package com.j.joker.game;

import com.j.joker.game.niuniu.DouniuSettings;
import com.j.joker.game.niuniu.application.DouniuService;
import com.j.joker.game.niuniu.infrastructure.AllocConnection;
import com.j.joker.game.niuniu.infrastructure.DataClient;
import com.j.joker.game.niuniu.infrastructure.DouniuAdmission;
import com.j.joker.game.niuniu.infrastructure.RoomJournal;
import com.j.joker.game.niuniu.interfaces.tcp.DouniuProtocol;
import com.j.joker.game.niuniu.interfaces.tcp.HallProtocol;
import com.j.joker.game.niuniu.util.Json;
import com.j.joker.game.rooms.application.Lobby;
import com.j.joker.game.rooms.application.RoomAllocation;
import com.j.joker.game.rooms.interfaces.tcp.AllocationProtocol;
import com.j.joker.game.rooms.interfaces.tcp.OnlineUserProtocol;
import com.j.joker.game.rooms.interfaces.tcp.LobbyNoticeProtocol;
import com.j.joker.game.rooms.infrastructure.RedisLobbyAccounts;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.Channel;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelOption;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.codec.LengthFieldBasedFrameDecoder;
import io.netty.handler.codec.http.HttpObjectAggregator;
import io.netty.handler.codec.http.HttpServerCodec;
import io.netty.handler.flow.FlowControlHandler;
import io.netty.handler.timeout.ReadTimeoutHandler;
import io.netty.util.concurrent.DefaultEventExecutorGroup;
import java.net.InetSocketAddress;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.core.env.Environment;

@SpringBootApplication
public class GameApplication {
    public static void main(String[] args) {
        SpringApplication.run(GameApplication.class, args);
    }

    @Bean(destroyMethod = "close")
    Server server() {
        return new Server();
    }

    @Bean
    ApplicationRunner listen(Server server, Environment env) {
        return args -> server.start(env);
    }

    static class Server implements AutoCloseable {
        private final NioEventLoopGroup boss = new NioEventLoopGroup(1);
        private final NioEventLoopGroup workers = new NioEventLoopGroup(2);
        private final List<Channel> listeners = new ArrayList<>();
        private String hallRegistration;
        private GoldStore gold;
        private DataProtocol.Store data;
        private DefaultEventExecutorGroup dataExecutor;
        private DouniuService douniu;
        private AllocConnection alloc;
        private redis.clients.jedis.JedisPool douniuRedis;

