package com.hbi.controller.roomcard;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.hbi.constants.Constants;
import com.hbi.mapper.TFreeGameTotalMapper;
import com.hbi.mapper.TUserMapper;
import com.hbi.model.TUser;
import com.hbi.service.Gold.GoldService;
import com.hbi.service.roomcard.RoomCardService;
import com.hbi.utils.CommonUtil;
import com.hbi.utils.GameServerUtil;
import com.hbi.utils.InfServerException;
import com.hbi.vo.response.Response;
import com.wordnik.swagger.annotations.ApiOperation;
import com.wordnik.swagger.annotations.ApiParam;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import java.util.Map;

/**
 * Created by ceeuoo on 8/27/2016.
 */
@Controller
public class RoomCardController {
    private static final Logger log = Logger.getLogger(RoomCardController.class);

    @Autowired
    private RoomCardService roomCardService;
    @Autowired
    private TUserMapper userMapper;
    @Autowired
    private GoldService goldService;

    @ResponseBody
    @ApiOperation(value = "扣除房卡接口", response = String.class, notes = "API-USERCENTER-8 扣除房卡接口")
    @RequestMapping(value = "roomCard/deductCard", method = { RequestMethod.GET, RequestMethod.POST }, produces = "application/json; charset=utf-8")
    public String deductCard(
        HttpServletRequest request,
        @ApiParam(required = true, name = "userId", value = "玩家ID")
        @RequestParam(value = "userId") Long userId,
        @ApiParam(required = true, name = "level", value = "游戏Level")
        @RequestParam(value = "level") Integer level,
        @ApiParam(required = true, name = "activityId", value = "activityId")
        @RequestParam(value = "activityId") Long activityId,
        @ApiParam(required = true, name = "round", value = "组局")
        @RequestParam(required = true,value = "round") Integer round,
        @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
        @RequestParam(required = false, value = "interfaceType") String interfaceType) {
        Response response = new Response();
        try {
            roomCardService.deductCard(userId, level, round,activityId);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        } catch (Exception e) {
            log.error("扣除房卡接口：", e);
            CommonUtil.BuildErrorResponse(e, response);
        }
        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
            return CommonUtil.buildJSONPResponse(method, response);
        }
        return JSON.toJSONString(response);
    }
    
//    @ResponseBody
//    @ApiOperation(value = "大赢家模式扣除房卡接口", response = String.class, notes = "API-USERCENTER-8 大赢家模式扣除房卡接口")
//    @RequestMapping(value = "roomCard/deductWinerCard", method = { RequestMethod.GET, RequestMethod.POST }, produces = "application/json; charset=utf-8")
//    public String deductWinerCard(
//        HttpServletRequest request,
//        @ApiParam(required = true, name = "activeId", value = "组局ID")
//        @RequestParam(value = "activeId") Long activeId,
//        @ApiParam(required = true, name = "winerList", value = "赢家列表")
//        @RequestParam(value = "winerList") String winerList,
//        @ApiParam(required = true, name = "payCount", value = "扣除房卡数")
//        @RequestParam(required = true,value = "payCount") Integer payCount,
//        @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//        @RequestParam(required = false, value = "interfaceType") String interfaceType) {
//        Response response = new Response();
//        try {
//            roomCardService.deductWinerCard(activeId, winerList, payCount);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("扣除房卡接口：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "roomCard/setRoomCard", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "设置房卡数量", position = 2, response = Response.class)
//    public String setRoomCard (
//            @ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") Long userId,
//            @ApiParam(required = true, name = "num", value = "num") @RequestParam(value = "num") Integer num,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response= new Response();
//        try {
//            roomCardService.setRoomCard(userId, num);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (InfServerException ie) {
//            log.error("设置房卡数量：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("设置房卡数量：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
    @ResponseBody
    @RequestMapping(value = "roomCard/queryRoomCardCount", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @ApiOperation(value = "查询房卡数量", position = 2, response = Response.class)
    public String queryRoomCardCount (
            @ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") Long userId,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
            @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response= new Response();
        try {
        	JSONObject object = new JSONObject();
            Integer count = roomCardService.queryRoomCardCount(userId);
            //Long points = userMapper.selectPiontByUSerId(userId);
//            Long gold = goldService.queryGoldCount(userId);

//            TUser user = userMapper.selectByPrimaryKey(userId);

//            Long repositoryMony = goldService.queryRepositoryMney(userId);
//            Integer ownerIncome = goldService.queryRoomOwnerIncome(userId);
//            object.put("owerIncome",ownerIncome);
            object.put("cardCount", count);
            //object.put("points", points);
//            object.put("gold",gold);
//            object.put("goldCount",user.getGiftGoldCount());
//            object.put("repositoryMony",repositoryMony);

            response.setData(object);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        } catch (InfServerException ie) {
            log.error("查询房卡数量：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            log.error("查询房卡数量：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
        }
        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
            return CommonUtil.buildJSONPResponse(method, response);
        }
        return JSON.toJSONString(response);
    }
//
//
//    @ResponseBody
//    @RequestMapping(value = "roomCard/giftRoomCardEveryDay", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "每日登陆送房卡  0:成功 1:失败 2:已经领取", position = 2, response = Response.class)
//    public String giftRoomCardEveryDay (
//            @ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") Long userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response= new Response();
//        try {
//            response = roomCardService.giftRoomCardEveryDay(userId);
//        } catch (InfServerException ie) {
//            log.error("每日登陆赠送：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("每日登陆赠送：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//    /**
//     * 十二子使用的,批量扣卡
//     * @param json
//     * @param interfaceType
//     * @param request
//     * @return
//     */
//    @ResponseBody
//    @RequestMapping(value = "roomCard/cutRoomCardByUsersAndNum", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "批量扣除房卡的功能 格式{\"users\":\"[1,2,3]\",\"CardNum\":\"1\"}", position = 2, response = Response.class)
//    public String giftRoomCardEveryDay (
//            @ApiParam(required = true, name = "usersAndNum", value = "用户和房卡数") @RequestParam(value = "usersAndNum") String json,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response= new Response();
//        try {
//            Map map = roomCardService.cutRoomCardByUsersAndNum(json);
//            if (map != null) {
//                response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//                response.setData(map);
//            }else {
//                response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            }
//
//
//        } catch (InfServerException ie) {
//            log.error("用户扣除房卡：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("用户扣除房卡：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
}
