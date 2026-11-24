package com.j.joker.game.niuniu.domain.card;

import com.j.joker.game.niuniu.domain.rules.GameConfig;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 牛牛牌型判定与比牌。
 *
 * <p>房间配置决定启用哪些特殊牌型。
 */
public final class CardLogic {

    private CardLogic() {
    }

    public static final Comparator<Card> BY_RANK_THEN_SUIT =
            Comparator.comparingInt(Card::rank).thenComparingInt(c -> c.suit().code());

    public static List<Card> sorted(List<Card> hand) {
        List<Card> copy = new ArrayList<>(hand);
        copy.sort(BY_RANK_THEN_SUIT);
        return copy;
    }

    public static int sum(List<Card> cards) {
        int s = 0;
        for (Card c : cards) {
            s += c.logicValue();
        }
        return s;
    }

    /**
     * 评估一手牌。{@code cfg} 决定特殊牌型开关与“无花牛牛/癞子”玩法。
     */
    public static HandResult evaluate(List<Card> hand, GameConfig cfg) {
        if (hand == null || hand.size() < 3) {
            throw new IllegalArgumentException("手牌不足: " + hand);
        }
        List<Card> cards = sorted(hand);
        int total = sum(cards);

        CardType special = detectSpecial(cards, total, cfg);
        if (special != null) {
            return new HandResult(cards, special, List.of(), total, 0);
        }

        if (cfg != null && cfg.isLeperEnabled()) {
            HandResult leper = evaluateWithLeper(cards, cfg);
            if (leper != null) {
                return leper;
            }
        }

        HandResult normal = detectNormalNiu(cards);
        if (cfg != null && cfg.isNoFlowerNiu()) {
            // 无花牛牛：普通牌型与金牌牛取较大者（cardLogic.lua:138–155）
            HandResult gold = detectGoldNiu(cards);
            if (gold != null && gold.type() != CardType.WU_NIU
                    && (normal == null || gold.type().strength() > normal.type().strength())) {
                return gold;
            }
        }
        return normal != null ? normal : new HandResult(cards, CardType.WU_NIU, List.of(), total, 0);
    }

    /** 不带特殊牌型开关的默认评估（所有特殊牌型开启）。 */
    public static HandResult evaluate(List<Card> hand) {
        return evaluate(hand, GameConfig.builder().build());
    }

    private static CardType detectSpecial(List<Card> cards, int total, GameConfig cfg) {
        if (allowed(cfg, 8) && isSameSuit(cards) && isStraight(cards)) {
            return CardType.TONG_HUA_SHUN;
        }
        // 部署镜像的 DouNiuServerGroup_new 保留四十大的编号，普通房的 countfan 没有这个分支。
        if (allowed(cfg, 6) && total <= 10 && cards.stream().allMatch(c -> c.value() <= 5)) {
            return CardType.WU_XIAO;
        }
        if (allowed(cfg, 5) && isFourOfKind(cards)) {
            return CardType.SI_ZHA;
        }
        if (allowed(cfg, 4) && isFullHouse(cards)) {
            return CardType.HU_LU;
        }
        if (allowed(cfg, 3) && isSameSuit(cards)) {
            return CardType.TONG_HUA;
        }
        if (allowed(cfg, 2) && isAllFace(cards)) {
            return CardType.WU_HUA;
        }
        if (allowed(cfg, 1) && isStraight(cards)) {
            return CardType.SHUN_ZI;
        }
        return null;
    }

    private static boolean allowed(GameConfig cfg, int speTypeBit) {
        return cfg == null || cfg.isSpeTypeEnabled(speTypeBit);
    }

    private static boolean isFourOfKind(List<Card> cards) {
        Map<Integer, Integer> count = rankCount(cards);
        return count.containsValue(4);
    }

    private static boolean isFullHouse(List<Card> cards) {
        Map<Integer, Integer> count = rankCount(cards);
        return count.size() == 2 && count.containsValue(3);
    }

    private static boolean isSameSuit(List<Card> cards) {
        if (cards.isEmpty()) {
            return false;
        }
        int suit = cards.get(0).suit().code();
        for (Card c : cards) {
            if (c.suit().code() != suit) {
                return false;
            }
        }
        return true;
    }

    private static boolean isAllFace(List<Card> cards) {
        for (Card c : cards) {
            if (c.value() < 10 || c.value() > 13) {
                return false;
            }
        }
        return true;
    }

    private static boolean isStraight(List<Card> cards) {
        // A 可当 1 也可当 14，整体看是否存在 5 张连续点数
        Map<Integer, Boolean> distinct = new HashMap<>();
        for (Card c : cards) {
            distinct.put(c.rank(), true);
            if (c.rank() == 14) {
                distinct.put(1, true);
            }
        }
        List<Integer> ranks = new ArrayList<>(distinct.keySet());
        ranks.sort(Integer::compareTo);
        int run = 1;
        for (int i = 1; i < ranks.size(); i++) {
            if (ranks.get(i) == ranks.get(i - 1) + 1) {
                run++;
                if (run >= 5) {
                    return true;
                }
            } else if (!ranks.get(i).equals(ranks.get(i - 1))) {
                run = 1;
            }
        }
        return run >= 5;
    }

