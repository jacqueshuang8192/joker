package com.j.joker.cache.controller;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.util.*;
import com.j.joker.cache.CacheManager;
import com.j.joker.cache.ICache;
import com.j.joker.constants.ClubConstants;
import com.j.joker.constants.Constants;
import com.j.joker.controller.playerGroup.ClubConstant;
import com.j.joker.enums.PlayerTypeEnum;
import com.j.joker.mapper.TGroupPlayerMapper;
import com.j.joker.mapper.TPlayerGroupMapper;
import com.j.joker.mapper.TUserMapper;
import com.j.joker.model.TGroupPlayer;
import com.j.joker.model.TPlayerGroup;
import com.j.joker.model.TUser;
import com.j.joker.utils.InfServerException;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by muzi on 2017/12/7.
 */
@Service
public class GroupPlayerCacheController {
    private static Logger log = Logger.getLogger(GroupPlayerCacheController.class);
    private static final Log pointLog = LogFactory.getLog("point");

    @Autowired
    private TGroupPlayerMapper groupPlayerMapper;
    @Autowired
    private TPlayerGroupMapper playerGroupMapper;
    @Autowired
    private TUserMapper userMapper;
    @Autowired
    private PlayerCacheController playerCacheController;

    public final static String GROUP_USER_CHIPS_ = "GROUP_USER_CHIPS_";
    public final static String DISABLE_USER_ = "DISABLE_USER_";

    public void insertGroupByOwerId(Integer playerId, Integer insertKey ,String config, ICache cache,String groupName) {

        JSONObject paretJson = new JSONObject();
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("userId",cache.hget(Constants.PLAYER_+playerId,"userId"));
        jsonObject.put("nickName",cache.hget(Constants.PLAYER_+playerId,"nickName"));
        jsonObject.put("photoUrl",cache.hget(Constants.PLAYER_+playerId,"photoUrl"));


        JSONArray objects = new JSONArray();
        objects.add(jsonObject);

        paretJson.put("players",objects);
        paretJson.put("owerId",playerId);
        paretJson.put("config",config);
        paretJson.put("playerCount",objects.size());
        paretJson.put("groupName",groupName);

        cache.hset(Constants.GROUP_PLAYER,insertKey.toString(),paretJson.toJSONString());

    }

    public void insertGroup(String post_key, Integer playerId, Integer insertKey, ICache cache) throws Exception {

        JSONObject jsonObject = new JSONObject();
        String userId = cache.hget(Constants.PLAYER_ + playerId, "userId");
        if (StringUtil.isEmpty(userId)) {
            playerCacheController.queryPlayerDetail(Long.parseLong(playerId+""),cache,false, false);
        }
        jsonObject.put("userId",cache.hget(Constants.PLAYER_+playerId,"userId"));
        jsonObject.put("nickName",cache.hget(Constants.PLAYER_+playerId,"nickName"));
        jsonObject.put("photoUrl",cache.hget(Constants.PLAYER_+playerId,"photoUrl"));

        String hget = cache.hget(Constants.GROUP_PLAYER + post_key, insertKey.toString());
        JSONObject jsonObject1 = JSONObject.parseObject(hget);
        JSONArray players = jsonObject1.getJSONArray("players");
        if (players == null || players.isEmpty()) {
            players = new JSONArray();
            players.add(jsonObject);
            jsonObject1.put("players",players);
        }else {
            players.add(jsonObject);
        }
        jsonObject1.put("players",players);
        cache.hset(Constants.GROUP_PLAYER + post_key,insertKey.toString(),jsonObject1.toJSONString());

    }


    public void insertPlayerGroup(Integer playerId, Integer insertKey,String groupName,ICache cache) {

        //群头像用群主的头像
        JSONObject jsonObject = new JSONObject();

        String hget = cache.hget(Constants.GROUP_PLAYER, insertKey.toString());
        Integer owerId = JSONObject.parseObject(hget).getInteger("owerId");

        jsonObject.put("owerUrl",cache.hget(Constants.PLAYER_+owerId,Constants.PHOTOURL));
        jsonObject.put("groupName",groupName);
        jsonObject.put("owerId",owerId);

        cache.hset(Constants.PLAYER_GROUP_+playerId,insertKey.toString(),jsonObject.toJSONString());
    }
    public void insertPlayerGroup(Integer playerId, Integer insertKey,String groupName,String config,ICache cache) {

        //群头像用群主的头像
        JSONObject jsonObject = new JSONObject();

        String hget = cache.hget(Constants.GROUP_PLAYER, insertKey.toString());
        if (StringUtil.isEmpty(hget)) {
//            insertGroupByOwerId(playerId,insertKey ,config,cache,groupName);
//            hget = cache.hget(Constants.GROUP_PLAYER, insertKey.toString());
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"网络异常，请稍后再试！！");
        }


