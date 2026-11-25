package com.j.joker.game.threecard.domain;

import com.j.joker.game.tables.domain.FriendRound;
import java.util.*;

public final class GoldenFlower implements FriendRound {
    public static final String RULES="独立规则 v1｜三人积分桌。每人底注1，暗注档1/2/4，看牌后加倍。第二轮起可付跟注额比一人，同牌发起方输，杂色235胜豹子。第五轮起可发起8分火拼，其他人跟或弃，第八轮强制比牌。牌型从大到小为豹子、同花顺、同花、顺子、对子、散牌，A23为最小顺子。";
    private final List<List<Integer>> hands;
    private final int dealer;
    private final boolean[] seen=new boolean[3],out=new boolean[3],acted=new boolean[3];
    private final int[] paid={1,1,1};
    private int turn,unit=1,lap=1,winner=-1,challenge=-1;

    public GoldenFlower(List<Integer> deck,int dealer) {
        hands=ThreeCardHand.deal(deck,3);
        this.dealer=dealer; turn=(dealer+1)%3;
    }
    public String phase() { return winner<0?"BET":"FINISHED"; }
    public int currentSeat() { return turn; }
    public List<Integer> hand(int seat) { return seen[seat] || winner>=0?hands.get(seat):List.of(); }
    public List<String> actions(int seat) {
        if(turn!=seat || winner>=0) return List.of();
        var options=new ArrayList<String>();
        if(!seen[seat]) options.add("look");
        options.add("fold");
        if(challenge>=0) {options.add("matchAll");return options;}
        options.add("call");
        if(unit<4) options.add("raise");
        if(lap>=2) for(int i=0;i<3;i++) if(i!=seat && !out[i]) options.add("compare"+(i+1));
        if(lap>=5) options.add("allIn");
        return options;
    }
    private int cost(int seat) { return unit*(seen[seat]?2:1); }
    private boolean beats(int a,int b) {
        return ThreeCardHand.golden(hands.get(a)).beats(ThreeCardHand.golden(hands.get(b)));
    }
    private void showdown(int initiator) {
        int best=(initiator+1)%3;
        while(out[best]) best=(best+1)%3;
        for(int i=1;i<=3;i++) {
            int other=(initiator+1+i)%3;
            if(!out[other] && other!=best && beats(other,best)) best=other;
        }
        winner=best;
    }
    public void apply(Move m) {
        int seat=m.seat();String action=m.action();
        if(!m.cards().isEmpty() || !actions(seat).contains(action)) throw new IllegalArgumentException("金花操作无效");
        switch(action) {
            case "look" -> { seen[seat]=true;return; }
            case "fold" -> out[seat]=true;
            case "call" -> paid[seat]+=cost(seat);
            case "raise" -> {unit*=2;paid[seat]+=cost(seat);}
            case "allIn" -> {challenge=seat;paid[seat]+=8;}
            case "matchAll" -> paid[seat]+=8;
            default -> {
                int other=action.charAt(action.length()-1)-'1';
                paid[seat]+=cost(seat);
                out[beats(seat,other)?other:seat]=true;
            }
        }
        int remaining=0;
        for(int i=0;i<3;i++) if(!out[i]) remaining++;
        do {turn=(turn+1)%3;} while(out[turn]);
        if(remaining==1) { winner=turn;return; }
        if(challenge>=0) {
            if(turn==challenge) showdown(challenge);
            return;
        }
        acted[seat]=true;
        for(int i=0;i<3;i++) if(!out[i] && !acted[i]) return;
        Arrays.fill(acted,false);
        if(++lap>8) showdown(seat);
    }
    public Move automatic(int seat) {
        var options=actions(seat);
        String op=options.stream().filter(a->a.startsWith("compare")).findFirst().orElse(challenge<0?"call":"matchAll");
        return new Move(seat,op,List.of());
    }
    public List<Integer> points() {
        if(winner<0) throw new IllegalStateException("牌局未结束");
        int pot=Arrays.stream(paid).sum();
        return java.util.stream.IntStream.range(0,3).map(i->(i==winner?pot:0)-paid[i]).boxed().toList();
    }
    public Map<String,Object> board(int viewer) {
        return Map.of("summary","第"+lap+"轮 · 暗注"+unit+"分 · 池中"+Arrays.stream(paid).sum()+"分",
                "out",List.of(out[0],out[1],out[2]),"paid",Arrays.stream(paid).boxed().toList(),
                "hands",winner<0?List.of():hands,"winner",winner);
    }
    public int nextStarter(java.util.random.RandomGenerator random) { return (dealer+1)%3; }
}
