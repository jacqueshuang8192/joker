package com.j.joker.game;

import com.j.joker.game.niuniu.domain.table.NiuNiuTable;
import com.j.joker.game.niuniu.application.history.RoundRecord;

import io.netty.buffer.ByteBuf;
import redis.clients.jedis.Jedis;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/** data 的单线程派发器串行处理整局结算与缓存补记。SQL 事务是整局入账边界。 */
final class RoundLedger {
    record Balance(int uid, int before, int after) {
        String encode() { return uid + ":" + before + ":" + after; }
    }

    private final GameSettings.Database database;
    private final short gameId;
    private boolean needsRecovery = true;

    RoundLedger(GameSettings.Database database, short gameId) {
        this.database = database;
        this.gameId = gameId;
    }

    int settle(DataGame game, Jedis redis, ByteBuf in) throws SQLException {
        String id = UUID.fromString(DataPacket.string(in)).toString();
        int count = in.readInt();
        if (count < 2 || count > NiuNiuTable.MAX_SEATS || in.readableBytes() < 12 * count) return 1;
        var balances = new ArrayList<Balance>(count);
        var users = new HashSet<Integer>();
        long net = 0;
        for (int i = 0; i < count; i++) {
            var b = new Balance(in.readInt(), in.readInt(), in.readInt());
            if (b.uid <= 0 || b.before < 0 || b.after < 0 || !users.add(b.uid)) return 1;
            balances.add(b);
            net += (long) b.after - b.before;
        }
        if (net != 0) return 1;
        RoundRecord record = null;
        if (in.isReadable()) {
            record = RoundRecord.parse(in.readCharSequence(in.readableBytes(), java.nio.charset.StandardCharsets.UTF_8).toString());
            if (record.activity() <= 0 || record.level() <= 0 || record.index() <= 0 || record.userinfos().size() != count) return 1;
            for (var seat : record.userinfos()) {
                if (!users.remove(seat.uid()) || balances.stream().noneMatch(b -> b.uid == seat.uid() && b.after - b.before == seat.score())) return 1;
            }
        }
        balances.sort(java.util.Comparator.comparingInt(Balance::uid));
        String payload = balances.stream().map(Balance::encode).collect(Collectors.joining(","));
        try (var db = database.connect()) {
            db.setAutoCommit(false);
            try {
                try (var lookup = db.prepareStatement("SELECT game_id, balances FROM joker_douniu_settlement WHERE round_id=?")) {
                    lookup.setString(1, id);
                    try (var rows = lookup.executeQuery()) {
                        if (rows.next()) {
                            if (rows.getInt(1) != gameId || !rows.getString(2).equals(payload)) return 1;
                            if (record == null) return 0;
                            // 升级前已经入账的局可以补录原快照中的战绩，余额只写一次。
                            try (var read = db.prepareStatement("SELECT content FROM t_free_game_round WHERE douniu_round_id=?")) {
                                read.setString(1, id);
                                try (var history = read.executeQuery()) {
                                    if (history.next()) return record.equals(RoundRecord.parse(history.getString(1))) ? 0 : 1;
                                }
                            }
                            saveRecord(db, id, record);
                            db.commit();
                            return 0;
                        }
                    }
                }
                for (var b : balances) {
                    var player = game.find(redis, b.uid);
                    String live = redis.hget("MEMDATA_" + b.uid, "CHIPS");
                    if (player == null || player.chips() != b.before || (live != null && Integer.parseInt(live) != b.before)) {
                        db.rollback();
                        return 2;
                    }
                    String table = "bullfight_gameinfo" + Math.floorMod(b.uid, database.shards);
                    try (var write = db.prepareStatement("UPDATE " + table + " SET chip=? WHERE mid=? AND COALESCE(chip,0)=?")) {
                        write.setInt(1, b.after);
                        write.setInt(2, b.uid);
                        write.setInt(3, b.before);
                        if (write.executeUpdate() != 1) {
                            db.rollback();
                            return 2;
                        }
                    }
                }
                try (var insert = db.prepareStatement("INSERT INTO joker_douniu_settlement(round_id,game_id,balances) VALUES(?,?,?)")) {
                    insert.setString(1, id);
                    insert.setInt(2, gameId);
                    insert.setString(3, payload);
                    insert.executeUpdate();
                }
                if (record != null) saveRecord(db, id, record);
                needsRecovery = true;
                db.commit();
            } catch (Exception failure) {
                db.rollback();
                throw failure;
            }
        }
        recover(game, redis);
        return 0;
    }

