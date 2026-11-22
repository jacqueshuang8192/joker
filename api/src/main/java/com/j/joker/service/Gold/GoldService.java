package com.j.joker.service.Gold;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.beanUtil.MapUtils;
import com.j.joker.core.util.ConfigUtil;
import com.j.joker.core.util.RedisUtil;
import com.j.joker.core.util.StringUtil;
import com.j.joker.cache.CacheManager;
import com.j.joker.cache.ICache;
import com.j.joker.cache.controller.BaseCacheController;
import com.j.joker.cache.controller.GameCacheController;
import com.j.joker.cache.controller.GoldCacheController;
import com.j.joker.cache.controller.PlayerCacheController;
import com.j.joker.constants.Constants;
import com.j.joker.mapper.GoldMapper;
import com.j.joker.mapper.TUserMapper;
import com.j.joker.model.TUser;
import com.j.joker.service.charge.BaseChargeService;
import com.j.joker.service.roomcard.RoomCardService;
import com.j.joker.utils.GameServerUtil;
import com.j.joker.utils.InfServerException;
import com.j.joker.vo.response.Response;
import com.j.joker.vo.response.gold.pickUpGoldVo;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/**
 * Created by muzi on 16/11/2017.
 */
@Service
public class GoldService {

    private static final Logger LOGGER = Logger.getLogger(GoldService.class);
    private static final String MEMDATA = "MEMDATA_";
    private static final String PLAYER = "PLAYER_";
    private static final String GOLDRANKING = "GOLDRANKING";


    @Autowired
    private GoldCacheController goldCacheController;
    @Autowired
    private GoldMapper goldMapper;
    @Autowired
    private PlayerCacheController playerCacheController;
    @Autowired
    private RoomCardService roomCardService;
    @Autowired
    private BaseChargeService baseChargeService;
    @Autowired
    private TUserMapper userMapper;
    @Autowired
    private GameCacheController gameCacheController;
    @Autowired
    private BaseCacheController baseCacheController;

    public Map<String,String> getPlayerCountByPlayerBind(Long playerId) throws Exception {
        ICache cache = null;

        try {
            cache = CacheManager.getCache();
            Map<String,String> map = goldCacheController.getPlayerCountByPlayerBind(playerId,cache);
            return map;
        }catch (Exception e ) {
            LOGGER.error(e.getMessage());
            throw e;
        }finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }



    public void authIdCard(Long playerId, String name, String idCardNo, String phone) throws Exception {

        try {
            goldMapper.updateAuthIdCard(playerId,name,idCardNo,phone);
        }catch (Exception e ) {
            LOGGER.error(e.getMessage());
            throw e;
        }
    }

    public void complaint2Admin(Long playerId, String context) throws Exception {
        try {
            goldMapper.complaint2Admin(playerId,"game",context,new Date());
        }catch (Exception e ) {
            LOGGER.error(e.getMessage());
            throw e;
        }

    }

    public Map<String,String> getUserInfo(Long playerId) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            String nickName = playerCacheController.getNickName(playerId, cache);

            Map<String,String> map = goldCacheController.getUserInfo(playerId ,cache);
            map.put("nickName",nickName);
            Integer cardCount = roomCardService.queryRoomCardCount(playerId);
            map.put("cardCount",cardCount.toString());


