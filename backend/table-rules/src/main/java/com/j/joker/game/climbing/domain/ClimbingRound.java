package com.j.joker.game.climbing.domain;

import com.j.joker.game.tables.domain.FriendRound;
import java.util.*;

public final class ClimbingRound implements FriendRound {
    private final ClimbingRules rules;
    private final List<List<Integer>> hands = new ArrayList<>();
    private final int[] team = new int[2];
    private int turn, leader, passed, pot, finisher = -1;
    private List<Integer> last = List.of();
    private Play lead;

    ClimbingRound(ClimbingRules rules, List<Integer> deck, int first) {
        this.rules = rules;
        this.turn = this.leader = first;
        for (int i = 0; i < 4; i++) hands.add(new ArrayList<>());
        for (int i = 0; i < deck.size(); i++) hands.get(i%4).add(deck.get(i));
    }
    private record Play(int category, int size, int high) {
        boolean beats(Play p) {
            if (p == null) return true;
            if (category != p.category) return category >= 5 && category > p.category;
            if (size != p.size) return category == 7 && size > p.size;
            return high > p.high;
        }
    }
    private static int rank(int c) { int p = c & 15; return p < 3 ? p+13 : p; }
    private Play classify(List<Integer> cards) {
        if (cards.isEmpty()) throw new IllegalArgumentException("请选择出牌");
        var freq = new TreeMap<Integer,Integer>();
        cards.forEach(c -> freq.merge(rank(c),1,Integer::sum));
        int n = cards.size(), high = freq.lastKey();
        if (freq.size() == 1) return new Play(n >= 4 ? 7 : n-1,n,high);
        if (rules.fiveTenKing && n == 3 && freq.keySet().equals(Set.of(5,10,13))) {
            int suit = cards.getFirst()/16;
            boolean suited = cards.stream().allMatch(c -> c/16 == suit);
            return new Play(suited ? 6 : 5,n,suited ? suit : 0);
        }
        int count = freq.firstEntry().getValue();
        if (high < 15 && high-freq.firstKey()+1 == freq.size() && freq.values().stream().allMatch(v -> v == count)) {
            if (count == 1 && n >= 5) return new Play(3,n,high);
            if (count == 2 && n >= 4) return new Play(4,n,high);
        }
        throw new IllegalArgumentException("牌型不合本桌规则");
    }
    private static int value(int c) { return switch(c & 15) { case 5 -> 5; case 10,13 -> 10; default -> 0; }; }
    public int currentSeat() { return turn; }
    public String phase() { return finisher < 0 ? "PLAY" : "FINISHED"; }
    public List<Integer> hand(int seat) { return List.copyOf(hands.get(seat)); }
    public List<String> actions(int seat) {
        if (seat != turn || finisher >= 0) return List.of();
        return lead == null ? List.of("play","auto") : List.of("play","pass","auto");
    }
    public void apply(Move move) {
        if (!actions(move.seat()).contains(move.action())) throw new IllegalArgumentException("出牌顺序有误");
        if (move.action().equals("auto")) { apply(automatic(turn)); return; }
        if (move.action().equals("pass")) {
            if (!move.cards().isEmpty()) throw new IllegalArgumentException("过牌无需选牌");
            if (++passed == 3) { closeTrick(); turn = leader; return; }
        } else {
            var rest = new ArrayList<>(hands.get(turn));
            for (int c : move.cards()) if (!rest.remove((Integer)c)) throw new IllegalArgumentException("所选牌不在手中");
            Play play = classify(move.cards());
            if (!play.beats(lead)) throw new IllegalArgumentException("需要压过上一手");
            hands.set(turn,rest);
            lead = play; last = move.cards(); passed = 0; leader = turn;
            pot += last.stream().mapToInt(ClimbingRound::value).sum();
            if (rest.isEmpty()) {
                finisher = turn;
                pot += 20 + hands.stream().flatMap(Collection::stream).mapToInt(ClimbingRound::value).sum();
                closeTrick(); return;
            }
        }
        turn = (turn+1)%4;
    }
    private void closeTrick() {
        team[leader%2] += pot + (lead.category == 7 ? rules.bombPrize : 0);
        pot = 0; passed = 0; lead = null; last = List.of();
    }
    public Move automatic(int seat) {
        var sorted = hands.get(seat).stream().sorted(Comparator.comparingInt(ClimbingRound::rank)).toList();
        var groups = new LinkedHashMap<Integer,List<Integer>>();
        sorted.forEach(c -> groups.computeIfAbsent(rank(c), k -> new ArrayList<>()).add(c));
        for (var group : groups.values()) {
            int n = lead == null ? group.size() : Math.min(group.size(), lead.size);
            for (int size = n; size <= group.size(); size++) {
                var cards = group.subList(0,size);
                if (classify(cards).beats(lead)) return new Move(seat,"play",cards);
            }
        }
        return new Move(seat,"pass",List.of());
    }
    public List<Integer> points() {
        int score = team[0]-team[1];
        return List.of(score,-score,score,-score);
    }
    public Map<String,Object> board(int viewer) {
        return Map.of("summary","一三座 "+team[0]+" 分 · 二四座 "+team[1]+" 分 · 本墩 "+pot+" 分",
                "lead",last,"leader",leader,"outcome",finisher<0?"":(finisher+1)+"座先出完，一三座 "+team[0]+" 分，二四座 "+team[1]+" 分");
    }
    public int nextStarter(java.util.random.RandomGenerator random) { return finisher; }
}
