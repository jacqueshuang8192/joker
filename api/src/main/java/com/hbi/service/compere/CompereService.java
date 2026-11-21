//package com.hbi.service.compere;
//
//import com.alibaba.fastjson.JSONObject;
//import com.core.service.BaseService;
//import com.core.util.DateUtils;
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.*;
//import com.hbi.cache.model.CacheCompereProfile;
//import com.hbi.cache.model.CachePlayerListProfile;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.*;
//import com.hbi.model.*;
//import com.hbi.service.common.CaptureCompereService;
//import com.hbi.service.common.GameService;
//import com.hbi.service.common.UserService;
//import com.hbi.service.common.UserTaskService;
//import com.hbi.service.idGenerate.GenerateIdService;
//import com.hbi.service.inviteCodeGen.InviteCodeGen;
//import com.hbi.utils.GameServerUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.utils.MongoUtil;
//import com.hbi.utils.UserUtil;
//import com.hbi.vo.response.user.AccountVo;
//import com.hbi.vo.response.user.LevelVo;
//import com.hbi.vo.response.user.UserGoodsPresentDetail;
//import org.apache.commons.collections.CollectionUtils;
//import org.apache.commons.lang.StringUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//import java.text.SimpleDateFormat;
//import java.util.ArrayList;
//import java.util.Calendar;
//import java.util.Date;
//import java.util.List;
//
//@Service
//public class CompereService extends BaseService<TCompere> {
//
//    private static final String COMPERE_FIELD_EXP = "experience";
//
//    private static final String COMPERE_FIELD_LEVEL = "level";
//
//    @Autowired
//    private TUserMapper userMapper;
//    @Autowired
//    private TCompereMapper compereMapper;
//    @Autowired
//    private TPlayerMapper playerMapper;
//    @Autowired
//    private TTaskMapper taskMapper;
//    @Autowired
//    private TUserTaskMapper userTaskMapper;
//    @Autowired
//    private TJewelGivesMapper jewelGivesMapper;
//    @Autowired
//    private TCompereAssistantMapper assistantMapper;
//    @Autowired
//    private TSecUserMapper secUserMapper;
//    @Autowired
//    private ZJewelReportMapper reportMapper;
//    @Autowired
//    private ZJewelStatementMapper statementMapper;
//    @Autowired
//    private ZCoinReportMapper coinReportMapper;
//    @Autowired
//    private TCompereIncomeMapper compereIncomeMapper;
//    @Autowired
//    private BullFightGameInfoMapper bullFightGameInfoMapper;
//    @Autowired
//    private CompereCacheController compereCacheController;
//    @Autowired
//    private BaseCacheController baseCacheController;
//    @Autowired
//    private UserTaskService userTaskService;
//    @Autowired
//    private UserService userService;
//    @Autowired
//    private CaptureCompereService captureCompereService;
//    @Autowired
//    private CaptureCacheController captureCacheController;
//    @Autowired
//    private GameCacheController gameCacheController;
//    @Autowired
//    private SocietyCacheController societyCacheController;
//    @Autowired
//    private CommonCacheController commonCacheController;
//    @Autowired
//    private GenerateIdService generateIdService;
//    @Autowired
//    private GameService gameService;
//    @Autowired
//    private ZJewelStatementMapper jewelStatementMapper;
//    @Autowired
//    private InviteCodeGen codeGen;
//
//    /**
//     * 注册用户，插入数据库，调用环信接口
//     *
//     * @param compere
//     * @param user
//     * @param invitationCode
//     * @return
//     */
//    public String register(final TCompere compere, TUser user,
//                           String invitationCode) throws Exception{
//        if (UserUtil.isUserExistedInDatabase(userMapper, user.getPhone())) {
//            throw new InfServerException(Constants.RETURN_CODE_PHONE_ALREADY_EXISTED, "账户已存在");
//        }
//        final ICache cache = CacheManager.getCache();
//        try {
//            TSecUser agent = null;
//            if (StringUtils.isNotBlank(invitationCode)) {
//                agent = new TSecUser();
//                agent.setInvitationCode(invitationCode.trim());
//                agent = secUserMapper.selectOne(agent);
//            }
//            if (agent != null) {
//                if(!agent.getUsertype().equals(Constants.USER_TYPE_MANAGER)) {
//                    throw  new InfServerException(Constants.RETURN_CODE_FAIL, "主播只能绑定经理！");
//                }
//                compere.setAgentId(agent.getUserid());
//                addOperatorCompereCount(agent); //给主播对应运营商的主播人数加1
//            } else {
//                throw  new InfServerException(Constants.RETURN_CODE_FAIL, "找不到经理！");
//            }
//
//            Date nowDate = new Date();
////            Long userId = generateIdService.generateId(TUser.class.getName());
////            user.setUserid(userId);
//            userMapper.insert(user);
//            TUser newUser = new TUser();
//            newUser.setPhone(user.getPhone());
//            user = userMapper.selectOne(newUser);
//            compere.setCompereId(user.getUserid());
////            compere.setInvitationCode(String.format("%08d", user.getUserid()));
//            compere.setInvitationCode(codeGen.getCode());
//            compere.setPlayerNum(0L);
//
//            //主播注册时给一个抢主播保护时间
//            Integer protectHour = Integer.parseInt(baseCacheController
//                    .queryConfig(Constants.CAPTURE_NEW, cache));
//            final Calendar c = Calendar.getInstance();
//            c.setTimeInMillis(new Date().getTime());
//            c.add(Calendar.HOUR, protectHour);
//            Date date = c.getTime();
//            compere.setProtectTime(date);
//            compere.setCaptureStatus(Constants.CAPTURE_PROTECT);
//
//            initCompere(compere);
//            compereMapper.insert(compere);
//
//            captureCompereService.unProtectCompereJob(user.getUserid(), c);//添加解除主播保护的定时任务
//
//            //添加成就任务
//            TTask taskTemp = new TTask();
//            taskTemp.setType(Constants.ONE_TIME_TASK);
//            taskTemp.setUserType(Constants.USER_TYPE_C);
//            taskTemp.setStatus(Constants.NORMAL_STATUS_PUBLISH);
//            List<TTask> tasks = taskMapper.select(taskTemp);
//            if (CollectionUtils.isNotEmpty(tasks)) {
//                for (TTask task : tasks) {
//                    if (task.getPreTaskId() == null) {
//                        TUserTask t = new TUserTask();
//                        t.setId(generateIdService.generateId(TUserTask.class.getName()));
//                        t.setTaskId(task.getTaskId());
//                        t.setTaskType(Constants.ONE_TIME_TASK);
//                        t.setUserId(user.getUserid());
//                        t.setActualAmount(0);
//                        t.setAwardStatus(Constants.TASK_AWARD_NOT_GET);
//                        t.setUpdateDate(nowDate);
//                        t.setPriority(1);
//                        userTaskMapper.insert(t);
//                    }
//                }
//            }
//
//            //用户类型
//            commonCacheController.addUserType(user.getUserid().toString(), Constants.USER_TYPE_C, cache);
//
//            //主播收入
//            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//            Date incomeDate = sdf.parse(sdf.format(nowDate));
//            TCompereIncome compereIncome = new TCompereIncome();
//            compereIncome.setId(generateIdService.generateId());
//            compereIncome.setCompereId(user.getUserid());
//            compereIncome.setMatchExtractIncome(0);
//            compereIncome.setLiveRoomGiftIncome(0);
//            compereIncome.setLiveRoomGameExtractIncome(0);
//            compereIncome.setDatingIncome(0);
//            compereIncome.setTaskIncome(0);
//            compereIncome.setMiningIncome(0);
//            compereIncome.setCaptureCompereDefendIncome(0);
//            compereIncome.setCaptureCompereRansomIncome(0);
//            compereIncome.setHasIncome("0");
//            compereIncome.setIncomeDate(incomeDate);
//            compereIncome.setLastmodifyDate(nowDate);
//            compereIncomeMapper.insert(compereIncome);
//
//            BullfightGameinfo gameInfo = new BullfightGameinfo();
//            gameInfo.setMid(user.getUserid().intValue());
//            bullFightGameInfoMapper.createUser(gameInfo);
//
////            String result = easeMobService.registerOnEaseMob(user.getPhone(),
////                    user.getPassword(), user.getNickName());
//            final Long tempId = user.getUserid();
//            final String tempPhone = user.getPhone();
//            new Thread(
//                    new Runnable() {
//                        @Override
//                        public void run() {
//                            ICache cache2 =null;
//                            try {
//                                cache2 = CacheManager.getCache();
//                                createChatroom(tempId, tempPhone, cache2);
//                            } catch (Exception e) {
//                                e.printStackTrace();
//                            } finally {
//                                if (cache2 != null) {
//                                    CacheManager.releaseCache(cache2);
//                                }
//                            }
//                        }
//                    }
//            ).start();
//
//            String month = new SimpleDateFormat("yyyy-MM").format(nowDate);
//            compereCacheController.addCompereIncome(compereIncome, month, cache);
//
//            return "";
//        } catch (Exception e) {
//            e.printStackTrace();
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//
//    }
//
//    /**
//     * 更新用户
//     *
//     * @param compere
//     */
//    public void updateUser(TCompere compere) {
//        compereMapper.updateByPrimaryKeySelective(compere);
//    }
//
//    /**
//     * 根据用户ID查找主播
//     *
//     * @param userid
//     * @return
//     * @throws Exception
//     */
//    public CacheCompereProfile getCompereInfoById(String userid)
//            throws Exception {
//        CacheCompereProfile compereDetail = null;
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
////            compereDetail = compereCacheController.getCompereDetail(userid,
////                    cache, true, true);
//            compereDetail = compereCacheController.getCompereDetail(userid,
//                    cache, false, true);
//            if(compereDetail == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "主播不存在！");
//            }
////            String phone = compereDetail.getPhone();
////            String token = loginCacheController.queryToken(phone, cache);
////            compereDetail.setToken(token);
//            return compereDetail;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public GameServerAuthInfo getCompereInfo4GameServer(String userId) throws Exception {
//        CacheCompereProfile compereProfile = getCompereInfoById(userId);
//        GameServerAuthInfo authInfo = new GameServerAuthInfo();
//        authInfo.setCompereProfile(compereProfile);
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TGameServer server = gameService.queryGameServer();
//            authInfo.setHall(server);
//            authInfo.setMtKey("123456");
//        } catch (Exception e) {
//            throw e;
//        }finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//        return authInfo;
//    }
//
//    /**
//     * 根据ID查找主播信息
//     *
//     * @param userid
//     * @return
//     * @throws Exception
//     */
//    public TCompere getCompereById(String userid) throws Exception {
//        TCompere compere = compereMapper
//                .selectByPrimaryKey(Long.parseLong(userid));
//        if (compere != null) {
//            TUser user = userMapper.selectByPrimaryKey(Long.parseLong(userid));
//            if (user != null) {
//                compere.setUser(user);
//            } else {
//                throw new InfServerException(
//                        Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR,
//                        "没有查询到相关账号");
//            }
//        } else {
//            throw new InfServerException(
//                    Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到相关账号");
//        }
//        return compere;
//    }
//
//    /**
//     * 根据ID查找主播信息
//     *
//     * @param userid
//     * @return
//     * @throws Exception
//     */
//    public TCompere getOnlyCompereInfoById(String userid) throws Exception {
//        TCompere compere = compereMapper
//                .selectByPrimaryKey(Long.parseLong(userid));
//        if (compere == null) {
//            throw new InfServerException(
//                    Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到相关账号");
//        }
//        return compere;
//    }
//
//    public void setAdmin(String compereId, String adminId) throws Exception {
//        TCompereAssistant m = new TCompereAssistant();
//        m.setCompereId(Long.parseLong(compereId));
//        m.setManagerId(Long.parseLong(adminId));
//        assistantMapper.insertSelective(m);
//
//        ICache cache = CacheManager.getCache();
//        try {
//            compereCacheController.setAdmin(compereId, adminId, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public void cancelAdmin(String compereId, String adminId) throws Exception {
//        TCompereAssistant m = new TCompereAssistant();
//        m.setCompereId(Long.parseLong(compereId));
//        m.setManagerId(Long.parseLong(adminId));
//        assistantMapper.delete(m);
//
//        ICache cache = CacheManager.getCache();
//        try {
//            compereCacheController.cancelAdmin(compereId, adminId, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public List<CompereVo> getCompereListByStatus(String status) {
//        List<CompereVo> compereList = compereMapper.getCompereByStatus(status);
//        for (CompereVo temp : compereList) {
//            temp.setFansCount(getFansCount(temp.getUserid()));
//        }
//        return compereList;
//    }
//
//    // /**
//    // * 根据城市ID查找主播
//    // * @param cityId
//    // * @return
//    // */
//    // public List<CompereVo> getCompereListByCity(String cityId) {
//    // List<CompereVo> compereList = compereMapper.getCompereNearby(cityId);
//    // for(CompereVo temp : compereList) {
//    // temp.setFansCount(getFansCount(temp.getUserid()));
//    // }
//    // return compereList;
//    // }
//
//    /**
//     * 获取主播粉丝数量
//     *
//     * @param compereId
//     * @return
//     */
//    private int getFansCount(String compereId) {
//        List<TPlayer> playerList = new ArrayList<TPlayer>();
//        TPlayer player = new TPlayer();
//        player.setCompereId(Long.parseLong(compereId));
//        playerList = playerMapper.select(player);
//        return playerList.size();
//    }
//
//    /**
//     * 更新用户
//     * @param compere
//     * @param oldCity
//     * @throws Exception
//     */
//    public void updateCompere(TCompere compere, String oldCity) throws Exception {
//        compereMapper.updateByPrimaryKeySelective(compere);
//        userMapper.updateByPrimaryKeySelective(compere.getUser());
//        //更新Redis
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            compereCacheController.updateCacheCompere(compere, oldCity, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public List<CompereVo> queryComperesNearby(double longitude,
//            double latitude) throws Exception {
//        List<Long> resultList = MongoUtil.queryUsersByLocation(longitude,
//                latitude);
//        return compereMapper.queryComperesNearBy(resultList);
//    }
//
//    /**
//     * 赠送房卡
//     *
//     * @param compereId
//     * @param jewelAmount
//     * @return
//     * @throws Exception
//     */
//    public AccountVo sendJewel(Long compereId, int jewelAmount)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        AccountVo accountVo = new AccountVo();
//
//        try {
//            int jewelAmountRemain = 0;
//            String json = GameServerUtil.invokeQuery(compereId);
//            if (StringUtils.isEmpty(json)) {
//                throw new InfServerException(
//                        Constants.RETURN_CODE_ACCOUNT_ERROR, "接口返回为空");
//            }
//
//            JSONObject obj = JSONObject.parseObject(json);
//
//            if (obj != null) {
//                if (obj.containsKey("jewelAmount") && StringUtils
//                        .isNotBlank(obj.getString("jewelAmount"))) {
//                    jewelAmountRemain = Integer
//                            .parseInt(obj.getString("jewelAmount"));
//                } else {
//                    throw new InfServerException(
//                            Constants.RETURN_CODE_ACCOUNT_ERROR, "接口返回房卡为空");
//                }
//            }
//
//            if (jewelAmountRemain >= jewelAmount) {
//                CacheCompereProfile compereProfile = compereCacheController
//                        .getCompereDetail(compereId.toString(), cache, false, false);
//                if (compereProfile != null) {
//                    long agentId = compereProfile.getAgentId();
//                    TJewelGives jewelGives = new TJewelGives();
//                    jewelGives.setCompereId(compereId);
//                    jewelGives.setJewelAmount((long) jewelAmount);
//                    jewelGives.setGiveDate(new Date());
//                    jewelGives.setAgentId(agentId);
//                    jewelGivesMapper.insert(jewelGives);
//
//                    secUserMapper.updateJewelAmount(agentId, jewelAmount);
//                    ZJewelReport report = new ZJewelReport();
//                    report.setGiverId(compereId);
//                    report.setReceiverId(agentId);
//                    report.setBalance(jewelAmount);
//                    report.setName(compereProfile.getNickName());
//                    report.setRemark(Constants.TRADE_TYPE_RECEIVE);
//                    report.setStatus(Constants.TRADE_STATUS_YES);
//                    report.setTime(new Date());
//                    report.setType(Integer.parseInt(Constants.USER_TYPE_MANAGER));
//                    reportMapper.insert(report);
//
//                    ZJewelStatement statement = new ZJewelStatement();
//                    statement.setBalance(-jewelAmount);
//                    statement.setGiverId(compereId);
//                    statement.setReceiverId(agentId);
//                    statement.setName(compereProfile.getNickName());
//                    statement.setRemark(Constants.TRADE_TYPE_EXCHANGE);
//                    statement.setStatus(Constants.TRADE_STATUS_YES);
//                    statement.setTime(new Date());
//                    statement.setType(Integer.parseInt(Constants.USER_TYPE_COMPERE));
//                    statementMapper.insert(statement);
//
//                    // 更新房卡
//                    if (GameServerUtil.invokeUpdateJewel(compereId,
//                            -jewelAmount)) {
//                        accountVo.setJewelAmount(
//                                Long.valueOf(jewelAmountRemain - jewelAmount));
//                    } else {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                                "更新账户房卡失败");
//                    }
//                    TSecUser agent = secUserMapper.selectByPrimaryKey(agentId);
//                    accountVo.setReceiverName(agent.getFullname());
//                } else {
//                    throw new InfServerException(
//                            Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR,
//                            "主播不存在");
//                }
//            } else {
//                throw new InfServerException(
//                        Constants.RETURN_CODE_ACCOUNT_ERROR, "账户房卡余额不足");
//            }
//
//            return accountVo;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//
//    }
//
//    public Object queryMyFans(String userId) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            return compereCacheController
//                    .queryFansPlayerByCompereId(Long.parseLong(userId), cache);
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
//     * 根据主播ID查询收到的礼物
//     *
//     * @param compereId
//     * @return
//     * @throws Exception
//     */
//    public List<TUserGoods> queryGiftsByCompereId(String compereId)
//            throws Exception {
//        List<TUserGoods> userGoods = null;
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            userGoods = compereCacheController
//                    .queryAllGiftsByCompereId(compereId, cache);
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
//    public List<CachePlayerListProfile> queryContributionRank(String compereId)
//            throws Exception {
//        List<CachePlayerListProfile> players = null;
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            players = compereCacheController.queryContributionRank(compereId,
//                    cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//        return players;
//    }
//
//    public String queryAgent(Long compereId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            CacheCompereProfile compere = compereCacheController
//                    .getCompereDetail(compereId.toString(), cache, false, false);
//            TSecUser agent = secUserMapper
//                    .selectByPrimaryKey(compere.getAgentId());
//            if (agent != null) {
//                return agent.getFullname();
//            }
//            return null;
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
//     * 查询月度收入
//     * @param compereId
//     * @param month
//     * @return
//     * @throws Exception
//     */
//    public List<TUserGoodsPresentRecord> queryGiftsForMonth(Long compereId, String month) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<TUserGoodsPresentRecord> presentRecords = compereCacheController.queryGiftsForMonth(compereId, month, cache);
//            return presentRecords;
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
//     * 查询当天收入
//     * @param compereId
//     * @return
//     * @throws Exception
//     */
//    public List<TUserGoodsPresentRecord> queryTodayGifts(long compereId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<TUserGoodsPresentRecord> presentRecords = compereCacheController.queryTodayGifts(compereId, cache);
//            return presentRecords;
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
//     * 查询每月收入中每项礼物的详情
//     * @param compereId
//     * @param month
//     * @param categoryId
//     * @return
//     * @throws Exception
//     */
//    public List<UserGoodsPresentDetail> queryMonthlyCategoryDetail(long compereId, String month, Long categoryId) throws Exception {
//        Date date = DateUtils.getParseDate(month, "yyyy-MM");
//        Calendar calendar = Calendar.getInstance();
//        calendar.setTime(date);
//        Date startDate = calendar.getTime();
//        calendar.add(Calendar.MONTH, 1);
//        Date endDate = calendar.getTime();
//        return compereMapper.queryCategoryDetailByDateRange(compereId,
//                DateUtils.getParseDate(startDate, "yyyy-MM-dd"), DateUtils.getParseDate(endDate, "yyyy-MM-dd"), categoryId);
//    }
//
//    /**
//     * 查询当天收入中每项礼物的详情
//     * @param compereId
//     * @param categoryId
//     * @return
//     */
//    public List<UserGoodsPresentDetail> queryTodayCategoryDetail(long compereId, long categoryId) {
//        String startDate = DateUtils.getParseDate(new Date(), "yyyy-MM-dd");
//        return compereMapper.queryCategoryDetailByDateRange(compereId, startDate, startDate + "23:59:59", categoryId);
//    }
//
//    public int updateCompereCoinAmount(Integer coinAmount) {
//        return compereMapper.updateCompereCoinAmount(coinAmount);
//    }
//
//    /**
//     * 领取任务奖励
//     * @param userId
//     * @param taskId
//     * @return
//     * @throws Exception
//     */
//    public LevelVo receiveTaskReward(Long userId, Long taskId) throws Exception {
//        ICache cache = CacheManager.getCache();
//        LevelVo vo = new LevelVo();
//        try {
//            Date nowDate = new Date();
//            TUserTask userTask = null;
//            TUserTask temp = new TUserTask();
//            temp.setTaskId(taskId);
//            temp.setUserId(userId);
//            List<TUserTask> userTasks = userTaskMapper.select(temp);
//            if (CollectionUtils.isNotEmpty(userTasks)) {
//                for (TUserTask ut : userTasks) {
//                    if (Constants.ONE_TIME_TASK.equals(ut.getTaskType())) {
//                        userTask = ut;
//                        break;
//                    } else {
//                        if (DateUtils.isSameDate(nowDate, ut.getEndDate())) {
//                            userTask = ut;
//                            break;
//                        }
//                    }
//                }
//            }
//
//            if (userTask == null) {
//                throw new InfServerException(
//                        Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "找不到任务！");
//            }
//            if (userTask.getAwardStatus() == 1) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "不能重复领取每日任务奖励");
//            }
//            TTask task = commonCacheController.queryTaskById(Constants.USER_TYPE_C, taskId, cache);
//            if (userTask.getActualAmount() < task.getAmount()) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "任务未完成");
//            }
//            Integer exprience = task.getExperience() == null ? 0 : task.getExperience();
//            Integer coinAmount = task.getAwards();
//
//            vo = updateCompereExp(userId, exprience, cache);
//
//            if (Constants.DAILY_TASK.equals(userTask.getTaskType())) {
//                userTaskService.getDailyTaskAward(userId, userTask, cache);
//            } else {
//                userTaskService.getAchievementTaskAward(userId, Constants.USER_TYPE_P, userTask, cache);
//            }
//
//            if (coinAmount > 0) {
//                String incomeDateStr = DateUtils.getParseDate(nowDate, "yyyy-MM-dd");
//                int incomeCount = compereIncomeMapper.addTaskIncome(userId, coinAmount, nowDate, incomeDateStr);
//                coinReportMapper.updateCoinReport(coinAmount);
//                if (incomeCount > 0) {
//                    compereCacheController.addTaskIncome(userId, incomeDateStr, coinAmount, cache);
//                }
//
//                if (!GameServerUtil.invokeUpdateCoin(userId, coinAmount)) {
//                    throw new InfServerException(Constants.RETURN_CODE_INVITATION_CODE_ERROR, "更新账户出错");
//                }
//            }
//
//            return vo;
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
//     * 更新主播平台经验
//     *
//     * @param userId
//     * @param exp
//     */
//    public LevelVo updateCompereExp(Long userId, Integer exp, ICache cache)
//            throws Exception {
//        LevelVo vo = new LevelVo();
//        CacheCompereProfile compere = compereCacheController.getCompereDetail(userId.toString(), cache, false, false);
//        if (compere == null) {
//            throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有此主播的相关信息");
//        }
//        Integer oldExp = compere.getExperience() == null ? 0 : compere.getExperience();
//        Integer newExp = oldExp + exp;
//        Integer newLevel = compere.getLevel();
//        TCompereLevel compereLevel = baseCacheController
//                .queryCompereLevelByLevel(newLevel, cache);
//        Integer totalExp = compereLevel.getCoinAmount().intValue();
//
//        while(newExp >= totalExp) {
//            newLevel++;
//            compereLevel = baseCacheController
//                    .queryCompereLevelByLevel(newLevel, cache);
//            if (compereLevel == null) {//已达到最高等级
//                newLevel--;
//                newExp = totalExp;
//                vo.setExperience(newExp);
//                vo.setLevel(newLevel);
//                vo.setTotalExperience(newExp);
//                break;
//            }
//            newExp -= totalExp;
//            totalExp = compereLevel.getCoinAmount().intValue();
//        }
//        vo.setExperience(newExp);
//        vo.setLevel(newLevel);
//        if (compereLevel == null) {
//            vo.setTotalExperience(newExp);
//        } else {
//            vo.setTotalExperience(compereLevel.getCoinAmount().intValue());
//        }
//        if (exp != 0) {
//            if (compereMapper.updateCompereExp(userId, newExp, newLevel) > 0) { // 更新缓存
//                compereCacheController.updateCompereDetailField(userId,
//                        COMPERE_FIELD_LEVEL, newLevel.toString(), cache);
//                compereCacheController.updateCompereDetailField(userId,
//                        COMPERE_FIELD_EXP, newExp.toString(), cache);
//            }
//        }
//
//        return vo;
//    }
//
//    /**
//     * 运营商主播人数加1
//     * @param agent
//     * @throws Exception
//     */
//    public void addOperatorCompereCount(TSecUser agent)
//            throws Exception {
//        TSecUser secUser = userService.findOperatorByAgent(agent);
//        secUserMapper.updateCompereCount(secUser.getUserid(), 1);
//    }
//
//    public List<TCompereIncome> queryCompereImcomesForMonth(Long compereId, String month) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            return compereCacheController.queryCompereIncomesForMonth(compereId, month, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public List<ZJewelStatement> queryJewelStatement(Long userId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            ZJewelStatement statement = new ZJewelStatement();
//            statement.setGiverId(userId);
//            return jewelStatementMapper.select(statement);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    private void initCompere(TCompere compere) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            TLevelLifeforce lifeforce = gameCacheController.queryLifeforce(1, cache);
//            compere.setMineAttack(lifeforce.getAttack().longValue());
//            compere.setMineDefense(lifeforce.getDefense().longValue());
//            compere.setMineLife(lifeforce.getLife().longValue());
//            compere.setCaptureAttack(lifeforce.getAttack().longValue());
//            compere.setCaptureDefense(lifeforce.getDefense().longValue());
////            compere.setLeftLife(lifeforce.getLife().longValue());
//            compere.setTotalLife(lifeforce.getLife().longValue());
//            captureCacheController.updateCompereLeftLife(compere.getCityId(), compere.getCompereId(),
//                    lifeforce.getLife().longValue(), cache);
//            captureCacheController.updateCompereTotalLife(compere.getCityId().toString(),
//                    compere.getCompereId(), lifeforce.getLife().longValue(), cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public String createChatroom(Long compereId, String phone, ICache cache) throws Exception {
//        String chatroomId = "";
////        = easeMobService.createChatRoom(phone);
////        if (StringUtils.isNotBlank(chatroomId)) {
////            TCompere compere = new TCompere();
////            compere.setCompereId(compereId);
////            compere.setChatroomId(chatroomId);
////            Example example = new Example(TCompere.class);
////            Example.Criteria criteria = example.createCriteria();
////            criteria.andIsNull("chatroomId");
////            criteria.andEqualTo("compereId", compereId);
////            if(compereMapper.updateByExampleSelective(compere, example) > 0) {
////                compereCacheController.updateCompereDetailField(compereId, "chatroomId", chatroomId, cache);
////            }
//            return chatroomId;
////        } else {
////            throw new InfServerException(Constants.RETURN_CODE_FAIL, "创建聊天室失败");
////        }
//    }
//
//}
