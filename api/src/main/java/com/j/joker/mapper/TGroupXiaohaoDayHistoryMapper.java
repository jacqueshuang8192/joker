package com.j.joker.mapper;

import com.j.joker.model.TGroupXiaohaoDayHistory;
import com.j.joker.vo.request.common.XiaoHaoInfoVO;
import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

public interface TGroupXiaohaoDayHistoryMapper extends EntityMapper<TGroupXiaohaoDayHistory> {
    int updateInfo(@Param("groupId") Integer groupId, @Param("hehuorenId") int hehuorenId, @Param("agentIncome") int agentIncome, @Param("dayingjiaCount") int dayingjiaCount,@Param("now_data") String now_data);

    XiaoHaoInfoVO selectXiaoHaoInfo(@Param("groupId") Integer groupId, @Param("playerId") Integer playerId, @Param("startTime") String startTime, @Param("endTime") String endTime);
}