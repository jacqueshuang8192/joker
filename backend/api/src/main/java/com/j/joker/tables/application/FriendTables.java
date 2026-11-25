package com.j.joker.tables.application;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.j.joker.game.tables.domain.FriendRound;
import com.j.joker.game.mahjong.domain.HongzhongOptions;
import com.j.joker.game.tables.domain.FriendRules;
import java.security.SecureRandom;
import java.util.*;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

@Service
@org.springframework.boot.autoconfigure.condition.ConditionalOnProperty(name="JOKER_PURE_JAVA",havingValue="true")
public class FriendTables {
    private static final int WAITING_MINUTES = 30;
    // V13 建房时由数据库以本地时间填写 changed_at；第一次座位变动起 save() 使用 UTC。
    private static final String WAITING_DUE = """
            (t.phase='WAITING' AND (
                (t.revision=0 AND t.changed_at<=CURRENT_TIMESTAMP(3)-INTERVAL %1$d MINUTE)
                OR (t.revision>0 AND t.changed_at<=UTC_TIMESTAMP(3)-INTERVAL %1$d MINUTE)))""".formatted(WAITING_MINUTES);
    private static final String PHASE_DUE = WAITING_DUE + """
             OR (t.phase='ACTIVE' AND t.changed_at<=UTC_TIMESTAMP(3)-INTERVAL 45 SECOND)
             OR (t.phase='INTERMISSION' AND t.changed_at<=UTC_TIMESTAMP(3)-INTERVAL 15 MINUTE)""";
    private final JdbcTemplate db;
    private final TransactionTemplate tx;
    private final FriendTableHistory history;
    private final ObjectMapper json;
    private final SecureRandom random = new SecureRandom();

    public FriendTables(@Qualifier("flexDataSource") DataSource source,
                        @Qualifier("transactionManager") PlatformTransactionManager manager, ObjectMapper json, FriendTableHistory history) {
        this.history = history;
        db = new JdbcTemplate(source);
        tx = new TransactionTemplate(manager);
        this.json = json;
    }

    record Journal(List<Integer> deck, List<FriendRound.Move> moves, Integer first,HongzhongOptions mahjong) {
        Journal { if (mahjong==null) mahjong=HongzhongOptions.DEFAULT; }
        FriendRound restore(FriendRules rules) {
            if (deck.isEmpty()) return null;
            var round = rules.start(deck,first == null ? -1 : first,mahjong);
            moves.forEach(round::apply);
            return round;
        }
    }
    private record Room(int code, FriendRules rules, int owner, int version, String phase, Journal journal,
                        boolean timedOut, int number, int limit, int next, boolean voting, boolean voteExpired) {}
    private record Seat(int uid, Integer points, boolean ready, boolean voted) {}
    private record Table(Room room, List<Seat> seats, FriendRound round) {
        boolean hasActiveSeat(int uid) {
            return !room.phase.equals("CLOSED") && !room.phase.equals("FINISHED") && seatOf(uid)>=0;
        }
        int seatOf(int uid) {
            for (int i = 0; i < seats.size(); i++) if (seats.get(i).uid == uid) return i;
            return -1;
        }
    }

    private String encode(Journal value) {
        try { return json.writeValueAsString(value); }
        catch (JsonProcessingException failure) { throw new IllegalStateException("牌局保存失败", failure); }
    }
    private Journal decode(String value) {
        try { return json.readValue(value,Journal.class); }
        catch (JsonProcessingException failure) { throw new IllegalStateException("牌局存档损坏", failure); }
    }

