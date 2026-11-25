package com.j.joker.tables.application;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.j.joker.game.tables.domain.FriendRules;
import java.util.*;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class FriendTableHistory {
    private final JdbcTemplate db;
    private final ObjectMapper json;

    public FriendTableHistory(@Qualifier("flexDataSource") DataSource source, ObjectMapper json) {
        db = new JdbcTemplate(source);
        this.json = json;
    }

    void archive(int code, int round, String journal, String outcome) {
        // 调用方持有房间行锁；整局封存、积分和房间状态在同一事务内生效。
        int deal = db.queryForObject("SELECT COALESCE(MAX(deal_no),0)+1 FROM joker_friend_replay WHERE code=? AND round_no=?",
                Integer.class,code,round);
        db.update("INSERT INTO joker_friend_replay(code,round_no,deal_no,journal,outcome) VALUES(?,?,?,?,?)",
                code,round,deal,journal,outcome);
    }

    public Map<String,Object> history(int uid, int level, int before) {
        FriendRules.forLevel(level);
        // 已结束的桌不再修改 changed_at。用房号作并列时间的第二排序键。
        var rooms = db.query("""
                SELECT t.code,t.round_no,t.phase,TIMESTAMPDIFF(SECOND,'1970-01-01',t.changed_at),s.points
                FROM joker_friend_seat s JOIN joker_friend_table t ON t.code=s.code
                WHERE s.uid=? AND s.level=? AND t.phase IN ('FINISHED','CLOSED')
                AND (?=0 OR (t.changed_at,t.code)<(SELECT changed_at,code FROM joker_friend_table WHERE code=?))
                ORDER BY t.changed_at DESC,t.code DESC LIMIT 7""",
                (rs,n) -> Map.of("code",rs.getInt(1),"roundNo",rs.getInt(2),"phase",rs.getString(3),
                        "endedAt",rs.getLong(4),"points",rs.getInt(5)),uid,level,before,before);
        return Map.of("rooms",rooms.subList(0,Math.min(6,rooms.size())),"more",rooms.size()>6);
    }

    public Map<String,Object> rounds(int uid, int code) {
        requireMember(uid,code);
        var rounds=db.query("""
                SELECT r.round_no,r.points,COALESCE(p.deals,0),COALESCE(p.outcome,'SETTLED')
                FROM (
                    SELECT round_no,points FROM joker_friend_round_score WHERE code=? AND uid=?
                    UNION ALL
                    SELECT round_no,0 FROM joker_friend_replay WHERE code=? AND outcome='DISSOLVED'
                ) r LEFT JOIN (
                    SELECT round_no,COUNT(*) deals,MAX(CASE WHEN outcome<>'REDEAL' THEN outcome END) outcome
                    FROM joker_friend_replay WHERE code=? GROUP BY round_no
                ) p ON r.round_no=p.round_no ORDER BY r.round_no""",
                (rs,n) -> Map.of("round",rs.getInt(1),"points",rs.getInt(2),"deals",rs.getInt(3),"outcome",rs.getString(4)),
                code,uid,code,code);
        return Map.of("rounds",rounds);
    }

    private void requireMember(int uid,int code) {
        if (db.queryForList("SELECT 1 FROM joker_friend_seat WHERE uid=? AND code=?",Integer.class,uid,code).isEmpty())
            throw new IllegalArgumentException("只有本桌玩家可以查看战绩");
    }

    public Map<String,Object> replay(int uid,int code,int round,int deal,int step) {
        // 重新发牌的片段也须等本局完成或解散后才能读，防止泄露当前牌局。
        var rows=db.query("""
                SELECT p.journal,p.outcome,s.level FROM joker_friend_replay p
                JOIN joker_friend_seat s ON s.code=p.code AND s.uid=?
                WHERE p.code=? AND p.round_no=? AND p.deal_no=? AND EXISTS (
                  SELECT 1 FROM joker_friend_replay e WHERE e.code=p.code AND e.round_no=p.round_no
                  AND e.outcome IN ('SETTLED','DISSOLVED'))""",
                (rs,n) -> new Replay(rs.getString(1),rs.getString(2),rs.getInt(3)),uid,code,round,deal);
        if (rows.isEmpty()) throw new IllegalArgumentException("本局没有可查看的已封存牌谱");
        var stored=rows.getFirst();
        FriendTables.Journal journal;
        try { journal=json.readValue(stored.journal,FriendTables.Journal.class); }
        catch (JsonProcessingException ex) { throw new IllegalStateException("牌谱读取失败",ex); }
        int total=journal.moves().size();
        if (step == -1) step=total; // 从下一次发牌回退到上一次的最后一手
        if (step<0 || step>total) throw new IllegalArgumentException("牌谱步数无效");
        var rules=FriendRules.forLevel(stored.level);
        var state=rules.start(journal.deck(),Objects.requireNonNullElse(journal.first(),-1),journal.mahjong());
        for (int i=0;i<step;i++) state.apply(journal.moves().get(i));
        var result=new LinkedHashMap<String,Object>();
        result.put("step",step); result.put("steps",total); result.put("phase",state.phase());
        result.put("outcome",stored.outcome);
        var players=db.queryForList("SELECT uid FROM joker_friend_seat WHERE code=? ORDER BY position",Integer.class,code);
        result.put("players",players);
        result.put("board",state.board(players.indexOf(uid)));
        if (step>0) result.put("move",journal.moves().get(step-1));
        var hands = new ArrayList<List<Integer>>();
        for (int i=0;i<rules.seats;i++) hands.add(state.hand(i));
        result.put("hands",hands);
        if ("FINISHED".equals(state.phase())) result.put("points",state.points());
        return result;
    }

    private record Replay(String journal,String outcome,int level) {}
}
