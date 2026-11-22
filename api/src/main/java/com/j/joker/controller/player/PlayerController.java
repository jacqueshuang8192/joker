package com.j.joker.controller.player;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.controller.BaseController;
import com.j.joker.core.util.*;
import com.j.joker.cache.CacheManager;
import com.j.joker.cache.ICache;
import com.j.joker.cache.model.CachePlayerProfile;
import com.j.joker.constants.Constants;
import com.j.joker.mapper.TSecUserMapper;
import com.j.joker.model.GameServerAuthInfo;
import com.j.joker.model.TPlayer;
import com.j.joker.model.TSecUser;
import com.j.joker.model.TUser;
import com.j.joker.service.common.UserService;
import com.j.joker.service.inviteCodeGen.InviteCodeGen;
import com.j.joker.service.player.PlayerService;
import com.j.joker.utils.CommonUtil;
import com.j.joker.utils.InfServerException;
import com.j.joker.vo.response.Response;
import com.j.joker.vo.response.user.OAuthVo;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.Parameter;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.ServletRequestDataBinder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.SQLException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

//import com.j.joker.vo.response.user.TaskListVo;

/**
 * 玩家控制器
 * 
 * @author yrou
 *
 */

@Tag(name = "玩家相关接口")
@Controller
public class PlayerController extends BaseController {

	private static final Log log = LogFactory.getLog(PlayerController.class);
	private static final Log rechargeLog = LogFactory.getLog("Recharge");
	
	@Autowired
	private PlayerService playerService;
	@Autowired
    private UserService userService;
	@Autowired
    private TSecUserMapper secUserMapper;
	@Autowired
	private InviteCodeGen codeGen;
	
	@InitBinder  
    protected void initBinder(HttpServletRequest request,  
            ServletRequestDataBinder binder) throws Exception {  
            DateFormat df = new SimpleDateFormat("yyyy-MM-dd");  
            CustomDateEditor editor = new CustomDateEditor(df, false);  
            binder.registerCustomEditor(Date.class, editor);  
    }
	
//	@ResponseBody
//	@RequestMapping(value = "playerRegister", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@Operation(summary = "玩家注册", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "玩家注册")
//	public String playerRegister(
//			@Parameter(required = true, name = "phone", description = "手机号") @RequestParam(value = "phone") String phone,
//			@Parameter(required = true, name = "password", description = "密码，MD5加密之后的密码") @RequestParam(value = "password") String password,
//			@Parameter(required = false, name = "photo", description = "头像，url") @RequestParam(value = "photo", required = false) String photo,
//			@Parameter(name = "roomPhoto", description = "房间图片，url")
//			@RequestParam(required = false, value = "roomPhoto") String roomPhoto,
//			@Parameter(name = "livePhoto", description = "直播间图片，url")
//			@RequestParam(required = false, value = "photo") String livePhoto,
//			@Parameter(required = true, name = "nickname", description = "昵称") @RequestParam(value = "nickname") String nickname,
//			@Parameter(required = true, name = "sex", description = "性别：0保密，1男，2女") @RequestParam(value = "sex") String sex,
//			@Parameter(required = false, name = "invitationCode", description = "邀请码") @RequestParam(value = "invitationCode", required = false) String invitationCode,
//			@Parameter(required = false, name = "qq", description = "邀请码") @RequestParam(value = "qq", required = false) String qq,
//			@Parameter(required = false, name = "wechat", description = "邀请码") @RequestParam(value = "wechat", required = false) String wechat,
//			@Parameter(required = false, name = "weibo", description = "邀请码") @RequestParam(value = "weibo", required = false) String weibo,
//			@Parameter(required = true, name = "code", description = "验证码") @RequestParam(value = "code") String code,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//			@RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			int minutes = Integer.parseInt(ConfigUtil.get("sms.effectiveTime"));
//			boolean isValid = userService.isCodeValid(phone, code, minutes);
//			if (!isValid) {
//				response.setReturnCode(Constants.RETURN_CODE_CHECKCODE_INVALID);
//				return JSONObject.toJSONString(response);
//			}
//
//			TPlayer player = new TPlayer();
//			TUser user = new TUser();
//			user.setPhone(phone);
//			user.setPassword(password);
//			user.setNickName(nickname);
//			user.setAccount(phone);
//			user.setType(Constants.USER_TYPE_P);
//			user.setState(Constants.VALID);
//			user.setQq(qq);
//			user.setWeibo(weibo);
//			user.setWechat(wechat);
//			user.setGender(sex);
//			user.setSmallIcon(photo);
//			user.setGrade(0F);
//			user.setCreateDate(new Date());
//			user.setDeprecated(Constants.USER_NOT_DEPRECATED);
//			playerService.register(player, user, invitationCode);
//		} catch (InfServerException ie) {
//			log.error("玩家注册：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (SQLException e) {
//			log.error("玩家注册：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			response.setError("注册插入数据库失败");
//		} catch (Exception e) {
//			log.error("玩家注册：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

