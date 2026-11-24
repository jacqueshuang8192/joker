package com.j.joker.game.rooms.infrastructure;

import com.j.joker.game.niuniu.infrastructure.DouniuAdmission;
import com.j.joker.game.rooms.application.Lobby;
import com.j.joker.game.rooms.domain.RoomAssignment;
import redis.clients.jedis.JedisPool;

public record RedisLobbyAccounts(JedisPool pool, DouniuAdmission admission) implements Lobby.Accounts {
    public String authenticate(int uid, String key) { return admission.sessionToken(uid, key); }

    public boolean invited(int uid, String token, int tid, int activity) {
        try (var redis = pool.getResource()) {
            return (token + ":" + tid).equals(redis.hget("TOKEN_" + uid, "douniuJoin:" + activity));
        }
    }

    public RoomAssignment assignment(int uid) {
        try (var redis = pool.getResource()) { return RedisRoomAssignments.read(redis, uid); }
    }

    public boolean watches(int uid, int activity) {
        try (var redis = pool.getResource()) { return redis.hexists("TOKEN_" + uid, "douniuWatch:" + activity); }
    }
}
