//package com.hbi.service.schedule;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.core.util.ConfigUtil;
//import com.core.util.RedisUtil;
//import com.core.util.StringUtil;
//import com.hbi.cache.model.CacheGameActivity;
//import com.hbi.mapper.TActivityMapper;
//import com.hbi.model.TGroupGameconfig;
//import com.hbi.service.game.FreeGameService;
//import com.hbi.service.playerGroup.TPlayerGroupService;
//import org.apache.log4j.Logger;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.jdbc.datasource.DataSourceTransactionManager;
//import org.springframework.scheduling.annotation.Scheduled;
//import org.springframework.stereotype.Service;
//import org.springframework.transaction.TransactionDefinition;
//import org.springframework.transaction.TransactionStatus;
//import org.springframework.transaction.interceptor.TransactionAspectSupport;
//import org.springframework.transaction.support.DefaultTransactionDefinition;
//
//import java.util.*;
//
//@Service
//public class scheduleClubService {
//
//    private static Logger log = Logger.getLogger(scheduleClubService.class);
//
//    // uid->level_clubId_status
//    private static final String ROBOT_STATUS = "ROBOT_STATUS";
//
//    @Autowired
//    private FreeGameService freeGameService;
//    @Autowired
//    private TActivityMapper activityMapper;
//    @Autowired
//    private TPlayerGroupService playerGroupService;
//    @Autowired
//    private DataSourceTransactionManager transactionManager;
//
//    /**
//     * 俱乐部自动创建房间
//     */
//    @Scheduled(cron="0/30 * * * * ?")
//    public void autoRobotCreateFreeGame() {
//
//        RedisUtil ru = RedisUtil.getRu();
//        Map<String, String> robotStatus = ru.hgetall(ROBOT_STATUS);
//
//        Map<String, List<String>> createMap = new HashMap<String, List<String>>();
//
//        //查找允许创建的机器人
//        for (Map.Entry<String, String> entry : robotStatus.entrySet()) {
//            String key = entry.getKey();
//            String value = entry.getValue();
//            if (!StringUtil.isEmpty(value) && value.split("_").length >= 3 ) {
//                String[] status = value.split("_");
//                if ("1".equals(status[2]) ) {
//                    String clubId = status[1];
//                    boolean flag = createMap.containsKey(clubId);
//                    if (flag) {
//                        createMap.get(clubId).add(key);
//                    }else {
//                        List<String> uids = new ArrayList<String>();
//                        uids.add(key);
//                        createMap.put(clubId,uids);
//                    }
//                }
//            }
//        }
//
//        //创建桌子
//        String robotGamesStr = ConfigUtil.get("robotGames");
//        String robotTables = ConfigUtil.get("robotTables");
//        if (!StringUtil.isEmpty(robotGamesStr) && !StringUtil.isEmpty(robotTables)) {
//            String[] games = robotGamesStr.split(",");
//            Integer tabCount = Integer.parseInt(robotTables);
//            for (Map.Entry<String, List<String>> entry: createMap.entrySet() ) {
//                String clubId = entry.getKey();
//                List<String> value = entry.getValue();
//                for (String gameLevel: games) {
//                    Integer tablesCount = activityMapper.selectClubTables(clubId,gameLevel);
//                    //如果初始化桌子不够,则创建桌子
//                    if (tabCount > tablesCount) {
//                        //从玩法中随机获取一种玩法创建桌子
//                        List<TGroupGameconfig> configs = null;
//                        try {
//                            configs = playerGroupService.selectGameConfig(Integer.parseInt(clubId), null, null, Integer.parseInt(gameLevel), null);
//                        }catch (Exception e ) {
//                            log.info("俱乐部" + clubId + "获取玩法报错");
//                            continue;
//                        }
//                        if (!StringUtil.isEmpty(configs) && configs.size() > 0 ) {
//                            Random random = new Random();
//                            int n = random.nextInt(configs.size());
//                            TGroupGameconfig config = configs.get(n);
//                            if (!StringUtil.isEmpty(config.getConfig()) ) {
//                                JSONObject jsonConfig = JSONObject.parseObject(config.getConfig());
//                                String uid = value.get(0);
//                                String level = jsonConfig.getString("level");
//                                Integer baseChip = jsonConfig.getInteger("baseChip");
//                                Integer round = jsonConfig.getJSONObject("round").getInteger("optionValue");
//
//                                JSONObject json = new JSONObject();
//                                String discription = "";
//                                String discription2Server = "";
//                                for (String key : jsonConfig.keySet() ) {
//                                    Object obj = jsonConfig.get(key);
//                                    if (obj instanceof JSONObject) {
//                                        JSONObject jo = (JSONObject)obj;
//                                        if (jo.size() > 0 ) {
//                                            String optionValue = jo.getString("optionValue");
//                                            String optionName = jo.getString("optionName");
//                                            String configName = jo.getString("configName");
//                                            Integer isShow = jo.getInteger("isShow");
//                                            if (!StringUtil.isEmpty(optionValue) ) {
//                                                json.put(key, jo.get("optionValue"));
//                                                if (!StringUtil.isEmpty(configName)) {
//                                                    discription += configName + ":" + optionName + " ";
//                                                    if (!StringUtil.isEmpty(isShow) && 1 == isShow ) {
//                                                        discription2Server += configName + ":" + optionName + " ";
//                                                    }
//                                                }
//                                            }
//                                        }
//                                    } else if (obj instanceof Integer) {
//                                        json.put(key, obj);
//                                    } else if ( obj instanceof String) {
//                                        json.put(key, obj);
//                                    }
//                                }
//                                //1.获取事务定义
//                                DefaultTransactionDefinition def = new DefaultTransactionDefinition();
//
//                                def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
//
//                                TransactionStatus status = transactionManager.getTransaction(def);
//                                try {
//
//                                    log.info("createInfo" + uid + " " + level + round + baseChip + "----" + clubId);
//                                    CacheGameActivity activity = (CacheGameActivity)freeGameService.createFreeGameByOthers(uid, level, Integer.parseInt(level), "组局", round, json.toJSONString(), discription.trim(), discription2Server.trim(), 0,
//                                            baseChip, Integer.parseInt(clubId), null, config.getId(), null);
//                                    log.info("createSuccess----" + activity.getGameActivityId());
//
//                                    transactionManager.commit(status);
//                                }catch (Exception e ) {
//                                    log.info("俱乐部" + clubId + "创建桌子失败" + level);
////                                    TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
//                                    transactionManager.rollback(status);
////                                    throw e;
//                                }finally {
//
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//}
