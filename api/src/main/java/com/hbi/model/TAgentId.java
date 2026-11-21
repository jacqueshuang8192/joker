package com.hbi.model;

import javax.persistence.Id;
import javax.persistence.Table;

/**
 * Created by dzesla on 2017/2/16.
 */
@Table
public class TAgentId {
    @Id
    private Long agentId;

    private String usedFlag;

    public Long getAgentId() {
        return agentId;
    }

    public void setAgentId(Long agentId) {
        this.agentId = agentId;
    }

    public String getUsedFlag() {
        return usedFlag;
    }

    public void setUsedFlag(String usedFlag) {
        this.usedFlag = usedFlag;
    }
}
