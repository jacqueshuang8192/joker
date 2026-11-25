import com.j.joker.game.mahjong.application.VerifyHongzhong;
import com.j.joker.game.mahjong.domain.HongzhongHand;
import com.j.joker.game.mahjong.domain.HongzhongHand.Meld;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import static com.j.joker.game.mahjong.domain.HongzhongHand.RED;

public class HongzhongCheck {
    static void check(boolean value) { if (!value) throw new AssertionError("红中麻将胡牌不符"); }
    static boolean wins(Integer... tiles) { return HongzhongHand.wins(List.of(tiles), List.of(), false, false); }
    static void reject(Runnable action) {
        try { action.run(); }
        catch (IllegalArgumentException expected) { return; }
        throw new AssertionError("接受了无效胡牌");
    }

    public static void main(String[] args) {
        // 六副牌来自大厅规则说明里的胡牌示例，三门花色在该玩法中对称。
        check(wins(1,1, 17,18,19, 33,34,35, 36,37,38, 38,39,40));
        check(wins(1,1, 1,2,3, 17,18,19, 36,37,38, 39,39,39));
        check(wins(1,1, 1,2,3, 17,18,19, 39,39,39, 41,41,41));
        check(wins(1,1, 1,2,3, 5,5,5, 39,39,39, 41,41,41));
        check(wins(1,1, 3,3,3, 5,5,5, 39,39,39, 41,41,41));
        check(wins(1,1, 33,33, 17,17, 5,5, 39,39, 20,20, 41,41));
        var melds = List.of(new Meld(0x11, 3), new Meld(0x12, 4), new Meld(0x13, 4));
        check(HongzhongHand.wins(List.of(1,1,8,9,RED), melds, true, false));
        check(!HongzhongHand.wins(List.of(1,1,9,0x21,RED), melds, true, false));
        var opening = List.of(RED,RED,RED,RED, 1,2,3,4,5,6,7,8,9);
        check(HongzhongHand.wins(opening, List.of(), true, true));
        check(!HongzhongHand.wins(opening, List.of(), true, false));
        reject(() -> HongzhongHand.wins(List.of(RED,RED), List.of(), false, false));
        reject(() -> new Meld(RED, 3));
        reject(() -> HongzhongHand.wins(List.of(0x12,0x12,1,2,3), melds, true, false));
        reject(() -> wins(0x31, 0x31));

        var wall = new ArrayList<Integer>();
        for (int suit = 0; suit < 3; suit++)
            for (int pip = 1; pip <= 9; pip++) wall.addAll(Collections.nCopies(4, 16 * suit + pip));
        var random = new Random(308);
        for (int trial = 0; trial < 200; trial++) {
            Collections.shuffle(wall, random);
            var tiles = new ArrayList<>(wall.subList(0, 13));
            var options = wall.stream().distinct().toList();
            // 通过逐张替代来独立核对一个红中的所有可行组合。
            boolean possible = false;
            for (int replacement : options) {
                if (Collections.frequency(tiles, replacement) >= 4) continue;
                tiles.add(replacement);
                possible |= HongzhongHand.wins(tiles, List.of(), false, false);
                tiles.removeLast();
            }
            tiles.add(RED);
            boolean actual = HongzhongHand.wins(tiles, List.of(), true, false);
            // 万能牌允许代表第五张同点牌，只有四张实牌齐集时替代穷举的范围更小。
            if (tiles.stream().noneMatch(c -> Collections.frequency(tiles, c) == 4)) check(possible == actual);
            else if (possible) check(actual);
        }
        var winner = new HashMap<String,Object>();
        winner.putAll(Map.of("uid", 1, "ifhu", 1, "pCount", 1, "pCards", List.of(17),
                "agCount", 1, "agCards", List.of(18), "gCount", 1, "gCards", List.of(19)));
        winner.put("hucontent", List.of(Map.of("hutype", 2, "zimo", List.of(Map.of("huCard", 9)))));
        winner.put("remainCards", List.of(1,1,8,9,RED));
        winner.put("remainCardsCount", 5);
        var end = Map.<String,Object>of("nRoundResult",1,"userCount",2,"players",List.of(winner,Map.of("ifhu",0)));
        VerifyHongzhong.verify(end, true, false);
        winner.put("remainCards", List.of(1,1,9,0x21,RED));
        reject(() -> VerifyHongzhong.verify(end, true, false));
        System.out.println("Verified six published winning hands, red jokers, kongs and decoded 308 settlement fields.");
    }
}
