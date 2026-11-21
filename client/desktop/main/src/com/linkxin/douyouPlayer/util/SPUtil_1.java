package com.linkxin.douyouPlayer.util;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.text.TextUtils;
import android.util.Base64;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.Calendar;

import net.tsz.afinal.FinalDb;
import com.linkxin.douyouPlayer.constant.DouyouConstants;
import com.linkxin.douyouPlayer.utils.JSONUtils;
import com.linkxin.douyouPlayer.vo.DouyouUser;

/**
 * SharedPreferences 数据存储工具类
 *
 * @author lxy
 */
public class SPUtil {
    private static String PreferenceName = "douyou_sp";
    
    public static String SP_USERNAME = "username";
    public static String SP_PASSWORD = "password";
    public static String SP_USERID = "user_id";
    public static String SP_DOUYOU_USER = "douyou_user";
    public static String SP_GOOD_DISCOUNT = "goodsDiscount";
    public static String SP_PRESSENT_DISCOUNT = "presentDiscount";
    public static String SP_IS_THIRD_PARTY_LOGIN = "isThirdPartyLogin";

    /**
     * 设置文件名
     *
     * @param preferenceName
     */
    public static void setPreferenceName(String preferenceName) {
        PreferenceName = preferenceName;
    }

    /**
     * 储存复杂的数据字段对象
     *
     * @param context
     * @param key
     * @param t
     * @return
     */
    public static <T> boolean setObjectToShare(Context context, String key, T t) {
        return setObjectToShare(context, PreferenceName, key, t);
    }

