package com.j.joker.game.rooms.infrastructure;

import redis.clients.jedis.Jedis;
import java.util.List;

/** 与分桌共用 Redis。领取锁与检查在桌状态在同一条 Redis 命令内完成。 */
public final class GiftLock {
    private GiftLock() {}
    public static String key(int uid) { return "JOKER_GIFT_LOCK:" + uid; }
    public static boolean acquire(Jedis redis, int uid, String owner) {
        if (uid <= 0) return false;
        return Long.valueOf(1).equals(redis.eval("""
                local route = redis.call('HGET','USER_GAME_STATUS',ARGV[1])
                if route and route:match('^%d+_[1-9]%d*_[1-9]%d*$') then return 0 end
                if redis.call('SET',KEYS[1],ARGV[2],'NX','EX',60) then return 1 end
                return 0
                """,List.of(key(uid)),List.of(Integer.toString(uid),owner)));
    }
    public static void release(Jedis redis, int uid, String owner) {
        redis.eval("if redis.call('GET',KEYS[1])==ARGV[1] then return redis.call('DEL',KEYS[1]) end",
                List.of(key(uid)),List.of(owner));
    }
}
