package com.j.joker.game.rooms.application;

import com.j.joker.game.rooms.domain.RoomRoute;
import com.j.joker.game.rooms.domain.RoomAssignment;
import java.util.concurrent.ConcurrentHashMap;

/** 大厅会话按账号唯一。旧连接迟到的关闭事件只释放它自己的会话。 */
public final class Lobby {
    public interface Connection {
        default void membershipChanged(int club) {}
        void disconnect();
        void notice(int command, byte[] payload);
    }
    public interface Accounts {
        String authenticate(int uid, String key);
        default void peer(int uid, String ip) {}
        default void location(int uid,double latitude,double longitude) {}
        default boolean requestInvitation(int uid,String token,RoomRoute route) { return false; }
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

    public void peer(int uid, String ip, Connection connection) {
        if (online.get(uid) == connection) accounts.peer(uid, ip);
    }

    public boolean requestInvitation(int uid,String key,Connection connection,RoomRoute route) {
        if (route==null || online.get(uid)!=connection) return false;
        String token=accounts.authenticate(uid,key);
        return token!=null && accounts.requestInvitation(uid,token,route) && accounts.invited(uid,token,route.tid(),route.activity());
    }

    public void location(int uid,String key,Connection connection,String latitude,String longitude) {
        if (!currentSession(uid,key,connection)) return;
        try {
            double lat=Double.parseDouble(latitude), lon=Double.parseDouble(longitude);
            if (Math.abs(lat)<=90 && Math.abs(lon)<=180) {
                accounts.location(uid,lat,lon);
                return;
            }
        } catch (NumberFormatException invalid) {
            // 老客户端定位失败时可能上报空串。
        }
        accounts.location(uid,0,0);
    }

    public boolean currentSession(int uid,String key,Connection connection) {
        return online.get(uid)==connection && accounts.authenticate(uid,key)!=null;
    }

    public void membershipChanged(int club,int uid,int action) {
        if (action==1) online.values().forEach(c -> c.membershipChanged(club));
        else deliver(uid,c -> c.membershipChanged(club));
    }

    public boolean online(int uid) { return online.containsKey(uid); }
    public void deliver(int uid, java.util.function.Consumer<Connection> notification) {
        Connection target = online.get(uid);
        if (target != null) notification.accept(target);
    }
    public void logout(int uid, Connection connection) { online.remove(uid, connection); }

    public boolean canCheckSeat(int uid, String key, int tid, int activity, Connection connection) {
        if (online.get(uid) != connection) return false;
        String token = accounts.authenticate(uid,key);
        var route = tables.route(tid);
        return token != null && route != null && route.activity() == activity
                && (uid == route.owner() || accounts.invited(uid, token, tid, activity) || route.equals(current(uid)));
    }

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