        void start(Environment env) throws Exception {
            String role = env.getProperty("GAME_ROLE", "gateway");
            ChannelInitializer<SocketChannel> initializer;
            int port;
            switch (role) {
                case "gateway" -> {
                    boolean forwardPeer = env.getProperty("HALL_PROXY_PROTOCOL", Boolean.class, false);
                    var trustedProxies = ProxyPeer.trusted(env.getProperty("TRUSTED_HTTP_PROXY_IPS"));
                    Map<String, InetSocketAddress> routes = Map.of(
                            "/ws/hall", endpoint(env, "HALL", 4700),
                            "/ws/douniu", endpoint(env, "DOUNIU", 13600));
                    initializer = new ChannelInitializer<>() {
                        protected void initChannel(SocketChannel ch) {
                            ch.pipeline().addLast(new ReadTimeoutHandler(90), new HttpServerCodec(),
                                    new HttpObjectAggregator(8192), new Gateway(routes, forwardPeer, trustedProxies));
                        }
                    };
                    port = 8090;
                }
                case "data" -> {
                    data = new DataProtocol.Store(env);
                    // Match the single native dispatcher and keep JDBC/Redis I/O off the socket loop.
                    dataExecutor = new DefaultEventExecutorGroup(1);
                    dataExecutor.scheduleWithFixedDelay(() -> {
                        try (var redis = data.redis.getResource()) {
                            for (var game : data.games.values()) {
                                game.rounds.recover(game, redis);
                                if (game.hundred != null) {
                                    game.balances.recover(game, redis);
                                    game.hundred.tick(redis);
                                    game.balances.recover(game, redis);
                                }
                            }
                        } catch (Exception ex) {
                            org.slf4j.LoggerFactory.getLogger(DataProtocol.class).warn("牛牛缓存补记待重试", ex);
                        }
                    }, 0, 5, java.util.concurrent.TimeUnit.SECONDS);
                    initializer = new ChannelInitializer<>() {
                        protected void initChannel(SocketChannel ch) {
                            ch.pipeline().addLast(new LengthFieldBasedFrameDecoder(DataClient.MAX_FRAME_BYTES, 0, 4, 0, 0));
                            ch.pipeline().addLast(dataExecutor, new DataProtocol(data));
                        }
                    };
                    port = 6001;
                }
                case "rooms", "douniu" -> {
                    boolean pure = role.equals("rooms");
                    // 牛牛房间服务：替代原生 DouNiuServerGroup，端口与 gateway 的 /ws/douniu 路由一致。
                    dataExecutor = new DefaultEventExecutorGroup(1);
                    DouniuService.Admission admission;
                    RoomJournal journal = null;
                    if (pure && !DouniuSettings.dataEnabled(env)) throw new IllegalArgumentException("纯 Java 游戏须启用 data");
                    if (DouniuSettings.dataEnabled(env)) {
                        douniuRedis = GameSettings.redis(env);
                        int level = env.getProperty("DOUNIU_LEVEL", Integer.class, 302);
                        admission = new DouniuAdmission(douniuRedis, level);
                        journal = new RoomJournal(douniuRedis, level, env.getProperty("DOUNIU_SERVER_ID", Integer.class, 1802), pure);
                    } else {
                        if (!"127.0.0.1".equals(env.getProperty("GAME_BIND_ADDRESS"))
                                || !env.getProperty("DOUNIU_LOCAL_DEMO", Boolean.class, false)) {
                            throw new IllegalArgumentException("离线演示须显式启用并绑定 127.0.0.1");
                        }
                        admission = (uid, tid, key, watch) -> new DouniuService.Access(0, watch ? 1 : 0, false);
                    }
                    var accounts = new DataClient(env);
                    douniu = new DouniuService(DouniuSettings.config(env), accounts, admission, journal);
                    if (pure) {
                        int level = env.getProperty("DOUNIU_LEVEL", Integer.class, 302);
                        int serverId = env.getProperty("DOUNIU_SERVER_ID", Integer.class, 1802);
                        String address = env.getRequiredProperty("ADVERTISE_IP");
                        if (!io.netty.util.NetUtil.isValidIpV4Address(address)) throw new IllegalArgumentException("大厅地址须为 IPv4");
                        var lobby = new Lobby(new RedisLobbyAccounts(douniuRedis, (DouniuAdmission) admission), douniu, level);
                        var directory = new RoomAllocation(level, serverId, () -> {
                            try (var redis = douniuRedis.getResource()) {
                                return redis.incr("JOKER_DOUNIU:" + level + ":" + serverId + ":sequence");
                            }
                        }, douniu);
                        var roomJournal = journal;
                        listenFrames("127.0.0.1", 11603, () -> new AllocationProtocol(directory,roomJournal));
                        listenFrames("127.0.0.1", 4701,
                                () -> new LobbyNoticeProtocol(lobby, accounts));
                        listenFrames("127.0.0.1", 7500, () -> new OnlineUserProtocol(lobby,douniuRedis));
                        var hundred = new com.j.joker.game.hundred.interfaces.HundredHall(
                                new com.j.joker.game.hundred.infrastructure.HundredClient(env.getProperty("DATA_HOST","data"),
                                        env.getProperty("DATA_PORT",Integer.class,6001)));
                        dataExecutor.scheduleWithFixedDelay(hundred::poll,1,1,java.util.concurrent.TimeUnit.SECONDS);
                        listenFrames(env.getProperty("GAME_BIND_ADDRESS", "0.0.0.0"), 4700,
                                () -> new HallProtocol(douniu, lobby, address, DouniuSettings.port(env), level,hundred),
                                ProxyPeer.trusted(env.getProperty("TRUSTED_HALL_GATEWAY_IPS")));
                        douniu.registered();
                        hallRegistration = Json.write(Map.of("SVID", 1, "IP", address, "PORT", 4700,
                                "instance", java.util.UUID.randomUUID().toString()));
                    }
                    initializer = new ChannelInitializer<>() {
                        protected void initChannel(SocketChannel ch) {
                            ch.pipeline().addLast(new ReadTimeoutHandler(120),
                                    new LengthFieldBasedFrameDecoder(10240, 0, 4, 0, 0));
                            ch.pipeline().addLast(dataExecutor, new DouniuProtocol(douniu));
                        }
                    };
                    port = DouniuSettings.port(env);
                }
                case "gold" -> {
                    gold = new GoldStore(env);
                    initializer = new ChannelInitializer<>() {
                        protected void initChannel(SocketChannel ch) {
                            ch.pipeline().addLast(new ReadTimeoutHandler(600),
                                    new LengthFieldBasedFrameDecoder(10240, 0, 4, 0, 0),
                                    new FlowControlHandler(), new GoldProtocol(gold));
                        }
                    };
                    port = 6005;
                }
                default -> throw new IllegalArgumentException("Unknown GAME_ROLE: " + role);
            }
            Channel listener = bind(env.getProperty("GAME_BIND_ADDRESS", "0.0.0.0"),
                    env.getProperty("GAME_PORT", Integer.class, port), initializer);
            if (hallRegistration != null) {
                try (var redis = douniuRedis.getResource()) {
                    redis.hset("HALLSERVER", "HALLSERVER1", hallRegistration);
                }
            } else if (douniuRedis != null) {
                int boundPort = ((InetSocketAddress) listener.localAddress()).getPort();
                alloc = new AllocConnection(workers.next(), env, douniu, boundPort);
                alloc.connect();
            }
        }

