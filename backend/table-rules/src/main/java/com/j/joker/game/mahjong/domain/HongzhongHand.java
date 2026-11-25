package com.j.joker.game.mahjong.domain;

import java.util.Arrays;
import java.util.List;

/** 308 红中麻将。三门数牌，可选加入四张万能红中。 */
public final class HongzhongHand {
    public static final int RED = 0x41;
    private HongzhongHand() {}

    public record Meld(int tile, int copies) {
        public Meld {
            index(tile);
            if (copies != 3 && copies != 4) throw new IllegalArgumentException("副露须为碰或杠");
        }
    }

    private static int index(int tile) {
        int suit = tile >>> 4, pip = tile & 15;
        if (suit > 2 || pip < 1 || pip > 9) throw new IllegalArgumentException("不属于三门数牌 " + tile);
        return 9 * suit + pip - 1;
    }

    public static boolean wins(List<Integer> concealed, List<Meld> melds, boolean useRed, boolean opening) {
        if (melds.size() > 4 || opening && !melds.isEmpty()) throw new IllegalArgumentException("副露数量不符");
        int[] counts = new int[27];
        int jokers = 0;
        for (int tile : concealed) {
            if (tile == RED && useRed) jokers++;
            else counts[index(tile)]++;
        }
        int[] held = counts.clone();
        for (Meld meld : melds) held[index(meld.tile)] += meld.copies;
        if (jokers > 4 || Arrays.stream(held).anyMatch(n -> n > 4))
            throw new IllegalArgumentException("同种牌超过四张");
        if (opening && jokers == 4 && (concealed.size() == 13 || concealed.size() == 14)) return true;
        if (concealed.size() != 14 - 3 * melds.size()) return false;
        int odd = Arrays.stream(counts).map(n -> n % 2).sum();
        if (melds.isEmpty() && odd <= jokers) return true; // 七对
        for (int i = 0; i < counts.length; i++) {
            if (counts[i] == 0) continue;
            int natural = Math.min(2, counts[i]);
            if (2 - natural > jokers) continue;
            counts[i] -= natural;
            boolean match = groups(counts, jokers - (2 - natural));
            counts[i] += natural;
            if (match) return true;
        }
        return jokers >= 2 && groups(counts, jokers - 2);
    }

    private static boolean groups(int[] counts, int wild) {
        int first = 0;
        while (first < counts.length && counts[first] == 0) first++;
        if (first == counts.length) return wild % 3 == 0;

        int natural = Math.min(counts[first], 3);
        if (3 - natural <= wild) {
            counts[first] -= natural;
            boolean match = groups(counts, wild - (3 - natural));
            counts[first] += natural;
            if (match) return true;
        }
        // 最小的实牌也可以是顺子的第二、三张。低张可由红中补齐。
        int suitStart = first / 9 * 9;
        for (int start = Math.max(suitStart, first - 2); start <= Math.min(first, suitStart + 6); start++) {
            int[] rest = counts.clone();
            int remaining = wild;
            for (int i = start; i < start + 3; i++) {
                if (rest[i] > 0) rest[i]--;
                else remaining--;
            }
            if (remaining >= 0 && groups(rest, remaining)) return true;
        }
        return false;
    }
}
