package com.j.joker.cache.controller;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.util.StringUtil;
import com.j.joker.cache.ICache;
import com.j.joker.constants.Constants;
import com.j.joker.model.TGameLevelCard;
import com.j.joker.utils.InfServerException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * Created by ceeuoo on 8/30/2016.
 */
@Service
public class RoomCardCacheController {

    private static final String GAME_ROUND_KEY = "USERPLAY_ROUND_";

    @Autowired
    private GameCacheController gameCacheController;


    public TGameLevelCard queryConfigByLevelAndRound(Integer level, Integer round, ICache cache) throws Exception {
        String content = gameCacheController.queryGameConfig(level, cache);

        //如果找不到配置就抛错
        if (StringUtil.isEmpty(content)) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "找不到组局配置");
        }
        //TGameLevelCard tGameLevelCard = new TGameLevelCard();
        JSONObject jsonContent = JSONObject.parseObject(content);

        //如果找到了配置,但是配置为空,也可以直接返回  猜拳使用
        //if (jsonContent.isEmpty()) {
        //    tGameLevelCard.setCardCount(0);
        //    return tGameLevelCard;
        //}

        //如果里面有配置  则需要判断里面的配置是否正常
        return queryConfigByLevelAndRound(level, round, jsonContent);


        //TGameConfig config = gameCacheController.queryGameConfig(level,cache);
        //String content = config.getContent();
        //JSONArray array = JSONArray.parseArray(content);
        //
        //
        //for (int i = 0; i < array.size(); i++) {
        //    JSONObject game = (JSONObject) array.get(i);
        //    if (!game.getInteger("level").equals(level)) {
        //        if (game.getJSONArray("otherGame") != null && game.getJSONArray("otherGame").size() > 0) {
        //            JSONArray otherGameArr = game.getJSONArray("otherGame");
        //            for (int j = 0; j < otherGameArr.size(); j++) {
        //                JSONObject otherGame = (JSONObject) otherGameArr.get(j);
        //                if (otherGame.getInteger("level").equals(level)) {
        //                    return queryConfigByLevelAndRound(level, round, otherGame);
        //                }
        //            }
        //        }
        //        continue;
        //    }
        //    return queryConfigByLevelAndRound(level, round, game);
        //}
        //throw new InfServerException(Constants.RETURN_CODE_FAIL, "找不到组局配置");

    }

    //public TGameLevelCard queryConfigByLevelAndRound(Integer level, Integer round, ICache cache) throws Exception {
    //    TGameConfig config = gameCacheController.queryGameConfig(cache);
    //    String content = config.getContent();
    //    JSONArray array = JSONArray.parseArray(content);
    //    for (int i = 0; i < array.size(); i++) {
    //        JSONObject game = (JSONObject) array.get(i);
    //        if (!game.getInteger("level").equals(level)) {
    //            if (game.getJSONArray("otherGame") != null && game.getJSONArray("otherGame").size() > 0) {
    //                JSONArray otherGameArr = game.getJSONArray("otherGame");
    //                for (int j = 0; j < otherGameArr.size(); j++) {
    //                    JSONObject otherGame = (JSONObject) otherGameArr.get(j);
    //                    if (otherGame.getInteger("level").equals(level)) {
    //                        return queryConfigByLevelAndRound(level, round, otherGame);
    //                    }
    //                }
    //            }
    //            continue;
    //        }
    //        return queryConfigByLevelAndRound(level, round, game);
    //    }
    //    throw new InfServerException(Constants.RETURN_CODE_FAIL, "找不到组局配置");
    //}

    private TGameLevelCard queryConfigByLevelAndRound(Integer level, Integer round, JSONObject game) throws Exception{
        JSONObject gameConfig = game.getJSONArray("gameConfig").getJSONObject(0);
        JSONArray configGroup = gameConfig.getJSONArray("configGroup");
        for (Object groupInfo : configGroup) {
            JSONObject groupObject = (JSONObject) groupInfo;
            System.out.println(groupObject.toString());
            if (groupObject.getString("config").equals("round")) {
                JSONArray configOption = groupObject.getJSONArray("configOption");
                for (Object optionInfo : configOption) {
                    JSONObject optionObject = (JSONObject) optionInfo;
                    if (optionObject.getInteger("optionValue").equals(round)) {
                        TGameLevelCard card = new TGameLevelCard();
                        card.setLevel(level);
                        card.setRound(round);
                        Integer cardCount = optionObject.getInteger("cardCount");
                        if (cardCount != null) {
                            card.setCardCount(cardCount);
                        }
                        return card;
                    }
                }
            }
        }
        throw new InfServerException(Constants.RETURN_CODE_FAIL, "找不到组局配置");
    }
}
