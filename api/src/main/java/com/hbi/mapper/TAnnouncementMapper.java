package com.hbi.mapper;

import java.util.Date;
import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TAnnouncement;

import tk.mybatis.mapper.common.Mapper;

public interface TAnnouncementMapper extends Mapper<TAnnouncement> {

    List<TAnnouncement> queryAnnouncementsByType(@Param("type") String type, @Param("nowDate") Date nowDate);

}