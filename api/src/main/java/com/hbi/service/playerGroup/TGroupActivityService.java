package com.hbi.service.playerGroup;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.core.util.StringUtil;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.constants.Constants;
import com.hbi.mapper.TActivityMapper;
import com.hbi.mapper.TGroupPlayerMapper;
import com.hbi.mapper.TGroupZhanjiMapper;
import com.hbi.mapper.TPlayerGroupMapper;
import com.hbi.model.*;
import com.hbi.utils.InfServerException;
import com.hbi.vo.request.common.GameResultVo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Create by Mars on 2019/6/28 15:03
 */
@Service
public class TGroupActivityService {

    @Autowired
    private TActivityMapper activityMapper;
    @Autowired
    private TGroupZhanjiMapper groupZhanjiMapper;
    @Autowired
    private TGroupPlayerMapper groupPlayerMapper;
    @Autowired
    private TPlayerGroupMapper playerGroupMapper;
    @Autowired
    private BaseCacheController baseCacheController;

    public JSONArray selectGroupActivityjiByGroupIdAndPlayerId(Integer groupId, Integer playerId, String dateStr, Integer selectAll, Integer currentPage, Integer pageSize) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            JSONArray jsonArray = new JSONArray();

            // 玩家不在这个联盟，不允许查看战绩!!
            TPlayerGroup playerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            if (playerGroup == null) {
                throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR,"玩家不在这个联盟，不允许查看战绩!!");
            }
            // 群主查全部
            Integer tempUid = playerId;
            if(selectAll != null && selectAll == 1) {
                TGroupPlayer tGroupPlayer = groupPlayerMapper.selectByPrimaryKey(groupId);
                if (tGroupPlayer.getOwerId().equals(playerId)) {
                    tempUid = null;
                }
            }
            Integer pageIndex = (currentPage - 1) * pageSize;

            List<TGroupZhanji> zhanjis = groupZhanjiMapper.selectByMyExample(groupId,tempUid,dateStr,pageIndex,pageSize);

            for (TGroupZhanji zhanji : zhanjis) {
                JSONObject jsonObject = new JSONObject();

                jsonObject.put("userId",zhanji.getPlayerId());
                jsonObject.put("nickName",baseCacheController.queryUserNickName(cache,zhanji.getPlayerId()));
                jsonObject.put("photoUrl",baseCacheController.queryUserPhoto(cache,zhanji.getPlayerId()));

                jsonObject.put("activityId", zhanji.getActivityId());
                if (!StringUtil.isEmpty(zhanji.getLevel())) {
                    TGame tGame =  baseCacheController.queryGameById(Long.parseLong(zhanji.getLevel() + ""),cache);
                    if (!StringUtil.isEmpty(tGame)) {
                        jsonObject.put("activityName", tGame.getName());
                    }
                }
                jsonObject.put("startDate",zhanji.getCreateTime());
                jsonObject.put("endDate", zhanji.getCreateTime());
                jsonObject.put("round", zhanji.getRound());
                jsonObject.put("roomNum",zhanji.getInviteCode());
                jsonObject.put("score", zhanji.getPlayPointCount());
                jsonArray.add(jsonObject);
            }

//            int l = playerId % 10;
//            List<GameResultVo> gameResultVos = groupPlayerMapper.selectGameResultVos(l,groupId,tempUid,dateStr,pageIndex,pageSize);
//            for (GameResultVo vo : gameResultVos) {
//                JSONObject jsonObject = new JSONObject();
//                JSONObject contextJson = JSONObject.parseObject(vo.getContent());
//
//                jsonObject.put("userId",playerId);
//                jsonObject.put("nickName",baseCacheController.queryUserNickName(cache,playerId));
//                jsonObject.put("photoUrl",baseCacheController.queryUserPhoto(cache,playerId));
//
//                jsonObject.put("activityId", vo.getActivityId());
//                jsonObject.put("activityName", contextJson.getString("gameName"));
//                jsonObject.put("startDate", vo.getCreateTime());
//                jsonObject.put("endDate", vo.getCreateTime());
//                jsonObject.put("round", vo.getRoundIndex());
//                jsonObject.put("roomNum",contextJson.getString("roomNum"));
//                int score = 0;
//                JSONArray userinfos = contextJson.getJSONArray("userinfos");
//                for (int i = 0; i< userinfos.size(); i++) {
//                    JSONObject user = userinfos.getJSONObject(i);
//                    Integer uid = user.getInteger("uid");
//                    if (playerId.equals(uid)) {
//                        score = user.getInteger("score");
//                    }
//                }
//                jsonObject.put("score", score);
//                jsonArray.add(jsonObject);
//            }
//            List<TActivity> activities = activityMapper.selectByGroupIdAndPlayerId(groupId, playerId, dateStr, pageIndex, pageSize);
//            for (TActivity activity : activities){
//                JSONObject jsonObject = new JSONObject();
//                jsonObject.put("userId",cache.hget(Constants.PLAYER_ + activity.getPlayerId(),"userId"));
//                jsonObject.put("nickName",cache.hget(Constants.PLAYER_ + activity.getPlayerId(),"nickName"));
//                jsonObject.put("photoUrl",cache.hget(Constants.PLAYER_ + activity.getPlayerId(),"photoUrl"));
//
//                jsonObject.put("activityId", activity.getActivityId());
//                jsonObject.put("activityName", activity.getActivityName());
//                jsonObject.put("startDate", activity.getStartDate());
//                jsonObject.put("endDate", activity.getEndDate());
//                jsonObject.put("round", activity.getRound());
//                jsonObject.put("score", activity.getScore());
//                jsonArray.add(jsonObject);
//            }
            return jsonArray;
        }catch (Exception e) {
            throw e;
        }finally {
            if ( null != cache) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public JSONArray selectGroupZhanjiByActivityId(Integer activityId) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            JSONArray jsonArray = new JSONArray();
            List<TGroupZhanji> zhanjis = groupZhanjiMapper.selectByActivityId(activityId);
            for (TGroupZhanji tgz : zhanjis){
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("id", tgz.getId());
                jsonObject.put("activityId", tgz.getActivityId());
                jsonObject.put("createTime", tgz.getCreateTime());
                jsonObject.put("isDayingjia", tgz.getIsDayingjia());
                jsonObject.put("score", tgz.getPlayPointCount());

                jsonObject.put("userId",cache.hget(Constants.PLAYER_ + tgz.getPlayerId(),"userId"));
                jsonObject.put("nickName",cache.hget(Constants.PLAYER_ + tgz.getPlayerId(),"nickName"));
                jsonObject.put("photoUrl",cache.hget(Constants.PLAYER_ + tgz.getPlayerId(),"photoUrl"));
                jsonArray.add(jsonObject);
            }
            return jsonArray;
        }catch (Exception e) {
            throw e;
        }finally {
            if ( null != cache) {
                CacheManager.releaseCache(cache);
            }
        }
    }
}
