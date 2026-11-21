package com.hbi.service.charge;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.core.util.ConfigUtil;
import com.core.util.StringUtil;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.constants.Constants;
import com.hbi.mapper.ImsTpOrdersMapper;
import com.hbi.mapper.TAccountChargeMapper;
import com.hbi.mapper.TUserMapper;
import com.hbi.model.ImsGoods;
import com.hbi.model.ImsTpOrders;
import com.hbi.model.TBiqiCardId;
import com.hbi.model.TUser;
import com.hbi.service.Gold.GoldService;
import com.hbi.service.common.GoodsService;
import com.hbi.utils.CommonUtil;
import com.hbi.utils.InfServerException;
import com.hbi.vo.response.Response;
import com.pingplusplus.Pingpp;
import com.pingplusplus.model.Charge;
import com.pingplusplus.model.Event;
import org.apache.commons.collections.MapUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jakarta.servlet.http.HttpServletRequest;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;

/**
 * Created by dzesla on 2017/2/15.
 */

@Service
public class PingPPService extends BaseChargeService{
    private static final Logger rechargeLog = Logger.getLogger("Recharge");

    @Autowired
    private GoodsService goodsService;
    @Autowired
    private TAccountChargeMapper accountChargeMapper;
    @Autowired
    private TUserMapper userMapper;
    @Autowired
    private ImsTpOrdersMapper imsTpOrdersMapper;
    @Autowired
    private BaseChargeService baseChargeService;
    @Autowired
    private GoldService goldService;
    @Autowired
    private BaseCacheController baseCacheController;

    public Charge payOrder(Long userId, Long goodsId, Integer amount, String payType) throws Exception{
        //TGoods goods = goodsService.findGoodsById(goodsId);
        ImsGoods goods = goodsService.findImsGoodsById(goodsId);
        System.out.println("支付用的是P++");
        Integer payAmount = goods.getPrice() * amount;
        Pingpp.apiKey = ConfigUtil.get("pingpp.apiKey");
        Map<String, Object> chargeParams = new HashMap<String, Object>();
        Map<String, String> app = new HashMap<String, String>();
        Map<String, String> extra = new HashMap<String, String>();
        //回调方法不在
        //String callbackUrl = ConfigUtil.get("pingpp.callback", "192.168.1.104:8080/hbi_pc/html/result_success.html");

        chargeParams.put("order_no", CommonUtil.dateFormat(new Date(), "yyyyMMddHHmmss"));
        app.put("id", ConfigUtil.get("pingpp.appid"));
        chargeParams.put("app", app);
        String chargeChannel = null;

        switch (payType.toUpperCase().charAt(0)) {
            case 'P':
                chargeChannel = "alipay";
                break;
            case 'W':
                chargeChannel = "wx";
                break;
            case 'U':
                chargeChannel = "upacp";
                break;
            case 'B':
                chargeChannel = "bfb";
                break;
            case 'J':
                chargeChannel = "jdpay_wap";
                break;
            default:
                break;
        }

        chargeParams.put("amount", payAmount);
        chargeParams.put("channel", chargeChannel);
        chargeParams.put("currency", "cny");
        chargeParams.put("client_ip", "127.0.0.1");
        chargeParams.put("subject","充值");
        chargeParams.put("body", goods.getAmount());
        Charge charge = Charge.create(chargeParams);
        rechargeLog.info(charge);
        if (StringUtils.isBlank(charge.getFailureMsg())){
            //if ("1".equals(goods.getCategoryType())) {
            //    //如果是1 ,则是房卡的,沿用以前的交易表记录, 如果是0,则是房卡,用到新的一套去
            //    TAccountCharge accountCharge = new TAccountCharge();
            //    accountCharge.setUserId(userId);
            //    accountCharge.setRmbAmount(goods.getPrice() * amount);
            //    accountCharge.setCreateDate(new Date());
            //    accountCharge.setStatus(Constants.PAY_TO_BE_CONFIRMED);
            //    accountCharge.setChargeOrder(charge.getId());
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

                imsTpOrders.setOrderstatus(Integer.parseInt(Constants.PAY_CANCEL));
                imsTpOrders.setOrderNo(charge.getId());
                imsTpOrders.setGoodsId(Integer.parseInt(goodsId.toString()));
                imsTpOrders.setCount(amount);
                TUser tUser = userMapper.selectByPrimaryKey(userId);
                if (tUser.getAgentId() != null) {
                    imsTpOrders.setParentId(Integer.parseInt(tUser.getAgentId().toString()));
                }
                imsTpOrdersMapper.insert(imsTpOrders);
            //}

        } else {
            throw new InfServerException(Constants.SYSTEM_ERROR, charge.getFailureMsg());
        }
        return charge;
    }

