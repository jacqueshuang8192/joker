package com.j.joker.core.constants;


public class YTConstants {
	/**
	 * 默认编码
	 */
	public static final String DEFAULT_CHAR = "UTF-8";
	public static final String RESULT_SUCCESS = "true";
	public static final String RESULT_FAIL = "false";
	//免费服务默认key
	public static final String DEFAULT_KEY = com.j.joker.core.util.ConfigUtil.get("protocol.defaultKey");

	public static final String AES_KEY = com.j.joker.core.util.ConfigUtil.get("protocol.aesKey");

	/**
	 * 服务类型:0=航班保障服务,1=机务进场服务,2=大航班接送机服务,3=其他服务
	 */
	public static final Integer FLIGHT_SUPPORT_TASK = 0;
	public static final Integer FLIGHT_APPROACH_TASK = 1;
	public static final Integer FLIGHT_SHUTTLE_TASK = 2;
	public static final Integer OTHER_TASK = 3;

	/**
	 * 客户人员类别 0=机组人员，1=客户人员(旅客)，2=机务进场人员，3=住酒店人员
	 */
	public static final Integer CREW_TYPE = 0;
	public static final Integer CUSTOMER_TYPE = 1;
	public static final Integer MAINTENANCE_TYPE = 2;
	public static final Integer HOTEL_TYPE = 3;
	//客户代表类型
	public static final String CUSTOMER_VO = "3";

	//客户代表枚举 代办、隔离区、接待方
	public static final String CUSTOMER_TYPE_AGENCY = "代办";
	public static final String CUSTOMER_TYPE_ISOLATION = "隔离区";
	public static final String CUSTOMER_TYPE_RECEPTION = "接待方";
	
	/**
	 * 提醒状态：0=无效 1=有效
	 */
	public static final Integer REMIND_DISABLE = 0;
	public static final Integer REMIND_ENABLE = 1;
	/**
	 * 是否子类型：t=是 f=否
	 */
	public static final String IS_SUB_MISSION = "t";
	public static final String IS_NOT_SUB_MISSION = "f";

	/**
	 * 时间记录1=预约,2=开始,3=结束
	 */
	public static final String RECORD_TYPE_BO = "1";
	public static final String RECORD_TYPE_START = "2";
	public static final String RECORD_TYPE_END = "3";

	/**
	 * 后台系统用户
	 */
	public static final String SYSTEM_USER = "system_app";
	public static final String SYSTEM_PASSWORD = com.j.joker.core.util.ConfigUtil.get("system.password");

	/**
	 * 消息类型 0=密码变更;1=任务更新;2=闹钟提醒
	 */
	public static final String Message_PWD = "0";
	public static final String Message_TASK = "1";
	public static final String Meaaage_ALERT = "2";

	/**
	 * a=用户新增、u=用户密码修改
	 */
	public static final String USER_ADD_NOTIFY = "a";
	public static final String USER_UPDATE_NOTIFY = "u";

	public static final String MISSION_QUERY_USERID_NULL_ERROR = "用户id不能为空!";

	/**
	 * 航班动态类型查询1=按城市对 2=按航班号 3=按日期查询
	 */
	public static final Integer FLIGHT_TYPE_CITY = 1;
	public static final Integer FLIGHT_TYPE_FLIGHT_NO = 2;
	public static final Integer FLIGHT_TYPE_DATE = 3;
	/**
	 * 性别
	 */
	public static final String SEX_MAN = "f";
	public static final String SEX_WOMEN = "m";

	/**
	 * 服务项类型 1=免费 2=收费
	 */
	public static final String FREE_MISSION = "1";
	public static final String PRICE_MISSION = "2";

	/**
	 * 版本是否生效 1=生效 0=不生效
	 */
	public static final Integer VERSION_DISABLE = 0;
	public static final Integer VERSION_ENABLE = 1;

	/**
	 * 是否需要更新 1是 0 否
	 */
	public static final String IS_NEED_UPDATE = "1";
	public static final String IS_NOT_NEED_UPDATE = "0";

	/**
	 * 航班保障任务进出港0-进港;1-出港;2-试飞;
	 */

	public static final Integer ENTER_PORT = 0;
	public static final Integer LEAVE_PORT = 1;
	public static final Integer TEST_FLY_PORT = 2;

	/**
	 * 随机输出字母、数字或者随机 char=字母 num=数字 all=随机
	 */
	public static final String RADOM_OUT_CHAR = "char";
	public static final String RADOM_OUT_NUM = "num";
	public static final String RADOM_OUT_ALL = "all";