    public Map<String,Object> create(int uid, int level, String key,int limit,HongzhongOptions options) {
        var rules = FriendRules.forLevel(level);
        if (rules!=FriendRules.HONGZHONG && !options.equals(HongzhongOptions.DEFAULT))
            throw new IllegalArgumentException("此玩法没有红中或抓鸟选项");
        if (limit != 1 && limit != 10 && limit != 20) throw new IllegalArgumentException("请选择 1、10 或 20 局");
        if (!key.matches("[a-zA-Z0-9_-]{8,64}")) throw new IllegalArgumentException("开桌请求编号无效");
        // 唯一约束仲裁来自多台 API 的并发开桌。重复请求在新事务中读取已提交回执。
        for (int retry=0; retry<4; retry++) {
            try {
                return tx.execute(status -> {
                    var prior = db.queryForList("SELECT code FROM joker_friend_table WHERE owner_uid=? AND create_key=?",
                            Integer.class,uid,key);
                    if (!prior.isEmpty()) {
                        var table = load(prior.getFirst());
                        if (table.room.rules != rules || table.room.limit != limit || !table.room.journal.mahjong.equals(options)) throw new IllegalArgumentException("此请求编号已用于其他开桌配置");
                        return view(expireWaiting(table),uid);
                    }
                    var active = active(uid,rules);
                    if (!active.isEmpty()) {
                        var table = expireWaiting(load(active.getFirst()));
                        if (table.hasActiveSeat(uid))
                            return view(table,uid);
                    }
                    int code = random.nextInt(10_000_000,100_000_000);
                    db.update("INSERT INTO joker_friend_table(code,level,owner_uid,create_key,journal,round_limit) VALUES(?,?,?,?,?,?)",
                            code,level,uid,key,encode(new Journal(List.of(),List.of(),-1,options)),limit);
                    addSeat(code,uid,rules,0);
                    return view(load(code),uid);
                });
            } catch (DuplicateKeyException collision) {
                if (retry == 3) throw new IllegalArgumentException("开桌繁忙，请重试");
            }
        }
        throw new IllegalStateException();
    }
    private List<Integer> active(int uid, FriendRules rules) {
        return db.queryForList("SELECT code FROM joker_friend_seat WHERE active_uid=? AND level=?",
                Integer.class,uid,rules.level);
    }
    public Map<String,Object> current(int uid, int level) {
        var rules=FriendRules.forLevel(level);
        return tx.execute(status -> {
            var codes=active(uid,rules);
            if (!codes.isEmpty()) {
                var table = load(codes.getFirst());
                if (table.hasActiveSeat(uid)) {
                    table = advanceTimeout(table);
                    if (table.hasActiveSeat(uid)) return view(table,uid);
                }
            }
            return rules.terms.isEmpty() ? Map.of() : Map.of("terms",rules.terms);
        });
    }
    private Table load(int code) {
        var rooms = db.query("""
                SELECT t.*, (%s) AS expired, t.vote_until<=UTC_TIMESTAMP(3) AS vote_expired
                FROM joker_friend_table t WHERE t.code=? FOR UPDATE
                """.formatted(PHASE_DUE),(rs,n) -> new Room(code,FriendRules.forLevel(rs.getInt("level")),rs.getInt("owner_uid"),
                rs.getInt("revision"),rs.getString("phase"),decode(rs.getString("journal")),rs.getBoolean("expired"),
                rs.getInt("round_no"),rs.getInt("round_limit"),rs.getInt("next_seat"),rs.getTimestamp("vote_until")!=null,
                rs.getBoolean("vote_expired")),code);
        if (rooms.isEmpty()) throw new IllegalArgumentException("找不到此房号");
        var room = rooms.getFirst();
        var seats = db.query("SELECT uid,points,ready_next,dissolve_yes FROM joker_friend_seat WHERE code=? ORDER BY position FOR UPDATE",
                (rs,n) -> new Seat(rs.getInt(1),rs.getObject(2,Integer.class),rs.getBoolean(3),rs.getBoolean(4)),code);
        return new Table(room,seats,room.journal.restore(room.rules));
    }
    private void addSeat(int code, int uid, FriendRules rules, int position) {
        db.update("INSERT INTO joker_friend_seat(code,uid,level,position,active_uid) VALUES(?,?,?,?,?)",
                code,uid,rules.level,position,uid);
    }
    public Map<String,Object> join(int uid, int level, int code) {
        // 允许玩家直接加入新房。先释放其过期旧座位，避免同时持有两张房间的锁。
        var expired = db.queryForList("""
                SELECT t.code FROM joker_friend_seat s JOIN joker_friend_table t ON t.code=s.code
                WHERE s.active_uid=? AND s.level=? AND s.code<>? AND %s""".formatted(WAITING_DUE),
                Integer.class,uid,level,code);
        for (int oldCode : expired) tx.executeWithoutResult(status -> expireWaiting(load(oldCode)));

        var result = tx.execute(status -> {
            var table = expireWaiting(load(code));
            var room = table.room;
            if (room.rules.level != level) throw new IllegalArgumentException("房号属于其他玩法");
            if (table.seatOf(uid) >= 0) return view(table,uid);
            if (!room.phase.equals("WAITING")) return null;
            int position = db.queryForObject("SELECT COALESCE(MAX(position),-1)+1 FROM joker_friend_seat WHERE code=?",Integer.class,code);
            try { addSeat(code,uid,room.rules,position); }
            catch (DuplicateKeyException occupied) { throw new IllegalArgumentException("请先返回本场次已有的牌桌"); }
            if (table.seats.size()+1 == room.rules.seats) save(room,deal(room),"ACTIVE");
            else save(room,room.journal,"WAITING");
            return view(load(code),uid);
        });
        // 先提交到期关桌和座位释放，再向迟到的非成员返回拒绝。
        if (result == null) throw new IllegalArgumentException("牌桌已经开局或关闭");
        return result;
    }
    private Journal deal(Room room) {
        var options=room.journal.mahjong;
        return new Journal(room.rules.deck(random,options),new ArrayList<>(),room.next,options);
    }
    private void save(Room room, Journal journal, String phase) {
        db.update("""
                UPDATE joker_friend_table SET journal=?,phase=?,revision=revision+1,changed_at=UTC_TIMESTAMP(3)
                WHERE code=?
                """,encode(journal),phase,room.code);
    }
    private int member(Table table,int uid) {
        int seat = table.seatOf(uid);
        if (seat < 0) throw new IllegalArgumentException("只有本桌玩家可以查看或操作");
        return seat;
    }

