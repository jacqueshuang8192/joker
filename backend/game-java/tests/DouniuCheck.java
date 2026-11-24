import com.j.joker.game.niuniu.proto.BinaryReader;
import com.j.joker.game.niuniu.proto.BinaryWriter;
import com.j.joker.game.niuniu.proto.PacketCodec;

import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.file.Path;
import java.util.Map;

/**
 * JDK-only integration check for the douniu role: heartbeat, login, ready, deal, grab, bet, settle
 * over the real 18-byte wire format.
 *
 * <p>Usage (from backend/game-java): {@code java tests/DouniuCheck.java target/joker-game-java.jar}
 */
public class DouniuCheck {

    static void check(boolean ok, String message) {
        if (!ok) throw new AssertionError(message);
    }

    static void send(Socket socket, int cmd, byte[] body) throws Exception {
        socket.getOutputStream().write(PacketCodec.encode(cmd, body));
        socket.getOutputStream().flush();
    }

    static PacketCodec.Frame exchange(Socket socket, int cmd, byte[] body) throws Exception {
        send(socket, cmd, body);
        return PacketCodec.readFrame(socket.getInputStream());
    }

    static Socket connect(int port) throws Exception {
        Socket socket = new Socket();
        socket.connect(new InetSocketAddress("127.0.0.1", port), 500);
        socket.setSoTimeout(5000);
        return socket;
    }

    static PacketCodec.Frame login(Socket socket, int tid, int uid, String key, boolean extended) throws Exception {
        var body = new BinaryWriter().i32(tid).i32(uid);
        if (extended) {
            body.i32(-1).u8(1).string("player").string("").string("0").string("0")
                    .string("{\"roomKey\":\"" + key + "\"}").i32(0).u8(1);
        } else {
            body.string(key).string("{}");
        }
        return exchange(socket, 0x1001, body.toByteArray());
    }

    static Map<String,Object> decode(PacketCodec.Frame frame) {
        return com.j.joker.game.niuniu.proto.SchemaCodec.decode(
                com.j.joker.game.niuniu.proto.ProtoRegistry.server(frame.cmd()), frame.body());
    }

    static Map<String,Object> waitFor(Socket socket, int wanted) throws Exception {
        return decode(waitFrame(socket, wanted));
    }

    static PacketCodec.Frame waitFrame(Socket socket, int wanted) throws Exception {
        for (int i = 0; i < 60; i++) {
            var frame = PacketCodec.readFrame(socket.getInputStream());
            if (frame.cmd() == wanted) return frame;
        }
        throw new AssertionError("missing cmd " + Integer.toHexString(wanted));
    }

