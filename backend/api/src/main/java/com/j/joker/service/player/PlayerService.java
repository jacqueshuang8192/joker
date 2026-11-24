package com.j.joker.service.player;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.rfUtil.Md5;
import com.j.joker.core.util.*;
import com.j.joker.cache.CacheManager;
import com.j.joker.cache.ICache;
import com.j.joker.cache.controller.*;
import com.j.joker.cache.model.CachePlayerProfile;
import com.j.joker.constants.AnnounceConstants;
import com.j.joker.constants.Constants;
import com.j.joker.mapper.*;
import com.j.joker.model.*;
import com.j.joker.service.Gold.GoldService;
import com.j.joker.service.charge.BaseChargeService;
import com.j.joker.service.common.AccountChargeService;
import com.j.joker.service.common.BaseDataService;
import com.j.joker.service.common.GameService;
import com.j.joker.service.inviteCodeGen.InviteCodeGen;
import com.j.joker.service.roomcard.RoomCardService;
import com.j.joker.utils.*;
import com.j.joker.utils.yeepay.HttpClientUtil;
import com.j.joker.utils.yeepay.RandomUtil;
import com.j.joker.vo.request.common.MapVo;
import com.j.joker.vo.response.Response;
import com.j.joker.vo.response.user.OAuthVo;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.RandomUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.logging.Logger;

@Service
public class PlayerService {
    @org.springframework.beans.factory.annotation.Value("${JOKER_PURE_JAVA:false}")
    private boolean pureJavaHall;

    @Autowired
    private TUserMapper userMapper;
    @Autowired
    private TPlayerMapper playerMapper;
    @Autowired
    private BullFightGameInfoMapper bullFightGameInfoMapper;
    @Autowired
    private PlayerCacheController playerCacheController;
    @Autowired
    private CommonCacheController commonCacheController;
    @Autowired
    private GameService gameService;
    @Autowired
    private AccountChargeService accountChargeService;
    @Autowired
    private InviteCodeGen codeGen;
    @Autowired
    private UserCacheController userCacheController;
    @Autowired
    private RoomCardService roomCardService;
    @Autowired
    private TConfigMapper configMapper;
    @Autowired
    private TSecUserMapper secUserMapper;
    @Autowired
    private TAgentIdMapper agentIdMapper;
    @Autowired
    private TYaoQingBangDingMapper tYaoQingBangDingMapper;
    @Autowired
    private BaseCacheController baseCacheController;
    @Autowired
    private BaseChargeService baseChargeService;
    @Autowired
    private GoldService goldService;
    @Autowired
    private TGiftRoomCardMapper giftRoomCardMapper;
    @Autowired
    private ImsMsgService msgService;
    @Autowired
    private TFreeGameResultMapper freeGameResultMapper;
    @Autowired
    private BaseDataService baseDataService;
    
