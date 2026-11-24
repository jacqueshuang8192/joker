package com.j.joker.game.niuniu.application;

import com.j.joker.game.niuniu.util.Json;
import com.j.joker.game.niuniu.application.history.RoundRecord;
import com.j.joker.game.niuniu.domain.card.Card;
import com.j.joker.game.niuniu.domain.rules.GameConfig;
import com.j.joker.game.niuniu.domain.table.GameState;
import com.j.joker.game.niuniu.domain.table.NiuNiuTable;
import com.j.joker.game.niuniu.domain.table.Player;
import com.j.joker.game.niuniu.domain.table.Settlement;
import com.j.joker.game.niuniu.proto.Cmd;
import com.j.joker.game.rooms.application.RoomAllocation;
import com.j.joker.game.rooms.domain.RoomDefinition;
import com.j.joker.game.rooms.domain.RoomRoute;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

/**
 * douniu 角色：把客户端命令映射到 {@link NiuNiuTable}。
 *
 * <p>替代原生 {@code DouNiuServerGroup}，端口默认 13600，与 gateway 的 {@code /ws/douniu} 路由对接。
 * 每个 tid 一张桌；同一 tid 的连接共享一张 {@link NiuNiuTable}。
 */
public final class DouniuService implements AutoCloseable, RoomAllocation.Rooms, com.j.joker.game.rooms.application.Lobby.Tables {

    /** 连接抽象，由 Netty handler 实现，便于测试替换。 */
    public interface Session {
        long uid();

        void uid(long value);

        int tableId();

        void tableId(int value);

        int seat();

        void seat(int value);

        void send(int cmd, Map<String, Object> values);

        void close();
    }

    public record Access(int activity, int watchingClub, boolean unlocked) {}

    @FunctionalInterface
    public interface Admission {
        Access access(int uid, int tid, String key, boolean watchRequested);
        default boolean allowedAtClubTable(int club, long uid, List<Long> seated) { return true; }
    }

    private static final org.slf4j.Logger LOG = org.slf4j.LoggerFactory.getLogger(DouniuService.class);
    private final Admission admission;
    private final Map<Long, Room> memberships = new ConcurrentHashMap<>();
    private final GameConfig cfg;
    private final RoundAccounts data;
    private final Random random = new java.security.SecureRandom();
    private final Map<Integer, Room> rooms = new ConcurrentHashMap<>();

    private final RoomRepository journal;
    private final ScheduledExecutorService votes = Executors.newSingleThreadScheduledExecutor(
            Thread.ofPlatform().daemon().name("niuniu-dissolve").factory());

    public DouniuService(GameConfig cfg, RoundAccounts data, Admission admission, RoomRepository journal) {
        this.journal = journal;
        this.admission = admission;
        this.cfg = cfg;
        this.data = data;
        if (journal != null) {
            for (var saved : journal.rooms()) {
                if (saved.version() != 1 || (saved.tid() >>> 16) != journal.serverId() || saved.activity() <= 0) {
                    throw new IllegalStateException("牛牛快照版本或桌号不匹配");
                }
                var table = new NiuNiuTable(saved.tid(), GameConfig.fromJson(saved.rules()), random);
                table.restore(saved.table());
                var room = new Room(saved.tid(), saved.activity(), table, saved.owner(), saved.invite(), saved.club(), saved.rules());
                room.restoring = true;
                room.closing = saved.closing();
                room.vote = saved.vote();
                room.playerClosed = saved.playerClosed();
                room.admitted.addAll(saved.admitted());
                if (rooms.putIfAbsent(room.tid, room) != null) throw new IllegalStateException("重复桌号");
                for (Player player : table.players()) {
                    if (memberships.putIfAbsent(player.uid(), room) != null) throw new IllegalStateException("重复在桌玩家");
                }
            }
        }
    }

    public record Vote(long applicant, Set<Long> voters, Set<Long> agreed, long expiresAt) {
        Map<String, Object> status() {
            var list = agreed.stream().sorted().map(uid -> Map.of("uid", uid)).toList();
            return Map.of("applyId", applicant, "agreeNum", list.size(), "agreeMember_arr", list);
        }
    }

    public record End(int tid, int activity, int rounds, boolean requested) {}
    public interface AllocEvents {
        void seatsChanged(int tid, int seats);
        void closed(End end);
    }

    private AllocEvents allocator;

    public void setAllocator(AllocEvents allocator) {
        this.allocator = allocator;
    }

    public List<End> pendingEnds() { return journal.pendingEnds(); }

    public void endSent(End end) { journal.endSent(end); }

    public void registered() {
        for (Room room : rooms.values()) {
            synchronized (room.table) {
                if (!room.restoring) continue;
                room.restoring = false;
                if (room.vote != null && room.vote.expiresAt() <= System.currentTimeMillis()) {
                    room.approveClose();
                    if (rooms.get(room.tid) != room) continue;
                } else if (room.vote != null) room.scheduleVote();
                if (room.ending() && !room.table.inRound()) finishRoom(room);
                else room.table.resume();
            }
        }
    }

    public void allocate(int tid, int activity, int owner, String invite, int club, GameConfig rules, String json) {
        Room room = rooms.computeIfAbsent(tid, key -> {
            var created = new Room(tid, activity, new NiuNiuTable(tid, rules, random), owner, invite, club, json);
            created.save();
            return created;
        });
        if (room.activity != activity) throw new IllegalStateException("桌号已被其他活动占用");
    }

    @Override public void create(int tid, RoomDefinition request) {
        allocate(tid, request.activity(), request.owner(), request.invite(), request.club(),
                GameConfig.fromJson(request.rules()), request.rules());
    }

    @Override public RoomRoute route(int tid) {
        Room room = rooms.get(tid);
        return room == null ? null : new RoomRoute(tid, room.activity, room.owner, room.invite, room.club, room.table.config().baseChip(),
                room.table.config().maxSeatCount(), room.json);
    }

    @Override public RoomRoute activityRoute(int activity) {
        for (var room : rooms.values()) if (room.activity == activity) return route(room.tid);
        return null;
    }

