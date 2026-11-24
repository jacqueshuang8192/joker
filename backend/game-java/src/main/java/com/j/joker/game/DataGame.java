package com.j.joker.game;

import org.w3c.dom.Element;
import redis.clients.jedis.Jedis;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import org.slf4j.LoggerFactory;

/** One instance per configured game. All commands run serially on the data service executor. */
final class DataGame implements AutoCloseable {
    record Player(long money, int exp, int score, int wins, int losses, int chips) {
        Player delta(int moneyDiff, int expDiff, int scoreDiff, int winsDiff, int lossesDiff, int chipDiff) {
            return new Player(Math.max(0, money + moneyDiff), Math.max(0, exp + expDiff),
                    Math.max(0, score + scoreDiff), Math.max(0, wins + winsDiff),
                    Math.max(0, losses + lossesDiff), Math.max(0, chips + chipDiff));
        }
        Player balance(long amount, int chipCount) { return new Player(amount, exp, score, wins, losses, chipCount); }
    }

    final Map<Integer, Player> players = new HashMap<>();
    private final GameSettings.Database database;
    final RoundLedger rounds;
    private final Forwarder log;
    private final Forwarder update;
    // The original forwards the last round's money and score deltas, including on a later exchange.
    private record Delta(long money, int score) {}
    private final Map<Integer, Delta> deltas = new HashMap<>();

    DataGame(Element section) throws SQLException {
        if (!"0".equals(section.getAttribute("ServerType"))) throw new IllegalArgumentException("Unsupported ServerType");
        database = new GameSettings.Database((Element) section.getElementsByTagName("DB").item(0));
        try (var db = database.connect()) { if (!db.isValid(3)) throw new SQLException("MySQL check failed"); }
        rounds = new RoundLedger(database, Short.parseShort(section.getAttribute("GameID")));
        log = new Forwarder(section, "LogServer");
        update = new Forwarder(section, "UpdateServer");
    }

    boolean isClubOwner(int club, int uid) throws SQLException {
        try (var db = database.connect();
             var read = db.prepareStatement("SELECT 1 FROM t_group_player WHERE group_id=? AND ower_id=?")) {
            read.setInt(1, club);
            read.setInt(2, uid);
            try (var result = read.executeQuery()) { return result.next(); }
        }
    }

    java.util.List<Integer> clubMembersAfter(int club, int after) throws SQLException {
        try (var db = database.connect(); var read = db.prepareStatement(
                "SELECT DISTINCT player_id FROM t_player_group WHERE group_id=? AND player_id>? ORDER BY player_id LIMIT 256")) {
            read.setInt(1,club);
            read.setInt(2,after);
            var members = new java.util.ArrayList<Integer>();
            try (var rows = read.executeQuery()) { while (rows.next()) members.add(rows.getInt(1)); }
            return members;
        }
    }

    boolean isClubMember(int club, int uid) throws SQLException {
        try (var db = database.connect();
             var read = db.prepareStatement("SELECT 1 FROM t_player_group WHERE group_id=? AND player_id=? LIMIT 1")) {
            read.setInt(1, club);
            read.setInt(2, uid);
            try (var result = read.executeQuery()) { return result.next(); }
        }
    }

    Player find(Jedis redis, int uid) throws SQLException {
        Player p = players.get(uid);
        if (p != null) return p;
        var fields = redis.hmget("MEMDATA_" + uid, "MONEY", "EXP", "SCORE", "WIN", "LOST", "CHIPS");
        if (!fields.contains(null)) {
            p = new Player(Long.parseLong(fields.get(0)), Integer.parseInt(fields.get(1)), Integer.parseInt(fields.get(2)),
                    Integer.parseInt(fields.get(3)), Integer.parseInt(fields.get(4)), Integer.parseInt(fields.get(5)));
        } else {
            String sql = "SELECT money, exp, score, wintimes, losetimes, chip FROM bullfight_gameinfo"
                    + Math.floorMod(uid, database.shards) + " WHERE mid=?";
            try (var db = database.connect(); var stmt = db.prepareStatement(sql)) {
                stmt.setInt(1, uid);
                try (var rows = stmt.executeQuery()) {
                    if (!rows.next()) return null;
                    p = new Player(rows.getLong(1), rows.getInt(2), rows.getInt(3),
                            rows.getInt(4), rows.getInt(5), rows.getInt(6));
                }
            }
        }
        players.put(uid, p);
        return p;
    }

    void save(Jedis redis, int uid, Player p, Player before, boolean moneyOnly, int source, String reason, String client) {
        String key = "MEMDATA_" + uid;
        if (moneyOnly) redis.hset(key, "MONEY", Long.toString(p.money));
        else redis.hset(key, Map.of("MONEY", Long.toString(p.money), "EXP", Integer.toString(p.exp),
                "SCORE", Integer.toString(p.score), "WIN", Integer.toString(p.wins),
                "LOST", Integer.toString(p.losses), "CHIPS", Integer.toString(p.chips)));
        players.put(uid, p);
        if (before != null) deltas.put(uid, new Delta(p.money - before.money, p.score - before.score));
        if (log.enabled()) {
            Delta delta = deltas.getOrDefault(uid, new Delta(0, 0));
            var packet = new DataPacket(0x3003).ints(uid).number(delta.money).number(p.money)
                    .ints(delta.score, p.score, source).text(reason).text(client);
            if (!moneyOnly) packet.ints(p.chips);
            log.send(packet);
        }
        update.send(new DataPacket(0x3004).ints(uid));
    }

    boolean delete(Jedis redis, int uid) {
        if (!players.containsKey(uid)) return false;
        redis.del("MEMDATA_" + uid);
        players.remove(uid);
        deltas.remove(uid);
        return true;
    }

    void activity(int uid, int activity, int chips, int bring) {
        update.send(new DataPacket(0x3005).ints(uid, activity, chips, bring));
    }

    private static final class Forwarder implements AutoCloseable {
        private final InetSocketAddress address;
        private Socket socket;

        Forwarder(Element section, String name) {
            Element element = (Element) section.getElementsByTagName(name).item(0);
            address = element == null ? null : new InetSocketAddress(element.getAttribute("ip"),
                    Integer.parseInt(element.getAttribute("port")));
        }
        boolean enabled() { return address != null; }

        void send(DataPacket packet) {
            if (!enabled()) return;
            try {
                if (socket == null) {
                    socket = new Socket();
                    socket.connect(address, 1500);
                    socket.setTcpNoDelay(true);
                }
                socket.getOutputStream().write(packet.bytes());
            } catch (IOException ex) {
                close();
                LoggerFactory.getLogger(DataGame.class).warn("Data notification to {} failed", address, ex);
            }
        }
        public void close() {
            if (socket != null) {
                try { socket.close(); } catch (IOException ignored) {}
                socket = null;
            }
        }
    }
    public void close() { log.close(); update.close(); }
}
