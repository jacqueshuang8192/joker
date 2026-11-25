package com.j.joker.game.meld.domain;

import java.util.*;

/** 用同一组合法组合判定吃牌与和牌，求含万能牌时最高的成组胡息。 */
final class MeldHand {
    record Group(List<Integer> cards, int hidden, int open, boolean triplet) {}
    static final int INVALID = -10000;
    private final MeldRules rules;
    private final List<Integer> tiles;
    final List<Group> shapes = new ArrayList<>();
    private final Map<Integer,List<Group>> byTile = new HashMap<>();

    MeldHand(MeldRules rules) {
        this.rules=rules;
        tiles=rules.pack().stream().map(rules::face).distinct().filter(c->c!=rules.wildcard()).toList();
        for(int c:tiles) {
            int value=c&15;
            boolean large=c>16;
            add(c,c,c,large?6:3,large?3:1);
            if((rules.type==MeldRules.Pack.HONORS && c>48) || rules.type==MeldRules.Pack.FLOWER && c>32) continue;
            if(tiles.contains(c+2) && tiles.contains(c+1) && c/16==(c+2)/16)
                add(c,c+1,c+2,value==1?(large?6:3):0,value==1?(large?6:3):0);
            if(!rules.mahjong() && value==2 && tiles.contains(c+8)) add(c,c+5,c+8,large?6:3,large?6:3);
            if(rules.type==MeldRules.Pack.WORD && !large) {
                add(c,c,c+16,0,0); add(c,c+16,c+16,0,0);
            }
        }
        if(rules.type==MeldRules.Pack.FLOWER) {
            add(1,33,34,3,3); add(3,35,36,3,3); add(7,10,37,3,3); add(8,9,38,3,3);
            add(39,40,41,6,6); add(42,43,44,6,6);
        }
    }
    private void add(int a,int b,int c,int hidden,int open) {
        var g=new Group(List.of(a,b,c),hidden,open,a==c);
        shapes.add(g);
        for(int tile:new HashSet<>(g.cards)) byTile.computeIfAbsent(tile,k->new ArrayList<>()).add(g);
    }
    int score(List<Integer> hand,List<MeldRound.Exposed> shown) {
        int[] counts=new int[66]; int wild=0;
        for(int c:hand) { if(c==rules.wildcard()) wild++; else counts[rules.face(c)]++; }
        if(rules.mahjong()) {
            int best=INVALID;
            if(shown.isEmpty() && hand.size()==14 && Arrays.stream(counts).map(n->n%2).sum()<=wild) best=2;
            for(int pair:tiles) {
                if(rules==MeldRules.CHANGSHA && !List.of(2,5,8).contains(pair&15)) continue;
                int held=Math.min(2,counts[pair]);
                if(held+wild<2) continue;
                counts[pair]-=held;
                boolean win=groups(counts,wild-2+held,false,false)>=0;
                counts[pair]+=held;
                if(win) {best=Math.max(best,0);break;}
            }
            if(best<0) return INVALID;
            var all=new HashSet<>(hand); shown.forEach(g->all.addAll(g.cards())); all.remove(rules.wildcard());
            if(rules==MeldRules.XINYU)
                for(int s=0;s<3;s++) {
                    int offset=s*16;
                    if(java.util.stream.IntStream.rangeClosed(1,9).allMatch(n->all.contains(offset+n))) {best+=2;break;}
                }
            if(rules==MeldRules.LAOPAI && all.stream().map(c->c/16).distinct().count()==1) best+=2;
            return best+rules.minimum;
        }
        int hidden=groups(counts,wild,true,false);
        if(hidden<0) return INVALID;
        int open=shown.stream().mapToInt(MeldRound.Exposed::score).sum();
        int flowers=(int)java.util.stream.Stream.concat(hand.stream(),shown.stream().flatMap(g->g.cards().stream()))
                .filter(tile->rules.face(tile)!=tile).count();
        int value=wordPoints(hidden+open+flowers);
        if(rules==MeldRules.PENGPENG && shown.stream().allMatch(g->g.cards().stream().distinct().count()==1)) {
            int onlyTriplets=groups(counts,wild,true,true);
            if(onlyTriplets>=0) value=Math.max(value,2*wordPoints(onlyTriplets+open));
        }
        return value;
    }
    private int wordPoints(int xi) {
        return xi<rules.minimum ? INVALID : (1+(xi-rules.minimum)/rules.step)*(rules==MeldRules.SANPI?3:1);
    }
    private int groups(int[] counts,int wild,boolean maximize,boolean tripletsOnly) {
        int first=1;
        while(first<counts.length && counts[first]<=0) first++;
        if(first==counts.length) return wild%3==0 ? (maximize?6*(wild/3):0) : INVALID;
        int best=INVALID;
        for(Group g:byTile.get(first)) {
            if(tripletsOnly && !g.triplet()) continue;
            int missing=0;
            for(int c:g.cards) if(--counts[c]<0) missing++;
            if(missing<=wild) {
                int tail=groups(counts,wild-missing,maximize,tripletsOnly);
                if(tail>=0) best=Math.max(best,tail+(maximize?g.hidden:0));
            }
            for(int c:g.cards) counts[c]++;
            if(!maximize && best>=0) break;
        }
        return best;
    }
}
