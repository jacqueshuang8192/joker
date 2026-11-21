//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.model.TGameVersion;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TGameVersionMapper extends Mapper<TGameVersion> {
//
//    List<TGameVersion> getGameVersion(
//            @Param("gameId") Long gameId,
//            @Param("curVersion") Long curVersion);
//}