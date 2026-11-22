package com.j.joker.cache.model;

import com.j.joker.cache.CacheModel;

public class CacheUserRelation extends CacheModel {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;

    private Long compereId;
    private Long managerId;
    private Long thirdlyAgentId;
    private Long secondaryAgentId;
    private Long primaryAgentId;
    private Long operatorId;

    public Long getCompereId() {
        return compereId;
    }

    public void setCompereId(Long compereId) {
        this.compereId = compereId;
    }

    public Long getManagerId() {
        return managerId;
    }

    public void setManagerId(Long managerId) {
        this.managerId = managerId;
    }

    public Long getThirdlyAgentId() {
        return thirdlyAgentId;
    }

    public void setThirdlyAgentId(Long thirdlyAgentId) {
        this.thirdlyAgentId = thirdlyAgentId;
    }

    public Long getSecondaryAgentId() {
        return secondaryAgentId;
    }

    public void setSecondaryAgentId(Long secondaryAgentId) {
        this.secondaryAgentId = secondaryAgentId;
    }

    public Long getPrimaryAgentId() {
        return primaryAgentId;
    }

    public void setPrimaryAgentId(Long primaryAgentId) {
        this.primaryAgentId = primaryAgentId;
    }

    public Long getOperatorId() {
        return operatorId;
    }

    public void setOperatorId(Long operatorId) {
        this.operatorId = operatorId;
    }

}
