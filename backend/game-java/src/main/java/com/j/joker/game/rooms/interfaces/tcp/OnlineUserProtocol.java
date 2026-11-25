package com.j.joker.game.rooms.interfaces.tcp;

import com.j.joker.game.rooms.application.Lobby;
import com.j.joker.game.niuniu.proto.BinaryWriter;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;

/** 服务内网在线用户查询。断线后仍可查询当前活动的恢复路由。 */
public final class OnlineUserProtocol extends SimpleChannelInboundHandler<ByteBuf> {
    private final Lobby lobby;
    private final redis.clients.jedis.JedisPool pool;
    public OnlineUserProtocol(Lobby lobby, redis.clients.jedis.JedisPool pool) { this.lobby = lobby; this.pool = pool; }
    @Override protected void channelRead0(ChannelHandlerContext ctx, ByteBuf frame) {
        if (frame.readableBytes() >= 18 && frame.getShort(4) == 0x4259) {
            int cmd = frame.getInt(8);
            if (cmd == 0x113 || cmd == 0x199) {
                int expected = cmd == 0x113 ? 32 : 28;
                if (frame.readableBytes() != expected) { ctx.close(); return; }
                int uid = frame.getInt(expected-4);
                try (var redis = pool.getResource()) {
                    if (cmd == 0x113) {
                        boolean granted = com.j.joker.game.rooms.infrastructure.GiftLock.acquire(redis,uid,"legacy");
                        AllocationProtocol.reply(ctx,cmd,new BinaryWriter().i32(granted ? 0 : 1));
                    } else com.j.joker.game.rooms.infrastructure.GiftLock.release(redis,uid,"legacy");
                }
                return;
            }
        }
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
