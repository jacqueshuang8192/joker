package com.j.joker.game;

import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.*;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.channel.FixedRecvByteBufAllocator;
import io.netty.handler.codec.http.*;
import io.netty.handler.codec.http.websocketx.*;

import java.net.InetSocketAddress;
import java.util.Base64;
import java.util.Map;

/** Each upgraded socket owns one upstream connection. Clients can only select a configured route. */
final class Gateway extends SimpleChannelInboundHandler<FullHttpRequest> {
    private final Map<String, InetSocketAddress> routes;
    private Channel upstream;

    Gateway(Map<String, InetSocketAddress> routes) {
        this.routes = routes;
    }

    private static void respond(ChannelHandlerContext ctx, HttpResponseStatus status) {
        var response = new DefaultFullHttpResponse(HttpVersion.HTTP_1_1, status);
        response.headers().setInt(HttpHeaderNames.CONTENT_LENGTH, 0);
        ctx.writeAndFlush(response).addListener(ChannelFutureListener.CLOSE);
    }

    @Override protected void channelRead0(ChannelHandlerContext ctx, FullHttpRequest request) {
        if (!request.decoderResult().isSuccess() || !HttpMethod.GET.equals(request.method()) || upstream != null) {
            respond(ctx, HttpResponseStatus.BAD_REQUEST);
            return;
        }
        if ("/health".equals(request.uri())) {
            respond(ctx, HttpResponseStatus.OK);
            return;
        }
        InetSocketAddress target = routes.get(request.uri());
        if (target == null) {
            respond(ctx, HttpResponseStatus.NOT_FOUND);
            return;
        }
        if (!request.headers().containsValue(HttpHeaderNames.UPGRADE, "websocket", true)
                || !request.headers().containsValue(HttpHeaderNames.CONNECTION, "upgrade", true)
                || request.headers().get(HttpHeaderNames.SEC_WEBSOCKET_KEY) == null
                || !"13".equals(request.headers().get(HttpHeaderNames.SEC_WEBSOCKET_VERSION))) {
            respond(ctx, HttpResponseStatus.BAD_REQUEST);
            return;
        }
        var handshake = new WebSocketServerHandshakerFactory("ws://localhost" + request.uri(), null, false,
                65536).newHandshaker(request);
        Channel front = ctx.channel();
        front.config().setAutoRead(false);
        ChannelFuture dial = new Bootstrap().group(front.eventLoop()).channel(NioSocketChannel.class)
                .option(ChannelOption.RCVBUF_ALLOCATOR, new FixedRecvByteBufAllocator(16384))
                .option(ChannelOption.AUTO_READ, false).option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 5000)
                .handler(new ReturnTraffic(front)).connect(target);
        upstream = dial.channel();
        front.closeFuture().addListener(f -> upstream.close());
        request.retain();
        dial.addListener((ChannelFutureListener) connected -> {
            try {
                if (!front.isActive()) return;
                if (!connected.isSuccess()) {
                    respond(ctx, HttpResponseStatus.BAD_GATEWAY);
                    return;
                }
                var upgrade = handshake.handshake(front, request);
                ctx.pipeline().addLast(new WebSocketFrameAggregator(65536), new GameTraffic(upstream, handshake));
                ctx.pipeline().remove(this);
                upgrade.addListener((ChannelFutureListener) result -> {
                    if (result.isSuccess()) {
                        front.config().setAutoRead(true);
                        upstream.config().setAutoRead(true);
                    } else front.close();
                });
            } finally {
                request.release();
            }
        });
    }

    @Override public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) { ctx.close(); }

    // The Lua WebSocket binding sends text. Base64 preserves every game byte, including NUL.
    private static final class GameTraffic extends SimpleChannelInboundHandler<WebSocketFrame> {
        private final Channel backend;
        private final WebSocketServerHandshaker handshake;
        GameTraffic(Channel backend, WebSocketServerHandshaker handshake) {
            this.backend = backend;
            this.handshake = handshake;
        }
        @Override protected void channelRead0(ChannelHandlerContext ctx, WebSocketFrame frame) {
            if (frame instanceof TextWebSocketFrame text) {
                try {
                    byte[] bytes = Base64.getDecoder().decode(text.text());
                    backend.writeAndFlush(Unpooled.wrappedBuffer(bytes)).addListener(ChannelFutureListener.CLOSE_ON_FAILURE);
                } catch (IllegalArgumentException invalidBase64) {
                    handshake.close(ctx.channel(), new CloseWebSocketFrame(1007, "Invalid Base64"));
                }
            } else if (frame instanceof PingWebSocketFrame) {
                ctx.writeAndFlush(new PongWebSocketFrame(frame.content().retain()));
            } else if (frame instanceof CloseWebSocketFrame close) {
                handshake.close(ctx.channel(), close.retain());
            } else if (!(frame instanceof PongWebSocketFrame)) {
                handshake.close(ctx.channel(), new CloseWebSocketFrame(1003, "Expected Base64 text"));
            }
        }
        @Override public void channelWritabilityChanged(ChannelHandlerContext ctx) {
            backend.config().setAutoRead(ctx.channel().isWritable());
        }
        @Override public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) { ctx.close(); }
    }

    private static final class ReturnTraffic extends SimpleChannelInboundHandler<ByteBuf> {
        private final Channel front;
        ReturnTraffic(Channel front) { this.front = front; }
        @Override protected void channelRead0(ChannelHandlerContext ctx, ByteBuf buf) {
            byte[] bytes = new byte[buf.readableBytes()];
            buf.readBytes(bytes);
            front.writeAndFlush(new TextWebSocketFrame(Base64.getEncoder().encodeToString(bytes)))
                    .addListener(ChannelFutureListener.CLOSE_ON_FAILURE);
        }
        @Override public void channelWritabilityChanged(ChannelHandlerContext ctx) {
            front.config().setAutoRead(ctx.channel().isWritable());
        }
        @Override public void channelInactive(ChannelHandlerContext ctx) {
            if (front.pipeline().get(GameTraffic.class) != null) {
                front.writeAndFlush(new CloseWebSocketFrame(1001, "Game connection closed"))
                        .addListener(ChannelFutureListener.CLOSE);
            }
        }
        @Override public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) { ctx.close(); }
    }
}
