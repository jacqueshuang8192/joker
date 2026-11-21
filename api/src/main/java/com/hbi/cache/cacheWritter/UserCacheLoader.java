package com.hbi.cache.cacheWritter;

//import com.hbi.mapper.TGameSignInMapper;
//import com.hbi.mapper.TMonthCardConfigMapper;
//import com.hbi.mapper.TMonthCardMapper;
import com.hbi.mapper.TUserMapper;
//import com.hbi.model.TGameSignIn;
//import com.hbi.model.TMonthCard;
//import com.hbi.model.TMonthCardConfig;
import com.hbi.model.TUser;
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
//        TUser user = userMapper.selectByPrimaryKey(userId);
//        return user.getHasMonthCard();
//    }

    public Integer isFirstCharged(Long userId) {
        TUser user = userMapper.selectByPrimaryKey(userId);
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
        TUser user = userMapper.selectByPrimaryKey(userId);
        return user.getFirstLogin();
    }
}
