package com.j.joker.game.hundred.domain;

import java.util.*;
import static com.j.joker.game.hundred.domain.HundredSettlement.*;

/** 千玺独立规则 v1。单副牌逐局洗牌，庄闲免佣，均按净赔付。 */
public final class Baccarat {
    public static final int LEVEL=9103;
    public static final String RULES="独立规则 v1 · 单副52张，每局重洗。庄、闲净赔1倍，和净赔8倍，庄对、闲对净赔11倍。和局退庄闲本金，对子独立结算，无佣金。";
    private Baccarat() {}
    public record Result(List<Integer> player,List<Integer> house,int playerPoints,int housePoints,boolean playerPair,boolean housePair) {}
    private static int point(int card) { return Math.min(card&15,10)%10; }
    private static int points(List<Integer> hand) { return hand.stream().mapToInt(Baccarat::point).sum()%10; }
    private static boolean bankerDraw(int total,int third) {
        return switch(total) {
            case 0,1,2 -> true;
            case 3 -> third!=8;
            case 4 -> third>=2 && third<=7;
            case 5 -> third>=4 && third<=7;
            case 6 -> third==6 || third==7;
            default -> false;
        };
    }
    /** 牌序按闲、庄、闲、庄排列。最后两张仅用于实际需要补牌的一方。 */
    public static Result open(List<Integer> deck) {
        if(deck.size()!=6 || new HashSet<>(deck).size()!=6) throw new IllegalArgumentException("百家乐牌序无效");
        deck.forEach(HundredPlayerCards.Card::new);
        var p=new ArrayList<>(List.of(deck.get(0),deck.get(2)));
        var b=new ArrayList<>(List.of(deck.get(1),deck.get(3)));
        int player=points(p),house=points(b);
        if(player<8 && house<8) {
            int cursor=4;
            boolean draw=player<=5;
            if(draw) p.add(deck.get(cursor++));
            if(draw?bankerDraw(house,point(p.getLast())):house<=5) b.add(deck.get(cursor));
        }
        return new Result(List.copyOf(p),List.copyOf(b),points(p),points(b),
                (p.get(0)&15)==(p.get(1)&15),(b.get(0)&15)==(b.get(1)&15));
    }
    public static Map<Integer,Long> settle(List<Banker> bankers,List<Bet> bets,List<Integer> cards) {
        Result r=open(cards);
        long house=Integer.compare(r.housePoints,r.playerPoints);
        return HundredSettlement.distribute(bankers,bets,List.of(house,-house,house==0?8L:-1L,
                r.housePair?11L:-1L,r.playerPair?11L:-1L));
    }
}