    @Override public boolean select(int uid, int tid, int activity, boolean invited) {
        Room room = rooms.get(tid);
        if (room == null) return false;
        synchronized (room.table) {
            Room occupied = memberships.get((long) uid);
            if (rooms.get(tid) != room || room.activity != activity || room.failed || room.restoring
                    || (occupied != null && occupied != room)
                    || (room.ending() && occupied != room)
                    || (!invited && uid != room.owner && room.table.byUid(uid) == null)) return false;
            // 先保存需要清理的账号。即使此时重启，也能安全重试分桌或关闭空桌。
            if (room.admitted.add((long) uid)) room.save();
            journal.route(tid, activity, uid);
            return true;
        }
    }

    public record ClubTable(int tid, int configId, int gameType, int round, String name, String invite,
                            List<String> users) {}

    public List<ClubTable> clubTables(int uid, int club, int groupType, int page, int size, int gameType, int configId) {
        if (club <= 0 || page < 0 || size < 1 || size > 100 || !data.isClubMember(club, uid)) return List.of();
        List<ClubTable> visible = new ArrayList<>();
        for (Room room : rooms.values()) {
            if (room.club != club) continue;
            synchronized (room.table) {
                if (rooms.get(room.tid) != room || room.ending()) continue;
                var info = Json.parseObject(room.json);
                int template = num(info.get("clubConfigId"), 0), game = num(info.get("clubGameType"), 0);
                int type = num(info.get("groupType"), 3);
                if (groupType != type || (gameType >= 0 && gameType != game) || (configId >= 0 && configId != template)) continue;
                var users = room.table.players().stream().map(p -> Json.write(
                        Map.of("uid", p.uid(), "seatId", p.seatId(), "nickName", p.nickName(), "portrait", p.portrait()))).toList();
                visible.add(new ClubTable(room.tid, template, game, room.table.roundNo(),
                        info.getOrDefault("clubName", "").toString(), room.invite, users));
            }
        }
        return visible.stream().sorted(java.util.Comparator.comparingInt(ClubTable::tid))
                .skip((long)page * size).limit(size).toList();
    }

    @Override public int release(int uid, int tid) {
        Room room = rooms.get(tid);
        if (room == null) return -1;
        synchronized (room.table) {
            if (rooms.get(tid) != room || room.failed || room.restoring) return -1;
            if (room.table.byUid(uid) != null && (room.table.inRound() || room.vote != null || room.ending())) return -1;
            Session session = room.sessions.get((long)uid);
            if (session != null) quit(session);
            else journal.leave(tid, room.activity, uid);
            return 0;
        }
    }

    public Map<Integer, Integer> occupancy() {
        Map<Integer, Integer> counts = new LinkedHashMap<>();
        rooms.forEach((tid, room) -> {
            synchronized (room.table) {
                if (rooms.get(tid) == room) counts.put(tid, room.table.players().size());
            }
        });
        return counts;
    }

    @Override public void requestRemoval(int tid, int activity) {
        Room room = rooms.get(tid);
        if (room == null || room.activity != activity) return;
        synchronized (room.table) {
            if (rooms.get(tid) != room || room.failed) return;
            room.closing = true;
            room.clearVote();
            if (room.table.inRound()) room.save();
            else finishRoom(room);
        }
    }

    private void finishRoom(Room room) {
        if (rooms.get(room.tid) != room) return;
        var end = new End(room.tid, room.activity, room.table.roundNo(), room.closing);
        try {
            if (journal != null) journal.finish(end, room.admitted);
        } catch (RuntimeException failure) {
            throw room.suspend(failure);
        }
        rooms.remove(room.tid, room);
        room.clearVote();
        if (end.rounds() > 0 && !room.sessions.isEmpty()) {
            Map<String,Object> scores;
            if (data.enabled()) {
                scores = data.billboard(room.activity, journal.level(), end.rounds());
            } else {
                var board = new com.j.joker.game.niuniu.application.history.RoomBillboard();
                room.demoHistory.values().forEach(board::add);
                scores = board.packet(end.rounds());
            }
            if (scores != null) broadcast(room, Cmd.SVR_GROUP_BILLBOARD, scores);
            else {
                LOG.warn("活动 {} 已结算 {} 局，总战绩暂不能通过牌桌显示", room.activity, end.rounds());
                broadcast(room, Cmd.BROADCAST_ERROR_TIPS, Map.of("errorCode", 1));
            }
        }
        if (room.playerClosed) broadcast(room, Cmd.SERVER_BROADCAST_DISSOLVE_GROUP, Map.of());
        room.table.stopTimers();
        room.sessions.forEach((uid, session) -> {
            memberships.remove(uid, room);
            session.send(Cmd.SVR_QUIT_ROOM, Map.of("uid", uid));
            session.close();
        });
        room.table.players().forEach(p -> memberships.remove(p.uid(), room));
        room.spectators.keySet().forEach(uid -> memberships.remove(uid, room));
        if (allocator != null) allocator.closed(end);
    }

    @Override
    public void close() {
        votes.shutdownNow();
        rooms.values().forEach(room -> room.table.stopTimers());
    }

    public void handle(Session session, int cmd, Map<String, Object> values) {
        if (cmd == Cmd.CLI_HEART) {
            session.send(Cmd.SVR_HEART, Map.of());
            return;
        }
        if (cmd == Cmd.CLI_LOGIN_ROOM) {
            login(session, values);
            return;
        }
        Room room = rooms.get(session.tableId());
        if (room == null || room.sessions.get(session.uid()) != session) {
            session.send(Cmd.SVR_LOGIN_ROOM_FAIL, Map.of("errorCode", 3));
            return;
        }
        synchronized (room.table) {
            if (!room.failed && rooms.get(room.tid) == room && room.sessions.get(session.uid()) == session) {
                dispatch(session, cmd, values);
            }
        }
    }

