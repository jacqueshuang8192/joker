package com.j.joker.game.niuniu.domain.table;

import com.j.joker.game.niuniu.domain.card.CardLogic;
import com.j.joker.game.niuniu.domain.card.HandResult;
import com.j.joker.game.niuniu.domain.rules.GameConfig;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 一局结算，逐条对应 CGameTable::CalcMoneyAndUpdate() @ 0x4d52b0。
 *
 * <pre>
 * UNIT     = baseChip × 10 × forDecimal
 * d        = pointMode==1 ? CT[赢家牌型] : CT[赢家牌型] - CT[输家牌型]   （为 0 时取 1）
 * m_blance = ±(闲家下注倍数 × d × 抢庄倍数)                            （庄赢为负）
 * amount   = m_blance × UNIT
 * 单人封顶 ：闲家输/赢不超过自己的金币
 * 庄家封顶 ：庄净赢 > 庄家金币 → 按比例削减输家；庄净赔 > 庄家金币 → 按比例削减赢家
 * 抽水     ：单局结算不抽水（commission_rate 属俱乐部侧，默认 0）
 * </pre>
 *
 * 所有循环按座位号升序，按累计权重分摊整数筹码，尾数计入本局分配。
 */
public final class Settlement {

    public record Entry(long uid, int seatId, String nick, boolean banker, int betTimes, int grabTimes,
                        String cardType, int typeMultiplier, long before, long delta, long commission, int winTimes, int nextPush) {
    }

    public record Result(int roundNo, long bankerUid, long bankerDelta, long commissionTotal, long totalAmount,
                         List<Entry> entries, SideBets.Posting side, com.j.joker.game.niuniu.domain.rules.ClubFee.Plan fees) {
    }

    private Settlement() {
    }

    public static Result settle(NiuNiuTable table) {
        Result result = calculate(table);
        apply(table, result);
        return result;
    }

    static void apply(NiuNiuTable table, Result result) {
        for (Entry entry : result.entries()) {
            Player p = table.byUid(entry.uid());
            p.setRoundDelta(entry.delta());
            p.addChips(entry.delta());
            p.addTotalDelta(entry.delta());
            p.setPushLimit(entry.nextPush());
        }
    }

