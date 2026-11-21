//package com.hbi.cache.controller;
//
//import org.springframework.beans.factory.annotation.Autowired;
//
//import com.alibaba.fastjson.JSONObject;
//import com.hbi.cache.ICache;
//import com.hbi.cache.cacheWritter.SystemCacheLoader;
//import com.hbi.model.TClientVersion;
//
//public class SystemCacheController {
//    /**
//     * 游戏版本号
//     */
//    private static final String GAME_VERSION_KEY = "GAME_VERSION_";
//
//    /**
//     * 系统版本号
//     */
//    private static final String SYSTEM_VERSION_KEY = "SYSTEM_VERSION";
//
//    @Autowired
//    private SystemCacheLoader systemCacheLoader;
//
//    public TClientVersion querySystemVersion(Long curVersion, ICache cache) {
//        String key = SYSTEM_VERSION_KEY;
//        TClientVersion systemVersion = cache.getObj(key, TClientVersion.class);
//        if(systemVersion == null) {
//            systemVersion = systemCacheLoader.getSystemVersion(curVersion);
//            cache.set(key, JSONObject.toJSONString(systemVersion));
//        }
//        return systemVersion;
//    }
//}
