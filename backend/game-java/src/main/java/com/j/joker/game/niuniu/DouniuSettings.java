package com.j.joker.game.niuniu;

import com.j.joker.game.niuniu.domain.rules.GameConfig;
import org.springframework.core.env.Environment;

/**
 * 牛牛角色配置。
 *
 * <p>与 C++ 版 {@code Douniu/bin/server.xml} 的 SYSTEM/ROOM 对应，但复用 game-java 的环境变量约定：
 * <pre>
 *   DOUNIU_PORT          监听端口，默认 13600（与 gateway 的 /ws/douniu 路由一致）
 *   DOUNIU_GAME_CONFIG   房间配置 JSON（就是 SVR_LOGIN_ROOM 下发的 gameConfig），缺省用线上日志实例
 *   DOUNIU_GUODI         锅底，默认 50
 *   DOUNIU_DATA_ENABLED  是否把登录/结算接到 data 角色，默认 1；本地测试设 0
 *   DATA_HOST / DATA_PORT data 角色地址，默认 data:6001
 * </pre>
 */
public final class DouniuSettings {

    /** 线上日志 2026-06-01 抓到的真实房间配置。 */
    public static final String DEFAULT_GAME_CONFIG = """
            {"additionalPoint":0,"baseChip":1,"cardCount":4,"gaoji":"4,7,5","hasLeper":0,"id":6,
             "joinGamePoint":5000,"master":100010,"maxSeatCount":6,"name":"牛牛0","oneOrAll":2,
             "profit":0,"profitLimit":5000,"profitType":0,"rateOrConstant":1,"readyPoint":2000,
             "round":10,"secConstant":"","showCardNums":4,"speType":"6,4,3,8,5,2,1",
             "subGameType":1,"tgTime":0,"tuizhu":5}""";

    private DouniuSettings() {
    }

    public static GameConfig config(Environment env) {
        String json = env.getProperty("DOUNIU_GAME_CONFIG", DEFAULT_GAME_CONFIG);
        GameConfig cfg = GameConfig.fromJson(json);
        cfg.setGuodi(env.getProperty("DOUNIU_GUODI", Integer.class, 50));
        return cfg;
    }

    public static int port(Environment env) {
        return env.getProperty("DOUNIU_PORT", Integer.class, 13600);
    }

    public static boolean dataEnabled(Environment env) {
        return env.getProperty("DOUNIU_DATA_ENABLED", Integer.class, 1) != 0;
    }
}
