package com.linkxin.douyouPlayer.constant;

/**
 * Constants
 * 
 * @author Lynch 2014-09-15
 *
 */
public interface Constants {
	String OK = "0";

	String FAIL = "102";

	// 未知错误
	String SYSTEM_ERROR = "000-未知错误！";

	String USER_EXISTED_ERROR = "用户已经存在！";

	String USER_NOT_EXISTED_ERROR = "用户不存在！";

	String PASSWORD_ERROR = "密码错误！";

	String CHECKCODE_NOT_EXIST = "验证码不存在！";

	String CHECKCODE_ERROR = "验证码错误！";

	/**
	 * 随机输出字母、数字或者随机 char=字母 num=数字 all=随机
	 */
	String RADOM_OUT_CHAR = "char";

	String RADOM_OUT_NUM = "num";

	String RADOM_OUT_ALL = "all";

	// 错误代码
	String SUCCESS = "0";
	String SYSTEM_ERROR_CODE = "1";
	String PARAM_ERROR_CODE = "2";
	String OBJECT_NOT_FOUND_ERROR_CODE = "3";

	// 用户物品来源
	String BUY_USER_GOOD = "0";
	String PRESENT_USER_GOOD = "1";

	// 用户物品类型
	String GIFT = "0";
	String PROP = "1";
	String COIN = "2";
	String DIAMOND = "3";

	// 直播房间状态
	String CLOSED = "0";
	String OPENED = "1";

	// 用户线上状态
	String OFF_LINE = "0";
	String ON_LINE = "1";
	String IN_ROOM = "2";
	String IN_GAME = "3";

	// 用户类型
	String USER_TYPE_C = "C";
	String USER_TYPE_P = "P";
	String USER_TYPE_S = "S";
	String USER_TYPE_A = "A";
	String USER_TYPE_O = "O";
	String USER_TYPE_R = "R";

	// 物品类型
	String GOODS_TYPE_COIN = "0";
    String GOODS_TYPE_GIFT = "1";
    String GOODS_TYPE_PROP = "2";
    String GOODS_TYPE_GAME_PROP = "3";
    String GOODS_TYPE_DATING_PROP = "4";
    String GOODS_TYPE_RANSOM_CARD = "5";
    String GOODS_TYPE_DEFEND = "6";
	
	//性别
	String MALE = "1";
	String FEMALE = "2";
	
	//Intent Request Code
	int REGIST_REQUEST_CODE = 1;

}
