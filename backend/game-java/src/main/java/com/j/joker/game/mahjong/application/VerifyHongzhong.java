package com.j.joker.game.mahjong.application;

import com.j.joker.game.mahjong.domain.HongzhongHand;
import com.j.joker.game.replay.ReplayFile;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import static com.j.joker.game.replay.ReplayFile.number;

/** 核对 308 客户端的 0x6008 单局结算中的胡牌牌面。 */
public final class VerifyHongzhong {
    private VerifyHongzhong() {}

    private static List<Integer> tiles(Map<?,?> player, String name, String size) {
        int count = number(player.get(size));
        Object value = player.get(name);
        // 部分 Lua 编码器会把空表输出为 {}，还有些版本省略空数组。
        if (count == 0 && (value == null || value instanceof Map<?,?> map && map.isEmpty())) return List.of();
        var cards = ReplayFile.integers(value);
        if (count != cards.size()) throw new IllegalArgumentException(name + " 张数不符");
        return cards;
    }

    private static Map<?,?> only(Object list) {
        if (list instanceof List<?> rows && rows.size() == 1 && rows.getFirst() instanceof Map<?,?> row) return row;
        throw new IllegalArgumentException("胡牌记录缺少唯一的结果");
    }

    public static void verify(Map<String,Object> packet, boolean useRed, boolean opening) {
        int result = number(packet.get("nRoundResult"));
        if (result != 1 && result != 2) throw new IllegalArgumentException("需要一局自摸或点炮的结算");
        if (!(packet.get("players") instanceof List<?> players) || players.size() != number(packet.get("userCount"))
                || players.size() < 2 || players.size() > 4) throw new IllegalArgumentException("参局人数不符");
        int winners = 0;
        for (Object item : players) {
            if (!(item instanceof Map<?,?> player)) throw new IllegalArgumentException("玩家记录无效");
            int flag = number(player.get("ifhu"));
            if (flag == 0) continue;
            if (flag != 1) throw new IllegalArgumentException("胡牌标识无效");
            var content = only(player.get("hucontent"));
            int type = number(content.get("hutype"));
            if (type != (result == 1 ? 2 : 1)) throw new IllegalArgumentException("自摸或点炮的标记不符");
            int finalTile = number(only(content.get(type == 2 ? "zimo" : "pinghu")).get("huCard"));
            var concealed = tiles(player, "remainCards", "remainCardsCount");
            var melds = new ArrayList<HongzhongHand.Meld>();
            for (int tile : tiles(player, "pCards", "pCount")) melds.add(new HongzhongHand.Meld(tile, 3));
            for (int tile : tiles(player, "gCards", "gCount")) melds.add(new HongzhongHand.Meld(tile, 4));
            for (int tile : tiles(player, "agCards", "agCount")) melds.add(new HongzhongHand.Meld(tile, 4));
            if (!concealed.contains(finalTile) || !HongzhongHand.wins(concealed, melds, useRed, opening))
                throw new IllegalArgumentException("玩家 " + player.get("uid") + " 的手牌与胡牌结果不符");
            winners++;
        }
        if (winners == 0 || result == 1 && winners != 1 || winners == players.size())
            throw new IllegalArgumentException("胡牌人数与局结果不符");
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2 || !List.of("plain", "red", "opening-red").contains(args[0]))
            throw new IllegalArgumentException("用法: VerifyHongzhong plain|red|opening-red 牌谱.jsonl");
        int count = ReplayFile.verify(Path.of(args[1]), packet -> verify(packet, !args[0].equals("plain"),
                args[0].equals("opening-red")));
        System.out.println("通过红中麻将胡牌核对，共 " + count + " 局");
    }
}