  //填写邀请人领取房卡
    public void getRoomcard(Long userId) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            TYaoQingBangDing tYaoQingBangDing = new TYaoQingBangDing();
            tYaoQingBangDing.setUserId(userId);
            tYaoQingBangDing=tYaoQingBangDingMapper.selectOne(tYaoQingBangDing);
            Integer isGet = tYaoQingBangDing.getIsGetRoomcards();
            Long promoterId = tYaoQingBangDing.getPromoterId();
            if (isGet!=null) {
            	tYaoQingBangDingMapper.updateIsGet(userId);
            	//填推荐送房卡
            	TConfig config = new TConfig();
                config.setK("bindPromoterSendCard");
                config=configMapper.selectOne(config);
                if (config!=null) {
                    String v = config.getV();
                    int count = Integer.parseInt(v);
                    
                    userMapper.increaseYaoqingRoomCard(promoterId, count);  
                    userMapper.increaseRoomCard(promoterId, count);
                }else{
                	
                	userMapper.increaseRoomCard(promoterId, 0);
                	userMapper.increaseYaoqingRoomCard(promoterId, 0);
                }
			}else {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "领取失败");
			}
            		
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }
    
    
    /*
     * 邀清
     */
    
  //用户绑定推荐人
    public void userBindingPromoter(Long userId,Long promoterId) throws Exception {
        ICache cache = CacheManager.getCache();
        try {
            TUser user = userMapper.findById(userId);
            if (user != null) {
                Integer isYaoqing = user.getIsYaoqing();
                if (isYaoqing != 1) {
                    TUser user1 = userMapper.findById(promoterId);
                    if (user1!=null) {
                    	userMapper.updateIsYaoqing(userId);
                    	//记录推荐表
                    	TConfig config = new TConfig();
                        config.setK("bindPromoterSendCard");
                        config=configMapper.selectOne(config);
                    	TYaoQingBangDing tYaoQingBangDing = new TYaoQingBangDing();
                    	tYaoQingBangDing.setPromoterId(promoterId);
                    	String userName = userMapper.selectNickNameByUSerId(userId);
                    	String promoterName = userMapper.selectNickNameByUSerId(promoterId);
                    	tYaoQingBangDing.setUserName(userName);
                    	tYaoQingBangDing.setUserId(userId);
                    	tYaoQingBangDing.setDate(new Date());
                    	tYaoQingBangDing.setPromoterName(promoterName);
                    	tYaoQingBangDing.setIsGetRoomcards(0);
                    	tYaoQingBangDing.setYaoqingRoomcards(0);
                    	tYaoQingBangDingMapper.insert(tYaoQingBangDing);
                    	
                    	
                    	
                    	TYaoQingBangDing tYaoQingBangDing1 = new TYaoQingBangDing();
                        tYaoQingBangDing1.setUserId(userId);
                        tYaoQingBangDing1=tYaoQingBangDingMapper.selectOne(tYaoQingBangDing1);
                        Long promoterId1 = tYaoQingBangDing1.getPromoterId();
                        String promoterName1 = tYaoQingBangDing1.getPromoterName();
                        PlayerCacheController playerCacheController = new PlayerCacheController(); 
                        playerCacheController.updatePlayerField(userId, "promoterId", String.valueOf(promoterId1), cache);
                        playerCacheController.updatePlayerField(userId, "promoterName", promoterName1, cache);
                        
                        if (config!=null) {
                            String v = config.getV();
                            int count = Integer.parseInt(v);
                            userMapper.increaseRoomCard(userId, count);                          
                        }else{
                        	
                        	userMapper.increaseRoomCard(userId, 0);
                            
                        }
                    }else {
                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "该玩家不存在");
                    }
                }else {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "该用户已绑定推荐人");
                }
            }else {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "该用户不存在");
            }
        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }
    }
    
    /**
     * 注册用户，插入数据库，调用环信接口
     *
     * @param player
     * @param user
     * @return
     */
    public void register(TPlayer player, TUser user, String invitationCode) {
        if (UserUtil.isUserExistedInDatabase(userMapper, user.getPhone())) {
            throw new InfServerException(Constants.RETURN_CODE_PHONE_ALREADY_EXISTED, "账户已存在");
        }
        String pwd = user.getPassword();
        ICache cache = null;
        try {
            cache = CacheManager.getCache();

            Date nowDate = new Date();
            userMapper.insert(user);
            TUser newUser = new TUser();
            newUser.setPhone(user.getPhone());
            user = userMapper.selectOne(newUser);
            player.setPlayerId(user.getUserid());

            String temp = "000000000" + user.getUserid();
            player.setPromoCode(codeGen.getCode());
            initPlayer(player, cache);
            playerMapper.insert(player);

            //用户类型
            commonCacheController.addUserType(user.getUserid().toString(), Constants.USER_TYPE_P, cache);

            BullfightGameinfo gameInfo = new BullfightGameinfo();
            gameInfo.setMid(user.getUserid().intValue());
            bullFightGameInfoMapper.createUser(gameInfo);

        } catch (Exception e) {
            e.printStackTrace();
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "注册失败");
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public OAuthVo quickRegister(String nickname, String code, String password, String photo, String sex, String qq, String wechat, String weibo, Integer isRobot) throws Exception {
        ICache cache = null;
        try {
            if (isOAuthCodeExist(Constants.OAUTH_WECHAT, wechat)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "网络错误，请重试");
            }
            nickname = CommonUtil.filterEmoji(nickname);

            cache = CacheManager.getCache();
            TPlayer player = new TPlayer();
            TUser user = new TUser();

            OAuthVo vo = new OAuthVo();

            user.setPhone(code);
            user.setAccount(code);
            user.setPassword(password);
            user.setNickName(nickname);
            user.setType(Constants.USER_TYPE_P);
            user.setState(Constants.VALID);
            if (StringUtils.isNotBlank(sex)) {
                user.setGender(sex);
            } else {
                int ran = RandomUtils.nextInt(2);
                if (ran == 0) {
                    user.setGender(Constants.USER_GENDER_MALE);
                } else {
                    user.setGender(Constants.USER_GENDER_FEMALE);
                }
            }
            if (StringUtils.isBlank(photo)) {
                photo = commonCacheController.queryRandomPhoto(cache).getPhoto();
            }
            user.setSmallIcon(photo);
            user.setQq(qq);
            user.setWechat(wechat);
            user.setWeibo(weibo);
            user.setGrade(0F);
            user.setCreateDate(new Date());
            user.setDeprecated(Constants.USER_NOT_DEPRECATED);
            user.setCardCount(9999);
            user.setClubLimit(1);
            user.setPoint(9999);
            user.setGiftGold(9999);
            user.setGiftGoldCount(9999);
            user.setYaoqingRoomcards(9999);
            userMapper.insertUser(user);

            Long userId = user.getUserid();

            player.setPromoCode(code);
            player.setPlayerId(userId);
            initPlayer(player, cache);
            playerMapper.insert(player);

            //用户类型
            commonCacheController.addUserType(userId.toString(), Constants.USER_TYPE_P, cache);

            //初始化房卡缓存
            baseCacheController.updateRoomCard(userId, 9999);

            BullfightGameinfo gameInfo = new BullfightGameinfo();
            gameInfo.setMid(userId.intValue());
            gameInfo.setMoney(9999);
            bullFightGameInfoMapper.createUser(gameInfo);

            vo.setPhone(code);
            vo.setPassword(password);
            vo.setPhoto(photo);
            return vo;
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public OAuthVo quickRegisterByPhone(String phone,String nickname,String password,String photo,String sex) throws Exception {
        ICache cache = null;
        try {

            boolean isPhone = IDCardUtil.isChinaPhoneLegal(phone);
            if (!isPhone ) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "手机号码异常...");
            }
            boolean isExist = UserUtil.isUserExistedInDatabase(userMapper, phone);
            if (isExist ) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "账号已经存在,请直接登录...");
            }
            nickname = CommonUtil.filterEmoji(nickname);
            if (StringUtil.isEmpty(nickname) || StringUtil.isEmpty(nickname.trim()) || nickname.length() > 8) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "昵称不可为空,并且不可超过8个字符...");
            }
            if (StringUtil.isEmpty(password) || StringUtil.isEmpty(password.trim()) || password.length() <= 5) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "密码不可为空,并且要大于5个字符...");
            }

            cache = CacheManager.getCache();
            TPlayer player = new TPlayer();
            TUser user = new TUser();

            OAuthVo vo = new OAuthVo();

            user.setPhone(phone);
            user.setAccount(phone);
            user.setPassword(password);
            user.setNickName(nickname);
            user.setType(Constants.USER_TYPE_P);
            user.setState(Constants.VALID);
            user.setGender(sex);
            if (StringUtil.isEmpty(sex) || (!"1".equals(sex) && !"2".equals(sex))) {
                sex = "1";
                user.setGender(sex);
            }

            if (StringUtils.isBlank(photo) || phone.endsWith(".png")) {
                photo = commonCacheController.queryRandomPhoto(cache).getPhoto();
                if ("1".equals(sex) ) {
                    //用的是讯游的OSS
                    photo = "http://xylm1.oss-cn-shenzhen.aliyuncs.com/common_photo/man1.png";
                }else {
                    photo = "http://xylm1.oss-cn-shenzhen.aliyuncs.com/common_photo/girl2.png";
                }
            }
            user.setSmallIcon(photo);
            long userId = insertRegisteredPlayer(user, player);
            commonCacheController.addUserType(Long.toString(userId), Constants.USER_TYPE_P, cache);
            baseCacheController.updateRoomCard(userId, user.getCardCount());

            vo.setPhone(phone);
            vo.setPassword(password);
            vo.setPhoto(photo);
            return vo;
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public long createUsernamePlayer(String username) {
        TUser user = new TUser();
        user.setAccount("username:" + username);
        user.setNickName(username);
        user.setType(Constants.USER_TYPE_P);
        user.setState(Constants.VALID);
        user.setGender("1");
        user.setSmallIcon("");
        return insertRegisteredPlayer(user, new TPlayer());
    }

    private long insertRegisteredPlayer(TUser user, TPlayer player) {
        user.setGrade(0F);
        user.setCreateDate(new Date());
        user.setDeprecated(Constants.USER_NOT_DEPRECATED);
        user.setCardCount(9999);
        user.setClubLimit(1);
        user.setPoint(9999);
        user.setGiftGold(9999);
        user.setGiftGoldCount(9999);
        user.setYaoqingRoomcards(9999);
        userMapper.insertUser(user);

        Long userId = user.getUserid();

        player.setPromoCode(user.getAccount());
        player.setPlayerId(userId);
        playerMapper.insert(player);

        BullfightGameinfo gameInfo = new BullfightGameinfo();
        gameInfo.setMid(userId.intValue());
        gameInfo.setMoney(9999);
        bullFightGameInfoMapper.createUser(gameInfo);
        return userId;
    }

    private Integer queryOldUser(String nickname, String photo) {
        boolean isIOS = isIOS(photo);
        TUser user    = new TUser();
        user.setNickName(nickname);
        List<TUser> list = userMapper.select(user);
        int maxCardCount = 0;
        for (TUser u : list) {
            if (isIOS(u.getSmallIcon()) == isIOS && u.getCardCount() > maxCardCount) {
                maxCardCount = u.getCardCount();
            }
        }
        return maxCardCount;
    }

    private boolean isIOS(String photo) {
        if (photo.contains("oss-cn")) {
            return true;
        }
        return false;
    }

    public String bindPhone(Long userId, String phone) throws Exception {
        ICache cache = null;
        try {
            boolean chinaPhoneLegal = IDCardUtil.isChinaPhoneLegal(phone);
            if  (!chinaPhoneLegal) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "请输入正确的手机号码");

            }
            cache = CacheManager.getCache();
            TUser user = new TUser();
            user.setUserid(userId);
            List<TUser> list = userMapper.select(user);
            if (list.size() <= 0) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "改玩家不存在");
            }
            if (list.get(0).getPhone().length() == 11) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您已经绑定过手机号码了!!");
            }
            user = new TUser();
            user.setUserid(userId);
            user.setPhone(phone);
            if (userMapper.updateSelective(user) > 0) {
                playerCacheController.updatePlayerField(userId, "phone", phone, cache);
            }
            //绑定送卡
            String bindPhoneSendCard = baseCacheController.queryConfig("bindPhoneSendCard", cache);
            if(StringUtil.isNotEmpty(bindPhoneSendCard)) {
//                userMapper.increaseRoomCard(userId,Integer.parseInt(bindPhoneSendCard));
                baseCacheController.updateRoomCard(userId,Integer.parseInt(bindPhoneSendCard));
                userMapper.insertTplayerShareGiftRecord(userId,bindPhoneSendCard,"0",Constants.bindPhone);
            }
            return bindPhoneSendCard;
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public String queryPhoneByUid(Long userId) {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            String phone = cache.hget(Constants.PLAYER_ + userId, "phone");
            if (phone.length() != 11) {
                return "";
            }else {
                return phone;
            }
        }catch (Exception e ) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "网络出错,请稍后再试!!");
        }finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    /**
     * 根据用户ID查找玩家
     *
     * @param userid
     * @return
     * @throws Exception
     */
    public CachePlayerProfile getPlayerInfoById(String userid)
            throws Exception {
        CachePlayerProfile playerDetail = null;
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            playerDetail = playerCacheController
                    .queryPlayerDetail(Long.parseLong(userid), cache, true, true);
            if (playerDetail == null) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "玩家不存在！");
            }
            if (StringUtils.isBlank(playerDetail.getPhone())) {
                playerDetail.setHasBindPhone(false);
            } else {
                playerDetail.setHasBindPhone(!playerDetail.getPhone().equals(playerDetail.getAccount()));
                playerDetail.setPhone(playerDetail.getAccount());
            }
            playerDetail.setCardCount(roomCardService.queryRoomCardCount(Long.parseLong(userid)));

        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
        return playerDetail;
    }

    public GameServerAuthInfo getPlayerInfo4GameServer(String userId, HttpServletRequest request)
            throws Exception {
        GameServerAuthInfo authInfo = new GameServerAuthInfo();
        CachePlayerProfile profile = getPlayerInfoById(userId);
        profile.setMyIp(HttpUtil.getIPAddress(request));
        authInfo.setPlayerProfile(profile);
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            TGameServer server = gameService.queryGameServer(userId);
//            TUser player = userMapper.findById(Long.parseLong(userId));
            Integer isFirstLogin = userCacheController.getIsFirstLogin(Long.parseLong(userId), cache);
//            Integer isFirstLogin = userCacheController.getIsFirstLogin(Long.parseLong(userId),cache);
//            Date lastLogin = player.getLastLogin();
//            Integer everydaySendCardCount= roomCardService.everydayLoginSendCard(Long.parseLong(userId), lastLogin);
            authInfo.setIsFirstLogin(isFirstLogin);
//            authInfo.setEverydayLoginSendCard(everydaySendCardCount);

            TUser user = new TUser();
            user.setUserid(Long.parseLong(userId));
            user.setLastLogin(new Date());
//            user.setFirstLogin(0);
            userMapper.updateSelective(user);
            authInfo.setHall(server);
            String sessionToken = request.getParameter("XYToken");
            if (sessionToken != null && !sessionToken.isBlank()) {
                var hash = java.security.MessageDigest.getInstance("SHA-256");
                byte[] key = ("joker/douniu/" + userId + "/" + sessionToken)
                        .getBytes(java.nio.charset.StandardCharsets.UTF_8);
                authInfo.setPureJavaHall(pureJavaHall);
                authInfo.setDouniuKey(java.util.HexFormat.of().formatHex(hash.digest(key)));
            }
            authInfo.setMtKey(ConfigUtil.get("protocol.mtKey"));
            authInfo.setAnnouncement(baseDataService.queryAnnouncementByType(AnnounceConstants.ANNOUNCE_TYPE_ZOUMADENG));


//            if (isFirstLogin.equals(0)) {
//                TUser user = new TUser();
//                user.setUserid(Long.parseLong(userId));
//                user.setFirstLogin(1);
//                if (userMapper.updateSelective(user) > 0) {
//                    userCacheController.setFirstLogin(Long.parseLong(userId), cache);
//                }
//            }
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
        return authInfo;
    }

    /**
     * 根据ID查找玩家信息
     *
     * @param userid
     * @return
     * @throws Exception
     */
    public TPlayer getPlayerById(String userid) throws Exception {
        TPlayer player = playerMapper.findById(Long.parseLong(userid));
        if (player != null) {
            TUser user = userMapper.findById(Long.parseLong(userid));
            if (user != null) {
                player.setUser(user);
            } else {
                throw new InfServerException(
                        Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR,
                        "没有查询到相关账号");
            }
        } else {
            throw new InfServerException(
                    Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到相关账号");
        }
        return player;
    }

    /**
     * 更新用户
     *
     * @throws Exception
     */
    public void updatePlayer(TPlayer player) throws Exception {
        playerMapper.updateSelective(player);
        userMapper.updateSelective(player.getUser());
        // 更新Redis
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            playerCacheController.updateCachePlayer(player, cache);
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    //用户绑定代理
    public void userBindingAgent(Long userId,Long agentId) throws Exception {
        ICache cache = CacheManager.getCache();
        try {
            TUser user = userMapper.findById(userId);
            if (user != null) {
                Long secuserId = user.getAgentId();
                if (secuserId == null) {
                    TSecUser secUser = secUserMapper.findById(agentId);
                    if (secUser!=null) {
                        userMapper.userBindingAgent(userId, agentId);
                        TSecUser sec = new TSecUser();
                        sec.setUserid(agentId);
//                        sec=secUserMapper.selectOne(sec);
        				String nickNme = secUser.getFullname();
        				PlayerCacheController playerCacheController = new PlayerCacheController(); 
                        playerCacheController.updatePlayerField(agentId, "agentId", String.valueOf(agentId), cache);
                        playerCacheController.updatePlayerField(agentId, "agentName", nickNme, cache);
                        TConfig config = new TConfig();
                        config.setK("bindAgentSendCard");
                        config=configMapper.selectOne(config);
                        if (config!=null) {
                            String v = config.getV();
                            int count = Integer.parseInt(v);
                            userMapper.increaseRoomCard(userId, count);
                        }else{
                            userMapper.increaseRoomCard(userId, 0);
                        }
                    }else {
                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "该代理不存在");
                    }
                }else {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "该用户已绑定代理");
                }
            }else {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "该用户不存在");
            }
        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }
    }

    public OAuthVo OAuthCheck(String type, String code) throws Exception {
        TUser user = new TUser();
        user.setDeprecated(Constants.USER_NOT_DEPRECATED);
        if (type.equalsIgnoreCase(Constants.OAUTH_QQ)) {
            user.setQq(code);
        } else if (type.equalsIgnoreCase(Constants.OAUTH_WECHAT)) {
            user.setWechat(code);
        } else if (type.equalsIgnoreCase(Constants.OAUTH_WEIBO)) {
            user.setWeibo(code);
        } else {
            user.setQq(code);
        }
        List<TUser> list = userMapper.select(user);
        if (CollectionUtils.isNotEmpty(list)) {
            OAuthVo vo = new OAuthVo();
            vo.setPhone(list.get(0).getAccount());
            vo.setPassword(list.get(0).getPassword());
            return vo;
        } else {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "第三方账号不存在！");
        }
    }

    public boolean isOAuthCodeExist(String type, String code)
    {
        TUser user = new TUser();
        user.setDeprecated(Constants.USER_NOT_DEPRECATED);
        if (type.equalsIgnoreCase(Constants.OAUTH_QQ)) {
            user.setQq(code);
        } else if (type.equalsIgnoreCase(Constants.OAUTH_WECHAT)) {
            user.setWechat(code);
        } else if (type.equalsIgnoreCase(Constants.OAUTH_WEIBO)) {
            user.setWeibo(code);
        } else {
            user.setQq(code);
        }
        List<TUser> list = userMapper.select(user);
        if (CollectionUtils.isNotEmpty(list)) {
            return true;
        }
        return false;
    }

    private void initPlayer(TPlayer player, ICache cache) throws Exception {
    }


    public void validateAppStoreCharge(Long userId, Integer payAmount, Integer coinAmount, String receipt) throws Exception {
        if (validateLiveCharge(receipt) || validateSandboxCharge(receipt)) {//验证生产环境
            Integer disCountedPayAmount = new Double(Math.floor(new Double(payAmount * 0.7).intValue())).intValue();
            TAccountCharge accountCharge = new TAccountCharge();
            accountCharge.setUserId(userId);
            accountCharge.setStatus(Constants.PAY_TO_BE_CONFIRMED);
            accountCharge.setChannel("1"); //平台直充
            accountCharge.setPayType("I");//ios应用内支付
            accountCharge.setChargeDate(new Date());
            accountCharge.setCoinAmount(coinAmount);
            accountCharge.setRmbAmount(payAmount);
            accountCharge.setDiscountedRmbAmount(disCountedPayAmount);
            accountCharge.setChargeOrder(receipt);
            if (validateSandboxCharge(receipt)) {
                accountCharge.setRemark("sandbox");
                accountChargeService.save(accountCharge);
                throw new ChargeException(Constants.RETURN_CODE_CHARGE_TYPE_SANDBOX, "充值成功[Sandbox]");
            } else {
                accountChargeService.save(accountCharge);
                accountChargeService.updateAccountChargeByPingPPOrderId(receipt, "");
            }
            return;
        } else {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "IOS支付凭证验证失败");
        }
    }

    private boolean validateLiveCharge(String receipt) {
        String url = "https://buy.itunes.apple.com/verifyReceipt";
        String param = String.format(Locale.CHINA,"{\"receipt-data\":\"" + receipt+"\"}");
        String response = HttpUtil.sendPost(url, param);
        JSONObject result = JSONObject.parseObject(response);
        Integer status = result.getInteger("status");
        if (status == 0) {//验证生产链接
            return true;
        } else {//验证测试链接
            return false;
        }
    }

    private boolean validateSandboxCharge(String receipt) {
        String url = "https://sandbox.itunes.apple.com/verifyReceipt";
        String param = String.format(Locale.CHINA,"{\"receipt-data\":\"" + receipt+"\"}");
        String response = HttpUtil.sendPost(url, param);
        //Deserialize response
        JSONObject result = JSONObject.parseObject(response);
        Integer status = result.getInteger("status");
        if (status == 0) {//验证生产链接
            return true;
        } else {//验证测试链接
            return false;
        }
    }

    public String generateNickname() throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            return playerCacheController.generateNickname(cache);
        } catch (Exception e) {
            throw  e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public TSecUser applyAgent(String phone, String name) throws Exception {
        TSecUser secUser = new TSecUser();
        secUser.setUsername(phone);
        secUser = secUserMapper.selectOne(secUser);
        if (secUser != null) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "该手机号的代理已存在");
        }
        String password = ConfigUtil.get("agent.initialPassword");
        secUser = new TSecUser();
        Long agentId = getAgentId();
        secUser.setUserid(agentId);
        secUser.setFullname(name);
        secUser.setPassword(EncryptUtils.encodeMD5String(password));
        secUser.setUsername(phone);
        secUser.setUsertype("2");//2 means agent
        secUser.setCreateDate(new Date());
        secUser.setStatus((short)0);
        secUser.setParentId(0L);
        secUser.setGrandfatherId(0L);
        secUser.setRoomCardNum(0);
        insertAgent(secUser);
        return secUser;
    }

    public void insertAgent(TSecUser secUser) {
        if (secUserMapper.insert(secUser) <= 0) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "代理新增失败");
        }
    }

    private Long getAgentId() {
        Long agentId = agentIdMapper.selectUnusedId();
        if (agentId != null) {
            TAgentId tAgentId = new TAgentId();
            tAgentId.setAgentId(agentId);
            tAgentId.setUsedFlag("1");
            agentIdMapper.updateSelective(tAgentId);
        }
        return agentId;
    }

    public Response userBindingAgentByGold(long userId, long agentId) throws Exception {
        Response response = new Response();
        ICache cache = null;
//        try {
            TUser user = userMapper.findById(userId);
            if (user == null) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"玩家不存在!!");
            } else if(StringUtil.isNotEmpty(user.getAgentId())) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"您已经绑定过代理了!!");
            } else{
                Long agent = userMapper.selectAgentIsExit(agentId);
                if (StringUtil.isEmpty(agent) || agent == 1 ) {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL,"代理不存在!!");
                }
                Long id = user.getAgentId();
                if (StringUtil.isEmpty(id)) {

                    MapVo map = userMapper.selectImsTpUserByIsBind(agentId);
                    userMapper.updateAgentId(userId,agentId);
                    if (StringUtil.isNotEmpty(map) && "1".equals(map.getMapValue())) {
                        cache = CacheManager.getCache();
                        String bindAgentSendCard = baseCacheController.queryConfig("bindAgentSendCard", cache);
                        String bindAgentSendGold = baseCacheController.queryConfig("bindAgentSendGold", cache);
                        if (StringUtil.isEmpty(bindAgentSendCard) || "0".equals(bindAgentSendCard)) {
                            bindAgentSendCard="0";
                        }else {
                            baseCacheController.updateRoomCard(userId,Integer.parseInt(bindAgentSendCard));
                        }
                        if (StringUtil.isEmpty(bindAgentSendGold) || "0".equals(bindAgentSendGold)) {
                            bindAgentSendGold="0";
                        }else {
                            baseChargeService.playerGoldRecharge(1,userId,Integer.parseInt(bindAgentSendGold));
                        }
                        if (cache.exist(Constants.PLAYER_+userId)) {
                            cache.hset(Constants.PLAYER_+userId,"agentId",agentId+"");
                        }
                        CacheManager.releaseCache(cache);
                        userMapper.increaseUseGoldbind(agentId,bindAgentSendGold);
                        userMapper.insertTplayerShareGiftRecord2AgentId(userId,bindAgentSendCard,bindAgentSendGold,Constants.giftPlayerBindAgent,agentId);
                    }

                    response.setReturnCode(Constants.RETURN_CODE_SUCCESS);

                }else {
                    if(null != cache) {
                        CacheManager.releaseCache(cache);
                    }
                    throw new InfServerException(Constants.RETURN_CODE_FAIL,"您已经绑定过代理了!!");
                }
            }
