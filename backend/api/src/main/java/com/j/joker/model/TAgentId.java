package com.j.joker.model;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

/**
 * Created by dzesla on 2017/2/16.
 */
@Table("t_agent_id")
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
