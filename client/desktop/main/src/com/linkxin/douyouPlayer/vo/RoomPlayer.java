package com.linkxin.douyouPlayer.vo;

import java.util.List;

/**
 * Created by lxy on 2016/4/20.
 */
public class RoomPlayer {
    private List<Player> players;
    private List<Player> micPlayers;

    private List<Player> fmPlayers;

    private List<Player> defendPlayers;

    public List<Player> getPlayers() {
        return players;
    }

    public void setPlayers(List<Player> players) {
        this.players = players;
    }

    public List<Player> getMicPlayers() {
        return micPlayers;
    }

    public void setMicPlayers(List<Player> micPlayers) {
        this.micPlayers = micPlayers;
    }

    public List<Player> getFmPlayers() {
        return fmPlayers;
    }

    public void setFmPlayers(List<Player> fmPlayers) {
        this.fmPlayers = fmPlayers;
    }

    public List<Player> getDefendPlayers() {
        return defendPlayers;
    }

    public void setDefendPlayers(List<Player> defendPlayers) {
        this.defendPlayers = defendPlayers;
    }
}
