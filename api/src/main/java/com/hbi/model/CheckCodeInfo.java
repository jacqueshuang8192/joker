package com.hbi.model;

public class CheckCodeInfo {
    private long timestamp;
    
    private String code;

    private String phone;
    
    public CheckCodeInfo() {
        
    }
    
    public CheckCodeInfo(long timestamp, String code, String phone) {
        this.timestamp = timestamp;
        this.code = code;
        this.phone = phone;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }
}
