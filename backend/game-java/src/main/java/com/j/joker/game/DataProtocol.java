package com.j.joker.game;

import lombok.RequiredArgsConstructor;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import org.springframework.core.env.Environment;
import org.w3c.dom.Element;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import java.sql.SQLException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import static com.j.joker.game.DataPacket.string;

@RequiredArgsConstructor
final class DataProtocol extends SimpleChannelInboundHandler<ByteBuf> {
    static final class Store implements AutoCloseable {
        final Map<Short, DataGame> games = new HashMap<>();
        final JedisPool redis;
        Store(Environment env) throws Exception {
            var sections = GameSettings.games(env, "data");
            redis = GameSettings.redis(env);
            try {
                for (int i = 0; i < sections.getLength(); i++) {
                    var section = (Element) sections.item(i);
                    short game = Short.parseShort(section.getAttribute("GameID"));
                    if (games.containsKey(game)) throw new IllegalArgumentException("Duplicate GameID " + game);
                    games.put(game, new DataGame(section, env.getProperty("JOKER_PURE_JAVA", Boolean.class, false)));
                }
            } catch (Exception failure) { close(); throw failure; }
        }
        public void close() { games.values().forEach(DataGame::close); redis.close(); }
    }
    private final Store store;
    private DataGame game;

    @Override protected void channelRead0(ChannelHandlerContext ctx, ByteBuf input) throws Exception {
        if (input.readableBytes() < 18 || input.getShort(4) != 0x4259) { ctx.close(); return; }
        DataGame selected = store.games.get(input.getShort(12));
        if (selected == null || (game != null && selected != game)) return;
        game = selected;
        int command = input.getInt(8);
        input.skipBytes(18);
        try (var redis = store.redis.getResource()) {
            game.rounds.recover(game, redis);
            if (game.balances != null) game.balances.recover(game, redis);
            DataPacket response = switch (command) {
                case 0x101d -> {
                    if (game.hundred == null) yield null;
                    var result = game.hundred.handle(redis, input);
                    game.balances.recover(game, redis);
                    yield new DataPacket(0x201d).utf8Text(com.j.joker.game.niuniu.util.Json.write(result));
                }
                case 0x101a -> new DataPacket(0x201a).ints(game.rounds.gift(game,redis,input));
                case 0x1019 -> new DataPacket(0x2019).ints(game.rounds.tableCharge(game,redis,input));
                case 0x1018 -> new DataPacket(0x2018).ints(game.rounds.reserve(game, redis, input));
                case 0x1017 -> new DataPacket(0x2017).ints(game.rounds.closeClub(game,redis,input));
                case 0x101b, 0x101c -> {
                    if (input.readableBytes()!=12) throw new IllegalArgumentException("成员查询格式错误");
                    int club = input.readInt(), second = input.readInt(), third = input.readInt();
                    var members = command == 0x101b ? game.robotsAfter(redis,club,second,third)
                            : game.membersAfter(club,second,third);
                    var packet = new DataPacket(command+0x1000).ints(members.size());
                    for (var member : members) {
                        packet.ints(member.uid(),member.sex()).utf8Text(member.name()).utf8Text(member.portrait());
                    }
                    yield packet;
                }
                case 0x1016 -> {
                    if (input.readableBytes() != 8) throw new IllegalArgumentException("联盟成员分页长度无效");
                    var members = game.clubMembersAfter(input.readInt(), input.readInt());
                    var packet = new DataPacket(0x2016).ints(members.size());
                    for (int uid : members) packet.ints(uid);
                    yield packet;
                }
                case 0x1015 -> {
                    if (input.readableBytes() != 8) throw new IllegalArgumentException("联盟成员请求长度无效");
                    yield new DataPacket(0x2015).ints(game.isClubMember(input.readInt(), input.readInt()) ? 1 : 0);
                }
                case 0x1014 -> {
                    if (input.readableBytes() != 8) throw new IllegalArgumentException("观战身份请求长度无效");
                    yield new DataPacket(0x2014).ints(game.isClubOwner(input.readInt(), input.readInt()) ? 1 : 0);
                }
                case 0x1013 -> game.rounds.billboard(input);
                case 0x1012 -> game.rounds.history(input);
                case 0x1010 -> new DataPacket(0x2010).ints(game.rounds.settle(game, redis, input));
                case 0x1001 -> create(redis, input);
                case 0x1002, 0x1005 -> change(redis, input, command == 0x1005);
                case 0x1003 -> {
                    input.readInt();
                    string(input);
                    int uid = input.readInt();
                    yield new DataPacket(0x2003).ints(uid, !game.rounds.held(uid) && game.delete(redis, uid) ? 0 : 1);
                }
                case 0x1004 -> get(redis, input, 0x2004);
                case 0x1011 -> get(redis, input, 0x2011); // 宣告支持整局结算的筹码查询
                case 0x1006 -> {
                    int uid = input.readInt(), chips = input.readInt(), bring = input.readInt(), activity = input.readInt();
                    if (game.find(redis, uid) != null) game.activity(uid, activity, chips, bring);
                    yield null;
                }
                case 0x301a -> buyChips(redis, input);
                case 0x301c -> null; // DGetChipProcess has no side effect or reply.
                case 0x301d -> redeemChips(redis, input);
                case 0x302d -> {
                    int creator = input.readInt(), state = input.readInt(), activity = input.readInt();
                    redis.hset("GROUP_USER_TABLE_STATE_" + creator, Integer.toString(activity), Integer.toString(state));
                    yield null;
                }
                case 0x3200 -> tables(redis, input);
                default -> null;
            };
            if (response != null) ctx.writeAndFlush(Unpooled.wrappedBuffer(response.bytes()));
        }
    }

