package com.j.joker.service.rongcloud;

import com.j.joker.mapper.TGameProvinceMapper;
import com.j.joker.mapper.TRongcloudServerMapper;
import com.j.joker.mapper.TUserMapper;
import com.j.joker.model.TGameProvince;
import com.j.joker.model.TRongcloudServer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Created by muzi on 2017/6/24.
 */
@Service
public class TRongcloudServerService {
    @Autowired
    private TRongcloudServerMapper rongcloudServerMapper;
    @Autowired
    private TUserMapper userMapper;
    @Autowired
    private TGameProvinceMapper gameProvinceMapper;

    public void updateToken(String userid, String token) {
        Long userId = Long.valueOf(userid);
        userMapper.updateToken(userId,token);
    }

    public void deleteOrderDate() {
        rongcloudServerMapper.deleteOrderDate();
    }

    public void insertRoom(TRongcloudServer tRongcloudServer) {
        rongcloudServerMapper.insertRoom(tRongcloudServer);
    }

    public List<TGameProvince> getAllProvince() {
        return gameProvinceMapper.getAllProvince();
    }

    public List<TRongcloudServer> getAllProvinceIds(String provinceId) {
        return rongcloudServerMapper.getAllProvinceIds(provinceId);
    }

    public void deleteByRoom_id(String room_id) {
        rongcloudServerMapper.deleteByRoom_id(room_id);
    }

    public List<TRongcloudServer> getAllRoom(String provinceId) {
        return rongcloudServerMapper.getAllRoom(provinceId);
    }

    public List<String> getRoomList() {
        return  rongcloudServerMapper.getRoomList();
    }
}

