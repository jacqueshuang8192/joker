//package com.hbi.service.helper;
//
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.CaptureCacheController;
//import com.hbi.cache.controller.PlayerCacheController;
//import com.hbi.cache.model.CachePlayerProfile;
//import com.hbi.cache.model.CacheUserProfile;
//import com.hbi.model.TVipLevel;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
///**
// * Created by ceeuoo on 4/5/2016.
// */
//@Service
//public class VipValidator {
//    @Autowired
//    private CaptureCacheController captureCacheController;
//    @Autowired
//    private PlayerCacheController playerCacheController;
////    @Autowired
////    private
//
//    public boolean canCapture(CachePlayerProfile player, ICache cache) throws Exception {
//        TVipLevel vipLevel = playerCacheController.queryVipLevel(player.getVipLevel(), cache);
//        Integer captureTimes = vipLevel.getCaptureTimes();
//        if (captureTimes == 0) {
//            return false;
//        }
//        return true;
//    }
//
//    public boolean canCreateDating(CacheUserProfile user, ICache cache) throws Exception {
//        CachePlayerProfile playerProfile = (CachePlayerProfile)user;
//        TVipLevel vipLevel = playerCacheController.queryVipLevel(playerProfile.getVipLevel(), cache);
//        Integer canCreateDating = vipLevel.getCanCreateDating();
//        if (canCreateDating > 0) {
//            return true;
//        }
//        return false;
//    }
//
//    public boolean canBuyLoudSpeaker(CachePlayerProfile playerProfile, ICache cache) {
//        TVipLevel vipLevel = playerCacheController.queryVipLevel(playerProfile.getVipLevel(), cache);
//        Integer canBuyLoudSpeaker = vipLevel.getCanBuyLoudspeaker();
//        if (canBuyLoudSpeaker > 0) {
//            return true;
//        }
//        return false;
//    }
//
//    public boolean canCaptureRegenerate(CachePlayerProfile playerProfile, ICache cache) {
//        TVipLevel vipLevel = playerCacheController.queryVipLevel(playerProfile.getVipLevel(), cache);
//        Integer canCaptureRegenerate = vipLevel.getCanCaptureRegenerate();
//        if (canCaptureRegenerate > 0) {
//            return true;
//        }
//        return false;
//    }
//
//    public boolean canCaptureSpell(CachePlayerProfile playerProfile, ICache cache) {
//        TVipLevel vipLevel = playerCacheController.queryVipLevel(playerProfile.getVipLevel(), cache);
//        Integer canCaptureSpell = vipLevel.getCanCaptureSpell();
//        if (canCaptureSpell > 0) {
//            return true;
//        }
//        return false;
//    }
//}
