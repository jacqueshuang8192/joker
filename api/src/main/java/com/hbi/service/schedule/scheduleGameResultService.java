package com.hbi.service.schedule;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.core.util.ConfigUtil;
import com.core.util.RedisUtil;
import com.core.util.RedisUtil3;
import com.core.util.StringUtil;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.cache.controller.GroupPlayerCacheController;
import com.hbi.constants.Constants;
import com.hbi.mapper.*;
import com.hbi.model.*;
import com.hbi.service.playerGroup.TGroupXiaoHaoDayHistoryService;
import com.hbi.service.playerGroup.TGroupXiaoHaoHistoryService;
import com.hbi.utils.OSSUtil;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import tk.mybatis.mapper.entity.Example;

import java.sql.ResultSet;
import java.util.Date;
import java.util.List;

/**
 * Create by Mars on 2019/7/20 19:32
 */
@Service
public class scheduleGameResultService {

    private static final Log info = LogFactory.getLog("gameresult");

    private static final String GAME_RESULT_QUEUE_LOCK = "GAME_RESULT_QUEUE_LOCK";
    private static final String GAME_RESULT_QUEUE = "GAME_RESULT_QUEUE";
    private static final String GAME_RESULT_QUEUE_EXCEPTION = "GAME_RESULT_QUEUE_EXCEPTION";

    @Autowired
    private BaseCacheController baseCacheController;
    @Autowired
    private TFreeGameResultMapper freeGameResultMapper;
    @Autowired
    private TActivityMapper activityMapper;
    @Autowired
    private TPlayerGroupMapper playerGroupMapper;
    @Autowired
    private TGroupPlayerMapper groupPlayerMapper;
    @Autowired
    private GroupPlayerCacheController groupPlayerCacheController;

    @Scheduled(cron="0/3 * * * * ?")
    public void scheduleJisuan() {

        RedisUtil3 ru3 = RedisUtil3.getRu();
        long times = ru3.incr(GAME_RESULT_QUEUE_LOCK);
        if (times <= 1 ) {

            int i = 0;  //防止死循环

            try {
                while (true) {

                    String gameString = ru3.lindex(GAME_RESULT_QUEUE,0);
                    if (!StringUtil.isEmpty(gameString)) {
                        long a = System.currentTimeMillis();
                        boolean result = uploadGameResult(gameString,ru3);
                        long b = System.currentTimeMillis();
                        info.info("result--> " + result + (b-a));
                        if (result) {
                            ru3.lpop(GAME_RESULT_QUEUE);
                        }else {
                            ru3.rpush(GAME_RESULT_QUEUE_EXCEPTION,gameString);
                            ru3.lpop(GAME_RESULT_QUEUE);
                        }

                    }else {
                        break;
                    }

                    if (i >= 50) {
                        break;
                    }
                }
            }catch (Exception e ) {
                info.info(e);
            }finally {
                ru3.del(GAME_RESULT_QUEUE_LOCK);
            }
        }

    }

