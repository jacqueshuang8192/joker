package com.linkxin.douyouPlayer.http;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import junit.framework.Assert;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Bitmap.CompressFormat;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.WindowManager;
import android.widget.Toast;

import com.cocos2dx.sample.LuaJavaBridgeTest.LuaJavaBridgeTest;
import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.util.ToastUtil;
import com.linkxin.douyouPlayer.view.PublicViews;
import com.tencent.mm.sdk.modelmsg.SendAuth;
import com.tencent.mm.sdk.modelmsg.SendMessageToWX;
import com.tencent.mm.sdk.modelmsg.WXImageObject;
import com.tencent.mm.sdk.modelmsg.WXMediaMessage;
import com.tencent.mm.sdk.modelmsg.WXTextObject;
import com.tencent.mm.sdk.modelmsg.WXWebpageObject;
import com.tencent.mm.sdk.openapi.IWXAPI;
//import com.tencent.mm.sdk.openapi.SendAuth;
//import com.tencent.mm.sdk.openapi.SendMessageToWX;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
//import com.tencent.mm.sdk.openapi.WXImageObject;
//import com.tencent.mm.sdk.openapi.WXMediaMessage;
//import com.tencent.mm.sdk.openapi.WXTextObject;
//import com.tencent.mm.sdk.openapi.WXWebpageObject;

public class WXPublicMethod {

	// APP_ID 替换为你的应用从官方网站申请到的合法appId
	public static final String WXAPP_ID = RequestURL.WXAPP_ID;

	// APP_ID 替换为你的应用从官方网站申请到的合法appId
	public static final String WXAPP_SECRET = RequestURL.WXAPP_SECRET;

	// WXTag
	private static final String TAG = "WXUtil";

	// 最大编码后图片大小
	private static final int MAX_DECODE_PICTURE_SIZE = 1920 * 1440;

	// 缩略图尺寸
	private static final int THUMB_SIZE = 150;

	// 发送场景
	public static final int WXSceneSession = 0;// 聊天界面
	public static final int WXSceneTimeline = 1;// 朋友圈
	public static final int WXSceneFavorite = 2;// 微信收藏

	// IWXAPI 是第三方app和微信通信的openapi接口
	private static IWXAPI api;

	/**
	 * 注册应用
	 * @param context
	 */
	public static void registerApp(Context context){

		// 通过WXAPIFactory工厂，获取IWXAPI的实例
		api = WXAPIFactory.createWXAPI(context, WXAPP_ID, false);

		// 将app注册到微信
		api.registerApp(WXAPP_ID);

	}

	/**
	 * 注册应用2
	 * @param context
	 */
	public static IWXAPI registerAppAndGetAPI(Context context){

		// 通过WXAPIFactory工厂，获取IWXAPI的实例
		api = WXAPIFactory.createWXAPI(context, WXAPP_ID, false);

		// 将app注册到微信
		api.registerApp(WXAPP_ID);

		return api;

	}

	/**
	 * 判断微信是否可用
	 * @return
	 */
	public static boolean isWXAppInstalledAndSupported() {
		return (api.isWXAppInstalled() && api.isWXAppSupportAPI());
	}

	/**
	 * 发送文字
	 * @param context
	 * @param text
	 * @param scene
	 */
	public static void SendText(Context context, String text, int scene){

		SPUtil.setString(MyApplication.gameActivity, "WXHandle", "share");

		// 注册应用
		registerApp(context);

		// 初始化一个WXTextObject对象
		WXTextObject textObj = new WXTextObject();
		textObj.text = text;

		// 用WXTextObject对象初始化一个WXMediaMessage对象
		WXMediaMessage msg = new WXMediaMessage();
		msg.mediaObject = textObj;

		// 发送文本类型的消息时，title字段不起作用
		// msg.title = "Will be ignored";
		msg.description = text;

		// 构造一个Req
		SendMessageToWX.Req req = new SendMessageToWX.Req();
		req.transaction = buildTransaction("text"); // transaction字段用于唯一标识一个请求
		req.message = msg;

		if(scene == WXSceneSession){
			req.scene = SendMessageToWX.Req.WXSceneSession;
		}else if(scene == WXSceneTimeline){
			req.scene = SendMessageToWX.Req.WXSceneTimeline;
		}else if(scene == WXSceneFavorite){

		}

		// 调用api接口发送数据到微信
		api.sendReq(req);

	}

	/**
	 * 发送Bitmap图片
	 * @param context
	 * @param bmp
	 * @param scene
	 */
	public static void SendBitmap(Context context, Bitmap bmp, int scene){

		SPUtil.setString(MyApplication.gameActivity, "WXHandle", "share");

		// 注册应用
		registerApp(context);

		WXImageObject imgObj = new WXImageObject(bmp);

		WXMediaMessage msg = new WXMediaMessage();
		msg.mediaObject = imgObj;

		// 设置缩略图
		Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, THUMB_SIZE, THUMB_SIZE, true);
		bmp.recycle();
		msg.thumbData = bmpToByteArray(thumbBmp, true);

