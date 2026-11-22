package com.j.joker.core.util;

public class RedisUtil extends RedisCommands {
    private static volatile RedisUtil ru = new RedisUtil();

    private RedisUtil() {
        super(ConfigUtil.get("redis.port"));
    }

    public static RedisUtil getRu() {
        return ru;
    }

    public static void setRu(RedisUtil ru) {
        RedisUtil.ru = ru;
    }
}
