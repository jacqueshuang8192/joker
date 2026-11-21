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
import com.wordnik.swagger.annotations.Api;
import com.wordnik.swagger.annotations.ApiOperation;
import com.wordnik.swagger.annotations.ApiParam;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedInputStream;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.*;

@Api(basePath = "", value = "sf支付接口", position = 1)
@RequestMapping(value = "/sfPay")
@Controller
public class  PayBy980Controller {

    private static final Logger log = Logger.getLogger(PayBy980Controller.class);

    @Autowired
    private PayBy980Service payBy980Service;

    @ResponseBody
    @RequestMapping(value = "/payOrder", method = { RequestMethod.POST, RequestMethod.GET})
//    @ApiOperation(value = "sf订单支付接口", position = 2, response = Response.class)
    public ModelAndView payOrder(
            @ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") Long userId,
            @ApiParam(required = true, name = "goodsId", value = "商品id") @RequestParam(value = "goodsId") Long goodsId,
            @ApiParam(required = true, name = "amount", value = "商品数量") @RequestParam(value = "amount") Integer amount,
            @ApiParam(name = "payType", value = "支付类型 wei_qr:微信支付   qq_qr:QQ支付",required = false) @RequestParam(value = "payType") String payType,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
    @ApiOperation(value = "sf支付回调接口", position = 2, response = Response.class)
    public String payOrderCallback(
            @ApiParam(required = false, name = "memberid", value = "商户Id") @RequestParam(required = false,value = "memberid") String memberid,
            @ApiParam(required = false, name = "orderid", value = "orderid") @RequestParam(required = false,value = "orderid") String orderid,
            @ApiParam(required = false, name = "amount", value = "amount") @RequestParam(required = false,value = "amount") Long amount,
            @ApiParam(required = false, name = "datetime", value = "datetime") @RequestParam(required = false,value = "datetime") String datetime,
            @ApiParam(required = false, name = "returncode", value = "returncode") @RequestParam(required = false,value = "returncode") String returncode,
            @ApiParam(required = false, name = "sign", value = "sign") @RequestParam(required = false,value = "sign") String sign,


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
    @ApiOperation(value = "荣舟订单支付接口", position = 2, response = Response.class)
    public ModelAndView rongZhouPayOrder(
            @ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") Long userId,
            @ApiParam(required = true, name = "goodsId", value = "商品id") @RequestParam(value = "goodsId") Long goodsId,
            @ApiParam(required = true, name = "amount", value = "商品数量") @RequestParam(value = "amount") Integer amount,
            @ApiParam(name = "payType", value = "W : 微信支付 ， Z ： 支付宝支付 ， Y ： 银联支付",required = false) @RequestParam(value = "payType") String payType,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
    @ApiOperation(value = "比奇订单支付接口", position = 2, response = Response.class)
    public String biqiPayOrder(
            @ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") Long userId,
            @ApiParam(required = true, name = "goodsId", value = "商品id") @RequestParam(value = "goodsId") Long goodsId,
            @ApiParam(required = true, name = "amount", value = "商品数量") @RequestParam(value = "amount") Integer amount,
            @ApiParam(name = "payType", value = "W : 微信支付 ， Z ： 支付宝支付 ， Y ： 银联支付",required = false) @RequestParam(value = "payType") String payType,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
    @ApiOperation(value = "比奇支付回调", position = 2, response = Response.class)
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
    @ApiOperation(value = "比奇支付回调接口", position = 2, response = Response.class)
    public String payOrderCallbackRongZhou(
            @ApiParam(required = false, name = "orderid", value = "orderid") @RequestParam(required = false,value = "orderid") String orderid,
            @ApiParam(required = false, name = "ovalue", value = "ovalue") @RequestParam(required = false,value = "ovalue") String ovalue,
            @ApiParam(required = false, name = "completiontime", value = "completiontime") @RequestParam(required = false,value = "completiontime") String completiontime,
            @ApiParam(required = false, name = "opstate", value = "opstate") @RequestParam(required = false,value = "opstate") String opstate,
            @ApiParam(required = false, name = "sign", value = "sign") @RequestParam(required = false,value = "sign") String sign,
            @ApiParam(required = false, name = "attach", value = "attach") @RequestParam(required = false,value = "attach") String attach,
            @ApiParam(required = false, name = "msg", value = "msg") @RequestParam(required = false,value = "msg") String msg,

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
    @ApiOperation(value = "闪云支付回调接口", position = 2, response = Response.class)
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
    @ApiOperation(value = "竣付通回调接口", position = 2, response = Response.class)
    public String payOrderCallbackJFT(
            @ApiParam(required = false, name = "p1_yingyongnum", value = "p1_yingyongnum") @RequestParam(required = false,value = "p1_yingyongnum") String p1_yingyongnum,
            @ApiParam(required = false, name = "p2_ordernumber", value = "p2_ordernumber") @RequestParam(required = false,value = "p2_ordernumber") String p2_ordernumber,
            @ApiParam(required = false, name = "p3_money", value = "p3_money") @RequestParam(required = false,value = "p3_money") String p3_money,
            @ApiParam(required = false, name = "p4_zfstate", value = "p4_zfstate") @RequestParam(required = false,value = "p4_zfstate") String p4_zfstate,
            @ApiParam(required = false, name = "p5_orderid", value = "p5_orderid") @RequestParam(required = false,value = "p5_orderid") String p5_orderid,
            @ApiParam(required = false, name = "p6_productcode", value = "p6_productcode") @RequestParam(required = false,value = "p6_productcode") String p6_productcode,
            @ApiParam(required = false, name = "p10_sign", value = "p10_sign") @RequestParam(required = false,value = "p10_sign") String p10_sign,
            @ApiParam(required = false, name = "p11_pdesc", value = "p11_pdesc") @RequestParam(required = false,value = "p11_pdesc") String p11_pdesc,
            @ApiParam(required = false, name = "p12_remark", value = "p12_remark") @RequestParam(required = false,value = "p12_remark") String p12_remark,
            @ApiParam(required = false, name = "p13_zfmoney", value = "p13_zfmoney") @RequestParam(required = false,value = "p13_zfmoney") String p13_zfmoney,

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
    @ApiOperation(value = "码支付通回调接口", position = 2, response = Response.class)
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
    @ApiOperation(value = "麒麟支付回调接口", position = 2, response = Response.class)
    public String payOrderCallbackQilin(
            @ApiParam(required = false, name = "paysapi_id", value = "paysapi_id") @RequestParam(required = false,value = "paysapi_id") String paysapi_id,
            @ApiParam(required = false, name = "orderid", value = "orderid") @RequestParam(required = false,value = "orderid") String orderid,
            @ApiParam(required = false, name = "price", value = "price") @RequestParam(required = false,value = "price") String price,
            @ApiParam(required = false, name = "realprice", value = "realprice") @RequestParam(required = false,value = "realprice") String realprice,
            @ApiParam(required = false, name = "orderuid", value = "orderuid") @RequestParam(required = false,value = "orderuid") String orderuid,
            @ApiParam(required = false, name = "key", value = "key") @RequestParam(required = false,value = "key") String key,

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
