import com.j.joker.game.niuniu.proto.BinaryReader;
import com.j.joker.game.niuniu.proto.BinaryWriter;
import com.j.joker.game.niuniu.util.Json;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.sql.Connection;
import java.sql.Statement;
import java.util.*;

public class LegacyFlowsCheck {
    static void check(boolean value,String label) { VariantsWireCheck.check(value,label); }
    static void command(Socket hall,int command,BinaryWriter body) throws Exception {
        HallRoomCheck.Client.hallCommand(hall,command,body);
    }
    static void login(Socket hall,HallRoomCheck.Client client) throws Exception {
        command(hall,0x116,new BinaryWriter().i32(client.uid()).i32(1).u8(1).string(Json.write(Map.of("roomKey",client.roomKey()))));
        DouniuCheck.waitFrame(hall,0x201);
    }
    static void fund(int uid,int money,int chips,Connection db) throws Exception {
        var request=new BinaryWriter().i32(0).string("fixture").i32(uid).i32(money)
                .i32(0).i32(0).i32(0).i32(0).string("").i32(chips);
        var balance=ByteBuffer.wrap(VariantsWireCheck.data(0x1002,request.toByteArray()));
        check(balance.getInt(4)==0,"fund account");
        check(VariantsWireCheck.scalar(db,"SELECT chip FROM bullfight_gameinfo"+uid%10+" WHERE mid=?",uid)
                == balance.getInt(balance.limit()-4), "funds persisted by data");
    }
    static long money(int uid) throws Exception {
        var result=new BinaryReader(VariantsWireCheck.data(0x1004,new BinaryWriter().i32(0).i32(uid).toByteArray()));
        check(result.i32()==uid && result.i32()==0,"wallet reply");
        return Long.parseLong(result.string());
    }
    static int internal(int port,int cmd,BinaryWriter body,boolean reply) throws Exception {
        try (var socket=new Socket("127.0.0.1",port)) {
            socket.setSoTimeout(3000);
            socket.getOutputStream().write(new BinaryWriter().i32(body.size()+14).u16(0x4259).u16(1).i32(cmd)
                    .i32(0).u16(0).bytes(body.toByteArray()).toByteArray());
            if (!reply) return 0;
            var in=new java.io.DataInputStream(socket.getInputStream());
            check(in.readInt()==18,"lock response length"); in.skipNBytes(14);return in.readInt();
        }
    }
    static boolean lock(int uid) throws Exception {
        return internal(7500,0x113,new BinaryWriter().i32(10).i16(0).i32(10).i32(uid),true)==0;
    }
    static void rejected(HallRoomCheck.Client c,Map<String,?> params) throws Exception {
        try { c.request("/playerXXX",params); } catch (AssertionError expected) { return; }
        throw new AssertionError("invalid gift accepted");
    }
    static void gifts() throws Exception {
        var a=HallRoomCheck.Client.register(); var b=HallRoomCheck.Client.register();
        try (var db=VariantsWireCheck.db()) {
            fund(a.uid(),1000,0,db);
            long before=money(a.uid()), recipient=money(b.uid());
            var params=new HashMap<String,Object>(Map.of("requestId",UUID.randomUUID().toString(),"playerId1",a.uid(),
                    "playerId2",b.uid(),"count",137,"remark","分桌回归"));
            check(lock(a.uid()) && !lock(a.uid()),"legacy exclusive sender lock");
            rejected(a,params);
            internal(7500,0x199,new BinaryWriter().u16(0).i32(-1).i32(a.uid()),false);
            // 顺序查询确保上一条回环命令已处理。
            for (int i=0;;i++) {
                try { a.request("/playerXXX",params); break; }
                catch (AssertionError unavailable) { if (i==10) throw unavailable; Thread.sleep(100); }
            }
            a.request("/playerXXX",params);
            check(money(a.uid())==before-137 && money(b.uid())==recipient+137,"gift balances after replay");
            params.put("count",138);rejected(a,params);
            params.put("requestId",UUID.randomUUID().toString());rejected(b,params);
            params.put("count",Integer.MAX_VALUE);rejected(a,params);
            var history=(List<?>)a.request("/queryPlayerXXX",Map.of("playerId1",a.uid(),"type",1));
            check(history.size()==1 && ((Map<?,?>)history.getFirst()).get("remark").equals("分桌回归"),"gift receipt visible");
            check(VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM t_gift_room_card WHERE projected=1 AND user_id=?",a.uid())==1,"one projected receipt");
        }
    }
    static void robotAndHall() throws Exception {
        var a=HallRoomCheck.Client.register(); var bot=HallRoomCheck.Client.register(); var guest=HallRoomCheck.Client.register();
        int club=HallRoomCheck.clubFixture(a,a,bot,guest);
        try (var db=VariantsWireCheck.db()) {
            try(var q=db.createStatement()) {
                q.executeUpdate("UPDATE t_user SET is_robot=1 WHERE userid="+bot.uid());
                q.executeUpdate("UPDATE t_player_group SET is_robot=1,robot_status=1 WHERE group_id="+club+" AND player_id="+bot.uid());
            }
            fund(bot.uid(),0,20000,db); fund(a.uid(),0,20000,db);
            int template;
            try(var q=db.prepareStatement("INSERT INTO t_group_gameconfig(group_id,level,config,game_type,status) VALUES(?,302,?,15,1)",Statement.RETURN_GENERATED_KEYS)){
                q.setInt(1,club); q.setString(2,Json.write(Map.of("groupType",2)));q.executeUpdate();
                try(var rs=q.getGeneratedKeys()){rs.next();template=rs.getInt(1);}
            }
            var room=(Map<?,?>)a.request("/freeGame/createFreeGameByOthers",Map.of("gameId",302,"name","机器人测试","level",302,
                    "round",2,"others",1,"baseChip",1,"groupId",club,"configId",template,
                    "json",Json.write(Map.of("maxSeatCount",2,"round",2,"subGameType",1))));
            int tid=Integer.parseInt(room.get("tableId").toString()), activity=Integer.parseInt(room.get("gameActivityId").toString());
            try(var hall=new HallRoomCheck.HallSocket();var other=new HallRoomCheck.HallSocket()) {
                a.enter(hall,tid,activity,1); login(other,guest);
                command(hall,0x188,new BinaryWriter().i32(club).i32(0).i32(10));
                var member=new BinaryReader(DouniuCheck.waitFrame(hall,0x188).body());
                check(member.i32()==club && member.i32()==guest.uid() && member.i32()==0,"online invite list");
                check(new BinaryReader(DouniuCheck.waitFrame(hall,0x189).body()).i32()==a.uid(),"invite list end");
                command(hall,0x190,new BinaryWriter().i32(guest.uid()).i32(club).i32(tid).i32(activity).i32(302)
                        .string("伪造名字").string("伪造头像").string("{}"));
                var invite=new BinaryReader(DouniuCheck.waitFrame(other,0x190).body());
                check(invite.i32()==a.uid() && invite.i32()==club && invite.i32()==tid && invite.i32()==activity
                        && invite.i32()==302 && !invite.string().equals("伪造名字") && !invite.string().equals("伪造头像")
                        && Json.parseObject(invite.string()).get("inviteCode").toString().equals(room.get("inviteCode").toString()),
                        "invitation from actual seated member and activity");
                command(other,0x155,new BinaryWriter().i32(tid));
                var refused=new BinaryReader(DouniuCheck.waitFrame(other,0x361).body());
                check(refused.i32()==0 && refused.i32()!=0,"ordinary member cannot dissolve a club table");
                check(!lock(a.uid()),"seated account cannot take gift lock");
                command(other,0x177,new BinaryWriter().i32(club).i32(a.uid()).i32(1));
                check(new BinaryReader(DouniuCheck.waitFrame(other,0x177).body()).i32()==0,"member cannot ban owner");
                command(hall,0x177,new BinaryWriter().i32(club).i32(guest.uid()).i32(1));
                check(new BinaryReader(DouniuCheck.waitFrame(hall,0x177).body()).i32()==1,"owner ban");
                var quick=new BinaryWriter().u16(302).i32(club).i32(template);
                command(other,0x179,quick);DouniuCheck.waitFrame(other,0x179);
                command(hall,0x177,new BinaryWriter().i32(club).i32(guest.uid()).i32(0));DouniuCheck.waitFrame(hall,0x177);
                command(other,0x179,quick);
                check(new BinaryReader(DouniuCheck.waitFrame(other,0x210).body()).i32()==tid,"authorized quick join");
                command(hall,0x2001,new BinaryWriter().i32(1));
                var arrival=DouniuCheck.waitFor(hall,0x100d);
                check(((Number)arrival.get("uid")).intValue()==bot.uid(),"authorized robot joins human");
                DouniuCheck.waitFor(hall,0x6015);
                command(hall,0x311,new BinaryWriter());
                var levels=new BinaryReader(DouniuCheck.waitFrame(hall,0x311).body());
                check(levels.u8()==3 && levels.i32()==302 && levels.i32()==2 && levels.i32()==101 && levels.i32()==0 && levels.i32()==102 && levels.i32()==0,"live level occupancy");
                command(hall,0x2007,new BinaryWriter().i32(1));
                DouniuCheck.waitFor(hall,0x6008);
                try (var q=db.prepareStatement("UPDATE t_player_group SET robot_status=3 WHERE group_id=? AND player_id=?")) {
                    q.setInt(1,club); q.setInt(2,bot.uid()); q.executeUpdate();
                }
                command(hall,0x2001,new BinaryWriter().i32(1));
                check(((Number)DouniuCheck.waitFor(hall,0x1033).get("uid")).intValue()==bot.uid(),"recalled robot leaves before next round");
                command(hall,0x155,new BinaryWriter().i32(tid));
                DouniuCheck.waitFor(hall,0x5100);
                check(lock(bot.uid()),"robot released after settlement and closure");
            }
        }
    }
    static final java.nio.file.Path fixture=java.nio.file.Path.of("/tmp/joker-recovery.properties");

    static void recovery(String phase) throws Exception {
        var p=new Properties();
        if (phase.equals("--seed")) {
            var sender=HallRoomCheck.Client.register();
            var recipient=HallRoomCheck.Client.register();
            var buyer=HallRoomCheck.Client.register();
            int club=HallRoomCheck.clubFixture(sender,sender,recipient);
            String gift=UUID.randomUUID().toString(), fee=UUID.randomUUID().toString();
            try (var db=VariantsWireCheck.db()) {
                fund(sender.uid(),700,5000,db);
                fund(buyer.uid(), 150, 0, db);
                var bought = new BinaryReader(VariantsWireCheck.data(0x301a,new BinaryWriter().i32(buyer.uid()).i32(0)
                        .i32(100).i32(1200).i32(0).toByteArray()));
                check(bought.i32()==1 && bought.i32()==100,"exchange before restart");
                var duplicate=new BinaryReader(VariantsWireCheck.data(0x301a,new BinaryWriter().i32(buyer.uid()).i32(0)
                        .i32(100).i32(1200).i32(0).toByteArray()));
                check(duplicate.i32()==1 && duplicate.i32()==100,"old request safely replayed");
                String purchaseKey=UUID.randomUUID().toString();
                var order=Map.of("chips",5,"requestId",purchaseKey);
                var prior=buyer.request("/wallet/purchaseChips",order);
                check(prior.equals(buyer.request("/wallet/purchaseChips",order)),"HTTP receipt after lost reply");
                boolean conflicted=false;
                try { buyer.request("/wallet/purchaseChips",Map.of("chips",6,"requestId",purchaseKey)); }
                catch (AssertionError expected) { conflicted=true; }
                check(conflicted,"conflicting purchase parameters");
                String secondKey=UUID.randomUUID().toString();
                var second=Map.of("chips",5,"requestId",secondKey);
                try(var workers=java.util.concurrent.Executors.newVirtualThreadPerTaskExecutor()) {
                    java.util.concurrent.Callable<Object> submit=()->buyer.request("/wallet/purchaseChips",second);
                    var one=workers.submit(submit); var two=workers.submit(submit);
                    check(one.get().equals(two.get()),"concurrent purchase");
                }
                check(VariantsWireCheck.scalar(db,"SELECT chip FROM bullfight_gameinfo"+buyer.uid()%10+" WHERE mid=?",buyer.uid())==110,"two distinct orders for same amount");
                p.setProperty("purchaseKey",purchaseKey);
                p.setProperty("buyer", Integer.toString(buyer.uid()));
                p.setProperty("buyerMoney", Long.toString(money(buyer.uid())));
                sender.request("/playerXXX",Map.of("playerId1",sender.uid(),"playerId2",recipient.uid(),
                        "count",50,"requestId",gift,"remark","recovery"));
                var room=(Map<?,?>)sender.request("/freeGame/createFreeGameByOthers",Map.of("gameId",302,"name","回执恢复",
                        "level",302,"round",2,"others",1,"baseChip",1,"groupId",club,"json","{}"));
                int activity=Integer.parseInt(room.get("gameActivityId").toString());
                int before=VariantsWireCheck.scalar(db,"SELECT chip FROM bullfight_gameinfo"+sender.uid()%10+" WHERE mid=?",sender.uid());
                var charge=new BinaryWriter().string(fee).string("START").i32(activity).i32(club).i32(302).i32(1)
                        .i32(sender.uid()).i32(before).i32(19);
                check(ByteBuffer.wrap(VariantsWireCheck.data(0x1019,charge.toByteArray())).getInt()==0,"seed fee");
                p.putAll(Map.of("sender",""+sender.uid(),"recipient",""+recipient.uid(),"gift",gift,"fee",fee,
                        "from",""+money(sender.uid()),"to",""+money(recipient.uid()),"chips",""+(before-19),
                        "activity",""+activity,"club",""+club));
            }
            try(var out=java.nio.file.Files.newOutputStream(fixture)){p.store(out,null);}
            java.nio.file.Files.writeString(java.nio.file.Path.of("/tmp/joker-recovery-users"),sender.uid()+" "+recipient.uid()+" "+buyer.uid()+"\n");
            return;
        }
        try (var in=java.nio.file.Files.newInputStream(fixture)){p.load(in);}
        int sender=Integer.parseInt(p.getProperty("sender")),recipient=Integer.parseInt(p.getProperty("recipient"));
        try (var db=VariantsWireCheck.db()) {
            if (phase.equals("--pending")) {
                db.setAutoCommit(false);
                for (String[] entry : new String[][]{{"t_gift_room_card","request_id","gift"},{"joker_table_charge","event_id","fee"}}) {
                    try(var q=db.prepareStatement("UPDATE "+entry[0]+" SET projected=0 WHERE "+entry[1]+"=? AND projected=1")) {
                        q.setString(1,p.getProperty(entry[2]));check(q.executeUpdate()==1,"recreate pending receipt");
                    }
                }
                try(var marker = db.prepareStatement("INSERT INTO joker_player_cache_sync(game_id,uid) VALUES(0,?)")) {
                    marker.setInt(1,Integer.parseInt(p.getProperty("buyer")));
                    marker.executeUpdate();
                }
                db.commit();
                return;
            }
            check(phase.equals("--recovered"),"unknown recovery phase");
            int buyer = Integer.parseInt(p.getProperty("buyer"));
            long wallet = Long.parseLong(p.getProperty("buyerMoney"));
            check(money(buyer)==wallet,"legacy wallet recovered from SQL");
            var retry=new BinaryReader(VariantsWireCheck.data(0x301a,new BinaryWriter().i32(buyer).i32(0).i32(5)
                    .i32(1200).i32(0).string(p.getProperty("purchaseKey")).toByteArray()));
            check(retry.i32()==1 && retry.i32()==105 && money(buyer)==wallet,"restart must replay original purchase receipt");
            var redeem = new BinaryReader(VariantsWireCheck.data(0x301d,new BinaryWriter().i32(buyer).i32(0).toByteArray()));
            check(redeem.i32()==0 && redeem.i32()==wallet+110,"redeem recovered chips");
            var redeemedAgain = new BinaryReader(VariantsWireCheck.data(0x301d,new BinaryWriter().i32(buyer).i32(0).toByteArray()));
            check(redeemedAgain.i32()==0 && redeemedAgain.i32()==wallet+110,"second redemption adds nothing");
            check(VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM joker_player_cache_sync WHERE uid=?",buyer)==0,
                    "cache marker cleared after recovery");
            for (int i=0;i<2;i++) {
                check(money(sender)==Long.parseLong(p.getProperty("from")) && money(recipient)==Long.parseLong(p.getProperty("to")),
                        "wallets restored from committed gift");
                var balance=VariantsWireCheck.data(0x1011,new BinaryWriter().i32(0).i32(sender).toByteArray());
                check(ByteBuffer.wrap(balance).getInt(balance.length-4)==Integer.parseInt(p.getProperty("chips")),"charge balance restored");
                var giftBody=new BinaryWriter().i32(sender).i32(recipient).i32(50).string(p.getProperty("gift"))
                        .bytes("recovery".getBytes(java.nio.charset.StandardCharsets.UTF_8));
                check(ByteBuffer.wrap(VariantsWireCheck.data(0x101a,giftBody.toByteArray())).getInt()==5,"recovered gift replay");
                VariantsWireCheck.replayCharge(db,Integer.parseInt(p.getProperty("activity")));
            }
            check(VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM t_gift_room_card WHERE projected=1 AND user_id=?",sender)==1,"single recovered gift");
            check(VariantsWireCheck.scalar(db,"SELECT SUM(amount) FROM joker_table_charge WHERE projected=1 AND uid=?",sender)==19,"single recovered debit");
            check(VariantsWireCheck.scalar(db,"SELECT profit_count FROM t_group_player WHERE group_id=?",Integer.parseInt(p.getProperty("club")))==19,"single fee distribution");
            System.out.println("Verified data restart with pending gift and fee receipts, stale Redis balances and repeated commands.");
        }
    }

    static int select(Socket hall, int tid, int activity, String lat, String lon) throws Exception {
        command(hall, 0x113, new BinaryWriter().u16(302).i32(0).i32(0).i32(tid).i32(activity)
                .i32(1).u8(1).i32(0).string(lat).string(lon));
        while (true) {
            var frame = com.j.joker.game.niuniu.proto.PacketCodec.readFrame(hall.getInputStream());
            if (frame.cmd() == 0x210) return 0;
            if (frame.cmd() == 0x212) {
                var body = new BinaryReader(frame.body());
                body.u16();
                return body.u16();
            }
        }
    }

    static void seatLimits(boolean ip) throws Exception {
        var owner = HallRoomCheck.Client.register();
        var guest = HallRoomCheck.Client.register();
        var third = HallRoomCheck.Client.register();
        String catalog = (String)owner.request("/gold/getGameConfigByLevelAndGold",Map.of("level",302));
        var keys = new java.util.HashSet<String>();
        for (var row : (List<?>) Json.parseObject(catalog).get("gameConfig")) {
            for (var option : (List<?>)((Map<?,?>)row).get("configGroup")) {
                String name = ((Map<?,?>)option).get("config").toString();
                if (name.equals("ipXz") || name.equals("juLi")) check(keys.add(name),"duplicate seat option");
            }
        }
        check(keys.containsAll(List.of("ipXz","juLi")),"seat rules available in client catalog");
        int club = HallRoomCheck.clubFixture(owner, owner, guest, third);
        int template;
        try (var db = VariantsWireCheck.db(); var q = db.prepareStatement(
                "INSERT INTO t_group_gameconfig(group_id,level,config,game_type,status) VALUES(?,302,?,15,1)", Statement.RETURN_GENERATED_KEYS)) {
            q.setInt(1,club);
            q.setString(2, Json.write(Map.of("ipXz", ip ? 1 : 0, "juLi", Map.of("optionValue", ip ? 0 : 100))));
            q.executeUpdate();
            try (var id = q.getGeneratedKeys()) { id.next(); template = id.getInt(1); }
        }
        var room = (Map<?,?>)owner.request("/freeGame/createFreeGameByOthers",Map.of("gameId",302,"name","入桌规则","level",302,
                "round",2,"others",1,"baseChip",1,"groupId",club,"configId",template,
                "json",Json.write(Map.of("ipXz",0,"juLi",0,"publicGoldTable",true,"maxSeatCount",4,"round",2))));
        int tid = Integer.parseInt(room.get("tableId").toString()), activity = Integer.parseInt(room.get("gameActivityId").toString());
        for (var client : List.of(guest,third)) client.request("/joinFreeGame",Map.of("type","P","invitationCode",room.get("inviteCode"),
                "activityId",activity,"level",302,"isWatch",1));
        try (var a = new HallRoomCheck.HallSocket(); var b = new HallRoomCheck.HallSocket(); var c = new HallRoomCheck.HallSocket()) {
            login(a,owner); login(b,guest); login(c,third);
            if (!ip) check(select(a,tid,activity,"0","0") == 8, "GPS required by template");
            check(select(a,tid,activity,"28","112") == 0 && select(b,tid,activity,"28.0001","112") == 0, "route before occupancy");
            check(owner.tryRoom(a,tid,activity).cmd() == 0x1007, "first seat");
            var failed = guest.tryRoom(b,tid,activity);
            check(failed.cmd() == 0x1005 && ((Number)DouniuCheck.decode(failed).get("errorCode")).intValue() == (ip ? 12 : 19),
                    "seat rechecks players who arrived after routing");
            check(select(c,tid,activity,"28.0001","112") == (ip ? 9 : 8), "hall rejects nearby player or same IP");
            if (!ip) {
                check(select(c,tid,activity,"28.02","112") == 0 && third.tryRoom(c,tid,activity).cmd() == 0x1007, "distant player seated");
            }
            command(a,0x151,new BinaryWriter().u16(302));
            var list = new BinaryReader(DouniuCheck.waitFrame(a,0x151).body());
            check(list.u8() == 0 && list.u16() == 0 && list.remaining() == 0, "private/club rooms hidden from gold list");
            command(a,0x151,new BinaryWriter().u16(999));
            check(new BinaryReader(DouniuCheck.waitFrame(a,0x151).body()).u8() == 1, "unavailable level answered");
        }
    }

    static void publicGoldList() throws Exception {
        var owner = HallRoomCheck.Client.register();
        // 通过实际分桌协议创建专用的公开金币场，默认 302 目录是私房。
        int activity = 193000001;
        var body = new BinaryWriter().i32(owner.uid()).i32(302).i32(2).i32(0).string("840731")
                .i32(activity).i32(2).string("{\"publicGoldTable\":true}").i32(0).i32(4)
                .string("").string("").string("");
        int tid;
        try (var socket = new Socket("127.0.0.1",11603)) {
            socket.setSoTimeout(3000);
            socket.getOutputStream().write(new BinaryWriter().i32(body.size()+14).u16(0x4259).u16(0).i32(0x160)
                    .i32(0).u16(0).bytes(body.toByteArray()).toByteArray());
            var in = new java.io.DataInputStream(socket.getInputStream());
            var frame = new BinaryReader(in.readNBytes(in.readInt()));
            frame.u16(); frame.u16(); check(frame.i32()==0x360,"gold allocate reply"); frame.i32(); frame.u16();
            frame.i32(); check(frame.i32()==0,"gold allocated"); frame.i32(); tid=frame.i32();
        }
        try (var hall = new HallRoomCheck.HallSocket()) {
            login(hall,owner);
            check(select(hall,tid,activity,"0","0") == 0 && owner.tryRoom(hall,tid,activity).cmd() == 0x1007,"gold owner seated");
            command(hall,0x151,new BinaryWriter().u16(302));
            var list = new BinaryReader(DouniuCheck.waitFrame(hall,0x151).body());
            check(list.u8()==0 && list.u16()==1 && list.i32()==tid && list.i32()==activity && list.string().equals("840731"),"public gold row");
            list.string(); check(list.u8()==1 && list.i32()==0 && list.i32()==2 && list.u8()==4 && list.i32()==owner.uid(),"gold table properties");
            list.string(); list.string(); list.i32();
            check(list.u8()==1 && list.i32()==0 && list.string().isEmpty() && list.remaining()==0,"seat and empty password field");
        }
    }

    static void websocketPeer(String address) throws Exception {
        var client = HallRoomCheck.Client.register();
        var listener = new GatewayCheck.Listener();
        var ws = GatewayCheck.http.newWebSocketBuilder().header("X-Real-IP",address)
                .buildAsync(java.net.URI.create("ws://ci-gateway:8090/ws/hall"), listener).get(10, java.util.concurrent.TimeUnit.SECONDS);
        try {
            var hello = new BinaryWriter().i32(client.uid()).i32(1).u8(1).string(Json.write(Map.of("roomKey",client.roomKey())));
            var frame = com.j.joker.game.niuniu.proto.PacketCodec.encode(0x116,1,0,0,0,hello.toByteArray());
            ws.sendText(Base64.getEncoder().encodeToString(frame),true).join();
            var bytes = new java.io.ByteArrayOutputStream();
            for (int parts=0; parts<20; parts++) {
                byte[] chunk = listener.data.poll(5,java.util.concurrent.TimeUnit.SECONDS);
                check(chunk!=null, "missing forwarded WSS login");
                bytes.writeBytes(chunk);
                var in = new java.io.DataInputStream(new java.io.ByteArrayInputStream(bytes.toByteArray()));
                while (in.available() >= 4) {
                    int size = in.readInt();
                    if (in.available()<size) break;
                    byte[] packet = new BinaryWriter().i32(size).bytes(in.readNBytes(size)).toByteArray();
                    var result = com.j.joker.game.niuniu.proto.PacketCodec.decode(packet);
                    if (result.cmd()==0x202) {
                        var reported = new BinaryReader(result.body()).string();
                        check(java.net.InetAddress.getByName(address).equals(java.net.InetAddress.getByName(reported)), "forwarded player IP");
                        return;
                    }
                }
            }
            throw new AssertionError("no player IP in WSS login");
        } finally { ws.abort(); }
    }

    public static void main(String[] args) throws Exception {
        if (args.length>0) { recovery(args[0]); return; }
        gifts();robotAndHall();seatLimits(false);seatLimits(true);publicGoldList();
        websocketPeer("192.0.2.31"); websocketPeer("2001:db8::31");
        System.out.println("Verified authenticated gifts, recovery locks, robots, club bans, quick join, IP/GPS seating, public gold tables and IPv4/IPv6 forwarding through the WebSocket gateway.");
    }
}