        private Channel bind(String host, int port, ChannelInitializer<SocketChannel> handler) throws InterruptedException {
            Channel channel = new ServerBootstrap().group(boss, workers).channel(NioServerSocketChannel.class)
                    .childOption(ChannelOption.TCP_NODELAY, true).childHandler(handler).bind(host, port).sync().channel();
            listeners.add(channel);
            return channel;
        }

        private void listenFrames(String host, int port, java.util.function.Supplier<io.netty.channel.ChannelHandler> handler)
                throws InterruptedException {
            listenFrames(host, port, handler, java.util.Set.of());
        }

        private void listenFrames(String host, int port, java.util.function.Supplier<io.netty.channel.ChannelHandler> handler,
                                  java.util.Set<String> trustedGateways) throws InterruptedException {
            bind(host, port, new ChannelInitializer<>() {
                @Override protected void initChannel(SocketChannel ch) {
                    ch.pipeline().addLast(new ReadTimeoutHandler(120));
                    ProxyPeer.install(ch, trustedGateways);
                    ch.pipeline().addLast(new LengthFieldBasedFrameDecoder(65536, 0, 4, 0, 0));
                    ch.pipeline().addLast(dataExecutor, handler.get());
                }
            });
        }

        private static InetSocketAddress endpoint(Environment env, String service, int port) {
            return InetSocketAddress.createUnresolved(env.getProperty(service + "_HOST", "api"),
                    env.getProperty(service + "_PORT", Integer.class, port));
        }

        @Override public void close() {
            if (douniu != null) douniu.close();
            if (alloc != null) alloc.close();
            for (var listener : listeners) listener.close().awaitUninterruptibly();
            if (hallRegistration != null) {
                try (var redis = douniuRedis.getResource()) {
                    redis.eval("if redis.call('HGET',KEYS[1],ARGV[1])==ARGV[2] then return redis.call('HDEL',KEYS[1],ARGV[1]) end",
                            List.of("HALLSERVER"), List.of("HALLSERVER1", hallRegistration));
                } catch (RuntimeException failure) {
                    org.slf4j.LoggerFactory.getLogger(Server.class).warn("未能注销大厅地址", failure);
                }
            }
            boss.shutdownGracefully().awaitUninterruptibly();
            workers.shutdownGracefully().awaitUninterruptibly();
            if (dataExecutor != null) dataExecutor.shutdownGracefully().awaitUninterruptibly();
            if (douniuRedis != null) douniuRedis.close();
            if (data != null) data.close();
            if (gold != null) gold.close();
        }
    }
}
