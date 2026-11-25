package com.j.joker.game.threecard.domain;

import java.util.*;

public final class ThreeCardHand {
    private ThreeCardHand() {}
    static List<List<Integer>> deal(List<Integer> deck,int seats) {
        if(deck.size()!=52 || new HashSet<>(deck).size()!=52 ||
                deck.stream().anyMatch(c->c<1 || c>61 || (c&15)<1 || (c&15)>13))
            throw new IllegalArgumentException("需要不含大小王的一副牌");
        var dealt=new ArrayList<List<Integer>>();
        for(int i=0;i<seats;i++) dealt.add(List.of(deck.get(i),deck.get(i+seats),deck.get(i+2*seats)));
        return List.copyOf(dealt);
    }

    public record Golden(int type,int high,int middle,int low,boolean rainbow235) {
        // 点数相同由主动比牌者负。杂色235只在对阵豹子时翻转牌型关系。
        public boolean beats(Golden other) {
            if(rainbow235 && other.type==5) return true;
            if(other.rainbow235 && type==5) return false;
            int a=((type*16+high)*16+middle)*16+low;
            int b=((other.type*16+other.high)*16+other.middle)*16+other.low;
            return a>b;
        }
    }
    public static Golden golden(List<Integer> cards) {
        var ranks=cards.stream().mapToInt(c->(c&15)==1?14:c&15).sorted().toArray();
        int a=ranks[0],b=ranks[1],c=ranks[2];
        boolean flush=cards.stream().map(i->i/16).distinct().count()==1;
        int straight=b==a+1 && c==b+1?c:a==2 && b==3 && c==14?3:0;
        if(a==c) return new Golden(5,c,0,0,false);
        if(straight>0 && flush) return new Golden(4,straight,0,0,false);
        if(flush) return new Golden(3,c,b,a,false);
        if(straight>0) return new Golden(2,straight,0,0,false);
        if(a==b || b==c) return new Golden(1,b,a==b?c:a,0,false);
        boolean special=a==2 && b==3 && c==5;
        return new Golden(0,special?0:c,b,a,special);
    }

    public record Gong(int kind,int points,int faces,int high,int suit) implements Comparable<Gong> {
        private int value() { return (((kind*10+points)*4+faces)*16+high)*4+suit; }
        public int compareTo(Gong other) { return Integer.compare(value(),other.value()); }
        public int rate() { return switch(kind) { case 3->5;case 2->4;case 1->3;default->points>=8?2:1; }; }
    }
    public static Gong gong(List<Integer> cards) {
        var ordered=cards.stream().sorted(Comparator.comparingInt(c->(c&15)*4+(c>>>4))).toList();
        int high=ordered.getLast()&15,suit=ordered.getLast()>>>4;
        boolean trips=(ordered.getFirst()&15)==high;
        int faces=(int)cards.stream().filter(c->(c&15)>10).count();
        int points=cards.stream().mapToInt(c->Math.min(10,c&15)).sum()%10;
        return new Gong(trips?(high>10?3:2):faces==3?1:0,trips || faces==3?0:points,faces,high,suit);
    }
}
