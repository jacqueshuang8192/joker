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

    private Object write(String operation, List<String> args) {
        var values = new ArrayList<String>(args.size() + 1);
        values.add(writer);
        values.addAll(args);
        try (var redis = pool.getResource()) {
            return redis.eval("if redis.call('GET',KEYS[1]) ~= ARGV[1] then return redis.error_reply('room writer changed') end\n" + operation,
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

    @Override public boolean robotRoom() { return localAllocator; }

    @Override public boolean claimRobot(int club,int uid,int tid,int activity) {
        String route = RedisRoomAssignments.encode(level,tid,activity);
        return Long.valueOf(1).equals(write("""
                local uid=ARGV[2]
                if redis.call('HGET','ROBOT_STATUS',uid)~=ARGV[4] or
                   redis.call('HGET','TEMP_ROBOT_STATUS',uid)~='0_0' or
                   redis.call('HEXISTS','JOKER_ROBOT_TABLE',uid)==1 or
                   redis.call('EXISTS','JOKER_GIFT_LOCK:'..uid)==1 then return 0 end
                local old=redis.call('HGET',KEYS[4],uid)
                if old and old:match('^%d+_[1-9]%d*_[1-9]%d*$') then return 0 end
                redis.call('HSET','JOKER_ROBOT_TABLE',uid,ARGV[3])
                redis.call('HSET','TEMP_ROBOT_STATUS',uid,ARGV[5])
                redis.call('HSET',KEYS[4],uid,ARGV[3])
                return 1
                """, List.of(Integer.toString(uid),route,"0_"+club+"_1_"+level,level+"_1")));
    }

    @Override public boolean ownsActiveRobot(int club,int uid,int tid,int activity) {
        return Long.valueOf(1).equals(write("""
                local uid=ARGV[2]
                if redis.call('HGET','JOKER_ROBOT_TABLE',uid)==ARGV[3]
                   and redis.call('HGET',KEYS[4],uid)==ARGV[3]
                   and redis.call('HGET','ROBOT_STATUS',uid)==ARGV[4]
                   and redis.call('HGET','TEMP_ROBOT_STATUS',uid)==ARGV[5] then return 1 end
                return 0
                """,List.of(Integer.toString(uid),RedisRoomAssignments.encode(level,tid,activity),
                            "0_"+club+"_1_"+level,level+"_1")));
    }

    @Override public void releaseRobot(long uid,int tid,int activity) {
        write("""
                if redis.call('HGET','JOKER_ROBOT_TABLE',ARGV[2])==ARGV[3] then
                    redis.call('HDEL','JOKER_ROBOT_TABLE',ARGV[2])
                    if redis.call('HGET',KEYS[4],ARGV[2])==ARGV[3] then redis.call('HDEL',KEYS[4],ARGV[2]) end
                    redis.call('HSET','TEMP_ROBOT_STATUS',ARGV[2],'0_0')
                end
                """,List.of(Long.toString(uid),RedisRoomAssignments.encode(level,tid,activity)));
    }

    @Override public void enableRobot(int club,int uid,int requestedLevel,int status) {
        if (club<=0 || uid<=0 || requestedLevel!=0 && requestedLevel!=level || status!=1) return;
        write("""
                if redis.call('HEXISTS','JOKER_ROBOT_TABLE',ARGV[2])==0
                   and redis.call('HGET','ROBOT_STATUS',ARGV[2])==ARGV[3]
                   then redis.call('HSET','TEMP_ROBOT_STATUS',ARGV[2],'0_0') end
                """,List.of(Integer.toString(uid),"0_"+club+"_1_"+level));
    }

    @Override public boolean route(int tid, int activity, long uid) {
        return Long.valueOf(1).equals(write("""
                if redis.call('EXISTS','JOKER_GIFT_LOCK:'..ARGV[2])==1 or
                   redis.call('HEXISTS','JOKER_ROBOT_TABLE',ARGV[2])==1 then return 0 end
                local old=redis.call('HGET',KEYS[4],ARGV[2])
                if old and old~=ARGV[3] and old:match('^[1-9]%d*_[1-9]%d*_[1-9]%d*$') then return 0 end
                redis.call('HSET',KEYS[4],ARGV[2],ARGV[3])
                return 1
                """,List.of(Long.toString(uid), RedisRoomAssignments.encode(level, tid, activity))));
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
                  if redis.call('HGET','JOKER_ROBOT_TABLE',ARGV[i])==ARGV[5] then
                    redis.call('HDEL','JOKER_ROBOT_TABLE',ARGV[i])
                    redis.call('HSET','TEMP_ROBOT_STATUS',ARGV[i],'0_0')
                  end
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
