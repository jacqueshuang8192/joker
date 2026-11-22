package com.j.joker.cache.cacheWritter;

import com.j.joker.cache.model.CachePlayerProfile;
import com.j.joker.mapper.TPlayerMapper;
//import com.j.joker.mapper.TVipLevelMapper;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PlayerCacheLoader {

	@Autowired
	private TPlayerMapper playerMapper;
//
//	@Autowired
//	private TPlatformLevelMapper platformLevelMapper;
//
//	@Autowired
//	private TVipLevelMapper vipLevelMapper;

	/**
	 * 获取玩家详细个人信息
	 * @param playerId
	 * @return
	 * @throws
	 * @throws Exception
	 */
	public CachePlayerProfile loadPlayerDetails(Long playerId) throws Exception {
		CachePlayerProfile cacheVo = playerMapper.queryPlayerDetails(playerId);
		if (cacheVo == null) {
            return null;
        }
		if (!StringUtils.isBlank(cacheVo.getPayPassword())) {
		    cacheVo.setHasPayPassword(true);
        } else {
            cacheVo.setHasPayPassword(false);
        }
		cacheVo.setPayPassword(null);
		return cacheVo;
	}

	/**
	 * 获取玩家关注的主播列表
	 * @param playerId
	 * @return
	 */
//	public List<CacheCompereListProfile> loadAttentionCompereByPlayerId(Long playerId) {
//		return compereMapper.queryAttentionCompereList(playerId);
//	}
//
//	public CachePlayerRelation loadPlayerRelation(Long playerId) {
//		return playerMapper.queryPlayerAllRelation(playerId);
//	}
//
//	public List<TPlatformLevel> queryPlatformLevelList() {
//	    return platformLevelMapper.select(new TPlatformLevel());
//	}
//
//    public List<TVipLevel> queryVipLevelList() {
//        return vipLevelMapper.select(new TVipLevel());
//    }

    public List<String> loadSubPlayers(Long playerId) {
        return playerMapper.querySubPlayers(playerId);
    }
}
