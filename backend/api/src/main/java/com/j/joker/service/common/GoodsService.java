package com.j.joker.service.common;

import com.j.joker.cache.CacheManager;
import com.j.joker.cache.ICache;
import com.j.joker.cache.controller.BaseCacheController;
import com.j.joker.constants.Constants;
import com.j.joker.mapper.*;
import com.j.joker.model.*;
import com.j.joker.utils.InfServerException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class GoodsService {

	@Autowired
	private TGoodsMapper goodsMapper;
	@Autowired
	private TUserMapper  userMapper;
	@Autowired
	private TConfigMapper   configMapper;
	@Autowired
	private TFreeGameTotalMapper freeGameTotalMapper;
	@Autowired
	private TExchangeHistoryMapper historyMapper;
	
	@Autowired
	private BaseCacheController baseCacheController;
	@Autowired
    @Lazy
    private UserService userService;

	/**
	 * 根据userId查询是否已有代理
	 */
	public List<TGoods> findGoodsByType(String type, Integer device) throws Exception {
		ICache cache = null;
		List<TGoods> goods = null;
		try {
			cache = CacheManager.getCache();
			goods = baseCacheController.queryGoodsByType(type, cache);
            //if (Constants.GOODS_TYPE_COIN.equals(type)) {
			 //   if (Constants.DEVICE_IOS.equals(device)) {
	         //       if (CollectionUtils.isNotEmpty(goods)) {
	         //           Double iosChargePercentage = Double.parseDouble(ConfigUtil.get("iosChargePercentage", "1.4"));
	         //           for (TGoods g : goods) {
	         //               g.setPrice(Integer.parseInt(new java.text.DecimalFormat("0").format(g.getPrice() * iosChargePercentage)));
	         //           }
	         //       }
	         //   }
            //}
            //
            //if (Constants.GOODS_TYPE_GIFT.equals(type)) {
			 //   List<TGoods> ransomCards = baseCacheController.queryGoodsByType(Constants.GOODS_TYPE_RANSOM_CARD, cache);
			 //   if (CollectionUtils.isNotEmpty(ransomCards)) {
			 //       if (CollectionUtils.isNotEmpty(goods)) {
			 //           goods.addAll(ransomCards);
			 //       } else {
			 //           goods = ransomCards;
			 //       }
			 //   }
            //}
            //if (Constants.GOODS_TYPE_PROP.equals(type)) {
			 //   List<TGoods> datingGoods = baseCacheController.queryGoodsByType(Constants.GOODS_TYPE_DATING_PROP, cache);
            //    if (CollectionUtils.isNotEmpty(datingGoods)) {
            //        if (CollectionUtils.isNotEmpty(goods)) {
            //            goods.addAll(datingGoods);
            //        } else {
            //            goods = datingGoods;
            //        }
            //    }
            //}
            //
            //if (Constants.GOODS_TYPE_GIFT.equals(type)) {
            //    List<TGoods> defends = baseCacheController.queryGoodsByType(Constants.GOODS_TYPE_DEFEND, cache);
            //    if (CollectionUtils.isNotEmpty(defends)) {
            //        if (CollectionUtils.isNotEmpty(goods)) {
            //            goods.addAll(defends);
            //        } else {
            //            goods = defends;
            //        }
            //    }
            //}
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
		return goods;
	}

	public List<ImsGoods> findImsGoodsByTpey(String type, Integer device,Long userId) throws Exception {
		ICache cache = null;
		List<ImsGoods> goods = null;
		try {
			cache = CacheManager.getCache();
			goods = baseCacheController.queryImsGoodsByType(type,Constants.VALID, cache);
			Map<String, String> stringStringMap = cache.hgetAll(Constants.CE_SHI_HAO);
			if (stringStringMap.containsKey(userId.toString())) {
				List<ImsGoods> goods0 =  baseCacheController.queryImsGoodsByType(Constants.goodsCATEGORYTYPE,Constants.VALID,cache);
				goods.addAll(goods0);
			}
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
		return goods;
	}
	
	
	
	public int isBindAgent(Long userId) throws Exception {
        ICache cache = null;
        try {
        	
            TUser user = userMapper.findById(userId);
            if (user!=null) {
				Long agentId = user.getAgentId();
				if (agentId !=null) {
					return 1;					
				}else {
					return 0;
				}
			}else {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "该用户不存在");
			}
        } catch (Exception e) {
            throw  e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
		
    }
	
	public String bindAgentSendCard(Long userId) throws Exception {
        ICache cache = null;
        try {
        	
            TUser user = userMapper.findById(userId);
        	TConfig config = new TConfig();
			config.setK("bindAgentSendCard");
			config=configMapper.selectOne(config);
            if (user!=null) {
				Long agentId = user.getAgentId();
				if (agentId !=null) {
					if (config!=null) {
						return config.getV();
					}else {
						return config.getV();
					}
					
				}else {
					return config.getV();
				}
			}else {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "该用户不存在");
			}
        } catch (Exception e) {
            throw  e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
		
    }
	/**
	 * 根据物品类型查询物品
	 * @param type
	 * @return
	 * @throws Exception
	 */
	public List<TGoods> findGoodsByType(String type) throws Exception {
		ICache cache = null;
		List<TGoods> goods = null;
		try {
			cache = CacheManager.getCache();
			TGoods g = new TGoods();
			g.setStatus(Constants.VALID);
			g.setCategoryType(type);
			goods = goodsMapper.select(g);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
		return goods;
	}
			
	/**
	 * 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	
	/**
	 * 根据物品ID查询物品详情
	 * @param goodsId
	 * @return
	 */
	public TGoods findGoodsById(Long goodsId) {
		return goodsMapper.findById(goodsId);
	}
	public ImsGoods findImsGoodsById(Long goodsId) {
		return goodsMapper.findImsGoodsById(goodsId);
	}

	public String exchange(Long userId, Long goodsId) throws Exception {

		List<FreeGameActivityInfo> list = userService.viewReganizeGames(userId.toString());
		if (list == null || list.size() == 0) {
			throw new InfServerException(Constants.RETURN_CODE_FAIL,"该用户正在游戏中,请在游戏结束后再进行兑换!!");
		}
		TFreeGameTotal total = freeGameTotalMapper.querytotal(userId);
		if (total == null) {
			throw new InfServerException(Constants.RETURN_CODE_FAIL, "积分不足");
		}
		TGoods g = findGoodsById(goodsId);
		if (g == null || !g.getCategoryType().equalsIgnoreCase(Constants.GOODS_TYPE_EXCHANGE)) {
			throw new InfServerException(Constants.RETURN_CODE_FAIL, "商品不存在");
		}
		TUser user = userMapper.findById(userId);
		if (user == null) {
			throw new InfServerException(Constants.RETURN_CODE_FAIL, "玩家不存在");
		}
		if (total.getTotal() < g.getPrice()) {
			throw new InfServerException(Constants.RETURN_CODE_FAIL, "积分不足");
		}
		freeGameTotalMapper.updateTotal(0, 0, 0, -g.getPrice(), userId);
		TExchangeHistory history = new TExchangeHistory();
		String       exchangCode = UUID.randomUUID().toString().replaceAll("-", "");
		history.setUserId(userId);
		history.setGoodsId(goodsId);
		history.setNickname(user.getNickName());
		history.setGoodsName(g.getName());
		history.setExchangeCode(exchangCode);
		history.setTime(new Date());
		history.setStatus(Constants.NOT_SEND);
		historyMapper.insert(history);
		return exchangCode;
	}

	public List<TExchangeHistory> queryExchangeHistory(Long userId) {
		TExchangeHistory history = new TExchangeHistory();
		history.setUserId(userId);
		return historyMapper.select(history);
	}
}
