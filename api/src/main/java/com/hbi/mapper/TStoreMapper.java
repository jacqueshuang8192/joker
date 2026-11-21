//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.cache.model.CacheMerchantStoreProfile;
//import com.hbi.cache.model.CacheStoreCategory;
//import com.hbi.model.TStore;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TStoreMapper extends Mapper<TStore> {
//
//    List<String> queryStoreIdsByPrimaryCategory(@Param("cityId") Long cityId, @Param("categoryId") Long categoryId);
//
//    List<String> queryStoreIdsBySecondaryCategory(@Param("cityId") Long cityId, @Param("categoryId") Long categoryId);
//
//    CacheMerchantStoreProfile queryStoreById(@Param("storeId") Long storeId);
//
//    List<CacheStoreCategory> queryPrimaryCategoryStoreCountByCityId(@Param("cityId") Long cityId);
//
//    List<CacheStoreCategory> querySecondaryCategoryStoreCountByCityId(@Param("cityId") Long cityId);
//}