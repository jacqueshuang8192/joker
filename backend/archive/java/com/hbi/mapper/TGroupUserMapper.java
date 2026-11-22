//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.cache.model.GroupMemberVo;
//import com.hbi.model.TGroupUser;
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TGroupUserMapper extends Mapper<TGroupUser> {
//	public List<GroupMemberVo> queryMembersByGroupId(@Param("groupId") Long groupId);
//}