    public Map<String,Object> state(int uid, int code,int knownVersion) {
        // 多数轮询只读版本号；只有新局面或到期操作才需锁桌并重建牌局。
        if (knownVersion >= 0 && !db.queryForList("""
                SELECT 1 FROM joker_friend_table t JOIN joker_friend_seat s ON s.code=t.code
                WHERE t.code=? AND s.uid=? AND t.revision=?
                AND (t.vote_until IS NULL OR t.vote_until>UTC_TIMESTAMP(3))
                AND NOT (%s)
                """.formatted(PHASE_DUE),Integer.class,code,uid,knownVersion).isEmpty()) return Map.of("unchanged",true);
        return tx.execute(status -> {
            var table = load(code);
            member(table,uid);
            return view(advanceTimeout(table),uid);
        });
    }
    private Table expireWaiting(Table table) {
        if (table.room.phase.equals("WAITING") && table.room.timedOut) {
            closeTable(table,"CLOSED");
            return load(table.room.code);
        }
        return table;
    }

    private Table advanceTimeout(Table table) {
        if (table.room.phase.equals("WAITING")) return expireWaiting(table);
        if (table.room.voteExpired) {
            clearVote(table.room.code);
            table = load(table.room.code);
        }
        if (table.room.phase.equals("INTERMISSION") && table.room.timedOut) {
            closeTable(table,"FINISHED");
            return load(table.room.code);
        }
        if (table.room.phase.equals("ACTIVE") && table.room.timedOut) {
            apply(table, table.round.automatic(table.round.currentSeat()));
            return load(table.room.code);
        }
        return table;
    }

