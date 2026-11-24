package com.j.joker.game.niuniu.config;

import com.j.joker.game.niuniu.domain.rules.GameConfig;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 服务端 DB 配置键。
 *
 * <p>这些键来自二进制中的 ReadConmmonConf / GetIntValue 调用点，以及线上日志
 * （{@code bullfight_gameconfig_table}、{@code bullfight_gameconfig_coecardtype}、
 * {@code bullfight_gameconfig_prob}）。这里给出 Java 侧的默认值，缺表时按默认值运行。
 */
public final class ConfigKeys {

    private ConfigKeys() {
    }

    public static final String TABLE_MAIN = "bullfight_gameconfig_table";
    public static final String TABLE_COE_CARD_TYPE = "bullfight_gameconfig_coecardtype";
    public static final String TABLE_PROB = "bullfight_gameconfig_prob";

    /** 主配置表默认值。 */
    public static Map<String, Object> mainDefaults() {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("BaseChip", 1);
        m.put("CallTimeCOE", 1);
        m.put("EnableGrabCOE", 0);
        m.put("SettleAnimationTime", 5000);
        m.put("DelayStopTime", 3000);
        m.put("ChangeCardAndTimesTime", 5000);
        m.put("RoomType", 1);
        m.put("RandomType", 0);
        m.put("isRandom", 0);
        m.put("commission_rate", 30); // 读入 GameConfig.costPercent，默认 30；牛牛主结算不消费
        m.put("cost_pattern", 1);
        m.put("profit", 0);
        m.put("profitLimit", 5000);
        m.put("profitType", 0);
        m.put("BankruptMoney", 0);
        m.put("MinRequireChips", 1000);
        m.put("MaxRequireChips", 1000000);
        m.put("MinMaxTimesValue", 1);
        m.put("MaxMaxTimesValue", 5);
        m.put("MoneyOfChangeRoom", 0);
        m.put("NewUserGameNum", 0);
        m.put("PayLevel", 0);
        m.put("Points", 0);
        m.put("PointsTimes", 0);
        m.put("PointsType", 0);
        m.put("SWinTimes", 1);
        m.put("SCardType", 1);
        m.put("PropTimes", 0);
        m.put("PropReminderCost", 0);
        m.put("PropKissCost", 0);
        m.put("PropFlowerCost", 0);
        m.put("PropEggCost", 0);
        m.put("PropBoombCost", 0);
        m.put("PropChangeCardPointCost", 0);
        m.put("PropChangeTimesPointCost", 0);
        m.put("FromKissCharm", 0);
        m.put("FromFlowerCharm", 0);
        m.put("FromEggCharm", 0);
        m.put("FromBoombCharm", 0);
        m.put("ToKissCharm", 0);
        m.put("ToFlowerCharm", 0);
        m.put("ToEggCharm", 0);
        m.put("ToBoombCharm", 0);
        m.put("robotSmartRate", 50);
        m.put("thresholdTimes4Robots", 10);
        m.put("thresholdRound", 10);
        return m;
    }

    /** 配牌权重表（决定控牌时各牌型出现概率），键为牌型 id。 */
    public static Map<String, Object> coeCardTypeDefaults() {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("TypeWuNiu", 20);
        for (int i = 1; i <= 9; i++) {
            m.put("TypeNiu" + i, 8);
        }
        m.put("TypeNiuNiu", 2);
        return m;
    }

    /** 控牌概率表，键为牌型分组。 */
    public static Map<String, Object> probDefaults() {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("P_WUNIU", 0.20);
        m.put("P_DOUNIU1_2", 0.30);
        m.put("P_DOUNIU3_4", 0.25);
        m.put("P_DOUNIU5_6", 0.15);
        m.put("P_DOUNIU7_9", 0.10);
        m.put("P_DOUBLEBULL", 0.0);
        m.put("P_SIZHA", 0.0);
        m.put("P_WUHUANIU", 0.0);
        m.put("P_WUXIAONIU", 0.0);
        return m;
    }
}