    private DataPacket create(Jedis redis, ByteBuf in) throws SQLException {
        int source = in.readInt();
        String reason = string(in);
        int uid = in.readInt();
        long money = Long.parseLong(string(in));
        int exp = in.readInt(), score = in.readInt(), wins = in.readInt(), losses = in.readInt();
        String client = string(in);
        int chips = in.readInt();
        boolean duplicate = game.players.containsKey(uid) || game.rounds.held(uid);
        if (!duplicate) duplicate = !game.save(redis, uid, new DataGame.Player(money, exp, score, wins, losses, chips),
                null, false, source, reason, client, null, false);
        return new DataPacket(0x2001).ints(uid, duplicate ? 1 : 0);
    }

    private DataPacket get(Jedis redis, ByteBuf in, int responseCommand) throws SQLException {
        in.readInt(); // Caller source
        int uid = in.readInt();
        if (responseCommand == 0x2011 && game.hundred != null && game.hundred.holds(uid))
            return new DataPacket(responseCommand).ints(uid, 1);
        var player = game.find(redis, uid);
        if (player == null) return null;
        return new DataPacket(responseCommand).ints(uid, 0).text(Long.toString(player.money()))
                .ints(player.exp(), player.score(), player.wins(), player.losses(), player.chips());
    }

    private DataPacket change(Jedis redis, ByteBuf in, boolean moneyOnly) throws SQLException {
        int source = in.readInt();
        String reason = string(in);
        int uid = in.readInt(), money = in.readInt();
        int exp = 0, score = 0, wins = 0, losses = 0, chips = 0;
        if (!moneyOnly) {
            exp = in.readInt(); score = in.readInt(); wins = in.readInt(); losses = in.readInt();
        }
        String client = string(in);
        if (!moneyOnly) chips = in.readInt();
        if (chips == -1) chips = 0;
        var before = game.find(redis, uid);
        if (before == null) return null;
        boolean shortfall = before.money() + money < 0;
        var out = new DataPacket(0x2002).ints(uid);
        if (chips != 0 && game.rounds.held(uid)) return out.ints(2);
        if (moneyOnly && shortfall) return out.ints(2);
        if (shortfall) money = (int) -before.money();
        else if (before.score() + score < 0) { score = -before.score(); shortfall = true; }
        else if (before.chips() + chips < 0) { chips = -before.chips(); shortfall = true; }
        var p = before.delta(money, exp, score, wins, losses, chips);
        if (!game.save(redis, uid, p, before, moneyOnly, source, reason, client, null, true)) return out.ints(2);
        out.ints(shortfall ? 2 : 0).number(p.money()).ints(p.exp(), p.score(), p.wins(), p.losses());
        // Native DUpdateProcess appends the status again on a partial debit.
        return shortfall ? out.ints(money, score, p.chips(), 2) : out.ints(p.chips());
    }

