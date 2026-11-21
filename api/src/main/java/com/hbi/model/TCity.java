package com.hbi.model;

import java.util.List;

import javax.persistence.*;

@Table(name = "t_city")
public class TCity {
    @Id
    @Column(name = "CITY_ID")
    private Long cityId;

    @Column(name = "PROVINCE_ID")
    private Long provinceId;

    @Column(name = "NAME")
    private String name;

    @Column(name = "IS_HOT")
    private String isHot;

    @Transient
    private List<TTown> towns;
    /**
     * @return CITY_ID
     */
    public Long getCityId() {
        return cityId;
    }

    /**
     * @param cityId
     */
    public void setCityId(Long cityId) {
        this.cityId = cityId;
    }

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

    /**
     * @return IS_HOT
     */
    public String getIsHot() {
        return isHot;
    }

    /**
     * @param isHot
     */
    public void setIsHot(String isHot) {
        this.isHot = isHot;
    }

	public List<TTown> getTowns() {
		return towns;
	}

	public void setTowns(List<TTown> towns) {
		this.towns = towns;
	}
}