    public void payOrderCallback(HttpServletRequest request) throws Exception {
        String req = InputStreamTOString(request.getInputStream());
        Event event = JSON.toJavaObject(JSON.parseObject(req), Event.class);
        rechargeLog.info(req);
        if (event != null) {
            Map<String, Object> chargeMaps = event.getData();
            if (chargeMaps == null) {
                rechargeLog.info("chargeMaps is null");
            }
            if (MapUtils.isNotEmpty(chargeMaps)) {
                JSONObject obj = (JSONObject) chargeMaps.get("object");
                Charge charge = JSON.toJavaObject(obj, Charge.class);
                //判断是否支付成功
                boolean paid = charge.getPaid();
                String chargeOrderId = charge.getId();
                //String substring = charge.getSubject().substring(0, 1);
                if (paid) {
                	System.out.println("成功");
                	//如果是房卡场,用会以前的操作  1
                    //if("1".equals(substring) ) {
                     //   payOrderCallbackTest(chargeOrderId);
                    //}else {
                        payOrderCallbackTest2(chargeOrderId);
                    //}

                    rechargeLog.info("充值成功，chargeOrderId：" + chargeOrderId);
                    System.out.println("充值成功，chargeOrderId：" + chargeOrderId);
                } else {
                    throw new InfServerException(Constants.SYSTEM_ERROR, "Ping++支付失败");
                }
            } else {
                throw new InfServerException(Constants.SYSTEM_ERROR, "Ping++回写结果为空");
            }
        } else {
            throw new InfServerException(Constants.SYSTEM_ERROR, "Ping++回写结果为空");
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

    public void testxxxxx(Integer userId, Integer count,String number) throws IOException {
        baseChargeService.playerGoldRecharge(1,Long.parseLong(userId.toString()),count);
    }

    public void reloadData(Long gold,Long card) throws Exception{
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            TUser tUser = new TUser();
            List<TUser> select = userMapper.select(tUser);


            if (StringUtil.isEmpty(gold)) {
                gold = 0L;
            }
            if (StringUtil.isEmpty(card)) {
                card = 0L;
            }

            int i = 0;
            for (TUser user : select) {
                Long goldCount = goldService.queryGoldCount(user.getUserid());
                if (goldCount > gold) {
                    baseChargeService.playerGoldRecharge(1,user.getUserid(),-(Integer.parseInt(goldCount.toString())-Integer.parseInt(gold+"")));
                }
                if (goldCount < gold ) {
                    baseChargeService.playerGoldRecharge(1,user.getUserid(),Integer.parseInt(gold+"")-Integer.parseInt(goldCount.toString()));
                }
                i++;
                if (i%100 == 0) {
                    Thread.sleep(20);
                }
            }
            userMapper.updateCardCount(card);

        }catch (Exception e) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"初始化错误!!");
        }finally {
            CacheManager.releaseCache(cache);
        }


    }

    public Response changeGold2BiqiCard(Long playerId, Long goodsId) {
        Response response = new Response();
        try {
            ImsGoods goods = goodsService.findImsGoodsById(goodsId);
            Long goldCount = goldService.queryGoldCount(playerId);
            if (goldCount < goods.getPrice()/100) {
                response.setReturnCode(Constants.RETURN_CODE_FAIL);
                response.setData("您好,您的钻石余额不足,请充值!!");
                return response;
            }

            Integer price = goods.getPrice()/100;
            TBiqiCardId bqc = userMapper.selectBiqiCard(price);
            if (StringUtil.isEmpty(bqc)) {
                response.setReturnCode(Constants.RETURN_CODE_FAIL);
                response.setData("您好,该商品已经售空,请等待!!");
                return response;
            }
            baseChargeService.playerGoldRecharge(1,playerId,-goods.getPrice()/100);
            userMapper.updateBiqiCard(playerId,bqc.getId(),goods.getPrice());
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("购买成功!!");
            return response;
        }catch (Exception e ) {
            System.out.println(e.getMessage());
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setData("网络异常,请稍后再试!!");
        }
        return response;
    }
}
