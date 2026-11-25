package com.j.joker.game.mahjong.domain;

import com.j.joker.game.tables.domain.FriendRound;
import java.util.*;

/** 308 四人红中房，房主起庄，按房间配置抓鸟。不吃，可一炮多响。 */
public final class HongzhongRound implements FriendRound {
    private final List<List<Integer>> hands = new ArrayList<>(), rivers = new ArrayList<>();
    private final List<List<HongzhongHand.Meld>> melds = new ArrayList<>();
    private final List<List<Boolean>> concealed = new ArrayList<>();
    private final List<Integer> wall;
    private final boolean[] missed = new boolean[4];
    private final int[] scores = new int[4];
    private final Map<Integer,List<String>> offers = new LinkedHashMap<>();
    private final Map<Integer,String> answers = new LinkedHashMap<>();
    private List<Integer> birds = List.of(), winners = List.of();
    private final int dealer;
    private final HongzhongOptions options;
    private int turn, source, discard, drawn, back;
    private boolean finished, opening, afterPong;

    public HongzhongRound(List<Integer> deck) { this(deck,0,HongzhongOptions.DEFAULT); }
    public HongzhongRound(List<Integer> deck,int dealer,HongzhongOptions options) {
        this.options=options;
        this.dealer = this.turn = dealer;
        if (deck.size() != (options.red()?112:108)) throw new IllegalArgumentException("牌堆张数与红中配置不符");
        var counts = new HashMap<Integer,Integer>();
        for (int tile : deck) {
            if ((tile != HongzhongHand.RED || !options.red()) && (tile < 1 || tile > 0x29 || (tile & 15) < 1 || (tile & 15) > 9)
                    || counts.merge(tile,1,Integer::sum) > 4) throw new IllegalArgumentException("红中牌堆有误");
        }
        wall = List.copyOf(deck);
        back = wall.size();
        for (int i=0; i<4; i++) {
            hands.add(new ArrayList<>()); rivers.add(new ArrayList<>());
            melds.add(new ArrayList<>()); concealed.add(new ArrayList<>());
        }
        for (int i=0; i<52; i++) hands.get(i%4).add(wall.get(drawn++));
        hands.get(dealer).add(wall.get(drawn++));
        for (int i=0; i<4; i++) {
            if (Collections.frequency(hands.get(i),HongzhongHand.RED) == 4) {
                opening = true;
                turn = i;
            }
        }
    }
    public String phase() { return finished ? "FINISHED" : offers.isEmpty() ? "DISCARD" : "CLAIM"; }
    public int nextStarter(java.util.random.RandomGenerator random) {
        if (winners.isEmpty()) return dealer;
        return winners.size() > 1 ? source : winners.getFirst();
    }
    public int currentSeat() { return turn; }
    public List<Integer> hand(int seat) { return List.copyOf(hands.get(seat)); }
    public List<Integer> points() { return Arrays.stream(scores).boxed().toList(); }
    public Map<String,Object> board(int viewer) {
        var visible = new ArrayList<>();
        for (int seat=0; seat<4; seat++) {
            var groups = new ArrayList<>();
            for (int i=0; i<melds.get(seat).size(); i++) {
                var group = melds.get(seat).get(i);
                groups.add(Map.of("tile", concealed.get(seat).get(i) && seat != viewer ? 0 : group.tile(),
                        "copies",group.copies()));
            }
            visible.add(groups);
        }
        return Map.of("wall",back-drawn,"rivers",rivers,"melds",visible,"birds",birds,
                "winners",winners,"discard",discard,"source",source,"dealer",dealer);
    }

    public List<String> actions(int seat) {
        if (finished || seat != turn) return List.of();
        if (opening) return List.of("win","skip");
        if (!offers.isEmpty()) return offers.get(turn);
        var actions = new ArrayList<>(List.of("discard"));
        var hand = hands.get(turn);
        if (!afterPong && HongzhongHand.wins(hand,melds.get(turn),options.red(),false)) actions.add("win");
        if (!afterPong && drawn < back && hand.stream().anyMatch(t -> kongType(t) > 0)) actions.add("kong");
        return actions;
    }

    private int kongType(int tile) {
        if (tile == HongzhongHand.RED) return 0;
        int copies = Collections.frequency(hands.get(turn),tile);
        if (copies == 4) return 4;
        if (copies == 1 && melds.get(turn).contains(new HongzhongHand.Meld(tile,3))) return 1;
        return 0;
    }
    public Move automatic(int seat) {
        var options = actions(seat);
        if (options.contains("win")) return new Move(seat,"win",List.of());
        if (options.contains("skip")) return new Move(seat,"skip",List.of());
        return new Move(seat,"discard",List.of(hands.get(seat).getLast()));
    }

