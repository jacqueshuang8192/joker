package com.j.joker.game;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Map;
import redis.clients.jedis.Jedis;

/** 单个 data 写入实例使用分表作为账本。待同步标记与账本在同一事务提交。 */
final class PlayerBalanceStore {
    private final GameSettings.Database database;
    private final short game;
    private boolean pending = true;

    PlayerBalanceStore(GameSettings.Database database, short game) {
        this.database = database;
        this.game = game;
    }

    private String table(int uid) {
        return "bullfight_gameinfo" + Math.floorMod(uid, database.shards);
    }

    DataGame.Player read(Connection db, int uid, boolean lock) throws SQLException {
        String sql = "SELECT money,exp,score,wintimes,losetimes,chip FROM " + table(uid)
                + " WHERE mid=?" + (lock ? " FOR UPDATE" : "");
        try (var q = db.prepareStatement(sql)) {
            q.setInt(1, uid);
            try (var row = q.executeQuery()) {
                return row.next() ? new DataGame.Player(row.getLong(1), row.getInt(2), row.getInt(3),
                        row.getInt(4), row.getInt(5), row.getInt(6)) : null;
            }
        }
    }

    void settleChips(Connection db, int uid, int before, int after) throws SQLException {
        var wallet = read(db, uid, true);
        if (wallet == null || wallet.chips() != before) throw new SQLException("玩家筹码与开局记录不一致 " + uid);
        ClubLedger.update(db, "UPDATE " + table(uid) + " SET chip=? WHERE mid=?", after, uid);
        markPending(db, uid);
    }

    private void markPending(Connection db, int uid) throws SQLException {
        ClubLedger.update(db, "INSERT INTO joker_player_cache_sync(game_id,uid) VALUES (?,?) ON DUPLICATE KEY UPDATE uid=VALUES(uid)", game, uid);
        pending = true;
    }

    boolean save(int uid, DataGame.Player before, DataGame.Player after, GoldStore.Chips activity) throws SQLException {
        try (var db = database.connect()) {
            db.setAutoCommit(false);
            try {
                var current = read(db, uid, true);
                if (before == null) {
                    // 注册端可能先创建了空分表行。迟到的初始化不得覆盖已经发生的交易。
                    var empty = new DataGame.Player(0, 0, 0, 0, 0, 0);
                    if (current != null && !current.equals(empty) && !current.equals(after)) return false;
                    if (current == null) ClubLedger.update(db, "INSERT INTO " + table(uid) + " (mid) VALUES (?)", uid);
                } else if (!before.equals(current)) {
                    return false;
                }
                ClubLedger.update(db, "UPDATE " + table(uid) + " SET money=?,exp=?,score=?,wintimes=?,losetimes=?,chip=? WHERE mid=?",
                        after.money(), after.exp(), after.score(), after.wins(), after.losses(), after.chips(), uid);
                if (activity != null) GoldStore.updateChips(db, activity);
                markPending(db, uid);
                db.commit();
                return true;
            } catch (Exception failure) {
                db.rollback();
                throw failure;
            }
        }
    }

    record Purchase(boolean accepted, int chips, long money, boolean newlyApplied) {}

    Purchase buy(int uid, int activity, int wanted, int bring, String key, boolean held,
                 DataGame.Player expected) throws SQLException {
        try (var db = database.connect()) {
            db.setAutoCommit(false);
            try {
                // 所有本账号购买先锁同一钱包行，再读取原回执，跨连接重试也只扣一次。
                var wallet = read(db, uid, true);
                if (wallet == null) return new Purchase(false, 0, 0, false);
                try (var q = db.prepareStatement("""
                        SELECT activity,wanted,bring_amount,accepted,chips_after,money_after
                        FROM joker_chip_purchase WHERE game_id=? AND uid=? AND request_id=? FOR UPDATE""")) {
                    q.setShort(1, game); q.setInt(2, uid); q.setString(3, key);
                    try (var row = q.executeQuery()) {
                        if (row.next()) {
                            if (row.getInt(1)!=activity || row.getInt(2)!=wanted || row.getInt(3)!=bring)
                                return new Purchase(false, wallet.chips(), wallet.money(), false);
                            return new Purchase(row.getBoolean(4), row.getInt(5), row.getLong(6), false);
                        }
                    }
                }
                long cost = wanted * 1200L / 1000;
                boolean accepted = !held && wanted > 0 && wallet.equals(expected) && cost <= wallet.money()
                        && (long) wallet.chips() + wanted <= Integer.MAX_VALUE;
                if (accepted) {
                    wallet = wallet.balance(wallet.money()-cost, wallet.chips()+wanted);
                    ClubLedger.update(db, "UPDATE " + table(uid) + " SET money=?,chip=? WHERE mid=?",
                            wallet.money(),wallet.chips(),uid);
                    GoldStore.updateChips(db,new GoldStore.Chips(uid,activity,wallet.chips(),bring));
                    markPending(db, uid);
                }
                if (accepted || !key.startsWith("legacy:"))
                    ClubLedger.update(db, """
                            INSERT INTO joker_chip_purchase(game_id,uid,request_id,activity,wanted,bring_amount,accepted,chips_after,money_after)
                            VALUES(?,?,?,?,?,?,?,?,?)""",game,uid,key,activity,wanted,bring,accepted,wallet.chips(),wallet.money());
                db.commit();
                return new Purchase(accepted, wallet.chips(), wallet.money(), accepted);
            } catch (Exception failure) {
                db.rollback();
                throw failure;
            }
        }
    }

    void recover(DataGame data, Jedis redis) throws SQLException {
        if (!pending) return;
        try (var db = database.connect();
             var q = db.prepareStatement("SELECT uid FROM joker_player_cache_sync WHERE game_id=?")) {
            q.setInt(1, game);
            try (var rows = q.executeQuery()) {
                while (rows.next()) {
                    int uid = rows.getInt(1);
                    var player = read(db, uid, false);
                    if (player == null) throw new SQLException("待同步的玩家分表记录缺失 " + uid);
                    redis.hset("MEMDATA_" + uid, Map.of("MONEY", Long.toString(player.money()), "CHIPS", Integer.toString(player.chips()),
                            "EXP", Integer.toString(player.exp()), "SCORE", Integer.toString(player.score()),
                            "WIN", Integer.toString(player.wins()), "LOST", Integer.toString(player.losses())));
                    data.players.put(uid, player);
                    ClubLedger.update(db, "DELETE FROM joker_player_cache_sync WHERE game_id=? AND uid=?", game, uid);
                }
            }
            pending = false;
        }
    }
}
