package com.j.joker.game.banker.domain;

import com.j.joker.game.tables.domain.FriendRound;
import java.util.*;

public final class BankerRound implements FriendRound {
    // 天、地、人、鹅、梅、长、板、斧、红头、高脚、零霖、杂九、杂八、杂七、杂五、丁三、猴六。
    private static final int[] PIPS={0,12,2,8,4,10,6,4,11,10,7,6,9,8,7,5,3,6};
    private final BankerRules rules;
    private final List<Integer> deck;
    private final List<List<Integer>> hands=new ArrayList<>();
    private final int[][] strength=new int[4][];
    private final int[] stakes=new int[4], net=new int[4];
    private final int banker;
    private int turn,cursor,number,pot=18;
    private boolean refilled;
    private String phase="BET";
    BankerRound(BankerRules rules,List<Integer> deck,int dealer) {
        this.rules=rules; this.deck=List.copyOf(deck); this.banker=dealer;
        for(int i=0;i<4;i++) hands.add(List.of());
        begin();
    }
    private void begin() {
        number++; phase="BET"; turn=(banker+1)%4;
        Arrays.fill(stakes,0); Arrays.fill(strength,null);
        for(int i=0;i<4;i++) hands.set(i,List.of());
    }
    public String phase() { return phase; }
    public int currentSeat() { return turn; }
    public List<Integer> hand(int seat) { return hands.get(seat); }
    private int reserved() { return Arrays.stream(stakes).sum()*(rules==BankerRules.POT_BULL?3:1); }
    public List<String> actions(int seat) {
        if(seat!=turn) return List.of();
        return switch(phase) {
            case "BET" -> {
                int limit=rules.pot()?(pot-reserved())/(rules==BankerRules.POT_BULL?3:1):2;
                yield limit>=2?List.of("stake1","stake2"):limit==1?List.of("stake1"):List.of("sitOut");
            }
            case "ARRANGE" -> List.of("split","auto");
            case "REVEAL" -> List.of("reveal");
            case "POT" -> lowPot()?List.of("cut","refill"):List.of("cut","continuePot");
            default -> List.of();
        };
    }
    public Move automatic(int seat) {
        if(phase.equals("ARRANGE")) {
            var h=hands.get(seat);
            int best=-1; List<Integer> choice=List.of();
            for(int j=1;j<4;j++) {
                var selected=List.of(h.getFirst(),h.get(j));
                var s=split(h,selected);
                if(s[0]>best) {best=s[0];choice=selected;}
            }
            return new Move(seat,"split",choice);
        }
        return new Move(seat,actions(seat).getFirst(),List.of());
    }
    public void apply(Move m) {
        if(!actions(m.seat()).contains(m.action())) throw new IllegalArgumentException("操作不属于当前座位");
        if(!m.action().equals("split") && !m.cards().isEmpty()) throw new IllegalArgumentException("此操作无需选牌");
        switch(m.action()) {
            case "auto" -> apply(automatic(turn));
            case "stake1","stake2","sitOut" -> {
                stakes[turn]=m.action().equals("sitOut")?0:m.action().charAt(5)-'0';
                turn=(turn+1)%4;
                if(turn==banker) {
                    for(int i=0;i<4;i++) {
                        int end=cursor+rules.handSize();
                        hands.set(i,deck.subList(cursor,end)); cursor=end;
                    }
                    phase=rules==BankerRules.PAI_GOW?"ARRANGE":"REVEAL";
                }
            }
            case "split","reveal" -> {
                var h=hands.get(turn);
                strength[turn]=switch(rules) {
                    case PAI_GOW -> split(h,m.cards());
                    case POT_DOMINO -> new int[]{domino(h)};
                    case POT_BULL -> new int[]{bull(h)};
                };
                turn=(turn+1)%4;
                if(turn==banker) settle();
            }
            case "cut" -> phase="FINISHED";
            case "refill" -> {refilled=true; pot+=18; begin();}
            case "continuePot" -> begin();
            default -> throw new IllegalArgumentException("未知操作");
        }
    }
    private static int[] split(List<Integer> held,List<Integer> pick) {
        if(pick.size()!=2) throw new IllegalArgumentException("选两张组成一门");
        var rest=new ArrayList<>(held);
        for(int c:pick) if(!rest.remove((Integer)c)) throw new IllegalArgumentException("手牌不匹配");
        int a=domino(pick),b=domino(rest);
        return new int[]{Math.min(a,b),Math.max(a,b)};
    }
    static int domino(List<Integer> hand) {
        int a=Math.min(hand.getFirst(),hand.getLast()), b=Math.max(hand.getFirst(),hand.getLast());
        if(a==16 && b==17) return 4000;
        if(a==b) return 3000-a;
        if(a==1 && PIPS[b]==9) return 2000;
        if(a<=2 && (PIPS[b]==8 || PIPS[b]==7)) return (PIPS[b]==8?1800:1600)-a;
        return ((PIPS[a]+PIPS[b])%10)*32+18-a;
    }
    static int bull(List<Integer> hand) {
        int[] p=hand.stream().mapToInt(c->Math.min(c&15,10)).toArray();
        int sum=Arrays.stream(p).sum(), rank=0;
        for(int i=0;i<4;i++) for(int j=i+1;j<5;j++) if((sum-p[i]-p[j])%10==0) rank=sum%10==0?10:sum%10;
        int high=hand.stream().mapToInt(c->(c&15)*4+c/16).max().orElseThrow();
        return rank*64+high;
    }
    private boolean lowPot() { return pot < (rules==BankerRules.POT_BULL?3:1); }
    private void settle() {
        int limit=pot;
        for(int i=0;i<4;i++) if(i!=banker) {
            int sum=0;
            for(int k=0;k<strength[i].length;k++) sum+=strength[i][k]>strength[banker][k]?1:-1;
            int sign=Integer.signum(sum);
            int mult=1;
            if(rules==BankerRules.POT_BULL) {
                int rank=strength[sign>0?i:banker][0]/64;
                mult=rank==10?3:rank>=7?2:1;
            }
            int score=sign*stakes[i]*mult;
            net[i]+=score; net[banker]-=score; pot-=score;
        }
        if(rules.pot() && (pot<0 || limit<reserved())) throw new IllegalStateException("锅底预占不足");
        phase=rules.pot() && cursor<deck.size() && (!lowPot() || !refilled)?"POT":"FINISHED";
    }
    public Map<String,Object> board(int viewer) {
        var visible=new ArrayList<List<Integer>>();
        for(int i=0;i<4;i++) visible.add(strength[i]!=null && (!phase.equals("ARRANGE") || i==viewer)?hands.get(i):List.of());
        return Map.of("summary",(banker+1)+"座坐庄 · 第"+number+"手"+(rules.pot()?" · 锅底"+pot+"分":""),
                "hands",visible,"stakes",Arrays.stream(stakes).boxed().toList(),"banker",banker);
    }
    public List<Integer> points() { return Arrays.stream(net).boxed().toList(); }
    public int nextStarter(java.util.random.RandomGenerator random) { return (banker+1)%4; }
}
