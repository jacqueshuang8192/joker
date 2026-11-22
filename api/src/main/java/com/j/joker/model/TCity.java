package com.j.joker.model;

import java.util.List;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_city")
public class TCity {
    @Id
    @Column("CITY_ID")
    private Long cityId;

    @Column("PROVINCE_ID")
    private Long provinceId;

    @Column("NAME")
    private String name;

    @Column("IS_HOT")
    private String isHot;

    @Column(ignore = true)
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