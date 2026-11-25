package com.j.joker.game;

import lombok.RequiredArgsConstructor;
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
@RequiredArgsConstructor
final class RoundLedger {
    record Balance(int uid, int before, int after) {
        String encode() { return uid + ":" + before + ":" + after; }
    }

    private final GameSettings.Database database;
    private final short gameId;
    private boolean needsRecovery = true;

    private record Hold(String round, int chips) {}
    private Hold hold(java.sql.Connection db, int uid) throws SQLException {
        try (var q = db.prepareStatement("SELECT round_id,before_chips FROM joker_douniu_side_hold WHERE uid=?")) {
            q.setInt(1, uid);
            try (var rs = q.executeQuery()) { return rs.next() ? new Hold(rs.getString(1), rs.getInt(2)) : null; }
        }
    }

    boolean held(int uid) throws SQLException {
        try (var db = database.connect()) { return hold(db, uid) != null; }
    }

    int reserve(DataGame game, Jedis redis, ByteBuf in) throws SQLException {
        String id = UUID.fromString(DataPacket.string(in)).toString();
        if (in.readableBytes() != 8) return 1;
        int uid = in.readInt(), before = in.readInt();
        if (uid <= 0 || before <= 0) return 1;
        try (var db = database.connect()) {
            db.setAutoCommit(false);
            try {
                Hold prior = hold(db, uid);
                if (prior != null) return prior.round.equals(id) && prior.chips == before ? 0 : 1;
                var player = game.find(redis, uid);
                if (player == null || player.chips() != before) return 1;
                String live = redis.hget("MEMDATA_" + uid, "CHIPS");
                if (live != null && Integer.parseInt(live) != before) return 1;
                String table = "bullfight_gameinfo" + Math.floorMod(uid, database.shards);
                try (var q = db.prepareStatement("SELECT chip FROM " + table + " WHERE mid=? FOR UPDATE")) {
                    q.setInt(1, uid);
                    try (var rs = q.executeQuery()) { if (!rs.next() || rs.getInt(1) != before) return 1; }
                }
                int inserted = ClubLedger.update(db, """
                        INSERT INTO joker_douniu_side_hold(uid,round_id,before_chips)
                        SELECT ?,?,? WHERE NOT EXISTS(SELECT 1 FROM joker_douniu_settlement WHERE round_id=?)""",
                        uid, id, before, id);
                db.commit();
                return inserted == 1 ? 0 : 1;
            } catch (Exception failure) { db.rollback(); throw failure; }
        }
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
        RoundRecord record = null;
        if (in.isReadable()) {
            record = RoundRecord.parse(in.readCharSequence(in.readableBytes(), java.nio.charset.StandardCharsets.UTF_8).toString());
            if (record.activity() <= 0 || record.level() <= 0 || record.index() <= 0 || record.userinfos().size() != count) return 1;
            for (var seat : record.userinfos()) {
                if (!users.remove(seat.uid()) || balances.stream().noneMatch(b -> b.uid == seat.uid() && b.after - b.before == seat.score())) return 1;
            }
        }
        var side = record == null ? null : record.side();
        if (side != null) {
            var positions = new HashSet<String>();
            long exposure = 0;
            for (var bet : side.positions()) {
                if (bet.amount() < 1 || Math.abs((long)bet.delta()) != bet.amount()
                        || (balances.stream().noneMatch(b -> b.uid == bet.uid()) && !side.standingBalances().containsKey(bet.uid())) || bet.seat() < 0
                        || bet.seat() >= NiuNiuTable.MAX_SEATS || !positions.add(bet.uid() + ":" + bet.seat())) return 1;
                exposure += bet.amount();
            }
            if (side.dealer() < 0 || exposure > Integer.MAX_VALUE) return 1;
            for (var entry : side.standingBalances().entrySet()) {
                int uid = Math.toIntExact(entry.getKey());
                long before = entry.getValue(), delta = side.delta(uid);
                long risk = side.positions().stream().filter(p -> p.uid() == uid).mapToLong(p -> p.amount()).sum();
                if (uid <= 0 || risk == 0 || uid == side.dealer() || balances.stream().anyMatch(b -> b.uid() == uid)
                        || risk > Math.min(before, Integer.MAX_VALUE - before)) return 1;
                balances.add(new Balance(uid, Math.toIntExact(before), Math.toIntExact(before + delta)));
                net += delta;
            }
            net += side.dealerDelta();
            if (side.dealer() > 0) {
                if (balances.stream().anyMatch(b -> b.uid == side.dealer())
                        || exposure > Math.min(side.dealerBefore(), Integer.MAX_VALUE - side.dealerBefore())) return 1;
                balances.add(new Balance(Math.toIntExact(side.dealer()), Math.toIntExact(side.dealerBefore()),
                        Math.toIntExact(side.dealerBefore() + side.dealerDelta())));
            }
        }
        var fees = record == null ? null : record.fees();
        if (fees != null) {
            if (record.club() <= 0 || fees.charges().keySet().stream().anyMatch(uid -> balances.stream().noneMatch(b -> b.uid == uid))) return 1;
            net += fees.total();
        }
        if (net != 0) return 1;
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
                    Hold locked = hold(db, b.uid);
                    boolean sidePlayer = side != null && (side.dealer() == b.uid || side.positions().stream().anyMatch(p -> p.uid() == b.uid));
                    if (locked == null ? sidePlayer : !locked.round.equals(id) || locked.chips != b.before) return 2;
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
                if (fees != null) {
                    var after = new java.util.HashMap<Integer,Long>();
                    balances.forEach(b -> after.put(b.uid,(long)b.after));
                    ClubLedger.post(db, record.club(), record.activity(), record.index(), record.level(), fees, after);
                }
                if (side != null) {
                    try (var insert = db.prepareStatement("""
                            INSERT INTO joker_douniu_side_ledger(round_id,activity_id,dealer_uid,dealer_delta,orders)
                            VALUES(?,?,?,?,?)""")) {
                        insert.setString(1, id);
                        insert.setInt(2, record.activity());
                        insert.setLong(3, side.dealer());
                        insert.setLong(4, side.dealerDelta());
                        insert.setString(5, record.json());
                        insert.executeUpdate();
                    }
                }
                if (record != null) saveRecord(db, id, record);
                // 包括已占用但抢庄确认丢失、以及无人下注的局。
                ClubLedger.update(db, "DELETE FROM joker_douniu_side_hold WHERE round_id=?", id);
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

    int gift(DataGame game, Jedis redis, ByteBuf in) throws SQLException {
        needsRecovery = true;
        int result = GiftLedger.transfer(database,game,redis,in);
        recover(game,redis);
        return result;
    }

    int tableCharge(DataGame game, Jedis redis, ByteBuf in) throws SQLException {
        String id = UUID.fromString(DataPacket.string(in)).toString();
        String kind = DataPacket.string(in);
        if (!List.of("START","UP","DOWN").contains(kind) || in.readableBytes() != 28) return 1;
        int activity = in.readInt(), club = in.readInt(), level = in.readInt(), round = in.readInt();
        int uid = in.readInt(), before = in.readInt(), amount = in.readInt();
        if (activity <= 0 || club <= 0 || level <= 0 || round <= 0 || uid <= 0 || amount <= 0 || before < amount) return 1;
        try (var db = database.connect()) {
            db.setAutoCommit(false);
            try {
                try (var q = db.prepareStatement("""
                        SELECT activity_id=?,club_id=?,level_id=?,round_index=?,kind=?,uid=?,before_chips=?,amount=?
                        FROM joker_table_charge WHERE event_id=?""")) {
                    Object[] fields = {activity, club, level, round, kind, uid, before, amount, id};
                    for (int i=0; i<fields.length; i++) q.setObject(i+1, fields[i]);
                    try (var rs = q.executeQuery()) {
                        if (rs.next()) {
                            for (int i=1; i<=8; i++) if (!rs.getBoolean(i)) return 1;
                            return 0;
                        }
                    }
                }
                int owner = ClubLedger.owner(db, club);
                var player = game.find(redis, uid);
                if (player == null || player.chips() != before || hold(db,uid) != null) return 2;
                String table = "bullfight_gameinfo" + Math.floorMod(uid,database.shards);
                if (ClubLedger.update(db, "UPDATE "+table+" SET chip=? WHERE mid=? AND chip=?", before-amount,uid,before)!=1) return 2;
                ClubLedger.update(db,"""
                        INSERT INTO joker_table_charge(event_id,activity_id,club_id,level_id,round_index,kind,uid,before_chips,amount)
                        VALUES(?,?,?,?,?,?,?,?,?)""",id,activity,club,level,round,kind,uid,before,amount);
                var plan = new com.j.joker.game.niuniu.domain.rules.ClubFee.Plan(
                        java.util.Map.of(uid,new com.j.joker.game.niuniu.domain.rules.ClubFee.Charge(amount,0)), java.util.Map.of(uid,amount));
                ClubLedger.distribute(db,club,activity,level,owner,plan);
                needsRecovery = true;
                db.commit();
            } catch (Exception failure) { db.rollback(); throw failure; }
        }
        recover(game,redis);
        return 0;
    }

    int closeClub(DataGame game, Jedis redis, ByteBuf in) throws SQLException {
        int club=in.readInt(), activity=in.readInt(), level=in.readInt(), expected=in.readInt();
        var fields = com.j.joker.game.niuniu.util.Json.parseObject(in.readCharSequence(in.readableBytes(),
                java.nio.charset.StandardCharsets.UTF_8).toString());
        var activeElsewhere = new HashSet<Integer>();
        if (fields.remove("activeElsewhere") instanceof List<?> ids) {
            for (Object id : ids) activeElsewhere.add(((Number) id).intValue());
        }
        var rules = com.j.joker.game.niuniu.domain.rules.GameConfig.fromMap(fields);
        if (expected < 1 || club <= 0 || !rules.clubFee().enabled() || rules.gongNiu()) return 1;
        var fee = rules.clubFee();
        // 只将影响本次扣款的字段计入回执，JSON 键序和额外的显示字段可不同。
        String terms = List.of(club, level, expected, fee.mode(), fee.profit().toPlainString(), fee.threshold(),
                fee.winners(), fee.share(), fee.additional(), fee.partnerFunded(), new java.util.TreeMap<>(fee.tiers())).toString();
        try (var db=database.connect()) {
            db.setAutoCommit(false);
            try {
                ClubLedger.owner(db,club);
                try (var q=db.prepareStatement("SELECT close_key=SHA2(?,256) FROM joker_douniu_club_bill WHERE activity_id=? AND round_index=0")) {
                    q.setString(1,terms);
                    q.setInt(2,activity);
                    try(var rs=q.executeQuery()) { if(rs.next()) return rs.getBoolean(1) ? 0 : 1; }
                }
                var scores=new java.util.TreeMap<Integer,Long>();
                try(var q=db.prepareStatement("SELECT content FROM t_free_game_round WHERE activity_id=? AND level=? AND douniu_round_id IS NOT NULL ORDER BY round_index")) {
                    q.setInt(1,activity); q.setInt(2,level);
                    try(var rs=q.executeQuery()) {
                        int index=0;
                        while(rs.next()) {
                            var row=RoundRecord.parse(rs.getString(1));
                            if(row.club()!=club || row.activity()!=activity || row.index()!=++index) return 1;
                            for(var seat:row.userinfos()) scores.merge(seat.uid(),seat.score() -
                                    (row.side()==null ? 0L : row.side().delta(seat.uid())),Long::sum);
                        }
                        if(index!=expected) return 1;
                    }
                }
                var balances=new java.util.HashMap<Integer,Long>();
                for(int uid:scores.keySet()) {
                    var player=game.find(redis,uid);
                    if(player==null) return 1;
                    balances.put(uid,(long)player.chips());
                }
                var plan=rules.clubFee().calculate(scores,balances);
                for(var e:plan.charges().entrySet()) {
                    int uid=e.getKey();
                    if (activeElsewhere.contains(uid) || hold(db, uid) != null) return 2;
                    long before=balances.get(uid), after=before-e.getValue().total();
                    String table="bullfight_gameinfo"+Math.floorMod(uid,database.shards);
                    if (ClubLedger.update(db,"UPDATE "+table+" SET chip=? WHERE mid=? AND chip=?",after,uid,before)!=1) return 2;
                    balances.put(uid,after);
                }
                ClubLedger.post(db,club,activity,0,level,plan,balances);
                ClubLedger.update(db, "UPDATE joker_douniu_club_bill SET close_key=SHA2(?,256) WHERE activity_id=? AND round_index=0", terms, activity);
                needsRecovery=true;
                db.commit();
            } catch(Exception failure) { db.rollback(); throw failure; }
        }
        recover(game,redis);
        return 0;
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
        try (var db = database.connect(); var read = db.prepareStatement(
                "SELECT uid,base_fee,additional_fee FROM joker_douniu_club_debit WHERE activity_id=? AND round_index=0")) {
            read.setInt(1,activity);
            try (var rows=read.executeQuery()) { while(rows.next()) board.deduct(rows.getInt(1),rows.getLong(2)+rows.getLong(3)); }
        }
        try (var db = database.connect(); var q = db.prepareStatement(
                "SELECT uid,SUM(amount) FROM joker_table_charge WHERE activity_id=? GROUP BY uid")) {
            q.setInt(1,activity);
            try (var rs=q.executeQuery()) { while (rs.next()) board.deduct(rs.getInt(1),rs.getLong(2)); }
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
            try (var q=db.prepareStatement("SELECT activity_id,uid,after_chips FROM joker_douniu_club_debit WHERE projected=0 ORDER BY activity_id,uid");
                 var rs=q.executeQuery()) {
                while(rs.next()) {
                    int uid=rs.getInt(2);
                    redis.hset("MEMDATA_"+uid,"CHIPS",rs.getString(3));
                    game.players.remove(uid);
                    ClubLedger.update(db,"UPDATE joker_douniu_club_debit SET projected=1 WHERE activity_id=? AND round_index=0 AND uid=?",rs.getInt(1),uid);
                }
            }
            try (var q = db.prepareStatement("SELECT event_id,uid,before_chips-amount FROM joker_table_charge WHERE projected=0");
                 var rs = q.executeQuery()) {
                while (rs.next()) {
                    int uid = rs.getInt(2);
                    redis.hset("MEMDATA_"+uid, "CHIPS", rs.getString(3));
                    game.players.remove(uid);
                    ClubLedger.update(db,"UPDATE joker_table_charge SET projected=1 WHERE event_id=?",rs.getString(1));
                }
            }
            GiftLedger.project(game, redis, db);
            needsRecovery = false;
        }
    }
}
