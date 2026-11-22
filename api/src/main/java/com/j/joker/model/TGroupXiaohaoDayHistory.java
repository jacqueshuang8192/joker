package com.j.joker.model;

import java.util.Date;
import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;

@Table("t_group_xiaohao_day_history")
public class TGroupXiaohaoDayHistory {
    @Id(keyType = KeyType.Auto)
    private Integer id;

    @Column("group_id")
    private Integer groupId;

    @Column("hehuoren_id")
    private Integer hehuorenId;

    private Integer profit;

    @Column("day_time")
    private Date dayTime;

    @Column("dayingjia_count")
    private Integer dayingjiaCount;

    @Column("player_count")
    private Integer playerCount;

    /**
     * @return id
     */
    public Integer getId() {
        return id;
    }

    /**
     * @param id
     */
    public void setId(Integer id) {
        this.id = id;
    }

    /**
     * @return group_id
     */
    public Integer getGroupId() {
        return groupId;
    }

    /**
     * @param groupId
     */
    public void setGroupId(Integer groupId) {
        this.groupId = groupId;
    }

    /**
     * @return hehuoren_id
     */
    public Integer getHehuorenId() {
        return hehuorenId;
    }

    /**
     * @param hehuorenId
     */
    public void setHehuorenId(Integer hehuorenId) {
        this.hehuorenId = hehuorenId;
    }

    /**
     * @return profit
     */
    public Integer getProfit() {
        return profit;
    }

    /**
     * @param profit
     */
    public void setProfit(Integer profit) {
        this.profit = profit;
    }

    /**
     * @return day_time
     */
    public Date getDayTime() {
        return dayTime;
    }

    /**
     * @param dayTime
     */
    public void setDayTime(Date dayTime) {
        this.dayTime = dayTime;
    }

    /**
     * @return dayingjia_count
     */
    public Integer getDayingjiaCount() {
        return dayingjiaCount;
    }

    /**
     * @param dayingjiaCount
     */
    public void setDayingjiaCount(Integer dayingjiaCount) {
        this.dayingjiaCount = dayingjiaCount;
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
}