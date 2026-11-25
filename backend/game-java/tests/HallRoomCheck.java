import com.j.joker.game.niuniu.proto.BinaryReader;
import com.j.joker.game.niuniu.proto.BinaryWriter;
import com.j.joker.game.niuniu.proto.PacketCodec;
import com.j.joker.game.niuniu.util.Json;

import java.net.Socket;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/** 在隔离的完整编排中，用新账号走 HTTP、原生大厅、alloc 和 Java 牛牛。 */
public class HallRoomCheck {
    private static final HttpClient HTTP = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
    private static final String API = "http://127.0.0.1:8080/hbiInterface";

    /** 跟 Cocos 一样每两秒把当前桌号发给大厅，直到客户端退桌或关闭连接。 */
    static class HallSocket extends Socket {
        private final java.util.concurrent.ScheduledExecutorService timer =
                java.util.concurrent.Executors.newSingleThreadScheduledExecutor();
        volatile int tid;

        HallSocket() throws Exception {
            super("127.0.0.1", 4700);
            setSoTimeout(10000);
            timer.scheduleAtFixedRate(() -> {
                try {
                    if (tid > 0) Client.hallCommand(this, 0x110, new BinaryWriter().i32(tid));
                } catch (java.io.IOException lost) {
                    timer.shutdown();
                }
            }, 2, 2, java.util.concurrent.TimeUnit.SECONDS);
        }
        void leave() throws Exception {
            tid = 0;
            Client.hallCommand(this, 0x1033, new BinaryWriter());
            DouniuCheck.waitFor(this, 0x1033);
        }
        @Override public void close() throws java.io.IOException {
            timer.shutdownNow();
            super.close();
        }
    }