    @org.springframework.scheduling.annotation.Scheduled(fixedDelay=2000)
    public void advanceIdleTables() {
        var due = db.queryForList("""
                SELECT t.code FROM joker_friend_table t WHERE (%s) OR t.vote_until<=UTC_TIMESTAMP(3)
                ORDER BY t.changed_at,t.code LIMIT 128""".formatted(PHASE_DUE),Integer.class);
        for (int code : due) {
            try {
                // 锁内重查时限。玩家请求、多台 API 以及重启后的扫描可以安全交错。
                tx.executeWithoutResult(status -> advanceTimeout(load(code)));
            } catch (RuntimeException failure) {
                org.slf4j.LoggerFactory.getLogger(FriendTables.class).error("好友桌 {} 超时处理失败",code,failure);
            }
        }
    }

    private void clearVote(int code) {
        db.update("UPDATE joker_friend_seat SET dissolve_yes=FALSE WHERE code=?",code);
        db.update("UPDATE joker_friend_table SET vote_until=NULL,revision=revision+1 WHERE code=?",code);
    }

    private void closeTable(Table table, String phase) {
        db.update("UPDATE joker_friend_seat SET active_uid=NULL WHERE code=?",table.room.code);
        save(table.room,table.room.journal,phase);
    }

    private void vote(Table table, int uid, boolean agree) {
        var room = table.room;
        if (!room.phase.equals("ACTIVE")) throw new IllegalArgumentException("只有进行中的牌局可以投票");
        if (!agree) {
            if (room.voting) clearVote(room.code);
            return;
        }
        if (table.seats.get(table.seatOf(uid)).voted) return;
        db.update("UPDATE joker_friend_seat SET dissolve_yes=TRUE WHERE code=? AND uid=?",room.code,uid);
        // 投票不改变出牌时钟；普通出牌也不延长两分钟的投票有效期。
        db.update("""
                UPDATE joker_friend_table SET vote_until=COALESCE(vote_until,UTC_TIMESTAMP(3)+INTERVAL 2 MINUTE),
                revision=revision+1 WHERE code=?""",room.code);
        if (table.seats.stream().filter(Seat::voted).count()+1 == table.seats.size()) {
            history.archive(room.code,room.number,encode(room.journal),"DISSOLVED");
            clearVote(room.code);
            closeTable(table,"CLOSED");
        }
    }

    public Map<String,Object> act(int uid,int code,int version,String action,List<Integer> cards) {
        return tx.execute(status -> {
            var table = load(code);
            int seat = member(table,uid);
            table = advanceTimeout(table);
            var room = table.room;
            // 旧版本的重复点击或响应丢失后重试，只返回当前视图。
            if (room.version != version) return view(table,uid);
            if (action.equals("dissolveYes") || action.equals("dissolveNo")) {
                vote(table,uid,action.equals("dissolveYes"));
                return view(load(code),uid);
            }
            if (room.phase.equals("INTERMISSION")) {
                if (action.equals("leave")) {
                    closeTable(table,"FINISHED");
                } else if (action.equals("next")) {
                    if (table.seats.get(seat).ready) return view(table,uid);
                    db.update("UPDATE joker_friend_seat SET ready_next=1 WHERE code=? AND uid=?",code,uid);
                    long othersReady = table.seats.stream().filter(Seat::ready).count();
                    if (othersReady+1 == room.rules.seats) {
                        db.update("UPDATE joker_friend_seat SET ready_next=0 WHERE code=?",code);
                        db.update("UPDATE joker_friend_table SET round_no=round_no+1 WHERE code=?",code);
                        save(room,deal(room),"ACTIVE");
                    } else save(room,room.journal,"INTERMISSION");
                } else throw new IllegalArgumentException("请确认下一局或结束此桌");
                return view(load(code),uid);
            }
            if (action.equals("leave") && room.phase.equals("WAITING")) {
                if (uid == room.owner) {
                    db.update("UPDATE joker_friend_seat SET active_uid=NULL WHERE code=?",code);
                    save(room,room.journal,"CLOSED");
                } else {
                    db.update("DELETE FROM joker_friend_seat WHERE code=? AND uid=?",code,uid);
                    save(room,room.journal,"WAITING");
                }
                return Map.of();
            }
            if (!room.phase.equals("ACTIVE") || table.round.currentSeat() != seat)
                throw new IllegalArgumentException("尚未轮到此玩家");
            if (!action.equals("auto") && !table.round.actions(seat).contains(action))
                throw new IllegalArgumentException("当前不能执行此操作");
            var move = action.equals("auto") ? table.round.automatic(seat) : new FriendRound.Move(seat,action,cards);
            apply(table,move);
            return view(load(code),uid);
        });
    }

