//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_attention")
//public class TAttention {
//    @Id
//    @Column(name = "player_id")
//    private Long playerId;
//
//    @Id
//    @Column(name = "compere_id")
//    private Long compereId;
//
//    @Column(name = "attent_date")
//    private Date attentDate;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    /**
//     * @return player_id
//     */
//    public Long getPlayerId() {
//        return playerId;
//    }
//
//    /**
//     * @param playerId
//     */
//    public void setPlayerId(Long playerId) {
//        this.playerId = playerId;
//    }
//
//    /**
//     * @return compere_id
//     */
//    public Long getCompereId() {
//        return compereId;
//    }
//
//    /**
//     * @param compereId
//     */
//    public void setCompereId(Long compereId) {
//        this.compereId = compereId;
//    }
//
//    /**
//     * @return attent_date
//     */
//    public Date getAttentDate() {
//        return attentDate;
//    }
//
//    /**
//     * @param attentDate
//     */
//    public void setAttentDate(Date attentDate) {
//        this.attentDate = attentDate;
//    }
//
//    /**
//     * @return create_date
//     */
//    public Date getCreateDate() {
//        return createDate;
//    }
//
//    /**
//     * @param createDate
//     */
//    public void setCreateDate(Date createDate) {
//        this.createDate = createDate;
//    }
//}