    private void dispatch(Session session, int cmd, Map<String, Object> values) {
        Room room = rooms.get(session.tableId());
        // 观战会话始终没有座位。只有玩家主动站起才会持有可以重新坐下的 -2 座位。
        if (session.seat() == -1) {
            if (cmd == Cmd.CLI_QUIT_ROOM) quit(session);
            else session.send(Cmd.BROADCAST_ERROR_TIPS, Map.of("errorCode", 17));
            return;
        }
        if ((room.vote != null || room.ending()) && (cmd == Cmd.CLI_SIT_DOWN || cmd == Cmd.CLI_STAND_UP
                || cmd == Cmd.CLI_READYNOW_ROOM || cmd == Cmd.CLIENT_COMMAND_START_GAME || cmd == Cmd.CLI_QUIT_ROOM)) {
            session.send(Cmd.BROADCAST_ERROR_TIPS, Map.of("errorCode", 17));
            return;
        }
        // 观战和解散期间的拒绝回复优先于包体校验，旧客户端依赖这条回复结束等待。
        if (values == null) return;
        switch (cmd) {
            case Cmd.C2G_CMD_DISSOLVE_ROOM -> {
                requestVote(session);
            }
            case Cmd.C2G_CMD_REPLY_DISSOLVE_ROOM -> {
                replyVote(session, num(values.get("agree"), -1));
            }
            case Cmd.CLI_COMMAND_GAMERESULT_RECORD -> {
                int index = num(values.get("resultIndex"), 0);
                Map<String,Object> result;
                if (data.enabled()) {
                    var history = data.history(room.activity, journal.level(), index);
                    result = history == null ? null : RoundRecord.reply(history.latest(), history.record());
                } else {
                    int latest = room.demoHistory.size();
                    int wanted = index > 0 && index <= latest ? index : latest;
                    result = RoundRecord.reply(latest, room.demoHistory.get(wanted));
                }
                if (result != null) session.send(Cmd.SERVER_COMMAND_GAMERESULT_RECORD, result);
                else session.send(Cmd.BROADCAST_ERROR_TIPS, Map.of("errorCode", 1));
            }
            case Cmd.CLIENT_CMD_SEND_MSG_TO_SERVER, Cmd.CLIENT_CMD_SEND_MSG_LEGACY, Cmd.CLIENT_CMD_FORWARD_MESSAGE -> {
                Player sender = room.table.byUid(session.uid());
                if (sender == null || !(values.get("msg") instanceof String raw)) return;
                boolean location = cmd == Cmd.CLIENT_CMD_FORWARD_MESSAGE;
                String message = RoomMessages.message(sender, raw, location);
                if (message == null) return;
                if (location) {
                    room.locations.put(sender.uid(), message);
                    broadcast(room, Cmd.SERVER_CMD_FORWARD_MESSAGE, room.locationList());
                } else broadcast(room, Cmd.SERVER_CMD_MESSAGE, Map.of("msg", message));
            }
            case Cmd.CLI_MSG_FACE -> {
                int face = num(values.get("type"), 0);
                if (RoomMessages.knownFace(face) && room.table.byUid(session.uid()) != null) {
                    broadcast(rooms.get(session.tableId()), Cmd.SVR_MSG_FACE, Map.of("uid", session.uid(), "type", face));
                }
            }
            case Cmd.CLI_SIT_DOWN -> sit(session, num(values.get("seat"), -1));
            case Cmd.CLI_STAND_UP -> stand(session);
            case Cmd.CLI_QUIT_ROOM -> quit(session);
            case Cmd.CLI_READYNOW_ROOM -> ready(session, num(values.get("ready"), 1) == 1);
            case Cmd.CLIENT_COMMAND_START_GAME -> start(session);
            case Cmd.CLI_QIANGZHUANG -> grab(session, values);
            case Cmd.CLI_USER_BASES -> bet(session, values);
            case Cmd.CLI_AUTO_PLAY -> auto(session, values);
            case Cmd.CLI_PLAY_CARD -> room.table.reveal(session.uid());
            default -> session.send(Cmd.BROADCAST_ERROR_TIPS, Map.of("errorCode", 1));
        }
    }

    private void requestVote(Session session) {
        Room room = rooms.get(session.tableId());
        if (room.ending() || room.table.byUid(session.uid()) == null || room.table.config().dissolveMode() == 3) {
            session.send(Cmd.G2H_CMD_DISSOLVE_FAILED, Map.of());
            return;
        }
        if (room.vote != null) {
            session.send(Cmd.G2H_CMD_REFRESH_DISSOLVE_LIST, room.vote.status());
            return;
        }
        var voters = new HashSet<Long>();
        room.table.players().forEach(p -> voters.add(p.uid()));
        if (voters.size() == 1 || room.table.roundNo() == 0) {
            room.approveClose();
            return;
        }
        room.vote = new Vote(session.uid(), voters, new HashSet<>(), System.currentTimeMillis() + 300_000L);
        room.save();
        room.scheduleVote();
        broadcast(room, Cmd.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP, Map.of("applyId", session.uid()));
        broadcast(room, Cmd.G2H_CMD_REFRESH_DISSOLVE_LIST, room.vote.status());
    }

    private void replyVote(Session session, int answer) {
        Room room = rooms.get(session.tableId());
        Vote vote = room.vote;
        long uid = session.uid();
        if (vote == null || uid == vote.applicant() || !vote.voters().contains(uid)
                || vote.agreed().contains(uid) || (answer != 0 && answer != 1)) return;
        if (System.currentTimeMillis() >= vote.expiresAt()) {
            room.approveClose();
        } else if (answer == 0) {
            room.clearVote();
            room.save();
            broadcast(room, Cmd.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP, Map.of("rejectId", uid));
        } else {
            vote.agreed().add(uid);
            int requiredReplies = room.table.config().dissolveMode() == 1 ? vote.voters().size() / 2 : vote.voters().size() - 1;
            if (vote.agreed().size() >= requiredReplies) room.approveClose();
            else {
                room.save();
                broadcast(room, Cmd.G2H_CMD_REFRESH_DISSOLVE_LIST, vote.status());
            }
        }
    }

    public void disconnect(Session session) {
        Room room = rooms.get(session.tableId());
        if (room == null) return;
        synchronized (room.table) {
            // 连接关闭回调可能已在退桌前取得旧 Room，并等待结算线程释放桌锁。
            if (rooms.get(room.tid) != room || room.failed || !room.sessions.remove(session.uid(), session)) return;
            Player p = room.table.byUid(session.uid());
            if (p != null) p.setOnline(false);
            room.spectators.remove(session.uid());
            room.locations.remove(session.uid());
            if (p == null || !room.table.inRound()) {
                if (p != null) room.table.leaveDisconnected(p);
                memberships.remove(session.uid(), room);
            }
            removeEmpty(room);
        }
    }

