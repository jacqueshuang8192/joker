package com.j.joker.game;

import com.j.joker.game.niuniu.domain.rules.ClubFee;
import java.sql.*;
import java.util.*;

/** 在调用方的 SQL 事务内完成扣费回执、合伙人分成以及盟主收入。 */
final class ClubLedger {
    private ClubLedger() {}
    static int update(Connection db, String sql, Object... args) throws SQLException {
        try (var stmt = db.prepareStatement(sql)) {
            for (int i = 0; i < args.length; i++) stmt.setObject(i+1,args[i]);
            return stmt.executeUpdate();
        }
    }
    static int owner(Connection db, int club) throws SQLException {
        try (var q = db.prepareStatement("SELECT ower_id FROM t_group_player WHERE group_id=? FOR UPDATE")) {
            q.setInt(1,club);
            try (var rs = q.executeQuery()) {
                if (!rs.next() || rs.getInt(1) <= 0) throw new SQLException("缺少俱乐部收款账户");
                return rs.getInt(1);
            }
        }
    }
    private record Member(int parent, int role, int percent) {}
    private static Member member(Connection db, int club, int uid) throws SQLException {
        try (var q = db.prepareStatement("SELECT up_player_id,player_type,bonus FROM t_player_group WHERE group_id=? AND player_id=?")) {
            q.setInt(1,club);
            q.setInt(2,uid);
            try (var rs = q.executeQuery()) {
                if (!rs.next()) return new Member(0,0,0);
                return new Member(rs.getInt(1),rs.getInt(2),Math.clamp(rs.getInt(3),0,100));
            }
        }
    }
    private static void credit(Connection db, int club, int activity, int level, int uid, int recipient,
                               int contribution, int income) throws SQLException {
        if (income <= 0) return;
        if (update(db,"""
                UPDATE t_player_group SET repository_point=COALESCE(repository_point,0)+?,
                xiaohao_count=COALESCE(xiaohao_count,0)+?,xiaohao_today=COALESCE(xiaohao_today,0)+?
                WHERE group_id=? AND player_id=?""",income,income,income,club,recipient) != 1)
            throw new SQLException("俱乐部收款成员不唯一");
        update(db,"""
                INSERT INTO t_group_xiaohao_history(group_id,hehuoren_id,player_id,profit,profit_time,profit_count,game_level,activity_id)
                VALUES(?,?,?,?,NOW(),?,?,?)""",club,recipient,uid,income,contribution,level,activity);
        if (update(db,"""
                UPDATE t_group_xiaohao_day_history SET profit=COALESCE(profit,0)+?,dayingjia_count=COALESCE(dayingjia_count,0)+1
                WHERE group_id=? AND hehuoren_id=? AND day_time>=CURRENT_DATE AND day_time<CURRENT_DATE+INTERVAL 1 DAY""",income,club,recipient)==0)
            update(db,"INSERT INTO t_group_xiaohao_day_history(group_id,hehuoren_id,profit,day_time,dayingjia_count,player_count) VALUES(?,?,?,NOW(),1,0)",club,recipient,income);
    }
    static void post(Connection db, int club, int activity, int round, int level, ClubFee.Plan plan,
                     Map<Integer,Long> balancesAfter) throws SQLException {
        int owner = owner(db,club);
        long total = plan.total();
        update(db,"INSERT INTO joker_douniu_club_bill(activity_id,round_index,club_id,fee_total) VALUES(?,?,?,?)",activity,round,club,total);
        long attributed = plan.attribution().values().stream().mapToLong(Integer::longValue).sum();
        if (attributed != plan.charges().values().stream().mapToLong(ClubFee.Charge::base).sum())
            throw new SQLException("俱乐部分成总额不符");
        for (var e : plan.charges().entrySet()) {
            int uid = e.getKey();
            var c = e.getValue();
            if (c.base()<0 || c.additional()<0 || !balancesAfter.containsKey(uid)) throw new SQLException("费用明细无效");
            update(db,"INSERT INTO joker_douniu_club_debit VALUES(?,?,?,?,?,?,?)",activity,round,uid,c.base(),c.additional(),
                    balancesAfter.get(uid),round==0 ? 0 : 1);
        }
        distribute(db, club, activity, level, owner, plan);
    }

    static void distribute(Connection db, int club, int activity, int level, int owner, ClubFee.Plan plan) throws SQLException {
        long total = plan.total(), ownerIncome = 0;
        for (var item : plan.charges().entrySet()) {
            var c = item.getValue();
            credit(db,club,activity,level,item.getKey(),owner,c.additional(),c.additional());
            ownerIncome += c.additional();
        }
        for (var e : plan.attribution().entrySet()) {
            int uid = e.getKey(), contribution=e.getValue(), left=contribution;
            if (left<0) throw new SQLException("贡献额无效");
            if (left==0) continue;
            int current=uid, previous=0;
            var seen = new HashSet<Integer>();
            var m=member(db,club,current);
            if (m.role()!=2) current=m.parent();
            while (current>0 && current!=owner && seen.add(current) && left>0) {
                m=member(db,club,current);
                if (m.role()!=2) break;
                int percent=Math.max(previous,m.percent());
                int income=(int)((long)contribution*(percent-previous)/100);
                credit(db,club,activity,level,uid,current,contribution,income);
                left-=income;
                previous=percent;
                current=m.parent();
            }
            credit(db,club,activity,level,uid,owner,contribution,left);
            ownerIncome+=left;
        }
        update(db,"""
                UPDATE t_group_player SET choushui_count=COALESCE(choushui_count,0)+?,profit_count=COALESCE(profit_count,0)+?,
                profit_club_count=COALESCE(profit_club_count,0)+?,point_pool=COALESCE(point_pool,0)-? WHERE group_id=?""",
                total,total,ownerIncome,total,club);
    }
}
