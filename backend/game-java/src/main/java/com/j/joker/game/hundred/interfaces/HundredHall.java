package com.j.joker.game.hundred.interfaces;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.j.joker.game.hundred.domain.HundredPlayerCards;
import com.j.joker.game.hundred.domain.HundredSettlement.Banker;
import com.j.joker.game.hundred.domain.HundredSettlement.Bet;
import com.j.joker.game.hundred.infrastructure.HundredClient;
import com.j.joker.game.niuniu.proto.*;
import com.j.joker.game.niuniu.util.Json;
import com.j.joker.game.rooms.application.Lobby;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;

/** 老大厅选桌后仍使用原认证连接。每桌共用一次轮询，数据服务单独负责时钟和钱包。 */
public final class HundredHall {
    private static final ObjectMapper JSON=new ObjectMapper().disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
    private static final Map<Integer,Map<Integer,Schema>> SCHEMAS=Map.of(101,schemas(101),102,schemas(102));
    private static final String[] AREAS={"Long","Hu","Que","Gui"};
    private final HundredClient client;
    private final Map<Integer,Table> tables=new LinkedHashMap<>();

    public HundredHall(HundredClient client) { this.client=client; }
    public static boolean supports(int tid) {
        int level=tid>>>16,index=tid&65535;
        return (level==101 || level==102) && (index==1 || index==2);
    }
    public static Schema schema(int level,int cmd) { return SCHEMAS.get(level).get(cmd); }
    private static Map<Integer,Schema> schemas(int level) {
        try(var in=HundredHall.class.getResourceAsStream("/hundred-"+level+".json")) {
            var out=new HashMap<Integer,Schema>();
            var defs=Json.parseObject(new String(Objects.requireNonNull(in).readAllBytes(),StandardCharsets.UTF_8));
            for(var e:defs.entrySet()) {
                int cmd=Integer.parseInt(e.getKey());
                @SuppressWarnings("unchecked") var fields=(Map<String,Object>)e.getValue();
                out.put(cmd,new Schema(cmd,1,ProtoRegistry.fields(fields)));
            }
            return Map.copyOf(out);
        } catch(IOException e) { throw new IllegalStateException(e); }
    }

    private record Receipt(int uid,int chips,int turnBlc) {}
    private record State(int level,int tid,int chips,int limit,int minimum,int maxRounds,String phase,String round,
                         long deadline,List<Integer> queue,List<Banker> bankers,List<Integer> totals,List<Bet> positions,
                         List<Integer> cards,List<List<Integer>> history,List<Receipt> receipt,String error) {
        State {
            bankers=bankers==null?List.of():bankers; positions=positions==null?List.of():positions;
            totals=totals==null?List.of():totals; receipt=receipt==null?List.of():receipt;
        }
        boolean open() { return "OPEN".equals(phase); }
    }
    private static final class Peer {
        final int uid,sex;
        final String name,portrait;
        final Lobby.Connection connection;
        int chips,seat=-1;
        Peer(int uid,int sex,String name,String portrait,Lobby.Connection connection) {
            this.uid=uid;this.sex=sex;this.name=name;this.portrait=portrait;this.connection=connection;
        }
    }
    private static final class Table {
        final int tid;
        final Map<Integer,Peer> peers=new LinkedHashMap<>();
        State observed;
        Table(int tid) { this.tid=tid; }
    }
    private record Position(int uid,int area) {}
    private State request(int tid,int uid,int command,String round,String key,int area,int chips) throws IOException {
        return JSON.readValue(client.execute(tid,uid,command,round,key,area,chips),State.class);
    }
    private State snapshot(int tid,int uid,String round) throws IOException {
        var state=request(tid,uid,4,round,"",0,0);
        if(state.error!=null) throw new IOException(state.error);
        return state;
    }

    public int count(int level) {
        return tables.values().stream().filter(t->(t.tid>>>16)==level).mapToInt(t->t.peers.size()).sum();
    }

    public void disconnect(int tid,int uid,Lobby.Connection connection) {
        var t=tables.get(tid);
        if(t==null) return;
        var p=t.peers.get(uid);
        if(p!=null && p.connection==connection) {
            t.peers.remove(uid);
            broadcast(t,0x1033,Map.of("uid",uid));
        }
        if(t.peers.isEmpty()) tables.remove(tid);
    }

