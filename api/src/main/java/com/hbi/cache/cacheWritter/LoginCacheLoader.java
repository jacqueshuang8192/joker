package com.hbi.cache.cacheWritter;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.hbi.mapper.TUserMapper;
import com.hbi.model.TUser;

@Service
public class LoginCacheLoader {
    
//    @Autowired
//    private TUserMapper userMapper;
    
//    public String loadPassword(String phone) {
//        TUser user = new TUser();
//        user.setPhone(phone);
//        user = userMapper.selectOne(user);
//        String password = user.getPassword();
//        return password;
//    }
}
