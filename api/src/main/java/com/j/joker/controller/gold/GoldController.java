package com.j.joker.controller.gold;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.cache.controller.BaseCacheController;
import com.j.joker.constants.Constants;
import com.j.joker.service.Gold.GoldService;
import com.j.joker.utils.CommonUtil;
import com.j.joker.utils.IDCardUtil;
import com.j.joker.utils.InfServerException;
import com.j.joker.vo.response.Response;
import com.j.joker.vo.response.gold.pickUpGoldVo;
import io.swagger.v3.oas.annotations.tags.Tag;
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
import java.util.List;
import java.util.Map;

/**
 * Created by muzi on 16/11/2017.
 */
@Tag(name = "房卡场相关接口")
@RequestMapping(value = "gold")
@Controller
public class GoldController {
    private static final Logger LOGGER = Logger.getLogger(GoldController.class);

    @Autowired
    private GoldService goldService;

//    @ResponseBody
//    @RequestMapping(value = "getPlayerCountByPlayerBind", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @Operation(summary = "查询玩家绑定代理的数量", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String getPlayerCountByPlayerBind(
//            @Parameter(required = true, name = "userId", description = "玩家ID") @RequestParam(required = true, value = "userId") Long playerId,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            Map<String,String> result =  goldService.getPlayerCountByPlayerBind(playerId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(result);
//        } catch (InfServerException ie) {
//            LOGGER.error("查询玩家数量：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("查询玩家数量：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }

