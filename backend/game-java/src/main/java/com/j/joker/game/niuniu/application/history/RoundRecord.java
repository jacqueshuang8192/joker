package com.j.joker.game.niuniu.application.history;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.j.joker.game.niuniu.domain.card.Card;
import com.j.joker.game.niuniu.domain.table.NiuNiuTable;
import com.j.joker.game.niuniu.domain.table.Settlement;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** 已结算的一局。大厅读取 userinfos，房间协议使用同一份明细生成 0x1050。 */
public record RoundRecord(int activity, int level, int club, int index, List<Seat> userinfos, com.j.joker.game.niuniu.domain.table.SideBets.Posting side,
                          com.j.joker.game.niuniu.domain.rules.ClubFee.Plan fees) {
    private static final ObjectMapper JSON = new ObjectMapper();
    public record Seat(int uid, String nickName, String photo_url, int isZhuang, int cardType,
                       int grab, int xiazhu, int score, List<Integer> cards, int sex) {
        Map<String, Object> wire() {
            Map<String,Object> fields = new LinkedHashMap<>();
            fields.put("uid", uid);
            fields.put("smallPhoto", photo_url);
            fields.put("nickName", nickName);
            fields.put("isZhuang", isZhuang);
            fields.put("card_mount", cards.size());
            fields.put("cards", cards);
            fields.put("cardType", cardType);
            fields.put("grab", grab);
            fields.put("xiazhu", xiazhu);
            fields.put("changeChip", score);
            return fields;
        }
    }

    public static RoundRecord capture(int activity, int level, int club, NiuNiuTable table, Settlement.Result result) {
        var seats = result.entries().stream().map(e -> {
            var player = table.byUid(e.uid());
            return new Seat(Math.toIntExact(e.uid()), display(player.nickName(), 32), player.portrait().getBytes(java.nio.charset.StandardCharsets.UTF_8).length <= 512 ? player.portrait() : "",
                    e.banker() ? 1 : 0, player.hand().type().id(), player.grabTimes(), player.betTimes(),
                    Math.toIntExact(e.delta()), player.cards().stream().map(Card::code).toList(), player.sex());
        }).toList();
        return new RoundRecord(activity, level, club, result.roundNo(), seats, result.side(), result.fees());
    }

    // 十人桌的回看仍须装进客户端单帧，截取时保留完整 Unicode 字符。
    private static String display(String value, int max) {
        return value.substring(0, value.offsetByCodePoints(0, Math.min(max, value.codePointCount(0, value.length()))));
    }

    public String json() {
        try { return JSON.writeValueAsString(this); }
        catch (JsonProcessingException e) { throw new IllegalStateException("牌局明细无法编码", e); }
    }

    public static RoundRecord parse(String json) {
        try { return JSON.readValue(json, RoundRecord.class); }
        catch (JsonProcessingException e) { throw new IllegalArgumentException("牌局明细无效", e); }
    }

    public static Map<String, Object> reply(int latest, RoundRecord round) {
        var seats = round == null ? List.of() : round.userinfos.stream().map(Seat::wire).toList();
        return Map.of("resultIndex", round == null ? 0 : round.index, "resultCount", latest,
                "gameResultCount", seats.size(), "gameResult", seats);
    }
}
