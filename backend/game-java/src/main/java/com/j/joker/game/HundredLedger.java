package com.j.joker.game;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.j.joker.game.hundred.domain.HundredExposure;
import com.j.joker.game.hundred.domain.Baccarat;
import com.j.joker.game.hundred.domain.HundredSettlement;
import com.j.joker.game.rooms.infrastructure.RedisRoomAssignments;
import io.netty.buffer.ByteBuf;
import redis.clients.jedis.Jedis;

import java.io.IOException;
import java.security.SecureRandom;
import java.sql.*;
import java.util.*;
import static com.j.joker.game.ClubLedger.update;
import static com.j.joker.game.hundred.domain.HundredSettlement.*;

/** data 的单写入线程持有钱包。锁桌后修改申请队列、订单、余额和回执。 */
final class HundredLedger {
    private static final ObjectMapper JSON = new ObjectMapper();
    private static final SecureRandom RANDOM = new SecureRandom();
    private final GameSettings.Database database;
    private final PlayerBalanceStore wallets;
    private record Room(int tid,int level,int seats,int minimum,int maxRounds,int limit,int seconds,String roundId) {}
    private record Round(String id,int tid,long deadline,int limit,List<Banker> bankers,List<Integer> cards,
                         List<Receipt> receipt,long closedAt) {}
    private record Receipt(int uid,int chips,long turnBlc) {}
    private record Order(String round,String request,int area,int chips) {}
    private record QueueEntry(int uid,int served,boolean retiring) {}
    private record Hold(String round,int before) {}

    HundredLedger(GameSettings.Database database,PlayerBalanceStore wallets) {
        this.database=database;
        this.wallets=wallets;
    }

    private static <T> T json(String value, TypeReference<T> type) throws SQLException {
        try { return JSON.readValue(value,type); }
        catch (IOException e) { throw new SQLException("百人场记录损坏",e); }
    }

    private static String encode(Object value) throws SQLException {
        try { return JSON.writeValueAsString(value); }
        catch (IOException e) { throw new SQLException("百人场记录无法编码",e); }
    }

    private static PreparedStatement query(Connection db,String sql,Object... args) throws SQLException {
        var q=db.prepareStatement(sql);
        try {
            for (int i=0;i<args.length;i++) q.setObject(i+1,args[i]);
            return q;
        } catch (SQLException failure) { q.close(); throw failure; }
    }

    private static Room lockRoom(Connection db,int tid) throws SQLException {
        try (var q=query(db,"SELECT level_id,banker_seats,min_capital,max_rounds,area_limit,bet_seconds,round_id FROM joker_hundred_room WHERE tid=? FOR UPDATE",tid);
             var r=q.executeQuery()) {
            if (!r.next()) throw new IllegalArgumentException("百人桌不存在");
            var room=new Room(tid,r.getInt(1),r.getInt(2),r.getInt(3),r.getInt(4),r.getInt(5),r.getInt(6),r.getString(7));
            if ((room.level!=101 && room.level!=102 && room.level!=Baccarat.LEVEL) || room.seats<1 || room.seats>6 || room.minimum<=0 ||
                    room.maxRounds<1 || room.limit<100 || room.seconds<1 || room.seconds>3600)
                throw new SQLException("百人桌配置无效 " + tid);
            return room;
        }
    }

    private static Round round(Connection db,String id) throws SQLException {
        if (id==null) return null;
        try (var q=query(db,"SELECT tid,deadline,area_limit,bankers,cards,receipt,closed_at FROM joker_hundred_round WHERE id=?",id);
             var r=q.executeQuery()) {
            if (!r.next()) throw new IllegalArgumentException("找不到该局");
            return new Round(id,r.getInt(1),r.getLong(2),r.getInt(3),json(r.getString(4),new TypeReference<>(){}),
                    json(r.getString(5),new TypeReference<>(){}),r.getString(6)==null?null:json(r.getString(6),new TypeReference<>(){}),r.getLong(7));
        }
    }