    private DataPacket buyChips(Jedis redis, ByteBuf in) throws SQLException {
        int uid = in.readInt(), activity = in.readInt(), wanted = in.readInt();
        in.readInt(); // Original server applies a fixed purchase rate of 1200 per thousand.
        int bring = in.readInt();
        if (game.balances != null) {
            String key;
            if (in.isReadable()) {
                key = string(in);
                if (in.isReadable() || !key.matches("[a-zA-Z0-9_-]{8,64}"))
                    throw new IllegalArgumentException("购买订单号无效");
            } else {
                // 旧调用方没有序号。同一账号、活动和购买参数只接受一次成功购买。
                key = "legacy:" + activity + ":" + wanted + ":" + bring;
            }
            var receipt = game.balances.buy(uid, activity, wanted, bring, key,
                    game.rounds.held(uid), game.find(redis, uid));
            game.balances.recover(game, redis);
            if (receipt.newlyApplied()) game.logBalance(uid,game.find(redis,uid),false,0,"","");
            return new DataPacket(0x301a).ints(receipt.accepted() ? 1 : 0, receipt.chips(), (int)receipt.money(), wanted);
        }
        var p = game.find(redis, uid);
        if (p == null) return null;
        int cost = (int) ((float) wanted * 1200 / 1000);
        if (wanted < 0 || cost < 0) throw new IllegalArgumentException("Invalid chip purchase");
        boolean allowed = cost <= p.money() && !game.rounds.held(uid);
        if (allowed) {
            var next = p.balance(p.money() - cost, Math.addExact(p.chips(), wanted));
            allowed = game.save(redis, uid, next, p, false, 0, "", "",
                    new GoldStore.Chips(uid, activity, next.chips(), bring), false);
            if (allowed) p = next;
        }
        return new DataPacket(0x301a).ints(allowed ? 1 : 0, p.chips(), (int) p.money(), wanted);
    }

    private DataPacket redeemChips(Jedis redis, ByteBuf in) throws SQLException {
        int uid = in.readInt(), rate = in.readInt();
        var p = game.find(redis, uid);
        if (p == null) return null;
        if (rate != 0) in.skipBytes(8); // Bring and activity have no persistent effect here.
        if (rate < 0) throw new IllegalArgumentException("Invalid exchange rate");
        // DChip2MoneyProcess divides the integer rate before applying it to the chips.
        if (game.rounds.held(uid)) return new DataPacket(0x301d).ints(1, (int)p.money());
        int credit = rate == 0 ? p.chips() : (int) (p.chips() * (float) (rate / 1000));
        var next = p.balance(Math.addExact(p.money(), credit), 0);
        if (!game.save(redis, uid, next, p, false, 0, "", "", null, false))
            return new DataPacket(0x301d).ints(1, (int)p.money());
        p = next;
        return new DataPacket(0x301d).ints(0, (int) p.money());
    }

    private DataPacket tables(Jedis redis, ByteBuf in) {
        int level = in.readInt(), sid = in.readInt(), count = in.readInt(), seats = in.readInt();
        in.readInt(); // Game type is not used by the native table list.
        if (count < 0 || count > 65536 || seats < 1 || seats > 64) throw new IllegalArgumentException("Invalid table dimensions");
        String players = String.join(",", Collections.nCopies(seats, "0"));
        try (var batch = redis.pipelined()) {
            for (int i = 0; i < count; i++) {
                batch.hset("TABLE_LIST_" + level, Integer.toString((sid << 16) + i), players);
                if ((i + 1) % 256 == 0) batch.sync();
            }
            batch.sync();
        }
        return new DataPacket(0x3200).ints(1);
    }

    @Override public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
        org.slf4j.LoggerFactory.getLogger(DataProtocol.class).warn("Data request failed", cause);
        ctx.close();
    }
}