//        }catch (Exception e ) {
//            CacheManager.releaseCache(cache);
//            System.out.println(e.getMessage());
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setData("网络异常,请稍后再试!!");
//        }
        return response;
    }

    public Response queryUseBiqiHistory(Long playerId) {
        Response response = new Response();
        try {
            List<TBiqiCardId> list =  playerMapper.queryUseBiqiHistory(playerId);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(list);
        }catch (Exception e ) {
            System.out.println(e.getMessage());
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("网络异常,请稍后再试!!");
        }
        return response;
    }

    public void playerRegister2Agent(Long userId, String loginName, String passWord, String phone) throws Exception {
        try {
            String name =  secUserMapper.selectByLoginName(loginName);
            if (!IDCardUtil.isChinaPhoneLegal(phone)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"您好,请输入正确的手机号码!!");
            }
            if (StringUtil.isNotEmpty(name)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"您好,此用户名已经被使用!!");
            }else {
                TUser tUser = userMapper.findById(userId);
                Long agnetId = 1L;
                if (StringUtil.isNotEmpty(tUser.getAgentId())) {
                    agnetId = tUser.getAgentId();
                }
                secUserMapper.insertIntoImsTpUser(userId,loginName,MD5.sign(passWord,"","utf-8"),phone,tUser.getWechat(),tUser.getSmallIcon(),tUser.getNickName(),agnetId);
            }
        }catch (Exception e ) {
            throw e;
        }
    }

    public Response playerXXX(Integer playerId1, Integer playerId2, Integer count,String sign,String remark) throws Exception {
        Response response = new Response();
        Long goldCount = goldService.queryGoldCount(Long.parseLong(playerId1+""));
        if ( count < 0 ) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"您好,请输入正确的的数量!!");
        }

        if (Long.parseLong(count+"") > goldCount) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"您好,您的钻石数量不足,请充值!!");
        }
        TUser tUser = userMapper.findById(Long.parseLong(playerId2 + ""));
        if (tUser == null ) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"您好,该账号不存在,请重新输入");
        }
        String mySign = playerId1 + "&" + playerId2 + "*" + count + ConfigUtil.get("mySign");
        if (!sign.equalsIgnoreCase(MD5.sign(mySign,"","UTF-8"))) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"网络异常,请稍后再试!!");
        }


        boolean status = baseChargeService.setPlayerGameStatus(playerId1);
        if (status) {



            //留下赠送记录
            TGiftRoomCard tGiftRoomCard = new TGiftRoomCard();
            tGiftRoomCard.setUserId(Long.parseLong(playerId1+""));
            tGiftRoomCard.setToUserId(Long.parseLong(playerId2 + ""));
            tGiftRoomCard.setRoomcardNum(count);
            tGiftRoomCard.setRemark(remark);
            tGiftRoomCard.setCreateTime(new Date());
            tGiftRoomCard.setType(Constants.GIFT_GOLD);

            giftRoomCardMapper.insert(tGiftRoomCard);
            baseChargeService.playerGoldRecharge(1,Long.parseLong(playerId1+""),-count);
            baseChargeService.playerGoldRecharge(1,Long.parseLong(playerId2+""),count);
//            释放玩家状态
            baseChargeService.changePlayerGameStatus(playerId1);

            GameServerUtil.notice2GameServerGoldRec(Long.parseLong(playerId2+""),count);

            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("赠送成功!!");
        }else {
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setData("网络异常,请稍后再试!!");
        }
        return response;

    }

    public Response queryMyAgentAdvice(Integer userId) {
        Response response = new Response();
        String biqiLink = ConfigUtil.get("biqiLink");
        JSONObject json = new JSONObject();
        json.put("link","");
        String agentId = baseCacheController.queryMyAgent(userId);
        if (StringUtil.isEmpty(agentId)) {
            json.put("advice","");
        }else {
            String biqiId = userMapper.selectImsTpUserByBiqiId(Long.parseLong(agentId + ""));
            if (StringUtil.isEmpty(biqiId)) {
                biqiId = "";
            }

            String advice = baseCacheController.queryAgentAdvice(agentId);
            json.put("advice",advice);
            json.put("link",biqiLink + biqiId);
        }
        response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        response.setData(json);
        return response;
    }

    public Response queryPlayerXXX(Integer playerId,Integer type,String currentPage,String pageSize) {
        Response response = null;
        try {

            response = new Response();
            List<TGiftRoomCard> result = null;

            //默认分30页
            if (StringUtil.isEmpty(pageSize)) {
                pageSize = "30";
            }

            Integer beginRowIndex = (Integer.parseInt(currentPage)-1)*(Integer.parseInt(pageSize));
            if (beginRowIndex < 0) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"请输入正确的页数");
            }

            if (type.equals(Constants.SHONG)) {
                result =  playerMapper.queryPlayerShong(playerId,beginRowIndex,Integer.parseInt(pageSize));
            }
            if (type.equals(Constants.SHOU)) {
                result = playerMapper.queryPlayerShou(playerId,beginRowIndex,Integer.parseInt(pageSize));
            }
            response.setData(result);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);

            return response;
        }catch (Exception e ) {
            System.out.println(e.getMessage());
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"网络异常,请稍后再试!!");
        }finally {

        }
    }

    public Response queryPlayerWaiWeiHistory(Integer playerId, String currentPage, String pageSize) {
        Response response = null;
        try {

            response = new Response();
            List<TWaiWriOrderHistory> result = null;

            //默认分30页
            if (StringUtil.isEmpty(pageSize)) {
                pageSize = "30";
            }
            Integer beginRowIndex = (Integer.parseInt(currentPage)-1)*(Integer.parseInt(pageSize));
            if (beginRowIndex < 0) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"请输入正确的页数");
            }
            int i = playerId%10;
            result = playerMapper.queryPlayerWaiWeiHistory(playerId,i,beginRowIndex,Integer.parseInt(pageSize));

            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:SS");
            if (StringUtil.isNotEmpty(result)) {
                for (TWaiWriOrderHistory tw: result) {
                    Date parse = simpleDateFormat.parse(tw.getCreateTime());
                    tw.setCreateTime(parse.getTime()+"");
                }
            }

            response.setData(result);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);

            return response;
        }catch (Exception e ) {
            System.out.println(e.getMessage());
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"网络异常,请稍后再试!!");
        }finally {

        }

    }

    public Response isAgent(Integer userId) {
        Response res = new Response();
        res.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        try {
            Integer agentId = playerMapper.isAgent(userId);
            if (StringUtil.isNotEmpty(agentId)) {
                res.setData("1");
            }else {
                res.setData("0");
            }
        }catch (Exception e ) {
            System.out.println(e.getMessage());
            res.setData("0");
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"网络异常,请稍后再试!!");
        }finally {

        }
        return res;
    }

    public Response sendSMS4bindPhone(Integer userId, String  phone) {

        Response response = new Response();

//        boolean isPhone = IDCardUtil.isChinaPhoneLegal(phone);
        if (phone.length() != 11) {
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setData("请输入正确的手机号码!!");
            return response;
        }

        String code = RandomUtil.getRandomNum(4);
        getRequest2(phone,code);
        msgService.addOne(phone,1,code,0,userId);

        response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        response.setData("发送成功!!");

        return response;

    }

    public static boolean getRequest2(String phone,String code){
        String result =null;
        String url ="http://v.juhe.cn/sms/send";//请求接口地址
        Map params = new HashMap();//请求参数
        params.put("mobile",phone);//接收短信的手机号码
        params.put("tpl_id",ConfigUtil.get("sms.tpl_id"));//短信模板ID，请参考个人中心短信模板设置
        params.put("tpl_value","%23code%23%3d" + code);//变量名和变量值对。如果你的变量名或者变量值中带有#&=中的任意一个特殊符号，请先分别进行urlencode编码后再传递，<a href="http://www.juhe.cn/news/index/id/50" target="_blank">详细说明></a>
        params.put("key",ConfigUtil.get("sms.APPKEY"));//应用APPKEY(应用详细页查询)

        try {

            result = HttpClientUtil.httpPost(url, params);

            JSONObject object = JSONObject.parseObject(result);
            if(object.getInteger("error_code")==0){
                return true;
            }else{
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    public Response bindPhoneBySms(Integer userId, String phone, String code,String password) throws Exception {

        ICache cache = null;
        try {
//            boolean chinaPhoneLegal = IDCardUtil.isChinaPhoneLegal(phone);
            if  (phone.length() != 11) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "请输入正确的手机号码");

            }
            cache = CacheManager.getCache();
            TUser user = new TUser();
            user.setUserid(Long.parseLong(userId+""));
            List<TUser> list = userMapper.select(user);
            if (list.size() <= 0) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "该玩家不存在");
            }
            if (list.get(0).getPhone().length() == 11) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您已经绑定过手机号码了!!");
            }
            ImsMsg imsMsg = msgService.selectByPhone(phone);
            if (StringUtil.isEmpty(imsMsg)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "请先获取验证码!!");
            }
            if (-(Long.parseLong(imsMsg.getAddtime()) - System.currentTimeMillis()) > 180000) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "验证码已经过期,请重新获取!!");
            }
            if (!imsMsg.getContent().equals(code)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "验证码错误,请重新输入!!");
            }

            user = new TUser();
            user.setUserid(Long.parseLong(userId+""));
            user.setPhone(phone);
            user.setAccount(phone);
            user.setPassword(Md5.getMd5ofStr(password));
            if (userMapper.updateSelective(user) > 0) {
                playerCacheController.updatePlayerField(Long.parseLong(userId+""), "phone", phone, cache);
            }
            //绑定送卡
            String bindPhoneSendCard = baseCacheController.queryConfig("bindPhoneSendCard", cache);
            if(StringUtil.isNotEmpty(bindPhoneSendCard)) {
//                userMapper.increaseRoomCard(userId,Integer.parseInt(bindPhoneSendCard));
                baseCacheController.updateRoomCard(Long.parseLong(userId+""),Integer.parseInt(bindPhoneSendCard));
                userMapper.insertTplayerShareGiftRecord(Long.parseLong(userId+""),bindPhoneSendCard,"0",Constants.bindPhone);
            }
            Response response = new Response();
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData(bindPhoneSendCard);
            return response;
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }

    }

    public Response updatePassBySms(String phone, String code,String password) throws Exception {

        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            TUser user = new TUser();
            user.setAccount(phone);
            List<TUser> list = userMapper.select(user);
            if (list.size() <= 0) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "该玩家不存在");
            }
            if (list.get(0).getPhone().length() != 11) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "请先绑定手机号码!!");
            }
            ImsMsg imsMsg = msgService.selectByPhone(list.get(0).getPhone());
            if (StringUtil.isEmpty(imsMsg)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "请先获取验证码!!");
            }
            if (-(Long.parseLong(imsMsg.getAddtime()) - System.currentTimeMillis()) > 180000) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "验证码已经过期,请重新获取!!");
            }
            if (!imsMsg.getContent().equals(code)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "验证码错误,请重新输入!!");
            }

            user = new TUser();
            user.setAccount(phone);
            user.setPassword(Md5.getMd5ofStr(password));
            if (userMapper.updateSelective(user) > 0) {

            }

            Response response = new Response();
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            return response;
        }catch (Exception e ) {
            throw e;
        }finally {
            if (cache != null ) {
                CacheManager.releaseCache(cache);
            }
        }

    }

    public Integer test(Integer xyUid, Integer groupId) {

        int l = xyUid % 10;

        List<TFreeGameResult> list = freeGameResultMapper.queryActivitiesResult(l, xyUid, groupId, null, 0, null, null);
        System.out.println("size-->" + list.size());

        Integer chips = 0;
        for (TFreeGameResult result: list) {
            String content = result.getContent();
            JSONObject contentJson = JSONObject.parseObject(content);
            JSONArray userinfos = contentJson.getJSONArray("userinfos");
            for (int i = 0 ; i < userinfos.size(); i++ ) {
                JSONObject infoJons = userinfos.getJSONObject(i);
                Integer uid = infoJons.getInteger("uid");
                Integer score = infoJons.getInteger("score");
                if (!StringUtil.isEmpty(uid) && !StringUtil.isEmpty(score) ) {
                    if ((xyUid + "").equals( uid + "")) {
                        chips += score;
                        continue;
                    }
                }
            }
        }

        System.out.println("chips--->" + chips);
        return 0;
    }

    public String uploadPhoto(MultipartFile photo) {

        if (photo.getSize() > 512500) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "图片大小不可以超过500K...");
        }

        if (photo.getSize() <= 0) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "图片异常...");
        }

        String userPhotoUrl = null;
        try {
            InputStream photoInputStream = photo.getInputStream();
            Integer available = photoInputStream.available();
            Long size = available.longValue();

            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
            String fileName = sdf.format(new Date())+"-" + RandomUtil.getRandom(8);

            OSSUtil.uploadObject2OSS(photoInputStream,fileName, size, ConfigUtil.get("oss.bucketName.replay"), "user_photo/");

            userPhotoUrl = ConfigUtil.get("oss.domain") + "user_photo/" +fileName+".png";


        }catch (Exception e ) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "上传图片异常1...");
        }

        if (!StringUtil.isEmpty(userPhotoUrl) ) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "上传图片异常2...");
        }

        return userPhotoUrl;
    }
}

