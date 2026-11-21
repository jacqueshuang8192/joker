//package com.hbi.service.common;
//
//import com.alibaba.fastjson.JSONObject;
//import com.core.util.DateUtils;
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.BaseCacheController;
//import com.hbi.cache.controller.CommonCacheController;
//import com.hbi.cache.controller.CompereCacheController;
//import com.hbi.cache.controller.PlayerCacheController;
//import com.hbi.cache.model.*;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.*;
//import com.hbi.model.*;
//import com.hbi.schedule.model.ScheduleJob;
//import com.hbi.schedule.service.DynamicScheduleService;
//import com.hbi.service.helper.VipValidator;
//import com.hbi.service.idGenerate.GenerateIdService;
//import com.hbi.utils.InfServerException;
//import com.hbi.utils.JPushUtil;
//import com.hbi.vo.response.datingActivity.DatingActivityRecord;
//import org.apache.commons.collections.CollectionUtils;
//import org.apache.commons.lang.StringUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import java.util.ArrayList;
//import java.util.Calendar;
//import java.util.Date;
//import java.util.List;
//
//@Service
//public class DatingService {
//
//    @Autowired
//    private TDatingActivityMapper datingActivityMapper;
//    @Autowired
//    private TDatingAuctionRecordMapper datingAuctionRecordMapper;
//    @Autowired
//    private TUserGoodsMapper userGoodsMapper;
//    @Autowired
//    private TUserGoodsUseRecordMapper userGoodsUseRecordMapper;
//    @Autowired
//    private TUserMapper userMapper;
//    @Autowired
//    private CompereCacheController compereCacheController;
//    @Autowired
//    private CommonCacheController commonCacheController;
//    @Autowired
//    private PlayerCacheController playerCacheController;
//    @Autowired
//    private BaseCacheController baseCacheController;
//
//    @Autowired
//    private GenerateIdService generateIdService;
//
//    @Autowired
//    private DynamicScheduleService dynamicScheduleService;
//    @Autowired
//    private ExtractService extractService;
//    @Autowired
//    private VipValidator vipValidator;
//
//    /**
//     * 新增约饭活动
//     *
//     * @param datingActivity
//     * @throws Exception
//     */
//    public void createDatingActivity(TDatingActivity datingActivity) throws Exception {
//        ICache cache = null;
//        String chatroomId = null;
//        try {
//            cache = CacheManager.getCache();
//            CacheUserProfile user = null;
//            if (Constants.USER_TYPE_P.equalsIgnoreCase(datingActivity.getUserType())) {
//                user = playerCacheController.queryPlayerDetail(datingActivity.getUserId(), cache, false, false);
//                if(!vipValidator.canCreateDating(user, cache)) {
//                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "VIP等级权限不够！");
//                }
//            } else {
//                user = compereCacheController.getCompereDetail(datingActivity.getUserId().toString(), cache, false, false);
//            }
//            if (user == null) {
//                throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到相关用户记录");
//            }
//
//            // 同一时间段不能创建多个约饭活动
//            String nowDateStr = DateUtils.getParseDate(datingActivity.getTime(), "yyyy-MM-dd");
//            int activityCount = datingActivityMapper.queryDatingActivityCountByUserIdAndPeriod(
//                    datingActivity.getUserId(), datingActivity.getPeriod(), nowDateStr, nowDateStr + " 23:59:59");
//            if (activityCount == 0) {
//                Long id = generateIdService.generateId(TDatingActivity.class.getName());
//                datingActivity.setId(id);
//                datingActivity.setHighestAuctionCount(datingActivity.getAuctionCount());
//                datingActivity.setTotalAuctionNum(0);
//                datingActivity.setIsEvaluation(0);
//                datingActivity.setEndType("");
////                chatroomId = easeMobService.createChatRoom(user.getPhone());
//                datingActivity.setChatroomId(chatroomId);
//
//                TGoodsCategory goodsCategory = baseCacheController.queryCategoryById(datingActivity.getCategoryId(),
//                        cache);
//                if (goodsCategory != null) {
//                    datingActivity.setCategoryName(goodsCategory.getName());
//                }
//                int count = datingActivityMapper.insert(datingActivity);
//                if (count == 1) {
//                    ScheduleJob scheduleJob = new ScheduleJob();
//                    scheduleJob.setJobId(id.toString());
//                    scheduleJob.setJobGroup("datingActivity");
//                    /**
//                     * 时间转换
//                     */
//                    Calendar calendar = Calendar.getInstance();
//                    calendar.setTime(datingActivity.getTime());
//                    calendar.add(Calendar.MINUTE, -30);
//                    String cronExpression = calendar.get(Calendar.SECOND) + " " + calendar.get(Calendar.MINUTE) + " "
//                            + calendar.get(Calendar.HOUR_OF_DAY) + " " + calendar.get(Calendar.DAY_OF_MONTH) + " "
//                            + (calendar.get(Calendar.MONTH) + 1) + " ? " + calendar.get(Calendar.YEAR);
//
//                    scheduleJob.setCronExpression(cronExpression);
//                    scheduleJob.setBeanName("datingActivityScheduleService");
//                    scheduleJob.setMethodType(1);
//                    scheduleJob.setData(id.toString());
//                    scheduleJob.setEndDate(calendar.getTime());
//                    dynamicScheduleService.enableSchedule(scheduleJob);
//
//                    commonCacheController.addCacheDatingActivity(datingActivity, user, cache);
//                } else {
//                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "保存约饭活动失败");
//                }
//
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "同一时间段不能创建多个活动");
//            }
//        } catch (Exception e) {
//            if (StringUtils.isNotBlank(chatroomId)) {
////                easeMobService.deleteChatRoom(chatroomId);
//            }
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    /**
//     * 查询附近约饭
//     *
//     * @param cityId
//     * @return
//     */
//    public List<CacheDatingActivityListProfile> queryDatingActivitiesNearby(String cityId) throws Exception {
//        List<CacheDatingActivityListProfile> datingActivities = null;
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            datingActivities = commonCacheController.findDatingActivitiesByCityId(cityId, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//        return datingActivities;
//    }
//
//    /**
//     * 查询用户活动
//     *
//     * @param userId
//     * @return
//     */
//    public DatingActivityRecord queryDatingActivitiesByUserId(Long userId) throws Exception {
//        DatingActivityRecord datingActivityRecord = new DatingActivityRecord();
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<CacheDatingActivityListProfile> datingActivities = commonCacheController.findUserDatingActivity(userId,
//                    cache);
//            datingActivityRecord.setDatingActivities(datingActivities);
//            List<CacheDatingAuctionRecordProfile> auctionRecords = commonCacheController
//                    .findDatingAuctionRecords(userId, cache);
//            datingActivityRecord.setAuctionRecords(auctionRecords);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//        return datingActivityRecord;
//    }
//
//    /**
//     * 获取约饭活动详情
//     *
//     * @param activityId
//     * @return
//     * @throws Exception
//     */
//    public CacheDatingActivityProfile queryDatingActivityDetailByActivityId(Long activityId) throws Exception {
//        CacheDatingActivityProfile datingActivity = null;
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            datingActivity = commonCacheController.findDatingActivityDetail(activityId, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//        return datingActivity;
//    }
//
//    /**
//     * 查询我的约饭道具
//     *
//     * @param userId
//     * @return
//     */
//    public List<TUserGoods> queryMyDatingGoods(long userId) throws Exception {
//        List<TUserGoods> userGoods = null;
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            userGoods = commonCacheController.queryUserGoodsByUserId(userId, Constants.GOODS_TYPE_DATING_PROP, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//        return userGoods;
//    }
//
//    /**
//     * 申请约饭竞价
//     *
//     * @param activityId
//     * @param auctionUserId
//     * @param categoryId
//     * @param auctionCount
//     * @throws Exception
//     */
//    public void applyDatingAuction(Long activityId, Long auctionUserId, Long categoryId, int auctionCount)
//            throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TUserGoods ug = null;
//            // 判断背包
//            TUserGoods temp = new TUserGoods();
//            temp.setUserId(auctionUserId);
//            List<TUserGoods> userGoods = userGoodsMapper.select(temp);
//            if (CollectionUtils.isNotEmpty(userGoods)) {
//                ug = userGoods.get(0);
//                if (ug.getAmount() < auctionCount) {
//                    throw new InfServerException(Constants.RETURN_CODE_LACK_OF_PROP, "用户约饭道具不足");
//                }
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_LACK_OF_PROP, "用户约饭道具不足");
//            }
//
//            Date nowDate = new Date();
//            int count = datingActivityMapper.updateDatingActivityAuction(activityId, auctionUserId, auctionCount,
//                    DateUtils.getParseDate(nowDate, "yyyy-MM-dd HH:mm:ss"));
//            if (count > 0) {
//
//                TDatingAuctionRecord darTemp = new TDatingAuctionRecord();
//                darTemp.setDatingActivityId(activityId);
//                darTemp.setStatus(Constants.RECORD_IN_AUCTION);
//                List<TDatingAuctionRecord> auctionRecords = datingAuctionRecordMapper.select(darTemp);
//
//                TDatingAuctionRecord datingAuctionRecord = new TDatingAuctionRecord();
//                Long darId = generateIdService.generateId(TDatingAuctionRecord.class.getName());
//                datingAuctionRecord.setId(darId);
//                datingAuctionRecord.setAuctionUserId(auctionUserId);
//                datingAuctionRecord.setDatingActivityId(activityId);
//                datingAuctionRecord.setCategoryId(categoryId);
//                datingAuctionRecord.setAuctionCount(auctionCount);
//                datingAuctionRecord.setStatus(Constants.RECORD_IN_AUCTION);
//                datingAuctionRecord.setLastAuctionDate(nowDate);
//                if(datingAuctionRecordMapper.insert(datingAuctionRecord) > 0) {
//                    commonCacheController.updateAuctionRank(activityId, datingAuctionRecord, cache);
//                }
//
//                // 更新道具背包
//                int reducePrice = ug.getTotalPrice() / ug.getAmount() * auctionCount;
//                ug.setAmount(auctionCount);
//                ug.setTotalPrice(reducePrice);
//                userGoodsMapper.reduceUserGoodsAmount(ug);
//                commonCacheController.reduceGoods(ug, cache);
//                List<String> toUserNames = new ArrayList<String>();
//                // 返还原有竞技者的道具
//                if (CollectionUtils.isNotEmpty(auctionRecords)) {
//                    for (TDatingAuctionRecord dar : auctionRecords) {
//                        dar.setStatus(Constants.RECORD_INVALID);
//                        Long oldUserId = dar.getAuctionUserId();
//                        temp.setUserId(oldUserId);
//                        List<TUserGoods> oldUserGoods = userGoodsMapper.select(temp);
//                        if (CollectionUtils.isNotEmpty(oldUserGoods)) {
//                            TUserGoods oldUg = oldUserGoods.get(0);
//                            int addPrice = oldUg.getUnitPrice() * dar.getAuctionCount();
//                            oldUg.setAmount(dar.getAuctionCount());
//                            oldUg.setTotalPrice(addPrice);
//                            userGoodsMapper.addUserGoodsAmount(oldUg);
//                            commonCacheController.addGoods(oldUg, cache);
//                        }
//                        TDatingAuctionRecord dt = new TDatingAuctionRecord();
//                        dt.setId(dar.getId());
//                        dt.setStatus(Constants.RECORD_INVALID);
//                        datingAuctionRecordMapper.updateByPrimaryKeySelective(dt);
//                    }
//
//                    for (TDatingAuctionRecord dar : auctionRecords) {
//                        CachePlayerProfile player = playerCacheController.queryPlayerDetail(dar.getAuctionUserId(),
//                                cache, false, false);
//                        toUserNames.add(player.getPhone());
//                        commonCacheController.addOrUpdateCacheDatingAuctionRecord(dar, cache);
//                    }
//                }
//
//                TDatingActivity datingActivity = datingActivityMapper.selectByPrimaryKey(activityId);
//                datingActivity.setHighestAuctionUserId(auctionUserId);
//                datingActivity.setHighestAuctionCount(auctionCount);
//                datingActivity.setLastAuctionDate(nowDate);
//                CacheUserProfile user = null;
//                if (Constants.USER_TYPE_P.equalsIgnoreCase(datingActivity.getUserType())) {
//                    user = playerCacheController.queryPlayerDetail(datingActivity.getUserId(), cache, false, false);
//                } else {
//                    user = compereCacheController.getCompereDetail(datingActivity.getUserId().toString(), cache, false, false);
//                }
//                if (user != null) {
//                    commonCacheController.applyDatingActivity(datingActivity, user, cache);
//                } else {
//                    throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到约饭发起人相关记录");
//                }
//
//                // 更新旧的记录
//                if (CollectionUtils.isNotEmpty(auctionRecords)) {
//                    commonCacheController.addOrUpdateCacheDatingAuctionRecord(auctionRecords.get(0), cache);
//                }
//                // 添加新的记录
//                commonCacheController.addOrUpdateCacheDatingAuctionRecord(datingAuctionRecord, cache);
//
//                // 发消息通知
////                easeMobService.datingStatusChanged((String[]) toUserNames.toArray(new String[toUserNames.size()]));
////                easeMobService.datingAuctionCountChanged(datingActivity.getChatroomId());
//            } else {
//                TDatingActivity datingActivity = datingActivityMapper.selectByPrimaryKey(activityId);
//                if (datingActivity != null) {
//                    if (datingActivity.getTime().before(nowDate)
//                            || !Constants.DATING_STATUS_IN_AUCTION.equals(datingActivity.getStatus())) {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "约饭活动已结束");
//                    } else if (datingActivity.getAuctionCount() > auctionCount) {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "约饭竞价饭卡数量低于起拍竞价");
//                    } else if (datingActivity.getHighestAuctionCount() >= auctionCount) {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "约饭竞价饭卡数量低于当前最高竞价");
//                    } else if (datingActivity.getUserId().equals(auctionUserId)) {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "不能竞价自己发起的约饭活动");
//                    } else {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "未知错误，更新约饭活动失败");
//                    }
//                } else {
//                    throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到约饭活动记录");
//                }
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//
//    }
//
//    /**
//     * 关闭约饭活动
//     *
//     * @param datingActivityId
//     * @throws Exception
//     */
//    public void closeDatingActivity(Long datingActivityId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TDatingActivity datingActivity = datingActivityMapper.selectByPrimaryKey(datingActivityId);
//            if (datingActivity != null) {
//                if (datingActivity.getHighestAuctionUserId() != null) {
//                    datingActivity.setStatus(Constants.DATING_STATUS_AUCTION_CLOSED);
//                    datingActivityMapper.updateByPrimaryKeySelective(datingActivity);
//
//                    if (datingActivity.getHighestAuctionUserId() != null) {
//                        int count = datingAuctionRecordMapper.modifyBidWinnerRecord(datingActivityId,
//                                datingActivity.getHighestAuctionUserId());
//                        if (count == 0) {
//                            throw new InfServerException(Constants.RETURN_CODE_FAIL, "更新竞价记录失败");
//                        }
//                    }
//                    sendDatingSuccessNotification(datingActivity, cache);
//                } else {
//                    datingActivity.setStatus(Constants.DATING_STATUS_CLOSED);
//                    datingActivity.setEndType(Constants.DATING_ABORTIVE_AUCTION);
//                    datingActivityMapper.updateByPrimaryKeySelective(datingActivity);
//                    sendDatingFailedNotification(datingActivity, cache);
//                }
//                CacheUserProfile user = null;
//                if (Constants.USER_TYPE_P.equalsIgnoreCase(datingActivity.getUserType())) {
//                    user = playerCacheController.queryPlayerDetail(datingActivity.getUserId(), cache, false, false);
//                } else {
//                    user = compereCacheController.getCompereDetail(datingActivity.getUserId().toString(), cache, false, false);
//                }
//
//                if (StringUtils.isNotBlank(datingActivity.getChatroomId())) {
////                    easeMobService.deleteChatRoom(datingActivity.getChatroomId());
//                }
//                if (user != null) {
//                    // 发消息通知
//                    String[] toUserNames = new String[] { user.getPhone() };
////                    easeMobService.datingStatusChanged(toUserNames);
//                    commonCacheController.disableCacheDatingActivity(datingActivity, user, cache);
//                } else {
//                    throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到相关用户记录");
//                }
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有相关的约饭活动记录");
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    /**
//     * 主播取消约饭活动
//     *
//     * @param activityId
//     * @param cancelReason
//     * @throws Exception
//     */
//    public void cancelDatingActivity(Long activityId, String cancelReason) throws Exception {
//
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TDatingActivity datingActivity = datingActivityMapper.selectByPrimaryKey(activityId);
//            if (datingActivity != null) {
//                if (Constants.DATING_STATUS_CLOSED.equals(datingActivity.getStatus())) {
//                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "不能取消已经结束的约饭活动");
//                }
//                Date nowDate = new Date();
//                if (datingActivity.getTime().after(nowDate)) {
//                    datingActivity.setEndType(Constants.DATING_AHEAD_CANCEL);
//                } else {
//                    datingActivity.setEndType(Constants.DATING_CANCEL);
//                }
//                datingActivity.setCancelReason(cancelReason);
//                datingActivity.setLastModifyDate(nowDate);
//                datingActivity.setStatus(Constants.DATING_STATUS_CLOSED);
//                datingActivityMapper.updateByPrimaryKeySelective(datingActivity);
//
//                if (datingActivity.getHighestAuctionUserId() != null) {
//                    TUserGoods temp = new TUserGoods();
//                    temp.setUserId(datingActivity.getHighestAuctionUserId());
//                    List<TUserGoods> oldUserGoods = userGoodsMapper.select(temp);
//                    if (CollectionUtils.isNotEmpty(oldUserGoods)) {
//                        TUserGoods ug = oldUserGoods.get(0);
//                        int addPrice = ug.getTotalPrice() / ug.getAmount() * datingActivity.getHighestAuctionCount();
//                        ug.setAmount(datingActivity.getHighestAuctionCount());
//                        ug.setTotalPrice(addPrice);
//                        userGoodsMapper.addUserGoodsAmount(ug);
//                        commonCacheController.addGoods(ug, cache);
//                    }
//
//                    CachePlayerProfile player = playerCacheController
//                            .queryPlayerDetail(datingActivity.getHighestAuctionUserId(), cache, false, false);
//                    String[] toUserNames = new String[] { player.getPhone() };
////                    easeMobService.datingStatusChanged(toUserNames);
//                }
//                CacheUserProfile user = null;
//                if (Constants.USER_TYPE_P.equalsIgnoreCase(datingActivity.getUserType())) {
//                    user = playerCacheController.queryPlayerDetail(datingActivity.getUserId(), cache, false, false);
//                } else {
//                    user = compereCacheController.getCompereDetail(datingActivity.getUserId().toString(), cache, false, false);
//                }
//                if (user != null) {
//                    commonCacheController.disableCacheDatingActivity(datingActivity, user, cache);
//                }
//                if (StringUtils.isNotBlank(datingActivity.getChatroomId())) {
////                    easeMobService.deleteChatRoom(datingActivity.getChatroomId());
//                }
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有相关的约饭活动记录");
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    /**
//     * 确认支付
//     *
//     * @param datingActivityId
//     * @param userId
//     * @throws Exception
//     */
//    public void confirmPayment(long datingActivityId, long userId) throws Exception {
//        ICache cache = null;
//        try {
//            Date nowDate = new Date();
//            cache = CacheManager.getCache();
//            TDatingActivity datingActivity = datingActivityMapper.selectByPrimaryKey(datingActivityId);
//            if (datingActivity != null) {
//                if (Constants.DATING_STATUS_AUCTION_CLOSED.equals(datingActivity.getStatus())) {
//                    if (datingActivity.getHighestAuctionUserId() != null) {
//                        if (datingActivity.getHighestAuctionUserId() == userId) {
//                            datingActivity.setStatus(Constants.DATING_STATUS_CLOSED);
//                            datingActivity.setEndType(Constants.DATING_PAYED);
//                            datingActivityMapper.updateByPrimaryKeySelective(datingActivity);
//
//                            int totalCost = 0;
//                            TUserGoods temp = new TUserGoods();
//                            temp.setUserId(datingActivity.getHighestAuctionUserId());
//                            TUserGoods userGoods = userGoodsMapper.selectOne(temp);
//
//                            TUserGoodsUseRecord goodsUseRecord = new TUserGoodsUseRecord();
//                            goodsUseRecord.setId(generateIdService.generateId(TUserGoodsUseRecord.class.getName()));
//                            goodsUseRecord.setUserId(datingActivity.getHighestAuctionUserId());
//                            goodsUseRecord.setActivityId(datingActivityId);
//                            if (userGoods != null) {
//                                totalCost = userGoods.getUnitPrice() * datingActivity.getHighestAuctionCount();
//                                goodsUseRecord.setPrice(totalCost);
//                            }
//                            List<TGoodsCategory> goodsCategories = baseCacheController.queryCategories(cache);
//                            if (CollectionUtils.isNotEmpty(goodsCategories)) {
//                                for (TGoodsCategory gc : goodsCategories) {
//                                    if (datingActivity.getCategoryId().equals(gc.getCategoryId())) {
//                                        goodsUseRecord.setCategoryType(gc.getType());
//                                        goodsUseRecord.setCategoryId(gc.getCategoryId());
//                                        goodsUseRecord.setCategoryName(gc.getName());
//                                        goodsUseRecord.setCategoryPhoto(gc.getCategoryPhoto());
//                                        break;
//                                    }
//                                }
//                            }
//
//                            goodsUseRecord.setAmount(datingActivity.getHighestAuctionCount());
//                            goodsUseRecord.setUseDate(nowDate);
//                            userGoodsUseRecordMapper.insert(goodsUseRecord);
//
//                            commonCacheController.updateCacheDatingActivityStatus(datingActivity, cache);
//
//
//                            CacheUserProfile user = null;
//                            if (Constants.USER_TYPE_P.equalsIgnoreCase(datingActivity.getUserType())) {
//                                user = playerCacheController.queryPlayerDetail(datingActivity.getUserId(), cache, false, false);
//                            } else {
//                                user = compereCacheController.getCompereDetail(datingActivity.getUserId().toString(), cache, false, false);
//                                /**
//                                 * 分成
//                                 */
//                                extractService.datingServiceExtract(datingActivity, totalCost, nowDate, cache);
//                            }
//                            if (user != null) {
//                                String[] toUserNames = new String[] { user.getPhone() };
////                                easeMobService.datingStatusChanged(toUserNames);
//                            } else {
//                                throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到相关用户记录");
//                            }
//                        } else {
//                            throw new InfServerException(Constants.RETURN_CODE_FAIL, "当前用户不是竞价得主");
//                        }
//                    } else {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "此活动没有竞价人");
//                    }
//                } else {
//                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "只有竞价结束状态的约饭活动才能支付");
//                }
//
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有相关的约饭活动记录");
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    /**
//     * 评论约饭
//     *
//     * @param activityId
//     * @param onTimeGrade
//     * @param satisfaction
//     * @throws Exception
//     */
//    public void evaluateDatingActivity(Long activityId, Float onTimeGrade, Float satisfaction) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TDatingActivity datingActivity = datingActivityMapper.selectByPrimaryKey(activityId);
//            if (datingActivity != null) {
//                if (Constants.DATING_STATUS_CLOSED.equals(datingActivity.getStatus()) && Constants.DATING_PAYED.equals(datingActivity.getEndType())) {
//                    datingActivity.setOnTimeGrade(onTimeGrade);
//                    datingActivity.setSatisfaction(satisfaction);
//                    datingActivity.setIsEvaluation(1);
//                    datingActivity.setGradeDate(new Date());
//                    datingActivityMapper.updateByPrimaryKeySelective(datingActivity);
//
//                    int count = userMapper.updateDatingActivityInfo(datingActivity.getUserId(), onTimeGrade, satisfaction);
//                    if (count == 0) {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "更新用户约饭信息失败");
//                    }
//
//                    commonCacheController.updateCacheDatingActivityStatus(datingActivity, cache);
//                } else {
//                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "只有已结束且已确认支付的约饭活动才能进行评论");
//                }
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    /**
//     * 查询个人竞价记录
//     *
//     * @param userId
//     * @return
//     * @throws Exception
//     */
//    public List<CacheDatingAuctionRecordProfile> queryDatingAuctionRecords(Long userId) throws Exception {
//        List<CacheDatingAuctionRecordProfile> auctionRecords = null;
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            auctionRecords = commonCacheController.findDatingAuctionRecords(userId, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//        return auctionRecords;
//    }
//
//    /**
//     * 应用启动时，初始化约饭活动
//     * @throws Exception
//     */
//    public void initDatingActivity() throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            Date nowDate = new Date();
//            TDatingActivity temp = new TDatingActivity();
//            temp.setStatus(Constants.DATING_STATUS_IN_AUCTION);
//            List<TDatingActivity> datingActivities = datingActivityMapper.select(temp);
//            if (CollectionUtils.isNotEmpty(datingActivities)) {
//                for (TDatingActivity datingActivity : datingActivities) {
//                    if (datingActivity.getTime().getTime() - nowDate.getTime() <= 1800000) {
//                        if (datingActivity.getHighestAuctionUserId() != null) {
//                            datingActivity.setStatus(Constants.DATING_STATUS_AUCTION_CLOSED);
//                            datingActivityMapper.updateByPrimaryKeySelective(datingActivity);
//
//                            if (datingActivity.getHighestAuctionUserId() != null) {
//                                int count = datingAuctionRecordMapper.modifyBidWinnerRecord(datingActivity.getId(),
//                                        datingActivity.getHighestAuctionUserId());
//                                if (count == 0) {
//                                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "更新竞价记录失败");
//                                }
//                            }
//                        } else {
//                            datingActivity.setStatus(Constants.DATING_STATUS_CLOSED);
//                            datingActivity.setEndType(Constants.DATING_ABORTIVE_AUCTION);
//                            datingActivityMapper.updateByPrimaryKeySelective(datingActivity);
//                        }
//                        CacheUserProfile user = null;
//                        if (Constants.USER_TYPE_P.equalsIgnoreCase(datingActivity.getUserType())) {
//                            user = playerCacheController.queryPlayerDetail(datingActivity.getUserId(), cache, false, false);
//                        } else {
//                            user = compereCacheController.getCompereDetail(datingActivity.getUserId().toString(), cache, false, false);
//                        }
//
//                        if (user != null) {
//                            // 发消息通知
//                            String[] toUserNames = new String[] { user.getPhone() };
////                            easeMobService.datingStatusChanged(toUserNames);
//                            commonCacheController.disableCacheDatingActivity(datingActivity, user, cache);
//                        } else {
//                            throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到相关用户记录");
//                        }
//                    } else {
//                        ScheduleJob scheduleJob = new ScheduleJob();
//                        scheduleJob.setJobId(datingActivity.getId().toString());
//                        scheduleJob.setJobGroup("datingActivity");
//                        /**
//                         * 时间转换
//                         */
//                        Calendar calendar = Calendar.getInstance();
//                        calendar.setTime(datingActivity.getTime());
//                        calendar.add(Calendar.MINUTE, -30);
//                        String cronExpression = calendar.get(Calendar.SECOND) + " " + calendar.get(Calendar.MINUTE) + " "
//                                + calendar.get(Calendar.HOUR_OF_DAY) + " " + calendar.get(Calendar.DAY_OF_MONTH) + " "
//                                + (calendar.get(Calendar.MONTH) + 1) + " ? " + calendar.get(Calendar.YEAR);
//
//                        scheduleJob.setCronExpression(cronExpression);
//                        scheduleJob.setBeanName("datingActivityScheduleService");
//                        scheduleJob.setMethodType(1);
//                        scheduleJob.setData(datingActivity.getId());
//                        dynamicScheduleService.enableSchedule(scheduleJob);
//                    }
//                }
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    private void sendDatingSuccessNotification(TDatingActivity datingActivity, ICache cache) throws Exception{
//        Long winnerId = datingActivity.getHighestAuctionUserId();
//        String userType = datingActivity.getUserType();
//        Long userId = datingActivity.getUserId();
//        String ownerName = "";
//
//        CachePlayerProfile player = playerCacheController.queryPlayerDetail(winnerId, cache, false, false);
//        if (userType.equalsIgnoreCase(Constants.USER_TYPE_C)) {
//            CacheCompereProfile user = compereCacheController.getCompereDetail(userId.toString(), cache, false, false);
//            ownerName = user.getNickName();
////            easeMobService.sendDatingWinnerNotification(player.getPhone(), user.getUserId(), user.getNickName(), user.getPhotoUrl(), userType, datingActivity.getHighestAuctionCount());
////            easeMobService.sendDatingOwnerNotification(user.getPhone(), player.getUserId(), player.getNickName(), player.getPhotoUrl(), Constants.USER_TYPE_P, datingActivity.getHighestAuctionCount());
//        } else if (userType.equalsIgnoreCase(Constants.USER_TYPE_P)) {
//            CachePlayerProfile user = playerCacheController.queryPlayerDetail(userId, cache, false, false);
//            ownerName = user.getNickName();
////            easeMobService.sendDatingWinnerNotification(player.getPhone(), user.getUserId(), user.getNickName(), user.getPhotoUrl(), userType, datingActivity.getHighestAuctionCount());
////            easeMobService.sendDatingOwnerNotification(user.getPhone(), player.getUserId(), player.getNickName(), player.getPhotoUrl(), Constants.USER_TYPE_P, datingActivity.getHighestAuctionCount());
//        }
//
//        JSONObject owner = new JSONObject();
//        owner.put("winnerName", player.getNickName());
//        owner.put("cardNum", datingActivity.getHighestAuctionCount());
//        JPushUtil.pushDatingOwnerSuccessNotification(owner, userId.toString());
//
//        JSONObject winner = new JSONObject();
//        winner.put("ownerName", ownerName);
//        winner.put("cardNum", datingActivity.getHighestAuctionCount());
//        JPushUtil.pushDatingWinnerSuccessNotification(winner, winnerId.toString());
//    }
//
//    private void sendDatingFailedNotification(TDatingActivity datingActivity, ICache cache) throws Exception{
//        String userType = datingActivity.getUserType();
//        Long userId = datingActivity.getUserId();
//        if (userType.equalsIgnoreCase(Constants.USER_TYPE_C)) {
//            CacheCompereProfile user = compereCacheController.getCompereDetail(userId.toString(), cache, false, false);
////            easeMobService.sendDatingOwnerNotification(user.getPhone(), null, null, null, null, datingActivity.getHighestAuctionCount());
//        } else if (userType.equalsIgnoreCase(Constants.USER_TYPE_P)) {
//            CachePlayerProfile user = playerCacheController.queryPlayerDetail(userId, cache, false, false);
////            easeMobService.sendDatingOwnerNotification(user.getPhone(), null, null, null, null, datingActivity.getHighestAuctionCount());
//        }
//
//        JPushUtil.pushDatingOwnerFailNotification(userId.toString());
//    }
//}
