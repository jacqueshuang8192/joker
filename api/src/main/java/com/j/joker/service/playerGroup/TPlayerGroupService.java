package com.j.joker.service.playerGroup;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.beanUtil.MapUtils;
import com.j.joker.core.util.ConfigUtil;
import com.j.joker.core.util.RedisUtil;
import com.j.joker.core.util.StringUtil;
import com.j.joker.cache.CacheManager;
import com.j.joker.cache.ICache;
import com.j.joker.cache.controller.BaseCacheController;
import com.j.joker.cache.controller.GroupPlayerCacheController;
import com.j.joker.constants.ClubConstants;
import com.j.joker.constants.Constants;
import com.j.joker.enums.PlayerTypeEnum;
import com.j.joker.mapper.TGroupPlayerMapper;
import com.j.joker.mapper.TPlayerGroupMapper;
import com.j.joker.model.*;
import com.j.joker.utils.GameServerUtil;
import com.j.joker.utils.InfServerException;
import com.j.joker.utils.QrCodeUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.DataInputStream;
import java.io.InputStream;
import java.net.URL;
import java.util.*;

/**
 * Create by Mars on 2019/5/27 20:53
 */
@Service
public class TPlayerGroupService {

    @Autowired
    private TPlayerGroupMapper playerGroupMapper;
    @Autowired
    private TGroupPlayerMapper groupPlayerMapper;
    @Autowired
    private GroupPlayerCacheController groupPlayerCacheController;
    @Autowired
    private TGroupGameconfigService gameconfigService;
    @Autowired
    private BaseCacheController baseCacheController;

