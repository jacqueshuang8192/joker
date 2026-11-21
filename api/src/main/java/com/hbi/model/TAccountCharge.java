package com.hbi.model;

import java.util.Date;
import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_account_charge")
public class TAccountCharge {
    @Id
    @Column("charge_id")
    private Long chargeId;

    @Column("account_id")
    private Long accountId;

    @Column("user_id")
    private Long userId;

    @Column("coin_amount")
    private Integer coinAmount;

    @Column("rmb_amount")
    private Integer rmbAmount;

    @Column("discounted_rmb_amount")
    private Integer discountedRmbAmount;

    @Column("charge_date")
    private Date chargeDate;

    @Column("create_date")
    private Date createDate;

    @Column("channel")
    private String channel;

    @Column("pay_type")
    private String payType;

    @Column("status")
    private String status;
    
    @Column("charge_order")
    private String chargeOrder;
    
    @Column("channel_order_id")
    private String channelOrderId;
    
    @Column("before_charge_coin")
    private String beforeChargeCoin;
    
    @Column("after_charge_coin")
    private String afterChargeCoin;
    
    @Column("goods_id")
    private Long goodsId;

    @Column("agent_id")
    private Long agentId;
    
    private Integer number;

    private String remark;

    public Long getAgentId() {
        return agentId;
    }

    public void setAgentId(Long agentId) {
        this.agentId = agentId;
    }

    public Long getGoodsId() {
		return goodsId;
	}

	public void setGoodsId(Long goodsId) {
		this.goodsId = goodsId;
	}

	public Integer getNumber() {
		return number;
	}

	public void setNumber(Integer number) {
		this.number = number;
	}

	/**
     * @return charge_id
     */
    public Long getChargeId() {
        return chargeId;
    }

    /**
     * @param chargeId
     */
    public void setChargeId(Long chargeId) {
        this.chargeId = chargeId;
    }

    /**
     * @return account_id
     */
    public Long getAccountId() {
        return accountId;
    }

    /**
     * @param accountId
     */
    public void setAccountId(Long accountId) {
        this.accountId = accountId;
    }

    /**
     * @return user_id
     */
    public Long getUserId() {
        return userId;
    }

    /**
     * @param userId
     */
    public void setUserId(Long userId) {
        this.userId = userId;
    }

    /**
     * @return coin_amount
     */
    public Integer getCoinAmount() {
        return coinAmount;
    }

    /**
     * @param coinAmount
     */
    public void setCoinAmount(Integer coinAmount) {
        this.coinAmount = coinAmount;
    }

    /**
     * @return rmb_amount
     */
    public Integer getRmbAmount() {
        return rmbAmount;
    }

    /**
     * @param rmbAmount
     */
    public void setRmbAmount(Integer rmbAmount) {
        this.rmbAmount = rmbAmount;
    }

    /**
     * @return charge_date
     */
    public Date getChargeDate() {
        return chargeDate;
    }

    /**
     * @param chargeDate
     */
    public void setChargeDate(Date chargeDate) {
        this.chargeDate = chargeDate;
    }

    /**
     * @return create_date
     */
    public Date getCreateDate() {
        return createDate;
    }

    /**
     * @param createDate
     */
    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }

    /**
     * @return channel
     */
    public String getChannel() {
        return channel;
    }

    /**
     * @param channel
     */
    public void setChannel(String channel) {
        this.channel = channel;
    }

    /**
     * @return pay_type
     */
    public String getPayType() {
        return payType;
    }

    /**
     * @param payType
     */
    public void setPayType(String payType) {
        this.payType = payType;
    }

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getChargeOrder() {
		return chargeOrder;
	}

	public void setChargeOrder(String chargeOrder) {
		this.chargeOrder = chargeOrder;
	}

	public String getChannelOrderId() {
		return channelOrderId;
	}

	public void setChannelOrderId(String channelOrderId) {
		this.channelOrderId = channelOrderId;
	}

	public String getBeforeChargeCoin() {
		return beforeChargeCoin;
	}

	public void setBeforeChargeCoin(String beforeChargeCoin) {
		this.beforeChargeCoin = beforeChargeCoin;
	}

	public String getAfterChargeCoin() {
		return afterChargeCoin;
	}

	public void setAfterChargeCoin(String afterChargeCoin) {
		this.afterChargeCoin = afterChargeCoin;
	}

    public Integer getDiscountedRmbAmount() {
        return discountedRmbAmount;
    }

    public void setDiscountedRmbAmount(Integer discountedRmbAmount) {
        this.discountedRmbAmount = discountedRmbAmount;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }
}