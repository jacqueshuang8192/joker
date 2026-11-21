package com.hbi.cache.controller;

import java.util.Date;
import java.util.Map;

import com.core.util.ConfigUtil;
import com.core.util.EncryptUtils;
import com.core.util.StringUtil;
import com.hbi.constants.Constants;
import com.hbi.utils.InfServerException;
import org.apache.commons.collections.MapUtils;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.hbi.cache.ICache;
import com.hbi.cache.cacheWritter.LoginCacheLoader;
//import com.hbi.mapper.TAuthcodeMapper;
import com.hbi.mapper.TUserMapper;
//import com.hbi.model.TAuthcode;
import com.hbi.model.TUser;

@Service
public class LoginCacheController {

    /**
     * Token
     */
    private static final String TOKEN_KEY = "TOKEN_";

    public String queryToken(String phone, String oldToken, ICache cache) throws Exception{
        if (StringUtils.isBlank(oldToken)) {
            throw new InfServerException(Constants.RETURN_CODE_TOKEN_INVALID, "token验证失败");
        }
        String key = TOKEN_KEY + phone;
        Long expireTime = Long.parseLong(ConfigUtil.get("tokenExpireTime", "10800")); // token过期时间3小时
        Map<String, String> map = cache.hgetAll(key);
        if(MapUtils.isEmpty(map)) { //缓存中没有
            throw new InfServerException(Constants.RETURN_CODE_TOKEN_INVALID, "token验证失败");
        } else {
            String token = map.get("token");
            Long timestamp = Long.parseLong(map.get("timestamp"));
            if (!token.equalsIgnoreCase(oldToken)) {
                throw new InfServerException(Constants.RETURN_CODE_TOKEN_INVALID, "token验证失败");
            }
            if (System.currentTimeMillis() - timestamp > expireTime * 1000) { // token 过期
                return getNewToken(phone, oldToken, cache);
            }
            return ""; //token验证成功返回空串
        }
    }
//
//    public boolean isTokenValid(String phone, String oldToken, ICache cache) throws Exception{
//        if (StringUtils.isBlank(oldToken)) {
//            return false;
//        }
//        String key = TOKEN_KEY + phone;
//        Long expireTime = Long.parseLong(ConfigUtil.get("tokenExpireTime", "10800")); // token过期时间3小时
//        Map<String, String> map = cache.hgetAll(key);
//        if(MapUtils.isEmpty(map)) { //缓存中没有
//            return false;
//        } else {
//            String token = map.get("token");
//            Long timestamp = Long.parseLong(map.get("timestamp"));
//            if (!token.equalsIgnoreCase(oldToken)) {
//                throw new InfServerException(Constants.RETURN_CODE_TOKEN_INVALID, "token验证失败");
//            }
//            if (System.currentTimeMillis() - timestamp > expireTime * 1000) { // token 过期
//                throw new InfServerException(Constants.RETURN_CODE_TOKEN_EXPIRED, "token已过期");
//            }
//            return true;
//        }
//    }

    public String getNewToken(String phone, String oldToken, ICache cache) throws Exception {
        if (StringUtils.isBlank(oldToken)) {
            throw new InfServerException(Constants.RETURN_CODE_TOKEN_INVALID, "token验证失败");
        }
        String key = TOKEN_KEY + phone;
        Long expireTime = Long.parseLong(ConfigUtil.get("tokenExpireTime", "10800")); // token过期时间3小时
        Map<String, String> map = cache.hgetAll(key);
        if(MapUtils.isEmpty(map)) { //缓存中没有
            String token = updateToken(phone, cache);
            return token;
        } else {
            String token = map.get("token");
            Long timestamp = Long.parseLong(map.get("timestamp"));
            if (!token.equalsIgnoreCase(oldToken)) {
                throw new InfServerException(Constants.RETURN_CODE_TOKEN_INVALID, "token验证失败");
            }
            if (System.currentTimeMillis() - timestamp > expireTime * 1000) { // token 过期
                token = updateToken(phone, cache);
            }
            return token;
        }
    }
    
    public String updateToken(String XYUid, ICache cache) {
        String key = TOKEN_KEY + XYUid;
        Long timestamp = System.currentTimeMillis();
        String temp = XYUid + timestamp;
//        Long expireTime = Long.parseLong(ConfigUtil.get("tokenExpireTime", "10800"));
        String token = EncryptUtils.encodeMD5String(temp);
        cache.hset(key, "token", token);
        cache.hset(key, "timestamp", String.valueOf(timestamp + 1000 * 60 * 60 * 24 * 14 ));
        return token;
    }

    public boolean isTokenValid(ICache cache, String XYUid, String XYToken) {

        if (StringUtil.isEmpty(XYUid) || StringUtil.isEmpty(XYToken) ) {
            return false;
        }

        String key = TOKEN_KEY + XYUid;
        Map<String, String> tokenInfo = cache.hgetAll(key);
        if (!StringUtil.isEmpty(tokenInfo)) {
            String token = tokenInfo.get("token");
            String timestamp = tokenInfo.get("timestamp");
            if (!StringUtil.isEmpty(token) && !StringUtil.isEmpty(timestamp)) {
                long timesTamp = Long.parseLong(timestamp);
                long timesNow = System.currentTimeMillis();
                if (token.equals(XYToken) && timesNow < timesTamp) {
                    return true;
                }
            }
        }

        return false;
    }
}