    /**
     * @param context
     * @param name
     * @param key
     * @param t
     * @return
     */
    public static <T> boolean setObjectToShare(Context context, String name,
                                                String key, T t) {
        try {
            SharedPreferences sp = context.getSharedPreferences(name,
                    Context.MODE_PRIVATE);
            // 存储
            Editor editor = sp.edit();
            if (t == null) {
                editor.putString(key, "");
                editor.commit();
                return true;
            }
            ByteArrayOutputStream toByte = new ByteArrayOutputStream();
            ObjectOutputStream oos;

            oos = new ObjectOutputStream(toByte);
            oos.writeObject(t);
            // 对byte[]进行Base64编码
            String payCityMapBase64 = new String(Base64.encode(
                    toByte.toByteArray(), Base64.DEFAULT));

            editor.putString(key, payCityMapBase64);
            editor.commit();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 得到复杂的数据对象
     *
     * @param context
     * @param key
     * @return
     */
    public static <T> T getObjectFromShare(Context context, String key) {
        return getObjectFromShare(context, PreferenceName, key);
    }

    /**
     * 得到复杂的数据对象
     *
     * @param key
     * @param name
     */
    @SuppressWarnings("unchecked")
    public static <T> T getObjectFromShare(Context context, String name,
                                           String key) {
        try {
            SharedPreferences sp = context.getSharedPreferences(name,
                    Context.MODE_PRIVATE);
            String payCityMapBase64 = sp.getString(key, "");
            if (payCityMapBase64.length() == 0) {
                return null;
            }
            byte[] base64Bytes = Base64
                    .decode(payCityMapBase64, Base64.DEFAULT);
            ByteArrayInputStream bais = new ByteArrayInputStream(base64Bytes);
            ObjectInputStream ois = new ObjectInputStream(bais);
            return (T) ois.readObject();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 存储字符串数据类型
     *
     * @param key
     * @param value
     */
    public static void setString(Context context, String key, String value) {
        SharedPreferences sp = context.getSharedPreferences(PreferenceName, Context.MODE_PRIVATE);
        Editor editor = sp.edit();
        editor.putString(key, value);
        editor.commit();
    }

    /**
     * 返回String类型数据，默认是“”；
     *
     * @param key
     * @return
     */
    public static String getString(Context context, String key) {
        return getString(context, key,"");
    }

    /**
     * 返回String类型数据，默认是“”；
     *
     * @param key
     * @return
     */
    public static String getString(Context context, String key, String defValue) {
        SharedPreferences sp = context.getSharedPreferences(PreferenceName, Context.MODE_PRIVATE);
        return sp.getString(key, defValue);
    }

    /**
     * 存储boolean数据类型
     *
     * @param key
     * @param value
     */
    public static void setboolean(Context context, String key, boolean value) {
        SharedPreferences sp = context.getSharedPreferences(PreferenceName, Context.MODE_PRIVATE);
        Editor editor = sp.edit();
        editor.putBoolean(key, value);
        editor.commit();
    }

    /**
     * 返回boolean类型数据，默认是true；
     *
     * @param key
     * @return
     */
    public static boolean getBoolean(Context context, String key) {
        return getBoolean(context, key, false);
    }

    /**
     * * 返回boolean类型数据
     * @param context
     * @param key
     * @param defValue
     * @return
     */
    public static boolean getBoolean(Context context, String key,boolean defValue) {
        SharedPreferences sp = context.getSharedPreferences(PreferenceName, Context.MODE_PRIVATE);
        return sp.getBoolean(key, defValue);
    }

    /**
     * 存储int数据类型
     *
     * @param key
     * @param value
     */
    public static void setInt(Context context, String key, int value) {
        SharedPreferences sp = context.getSharedPreferences(PreferenceName, Context.MODE_PRIVATE);
        Editor editor = sp.edit();
        editor.putInt(key, value);
        editor.commit();
    }

    /**
     * 返回int类型数据，默认是true；
     *
     * @param key
     * @return
     */
    public static int getInt(Context context, String key) {
       return getInt(context, key,0);
    }

    /**
     * 返回int类型数据；
     *
     * @param key
     * @param defaultValue
     * @return
     */
    public static int getInt(Context context, String key, int defaultValue) {
        SharedPreferences sp = context.getSharedPreferences(PreferenceName, Context.MODE_PRIVATE);
        return sp.getInt(key, defaultValue);
    }

    /**
     * 存储float数据类型
     *
     * @param key
     * @param value
     */
    public static void setFloat(Context context, String key, float value) {
        SharedPreferences sp = context.getSharedPreferences(PreferenceName, Context.MODE_PRIVATE);
        Editor editor = sp.edit();
        editor.putFloat(key, value);
        editor.commit();
    }

    /**
     * 返回float类型数据，默认是true；
     *
     * @param key
     * @return
     */
    public static float getFloat(Context context, String key) {
        SharedPreferences sp = context.getSharedPreferences(PreferenceName, Context.MODE_PRIVATE);
        return sp.getFloat(key, 0);
    }

    /**
     * 存储long数据类型
     *
     * @param key
     * @param value
     */
    public static void setLong(Context context, String key, long value) {
        SharedPreferences sp = context.getSharedPreferences(PreferenceName, Context.MODE_PRIVATE);
        Editor editor = sp.edit();
        editor.putLong(key, value);
        editor.commit();
    }

    /**
     * 返回long类型数据，默认是0；
     * @param key
     * @return
     */
    public static long getLong(Context context, String key) {
        return getLong(context,key,0);
    }

    /**
     * 返回long类型数据
     *
     * @param key
     * @return
     */
    public static long getLong(Context context, String key,long defValue) {
        SharedPreferences sp = context.getSharedPreferences(PreferenceName, Context.MODE_PRIVATE);
        return sp.getLong(key, defValue);
    }

    public static SharedPreferences getPreferences(Context context) {
		return context.getSharedPreferences(PreferenceName, Context.MODE_PRIVATE);
	}
    
    public static Editor getEditor(Context context) {
  		return getPreferences(context).edit();
  	}
    
    /**
     * 清除所有缓存
     * @param context
     */
    public static void clearCache(Context context){
    	getEditor(context).clear().commit();
    }
    
    
    public static void onSaveUserJson(Context context,String json){
    	setString(context, SP_DOUYOU_USER, json);
    }

    /**
     * 登录成功，保存用户登录数据
     * @param context
     * @param username
     * @param password
     * @param userid
     * @param douyouUser 当前登录用户最新信息
     * @param isThirdParty 是否第三方登录
     * @return
     */
    public static boolean onLoginSuccess(Context context,String username,String password,String userid,DouyouUser douyouUser, boolean isThirdParty){
    	/**
    	 * 当前用户名和密码保存至sp
    	 */
    	Editor editor = getEditor(context);
    	editor.putString(SP_USERNAME, username);
        editor.putString(SP_PASSWORD, password);
        if (isThirdParty) {
//            editor.remove(SP_USERNAME);
//            editor.remove(SP_PASSWORD);
            editor.putBoolean(SP_IS_THIRD_PARTY_LOGIN, true);
        } else {
            editor.putBoolean(SP_IS_THIRD_PARTY_LOGIN, false);
        }

    	editor.putString(SP_USERID, userid);
    	
    	/**
    	 * 登录成功，保存或更新当前用户
    	 * 支持多用户，数据库不保存用户名和密码
    	 */
    	DouyouUser u=getUser(context, userid);
    	FinalDb finalDb = FinalDb.create(context);
    	if (u== null) {
    		finalDb.save(douyouUser);
		}else {
			finalDb.update(douyouUser, String.format("userId=%s", userid));
		}
    	currentUser = douyouUser;//登录成功，最新缓存
    	
    	return editor.commit();
    }
    
    public static boolean onRegisterSuccess(Context context,String username,String password){
    	Editor editor = getEditor(context);
    	editor.putString(SP_USERNAME, username);
    	editor.putString(SP_PASSWORD, password);
    	
    	return editor.commit();
    }
    
    
    /**
     * 是否已登录
     * @param context
     * @return
     */
    public static boolean isLogined(Context context){
    	SharedPreferences sp = getPreferences(context);
    	String username = sp.getString(SP_USERNAME, "");
    	String password = sp.getString(SP_PASSWORD, "");

        return !(TextUtils.isEmpty(username) || TextUtils.isEmpty(password));
    }
    
    public static void logout(Context context){
    	setString(context, SP_USERNAME, "");
    	setString(context, SP_PASSWORD, "");
    }
    
    /**
     * 获取当前登录用户ID
     * 可用于查询最后一次登录用户信息做自动登录
     * @param context
     * @return
     */
    public static String getCurrentUserId(Context context){
    	return getString(context, SP_USERID,"");
    }
    
    public static DouyouUser getUser(Context context,String userid){
    	if (TextUtils.isEmpty(userid)) {
			return null;
		}
    	FinalDb finalDb = FinalDb.create(context,DouyouConstants.IS_DEBUG);
    	DouyouUser user = finalDb.findById(userid, DouyouUser.class);
    	return user;
    }
    
    
    /**
     * 获取当前登录用户
     */
    private static DouyouUser currentUser;
    public static DouyouUser getCurrentUser(Context context){
    	//缓存不为空，则拿缓存数据
    	if (currentUser !=null) {
			return currentUser;
		}else {
			//从数据库查询
			String userId = getCurrentUserId(context);
			currentUser = getUser(context, userId);
	    	return currentUser;
		}
    }
    
    /**
     * 更新当前登录用户信息
     * @param context
     * @param user
     * @return
     */
    public static boolean updateCurrentUser(Context context, DouyouUser user){
    	
    	if (user == null) {
			return false;
		}
    	String userid = user.getUserId();

    	FinalDb finalDb = FinalDb.create(context);
    	finalDb.update(user, String.format("userId='%s'", userid));
    	currentUser = user;//更新缓存
    	
    	return true;
    }

    /**
     * 是否需要显示每日任务对话框
     * 保证每日仅显示一次
     * @param context
     * @return
     */
    public static boolean isTaskShowable(Context context){
        String key = "day";
        Calendar calendar = Calendar.getInstance();
        int dayOfYear = calendar.get(Calendar.DAY_OF_YEAR);
        int day = getInt(context,key,0);
        if (day == dayOfYear){
            return false;
        }else {
            setInt(context,key,dayOfYear);
            return true;
        }
    }

    /**
     * 折扣相关
     * @param context
     * @return
     */
    public static double getGoodDiscount(Context context){
        String v = getString(context,SP_GOOD_DISCOUNT,"1.0");
        return Double.valueOf(v);
    }

    public static void updateGoodDiscount(Context context,double value){
        setString(context,SP_GOOD_DISCOUNT,String.valueOf(value));
    }

    public static double getPressentDiscount(Context context){
        String v = getString(context,SP_PRESSENT_DISCOUNT,"1.0");
        return Double.valueOf(v);
    }

    public static void updatePressentDiscount(Context context,double value){
        setString(context,SP_PRESSENT_DISCOUNT,String.valueOf(value));
    }
}
