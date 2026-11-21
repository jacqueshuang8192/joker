//package com.hbi.model;
//
//import java.util.Date;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//
//@Table(name = "t_compere_income")
//public class TCompereIncome {
//    @Id
//    @Column(name = "id")
//    private Long id;
//    @Column(name = "compere_id")
//    private Long compereId;
//    @Column(name = "match_extract_income")
//    private Integer matchExtractIncome;
//    @Column(name = "live_room_gift_income")
//    private Integer liveRoomGiftIncome;
//    @Column(name = "live_room_game_extract_income")
//    private Integer liveRoomGameExtractIncome;
//    @Column(name = "dating_income")
//    private Integer datingIncome;
//    @Column(name = "task_income")
//    private Integer taskIncome;
//    @Column(name = "mining_income")
//    private Integer miningIncome;
//    @Column(name = "capture_compere_defend_income")
//    private Integer captureCompereDefendIncome;
//    @Column(name = "capture_compere_ransom_income")
//    private Integer captureCompereRansomIncome;
//    @Column(name = "has_income")
//    private String hasIncome;
//    @Column(name = "income_date")
//    private Date incomeDate;
//    @Column(name = "lastmodify_date")
//    private Date lastmodifyDate;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public Long getCompereId() {
//        return compereId;
//    }
//
//    public void setCompereId(Long compereId) {
//        this.compereId = compereId;
//    }
//
//    public Integer getMatchExtractIncome() {
//        return matchExtractIncome;
//    }
//
//    public void setMatchExtractIncome(Integer matchExtractIncome) {
//        this.matchExtractIncome = matchExtractIncome;
//    }
//
//    public Integer getLiveRoomGiftIncome() {
//        return liveRoomGiftIncome;
//    }
//
//    public void setLiveRoomGiftIncome(Integer liveRoomGiftIncome) {
//        this.liveRoomGiftIncome = liveRoomGiftIncome;
//    }
//
//    public Integer getLiveRoomGameExtractIncome() {
//        return liveRoomGameExtractIncome;
//    }
//
//    public void setLiveRoomGameExtractIncome(Integer liveRoomGameExtractIncome) {
//        this.liveRoomGameExtractIncome = liveRoomGameExtractIncome;
//    }
//
//    public Integer getDatingIncome() {
//        return datingIncome;
//    }
//
//    public void setDatingIncome(Integer datingIncome) {
//        this.datingIncome = datingIncome;
//    }
//
//    public Integer getTaskIncome() {
//        return taskIncome;
//    }
//
//    public void setTaskIncome(Integer taskIncome) {
//        this.taskIncome = taskIncome;
//    }
//
//    public Integer getMiningIncome() {
//        return miningIncome;
//    }
//
//    public void setMiningIncome(Integer miningIncome) {
//        this.miningIncome = miningIncome;
//    }
//
//    public Integer getCaptureCompereDefendIncome() {
//        return captureCompereDefendIncome;
//    }
//
//    public void setCaptureCompereDefendIncome(Integer captureCompereDefendIncome) {
//        this.captureCompereDefendIncome = captureCompereDefendIncome;
//    }
//
//    public Integer getCaptureCompereRansomIncome() {
//        return captureCompereRansomIncome;
//    }
//
//    public void setCaptureCompereRansomIncome(Integer captureCompereRansomIncome) {
//        this.captureCompereRansomIncome = captureCompereRansomIncome;
//    }
//
//    public String getHasIncome() {
//        return hasIncome;
//    }
//
//    public void setHasIncome(String hasIncome) {
//        this.hasIncome = hasIncome;
//    }
//
//    public Date getIncomeDate() {
//        return incomeDate;
//    }
//
//    public void setIncomeDate(Date incomeDate) {
//        this.incomeDate = incomeDate;
//    }
//
//    public Date getLastmodifyDate() {
//        return lastmodifyDate;
//    }
//
//    public void setLastmodifyDate(Date lastmodifyDate) {
//        this.lastmodifyDate = lastmodifyDate;
//    }
//
//}