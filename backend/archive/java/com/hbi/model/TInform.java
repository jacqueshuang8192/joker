//package com.hbi.model;
//
//import java.util.Date;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//
//@Table(name = "t_inform")
//public class TInform {
//    @Id
//    private Long id;
//
//    /**
//     * 举报人ID
//     */
//    @Column(name="informer_id")
//    private Long informerId;
//
//    /**
//     * 被举报人ID
//     */
//    @Column(name="Informant_id")
//    private Long informantId;
//
//    /**
//     * 内容
//     */
//    private String content;
//
//    /**
//     * 举报类型：0用户；1群组
//     */
//    private Integer type;
//
//    /**
//     * 创建日期
//     */
//    @Column(name="create_date")
//    private Date createDate;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public Long getInformerId() {
//        return informerId;
//    }
//
//    public void setInformerId(Long informerId) {
//        this.informerId = informerId;
//    }
//
//    public Long getInformantId() {
//        return informantId;
//    }
//
//    public void setInformantId(Long informantId) {
//        this.informantId = informantId;
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
//    public Date getCreateDate() {
//        return createDate;
//    }
//
//    public void setCreateDate(Date createDate) {
//        this.createDate = createDate;
//    }
//
//    public Integer getType() {
//        return type;
//    }
//
//    public void setType(Integer type) {
//        this.type = type;
//    }
//}
