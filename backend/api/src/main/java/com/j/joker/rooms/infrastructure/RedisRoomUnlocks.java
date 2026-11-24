package com.j.joker.rooms.infrastructure;

import com.j.joker.rooms.application.RoomUnlocks;
import org.springframework.stereotype.Component;
import redis.clients.jedis.JedisPool;
import java.util.List;

@Component
public record RedisRoomUnlocks(JedisPool pool) implements RoomUnlocks {
    private static final String CHECK = """
            if redis.call('HGET',KEYS[1],'token') ~= ARGV[2] then return 0 end
            local route = redis.call('HGET',KEYS[2],ARGV[1])
            if not route or not string.match(route,'^302_%d+_' .. ARGV[3] .. '$') then return 0 end
            """;
    private long run(long uid, String token, long activity, String action) {
        var suffix = activity + ":" + uid;
        try (var cache = pool.getResource()) {
            return (long)cache.eval(CHECK + action, List.of("TOKEN_" + uid,"USER_GAME_STATUS",
                    "JOKER_DOUNIU_PIN_TRY:" + suffix, "JOKER_DOUNIU_UNLOCK:" + suffix),
                    List.of(Long.toString(uid),token,Long.toString(activity)));
        }
    }
    public long attempt(long uid, String token, long activity) {
        return run(uid, token, activity, """
                local n = redis.call('INCR',KEYS[3])
                if n == 1 then redis.call('EXPIRE',KEYS[3],60) end
                return n
                """);
    }
    public boolean grant(long uid, String token, long activity) {
        return run(uid, token, activity, """
                redis.call('SETEX',KEYS[4],86400,ARGV[2])
                redis.call('DEL',KEYS[3])
                return 1
                """)==1;
    }
}