    private static List<QueueEntry> queue(Connection db,int tid) throws SQLException {
        try (var q=query(db,"SELECT uid,served,retiring FROM joker_hundred_banker WHERE tid=? ORDER BY seq",tid);
             var r=q.executeQuery()) {
            var entries=new ArrayList<QueueEntry>();
            while(r.next()) entries.add(new QueueEntry(r.getInt(1),r.getInt(2),r.getBoolean(3)));
            return entries;
        }
    }

    private static Hold hold(Connection db,int uid) throws SQLException {
        try (var q=query(db,"SELECT round_id,before_chips FROM joker_douniu_side_hold WHERE uid=?",uid);var r=q.executeQuery()) {
            return r.next()?new Hold(r.getString(1),r.getInt(2)):null;
        }
    }

    boolean holds(int uid) throws SQLException {
        try (var db=database.connect();var q=query(db,"SELECT 1 FROM joker_douniu_side_hold h JOIN joker_hundred_round r ON r.id=h.round_id WHERE h.uid=?",uid);
             var r=q.executeQuery()) { return r.next(); }
    }

    private int available(Connection db,Jedis redis,int uid,String id) throws SQLException {
        var player=wallets.read(db,uid,true);
        var occupied=hold(db,uid);
        if (player==null || RedisRoomAssignments.read(redis,uid)!=null || (occupied!=null && !occupied.round.equals(id))) return -1;
        String cached=redis.hget("MEMDATA_"+uid,"CHIPS");
        if (cached!=null && Integer.parseInt(cached)!=player.chips()) throw new SQLException("玩家筹码缓存与分表不一致 "+uid);
        return player.chips();
    }

    private static void reserve(Connection db,int uid,String round,int balance) throws SQLException {
        var held=hold(db,uid);
        if (held==null) update(db,"INSERT INTO joker_douniu_side_hold(uid,round_id,before_chips) VALUES(?,?,?)",uid,round,balance);
        else if (!held.round.equals(round) || held.before!=balance) throw new IllegalArgumentException("筹码已由其他牌局占用");
    }

    private Round start(Connection db,Jedis redis,Room room,long now) throws SQLException {
        String id=UUID.randomUUID().toString();
        var bankers=new ArrayList<Banker>();
        for (var entry:queue(db,room.tid)) {
            int chips=available(db,redis,entry.uid,id);
            if (chips<room.minimum || entry.served>=room.maxRounds || entry.retiring) {
                update(db,"DELETE FROM joker_hundred_banker WHERE tid=? AND uid=?",room.tid,entry.uid);
                continue;
            }
            reserve(db,entry.uid,id,chips);
            bankers.add(new Banker(entry.uid,chips));
            if (bankers.size()==room.seats) break;
        }
        if (bankers.isEmpty()) return null;
        var deck=new ArrayList<Integer>(52);
        for(int suit=0;suit<4;suit++) for(int pip=1;pip<=13;pip++) deck.add(suit*16+pip);
        Collections.shuffle(deck,RANDOM);
        var result=new Round(id,room.tid,now+1000L*room.seconds,room.limit,bankers,
                List.copyOf(deck.subList(0,HundredSettlement.drawCount(room.level))),null,0);
        update(db,"INSERT INTO joker_hundred_round(id,tid,deadline,area_limit,bankers,cards) VALUES(?,?,?,?,?,?)",
                id,room.tid,result.deadline,result.limit,encode(bankers),encode(result.cards));
        update(db,"UPDATE joker_hundred_room SET round_id=? WHERE tid=?",id,room.tid);
        return result;
    }

    private static List<Bet> bets(Connection db,String round) throws SQLException {
        try (var q=query(db,"SELECT uid,area,SUM(chips) FROM joker_hundred_order WHERE round_id=? GROUP BY uid,area",round);
             var r=q.executeQuery()) {
            var result=new ArrayList<Bet>();
            while(r.next()) result.add(new Bet(r.getInt(1),r.getInt(2),r.getInt(3)));
            return result;
        }
    }

