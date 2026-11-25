package com.j.joker.game.threecard.domain;

import com.j.joker.game.tables.domain.FriendRound;
import java.util.*;

public final class Sangong implements FriendRound {
    public static final String RULES="独立规则 v1｜三人积分桌。抢庄0至3倍，同抢按本局首位顺序定庄，全不抢首位1倍坐庄。闲家押1或2分。大三公5倍、小三公4倍、混三公3倍、八九点2倍，其余1倍，按赢家牌型结算。三张相同人头为大三公，其余三同为小三公，三人头为混三公；同型依点数、人头数、最大牌和花色分胜负。";
    private final List<List<Integer>> hands;
    private final int first;
    private final int[] bids={-1,-1,-1},stakes=new int[3];
    private final boolean[] revealed=new boolean[3];
    private int turn,banker=-1;
    private String phase="GRAB";

    public Sangong(List<Integer> deck,int first) { this.first=turn=first; hands=ThreeCardHand.deal(deck,3); }
    public String phase() { return phase; }
    public int currentSeat() { return turn; }
    public List<Integer> hand(int seat) {
        return phase.equals("GRAB") || phase.equals("BET")?hands.get(seat).subList(0,2):hands.get(seat);
    }
    public List<String> actions(int seat) {
        if(turn!=seat) return List.of();
        return switch(phase) {case "GRAB"->List.of("grab0","grab1","grab2","grab3");
            case "BET"->List.of("stake1","stake2");case "REVEAL"->List.of("reveal");default->List.of();};
    }
    public void apply(Move m) {
        if(!actions(m.seat()).contains(m.action()) || !m.cards().isEmpty()) throw new IllegalArgumentException("三公操作无效");
        int seat=turn;
        turn=(turn+1)%3;
        switch(phase) {
            case "GRAB" -> {
                bids[seat]=m.action().charAt(4)-'0';
                if(turn==first) {
                    banker=first;
                    for(int i=1;i<3;i++) {
                        int other=(first+i)%3;
                        if(bids[other]>bids[banker]) banker=other;
                    }
                    phase="BET";turn=(banker+1)%3;
                }
            }
            case "BET" -> {
                stakes[seat]=m.action().charAt(5)-'0';
                if(turn==banker) phase="REVEAL";
            }
            case "REVEAL" -> { revealed[seat]=true;if(turn==banker) phase="FINISHED"; }
            default -> throw new IllegalStateException();
        }
    }
    public Move automatic(int seat) { return new Move(seat,actions(seat).getFirst(),List.of()); }
    public Map<String,Object> board(int viewer) {
        var cards=new ArrayList<List<Integer>>();
        for(int i=0;i<3;i++) cards.add(revealed[i]?hands.get(i):List.of());
        return Map.of("summary",banker<0?"各座依次抢庄":"庄家 "+(banker+1)+"座 · "+Math.max(1,bids[banker])+"倍",
                "hands",cards,"banker",banker);
    }
    public List<Integer> points() {
        if(!phase.equals("FINISHED")) throw new IllegalStateException("牌局未结束");
        var bank=ThreeCardHand.gong(hands.get(banker));
        int[] net=new int[3];
        for(int i=0;i<3;i++) if(i!=banker) {
            var hand=ThreeCardHand.gong(hands.get(i));
            int rate=hand.compareTo(bank)>0?hand.rate():-bank.rate();
            net[i]=rate*stakes[i]*Math.max(1,bids[banker]);net[banker]-=net[i];
        }
        return Arrays.stream(net).boxed().toList();
    }
    public int nextStarter(java.util.random.RandomGenerator random) { return (first+1)%3; }
}
