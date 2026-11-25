package com.j.joker.game.water.domain;

import com.j.joker.game.tables.domain.FriendRound;
import java.util.*;

/** 四座十三水。头道和中道由持牌人分别提交，尾道由剩牌确定。 */
public final class WaterRound implements FriendRound {
    public static final String RULES="独立规则 v1｜四人积分桌。头3中5尾5，尾≥中≥头。每道1分，头三条3，中葫芦2，中/尾四条8/4，同花顺10/5；打枪双倍，全垒打再翻倍。六对半、三同花、三顺6分，一条龙52分。同类特殊和局。";
    private final List<List<Integer>> hands=new ArrayList<>(),front=new ArrayList<>(),middle=new ArrayList<>(),back=new ArrayList<>();
    private int turn,count;
    public WaterRound(List<Integer> deck,int first) {
        if(deck.size()!=52 || new HashSet<>(deck).size()!=52 || deck.stream().anyMatch(c->c<1 || c>61 || (c&15)<1 || (c&15)>13))
            throw new IllegalArgumentException("十三水需要完整的一副牌");
        turn=first;
        for(int i=0;i<4;i++) {
            var hand=new ArrayList<Integer>();
            for(int j=i;j<52;j+=4) hand.add(deck.get(j));
            hands.add(List.copyOf(hand));front.add(List.of());middle.add(List.of());back.add(List.of());
        }
    }
    private static int pip(int c) { return (c&15)==1?14:c&15; }
    private static boolean flush(List<Integer> h) { return h.stream().map(c->c/16).distinct().count()==1; }
    private static int straight(List<Integer> h) {
        var sorted=h.stream().mapToInt(WaterRound::pip).distinct().sorted().toArray();
        if(sorted.length!=h.size()) return 0;
        int last=sorted[sorted.length-1];
        if(last==14 && sorted[0]==2 && sorted[sorted.length-2]==sorted.length) return 14;
        if(last-sorted[0]!=h.size()-1) return 0;
        return last==14?15:last;
    }
    private record Rank(int kind,long tie,int suit) implements Comparable<Rank> {
        public int compareTo(Rank r) {
            int k=Integer.compare(kind,r.kind);
            if(k!=0) return k;
            int t=Long.compare(tie,r.tie);
            return t==0?Integer.compare(suit,r.suit):t;
        }
    }
    private static Rank rank(List<Integer> h) {
        var freq=new int[15];
        for(int c:h) freq[pip(c)]++;
        var ranks=h.stream().map(WaterRound::pip).distinct()
                .sorted(Comparator.<Integer>comparingInt(p->freq[p]).thenComparingInt(p->p).reversed()).toList();
        int first=ranks.getFirst(),many=freq[first];
        int straight=h.size()==5?straight(h):0;
        boolean flush=h.size()==5 && flush(h);
        int kind=flush && straight!=0?8:many==4?7:many==3 && ranks.size()==2?6:flush?5:straight!=0?4:
                many==3?3:many==2 && ranks.size()==3 && h.size()==5?2:many==2?1:0;
        long tie=0;
        if(straight!=0) tie=straight;
        else for(int i=0;i<5;i++) tie=16*tie+(i<ranks.size()?ranks.get(i):0);
        int suit=h.stream().filter(c->pip(c)==first).mapToInt(c->c/16).max().orElseThrow();
        return new Rank(kind,tie,suit);
    }
    private static List<Integer> remaining(List<Integer> source,List<Integer> selected) {
        var rest=new ArrayList<>(source);
        for(int c:selected) if(!rest.remove((Integer)c)) throw new IllegalArgumentException("所选牌不在手中");
        return rest;
    }
    private static List<Integer> validMiddle(List<Integer> rest,List<Integer> head) {
        Rank min=rank(head);
        for(int a=0;a<6;a++) for(int b=a+1;b<7;b++) for(int c=b+1;c<8;c++)
            for(int d=c+1;d<9;d++) for(int e=d+1;e<10;e++) {
                var m=List.of(rest.get(a),rest.get(b),rest.get(c),rest.get(d),rest.get(e));
                var score=rank(m);
                if(score.compareTo(min)>=0 && rank(remaining(rest,m)).compareTo(score)>=0) return m;
            }
        return List.of();
    }
    public String phase() { return count==4?"FINISHED":"ARRANGE"; }
    public int currentSeat() { return turn; }
    public List<Integer> hand(int seat) { return remaining(hands.get(seat),front.get(seat)); }
    public List<String> actions(int seat) {
        return turn==seat && count<4?List.of(front.get(seat).isEmpty()?"front":"middle","auto"):List.of();
    }
    public Move automatic(int seat) {
        var h=hands.get(seat);
        if(front.get(seat).isEmpty()) {
            var sorted=h.stream().sorted(Comparator.comparingInt(WaterRound::pip)).toList();
            for(int a=0;a<11;a++) for(int b=a+1;b<12;b++) for(int c=b+1;c<13;c++) {
                var f=List.of(sorted.get(a),sorted.get(b),sorted.get(c));
                if(!validMiddle(remaining(h,f),f).isEmpty()) return new Move(seat,"front",f);
            }
            throw new IllegalStateException("未找到合法头道");
        }
        return new Move(seat,"middle",validMiddle(hand(seat),front.get(seat)));
    }
    public void apply(Move move) {
        int seat=move.seat(); var selected=move.cards();
        if(!actions(seat).contains(move.action())) throw new IllegalArgumentException("摆道顺序错误");
        if(move.action().equals("auto")) {apply(automatic(seat));return;}
        var rest=remaining(hand(seat),selected);
        if(move.action().equals("front")) {
            if(selected.size()!=3 || validMiddle(rest,selected).isEmpty()) throw new IllegalArgumentException("头道须选三张并能合法摆道");
            front.set(seat,List.copyOf(selected));
        } else {
            if(selected.size()!=5 || rank(selected).compareTo(rank(front.get(seat)))<0 || rank(rest).compareTo(rank(selected))<0)
                throw new IllegalArgumentException("中道须选五张，尾道不能小于中道，中道不能小于头道");
            middle.set(seat,List.copyOf(selected)); back.set(seat,List.copyOf(rest));count++;turn=(turn+1)%4;
        }
    }
    private int special(int seat) {
        var hand=hands.get(seat);
        if(hand.stream().map(WaterRound::pip).distinct().count()==13) return 52;
        var groups=List.of(front.get(seat),middle.get(seat),back.get(seat));
        if(groups.stream().allMatch(WaterRound::flush) || groups.stream().allMatch(h->straight(h)>0)) return 6;
        int pairs=hand.stream().map(WaterRound::pip).distinct().mapToInt(p->(int)hand.stream().filter(c->pip(c)==p).count()/2).sum();
        return pairs==6?6:0;
    }
    private static int value(int lane,Rank hand) {
        if(lane==0 && hand.kind==3) return 3;
        if(lane==1 && hand.kind==6) return 2;
        if(hand.kind==8) return lane==1?10:5;
        if(hand.kind==7) return lane==1?8:4;
        return 1;
    }
    public List<Integer> points() {
        if(count!=4) throw new IllegalStateException("等待摆道");
        int[][] vs=new int[4][4];int[] sweep=new int[4];
        var lanes=List.of(front,middle,back);
        for(int i=0;i<4;i++) for(int j=i+1;j<4;j++) {
            int a=special(i),b=special(j);
            int score=0,wins=0;
            if(a!=0 || b!=0) score=a>b?a:b>a?-b:0;
            else {
                for(int k=0;k<3;k++) {
                    var x=rank(lanes.get(k).get(i)); var y=rank(lanes.get(k).get(j)); int d=x.compareTo(y);
                    wins+=Integer.signum(d);
                    score+=d>0?value(k,x):d<0?-value(k,y):0;
                }
                if(Math.abs(wins)==3) {score*=2;sweep[wins>0?i:j]++;}
            }
            vs[i][j]=score;vs[j][i]=-score;
        }
        int[] result=new int[4];
        for(int i=0;i<4;i++) for(int j=0;j<4;j++) result[i]+=vs[i][j]*(sweep[i]==3 || sweep[j]==3?2:1);
        return Arrays.stream(result).boxed().toList();
    }
    public Map<String,Object> board(int viewer) {
        return Map.of("summary",front.get(viewer).isEmpty()?"点选三张放入头道，或选择自动摆道":"点选五张放入中道，其余为尾道",
                "head",front.get(viewer),"hands",count==4?List.of(front,middle,back):List.of());
    }
    public int nextStarter(java.util.random.RandomGenerator random) { return turn; }
}
