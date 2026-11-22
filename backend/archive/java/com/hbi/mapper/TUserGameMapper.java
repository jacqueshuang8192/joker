//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.model.TUserGame;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TUserGameMapper extends Mapper<TUserGame> {
//
//	List<TUserGame> queryUserGameDanByUserId(@Param("userId")Long userId);
//
//	TUserGame loadUserGameByUserIdAndGameId(@Param("userId")Long userId,
//											@Param("gameId")Long gameId);
//}