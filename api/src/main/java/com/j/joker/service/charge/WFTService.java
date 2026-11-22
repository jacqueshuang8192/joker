package com.j.joker.service.charge;

import com.j.joker.core.util.ConfigUtil;
import com.j.joker.constants.Constants;
import com.j.joker.mapper.TAccountChargeMapper;
import com.j.joker.model.TAccountCharge;
import com.j.joker.model.TGoods;
import com.j.joker.service.common.GoodsService;
import com.j.joker.utils.CommonUtil;
import com.j.joker.utils.InfServerException;
import com.j.joker.utils.SignUtils;
import com.j.joker.utils.XmlUtils;


import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.apache.log4j.Logger;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.SortedMap;

/**
 * Created by dzesla on 2017/2/15.
 */

@Service
public class WFTService extends BaseChargeService{
    private static final Logger rechargeLog = Logger.getLogger("Recharge");

    @Autowired
    private GoodsService goodsService;
    @Autowired
    private TAccountChargeMapper accountChargeMapper;
    private SimpleDateFormat dateFormat=new SimpleDateFormat("yyyy-MM-dd hh:mm:ssddd");

    public String payOrder(Long userId, Long goodsId, Integer amount, String payType,HttpServletRequest req,HttpServletResponse resp) throws Exception{
    	System.out.println("支付用的是WFT");
    	req.setCharacterEncoding("utf-8");
    	resp.setCharacterEncoding("utf-8");
    	TGoods goods = goodsService.findGoodsById(goodsId);
        String goodsName = goods.getName();
        Integer totalFees = goods.getPrice() * amount;
        String totalFee = totalFees.toString();
        String mchId = ConfigUtil.get("WFT.mchId");
        String apiKey = ConfigUtil.get("WFT.apiKey");
        String appid = ConfigUtil.get("WFT.appid");
        String reqUrl = ConfigUtil.get("WFT.reqUrl");
        Map<String, Object> chargeParams = new HashMap<String, Object>();
        Map<String, String> app = new HashMap<String, String>();
        Map<String, String> extra = new HashMap<String, String>();
        String callbackUrl = ConfigUtil.get("WTF.callback", "http://112.74.132.133:8080/hbi_interface/WFT/payOrderCallback");
        Map<String, String> params = new HashMap<String, String>();
        params.put("body", goodsName); // 商品名称
        params.put("service", "unified.trade.pay"); // 支付类型
        params.put("version", "2.0"); // 版本
        params.put("mch_id", mchId); // 威富通商户号
        //        params.put("mch_id", mchId.getText().toString()); // 威富通商户号
        params.put("notify_url",callbackUrl); // 后台通知url
        params.put("nonce_str", genNonceStr()); // 随机数money, body, mchId, notifyUrl, orderNo, signKey, appId, seller_id, credit_pay;
//        String out_trade_no = genOutTradNo();
        String out_trade_no = CommonUtil.dateFormat(new Date(), "yyyyMMddHHmmss");
        params.put("out_trade_no", out_trade_no); //订单号
        params.put("sub_appid",appid ); //
        params.put("mch_create_ip", "127.0.0.1"); // 机器ip地址
        params.put("total_fee", totalFee); // 总金额
        String sign = createSign(apiKey, params); // 9d101c97133837e13dde2d32a5054abb 威富通密钥
        
        params.put("sign", sign); // sign签名
        
        
            
            
       
        System.out.println("reqUrl：" + reqUrl);
        
        System.out.println("reqParams:" + XmlUtils.toXml(params));
        CloseableHttpResponse response = null;
        CloseableHttpClient client = null;
        String res = null;
        try {
            HttpPost httpPost = new HttpPost(reqUrl);
            StringEntity entityParams = new StringEntity(XmlUtils.toXml(params),"utf-8");
            httpPost.setEntity(entityParams);
            //httpPost.setHeader("Content-Type", "text/xml;charset=ISO-8859-1");
            client = HttpClients.createDefault();
            response = client.execute(httpPost);
            if(response != null && response.getEntity() != null){
                Map<String,String> resultMap = XmlUtils.toMap(EntityUtils.toByteArray(response.getEntity()), "utf-8");
                res = XmlUtils.toXml(resultMap);
                System.out.println("请求结果：" + res);
                
                if(resultMap.containsKey("sign")){
                    if(!SignUtils.checkParam(resultMap, apiKey)){
                        res = "验证签名不通过";
                    }else{
                        if("0".equals(resultMap.get("status")) && "0".equals(resultMap.get("result_code"))){
                            
                            
                            String token_id = resultMap.get("token_id");
                            String services = resultMap.get("services");
                            
                        }else{
                            
                        }
                    }
                } 
            }else{
                res = "操作失败";
            }
        } catch (Exception e) {
            e.printStackTrace();
            res = "系统异常";
        } finally {
            if(response != null){
                response.close();
            }
            if(client != null){
                client.close();
            }
        }
        
        
        
        
        TAccountCharge accountCharge = new TAccountCharge();
        accountCharge.setUserId(userId);
        accountCharge.setRmbAmount(goods.getPrice() * amount);
        accountCharge.setCreateDate(new Date());
        accountCharge.setStatus(Constants.PAY_TO_BE_CONFIRMED);
        accountCharge.setChargeOrder(out_trade_no);
        accountCharge.setGoodsId(goodsId);
        accountCharge.setNumber(amount);
        accountChargeMapper.insert(accountCharge);
        return XmlUtils.toXml(params);
    }
    
