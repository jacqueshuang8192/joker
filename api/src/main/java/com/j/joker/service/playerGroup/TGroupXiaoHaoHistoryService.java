package com.j.joker.service.playerGroup;

import com.j.joker.mapper.TGroupXiaohaoHistoryMapper;
import com.j.joker.model.TGroupXiaohaoHistory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

/**
 * Create by Mars on 2019/7/20 15:43
 */
@Service
public class TGroupXiaoHaoHistoryService {

    @Autowired
    private TGroupXiaohaoHistoryMapper groupXiaohaoHistoryMapper;


    public void insertOne(Integer groupId, int shangjiId, Integer uid, Integer profit, int agentIncome, int level, Long activityId) {

        TGroupXiaohaoHistory history = new TGroupXiaohaoHistory();
        history.setGroupId(groupId);
        history.setHehuorenId(shangjiId);
        history.setPlayerId(uid);
        history.setProfit(agentIncome);
        history.setProfitCount(profit);
        history.setProfitTime(new Date());
        history.setGameLevel(level);
        history.setActivityId(activityId);
        groupXiaohaoHistoryMapper.insertSelective(history);

    }


    public List<TGroupXiaohaoHistory> getXiaohaoList(Integer groupId, Integer hehuorenId, String startTime, String endTime, Integer currentPage, Integer pageSize, Integer searchUid ) {

        Integer startIndex = (currentPage - 1 ) * pageSize;

        List<TGroupXiaohaoHistory> result = groupXiaohaoHistoryMapper.getXiaohaoList(groupId, hehuorenId, startTime, endTime, startIndex, pageSize, searchUid);

        return result;
    }

    public Integer getXiaohaoListLen(Integer groupId, Integer hehuorenId, String startTime, String endTime, Integer searchUid) {


        Integer len = groupXiaohaoHistoryMapper.getXiaohaoListLen(groupId, hehuorenId, startTime, endTime, searchUid );

        return len;
    }

    public Integer getXiaoHaoCount(Integer groupId, Integer hehuorenId, String startTime, String endTime, Integer searchUid ) {

        Integer count = groupXiaohaoHistoryMapper.getXiaoHaoCount(groupId, hehuorenId, startTime, endTime, searchUid );

        return count;
    }

}
