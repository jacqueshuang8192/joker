package com.hbi.service.playerGroup;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.core.rfUtil.Md5;
import com.core.util.DateUtils;
import com.core.util.RedisUtil;
import com.core.util.RedisUtil3;
import com.core.util.StringUtil;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.cache.controller.GroupPlayerCacheController;
import com.hbi.cache.controller.PlayerCacheController;
import com.hbi.constants.ClubConstants;
import com.hbi.constants.Constants;
import com.hbi.controller.playerGroup.ClubConstant;
import com.hbi.enums.PlayerTypeEnum;
import com.hbi.mapper.*;
import com.hbi.model.*;
import com.hbi.service.roomcard.RoomCardService;
import com.hbi.service.schedule.ScheduleConstants;
import com.hbi.utils.GameServerUtil;
import com.hbi.utils.InfServerException;
import com.hbi.vo.request.common.MapVo;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.*;

/**
 * Created by muzi on 2017/12/7.
 */
@Service
public class TGroupPlayerService {
    private static Logger log = Logger.getLogger(TGroupPlayerService.class);

    private static final String Lock_Add_A = "Lock_Add_A";
    private static final String Lock_Add_B = "Lock_Add_B";
    private static final String Lock_Cub_A = "Lock_Add_A";
    private static final String Lock_Cub_B = "Lock_Add_B";

    private static final String CLUB_NEED_GAME_LIST_ = "CLUB_NEED_GAME_LIST_";

    @Autowired
    private TGroupPlayerMapper groupPlayerMapper;
    @Autowired
    private TPlayerGroupMapper playerGroupMapper;
    @Autowired
    private GroupPlayerCacheController groupPlayerCacheController;
    @Autowired
    private TMsgPlayerGroupMapper msgPlayerGroupMapper;
    @Autowired
    private TUserMapper userMapper;
    @Autowired
    private TGroupZhanjiMapper groupZhanjiMapper;
    @Autowired
    private RoomCardService roomCardService;
    @Autowired
    private BaseCacheController baseCacheController;
    @Autowired
    private TClucoinsHandleHistoryMapper clucoinsHandleHistoryMapper;
    @Autowired
    private TCluRepositoryHandleHistoryService cluRepositoryHandleHistoryService;
    @Autowired
    private PlayerCacheController playerCacheController;
    @Autowired
    private TPointChangeRecordService pointChangeRecordService;
    @Autowired
    private TGroupXiaoHaoHistoryService xiaoHaoHistoryService;
    @Autowired
    private TPlayerGroupService playerGroupService;
    @Autowired
    private TGroupNoticeService groupNoticeService;

    public JSONObject insertGroupPlayer(Integer playerId, String groupName, String configArrays) throws Exception {
        ICache cache = null;


        try {
            cache = CacheManager.getCache();

            String leasthCard2CreateClu = baseCacheController.queryConfig("leasthCard2CreateClu", cache);
            if (!StringUtil.isEmpty(leasthCard2CreateClu) && Integer.parseInt(leasthCard2CreateClu) > 0) {
                Integer integer = roomCardService.queryRoomCardCount(Long.parseLong(String.valueOf (playerId)));
                if (Integer.parseInt(leasthCard2CreateClu) > integer) {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "须有" + leasthCard2CreateClu + "张房卡才能创建联盟，请充值房卡");
                }
            }

            TUser tUser = userMapper.findById(Long.parseLong(String.valueOf (playerId)));
            if (StringUtil.isEmpty(tUser) || tUser.getClubLimit() != 1) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您未获得创建联盟权限!");
            }


            String inviteCode = groupPlayerCacheController.getClubInviteCode(cache);
            configArrays = groupPlayerCacheController.getDefaultClubConfig();

            //创建群 群的默认配置
            //String config = ConfigUtil.get("clu_config");
            String config = configArrays;

            TGroupPlayer tgp = new TGroupPlayer();
            tgp.setOwerId(playerId);
            tgp.setGroupName(groupName);
            tgp.setConfig(config);
            groupPlayerMapper.insertGroup(tgp);
            Integer groupId = tgp.getGroupId();
            //将群,存入redis中,方便以后操作
            groupPlayerCacheController.insertGroupByOwerId(playerId, groupId, config, cache, groupName);

            //新增
            //玩家不存在就新增 玩家->群 ,存在就追加
            //TPlayerGroup tPlayerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(playerId,groupId);
            //if (tPlayerGroup == null) {
            TPlayerGroup tpg1 = new TPlayerGroup();
            tpg1.setPlayerId(playerId);
            tpg1.setGroupId(groupId);
            tpg1.setUpPlayerId(playerId);
            tpg1.setCreateTime(new Date());
            tpg1.setPlayerType(PlayerTypeEnum.MASTER);
            tpg1.setInviteCode(inviteCode);
            tpg1.setBonus(100d);
            tpg1.setIsRobot(0);
            playerGroupMapper.add(tpg1);

            cache.hset(ClubConstants.Club2InviteCode + playerId, String.valueOf (groupId), inviteCode);

            //将这个关系存入redis中
            groupPlayerCacheController.insertPlayerGroup(playerId, groupId, groupName, config, cache);

            //初始化俱乐部积分
            groupPlayerCacheController.updateClubPoint(groupId, playerId, 9999);

            //通知大厅
            GameServerUtil.notice2HallAboutClu(Constants.CLU_CREATE, groupId, playerId);

            JSONObject result = new JSONObject();
            result.put("groupName", groupName);
            result.put("groupId", groupId);
            result.put("owerId", playerId);
            result.put("clubCode", inviteCode);
            result.put("roleType", PlayerTypeEnum.MASTER);
            result.put("owerUrl", tUser.getSmallIcon());

            return result;


        } catch (Exception e) {
            log.error("创建联盟异常:" + e.getMessage());
            throw e;

        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void transferClubOwner(Integer ownerId, Integer groupId, Integer assignor) throws Exception {
        ICache cache = null;

        try {

            cache = CacheManager.getCache();
            TPlayerGroup ownerTPG = playerGroupMapper.selectByPlayerIdAndGroupId(ownerId, groupId);
            if (StringUtil.isEmpty(ownerTPG) || ownerTPG.getPlayerType() != PlayerTypeEnum.MASTER) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您无权操作这个联盟...");
            }

            TPlayerGroup assignorTPG = playerGroupMapper.selectByPlayerIdAndGroupId(assignor, groupId);
            if (StringUtil.isEmpty(assignorTPG)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "被转让人不存在...");
            }
            TUser sssignorInfo = userMapper.findById(Long.parseLong(String.valueOf (assignor)));
            if (StringUtil.isEmpty(sssignorInfo)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "被转让人不存在...");
            }

            groupPlayerMapper.updateClubOwnerId(groupId, assignor);

            //修改自身的角色
            playerGroupMapper.updateRepositoryPoint(groupId, ownerId, 0);
            playerGroupMapper.setPlayerType(groupId, ownerId, PlayerTypeEnum.MEMBER, 0d, null);
            playerGroupMapper.setPlayerType(groupId, assignor, PlayerTypeEnum.MASTER, ownerTPG.getBonus(), ownerTPG.getInviteCode());

            //修改旧盟主的绑定全部都到新盟主身上
            List<TPlayerGroup> ownerSonList = playerGroupMapper.selectMySonList(groupId, ownerId, null, null, null);
            List<TPlayerGroup> assignorSonList = playerGroupMapper.selectMySonList(groupId, assignor, null, null, null);
            for (TPlayerGroup ownerSon : ownerSonList) {
                //修改旧盟主的绑定关系
                cache.hdel(ClubConstants.Club2InviteCode + ownerSon.getPlayerId(), groupId.toString());
                cache.hdel(Constants.Group_Uid_Shangji_Id + groupId, String.valueOf (ownerSon.getPlayerId ()));
            }
            for (TPlayerGroup assignorSon : assignorSonList) {
                //将新盟主的旧关系中的邀请码更新
                cache.hdel(ClubConstants.Club2InviteCode + assignorSon.getPlayerId(), groupId.toString());
            }
            playerGroupMapper.updateUpPlayerId(groupId, ownerId, assignor);
            playerGroupMapper.updateMyUpPlayerId(groupId, assignor, assignor);
            playerGroupMapper.updateMyUpPlayerId(groupId, ownerId, assignor);

            cache.hdel(ClubConstants.Club2InviteCode + ownerId, groupId.toString());
            cache.hdel(ClubConstants.Club2InviteCode + assignor, groupId.toString());
            cache.hdel(Constants.Group_Uid_Shangji_Id + groupId, String.valueOf (assignor));
            cache.hdel(Constants.Group_Uid_Shangji_Id + groupId, String.valueOf (ownerId));
            cache.hdel(Constants.Group_Hehuoren_Commission + groupId, String.valueOf (assignor));
            cache.hdel(Constants.Group_Hehuoren_Commission + groupId, String.valueOf (ownerId));
            groupPlayerCacheController.removeRoleType(cache, groupId, ownerId);
            groupPlayerCacheController.removeRoleType(cache, groupId, assignor);

            String grouInfoStr = cache.hget(Constants.GROUP_PLAYER, String.valueOf (groupId));
            JSONObject groupInfoJson = JSONObject.parseObject(grouInfoStr);
            if (!StringUtil.isEmpty(groupInfoJson)) {
                groupInfoJson.put("owerId", assignor);
                cache.hset(Constants.GROUP_PLAYER, String.valueOf (groupId), groupInfoJson.toJSONString());

                JSONArray players = groupInfoJson.getJSONArray("players");
                for (int i = 0; i < players.size(); i++) {
                    JSONObject player = players.getJSONObject(i);
                    if (!StringUtil.isEmpty(player)) {
                        Integer uid = player.getInteger("userId");
                        String playerInfoStr = cache.hget(Constants.PLAYER_GROUP_ + uid, String.valueOf (groupId));
                        JSONObject playerInfoJson = JSONObject.parseObject(playerInfoStr);
                        if (!StringUtil.isEmpty(playerInfoJson)) {
                            playerInfoJson.put("owerUrl", sssignorInfo.getSmallIcon());
                            playerInfoJson.put("owerId", assignor);
                            cache.hset(Constants.PLAYER_GROUP_ + uid, String.valueOf (groupId), playerInfoJson.toJSONString());
                        }
                    }
                }
            }

            //通知游戏服,固定格式
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("groupId", groupId);
            jsonObject.put("type", "transferClubOwner");

            //通知游戏服
            GameServerUtil.notice2HallPublice(Long.parseLong(String.valueOf (assignor)), jsonObject);

        } catch (Exception e) {
            log.error("转让群主:" + e.getMessage());
            throw e;

        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }


    public String applyForJoinPlayerGroup(Integer playerId, Integer groupId, Integer playerIdInvite, String inviteCode) throws Exception {
        ICache cache = null;

        try {
            //申请加入群
            cache = CacheManager.getCache();

//            Boolean isSet = cache.sismember(ClubConstants.Club_Invite_Code_Set, inviteCode);
            TPlayerGroup invitePlayer = groupPlayerMapper.selectByInviteCode(inviteCode);

//            TPlayerGroup invitePlayer = groupPlayerMapper.selectByInviteCode(inviteCode);
            if (StringUtil.isEmpty(invitePlayer)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "无效的邀请码");
            }
            groupId = invitePlayer.getGroupId();

            //String group = cache.hget(Constants.GROUP_PLAYER, groupId.toString());
            TGroupPlayer groupPlayer = groupPlayerMapper.findById(groupId);
            if (groupPlayer == null) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "抱歉,这个群不存在!!");
            }
            TPlayerGroup playerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            if (playerGroup != null) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您已经在这个群里面了!!");
            }
            JSONObject clubConfig = JSONObject.parseObject(groupPlayer.getConfig());
            String isAgree = clubConfig.getString(ClubConstant.is_agree);
            if (StringUtil.isEmpty(isAgree) || "0".equals(isAgree)) {
                //直接加入
                addOne2Club(cache, playerId, invitePlayer, groupPlayer, false);
            } else {
                Integer count = msgPlayerGroupMapper.selectMsg(playerId, groupId, groupPlayer.getOwerId(), 0);
                if (count <= 0) {
                    TMsgPlayerGroup msg = new TMsgPlayerGroup();
                    msg.setPlayerId(playerId);
                    msg.setGroupId(groupId);
                    msg.setOwerId(groupPlayer.getOwerId());
                    msg.setStatus(Constants.HAS_NOT_READ);
                    msg.setInviterUid(invitePlayer.getPlayerId());
                    msgPlayerGroupMapper.insert(msg);
                }

                //通知游戏服,固定格式
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("groupId", groupId);
                jsonObject.put("type", "apply4JoinClub");
                JSONObject joinPlayer = groupPlayerCacheController.getMessageForNameAndHeadUrlAndUid(playerId, cache);
                JSONObject upPlayer = groupPlayerCacheController.getMessageForNameAndHeadUrlAndUid(invitePlayer.getPlayerId(), cache);
                jsonObject.put("joinPlayer", joinPlayer);
                jsonObject.put("upPlayer", upPlayer);

                //通知游戏服
                GameServerUtil.notice2HallPublice(Long.parseLong(String.valueOf (groupPlayer.getOwerId ())), jsonObject);
            }

            return isAgree;
            //申请直接加入联盟
