package com.hbi.service.schedule;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.core.util.RedisUtil;
import com.core.util.RedisUtil3;
import com.core.util.StringUtil;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.GroupPlayerCacheController;
import com.hbi.enums.PlayerTypeEnum;
import com.hbi.mapper.TGroupPlayerMapper;
import com.hbi.mapper.TPlayerGroupMapper;
import com.hbi.model.TGroupPlayer;
import com.hbi.model.TGroupXiaohaoDayHistory;
import com.hbi.model.TPlayerGroup;
import com.hbi.service.playerGroup.TGroupXiaoHaoDayHistoryService;
import com.hbi.service.playerGroup.TGroupXiaoHaoHistoryService;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Create by Mars on 2019/7/20 13:08
 */
@Service
public class scheduleJifenProfitService {

    private static final Log info = LogFactory.getLog("jifen");

    private static final String JIFENPROFIT_LOCK = "JIFENPROFIT_LOCK";
    private static final String JIFEN_PROFIT = "JIFEN_PROFIT";
    private static final String JIFEN_PROFIT_EXCEPTION = "JIFEN_PROFIT_EXCEPTION";

    @Autowired
    private GroupPlayerCacheController groupPlayerCacheController;
    @Autowired
    private TPlayerGroupMapper playerGroupMapper;
    @Autowired
    private TGroupPlayerMapper groupPlayerMapper;
    @Autowired
    private TGroupXiaoHaoHistoryService groupXiaoHaoHistoryService;
    @Autowired
    private TGroupXiaoHaoDayHistoryService groupXiaoHaoDayHistoryService;

