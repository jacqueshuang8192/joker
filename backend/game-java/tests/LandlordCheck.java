import com.j.joker.game.landlord.domain.LandlordPlay;
import com.j.joker.game.landlord.domain.LandlordRound;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import static com.j.joker.game.landlord.domain.LandlordPlay.Kind.*;

public class LandlordCheck {
    static void check(boolean ok) { if (!ok) throw new AssertionError("斗地主牌例不符"); }
    static LandlordPlay hand(int... physical) {
        return LandlordPlay.of(Arrays.stream(physical).boxed().toList());
    }
    static void reject(Runnable operation) {
        try { operation.run(); }
        catch (IllegalStateException | IllegalArgumentException expected) { return; }
        throw new AssertionError("接受了无效操作");
    }
    public static void main(String[] args) {
        check(hand(1).beats(hand(13)) && hand(2).beats(hand(1)) && hand(0x4f).beats(hand(0x4e)));
        check(hand(0x13, 3).kind() == PAIR && hand(3, 0x13, 0x33).kind() == TRIPLE);
        check(hand(3, 0x13, 0x23, 0x24).kind() == TRIPLE_SINGLE);
        check(hand(3, 0x13, 0x23, 4, 0x14).kind() == TRIPLE_PAIR);
        check(hand(10, 11, 12, 13, 1).kind() == STRAIGHT);
        check(hand(3, 19, 4, 20, 5, 21).kind() == PAIR_RUN);
        check(hand(3, 19, 35, 4, 20, 36).kind() == TRIPLE_RUN);
        check(hand(3, 19, 35, 4, 20, 36, 7, 9).kind() == PLANE_SINGLES);
        check(hand(3, 19, 35, 4, 20, 36, 7, 23, 9, 25).kind() == PLANE_PAIRS);
        check(hand(3, 19, 35, 51, 7, 23).kind() == FOUR_SINGLES);
        check(hand(3, 19, 35, 51, 7, 23, 9, 25).kind() == FOUR_PAIRS);
        var bomb = hand(3, 19, 35, 51);
        check(bomb.kind() == BOMB && bomb.beats(hand(2)) && !bomb.beats(bomb));
        check(hand(0x4f, 0x4e).beats(bomb) && !bomb.beats(hand(0x4e, 0x4f)));
        check(!hand(4, 5, 6, 7, 8, 9).beats(hand(3, 4, 5, 6, 7)));
        reject(() -> hand(11, 12, 13, 1, 2));
        reject(() -> hand(0x51));
        reject(() -> hand(1, 1));
        var random = new Random(324);
        var round = LandlordRound.deal(2, random);
        check(round.publicBottom().isEmpty() && round.landlord() == -1 && round.hand(2).size() == 17);
        reject(() -> round.call(1, 1));
        reject(() -> round.call(2, 2));
        round.call(2, 0); round.call(0, 0); round.call(1, 0);
        check(round.phase() == LandlordRound.Phase.REDEAL);
        var next = round.nextDeal(random);
        check(next.turn() == 2 && !next.hand(2).equals(round.hand(2)));
        next.call(2, 3); next.rob(0, true); next.rob(1, true);
        check(next.turn() == 1 && next.landlord() == 1 && next.multiplier() == 12);
        var fullDeck = new HashSet<Integer>();
        for (int seat = 0; seat < 3; seat++) fullDeck.addAll(next.hand(seat));
        check(fullDeck.size() == 54 && next.hand(1).containsAll(next.publicBottom()));
        reject(() -> next.pass(1));
        reject(() -> next.play(1, List.of(next.hand(0).getFirst())));
        reject(() -> next.play(0, List.of(next.hand(0).getFirst())));
        // 让农民接过领出权，打完全部 17 张，核对另一农民也赢分。
        int low = next.hand(1).stream().filter(c -> c % 16 == 3).findFirst().orElseThrow();
        next.play(1, List.of(low));
        int higher = next.hand(2).stream().filter(c -> hand(c).beats(hand(low))).findFirst().orElseThrow();
        next.play(2, List.of(higher));
        while (next.phase() == LandlordRound.Phase.PLAY) {
            next.pass(0); next.pass(1);
            next.play(2, List.of(next.hand(2).getFirst()));
        }
        check(next.winner() == 2 && next.points().equals(List.of(12, -24, 12)));
        check(next.nextDeal(random).turn() != 1);
        reject(() -> next.pass(0));
        System.out.println("Verified landlord combinations, bidding, redeal, ownership, turn order and farmer team scoring.");
    }
}