		SendMessageToWX.Req req = new SendMessageToWX.Req();
		req.transaction = buildTransaction("img");
		req.message = msg;

		if(scene == WXSceneSession){
			req.scene = SendMessageToWX.Req.WXSceneSession;
		}else if(scene == WXSceneTimeline){
			req.scene = SendMessageToWX.Req.WXSceneTimeline;
		}else if(scene == WXSceneFavorite){

		}

		// 调用api接口发送数据到微信
		api.sendReq(req);

	}

	/**
	 * 发送当前屏幕截图
	 * @param context
	 * @param path
	 * @param scene
	 */
	public static void SendScreenShop(Context context, String path, int scene, String description){

		SPUtil.setString(MyApplication.gameActivity, "WXHandle", "share");

		File file = new File(path);
		if (!file.exists()) {
			String tip = "文件不存在";
			Toast.makeText(context, tip + " path = " + path, Toast.LENGTH_LONG).show();
			return;
		}

		WXImageObject imgObj = new WXImageObject();
		imgObj.setImagePath(path);

		WXMediaMessage msg = new WXMediaMessage();
		msg.mediaObject = imgObj;

		Bitmap bmp = BitmapFactory.decodeFile(path);
		Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, THUMB_SIZE, THUMB_SIZE, true);
		bmp.recycle();
		msg.thumbData = bmpToByteArray(thumbBmp, true);

		SendMessageToWX.Req req = new SendMessageToWX.Req();
		req.transaction = buildTransaction("img");
		req.message = msg;

		if(scene == WXSceneSession){
			req.scene = SendMessageToWX.Req.WXSceneSession;
		}else if(scene == WXSceneTimeline){
			req.scene = SendMessageToWX.Req.WXSceneTimeline;
		}else if(scene == WXSceneFavorite){

		}

		// 调用api接口发送数据到微信
		api.sendReq(req);

