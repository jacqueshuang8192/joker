package com.hbi.controller.playerGroup;

import com.alibaba.fastjson.JSONObject;
import com.core.util.StringUtil;
import com.hbi.base.BaseController;
import com.hbi.constants.Constants;
import com.hbi.model.*;
import com.hbi.service.playerGroup.*;
import com.hbi.utils.CommonUtil;
import com.hbi.utils.InfServerException;
import com.hbi.vo.response.Response;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.Parameter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

/**
 * Created by muzi on 2017/12/7.
 */
@Tag(name = "联盟相关接口")
@Controller
public class TGroupPlayerController extends BaseController<TGroupPlayerController> {

    @Autowired
    private TPlayerGroupService playerGroupService;
    @Autowired
    private TGroupPlayerService groupPlayerService;
    @Autowired
    private TMsgPlayerGroupService msgPlayerGroupService;
    @Autowired
    private TGroupNoticeService groupNoticeService;
    @Autowired
    private TGroupActivityService groupActivityService;

    @ResponseBody
    @RequestMapping(value = "createPlayerGroup", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "新建联盟", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String createPlayerGroup(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "groupName", description = "群名") @RequestParam(value = "groupName", required = true) String groupName,
            @Parameter(required = false, name = "configArrays", description = "配置数组") @RequestParam(value = "configArrays", required = false) String configArrays,

            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {
            JSONObject result = groupPlayerService.insertGroupPlayer(XYUid, groupName,configArrays);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);
        }catch (InfServerException ie) {
            LOGGER.error("新建联盟：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("新建联盟：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "transferClubOwner", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "转让群主", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String transferClubOwner(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "groupId", description = "联盟ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "assignor", description = "转让者ID") @RequestParam(value = "assignor", required = true) Integer assignor,

            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {
            groupPlayerService.transferClubOwner(XYUid, groupId,assignor);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        }catch (InfServerException ie) {
            LOGGER.error("转让群主：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("转让群主：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "applyForJoinPlayerGroup", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "申请加入一个联盟", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String applyForJoinPlayerGroup(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = false, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = false) Integer groupId,
            @Parameter(required = true, name = "inviteCode", description = "申请码") @RequestParam(value = "inviteCode", required = true) String inviteCode,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            String isAgree = groupPlayerService.applyForJoinPlayerGroup(XYUid,groupId,null,inviteCode);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            if (!"1".equals(isAgree)) {
                response.setData("加入成功,游戏愉快...");
            } else {
                response.setData("申请成功,等待盟主审核...");
            }

        }catch (InfServerException ie) {
            LOGGER.error("申请加入一个联盟：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("申请加入一个联盟：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "inviteForJoinPlayerGroup", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "邀请加入一个联盟", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String inviteForJoinPlayerGroup(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "playerId2", description = "玩家ID") @RequestParam(value = "playerId2", required = true) Integer playerId2,
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = false, name = "is_test", description = "群ID") @RequestParam(value = "is_test", required = false) Integer is_test,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.inviteForJoinPlayerGroup(XYUid,playerId2,groupId, is_test);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("邀请成功!!");

        }catch (InfServerException ie) {
            LOGGER.error("邀请加入一个联盟：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("邀请加入一个联盟：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "/addHhr", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "群主、现有合伙人添加新合伙人，如果这个人不在联盟，先加进联盟，再升级成合伙人", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String addHhr(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "playerId2", description = "被添加人ID") @RequestParam(required = true, value = "playerId2") Integer playerId2,
            @Parameter(required = true, name = "groupId", description = "群组ID") @RequestParam(required = true, value = "groupId") Integer groupId,
            @Parameter(required = false, name = "bonus", description = "分红比例，不能大于100.00%") @RequestParam(required = false, value = "bonus", defaultValue = "0.00") Double bonus,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request){
        Response response = new Response();
        try {
            playerGroupService.addPlayerGroup(XYUid, playerId2, groupId, bonus);
            response.setData("添加成功");
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        } catch (InfServerException e1){
            LOGGER.error("添加联盟合伙人：", e1);
            response.setReturnCode(e1.getErrorCode());
            response.setError(e1.getErrorMsg());
        } catch (Exception e2) {
            LOGGER.error("添加联盟合伙人：", e2);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e2.toString());
            CommonUtil.BuildErrorResponse(e2, response);
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "/removeHhr", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "移除合伙人", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String removeHhr(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "playerId", description = "playerId") @RequestParam(required = true, value = "playerId") Integer playerId,
            @Parameter(required = true, name = "groupId", description = "群组ID") @RequestParam(required = true, value = "groupId") Integer groupId,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request){
        Response response = new Response();
        try {
            playerGroupService.removeHhr(XYUid, playerId, groupId);
            response.setData("移除合伙人");
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        } catch (InfServerException e1){
            LOGGER.error("移除合伙人：", e1);
            response.setReturnCode(e1.getErrorCode());
            response.setError(e1.getErrorMsg());
        } catch (Exception e2) {
            LOGGER.error("移除合伙人：", e2);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e2.toString());
            CommonUtil.BuildErrorResponse(e2, response);
        }
        return responseJsonString(response, interfaceType);
    }

//    @ResponseBody
//    @RequestMapping(value = "/getHhrList", method = {RequestMethod.GET, RequestMethod.POST}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "获取合伙人列表信息", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String getHhrList(
//            @Parameter(required = true, name = "groupId", description = "群组ID") @RequestParam(required = true, value = "groupId") Integer groupId,
//            @Parameter(required = false, name = "byDate", description = "根据时间筛选（0、昨天；1、前天；不传查全部）") @RequestParam(value = "byDate", required = false) Integer byDate,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
//        Response response = new Response();
//        try {
//            JSONObject result = null ; //groupPlayerService.getHhrList(groupId, byDate);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(result);
//        } catch (Exception e) {
//            LOGGER.error("获取合伙人列表信息：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.getMessage());
//        }
//        return responseJsonString(response, interfaceType);
//    }

//    @ResponseBody
//    @RequestMapping(value = "setCost", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "抽水设置", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String setCost(
//            @Parameter(required = true, name = "groupId", description = "群组ID") @RequestParam(required = true, value = "groupId") Integer groupId,
//            @Parameter(required = true, name = "playerId", description = "设置人ID") @RequestParam(required = true, value = "playerId") Integer playerId,
//            @Parameter(required = true, name = "costPattern", description = "1=>固定抽水  2 => 比例抽水") @RequestParam(required = true, value = "costPattern") Integer costPattern,
//            @Parameter(required = true, name = "commission", description = "固定抽水自己定，保留两位小数。比例需要设定0-100%") @RequestParam(required = true, value = "commission") Double commission,
//            @Parameter(required = true, name = "costUserType", description = "0=>抽大赢家  1 => 抽赢家") @RequestParam(required = true, value = "costUserType") Integer costUserType,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
//        Response response = new Response();
//        try {
//            groupPlayerService.setCost(groupId, playerId, costPattern, commission, costUserType);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData("抽水设置成功");
//        } catch (Exception e) {
//            LOGGER.error("抽水设置：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//        }
//        return responseJsonString(response, interfaceType);
//    }

    @ResponseBody
    @RequestMapping(value = "setBonus", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "分红设置", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String setBonus(
            @Parameter(required = true, name = "groupId", description = "群组ID") @RequestParam(required = true, value = "groupId") Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "playerId2", description = "被设置人ID") @RequestParam(required = true, value = "playerId2") Integer playerId2,
            @Parameter(required = true, name = "bonus", description = "比例需要设定0-100%") @RequestParam(required = true, value = "bonus") Double bonus,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
        Response response = new Response();
        try {
            playerGroupService.setBonus(groupId, XYUid, playerId2, bonus);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("分红设置成功");
        } catch (InfServerException ie) {
            LOGGER.error("分红设置：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("分红设置：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.getMessage());
        }
        return responseJsonString(response, interfaceType);
    }



    @ResponseBody
    @RequestMapping(value = "selectPlayerGroup", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "玩家拥有的群", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String selectPlayerGroup(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            Map<String,String> result = groupPlayerService.selectPlayerGroup(XYUid);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);

        }catch (InfServerException ie) {
            LOGGER.error("玩家拥有的群：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("玩家拥有的群：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }


    @ResponseBody
    @RequestMapping(value = "selectGroupPlayer", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "获取群玩家列表", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String selectGroupPlayer(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = false, name = "byDate", description = "根据时间筛选（0、昨天；1、前天；不传查全部）,弃用") @RequestParam(value = "byDate", required = false) Integer byDate,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P, 弃用") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            JSONObject result = groupPlayerService.selectGroupPlayer(groupId, byDate );

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);

        }catch (InfServerException ie) {
            LOGGER.error("玩家拥有的群：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("玩家拥有的群：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "gotoClub", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "进入联盟返回联盟的基本信息", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String gotoClub(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = false, name = "gameType", description = "gameType") @RequestParam(value = "gameType", required = false) Integer gameType,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            Map<String, Object> result = groupPlayerService.gotoClub(groupId, XYUid, gameType);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);

        }catch (InfServerException ie) {
            LOGGER.error("进入联盟返回联盟的基本信息：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("进入联盟返回联盟的基本信息：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "opeSetClubGameLimit", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "选择游戏", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String opeSetClubGameLimit(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "gameLimits", description = "gameLimits") @RequestParam(value = "gameLimits", required = true) String gameLimits,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.opeSetClubGameLimit(groupId, XYUid, gameLimits);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);

        }catch (InfServerException ie) {
            LOGGER.error("选择游戏：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("选择游戏：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }


    @ResponseBody
    @RequestMapping(value = "getClubUserInfo", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "获取俱乐部玩家信息", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String getClubUserInfo(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "searchId", description = "searchId") @RequestParam(value = "searchId", required = true) Integer searchId,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            response.setData(groupPlayerService.getClubUserInfo(groupId, XYUid, searchId));

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);

        }catch (InfServerException ie) {
            LOGGER.error("获取俱乐部玩家信息：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取俱乐部玩家信息：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "selectGroupPlayerBydayingjia", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "获取群玩家列表,大赢家模式", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String selectGroupPlayerBydayingjia(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,

            @Parameter(required = false, name = "searchUid", description = "searchUid") @RequestParam(value = "searchUid", required = false) Integer searchUid,

            @Parameter(required = false, name = "currentPage", description = "当前页,兼容以前的版本,不传返回全部") @RequestParam(value = "currentPage", required = false) Integer currentPage,
            @Parameter(required = false, name = "pageSize", description = "每页显示数,可以不穿,默认为10") @RequestParam(required = false,value = "pageSize", defaultValue = "10") Integer pageSize,

            @Parameter(required = false, name = "startTime", description = "开始时间 格式 yyyy-MM-dd HH:mm:ss") @RequestParam(value = "startTime", required = false) String startTime,
            @Parameter(required = false, name = "endTime", description = "结束时间 年月日") @RequestParam(value = "endTime", required = false) String endTime,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(groupPlayerService.selectGroupPlayerBydayingjia(groupId, XYUid,startTime,endTime, currentPage, pageSize, searchUid));

        }catch (InfServerException ie) {
            LOGGER.error("群成员列表：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("群成员列表：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "selectHhrListBydayingjia", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "获取合伙人列表,大赢家模式", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String selectHhrListBydayingjia(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "playerId", description = "playerId") @RequestParam(value = "playerId") Integer playerId,
            @Parameter(required = false, name = "pageSize", description = "pageSize") @RequestParam(value = "pageSize", required = false, defaultValue = "30") Integer pageSize,
            @Parameter(required = false, name = "currentPage", description = "currentPage") @RequestParam(value = "currentPage", required = false, defaultValue = "1") Integer currentPage,
            @Parameter(required = false, name = "startTime", description = "开始时间 格式 yyyy-MM-dd") @RequestParam(value = "startTime", required = false) String startTime,
            @Parameter(required = false, name = "endTime", description = "结束时间 yyyy-MM-d") @RequestParam(value = "endTime", required = false) String endTime,
            @Parameter(required = false, name = "searchId", description = "搜索ID") @RequestParam(value = "searchId", required = false) Integer searchId,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            Map<String, Object> result = groupPlayerService.selectHhrListBydayingjia(groupId,startTime,endTime,playerId,pageSize,currentPage, searchId);
            response.setData(result);

        }catch (InfServerException ie) {
            LOGGER.error("群成员列表：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("群成员列表：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "selectMemberListBydayingjia", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "获取玩家列表,大赢家模式", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String selectMemberListBydayingjia(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "playerId", description = "playerId") @RequestParam(value = "playerId", required = true) Integer playerId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = false, name = "pageSize", description = "pageSize") @RequestParam(value = "pageSize", required = false, defaultValue = "30") Integer pageSize,
            @Parameter(required = false, name = "currentPage", description = "currentPage") @RequestParam(value = "currentPage", required = false, defaultValue = "1") Integer currentPage,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            Map<String, Object> result = groupPlayerService.selectMemberListBydayingjia(groupId,playerId,pageSize,currentPage);
            response.setData(result);

        }catch (InfServerException ie) {
            LOGGER.error("获取玩家列表,大赢家模式：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取玩家列表,大赢家模式：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "getMsgForplayerGroup", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "群主获取玩家申请入群的消息  0 : 待处理   3 : 拒绝  ", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String getMsgForplayerGroup(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = false, name = "groupId", description = "俱乐部ID") @RequestParam(value = "groupId", required = false) Integer groupId,
            @Parameter(required = false, name = "status", description = "status,默认0,未处理的信息,不传就可以了") @RequestParam(value = "status", required = false, defaultValue = "0") String status,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            List<TMsgPlayerGroup> result = msgPlayerGroupService.getMsgForplayerGroup(XYUid,status,groupId);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);

        }catch (InfServerException ie) {
            LOGGER.error("群主获取玩家申请入群的消息：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("群主获取玩家申请入群的消息：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }


    @ResponseBody
    @RequestMapping(value = "updateApplyForStatus", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "群主处理玩家的申请信息  0:待审核 1:通过 2:忽略 3:拒绝 4:已读 5:邀请 6:同意 7:拒绝 ", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String updateApplyForStatus(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "msgId", description = "信息的ID") @RequestParam(value = "msgId", required = true) Integer msgId,
            @Parameter(required = true, name = "status", description = "状态") @RequestParam(value = "status", required = true) Integer status,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.updateApplyForStatus(XYUid,msgId,status);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("处理成功!!");

        }catch (InfServerException ie) {
            LOGGER.error("群主处理玩家的申请信息：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("群主处理玩家的申请信息：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "updateApplyForStatusByInvite", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "群主处理玩家的申请信息  0:待审核 1:通过 2:忽略 3:拒绝 4:已读 5:邀请 6:同意 7:拒绝 ", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String updateApplyForStatusByInvite(
            @Parameter(required = false, name = "playerId1", description = "邀请人") @RequestParam(value = "playerId1", required = false) Integer playerId1,
            @Parameter(required = false, name = "playerId", description = "被邀请人") @RequestParam(value = "playerId", required = false) Integer playerId,
            @Parameter(required = false, name = "owerId", description = "群主ID") @RequestParam(value = "owerId", required = false) Integer owerId,
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "status", description = "状态") @RequestParam(value = "status", required = true) Integer status,
            @Parameter(required = true, name = "inviteCode", description = "状态") @RequestParam(value = "inviteCode", required = true) String inviteCode,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.updateApplyForStatusByInvite(playerId,owerId,groupId,status,playerId1,inviteCode);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("处理成功!!");

        }catch (InfServerException ie) {
            LOGGER.error("群主处理玩家的申请信息：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("群主处理玩家的申请信息：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "deletePlayer4GroupByOwerId", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "群主删除群里面的某个玩家", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String deletePlayer4GroupByOwerId(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "playerId", description = "玩家ID") @RequestParam(value = "playerId", required = true) Integer playerId,
//            @Parameter(required = true, name = "owerId", description = "群主ID") @RequestParam(value = "owerId", required = true) Integer owerId,
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.deletePlayer4GroupByOwerId(playerId,XYUid,groupId);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("处理成功!!");

        }catch (InfServerException ie) {
            LOGGER.error("群主删除群里面的某个玩家：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("群主删除群里面的某个玩家：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "setClubManagerByOwner", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "设置联盟的管理员", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String setClubManagerByOwner(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid", required = true) Integer XYUid,
            @Parameter(required = true, name = "playerId", description = "玩家ID") @RequestParam(value = "playerId", required = true) Integer playerId,
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "status", description = "状态 1 管理员, 其他 不是") @RequestParam(value = "status", required = true) Integer status,

            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.setClubManagerByOwner(XYUid, playerId,groupId, status);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("设置成功...");

        }catch (InfServerException ie) {
            LOGGER.error("设置联盟的管理员：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("设置联盟的管理员：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "playerExitGroupByGroupId", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "玩家退群", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String playerExitGroupByGroupId(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "groupId", description = "群主ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.playerExitGroupByGroupId(XYUid,groupId);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("处理成功!!");

        }catch (InfServerException ie) {
            LOGGER.error("玩家退群：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("玩家退群：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "deleteGroupByOwerId", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "群主删除群", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String deleteGroupByOwerId(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.deleteGroupByOwerId(XYUid,groupId);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("处理成功!!");

        }catch (InfServerException ie) {
            LOGGER.error("群主删除群：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("群主删除群：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "updateGroupNameByOwerId", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "群主更改群名字", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String updateGroupNameByOwerId(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "groupName", description = "群主更改群的名字") @RequestParam(value = "groupName", required = true) String groupName,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.updateGroupNameByOwerId(XYUid,groupId,groupName);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("处理成功!!");

        }catch (InfServerException ie) {
            LOGGER.error("群主更改群名字：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("群主更改群名字：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

//    @ResponseBody
//    @RequestMapping(value = "getChatByGroupId", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "通过groupID获取这个群的聊天记录", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String getChatByGroupId(
//            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
//            @Parameter(required = false, name = "gameType", description = "gameType") @RequestParam(value = "gameType", required = false) String gameType,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//
//            Map<String, String> result = groupPlayerService.getChatByGroupId(groupId,gameType);
//
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(result);
//
//        }catch (InfServerException ie) {
//            LOGGER.error("通过groupID获取这个群的聊天记录：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("通过groupID获取这个群的聊天记录：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//        }
//        return responseJsonString(response, interfaceType);
//    }

    @ResponseBody
    @RequestMapping(value = "updateGroupConfig", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "更新游戏配置", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String updateGroupConfig(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = false, name = "is_config", description = "is_config") @RequestParam(value = "is_config", required = false) Integer is_config,
            @Parameter(required = false, name = "is_invitation", description = "is_invitation") @RequestParam(value = "is_invitation", required = false) Integer is_invitation,
            @Parameter(required = false, name = "SelectGameConfig", description = "SelectGameConfig") @RequestParam(value = "SelectGameConfig", required = false) String SelectGameConfig,
            @Parameter(required = false, name = "SelectGameConfigIndex", description = "修改第几个玩法，下标从0开始。添加玩法传-1。老版本不用传") @RequestParam(value = "SelectGameConfigIndex", required = false) Integer SelectGameConfigIndex,

            @Parameter(required = false, description = "显示排行榜", name = "show_ranking") @RequestParam(value = "show_ranking", required = false) Integer show_ranking,
            @Parameter(required = false, description = "显示成员", name = "show_member") @RequestParam(value = "show_member", required = false) Integer show_member,
            @Parameter(required = false, description = "战绩纪录", name = "show_record") @RequestParam(value = "show_record", required = false) Integer show_record,
            @Parameter(required = false, description = "是否聊天", name = "is_chat") @RequestParam(value = "is_chat", required = false) Integer is_chat,
            @Parameter(required = false, description = "赠送积分", name = "exchange_status") @RequestParam(value = "exchange_status", required = false) Integer exchange_status,
            @Parameter(required = false, description = "0 : 打烊 1 :正常运营", name = "club_status") @RequestParam(value = "club_status", required = false) Integer club_status,
            @Parameter(required = false, description = "0 : 不显示桌子 num :显示桌子数量", name = "show_table") @RequestParam(value = "show_table", required = false) Integer show_table,
            @Parameter(required = false, description = "是否需要同意才可以加入俱乐部 1 要 0 不要", name = "is_agree") @RequestParam(value = "is_agree", required = false) Integer is_agree,
            @Parameter(required = false, description = "是否允许退出联盟 1 允许 0 不允许", name = "auto_exit_club") @RequestParam(value = "auto_exit_club", required = false) Integer auto_exit_club,

            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.updateGroupConfig(groupId,XYUid,is_config,is_invitation,is_agree,SelectGameConfig, SelectGameConfigIndex,
                    show_ranking,show_member,show_record,is_chat,exchange_status,club_status,show_table,auto_exit_club);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("设置成功!!");

        }catch (InfServerException ie) {
            LOGGER.error("更新游戏配置：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("更新游戏配置：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "deleteGroupConfig", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "删除游戏配置/删除玩法", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String deleteGroupConfig(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = false, name = "SelectGameConfigIndex", description = "删除第几个玩法，下标从0开始") @RequestParam(value = "SelectGameConfigIndex", required = false) Integer SelectGameConfigIndex,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.deleteGroupConfig(groupId, XYUid, SelectGameConfigIndex);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("删除成功!!");

        }catch (InfServerException ie) {
            LOGGER.error("删除游戏配置：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("删除游戏配置：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "cluCoinsHandle", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "积分操作", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String cluCoinsHandle(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "playerId", description = "赠送员ID") @RequestParam(value = "playerId", required = true) Integer playerId,
            @Parameter(required = true, name = "type", description = "操作类型 0 减 1 加") @RequestParam(value = "type", required = true) Integer type,
            @Parameter(required = false, name = "userType", description = "1: 积分操作 其他: 赠送") @RequestParam(value = "userType", required = false, defaultValue = "1") Integer userType,
            @Parameter(required = true, name = "coins", description = "操作数") @RequestParam(value = "coins", required = true) Integer coins,
            @Parameter(required = true, name = "sign", description = "校验码") @RequestParam(value = "sign", required = true) String sign,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            if (coins < 0 ) {
                response.setReturnCode(Constants.RETURN_CODE_FAIL);
                response.setData("请输入有效的参数！！");
            }else if((XYUid+"").equals(playerId+"") && userType == 0 ) {
                response.setReturnCode(Constants.RETURN_CODE_FAIL);
                response.setError("不可以赠送给自己...");
            } else {

                int errCode = groupPlayerService.cluCoinsHandle(groupId,XYUid,playerId,type,coins,sign,userType);

                if (errCode == Constants.handle_Success) {
                    JSONObject obj = new JSONObject();
                    obj.put("msg", "操作成功!!");
                    obj.put("type", type);
                    obj.put("coins", coins);
                    obj.put("playerId", playerId);
                    response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
                    response.setData(obj);
                }else {

                    response.setReturnCode(Constants.RETURN_CODE_FAIL);
                    if (errCode == Constants.System_Err) {
                        response.setError("系统异常，请稍后再试...");
                    }else if(errCode == Constants.Limit_Err) {
                        response.setError("权限不足，不允许操作...");
                    }else if (errCode == Constants.Encrypt_Err) {
                        response.setError("签名失败...");
                    }else if (errCode == Constants.Locking_Err) {
                        response.setError("操作失败，请勿频繁操作...");
                    }else if (errCode == Constants.TUSER_Err) {
                        response.setError("用户数据异常...");
                    }else if(errCode == Constants.TUSER_No_Exist) {
                        response.setError("用户不存在...");
                    }else if (errCode == Constants.TUSER_IS_NO_MYSon){
                        response.setError("不是您邀请过的玩家,权限不足..");
                    }else if (errCode == Constants.Point_Nont_Enough) {
                        response.setError("余额不足...");
                    }else if(errCode == Constants.TUSER_IS_INGAME){
                        response.setError("游戏中,不可操作...");
                    }else if(errCode == Constants.MareThat_maxpoint){
                        response.setError("已超过当前可用积分...");
                    }else if(errCode == Constants.Forbid_Exchange_Point){
                        response.setError("赠送功能暂停中....");
                    }  else {
                        response.setError("网络异常，请稍后再试！！");
                    }

                }

            }
        }catch (InfServerException ie) {
            LOGGER.error("积分操作：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("积分操作：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }


    @ResponseBody
    @RequestMapping(value = "heHuoRenTixian", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "体力消耗体现", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String heHuoRenTixian(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "tixianCount", description = "tixianCount") @RequestParam(value = "tixianCount", required = true) Integer tixianCount,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.heHuoRenTixian(groupId,XYUid,tixianCount);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("领取成功...");

        }catch (InfServerException ie) {
            LOGGER.error("体力消耗体现：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取操作列表：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "baiRenPoolTixian", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "百人场奖池提现", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String baiRenPoolTixian(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "tixianCount", description = "tixianCount") @RequestParam(value = "tixianCount", required = true) Integer tixianCount,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.baiRenPoolTixian(groupId,XYUid,tixianCount);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("领取成功...");

        }catch (InfServerException ie) {
            LOGGER.error("百人场奖池提现：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取操作列表：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "savePoint2Repository", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "积分存入保险箱", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String savePoint2Repository(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "savePoint", description = "savePoint") @RequestParam(value = "savePoint", required = true) Integer savePoint,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.savePoint2Repository(groupId,XYUid,savePoint);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("存入成功!!");

        }catch (InfServerException ie) {
            LOGGER.error("体力消耗体现：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取操作列表：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "repositoryHandleHistory", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "保险箱操作记录", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String repositoryHandleHistory(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = false, name = "pageSize", description = "pageSize") @RequestParam(value = "pageSize", required = false, defaultValue = "30") Integer pageSize,
            @Parameter(required = false, name = "currentPage", description = "currentPage") @RequestParam(value = "currentPage", required = false, defaultValue = "1") Integer currentPage,
            @Parameter(required = false, name = "type", description = "type") @RequestParam(value = "type", required = false) String type,

            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            Map<String,Object> result = groupPlayerService.repositoryHandleHistory(groupId,XYUid,pageSize,currentPage,type);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);

        }catch (InfServerException ie) {
            LOGGER.error("保险箱操作记录：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("保险箱操作记录：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "selectCluHistory", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "获取操作列表", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String selectCluHistory(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = false, name = "ownerId", description = "ownerId") @RequestParam(value = "ownerId", required = false) Integer ownerId,
            @Parameter(required = false, name = "playerId", description = "查询操作的ID") @RequestParam(value = "playerId", required = false) Integer playerId,
            @Parameter(required = false, name = "startTime", description = "开始时间 格式 yyyy-MM-dd") @RequestParam(value = "startTime", required = false) String startTime,
            @Parameter(required = false, name = "endTime", description = "结束时间 年月日") @RequestParam(value = "endTime", required = false) String endTime,
            @Parameter(required = false, name = "pageSize", description = "pageSize") @RequestParam(value = "pageSize", required = false, defaultValue = "30") Integer pageSize,
            @Parameter(required = false, name = "currentPage", description = "currentPage") @RequestParam(value = "currentPage", required = false, defaultValue = "1") Integer currentPage,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            Map<String, Object> result = groupPlayerService.selectCluHistory(groupId, startTime, endTime, pageSize, currentPage, ownerId,playerId);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);

        }catch (InfServerException ie) {
            LOGGER.error("获取操作列表：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取操作列表：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "selectPointChangeHistory", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "获取俱乐部的积分变化", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String selectPointChangeHistory(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = false, name = "searchId", description = "searchId") @RequestParam(value = "searchId", required = false) Integer searchId,
            @Parameter(required = false, name = "type", description = "1:上下分 2组局场游戏 3被抽水 4仓库存储 5 赠送 6百人场游戏(百人场的战绩) 如果要选多个格式=>1,2,3 单个直接数字") @RequestParam(value = "type", required = false) String type,
            @Parameter(required = false, name = "startTime", description = "开始时间 格式 yyyy-MM-dd, 保留,未使用") @RequestParam(value = "startTime", required = false) String startTime,
            @Parameter(required = false, name = "endTime", description = "结束时间 年月日, 保留,未使用") @RequestParam(value = "endTime", required = false) String endTime,
            @Parameter(required = false, name = "pageSize", description = "pageSize") @RequestParam(value = "pageSize", required = false, defaultValue = "30") Integer pageSize,
            @Parameter(required = false, name = "currentPage", description = "currentPage") @RequestParam(value = "currentPage", required = false, defaultValue = "1") Integer currentPage,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            Map<String, Object> result = groupPlayerService.selectPointChangeHistory(groupId, XYUid, type, startTime, endTime, pageSize, currentPage, searchId);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);

        }catch (InfServerException ie) {
            LOGGER.error("获取操作列表：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取操作列表：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "getGroupInfo", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "获取群的相关信息", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String getGroupInfo(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            TGroupPlayer tgp = groupPlayerService.getGroupInfo(groupId);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(tgp);

        }catch (InfServerException ie) {
            LOGGER.error("获取操作列表：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取操作列表：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "selectCluConfigCostPattern", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "查询抽水类型", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String selectCluConfigCostPattern(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
        Response response = new Response();
        try {
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(groupPlayerService.selectCluConfigCostPattern(groupId));
        }catch (InfServerException ie) {
            LOGGER.error("查询抽水类型：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("查询抽水类型：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "updatCluConfigCostPattern", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "修改抽水类型", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String updatCluConfigCostPattern(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "cost_pattern", description = "1=>固定抽水  2 => 比例抽水") @RequestParam(value = "cost_pattern", required = true) Integer cost_pattern,
            @Parameter(required = true, name = "cost_user_type", description = "0=>抽大赢家  1 => 抽赢家") @RequestParam(value = "cost_user_type", required = true) Integer cost_user_type,
            @Parameter(required = true, name = "commission", description = " 1 => 固定抽成的量 2 => 最多保留两位小数 比例抽水  这个的时候比传需要设定 0-100  ") @RequestParam(value = "commission", required = false) Double commission,
            @Parameter(required = true, name = "costLimit", description = "抽水限制，赢多少才抽水") @RequestParam(value = "costLimit", required = true) Double costLimit,
            @Parameter(required = true, name = "strengthLimit", description = "体力限制，低于多少体力不能进入游戏") @RequestParam(value = "strengthLimit", required = true) Integer strengthLimit,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            if (cost_pattern == Constants.Cost_Pattern_Com && StringUtil.isEmpty(commission)) {
                response.setReturnCode(Constants.RETURN_CODE_FAIL);
                response.setData("比例不允许给空！！");
            }else {

                groupPlayerService.updatCluConfigCostPattern(groupId,XYUid,cost_pattern,commission,cost_user_type, costLimit, strengthLimit);

                response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
                response.setData("修改成功");
            }

        }catch (InfServerException ie) {
            LOGGER.error("获取操作列表：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取操作列表：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "updatCluConfigMinCoins", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "修改进入游戏的最小分", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String updatCluConfigMinCoins(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "coins", description = "coins") @RequestParam(value = "coins", required = true) Integer coins,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {
            groupPlayerService.updatCluConfigMinCoins(groupId,XYUid,coins);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("修改成功");
        }catch (InfServerException ie) {
            LOGGER.error("获取操作列表：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取操作列表：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "/updateNotice", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "群主修改联盟公告", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String updateNotice(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "notice", description = "公告内容") @RequestParam(value = "notice", required = true) String notice,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request){
        Response response = new Response();
        try {
            groupNoticeService.updateNotice(groupId,XYUid, notice);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("修改成功");
        }catch (InfServerException ie) {
            LOGGER.error("群主修改联盟公告：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("群主修改联盟公告：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    // 前端要求：用POST请求
    @ResponseBody
    @RequestMapping(value = "/getNotice", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "联盟成员查看群公告", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String getNotice(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request){
        Response response = new Response();
        try {
            TGroupNotice groupNotice = groupNoticeService.getNotice(groupId, XYUid);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(groupNotice);
        }catch (InfServerException ie) {
            LOGGER.error("联盟成员查看群公告：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("联盟成员查看群公告：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }


    @ResponseBody
    @RequestMapping(value = "/selectGroupActivity", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "查询亲友圈参与桌子的战绩列表", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String selectGroupActivity(
            @Parameter(required = false, name = "groupId", description = "亲友圈ID") @RequestParam(value = "groupId", required = false) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = false, name = "dateStr", description = "日期,格式：yyyy-MM-dd") @RequestParam(value = "dateStr", required = false) String dateStr,
            @Parameter(required = false, name = "selectAll", description = "查全部成员传1，查自己传0") @RequestParam(value = "selectAll", required = false) Integer selectAll,
            @Parameter(required = false, name = "currentPage", description = "当前页数,不传默认为 1") @RequestParam(value = "currentPage", required = false, defaultValue = "1") Integer currentPage,
            @Parameter(required = false, name = "pageSize", description = "每页显示数,不传默认为 30") @RequestParam(value = "pageSize", required = false, defaultValue = "30") Integer pageSize,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
        Response response = new Response();
        try {
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(groupActivityService.selectGroupActivityjiByGroupIdAndPlayerId(groupId, XYUid, dateStr, selectAll, currentPage, pageSize));
        }catch (InfServerException ie) {
            LOGGER.error("查询亲友圈参与桌子的战绩列表：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("查询亲友圈参与桌子的战绩列表：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "/selectGroupZhanji", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "查询亲友圈单局战绩列表", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String selectGroupZhanji(
            @Parameter(required = true, name = "activityId", description = "组局ID") @RequestParam(value = "activityId", required = true) Integer activityId,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
        Response response = new Response();
        try {
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(groupActivityService.selectGroupZhanjiByActivityId(activityId));
        }catch (InfServerException ie) {
            LOGGER.error("查询单局战绩详情：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("查询单局战绩详情：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "/deletePlayerGroup", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "删除群成员（把群员踢出群，群主可以踢所有人，合伙人只能踢自己邀请进来的）", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String deletePlayerGroup(
            @Parameter(required = true, name = "groupId", description = "亲友圈ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "playerId2", description = "被删除人ID") @RequestParam(value = "playerId2", required = true) Integer playerId2,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
        Response response = new Response();
        try {
            playerGroupService.deletePlayerGroup(groupId, XYUid, playerId2);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("删除群成员成功");
        }catch (InfServerException ie) {
            LOGGER.error("删除群成员：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("删除群成员：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "/addGameConfig", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "添加玩法", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String addGameConfig(
            @Parameter(required = true, name = "groupId", description = "亲友圈ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,

            @Parameter(required = true, name = "level", description = "level") @RequestParam(value = "level", required = true) Integer level,
            @Parameter(required = true, name = "name", description = "name") @RequestParam(value = "name", required = true) String name,
            @Parameter(required = true, name = "config", description = "config") @RequestParam(value = "config", required = true) String config,

            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
        Response response = new Response();
        try {
            Map<String,Integer> result = playerGroupService.addGameConfig(groupId, XYUid, level, name, config);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);
        }catch (InfServerException ie) {
            LOGGER.error("添加玩法：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("添加玩法：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "/delGameConfig", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "删除玩法", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String delGameConfig(
            @Parameter(required = true, name = "groupId", description = "亲友圈ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,

            @Parameter(required = true, name = "configId", description = "configId") @RequestParam(value = "configId", required = true) Integer configId,

            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
        Response response = new Response();
        try {
            playerGroupService.delGameConfig(groupId, XYUid, configId);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("删除玩法");
        }catch (InfServerException ie) {
            LOGGER.error("删除玩法：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("删除玩法：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "/updateGameConfig", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "更新玩法", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String updateGameConfig(
            @Parameter(required = true, name = "groupId", description = "亲友圈ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,

            @Parameter(required = true, name = "configId", description = "configId") @RequestParam(value = "configId", required = true) Integer configId,
            @Parameter(required = false, name = "name", description = "name") @RequestParam(value = "name", required = false) String name,
            @Parameter(required = false, name = "config", description = "config") @RequestParam(value = "config", required = false) String config,

            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
        Response response = new Response();
        try {
            playerGroupService.updateGameConfig(groupId, XYUid, configId, name, config);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("更新玩法");
        }catch (InfServerException ie) {
            LOGGER.error("更新玩法：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("更新玩法：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }


    @ResponseBody
    @RequestMapping(value = "/selectGameConfig", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "选择玩法", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String selectGameConfig(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "groupId", description = "亲友圈ID") @RequestParam(value = "groupId", required = true) Integer groupId,

            @Parameter(required = false, name = "configId", description = "configId") @RequestParam(value = "configId", required = false) Integer configId,
            @Parameter(required = false, name = "level", description = "level") @RequestParam(value = "level", required = false) Integer level,
            @Parameter(required = false, name = "gameType", description = "gameType") @RequestParam(value = "gameType", required = false) Integer gameType,

            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
        Response response = new Response();
        try {
            List<TGroupGameconfig> result = playerGroupService.selectGameConfig(groupId, XYUid, configId, level, gameType);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);
        }catch (InfServerException ie) {
            LOGGER.error("选择玩法：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("选择玩法：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "/getClubPointRanking", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "获取联盟的积分排名", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String getClubPointRanking(
            @Parameter(required = true, name = "groupId", description = "亲友圈ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,

            @Parameter(required = false, name = "pageSize", description = "pageSize") @RequestParam(value = "pageSize", required = false, defaultValue = "10") Integer pageSize,
            @Parameter(required = false, name = "currentPage", description = "currentPage") @RequestParam(value = "currentPage", required = false, defaultValue = "1") Integer currentPage,


            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
        Response response = new Response();
        try {
            Map<String, Object> result = playerGroupService.getClubPointRanking(groupId, XYUid,currentPage, pageSize);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);
        }catch (InfServerException ie) {
            LOGGER.error("获取联盟的积分排名：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取联盟的积分排名：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }


    @ResponseBody
    @RequestMapping(value = "/getMyIDCard", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "获取我的名片,包括上级的名片", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String getMyIDCard(
            @Parameter(required = true, name = "groupId", description = "亲友圈ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,

            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
        Response response = new Response();
        try {
            Map<String, Object> result = playerGroupService.getMyIDCard(groupId, XYUid);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(result);
        }catch (InfServerException ie) {
            LOGGER.error("获取联盟的积分排名：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取联盟的积分排名：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "/updateMyIDCard", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "更新我的名片", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String updateMyIDCard(
            @Parameter(required = true, name = "groupId", description = "亲友圈ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,

            @Parameter(required = false, name = "wechat", description = "wechat") @RequestParam(value = "wechat", required = false) String wechat,
            @Parameter(required = false, name = "qq", description = "qq") @RequestParam(value = "qq", required = false) String qq,
            @Parameter(required = false, name = "xianliao", description = "xianliao") @RequestParam(value = "xianliao", required = false) String xianliao,

            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
        Response response = new Response();
        try {

//            if (StringUtil.isEmpty(wechat) && StringUtil.isEmpty(qq) && StringUtil.isEmpty(xianliao)) {
//                response.setReturnCode(Constants.RETURN_CODE_FAIL);
//                response.setError("请修改需要更新的名片");
//            }else {
            playerGroupService.updateMyIDCard(groupId, XYUid,wechat,qq,xianliao);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("修改成功");
//            }

        }catch (InfServerException ie) {
            LOGGER.error("更新我的名片：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("更新我的名片：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("网络异常，请稍后再试！！");
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "selectMyXiaohaoList", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "获取我的反水情况", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String selectMyXiaohaoList(
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,

            @Parameter(required = false, name = "searchUid", description = "searchUid") @RequestParam(value = "searchUid", required = false) Integer searchUid,

            @Parameter(required = false, name = "currentPage", description = "当前页") @RequestParam(value = "currentPage", required = false, defaultValue = "1") Integer currentPage,
            @Parameter(required = false, name = "pageSize", description = "每页显示数,可以不穿,默认为10") @RequestParam(required = false,value = "pageSize", defaultValue = "10") Integer pageSize,

            @Parameter(required = false, name = "startTime", description = "开始时间 格式 yyyy-MM-dd HH:mm:ss") @RequestParam(value = "startTime", required = false) String startTime,
            @Parameter(required = false, name = "endTime", description = "结束时间 年月日") @RequestParam(value = "endTime", required = false) String endTime,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            Map<String, Object> result = groupPlayerService.selectMyXiaohaoList(groupId, XYUid, searchUid, currentPage, pageSize, startTime, endTime);
            response.setData(result);

        }catch (InfServerException ie) {
            LOGGER.error("获取我的反水情况：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取我的反水情况：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "addJoinGameLimit", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "添加同桌限制", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String addJoinGameLimit(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "addUser", description = "addUser") @RequestParam(value = "addUser", required = true) String addUser,
            @Parameter(required = false, name = "key", description = "key") @RequestParam(value = "key", required = false) String key,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.addJoinGameLimit(groupId, XYUid, addUser, key);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);

        }catch (InfServerException ie) {
            LOGGER.error("添加同桌限制：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("添加同桌限制：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "delJoinGameLimit", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "删除同桌限制", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String delJoinGameLimit(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "key", description = "key") @RequestParam(value = "key", required = true) String key,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.delJoinGameLimit(groupId, XYUid, key);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);

        }catch (InfServerException ie) {
            LOGGER.error("删除同桌限制：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("删除同桌限制：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "queryJoinGameLimit", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "查询同桌限制", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String queryJoinGameLimit(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            response.setData(groupPlayerService.queryJoinGameLimit(groupId, XYUid));

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);

        }catch (InfServerException ie) {
            LOGGER.error("添加同桌限制：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("添加同桌限制：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "updateClubThresholdValue", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "设置阀值", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String updateClubThresholdValue(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
            @Parameter(required = true, name = "hehuorenId", description = "合伙人ID") @RequestParam(value = "hehuorenId", required = true) Integer hehuorenId,
            @Parameter(required = true, name = "thresholdValue", description = "阀值") @RequestParam(value = "thresholdValue", required = true) Integer thresholdValue,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {

            groupPlayerService.updateClubThresholdValue(XYUid, groupId, hehuorenId, thresholdValue);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);

        }catch (InfServerException ie) {
            LOGGER.error("设置阀值：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("设置阀值：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
        }
        return responseJsonString(response, interfaceType);
    }

//    @ResponseBody
//    @RequestMapping(value = "updatCostUserType", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "修改进入游戏的最小分", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String updatCostUserType(
//            @Parameter(required = true, name = "groupId", description = "群ID") @RequestParam(value = "groupId", required = true) Integer groupId,
//            @Parameter(required = true, name = "ownerId", description = "ownerId") @RequestParam(value = "ownerId", required = true) Integer ownerId,
//            @Parameter(required = true, name = "costUserType", description = "抽取的用户群体 0 大赢家 1 赢家") @RequestParam(value = "costUserType", required = true) Integer costUserType,
//
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//
//
//            groupPlayerService.updatCostUserType(groupId,ownerId,costUserType);
//
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData("修改成功");
//
//
//        }catch (InfServerException ie) {
//            LOGGER.error("获取操作列表：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("获取操作列表：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError("网络异常，请稍后再试！！");
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }

}
