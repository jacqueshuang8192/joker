//package com.hbi.service.society;
//
//import com.core.service.BaseService;
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.MiningCacheController;
//import com.hbi.cache.controller.SocietyCacheController;
//import com.hbi.cache.model.*;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TSocietyManagerMapper;
//import com.hbi.mapper.TSocietyMapper;
//import com.hbi.mapper.TUserMapper;
//import com.hbi.model.TMiningGame;
//import com.hbi.model.TSociety;
//import com.hbi.model.TSocietyManager;
//import com.hbi.model.TUser;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.user.ListVo;
//import org.apache.commons.lang.StringUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import java.text.SimpleDateFormat;
//import java.util.Date;
//import java.util.List;
//
//@Service
//public class SocietyService extends BaseService<TSociety> {
//
//    @Autowired
//    private TSocietyMapper societyMapper;
//    @Autowired
//    private TSocietyManagerMapper societyManagerMapper;
//    @Autowired
//    private TUserMapper userMapper;
//    @Autowired
//    private SocietyCacheController societyCacheController;
//    @Autowired
//    private MiningCacheController miningCacheController;
////    @Autowired
////    private EaseMobService easeMobService;
//
//    public TSociety findTSocietyById(Long id) {
//        TSociety society = societyMapper.selectByPrimaryKey(id);
//        return society;
//    }
//
//    public CacheSocietyProfile findSocietyDetailById(Long societyId)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            CacheSocietyProfile vo = societyCacheController
//                    .querySocietyDetail(societyId, cache);
//            if (vo.getActivityId() != null && !vo.getActivityId().equals(0L)) {
//                TMiningGame activity = miningCacheController
//                        .queryMiningGameByActivityId(cache, vo.getActivityId());
//                if (activity != null) {
//                    // 开始结束时间转换成unix时间戳
//                    String endDate = activity.getEndDate();
//                    if (StringUtils.isNotBlank(endDate)) {
//                        // endDate = endDate.substring(0, 19);
//                        SimpleDateFormat format = new SimpleDateFormat(
//                                "yyyy-MM-dd HH:mm:ss");
//                        Date date = format.parse(endDate);
//                        vo.setMineEndTime(String.valueOf(date.getTime()));
//                    }
//                }
//            }
//
//            return vo;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//
//    }
//
//    public ListVo getSocietyCompereListById(Long societyId) throws Exception {
//        ICache cache = CacheManager.getCache();
//        ListVo vo = new ListVo();
//        try {
//            List<CacheCompereProfile> compereVos = societyCacheController
//                    .querySocietyComperes(societyId, cache);
//            if (compereVos == null) {
//                throw new InfServerException(
//                        Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, null);
//            }
//            vo.setList(compereVos);
//            vo.setCount(compereVos.size());
//            return vo;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public ListVo getSocietyPlayerListById(Long societyId) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            ListVo vo = new ListVo();
//            List<CachePlayerProfile> playerVos = societyCacheController
//                    .querySocietyPlayers(societyId, cache);
//            if (playerVos == null) {
//                throw new InfServerException(
//                        Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, null);
//            }
//            vo.setList(playerVos);
//            vo.setCount(playerVos.size());
//            return vo;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public ListVo getSocietyManagerListById(Long societyId) throws Exception {
//        ListVo vo = new ListVo();
//        List<CacheUserListProfile> playerVos = societyMapper
//                .getManagerListBySocietyId(societyId);
//        if (playerVos == null) {
//            throw new InfServerException(
//                    Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, null);
//        }
//        vo.setList(playerVos);
//        vo.setCount(playerVos.size());
//        return vo;
//    }
//
//    /**
//     * 设置工会管理员
//     *
//     * @param societyId
//     * @param userId
//     * @param managerId
//     * @return
//     * @throws Exception
//     */
//    public boolean setSocietyManager(Long societyId, Long userId, String type,
//            Long managerId) throws Exception {
//        if (!isSocietyMaster(managerId, societyId)) {
//            return false;
//        }
//        ICache cache = CacheManager.getCache();
//        try {
//            societyCacheController.setSocietyManager(societyId, userId, type,
//                    cache);
//            TSocietyManager societyManager = new TSocietyManager();
//            societyManager.setSocietyId(societyId);
//            societyManager.setManagerId(userId);
//            int result = societyManagerMapper.insert(societyManager);
//            if (result > 0) {
//                return true;
//            }
//            return false;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//
//    }
//
//    /**
//     * 取消工会管理员
//     *
//     * @param societyId
//     * @param userId
//     * @param managerId
//     * @return
//     * @throws Exception
//     */
//    public boolean cancelSocietyManager(Long societyId, Long userId,
//            Long managerId) throws Exception {
//        if (!isSocietyMaster(managerId, societyId)) {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, "用户不是会长！");
//        }
//        ICache cache = CacheManager.getCache();
//        try {
//            societyCacheController.cancelSocietyManager(societyId, userId,
//                    cache);
//            TSocietyManager societyManager = new TSocietyManager();
//            societyManager.setSocietyId(societyId);
//            societyManager.setManagerId(userId);
//            int result = societyManagerMapper
//                    .deleteByPrimaryKey(societyManager);
//            if (result > 0) {
//                return true;
//            }
//            return false;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//
//    }
//
//    /**
//     * 踢出公会
//     *
//     * @param societyId
//     * @param userId
//     * @param managerId
//     * @return
//     * @throws Exception
//     */
//    public boolean kickPlayerOutOfSociety(Long societyId, Long userId,
//            Long managerId) throws Exception {
//        if (!isSocietyManager(managerId, societyId)) {
//            return false;
//        }
//        // TODO 发送环信通知
//        return exitSociety(userId);
//    }
//
//    public boolean joinSociety(Long societyId, Long userid, String type, String phone)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//
//            TUser user = userMapper.selectByPrimaryKey(userid);
//            if (user == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "用户不存在！");
//            }
//            if (user.getSocietyId() != null) {
//                throw new InfServerException(Constants.RETURN_CODE_SOCIETY_EXISTED,
//                        "用户已有公会！");
//            }
//            TSociety society = findTSocietyById(societyId);
//            if (society == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "公会不存在！");
//            }
//            user.setSocietyId(societyId);
//            if (user.getType().equalsIgnoreCase(Constants.USER_TYPE_C)) {
//                society.setCompereNum(society.getCompereNum() + 1);
//                societyMapper.updateByPrimaryKeySelective(society);
//            } else if (user.getType().equalsIgnoreCase(Constants.USER_TYPE_P)) {
//                society.setPlayerNum(society.getPlayerNum() + 1);
//                societyMapper.updateByPrimaryKeySelective(society);
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "用户类型不匹配！");
//            }
//            userMapper.updateByPrimaryKeySelective(user);
//
//            societyCacheController.joinSociety(societyId, userid, type, cache);
////            easeMobService.joinSocietyMessage(society.getSocietyId(), society.getName(), phone);
//            return true;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 退出公会
//     *
//     * @param userId
//     * @return
//     */
//    public boolean exitSociety(Long userId) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            TUser user = userMapper.selectByPrimaryKey(userId);
//            if (user == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "用户不存在！");
//            }
//            if (user.getSocietyId() == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "用户没有加入公会！");
//            }
//            boolean isSuccess = societyCacheController.exitSociety(
//                    user.getSocietyId(), userId, user.getType(), cache);
//            if (isSuccess) {
//                TSociety society = new TSociety();
//                society.setSocietyId(user.getSocietyId());
//                society = societyMapper.selectOne(society);
//                if (user.getType().equalsIgnoreCase(Constants.USER_TYPE_C)) {
//                    society.setCompereNum(society.getCompereNum() - 1);
//                    societyMapper.updateByPrimaryKeySelective(society);
//                } else if (user.getType()
//                        .equalsIgnoreCase(Constants.USER_TYPE_P)) {
//                    society.setPlayerNum(society.getPlayerNum() - 1);
//                    societyMapper.updateByPrimaryKeySelective(society);
//                } else {
//                    return false;
//                }
//                TSocietyManager manager = new TSocietyManager();
//                manager.setSocietyId(user.getSocietyId());
//                manager.setManagerId(userId);
//                manager = societyManagerMapper.selectOne(manager);
//                if (manager != null) {
//                    int result = societyManagerMapper.delete(manager);
//                    if (result == 0) {
//                        return false;
//                    }
//                }
//                user.setSocietyId(null);
//                int result = userMapper.exitSociety(userId);
//                if (result > 0) {
//                    return true;
//                }
//            }
//            return false;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public List<CacheSocietyProfile> querySocietyListByCity(Long cityId)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            List<CacheSocietyProfile> profiles = societyCacheController
//                    .querySocietyListByCity(cache, cityId);
//            for (CacheSocietyProfile profile : profiles) {
//                if(profile.getActivityId() != null) {
//                    TMiningGame activity = miningCacheController
//                            .queryMiningGameByActivityId(cache, profile.getActivityId());
//                    if(activity != null) {
//                        // 开始结束时间转换成unix时间戳
//                        String endDate = activity.getEndDate();
//                        if (StringUtils.isNotBlank(endDate)) {
//                            // endDate = endDate.substring(0, 19);
//                            SimpleDateFormat format = new SimpleDateFormat(
//                                    "yyyy-MM-dd HH:mm:ss");
//                            Date date = format.parse(endDate);
//                            profile.setMineEndTime(String.valueOf(date.getTime()));
//                        }
//                    }
//                }
//            }
//            return profiles;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public List<CacheSocietyProfile> queryAllSocieties() throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<CacheSocietyProfile> profiles = societyCacheController
//                    .queryAllSocieties(cache);
//            return profiles;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//        private boolean isSocietyMaster(Long managerId, Long societyId) {
//        // TSociety society =
//        // societyMapper.selectByPrimaryKey(Long.parseLong(societyId));
//        // Long societyMasterId = society.getManagerId();
//        // if(societyMasterId != Long.parseLong(managerId)) { //检查是否有设置管理员权限
//        // return false;
//        // }
//        return true;
//    }
//
//    private boolean isSocietyManager(Long managerId, Long societyId) {
//        // TSocietyManager societyManager = new TSocietyManager();
//        // societyManager.setSocietyId(Long.parseLong(societyId));
//        // societyManager.setManagerId(Long.parseLong(managerId));
//        // societyManager =
//        // societyManagerMapper.selectByPrimaryKey(societyManager);
//        // if(societyManager == null) {
//        // return false;
//        // }
//        return true;
//    }
//}
