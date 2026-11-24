package com.j.joker.game.niuniu.infrastructure;

import com.j.joker.game.niuniu.application.DouniuService;
import com.j.joker.game.niuniu.domain.rules.GameConfig;
import com.j.joker.game.niuniu.domain.table.NiuNiuTable;
import com.j.joker.game.niuniu.proto.BinaryReader;
import com.j.joker.game.niuniu.proto.BinaryWriter;
import com.j.joker.game.niuniu.util.Json;
import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.*;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.handler.codec.LengthFieldBasedFrameDecoder;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;

/** 房间主动连接内网 alloc。控制包使用明文 BY 帧，与玩家端口分开。 */
public final class AllocConnection implements DouniuService.AllocEvents, AutoCloseable {
    private static final Logger LOG = LoggerFactory.getLogger(AllocConnection.class);
    private final EventLoop loop;
    private final DouniuService service;
    private final int serverId, level, gamePort, allocPort;
    private final String host, advertised;
    private final Path readyFile;
    private final Set<DouniuService.End> pending = new LinkedHashSet<>();
    private final Map<Integer, Integer> seats = new HashMap<>();
    private int totalUsers;
    private Channel channel;
    private volatile boolean stopping;

    public AllocConnection(EventLoop loop, Environment env, DouniuService service, int gamePort) {
        this.loop = loop;
        this.service = service;
        this.gamePort = gamePort;
        serverId = env.getProperty("DOUNIU_SERVER_ID", Integer.class, 1802);
        level = env.getProperty("DOUNIU_LEVEL", Integer.class, 302);
        host = env.getProperty("ALLOC_HOST", "127.0.0.1");
        allocPort = env.getProperty("ALLOC_PORT", Integer.class, 11603);
        advertised = env.getRequiredProperty("ADVERTISE_IP");
        if (serverId < 1 || serverId > Short.MAX_VALUE || level < 1 || level > Short.MAX_VALUE
                || !io.netty.util.NetUtil.isValidIpV4Address(advertised)) {
            throw new IllegalArgumentException("请核对牛牛服务编号、场次和 ADVERTISE_IP");
        }
        String marker = env.getProperty("DOUNIU_READY_FILE");
        readyFile = marker == null ? null : Path.of(marker);
        readiness(false);
        service.setAllocator(this);
        pending.addAll(service.pendingEnds());
    }

    @Override public void seatsChanged(int tid, int count) {
        loop.execute(() -> updateSeats(tid, count));
    }

    private void updateSeats(int tid, int count) {
        int previous = seats.getOrDefault(tid, 0);
        if (count == previous) return;
        if (count == 0) seats.remove(tid);
        else seats.put(tid, count);
        totalUsers += count - previous;
        if (channel != null && channel.isActive()) {
            send(channel, 0x502, new BinaryWriter().u16(serverId).i32(tid).u16(level).u16(count).i32(totalUsers))
                    .addListener(ChannelFutureListener.CLOSE_ON_FAILURE);
        }
    }

    @Override public void closed(DouniuService.End end) {
        loop.execute(() -> {
            updateSeats(end.tid(), 0);
            pending.add(end);
            if (channel != null && channel.isActive()) reportEnd(channel, end);
        });
    }

