package com.j.joker.vo.response.society;

import java.util.List;

public class MiningProperty {
    private Long userId;
    
    private String tool;
    
    private String protect;
    
    private String transport;
    
    private Integer workerAmount;
    
    private String equip;
    
    private Long attack;
    
    private Long defense;
    
    private Long life;
    
    private List gameList;
    
    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getTool() {
        return tool;
    }

    public void setTool(String tool) {
        this.tool = tool;
    }

    public String getProtect() {
        return protect;
    }

    public void setProtect(String protect) {
        this.protect = protect;
    }

    public String getTransport() {
        return transport;
    }

    public void setTransport(String transport) {
        this.transport = transport;
    }

    public Integer getWorkerAmount() {
        return workerAmount;
    }

    public void setWorkerAmount(Integer workerAmount) {
        this.workerAmount = workerAmount;
    }

    public String getEquip() {
        return equip;
    }

    public void setEquip(String equip) {
        this.equip = equip;
    }

    public Long getAttack() {
        return attack;
    }

    public void setAttack(Long attack) {
        this.attack = attack;
    }

    public Long getDefense() {
        return defense;
    }

    public void setDefense(Long defense) {
        this.defense = defense;
    }

    public Long getLife() {
        return life;
    }

    public void setLife(Long life) {
        this.life = life;
    }

    public List getGameList() {
        return gameList;
    }

    public void setGameList(List gameList) {
        this.gameList = gameList;
    }
}
