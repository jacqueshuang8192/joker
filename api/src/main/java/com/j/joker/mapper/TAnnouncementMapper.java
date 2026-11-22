package com.j.joker.mapper;

import java.util.Date;
import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.j.joker.model.TAnnouncement;

import com.j.joker.core.mapper.EntityMapper;

public interface TAnnouncementMapper extends EntityMapper<TAnnouncement> {

    List<TAnnouncement> queryAnnouncementsByType(@Param("type") String type, @Param("nowDate") Date nowDate);

}