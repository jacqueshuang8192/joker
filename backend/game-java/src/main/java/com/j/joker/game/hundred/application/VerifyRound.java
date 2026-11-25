package com.j.joker.game.hundred.application;

import com.j.joker.game.hundred.domain.HundredPlayerCards;
import com.j.joker.game.hundred.domain.HundredSettlement;
import com.j.joker.game.hundred.domain.HundredOrders;
import com.j.joker.game.hundred.domain.Baccarat;
import com.j.joker.game.replay.ReplayFile;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

/** 用脱敏的 0x6008 结算消息核对规则。输入为每行一条解码后的 JSON 消息。 */
public final class VerifyRound {
    private VerifyRound() {}

    private static int field(Map<?,?> packet, String key) {
        if (!(packet.get(key) instanceof Number n)) throw new IllegalArgumentException("缺少数值字段 " + key);
        return ReplayFile.number(n);
    }

    // 9103 的复算输入来自结算后导出的牌序与公开结果。
    private static List<Integer> cards(int level,Map<?,?> result) {
        if(level==Baccarat.LEVEL) return ReplayFile.integers(result.get("deal"));
        int dragon=field(result,"longCard"), tiger=field(result,"huCard");
        return level==101 ? List.of(dragon,tiger) : List.of(field(result,"bankerCard"),dragon,tiger,
                field(result,"queCard"),field(result,"guiCard"));
    }
    public static boolean matches(int level, Map<?,?> packet) {
        if(level==Baccarat.LEVEL) {
            var deal=Baccarat.open(cards(level,packet));
            return deal.house().equals(ReplayFile.integers(packet.get("bankerCards")))
                    && deal.player().equals(ReplayFile.integers(packet.get("playerCards")))
                    && deal.housePoints()==field(packet,"bankerPoints") && deal.playerPoints()==field(packet,"playerPoints")
                    && Boolean.valueOf(deal.housePair()).equals(packet.get("bankerPair"))
                    && Boolean.valueOf(deal.playerPair()).equals(packet.get("playerPair"));
        }
        int dragon = field(packet, "longCard"), tiger = field(packet, "huCard");
        if (level == 101) {
            int outcome = switch (HundredPlayerCards.dragonTiger(dragon,tiger)) {
                case DRAGON -> 1;
                case TIGER -> 2;
                case TIE -> 3;
            };
            return outcome == field(packet, "openRes");
        }
        if (level != 102) throw new IllegalArgumentException("支持场次 101、102 和 9103");
        var result = HundredPlayerCards.beasts(field(packet,"bankerCard"), dragon, tiger,
                field(packet,"queCard"), field(packet,"guiCard"));
        var names = List.of("openLongRes","openHuRes","openQueRes","openGuiRes");
        for (int i = 0; i < result.size(); i++) {
            if (result.get(i).playerWins() != (field(packet,names.get(i)) == 1)) return false;
        }
        return true;
    }

    private static List<Map<?,?>> rows(Map<?,?> packet, String key) {
        if (!(packet.get(key) instanceof List<?> list)) throw new IllegalArgumentException("缺少列表 " + key);
        return list.stream().<Map<?,?>>map(item -> {
            if (item instanceof Map<?,?> row) return row;
            throw new IllegalArgumentException("列表元素无效 " + key);
        }).toList();
    }

    public static boolean matchesAccounts(int level, Map<String,Object> record) {
        return matchesAccounts(level,record,false);
    }

    public static boolean matchesAccounts(int level, Map<String,Object> record, boolean verifyOrders) {
        if (!(record.get("result") instanceof Map<?,?> result) || !matches(level, result)) return false;
        var bankers = rows(record, "bankerList").stream().map(row ->
                new HundredSettlement.Banker(field(row,"uid"), field(row,"chips"))).toList();
        var dealt=cards(level,result);
        var betRows = rows(record,"bets");
        var bets = betRows.stream().map(row -> new HundredSettlement.Bet(field(row,"uid"),field(row,"betType"),
                Math.multiplyExact(100,field(row,"betScore")))).toList();
        Map<Integer,Long> deltas;
        if (verifyOrders) {
            var wallets = new java.util.HashMap<Integer,Integer>();
            for (var row : rows(record,"openingChips"))
                if (wallets.put(field(row,"uid"),field(row,"chips"))!=null) throw new IllegalArgumentException("期初余额重复");
            var book = new HundredOrders(level,bankers,wallets,ReplayFile.integers(record.get("areaLimits")));
            for (int i=0; i<bets.size(); i++) {
                Object key = betRows.get(i).get("requestId");
                if (!(key instanceof String request)) throw new IllegalArgumentException("核验重试需要订单编号");
                book.accept(request,bets.get(i));
            }
            deltas = book.close(dealt);
        } else {
            deltas = HundredSettlement.settle(level,bankers,bets,dealt);
        }
        var players = rows(result, "playerList");
        if (players.size() != field(result, "playerCount")) return false;
        var reported = new HashSet<Integer>();
        for (var player : players) {
            int uid = field(player, "uid");
            if (!reported.add(uid) || deltas.getOrDefault(uid, 0L) != field(player, "turnBlc")) return false;
        }
        return reported.containsAll(deltas.keySet());
    }

    public static void main(String[] args) throws Exception {
        if (args.length < 2 || args.length > 3 || args.length == 3 && !List.of("--accounts","--orders").contains(args[2]))
            throw new IllegalArgumentException("用法: VerifyRound 场次 文件.jsonl [--accounts|--orders]");
        int level = Integer.parseInt(args[0]);
        int count = ReplayFile.verify(Path.of(args[1]), packet -> {
            boolean valid = args.length == 3 ? matchesAccounts(level, packet,args[2].equals("--orders")) : matches(level, packet);
            if (!valid) throw new IllegalArgumentException("牌局与记录不符");
        });
        System.out.println("核对通过，共 " + count + " 局");
    }
}
