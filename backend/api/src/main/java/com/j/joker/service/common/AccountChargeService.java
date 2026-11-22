package com.j.joker.service.common;

import java.util.Date;
import java.util.List;
import java.util.Map;
import com.j.joker.mapper.*;
import com.j.joker.model.*;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.service.BaseService;
import com.j.joker.cache.CacheManager;
import com.j.joker.cache.ICache;
import com.j.joker.cache.controller.PlayerCacheController;
import com.j.joker.cache.model.CachePlayerProfile;
import com.j.joker.constants.Constants;
import com.j.joker.utils.GameServerUtil;
import com.j.joker.utils.InfServerException;
import com.mybatisflex.core.query.QueryWrapper;
import static com.mybatisflex.core.query.QueryMethods.column;

@Service
public class AccountChargeService extends BaseService<TAccountCharge> {

	@Autowired
	private TAccountChargeMapper accountChargeMapper;
	@Autowired
	private PlayerCacheController playerCacheController;
	@Autowired
	private TPlayerMapper playerMapper;
	
	/**
	 * 查询记录信息
	 * 
	 * @return
	 * @throws Exception 
	 */
	public List<TAccountCharge> findAccountChargeHistoryByConditions(Map<String, Object> params) throws Exception {
		QueryWrapper query = QueryWrapper.create();
		if (params.get("userId") != null) {
			query.and(column(TAccountCharge::getUserId).eq(params.get("userId")));
		}
		if (params.get("startDate") != null) {
			query.and(column(TAccountCharge::getChargeDate).ge(params.get("startDate")));
		}
		if (params.get("endDate") != null) {
			query.and(column(TAccountCharge::getChargeDate).le(params.get("endDate")));
		}
		query.and(column(TAccountCharge::getStatus).eq(Constants.PAY_SUCCESS));
		query.and(column(TAccountCharge::getCoinAmount).ne(-1));
		return accountChargeMapper.selectListByQuery(query);
	}
	
	/**
	 * 根据Ping++订单号更新平台充值记录状态
	 * @param chargeOrderId
	 * @param channelOrderId 
	 * @throws Exception
	 */
	public void updateAccountChargeByPingPPOrderId(String chargeOrderId, String channelOrderId) throws Exception {
		ICache cache = null;
		try {
			TAccountCharge ac = new TAccountCharge();
			ac.setChargeOrder(chargeOrderId);
			TAccountCharge accountCharge = null;
			List<TAccountCharge> accountCharges = accountChargeMapper.select(ac);
			if (CollectionUtils.isNotEmpty(accountCharges)) {
				accountCharge = accountCharges.get(0);
			}
			if (accountCharge != null) {
				Long userId = accountCharge.getUserId();
				
				int coinAmountBefore = 0;
				String coinResult = GameServerUtil.invokeQuery(userId);
				JSONObject jsonObject = JSONObject.parseObject(coinResult);
				if (jsonObject.containsKey("coinAmount") && StringUtils.isNotBlank(jsonObject.getString("coinAmount"))) {
					coinAmountBefore = jsonObject.getInteger("coinAmount");
				} else {
					throw new InfServerException(Constants.RETURN_CODE_FAIL, "宝贝币账户不存在");
				}
				
				accountCharge.setChargeDate(new Date());
				accountCharge.setStatus(Constants.PAY_SUCCESS);
				accountCharge.setChannelOrderId(channelOrderId);
				accountCharge.setBeforeChargeCoin(coinAmountBefore + "");
				accountCharge.setAfterChargeCoin(String.valueOf(coinAmountBefore + accountCharge.getCoinAmount()));
				accountChargeMapper.updateSelective(accountCharge);
				
				//更新任务进度
				cache = CacheManager.getCache();
				CachePlayerProfile primaryPlayer = playerCacheController.queryPlayerDetail(userId, cache, false, false);
				if (primaryPlayer != null) {
				    Long promoterId = primaryPlayer.getPromoterId();
				    if (promoterId != null) {

				        CachePlayerProfile secondaryPlayer = playerCacheController.queryPlayerDetail(promoterId, cache, false, false);
				        if (secondaryPlayer != null) {
				            if (secondaryPlayer.getPromoterId() != null) {
				            }
				        }
				    }
				    
				    //更新VIP
				    Long chargeSum = primaryPlayer.getChargeSum() + accountCharge.getRmbAmount();
				    TPlayer player = new TPlayer();
				    player.setPlayerId(userId);
				    player.setChargeSum(chargeSum);
				    
				    playerMapper.updateSelective(player);
				    primaryPlayer.setChargeSum(chargeSum);
				    playerCacheController.updatePlayerVipLevelAndChargeSum(primaryPlayer, cache);

				}
				
				boolean updateResult = GameServerUtil.invokeUpdateCoin(userId, accountCharge.getCoinAmount());
				if (!updateResult) {
					throw new InfServerException(Constants.RETURN_CODE_FAIL, "更新账户宝贝币失败");
				}
			} else {
				throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, chargeOrderId + "未查询到对应的充值记录");
			}
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}
}
