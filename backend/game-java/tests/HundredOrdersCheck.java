import com.j.joker.game.hundred.domain.*;
import java.util.*;
import static com.j.joker.game.hundred.domain.HundredSettlement.*;

public class HundredOrdersCheck {
    static void check(boolean ok) { if(!ok) throw new AssertionError("百人接单或轮庄错误"); }
    static void reject(Runnable op) {
        try { op.run(); } catch(IllegalArgumentException|IllegalStateException expected) { return; }
        throw new AssertionError("接受了无效操作");
    }
    public static void main(String[] args) {
        var queue=new BankerQueue(2,100,2);
        var coins=Map.of(1,600,2,200,3,150,4,120,5,100);
        reject(()->queue.apply(1,80,false)); reject(()->queue.apply(1,600,true));
        for(int i=1;i<=4;i++) queue.apply(i,coins.get(i),false);
        queue.apply(4,120,false);
        var pair=queue.start(coins);
        check(pair.equals(List.of(new Banker(1,600),new Banker(2,200))));
        reject(()->queue.start(coins));
        queue.withdraw(1); queue.withdraw(4);
        check(queue.waiting().equals(List.of(3)));
        queue.finish();
        check(queue.start(coins).equals(List.of(new Banker(2,200),new Banker(3,150))));
        queue.apply(5,100,false); queue.finish();
        check(queue.start(coins).equals(List.of(new Banker(3,150),new Banker(5,100))));
        var orders=new HundredOrders(101,pair,coins,List.of(100,100,180));
        var bet=new Bet(3,3,80);
        orders.accept("tie",bet);orders.accept("tie",bet);
        check(orders.held(3)==80);
        reject(()->orders.accept("tie",new Bet(3,3,40)));
        reject(()->orders.accept("too-big",new Bet(3,1,71)));
        reject(()->orders.accept("too-much-risk",new Bet(4,3,60)));
        reject(()->orders.accept("wrong-area",new Bet(4,4,20)));
        reject(()->orders.accept("dealer",new Bet(1,1,20)));
        var expected=Map.of(1,-360L,2,-120L,3,480L);
        check(orders.close(List.of(2,18)).equals(expected) && orders.held(3)==0);
        orders.accept("tie",bet);
        check(orders.close(List.of(2,18)).equals(expected));
        reject(()->orders.close(List.of(1,18)));
        reject(()->orders.accept("late",new Bet(3,2,1)));
        var beasts=new HundredOrders(102,pair,coins,List.of(10,10,10,10));
        reject(()->beasts.accept("limit",new Bet(3,1,11)));
        beasts.accept("ok",new Bet(3,1,10));
        check(beasts.held(3)==130);
        reject(()->beasts.accept("wallet",new Bet(3,2,2)));
        check(beasts.close(List.of(13,1,2,3,4)).get(3)==-130L);
        // 自然八九停牌，两边首两张对子独立于主注结算。
        var natural=List.of(4,9,20,25,1,3);
        var deal=Baccarat.open(natural);
        check(deal.playerPoints()==8 && deal.housePoints()==8 && deal.playerPair() && deal.housePair() && deal.player().size()==2 && deal.house().size()==2);
        var payouts=Baccarat.settle(pair,List.of(new Bet(3,3,10),new Bet(4,4,10),new Bet(5,5,10)),natural);
        check(payouts.get(3)==80L && payouts.get(4)==110L && payouts.get(5)==110L);
        var playerDraw=Baccarat.open(List.of(1,2,4,17,8,3));
        check(playerDraw.player().size()==3 && playerDraw.house().size()==2);
        var both=Baccarat.open(List.of(1,2,4,19,7,3));
        check(both.player().size()==3 && both.house().size()==3);
        reject(()->HundredExposure.check(101,List.of(new Banker(1,Integer.MAX_VALUE)),200,new long[]{100,0,0},new long[]{100,0,0}));
        reject(()->HundredExposure.check(9103,pair,Integer.MAX_VALUE,new long[]{0,0,0,100,0},new long[]{0,0,0,100,0}));
        System.out.println("Verified banker rotation, withdrawal, caps, exposure, funds and idempotent bets.");
    }
}
