package com.j.joker.game.runfast.application;

import com.j.joker.game.replay.ReplayFile;
import com.j.joker.game.runfast.domain.RunFastScore;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import static com.j.joker.game.replay.ReplayFile.number;

/** 从跑得快已广播的出牌、过牌和结算复算三人基础房的输赢。 */
public final class VerifyRunFast {
    private VerifyRunFast() {}

    private static List<Integer> cards(Map<?,?> packet, String size) {
        int count = number(packet.get(size));
        Object raw = packet.get("Cardbuf");
        if (count == 0 && (raw == null || raw instanceof Map<?,?> map && map.isEmpty())) return List.of();
        var cards = ReplayFile.integers(raw);
        if (cards.size() != count) throw new IllegalArgumentException("Cardbuf 张数不符");
        return cards;
    }

    private static void collect(Set<Integer> deck, List<Integer> cards) {
        for (int code : cards) {
            int pip = code & 15;
            if (code < 1 || code > 0x3d || pip < 1 || pip > 13 || !deck.add(code))
                throw new IllegalArgumentException("牌堆中有重复牌或无效牌");
        }
    }

    public static void verify(Map<String,Object> record) {
        if (!(record.get("result") instanceof Map<?,?> result) || number(result.get("playercount")) != 3
                || !(result.get("playerList") instanceof List<?> players) || players.size() != 3)
            throw new IllegalArgumentException("需要三人的 0x6008 结算");
        var remaining = new HashMap<Integer,Integer>();
        var reported = new HashMap<Integer,Long>();
        var deck = new HashSet<Integer>();
        for (Object obj : players) {
            if (!(obj instanceof Map<?,?> row)) throw new IllegalArgumentException("玩家结算格式有误");
            int uid = number(row.get("Uid"));
            var left = cards(row,"Cardcount");
            collect(deck, left);
            if (remaining.put(uid,left.size()) != null) throw new IllegalArgumentException("玩家重复");
            reported.put(uid,(long)number(row.get("Turningscore")));
        }
        if (!(record.get("events") instanceof List<?> events)) throw new IllegalArgumentException("缺少出牌与过牌记录");
        var played = new HashMap<Integer,Integer>();
        var bombs = new HashMap<Integer,Integer>();
        var passes = new HashSet<Integer>();
        int leader = 0, lastBomb = 0, finished = 0;
        for (Object obj : events) {
            if (finished != 0 || !(obj instanceof Map<?,?> event)) throw new IllegalArgumentException("操作顺序有误");
            int cmd = number(event.get("cmd"));
            if (cmd == 0x6006) {
                int uid = number(event.get("nPassUserId"));
                if (leader == 0 || uid == leader || !remaining.containsKey(uid) || !passes.add(uid))
                    throw new IllegalArgumentException("过牌记录有误");
                if (passes.size() == 2 && lastBomb > 0) bombs.merge(leader,1,Integer::sum);
                continue;
            }
            if (cmd != 0x6005) throw new IllegalArgumentException("需要 0x6005 出牌或 0x6006 过牌");
            int uid = number(event.get("nPreOutUserId"));
            boolean newTrick = leader == 0 || passes.size() == 2;
            if (!remaining.containsKey(uid) || leader != 0 && (uid == leader) != newTrick)
                throw new IllegalArgumentException("出牌人和上一轮领牌结果不符");
            var out = cards(event,"Putcount");
            if (out.isEmpty()) throw new IllegalArgumentException("出牌记录为空");
            collect(deck, out);
            int rank = out.getFirst() & 15;
            boolean bomb = out.size() == 4 && out.stream().allMatch(code -> (code & 15) == rank);
            if (bomb != (number(event.get("Cardtype")) == 12)) throw new IllegalArgumentException("炸弹标记与牌面不符");
            int bombRank = bomb ? (rank <= 2 ? rank + 13 : rank) : 0;
            if (!newTrick && lastBomb != 0 && bombRank <= lastBomb) throw new IllegalArgumentException("炸弹未被更大炸弹盖过");
            leader = uid;
            lastBomb = bombRank;
            passes.clear();
            int left = 16 - played.merge(uid,out.size(),Integer::sum);
            if (left < 0 || left != number(event.get("Cardcount"))) throw new IllegalArgumentException("出牌后剩牌数不符");
            if (left == 0) {
                finished = uid;
                if (bomb) bombs.merge(uid,1,Integer::sum);
            }
        }
        if (finished == 0 || deck.size() != 48 || deck.stream().filter(code -> (code & 15) == 1).count() != 3
                || deck.stream().filter(code -> (code & 15) == 2).count() != 1)
            throw new IllegalArgumentException("需要完整的三人十六张牌局");
        var seats = new ArrayList<RunFastScore.Seat>();
        remaining.forEach((uid,left) -> {
            if (left + played.getOrDefault(uid,0) != 16) throw new IllegalArgumentException("期末手牌与出牌记录不符");
            seats.add(new RunFastScore.Seat(uid,left,bombs.getOrDefault(uid,0)));
        });
        var score = RunFastScore.settle(seats, number(record.get("pointUnit")));
        if (!score.equals(reported)) throw new IllegalArgumentException("三家净分与结算不同，计算得到 " + score);
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 1) throw new IllegalArgumentException("需要三人十六张基础房逐局 JSONL 文件");
        int count = ReplayFile.verify(Path.of(args[0]), VerifyRunFast::verify);
        System.out.println("通过跑得快积分核对，共 " + count + " 局");
    }
}
