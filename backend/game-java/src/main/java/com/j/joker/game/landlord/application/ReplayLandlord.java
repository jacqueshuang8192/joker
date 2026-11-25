package com.j.joker.game.landlord.application;

import com.j.joker.game.landlord.domain.LandlordRound;
import com.j.joker.game.replay.ReplayFile;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import static com.j.joker.game.replay.ReplayFile.integers;
import static com.j.joker.game.replay.ReplayFile.number;

/** 从完整牌序、逐手操作和预期输赢复算房卡斗地主。每行是一局。 */
public final class ReplayLandlord {
    private ReplayLandlord() {}

    public static LandlordRound verify(Map<String, Object> record) {
        var round = new LandlordRound(number(record.get("firstCaller")), integers(record.get("deck")));
        if (!(record.get("actions") instanceof List<?> actions)) throw new IllegalArgumentException("缺少操作");
        for (int i = 0; i < actions.size(); i++) {
            try {
                if (!(actions.get(i) instanceof Map<?,?> move)) throw new IllegalArgumentException("操作格式有误");
                int seat = number(move.get("seat"));
                switch (String.valueOf(move.get("action"))) {
                    case "call" -> round.call(seat, number(move.get("bid")));
                    case "rob" -> {
                        if (!(move.get("take") instanceof Boolean take)) throw new IllegalArgumentException("缺少抢地主选择");
                        round.rob(seat, take);
                    }
                    case "play" -> round.play(seat, integers(move.get("cards")));
                    case "pass" -> round.pass(seat);
                    default -> throw new IllegalArgumentException("未知操作");
                }
            } catch (RuntimeException invalid) {
                throw new IllegalArgumentException("第 " + (i + 1) + " 手无效", invalid);
            }
        }
        if (round.winner() != number(record.get("winner")) || !round.points().equals(integers(record.get("points"))))
            throw new IllegalArgumentException("胜出座位或三家净分与记录不符");
        return round;
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 1) throw new IllegalArgumentException("需要逐局 JSONL 文件路径");
        int count = ReplayFile.verify(Path.of(args[0]), ReplayLandlord::verify);
        System.out.println("通过房卡斗地主复算，共 " + count + " 局");
    }
}