    private void removeEmpty(Room room) {
        if (!data.enabled() && room.sessions.isEmpty() && room.table.players().isEmpty() && rooms.remove(room.tid, room)) {
            room.table.stopTimers();
        }
    }

    private void login(Session session, Map<String, Object> m) {
        int tid = num(m.get("tid"), 0), uid = num(m.get("uid"), 0);
        Access access = tid > 0 && uid > 0
                ? admission.access(uid, tid, (String) m.get("key"), num(m.get("isWatch"), 1) == 0) : null;
        if (session.uid() != 0 || access == null) {
            session.send(Cmd.SVR_LOGIN_ROOM_FAIL, Map.of("errorCode", 3));
            return;
        }
        int activity = access.activity();
        boolean watching = access.watchingClub() > 0;
        Room existing = memberships.get((long) uid);
        if (existing != null && existing.tid != tid) {
            session.send(Cmd.SVR_LOGIN_ROOM_FAIL, Map.of("errorCode", 7));
            return;
        }
        while (true) {
            Room room = data.enabled() ? rooms.get(tid) : rooms.computeIfAbsent(tid, id ->
                    new Room(tid, activity, new NiuNiuTable(id, cfg, random), 0, Integer.toString(tid), 0, demoRules()));
            if (room == null) {
                session.send(Cmd.SVR_LOGIN_ROOM_FAIL, Map.of("errorCode", 3));
                return;
            }
            synchronized (room.table) {
                if (rooms.get(tid) != room) continue;
                if (room.failed || room.restoring || room.activity != activity
                        || (watching && (room.table.byUid(uid) != null || (data.enabled()
                            && (access.watchingClub() != room.club || !data.isClubOwner(room.club, uid)))))
                        || (room.ending() && room.table.byUid(uid) == null)
                        || (room.vote != null && !room.vote.voters().contains((long) uid))) {
                    session.send(Cmd.SVR_LOGIN_ROOM_FAIL, Map.of("errorCode", 3));
                    return;
                }
                if (room.table.config().passwordRequired() && uid != room.owner && !access.unlocked()) {
                    session.send(Cmd.SVR_LOGIN_ROOM_FAIL, Map.of("errorCode", 16));
                    return;
                }
                Room reserved = memberships.putIfAbsent((long) uid, room);
                if (reserved != null && reserved != room) {
                    session.send(Cmd.SVR_LOGIN_ROOM_FAIL, Map.of("errorCode", 7));
                } else {
                    try {
                        join(session, m, room, uid, watching);
                    } finally {
                        if (reserved == null && !room.sessions.containsKey((long) uid) && room.table.byUid(uid) == null)
                            memberships.remove((long) uid, room);
                    }
                }
                removeEmpty(room);
                return;
            }
        }
    }

