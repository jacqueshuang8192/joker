package com.j.joker.shardbatis;

import java.util.HashMap;

import com.j.joker.model.BullfightGameinfo;

public class ShardStrategyImpl  {
	/**
	 * 得到实际表名
	 * 
	 * @param baseTableName 逻辑表名,一般是没有前缀或者是后缀的表名
	 * @param params 		mybatis执行某个statement时使用的参数
	 * @param mapperId 		mybatis配置的statement id
	 * @return
	 */
	public String getTargetTableName(String baseTableName, Object params, String mapperId) {
		Integer k = 0;
		if ("bullfight_gameinfo".equalsIgnoreCase(baseTableName)) {
			@SuppressWarnings("unchecked")
            Long id = ((BullfightGameinfo) ((HashMap<String, Object>)params).get("bullfight_gameinfo")).getMid().longValue();
			k = (int) (id % 10);
			
		}
		return baseTableName + k;
	}

//	public String getTargetTableName(String baseTableName, Object params, String mapperId) {
//		Integer k = 0;
//		if ("game_info".equalsIgnoreCase(baseTableName)) {
//			@SuppressWarnings("unchecked")
//			Long id = ((GameInfo) ((HashMap<String, Object>)params).get("gameInfo")).getMid();
//			k = (int) (id % 100);
//
//		}
//		return baseTableName + "_" + k;
//	}
}
