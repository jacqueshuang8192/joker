package com.hbi.cache.cacheWritter;

import com.hbi.mapper.TFreeGameResultMapper;
import com.hbi.mapper.TFreeGameRoundMapper;
import com.hbi.mapper.TFreeGameSingleresultMapper;
import com.hbi.mapper.TFreeGameTotalMapper;
import com.hbi.model.TFreeGameResult;
import com.hbi.model.TFreeGameRound;
import com.hbi.model.TFreeGameSingleresult;
import com.hbi.model.TFreeGameTotal;
import org.apache.commons.collections.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Created by ceeuoo on 8/23/2016.
 */
@Service
public class FreeGameCacheLoader {
    @Autowired
    private TFreeGameRoundMapper roundMapper;
    @Autowired
    private TFreeGameResultMapper resultMapper;
    @Autowired
    private TFreeGameTotalMapper TotalMapper;
    @Autowired
    private TFreeGameSingleresultMapper singleresultMapper;

    public TFreeGameRound queryRoundByRoundIndex(Long activityId, Integer roundIndex) {
        TFreeGameRound round = new TFreeGameRound();
        round.setActivityId(activityId);
        round.setRoundIndex(roundIndex);
        return roundMapper.selectOne(round);
    }

    public TFreeGameResult queryResultByActivityId(Long activityId) {
        TFreeGameResult result = new TFreeGameResult();
        result.setActivityId(activityId);
        List<TFreeGameResult> list = resultMapper.select(result);
        if (CollectionUtils.isNotEmpty(list)) {
            return list.get(0);
        }
        return null;
    }
    

    public List<TFreeGameRound> querRoundsByActivityId(Long activityId) {
        TFreeGameRound round = new TFreeGameRound();
        round.setActivityId(activityId);
        return roundMapper.select(round);
    }
    public TFreeGameTotal queryTotalGroupGeRenRank(Long useId) {
        return TotalMapper.queryTotalGroupGeRenRank(useId);
    }
    public TFreeGameTotal queryTotalGroupGeRenRank2(Long useId) {
        return TotalMapper.queryTotalGroupGeRenRank2(useId);
    }
    
    public List<TFreeGameTotal> queryTotalGroupRank(Long rankcount) {
        return TotalMapper.queryTotalGroupRank(rankcount);
    }
    public TFreeGameSingleresult queryGeRenSingleResult(Long useId,String startTime,String endTime) {
        return singleresultMapper.queryGeRenSingleResult(useId,startTime,endTime);
    }
    public TFreeGameSingleresult queryGeRenSingleResult2(Long useId,String startTime,String endTime) {
        return singleresultMapper.queryGeRenSingleResult2(useId,startTime,endTime);
    }
    public List<TFreeGameSingleresult> querySingleResult(Long rankcount,String startTime,String endTime) {
        return singleresultMapper.querySingleResult(rankcount,startTime,endTime);
    }
    public List<TFreeGameResult> queryActivitiesByUserId(Long userId) {
        return resultMapper.queryActivitiesByUserId(userId);
    }
    
    public List<TFreeGameResult> queryActivitiesByOwner(Long userId) {
        return resultMapper.queryActivitiesByOwner(userId);
    }
}
