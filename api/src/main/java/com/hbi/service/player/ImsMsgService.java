package com.hbi.service.player;

import com.hbi.mapper.ImsMsgMapper;
import com.hbi.model.ImsMsg;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ImsMsgService {

    @Autowired
    private ImsMsgMapper msgMapper;

    public ImsMsg addOne(String phone,Integer type,String smsCode, Integer status, Integer uid) {

        ImsMsg msg = new ImsMsg();
        msg.setPhone(phone);
        msg.setType(type);
        msg.setContent(smsCode);
        msg.setStatus(status);
        msg.setAgentid(uid);
        msg.setAddtime(System.currentTimeMillis()+"");
        msgMapper.insertSelective(msg);

        return msg;
    }

    public ImsMsg selectByPhone(String phone ) {

       ImsMsg msg = msgMapper.selectByPhone(phone);

       return msg;
    }

}
