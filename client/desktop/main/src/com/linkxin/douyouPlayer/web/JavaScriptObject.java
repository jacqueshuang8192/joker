package com.linkxin.douyouPlayer.web;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.activity.base.BaseActivity;
import com.linkxin.douyouPlayer.activity.web.WebActivity;
import com.linkxin.douyouPlayer.constant.DouyouConstants;
import com.linkxin.douyouPlayer.dialog.SingleChoseDialog;
import com.linkxin.douyouPlayer.http.PublicMethod;
import com.linkxin.douyouPlayer.vo.Player;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.JsonResponse;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.util.DateUtil;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.util.ToastUtil;
import com.linkxin.douyouPlayer.view.PublicViews;
import com.linkxin.douyouPlayer.vo.DouyouUser;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.View;
import android.webkit.JavascriptInterface;
import android.widget.Toast;

import net.tsz.afinal.FinalDb;

import java.util.HashMap;
import java.util.Map;

import de.greenrobot.event.EventBus;

/**
 * Web调用本地代码
 * 
 * @author Administrator
 * 
 */
public class JavaScriptObject {
	
	Context context;
	BaseActivity baseActivity;
	Handler handler = new Handler(Looper.getMainLooper());

	public JavaScriptObject(Context context) {
		this.context = context;
	}
	
	public JavaScriptObject(Context context,BaseActivity baseActivity) {
		this.context = context;
		this.baseActivity = baseActivity;
	}

	/**
	 * 显示Toast
	 * @param content
	 */
	@JavascriptInterface
	public void showToast(String content) {
		Toast.makeText(context, content, Toast.LENGTH_SHORT).show();
	}
	
	/**
	 * 显示加载圈
	 */
	@JavascriptInterface
	public void showLoading() {
		PublicViews.ShowLoading(context);
	}

	/**
	 * 显示成功信息
	 */
	@JavascriptInterface
	public void showSuccess(final String msg) {
		handler.post(new Runnable() {
			@Override
			public void run() {
				PublicViews.HideLoading();
				PublicViews.ShowDialog(context,"提示",msg,"我知道了",null);
			}
		});
	}
	
	/**
	 * 隐藏加载圈
	 * @param msg
	 */
	@JavascriptInterface
	public void hideLoading(final String msg) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                PublicViews.HideLoading();

