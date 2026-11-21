//package com.hbi.cache.cacheWritter;
//
//import com.hbi.cache.model.CacheCompereProfile;
//import com.hbi.cache.model.CacheRoomListProfile;
//import com.hbi.cache.model.CacheRoomProfile;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TLiveHotWordsMapper;
//import com.hbi.mapper.TLiveRoomAccountMapper;
//import com.hbi.mapper.TRoomMapper;
//import com.hbi.model.TLiveHotWords;
//import com.hbi.model.TLiveRoomAccount;
//import com.hbi.model.TRoom;
//import org.apache.commons.collections.CollectionUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//import tk.mybatis.mapper.entity.Example;
//import tk.mybatis.mapper.entity.Example.Criteria;
//
//import java.util.List;
//
//@Service
//public class RoomCacheLoader {
//
//	@Autowired
//	private TRoomMapper roomMapper;
//	@Autowired
//	private TLiveRoomAccountMapper liveRoomAccountMapper;
//	@Autowired
//	private TLiveHotWordsMapper liveHotWordsMapper;
//
//	public CacheRoomProfile loadRoomDetails(Long roomId) {
//		TRoom room = roomMapper.selectByPrimaryKey(roomId);
//
//		if (room != null && room.getStatus() != 3) {
//			CacheRoomProfile result = new CacheRoomProfile();
//			CacheCompereProfile compereProfile = new CacheCompereProfile();
//			compereProfile.setUserId(room.getCompereId().toString());
//			result.setCompere(compereProfile);
//			result.setLiveId((room.getLiveId() != null) ? room.getLiveId().toString() : null);
//			result.setRoomId(room.getRoomId().toString());
//			result.setRoomName(room.getName());
//			result.setChatRoomId(room.getChatroomId());
//			result.setRoomPhoto(room.getRoomPhoto());
//			result.setLiveType(room.getLiveType());
//			result.setResolution(room.getResolution());
//			return result;
//		}
//		return null;
//	}
//
//	public List<CacheRoomListProfile> loadRoomList(Long cityId) throws Exception {
//		return roomMapper.queryAllRoomsByCity(cityId);
//	}
//
//	public List<CacheRoomListProfile> loadAllRooms() throws Exception {
//		return roomMapper.queryAllRooms();
////		Example example = new Example(TRoom.class);
////		Criteria criteria = example.createCriteria();
////		criteria.andNotEqualTo("status", "3");
////		List<TRoom> rooms = roomMapper.selectByExample(example);
////		List<Long> roomIds = new ArrayList<Long>();
////		for(TRoom room : rooms) {
////			roomIds.add(room.getRoomId());
////		}
////		return roomIds;
//	}
//
//	public String loadRoomByCompereId(Long compereId) {
//		Example example = new Example(TRoom.class);
//		Criteria criteria = example.createCriteria();
//		criteria.andNotEqualTo("status", "3");
//		criteria.andEqualTo("compereId", compereId);
//		List<TRoom> rooms = roomMapper.selectByExample(example);
//		if (CollectionUtils.isNotEmpty(rooms)) {
//			return rooms.get(0).getRoomId().toString();
//		}
//		return null;
//	}
//
//	public List<TLiveRoomAccount> loadLiveRoomAccount() {
//	    TLiveRoomAccount temp = new TLiveRoomAccount();
//	    temp.setStatus(Constants.LIVE_ROOM_DESTRIBUTE_STATUS_USED);
//	    return liveRoomAccountMapper.select(temp);
//	}
//
//	public List<TLiveHotWords> hotWords() {
//		return liveHotWordsMapper.select(new TLiveHotWords());
//	}
//}
