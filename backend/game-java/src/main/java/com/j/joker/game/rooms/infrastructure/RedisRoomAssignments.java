package com.j.joker.game.rooms.infrastructure;

import com.j.joker.game.rooms.domain.RoomAssignment;
import redis.clients.jedis.Jedis;

/** USER_GAME_STATUS 与旧服务共用，只有三个正整数才表示一张活动桌。 */
public final class RedisRoomAssignments {
    private RedisRoomAssignments() {}

    public static String encode(int level, int tid, int activity) {
        return level + "_" + tid + "_" + activity;
    }

    public static RoomAssignment read(Jedis redis, long uid) {
        String value = redis.hget("USER_GAME_STATUS", Long.toString(uid));
        if (value == null) return null;
        String[] parts = value.split("_", -1);
        if (parts.length != 3) return null;
        try {
            int level = Integer.parseInt(parts[0]);
            int tid = Integer.parseInt(parts[1]);
            int activity = Integer.parseInt(parts[2]);
            if (level <= 0 || tid <= 0 || activity <= 0 || !encode(level, tid, activity).equals(value)) return null;
            return new RoomAssignment(level, tid, activity);
        } catch (NumberFormatException invalid) {
            return null;
        }
    }
}
