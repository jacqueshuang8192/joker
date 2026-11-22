package com.j.joker.cache.controller;

import java.util.Date;
import java.util.List;

import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSON;
import com.j.joker.cache.CacheDatabaseObject;
import com.j.joker.cache.CacheDatabaseQueueObject;
import com.j.joker.cache.ICache;

@Service
public class DatabaseQueueCacheController {

	private final static String DB_QUEUE = "DB_QUEUE";
	
	public boolean queueObject(String playerId, List<CacheDatabaseObject> insertList, List<CacheDatabaseObject> updateList, ICache cache) {
		CacheDatabaseQueueObject queueObj = new CacheDatabaseQueueObject();
		queueObj.setPlayerId(playerId);
		queueObj.setDate(new Date());

		queueObj.setInsertList(insertList);
		queueObj.setUpdateList(updateList);
		
		return cache.rpush(DB_QUEUE, JSON.toJSONString(queueObj)) > 0;
	}
	
//	public boolean insertObject(Object obj, String playerId, ICache cache) {
//		String className = obj.getClass().getName();
//		
//		String queueKey = cache.hget(DB_QUEUE, className);
//		
//		if (StringUtils.isBlank(queueKey)) {
//			queueKey = DB_INSERT_QUEUE_PREFIX + className;
//			
//			cache.hset(DB_QUEUE, className, queueKey);
//		}
//		
//		CacheDatabaseQueueObject cacheObj = new CacheDatabaseQueueObject();
//		cacheObj.setControlType("insert");
//		cacheObj.setData(obj);
//		cacheObj.setDate(new Date());
//		cacheObj.setPlayerId(playerId);
//		
//		return cache.lpush(queueKey, JSON.toJSONString(cacheObj)) > 0;
//	}
//	
//	public boolean updateObject(Object obj, String playerId, ICache cache) {
//		String className = obj.getClass().getName();
//		
//		String queueKey = cache.hget(DB_QUEUE, className);
//		
//		if (StringUtils.isBlank(queueKey)) {
//			queueKey = DB_INSERT_QUEUE_PREFIX + className;
//			
//			cache.hset(DB_QUEUE, className, queueKey);
//		}
//		
//		CacheDatabaseQueueObject cacheObj = new CacheDatabaseQueueObject();
//		cacheObj.setControlType("insert");
//		cacheObj.setData(obj);
//		cacheObj.setDate(new Date());
//		cacheObj.setPlayerId(playerId);
//		
//		return cache.lpush(queueKey, JSON.toJSONString(cacheObj)) > 0;
//	}
}