    static Result calculate(NiuNiuTable table) {
        GameConfig cfg = table.config();
        Player banker = table.banker();
        if (banker == null) {
            for (Player p : table.players()) {
                if (p.banker()) {
                    banker = p;
                    break;
                }
            }
        }
        if (banker == null) {
            throw new IllegalStateException("本局没有庄家");
        }
        if (banker.hand() == null) {
            throw new IllegalStateException("庄家没有手牌");
        }

        BigInteger unit = BigInteger.valueOf(cfg.baseChip()).multiply(BigInteger.TEN)
                .multiply(BigInteger.valueOf(cfg.forDecimal()));
        if (cfg.gongNiu()) unit = BigInteger.valueOf(100);
        int grab = cfg.gongNiu() ? 1 : Math.max(1, banker.grabTimes());
        HandResult bankerHand = banker.hand();

        List<Player> ordered = new ArrayList<>(table.players());
        ordered.sort((a, b) -> Integer.compare(a.seatId(), b.seatId()));

        Map<Player, Long> amounts = new LinkedHashMap<>();
        Map<Player, Integer> typeMult = new LinkedHashMap<>();
        Map<Player, BigInteger> winTimes = new LinkedHashMap<>();
        BigInteger bankTimes = BigInteger.ZERO;
        long totalLosers = 0;
        long totalWinners = 0;

        for (Player p : ordered) {
            if (p == banker || p.hand() == null) {
                continue;
            }
            // CompareUser(庄, 闲) > 0 → 庄赢；完全相同也判庄赢
            boolean bankerWins = CardLogic.compare(bankerHand, p.hand(), cfg) >= 0;
            HandResult winner = bankerWins ? bankerHand : p.hand();
            HandResult loser = bankerWins ? p.hand() : bankerHand;
            int d;
            if (!cfg.pointDValue() || cfg.pointMode() == 1) {
                // 非点差玩法：只取胜方牌型倍数
                d = cfg.cardTypeTimes(winner.type());
            } else {
                d = cfg.cardTypeTimes(winner.type()) - cfg.cardTypeTimes(loser.type());
            }
            if (d == 0) {
                d = 1;
            }
            BigInteger units = BigInteger.valueOf((long) (cfg.gongNiu() ? p.betTimes() : Math.max(1, p.betTimes())) * grab)
                    .multiply(BigInteger.valueOf(Math.abs((long) d)));
            BigInteger signed = bankerWins ? units.negate() : units;
            winTimes.put(p, signed);
            bankTimes = bankTimes.subtract(signed);
            long limit = bankerWins ? p.chips() : Math.min(p.chips(), Integer.MAX_VALUE - p.chips());
            limit -= table.side().reserved(p.uid());
            long amount = unit.multiply(units).min(BigInteger.valueOf(limit)).longValueExact();
            if (bankerWins) amount = -amount;
            amounts.put(p, amount);
            typeMult.put(p, d);
            if (amount < 0) {
                totalLosers += -amount;
            } else {
                totalWinners += amount;
            }
        }

        long diff = totalLosers - totalWinners;
        long bankerDelta = Math.clamp(diff, -banker.chips() + table.side().reserved(banker.uid()), Math.min(banker.chips(), Integer.MAX_VALUE - banker.chips()) - table.side().reserved(banker.uid()));
        if (cfg.gongNiu()) {
            // 先收闲家输分，再按牌力从强到弱赔付，锅底和庄家筹码同时封顶。
            long collected = Math.min(totalLosers, Integer.MAX_VALUE - banker.chips() - table.side().reserved(banker.uid()));
            if (collected < totalLosers) distribute(amounts, -1, totalLosers, collected);
            long available = Math.min(100L * table.potPoints(), banker.chips() - table.side().reserved(banker.uid())) + collected;
            var winners = ordered.stream().filter(p -> amounts.getOrDefault(p, 0L) > 0)
                    .sorted((a,b) -> CardLogic.compare(b.hand(), a.hand(), cfg)).toList();
            bankerDelta = collected;
            for (Player player : winners) {
                long paid = Math.min(available, amounts.get(player));
                amounts.put(player, paid);
                available -= paid;
                bankerDelta -= paid;
            }
        } else if (diff > bankerDelta) {
            distribute(amounts, -1, totalLosers, totalWinners + bankerDelta);
        } else if (diff < bankerDelta) {
            distribute(amounts, 1, totalWinners, totalLosers - bankerDelta);
        }

        // 落账
        var side = table.side().settle(table);
        List<Entry> entries = new ArrayList<>();
        for (Player p : ordered) {
            long delta = p == banker ? bankerDelta : amounts.getOrDefault(p, 0L);
            if (side != null) delta += side.delta(p.uid());
            int mult = p == banker ? cfg.cardTypeTimes(bankerHand.type()) : typeMult.getOrDefault(p, 1);
            BigInteger signed = p == banker ? bankTimes : winTimes.getOrDefault(p, BigInteger.ZERO);
            // calTuizhu 取未乘金币单位的输赢倍数。用完推注档位或输牌后，下一局清零。
            long cap = (long) cfg.tuizhu() * cfg.betOptions()[0];
            int previousBet = p == banker ? 0 : p.betTimes();
            int nextPush = cap > 0 && signed.signum() > 0 && (p.pushLimit() == 0 || previousBet < p.pushLimit())
                    ? signed.add(BigInteger.valueOf(previousBet)).min(BigInteger.valueOf(Math.min(Integer.MAX_VALUE / 2, cap))).intValueExact() : 0;
            entries.add(new Entry(p.uid(), p.seatId(), p.nickName(), p == banker,
                    p.betTimes(), grab, p.hand() == null ? "-" : p.hand().type().cnName(),
                    mult, p.chips(), delta, 0, signed.max(BigInteger.valueOf(Integer.MIN_VALUE)).min(BigInteger.valueOf(Integer.MAX_VALUE)).intValueExact(), nextPush));
        }
        long totalAmount = 0;
        for (long v : amounts.values()) {
            totalAmount += Math.abs(v);
        }
        com.j.joker.game.niuniu.domain.rules.ClubFee.Plan fees = null;
        if (cfg.gongNiu() && cfg.clubFee().enabled()) {
            var scores = new LinkedHashMap<Integer,Long>();
            var balances = new LinkedHashMap<Integer,Long>();
            for (var entry : entries) {
                int uid = Math.toIntExact(entry.uid());
                scores.put(uid, entry.delta() - (side == null ? 0 : side.delta(entry.uid())));
                balances.put(uid, entry.before() + entry.delta());
            }
            fees = cfg.clubFee().calculate(scores,balances);
            for (int i = 0; i < entries.size(); i++) {
                var e = entries.get(i);
                var charge = fees.charges().get((int)e.uid());
                if (charge == null) continue;
                if (e.banker()) bankerDelta -= charge.total();
                entries.set(i,new Entry(e.uid(), e.seatId(), e.nick(), e.banker(), e.betTimes(), e.grabTimes(),
                        e.cardType(), e.typeMultiplier(), e.before(), e.delta()-charge.total(), charge.total(), e.winTimes(), e.nextPush()));
            }
        }
        if (side != null) side = side.withClosingBalances(entries);
        return new Result(table.roundNo(), banker.uid(), bankerDelta + (side == null ? 0 : side.delta(banker.uid())), fees == null ? 0 : fees.total(), totalAmount, entries, side, fees);
    }

    private static void distribute(Map<Player, Long> amounts, int sign, long total, long available) {
        long weight = 0;
        long allocated = 0;
        for (var entry : amounts.entrySet()) {
            long amount = entry.getValue();
            if (Long.signum(amount) != sign) continue;
            weight += Math.abs(amount);
            long share = BigInteger.valueOf(weight).multiply(BigInteger.valueOf(available))
                    .divide(BigInteger.valueOf(total)).longValueExact();
            entry.setValue(sign * (share - allocated));
            allocated = share;
        }
    }
}