    private void apply(Table table, FriendRound.Move move) {
        var round = table.round;
        round.apply(move);
        var room = table.room;
        var journal = room.journal;
        journal.moves.add(move);
        if (round.phase().equals("REDEAL")) {
            history.archive(room.code,room.number,encode(journal),"REDEAL");
            save(room,deal(room),"ACTIVE");
            return;
        }
        boolean done = round.phase().equals("FINISHED");
        String phase = "ACTIVE";
        if (done) {
            history.archive(room.code,room.number,encode(journal),"SETTLED");
            if (room.voting) clearVote(room.code);
            phase = room.number < room.limit ? "INTERMISSION" : "FINISHED";
            var points = round.points();
            for (int i=0; i<table.seats.size(); i++) {
                int uid = table.seats.get(i).uid;
                db.update("INSERT INTO joker_friend_round_score(code,round_no,uid,points) VALUES(?,?,?,?)",
                        room.code,room.number,uid,points.get(i));
                db.update("UPDATE joker_friend_seat SET points=COALESCE(points,0)+?,ready_next=0 WHERE code=? AND uid=?",
                        points.get(i),room.code,uid);
            }
            if (phase.equals("FINISHED")) db.update("UPDATE joker_friend_seat SET active_uid=NULL WHERE code=?",room.code);
            db.update("UPDATE joker_friend_table SET next_seat=? WHERE code=?",round.nextStarter(random),room.code);
        }
        save(room,journal,phase);
    }

    private Map<String,Object> view(Table table,int uid) {
        int seat = member(table,uid);
        var room = table.room;
        var round = table.round;
        var result = new LinkedHashMap<String,Object>();
        result.put("code",room.code); result.put("level",room.rules.level); result.put("version",room.version);
        result.put("seat",seat); result.put("capacity",room.rules.seats);
        result.put("phase",room.phase.equals("ACTIVE") ? round.phase() : room.phase);
        if (room.rules==FriendRules.HONGZHONG) result.put("mahjong",room.journal.mahjong);
        result.put("roundNo",room.number); result.put("roundLimit",room.limit);
        if(!room.rules.terms.isEmpty()) result.put("terms",room.rules.terms);
        result.put("players",table.seats.stream().map(Seat::uid).toList());
        if (room.phase.equals("WAITING")) result.put("waitingMinutes",WAITING_MINUTES);
        if (room.voting) {
            result.put("voteCount",table.seats.stream().filter(Seat::voted).count());
            result.put("voted",table.seats.get(seat).voted);
        }
        if ("CLOSED".equals(room.phase)) {
            result.put("points",table.seats.stream().map(s -> Objects.requireNonNullElse(s.points,0)).toList());
            return result;
        }
        if (round != null) {
            result.put("turn",round.currentSeat()); result.put("hand",round.hand(seat));
            result.put("counts",java.util.stream.IntStream.range(0,room.rules.seats).map(i -> round.hand(i).size()).toArray());
            result.put("board",round.board(seat)); result.put("actions",round.actions(seat));
            if (room.phase.equals("FINISHED") || room.phase.equals("INTERMISSION")) {
                result.put("points",table.seats.stream().map(Seat::points).toList());
                result.put("lastPoints",round.points());
                result.put("ready",table.seats.get(seat).ready);
                result.put("readyCount",table.seats.stream().filter(Seat::ready).count());
            }
        }
        return result;
    }
}
