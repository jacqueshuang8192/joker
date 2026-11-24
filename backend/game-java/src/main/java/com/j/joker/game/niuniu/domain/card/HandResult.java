package com.j.joker.game.niuniu.domain.card;

import java.util.List;

/**
 * 一手牌的评估结果。
 *
 * @param hand    原始 5 张（或配置的 cardCount 张）牌
 * @param type    牌型
 * @param niuPart 凑成整十的三张牌；无牛时为空
 * @param sum     全部牌的逻辑点数之和
 * @param restSum 剩余两张的逻辑点数之和（用于展示“牛几”）
 */
public record HandResult(List<Card> hand, CardType type, List<Card> niuPart, int sum, int restSum) {

    public boolean hasNiu() {
        return type != CardType.WU_NIU;
    }

    public boolean isSpecial() {
        return type.id() >= CardType.SHUN_ZI.id() || type == CardType.GOLD_NIU;
    }

    /** 未经过 timesRule 配置覆盖的默认倍数。 */
    public int defaultMultiplier() {
        return type.defaultMultiplier();
    }

    public String describe() {
        StringBuilder sb = new StringBuilder(type.cnName());
        if (niuPart != null && !niuPart.isEmpty()) {
            sb.append(" [");
            for (int i = 0; i < niuPart.size(); i++) {
                if (i > 0) {
                    sb.append(' ');
                }
                sb.append(niuPart.get(i).display());
            }
            sb.append(']');
        }
        return sb.toString();
    }
}