    private static void send(Peer p,int level,int cmd,Map<String,Object> fields) {
        p.connection.notice(cmd,SchemaCodec.encode(schema(level,cmd),fields));
    }
    private static void broadcast(Table t,int cmd,Map<String,Object> fields) {
        var bytes=SchemaCodec.encode(schema(t.tid>>>16,cmd),fields);
        t.peers.values().forEach(p->p.connection.notice(cmd,bytes));
    }
    private static void list(Map<String,Object> m,String count,String key,List<?> rows) {
        m.put(count,rows.size()); m.put(key,rows);
    }

    private static Map<String,Object> profile(Table t,int uid) {
        Peer p=t.peers.get(uid);
        var m=new HashMap<String,Object>();
        m.put("uid",uid); m.put("seat_id",p==null?-1:p.seat); m.put("if_online",p==null?0:1);
        m.put("sex",p==null?0:p.sex); m.put("nickName",p==null?"玩家"+uid:p.name);
        m.put("portrait",p==null?"":p.portrait); m.put("chips",p==null?0:p.chips); m.put("otherInfo","{}");
        return m;
    }
    private static Map<String,Object> banks(Table t,State s) {
        var m=new HashMap<String,Object>();
        var ids=new HashSet<Integer>();
        var bankers=new ArrayList<Map<String,Object>>();
        for(var b:s.bankers) {
            ids.add(b.uid());
            var row=profile(t,b.uid()); row.put("chips",b.chips()); bankers.add(row);
        }
        list(m,"bankerSize","bankerList",bankers);
        list(m,"waitBankerSize","waitBankerList",s.queue.stream().filter(id->!ids.contains(id)).map(id->profile(t,id)).toList());
        return m;
    }
    private static int[] outcome(int level,List<Integer> c) {
        if(level==101) return new int[]{HundredPlayerCards.dragonTiger(c.get(0),c.get(1)).ordinal()+1};
        return HundredPlayerCards.beasts(c.get(0),c.get(1),c.get(2),c.get(3),c.get(4)).stream()
                .mapToInt(r->r.playerWins()?1:-1).toArray();
    }
    private static Map<String,Object> trend(State s) {
        var m=new HashMap<String,Object>();
        var history=s.history.stream().map(c->outcome(s.level,c)).toList();
        if(s.level==101) {
            list(m,"trendSize","trendList",history.stream().map(a->Map.of("openRes",a[0])).toList());
            var runs=new ArrayList<String>();
            int previous=0;
            for(var a:history) {
                if(a[0]==previous) runs.set(runs.size()-1,runs.getLast()+","+a[0]); else runs.add(""+a[0]);
                previous=a[0];
            }
            m.put("paiLuStr",String.join(";",runs));
        } else {
            var names=List.of("longResult","huResult","queResult","wuResult");
            for(int i=0;i<4;i++) {
                final int area=i;
                m.put(names.get(i),history.stream().map(a->""+a[area]).collect(Collectors.joining(",")));
            }
        }
        return m;
    }
    private static Map<String,Object> board(State s) {
        var m=new HashMap<String,Object>();
        long pool=s.bankers.stream().mapToLong(Banker::chips).sum();
        int count=s.level==101?3:4;
        long[] amounts=new long[count];
        for(int i=0;i<count;i++) {
            amounts[i]=s.totals.isEmpty()?0:s.totals.get(i);
            String area=s.level==101 && i==2?"He":AREAS[i];
            m.put("total"+area+"Score",amounts[i]/100);
        }
        if(s.level==101) {
            long d=amounts[0],t=amounts[1],tie=amounts[2];
            long[] capacity={pool-d+t+tie,pool-t+d+tie,pool/6-tie};
            for(int i=0;i<3;i++) m.put("surp"+List.of("Long","Hu","He").get(i)+"MaxScore",Math.max(0,Math.min(capacity[i],s.limit-amounts[i]))/100);
        } else m.put("surpMaxScore",Math.max(0,Math.min(s.limit,pool/13-Arrays.stream(amounts).sum()))/100);
        m.put("times",Math.max(0,(s.deadline-System.currentTimeMillis()+999)/1000));
        return m;
    }
    private static Map<String,Object> result(State s) {
        var m=new HashMap<String,Object>();
        var c=s.cards;
        int offset=s.level==102?1:0;
        m.put("longCard",c.get(offset)); m.put("huCard",c.get(offset+1));
        int[] win=outcome(s.level,c);
        if(s.level==101) m.put("openRes",win[0]);
        else {
            m.put("bankerCard",c.getFirst());m.put("queCard",c.get(3));m.put("guiCard",c.get(4));
            for(int i=0;i<4;i++) m.put("open"+AREAS[i]+"Res",win[i]);
        }
        list(m,"playerCount","playerList",s.receipt.stream().map(r->Map.of("uid",r.uid,"chips",r.chips,"turnBlc",r.turnBlc)).toList());
        return m;
    }
    private static Map<String,Object> player(Table t,State s,int uid) {
        var m=profile(t,uid);
        m.put("isBanker",s.bankers.stream().anyMatch(b->b.uid()==uid)?1:s.queue.contains(uid)?2:0);
        m.put("betStr",s.positions.stream().filter(b->b.uid()==uid).map(b->b.area()+","+b.chips()/100).collect(Collectors.joining(";")));
        return m;
    }

