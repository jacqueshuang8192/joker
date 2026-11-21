package com.hbi.model;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;

@Table("ims_msg")
public class ImsMsg {
    @Id(keyType = KeyType.Auto)
    private Integer id;

    private String phone;

    private Integer msgcode;

    private Integer type;

    private String addtime;

    private String content;

    private Integer status;

    private Integer agentid;

    /**
     * @return id
     */
    public Integer getId() {
        return id;
    }

    /**
     * @param id
     */
    public void setId(Integer id) {
        this.id = id;
    }

    /**
     * @return phone
     */
    public String getPhone() {
        return phone;
    }

    /**
     * @param phone
     */
    public void setPhone(String phone) {
        this.phone = phone;
    }

    /**
     * @return msgcode
     */
    public Integer getMsgcode() {
        return msgcode;
    }

    /**
     * @param msgcode
     */
    public void setMsgcode(Integer msgcode) {
        this.msgcode = msgcode;
    }

    /**
     * @return type
     */
    public Integer getType() {
        return type;
    }

    /**
     * @param type
     */
    public void setType(Integer type) {
        this.type = type;
    }

    /**
     * @return addtime
     */
    public String getAddtime() {
        return addtime;
    }

    /**
     * @param addtime
     */
    public void setAddtime(String addtime) {
        this.addtime = addtime;
    }

    /**
     * @return content
     */
    public String getContent() {
        return content;
    }

    /**
     * @param content
     */
    public void setContent(String content) {
        this.content = content;
    }

    /**
     * @return status
     */
    public Integer getStatus() {
        return status;
    }

    /**
     * @param status
     */
    public void setStatus(Integer status) {
        this.status = status;
    }

    /**
     * @return agentid
     */
    public Integer getAgentid() {
        return agentid;
    }

    /**
     * @param agentid
     */
    public void setAgentid(Integer agentid) {
        this.agentid = agentid;
    }
}