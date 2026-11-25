import com.j.joker.game.tables.domain.*;
import com.j.joker.game.mahjong.domain.HongzhongRound;
import java.util.*;

/** 确定牌序重放、暗杠隐私、碰牌后禁自摸，以及四红中和流局的边界。 */
public class FriendRulesCheck {
    static void check(boolean ok,String message) { if (!ok) throw new AssertionError(message); }
    static void reject(Runnable action) {
        try { action.run(); } catch (IllegalArgumentException | IllegalStateException expected) { return; }
        throw new AssertionError("accepted illegal move");
    }
    static void move(FriendRound round,String action,Integer... cards) {
        round.apply(new FriendRound.Move(round.currentSeat(),action,List.of(cards)));
    }
    static List<Integer> mahjongDeck(Map<Integer,Integer> fixed) {
        var bag=new ArrayList<>(FriendRules.HONGZHONG.deck(new Random(17)));
        var deck=new ArrayList<>(Collections.nCopies(112,0));
        for(var e:fixed.entrySet()) {
            if (!bag.remove(e.getValue())) throw new AssertionError("bad fixture");
            deck.set(e.getKey(),e.getValue());
        }
        for(int i=0;i<deck.size();i++) if(deck.get(i)==0) deck.set(i,bag.removeLast());
        return deck;
    }
    static void mahjongEdges() {
        var opening=new HongzhongRound(mahjongDeck(Map.of(1,65,5,65,9,65,13,65)));
        check(opening.currentSeat()==1 && opening.actions(1).contains("win"),"opening four wildcards");
        move(opening,"win");
        check(opening.phase().equals("FINISHED") && opening.points().get(1)>0,"four-red win");

        var kong=new HongzhongRound(mahjongDeck(Map.of(0,6,4,6,8,6,12,6)));
        move(kong,"kong",6);
        List<?> outside=(List<?>)kong.board(1).get("melds"), inside=(List<?>)kong.board(0).get("melds");
        var hidden=(Map<?,?>)((List<?>)outside.getFirst()).getFirst();
        var known=(Map<?,?>)((List<?>)inside.getFirst()).getFirst();
        check(hidden.get("tile").equals(0) && known.get("tile").equals(6),"concealed kong privacy");
        check(kong.hand(0).size()==11 && kong.points().equals(List.of(6,-2,-2,-2)),"kong draws and scores");

        var pong=new HongzhongRound(mahjongDeck(Map.of(0,9,1,9,5,9,87,9)));
        move(pong,"discard",9);
        while (pong.phase().equals("CLAIM")) {
            if (pong.currentSeat()==1) move(pong,"pong"); else move(pong,"skip");
        }
        check(pong.currentSeat()==1 && pong.actions(1).equals(List.of("discard")),"pong grants discard only");
        reject(() -> move(pong,"win"));

        // 两个玩家都听五万，另一个玩家即使能碰，也不能抢走胡牌。
        var fixed=new HashMap<Integer,Integer>();
        List<Integer> ready=List.of(1,2,3,0x11,0x12,0x13,0x21,0x22,0x23,7,8,9,5);
        for(int i=0; i<ready.size(); i++) {fixed.put(4*i+1,ready.get(i));fixed.put(4*i+2,ready.get(i));}
        fixed.put(0,5);
        var simultaneous=new HongzhongRound(mahjongDeck(fixed));
        move(simultaneous,"discard",5);
        while (simultaneous.phase().equals("CLAIM")) {
            if (simultaneous.currentSeat()==1 || simultaneous.currentSeat()==2) move(simultaneous,"win");
            else move(simultaneous,"skip");
        }
        check(simultaneous.board(0).get("winners").equals(List.of(1,2)),"two winners on the same discard");
        check(simultaneous.points().get(0)<0 && simultaneous.points().get(3)==0,"discarder pays both winners");
    }

    static void missedDiscardWin() {
        var fixed=new HashMap<Integer,Integer>();
        List<Integer> waiting=List.of(2,3,0x11,0x12,0x13,0x21,0x22,0x23,7,8,9,0x19,0x19);
        for(int i=0;i<waiting.size();i++) fixed.put(4*i+1,waiting.get(i));
        fixed.put(0,1); fixed.put(2,1); fixed.put(6,1); fixed.put(10,4);
        var round=new HongzhongRound(mahjongDeck(fixed));
        move(round,"discard",1);
        check(round.actions(1).contains("win"),"first discard wins");
        while(round.phase().equals("CLAIM")) move(round,round.currentSeat()==2 ? "pong" : "skip");
        check(round.currentSeat()==2,"pong interrupted the normal draw");
        move(round,"discard",4);
        while(round.phase().equals("CLAIM")) {
            check(!round.actions(1).contains("win"),"missed discard win remained available before a draw");
            move(round,"skip");
        }
    }
    static void forcedFollow() {
        var deck=new ArrayList<>(FriendRules.RUN_FAST.deck(new Random(81)));
        for(int[] fixed:new int[][]{{0,0x33},{1,0x34},{2,0x35}}) {
            Collections.swap(deck,fixed[0],deck.indexOf(fixed[1]));
        }
        var round=FriendRules.RUN_FAST.start(deck);
        check(round.currentSeat()==0,"spade three gets the lead");
        reject(()->move(round,"pass"));
        reject(()->move(round,"play",0x34));
        reject(()->move(round,"play",0x33,0x33));
        move(round,"play",0x33);
        reject(()->move(round,"pass"));
        var reply=round.automatic(1);
        check(reply.action().equals("play"),"legal response should be required");
        round.apply(reply);
    }

    public static void main(String[] args) {
        mahjongEdges();
        missedDiscardWin();
        forcedFollow();
        var plain = new com.j.joker.game.mahjong.domain.HongzhongOptions(false,999);
        var noWild = FriendRules.HONGZHONG.deck(new Random(108),plain);
        check(noWild.size()==108 && !noWild.contains(65),"108-tile deck");
        check(plain.hits(List.of(0x18))==8 && new com.j.joker.game.mahjong.domain.HongzhongOptions(true,999).hits(List.of(65))==9,"all-hit bird");
        var plainRound = FriendRules.HONGZHONG.start(noWild,2,plain);
        check(plainRound.hand(2).size()==14,"next-round Mahjong dealer");
        while (!plainRound.phase().equals("FINISHED")) plainRound.apply(plainRound.automatic(plainRound.currentSeat()));
        check(plainRound.points().stream().mapToInt(Integer::intValue).sum()==0,"plain Mahjong table");
        for (var rules:FriendRules.values()) {
            for(int seed=0; seed<30; seed++) {
                var deck=rules.deck(new Random(seed));
                var round=rules.start(deck); var replay=rules.start(deck);
                int steps=0;
                while (!round.phase().equals("FINISHED")) {
                    check(++steps<230,"round never finished");
                    var auto=round.automatic(round.currentSeat());
                    round.apply(auto); replay.apply(auto);
                    check(round.phase().equals(replay.phase()) && round.currentSeat()==replay.currentSeat(),"replay phase");
                }
                check(round.points().equals(replay.points()) && round.points().stream().mapToInt(i->i).sum()==0,"unbalanced settlement");
            }
        }
        System.out.println("Verified "+(FriendRules.values().length*30)+" shuffled friend tables and fixed Mahjong claims, scoring and privacy.");
    }
}
