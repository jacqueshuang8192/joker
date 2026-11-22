package com.j.joker.mapper;

import com.j.joker.model.TGroupGame;
import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

import java.util.List;

public interface TGroupGameMapper extends EntityMapper<TGroupGame> {

	List<TGroupGame> queryValidGroupGamesByGameId(@Param("gameId") Long gameId);

	List<TGroupGame> queryAllValidGroupGames();
}