            return map;
        }catch (Exception e ) {
            LOGGER.error(e.getMessage());
            throw e;
        }finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void saveSigName(Long playerId, String context) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            goldCacheController.saveSigName(playerId,context,cache);
        }catch (Exception e ) {
            LOGGER.error(e.getMessage());
            throw e;
        }finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public Response getConfigByGameType(String isGoldRoom) throws Exception {
        ICache cache  = null;
        try {
            cache = CacheManager.getCache();
            Response response = new Response();
            String result = goldCacheController.getConfigByGameType(isGoldRoom,cache);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);
            return response;
        }catch (Exception e ) {
            LOGGER.error(e.getMessage());
            throw e;
        }finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public Response getGameTypeByRoomType(Integer roomType) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            Response response = new Response();

            JSONObject result = goldCacheController.getGameTypeByRoomType(roomType,cache);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);
            return response;
        }catch (Exception e ) {
            LOGGER.error(e.getMessage());
            throw e;
        }finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public Response getGameConfigByLevel(Integer level) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            Response response = new Response();
            String result = gameCacheController.queryGameConfig(level,cache);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);
            return response;
        }catch (Exception e ) {
            LOGGER.error(e.getMessage());
            throw e;
        }finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }

    }

    public Long queryGoldCount(Long userId) throws Exception {
        ICache cache = null;
        try {
//            cache = CacheManager.getCache();
//            return goldCacheController.queryGoldCount(userId,cache);
            String s = GameServerUtil.invokeQuery(userId);
            if (StringUtil.isEmpty(s)) {
                return 0L;
            }else {
                JSONObject jsonObject = JSONObject.parseObject(s);
                return jsonObject.getLong("coinAmount");
            }
        }catch (Exception e ) {
        LOGGER.error(e.getMessage());
            throw e;
        }finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public Long queryRepositoryMney(Long userId) {
        Long l = userId%10;
        return goldMapper.queryRepositoryMney(l,userId);
    }

    public Response save2repository(Long playerId, Long count, Long type) throws Exception {
        ICache cache = null;
        try {
            Response response = new Response();
            cache = CacheManager.getCache();
            //如果是存的话 检测玩家的房卡是否足够
            if (type == 0) {
//                Long goldCount = goldCacheController.queryGoldCount(playerId, cache);
                Long goldCount = queryGoldCount(playerId);
                if ( count > goldCount) {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL,"您好,您存入的金币大于您持有的金币,请重新输入!!");
                }

                baseChargeService.playerGoldRecharge(1,playerId,-Integer.parseInt(count.toString()));
                goldCacheController.insertIntoMoneyRepository(playerId,count,type);

                response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
                response.setData("操作成功!!");
                return response;
            }

            if (type == 1) {
                long l = playerId % 10;
                Long repositoryMoney = goldMapper.getRepositoryMoney(l,playerId);
                if (count > repositoryMoney) {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL,"您好,您仓库的金币小于您提取的金币,请重新输入!!");
                }

                baseChargeService.playerGoldRecharge(1,playerId,Integer.parseInt(count.toString()));
                goldCacheController.insertIntoMoneyRepository(playerId,count,type);

                response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
                response.setData("操作成功!!");
                return response;

            }


            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setData("操作失败!!");
            return response;

        }catch (Exception e ) {
            LOGGER.error(e.getMessage());
            throw e;
        }finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }


    public Integer queryRoomOwnerIncome(Long userId) {

        TUser user = userMapper.findById(userId);

        //Long gold = goldMapper.queryRoomOwnerIncome(userId);
        //if (gold == null || "".equals(gold)) {
        //    gold = 0l;
        //}
        return user.getGiftGold() ;
    }

    public Response pickUpGold(Long playerId, Long count) throws Exception {
        ICache cache = null;
        try {
            Response response = new Response();
            cache = CacheManager.getCache();
            //如果是存的话 检测玩家的房卡是否足够
            TUser user = userMapper.findById(playerId);

            if ( count < 0 || count > user.getGiftGold()) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"您好,您提取的金币大于您持有的金币,请重新输入!!");
            }

            userMapper.pickUpGold(playerId,count);

            baseChargeService.playerGoldRecharge(1,playerId,Integer.parseInt(count.toString()));
            goldMapper.insertIntoReposity(playerId,count,3L);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("操作成功!!");
            return response;
        }catch (Exception e ) {
            LOGGER.error(e.getMessage());
            throw e;
        }finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public List<pickUpGoldVo> getPickUpGoldList(Long playerId, String currentPage, String pageSize) {

        if (StringUtil.isEmpty(pageSize)) {
            pageSize = "10";
        }
        Integer beginRowIndex = (Integer.parseInt(currentPage)-1)*(Integer.parseInt(pageSize));

        if (beginRowIndex < 0) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"请输入正确的页数");
        }


        return goldMapper.getPickUpGoldList(playerId,beginRowIndex,Integer.parseInt(pageSize));
    }

    public String getGoldRanking() throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();

            //获取真是的排行榜
            String s = cache.get(GOLDRANKING);
            if (StringUtil.isEmpty(s)){
                updateGoldRanking();
                s = cache.get(GOLDRANKING);
            }


            JSONArray objects = JSONObject.parseArray(s);
            JSONArray ranking = new JSONArray();
            //获取营商的排行
            String myRanking = cache.get(GOLDRANKING + "ME");
            if (StringUtil.isNotEmpty(myRanking)) {
                JSONArray myObj = JSONObject.parseArray(myRanking);
                if (!myObj.isEmpty()) {
                    for (int i = 0; i< myObj.size(); i++){
                        JSONObject jsonObject = myObj.getJSONObject(i);
                        ranking.add(0,jsonObject);
                    }
                }
            }
            for (int i = 0; i < objects.size(); i++) {
                ranking.add(objects.get(i));
            }
            return ranking.toJSONString();
        }catch (Exception e ) {
            LOGGER.error(e.getMessage());
            throw e;
        }finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }

    }


