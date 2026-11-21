package com.hbi.service.playerGroup;

import com.alibaba.fastjson.JSONObject;
import com.core.util.StringUtil;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.PlayerCacheController;
import com.hbi.constants.Constants;
import com.hbi.mapper.TMsgPlayerGroupMapper;
import com.hbi.model.TMsgPlayerGroup;
import com.hbi.service.player.PlayerService;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Created by muzi on 2017/12/9.
 */
@Service
public class TMsgPlayerGroupService {
    private static Logger log = Logger.getLogger(TMsgPlayerGroupService.class);

    @Autowired
    private TMsgPlayerGroupMapper msgPlayerGroupMapper;
    @Autowired
    private PlayerCacheController playerCacheController;

    public List<TMsgPlayerGroup> getMsgForplayerGroup(Integer playerId,String status,Integer groupId) throws Exception {
        ICache cache = CacheManager.getCache();
        try {

            List<TMsgPlayerGroup> msgs = msgPlayerGroupMapper.getMsg(playerId,status,groupId);
            for (TMsgPlayerGroup tmpg: msgs) {
                Integer playerId1 = tmpg.getPlayerId();
                Integer inviterUid = tmpg.getInviterUid();

                //申请者信息
                String photoUrl = cache.hget(Constants.PLAYER_ + playerId1, "photoUrl");
                if (StringUtil.isEmpty(photoUrl)) {
                    playerCacheController.queryPlayerDetail(Long.parseLong(playerId+""),cache,false, false);
                }
                tmpg.setPhotoUrl(cache.hget(Constants.PLAYER_ + playerId1, "photoUrl"));
                tmpg.setNickName(cache.hget(Constants.PLAYER_+playerId1,"nickName"));

                //邀请者信息
                photoUrl = cache.hget(Constants.PLAYER_ + inviterUid, "photoUrl");
                if (StringUtil.isEmpty(photoUrl)) {
                    playerCacheController.queryPlayerDetail(Long.parseLong(playerId+""),cache,false, false);
                }
                tmpg.setInviterPhotoUrl(cache.hget(Constants.PLAYER_ + inviterUid, "photoUrl"));
                tmpg.setInviterNickName(cache.hget(Constants.PLAYER_+inviterUid,"nickName"));

                //俱乐部的昵称
                String hget = cache.hget(Constants.PLAYER_GROUP_ + playerId, tmpg.getGroupId() + "");
                if (StringUtil.isNotEmpty(hget)) {
                    tmpg.setGroupName(JSONObject.parseObject(hget).getString("groupName"));
                }
            }
            return msgs;
        }catch (Exception e) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }

    }
}
