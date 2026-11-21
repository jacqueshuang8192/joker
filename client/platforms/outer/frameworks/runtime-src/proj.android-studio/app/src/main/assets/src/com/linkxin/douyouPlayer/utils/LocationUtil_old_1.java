package com.linkxin.douyouPlayer.utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.widget.Toast;

import com.linkxin.douyouPlayer.util.SPUtil;

import java.util.List;

/**
 * Created by Administrator on 2017-01-09.
 */
public class LocationUtil_old {

    public static LocationManager locationManager;
    public static LocationListener locationListener;

    /**
     * 判断GPS模块是否存在或者是开启
     */
    public static void isGPSProviderEnabled(final Activity context){

        if (locationManager == null){
            locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
        }

        if (locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
            Toast.makeText(context, "GPS模块正常", Toast.LENGTH_SHORT).show();
            return;
        }

        Toast.makeText(context, "请开启GPS！",Toast.LENGTH_SHORT).show();
        Intent intent = new Intent(Settings.ACTION_SECURITY_SETTINGS);
        context.startActivityForResult(intent,0); //此为设置完成后返回到获取界面

    }

    /**
     * 获取地理位置
     * @param context
     */
    public static void getLoactionServe(final Context context){

        String locationProvider;

        //获取地理位置管理器
        closeLoactionServe();
        if (locationManager == null){
            locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
        }

        //获取所有可用的位置提供器
        List<String> providers = locationManager.getProviders(true);
        if(providers.contains(LocationManager.NETWORK_PROVIDER)){

            // 如果是Network
            locationProvider = LocationManager.NETWORK_PROVIDER;

        }else{

            if (providers.contains(LocationManager.GPS_PROVIDER)){

                // 如果是GPS
                locationProvider = LocationManager.GPS_PROVIDER;

            }else{

//                Toast.makeText(context, "没有可用的位置提供器", Toast.LENGTH_SHORT).show();
                return ;

            }

        }

        //获取Location
        Location location = locationManager.getLastKnownLocation(locationProvider);
        if (location != null){
            SPUtil.setString(context, "Longitude", Double.toString(location.getLongitude()));
            SPUtil.setString(context, "Latitude",  Double.toString(location.getLatitude()));
        }

        //监视地理位置变化
        locationListener =  new LocationListener() {

            @Override
            public void onLocationChanged(Location location) {

                SPUtil.setString(context, "Longitude", Double.toString(location.getLongitude()));
                SPUtil.setString(context, "Latitude",  Double.toString(location.getLatitude()));

                Log.d("-----LoactionServe-----", "经度：" + Double.toString(location.getLongitude()));
                Log.d("-----LoactionServe-----", "纬度：" + Double.toString(location.getLatitude()));

//                Toast.makeText(context, "经度：" + SPUtil.getString(context, "Longitude") + ",纬度：" + SPUtil.getString(context, "Latitude"), Toast.LENGTH_SHORT).show();

//                LuaJavaBridgeTest.setLocation();

            }

            @Override
            public void onStatusChanged(String provider, int status, Bundle extras) {

                Log.d("-----LoactionServe-----", provider + " 状态改变：" + status);

            }

            @Override
            public void onProviderEnabled(String provider) {

                Log.d("-----LoactionServe-----", "定位可用");

            }

            @Override
            public void onProviderDisabled(String provider) {

                Log.d("-----LoactionServe-----", "定位不可用");

            }

        };
        locationManager.requestLocationUpdates(locationProvider, 5000, 1, locationListener);

    }

    /**
     * 关闭定位服务
     */
    public static void closeLoactionServe(){

        if (locationManager != null){
            if (locationListener != null){
                //移除监听器
                locationManager.removeUpdates(locationListener);
            }
            locationManager = null;
        }

    }

}