    private void readiness(boolean ready) {
        if (readyFile == null) return;
        try {
            if (ready) Files.writeString(readyFile, "registered\n");
            else Files.deleteIfExists(readyFile);
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    public void connect() {
        if (stopping) return;
        var bootstrap = new Bootstrap().group(loop).channel(NioSocketChannel.class)
                .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 3000)
                .option(ChannelOption.SO_KEEPALIVE, true)
                .handler(new ChannelInitializer<SocketChannel>() {
                    @Override protected void initChannel(SocketChannel ch) {
                        ch.pipeline().addLast(new LengthFieldBasedFrameDecoder(10240, 0, 4, 0, 0), new Handler());
                    }
                });
        bootstrap.connect(host, allocPort).addListener((ChannelFutureListener) result -> {
            if (stopping) result.channel().close();
            else if (!result.isSuccess()) retry();
        });
    }

    private void retry() {
        if (!stopping) loop.schedule(this::connect, 2, TimeUnit.SECONDS);
    }

    private static ChannelFuture send(Channel ch, int cmd, BinaryWriter body) {
        ByteBuf packet = Unpooled.buffer(18 + body.size());
        packet.writeInt(14 + body.size()).writeShort(0x4259).writeShort(0).writeInt(cmd)
                .writeZero(6).writeBytes(body.toByteArray());
        return ch.writeAndFlush(packet);
    }

    private void reportEnd(Channel ch, DouniuService.End end) {
        // 面板发起的解散只需通知 alloc 释放活动。自然打完的房卡局还要上报局数。
        BinaryWriter body = new BinaryWriter();
        if (end.requested()) body.i32(end.activity());
        else body.i32(end.tid()).i32(end.activity()).i32(end.rounds());
        send(ch, end.requested() ? 0x150 : 0x157, body).addListener((ChannelFutureListener) result -> {
            if (result.isSuccess()) {
                try {
                    service.endSent(end);
                    pending.remove(end);
                } catch (RuntimeException failure) {
                    LOG.warn("牛牛活动 {} 的退桌通知待重新确认", end.activity(), failure);
                    ch.close();
                }
            } else ch.close();
        });
    }

    private final class Handler extends SimpleChannelInboundHandler<ByteBuf> {
        @Override public void channelActive(ChannelHandlerContext ctx) {
            channel = ctx.channel();
            var rooms = service.occupancy();
            seats.clear();
            seats.putAll(rooms);
            totalUsers = rooms.values().stream().mapToInt(Integer::intValue).sum();
            var report = new BinaryWriter().u16(serverId).u16(level).i32(totalUsers).i32(rooms.size());
            rooms.forEach((tid, count) -> report.i32(tid).i32(0).u16(count));
            report.i32(0); // 不预建公共桌，由 alloc 按开房请求分配。
            send(channel, 0x501, report).addListener(ChannelFutureListener.CLOSE_ON_FAILURE);
            send(channel, 0x504, new BinaryWriter().string(advertised).i32(gamePort).u16(serverId))
                    .addListener(ChannelFutureListener.CLOSE_ON_FAILURE);
            for (var end : Set.copyOf(pending)) reportEnd(channel, end);
            LOG.info("向 alloc {}:{} 登记牛牛场次 {}、服务 {}、玩家端口 {}", host, allocPort, level, serverId, gamePort);
        }

        @Override protected void channelRead0(ChannelHandlerContext ctx, ByteBuf packet) {
            if (packet.readableBytes() < 18 || packet.getUnsignedShort(4) != 0x4259) {
                ctx.close();
                return;
            }
            int cmd = packet.getInt(8);
            // 注册回执是 CLIENT_PACKET 包裹的原始 0x501 帧。
            if (cmd == 1 && packet.readableBytes() >= 52 && packet.getInt(18) == 0
                    && packet.getInt(38) == 0x501 && packet.getUnsignedShort(48) == serverId
                    && packet.getUnsignedShort(50) == level) {
                service.registered();
                readiness(true);
                return;
            }
            if (cmd != 0x403 && cmd != 0x155) return;
            packet.skipBytes(18);
            byte[] payload = new byte[packet.readableBytes()];
            packet.readBytes(payload);
            var in = new BinaryReader(payload);
            int tid = in.i32();
            if ((tid >>> 16) != serverId) throw new IllegalArgumentException("桌号与服务编号不匹配");
            if (cmd == 0x155) {
                int activity = in.i32();
                if (in.remaining() != 0) throw new IllegalArgumentException("退桌包长度错误");
                service.requestRemoval(tid, activity);
                return;
            }
            int base = in.i32(), owner = in.i32();
            String invite = in.string();
            int activity = in.i32(), rounds = in.i32();
            in.i32(); // 开房携带筹码，个人余额另由 data 核验。
            String json = in.string();
            in.i32(); // 俱乐部准入门槛由 alloc 检查。
            int count = in.u8(), club = in.i32();
            if (in.remaining() != 0 || activity <= 0) throw new IllegalArgumentException("建桌包无效");
            try {
                if (owner <= 0 || rounds <= 0 || base <= 0 || count < 2 || count > NiuNiuTable.MAX_SEATS) {
                    throw new IllegalArgumentException("建桌参数无效");
                }
                var settings = Json.parseObject(json);
                settings.put("baseChip", base);
                settings.put("maxSeatCount", count);
                settings.put("round", rounds);
                settings.put("master", owner);
                var rules = GameConfig.fromMap(settings);
                if (!rules.hasJQK() && count * rules.handSize() > 40) {
                    throw new IllegalArgumentException("无 JQK 的房间最多支持 8 人");
                }
                service.allocate(tid, activity, owner, invite, club, rules, Json.write(settings));
            } catch (IllegalArgumentException invalid) {
                LOG.warn("牛牛桌 {} 活动 {} 配置无效，通知 alloc 收回空桌", tid, activity, invalid);
                closed(new DouniuService.End(tid, activity, 0, false));
            }
        }

        @Override public void channelInactive(ChannelHandlerContext ctx) {
            if (channel == ctx.channel()) {
                channel = null;
                readiness(false);
                retry();
            }
        }

        @Override public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
            LOG.warn("牛牛 alloc 控制连接异常", cause);
            ctx.close();
        }
    }

    @Override public void close() {
        stopping = true;
        loop.execute(() -> { if (channel != null) channel.close(); });
    }
}
