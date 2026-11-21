//package com.hbi.controller.common;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.hbi.constants.Constants;
//import com.hbi.service.common.AccountChargeService;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.hbi.vo.response.base.BaseResultVo;
//import com.pingplusplus.model.Charge;
//import com.pingplusplus.model.Event;
//import com.wordnik.swagger.annotations.ApiOperation;
//import org.apache.commons.collections.MapUtils;
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Controller;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RequestMethod;
//import org.springframework.web.bind.annotation.ResponseBody;
//
//import javax.servlet.http.HttpServletRequest;
//import java.io.ByteArrayOutputStream;
//import java.io.InputStream;
//import java.util.Map;
//
///**
// * Created by ceeuoo on 8/18/2016.
// */
//@Controller
//public class ChargeController {
//    private static final Log log = LogFactory.getLog(ChargeController.class);
//    private static final Log rechargeLog = LogFactory.getLog("Recharge");
//
////    @Autowired
////    private AccountChargeService accountChargeService;
//
////    @ResponseBody
////    @RequestMapping(value = "game/receiveGameCharge", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "游戏Ping++充值回调", httpMethod = "POST", position = 1, response = BaseResultVo.class)
////    public String receivePlayerCharge(HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            String req = InputStreamTOString(request.getInputStream());
////            Event event = JSON.toJavaObject(JSON.parseObject(req), Event.class);
////            rechargeLog.info(req);
////            if (event != null) {
////                Map<String, Object> chargeMaps = event.getData();
////                if (chargeMaps == null) {
////                    rechargeLog.info("chargeMaps is null");
////                }
////                if (MapUtils.isNotEmpty(chargeMaps)) {
////                    JSONObject obj = (JSONObject) chargeMaps.get("object");
////                    Charge charge = JSON.toJavaObject(obj, Charge.class);
////                    //判断是否支付成功
////                    boolean paid = charge.getPaid();
////                    String chargeOrderId = charge.getId();
////                    if (paid) {
////                        accountChargeService.updateGameCharge(chargeOrderId);
////                        response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////                        rechargeLog.info("充值成功，chargeOrderId：" + chargeOrderId);
////                        return JSON.toJSONString(response);
////                    } else {
////                        throw new InfServerException(Constants.SYSTEM_ERROR, "Ping++支付失败");
////                    }
////                } else {
////                    throw new InfServerException(Constants.SYSTEM_ERROR, "Ping++回写结果为空");
////                }
////            } else {
////                throw new InfServerException(Constants.SYSTEM_ERROR, "Ping++回写结果为空");
////            }
////
////        } catch (Exception e) {
////            log.error("Ping++充值回调：", e);
////            CommonUtil.BuildErrorResponse(e, response);
////            return JSON.toJSONString(response);
////        }
////    }
//
//    private String InputStreamTOString(InputStream in) throws Exception{
//
//        ByteArrayOutputStream outStream = new ByteArrayOutputStream();
//        byte[] data = new byte[1024];
//        int count = -1;
//        while((count = in.read(data,0,1024)) != -1)
//            outStream.write(data, 0, count);
//
//        data = null;
//        return new String(outStream.toByteArray(),"UTF-8");
//    }
//}
