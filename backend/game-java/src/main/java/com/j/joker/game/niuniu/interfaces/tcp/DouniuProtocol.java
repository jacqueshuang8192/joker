package com.j.joker.game.niuniu.interfaces.tcp;

import com.j.joker.game.niuniu.application.DouniuService;
import com.j.joker.game.niuniu.proto.BinaryReader;
import com.j.joker.game.niuniu.proto.Cmd;
import com.j.joker.game.niuniu.proto.PacketCodec;
import com.j.joker.game.niuniu.proto.ProtoRegistry;
import com.j.joker.game.niuniu.proto.Schema;
import com.j.joker.game.niuniu.proto.SchemaCodec;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.Channel;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import java.util.Map;

/**
 * 牛牛协议处理器：18 字节包头 + 置换加密包体，与客户端 {@code hall/network} 完全一致。
 *
 * <p>帧由 {@code LengthFieldBasedFrameDecoder(10240, 0, 4, 0, 0)} 切好；
 * 这里只做解密、分发与回包加密。
 */
public class DouniuProtocol extends SimpleChannelInboundHandler<ByteBuf> {

    private final DouniuService service;
    protected DouniuService.Session session;

    public DouniuProtocol(DouniuService service) {
        this.service = service;
    }

    @Override
    public void channelActive(ChannelHandlerContext ctx) {
        session = new Session(ctx.channel());
    }

    @Override
    protected void channelRead0(ChannelHandlerContext ctx, ByteBuf input) {
        if (input.readableBytes() < 18 || input.getShort(4) != 0x4259) {
            ctx.close();
            return;
        }
        byte[] bytes = new byte[input.readableBytes()];
        input.readBytes(bytes);
        PacketCodec.Frame frame;
        try {
            frame = PacketCodec.decode(bytes);
        } catch (RuntimeException malformed) {
            ctx.close();
            return;
        }
        handleFrame(ctx, frame, bytes);
    }

    void handleFrame(ChannelHandlerContext ctx, PacketCodec.Frame frame, byte[] wire) {
        service.handle(session, frame.cmd(), commandFields(frame.cmd(), frame.body()));
    }

    // 兼容早期客户端的空准备包和不带座位号的自动选座包。
    private static Map<String, Object> commandFields(int cmd, byte[] body) {
        var in = new BinaryReader(body);
        switch (cmd) {
            case Cmd.CLI_LOGIN_ROOM -> { return roomLogin(body); }
            case Cmd.CLI_READYNOW_ROOM -> {
                if (body.length == 0) return Map.of("ready", 1);
                if (body.length != 4) return null;
                int ready = in.i32();
                return ready == 0 || ready == 1 ? Map.of("ready", ready) : null;
            }
            case Cmd.CLI_SIT_DOWN -> { return Map.of("seat", body.length == 4 ? in.i32() : -1); }
            case Cmd.CLI_PLAY_CARD -> { return body.length > 0 && body.length == 1 + in.u8() ? Map.of() : null; }
            case Cmd.C2G_CMD_DISSOLVE_ROOM -> { return body.length == 0 ? Map.of() : null; }
            case Cmd.CLI_MSG_FACE, Cmd.CLI_COMMAND_GAMERESULT_RECORD, Cmd.C2G_CMD_REPLY_DISSOLVE_ROOM -> {
                if (body.length != 4) return null;
            }
            default -> { }
        }
        Schema schema = ProtoRegistry.client(cmd);
        if (schema == null || body.length == 0) return Map.of();
        try {
            return SchemaCodec.decode(schema, body);
        } catch (IllegalArgumentException | IndexOutOfBoundsException malformed) {
            return null;
        }
    }

    // 客户端使用两种 0x1001 格式，按完整包长区分。扩展格式尾部另有可选 activityId。
    private static Map<String, Object> roomLogin(byte[] body) {
        var in = new BinaryReader(body);
        int tid = in.i32(), uid = in.i32();
        var compact = new BinaryReader(body);
        compact.i32();
        compact.i32();
        try {
            String key = compact.string();
            compact.string();
            if (compact.remaining() == 0) return Map.of("tid", tid, "uid", uid, "key", key);
        } catch (RuntimeException ignored) {
            // 扩展格式的第三个字段是整数座位号。
        }
        int seat = in.i32();
        int sex = in.u8();
        String nick = in.string();
        String portrait = in.string();
        in.string();
        in.string();
        var info = com.j.joker.game.niuniu.util.Json.parseObject(in.string());
        in.i32();
        int isWatch = in.u8();
        if (isWatch > 1) throw new IllegalArgumentException("无效入房身份");
        if (in.remaining() == 4) in.i32();
        if (in.remaining() != 0) throw new IllegalArgumentException("无效入房包");
        return Map.of("tid", tid, "uid", uid, "seat_id", seat, "nick", nick, "sex", sex,
                "portrait", portrait, "isWatch", isWatch, "key", info.getOrDefault("roomKey", ""));
    }

    @Override
    public void channelInactive(ChannelHandlerContext ctx) {
        if (session != null) {
            service.disconnect(session);
        }
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
        ctx.close();
    }

    private static final class Session implements DouniuService.Session {
        private final Channel channel;
        private long uid;
        private int tableId;
        private int seat = -1;

        Session(Channel channel) {
            this.channel = channel;
        }

        @Override
        public long uid() {
            return uid;
        }

        @Override
        public void uid(long value) {
            uid = value;
        }

        @Override
        public int tableId() {
            return tableId;
        }

        @Override
        public void tableId(int value) {
            tableId = value;
        }

        @Override
        public int seat() {
            return seat;
        }

        @Override
        public void seat(int value) {
            seat = value;
        }

        @Override
        public void send(int cmd, Map<String, Object> values) {
            if (channel == null || !channel.isActive()) {
                return;
            }
            Schema schema = ProtoRegistry.server(cmd);
            byte[] body = schema == null ? new byte[0] : SchemaCodec.encode(schema, values);
            channel.writeAndFlush(Unpooled.wrappedBuffer(PacketCodec.encode(cmd, body)));
        }

        @Override
        public void close() {
            channel.close();
        }
    }
}
