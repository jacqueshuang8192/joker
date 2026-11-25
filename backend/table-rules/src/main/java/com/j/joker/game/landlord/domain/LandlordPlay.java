package com.j.joker.game.landlord.domain;

import java.util.HashSet;
import java.util.List;

/** 三人斗地主出牌。比较时只看主牌点数，牌码的高四位是花色。 */
public final class LandlordPlay {
    public enum Kind { SINGLE, PAIR, TRIPLE, TRIPLE_SINGLE, TRIPLE_PAIR, STRAIGHT, PAIR_RUN,
        TRIPLE_RUN, PLANE_SINGLES, PLANE_PAIRS, FOUR_SINGLES, FOUR_PAIRS, BOMB, ROCKET }

    private final Kind kind;
    private final int high;
    private final int size;

    private LandlordPlay(Kind kind, int high, int size) {
        this.kind = kind;
        this.high = high;
        this.size = size;
    }

    public Kind kind() { return kind; }

    static int rank(int code) {
        if (code == 0x4e || code == 0x4f) return code - 0x4e + 16;
        int face = code & 15;
        if (code < 1 || code > 0x3d || face < 1 || face > 13)
            throw new IllegalArgumentException("无效牌码 " + code);
        return face < 3 ? face + 13 : face;
    }

    public static LandlordPlay of(List<Integer> cards) {
        int size = cards.size();
        if (size == 0 || size > 20 || new HashSet<>(cards).size() != size)
            throw new IllegalArgumentException("出牌张数或牌码重复");
        int[] counts = new int[18];
        for (int card : cards) counts[rank(card)]++;
        int groups = 0, low = 18, high = 0, triple = 0, quad = 0, pairs = 0;
        for (int rank = 3; rank < counts.length; rank++) {
            if (counts[rank] == 0) continue;
            groups++;
            low = Math.min(low, rank);
            high = rank;
            switch (counts[rank]) {
                case 2 -> pairs++;
                case 3 -> triple = rank;
                case 4 -> quad = rank;
                default -> { }
            }
        }
        if (groups == 1) {
            Kind kind = switch (size) {
                case 1 -> Kind.SINGLE;
                case 2 -> Kind.PAIR;
                case 3 -> Kind.TRIPLE;
                case 4 -> Kind.BOMB;
                default -> throw new IllegalArgumentException("同点数牌过多");
            };
            return new LandlordPlay(kind, high, size);
        }
        if (size == 2 && low == 16 && high == 17) return new LandlordPlay(Kind.ROCKET, high, size);
        if (triple > 0 && size == 4) return new LandlordPlay(Kind.TRIPLE_SINGLE, triple, size);
        if (triple > 0 && size == 5 && pairs == 1) return new LandlordPlay(Kind.TRIPLE_PAIR, triple, size);
        if (quad > 0 && size == 6) return new LandlordPlay(Kind.FOUR_SINGLES, quad, size);
        if (quad > 0 && size == 8 && pairs == 2) return new LandlordPlay(Kind.FOUR_PAIRS, quad, size);
        if (high <= 14 && high - low + 1 == groups) {
            if (size == groups && groups >= 5) return new LandlordPlay(Kind.STRAIGHT, high, size);
            if (pairs == groups && groups >= 3) return new LandlordPlay(Kind.PAIR_RUN, high, size);
        }
        // 从最长的连续三张开始。机身和翅膀不能使用同一张牌。
        for (int length = size / 3; length >= 2; length--) {
            for (int top = 14; top - length + 1 >= 3; top--) {
                if (!hasBody(counts, top, length)) continue;
                Kind kind = null;
                if (size == 3 * length) kind = Kind.TRIPLE_RUN;
                else if (size == 4 * length) kind = Kind.PLANE_SINGLES;
                else if (size == 5 * length && pairs == length) kind = Kind.PLANE_PAIRS;
                if (kind != null) return new LandlordPlay(kind, top, size);
            }
        }
        throw new IllegalArgumentException("不符合斗地主牌型");
    }

    private static boolean hasBody(int[] counts, int top, int length) {
        for (int i = 0; i < length; i++) if (counts[top - i] != 3) return false;
        return true;
    }

    public boolean beats(LandlordPlay previous) {
        if (kind == previous.kind) return size == previous.size && high > previous.high;
        if (kind == Kind.ROCKET) return true;
        return kind == Kind.BOMB && previous.kind != Kind.ROCKET;
    }
}
