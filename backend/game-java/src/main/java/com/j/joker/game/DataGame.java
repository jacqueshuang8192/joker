package com.j.joker.game;

import com.j.joker.game.niuniu.application.RoundAccounts.Member;
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
    final HundredLedger hundred;
    final RoundLedger rounds;
    final PlayerBalanceStore balances;
    private final Forwarder log;
    private final Forwarder update;
    // The original forwards the last round's money and score deltas, including on a later exchange.
    private record Delta(long money, int score) {}
    private final Map<Integer, Delta> deltas = new HashMap<>();

    DataGame(Element section, boolean pureJava) throws SQLException {
        if (!"0".equals(section.getAttribute("ServerType"))) throw new IllegalArgumentException("Unsupported ServerType");
        database = new GameSettings.Database((Element) section.getElementsByTagName("DB").item(0));
        try (var db = database.connect()) { if (!db.isValid(3)) throw new SQLException("MySQL check failed"); }
        rounds = new RoundLedger(database, Short.parseShort(section.getAttribute("GameID")));
        balances = pureJava ? new PlayerBalanceStore(database, Short.parseShort(section.getAttribute("GameID"))) : null;
        hundred = pureJava ? new HundredLedger(database, balances) : null;
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

    java.util.List<Member> membersAfter(int club, int after, int limit) throws SQLException {
        if (limit < 1 || limit > 64) throw new IllegalArgumentException("成员分页大小无效");
        try (var db = database.connect(); var query = db.prepareStatement("""
                SELECT u.userid, LEFT(u.nick_name,64), LEFT(u.small_icon,255), CAST(u.gender AS SIGNED)
                FROM t_user u WHERE u.userid>? AND COALESCE(u.is_robot,0)=0
                AND EXISTS (SELECT 1 FROM t_player_group m WHERE m.group_id=? AND m.player_id=u.userid)
                ORDER BY u.userid LIMIT ?""")) {
            query.setInt(1,after);
            query.setInt(2,club);
            query.setInt(3,limit);
            var members = new java.util.ArrayList<Member>();
            try (var rows = query.executeQuery()) {
                while (rows.next()) members.add(new Member(rows.getInt(1),
                        java.util.Objects.toString(rows.getString(2),"玩家"+rows.getInt(1)),
                        java.util.Objects.toString(rows.getString(3),""),rows.getInt(4)));
            }
            return members;
        }
    }

    java.util.List<Member> robotsAfter(Jedis redis,int club, int level,int after) throws SQLException {
        try (var db=database.connect(); var q=db.prepareStatement("""
                SELECT m.player_id,LEFT(u.nick_name,32),LEFT(u.small_icon,255),CAST(u.gender AS SIGNED),MAX(m.robot_status) FROM t_player_group m JOIN t_user u ON u.userid=m.player_id
                WHERE m.group_id=? AND m.player_id>? AND m.is_robot=1 AND u.is_robot=1
                AND COALESCE(m.robot_status,0)<>3 GROUP BY m.player_id,u.nick_name,u.small_icon,u.gender ORDER BY m.player_id LIMIT 64""")) {
            q.setInt(1,club); q.setInt(2,after);
            var ids = new java.util.ArrayList<Member>();
            try (var rs=q.executeQuery()) {
                while (rs.next()) {
                    int uid=rs.getInt(1);
                    if (rs.getInt(5)==1) {
                        redis.hsetnx("ROBOT_STATUS",Integer.toString(uid),"0_"+club+"_1_"+level);
                        redis.hsetnx("TEMP_ROBOT_STATUS",Integer.toString(uid),"0_0");
                    }
                    ids.add(new Member(uid,
                            java.util.Objects.toString(rs.getString(2),"机器人"+uid),java.util.Objects.toString(rs.getString(3),""),rs.getInt(4)));
                }
            }
            return ids;
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

    boolean save(Jedis redis, int uid, Player p, Player before, boolean moneyOnly, int source, String reason,
                 String client, GoldStore.Chips purchase, boolean logDelta) throws SQLException {
        if (balances != null) {
            if (!balances.save(uid, before, p, purchase)) return false;
            balances.recover(this, redis);
        } else {
            if (purchase != null) activity(uid, purchase.activity(), purchase.present(), purchase.bring());
            String key = "MEMDATA_" + uid;
            if (moneyOnly) redis.hset(key, "MONEY", Long.toString(p.money));
            else redis.hset(key, Map.of("MONEY", Long.toString(p.money), "EXP", Integer.toString(p.exp),
                    "SCORE", Integer.toString(p.score), "WIN", Integer.toString(p.wins),
                    "LOST", Integer.toString(p.losses), "CHIPS", Integer.toString(p.chips)));
            players.put(uid, p);
        }
        if (logDelta && before != null) deltas.put(uid, new Delta(p.money - before.money, p.score - before.score));
        logBalance(uid,p,moneyOnly,source,reason,client);
        if (balances == null) update.send(new DataPacket(0x3004).ints(uid));
        return true;
    }

    void logBalance(int uid, Player p, boolean moneyOnly, int source, String reason, String client) {
        if (log.enabled()) {
            Delta delta = deltas.getOrDefault(uid, new Delta(0, 0));
            var packet = new DataPacket(0x3003).ints(uid).number(delta.money).number(p.money)
                    .ints(delta.score, p.score, source).text(reason).text(client);
            if (!moneyOnly) packet.ints(p.chips);
            log.send(packet);
        }
    }

    boolean delete(Jedis redis, int uid) {
        if (!players.containsKey(uid)) return false;
        redis.del("MEMDATA_" + uid);
        players.remove(uid);
        deltas.remove(uid);
        return true;
    }

    void activity(int uid, int activity, int chips, int bring) throws SQLException {
        if (balances != null) {
            try (var db = database.connect()) {
                GoldStore.updateChips(db, new GoldStore.Chips(uid, activity, chips, bring));
            }
            return;
        }
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
