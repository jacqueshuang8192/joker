//package com.hbi.service.common;
//
//import java.text.SimpleDateFormat;
//import java.util.ArrayList;
//import java.util.List;
//import java.util.Locale;
//import java.util.Map;
//import java.util.TimeZone;
//import org.apache.commons.collections.CollectionUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//import com.core.service.BaseService;
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.CommonCacheController;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TJewelGivesMapper;
//import com.hbi.mapper.TUserGoodsMapper;
//import com.hbi.model.SendJewelHistoryVo;
//import com.hbi.model.TUserGoods;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.user.HistoryVo;
//import com.hbi.vo.response.user.UserGoodsHistoryVo;
//
//import tk.mybatis.mapper.entity.Example;
//import tk.mybatis.mapper.entity.Example.Criteria;
//
//@Service
//public class UserGoodsService extends BaseService<TUserGoods> {
//
//	@Autowired
//	private TUserGoodsMapper userGoodsMapper;
//
//	@Autowired
//    private TJewelGivesMapper jewelGivesMapper;
//
//	@Autowired
//	private GoodsService goodsService;
//	@Autowired
//	private CommonCacheController commonCacheController;
//	/**
//	 * 查询记录信息
//	 *
//	 * @param account
//	 * @return
//	 * @throws Exception
//	 */
//	public UserGoodsHistoryVo findExchangeHistoryByConditions(Map<String, Object> params) throws Exception {
//		UserGoodsHistoryVo vo = new UserGoodsHistoryVo();
//		List<TUserGoods> userGoods = null;
//		userGoods = findUserGoodsByConditions(params);
//
//		//更新Redis
//
//		if (CommonUtil.isNotNullList(userGoods)) {
//			vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			vo.setCount(userGoods.size());
//			SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd HHmm", Locale.US);
//			sdf.setTimeZone(TimeZone.getTimeZone("GMT+8"));
//			List<HistoryVo> histories = new ArrayList<HistoryVo>();
//			for (TUserGoods ug : userGoods) {
//				HistoryVo historyVo = new HistoryVo();
//				/*historyVo.setBuyDate(sdf.format(ug.getGiveDate()));
//				historyVo.setAmount(ug.getAmount());
//				historyVo.setGoodsName(ug.getType());*/
//				historyVo.setTotalPrice(ug.getTotalPrice());
//				histories.add(historyVo);
//			}
//			vo.setHistory(histories);
//		} else {
//			throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "兑换记录不存在");
//		}
//		return vo;
//	}
//
//	/**
//     * 查询赠送房卡记录信息
//     *
//     * @return
//     * @throws Exception
//     */
//    public List<SendJewelHistoryVo> findSendJewelHistoryByConditions(Long compereId, String startDate, String endDate) throws Exception {
//        startDate = "'" + startDate + "'";
//        endDate = "'" + endDate + " 23:59:59'";
//        List<SendJewelHistoryVo> vo = jewelGivesMapper.findHistory(compereId, startDate, endDate);
//        if(vo == null || vo.size() == 0) {
//            throw new Exception(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR);
//        }
//        //更新Redis
//        return vo;
//    }
//
//    /**
//   	 * 查询用户道具
//   	 * @param userId
//   	 * @return
//   	 */
//   	public List<TUserGoods> queryUserGoodsByUserId(Long userId) throws Exception {
//   		ICache cache = null;
//   		List<TUserGoods> goods = null;
//   		try {
//   			cache = CacheManager.getCache();
//   			goods = commonCacheController.queryUserGoodsByUserId(userId, Constants.GOODS_TYPE_PROP, cache);
//   			List<TUserGoods> ransomCards = commonCacheController.queryUserGoodsByUserId(userId, Constants.GOODS_TYPE_RANSOM_CARD, cache);
//            if (CollectionUtils.isNotEmpty(ransomCards)) {
//                if (CollectionUtils.isNotEmpty(goods)) {
//                    goods.addAll(ransomCards);
//                } else {
//                    goods = ransomCards;
//                }
//            }
//            List<TUserGoods> datingGoods = commonCacheController.queryUserGoodsByUserId(userId, Constants.GOODS_TYPE_DATING_PROP, cache);
//            if (CollectionUtils.isNotEmpty(datingGoods)) {
//                if (CollectionUtils.isNotEmpty(goods)) {
//                    goods.addAll(datingGoods);
//                } else {
//                    goods = datingGoods;
//                }
//            }
//   		} catch (Exception e) {
//   			throw e;
//   		} finally {
//   			if (cache != null) {
//   				CacheManager.releaseCache(cache);
//   			}
//   		}
//   		return goods;
//   	}
//
//       /**
//        * 增加用户背包道具数量
//        * @param userGoods
//        * @return
//        */
//       public int addUserGoodsAmount(TUserGoods userGoods) {
//       	return userGoodsMapper.addUserGoodsAmount(userGoods);
//       }
//
//	/**
//	 *
//	 * @param params
//	 * @return
//	 * @throws Exception
//	 */
//	public List<TUserGoods> findUserGoodsByConditions(Map<String, Object> params) throws Exception {
//		List<TUserGoods> userGoods = null;
//		Example example = new Example(TUserGoods.class);
//		Criteria criteria = example.createCriteria();
//		if (params.get("userid") != null) {
//			criteria.andEqualTo("userid", params.get("userid"));
//		}
//		if (params.get("giverId") != null) {
//			criteria.andEqualTo("giverId", params.get("giverId"));
//		}
//		if (params.get("startDate") != null) {
//			criteria.andGreaterThanOrEqualTo("giveDate", params.get("startDate"));
//		}
//		if (params.get("endDate") != null) {
//			criteria.andLessThanOrEqualTo("giveDate", params.get("endDate"));
//		}
//		userGoods = userGoodsMapper.selectByExample(example);
//		return userGoods;
//	}
//
//}
