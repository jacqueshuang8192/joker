package com.j.joker.service.roomCard2Gold;

import com.j.joker.core.util.StringUtil;
import com.j.joker.cache.CacheManager;
import com.j.joker.cache.ICache;
import com.j.joker.cache.controller.BaseCacheController;
import com.j.joker.cache.controller.GoldCacheController;
import com.j.joker.constants.Constants;
import com.j.joker.mapper.TUserMapper;
import com.j.joker.model.TUser;
import com.j.joker.service.charge.BaseChargeService;
import com.j.joker.utils.InfServerException;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class RoomCard2GoldService {
    private static final Logger LOGGER = Logger.getLogger(RoomCard2GoldService.class);
    @Autowired
    private TUserMapper userMapper;
    @Autowired
    private BaseCacheController baseCacheController;
    @Autowired
    private BaseChargeService baseChargeService;
    @Autowired
    private GoldCacheController goldCacheController;

    public void changeByRoomCardAndGold(Long playerId, Integer category_type, Long count) throws Exception {
        ICache cache = null;

        try {
            cache = CacheManager.getCache();
            if (category_type == Constants.giftTypeCard2gold) {
                Integer roomCard = baseCacheController.queryPlayerRoomCard(playerId);
                if (roomCard < count) {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL,"您的钻石余额不足!!");
                }
                String roomCard2Gold = baseCacheController.queryConfig("roomCard2Gold", cache);
                Long gold = count * (Integer.parseInt(roomCard2Gold));
                userMapper.insertTplayerShareGiftRecord(playerId,count.toString(),gold.toString(),Constants.giftTypeCard2gold);
                baseCacheController.updateRoomCard(playerId,-Integer.parseInt(count.toString()));
                baseChargeService.playerGoldRecharge(1,playerId,Integer.parseInt(gold.toString()));

            }

            if (category_type == Constants.giftTypeGold2Card) {
                String minGold2RoomCard = baseCacheController.queryConfig("minGold2RoomCard", cache);
                if (count < Long.parseLong(minGold2RoomCard) ) {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL,"最低金币兑换数量:"+minGold2RoomCard);
                }
                Long money = goldCacheController.queryGoldCount(playerId, cache);
                if (count > money) {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL,"您的金币余额不足!!");
                }
                String gold2RoomCard = baseCacheController.queryConfig("gold2RoomCard", cache);
                Long roomCardCount = count/(Long.parseLong(gold2RoomCard));
                userMapper.insertTplayerShareGiftRecord(playerId,roomCardCount.toString(),count.toString(),Constants.giftTypeGold2Card);
                baseCacheController.updateRoomCard(playerId,Integer.parseInt(roomCardCount.toString()));
                baseChargeService.playerGoldRecharge(1,playerId,-Integer.parseInt(count.toString()));
            }
        }catch (Exception e) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }
    }

    public Integer queryMinGold2Card() {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            String minGold2RoomCard = baseCacheController.queryConfig("minGold2RoomCard", cache);
            if (StringUtil.isEmpty(minGold2RoomCard)) {
                minGold2RoomCard = "0";
            }
            return Integer.parseInt(minGold2RoomCard);
        }catch (Exception e ) {

        }finally {
            CacheManager.releaseCache(cache);
        }
        return 0;
    }
}
