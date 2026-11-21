package com.hbi.mapper;

import org.apache.ibatis.annotations.Param;

import com.core.mapper.EntityMapper;

import com.hbi.model.TRecord;

public interface TRecordMapper extends EntityMapper<TRecord> {

	/**
	 * 获取对象主键数据，步长为1
	 * @param objectClassName
	 * @return
	 */
	Long getCurrentId(@Param("objectClassName") String objectClassName);

	/**
	 * 新增对象主键当前最大值
	 * @param objectClassName
	 * @param l
	 */
	void insertRecord(@Param("objectClassName") String objectClassName,
			@Param("sequences") long sequences);

	/**
	 * 更新对象主键当前最大值
	 * @param objectClassName
	 * @param l
	 */
	void updateRecord(@Param("objectClassName") String objectClassName,
			@Param("sequences") long sequences);
}
