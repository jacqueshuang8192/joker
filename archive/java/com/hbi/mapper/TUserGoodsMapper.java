//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.model.TUserGoods;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TUserGoodsMapper extends Mapper<TUserGoods> {
//	List<TUserGoods> queryAllByCompere(
//			@Param("compereId") Long compereId);
//
//	List<TUserGoods> queryUserGoodsByUserId(
//			@Param("userId") Long userId, @Param("categoryType") String categoryType);
//
//	/**
//	 * 增加用户背包道具数量
//	 * @param userGoods
//	 * @return
//	 */
//	int addUserGoodsAmount(@Param("userGoods")TUserGoods userGoods);
//
//	/**
//	 * 减少用户背包道具数量
//	 * @param userGoods
//	 * @return
//	 */
//	int reduceUserGoodsAmount(@Param("userGoods")TUserGoods userGoods);
//}