package com.j.joker.core.util;

public class RedisUtil1 extends RedisCommands {
    private static volatile RedisUtil1 ru = new RedisUtil1();

    private RedisUtil1() {
        super(invitationPort());
    }

    private static String invitationPort() {
        String port = ConfigUtil.get("redis.port1");
        return StringUtil.isEmpty(port) ? "4501" : port;
    }

    public static RedisUtil1 getRu() {
        return ru;
    }

    public static void setRu(RedisUtil1 ru) {
        RedisUtil1.ru = ru;
    }
}
