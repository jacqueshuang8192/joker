//package com.hbi.mapper;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.model.TMiningGameSection;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TMiningGameSectionMapper extends Mapper<TMiningGameSection> {
//    public int updateMiningSec(
//            @Param("sectionId") Long sectionId,
//            @Param("attackerId") Long attackerId,
//            @Param("mineCount") Long mineCount,
//            @Param("status") String status);
//}