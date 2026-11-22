package com.j.joker.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_chip_select")
public class TChipSelect {
    @Id
    @Column("chip_id")
    private Long chipId;

    private String name;

    private Integer level;

    private String remark;

    private String photo;

    @Column("game_id")
    private Long gameId;

    private Long version;

    @Column("coin_count")
    private Integer coinCount;

    @Column("player_count")
    private Integer playerCount;

    @Column("Nullity")
    private String nullity;

    /**
     * @return chip_id
     */
    public Long getChipId() {
        return chipId;
    }

    /**
     * @param chipId
     */
    public void setChipId(Long chipId) {
        this.chipId = chipId;
    }

    /**
     * @return name
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

    /**
     * @return photo
     */
    public String getPhoto() {
        return photo;
    }

    /**
     * @param photo
     */
    public void setPhoto(String photo) {
        this.photo = photo;
    }

    /**
     * @return version
     */
    public Long getVersion() {
        return version;
    }

    /**
     * @param version
     */
    public void setVersion(Long version) {
        this.version = version;
    }

    /**
     * @return coin_count
     */
    public Integer getCoinCount() {
        return coinCount;
    }

    /**
     * @param coinCount
     */
    public void setCoinCount(Integer coinCount) {
        this.coinCount = coinCount;
    }

    /**
     * @return player_count
     */
    public Integer getPlayerCount() {
        return playerCount;
    }

    /**
     * @param playerCount
     */
    public void setPlayerCount(Integer playerCount) {
        this.playerCount = playerCount;
    }

    /**
     * @return Nullity
     */
    public String getNullity() {
        return nullity;
    }

    /**
     * @param nullity
     */
    public void setNullity(String nullity) {
        this.nullity = nullity;
    }

    public Long getGameId() {
        return gameId;
    }

    public void setGameId(Long gameId) {
        this.gameId = gameId;
    }

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }
}