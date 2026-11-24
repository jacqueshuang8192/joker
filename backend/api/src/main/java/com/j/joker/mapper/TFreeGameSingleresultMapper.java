package com.j.joker.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.j.joker.model.TFreeGameSingleresult;

import com.j.joker.core.mapper.EntityMapper;

public interface TFreeGameSingleresultMapper extends EntityMapper<TFreeGameSingleresult>{
	TFreeGameSingleresult queryGeRenSingleResult(@Param(value = "userId") Long userId,@Param(value = "startTime") String startTime,@Param(value = "endTime") String endTime);
	TFreeGameSingleresult queryGeRenSingleResult2(@Param(value = "userId") Long userId,@Param(value = "startTime") String startTime,@Param(value = "endTime") String endTime);
	List<TFreeGameSingleresult> listTopPlayers(@Param(value = "rankcount") Long  rankcount,@Param(value = "startTime") String startTime,@Param(value = "endTime") String endTime);

    default List<TFreeGameSingleresult> querySingleResult(Long limit, String start, String end) {
        var players = listTopPlayers(limit, start, end);
        for (int i = 0; i < players.size(); i++) players.get(i).setRank(i + 1);
        return players;
    }
}
