package com.hbi.utils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.TypeReference;
import com.core.constants.YTConstants;
import com.core.util.*;
import com.hbi.utils.yeepay.AES;
import com.hbi.utils.yeepay.HttpClient4Utils;
import com.hbi.utils.yeepay.RSA;

import java.util.*;

/**
 * Created by dzesla on 2016/12/26.
 */
public class YeePayUtil {
    private final String payUrl = "https://ok.yeepay.com/paymobile/payapi/request";

    private static final String callbackUrl = ConfigUtil.get("yeepay.callbackUrl");
    private static String account = ConfigUtil.get("yeepay.account");
    private static String yeepayPublicKey = ConfigUtil.get("yeepay.publicKey");
    private static String merchantPrivateKey = ConfigUtil.get("merchant.privateKey");

    /**
     * 生成支付订单
     * @param userId           用户ID
     * @param orderId          订单ID
     * @param amount           价格，单位：人民币分
     * @param productName      商品名称
     * @param productDesc      商品描述
     * @param userIp           用户IP
     * @return
     * @throws Exception
     */
    public static TreeMap generateOrderPay(Long userId, String orderId, Integer amount,
                                           String productName, String productDesc, String userIp) {
//        orderId = "PAYMOBILE161227_2000004";
//        transTime = 1482825184;
        Integer transTime = new Long(System.currentTimeMillis()/1000).intValue();
//        amount = 1;
        String productCatalog = "1";  //虚拟物品
//        productName = new String("一键支付-测试");
//        productDesc = new String("productdesc");
        Integer identityType = 2;
        String identityId = userId.toString();
        String terminalId = "44-45-53-54-00-00";
        Integer terminalType = 1;
//        userIp = "127.0.0.0";

        TreeMap<String, Object> dataMap = new TreeMap<String, Object>();
        dataMap.put("merchantaccount", account);
        dataMap.put("orderid", orderId);
        dataMap.put("transtime", transTime);
        dataMap.put("amount", amount);
        dataMap.put("productcatalog", productCatalog);
        dataMap.put("productname", productName);
        dataMap.put("productdesc", productDesc);
        dataMap.put("identitytype", identityType);
        dataMap.put("identityid", identityId);
        dataMap.put("terminalid", terminalId);
        dataMap.put("terminaltype", terminalType);
        dataMap.put("userip", userIp);
        dataMap.put("callbackurl", callbackUrl);
        dataMap.put("cardno", "");
        dataMap.put("currency", 156);
        dataMap.put("directpaytype", 0);
//        dataMap.put("fcallbackurl", "");
        dataMap.put("idcard", "");
        dataMap.put("idcardtype", "");
        dataMap.put("orderexpdate", 60);
        dataMap.put("owner", "");
        dataMap.put("paytool", "");
        dataMap.put("paytypes", "");
        dataMap.put("userua", "Mozilla/5.0");
        dataMap.put("version", 0);

        System.out.println(dataMap);
        Set keySet = dataMap.keySet();
        String total = "";
        for (Object o : keySet) {
            String k = (String)o;
            String value = dataMap.get(k).toString();
            total += value;
        }
        System.out.println(total);

        String sign = RSA.sign(total, merchantPrivateKey);
        System.out.println("sign:" + sign);
        dataMap.put("sign", sign);
        return dataMap;
    }

    public static void main(String[] strings) {
        try {
            String orderId = "PAYMOBILE161227_2000006";
            Integer amount = 1;
            String productName = new String("一键支付-测试");
            String productDesc = new String("productdesc");
            String userIp = "127.0.0.0";
            Long userId = 506L;

            TreeMap<String, Object> dataMap = generateOrderPay(userId, orderId, amount, productName,
                    productDesc, userIp);

            TreeMap result = encryptAndSend(dataMap);
            System.out.println(result);
            String decryptData = decrypt(result);
            System.out.println(decryptData);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static TreeMap<String, String> encryptAndSend(TreeMap dataMap) throws Exception {
        String jsonStr = JSON.toJSONString(dataMap);
//        System.out.println("jsonStr:" + jsonStr);
        String aesKey = RadomUtil.getCharAndNumr(16, YTConstants.RADOM_OUT_ALL);
//        System.out.println(aesKey);
        String data = AES.encryptToBase64(jsonStr, aesKey);
//        System.out.println("data:" + data);
        String encryptKey = RSA.encrypt(aesKey, yeepayPublicKey);
//        System.out.println("encryptKey:" + encryptKey);
        String url = "https://ok.yeepay.com/paymobile/payapi/request";
        return httpPost(url,account,data, encryptKey);
    }

    public static String decrypt(TreeMap result) throws Exception {
        String outData = (String)result.get("data");
        String outEnkey = (String) result.get("encryptkey");
        String yeepayAESKey = RSA.decrypt(outEnkey, merchantPrivateKey);
        System.out.println(yeepayAESKey);
        return AES.decryptFromBase64(outData, yeepayAESKey);
    }

    public static String decrypt(String data, String encryptkey) throws Exception {
        String yeepayAESKey = RSA.decrypt(encryptkey, merchantPrivateKey);
        System.out.println(yeepayAESKey);
        return AES.decryptFromBase64(data, yeepayAESKey);
    }

    public static TreeMap<String, String> httpPost(String url, String merchantaccount, String data, String encryptkey) {
        TreeMap<String, String> result      = null;

        //请求参数为如下三者：merchantaccount、data、enrcyptkey
        Map<String, String> paramMap    = new HashMap<String, String>();
        paramMap.put("data", data);
        paramMap.put("encryptkey", encryptkey);
        paramMap.put("merchantaccount", merchantaccount);

        String responseBody = HttpClient4Utils.sendHttpRequest(url, paramMap, "UTF-8", true);
        result              = JSON.parseObject(responseBody, new TypeReference<TreeMap<String, String>>() {});
        return result;
    }
}
