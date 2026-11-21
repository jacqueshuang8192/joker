//package com.hbi.controller.charge;
//
//import com.alibaba.fastjson.JSONObject;
//import com.hbi.constants.Constants;
//import com.hbi.service.charge.SFPayService;
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
// * Created by muzi on 2017/12/15.
// */
//@Api(basePath = "", value = "sf支付接口", position = 1)
//@RequestMapping(value = "/sfPay")
//@Controller
//public class SFPayController {
//
//    private static final Logger log = Logger.getLogger(SFPayController.class);
//
//    @Autowired
//    private SFPayService sfPayService;
//
//
//
//    @ResponseBody
//    @RequestMapping(value = "/payOrder", method = { RequestMethod.POST},produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "sf订单支付接口", position = 2, response = Response.class)
//    public Response payOrder(
//            @ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") Long userId,
//            @ApiParam(required = true, name = "goodsId", value = "商品id") @RequestParam(value = "goodsId") Long goodsId,
//            @ApiParam(required = true, name = "amount", value = "商品数量") @RequestParam(value = "amount") Integer amount,
//            @ApiParam(name = "payType", value = "支付类型 wei_qr:微信支付   qq_qr:QQ支付",required = false) @RequestParam(value = "payType") String payType,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            response = sfPayService.payOrder(userId, goodsId, amount, payType);
//
//
//        } catch (InfServerException ie) {
//            log.error("SF订单支付接口：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("SF订单支付接口：", e);
//            //response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            //response.setError("您的网络异常!!");
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.getMessage());
//        }
//        return response;
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "payOrderCallback", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "sf支付回调接口", position = 2, response = Response.class)
//    public String payOrderCallback(
//            @ApiParam(required = true, name = "status", value = "状态  0 : 等待  1 : 成功  2 : 失败") @RequestParam(value = "status") Integer status,
//            @ApiParam(required = true, name = "tranId", value = "交易号") @RequestParam(value = "tranId") String tranId,
//            @ApiParam(required = true, name = "orderId", value = "订单ID") @RequestParam(value = "orderId") String orderId,
//            @ApiParam(required = true, name = "signature", value = "验签") @RequestParam(value = "signature") String  signature,
//            @ApiParam(required = true, name = "amount", value = "金额(分)") @RequestParam(value = "amount") Long amount,
//
//            HttpServletRequest request) {
//        Response response = new Response();
//        JSONObject jsonObject = new JSONObject();
//        try {
//
//            String result = sfPayService.payOrderCallback(status,tranId,orderId,signature,amount);
//            return result;
//
//        } catch (InfServerException ie) {
//            log.error("ping++支付回调接口inf：", ie);
//            jsonObject.put("success","false");
//            return jsonObject.toString();
//        } catch (Exception e) {
//            log.error("ping++支付回调接口：", e);
//            jsonObject.put("success","false");
//            return jsonObject.toString();
//        }
//
//    }
//}
