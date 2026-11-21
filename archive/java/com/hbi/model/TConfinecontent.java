//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_confinecontent")
//public class TConfinecontent {
//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    private Long id;
//
//    private String account;
//
//    private String ipaddress;
//
//    private String merchine;
//
//    @Column(name = "ConfineDate")
//    private String confinedate;
//
//    private Date begindate;
//
//    private Date finishdate;
//
//    private String remark;
//
//    /**
//     * @return id
//     */
//    public Long getId() {
//        return id;
//    }
//
//    /**
//     * @param id
//     */
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    /**
//     * @return account
//     */
//    public String getAccount() {
//        return account;
//    }
//
//    /**
//     * @param account
//     */
//    public void setAccount(String account) {
//        this.account = account;
//    }
//
//    /**
//     * @return ipaddress
//     */
//    public String getIpaddress() {
//        return ipaddress;
//    }
//
//    /**
//     * @param ipaddress
//     */
//    public void setIpaddress(String ipaddress) {
//        this.ipaddress = ipaddress;
//    }
//
//    /**
//     * @return merchine
//     */
//    public String getMerchine() {
//        return merchine;
//    }
//
//    /**
//     * @param merchine
//     */
//    public void setMerchine(String merchine) {
//        this.merchine = merchine;
//    }
//
//    /**
//     * @return ConfineDate
//     */
//    public String getConfinedate() {
//        return confinedate;
//    }
//
//    /**
//     * @param confinedate
//     */
//    public void setConfinedate(String confinedate) {
//        this.confinedate = confinedate;
//    }
//
//    /**
//     * @return begindate
//     */
//    public Date getBegindate() {
//        return begindate;
//    }
//
//    /**
//     * @param begindate
//     */
//    public void setBegindate(Date begindate) {
//        this.begindate = begindate;
//    }
//
//    /**
//     * @return finishdate
//     */
//    public Date getFinishdate() {
//        return finishdate;
//    }
//
//    /**
//     * @param finishdate
//     */
//    public void setFinishdate(Date finishdate) {
//        this.finishdate = finishdate;
//    }
//
//    /**
//     * @return remark
//     */
//    public String getRemark() {
//        return remark;
//    }
//
//    /**
//     * @param remark
//     */
//    public void setRemark(String remark) {
//        this.remark = remark;
//    }
//}