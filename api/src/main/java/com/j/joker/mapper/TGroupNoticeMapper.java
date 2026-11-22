package com.j.joker.mapper;

import com.j.joker.model.TGroupNotice;
import com.j.joker.model.TMsgPlayerGroup;
import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

/**
 * Create by Mars on 2019/6/12 17:45
 */
public interface TGroupNoticeMapper extends EntityMapper<TMsgPlayerGroup> {

    /**
     * 根据群组ID查询公告
     */
    TGroupNotice getByGroupId(@Param("groupId") Integer groupId);

    /**
     * 添加公告
     */
    void insertTGroupNotice(@Param("notice") TGroupNotice tGroupNotice);

    /**
     * 修改公告
     */
    void updateTGroupNotice(@Param("notice") TGroupNotice tGroupNotice);

}
