//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.cache.model.GroupVo;
//import com.hbi.model.TGroup;
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TGroupMapper extends Mapper<TGroup> {
//	public GroupVo queryGroupById(@Param("groupId") Long groupId);
//
//	public List<GroupVo> queryGroupByUserId(@Param("userId") Long userId);
//}