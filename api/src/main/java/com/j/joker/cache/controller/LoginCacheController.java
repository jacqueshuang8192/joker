package com.j.joker.cache.controller;

import java.util.Date;
import java.util.Map;

import com.j.joker.core.util.ConfigUtil;
import com.j.joker.core.util.EncryptUtils;
import com.j.joker.core.util.StringUtil;
import com.j.joker.constants.Constants;
import com.j.joker.utils.InfServerException;
import org.apache.commons.collections.MapUtils;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.j.joker.cache.ICache;
import com.j.joker.cache.cacheWritter.LoginCacheLoader;
//import com.j.joker.mapper.TAuthcodeMapper;
import com.j.joker.mapper.TUserMapper;
//import com.j.joker.model.TAuthcode;
import com.j.joker.model.TUser;

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
