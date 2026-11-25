package com.j.joker.game.niuniu.application;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.j.joker.game.niuniu.domain.table.Player;
import java.util.LinkedHashMap;
import java.util.Map;

/** 只接收牌桌客户端展示的字段，消息发布者使用登录座位。 */
final class RoomMessages {
    private static final ObjectMapper JSON = new ObjectMapper();

    static boolean knownFace(int id) {
        return (id >= 1 && id <= 11) || (id >= 51 && id <= 65);
    }

    static String message(Player sender, String raw, boolean location, java.util.function.LongPredicate seated) {
        if (raw == null || raw.length() > 2048) return null;
        try {
            JsonNode source = JSON.readTree(raw);
            if (source == null || !source.isObject()) return null;
            Map<String,Object> out = new LinkedHashMap<>();
            out.put("uid", sender.uid());
            if (location) {
                String lat = source.path("latitude").asText(""), lon = source.path("longitude").asText("");
                if (!coordinate(lat, 90) || !coordinate(lon, 180)) return null;
                out.put("latitude", lat);
                out.put("longitude", lon);
                String city = source.path("city").asText("");
                if (city.length() <= 64) out.put("city", city);
            } else {
                String type = source.path("msgType").asText();
                out.put("msgType", type);
                if ("emoji".equals(type)) {
                    int id = source.path("type").asInt();
                    if (!knownFace(id)) return null;
                    out.put("type", id);
                } else if ("expression".equals(type) || "EmojiArmatureView".equals(type)) {
                    boolean expression = "expression".equals(type);
                    String targetKey = expression ? "uid_to" : "to_uid";
                    String effectKey = expression ? "expressionType" : "type";
                    long target = source.path(targetKey).asLong(0);
                    int effect = source.path(effectKey).asInt(0);
                    if (effect < 1 || effect > (expression ? 7 : 9) || target <= 0 || !seated.test(target)) return null;
                    if (expression) out.put("uid_from", sender.uid());
                    out.put(targetKey, target);
                    out.put(effectKey, effect);
                } else if ("text".equals(type)) {
                    String content = source.path("textMessage").asText("");
                    if (content.isBlank() || content.codePointCount(0, content.length()) > 60) return null;
                    out.put("textMessage", content);
                } else return null;
            }
            return JSON.writeValueAsString(out);
        } catch (JsonProcessingException | NumberFormatException invalid) {
            return null;
        }
    }

    private static boolean coordinate(String text, int bound) {
        if (text.isEmpty() || text.length() > 24) return false;
        return Math.abs(Double.parseDouble(text)) <= bound;
    }
}
