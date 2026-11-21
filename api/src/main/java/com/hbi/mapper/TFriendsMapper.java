//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.cache.model.CacheCompereListProfile;
//import com.hbi.cache.model.CachePlayerListProfile;
//import com.hbi.model.TFriends;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TFriendsMapper extends Mapper<TFriends> {
//
//	List<CachePlayerListProfile> queryPlayerFriendsByUserId(@Param("userId") Long userId);
//
//	List<CacheCompereListProfile> queryCompereFriendsByUserId(@Param("userId") Long userId);
//
//}