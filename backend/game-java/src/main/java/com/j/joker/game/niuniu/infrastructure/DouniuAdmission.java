package com.j.joker.game.niuniu.infrastructure;

import com.j.joker.game.niuniu.application.DouniuService;
import com.j.joker.game.rooms.infrastructure.RedisRoomAssignments;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import redis.clients.jedis.JedisPool;

/** 只接受当前 API 会话派生的牛牛凭据和 alloc 分配的同一场次、牌桌。 */
public final class DouniuAdmission implements DouniuService.Admission {
    private final JedisPool pool;
    private final int level;

    public DouniuAdmission(JedisPool pool, int level) {
        this.pool = pool;
        this.level = level;
    }

    public String sessionToken(int uid, String key) {
        try (var redis = pool.getResource()) {
            return sessionToken(redis, uid, key);
        }
    }

    private static String sessionToken(redis.clients.jedis.Jedis redis, int uid, String key) {
        if (uid <= 0 || key == null || key.length() != 64) return null;
        var session = redis.hmget("TOKEN_" + uid, "token", "timestamp");
        if (session.contains(null) || Long.parseLong(session.get(1)) <= System.currentTimeMillis()) return null;
        byte[] material = ("joker/douniu/" + uid + "/" + session.getFirst()).getBytes(StandardCharsets.UTF_8);
        try {
            return MessageDigest.isEqual(MessageDigest.getInstance("SHA-256").digest(material), HexFormat.of().parseHex(key))
                    ? session.getFirst() : null;
        } catch (IllegalArgumentException malformed) {
            return null;
        } catch (NoSuchAlgorithmException impossible) {
            throw new IllegalStateException(impossible);
        }
    }

    @Override public boolean allowedAtClubTable(int club, long uid, java.util.List<Long> seated) {
        if (club <= 0) return true;
        try (var redis = pool.getResource()) {
            if ("1".equals(redis.hget("DISABLE_USER_" + club, Long.toString(uid)))) return false;
            String restriction = "CLUB_USER_JOIN_TOGETHER_LIMIT_" + club + "_" + uid;
            for (long other : seated) {
                if (other != uid && redis.sismember(restriction, Long.toString(other))) return false;
            }
            return true;
        }
    }

    @Override public DouniuService.Access access(int uid, int tid, String key, boolean watchRequested) {
        if (key == null || key.length() != 64) return null;
        try (var redis = pool.getResource()) {
            String token = sessionToken(redis, uid, key);
            if (token == null) return null;
            var assignment = RedisRoomAssignments.read(redis, uid);
            if (assignment == null || assignment.level() != level || assignment.tid() != tid) return null;
            int activity = assignment.activity();
            boolean unlocked = token.equals(redis.get("JOKER_DOUNIU_UNLOCK:" + activity + ":" + uid));
            String club = redis.hget("TOKEN_" + uid, "douniuWatch:" + activity);
            if (club == null) return watchRequested ? null : new DouniuService.Access(activity, 0, unlocked);
            int clubId = Integer.parseInt(club);
            return clubId > 0 ? new DouniuService.Access(activity, clubId, unlocked) : null;
        } catch (RuntimeException unavailable) {
            return null;
        }
    }
}
