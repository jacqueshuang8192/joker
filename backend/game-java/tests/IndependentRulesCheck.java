import com.j.joker.game.hundred.domain.Baccarat;
import com.j.joker.game.hundred.domain.HundredSettlement.Banker;
import com.j.joker.game.hundred.domain.HundredSettlement.Bet;
import com.j.joker.game.tables.domain.*;
import java.util.*;
import static com.j.joker.game.tables.domain.FriendRules.*;

/** 公开的独立规则在指定牌序上的验收，包含不能仅靠零和断言发现的赔率、胡息与可见性错误。 */
public final class IndependentRulesCheck {
    static void check(boolean value,String message) { if (!value) throw new AssertionError(message); }
    static void move(FriendRound r,String action,Integer... cards) {
        r.apply(new FriendRound.Move(r.currentSeat(),action,List.of(cards)));
    }
    static void finish(FriendRound r) {
        for(int i=0;i<450;i++) {
            if(r.phase().equals("FINISHED")) return;
            r.apply(r.automatic(r.currentSeat()));
        }
        throw new AssertionError("没有结束牌局");
    }
    static FriendRound opening(FriendRules rules,List<Integer> firstHand) {
        var deck=new ArrayList<>(rules.deck(new Random(421)));
        var rest=new ArrayList<>(deck);
        for(int tile:firstHand) check(rest.remove((Integer)tile),"测试牌不在牌堆中");
        var fixed=new HashMap<Integer,Integer>();
        for(int i=0;i<firstHand.size();i++) fixed.put(i*rules.seats,firstHand.get(i));
        for(int i=0;i<deck.size();i++) deck.set(i,fixed.containsKey(i)?fixed.get(i):rest.removeLast());
        return rules.start(deck);
    }
    static void regionalScores() {
        var words=List.of(CHANGDE,LOUDI,HANSHOU,SHAOYANG,BAYI,SANPI,PENGPENG,GUIHU,XUPU,LIUZHOU_WORD,JINGCHU,NINETY_SIX);
        // 四组小暗刻与三组大暗刻，共30息。
        var charges=List.of(6,16,5,7,21,27,50,7,8,7,28,9);
        for(int i=0;i<words.size();i++) {
            var rules=words.get(i);
            var hand=new ArrayList<Integer>();
            for(int tile:List.of(1,3,5,7,rules==JINGCHU?33:17,rules==JINGCHU?35:19,rules==JINGCHU?37:21))
                hand.addAll(Collections.nCopies(3,tile));
            var r=opening(rules,hand);
            check(r.actions(0).contains("win"),rules.name());
            move(r,"win");
            int fee=charges.get(i);
            check(r.points().equals(List.of(2*fee,-fee,-fee)),rules+" "+r.points());
        }
        var flowerDeck=JINGCHU.deck(new Random(112));
        check(flowerDeck.size()==112 && Collections.frequency(flowerDeck,45)==2,"两张别杠");
        var flowers=opening(JINGCHU,List.of(1,1,17,3,3,19,5,5,5,7,7,7,33,33,33,35,35,35,37,37,45));
        move(flowers,"win");
        check(flowers.points().equals(List.of(60,-30,-30)),"花素成坎，每花加一息，别杠代字牌");
        for(var rules:List.of(LIUZHOU,CHANGSHA,XINYU,YUANJIANG,MEIZHOU,CHUOXIA,LAOPAI)) {
            var r=opening(rules,List.of(1,1,1,3,3,3,4,4,4,6,6,6,5,5));
            move(r,"win");
            int raw=switch(rules) {case YUANJIANG,CHUOXIA->2;case MEIZHOU,LAOPAI->3;default->1;};
            for(Object tile:(List<?>)r.board(0).get("birds")) {
                int c=(Integer)tile;
                if(rules==CHUOXIA) raw+=c==65?9:c&15;
                else if(c==49 || c==53 || c<49 && List.of(1,5,9).contains(c&15)) raw++;
            }
            int payment=raw*2;
            check(r.points().equals(List.of(3*payment,-payment,-payment,-payment)),rules+" "+r.points());
        }
    }
    static FriendRound climbingDeal(FriendRules rules,List<List<Integer>> seats) {
        var deck=new ArrayList<>(rules.deck(new Random(3)));
        var rest=new ArrayList<>(deck);
        var fixed=new HashMap<Integer,Integer>();
        for(int i=0;i<seats.size();i++) for(int j=0;j<seats.get(i).size();j++) {
            int card=seats.get(i).get(j);
            check(rest.remove((Integer)card),"测试分牌超出牌副");
            fixed.put(i+j*4,card);
        }
        for(int i=0;i<deck.size();i++) deck.set(i,fixed.containsKey(i)?fixed.get(i):rest.removeLast());
        return rules.start(deck);
    }
    static void climbingTricks() {
        var opening=List.of(List.of(5,26,45),List.of(5,10,13),List.of(4,20,36,52));
        var xinyu=climbingDeal(FIVE_TEN_KING,opening);
        move(xinyu,"play",5,26,45); move(xinyu,"play",5,10,13); move(xinyu,"play",4,20,36,52);
        move(xinyu,"pass"); move(xinyu,"pass"); move(xinyu,"pass");
        check(xinyu.currentSeat()==2 && xinyu.board(0).get("summary").toString().contains("一三座 50 分"),"炸弹收两手510K共50分");
        for(var rules:List.of(GUOZHA,DAZHA,QIANFEN)) {
            var r=climbingDeal(rules,List.of(List.of(5,21,37,53)));
            move(r,"play",5,21,37,53); move(r,"pass"); move(r,"pass"); move(r,"pass");
            int total=20+(rules==GUOZHA?10:rules==DAZHA?20:0);
            check(r.board(1).get("summary").toString().contains("一三座 "+total+" 分"),rules+" 炸奖和分牌");
        }
    }
    static void baccarat() {
        var cards=List.of(4,36,20,52,1,2); // 双方前两张都是4，天然八和。
        var deal=Baccarat.open(cards);
        check(deal.playerPair() && deal.housePair() && deal.house().size()==2 && deal.player().size()==2,"双对天然和");
        var net=Baccarat.settle(List.of(new Banker(1,200)),List.of(new Bet(2,1,3),new Bet(2,2,3),
                new Bet(2,3,1),new Bet(2,4,2),new Bet(2,5,2)),cards);
        check(net.equals(Map.of(1,-52L,2,52L)),"庄闲退还、和8、对子11");
        check(Baccarat.open(List.of(2,1,3,18,8,4)).house().size()==2,"庄三遇闲第三张八停牌");
        check(Baccarat.open(List.of(2,1,3,18,7,4)).house().size()==3,"庄三遇闲第三张七补牌");
    }
    static void bettingAndPrivacy() {
        var cards=List.of(16,17,1,1, 12,12,15,15, 2,2,3,3, 4,4,5,5);
        var r=CLASSIC_DOMINO.start(cards);
        for(int i=0;i<3;i++) { check(r.hand(i).isEmpty(),"下注前泄露牌面"); move(r,"stake1"); }
        for(int[] pair:new int[][]{{16,17},{12,12},{2,2},{4,4}}) move(r,"split",pair[0],pair[1]);
        check(r.points().equals(List.of(3,-1,-1,-1)),"至尊配双天");
        var bull=POT_BULL.start(POT_BULL.deck(new Random(319)));
        for(int n=0;n<7;n++) bull.apply(bull.automatic(bull.currentSeat()));
        check(bull.phase().equals("POT"),"应能切锅或继续");
        var score=bull.points();
        move(bull,"continuePot");
        check(bull.phase().equals("BET") && bull.points().equals(score) && bull.hand(1).isEmpty(),"续手应保留锅内净分、重新下注");
        finish(bull);
        var ddz=OPEN_LANDLORD.start(OPEN_LANDLORD.deck(new Random(4)));
        move(ddz,"call1");move(ddz,"decline");move(ddz,"decline");
        move(ddz,"openDouble");move(ddz,"double");move(ddz,"normal");
        var open=(List<?>)ddz.board(2).get("openHands");
        check(((List<?>)open.get(0)).size()==20 && ((List<?>)open.get(1)).isEmpty(),"明暗牌可见性");
        finish(ddz);
        check(Math.abs(ddz.points().get(1))==2*Math.abs(ddz.points().get(2)),"农民个人加倍");
        var deck=FLOAT_DUEL.deck(new Random(8));
        var base=FLOAT_DUEL.start(deck);var floated=FLOAT_DUEL.start(deck);
        move(base,"float0");move(base,"float0");move(floated,"float1");move(floated,"float2");
        check(base.hand(0).size()==16 && base.hand(1).size()==16,"双人各16张");
        finish(base); finish(floated);
        int winner=floated.nextStarter(new Random(1));
        check(floated.points().get(winner)-base.points().get(winner)==3,"单独核算飘分");
    }
    public static void main(String[] args) {
        regionalScores(); climbingTricks(); baccarat(); bettingAndPrivacy();
        System.out.println("Verified regional winning hands and scores, banker pot continuity, domino split, pair payouts, individual doubles and floats.");
    }
}
