//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.cache.model.CacheStoreCategory;
//import com.hbi.model.TStoreCategory;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TStoreCategoryMapper extends Mapper<TStoreCategory> {
//
//	List<CacheStoreCategory> queryPrimaryCategories();
//
//	List<CacheStoreCategory> querySecondaryCategories(@Param("parentId") Long parentId);
//
//}