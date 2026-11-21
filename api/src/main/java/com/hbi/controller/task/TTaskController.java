//package com.hbi.controller.task;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.hbi.constants.Constants;
//import com.hbi.service.tack.TPlayerTaskService;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.wordnik.swagger.annotations.Api;
//import com.wordnik.swagger.annotations.ApiOperation;
//import com.wordnik.swagger.annotations.ApiParam;
//import org.apache.log4j.Logger;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Controller;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RequestMethod;
//import org.springframework.web.bind.annotation.RequestParam;
//import org.springframework.web.bind.annotation.ResponseBody;
//
//import javax.servlet.http.HttpServletRequest;
//
///**
// * Created by muzi on 23/11/2017.
// */
//@Api(basePath = "/task", value = "任务的相关接口", position = 1)
//@RequestMapping(value = "task")
//@Controller
//public class TTaskController {
//    private static final Logger LOGGER = Logger.getLogger(TTaskController.class);
//
//    @Autowired
//    private TPlayerTaskService playerTaskService;
//
//    @ResponseBody
//    @RequestMapping(value = "getTaskList", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "获取玩家的任务的详情", position = 2, response = Response.class)
//    public String getTaskList(
//            @ApiParam(required = true, name = "userId", value = "玩家ID") @RequestParam(required = true, value = "userId") Long playerId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//
//            JSONObject result = playerTaskService.getTaskList(playerId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(result);
//
//        } catch (InfServerException ie) {
//            LOGGER.error("查询玩家的充值成就情况：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("查询玩家的充值成就情况：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//
//    @ResponseBody
//    @RequestMapping(value = "playerApplyTask", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "玩家任务升级", position = 2, response = Response.class)
//    public String getTaskList(
//            @ApiParam(required = true, name = "userId", value = "玩家ID") @RequestParam(required = true, value = "userId") Long playerId,
//            @ApiParam(required = true, name = "taskId", value = "taskId") @RequestParam(required = true, value = "taskId") Integer taskId,
//            @ApiParam(required = true, name = "squence", value = "squence") @RequestParam(required = true, value = "squence") Integer squence,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            //绑定代理升级
//            if (taskId == Constants.GIFT_SHENG_JI) {
//                response = playerTaskService.applyForAgent(playerId);
//            }
//            //充值奖励
//            if (taskId == Constants.GIFT_CHENG_JIU) {
//                response = playerTaskService.applyForRecGold(playerId,squence);
//            }
//            //每日任务
//            if (taskId == Constants.GIFT_EVERY_DAY) {
//                response = playerTaskService.gifEveryDay(playerId,squence);
//            }
//
//        } catch (InfServerException ie) {
//            LOGGER.error("查询玩家的充值成就情况：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("查询玩家的充值成就情况：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//}
