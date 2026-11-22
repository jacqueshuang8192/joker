package com.j.joker.service.playerGroup;

import com.j.joker.mapper.TGroupXiaohaoDayHistoryMapper;
import com.j.joker.model.TGroupXiaohaoDayHistory;
import com.j.joker.utils.DateUtil;
import com.j.joker.vo.request.common.XiaoHaoInfoVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;

/**
 * Create by Mars on 2019/7/20 16:48
 */
@Service
public class TGroupXiaoHaoDayHistoryService {

    @Autowired
    private TGroupXiaohaoDayHistoryMapper groupXiaohaoDayHistoryMapper;


    public void update(Integer groupId, int hehuorenId, int agentIncome, int dayingjiaCount) {

        String now_data = DateUtil.getTodayString(new Date(),"yyyy-MM-dd");
        int updateCount = groupXiaohaoDayHistoryMapper.updateInfo(groupId,hehuorenId,agentIncome,dayingjiaCount,now_data);

        if (updateCount <= 0 ) {
            TGroupXiaohaoDayHistory history = new TGroupXiaohaoDayHistory();
            history.setGroupId(groupId);
            history.setHehuorenId(hehuorenId);
            history.setProfit(agentIncome);
            history.setDayTime(new Date());
            history.setDayingjiaCount(dayingjiaCount);
            history.setPlayerCount(0);

            groupXiaohaoDayHistoryMapper.insertSelective(history);
        }

    }

    public XiaoHaoInfoVO selectXiaoHaoInfo(Integer groupId, Integer playerId, String startTime, String endTime) {

        return groupXiaohaoDayHistoryMapper.selectXiaoHaoInfo(groupId,playerId,startTime,endTime);

    }
}
