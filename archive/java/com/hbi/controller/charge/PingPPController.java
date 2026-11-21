//package com.hbi.controller.charge;
//
//import com.alibaba.fastjson.JSON;
//import com.core.util.ConfigUtil;
//import com.hbi.constants.Constants;
//import com.hbi.service.charge.PayBy980Service;
//import com.hbi.service.charge.PingPPService;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.pingplusplus.model.Charge;
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
// * Created by dzesla on 2017/2/15.
// */
//
//@Api(basePath = "", value = "ping++支付接口", position = 1)
//@RequestMapping(value = "pingpp")
//@Controller
//public class PingPPController {
//    private static final Logger log = Logger.getLogger(PingPPController.class);
//
//    @Autowired
//    private PingPPService pingPPService;
//    @Autowired
//    private PayBy980Service payBy980Service;
//
//    @ResponseBody
//    @RequestMapping(value = "payOrder", method = { RequestMethod.POST,
//            RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "ping++订单支付接口", position = 2, response = Response.class)
//    public String payOrder(
//            @ApiParam(required = true, name = "userId", value = "用户id")
//            @RequestParam(value = "userId") Long userId,
//            @ApiParam(required = true, name = "goodsId", value = "商品id")
//            @RequestParam(value = "goodsId") Long goodsId,
//            @ApiParam(required = true, name = "amount", value = "商品数量")
//            @RequestParam(value = "amount") Integer amount,
//            @ApiParam(name = "payType", value = "支付类型",required = false)
//            @RequestParam(value = "payType") String payType,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            String payTypeChannl = ConfigUtil.get("payTypeChannl");
//            if ("biqi".equals(payTypeChannl)) {
//                Response response1 = payBy980Service.payOrderNiu(userId, goodsId, amount, payType);
//                return JSON.toJSONString(response1);
//            }else {
//                Charge charge = pingPPService.payOrder(userId, goodsId, amount, payType);
//                response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//                response.setData(charge);
//            }
//        } catch (InfServerException ie) {
//            log.error("ping++订单支付接口：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("ping++订单支付接口：", e);
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
//    @RequestMapping(value = "payOrderCallback", method = { RequestMethod.POST,
//            RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "ping++支付回调接口", position = 2, response = Response.class)
//    public String payOrderCallback(
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            pingPPService.payOrderCallback(request);
//        } catch (InfServerException ie) {
//            log.error("ping++支付回调接口inf：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("ping++支付回调接口：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "payOrderCallbackTest", method = { RequestMethod.POST,
//            RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "ping++支付回调测试接口", position = 2, response = Response.class)
//    public String payOrderCallbackTest(
//            @ApiParam(required = true, name = "orderId", value = "订单ID")
//            @RequestParam(value = "orderId") String orderId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            pingPPService.payOrderCallbackTest(orderId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (InfServerException ie) {
//            log.error("ping++支付回调测试接口：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("ping++支付回调测试接口：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "changeGold2BiqiCard", method = { RequestMethod.POST,
//            RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "用金币兑换比奇卡", position = 2, response = Response.class)
//    public String changeGold2BiqiCard(
//            @ApiParam(required = true, name = "playerId", value = "玩家ID") @RequestParam(value = "playerId") Long playerId,
//            @ApiParam(required = true, name = "goodsId", value = "商品id") @RequestParam(value = "goodsId") Long goodsId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            response = pingPPService.changeGold2BiqiCard(playerId,goodsId);
//        } catch (InfServerException ie) {
//            log.error("用金币兑换比奇卡：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("用金币兑换比奇卡:", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
////    @ResponseBody
////    @RequestMapping(value = "reloadData", method = { RequestMethod.POST,
////            RequestMethod.GET }, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "重置数据(房卡+房卡)", position = 2, response = Response.class)
////    public String reloadData(
////            @ApiParam(required = false, name = "gold", value = "gold") @RequestParam(required = false, value = "gold") Long gold,
////            @ApiParam(required = false, name = "card", value = "card") @RequestParam(required = false, value = "card") Long card,
////            @RequestParam(required = false, value = "interfaceType") String interfaceType,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            pingPPService.reloadData(gold,card);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////        } catch (InfServerException ie) {
////            log.error("重置数据(房卡+房卡)", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////        } catch (Exception e) {
////            log.error("重置数据(房卡+房卡)", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////        }
////        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
////            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
////            return CommonUtil.buildJSONPResponse(method, response);
////        }
////        return JSON.toJSONString(response);
////    }
////
////    @ResponseBody
////    @RequestMapping(value = "testxxxxx", method = { RequestMethod.POST,
////            RequestMethod.GET }, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "xxx", position = 2, response = Response.class)
////    public String testxxxxx(
////            @ApiParam(required = true, name = "userId", value = "userId") @RequestParam(value = "userId") Integer userId,
////            @ApiParam(required = true, name = "count", value = "count") @RequestParam(value = "count") Integer count,
////            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            pingPPService.testxxxxx(userId,count);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////        } catch (InfServerException ie) {
////            log.error("ping++支付回调测试接口：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////        } catch (Exception e) {
////            log.error("ping++支付回调测试接口：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////        }
////        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
////            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
////            return CommonUtil.buildJSONPResponse(method, response);
////        }
////        return JSON.toJSONString(response);
////    }
//
//
//}
