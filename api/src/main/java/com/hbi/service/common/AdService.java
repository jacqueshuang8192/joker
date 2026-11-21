//package com.hbi.service.common;
//
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.AdCacheController;
//import com.hbi.constants.Constants;
//import com.hbi.model.TAd;
//import com.hbi.utils.InfServerException;
//import org.apache.commons.collections.CollectionUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import java.util.List;
//import java.util.Random;
//
///**
// * Created by ceeuoo on 5/19/2016.
// */
//@Service
//public class AdService {
//
//    @Autowired
//    private AdCacheController adCacheController;
//
//    public List<TAd> queryAds() throws Exception{
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            return adCacheController.queryAds(cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public TAd queryRandomAd() throws Exception{
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<TAd> list = adCacheController.queryAds(cache);
//            if (CollectionUtils.isNotEmpty(list)) {
//                int index = new Random().nextInt(list.size());
//                return list.get(index);
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "无法获取广告列表");
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//}
