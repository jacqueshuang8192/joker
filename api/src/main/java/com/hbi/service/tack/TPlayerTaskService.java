package com.hbi.service.tack;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.core.util.StringUtil;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.constants.Constants;
import com.hbi.mapper.GoldMapper;
import com.hbi.mapper.TPlayerTaskMapper;
import com.hbi.mapper.TUserMapper;
import com.hbi.model.TPlayerTask;
import com.hbi.model.TTask;
import com.hbi.service.charge.BaseChargeService;
import com.hbi.service.roomcard.RoomCardService;
import com.hbi.vo.response.Response;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.List;

/**
 * Created by muzi on 23/11/2017.
 */
@Service
public class TPlayerTaskService {

    @Autowired
    private TPlayerTaskMapper playerTaskMapper;
    @Autowired
    private GoldMapper goldMapper;
    @Autowired
    private TUserMapper userMapper;
    @Autowired
    private BaseChargeService baseChargeService;
    @Autowired
    private RoomCardService roomCardService;
    @Autowired
    private BaseCacheController baseCacheController;

    private final static String TASK = "TASK";



    public JSONObject getTaskList(Long playerId) {
        long l = playerId % 10;

        JSONObject taskJson = selectTask();
        //绑定任务处理,根据绑定任务确定是否满足升级为代理的条件
        JSONObject taskTwo = taskJson.getJSONObject(Constants.TASK_CHENG_JIU);
        if (StringUtil.isNotEmpty(taskTwo)){
            getTaskTwo(playerId,taskJson);
        }

        //充值任务
        JSONObject taskThree = taskJson.getJSONObject(Constants.TASK_SHENG_JI);
        if (StringUtil.isNotEmpty(taskThree)){
            getTaskThree(playerId,taskJson);
        }

        //成就任务
        JSONObject taskOne = taskJson.getJSONObject(Constants.TASK_EVERY_DAY);
        if (StringUtil.isNotEmpty(taskOne)){
            getTaskOne(playerId,taskJson);
        }

        return taskJson;
    }

    private void getTaskOne(Long playerId, JSONObject taskJson) {
        long l = playerId % 10;
        JSONObject recTask = taskJson.getJSONObject(Constants.TASK_EVERY_DAY).getJSONArray("task").getJSONObject(0);
        TPlayerTask t6 = playerTaskMapper.selectPlayerTaskByTask(playerId,l,6,0);
        if (t6 == null) {
            goldMapper.insertPlayerTask4(l,playerId,6);
            playerTaskMapper.updateTaskStatus(l,playerId,Constants.GIFT_EVERY_DAY,0,2);
            recTask.put("status","2");
        }else {
            recTask.put("status",t6.getStatus().toString());
        }
    }

    private void getTaskThree(Long playerId, JSONObject taskJson) {
        long l = playerId%10;
        JSONArray recTask = taskJson.getJSONObject(Constants.TASK_SHENG_JI).getJSONArray("task");
        int count = goldMapper.selectPlayerTask(l,playerId);
        //TPlayerTask t5 = playerTaskMapper.selectPlayerTaskByTaskId(playerId,l,5);
        //如果还没有这个记录则插入这个记录
        if(count > 0) {
            //有的话直接处理
            //TPlayerTask tpt = playerTaskMapper.selectByTask_id(l,playerId,5);
            int recCount = userMapper.selectRechangeGoldCount(playerId);
            List<TTask> t = playerTaskMapper.selectByTaskIdNotSquence(5);
            for (TTask tt : t) {
                TPlayerTask t5 = playerTaskMapper.selectPlayerTaskByTask(playerId,l,5,tt.getSquence());
                JSONObject jso = new JSONObject();
                jso.put("gife",tt.getGift());
                jso.put("squence",tt.getSquence());
                //jso.put("status",t5.getStatus());
                jso.put("taskDescribe",tt.getTaskDescribe());
                jso.put("taskId",tt.getTaskId());
                jso.put("taskName",tt.getTaskName());
                jso.put("taskTerm",tt.getTaskTerm());
                jso.put("taskNow",recCount);

                //0 : 未满足  2 : 已满足未领取 1 : 已领取
                if (t5.getStatus() == 1 ) {
                    jso.put("status",t5.getStatus());
                }else if (recCount >= tt.getTaskTerm()) {
                    jso.put("status","2");
                }else {
                    jso.put("status","0");
                }

                recTask.add(jso);
            }
        }else {
            //没有的话插入一条记录
            int recCount = userMapper.selectRechangeGoldCount(playerId);
            List<TTask> t = playerTaskMapper.selectByTaskIdNotSquence(5);
            for (TTask tt : t) {
                goldMapper.insertPlayerTask(l,playerId,recCount,tt.getSquence());
                //TTask t = playerTaskMapper.selectByTaskId(5,1);
                JSONObject jso = new JSONObject();
                jso.put("gife",tt.getGift());
                jso.put("squence",tt.getSquence());
                jso.put("status",0);
                jso.put("taskDescribe",tt.getTaskDescribe());
                jso.put("taskId",tt.getTaskId());
                jso.put("taskName",tt.getTaskName());
                jso.put("taskTerm",tt.getTaskTerm());
                jso.put("taskNow",recCount);
                if (recCount >= tt.getTaskTerm()) {
                    jso.put("status","2");
                }else {
                    jso.put("status","0");
                }
                recTask.add(jso);
            }
        }

    }

