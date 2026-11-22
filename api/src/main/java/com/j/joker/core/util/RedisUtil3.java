package com.j.joker.core.util;

public class RedisUtil3 extends RedisCommands {
    private static volatile RedisUtil3 ru = new RedisUtil3();

    private RedisUtil3() {
        super(ConfigUtil.get("redis.port3"));
    }

    public String rename(String oldKey, String newKey) {
        return execute(jedis -> jedis.exists(oldKey) ? jedis.rename(oldKey, newKey) : null, null);
    }

    public static RedisUtil3 getRu() {
        return ru;
    }

    public static void setRu(RedisUtil3 ru) {
        RedisUtil3.ru = ru;
    }
}
