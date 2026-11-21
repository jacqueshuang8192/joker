package com.hbi.model;

import javax.persistence.Id;
import javax.persistence.Table;

/**
 */
@Table(name = "t_charge_pool")
public class TChargePool {
    @Id
    private Long   id;
    private Double amount;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Double getAmount() {
        return amount;
    }

    public void setAmount(Double amount) {
        this.amount = amount;
    }
}
