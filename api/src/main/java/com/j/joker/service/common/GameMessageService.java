package com.j.joker.service.common;

import com.j.joker.mapper.TGameMessageMapper;
import com.j.joker.model.TGameMessage;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;

/**
 * Created by dzesla on 2017/2/16.
 */
@Service
public class GameMessageService {
    @Autowired
    private TGameMessageMapper gameMessageMapper;

    private static final Logger LOGGER = Logger.getLogger(GameMessageService.class);

    public void uploadGameMessage(Integer type,Integer uid,Integer level, String msg) {
        TGameMessage gameMessage = new TGameMessage();
        gameMessage.setType(type);
        gameMessage.setLevel(level);
        gameMessage.setUid(uid);
        gameMessage.setMsg(msg);
        gameMessage.setDate(new Date());
        gameMessageMapper.insert(gameMessage);
        
    }
}
