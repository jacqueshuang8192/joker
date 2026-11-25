package com.j.joker.game.landlord.domain;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.random.RandomGenerator;

/** 旧大厅房卡说明的一局三人斗地主。座位 0、1、2 按出牌方向编号。 */
public final class LandlordRound {
    public enum Phase { CALL, ROB, PLAY, REDEAL, FINISHED }

    private final List<List<Integer>> hands = List.of(new ArrayList<>(), new ArrayList<>(), new ArrayList<>());
    private final List<Integer> bottom;
    private final int firstCaller;
    private int turn;
    private int landlord = -1;
    private int caller = -1;
    private int multiplier;
    private int winner = -1;
    private int passes;
    private LandlordPlay lead;
    private Phase phase = Phase.CALL;

    public LandlordRound(int firstCaller, List<Integer> orderedDeck) {
        if (firstCaller < 0 || firstCaller >= 3) throw new IllegalArgumentException("座位超出范围");
        if (orderedDeck.size() != 54 || new HashSet<>(orderedDeck).size() != 54)
            throw new IllegalArgumentException("发牌需要一副完整的 54 张牌");
        orderedDeck.forEach(LandlordPlay::rank);
        this.turn = this.firstCaller = firstCaller;
        for (int i = 0; i < 51; i++) hands.get((firstCaller + i) % 3).add(orderedDeck.get(i));
        bottom = List.copyOf(orderedDeck.subList(51, 54));
    }

    public static LandlordRound deal(int firstCaller, RandomGenerator random) {
        var deck = new ArrayList<Integer>(54);
        for (int suit = 0; suit < 4; suit++)
            for (int rank = 1; rank <= 13; rank++) deck.add(suit * 16 + rank);
        deck.add(0x4e);
        deck.add(0x4f);
        Collections.shuffle(deck, random);
        return new LandlordRound(firstCaller, deck);
    }

    public Phase phase() { return phase; }
    public int turn() { return turn; }
    public int landlord() { return phase == Phase.PLAY || phase == Phase.FINISHED ? landlord : -1; }
    public int multiplier() { return multiplier; }
    public int winner() { return winner; }
    public List<Integer> hand(int seat) { return List.copyOf(hands.get(seat)); }
    public List<Integer> publicBottom() { return landlord() >= 0 ? bottom : List.of(); }

    public void call(int seat, int bid) {
        requireTurn(Phase.CALL, seat);
        if (bid != 0 && bid != 1 && bid != 3) throw new IllegalArgumentException("叫地主只能选 0、1、3");
        advance();
        if (bid == 0) {
            if (turn == firstCaller) phase = Phase.REDEAL;
        } else {
            caller = landlord = seat;
            multiplier = bid;
            phase = Phase.ROB;
        }
    }

    public void rob(int seat, boolean take) {
        requireTurn(Phase.ROB, seat);
        if (take) {
            landlord = seat;
            multiplier *= 2;
        }
        advance();
        if (turn == caller) {
            phase = Phase.PLAY;
            turn = landlord;
            hands.get(landlord).addAll(bottom);
        }
    }

    public void play(int seat, List<Integer> cards) {
        requireTurn(Phase.PLAY, seat);
        var played = LandlordPlay.of(cards);
        var hand = hands.get(seat);
        if (!hand.containsAll(cards)) throw new IllegalArgumentException("玩家没有这些牌");
        if (lead != null && !played.beats(lead)) throw new IllegalArgumentException("不能压过上一手");
        hand.removeAll(cards);
        if (played.kind() == LandlordPlay.Kind.BOMB) multiplier *= 2;
        lead = played;
        passes = 0;
        if (hand.isEmpty()) {
            winner = seat;
            phase = Phase.FINISHED;
        } else advance();
    }

    public void pass(int seat) {
        requireTurn(Phase.PLAY, seat);
        if (lead == null) throw new IllegalStateException("领出时必须出牌");
        if (++passes == 2) {
            lead = null;
            passes = 0;
        }
        advance();
    }

    /** 房卡底分为 1，每名农民分别与地主计算净分。 */
    public List<Integer> points() {
        if (phase != Phase.FINISHED) throw new IllegalStateException("本局尚未结束");
        int farmer = winner == landlord ? -multiplier : multiplier;
        var points = new ArrayList<>(Collections.nCopies(3, farmer));
        points.set(landlord, -2 * farmer);
        return List.copyOf(points);
    }

    /** 全部不叫时保留首叫座位，下一局按胜方决定首叫者。 */
    public LandlordRound nextDeal(RandomGenerator random) {
        if (phase == Phase.REDEAL) return deal(firstCaller, random);
        if (phase != Phase.FINISHED) throw new IllegalStateException("当前牌局仍在进行");
        int next = winner == landlord ? landlord : (landlord + 1 + random.nextInt(2)) % 3;
        return deal(next, random);
    }

    private void advance() { turn = (turn + 1) % 3; }

    private void requireTurn(Phase expected, int seat) {
        if (phase != expected || turn != seat) throw new IllegalStateException("阶段或操作座位不符");
    }
}
