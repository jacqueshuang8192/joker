package com.hbi.controller.charge;

import com.alibaba.fastjson.JSON;
import com.core.util.ConfigUtil;
import com.core.util.StringUtil;
import com.hbi.constants.Constants;
import com.hbi.service.charge.PayBy980Service;
import com.hbi.utils.InfServerException;
import com.hbi.utils.XMLUtil;
import com.hbi.utils.XmlUtils;
import com.hbi.vo.response.Response;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.Parameter;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedInputStream;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.*;

@Tag(name = "sf支付接口")
@RequestMapping(value = "/sfPay")
@Controller
public class  PayBy980Controller {

    private static final Logger log = Logger.getLogger(PayBy980Controller.class);

    @Autowired
    private PayBy980Service payBy980Service;

    @ResponseBody
    @RequestMapping(value = "/payOrder", method = { RequestMethod.POST, RequestMethod.GET})
//    @Operation(summary = "sf订单支付接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public ModelAndView payOrder(
            @Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") Long userId,
            @Parameter(required = true, name = "goodsId", description = "商品id") @RequestParam(value = "goodsId") Long goodsId,
            @Parameter(required = true, name = "amount", description = "商品数量") @RequestParam(value = "amount") Integer amount,
            @Parameter(name = "payType", description = "支付类型 wei_qr:微信支付   qq_qr:QQ支付", required = false) @RequestParam(value = "payType") String payType,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request,Model model) {
        Response response = new Response();
        ModelAndView modelAndView = null;
        try {

            Map<String,String> map = payBy980Service.payOrder(userId, goodsId, amount, payType);

            System.out.println(map);


            Iterator<Map.Entry<String, String>> entries = map.entrySet().iterator();

            while (entries.hasNext()) {
                Map.Entry<String, String> entry = entries.next();
                model.addAttribute(entry.getKey(),entry.getValue());
            }
            modelAndView = new ModelAndView();
            modelAndView.setViewName("payOrder");
            return modelAndView;

        } catch (InfServerException ie) {
            log.error("980订单支付接口：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            log.error("980订单支付接口：", e);
            //response.setReturnCode(Constants.RETURN_CODE_FAIL);
            //response.setError("您的网络异常!!");
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.getMessage());
        }
        return modelAndView;
    }

    @ResponseBody
    @RequestMapping(value = "payOrderCallback", method = { RequestMethod.GET }, produces = "application/json; charset=utf-8")
    @Operation(summary = "sf支付回调接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String payOrderCallback(
            @Parameter(required = false, name = "memberid", description = "商户Id") @RequestParam(required = false,value = "memberid") String memberid,
            @Parameter(required = false, name = "orderid", description = "orderid") @RequestParam(required = false,value = "orderid") String orderid,
            @Parameter(required = false, name = "amount", description = "amount") @RequestParam(required = false,value = "amount") Long amount,
            @Parameter(required = false, name = "datetime", description = "datetime") @RequestParam(required = false,value = "datetime") String datetime,
            @Parameter(required = false, name = "returncode", description = "returncode") @RequestParam(required = false,value = "returncode") String returncode,
            @Parameter(required = false, name = "sign", description = "sign") @RequestParam(required = false,value = "sign") String sign,


            HttpServletRequest request) {
        try {

            String result = payBy980Service.payOrderCallback(memberid,orderid,datetime,returncode,amount,sign);
            return result;

        } catch (InfServerException ie) {
            log.error("980支付回调接口inf：", ie);
            return "false";
        } catch (Exception e) {
            log.error("980支付回调接口：", e);
            return "false";
        }

    }



    //多个支付的渠道
    @ResponseBody
    @RequestMapping(value = "/rongZhouPayOrder", method = { RequestMethod.POST, RequestMethod.GET})
    @Operation(summary = "荣舟订单支付接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public ModelAndView rongZhouPayOrder(
            @Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") Long userId,
            @Parameter(required = true, name = "goodsId", description = "商品id") @RequestParam(value = "goodsId") Long goodsId,
            @Parameter(required = true, name = "amount", description = "商品数量") @RequestParam(value = "amount") Integer amount,
            @Parameter(name = "payType", description = "W : 微信支付 ， Z ： 支付宝支付 ， Y ： 银联支付", required = false) @RequestParam(value = "payType") String payType,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request,Model model) {
        Response response = new Response();
        ModelAndView modelAndView = null;
        try {

            Map<String,String> map = null;
            String payChannel = ConfigUtil.get("payChannel");

            if ("qilin".equals(payChannel)) {
                map = payBy980Service.qilinPayOrder(userId, goodsId, amount, payType);
                Iterator<Map.Entry<String, String>> entries = map.entrySet().iterator();
                while (entries.hasNext()) {
                    Map.Entry<String, String> entry = entries.next();
                    model.addAttribute(entry.getKey(),entry.getValue());
                }
                modelAndView = new ModelAndView();
                modelAndView.setViewName("qilin");
                return modelAndView;
            }

            if ("shanyun".equalsIgnoreCase(payChannel)) {
                String s = payBy980Service.shanyunPayOrder(userId, goodsId, amount, payType);

                model.addAttribute("input",s);
                String s1 = ConfigUtil.get("shanyun.postUrl");
                model.addAttribute("url",s1);
                modelAndView = new ModelAndView();
                modelAndView.setViewName("shanyun");
                return modelAndView;
            }

            if ("mazhifu".equalsIgnoreCase(payChannel)) {
                map = payBy980Service.maZhiFuPayOrder(userId, goodsId, amount, payType);
                Iterator<Map.Entry<String, String>> entries = map.entrySet().iterator();
                while (entries.hasNext()) {
                    Map.Entry<String, String> entry = entries.next();
                    model.addAttribute(entry.getKey(),entry.getValue());
                }
                modelAndView = new ModelAndView();
                modelAndView.setViewName("mazhifu");
                return modelAndView;
            }

            if ("junfutong".equalsIgnoreCase(payChannel)) {
               map = payBy980Service.junfutongPayOrder(userId, goodsId, amount, payType);
                Iterator<Map.Entry<String, String>> entries = map.entrySet().iterator();
                while (entries.hasNext()) {
                    Map.Entry<String, String> entry = entries.next();
                    model.addAttribute(entry.getKey(),entry.getValue());
                }
                modelAndView = new ModelAndView();
                if ("Z".equals(payType)) {
                    modelAndView.setViewName("rongZhouPayOrder2");
                }else {
                    modelAndView.setViewName("rongZhouPayOrder");
                }
                return modelAndView;
            }

            return null;

        } catch (InfServerException ie) {
            log.error("980订单支付接口：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            log.error("980订单支付接口：", e);
            //response.setReturnCode(Constants.RETURN_CODE_FAIL);
            //response.setError("您的网络异常!!");
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.getMessage());
        }
//        return JSON.toJSONString(response);
        return modelAndView;
    }




    @ResponseBody
    @RequestMapping(value = "/biqiPayOrder", method = { RequestMethod.POST, RequestMethod.GET})
    @Operation(summary = "比奇订单支付接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String biqiPayOrder(
            @Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") Long userId,
            @Parameter(required = true, name = "goodsId", description = "商品id") @RequestParam(value = "goodsId") Long goodsId,
            @Parameter(required = true, name = "amount", description = "商品数量") @RequestParam(value = "amount") Integer amount,
            @Parameter(name = "payType", description = "W : 微信支付 ， Z ： 支付宝支付 ， Y ： 银联支付", required = false) @RequestParam(value = "payType") String payType,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request,Model model) {
        Response response = null;
//        ModelAndView modelAndView = null;
        try {

            response = payBy980Service.payOrderNiu(userId, goodsId, amount, payType);
            return JSON.toJSONString(response);
//            System.out.println(map);

//            Iterator<Map.Entry<String, String>> entries = map.entrySet().iterator();
//            while (entries.hasNext()) {
//                Map.Entry<String, String> entry = entries.next();
//                model.addAttribute(entry.getKey(),entry.getValue());
//            }
//            return null;
//            modelAndView = new ModelAndView();
//            modelAndView.setViewName("biqiPayOrder");
//            return modelAndView;

        } catch (InfServerException ie) {
            log.error("比奇订单支付接口：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            log.error("比奇订单支付接口：", e);
            //response.setReturnCode(Constants.RETURN_CODE_FAIL);
            //response.setError("您的网络异常!!");
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.getMessage());
        }
        return JSON.toJSONString(response);
    }

    @ResponseBody
    @RequestMapping(value = "/payOrderCallbackBiQi", method = { RequestMethod.POST, RequestMethod.GET})
    @Operation(summary = "比奇支付回调", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String payOrderCallbackBiQi(HttpServletRequest request,
                                       HttpServletResponse response) throws Exception {

        String s = "false";

        try {
            return payBy980Service.payOrderCallbackBiQi(request, response);
        } catch (InfServerException ie) {
            log.error("比奇订单支付接口：", ie);
        } catch (Exception e) {
            System.out.println(e.getMessage());
            log.error("比奇订单支付接口：", e);
        }
        return "false";
    }




    @ResponseBody
    @RequestMapping(value = "payOrderCallbackRongZhou", method = { RequestMethod.GET }, produces = "application/json; charset=utf-8")
    @Operation(summary = "比奇支付回调接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String payOrderCallbackRongZhou(
            @Parameter(required = false, name = "orderid", description = "orderid") @RequestParam(required = false,value = "orderid") String orderid,
            @Parameter(required = false, name = "ovalue", description = "ovalue") @RequestParam(required = false,value = "ovalue") String ovalue,
            @Parameter(required = false, name = "completiontime", description = "completiontime") @RequestParam(required = false,value = "completiontime") String completiontime,
            @Parameter(required = false, name = "opstate", description = "opstate") @RequestParam(required = false,value = "opstate") String opstate,
            @Parameter(required = false, name = "sign", description = "sign") @RequestParam(required = false,value = "sign") String sign,
            @Parameter(required = false, name = "attach", description = "attach") @RequestParam(required = false,value = "attach") String attach,
            @Parameter(required = false, name = "msg", description = "msg") @RequestParam(required = false,value = "msg") String msg,

            HttpServletRequest request) {
        try {

            String result = payBy980Service.payOrderCallbackRongZhou(orderid,ovalue,completiontime,opstate,sign,attach,msg);
            return result;

        } catch (InfServerException ie) {
            log.error("980支付回调接口inf：", ie);
            return "false";
        } catch (Exception e) {
            log.error("980支付回调接口：", e);
            return "false";
        }

    }

    @ResponseBody
    @RequestMapping(value = "payOrderCallbackShanyun", method = { RequestMethod.POST }, produces = "application/json; charset=utf-8")
    @Operation(summary = "闪云支付回调接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public void payOrderCallbackShanyun(
            HttpServletRequest request,
            HttpServletResponse response) {
        try {

            request.setCharacterEncoding("UTF-8");
            Map<String, String[]> map = request.getParameterMap();

            boolean b = payBy980Service.payOrderCallbacShanyun(map);
            if (b) {
                response.getWriter().println("success");
            }else {
                response.getWriter().println("fail");
            }
        } catch (InfServerException ie) {
            log.error("闪云支付回调接口：", ie);
        } catch (Exception e) {
            log.error("闪云支付回调接口：", e);
        }

    }

    @ResponseBody
    @RequestMapping(value = "payOrderCallbackJFT", method = { RequestMethod.GET,RequestMethod.POST }, produces = "application/json; charset=utf-8")
    @Operation(summary = "竣付通回调接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String payOrderCallbackJFT(
            @Parameter(required = false, name = "p1_yingyongnum", description = "p1_yingyongnum") @RequestParam(required = false,value = "p1_yingyongnum") String p1_yingyongnum,
            @Parameter(required = false, name = "p2_ordernumber", description = "p2_ordernumber") @RequestParam(required = false,value = "p2_ordernumber") String p2_ordernumber,
            @Parameter(required = false, name = "p3_money", description = "p3_money") @RequestParam(required = false,value = "p3_money") String p3_money,
            @Parameter(required = false, name = "p4_zfstate", description = "p4_zfstate") @RequestParam(required = false,value = "p4_zfstate") String p4_zfstate,
            @Parameter(required = false, name = "p5_orderid", description = "p5_orderid") @RequestParam(required = false,value = "p5_orderid") String p5_orderid,
            @Parameter(required = false, name = "p6_productcode", description = "p6_productcode") @RequestParam(required = false,value = "p6_productcode") String p6_productcode,
            @Parameter(required = false, name = "p10_sign", description = "p10_sign") @RequestParam(required = false,value = "p10_sign") String p10_sign,
            @Parameter(required = false, name = "p11_pdesc", description = "p11_pdesc") @RequestParam(required = false,value = "p11_pdesc") String p11_pdesc,
            @Parameter(required = false, name = "p12_remark", description = "p12_remark") @RequestParam(required = false,value = "p12_remark") String p12_remark,
            @Parameter(required = false, name = "p13_zfmoney", description = "p13_zfmoney") @RequestParam(required = false,value = "p13_zfmoney") String p13_zfmoney,

            HttpServletRequest request) {
        try {

            String result = payBy980Service.payOrderCallbackJFT(p1_yingyongnum,p2_ordernumber,p3_money,p4_zfstate,p5_orderid,p6_productcode,p10_sign,p11_pdesc,p12_remark,p13_zfmoney);
            return result;

        } catch (InfServerException ie) {
            log.error("980支付回调接口inf：", ie);
            return "false";
        } catch (Exception e) {
            log.error("980支付回调接口：", e);
            return "false";
        }

    }

    @ResponseBody
    @RequestMapping(value = "payOrderCallbackMZF", method = { RequestMethod.GET,RequestMethod.POST }, produces = "application/json; charset=utf-8")
    @Operation(summary = "码支付通回调接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String payOrderCallbackMZF(
            HttpServletRequest request) {
        try {

            String result = payBy980Service.payOrderCallbackMZF(request);
            return result;

        } catch (InfServerException ie) {
            log.error("980支付回调接口inf：", ie);
            return "false";
        } catch (Exception e) {
            log.error("980支付回调接口：", e);
            return "false";
        }

    }

    @ResponseBody
    @RequestMapping(value = "payOrderCallbackQilin", method = { RequestMethod.GET,RequestMethod.POST }, produces = "application/json; charset=utf-8")
    @Operation(summary = "麒麟支付回调接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String payOrderCallbackQilin(
            @Parameter(required = false, name = "paysapi_id", description = "paysapi_id") @RequestParam(required = false,value = "paysapi_id") String paysapi_id,
            @Parameter(required = false, name = "orderid", description = "orderid") @RequestParam(required = false,value = "orderid") String orderid,
            @Parameter(required = false, name = "price", description = "price") @RequestParam(required = false,value = "price") String price,
            @Parameter(required = false, name = "realprice", description = "realprice") @RequestParam(required = false,value = "realprice") String realprice,
            @Parameter(required = false, name = "orderuid", description = "orderuid") @RequestParam(required = false,value = "orderuid") String orderuid,
            @Parameter(required = false, name = "key", description = "key") @RequestParam(required = false,value = "key") String key,

            HttpServletRequest request) {
        try {

            String result = payBy980Service.payOrderCallbackQilin(paysapi_id,orderid,price,realprice,orderuid,key);
            return result;

        } catch (InfServerException ie) {
            log.error("980支付回调接口inf：", ie);
            return "false";
        } catch (Exception e) {
            log.error("980支付回调接口：", e);
            return "false";
        }

    }


}
