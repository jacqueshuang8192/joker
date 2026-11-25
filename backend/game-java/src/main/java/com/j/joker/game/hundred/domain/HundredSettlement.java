package com.j.joker.game.hundred.domain;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

/** 已接受订单的税前净分。庄家按本局开始时的出资比例分摊。 */
public final class HundredSettlement {
    private HundredSettlement() {}
    public static int areas(int level) {
        return switch(level) { case 101 -> 3; case 102 -> 4; case Baccarat.LEVEL -> 5;
            default -> throw new IllegalArgumentException("未知百人场次"); };
    }
    public static int drawCount(int level) {
        return switch(level) { case 101 -> 2; case 102 -> 5; case Baccarat.LEVEL -> 6;
            default -> throw new IllegalArgumentException("未知百人场次"); };
    }
    public static Map<Integer,Long> settle(int level,List<Banker> bankers,List<Bet> bets,List<Integer> cards) {
        if(cards.size()!=drawCount(level)) throw new IllegalArgumentException("开牌张数有误");
        return switch(level) {
            case 101 -> dragonTiger(bankers,bets,cards.get(0),cards.get(1));
            case 102 -> beasts(bankers,bets,cards.get(0),cards.get(1),cards.get(2),cards.get(3),cards.get(4));
            case Baccarat.LEVEL -> Baccarat.settle(bankers,bets,cards);
            default -> throw new IllegalArgumentException("未知百人场次");
        };
    }
    public record Banker(int uid, int chips) {
        public Banker {
            if (uid <= 0 || chips <= 0) throw new IllegalArgumentException("庄家和出资额必须为正数");
        }
    }
    public record Bet(int uid, int area, int chips) {
        public Bet {
            if (uid <= 0 || chips <= 0) throw new IllegalArgumentException("玩家和下注额必须为正数");
        }
    }

    public static Map<Integer,Long> dragonTiger(List<Banker> bankers, List<Bet> bets, int dragon, int tiger) {
        var winner = HundredPlayerCards.dragonTiger(dragon, tiger);
        return distribute(bankers, bets, List.of(winner.net(1,0,0), winner.net(0,1,0), winner.net(0,0,1)));
    }

    public static Map<Integer,Long> beasts(List<Banker> bankers, List<Bet> bets,
                                            int house, int dragon, int tiger, int bird, int turtle) {
        var rates = HundredPlayerCards.beasts(house, dragon, tiger, bird, turtle).stream()
                .map(card -> card.playerWins() ? (long)card.winningRank() : -(long)card.winningRank()).toList();
        return distribute(bankers, bets, rates);
    }

    private record Remainder(int uid, BigInteger fraction) {}

    static Map<Integer,Long> distribute(List<Banker> bankers, List<Bet> bets, List<Long> rates) {
        if (bankers.isEmpty() || bankers.size() > 6) throw new IllegalArgumentException("每局需要 1 至 6 名庄家");
        var dealerIds = new HashSet<Integer>();
        long pool = 0;
        for (Banker banker : bankers) {
            if (!dealerIds.add(banker.uid)) throw new IllegalArgumentException("同一庄家多次出资");
            pool += banker.chips;
        }
        var net = new HashMap<Integer,Long>();
        long house = 0;
        for (Bet bet : bets) {
            if (dealerIds.contains(bet.uid) || bet.area < 1 || bet.area > rates.size())
                throw new IllegalArgumentException("庄家不能下注，且下注必须属于本玩法");
            long amount = rates.get(bet.area - 1) * bet.chips;
            net.merge(bet.uid, amount, Math::addExact);
            house = Math.subtractExact(house, amount);
        }
        if (house < -pool) throw new IllegalArgumentException("当前庄家出资不足以结算这批订单");
        var total = BigInteger.valueOf(house).abs();
        var invested = BigInteger.valueOf(pool);
        var remainders = new ArrayList<Remainder>();
        int sign = Long.signum(house);
        long left = total.longValueExact();
        for (Banker banker : bankers) {
            var parts = total.multiply(BigInteger.valueOf(banker.chips)).divideAndRemainder(invested);
            long share = parts[0].longValueExact();
            left -= share;
            net.put(banker.uid, sign * share);
            remainders.add(new Remainder(banker.uid, parts[1]));
        }
        // 最大余数法。同余数依次按客户端 bankerList 中的上庄顺序分配一个最小单位。
        remainders.sort(Comparator.comparing(Remainder::fraction).reversed());
        for (int i = 0; i < left; i++) net.merge(remainders.get(i).uid, (long)sign, Math::addExact);
        return Map.copyOf(net);
    }
}
