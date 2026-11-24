package com.j.joker.game.niuniu.domain.rules;

import com.j.joker.game.niuniu.domain.card.CardType;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 一桌牛牛的完整配置。
 *
 * <p>前半部分来自服务端下发给客户端的 gameConfig JSON（日志实例）：
 * <pre>
 * {"additionalPoint":0,"baseChip":1,"cardCount":4,"gaoji":"4,7,5","hasLeper":0,"id":6,
 *  "joinGamePoint":5000,"master":100010,"maxSeatCount":6,"name":"牛牛0","oneOrAll":2,
 *  "profit":0,"profitLimit":5000,"profitType":0,"rateOrConstant":1,"readyPoint":2000,
 *  "round":10,"secConstant":"","showCardNums":4,"speType":"6,4,3,8,5,2,1",
 *  "subGameType":1,"tgTime":0,"tuizhu":5}
 * </pre>
 * 后半部分来自 DB 表 bullfight_gameconfig_table / bullfight_gameconfig_coecardtype /
 * bullfight_gameconfig_prob，键名见旧数据库配置。
 */
public final class GameConfig {

    /** 玩法：1 明牌抢庄, 2 定庄斗牛, 3 轮庄斗牛, 4 牛牛坐庄, 5 斗公牛。 */
    public enum SubGameType {
        MING_PAI_GRAB(1, "明牌抢庄"),
        FIXED_BANKER(2, "定庄斗牛"),
        ROTATE_BANKER(3, "轮庄斗牛"),
        NIU_NIU_BANKER(4, "牛牛坐庄"),
        GONG_NIU(5, "斗公牛");

        public final int code;
        public final String cn;

        SubGameType(int code, String cn) {
            this.code = code;
            this.cn = cn;
        }

        public static SubGameType of(int code) {
            for (SubGameType t : values()) {
                if (t.code == code) {
                    return t;
                }
            }
            return MING_PAI_GRAB;
        }
    }

    private int id;
    private String name = "牛牛";
    private int baseChip = 1;
    private int guodi = 50;
    private int maxSeatCount = 6;
    private int readyPoint = 2000;
    private int joinGamePoint = 5000;
    private int round = 10;
    private int showCardNums = 4;
    private int cardCount = 5;
    private int[] times = {1, 2, 3, 4, 5};
    private int timesRule = 0;
    private SubGameType subGameType = SubGameType.MING_PAI_GRAB;
    private final Set<Integer> speType = new LinkedHashSet<>(Set.of(1, 2, 3, 4, 5, 6, 7));
    private final Set<Integer> gaoji = new LinkedHashSet<>();
    private boolean passwordRequired;
    private boolean leperEnabled;
    private boolean noFlowerNiu;
    private boolean waiweiEnabled;
    private int tuizhu = 5;
    private int dissolveMode = 1;
    private List<Integer> grabOptions = List.of(1, 2, 3, 4);
    private boolean doubleBet;
    private int grabDealerChips;
    private int profit;
    private int profitLimit = 5000;
    private int profitType;
    private int oneOrAll = 2;
    private int rateOrConstant = 1;
    private int additionalPoint;
    private int tgTime;
    private int pointMode;
    private int firstBetLimit;
    private int afterBetLimit;
    private int[] waiweiBetChips = {10, 50, 100};
    private String secConstant = "";

    // ---- DB 配置（bullfight_gameconfig_table） ----
    private double commissionRate = 0.05;
    private int costPattern = 1;
    private int bankruptMoney = 0;
    private int minRequireChips = 1000;
    private int maxRequireChips = 1000000;
    private int minMaxTimesValue = 1;
    private int maxMaxTimesValue = 5;
    private int callTimeCOE = 1;
    private int enableGrabCOE;
    private int settleAnimationTime = 3000;
    private int delayStopTime = 0;
    private int changeCardAndTimesTime = 5000;
    private int moneyOfChangeRoom;
    private int payLevel;
    private int roomType = 1;
    private int randomType;
    private boolean random;
    private double robotSmartRate = 0.5;
    private int thresholdTimes4Robots = 10;
    private int thresholdRound = 10;
    private int newUserGameNum;
    private int points;
    private int pointsTimes;
    private int pointsType;
    private int swinTimes = 1;
    private int scardType = 1;
    private int propTimes;
    private int niu7 = 1;
    private int niu8 = 2;
    private int niu9 = 2;
    private int niu10 = 3;
    private int forDecimal = 1;
    private boolean pointDValue;
    private boolean hasJQK = true;
    private int[] specialTimes = {5, 5, 6, 6, 7, 8, 7, 20};
    private int propChangeCardPointCost;
    private int propChangeTimesPointCost;
    private int propReminderCost;
    private int propKissCost;
    private int propFlowerCost;
    private int propEggCost;
    private int propBoombCost;
    private int fromKissCharm;
    private int fromFlowerCharm;
    private int fromEggCharm;
    private int fromBoombCharm;
    private int toKissCharm;
    private int toFlowerCharm;
    private int toEggCharm;
    private int toBoombCharm;

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private final GameConfig c = new GameConfig();

