import com.j.joker.game.hundred.domain.HundredPlayerCards;
import com.j.joker.game.niuniu.proto.BinaryWriter;
import com.j.joker.game.niuniu.util.Json;
import java.nio.ByteBuffer;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.*;

/** 走真实认证 API、data 进程、分表钱包与缓存。只在隔离的 Compose 回归内调用。 */
public class HundredTableCheck {
    private static final Path SAVE=Path.of("/tmp/hundred-check.json");
    static void check(boolean ok,String why) { if(!ok) throw new AssertionError(why); }
    static int n(Object v) { return ((Number)v).intValue(); }
    static Map<?,?> call(HallRoomCheck.Client c,int tid,String op,Map<String,?> params) throws Exception {
        var form=new HashMap<String,Object>(params); form.put("tid",tid);
        return (Map<?,?>)c.request("/hundredTable/"+op,form);
    }
    static void denied(HallRoomCheck.Client c,int tid,String op,Map<String,?> params) throws Exception {
        try { call(c,tid,op,params); } catch(AssertionError expected) { return; }
        throw new AssertionError("accepted invalid "+op);
    }
    static Map<?,?> state(HallRoomCheck.Client c,int tid) throws Exception { return call(c,tid,"state",Map.of()); }
    static void fund(HallRoomCheck.Client c) throws Exception {
        var credit=new BinaryWriter().i32(0).string("hundred-test").i32(c.uid()).i32(24000).string("");
        check(ByteBuffer.wrap(VariantsWireCheck.data(0x1005,credit.toByteArray())).getInt(4)==0,"credit");
        var buy=new BinaryWriter().i32(c.uid()).i32(0).i32(20000).i32(1200).i32(0);
        check(ByteBuffer.wrap(VariantsWireCheck.data(0x301a,buy.toByteArray())).getInt()==1,"purchase");
    }
    static int balance(int uid) throws Exception {
        try(var db=VariantsWireCheck.db()) {
            return VariantsWireCheck.scalar(db,"SELECT chip FROM bullfight_gameinfo"+uid%10+" WHERE mid=?",uid);
        }
    }
    static void seed() throws Exception {
        var cases=new ArrayList<Map<String,Object>>();
        try(var db=VariantsWireCheck.db();var q=db.createStatement()) {
            q.executeUpdate("UPDATE joker_hundred_room SET bet_seconds=240,max_rounds=1");
        }
        for(int level:List.of(101,102,9103)) {
            int tid=level*65536+(level==101?1:2);
            var banker=HallRoomCheck.Client.register(); var player=HallRoomCheck.Client.register();
            denied(player,tid,"apply",Map.of());
            fund(banker); fund(player);
            var forged=new HallRoomCheck.Client(player.uid(),"bad","","");
            denied(forged,tid,"apply",Map.of());
            call(banker,tid,"apply",Map.of());
            Map<?,?> opened=state(player,tid);
            for(int i=0;i<20 && !"OPEN".equals(opened.get("phase"));i++){ Thread.sleep(500); opened=state(player,tid); }
            check("OPEN".equals(opened.get("phase")) && !opened.containsKey("cards"),"premature or missing deal");
            if(level==9103) check(opened.get("rules").toString().contains("独立规则") && !opened.containsKey("bankerCards"),"baccarat terms or hidden cards");
            String round=(String)opened.get("round");
            var bet=Map.of("round",round,"requestId","concurrent","area",1,"chips",200);
            denied(banker,tid,"bet",bet);
            if(level==9103) for(int area=2;area<=5;area++)
                call(player,tid,"bet",Map.of("round",round,"requestId","area"+area,"area",area,"chips",100));
            try(var executor=Executors.newVirtualThreadPerTaskExecutor()) {
                Callable<Map<?,?>> submit=()->call(player,tid,"bet",bet);
                var a=executor.submit(submit);var b=executor.submit(submit);
                check(a.get().equals(b.get()),"concurrent receipt mismatch");
            }
            denied(player,tid,"bet",Map.of("round",round,"requestId","concurrent","area",2,"chips",200));
            denied(player,tid,"bet",Map.of("round",round,"requestId","large","area",1,"chips",20100));
            denied(player,(level==101?102:101)*65536+1,"apply",Map.of());
            var chips=ByteBuffer.wrap(VariantsWireCheck.data(0x301d,new BinaryWriter().i32(player.uid()).i32(0).toByteArray()));
            check(chips.getInt()==1,"redeem while reserved");
            check(n(((List<?>)state(player,tid).get("own")).getFirst())==200 && balance(player.uid())==20000,"duplicate charged");
            call(banker,tid,"withdraw",Map.of());
            cases.add(Map.of("tid",tid,"level",level,"round",round,"banker",banker.uid(),"player",player.uid(),"token",player.token()));
        }
        Files.writeString(SAVE,Json.write(cases));
        System.out.println("Verified authentication, duplicate bets, shared wallet holds and banker withdrawal for 101/102/9103.");
    }
    static void resume() throws Exception {
        var cases=(List<?>)Json.parse(Files.readString(SAVE));
        for(var item:cases) {
            var c=(Map<?,?>)item;
            int tid=n(c.get("tid")),uid=n(c.get("player"));
            var player=new HallRoomCheck.Client(uid,(String)c.get("token"),"","");
            var live=state(player,tid);
            check("OPEN".equals(live.get("phase")) && c.get("round").equals(live.get("round")) && n(((List<?>)live.get("own")).getFirst())==200,
                    "crash lost round or order");
        }
        try(var db=VariantsWireCheck.db();var q=db.createStatement()) { q.executeUpdate("UPDATE joker_hundred_round SET deadline=0 WHERE closed_at IS NULL"); }
        // 无客户端请求期间由 data 定时封盘。
        for(int i=0;i<40;i++) {
            try(var db=VariantsWireCheck.db()) {
                if(VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM joker_hundred_round WHERE closed_at IS NOT NULL AND tid>?",0)>=3) break;
            }
            Thread.sleep(500);
        }
        for(var item:cases) {
            var c=(Map<?,?>)item;
            int tid=n(c.get("tid")),uid=n(c.get("player")),banker=n(c.get("banker"));
            var player=new HallRoomCheck.Client(uid,(String)c.get("token"),"","");
            var end=state(player,tid);
            check("SETTLED".equals(end.get("phase")) && ((List<?>)end.get("queue")).isEmpty(),"unattended close/withdraw");
            var cards=((List<?>)end.getOrDefault("cards",null));
            List<Integer> dealt=new ArrayList<>();
            if(cards!=null) dealt=cards.stream().map(HundredTableCheck::n).toList();
            else for(String side:List.of("playerCards","bankerCards")) for(var c2:(List<?>)end.get(side)) dealt.add(n(c2));
            check(new HashSet<>(dealt).size()==dealt.size(),"duplicate deal");
            int delta;
            if(n(c.get("level"))==101) delta=(int)HundredPlayerCards.dragonTiger(dealt.get(0),dealt.get(1)).net(200,0,0);
            else if(n(c.get("level"))==9103) {
                int side=Integer.compare(n(end.get("bankerPoints")),n(end.get("playerPoints")));
                delta=100*side+(side==0?800:-100)+(Boolean.TRUE.equals(end.get("bankerPair"))?1100:-100)
                        +(Boolean.TRUE.equals(end.get("playerPair"))?1100:-100);
            }
            else {
                var r=HundredPlayerCards.beasts(dealt.get(0),dealt.get(1),dealt.get(2),dealt.get(3),dealt.get(4)).getFirst();
                delta=200*r.winningRank()*(r.playerWins()?1:-1);
            }
            check(balance(uid)==20000+delta && balance(banker)==20000-delta && n(end.get("chips"))==20000+delta,"wrong settlement");
            var history=(List<?>)call(player,tid,"history",Map.of()).get("rounds");
            check(n(((Map<?,?>)history.getFirst()).get("delta"))==delta,"personal round history");
            var bet=Map.of("round",c.get("round"),"requestId","concurrent","area",1,"chips",200);
            check(call(player,tid,"bet",bet).equals(end),"retry after close");
            denied(player,tid,"bet",Map.of("round",c.get("round"),"requestId","late","area",1,"chips",100));
            try(var db=VariantsWireCheck.db()) {
                check(VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM joker_douniu_side_hold WHERE uid=?",uid)==0,"locked after close");
            }
            var out=ByteBuffer.wrap(VariantsWireCheck.data(0x1011,new BinaryWriter().i32(0).i32(uid).toByteArray()));
            check(out.getInt()==uid && out.getInt()==0 && out.getInt(out.limit()-4)==20000+delta,"data cache differs");
        }
        Files.delete(SAVE);
        System.out.println("Verified 101/102/9103 crash recovery, unattended close, card-based payouts, released holds and retry after settlement.");
    }
    static void send(java.net.Socket s,int cmd,BinaryWriter payload) throws Exception {
        HallRoomCheck.Client.hallCommand(s,cmd,payload);
    }
    static Map<String,Object> receive(java.net.Socket s,int level,int cmd) throws Exception {
        return com.j.joker.game.niuniu.proto.SchemaCodec.decode(com.j.joker.game.hundred.interfaces.HundredHall.schema(level,cmd),
                DouniuCheck.waitFrame(s,cmd).body());
    }
    static void join(java.net.Socket s,HallRoomCheck.Client who,int tid) throws Exception {
        send(s,0x116,new BinaryWriter().i32(who.uid()).i32(1).u8(1).string(Json.write(Map.of("roomKey",who.roomKey()))));
        DouniuCheck.waitFrame(s,0x201);
        send(s,0x151,new BinaryWriter().u16(tid>>>16));
        var tables=new com.j.joker.game.niuniu.proto.BinaryReader(DouniuCheck.waitFrame(s,0x151).body());
        check(tables.u8()==0 && tables.u16()==2,"missing classic or pooled room");
        send(s,0x113,new BinaryWriter().u16(tid>>>16).i32(10).i32(1).i32(tid).i32(tid).i32(1).u8(1).i32(0).string("").string(""));
        DouniuCheck.waitFrame(s,0x210);
        send(s,0x1001,new BinaryWriter().i32(tid).i32(who.uid()).i32(-1).u8(1).string(who.nick()).string("")
                .string("").string("").string("{}").i32(tid).string(""));
    }
    static void wire() throws Exception {
        for(int level:List.of(101,102)) {
            int tid=level*65536+(level==101?2:1);
            var a=HallRoomCheck.Client.register();var b=HallRoomCheck.Client.register();
            fund(a); fund(b);
            try(var bank=new HallRoomCheck.HallSocket();var bettor=new HallRoomCheck.HallSocket()) {
                join(bank,a,tid); receive(bank,level,0x1007);
                join(bettor,b,tid); receive(bettor,level,0x1007);
                send(bank,0x1102,new BinaryWriter());receive(bank,level,0x4005);
                receive(bettor,level,0x4003);
                send(bettor,0x1101,new BinaryWriter().i32(1).i32(2));
                var accepted=receive(bettor,level,0x4002);
                check(n(accepted.get("uid"))==b.uid() && n(accepted.get("totalLongScore"))==2,"wire wager units");
                String round=(String)state(b,tid).get("round");
                try(var again=new HallRoomCheck.HallSocket()) {
                    join(again,b,tid);
                    var restored=receive(again,level,0x1009);
                    check(n(restored.get("totalLongScore"))==2 && n(restored.get("longCard"))==0,"wire private restart snapshot");
                    call(b,tid,"bet",Map.of("round",round,"requestId","http","area",1,"chips",100));
                    check(n(receive(again,level,0x4002).get("totalLongScore"))==3,"HTTP order missing in TCP");
                    send(bank,0x1104,new BinaryWriter()); receive(bank,level,0x4009);
                    try(var db=VariantsWireCheck.db();var q=db.prepareStatement("UPDATE joker_hundred_round SET deadline=0 WHERE id=?")) {
                        q.setString(1,round);q.executeUpdate();
                    }
                    receive(again,level,0x4014);
                    var end=receive(again,level,0x6008);
                    check(n(end.get("playerCount"))==2 && n(end.get("longCard"))>0,"wire settlement");
                    for(var obj:(List<?>)end.get("playerList")) {
                        var row=(Map<?,?>)obj;
                        check(n(row.get("chips"))==balance(n(row.get("uid"))),"wire wallet mismatch");
                    }
                    send(again,0x1103,new BinaryWriter());var trend=receive(again,level,0x4006);
                    check(level==101?n(trend.get("trendSize"))>0:!trend.get("longResult").equals(""),"history missing");
                    send(again,0x1033,new BinaryWriter()); receive(again,level,0x1033);
                }
            }
        }
        System.out.println("Verified authenticated legacy 101/102 TCP entry, banker commands, mixed TCP/HTTP bets, reconnect, trends and payouts.");
    }
    public static void main(String[] args) throws Exception {
        switch(args[0]) {case "--seed" -> seed();case "--resume" -> resume();case "--wire" -> wire();default -> throw new IllegalArgumentException();}
    }
}