    @ResponseBody
    @RequestMapping(value = "authIdCard", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
    @Operation(summary = "实名认证", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String authIdCard(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Long XYUid,
            @Parameter(required = true, name = "name", description = "name") @RequestParam(required = true, value = "name") String name,
            @Parameter(required = true, name = "idCardNo", description = "省份证号码") @RequestParam(required = true, value = "idCardNo") String idCardNo,
            @Parameter(required = true, name = "phone", description = "phone") @RequestParam(required = true, value = "phone") String phone,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {
            boolean flag1 = IDCardUtil.isChineseName(name);
            boolean flag2 = IDCardUtil.isIDCard(idCardNo);
            boolean flag3 = IDCardUtil.isChinaPhoneLegal(phone);
            if (flag1 && flag2 && flag3) {
                goldService.authIdCard(XYUid,name,idCardNo,phone);
                response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
                response.setData("实名认证成功!!");
            }else {
                response.setReturnCode(Constants.RETURN_CODE_FAIL);
                if (!flag1) {
                    response.setError("请输入有效的名字!!");
                }else if (!flag2) {
                    response.setError("请输入正确的身份证号码!!");
                }else if (!flag3){
                    response.setError("请输入正确的手机号码!!");
                }else {
                    response.setError("请输入有效的身份信息");
                }
            }
        } catch (InfServerException ie) {
            LOGGER.error("实名认证：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("实名认证：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
            return CommonUtil.buildJSONPResponse(method, response);
        }
        return JSON.toJSONString(response);
    }


//    @ResponseBody
//    @RequestMapping(value = "complaint2Admin", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @Operation(summary = "问题反馈", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String complaint2Admin(
//            @Parameter(required = true, name = "userId", description = "玩家ID") @RequestParam(required = true, value = "userId") Long playerId,
//            @Parameter(required = true, name = "Context", description = "Context") @RequestParam(required = true, value = "Context") String context,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            if (context.length() > 100 ) {
//                response.setReturnCode(Constants.RETURN_CODE_FAIL);
//                response.setData("抱歉,您输入的内容过长,请重新输入!!");
//            }else {
//                goldService.complaint2Admin(playerId,context);
//                response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//                response.setData("反馈成功,感谢您宝贵的建议!!");
//            }
//        } catch (InfServerException ie) {
//            LOGGER.error("问题反馈：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("问题反馈：", e);
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
//    @ResponseBody
//    @RequestMapping(value = "getUserInfo", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @Operation(summary = "获取用户信息", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String getUserInfo(
//            @Parameter(required = true, name = "userId", description = "玩家ID") @RequestParam(required = true, value = "userId") Long playerId,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//                Map<String,String> result = goldService.getUserInfo(playerId);
//                response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//                response.setData(result);
//
//        } catch (InfServerException ie) {
//            LOGGER.error("获取用户信息：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("获取用户信息：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }


    @ResponseBody
    @RequestMapping(value = "saveSigName", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
    @Operation(summary = "保存用户的个性签名", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String saveSigName(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Long XYUid,
            @Parameter(required = true, name = "context", description = "玩家ID") @RequestParam(required = true, value = "context") String context,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {
            goldService.saveSigName(XYUid,context);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("保存成功");

        } catch (InfServerException ie) {
            LOGGER.error("获取用户信息：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取用户信息：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
            return CommonUtil.buildJSONPResponse(method, response);
        }
        return JSON.toJSONString(response);
    }

    @ResponseBody
    @RequestMapping(value = "getGameTypeByRoomType", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
    @Operation(summary = "查询游戏的游戏和分场详情", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String getGameTypeByRoomType(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
            @Parameter(required = false, name = "isGoldRoom", description = "是否房卡场 1 : 房卡场, 2 : 房卡场") @RequestParam(required = false, value = "isGoldRoom") Integer roomType,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {
            response = goldService.getGameTypeByRoomType(roomType);

        } catch (InfServerException ie) {
            LOGGER.error("获取用户信息：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取用户信息：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
            return CommonUtil.buildJSONPResponse(method, response);
        }
        return JSON.toJSONString(response);
    }

    @ResponseBody
    @RequestMapping(value = "getGameConfigByLevelAndGold", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
    @Operation(summary = "查询游戏配置", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String getGameConfigByLevelAndGold(
            @Parameter(required = true, name = "level", description = "通过level查询游戏配置") @RequestParam(required = true, value = "level") Integer level,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {
            response = goldService.getGameConfigByLevel(level);
        } catch (InfServerException ie) {
            LOGGER.error("获取用户信息：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("获取用户信息：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
            return CommonUtil.buildJSONPResponse(method, response);
        }
        return JSON.toJSONString(response);
    }

//    @ResponseBody
//    @RequestMapping(value = "save2repository", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @Operation(summary = "仓库存取房卡", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String save2repository(
//            @Parameter(required = true, name = "playerId", description = "玩家ID") @RequestParam(required = true, value = "playerId") Long playerId,
//            @Parameter(required = true, name = "count", description = "房卡数量") @RequestParam(required = true, value = "count") Long count,
//            @Parameter(required = true, name = "type", description = "存取类型 : 0: 存  1 取") @RequestParam(required = true, value = "type") Long type,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            System.out.println("xxxxx");
//            response = goldService.save2repository(playerId,count,type);
//        } catch (InfServerException ie) {
//            LOGGER.error("仓库存取房卡：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("仓库存取房卡：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }



//    @ResponseBody
//    @RequestMapping(value = "pickUpGold", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @Operation(summary = "房主佣金提房卡,只有提取", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String pickUpGold(
//            @Parameter(required = true, name = "playerId", description = "玩家ID") @RequestParam(required = true, value = "playerId") Long playerId,
//            @Parameter(required = true, name = "count", description = "房卡数量") @RequestParam(required = true, value = "count") Long count,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            response = goldService.pickUpGold(playerId,count);
//        } catch (InfServerException ie) {
//            LOGGER.error("房主佣金提取：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("房主佣金提取：", e);
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
//    @ResponseBody
//    @RequestMapping(value = "getPickUpGoldList", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @Operation(summary = "房主佣金提房卡记录", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String getPickUpGoldList(
//            @Parameter(required = true, name = "playerId", description = "玩家ID") @RequestParam(required = true, value = "playerId") Long playerId,
//            @Parameter(required = true, name = "currentPage", description = "当前页") @RequestParam(value = "currentPage") String currentPage,
//            @Parameter(required = false, name = "pageSize", description = "每页显示数,可以不穿,默认为10") @RequestParam(required = false,value = "pageSize") String pageSize,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<pickUpGoldVo> result = goldService.getPickUpGoldList(playerId,currentPage,pageSize);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(result);
//
//        } catch (InfServerException ie) {
//            LOGGER.error("房主佣金提房卡记录：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("房主佣金提房卡记录：", e);
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
//    @ResponseBody
//    @RequestMapping(value = "getPlayerCommissionList", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @Operation(summary = "房主佣金提房卡记录", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String getPlayerCommissionList(
//            @Parameter(required = true, name = "playerId", description = "玩家ID") @RequestParam(required = true, value = "playerId") Long playerId,
//            @Parameter(required = true, name = "year", description = "年") @RequestParam(required = true, value = "year") Long year,
//            @Parameter(required = true, name = "month", description = "月") @RequestParam(required = true, value = "month") Long month,
//
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            JSONObject result = goldService.getPlayerCommissionList(playerId,year,month);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(result);
//
//        } catch (InfServerException ie) {
//            LOGGER.error("房主佣金提房卡记录：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("房主佣金提房卡记录：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }




    /**
     * 排行榜  需要的数据 头衔地址  名字 签名  房卡数量  数量20个
     * @param interfaceType
     * @param request
     * @return
     */

//    @ResponseBody
//    @RequestMapping(value = "getGoldRanking", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @Operation(summary = "财富榜", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String getGoldRanking(
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType, HttpServletRequest request) {
//        Response response = new Response();
//        try {
//
//            String result = goldService.getGoldRanking();
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(result);
//
//        } catch (InfServerException ie) {
//            LOGGER.error("财富榜：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("财富榜：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }

    @ResponseBody
    @RequestMapping(value = "getPayType", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
    @Operation(summary = "获取支付类型", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public Response getPayType(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType, HttpServletRequest request) {
        Response response = new Response();
        try {

            String type = goldService.queryConfigByPayType();
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(type);
            return response;
        }catch (Exception e) {
            LOGGER.error("获取支付类型：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
            return response;
        }
    }
}
