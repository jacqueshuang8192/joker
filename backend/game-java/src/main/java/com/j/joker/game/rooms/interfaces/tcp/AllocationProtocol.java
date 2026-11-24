package com.j.joker.game.rooms.interfaces.tcp;

import com.j.joker.game.rooms.application.RoomAllocation;
import com.j.joker.game.rooms.domain.RoomDefinition;
import com.j.joker.game.niuniu.proto.BinaryReader;
import com.j.joker.game.niuniu.proto.BinaryWriter;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;

/** 仅绑定回环地址，接收 Spring API 的内部 BY 明文控制帧。 */
public final class AllocationProtocol extends SimpleChannelInboundHandler<ByteBuf> {
    private final RoomAllocation allocation;

    public AllocationProtocol(RoomAllocation allocation) { this.allocation = allocation; }

    public static void reply(ChannelHandlerContext ctx, int command, BinaryWriter body) {
        var packet = Unpooled.buffer(18 + body.size());
        packet.writeInt(14 + body.size()).writeShort(0x4259).writeShort(0).writeInt(command)
                .writeZero(6).writeBytes(body.toByteArray());
        ctx.writeAndFlush(packet);
    }

    @Override protected void channelRead0(ChannelHandlerContext ctx, ByteBuf frame) {
        if (frame.readableBytes() < 18 || frame.getShort(4) != 0x4259) { ctx.close(); return; }
        int command = frame.getInt(8);
        frame.skipBytes(18);
        byte[] raw = new byte[frame.readableBytes()];
        frame.readBytes(raw);
        var in = new BinaryReader(raw);
        switch (command) {
            case 0x160, 0x260 -> {
                int result;
                try {
                    result = allocation.create(readRoom(in));
                } catch (IllegalArgumentException | IndexOutOfBoundsException invalid) {
                    result = -99;
                }
                reply(ctx, 0x360, new BinaryWriter().i32(0).i32(Math.min(0, result)).i32(0).i32(Math.max(0, result)));
            }
            case 0x155 -> reply(ctx, 0x361, new BinaryWriter().i32(0).i32(allocation.dissolve(in.i32())));
            case 0x120a -> reply(ctx, command, new BinaryWriter().i32(allocation.release(in.i32(), in.i32())));
            default -> ctx.close();
        }
    }

    private static RoomDefinition readRoom(BinaryReader in) {
        int owner = in.i32(), level = in.i32(), base = in.i32();
        in.i32(); // 个人筹码以 data 的余额为准
        String invite = in.string();
        int activity = in.i32(), rounds = in.i32();
        String rules = in.string();
        int minimum = in.i32(), seats = in.i32();
        in.string(); in.string(); // 头像与说明由 API 管理
        if (!in.string().isEmpty()) throw new IllegalArgumentException("纯 Java 密码房只接受 API 校验值");
        int club = 0, configId = 0, gameType = 0;
        String groupName = "";
        if (in.remaining() > 0) {
            club = in.i32();
            configId = in.i32(); gameType = in.i32(); groupName = in.string();
        }
        if (in.remaining() != 0) throw new IllegalArgumentException("建桌包尾部字段错误");
        return new RoomDefinition(level, activity, owner, invite, club, rounds, seats, base, minimum, configId, gameType, groupName, rules);
    }

    @Override public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
        org.slf4j.LoggerFactory.getLogger(AllocationProtocol.class).warn("分桌请求失败", cause);
        ctx.close();
    }
}
