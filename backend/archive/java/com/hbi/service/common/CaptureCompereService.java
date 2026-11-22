//package com.hbi.service.common;
//
//import java.util.ArrayList;
//import java.util.Calendar;
//import java.util.Date;
//import java.util.List;
//
//import com.hbi.model.*;
//import com.hbi.service.helper.VipValidator;
//import org.apache.commons.collections.CollectionUtils;
//import org.apache.commons.lang.StringUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.alibaba.fastjson.JSONObject;
//import com.core.service.BaseService;
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.BaseCacheController;
//import com.hbi.cache.controller.CaptureCacheController;
//import com.hbi.cache.controller.CommonCacheController;
//import com.hbi.cache.controller.CompereCacheController;
//import com.hbi.cache.controller.PlayerCacheController;
//import com.hbi.cache.model.CacheCompereProfile;
//import com.hbi.cache.model.CachePlayerProfile;
//import com.hbi.cache.model.CacheUserListProfile;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TCaptureDefenderMapper;
//import com.hbi.mapper.TCompereMapper;
//import com.hbi.mapper.TUserGoodsMapper;
//import com.hbi.schedule.model.ScheduleJob;
//import com.hbi.schedule.service.DynamicScheduleService;
//import com.hbi.service.idGenerate.GenerateIdService;
//import com.hbi.utils.GameServerUtil;
//import com.hbi.utils.InfServerException;
//
//@Service
//public class CaptureCompereService extends BaseService<TCaptureDefender> {
//
//    private static final String COMPERE_FIELD_CAPTUREATTACK = "captureAttack";
//    @Autowired
//    private CaptureCacheController captureCacheController;
//    @Autowired
//    private CompereCacheController compereCacheController;
//    @Autowired
//    private PlayerCacheController playerCacheController;
//    @Autowired
//    private BaseCacheController baseCacheController;
//    @Autowired
//    private CommonCacheController commonCacheController;
//    @Autowired
//    private TCompereMapper compereMapper;
//    @Autowired
//    private TUserGoodsMapper userGoodsMapper;
//    @Autowired
//    private TCaptureDefenderMapper defenderMapper;
//    @Autowired
//    private UserTaskService userTaskService;
//    @Autowired
//    private ExtractService extractService;
//    @Autowired
//    private DynamicScheduleService dynamicScheduleService;
//    @Autowired
//    private GenerateIdService idService;
//    @Autowired
//    private VipValidator vipValidator;
//
//    /**
//     * 查看主播的被抓状态
//     *
//     * @param compereId
//     * @return
//     * @throws Exception
//     */
//    public CaptureInfo getCompereCaptureStatus(Long compereId)
//            throws Exception {
//
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            CaptureInfo captureInfo = new CaptureInfo();
//            List<TCaptureDefender> defender = captureCacheController
//                    .queryCaptureInfoByCompere(compereId, cache);
//            captureInfo.setDefenderList(defender);
//
//            CacheCompereProfile compere = compereCacheController
//                    .getCompereDetail(compereId.toString(), cache, false, false);
//            captureInfo.setCaptureStatus(compere.getCaptureStatus());
//            captureInfo.setOwnerId(compere.getOwnerId());
//            captureInfo.setComperePhoto(compere.getPhotoUrl());
//
//            if (compere.getOwnerId() != null) {
//                CachePlayerProfile owner = playerCacheController
//                        .queryPlayerDetail(compere.getOwnerId(), cache, false, false);
//                captureInfo.setOwner(owner.getNickName());
//            }
//
//            captureInfo.setTitle(compere.getTitle());
////            captureInfo.setLeftLife(compere.getLeftLife());
//            captureInfo.setLeftLife(captureCacheController.queryCompereLeftLife(compere.getCityId(), compereId, cache));
////            captureInfo.setTotalLife(compere.getTotalLife());
//            captureInfo.setTotalLife(captureCacheController.queryCompereTotalLife(compere.getCityId(), compereId, cache));
//
//            return captureInfo;
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
//     * 查看赎身详情
//     *
//     * @param compereId
//     * @return
//     */
//    public RansomInfo getRansomDetail(Long compereId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            RansomInfo info = new RansomInfo();
//            CacheCompereProfile compere = compereCacheController
//                    .getCompereDetail(compereId.toString(), cache, false, false);
//            if (!compere.getCaptureStatus().equals(Constants.CAPTURE_CATCH)) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "该主播没有被抓！");
//            }
//            info.setOwnerId(compere.getOwnerId());
//            if (compere.getOwnerId() != null) {
//                CachePlayerProfile owner = playerCacheController
//                        .queryPlayerDetail(compere.getOwnerId(), cache, false, false);
//                info.setOwner(owner.getNickName());
//            }
//
//            info.setReducedProfit(compere.getSharedProfit());
//
//            if (compere.getLevel() != null) {
//                TCompereLevel level = baseCacheController
//                        .queryCompereLevelByLevel(
//                                compere.getLevel(), cache);
//                Integer ownHour = Integer.parseInt(baseCacheController
//                        .queryConfig(Constants.CAPTURE_OWN, cache));
//
//                if (level != null && compere.getReleaseTime() != null
//                        && level.getNeedRansomCardCount() != null) {
//                    Integer totalCardNum = level.getNeedRansomCardCount();
//                    Long curTime = new Date().getTime();
//                    Long releaseTime = compere.getReleaseTime().getTime();
//
//                    // 剩余关押时间
//                    info.setLeftTime(releaseTime - curTime);
//
//                    Integer leftHour = (int) ((releaseTime - curTime)
//                            / (3600 * 1000));
//                    float cardPerHour = ((float) totalCardNum / ownHour);
//
//                    // 所需剩余赎身卡
//                    Integer leftCardCount = (int) (leftHour * cardPerHour);
//                    if (leftCardCount < 0) {
//                        leftCardCount = 0;
//                    }
//                    info.setNeedRansomCardCount(leftCardCount);
//
//                    // 主播现有赎身卡
//                    List<TUserGoods> goods = commonCacheController
//                            .queryUserGoodsByUserId(compereId,
//                                    Constants.GOODS_TYPE_RANSOM_CARD, cache);
//                    if (CollectionUtils.isEmpty(goods)) {
//                        info.setCurRansomCardNum(0);
//                    } else {
//                        Integer cardCount = goods.get(0).getAmount();
//                        info.setCurRansomCardNum(cardCount);
//                    }
//                } else {
//                    throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                            "找不到该主播等级！");
//                }
//            }
//
//            return info;
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
//     * 查看我的守护
//     *
//     * @param playerId
//     * @return
//     */
////    public List<PlayerDefender> getMyDefendCompere(Long playerId)
////            throws Exception {
////        ICache cache = null;
////        try {
////            cache = CacheManager.getCache();
////            List<PlayerDefender> playerDefenders = new ArrayList<PlayerDefender>();
////            List<TCaptureDefender> defenders = captureCacheController
////                    .queryCaptureInfoByPlayer(playerId, cache);
////            for (TCaptureDefender defender : defenders) {
////
////                PlayerDefender playerDefender = new PlayerDefender();
////                CacheCompereProfile compere = compereCacheController
////                        .getCompereDetail(defender.getCompereId().toString(),
////                                cache);
////                playerDefender.setCompere(compere);
////                playerDefender.setLeftTime(
////                        defender.getEndDate().getTime() - new Date().getTime());
////                if (!playerDefenders.contains(playerDefender)) {
////                    playerDefenders.add(playerDefender);
////                }
////            }
////            return playerDefenders;
////        } catch (Exception e) {
////            throw e;
////        } finally {
////            if (cache != null) {
////                CacheManager.releaseCache(cache);
////            }
////        }
////    }
//    public List<TCaptureDefender> getMyDefendCompere(Long playerId)
//            throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            return captureCacheController.queryCaptureInfoByPlayer(playerId, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public List<TCaptureDefender> getMyDefendPlayer(Long compereId)
//            throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            return captureCacheController.queryCaptureInfoByCompere(compereId, cache);
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
//     * 查看我的后宫
//     *
//     * @param playerId
//     * @return
//     */
//    public List<CacheCompereProfile> getMyWives(Long playerId)
//            throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<Long> wifeIds = captureCacheController.queryMyWivesId(playerId,
//                    cache);
//            List<CacheCompereProfile> wives = new ArrayList<CacheCompereProfile>();
//            for (Long wifeId : wifeIds) {
//                CacheCompereProfile compere = compereCacheController
//                        .getCompereDetail(wifeId.toString(), cache, false, false);
//                wives.add(compere);
//            }
//            return wives;
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
//     * 释放主播
//     *
//     * @param compereId
//     */
//    public void releaseCompere(Long playerId, Long compereId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            CacheCompereProfile compereProfile = compereCacheController
//                    .getCompereDetail(compereId.toString(), cache, false, false);
//
//            cache = CacheManager.getCache();
//            Calendar c = Calendar.getInstance();
//            c.setTime(new Date());
//            Integer protectHour = Integer.parseInt(baseCacheController
//                    .queryConfig(Constants.CAPTURE_PROTECT_HOURS, cache));
//            c.add(Calendar.HOUR, protectHour);
//            unProtectCompereJob(compereId, c);
//            compereMapper.releaseCompere(c.getTime(), Constants.CAPTURE_PROTECT,
//                    compereId);
//            dynamicScheduleService.removeSchedule(compereId.toString(),
//                    "captureCompere");
//            captureCacheController.releaseCompere(playerId, compereId, c.getTime(),
//                    cache);
//            // 发送消息给主播
//            sendCaptureMessage(compereProfile, "release");
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
//     * 解除主播保护
//     *
//     * @param compereId
//     * @throws Exception
//     */
//    public void unProtectCompere(Long compereId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            compereMapper.unProtectCompere(Constants.CAPTURE_FREE, compereId);
//            captureCacheController.unProtectCompere(compereId, cache);
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
//     * 使用赎身卡
//     *
//     * @param compereId
//     * @return
//     * @throws Exception
//     */
//    public UseRansomInfo useRansomCard(Long playerId, Long compereId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            RansomInfo ransomInfo = getRansomDetail(compereId);
//            UseRansomInfo useRansomInfo = new UseRansomInfo();
//            TUserGoods card = new TUserGoods();
//            List<TUserGoods> goodsList = commonCacheController.queryUserGoodsByUserId(
//                    compereId, Constants.GOODS_TYPE_RANSOM_CARD, cache);
//            if (goodsList.size() == 0) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您还没有赎身卡");
//            }
//            TUserGoods temp = goodsList.get(0);
//            card.setId(temp.getId());
//            card = userGoodsMapper.selectOne(card);
//            if (card.getAmount() >= ransomInfo.getNeedRansomCardCount()) { // 赎身卡足够
//                int leftCardCount = card.getAmount()
//                        - ransomInfo.getNeedRansomCardCount();
//                // 修改赎身卡数量：1数据库；2缓存
//                Integer singlePrice = card.getTotalPrice() / card.getAmount();
//                card.setAmount(ransomInfo.getNeedRansomCardCount());
//                card.setTotalPrice(
//                        singlePrice * ransomInfo.getNeedRansomCardCount());
//                userGoodsMapper.reduceUserGoodsAmount(card);
//                extractService.captureCompereRansomExtract(playerId, card.getTotalPrice(), ransomInfo.getNeedRansomCardCount(), compereId, null, new Date(), cache);
//                // 释放主播
//                releaseCompere(playerId, compereId);
//
//
//                commonCacheController.reduceGoods(card, cache);
//                useRansomInfo.setCaptureStatus(Constants.CAPTURE_FREE);
//            } else { // 赎身卡不足够，减时间
//                CacheCompereProfile compere = compereCacheController
//                        .getCompereDetail(compereId.toString(), cache, false, false);
//                Long leftTime = ransomInfo.getLeftTime();
//                Integer reducedHours = (int) ((float) card.getAmount()
//                        / ransomInfo.getNeedRansomCardCount() * leftTime / 1000
//                        / 3600);
//                Calendar c = Calendar.getInstance();
//                c.setTime(compere.getReleaseTime());
//                c.add(Calendar.HOUR, -reducedHours);
//                Date afterUse = c.getTime();
//
//                TCompere tCompere = new TCompere();
//                tCompere.setCompereId(compereId);
//                tCompere.setReleaseTime(afterUse);
//
//                compereMapper.updateByPrimaryKeySelective(tCompere);
//                userGoodsMapper.reduceUserGoodsAmount(card);
//                extractService.captureCompereRansomExtract(playerId, card.getTotalPrice(), ransomInfo.getNeedRansomCardCount(), compereId, null, new Date(), cache);
//                releaseCompereJob(playerId, compereId, c); // 修改定时任务时间
//
//                useRansomInfo.setCaptureStatus(Constants.CAPTURE_CATCH);
//                useRansomInfo.setLeftTime(afterUse);
//
//                captureCacheController.updateReleaseTime(compereId, afterUse,
//                        cache);
//                captureCacheController.useRansomCard(compereId, 0, cache);
//            }
//            return useRansomInfo;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//    public CaptureFightInfo startFighting(Long compereId, Long playerId) throws Exception{
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            Integer captureTimes = captureCacheController
//                    .queryCaptureLeftTimes(playerId, cache);
//            if (captureTimes <= 0) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "您已没有战斗次数！");
//            }
//            List<CacheCompereProfile> wives = getMyWives(playerId);
//            if (wives.size() >= 10) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "您所抢主播已达上限！");
//            }
//            // 更新抢主播每日任务
//            userTaskService.updateUserDailyTask(playerId, Constants.USER_TYPE_P, Constants.TASK_CAPTURE_COMPERE, 1, cache);
//            captureCacheController.updateCaptureTimes(playerId, -1, cache);
//
//            return fightRound(compereId, playerId);
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
//     * 抓主播战斗一回合
//     *
//     * @param compereId
//     * @param playerId
//     * @return
//     * @throws Exception
//     */
//    public CaptureFightInfo fightRound(Long compereId, Long playerId)
//            throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//
//            if(compereCacheController.lockCompere(compereId)) {
//                try {
//                    CacheCompereProfile compere = compereCacheController
//                            .getCompereDetail(compereId.toString(), cache, false, false);
//                    if (!compere.getCaptureStatus().equals(Constants.CAPTURE_FREE)) {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                                "主播状态不正确！");
//                    }
//
//                    CaptureFightInfo fightInfo = new CaptureFightInfo();
//                    CachePlayerProfile player = captureCacheController
//                            .queryCaptureAttacker(playerId, cache);
//
//                    Long attack1 = player.getCaptureAttack();
//                    Long defense1 = player.getCaptureDefense();
//                    Long life1 = player.getCaptureLife();
//
//                    Long attack2 = compere.getCaptureAttack();
//                    Long defense2 = compere.getCaptureDefense();
////                    Long life2 = compere.getLeftLife();
//                    Long life2 = captureCacheController.queryCompereLeftLife(compere.getCityId(), compereId, cache);
//
//                    List<TUserGame> attackerGames = commonCacheController
//                            .queryUserGameDanByUserId(
//                                    Long.parseLong(player.getUserId()), cache);
//                    Integer attackerDans = 0;
//                    for (TUserGame t : attackerGames) {
//                        attackerDans += t.getLevel();
//                    }
//
//                    List<TUserGame> defenderGames = commonCacheController
//                            .queryUserGameDanByUserId(
//                                    Long.parseLong(compere.getUserId()), cache);
//                    Integer defenderDans = 0;
//                    for (TUserGame t : defenderGames) {
//                        defenderDans += t.getLevel();
//                    }
//
//                    Long attackerDamage = FightUtil.calculateDamage(attack1, defense2,
//                            attackerDans);
//                    if (attackerDamage > life2) {
//                        attackerDamage = life2;
//                    }
//                    captureCacheController.increaseCompereLeftLife(compere.getCityId(), compereId, -attackerDamage, cache);
//                    if (attackerDamage.equals(life2)) {// 主播被打死
//                        killCompere(playerId, compereId, cache, compere, life1, fightInfo);
//                    } else {// 主播没有被打死
//                        fightInfo.setCompereLeftLife(life2 - attackerDamage);
//                        Long defenderDamage = FightUtil.calculateDamage(attack2,
//                                defense1, defenderDans);
//                        if (defenderDamage > life1) {// 玩家被打死
//                            defenderDamage = life1;
//                            fightInfo.setPlayerLeftLife(0L);
//                        } else {// 玩家没有被打死
//                            fightInfo.setPlayerLeftLife(life1 - defenderDamage);
//                        }
//                        captureCacheController.updateAttackerLife(playerId, cache,
//                                -defenderDamage.intValue());
//                    }
//                    return fightInfo;
//                } catch (Exception e) {
//                    throw  e;
//                } finally {
//                    compereCacheController.unlockCompere(compereId);
//                }
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "连接超时！");
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
//     * 玩家使用技能
//     *
//     * @param compereId
//     * @param playerId
//     * @param spellId
//     * @return
//     * @throws Exception
//     */
//    public CaptureFightInfo castSpell(Long compereId, Long playerId,
//            Long spellId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            CacheCompereProfile compere = compereCacheController
//                    .getCompereDetail(compereId.toString(), cache, false, false);
//
//            CaptureFightInfo fightInfo = new CaptureFightInfo();
//            CachePlayerProfile attacker = captureCacheController
//                    .queryCaptureAttacker(playerId, cache);
//            CachePlayerProfile playerProfile = playerCacheController.queryPlayerDetail(playerId, cache, false, false);
//            Long playerTotalLife = playerProfile.getLife();
//            TCaptureSpell spell = captureCacheController.querySpell(spellId,
//                    cache);
//            if (spell.getCode().equals(Constants.REGENERATE)) {
//                if (!vipValidator.canCaptureRegenerate(playerProfile, cache)) {
//                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "VIP等级权限不够！");
//                }
//            } else {
//                if (!vipValidator.canCaptureSpell(playerProfile, cache)) {
//                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "VIP等级权限不够！");
//                }
//            }
//
//            int coinAmount = 0;
//            String coinResult = GameServerUtil.invokeQuery(playerId);
//            JSONObject jsonObject = JSONObject.parseObject(coinResult);
//            if (jsonObject.containsKey("coinAmount") && StringUtils
//                    .isNotBlank(jsonObject.getString("coinAmount"))) {
//                coinAmount = jsonObject.getInteger("coinAmount");
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "宝贝币账户不存在");
//            }
//            if (spell.getPrice().intValue() > coinAmount) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "余额不足！");
//            }
//
//            if(compereCacheController.lockCompere(compereId)) {
//                try {
//                    if (!compere.getCaptureStatus().equals(Constants.CAPTURE_FREE)) {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                                "主播状态不正确！");
//                    }
//
//                    Long life1 = attacker.getCaptureLife();
////                    Long life2 = compere.getLeftLife();
//                    Long life2 = captureCacheController.queryCompereLeftLife(compere.getCityId(), compereId, cache);
//                    if (spell.getCode().equals(Constants.REGENERATE)) {
//                        fightInfo.setCompereLeftLife(life2);
//                        Long newLife = life1 + spell.getEffect();
//                        if (newLife > playerTotalLife) {
//                            newLife = playerTotalLife;
//                        }
//                        fightInfo.setPlayerLeftLife(newLife);
//                        captureCacheController.updateAttackerLife(playerId, cache,
//                                (int) (newLife - life1));
//                        return fightInfo;
//                    } else {
//                        Long attackerDamage = (long) spell.getEffect();
//                        if (attackerDamage > life2) {
//                            attackerDamage = life2;
//                        }
//                        captureCacheController.increaseCompereLeftLife(compere.getCityId(), compereId, -attackerDamage, cache);
//                        if (attackerDamage.equals(life2)) {// 主播被打死
//                            killCompere(playerId, compereId, cache, compere, life1, fightInfo);
//                        } else {// 主播没有被打死
//                            fightInfo.setCompereLeftLife(life2 - attackerDamage);
//                            fightInfo.setPlayerLeftLife(life1);
//                        }
//                        // 减钱
//                        boolean updateResult = GameServerUtil.invokeUpdateCoin(playerId,
//                                -spell.getPrice().intValue());
//                        if (!updateResult) {
//                            throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                                    "更新账户宝贝币失败");
//                        }
//                        return fightInfo;
//                    }
//                } catch (Exception e) {
//                    throw  e;
//                } finally {
//                    compereCacheController.unlockCompere(compereId);
//                }
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "连接超时！");
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
//     * 购买守护之后重新计算守护时间
//     *
//     * @param playerId
//     * @param compereId
//     * @param defenderType
//     */
//    public void buyDefender(Long playerId, Long compereId, Integer defenderType)
//            throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<TCaptureDefender> defenders = captureCacheController
//                    .queryCaptureInfoByCompere(compereId, cache);
//            TCaptureDefender defender = null;
//            for (TCaptureDefender t : defenders) {
//                if (t.getPlayerId().equals(playerId)) {// 玩家已守护此主播
//                    defender = t;
//                    break;
//                }
//            }
//            Calendar c = Calendar.getInstance();
//            if (defender == null) {
//                c.setTime(new Date());
//            } else {
//                Date endDate = defender.getEndDate();
//                if (endDate.getTime() > new Date().getTime()) {// 守护时间未过期
//                    c.setTime(endDate);
//                } else {// 守护时间已过期
//                    c.setTime(new Date());
//                }
//            }
//            if (defenderType.equals(Constants.WEEK_DEFENDER)) {
//                c.add(Calendar.HOUR_OF_DAY, 7 * 24);
//            } else if (defenderType.equals(Constants.MONTH_DEFENDER)) {
//                c.add(Calendar.MONTH, 1);
//            } else if (defenderType.equals(Constants.YEAR_DEFENDER)) {
//                c.add(Calendar.YEAR, 1);
//            }
//            if (defender == null) {
//                defender = new TCaptureDefender();
//                defender.setCompereId(compereId);
//                defender.setPlayerId(playerId);
//                defender.setId(
//                        idService.generateId(TCaptureDefender.class.getName()));
//                defender.setStartDate(new Date());
//                defender.setEndDate(c.getTime());
//                defender.setType(defenderType);
//
//                CacheCompereProfile compere = compereCacheController.getCompereDetail(compereId.toString(), cache, false, false);
//                defender.setCompereBirthday(compere.getBirthday());
//                defender.setCompereGender(compere.getSex());
//                defender.setCompereNickname(compere.getNickName());
//                defender.setComperePhoto(compere.getPhotoUrl());
//                defender.setCompereLatitude(compere.getLatitude());
//                defender.setCompereLongitude(compere.getLongitude());
//
//                CachePlayerProfile player = playerCacheController.queryPlayerDetail(playerId, cache, false, false);
//                defender.setPlayerBirthday(player.getBirthday());
//                defender.setPlayerGender(player.getSex());
//                defender.setPlayerNickname(player.getNickName());
//                defender.setPlayerPhoto(player.getPhotoUrl());
//                defender.setPlayerLongitude(player.getLongitude());
//                defender.setPlayerLatitude(player.getLatitude());
//
//                if (defenderMapper.insert(defender) > 0) {
//                    captureCacheController.addCaptureCache(defender, cache);
//                }
//            } else {
//                if (defenderType < defender.getType()) { //买的守护等级比现有低，不覆盖
//                    defenderType = defender.getType();
//                }
//
//                if (defenderMapper.updateCaptureTime(defender.getId(),
//                        c.getTime(), defenderType) > 0) {
//                    defender.setEndDate(c.getTime());
//                    defender.setType(defenderType); //更新缓存的类型
//                    captureCacheController.updateCaptureCache(defender, cache);
//                }
//            }
//            //重新计算主播属性
//            calculateCaptureAttribute(compereId);
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
//     * 购买抢主播战斗次数
//     *
//     * @param playerId
//     * @throws Exception
//     */
//    public Integer buyCaptureFightTime(Long playerId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            int coinAmount = 0;
//            String coinResult = GameServerUtil.invokeQuery(playerId);
//            JSONObject jsonObject = JSONObject.parseObject(coinResult);
//            if (jsonObject.containsKey("coinAmount") && StringUtils
//                    .isNotBlank(jsonObject.getString("coinAmount"))) {
//                coinAmount = jsonObject.getInteger("coinAmount");
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "宝贝币账户不存在");
//            }
//            Integer captureTimeFee = Integer.parseInt(baseCacheController
//                    .queryConfig(Constants.CAPTURE_TIME_FEE, cache));
//            if (captureTimeFee > coinAmount) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "余额不足！");
//            }
//
//            // 减钱
//            boolean updateResult = GameServerUtil.invokeUpdateCoin(playerId,
//                    -captureTimeFee);
//            if (!updateResult) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "更新账户宝贝币失败");
//            }
//
//            captureCacheController.updateCaptureTimes(playerId, 1, cache);
//
//            return captureCacheController.queryCaptureLeftTimes(playerId, cache);
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
//     * 释放主播定时任务
//     *
//     * @param compereId
//     * @throws Exception
//     */
//    public void releaseCompereJob(Long playerId, Long compereId, Calendar c) throws Exception {
//        ScheduleJob scheduleJob = new ScheduleJob();
//        scheduleJob.setJobId(compereId.toString());
//        scheduleJob.setJobGroup("captureCompere");
//        /**
//         * 时间转换
//         */
//        String cronExpression = c.get(Calendar.SECOND) + " "
//                + (c.get(Calendar.MINUTE)) + " " + (c.get(Calendar.HOUR_OF_DAY))
//                + " " + c.get(Calendar.DAY_OF_MONTH) + " "
//                + (c.get(Calendar.MONTH) + 1) + " ? " + c.get(Calendar.YEAR);
//
//        scheduleJob.setCronExpression(cronExpression);
//        scheduleJob.setBeanName("releaseCaptureService");
//        scheduleJob.setMethodType(1);
//        scheduleJob.setEndDate(c.getTime());
//        JSONObject obj = new JSONObject();
//        obj.put("playerId", playerId);
//        obj.put("compereId", compereId);
//        scheduleJob.setData(obj.toString());
//        dynamicScheduleService.enableSchedule(scheduleJob);
//    }
//
//    public List<CacheUserListProfile> viewDefendPlayers(String compereId)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            return captureCacheController.queryDefenderInfoByCompereId(
//                    Long.parseLong(compereId), cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public CaptureFightInfo enterFightPage(Long compereId, Long playerId)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            CachePlayerProfile player = playerCacheController
//                    .queryPlayerDetail(playerId, cache, true, false);
//            if(!vipValidator.canCapture(player, cache)) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "VIP等级权限不够！");
//            }
//            CaptureFightInfo fightInfo = new CaptureFightInfo();
//
//            Integer captureTimes = captureCacheController
//                    .queryCaptureLeftTimes(playerId, cache);
//            fightInfo.setLeftCaptureTimes(captureTimes);
//
//            CachePlayerProfile attacker = captureCacheController
//                    .queryCaptureAttacker(playerId, cache);
//            CacheCompereProfile defender = compereCacheController
//                    .getCompereDetail(compereId.toString(), cache, false, false);
//            fightInfo.setPlayerLeftLife(attacker.getCaptureLife());
//            fightInfo.setPlayerTotalLife(player.getCaptureLife());
////            fightInfo.setCompereLeftLife(defender.getLeftLife());
////            fightInfo.setCompereTotalLife(defender.getTotalLife());
//            fightInfo.setCompereLeftLife(captureCacheController.queryCompereLeftLife(defender.getCityId(), compereId, cache));
//            fightInfo.setCompereTotalLife(captureCacheController.queryCompereTotalLife(defender.getCityId(), compereId, cache));
//
//            List<TCaptureSpell> spells = captureCacheController
//                    .querySpells(cache);
//
//            fightInfo.setSpells(spells);
//
//            return fightInfo;
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
//     * 计算抓主播中主播的属性
//     *
//     * @param compereId
//     * @throws Exception
//     */
//    public void calculateCaptureAttribute(Long compereId) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            CacheCompereProfile compereProfile = compereCacheController
//                    .getCompereDetail(compereId.toString(), cache, false, false);
//            List<TCaptureDefender> defenders = captureCacheController
//                    .queryCaptureInfoByCompere(compereId, cache);
//            Long defenderAttack = 0L;
////            Long compereCaptureLife = compereProfile.getLife();
//            Long compereCaptureLife = captureCacheController.queryCompereTotalLife(compereProfile.getCityId(), compereId, cache);
//            Long compereLeftLife = captureCacheController.queryCompereLeftLife(compereProfile.getCityId(), compereId, cache);
//            Float rate =  compereLeftLife.floatValue() / compereCaptureLife;
//            for (TCaptureDefender d : defenders) {
//                CachePlayerProfile profile = playerCacheController
//                        .queryPlayerDetail(d.getPlayerId(), cache, false, false);
//                if (defenderAttack < profile.getCaptureAttack()) {
//                    defenderAttack = profile.getCaptureAttack();
//                }
//                Long leftDay = (d.getEndDate().getTime() - new Date().getTime())
//                        / (1000 * 60 * 60 * 24);
//                Long additionLife = profile.getLife() * (leftDay / 7);
//                compereCaptureLife += additionLife;
//            }
//            compereLeftLife = (long)(compereCaptureLife * rate);
//            Long compereCaptureAttack = compereProfile.getAttack() + defenderAttack;
//            TCompere compere = new TCompere();
//            compere.setCompereId(compereId);
//            compere.setCaptureAttack(compereCaptureAttack);
//            compere.setTotalLife(compereCaptureLife);
//            compereMapper.updateByPrimaryKeySelective(compere);
//
//            compereCacheController.updateCompereDetailField(compereId, COMPERE_FIELD_CAPTUREATTACK,
//                    compereCaptureAttack.toString(), cache);
//            captureCacheController.updateCompereTotalLife(compereProfile.getCityId(), compereId, compereCaptureLife, cache);
//            captureCacheController.updateCompereLeftLife(Long.parseLong(compereProfile.getCityId()), compereId, compereLeftLife, cache);
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
//     *
//     * @param compereId
//     * @param c
//     * @throws Exception
//     */
//    public void unProtectCompereJob(Long compereId, Calendar c)
//            throws Exception {
//        ScheduleJob scheduleJob = new ScheduleJob();
//        scheduleJob.setJobId(compereId.toString());
//        scheduleJob.setJobGroup("unProtectCompere");
//        /**
//         * 时间转换
//         */
//        String cronExpression = c.get(Calendar.SECOND) + " "
//                + (c.get(Calendar.MINUTE)) + " " + (c.get(Calendar.HOUR_OF_DAY))
//                + " " + c.get(Calendar.DAY_OF_MONTH) + " "
//                + (c.get(Calendar.MONTH) + 1) + " ? " + c.get(Calendar.YEAR);
//
//        scheduleJob.setCronExpression(cronExpression);
//        scheduleJob.setBeanName("unProtectCompereService");
//        scheduleJob.setMethodType(1);
//        scheduleJob.setData(compereId.toString());
//        scheduleJob.setEndDate(c.getTime());
//        dynamicScheduleService.enableSchedule(scheduleJob);
//    }
//
//    private void killCompere(Long playerId, Long compereId, ICache cache, CacheCompereProfile compere,
//                             Long life1, CaptureFightInfo fightInfo) throws  Exception{
////        captureCacheController.updateCaptureTimes(playerId, -1, cache);
//        // 发送消息给主播
//        sendCaptureMessage(compere, "capture");
//
//        fightInfo.setPlayerLeftLife(life1);
//        fightInfo.setCompereLeftLife(0L);
//        fightInfo.setWinnerId(playerId);
//        // 修改主播被抓状态等，数据库，缓存
//        TCompere modifyCompere = new TCompere();
//        modifyCompere.setCompereId(compereId);
//        modifyCompere.setCaptureStatus(Constants.CAPTURE_CATCH);
//        modifyCompere.setLeftLife(0L);
//        modifyCompere.setOwnerId(playerId);
//        modifyCompere.setCityId(Long.parseLong(compere.getCityId()));
//        Integer captureHours = Integer
//                .parseInt(baseCacheController.queryConfig(
//                        Constants.CAPTURE_OWN, cache));
//        Calendar c = Calendar.getInstance();
//        c.setTime(new Date());
//        c.add(Calendar.HOUR, captureHours);
//        modifyCompere.setReleaseTime(c.getTime());
//        modifyCompere.setSharedProfit(0L);
//        modifyCompere.setTitle("大老婆");
////        modifyCompere.setTitleId(1L);
//        compereMapper.updateByPrimaryKeySelective(modifyCompere);
//
//        // 添加定时任务时间到了之后将状态改回来
//        releaseCompereJob(playerId, compereId, c);
//        captureCacheController.captureCompere(modifyCompere, cache);
//
//    }
//
//    private boolean sendCaptureMessage(CacheCompereProfile compere, String msg) {
//        String comperePhone = compere.getPhone();
//        String photo = compere.getPhotoUrl();
//        String nickname = compere.getNickName();
//        Long ownerId = compere.getOwnerId();
//        String title = compere.getTitle();
//        String[] userNames = new String[1];
//        userNames[0] = comperePhone;
//        JSONObject json = new JSONObject();
//        json.put("type", msg);
//        json.put("photo", photo);
//        json.put("nickname", nickname);
//        json.put("ownerId", ownerId);
//        json.put("title", title);
////        String result = easeMobService.sendVerifyMessage(userNames, "users",
////                json);
////        if (Constants.RETURN_CODE_SUCCESS.equals(result)) {
////            return true;
////        }
//        return false;
//    }
//
//    public void modifyTitle(Long compereId, String title) {
//        TCompere compere = new TCompere();
//        compere.setTitle(title);
//        compere.setCompereId(compereId);
//        if(compereMapper.updateByPrimaryKeySelective(compere) > 0) {
//            ICache cache = null;
//            try {
//                cache = CacheManager.getCache();
//                captureCacheController.modifyTitle(compere, cache);
//                CacheCompereProfile compereProfile = compereCacheController.getCompereDetail(compereId.toString(), cache, false, false);
//                sendCaptureMessage(compereProfile, "capture");
//            } catch (Exception e) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, e.getMessage());
//            } finally {
//                if(cache != null) {
//                    CacheManager.releaseCache(cache);
//                }
//            }
//        }
//    }
//}
