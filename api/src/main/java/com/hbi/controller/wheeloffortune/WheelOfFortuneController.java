//package com.hbi.controller.wheeloffortune;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.hbi.constants.Constants;
//import com.hbi.model.TFortuneAddress;
//import com.hbi.model.TFortuneRecord;
//import com.hbi.service.common.UserService;
//import com.hbi.service.gift.TConfigService;
//import com.hbi.service.wheeloffortune.WheelOfFortuneService;
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
//import java.util.List;
//
///**
// * Created by dzesla on 2017/2/17.
// */
//
//@Api(basePath = "", value = "抽奖转盘接口", position = 1)
//@RequestMapping(value = "fortune")
//@Controller
//public class WheelOfFortuneController {
//    private static final Logger LOGGER = Logger.getLogger(WheelOfFortuneController.class);
//
//    @Autowired
//    private WheelOfFortuneService wheelOfFortuneService;
//    @Autowired
//    private UserService userService;
//    @Autowired
//    private TConfigService configService;
//
//    @ResponseBody
//    @RequestMapping(value = "queryAwardList", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询奖品列表", position = 2, response = Response.class)
//    public String queryAwardList(
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            String json = wheelOfFortuneService.queryAwardList();
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(json);
//        } catch (InfServerException ie) {
//            LOGGER.error("查询奖品列表：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("查询奖品列表：", e);
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
//    @RequestMapping(value = "roll", method = { RequestMethod.POST,
//            RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "摇奖", position = 2, response = Response.class)
//    public String roll(
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(required = true, value = "userId") Long userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            TFortuneRecord record = wheelOfFortuneService.roll(userId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            if (record != null) {
//                response.setData(record);
//            }
//        } catch (InfServerException ie) {
//            LOGGER.error("摇奖：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("摇奖：", e);
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
//    @RequestMapping(value = "bindAddress", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "绑定收获地址", position = 1, response = Response.class)
//    public String bindAddress (
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(required = true, value = "userId") Long userId,
//            @ApiParam(required = true, name = "addressId", value = "地址ID")
//            @RequestParam(required = true, value = "addressId") Long addressId,
//            @ApiParam(required = true, name = "fortuneRecordId", value = "奖品记录ID")
//            @RequestParam(required = true, value = "fortuneRecordId") Long fortuneRecordId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            wheelOfFortuneService.bindAddress(userId, addressId, fortuneRecordId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (InfServerException ie) {
//            LOGGER.error("绑定收获地址：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("绑定收获地址：", e);
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
//    @RequestMapping(value = "addAddress", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "添加收获地址", position = 1, response = Response.class)
//    public String addAddress (
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(required = true, value = "userId") Long userId,
//            @ApiParam(required = true, name = "userName", value = "收件人姓名")
//            @RequestParam(required = true, value = "userName") String userName,
//            @ApiParam(required = true, name = "phone", value = "收件人手机号")
//            @RequestParam(required = true, value = "phone") String phone,
//            @ApiParam(required = true, name = "address", value = "地址")
//            @RequestParam(required = true, value = "address") String address,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            wheelOfFortuneService.addAddress(userId, userName, phone, address);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (InfServerException ie) {
//            LOGGER.error("添加收获地址：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("添加收获地址：", e);
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
//    @RequestMapping(value = "deleteAddress", method = {RequestMethod.POST,RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "删除收获地址", position = 1, response = Response.class)
//    public String deleteAddress (
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(required = true, value = "userId") Long userId,
//            @ApiParam(required = true, name = "addressId", value = "地址ID")
//            @RequestParam(required = true, value = "addressId") Long addressId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            wheelOfFortuneService.deleteAddress(userId, addressId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (InfServerException ie) {
//            LOGGER.error("删除收获地址：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("删除收获地址：", e);
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
//    @RequestMapping(value = "queryAddress", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询收获地址", position = 1, response = Response.class)
//    public String queryAddress (
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(required = true, value = "userId") Long userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<TFortuneAddress> list= wheelOfFortuneService.queryAddress(userId);
//            response.setData(list);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (InfServerException ie) {
//            LOGGER.error("查询收获地址：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("查询收获地址：", e);
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
//    /**
//     * 赠送积分
//     * @param userId
//     * @param toUserId
//     * @param point
//     * @param request
//     * @return
//     */
//    @ResponseBody
//    @RequestMapping(value = "giftPoints", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "赠送积分", position = 2, response = Response.class)
//    public String giftPoints (
//            @ApiParam(required = true, name = "userId", value = "赠送人ID") @RequestParam(required = true, value = "userId") Long userId,
//            @ApiParam(required = true, name = "toUserId", value = "接受人ID") @RequestParam(required = true, value = "toUserId") Long toUserId,
//            @ApiParam(required = true, name = "point",value = "赠送多少积分") @RequestParam(required = true, value = "point") Integer point,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            //判断传入的数据是否为空
//            if (userId == null || toUserId == null || point == null ) {
//                response.setReturnCode(Constants.RETURN_CODE_PARAM_ERROR);
//                response.setData("请传入正确的参数");
//                return JSON.toJSONString(response);
//            }
//            if (Integer.valueOf(configService.getLeastGiftPoints()) > point) {
//                response.setReturnCode(Constants.RETURN_CODE_PARAM_ERROR);
//                response.setData("积分不得小于最少积分");
//                return JSON.toJSONString(response);
//            }
//
//            //如果赠送人的积分足够,则进行交换
//            Integer currentPoint = userService.changePoints(userId,toUserId,point);
//            JSONObject obj = new JSONObject();
//            obj.put("userId",userId);
//            obj.put("points",currentPoint);
//            obj.put(Constants.RETURN_CODE_SUCCESS,"赠送成功");
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(obj);
//        }catch (InfServerException ie) {
//            LOGGER.error("赠送积分：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        }catch (Exception e) {
//            LOGGER.error("查询收获地址：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//        }
//        return JSON.toJSONString(response);
//    }
//
//    /**
//     * 赠送房卡
//     * @param userId
//     * @param toUserId
//     * @param roomCard
//     * @param request
//     * @return
//     */
//    @ResponseBody
//    @RequestMapping(value = "giftRoomCard", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "赠送房卡", position = 2, response = Response.class)
//    public String giftRoomCard (
//            @ApiParam(required = true, name = "userId", value = "赠送人ID") @RequestParam(required = true, value = "userId") Long userId,
//            @ApiParam(required = true, name = "toUserId", value = "接受人ID") @RequestParam(required = true, value = "toUserId") Long toUserId,
//            @ApiParam(required = true, name = "roomCard",value = "赠送多少房卡") @RequestParam(required = true, value = "roomCard") Integer roomCard,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            //判断传入的数据是否为空
//            if (userId == null || toUserId == null || roomCard == null || roomCard <= 0 ) {
//                response.setReturnCode(Constants.RETURN_CODE_PARAM_ERROR);
//                response.setData("请传入正确的参数");
//                return JSON.toJSONString(response);
//            }
//
////            if (Integer.valueOf(configService.getLeastGiftCardRoom()) > roomCard) {
////                response.setReturnCode(Constants.RETURN_CODE_PARAM_ERROR);
////                response.setData("房卡不得小于最少房卡");
////                return JSON.toJSONString(response);
////            }
//
//            //如果赠送人的积分足够,则进行交换
//            Integer currentRoomCard = userService.changeRoomcard(userId,toUserId,roomCard);
//            JSONObject obj = new JSONObject();
//            obj.put("userId",userId);
//            obj.put("points",currentRoomCard);
//            obj.put(Constants.RETURN_CODE_SUCCESS,"赠送成功");
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(obj);
//        }catch (InfServerException ie) {
//            LOGGER.error("赠送积分：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        }catch (Exception e) {
//            LOGGER.error("查询收获地址：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//        }
//        return JSON.toJSONString(response);
//    }
//
//    /**
//     * 需要的最少积分
//     * @param request
//     * @return
//     */
//    @ResponseBody
//    @RequestMapping(value = "getLeastGiftPoints", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "最少赠送积分", position = 2, response = Response.class)
//    public String getLeastGiftPoints(HttpServletRequest request) {
//        Response response = new Response();
//        String leastGiftPoints = configService.getLeastGiftPoints();
//        if (leastGiftPoints == null || leastGiftPoints.trim() == "") {
//            response.setError(Constants.RETURN_CODE_FAIL);
//            response.setError("获取失败");
//        }
//        response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        response.setData(leastGiftPoints);
//        return JSON.toJSONString(response);
//    }
//
//    /**
//     * 需要的最少房卡
//     * @param request
//     * @return
//     */
//    @ResponseBody
//    @RequestMapping(value = "getLeastGiftCardRoom", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "最少赠送房卡", position = 2, response = Response.class)
//    public String getLeastGiftCardRoom(HttpServletRequest request) {
//        String leastGiftCardRoom = configService.getLeastGiftCardRoom();
//        Response response = new Response();
//        if (leastGiftCardRoom == null || leastGiftCardRoom.trim() == "") {
//            response.setError(Constants.RETURN_CODE_FAIL);
//            response.setError("获取失败");
//        }
//        response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        response.setData(leastGiftCardRoom);
//        return JSON.toJSONString(response);
//    }
//
//    /**
//     * 获取轮播图的图片
//     * @param request
//     * @return
//     */
//    @ResponseBody
//    @RequestMapping(value = "getAdvertList", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "获取图片地址列表", position = 2, response = Response.class)
//    public String getAdvertList(HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            String result = wheelOfFortuneService.getAdvertList();
//            System.out.println(result);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(result);
//        }catch (InfServerException ie) {
//            LOGGER.error("获取轮播图列表：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        }catch (Exception e) {
//            LOGGER.error("获取轮播图列表：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//        }
//        return JSON.toJSONString(response);
//    }
//}
