package com.hbi.vo.response.user;

public class MiningVo {
    private Long societyId;
    
    private String societyName;
    
    private Integer onlinePlayerCount;
    
    private Integer miningPlayerCount;
    
    public Long getSocietyId() {
        return societyId;
    }

    public void setSocietyId(Long societyId) {
        this.societyId = societyId;
    }

    public String getSocietyName() {
        return societyName;
    }

    public void setSocietyName(String societyName) {
        this.societyName = societyName;
    }

    public Integer getOnlinePlayerCount() {
        return onlinePlayerCount;
    }

    public void setOnlinePlayerCount(Integer onlinePlayerCount) {
        this.onlinePlayerCount = onlinePlayerCount;
    }

    public Integer getMiningPlayerCount() {
        return miningPlayerCount;
    }

    public void setMiningPlayerCount(Integer miningPlayerCount) {
        this.miningPlayerCount = miningPlayerCount;
    }
}
