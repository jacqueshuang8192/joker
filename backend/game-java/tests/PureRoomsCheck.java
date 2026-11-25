import com.j.joker.game.niuniu.proto.BinaryReader;
import com.j.joker.game.niuniu.proto.BinaryWriter;
import com.j.joker.game.niuniu.proto.PacketCodec;
import com.j.joker.game.niuniu.util.Json;
import java.nio.file.*;
import java.util.Map;
import java.net.Socket;
import java.time.Instant;

/** A 桌自然结束，B 桌跨进程重启重连续局。运行于临时 api 容器。 */
public class PureRoomsCheck {
    record Table(HallRoomCheck.Client owner, HallRoomCheck.Client guest, int tid, int activity) {
        static Table open() throws Exception {
            var owner = HallRoomCheck.Client.register();
            var guest = HallRoomCheck.Client.register();
            var rules = Map.of("level", 302, "gameId", 302, "subGameType", 1, "maxSeatCount", 6,
                    "round", 2, "showCardNums", 3, "cardCount", 4, "baseChip", 1);
            var room = (Map<?,?>)owner.request("/freeGame/createFreeGameByOthers", Map.of("gameId",302,"name","双桌回归",
                    "level",302,"round",2,"others",1,"baseChip",1,"json",Json.write(rules)));
            int activity = Integer.parseInt(room.get("gameActivityId").toString());
            guest.request("/joinFreeGame", Map.of("type","P","invitationCode",room.get("inviteCode"),
                    "activityId",activity,"level",302,"isWatch",1));
            return new Table(owner,guest,Integer.parseInt(room.get("tableId").toString()),activity);
        }

        void enter(HallRoomCheck.HallSocket a, HallRoomCheck.HallSocket b) throws Exception {
            owner.enter(a, tid, activity);
            guest.enter(b, tid, activity);
        }
    }

    static int queryOnline(int uid) throws Exception {
        try (var s = new Socket("127.0.0.1", 7500)) {
            s.setSoTimeout(3000);
            s.getOutputStream().write(new BinaryWriter().i32(18).u16(0x4259).u16(0).i32(0xa1).i32(0)
                    .u16(0).i32(uid).toByteArray());
            var r = new java.io.DataInputStream(s.getInputStream());
            DouniuCheck.check(r.readInt()==22,"user reply frame");
            r.skipNBytes(14);
            DouniuCheck.check(r.readInt()==uid,"online query uid");
            return r.readInt();
        }
    }

    static void checkClosed(Table t) throws Exception {
        try (var hall = new HallRoomCheck.HallSocket()) {
            HallRoomCheck.Client.hallCommand(hall,0x116,new BinaryWriter().i32(t.owner.uid()).i32(1).u8(1)
                    .string(Json.write(Map.of("roomKey",t.owner.roomKey()))));
            DouniuCheck.check(PacketCodec.readFrame(hall.getInputStream()).cmd()==0x201,"login after closure");
            HallRoomCheck.Client.hallCommand(hall,0x668,new BinaryWriter());
            var ip = PacketCodec.readFrame(hall.getInputStream());
            DouniuCheck.check(ip.cmd() == 0x202 && "127.0.0.1".equals(new BinaryReader(ip.body()).string()), "observed hall peer");
            var status=PacketCodec.readFrame(hall.getInputStream());
            DouniuCheck.check(status.cmd()==0x668 && new BinaryReader(status.body()).u16()==0,"closed route removed");
            HallRoomCheck.Client.hallCommand(hall,0x113,new BinaryWriter().u16(302).i32(0).i32(0).i32(t.tid)
                    .i32(t.activity).i32(1).u8(1).i32(0).string("").string(""));
            DouniuCheck.check(PacketCodec.readFrame(hall.getInputStream()).cmd()==0x212,"closed room stays closed");
        }
    }

