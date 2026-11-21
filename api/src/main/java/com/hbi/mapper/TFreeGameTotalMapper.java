package com.hbi.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.hbi.cache.model.CacheCompereListProfile;
import com.hbi.model.TFreeGameResult;
import com.hbi.model.TFreeGameTotal;
import com.hbi.model.TFreeGameTotalranking;

import tk.mybatis.mapper.common.Mapper;

public interface TFreeGameTotalMapper extends Mapper<TFreeGameTotal>{
	TFreeGameTotal queryTotalGroupGeRenRank(@Param(value = "userId") Long userId);
	TFreeGameTotal queryTotalGroupGeRenRank2(@Param(value = "userId") Long userId);
	Long queryTotalByUserId(@Param(value = "userId") Long userId);
	List<TFreeGameTotal> queryTotalGroupRank(@Param(value = "rankcount") Long rankcount);
	Integer updateTotal(@Param("win") Integer win, @Param("draw") Integer draw, @Param("lose") Integer lose,
			@Param("total") Integer total, @Param("user_id") Long userId);
	
	
	
	TFreeGameTotal querytotal(@Param(value = "userId") Long userId);
	
}