        Integer owerId = JSONObject.parseObject(hget).getInteger("owerId");

        jsonObject.put("owerUrl",cache.hget(Constants.PLAYER_+owerId,Constants.PHOTOURL));
        jsonObject.put("groupName",groupName);
        jsonObject.put("owerId",owerId);
        jsonObject.put("config",config);
        jsonObject.put("playerCount",1);

        cache.hset(Constants.PLAYER_GROUP_+playerId,insertKey.toString(),jsonObject.toJSONString());
    }

    public JSONObject getMessageForNameAndHeadUrlAndUid(Integer playerId,ICache cache) {

        JSONObject jsonObject = new JSONObject();
        String userId = cache.hget(Constants.PLAYER_ + playerId, "userId");
        String nickName = cache.hget(Constants.PLAYER_ + playerId, "nickName");
        String photoUrl = cache.hget(Constants.PLAYER_ + playerId, "photoUrl");

        if (StringUtil.isEmpty(userId)) {
            TUser tUser = userMapper.findById(Long.parseLong(playerId + ""));
            if (StringUtil.isEmpty(tUser)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"用户不存在");
            }
            userId = tUser.getUserid() + "";
            nickName = tUser.getNickName();
            photoUrl = tUser.getSmallIcon();
        }

        jsonObject.put("userId",userId);
        jsonObject.put("nickName",nickName);
        jsonObject.put("photoUrl",photoUrl);

        return jsonObject;
    }

    public JSONObject getGroupInfoByOwerId(Integer owerId,Integer groupId, ICache cache) {

        String hget = cache.hget(Constants.PLAYER_GROUP_ + owerId, groupId.toString());
        return JSONObject.parseObject(hget);
    }

    public void addGroupPlayer(Integer playerId, Integer groupId, ICache cache) {
        String hget = cache.hget(Constants.GROUP_PLAYER, groupId.toString());
        JSONObject jsonObject = JSONObject.parseObject(hget);

        JSONObject playerInfo = getMessageForNameAndHeadUrlAndUid(playerId, cache);

        jsonObject.getJSONArray("players").add(playerInfo);
        Integer playerCount = jsonObject.getInteger("playerCount");
        if (StringUtil.isNotEmpty(playerCount)) {
            playerCount = playerCount+1;
        }else {
            playerCount = 1;
        }
        jsonObject.put("playerCount",playerCount);


        cache.hset(Constants.GROUP_PLAYER,groupId.toString(),jsonObject.toJSONString());

    }

    public JSONObject getGroupInfoByGroupId(ICache cache, Integer groupId) {
        String hget = cache.hget(Constants.GROUP_PLAYER, groupId + "");
        if (StringUtil.isNotEmpty(hget)) {
            return JSONObject.parseObject(hget);
        }else {
//            如果没有直接查询数据库直接插入redis中
            JSONObject groupPlayerJson = new JSONObject();

            TGroupPlayer groupPlayer = groupPlayerMapper.findById(groupId);
            groupPlayerJson.put("config",groupPlayer.getConfig());
            groupPlayerJson.put("owerId",groupPlayer.getOwerId());
            groupPlayerJson.put("groupName",groupPlayer.getGroupName());
            List<TPlayerGroup> tPlayerGroups = playerGroupMapper.selectByGroupId(groupId, null, null, null, null);
            JSONArray objects = new JSONArray();
            for (TPlayerGroup pg : tPlayerGroups) {
                JSONObject ljson = new JSONObject();
                TUser tUser = userMapper.findById(Long.parseLong(pg.getPlayerId()+""));
                ljson.put("nickName",tUser.getNickName());
                ljson.put("photoUrl",tUser.getSmallIcon());
                ljson.put("userId",tUser.getUserid());
                objects.add(ljson);
            }
            groupPlayerJson.put("players",objects);
            groupPlayerJson.put("playerCount",tPlayerGroups.size());

            cache.hset(Constants.GROUP_PLAYER,groupId+"",groupPlayerJson.toJSONString());

            return groupPlayerJson;
        }
    }

    public int queryMinJoinCoins(String groupId) {
        ICache cache = null;

        try {
            cache = CacheManager.getCache();
            String min = cache.hget(Constants.Min_Join_FreeGame_Coins, groupId);
            if (StringUtil.isEmpty(min)) {

                TGroupPlayer tGroupPlayer = groupPlayerMapper.findById(Integer.parseInt(groupId));
                cache.hset(Constants.Min_Join_FreeGame_Coins, groupId,tGroupPlayer.getStrengthLimit()+"");
                return tGroupPlayer.getStrengthLimit();
            }

            return Integer.parseInt(min);

        }catch (Exception e ) {
            return -1;
        }finally {
            if ( null != cache) {
                CacheManager.releaseCache(cache);
            }
        }

    }

    public TPlayerGroup queryPlayerClubInfo(Integer groupId,Long playerId) {

        try {

            TPlayerGroup tPlayerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(Integer.parseInt(playerId + ""), groupId);

            return tPlayerGroup;
        }catch (Exception e ) {
            return null;
        }finally {

        }

    }

    /**
     * 搜索上级合伙人集合
     * @param cache
     * @param groupId
     * @param uid
     * @return
     */
    public List<Integer> queryHehuorenList(ICache cache,Integer groupId,Integer uid) {

        List<Integer> shangjiList = new ArrayList<Integer>();

        Integer roleType = queryRoleType(cache, groupId, uid);
        if (roleType == PlayerTypeEnum.PARTNER) {
            shangjiList.add(uid);
        }

        Integer shangjiId = queryShangjiId(cache,groupId,uid);
        int i = 0;
        while (!StringUtil.isEmpty(shangjiId) && shangjiId > 0 ) {

            shangjiList.add(shangjiId);
            shangjiId = queryShangjiId(cache,groupId,shangjiId);
            i++;
            if (i > 50) {
                break;
            }
        }

        return shangjiList;

    }

    /**
     * 搜索上级ID
     * @param cache
     * @param groupId
     * @param uid
     * @return
     */
    public Integer queryShangjiId(ICache cache,Integer groupId,Integer uid) {

        if (StringUtil.isEmpty(groupId) || StringUtil.isEmpty(uid)) {
            return -1;
        }

        String shangjiId = cache.hget(Constants.Group_Uid_Shangji_Id + groupId,uid + "");
        if (StringUtil.isEmpty(shangjiId)) {
            TPlayerGroup tpg = playerGroupMapper.selectByPlayerIdAndGroupId(uid,groupId);
            if (StringUtil.isEmpty(tpg)) {
                return -1;
            }else {

                TPlayerGroup tpgUp = playerGroupMapper.selectByPlayerIdAndGroupId(tpg.getUpPlayerId(),groupId);
                if (!StringUtil.isEmpty(tpgUp) && tpgUp.getPlayerType() == PlayerTypeEnum.PARTNER) {
                    cache.hset(Constants.Group_Uid_Shangji_Id + groupId,uid + "",tpg.getUpPlayerId() + "");
                    return tpg.getUpPlayerId();
                }

            }
            return -1;
        }

        return Integer.parseInt(shangjiId);
    }

    //获取合伙人的分成比例
    public Integer queryMyCommission(ICache cache,Integer groupId,Integer uid) {

        if (StringUtil.isEmpty(groupId) || StringUtil.isEmpty(uid)) {
            return 0;
        }

        String myCommission = cache.hget(Constants.Group_Hehuoren_Commission + groupId,uid + "");
        if (StringUtil.isEmpty(myCommission)) {

            TPlayerGroup tpg = playerGroupMapper.selectByPlayerIdAndGroupId(uid,groupId);
            if (StringUtil.isEmpty(tpg)) {
                return 0;
            }

            cache.hset(Constants.Group_Hehuoren_Commission + groupId,uid + "",(int)tpg.getBonus().doubleValue() + "");
            return (int)tpg.getBonus().doubleValue();
        }

        return Integer.parseInt(myCommission);
    }

    public void removeRoleType(ICache cache,Integer groupId, Integer playerId ) {

        cache.hdel(ClubConstants.Club2UserRoleType + playerId, groupId + "");

    }

    /**
     * 搜索玩家类型
     * @param cache redis
     * @param groupId 小组id
     * @param playerId 玩家id
     * @return
     */
    public Integer queryRoleType (ICache cache, Integer groupId, Integer playerId) {

        String roleType = cache.hget(ClubConstants.Club2UserRoleType + playerId, groupId + "");

        if (StringUtil.isEmpty(roleType)) {
            TPlayerGroup tPlayerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            if (!StringUtil.isEmpty(tPlayerGroup)) {
                roleType = tPlayerGroup.getPlayerType() + "";
                cache.hset(ClubConstants.Club2UserRoleType + playerId,groupId + "" , roleType);
            }else {
                roleType = "-1";
            }
        }
        return Integer.parseInt(roleType);
    }

    public boolean isManager(ICache cache, Integer groupId, Integer playerId) {


        Boolean isManager = cache.sismember(ClubConstants.Club2UserIsManagerSet + groupId, playerId + "");

       return isManager;

    }

    public Long setManager(ICache cache, Integer groupId, Integer playerId) {


        Long addCount = cache.sadd(ClubConstants.Club2UserIsManagerSet + groupId, playerId + "");

       return addCount;

    }

    public Long removeManager(ICache cache, Integer groupId, Integer playerId) {


        Long removeCount = cache.srem(ClubConstants.Club2UserIsManagerSet + groupId, playerId + "");

        return removeCount;

    }

    public String queryClubCode(ICache cache, Integer groupId, Integer playerId) {

        String inviteCode = cache.hget(ClubConstants.Club2InviteCode + playerId, groupId + "");

        if (StringUtil.isEmpty(inviteCode)) {

            TPlayerGroup tPlayerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            if (!StringUtil.isEmpty(tPlayerGroup)) {
                if (tPlayerGroup.getPlayerType() != PlayerTypeEnum.MEMBER) {
                    inviteCode = tPlayerGroup.getInviteCode();
                    cache.hset(ClubConstants.Club2InviteCode + playerId,groupId + "" , inviteCode);
                }else {
                    //如果是普通玩家,则用上级的邀请码
                    TPlayerGroup upPlayer = playerGroupMapper.selectByPlayerIdAndGroupId(tPlayerGroup.getUpPlayerId(), groupId);
                    if (!StringUtil.isEmpty(upPlayer)) {
                        inviteCode = upPlayer.getInviteCode();
                        cache.hset(ClubConstants.Club2InviteCode + playerId,groupId + "" , inviteCode);
                    }
                }

            }

        }

        return inviteCode;
    }

    public String getClubInviteCode(ICache cache) {

        String inviteCode = RadomUtil.getRadomNum(8);
        Boolean flag = cache.sismember(ClubConstants.Club_Invite_Code_Set, inviteCode);

        int i = 0;
        while (!flag) {
            inviteCode = RadomUtil.getRadomNum(8);
            flag = cache.sismember(ClubConstants.Club_Invite_Code_Set, inviteCode);
            //如果不存在
            if (!flag) {
                cache.sadd(ClubConstants.Club_Invite_Code_Set,inviteCode);
                break;
            }

            if (i >= 50 ) {
                inviteCode = "";
                break;
            }
            i++;
        }
        if (StringUtil.isEmpty(inviteCode)) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "系统繁忙,请稍后再试");
        }

        return inviteCode;
    }

    public void deleteRedisGroupPlayer(Integer playerId, Integer groupId, ICache cache) {

        TPlayerGroup tPlayerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
        Integer playerType = StringUtil.isEmpty(tPlayerGroup) ? null : tPlayerGroup.getPlayerType();

        playerGroupMapper.deleteByPlayerIdAndGroupId(playerId, groupId);

        cache.hdel(Constants.PLAYER_GROUP_+playerId,groupId.toString());
        cache.hdel(ClubConstants.Club2InviteCode+playerId,groupId.toString());

        //合伙人清除上下级关系
        if (playerType == PlayerTypeEnum.PARTNER ) {

            List<TPlayerGroup> sonList = playerGroupMapper.selectMySonList(groupId,playerId,null,null,null);
            for (TPlayerGroup son : sonList) {
                cache.hdel(ClubConstants.Club2InviteCode+son.getPlayerId(),groupId.toString());
                cache.hdel(Constants.Group_Uid_Shangji_Id + groupId,son.getPlayerId() + "");
            }
            //将下级玩家全部都归到群主身上
            TGroupPlayer tGroupPlayer = groupPlayerMapper.findById(groupId);
            if (!StringUtil.isEmpty(tGroupPlayer)) {
                playerGroupMapper.updateUpPlayerId(groupId,playerId,tGroupPlayer.getOwerId());
            }
            removeHhr(playerId,groupId,cache);
        }
        //清除自己的上级关系
        cache.hdel(Constants.Group_Uid_Shangji_Id + groupId,playerId + "");
        removeManager(cache, groupId, playerId);
    }

    public void removeHhr(Integer playerId, Integer groupId, ICache cache) {

        cache.hdel(ClubConstants.Club2InviteCode+playerId,groupId.toString());
        cache.hdel(Constants.Group_Hehuoren_Commission + groupId, playerId + "");
        cache.hdel(ClubConstants.Club2UserRoleType + playerId, groupId + "");
    }

    public String getDefaultClubConfig() {

        JSONObject config = new JSONObject();

        config.put(ClubConstant.is_config,0);
        config.put(ClubConstant.SelectGameConfig,"[]");
        config.put(ClubConstant.is_invitation,1);
        config.put(ClubConstant.show_ranking,1);
        config.put(ClubConstant.show_member,0);
        config.put(ClubConstant.show_record,1);
        config.put(ClubConstant.is_chat,1);
        config.put(ClubConstant.exchange_status,0);
        config.put(ClubConstant.is_agree,0);
        config.put(ClubConstant.club_status,1);
        config.put(ClubConstant.show_table,0);
        config.put(ClubConstant.auto_exit_club,1);

        return config.toJSONString();

    }

    /**
     * 1 redis 2 传进的积分 3 数据库的积分
     * 获取用户积分
     * @param groupId
     * @param playerId
     * @param point   如果积分传进来了,就不用查了
     * @return
     */
    public Double queryClubPoint(Integer groupId, Integer playerId, Double point) {

        if (StringUtil.isEmpty(groupId) || StringUtil.isEmpty(playerId) ) {
            return 0d;
        }

        RedisUtil ru = RedisUtil.getRu();
        String key = GROUP_USER_CHIPS_ + groupId;

        String pointStr = ru.hget(key, playerId+"");

        if (!StringUtil.isEmpty(pointStr) ) {

            return Double.parseDouble(pointStr);

        } else if (!StringUtil.isEmpty(point) ) {

            ru.hset(key,playerId+"", point.intValue() + "");
            return point;

        } else {

            TPlayerGroup tPlayerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            if (!StringUtil.isEmpty(tPlayerGroup) ) {
                ru.hset(key,playerId+"", tPlayerGroup.getPointCount().intValue()+"");
                return tPlayerGroup.getPointCount();
            } else {
                // 如果数据库也没有记录，初始化积分为9999并保存到Redis
                ru.hset(key, playerId + "", "9999");
                return 0d;
            }

        }
    }

    public void updateClubPoint(Integer groupId, Integer playerId, Integer hincrValue) {

        pointLog.info("updateClubPoint-->" + groupId + "--" + playerId + "--" + hincrValue);

        RedisUtil ru = RedisUtil.getRu();
        String key = GROUP_USER_CHIPS_ + groupId;

        Boolean ex = ru.hexists(key, playerId + "");
        if (!ex ) {
            queryClubPoint(groupId,playerId, null);
        }
        ru.hincrby(key, playerId + "", Long.parseLong(hincrValue+""));

    }

    public Integer getClubBaiRenPool(Integer groupId, ICache cache) {

        RedisUtil ru = RedisUtil.getRu();

        String pool = ru.hget("CLUB_POOL_CHIPS", groupId + "");
        if (!StringUtil.isEmpty(pool) ) {
            return Integer.parseInt(pool);
        }

        return 0;
    }

    public Long hinClubBaiRenPool(Integer groupId, Long tixianCount ) {

        RedisUtil ru = RedisUtil.getRu();
        return ru.hincrby("CLUB_POOL_CHIPS", groupId + "", -tixianCount);

    }

    public Integer queryUserClubStatus(Integer groupId, int playerId) {

        RedisUtil ru = RedisUtil.getRu();

        String status = ru.hget(DISABLE_USER_ + groupId, playerId + "");
        if (!StringUtil.isEmpty(status) ) {
            return Integer.parseInt(status);
        }

        return 0;
    }

    /**
     * 搜索玩家积分池
     * @param uid
     * @param usersChipMap
     * @param uid2UpIdMap
     * @param uid2RepPointMap
     * @return
     */
    public Long queryMySonPool(Integer uid, Map<String, String> usersChipMap, Map<Integer, Integer> uid2UpIdMap, Map<Integer, Integer> uid2RepPointMap) {

        List<Integer> sonList = getMySons(uid2UpIdMap, uid);
        Long result = 0l;

        for (int i = 0; i < sonList.size(); i++) {
            //积分
            String point = usersChipMap.get((sonList.get(i) + ""));
            if (!StringUtil.isEmpty(point) ) {
                result += Long.parseLong(point);
            }
            //仓库
            Integer repPoint = uid2RepPointMap.get(sonList.get(i));
            if (!StringUtil.isEmpty(repPoint) && repPoint > 0) {
                result += Long.parseLong(repPoint+"");
            }

        }

        return result;

    }

    /**
     * 检查是否超过阈值
     * @param cache
     * @param groupId
     * @param uid
     * @return
     */
    public boolean isSurpassThresholdValue(ICache cache, Integer groupId, Integer uid) {
        log.debug ("创建组局："+",groupId=" + groupId + ",uid:" + uid);
        List<Integer> hehuorenList = queryHehuorenList(cache, groupId, uid);
        log.debug ("合伙人集合="+"hehuorenList:" + hehuorenList);
        if (hehuorenList == null || hehuorenList.size() == 0) {
            return false;
        }

        RedisUtil ru = RedisUtil.getRu();
        Map<String, String> usersChipMap = ru.hgetall("GROUP_USER_CHIPS_" + groupId);

        log.debug ("玩家积分Map="+"usersChipMap:" + usersChipMap);
        Map<Integer, Integer> uid2UpIdMap = new HashMap<Integer, Integer>();
        Map<Integer, Integer> uid2RepPointMap = new HashMap<Integer, Integer>();
        //玩家的上级合伙人
        List<TPlayerGroup> allList = playerGroupMapper.selctAllList(groupId);
        for (TPlayerGroup li : allList) {
            uid2UpIdMap.put(li.getPlayerId(), li.getUpPlayerId());
        }

        log.debug ("上级合伙人Map="+"uid2UpIdMap:" + uid2UpIdMap);
        //玩家存储库的余额
        List<TPlayerGroup> repositoryList = playerGroupMapper.selectClubRepositoryPoint(groupId);
        for (TPlayerGroup repTpg : repositoryList) {
            uid2RepPointMap.put(repTpg.getPlayerId(), repTpg.getRepositoryPoint());
        }

        log.debug ("玩家保险柜的余额Map="+"uid2RepPointMap:" + uid2RepPointMap);
        RedisUtil3 ru3 = RedisUtil3.getRu();
        for (Integer hId: hehuorenList ) {
            String valuesStr = ru3.hget(ClubConstant.CLUB_PARTNER_THRESHOLD_VALUE_ + groupId, hId + "");
            log.debug (hId+"的预警分="+"valuesStr:" + valuesStr);
            Long values = valuesStr == null ? 0 : Long.parseLong(valuesStr);
            if (values <= 0L) {
                continue;
            }
            Long sonPool = queryMySonPool(hId, usersChipMap, uid2UpIdMap, uid2RepPointMap);
            log.debug (hId+"的玩家积分池="+"sonPool:" + sonPool);
            if (sonPool <= values - 10000) {
                return true;
            }
        }
        return false;
    }

    private List<Integer> getMySons(Map<Integer, Integer> uid2UpIdMap, Integer uid) {

        List<Integer> sonArr = new ArrayList<Integer>();
        sonArr.add(uid);

        for (Map.Entry<Integer, Integer> entry : uid2UpIdMap.entrySet()) {

            if ((entry.getKey()+"").equals(uid+"")) {
                continue;
            }

            if ((entry.getValue()+"").equals(uid+"")) {
                List<Integer> aesSon = getMySons(uid2UpIdMap, entry.getKey());
                sonArr.addAll(aesSon);
            }

        }

        return sonArr;
    }
}
