package com.hbi.cache;

import com.core.util.ConfigUtil;
import com.core.util.StringUtil;
import com.hbi.cache.redis.CacheRedisImp;

public class CacheManager {
//	public static int a = 0;
//	public static int b = 0;


	public static ICache getCache() {
		
		String cacheType = ConfigUtil.get("cache.type");
//				System.out.println("getCon:" + (a++));

		if ("redis".equals(cacheType)) {
			return CacheRedisImp.getInstance();
		}
		return null;
	}
	
	public static void releaseCache(ICache cache) {
		
		String cacheType = ConfigUtil.get("cache.type");
		if (null != cache) {
			if ("redis".equals(cacheType)) {
				CacheRedisImp.releaseCache((CacheRedisImp)cache);
			}
		}

//		System.out.println("RelCon" + b++);
		
	}
}
