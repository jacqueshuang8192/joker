package com.j.joker.game;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.core.env.Environment;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import redis.clients.jedis.DefaultJedisClientConfig;
import redis.clients.jedis.HostAndPort;
import redis.clients.jedis.JedisPool;

import javax.xml.parsers.DocumentBuilderFactory;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

final class GameSettings {
    private record RedisSettings(String host, int port, String user, String password) {}

    static NodeList games(Environment env, String role) throws Exception {
        var factory = DocumentBuilderFactory.newInstance();
        factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
        var xml = Path.of(env.getProperty(role.toUpperCase(java.util.Locale.ROOT) + "_CONFIG", "/srv/" + role + "/bin/config.xml"));
        var sections = factory.newDocumentBuilder().parse(xml.toFile()).getElementsByTagName("GAME");
        if (sections.getLength() == 0) throw new IllegalArgumentException("Missing GAME configuration");
        return sections;
    }

    static JedisPool redis(Environment env) throws Exception {
        var settings = new ObjectMapper().readValue(Path.of(env.getProperty("JOKER_REDIS_CONFIG",
                "/srv/redis.json")).toFile(), RedisSettings.class);
        var credentials = DefaultJedisClientConfig.builder().timeoutMillis(3000);
        if (settings.user() != null && !settings.user().isEmpty()) credentials.user(settings.user());
        if (settings.password() != null && !settings.password().isEmpty()) credentials.password(settings.password());
        var pool = new JedisPool(new HostAndPort(settings.host(), settings.port()), credentials.build());
        try (var client = pool.getResource()) { client.ping(); }
        catch (RuntimeException e) { pool.close(); throw e; }
        return pool;
    }

    static class Database {
        final String url;
        final Properties credentials = new Properties();
        final int shards;
        Database(Element db) {
            shards = Integer.parseInt(db.getAttribute("tableNum"));
            if (shards <= 0) throw new IllegalArgumentException("Invalid tableNum");
            // The native service connects each dbNum entry to the same dbName on the same host.
            if (Integer.parseInt(db.getAttribute("dbNum")) < 1) throw new IllegalArgumentException("Invalid dbNum");
            url = "jdbc:mysql://" + db.getAttribute("ip") + ":" + db.getAttribute("port") + "/" + db.getAttribute("dbName");
            credentials.setProperty("user", db.getAttribute("user"));
            credentials.setProperty("password", db.getAttribute("pwd"));
            credentials.setProperty("connectTimeout", "3000");
            credentials.setProperty("socketTimeout", "5000");
        }
        Connection connect() throws SQLException { return DriverManager.getConnection(url, credentials); }
    }

}
