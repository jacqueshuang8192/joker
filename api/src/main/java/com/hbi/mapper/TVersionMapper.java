package com.hbi.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TVersion;

import com.core.mapper.EntityMapper;

public interface TVersionMapper extends EntityMapper<TVersion> {

    List<TVersion> queryNewestApplicationVersions();

    List<TVersion> queryNewestGameHallVersions();

    List<TVersion> queryNewestGameVersionByGameIds(@Param("gameId") Long gameId);
    TVersion queryVersionByGameIds(@Param("gameId") Long gameId);
}