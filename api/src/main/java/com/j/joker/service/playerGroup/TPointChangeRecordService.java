package com.j.joker.service.playerGroup;

import com.j.joker.core.util.StringUtil;
import com.j.joker.mapper.TPointChangeRecordMapper;
import com.j.joker.model.TPointChangeRecord;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class TPointChangeRecordService {

    @Autowired
    private TPointChangeRecordMapper pointChangeRecordMapper;

    /**
     * 积分变化记录
     * @param clubId
     * @param uid
     * @param type
     * @param beforePoint
     * @param changePoint
     * @param nowPoint
     * @param operator
     * @param activityId
     * @param index
     * @param remarkInfo
     * @param changeTime
     * @return
     */
    public Integer addOne(Integer clubId, Integer uid, Integer type, Integer beforePoint, Integer changePoint,
                          Integer nowPoint, Integer operator, Integer activityId, Integer index, String remarkInfo, String changeTime) {

        int tab = clubId % 10;

        return pointChangeRecordMapper.addOne(tab ,clubId, uid, type, beforePoint, changePoint, nowPoint, operator, activityId, index,remarkInfo, changeTime);

    }

    public Map<String, Object> selectChangeRecord(Integer clubId, Integer uid, String typesStr,Integer currentPage,Integer pageSize) {

        int tab = clubId % 10;
        int startInex = (currentPage-1) * pageSize;

//        if (!StringUtil.isEmpty(typesStr) ) {
//            String[] types = typesStr.split(",");
//            if (types.length > 1) {
//                String temp = null;
//                for (int i = 0; i < types.length; i++){
//                    if ( i == (types.length - 1) ) {
//                        temp += types[i];
//                        break;
//                    }
//                    temp += (types[i] + ",");
//                    typesStr = temp;
//                }
//            }
//        }

        List<TPointChangeRecord> list = pointChangeRecordMapper.selectChangeRecord(tab ,clubId, uid, typesStr, startInex, pageSize);
        Integer listCount = pointChangeRecordMapper.selectChangeRecordCount(tab ,clubId, uid, typesStr);

        HashMap<String, Object> result = new HashMap<String, Object>();
        result.put("list", list);
        result.put("listCount", listCount);

        return result;
    }

}
