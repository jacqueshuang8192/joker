package com.linkxin.douyouPlayer.util;

import android.content.Context;
import android.text.TextUtils;

import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.vo.DouyouUser;
import com.linkxin.douyouPlayer.vo.UserCity;

import net.tsz.afinal.FinalDb;

/**
 * Created by zhongweihao on 16/6/16.
 */
public class DBUtils {

    private static UserCity userCity;

    /**
     * 获取当前用户的城市信息
     *
     * @param context
     * @return
     */
    public static UserCity getCurrentUserCity(Context context) {
        if (userCity == null) {
            FinalDb finalDb = FinalDb.create(context);
            userCity = finalDb.findById(SPUtil.getCurrentUserId(context), UserCity.class);
            if (userCity == null) {
                userCity = new UserCity();
                String cityId = MyApplication.locatedCityId;
                String cityName = MyApplication.locatedCityName;
                if (TextUtils.isEmpty(cityId) || TextUtils.isEmpty(cityName)) {
                    DouyouUser user = SPUtil.getCurrentUser(context);
                    cityId = user.getCityId();
                    cityName = user.getCity();
                }

                userCity.setUserId(SPUtil.getCurrentUserId(context));
                userCity.setRoomCityId(cityId);
                userCity.setRoomCityName(cityName);
                userCity.setSocietyCityId(cityId);
                userCity.setSocietyCityName(cityName);
                userCity.setOfflineStoreCityId(cityId);
                userCity.setOfflineStoreCityName(cityName);
                userCity.setDatingCityId(cityId);
                userCity.setDatingCityName(cityName);
                userCity.setTreasureCityId(cityId);
                userCity.setTreasureCityName(cityName);
                finalDb.save(userCity);
            }
        }
        return userCity;
    }

    /**
     *
     * @param context
     * @param uc
     * @return
     */
    public static boolean updateCurrentUserCity(Context context, UserCity uc){
        if (uc == null) {
            return false;
        }
        String userId = uc.getUserId();

        FinalDb finalDb = FinalDb.create(context);
        finalDb.update(uc, String.format("userId='%s'", userId));
        userCity = uc;//更新缓存

        return true;
    }
}