    private void join(Session session, Map<String, Object> m, Room room, int uid, boolean watching) {
        GameConfig cfg = room.table.config();
        int tid = room.tid;
        Player player = room.table.byUid(uid);
        if (watching) {
            room.spectators.remove((long) uid);
            player = new Player(uid, "", 0, false);
        } else if (player == null) {
            if (!room.allowedSeat(uid)) {
                session.send(Cmd.SVR_LOGIN_ROOM_FAIL, Map.of("errorCode", 7));
                return;
            }
            if (!room.canJoinAfterStart(uid)) {
                session.send(Cmd.SVR_LOGIN_ROOM_FAIL, Map.of("errorCode", 18));
                return;
            }
            int seat = num(m.get("seat_id"), -1);
            if (seat < 0 || seat >= Math.min(cfg.maxSeatCount(), NiuNiuTable.MAX_SEATS) || room.table.bySeat(seat) != null) seat = room.table.autoSeat();
            if (seat < 0 || room.table.inRound()) {
                session.send(Cmd.SVR_LOGIN_ROOM_FAIL, Map.of("errorCode", 7));
                return;
            }
            long chips = data.enabled() ? data.chips(uid) : cfg.joinGamePoint();
            if (chips < 0 || chips < room.minimumChips) {
                session.send(Cmd.SVR_LOGIN_ROOM_FAIL, Map.of("errorCode", 3));
                return;
            }
            player = new Player(uid, (String) m.getOrDefault("nick", "玩家" + uid), chips, false);
            player.setPortrait((String) m.getOrDefault("portrait", ""));
            player.setSex(num(m.get("sex"), 0));
            room.spectators.remove((long) uid);
            room.table.sit(seat, player);
        }
        if (data.enabled()) room.admitted.add((long) uid);
        player.setOnline(true);
        room.save();
        session.uid(uid);
        session.tableId(tid);
        session.seat(player.seatId());
        Session replaced = room.sessions.put((long) uid, session);
        if (replaced != null) replaced.close();

        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("activityId", room.activity);
        resp.put("isWatch", watching ? 0 : 1);
        resp.put("club_id", room.club);
        resp.put("inviteCode", room.invite);
        resp.put("bonusPool", 0);
        resp.put("start_id", room.owner);
        resp.put("gameType", cfg.subGameType().code);
        resp.put("initialChip", cfg.joinGamePoint());
        resp.put("maxPlyaerNum", (byte) cfg.maxSeatCount());
        resp.put("allUsersReadyStatus", 0);
        resp.put("base", cfg.baseChip());
        resp.put("table_kind", (short) 0);
        resp.put("seat_id", player.seatId());
        resp.put("gold", (int) Math.min(Integer.MAX_VALUE, player.chips()));
        resp.put("win", 0);
        resp.put("lost", 0);
        resp.put("table_status", switch (room.table.state()) {
            case WAIT_START, SEND_CARD -> 1;
            case GRAB_DEALER -> 2;
            case CALL_TIMES -> 3;
            case OPEN_CARD, SETTLE -> 4;
            default -> 0;
        });
        resp.put("bank_uid", room.table.banker() == null ? 0 : (int) room.table.banker().uid());
        resp.put("less_time", room.secondsLeft());
        int status = watching ? 0 : room.table.userStatus(player);
        resp.put("user_status", status);
        List<Integer> cards = !watching && room.table.inRound() ? visibleCards(room.table, player) : List.of();
        resp.put("card_mount", cards.size());
        resp.put("cards", cards);
        resp.put("grab_times_mount", cfg.grabOptions().size());
        resp.put("grab_times", cfg.grabOptions());
        boolean canGrab = !watching && room.table.canGrab(player);
        resp.put("can_grab_times_mount", canGrab ? cfg.grabOptions().size() : 0);
        resp.put("can_grab_times", canGrab ? cfg.grabOptions() : List.of());
        resp.put("canGrabDealer", canGrab ? 1 : 0);
        var bets = watching ? List.of() : room.table.betChoices(player);
        var display = room.table.displayedBets(player);
        resp.put("selects_base_mount", display.size());
        resp.put("selects_base", display);
        resp.put("can_selects_base_mount", bets.size());
        resp.put("can_selects_base", bets);
        resp.put("user_base_calltime", player.betTimes());
        List<Integer> waiting = status == 7 ? cards : List.of();
        List<Integer> shown = status == 8 ? cards : List.of();
        resp.put("user_base_waitplay", player.betTimes());
        resp.put("user_base_waitplay_cards_mount", waiting.size());
        resp.put("user_base_waitplay_cards", waiting);
        resp.put("user_base_out", player.betTimes());
        resp.put("user_base_out_card_kind", shown.isEmpty() ? 0 : player.hand().type().id());
        resp.put("user_base_out_cards_mount", shown.size());
        resp.put("user_base_out_cards", shown);
        var others = new ArrayList<Map<String, Object>>();
        for (Player other : room.table.players()) {
            if (other.uid() == uid) continue;
            Map<String,Object> info = new LinkedHashMap<>(Map.of("uid", other.uid(), "seat_id", other.seatId(), "nickName", other.nickName(),
                    "portrait", other.portrait(), "gold", other.chips(), "user_status", room.table.userStatus(other),
                    "user_base_calltime", other.betTimes(), "user_if_outline", other.online() ? 0 : 1,
                    "otherInfo", "{}"));
            if (room.table.userStatus(other) == 8) {
                var openCards = other.cards().stream().map(Card::code).toList();
                info.put("user_base_out", other.betTimes());
                info.put("user_base_out_cards_cardkind", other.hand().type().id());
                info.put("user_base_out_cards_mount", openCards.size());
                info.put("user_base_out_cards", openCards);
            }
            info.put("sex", other.sex());
            info.put("user_base_waitplay", other.betTimes());
            info.put("keTuizhu", room.table.pushBet(other));
            info.put("user_if_auto", other.autoPlay() ? 1 : 0);
            others.add(info);
        }
        resp.put("user_mount", others.size());
        resp.put("users_infos", others);
        resp.put("isGoldGame", (byte) 1);
        resp.put("gameConfig", room.json);
        resp.put("waiweibet_count", (byte) 0);
        resp.put("waiweibet_chips", List.of());
        resp.put("m_guodi", cfg.guodi());
        resp.put("m_curGuoJuSize", 0);
        resp.put("bankerOptState", 0);
        resp.put("m_nGuoCount", 0);
        resp.put("hasLeper", (byte) (cfg.isLeperEnabled() ? 1 : 0));
        resp.put("leperCount", (byte) 0);
        resp.put("lepers", List.of());
        session.send(Cmd.SVR_LOGIN_ROOM, resp);
        session.send(Cmd.SVR_GROUP_TIME, room.roundInfo());
        if (room.vote != null) session.send(Cmd.G2H_CMD_REFRESH_DISSOLVE_LIST, room.vote.status());
        if (!room.locations.isEmpty()) session.send(Cmd.SERVER_CMD_FORWARD_MESSAGE, room.locationList());
        if (watching) return;
        var arrival = Map.<String, Object>of("uid", uid, "seat_id", player.seatId(), "nickName", player.nickName(),
                "portrait", player.portrait(), "sex", player.sex(), "gold", player.chips(), "otherInfo", "{}");
        room.sessions.values().stream().filter(other -> other != session)
                .forEach(other -> other.send(Cmd.SVR_LOGIN_ROOM_BROADCAST, arrival));
    }

    private void sit(Session session, int seat) {
        Room room = rooms.get(session.tableId());
        Player player = room.table.byUid(session.uid());
        if (player == null) player = room.spectators.get(session.uid());
        if (player == null || room.table.inRound()) return;
        if (!room.canJoinAfterStart(session.uid()) || !room.allowedSeat(session.uid())) {
            session.send(Cmd.BROADCAST_ERROR_TIPS, Map.of("errorCode", 18));
            return;
        }
        if (seat < 0) seat = player.seatId() >= 0 ? player.seatId() : room.table.autoSeat();
        if (seat < 0 || seat >= room.table.config().maxSeatCount() || (room.table.bySeat(seat) != null && room.table.bySeat(seat) != player)) {
            session.send(Cmd.BROADCAST_ERROR_TIPS, Map.of("errorCode", 16));
            return;
        }
        try {
            room.table.standUp(session.uid());
            room.table.sit(seat, player);
            room.spectators.remove(session.uid());
            session.seat(seat);
            broadcastSeat(room, player);
        } catch (RuntimeException e) {
            session.send(Cmd.BROADCAST_ERROR_TIPS, Map.of("errorCode", 11));
        }
    }

    private void stand(Session session) {
        Room room = rooms.get(session.tableId());
        Player player = room.table.byUid(session.uid());
        if (player == null || room.table.inRound()) {
            return;
        }
        room.table.standUp(session.uid());
        player.setSeatId(-2);
        room.spectators.put(session.uid(), player);
        room.locations.remove(session.uid());
        session.seat(-2);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("uid", (int) player.uid());
        m.put("seat_id", -2);
        broadcast(room, Cmd.BROADCAST_USER_STAND_UP, m);
    }

    private void quit(Session session) {
        Room room = rooms.get(session.tableId());
        if (room.table.inRound() && room.table.byUid(session.uid()) != null) {
            session.send(Cmd.BROADCAST_ERROR_TIPS, Map.of("errorCode", 17));
            return;
        }
        var departure = Map.<String,Object>of("uid", Math.toIntExact(session.uid()));
        boolean visible = session.seat() != -1;
        if (journal != null) journal.leave(room.tid, room.activity, session.uid());
        disconnect(session);
        if (visible) broadcast(room, Cmd.BROADCAST_USER_QUIT_ROOM, departure);
        // 大厅复用这条 TCP 连接，1033 会驱动 Lua 返回大厅；100E 只表示其他玩家断线。
        session.send(Cmd.BROADCAST_USER_QUIT_ROOM, departure);
        session.uid(0);
        session.tableId(0);
        session.seat(-1);
    }

