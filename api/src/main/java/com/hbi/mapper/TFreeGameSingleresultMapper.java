package com.hbi.mapper;

import java.util.Date;
import java.util.List;

import javax.swing.Spring;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TFreeGameSingleresult;
import com.hbi.model.TFreeGameTotal;


import com.core.mapper.EntityMapper;

public interface TFreeGameSingleresultMapper extends EntityMapper<TFreeGameSingleresult>{
	TFreeGameSingleresult queryGeRenSingleResult(@Param(value = "userId") Long userId,@Param(value = "startTime") String startTime,@Param(value = "endTime") String endTime);
	TFreeGameSingleresult queryGeRenSingleResult2(@Param(value = "userId") Long userId,@Param(value = "startTime") String startTime,@Param(value = "endTime") String endTime);
	List<TFreeGameSingleresult> querySingleResult(@Param(value = "rankcount") Long  rankcount,@Param(value = "startTime") String startTime,@Param(value = "endTime") String endTime);
}
