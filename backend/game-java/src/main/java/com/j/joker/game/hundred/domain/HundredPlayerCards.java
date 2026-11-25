package com.j.joker.game.hundred.domain;

import java.util.HashSet;
import java.util.List;

/** 客户端百人龙虎（101）和百人神兽（102）的单副 52 张牌及公开比牌规则。 */
public final class HundredPlayerCards {
    private HundredPlayerCards() {}

    public record Card(int code) {
        public Card {
            int pip = code & 15;
            if (code < 1 || code > 0x3d || pip < 1 || pip > 13)
                throw new IllegalArgumentException("无效的百人场牌值 " + code);
        }
        public int rank() { return code & 15; }
        public int suit() { return code >>> 4; }
    }

    private static List<Card> deal(int... codes) {
        var cards = java.util.Arrays.stream(codes).mapToObj(Card::new).toList();
        if (new HashSet<>(cards).size() != cards.size()) throw new IllegalArgumentException("同一副牌中出现重复牌");
        return cards;
    }

    public enum DragonTiger { DRAGON, TIGER, TIE;
        /** 已接受投注的净输赢，使用调用者传入的筹码最小单位。 */
        public long net(long dragon, long tiger, long tie) {
            if (dragon < 0 || tiger < 0 || tie < 0) throw new IllegalArgumentException("投注不能为负");
            return switch (this) {
                case DRAGON -> Math.subtractExact(dragon - tiger, tie);
                case TIGER -> Math.subtractExact(tiger - dragon, tie);
                case TIE -> Math.multiplyExact(6L, tie);
            };
        }
    }

    public static DragonTiger dragonTiger(int dragon, int tiger) {
        var cards = deal(dragon, tiger);
        int byRank = Integer.compare(cards.get(0).rank(), cards.get(1).rank());
        if (byRank == 0) return DragonTiger.TIE;
        return byRank > 0 ? DragonTiger.DRAGON : DragonTiger.TIGER;
    }

    public record BeastResult(boolean playerWins, int winningRank) {}

    /** 返回青龙、白虎、朱雀、玄武的比牌结果。点数相同按方、梅、红、黑排序。 */
    public static List<BeastResult> beasts(int banker, int dragon, int tiger, int bird, int turtle) {
        var cards = deal(banker, dragon, tiger, bird, turtle);
        var house = cards.getFirst();
        return cards.subList(1, 5).stream().map(card -> {
            int byRank = Integer.compare(card.rank(), house.rank());
            boolean wins = byRank == 0 ? card.suit() > house.suit() : byRank > 0;
            return new BeastResult(wins, wins ? card.rank() : house.rank());
        }).toList();
    }
}