    private void ready(Session session, boolean requested) {
        Room room = rooms.get(session.tableId());
        try {
            room.table.ready(session.uid(), requested);
            org.slf4j.LoggerFactory.getLogger(DouniuService.class).debug("ready uid={} state={} players={}",
                    session.uid(), room.table.state(), room.table.players());
        } catch (RuntimeException e) {
            org.slf4j.LoggerFactory.getLogger(DouniuService.class).warn("ready failed", e);
            session.send(Cmd.BROADCAST_ERROR_TIPS, Map.of("errorCode", 17));
        }
    }

    private void start(Session session) {
        Room room = rooms.get(session.tableId());
        if (room.owner == 0 ? session.seat() == 0 : session.uid() == room.owner) room.table.startGame(session.uid());
    }

    private void grab(Session session, Map<String, Object> m) {
        Room room = rooms.get(session.tableId());
        try {
            int times = num(m.get("if_qiang"), 0);
            Player player = room.table.byUid(session.uid());
            if (times > 0 && player != null && !room.table.canGrab(player)) {
                session.send(Cmd.BROADCAST_ERROR_TIPS, Map.of("errorCode", 105));
                return;
            }
            room.table.grabBanker(session.uid(), times);
        } catch (RuntimeException e) {
            org.slf4j.LoggerFactory.getLogger(DouniuService.class).debug("grab ignored uid={} state={}", session.uid(), room.table.state());
            session.send(Cmd.BROADCAST_ERROR_TIPS, Map.of("errorCode", 20));
        }
    }

    private void bet(Session session, Map<String, Object> m) {
        Room room = rooms.get(session.tableId());
        try {
            room.table.bet(session.uid(), num(m.get("bases"), 1));
        } catch (RuntimeException e) {
            org.slf4j.LoggerFactory.getLogger(DouniuService.class).debug("bet ignored state={}", room.table.state());
            session.send(Cmd.BROADCAST_ERROR_TIPS, Map.of("errorCode", 20));
        }
    }

    private void auto(Session session, Map<String, Object> m) {
        Room room = rooms.get(session.tableId());
        Player player = room.table.byUid(session.uid());
        if (player == null) {
            return;
        }
        boolean open = num(m.get("isOpenAuto"), 0) != 0;
        player.setAutoPlay(open);
        room.save();
        if (open) {
            switch (room.table.state()) {
                case GRAB_DEALER -> room.table.autoPlayBotsGrab();
                case CALL_TIMES -> room.table.autoPlayBotsBet();
                default -> {
                }
            }
        }
    }