    static Object post(String path, Map<String, ?> fields, boolean json) throws Exception {
        String body = json ? Json.write(fields) : fields.entrySet().stream().map(e -> e.getKey() + "="
                + URLEncoder.encode(e.getValue().toString(), StandardCharsets.UTF_8)).collect(Collectors.joining("&"));
        var req = HttpRequest.newBuilder(URI.create(API + path)).timeout(Duration.ofSeconds(20))
                .header("Content-Type", json ? "application/json" : "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(body)).build();
        var response = HTTP.send(req, HttpResponse.BodyHandlers.ofString());
        var result = Json.parseObject(response.body());
        if (!"0".equals(result.get("returnCode"))) throw new AssertionError(path + " " + result.get("error"));
        return result.get("data");
    }

    record Client(int uid, String token, String roomKey, String nick) {
        static Client register() throws Exception {
            String nick = "Room_" + UUID.randomUUID().toString().substring(0, 8);
            var form = Map.of("username", nick, "password", UUID.randomUUID().toString(), "device", 2);
            post("/playerUser/username/register", form, true);
            var login = (Map<?,?>) post("/playerUser/username/login", form, true);
            int uid = ((Number)login.get("userId")).intValue();
            String token = login.get("token").toString();
            var bootstrap = (Map<?,?>) post("/playerUser/getUserInfo4GameServer", Map.of("XYUid", uid, "XYToken", token), false);
            return new Client(uid, token, bootstrap.get("douniuKey").toString(), nick);
        }

        Object request(String path, Map<String,?> fields) throws Exception {
            Map<String,Object> params = new LinkedHashMap<>(fields);
            params.put("XYUid", uid);
            params.put("XYToken", token);
            return post(path, params, false);
        }

        static void hallCommand(Socket hall, int cmd, BinaryWriter payload) throws java.io.IOException {
            synchronized (hall) {
                hall.getOutputStream().write(PacketCodec.encode(cmd, 1, 0, 0, 0, payload.toByteArray()));
                hall.getOutputStream().flush();
            }
        }

        void enter(HallSocket hall, int tid, int activity) throws Exception {
            enter(hall, tid, activity, 1);
        }

        PacketCodec.Frame roomLogin(HallSocket hall, int tid, int activity, int mode) throws Exception {
            hall.setSoTimeout(10000);
            var profile = Boolean.parseBoolean(System.getenv("JOKER_PURE_JAVA"))
                    ? Json.write(Map.of("roomKey", roomKey))
                    : Json.write(Map.of("nickName", nick, "level", 0, "sex", 1, "photoUrl", ""));
            hallCommand(hall, 0x116, new BinaryWriter().i32(uid).i32(1).u8(1).string(profile));
            var hello = PacketCodec.readFrame(hall.getInputStream());
            DouniuCheck.check(hello.cmd() == 0x201 && new BinaryReader(hello.body()).i32() == 1, "hall login");
            hallCommand(hall, 0x113, new BinaryWriter().u16(302).i32(0).i32(0).i32(tid).i32(activity)
                    .i32(1).u8(mode).i32(0).string("0.00").string("0.00"));
            PacketCodec.Frame frame;
            do {
                frame = PacketCodec.readFrame(hall.getInputStream());
                if (frame.cmd() == 0x212) throw new AssertionError("hall refused seat");
            } while (frame.cmd() != 0x210);
            var route = new BinaryReader(frame.body());
            DouniuCheck.check(route.i32() == tid && route.u16() == tid >>> 16, "allocated table");
            String host = route.string();
            int port = route.i32();
            route.i32();
            DouniuCheck.check(route.u16() == 302 && route.u8() > 1 && route.i32() == activity, "allocated activity");
            DouniuCheck.check(!host.isBlank() && port == 13600, "room endpoint");
            return tryRoom(hall, tid, activity);
        }

        PacketCodec.Frame tryRoom(HallSocket hall, int tid, int activity) throws Exception {
            PacketCodec.Frame frame;
            var loginBody = new BinaryWriter().i32(tid).i32(uid).i32(-1).u8(1).string(nick).string("")
                    .string("0.00").string("0.00").string(Json.write(Map.of("roomKey", roomKey))).i32(activity).u8(1);
            hallCommand(hall, 0x1001, loginBody);
            do {
                frame = PacketCodec.readFrame(hall.getInputStream());
            } while (frame.cmd() != 0x1007 && frame.cmd() != 0x1005);
            if (frame.cmd() == 0x1007) hall.tid = tid;
            return frame;
        }

        Map<String,Object> enter(HallSocket hall, int tid, int activity, int mode) throws Exception {
            var frame = roomLogin(hall, tid, activity, mode);
            DouniuCheck.check(frame.cmd() == 0x1007, "room login rejected: " + DouniuCheck.decode(frame));
            var roomView = DouniuCheck.decode(frame);
            DouniuCheck.check(((Number)roomView.get("activityId")).intValue() == activity, "Java room joined via hall");
            DouniuCheck.check((int)DouniuCheck.waitFor(hall, 0x5101).get("round_total") == 2, "room length");
            return roomView;
        }
    }

    static Map<String,Object> playRound(Socket a, Socket b, int index) throws Exception {
        for (var s : List.of(a,b)) Client.hallCommand(s, 0x2001, new BinaryWriter().i32(1));
        DouniuCheck.check((int)DouniuCheck.waitFor(a, 0x5101).get("round") == index, "round started");
        DouniuCheck.waitFor(a, 0x6015);
        Client.hallCommand(a, 0x2007, new BinaryWriter().i32(1));
        Client.hallCommand(b, 0x2007, new BinaryWriter().i32(0));
        var betting = DouniuCheck.waitFor(b, 0x7001);
        DouniuCheck.check(!((List<?>)betting.get("selects_base")).isEmpty()
                && ((List<?>)betting.get("can_selects_base")).isEmpty(), "zero-chip account has no manual bet");
        // 新账号等待房间倒计时按默认一倍推进，保留零余额。

        for (var s : List.of(a,b)) {
            DouniuCheck.waitFor(s, 0x6004);
            Client.hallCommand(s, 0x2003, new BinaryWriter().bytes(new byte[]{3,0,0,0}));
        }
        var end = DouniuCheck.waitFor(a, 0x6008);
        DouniuCheck.waitFor(b, 0x6008);
        return end;
    }

    // 只在 smoke.sh 的一次性数据库内预置联盟及成员。账号、开房和观战均走实际业务接口。
    static int clubFixture(Client leader, Client... members) throws Exception {
        var config = new java.util.Properties();
        try (var file = java.nio.file.Files.newInputStream(java.nio.file.Path.of(System.getenv("JOKER_CONFIG")))) { config.load(file); }
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (var db = java.sql.DriverManager.getConnection(config.getProperty("jdbc.url"),
                config.getProperty("jdbc.user"), config.getProperty("jdbc.password"));
             var club = db.prepareStatement("INSERT INTO t_group_player(ower_id,group_name,config) VALUES (?,'test','{}')",
                     java.sql.Statement.RETURN_GENERATED_KEYS);
             var add = db.prepareStatement("INSERT INTO t_player_group(group_id,player_id,up_player_id,player_type,is_robot) VALUES (?,?,?,?,0)")) {
            club.setInt(1, leader.uid());
            club.executeUpdate();
            try (var keys = club.getGeneratedKeys()) {
                if (!keys.next()) throw new AssertionError("missing club");
                int id = keys.getInt(1);
                for (var member : members) {
                    add.setInt(1, id);
                    add.setInt(2, member.uid());
                    add.setInt(3, leader.uid());
                    add.setInt(4, member.equals(leader) ? 0 : 3);
                    add.executeUpdate();
                }
                return id;
            }
        }
    }

    static void watchClubRoom(Client owner, Client guest) throws Exception {
        var leader = Client.register();
        var newcomer = Client.register();
        int club = clubFixture(leader, leader, owner, guest, newcomer);
        var rules = new LinkedHashMap<String,Object>(Map.of("level", 302, "gameId", 302, "round", 2,
                "baseChip", 1, "maxSeatCount", 2, "cardCount", 0, "showCardNums", 3, "subGameType", 1,
                "grabDealerChips", 2, "grabTimes", 3));
        rules.put("gaoji", "5");
        var room = (Map<?,?>)owner.request("/freeGame/createFreeGameByOthers", Map.of("gameId", 302, "name", "观战回归",
                "level", 302, "round", 2, "others", 1, "baseChip", 1, "groupId", club, "json", Json.write(rules)));
        int tid = Integer.parseInt(room.get("tableId").toString());
        int activity = Integer.parseInt(room.get("gameActivityId").toString());
        var invite = Map.of("type", "P", "invitationCode", room.get("inviteCode"), "activityId", activity, "level", 302, "isWatch", 0);
        try {
            guest.request("/joinFreeGame", invite);
            throw new AssertionError("ordinary member received a spectator grant");
        } catch (AssertionError denied) {
            if (!denied.getMessage().contains("只有本联盟的盟主可以观战")) throw denied;
        }
        leader.request("/joinFreeGame", invite);
        var play = new LinkedHashMap<String,Object>(invite);
        play.put("isWatch", 1);
        guest.request("/joinFreeGame", play);
        try (var a = new HallSocket(); var b = new HallSocket(); var w = new HallSocket()) {
            owner.enter(a, tid, activity);
            guest.enter(b, tid, activity);
            if (Boolean.parseBoolean(System.getenv("JOKER_PURE_JAVA"))) {
                Client.hallCommand(a, 0x172, new BinaryWriter().i32(club).i32(3).i32(0).i32(20)
                        .i32(-1).i32(-1).string("").string(""));
                var listing = new BinaryReader(DouniuCheck.waitFrame(a, 0x175).body());
                DouniuCheck.check(listing.i32() == club && listing.i32() >= 0 && listing.i32() == tid,
                        "club member sees the live table");
                DouniuCheck.waitFrame(a, 0x174);
            }
            for (var s : List.of(a,b)) Client.hallCommand(s, 0x2001, new BinaryWriter().i32(1));
            var grab = DouniuCheck.waitFor(a, 0x6015);
            DouniuCheck.check(((List<?>)grab.get("grab_times")).size() == 3, "numeric grab options");
            for (var entry : (List<?>)grab.get("ids")) {
                DouniuCheck.check(((Number)((Map<?,?>)entry).get("canGrabDealer")).intValue() == 0, "low-chip grab disabled");
            }
            Client.hallCommand(a, 0x2007, new BinaryWriter().i32(1));
            DouniuCheck.check((int)DouniuCheck.waitFor(a, 0x5001).get("errorCode") == 105, "not enough chips to grab");
            var view = leader.enter(w, tid, activity, 0);
            var seats = (List<?>)view.get("users_infos");
            DouniuCheck.check((int)view.get("isWatch") == 0 && (int)view.get("seat_id") < 0 && seats.size() == 2
                    && ((List<?>)view.get("cards")).isEmpty(), "watching a full table without a hand or seat");
            for (var seat : seats) {
                DouniuCheck.check(((List<?>)((Map<?,?>)seat).get("user_base_out_cards")).isEmpty(), "private cards hidden");
            }
            for (int cmd : new int[]{0x1031,0x2001,0x2007,0x2008,0x808}) {
                Client.hallCommand(w, cmd, new BinaryWriter().i32(1));
                DouniuCheck.check((int)DouniuCheck.waitFor(w, 0x5001).get("errorCode") == 17, "watcher cannot take part");
            }
            var revealed = DouniuCheck.waitFor(w, 0x6005);
            DouniuCheck.check(((List<?>)revealed.get("cards")).size() == 5, "public reveal delivered");
            var end = DouniuCheck.waitFor(w, 0x6008);
            DouniuCheck.check(((List<?>)end.get("userinfo")).size() == 1, "only two players settled");
            w.leave();
            b.leave();

            newcomer.request("/joinFreeGame", play);
            try (var extra = new HallSocket()) {
                var refused = newcomer.roomLogin(extra, tid, activity, 1);
                DouniuCheck.check(refused.cmd() == 0x1005 && (int)DouniuCheck.decode(refused).get("errorCode") == 18,
                        "new player cannot take the free seat after round one");
            }
            try (var back = new HallSocket()) {
                guest.enter(back, tid, activity);
                leader.request("/transferClubOwner", Map.of("groupId", club, "assignor", newcomer.uid()));
                try (var stale = new HallSocket()) {
                    var refused = leader.roomLogin(stale, tid, activity, 0);
                    DouniuCheck.check(refused.cmd() == 0x1005, "former owner cannot reuse the spectator grant");
                }
                newcomer.request("/joinFreeGame", invite);
                try (var next = new HallSocket()) {
                    DouniuCheck.check((int)newcomer.enter(next, tid, activity, 0).get("isWatch") == 0,
                            "new owner can watch");
                }
            }
        }
        System.out.println("Verified club owner transfer, spectator isolation, grab threshold, locked seats and returning players.");
    }

    private static void passwordRoom(Client owner, Client guest) throws Exception {
        String catalog = (String)owner.request("/gold/getGameConfigByLevelAndGold", Map.of("level", 302));
        var options = (List<?>)Json.parseObject(catalog).get("gameConfig");
        DouniuCheck.check(options.stream().anyMatch(row -> ((List<?>)((Map<?,?>)row).get("configGroup")).stream()
                .anyMatch(group -> "special".equals(((Map<?,?>)group).get("config")))), "password choice in room catalog");
        if ("true".equalsIgnoreCase(System.getenv("JOKER_PURE_JAVA"))) {
            boolean ordinary = false;
            for (var row : options) for (var entry : (List<?>)((Map<?,?>)row).get("configGroup")) {
                var group = (Map<?,?>)entry;
                if (!"hasLeper".equals(group.get("config"))) continue;
                var choices = (List<?>)group.get("configOption");
                ordinary = choices.stream().map(o -> ((Map<?,?>)o).get("optionValue").toString()).toList().containsAll(List.of("0", "1", "2"));
                DouniuCheck.check(ordinary, "only playable wildcard settings offered");
            }
            DouniuCheck.check(ordinary, "ordinary cards in catalog");
        }
        String pin = "047219";
        var rules = Map.of("level", 302, "subGameType", 1, "maxSeatCount", 2, "round", 2);
        var create = Map.of("gameId", 302, "name", "密码房", "level", 302, "round", 2,
                "others", 1, "baseChip", 1, "json", Json.write(rules), "password", pin);
        for (int i = 0; i < 2; i++) {
            var room = (Map<?,?>)owner.request("/freeGame/createFreeGameByOthers", create);
            int tid = Integer.parseInt(room.get("tableId").toString());
            int activity = Integer.parseInt(room.get("gameActivityId").toString());
            var invitation = guest.request("/joinFreeGame", Map.of("type", "P", "invitationCode", room.get("inviteCode"),
                    "activityId", activity, "level", 302, "isWatch", 1));
            DouniuCheck.check(!Json.write(invitation).contains(pin), "invitation hides room PIN");
            try (var a = new HallSocket(); var b = new HallSocket()) {
                var view = owner.enter(a, tid, activity, 1);
                DouniuCheck.check(!view.get("gameConfig").toString().contains(pin), "room config hides PIN");
                checkLocked(guest.roomLogin(b, tid, activity, 1));
                try {
                    guest.request("/freeGame/unlockDouniuRoom", Map.of("activityId", activity, "password", "000000"));
                    throw new AssertionError("wrong PIN accepted");
                } catch (AssertionError denied) {
                    if (!denied.getMessage().contains("房间密码错误")) throw denied;
                }
                checkLocked(guest.tryRoom(b, tid, activity));
                guest.request("/freeGame/unlockDouniuRoom", Map.of("activityId", activity, "password", pin));
                DouniuCheck.check(guest.tryRoom(b, tid, activity).cmd() == 0x1007, "correct PIN unlocks current hall connection");
                b.leave();
                try (var again = new HallSocket()) {
                    guest.enter(again, tid, activity);
                    again.leave();
                }
                a.leave();
            }
        }
        System.out.println("Verified password entry, private PIN, retry, reconnect and separate grants for two rooms.");
    }

    private static void checkLocked(PacketCodec.Frame reply) {
        DouniuCheck.check(reply.cmd() == 0x1005 && (int)DouniuCheck.decode(reply).get("errorCode") == 16,
                "room requires password before taking a seat");
    }

    public static void main(String[] args) throws Exception {
        var owner = Client.register();
        var guest = Client.register();
        if (args.length == 1 && args[0].equals("--password")) {
            passwordRoom(owner, guest);
            return;
        }
        if (args.length == 1 && args[0].equals("--club")) {
            watchClubRoom(owner, guest);
            return;
        }
        var rules = Map.of("level", 302, "gameId", 302, "subGameType", 1, "maxSeatCount", 6, "round", 2,
                "showCardNums", 3, "cardCount", 4, "baseChip", 1);
        var room = (Map<?,?>)owner.request("/freeGame/createFreeGameByOthers", Map.of("gameId", 302, "name", "回归房",
                "level", 302, "round", 2, "others", 1, "baseChip", 1, "json", Json.write(rules)));
        int tid = Integer.parseInt(room.get("tableId").toString());
        int activity = Integer.parseInt(room.get("gameActivityId").toString());
        var join = (Map<?,?>)guest.request("/joinFreeGame", Map.of("type", "P", "invitationCode", room.get("inviteCode"),
                "activityId", activity, "level", 302, "isWatch", 1));
        DouniuCheck.check(Integer.parseInt(join.get("tableId").toString()) == tid, "guest invitation");
        try (var a = new HallSocket(); var b = new HallSocket()) {
            owner.enter(a, tid, activity);
            guest.enter(b, tid, activity);
            var message = Json.write(Map.of("uid", owner.uid, "msgType", "text", "textMessage", "同桌你好"));
            Client.hallCommand(a, 0x801, new BinaryWriter().u16(302).string(message));
            var chat = Json.parseObject((String)DouniuCheck.waitFor(b, 0x801).get("msg"));
            DouniuCheck.check("同桌你好".equals(chat.get("textMessage")), "chat through hall");
            if (Boolean.parseBoolean(System.getenv("JOKER_PURE_JAVA"))) {
                for (boolean expression : List.of(true,false)) {
                    String target = expression ? "uid_to" : "to_uid";
                    String effect = expression ? "expressionType" : "type";
                    var body = Json.write(Map.of("msgType", expression ? "expression" : "EmojiArmatureView",
                            "uid", guest.uid, "uid_from", guest.uid, target, guest.uid, effect, 2));
                    Client.hallCommand(a,0x801,new BinaryWriter().u16(302).string(body));
                    var received = Json.parseObject((String)DouniuCheck.waitFor(b,0x801).get("msg"));
                    DouniuCheck.check(((Number)received.get("uid")).intValue()==owner.uid &&
                            ((Number)received.get(target)).intValue()==guest.uid, "interactive effect from a seated player");
                    if (expression) DouniuCheck.check(((Number)received.get("uid_from")).intValue()==owner.uid, "effect sender");
                }
            }
            Client.hallCommand(a, 0x2001, new BinaryWriter().i32(1));
            DouniuCheck.waitFor(b, 0x6001);
            Client.hallCommand(a, 0x2001, new BinaryWriter().i32(0));
            DouniuCheck.check(((Number)DouniuCheck.waitFor(b, 0x6001).get("readyState")).intValue() == 0, "hall cancel ready");
            var end = playRound(a, b, 1);
            for (Client c : List.of(owner, guest)) {
                var rounds = (List<?>)c.request("/freeGame/querRoundsByActivityId", Map.of("activityId", activity));
                var record = Json.parseObject((String)((Map<?,?>)rounds.getFirst()).get("content"));
                var banker = (Map<?,?>)((List<?>)record.get("userinfos")).getFirst();
                DouniuCheck.check(banker.get("cards").toString().equals(end.get("handCards").toString()), "HTTP round cards");
            }
            b.leave();
            var newcomer = Client.register();
            newcomer.request("/joinFreeGame", Map.of("type", "P", "invitationCode", room.get("inviteCode"),
                    "activityId", activity, "level", 302, "isWatch", 1));
            try (var c = new HallSocket()) {
                newcomer.enter(c, tid, activity);
                playRound(a, c, 2);
                var board = DouniuCheck.waitFor(a, 0x5100);
                var users = (List<?>)board.get("playerlist");
                var ids = users.stream().map(u -> ((Map<?,?>)u).get("uid")).collect(Collectors.toSet());
                DouniuCheck.check((int)board.get("game_amount") == 2
                        && ids.equals(java.util.Set.of(owner.uid, guest.uid, newcomer.uid)), "board includes former seat");
            }
        }
        System.out.println("Verified three new accounts, invitation and hall routing, two Java rounds, HTTP history and final scores including a departed player.");
    }
}