    private void getTaskTwo(Long playerId, JSONObject taskJson) {
        long l = playerId%10;
        JSONObject task = taskJson.getJSONObject(Constants.TASK_CHENG_JIU).getJSONArray("task").getJSONObject(0);
        TPlayerTask t4 = playerTaskMapper.selectPlayerTaskByTask(playerId,l,4,0);
        if (t4 == null) {
            goldMapper.insertPlayerTask4(l,playerId,4);
            Integer bindCount = goldMapper.getPlayerCountByPlayerBind(playerId);
            task.put("taskNow",bindCount);
            //task.put("status",0);

            Integer taskTerm = task.getInteger("taskTerm");
            if (bindCount >= taskTerm) {
                task.put("status",2);
            }else {
                task.put("status",0);
            }
        }else {
            //如果状态为1,则是已经领取的状态
            //if (t4.getStatus() == 1 ) {
            Integer bindCount = goldMapper.getPlayerCountByPlayerBind(playerId);
            task.put("taskNow",bindCount);
            Integer taskTerm = task.getInteger("taskTerm");

            if (t4.getStatus() == 1 ) {
                task.put("status",t4.getStatus());
            }else if (bindCount >= taskTerm) {
                task.put("status","2");
            }else {
                task.put("status","0");
            }
        }

    }

    private JSONObject selectTask() {

        ICache cache = null;

        try {

            cache = CacheManager.getCache();

            String s = cache.get(TASK);
            if (StringUtil.isNotEmpty(s)) {
                return JSONObject.parseObject(s);
            }else {
                JSONObject taskJosn = new JSONObject();
                //返回任务类型
                List<TTask> parentTask = playerTaskMapper.selectTask();
                for (TTask task: parentTask) {
                    JSONObject sonTask = new JSONObject();
                    List<TTask> list = playerTaskMapper.selectByparentId(task.getTaskId());
                    sonTask.put("task",list);
                    sonTask.put("parentTaskId",task.getTaskId());
                    sonTask.put("parentTaskName",task.getTaskName());
                    taskJosn.put(task.getTaskId().toString(),sonTask);
                }

                cache.set(TASK,taskJosn.toJSONString());
                return taskJosn;
            }
        }catch (Exception e ) {
            System.out.println(e.getMessage());
        }finally {
            CacheManager.releaseCache(cache);
        }

        return null;
    }

    public Response applyForAgent(Long playerId) {
        Response response = new Response();

        Integer bindCount = goldMapper.getPlayerCountByPlayerBind(playerId);
        TTask t = playerTaskMapper.selectByTaskId(4,0);
        if (bindCount > t.getTaskTerm() ) {
            long l = playerId % 10;
            playerTaskMapper.updateTaskStatus(l,playerId,4,0,1);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("升级代理成功!!");
            return response;
        }else {
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("绑定您的玩家数量不足!!");
            return response;
        }


    }

