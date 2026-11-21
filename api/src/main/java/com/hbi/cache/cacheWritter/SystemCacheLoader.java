//package com.hbi.cache.cacheWritter;
//
//import java.util.List;
//
//import org.springframework.beans.factory.annotation.Autowired;
//
//import com.hbi.cache.model.CacheSystemVersion;
//import com.hbi.mapper.TClientVersionMapper;
//import com.hbi.mapper.TGameVersionMapper;
//import com.hbi.model.TClientVersion;
//import com.hbi.model.TGameVersion;
//
//public class SystemCacheLoader {
//
//    @Autowired
//    private TClientVersionMapper clientVersionMapper;
//    @Autowired
//    private TGameVersionMapper gameVersionMapper;
//
//    public TClientVersion getSystemVersion(Long curVersion) {
//        List<TClientVersion> versions = clientVersionMapper.getSystemVersion(curVersion);
//        TClientVersion updateVersion = versions.get(0);
//        int isManual = 0;
//        for (TClientVersion clientVersion : versions) {
//            if (clientVersion.getVersion() > updateVersion.getVersion()) {
//                updateVersion = clientVersion;
//            }
//            if(clientVersion.getIsmanual() == 1) {
//                isManual = 1;
//            }
//        }
//        updateVersion.setIsmanual(isManual);
//        return updateVersion;
//    }
//
//    public TGameVersion getGameVersion(Long gameId, Long curVersion) {
//        List<TGameVersion> versions = gameVersionMapper.getGameVersion(gameId, curVersion);
//        TGameVersion updateVersion = versions.get(0);
//        int isManual = 0;
//        for (TGameVersion gameVersion : versions) {
//            if (gameVersion.getVersion() > updateVersion.getVersion()) {
//                updateVersion = gameVersion;
//            }
//            if(gameVersion.getIsmanual() == 1) {
//                isManual = 1;
//            }
//        }
//        updateVersion.setIsmanual(isManual);
//        return updateVersion;
//    }
//}