    static void play(int port, String firstKey, String secondKey, boolean online, int tid) throws Exception {
        try (var first = connect(port); var second = connect(port)) {
            check(exchange(first, 0x110, new byte[0]).cmd() == 0x110, "heartbeat");
            // 与 Cocos 的 buildHeart 和 EncryptBuffer 生成的带桌号心跳逐字节对照。
            var heartbeat = java.util.HexFormat.of().parseHex("0000001242590001000001100000000000ee452c702f");
            check(new BinaryReader(PacketCodec.decode(heartbeat).body()).i32() == 0x070a0001, "Cocos heartbeat table");
            first.getOutputStream().write(heartbeat);
            check(PacketCodec.readFrame(first.getInputStream()).cmd() == 0x110, "Cocos heartbeat acknowledged");
            if (online) {
                check(login(first, tid + 1, 424241, firstKey, false).cmd() == 0x1005, "wrong assigned table");
                check(login(first, tid, 424241, "", false).cmd() == 0x1005, "credential required");
            }
            var firstLogin = login(first, tid, 424241, firstKey, true);
            check(firstLogin.cmd() == 0x1007, "extended login");
            if (online) {
                var room = decode(firstLogin);
                check(room.get("inviteCode").equals("851001") && (int)room.get("start_id") == 851
                        && ((Number)room.get("base")).intValue() == 2, "allocated room configuration");
            }
            check(login(second, tid, 424251, secondKey, false).cmd() == 0x1007, "compact login");
            var initial = waitFor(first, 0x5101);
            check((int)initial.get("round") == 0 && (int)initial.get("round_total") >= 1, "initial round count");
            send(first, 0x1050, new BinaryWriter().i32(0).toByteArray());
            check((int) waitFor(first, 0x1050).get("resultIndex") == 0, "new room has no history");
            send(first, 0x1104, new BinaryWriter().i32(51).toByteArray());
            var face = waitFor(second, 0x1104);
            check((int)face.get("uid") == 424241 && (int)face.get("type") == 51, "same-table emoji");
            var msg = new BinaryWriter().u16(302).string("{\"uid\":999,\"msgType\":\"text\",\"textMessage\":\"同桌你好\"}");
            send(first, 0x801, msg.toByteArray());
            var chat = com.j.joker.game.niuniu.util.Json.parseObject((String) waitFor(second, 0x801).get("msg"));
            check(((Number)chat.get("uid")).intValue() == 424241 && "同桌你好".equals(chat.get("textMessage")), "room chat");
            var location = new BinaryWriter().u16(302).string("{\"uid\":999,\"longitude\":116,\"latitude\":39}");
            send(first, 0x165, location.toByteArray());
            var locations = (java.util.List<?>)waitFor(second, 0x213).get("msgList");
            var position = com.j.joker.game.niuniu.util.Json.parseObject((String)((Map<?,?>)locations.getFirst()).get("msg"));
            check(((Number)position.get("uid")).intValue() == 424241 && "39".equals(position.get("latitude")), "room location");
            send(first, 0x2001, new BinaryWriter().i32(1).toByteArray());
            check(((Number)waitFor(second, 0x6001).get("readyState")).intValue() == 1, "ready");
            send(first, 0x2001, new BinaryWriter().i32(0).toByteArray());
            check(((Number)waitFor(second, 0x6001).get("readyState")).intValue() == 0, "cancel ready");
            send(first, 0x2001, new byte[0]);
            send(second, 0x2001, new byte[0]);
            check((int)waitFor(first, 0x5101).get("round") == 1, "first round started");
            var firstDeal = (java.util.List<?>) waitFor(first, 0x4001).get("cards");
            var secondDeal = (java.util.List<?>) waitFor(second, 0x4001).get("cards");
            check(firstDeal.size() == (online ? 3 : 4) && firstDeal.stream().distinct().count() == firstDeal.size(), "visible cards");
            waitFor(first, 0x6015);
            send(first, 0x2007, new BinaryWriter().i32(2).toByteArray());
            send(second, 0x2007, new BinaryWriter().i32(0).toByteArray());
            waitFor(first, 0x7001);
            second.close();
            try (var reconnect = connect(port)) {
                var frame = login(reconnect, tid, 424251, secondKey, true);
                check(frame.cmd() == 0x1007, "reconnect");
                var view = decode(frame);
                check((int)waitFor(reconnect, 0x5101).get("round") == 1, "round after reconnect");
                check(((Number)view.get("table_status")).intValue() == 3, "client betting phase");
                if (online) check(((Number)view.get("activityId")).intValue() == Integer.parseInt(System.getenv("ROOM_ACTIVITY")), "assigned activity");
                check(view.get("cards").equals(secondDeal) && (int)view.get("bank_uid") == 424241, "reconnected hand and banker");
                check(((java.util.List<?>)view.get("users_infos")).size() == 1, "other seat restored");
                if ("1".equals(System.getenv("PAUSE_BEFORE_BET"))) {
                    System.out.println("WAITING_FOR_DISSOLVE");
                    check("continue".equals(new java.io.BufferedReader(new java.io.InputStreamReader(System.in)).readLine()), "dissolve coordination");
                }
                var available = (java.util.List<?>)view.get("can_selects_base");
                if (!available.isEmpty()) {
                    int stake = available.contains(2) ? 2 : ((Number)available.getFirst()).intValue();
                    send(reconnect, 0x2008, new BinaryWriter().i32(stake).toByteArray());
                }
                var completeHand = (java.util.List<?>)waitFor(first, 0x4001).get("cards");
                waitFor(first, 0x6004);
                send(first, 0x2003, new byte[]{3,0,0,0});
                send(first, 0x2003, new byte[]{3,0,0,0});
                var shown = waitFor(reconnect, 0x6005);
                check((int)shown.get("uid") == 424241 && shown.get("cards").equals(completeHand), "reveal actual hand");
                send(reconnect, 0x2003, new byte[]{3,0,0,0});
                var sideReveal = waitFor(reconnect, 0x6005);
                check((int)sideReveal.get("uid") == 424251 && ((java.util.List<?>)sideReveal.get("cards"))
                        .subList(0, secondDeal.size()).equals(secondDeal), "one reveal per player");
                var end = waitFor(first, 0x6008);
                var users = (java.util.List<?>)end.get("userinfo");
                var other = (Map<?,?>)users.getFirst();
                check(((java.util.List<?>)end.get("handCards")).subList(0, firstDeal.size()).equals(firstDeal), "banker fixed hand");
                check(((java.util.List<?>)other.get("handCards")).subList(0, secondDeal.size()).equals(secondDeal), "player fixed hand");
                check((int)end.get("banker_win_chip") + (int)other.get("win_chip") == 0, "zero-sum broadcast");
                if (!online || "1".equals(System.getenv("CHECK_HISTORY"))) {
                    for (int index : new int[]{0, 1, 500}) {
                        send(first, 0x1050, new BinaryWriter().i32(index).toByteArray());
                        var record = waitFor(first, 0x1050);
                        check((int)record.get("resultIndex") == 1 && (int)record.get("resultCount") == 1, "history page");
                        var seats = (java.util.List<?>)record.get("gameResult");
                        var bank = (Map<?,?>)seats.getFirst();
                        var side = (Map<?,?>)seats.getLast();
                        check(seats.size() == 2 && bank.get("cards").equals(end.get("handCards"))
                                && side.get("cards").equals(other.get("handCards"))
                                && side.get("changeChip").equals(other.get("win_chip")), "history matches settlement");
                    }
                    send(first, 0x808, new byte[0]);
                    waitFor(reconnect, 0x909);
                    send(reconnect, 0x809, new BinaryWriter().i32(0).toByteArray());
                    check((int)waitFor(first, 0x104a).get("rejectId") == 424251, "vote refusal");
                    send(first, 0x808, new byte[0]);
                    waitFor(reconnect, 0x909);
                    send(reconnect, 0x809, new BinaryWriter().i32(1).toByteArray());
                }
                var board = waitFor(first, 0x5100);
                var standings = (java.util.List<?>)board.get("playerlist");
                check((int)board.get("game_amount") == 1 && standings.size() == 2, "room scoreboard");
                check(((Map<?,?>)standings.getFirst()).get("chips").equals(end.get("banker_win_chip")) &&
                        ((Map<?,?>)standings.getLast()).get("chips").equals(other.get("win_chip")), "scores match ledger");
                if (!online || "1".equals(System.getenv("CHECK_HISTORY"))) waitFor(first, 0x103a);
                System.out.println("DouniuCheck OK " + end.get("banker_chips") + " " + other.get("chips"));
            }
        }
    }

