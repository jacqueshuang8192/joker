package com.j.joker.game.rooms.infrastructure;

import com.j.joker.game.niuniu.infrastructure.DouniuAdmission;
import com.j.joker.game.rooms.application.Lobby;
import com.j.joker.game.rooms.domain.RoomAssignment;
import redis.clients.jedis.JedisPool;

public record RedisLobbyAccounts(JedisPool pool, DouniuAdmission admission) implements Lobby.Accounts {
    public String authenticate(int uid, String key) { return admission.sessionToken(uid, key); }

    private static final java.net.http.HttpClient API = java.net.http.HttpClient.newBuilder()
            .connectTimeout(java.time.Duration.ofSeconds(2)).build();

    @Override public boolean requestInvitation(int uid,String token,com.j.joker.game.rooms.domain.RoomRoute route) {
        // 快速入桌复用大厅 HTTP 校验（联盟积分、预警分和 AA 房卡），取得同一张入房凭据。
        var utf8=java.nio.charset.StandardCharsets.UTF_8;
        String form="type=P&level=302&isWatch=1&XYUid="+uid+"&XYToken="+java.net.URLEncoder.encode(token,utf8)
                +"&activityId="+route.activity()+"&invitationCode="+java.net.URLEncoder.encode(route.invite(),utf8);
        var request=java.net.http.HttpRequest.newBuilder(java.net.URI.create("http://127.0.0.1:8080/hbiInterface/joinFreeGame"))
                .timeout(java.time.Duration.ofSeconds(3)).header("Content-Type","application/x-www-form-urlencoded")
                .POST(java.net.http.HttpRequest.BodyPublishers.ofString(form)).build();
        try {
            var result=API.send(request,java.net.http.HttpResponse.BodyHandlers.ofString());
            return result.statusCode()==200 && "0".equals(com.j.joker.game.niuniu.util.Json.parseObject(result.body()).get("returnCode"));
        } catch (InterruptedException interrupted) {
            Thread.currentThread().interrupt();
            return false;
        } catch (java.io.IOException | IllegalArgumentException unavailable) { return false; }
    }

    public boolean invited(int uid, String token, int tid, int activity) {
        try (var redis = pool.getResource()) {
            return (token + ":" + tid).equals(redis.hget("TOKEN_" + uid, "douniuJoin:" + activity));
        }
    }

    public RoomAssignment assignment(int uid) {
        try (var redis = pool.getResource()) { return RedisRoomAssignments.read(redis, uid); }
    }

    @Override public void peer(int uid, String ip) {
        try (var redis = pool.getResource()) {
            redis.hset("TOKEN_" + uid, java.util.Map.of("hallPeer", ip, "hallLatitude", "", "hallLongitude", ""));
        }
    }

    @Override public void location(int uid,double latitude,double longitude) {
        try (var redis=pool.getResource()) {
            redis.hset("TOKEN_" + uid, java.util.Map.of("hallLatitude", Double.toString(latitude), "hallLongitude", Double.toString(longitude)));
            redis.hset("PLAYER_"+uid,java.util.Map.of("latitude",Double.toString(latitude),"longitude",Double.toString(longitude)));
        }
    }

    public boolean watches(int uid, int activity) {
        try (var redis = pool.getResource()) { return redis.hexists("TOKEN_" + uid, "douniuWatch:" + activity); }
    }
}
