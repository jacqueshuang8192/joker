package com.j.joker.game.rooms.domain;

import com.j.joker.game.niuniu.domain.rules.GameConfig;
import com.j.joker.game.niuniu.domain.table.NiuNiuTable;
import com.j.joker.game.niuniu.util.Json;

/** API 的开房意图。桌号分配之前完成规则校验，避免创建半成品房间。 */
public record RoomDefinition(int level, int activity, int owner, String invite, int club, int rounds,
                             int seats, int base, int minimumChips, int configId, int gameType, String groupName, String rules) {
    public RoomDefinition {
        if (activity <= 0 || owner <= 0 || invite == null || invite.isBlank() || club < 0
                || rounds < 1 || seats < 2 || seats > NiuNiuTable.MAX_SEATS || base < 1 || minimumChips < 0)
            throw new IllegalArgumentException("开房参数无效");
        var settings = Json.parseObject(rules);
        settings.put("round", rounds);
        settings.put("maxSeatCount", seats);
        settings.put("baseChip", base);
        settings.put("master", owner);
        settings.put("minimumChips", minimumChips);
        settings.put("clubConfigId", configId);
        settings.put("clubGameType", gameType);
        settings.put("clubName", groupName);
        if (settings.get("waiwei") instanceof Number value) settings.put("waiwei", value.toString());
        rules = Json.write(new java.util.TreeMap<>(settings));
        var config = GameConfig.fromMap(settings);
        if (!config.hasJQK() && seats * config.handSize() > 40)
            throw new IllegalArgumentException("无 JQK 的房间超过一副牌的张数");
        if ((config.clubFee().enabled() || config.clubFee().hasTableCharges()) && (club <= 0 || configId <= 0))
            throw new IllegalArgumentException("收费桌须绑定所属俱乐部的模板");
    }
}