    private void close(Connection db,Room room,Round r,long now) throws SQLException {
        var cards=r.cards;
        var bets=bets(db,r.id);
        var net=HundredSettlement.settle(room.level,r.bankers,bets,cards);
        var receipts=new ArrayList<Receipt>();
        for (var entry:new TreeMap<>(net).entrySet()) {
            int uid=entry.getKey();
            var h=hold(db,uid);
            if (h==null || !h.round.equals(r.id)) throw new SQLException("百人场筹码占用记录缺失 "+uid);
            int after=Math.toIntExact(h.before+entry.getValue());
            if (after<0) throw new SQLException("百人场余额不足 "+uid);
            wallets.settleChips(db,uid,h.before,after);
            receipts.add(new Receipt(uid,after,entry.getValue()));
        }
        update(db,"UPDATE joker_hundred_round SET receipt=?,closed_at=? WHERE id=?",encode(receipts),now,r.id);
        update(db,"DELETE FROM joker_douniu_side_hold WHERE round_id=?",r.id);
        for (var b:r.bankers) {
            update(db,"UPDATE joker_hundred_banker SET served=served+1 WHERE tid=? AND uid=?",room.tid,b.uid());
        }
        update(db,"DELETE FROM joker_hundred_banker WHERE tid=? AND (retiring OR served>=?)",room.tid,room.maxRounds);
    }

    void tick(Jedis redis) throws SQLException {
        try (var db=database.connect();var list=query(db,"SELECT tid FROM joker_hundred_room ORDER BY tid");var rows=list.executeQuery()) {
            var ids=new ArrayList<Integer>();
            while (rows.next()) ids.add(rows.getInt(1));
            db.setAutoCommit(false);
            for (int tid:ids) {
                try {
                    Room room=lockRoom(db,tid);
                    Round r=round(db,room.roundId);
                    long now=System.currentTimeMillis();
                    if (r!=null && r.receipt==null && now>=r.deadline) close(db,room,r,now);
                    else if (r==null || (r.receipt!=null && now-r.closedAt>=10000)) start(db,redis,room,now);
                    db.commit();
                } catch (Exception e) {
                    db.rollback();
                    org.slf4j.LoggerFactory.getLogger(HundredLedger.class).warn("百人桌 {} 推进失败，将重试",tid,e);
                }
            }
        }
    }

    private void accept(Connection db,Jedis redis,int uid,Room room,Round r,Order order) throws SQLException {
        if (r==null || !r.id.equals(order.round) || order.chips<=0 || order.chips%100!=0 ||
                order.area<1 || order.area>HundredSettlement.areas(room.level) || !order.request.matches("[a-zA-Z0-9_-]{1,64}"))
            throw new IllegalArgumentException("订单参数或牌局不符");
        if (r.receipt!=null || System.currentTimeMillis()>=r.deadline) throw new IllegalArgumentException("该局已经封盘");
        if (r.bankers.stream().anyMatch(b->b.uid()==uid)) throw new IllegalArgumentException("庄家不能下注");
        int balance=available(db,redis,uid,r.id);
        if (balance<0) throw new IllegalArgumentException("钱包不可用或正在其他牌桌");
        long[] totals=new long[HundredSettlement.areas(room.level)],own=new long[totals.length];
        var participants=new HashSet<Integer>();
        for (var bet:bets(db,r.id)) {
            totals[bet.area()-1]+=bet.chips();
            if (bet.uid()==uid) own[bet.area()-1]+=bet.chips();
            participants.add(bet.uid());
        }
        participants.add(uid);
        if (participants.size()+r.bankers.size()>100) throw new IllegalArgumentException("本局人数已满");
        int i=order.area-1;
        own[i]+=order.chips;
        totals[i]+=order.chips;
        if (totals[i]>r.limit) throw new IllegalArgumentException("超过本区限额");
        HundredExposure.check(room.level,r.bankers,balance,own,totals);
        reserve(db,uid,r.id,balance);
        update(db,"INSERT INTO joker_hundred_order(round_id,uid,request_id,area,chips) VALUES(?,?,?,?,?)",r.id,uid,order.request,i+1,order.chips);
    }

