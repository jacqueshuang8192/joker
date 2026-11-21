//package com.hbi.service.society;
//
//import java.text.SimpleDateFormat;
//import java.util.*;
//
//import com.hbi.utils.JPushUtil;
//import com.hbi.utils.PushUtil;
//import com.hbi.vo.response.society.*;
//import org.apache.commons.lang.StringUtils;
//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.alibaba.fastjson.JSONObject;
//import com.core.util.DateUtils;
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.BaseCacheController;
//import com.hbi.cache.controller.CommonCacheController;
//import com.hbi.cache.controller.CompereCacheController;
//import com.hbi.cache.controller.MiningCacheController;
//import com.hbi.cache.controller.PlayerCacheController;
//import com.hbi.cache.controller.SocietyCacheController;
//import com.hbi.cache.model.CacheCompereProfile;
//import com.hbi.cache.model.CachePlayerProfile;
//import com.hbi.cache.model.CacheSocietyProfile;
//import com.hbi.cache.model.CacheUserListProfile;
//import com.hbi.cache.model.CacheUserProfile;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TCompereIncomeMapper;
//import com.hbi.mapper.TMiningGameMapper;
//import com.hbi.mapper.TSocietyMapper;
//import com.hbi.model.TMiningGame;
//import com.hbi.model.TMiningGameSection;
//import com.hbi.model.TUserGame;
//import com.hbi.schedule.model.ScheduleJob;
//import com.hbi.schedule.service.DynamicScheduleService;
//import com.hbi.service.common.FightUtil;
//import com.hbi.service.idGenerate.GenerateIdService;
//import com.hbi.utils.GameServerUtil;
//import com.hbi.utils.InfServerException;
//
//@Service
//public class MiningService {
//
//    private static final Logger LOG = LoggerFactory.getLogger(MiningService.class);
//
//    @Autowired
//    private TSocietyMapper societyMapper;
//    @Autowired
//    private TMiningGameMapper miningGameMapper;
//    @Autowired
//    private TCompereIncomeMapper compereIncomeMapper;
//    @Autowired
//    private SocietyCacheController societyCacheController;
//    @Autowired
//    private BaseCacheController baseCacheController;
//    @Autowired
//    private PlayerCacheController playerCacheController;
//    @Autowired
//    private CompereCacheController compereCacheController;
//    @Autowired
//    private CommonCacheController commonCacheController;
//    @Autowired
//    private MiningCacheController miningCacheController;
//    @Autowired
//    private GenerateIdService idService;
//    @Autowired
//    private EaseMobService easeMobService;
//    @Autowired
//    private DynamicScheduleService dynamicScheduleService;
//
//    /**
//     * 查询公会可抢矿列表
//     *
//     * @param cityId
//     * @return
//     * @throws Exception
//     */
//    public MiningListVo queryMiningList(Long cityId, Long societyId)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            MiningListVo vo = new MiningListVo();
//            vo.setSelfSocietyBoomed(false);
//            List<TMiningGame> activityList = miningCacheController
//                    .querySocietyMineActivity(cache);
//            Iterator<TMiningGame> iterator = activityList.iterator();
//            while (iterator.hasNext()) {
//                TMiningGame activity = iterator.next();
//                if (activity.getSocietyId().equals(societyId)) {
//                    iterator.remove();
//                    vo.setSelfSocietyBoomed(true);
//                    continue;
//                }
//                CacheSocietyProfile societyProfile = societyCacheController
//                        .querySocietyDetail(activity.getSocietyId(), cache);
//                if (!societyProfile.getCityId().equals(cityId)) {
//                    iterator.remove();
//                    continue;
//                }
//                // 开始结束时间转换成unix时间戳
//                String startDate = activity.getStartDate();
//                if (StringUtils.isNotBlank(startDate)) {
//                    // endDate = endDate.substring(0, 19);
//                    SimpleDateFormat format = new SimpleDateFormat(
//                            "yyyy-MM-dd HH:mm:ss");
//                    Date date = format.parse(startDate);
//                    activity.setStartDate(String.valueOf(date.getTime()));
//                }
//                String endDate = activity.getEndDate();
//                if (StringUtils.isNotBlank(endDate)) {
//                    // endDate = endDate.substring(0, 19);
//                    SimpleDateFormat format = new SimpleDateFormat(
//                            "yyyy-MM-dd HH:mm:ss");
//                    Date date = format.parse(endDate);
//                    activity.setEndDate(String.valueOf(date.getTime()));
//                }
//            }
//            // 无可抢矿列表，个推推送隐藏抢矿按钮
////            if (activityList.size() == 0) {
////                JSONObject json = new JSONObject();
////                json.put("boom", "false");
////                GetuiUtil.push(Constants.BOOM, json);
////            }
//            vo.setCount(activityList.size());
//            vo.setList(activityList);
//            return vo;
////            return activityList;activityList
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 查询我的可抢矿次数
//     *
//     * @param userId
//     * @return
//     * @throws Exception
//     */
//    public MiningTimes queryMiningTimes(Long userId, String userType) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            MiningTimes miningTimes = new MiningTimes();
//            Integer count = miningCacheController.queryUserTotalDigCount(userId, cache, userType);
//            miningTimes.setTotalTimes(count);
//            Integer leftCount = miningCacheController
//                    .queryUserLeftDigCount(userId, cache, userType);
//            miningTimes.setLeftTimes(leftCount);
//            return miningTimes;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 查询采矿活动详情
//     *
//     * @param userId
//     * @param activityId
//     * @return
//     * @throws Exception
//     */
//    public MiningDetail queryMiningDetail(Long userId, Long activityId)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            MiningDetail detail = new MiningDetail();
//            TMiningGame miningGame = miningCacheController
//                    .queryMiningGameByActivityId(cache, activityId);
//            if (miningGame == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "抢矿活动不存在！");
//            }
//            Integer maxFightRound = queryMaxFightRound();
//            detail.setStartDate(miningGame.getStartDate());
//
//            // 开始结束时间转换成unix时间戳
//            String startDate = miningGame.getStartDate();
//            if (StringUtils.isNotBlank(startDate)) {
//                // endDate = endDate.substring(0, 19);
//                SimpleDateFormat format = new SimpleDateFormat(
//                        "yyyy-MM-dd HH:mm:ss");
//                Date date = format.parse(startDate);
//                detail.setStartDate(String.valueOf(date.getTime()));
//            }
//            String endDate = miningGame.getEndDate();
//            if (StringUtils.isNotBlank(endDate)) {
//                // endDate = endDate.substring(0, 19);
//                SimpleDateFormat format = new SimpleDateFormat(
//                        "yyyy-MM-dd HH:mm:ss");
//                Date date = format.parse(endDate);
//                detail.setEndDate(String.valueOf(date.getTime()));
//            }
//            detail.setFullAmount(miningGame.getFullAmount());
//            detail.setRealAmount(miningGame.getRealAmount());
//            detail.setMaxFightRound(maxFightRound);
//
//            List<CacheUserProfile> userList = societyCacheController
//                    .querySocietyOnlineUsers(miningGame.getSocietyId(), cache);
//            Iterator<CacheUserProfile> iterator = userList.iterator();
//            while (iterator.hasNext()) {
//                CacheUserProfile profile = iterator.next();
//                if (profile.getLife() == null || profile.getLife() == 0) {
//                    iterator.remove();
//                }
//            }
//            detail.setDefenseNum(userList.size());
//
//            CachePlayerProfile player = playerCacheController
//                    .queryPlayerDetail(userId, cache, false, false);
//            if (player == null) {
//                CacheCompereProfile compere = compereCacheController
//                        .getCompereDetail(userId.toString(), cache, false, false);
//                if (compere == null) {
//                    throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                            "用户不存在！");
//                } else {
//                    detail.setAttack(compere.getAttack());
//                    detail.setDefense(compere.getDefense());
//                    detail.setLife(compere.getLife());
//                }
//            } else {
//                detail.setAttack(player.getAttack());
//                detail.setDefense(player.getDefense());
//                detail.setLife(player.getLife());
//            }
//
//            Long profit = miningCacheController.queryUserDayProfit(userId,
//                    cache);
//            detail.setDayProfit(profit);
//
//            List<TMiningGameSection> segments = miningCacheController
//                    .queryMineSegs(activityId, cache);
//            detail.setMineSegList(segments);
//
//            int attackerCount = 0;
//            for (TMiningGameSection section : segments) {
//                if (Constants.MINE_SEC_STATUS_IN_BATTLE
//                        .equals(section.getStatus())) {
//                    attackerCount++;
//                }
//            }
//            detail.setAttackNum(attackerCount);
//
//            detail.setMinDigSecond(Constants.MIN_DIG_SECOND);
//
//            Integer reviveTime = Integer.parseInt(baseCacheController
//                    .queryConfig(Constants.REVIVE_TIME, cache));
//            detail.setReviveTime(reviveTime);
//
////            LOG.info(detail.toString());
//
//            return detail;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 查询采矿活动攻击防守人员列表
//     *
//     * @param activityId
//     * @return
//     */
//    public List<CacheUserProfile> queryAttackerList(Long activityId)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            TMiningGame activity = miningCacheController
//                    .queryMiningGameByActivityId(cache, activityId);
//            if (activity == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "采矿活动不存在！");
//            }
//            List<CacheUserProfile> list = miningCacheController
//                    .queryAttackerList(activityId, cache);
//            return list;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public List<CacheUserProfile> queryDefenderList(Long societyId)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            List<CacheUserProfile> list = societyCacheController
//                    .querySocietyOnlineUsers(societyId, cache);
//            Iterator<CacheUserProfile> iterator = list.iterator();
//            while (iterator.hasNext()) {
//                CacheUserProfile profile = iterator.next();
//                if (profile.
//                        getLife() == null || profile.getLife() == 0) {
//                    iterator.remove();
//                }
//            }
//            return list;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 采矿最大战斗回合数
//     *
//     * @return
//     */
//    public Integer queryMaxFightRound() throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            String round = baseCacheController
//                    .queryConfig(Constants.MAX_FIGHT_ROUND, cache);
//            return Integer.parseInt(round);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 开始抢矿
//     *
//     * @param userId
//     * @param activityId
//     */
//    public List<MiningResultVo> startMining(Long userId, Long activityId, Long mineSectionId, String userType)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            // 判断采矿活动中是否有可采剩余
//            TMiningGame activity = miningCacheController
//                    .queryMiningGameByActivityId(cache, activityId);
//            if (activity == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "采矿活动不存在！");
//            }
//            if (activity.getRealAmount() <= 0) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "矿已被采光！");
//            }
//
//            checkMineSec(activityId, userId, mineSectionId, cache);
//
//            // 更新采矿剩余次数
//            miningCacheController.decreaseUserLeftDigCount(userId, cache, userType);
//            //重置采集轮数
//            Integer round = Integer.parseInt(baseCacheController.queryConfig(Constants.MAX_FIGHT_ROUND, cache));
//            miningCacheController.updateLeftDigPerRound(userId, cache, round);
//
//            // redis
//            TMiningGameSection section = miningCacheController
//                    .queryMineSegById(activityId, mineSectionId, cache);
//            section.setAttackerId(userId);
//            section.setStatus(Constants.MINE_SEC_STATUS_IN_BATTLE);
//            miningCacheController.updateMineSeg(section, cache);
//
//            CacheUserProfile profile = null;
//            if(userType.equalsIgnoreCase(Constants.USER_TYPE_C)) {
//                profile = compereCacheController
//                        .getCompereDetail(userId.toString(), cache, false, false);
//            } else if (userType.equalsIgnoreCase(Constants.USER_TYPE_P)) {
//                profile = playerCacheController
//                        .queryPlayerDetail(userId, cache, false, false);
//
//            }
//            if (profile != null) {
//                miningCacheController.updateAttacker(profile, cache);
//            }
//
//            // 发送环信消息刷新界面
//            sendRefreshMineMessage(activityId, cache);
//
//            List<MiningResultVo> resultVoList = new ArrayList<MiningResultVo>();
//            MiningResultVo resultVo = new MiningResultVo();
//            String str = baseCacheController.queryConfig(Constants.MAX_FIGHT_ROUND, cache);
//            Integer totalRound = Integer.parseInt(str);
//            MiningDig miningDig = dig(userId, activityId, mineSectionId, userType);
//            resultVo.setRound(1);
//            resultVo.setMiningDig(miningDig);
//            resultVoList.add(resultVo);
//            if (!miningDig.isEmpty()) {
//                for (int i = 1; i < totalRound; i++) { //扣除掉第一次挖的保底收益
//                    resultVo = new MiningResultVo();
//                    BattleResult battleResult = battleResult(userId, activityId, userType);
//                    resultVo.setRound(i + 1);
//                    resultVo.setBattleResult(battleResult);
//                    if (battleResult.isWin() == false) {
//                        resultVoList.add(resultVo);
//                        break;
//                    }
//                    miningDig = dig(userId, activityId, mineSectionId, userType);
//                    resultVo.setMiningDig(miningDig);
//                    resultVoList.add(resultVo);
//                    if (miningDig.isEmpty()) {
//                        break;
//                    }
//                }
//            }
//            return resultVoList;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 执行战斗过程，返回结果
//     *
//     * @param userId
//     * @param activityId
//     * @throws Exception
//     */
//    public BattleResult battleResult(Long userId, Long activityId, String userType)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            // 判断采矿活动中是否有可采剩余
//            TMiningGame activity = miningCacheController
//                    .queryMiningGameByActivityId(cache, activityId);
//            if (activity == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "采矿活动不存在！");
//            }
//            if (activity.getRealAmount() <= 0) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "矿已被采光！");
//            }
//            BattleResult result = new BattleResult();
//            List<TMiningGameSection> segList = miningCacheController
//                    .queryMineSegs(activityId, cache);
//            Long mineSectionId = null;
//            for (TMiningGameSection seg : segList) {
//                if (userId.equals(seg.getAttackerId())) {
//                    mineSectionId = seg.getMineSectionId();
//                    break;
//                }
//            }
//            if (mineSectionId == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "找不到可抢矿位！");
//            }
//
//            boolean hasDefender = fight(userId, activityId, userType, cache);
//
//            // Long profit = dig(userId, activityId, mineSectionId, cache);
//
//            CachePlayerProfile player = miningCacheController
//                    .queryAttacker(userId, cache);
//            if (player.getLife() > 0) {
//                result.setWin(true);
//            } else {
//                result.setWin(false);
//                // 战斗失败，释放矿坑
////                TMiningGameSection sec = miningCacheController
////                        .queryMineSegById(activityId, mineSectionId, cache);
////                sec.setAttackerId(null);
////                sec.setStatus(Constants.MINE_SEC_STATUS_AVALIABLE);
////                miningCacheController.updateMineSeg(sec, cache);
//
//                // 发送环信消息刷新界面
////                sendRefreshMineMessage(activityId, cache);
//            }
//            // result.setProfit(profit);
//            result.setLife(player.getLife());
//            result.setHasDefender(hasDefender);
//            return result;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 释放矿坑
//     *
//     * @param mineSectionId
//     */
//    public void releaseSection(Long mineSectionId, Long activityId)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            TMiningGameSection section = miningCacheController
//                    .queryMineSegById(activityId, mineSectionId, cache);
//            if (section == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "矿坑不存在！");
//            }
//            section.setAttackerId(null);
//            if (section.getAvailableAmount() == 0) {
//                section.setStatus(Constants.MINE_SEC_STATUS_EMPTY);
//            } else {
//                section.setStatus(Constants.MINE_SEC_STATUS_AVALIABLE);
//            }
//            miningCacheController.updateMineSeg(section, cache);
//
//            sendRefreshMineMessage(activityId, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 查询采矿活动是否有防守者
//     *
//     * @param activityId
//     * @return
//     */
//    public boolean hasDefender(Long activityId) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            TMiningGame miningGame = miningCacheController
//                    .queryMiningGameByActivityId(cache, activityId);
//            Long societyId = miningGame.getSocietyId();
//
//            List<CacheUserProfile> userList = societyCacheController
//                    .querySocietyOnlineUsers(societyId, cache);
//
//            Iterator<CacheUserProfile> iterator = userList.iterator();
//            while (iterator.hasNext()) {
//                CacheUserProfile profile = iterator.next();
//                if (profile.getLife() == null || profile.getLife() == 0) {
//                    iterator.remove();
//                }
//            }
//
//            if (userList.isEmpty()) {
//                return false;
//            } else {
//                return true;
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 采矿动作，算出采集量后更新数据库和缓存
//     *
//     * @param userId
//     * @param activityId
//     * @param mineSectionId
//     * @return
//     * @throws Exception
//     */
//    public MiningDig dig(Long userId, Long activityId, Long mineSectionId, String userType)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            // 判断采矿活动中是否有可采剩余
//            TMiningGame activity = miningCacheController
//                    .queryMiningGameByActivityId(cache, activityId);
//            if (activity == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "采矿活动不存在！");
//            }
//            if (activity.getRealAmount() <= 0) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "矿已被采光！");
//            }
//            CacheSocietyProfile societyProfile = societyCacheController
//                    .querySocietyDetail(activity.getSocietyId(), cache);
//            if(societyProfile.getCumulation() <= 0) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "矿已被采光！");
//            }
//
//            TMiningGameSection section = miningCacheController
//                    .queryMineSegById(activityId, mineSectionId, cache);
//
//            if (section == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "找不到矿坑！");
//            }
//
//            MiningDig miningDig = new MiningDig();
//            List<TUserGame> gameList = commonCacheController
//                    .queryUserGameDanByUserId(userId, cache);
//            Long totalLevel = 0L;
//            for (TUserGame game : gameList) {
//                totalLevel = totalLevel + game.getLevel();
//            }
//            Long profit = totalLevel * Constants.DIG_PER_SECOND
//                    * Constants.MIN_DIG_SECOND;
//
//            // 更新抢矿时间戳
//            section.setTimestamp(new Date());
//
//            if (section.getAvailableAmount() <= 0l) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "矿已被采光！");
//            }
//
//            if (profit >= section.getAvailableAmount()) {
//
//                // 更新矿坑，已采空
//                profit = section.getAvailableAmount();
//                section.setAvailableAmount(0L);
//                section.setMinedAmount(section.getMinedAmount() + profit);
//                section.setAttackerId(null);
//                section.setStatus(Constants.MINE_SEC_STATUS_EMPTY);
//                miningCacheController.updateMineSeg(section, cache);
//
//                miningDig.setEmpty(true);
//                // 发送环信消息刷新界面
////                sendRefreshMineMessage(activityId, cache);
//                miningCacheController.increaseDigProfit(userId, profit, cache);
//                flushDig2DB(userId, activityId, userType, cache);
//            } else {
//                // 更新矿坑，未采空
//                section.setAvailableAmount(section.getAvailableAmount() - profit);
//                section.setMinedAmount(section.getMinedAmount() + profit);
//                miningCacheController.updateMineSeg(section, cache);
//                miningDig.setEmpty(false);
//                //减采矿轮数
//                Integer curRound = miningCacheController.queryLeftDigPerRound(userId, cache);
//                curRound -= 1;
//                miningCacheController.updateLeftDigPerRound(userId, cache, curRound);
//                // 写缓存
//                miningCacheController.increaseDigProfit(userId, profit, cache);
//                if (curRound ==0) {
//                    flushDig2DB(userId, activityId, userType, cache);
//                }
//            }
//            miningDig.setProfit(profit);
//            return miningDig;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 爆矿
//     *
//     * @param societyId
//     * @param fullAmount
//     * @throws Exception
//     */
//    public void boomMine(Long societyId, Long fullAmount) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
////            CacheSocietyProfile society = societyCacheController.querySocietyDetail(societyId, cache);
////            if (!society.getStatus().equals(Constants.SOCIETY_VALID)) { // 状态不对，不允许爆矿
////                return;
////            }
//            TMiningGame gameActivity = new TMiningGame();
//
//            Integer mineExistMinutes = Integer.parseInt(baseCacheController
//                    .queryConfig(Constants.MINE_EXIST_MINUTES, cache));
//            SimpleDateFormat format = new SimpleDateFormat(
//                    "yyyy-MM-dd HH:mm:ss");
//            Calendar nowTime = Calendar.getInstance();
//            Date startDate = nowTime.getTime();
//            nowTime.add(Calendar.MINUTE, mineExistMinutes);
////            nowTime.add(Calendar.MINUTE, 2);
//            Date endDate = nowTime.getTime();
//            Long activityId = idService.generateId(TMiningGame.class.getName());
//
//            gameActivity.setStartDate(format.format(startDate));
//            gameActivity.setEndDate(format.format(endDate));
//            gameActivity.setActivityId(activityId);
//            gameActivity.setFullAmount(fullAmount);
//            gameActivity.setSocietyId(societyId);
//            gameActivity.setRealAmount(fullAmount);
//            miningGameMapper.insert(gameActivity);
//            // 公会状态修改为爆矿
////            societyMapper.updateSocietyStatus(societyId,
////                    Constants.SOCIETY_BOOM);
//
//            // redis中初始化该采矿活动的矿坑
//            miningCacheController.initMineSection(activityId, fullAmount, cache);
//
//            miningCacheController.boomMine(gameActivity,
//                    Constants.SOCIETY_BOOM, cache);
//
//            // 添加定时任务时间到了之后将状态改回来
//            ScheduleJob scheduleJob = new ScheduleJob();
//            scheduleJob.setJobId(activityId.toString());
//            scheduleJob.setJobGroup("boomMine");
//            /**
//             * 时间转换
//             */
//            Calendar calendar = Calendar.getInstance();
//            calendar.setTime(endDate);
//            String cronExpression = calendar.get(Calendar.SECOND) + " "
//                    + (calendar.get(Calendar.MINUTE)) + " "
//                    + calendar.get(Calendar.HOUR_OF_DAY) + " "
//                    + calendar.get(Calendar.DAY_OF_MONTH) + " "
//                    + (calendar.get(Calendar.MONTH) + 1) + " ? "
//                    + calendar.get(Calendar.YEAR);
//
//            scheduleJob.setCronExpression(cronExpression);
//            scheduleJob.setBeanName("boomMineScheduleService");
//            scheduleJob.setMethodType(1);
//            scheduleJob.setData(societyId.toString());
//            scheduleJob.setEndDate(endDate);
//            dynamicScheduleService.enableSchedule(scheduleJob);
//
//            JSONObject json = new JSONObject();
//            json.put("boom", "true");
//            PushUtil.push(Constants.BOOM, json);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 进入采矿活动界面
//     *
//     * @param userId
//     */
//    public void enterMiningActivity(Long activityId, Long userId)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            miningCacheController.enterMiningActivity(activityId, userId,
//                    cache);
//            sendRefreshMineMessage(activityId, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 退出采矿活动界面
//     *
//     * @param userId
//     */
//    public void exitMiningActivity(Long activityId, Long userId)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            miningCacheController.exitMiningActivity(activityId, userId,
//                    cache);
//            sendRefreshMineMessage(activityId, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 战斗过程
//     *
//     * @param userId
//     * @param activityId
//     * @throws Exception
//     */
//    private boolean fight(Long userId, Long activityId, String userType, ICache cache)
//            throws Exception {
//        TMiningGame miningGame = miningCacheController
//                .queryMiningGameByActivityId(cache, activityId);
//        Long societyId = miningGame.getSocietyId();
//        List<CacheUserProfile> userList = societyCacheController
//                .querySocietyOnlineUsers(societyId, cache);
//        Iterator<CacheUserProfile> iterator = userList.iterator();
//        while (iterator.hasNext()) {
//            CacheUserProfile profile = iterator.next();
//            if (profile.getLife() == null || profile.getLife() == 0) {
//                iterator.remove();
//            }
//        }
//
//        Random rand = new Random();
//        if (!userList.isEmpty()) {
//
//            int randNum = 0;
//            if (userList.size() > 1) {
//                randNum = rand.nextInt(userList.size() - 1);
//            }
//            CacheUserProfile defender = userList.get(randNum);
//            CacheUserProfile attacker = miningCacheController
//                    .queryAttacker(userId, cache);
//            while (fightRound(attacker, defender, cache)) {
//                continue;
//            }
//            // 更新攻守方缓存的血量
//            miningCacheController.updateAttacker(attacker, cache);
//            miningCacheController.updateDefender(defender, activityId, cache);
////            societyCacheController.updateSocietyPlayerById(societyId, defender,
////                    cache);
//            if(attacker.getLife().equals(0L) || defender.getLife().equals(0L)) {//攻击人员被打死，调用flush方法将更新收益
//                flushDig2DB(userId, activityId, userType, cache);
//            }
//            return true;
//        } else { // 没有防守人员
//            return false;
//        }
//    }
//
//    /**
//     * 计算一回合战斗结果
//     *
//     * @param attacker
//     * @param defender
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    private boolean fightRound(CacheUserProfile attacker, CacheUserProfile defender, ICache cache) throws Exception {
//        Long attack1 = attacker.getAttack();
//        Long defense1 = attacker.getDefense();
//        Long life1 = attacker.getLife();
//
//        Long attack2 = defender.getAttack();
//        Long defense2 = defender.getDefense();
//        Long life2 = defender.getLife();
//
//        List<TUserGame> attackerGames = commonCacheController
//                .queryUserGameDanByUserId(Long.parseLong(attacker.getUserId()), cache);
//        Integer attackerDans = 0;
//        for (TUserGame t : attackerGames) {
//            attackerDans += t.getLevel();
//        }
//
//        List<TUserGame> defenderGames = commonCacheController
//                .queryUserGameDanByUserId(Long.parseLong(defender.getUserId()), cache);
//        Integer defenderDans = 0;
//        for (TUserGame t : defenderGames) {
//            defenderDans += t.getLevel();
//        }
//
//        Long attackerDamage = FightUtil.calculateDamage(attack1, defense2, attackerDans);
//        life2 = life2 - attackerDamage;
//        if (life2 <= 0) {
//            life2 = 0l;
//            defender.setLife(life2);
//            return false;
//        }
//        defender.setLife(life2);
//
//        Long defenderDamage = FightUtil.calculateDamage(attack2, defense1, defenderDans);
//        life1 = life1 - defenderDamage;
//        if (life1 <= 0) {
//            life1 = 0l;
//            // 更新采矿剩余次数
//            // societyCacheController.decreaseUserLeftDigCount(
//            // Long.parseLong(attacker.getUserId()), cache, -1);
//            attacker.setLife(life1);
//            return false;
//        }
//        attacker.setLife(life1);
//        return true;
//    }
//
//    /**
//     * 将缓存的采矿收益变动写进redis及数据库
//     * @param userId
//     * @param activityId
//     * @param cache
//     * @throws Exception
//     */
//    private void flushDig2DB(Long userId, Long activityId, String userType, ICache cache) throws Exception {
//        Long totalProfit = miningCacheController.queryDigProfit(userId, cache);
//        // 更新采矿活动表
//        miningGameMapper.updateRealAmount(-totalProfit, activityId);
//
//        // 更新公会表当前矿量
//        TMiningGame game = miningCacheController
//                .queryMiningGameByActivityId(cache, activityId);
//        societyMapper.updateSocietyMine(game.getSocietyId(), -totalProfit);
//
//        // 更新抢矿人游戏币，玩家详情，玩家列表缓存
//        GameServerUtil.invokeUpdateCoin(userId, totalProfit.intValue());
//
//        //更新缓存
//        miningCacheController.updateMiningCache(userId, activityId, totalProfit, cache);
//
//        //更新主播收入
//        if (Constants.USER_TYPE_C.equalsIgnoreCase(userType)) {
//            Date nowDate = new Date();
//            String incomeDateStr = DateUtils.getParseDate(nowDate, "yyyy-MM-dd");
//            int incomeCount = compereIncomeMapper.addMiningIncome(userId, totalProfit.intValue(), nowDate, incomeDateStr);
//            if (incomeCount > 0) {
//                compereCacheController.addMiningIncome(userId, incomeDateStr, totalProfit.intValue(), cache);
//            }
//        }
//    }
//
//    /**
//     * 检查矿坑，若有可用，改状态
//     *
//     * @param activityId
//     * @param userId
//     * @param mineSectionId
//     * @param cache
//     * @throws Exception
//     */
//    private void checkMineSec(Long activityId, Long userId, Long mineSectionId,
//            ICache cache) throws Exception {
//        List<TMiningGameSection> sections = miningCacheController
//                .queryMineSegs(activityId, cache);
//        for (TMiningGameSection sec : sections) {
//            if (userId.equals(sec.getAttackerId())) { // 矿坑列表有此玩家且该矿坑不是该玩家的矿坑，抛异常
//                if (sec.getMineSectionId() != mineSectionId) {
//                    throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                            "您已有矿坑！");
//                }
//            }
//        }
//
//        TMiningGameSection section = miningCacheController
//                .queryMineSegById(activityId, mineSectionId, cache);
//        // 判断矿坑是否仍可采
//        if (section.getAvailableAmount() <= 0 || Constants.MINE_SEC_STATUS_EMPTY
//                .equals(section.getStatus())) {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, "矿已被采光！");
//        }
//        // 判断矿坑是否被占
//        if (Constants.MINE_SEC_STATUS_IN_BATTLE.equals(section.getStatus())) {
//            // 当前玩家不是矿坑采矿玩家
//            if (section.getAttackerId().intValue() != userId.intValue()) {
//                // 判断当前矿坑时间戳，是否超时
//                if (section.getTimestamp() == null) {
//                    section.setTimestamp(new Date());
//                }
//                if (System.currentTimeMillis() - section.getTimestamp()
//                        .getTime() > Constants.MAX_MINE_VALID_TIME * 1000) {
//                    section.setAttackerId(userId);
//                } else {
//                    throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                            "该矿坑已有人在采！");
//                }
//            }
//        }
//    }
//
//    /**
//     * 发送聊天室消息刷新界面
//     *
//     * @param activityId
//     * @param cache
//     * @throws Exception
//     */
//    private void sendRefreshMineMessage(Long activityId, ICache cache)
//            throws Exception {
//        TMiningGame miningGame = miningCacheController
//                .queryMiningGameByActivityId(cache, activityId);
//        if(miningGame != null) {
//            Long societyId = miningGame.getSocietyId();
//            String chatroomId = societyCacheController
//                    .querySocietyDetail(societyId, cache).getChatroomId();
//            easeMobService.refreshMine(chatroomId);
//        }
//    }
//}