                if(!msg.equals("0")){
                    if(msg.equals("301")){
                        PublicViews.ShowDialog(context, "错误", "道具不足", "快去购买", new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                Intent i = new Intent(context, WebActivity.class);
                                i.putExtra("title", context.getString(R.string.propshop));
                                String url = PublicMethod.getPropstoreUrl(context,SPUtil.getCurrentUserId(context));
                                i.putExtra("url", url);
                                PublicViews.hideDialog();
                                context.startActivity(i);
                            }
                        });
                    }else{
                        PublicViews.ShowDialog(context, "错误", msg, "我知道了", null);
                    }
                }
            }
        });
	}
	
	/**
	 * 获取经纬度
	 */
	@JavascriptInterface
	public void getLocation() {
		
	}
	
	/**
	 * 测试
	 */
	@JavascriptInterface
	public void MyAppTest() {
		
	}

	/**
	 * 跳转到任意界面
	 * @param title
	 * @param url
	 */
	@JavascriptInterface
	public void toWebActivity(final String title, final String url) {
		handler.post(new Runnable() {
			@Override
			public void run() {
				Intent i = new Intent(context,WebActivity.class);
				i.putExtra("title", title);
				i.putExtra("url", url);
				context.startActivity(i);
			}
		});
	}

	/**
	 * 跳转到约饭消息
	 * @param title
	 * @param url
	 */
	@JavascriptInterface
	public void ToMyMessage(final String title, final String url) {
		handler.post(new Runnable() {
			@Override
			public void run() {
				Intent i = new Intent(MyApplication.applicationContext,WebActivity.class);
				i.putExtra("title", title);
				i.putExtra("url", url);
				context.startActivity(i);
			}
		});
	}

	/**
	 * 跳转到店铺列表
	 * @param title
	 * @param url
	 */
	@JavascriptInterface
	public void toStoreList(String title, String url) {
		Intent i = new Intent(context,WebActivity.class);
		i.putExtra("title", title);
		i.putExtra("url", url);
		i.putExtra("nowAT", 2);
		context.startActivity(i);
	}
	
	/**
	 * 跳转到个人资料页面
	 * @param userId
	 * @param nickName
	 * @param hasSociety
	 * @param userType
	 */
	@JavascriptInterface
	public void toWebActivity(final String userId, final String nickName, final String hasSociety, final String userType) {

	}

	/**
	 * 排行榜跳转到用户信息
	 * @param userId
	 * @param nickName
	 * @param society
	 * @param userType
     */
	@JavascriptInterface
	public void toAnchorInformationViewController(final String userId,final String nickName,final String society,final String userType){

        handler.post(new Runnable() {
            @Override
            public void run() {
                toPageActivity(userId,userType);
            }
        });

	}

    private void toPageActivity(String userId,String userType){

    }
	
	/**
	 * 跳转到聊天页面 
	 * @param phone
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param userType
	 */
	@JavascriptInterface
	public void toChatViewController(String phone, String userId,String nickName,String photoUrl,String userType) {

	}
	
	/**
	 * 跳转到地图
	 * @param title
	 * @param url
	 */
	@JavascriptInterface
	public void toMap(final String title,final String url) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Intent i = new Intent(MyApplication.applicationContext,WebActivity.class);
                i.putExtra("title", title);
                i.putExtra("url", url);
                i.putExtra("nowAT", 1);
                context.startActivity(i);
            }
        });
	}
	
	/**
	 * 跳转到公会详情
	 * @param title
	 * @param url
	 * @param societyId
	 */
	@JavascriptInterface
	public void toWebActivity(final String title, final String url,final String societyId) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Intent i = new Intent(context,WebActivity.class);
                i.putExtra("title", title);
                i.putExtra("url", url);
				i.putExtra("nowAT", 7);
				MyApplication.othersocietyId = societyId;
                context.startActivity(i);
            }
        });

	}

	/**
	 * 跳转到公会成员列表
	 */
	@JavascriptInterface
	public void toShowSocietyMenber() {

	}

	/**
	 * 申请加入公会
	 * @param societyId
	 * @param societyName
	 * @param masterPhone
     */
	@JavascriptInterface
	public void joinSociety(String societyId, String societyName, String masterPhone) {

		PublicViews.ShowLoading(context);

		JSONObject object = new JSONObject();
		try {
			object.put("userId", MyApplication.userId);
			object.put("nickname", MyApplication.nickName);
			object.put("phone", MyApplication.phone);
			object.put("photoUrl", MyApplication.photoUrl);
			object.put("type", DouyouConstants.EMCHAT_JOIN_SOCIETY);
			object.put("societyId", societyId);
			object.put("societyName", societyName);
			object.put("timeStamp", DateUtil.timeStamp());
			object.put("userType", "P");
			object.put("reason", "我是" + MyApplication.nickName);
		} catch (JSONException e) {
			e.printStackTrace();
		}

		final Map<String,String> params = new HashMap<String,String>();
		params.put("phone", masterPhone);
		params.put("message", object.toString());

		FinalHttpClient.getInstance().post(RequestURL.TRANSMIT_VERIFY_MESSAGE_URL, params, new FinalHttpClient.OnRequestListener() {

			@Override
			public void onFinish(JsonResponse response) {

				PublicViews.HideLoading();

				if (response.isSuccess()){
					ToastUtil.showBaseToast(context,"申请成功！");
				}else {
					PublicViews.ShowErrorDialog(context, response.getError());
				}
			}
		});

	}

	/**
	 * 退出公会
	 */
	@JavascriptInterface
	public void exitSociety(){

		ToastUtil.showBaseToast(context,"退出公会成功！");

		// 设置需要刷新公会界面
		MyApplication.isloadSociety = true;

		// 设置我的公会为未加入公会
		MyApplication.society = "未加入公会";
		MyApplication.societyId = "0";

		// 更新本地数据库
		FinalDb finalDb = FinalDb.create(context);
		DouyouUser user = finalDb.findById(MyApplication.userId, DouyouUser.class);
		user.setSociety("未加入公会");
		user.setSociety("0");
		finalDb.update(user);

	}

	/**
	 * 跳转到抢矿界面
	 * @param title
	 * @param url
	 * @param chatroomId
	 * @param activityId
     */
	@JavascriptInterface
	public void toRobMine(final String title,final String url,final String chatroomId, final String activityId) {

	}

	/**
	 * 记录当前矿坑
	 * @param nowMineSectionId
     */
	@JavascriptInterface
	public void saveNowMineSectionId(final String nowMineSectionId) {
		handler.post(new Runnable() {
			@Override
			public void run() {
				MyApplication.nowMineSectionId = nowMineSectionId;
			}
		});
	}
	
	/**
	 * 保存收益
	 * @param profit
	 */
	@JavascriptInterface
	public void saveProfit(final String profit) {

	}
	
	/**
	 * 充值
	 * @param price 价格（人民币数）
	 * @param amount 价格（宝贝币数）
	 */
	@JavascriptInterface
	public void buyAction(final String price,final String amount) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                ((WebActivity)baseActivity).showChoosePayChannel(price, amount);
            }
        });
	}

    /**
     * 兑换钻石后减金币
     * @param coinAmount
     * @param jewelAmount
     */
    @JavascriptInterface
    public void ExchangeAfter(final String coinAmount,final String jewelAmount ){
        handler.post(new Runnable() {
            @Override
            public void run() {
                int coin = toInt(coinAmount);
                int jewe = toInt(jewelAmount);
                DouyouUser user = SPUtil.getCurrentUser(context);
                int remainCoin = user.getCoinAmount()-coin;
                if(remainCoin <=0){
                    remainCoin = 0;
                }
                user.setCoinAmount(remainCoin);
                user.setJewelAmount(user.getJewelAmount() + jewe);
                SPUtil.updateCurrentUser(context,user);
            }
        });

    }

    /**
     * 赠送钻石后刷新钻石数量
     */
    @JavascriptInterface
    public void giveDiamonds(final String costJewelAmount){
        handler.post(new Runnable() {
            @Override
            public void run() {
                int costJewel = toInt(costJewelAmount);
                DouyouUser user = SPUtil.getCurrentUser(context);
                int remainJewel = user.getJewelAmount()-costJewel;
                if(remainJewel <=0){
                    remainJewel = 0;
                }
                user.setJewelAmount(remainJewel);
                SPUtil.updateCurrentUser(context,user);
            }
        });
    }

    private int toInt(String value){
        try {
            if (TextUtils.isEmpty(value)){
                return 0;
            }
            if (!TextUtils.isDigitsOnly(value)){
                return 0;
            }
            return Integer.valueOf(value);

        }catch (Exception e){
            e.printStackTrace();
            return 0;
        }
    }

}