    private void broadcastSeat(Room room, Player player) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("uid", (int) player.uid());
        m.put("seat_id", player.seatId());
        m.put("sex", player.sex());
        m.put("nickName", player.nickName());
        m.put("portrait", player.portrait());
        m.put("gold", (int) Math.min(Integer.MAX_VALUE, player.chips()));
        m.put("ip", "");
        broadcast(room, Cmd.BROADCAST_USER_SIT_DOWN, m);
    }

    private void broadcast(Room room, int cmd, Map<String, Object> values) {
        room.sessions.values().forEach(s -> s.send(cmd, values));
    }

    private String demoRules() {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", cfg.id());
        m.put("name", cfg.name());
        m.put("baseChip", cfg.baseChip());
        m.put("maxSeatCount", cfg.maxSeatCount());
        m.put("readyPoint", cfg.readyPoint());
        m.put("joinGamePoint", cfg.joinGamePoint());
        m.put("round", cfg.round());
        m.put("showCardNums", cfg.showCardNums());
        m.put("grabDealerChips", cfg.grabDealerChips());
        m.put("grabTimes", cfg.grabOptions().stream().map(String::valueOf).collect(java.util.stream.Collectors.joining(",")));
        m.put("subGameType", cfg.subGameType().code);
        m.put("timesRule", cfg.timesRule());
        m.put("speType", join(cfg.speTypes()));
        m.put("gaoji", join(cfg.gaoji()));
        m.put("hasLeper", cfg.isLeperEnabled() ? 1 : 0);
        m.put("tuizhu", cfg.tuizhu());
        m.put("guodi", cfg.guodi());
        return Json.write(m);
    }

    private List<Integer> visibleCards(NiuNiuTable table, Player p) {
        boolean open = table.state() == GameState.OPEN_CARD || table.state() == GameState.SETTLE;
        int count = open ? p.cards().size() : Math.clamp(table.config().showCardNums(), 0, p.cards().size());
        return p.cards().stream().limit(count).map(Card::code).toList();
    }

    private static String join(java.util.Set<Integer> values) {
        StringBuilder sb = new StringBuilder();
        for (int v : values) {
            if (sb.length() > 0) {
                sb.append(',');
            }
            sb.append(v);
        }
        return sb.toString();
    }

    private static List<Integer> ints(int[] values) {
        List<Integer> list = new ArrayList<>(values.length);
        for (int v : values) {
            list.add(v);
        }
        return list;
    }

    private static int num(Object value, int def) {
        if (value instanceof Number n) {
            return n.intValue();
        }
        if (value instanceof String s) {
            try {
                return Integer.parseInt(s.trim());
            } catch (NumberFormatException ignored) {
                return def;
            }
        }
        return def;
    }

    /** 一张桌及其在线连接。 */
    private final class Room {
        java.util.UUID awaitingReceipt;
        long deadlineNanos;

        int secondsLeft() {
            return (int) Math.max(0, Math.ceil((deadlineNanos - System.nanoTime()) / 1_000_000_000.0));
        }

        final int activity;
        final int tid;
        final NiuNiuTable table;
        final Map<Long, Player> spectators = new LinkedHashMap<>();
        final Map<Long, Session> sessions = new ConcurrentHashMap<>();

        final int minimumChips;
        final java.util.Set<Long> admitted = new java.util.HashSet<>();
        final int owner;
        final String invite;
        final int club;
        final String json;
        final Map<Long, String> locations = new LinkedHashMap<>();
        Map<String,Object> locationList() {
            var list = locations.values().stream().map(msg -> Map.of("msg", msg)).toList();
            return Map.of("msgCount", list.size(), "msgList", list);
        }
        Map<String,Object> roundInfo() {
            return Map.of("time", 0, "round", table.roundNo(), "round_total", table.config().round());
        }

        boolean allowedSeat(long uid) {
            return club <= 0 || admission.allowedAtClubTable(club, uid, table.players().stream().map(Player::uid).toList());
        }

        Set<Long> openingPlayers;
        boolean canJoinAfterStart(long uid) {
            if (table.roundNo() == 0 || !table.config().gaoji().contains(5)) return true;
            if (openingPlayers == null) {
                // 旧快照也能恢复。首局进行中直接使用座位，已结算则使用同一活动的首局回执。
                if (table.roundNo() == 1 && table.inRound()) rememberOpeningPlayers();
                else {
                    RoundRecord first = demoHistory.get(1);
                    if (data.enabled()) {
                        var history = data.history(activity, journal.level(), 1);
                        if (history != null) first = history.record();
                    }
                    if (first == null || first.index() != 1) return false;
                    openingPlayers = new HashSet<>();
                    for (var seat : first.userinfos()) openingPlayers.add((long) seat.uid());
                }
            }
            return openingPlayers.contains(uid);
        }

        void rememberOpeningPlayers() {
            openingPlayers = new HashSet<>();
            for (var player : table.players()) openingPlayers.add(player.uid());
        }

        final Map<Integer, RoundRecord> demoHistory = new LinkedHashMap<>();
        Vote vote;
        ScheduledFuture<?> voteTimer;
        boolean playerClosed;
        boolean closing;
        boolean ending() { return playerClosed || closing; }

        void clearVote() {
            vote = null;
            if (voteTimer != null) voteTimer.cancel(false);
            voteTimer = null;
        }

        void scheduleVote() {
            Vote pending = vote;
            voteTimer = votes.schedule(() -> {
                synchronized (table) {
                    if (!failed && rooms.get(tid) == this && vote == pending) approveClose();
                }
            }, Math.max(0, pending.expiresAt() - System.currentTimeMillis()), TimeUnit.MILLISECONDS);
        }

        void approveClose() {
            clearVote();
            playerClosed = true;
            if (table.inRound()) save();
            else finishRoom(this);
        }
        boolean restoring;
        boolean failed;

        void save() {
            if (journal == null) return;
            if (failed) throw new IllegalStateException("该桌已暂停");
            try {
                journal.save(new RoomRepository.RoomState(1, tid, activity, owner, invite, club, json,
                        closing, admitted, table.snapshot(), vote, playerClosed));
            } catch (RuntimeException failure) {
                throw suspend(failure);
            }
        }

        IllegalStateException suspend(RuntimeException failure) {
            failed = true;
            table.stopTimers();
            sessions.values().forEach(Session::close);
            LOG.error("牛牛桌 {} 活动 {} 持久化失败，已暂停，请恢复 Redis 后重启房间进程", tid, activity, failure);
            return new IllegalStateException("牛牛房间状态未确认", failure);
        }

        Room(int tid, int activity, NiuNiuTable table, int owner, String invite, int club, String json) {
            this.minimumChips = num(Json.parseObject(json).get("minimumChips"), 0);
            this.owner = owner;
            this.invite = invite;
            this.club = club;
            this.json = json;
            this.activity = activity;
            this.tid = tid;
            this.table = table;
            table.addListener(new Broadcaster(this));
            table.startTimers();
        }
    }

    /** 桌面事件 → 客户端广播包。 */
    private final class Broadcaster implements NiuNiuTable.TableListener {
        private final Room room;
        private final GameConfig cfg;

        Broadcaster(Room room) {
            this.room = room;
            this.cfg = room.table.config();
        }

        private void send(long uid, int cmd, Map<String, Object> values) {
            Session s = room.sessions.get(uid);
            if (s != null) {
                s.send(cmd, values);
            }
        }

        @Override
        public void onState(NiuNiuTable t, GameState state) {
            if ((data.enabled() && state == GameState.STOP_GAME) || (room.ending() && (state == GameState.WAIT_READY || state == GameState.STOP_GAME))) {
                finishRoom(room);
                return;
            }
            if (state != GameState.GRAB_DEALER && state != GameState.SETTLE) room.save();
            if (state == GameState.WAIT_READY || state == GameState.STOP_GAME) {
                for (Player p : t.players()) {
                    if (!p.online()) {
                        t.leaveDisconnected(p);
                        memberships.remove(p.uid(), room);
                    }
                }
                removeEmpty(room);
            }
            if (state == GameState.SEND_CARD) {
                for (Session session : room.sessions.values()) {
                    if (session.seat() == -1 && !data.isClubOwner(room.club, session.uid())) quit(session);
                }
                if (t.roundNo() == 1 && cfg.gaoji().contains(5)) room.rememberOpeningPlayers();
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("send_card_num", (byte) cfg.showCardNums());
                m.put("playerCount", (byte) 0);
                m.put("user_datas", List.of());
                m.put("hasLeper", (byte) (cfg.isLeperEnabled() ? 1 : 0));
                m.put("leperCount", (byte) 0);
                m.put("lepers", List.of());
                broadcast(room, Cmd.SVR_BROADCAST_GAME_START, m);
                broadcast(room, Cmd.SVR_GROUP_TIME, room.roundInfo());
            }
        }

        @Override
        public void onDeal(NiuNiuTable t, Player player) {
            var cards = visibleCards(t, player);
            send(player.uid(), Cmd.SVR_SEND_USER_CARD, Map.of("mount", cards.size(), "cards", cards,
                    "userMount", 1, "users", List.of(Map.of("seat_id", player.seatId(), "mount", cards.size(), "cards", cards))));
        }

        @Override
        public void onOpenCard(NiuNiuTable t, Player p) {
            onDeal(t, p);
        }

        @Override
        public void onReveal(NiuNiuTable t, Player p) {
            room.save();
            var cards = p.cards().stream().map(Card::code).toList();
            broadcast(room, Cmd.SVR_USER_PLAYED_CARDS_BROADCAST, Map.of("uid", p.uid(), "kind", p.hand().type().id(),
                    "mount", cards.size(), "cards", cards, "times", cfg.cardTypeTimes(p.hand().type())));
        }

        @Override
        public void onSeatChange(NiuNiuTable t, Player player) {
            room.save();
            if (allocator != null) allocator.seatsChanged(room.tid, t.players().size());
        }

        @Override
        public void onReady(NiuNiuTable t, Player player) {
            room.save();
            broadcast(room, Cmd.SVR_READY_BROADCAST, Map.of("uid", (int) player.uid(), "readyState", player.ready() ? 1 : 0));
        }

        @Override
        public void onPhaseDeadline(NiuNiuTable t, GameState state, long millis) {
            room.deadlineNanos = System.nanoTime() + millis * 1_000_000;
            int seconds = room.secondsLeft();
            if (state == GameState.GRAB_DEALER) {
                var choices = cfg.grabOptions();
                var options = choices.stream().map(n -> Map.of("times", n)).toList();
                var ids = t.players().stream().map(p -> {
                    boolean eligible = t.canGrab(p);
                    return Map.of("uid", p.uid(), "canGrabDealer", eligible ? 1 : 0,
                            "can_grab_times_mount", eligible ? options.size() : 0,
                            "can_grab_times", eligible ? options : List.of());
                }).toList();
                broadcast(room, Cmd.SVR_BEGIN_QIANFGZHUANG_BROADCAST, Map.of("time", seconds, "isShowHandleView", 1,
                        "grab_times_mount", choices.size(), "grab_times", choices, "mount", ids.size(), "ids", ids));
            } else if (state == GameState.OPEN_CARD) {
                broadcast(room, Cmd.SVR_PLAY_CARD_BROADCAST, Map.of("time", seconds, "isShowHandleView", 1));
            } else if (state == GameState.CALL_TIMES) {
                var pushes = t.players().stream().filter(p -> t.pushBet(p) > 0)
                        .map(p -> Map.of("uid", p.uid(), "max_tuizhu", t.pushBet(p))).toList();
                for (Player p : t.players()) {
                    var display = t.displayedBets(p);
                    var bets = t.betChoices(p);
                    send(p.uid(), Cmd.SVR_SEND_BASES_TO_USER_BROADCAST, Map.of("time", seconds, "isShowHandleView", 1,
                            "selects_base_mount", display.size(), "selects_base", display, "can_selects_base_mount", bets.size(),
                            "can_selects_base", bets.stream().map(n -> Map.of("times", n)).toList(),
                            "tuiZhuBase", t.pushBet(p), "canTuizhuCount", pushes.size(), "canTuizhu", pushes));
                }
            }
        }

        @Override
        public void onGrab(NiuNiuTable t, Player player, int times) {
            room.save();
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("uid", (int) player.uid());
            m.put("if_qiang", times);
            m.put("isShowHandleView", (byte) 1);
            broadcast(room, Cmd.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST, m);
        }

        @Override
        public void onBankerDecided(NiuNiuTable t, Player player) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("uid", (int) player.uid());
            m.put("guodi", cfg.guodi());
            m.put("isShowHandleView", (byte) 1);
            broadcast(room, Cmd.SVR_BRANK_BROADCAST, m);
        }

        @Override
        public void onBet(NiuNiuTable t, Player player, int times) {
            room.save();
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("uid", (int) player.uid());
            m.put("base", times);
            m.put("isShowHandleView", (byte) 1);
            m.put("tuizhu", times == t.pushBet(player) ? 1 : 0);
            m.put("isSheMen", (byte) 0);
            broadcast(room, Cmd.SVR_USER_BASES_RESULT_BROADCAST, m);
        }

        @Override
        public boolean commitRound(java.util.UUID id, Settlement.Result result) {
            room.save(); // 发送入账和每次重试前，确认当前进程仍持有这张桌。
            var record = RoundRecord.capture(room.activity, journal == null ? 0 : journal.level(), room.club, room.table, result);
            if (data.settle(id, result, record)) {
                if (!data.enabled()) room.demoHistory.put(record.index(), record);
                room.awaitingReceipt = null;
                return true;
            }
            if (!id.equals(room.awaitingReceipt)) {
                LOG.warn("牛牛桌 {} 第 {} 局等待数据服务确认，核账局号 {}", room.tid, result.roundNo(), id);
                room.awaitingReceipt = id;
            }
            return false;
        }

        @Override
        public void onSettled(NiuNiuTable t, Settlement.Result result) {
            List<Map<String, Object>> users = new ArrayList<>();
            for (Settlement.Entry e : result.entries()) {
                Player p = t.byUid(e.uid());
                if (p != null && p.banker()) {
                    continue;
                }
                Map<String, Object> u = new LinkedHashMap<>();
                u.put("uid", (int) e.uid());
                u.put("win_times", e.winTimes());
                u.put("win_chip", (int) Math.max(Integer.MIN_VALUE, Math.min(Integer.MAX_VALUE, e.delta())));
                u.put("chips", p == null ? 0 : (int) Math.min(Integer.MAX_VALUE, p.chips()));
                u.put("handCardCount", (byte) (p == null ? 0 : p.cards().size()));
                u.put("handCards", p == null ? List.of() : p.cards().stream().map(Card::code).toList());
                users.add(u);
            }
            Player banker = t.banker();
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("bonusPool", 0);
            m.put("user_mount", users.size());
            m.put("userinfo", users);
            m.put("banker_uid", (int) result.bankerUid());
            m.put("banker_win_times", result.entries().stream().filter(Settlement.Entry::banker)
                    .findFirst().orElseThrow().winTimes());
            m.put("banker_win_chip", (int) Math.max(Integer.MIN_VALUE, Math.min(Integer.MAX_VALUE, result.bankerDelta())));
            m.put("banker_chips", banker == null ? 0 : (int) Math.min(Integer.MAX_VALUE, banker.chips()));
            m.put("time", (int) (System.currentTimeMillis() / 1000));
            m.put("round", result.roundNo());
            m.put("guodi", cfg.guodi());
            m.put("handCardCount", (byte) (banker == null ? 0 : banker.cards().size()));
            m.put("handCards", banker == null ? List.of() : banker.cards().stream().map(Card::code).toList());
            broadcast(room, Cmd.SVR_SETTLEMENT_BROADCAST, m);
        }
    }
}
