package com.hbi.service.common;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.core.service.BaseService;
import com.core.util.ConfigUtil;
import com.core.util.RadomUtil;
import com.core.util.StringUtil;
import com.core.util.emojiFilter;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.*;
import com.hbi.cache.model.*;
import com.hbi.constants.Constants;
import com.hbi.controller.playerGroup.ClubConstant;
import com.hbi.impl.groupgame.GroupGameImpl;
import com.hbi.interfaces.IGroupGame;
import com.hbi.ioc.account.AccountOperationService;
import com.hbi.mapper.*;
import com.hbi.model.*;
import com.hbi.service.idGenerate.GenerateIdService;
import com.hbi.service.player.PlayerService;
import com.hbi.service.playerGroup.TGroupGameconfigService;
import com.hbi.service.playerGroup.TGroupPlayerService;
import com.hbi.service.roomcard.RoomCardService;
import com.hbi.utils.*;
import com.hbi.vo.response.Response;
import com.hbi.vo.response.user.AccountVo;
import com.hbi.vo.response.user.LoginVo;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class UserService extends BaseService<TUser> {

    private static final String USER_HAS_PAYPASSWORD = "payPassword";
    private static final String GAME_TYPE_KEY = "USERPLAY_TYPE_";
    private static final String GAME_ROUND_KEY = "USERPLAY_ROUND_";
    private static final String GAME_TYPE = "winer_pay";
    private static final String GAME_ROUND = "round";
    private static final String PAY_TYPE = "pay_type";
    private static final String OTHERS = "others";
    private static final String CARD_COUND = "cardCount";
    private static final String GAME_ACTIVITY_KEY_PREFIX = "GAME_ACTIVITY_";

    static Random random = new Random();
    @Autowired
    private TUserMapper userMapper;
//    @Autowired
//    private UpdateByPrimaryKeyMapper<TUser> updateByPrimaryKeyMapper;
    @Autowired
    private CommonCacheController commonCacheController;
    @Autowired
    private LoginCacheController loginCacheController;
    @Autowired
    private PlayerCacheController playerCacheController;
    @Autowired
    private TActivityMapper activityMapper;
    @Autowired
    private TFreeGameActivityMapper freeGameActivityMapper;
    @Autowired
    private TActivityUserMapper activityUserMapper;
    @Autowired
    private TLoginHistoryMapper loginHistoryMapper;
    @Autowired
    private GenerateIdService idService;
    @Autowired
    private TSecUserMapper secUserMapper;
    @Autowired
    private GameCacheController gameCacheController;
    @Autowired
    private BaseCacheController baseCacheController;
    @Autowired
    private PlayerService playerService;
    @Autowired
    private UserCacheController userCacheController;
    @Autowired
    private RoomCardService roomCardService;
    @Autowired
    private FreeGameCacheController freeGameCacheController;
    @Autowired
    private TGiftPointMapper giftPointMapper;
    @Autowired
    private TGiftRoomCardMapper giftRoomCardMapper;
    @Autowired
    private TGroupPlayerService groupPlayerService;
    @Autowired
    private GroupPlayerCacheController groupPlayerCacheController;
    @Autowired
    private TGroupGameconfigService gameconfigService;
    @Autowired
    private TGroupPlayerMapper groupPlayerMapper;

    @Autowired
    private TPlayerGroupMapper playerGroupMapper;

    private Map<String, CheckCodeInfo> codeMap = new HashMap<String, CheckCodeInfo>();

    private String generateSixCode() {
        ICache cache = CacheManager.getCache();
        try {
            String result = String.format("%06d", random.nextInt(100000));

            int count = 0;
            while (!baseCacheController.insertFreeGameInviteCode(result, cache)) {
                if (count > 9) {
                    return "-1";
                }
                result = String.format("%06d", random.nextInt(100000));
                count++;
            }

            return result;
        } catch (Exception e) {
            return "-1";
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void releaseSixCode(String inviteCode) {
        ICache cache = CacheManager.getCache();
        try {
            baseCacheController.releaseFreeGameInviteCode(inviteCode, cache);
        } catch (Exception e) {

        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    /**
     * 用户登录
     *
     * @param phone
     * @param password
     * @return
     * @throws Exception
     */
    public LoginVo login(String phone, String password, String type, Integer device, String nickname,
                         String gender, String photo)
            throws Exception {
        LoginVo vo = null;
        ICache cache = null;
        try {
            vo = new LoginVo();
            TUser user = new TUser();
            user.setAccount(phone);
            user.setDeprecated(Constants.USER_NOT_DEPRECATED);
            user = userMapper.selectOne(user);
            if (user == null) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "用户不存在！");
            }
            if (!user.getPassword().equalsIgnoreCase(password)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "账号或密码错误！");
            }else if(user.getState() ==null || user.getState().equals("0")){
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您好,您的账号已经被封停了,请联系您的代理!!");
            } else if (!user.getState().equalsIgnoreCase(Constants.VALID)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "该用户账号已被封禁！");
            } else {
                cache = CacheManager.getCache();

                Date nowDate = new Date();
                vo.setIsFirstLogin(user.getFirstLogin());

                user.setLastLogin(nowDate);
                user.setOnlineStatus(Constants.ON_LINE);
//                user.setFirstLogin(Constants.NO);
                if (StringUtils.isNotBlank(nickname)) {
                    nickname = emojiFilter.emojiChange(nickname);
                    nickname = CommonUtil.filterEmoji(nickname);
                    user.setNickName(nickname);
                }
                if (StringUtils.isNotBlank(gender)) {
                    user.setGender(gender);
                }
                if (StringUtils.isNotBlank(photo)) {
                    user.setSmallIcon(photo);
                }
                userMapper.updateSelective(user);

                String token = loginCacheController.updateToken(user.getUserid()+"", cache);
                vo.setToken(token);
                vo.setUserid(user.getUserid());
                vo.setType(user.getType());
                vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);

                //登录历史
                TLoginHistory loginHistory = new TLoginHistory();
                loginHistory.setId(idService.generateId(TLoginHistory.class.getName()));
                loginHistory.setUserId(user.getUserid());
                loginHistory.setName(user.getNickName());
                loginHistory.setTimestamp(new Date());
                loginHistory.setDevice(device);
                loginHistoryMapper.insert(loginHistory);

//                if (vo.getIsFirstLogin() == 0) {
//                    this.roomCardService.firstLoginSendCard(user.getUserid());
//                    this.roomCardService.firstLoginSendGold(user.getUserid());
//                }

                if (StringUtils.isNotBlank(nickname)) {
                    playerCacheController.updatePlayerField(user.getUserid(), "nickName", nickname, cache);
                }
                if (StringUtils.isNotBlank(gender)) {
                    playerCacheController.updatePlayerField(user.getUserid(), "sex", gender, cache);
                }
                if (StringUtils.isNotBlank(photo)) {
                    playerCacheController.updatePlayerField(user.getUserid(), "photoUrl", photo, cache);
                }

            }
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
        return vo;
    }


    public Response userFirstLoginSentCard(Long userId) throws Exception {
        ICache cache = null;
        Response response = null;
        try {
            response = new Response();
            cache = CacheManager.getCache();
            Integer isFirstLogin = userCacheController.getIsFirstLogin(userId, cache);
            if (isFirstLogin == 0) {
                String card =  roomCardService.firstLoginSendCard(userId);
//                String gold =  roomCardService.firstLoginSendGold(userId);
                String gold =  "0";
                userCacheController.setFirstLogin(userId,cache);
//                TUser tUser = new TUser();
//                tUser.setUserid(userId);
//                tUser.setFirstLogin(1);
//                userMapper.update(tUser, false);
                userMapper.updateUserFirstLoginStatus(userId);
                userMapper.insertTplayerShareGiftRecord(userId,card,gold,Constants.giftTypeFirstLogin);
                response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
                response.setData("领取成功!!");
                return response;
            }else {
                response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
                response.setData("您已经领取过了哦!!");
                return response;
            }

        }catch (Exception e) {
            System.out.println(e.getMessage());
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"领取失败!!");
        }finally {
            CacheManager.releaseCache(cache);
        }
    }

    public CacheUserProfile getUserInfo(Long userId, String type) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            if (StringUtils.isBlank(type)) {
                type = commonCacheController.queryUserTypeByUserId(userId.toString(), cache);
            }
            if (type.equalsIgnoreCase(Constants.USER_TYPE_C)) {
//                return compereService.getCompereInfoById(userId.toString());
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "用户类型错误");
            } else if (type.equalsIgnoreCase(Constants.USER_TYPE_P)) {
                return playerService.getPlayerInfoById(userId.toString());
            } else {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "用户类型错误");
            }
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    /**
     * 根据ID查找用户
     *
     * @param userid
     * @return
     */
    public TUser findUserById(Long userid) {
        return userMapper.findById(userid);
    }

    public String getRandomCode(String phone) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            String code = RadomUtil.getCharAndNumr(6, Constants.RADOM_OUT_NUM).toUpperCase();
            SendSmsUtil.sendSms(phone, code);
            CheckCodeInfo checkCodeInfo = new CheckCodeInfo(System.currentTimeMillis(), code, phone);
            commonCacheController.setRandomCode(checkCodeInfo, cache);
            return code;
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public TUser findUserByPhone(String phone) {
        TUser user = new TUser();
        user.setPhone(phone);
        return userMapper.selectOne(user);
    }

    /**
     * 更新用户密码
     *
     * @param phone
     * @param password
     * @return
     * @throws Exception
     */
    public boolean updateUserPassword(String phone, String password) throws Exception {
        TUser user = new TUser();
        user.setPhone(phone);
        user = userMapper.selectOne(user);
        if (user == null) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "用户不存在！");
        }
        user.setPassword(password);
