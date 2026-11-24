package com.j.joker.game.rooms.interfaces.tcp;

import com.j.joker.game.rooms.application.Lobby;
import com.j.joker.game.niuniu.proto.BinaryWriter;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;

/** 服务内网在线用户查询。断线后仍可查询当前活动的恢复路由。 */
public final class OnlineUserProtocol extends SimpleChannelInboundHandler<ByteBuf> {
    private final Lobby lobby;
    public OnlineUserProtocol(Lobby lobby) { this.lobby = lobby; }
    @Override protected void channelRead0(ChannelHandlerContext ctx, ByteBuf frame) {
        if (frame.readableBytes() != 22 || frame.getShort(4) != 0x4259) { ctx.close(); return; }
        int cmd = frame.getInt(8), uid = frame.getInt(18);
        var data = new BinaryWriter().i32(uid);
        switch (cmd) {
            case 0xa1 -> data.i32(lobby.online(uid) ? 1 : -1);
            case 0xa2 -> {
                var route = lobby.current(uid);
                data.i32(route == null ? 0 : route.tid()).i32(route == null ? 0 : (int)(System.currentTimeMillis()/1000));
            }
            default -> { ctx.close(); return; }
        }
        AllocationProtocol.reply(ctx, cmd, data);
    }
}
