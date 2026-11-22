package com.j.joker.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Table;

@Table("ims_tpcard")
public class ImsTpCard {
    @Column("userid")
    private Long userId;

    @Column("money")
    private Long money;

    @Column("agentid")
    private Integer agentId;

    @Column("agentincome")
    private Integer agentInCome;

    @Column("parentid")
    private Integer parentId;

    @Column("parentincome")
    private Integer parentInCome;

    @Column("grandparentid")
    private Integer grandParentId;

    @Column("grandparentincome")
    private Integer grandParentInCome;

    @Column("surplus")
    private Integer surplus;


    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getMoney() {
        return money;
    }

    public void setMoney(Long money) {
        this.money = money;
    }

    public Integer getAgentId() {
        return agentId;
    }

    public void setAgentId(Integer agentId) {
        this.agentId = agentId;
    }

    public Integer getAgentInCome() {
        return agentInCome;
    }

    public void setAgentInCome(Integer agentInCome) {
        this.agentInCome = agentInCome;
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }

    public Integer getParentInCome() {
        return parentInCome;
    }

    public void setParentInCome(Integer parentInCome) {
        this.parentInCome = parentInCome;
    }

    public Integer getGrandParentId() {
        return grandParentId;
    }

    public void setGrandParentId(Integer grandParentId) {
        this.grandParentId = grandParentId;
    }

    public Integer getGrandParentInCome() {
        return grandParentInCome;
    }

    public void setGrandParentInCome(Integer grandParentInCome) {
        this.grandParentInCome = grandParentInCome;
    }

    public Integer getSurplus() {
        return surplus;
    }

    public void setSurplus(Integer surplus) {
        this.surplus = surplus;
    }
}
