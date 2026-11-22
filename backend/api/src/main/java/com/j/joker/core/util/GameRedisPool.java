package com.j.joker.core.util;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.nio.file.Path;
import redis.clients.jedis.DefaultJedisClientConfig;
import redis.clients.jedis.HostAndPort;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

public final class GameRedisPool {
    private record Endpoint(String host, int port, String user, String password) {}

    private GameRedisPool() {}

    public static JedisPool applicationPool(JedisPoolConfig pool, String host, int port) {
        JedisPool connectionPool = create(pool, host, port, 2000);
        if (System.getenv("JOKER_REDIS_CONFIG") != null) {
            try (var connection = connectionPool.getResource()) {
                connection.ping();
            } catch (RuntimeException e) {
                connectionPool.close();
                throw e;
            }
        }
        return connectionPool;
    }

    static JedisPool create(JedisPoolConfig pool, String host, int port, int timeoutMillis) {
        String path = System.getenv("JOKER_REDIS_CONFIG");
        Endpoint endpoint;
        if (path == null) {
            endpoint = new Endpoint(host, port, ConfigUtil.get("redis.user"), ConfigUtil.get("redis.password"));
        } else {
            try {
                endpoint = new ObjectMapper().readValue(Path.of(path).toFile(), Endpoint.class);
            } catch (IOException e) {
                throw new IllegalStateException("Cannot read panel Redis configuration at " + path, e);
            }
        }
        var client = DefaultJedisClientConfig.builder().timeoutMillis(timeoutMillis);
        if (endpoint.user() != null && !endpoint.user().isEmpty()) client.user(endpoint.user());
        if (endpoint.password() != null && !endpoint.password().isEmpty()) client.password(endpoint.password());
        return new JedisPool(pool, new HostAndPort(endpoint.host(), endpoint.port()), client.build());
    }
}