//		// 注册应用
//		registerApp(context);
//
//		WindowManager windowManager = MyApplication.gameActivity.getWindowManager();
//		Display display = windowManager.getDefaultDisplay();
//		int w = display.getWidth();
//		int h = display.getHeight();
//		Bitmap Bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
//
//		// 2.获取屏幕
//		View decorview = MyApplication.gameActivity.getWindow().getDecorView();
//		decorview.setDrawingCacheEnabled(true);
//		Bmp = decorview.getDrawingCache();
//
//		WXImageObject imgObj = new WXImageObject(Bmp);
//
////		WXImageObject imgObj = new WXImageObject(bmp);
//
//		WXMediaMessage msg = new WXMediaMessage();
//		msg.title = "分享图片";
//		msg.description = description;
//		msg.mediaObject = imgObj;
//
//		// 设置缩略图
//		Bitmap thumbBmp = Bitmap.createScaledBitmap(Bmp, THUMB_SIZE, THUMB_SIZE, true);
////		Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, THUMB_SIZE, THUMB_SIZE, true);
//		bmp.recycle();
//		msg.thumbData = bmpToByteArray(thumbBmp, true);
//
//		SendMessageToWX.Req req = new SendMessageToWX.Req();
//		req.transaction = buildTransaction("img");
//		req.message = msg;
//
//		if(scene == WXSceneSession){
//			req.scene = SendMessageToWX.Req.WXSceneSession;
//		}else if(scene == WXSceneTimeline){
//			req.scene = SendMessageToWX.Req.WXSceneTimeline;
//		}else if(scene == WXSceneFavorite){
//
//		}
//
//		// 调用api接口发送数据到微信
//		api.sendReq(req);
	}

	/**
	 * 发送本地图片
	 * @param context
	 * @param path
	 * @param scene
	 */
	public static void SendlocalImage(Context context, String path, int scene){

		SPUtil.setString(MyApplication.gameActivity, "WXHandle", "share");

		// 注册应用
		registerApp(context);

		File file = new File(path);
		if (!file.exists()) {
			String tip = "文件不存在";
			Toast.makeText(context, tip + " path = " + path, Toast.LENGTH_LONG).show();
			return;
		}

		WXImageObject imgObj = new WXImageObject();
		imgObj.setImagePath(path);

		WXMediaMessage msg = new WXMediaMessage();
		msg.mediaObject = imgObj;

		Bitmap bmp = BitmapFactory.decodeFile(path);
		Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, 96, 54, true);
		bmp.recycle();
		msg.thumbData = bmpToByteArray(thumbBmp, true);

		SendMessageToWX.Req req = new SendMessageToWX.Req();
		req.transaction = buildTransaction("img");
		req.message = msg;

		if(scene == WXSceneSession){
			req.scene = SendMessageToWX.Req.WXSceneSession;
		}else if(scene == WXSceneTimeline){
			req.scene = SendMessageToWX.Req.WXSceneTimeline;
		}else if(scene == WXSceneFavorite){

		}

		// 调用api接口发送数据到微信
		api.sendReq(req);

	}

	/**
	 * 发送网络图片
	 * @param context
	 * @param scene
	 */
	public static void SendWebPicture(Context context, String url, int scene){

		SPUtil.setString(MyApplication.gameActivity, "WXHandle", "share");

		// 注册应用
		registerApp(context);

		try{
			WXImageObject imgObj = new WXImageObject();
			imgObj.imageUrl = url;

			WXMediaMessage msg = new WXMediaMessage();
			msg.mediaObject = imgObj;

			Bitmap bmp = BitmapFactory.decodeStream(new URL(url).openStream());
			Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, THUMB_SIZE, THUMB_SIZE, true);
			bmp.recycle();
			msg.thumbData = bmpToByteArray(thumbBmp, true);

			SendMessageToWX.Req req = new SendMessageToWX.Req();
			req.transaction = buildTransaction("img");
			req.message = msg;

			if(scene == WXSceneSession){
				req.scene = SendMessageToWX.Req.WXSceneSession;
			}else if(scene == WXSceneTimeline){
				req.scene = SendMessageToWX.Req.WXSceneTimeline;
			}else if(scene == WXSceneFavorite){

			}

			// 调用api接口发送数据到微信
			api.sendReq(req);

		} catch(Exception e) {
			e.printStackTrace();
		}

	}

	/**
	 * 发送网络链接
	 * @param context
	 * @param scene
	 */
	public static void SendUrl(Context context,String title, String description, String url, int scene){

		SPUtil.setString(MyApplication.gameActivity, "WXHandle", "share");

		// 注册应用
		registerApp(context);

		try{
			WXWebpageObject webpage = new WXWebpageObject();
			webpage.webpageUrl = url;

			WXMediaMessage msg = new WXMediaMessage(webpage);
			msg.title = title;
			msg.description = description;

			//这个地方要注意，缩略图要选尺寸合适的，尽量少，并且存放位置要对，不然分享会失效
			Bitmap thumb = BitmapFactory.decodeResource(context.getResources(), R.drawable.shareicon);
			msg.thumbData = bmpToByteArray(thumb, true);

			SendMessageToWX.Req req = new SendMessageToWX.Req();
			req.transaction = buildTransaction("webpage");
			req.message = msg;

			if(scene == WXSceneSession){
				req.scene = SendMessageToWX.Req.WXSceneSession;
			}else if(scene == WXSceneTimeline){
				req.scene = SendMessageToWX.Req.WXSceneTimeline;
			}else if(scene == WXSceneFavorite){

			}

			// 调用api接口发送数据到微信
			api.sendReq(req);

		} catch(Exception e) {
			e.printStackTrace();
		}

	}

	/**
	 * 发送授权
	 */
	public static void SendAuth(Context context){

		SPUtil.setString(MyApplication.gameActivity, "WXHandle", "login");

		// 注册应用
		registerApp(context);

		boolean isValid = isWXAppInstalledAndSupported();
		if (!isValid) {
			MyApplication.gameActivity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					Toast.makeText(MyApplication.gameActivity, "微信客户端未安装，请确认", Toast.LENGTH_LONG).show();
				}
			});
			LuaJavaBridgeTest.loginFail();
			return;
		} else {
			SendAuth.Req req = new SendAuth.Req();
			req.scope = "snsapi_userinfo";
			req.state = "SendAuth";
			api.sendReq(req);
		}

	}

	/**
	 * 注销
	 */
	public static void unregister(){
		api.unregisterApp();
	}

	/**
	 * 创建事务
	 * @param type
	 * @return
	 */
	private static String buildTransaction(final String type) {
		return (type == null) ? String.valueOf(System.currentTimeMillis()) : type + System.currentTimeMillis();
	}

	/**
	 * Bitmap转字节数组
	 * @param bmp
	 * @param needRecycle
	 * @return
	 */
	public static byte[] bmpToByteArray(final Bitmap bmp, final boolean needRecycle) {
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		bmp.compress(CompressFormat.PNG, 100, output);
		if (needRecycle) {
			bmp.recycle();
		}

		byte[] result = output.toByteArray();
		try {
			output.close();
		} catch (Exception e) {
			e.printStackTrace();
		}

		return result;
	}

	public static byte[] getHtmlByteArray(final String url) {
		URL htmlUrl = null;
		InputStream inStream = null;
		try {
			htmlUrl = new URL(url);
			URLConnection connection = htmlUrl.openConnection();
			HttpURLConnection httpConnection = (HttpURLConnection)connection;
			int responseCode = httpConnection.getResponseCode();
			if(responseCode == HttpURLConnection.HTTP_OK){
				inStream = httpConnection.getInputStream();
			}
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		byte[] data = inputStreamToByte(inStream);

		return data;
	}

	public static byte[] inputStreamToByte(InputStream is) {
		try{
			ByteArrayOutputStream bytestream = new ByteArrayOutputStream();
			int ch;
			while ((ch = is.read()) != -1) {
				bytestream.write(ch);
			}
			byte imgdata[] = bytestream.toByteArray();
			bytestream.close();
			return imgdata;
		}catch(Exception e){
			e.printStackTrace();
		}

		return null;
	}

	public static byte[] readFromFile(String fileName, int offset, int len) {
		if (fileName == null) {
			return null;
		}

		File file = new File(fileName);
		if (!file.exists()) {
			Log.i(TAG, "readFromFile: file not found");
			return null;
		}

		if (len == -1) {
			len = (int) file.length();
		}

		Log.d(TAG, "readFromFile : offset = " + offset + " len = " + len + " offset + len = " + (offset + len));

		if(offset <0){
			Log.e(TAG, "readFromFile invalid offset:" + offset);
			return null;
		}
		if(len <=0 ){
			Log.e(TAG, "readFromFile invalid len:" + len);
			return null;
		}
		if(offset + len > (int) file.length()){
			Log.e(TAG, "readFromFile invalid file len:" + file.length());
			return null;
		}

		byte[] b = null;
		try {
			RandomAccessFile in = new RandomAccessFile(fileName, "r");
			b = new byte[len]; // 创建合适文件大小的数组
			in.seek(offset);
			in.readFully(b);
			in.close();

		} catch (Exception e) {
			Log.e(TAG, "readFromFile : errMsg = " + e.getMessage());
			e.printStackTrace();
		}
		return b;
	}


	public static Bitmap extractThumbNail(final String path, final int height, final int width, final boolean crop) {
		Assert.assertTrue(path != null && !path.equals("") && height > 0 && width > 0);

		BitmapFactory.Options options = new BitmapFactory.Options();

		try {
			options.inJustDecodeBounds = true;
			Bitmap tmp = BitmapFactory.decodeFile(path, options);
			if (tmp != null) {
				tmp.recycle();
				tmp = null;
			}

			Log.d(TAG, "extractThumbNail: round=" + width + "x" + height + ", crop=" + crop);
			final double beY = options.outHeight * 1.0 / height;
			final double beX = options.outWidth * 1.0 / width;
			Log.d(TAG, "extractThumbNail: extract beX = " + beX + ", beY = " + beY);
			options.inSampleSize = (int) (crop ? (beY > beX ? beX : beY) : (beY < beX ? beX : beY));
			if (options.inSampleSize <= 1) {
				options.inSampleSize = 1;
			}

			// NOTE: out of memory error
			while (options.outHeight * options.outWidth / options.inSampleSize > MAX_DECODE_PICTURE_SIZE) {
				options.inSampleSize++;
			}

			int newHeight = height;
			int newWidth = width;
			if (crop) {
				if (beY > beX) {
					newHeight = (int) (newWidth * 1.0 * options.outHeight / options.outWidth);
				} else {
					newWidth = (int) (newHeight * 1.0 * options.outWidth / options.outHeight);
				}
			} else {
				if (beY < beX) {
					newHeight = (int) (newWidth * 1.0 * options.outHeight / options.outWidth);
				} else {
					newWidth = (int) (newHeight * 1.0 * options.outWidth / options.outHeight);
				}
			}

			options.inJustDecodeBounds = false;

			Log.i(TAG, "bitmap required size=" + newWidth + "x" + newHeight + ", orig=" + options.outWidth + "x" + options.outHeight + ", sample=" + options.inSampleSize);
			Bitmap bm = BitmapFactory.decodeFile(path, options);
			if (bm == null) {
				Log.e(TAG, "bitmap decode failed");
				return null;
			}

			Log.i(TAG, "bitmap decoded size=" + bm.getWidth() + "x" + bm.getHeight());
			final Bitmap scale = Bitmap.createScaledBitmap(bm, newWidth, newHeight, true);
			if (scale != null) {
				bm.recycle();
				bm = scale;
			}

			if (crop) {
				final Bitmap cropped = Bitmap.createBitmap(bm, (bm.getWidth() - width) >> 1, (bm.getHeight() - height) >> 1, width, height);
				if (cropped == null) {
					return bm;
				}

				bm.recycle();
				bm = cropped;
				Log.i(TAG, "bitmap croped size=" + bm.getWidth() + "x" + bm.getHeight());
			}
			return bm;

		} catch (final OutOfMemoryError e) {
			Log.e(TAG, "decode bitmap failed: " + e.getMessage());
			options = null;
		}

		return null;
	}

}
