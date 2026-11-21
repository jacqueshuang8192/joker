//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.cache.model.CacheMerchantGoodsProfile;
//import com.hbi.model.TMerchantGoods;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TMerchantGoodsMapper extends Mapper<TMerchantGoods> {
//
//    CacheMerchantGoodsProfile queryMerchantGoodsByGoodsId(@Param("goodsId") Long goodsIs);
//
//	List<CacheMerchantGoodsProfile> queryMerchantGoodsByStoreId(@Param("storeId") Long storeId);
//
//	int updateMerchantGoodsHotAndPrice(
//			@Param("goodsId") Long goodsIs);
//}