package com.j.joker.game.niuniu.interfaces.tcp;

import com.j.joker.game.niuniu.application.DouniuService;
import com.j.joker.game.niuniu.proto.*;
import com.j.joker.game.niuniu.util.Json;
import com.j.joker.game.rooms.application.Lobby;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerContext;

/** 纯 Java 大厅复用房间协议会话，同一连接从选桌进入牌局。 */
public final class HallProtocol extends DouniuProtocol implements Lobby.Connection {
    private final DouniuService rooms;
    private final Lobby lobby;
    private final String address;
    private final int port, level;
    private int uid, selected;
    private String key;
    private ChannelHandlerContext channel;

    public HallProtocol(DouniuService service, Lobby lobby, String address, int port, int level) {
        super(service);
        this.rooms = service;
        this.lobby = lobby;
        this.address = address;
        this.port = port;
        this.level = level;
    }

    @Override public void channelActive(ChannelHandlerContext ctx) {
        super.channelActive(ctx);
        channel = ctx;
    }

    @Override public void channelInactive(ChannelHandlerContext ctx) {
        lobby.logout(uid, this);
        super.channelInactive(ctx);
    }

    @Override public void disconnect() { channel.close(); }

    private void reply(int cmd, BinaryWriter body) { notice(cmd, body.toByteArray()); }

    @Override public void notice(int cmd, byte[] payload) {
        channel.writeAndFlush(Unpooled.wrappedBuffer(PacketCodec.encode(cmd, 1, 0, 0, 0, payload)));
    }

    @Override void handleFrame(ChannelHandlerContext ctx, PacketCodec.Frame frame, byte[] wire) {
        int cmd = frame.cmd();
        var in = new BinaryReader(frame.body());
        if (cmd == 0x110 && (in.remaining() == 4 || in.remaining() == 0)) {
            ctx.writeAndFlush(Unpooled.wrappedBuffer(wire));
        } else if (cmd == 0x116) {
            int account = in.i32();
            in.i32(); in.u8();
            String proof = (String)Json.parseObject(in.string()).get("roomKey");
            if (in.remaining() != 0 || uid != 0 || !lobby.login(account, proof, this)) { ctx.close(); return; }
            uid = account;
            key = proof;
            var route = lobby.current(uid);
            var result = new BinaryWriter().i32(1).i32(0).i32(0).i32(route == null ? 0 : route.tid());
            if (route == null) result.string("").i32(0).i16(-1);
            reply(0x201, result.i32(0).i32(0).u8(0));
        } else if (uid == 0) {
            ctx.close();
        } else if (cmd == 0x668) {
            var route = lobby.current(uid);
            var result = new BinaryWriter();
            if (route == null) result.u16(0).i32(0).i32(0).i32(0).u8(0);
            else result.u16(level).i32(route.tid()).i32(route.activity()).i32(route.base()).u8(lobby.mode(uid, route));
            reply(cmd, result);
        } else if (cmd == 0x172) {
            int club = in.i32(), type = in.i32(), page = in.i32(), size = in.i32();
            int game = in.i32(), config = in.i32();
            in.string(); in.string();
            for (var table : rooms.clubTables(uid, club, type, page, size, game, config)) {
                var row = new BinaryWriter().i32(club).i32(1).i32(table.tid()).i32(level).i32(table.configId())
                        .i32(table.gameType()).i32(table.round()).u8(table.users().size());
                table.users().forEach(row::string);
                reply(0x175, row.string(table.name()).string(table.invite()));
            }
            reply(0x174, new BinaryWriter().u8(1).u8(0));
        } else if (cmd == 0x113) {
            int requestedLevel = in.u16();
            in.i32(); in.i32();
            int tid = in.i32(), activity = in.i32();
            in.i32();
            int mode = in.u8();
            in.i32(); in.string(); in.string();
            var route = mode <= 1 && in.remaining() == 0
                    ? lobby.select(uid, key, requestedLevel, tid, activity, this) : null;
            if (route == null) { reply(0x212, new BinaryWriter().u16(0).u16(1)); return; }
            selected = tid;
            reply(0x210, new BinaryWriter().i32(tid).u16(tid >>> 16).string(address).i32(port)
                    .i32(1).u16(level).u8(route.seats()).i32(activity).string(route.rules()).string("").u8(mode));
        } else if (cmd == 0x1001) {
            if (in.i32() != selected || in.i32() != uid) { ctx.close(); return; }
            super.handleFrame(ctx, frame, wire);
        } else if (cmd == 0x153) {
            reply(cmd, new BinaryWriter());
        } else if (session.uid() > 0) {
            super.handleFrame(ctx, frame, wire);
        }
    }
}
