package com.hbi.service.gift;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.hbi.constants.Constants;
import com.hbi.mapper.TConfigMapper;
import com.hbi.service.game.FreeGameService;
import com.hbi.vo.response.Response;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * Created by Administrator on 2017/7/12.
 */
@Service
public class TConfigService {
    private static Logger log = Logger.getLogger(FreeGameService.class);

    @Autowired
    private TConfigMapper configMapper;

    public String getLeastGiftPoints() {
        return configMapper.getVValues("leastGiftPoints");
    }

    public String getLeastGiftCardRoom() {
        return configMapper.getVValues("leastGiftCardRoom");
    }
}
