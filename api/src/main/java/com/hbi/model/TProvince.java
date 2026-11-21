package com.hbi.model;

import java.util.List;

import javax.persistence.*;

@Table(name = "t_province")
public class TProvince {
    @Id
    @Column(name = "PROVINCE_ID")
    private Long provinceId;

    @Column(name = "NAME")
    private String name;

    @Transient
    private List<TCity> cities;
    /**
     * @return PROVINCE_ID
     */
    public Long getProvinceId() {
        return provinceId;
    }

    /**
     * @param provinceId
     */
    public void setProvinceId(Long provinceId) {
        this.provinceId = provinceId;
    }

    /**
     * @return NAME
     */
    public String getName() {
        return name;
    }

    /**
     * @param name
     */
    public void setName(String name) {
        this.name = name;
    }

	public List<TCity> getCities() {
		return cities;
	}

	public void setCities(List<TCity> cities) {
		this.cities = cities;
	}
}