package com.hbi.model;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import java.util.Date;

/**
 * Created by dzesla on 2017/2/17.
 */
@Table("t_fortune_record")
public class TFortuneRecord {
    @Id
    private Long id;

    private Long userId;

    private Long fortuneId;

    private String fortuneName;

    /**
     * 奖品类型：card房卡；object实物；point积分
     */
    private String type;

    private Integer count;

    private String address;

    private String phone;

    /**
     * 奖品状态：0未发货；1已发货未确认；2用户已确认
     */
    private Integer status;

    private Date date;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getFortuneId() {
        return fortuneId;
    }

    public void setFortuneId(Long fortuneId) {
        this.fortuneId = fortuneId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Integer getCount() {
        return count;
    }

    public void setCount(Integer count) {
        this.count = count;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public String getFortuneName() {
        return fortuneName;
    }

    public void setFortuneName(String fortuneName) {
        this.fortuneName = fortuneName;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }
}
