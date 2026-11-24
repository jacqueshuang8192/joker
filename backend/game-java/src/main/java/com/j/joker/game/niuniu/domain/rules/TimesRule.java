package com.j.joker.game.niuniu.domain.rules;

import com.j.joker.game.niuniu.domain.card.CardType;

/**
 * 牌型倍数规则，对应配置 {@code timesRule}。
 *
 * <p>数值来自客户端 NiuNiuReceiveHandle.lua 的 NIUNIU_CARDTYPE_TABLE
 * （下标 1=无牛, 2=牛一 … 10=牛九, 11=牛牛）：
 * <pre>
 *  timesRule=0(默认)  无牛~牛七=1, 牛八=2, 牛九=2, 牛牛=3,
 *                     顺子/五花=5, 同花/葫芦=6, 四炸/四十大=7, 五小牛=8
 *  timesRule=1        id 8(牛七)=1, 9(牛八)=2, 10(牛九)=2, 11(牛牛)=3
 *  timesRule=2        id 8=2, 9=2, 10=3, 11=4
 *  timesRule=3 疯狂   牛一=1 … 牛九=8, 牛牛=10, 顺子/五花=11, 同花/葫芦=12, 四炸=15, 五小牛=20
 *  timesRule=4        id 8=2, 9=3, 10=4, 11=5
 * </pre>
 */
public enum TimesRule {
    STANDARD(0),
    RULE_1(1),
    RULE_2(2),
    CRAZY(3),
    RULE_4(4);

    private final int code;

    TimesRule(int code) {
        this.code = code;
    }

    public int code() {
        return code;
    }

    public static TimesRule of(int code) {
        for (TimesRule r : values()) {
            if (r.code == code) {
                return r;
            }
        }
        return STANDARD;
    }

    public int multiplier(CardType type) {
        int id = type.id();
        if (type == CardType.GOLD_NIU) {
            return 1;
        }
        if (this == CRAZY) {
            if (id >= 2 && id <= 11) {
                return id - 1; // 牛一=1 … 牛牛=10
            }
            return switch (type) {
                case SHUN_ZI, WU_HUA -> 11;
                case TONG_HUA, HU_LU -> 12;
                case SI_ZHA -> 15;
                case SI_SHI_DA -> 7; // 疯狂斗牛未覆盖四十大，仍是 7
                case WU_XIAO, TONG_HUA_SHUN -> 20;
                default -> 1;
            };
        }
        int n = switch (type) {
            case NIU_7 -> 8;
            case NIU_8 -> 9;
            case NIU_9 -> 10;
            case NIU_NIU -> 11;
            default -> -1;
        };
        if (n > 0) {
            return switch (this) {
                case RULE_1 -> switch (n) {
                    case 8 -> 1;
                    case 9, 10 -> 2;
                    default -> 3; // 牛牛
                };
                case RULE_2 -> switch (n) {
                    case 8, 9 -> 2;
                    case 10 -> 3;
                    default -> 4; // 牛牛
                };
                case RULE_4 -> switch (n) {
                    case 8 -> 2;
                    case 9 -> 3;
                    case 10 -> 4;
                    default -> 5; // 牛牛
                };
                default -> switch (n) {
                    case 9, 10 -> 2;   // 牛八、牛九
                    default -> n == 11 ? 3 : 1; // 牛牛
                };
            };
        }
        return switch (type) {
            case WU_NIU, NIU_1, NIU_2, NIU_3, NIU_4, NIU_5, NIU_6 -> 1;
            case SHUN_ZI, WU_HUA -> 5;
            case TONG_HUA, HU_LU -> 6;
            case SI_ZHA, SI_SHI_DA -> 7;
            case WU_XIAO -> 8;
            case TONG_HUA_SHUN -> 10;
            default -> 1;
        };
    }
}
