package com.j.joker.cache.cacheWritter;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.j.joker.mapper.TUserMapper;
import com.j.joker.model.TUser;

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
