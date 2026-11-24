package com.j.joker.game;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;

/** Internal length-prefixed BY protocol. These two operations have no reply payload. */
final class GoldProtocol extends SimpleChannelInboundHandler<ByteBuf> {
    private final GoldStore store;
    private Short boundGame;
    private boolean waitingForCapacity;

    GoldProtocol(GoldStore store) { this.store = store; }

    @Override protected void channelRead0(ChannelHandlerContext ctx, ByteBuf data) {
        if (data.readableBytes() < 18 || data.getByte(4) != 'B' || data.getByte(5) != 'Y') {
            ctx.close();
            return;
        }
        short game = data.getShort(12);
        if (!store.supports(game) || (boundGame != null && boundGame != game)) return;
        boundGame = game;
        switch (data.getInt(8)) {
            case 0x3004 -> {
                if (data.readableBytes() < 22) { ctx.close(); return; }
                enqueue(ctx, game, new GoldStore.Player(data.getInt(18)));
            }
            case 0x3005 -> {
                if (data.readableBytes() < 34) { ctx.close(); return; }
                enqueue(ctx, game, new GoldStore.Chips(data.getInt(18), data.getInt(22),
                        data.getInt(26), data.getInt(30)));
            }
        }
    }

    // Stop reading this connection until its current update has entered the writer queue.
    // FlowControlHandler retains later frames from the same TCP read in arrival order.
    private void enqueue(ChannelHandlerContext ctx, short game, GoldStore.Update update) {
        if (store.enqueue(game, update)) {
            if (waitingForCapacity) {
                waitingForCapacity = false;
                ctx.channel().config().setAutoRead(true);
            }
            return;
        }
        if (!waitingForCapacity) {
            waitingForCapacity = true;
            ctx.channel().config().setAutoRead(false);
        }
        ctx.executor().schedule(() -> {
            if (ctx.channel().isActive()) enqueue(ctx, game, update);
        }, 100, java.util.concurrent.TimeUnit.MILLISECONDS);
    }

    @Override public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) { ctx.close(); }
}