    private static boolean duplicate(Connection db,int uid,int tid,Order order) throws SQLException {
        try (var q=query(db,"SELECT r.tid,o.area,o.chips FROM joker_hundred_order o JOIN joker_hundred_round r ON o.round_id=r.id WHERE o.round_id=? AND uid=? AND request_id=?",order.round,uid,order.request);
             var row=q.executeQuery()) {
            if (!row.next()) return false;
            if(row.getInt(1)!=tid || row.getInt(2)!=order.area || row.getInt(3)!=order.chips)
                throw new IllegalArgumentException("订单编号与已接订单冲突");
            return true;
        }
    }

    /** 最近二十局的公开结果和本人的结算。榜单按每人实际下单额和赢局数汇总。 */
    private Map<String,Object> records(Connection db,Room room,int viewer) throws SQLException {
        var rounds=new ArrayList<Map<String,Object>>();
        var totals=new TreeMap<Integer,Long>();
        var wins=new HashMap<Integer,Integer>();
        try(var q=query(db,"SELECT id,cards,receipt,closed_at FROM joker_hundred_round WHERE tid=? AND closed_at IS NOT NULL ORDER BY closed_at DESC LIMIT 20",room.tid);
            var rows=q.executeQuery()) {
            while(rows.next()) {
                String id=rows.getString(1);
                List<Integer> cards=json(rows.getString(2),new TypeReference<>(){});
                List<Receipt> receipts=json(rows.getString(3),new TypeReference<>(){});
                var item=new LinkedHashMap<String,Object>();
                item.put("round",id);item.put("closedAt",rows.getLong(4));
                if(room.level==Baccarat.LEVEL) {
                    var deal=Baccarat.open(cards);
                    item.put("cards",java.util.stream.Stream.concat(deal.house().stream(),deal.player().stream()).toList());
                    item.put("bankerPoints",deal.housePoints()); item.put("playerPoints",deal.playerPoints());
                } else item.put("cards",cards);
                for(var r:receipts) {
                    if(r.uid==viewer) {item.put("delta",r.turnBlc);item.put("after",r.chips);}
                    wins.merge(r.uid,r.turnBlc>0?1:0,Integer::sum);
                }
                for(var bet:bets(db,id)) totals.merge(bet.uid(),(long)bet.chips(),Long::sum);
                rounds.add(item);
            }
        }
        var ranking=wins.keySet().stream().sorted(Comparator.<Integer>comparingLong(id->totals.getOrDefault(id,0L))
                .reversed().thenComparingInt(Integer::intValue)).limit(100)
                .map(id->Map.of("uid",id,"totalScore",totals.getOrDefault(id,0L)/100,"times",wins.get(id))).toList();
        return Map.of("rounds",rounds,"ranking",ranking);
    }

    // 读取的牌局可以是历史局。只在封盘并完成钱包入账后公开牌面。
    private Map<String,Object> view(Connection db,Room room,Round r,int uid,boolean display) throws SQLException {
        var view=new LinkedHashMap<String,Object>();
        view.put("tid",room.tid); view.put("level",room.level); view.put("seats",room.seats);
        view.put("minimum",room.minimum); view.put("maxRounds",room.maxRounds);
        view.put("limit",r==null?room.limit:r.limit);
        view.put("rules",switch(room.level) {
            case 101 -> "龙、虎净赔1倍，和净赔6倍；同点为和，龙、虎退本。拼庄尾差按最大余数分摊，同余先上庄者优先。";
            case 102 -> "四门各与庄家比，胜负按赢家点数1至13倍；同点比花色。拼庄尾差按最大余数分摊，同余先上庄者优先。";
            case Baccarat.LEVEL -> Baccarat.RULES;
            default -> throw new IllegalArgumentException("未知百人场次");
        });
        var queue=queue(db,room.tid);
        view.put("queue",queue.stream().map(QueueEntry::uid).toList());
        var wallet=wallets.read(db,uid,false);
        view.put("chips",wallet==null?0:wallet.chips());
        view.put("phase",r==null?"WAITING":r.receipt==null?"OPEN":"SETTLED");
        if(display) {
            var history=new ArrayList<List<Integer>>();
            try(var q=query(db,"SELECT cards FROM joker_hundred_round WHERE tid=? AND closed_at IS NOT NULL ORDER BY closed_at DESC LIMIT 20",room.tid);
                var rows=q.executeQuery()) {
                while(rows.next()) history.add(json(rows.getString(1),new TypeReference<>(){}));
            }
            view.put("history",history.reversed());
        }
        if(r==null) return view;
        view.put("round",r.id); view.put("deadline",r.deadline);
        view.put("bankers",r.bankers.stream().map(b->Map.of("uid",b.uid(),"chips",b.chips())).toList());
        long[] totals=new long[HundredSettlement.areas(room.level)], own=new long[totals.length];
        var accepted=bets(db,r.id);
        if(display) view.put("positions",accepted.stream().map(b->Map.of("uid",b.uid(),"area",b.area(),"chips",b.chips())).toList());
        for(var bet:accepted) {
            totals[bet.area()-1]+=bet.chips();
            if(bet.uid()==uid) own[bet.area()-1]+=bet.chips();
        }
        view.put("totals",Arrays.stream(totals).boxed().toList());
        view.put("own",Arrays.stream(own).boxed().toList());
        if(r.receipt!=null) {
            if(room.level==Baccarat.LEVEL) {
                var result=Baccarat.open(r.cards);
                view.put("playerCards",result.player()); view.put("bankerCards",result.house());
                view.put("playerPoints",result.playerPoints()); view.put("bankerPoints",result.housePoints());
                view.put("playerPair",result.playerPair()); view.put("bankerPair",result.housePair());
            } else view.put("cards",r.cards);
            view.put("receipt",r.receipt.stream().map(p->Map.of("uid",p.uid,"chips",p.chips,"turnBlc",p.turnBlc)).toList());
        }
        return view;
    }

