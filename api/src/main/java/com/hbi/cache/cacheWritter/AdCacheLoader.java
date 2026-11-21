package com.hbi.cache.cacheWritter;

import com.hbi.mapper.TAdMapper;
import com.hbi.model.TAd;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Created by ceeuoo on 5/19/2016.
 */
@Service
public class AdCacheLoader {

    @Autowired
    private TAdMapper adMapper;

    public List<TAd> queryAds() {
        return adMapper.select(new TAd());
    }

}
