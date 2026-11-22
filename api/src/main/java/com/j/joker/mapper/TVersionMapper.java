package com.j.joker.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.j.joker.model.TVersion;

import com.j.joker.core.mapper.EntityMapper;

public interface TVersionMapper extends EntityMapper<TVersion> {

    List<TVersion> queryNewestApplicationVersions();

    List<TVersion> queryNewestGameHallVersions();

    List<TVersion> queryNewestGameVersionByGameIds(@Param("gameId") Long gameId);
    TVersion queryVersionByGameIds(@Param("gameId") Long gameId);
}