package com.j.joker.cache.cacheWritter;

import com.j.joker.mapper.TGameLevelCardMapper;
import com.j.joker.model.TGameLevelCard;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Created by ceeuoo on 8/30/2016.
 */
@Service
public class RoomCardCacheLoader {

    @Autowired
    private TGameLevelCardMapper gameLevelCardMapper;

    public List<TGameLevelCard> queryGameLevelCards() {
        return gameLevelCardMapper.select(new TGameLevelCard());
    }
}