    /** 无花牛牛：存在三张同点，剩余两张求和取个位。 */
    private static HandResult detectGoldNiu(List<Card> cards) {
        Map<Integer, Integer> count = rankCount(cards);
        for (Map.Entry<Integer, Integer> e : count.entrySet()) {
            if (e.getValue() == 3) {
                List<Card> rest = new ArrayList<>();
                for (Card c : cards) {
                    if (c.rank() != e.getKey()) {
                        rest.add(c);
                    }
                }
                if (rest.size() != 2) {
                    continue;
                }
                int restSum = sum(rest);
                if (restSum % 10 == 0) {
                    return new HandResult(cards, CardType.NIU_NIU, rest, sum(cards), restSum);
                }
                return new HandResult(cards, CardType.GOLD_NIU, rest, sum(cards), restSum);
            }
        }
        return null;
    }

    private static HandResult detectNormalNiu(List<Card> cards) {
        int n = cards.size();
        for (int i = 0; i < n - 2; i++) {
            for (int j = i + 1; j < n - 1; j++) {
                for (int k = j + 1; k < n; k++) {
                    int s = cards.get(i).logicValue() + cards.get(j).logicValue() + cards.get(k).logicValue();
                    if (s % 10 != 0) {
                        continue;
                    }
                    List<Card> niuPart = List.of(cards.get(i), cards.get(j), cards.get(k));
                    List<Card> rest = new ArrayList<>(cards);
                    rest.remove(cards.get(i));
                    rest.remove(cards.get(j));
                    rest.remove(cards.get(k));
                    int restSum = sum(rest);
                    CardType type;
                    if (restSum % 10 == 0) {
                        type = CardType.NIU_NIU;
                    } else {
                        type = CardType.ofId(restSum % 10 + 1); // 无牛=1，牛一=2 … 牛牛=11
                    }
                    return new HandResult(cards, type, niuPart, sum(cards), restSum);
                }
            }
        }
        return null;
    }

    /** 癞子：枚举替换成 52 张中的任意一张，取牌型最强的一种。 */
    private static HandResult evaluateWithLeper(List<Card> cards, GameConfig cfg) {
        int idx = -1;
        for (int i = 0; i < cards.size(); i++) {
            if (cards.get(i).suit() == Suit.LAI_ZI) {
                idx = i;
                break;
            }
        }
        if (idx < 0) {
            return null;
        }
        HandResult best = null;
        for (int code = 0x01; code <= 0x3D; code++) {
            if ((code & 0x0F) == 0 || (code & 0x0F) > 13) {
                continue;
            }
            List<Card> trial = new ArrayList<>(cards);
            trial.set(idx, Card.of(code));
            HandResult r = evaluate(trial, cfg);
            if (best == null || compare(r, best) > 0) {
                best = r;
            }
        }
        return best;
    }

    private static Map<Integer, Integer> rankCount(List<Card> cards) {
        Map<Integer, Integer> map = new HashMap<>();
        for (Card c : cards) {
            map.merge(c.rank(), 1, Integer::sum);
        }
        return map;
    }

    /**
     * 比牌，对应 CGameTable::CompareUserCards(0x4d9926) / CompareUser(0x4d9efe)：
     * <ol>
     *   <li>牌型编号差（hasJQK!=1 时四炸 +3 → 19）；</li>
     *   <li>同为五小牛：比五张点数和；</li>
     *   <li>同为四炸：比"炸的那张"；</li>
     *   <li>其余：比最大单张（点数 A=1，再比花色）。</li>
     * </ol>
     * 返回 &gt;0 表示 a 赢，&lt;0 表示 b 赢，0 表示完全相同。
     */
    public static int compare(HandResult a, HandResult b, GameConfig cfg) {
        int ta = a.type().id();
        int tb = b.type().id();
        double fa = ta;
        double fb = tb;
        if (cfg != null && !cfg.hasJQK()) {
            if (ta == CardType.SI_ZHA.id()) {
                fa += 3.0;
            }
            if (tb == CardType.SI_ZHA.id()) {
                fb += 3.0;
            }
        }
        if (fa != fb) {
            return Double.compare(fa, fb);
        }
        if (ta == CardType.WU_XIAO.id()) {
            int s = sum(a.hand()) - sum(b.hand());
            if (s != 0) {
                return s;
            }
        }
        if (ta == CardType.SI_ZHA.id()) {
            int r = Integer.compare(siZhaValue(a.hand()), siZhaValue(b.hand()));
            if (r != 0) {
                return r;
            }
        }
        return maxCard(a.hand()).compareTo(maxCard(b.hand()));
    }

    public static int compare(HandResult a, HandResult b) {
        return compare(a, b, null);
    }

    private static Card maxCard(List<Card> cards) {
        Card best = null;
        for (Card c : cards) {
            if (best == null || c.compareTo(best) > 0) {
                best = c;
            }
        }
        return best == null ? Card.of(0x02) : best;
    }

    /** 四炸代表牌：排序后取四张同点中的那张。 */
    private static int siZhaValue(List<Card> cards) {
        Map<Integer, Integer> count = rankCount(cards);
        for (Map.Entry<Integer, Integer> e : count.entrySet()) {
            if (e.getValue() == 4) {
                return e.getKey() == 14 ? 1 : e.getKey();
            }
        }
        return 0;
    }
}