    private boolean uploadGameResult(String gameString,RedisUtil3 ru) {
        info.info("gameString-->"  + gameString);
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            JSONObject gameResultJson = JSONObject.parseObject(gameString);
            String activityId = gameResultJson.getString("activityId");
            String index = gameResultJson.getString("index");
            String baseChip = gameResultJson.getString("baseChip");
            String level = gameResultJson.getString("level");
            String gameTime = gameResultJson.getJSONObject("roundRoot").getString("gameTime");
            String time = StringUtil.stampToDate(gameTime + "000");
            JSONArray userinfos = gameResultJson.getJSONObject("roundRoot").getJSONArray("userinfos");
            JSONArray frame = gameResultJson.getJSONObject("roundRoot").getJSONArray("frame");
            JSONObject groupRootxx = gameResultJson.getJSONObject("groupRoot");
            Integer groupId = null;

            TGame tgame = baseCacheController.queryGameById(Long.parseLong(level),cache);
            if (!StringUtil.isEmpty(tgame)) {

                int is_gold = tgame.getIsGold();
                JSONObject contentList = new JSONObject();
                contentList.put("userinfos", userinfos);
                contentList.put("roomNumb", groupRootxx.getString("roomNum"));
                if (StringUtil.isEmpty(baseChip)) {
                    contentList.put("gameName", tgame.getName());
                } else {
                    contentList.put("gameName", tgame.getName() + "(" + baseChip + "分场)");
                }
//                contentList.put("frame", frame);

                //上传到OSS
                String replayUrl = StringUtil.dateFormat(new Date(), "yyyyMM") + "/" + activityId + "_" + level + "_"
                        + index + "_" + StringUtil.dateFormat(new Date(), "ddHHmmSSSS");

                if ("yes".equalsIgnoreCase(ConfigUtil.get("isupload2OSS"))) {
                    OSSUtil.simpleUpload(gameResultJson.getString("roundRoot"), replayUrl, ConfigUtil.get("oss.bucketName.replay"));
                }

                Example ex = new Example(TActivity.class);
                Example.Criteria criteria = ex.createCriteria();
                criteria.andEqualTo("activityId",activityId);
                List<TActivity> tActivitys = activityMapper.selectByExample(ex);
                if (!StringUtil.isEmpty(tActivitys) && tActivitys.size() >= 1) {
                    TActivity tActivity = tActivitys.get(0);
                    groupId = tActivity.getGroupId();
                }

                //循环插入每个玩家的ID
                for (int i = 0; i < userinfos.size(); i++) {
                    Integer uid = userinfos.getJSONObject(i).getInteger("uid");
                    Integer score = userinfos.getJSONObject(i).getInteger("score");
                    Integer chip = userinfos.getJSONObject(i).getInteger("chip");
                    int l = uid % 10;
                    freeGameResultMapper.insertPlayerRound(l,uid,activityId,index,is_gold,groupId);

                    //这个玩家的输赢
                    ru.hincrby(ScheduleConstants.STT_CLUB_PLAYER_POINT_CHANGE_TODAY_ + groupId, uid + "", (long) score);
                }

                freeGameResultMapper.insertFreeGameRound(activityId,contentList.toJSONString(),replayUrl,level,index,time, groupId);

                JSONObject groupRoot = gameResultJson.getJSONObject("groupRoot");
                groupRoot.put("gameName", tgame.getName());

                String groupGameStamp = groupRoot.getString("gameTime");
                String groupGameTime = StringUtil.stampToDate(groupGameStamp + "000");


                //分布将对应的userId的记录插入到横向的表中
                JSONArray jsonArray = groupRoot.getJSONArray("userinfos");
                for (int i = 0; i < jsonArray.size(); i++) {
                    JSONObject jsonObject = jsonArray.getJSONObject(i);
                    Integer uid = jsonObject.getInteger("uid");
                    long l = uid % 10;

                    Integer indexNow = freeGameResultMapper.selectPlayerResult(l,uid,activityId);
                    if (!StringUtil.isEmpty(indexNow) && indexNow > 0 && indexNow < Integer.parseInt(index)) {
                        freeGameResultMapper.updatePlayerResult(l,index,uid,activityId);
                    }else {
                        freeGameResultMapper.insertPlayerResult(l,uid,activityId,index,is_gold,groupGameTime,groupId);
                        if (!StringUtil.isEmpty(groupId)) {
                            playerGroupMapper.updateplayCountToday(1,uid,groupId);
                        }
                    }

                }

                Integer indexNow = freeGameResultMapper.selectFreeGameResult(activityId);
                if (!StringUtil.isEmpty(indexNow)  && indexNow > 0 && indexNow < Integer.parseInt(index) ) {
                    freeGameResultMapper.updateFreeGameResult(groupRoot.toJSONString(),index,activityId);
//                    if (!StringUtil.isEmpty(groupId)) {
//                        JSONArray userifos = groupRoot.getJSONArray("userinfos");
//                        String roomNum = groupRoot.getString("roomNum");
//                        for (int i =0; i < userifos.size(); i++) {
//                            JSONObject userJson = userifos.getJSONObject(i);
//                            int score =userJson.getInteger("score");
//                            int uid = userJson.getInteger("uid");
//                            groupZhanjiMapper.updateZhanjiPoint(activityId,uid,score);
//                        }
//                    }
                }else {
                    freeGameResultMapper.insertFreeGameResult(activityId,groupRoot.toJSONString(),level,groupGameTime,index,groupId);

                    //个人和团队的局数--  有bug 中途加入算不到...
                    if (!StringUtil.isEmpty(groupId) ) {
                        TGroupPlayer tgp = groupPlayerMapper.selectByPrimaryKey(groupId);
                        Integer ownerId = tgp.getOwerId();
                        for (int i = 0; i < userinfos.size(); i++) {
                            Integer uid = userinfos.getJSONObject(i).getInteger("uid");
                            ru.hincrby(ScheduleConstants.STT_CLUB_PLAYER_GAME_COUNT_TODAY_ + groupId, uid+"", 1l);
                            if (!uid.equals(ownerId) ) {
                                List<Integer> hehuorenList = groupPlayerCacheController.queryHehuorenList(cache, groupId, uid);
                                if (hehuorenList == null || hehuorenList.size() == 0) {
                                    //这一步貌似没用了,因为这种情况证明他就是盟主|盟主的玩家,都算盟主的团队
                                    ru.hincrby(ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_TODAY_ + groupId, uid+"", 1l);
                                } else {
                                    if (!hehuorenList.get(0).equals(uid)) {
                                        ru.hincrby(ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_TODAY_ + groupId, uid+"", 1l);
                                    }
                                    for (Integer hehuorenId : hehuorenList) {
                                        ru.hincrby(ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_TODAY_ + groupId, hehuorenId+"", 1l);
                                    }
                                }
                            }
                        }

                        //只要打了,都算是盟主的团队
                        if (tgp != null ) {
                            ru.hincrby(ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_TODAY_ + groupId, tgp.getOwerId()+"", (long)userinfos.size());
                        }
                    }

//                    if (!StringUtil.isEmpty(groupId)) {
//                        JSONArray userifos = groupRoot.getJSONArray("userinfos");
//                        String roomNum = groupRoot.getString("roomNum");
//                        for (int i =0; i < userifos.size(); i++) {
//                            JSONObject userJson = userifos.getJSONObject(i);
//                            int score =userJson.getInteger("score");
//                            int uid = userJson.getInteger("uid");
//                            TGroupZhanji tgz = new TGroupZhanji();
//                            tgz.setGroupId(groupId);
//                            tgz.setPlayerId(uid);
//                            tgz.setActivityId(Integer.parseInt(activityId));
//                            tgz.setInviteCode(Integer.parseInt(roomNum));
//                            tgz.setCreateTime(new Date());
//                            tgz.setIsDayingjia(0);
//                            tgz.setPlayPointCount(score);
//                            tgz.setLevel(Integer.parseInt(level));
//                            groupZhanjiMapper.insert(tgz);
//                        }
//                    }
                }

                return true;
            }

        }catch (Exception e ) {
            info.info(e);
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
        }finally {
            CacheManager.releaseCache(cache);
        }

        return false;
    }

}
