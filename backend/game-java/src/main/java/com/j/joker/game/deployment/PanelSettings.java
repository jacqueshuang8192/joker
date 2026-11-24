package com.j.joker.game.deployment;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.nio.file.attribute.PosixFilePermissions;
import java.security.*;
import java.util.*;
import java.util.regex.Pattern;

/** 纯 Java 编排的首次配置。与原部署共用模板和 keys.json，每次重建沿用原业务密钥。 */
public final class PanelSettings {
    private static final Path SETTINGS = Path.of("/settings"), TEMPLATES = Path.of("/opt/joker/panel/config");
    private static final ObjectMapper JSON = new ObjectMapper();
    private static final Pattern SLOT = Pattern.compile("@([A-Z_]+)@");
    private static final List<String> FILES = List.of("api.properties", "data.xml", "gold-example.xml");
    private static String env(String key, String fallback) { return System.getenv().getOrDefault(key, fallback); }

    private static String host(String variable, String fallback) {
        String host = env(variable, fallback);
        if (!host.matches("[a-zA-Z0-9_][a-zA-Z0-9_.-]*")) throw new IllegalArgumentException(variable);
        return host;
    }
    private static int port(String variable, int fallback) {
        int number = Integer.parseInt(env(variable, String.valueOf(fallback)));
        if (number < 1 || number > 65535) throw new IllegalArgumentException(variable);
        return number;
    }
    private static void write(Path target, byte[] value, String permissions) throws Exception {
        Path tmp = Files.createTempFile(target.getParent(), ".prepare-", ".tmp",
                PosixFilePermissions.asFileAttribute(PosixFilePermissions.fromString("rw-------")));
        try {
            Files.write(tmp, value);
            Files.setPosixFilePermissions(tmp, PosixFilePermissions.fromString(permissions));
            Files.move(tmp, target, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
        } finally { Files.deleteIfExists(tmp); }
    }
    private static Map<String,String> keys() throws Exception {
        var path = SETTINGS.resolve("keys.json");
        List<String> names = List.of("DEFAULT_KEY","SYSTEM_PASSWORD","SIGN_KEY","AGENT_PASSWORD","AES_KEY","MT_KEY");
        if (Files.exists(path)) {
            Map<String,String> stored = JSON.readValue(path.toFile(), new TypeReference<>() {});
            if (names.stream().anyMatch(k -> stored.get(k) == null || stored.get(k).isEmpty()))
                throw new IllegalStateException("现有 keys.json 缺少业务密钥");
            return stored;
        }
        var map = new TreeMap<String,String>();
        var random = new SecureRandom();
        for (String key : names) {
            byte[] bytes = new byte[key.equals("AES_KEY") || key.equals("MT_KEY") ? 8 : 24];
            random.nextBytes(bytes);
            map.put(key, HexFormat.of().formatHex(bytes));
        }
        write(path, JSON.writeValueAsBytes(map), "rw-------");
        return map;
    }
    private static String component(String s) {
        return java.net.URLEncoder.encode(s, StandardCharsets.UTF_8).replace("+","%20");
    }
    private static String escape(String value, boolean xml) {
        if (value.codePoints().anyMatch(c -> c < 32)) throw new IllegalArgumentException("配置含控制字符");
        return xml ? value.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&apos;")
                : value.replace("\\","\\\\").replace(" ", "\\ ");
    }

    public static void main(String[] args) throws Exception {
        var values = new TreeMap<>(keys());
        values.put("DB_HOST", host("MYSQL_HOST","mysql"));
        values.put("DB_PORT", String.valueOf(port("MYSQL_PORT",3306)));
        values.put("DB_NAME", env("MYSQL_DATABASE","shenshou_game"));
        if (!values.get("DB_NAME").matches("[a-zA-Z0-9_]+")) throw new IllegalArgumentException("MYSQL_DATABASE");
        values.put("DB_USER", env("MYSQL_USER","shenshou_game"));
        values.put("DB_PASSWORD", env("MYSQL_PASSWORD",""));
        if (values.get("DB_PASSWORD").isEmpty()) throw new IllegalArgumentException("MYSQL_PASSWORD");
        String user = env("MONGO_USER",""), pass = env("MONGO_PASSWORD","");
        if (user.isEmpty() != pass.isEmpty()) throw new IllegalArgumentException("MongoDB 账号密码须配套填写");
        String auth = user.isEmpty() ? "" : component(user) + ":" + component(pass) + "@";
        values.put("MONGO_URI","mongodb://" + auth + host("MONGO_HOST","mongo") + ":" + port("MONGO_PORT",27017)
                + "/douyoudb?authSource=" + component(env("MONGO_AUTH_DATABASE","admin")));
        values.put("MEMCACHED_HOST",host("MEMCACHED_HOST","memcached"));
        values.put("MEMCACHED_PORT",String.valueOf(port("MEMCACHED_PORT",11211)));
        Map<String,Object> redis = new TreeMap<>(Map.of("host",host("REDIS_HOST","redis"),"port",port("REDIS_PORT",6379),
                "user",env("REDIS_USER",""),"password",env("REDIS_PASSWORD","")));
        var runtime = Files.createDirectories(SETTINGS.resolve("runtime-java"));
        var generated = new TreeMap<String,byte[]>();
        generated.put("redis.json", JSON.writeValueAsBytes(redis));
        for (String file : FILES) {
            String template = Files.readString(TEMPLATES.resolve(file + ".in"));
            String result = SLOT.matcher(template).replaceAll(m -> java.util.regex.Matcher.quoteReplacement(
                    escape(Objects.requireNonNull(values.get(m.group(1)), m.group(1)), file.endsWith(".xml"))));
            // hall.port 仅供 API 内部推送。玩家地址由 HALLSERVER 发布。
            if (file.equals("api.properties")) result = result.replace("hall.port=4700", "hall.port=4701");
            generated.put(file, result.getBytes(StandardCharsets.UTF_8));
        }
        // 内容摘要含密钥派生数据，仅保存在私有卷。参数相同则保留管理员手工调整的运行配置。
        var digest = MessageDigest.getInstance("SHA-256");
        generated.forEach((name, bytes) -> { digest.update(name.getBytes(StandardCharsets.UTF_8)); digest.update(bytes); });
        String hash = HexFormat.of().formatHex(digest.digest());
        var stamp = SETTINGS.resolve("pure-java.sha256");
        if (Files.exists(stamp) && hash.equals(Files.readString(stamp))
                && generated.keySet().stream().allMatch(n -> Files.isRegularFile(runtime.resolve(n)))) return;
        for (var entry : generated.entrySet()) write(runtime.resolve(entry.getKey()), entry.getValue(), "r--r--r--");
        write(stamp, hash.getBytes(StandardCharsets.US_ASCII), "rw-------");
    }
}