    @Scheduled(cron="0/3 * * * * ?")
    public void scheduleJisuan() {
        RedisUtil ru = RedisUtil.getRu();
        long times = ru.incr(JIFENPROFIT_LOCK);
        if (times <= 1 ) {

            int i = 0;  //防止死循环

            try {
                while (true) {

                    String profitString = ru.lindex(JIFEN_PROFIT,0);
                    if (!StringUtil.isEmpty(profitString)) {
                        long a = System.currentTimeMillis();
                        boolean result = jisuanJifenProfit(profitString);
                        long b = System.currentTimeMillis();
                        info.info("result--> " + result + (b-a));
                        if (result) {
                            ru.lpop(JIFEN_PROFIT);
                        }else {
                            ru.rpush(JIFEN_PROFIT_EXCEPTION,profitString);
                            ru.lpop(JIFEN_PROFIT);
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
                ru.del(JIFENPROFIT_LOCK);
            }
        }

    }


    private  boolean jisuanJifenProfit(String profitString) {
        info.info(profitString);
        ICache cache = null;
        RedisUtil3 ru = RedisUtil3.getRu();
        try {

            JSONObject profitJson = JSONObject.parseObject(profitString);
            Integer groupId = profitJson.getInteger("groupId");
            if (StringUtil.isEmpty(groupId)) {
                info.info("group_id is null");
                return false;
            }
            JSONArray players = profitJson.getJSONArray("players");
            JSONArray additional = profitJson.getJSONArray("additional");
            Long activityId = profitJson.getLong("activityId");
            Integer level = profitJson.getInteger("level");

            if (StringUtil.isEmpty(players) && StringUtil.isEmpty(additional) ) {
                info.info("players is null and additional is null");
                return false;
            }

            TGroupPlayer tgp = groupPlayerMapper.findById(groupId);
            Integer ownerId = tgp.getOwerId();

            cache = CacheManager.getCache();
            int choushuiCount = 0;
            int shengyuCount = 0;
            if (!StringUtil.isEmpty(players) && !players.isEmpty() ) {
                for (int i = 0; i < players.size(); i++) {

                    JSONObject player = players.getJSONObject(i);
                    if (!StringUtil.isEmpty(player)) {

                        Integer uid = player.getInteger("uid");
                        Integer profit = player.getInteger("profit");
                        if (!StringUtil.isEmpty(uid) && !StringUtil.isEmpty(profit)) {
                            choushuiCount += profit;
                            int shengyuMoney = profit;
                            int sonCommission = 0;
                            List<Integer> shangjiList= groupPlayerCacheController.queryHehuorenList(cache,groupId,uid);
                            //如果没有合伙人,证明是盟主的玩家
                            if (shangjiList == null || shangjiList.size() == 0 ) {
                                ru.hincrby(ScheduleConstants.STT_CLUB_PLAYER_CONTRI_TODAY_ + groupId, uid + "", (long) shengyuMoney);
                            }

                            info.info(shangjiList);
                            int shangjiId = 0;
                            for (int j =0 ; j < shangjiList.size(); j++ ) {
                                shangjiId = shangjiList.get(j);
                                int commission = groupPlayerCacheController.queryMyCommission(cache,groupId,shangjiId);
                                int agentIncome = profit * (commission-sonCommission) / 100;
                                sonCommission = commission;

                                if (agentIncome <= 0) {
                                    continue;
                                }else {
                                    if (agentIncome >= shengyuMoney) {
                                        agentIncome = shengyuMoney;
                                    }
                                }
                                info.info("shangjiId-->" + shangjiId + " agentIncome-->" + agentIncome);
                                //上级的收入就是下级的贡献
                                if (j == 0 ) {
                                    if (uid.equals(shangjiId) ) {
                                        //合伙人自己玩,贡献给自己
                                        ru.hincrby(ScheduleConstants.STT_CLUB_MYSELF_CONTRI_TODAY_ + groupId, uid + "", (long) agentIncome);
                                    }else {
                                        ru.hincrby(ScheduleConstants.STT_CLUB_PLAYER_CONTRI_TODAY_ + groupId, uid + "", (long) agentIncome);
                                    }
                                } else {
                                    ru.hincrby(ScheduleConstants.STT_CLUB_PLAYER_CONTRI_TODAY_ + groupId, shangjiList.get(j-1) + "", (long) agentIncome);
                                }

                                //代理的收入
                                playerGroupMapper.updateJifenInfo(agentIncome,1,groupId,shangjiId);
                                //收入记录
                                groupXiaoHaoHistoryService.insertOne(groupId,shangjiId,uid,profit,agentIncome,level,activityId);
                                //日收入记录
                                groupXiaoHaoDayHistoryService.update(groupId,shangjiId,agentIncome,1);

                                shengyuMoney -= agentIncome;
                                if (shengyuMoney <= 0 ) {
                                    break;
                                }
                            }

                            // 如果存在合伙人分,并且分了之后还有的盛,最后一个代理就是他贡献给盟主的
                            if (shangjiList != null && shangjiList.size() > 0 && shengyuMoney > 0 && shangjiId > 0) {
                                ru.hincrby(ScheduleConstants.STT_CLUB_PLAYER_CONTRI_TODAY_ + groupId, shangjiId + "", (long) shengyuMoney);
                            }
                            //群主的收入
                            if (shengyuMoney > 0 ) {
//                            playerGroupMapper.updateJifenInfo(shengyuMoney,0,groupId,ownerId);
                                shengyuCount += shengyuMoney;
                                groupXiaoHaoHistoryService.insertOne(groupId,ownerId,uid,profit,shengyuMoney,level,activityId);
                                groupXiaoHaoDayHistoryService.update(groupId,ownerId,profit,1);
                            }

                            //统计玩家的大赢家次数
                            playerGroupMapper.updateDayingjiaCount(1,uid,groupId);

                        }

                    }

                }
            }


            //额外赠送的处理
            if (!StringUtil.isEmpty(additional) && !additional.isEmpty() ) {
                for (int i =0; i < additional.size(); i++) {
                    JSONObject jsonObject = additional.getJSONObject(i);
                    if (!StringUtil.isEmpty(jsonObject)) {
                        Integer profit = jsonObject.getInteger("profit");
                        Integer uid = jsonObject.getInteger("uid");
                        if (!StringUtil.isEmpty(profit) && profit > 0) {
                            choushuiCount += profit;
                            shengyuCount += profit;

                            groupXiaoHaoHistoryService.insertOne(groupId,ownerId,uid,profit,profit,level,activityId);
                            groupXiaoHaoDayHistoryService.update(groupId,ownerId,profit,1);
                        }
                    }
                }
            }

            //联盟的总抽水额度
            if (choushuiCount > 0 ) {
                groupPlayerMapper.updateChoushuiCount(groupId,choushuiCount,shengyuCount);
                playerGroupMapper.updateJifenInfo(shengyuCount,0,groupId,ownerId);
            }

            return true;
        }catch (Exception e ) {

            info.info(e);
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
        }finally {

            CacheManager.releaseCache(cache);

        }

        return false;
    }

    @Scheduled(cron = "0 0 0 * * ?")
    public void updateXiaohaoInfo() {

        info.info("每日初始化群主的抽水" + System.currentTimeMillis());
        try {
            playerGroupMapper.updateYesterday20();
            playerGroupMapper.updateToday2Yesterday();
            playerGroupMapper.updateToday20();
        }catch (Exception e ) {
            info.info(e);
        }

        //团队昨日打的局数
        List<TPlayerGroup> list = playerGroupMapper.selectAll();

        for (TPlayerGroup tpg : list) {
            Integer playCountYesterday = tpg.getPlayCountYesterday();
            Integer playerType = tpg.getPlayerType();
            Integer groupId = tpg.getGroupId();
            Integer playerId = tpg.getPlayerId();

            Integer teamPlayerCount = 0;
            if (playerType == PlayerTypeEnum.MASTER) {
                for (TPlayerGroup tpg2: list) {
                    if (tpg2.getGroupId().equals(groupId)) {
                        teamPlayerCount += tpg2.getPlayCountYesterday();
                    }
                }
                if (teamPlayerCount > 0 ) {
                    playerGroupMapper.updateTeamPlayCount(groupId,playerId,teamPlayerCount);
                }
            }else if (playerType == PlayerTypeEnum.PARTNER) {
                teamPlayerCount += playCountYesterday;
                for (TPlayerGroup tpg2: list) {
                    if (tpg2.getGroupId().equals(groupId) && playerId.equals(tpg2.getUpPlayerId())) {
                        teamPlayerCount += tpg2.getPlayCountYesterday();
                    }
                }
                if (teamPlayerCount > 0 ) {
                    playerGroupMapper.updateTeamPlayCount(groupId,playerId,teamPlayerCount);
                }
            }
        }
    }

//    @Scheduled(cron = "0 0 0 * * ?")
//    public void updateXiaohaoInfo() {
//
//        info.info("每日初始化成员的" + System.currentTimeMillis());
//        try {
//            playerGroupMapper.updateYesterday20();
//            playerGroupMapper.updateToday2Yesterday();
//            playerGroupMapper.updateToday20();
//        }catch (Exception e ) {
//            info.info(e);
//        }
//
//    }

}
