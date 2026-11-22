package com.j.joker.cache.cacheWritter;

//import com.j.joker.mapper.TGameSignInMapper;
//import com.j.joker.mapper.TMonthCardConfigMapper;
//import com.j.joker.mapper.TMonthCardMapper;
import com.j.joker.mapper.TUserMapper;
//import com.j.joker.model.TGameSignIn;
//import com.j.joker.model.TMonthCard;
//import com.j.joker.model.TMonthCardConfig;
import com.j.joker.model.TUser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Created by ceeuoo on 8/1/2016.
 */
@Service
public class UserCacheLoader {
//    @Autowired
//    private TMonthCardMapper monthCardMapper;
//    @Autowired
//    private TMonthCardConfigMapper monthCardConfigMapper;
    @Autowired
    private TUserMapper userMapper;
//    @Autowired
//    private TGameSignInMapper gameSignInMapper;

//    public TMonthCard queryMonthCardById(Long userId, Integer cardType) {
//        TMonthCard card = new TMonthCard();
//        card.setUserId(userId);
//        card.setType(cardType);
//        List<TMonthCard> list = monthCardMapper.select(card);
//        if (list.size() > 0) {
//            return list.get(0);
//        }
//        return null;
//    }

//    public Integer hasMonthCard(Long userId, Integer cardType) {
//        TUser user = userMapper.findById(userId);
//        return user.getHasMonthCard();
//    }

    public Integer isFirstCharged(Long userId) {
        TUser user = userMapper.findById(userId);
        return user.getFirstCharge();
    }

//    public List<TMonthCardConfig> queryMonthCardConfigs() {
//        return monthCardConfigMapper.select(new TMonthCardConfig());
//    }
//
//    public List<TGameSignIn> queryConSignInAward() {
//        return gameSignInMapper.select(new TGameSignIn());
//    }

    public Integer isFirstLogin(Long userId) {
        TUser user = userMapper.findById(userId);
        return user.getFirstLogin();
    }
}
