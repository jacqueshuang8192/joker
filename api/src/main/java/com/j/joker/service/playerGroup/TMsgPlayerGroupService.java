package com.j.joker.service.playerGroup;

import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.util.StringUtil;
import com.j.joker.cache.CacheManager;
import com.j.joker.cache.ICache;
import com.j.joker.cache.controller.PlayerCacheController;
import com.j.joker.constants.Constants;
import com.j.joker.mapper.TMsgPlayerGroupMapper;
import com.j.joker.model.TMsgPlayerGroup;
import com.j.joker.service.player.PlayerService;
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