//        int affectedRow = updateByPrimaryKeyMapper.update(user, false);
        int affectedRow = 0;
        if (affectedRow > 0) {
            return false;
        }
        return false;
    }


    /**
     * 校验code是否有效
     *
     * @param phone
     * @param code
     * @param minutes
     * @return
     */
    public boolean isCodeValid(String phone, String code, int minutes) throws Exception {
        ICache cache = CacheManager.getCache();
        try {
            CheckCodeInfo vo = commonCacheController.getRandomCode(phone, cache);
            if (vo == null) {
                return false;
            }
            if (!isCodeInTime(vo, minutes)) {
                return false;
            }
            if (!code.equalsIgnoreCase(vo.getCode())) {
                return false;
            }
            return true;
        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }

    }

    /**
     * 校验code是否超时
     *
     * @param vo
     * @param minutes
     * @return
     */
    private boolean isCodeInTime(CheckCodeInfo vo, int minutes) {
        long curTime = System.currentTimeMillis();
        long origineTime = vo.getTimestamp();
        int seconds = minutes * 60;
        int duration = (int) ((curTime - origineTime) / 1000);
        if (duration > seconds) {
            return false;
        }
        return true;
    }

    public Object createFreeGame(String userId, String phone, int coins, String gameId, int level, int minutes, String type,
                                 int oriCoins, String name) throws Exception {
        ICache cache = CacheManager.getCache();

        String inviteCode = null;
        try {
            TGame g = baseCacheController.queryGameById(Long.parseLong(gameId), cache);

            if (g == null) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "游戏不存在");
            }

            if (gameCacheController.isExistFreeGameCreatedByUserId(userId, cache)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局资源还未释放，请稍后再试");
            }
            TGroupGame gg = baseCacheController.queryGroupGameByGameIdAndLevel(Long.parseLong(gameId), level, cache);

            if (gg == null) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局配置异常");
            }

            inviteCode = generateSixCode();

            if ("-1".equals(inviteCode)) {
                throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "组局资源不足，请稍后再试");
            }

            TActivity t = new TActivity();
            t.setCreateDate(new Date());
            t.setStartDate(t.getCreateDate());
            t.setOwnerId(Long.parseLong(userId));
            t.setType("1");
            t.setActivityName(name);
            t.setStatus((short) 0);

            activityMapper.insertActivity(t);

            TFreeGameActivity m = new TFreeGameActivity();
            m.setActivityId(t.getActivityId());
            m.setCoins(coins);
            m.setGameId(Long.parseLong(gameId));
            m.setMinutes(minutes);
            m.setInviteCode(inviteCode);
            m.setLevel(level);

            freeGameActivityMapper.insert(m);

            TActivityUser u = new TActivityUser();
            u.setActivityId(t.getActivityId());
            u.setUserid(Long.parseLong(userId));
            u.setStatus((short) 1);
            activityUserMapper.insert(u);

            String chatRoomId = "";

            int tid = GameServerUtil.invokeCreateTable(Long.parseLong(userId), coins, oriCoins, "", "", inviteCode,
                    t.getActivityId() + "", minutes * 60, gg.getIp(), gg.getPort(), gg.getLevel(), gg.getLevel());

            if (tid >= 0) {
                return commonCacheController.createFreeGameActivity(m, t, g.getCode(), tid, inviteCode, oriCoins, type, chatRoomId,
                        cache);
            } else if (tid == -1) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "创建组局的筹码与请求的不符");
            } else if (tid == -2) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "创建桌子与此分配房间服务器level不同");
            } else if (tid == -3) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "兑换筹码失败");
            } else if (tid == -4) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "此用户已经创建桌子");
            } else {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "创建游戏桌失败");
            }
        } catch (Exception e) {
            if (inviteCode != null) {
                baseCacheController.releaseFreeGameInviteCode(inviteCode, cache);
            }

            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void closeFreeGame(String inviteCode, String gameActivityId, String rounds) throws Exception {
        ICache cache = CacheManager.getCache();

        try {
            if (!StringUtils.isBlank(rounds) && !StringUtils.isBlank(gameActivityId)) {
                TFreeGameActivity ga = new TFreeGameActivity();
                ga.setActivityId(Long.parseLong(gameActivityId));
                ga.setCount(Integer.parseInt(rounds));

                freeGameActivityMapper.updateSelective(ga);
            }

            CacheGameActivity activity = commonCacheController.queryGameActivity(inviteCode, cache);

            if (activity == null) {
                return;
            }

            TGroupGame gg = baseCacheController.queryGroupGameByGameIdAndLevel(Long.parseLong(activity.getGameId()), activity.getLevel(), cache);

            if (gg == null) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局配置异常，请联系管理员");
            }

            Long activityId = Long.parseLong(activity.getGameActivityId());

            TActivity t = new TActivity();
            t.setActivityId(activityId);
            t.setStatus((short) 2);
            t.setEndDate(new Date());
            activityMapper.updateSelective(t);

            commonCacheController.closeFreeGame(inviteCode, cache);
            freeGameCacheController.delGroupGameStatus(Long.parseLong(activity.getCreatorId()), activityId, cache);
            String key = "GROUP_GAME_MAX_PLAYER_KEY_";
            cache.hdel(key,activityId.toString());
            releaseSixCode(inviteCode);
            freeGameCacheController.delWaitCloseGroup(activityId, cache);
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void startFreeGame(String inviteCode) throws Exception {
        ICache cache = CacheManager.getCache();

        try {
            String activityId = commonCacheController.startFreeGame(inviteCode, cache);

            TActivity t = new TActivity();
            t.setActivityId(Long.parseLong(activityId));
            t.setStatus((short) 1);

            activityMapper.updateSelective(t);
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public Object joinFreeGame(String userId, String invitationCode, String activityId, Integer level,Integer configId,Integer isWatch) throws Exception {
        ICache cache = CacheManager.getCache();

        try {
            CacheGameActivity activity = commonCacheController.queryGameActivity(invitationCode, cache);
            if (activity == null) {
                throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "组局不存在");
            }

            if (activityId != null && !activityId.equals(activity.getGameActivityId())) {
                throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "组局不存在");
            }

            //非群内会员不允许加入
            String groupId = cache.hget(GAME_ROUND_KEY + activity.getGameActivityId(), "groupId");
            boolean flag = true;
            String feiqunchengyuanjiaru = ConfigUtil.get("feiqunchengyuanjiaru");
            if  (StringUtil.isNotEmpty(groupId) && "1".equals(feiqunchengyuanjiaru)) {
//                JSONObject jsonObject = groupPlayerService.selectGroupPlayer(Integer.parseInt(groupId), null);
//                JSONArray players = jsonObject.getJSONArray("players");
//                for (int i = 0 ; i < players.size() ; i++) {
//                    JSONObject jsonObject1 = players.getJSONObject(i);
//                    if (userId.equals(jsonObject1.getString("userId"))) {
//                        flag = false;
//                        break;
//                    }
//                }
                TPlayerGroup tpg = playerGroupMapper.selectByPlayerIdAndGroupId(Integer.parseInt(userId), Integer.parseInt(groupId));
                if (tpg != null) {
                    flag = false;
                }
            }
            if (StringUtil.isNotEmpty(groupId) && flag  && "1".equals(feiqunchengyuanjiaru)) {
                throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "您不是联盟的会员,不可加入房间,请先加入联盟!!");
            }

            //积分不足,不能加入桌子
            if (StringUtil.isNotEmpty(groupId)) {
                TActivity tActivity = activityMapper.findById(Long.parseLong(activity.getGameActivityId()));

                if (!StringUtil.isEmpty(tActivity) && "1".equals(isWatch+"")) {
                    TGame g = baseCacheController.queryGameById(Long.parseLong(tActivity.getLevel()+""), cache);
                    if (g == null) {
                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局游戏配置异常...");
                    }
                    String gameConfig = tActivity.getGameJson();
                    JSONObject gameConfigJson = JSONObject.parseObject(gameConfig);
                    if (!StringUtil.isEmpty(gameConfigJson) && g.getIsGold() == Constants.CLUD_ROOM) {
                        String json = gameConfigJson.getString("json");
                        JSONObject gameJ = JSONObject.parseObject(json);
                        if (!StringUtil.isEmpty(gameJ)) {
                            Integer joinGamePoint = gameJ.getInteger("joinGamePoint");
                            if (!StringUtil.isEmpty(joinGamePoint)) {
                                Double playerCoins = groupPlayerCacheController.queryClubPoint(Integer.parseInt(groupId), Integer.parseInt(userId), null);
                                if (joinGamePoint > playerCoins ) {
                                    throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "积分不足，请联系群主！！");
                                }
                            }
                        }
                    }
                }
            }

            //预警分受限
            if (!StringUtil.isEmpty(groupId) ) {
                boolean isNotOk = groupPlayerCacheController.isSurpassThresholdValue(cache, Integer.parseInt(groupId), Integer.parseInt(userId));
                if (isNotOk ) {
                    throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "请联系上级,池子不足...");
                }
            }

            String paytype = cache.hget(GAME_ROUND_KEY + activity.getGameActivityId(), PAY_TYPE);
            String password = cache.hget(GAME_ROUND_KEY + activity.getGameActivityId(), "password");
            String others = cache.hget(GAME_ROUND_KEY + activity.getGameActivityId(), OTHERS);
            String creatorId = cache.hget(GAME_ACTIVITY_KEY_PREFIX + invitationCode, "creatorId");
            if (paytype!=null && paytype.equals("AA")) {
                Integer cardCounts = baseCacheController.queryPlayerRoomCard(Long.parseLong(userId));
                String cards = cache.hget(GAME_ROUND_KEY + activity.getGameActivityId(), CARD_COUND);
                if (!userId.equals(creatorId)) {
                    if (cardCounts < Integer.parseInt(cards)) {
                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "房卡不足,无法加入");
                    }
                }else if ("0".equals(others)) {
                    if (cardCounts < Integer.parseInt(cards)) {
                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "房卡不足,无法加入");
                    }
                }
			}

			String discription = freeGameCacheController.queryFreeGameActivityDiscription(Long.parseLong(activity.getGameActivityId()), cache);


            activity.setActivityDiscription(discription);
            activity.setLevel(activity.getLevel());
            activity.setPassWord(password);
            activity.setIsWatch(isWatch);
            return activity;
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void exitFreeGame(String userId, String type, String inviteCode) throws Exception {
        ICache cache = CacheManager.getCache();
        try {
            CacheGameActivity activity = commonCacheController.queryGameActivity(inviteCode, cache);

            if (activity == null) {
                return;
            }

            CacheUserProfile userProfile;

            if ("C".equals(type)) {
            } else {
                userProfile = playerCacheController.queryPlayerDetail(Long.parseLong(userId), cache, false, false);
            }

            TActivityUser u = new TActivityUser();
            u.setActivityId(Long.parseLong(activity.getGameActivityId()));
            u.setUserid(Long.parseLong(userId));
            u.setStatus((short) 0);
            activityUserMapper.updateSelective(u);

        } catch (Exception e) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "退出异常");
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void exitFreeGameByDbDateAndGame(Integer table_id,String userId,String activityId) throws Exception {
        ICache cache = CacheManager.getCache();
        try {

            //通知游戏服已经踢了某个人了
            TActivity t = new TActivity();
            t.setActivityId(Long.parseLong(activityId));
            t = activityMapper.selectOne(t);
            if (t == null) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局不存在");
            }
            if (t.getGameId() == null || t.getLevel() == null) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局配置错误");
            }
            TGroupGame gg = baseCacheController.queryGroupGameByGameIdAndLevel(t.getGameId(), t.getLevel(), cache);

            if (gg == null) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局配置异常");
            }

            TActivityUser u = new TActivityUser();
            u.setActivityId(Long.parseLong(activityId));
            u.setUserid(Long.parseLong(userId));
            u.setStatus((short) 0);
            activityUserMapper.updateSelective(u);



            byte[] protocolNo = new byte[2];
            protocolNo[0] = (byte) 0x12;
            protocolNo[1] = (byte) 0x0A;



            IGroupGame gameService = new GroupGameImpl(gg.getIp(), gg.getPort(), protocolNo);
            int result = gameService.exitFreeGameByDbDateAndGame(table_id,userId, activityId);
            String key = "FREE_GAME_ACTIVITY_PLAYER_COUNT";
            String count = cache.hget(key, activityId);
            cache.hset(key,activityId,(Integer.parseInt(count)-1)+"");
            if (result != 0) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "踢人或者中途退出失败");
            }

        } catch (Exception e) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "退出异常");
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void invitePlayerForFreeGame(String invitationCode, List<String> phones) throws Exception {
        ICache cache = CacheManager.getCache();

        try {
            CacheGameActivity activity = commonCacheController.queryGameActivity(invitationCode, cache);

            if (activity == null) {
                throw new InfServerException();
            }

        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public AccountVo viewAccount(String userId) throws Exception {
        AccountVo accountVo = new AccountVo();
        String json = new AccountOperationService().invokeQuery(Long.parseLong(userId));

        if (StringUtils.isEmpty(json)) {
            throw new InfServerException(Constants.RETURN_CODE_ACCOUNT_ERROR, "接口返回为空");
        }

        JSONObject obj = JSONObject.parseObject(json);

        if (obj != null) {
            if (obj.containsKey("coinAmount") && StringUtils.isNotBlank(obj.getString("coinAmount"))) {
                accountVo.setCoinAmount(Long.parseLong(obj.getString("coinAmount")));
            } else {
                throw new InfServerException(Constants.RETURN_CODE_ACCOUNT_ERROR, "接口返回宝贝币为空");
            }

            if (obj.containsKey("jewelAmount") && StringUtils.isNotBlank(obj.getString("jewelAmount"))) {
                accountVo.setJewelAmount(Long.parseLong(obj.getString("jewelAmount")));
            } else {
                throw new InfServerException(Constants.RETURN_CODE_ACCOUNT_ERROR, "接口返回房卡为空");
            }
        }
        return accountVo;
    }

    /**
     * 兑换房卡
     *
     * @throws Exception
     */
    public AccountVo exchangeDiamond(String userId, Long coinAmount, Long jewelAmount) throws Exception {
        ICache cache = null;
        try {
            AccountVo accountVo = new AccountVo();
            int coinAmountRemain = 0;
            int jewelAmountRemain = 0;

            String json = GameServerUtil.invokeQuery(Long.parseLong(userId));

            if (StringUtils.isEmpty(json)) {
                throw new InfServerException(Constants.RETURN_CODE_ACCOUNT_ERROR, "接口返回为空");
            }

            JSONObject obj = JSONObject.parseObject(json);

            if (obj != null) {
                if (obj.containsKey("coinAmount") && StringUtils.isNotBlank(obj.getString("coinAmount"))) {
                    coinAmountRemain = Integer.parseInt(obj.getString("coinAmount"));
                } else {
                    throw new InfServerException(Constants.RETURN_CODE_ACCOUNT_ERROR, "接口返回宝贝币为空");
                }

                if (obj.containsKey("jewelAmount") && StringUtils.isNotBlank(obj.getString("jewelAmount"))) {
                    jewelAmountRemain = Integer.parseInt(obj.getString("jewelAmount"));
                } else {
                    throw new InfServerException(Constants.RETURN_CODE_ACCOUNT_ERROR, "接口返回房卡为空");
                }
            }

            if (coinAmountRemain >= coinAmount) {
                /**
                 * 验证兑换比例
                 */
                cache = CacheManager.getCache();
                String coinExchangeRatio = baseCacheController.queryConfig(Constants.COIN_EXCHANGE_RATIO, cache);
                if (StringUtils.isNotBlank(coinExchangeRatio)) {
                    if (coinAmount / jewelAmount != Long.parseLong(coinExchangeRatio)) {
                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "宝贝币兑换房卡比例错误");
                    }
                }
                Long uId = Long.parseLong(userId);

                // 更新宝贝币
                if (GameServerUtil.invokeUpdateCoin(uId, -coinAmount.intValue())) {
                    // 更新房卡
                    if (GameServerUtil.invokeUpdateJewel(uId, +jewelAmount.intValue())) {
                        accountVo.setCoinAmount(coinAmountRemain - coinAmount);
                        accountVo.setJewelAmount(jewelAmountRemain + jewelAmount);

                    } else {
                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "更新账户房卡失败");
                    }
                } else {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "更新账户宝贝币失败");
                }
            } else {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "账户宝贝币余额不足");
            }

            return accountVo;
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    /**
     * 根据用户ID查询游戏段位
     *
     * @param userId
     * @return
     */

    public List<FreeGameActivityInfo> viewReganizeGames(String userId) throws Exception {
        ICache cache = CacheManager.getCache();
        List<FreeGameActivityInfo> infos = null;
        try {

            //String hget = cache.hget(Constants.USER_GAME_STATES, userId);
            //if (hget == null || "".equals(hget)) {
                infos = freeGameActivityMapper.queryFreeGameRecord(Long.parseLong(userId));
                return infos;
            //}else {
            //    //房卡场的返回方式
            //    String[] sp = hget.split("_");
            //    FreeGameActivityInfo fga = new FreeGameActivityInfo();
            //    fga.setUserId(Long.parseLong(userId));
            //    fga.setLevel(Integer.parseInt(sp[0]));
            //    fga.setTid(Long.parseLong(sp[1]));
            //    infos = new ArrayList<FreeGameActivityInfo>();
            //    infos.add(fga);
            //    return infos;
            //}
        }catch(Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }
    }

    /**
     * 俱乐部里面的东西 uid_level_tid_activityId
     * @param playerId
     * @return
     * @throws Exception
     */
    public Map<String,String> queryUserGameStatus(String playerId) throws Exception {
        ICache cache = null;

        Map<String,String> map = new HashMap<String, String>();
        try {
            cache = CacheManager.getCache();
            String hget = cache.hget(Constants.USER_GAME_STATUS, playerId);
            if (hget == null || "".equals(hget)) {
                return map;
            }else {
                //房卡场的返回方式

                String[] sp = hget.split("_");
                map.put("userId",playerId);
                map.put("level",sp[0]);
                map.put("tid",sp[1]);
                //如果有第三个才添加
                if(sp.length == 3) {
                    TActivity activity = activityMapper.findById(Long.parseLong(sp[2]));
                    if (!StringUtil.isEmpty(activity)) {
                        Integer groupId = activity.getGroupId();
                        map.put("groupId",groupId+"");
                        map.put("activityId",activity.getActivityId()+"");

                        if (!StringUtil.isEmpty(groupId)) {
                            TGroupPlayer tGroupPlayer = groupPlayerMapper.findById(groupId);
                            if (!StringUtil.isEmpty(tGroupPlayer)) {
                                JSONObject jsonObject = JSONObject.parseObject(tGroupPlayer.getConfig());
                                map.put(ClubConstant.is_chat,jsonObject.getString(ClubConstant.is_chat));
                            }
                        }
                    }
                }

            }

            //String hget = cache.hget(Constants.USER_GAME_STATES, userId);
            //if (hget == null || "".equals(hget)) {
            //}else {
            //    //房卡场的返回方式
            //    String[] sp = hget.split("_");
            //    FreeGameActivityInfo fga = new FreeGameActivityInfo();
            //    fga.setUserId(Long.parseLong(userId));
            //    fga.setLevel(Integer.parseInt(sp[0]));
            //    fga.setTid(Long.parseLong(sp[1]));
            //    infos = new ArrayList<FreeGameActivityInfo>();
            //    infos.add(fga);
            //    return infos;
            //
        }catch (Exception e ) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }
        return map;
    }

    public List<FreeGameActivityInfo> viewOwnReganizeGames(String userId) throws Exception {
        return freeGameActivityMapper.queryOwnFreeGameRecord(Long.parseLong(userId));
    }

    public List<CacheGameActivityPlayer> viewReganizeGameUsers(String activityId) throws Exception {
        return activityUserMapper.queryFreeGamePlayers(Long.parseLong(activityId));
    }

    public String varifyPhones(String phones) throws Exception {
        ICache cache = CacheManager.getCache();

        try {
            return commonCacheController.varifyPhones(phones, cache);
        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }
    }

    public void varifyIdentity(String userId,String name,String identity) throws Exception {
        ICache cache = CacheManager.getCache();

        try {
        	String identityNumber = userMapper.selectIdentity(userId);
        	if (identityNumber!=null) {
        		throw new InfServerException(Constants.RETURN_CODE_FAIL, "该用户已认证");
			}else{
				boolean mark = IDCardUtil.isIDCard(identity);
				if (mark) {
					boolean names = IDCardUtil.isChineseName(name);
					if (names) {
						userMapper.updateIdentity(userId,name,identity);
					}else{
						throw new InfServerException(Constants.RETURN_CODE_FAIL, "请输入正确的姓名");
					}

				}else {
					throw new InfServerException(Constants.RETURN_CODE_FAIL, "请输入正确的身份证");
				}
			}

        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }
    }

    public boolean isPhoneExist(String phone) throws Exception {
        return UserUtil.isUserExistedInDatabase(userMapper, phone);
    }


    /**
     * 通过用户id获取用户任务列表
     *
     * @param userId
     * @return
     * @throws Exception
     */

    /**
     * 通过主播ID找到主播对应的运营商
     *
     * @throws Exception
     */
    public TSecUser findOperatorByAgent(TSecUser agent) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            while (agent.getParentId() != null && !agent.getUserid().equals(agent.getParentId())) {
                Long parentId = agent.getParentId();
                agent = secUserMapper.findById(parentId);
            }
            return agent;
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    /**
     * 上传图片视频文字
     *
     * @param userId
     * @param text
     * @param photos
     */

    /**
     * 设置支付密码
     *
     * @param userId
     */
