package com.j.joker.game.runfast.domain;

import java.util.List;

/** 十六张基础房，不启用三 A 炸、四带及飘分。 */
record RunFastPlay(Kind kind, int high, int bodies, int size) {
    enum Kind { SINGLE, PAIR, STRAIGHT, PAIRS, TRIPLES, BOMB }

    static int rank(int code) {
        int value = code & 15;
        return value < 3 ? value + 13 : value;
    }

    static RunFastPlay classify(List<Integer> cards, boolean last) {
        int size = cards.size(), groups = 0, low = 16, high = 0;
        int[] count = new int[16];
        for (int code : cards) {
            int rank = rank(code);
            if (count[rank]++ == 0) groups++;
            low = Math.min(low, rank);
            high = Math.max(high, rank);
        }
        if (groups == 1) {
            var kind = switch (size) {
                case 1 -> Kind.SINGLE;
                case 2 -> Kind.PAIR;
                case 3 -> last ? Kind.TRIPLES : null;
                case 4 -> Kind.BOMB;
                default -> null;
            };
            if (kind != null) return new RunFastPlay(kind, high, 1, size);
        }
        if (high <= 14 && high - low + 1 == groups) {
            if (size == groups && size >= 5) return new RunFastPlay(Kind.STRAIGHT, high, groups, size);
            if (groups >= 2 && size == 2 * groups) {
                boolean pairs = true;
                for (int i = low; i <= high; i++) pairs &= count[i] == 2;
                if (pairs) return new RunFastPlay(Kind.PAIRS, high, groups, size);
            }
        }
        // 每组三张带两张，可带对子。临出完才允许少带。
        for (int bodies = size / 3; bodies >= 1; bodies--) {
            if (size > 5 * bodies || !last && size != 5 * bodies) continue;
            for (int top = 14; top - bodies + 1 >= 3; top--) {
                boolean match = true;
                for (int i = 0; i < bodies; i++) match &= count[top - i] == 3;
                if (match) return new RunFastPlay(Kind.TRIPLES, top, bodies, size);
            }
        }
        return null;
    }

    boolean beats(RunFastPlay other, boolean last) {
        if (other == null) return true;
        if (kind == Kind.BOMB && other.kind != Kind.BOMB) return true;
        return kind == other.kind && bodies == other.bodies && high > other.high &&
                (size == other.size || last && kind == Kind.TRIPLES && size < other.size);
    }
}