//            String myInviteCode = groupPlayerCacheController.getClubInviteCode(cache);
//            TPlayerGroup newPlayer = new TPlayerGroup();
//            newPlayer.setPlayerId(playerId);
//            newPlayer.setGroupId(groupId);
//            newPlayer.setUpPlayerId(invitePlayer.getPlayerId());
//            newPlayer.setCreateTime(new Date());
//            newPlayer.setPlayerType(PlayerTypeEnum.MEMBER);
//            newPlayer.setBonus(0d);
////            newPlayer.setInviteCode(myInviteCode);
//            playerGroupMapper.add(newPlayer);
//            cache.hset(ClubConstants.Club2InviteCode + playerId,String.valueOf (groupId),myInviteCode);
//
//            //玩家(redis) 添加 群
//            groupPlayerCacheController.insertPlayerGroup(playerId,groupId,groupPlayer.getGroupName(),groupPlayer.getConfig(),cache);
//
//            //往群->玩家追加数据(redis)
//            groupPlayerCacheController.addGroupPlayer(playerId,groupId,cache);
//
//            //通知玩家已经入群
//            //通知游戏服,固定格式
//            JSONObject jo = new JSONObject();
//            jo.put("groupId",groupId);
//            jo.put("type","sure2group");
//            JSONObject data = groupPlayerCacheController.getMessageForNameAndHeadUrlAndUid(groupPlayer.getOwerId(),cache);
//            data.put("groupId",groupId);
//            jo.put("data",data);
//            GameServerUtil.notice2HallPublice(Long.parseLong(String.valueOf (playerId)),jo);
//
//            GameServerUtil.notice2HallAboutClu(Constants.CLU_MEMBER_JOIN,groupId,playerId);

//            Integer owerId = groupPlayer.getOwerId();
//            //留下记录,如果玩家不在线则调用接口通知
//            Integer count = msgPlayerGroupMapper.selectMsg(playerId,groupId,owerId,0);
//            if (count <= 0) {
//                TMsgPlayerGroup msg = new TMsgPlayerGroup();
//                msg.setPlayerId(playerId);
//                msg.setGroupId(groupId);
//                msg.setOwerId(owerId);
//                msg.setStatus(Constants.HAS_NOT_READ);
//                msg.setInviteCode(inviteCode);
//                msgPlayerGroupMapper.insert(msg);
//            }
//
//
//            //通知游戏服,固定格式
//            JSONObject jsonObject = new JSONObject();
//            jsonObject.put("groupId",groupId);
//            jsonObject.put("invitePlayer",playerIdInvite);
//            jsonObject.put("type","joinPlayerGroup");
//            JSONObject data = groupPlayerCacheController.getMessageForNameAndHeadUrlAndUid(playerId,cache);
//            data.put("groupId",groupId);
//            jsonObject.put("data",data);
//
//            //通知游戏服
//            GameServerUtil.notice2HallPublice(Long.parseLong(owerId.toString()),jsonObject);

        } catch (Exception e) {
            log.error("申请加入一个联盟:" + e.getMessage());
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    private void addOne2Club(ICache cache, Integer playerId, TPlayerGroup invitePlayer, TGroupPlayer tpg, boolean sendMsg) throws IOException {
        //申请直接加入联盟
//            String myInviteCode = groupPlayerCacheController.getClubInviteCode(cache);
        TPlayerGroup newPlayer = new TPlayerGroup();
        newPlayer.setPlayerId(playerId);
        newPlayer.setGroupId(invitePlayer.getGroupId());
        newPlayer.setUpPlayerId(invitePlayer.getPlayerId());
        newPlayer.setCreateTime(new Date());
        newPlayer.setPlayerType(PlayerTypeEnum.MEMBER);
        newPlayer.setBonus(0d);
        newPlayer.setIsRobot(0);
//            newPlayer.setInviteCode(myInviteCode);
        playerGroupMapper.add(newPlayer);
//            cache.hset(ClubConstants.Club2InviteCode + playerId,String.valueOf (groupId),myInviteCode);

        //玩家(redis) 添加 群
        groupPlayerCacheController.insertPlayerGroup(playerId, invitePlayer.getGroupId(), tpg.getGroupName(), tpg.getConfig(), cache);

        //往群->玩家追加数据(redis)
        groupPlayerCacheController.addGroupPlayer(playerId, invitePlayer.getGroupId(), cache);

        //初始化俱乐部积分
        groupPlayerCacheController.updateClubPoint(invitePlayer.getGroupId(), playerId, 9999);

        //通知玩家已经入群
        //通知游戏服,固定格式
        if (sendMsg) {
            JSONObject jo = new JSONObject();
            jo.put("groupId", invitePlayer.getGroupId());
            jo.put("type", "sure2group");
            JSONObject data = groupPlayerCacheController.getMessageForNameAndHeadUrlAndUid(tpg.getOwerId(), cache);
            data.put("groupId", invitePlayer.getGroupId());
            jo.put("data", data);
            GameServerUtil.notice2HallPublice(Long.parseLong(String.valueOf (playerId)), jo);
        }

        GameServerUtil.notice2HallAboutClu(Constants.CLU_MEMBER_JOIN, invitePlayer.getGroupId(), playerId);
    }

    public void inviteForJoinPlayerGroup(Integer playerId1, Integer playerId2, Integer groupId, Integer isTest) throws Exception {
        ICache cache = null;

        try {
            //申请加入群
            cache = CacheManager.getCache();

            TUser tUser = userMapper.findById(Long.parseLong(String.valueOf (playerId2)));
            if (StringUtil.isEmpty(tUser)) {
                throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR, "该玩家不存在！！");
            }

            TGroupPlayer groupPlayer = groupPlayerMapper.findById(groupId);
            if (StringUtil.isEmpty(groupPlayer)) {
                throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR, "联盟数据异常！！");
            }

            TPlayerGroup newPlayer = playerGroupMapper.selectByPlayerIdAndGroupId(playerId2, groupId);
            if (newPlayer != null) {
                throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR, "此玩家已经在这个群里面了!!");
            }
            TPlayerGroup invitePlayer = playerGroupMapper.selectByPlayerIdAndGroupId(playerId1, groupId);
            if (StringUtil.isEmpty(invitePlayer)) {
                throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR, "玩家数据异常!!");
            }
//            String inviteCode = groupPlayerCacheController.getClubInviteCode(cache);

            newPlayer = new TPlayerGroup();
            newPlayer.setPlayerId(playerId2);
            newPlayer.setGroupId(groupId);

            int upPlayerId = groupPlayer.getOwerId();
            if (invitePlayer.getPlayerType () == null ? PlayerTypeEnum.MEMBER != null : ! invitePlayer.getPlayerType ().equals (PlayerTypeEnum.MEMBER)) {
                upPlayerId = playerId1;
            } else {

                TPlayerGroup upPG = playerGroupMapper.selectByPlayerIdAndGroupId(invitePlayer.getUpPlayerId(), groupId);
                if (!StringUtil.isEmpty(upPG) && (upPG.getPlayerType () == null ? PlayerTypeEnum.MEMBER != null : ! upPG.getPlayerType ().equals (PlayerTypeEnum.MEMBER))) {
                    upPlayerId = upPG.getPlayerId();
                }
            }
            newPlayer.setUpPlayerId(upPlayerId);
            newPlayer.setCreateTime(new Date());
            newPlayer.setPlayerType(PlayerTypeEnum.MEMBER);
            newPlayer.setBonus(0d);
            if (!StringUtil.isEmpty(isTest) && isTest > 0) {
                newPlayer.setIsRobot(1);
            } else {
                newPlayer.setIsRobot(0);
            }

//            newPlayer.setInviteCode(inviteCode);
            playerGroupMapper.add(newPlayer);
//            cache.hset(ClubConstants.Club2InviteCode + playerId2,String.valueOf (groupId),inviteCode);

            //玩家(redis) 添加 群
//            JSONObject groupInfo = groupPlayerCacheController.getGroupInfoByOwerId(owerId,groupId,cache);
            if (cache != null) {
                groupPlayerCacheController.insertPlayerGroup(playerId2, groupId, groupPlayer.getGroupName(), groupPlayer.getConfig(), cache);
            }

            //往群->玩家追加数据(redis)
            if (cache != null) {
                groupPlayerCacheController.addGroupPlayer(playerId2, groupId, cache);
            }

            //初始化俱乐部积分
            groupPlayerCacheController.updateClubPoint(groupId, playerId2, 9999);

            //通知玩家已经入群
            //通知游戏服,固定格式
            JSONObject jo = new JSONObject();
            jo.put("groupId", groupId);
            jo.put("type", "sure2group");
            JSONObject data = groupPlayerCacheController.getMessageForNameAndHeadUrlAndUid(groupPlayer.getOwerId(), cache);
            data.put("groupId", groupId);
            jo.put("data", data);
            GameServerUtil.notice2HallPublice(Long.parseLong(String.valueOf (playerId2)), jo);

            GameServerUtil.notice2HallAboutClu(Constants.CLU_MEMBER_JOIN, groupId, playerId2);

