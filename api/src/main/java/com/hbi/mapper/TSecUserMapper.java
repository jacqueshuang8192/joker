package com.hbi.mapper;


import java.math.BigDecimal;
import java.util.List;
import org.apache.ibatis.annotations.Param;

import com.hbi.model.TGameConfig;
import com.hbi.model.TSecUser;

import tk.mybatis.mapper.common.Mapper;

public interface TSecUserMapper extends Mapper<TSecUser> {
    int updateSellCount(
            @Param("userId")Long userId,
            @Param("sellCount")Integer sellCount);
    int changeSellCount(
            @Param("userId")Long userId,
            @Param("sellCount")Integer sellCount);
    int increaseSecondLayerSellCount(
            @Param("userId")Long userId,
            @Param("secondLayerSellCount")Long secondLayerSellCount);
    int updatePlayerCount(
            @Param("userId")Long userId,
            @Param("count")Integer count);
    Long selectProvinceIdByAgentId(@Param("userId") Long userId);
    void updateCardNum(
            @Param("userId")Long userId,
            @Param("cardNum")Integer cardNum);

    Integer queryAgentLevelByAgentId(@Param("userId") Long userId);
    Long queryParentIdByUserId(@Param("userId") Long userId);

    int isOverByCeshiManager();

    String selectByLoginName(@Param("loginName") String loginName);

    void insertIntoImsTpUser(@Param("userId")Long userId,
                             @Param("loginName")String loginName,
                             @Param("password")String password,
                             @Param("phone")String phone,
                             @Param("wechat")String wechat,
                             @Param("smallIcon")String smallIcon,
                             @Param("nickName")String nickName,
                             @Param("agentId")Long agentId);
}