    public Response applyForRecGold(Long playerId,Integer squence) throws IOException {
        Response response = new Response();
        long l = playerId % 10;
        //TPlayerTask tpt = playerTaskMapper.selectByTask_id(l,playerId,5);
        TTask t = playerTaskMapper.selectByTaskId(5,squence);
        int recCount = userMapper.selectRechangeGoldCount(playerId);
        if (recCount >= t.getTaskTerm()) {


            //playerTaskMapper.updateSquence(l,playerId,5,tpt.getSquence()+1);
            playerTaskMapper.updateTaskStatus(l,playerId,5,squence,1);
            baseChargeService.playerGoldRecharge(1,playerId,Integer.parseInt(t.getGift()));
            userMapper.insertTplayerShareGiftRecord(playerId,"0",t.getGift(),Constants.giftPlayerByTask);
            //第7层的可以领取  房卡第7层的也还没有领取
            //if (tpt.getSquence() < 7 && tpt.getStatus() != 1 ) {
            //    playerTaskMapper.updateSquence(l,playerId,5,tpt.getSquence()+1);
            //    baseChargeService.playerGoldRecharge(1,playerId,Integer.parseInt(t.getGift()));
            //    playerTaskMapper.insertGiftGoldHistory(playerId,5,tpt.getSquence(),t.getGift());
            //}
            //if (tpt.getSquence() == 7 && tpt.getStatus() != 1) {
            //    //playerTaskMapper.updateSquence(l,playerId,5,tpt.getSquence());
            //    playerTaskMapper.updateTaskStatus(l,playerId,5,7,1);
            //    baseChargeService.playerGoldRecharge(1,playerId,Integer.parseInt(t.getGift()));
            //    playerTaskMapper.insertGiftGoldHistory(playerId,5,tpt.getSquence(),t.getGift());
            //}

            return response;
        }else {
            response.setData(Constants.RETURN_CODE_FAIL);
            response.setError("您的条件不满足领取条件!!");
            return response;
        }

    }

    public Response gifEveryDay(Long playerId, Integer squence) throws Exception {
        Response response = new Response();
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            TPlayerTask tPlayerTask = playerTaskMapper.selectByTask_id(playerId % 10, playerId, Constants.GIFT_EVERY_DAY);
            if (tPlayerTask.getStatus() == 1 ) {
                response.setReturnCode(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR);
                response.setData("今日已经领取过了,请明日再来,谢谢您的参与!!");
                return response;
            }else {
                String gift = playerTaskMapper.selectByTaskId(Constants.GIFT_EVERY_DAY,0).getGift();
                JSONObject jsonObject = JSONObject.parseObject(gift);

//                String cardEveryDay = baseCacheController.queryConfig("sharSendCardEveryDay", cache);
//                String goldEveryDay = baseCacheController.queryConfig("sharSendGoldEveryDay", cache);
                  String cardEveryDay = jsonObject.getString("roomCard");
                  String goldEveryDay = jsonObject.getString("gold");
                if (!StringUtil.isEmpty(cardEveryDay)) {
                    cache.hincrby(Constants.PLAYER_ROOM_CARD,playerId+"",Integer.parseInt(cardEveryDay));
                    userMapper.giftRoomCardEveryDay(playerId,cardEveryDay);
                }
                if (!StringUtil.isEmpty(goldEveryDay) && Integer.parseInt(goldEveryDay) > 0) {
                    baseChargeService.playerGoldRecharge(1,playerId,Integer.parseInt(goldEveryDay));
                }
                userMapper.insertTplayerShareGiftRecord(playerId,cardEveryDay,goldEveryDay,Constants.giftPlayerByTaskEvery);
                playerTaskMapper.updateTaskStatus(playerId%10,playerId,Constants.GIFT_EVERY_DAY,0,1);
                response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
                JSONObject jo = new JSONObject();
                jo.put("goldCount",goldEveryDay);
                jo.put("cardCount",cardEveryDay);
                jo.put("msg","今日领取成功!!");
                response.setData(jo);
            }
//            response = roomCardService.giftRoomCardEveryDay(playerId);
        }catch (Exception e) {
//            new InfServerException(Constants.RETURN_CODE_FAIL,"网络异常!!");
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }
        return response;
    }
}
