package com.j.joker.game.niuniu.domain.rules;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;

/** 俱乐部模板约定的百分比、固定积分和区间收费。所有计算结果均为百分之一积分。 */
public record ClubFee(int mode, BigDecimal profit, long threshold, int winners, boolean share,
                      int additional, boolean partnerFunded, Map<Long,Integer> tiers, int startCost, boolean firstOnly, int upRate, int downRate) {
    public boolean hasTableCharges() { return startCost > 0 || upRate > 0 || downRate > 0; }
    public record Charge(int base, int additional) { public long total() { return (long)base + additional; } }
    public record Plan(Map<Integer,Charge> charges, Map<Integer,Integer> attribution) {
        public long total() { return charges.values().stream().mapToLong(Charge::total).sum(); }
    }
    public boolean enabled() { return profit.signum() > 0 || !tiers.isEmpty() || additional > 0; }
    private static BigDecimal number(Map<String,Object> m, String key, int fallback) {
        Object value = m.get(key);
        if (value instanceof Map<?,?> option) value = option.get("optionValue");
        if (value == null || value.toString().isBlank()) return BigDecimal.valueOf(fallback);
        return new BigDecimal(value.toString().trim()).stripTrailingZeros();
    }
    public static ClubFee from(Map<String,Object> rules) {
        int mode = number(rules,"rateOrConstant",1).intValueExact();
        var profit = number(rules,"profit",0);
        int winners = number(rules,"profitType",0).intValueExact();
        int sharing = number(rules,"oneOrAll",2).intValueExact();
        int threshold = number(rules,"profitLimit",5000).intValueExact();
        int extra = number(rules,"additionalPoint",0).intValueExact();
        if (mode < 1 || mode > 3 || profit.signum() < 0 || mode == 1 && profit.compareTo(BigDecimal.valueOf(100)) > 0
                || winners < 0 || winners > 3 || sharing < 1 || sharing > 2 || threshold < 0 || extra < 0)
            throw new IllegalArgumentException("俱乐部收费模板无效");
        Map<Long,Integer> tiers = new TreeMap<>();
        String raw = Objects.toString(rules.get("secConstant"), "").trim();
        if (mode == 3 && !raw.isEmpty()) for (String item : raw.split(",")) {
            String[] fields = item.split("-");
            if (fields.length != 3) throw new IllegalArgumentException("区间须填写起点、终点和金额");
            long start = Long.parseLong(fields[0]), end = Long.parseLong(fields[1]);
            int fee = Integer.parseInt(fields[2]);
            if (start < 0 || end < start || fee < 0 || tiers.put(start,fee) != null)
                throw new IllegalArgumentException("俱乐部区间重叠或金额无效");
        }
        String source = Objects.toString(rules.get("additional_point_from"), "0");
        boolean partner = switch (source) {
            case "1", "partner" -> true;
            case "0", "player" -> false;
            default -> throw new IllegalArgumentException("额外赠分来源无效");
        };
        int start = number(rules, "startCost", 0).intValueExact();
        int once = number(rules, "startCostOneOrAll", 0).intValueExact();
        int up = number(rules, "upBankWater", 0).intValueExact();
        int down = number(rules, "downBankWater", 0).intValueExact();
        if (start < 0 || once < 0 || once > 1 || up < 0 || up > 100 || down < 0 || down > 100)
            throw new IllegalArgumentException("台费或上下庄费率无效");
        return new ClubFee(mode, profit, threshold, winners, sharing == 2, extra, partner, Map.copyOf(tiers), start, once == 1, up, down);
    }
    public Plan calculate(Map<Integer,Long> scores, Map<Integer,Long> balances) {
        var charges = new TreeMap<Integer,Charge>();
        var attribution = new TreeMap<Integer,Integer>();
        var ranked = scores.entrySet().stream().sorted(Map.Entry.<Integer,Long>comparingByValue().reversed()
                .thenComparing(Map.Entry.comparingByKey())).toList();
        long previous = Long.MAX_VALUE, totalBase = 0;
        int rank = 0;
        for (var entry : ranked) {
            long score = entry.getValue();
            if (score <= 0 || score < threshold || winners > 0 && rank >= winners && score < previous) break;
            previous = score;
            rank++;
            long limit = Math.min(score, balances.getOrDefault(entry.getKey(),0L));
            BigDecimal rate = switch (mode) {
                case 1 -> BigDecimal.valueOf(score).multiply(profit).movePointLeft(2);
                case 2 -> profit.movePointRight(2);
                default -> BigDecimal.valueOf(tiers.entrySet().stream().filter(t -> t.getKey() <= score)
                        .max(Map.Entry.comparingByKey()).map(Map.Entry::getValue).orElse(0));
            };
            int base = rate.min(BigDecimal.valueOf(limit)).setScale(0,RoundingMode.DOWN).intValueExact();
            int extra = partnerFunded ? 0 : (int)Math.min(additional,limit - base);
            if (base + (long)extra == 0) continue;
            charges.put(entry.getKey(), new Charge(base,extra));
            totalBase += base;
            if (base > 0) attribution.put(entry.getKey(),base);
        }
        // 平摊的是用于代理分成的贡献额，玩家仍按自己的胜分承担费用。
        // 合伙人承担时，从本次基础费用中划出一次额外赠分，剩余贡献按全桌平摊。
        long allocation = partnerFunded ? Math.min(additional, totalBase) : 0;
        if (allocation > 0) {
            totalBase -= allocation;
            long left = allocation;
            for (var winner : ranked) {
                var charge = charges.get(winner.getKey());
                if (charge == null) continue;
                int split = (int)Math.min(left, charge.base());
                charges.put(winner.getKey(), new Charge(charge.base() - split, split));
                left -= split;
                if (left == 0) break;
            }
            attribution.clear();
        }
        if ((share || allocation > 0) && totalBase > 0) {
            attribution.clear();
            int each = Math.toIntExact(totalBase / scores.size());
            for (int uid : scores.keySet()) attribution.put(uid,each);
            attribution.merge(ranked.getFirst().getKey(), (int)(totalBase % scores.size()), Math::addExact);
        }
        return new Plan(Map.copyOf(charges),Map.copyOf(attribution));
    }
}