    public void apply(Move m) {
        if (!actions(m.seat()).contains(m.action())) throw new IllegalArgumentException("当前不能执行此操作");
        if (opening) {
            opening = false;
            if (m.action().equals("win")) settle(List.of(turn),-1);
            else turn = dealer;
        } else if (!offers.isEmpty()) {
            if (offers.get(turn).contains("win") && !m.action().equals("win")) missed[turn] = true;
            answers.put(turn,m.action());
            turn = offers.keySet().stream().filter(i -> !answers.containsKey(i)).findFirst().orElse(-1);
            if (turn < 0) resolve();
        } else if (m.action().equals("win")) {
            settle(List.of(turn),-1);
        } else {
            if (m.cards().size() != 1 || !hands.get(turn).contains(m.cards().getFirst()))
                throw new IllegalArgumentException("请选择自己的一张牌");
            int tile = m.cards().getFirst();
            if (m.action().equals("kong")) ownKong(tile);
            else discard(tile);
        }
    }

    private void discard(int tile) {
        afterPong = false;
        source = turn;
        discard = tile;
        hands.get(turn).remove(Integer.valueOf(tile));
        rivers.get(turn).add(tile);
        for (int offset=1; offset<=3; offset++) {
            int seat = (source+offset)%4;
            var test = new ArrayList<>(hands.get(seat));
            test.add(tile);
            var choices = new ArrayList<String>();
            if (!missed[seat] && HongzhongHand.wins(test,melds.get(seat),options.red(),false)) choices.add("win");
            int copies = Collections.frequency(hands.get(seat),tile);
            if (tile != HongzhongHand.RED && copies >= 2) choices.add("pong");
            if (tile != HongzhongHand.RED && copies == 3 && drawn < back) choices.add("exposedKong");
            if (!choices.isEmpty()) {
                choices.add("skip");
                offers.put(seat,List.copyOf(choices));
            }
        }
        if (offers.isEmpty()) draw((source+1)%4,false);
        else turn = offers.keySet().iterator().next();
    }

    private void resolve() {
        var claims = new LinkedHashMap<>(answers);
        offers.clear(); answers.clear();
        var wins = claims.keySet().stream().filter(i -> claims.get(i).equals("win")).toList();
        if (!wins.isEmpty()) { settle(wins,source); return; }
        for (var entry : claims.entrySet()) {
            if (entry.getValue().equals("skip")) continue;
            turn = entry.getKey();
            boolean kong = entry.getValue().equals("exposedKong");
            reveal(discard, kong ? 4 : 3, kong ? 3 : 2, false);
            rivers.get(source).removeLast();
            if (kong) {
                transfer(source,turn,3);
                draw(turn,true);
            } else afterPong = true;
            return;
        }
        draw((source+1)%4,false);
    }

    private void ownKong(int tile) {
        int kind = kongType(tile);
        if (kind == 0) throw new IllegalArgumentException("所选牌不能开杠");
        if (kind == 1) {
            var groups = melds.get(turn);
            groups.set(groups.indexOf(new HongzhongHand.Meld(tile,3)),new HongzhongHand.Meld(tile,4));
            hands.get(turn).remove(Integer.valueOf(tile));
        } else reveal(tile,4,4,true);
        for (int i=0; i<4; i++) if (i != turn) transfer(i,turn,kind == 4 ? 2 : 1);
        draw(turn,true);
    }
    private void reveal(int tile, int total, int held, boolean hidden) {
        for (int i=0; i<held; i++) hands.get(turn).remove(Integer.valueOf(tile));
        melds.get(turn).add(new HongzhongHand.Meld(tile,total));
        concealed.get(turn).add(hidden);
    }
    private void draw(int seat, boolean kong) {
        if (drawn >= back) { finished = true; return; }
        turn = seat;
        missed[turn] = false;
        afterPong = false;
        hands.get(turn).add(kong ? wall.get(--back) : wall.get(drawn++));
    }
    private void transfer(int from,int to,int points) { scores[from] -= points; scores[to] += points; }
    private void settle(List<Integer> winning, int payer) {
        winners = List.copyOf(winning);
        birds = wall.subList(drawn,Math.min(back,drawn+options.drawCount()));
        int hits = options.hits(birds);
        for (int win : winners) {
            if (payer >= 0) transfer(payer,win,1 + (payer == dealer || win == dealer ? 1 : 0) + hits);
            else for (int i=0; i<4; i++) if (i != win) transfer(i,win,2 + (win == dealer || i == dealer ? 1 : 0) + hits);
        }
        finished = true;
    }
}
