package com.j.joker.model;

import java.util.Date;

public class TBiqiCardId {
    private Integer id;
    private String cardId;
    private String cardPw;
    private Integer status;
    private Long playerId;
    private Date useTime;
    private Integer moneyType;
    private Integer price;

    public Integer getPrice() {
        return price;
    }

    public void setPrice(Integer price) {
        this.price = price;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getCardId() {
        return cardId;
    }

    public Date getUseTime() {
        return useTime;
    }

    public void setUseTime(Date useTime) {
        this.useTime = useTime;
    }

    public void setCardId(String cardId) {
        this.cardId = cardId;
    }

    public String getCardPw() {
        return cardPw;
    }

    public void setCardPw(String cardPw) {
        this.cardPw = cardPw;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public Long getPlayerId() {
        return playerId;
    }

    public void setPlayerId(Long playerId) {
        this.playerId = playerId;
    }

    public Integer getMoneyType() {
        return moneyType;
    }

    public void setMoneyType(Integer moneyType) {
        this.moneyType = moneyType;
    }
}