//            Integer owerId = groupPlayer.getOwerId();
//            Integer is_invitation = JSONObject.parseObject(groupPlayer.getConfig()).getInteger("is_invitation");
//            if  (is_invitation == 0 && !owerId.equals(playerId1) ) {
//                throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR,"部长不允许成员邀请其他玩家,请联系部长申请!!");
//            }
//
//            TPlayerGroup playerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(playerId2, groupId);
//            if (playerGroup != null) {
//                throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR,"此玩家已经在这个群里面了!!");
//            }
//            //留下记录,如果玩家不在线则调用接口通知
//
//            Integer count = msgPlayerGroupMapper.selectMsg(playerId2,groupId,playerId1,Constants.INVITE_PLAYER);
//            if (count <= 0) {
//                TMsgPlayerGroup msg = new TMsgPlayerGroup();
//                msg.setPlayerId(playerId1);
//                msg.setGroupId(groupId);
//                msg.setOwerId(playerId2);
//                msg.setStatus(Constants.INVITE_PLAYER);
//                msgPlayerGroupMapper.insert(msg);
//            }
//
//
//            //通知游戏服,固定格式
//            JSONObject jsonObject = new JSONObject();
//            jsonObject.put("groupId",groupId);
//            jsonObject.put("type","invitePlayerGroup");
//            JSONObject data = groupPlayerCacheController.getMessageForNameAndHeadUrlAndUid(playerId2,cache);
//            data.put("groupId",groupId);
//            jsonObject.put("data",data);
//
//            //通知游戏服
//            GameServerUtil.notice2HallPublice(Long.parseLong(String.valueOf (playerId2)),jsonObject);

        } catch (Exception e) {
            log.error("邀请加入一个联盟:" + e.getMessage());
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public Map<String, String> selectPlayerGroup(Integer playerId) {
        ICache cache = null;

        try {
            cache = CacheManager.getCache();

            Map<String, String> result = cache.hgetAll(Constants.PLAYER_GROUP_ + playerId);
            if (org.apache.commons.collections.MapUtils.isEmpty(result)) {
                List<TPlayerGroup> lists = playerGroupMapper.selectByPlayerId(playerId);
//              循环插入联盟和玩家
                if (!StringUtil.isEmpty(result)) {
                    System.out.println(lists.size() + "......");
                    for (TPlayerGroup playerGroup : lists) {
                        String hget = cache.hget(Constants.PLAYER_GROUP_ + playerGroup.getPlayerId(), String.valueOf (playerGroup.getGroupId ()));
                        System.out.println(hget);
                        if (StringUtil.isEmpty(hget)) {
//                        如果为空,表示没有,则往redis中存
                            JSONObject groupInfoByGroupId = groupPlayerCacheController.getGroupInfoByGroupId(cache, playerGroup.getGroupId());
                            JSONObject playerinfo = new JSONObject();
                            playerinfo.put("config", groupInfoByGroupId.getString("config"));
                            playerinfo.put("groupName", groupInfoByGroupId.getString("groupName"));
                            playerinfo.put("owerId", groupInfoByGroupId.getInteger("owerId"));
                            playerinfo.put("playerCount", groupInfoByGroupId.getInteger("playerCount"));
                            TUser tUser = userMapper.findById((long) groupInfoByGroupId.getInteger("owerId"));
                            if (StringUtil.isNotEmpty(tUser)) {
                                playerinfo.put("owerUrl", tUser.getSmallIcon());
                            }
                            System.out.println(playerGroup.getPlayerId());
                            cache.hset(Constants.PLAYER_GROUP_ + playerGroup.getPlayerId(), String.valueOf (playerGroup.getGroupId ()), playerinfo.toJSONString());
                        }
                    }
                }
                result = cache.hgetAll(Constants.PLAYER_GROUP_ + playerId);

                GameServerUtil.notice2HallAboutClu(Constants.CLU_REFLESH, 0, 0);

            }

            //获取各个渠道的人数
            if (!StringUtil.isEmpty(result)) {
                for (String key : result.keySet()) {
                    JSONObject jsonObject = JSONObject.parseObject(result.get(key));
                    String hget = cache.hget(Constants.GROUP_PLAYER, key);
                    if (StringUtil.isEmpty(hget)) {
                        hget = initHGetGroupPlayer(cache, Integer.valueOf(key), "", null, null, null);
                    }
                    Integer playerCount = JSONObject.parseObject(hget).getInteger("playerCount");
                    if (StringUtil.isEmpty(playerCount)) {
                        playerCount = 0;
                    }
                    jsonObject.put("playerCount", playerCount);
                    jsonObject.put("jifenCount", groupPlayerCacheController.queryClubPoint(Integer.parseInt(key), Integer.parseInt(String.valueOf (playerId)), null));
                    jsonObject.put("clubCode", groupPlayerCacheController.queryClubCode(cache, Integer.parseInt(key), playerId));
                    jsonObject.put("roleType", groupPlayerCacheController.queryRoleType(cache, Integer.parseInt(key), playerId));
                    jsonObject.put("isManager", groupPlayerCacheController.isManager(cache, Integer.parseInt(key), playerId) ? 1 : 0);
                    result.put(key, jsonObject.toJSONString());
                }
            }

            return result;
        } catch (Exception e) {
            log.error("获取群列表:" + e.getMessage());
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "处理异常,请和管理员联系!!");
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public Object selectGroupPlayerBydayingjia(Integer groupId, Integer playerIdP, String startTime, String endTime, Integer currentPage, Integer pageSize, Integer searchUid) throws Exception {
        ICache cache = null;

        try {
            cache = CacheManager.getCache();

            Integer upPlayerId = null;
            Integer playerType = playerGroupMapper.getPlayTypeByGroupIdAndPlayerId(groupId, playerIdP);

            if (cache != null && groupPlayerCacheController.isManager (cache, groupId, playerIdP)) {
                //如果是管理员,则查出所有的玩家
                playerType = PlayerTypeEnum.MANAGER;
            }

            List<TPlayerGroup> list = new ArrayList<TPlayerGroup>();
            if (playerType == null ? PlayerTypeEnum.MEMBER == null : playerType.equals (PlayerTypeEnum.MEMBER)) {
                list.add(playerGroupMapper.selectByPlayerIdAndGroupId(playerIdP, groupId));
            } else {
                if (playerType == null ? PlayerTypeEnum.PARTNER == null : playerType.equals (PlayerTypeEnum.PARTNER)) {
                    upPlayerId = playerIdP;
                }
                TPlayerGroup ttt = playerGroupMapper.selectByPlayerIdAndGroupId(playerIdP, groupId);
                if (playerType == null ? PlayerTypeEnum.MASTER != null : ! playerType.equals (PlayerTypeEnum.MASTER)) {
                    list.add(ttt);
                }
                List<TPlayerGroup> sonList = playerGroupMapper.selectByGroupId(groupId, startTime, endTime, null, upPlayerId);
                for (TPlayerGroup tpg : sonList) {
                    if (!ttt.getPlayerId().equals(tpg.getPlayerId())) {
                        list.add(tpg);
                    }
                }
            }

            TGroupPlayer tgp = null;
            //处理获取的数据,处理往前端功提供的格式
            if (list.size() > 0) {
                tgp = groupPlayerMapper.findById(groupId);
                //    if (tgp != null) {
                //        JSONObject jsonObject = new JSONObject();
                //        jsonObject.put("owerId",tgp.getOwerId());
                //        cache.hset(Constants.GROUP_PLAYER,groupId.toString(),jsonObject.toJSONString());
                //    }
            }
            JSONArray resut = new JSONArray();

            //如果搜索到人则直接清空数据
            if (!StringUtil.isEmpty(searchUid)) {
                TPlayerGroup seatchTPG = null;
                for (TPlayerGroup tpg : list) {
                    if ((String.valueOf (searchUid)).equals(String.valueOf (tpg.getPlayerId ()))) {
                        seatchTPG = tpg;
                        break;
                    }
                }
                list.clear();
                if (!StringUtil.isEmpty(seatchTPG)) {
                    list.add(seatchTPG);
                }
            }

            Integer startIndex = 0;
            if (!StringUtil.isEmpty(currentPage)) {
                startIndex = (currentPage - 1) * pageSize;
            }
            int i = 0;
            for (TPlayerGroup tpg : list) {

                if (tgp != null) {

                    if (!StringUtil.isEmpty(currentPage)) {
                        if (startIndex <= i) {
                            Integer playerId = tpg.getPlayerId();
                            JSONObject jsonObject = new JSONObject();
                            String userId = cache.hget(Constants.PLAYER_ + playerId, "userId");
                            if (StringUtil.isEmpty(userId)) {
                                playerCacheController.queryPlayerDetail(Long.parseLong(String.valueOf (playerId)), cache, false, false);
                            }
                            jsonObject.put("userId", cache.hget(Constants.PLAYER_ + playerId, "userId"));
                            jsonObject.put("nickName", cache.hget(Constants.PLAYER_ + playerId, "nickName"));
                            jsonObject.put("photoUrl", cache.hget(Constants.PLAYER_ + playerId, "photoUrl"));

                            jsonObject.put("changciCount", tpg.getChangciCount());
//                            jsonObject.put("pointCount",tpg.getPointCount());
                            jsonObject.put("pointCount", groupPlayerCacheController.queryClubPoint(groupId, playerId, tpg.getPointCount()));
                            jsonObject.put("useClubStatus", groupPlayerCacheController.queryUserClubStatus(groupId, playerId));
                            jsonObject.put("isManager", groupPlayerCacheController.isManager(cache, groupId, playerId) ? 1 : 0);
                            jsonObject.put("roleType", groupPlayerCacheController.queryRoleType(cache, groupId, playerId));
                            jsonObject.put("dayingjiaCount", tpg.getDayingjiaCount());
                            jsonObject.put("dayingjiaPointCount", tpg.getDayingjiaPointCount());
                            jsonObject.put("upUserId", tpg.getUpPlayerId());

                            String upUid = cache.hget(Constants.PLAYER_ + tpg.getUpPlayerId(), "nickName");
                            if (StringUtil.isEmpty(upUid)) {
                                playerCacheController.queryPlayerDetail(Long.parseLong(String.valueOf (playerId)), cache, false, false);
                            }
                            jsonObject.put("upNickName", cache.hget(Constants.PLAYER_ + tpg.getUpPlayerId(), "nickName"));

                            if (playerId.equals(tgp.getOwerId()) ) {
                                jsonObject.put("repositoryPoint", tgp.getProfitClubCount());
                            }else {
                                jsonObject.put("repositoryPoint", tpg.getRepositoryPoint());
                            }
                            resut.add(jsonObject);
                        }
                        i++;
                        if (i >= startIndex + pageSize) {
                            break;
                        }
                    } else {
                        Integer playerId = tpg.getPlayerId();
                        JSONObject jsonObject = new JSONObject();
                        String userId = cache.hget(Constants.PLAYER_ + playerId, "userId");
                        if (StringUtil.isEmpty(userId)) {
                            playerCacheController.queryPlayerDetail(Long.parseLong(String.valueOf (playerId)), cache, false, false);
                        }
                        jsonObject.put("userId", cache.hget(Constants.PLAYER_ + playerId, "userId"));
                        jsonObject.put("nickName", cache.hget(Constants.PLAYER_ + playerId, "nickName"));
                        jsonObject.put("photoUrl", cache.hget(Constants.PLAYER_ + playerId, "photoUrl"));

                        jsonObject.put("changciCount", tpg.getChangciCount());
                        jsonObject.put("pointCount", groupPlayerCacheController.queryClubPoint(groupId, playerId, tpg.getPointCount()));
                        jsonObject.put("useClubStatus", groupPlayerCacheController.queryUserClubStatus(groupId, playerId));
                        jsonObject.put("isManager", groupPlayerCacheController.isManager(cache, groupId, playerId) ? 1 : 0);
                        jsonObject.put("roleType", groupPlayerCacheController.queryRoleType(cache, groupId, playerId));
                        jsonObject.put("dayingjiaCount", tpg.getDayingjiaCount());
                        jsonObject.put("dayingjiaPointCount", tpg.getDayingjiaPointCount());
                        jsonObject.put("upUserId", tpg.getUpPlayerId());

                        String upUid = cache.hget(Constants.PLAYER_ + tpg.getUpPlayerId(), "nickName");
                        if (StringUtil.isEmpty(upUid)) {
                            playerCacheController.queryPlayerDetail(Long.parseLong(String.valueOf (playerId)), cache, false, false);
                        }
                        jsonObject.put("upNickName", cache.hget(Constants.PLAYER_ + tpg.getUpPlayerId(), "nickName"));

                        if (playerId.equals(tgp.getOwerId()) ) {
                            jsonObject.put("repositoryPoint", tgp.getProfitClubCount());
                        }else {
                            jsonObject.put("repositoryPoint", tpg.getRepositoryPoint());
                        }
                        resut.add(jsonObject);
                    }
                }
            }
            if (!StringUtil.isEmpty(currentPage)) {
                JSONObject currResult = new JSONObject();
                currResult.put("list", resut);
                if (!StringUtil.isEmpty(list)) {
                    currResult.put("count", list.size());
                } else {
                    currResult.put("count", 0);
                }
                return currResult;
            }
            return resut;
        } catch (Exception e) {
            log.error("获取群列表:" + e.getMessage());
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public Map<String, Object> selectMemberListBydayingjia(Integer groupId, Integer playerId, Integer pageSize, Integer currentPage) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            RedisUtil3 ru = RedisUtil3.getRu();
            TPlayerGroup tpg = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            if (StringUtil.isEmpty(tpg)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "会员数据异常");
            }
            int startIndex = (currentPage - 1) * pageSize;
            Integer roleType = PlayerTypeEnum.MEMBER;
            if (tpg.getPlayerType() == PlayerTypeEnum.MASTER) {
                playerId = null;
                roleType = null;
            }

            List<TPlayerGroup> list = playerGroupMapper.selectMySonList(groupId, playerId, roleType, startIndex, pageSize);
            Integer listCount = playerGroupMapper.selectMySonListCount(groupId, playerId, roleType, null);

            if (tpg.getPlayerType() == PlayerTypeEnum.PARTNER) {
                if (StringUtil.isEmpty(list)) {
                    list = new ArrayList<TPlayerGroup>();
                }
                list.add(0, tpg);
            }

            for (TPlayerGroup tpgs : list) {
                tpgs.setNickName(baseCacheController.queryUserNickName(cache, tpgs.getPlayerId()));
                tpgs.setPhoto(baseCacheController.queryUserPhoto(cache, tpgs.getPlayerId()));

                String countTeamYesterdayStr = ru.hget(ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_YESTERDAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                String countPlayerYesterdayStr = ru.hget(ScheduleConstants.STT_CLUB_PLAYER_GAME_COUNT_YESTERDAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                String countPlayerTodayStr = ru.hget(ScheduleConstants.STT_CLUB_PLAYER_GAME_COUNT_TODAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                String countTeamTodayStr = ru.hget(ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_TODAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                String pointChangeYesterdayStr = ru.hget(ScheduleConstants.STT_CLUB_PLAYER_POINT_CHANGE_YESTERDAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                String pointChangeTodayStr = ru.hget(ScheduleConstants.STT_CLUB_PLAYER_POINT_CHANGE_TODAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                String contriYesterdayStr = ru.hget(ScheduleConstants.STT_CLUB_PLAYER_CONTRI_YESTERDAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                String contriTodayStr = ru.hget(ScheduleConstants.STT_CLUB_PLAYER_CONTRI_TODAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));

                Integer countTeamYesterday = countTeamYesterdayStr == null ? 0 : Integer.parseInt(countTeamYesterdayStr);
                Integer countPlayerYesterday = countPlayerYesterdayStr == null ? 0 : Integer.parseInt(countPlayerYesterdayStr);
                Integer pointChangeYesterday = pointChangeYesterdayStr == null ? 0 : Integer.parseInt(pointChangeYesterdayStr);
                Integer pointChangeToday = pointChangeTodayStr == null ? 0 : Integer.parseInt(pointChangeTodayStr);
                Integer contriYesterday = contriYesterdayStr == null ? 0 : Integer.parseInt(contriYesterdayStr);
                Integer contriToday = contriTodayStr == null ? 0 : Integer.parseInt(contriTodayStr);
                Integer countPlayerToday = countPlayerTodayStr == null ? 0 : Integer.parseInt(countPlayerTodayStr);
                Integer countTeamToday = countTeamTodayStr == null ? 0 : Integer.parseInt(countTeamTodayStr);

                tpgs.setTeamPlayCountYesterday(countTeamYesterday);
                tpgs.setPlayCountYesterday(countPlayerYesterday);
                tpgs.setXiaohaoYesterday(pointChangeYesterday);
                tpgs.setXiaohaoToday(pointChangeToday);
                tpgs.setGongxianYesterday(contriYesterday);
                tpgs.setGongxianToday(contriToday);
                tpgs.setPlayCountToday(countPlayerToday);
                tpgs.setTeamPlayCountToday(countTeamToday);

                //如果是合伙人自己,则显示自己给自己的贡献
                if (tpg.getPlayerType() == PlayerTypeEnum.PARTNER && playerId.equals(tpgs.getPlayerId())) {
                    String contriMyselfYesterdayStr = ru.hget(ScheduleConstants.STT_CLUB_MYSELF_CONTRI_YESTERDAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                    String contriMyselfTodayStr = ru.hget(ScheduleConstants.STT_CLUB_MYSELF_CONTRI_TODAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                    Integer contriMyselfYesterday = contriMyselfYesterdayStr == null ? 0 : Integer.parseInt(contriMyselfYesterdayStr);
                    Integer contriMyselfToday = contriMyselfTodayStr == null ? 0 : Integer.parseInt(contriMyselfTodayStr);
                    tpgs.setGongxianYesterday(contriMyselfYesterday);
                    tpgs.setGongxianToday(contriMyselfToday);
                }

                tpgs.setPointCount(groupPlayerCacheController.queryClubPoint(groupId, tpgs.getPlayerId(), null));
            }

            Map<String, Object> result = new HashMap<String, Object>();
            result.put("list", list);
            result.put("listCount", listCount);

            return result;
        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }
    }

    public Map<String, Object> selectHhrListBydayingjia(Integer groupId, String startTime, String endTime, Integer playerId, Integer pageSize, Integer currentPage, Integer searchId) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            RedisUtil ru = RedisUtil.getRu();
            RedisUtil3 ru3 = RedisUtil3.getRu();
            Map<String, Object> result = new HashMap<String, Object>();
            TPlayerGroup tpg = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            TGroupPlayer tgp = groupPlayerMapper.findById(groupId);

            if (StringUtil.isEmpty(tpg)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "成员数据异常");
            }

            int startIndex = (currentPage - 1) * pageSize;
            List<TPlayerGroup> list = playerGroupMapper.selectMySonListByOne(groupId, playerId, PlayerTypeEnum.PARTNER, startIndex, pageSize, searchId);
            Integer listCount = playerGroupMapper.selectMySonListCount(groupId, playerId, PlayerTypeEnum.PARTNER, searchId);
            List<TPlayerGroup> allList = playerGroupMapper.selctAllList(groupId);
            Map<Integer, Integer> uid2UpIdMap = new HashMap<Integer, Integer>();
            Map<Integer, Integer> uid2RepPointMap = new HashMap<Integer, Integer>();
            for (TPlayerGroup li : allList) {
                uid2UpIdMap.put(li.getPlayerId(), li.getUpPlayerId());
            }
            Map<String, String> usersChipMap = ru.hgetall("GROUP_USER_CHIPS_" + groupId);

            List<TPlayerGroup> repositoryList = playerGroupMapper.selectClubRepositoryPoint(groupId);
            for (TPlayerGroup repTpg : repositoryList) {
                uid2RepPointMap.put(repTpg.getPlayerId(), repTpg.getRepositoryPoint());
            }

            for (TPlayerGroup tpgs : list) {
                tpgs.setNickName(baseCacheController.queryUserNickName(cache, tpgs.getPlayerId()));
                tpgs.setPhoto(baseCacheController.queryUserPhoto(cache, tpgs.getPlayerId()));
                tpgs.setSonPool(groupPlayerCacheController.queryMySonPool(tpgs.getPlayerId(), usersChipMap, uid2UpIdMap, uid2RepPointMap));

                String countTeamYesterdayStr = ru3.hget(ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_YESTERDAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                String countPlayerYesterdayStr = ru3.hget(ScheduleConstants.STT_CLUB_PLAYER_GAME_COUNT_YESTERDAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                String pointChangeYesterdayStr = ru3.hget(ScheduleConstants.STT_CLUB_PLAYER_POINT_CHANGE_YESTERDAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                String pointChangeTodayStr = ru3.hget(ScheduleConstants.STT_CLUB_PLAYER_POINT_CHANGE_TODAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                String contriYesterdayStr = ru3.hget(ScheduleConstants.STT_CLUB_PLAYER_CONTRI_YESTERDAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                String contriTodayStr = ru3.hget(ScheduleConstants.STT_CLUB_PLAYER_CONTRI_TODAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                String countPlayerTodayStr = ru3.hget(ScheduleConstants.STT_CLUB_PLAYER_GAME_COUNT_TODAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));
                String countTeamTodayStr = ru3.hget(ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_TODAY_ + tpgs.getGroupId(), String.valueOf (tpgs.getPlayerId ()));


                Integer countTeamYesterday = countTeamYesterdayStr == null ? 0 : Integer.parseInt(countTeamYesterdayStr);
                Integer countPlayerYesterday = countPlayerYesterdayStr == null ? 0 : Integer.parseInt(countPlayerYesterdayStr);
                Integer pointChangeYesterday = pointChangeYesterdayStr == null ? 0 : Integer.parseInt(pointChangeYesterdayStr);
                Integer pointChangeToday = pointChangeTodayStr == null ? 0 : Integer.parseInt(pointChangeTodayStr);
                Integer contriYesterday = contriYesterdayStr == null ? 0 : Integer.parseInt(contriYesterdayStr);
                Integer contriToday = contriTodayStr == null ? 0 : Integer.parseInt(contriTodayStr);
                Integer countPlayerToday = countPlayerTodayStr == null ? 0 : Integer.parseInt(countPlayerTodayStr);
                Integer countTeamToday = countTeamTodayStr == null ? 0 : Integer.parseInt(countTeamTodayStr);

                tpgs.setTeamPlayCountYesterday(countTeamYesterday);
                tpgs.setPlayCountYesterday(countPlayerYesterday);
                tpgs.setXiaohaoYesterday(pointChangeYesterday);
                tpgs.setXiaohaoToday(pointChangeToday);
                tpgs.setGongxianYesterday(contriYesterday);
                tpgs.setGongxianToday(contriToday);
                tpgs.setPlayCountToday(countPlayerToday);
                tpgs.setTeamPlayCountToday(countTeamToday);

                //合伙人的阀值
                String thresholdValueStr = ru3.hget(ClubConstant.CLUB_PARTNER_THRESHOLD_VALUE_ + groupId, tpgs.getPlayerId()+"");
                Integer thresholdValue = thresholdValueStr == null ? 0 : Integer.parseInt(thresholdValueStr);
                tpgs.setThresholdValue(thresholdValue);
            }

            result.put("list", list);
            result.put("listCount", listCount);
            result.put("sonPlayerCount", tpg.getTeamPlayCountYesterday());

            Integer myAllSonCount = playerGroupMapper.selectMySonListCount(groupId, playerId, null, null);
            result.put("myAllSonCount", myAllSonCount);

            Long mySonAllPoint = groupPlayerCacheController.queryMySonPool(playerId, usersChipMap, uid2UpIdMap, uid2RepPointMap);
            if (playerId.equals(tgp.getOwerId()) ) {
                result.put("mySonAllPoint", tgp.getPointPool() );

                String cardCountTeamTodayStr = ru3.hget(ScheduleConstants.STT_CLUB_CARD_COUNT_TODAY , String.valueOf (groupId));
                String cardCountTeamYesterdayStr = ru3.hget(ScheduleConstants.STT_CLUB_CARD_COUNT_YESTERDAY , String.valueOf (groupId));
                Integer cardCountTeamToday = cardCountTeamTodayStr == null ? 0 : Integer.parseInt(cardCountTeamTodayStr);
                Integer cardCountTeamYesterday = cardCountTeamYesterdayStr == null ? 0 : Integer.parseInt(cardCountTeamYesterdayStr);
                result.put("cardCountTeamToday", cardCountTeamToday );
                result.put("cardCountTeamYesterday", cardCountTeamYesterday );
            }else {
                result.put("mySonAllPoint", mySonAllPoint);
            }

            String countTeamYesterdayStr = ru3.hget(ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_YESTERDAY_ + groupId, String.valueOf (playerId));
            String countTeamTodayStr = ru3.hget(ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_TODAY_ + groupId, String.valueOf (playerId));
            String countTeamBeforeYesterdayStr = ru3.hget(ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_BEFORE_YESTERDAY_ + groupId, String.valueOf (playerId));
            Integer countTeamYesterday = countTeamYesterdayStr == null ? 0 : Integer.parseInt(countTeamYesterdayStr);
            Integer countTeamToday = countTeamTodayStr == null ? 0 : Integer.parseInt(countTeamTodayStr);
            Integer countTeamBeforeYesterday = countTeamBeforeYesterdayStr == null ? 0 : Integer.parseInt(countTeamBeforeYesterdayStr);
            result.put("teamPlayCountYesterday", countTeamYesterday);
            result.put("teamPlayCountToday", countTeamToday);
            result.put("teamPlayCountBeforeYesterday", countTeamBeforeYesterday);
            result.put("myBonus", tpg.getBonus());

            return result;
        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }

//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//
//            List<TPlayerGroup> list = playerGroupMapper.selectByGroupId(groupId, startTime, endTime, PlayerTypeEnum.PARTNER, null);
//            TGroupPlayer tgp = null;
//            //处理获取的数据,处理往前端功提供的格式
//            if (list != null && list.size() > 0 ) {
//                tgp = groupPlayerMapper.findById(groupId);
//                //    if (tgp != null) {
//                //        JSONObject jsonObject = new JSONObject();
//                //        jsonObject.put("owerId",tgp.getOwerId());
//                //        cache.hset(Constants.GROUP_PLAYER,groupId.toString(),jsonObject.toJSONString());
//                //    }
//            }
//            JSONArray resut = new JSONArray();
//            if (!StringUtil.isEmpty(startTime) || !StringUtil.isEmpty(endTime)) {
//                List<TGroupZhanji> zhanjiList = groupZhanjiMapper.selectByTime(groupId,startTime,endTime);
//
//                for (TPlayerGroup tpg : list) {
//                    int playerId = tpg.getPlayerId();
//                    JSONObject jsonObject = new JSONObject();
//                    jsonObject.put("userId",cache.hget(Constants.PLAYER_+playerId,"userId"));
//                    jsonObject.put("nickName",cache.hget(Constants.PLAYER_+playerId,"nickName"));
//                    jsonObject.put("photoUrl",cache.hget(Constants.PLAYER_+playerId,"photoUrl"));
//                    jsonObject.put("bonus", tpg.getBonus());
//                    jsonObject.put("createTime", tpg.getCreateTime());
//
//                    int changciCount = 0;
//                    int pointCount = 0;
//                    int dayingjiaCount = 0;
//                    int dayingjiaPointCount = 0;
//                    for (TGroupZhanji zj : zhanjiList) {
//                        changciCount++;
//                        pointCount += zj.getPlayPointCount();
//                        if (1 == zj.getIsDayingjia()) {
//                            dayingjiaCount++;
//                            dayingjiaPointCount += zj.getPlayPointCount();
//                        }
//                    }
//
//                    jsonObject.put("changciCount",changciCount);
//                    jsonObject.put("pointCount",pointCount);
//                    jsonObject.put("dayingjiaCount",dayingjiaCount);
//                    jsonObject.put("dayingjiaPointCount",dayingjiaPointCount);
//                    resut.add(jsonObject);
//                }
//                return resut;
//            }
//
//            for (TPlayerGroup tpg : list) {
//                if (tgp != null) {
//                    int playerId = tpg.getPlayerId();
//                    JSONObject jsonObject = new JSONObject();
//                    jsonObject.put("userId",cache.hget(Constants.PLAYER_+playerId,"userId"));
//                    jsonObject.put("nickName",cache.hget(Constants.PLAYER_+playerId,"nickName"));
//                    jsonObject.put("photoUrl",cache.hget(Constants.PLAYER_+playerId,"photoUrl"));
//
//                    jsonObject.put("changciCount",tpg.getChangciCount());
//                    jsonObject.put("pointCount",tpg.getPointCount());
//                    jsonObject.put("dayingjiaCount",tpg.getDayingjiaCount());
//                    jsonObject.put("dayingjiaPointCount",tpg.getDayingjiaPointCount());
//                    resut.add(jsonObject);
//                }
//            }
//            return resut;
//        } catch (Exception e) {
//            log.error("获取群列表:" + e.getMessage());
//            throw e;
//
//
//        }finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
    }


    public JSONObject selectGroupPlayer(Integer groupId, Integer byDate) throws Exception {
        ICache cache = null;

        try {
            cache = CacheManager.getCache();
//            String dateStr = null;
//            String post_key = "_MEMBER_ALL";
//            if(byDate != null && (byDate == 0 || byDate == 1)) {
//                Date date = DateUtil.changeDate(new Date(), 5, -(byDate + 1));
//                dateStr = DateUtil.parse(date, "yyyy-MM-dd");
//                post_key = "_MEMBER_" + dateStr;
//            }
            JSONObject result = JSON.parseObject(initHGetGroupPlayer(cache, groupId, "", null, null, null));
            return result;
        } catch (Exception e) {
            log.error("获取群列表:" + e.getMessage());
            throw e;


        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }
//    public JSONObject getHhrList(Integer groupId, Integer byDate) throws Exception {
//        ICache cache = null;
//
//        try {
//            cache = CacheManager.getCache();
//            String dateStr = null;
//            String post_key = "_PARTNER_ALL";
//            if(byDate != null && (byDate == 0 || byDate == 1)) {
//                Date date = DateUtil.changeDate(new Date(), 5, -(byDate + 1));
//                dateStr = DateUtil.parse(date, "yyyy-MM-dd");
//                post_key = "_PARTNER_" + dateStr;
//            }
//            return JSON.parseObject(initHGetGroupPlayer(cache, groupId, post_key, dateStr, PlayerTypeEnum.PARTNER));
//        } catch (Exception e) {
//            log.error("获取群列表:" + e.getMessage());
//            throw e;
//
//
//        }finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }

    private String initHGetGroupPlayer(ICache cache, Integer groupId, String post_key, String startTime, String endTime, Integer playerType) throws Exception {
        String hget = cache.hget(Constants.GROUP_PLAYER + post_key, groupId.toString());
        List<TPlayerGroup> list = playerGroupMapper.selectByGroupId(groupId, startTime, endTime, playerType, null);
        if (!StringUtil.isEmpty(hget)) {
            JSONObject cObject = JSONObject.parseObject(hget);
            if (cObject.get("playerCount") != null && !cObject.get("playerCount").toString().equals(String.valueOf (list.size ()))) {
                hget = null;
            }
        }
        //如果数据是空,则从数据库获取数据
        if (StringUtil.isEmpty(hget)) {
            TGroupPlayer tgp = null;
            //处理获取的数据,处理往前端功提供的格式
            if (list != null && list.size() > 0) {
                tgp = groupPlayerMapper.findById(groupId);
                if (tgp != null) {
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("owerId", tgp.getOwerId());
                    jsonObject.put("groupName", tgp.getGroupName());
                    jsonObject.put("config", tgp.getConfig());
                    jsonObject.put("groupName", tgp.getGroupName());
                    jsonObject.put("playerCount", list.size());
                    cache.hset(Constants.GROUP_PLAYER + post_key, groupId.toString(), jsonObject.toJSONString());
                }
            }
            for (TPlayerGroup tpg : list) {
                if (tgp != null) {
                    groupPlayerCacheController.insertGroup(post_key, tpg.getPlayerId(), groupId, cache);
                }
            }
            hget = cache.hget(Constants.GROUP_PLAYER + post_key, groupId.toString());
        }
        return hget;
    }

    public void updateApplyForStatus(Integer playerId, Integer msgId, Integer status) throws Exception {

        ICache cache = null;

        try {
            cache = CacheManager.getCache();

            //status=1 通过加入
            if (status == 1) {
                TMsgPlayerGroup msg = msgPlayerGroupMapper.findById(msgId);

                if (StringUtil.isEmpty(msg)) {
                    return;
                }

                TPlayerGroup invitePlayer = playerGroupMapper.selectByPlayerIdAndGroupId(msg.getInviterUid(), msg.getGroupId());

                if (StringUtil.isEmpty(invitePlayer)) {
                    return;
                }
                Integer groupId = invitePlayer.getGroupId();

                //String group = cache.hget(Constants.GROUP_PLAYER, groupId.toString());
                TGroupPlayer groupPlayer = groupPlayerMapper.findById(groupId);
                if (groupPlayer == null) {
                    return;
                }
                if (!(String.valueOf (playerId)).equals(String.valueOf (groupPlayer.getOwerId ()))) {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "您无权处理该信息...");
                }

                TPlayerGroup playerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(msg.getPlayerId(), groupId);
                if (playerGroup != null) {
                    return;
                }

                //直接加入
                addOne2Club(cache, msg.getPlayerId(), invitePlayer, groupPlayer, true);
            }
            if (status == 3) {
                //通知游戏服,固定格式
            }

        } catch (Exception e) {
            log.error("获取群列表:" + e.getMessage());
            throw e;
        } finally {
            msgPlayerGroupMapper.updateStatusById(msgId, status);
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void updateApplyForStatusByInvite(Integer playerId, Integer owerId, Integer groupId, Integer status, Integer playerId1, String invitePlayerCode) throws Exception {

        ICache cache = null;

        try {
            cache = CacheManager.getCache();


            //更新信息的状态
            msgPlayerGroupMapper.updateStatus(owerId, playerId, groupId, status);
            //status=1 通过加入
            if (status == Constants.INVITE_PLAYER_SURE) {
                TGroupPlayer tGroupPlayer = groupPlayerMapper.findById(groupId);
                if (null == tGroupPlayer) {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "联盟不存在!!");
                }
                Integer owerId1 = tGroupPlayer.getOwerId();
                JSONObject jsonConfig = JSONObject.parseObject(tGroupPlayer.getConfig());
                if (playerId1.equals(owerId1) || jsonConfig.getInteger("is_agree") == 0) {
                    if (playerId.equals(owerId1)) {
                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "您是房主,您已经在房间里面了");
                    }
                    JSONObject jsonObject = JSONObject.parseObject(cache.hget(Constants.GROUP_PLAYER, groupId.toString()));
                    if (!jsonObject.isEmpty()) {
                        JSONArray players = jsonObject.getJSONArray("players");
                        for (int i = 0; i < players.size(); i++) {
                            Integer userId = players.getJSONObject(i).getInteger("userId");
                            if (playerId.equals(userId)) {
                                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您已经在房间里面了");
                            }
                        }
                    }
                    TPlayerGroup invitePlayer = groupPlayerMapper.selectByInviteCode(invitePlayerCode);
                    String inviteCode = groupPlayerCacheController.getClubInviteCode(cache);

                    TPlayerGroup tPlayerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
                    if (tPlayerGroup == null) {
                        TPlayerGroup tPlayerGroup1 = new TPlayerGroup();
                        tPlayerGroup1.setPlayerId(playerId);
                        tPlayerGroup1.setGroupId(groupId);
                        if (StringUtil.isEmpty(invitePlayer)) {
                            tPlayerGroup1.setUpPlayerId(owerId);
                        } else {
                            tPlayerGroup1.setUpPlayerId(invitePlayer.getPlayerId());
                        }
                        tPlayerGroup1.setCreateTime(new Date());
                        tPlayerGroup1.setPlayerType(PlayerTypeEnum.MEMBER);
                        tPlayerGroup1.setInviteCode(inviteCode);
                        tPlayerGroup1.setBonus(0d);
                        tPlayerGroup1.setIsRobot(0);
                        playerGroupMapper.add(tPlayerGroup1);
                        cache.hset(ClubConstants.Club2InviteCode + playerId, String.valueOf (groupId), inviteCode);

                    } else {
                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "这个玩家已经在群里面了!!");
                    }
                    JSONObject groupInfo = groupPlayerCacheController.getGroupInfoByOwerId(owerId, groupId, cache);

                    groupPlayerCacheController.insertPlayerGroup(playerId, groupId, groupInfo.getString("groupName"), tGroupPlayer.getConfig(), cache);

                    //往群->玩家追加数据(redis)
                    groupPlayerCacheController.addGroupPlayer(playerId, groupId, cache);

                    //通知玩家已经入群
                    //通知游戏服,固定格式
                    JSONObject jo = new JSONObject();
                    jo.put("groupId", groupId);
                    jo.put("type", "sure2group");
                    JSONObject data = groupPlayerCacheController.getMessageForNameAndHeadUrlAndUid(owerId, cache);
                    data.put("groupId", groupId);
                    jo.put("data", data);
                    GameServerUtil.notice2HallPublice(Long.parseLong(String.valueOf (playerId)), jo);

                    GameServerUtil.notice2HallAboutClu(Constants.CLU_MEMBER_JOIN, groupId, playerId);
                } else {
                    applyForJoinPlayerGroup(playerId, groupId, playerId1, null);
                }
            }
            if (status == Constants.INVITE_PLAYER_NO_SURE) {
                JSONObject jo = new JSONObject();
                jo.put("groupId", groupId);
                jo.put("type", "notsure2invitegroup");
                JSONObject data = groupPlayerCacheController.getMessageForNameAndHeadUrlAndUid(owerId, cache);
                data.put("groupId", groupId);
                jo.put("data", data);
                GameServerUtil.notice2HallPublice(Long.parseLong(String.valueOf (playerId)), jo);
            }

        } catch (Exception e) {
            if (StringUtil.isNotEmpty(playerId1)) {
                msgPlayerGroupMapper.updateStatus(owerId, playerId, groupId, 8);
            } else {
                msgPlayerGroupMapper.updateStatus(playerId, owerId, groupId, 8);
            }
            log.error("获取群列表:" + e.getMessage());
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void deletePlayer4GroupByOwerId(Integer playerId, Integer owerId, Integer groupId) throws Exception {
        ICache cache = null;

        try {
            cache = CacheManager.getCache();
            JSONObject group = JSONObject.parseObject(cache.hget(Constants.GROUP_PLAYER, groupId.toString()));
            Integer owerId1 = group.getInteger("owerId");
            if (!owerId.equals(owerId1)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您不是群主,不允许删除这个人!!");
            }
            if (playerId.equals(owerId1)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您是群主,不能删除自己,如果有需要,可以解散该群!!");
            }
            TPlayerGroup tPlayerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            Double playerPoint = groupPlayerCacheController.queryClubPoint(groupId, playerId, null);
            if (StringUtil.isEmpty(tPlayerGroup) || playerPoint >= 100) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "该玩家还有积分,不允许删除");
            }
            if (tPlayerGroup.getRepositoryPoint() >= 100) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "该玩家仓库还有积分,不允许删除");
            }

            if (tPlayerGroup.getIsRobot() == 1) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "删除用户异常,错误码10000");
            }

            //清除 群 -> 玩家(redis)
            JSONArray players = group.getJSONArray("players");
            List list = new ArrayList<JSONObject>();
            for (int i = 0; i < players.size(); i++) {
                JSONObject jsonObject = players.getJSONObject(i);
                if (!playerId.equals(jsonObject.getInteger("userId"))) {
                    list.add(jsonObject);
                }
            }
            group.put("players", new JSONArray(list));

            //清除 群 -> 玩家(db)
            groupPlayerCacheController.deleteRedisGroupPlayer(playerId, groupId, cache);

            //清除  玩家->群 (redis)
            boolean hdel = cache.hdel(Constants.PLAYER_GROUP_ + playerId, groupId.toString());

            Integer playerCount = group.getInteger("playerCount");
            if (StringUtil.isNotEmpty(playerCount)) {
                playerCount = playerCount - 1;
            } else {
                playerCount = 1;
            }
            group.put("playerCount", playerCount);
            cache.hset(Constants.GROUP_PLAYER, groupId.toString(), group.toJSONString());

            JSONObject jo = new JSONObject();
            jo.put("groupId", groupId);
            jo.put("type", "delPlayer4Group");
            JSONObject data = groupPlayerCacheController.getMessageForNameAndHeadUrlAndUid(owerId, cache);
            data.put("groupId", groupId);
            jo.put("data", data);
            GameServerUtil.notice2HallPublice(Long.parseLong(String.valueOf (playerId)), jo);

            GameServerUtil.notice2HallAboutClu(Constants.CLU_MEMBER_LEVEL, groupId, playerId);

        } catch (Exception e) {
            log.error("群主删除群里面的某个玩家:" + e.getMessage());
            //throw new InfServerException(Constants.RETURN_CODE_FAIL,"处理异常,请和管理员联系!!");
            throw e;

        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void playerExitGroupByGroupId(Integer playerId, Integer groupId) throws Exception {
        ICache cache = null;

        try {
            cache = CacheManager.getCache();

            JSONObject group = JSONObject.parseObject(cache.hget(Constants.GROUP_PLAYER, groupId.toString()));

            TPlayerGroup playerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            if (StringUtil.isEmpty(playerGroup)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "联盟用户异常");
            }
            if (playerGroup.getPlayerType() == PlayerTypeEnum.MASTER) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您是群主,请不要自己退出群!!");
            }
            Double playerPoint = groupPlayerCacheController.queryClubPoint(groupId, playerId, null);
            if (playerPoint >= 100) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您还有积分,不允许退出联盟");
            }
            if (playerGroup.getRepositoryPoint() >= 100) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "该玩家仓库还有积分,不允许删除");
            }

            //清除 群 -> 玩家(redis)
            JSONArray players = group.getJSONArray("players");
            List list = new ArrayList<JSONObject>();
            for (int i = 0; i < players.size(); i++) {
                JSONObject jsonObject = players.getJSONObject(i);
                if (!(String.valueOf (playerId)).equals(jsonObject.getString("userId"))) {
                    list.add(jsonObject);
                }
            }
            group.put("players", new JSONArray(list));
            Integer playerCount = group.getInteger("playerCount");
            if (StringUtil.isNotEmpty(playerCount)) {
                playerCount = playerCount - 1;
            } else {
                playerCount = 1;
            }
            group.put("playerCount", playerCount);
            cache.hset(Constants.GROUP_PLAYER, groupId.toString(), group.toJSONString());
            //清除 群 -> 玩家(db)
            //清除  玩家->群 (redis)
            groupPlayerCacheController.deleteRedisGroupPlayer(playerId, groupId, cache);

            GameServerUtil.notice2HallAboutClu(Constants.CLU_MEMBER_LEVEL, groupId, playerId);

        } catch (Exception e) {
            log.error("玩家退群:" + e.getMessage());
//            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void deleteGroupByOwerId(Integer owerId, Integer groupId) throws Exception {

        ICache cache = null;

        try {
            cache = CacheManager.getCache();

            JSONObject group = JSONObject.parseObject(cache.hget(Constants.GROUP_PLAYER, groupId.toString()));
            Integer owerId1 = group.getInteger("owerId");
            if (!owerId.equals(owerId1)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您不是群主,不允许解散此群!!");
            }

            String groupPlayer = cache.hget(Constants.GROUP_PLAYER, String.valueOf (groupId));
            if (StringUtil.isNotEmpty(groupPlayer)) {
                JSONObject gp = JSONObject.parseObject(groupPlayer);
                JSONArray players = gp.getJSONArray("players");
                if (StringUtil.isNotEmpty(players)) {
                    JSONObject jo = new JSONObject();
                    jo.put("type", "jiesanRoom");
                    jo.put("groupId", groupId);
                    JSONObject xx = groupPlayerCacheController.getMessageForNameAndHeadUrlAndUid(owerId, cache);
                    jo.put("data", xx);
                    GameServerUtil.notice2HallAllPublice(owerId, players, jo.toJSONString());
                }
            }

            // 删除玩家
            JSONArray players = group.getJSONArray("players");
            for (int i = 0; i < players.size(); i++) {
                Integer userId = players.getJSONObject(i).getInteger("userId");
                //redis
                cache.hdel(Constants.PLAYER_GROUP_ + userId, groupId.toString());

            }

            //删除群 redis
            cache.hdel(Constants.GROUP_PLAYER, groupId.toString());
            //删除群 db
            playerGroupMapper.deleteByGroupId(groupId);
            groupPlayerMapper.removeById(groupId);

            GameServerUtil.notice2HallAboutClu(Constants.CLU_CLOSE, groupId, owerId);

        } catch (Exception e) {
            log.error("群主删除群:" + e.getMessage());
            throw e;

        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void updateGroupNameByOwerId(Integer owerId, Integer groupId, String groupName) throws Exception {
        ICache cache = null;

        try {
            cache = CacheManager.getCache();

            JSONObject group = JSONObject.parseObject(cache.hget(Constants.GROUP_PLAYER, groupId.toString()));
            Integer owerId1 = group.getInteger("owerId");
            if (!owerId.equals(owerId1)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您不是群主,不允更新名字!!");
            }

            TGroupPlayer groupPlayer = groupPlayerMapper.findById(groupId);
            groupPlayer.setGroupName(groupName);
            groupPlayerMapper.update(groupPlayer, false);


            //更新玩家redis中的名字
            JSONArray players = group.getJSONArray("players");
            for (int i = 0; i < players.size(); i++) {
                Integer userId = players.getJSONObject(i).getInteger("userId");
                String config = groupPlayer.getConfig();
                groupPlayerCacheController.insertPlayerGroup(userId, groupId, groupName, config, cache);
            }

        } catch (Exception e) {
            log.error("群主更改群名字:" + e.getMessage());
            throw e;

        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public Long queryGroupOwerId(Integer groupId, ICache cache) throws Exception {
        try {
            String hget = cache.hget(Constants.GROUP_PLAYER, String.valueOf (groupId));
            if (StringUtil.isEmpty(hget)) {
                Long groupOwerId = groupPlayerMapper.queryGroupOwerId(groupId);
                return groupOwerId;
            }
            JSONObject jsonObject = JSONObject.parseObject(hget);
            return jsonObject.getLong("owerId");
        } catch (Exception e) {
            log.error("查询群主的ID" + e.getMessage());
            throw e;
        } finally {

        }
    }

    public void updateGroupConfig(Integer groupId, Integer playerId, Integer is_config, Integer is_invitation, Integer is_agree, String SelectGameConfig, Integer SelectGameConfigIndex,
                                  Integer show_ranking, Integer show_member, Integer show_record, Integer is_chat, Integer exchange_status, Integer club_status, Integer show_table,
                                  Integer auto_exit_club) throws Exception {
        ICache cache = null;

        try {
            cache = CacheManager.getCache();

            TGroupPlayer tGroupPlayer = groupPlayerMapper.findById(groupId);

            System.out.println(tGroupPlayer.getConfig());
            if (!tGroupPlayer.getOwerId().equals(playerId)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您不是盟主,无权更改配置!!");
            }
            JSONObject jsonObject = JSONObject.parseObject(tGroupPlayer.getConfig());
            if (StringUtil.isNotEmpty(is_config)) {
                jsonObject.put(ClubConstant.is_config, is_config);
            }
            if (StringUtil.isNotEmpty(is_invitation)) {
                jsonObject.put(ClubConstant.is_invitation, is_invitation);
            }
            if (StringUtil.isNotEmpty(is_agree)) {
                jsonObject.put(ClubConstant.is_agree, is_agree);
            }
            if (StringUtil.isNotEmpty(show_ranking)) {
                jsonObject.put(ClubConstant.show_ranking, show_ranking);
            }
            if (StringUtil.isNotEmpty(show_member)) {
                jsonObject.put(ClubConstant.show_member, show_member);
            }
            if (StringUtil.isNotEmpty(show_record)) {
                jsonObject.put(ClubConstant.show_record, show_record);
            }
            if (StringUtil.isNotEmpty(is_chat)) {
                jsonObject.put(ClubConstant.is_chat, is_chat);
            }
            if (StringUtil.isNotEmpty(exchange_status)) {
                jsonObject.put(ClubConstant.exchange_status, exchange_status);
            }
            if (StringUtil.isNotEmpty(club_status)) {
                jsonObject.put(ClubConstant.club_status, club_status);
            }

            if (StringUtil.isNotEmpty(show_table)) {
                jsonObject.put(ClubConstant.show_table, show_table);
            }

            if (StringUtil.isNotEmpty(auto_exit_club) ) {
                jsonObject.put(ClubConstant.auto_exit_club, auto_exit_club);
            }

            if (StringUtil.isNotEmpty(SelectGameConfig)) {
                if (SelectGameConfigIndex == null) {
                    // 老游戏写法，不传index就按老写法来
                    jsonObject.put("SelectGameConfig", SelectGameConfig);
                } else {
                    Object object = jsonObject.get("SelectGameConfig");
                    String str = object == null ? "[]" : object.toString();
                    JSONArray jsonArray = JSONArray.parseArray(str);
                    JSONObject newJsonObject = JSONObject.parseObject(SelectGameConfig);
                    if (SelectGameConfigIndex == -1) {
                        // 添加玩法
                        jsonArray.add(newJsonObject);
                    } else {
                        // 修改玩法
                        jsonArray.set(SelectGameConfigIndex, newJsonObject);
                    }
                    jsonObject.put("SelectGameConfig", jsonArray);
                }
            }
            tGroupPlayer.setConfig(jsonObject.toJSONString());
            groupPlayerMapper.update(tGroupPlayer, false);

            String hget = cache.hget(Constants.GROUP_PLAYER, groupId.toString());
            JSONObject jsonConfig = JSONObject.parseObject(hget);
            if (StringUtil.isNotEmpty(hget)) {
                jsonConfig.put("config", jsonObject.toJSONString());
                cache.hset(Constants.GROUP_PLAYER, groupId.toString(), jsonConfig.toJSONString());
            }

            JSONObject jo = new JSONObject();
            jo.put("groupId", groupId);
            jo.put("type", "updateClubConfig");
            jo.put("data", jsonObject.toJSONString());

            JSONArray players = jsonConfig.getJSONArray("players");
            for (int i = 0; i < players.size(); i++) {
                playerId = players.getJSONObject(i).getInteger("userId");
                String hget1 = cache.hget(Constants.PLAYER_GROUP_ + playerId, groupId.toString());
                if (StringUtil.isNotEmpty(hget1)) {
                    JSONObject js = JSONObject.parseObject(hget1);
                    js.put("config", jsonObject.toJSONString());
                    cache.hset(Constants.PLAYER_GROUP_ + playerId, groupId.toString(), js.toJSONString());
                    //通知修改配置
                    GameServerUtil.notice2HallPublice(Long.parseLong(String.valueOf (playerId)), jo);
                }
            }
        } catch (Exception e) {
            log.error("更新游戏配置" + e.getMessage());
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "网络异常,请稍后再试!!");
        } finally {
            if (null != cache) {
                CacheManager.releaseCache(cache);
            }
        }

    }


    public void deleteGroupConfig(Integer groupId, Integer playerId, Integer SelectGameConfigIndex) {
        ICache cache = null;

        try {
            cache = CacheManager.getCache();

            TGroupPlayer tGroupPlayer = groupPlayerMapper.findById(groupId);

            System.out.println(tGroupPlayer.getConfig());
            if (!tGroupPlayer.getOwerId().equals(playerId)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您不是部长,无权更改配置!!");
            }

            JSONObject jsonObject = JSONObject.parseObject(tGroupPlayer.getConfig());
            Object object = jsonObject.get("SelectGameConfig");
            String str = object == null ? "[]" : object.toString();
            JSONArray jsonArray = JSONArray.parseArray(str);
            if (SelectGameConfigIndex >= jsonArray.size()) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "[非法操作]无法删除一个不存在的玩法!!");
            }
            jsonArray.remove((int) SelectGameConfigIndex);
            jsonObject.put("SelectGameConfig", jsonArray);

            tGroupPlayer.setConfig(jsonObject.toJSONString());
            groupPlayerMapper.update(tGroupPlayer, false);

            String hget = cache.hget(Constants.GROUP_PLAYER, groupId.toString());
            JSONObject jsonConfig = JSONObject.parseObject(hget);
            if (StringUtil.isNotEmpty(hget)) {
                jsonConfig.put("config", jsonObject.toJSONString());
                cache.hset(Constants.GROUP_PLAYER, groupId.toString(), jsonConfig.toJSONString());
            }
            JSONArray players = jsonConfig.getJSONArray("players");
            for (int i = 0; i < players.size(); i++) {
                playerId = players.getJSONObject(i).getInteger("userId");
                String hget1 = cache.hget(Constants.PLAYER_GROUP_ + playerId, groupId.toString());
                if (StringUtil.isNotEmpty(hget1)) {
                    JSONObject js = JSONObject.parseObject(hget1);
                    js.put("config", jsonObject.toJSONString());
                    cache.hset(Constants.PLAYER_GROUP_ + playerId, groupId.toString(), js.toJSONString());
                }
            }
        } catch (Exception e) {
            log.error("删除游戏配置" + e.getMessage());
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "网络异常,请稍后再试!!");
        } finally {
            if (null != cache) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public int cluCoinsHandle(Integer groupId, Integer ownerId, Integer playerId, Integer type, Integer coins, String sign, Integer useType) {

        ICache cache = null;

        try {
            cache = CacheManager.getCache();

//            JSONObject group = JSONObject.parseObject(cache.hget(Constants.GROUP_PLAYER, groupId.toString()));
//            Integer owerId1 = group.getInteger("owerId");
//            if (!ownerId.equals(owerId1)) {
//                return Constants.Limit_Err;
//            }
            TUser tUser = userMapper.findById(Long.parseLong(String.valueOf (playerId)));
            if (StringUtil.isEmpty(tUser)) {
                return Constants.TUSER_Err;
            }

            String md5 = Md5.getMd5ofStr("addCoins" + groupId + "_" + ownerId + "&" + playerId + "type" + type + coins);
            if (!md5.equals(sign)) {
                System.out.println("md5-->" + md5);
                return Constants.Encrypt_Err;
            }
            boolean inGameOwner = baseCacheController.isInGame(ownerId, cache);
            boolean inGamePlayer = baseCacheController.isInGame(playerId, cache);
            if ((inGameOwner || inGamePlayer) && type == Constants.Coins_sub) {
//            if (inGameOwner || inGamePlayer) {
                return Constants.TUSER_IS_INGAME;
            }

            TPlayerGroup ownerInfo = playerGroupMapper.selectByPlayerIdAndGroupId(ownerId, groupId);
            TPlayerGroup playerInfo = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            TGroupPlayer clubInfo = groupPlayerMapper.findById(groupId);

            if (StringUtil.isEmpty(ownerInfo) || StringUtil.isEmpty(playerInfo)) {
                return Constants.TUSER_No_Exist;
            }
            if (StringUtil.isEmpty(clubInfo)) {
                return Constants.Limit_Err;
            }
            String config = clubInfo.getConfig();
            JSONObject clubConfig = JSONObject.parseObject(config);
            String exchangeStatus = clubConfig.getString(ClubConstant.exchange_status);
            boolean isOwner = ownerInfo.getPlayerType() == PlayerTypeEnum.MASTER;

            boolean isManager = groupPlayerCacheController.isManager(cache, groupId, ownerId);
            //管理员可以直接上下分
            if (!isManager) {
                if (1 == useType) {
                    if (ownerInfo.getPlayerType() != PlayerTypeEnum.MASTER && ownerInfo.getPlayerType() != PlayerTypeEnum.PARTNER) {
                        return Constants.Limit_Err;
                    }
                    if (!isOwner && !ownerId.equals(playerInfo.getUpPlayerId()) && type == Constants.Coins_sub) {
                        return Constants.TUSER_IS_NO_MYSon;
                    }
                } else {
                    //如果是普通人的话判断是不是允许赠送积分
                    if (!"1".equals(exchangeStatus) || type == Constants.Coins_sub) {
                        return Constants.Forbid_Exchange_Point;
                    }
                }
            } else {
                useType = 1;
            }

//            Long hincrby = cache.hincrby(Constants.Lock_By_Owner, String.valueOf (groupId), 1);
//            if (hincrby > 1 ) {
//                return Constants.Locking_Err;
//            }

            Integer changeType = ClubConstants.PointChange_add;
            if (useType != 1) {
                changeType = ClubConstants.PointChange_Give;
            }

            //记录
            TClucoinsHandleHistory tClucoinsHandleHistory = new TClucoinsHandleHistory();
            tClucoinsHandleHistory.setCoins(coins);
            tClucoinsHandleHistory.setGroupId(groupId);
            tClucoinsHandleHistory.setOwnerId(ownerId);
            tClucoinsHandleHistory.setType(type);
            tClucoinsHandleHistory.setPlayerId(Long.parseLong(String.valueOf (playerId)));
            tClucoinsHandleHistory.setCreateTime(new Date());
            tClucoinsHandleHistory.setNickName(tUser.getNickName());
            tClucoinsHandleHistory.setUseType(useType);

            //加
            if (type == Constants.Coins_add) {
                if (isOwner) {
                    synchronized (Lock_Add_A) {
                        Integer maxPoint = clubInfo.getMaxPoint();
                        Integer pointPool = clubInfo.getPointPool();
                        Integer profitCount = clubInfo.getProfitCount();
                        if (coins > (maxPoint - pointPool - profitCount)) {
                            return Constants.MareThat_maxpoint;
                        }

                        clucoinsHandleHistoryMapper.insert(tClucoinsHandleHistory);

                        Double aPoint = groupPlayerCacheController.queryClubPoint(groupId, playerId, null);
                        pointChangeRecordService.addOne(groupId, playerId, changeType, aPoint.intValue(), coins, aPoint.intValue() + coins, ownerId, null, null, null, DateUtils.getTodayDate());
                        //更新奖池
                        Integer updatePoolCount = groupPlayerMapper.updateCluPointPool(groupId, coins);

                        groupPlayerCacheController.updateClubPoint(groupId, playerId, coins);
                    }
                } else {
                    synchronized (Lock_Add_B) {
                        Double ownerPoint = groupPlayerCacheController.queryClubPoint(groupId, ownerId, null);
                        if (ownerPoint < coins) {
                            return Constants.Point_Nont_Enough;
                        }

                        clucoinsHandleHistoryMapper.insert(tClucoinsHandleHistory);

                        Double playerPoint = groupPlayerCacheController.queryClubPoint(groupId, playerId, null);

                        pointChangeRecordService.addOne(groupId, ownerId, changeType, ownerPoint.intValue(), -coins, ownerPoint.intValue() - coins, playerId, null, null, null, DateUtils.getTodayDate());
                        pointChangeRecordService.addOne(groupId, playerId, changeType, playerPoint.intValue(), coins, playerPoint.intValue() + coins, ownerId, null, null, null, DateUtils.getTodayDate());

                        groupPlayerCacheController.updateClubPoint(groupId, ownerId, -coins);
                        groupPlayerCacheController.updateClubPoint(groupId, playerId, coins);
                    }
                }
                //如果是机器人,充钱了之后就通知alloc释放它
                if (1 == playerInfo.getIsRobot()) {
                    GameServerUtil.I2AReleaseRobot(groupId, 0, playerInfo.getPlayerId(), 1);
                }
            }
            //减
            if (type == Constants.Coins_sub) {
                if (isOwner) {
                    synchronized (Lock_Cub_A) {
                        Double playerPoint = groupPlayerCacheController.queryClubPoint(groupId, playerId, null);
                        if (playerPoint < coins) {
                            return Constants.Point_Nont_Enough;
                        }

                        clucoinsHandleHistoryMapper.insert(tClucoinsHandleHistory);

                        pointChangeRecordService.addOne(groupId, playerId, changeType, playerPoint.intValue(), -coins, playerPoint.intValue() - coins, ownerId, null, null, null, DateUtils.getTodayDate());
                        Integer updatePoolCount = groupPlayerMapper.updateCluPointPool(groupId, -coins);

                        groupPlayerCacheController.updateClubPoint(groupId, playerId, -coins);
                    }
                } else {
                    synchronized (Lock_Cub_B) {
                        Double playerPoint = groupPlayerCacheController.queryClubPoint(groupId, playerId, null);
                        if (playerPoint < coins) {
                            return Constants.Point_Nont_Enough;
                        }

                        clucoinsHandleHistoryMapper.insert(tClucoinsHandleHistory);

                        Double ownerPoint = groupPlayerCacheController.queryClubPoint(groupId, ownerId, null);

                        pointChangeRecordService.addOne(groupId, ownerId, changeType, ownerPoint.intValue(), coins, ownerPoint.intValue() + coins, playerId, null, null, null, DateUtils.getTodayDate());
                        pointChangeRecordService.addOne(groupId, playerId, changeType, playerPoint.intValue(), -coins, playerPoint.intValue() - coins, ownerId, null, null, null, DateUtils.getTodayDate());

                        groupPlayerCacheController.updateClubPoint(groupId, ownerId, coins);
                        groupPlayerCacheController.updateClubPoint(groupId, playerId, -coins);
                    }
                }
            }

            JSONObject jo = new JSONObject();
            jo.put("groupId", groupId);
            if (type == 0) {
                jo.put("coins", -coins);
            } else {
                jo.put("coins", coins);
            }
            jo.put("type", "updatePoint");
            jo.put("handNickName", baseCacheController.queryUserNickName(cache, ownerId));
            jo.put("handUid", ownerId);
            GameServerUtil.notice2HallPublice(Long.parseLong(String.valueOf (playerId)), jo);

//            cache.hdel(Constants.Lock_By_Owner,String.valueOf (groupId));

            return Constants.handle_Success;
        } catch (Exception e) {
            log.error("积分操作" + e.getMessage());
//            throw new InfServerException(Constants.RETURN_CODE_FAIL,"网络异常,请稍后再试!!");
//            cache.hdel(Constants.Lock_By_Owner,String.valueOf (groupId));
            return Constants.System_Err;
        } finally {
            if (null != cache) {
                CacheManager.releaseCache(cache);
            }
        }

    }

    public Map<String, Object> selectCluHistory(Integer groupId, String startTime, String endTime, Integer pageSize, Integer currentPage, Integer owner, Integer playerId) {

        Integer beginRowIndex = (currentPage - 1) * pageSize;

        TGroupPlayer tgp = groupPlayerMapper.findById(groupId);
        if (StringUtil.isEmpty(tgp)) {
            return null;
        }

        //如果是群主 查全部
        if ((String.valueOf (groupId)).equals(tgp.getOwerId())) {

        } else {
            if (StringUtil.isEmpty(playerId)) {
                playerId = owner;
            }
        }
        owner = null;

        List<TClucoinsHandleHistory> list = clucoinsHandleHistoryMapper.selectList(groupId, startTime, endTime, beginRowIndex, pageSize, owner, playerId);
        Integer count = clucoinsHandleHistoryMapper.selectListCount(groupId, startTime, endTime, owner, playerId);

        Map<String, Object> result = new HashMap<String, Object>();
        result.put("list", list);
        result.put("listCount", count);

        return result;
    }

    public TGroupPlayer getGroupInfo(Integer groupId) {

        return groupPlayerMapper.findById(groupId);

    }

    public void updatCluConfigCostPattern(Integer groupId, Integer ownerId, Integer cost_pattern, Double commission, Integer cost_user_type, Double costLimit, Integer strengthLimit) throws Exception {
        ICache cache = null;

        try {
            cache = CacheManager.getCache();
            TGroupPlayer tGroupPlayer = groupPlayerMapper.findById(groupId);

            if (!tGroupPlayer.getOwerId().equals(ownerId)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您不是群主,无权更改配置!!");
            }

            if (cost_pattern == Constants.Cost_Pattern_Com && (commission < 0 || commission > 100)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "请输入有效的抽成比例（0-100）！！");
            }

            if (cost_pattern == Constants.Cost_Pattern_guding && commission < 0) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "请输入有效的抽成数量！！");
            }


            if (cost_pattern != Constants.Cost_Pattern_Com && cost_pattern != Constants.Cost_Pattern_guding) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "请设置有效的抽成类型！！");
            }

            if (cost_user_type != Constants.cost_user_type_dayingjia && cost_user_type != Constants.cost_user_type_yingjia) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "请设置有效的抽水群体类型！！");
            }

            groupPlayerMapper.updateComConfig(groupId, cost_pattern, commission, cost_user_type, costLimit, strengthLimit);

            cache.del(Constants.Group_Commission + groupId);
            cache.hdel(Constants.Min_Join_FreeGame_Coins, String.valueOf (groupId));

        } finally {
            if (null != cache) {
                CacheManager.releaseCache(cache);
            }
        }

    }

    public void updatCluConfigMinCoins(Integer groupId, Integer ownerId, Integer coins) throws Exception {

        ICache cache = null;

        try {
            cache = CacheManager.getCache();
            TGroupPlayer tGroupPlayer = groupPlayerMapper.findById(groupId);

            if (!tGroupPlayer.getOwerId().equals(ownerId)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您不是群主,无权更改配置!!");
            }


            groupPlayerMapper.updatePlayCoins(groupId, coins);
            if (cache != null) {
                cache.hdel(Constants.Min_Join_FreeGame_Coins, String.valueOf (groupId));
            }

        } finally {
            if (null != cache) {
                CacheManager.releaseCache(cache);
            }
        }

    }

    public void updatCostUserType(Integer groupId, Integer ownerId, Integer costUserType) throws Exception {

        ICache cache = null;

        try {
            cache = CacheManager.getCache();
            TGroupPlayer tGroupPlayer = groupPlayerMapper.findById(groupId);

            if (!tGroupPlayer.getOwerId().equals(ownerId)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您不是群主,无权更改配置!!");
            }


            groupPlayerMapper.updatCostUserType(groupId, costUserType);
            if (cache != null) {
                cache.hdel(Constants.Cost_user_type, String.valueOf (groupId));
            }

        } catch (Exception e) {
            throw e;
        } finally {
            if (null != cache) {
                CacheManager.releaseCache(cache);
            }
        }

    }

    public void setCost(Integer groupId, Integer playerId, Integer costPattern, Double commission, Integer costUserType) throws Exception {
        // 只有群主或管理员才能设置抽水
        Integer playerType = playerGroupMapper.getPlayTypeByGroupIdAndPlayerId(groupId, playerId);
        if (playerType == null) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "操作错误：玩家没有权限设置联盟抽水!!");
        } else if (playerType != 0 && playerId != 1) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "玩家没有权限设置联盟抽水!!");
        }
        groupPlayerMapper.setCost(groupId, playerId, costPattern, commission, costUserType);
    }

    public JSONObject selectCluConfigCostPattern(Integer groupId) {
        TGroupPlayer tGroupPlayer = groupPlayerMapper.findById(groupId);
        if (tGroupPlayer == null) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "没有找到这个群！");
        }
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("groupId", tGroupPlayer.getGroupId());
        jsonObject.put("ownerId", tGroupPlayer.getOwerId());
        jsonObject.put("cost_pattern", tGroupPlayer.getCostPattern());
        jsonObject.put("cost_user_type", tGroupPlayer.getCostUserType());
        jsonObject.put("commission", tGroupPlayer.getCommission());
        jsonObject.put("costLimit", tGroupPlayer.getCostLimit());
        jsonObject.put("strengthLimit", tGroupPlayer.getStrengthLimit());
        jsonObject.put("updateCostCount", tGroupPlayer.getUpdateCostCount());
        return jsonObject;
    }

    public void savePoint2Repository(Integer groupId, Integer playerId, Integer savePoint) throws Exception {

        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            boolean inGame = baseCacheController.isInGame(playerId, cache);
            if (inGame) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "请退出游戏后再操作...");
            }
            TPlayerGroup tpg = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            if (StringUtil.isEmpty(tpg)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "联盟数据异常...");
            }

            if (tpg.getPlayerType() == PlayerTypeEnum.MASTER) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "群主不允许积分存入保险箱...");
            }

            if (savePoint <= 0) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "请输入有效的数字...");
            }

            synchronized (log) {
                Double playerPoint = groupPlayerCacheController.queryClubPoint(groupId, playerId, null);
                if (savePoint > playerPoint) {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "积分不足");
                }
                int updateCount = playerGroupMapper.updatePoint2Repository(groupId, playerId, savePoint);
                if (updateCount > 0) {
                    pointChangeRecordService.addOne(groupId, playerId, ClubConstants.PointChange_repository, playerPoint.intValue(), -savePoint, playerPoint.intValue() - savePoint, playerId, null, null, null, DateUtils.getTodayDate());
                    groupPlayerCacheController.updateClubPoint(groupId, playerId, -savePoint);
                    //存入保险箱的时候增加 未提取积分的综合
                    groupPlayerMapper.updateCluProfitCount(groupId, savePoint, 0, -savePoint);

                } else {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "请刷新后重试...");
                }
            }
            cluRepositoryHandleHistoryService.addOne(playerId, groupId, 1, savePoint);

        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }

    }

    public void heHuoRenTixian(Integer groupId, Integer playerId, Integer tixianCount) throws Exception {

        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            if (tixianCount <= 0) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "请输入有效的领取数额...");
            }

            TPlayerGroup tpg = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            if (StringUtil.isEmpty(tpg)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "联盟数据异常...");
            }

            if (tpg.getPlayerType() == PlayerTypeEnum.MASTER) {
                //群主的提现是直接扣减收益,变相增加奖池
                TGroupPlayer groupPlayer = groupPlayerMapper.findById(groupId);
                if (!StringUtil.isEmpty(groupPlayer)) {
                    if (tixianCount > groupPlayer.getProfitClubCount()) {
                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "积分不足以本次提取...");
                    }
                    groupPlayerMapper.updateCluProfitCount(groupId, -tixianCount, -tixianCount, 0);
                }
            } else {
                int subPoint = tpg.getRepositoryPoint();
                if (tixianCount > subPoint) {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "积分不足以本次提取...");
                }

                int updateCount = playerGroupMapper.updateTixianCount(groupId, playerId, tixianCount);

                if (updateCount > 0) {
                    Double playerPoint = groupPlayerCacheController.queryClubPoint(groupId, playerId, null);
                    pointChangeRecordService.addOne(groupId, playerId, ClubConstants.PointChange_repository, playerPoint.intValue(), tixianCount, playerPoint.intValue() + tixianCount, playerId, null, null, null, DateUtils.getTodayDate());
                    groupPlayerCacheController.updateClubPoint(groupId, playerId, tixianCount);

                    groupPlayerMapper.updateCluProfitCount(groupId, -tixianCount, 0, tixianCount);
                } else {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "领取失败，请稍后再试...");
                }
            }

            cluRepositoryHandleHistoryService.addOne(playerId, groupId, 0, tixianCount);

        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }

    }

    public void baiRenPoolTixian(Integer groupId, Integer playerId, Integer tixianCount) throws Exception {

        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            if (tixianCount <= 0) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "请输入有效的领取数额...");
            }
            TPlayerGroup tpg = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            if (StringUtil.isEmpty(tpg)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "联盟数据异常...");
            }

            if (tpg.getPlayerType() != PlayerTypeEnum.MASTER) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "只允许盟主操作...");
            }

            Integer clubBaiRenPool = groupPlayerCacheController.getClubBaiRenPool(groupId, cache);

            if (tixianCount > clubBaiRenPool) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "池子不足以本次提取...");
            }

            groupPlayerMapper.updateCluPointPool(groupId, -tixianCount);

            cluRepositoryHandleHistoryService.addOne(playerId, groupId, 2, tixianCount);

            groupPlayerCacheController.hinClubBaiRenPool(groupId, Long.parseLong(String.valueOf (tixianCount)));

        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }

    }

    public Map<String, Object> gotoClub(Integer groupId, Integer uid, Integer gameType) throws Exception {

        ICache cache = null;
        try {
            Map<String, Object> result = new HashMap<String, Object>();
            cache = CacheManager.getCache();

            TPlayerGroup tPlayerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(uid, groupId);
            if (StringUtil.isEmpty(tPlayerGroup)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "俱乐部不存在...");
            }

            result.put("point", groupPlayerCacheController.queryClubPoint(groupId, uid, null));

            result.put("gameConfigs", playerGroupService.selectGameConfig(groupId, uid, null, null, gameType));

            result.put("notice", groupNoticeService.getNotice(groupId, uid));

            result.put("gameLimits", RedisUtil3.getRu().smembers(CLUB_NEED_GAME_LIST_ + groupId));

            return result;
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }

    }

    public Map<String, Object> repositoryHandleHistory(Integer groupId, Integer playerId, Integer pageSize, Integer currentPage, String type) throws Exception {

        ICache cache = null;
        try {

            cache = CacheManager.getCache();
            TPlayerGroup tPlayerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            if (StringUtil.isEmpty(tPlayerGroup)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "联盟用户信息异常");
            }

            int startIndex = (currentPage - 1) * pageSize;
            List<TCluRepositoryHandleHistory> list = cluRepositoryHandleHistoryService.selectMyHistory(playerId, groupId, type, startIndex, pageSize);
            Integer listCount = cluRepositoryHandleHistoryService.selectMyHistoryCount(playerId, groupId, type);

            Map<String, Object> result = new HashMap<String, Object>();
            result.put("list", list);
            result.put("listCount", listCount);
            result.put("xiaohaoToday", tPlayerGroup.getXiaohaoToday());
            result.put("xiaohaoYesterday", tPlayerGroup.getXiaohaoYesterday());
            result.put("repositoryPoint", tPlayerGroup.getRepositoryPoint());
            result.put("bonus", tPlayerGroup.getBonus());
            if (tPlayerGroup.getPlayerType() == PlayerTypeEnum.MASTER) {
                TGroupPlayer groupPlayer = groupPlayerMapper.findById(groupId);
                if (StringUtil.isEmpty(groupPlayer)) {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "联盟信息异常");
                }
                result.put("maxPoint", groupPlayer.getMaxPoint());
                result.put("pointPool", groupPlayer.getPointPool());
                result.put("profitOwnerPoint", groupPlayer.getProfitClubCount());
                result.put("profitPoint", groupPlayer.getProfitCount());
                result.put("ClubBaiRenPool", groupPlayerCacheController.getClubBaiRenPool(groupId, cache));
            }

            return result;

        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }


    }

    public Map<String, Object> selectMyXiaohaoList(Integer groupId, Integer xyUid, Integer searchUid, Integer currentPage, Integer pageSize, String startTime, String endTime) throws Exception {

        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            Map<String, Object> result = new HashMap<String, Object>();

            List<TGroupXiaohaoHistory> list = xiaoHaoHistoryService.getXiaohaoList(groupId, xyUid, startTime, endTime, currentPage, pageSize, searchUid);
            Integer count = xiaoHaoHistoryService.getXiaohaoListLen(groupId, xyUid, startTime, endTime, searchUid);
//        Integer profitCount = xiaoHaoHistoryService.getXiaoHaoCount(groupId, xyUid, startTime, endTime, searchUid);
            for (TGroupXiaohaoHistory history : list) {
                String urlPhone = baseCacheController.queryUserPhoto(cache, history.getPlayerId());
                String nickName = baseCacheController.queryUserNickName(cache, history.getPlayerId());
                history.setSmallPhoto(urlPhone);
                history.setNickName(nickName);
            }

            result.put("list", list);
            result.put("listCount", count);
//        result.put("profitCount", profitCount);
            return result;
        }catch (Exception e ) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }

    }

    public Map<String, Object> selectPointChangeHistory(Integer groupId, Integer xyUid, String type, String startTime, String endTime, Integer pageSize, Integer currentPage, Integer searchId) {

        if (!StringUtil.isEmpty(searchId)) {
            xyUid = searchId;
        }

        return pointChangeRecordService.selectChangeRecord(groupId, xyUid, type, currentPage, pageSize);

    }

    public void setClubManagerByOwner(Integer xyUid, Integer playerId, Integer groupId, Integer status) throws Exception {

        ICache cache = null;
        try {
            cache = CacheManager.getCache();

            if ((String.valueOf (xyUid)).equals(String.valueOf (playerId))) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "不可将自己设为管理员...");
            }

            TGroupPlayer tGroupPlayer = groupPlayerMapper.findById(groupId);

            if (StringUtil.isEmpty(tGroupPlayer) || !tGroupPlayer.getOwerId().equals(xyUid)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您不是群主,无法设置管理员...");
            }

            if (status == 1) {
                groupPlayerCacheController.setManager(cache, groupId, playerId);
            } else {
                groupPlayerCacheController.removeManager(cache, groupId, playerId);
            }

            JSONObject jo = new JSONObject();
            jo.put("groupId", groupId);
            jo.put("status", status);
            jo.put("type", "setManager");
            GameServerUtil.notice2HallPublice(Long.parseLong(String.valueOf (playerId)), jo);

        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }

    }

    public void opeSetClubGameLimit(Integer groupId, Integer xyUid, String gameLimits) throws Exception{

        ICache cache = null;
        try {
            cache = CacheManager.getCache();

            TGroupPlayer tGroupPlayer = groupPlayerMapper.findById(groupId);

            if (StringUtil.isEmpty(tGroupPlayer) || !tGroupPlayer.getOwerId().equals(xyUid)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "您不是群主,无法设置...");
            }

            RedisUtil3 ru = RedisUtil3.getRu();
            if (!StringUtil.isEmpty(gameLimits )) {
                ru.del(CLUB_NEED_GAME_LIST_ + groupId);
                String[] lists = gameLimits.split("-");
                if (lists.length > 0) {
                    for (String level : lists) {
                        ru.sadd(CLUB_NEED_GAME_LIST_ + groupId, level);
                    }
                }
            }

            // 通知玩家
            JSONObject jo = new JSONObject();
            jo.put("groupId", groupId);
            jo.put("type", "gameLimits");
            jo.put("data", gameLimits);

            GameServerUtil.notice2HallPubliceAllMember(groupId, jo);

        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }

    }

    public Object getClubUserInfo(Integer groupId, Integer xyUid, Integer searchId) throws Exception {


        ICache cache = null;
        try {
            cache = CacheManager.getCache();

            TPlayerGroup newPlayer = playerGroupMapper.selectByPlayerIdAndGroupId(searchId, groupId);
            if (newPlayer != null) {
                String nickName = baseCacheController.queryUserNickName(cache, searchId);
                String photo = baseCacheController.queryUserPhoto(cache, searchId);

                Map result = new HashMap<String, Object>();
                result.put("uid", searchId);
                result.put("nickName", nickName);
                result.put("smallIcon", photo);

                return result;
            }

            throw new InfServerException(Constants.RETURN_CODE_FAIL,"玩家不存在...");

        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }

    }

    public Object queryJoinGameLimit(Integer groupId, Integer xyUid) throws Exception{

        ICache cache = null;
        try {
            cache = CacheManager.getCache();

            JSONObject result = new JSONObject();

            RedisUtil3 ru = RedisUtil3.getRu();
            Map<String, String> all = ru.hgetall(ClubConstant.CLUB_JOIN_TOGETHER_LIMIT_ + groupId);
            if (null != all && all.size() > 0 ) {
                for (Map.Entry<String, String> entry : all.entrySet()) {
                    String mapKey = entry.getKey();
                    String mapValue = entry.getValue();

                    if (!StringUtil.isEmpty(mapValue) ) {
                        String[] list = mapValue.split("-");
                        JSONArray players = new JSONArray();
                        for (String str : list) {
                            JSONObject json = new JSONObject();
                            int uid = Integer.parseInt(str);
                            json.put("smallIcon", baseCacheController.queryUserPhoto(cache, uid));
                            json.put("nickName", baseCacheController.queryUserNickName(cache, uid));
                            json.put("uid", uid);
                            players.add(json);
                        }
                        result.put(mapKey ,players);
                    }
                }
            }

            return result;
        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }

    }

    public void addJoinGameLimit(Integer groupId, Integer xyUid, String addUser, String key) throws Exception{

        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            String[] users = addUser.split("-");
            if (users.length < 1 ) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"至少需要两个玩家...");
            }

            Integer playerType = playerGroupMapper.getPlayTypeByGroupIdAndPlayerId(groupId, xyUid);
            if (playerType == PlayerTypeEnum.MASTER || playerType == PlayerTypeEnum.MANAGER ) {

                RedisUtil3 ru = RedisUtil3.getRu();
                if (StringUtil.isEmpty(key) ) {
                    ru.hset(ClubConstant.CLUB_JOIN_TOGETHER_LIMIT_ + groupId, String.valueOf (System.currentTimeMillis ()), addUser);
                } else {
                    //先解除以前的关系
                    String oldM = ru.hget(ClubConstant.CLUB_JOIN_TOGETHER_LIMIT_ + groupId, key);
                    if (!StringUtil.isEmpty(oldM) ) {
                        String[] split = oldM.split("-");
                        for (int i = 0; i < split.length; i++) {
                            for (int j = 0; j < split.length; j++ ) {
                                if (!split[i].equals(split[j]) ) {
                                    ru.srem(ClubConstant.CLUB_USER_JOIN_TOGETHER_LIMIT_ + groupId + "_" + split[i], split[j]);
                                }
                            }
                        }
                    }

                    ru.hset(ClubConstant.CLUB_JOIN_TOGETHER_LIMIT_ + groupId, key, addUser);
                }

                //新曾限制关系
                for (int i = 0; i < users.length; i++ ) {
                    for (int j = 0; j < users.length; j++ ) {
                        if (!users[i].equals(users[j]) ) {
                            ru.sadd(ClubConstant.CLUB_USER_JOIN_TOGETHER_LIMIT_ + groupId + "_" + users[i], users[j]);
                        }
                    }
                }

            }

        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }

    }

    public void delJoinGameLimit(Integer groupId, Integer xyUid, String key) throws Exception{

        try {
            Integer playerType = playerGroupMapper.getPlayTypeByGroupIdAndPlayerId(groupId, xyUid);
            if (playerType == PlayerTypeEnum.MASTER || playerType == PlayerTypeEnum.MANAGER ) {
                RedisUtil3 ru = RedisUtil3.getRu();
                String oldM = ru.hget(ClubConstant.CLUB_JOIN_TOGETHER_LIMIT_ + groupId, key);
                if (!StringUtil.isEmpty(oldM) ) {
                    String[] split = oldM.split("-");
                    for (int i = 0; i < split.length; i++) {
                        for (int j = 0; j < split.length; j++ ) {
                            if (!split[i].equals(split[j]) ) {
                                ru.srem(ClubConstant.CLUB_USER_JOIN_TOGETHER_LIMIT_ + groupId + "_" + split[i], split[j]);
                            }
                        }
                    }
                    ru.hdel(ClubConstant.CLUB_JOIN_TOGETHER_LIMIT_ + groupId, key);
                }
            }
        }catch (Exception e ) {
            throw e;
        }finally {

        }
    }

    public void updateClubThresholdValue(Integer xyUid, Integer groupId, Integer hehuorenId, Integer thresholdValue) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();

            TPlayerGroup tpg = playerGroupMapper.selectByPlayerIdAndGroupId(hehuorenId, groupId);
            if (StringUtil.isEmpty(tpg) || tpg.getPlayerType() != PlayerTypeEnum.PARTNER) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "联盟用户信息异常...");
            }

            if (!tpg.getUpPlayerId().equals(xyUid) ) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "不是你的下级,不允许设置...");
            }

            if (thresholdValue < 0 ) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "阀值不允许小于0...");
            }


            RedisUtil3 ru = RedisUtil3.getRu();
            ru.hset(ClubConstant.CLUB_PARTNER_THRESHOLD_VALUE_ + groupId, hehuorenId+"", thresholdValue+"");

        } catch (Exception e) {
            throw e;
        } finally {
            CacheManager.releaseCache(cache);
        }
    }

}
