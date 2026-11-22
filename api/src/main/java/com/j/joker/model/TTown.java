package com.j.joker.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_town")
public class TTown {
    @Id
    @Column("TOWN_ID")
    private Long townId;

    @Column("CITY_ID")
    private Long cityId;

    @Column("NAME")
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