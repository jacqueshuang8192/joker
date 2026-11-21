package com.hbi.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_config")
public class TConfig {
    @Id
    @Column("id")
    private Long id;

    @Id
    @Column("K")
    private String k;

    @Column("V")
    private String v;

    private String remark;

    public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	/**
     * @return K
     */
    public String getK() {
        return k;
    }

    /**
     * @param k
     */
    public void setK(String k) {
        this.k = k;
    }

    /**
     * @return V
     */
    public String getV() {
        return v;
    }

    /**
     * @param v
     */
    public void setV(String v) {
        this.v = v;
    }

    /**
     * @return remark
     */
    public String getRemark() {
        return remark;
    }

    /**
     * @param remark
     */
    public void setRemark(String remark) {
        this.remark = remark;
    }
}