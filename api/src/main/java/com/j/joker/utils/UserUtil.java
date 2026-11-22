package com.j.joker.utils;

import com.j.joker.constants.Constants;
import com.j.joker.mapper.TUserMapper;
import com.j.joker.model.TUser;

public class UserUtil {
    
    public static boolean isUserExistedInDatabase(TUserMapper userMapper, String phone) {
        TUser user = new TUser();
        user.setPhone(phone);
        user.setDeprecated(Constants.USER_NOT_DEPRECATED);
        user = userMapper.selectOne(user);
        if(user == null) {
            return false;
        }
        return true;
    }
}
