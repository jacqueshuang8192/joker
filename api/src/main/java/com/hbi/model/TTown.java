package com.hbi.model;

import jakarta.persistence.*;

@Table(name = "t_town")
public class TTown {
    @Id
    @Column(name = "TOWN_ID")
    private Long townId;

    @Column(name = "CITY_ID")
    private Long cityId;

    @Column(name = "NAME")
    private String name;

    /**
     * @return TOWN_ID
     */
    public Long getTownId() {
        return townId;
    }

    /**
     * @param townId
     */
    public void setTownId(Long townId) {
        this.townId = townId;
    }

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
}