//    @Scheduled(cron="${goldranking.update.time}")//财富榜  每隔半个小时刷新一次
//    public void doUpdateGoldRanking() {
//        updateGoldRanking();
//    }

    private void updateGoldRanking() {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();

            String rankType = ConfigUtil.get("rankType");

            if ("1".equals(rankType)) {
                Map<String,Integer> map = new TreeMap<String, Integer>();

                int y = 0;
                List<Integer> list = goldMapper.selectAllPlayerId();
                for (Integer user: list) {
                    y++;
                    if (y%100 == 0) {
                        Thread.sleep(10);
                    }
                    String money = RedisUtil.getRu().hget(MEMDATA + user, "MONEY");
                    if (StringUtil.isNotEmpty(money)) {
                        map.put(user.toString(),Integer.parseInt(money));
                    }

                }
                Map<String, Integer> result = MapUtils.sortByValue(map);

                int i = 0;

                JSONArray objects = new JSONArray();
                for (Map.Entry<String, Integer> entry : result.entrySet()) {
                    JSONObject js = new JSONObject();
                    Long gold = queryGoldCount(Long.parseLong(entry.getKey()));
                    i++;
                    if(i%200 == 0) {
                        Thread.sleep(10);
                    }
                    String nickName = playerCacheController.getNickName(Long.parseLong(entry.getKey()), cache);

                    String key = PLAYER + entry.getKey();
                    String sign = cache.hget(key, "SIGN");
                    if (StringUtil.isEmpty(sign)) {
                        sign = userMapper.getSign(Long.parseLong(entry.getKey()));
                        if (StringUtil.isNotEmpty(sign)) {
                            cache.hset(key, "SIGN", sign);
                        }
                    }

                    String photoUrl = playerCacheController.getPhotoUrl(Long.parseLong(entry.getKey()), cache);

                    js.put("goldCount",gold);
                    js.put("nickNmae",nickName);
                    js.put("sign",sign);
                    js.put("headURL",photoUrl);
                    System.out.println(js.toJSONString() + i + "....");
                    objects.add(js);
                    i++;
                    if ( i > 10 ) {
                        break;
                    }

                }
                String key = GOLDRANKING;

                String s = cache.get(key);
                if (StringUtil.isNotEmpty(s)) {
                    cache.del(key);
                    cache.set(key,objects.toJSONString());
                }else {
                    cache.set(key,objects.toJSONString());
                }
            }
            if ("2".equals(rankType)) {
                String rankNum = ConfigUtil.get("rankNum");
                List<TUser> list =  userMapper.selectMaxPoint(rankNum);
                JSONArray objects = new JSONArray();
                for (TUser user : list) {
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("goldCount",user.getPoint());
                    jsonObject.put("headURL",user.getSmallIcon());
                    jsonObject.put("nickNmae",user.getNickName());
                    jsonObject.put("sign",user.getSign());
                    objects.add(jsonObject);
                }
                String key = GOLDRANKING;
                cache.set(key,objects.toJSONString());
            }
        }catch (Exception e ) {
            LOGGER.error(e.getMessage());
        }finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public JSONObject getPlayerCommissionList(Long playerId, Long year, Long month) throws Exception {
        ICache cache = null;
        try {
            JSONObject result = new JSONObject();
            cache = CacheManager.getCache();

            //计算这个月的收益
            String date = year+"-"+month;
            List<pickUpGoldVo> everyDay = goldMapper.getPlayerCommissionList(playerId,date);
            int count=0;
            for (pickUpGoldVo aa:everyDay) {
                count += aa.getGoldCount();
            }
            //如果是这个月,则加上当天的收益
            Date currentTime = new Date();
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
            String dateString = formatter.format(currentTime);
            String substring = dateString.substring(5, 7);
            if (substring.equals(month.toString())) {
                Integer countToday = goldMapper.selectOwerIncomeToday(playerId);
                pickUpGoldVo vo = new pickUpGoldVo();
                vo.setPlayerId(Integer.parseInt(playerId.toString()));
                vo.setGoldCount(StringUtil.isEmpty(countToday)?0:countToday);
                vo.setDate(dateString);
                everyDay.add(0,vo);

            }

            result.put("everyDay",everyDay);

            result.put("count",count);

            return result;
        }catch (Exception e ) {
            LOGGER.error(e.getMessage());
            throw e;
        }finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public String queryConfigByPayType() throws Exception {
        ICache cache = null;

        try {
            cache = CacheManager.getCache();
            String payType = baseCacheController.queryConfig("payType", cache);
            if (StringUtil.isEmpty(payType)) {
                payType = "0";
            }
            return payType;
        }catch (Exception e ) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }
    }

}
