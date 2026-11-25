package com.j.joker.game.niuniu.application.history;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Map;
import java.util.TreeMap;

/** 按已入账的局汇总整桌得分。离座、换座和房间重启不改变参与者名单。 */
public final class RoomBillboard {
    private record Standing(RoundRecord.Seat profile, long score) {}
    private final Map<Integer, Standing> players = new TreeMap<>();
    private int rounds;

    public void add(RoundRecord round) {
        if (round.index() != rounds + 1) throw new IllegalStateException("累计战绩缺少连续局号");
        for (var seat : round.userinfos()) {
            var previous = players.get(seat.uid());
            long total = seat.score() + (previous == null ? 0L : previous.score());
            players.put(seat.uid(), new Standing(seat, total));
        }
        rounds = round.index();
    }

    public void deduct(int uid, long amount) {
        var p = players.get(uid);
        if (p == null || amount < 0) throw new IllegalArgumentException("整桌费用与参与者不符");
        players.put(uid,new Standing(p.profile(),p.score() - amount));
    }

    public Map<String,Object> packet(int expectedRounds) {
        if (rounds != expectedRounds || players.size() > Byte.MAX_VALUE) return null;
        // 原生大厅转发的是 8192 字节包。换桌人数多时优先保留每人的身份和净分。
        int required = 18 + 1 + 4;
        int portraits = 0;
        for (var standing : players.values()) {
            var p = standing.profile();
            required += 19 + p.nickName().getBytes(StandardCharsets.UTF_8).length;
            portraits += p.photo_url().getBytes(StandardCharsets.UTF_8).length;
            if (standing.score() < Integer.MIN_VALUE || standing.score() > Integer.MAX_VALUE) return null;
        }
        if (required > 8192) return null;
        boolean includePortraits = required + portraits <= 8192;
        var list = new ArrayList<Map<String,Object>>(players.size());
        for (var standing : players.values()) {
            var p = standing.profile();
            list.add(Map.of("uid", p.uid(), "sex", p.sex(), "nickName", p.nickName(),
                    "portrait", includePortraits ? p.photo_url() : "", "chips", (int)standing.score()));
        }
        return Map.of("playercount", list.size(), "playerlist", list, "game_amount", rounds);
    }
}
