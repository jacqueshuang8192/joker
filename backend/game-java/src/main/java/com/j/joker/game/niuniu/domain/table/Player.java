package com.j.joker.game.niuniu.domain.table;

import com.j.joker.game.niuniu.domain.card.Card;
import com.j.joker.game.niuniu.domain.card.HandResult;
import java.util.ArrayList;
import java.util.List;

/** 桌子上的一个玩家（对应 CGameUser）。 */
public final class Player {

    private final long uid;
    private int seatId = -1;
    private int sex;
    private String nickName = "";
    private String portrait = "";
    private long chips;
    private boolean robot;
    private boolean online = true;
    private boolean ready;
    private boolean autoPlay;
    private boolean banker;
    private int grabTimes;
    private int betTimes;
    private int pushLimit;
    private final List<Card> cards = new ArrayList<>();
    private HandResult hand;
    private long roundDelta;
    private long totalDelta;
    /** 外围下注：seatId -> 下注额。 */
    private final java.util.Map<Integer, Long> waiweiBets = new java.util.LinkedHashMap<>();

    public Player(long uid, String nickName, long chips, boolean robot) {
        this.uid = uid;
        this.nickName = nickName;
        this.chips = chips;
        this.robot = robot;
    }

    public void resetForRound() {
        cards.clear();
        hand = null;
        banker = false;
        grabTimes = 0;
        betTimes = 1;
        ready = false;
        roundDelta = 0;
        waiweiBets.clear();
    }

    public long uid() { return uid; }
    public int sex() { return sex; }
    public void setSex(int v) { sex = v; }
    public int seatId() { return seatId; }
    public void setSeatId(int v) { seatId = v; }
    public String nickName() { return nickName; }
    public String portrait() { return portrait; }
    public void setPortrait(String v) { portrait = v; }
    public long chips() { return chips; }
    public void addChips(long v) { chips += v; }
    public boolean robot() { return robot; }
    public boolean online() { return online; }
    public void setOnline(boolean v) { online = v; }
    public boolean ready() { return ready; }
    public void setReady(boolean v) { ready = v; }
    public boolean autoPlay() { return autoPlay; }
    public void setAutoPlay(boolean v) { autoPlay = v; }
    public boolean banker() { return banker; }
    public void setBanker(boolean v) { banker = v; }
    public int grabTimes() { return grabTimes; }
    public void setGrabTimes(int v) { grabTimes = v; }
    public int pushLimit() { return pushLimit; }
    public void setPushLimit(int value) { pushLimit = value; }
    public int betTimes() { return betTimes; }
    public void setBetTimes(int v) { betTimes = v; }
    public List<Card> cards() { return cards; }
    public HandResult hand() { return hand; }
    public void setHand(HandResult v) { hand = v; }
    public long roundDelta() { return roundDelta; }
    public void addRoundDelta(long v) { roundDelta += v; }
    public void setRoundDelta(long v) { roundDelta = v; }
    public long totalDelta() { return totalDelta; }
    public void addTotalDelta(long v) { totalDelta += v; }
    public java.util.Map<Integer, Long> waiweiBets() { return waiweiBets; }

    public String cardsText() {
        StringBuilder sb = new StringBuilder();
        for (Card c : cards) {
            if (sb.length() > 0) {
                sb.append(' ');
            }
            sb.append(c.display());
        }
        return sb.toString();
    }

    @Override
    public String toString() {
        return String.format("%s[%d] seat=%d chips=%d", nickName, uid, seatId, chips);
    }
}
