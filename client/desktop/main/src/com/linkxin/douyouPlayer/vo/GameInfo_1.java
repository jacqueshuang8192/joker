package com.linkxin.douyouPlayer.vo;

import java.util.List;

public class GameInfo{

    /**
     * code : ddz
     * danLosePoint : -5
     * danTiePoint : 0
     * danWinPoint : 10
     * freeGamePhoto : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/game1.png
     * gameId : 1
     * isFreeGame : 1
     * name : ������
     * photo : doudizhu
     * playerCount : 123
     * status : 2
     * type : 0
     */

    private String code;
    private int danLosePoint;
    private int danTiePoint;
    private int danWinPoint;
    private String freeGamePhoto;
    private String gameId;
    private int isFreeGame;
    private String name;
    private String photo;
    private int playerCount;
    private String status;
    private int type;
    private List<GameChip> groupGameList;

	public List<GameChip> getGameChips() {
		return groupGameList;
	}

	public void setGameChips(List<GameChip> groupGameList) {
		this.groupGameList = groupGameList;
	}

	public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public int getDanLosePoint() {
        return danLosePoint;
    }

    public void setDanLosePoint(int danLosePoint) {
        this.danLosePoint = danLosePoint;
    }

    public int getDanTiePoint() {
        return danTiePoint;
    }

    public void setDanTiePoint(int danTiePoint) {
        this.danTiePoint = danTiePoint;
    }

    public int getDanWinPoint() {
        return danWinPoint;
    }

    public void setDanWinPoint(int danWinPoint) {
        this.danWinPoint = danWinPoint;
    }

    public String getFreeGamePhoto() {
        return freeGamePhoto;
    }

    public void setFreeGamePhoto(String freeGamePhoto) {
        this.freeGamePhoto = freeGamePhoto;
    }

    public String getGameId() {
        return gameId;
    }

    public void setGameId(String gameId) {
        this.gameId = gameId;
    }

    public int getIsFreeGame() {
        return isFreeGame;
    }

    public void setIsFreeGame(int isFreeGame) {
        this.isFreeGame = isFreeGame;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhoto() {
        return photo;
    }

    public void setPhoto(String photo) {
        this.photo = photo;
    }

    public int getPlayerCount() {
        return playerCount;
    }

    public void setPlayerCount(int playerCount) {
        this.playerCount = playerCount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }
}
