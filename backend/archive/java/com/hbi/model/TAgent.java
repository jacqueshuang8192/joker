//package com.hbi.model;
//
//import java.util.Date;
//
//import javax.persistence.*;
//
//@Table(name = "t_agent")
//public class TAgent {
//    @Id
//    @Column(name = "agent_id")
//    private Long agentId;
//
//    private String name;
//
//    private Integer type;
//
//    @Column(name = "parent_id")
//    private Long parentId;
//
//    @Column(name = "invitation_code")
//    private String invitationCode;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    private Integer income;
//
//    /**
//     * @return agent_id
//     */
//    public Long getAgentId() {
//        return agentId;
//    }
//
//    /**
//     * @param agentId
//     */
//    public void setAgentId(Long agentId) {
//        this.agentId = agentId;
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
//    public Integer getType() {
//        return type;
//    }
//
//    public void setType(Integer type) {
//        this.type = type;
//    }
//
//    public Long getParentId() {
//        return parentId;
//    }
//
//    public void setParentId(Long parentId) {
//        this.parentId = parentId;
//    }
//
//    public String getInvitationCode() {
//        return invitationCode;
//    }
//
//    public void setInvitationCode(String invitationCode) {
//        this.invitationCode = invitationCode;
//    }
//
//    public Date getCreateDate() {
//        return createDate;
//    }
//
//    public void setCreateDate(Date createDate) {
//        this.createDate = createDate;
//    }
//
//    public Integer getIncome() {
//        return income;
//    }
//
//    public void setIncome(Integer income) {
//        this.income = income;
//    }
//
//}