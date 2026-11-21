package com.linkxin.douyouPlayer.vo;

import java.util.Comparator;

/**
 * vip等级
 * Created by lxy on 2016/5/13.
 */
public class VipLevel implements Comparator<VipLevel>{

    /**
     * attackEffect :
     * autoFinishDailyTask : 1
     * canBuyLoudspeaker : 1
     * canCaptureRegenerate : 1
     * canCaptureSpell : 1
     * canCreateDating : 1
     * canGroupGame : 1
     * canJoinFullRoom : 1
     * canQueueMic : 1
     * captureMaxCount : 12
     * captureTimes : 13
     * chargeAmount : 100000
     * content :
     充值100000元成为VIP11。100000。
     拥有VIP10的全部权限
     每天抢矿次数5次。5。
     每天抢主播次数13次。13。
     最大可抢夺主播数量12个。12。
     道具商城8.5折。8.5。
     直播间礼物9折。9。
     * defenseLife : 0.3
     * experiencePercentage : 0.6
     * giveTurpeth : 40
     * goodsDiscount : 0.85
     * id : 12
     * level : 11
     * maxCompereFriends : 50
     * maxDigCount : 5
     * name : 11
     * orderInRoom : 5
     * presentDiscount : 0.9
     * rankAcceleration : 0.6
     * unlockMoreEmotion :
     * unlockMoreProp :
     * unlockVoiceInput : 1
     * vipName : 王储
     */

    private String attackEffect;
    private String autoFinishDailyTask;
    private int canBuyLoudspeaker;
    private int canCaptureRegenerate;
    private int canCaptureSpell;
    private int canCreateDating;
    private String canGroupGame;
    private String canJoinFullRoom;
    private String canQueueMic;
    private int captureMaxCount;
    private int captureTimes;
    private int chargeAmount;
    private String content;
    private double defenseLife;
    private double experiencePercentage;
    private int giveTurpeth;
    private double goodsDiscount;
    private long id;
    private int level;
    private int maxCompereFriends;
    private int maxDigCount;
    private String name;
    private int orderInRoom;
    private double presentDiscount;
    private double rankAcceleration;
    private String unlockMoreEmotion;
    private String unlockMoreProp;
    private String unlockVoiceInput;
    private String vipName;

    public String getAttackEffect() {
        return attackEffect;
    }

    public void setAttackEffect(String attackEffect) {
        this.attackEffect = attackEffect;
    }

    public String getAutoFinishDailyTask() {
        return autoFinishDailyTask;
    }

    public void setAutoFinishDailyTask(String autoFinishDailyTask) {
        this.autoFinishDailyTask = autoFinishDailyTask;
    }

    public int getCanBuyLoudspeaker() {
        return canBuyLoudspeaker;
    }

    public void setCanBuyLoudspeaker(int canBuyLoudspeaker) {
        this.canBuyLoudspeaker = canBuyLoudspeaker;
    }

    public int getCanCaptureRegenerate() {
        return canCaptureRegenerate;
    }

    public void setCanCaptureRegenerate(int canCaptureRegenerate) {
        this.canCaptureRegenerate = canCaptureRegenerate;
    }

    public int getCanCaptureSpell() {
        return canCaptureSpell;
    }

    public void setCanCaptureSpell(int canCaptureSpell) {
        this.canCaptureSpell = canCaptureSpell;
    }

    public int getCanCreateDating() {
        return canCreateDating;
    }

    public void setCanCreateDating(int canCreateDating) {
        this.canCreateDating = canCreateDating;
    }

    public String getCanGroupGame() {
        return canGroupGame;
    }

    public void setCanGroupGame(String canGroupGame) {
        this.canGroupGame = canGroupGame;
    }

    public String getCanJoinFullRoom() {
        return canJoinFullRoom;
    }

    public void setCanJoinFullRoom(String canJoinFullRoom) {
        this.canJoinFullRoom = canJoinFullRoom;
    }

    public String getCanQueueMic() {
        return canQueueMic;
    }

    public void setCanQueueMic(String canQueueMic) {
        this.canQueueMic = canQueueMic;
    }

    public int getCaptureMaxCount() {
        return captureMaxCount;
    }

    public void setCaptureMaxCount(int captureMaxCount) {
        this.captureMaxCount = captureMaxCount;
    }

    public int getCaptureTimes() {
        return captureTimes;
    }

    public void setCaptureTimes(int captureTimes) {
        this.captureTimes = captureTimes;
    }

    public int getChargeAmount() {
        return chargeAmount;
    }

    public void setChargeAmount(int chargeAmount) {
        this.chargeAmount = chargeAmount;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public double getDefenseLife() {
        return defenseLife;
    }

    public void setDefenseLife(double defenseLife) {
        this.defenseLife = defenseLife;
    }

    public double getExperiencePercentage() {
        return experiencePercentage;
    }

    public void setExperiencePercentage(double experiencePercentage) {
        this.experiencePercentage = experiencePercentage;
    }

    public int getGiveTurpeth() {
        return giveTurpeth;
    }

    public void setGiveTurpeth(int giveTurpeth) {
        this.giveTurpeth = giveTurpeth;
    }

    public double getGoodsDiscount() {
        return goodsDiscount;
    }

    public void setGoodsDiscount(double goodsDiscount) {
        this.goodsDiscount = goodsDiscount;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getMaxCompereFriends() {
        return maxCompereFriends;
    }

    public void setMaxCompereFriends(int maxCompereFriends) {
        this.maxCompereFriends = maxCompereFriends;
    }

    public int getMaxDigCount() {
        return maxDigCount;
    }

    public void setMaxDigCount(int maxDigCount) {
        this.maxDigCount = maxDigCount;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getOrderInRoom() {
        return orderInRoom;
    }

    public void setOrderInRoom(int orderInRoom) {
        this.orderInRoom = orderInRoom;
    }

    public double getPresentDiscount() {
        return presentDiscount;
    }

    public void setPresentDiscount(double presentDiscount) {
        this.presentDiscount = presentDiscount;
    }

    public double getRankAcceleration() {
        return rankAcceleration;
    }

    public void setRankAcceleration(double rankAcceleration) {
        this.rankAcceleration = rankAcceleration;
    }

    public String getUnlockMoreEmotion() {
        return unlockMoreEmotion;
    }

    public void setUnlockMoreEmotion(String unlockMoreEmotion) {
        this.unlockMoreEmotion = unlockMoreEmotion;
    }

    public String getUnlockMoreProp() {
        return unlockMoreProp;
    }

    public void setUnlockMoreProp(String unlockMoreProp) {
        this.unlockMoreProp = unlockMoreProp;
    }

    public String getUnlockVoiceInput() {
        return unlockVoiceInput;
    }

    public void setUnlockVoiceInput(String unlockVoiceInput) {
        this.unlockVoiceInput = unlockVoiceInput;
    }

    public String getVipName() {
        return vipName;
    }

    public void setVipName(String vipName) {
        this.vipName = vipName;
    }

    @Override
    public int compare(VipLevel lhs, VipLevel rhs) {

        if (lhs.level <rhs.level){
            return -1;
        }else if (lhs.level > rhs.level){
            return 1;
        }
        return 0;
    }
}
