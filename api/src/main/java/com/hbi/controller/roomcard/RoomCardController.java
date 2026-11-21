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
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.Parameter;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import jakarta.servlet.http.HttpServletRequest;
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
    @Operation(summary = "扣除房卡接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = String.class))), description = "API-USERCENTER-8 扣除房卡接口")
    @RequestMapping(value = "roomCard/deductCard", method = { RequestMethod.GET, RequestMethod.POST }, produces = "application/json; charset=utf-8")
    public String deductCard(
        HttpServletRequest request,
        @Parameter(required = true, name = "userId", description = "玩家ID")
        @RequestParam(value = "userId") Long userId,
        @Parameter(required = true, name = "level", description = "游戏Level")
        @RequestParam(value = "level") Integer level,
        @Parameter(required = true, name = "activityId", description = "activityId")
        @RequestParam(value = "activityId") Long activityId,
        @Parameter(required = true, name = "round", description = "组局")
        @RequestParam(required = true,value = "round") Integer round,
        @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
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
//    @Operation(summary = "大赢家模式扣除房卡接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = String.class))), description = "API-USERCENTER-8 大赢家模式扣除房卡接口")
//    @RequestMapping(value = "roomCard/deductWinerCard", method = { RequestMethod.GET, RequestMethod.POST }, produces = "application/json; charset=utf-8")
//    public String deductWinerCard(
//        HttpServletRequest request,
//        @Parameter(required = true, name = "activeId", description = "组局ID")
//        @RequestParam(value = "activeId") Long activeId,
//        @Parameter(required = true, name = "winerList", description = "赢家列表")
//        @RequestParam(value = "winerList") String winerList,
//        @Parameter(required = true, name = "payCount", description = "扣除房卡数")
//        @RequestParam(required = true,value = "payCount") Integer payCount,
//        @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
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
//    @Operation(summary = "设置房卡数量", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String setRoomCard (
//            @Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") Long userId,
//            @Parameter(required = true, name = "num", description = "num") @RequestParam(value = "num") Integer num,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
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
    @Operation(summary = "查询房卡数量", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String queryRoomCardCount (
            @Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") Long userId,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
            @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response= new Response();
        try {
        	JSONObject object = new JSONObject();
            Integer count = roomCardService.queryRoomCardCount(userId);
            //Long points = userMapper.selectPiontByUSerId(userId);
//            Long gold = goldService.queryGoldCount(userId);

//            TUser user = userMapper.findById(userId);

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
//    @Operation(summary = "每日登陆送房卡  0:成功 1:失败 2:已经领取", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String giftRoomCardEveryDay (
//            @Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") Long userId,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
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
//    @Operation(summary = "批量扣除房卡的功能 格式{\"users\":\"[1,2,3]\",\"CardNum\":\"1\"}", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String giftRoomCardEveryDay (
//            @Parameter(required = true, name = "usersAndNum", description = "用户和房卡数") @RequestParam(value = "usersAndNum") String json,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
