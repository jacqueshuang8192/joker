package com.j.joker.service.playerGroup;

import com.j.joker.mapper.TCluRepositoryHandleHistoryMapper;
import com.j.joker.model.TCluRepositoryHandleHistory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TCluRepositoryHandleHistoryService {

    @Autowired
    private TCluRepositoryHandleHistoryMapper handleHistoryMapper;

    public TCluRepositoryHandleHistory addOne(Integer playerId,Integer groupId,Integer type,Integer point) {

        TCluRepositoryHandleHistory handleHistory = new TCluRepositoryHandleHistory();
        handleHistory.setPlayerId(playerId);
        handleHistory.setGroupId(groupId);
        handleHistory.setType(type);
        handleHistory.setPoint(point);
        handleHistoryMapper.insertSelective(handleHistory);

        return handleHistory;

    }

    public List<TCluRepositoryHandleHistory> selectMyHistory(Integer playerId,Integer groupId,String type,Integer startPage,Integer pageSize) {

        return handleHistoryMapper.selectMyHistory(playerId,groupId,type,startPage,pageSize);

    }

    public Integer selectMyHistoryCount(Integer playerId,Integer groupId,String type) {

        return handleHistoryMapper.selectMyHistoryCount(playerId,groupId,type);

    }

}
