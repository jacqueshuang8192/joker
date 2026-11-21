//package com.hbi.model;
//
//import javax.persistence.*;
//
//@Table(name = "t_vip_level")
//public class TVipLevel {
//    @Id
//    private Integer id;
//
//    @Column(name= "level")
//    private Integer level;
//
//    private String name;
//
//    private String content;
//
//    @Column(name = "charge_amount")
//    private Integer chargeAmount;
//
//    @Column(name = "vip_name")
//    private String vipName;
//
//    @Column(name = "attack_effect")
//    private String attackEffect;
//
//    @Column(name = "order_in_room")
//    private Integer orderInRoom;
//
//    @Column(name = "can_group_game")
//    private String canGroupGame;
//
//    @Column(name = "unlock_more_emotion")
//    private String unlockMoreEmotion;
//
//    @Column(name = "unlock_voice_input")
//    private String unlockVoiceInput;
//
//    @Column(name = "unlock_more_prop")
//    private String unlockMoreProp;
//
//    @Column(name = "can_queue_mic")
//    private String canQueueMic;
//
//    @Column(name = "max_compere_friends")
//    private Integer maxCompereFriends;
//
//    @Column(name = "can_join_full_room")
//    private String canJoinFullRoom;
//
//    @Column(name = "auto_finish_daily_task")
//    private String autoFinishDailyTask;
//
//    @Column(name = "experience_percentage")
//    private Float experiencePercentage;
//
//    @Column(name = "rank_acceleration")
//    private Float rankAcceleration;
//
//    @Column(name = "rank_diffcult")
//    private Integer rankDiffcult;
//
//    @Column(name = "defense_life")
//    private Float defenseLife;
//
//    @Column(name = "grand_prix_card")
//    private Integer grandPrixCard;
//
//    @Column(name = "give_turpeth")
//    private Integer giveTurpeth;
//
//    @Column(name = "can_create_dating")
//    private Integer canCreateDating;
//
//    @Column(name = "can_buy_loudspeaker")
//    private Integer canBuyLoudspeaker;
//
//    @Column(name = "can_capture_regenerate")
//    private Integer canCaptureRegenerate;
//
//    @Column(name = "can_capture_spell")
//    private Integer canCaptureSpell;
//
//    @Column(name = "goods_discount")
//
//    private Float goodsDiscount;
//
//    @Column(name = "present_discount")
//    private Float presentDiscount;
//
//    @Column(name = "max_dig_count")
//    private Integer maxDigCount;
//
//    @Column(name = "capture_times")
//    private Integer captureTimes;
//
//    @Column(name = "capture_max_count")
//    private Integer captureMaxCount;
//
//    public Integer getId() {
//		return id;
//	}
//
//	public void setId(Integer id) {
//		this.id = id;
//	}
//
//	/**
//     * @return level
//     */
//    public Integer getLevel() {
//        return level;
//    }
//
//    /**
//     * @param level
//     */
//    public void setLevel(Integer level) {
//        this.level = level;
//    }
//
//    /**
//     * @return name
//     */
//    public String getName() {
//        return name;
//    }
//
//    /**
//     * @param name
//     */
//    public void setName(String name) {
//        this.name = name;
//    }
//
//    /**
//     * @return charge_amount
//     */
//    public Integer getChargeAmount() {
//        return chargeAmount;
//    }
//
//    /**
//     * @param chargeAmount
//     */
//    public void setChargeAmount(Integer chargeAmount) {
//        this.chargeAmount = chargeAmount;
//    }
//
//    /**
//     * @return vip_name
//     */
//    public String getVipName() {
//        return vipName;
//    }
//
//    /**
//     * @param vipName
//     */
//    public void setVipName(String vipName) {
//        this.vipName = vipName;
//    }
//
//    /**
//     * @return attack_effect
//     */
//    public String getAttackEffect() {
//        return attackEffect;
//    }
//
//    /**
//     * @param attackEffect
//     */
//    public void setAttackEffect(String attackEffect) {
//        this.attackEffect = attackEffect;
//    }
//
//    /**
//     * @return order_in_room
//     */
//    public Integer getOrderInRoom() {
//        return orderInRoom;
//    }
//
//    /**
//     * @param orderInRoom
//     */
//    public void setOrderInRoom(Integer orderInRoom) {
//        this.orderInRoom = orderInRoom;
//    }
//
//    /**
//     * @return can_group_game
//     */
//    public String getCanGroupGame() {
//        return canGroupGame;
//    }
//
//    /**
//     * @param canGroupGame
//     */
//    public void setCanGroupGame(String canGroupGame) {
//        this.canGroupGame = canGroupGame;
//    }
//
//    /**
//     * @return unlock_more_emotion
//     */
//    public String getUnlockMoreEmotion() {
//        return unlockMoreEmotion;
//    }
//
//    /**
//     * @param unlockMoreEmotion
//     */
//    public void setUnlockMoreEmotion(String unlockMoreEmotion) {
//        this.unlockMoreEmotion = unlockMoreEmotion;
//    }
//
//    /**
//     * @return unlock_voice_input
//     */
//    public String getUnlockVoiceInput() {
//        return unlockVoiceInput;
//    }
//
//    /**
//     * @param unlockVoiceInput
//     */
//    public void setUnlockVoiceInput(String unlockVoiceInput) {
//        this.unlockVoiceInput = unlockVoiceInput;
//    }
//
//    /**
//     * @return unlock_more_prop
//     */
//    public String getUnlockMoreProp() {
//        return unlockMoreProp;
//    }
//
//    /**
//     * @param unlockMoreProp
//     */
//    public void setUnlockMoreProp(String unlockMoreProp) {
//        this.unlockMoreProp = unlockMoreProp;
//    }
//
//    /**
//     * @return max_compere_friends
//     */
//    public Integer getMaxCompereFriends() {
//        return maxCompereFriends;
//    }
//
//    /**
//     * @param maxCompereFriends
//     */
//    public void setMaxCompereFriends(Integer maxCompereFriends) {
//        this.maxCompereFriends = maxCompereFriends;
//    }
//
//    /**
//     * @return can_join_full_room
//     */
//    public String getCanJoinFullRoom() {
//        return canJoinFullRoom;
//    }
//
//    /**
//     * @param canJoinFullRoom
//     */
//    public void setCanJoinFullRoom(String canJoinFullRoom) {
//        this.canJoinFullRoom = canJoinFullRoom;
//    }
//
//    /**
//     * @return auto_finish_daily_task
//     */
//    public String getAutoFinishDailyTask() {
//        return autoFinishDailyTask;
//    }
//
//    /**
//     * @param autoFinishDailyTask
//     */
//    public void setAutoFinishDailyTask(String autoFinishDailyTask) {
//        this.autoFinishDailyTask = autoFinishDailyTask;
//    }
//
//    /**
//     * @return experience_percentage
//     */
//    public Float getExperiencePercentage() {
//        return experiencePercentage;
//    }
//
//    /**
//     * @param experiencePercentage
//     */
//    public void setExperiencePercentage(Float experiencePercentage) {
//        this.experiencePercentage = experiencePercentage;
//    }
//
//    /**
//     * @return rank_acceleration
//     */
//    public Float getRankAcceleration() {
//        return rankAcceleration;
//    }
//
//    /**
//     * @param rankAcceleration
//     */
//    public void setRankAcceleration(Float rankAcceleration) {
//        this.rankAcceleration = rankAcceleration;
//    }
//
//    /**
//     * @return rank_diffcult
//     */
//    public Integer getRankDiffcult() {
//        return rankDiffcult;
//    }
//
//    /**
//     * @param rankDiffcult
//     */
//    public void setRankDiffcult(Integer rankDiffcult) {
//        this.rankDiffcult = rankDiffcult;
//    }
//
//    /**
//     * @return defense_life
//     */
//    public Float getDefenseLife() {
//        return defenseLife;
//    }
//
//    /**
//     * @param defenseLife
//     */
//    public void setDefenseLife(Float defenseLife) {
//        this.defenseLife = defenseLife;
//    }
//
//    /**
//     * @return grand_prix_card
//     */
//    public Integer getGrandPrixCard() {
//        return grandPrixCard;
//    }
//
//    /**
//     * @param grandPrixCard
//     */
//    public void setGrandPrixCard(Integer grandPrixCard) {
//        this.grandPrixCard = grandPrixCard;
//    }
//
//    /**
//     * @return give_turpeth
//     */
//    public Integer getGiveTurpeth() {
//        return giveTurpeth;
//    }
//
//    /**
//     * @param giveTurpeth
//     */
//    public void setGiveTurpeth(Integer giveTurpeth) {
//        this.giveTurpeth = giveTurpeth;
//    }
//
//    /**
//     * @return goods_discount
//     */
//    public Float getGoodsDiscount() {
//        return goodsDiscount;
//    }
//
//    /**
//     * @param goodsDiscount
//     */
//    public void setGoodsDiscount(Float goodsDiscount) {
//        this.goodsDiscount = goodsDiscount;
//    }
//
//    /**
//     * @return present_discount
//     */
//    public Float getPresentDiscount() {
//        return presentDiscount;
//    }
//
//    /**
//     * @param presentDiscount
//     */
//    public void setPresentDiscount(Float presentDiscount) {
//        this.presentDiscount = presentDiscount;
//    }
//
//    public String getContent() {
//        return content;
//    }
//
//    public void setContent(String content) {
//        this.content = content;
//    }
//
//    public Integer getMaxDigCount() {
//        return maxDigCount;
//    }
//
//    public void setMaxDigCount(Integer maxDigCount) {
//        this.maxDigCount = maxDigCount;
//    }
//
//    public Integer getCaptureTimes() {
//        return captureTimes;
//    }
//
//    public void setCaptureTimes(Integer captureTimes) {
//        this.captureTimes = captureTimes;
//    }
//
//    public Integer getCaptureMaxCount() {
//        return captureMaxCount;
//    }
//
//    public void setCaptureMaxCount(Integer captureMaxCount) {
//        this.captureMaxCount = captureMaxCount;
//    }
//
//    public Integer getCanBuyLoudspeaker() {
//        return canBuyLoudspeaker;
//    }
//
//    public void setCanBuyLoudspeaker(Integer canBuyLoudspeaker) {
//        this.canBuyLoudspeaker = canBuyLoudspeaker;
//    }
//
//    public Integer getCanCaptureRegenerate() {
//        return canCaptureRegenerate;
//    }
//
//    public void setCanCaptureRegenerate(Integer canCaptureRegenerate) {
//        this.canCaptureRegenerate = canCaptureRegenerate;
//    }
//
//    public Integer getCanCaptureSpell() {
//        return canCaptureSpell;
//    }
//
//    public void setCanCaptureSpell(Integer canCaptureSpell) {
//        this.canCaptureSpell = canCaptureSpell;
//    }
//
//    public Integer getCanCreateDating() {
//        return canCreateDating;
//    }
//
//    public void setCanCreateDating(Integer canCreateDating) {
//        this.canCreateDating = canCreateDating;
//    }
//
//    public String getCanQueueMic() {
//        return canQueueMic;
//    }
//
//    public void setCanQueueMic(String canQueueMic) {
//        this.canQueueMic = canQueueMic;
//    }
//}