package com.j.joker.game.niuniu.proto;

import com.j.joker.game.niuniu.util.Json;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 协议注册表：从 classpath:protocol.json 加载 97 条命令的字段结构。
 * protocol.json 由客户端 handle/NiuNiuProtocol.lua 自动解析生成。
 */
public final class ProtoRegistry {

    private static final Map<Integer, Schema> CLIENT = new LinkedHashMap<>();
    private static final Map<Integer, Schema> SERVER = new LinkedHashMap<>();
    private static final Map<String, Integer> BY_NAME = new LinkedHashMap<>();

    static {
        load();
    }

    private ProtoRegistry() {
    }

    @SuppressWarnings("unchecked")
    private static void load() {
        try (InputStream in = ProtoRegistry.class.getResourceAsStream("/protocol.json")) {
            if (in == null) {
                return;
            }
            String text = new String(in.readAllBytes(), StandardCharsets.UTF_8);
            Map<String, Object> root = Json.parseObject(text);
            for (Map.Entry<String, Object> e : root.entrySet()) {
                Map<String, Object> def = (Map<String, Object>) e.getValue();
                String hex = String.valueOf(def.get("cmd"));
                if (hex == null || hex.equals("null")) {
                    continue;
                }
                int cmd = Integer.decode(hex);
                int ver = ((Number) def.getOrDefault("ver", 1)).intValue();
                BY_NAME.put(e.getKey(), cmd);
                if (def.get("CLIENT") instanceof Map<?, ?> c) {
                    CLIENT.put(cmd, new Schema(cmd, ver, fields((Map<String, Object>) c)));
                }
                if (def.get("SERVER") instanceof Map<?, ?> s) {
                    SERVER.put(cmd, new Schema(cmd, ver, fields((Map<String, Object>) s)));
                }
            }
        } catch (IOException e) {
            throw new IllegalStateException("加载 protocol.json 失败", e);
        }
    }

    @SuppressWarnings("unchecked")
    private static List<FieldSpec> fields(Map<String, Object> block) {
        Object fmt = block.get("fmt");
        if (fmt == null && block.get("_anon") instanceof List<?> anon) {
            fmt = anon;
        }
        List<FieldSpec> out = new ArrayList<>();
        if (fmt instanceof List<?> list) {
            for (Object o : list) {
                if (o instanceof Map<?, ?> raw) {
                    Map<String, Object> m = (Map<String, Object>) raw;
                    String name = (String) m.getOrDefault("name", "");
                    PType type = PType.of(m.get("type") instanceof String t ? t : null);
                    String parser = (String) m.getOrDefault("fixedLengthParser", null);
                    List<FieldSpec> sub = List.of();
                    if (m.get("fmt") instanceof List<?> subList) {
                        sub = fields(Map.of("fmt", subList));
                    }
                    out.add(new FieldSpec(name, type, parser, sub));
                }
            }
        }
        return out;
    }

    public static Schema client(int cmd) {
        return CLIENT.get(cmd);
    }

    public static Schema server(int cmd) {
        return SERVER.get(cmd);
    }

    public static int cmdOf(String name) {
        Integer c = BY_NAME.get(name);
        if (c == null) {
            throw new IllegalArgumentException("未知命令名: " + name);
        }
        return c;
    }

    public static Map<Integer, Schema> allClient() {
        return CLIENT;
    }

    public static Map<Integer, Schema> allServer() {
        return SERVER;
    }
}
