package com.j.joker.game.rooms.application;

import com.j.joker.game.rooms.domain.RoomDefinition;
import com.j.joker.game.rooms.domain.RoomRoute;
import java.util.function.LongSupplier;

/** 同一游戏实例内串行分配桌号。持久化成功后才向 HTTP 服务确认。 */
public final class RoomAllocation {
    public interface Rooms {
        RoomRoute route(int tid);
        RoomRoute activityRoute(int activity);
        void create(int tid, RoomDefinition request);
        void requestRemoval(int tid, int activity);
        int release(int uid, int tid);
    }

    private final int level, serverId;
    private final LongSupplier sequence;
    private final Rooms rooms;

    public RoomAllocation(int level, int serverId, LongSupplier sequence, Rooms rooms) {
        if (level < 1 || level > 32767 || serverId < 1 || serverId > 32767)
            throw new IllegalArgumentException("场次或服务编号无效");
        this.level = level;
        this.serverId = serverId;
        this.sequence = sequence;
        this.rooms = rooms;
    }

    public synchronized int create(RoomDefinition request) {
        if (request.level() != level) return -2;
        var prior = rooms.activityRoute(request.activity());
        if (prior != null) {
            boolean matches = prior.owner() == request.owner() && prior.club() == request.club()
                    && prior.invite().equals(request.invite()) && prior.rules().equals(request.rules());
            return matches ? prior.tid() : -4;
        }
        long first = sequence.getAsLong();
        for (int offset = 0; offset < 65535; offset++) {
            int tid = (serverId << 16) | (1 + Math.floorMod(first - 1 + offset, 65535));
            if (rooms.route(tid) == null) {
                rooms.create(tid, request);
                return tid;
            }
        }
        return -99;
    }

    public int dissolve(int tid) {
        var route = rooms.route(tid);
        if (route == null) return -1;
        rooms.requestRemoval(tid, route.activity());
        return 0;
    }

    public int release(int uid, int tid) { return rooms.release(uid, tid); }
}