    public void addPlayerGroup(Integer playerId1, Integer playerId2, Integer groupId, Double bonus) throws InfServerException, Exception {

        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            // 分红比例不能大于100%
            if(bonus > 100){
                throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR, "分红比例不能大于100%!!");
            }
            // 判断邀请人是不是群主或合伙人，群主合伙人才能邀请合伙人
            TGroupPlayer groupPlayer = groupPlayerMapper.findById(groupId);
            Integer owerId = groupPlayer.getOwerId();
            Integer p1PlayerType = playerGroupMapper.getPlayTypeByGroupIdAndPlayerId(groupId, playerId1);
            // 判断是不是普通成员，普通成员不能添加合伙人
            if (p1PlayerType == PlayerTypeEnum.MEMBER){
                throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR, "群主不允许成员邀请其他玩家,请联系群主申请!!");
            }
            // 不能邀请群主作为合伙人
            if(owerId.equals(playerId2)){
                throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR, "不能邀请群主作为合伙人!!");
            }
            Integer p2PlayerType = playerGroupMapper.getPlayTypeByGroupIdAndPlayerId(groupId, playerId2);
            TPlayerGroup p2Player = playerGroupMapper.selectByPlayerIdAndGroupId(playerId2, groupId);

            if (StringUtil.isEmpty(p2PlayerType) || StringUtil.isEmpty(p2Player)) {
                throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR, "请先邀请玩家加入联盟!!");
            }


            if (p1PlayerType == PlayerTypeEnum.PARTNER && !playerId1.equals(p2Player.getUpPlayerId())) {
                throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR, "该玩家不是您邀请过来的玩家!!");
            }

            // 不允许重复添加合伙人
            if(p2PlayerType != null && p2PlayerType == PlayerTypeEnum.PARTNER){
                throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR, "不允许重复添加合伙人!!");
            }
            String inviteCode = groupPlayerCacheController.getClubInviteCode(cache);

            if(p2PlayerType == null){
                // 不在联盟，加进联盟,设置为合伙人
                TPlayerGroup vo = new TPlayerGroup();
                vo.setGroupId(groupId);
                vo.setPlayerId(playerId2);
                vo.setUpPlayerId(playerId1);
                vo.setCreateTime(new Date());
                vo.setPlayerType(PlayerTypeEnum.PARTNER);
                vo.setBonus(bonus);
                vo.setInviteCode(inviteCode);
                vo.setBonus(0d);
                vo.setIsRobot(0);
                playerGroupMapper.add(vo);

            }else{
                // 在联盟，就设置成合伙人 | 如果是合伙人,则有邀请码
                playerGroupMapper.setPlayerType(groupId, playerId2, PlayerTypeEnum.PARTNER,bonus,inviteCode);
                groupPlayerCacheController.removeRoleType(cache,groupId,playerId2);
            }
            cache.hset(ClubConstants.Club2InviteCode + playerId2,groupId + "",inviteCode);
            cache.hdel(Constants.Group_Hehuoren_Commission + groupId,playerId2 + "");

            JSONObject jo = new JSONObject();
            jo.put("groupId",groupId);
            jo.put("type","addHhr");
            GameServerUtil.notice2HallPublice(Long.parseLong(playerId2 + ""),jo);

        }catch (Exception e ) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }

    }
    public void setBonus(Integer groupId, Integer playerId1, Integer playerId2, Double bonus) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            TPlayerGroup playerGroup = playerGroupMapper.getPlayerGroupByGroupIdAndPlayerId(groupId, playerId2);
            if(playerGroup == null){
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "玩家不在当前群组，设置失败！");
            }
            if(!playerGroup.getUpPlayerId().equals(playerId1)){
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "不能越权设置，设置失败！");
            }
            if(playerGroup.getPlayerType() == PlayerTypeEnum.MEMBER){
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "普通成员不能设置分红!");
            }
            TPlayerGroup playerGroup1 = playerGroupMapper.getPlayerGroupByGroupIdAndPlayerId(groupId, playerId1);
            if (playerGroup1.getBonus() < bonus.doubleValue()) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "下级的比例不可以高于" + playerGroup1.getBonus() + "!!");
            }
            // 如果设置的分红跟之前一致，不需要执行修改
            if(playerGroup.getBonus() != bonus) {
                cache.hdel(Constants.Group_Hehuoren_Commission + groupId,playerId2 + "");
                playerGroupMapper.setBonus(groupId, playerId1, playerId2, bonus);
            }
        }catch (Exception e ) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }

    }

    public void deletePlayerGroup(Integer groupId, Integer playerId1, Integer playerId2) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();

            if(playerId1 == playerId2){
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "不能把自己移除群！");
            }
            Integer playerType1 = playerGroupMapper.getPlayTypeByGroupIdAndPlayerId(groupId, playerId1);
            if(playerType1 != PlayerTypeEnum.MASTER && playerType1 != PlayerTypeEnum.PARTNER){
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "没有移除玩家的权限！");
            }
            TPlayerGroup tPlayerGroup = playerGroupMapper.selectByPlayerIdAndGroupId(playerId2, groupId);
            // 只要还有积分就不能踢
            Double playerPoint = groupPlayerCacheController.queryClubPoint(groupId, playerId2, null);
            if(playerPoint >= 100){
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "玩家还有积分未结算！");
            }
            if (tPlayerGroup.getRepositoryPoint() >= 100) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"该玩家仓库还有积分,不允许删除");
            }

            if(playerType1 == PlayerTypeEnum.MASTER){ // 踢人者是群主

            }else{ // 踢人者是合伙人
                // 如果不是自己邀请进来的，不能踢
                if(tPlayerGroup.getUpPlayerId() != playerId1){
                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "没有移除这个玩家的权限！");
                }
            }
            groupPlayerCacheController.deleteRedisGroupPlayer(playerId2,groupId,cache);

            JSONObject jo = new JSONObject();
            jo.put("groupId",groupId);
            jo.put("type","delMember");
            GameServerUtil.notice2HallPublice(Long.parseLong(playerId2 + ""),jo);

        }catch (Exception e ) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }

    }

    public List<TGroupGameconfig> selectGameConfig(Integer groupId, Integer playerId, Integer configId, Integer level, Integer gameType) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();

            Map<String, String> configs = cache.hgetAll("GroupGameConfig_" + groupId);
            if (StringUtil.isEmpty(configs) || configs.isEmpty()) {

                configs = new HashMap<String, String>();
                List<TGroupGameconfig> tGroupGameconfigs = gameconfigService.selectAll(groupId, null, null);
                for (TGroupGameconfig config : tGroupGameconfigs) {
                    configs.put(config.getId()+"", JSON.toJSONString(config));
                }
                if (!configs.isEmpty()) {
                    cache.hmset("GroupGameConfig_" + groupId, configs);
                }
            }

            List<TGroupGameconfig> result = new ArrayList<TGroupGameconfig>();
            //一个玩法
            if (!StringUtil.isEmpty(configId)) {

                String configOne = configs.get(configId + "");
                if (!StringUtil.isEmpty(configOne)) {
                    TGroupGameconfig gameconfig = JSON.parseObject(configOne, TGroupGameconfig.class);
                    if (!StringUtil.isEmpty(gameconfig)) {
                        result.add(gameconfig);
                    }
                }
                return result;
            }
            //多个玩法
            for (Map.Entry<String, String > entry : configs.entrySet() ) {

                TGroupGameconfig gameconfig = JSON.parseObject(entry.getValue(), TGroupGameconfig.class);
                if (!StringUtil.isEmpty(gameconfig) ) {
                    if (!StringUtil.isEmpty(gameType)) {
                        if (gameType.equals(gameconfig.getGameType())) {
                            result.add(gameconfig);
                        }
                    }else if (!StringUtil.isEmpty(level )) {
                        if (level.equals(gameconfig.getLevel())) {
                            result.add(gameconfig);
                        }
                    }else {
                        result.add(gameconfig);
                    }
                }
            }

            return result;
        }catch (Exception e ) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }
    }

    public void updateGameConfig(Integer groupId, Integer playerId, Integer configId, String name, String config) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();

            JSONObject group = JSONObject.parseObject(cache.hget(Constants.GROUP_PLAYER, groupId.toString()));
            Integer owerId1 = group.getInteger("owerId");
            if (!playerId.equals(owerId1)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"您不是盟主,不允许修改玩法");
            }

            gameconfigService.updateOne(configId, name, config, null );

            String hget = cache.hget("GroupGameConfig_" + groupId, configId + "");
            TGroupGameconfig gameconfig = gameconfigService.selectOne(configId);
            if (!StringUtil.isEmpty(hget)) {
                if (!StringUtil.isEmpty(gameconfig)) {
                    cache.hset("GroupGameConfig_" + groupId, configId + "", JSON.toJSONString(gameconfig));
                }
            }

            //通知游戏服
            if (!StringUtil.isEmpty(gameconfig)) {
                GameServerUtil.notice2HallAboutCluConfig(groupId,configId,gameconfig.getGameType(),gameconfig.getConfig(),Constants.Club_GameConfig_Update,gameconfig.getName());
            }

        }catch (Exception e ) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }
    }

    public void delGameConfig(Integer groupId, Integer playerId, Integer configId) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();

            JSONObject group = JSONObject.parseObject(cache.hget(Constants.GROUP_PLAYER, groupId.toString()));
            Integer owerId1 = group.getInteger("owerId");
            if (!playerId.equals(owerId1)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"您不是盟主,不允许删除玩法");
            }
            TGroupGameconfig gameconfig = gameconfigService.selectOne(configId);

            gameconfigService.delOne(configId);
            cache.hdel("GroupGameConfig_" + groupId, configId + "");
            if (!StringUtil.isEmpty(gameconfig)) {
                GameServerUtil.notice2HallAboutCluConfig(groupId, configId, gameconfig.getGameType(), "", Constants.Club_GameConfig_Del,"");
            }
        }catch (Exception e ) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }
    }

    public Map<String,Integer> addGameConfig(Integer groupId, Integer playerId, Integer level, String name, String config) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();

            JSONObject group = JSONObject.parseObject(cache.hget(Constants.GROUP_PLAYER, groupId.toString()));
            Integer owerId1 = group.getInteger("owerId");
            if (!playerId.equals(owerId1)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"您不是盟主,不允许添加玩法");
            }
            TGame g = baseCacheController.queryGameById(Long.parseLong(level + ""), cache);

            Integer configCount = gameconfigService.selectConfigCountByGameType(g.getGameType(),groupId);
            String maxConfigStr = ConfigUtil.get("maxGameConfigCount");
            Integer maxConfigCount = 8;
            if (!StringUtil.isEmpty(maxConfigStr)) {
                maxConfigCount = Integer.parseInt(maxConfigStr );
            }

            if (!StringUtil.isEmpty(configCount) && configCount >= maxConfigCount ) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"最多可以添加" + maxConfigCount + "种玩法");
            }

            TGroupGameconfig gameconfig = gameconfigService.addOne(groupId, level,Integer.parseInt(g.getGameType()), name, config);

            cache.hset("GroupGameConfig_" + groupId, gameconfig.getId() + "", JSON.toJSONString(gameconfig));

            Map<String, Integer> result = new HashMap<String, Integer>();
            result.put("configId",gameconfig.getId());
            result.put("gameType",gameconfig.getGameType());

            if (!StringUtil.isEmpty(gameconfig)) {
                GameServerUtil.notice2HallAboutCluConfig(groupId, gameconfig.getId(), gameconfig.getGameType(), gameconfig.getConfig(), Constants.Club_GameConfig_Add,gameconfig.getName());
            }

            return result;

        }catch (Exception e ) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }
    }

    public Map<String, Object> getClubPointRanking(Integer groupId, Integer playerId, Integer currentPage, Integer pageSize) throws Exception {

        ICache cache = null;
        try {

            cache = CacheManager.getCache();
            RedisUtil ru = RedisUtil.getRu();

            String key = "GROUP_USER_CHIPS_" + groupId;
            Map<String, String> hgetall = ru.hgetall(key);

            Map<Integer, Integer> newAll = new HashMap<Integer, Integer>();
            for (Map.Entry<String, String> entry : hgetall.entrySet()) {
                newAll.put(Integer.parseInt(entry.getKey()), Integer.parseInt(entry.getValue()));
            }


            Map<Integer, Integer> sortMap = MapUtils.sortByValue(newAll);

            JSONArray list = new JSONArray();
            int i = 0;
            Integer startIndex = (currentPage-1) * pageSize;
            for (Map.Entry<Integer, Integer> entry : sortMap.entrySet()) {
                if ( (startIndex + pageSize) <= i) {
                    break;
                }

                if (startIndex <= i) {
                    JSONObject json = new JSONObject();
                    json.put("dayingjiaCount", 0);
                    json.put("groupId", groupId);
                    json.put("nickName",baseCacheController.queryUserNickName(cache,entry.getKey()));
                    json.put("photo",baseCacheController.queryUserPhoto(cache,entry.getKey()));
                    json.put("playerId", entry.getKey());
                    json.put("pointCount", entry.getValue());
                    list.add(json);
                }

                i++;
            }


//            cache = CacheManager.getCache();
//
//            Integer startIndex = (currentPage-1) * pageSize;
//            List<TPlayerGroup> list = playerGroupMapper.getClubPointRanking(groupId,playerId,startIndex,pageSize);
//            Integer count = playerGroupMapper.getClubPointRankingCount(groupId,playerId);
//
//            for (TPlayerGroup tpg : list) {
//                tpg.setNickName(baseCacheController.queryUserNickName(cache,tpg.getPlayerId()));
//                tpg.setPhoto(baseCacheController.queryUserPhoto(cache,tpg.getPlayerId()));
//            }

            Map<String , Object> map = new HashMap<String, Object>();
            map.put("list",list);
            map.put("listCount",hgetall.size());

            return map;

        }catch (Exception e ) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }

    }

    public void removeHhr(Integer ownerId, Integer playerId, Integer groupId) throws Exception {

        ICache cache = null;
        try {
            cache = CacheManager.getCache();

            TPlayerGroup owner = playerGroupMapper.selectByPlayerIdAndGroupId(ownerId, groupId);
            TPlayerGroup player = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);

            if (StringUtil.isEmpty(player) || player.getPlayerType() != PlayerTypeEnum.PARTNER) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"玩家不存在或者不是合伙人");
            }

            if (StringUtil.isEmpty(owner) || owner.getPlayerType() != PlayerTypeEnum.MASTER) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"成员数据异常");
            }

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

            JSONObject jo = new JSONObject();
            jo.put("groupId",groupId);
            jo.put("type","removeHhr");
            GameServerUtil.notice2HallPublice(Long.parseLong(playerId + ""),jo);
            playerGroupMapper.setPlayerType(groupId,playerId,PlayerTypeEnum.MEMBER,0d,null);
            groupPlayerCacheController.removeHhr(playerId,groupId,cache);

        }catch (Exception e ) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }

    }

    public Map<String, Object> getMyIDCard(Integer groupId, Integer playerId) {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            Map<String, Object> result = new HashMap<String, Object>();
            TPlayerGroup tpg = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
            if (!StringUtil.isEmpty(tpg)) {

                //我的名片
                if (tpg.getPlayerType() != PlayerTypeEnum.MEMBER) {
                    if ( StringUtil.isEmpty(tpg.getInviteIcon())) {
                        //生成二维码
                        String photoUrl = cache.hget(Constants.PLAYER_ + playerId, "photoUrl");
                        InputStream is = null;
                        if (!StringUtil.isEmpty(photoUrl)) {
                            URL url1 = new URL(photoUrl);
                            is = new DataInputStream(url1.openStream());
                        }
                        String inviteIcon = QrCodeUtil.drawLogoQRCode(is, ConfigUtil.get("mlink") + "?inviteCode=" + tpg.getInviteCode(), null, Long.parseLong(playerId + ""));
                        playerGroupMapper.updateIDCard(playerId,groupId, tpg.getWxchat(),tpg.getQq(),tpg.getXianliao(),inviteIcon);
                        tpg.setInviteIcon(inviteIcon);
                    }
                    HashMap<String, String> myIDCard = new HashMap<String, String>();
                    myIDCard.put("wxchat",tpg.getWxchat());
                    myIDCard.put("qq",tpg.getQq());
                    myIDCard.put("xianliao",tpg.getXianliao());
                    myIDCard.put("inviteCode",tpg.getInviteCode());
                    myIDCard.put("inviteIcon",tpg.getInviteIcon());
                    result.put("myIdCard",myIDCard);
                }
                //我的上级的名片
                if (tpg.getPlayerType() != PlayerTypeEnum.MASTER) {

                    TPlayerGroup upTpg = playerGroupMapper.selectByPlayerIdAndGroupId(tpg.getUpPlayerId(), groupId);
                    if (!StringUtil.isEmpty(upTpg) ) {
                        if ( StringUtil.isEmpty(upTpg.getInviteIcon())) {
                            //生成二维码
                            String photoUrl = cache.hget(Constants.PLAYER_ + upTpg.getPlayerId(), "photoUrl");
                            InputStream is = null;
                            if (!StringUtil.isEmpty(photoUrl)) {
                                URL url1 = new URL(photoUrl);
                                is = new DataInputStream(url1.openStream());
                            }
                            String inviteIcon = QrCodeUtil.drawLogoQRCode(is, ConfigUtil.get("mlink") + "?inviteCode=" + upTpg.getInviteCode(), null, Long.parseLong(upTpg.getPlayerId() + ""));
                            playerGroupMapper.updateIDCard(playerId,groupId, upTpg.getWxchat(),upTpg.getQq(),upTpg.getXianliao(),inviteIcon);
                            upTpg.setInviteIcon(inviteIcon);
                        }
                        HashMap<String, String> upIDCard = new HashMap<String, String>();
                        upIDCard.put("wxchat",upTpg.getWxchat());
                        upIDCard.put("qq",upTpg.getQq());
                        upIDCard.put("xianliao",upTpg.getXianliao());
                        upIDCard.put("inviteCode",upTpg.getInviteCode());
                        upIDCard.put("inviteIcon",upTpg.getInviteIcon());
                        result.put("upIdCard",upIDCard);
                    }

                }

            }
            result.put("domain",ConfigUtil.get("domain"));
            return result;
        }catch (Exception e ) {
            return null;
        }finally {
            CacheManager.releaseCache(cache);
        }

    }

    public void updateMyIDCard(Integer groupId, Integer playerId, String wechat, String qq, String xianliao) {

        TPlayerGroup tpg = playerGroupMapper.selectByPlayerIdAndGroupId(playerId, groupId);
        if (!StringUtil.isEmpty(tpg) ) {

//            if (!StringUtil.isEmpty(wechat)) {
                tpg.setWxchat(wechat);
//            }
//            if (!StringUtil.isEmpty(qq)) {
                tpg.setQq(qq);
//            }
//            if (!StringUtil.isEmpty(xianliao)) {
                tpg.setXianliao(xianliao);
//            }

            playerGroupMapper.updateIDCard(playerId,groupId,tpg.getWxchat(),tpg.getQq(),tpg.getXianliao(),tpg.getInviteIcon());
        }

    }
}
