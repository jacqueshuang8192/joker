//package com.hbi.model;
//
//import java.util.Date;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//
//@Table(name = "t_task_activity")
//public class TTaskActivity {
//
//    @Id
//    @Column(name = "id")
//    private Long id;
//    @Column(name = "name")
//    private String name;
//    @Column(name = "content")
//    private String content;
//    @Column(name = "remark")
//    private String remark;
//    @Column(name = "amount")
//    private Integer amount;
//    @Column(name = "unit")
//    private String unit;
//    @Column(name = "effective_start")
//    private Date effectiveStart;
//    @Column(name = "effective_end")
//    private Date effectiveEnd;
//    @Column(name = "treasure_chest_id")
//    private Long treasureChestId;
//    @Column(name = "creator_id")
//    private Long creatorId;
//    @Column(name = "create_date")
//    private java.util.Date createDate;
//    @Column(name = "last_modifier_id")
//    private Long lastModifierId;
//    @Column(name = "last_modify_date")
//    private java.util.Date lastModifyDate;
//    @Column(name = "status")
//    private String status;
//    @Column(name = "pre_activity_id")
//    private Long preActivityId;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public String getName() {
//        return name;
//    }
//
//    public void setName(String name) {
//        this.name = name;
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
//    public String getRemark() {
//        return remark;
//    }
//
//    public void setRemark(String remark) {
//        this.remark = remark;
//    }
//
//    public Integer getAmount() {
//        return amount;
//    }
//
//    public void setAmount(Integer amount) {
//        this.amount = amount;
//    }
//
//    public String getUnit() {
//        return unit;
//    }
//
//    public void setUnit(String unit) {
//        this.unit = unit;
//    }
//
//    public Date getEffectiveStart() {
//        return effectiveStart;
//    }
//
//    public void setEffectiveStart(Date effectiveStart) {
//        this.effectiveStart = effectiveStart;
//    }
//
//    public Date getEffectiveEnd() {
//        return effectiveEnd;
//    }
//
//    public void setEffectiveEnd(Date effectiveEnd) {
//        this.effectiveEnd = effectiveEnd;
//    }
//
//    public Long getTreasureChestId() {
//        return treasureChestId;
//    }
//
//    public void setTreasureChestId(Long treasureChestId) {
//        this.treasureChestId = treasureChestId;
//    }
//
//    public Long getCreatorId() {
//        return creatorId;
//    }
//
//    public void setCreatorId(Long creatorId) {
//        this.creatorId = creatorId;
//    }
//
//    public java.util.Date getCreateDate() {
//        return createDate;
//    }
//
//    public void setCreateDate(java.util.Date createDate) {
//        this.createDate = createDate;
//    }
//
//    public Long getLastModifierId() {
//        return lastModifierId;
//    }
//
//    public void setLastModifierId(Long lastModifierId) {
//        this.lastModifierId = lastModifierId;
//    }
//
//    public java.util.Date getLastModifyDate() {
//        return lastModifyDate;
//    }
//
//    public void setLastModifyDate(java.util.Date lastModifyDate) {
//        this.lastModifyDate = lastModifyDate;
//    }
//
//    public String getStatus() {
//        return status;
//    }
//
//    public void setStatus(String status) {
//        this.status = status;
//    }
//
//    public Long getPreActivityId() {
//        return preActivityId;
//    }
//
//    public void setPreActivityId(Long preActivityId) {
//        this.preActivityId = preActivityId;
//    }
//
//}