//    public void setPayPassword(Long userId, String payPassword, String userType) throws Exception {
//        TUser user = new TUser();
//        user.setUserid(userId);
//        user.setPayPassword(payPassword);
//        if (userMapper.updateSelective(user) > 0) {
//            if (userType.equalsIgnoreCase(Constants.USER_TYPE_P)) {
//                ICache cache = null;
//                try {
//                    cache = CacheManager.getCache();
//                    CachePlayerProfile playerProfile = playerCacheController.queryPlayerDetail(userId, cache, false, false);
//                    playerProfile.setHasPayPassword(true);
//                    playerCacheController.updatePlayerDetail(playerProfile, cache);
//                } catch (Exception e) {
//                    throw e;
//                } finally {
//                    if (cache != null) {
//                        CacheManager.releaseCache(cache);
//                    }
//                }
//
//            } else {
//                ICache cache = null;
//                try {
//                    cache = CacheManager.getCache();
////                    compereCacheController.updateCompereDetailField(userId, USER_HAS_PAYPASSWORD, "true", cache);
//                } catch (Exception e) {
//                    throw e;
//                } finally {
//                    if (cache != null) {
//                        CacheManager.releaseCache(cache);
//                    }
//                }
//            }
//        }
//    }
//
//    /**
//     * 修改支付密码
//     *
//     * @param userId
//     * @param oldPayPassword
//     * @throws Exception
//     */
//    public void modifyPayPassword(Long userId, String oldPayPassword) throws Exception {
//        TUser user = userMapper.findById(userId);
//        if (user == null) {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, "用户不存在！");
//        }
//        if (!oldPayPassword.equals(user.getPayPassword())) {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, "支付密码错误！");
//        }
//    }


    public Integer increaseJewel(Long userId, Integer amount) throws Exception {
        if (amount < 0) {
            AccountVo vo = viewAccount(userId.toString());
            Long coinAmount = vo.getCoinAmount();
            if (coinAmount.intValue() < amount) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "余额不足");
            }
        }
        GameServerUtil.invokeUpdateJewel(userId, amount);
        return GameServerUtil.queryJewelAmount(userId);
    }

    public Map<String, CheckCodeInfo> getCodeMap() {
        return codeMap;
    }

    public void setCodeMap(Map<String, CheckCodeInfo> codeMap) {
        this.codeMap = codeMap;
    }

    /**
     * 验证房卡server是否有该用户的信息并做处理
     *
     * @param userId 用户ID
     */

    /**
     * 查找用户
     *
     * @param condition
     * @return
     */
    public List<CacheUserListProfile> findUser(String condition) {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            List<CacheUserListProfile> users = userMapper.queryUserByPhoneOrNickName(condition);
            for (CacheUserListProfile user : users) {
                if (user.getType().equalsIgnoreCase(Constants.USER_TYPE_C)) {
//                    CacheCompereProfile compere = compereCacheController.getCompereDetail(user.getUserId(), cache, false, false);
//                    user.setCityId(compere.getCityId());
//                    user.setCity(compere.getCity());
                } else if (user.getType().equalsIgnoreCase(Constants.USER_TYPE_P)) {
                    CachePlayerProfile player = playerCacheController.queryPlayerDetail(Long.parseLong(user.getUserId()), cache, false, false);
                    user.setCityId(player.getCityId());
                    user.setCity(player.getCity());
                }
            }
            return users;
        } catch (Exception e) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, e.getMessage());
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public String queryToken(String phone, String oldToken) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            return loginCacheController.queryToken(phone, oldToken, cache);
        } catch (InfServerException ie) {
            throw ie;
        } catch (Exception e) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, e.getMessage());
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public JSONObject isFirstCharged(Long userId) throws Exception {
        ICache cache = null;
        JSONObject result = new JSONObject();
        try {
            cache = CacheManager.getCache();
            Integer isFirstCharged = userCacheController.isFirstCharged(userId, cache);
            result.put("isFirstCharged", isFirstCharged);
            return result;
        } catch (InfServerException ie) {
            throw ie;
        } catch (Exception e) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, e.getMessage());
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    /**
     * 查看积分是否足够
     * @param userId
     * @param point
     */
    public void isHavingPoint(Long userId, Integer point) {
        TUser user = userMapper.findById(userId);
        if (user.getPoint() < point) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"您的积分不够哦");
        }
    }

    public void isHavingRoomCard(Long userId, Integer roomCard) {
        TUser user = userMapper.findById(userId);
        if (user.getCardCount() < roomCard) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"您的房卡不够哦");
        }
    }

    /**
     * 积分足够,进行积分赠送操作
     * @param userId
     * @param toUserId
     * @param point
     * @return 是否积分赠送成功
     */
    public Integer changePoints(Long userId, Long toUserId, Integer point) throws Exception {
        TUser user1 = userMapper.findById(userId);
        TUser user2 = userMapper.findById(toUserId);
        if (user1 == null || user2 == null) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"您输入的用户不存在");
        }
        List<FreeGameActivityInfo> list = this.viewReganizeGames(userId.toString());
        if (list == null || list.size() == 0) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"该用户正在游戏中,请在游戏结束后再进行兑换!!");
        }
        this.isHavingPoint(userId,point);
        int currentPoint = user1.getPoint() - point;
        user1.setPoint(currentPoint);
        int currentPonint2 = user2.getPoint() + point;
        user2.setPoint(currentPonint2);
        userMapper.update(user1, false);
        userMapper.update(user2, false);

        //保存到赠送数据到数据库
        TGiftPoint tGiftPoint = new TGiftPoint();
        tGiftPoint.setUserId(userId);
        tGiftPoint.setToUserId(toUserId);
        tGiftPoint.setPoint(point);
        tGiftPoint.setUserPoint(currentPoint);
        tGiftPoint.setToUserPoint(currentPonint2);
        giftPointMapper.insert(tGiftPoint);
        return currentPoint;
    }

    /**
     * 赠送房卡
     * @param userId
     * @param toUserId
     * @param roomCard
     * @return
     */

    public Integer changeRoomcard(Long userId, Long toUserId, Integer roomCard) {
        TUser user1 = userMapper.findById(userId);
        TUser user2 = userMapper.findById(toUserId);
        if (user1 == null || user2 == null) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"您输入的用户不存在");
        }
        this.isHavingRoomCard(userId,roomCard);
        int currentPoint = user1.getCardCount() - roomCard;
