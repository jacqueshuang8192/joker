package com.j.joker.service.charge;

import com.alibaba.fastjson.JSONObject;
import com.j.joker.constants.Constants;
import com.j.joker.mapper.TAccountChargeMapper;
import com.j.joker.model.TAccountCharge;
import com.j.joker.model.TGoods;
import com.j.joker.service.common.GoodsService;
import com.j.joker.utils.InfServerException;
import com.j.joker.utils.XmlUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.Map;
import java.util.UUID;

/**
 * Created by dzesla on 2017/6/12.
 */
@Service
public class QiaoPayService extends BaseChargeService{
    private static Logger logger = Logger.getLogger(QiaoPayService.class);
    
    @Autowired
    private TAccountChargeMapper accountChargeMapper;
    @Autowired
    private GoodsService goodsService;

    public JSONObject qiaoPayOrder(Long userId, Long goodsId, Integer amount, String payType) {
    	System.out.println("支付用的是QIAO");
    	JSONObject result = new JSONObject();
        TGoods goods      = goodsService.findGoodsById(goodsId);
        String orderId    = UUID.randomUUID().toString().replaceAll("-", "");
        Integer rmbAmount = goods.getPrice() * amount;
        TAccountCharge accountCharge = new TAccountCharge();
        accountCharge.setUserId(userId);
        accountCharge.setRmbAmount(rmbAmount);
        accountCharge.setCreateDate(new Date());
        accountCharge.setStatus(Constants.PAY_TO_BE_CONFIRMED);
        accountCharge.setChargeOrder(orderId);
        accountCharge.setGoodsId(goodsId);
        accountCharge.setNumber(amount);
        accountCharge.setPayType(payType);
        accountChargeMapper.insert(accountCharge);
        result.put("orderId", orderId);
        result.put("payType", payType);
        result.put("rmbAmount", rmbAmount);
        return result;
    }

    public void payOrderCallback(String requestBody) throws Exception {
        if (StringUtils.isBlank(requestBody)) {
            return;
        }
        logger.info("乔支付回调内容：" + requestBody);
        Map<String, String> map = XmlUtils.toMap(requestBody.getBytes(), "utf-8");
        if (map.get("pay_result") == null || !map.get("pay_result").equals("0")) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "乔支付回调失败");
        }
        String orderId = map.get("out_trade_no");
        if (StringUtils.isBlank(orderId)) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "乔支付回调失败");
        }
        payOrderCallbackTest(orderId);
    }

}