    public static void main(String[] args) throws Exception {
        // 仅知道 UID 或桌号都不能获得入房路由。
        var outsider = HallRoomCheck.Client.register();
        try (var hall = new HallRoomCheck.HallSocket()) {
            HallRoomCheck.Client.hallCommand(hall,0x116,new BinaryWriter().i32(outsider.uid()).i32(1).u8(1)
                    .string(Json.write(Map.of("roomKey", "0".repeat(64)))));
            DouniuCheck.check(hall.getInputStream().read()==-1,"invalid hall credential refused");
        }
        var first=Table.open();
        try (var hall = new HallRoomCheck.HallSocket()) {
            HallRoomCheck.Client.hallCommand(hall,0x116,new BinaryWriter().i32(outsider.uid()).i32(1).u8(1)
                    .string(Json.write(Map.of("roomKey", outsider.roomKey()))));
            DouniuCheck.waitFrame(hall,0x201);
            HallRoomCheck.Client.hallCommand(hall,0x113,new BinaryWriter().u16(302).i32(0).i32(0).i32(first.tid)
                    .i32(first.activity).i32(1).u8(1).i32(0).string("").string(""));
            DouniuCheck.waitFrame(hall,0x212);
        }
        var other=Table.open();
        DouniuCheck.check(first.tid!=other.tid && first.activity!=other.activity,"independent routes");
        try (var a=new HallRoomCheck.HallSocket(); var b=new HallRoomCheck.HallSocket();
             var c=new HallRoomCheck.HallSocket(); var d=new HallRoomCheck.HallSocket()) {
            first.enter(a,b);
            other.enter(c,d);
            DouniuCheck.check(queryOnline(other.owner.uid())==1,"online user lookup");
            // API 控制端口的定向通知应抵达目标玩家，大厅的公开端口只处理玩家协议。
            try (var apiPush = new Socket("127.0.0.1",4701)) {
                var target = new BinaryWriter().i32(1).i32(first.owner.uid()).string("{\"type\":\"testNotice\"}");
                apiPush.getOutputStream().write(new BinaryWriter().i32(14+target.size()).u16(0x4259).u16(1)
                        .i32(0x168).i32(0).u16(0).bytes(target.toByteArray()).toByteArray());
                var notice = new BinaryReader(DouniuCheck.waitFrame(a,0x168).body());
                DouniuCheck.check(notice.i32()==first.owner.uid() && notice.string().contains("testNotice"),"private API notification");
            }
            HallRoomCheck.playRound(c,d,1);
            HallRoomCheck.playRound(a,b,1);
            HallRoomCheck.playRound(a,b,2);
            DouniuCheck.waitFor(a,0x5100);
            HallRoomCheck.Client.hallCommand(c,0x668,new BinaryWriter());
            var status=new BinaryReader(DouniuCheck.waitFrame(c,0x668).body());
            DouniuCheck.check(status.u16()==302 && status.i32()==other.tid,"other room still routed");
        }
        checkClosed(first);
        Files.createFile(Path.of("/tmp/pure-rooms-restart"));
        var until=Instant.now().plusSeconds(150);
        while (!Files.exists(Path.of("/tmp/pure-rooms-resume"))) {
            if (Instant.now().isAfter(until)) throw new AssertionError("waiting for rooms restart");
            Thread.sleep(250);
        }
        checkClosed(first);
        try (var c=new HallRoomCheck.HallSocket(); var d=new HallRoomCheck.HallSocket()) {
            other.enter(c,d);
            HallRoomCheck.playRound(c,d,2);
            DouniuCheck.waitFor(c,0x5100);
        }
        var config=new java.util.Properties();
        try(var input=Files.newInputStream(Path.of(System.getenv("JOKER_CONFIG")))) {config.load(input);}
        try(var db=java.sql.DriverManager.getConnection(config.getProperty("jdbc.url"),config.getProperty("jdbc.user"),
                    config.getProperty("jdbc.password"));
            var q=db.prepareStatement("SELECT r.round_index, COUNT(*), SUM(s.projected) FROM t_free_game_round r "
                    + "JOIN joker_douniu_settlement s ON s.round_id=r.douniu_round_id WHERE r.activity_id=? "
                    + "GROUP BY r.round_index ORDER BY r.round_index")) {
            for(var t:java.util.List.of(first,other)) {
                q.setInt(1,t.activity);
                try(var rows=q.executeQuery()) {
                    for(int i=1;i<=2;i++) DouniuCheck.check(rows.next() && rows.getInt(1)==i && rows.getInt(2)==1
                            && rows.getInt(3)==1,"exactly one projected receipt per round");
                    DouniuCheck.check(!rows.next(),"two rounds only");
                }
            }
        }
        System.out.println("Verified independent Java tables, online lookup, recovered routing, and one receipt per round.");
    }
}