    public void join(int tid,int uid,BinaryReader in,Lobby.Connection connection) throws IOException {
        int seat=in.i32(),sex=in.u8();
        String nick=in.string(),portrait=in.string();
        in.string();in.string();in.string();int activity=in.i32();in.string();
        if(in.remaining()!=0 || (activity!=tid && activity!=0) || nick.length()>64 || portrait.length()>256)
            throw new IllegalArgumentException("百人桌登录参数无效");
        var t=tables.computeIfAbsent(tid,Table::new);
        if(t.peers.size()>=100 && !t.peers.containsKey(uid)) throw new IllegalArgumentException("百人桌已满");
        var s=snapshot(tid,uid,"");
        if(t.observed!=null) refresh(t,s);
        var p=new Peer(uid,sex,nick,portrait,connection);
        p.chips=s.chips;
        if(seat>=0 && seat<6 && t.peers.values().stream().noneMatch(other->other.seat==seat)) p.seat=seat;
        if(!t.peers.containsKey(uid)) broadcast(t,0x100d,Map.of("uid",uid,"seat_id",p.seat,"sex",p.sex,"nickName",nick,"portrait",portrait,"chips",p.chips,"otherInfo","{}"));
        t.peers.put(uid,p);
        var m=board(s);
        m.putAll(trend(s));m.putAll(banks(t,s));
        m.put("inviteCode",""+tid);m.put("baseChip",1);m.put("maxPlayerSize",100);m.put("gameStatus",s.open()?1:0);
        m.put("roomConfigStr",Json.write(Map.of("applyBankerScore",s.minimum/100,"bankTimes",s.maxRounds,"dis_agree",3)));
        var shown=new LinkedHashSet<Integer>();
        shown.add(uid);
        t.peers.values().stream().filter(other->other.seat>=0).forEach(other->shown.add(other.uid));
        list(m,"playerCount","playerList",shown.stream().map(id->player(t,s,id)).toList());
        boolean previouslyPlayed=s.positions.stream().anyMatch(b->b.uid()==uid) || s.bankers.stream().anyMatch(b->b.uid()==uid);
        send(p,s.level,previouslyPlayed?0x1009:0x1007,m);
        if(s.open()) send(p,s.level,0x4003,board(s));
        t.observed=s;
    }

    private void refresh(Table t,State s) throws IOException {
        var old=t.observed;
        boolean changed=old==null || !Objects.equals(old.round,s.round);
        if(old!=null && changed && old.open()) refresh(t,snapshot(t.tid,t.peers.keySet().iterator().next(),old.round));
        if(changed || !Objects.equals(old.queue,s.queue)) broadcast(t,0x4009,banks(t,s));
        if(changed && s.open()) broadcast(t,0x4003,board(s));
        if(s.round!=null && (changed || !s.positions.equals(old.positions))) {
            var previous=new HashMap<Position,Integer>();
            if(!changed) old.positions.forEach(b->previous.put(new Position(b.uid(),b.area()),b.chips()));
            for(var b:s.positions) {
                int increase=b.chips()-previous.getOrDefault(new Position(b.uid(),b.area()),0);
                if(increase<=0) continue;
                var m=board(s);m.put("uid",b.uid());m.put("betType",b.area());m.put("betScore",increase/100);
                broadcast(t,0x4002,m);
            }
        }
        if(s.cards!=null && (changed || old.open())) {
            var m=result(s);
            broadcast(t,0x4014,m);broadcast(t,0x6008,m);
            for(var row:s.receipt) {
                var p=t.peers.get(row.uid);
                if(p!=null) p.chips=row.chips;
            }
        }
        t.observed=s;
    }