    Map<String,Object> handle(Jedis redis,ByteBuf in) throws SQLException {
        int tid=in.readInt(),uid=in.readInt(),action=in.readInt();
        String roundId=DataPacket.string(in), key=DataPacket.string(in);
        int area=in.readInt(), chips=in.readInt();
        if (in.isReadable() || uid<=0) throw new IllegalArgumentException("百人桌内部请求无效");
        try(var db=database.connect()) {
            db.setAutoCommit(false);
            try {
                Room room=lockRoom(db,tid);
                Round r=round(db,room.roundId);
                switch(action) {
                    case 5 -> {
                        var history=records(db,room,uid);
                        db.commit();
                        return history;
                    }
                    case 0,4 -> {
                        if (!roundId.isEmpty()) {
                            r=round(db,roundId);
                            if(r.tid!=tid) throw new IllegalArgumentException("牌局与桌号不符");
                        }
                    }
                    case 1 -> {
                        if(available(db,redis,uid,r==null?null:r.id)<room.minimum) throw new IllegalArgumentException("未达到上庄门槛或筹码已占用");
                        var entries=queue(db,tid);
                        if(entries.stream().noneMatch(e->e.uid==uid)) {
                            if(entries.size()>=100) throw new IllegalArgumentException("上庄队列已满");
                            update(db,"INSERT INTO joker_hundred_banker(tid,uid) VALUES(?,?)",tid,uid);
                        }
                    }
                    case 2 -> {
                        if (r!=null && r.receipt==null && r.bankers.stream().anyMatch(b->b.uid()==uid))
                            update(db,"UPDATE joker_hundred_banker SET retiring=1 WHERE tid=? AND uid=?",tid,uid);
                        else update(db,"DELETE FROM joker_hundred_banker WHERE tid=? AND uid=?",tid,uid);
                    }
                    case 3 -> {
                        var order=new Order(roundId,key,area,chips);
                        if(!key.matches("[a-zA-Z0-9_-]{1,64}") || roundId.length()!=36)
                            throw new IllegalArgumentException("订单编号或局号无效");
                        if(duplicate(db,uid,tid,order)) r=round(db,roundId);
                        else accept(db,redis,uid,room,r,order);
                    }
                    default -> throw new IllegalArgumentException("未知百人桌操作");
                }
                var state=view(db,room,r,uid,action==4);
                db.commit();
                return state;
            } catch(IllegalArgumentException e) {
                db.rollback();
                return Map.of("error",e.getMessage());
            } catch(Exception e) { db.rollback(); throw e; }
        }
    }
}
