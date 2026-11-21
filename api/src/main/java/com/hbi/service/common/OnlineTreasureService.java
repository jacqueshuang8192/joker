//package com.hbi.service.common;
//
//import com.core.util.ConfigUtil;
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.cacheWritter.OnlineTreasureCacheLoader;
//import com.hbi.cache.controller.CommonCacheController;
//import com.hbi.cache.controller.CompereCacheController;
//import com.hbi.cache.controller.OnlineTreasuerCacheController;
//import com.hbi.cache.controller.PlayerCacheController;
//import com.hbi.cache.model.CacheStoreCategory;
//import com.hbi.cache.model.CacheUserProfile;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.*;
//import com.hbi.model.*;
//import com.hbi.service.idGenerate.GenerateIdService;
//import com.hbi.utils.GameServerUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.onlineTreasure.JoinTreasureActivityVo;
//import com.hbi.vo.response.onlineTreasure.MyTreasureActivityVo;
//import org.apache.commons.lang.math.RandomUtils;
//import org.springframework.beans.BeanUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import java.util.*;
//
///**
// * Created by yrou on 4/20/2016.
// */
//@Service
//public class OnlineTreasureService {
//    @Autowired
//    private OnlineTreasuerCacheController onlineTreasuerCacheController;
//    @Autowired
//    private GenerateIdService idService;
//    @Autowired
//    private TOnlineTreasureRecordMapper recordMapper;
//    @Autowired
//    private TOnlineTreasureActivityMapper activityMapper;
//    @Autowired
//    private CompereCacheController compereCacheController;
//    @Autowired
//    private OnlineTreasureCacheLoader onlineTreasureCacheLoader;
//    @Autowired
//    private PlayerCacheController playerCacheController;
//    @Autowired
//    private TOnlineTreasureMapper onlineTreasureMapper;
//    @Autowired
//    private TOnlineTreasureAddressMapper addressMapper;
//    @Autowired
//    private ExtractService extractService;
//    @Autowired
//    private TSecUserMapper secUserMapper;
//    @Autowired
//    private CommonCacheController commonCacheController;
//
//    public List<TOnlineTreasureActivity> queryActiveTreasureList(Long cityId, Long categoryId) throws Exception{
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<TOnlineTreasureActivity> list = onlineTreasuerCacheController.queryActiveTreasureList(cache);
//            Iterator<TOnlineTreasureActivity> iterator = list.iterator();
//            while (iterator.hasNext()) {
//                TOnlineTreasureActivity activity = iterator.next();
//                if (cityId != null && !activity.getCityId().equals(cityId)) {
//                    iterator.remove();
//                    continue;
//                }
//                if (categoryId != null &&!activity.getCategoryId().equals(categoryId)) {
//                    iterator.remove();
//                    continue;
//                }
//            }
//            if (cityId != null) {
//            }
//            return list;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public MyTreasureActivityVo activityDetail(Long activityId, Long userId) throws Exception{
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            MyTreasureActivityVo vo = new MyTreasureActivityVo();
//            TOnlineTreasureActivity activity = onlineTreasuerCacheController.activityDetail(activityId, cache);
//            List<TOnlineTreasureRecord> records = onlineTreasuerCacheController.queryRecordsByActivityId(activityId, cache);
//            activity.setRecords(records);
//            List<String> codes = onlineTreasuerCacheController.queryMyCodeByActivityId(activityId, userId, cache);
//            Integer jewelAmount = GameServerUtil.queryJewelAmount(userId);
//            vo.setUserJewelAmount(jewelAmount);
//            vo.setActivity(activity);
//            vo.setCodes(codes);
//            return vo;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public JoinTreasureActivityVo joinActivity(Long userId, String userType, Integer jewelAmount, Long activityId, Integer isToEnd) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            if (jewelAmount <= 0 && isToEnd == 0) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "投入房卡数量错误！");
//            }
//            if (onlineTreasuerCacheController.lockActivity(activityId)) {
//                try {
//                    JoinTreasureActivityVo vo = new JoinTreasureActivityVo();
//                    TOnlineTreasureActivity activity = onlineTreasuerCacheController.activityDetail(activityId, cache);
//                    if (!activity.getStatus().equals(Constants.ONLINE_TREASURE_STATUS_PUBLISH)) {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "活动已结束！");
//                    }
//                    Integer selledAmount = activity.getSelledAmount();
//                    Integer jewelLeft = activity.getThreshold() - selledAmount;
//                    if (jewelLeft <= 0) {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "该活动已投满！");
//                    }
//                    if(isToEnd.equals(1)) {
//                        jewelAmount = jewelLeft;
//                        vo.setLeftJewel(jewelLeft);
//                    }
//                    Integer userJewel = GameServerUtil.queryJewelAmount(userId);
//                    String code = generateCode(activityId, jewelAmount, selledAmount);
//                    CacheUserProfile profile = new CacheUserProfile();
//                    if (Constants.USER_TYPE_C.equals(userType)) {
//                        profile = compereCacheController.getCompereDetail(userId.toString(), cache, false, false);
//                    } else if (Constants.USER_TYPE_P.equals(userType)) {
//                        profile = playerCacheController.queryPlayerDetail(userId, cache, false, false);
//                    }
//
//                    vo.setCode(code);
//
//                    if(userJewel < jewelAmount) {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "余额不足！");
//                    }
//
//                    if (jewelLeft < jewelAmount) {//剩余房卡数不够
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "投入房卡数量超过限制！");
//                    }
//
//                    GameServerUtil.invokeUpdateJewel(userId, -jewelAmount); //更新用户房卡
//
//                    if(activityMapper.increaseSelledAmount(activityId, jewelAmount) == 0) {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "更新夺宝记录失败！");
//                    }
//
//                    TOnlineTreasureRecord record = new TOnlineTreasureRecord();
//                    record.setId(idService.generateId());
//                    record.setActivityId(activityId);
//                    record.setCode(code);
//                    record.setJewelAmount(jewelAmount);
//                    record.setUserId(userId);
//                    record.setUserName(profile.getNickName());
//                    record.setPhoto(profile.getPhotoUrl());
//                    record.setUserType(userType);
//                    record.setDate(new Date());
//                    if (recordMapper.insert(record) == 0) {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "更新夺宝记录失败！");
//                    }
//
//                    if(jewelLeft.equals(jewelAmount)) { //房卡数量刚好投完
//                        generateWinner(activity, vo, cache);
//                        vo.setStatus(Constants.ONLINE_TREASURE_STATUS_WAITING);
//                        wait4Draw(activityId, vo, cache);
//                    }
//
//                    onlineTreasuerCacheController.addRecord(record, cache);
//                    onlineTreasuerCacheController.joinActivity(activityId, jewelAmount, cache);
//                    return vo;
//                } catch (Exception e) {
//                    throw e;
//                } finally {
//                    onlineTreasuerCacheController.unlockActivity(activityId);
//                }
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "参加夺宝失败！");
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    /**
//     * 等待开奖：1，更新库存；2，更新活动中奖玩家和中奖号码；3，启动下一个活动；4，更新本次活动状态，启动定时器
//     * @param activityId
//     * @param cache
//     * @throws Exception
//     */
//    public void wait4Draw(Long activityId, JoinTreasureActivityVo vo, ICache cache) throws Exception {
//        TOnlineTreasureActivity updateActivity = new TOnlineTreasureActivity();
//        Long waitTime = Long.parseLong(ConfigUtil.get("treasure.waitTime", "30000"));
//        TOnlineTreasureActivity originActivity = onlineTreasuerCacheController.activityDetail(activityId, cache);
//        Calendar c = Calendar.getInstance();
//        c.add(Calendar.SECOND, 30);
//        Date drawTime = c.getTime();//开奖时间
//
//        updateActivity.setId(activityId);
//        updateActivity.setWinnerId(vo.getWinnerId());
//        updateActivity.setWinnerName(vo.getWinner().getNickName());
//        updateActivity.setRewardCode(vo.getWinnerCode());
//        updateActivity.setStatus(Constants.ONLINE_TREASURE_STATUS_WAITING);
//        updateActivity.setDrawTime(drawTime);
//        if (activityMapper.updateByPrimaryKeySelective(updateActivity) == 0) {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, "更新夺宝状态失败！");
//        }
//        if(onlineTreasureMapper.updateInventory(originActivity.getTreasureId()) == 0) {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, "更新夺宝库存失败！");
//        }
//
//        TOnlineTreasure treasure = new TOnlineTreasure();
//        treasure.setId(originActivity.getTreasureId());
//        List<TOnlineTreasure> l = onlineTreasureMapper.select(treasure);
//        if(l.size() > 0) {
//            treasure = l.get(0);
//        }
//        if (treasure.getInventory() > 0
//                && treasure.getStatus().equals(Constants.ONLINE_TREASURE_STATUS_PUBLISH)) {//库存有剩余
//            createActivity(treasure, cache);
//        }
//
//        //更新活动状态，获奖用户，获奖码，开奖时间
//        onlineTreasuerCacheController.updateActivityField(activityId, "status", Constants.ONLINE_TREASURE_STATUS_WAITING, cache);
//        onlineTreasuerCacheController.updateActivityField(activityId, "winnerId", vo.getWinnerId().toString(), cache);
//        onlineTreasuerCacheController.updateActivityField(activityId, "winnerName", vo.getWinner().getNickName(), cache);
//        onlineTreasuerCacheController.updateActivityField(activityId, "rewardCode", vo.getWinnerCode(), cache);
//        onlineTreasuerCacheController.updateActivityField(activityId, "drawTime", String.valueOf(drawTime.getTime()), cache);
//
//        //将活动从active列表移到draw列表
//        onlineTreasuerCacheController.removeActiveActivity(activityId, cache);
//        onlineTreasuerCacheController.addToDrawActivities(activityId, cache);
//
//        TSecUser provinceAgent = secUserMapper.selectByPrimaryKey(originActivity.getAgentId());
//        Integer profit = originActivity.getThreshold() - originActivity.getProduceActualPrice();
//        extractService.indianaExtract(provinceAgent.getUserid(), provinceAgent.getParentId(),profit, drawTime, cache);
//
//        final Long finalActivityId = new Long(activityId.longValue());
//        new Timer().schedule(new TimerTask() {
//            @Override
//            public void run() {
//                try {
//                    afterDraw(finalActivityId);
//                } catch (Exception e) {
//                    e.printStackTrace();
//                }
//            }
//        }, waitTime);
//    }
//
//    public void afterDraw(Long activityId) throws Exception{
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TOnlineTreasureActivity updateActivity = new TOnlineTreasureActivity();
//            updateActivity.setStatus(Constants.ONLINE_TREASURE_STATUS_PAST_DUE);
//            updateActivity.setId(activityId);
//            if (activityMapper.updateByPrimaryKeySelective(updateActivity) == 0) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "更新夺宝状态失败！");
//            }
//            onlineTreasuerCacheController.updateActivityField(activityId, "status", Constants.ONLINE_TREASURE_STATUS_PAST_DUE, cache);
//
//            //将活动从draw列表移到结束列表
//            onlineTreasuerCacheController.removeDrawActivity(activityId, cache);
//            onlineTreasuerCacheController.addToPreviousActivities(activityId, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public List<MyTreasureActivityVo> queryMyActivities(Long userId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            return onlineTreasuerCacheController.queryMyActivities(userId, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public List<TOnlineTreasureActivity> queryPreviouceActivities(Long cityId, Long treasureId) throws Exception{
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<TOnlineTreasureActivity> list = onlineTreasuerCacheController.queryPreviousTreasureList(cache);
//            Iterator<TOnlineTreasureActivity> iterator = list.iterator();
//            while (iterator.hasNext()) {
//                TOnlineTreasureActivity activity = iterator.next();
//                if (cityId != null && !activity.getCityId().equals(cityId)) {
//                    iterator.remove();
//                    continue;
//                }
//                if (treasureId != null &&!activity.getTreasureId().equals(treasureId)) {
//                    iterator.remove();
//                    continue;
//                }
//            }
//            return list;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public List<TOnlineTreasureActivity> queryNearestPreviouceActivities() throws Exception{
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            return onlineTreasuerCacheController.queryNearestPreviouceActivities(cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public List<TOnlineTreasureActivity> drawActivities() throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<TOnlineTreasureActivity> list = onlineTreasuerCacheController.drawActivities(cache);
//            Date now = new Date();
//            for (TOnlineTreasureActivity a : list) {
//                a.setLeftTime(a.getDrawTime().getTime() - now.getTime());
//            }
//            return list;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    /**
//     * 创建新的夺宝活动
//     * @param treasure
//     * @param cache
//     * @throws Exception
//     */
//    public void createActivity(TOnlineTreasure treasure, ICache cache) throws Exception {
//        TOnlineTreasureActivity activity = new TOnlineTreasureActivity();
//        BeanUtils.copyProperties(treasure, activity);
//        activity.setId(idService.generateId());
//        activity.setTreasureId(treasure.getId());
//        activity.setSelledAmount(0);
//        if(activityMapper.insert(activity) == 0) {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, "新建夺宝活动失败！");
//        }
//        onlineTreasuerCacheController.addActivityDetail(activity, cache);
//        onlineTreasuerCacheController.addActiveActivity(activity.getId(), cache);
//    }
//
//    /**
//     * 搜索夺宝活动
//     * @param keyWord
//     * @return
//     */
//    public List<TOnlineTreasureActivity> search(Long cityId, String keyWord) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            keyWord = "%" + keyWord + "%";
//            List<Long> ids = activityMapper.search(cityId, keyWord);
//            List<TOnlineTreasureActivity> list = new ArrayList<TOnlineTreasureActivity>();
//            for (Long id : ids) {
//                TOnlineTreasureActivity activity = onlineTreasuerCacheController.activityDetail(id, cache);
//                if(activity != null && activity.getStatus().equals(Constants.ONLINE_TREASURE_STATUS_PUBLISH)) {
//                    list.add(activity);
//                }
//            }
//            return list;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public Long addAddress(Long userId, String userName, String phone, String address) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TOnlineTreasureAddress onlineTreasureAddress = new TOnlineTreasureAddress();
//            Long id = idService.generateId();
//            onlineTreasureAddress.setId(id);
//            onlineTreasureAddress.setUserId(userId);
//            onlineTreasureAddress.setAddress(address);
//            onlineTreasureAddress.setUserName(userName);
//            onlineTreasureAddress.setPhone(phone);
//            if (addressMapper.insert(onlineTreasureAddress) > 0) {
//                onlineTreasuerCacheController.addAddress(onlineTreasureAddress, cache);
//                return id;
//            }
//            return null;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public void chooseAddress(Long addressId, Long activityId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TOnlineTreasureActivity activity = onlineTreasuerCacheController.activityDetail(activityId, cache);
//            if (activity != null) {
//                TOnlineTreasureAddress address = onlineTreasuerCacheController.queryAddressById(addressId, activity.getWinnerId(), cache);
//                TOnlineTreasureActivity newActivity = new TOnlineTreasureActivity();
//                newActivity.setId(activityId);
//                newActivity.setAddressId(address.getId());
//                newActivity.setStatus(Constants.ONLINE_TREASURE_STATUS_WAIT_DELIVER);
//                activityMapper.updateByPrimaryKeySelective(newActivity);
//                onlineTreasuerCacheController.updateActivityField(activityId, "addressId", address.getId().toString(), cache);
//                onlineTreasuerCacheController.updateActivityField(activityId, "status", Constants.ONLINE_TREASURE_STATUS_WAIT_DELIVER, cache);
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public List<TOnlineTreasureAddress> queryAddress(Long userId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            return onlineTreasuerCacheController.queryAddress(userId, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public List<CacheStoreCategory> queryCategory() throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            return commonCacheController.queryStorePrimaryCategories(cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    private String generateCode(Long activityId, Integer jewelAmount, Integer selledAmount) {
//        Integer start = selledAmount + 1;
//        Integer end = start + jewelAmount - 1;
//        //activityId后4位加中奖码补0到五位
//        String startStr = formatStr(activityId, start);
//        String endStr = formatStr(activityId, end);
//        if (jewelAmount.equals(1)) {
//            return startStr;
//        }
//        return startStr + "-" + endStr;
//    }
//
//    private void generateWinner(TOnlineTreasureActivity activity, JoinTreasureActivityVo vo, ICache cache) throws Exception {
//        Integer rand = RandomUtils.nextInt(activity.getThreshold()) + 1; //随机数生成不包括右区间
//        String code = formatStr(activity.getId(), rand);
//        List<TOnlineTreasureRecord> records = onlineTreasureCacheLoader.queryRecordsByActivityId(activity.getId());
//        TOnlineTreasureRecord winRecord = new TOnlineTreasureRecord();
//        for (TOnlineTreasureRecord r : records) {
//            if (r.getCode().equals(code)) {//生成的号码记录为单个号码记录
//                winRecord = r;
//                break;
//            } else if (r.getCode().indexOf("-") > -1){//生成的号码在号码串之间
//                String[] codes = r.getCode().split("-");
//                Long start = Long.parseLong(codes[0]);
//                Long end = Long.parseLong(codes[1]);
//                Long codeL = Long.parseLong(code);
//                if (codeL >= start && codeL <= end) {
//                    winRecord = r;
//                    break;
//                }
//            }
//        }
//        if (winRecord.getCode() == null) {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, "无法生成获奖号码！");
//        }
//        Long userId = winRecord.getUserId();
//        String userType = winRecord.getUserType();
//        CacheUserProfile profile = new CacheUserProfile();
//        if (Constants.USER_TYPE_C.equals(userType)) {
//            profile = compereCacheController.getCompereDetail(userId.toString(), cache, false, false);
//        } else if (Constants.USER_TYPE_P.equals(userType)) {
//            profile = playerCacheController.queryPlayerDetail(userId, cache, false, false);
//        }
//        vo.setWinnerCode(code);
//        vo.setWinner(profile);
//        vo.setWinnerId(userId);
//    }
//
//    private String formatStr(Long activityId, int count) {
//        String str = "";
//        if (activityId.toString().length() < 4) {
//            str = String.format("%0"+4+"d", activityId) + String.format("%0"+5+"d", count);
//        } else {
//            String activityStr = activityId.toString();
//            str = activityStr.substring(activityStr.length() -4) + String.format("%0"+5+"d", count);
//        }
//        return str;
//    }
//}
