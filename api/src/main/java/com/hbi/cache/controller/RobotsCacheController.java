package com.hbi.cache.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.hbi.cache.ICache;
import com.hbi.constants.Constants;
import com.hbi.mapper.TUserMapper;
import com.hbi.model.TUser;

@Service
public class RobotsCacheController {
	
	private static final String LIVE_ROOM_ROBOTS_PREFIX = "LIVE_ROOM_ROBOTS_";
	
	private static final String LIVE_ROOM_ROBOTS_FIELD_BAT_COUNT = "batCount";
	
	private static final String ROBOTS_LIST_PREFIX = "ROBOTS_LIST_";
	
	@Autowired
	private TUserMapper userMapper;
	@Autowired
	private BaseCacheController baseCacheController;

	public void doCreateRoom(String roomId, ICache cache) throws Exception {
		doCloseRoom(roomId, cache);
		
		String key = LIVE_ROOM_ROBOTS_PREFIX + roomId;

		String robotBatchNoStr = baseCacheController.queryConfig("robotBatchNo", cache);

		Integer robotBatchNo = Integer.parseInt(robotBatchNoStr);
		
		List<Integer> oriList = new ArrayList<Integer>();
		for (int i = 0; i < robotBatchNo; i++) {
			oriList.add(i + 1);
		}
		
		List<Integer> batList = new ArrayList<Integer>();
		while(!oriList.isEmpty()) {
			Random r = new Random();
			int index = r.nextInt(oriList.size());
			
			batList.add(oriList.get(index));
			oriList.remove(index);
		}
		
		for (int i = 0; i < batList.size(); i++) {
			cache.hset(key, i + 1 + "", batList.get(i) + "");
		}
		
		cache.hset(key, LIVE_ROOM_ROBOTS_FIELD_BAT_COUNT, "0");
	}
	
	public void doCloseRoom(String roomId, ICache cache) {
		String key = LIVE_ROOM_ROBOTS_PREFIX + roomId;
		
		cache.del(key);
	}
	
	public int getAvaibleBatNo(String roomId, ICache cache) throws Exception {
		String key = LIVE_ROOM_ROBOTS_PREFIX + roomId;
		
		long index = cache.hincrby(key, LIVE_ROOM_ROBOTS_FIELD_BAT_COUNT, 1);

		String robotBatchNoStr = baseCacheController.queryConfig("robotBatchNo", cache);

		Integer robotBatchNo = Integer.parseInt(robotBatchNoStr);
		
		if (index > robotBatchNo) {
			return -1;
		}
		
		int result = Integer.parseInt(cache.hget(key, index + ""));
		
		return result;
	}
	
}