        public Builder id(int v) { c.id = v; return this; }
        public Builder name(String v) { c.name = v; return this; }
        public Builder baseChip(int v) { c.baseChip = v; return this; }
        public Builder guodi(int v) { c.guodi = v; return this; }
        public Builder maxSeatCount(int v) { c.maxSeatCount = v; return this; }
        public Builder readyPoint(int v) { c.readyPoint = v; return this; }
        public Builder joinGamePoint(int v) { c.joinGamePoint = v; return this; }
        public Builder round(int v) { c.round = v; return this; }
        public Builder showCardNums(int v) { c.showCardNums = v; return this; }
        public Builder cardCount(int v) { c.cardCount = v; return this; }
        public Builder times(int... v) { c.times = v; return this; }
        public Builder timesRule(int v) { c.timesRule = v; return this; }
        public Builder subGameType(int v) { c.subGameType = SubGameType.of(v); return this; }
        public Builder speType(String csv) {
            c.speType.clear();
            for (String part : csv.split(",")) {
                if (!part.isBlank()) {
                    c.speType.add(Integer.parseInt(part.trim()));
                }
            }
            return this;
        }
        public Builder gaoji(String csv) {
            c.gaoji.clear();
            for (String part : csv.split(",")) {
                if (!part.isBlank()) {
                    c.gaoji.add(Integer.parseInt(part.trim()));
                }
            }
            return this;
        }
        public Builder leper(boolean v) { c.leperEnabled = v; return this; }
        public Builder noFlowerNiu(boolean v) { c.noFlowerNiu = v; return this; }
        public Builder waiwei(boolean v) { c.waiweiEnabled = v; return this; }
        public Builder commissionRate(double v) { c.commissionRate = v; return this; }
        public Builder pointMode(int v) { c.pointMode = v; return this; }
        public Builder pointDValue(boolean v) { c.pointDValue = v; return this; }
        public Builder hasJQK(boolean v) { c.hasJQK = v; return this; }
        public Builder forDecimal(int v) { c.forDecimal = v; return this; }
        public Builder niuTimes(int n7, int n8, int n9, int n10) {
            c.niu7 = n7; c.niu8 = n8; c.niu9 = n9; c.niu10 = n10; return this;
        }
        public Builder tuizhu(int v) { c.tuizhu = v; return this; }
        public GameConfig build() { return c; }
    }

    /** 解析日志中出现的 gameConfig JSON。 */
    public static GameConfig fromJson(String json) {
        return fromMap(com.j.joker.game.niuniu.util.Json.parseObject(json));
    }

    public static GameConfig fromMap(Map<String, Object> m) {
        Builder b = builder();
        b.id(i(m, "id", 0));
        b.c.passwordRequired = i(m, "douniuPasswordRequired", 0) == 1;
        b.name(s(m, "name", "牛牛"));
        b.baseChip(positiveMultiplier(m, "baseChip", 1));
        b.maxSeatCount(i(m, "maxSeatCount", 6));
        b.readyPoint(i(m, "readyPoint", 2000));
        b.joinGamePoint(i(m, "joinGamePoint", 5000));
        b.round(i(m, "round", 10));
        b.showCardNums(i(m, "showCardNums", 4));
        b.cardCount(i(m, "cardCount", 4));
        b.subGameType(i(m, "subGameType", 1));
        b.tuizhu(i(m, "tuizhu", 5));
        b.c.dissolveMode = i(m, "dis_agree", 1);
        b.c.doubleBet = i(m, "isDouble", 0) != 0;
        b.c.grabDealerChips = Math.max(0, i(m, "grabDealerChips", 0));
        if (m.get("grabTimes") instanceof Number limit && limit.longValue() > 0) {
            if (limit.longValue() > Byte.MAX_VALUE) throw new IllegalArgumentException("抢庄档位超出协议范围");
            b.c.grabOptions = java.util.stream.IntStream.rangeClosed(1, limit.intValue()).boxed().toList();
        } else if (m.get("grabTimes") instanceof String options && !options.isBlank()) {
            b.c.grabOptions = java.util.Arrays.stream(options.split(","))
                    .map(String::trim).map(Integer::parseInt).filter(n -> n > 0 && n <= 127)
                    .sorted().distinct().toList();
            if (b.c.grabOptions.isEmpty()) throw new IllegalArgumentException("抢庄倍数无效");
        }
        b.niuTimes(positiveMultiplier(m, "niu7", b.c.niu7), positiveMultiplier(m, "niu8", b.c.niu8),
                positiveMultiplier(m, "niu9", b.c.niu9), positiveMultiplier(m, "niu10", b.c.niu10));
        b.timesRule(i(m, "timesRule", 0));
        b.pointMode(i(m, "pointMode", 0));
        b.forDecimal(positiveMultiplier(m, "forDecimal", 1));
        if (i(m, "guodi", 0) > 0) {
            b.guodi(i(m, "guodi", 0));
        }
        b.leper(i(m, "hasLeper", 0) == 1);
        if (m.get("speType") instanceof String sp) {
            b.speType(sp);
        }
        if (m.get("gaoji") instanceof String gj) {
            b.gaoji(gj);
        }
        if (m.get("times") instanceof String t) {
            String[] parts = t.split(",");
            int[] arr = new int[parts.length];
            for (int k = 0; k < parts.length; k++) {
                arr[k] = Integer.parseInt(parts[k].trim());
            }
            b.times(arr);
        }
        if (m.get("waiwei") instanceof String w && w.contains("1")) {
            b.waiwei(true);
        }
        if (m.get("gaoji") instanceof String) {
            b.pointDValue(b.c.gaoji.contains(7));   // gaoji 含 7 = 点差
            b.hasJQK(!b.c.gaoji.contains(6));       // gaoji 含 6 = 无 JQK
        }
        if (b.c.times.length == 0 || b.c.times.length > 125 || java.util.Arrays.stream(b.c.times)
                .anyMatch(n -> n < 1 || n > Integer.MAX_VALUE / 2)) throw new IllegalArgumentException("下注倍数无效");
        return b.build();
    }

    private static int positiveMultiplier(Map<String,Object> settings, String key, int fallback) {
        Object value = settings.get(key);
        if (value == null) return fallback;
        int times = Integer.parseInt(value.toString());
        if (times < 1) throw new IllegalArgumentException(key + " 必须为正整数");
        return times;
    }

    private static int i(Map<String, Object> m, String k, int def) {
        Object v = m.get(k);
        return v instanceof Number n ? n.intValue() : def;
    }

    private static String s(Map<String, Object> m, String k, String def) {
        Object v = m.get(k);
        return v == null ? def : String.valueOf(v);
    }

    public boolean isSpeTypeEnabled(int bit) {
        return speType.contains(bit);
    }

    public boolean isNoFlowerNiu() {
        return noFlowerNiu;
    }

    public boolean passwordRequired() { return passwordRequired; }

    public boolean isLeperEnabled() {
        return leperEnabled;
    }

    /**
     * 牌型倍数表 CT[type-1]，对应 CGameTable::InitTable 的 coeCardType：
     * CT[7..10] = niu7/niu8/niu9/niu10（牛七~牛牛），CT[11..18] = 顺子~同花顺。
     */
    public int cardTypeTimes(CardType type) {
        return cardTypeTimes(type.id());
    }

    /** 按牌型编号取倍数（CT[type-1]）。 */
    public int cardTypeTimes(int id) {
        if (id < 1 || id > 19) {
            return 1;
        }
        return buildCardTypeTable()[id - 1];
    }

    private int[] buildCardTypeTable() {
        int[] ct = new int[19];
        for (int i = 0; i < 7; i++) {
            ct[i] = 1; // 无牛..牛六
        }
        ct[7] = niu7;
        ct[8] = niu8;
        ct[9] = niu9;
        ct[10] = niu10;
        for (int i = 0; i < specialTimes.length && 11 + i < ct.length; i++) {
            ct[11 + i] = specialTimes[i];
        }
        if (timesRule == 3) { // 疯狂斗牛：2..11 改为 1..10，顺子/五花 11，同花/葫芦 12，四炸 15，五小 20，四十大仍 7
            for (int id = 2; id <= 11; id++) {
                ct[id - 1] = id - 1;
            }
            ct[11] = 11;
            ct[12] = 11;
            ct[13] = 12;
            ct[14] = 12;
            ct[15] = 15;
            ct[16] = 20;
            ct[17] = 7;
        } else if (timesRule == 1) {
            ct[7] = 1;
            ct[8] = 2;
            ct[9] = 2;
            ct[10] = 3;
        } else if (timesRule == 2) {
            ct[7] = 2;
            ct[8] = 2;
            ct[9] = 3;
            ct[10] = 4;
        } else if (timesRule == 4) {
            ct[7] = 2;
            ct[8] = 3;
            ct[9] = 4;
            ct[10] = 5;
        }
        return ct;
    }

    /** 比牌时 "无 JQK" 变体把四炸按 19 处理。 */
    public boolean hasJQK() {
        return hasJQK;
    }

    /** 点差模式（gaoji 含 7）：按两家牌型倍数差赔付。 */
    public boolean pointDValue() {
        return pointDValue;
    }

    /** 金币单位放大：UNIT = baseChip × 10 × forDecimal。 */
    public int forDecimal() {
        return forDecimal;
    }

    public int dissolveMode() { return dissolveMode; }
    public int grabDealerChips() { return grabDealerChips; }
    public boolean doubleBet() { return doubleBet; }
    public List<Integer> grabOptions() { return grabOptions; }

    public int[] betOptions() {
        return times.clone();
    }

    public List<Integer> betOptionList() {
        List<Integer> list = new ArrayList<>(times.length);
        for (int t : times) {
            list.add(t);
        }
        return list;
    }

    public int clampBetTimes(int requested) {
        int best = times[0];
        for (int t : times) {
            if (Math.abs(t - requested) < Math.abs(best - requested)) {
                best = t;
            }
        }
        return best;
    }

    // ---- getters/setters ----
    public int id() { return id; }
    public String name() { return name; }
    public int baseChip() { return baseChip; }
    public int guodi() { return guodi; }
    public void setGuodi(int v) { guodi = v; }
    public int maxSeatCount() { return maxSeatCount; }
    public int readyPoint() { return readyPoint; }
    public int joinGamePoint() { return joinGamePoint; }
    public int round() { return round; }
    public int showCardNums() { return showCardNums; }
    /**
     * 手牌张数固定 5（牛牛规则）；配置里的 cardCount 实际是“明牌张数”，
     * 对应 showCardNums，不是手牌数量。
     */
    public int handSize() { return 5; }

    /** 配置里的明牌张数（日志实例 cardCount=4）。 */
    public int cardCount() { return cardCount; }
    public int[] times() { return times.clone(); }
    public int timesRule() { return timesRule; }
    public void setTimesRule(int v) { timesRule = v; }
    public SubGameType subGameType() { return subGameType; }
    public Set<Integer> speTypes() { return Set.copyOf(speType); }
    public Set<Integer> gaoji() { return Set.copyOf(gaoji); }
    public boolean waiweiEnabled() { return waiweiEnabled; }
    public int tuizhu() { return tuizhu; }
    public int profit() { return profit; }
    public int profitLimit() { return profitLimit; }
    public int profitType() { return profitType; }
    public int oneOrAll() { return oneOrAll; }
    public int rateOrConstant() { return rateOrConstant; }
    public int additionalPoint() { return additionalPoint; }
    public int tgTime() { return tgTime; }
    public int pointMode() { return pointMode; }
    /** 外围首注下限百分比：floor(guodi * firstBetLimit / 100)。 */
    public int firstBetLimit() { return firstBetLimit; }
    /** 外围续注下限百分比。 */
    public int afterBetLimit() { return afterBetLimit; }
    public int[] waiweiBetChips() { return waiweiBetChips.clone(); }
    public String secConstant() { return secConstant; }
    public double commissionRate() { return commissionRate; }
    public int costPattern() { return costPattern; }
    public int bankruptMoney() { return bankruptMoney; }
    public int minRequireChips() { return minRequireChips; }
    public int maxRequireChips() { return maxRequireChips; }
    public int settleAnimationTime() { return settleAnimationTime; }
    public int delayStopTime() { return delayStopTime; }
    public int changeCardAndTimesTime() { return changeCardAndTimesTime; }
    public int roomType() { return roomType; }
    public int randomType() { return randomType; }
    public boolean random() { return random; }
    public double robotSmartRate() { return robotSmartRate; }
    public int thresholdTimes4Robots() { return thresholdTimes4Robots; }
    public int thresholdRound() { return thresholdRound; }
    public int swinTimes() { return swinTimes; }
    public int scardType() { return scardType; }
    public int propTimes() { return propTimes; }
    public int payLevel() { return payLevel; }
}
