package com.hbi.cache.cacheWritter;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

import com.hbi.cache.model.*;
import com.hbi.mapper.*;
import com.hbi.model.*;
import org.apache.commons.collections.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.core.util.DateUtils;
import com.hbi.constants.Constants;
import com.hbi.vo.response.user.AccountVo;
import tk.mybatis.mapper.entity.Example;

@Service
public class CommonCacheLoader {
	
//	@Autowired
//	private TUserTaskMapper userTaskMapper;
//	@Autowired
//	private TTaskMapper taskMapper;
//	@Autowired
//	private TUserGoodsMapper userGoodsMapper;
//	@Autowired
//	private TAccountMapper accountMapper;
//	@Autowired
//    private TUserWealthRankMapper userWealthRankMapper;
//	@Autowired
//	private TUserGameMapper userGameMapper;
	@Autowired
	private TUserMapper userMapper;
//	@Autowired
//	private TDatingActivityMapper datingActivityMapper;
//	@Autowired
//	private TDatingAuctionRecordMapper datingAuctionRecordMapper;
//	@Autowired
//    private TStoreCategoryMapper storeCategoryMapper;
//	@Autowired
//	private TStoreMapper storeMapper;
//	@Autowired
//    private GameInfoMapper gameInfoMapper;
	@Autowired
	private TDefaultPhotoMapper defaultPhotoMapper;
	
	/**
	 * 查找用户任务列表ID
	 * @param userId
	 * @return
	 * @throws Exception 
	 */
//	public List<Long> loadTaskIdsByUserId(Long userId) throws Exception {
//	    List<Long> taskIds = new ArrayList<Long>();
//		List<Long> oneTimeTaskIds = userTaskMapper.queryOneTimeTaskIdByUserId(userId);
//		if (CollectionUtils.isNotEmpty(oneTimeTaskIds)) {
//            taskIds.addAll(oneTimeTaskIds);
//        }
//		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd", Locale.US);
//        sdf.setTimeZone(TimeZone.getTimeZone("GMT+8"));
//        String nowDate = sdf.format(new Date());
//        List<Long> dailyTaskIds = userTaskMapper.queryDailyTaskIdByUserId(userId, sdf.parse(nowDate));
//        if (CollectionUtils.isNotEmpty(dailyTaskIds)) {
//            taskIds.addAll(dailyTaskIds);
//        }
//		return taskIds;
//	}
	
	/**
	 * 根据用户ID和任务ID查询用户任务
	 * @return
	 */
//	public CacheTask loadTaskByUserIdAndTaskId(Long userId, Long taskId) {
//	    CacheTask task = null;
//	    Date nowDate = new Date();
//	    List<CacheTask> tasks = userTaskMapper.queryTasksByUserId(userId, taskId);
//	    if (CollectionUtils.isNotEmpty(tasks)) {
//	        for (CacheTask t : tasks) {
//                if (Constants.ONE_TIME_TASK.equals(t.getTaskType())) {
//                    task = t;
//                    break;
//                } else {
//                    if (DateUtils.isSameDate(nowDate, t.getEndDate())) {
//                        task = t;
//                        break;
//                    }
//                }
//            }
//	    }
//		return task;
//	}
//
//	/**
//	 * 根据用户类型获取所有静态任务
//	 * @return
//	 */
//	public List<TTask> loadAllTasksByUserType(String userType) {
//		TTask temp = new TTask();
//		temp.setUserType(userType);
//		temp.setStatus(Constants.TASK_STATUS_PUBLISH);
//		return taskMapper.select(temp);
//	}
//
//	/**
//	 * 根据用户ID查询个人道具
//	 * @param userId
//	 * @return
//	 */
//	public List<TUserGoods> loadGoodsByUserId(Long userId, String categoryType) {
//		return userGoodsMapper.queryUserGoodsByUserId(userId, categoryType);
//	}
//
//	/**
//	 * 根据用户ID查询个人账户
//	 * @param userId
//	 * @return
//	 */
//	public TAccount loadAccountByUserId(Long userId) {
//		TAccount account = new TAccount();
//		account.setUserid(userId);
//		return accountMapper.selectOne(account);
//	}
//
//	public AccountVo getUserAccount(Long userId) throws Exception {
//        AccountVo vo = null;
//        GameInfo info = new GameInfo();
//        info.setMid(userId);
//        info = gameInfoMapper.selectById(info);
//		if (info != null) {
//			vo = new AccountVo();
//			vo.setCoinAmount(info.getMoney());
//			vo.setJewelAmount(info.getDiamond().longValue());
//		}
//        return vo;
//    }
//
//	/**
//	 * 根据用户ID查询游戏段位
//	 * @param userId
//	 * @return
//	 */
//	public List<TUserGame> loadUserGamesByUserId(Long userId) {
//	    List<TUserGame> userGames = userGameMapper.queryUserGameDanByUserId(userId);
//		return userGames;
//	}
//
//	public TUserGame loadUserGameByUserIdAndGameId(Long userId, Long gameId) {
//		return userGameMapper.loadUserGameByUserIdAndGameId(userId, gameId);
//	}
//
//	/**
//	 * 查询财富排行
//	 * @return
//	 */
//	public List<TUserWealthRank> loadWealthRank() {
//		return userWealthRankMapper.queryWealthRank();
//	}
	
