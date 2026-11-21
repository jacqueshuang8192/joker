package com.hbi.service.limit;

import com.hbi.constants.Constants;
import com.hbi.mapper.TTestConfigMapper;
import com.hbi.model.TTestConfig;
import com.hbi.model.TVersion;
import com.hbi.service.common.VersionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Administrator on 2017/7/21.
 */
@Service
public class TTestConfigService {
    @Autowired
    private TTestConfigMapper testConfigMapper;
    @Autowired
    private VersionService versionService;

    public String getVerifyByUidAndLevel(String uid, String level) {
        TTestConfig tTestConfig = testConfigMapper.getVerifyByUidAndLevel(uid,level);
        //if (tTestConfig == null ) {
        //    return null;
        //} else {
        //    String gameList = tTestConfig.getGameList();
        //    String[] split = gameList.substring(1, gameList.length() - 1).split(",");
        //    for (String s : split) {
        //        if (s == level) {
        //            return tTestConfig.getVerify();
        //        }
        //    }
        //}
        if(tTestConfig == null ) {
            return null;
        }
        return tTestConfig.getVerify();
    }

    public Map<String, Object> getDataByUidOrLevel(String level) throws Exception {
        List<TTestConfig> list = testConfigMapper.getAllTestConfig(level);
        TVersion tVersion = versionService.queryNewestVersion(Constants.VERSION_TYPE_GAME, null, level);

        Map<String, Object> result = new HashMap<String, Object>();
        result.put("testList", list);
        result.put("version", tVersion);


        //List<Map<String,Object>> resultList = new ArrayList<Map<String, Object>>();
        //for(TTestConfig t : list) {
        //    Map<String,Object> map = null;
        //    String gameList = t.getGameList();
        //    System.out.println(gameList);
        //    String[] split = gameList.substring(1, gameList.length() - 1).split(",");
        //    for (String s : split) {
        //        if ( s.equals(level)) {
        //            map = new HashMap<String, Object>();
        //            map.put("userid",t.getUserid());
        //            map.put("verify",t.getVerify());
        //        }
        //    }
        //    if (map != null) {
        //        System.out.println(map.get(1));
        //        resultList.add(map);
        //    }
        //}
        return result;
    }
}
