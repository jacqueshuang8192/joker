package com.j.joker.game;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;
import org.w3c.dom.Element;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.*;

final class GoldStore implements AutoCloseable {
    private static final Logger LOG = LoggerFactory.getLogger(GoldStore.class);
    private final Map<Short, Game> games = new HashMap<>();
    private final ScheduledExecutorService timer = Executors.newSingleThreadScheduledExecutor();
    private final JedisPool redis;

    sealed interface Update permits Player, Chips {}
    record Player(int uid) implements Update {}
    record Chips(int uid, int activity, int present, int bring) implements Update {}

    GoldStore(Environment env) throws Exception {
        var sections = GameSettings.games(env, "gold");
        redis = GameSettings.redis(env);
        try {
            for (int i = 0; i < sections.getLength(); i++) {
                Element section = (Element) sections.item(i);
                short id = Short.parseShort(section.getAttribute("GameID"));
                if (!"0".equals(section.getAttribute("ServerType"))) throw new IllegalArgumentException("Unsupported ServerType");
                var game = new Game((Element) section.getElementsByTagName("DB").item(0));
                if (games.putIfAbsent(id, game) != null) throw new IllegalArgumentException("Duplicate GameID: " + id);
                try (var db = game.connect()) { if (!db.isValid(3)) throw new SQLException("MySQL check failed"); }
                int seconds = Integer.parseInt(section.getAttribute("UpdateInteval"));
                // One timer processes writes in arrival order per game. JDBC work stays off the Netty event loop.
                timer.scheduleWithFixedDelay(() -> flush(game), seconds, seconds, TimeUnit.SECONDS);
            }
        } catch (Exception error) {
            timer.shutdownNow();
            redis.close();
            throw error;
        }
    }

    boolean supports(short game) { return games.containsKey(game); }
    boolean enqueue(short game, Update update) {
        return games.get(game).pending.offer(update);
    }

    private static final class Game extends GameSettings.Database {
        final BlockingQueue<Update> pending = new ArrayBlockingQueue<>(32768);
        Game(Element db) { super(db); }
    }

    private void flush(Game game) {
        int count = game.pending.size();
        if (count == 0) return;
        try (var db = game.connect()) {
            for (int i = 0; i < count; i++) {
                Update next = game.pending.element();
                switch (next) {
                    case Player p -> updatePlayer(db, game.shards, p.uid());
                    case Chips c -> updateChips(db, c);
                }
                // All statements assign absolute values and can be replayed after a lost response.
                game.pending.remove();
            }
        } catch (Exception e) {
            LOG.warn("Gold update failed; pending writes will be retried", e);
        }
    }

    private void updatePlayer(Connection db, int shards, int uid) throws SQLException {
        // 先锁玩家行再读缓存，避免延迟的旧快照覆盖 data 新提交的整局余额。
        String table = "bullfight_gameinfo" + Math.floorMod(uid, shards);
        db.setAutoCommit(false);
        try (var lock = db.prepareStatement("SELECT mid FROM " + table + " WHERE mid=? FOR UPDATE")) {
            lock.setInt(1, uid);
            try (var rows = lock.executeQuery()) {
                if (rows.next()) writeCachedPlayer(db, table, uid);
            }
            db.commit();
        } catch (Exception ex) {
            db.rollback();
            throw ex;
        } finally {
            db.setAutoCommit(true);
        }
    }

    private void writeCachedPlayer(Connection db, String table, int uid) throws SQLException {
        try (var check = db.prepareStatement("""
                SELECT 1 FROM joker_douniu_settlement WHERE projected=0
                UNION ALL SELECT 1 FROM joker_douniu_club_debit WHERE projected=0
                UNION ALL SELECT 1 FROM joker_table_charge WHERE projected=0
                UNION ALL SELECT 1 FROM joker_player_cache_sync WHERE uid=?
                UNION ALL SELECT 1 FROM t_gift_room_card WHERE projected=0 LIMIT 1""")) {
            check.setInt(1, uid);
            try (var pending = check.executeQuery()) {
                if (pending.next()) throw new SQLException("等待玩家余额缓存补记");
            }
        }
        List<String> values;
        try (Jedis client = redis.getResource()) {
            values = client.hmget("MEMDATA_" + uid, "MONEY", "EXP", "WIN", "LOST", "SCORE", "CHIPS");
        }
        if (values.contains(null)) return;
        String sql = "UPDATE " + table
                + " SET money=?,exp=?,wintimes=?,losetimes=?,score=?,chip=? WHERE mid=?";
        try (PreparedStatement stmt = db.prepareStatement(sql)) {
            for (int i = 0; i < values.size(); i++) {
                String value = values.get(i);
                try {
                    stmt.setLong(i + 1, Long.parseLong(value));
                } catch (NumberFormatException invalid) {
                    LOG.warn("Skipping malformed MEMDATA field {} for uid {}", i, uid);
                    return;
                }
            }
            stmt.setInt(7, uid);
            stmt.executeUpdate();
        }
    }

    static void updateChips(Connection db, Chips chips) throws SQLException {
        String sql = chips.bring() == 0
                ? "UPDATE t_activity_user SET present_chip=? WHERE userid=? AND activity_id=?"
                : "UPDATE t_activity_user SET present_chip=?,bring_chip=? WHERE userid=? AND activity_id=?";
        try (PreparedStatement stmt = db.prepareStatement(sql)) {
            int i = 1;
            stmt.setInt(i++, chips.present());
            if (chips.bring() != 0) stmt.setInt(i++, chips.bring());
            stmt.setInt(i++, chips.uid());
            stmt.setInt(i, chips.activity());
            stmt.executeUpdate();
        }
    }

    @Override public void close() {
        timer.shutdown();
        try {
            if (!timer.awaitTermination(30, TimeUnit.SECONDS)) {
                LOG.warn("Timed out waiting for the gold writer to stop");
                return;
            }
            games.values().forEach(this::flush);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } finally {
            redis.close();
        }
    }
}
