package com.hbi.service.charge;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.hbi.constants.Constants;
import com.hbi.mapper.TAccountChargeMapper;
import com.hbi.mapper.TGoodsMapper;

import com.hbi.mapper.TSecUserMapper;
import com.hbi.mapper.TUserMapper;
import com.hbi.model.TAccountCharge;
import com.hbi.model.TGoods;
import com.hbi.model.TSecUser;
import com.hbi.model.TUser;
import com.hbi.service.common.GoodsService;
import com.hbi.utils.CommonUtil;
import com.hbi.utils.InfServerException;
import com.hbi.utils.YeePayUtil;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Date;
import java.util.TreeMap;

/**
 * Created by dzesla on 2016/12/27.
 */

@Service
public class YeePayService extends BaseChargeService{

    private static final Log log = LogFactory.getLog(YeePayService.class);

    @Autowired
    private GoodsService goodsService;
    @Autowired
    private TAccountChargeMapper accountChargeMapper;

    public String payOrder(Long userId, Long goodsId, Integer amount, HttpServletRequest request) throws Exception{
        TGoods goods = goodsService.findGoodsById(goodsId);
        String ip = CommonUtil.getIpAddr(request);
        System.out.println("支付用的是Yee");

        String orderId = CommonUtil.generateOrderId(userId);

        System.out.println(orderId);

        System.out.println(ip);

        TreeMap dataMap = YeePayUtil.generateOrderPay(userId, orderId, goods.getPrice() * amount, goods.getName(),
                goods.getRemark(), ip);

        TreeMap resultMap = YeePayUtil.encryptAndSend(dataMap);

        if(resultMap.containsKey("error_code")) {
            log.error(resultMap);
            throw new InfServerException(Constants.RETURN_CODE_FAIL, resultMap.toString());
        }

        String resultStr = YeePayUtil.decrypt(resultMap);

        TAccountCharge accountCharge = new TAccountCharge();
        accountCharge.setUserId(userId);
        accountCharge.setRmbAmount(goods.getPrice() * amount);
        accountCharge.setCreateDate(new Date());
        accountCharge.setStatus(Constants.PAY_TO_BE_CONFIRMED);
        accountCharge.setChargeOrder(orderId);
        accountCharge.setGoodsId(goodsId);
        accountCharge.setNumber(amount);
        accountChargeMapper.insert(accountCharge);

        return JSON.parseObject(resultStr).getString("payurl");
    }

    public void payOrderCallback(String data, String encryptkey) throws Exception {
        String resultStr = YeePayUtil.decrypt(data, encryptkey);
        JSONObject obj = JSONObject.parseObject(resultStr);
        if (obj.getInteger("status") != 1 || StringUtils.isBlank(obj.getString("orderid"))) {
            log.error(obj);
            throw new InfServerException(Constants.RETURN_CODE_FAIL, obj.toString());
        }
        String orderId = obj.getString("orderid");
        payOrderCallbackTest(orderId);
    }
}
