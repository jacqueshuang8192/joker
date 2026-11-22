package com.j.joker.cache.controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.util.StringUtil;
import com.j.joker.cache.ICache;
import com.j.joker.mapper.BullFightGameInfoMapper;
import com.j.joker.mapper.GoldMapper;
import com.j.joker.mapper.TUserMapper;
import com.j.joker.model.TGame;
import com.j.joker.model.TGameTypeByGold;
import com.j.joker.vo.request.common.MapVo;
import com.j.joker.vo.request.common.TLevelFenChangVo;
import org.apache.commons.collections.MapUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by muzi on 16/11/2017.
 */
@Service
public class GoldCacheController {

    //玩家的相关信息
    private static final String PLAYER = "PLAYER_";
    private static final String MEMDATA = "MEMDATA_";
    private static final String SIGN = "SIGN";
    private static final String GAME_TYPE_DEDLOY = "GAME_TYPE_DEDLOY";
    private static final String GAME_TYPE_BY_ROOM_TYPE = "GAME_TYPE_BY_ROOM_TYPE";
    //private static final String GET_GAME_CONFIG_BY_LEVEL = "GET_GAME_CONFIG_BY_LEVEL";
    //private static final String GAME_CONFIG = "GAME_CONFIG";

    @Autowired
    private GoldMapper goldMapper;
    @Autowired
    private TUserMapper userMapper;
    @Autowired
    private BullFightGameInfoMapper bullFightGameInfoMapper;

    public Map<String, String> getPlayerCountByPlayerBind(Long playerId, ICache cache) {

        String key = PLAYER + playerId;
        Map<String, String> result = new HashMap<String, String>();
        Map<String, String> map = cache.hgetAll(key);
        if (MapUtils.isEmpty(map)) {
            Integer count = goldMapper.getPlayerCountByPlayerBind(playerId);
            cache.hset(key, "playerCount", count.toString());
            Integer isAgent = goldMapper.isAgent(playerId);
            //1代表是代理,0代表不是
            cache.hset(key, "isAgent", isAgent.toString());
            //返回结果
            result.put("playerCount", count.toString());
            result.put("isAgent", isAgent.toString());
        } else {
            String playerCount = map.get("playerCount");
            String isAgent = map.get("isAgent");
            if (StringUtil.isEmpty(playerCount)) {
                playerCount = goldMapper.getPlayerCountByPlayerBind(playerId) + "";
                cache.hset(key, "playerCount", playerCount);
            }
            if (StringUtil.isEmpty(isAgent)) {
                isAgent = goldMapper.isAgent(playerId) + "";
                cache.hset(key, "isAgent", isAgent);

            }
            result.put("playerCount", playerCount);
            result.put("isAgent", isAgent);
        }
        return result;
    }

    public Map<String, String> getUserInfo(Long playerId, ICache cache) {
        String key = PLAYER + playerId;
        String key1 = MEMDATA + playerId;
        Map<String, String> result = new HashMap<String, String>();

        String sign = cache.hget(key, SIGN);
        String money = cache.hget(key1, "MONEY");
        if (StringUtil.isEmpty(sign)) {
            sign = userMapper.getSign(playerId);
            cache.hset(key, SIGN, sign);
        }
        if (StringUtil.isEmpty(money)) {
            long l = playerId % 10;
            money = bullFightGameInfoMapper.selectByMoney(l, playerId);
        }
        result.put(sign, sign);
        result.put("sign", sign);


        return result;
    }

    public void saveSigName(Long playerId, String context, ICache cache) {
        String key = PLAYER + playerId;
        String sign = cache.hget(key, SIGN);

        if (StringUtil.isEmpty(context)) {
            cache.hset(key, SIGN, null);
            userMapper.updateSign(playerId, context);
            return;
        }
        if (context.equals(sign)) {
            return;
        } else {
            cache.hset(key, SIGN, context);
            userMapper.updateSign(playerId, context);
        }
    }

    public String getConfigByGameType(String roomType, ICache cache) {

        String conf = cache.get(GAME_TYPE_DEDLOY);

        if (StringUtil.isEmpty(conf)) {
            //获取游戏类型
            List<Integer> list = goldMapper.selectByRoomType(roomType);
        }

        return null;
    }

