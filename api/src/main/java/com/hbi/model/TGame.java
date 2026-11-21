package com.hbi.model;

import com.hbi.vo.request.common.TLevelFenChangVo;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Transient;
import java.util.List;

@Table(name = "t_game")
public class TGame {
    @Id
    @Column(name = "game_id")
    private Long gameId;

    private Integer type;
    
    private String code;

    @Column(name = "level")
    private Integer level;

    /**
     * 是否是组局游戏：0：否；1：是
     */
    @Column(name = "is_free_game")
    private Integer isFreeGame;
    
    @Column(name = "is_gold")
    private Integer isGold;
    
    @Column(name = "min_golds")
    private Long minGolds;
    @Column(name = "max_golds")
    private Long maxGolds;

    private String photo;
    
    @Column(name = "free_game_photo")
    private String freeGamePhoto;

    private String name;

    private String remark;
    
    private String status;
    
    @Column(name = "jetton_exchange_ratio")
    private Float jettonExchangeRatio;
//    @Transient
//    private List<TQuickGame> chipList;

    @Transient
    private List<TGroupGame> groupGameList;
    
    /**
     * 每局胜利增加段位积分
     */
    @Column(name="dan_win_point")
    private Integer danWinPoint;
    
    /**
     * 每局失败减少段位积分
     */
    @Column(name="dan_lose_point")
    private Integer danLosePoint;
    
    /**
     * 每局平局变化段位积分
     */
    @Column(name="dan_tie_point")
    private Integer danTiePoint;

    /**
     * 是否显示在首页
     */
    @Column(name="is_main_page")
    private Integer isMainPage;
    @Column(name="game_type")
    private String gameType;

    @Column(name="is_show")
    private Integer isShow;

    @Column(name="dizhu")
    private Integer dizhu;

    @Column(name = "min_coins_gold")
    private Integer minCoinsGold;

    @Column(name = "max_player_count")
    private Integer maxPlayerCount;


    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    @Transient
    private Integer playerCount;

    public String getGameType() {
		return gameType;
	}

	public void setGameType(String gameType) {
		this.gameType = gameType;
	}

	@Transient
    private String version;

    @Transient
    private List<TLevelFenChangVo> fenchang;

    public List<TLevelFenChangVo> getFenchang() {
        return fenchang;
    }

    public void setFenchang(List<TLevelFenChangVo> fenchang) {
        this.fenchang = fenchang;
    }

    /**
     * @return game_id
     */
    public Long getGameId() {
        return gameId;
    }

    /**
     * @param gameId
     */
    public void setGameId(Long gameId) {
        this.gameId = gameId;
    }

    /**
     * 获取0：玩家游戏；1：主播游戏
     *
     * @return type - 0：玩家游戏；1：主播游戏
     */
    public Integer getType() {
        return type;
    }

    /**
     * 设置0：玩家游戏；1：主播游戏
     *
     * @param type 0：玩家游戏；1：主播游戏
     */
    public void setType(Integer type) {
        this.type = type;
    }

    /**
     * @return photo
     */
    public String getPhoto() {
        return photo;
    }

    /**
     * @param photo
     */
    public void setPhoto(String photo) {
        this.photo = photo;
    }

    /**
     * @return name
     */
    public String getName() {
        return name;
    }

    /**
     * @param name
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * @return remark
     */
    public String getRemark() {
        return remark;
    }

    public Integer getDizhu() {
        return dizhu;
    }

    public void setDizhu(Integer dizhu) {
        this.dizhu = dizhu;
    }

    /**
     * @param remark
     */


    public void setRemark(String remark) {
        this.remark = remark;
    }

    public Integer getPlayerCount() {
        return playerCount;
    }

    public void setPlayerCount(Integer playerCount) {
        this.playerCount = playerCount;
    }

    public Integer getDanWinPoint() {
        return danWinPoint;
    }

    public void setDanWinPoint(Integer danWinPoint) {
        this.danWinPoint = danWinPoint;
    }

    public Integer getDanLosePoint() {
        return danLosePoint;
    }

    public void setDanLosePoint(Integer danLosePoint) {
        this.danLosePoint = danLosePoint;
    }

    public Integer getDanTiePoint() {
        return danTiePoint;
    }

    public void setDanTiePoint(Integer danTiePoint) {
        this.danTiePoint = danTiePoint;
    }

    public Float getJettonExchangeRatio() {
        return jettonExchangeRatio;
    }

    public void setJettonExchangeRatio(Float jettonExchangeRatio) {
        this.jettonExchangeRatio = jettonExchangeRatio;
    }

//    public List<TQuickGame> getChipList() {
//        return chipList;
//    }
//
//    public void setChipList(List<TQuickGame> chipList) {
//        this.chipList = chipList;
//    }

    public Integer getIsFreeGame() {
        return isFreeGame;
    }

    public Long getMaxGolds() {
		return maxGolds;
	}

	public void setMaxGolds(Long maxGolds) {
		this.maxGolds = maxGolds;
	}

	public void setIsFreeGame(Integer isFreeGame) {
        this.isFreeGame = isFreeGame;
    }

    public String getFreeGamePhoto() {
        return freeGamePhoto;
    }

    public void setFreeGamePhoto(String freeGamePhoto) {
        this.freeGamePhoto = freeGamePhoto;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public List<TGroupGame> getGroupGameList() {
        return groupGameList;
    }

    public void setGroupGameList(List<TGroupGame> groupGameList) {
        this.groupGameList = groupGameList;
    }

    public Integer getIsMainPage() {
        return isMainPage;
    }

    public void setIsMainPage(Integer isMainPage) {
        this.isMainPage = isMainPage;
    }

    public Integer getIsShow() {
        return isShow;
    }

    public Integer getIsGold() {
		return isGold;
	}

	public void setIsGold(Integer isGold) {
		this.isGold = isGold;
	}

	public Long getMinGolds() {
		return minGolds;
	}

	public void setMinGolds(Long minGolds) {
		this.minGolds = minGolds;
	}

	public void setIsShow(Integer isShow) {
        this.isShow = isShow;
    }

    public Integer getMinCoinsGold() {
        return minCoinsGold;
    }

    public void setMinCoinsGold(Integer minCoinsGold) {
        this.minCoinsGold = minCoinsGold;
    }

    public Integer getMaxPlayerCount() {
        return maxPlayerCount;
    }

    public void setMaxPlayerCount(Integer maxPlayerCount) {
        this.maxPlayerCount = maxPlayerCount;
    }
}