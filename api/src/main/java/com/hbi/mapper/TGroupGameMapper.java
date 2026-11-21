package com.hbi.mapper;

import com.hbi.model.TGroupGame;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

import java.util.List;

public interface TGroupGameMapper extends EntityMapper<TGroupGame> {

	List<TGroupGame> queryValidGroupGamesByGameId(@Param("gameId") Long gameId);

	List<TGroupGame> queryAllValidGroupGames();
}