    public void poll() {
        for(var t:List.copyOf(tables.values())) {
            if(t.peers.isEmpty()) continue;
            try { refresh(t,snapshot(t.tid,t.peers.keySet().iterator().next(),"")); }
            catch(IOException | RuntimeException e) { org.slf4j.LoggerFactory.getLogger(HundredHall.class).warn("百人桌 {} 暂时无法同步",t.tid,e); }
        }
    }

    public void handle(int tid,int uid,Lobby.Connection connection,int cmd,BinaryReader in) throws IOException {
        var t=tables.get(tid);
        var p=t==null?null:t.peers.get(uid);
        if(p==null || p.connection!=connection) return;
        var s=t.observed;
        if(cmd==0x1033 && in.remaining()==0) {
            request(tid,uid,2,"","",0,0);
            send(p,s.level,0x1033,Map.of("uid",uid));
            disconnect(tid,uid,connection);
            return;
        }
        if(cmd==0x1101 || (in.remaining()==0 && (cmd==0x1102 || cmd==0x1104 || cmd==0x1105))) {
            int area=0,chips=0;String round="",key="";
            int action=cmd==0x1101?3:cmd==0x1102?1:2;
            if(action==3) {
                if(in.remaining()!=8 || !s.open()) {send(p,s.level,0x5001,Map.of("errorCode",100));return;}
                area=in.i32();
                int score=in.i32();
                if(score<=0 || score>Integer.MAX_VALUE/100) {send(p,s.level,0x5001,Map.of("errorCode",100));return;}
                chips=score*100;round=s.round;key=UUID.randomUUID().toString();
            }
            if(action==1 && p.seat>=0) {send(p,s.level,0x5001,Map.of("errorCode",101));return;}
            var response=request(tid,uid,action,round,key,area,chips);
            if(response.error!=null) {send(p,s.level,0x5001,Map.of("errorCode",action==1?101:100));return;}
            var next=snapshot(tid,uid,"");
            refresh(t,next);
            if(action!=3) send(p,s.level,action==1?0x4005:0x4009,banks(t,next));
        } else if(cmd==0x1103 && in.remaining()==0) send(p,s.level,0x4006,trend(s));
        else if(cmd==0x1107 && in.remaining()==4) {
            int target=in.i32();
            if(t.peers.containsKey(target)) send(p,s.level,0x4011,player(t,s,target));
        } else if(cmd==0x1106 && in.remaining()==0) {
            var m=new HashMap<String,Object>();
            var history=JSON.readTree(client.execute(tid,uid,5,"","",0,0));
            var rows=new ArrayList<Map<String,Object>>();
            for(var r:history.path("ranking")) {
                var row=profile(t,r.path("uid").intValue());
                row.put("totalScore",Math.min(Integer.MAX_VALUE,r.path("totalScore").longValue()));
                row.put("times",r.path("times").intValue());
                rows.add(row);
            }
            list(m,"playerCount","playerList",rows);
            send(p,s.level,0x4008,m);
        } else if(cmd==0x1032 && in.remaining()==0) {
            p.seat=-1;broadcast(t,cmd,Map.of("uid",uid));
        } else if(cmd==0x1031 && (in.remaining()==0 || in.remaining()==4) && !s.queue.contains(uid)) {
            int wanted=in.remaining()==4?in.i32():-1;
            for(int i=0;i<6;i++) {
                final int seat=i;
                if ((wanted<0 || wanted==i) && t.peers.values().stream().noneMatch(other->other.seat==seat)) {
                    p.seat=i;broadcast(t,cmd,player(t,s,uid));break;
                }
            }
        }
    }
}
