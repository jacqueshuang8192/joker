package com.hbi.model;

import java.util.Date;

import javax.persistence.*;

@Table(name = "t_player")
public class TPlayer {
    @Id
    @Column(name = "player_id")
    private Long playerId;

    @Column(name = "compere_id")
    private Long compereId;

    @Column(name = "province_id")
    private Long provinceId;

    @Column(name = "city_id")
    private Long cityId;

    @Column(name = "town_id")
    private Long townId;

    @Transient
    private TUser user;

    private String tel;

    private String mail;

    private Integer level;

    @Column(name = "MasterOrder")
    private Integer masterorder;

    @Column(name = "expiric_value")
    private Integer expiricValue;

    @Column(name = "MemberOverDate")
    private Date memberoverdate;

    @Column(name = "RegisterDate")
    private Date registerdate;

    @Column(name = "LastLogonDate")
    private Date lastlogondate;

    @Column(name = "RegisterIP")
    private String registerip;

    @Column(name = "LastLogonIP")
    private String lastlogonip;
    
    @Column(name = "charge_sum")
    private Long chargeSum;

    private Long attack;

    private Long defense;

    private Long life;

    @Column(name = "capture_attack")
    private Long captureAttack;

    @Column(name = "capture_defense")
    private Long captureDefense;

    @Column(name = "capture_life")
    private Long captureLife;

    @Column(name = "promoter_id")
    private Long promoterId;

    @Column(name = "promo_code")
    private String promoCode;

    /**
     * @return player_id
     */
    public Long getPlayerId() {
        return playerId;
    }

    /**
     * @param playerId
     */
    public void setPlayerId(Long playerId) {
        this.playerId = playerId;
    }

    /**
     * @return compere_id
     */
    public Long getCompereId() {
        return compereId;
    }

    /**
     * @param compereId
     */
    public void setCompereId(Long compereId) {
        this.compereId = compereId;
    }

    /**
     * @return province_id
     */
    public Long getProvinceId() {
        return provinceId;
    }

    /**
     * @param provinceId
     */
    public void setProvinceId(Long provinceId) {
        this.provinceId = provinceId;
    }

    /**
     * @return city_id
     */
    public Long getCityId() {
        return cityId;
    }

    /**
     * @param cityId
     */
    public void setCityId(Long cityId) {
        this.cityId = cityId;
    }

    /**
     * @return town_id
     */
    public Long getTownId() {
        return townId;
    }

    /**
     * @param townId
     */
    public void setTownId(Long townId) {
        this.townId = townId;
    }

    /**
     * @return tel
     */
    public String getTel() {
        return tel;
    }

    /**
     * @param tel
     */
    public void setTel(String tel) {
        this.tel = tel;
    }

    /**
     * @return mail
     */
    public String getMail() {
        return mail;
    }

    /**
     * @param mail
     */
    public void setMail(String mail) {
        this.mail = mail;
    }

    /**
     * @return level
     */
    public Integer getLevel() {
        return level;
    }

    /**
     * @param level
     */
    public void setLevel(Integer level) {
        this.level = level;
    }

    /**
     * @return MasterOrder
     */
    public Integer getMasterorder() {
        return masterorder;
    }

    /**
     * @param masterorder
     */
    public void setMasterorder(Integer masterorder) {
        this.masterorder = masterorder;
    }

    /**
     * @return expiric_value
     */
    public Integer getExpiricValue() {
        return expiricValue;
    }

    /**
     * @param expiricValue
     */
    public void setExpiricValue(Integer expiricValue) {
        this.expiricValue = expiricValue;
    }

    /**
     * @return MemberOverDate
     */
    public Date getMemberoverdate() {
        return memberoverdate;
    }

    /**
     * @param memberoverdate
     */
    public void setMemberoverdate(Date memberoverdate) {
        this.memberoverdate = memberoverdate;
    }

    /**
     * @return RegisterDate
     */
    public Date getRegisterdate() {
        return registerdate;
    }

    /**
     * @param registerdate
     */
    public void setRegisterdate(Date registerdate) {
        this.registerdate = registerdate;
    }

    /**
     * @return LastLogonDate
     */
    public Date getLastlogondate() {
        return lastlogondate;
    }

    /**
     * @param lastlogondate
     */
    public void setLastlogondate(Date lastlogondate) {
        this.lastlogondate = lastlogondate;
    }

    /**
     * @return RegisterIP
     */
    public String getRegisterip() {
        return registerip;
    }

    /**
     * @param registerip
     */
    public void setRegisterip(String registerip) {
        this.registerip = registerip;
    }

    /**
     * @return LastLogonIP
     */
    public String getLastlogonip() {
        return lastlogonip;
    }

    /**
     * @param lastlogonip
     */
    public void setLastlogonip(String lastlogonip) {
        this.lastlogonip = lastlogonip;
    }

    public TUser getUser() {
        return user;
    }

    public void setUser(TUser user) {
        this.user = user;
    }

    public Long getAttack() {
        return attack;
    }

    public void setAttack(Long attack) {
        this.attack = attack;
    }

    public Long getDefense() {
        return defense;
    }

    public void setDefense(Long defense) {
        this.defense = defense;
    }

    public Long getLife() {
        return life;
    }

    public void setLife(Long life) {
        this.life = life;
    }

    public Long getCaptureAttack() {
        return captureAttack;
    }

    public void setCaptureAttack(Long captureAttack) {
        this.captureAttack = captureAttack;
    }

    public Long getCaptureDefense() {
        return captureDefense;
    }

    public void setCaptureDefense(Long captureDefense) {
        this.captureDefense = captureDefense;
    }

    public Long getCaptureLife() {
        return captureLife;
    }

    public void setCaptureLife(Long captureLife) {
        this.captureLife = captureLife;
    }

    public Long getPromoterId() {
        return promoterId;
    }

    public void setPromoterId(Long promoterId) {
        this.promoterId = promoterId;
    }

    public String getPromoCode() {
        return promoCode;
    }

    public void setPromoCode(String promoCode) {
        this.promoCode = promoCode;
    }

    public Long getChargeSum() {
        return chargeSum;
    }

    public void setChargeSum(Long chargeSum) {
        this.chargeSum = chargeSum;
    }

}