    static void restartRound(int port, int tid) throws Exception {
        String a = System.getenv("FIRST_ROOM_KEY"), b = System.getenv("SECOND_ROOM_KEY");
        var control = new java.io.BufferedReader(new java.io.InputStreamReader(System.in));
        Object handA, handB;
        int stake;
        try (var first = connect(port); var second = connect(port)) {
            check(login(first, tid, 424241, a, true).cmd() == 0x1007, "join first");
            check(login(second, tid, 424251, b, false).cmd() == 0x1007, "join second");
            send(first, 0x2001, new byte[0]);
            send(second, 0x2001, new byte[0]);
            handA = waitFor(first, 0x4001).get("cards");
            handB = waitFor(second, 0x4001).get("cards");
            waitFor(first, 0x6015);
            send(first, 0x2007, new BinaryWriter().i32(2).toByteArray());
            waitFor(first, com.j.joker.game.niuniu.proto.Cmd.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST);
            send(first, 0x808, new byte[0]);
            check((int)waitFor(second, 0x909).get("applyId") == 424241, "vote started before restart");
            System.out.println("RESTART_AFTER_GRAB");
            port = Integer.parseInt(control.readLine()); // 保持连接，直到测试器强制终止进程。
        }
        try (var first = connect(port); var second = connect(port)) {
            var restored = decode(login(first, tid, 424241, a, true));
            check(restored.get("cards").equals(handA) && ((Number)restored.get("user_status")).intValue() == 4,
                    "first hand and acknowledged grab restored");
            check(decode(login(second, tid, 424251, b, false)).get("cards").equals(handB), "second hand restored");
            check((int)waitFor(second, 0x909).get("applyId") == 424241, "vote resumes after restart");
            send(second, 0x2007, new BinaryWriter().i32(0).toByteArray());
            var betting = (java.util.List<?>)waitFor(second, 0x7001).get("can_selects_base");
            stake = 1;
            if (!betting.isEmpty()) {
                var options = betting.stream().map(row -> ((Number)((Map<?,?>)row).get("times")).intValue()).toList();
                stake = options.contains(2) ? 2 : options.getFirst();
                send(second, 0x2008, new BinaryWriter().i32(stake).toByteArray());
            }
            waitFor(first, 0x4001); // 亮牌后，data 会提交但测试转发器暂扣成功应答。
            System.out.println("RESTART_DURING_SETTLEMENT");
            port = Integer.parseInt(control.readLine());
        }
        try (var first = connect(port); var second = connect(port)) {
            var restored = decode(login(first, tid, 424241, a, true));
            var other = decode(login(second, tid, 424251, b, false));
            check(((Number)restored.get("bank_uid")).intValue() == 424241, "banker restored");
            check(((Number)other.get("user_base_calltime")).intValue() == stake, "bet restored");
            check(((java.util.List<?>)restored.get("cards")).subList(0, 3).equals(handA), "settlement cards restored");
            System.out.println("CONFIRM_SETTLEMENT");
            first.setSoTimeout(15000);
            var end = waitFor(first, 0x6008);
            var opponent = (Map<?,?>)((java.util.List<?>)end.get("userinfo")).getFirst();
            check(end.get("handCards").equals(restored.get("cards")) && opponent.get("handCards").equals(other.get("cards")),
                    "settled hands match recovered hands");
            var scores = waitFor(first, 0x5100);
            check((int)scores.get("game_amount") == 1 && ((java.util.List<?>)scores.get("playerlist")).size() == 2,
                    "recovered room scoreboard");
            waitFor(first, 0x103a); // 停机期间投票到期，按原局结算后解散。
            System.out.println("DouniuCheck OK " + end.get("banker_chips") + " " + opponent.get("chips"));
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length == 3 && args[0].equals("--restart")) {
            restartRound(Integer.parseInt(args[1]), Integer.parseInt(args[2]));
            return;
        }
        if (args.length == 3 && args[0].equals("--closed")) {
            try (var client = connect(Integer.parseInt(args[1]))) {
                check(login(client, Integer.parseInt(args[2]), 424241, System.getenv("FIRST_ROOM_KEY"), false).cmd() == 0x1005,
                        "stale admission must not recreate a closed room");
            }
            return;
        }
        if (args.length == 3 && args[0].equals("--port")) {
            play(Integer.parseInt(args[1]), System.getenv("FIRST_ROOM_KEY"), System.getenv("SECOND_ROOM_KEY"), true, Integer.parseInt(args[2]));
            return;
        }
        int port;
        try (var probe = new ServerSocket(0)) { port = probe.getLocalPort(); }
        var builder = new ProcessBuilder(Path.of(System.getProperty("java.home"), "bin", "java").toString(),
                "-jar", args[0]).inheritIO();
        builder.environment().putAll(Map.of("GAME_ROLE", "douniu", "GAME_PORT", Integer.toString(port),
                "GAME_BIND_ADDRESS", "127.0.0.1", "DOUNIU_LOCAL_DEMO", "true", "DOUNIU_DATA_ENABLED", "0"));
        Process service = builder.start();
        try {
            for (int i = 0; i < 150 && service.isAlive(); i++) {
                try (var probe = connect(port)) { break; }
                catch (java.io.IOException e) { Thread.sleep(100); }
            }
            play(port, "k", "k", false, 1);
        } finally {
            service.destroy();
            service.waitFor();
        }
    }
}
