package com.j.joker.game.landlord.domain;

import com.j.joker.game.tables.domain.FriendRound;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.LinkedHashMap;

/** 三人房卡说明中的首局，房主首叫。 */
public final class LandlordTable implements FriendRound {
    private final LandlordRound round;
    private List<Integer> lead = List.of();
    private int leader = -1;

    private final boolean openGame;
    private final boolean[] open=new boolean[3], doubled=new boolean[3];
    private int choosing=-1;
    public LandlordTable(List<Integer> deck,int first) { this(deck,first,false); }
    public LandlordTable(List<Integer> deck,int first,boolean openGame) {
        round = new LandlordRound(first, deck);
        this.openGame=openGame;
    }
    public int nextStarter(java.util.random.RandomGenerator random) {
        return round.winner() == round.landlord() ? round.winner() : (round.landlord()+1+random.nextInt(2))%3;
    }
    public String phase() { return choosing<0 ? round.phase().name() : "DOUBLE"; }
    public int currentSeat() { return choosing<0 ? round.turn() : choosing; }
    public List<Integer> hand(int seat) { return round.hand(seat); }
    public List<Integer> points() {
        var scores=new ArrayList<>(round.points());
        int landlord=round.landlord(), total=0;
        for(int i=0;i<3;i++) if(i!=landlord) {
            int net=scores.get(i)*factor(i)*factor(landlord);
            scores.set(i,net); total-=net;
        }
        scores.set(landlord,total);
        return scores;
    }
    private int factor(int seat) { return open[seat]?4:doubled[seat]?2:1; }
    public Map<String,Object> board(int viewer) {
        var board=new LinkedHashMap<String,Object>(Map.of("bottom", round.publicBottom(), "landlord", round.landlord(), "multiplier", round.multiplier(),
                "lead", lead, "leader", leader));
        if(openGame) {
            var visible=new ArrayList<List<Integer>>();
            for(int i=0;i<3;i++) visible.add(open[i]?hand(i):List.of());
            board.put("openHands",visible);
            board.put("factors",List.of(factor(0),factor(1),factor(2)));
        }
        return board;
    }
    public List<String> actions(int seat) {
        if (seat != currentSeat()) return List.of();
        if (choosing>=0) return List.of("normal","double","openDouble");
        return switch (round.phase()) {
            case CALL -> List.of("call1","call3","decline");
            case ROB -> List.of("rob","decline");
            case PLAY -> seat == leader || lead.isEmpty() ? List.of("play") : List.of("play","pass");
            default -> List.of();
        };
    }

    public Move automatic(int seat) {
        if(choosing>=0) return new Move(seat,"normal",List.of());
        return switch (round.phase()) {
            case CALL -> new Move(seat,"call1",List.of());
            case ROB -> new Move(seat,"decline",List.of());
            case PLAY -> actions(seat).contains("pass") ? new Move(seat,"pass",List.of())
                    : new Move(seat,"play", List.of(hand(seat).getFirst()));
            default -> throw new IllegalStateException("本局已结束");
        };
    }

    public void apply(Move m) {
        int seat = m.seat();
        if(choosing>=0) {
            if(!actions(seat).contains(m.action()) || !m.cards().isEmpty()) throw new IllegalArgumentException("加倍选择无效");
            doubled[seat]=m.action().equals("double");
            open[seat]=m.action().equals("openDouble");
            choosing=(choosing+1)%3;
            if(choosing==round.landlord()) choosing=-1;
            return;
        }
        var before=round.phase();
        switch (m.action()) {
            case "call1", "call3" -> round.call(seat, m.action().equals("call1") ? 1 : 3);
            case "decline" -> {
                if (round.phase() == LandlordRound.Phase.CALL) round.call(seat, 0);
                else round.rob(seat, false);
            }
            case "rob" -> round.rob(seat, true);
            case "pass" -> {
                round.pass(seat);
                if (round.turn() == leader) lead = List.of();
            }
            case "play" -> { round.play(seat, m.cards()); lead = m.cards(); leader = seat; }
            default -> throw new IllegalArgumentException("未知斗地主操作");
        }
        if(openGame && before==LandlordRound.Phase.ROB && round.phase()==LandlordRound.Phase.PLAY) choosing=round.landlord();
    }
}
