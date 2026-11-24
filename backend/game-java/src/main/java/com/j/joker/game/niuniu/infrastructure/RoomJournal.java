package com.j.joker.game.niuniu.infrastructure;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.j.joker.game.niuniu.application.DouniuService;
import com.j.joker.game.rooms.infrastructure.RedisRoomAssignments;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import redis.clients.jedis.JedisPool;

/** 同一场次及服务编号只有一个房间写入者；接管后旧进程不能覆盖新快照。 */
public final class RoomJournal implements com.j.joker.game.niuniu.application.RoomRepository {
    @Override public int level() { return level; }
    @Override public int serverId() { return serverId; }
    private static final ObjectMapper JSON = new ObjectMapper();
    private final JedisPool pool;
    private final String writer = UUID.randomUUID().toString();
    private final String prefix;
    private final boolean localAllocator;
    final int level;
    final int serverId;

    public RoomJournal(JedisPool pool, int level, int serverId) {
        this(pool, level, serverId, false);
    }

    public RoomJournal(JedisPool pool, int level, int serverId, boolean localAllocator) {
        this.localAllocator = localAllocator;
        this.pool = pool;
        this.serverId = serverId;
        this.level = level;
        prefix = "JOKER_DOUNIU:" + level + ":" + serverId;
        try (var redis = pool.getResource()) {
            redis.set(prefix + ":writer", writer);
        }
    }

    private void write(String operation, List<String> args) {
        var values = new ArrayList<String>(args.size() + 1);
        values.add(writer);
        values.addAll(args);
        try (var redis = pool.getResource()) {
            redis.eval("if redis.call('GET',KEYS[1]) ~= ARGV[1] then return redis.error_reply('room writer changed') end\n" + operation,
                    List.of(prefix + ":writer", prefix + ":rooms", prefix + ":ends", "USER_GAME_STATUS"), values);
        }
    }

    private static String json(Object value) {
        try { return JSON.writeValueAsString(value); }
        catch (JsonProcessingException e) { throw new IllegalStateException("牌桌状态无法编码", e); }
    }

    private <T> List<T> read(String suffix, Class<T> type) {
        try (var redis = pool.getResource()) {
            var records = new ArrayList<T>();
            for (String s : redis.hvals(prefix + suffix)) records.add(JSON.readValue(s, type));
            return records;
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("牌桌状态无法恢复", e);
        }
    }

    @Override public List<RoomState> rooms() { return read(":rooms", RoomState.class); }
    @Override public List<DouniuService.End> pendingEnds() { return read(":ends", DouniuService.End.class); }

    @Override public void save(RoomState room) {
        write("return redis.call('HSET',KEYS[2],ARGV[2],ARGV[3])", List.of(Integer.toString(room.tid()), json(room)));
    }

    @Override public void route(int tid, int activity, long uid) {
        write("return redis.call('HSET',KEYS[4],ARGV[2],ARGV[3])",
                List.of(Long.toString(uid), RedisRoomAssignments.encode(level, tid, activity)));
    }

    @Override public void leave(int tid, int activity, long uid) {
        write("""
                if redis.call('HGET',KEYS[4],ARGV[2]) == ARGV[3] then
                  return redis.call('HDEL',KEYS[4],ARGV[2])
                end
                return 0
                """, List.of(Long.toString(uid), RedisRoomAssignments.encode(level, tid, activity)));
    }

    @Override public void finish(DouniuService.End end, Set<Long> admitted) {
        var args = new ArrayList<>(List.of(Integer.toString(end.tid()), Integer.toString(end.activity()), json(end),
                RedisRoomAssignments.encode(level, end.tid(), end.activity())));
        args.add(localAllocator ? (end.requested() ? "2" : "1") : "0");
        args.add(end.tid() + "_" + end.activity() + "_" + end.rounds());
        admitted.forEach(uid -> args.add(uid.toString()));
        write("""
                if ARGV[6]=='1' then redis.call('HSET','WAIT_CLOSE_GROUP_NEW',ARGV[3],ARGV[7]) end
                for i=8,#ARGV do
                  if redis.call('HGET',KEYS[4],ARGV[i]) == ARGV[5] then redis.call('HDEL',KEYS[4],ARGV[i]) end
                end
                if ARGV[6]=='0' then redis.call('HSET',KEYS[3],ARGV[3],ARGV[4]) end
                return redis.call('HDEL',KEYS[2],ARGV[2])
                """, args);
    }

    @Override public void endSent(DouniuService.End end) {
        write("return redis.call('HDEL',KEYS[3],ARGV[2])", List.of(Integer.toString(end.activity())));
    }
}