	public List<TUser> queryAllUsers() {
		return userMapper.select(new TUser());
	}
	/*
	*//**
	 * 根据邀请人查询约饭记录
	 * @param inviterId
	 * @return
	 *//*
	public List<CacheDatingRecordListProfile> loadDatingRecordsByInviterId(Long inviterId) {
		return datingRecordMapper.queryDatingRecordsByInviterId(inviterId);
	}
	
	*//**
	 * 根据主播查询约饭记录
	 * @param compereId
	 * @return
	 *//*
	public List<CacheDatingRecordListProfile> loadDatingRecordsByCompereId(Long compereId) {
		return datingRecordMapper.queryDatingRecordsByCompereId(compereId);
	}*/

	/**
	 * 根据城市，获取附近的约饭活动
	 * @param cityId
	 * @return
	 */
//	public List<CacheDatingActivityListProfile> loadDatingActivitiesByCityId(String cityId) {
//		return datingActivityMapper.queryDatingActivitiesByCityId(cityId);
//	}
//
//	public CacheDatingActivityProfile loadDatingActivityByActivityId(Long activityId) {
//		return datingActivityMapper.queryDatingActivityByActivityId(activityId);
//	}
//
//	public List<CacheDatingActivityListProfile> loadDatingActivitiesByUserId(Long compereId) {
//		return datingActivityMapper.queryDatingActivitiesByUserId(compereId);
//	}
	
//	public List<CacheDatingAuctionRecordProfile> loadDatingAuctionRecordsByUserId(Long userId) {
//		return datingAuctionRecordMapper.queryDatingAuctionRecordsByUserId(userId);
//	}
//
//	public List<CacheStoreCategory> loadStorePrimaryCategories() {
//    	return storeCategoryMapper.queryPrimaryCategories();
//    }
//
//    public List<CacheStoreCategory> loadStoreSecondaryCategories(Long parentId) {
//    	return storeCategoryMapper.querySecondaryCategories(parentId);
//    }
//
//	public List<Long> queryAdIds(Long cityId) {
//		Example example = new Example(TStore.class);
//		Example.Criteria criteria = example.createCriteria();
//		criteria.andGreaterThan("goodsCount", 0);
//		criteria.andEqualTo("cityId", cityId);
//		criteria.andGreaterThan("adPriority", -1);
//		List<TStore> stores = storeMapper.selectByExample(example);
//		List<Long> ids = new ArrayList<Long>();
//		for (TStore s : stores) {
//			ids.add(s.getId());
//		}
//		return ids;
//	}
//
//	public List<Long> queryStoreIdsByCity(Long cityId) {
//		TStore store = new TStore();
//		store.setCityId(cityId);
//		List<TStore> stores = storeMapper.select(store);
//		List<Long> ids = new ArrayList<Long>();
//		for (TStore s : stores) {
//			ids.add(s.getId());
//		}
//		return ids;
//	}
//
//	public List<TDatingAuctionRecord> queryDatingAuctionRankByActivityId(Long activityId) {
//		List<TDatingAuctionRecord> list = datingAuctionRecordMapper.queryDatingAuctionRankByActivityId(activityId);
//		return list;
//	}
    
    /**
     * 获取所有用户的用户类型
     * @return
     */
    public Map<String, String> loadUserTypes() {
        List<Map<String, Object>> userTypeMap = userMapper.queryUserTypes();
        Map<String, String> resultMap = new HashMap<String, String>();
        for (Map<String, Object> map : userTypeMap) {
            String userId = null;
            String userType = null;
            for (Map.Entry<String, Object> entry : map.entrySet()) {
              if ("userId".equals(entry.getKey())) {
                  userId = entry.getValue().toString();
              } else if ("type".equals(entry.getKey())) {
                  userType = (String) entry.getValue();
              }
            }
            resultMap.put(userId, userType);
        }
        return resultMap;
    }

	public List<TDefaultPhoto> queryDefaultPhotoList() {
		return defaultPhotoMapper.select(new TDefaultPhoto());
	}
    
    /*public List<TMerchantGoods> loadMerchantGoodsByPrimaryCategory(Long categoryId, int startIndex, int pageSize) {
    	return merchantGoodsMapper.queryMerchantGoodsByPrimaryCategory(categoryId, startIndex, pageSize);
    }
    
    public int loadMerchantGoodsTotalCountByPrimaryCategory(Long categoryId) {
        TMerchantGoods merchantGoods = new TMerchantGoods();
        merchantGoods.setPrimaryCategoryId(categoryId);
        return merchantGoodsMapper.selectCount(merchantGoods);
    }
    
    public List<TMerchantGoods> loadMerchantGoodsBySecondaryCategory(Long categoryId, int startIndex, int pageSize) {
        return merchantGoodsMapper.queryMerchantGoodsBySecondaryCategory(categoryId, startIndex, pageSize);
    }
    
    public int loadMerchantGoodsTotalCountBySecondaryCategory(Long categoryId) {
        TMerchantGoods merchantGoods = new TMerchantGoods();
        merchantGoods.setSecondaryCategoryId(categoryId);
        return merchantGoodsMapper.selectCount(merchantGoods);
    }
    
    */
}
