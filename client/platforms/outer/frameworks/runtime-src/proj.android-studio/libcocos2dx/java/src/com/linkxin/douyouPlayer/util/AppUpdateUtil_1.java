package com.linkxin.douyouPlayer.util;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.view.View;

import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.library.dialog.DialogUpgrade;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.JsonResponse;
import com.linkxin.library.model.AppVersion;
import com.linkxin.library.utils.StrUtils;

import org.cocos2dx.lua.AppActivity;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Administrator on 2016-10-08.
 */
public class AppUpdateUtil {

    /**
     * 获取服务器最新版本号
     * @param activity
     */
    public static void CheckVersion(final Activity activity){

        Map<String, String> params = new HashMap<String, String>();
        params.put("type", "1");
        params.put("applicationType", "1");
        params.put("interfaceType","J");
        FinalHttpClient.getInstance().post(RequestURL.APP_VERSION, params, new FinalHttpClient.OnRequestListener() {
            @Override
            public void onFinish(JsonResponse response) {
                if (response.isSuccess()){
                    AppVersion version = response.readObject(AppVersion.class);
                    if (version == null){
                        return;
                    }
                    compareVersion(activity,version);
                }
            }
        });

    }

    /**
     * 比较本地应用版本
     * @param activity
     * @param version
     * @return
     */
    public static boolean compareVersion(final Activity activity, final AppVersion version){

        try{
            // 本地应用版本
            String currentVersion = getVersionName(activity);

            // 服务器当前版本
            String latestVersion = version.getVersion();

            // 当前是最新版本
            if (!StrUtils.hasNewVersion(currentVersion, latestVersion)) {
                return false;
            }

            // 显示更新对话框
            final DialogUpgrade dialog = new DialogUpgrade(activity,version);
            dialog.setOnUpgradeListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    openBrower(activity,version.getUpdateUrl());
                    dialog.dismiss();
                }
            });
            dialog.setIKnowListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    activity.startActivity(new Intent(activity, AppActivity.class));
                    activity.finish();
                    dialog.dismiss();
                }
            });
            dialog.show();

            return true;

        }catch (Exception e){
            e.printStackTrace();
            return false;
        }

    }

    /**
     * 获取本地应用版本
     * @param activity
     * @return
     */
    public static String getVersionName(Activity activity) {

        if (activity == null) {
            return "";
        }

        String versionName = "";
        try {
            versionName = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0).versionName;
            versionName = versionName.replace("-","");
            versionName = versionName.replace("debug","");
            versionName = versionName.replace("release","");
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        return versionName;

    }

    /**
     * 打开浏览器下载
     * @param activity
     * @param url
     */
    protected static void openBrower(Activity activity, String url){

        Uri uri = Uri.parse(url);
        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
        activity.startActivity(intent);

    }

}
