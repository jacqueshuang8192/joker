package com.hbi.mapper;

import com.hbi.model.TMsgPlayerGroup;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

import java.util.List;

/**
 * Created by muzi on 2017/12/9.
 */
public interface TMsgPlayerGroupMapper extends EntityMapper<TMsgPlayerGroup> {

    List<TMsgPlayerGroup> getMsg(@Param("playerId") Integer playerId,
                                 @Param("status")String status,
                                 @Param("groupId")Integer groupId);

    public void updateStatus(@Param("playerId") Integer playerId,
                             @Param("owerId") Integer owerId,
                             @Param("groupId") Integer groupId,
                             @Param("status") Integer status);

    public void updateStatusById(@Param("msgId") Integer msgId,
                                 @Param("status") Integer status);

    Integer selectMsg(@Param("playerId") Integer playerId,
                      @Param("groupId") Integer groupId,
                      @Param("owerId") Integer owerId,
                      @Param("i") int i);
}
