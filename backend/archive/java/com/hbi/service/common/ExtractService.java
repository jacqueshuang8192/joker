//package com.hbi.service.common;
//
//import java.math.BigDecimal;
//import java.util.ArrayList;
//import java.util.Date;
//import java.util.HashMap;
//import java.util.List;
//import java.util.Map;
//
//import org.apache.commons.lang.StringUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.core.util.DateUtils;
//import com.hbi.cache.CacheDatabaseObject;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.BaseCacheController;
//import com.hbi.cache.controller.CompereCacheController;
//import com.hbi.cache.controller.DatabaseQueueCacheController;
//import com.hbi.cache.controller.GameCacheController;
//import com.hbi.cache.controller.PlayerCacheController;
//import com.hbi.cache.model.CacheCompereProfile;
//import com.hbi.cache.model.CacheCompereRelation;
//import com.hbi.cache.model.CacheExtractStrategyProfile;
//import com.hbi.cache.model.CacheUserRelation;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TCaptureCompereDefendExtractMapper;
//import com.hbi.mapper.TCaptureCompereDefendProfitMapper;
//import com.hbi.mapper.TCaptureCompereRansomExtractMapper;
//import com.hbi.mapper.TCaptureCompereRansomProfitMapper;
//import com.hbi.mapper.TCompereIncomeMapper;
//import com.hbi.mapper.TCompereMapper;
//import com.hbi.mapper.TDatingActivityExtractMapper;
//import com.hbi.mapper.TDatingActivityProfitMapper;
//import com.hbi.mapper.TFreeGameExtractMapper;
//import com.hbi.mapper.TFreeGameProfitMapper;
//import com.hbi.mapper.TGameMatchExtractMapper;
//import com.hbi.mapper.TGameMatchProfitMapper;
//import com.hbi.mapper.TLiveRoomGameExtractMapper;
//import com.hbi.mapper.TLiveRoomGameProfitMapper;
//import com.hbi.mapper.TLiveRoomGiftExtractMapper;
//import com.hbi.mapper.TLiveRoomGiftProfitMapper;
//import com.hbi.mapper.TSecUserMapper;
//import com.hbi.model.TCaptureCompereDefendExtract;
//import com.hbi.model.TCaptureCompereDefendProfit;
//import com.hbi.model.TCaptureCompereRansomExtract;
//import com.hbi.model.TCaptureCompereRansomProfit;
//import com.hbi.model.TCompereGame;
//import com.hbi.model.TDatingActivity;
//import com.hbi.model.TDatingActivityExtract;
//import com.hbi.model.TDatingActivityProfit;
//import com.hbi.model.TFreeGameExtract;
//import com.hbi.model.TFreeGameProfit;
//import com.hbi.model.TGameMatch;
//import com.hbi.model.TGameMatchExtract;
//import com.hbi.model.TGameMatchProfit;
//import com.hbi.model.TLiveRoomGameExtract;
//import com.hbi.model.TLiveRoomGameProfit;
//import com.hbi.model.TLiveRoomGiftExtract;
//import com.hbi.model.TLiveRoomGiftProfit;
//import com.hbi.model.TOnlineTreasureExtract;
//import com.hbi.model.TOnlineTreasureProfit;
//import com.hbi.service.idGenerate.GenerateIdService;
//import com.hbi.utils.GameServerUtil;
//import com.hbi.utils.InfServerException;
//
//@Service
//public class ExtractService {
//
//	@Autowired
//	private TSecUserMapper secUserMapper;
//	@Autowired
//	private TGameMatchExtractMapper gameMatchExtractMapper;
//	@Autowired
//	private TGameMatchProfitMapper gameMatchProfitMapper;
//	@Autowired
//	private TLiveRoomGameExtractMapper liveRoomGameExtractMapper;
//	@Autowired
//	private TLiveRoomGameProfitMapper liveRoomGameProfitMapper;
//	@Autowired
//	private TLiveRoomGiftExtractMapper liveRoomGiftExtractMapper;
//	@Autowired
//	private TLiveRoomGiftProfitMapper liveRoomGiftProfitMapper;
//	@Autowired
//	private TDatingActivityExtractMapper datingActivityExtractMapper;
//	@Autowired
//	private TDatingActivityProfitMapper datingActivityProfitMapper;
//	@Autowired
//	private TCaptureCompereDefendExtractMapper captureCompereDefendExtractMapper;
//	@Autowired
//	private TCaptureCompereDefendProfitMapper captureCompereDefendProfitMapper;
//	@Autowired
//	private TCaptureCompereRansomExtractMapper captureCompereRansomExtractMapper;
//	@Autowired
//	private TCaptureCompereRansomProfitMapper captureCompereRansomProfitMapper;
//	@Autowired
//	private TFreeGameExtractMapper freeGameExtractMapper;
//	@Autowired
//	private TFreeGameProfitMapper freeGameProfitMapper;
//	@Autowired
//	private TCompereIncomeMapper compereIncomeMapper;
//	@Autowired
//	private TCompereMapper compereMapper;
//	@Autowired
//	private BaseCacheController baseCacheController;
//	@Autowired
//	private CompereCacheController compereCacheController;
//	@Autowired
//	private GameCacheController gameCacheController;
//	@Autowired
//	private PlayerCacheController playerCacheController;
//
//	@Autowired
//	private GenerateIdService generateIdService;
//
//	@Autowired
//    private DatabaseQueueCacheController databaseQueueCacheController;
//
//	public void gameMatchExtract(TGameMatch gameMatch, Long userId,
//			String userType, Integer totalIncome,
//			CacheUserRelation userRelation, Date nowDate, ICache cache)
//			throws Exception {
//		double ratio = 1;
//		String ratioStr = baseCacheController.queryConfig(
//				Constants.EXTRACT_COIN_EXCHANGE_RATIO, cache);
//		int compereAddPrice = 0;
//		if (StringUtils.isNotBlank(ratioStr)) {
//			ratio = Double.parseDouble(ratioStr);
//		}
//
//		CacheExtractStrategyProfile extractStrategy = null;
//		CacheExtractStrategyProfile individuationExtractStrategy = baseCacheController
//				.queryTodayIndividuationExtractStrategiesByManagerId(
//						Constants.SOURCE_GAME_MATCH,
//						userRelation.getManagerId(), nowDate, cache);
//		if (individuationExtractStrategy != null) {
//			extractStrategy = individuationExtractStrategy;
//		} else {
//			extractStrategy = baseCacheController
//					.queryBaseExtractStrategiesBySource(
//							Constants.SOURCE_GAME_MATCH, cache);
//		}
//
//		if (extractStrategy != null) {
//			TGameMatchExtract gameMatchExtract = new TGameMatchExtract();
//			Long gmeId = generateIdService.generateId(TGameMatchExtract.class
//					.getName());
//			gameMatchExtract.setId(gmeId);
//			gameMatchExtract.setGiverId(userId);
//			gameMatchExtract.setGameMatchId(gameMatch.getMatchId());
//			gameMatchExtract.setActivityTotalIncome(totalIncome);
//			gameMatchExtract.setPercentage(gameMatch.getShareExtract() / 100);
//			gameMatchExtract.setExtractIncome((int) (totalIncome
//					* gameMatch.getShareExtract() / 100));
//			gameMatchExtract.setActivityDate(nowDate);
//			gameMatchExtractMapper.insert(gameMatchExtract);
//
//			int size = 0;
//			if (Constants.USER_TYPE_C.equals(userType)) {
//				size = 5;
//			} else {
//				size = 6;
//			}
//			// Long id =
//			// generateIdService.generateIdForList(TGameMatchProfit.class.getName(),
//			// size);
//			if (extractStrategy.getOperatorPercentage() != null) {
//				Long id = generateIdService.generateId();
//				BigDecimal extractPrice = this.saveGameMatchProfit(id, gmeId,
//						userRelation.getPrimaryAgentId(),
//						userRelation.getOperatorId(),
//						Constants.USER_TYPE_OPERATOR, totalIncome,
//						extractStrategy.getOperatorPercentage(),
//						extractStrategy.getOperatorCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						userRelation.getOperatorId(), extractPrice);
//			}
//			if (extractStrategy.getPrimaryAgentPercentage() != null) {
//				Long id = generateIdService.generateId();
//				BigDecimal extractPrice = this.saveGameMatchProfit(id, gmeId,
//						userRelation.getSecondaryAgentId(),
//						userRelation.getPrimaryAgentId(),
//						Constants.USER_TYPE_PRIMARY_AGENT, totalIncome,
//						extractStrategy.getPrimaryAgentPercentage(),
//						extractStrategy.getPrimaryAgentCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						userRelation.getPrimaryAgentId(), extractPrice);
//			}
//			if (extractStrategy.getSecondaryAgentPercentage() != null) {
//				Long id = generateIdService.generateId();
//				BigDecimal extractPrice = this.saveGameMatchProfit(id, gmeId,
//						userRelation.getThirdlyAgentId(),
//						userRelation.getSecondaryAgentId(),
//						Constants.USER_TYPE_SECONDARY_AGENT, totalIncome,
//						extractStrategy.getSecondaryAgentPercentage(),
//						extractStrategy.getSecondaryAgentCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						userRelation.getSecondaryAgentId(), extractPrice);
//			}
//			if (extractStrategy.getThirdlyAgentPercentage() != null) {
//				Long id = generateIdService.generateId();
//				BigDecimal extractPrice = this.saveGameMatchProfit(id, gmeId,
//						userRelation.getManagerId(),
//						userRelation.getThirdlyAgentId(),
//						Constants.USER_TYPE_THIRDLY_AGENT, totalIncome,
//						extractStrategy.getThirdlyAgentPercentage(),
//						extractStrategy.getThirdlyAgentCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						userRelation.getThirdlyAgentId(), extractPrice);
//			}
//			if (extractStrategy.getManagerPercentage() != null) {
//				Long id = generateIdService.generateId();
//				BigDecimal extractPrice = this.saveGameMatchProfit(id, gmeId,
//						userRelation.getCompereId(),
//						userRelation.getManagerId(),
//						Constants.USER_TYPE_MANAGER, totalIncome,
//						extractStrategy.getManagerPercentage(),
//						extractStrategy.getManagerCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						userRelation.getManagerId(), extractPrice);
//			}
//			if (Constants.USER_TYPE_P.equalsIgnoreCase(userType)) {
//				if (extractStrategy.getComperePercentage() != null) {
//					Long id = generateIdService.generateId();
//					compereAddPrice = this.saveGameMatchProfit(id, gmeId,
//							userId, userRelation.getCompereId(),
//							Constants.USER_TYPE_COMPERE, totalIncome,
//							extractStrategy.getComperePercentage(),
//							extractStrategy.getCompereCurrency(), ratio)
//							.intValue();
//					if (compereAddPrice > 0) {
//						String incomeDateStr = DateUtils.getParseDate(nowDate,
//								"yyyy-MM-dd");
//						int incomeCount = compereIncomeMapper
//								.addGameMatchExtractIncome(
//										userRelation.getCompereId(),
//										compereAddPrice, nowDate, incomeDateStr);
//
//						boolean isUpdateSuccess = GameServerUtil
//								.invokeUpdateCoin(userRelation.getCompereId(),
//										compereAddPrice);
//						if (!isUpdateSuccess) {
//							throw new InfServerException(
//									Constants.RETURN_CODE_ACCOUNT_ERROR,
//									"更新主播账户失败");
//						}
//
//						if (incomeCount > 0) {
//							compereCacheController.addGameMatchExtractIncome(
//									userRelation.getCompereId(), incomeDateStr,
//									compereAddPrice, cache);
//						}
//					}
//				}
//			}
//		} else {
//			throw new InfServerException(
//					Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到分成策略");
//		}
//	}
//
//	/**
//	 * 直播间游戏分成
//	 *
//	 * @param roomId
//	 * @param gameId
//	 * @param compereId
//	 * @param userId
//	 * @param extractIncome
//	 * @param nowDate
//	 * @param cache
//	 * @throws Exception
//	 */
//	public void liveGameExtract(Long roomId, Long gameId, Long compereId,
//			Long userId, Integer extractIncome, Date nowDate, ICache cache)
//			throws Exception {
//		double ratio = 1;
//		String ratioStr = baseCacheController.queryConfig(
//				Constants.EXTRACT_COIN_EXCHANGE_RATIO, cache);
//		int compereAddPrice = 0;
//		if (StringUtils.isNotBlank(ratioStr)) {
//			ratio = Double.parseDouble(ratioStr);
//		}
//
//		CacheCompereRelation compereRelation = compereCacheController
//				.queryCompereRelation(compereId, cache);
//		if (compereRelation == null) {
//			throw new InfServerException(
//					Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询主播对应的关系");
//		}
//
//		TCompereGame compereGame = gameCacheController.queryCompereGame(gameId,
//				cache);
//		if (compereGame == null) {
//			throw new InfServerException(
//					Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR,
//					"没有查询到视频游戏底分分场");
//		}
//
//		CacheExtractStrategyProfile extractStrategy = null;
//		CacheExtractStrategyProfile individuationExtractStrategy = baseCacheController
//				.queryTodayIndividuationExtractStrategiesByManagerId(
//						Constants.SOURCE_LIVE_ROOM_GAME,
//						compereRelation.getManagerId(), nowDate, cache);
//		if (individuationExtractStrategy != null) {
//			extractStrategy = individuationExtractStrategy;
//		} else {
//			extractStrategy = baseCacheController
//					.queryBaseExtractStrategiesBySource(
//							Constants.SOURCE_LIVE_ROOM_GAME, cache);
//		}
//
//		Integer totalIncome = (int) (extractIncome * 100 / (100 - compereGame
//				.getExtract()));
//		if (extractStrategy != null) {
//			TLiveRoomGameExtract liveRoomGameExtract = new TLiveRoomGameExtract();
//			Long lrgeId = generateIdService
//					.generateId(TLiveRoomGameExtract.class.getName());
//			liveRoomGameExtract.setId(lrgeId);
//			liveRoomGameExtract.setGiverId(userId);
//			liveRoomGameExtract.setRoomId(roomId);
//			liveRoomGameExtract.setGameId(gameId);
//			liveRoomGameExtract.setActivityTotalIncome(totalIncome);
//			liveRoomGameExtract
//					.setPercentage((100 - compereGame.getExtract()) / 100);
//			liveRoomGameExtract.setExtractIncome(extractIncome);
//			liveRoomGameExtract.setActivityDate(nowDate);
//			liveRoomGameExtractMapper.insert(liveRoomGameExtract);
//
//			// Long id =
//			// generateIdService.generateIdForList(TLiveRoomGameProfit.class.getName(),
//			// 6);
//			if (extractStrategy.getOperatorPercentage() != null) {
//				Long id = generateIdService.generateId();
//				Long contributoryId = compereRelation.getPrimaryAgentId();
//				BigDecimal extractPrice = this.saveLiveRoomGameProfit(id,
//						lrgeId, contributoryId,
//						compereRelation.getOperatorId(),
//						Constants.USER_TYPE_OPERATOR, totalIncome,
//						extractStrategy.getOperatorPercentage(),
//						extractStrategy.getOperatorCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						compereRelation.getOperatorId(), extractPrice);
//			}
//			if (extractStrategy.getPrimaryAgentPercentage() != null) {
//				Long contributoryId = compereRelation.getSecondaryAgentId();
//				Long id = generateIdService.generateId();
//				BigDecimal extractPrice = this.saveLiveRoomGameProfit(id,
//						lrgeId, contributoryId,
//						compereRelation.getPrimaryAgentId(),
//						Constants.USER_TYPE_PRIMARY_AGENT, totalIncome,
//						extractStrategy.getPrimaryAgentPercentage(),
//						extractStrategy.getPrimaryAgentCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						compereRelation.getPrimaryAgentId(), extractPrice);
//			}
//			if (extractStrategy.getSecondaryAgentPercentage() != null) {
//				Long contributoryId = compereRelation.getThirdlyAgentId();
//				Long id = generateIdService.generateId();
//				BigDecimal extractPrice = this.saveLiveRoomGameProfit(id,
//						lrgeId, contributoryId,
//						compereRelation.getSecondaryAgentId(),
//						Constants.USER_TYPE_SECONDARY_AGENT, totalIncome,
//						extractStrategy.getSecondaryAgentPercentage(),
//						extractStrategy.getSecondaryAgentCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						compereRelation.getSecondaryAgentId(), extractPrice);
//			}
//			if (extractStrategy.getThirdlyAgentPercentage() != null) {
//				Long contributoryId = compereRelation.getManagerId();
//				Long id = generateIdService.generateId();
//				BigDecimal extractPrice = this.saveLiveRoomGameProfit(id,
//						lrgeId, contributoryId,
//						compereRelation.getThirdlyAgentId(),
//						Constants.USER_TYPE_THIRDLY_AGENT, totalIncome,
//						extractStrategy.getThirdlyAgentPercentage(),
//						extractStrategy.getThirdlyAgentCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						compereRelation.getThirdlyAgentId(), extractPrice);
//			}
//			if (extractStrategy.getManagerPercentage() != null) {
//				Long contributoryId = compereRelation.getCompereId();
//				Long id = generateIdService.generateId();
//				BigDecimal extractPrice = this.saveLiveRoomGameProfit(id,
//						lrgeId, contributoryId, compereRelation.getManagerId(),
//						Constants.USER_TYPE_MANAGER, totalIncome,
//						extractStrategy.getManagerPercentage(),
//						extractStrategy.getManagerCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						compereRelation.getManagerId(), extractPrice);
//			}
//			if (extractStrategy.getComperePercentage() != null) {
//				Long id = generateIdService.generateId();
//				compereAddPrice = this.saveLiveRoomGameProfit(id, lrgeId,
//						userId, compereRelation.getCompereId(),
//						Constants.USER_TYPE_COMPERE, totalIncome,
//						extractStrategy.getComperePercentage(),
//						extractStrategy.getCompereCurrency(), ratio).intValue();
//				String incomeDateStr = DateUtils.getParseDate(nowDate,
//						"yyyy-MM-dd");
//				int incomeCount = compereIncomeMapper
//						.addLiveRoomGameExtractIncome(
//								compereRelation.getCompereId(),
//								compereAddPrice, nowDate, incomeDateStr);
//				if (incomeCount > 0) {
//					compereCacheController.addLiveRoomGameExtractIncome(
//							compereRelation.getCompereId(), incomeDateStr,
//							compereAddPrice, cache);
//				}
//			}
//		} else {
//			throw new InfServerException(
//					Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到分成策略");
//		}
//
//		boolean isUpdateSuccess = GameServerUtil.invokeUpdateCoin(compereId,
//				compereAddPrice);
//		if (isUpdateSuccess) {
//		} else {
//			throw new InfServerException(Constants.RETURN_CODE_ACCOUNT_ERROR,
//					"更新主播账户失败");
//		}
//	}
//
//	public void indianaExtract(Long prividerId, Long operatorId, int profit,
//			Date activityDate, ICache cache) throws Exception {
//		CacheExtractStrategyProfile extractStrategy = baseCacheController
//				.queryBaseExtractStrategiesBySource(Constants.SOURCE_ONLINE_TREASURE,
//						cache);
//
//		if (extractStrategy == null) {
//			throw new InfServerException(Constants.RETURN_CODE_FAIL,
//					"没有夺宝的分成策略");
//		}
//
//		double ratio = 1;
//		String ratioStr = baseCacheController.queryConfig(
//				Constants.EXTRACT_COIN_EXCHANGE_RATIO, cache);
//		if (StringUtils.isNotBlank(ratioStr)) {
//			ratio = Double.parseDouble(ratioStr);
//		}
//
//		List<CacheDatabaseObject> insertList = new ArrayList<CacheDatabaseObject>();
//		List<CacheDatabaseObject> updateList = new ArrayList<CacheDatabaseObject>();
//
//		TOnlineTreasureExtract indianaExtract = new TOnlineTreasureExtract();
//		Long extractId = generateIdService.generateId();
//		indianaExtract.setId(extractId);
//		indianaExtract.setActivityTotalIncome(profit);
//		indianaExtract.setPercentage(1F);
//		indianaExtract.setExtractIncome(profit);
//		indianaExtract.setActivityDate(activityDate);
//		CacheDatabaseObject indianaExtractObj = new CacheDatabaseObject();
//		indianaExtractObj.setControlType("insert:T_ONLINE_TREASURE_EXTRACT");
//		indianaExtractObj.setData(indianaExtract);
//		insertList.add(indianaExtractObj);
//		Long lrgeId = indianaExtract.getId();
//
//		if (extractStrategy.getOperatorPercentage() != null) {
//			Long id = generateIdService.generateId();
//			BigDecimal extractPrice = this.saveIndianaProfit(id, lrgeId,
//					operatorId, Constants.USER_TYPE_OPERATOR, profit,
//					extractStrategy.getOperatorPercentage(),
//					extractStrategy.getOperatorCurrency(), ratio, insertList);
//			Map<String, Object> params = new HashMap<String, Object>();
//			params.put("userId", operatorId + "");
//			params.put("jewelAmount", extractPrice);
//
//			CacheDatabaseObject secUserObj = new CacheDatabaseObject();
//			secUserObj.setControlType("updateTSECUSER:T_SEC_USER");
//			secUserObj.setData(params);
//
//			updateList.add(secUserObj);
//		}
//
//		if (extractStrategy.getPrimaryAgentPercentage() != null) {
//			Long id = generateIdService.generateId();
//			BigDecimal extractPrice = this.saveIndianaProfit(id, lrgeId,
//					prividerId, Constants.USER_TYPE_PRIMARY_AGENT, profit,
//					extractStrategy.getPrimaryAgentPercentage(),
//					extractStrategy.getPrimaryAgentCurrency(), ratio, insertList);
//			Map<String, Object> params = new HashMap<String, Object>();
//			params.put("userId", prividerId + "");
//			params.put("jewelAmount", extractPrice);
//
//			CacheDatabaseObject secUserObj = new CacheDatabaseObject();
//			secUserObj.setControlType("updateTSECUSER:T_SEC_USER");
//			secUserObj.setData(params);
//
//			updateList.add(secUserObj);
//		}
//
//		if (!databaseQueueCacheController.queueObject(null, insertList, updateList, cache)) {
//			throw new InfServerException(Constants.RETURN_CODE_FAIL, "队列数据更新失败");
//		}
//	}
//
//	/**
//	 * 礼物分成
//	 *
//	 * @param giverId
//	 * @param cost
//	 * @param receiverId
//	 * @param roomId
//	 * @param nowDate
//	 * @param cache
//	 * @throws Exception
//	 */
//	public void liveRoomGiftExtract(Long giverId, int cost, Long receiverId,
//			Long roomId, Date nowDate, List<CacheDatabaseObject> insertList,
//			List<CacheDatabaseObject> updateList, ICache cache)
//			throws Exception {
//		double ratio = 1;
//		String ratioStr = baseCacheController.queryConfig(
//				Constants.EXTRACT_COIN_EXCHANGE_RATIO, cache);
//		int compereAddPrice = 0;
//		int ownerAddPrice = 0;
//		Long ownerId = null;
//		if (StringUtils.isNotBlank(ratioStr)) {
//			ratio = Double.parseDouble(ratioStr);
//		}
//
//		CacheCompereRelation compereRelation = compereCacheController
//				.queryCompereRelation(receiverId, cache);
//		if (compereRelation != null) {
//			CacheExtractStrategyProfile extractStrategy = null;
//			CacheExtractStrategyProfile individuationExtractStrategy = baseCacheController
//					.queryTodayIndividuationExtractStrategiesByManagerId(
//							Constants.SOURCE_LIVE_ROOM_GIFT,
//							compereRelation.getManagerId(), nowDate, cache);
//			if (individuationExtractStrategy != null) {
//				extractStrategy = individuationExtractStrategy;
//			} else {
//				extractStrategy = baseCacheController
//						.queryBaseExtractStrategiesBySource(
//								Constants.SOURCE_LIVE_ROOM_GIFT, cache);
//			}
//
//			if (extractStrategy != null) {
//				TLiveRoomGiftExtract liveRoomGiftExtract = new TLiveRoomGiftExtract();
//				Long extractId = generateIdService.generateId();
//				liveRoomGiftExtract.setId(extractId);
//				liveRoomGiftExtract.setGiverId(giverId);
//				liveRoomGiftExtract.setRoomId(roomId);
//				liveRoomGiftExtract.setActivityTotalIncome(cost);
//				liveRoomGiftExtract.setPercentage(1F);
//				liveRoomGiftExtract.setExtractIncome(cost);
//				liveRoomGiftExtract.setActivityDate(nowDate);
//				// liveRoomGiftExtractMapper.insertLiveRoomGiftExtract(liveRoomGiftExtract);
//				CacheDatabaseObject liveRoomGiftExtractObj = new CacheDatabaseObject();
//				liveRoomGiftExtractObj
//						.setControlType("insert:T_LIVE_ROOM_GIFT_EXTRACT");
//				liveRoomGiftExtractObj.setData(liveRoomGiftExtract);
//				insertList.add(liveRoomGiftExtractObj);
//				Long lrgeId = liveRoomGiftExtract.getId();
//				// Long id =
//				// generateIdService.generateIdForList(TLiveRoomGiftProfit.class.getName(),
//				// 7);
//				if (extractStrategy.getOperatorPercentage() != null) {
//					Long id = generateIdService.generateId();
//					System.out.println(id + "-----");
//					Long contributoryId = compereRelation.getPrimaryAgentId();
//					BigDecimal extractPrice = this.saveLiveRoomGiftProfit(id,
//							lrgeId, contributoryId,
//							compereRelation.getOperatorId(),
//							Constants.USER_TYPE_OPERATOR, cost,
//							extractStrategy.getOperatorPercentage(),
//							extractStrategy.getOperatorCurrency(), ratio,
//							insertList);
//					Map<String, Object> params = new HashMap<String, Object>();
//					params.put("userId", compereRelation.getOperatorId() + "");
//					params.put("jewelAmount", extractPrice);
//
//					CacheDatabaseObject secUserObj = new CacheDatabaseObject();
//					secUserObj.setControlType("updateTSECUSER:T_SEC_USER");
//					secUserObj.setData(params);
//
//					updateList.add(secUserObj);
//					// secUserMapper.updateExtractJewelAmount(compereRelation.getOperatorId(),
//					// extractPrice);
//				}
//				if (extractStrategy.getPrimaryAgentPercentage() != null) {
//					Long id = generateIdService.generateId();
//					System.out.println(id + "-----");
//					Long contributoryId = compereRelation.getSecondaryAgentId();
//					BigDecimal extractPrice = this.saveLiveRoomGiftProfit(id,
//							lrgeId, contributoryId,
//							compereRelation.getPrimaryAgentId(),
//							Constants.USER_TYPE_PRIMARY_AGENT, cost,
//							extractStrategy.getPrimaryAgentPercentage(),
//							extractStrategy.getPrimaryAgentCurrency(), ratio,
//							insertList);
//					Map<String, Object> params = new HashMap<String, Object>();
//					params.put("userId", compereRelation.getPrimaryAgentId()
//							+ "");
//					params.put("jewelAmount", extractPrice);
//
//					CacheDatabaseObject secUserObj = new CacheDatabaseObject();
//					secUserObj.setControlType("updateTSECUSER:T_SEC_USER");
//					secUserObj.setData(params);
//
//					updateList.add(secUserObj);
//					// secUserMapper.updateExtractJewelAmount(compereRelation.getPrimaryAgentId(),
//					// extractPrice);
//				}
//				if (extractStrategy.getSecondaryAgentPercentage() != null) {
//					Long id = generateIdService.generateId();
//					System.out.println(id + "-----");
//					Long contributoryId = compereRelation.getThirdlyAgentId();
//					BigDecimal extractPrice = this.saveLiveRoomGiftProfit(id,
//							lrgeId, contributoryId,
//							compereRelation.getSecondaryAgentId(),
//							Constants.USER_TYPE_SECONDARY_AGENT, cost,
//							extractStrategy.getSecondaryAgentPercentage(),
//							extractStrategy.getSecondaryAgentCurrency(), ratio,
//							insertList);
//					Map<String, Object> params = new HashMap<String, Object>();
//					params.put("userId", compereRelation.getSecondaryAgentId()
//							+ "");
//					params.put("jewelAmount", extractPrice);
//
//					CacheDatabaseObject secUserObj = new CacheDatabaseObject();
//					secUserObj.setControlType("updateTSECUSER:T_SEC_USER");
//					secUserObj.setData(params);
//
//					updateList.add(secUserObj);
//					// secUserMapper.updateExtractJewelAmount(compereRelation.getSecondaryAgentId(),
//					// extractPrice);
//				}
//				if (extractStrategy.getThirdlyAgentPercentage() != null) {
//					Long id = generateIdService.generateId();
//					System.out.println(id + "-----");
//					Long contributoryId = compereRelation.getManagerId();
//					BigDecimal extractPrice = this.saveLiveRoomGiftProfit(id,
//							lrgeId, contributoryId,
//							compereRelation.getThirdlyAgentId(),
//							Constants.USER_TYPE_THIRDLY_AGENT, cost,
//							extractStrategy.getThirdlyAgentPercentage(),
//							extractStrategy.getThirdlyAgentCurrency(), ratio,
//							insertList);
//
//					Map<String, Object> params = new HashMap<String, Object>();
//					params.put("userId", compereRelation.getThirdlyAgentId()
//							+ "");
//					params.put("jewelAmount", extractPrice);
//
//					CacheDatabaseObject secUserObj = new CacheDatabaseObject();
//					secUserObj.setControlType("updateTSECUSER:T_SEC_USER");
//					secUserObj.setData(params);
//
//					updateList.add(secUserObj);
//
//					// secUserMapper.updateExtractJewelAmount(compereRelation.getThirdlyAgentId(),
//					// extractPrice);
//				}
//				if (extractStrategy.getManagerPercentage() != null) {
//					Long contributoryId = compereRelation.getCompereId();
//					Long id = generateIdService.generateId();
//					System.out.println(id + "-----");
//					BigDecimal extractPrice = this.saveLiveRoomGiftProfit(id,
//							lrgeId, contributoryId,
//							compereRelation.getManagerId(),
//							Constants.USER_TYPE_MANAGER, cost,
//							extractStrategy.getManagerPercentage(),
//							extractStrategy.getManagerCurrency(), ratio,
//							insertList);
//
//					Map<String, Object> params = new HashMap<String, Object>();
//					params.put("userId", compereRelation.getManagerId() + "");
//					params.put("jewelAmount", extractPrice);
//
//					CacheDatabaseObject secUserObj = new CacheDatabaseObject();
//					secUserObj.setControlType("updateTSECUSER:T_SEC_USER");
//					secUserObj.setData(params);
//
//					updateList.add(secUserObj);
//
//					// secUserMapper.updateExtractJewelAmount(compereRelation.getManagerId(),
//					// extractPrice);
//				}
//				if (extractStrategy.getComperePercentage() != null) {
//					CacheCompereProfile compere = compereCacheController
//							.getCompereDetail(receiverId.toString(), cache,
//									false, false);
//					if (compere != null && compere.getOwnerId() != null) {
//						Long id = generateIdService.generateId();
//						ownerId = compere.getOwnerId();
//						double captureShareRate = 3;
//						String captureShareRateStr = baseCacheController
//								.queryConfig(Constants.CAPTURE_SHARE_RATE,
//										cache);
//						if (StringUtils.isNotBlank(captureShareRateStr)) {
//							captureShareRate = Double
//									.parseDouble(captureShareRateStr);
//						}
//						BigDecimal bigDecimal = new BigDecimal(cost
//								* extractStrategy.getComperePercentage());
//						bigDecimal = bigDecimal.divide(new BigDecimal(100));
//						System.out.println(id + "-----");
//						ownerAddPrice = this.saveLiveRoomGiftProfit(id, lrgeId,
//								compereRelation.getCompereId(), ownerId,
//								Constants.USER_TYPE_USER,
//								bigDecimal.intValue(), captureShareRate,
//								Constants.CURRENCY_COIN, ratio, insertList)
//								.intValue();
//						id = generateIdService.generateId();
//						System.out.println(id + "-----");
//						compereAddPrice = this.saveLiveRoomGiftProfit(
//								id,
//								lrgeId,
//								giverId,
//								compereRelation.getCompereId(),
//								Constants.USER_TYPE_COMPERE,
//								cost,
//								extractStrategy.getComperePercentage()
//										- captureShareRate,
//								extractStrategy.getCompereCurrency(), ratio,
//								insertList).intValue();
//						String incomeDateStr = DateUtils.getParseDate(nowDate,
//								"yyyy-MM-dd");
//
//						Map<String, Object> params = new HashMap<String, Object>();
//						params.put("compereId", compereRelation.getCompereId());
//						params.put("liveRoomGiftIncome", compereAddPrice);
//						params.put("lastmodifyDate", nowDate);
//						params.put("nowDate", incomeDateStr);
//
//						CacheDatabaseObject incomeObj = new CacheDatabaseObject();
//						incomeObj
//								.setControlType("updateIncome:T_COMPERE_INCOME");
//						incomeObj.setData(params);
//
//						updateList.add(incomeObj);
//						// int incomeCount =
//						// compereIncomeMapper.addLiveRoomGiftIncome(compereRelation.getCompereId(),
//						// compereAddPrice, nowDate, incomeDateStr);
//						// if (incomeCount > 0) {
//						compereCacheController.addLiveRoomGiftIncome(
//								compereRelation.getCompereId(), incomeDateStr,
//								compereAddPrice, cache);
//						// }
//					} else {
//						Long id = generateIdService.generateId();
//						compereAddPrice = this.saveLiveRoomGiftProfit(id,
//								lrgeId, giverId,
//								compereRelation.getCompereId(),
//								Constants.USER_TYPE_COMPERE, cost,
//								extractStrategy.getComperePercentage(),
//								extractStrategy.getCompereCurrency(), ratio,
//								insertList).intValue();
//						String incomeDateStr = DateUtils.getParseDate(nowDate,
//								"yyyy-MM-dd");
//
//						Map<String, Object> params = new HashMap<String, Object>();
//						params.put("compereId", compereRelation.getCompereId());
//						params.put("liveRoomGiftIncome", compereAddPrice);
//						params.put("lastmodifyDate", nowDate);
//						params.put("nowDate", incomeDateStr);
//
//						CacheDatabaseObject incomeObj = new CacheDatabaseObject();
//						incomeObj
//								.setControlType("updateIncome:T_COMPERE_INCOME");
//						incomeObj.setData(params);
//
//						updateList.add(incomeObj);
//
//						// int incomeCount =
//						// compereIncomeMapper.addLiveRoomGiftIncome(compereRelation.getCompereId(),
//						// compereAddPrice, nowDate, incomeDateStr);
//						// if (incomeCount > 0) {
//						compereCacheController.addLiveRoomGiftIncome(
//								compereRelation.getCompereId(), incomeDateStr,
//								compereAddPrice, cache);
//						// }
//					}
//				}
//
//			} else {
//				throw new InfServerException(
//						Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR,
//						"没有查询到分成策略");
//			}
//		}
//
//		if (compereAddPrice > 0) {
//			if (!GameServerUtil.invokeUpdateCoin(receiverId, compereAddPrice)) {
//				throw new InfServerException(
//						Constants.RETURN_CODE_ACCOUNT_ERROR, "更新主播账户失败");
//			}
//		}
//
//		if (ownerAddPrice > 0) {
//			compereMapper.addCompereSharedProfit(ownerAddPrice, receiverId);
//			compereCacheController.increaseCompereDetailField(receiverId,
//					CompereCacheController.COMPERE_FIELD_SHARED_PROFIT,
//					ownerAddPrice, cache);
//			if (!GameServerUtil.invokeUpdateCoin(ownerId, ownerAddPrice)) {
//				throw new InfServerException(
//						Constants.RETURN_CODE_ACCOUNT_ERROR, "更新主播所属玩家账户失败");
//			}
//		}
//	}
//
//	/**
//	 * 约饭分成
//	 *
//	 * @param datingActivity
//	 * @param totalIncome
//	 * @param nowDate
//	 * @param cache
//	 * @throws Exception
//	 */
//	public void datingServiceExtract(TDatingActivity datingActivity,
//			Integer totalIncome, Date nowDate, ICache cache) throws Exception {
//		double ratio = 1;
//		String ratioStr = baseCacheController.queryConfig(
//				Constants.EXTRACT_COIN_EXCHANGE_RATIO, cache);
//		int compereAddPrice = 0;
//		if (StringUtils.isNotBlank(ratioStr)) {
//			ratio = Double.parseDouble(ratioStr);
//		}
//
//		CacheCompereRelation compereRelation = compereCacheController
//				.queryCompereRelation(datingActivity.getUserId(), cache);
//		if (compereRelation == null) {
//			throw new InfServerException(
//					Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询主播对应的关系");
//		}
//
//		CacheExtractStrategyProfile extractStrategy = null;
//		CacheExtractStrategyProfile individuationExtractStrategy = baseCacheController
//				.queryTodayIndividuationExtractStrategiesByManagerId(
//						Constants.SOURCE_DATING,
//						compereRelation.getManagerId(), nowDate, cache);
//		if (individuationExtractStrategy != null) {
//			extractStrategy = individuationExtractStrategy;
//		} else {
//			extractStrategy = baseCacheController
//					.queryBaseExtractStrategiesBySource(
//							Constants.SOURCE_DATING, cache);
//		}
//
//		if (extractStrategy != null) {
//			TDatingActivityExtract datingActivityExtract = new TDatingActivityExtract();
//			Long daeId = generateIdService
//					.generateId(TDatingActivityExtract.class.getName());
//			datingActivityExtract.setId(daeId);
//			datingActivityExtract.setGiverId(datingActivity
//					.getHighestAuctionUserId());
//			datingActivityExtract.setActivityId(datingActivity.getId());
//			datingActivityExtract.setActivityTotalIncome(totalIncome);
//			datingActivityExtract.setPercentage(1F);
//			datingActivityExtract.setExtractIncome(totalIncome);
//			datingActivityExtract.setActivityDate(nowDate);
//			datingActivityExtractMapper.insert(datingActivityExtract);
//
//			// Long id =
//			// generateIdService.generateIdForList(TLiveRoomGameProfit.class.getName(),
//			// 6);
//			if (extractStrategy.getOperatorPercentage() != null) {
//				Long id = generateIdService.generateId();
//				Long contributoryId = compereRelation.getPrimaryAgentId();
//				BigDecimal extractPrice = this.saveDatingActivityProfit(id,
//						daeId, contributoryId, compereRelation.getOperatorId(),
//						Constants.USER_TYPE_OPERATOR, totalIncome,
//						extractStrategy.getOperatorPercentage(),
//						extractStrategy.getOperatorCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						compereRelation.getOperatorId(), extractPrice);
//			}
//			if (extractStrategy.getPrimaryAgentPercentage() != null) {
//				Long id = generateIdService.generateId();
//				Long contributoryId = compereRelation.getSecondaryAgentId();
//				BigDecimal extractPrice = this.saveDatingActivityProfit(id,
//						daeId, contributoryId,
//						compereRelation.getPrimaryAgentId(),
//						Constants.USER_TYPE_PRIMARY_AGENT, totalIncome,
//						extractStrategy.getPrimaryAgentPercentage(),
//						extractStrategy.getPrimaryAgentCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						compereRelation.getPrimaryAgentId(), extractPrice);
//			}
//			if (extractStrategy.getSecondaryAgentPercentage() != null) {
//				Long id = generateIdService.generateId();
//				Long contributoryId = compereRelation.getThirdlyAgentId();
//				BigDecimal extractPrice = this.saveDatingActivityProfit(id,
//						daeId, contributoryId,
//						compereRelation.getSecondaryAgentId(),
//						Constants.USER_TYPE_SECONDARY_AGENT, totalIncome,
//						extractStrategy.getSecondaryAgentPercentage(),
//						extractStrategy.getSecondaryAgentCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						compereRelation.getSecondaryAgentId(), extractPrice);
//			}
//			if (extractStrategy.getThirdlyAgentPercentage() != null) {
//				Long id = generateIdService.generateId();
//				Long contributoryId = compereRelation.getManagerId();
//				BigDecimal extractPrice = this.saveDatingActivityProfit(id,
//						daeId, contributoryId,
//						compereRelation.getThirdlyAgentId(),
//						Constants.USER_TYPE_THIRDLY_AGENT, totalIncome,
//						extractStrategy.getThirdlyAgentPercentage(),
//						extractStrategy.getThirdlyAgentCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						compereRelation.getThirdlyAgentId(), extractPrice);
//			}
//			if (extractStrategy.getManagerPercentage() != null) {
//				Long id = generateIdService.generateId();
//				Long contributoryId = compereRelation.getCompereId();
//				BigDecimal extractPrice = this.saveDatingActivityProfit(id,
//						daeId, contributoryId, compereRelation.getManagerId(),
//						Constants.USER_TYPE_MANAGER, totalIncome,
//						extractStrategy.getManagerPercentage(),
//						extractStrategy.getManagerCurrency(), ratio);
//				secUserMapper.updateExtractJewelAmount(
//						compereRelation.getManagerId(), extractPrice);
//			}
//			if (extractStrategy.getComperePercentage() != null) {
//				Long id = generateIdService.generateId();
//				compereAddPrice = this.saveDatingActivityProfit(id, daeId,
//						datingActivity.getHighestAuctionUserId(),
//						compereRelation.getCompereId(),
//						Constants.USER_TYPE_COMPERE, totalIncome,
//						extractStrategy.getComperePercentage(),
//						extractStrategy.getCompereCurrency(), ratio).intValue();
//				String incomeDateStr = DateUtils.getParseDate(nowDate,
//						"yyyy-MM-dd");
//				int incomeCount = compereIncomeMapper.addDatingIncome(
//						compereRelation.getCompereId(), compereAddPrice,
//						nowDate, incomeDateStr);
//				if (incomeCount > 0) {
//					compereCacheController.addDatingIncome(
//							compereRelation.getCompereId(), incomeDateStr,
//							compereAddPrice, cache);
//				}
//			}
//		} else {
//			throw new InfServerException(
//					Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到分成策略");
//		}
//
//		boolean isUpdateSuccess = GameServerUtil.invokeUpdateCoin(
//				datingActivity.getUserId(), compereAddPrice);
//		if (!isUpdateSuccess) {
//			throw new InfServerException(Constants.RETURN_CODE_ACCOUNT_ERROR,
//					"更新主播账户失败");
//		}
//	}
//
//	/**
//	 * 守护分成
//	 *
//	 * @param giverId
//	 * @param cost
//	 * @param receiverId
//	 * @param roomId
//	 * @param nowDate
//	 * @param cache
//	 * @throws Exception
//	 */
//	public void captureCompereDefendExtract(Long giverId, int cost,
//			Long receiverId, Long roomId, Date nowDate, ICache cache)
//			throws Exception {
//		double ratio = 1;
//		String ratioStr = baseCacheController.queryConfig(
//				Constants.EXTRACT_COIN_EXCHANGE_RATIO, cache);
//		int compereAddPrice = 0;
//		if (StringUtils.isNotBlank(ratioStr)) {
//			ratio = Double.parseDouble(ratioStr);
//		}
//
//		CacheCompereRelation compereRelation = compereCacheController
//				.queryCompereRelation(receiverId, cache);
//		if (compereRelation != null) {
//			CacheExtractStrategyProfile extractStrategy = null;
//			CacheExtractStrategyProfile individuationExtractStrategy = baseCacheController
//					.queryTodayIndividuationExtractStrategiesByManagerId(
//							Constants.SOURCE_DEFEND,
//							compereRelation.getManagerId(), nowDate, cache);
//			if (individuationExtractStrategy != null) {
//				extractStrategy = individuationExtractStrategy;
//			} else {
//				extractStrategy = baseCacheController
//						.queryBaseExtractStrategiesBySource(
//								Constants.SOURCE_DEFEND, cache);
//			}
//
//			if (extractStrategy != null) {
//				TCaptureCompereDefendExtract captureCompereDefendExtract = new TCaptureCompereDefendExtract();
//				Long ccdeId = generateIdService
//						.generateId(TCaptureCompereDefendExtract.class
//								.getName());
//				captureCompereDefendExtract.setId(ccdeId);
//				captureCompereDefendExtract.setGiverId(giverId);
//				captureCompereDefendExtract.setRoomId(roomId);
//				captureCompereDefendExtract.setActivityTotalIncome(cost);
//				captureCompereDefendExtract.setPercentage(1F);
//				captureCompereDefendExtract.setExtractIncome(cost);
//				captureCompereDefendExtract.setActivityDate(nowDate);
//				captureCompereDefendExtractMapper
//						.insert(captureCompereDefendExtract);
//
//				// Long id =
//				// generateIdService.generateIdForList(TCaptureCompereDefendProfit.class.getName(),
//				// 6);
//				if (extractStrategy.getOperatorPercentage() != null) {
//					Long id = generateIdService.generateId();
//					BigDecimal extractPrice = this
//							.saveCaptureCompereDefendProfit(id, ccdeId,
//									compereRelation.getPrimaryAgentId(),
//									compereRelation.getOperatorId(),
//									Constants.USER_TYPE_OPERATOR, cost,
//									extractStrategy.getOperatorPercentage(),
//									extractStrategy.getOperatorCurrency(),
//									ratio);
//					secUserMapper.updateExtractJewelAmount(
//							compereRelation.getOperatorId(), extractPrice);
//				}
//				if (extractStrategy.getPrimaryAgentPercentage() != null) {
//					Long id = generateIdService.generateId();
//					BigDecimal extractPrice = this
//							.saveCaptureCompereDefendProfit(
//									id,
//									ccdeId,
//									compereRelation.getSecondaryAgentId(),
//									compereRelation.getPrimaryAgentId(),
//									Constants.USER_TYPE_PRIMARY_AGENT,
//									cost,
//									extractStrategy.getPrimaryAgentPercentage(),
//									extractStrategy.getPrimaryAgentCurrency(),
//									ratio);
//					secUserMapper.updateExtractJewelAmount(
//							compereRelation.getPrimaryAgentId(), extractPrice);
//				}
//				if (extractStrategy.getSecondaryAgentPercentage() != null) {
//					Long id = generateIdService.generateId();
//					BigDecimal extractPrice = this
//							.saveCaptureCompereDefendProfit(
//									id,
//									ccdeId,
//									compereRelation.getThirdlyAgentId(),
//									compereRelation.getSecondaryAgentId(),
//									Constants.USER_TYPE_SECONDARY_AGENT,
//									cost,
//									extractStrategy
//											.getSecondaryAgentPercentage(),
//									extractStrategy.getSecondaryAgentCurrency(),
//									ratio);
//					secUserMapper
//							.updateExtractJewelAmount(
//									compereRelation.getSecondaryAgentId(),
//									extractPrice);
//				}
//				if (extractStrategy.getThirdlyAgentPercentage() != null) {
//					Long id = generateIdService.generateId();
//					BigDecimal extractPrice = this
//							.saveCaptureCompereDefendProfit(
//									id,
//									ccdeId,
//									compereRelation.getManagerId(),
//									compereRelation.getThirdlyAgentId(),
//									Constants.USER_TYPE_THIRDLY_AGENT,
//									cost,
//									extractStrategy.getThirdlyAgentPercentage(),
//									extractStrategy.getThirdlyAgentCurrency(),
//									ratio);
//					secUserMapper.updateExtractJewelAmount(
//							compereRelation.getThirdlyAgentId(), extractPrice);
//				}
//				if (extractStrategy.getManagerPercentage() != null) {
//					Long id = generateIdService.generateId();
//					BigDecimal extractPrice = this
//							.saveCaptureCompereDefendProfit(id, ccdeId,
//									compereRelation.getCompereId(),
//									compereRelation.getManagerId(),
//									Constants.USER_TYPE_MANAGER, cost,
//									extractStrategy.getManagerPercentage(),
//									extractStrategy.getManagerCurrency(), ratio);
//					secUserMapper.updateExtractJewelAmount(
//							compereRelation.getManagerId(), extractPrice);
//				}
//				if (extractStrategy.getComperePercentage() != null) {
//					Long id = generateIdService.generateId();
//					compereAddPrice = this.saveCaptureCompereDefendProfit(id,
//							ccdeId, giverId, compereRelation.getCompereId(),
//							Constants.USER_TYPE_COMPERE, cost,
//							extractStrategy.getComperePercentage(),
//							extractStrategy.getCompereCurrency(), ratio)
//							.intValue();
//					String incomeDateStr = DateUtils.getParseDate(nowDate,
//							"yyyy-MM-dd");
//					int incomeCount = compereIncomeMapper
//							.addCaptureCompereDefendIncome(
//									compereRelation.getCompereId(),
//									compereAddPrice, nowDate, incomeDateStr);
//					if (incomeCount > 0) {
//						compereCacheController.addCaptureCompereDefendIncome(
//								compereRelation.getCompereId(), incomeDateStr,
//								compereAddPrice, cache);
//					}
//				}
//			} else {
//				throw new InfServerException(
//						Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR,
//						"没有查询到分成策略");
//			}
//		}
//
//		if (compereAddPrice > 0) {
//			if (!GameServerUtil.invokeUpdateCoin(receiverId, compereAddPrice)) {
//				throw new InfServerException(
//						Constants.RETURN_CODE_ACCOUNT_ERROR, "更新主播账户失败");
//			}
//		}
//
//	}
//
//	/**
//	 * 赎身卡分成
//	 *
//	 * @param giverId
//	 * @param cost
//	 * @param receiverId
//	 * @param roomId
//	 * @param nowDate
//	 * @param cache
//	 * @throws Exception
//	 */
//	public void captureCompereRansomExtract(Long giverId, int cost,
//			int cardCount, Long receiverId, Long roomId, Date nowDate,
//			ICache cache) throws Exception {
//		double ratio = 1;
//		String ratioStr = baseCacheController.queryConfig(
//				Constants.EXTRACT_COIN_EXCHANGE_RATIO, cache);
//		int compereAddPrice = 0;
//		int ownerAddPrice = 0;
//		Long ownerId = null;
//		if (StringUtils.isNotBlank(ratioStr)) {
//			ratio = Double.parseDouble(ratioStr);
//		}
//
//		CacheCompereRelation compereRelation = compereCacheController
//				.queryCompereRelation(receiverId, cache);
//		if (compereRelation != null) {
//			CacheExtractStrategyProfile extractStrategy = null;
//			CacheExtractStrategyProfile individuationExtractStrategy = baseCacheController
//					.queryTodayIndividuationExtractStrategiesByManagerId(
//							Constants.SOURCE_RANSOM,
//							compereRelation.getManagerId(), nowDate, cache);
//			if (individuationExtractStrategy != null) {
//				extractStrategy = individuationExtractStrategy;
//			} else {
//				extractStrategy = baseCacheController
//						.queryBaseExtractStrategiesBySource(
//								Constants.SOURCE_RANSOM, cache);
//			}
//
//			if (extractStrategy != null) {
//				TCaptureCompereRansomExtract captureCompereRansomExtract = new TCaptureCompereRansomExtract();
//				Long ccreId = generateIdService
//						.generateId(TCaptureCompereRansomExtract.class
//								.getName());
//				captureCompereRansomExtract.setId(ccreId);
//				captureCompereRansomExtract.setGiverId(giverId);
//				captureCompereRansomExtract.setCardCount(cardCount);
//				captureCompereRansomExtract.setRoomId(roomId);
//				captureCompereRansomExtract.setActivityTotalIncome(cost);
//				captureCompereRansomExtract.setPercentage(1F);
//				captureCompereRansomExtract.setExtractIncome(cost);
//				captureCompereRansomExtract.setActivityDate(nowDate);
//				captureCompereRansomExtractMapper
//						.insert(captureCompereRansomExtract);
//
//				// Long id =
//				// generateIdService.generateIdForList(TCaptureCompereRansomProfit.class.getName(),
//				// 7);
//				if (extractStrategy.getOperatorPercentage() != null) {
//					Long id = generateIdService.generateId();
//					BigDecimal extractPrice = this
//							.saveCaptureCompereRansomProfit(id, ccreId,
//									compereRelation.getPrimaryAgentId(),
//									compereRelation.getOperatorId(),
//									Constants.USER_TYPE_OPERATOR, cost,
//									extractStrategy.getOperatorPercentage(),
//									extractStrategy.getOperatorCurrency(),
//									ratio);
//					secUserMapper.updateExtractJewelAmount(
//							compereRelation.getOperatorId(), extractPrice);
//				}
//				if (extractStrategy.getPrimaryAgentPercentage() != null) {
//					Long id = generateIdService.generateId();
//					BigDecimal extractPrice = this
//							.saveCaptureCompereRansomProfit(
//									id,
//									ccreId,
//									compereRelation.getSecondaryAgentId(),
//									compereRelation.getPrimaryAgentId(),
//									Constants.USER_TYPE_PRIMARY_AGENT,
//									cost,
//									extractStrategy.getPrimaryAgentPercentage(),
//									extractStrategy.getPrimaryAgentCurrency(),
//									ratio);
//					secUserMapper.updateExtractJewelAmount(
//							compereRelation.getPrimaryAgentId(), extractPrice);
//				}
//				if (extractStrategy.getSecondaryAgentPercentage() != null) {
//					Long id = generateIdService.generateId();
//					BigDecimal extractPrice = this
//							.saveCaptureCompereRansomProfit(
//									id,
//									ccreId,
//									compereRelation.getThirdlyAgentId(),
//									compereRelation.getSecondaryAgentId(),
//									Constants.USER_TYPE_SECONDARY_AGENT,
//									cost,
//									extractStrategy
//											.getSecondaryAgentPercentage(),
//									extractStrategy.getSecondaryAgentCurrency(),
//									ratio);
//					secUserMapper
//							.updateExtractJewelAmount(
//									compereRelation.getSecondaryAgentId(),
//									extractPrice);
//				}
//				if (extractStrategy.getThirdlyAgentPercentage() != null) {
//					Long id = generateIdService.generateId();
//					BigDecimal extractPrice = this
//							.saveCaptureCompereRansomProfit(
//									id,
//									ccreId,
//									compereRelation.getManagerId(),
//									compereRelation.getThirdlyAgentId(),
//									Constants.USER_TYPE_THIRDLY_AGENT,
//									cost,
//									extractStrategy.getThirdlyAgentPercentage(),
//									extractStrategy.getThirdlyAgentCurrency(),
//									ratio);
//					secUserMapper.updateExtractJewelAmount(
//							compereRelation.getThirdlyAgentId(), extractPrice);
//				}
//				if (extractStrategy.getManagerPercentage() != null) {
//					Long id = generateIdService.generateId();
//					BigDecimal extractPrice = this
//							.saveCaptureCompereRansomProfit(id, ccreId,
//									compereRelation.getCompereId(),
//									compereRelation.getManagerId(),
//									Constants.USER_TYPE_MANAGER, cost,
//									extractStrategy.getManagerPercentage(),
//									extractStrategy.getManagerCurrency(), ratio);
//					secUserMapper.updateExtractJewelAmount(
//							compereRelation.getManagerId(), extractPrice);
//				}
//				if (extractStrategy.getComperePercentage() != null) {
//					Long id = generateIdService.generateId();
//					compereAddPrice = this.saveCaptureCompereRansomProfit(id,
//							ccreId, giverId, compereRelation.getCompereId(),
//							Constants.USER_TYPE_COMPERE, cost,
//							extractStrategy.getComperePercentage(),
//							extractStrategy.getCompereCurrency(), ratio)
//							.intValue();
//					String incomeDateStr = DateUtils.getParseDate(nowDate,
//							"yyyy-MM-dd");
//					int incomeCount = compereIncomeMapper
//							.addCaptureCompereDefendIncome(
//									compereRelation.getCompereId(),
//									compereAddPrice, nowDate, incomeDateStr);
//					if (incomeCount > 0) {
//						compereCacheController.addCaptureCompereDefendIncome(
//								compereRelation.getCompereId(), incomeDateStr,
//								compereAddPrice, cache);
//					}
//				}
//				if (extractStrategy.getUserPercentage() != null) {
//					Long id = generateIdService.generateId();
//					CacheCompereProfile compere = compereCacheController
//							.getCompereDetail(receiverId.toString(), cache,
//									false, false);
//					if (compere != null && compere.getOwnerId() != null) {
//						ownerId = compere.getOwnerId();
//						ownerAddPrice = this.saveCaptureCompereRansomProfit(id,
//								ccreId, receiverId, ownerId,
//								Constants.USER_TYPE_USER, cost,
//								extractStrategy.getUserPercentage(),
//								extractStrategy.getUserCurrency(), ratio)
//								.intValue();
//					}
//				}
//
//			} else {
//				throw new InfServerException(
//						Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR,
//						"没有查询到分成策略");
//			}
//		}
//
//		if (compereAddPrice > 0) {
//			if (!GameServerUtil.invokeUpdateCoin(receiverId, compereAddPrice)) {
//				throw new InfServerException(
//						Constants.RETURN_CODE_ACCOUNT_ERROR, "更新主播账户失败");
//			}
//		}
//
//		if (ownerAddPrice > 0) {
//			if (!GameServerUtil.invokeUpdateCoin(ownerId, ownerAddPrice)) {
//				throw new InfServerException(
//						Constants.RETURN_CODE_ACCOUNT_ERROR, "更新主播所属玩家账户失败");
//			}
//		}
//	}
//
//	/**
//	 * 组局分成
//	 *
//	 * @param activityId
//	 * @param userId
//	 * @param userType
//	 * @param nowDate
//	 * @param cache
//	 * @throws Exception
//	 */
//	public void freeGameExtract(Long activityId, Long userId, String userType,
//			Integer extractIncome, Integer totalIncome, Date nowDate,
//			ICache cache) throws Exception {
//		double ratio = 1;
//		String ratioStr = baseCacheController.queryConfig(
//				Constants.EXTRACT_COIN_EXCHANGE_RATIO, cache);
//		int compereAddPrice = 0;
//		if (StringUtils.isNotBlank(ratioStr)) {
//			ratio = Double.parseDouble(ratioStr);
//		}
//
//		CacheUserRelation userRelation = null;
//		if (Constants.USER_TYPE_P.equalsIgnoreCase(userType)) {
//			userRelation = playerCacheController.queryPlayerRelation(userId,
//					cache);
//		} else {
//			userRelation = compereCacheController.queryCompereRelation(userId,
//					cache);
//		}
//
//		if (userRelation != null) {
//			CacheExtractStrategyProfile extractStrategy = null;
//			CacheExtractStrategyProfile individuationExtractStrategy = baseCacheController
//					.queryTodayIndividuationExtractStrategiesByManagerId(
//							Constants.SOURCE_FREE_GAME,
//							userRelation.getManagerId(), nowDate, cache);
//			if (individuationExtractStrategy != null) {
//				extractStrategy = individuationExtractStrategy;
//			} else {
//				extractStrategy = baseCacheController
//						.queryBaseExtractStrategiesBySource(
//								Constants.SOURCE_FREE_GAME, cache);
//			}
//
//			if (extractStrategy != null) {
//				float percentage = ((float) extractIncome) / totalIncome;
//				// int totalIncome = (int) (extractIncome / percentage);
//
//				TFreeGameExtract freeGameExtract = new TFreeGameExtract();
//				Long id = generateIdService.generateId();
//				freeGameExtract.setId(id);
//				freeGameExtract.setGiverId(userId);
//				freeGameExtract.setActivityId(activityId);
//				freeGameExtract.setActivityTotalIncome(totalIncome);
//				freeGameExtract.setPercentage(percentage);
//				freeGameExtract.setExtractIncome(extractIncome);
//				freeGameExtract.setActivityDate(nowDate);
//				Long fgeId = freeGameExtractMapper
//						.insertFreeGameExtract(freeGameExtract);
//
//				if (extractStrategy.getOperatorPercentage() != null) {
//					BigDecimal extractPrice = this.saveFreeGameProfit(fgeId,
//							userRelation.getPrimaryAgentId(),
//							userRelation.getOperatorId(),
//							Constants.USER_TYPE_OPERATOR, totalIncome,
//							extractStrategy.getOperatorPercentage(),
//							extractStrategy.getOperatorCurrency(), ratio);
//					secUserMapper.updateExtractJewelAmount(
//							userRelation.getOperatorId(), extractPrice);
//				}
//				if (extractStrategy.getPrimaryAgentPercentage() != null) {
//					BigDecimal extractPrice = this.saveFreeGameProfit(fgeId,
//							userRelation.getSecondaryAgentId(),
//							userRelation.getPrimaryAgentId(),
//							Constants.USER_TYPE_PRIMARY_AGENT, totalIncome,
//							extractStrategy.getPrimaryAgentPercentage(),
//							extractStrategy.getPrimaryAgentCurrency(), ratio);
//					secUserMapper.updateExtractJewelAmount(
//							userRelation.getPrimaryAgentId(), extractPrice);
//				}
//				if (extractStrategy.getSecondaryAgentPercentage() != null) {
//					BigDecimal extractPrice = this.saveFreeGameProfit(fgeId,
//							userRelation.getThirdlyAgentId(),
//							userRelation.getSecondaryAgentId(),
//							Constants.USER_TYPE_SECONDARY_AGENT, totalIncome,
//							extractStrategy.getSecondaryAgentPercentage(),
//							extractStrategy.getSecondaryAgentCurrency(), ratio);
//					secUserMapper.updateExtractJewelAmount(
//							userRelation.getSecondaryAgentId(), extractPrice);
//				}
//				if (extractStrategy.getThirdlyAgentPercentage() != null) {
//					BigDecimal extractPrice = this.saveFreeGameProfit(fgeId,
//							userRelation.getManagerId(),
//							userRelation.getThirdlyAgentId(),
//							Constants.USER_TYPE_THIRDLY_AGENT, totalIncome,
//							extractStrategy.getThirdlyAgentPercentage(),
//							extractStrategy.getThirdlyAgentCurrency(), ratio);
//					secUserMapper.updateExtractJewelAmount(
//							userRelation.getThirdlyAgentId(), extractPrice);
//				}
//				if (extractStrategy.getManagerPercentage() != null) {
//					BigDecimal extractPrice = this.saveFreeGameProfit(fgeId,
//							userRelation.getCompereId(),
//							userRelation.getManagerId(),
//							Constants.USER_TYPE_MANAGER, totalIncome,
//							extractStrategy.getManagerPercentage(),
//							extractStrategy.getManagerCurrency(), ratio);
//					secUserMapper.updateExtractJewelAmount(
//							userRelation.getManagerId(), extractPrice);
//				}
//				if (Constants.USER_TYPE_P.equalsIgnoreCase(userType)) {
//					if (extractStrategy.getComperePercentage() != null) {
//						compereAddPrice = this.saveFreeGameProfit(fgeId,
//								userId, userRelation.getCompereId(),
//								Constants.USER_TYPE_COMPERE, totalIncome,
//								extractStrategy.getComperePercentage(),
//								extractStrategy.getCompereCurrency(), ratio)
//								.intValue();
//						if (compereAddPrice > 0) {
//							String incomeDateStr = DateUtils.getParseDate(
//									nowDate, "yyyy-MM-dd");
//							int incomeCount = compereIncomeMapper
//									.addGameMatchExtractIncome(
//											userRelation.getCompereId(),
//											compereAddPrice, nowDate,
//											incomeDateStr);
//
//							boolean isUpdateSuccess = GameServerUtil
//									.invokeUpdateCoin(
//											userRelation.getCompereId(),
//											compereAddPrice);
//							if (!isUpdateSuccess) {
//								throw new InfServerException(
//										Constants.RETURN_CODE_ACCOUNT_ERROR,
//										"更新主播账户失败");
//							}
//
//							if (incomeCount > 0) {
//								compereCacheController
//										.addGameMatchExtractIncome(
//												userRelation.getCompereId(),
//												incomeDateStr, compereAddPrice,
//												cache);
//							}
//						}
//					}
//				}
//			} else {
//				throw new InfServerException(
//						Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR,
//						"没有查询到分成策略");
//			}
//		}
//
//	}
//
//	/**
//	 * 保存游戏比赛分成明细
//	 *
//	 * @param id
//	 * @param gameMatchExtractId
//	 * @param receiverId
//	 * @param receiverType
//	 * @param cost
//	 * @param percentage
//	 * @param currency
//	 * @param ratio
//	 * @return
//	 */
//	private BigDecimal saveGameMatchProfit(Long id, Long gameMatchExtractId,
//			Long contributoryId, Long receiverId, String receiverType,
//			int cost, Double percentage, String currency, double ratio) {
//		BigDecimal income = null;
//		TGameMatchProfit gameMatchProfit = new TGameMatchProfit();
//		gameMatchProfit.setId(id);
//		gameMatchProfit.setGameMatchExtractId(gameMatchExtractId);
//		gameMatchProfit.setContributoryId(contributoryId);
//		BigDecimal bigDecimal = new BigDecimal(cost * percentage);
//		if (Constants.CURRENCY_JEWEL.equals(currency)) {
//			income = bigDecimal.multiply(new BigDecimal(ratio)).divide(
//					new BigDecimal(100));
//		} else {
//			income = bigDecimal.divide(new BigDecimal(100));
//		}
//		gameMatchProfit.setIncome(income);
//		gameMatchProfit.setReceiverId(receiverId);
//		gameMatchProfit.setReceiverType(receiverType);
//		gameMatchProfitMapper.insert(gameMatchProfit);
//		return income;
//	}
//
//	/**
//	 * 保存直播间游戏分成明细
//	 *
//	 * @param id
//	 * @param liveRoomGameExtractId
//	 * @param receiverId
//	 * @param receiverType
//	 * @param cost
//	 * @param percentage
//	 * @param currency
//	 * @param ratio
//	 * @return
//	 */
//	private BigDecimal saveLiveRoomGameProfit(Long id,
//			Long liveRoomGameExtractId, Long contributoryId, Long receiverId,
//			String receiverType, int cost, Double percentage, String currency,
//			double ratio) {
//		BigDecimal income = null;
//		TLiveRoomGameProfit liveRoomGameProfit = new TLiveRoomGameProfit();
//		liveRoomGameProfit.setId(id);
//		liveRoomGameProfit.setLiveRoomGameExtractId(liveRoomGameExtractId);
//		liveRoomGameProfit.setContributoryId(contributoryId);
//
//		BigDecimal bigDecimal = new BigDecimal(cost * percentage);
//		if (Constants.CURRENCY_JEWEL.equals(currency)) {
//			income = bigDecimal.multiply(new BigDecimal(ratio)).divide(
//					new BigDecimal(100));
//		} else {
//			income = bigDecimal.divide(new BigDecimal(100));
//		}
//		liveRoomGameProfit.setIncome(income);
//		liveRoomGameProfit.setReceiverId(receiverId);
//		liveRoomGameProfit.setReceiverType(receiverType);
//		liveRoomGameProfitMapper.insert(liveRoomGameProfit);
//		return income;
//	}
//
//	/**
//	 * 保存直播间礼物分成明细
//	 *
//	 * @param liveRoomGiftExtractId
//	 * @param contributoryId
//	 * @param receiverId
//	 * @param receiverType
//	 * @param cost
//	 * @param percentage
//	 * @param currency
//	 * @param ratio
//	 * @return
//	 */
//	private BigDecimal saveLiveRoomGiftProfit(Long id,
//			Long liveRoomGiftExtractId, Long contributoryId, Long receiverId,
//			String receiverType, int cost, Double percentage, String currency,
//			double ratio, List<CacheDatabaseObject> insertList) {
//		BigDecimal income = null;
//		TLiveRoomGiftProfit liveRoomGiftProfit = new TLiveRoomGiftProfit();
//		liveRoomGiftProfit.setId(id);
//		liveRoomGiftProfit.setLiveRoomGiftExtractId(liveRoomGiftExtractId);
//		liveRoomGiftProfit.setContributoryId(contributoryId);
//		BigDecimal bigDecimal = new BigDecimal(cost * percentage);
//		if (Constants.CURRENCY_JEWEL.equals(currency)) {
//			income = bigDecimal.multiply(new BigDecimal(ratio)).divide(
//					new BigDecimal(100));
//		} else {
//			income = bigDecimal.divide(new BigDecimal(100));
//		}
//		liveRoomGiftProfit.setIncome(income);
//		liveRoomGiftProfit.setReceiverId(receiverId);
//		liveRoomGiftProfit.setReceiverType(receiverType);
//		// liveRoomGiftProfitMapper.insert(liveRoomGiftProfit);
//		CacheDatabaseObject liveRoomGiftProfitObj = new CacheDatabaseObject();
//		liveRoomGiftProfitObj.setControlType("insert:T_LIVE_ROOM_GIFT_PROFIT");
//		liveRoomGiftProfitObj.setData(liveRoomGiftProfit);
//
//		insertList.add(liveRoomGiftProfitObj);
//		return income;
//	}
//
//	/**
//	 * 保存夺宝分成明细
//	 *
//	 * @param liveRoomGiftExtractId
//	 * @param contributoryId
//	 * @param receiverId
//	 * @param receiverType
//	 * @param cost
//	 * @param percentage
//	 * @param currency
//	 * @param ratio
//	 * @return
//	 */
//	private BigDecimal saveIndianaProfit(Long id, Long indianaExtractId,
//			Long receiverId, String receiverType, int cost, Double percentage,
//			String currency, double ratio, List<CacheDatabaseObject> insertList) {
//		BigDecimal income = null;
//		TOnlineTreasureProfit indianaProfit = new TOnlineTreasureProfit();
//		indianaProfit.setId(id);
//		indianaProfit.setExtractId(indianaExtractId);
//		BigDecimal bigDecimal = new BigDecimal(cost * percentage);
//		if (Constants.CURRENCY_JEWEL.equals(currency)) {
//			income = bigDecimal.multiply(new BigDecimal(ratio)).divide(
//					new BigDecimal(100));
//		} else {
//			income = bigDecimal.divide(new BigDecimal(100));
//		}
//		indianaProfit.setIncome(income);
//		indianaProfit.setReceiverId(receiverId);
//		indianaProfit.setReceiverType(receiverType);
//		CacheDatabaseObject indianaProfitObj = new CacheDatabaseObject();
//		indianaProfitObj.setControlType("insert:T_ONLINE_TREASURE_PROFIT");
//		indianaProfitObj.setData(indianaProfit);
//
//		insertList.add(indianaProfitObj);
//		return income;
//	}
//
//	/**
//	 * 保存约饭分成明细
//	 *
//	 * @param id
//	 * @param datingActivityExtractId
//	 * @param contributoryId
//	 * @param receiverId
//	 * @param receiverType
//	 * @param cost
//	 * @param percentage
//	 * @param currency
//	 * @param ratio
//	 * @return
//	 */
//	private BigDecimal saveDatingActivityProfit(Long id,
//			Long datingActivityExtractId, Long contributoryId, Long receiverId,
//			String receiverType, int cost, Double percentage, String currency,
//			double ratio) {
//		BigDecimal income = null;
//		TDatingActivityProfit datingActivityProfit = new TDatingActivityProfit();
//		datingActivityProfit.setId(id);
//		datingActivityProfit
//				.setDatingActivityExtractId(datingActivityExtractId);
//		datingActivityProfit.setContributoryId(contributoryId);
//
//		BigDecimal bigDecimal = new BigDecimal(cost * percentage);
//		if (Constants.CURRENCY_JEWEL.equals(currency)) {
//			income = bigDecimal.multiply(new BigDecimal(ratio)).divide(
//					new BigDecimal(100));
//		} else {
//			income = bigDecimal.divide(new BigDecimal(100));
//		}
//		datingActivityProfit.setIncome(income);
//		datingActivityProfit.setReceiverId(receiverId);
//		datingActivityProfit.setReceiverType(receiverType);
//		datingActivityProfitMapper.insert(datingActivityProfit);
//		return income;
//	}
//
//	/**
//	 * 保存保护分成明细
//	 *
//	 * @param id
//	 * @param defendExtractId
//	 * @param receiverId
//	 * @param receiverType
//	 * @param cost
//	 * @param percentage
//	 * @param currency
//	 * @param ratio
//	 * @return
//	 */
//	private BigDecimal saveCaptureCompereDefendProfit(Long id,
//			Long defendExtractId, Long contributoryId, Long receiverId,
//			String receiverType, int cost, Double percentage, String currency,
//			double ratio) {
//		BigDecimal income = null;
//		TCaptureCompereDefendProfit captureCompereDefendProfit = new TCaptureCompereDefendProfit();
//		captureCompereDefendProfit.setId(id);
//		captureCompereDefendProfit.setDefendExtractId(defendExtractId);
//		captureCompereDefendProfit.setContributoryId(contributoryId);
//
//		BigDecimal bigDecimal = new BigDecimal(cost * percentage);
//		if (Constants.CURRENCY_JEWEL.equals(currency)) {
//			income = bigDecimal.multiply(new BigDecimal(ratio)).divide(
//					new BigDecimal(100));
//		} else {
//			income = bigDecimal.divide(new BigDecimal(100));
//		}
//		captureCompereDefendProfit.setIncome(income);
//		captureCompereDefendProfit.setReceiverId(receiverId);
//		captureCompereDefendProfit.setReceiverType(receiverType);
//		captureCompereDefendProfitMapper.insert(captureCompereDefendProfit);
//		return income;
//	}
//
//	/**
//	 * 保存赎身卡分成明细
//	 *
//	 * @param id
//	 * @param ransomExtractId
//	 * @param receiverId
//	 * @param receiverType
//	 * @param cost
//	 * @param percentage
//	 * @param currency
//	 * @param ratio
//	 * @return
//	 */
//	private BigDecimal saveCaptureCompereRansomProfit(Long id,
//			Long ransomExtractId, Long contributoryId, Long receiverId,
//			String receiverType, int cost, Double percentage, String currency,
//			double ratio) {
//		BigDecimal income = null;
//		TCaptureCompereRansomProfit captureCompereRansomProfit = new TCaptureCompereRansomProfit();
//		captureCompereRansomProfit.setId(id);
//		captureCompereRansomProfit.setRansomExtractId(ransomExtractId);
//		captureCompereRansomProfit.setContributoryId(contributoryId);
//
//		BigDecimal bigDecimal = new BigDecimal(cost * percentage);
//		if (Constants.CURRENCY_JEWEL.equals(currency)) {
//			income = bigDecimal.multiply(new BigDecimal(ratio)).divide(
//					new BigDecimal(100));
//		} else {
//			income = bigDecimal.divide(new BigDecimal(100));
//		}
//		captureCompereRansomProfit.setIncome(income);
//		captureCompereRansomProfit.setReceiverId(receiverId);
//		captureCompereRansomProfit.setReceiverType(receiverType);
//		captureCompereRansomProfitMapper.insert(captureCompereRansomProfit);
//		return income;
//	}
//
//	/**
//	 * 保存组局分成明细
//	 *
//	 * @param freeGameExtractId
//	 * @param contributoryId
//	 * @param receiverId
//	 * @param receiverType
//	 * @param cost
//	 * @param percentage
//	 * @param currency
//	 * @param ratio
//	 * @return
//	 */
//	private BigDecimal saveFreeGameProfit(Long freeGameExtractId,
//			Long contributoryId, Long receiverId, String receiverType,
//			int cost, Double percentage, String currency, double ratio) {
//		BigDecimal income = null;
//		Long id = generateIdService.generateId();
//		TFreeGameProfit freeGameProfit = new TFreeGameProfit();
//		freeGameProfit.setId(id);
//		freeGameProfit.setFreeGameExtractId(freeGameExtractId);
//		freeGameProfit.setContributoryId(contributoryId);
//		BigDecimal bigDecimal = new BigDecimal(cost * percentage);
//		if (Constants.CURRENCY_JEWEL.equals(currency)) {
//			income = bigDecimal.multiply(new BigDecimal(ratio)).divide(
//					new BigDecimal(100));
//		} else {
//			income = bigDecimal.divide(new BigDecimal(100));
//		}
//		freeGameProfit.setIncome(income);
//		freeGameProfit.setReceiverId(receiverId);
//		freeGameProfit.setReceiverType(receiverType);
//		freeGameProfitMapper.insert(freeGameProfit);
//		return income;
//	}
//}
