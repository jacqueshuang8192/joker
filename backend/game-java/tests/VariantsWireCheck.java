import com.j.joker.game.niuniu.proto.BinaryWriter;
import com.j.joker.game.niuniu.util.Json;
import java.io.DataInputStream;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.sql.*;
import java.util.*;

/** 通过真实 HTTP、大厅 TCP 和 data TCP 在独立编排验证模板、外围和收账回执。 */
public class VariantsWireCheck {
    static Connection db() throws Exception {
        var props=new Properties();
        try(var f=java.nio.file.Files.newInputStream(java.nio.file.Path.of(System.getenv("JOKER_CONFIG")))) { props.load(f); }
        return DriverManager.getConnection(props.getProperty("jdbc.url"),props.getProperty("jdbc.user"),props.getProperty("jdbc.password"));
    }
    static int scalar(Connection db,String sql,int key) throws SQLException {
        try(var q=db.prepareStatement(sql)) {
            q.setInt(1,key);
            try(var rs=q.executeQuery()){ if(!rs.next()) throw new AssertionError(sql); return rs.getInt(1); }
        }
    }
    static byte[] data(int cmd,byte[] body) throws Exception {
        try(var s=new Socket("127.0.0.1",6001); var in=new DataInputStream(s.getInputStream())) {
            s.setSoTimeout(5000);
            s.getOutputStream().write(ByteBuffer.allocate(18+body.length).putInt(14+body.length).putShort((short)0x4259)
                    .putShort((short)0).putInt(cmd).putInt(0).putShort((short)0).put(body).array());
            int length=in.readInt();
            var response=ByteBuffer.wrap(in.readNBytes(length));
            int expected = switch (cmd) {
                case 0x1005 -> 0x2002;
                case 0x301a, 0x301d -> cmd;
                default -> cmd + 0x1000;
            };
            check(response.getInt(4) == expected, "unexpected data reply to " + Integer.toHexString(cmd));
            return Arrays.copyOfRange(response.array(),14,length);
        }
    }
    static void check(boolean ok,String why) { if(!ok) throw new AssertionError(why); }
    static void play(boolean gong, boolean claimed) throws Exception {
        var owner=HallRoomCheck.Client.register(); var guest=HallRoomCheck.Client.register();
        var dealer = claimed ? HallRoomCheck.Client.register() : null;
        var standing = claimed ? HallRoomCheck.Client.register() : null;
        var members = claimed ? List.of(owner, guest, dealer, standing) : List.of(owner, guest);
        int club = HallRoomCheck.clubFixture(owner, members.toArray(HallRoomCheck.Client[]::new));
        try(var db=db()) {
            int template;
            try(var q=db.prepareStatement("INSERT INTO t_group_gameconfig(group_id,level,config,game_type,status) VALUES(?,302,?,15,1)",Statement.RETURN_GENERATED_KEYS)){
                q.setInt(1,club);
                q.setString(2,Json.write(Map.of("profit",20,"profitLimit",0,"rateOrConstant",1,"oneOrAll",1,"startCost",25,"startCostOneOrAll",1,"upBankWater",gong?2:0,"downBankWater",gong?10:0)));
                q.executeUpdate();try(var keys=q.getGeneratedKeys()){keys.next();template=keys.getInt(1);}
            }
            for(var c:members) {
                // 用旧接口给钱包充值、买筹码，再使用相同的账号开局、扣费和结算。
                var credit = new BinaryWriter().i32(0).string("variant-test").i32(c.uid()).i32(24000).string("");
                check(ByteBuffer.wrap(data(0x1005, credit.toByteArray())).getInt(4) == 0, "credit wallet");
                var purchase = new BinaryWriter().i32(c.uid()).i32(0).i32(20000).i32(1200).i32(0);
                var funded = ByteBuffer.wrap(data(0x301a, purchase.toByteArray()));
                check(funded.getInt() == 1 && funded.getInt() == 20000, "buy chips");
                check(scalar(db, "SELECT chip FROM bullfight_gameinfo" + c.uid()%10 + " WHERE mid=?", c.uid()) == 20000,
                        "purchased chips persisted before play");
            }
            var rules=Map.of("subGameType",gong?5:1,"hasLeper",gong?2:1,"waiwei","1","guodi",30,
                    "maxSeatCount",claimed ? 4 : 2,"round",2,"grabTimes",1,"profit",99,"baseChip",1);
            var room=(Map<?,?>)owner.request("/freeGame/createFreeGameByOthers",Map.of("gameId",302,"name","变体联调","level",302,
                    "round",2,"others",1,"baseChip",1,"groupId",club,"configId",template,"json",Json.write(rules)));
            int tid=Integer.parseInt(room.get("tableId").toString());
            int activity=Integer.parseInt(room.get("gameActivityId").toString());
            for (var member : members.subList(1, members.size())) member.request("/joinFreeGame",Map.of("type","P","invitationCode",room.get("inviteCode"),"activityId",activity,"level",302,"isWatch",1));
            try(var a=new HallRoomCheck.HallSocket();var b=new HallRoomCheck.HallSocket();
                var d=claimed ? new HallRoomCheck.HallSocket() : null;
                var w=claimed ? new HallRoomCheck.HallSocket() : null) {
                var info=owner.enter(a,tid,activity,1); guest.enter(b,tid,activity);
                if (claimed) {
                    dealer.enter(d,tid,activity);
                    HallRoomCheck.Client.hallCommand(d,0x1032,new BinaryWriter());
                    DouniuCheck.waitFor(d,0x1032);
                    standing.enter(w,tid,activity);
                    HallRoomCheck.Client.hallCommand(w,0x1032,new BinaryWriter());
                    DouniuCheck.waitFor(w,0x1032);
                }
                check("20".equals(Json.parseObject((String)info.get("gameConfig")).get("profit").toString()),"stored club rate overrides HTTP value");
                for(var s:List.of(a,b)) HallRoomCheck.Client.hallCommand(s,0x2001,new BinaryWriter().i32(1));
                var start=DouniuCheck.waitFor(a,0x6002);
                check(((List<?>)start.get("lepers")).size()==(gong?1:2),"wildcard announcement");
                DouniuCheck.waitFor(a,0x6015);
                HallRoomCheck.Client.hallCommand(a,0x2007,new BinaryWriter().i32(1)); HallRoomCheck.Client.hallCommand(b,0x2007,new BinaryWriter().i32(0));
                DouniuCheck.waitFor(b,0x7001); HallRoomCheck.Client.hallCommand(b,0x2008,new BinaryWriter().i32(gong?10:1));
                var bet=DouniuCheck.waitFor(a,0x6014);
                check(((Number)bet.get("isSheMen")).intValue()==(gong?1:0),"shot flag");
                DouniuCheck.waitFor(a,0x110c);
                if (claimed) HallRoomCheck.Client.hallCommand(d,0x110a,new BinaryWriter());
                check((int)DouniuCheck.waitFor(a,0x110a).get("waiwei_banker_uid") == (claimed ? dealer.uid() : 0), "side banker");
                HallRoomCheck.Client.hallCommand(b,0x1040,new BinaryWriter().i32(1).i32(5));
                check((int)DouniuCheck.waitFor(b,0x1040).get("costCoins")==5,"accepted side wager");
                var competing = new BinaryWriter().string(UUID.randomUUID().toString()).i32(guest.uid()).i32(20000);
                check(ByteBuffer.wrap(data(0x1018,competing.toByteArray())).getInt() != 0, "second room cannot reserve same account");
                check(ByteBuffer.wrap(data(0x301d,new BinaryWriter().i32(guest.uid()).i32(0).toByteArray())).getInt() != 0,
                        "in-flight wager prevents redemption");
                if (claimed) {
                    HallRoomCheck.Client.hallCommand(w,0x1040,new BinaryWriter().i32(1).i32(2));
                    DouniuCheck.waitFor(b,0x1040);
                }
                HallRoomCheck.Client.hallCommand(b,0x1106,new BinaryWriter());
                check(((List<?>)DouniuCheck.waitFor(b,0x1106).get("players_bet_situation")).size()==2,"snapshot of bets");
                HallRoomCheck.Client.hallCommand(b,0x1107,new BinaryWriter().i32(1));
                check(((List<?>)DouniuCheck.waitFor(b,0x1107).get("players_bet_situation")).size()==(claimed?2:1),"bet detail");
                for(var s:List.of(a,b)) {
                    DouniuCheck.waitFor(s,0x6004);
                    HallRoomCheck.Client.hallCommand(s,0x2003,new BinaryWriter().bytes(new byte[]{3,0,0,0}));
                }
                DouniuCheck.waitFor(a,0x6008); DouniuCheck.waitFor(a,0x110b);
                if (!gong) {
                    var terms = Map.of("profit",20,"profitLimit",0,"rateOrConstant",1,"oneOrAll",1,
                            "activeElsewhere", List.of(owner.uid(),guest.uid()));
                    var close = new BinaryWriter().i32(club).i32(activity).i32(302).i32(1)
                            .bytes(Json.write(terms).getBytes(java.nio.charset.StandardCharsets.UTF_8));
                    check(ByteBuffer.wrap(data(0x1017,close.toByteArray())).getInt()==2, "in-flight hand defers closing debit");
                    check(scalar(db,"SELECT COUNT(*) FROM joker_douniu_club_bill WHERE activity_id=?",activity)==0, "deferred close has no debit");
                }
                HallRoomCheck.Client.hallCommand(a,0x808,new BinaryWriter());
                DouniuCheck.waitFor(b,0x102a);
                HallRoomCheck.Client.hallCommand(b,0x809,new BinaryWriter().i32(1));
                DouniuCheck.waitFor(a,0x5100);
            }
            int sideDelta = scalar(db,"SELECT dealer_delta FROM joker_douniu_side_ledger WHERE activity_id=?",activity);
            check(Math.abs(sideDelta) == (claimed ? 7 : 5), "balanced side ledger");
            check(scalar(db,"SELECT dealer_uid FROM joker_douniu_side_ledger WHERE activity_id=?",activity)
                    == (claimed ? dealer.uid() : 0), "dealer account on receipt");
            if (claimed) {
                check(scalar(db,"SELECT chip FROM bullfight_gameinfo" + dealer.uid()%10 + " WHERE mid=?",dealer.uid()) == 20000+sideDelta,
                        "standing dealer credited once");
                check(scalar(db,"SELECT chip FROM bullfight_gameinfo" + standing.uid()%10 + " WHERE mid=?",standing.uid()) == 20000-2*Integer.signum(sideDelta),
                        "standing player credited once");
            }
            check(scalar(db,"SELECT COUNT(*) FROM joker_douniu_side_hold h JOIN joker_douniu_side_ledger l ON l.round_id=h.round_id WHERE l.activity_id=?",activity)==0,
                    "reservation released");
            replay(db, activity);
            int fee=scalar(db,"SELECT fee_total FROM joker_douniu_club_bill WHERE activity_id=? AND round_index="+(gong?1:0),activity);
            int charges=scalar(db,"SELECT SUM(amount) FROM joker_table_charge WHERE projected=1 AND activity_id=?",activity);
            check(scalar(db,"SELECT SUM(amount) FROM joker_table_charge WHERE kind='START' AND activity_id=?",activity)==50,"two opening fees");
            if (gong) check(scalar(db,"SELECT SUM(amount) FROM joker_table_charge WHERE kind='UP' AND activity_id=?",activity)==60,"banker entry fee");
            replayCharge(db,activity);
            check(fee>0 && fee+charges==scalar(db,"SELECT SUM(profit) FROM t_group_xiaohao_history WHERE activity_id=?",activity),"balanced fee distribution");
            check(fee==scalar(db,"SELECT SUM(base_fee+additional_fee) FROM joker_douniu_club_debit WHERE activity_id=? AND projected=1",activity),"fee charged and projected");
            if(!gong) {
                var committedRules = Map.of("profit",20,"profitLimit",0,"rateOrConstant",1,"oneOrAll",1);
                var prefix = new BinaryWriter().i32(club).i32(activity).i32(302).i32(1).toByteArray();
                var retry = new BinaryWriter().bytes(prefix).bytes(Json.write(committedRules).getBytes(java.nio.charset.StandardCharsets.UTF_8));
                var conflict = new BinaryWriter().bytes(prefix).bytes(Json.write(rules).getBytes(java.nio.charset.StandardCharsets.UTF_8));
                check(ByteBuffer.wrap(data(0x1017,conflict.toByteArray())).getInt()!=0,"conflicting close refused");
                check(ByteBuffer.wrap(data(0x1017,retry.toByteArray())).getInt()==0,"idempotent club close");
                check(scalar(db,"SELECT COUNT(*) FROM joker_douniu_club_bill WHERE activity_id=?",activity)==1,"one club receipt");
            }
        }
    }
    static void replayCharge(Connection db,int activity) throws Exception {
        try (var q=db.prepareStatement("SELECT event_id,kind,club_id,level_id,round_index,uid,before_chips,amount FROM joker_table_charge WHERE activity_id=? LIMIT 1")) {
            q.setInt(1,activity);
            try (var row=q.executeQuery()) {
                check(row.next(),"fee receipt missing");
                for (int alteration : new int[]{0,1}) {
                    var payload=new BinaryWriter().string(row.getString(1)).string(row.getString(2)).i32(activity);
                    for (int i=3; i<=7; i++) payload.i32(row.getInt(i));
                    int result=ByteBuffer.wrap(data(0x1019,payload.i32(row.getInt(8)+alteration).toByteArray())).getInt();
                    check((result==0)==(alteration==0),"fee replay and conflict");
                }
            }
        }
    }
    static void replay(Connection db, int activity) throws Exception {
        try (var q = db.prepareStatement("""
                SELECT r.douniu_round_id, r.content, s.balances FROM t_free_game_round r
                JOIN joker_douniu_settlement s ON s.round_id=r.douniu_round_id WHERE r.activity_id=?""")) {
            q.setInt(1,activity);
            try (var rs = q.executeQuery()) {
                check(rs.next(), "round receipt");
                String content = rs.getString(2);
                var record = com.j.joker.game.niuniu.application.history.RoundRecord.parse(content);
                var balance = new HashMap<Integer,int[]>();
                for (String item : rs.getString(3).split(",")) {
                    int[] row = Arrays.stream(item.split(":")).mapToInt(Integer::parseInt).toArray();
                    balance.put(row[0],row);
                }
                var request = new BinaryWriter().string(rs.getString(1)).i32(record.userinfos().size());
                for (var seat : record.userinfos()) for (int field : balance.get(seat.uid())) request.i32(field);
                request.bytes(content.getBytes(java.nio.charset.StandardCharsets.UTF_8));
                check(ByteBuffer.wrap(data(0x1010,request.toByteArray())).getInt()==0, "repeated settlement acknowledged");
            }
        }
    }
    public static void main(String[] args) throws Exception {
        play(true,true); play(false,false);
        System.out.println("Verified funded players, wildcard announcements, shot, standing bettors, player and system dealers, wager holds, repeat receipts, trusted club template and posted fees via real sockets.");
    }
}