    public String createSign(String signKey, Map<String, String> params)
    {
        StringBuilder buf = new StringBuilder((params.size() + 1) * 10);
        SignUtils.buildPayParams(buf, params, false);
        buf.append("&key=").append(signKey);
        String preStr = buf.toString();
        String sign = "";
        // 获得签名验证结果
//        try
//        {
//            sign = MD5.md5s(preStr).toUpperCase();
//        }
//        catch (Exception e)
//        {
//            sign = MD5.md5s(preStr).toUpperCase();
//        }
        return sign;
    }
    private String genNonceStr()
    {
        Random random = new Random();
//        return MD5.getMessageDigest(String.valueOf(random.nextInt(10000)).getBytes());
        return "";
    }

    
    public void buildPayParams(StringBuilder sb, Map<String, String> payParams, boolean encoding)
    {
        List<String> keys = new ArrayList<String>(payParams.keySet());
        Collections.sort(keys);
        for (String key : keys)
        {
            sb.append(key).append("=");
            if (encoding)
            {
                sb.append(urlEncode(payParams.get(key)));
            }
            else
            {
                sb.append(payParams.get(key));
            }
            sb.append("&");
        }
        sb.setLength(sb.length() - 1);
    }
    
    public String urlEncode(String str)
    {
        try
        {
            return URLEncoder.encode(str, "UTF-8");
        }
        catch (Throwable e)
        {
            return str;
        }
    }
    public void payOrderCallback(HttpServletRequest request) throws Exception {
    	request.setCharacterEncoding("utf-8");
    	String resString = XmlUtils.parseRequst(request);
    	System.out.println("通知内容：" + resString); 
    	 String apiKey = ConfigUtil.get("WFT.apiKey");
    	
    	if(resString != null && !"".equals(resString)){
            Map<String,String> map = XmlUtils.toMap(resString.getBytes(), "utf-8");
            String res = XmlUtils.toXml(map);
            System.out.println("通知内容：" + res);
            if(map.containsKey("sign")){
                if(!SignUtils.checkParam(map, apiKey)){
                	throw new InfServerException(Constants.SYSTEM_ERROR, "验证签名不通过");                	
                }else{
                    String status = map.get("status");
                    if(status != null && "0".equals(status)){
                        String result_code = map.get("result_code");
                        if(result_code != null && "0".equals(result_code)){
                           //此处可以在添加相关处理业务，校验通知参数中的商户订单号out_trade_no和金额total_fee是否和商户业务系统的单号和金额是否一致，一致后方可更新数据库表中的记录。 
                            String orderId = map.get("out_trade_no");
                        	if (orderId != null) {
                        		payOrderCallbackTest(orderId);
                                rechargeLog.info("充值成功，chargeOrderId：" + orderId);
							}
                        } else {
                        	throw new InfServerException(Constants.SYSTEM_ERROR, "支付失败");
						}
                    }else {
                    	throw new InfServerException(Constants.SYSTEM_ERROR, "支付失败");  
					} 
                    
                }
            }
            }
    	
        
        
        
    }

    private String InputStreamTOString(InputStream in) throws Exception{
        ByteArrayOutputStream outStream = new ByteArrayOutputStream();
        byte[] data = new byte[1024];
        int count = -1;
        while((count = in.read(data,0,1024)) != -1)
            outStream.write(data, 0, count);

        data = null;
        return new String(outStream.toByteArray(),"UTF-8");
    }
}
