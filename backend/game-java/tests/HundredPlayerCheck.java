import com.j.joker.game.hundred.domain.HundredPlayerCards;
import com.j.joker.game.hundred.domain.HundredPlayerCards.DragonTiger;
import com.j.joker.game.hundred.domain.HundredSettlement;
import com.j.joker.game.hundred.domain.HundredSettlement.Banker;
import com.j.joker.game.hundred.domain.HundredSettlement.Bet;
import com.j.joker.game.hundred.application.VerifyRound;
import java.util.List;
import java.util.Map;

public class HundredPlayerCheck {
    static void check(boolean valid) {
        if (!valid) throw new AssertionError("百人场牌例不符");
    }

    public static void main(String[] args) {
        int[] outcomes = new int[3];
        for (int a = 0; a < 52; a++) {
            for (int b = 0; b < 52; b++) {
                if (a == b) continue;
                int dragon = (a / 13) * 16 + a % 13 + 1;
                int tiger = (b / 13) * 16 + b % 13 + 1;
                var winner = HundredPlayerCards.dragonTiger(dragon, tiger);
                outcomes[winner.ordinal()]++;
            }
        }
        check(java.util.Arrays.equals(outcomes, new int[]{1248,1248,156}));
        check(HundredPlayerCards.dragonTiger(0x31,0x02) == DragonTiger.TIGER);
        check(DragonTiger.TIE.net(8,5,2) == 12 && DragonTiger.DRAGON.net(8,5,2) == 1
                && DragonTiger.TIGER.net(8,5,2) == -5);
        var beasts = HundredPlayerCards.beasts(0x19,0x09,0x29,0x31,0x0d);
        check(beasts.stream().map(HundredPlayerCards.BeastResult::playerWins).toList().equals(List.of(false,true,false,true)));
        check(beasts.stream().map(HundredPlayerCards.BeastResult::winningRank).toList().equals(List.of(9,9,9,13)));
        var tie = java.util.Map.<String,Object>of("longCard", 1, "huCard",17,"openRes",3);
        check(com.j.joker.game.hundred.application.VerifyRound.matches(101,tie));
        check(!com.j.joker.game.hundred.application.VerifyRound.matches(101,java.util.Map.of("longCard",1,"huCard",17,"openRes",1)));
        check(com.j.joker.game.hundred.application.VerifyRound.matches(102,java.util.Map.of("bankerCard",0x19,
                "longCard",0x09,"huCard",0x29,"queCard",0x31,"guiCard",0x0d,
                "openLongRes",0,"openHuRes",1,"openQueRes",0,"openGuiRes",1)));
        for (int invalid : new int[]{0x01,0x10,0x4e,-1}) {
            try {
                HundredPlayerCards.dragonTiger(0x01, invalid);
                throw new AssertionError("接受重复牌或无效牌");
            } catch (IllegalArgumentException expected) {}
        }
        var bankers = List.of(new Banker(4, 30), new Banker(5, 10));
        var bets = List.of(new Bet(6, 1, 8), new Bet(6, 3, 1), new Bet(7, 2, 5), new Bet(6, 3, 1));
        check(HundredSettlement.dragonTiger(bankers, bets, 1, 17).equals(Map.of(4,-9L,5,-3L,6,12L,7,0L)));
        check(HundredSettlement.dragonTiger(bankers, bets, 11, 2).equals(Map.of(4,-1L,5,0L,6,6L,7,-5L)));
        var small = List.of(new Banker(1, 5), new Banker(2, 5), new Banker(3, 5));
        check(HundredSettlement.dragonTiger(small, List.of(new Bet(6,2,2)), 3,2)
                .equals(Map.of(1,1L,2,1L,3,0L,6,-2L)));
        check(HundredSettlement.beasts(bankers,List.of(new Bet(6,1,3),new Bet(6,2,1),new Bet(7,4,2)),
                0x19,0x09,0x29,0x31,0x0d).equals(Map.of(4,-6L,5,-2L,6,-18L,7,26L)));
        try {
            HundredSettlement.dragonTiger(small, List.of(new Bet(6,3,3)), 1,17);
            throw new AssertionError("接受超出庄家出资的结算");
        } catch (IllegalArgumentException expected) { }
        var receipts = List.of(Map.of("uid",4,"turnBlc",-900), Map.of("uid",5,"turnBlc",-300), Map.of("uid",6,"turnBlc",1200));
        var snapshot = new java.util.HashMap<String,Object>();
        snapshot.put("result", Map.of("longCard",1,"huCard",17,"openRes",3,"playerCount",3,"playerList",receipts));
        snapshot.put("bankerList", List.of(Map.of("uid",4,"chips",3000), Map.of("uid",5,"chips",1000)));
        snapshot.put("bets", List.of(Map.of("uid",6,"betType",3,"betScore",2)));
        check(VerifyRound.matchesAccounts(101, snapshot));
        snapshot.put("bets", List.of(Map.of("uid",6,"betType",3,"betScore",1)));
        check(!VerifyRound.matchesAccounts(101, snapshot));
        System.out.println("Verified 2652 dragon/tiger deals, beast payouts, pooled banker shares and round receipts.");
    }
}
