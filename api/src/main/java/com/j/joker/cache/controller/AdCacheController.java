package com.j.joker.cache.controller;

import com.alibaba.fastjson.JSON;
import com.j.joker.cache.ICache;
import com.j.joker.cache.cacheWritter.AdCacheLoader;
import com.j.joker.model.TAd;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Created by ceeuoo on 5/19/2016.
 */
@Service
public class AdCacheController {

    @Autowired
    private AdCacheLoader adCacheLoader;

    private static final String ADS_PREFIX = "ADS";
    public List<TAd> queryAds(ICache cache) {
        String key = ADS_PREFIX;
        List<TAd> ads = new ArrayList<TAd>();
        if (cache.exist(key)) {
            Map<String, String> map = cache.hgetAll(key);
            Set<String> fields = map.keySet();
            for(String f : fields) {
                String str = map.get(f);
                ads.add(JSON.parseObject(str, TAd.class));
            }
        } else {
            ads = adCacheLoader.queryAds();
            for (TAd d : ads) {
                cache.hset(key, d.getId().toString(), JSON.toJSONString(d));
            }
        }
        return ads;
    }
}
