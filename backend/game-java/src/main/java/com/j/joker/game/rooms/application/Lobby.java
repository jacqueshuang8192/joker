package com.j.joker.game.rooms.application;

import com.j.joker.game.rooms.domain.RoomRoute;
import com.j.joker.game.rooms.domain.RoomAssignment;
import java.util.concurrent.ConcurrentHashMap;

/** 大厅会话按账号唯一。旧连接迟到的关闭事件只释放它自己的会话。 */
public final class Lobby {
    public interface Connection {
        void disconnect();
        void notice(int command, byte[] payload);
    }
    public interface Accounts {
        String authenticate(int uid, String key);
        boolean invited(int uid, String token, int tid, int activity);
        RoomAssignment assignment(int uid);
        boolean watches(int uid, int activity);
    }
    public interface Tables {
        RoomRoute route(int tid);
        boolean select(int uid, int tid, int activity, boolean invited);
    }

    private final Accounts accounts;
    private final Tables tables;
    private final int level;
    private final ConcurrentHashMap<Integer, Connection> online = new ConcurrentHashMap<>();

    public Lobby(Accounts accounts, Tables tables, int level) {
        this.accounts = accounts;
        this.tables = tables;
        this.level = level;
    }

    public boolean login(int uid, String key, Connection connection) {
        if (accounts.authenticate(uid, key) == null) return false;
        Connection old = online.put(uid, connection);
        if (old != null && old != connection) old.disconnect();
        return true;
    }

    public boolean online(int uid) { return online.containsKey(uid); }
    public void deliver(int uid, java.util.function.Consumer<Connection> notification) {
        Connection target = online.get(uid);
        if (target != null) notification.accept(target);
    }
    public void logout(int uid, Connection connection) { online.remove(uid, connection); }

    public RoomRoute select(int uid, String key, int requestedLevel, int tid, int activity, Connection connection) {
        if (level != requestedLevel || online.get(uid) != connection) return null;
        String token = accounts.authenticate(uid, key);
        if (token == null) return null;
        boolean invited = accounts.invited(uid, token, tid, activity);
        return tables.select(uid, tid, activity, invited) ? tables.route(tid) : null;
    }

    public RoomRoute current(int uid) {
        var assignment = accounts.assignment(uid);
        if (assignment == null || assignment.level() != level) return null;
        var route = tables.route(assignment.tid());
        return route != null && route.activity() == assignment.activity() ? route : null;
    }

    public int mode(int uid, RoomRoute route) { return accounts.watches(uid, route.activity()) ? 0 : 1; }
}
