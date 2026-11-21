package com.hbi.vo.response.hehuoren;

/**
 * 合伙人列表
 * Create by Mars on 2019/5/27 13:50
 */
public class PlayerGroupHhrListVo {

    private Integer userid;

    // 昵称
    private String nickName;

    // 群组ID
    private Integer groupId;

    // 游戏局数
    private Integer gameCount;

    // 大赢家次数
    private Integer dayingjiaCount;

    // 消耗
    private Double consume;

    public Integer getUserid() {
        return userid;
    }

    public void setUserid(Integer userid) {
        this.userid = userid;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public Integer getGroupId() {
        return groupId;
    }

    public void setGroupId(Integer groupId) {
        this.groupId = groupId;
    }

    public Integer getGameCount() {
        return gameCount;
    }

    public void setGameCount(Integer gameCount) {
        this.gameCount = gameCount;
    }

    public Integer getDayingjiaCount() {
        return dayingjiaCount;
    }

    public void setDayingjiaCount(Integer dayingjiaCount) {
        this.dayingjiaCount = dayingjiaCount;
    }

    public Double getConsume() {
        return consume;
    }

    public void setConsume(Double consume) {
        this.consume = consume;
    }
}
