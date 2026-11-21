//package com.hbi.controller.charge;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.hbi.constants.Constants;
//import com.hbi.service.charge.YeePayService;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.wordnik.swagger.annotations.Api;
//import com.wordnik.swagger.annotations.ApiOperation;
//import com.wordnik.swagger.annotations.ApiParam;
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
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
// * Created by dzesla on 2016/12/27.
// */
//
//@Api(basePath = "", value = "易宝支付接口", position = 1)
//@RequestMapping(value = "yeepay")
//@Controller
//public class YeePayController {
//    @Autowired
//    private YeePayService yeePayService;
//
//    private static final Log log = LogFactory.getLog(YeePayController.class);
//
//    @ResponseBody
//    @RequestMapping(value = "payOrder", method = { RequestMethod.POST,
//            RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "订单支付接口", position = 2, response = Response.class)
//    public String payOrder(
//            @ApiParam(required = true, name = "userId", value = "用户id")
//            @RequestParam(value = "userId") Long userId,
//            @ApiParam(required = true, name = "goodsId", value = "商品id")
//            @RequestParam(value = "goodsId") Long goodsId,
//            @ApiParam(required = true, name = "amount", value = "商品数量")
//            @RequestParam(value = "amount") Integer amount,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            String payUrl = yeePayService.payOrder(userId, goodsId, amount, request);
//            JSONObject obj = new JSONObject();
//            obj.put("payUrl", payUrl);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(obj);
//        } catch (InfServerException ie) {
//            log.error("订单支付接口：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("订单支付接口：", e);
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
//    @ApiOperation(value = "支付回调接口", position = 2, response = Response.class)
//    public String payOrderCallback(
//            @ApiParam(required = true, name = "data", value = "数据")
//            @RequestParam(value = "data") String data,
//            @ApiParam(required = true, name = "encryptkey", value = "key")
//            @RequestParam(value = "encryptkey") String encryptkey,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            yeePayService.payOrderCallback(data, encryptkey);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (InfServerException ie) {
//            log.error("订单支付接口：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("订单支付接口：", e);
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
//    @ApiOperation(value = "支付回调测试接口", position = 2, response = Response.class)
//    public String payOrderCallbackTest(
//            @ApiParam(required = true, name = "orderId", value = "订单ID")
//            @RequestParam(value = "orderId") String orderId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            yeePayService.payOrderCallbackTest(orderId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (InfServerException ie) {
//            log.error("订单支付接口：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("订单支付接口：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//}
