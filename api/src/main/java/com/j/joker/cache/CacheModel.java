package com.j.joker.cache;

import java.util.Map;

import com.j.joker.core.beanUtil.BeanMapUtils;
import com.j.joker.vo.response.base.BaseResultVo;

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
