package com.hbi.service.common;

import java.util.List;

import com.alibaba.fastjson.JSONArray;
import com.hbi.constants.AnnounceConstants;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.model.TAnnouncement;

@Service
public class BaseDataService {

    @Autowired
    private BaseCacheController baseCacheController;
    
    public JSONArray queryAnnouncementByType(String type) throws Exception {
        ICache cache = null;
        JSONArray array = new JSONArray();
        try {
            cache = CacheManager.getCache();
            if (StringUtils.isNotBlank(type)) {
                List<TAnnouncement> list = baseCacheController.queryAnnouncementsByType(type, cache);
                if (CollectionUtils.isNotEmpty(list)) {
                    array.add(list);
                }
            } else {
                type = AnnounceConstants.ANNOUNCE_TYPE_ROOM_CARD;
                array.add(baseCacheController.queryAnnouncementsByType(type, cache));
                type = AnnounceConstants.ANNOUNCE_TYPE_ZOUMADENG;
                array.add(baseCacheController.queryAnnouncementsByType(type, cache));
                type = AnnounceConstants.ANNOUNCE_TYPE_MESSAGE;
                array.add(baseCacheController.queryAnnouncementsByType(type, cache));
            }
            return array;
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public String queryConfig(String type) {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            String s = baseCacheController.queryConfig(type, cache);
            return s;
        }catch (Exception e ) {
            System.out.println(e.getMessage());
        }finally {
            CacheManager.releaseCache(cache);
        }
        return null;
    }
}