//        user1.setCardCount(currentPoint);
        int currentPonint2 = user2.getCardCount() + roomCard;
//        user2.setCardCount(currentPonint2);

        baseCacheController.updateRoomCard(userId, -roomCard);
        baseCacheController.updateRoomCard(toUserId,roomCard);

//        userMapper.update(user1, false);
//        userMapper.update(user2, false);

        //保存到赠送数据到数据库
        TGiftRoomCard tGiftPoint = new TGiftRoomCard();
        tGiftPoint.setUserId(userId);
        tGiftPoint.setToUserId(toUserId);
        tGiftPoint.setRoomcardNum(roomCard);
        tGiftPoint.setUserRoomcardNum(currentPoint);
        tGiftPoint.setToUserRoomcardNum(currentPonint2);
        tGiftPoint.setType(Constants.GIFT_ROOM_CARD);
        giftRoomCardMapper.insert(tGiftPoint);
        return currentPoint;
    }

    public String statusByUserId(String userId) throws Exception {
        ICache cache = CacheManager.getCache();

        try {
            String status = cache.hget(Constants.PLAYER_ + userId, "status");
            if (StringUtil.isEmpty(status)) {
                status = userMapper.findById(Long.parseLong(userId)).getState();
            }
            return status;
        }catch(Exception e) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }
    }
}