    public JSONObject getGameTypeByRoomType(Integer roomType, ICache cache) {
        String key = GAME_TYPE_BY_ROOM_TYPE;
        String value = cache.get(key);
        JSONObject js = JSON.parseObject(value);
        if (!StringUtil.isEmpty(value)) {
            return js;
        } else {
            JSONObject z = new JSONObject();
            //获取房间类型  是房卡场还是房卡场 成功
            List<MapVo> roomList = goldMapper.queryRoomTypeList();
            for (MapVo mv : roomList) {
                JSONObject a = new JSONObject();
                a.put("roomNane", mv.getMapValue());
                a.put("roomType", mv.getMapKey());

                //游戏类型  牛牛  扎金花
                List<TGameTypeByGold> gameTypes = goldMapper.queryByRoomTypeId(mv.getMapKey());
                for (TGameTypeByGold ttbg : gameTypes) {
                    JSONObject b = new JSONObject();
                    b.put("id", ttbg.getId());
                    b.put("gameTypeName", ttbg.getName());

                    //牛牛游戏的类型  金典牛牛   明牌牛牛
                    JSONArray c = new JSONArray();
                    List<TGameTypeByGold> gameTypeList = goldMapper.queryRoomTypeByParentId(ttbg.getId());
                    for (TGameTypeByGold gtl : gameTypeList) {

                        JSONObject d = new JSONObject();
                        d.put("id", gtl.getId());
                        d.put("name", gtl.getName());
                        List<TGame> gameList = goldMapper.queryGames(gtl.getId());
                        //获取分场
                        for (TGame tGame : gameList) {
                            List<TLevelFenChangVo> fenChang =  goldMapper.queryFenChangByGameId(tGame.getLevel());
                            tGame.setFenchang(fenChang);
                        }
                        d.put("gameList", gameList);
//                        c.put(gtl.getId().toString(), d);
                        c.add(d);
                    }
                    b.put("gameTypeList",c);
                    a.put(ttbg.getId().toString(),b);
                }

                z.put(mv.getMapKey(),a);

            }
            cache.set(key,z.toJSONString());
            return z;
            //for (MapVo mv : roomList) {
            //    JSONObject b = new JSONObject();
            //    b.put("roomType",mv.getMapKey());
            //    b.put("roomName",mv.getMapValue());
            //    //获取游戏
            //    List<TGameTypeByGold> gameTypeByGolds =  goldMapper.queryByRoomTypeId(mv.getMapKey());
            //
            //    for (TGameTypeByGold tgtb : gameTypeByGolds) {
            //        JSONObject c = new JSONObject();
            //        //获取游戏类型
            //        List<TGameTypeByGold> list = goldMapper.queryRoomTypeByParentId(tgtb.getId());
            //        c.put("id",list.get(0).getId());
            //        c.put("name",list.get(0).getName());
            //        for (TGameTypeByGold tt : list) {
            //            Map<String,String> tt = tt.put()
            //        }
            //
            //
            //        //for (TGameTypeByGold tg : list)  {
            //        //    //获取这个类型的所有游戏
            //        //    List<TGame> gameList =  goldMapper.queryGames(tg.getId());
            //        //    c.put("gamegameTypeList",gameList);
            //        //}
            //        b.put(tgtb.getId().toString(),c);
            //    }
            //    a.put(mv.getMapKey(),b);
            //}
            //cache.set(key,a.toJSONString());
            //
            //return a.toJSONString();
        }
    }


    //public String getGameConfigByLevel(Integer level, ICache cache) {
    //    String content = cache.hget(GET_GAME_CONFIG_BY_LEVEL, level.toString());
    //    cache.hget(GAME_CONFIG,level.toString());
    //    if (!StringUtil.isEmpty(content)) {
    //        return content;
    //    }else {
    //        String content1 = goldMapper.getGameConfigByLevel(level);
    //        cache.hset(GET_GAME_CONFIG_BY_LEVEL,level.toString(),content1);
    //        return content1;
    //    }
    //}

    public Long queryGoldCount(Long userId, ICache cache) {
        String key1 = MEMDATA + userId;

        String money = cache.hget(key1, "MONEY");
        if (StringUtil.isEmpty(money)) {
            long l = userId % 10;
            money = bullFightGameInfoMapper.selectByMoney(l, userId);
        }


        return Long.parseLong(money);
    }

    public void insertIntoMoneyRepository(Long playerId, Long count, Long type) {
        long l = playerId % 10;
        if (type==0) {
            goldMapper.updateMoneyRepository(l,playerId,count,type);
        }else {
            count = -count;
            goldMapper.updateMoneyRepository(l,playerId,count,type);
        }

        goldMapper.insertIntoReposity(playerId,count,type);
    }
}
