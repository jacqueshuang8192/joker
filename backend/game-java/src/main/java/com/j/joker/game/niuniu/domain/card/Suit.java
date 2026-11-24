package com.j.joker.game.niuniu.domain.card;

/**
 * 花色编码，直接对应客户端 PokerCard.lua 的 VARIETY_* 常量：
 * 牌值 = code &amp; 0x0F，花色 = code &amp; 0xF0。
 */
public enum Suit {
    DIAMOND(0x00, "方块", "♦"),
    CLUB(0x10, "梅花", "♣"),
    HEART(0x20, "红桃", "♥"),
    SPADE(0x30, "黑桃", "♠"),
    LAI_ZI(0x40, "癞子", "★"),
    JOKER(0x40, "王", "JOKER");

    private final int code;
    private final String cnName;
    private final String symbol;

    Suit(int code, String cnName, String symbol) {
        this.code = code;
        this.cnName = cnName;
        this.symbol = symbol;
    }

    public int code() {
        return code;
    }

    public String cnName() {
        return cnName;
    }

    public String symbol() {
        return symbol;
    }

    public static Suit ofCode(int masked) {
        int v = masked & 0xF0;
        return switch (v) {
            case 0x00 -> DIAMOND;
            case 0x10 -> CLUB;
            case 0x20 -> HEART;
            case 0x30 -> SPADE;
            case 0x40 -> LAI_ZI;
            default -> throw new IllegalArgumentException("未知花色: 0x" + Integer.toHexString(masked));
        };
    }
}
