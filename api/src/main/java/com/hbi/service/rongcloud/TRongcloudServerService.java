package com.hbi.service.rongcloud;

import com.hbi.mapper.TGameProvinceMapper;
import com.hbi.mapper.TRongcloudServerMapper;
import com.hbi.mapper.TUserMapper;
import com.hbi.model.TGameProvince;
import com.hbi.model.TRongcloudServer;
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

