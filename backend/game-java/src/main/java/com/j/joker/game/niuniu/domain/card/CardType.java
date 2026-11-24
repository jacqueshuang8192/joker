package com.j.joker.game.niuniu.domain.card;

/**
 * 牌型枚举。
 *
 * <p>编号同时是客户端 cardType 字段与 CARDKIND_* 常量：
 * <pre>
 *  1 无牛 ... 10 牛九, 11 牛牛,
 *  12 顺子牛 SHUNZI, 13 五花牛 WUHUA, 14 同花牛 TONGHUANIU,
 *  15 葫芦牛 HULUNIU, 16 四炸 SIZHA, 17 五小牛 WUXIAONIU, 18 四十大 SISHIDA,
 *  19 同花顺 TONGHUASHUN,
 *  -1 金牌牛（无花牛牛玩法）
 * </pre>
 */
public enum CardType {
    GOLD_NIU(-1, "金牌牛", 11),
    WU_NIU(1, "无牛", 0),
    NIU_1(2, "牛一", 1),
    NIU_2(3, "牛二", 2),
    NIU_3(4, "牛三", 3),
    NIU_4(5, "牛四", 4),
    NIU_5(6, "牛五", 5),
    NIU_6(7, "牛六", 6),
    NIU_7(8, "牛七", 7),
    NIU_8(9, "牛八", 8),
    NIU_9(10, "牛九", 9),
    NIU_NIU(11, "牛牛", 10),
    SHUN_ZI(12, "顺子牛", 11),
    WU_HUA(13, "五花牛", 11),
    TONG_HUA(14, "同花牛", 12),
    HU_LU(15, "葫芦牛", 12),
    SI_ZHA(16, "四炸牛", 15),
    WU_XIAO(17, "五小牛", 20),
    SI_SHI_DA(18, "四十大", 15),
    TONG_HUA_SHUN(19, "同花顺", 20);

    private final int id;
    private final String cnName;
    private final int defaultMultiplier;

    CardType(int id, String cnName, int defaultMultiplier) {
        this.id = id;
        this.cnName = cnName;
        this.defaultMultiplier = defaultMultiplier;
    }

    public int id() {
        return id;
    }

    public String cnName() {
        return cnName;
    }

    /** 疯狂斗牛(timesRule=3) 之外的默认倍数，实际以配置表 timesRule 为准。 */
    public int defaultMultiplier() {
        return defaultMultiplier;
    }

    public static CardType ofId(int id) {
        for (CardType t : values()) {
            if (t.id == id) {
                return t;
            }
        }
        throw new IllegalArgumentException("未知牌型 id=" + id);
    }

    /** 同牌型比较时的强度权重（数值越大越强）。 */
    public int strength() {
        return switch (this) {
            case WU_NIU -> 0;
            case NIU_1 -> 1;
            case NIU_2 -> 2;
            case NIU_3 -> 3;
            case NIU_4 -> 4;
            case NIU_5 -> 5;
            case NIU_6 -> 6;
            case NIU_7 -> 7;
            case NIU_8 -> 8;
            case NIU_9 -> 9;
            case NIU_NIU -> 10;
            case SHUN_ZI -> 11;
            case WU_HUA -> 12;
            case TONG_HUA -> 13;
            case HU_LU -> 14;
            case SI_ZHA -> 15;
            case WU_XIAO -> 16;
            case SI_SHI_DA -> 17;
            case TONG_HUA_SHUN -> 18;
            case GOLD_NIU -> 19;
        };
    }
}