	@ResponseBody
	@RequestMapping(value = "playerUser/quickRegister", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
	@Operation(summary = "快速注册", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String quickRegister(
			@Parameter(required = false, name = "photo", description = "头像，url") @RequestParam(value = "photo", required = false) String photo,
			@Parameter(required = false, name = "nickname", description = "昵称") @RequestParam(value = "nickname", required = false) String nickname,
			@Parameter(required = false, name = "sex", description = "性别：0保密，1男，2女") @RequestParam(value = "sex", required = false) String sex,
			@Parameter(required = false, name = "qq", description = "qq") @RequestParam(value = "qq", required = false) String qq,
			@Parameter(required = false, name = "wechat", description = "wechat") @RequestParam(value = "wechat", required = false) String wechat,
			@Parameter(required = false, name = "weibo", description = "weibo") @RequestParam(value = "weibo", required = false) String weibo,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
			@RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
			String code = codeGen.getCode();
			if (code == null) {
				response.setReturnCode(Constants.RETURN_CODE_FAIL);
				response.setError("注册失败");
				return JSON.toJSONString(response);
			}
			String password = RadomUtil.getCharAndNumr(6, Constants.RADOM_OUT_NUM);
			if (StringUtils.isBlank(nickname)) {
				nickname = "用户" + code;
			}
			nickname = emojiFilter.emojiChange(nickname);
			OAuthVo vo = playerService.quickRegister(nickname, code, password, photo, sex, qq, wechat, weibo, 0);
			response.setData(vo);
			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
		} catch (SQLException e) {
			log.error("快速注册：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
			response.setError("注册插入数据库失败");
		} catch (Exception e) {
			log.error("快速注册：", e);
			CommonUtil.BuildErrorResponse(e, response);
		}
		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}


	@ResponseBody
	@RequestMapping(value = "playerUser/quickRegisterByPhone", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
	@Operation(summary = "手机注册", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String quickRegisterByPhone(
			@Parameter(required = true, name = "phone", description = "头像，url") @RequestParam(value = "phone", required = true) String phone,
			@Parameter(required = true, name = "nickname", description = "昵称") @RequestParam(value = "nickname", required = true) String nickname,
			@Parameter(required = true, name = "passWord", description = "密码") @RequestParam(value = "passWord", required = true) String passWord,

			@Parameter(required = false, name = "photo", description = "头像，url,必须是以.png结尾") @RequestParam(value = "photo", required = false) String photo,
			@Parameter(required = false, name = "sex", description = "性别: 1男，2女") @RequestParam(value = "sex", required = false, defaultValue = "1") String sex,


			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
			@RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {

			nickname = emojiFilter.emojiChange(nickname);
			OAuthVo vo = playerService.quickRegisterByPhone(phone, nickname, passWord, photo, sex);
			response.setData(vo);
			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
		} catch (SQLException e) {
			log.error("手机注册：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
			response.setError("注册插入数据库失败");
		}catch (InfServerException ie) {
			log.error("手机注册：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		}catch (Exception e) {
			log.error("手机注册：", e);
			CommonUtil.BuildErrorResponse(e, response);
		}
		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}

	@ResponseBody
	@RequestMapping(value = "playerUser/uploadPhoto", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
	@Operation(summary = "上传头像", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String uploadPhoto(
			@Parameter(required = true, name = "photo", description = "上传头像") @RequestParam(value = "photo", required = true) MultipartFile photo,

			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
			@RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
			String photoUrl = playerService.uploadPhoto(photo);
			response.setData(photoUrl);
			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
		}catch (InfServerException ie) {
			log.error("上传头像：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		}catch (Exception e) {
			log.error("上传头像：", e);
			CommonUtil.BuildErrorResponse(e, response);
		}
		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}

//	@ResponseBody
//	@RequestMapping(value = "playerUser/quickRegisterRobot", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@Operation(summary = "快速注册机器人", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String quickRegisterRobot(
//			@Parameter(required = false, name = "photo", description = "头像，url") @RequestParam(value = "photo", required = false) String photo,
//			@Parameter(required = false, name = "sex", description = "性别：0保密，1男，2女") @RequestParam(value = "sex", required = false) String sex,
//			@Parameter(required = false, name = "qq", description = "qq") @RequestParam(value = "qq", required = false) String qq,
//			@Parameter(required = false, name = "wechat", description = "wechat") @RequestParam(value = "wechat", required = false) String wechat,
//			@Parameter(required = false, name = "weibo", description = "weibo") @RequestParam(value = "weibo", required = false) String weibo,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//			@RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			for(int i = 0; i < 30; i++) {
//				String code = codeGen.getCode();

//				String nickname = playerService.generateNickname();
////				String result = easeMobService.registerOnEaseMob(code, EncryptUtils.encodeMD5String(password).toUpperCase(), nickname);
////				if (!result.equalsIgnoreCase(Constants.RETURN_CODE_SUCCESS) && result.indexOf("duplicate") == -1) {
////					throw new InfServerException(Constants.RETURN_CODE_FAIL, "注册失败，请稍后再试");
////				}
//				OAuthVo vo = playerService.quickRegister(nickname, code, password, photo, sex, qq, wechat, weibo, 1);
//			}
////			response.setData(vo);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (SQLException e) {
//			log.error("快速注册：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			response.setError("注册插入数据库失败");
//		} catch (Exception e) {
//			log.error("快速注册：", e);
//			CommonUtil.BuildErrorResponse(e, response);
//		}
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

	@ResponseBody
	@RequestMapping(value = "playerUser/bindPhone", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
	@Operation(summary = "绑定手机号", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String bindPhone(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Long XYUid,
			@Parameter(required = true, name = "phone", description = "手机号") @RequestParam(value = "phone") String phone,
			@Parameter(required = false, name = "code", description = "验证码") @RequestParam( required = false, value = "code") String code,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
//			int minutes = Integer.parseInt(ConfigUtil.get("sms.effectiveTime"));
//			boolean isValid = userService.isCodeValid(phone, code, minutes);
//			if (!isValid) {
//				response.setReturnCode(Constants.RETURN_CODE_CHECKCODE_INVALID);
//				return JSONObject.toJSONString(response);
//			}
			String s = playerService.bindPhone(XYUid, phone);
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("cardCount",s);
			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
			response.setData(jsonObject);
		} catch (Exception e) {
			log.error("绑定手机号：", e);
			CommonUtil.BuildErrorResponse(e, response);
		}
		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}
//	@ResponseBody
//	@RequestMapping(value = "playerUser/queryPhoneByUid", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@Operation(summary = "查询玩家的电话号码", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String queryPhoneByUid(
//			@Parameter(required = true, name = "userId", description = "玩家id") @RequestParam(value = "userId") Long userId,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
////			int minutes = Integer.parseInt(ConfigUtil.get("sms.effectiveTime"));
////			boolean isValid = userService.isCodeValid(phone, code, minutes);
////			if (!isValid) {
////				response.setReturnCode(Constants.RETURN_CODE_CHECKCODE_INVALID);
////				return JSONObject.toJSONString(response);
////			}
//			String s = playerService.queryPhoneByUid(userId);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(s);
//		} catch (Exception e) {
//			log.error("查询玩家的电话号码：", e);
//			CommonUtil.BuildErrorResponse(e, response);
//		}
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}
	
	@ResponseBody
    @RequestMapping(value = "playerUser/OAuthCheck", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "检测第三方账号是否有注册", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String OAuthCheck(
            @Parameter(required = false, name = "type", description = "第三方登陆渠道，QQ:qq;微博:weibo;微信:wechat")
            @RequestParam( required = false,value = "type") String type,
            @Parameter(required = false, name = "code", description = "第三方登陆验证code")
            @RequestParam(required = false,  value = "code") String code,
            HttpServletRequest request) {
        Response vo = new Response();
        try {
			System.out.println(type + "....." + code);
            OAuthVo check = playerService.OAuthCheck(type, code);
            vo.setData(check);
            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
			System.out.println(check.getPassword() + "...." + check.getPhone() + "...." + check.getPhoto());
            return JSON.toJSONString(vo);
        } catch (InfServerException ie) {
			log.error("检测第三方账号是否有注册：", ie);
            vo.setReturnCode(ie.getErrorCode());
            vo.setError(ie.getErrorMsg());
            return JSONUtil.parseJSONContainsNull(vo);
        } catch (Exception e) {
			log.error("检测第三方账号是否有注册：", e);
            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
            return JSONUtil.parseJSONContainsNull(vo);
        }
    }
	
//	@ResponseBody
//	@RequestMapping(value = "playerUser/getUserInfo", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@Operation(summary = "获取个人资料", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "获取个人资料")
//	public String getUserInfo(
//			@Parameter(required = true, name = "userId", description = "用户名,唯一") @RequestParam(value = "userId") String userId,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//			@RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//			Response response = new Response();
//		try {
//			CachePlayerProfile cachePlayer = playerService.getPlayerInfoById(userId);
//			response.setData(cachePlayer);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("获取个人资料：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}
	
	@ResponseBody
    @RequestMapping(value = "playerUser/getUserInfo4GameServer", method = {RequestMethod.POST,RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "游戏服务器获取个人资料", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "获取个人资料")
    public String getUserInfo4GameServer(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
            HttpServletRequest request) {
            Response response = new Response();
        try {

			GameServerAuthInfo cachePlayer = playerService.getPlayerInfo4GameServer(XYUid, request);
			String status = cachePlayer.getPlayerProfile().getStatus();
			if ( status == null || status.equals("0")) {
				response.setReturnCode(Constants.RETURN_CODE_FAIL);
				response.setError("您好,您的账号已经被封停了,请联系您的代理!!");
				return JSON.toJSONString(response);
			}
			response.setData(cachePlayer);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            return JSON.toJSONString(response);
        }catch (Exception e) {
			log.error("游戏服务器获取个人资料：", e);
            CommonUtil.BuildErrorResponse(e, response);
            return JSON.toJSONString(response);
        }
    }

//	@ResponseBody
//	@RequestMapping(value = "playerUser/modifyUserInfo", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@Operation(summary = "修改个人资料", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "修改个人资料")
//	public String modifyUserInfo(
//			@Parameter(name = "userId", description = "用户名,唯一", required = true) @RequestParam(value = "userId") String userId,
//			@Parameter(name = "photo", description = "图像", required = false) @RequestParam(value = "photo", required = false) String photo,
//			@Parameter(name = "nickName", description = "昵称", required = false) @RequestParam(value = "nickName", required = false) String nickName,
//			@Parameter(name = "name", description = "名称", required = false) @RequestParam(value = "name", required = false) String name,
//			@Parameter(name = "birthday", description = "生日", required = false) @RequestParam(value = "birthday", required = false) String birthday,
//			@Parameter(name = "provinceId", description = "省份", required = false) @RequestParam(value = "provinceId", required = false) String provinceId,
//			@Parameter(name = "cityId", description = "城市", required = false) @RequestParam(value = "cityId", required = false) String cityId,
//			@Parameter(name = "townId", description = "区", required = false) @RequestParam(value = "townId", required = false) String townId,
//			@Parameter(name = "sign", description = "名称", required = false) @RequestParam(value = "sign", required = false) String sign,
//			@Parameter(name = "gender", description = "性别", required = false) @RequestParam(value = "gender", required = false) String gender,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//			@RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			TPlayer player = playerService.getPlayerById(userId);
//			TUser user = player.getUser();
//			if (user != null) {
//			    if (StringUtils.isNotBlank(photo)) {
//			        user.setSmallIcon(photo);
//			    }
//			    if (StringUtils.isNotBlank(nickName)) {
//			        user.setNickName(nickName);
//			    }
//			    if (StringUtils.isNotBlank(name)) {
//			        user.setName(name);
//			    }
//
//				if (StringUtils.isNotBlank(birthday)) {
//					user.setBirthday(DateUtils.getParseDate(birthday, "yyyy-MM-dd"));
//				}
//				if (StringUtils.isNotBlank(sign)) {
//				    user.setSign(sign);
//				}
//				if (StringUtils.isNotBlank(gender)) {
//					user.setGender(gender);
//				}
//
//				player.setUser(user);
//				if (StringUtils.isNotBlank(provinceId)) {
//					player.setProvinceId(Long.parseLong(provinceId));
//				}
//				if (StringUtils.isNotBlank(cityId)) {
//					player.setCityId(Long.parseLong(cityId));
//				}
//				if (StringUtils.isNotBlank(townId)) {
//					player.setTownId(Long.parseLong(townId));
//				}
//				playerService.updatePlayer(player);
//				response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			} else {
//				throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到相关账号");
//			}
//
//		} catch (Exception e) {
//			log.error("修改个人资料：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}


//	@ResponseBody
//	@RequestMapping(value = "playerUser/validateAppStoreCharge", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@Operation(summary = "验证APPstore充值订单", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String validateAppStoreCharge(
//			@Parameter(required = true, name = "userId", description = "玩家id")
//			@RequestParam(value = "userId") Long userId,
//			@Parameter(required = true, name = "payAmount", description = "购买价格")
//			@RequestParam(value = "payAmount") Integer payAmount,
//			@Parameter(required = true, name = "coinAmount", description = "购买价格")
//			@RequestParam(value = "coinAmount") Integer coinAmount,
//			@Parameter(required = true, name = "receipt", description = "支付凭证")
//			@RequestParam(value = "receipt") String receipt,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//			@RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			playerService.validateAppStoreCharge(userId, payAmount, coinAmount, receipt);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////			response.setData(detail);
//		} catch (InfServerException ie) {
//			log.error("玩家PC端充值：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (ChargeException e) {
//			log.error("玩家PC端充值：", e);
//			response.setReturnCode(e.getErrorCode());
//			response.setError(e.getErrorMsg());
//		} catch (Exception e) {
//			log.error("玩家PC端充值：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponseContainsNull(method, response);
//		}
//		return JSONUtil.parseJSONContainsNull(response);
//	}

//	@ResponseBody
//	@RequestMapping(value = "playerUser/receivePlayerCharge", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@Operation(summary = "Ping++充值回调", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = BaseResultVo.class))), description = "玩家充值")
//	public String receivePlayerCharge(HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			String req = InputStreamTOString(request.getInputStream());
//			Event event = JSON.toJavaObject(JSON.parseObject(req), Event.class);
//			rechargeLog.info(req);
//			if (event != null) {
//				Map<String, Object> chargeMaps = event.getData();
//				if (chargeMaps == null) {
//					rechargeLog.info("chargeMaps is null");
//				}
//				if (MapUtils.isNotEmpty(chargeMaps)) {
//					JSONObject obj = (JSONObject) chargeMaps.get("object");
//					Charge charge = JSON.toJavaObject(obj, Charge.class);
//					//判断是否支付成功
//					boolean paid = charge.getPaid();
//					String chargeOrderId = charge.getId();
//					String channelOrderId = charge.getOrderNo();
//					if (paid) {
//						accountChargeService.updateAccountChargeByPingPPOrderId(chargeOrderId, channelOrderId);
//						response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//						rechargeLog.info("充值成功，chargeOrderId：" + chargeOrderId);
//						return JSON.toJSONString(response);
//					} else {
//						throw new InfServerException(Constants.SYSTEM_ERROR, "Ping++支付失败");
//					}
//				} else {
//					throw new InfServerException(Constants.SYSTEM_ERROR, "Ping++回写结果为空");
//				}
//			} else {
//				throw new InfServerException(Constants.SYSTEM_ERROR, "Ping++回写结果为空");
//			}
//
////			accountChargeService.updateAccountChargeByPingPPOrderId("ch_vT8ebTGWvjTObv9SGGPqbbfD", "");
////			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////			rechargeLog.info("充值成功，chargeOrderId：" + chargeOrderId);
////			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("Ping++充值回调：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//	}
	
//	@ResponseBody
//	@RequestMapping(value = "playerUser/queryRechargeRecord", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@Operation(summary = "玩家充值记录", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "玩家充值记录")
//	public String queryRechargeRecord(
//			@Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") String userId,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			Map<String, Object> params = new HashMap<String, Object>();
//			params.put("userId", userId);
//
//			Calendar calendar = Calendar.getInstance();
//			params.put("endDate", DateUtils.getParseDate(calendar.getTime(), "yyyy-MM-dd HH:mm:ss"));
//			calendar.add(Calendar.MONTH, -3);
//			params.put("startDate", DateUtils.getParseDate(calendar.getTime(), "yyyy-MM-dd HH:mm:ss"));
//			params.put("status", Constants.PAY_SUCCESS);
//			List<TAccountCharge> accountCharges = accountChargeService.findAccountChargeHistoryByConditions(params);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(accountCharges);
//		} catch (Exception e) {
//			log.error("玩家充值记录：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}
	
//	@ResponseBody
//    @RequestMapping(value = "playerUser/bindCompere", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "绑定主播", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "绑定主播")
//    public String bindCompere(
//    		@Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") String userId,
//    		@Parameter(required = true, name = "invitationCode", description = "邀请码") @RequestParam(value = "invitationCode") String invitationCode,
//    		HttpServletRequest request) {
//	    Response response = new Response();
//        try {
//        	playerService.bindCompere(userId, invitationCode);
//
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//			log.error("绑定主播：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
	
//	@ResponseBody
//    @RequestMapping(value = "playerUser/myAttentions", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "关注的主播", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "关注的主播")
//    public String myAttentions(
//    		@Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") String userId,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//			@RequestParam(required = false, value = "interfaceType") String interfaceType,
//    		HttpServletRequest request) {
//	    Response response = new Response();
//        try {
//        	response.setData(playerService.queryMyAttentions(userId));
//
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//
//        } catch (Exception e) {
//			log.error("关注的主播：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//    }
	

    @ResponseBody
    @RequestMapping(value = "userBindingAgent", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "玩家绑定代理", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "玩家绑定代理")
    public String userBindingAgent(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
			@Parameter(required = true, name = "agentId", description = "代理ID") @RequestParam(value = "agentId") String agentId,
            HttpServletRequest request) {
        Response response = new Response();

        try {
            playerService.userBindingAgent(Long.parseLong(XYUid),Long.parseLong(agentId) );
			JSONObject object = new JSONObject();
			if (XYUid != null) {
				TSecUser secUser = new TSecUser();
				secUser.setUserid(Long.parseLong(agentId));
				secUser=secUserMapper.selectOne(secUser);
				String nickNme = secUser.getFullname();
				object.put("agentId", agentId);
				object.put("nickNme", nickNme);
				
			}
			response.setData(object);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            return JSON.toJSONString(response);
        } catch (Exception e) {
			log.error("玩家绑定代理：", e);
            CommonUtil.BuildErrorResponse(e, response);
            return JSON.toJSONString(response);
        }
    }

	@ResponseBody
	@RequestMapping(value = "userBindingAgentByGold", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
	@Operation(summary = "玩家绑的代理", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "玩家绑定代理")
	public String userBindingAgentByGold(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
			@Parameter(required = true, name = "agentId", description = "代理ID") @RequestParam(value = "agentId") String agentId,
			HttpServletRequest request) {
		Response response = new Response();

		try {
		    response = playerService.userBindingAgentByGold(Long.parseLong(XYUid),Long.parseLong(agentId) );
			response.setData("绑定成功");
			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
			return JSON.toJSONString(response);
		} catch (Exception e) {
			log.error("玩家绑定代理：", e);
			ICache cache = CacheManager.getCache();
			cache.hset("BINDING_AGENT_BY_GOLD_ERR",XYUid,agentId);
			CacheManager.releaseCache(cache);
			CommonUtil.BuildErrorResponse(e, response);
			return JSON.toJSONString(response);
		}
	}

//	@ResponseBody
//	@RequestMapping(value = "playerRegister2Agent", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@Operation(summary = "玩家充值后成为代理", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "玩家绑定代理")
//	public String playerRegister2Agent(
//			@Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") Long userId,
//			@Parameter(required = true, name = "loginName", description = "登陆名") @RequestParam(value = "loginName") String loginName,
//			@Parameter(required = true, name = "passWord", description = "passWord") @RequestParam(value = "passWord") String passWord,
//			@Parameter(required = true, name = "phone", description = "phone") @RequestParam(value = "phone") String phone,
//			HttpServletRequest request) {
//		Response response = new Response();
//
//		try {
//			playerService.playerRegister2Agent(userId,loginName,passWord,phone);
//			JSONObject jsonObject = new JSONObject();
//			jsonObject.put("date","注册成功!!");
//			jsonObject.put("loginName",loginName);
//			jsonObject.put("password",passWord);
//			response.setData(jsonObject);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//		}
//	}

//	@ResponseBody
//	@RequestMapping(value = "queryUseBiqiHistory", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@Operation(summary = "使用比奇卡的记录", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String queryUseBiqiHistory(
//			@Parameter(required = true, name = "playerId", description = "玩家ID") @RequestParam(value = "playerId") Long playerId,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			response =  playerService.queryUseBiqiHistory(playerId);
//		} catch (InfServerException ie) {
//			log.error("使用比奇卡的记录：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("使用比奇卡的记录：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "playerXXX", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@Operation(summary = "玩家放炮次数", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String playerXXX(
//			@Parameter(required = true, name = "playerId1", description = "玩家ID") @RequestParam(value = "playerId1") Integer playerId1,
//			@Parameter(required = true, name = "playerId2", description = "玩家ID") @RequestParam(value = "playerId2") Integer playerId2,
//			@Parameter(required = true, name = "count", description = "count") @RequestParam(value = "count") Integer count,
//			@Parameter(required = false, name = "remark", description = "remark") @RequestParam(required = false,value = "remark") String remark,
//			@Parameter(required = true, name = "sign", description = "sign") @RequestParam(value = "sign") String sign,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			response =  playerService.playerXXX(playerId1,playerId2,count,sign,remark);
//		} catch (InfServerException ie) {
//			log.error("玩家放炮：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("玩家放炮：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}
//	@ResponseBody
//	@RequestMapping(value = "queryPlayerXXX", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@Operation(summary = "查询玩家放炮次数,还未实现", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String queryPlayerXXX(
//			@Parameter(required = true, name = "playerId1", description = "玩家ID") @RequestParam(value = "playerId1") Integer playerId,
//			@Parameter(required = true, name = "type", description = "1 ; 放炮人  2 : 被放炮人") @RequestParam(value = "type") Integer type,
//			@Parameter(required = true, name = "currentPage", description = "当前页") @RequestParam(value = "currentPage") String currentPage,
//			@Parameter(required = false, name = "pageSize", description = "每页显示数,可以不穿,默认为30") @RequestParam(required = false,value = "pageSize") String pageSize,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			response =  playerService.queryPlayerXXX(playerId,type,currentPage,pageSize);
//		} catch (InfServerException ie) {
//			log.error("查询玩家放炮次数：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("查询玩家放炮次数：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

//	@ResponseBody
//	@RequestMapping(value = "queryPlayerWaiWeiHistory", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@Operation(summary = "查询玩家三公外围的记录", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String queryPlayerWaiWeiHistory(
//			@Parameter(required = true, name = "playerId1", description = "玩家ID") @RequestParam(value = "playerId1") Integer playerId,
//			@Parameter(required = true, name = "currentPage", description = "当前页") @RequestParam(value = "currentPage") String currentPage,
//			@Parameter(required = false, name = "pageSize", description = "每页显示数,可以不穿,默认为30") @RequestParam(required = false,value = "pageSize") String pageSize,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			response =  playerService.queryPlayerWaiWeiHistory(playerId,currentPage,pageSize);
//		} catch (InfServerException ie) {
//			log.error("查询玩家三公外围的记录：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("查询玩家三公外围的记录：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

	@ResponseBody
	@RequestMapping(value = "queryMyAgentAdvice", method = { RequestMethod.POST,
			RequestMethod.GET }, produces = "application/json; charset=utf-8")
	@Operation(summary = "查询我的代理的公告", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String queryMyAgentAdvice(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
			response =  playerService.queryMyAgentAdvice(XYUid);
		} catch (InfServerException ie) {
			log.error("查询我的代理的公告：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		} catch (Exception e) {
			log.error("查询我的代理的公告：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
		}
		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}

	@ResponseBody
	@RequestMapping(value = "isAgent", method = { RequestMethod.POST,
			RequestMethod.GET }, produces = "application/json; charset=utf-8")
	@Operation(summary = "查看这个Id是否是代理", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String isAgent(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
			response =  playerService.isAgent(XYUid);
		} catch (InfServerException ie) {
			log.error("查看这个Id是否是代理：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		} catch (Exception e) {
			log.error("查看这个Id是否是代理：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
		}
		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}


//	@ResponseBody
//	@RequestMapping(value = "applyAgent", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@Operation(summary = "玩家申请成为代理", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "玩家绑定代理")
//	public String applyAgent(
////			@Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") Long userId,
//			@Parameter(required = true, name = "phone", description = "用户手机号") @RequestParam(value = "phone") String phone,
//			@Parameter(required = true, name = "name", description = "代理名称") @RequestParam(value = "name") String name,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			DbContextHolder.setDataSource(Constants.USERCENTERDATASOURCE);
//			TSecUser secUser = playerService.applyAgent(phone, name);
//			DbContextHolder.setDataSource(Constants.COMMONDATASOURCE);
//			playerService.insertAgent(secUser);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("玩家绑定代理：", e);
//			CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//		}
//	}
    
//    @ResponseBody
//    @RequestMapping(value = "test", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "测试接口", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = TaskListVo.class))), description = "领取任务奖励")
//    public String test(
//            @Parameter(required = true, name = "userId", description = "玩家id")
//            @RequestParam(value = "userId") Long userId,
//            @Parameter(required = true, name = "exp", description = "任务id")
//            @RequestParam(value = "exp") Integer exp,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            ICache cache = CacheManager.getCache();
//            LevelVo vo = playerService.updatePlayerExp(userId, exp, cache);
//            CacheManager.releaseCache(cache);
//            response.setData(vo);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//			log.error("测试接口：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//            return JSON.toJSONString(response);
//        }
//    }

	public static JSONObject doGetJson(String url) throws IOException {
		JSONObject jsonObject=null;
		DefaultHttpClient defaultHttpClient=new DefaultHttpClient();
		HttpGet httpGet=new HttpGet(url);
		HttpResponse httpResponse = defaultHttpClient.execute(httpGet);
		HttpEntity httpEntity=httpResponse.getEntity();
		if(httpEntity!=null){
			String result= EntityUtils.toString(httpEntity,"UTF-8");
			jsonObject=JSONObject.parseObject(result);
			//System.out.println("jsonObject:  "+jsonObject);
		}
		httpGet.releaseConnection();
		return jsonObject;
	}

	//微信登陆校验
//	@ResponseBody
//	@RequestMapping(value = "authorize", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@Operation(summary = "authorize", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String authorize(
//			@Parameter(required = false, name = "code", description = "code") @RequestParam(required = false, value = "code") String code,
//			HttpServletRequest req, HttpServletResponse resp) throws Exception {
//
//		String appid = ConfigUtil.get("weixin.AppId");

//		//如果不为空则去校验
//		if (StringUtil.isEmpty(code)) {
//			String backUrl="http://"+req.getServerName() + req.getContextPath() + "/authorize";
////			String backUrl="http://"+req.getServerName() +"/fengYouH5/web-mobile-4/index.html";
//			System.out.println(backUrl + "backUrl");
//			String url="https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + appid+
//					"&redirect_uri=" + URLEncoder.encode(backUrl,"UTF-8")+
//					"&response_type=code" +
//					"&scope=snsapi_userinfo" +
//					"&state=STATE#wechat_redirect";
//			System.out.println(url + "url");
//			resp.sendRedirect(url);
//		}else {
//            Response vo = new Response();
//            OAuthVo wechat = null;
//			String url="https://api.weixin.qq.com/sns/oauth2/access_token?appid=" + appid+

//					"&code=" +code+
//					"&grant_type=authorization_code";
//			JSONObject jsonObject = doGetJson(url);
//			String openid=jsonObject.getString("openid");
//			String token=jsonObject.getString("access_token");
//			String infoUrl="https://api.weixin.qq.com/sns/userinfo?access_token=" +token+
//					"&openid=" +openid+
//					"&lang=zh_CN";
//			JSONObject userInfo= doGetJson(infoUrl);
//			if (StringUtil.isEmpty(userInfo) || StringUtil.isEmpty(userInfo.getString("openid"))) {
//				vo.setError("网络异常,请稍后再试!!");
//				vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//				return JSON.toJSONString(vo);
//			}
//
//
//		    try {
//		        wechat = playerService.OAuthCheck("wechat", userInfo.getString("openid"));
//                vo.setData(wechat);
//                vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//                System.out.println(wechat.getPassword() + "...." + wechat.getPhone() + "...." + wechat.getPhoto());
//                return JSON.toJSONString(vo);
//            }catch (InfServerException ie) {
//                log.error("检测第三方账号是否有注册：", ie);
//                //如果不存在则插入用户
////                if (StringUtil.isNotEmpty(wechat) && StringUtil.isNotEmpty(wechat.getPassword()) && StringUtil.isNotEmpty(wechat.getPassword())){
////                    userService.login(wechat.getPhone(), wechat.getPassword(), "P", 2, null, null, null);
////                }
//                //处理登陆
//				String codexx = codeGen.getCode();

//                wechat = playerService.quickRegister(userInfo.getString("nickname"), codexx, password, userInfo.getString("headimgurl"), userInfo.getString("sex"), null, userInfo.getString("openid"), null, 0);
//                wechat.setPassword(EncryptUtils.encodeMD5String(password).toUpperCase());
//                vo.setData(wechat);
//                vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//                System.out.println(wechat.getPassword() + "...." + wechat.getPhone() + "...." + wechat.getPhoto());
//                return JSON.toJSONString(vo);
//            } catch (Exception e) {
//                log.error("检测第三方账号是否有注册：", e);
//                vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//                return JSONUtil.parseJSONContainsNull(vo);
//            }
//		}
//		return null;
//	}
//
//
//	//微信小程序登陆校验
//	@ResponseBody
//	@RequestMapping(value = "authorizeWXXCX", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@Operation(summary = "authorizeWXXCX", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String authorizeWXXCX(
//			@Parameter(required = true, name = "code", description = "code") @RequestParam(required = true, value = "code") String code,
//			HttpServletRequest req, HttpServletResponse resp) throws Exception {
//
//		String appid = ConfigUtil.get("WXXCX.AppId");

//		//如果不为空则去校验
////		if (StringUtil.isEmpty(code)) {
////			String backUrl="http://"+req.getServerName() + req.getContextPath() + "/authorize";
////			String backUrl="http://"+req.getServerName() +"/fengYouH5/web-mobile-4/index.html";
////			System.out.println(backUrl + "backUrl");
////			String url="https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + appid+
////					"&redirect_uri=" + URLEncoder.encode(backUrl,"UTF-8")+
////					"&response_type=code" +
////					"&scope=snsapi_userinfo" +
////					"&state=STATE#wechat_redirect";
////			System.out.println(url + "url");
////			resp.sendRedirect(url);
////		}else {
//		Response vo = new Response();
//		OAuthVo wechat = null;
//		String url = "https://api.weixin.qq.com/sns/jscode2session?appid=" + appid +

//				"&js_code=" + code +
//				"&grant_type=authorization_code";
//
//		JSONObject jsonObject = doGetJson(url);
//
//		System.out.println(jsonObject.toJSONString());
//
//		if (StringUtil.isEmpty(jsonObject.getString("openid"))) {
//			vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//			vo.setData("网络异常,请稍后再试!!");
//			return JSONUtil.parseJSONContainsNull(vo);
//		}
//
//		vo.setData(jsonObject.getString("openid"));
//		vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//
//		return JSONUtil.parseJSONContainsNull(vo);
//	}


	@ResponseBody
	@RequestMapping(value = "sendSMS4bindPhone", method = { RequestMethod.POST,
			RequestMethod.GET }, produces = "application/json; charset=utf-8")
	@Operation(summary = "sendSMS4bindPhone", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String sendSMS4bindPhone(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
			@Parameter(required = true, name = "phone", description = "电话号码") @RequestParam(value = "phone") String phone,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = null;
		try {
			response =  playerService.sendSMS4bindPhone(XYUid,phone);
		} catch (InfServerException ie) {
			log.error("查看这个Id是否是代理：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		} catch (Exception e) {
			log.error("查看这个Id是否是代理：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
		}
		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}

    @ResponseBody
    @RequestMapping(value = "bindPhoneBySms", method = { RequestMethod.POST,
            RequestMethod.GET }, produces = "application/json; charset=utf-8")
    @Operation(summary = "bindPhoneBySms", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String bindPhoneBySms(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
			@Parameter(required = true, name = "phone", description = "电话号码") @RequestParam(value = "phone") String phone,
            @Parameter(required = true, name = "code", description = "电话号码") @RequestParam(value = "code") String code,
            @Parameter(required = true, name = "password", description = "电话号码") @RequestParam(value = "password") String password,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {
            response =  playerService.bindPhoneBySms(XYUid,phone,code,password);
        } catch (InfServerException ie) {
            log.error("查看这个Id是否是代理：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            log.error("查看这个Id是否是代理：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
        }
        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
            return CommonUtil.buildJSONPResponse(method, response);
        }
        return JSON.toJSONString(response);
    }

//	@ResponseBody
//	@RequestMapping(value = "test", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@Operation(summary = "test", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String test(
//			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
//			@Parameter(required = true, name = "groupId", description = "groupId") @RequestParam(value = "groupId") Integer groupId,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			Integer point =  playerService.test(XYUid, groupId);
//			response.setData(point);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (InfServerException ie) {
//			log.error("查看这个Id是否是代理：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("查看这个Id是否是代理：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

//    @ResponseBody
//    @RequestMapping(value = "updatePassBySms", method = { RequestMethod.POST,
//            RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @Operation(summary = "updatePassBySms", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String updatePassBySms(
//            @Parameter(required = true, name = "phone", description = "phone") @RequestParam(value = "phone") String phone,
//            @Parameter(required = true, name = "code", description = "code") @RequestParam(value = "code") String code,
//            @Parameter(required = true, name = "password", description = "password") @RequestParam(value = "password") String password,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            response =  playerService.updatePassBySms(phone,code,password);
//        } catch (InfServerException ie) {
//            log.error("查看这个Id是否是代理：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("查看这个Id是否是代理：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }

}
