package com.j.joker.game.runfast.domain;

import com.j.joker.game.tables.domain.FriendRound;
import java.util.*;

public final class RunFastRound implements FriendRound {
    private final List<List<Integer>> hands = new ArrayList<>();
    private final int seats;
    private final int[] floats;
    private int floatSeat;
    private final int[] bombs;
    private int turn, leader = -1, winner = -1;
    private RunFastPlay previous;
    private List<Integer> lead = List.of();

    public RunFastRound(List<Integer> deck,int first) {
        this(deck,first,3,false);
    }
    public RunFastRound(List<Integer> deck,int first,int seats,boolean floating) {
        if(seats!=2 && seats!=3) throw new IllegalArgumentException("跑得快仅支持两人或三人");
        this.seats=seats; bombs=new int[seats]; floats=new int[seats];
        floatSeat=floating?0:-1;
        for(int i=0;i<seats;i++) hands.add(new ArrayList<>());
        if (deck.size() != 48 || new HashSet<>(deck).size() != 48 || !deck.contains(0x33))
            throw new IllegalArgumentException("跑得快需要包含黑桃三的 48 张牌");
        int aces = 0, twos = 0;
        for (int i = 0; i < deck.size(); i++) {
            int card = deck.get(i), pip = card & 15;
            if (card < 1 || card > 0x3d || pip == 0 || pip > 13) throw new IllegalArgumentException("跑得快牌码有误");
            if (pip == 1) aces++;
            if (pip == 2) twos++;
            if(i<16*seats) {
                hands.get(i % seats).add(card);
                if (card == 0x33) turn = i % seats;
            }
        }
        if (first >= 0) turn = first;
        if (aces != 3 || twos != 1) throw new IllegalArgumentException("跑得快牌堆有误");
    }
    public String phase() { return floatSeat>=0 ? "FLOAT" : winner < 0 ? "PLAY" : "FINISHED"; }
    public int nextStarter(java.util.random.RandomGenerator random) { return winner; }
    public int currentSeat() { return floatSeat>=0?floatSeat:turn; }
    public List<Integer> hand(int seat) { return List.copyOf(hands.get(seat)); }
    public Map<String,Object> board(int viewer) { return Map.of("lead", lead, "leader", leader, "bombs", bombs.clone(),"floats", floats.clone()); }
    public List<String> actions(int seat) {
        if (floatSeat>=0) return seat==floatSeat?List.of("float0","float1","float2"):List.of();
        if (seat != turn || winner >= 0) return List.of();
        return previous == null ? List.of("play", "auto") : List.of("play","pass","auto");
    }
    public List<Integer> points() {
        var players = new ArrayList<RunFastScore.Seat>();
        for (int i = 0; i < seats; i++) players.add(new RunFastScore.Seat(i+1, hands.get(i).size(), bombs[i]));
        var score = RunFastScore.settle(players, 1);
        var result = new ArrayList<Integer>();
        for (int i=0;i<seats;i++) result.add(score.get(i+1).intValue());
        for (int i=0;i<seats;i++) if(i!=winner) {
            int extra=floats[i]+floats[winner];
            result.set(i,result.get(i)-extra); result.set(winner,result.get(winner)+extra);
        }
        return result;
    }

    private boolean legal(List<Integer> cards) {
        var all = hands.get(turn);
        boolean last = cards.size() == all.size();
        var play = RunFastPlay.classify(cards, last);
        if (play == null || !play.beats(previous, last)) return false;
        if (!last) {
            var finish = RunFastPlay.classify(all, true);
            if (finish != null && finish.beats(previous, true)) return false;
        }
        return play.kind() != RunFastPlay.Kind.SINGLE || hands.get((turn+1)%seats).size() != 1 ||
                all.stream().noneMatch(c -> RunFastPlay.rank(c) > play.high());
    }

    /** 查找可跟的第一手，先检查整手；按张数跳过无关的组合。 */
    public Move automatic(int seat) {
        if(floatSeat>=0) return new Move(seat,"float0",List.of());
        var hand = hands.get(turn);
        if (legal(hand)) return new Move(seat,"play",hand);
        for (int size = 1; size < hand.size(); size++) {
            if (previous != null && size != previous.size() && size != 4) continue;
            var result = find(hand, 0, size, new ArrayList<>());
            if (result != null) return new Move(seat,"play",result);
        }
        return new Move(seat,"pass",List.of());
    }

    private List<Integer> find(List<Integer> hand, int start, int left, ArrayList<Integer> selected) {
        if (left == 0) return legal(selected) ? List.copyOf(selected) : null;
        // 牌型不区分花色，在同一层只尝试每个点数一次。
        int tried = 0;
        for (int i = start; i <= hand.size() - left; i++) {
            int card = hand.get(i), bit = 1 << RunFastPlay.rank(card);
            if ((tried & bit) != 0) continue;
            tried |= bit;
            selected.add(card);
            var result = find(hand, i+1, left-1, selected);
            selected.removeLast();
            if (result != null) return result;
        }
        return null;
    }

    public void apply(Move m) {
        if(floatSeat>=0) {
            if(!actions(m.seat()).contains(m.action()) || !m.cards().isEmpty()) throw new IllegalArgumentException("飘分选择无效");
            floats[floatSeat++]=m.action().charAt(5)-'0';
            if(floatSeat==seats) floatSeat=-1;
            return;
        }
        if (winner >= 0 || turn != m.seat()) throw new IllegalStateException("尚未轮到此玩家");
        if (m.action().equals("pass")) {
            if (previous == null || !automatic(turn).action().equals("pass")) throw new IllegalArgumentException("有牌可出，不能过牌");
            turn = (turn+1)%seats;
            if (turn == leader) {
                if (previous.kind() == RunFastPlay.Kind.BOMB) bombs[leader]++;
                previous = null;
                lead = List.of();
            }
            return;
        }
        var cards = m.cards();
        var hand = hands.get(turn);
        if (!m.action().equals("play") || cards.isEmpty() || new HashSet<>(cards).size() != cards.size() ||
                !hand.containsAll(cards) || !legal(cards)) throw new IllegalArgumentException("所选牌不符合本桌出牌规则");
        previous = RunFastPlay.classify(cards, cards.size() == hand.size());
        lead = cards;
        leader = turn;
        hand.removeAll(cards);
        if (hand.isEmpty()) {
            winner = turn;
            if (previous.kind() == RunFastPlay.Kind.BOMB) bombs[turn]++;
        } else turn = (turn+1)%seats;
    }
}
