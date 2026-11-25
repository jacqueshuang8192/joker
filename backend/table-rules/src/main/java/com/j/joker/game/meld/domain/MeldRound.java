package com.j.joker.game.meld.domain;

import com.j.joker.game.tables.domain.FriendRound;
import java.util.*;

public final class MeldRound implements FriendRound {
    record Exposed(List<Integer> cards,int score,boolean concealed) {}
    private record Offer(int seat,String action,List<Integer> held,int score) {}
    private final MeldRules rules;
    private final MeldHand evaluator;
    private final List<Integer> deck;
    private final List<List<Integer>> hands=new ArrayList<>(), rivers=new ArrayList<>();
    private final List<List<Exposed>> exposed=new ArrayList<>();
    private final List<Offer> offers=new ArrayList<>();
    private final int[] points;
    private final int dealer;
    private int turn, draw, back, source, discarded, winner=-1;
    private boolean done, mustDiscard, selfDraw;
    private List<Integer> birds=List.of();

    MeldRound(MeldRules rules,List<Integer> deck,int first) {
        this.rules=rules; this.deck=List.copyOf(deck); this.back=deck.size();
        dealer=turn=first; points=new int[rules.seats()];
        evaluator=rules.evaluator();
        for(int i=0;i<rules.seats();i++) {
            hands.add(new ArrayList<>()); rivers.add(new ArrayList<>()); exposed.add(new ArrayList<>());
        }
        for(int i=0;i<rules.initial()*rules.seats();i++) hands.get(i%rules.seats()).add(deck.get(draw++));
        hands.get(turn).add(deck.get(draw++));
    }
    public int currentSeat() { return turn; }
    public String phase() { return done?"FINISHED":offers.isEmpty()?"DISCARD":"CLAIM"; }
    public List<Integer> hand(int seat) { return List.copyOf(hands.get(seat)); }
    public List<Integer> points() { return Arrays.stream(points).boxed().toList(); }
    private int win(int seat,boolean self) {
        var hand=new ArrayList<>(hands.get(seat));
        if(!self) hand.add(discarded);
        return evaluator.score(hand,exposed.get(seat));
    }
    private boolean kong(int seat,int tile) {
        if(tile==rules.wildcard() || draw>=back) return false;
        return matching(seat,tile).size()>=4 || exposed.get(seat).stream().anyMatch(g->pongOf(g,tile));
    }
    private List<Integer> matching(int seat,int tile) {
        return hands.get(seat).stream().filter(c->rules.face(c)==rules.face(tile)).toList();
    }
    private boolean pongOf(Exposed g,int tile) {
        return g.cards.size()==3 && g.cards.stream().allMatch(c->rules.face(c)==rules.face(tile));
    }
    public List<String> actions(int seat) {
        if(done || seat!=turn) return List.of();
        if(!offers.isEmpty()) {
            String action=offers.getFirst().action;
            return List.of(action,"skip");
        }
        var actions=new ArrayList<>(List.of("discard","auto"));
        if(!mustDiscard && win(seat,true)>=0) actions.add("win");
        if(!mustDiscard && hands.get(seat).stream().anyMatch(c->kong(seat,c))) actions.add("kong");
        return actions;
    }
    public Move automatic(int seat) {
        var allowed=actions(seat);
        if(allowed.contains("win")) return new Move(seat,"win",List.of());
        if(!offers.isEmpty()) {
            var claim=offers.getFirst();
            return new Move(seat,claim.action,claim.action.equals("chi")?claim.held:List.of());
        }
        // 先打无搭的单张，保留对子、顺搭和万能牌。
        var hand=hands.get(seat);
        int tile=hand.stream().min(Comparator.comparingInt(c -> keep(hand,c))).orElseThrow();
        return new Move(seat,"discard",List.of(tile));
    }
    private int keep(List<Integer> hand,int tile) {
        if(tile==rules.wildcard()) return 100;
        int n=Collections.frequency(hand,tile)*4;
        for(int offset:List.of(-2,-1,1,2)) if(hand.contains(tile+offset) && tile/16==(tile+offset)/16) n++;
        return n;
    }
    public void apply(Move move) {
        int seat=move.seat();
        if(!actions(seat).contains(move.action())) throw new IllegalArgumentException("当前不能执行此操作");
        switch(move.action()) {
            case "auto" -> apply(automatic(seat));
            case "win" -> settle(offers.isEmpty());
            case "skip" -> {
                Offer first=offers.getFirst();
                offers.removeIf(o->o.seat==first.seat && o.action.equals(first.action));
                nextOffer();
            }
            case "discard" -> discard(single(move));
            case "kong" -> ownKong(single(move));
            default -> claim(move);
        }
    }
    private int single(Move m) {
        if(m.cards().size()!=1 || !hands.get(turn).contains(m.cards().getFirst()))
            throw new IllegalArgumentException("请选择手中一张牌");
        return m.cards().getFirst();
    }
    private void take(int seat,List<Integer> tiles) {
        for(int tile:tiles) hands.get(seat).remove((Integer)tile);
    }
    private void discard(int tile) {
        source=turn; discarded=tile; mustDiscard=false;
        take(turn,List.of(tile)); rivers.get(turn).add(tile);
        for(int d=1;d<rules.seats();d++) {
            int other=(source+d)%rules.seats();
            if(win(other,false)>=0) offers.add(new Offer(other,"win",List.of(),0));
        }
        if(tile!=rules.wildcard()) {
            for(int d=1;d<rules.seats();d++) {
                int other=(source+d)%rules.seats();
                var matches=matching(other,tile);
                int count=matches.size(), face=rules.face(tile);
                if(count>=3 && draw<back) offers.add(new Offer(other,"exposedKong",matches.subList(0,3),face>16?9:6));
                if(count>=2 && hands.get(other).size()>2) offers.add(new Offer(other,"pong",matches.subList(0,2),face>16?3:1));
            }
            int next=(source+1)%rules.seats();
            for(var g:evaluator.shapes) {
                int face=rules.face(tile);
                if(hands.get(next).size()<=2 || g.triplet() || !g.cards().contains(face)) continue;
                var needed=new ArrayList<>(g.cards()); needed.remove((Integer)face);
                var seen=new HashSet<List<Integer>>();
                for(int a:matching(next,needed.getFirst())) for(int b:matching(next,needed.getLast())) {
                    if(a==b && Collections.frequency(hands.get(next),a)<2) continue;
                    var held=List.of(Math.min(a,b),Math.max(a,b));
                    if(seen.add(held)) offers.add(new Offer(next,"chi",held,g.open()));
                }
            }
        }
        nextOffer();
    }
    private void nextOffer() {
        if(!offers.isEmpty()) turn=offers.getFirst().seat;
        else draw((source+1)%rules.seats(),false);
    }
    private void claim(Move move) {
        var chosen=offers.getFirst();
        if(move.action().equals("chi")) {
            var cards=move.cards().stream().sorted().toList();
            chosen=offers.stream().filter(o->o.seat==turn && o.action.equals("chi") && o.held.equals(cards))
                    .findFirst().orElseThrow(()->new IllegalArgumentException("请选择能与弃牌成组的两张手牌"));
        }
        var group=new ArrayList<>(chosen.held);
        take(turn,group); group.add(discarded); Collections.sort(group);
        exposed.get(turn).add(new Exposed(List.copyOf(group),chosen.score,false));
        rivers.get(source).removeLast(); offers.clear();
        if(move.action().equals("exposedKong")) draw(turn,true); else mustDiscard=true;
    }
    private void ownKong(int tile) {
        if(!kong(turn,tile)) throw new IllegalArgumentException("所选牌不能开杠");
        var groups=exposed.get(turn);
        var prior=groups.stream().filter(g->pongOf(g,tile)).findFirst();
        if(prior.isPresent()) groups.remove(prior.get());
        var quad=new ArrayList<Integer>();
        if(prior.isPresent()) {
            quad.addAll(prior.get().cards); quad.add(tile); take(turn,List.of(tile));
        } else {
            quad.addAll(matching(turn,tile).subList(0,4)); take(turn,quad);
        }
        groups.add(new Exposed(List.copyOf(quad),rules.face(tile)>16?9:6,prior.isEmpty())); draw(turn,true);
    }
    private void draw(int seat,boolean replacement) {
        if(draw>=back) {done=true;return;}
        turn=seat; mustDiscard=false;
        hands.get(turn).add(replacement?deck.get(--back):deck.get(draw++));
    }
    private void settle(boolean self) {
        int value=win(turn,self);
        if(value<0) throw new IllegalArgumentException("尚未达到胡牌条件");
        if(rules==MeldRules.LIUZHOU || rules==MeldRules.CHUOXIA) {
            int count=rules==MeldRules.LIUZHOU?2:1;
            birds=deck.subList(draw,Math.min(back,draw+count));
            for(int c:birds) {
                if(rules==MeldRules.CHUOXIA) value+=c==65?9:c&15;
                else if(c==49 || c==53 || c<49 && List.of(1,5,9).contains(c&15)) value++;
            }
        }
        if(self && rules.mahjong()) value*=2;
        for(int i=0;i<points.length;i++) if(i!=turn && (self || i==source)) {
            points[i]-=value; points[turn]+=value;
        }
        done=true; winner=turn; selfDraw=self; offers.clear();
    }
    public Map<String,Object> board(int viewer) {
        var groups=new ArrayList<>();
        for(int i=0;i<rules.seats();i++) {
            var visible=new ArrayList<List<Integer>>();
            for(var g:exposed.get(i)) visible.add(g.concealed && viewer!=i && !done?Collections.nCopies(4,0):g.cards);
            groups.add(visible);
        }
        var board=new LinkedHashMap<String,Object>();
        board.put("wall",back-draw); board.put("rivers",rivers); board.put("groups",groups);
        board.put("discard",discarded); board.put("source",source); board.put("winner",winner); board.put("birds",birds);
        board.put("chi",offers.stream().filter(o->o.seat==viewer && o.action.equals("chi")).map(Offer::held).toList());
        if(done) {
            board.put("outcome",winner<0?"牌堆耗尽，流局":(winner+1)+"座"+(selfDraw?"自摸":"胡"+(source+1)+"座弃牌"));
            if(winner>=0) {
                var winning=new ArrayList<>(hands.get(winner));
                if(!selfDraw) winning.add(discarded);
                board.put("winningHand",winning);
            }
        }
        return board;
    }
    public int nextStarter(java.util.random.RandomGenerator random) { return winner<0?dealer:winner; }
}
