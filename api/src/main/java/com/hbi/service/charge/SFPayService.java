package com.hbi.service.charge;

import com.core.rfUtil.Md5;
import com.core.util.ConfigUtil;
import com.hbi.constants.Constants;
import com.hbi.controller.charge.URL;
import com.hbi.mapper.ImsTpOrdersMapper;
import com.hbi.mapper.TAccountChargeMapper;
import com.hbi.mapper.TUserMapper;
import com.hbi.model.ImsGoods;
import com.hbi.model.ImsTpOrders;
import com.hbi.model.TUser;
import com.hbi.service.charge.sfHttp.HttpHelper;
import com.hbi.service.charge.sfHttp.HttpMethodType;
import com.hbi.service.common.GoodsService;
import com.hbi.utils.InfServerException;
import com.hbi.vo.response.Response;
import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by muzi on 2017/12/15.
 */
@Service
public class SFPayService extends BaseChargeService{

    private static Logger logger = Logger.getLogger(SFPayService.class);
    @Autowired
    private GoodsService goodsService;
    @Autowired
    private TAccountChargeMapper accountChargeMapper;
    @Autowired
    private TUserMapper userMapper;
    @Autowired
    private ImsTpOrdersMapper imsTpOrdersMapper;



    public Response payOrder(Long userId, Long goodsId, Integer amount, String payType) throws Exception{
        Response response = new Response();
        ImsGoods goods = goodsService.findImsGoodsById(goodsId);
        System.out.println("支付用的是sf++");
        int payAmount = goods.getPrice() * amount;


        String curr =  userId + "-" + System.currentTimeMillis() / 1000;
        JSONObject json = new JSONObject();
        json.put("orderId", curr);
        json.put("amount", payAmount);

        json.put("returnUrl", "");
        String categoryType = goods.getCategoryType();
        if ("0".equals(categoryType)) {
            json.put("body", "购买"+goods.getAmount()*amount+"张房卡");
        }else if("1".equals(categoryType)) {
            json.put("body", "购买"+goods.getAmount()*amount+"个房卡");
        }else {
            json.put("body","欢迎光临!!");
        }
        json.put("merchantCode", URL.myKey);
        json.put("version", URL.version);
        json.put("notifyUrl", URL.returnUrl);

        JSONObject res = request(URL.down_order, json);
         System.out.println("下单返回结果："+res);
        //下单返回结果：{"tranId":"5c186836-e3b7-4ce9-b6fe-33699d0b2b79","success":true,"msg":"下单成功","orderId":"test20160725000005"}
        //下单返回结果：{"success":false,"msg":"订单号重复"}

        //以下二选一
        //支付【跳转支付】
//        String url = getLink(res.getString("tranId"));
//        System.err.println("支付链接：" + url);
        //支付【获取支付二维码】
        System.out.println(res.toString() + "--------");
        String imgCode = getCode(res.getString("tranId"),payType);
        System.err.println("支付二维码：" + imgCode);
        response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        response.setData(ConfigUtil.get("sf.pay.Id") + imgCode);




        if (StringUtils.isNotBlank(imgCode)){
            //if ("1".equals(goods.getCategoryType())) {
            //    //如果是1 ,则是房卡的,沿用以前的交易表记录, 如果是0,则是房卡,用到新的一套去
            //    TAccountCharge accountCharge = new TAccountCharge();
            //    accountCharge.setUserId(userId);
            //    accountCharge.setRmbAmount(goods.getPrice() * amount);
            //    accountCharge.setCreateDate(new Date());
            //    accountCharge.setStatus(Constants.PAY_TO_BE_CONFIRMED);
            //    accountCharge.setChargeOrder(curr);
            //    accountCharge.setGoodsId(goodsId);
            //    accountCharge.setNumber(amount);
            //    TUser tUser = userMapper.selectByPrimaryKey(userId);
            //    if (tUser.getAgentId() != null) {
            //        accountCharge.setAgentId(tUser.getAgentId());
            //    }
            //    accountChargeMapper.insert(accountCharge);
            //}else {
                ImsTpOrders imsTpOrders = new ImsTpOrders();
                imsTpOrders.setPlayerId(Integer.parseInt(userId.toString()));
                imsTpOrders.setPrice(goods.getPrice()*amount/100D);
                imsTpOrders.setCreateAt(Long.toString(System.currentTimeMillis()/1000));
                Calendar cal = Calendar.getInstance();
                int year = cal.get(Calendar.YEAR);
                int month = cal.get(Calendar.MONTH )+1;

                imsTpOrders.setYear(year);
                imsTpOrders.setMonth(month);
                imsTpOrders.setType(1);
                imsTpOrders.setUserId(0);
                imsTpOrders.setGoodType(Integer.parseInt(goods.getCategoryType()));
                imsTpOrders.setThirdpartyOrderNum(res.getString("tranId"));

                imsTpOrders.setOrderstatus(Integer.parseInt(Constants.PAY_CANCEL));
                imsTpOrders.setOrderNo(curr);
                imsTpOrders.setGoodsId(Integer.parseInt(goodsId.toString()));
                imsTpOrders.setCount(amount);
                TUser tUser = userMapper.selectByPrimaryKey(userId);
                if (tUser.getAgentId() != null) {
                    imsTpOrders.setParentId(Integer.parseInt(tUser.getAgentId().toString()));
                }
                imsTpOrdersMapper.insert(imsTpOrders);
            //}

        } else {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"您的网络异常!!");
        }
        return response;
    }

    private static JSONObject request(String api, JSONObject json) {
        HttpHelper http = new HttpHelper();
        //业务参数加密
        Map<String, Object> map = new HashMap<String, Object>();
        String input = json.toString();
        String encoded = Base64.encodeBase64String(input.getBytes());

        //验签加密
        String newstr = input+URL.key;
        String return_newstr = Md5.getMd5ofStr(newstr);
        String return_bigstr = return_newstr.toUpperCase();
        //appid
        map.put("appid", URL.appid);
        map.put("params", encoded);
        map.put("signs", return_bigstr);
        System.err.println(URL.appid+","+encoded+","+return_bigstr);
        return http.getJSONFromHttp(api, map, HttpMethodType.POST);
    }
    public static String getCode(String tranId,String payType){
        JSONObject json = new JSONObject();
        json.put("version",URL.version);
        json.put("way",payType);

        json.put("tranId", tranId);

        String input = json.toString();
        String encoded = Base64.encodeBase64String(input.getBytes());

        //签名参数
        String newstr = input + URL.key;
        String return_newstr = Md5.getMd5ofStr(newstr);
        String return_bigstr = return_newstr.toUpperCase();

        //appid参数
        Map map = new HashMap();
        map.put("appid", URL.appid);
        map.put("params", encoded);
        map.put("signs", return_bigstr);
        String res = new HttpHelper().sendHttp(URL.get_code,map, HttpMethodType.GET);
        System.out.println(res);
        return new JSONObject(res).getString("codeUrl");
    }

    public String payOrderCallback(Integer status, String tranId, String orderId, String signature, Long amount) throws Exception {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject = new JSONObject();
            System.out.println("sf开始");

            System.out.println(status + "-" + tranId + "-" + orderId + "-" + signature + "-" + amount);

            if (status != 1) {
                jsonObject.put("success","false");
                return jsonObject.toString();
            }


            String sign = Md5.getMd5ofStr(status+orderId+tranId+amount+URL.key);
            if (!signature.equals(sign)) {
                //校验失败,直接返回错误
                jsonObject.put("success","false");
                return jsonObject.toString();
            }else {
                System.out.println("成功");
                //如果是房卡场,用会以前的操作
                payOrderCallbackTest2(orderId);

                logger.info("充值成功，chargeOrderId：" + orderId);
                System.out.println("充值成功，chargeOrderId：" + orderId);
                jsonObject.put("success","true");
                return jsonObject.toString();
            }

        } catch (Exception e) {
            throw e;
            //logger.info("充值失败：" + orderId + "xx" + e.getMessage());
            //jsonObject.put("success","false");
            //return jsonObject.toString();
        } finally {

        }


    }
}
