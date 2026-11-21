package com.linkxin.douyouPlayer.http;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.web.WebActivity;
import com.linkxin.douyouPlayer.constant.DouyouConstants;
import com.linkxin.douyouPlayer.util.DBUtils;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.FinalHttpClient.OnRequestListener;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.view.PublicViews;
import com.linkxin.douyouPlayer.vo.DouyouUser;
import com.linkxin.douyouPlayer.vo.Props;
import com.linkxin.library.http.JsonResponse;

import org.json.JSONObject;

public class PublicMethod {

	/**
	 * 添加关注
	 * @param userId
	 * @param userType
	 * @param compereId
	 */
	public static void addAttention(String userId, String userType, String compereId){
		Map<String, String> params = new HashMap<String, String>();
		params.put("userId", userId);
		params.put("userType", userType);
		params.put("compereId", compereId);
		
		FinalHttpClient.getInstance().post(RequestURL.GetCompereCaptureStatus_URL, params, new OnRequestListener() {
			
			@Override
			public void onFinish(JsonResponse response) {
				// TODO Auto-generated method stub
				if (response.isSuccess()) {
					
				}else{
					
				}
			}
		});
	}

	/**
	 * 计算地球上任意两点(经纬度)距离
	 *
	 * @param long1
	 *            第一点经度
	 * @param lat1
	 *            第一点纬度
	 * @param long2
	 *            第二点经度
	 * @param lat2
	 *            第二点纬度
	 * @return 返回距离 单位：米或千米
	 */
	public static String Distance(double long1, double lat1, double long2,
								  double lat2) {
		double a, b, R;
		R = 6378137; // 地球半径
		lat1 = lat1 * Math.PI / 180.0;
		lat2 = lat2 * Math.PI / 180.0;
		a = lat1 - lat2;
		b = (long1 - long2) * Math.PI / 180.0;
		double d;
		double sa2, sb2;
		sa2 = Math.sin(a / 2.0);
		sb2 = Math.sin(b / 2.0);
		d = 2 * R * Math.asin(Math.sqrt(sa2 * sa2 + Math.cos(lat1) * Math.cos(lat2) * sb2 * sb2));

		if(d >= 1000){
			d = d / 1000;
			return (int)d + "KM";
		}

		return (int)d + "M";
	}

	/**
	 * 获取公会列表
	 * @param context
	 * @param list  0 我的公会 1 附近的公会 2 可抢公会
	 * @param userId
	 * @param type  p 玩家 c 主播
     * @return
     */
	public static String getSocietyUrl(Context context, String list, String userId, String type, String societyId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&cityId=" + DBUtils.getCurrentUserCity(context).getSocietyCityId() +
				"&list=" + list +
				"&userId=" + userId +
				"&type=" + type +
				"&mysocietyId=" + societyId +
				"&latitude=" + MyApplication.latitude +
				"&longitude=" + MyApplication.longitude +
				"#society/society";
		return url;
	}

	/**
	 * 获取公会详情
	 * @param context
	 * @param userId
	 * @param type
	 * @param societyId
	 * @param mysocietyId
     * @return
     */
	public static String getSocietydetailUrl(Context context, String userId, String type, String societyId, String mysocietyId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"&type=" + type +
				"&societyId=" + societyId +
				"&mysocietyId=" + mysocietyId +
				"&latitude=" + MyApplication.latitude +
				"&longitude=" + MyApplication.longitude +
				"#society/societydetail";
		return url;
	}

	/**
	 * 获取玩家任务
	 * @param context
	 * @param userId
	 * @return
	 */
	public static String getPlayerTaskUrl(Context context, String userId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"&type=p" +
				"#task/task";
		return url;
	}

	/**
	 * 获取玩家端排行榜
	 * @param context
	 * @param userId
	 * @return
	 */
	public static String getPlayerRankingUrl(Context context, String userId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"&type=c" +
				"#mydetails/paihang-richlist";
		return url;
	}

	/**
	 * 获取道具商城
	 * @param context
	 * @param userId
	 * @return
	 */
	public static String getPropstoreUrl(Context context, String userId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"&goodsDiscount="+SPUtil.getGoodDiscount(context) +
				"#prop/propstore";
		return url;
	}

	/**
	 * 获取我的道具
	 * @param context
	 * @param userId
	 * @return
	 */
	public static String getMypropUrl(Context context, String userId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"#prop/myprop";
		return url;
	}

	/**
	 * 获取线下商城
	 * @param context
	 * @param userId
	 * @return
	 */
	public static String getShoplistUrl(Context context, String userId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"&cityId=" + DBUtils.getCurrentUserCity(context).getOfflineStoreCityId() +
				"#shop/shoplist";
		return url;
	}

	/**
	 * 获取充值中心
	 * @param context
	 * @param userId
	 * @return
	 */
	public static String getRechargeCenterUrl(Context context, String userId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"#rechargeCenter/rechargeCenter";
		return url;
	}

	/**
	 * 获取充值记录
	 * @param context
	 * @param userId
	 * @return
	 */
	public static String getRechargerecordUrl(Context context, String userId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"#rechargeCenter/rechargerecord";
		return url;
	}

	/**
	 * 获取钻石兑换
	 * @param context
	 * @param userId
	 * @return
	 */
	public static String getExchangeDiamondUrl(Context context, String userId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"#exchangeDiamond/exchangeDiamond";
		return url;
	}

	/**
	 * 获取兑换记录
	 * @param context
	 * @param userId
	 * @return
	 */
	public static String getExchangerecordUrl(Context context, String userId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"#exchangeDiamond/exchangerecord";
		return url;
	}

	/**
	 * 获取我的守护
	 * @param context
	 * @param userId
	 * @return
	 */
	public static String getGuardCompereUrl(Context context, String userId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"&latitude=" + MyApplication.latitude +
				"&longitude=" + MyApplication.longitude +
				"#guard/guard_compere";
		return url;
	}

	/**
	 * 获取我的关注
	 * @param context
	 * @param userId
	 * @return
	 */
	public static String getMyFocusUrl(Context context, String userId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"&latitude=" + MyApplication.latitude +
				"&longitude=" + MyApplication.longitude +
				"#mydetails/my-focus";
		return url;
	}

	/**
	 * 获取我的段位
	 * @param context
	 * @param userId
	 * @return
	 */
	public static String getDuanListUrl(Context context, String userId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"#mydetails/duan-list";
		return url;
	}

	/**
	 * 获取我的后宫
	 * @param context
	 * @param userId
	 * @param isself
	 * @return
	 */
	public static String getMyWivesUrl(Context context, String userId, String isself){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"&isself=" + isself +
				"#guard/getMyWives";
		return url;
	}

	/**
	 * 获取我的粉丝
	 * @param context
	 * @param userId
	 * @return
	 */
	public static String getMyFansUrl(Context context, String userId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"&latitude=" + MyApplication.latitude +
				"&longitude=" + MyApplication.longitude +
				"#mydetails/my-fans";
		return url;
	}

	/**
	 * 获取守护我的
	 * @param context
	 * @param userId
	 * @return
	 */
	public static String getCompereguardUrl(Context context, String userId){
		String url = RequestURL.HTML_HOST + RequestURL.PROJECTPATH + "index.html?plat=2" +
				"&userId=" + userId +
				"&latitude=" + MyApplication.latitude +
				"&longitude=" + MyApplication.longitude +
				"#guard/compere_guard";
		return url;
	}
	
}
