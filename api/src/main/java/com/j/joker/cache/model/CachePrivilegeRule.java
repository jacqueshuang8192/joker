package com.j.joker.cache.model;

import com.j.joker.cache.CacheModel;

public class CachePrivilegeRule extends CacheModel {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 特权类型， 平台 vip 主播
	 */
	private String type;
	
	/**
	 * 特权等级
	 */
	private String level;
	
	/**
	 * 成长值
	 */
	private Integer expiricValue;
	
	/**
     * 组局
     */
	private String canGroupGame;
	
    /**
     * 解锁表情
     */
    private String unlockMoreEmotion;
    
    /**
     * 解锁语音
     */
    private String unlockVoiceInput;
    
    /**
     * 加主播好友上限
     */
    private Integer maxCompereFriends;
    
    /**
     * 称号
     */
    private String name;
    
    /**
     * 累计充值金额
     */
    private String chargeAmount;
    
    /**
     * 尊享称号
     */
    private String vipName;
    
    /**
     * 进攻特效
     */
    private String attackEffect;
    
    /**
     * 房间内排名顺序
     */
    private String orderInRoom;
    
    /**
     * 高级道具解锁
     */
    private String unlockMoreProp;
    
    /**
     * 满人进入
     */
    private String canJoinFullRoom;
    
    /**
     * 每日任务自动完成
     */
    private String autoFinishDailyTask;
    
    /**
     * 平台等级经验加成
     */
    private String experiencePercentage;
    
    /**
     * 段位资格积分加速
     */
    private String rankAcceleration;
    
    /**
     * 段位晋级赛难度下降
     */
    private String rankDiffcult;
    
    /**
     * 守矿生命值增加
     */
    private String defenseLife;
    
    /**
     * 大奖赛参赛卡
     */
    private String grandPrixCard;
    
    /**
     * 赠送喇叭
     */
    private String giveTurpeth;
    
    /**
     * 商店折扣
     */
    private String goodsDiscount;
    
    /**
     * 礼物折扣
     */
    private String presentDiscount;
    
    /**
     * 主播等级名称
     */
    private String compereLevelName;
    
    /**
     * 累计游戏币
     */
    private Long coinAmount;
    
    /**
     * 徽章
     */
    private String badge;
    
    /**
     * 上传照片数量
     */
    private Long maxPhotoCount;
    
	//以下是各特权数值字段
	
	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getLevel() {
		return level;
	}

	public void setLevel(String level) {
		this.level = level;
	}

    public Integer getExpiricValue() {
        return expiricValue;
    }

    public void setExpiricValue(Integer expiricValue) {
        this.expiricValue = expiricValue;
    }

    public String getCanGroupGame() {
        return canGroupGame;
    }

    public void setCanGroupGame(String canGroupGame) {
        this.canGroupGame = canGroupGame;
    }

    public String getUnlockMoreEmotion() {
        return unlockMoreEmotion;
    }

    public void setUnlockMoreEmotion(String unlockMoreEmotion) {
        this.unlockMoreEmotion = unlockMoreEmotion;
    }

    public String getUnlockVoiceInput() {
        return unlockVoiceInput;
    }

    public void setUnlockVoiceInput(String unlockVoiceInput) {
        this.unlockVoiceInput = unlockVoiceInput;
    }

    public Integer getMaxCompereFriends() {
        return maxCompereFriends;
    }

    public void setMaxCompereFriends(Integer maxCompereFriends) {
        this.maxCompereFriends = maxCompereFriends;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getChargeAmount() {
        return chargeAmount;
    }

    public void setChargeAmount(String chargeAmount) {
        this.chargeAmount = chargeAmount;
    }

    public String getVipName() {
        return vipName;
    }

    public void setVipName(String vipName) {
        this.vipName = vipName;
    }

    public String getAttackEffect() {
        return attackEffect;
    }

    public void setAttackEffect(String attackEffect) {
        this.attackEffect = attackEffect;
    }

    public String getOrderInRoom() {
        return orderInRoom;
    }

    public void setOrderInRoom(String orderInRoom) {
        this.orderInRoom = orderInRoom;
    }

    public String getUnlockMoreProp() {
        return unlockMoreProp;
    }

    public void setUnlockMoreProp(String unlockMoreProp) {
        this.unlockMoreProp = unlockMoreProp;
    }

    public String getCanJoinFullRoom() {
        return canJoinFullRoom;
    }

    public void setCanJoinFullRoom(String canJoinFullRoom) {
        this.canJoinFullRoom = canJoinFullRoom;
    }

    public String getAutoFinishDailyTask() {
        return autoFinishDailyTask;
    }

    public void setAutoFinishDailyTask(String autoFinishDailyTask) {
        this.autoFinishDailyTask = autoFinishDailyTask;
    }

    public String getExperiencePercentage() {
        return experiencePercentage;
    }

    public void setExperiencePercentage(String experiencePercentage) {
        this.experiencePercentage = experiencePercentage;
    }

    public String getRankAcceleration() {
        return rankAcceleration;
    }

    public void setRankAcceleration(String rankAcceleration) {
        this.rankAcceleration = rankAcceleration;
    }

    public String getRankDiffcult() {
        return rankDiffcult;
    }

    public void setRankDiffcult(String rankDiffcult) {
        this.rankDiffcult = rankDiffcult;
    }

    public String getDefenseLife() {
        return defenseLife;
    }

    public void setDefenseLife(String defenseLife) {
        this.defenseLife = defenseLife;
    }

    public String getGrandPrixCard() {
        return grandPrixCard;
    }

    public void setGrandPrixCard(String grandPrixCard) {
        this.grandPrixCard = grandPrixCard;
    }

    public String getGiveTurpeth() {
        return giveTurpeth;
    }

    public void setGiveTurpeth(String giveTurpeth) {
        this.giveTurpeth = giveTurpeth;
    }

    public String getGoodsDiscount() {
        return goodsDiscount;
    }

    public void setGoodsDiscount(String goodsDiscount) {
        this.goodsDiscount = goodsDiscount;
    }

    public String getPresentDiscount() {
        return presentDiscount;
    }

    public void setPresentDiscount(String presentDiscount) {
        this.presentDiscount = presentDiscount;
    }

    public String getCompereLevelName() {
        return compereLevelName;
    }

    public void setCompereLevelName(String compereLevelName) {
        this.compereLevelName = compereLevelName;
    }

    public Long getCoinAmount() {
        return coinAmount;
    }

    public void setCoinAmount(Long coinAmount) {
        this.coinAmount = coinAmount;
    }

    public String getBadge() {
        return badge;
    }

    public void setBadge(String badge) {
        this.badge = badge;
    }

    public Long getMaxPhotoCount() {
        return maxPhotoCount;
    }

    public void setMaxPhotoCount(Long maxPhotoCount) {
        this.maxPhotoCount = maxPhotoCount;
    }
	
}