	/**
	 * 上传类型
	 */
	public static final String TYPE_SIGN = "sing";
	public static final String TYPE_USER = "user";
	public static final String TYPE_PHOTO = "photo";
	public static final String TYPE_DEFAULT = "default";
	/**
	 * 是否已签名 1=已签名 0=未签名
	 */
	public static final String IS_SIGNED = "1";
	public static final String IS_NOT_SIGNED = "0";

	/**
	 * 是否有提醒 0=无 1=有
	 */
	public static final String IS_NOT_ALERT = "0";
	public static final String IS_ALERT = "1";

	/***
	 * 任务、服务公共状态  
	 * 0=未开始,1=服务中,2=审核中,3=预定中,4=审批通过,5=审批不通过,6=已完成
	 * 7=客户取消,8=删除,9=已确认,10=待办理,11=办理中,12=证件过期,13=已归档,14=已流转,15=已指派,16=已签名
	 */

	public static final Integer SERVICE_STATUS_NO_BEGIN = 0;
	public static final Integer SERVICE_STATUS_BEGIN = 1;
	public static final Integer SERVICE_STATUS_AUDIT = 2;
	public static final Integer SERVICE_STATUS_BOOKING = 3;
	public static final Integer SERVICE_STATUS_APPROVAL = 4;
	public static final Integer SERVICE_STATUS_REJECT = 5;
	public static final Integer SERVICE_STATUS_END = 6;
	public static final Integer SERVICE_STATUS_CUSTOMER_CANCEL = 7;
	public static final Integer SERVICE_STATUS_DEL = 8;
	public static final Integer SERVICE_STATUS_CONFIRM = 9;
	public static final Integer SERVICE_STATUS_IS_WAIT = 10;
	public static final Integer SERVICE_STATUS_DOING = 11;
	public static final Integer SERVICE_STATUS_EXPIRE = 12;
	public static final Integer SERVICE_STATUS_FILED = 13;
	public static final Integer SERVICE_STATUS_TRANSFER = 14;
	public static final Integer SERVICE_STATUS_ASSIGNED= 15;
	public static final Integer SERVICE_STATUS_SINGER = 16;
	/**
	 * 免费服务类型 1=时间点节点 2=时间段节点
	 */
	public static final String FREE_TIME_POINT_NODE="1";
	public static final String FREE_TIME_SOLT_NODE="2";

	public static final String IDENTITY_CARD = "身份证";
	public static final String PASSPORT = "护照";
	public static final String OTHER = "其他";

	//服务项类型，对应配置文件key 0=机组 1=旅客
	public static final String ALL = ".all";
	public static final String AIRCREW = ".0";;
	public static final Integer AIRCREW_TYPE = 0;;
	public static final String PASSENGER = ".1";
	public static final Integer PASSENGER_TYPE = 1;
	
	//收费服务分类 ,1=其它服务 2=机组服务 3=机坪服务 4=旅客服务
	public static final String SERVICE_OTHER_TYPE="1";
	public static final String SERVICE_AIRCREW_TYPE="2";
	public static final String SERVICE_AIRPORT_RAMP_TYPE="3";
	public static final String SERVICE_PASSENGER_TYPE="4";
	
	//是否有更新 0=未有更新 1=有更新 
	public static final String IS_HAVING_UPDATE="1";
	public static final String NO_UPDATE="0";

	//更新查询表名
	public static final String FLIGHT_SUPPORT_TABLE_NAME = "TaskFlightEnsure";
	public static final String FLIGHT_SHUTTLE_TABLE_NAME = "TaskBigFlightShuttle";
	public static final String APPROACH_TABLE_NAME = "TaskApproachService";
	public static final String OTHER_TABLE_NAME = "TaskOtherServe";

	//实体跟数据库属性关系xml映射
	public static final String SUPPORT_MAPPING_XML = "/fieldMapping/flightSupport.xml";
	public static final String SHUTTLE_MAPPING_XML = "/fieldMapping/flightShuttle.xml";
	public static final String APPROACH_MAPPING_XML = "/fieldMapping/approach.xml";
	public static final String OTHER_MAPPING_XML = "/fieldMapping/other.xml";
	//是否显示全部
	public static final String IS_ALL = "1";

	//机组旅客交通 0=机组 1=旅客
	public static final String PASSENGER_TRAFFIC = "1";
	public static final String  CREW_TRAFFIC="0";
	//保障人员有效状态
	public static final Integer MISSION_ENABLE = 0;
	//服务项删除、取消 d=删除 c=取消
	public static final String SUB_MISSION_DEL = "d";
	public static final String SUB_MISSION_CANCEL = "c";

}
