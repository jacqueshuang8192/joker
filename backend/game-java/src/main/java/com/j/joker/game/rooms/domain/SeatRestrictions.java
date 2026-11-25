package com.j.joker.game.rooms.domain;

import java.util.Collection;
import java.util.Map;

public record SeatRestrictions(boolean sameIp, int metres) {
    public record Position(String ip, Double latitude, Double longitude) {
        public static Position of(String ip, String latitude, String longitude) {
            try {
                double lat = Double.parseDouble(latitude), lon = Double.parseDouble(longitude);
                if (Math.abs(lat) <= 90 && Math.abs(lon) <= 180 && (lat != 0 || lon != 0))
                    return new Position(ip, lat, lon);
            } catch (NumberFormatException | NullPointerException ignored) {
                // 旧客户端在定位失败时发送空串或一对零。
            }
            return new Position(ip, null, null);
        }
    }

    public static SeatRestrictions from(Map<String, Object> rules) {
        return new SeatRestrictions(option(rules.get("ipXz")) == 1, option(rules.get("juLi")));
    }

    private static int option(Object value) {
        if (value instanceof Map<?,?> choice) value = choice.get("optionValue");
        if (value == null || "".equals(value)) return 0;
        int parsed = Integer.parseInt(value.toString());
        if (parsed < 0) throw new IllegalArgumentException("入桌限制不能为负数");
        return parsed;
    }

    public boolean enabled() { return sameIp || metres > 0; }

    /** 大厅错误码 8 表示距离，9 表示 IP。缺少开启该规则所需的资料时也拒绝新座位。 */
    public int refusal(Position candidate, Collection<Position> occupied) {
        if (sameIp && (candidate == null || candidate.ip == null || candidate.ip.isBlank())) return 9;
        if (metres > 0 && (candidate == null || candidate.latitude == null || candidate.longitude == null)) return 8;
        for (var other : occupied) {
            if (sameIp && (other == null || other.ip == null || candidate.ip.equals(other.ip))) return 9;
            if (metres > 0 && (other == null || other.latitude == null || other.longitude == null
                    || distance(candidate, other) < metres)) return 8;
        }
        return 0;
    }

    private static double distance(Position a, Position b) {
        double lat = Math.sin(Math.toRadians(a.latitude - b.latitude) / 2);
        double lon = Math.sin(Math.toRadians(a.longitude - b.longitude) / 2);
        double h = lat * lat + Math.cos(Math.toRadians(a.latitude)) * Math.cos(Math.toRadians(b.latitude)) * lon * lon;
        return 12_742_000 * Math.asin(Math.sqrt(Math.min(1, h)));
    }
}
