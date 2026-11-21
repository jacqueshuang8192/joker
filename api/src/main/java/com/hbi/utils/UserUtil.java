package com.hbi.utils;

import com.hbi.constants.Constants;
import com.hbi.mapper.TUserMapper;
import com.hbi.model.TUser;

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
