//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.cache.model.CacheRoomListProfile;
//import com.hbi.model.TRoom;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TRoomMapper extends Mapper<TRoom> {
//    List<CacheRoomListProfile> queryAllRoomsByCity(@Param("cityId") Long cityId);
//
//    List<CacheRoomListProfile> queryAllRooms();
//
//    List<CacheRoomListProfile> queryAllNotClosedRooms();
//
//    Long queryNotClosedRoomByCompre(@Param("compereId") Long compereId);
//
//    int updateLiveRoomInfo(@Param("roomId") Long roomId, @Param("roomName") String roomName,
//            @Param("roomListPhoto") String roomListPhoto, @Param("roomPhoto") String roomPhoto,
//            @Param("password") String password, @Param("liveType") String liveType);
//}