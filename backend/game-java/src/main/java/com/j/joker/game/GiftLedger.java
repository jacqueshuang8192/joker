package com.j.joker.game;

import com.j.joker.game.rooms.infrastructure.GiftLock;
import io.netty.buffer.ByteBuf;
import redis.clients.jedis.Jedis;
import java.sql.*;
import java.util.UUID;
import java.nio.charset.StandardCharsets;

/** data 串行处理钱包命令。玩家余额、赠送记录和待同步标志同时提交。 */
final class GiftLedger {
    private GiftLedger() {}
    static int transfer(GameSettings.Database database, DataGame game, Jedis redis, ByteBuf in) throws SQLException {
        int sender = in.readInt(), recipient = in.readInt(), count = in.readInt();
        String request = DataPacket.string(in);
        String remark = in.readCharSequence(in.readableBytes(), StandardCharsets.UTF_8).toString();
        if (sender <= 0 || recipient <= 0 || sender == recipient || count <= 0 || remark.length()>255
                || !request.matches("[a-zA-Z0-9_-]{8,64}")) return 1;
        try (var db = database.connect()) {
            try (var q = db.prepareStatement("SELECT to_user_id,roomcard_num,remark FROM t_gift_room_card WHERE user_id=? AND request_id=?")) {
                q.setInt(1,sender); q.setString(2,request);
                try (var rs=q.executeQuery()) {
                    if (rs.next()) return rs.getInt(1)==recipient && rs.getInt(2)==count && remark.equals(rs.getString(3)) ? 5 : 1;
                }
            }
            String owner = UUID.randomUUID().toString();
            if (!GiftLock.acquire(redis,sender,owner)) return 2;
            try {
                db.setAutoCommit(false);
                long from=0, to=0, maxFrom=0, maxTo=0;
                for (int uid : new int[]{Math.min(sender,recipient),Math.max(sender,recipient)}) {
                    String table = "bullfight_gameinfo"+Math.floorMod(uid,database.shards);
                    try (var q=db.prepareStatement("SELECT money FROM "+table+" WHERE mid=? FOR UPDATE")) {
                        q.setInt(1,uid);
                        try (var rs=q.executeQuery()) {
                            if (!rs.next()) return 3;
                            var player = game.find(redis,uid);
                            if (player == null) return 3;
                            var column = rs.getMetaData();
                            // 旧库的 money 为 INT，也兼容已有业务库加宽后的 BIGINT。
                            long limit = column.getColumnType(1)==Types.INTEGER
                                    ? (column.isSigned(1) ? Integer.MAX_VALUE : 0xffffffffL) : Long.MAX_VALUE;
                            if (uid==sender) { from=player.money(); maxFrom=limit; }
                            else { to=player.money(); maxTo=limit; }
                        }
                    }
                }
                if (from<count || from-count>maxFrom || to<0 || to>maxTo-count) return 4;
                for (int uid : new int[]{sender,recipient}) {
                    String table="bullfight_gameinfo"+Math.floorMod(uid,database.shards);
                    ClubLedger.update(db,"UPDATE "+table+" SET money=? WHERE mid=?",uid==sender ? from-count : to+count,uid);
                }
                ClubLedger.update(db,"""
                        INSERT INTO t_gift_room_card(user_id,to_user_id,roomcard_num,type,remark,create_time,
                            request_id,money_after,recipient_after,projected)
                        VALUES(?,?,?,1,?,NOW(),?,?,?,0)""",sender,recipient,count,remark,request,from-count,to+count);
                if (!owner.equals(redis.get(GiftLock.key(sender)))) return 2;
                db.commit();
                return 0;
            } catch (Exception failure) { db.rollback(); throw failure; }
            finally { GiftLock.release(redis,sender,owner); }
        }
    }

    static void project(DataGame game, Jedis redis, Connection db) throws SQLException {
        try (var q=db.prepareStatement("SELECT id,user_id,to_user_id,money_after,recipient_after FROM t_gift_room_card WHERE projected=0 ORDER BY id");
             var rs=q.executeQuery()) {
            while (rs.next()) {
                int sender=rs.getInt(2), recipient=rs.getInt(3);
                redis.eval("""
                        redis.call('HSET',KEYS[1],'MONEY',ARGV[1])
                        redis.call('HSET',KEYS[2],'MONEY',ARGV[2])
                        """,java.util.List.of("MEMDATA_"+sender,"MEMDATA_"+recipient),
                            java.util.List.of(rs.getString(4),rs.getString(5)));
                game.players.remove(sender);
                game.players.remove(recipient);
                ClubLedger.update(db,"UPDATE t_gift_room_card SET projected=1 WHERE id=?",rs.getLong(1));
            }
        }
    }
}
