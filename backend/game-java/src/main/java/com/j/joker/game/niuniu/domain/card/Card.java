package com.j.joker.game.niuniu.domain.card;

/**
 * 一张牌。
 *
 * <p>编码规则来自客户端 PokerCard.lua 与 cardLogic.lua：
 * <pre>
 *   value = code &amp; 0x0F;  value == 1 视为 14（A）
 *   suit  = code &amp; 0xF0;  0x00 方块 / 0x10 梅花 / 0x20 红桃 / 0x30 黑桃 / 0x40 癞子
 *   code == 0x4E 小王, 0x4F 大王
 * </pre>
 * 例：0x01 = 方块A，0x0A = 方块10，0x2B = 红桃J，0x3D = 黑桃K。
 */
public final class Card implements Comparable<Card> {

    public static final int SMALL_JOKER = 0x4E;
    public static final int BIG_JOKER = 0x4F;

    private final int code;

    private Card(int code) {
        this.code = code & 0xFF;
    }

    public static Card of(int code) {
        return new Card(code);
    }

    public int code() {
        return code;
    }

    public boolean isJoker() {
        return code == SMALL_JOKER || code == BIG_JOKER;
    }

    /** 服务端 GetCardValue：A=1，J/Q/K=11/12/13（用于比大小/顺子）。 */
    public int value() {
        return code & 0x0F;
    }

    /** 原始点数：A=14，J/Q/K=11/12/13（用于五花牛等牌型判定）。 */
    public int rank() {
        int v = code & 0x0F;
        return v == 1 ? 14 : v;
    }

    /** 比牌用的牌力值：A=1，10/J/Q/K=10。 */
    public int logicValue() {
        return Math.min(value(), 10);
    }

    public Suit suit() {
        return Suit.ofCode(code);
    }

    public String display() {
        if (isJoker()) {
            return code == BIG_JOKER ? "大王" : "小王";
        }
        String r = switch (rank()) {
            case 14 -> "A";
            case 13 -> "K";
            case 12 -> "Q";
            case 11 -> "J";
            default -> String.valueOf(rank());
        };
        return suit().symbol() + r;
    }

    /**
     * 与服务端 CGameLogic::CompareCard 一致：先比点数（A=1 最小），再比花色
     * （方块 0 &lt; 梅花 1 &lt; 红桃 2 &lt; 黑桃 3）。
     */
    @Override
    public int compareTo(Card o) {
        if (value() != o.value()) {
            return Integer.compare(value(), o.value());
        }
        return Integer.compare(suit().code(), o.suit().code());
    }

    @Override
    public boolean equals(Object o) {
        return o instanceof Card c && c.code == code;
    }

    @Override
    public int hashCode() {
        return code;
    }

    @Override
    public String toString() {
        return String.format("%s(0x%02X)", display(), code);
    }
}
