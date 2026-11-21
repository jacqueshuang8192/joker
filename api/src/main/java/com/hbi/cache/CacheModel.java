package com.hbi.cache;

import java.util.Map;

import com.core.beanUtil.BeanMapUtils;
import com.hbi.vo.response.base.BaseResultVo;

public class CacheModel extends BaseResultVo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public Map<String, String> generateHashMapBySelective() throws Exception {
		try {
			return BeanMapUtils.toMapBySelective(this);
		} catch (Exception e) {
			throw e;
		}
	}
	
	
}