    private static void saveRecord(java.sql.Connection db, String id, RoundRecord record) throws SQLException {
        try (var write = db.prepareStatement("""
                INSERT INTO t_free_game_round(activity_id,level,group_id,round_index,content,end_time,douniu_round_id)
                VALUES(?,?,?,?,?,NOW(),?)""")) {
            write.setInt(1, record.activity());
            write.setInt(2, record.level());
            write.setInt(3, record.club());
            write.setInt(4, record.index());
            write.setString(5, record.json());
            write.setString(6, id);
            write.executeUpdate();
        }
        try (var write = db.prepareStatement("""
                INSERT INTO t_free_game_singleresult(game_id,user_id,date,score,win,lose,draw,total,level)
                VALUES ((SELECT game_id FROM t_activity WHERE activity_id=?),?,CURRENT_DATE,?,?,?,?,1,?)""")) {
            for (var seat : record.userinfos()) {
                write.setInt(1, record.activity());
                write.setInt(2, seat.uid());
                write.setInt(3, seat.score());
                write.setInt(4, seat.score() > 0 ? 1 : 0);
                write.setInt(5, seat.score() < 0 ? 1 : 0);
                write.setInt(6, seat.score() == 0 ? 1 : 0);
                write.setInt(7, record.level());
                write.addBatch();
            }
            write.executeBatch();
        }
    }

    DataPacket billboard(ByteBuf in) throws SQLException {
        if (in.readableBytes() != 12) throw new IllegalArgumentException("总战绩请求长度无效");
        int activity = in.readInt(), level = in.readInt(), expected = in.readInt();
        var board = new com.j.joker.game.niuniu.application.history.RoomBillboard();
        try (var db = database.connect(); var read = db.prepareStatement("""
                SELECT content FROM t_free_game_round
                WHERE activity_id=? AND level=? AND douniu_round_id IS NOT NULL ORDER BY round_index""")) {
            read.setInt(1, activity);
            read.setInt(2, level);
            try (var rows = read.executeQuery()) {
                while (rows.next()) board.add(RoundRecord.parse(rows.getString(1)));
            }
        }
        var reply = new DataPacket(0x2013);
        var fields = board.packet(expected);
        return fields == null ? reply : reply.utf8(com.j.joker.game.niuniu.util.Json.write(fields));
    }

    DataPacket history(ByteBuf in) throws SQLException {
        if (in.readableBytes() != 12) throw new IllegalArgumentException("战绩请求长度无效");
        int activity = in.readInt(), level = in.readInt(), wanted = in.readInt();
        try (var db = database.connect(); var read = db.prepareStatement("""
                SELECT latest.last_index,r.content FROM
                (SELECT COALESCE(MAX(round_index),0) AS last_index FROM t_free_game_round
                 WHERE activity_id=? AND level=? AND douniu_round_id IS NOT NULL) latest
                LEFT JOIN t_free_game_round r ON r.activity_id=? AND r.level=? AND r.douniu_round_id IS NOT NULL
                AND r.round_index=IF(? BETWEEN 1 AND latest.last_index,?,latest.last_index)""")) {
            read.setInt(1, activity);
            read.setInt(2, level);
            read.setInt(3, activity);
            read.setInt(4, level);
            read.setInt(5, wanted);
            read.setInt(6, wanted);
            try (var rows = read.executeQuery()) {
                rows.next();
                var reply = new DataPacket(0x2012).ints(rows.getInt(1));
                String detail = rows.getString(2);
                return detail == null ? reply : reply.utf8(detail);
            }
        }
    }

    // 即使在 SQL 提交和 Redis 同步之间重启，也要在处理下一条数据命令前补记。
    void recover(DataGame game, Jedis redis) throws SQLException {
        if (!needsRecovery) return;
        try (var db = database.connect();
             var pending = db.prepareStatement("SELECT round_id, balances FROM joker_douniu_settlement WHERE game_id=? AND projected=0")) {
            pending.setInt(1, gameId);
            try (var rows = pending.executeQuery()) {
                while (rows.next()) {
                    List<String> keys = new ArrayList<>(), values = new ArrayList<>();
                    for (String item : rows.getString(2).split(",")) {
                        String[] fields = item.split(":");
                        keys.add("MEMDATA_" + fields[0]);
                        values.add(fields[2]);
                        game.players.remove(Integer.valueOf(fields[0]));
                    }
                    redis.eval("""
                            for _,k in ipairs(KEYS) do
                                local t = redis.call('TYPE',k).ok
                                if t ~= 'none' and t ~= 'hash' then return redis.error_reply('invalid player cache') end
                            end
                            for i,k in ipairs(KEYS) do redis.call('HSET',k,'CHIPS',ARGV[i]) end
                            return 1
                            """, keys, values);
                    try (var finish = db.prepareStatement("UPDATE joker_douniu_settlement SET projected=1 WHERE round_id=?")) {
                        finish.setString(1, rows.getString(1));
                        finish.executeUpdate();
                    }
                }
            }
            needsRecovery = false;
        }
    }
}
