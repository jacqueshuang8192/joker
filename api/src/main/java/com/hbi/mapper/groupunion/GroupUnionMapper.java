package com.hbi.mapper.groupunion;

import com.hbi.model.TGroupUnion;
import org.apache.ibatis.annotations.Param;

/**
 * Create by Mars on 2019/5/27 15:54
 */
public interface GroupUnionMapper {

    /**
     * 添加联盟联盟
     * Create by Mars on 15:57 2019/5/27
     **/
    void add(@Param("vo") TGroupUnion vo);

    /**
     * 设置联盟联盟成员分红
     * Create by Mars on 16:39 2019/5/28
     **/
    void setBonus(
            @Param("unionId") Integer unionId,
            @Param("groupId") Integer groupId,
            @Param("bonus") Double bonus,
            @Param("palyerType") Integer playerType);

    /**
     * 设置联盟抽水
     * Create by Mars on 17:21 2019/5/28
     **/
    void setCost(
            @Param("unionId") Integer unionId,
            @Param("costPattern") Integer costPattern,
            @Param("commission") Double commission,
            @Param("costUserType") Integer costUserType);
}
