package com.hbi.mapper;

import com.hbi.model.TGroupGame;
import org.apache.ibatis.annotations.Param;
import tk.mybatis.mapper.common.Mapper;

import java.util.List;

public interface TGroupGameMapper extends Mapper<TGroupGame> {

	List<TGroupGame> queryValidGroupGamesByGameId(@Param("gameId") Long gameId);

	List<TGroupGame> queryAllValidGroupGames();
}
