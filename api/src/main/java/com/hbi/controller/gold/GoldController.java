package com.hbi.controller.gold;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.constants.Constants;
import com.hbi.service.Gold.GoldService;
import com.hbi.utils.CommonUtil;
import com.hbi.utils.IDCardUtil;
import com.hbi.utils.InfServerException;
import com.hbi.vo.response.Response;
import com.hbi.vo.response.gold.pickUpGoldVo;
import com.wordnik.swagger.annotations.Api;
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
import java.util.List;
import java.util.Map;

/**
 * Created by muzi on 16/11/2017.
 */
@Api(basePath = "/gold", value = "房卡场相关接口", position = 1)
@RequestMapping(value = "gold")
@Controller
public class GoldController {
    private static final Logger LOGGER = Logger.getLogger(GoldController.class);

    @Autowired
    private GoldService goldService;

//    @ResponseBody
//    @RequestMapping(value = "getPlayerCountByPlayerBind", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询玩家绑定代理的数量", position = 2, response = Response.class)
//    public String getPlayerCountByPlayerBind(
//            @ApiParam(required = true, name = "userId", value = "玩家ID") @RequestParam(required = true, value = "userId") Long playerId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
    @ApiOperation(value = "实名认证", position = 2, response = Response.class)
    public String authIdCard(
            @ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") Long XYUid,
            @ApiParam(required = true, name = "name", value = "name") @RequestParam(required = true, value = "name") String name,
            @ApiParam(required = true, name = "idCardNo", value = "省份证号码") @RequestParam(required = true, value = "idCardNo") String idCardNo,
            @ApiParam(required = true, name = "phone", value = "phone") @RequestParam(required = true, value = "phone") String phone,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//    @ApiOperation(value = "问题反馈", position = 2, response = Response.class)
//    public String complaint2Admin(
//            @ApiParam(required = true, name = "userId", value = "玩家ID") @RequestParam(required = true, value = "userId") Long playerId,
//            @ApiParam(required = true, name = "Context", value = "Context") @RequestParam(required = true, value = "Context") String context,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//    @ApiOperation(value = "获取用户信息", position = 2, response = Response.class)
//    public String getUserInfo(
//            @ApiParam(required = true, name = "userId", value = "玩家ID") @RequestParam(required = true, value = "userId") Long playerId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
    @ApiOperation(value = "保存用户的个性签名", position = 2, response = Response.class)
    public String saveSigName(
            @ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") Long XYUid,
            @ApiParam(required = true, name = "context", value = "玩家ID") @RequestParam(required = true, value = "context") String context,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
    @ApiOperation(value = "查询游戏的游戏和分场详情", position = 2, response = Response.class)
    public String getGameTypeByRoomType(
            @ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") String XYUid,
            @ApiParam(required = false, name = "isGoldRoom", value = "是否房卡场 1 : 房卡场, 2 : 房卡场") @RequestParam(required = false, value = "isGoldRoom") Integer roomType,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
    @ApiOperation(value = "查询游戏配置", position = 2, response = Response.class)
    public String getGameConfigByLevelAndGold(
            @ApiParam(required = true, name = "level", value = "通过level查询游戏配置") @RequestParam(required = true, value = "level") Integer level,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//    @ApiOperation(value = "仓库存取房卡", position = 2, response = Response.class)
//    public String save2repository(
//            @ApiParam(required = true, name = "playerId", value = "玩家ID") @RequestParam(required = true, value = "playerId") Long playerId,
//            @ApiParam(required = true, name = "count", value = "房卡数量") @RequestParam(required = true, value = "count") Long count,
//            @ApiParam(required = true, name = "type", value = "存取类型 : 0: 存  1 取") @RequestParam(required = true, value = "type") Long type,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//    @ApiOperation(value = "房主佣金提房卡,只有提取", position = 2, response = Response.class)
//    public String pickUpGold(
//            @ApiParam(required = true, name = "playerId", value = "玩家ID") @RequestParam(required = true, value = "playerId") Long playerId,
//            @ApiParam(required = true, name = "count", value = "房卡数量") @RequestParam(required = true, value = "count") Long count,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//    @ApiOperation(value = "房主佣金提房卡记录", position = 2, response = Response.class)
//    public String getPickUpGoldList(
//            @ApiParam(required = true, name = "playerId", value = "玩家ID") @RequestParam(required = true, value = "playerId") Long playerId,
//            @ApiParam(required = true, name = "currentPage", value = "当前页") @RequestParam(value = "currentPage") String currentPage,
//            @ApiParam(required = false, name = "pageSize", value = "每页显示数,可以不穿,默认为10") @RequestParam(required = false,value = "pageSize") String pageSize,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//    @ApiOperation(value = "房主佣金提房卡记录", position = 2, response = Response.class)
//    public String getPlayerCommissionList(
//            @ApiParam(required = true, name = "playerId", value = "玩家ID") @RequestParam(required = true, value = "playerId") Long playerId,
//            @ApiParam(required = true, name = "year", value = "年") @RequestParam(required = true, value = "year") Long year,
//            @ApiParam(required = true, name = "month", value = "月") @RequestParam(required = true, value = "month") Long month,
//
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//    @ApiOperation(value = "财富榜", position = 2, response = Response.class)
//    public String getGoldRanking(
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType, HttpServletRequest request) {
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
    @ApiOperation(value = "获取支付类型", position = 2, response = Response.class)
    public Response getPayType(
            @ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") String XYUid,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType, HttpServletRequest request) {
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
