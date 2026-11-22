package com.j.joker.controller.common;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.controller.BaseController;
import com.j.joker.core.util.JSONUtil;
import com.j.joker.core.util.ResponseUtil;
import com.j.joker.cache.model.CachePlayerProfile;
import com.j.joker.cache.model.CacheUserListProfile;
import com.j.joker.cache.model.CacheUserProfile;
import com.j.joker.constants.Constants;
import com.j.joker.datasource.DbContextHolder;
import com.j.joker.mapper.TSecUserMapper;
import com.j.joker.mapper.TTestConfigMapper;
import com.j.joker.mapper.TUserMapper;
import com.j.joker.model.FreeGameActivityInfo;
import com.j.joker.model.TUser;
import com.j.joker.service.common.GameService;
import com.j.joker.service.common.UserService;
import com.j.joker.service.common.VersionService;
import com.j.joker.service.player.PlayerService;
import com.j.joker.service.roomcard.RoomCardService;
import com.j.joker.utils.CommonUtil;
import com.j.joker.utils.InfServerException;
import com.j.joker.vo.response.Response;
import com.j.joker.vo.response.game.UserOnlineGame;
import com.j.joker.vo.response.user.AccountVo;
import com.j.joker.vo.response.user.LoginVo;
import com.j.joker.vo.response.user.RandomCodeVo;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.Parameter;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.ServletRequestDataBinder;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

//import com.j.joker.model.TCoinExchange;
//import com.j.joker.model.TMoments;
//import com.j.joker.model.TUserGame;

/**
 * 首页控制器
 * 
 * @author apple
 *
 */

@Tag(name = "用户信息接口")
@Controller
public class UserController extends BaseController {

	private static final Log log = LogFactory.getLog(UserController.class);

	@Autowired
	private PlayerService playerService;
	@Autowired
    private UserService userService;
    @Autowired
    private RoomCardService roomCardService;
    @Autowired
	private GameService gameService;
    
	@InitBinder  
    protected void initBinder(HttpServletRequest request,  
            ServletRequestDataBinder binder) throws Exception {  
            DateFormat df = new SimpleDateFormat("yyyy-MM-dd");  
            CustomDateEditor editor = new CustomDateEditor(df, false);  
            binder.registerCustomEditor(Date.class, editor);  
    }
	
    @ResponseBody
    @RequestMapping(value = "userLogin", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @Operation(summary = "用户登陆", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "用户登陆")
    public String userLogin(
            @Parameter(required = true, name = "phone", description = "手机号")
            @RequestParam(value = "phone") String phone,
            @Parameter(required = true, name = "password", description = "密码")
            @RequestParam(value = "password") String password,
            @Parameter(required = false, name = "type", description = "用户类型")
            @RequestParam(required = false, value = "type") String type,
            @Parameter(required = true, name = "device", description = "登录设备，0:IOS;1：ANDROID;2：PC;3：其他")
            @RequestParam(value = "device") Integer device,
            @Parameter(name = "nickname", required = false, description = "昵称，当传入此值时会将原有昵称替换")
            @RequestParam(value = "nickname", required = false) String nickname,
            @Parameter(name = "gender", required = false, description = "性别，当传入此值时会将原有性别替换")
            @RequestParam(value = "gender", required = false) String gender,
            @Parameter(name = "photo", required = false, description = "头像，当传入此值时会将原有性别替换")
            @RequestParam(value = "photo", required = false) String photo,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
            @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) 
    {
        Response response =  new Response();
        try {
            LoginVo vo = userService.login(phone, password, type, device, nickname, gender, photo);
            Long userId = vo.getUserid();
            CacheUserProfile profile = userService.getUserInfo(userId, type);
            profile.setToken(vo.getToken());
            JSONObject json = (JSONObject)JSON.toJSON(profile);
            if (vo.getIsFirstLogin() == null || vo.getIsFirstLogin().equals(0)) {
                json.put("isLogined", 0);
                Integer sendCardCount = roomCardService.queryFirstLoginSendCardCount();
                json.put("sendCardCount", sendCardCount);
            }
            response = ResponseUtil.getSuccessWithDataResponse(json);
        } catch (InfServerException e) {
            log.error("用户登陆：", e);
            response =  new Response();
            response.setReturnCode(e.getErrorCode());
            response.setError(e.getErrorMsg());
        } catch (Exception e) {
            log.error("用户登陆：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
        }
        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
            return CommonUtil.buildJSONPResponse(method, response);
        }
        return JSON.toJSONString(response);
    }

//    @ResponseBody
//    @RequestMapping(value = "userFirstLoginSentCard", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "第一次登陆领取房卡和金币", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "用户登陆")
//    public String userLogin(
//            @Parameter(name = "userId", required = true, description = "用户ID") @RequestParam(value = "userId", required = true) Long userId,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request)
//    {
//        Response response =  new Response();
//        try {
//
//            response = userService.userFirstLoginSentCard(userId);
//
//        } catch (InfServerException e) {
//            log.error("第一次登陆领取房卡和金币：", e);
//            response =  new Response();
//            response.setReturnCode(e.getErrorCode());
//            response.setError(e.getErrorMsg());
//        } catch (Exception e) {
//            log.error("第一次登陆领取房卡和金币：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/getUserInfo", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "获取用户资料", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "获取用户资料")
//    public String getUserInfo(
//            @Parameter(required = true, name = "userId", description = "用户名,唯一")
//            @RequestParam(value = "userId") String userId,
//            @Parameter(required = true, name = "type", description = "用户类型")
//            @RequestParam(value = "type") String type,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request)
//    {
//        Response response = new Response();
//        try {
//            if(type.equalsIgnoreCase(Constants.USER_TYPE_C)) {
////                CacheCompereProfile compere = compereService.getCompereInfoById(userId.toString());
////                response = ResponseUtil.getSuccessWithDataResponse(compere);
//            } else if (type.equalsIgnoreCase(Constants.USER_TYPE_P)) {
//                CachePlayerProfile player = playerService.getPlayerInfoById(userId.toString());
//                response = ResponseUtil.getSuccessWithDataResponse(player);
//            } else {
//                response =  ResponseUtil.getErrorResponse(Constants.RETURN_CODE_FAIL);
//            }
//        } catch(InfServerException ie){
//            log.error("获取用户资料：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("获取用户资料：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "getRandomCode", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "获取随机验证码", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "获取随机验证码")
//    public String getRandomCode(
//            @Parameter(required = true, name = "phone", description = "手机号")
//            @RequestParam(value = "phone") String phone,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//    	Response response = new Response();
//        try {
//            RandomCodeVo vo = new RandomCodeVo();
//            String code = userService.getRandomCode(phone);
//            vo.setSecureCode(code);
//            response.setData(vo);
//        } catch (InfServerException ie) {
//            ie.printStackTrace();
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            e.printStackTrace();
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "modifyPasswordByCode", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "通过手机验证码找回密码", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "通过手机验证码找回密码")
//    public String modifyPasswordByCode(
//            @Parameter(required = true, name = "phone", description = "手机号")
//            @RequestParam(value = "phone") String phone,
//            @Parameter(required = true, name = "code", description = "验证码")
//            @RequestParam(value = "code") String code,
//            @Parameter(required = true, name = "password", description = "新密码")
//            @RequestParam(value = "password") String password,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request)
//    {
//        Response response = new Response();
//        try {
//            if(userService.isCodeValid(phone, code, 5)) {
//                boolean isUpdated = userService.updateUserPassword(phone, password);
//                if(isUpdated) {
//                    response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//                }
//            } else {
//                response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            }
//        } catch (Exception e) {
//            log.error("modifyPasswordByCode：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "modifyPasswordByOldPassword", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "通过旧密码找回密码", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "通过旧密码找回密码")
//    public String modifyPasswordByOldPassword(
//            @Parameter(required = true, name = "phone", description = "手机号")
//            @RequestParam(value = "phone") String phone,
//            @Parameter(required = true, name = "oldPassword", description = "旧密码")
//            @RequestParam(value = "oldPassword") String oldPassword,
//            @Parameter(required = true, name = "password", description = "新密码")
//            @RequestParam(value = "password") String password,
//            HttpServletRequest request)
//    {
//        Response response = new Response();
//        try {
//            TUser user = userService.findUserByPhone(phone);
////            if(EncryptUtils.encodeMD5String(oldPassword).equals(user.getPassword())) {
////                boolean isUpdated = userService.updateUserPassword(phone, password);
////                if(isUpdated) {
////                    response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////                    return JSONObject.toJSONString(response);
////                }
////            }
//            if(oldPassword.equalsIgnoreCase(user.getPassword())) {
//                boolean isUpdated = userService.updateUserPassword(phone, password);
//                if(isUpdated) {
//                    response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//                    return JSONObject.toJSONString(response);
//                }
//            } else {
//                response.setError("旧密码验证失败！");
//            }
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONObject.toJSONString(response);
//        } catch (Exception e) {
//            log.error("modifyPasswordByOldPassword：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "addAttention", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "添加关注", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "添加关注")
//    public String addAttention(
//            @Parameter(required = true, name = "userId", description = "userId") @RequestParam(value = "userId") String userId,
//            @Parameter(required = true, name = "userType", description = "userType") @RequestParam(value = "userType") String userType,
//            @Parameter(required = true, name = "compereId", description = "compereId") @RequestParam(value = "compereId") String compereId,
//            HttpServletRequest request)
//    {
//        Response response = new Response();
//
//        try {
//            //先拿Redis
//            userService.addAttention(userId, userType, compereId);
//
//            response.setReturnCode("0");
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("addAttention：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "removeAttention", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "取消关注", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "取消关注")
//    public String removeAttention(
//            @Parameter(required = true, name = "userId", description = "userId") @RequestParam(value = "userId") String userId,
//            @Parameter(required = true, name = "compereId", description = "compereId") @RequestParam(value = "compereId") String compereId,
//            HttpServletRequest request)
//    {
//        Response response = new Response();
//
//        try {
//            //先拿Redis
//            userService.removeAttention(userId, compereId);
//
//            response.setReturnCode("0");
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("removeAttention：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "recommendUser", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "分享", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "分享")
//    public String recommendUser(
//            @Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//            @Parameter(required = true, name = "userType", description = "用户类型") @RequestParam(value = "userType") String userType,
//            HttpServletRequest request)
//    {
//        Response response = new Response();
//
//        try {
//        	userService.share(userId, userType);
//            response.setReturnCode("0");
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("recommendUser：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "createFreeGame", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "创建组局", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "创建组局")
//    public String createFreeGame(
//            @Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//            @Parameter(required = true, name = "phone", description = "电话") @RequestParam(value = "phone") String phone,
//            @Parameter(required = true, name = "coins", description = "底注") @RequestParam(value = "coins") int coins,
//            @Parameter(required = true, name = "gameId", description = "游戏ID") @RequestParam(value = "gameId") String gameId,
//            @Parameter(required = true, name = "minutes", description = "用户ID") @RequestParam(value = "minutes") int minutes,
//            @Parameter(required = true, name = "type", description = "用户类型") @RequestParam(value = "type") String type,
//            @Parameter(required = true, name = "oriCoins", description = "带入筹码") @RequestParam(value = "oriCoins") int oriCoins,
//            @Parameter(required = true, name = "name", description = "组局名称") @RequestParam(value = "name") String name,
//            @Parameter(required = true, name = "level", description = "level") @RequestParam(value = "level") int level,
//            HttpServletRequest request)
//    {
//        Response response = new Response();
//
//        try {
//
//        	response.setData(userService.createFreeGame(userId, phone, coins, gameId, level, minutes, type, oriCoins, name));
//            response.setReturnCode("0");
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("createFreeGame：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "startFreeGame", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "开始组局", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "开始组局")
//    public String startFreeGame(
//            @Parameter(required = true, name = "inviteCode", description = "邀请码") @RequestParam(value = "inviteCode") String inviteCode,
//            HttpServletRequest request)
//    {
//        Response response = new Response();
//
//        try {
//        	userService.startFreeGame(inviteCode);
//            response.setReturnCode("0");
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("startFreeGame：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "closeFreeGame", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "关闭组局", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "关闭组局")
//    public String closeFreeGame(
//            @Parameter(required = true, name = "inviteCode", description = "邀请码") @RequestParam(value = "inviteCode") String inviteCode,
//            @Parameter(required = false, name = "activityId", description = "活动id") @RequestParam(required = false, value = "activityId") String activityId,
//            @Parameter(required = false, name = "rounds", description = "局数") @RequestParam(required = false, value = "rounds") String rounds,
//            HttpServletRequest request)
//    {
//        Response response = new Response();
//
//        try {
//        	userService.closeFreeGame(inviteCode, activityId, rounds);
//            response.setReturnCode("0");
//
//            //查看VIP游戏用户是否过期,过期的话就修改为普通游戏用户
////            DbContextHolder.setDataSource(Constants.USERCENTERDATASOURCE);
////            boolean flag = secUserMapper.isOverByCeshiManager() > 0;
////            DbContextHolder.clearDataSource();
////
////            DbContextHolder.setDataSource(Constants.COMMONDATASOURCE);
////            if( flag ) {
////                testConfigMapper.delByCeshi();
////            }
////            DbContextHolder.clearDataSource();
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("closeFreeGame：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }finally {
////            DbContextHolder.clearDataSource();
//        }
//    }
    
    @ResponseBody
    @RequestMapping(value = "joinFreeGame", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "加入组局", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "加入组局")
    public String joinFreeGame(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
            @Parameter(required = true, name = "invitationCode", description = "邀请码") @RequestParam(value = "invitationCode") String invitationCode,
            @Parameter(required = true, name = "type", description = "用户类型") @RequestParam(value = "type") String type,
            @Parameter(required = false, name = "activityId", description = "活动ID") @RequestParam(required = false, value = "activityId") String activityId,
            @Parameter(required = false, name = "level", description = "level") @RequestParam(required = false, value = "level") Integer level,
            @Parameter(required = false, name = "isWatch", description = "是否观战, 1 : 不是观战, 其他,是观战") @RequestParam(required = false, value = "isWatch", defaultValue = "1") Integer isWatch,
            @Parameter(required = false, name = "configId", description = "configId") @RequestParam(required = false, value = "configId") Integer configId,
            HttpServletRequest request)
    {
        Response response = new Response();
        
        try {
            String status = userService.statusByUserId(XYUid);
            if ( status == null || status.equals("0")) {
                response.setReturnCode(Constants.RETURN_CODE_FAIL);
                response.setError("您好,您的账号已经被封停了,请联系您的代理!!");
                return JSON.toJSONString(response);
            }
        	response.setData(userService.joinFreeGame(XYUid, invitationCode,activityId, level,configId,isWatch));
            response.setReturnCode("0");
            return JSON.toJSONString(response);
        } catch (Exception e) {
            log.error("加入组局：", e);
            CommonUtil.BuildErrorResponse(e, response);
			return JSON.toJSONString(response);
        }
    }
    
//    @ResponseBody
//    @RequestMapping(value = "joinGroupGame", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "加入组局并查看用户游戏在线情况与组局记录", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "加入组局并查看用户游戏在线情况与组局记录")
//    public String joinGroupGame(
//            @Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//            @Parameter(required = true, name = "invitationCode", description = "邀请码") @RequestParam(value = "invitationCode") String invitationCode,
//            @Parameter(required = false, name = "activityId", description = "活动ID") @RequestParam(required = false, value = "activityId") String activityId,
//            @Parameter(required = false, name = "level", description = "level") @RequestParam(required = false,value = "level") Integer level,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//			@RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request){
//        Response response = new Response();
//
//        try {
//        	JSONObject object = new JSONObject();
//
//        	List<FreeGameActivityInfo> reganizeHistory=userService.viewReganizeGames(userId);
//        	UserOnlineGame userOnlineGame = gameService.queryUserOnlineGame(userId);
//        	Object joinFreeGame= userService.joinFreeGame(userId, invitationCode, activityId, level,null,null);
//        	object.put("reganizeHistory", reganizeHistory);
//        	object.put("userOnlineGame", userOnlineGame);
//        	object.put("joinFreeGame", joinFreeGame);
//        	response.setData(object);
//        	response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("加入组局并查看组局记录与版本信息：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "exitFreeGame", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "退出组局", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "退出组局")
//    public String exitFreeGame(
//            @Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//            @Parameter(required = true, name = "type", description = "用户类型") @RequestParam(value = "type") String type,
//            @Parameter(required = true, name = "invitationCode", description = "邀请码") @RequestParam(value = "invitationCode") String invitationCode,
//
//            HttpServletRequest request)
//    {
//        Response response = new Response();
//
//        try {
//        	userService.exitFreeGame(userId, type, invitationCode);
//            response.setReturnCode("0");
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("退出组局：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }

//    @ResponseBody
//    @RequestMapping(value = "exitFreeGameByDbDateAndGame", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "踢人或者中途退出专用,清除数据库记录和通知游戏服", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "踢人或者中途退出专用,清除数据库记录和通知游戏服")
//    public String exitFreeGameByDbDateAndGame(
//            @Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//            @Parameter(required = true, name = "activityId", description = "activityId") @RequestParam(value = "activityId") String activityId,
//            @Parameter(required = true, name = "table_id", description = "table_id") @RequestParam(value = "table_id") Integer table_id,
//
//            HttpServletRequest request)
//    {
//        Response response = new Response();
//
//        try {
//            userService.exitFreeGameByDbDateAndGame(table_id,userId, activityId);
//            response.setReturnCode("0");
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("踢人或者中途退出：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//            return JSON.toJSONString(response);
//        }
//    }

//    @ResponseBody
//    @RequestMapping(value = "invitePlayerForFreeGame", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "邀请玩家组局", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "邀请玩家组局")
//    public String invitePlayerForFreeGame(
//            @Parameter(required = true, name = "invitationCode", description = "邀请码") @RequestParam(value = "invitationCode") String invitationCode,
//            @Parameter(required = true, name = "phones", description = "手机号集合") @RequestParam(value = "phones") List<String> phones,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	userService.invitePlayerForFreeGame(invitationCode, phones);
//            response.setReturnCode("0");
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("邀请玩家组局：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "viewPlayerGameLevels", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "查看玩家个人段位", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "查看玩家个人段位")
//    public String viewPlayerGameLevels(
//    		@Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//        	List<TUserGame> userGames = userService.queryUserGameDanByUserId(Long.parseLong(userId));
//            response.setData(userGames);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("查看玩家个人段位：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "viewReganizeHistory", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "查看组局记录,重连使用", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "查看组局记录")
//    public String viewReganizeHistory(
//    		@Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//            response.setData(userService.viewReganizeGames(userId));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("查看组局记录：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }


    @ResponseBody
    @RequestMapping(value = "queryUserGameStatus", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "重连(统一使用接口)", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "查看组局记录")
    public String queryUserGameStatus(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
            HttpServletRequest request) {
        Response response = new Response();

        try {
            response.setData(userService.queryUserGameStatus(XYUid));
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);

            return JSON.toJSONString(response);
        } catch (Exception e) {
            log.error("查看组局记录：", e);
            CommonUtil.BuildErrorResponse(e, response);
            return JSON.toJSONString(response);
        }
    }

    
//    @ResponseBody
//	@RequestMapping(value = "queryOwnActivitiesByUserId", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@Operation(summary = "查询用户所有创建的组局", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String queryOwnActivitiesByUserId(
//			@Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") String userId,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//
//        try {
//            response.setData(userService.viewOwnReganizeGames(userId));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("查看组局记录：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//	}
//
//    @ResponseBody
//    @RequestMapping(value = "viewActivityPlayers", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "查看组局玩家", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "查看组局玩家")
//    public String viewActivityPlayers(
//    		@Parameter(required = true, name = "activityId", description = "活动ID") @RequestParam(value = "activityId") String activityId,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//            response.setData(userService.viewReganizeGameUsers(activityId));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("查看组局玩家：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/queryUserFriends", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "查看玩家好友列表", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "查看玩家好友列表")
//    public String queryUserFriends(
//    		@Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	List<CacheUserListProfile> friends = userService.queryFriendsByUserId(Long.parseLong(userId));
//            response.setData(friends);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("查看玩家好友列表：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/transmitVerifyMessage", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "转发审核消息", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "转发审核消息")
//    public String transmitVerifyMessage(
//            @Parameter(required = true, name = "phone", description = "电话号码") @RequestParam(value = "phone") String phone,
//            @Parameter(required = true, name = "message", description = "消息内容") @RequestParam(value = "message") String message,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//            userService.transmitVerifyMessage(phone, message);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("转发审核消息：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//            return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/transmitGetuiMessage", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "转发个推消息", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "转发个推消息")
//    public String transmitGetuiMessage(
//            @Parameter(required = true, name = "message", description = "消息内容") @RequestParam(value = "message") String message,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            userService.transmitGetuiMessage(message);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("转发个推消息：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//            return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/addFriend", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "添加好友", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "添加玩家")
//    public String addFriend(
//    		@Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//    		@Parameter(required = true, name = "friendPhone", description = "好友电话号码") @RequestParam(value = "friendPhone") String friendPhone,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	userService.addFriend(Long.parseLong(userId), friendPhone);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("添加好友：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/removeFriend", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "删除好友", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "添加玩家")
//    public String removeFriend(
//    		@Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//    		@Parameter(required = true, name = "friendPhone", description = "好友电话号码") @RequestParam(value = "friendPhone") String friendPhone,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	userService.deleteFriend(Long.parseLong(userId), friendPhone);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("删除好友：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/queryUserBlacklist", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "查看玩家黑名单", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "查看玩家好友列表")
//    public String queryUserBlacklist(
//    		@Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	List<CacheUserListProfile> blacklist = userService.queryBlacklistByUserId(Long.parseLong(userId));
//            response.setData(blacklist);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("查看玩家黑名单：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/addToBlacklist", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "添加黑名单", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "添加黑名单")
//    public String addToBlacklist(
//    		@Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//    		@Parameter(required = true, name = "blackUserPhone", description = "黑名单用户电话号码") @RequestParam(value = "blackUserPhone") String blackUserPhone,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//        	userService.addToBlacklist(Long.parseLong(userId), blackUserPhone);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("添加黑名单：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }

//    @ResponseBody
//    @RequestMapping(value = "user/removeFromBlacklist", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "移出黑名单", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "移出黑名单")
//    public String removeFromBlacklist(
//    		@Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//    		@Parameter(required = true, name = "blackUserPhone", description = "黑名单用户电话号码") @RequestParam(value = "blackUserPhone") String blackUserPhone,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	userService.deleteBlacklist(Long.parseLong(userId), blackUserPhone);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("移出黑名单：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/compereRank", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "主播排行榜", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "主播排行榜")
//    public String compereRank(
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	response.setData(userService.queryCompereRank());
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("主播排行榜：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/varifyPhones", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "验证电话", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "验证电话")
//    public String varifyPhones(
//    		@Parameter(required = true, name = "phones", description = "电话号码串") @RequestParam(value = "phones") String phones,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	response.setData(userService.varifyPhones(phones));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("验证电话：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/varifyIdentity", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "实名认证", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "实名认证")
//    public String varifyIdentity(
//    		@Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") String userId,
//    		@Parameter(required = true, name = "name", description = "姓名") @RequestParam(value = "name") String name,
//    		@Parameter(required = true, name = "identity", description = "身份证") @RequestParam(value = "identity") String identity,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	userService.varifyIdentity(userId,name,identity);
//
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("实名认证：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/createGroup", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "创建群组", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "创建群组")
//    public String createGroup(
//    		@Parameter(required = true, name = "userId", description = "创建人ID") @RequestParam(value = "userId") String userId,
//    		@Parameter(required = true, name = "groupName", description = "群组名称") @RequestParam(value = "groupName") String groupName,
//    		@Parameter(required = true, name = "easeGroupId", description = "环信群ID") @RequestParam(value = "easeGroupId") String easeGroupId,
//    		@Parameter(required = true, name = "invitees", description = "被邀请人ID") @RequestParam(value = "invitees") String invitees,
//    		@Parameter(required = true, name = "photoUrl", description = "群组头像") @RequestParam(value = "photoUrl") String photoUrl,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	response.setData(userService.createGroup(userId, groupName, easeGroupId, invitees, photoUrl));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("创建群组：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/inviteJoinGroup", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "邀请入群组", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "邀请入群组")
//    public String inviteJoinGroup(
//    		@Parameter(required = true, name = "groupId", description = "群组ID") @RequestParam(value = "groupId") String groupId,
//    		@Parameter(required = true, name = "invitees", description = "被邀请人ID") @RequestParam(value = "invitees") String invitees,
//    		@Parameter(required = true, name = "photoUrl", description = "群组头像") @RequestParam(value = "photoUrl") String photoUrl,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
////        	response.setData(userService.inviteJoinGroup(groupId, invitees));
//        	userService.inviteJoinGroup(groupId, invitees, photoUrl);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("邀请入群组：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/joinGroup", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "加入群组", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "加入群组")
//    public String joinGroup(
//    		@Parameter(required = true, name = "userId", description = "加入者ID") @RequestParam(value = "userId") String userId,
//    		@Parameter(required = true, name = "groupId", description = "群组ID") @RequestParam(value = "groupId") String groupId,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	response.setData(userService.joinGroup(userId, groupId));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("加入群组：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/exitGroup", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "退出群组", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "退出群组")
//    public String exitGroup(
//    		@Parameter(required = true, name = "userId", description = "退出者ID") @RequestParam(value = "userId") String userId,
//    		@Parameter(required = true, name = "groupId", description = "群组ID") @RequestParam(value = "groupId") String groupId,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	userService.exitGroup(userId, groupId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("退出群组：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/modifyGroup", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "修改群组", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "修改群组")
//    public String modifyGroup(
//    		@Parameter(required = false, name = "userId", description = "新群主ID") @RequestParam(required = false, value = "userId") String userId,
//    		@Parameter(required = false, name = "groupName", description = "群组名称") @RequestParam(required = false, value = "groupName") String groupName,
//    		@Parameter(required = true, name = "groupId", description = "群组ID") @RequestParam(value = "groupId") String groupId,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	userService.modifyGroup(userId, groupId, groupName);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("修改群组：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/queryGroup", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "查询群组", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "查询群组")
//    public String queryGroup(
//    		@Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	response.setData(userService.queryGroups(userId));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("查询群组：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/queryGroupDetails", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "查询群组详情", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "查询群组详情")
//    public String queryGroupDetails(
//    		@Parameter(required = true, name = "groupId", description = "群组ID") @RequestParam(value = "groupId") String groupId,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	response.setData(userService.queryGroupDetails(groupId));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("查询群组详情：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
    
//    @ResponseBody
//	@RequestMapping(value = "user/viewAccount", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@Operation(summary = "查询余额", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "查询余额")
//	public String viewAccount(
//			@Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") String userId,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//    	try {
//			AccountVo vo = userService.viewAccount(userId);
//			response.setData(vo);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//            log.error("查询余额：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//	}
//
//    @ResponseBody
//	@RequestMapping(value = "user/exchangeDiamond", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@Operation(summary = "宝贝币兑换房卡", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "宝贝币兑换房卡")
//	public String exchange(
//			@Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") String userId,
//			@Parameter(required = true, name = "coinAmount", description = "游戏币数") @RequestParam(value = "coinAmount") String coinAmount,
//			@Parameter(required = true, name = "jewelAmount", description = "房卡数") @RequestParam(value = "jewelAmount") String jewelAmount,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//    	Response response = new Response();
//		try {
//			AccountVo vo = userService.exchangeDiamond(userId, Long.parseLong(coinAmount), Long.parseLong(jewelAmount));
//			response.setData(vo);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//            log.error("宝贝币兑换房卡：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//	}
//
//    @ResponseBody
//	@RequestMapping(value = "user/exchangeHistory", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@Operation(summary = "宝贝币兑换房卡记录", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "宝贝币兑换房卡记录")
//	public String exchangeHistory(
//			@Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") String userId,
//			@Parameter(required = true, name = "startDate", description = "查询起始日期,yyyy-MM-dd") @RequestParam(value = "startDate") String startDate,
//			@Parameter(required = true, name = "endDate", description = "查询结束日期,yyyy-MM-dd") @RequestParam(value = "endDate") String endDate,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//    	Response response = new Response();
//		try {
////			List<TCoinExchange> coinExchanges = coinExchangeService.findCoinExchangeHistory(Long.parseLong(userId), startDate, endDate);
////			response.setData(coinExchanges);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//            log.error("宝贝币兑换房卡记录：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//	}
	
//    @ResponseBody
//	@RequestMapping(value = "user/updateLocation", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@Operation(summary = "更新地理位置", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "更新地理位置")
//	public String updateLocation(
//			@Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") String userId,
//			@Parameter(required = true, name = "latitude", description = "纬度") @RequestParam(value = "latitude") float latitude,
//			@Parameter(required = true, name = "longitude", description = "经度") @RequestParam(value = "longitude") float longitude,
//			@Parameter(required = true, name = "type", description = "用户类型") @RequestParam(value = "type") String type,
//			HttpServletRequest request) {
//    	Response response = new Response();
//		try {
//			userService.updateLocation(userId, latitude, longitude, type);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//		} catch (Exception e) {
//            log.error("更新地理位置：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//	}
    
//    @ResponseBody
//    @RequestMapping(value = "user/getTaskList", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "用户任务列表", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "用户任务列表")
//    public String getTaskList(
//            @Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") String userId,
//            @Parameter(required = true, name = "userType", description = "用户类型") @RequestParam(value = "userType") String userType,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<CacheTask> tasks = userService.queryUserTaskList(userId, userType);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(tasks);
//        } catch (Exception e) {
//            log.error("用户任务列表：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/uploadMoments", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "用户上传图片视频文字", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String uploadMoments(
//            @Parameter(required = true, name = "userId", description = "用户id")
//            @RequestParam(value = "userId") Long userId,
//            @Parameter(name = "text", description = "朋友圈文字")
//            @RequestParam(required = false, value = "text") String text,
//            @Parameter(name = "photos", description = "json格式图片列表路径")
//            @RequestParam(value = "photos") String photos,
//            @Parameter(name = "type", description = "资源类型，0图片；1视频")
//            @RequestParam(value = "type") String type,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
//            userService.uploadMoments(userId, text, photos, type);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("用户上传图片视频文字：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("用户上传图片视频文字：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/turnMomentPage", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "朋友圈翻页", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String turnMomentPage(
//            @Parameter(required = true, name = "userId", description = "用户id")
//            @RequestParam(value = "userId") Long userId,
//            @Parameter(name = "pageNo", description = "页码，如第二页传2")
//            @RequestParam(required = true, value = "pageNo") Integer pageNo,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
//            List<TMoments> list = userService.turnMomentPage(userId, pageNo);
//            vo.setData(list);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("朋友圈翻页：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("朋友圈翻页：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
    
//    @ResponseBody
//    @RequestMapping(value = "user/isPhoneExist", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "手机号是否已被注册", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String isPhoneExist(
//            @Parameter(required = true, name = "phone", description = "用户手机号")
//            @RequestParam(value = "phone") String phone,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
//            boolean isExist = userService.isPhoneExist(phone);
//            vo.setData(isExist);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("手机号是否已被注册：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("手机号是否已被注册：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "user/setPayPassword", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "设置支付密码", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String setPayPassword(
//            @Parameter(required = true, name = "userId", description = "用户id")
//            @RequestParam(value = "userId") Long userId,
//            @Parameter(required = true, name = "payPassword", description = "支付密码，MD5之后的值")
//            @RequestParam(value = "payPassword") String payPassword,
//            @Parameter(required = true, name = "userType", description = "用户类型：C主播；P玩家")
//            @RequestParam(value = "userType") String userType,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
////            userService.setPayPassword(userId, payPassword, userType);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("设置支付密码：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("设置支付密码：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "user/varifyPayPassword", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "验证旧支付密码", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String varifyPayPassword(
//            @Parameter(required = true, name = "userId", description = "用户id")
//            @RequestParam(value = "userId") Long userId,
//            @Parameter(required = true, name = "oldPayPassword", description = "旧密码")
//            @RequestParam(value = "oldPayPassword") String oldPayPassword,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
////            userService.modifyPayPassword(userId, oldPayPassword);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("验证旧支付密码：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("验证旧支付密码：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }

//    @ResponseBody
//    @RequestMapping(value = "user/increaseJewel", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "增加用户房卡", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String increaseJewel(
//            @Parameter(required = true, name = "userId", description = "用户id")
//            @RequestParam(value = "userId") Long userId,
//            @Parameter(required = true, name = "amount", description = "增加的房卡数量，减房卡传负值")
//            @RequestParam(value = "amount") Integer amount,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
//            Integer jewelAmount = userService.increaseJewel(userId, amount);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            vo.setData(jewelAmount);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("增加用户房卡：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("增加用户房卡：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "user/findUser", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "查找用户", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String findUser(
//            @Parameter(required = true, name = "condition", description = "查询条件")
//            @RequestParam(value = "condition") String condition,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<CacheUserListProfile> users = userService.findUser(condition);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(users);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("查找用户：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//            return JSON.toJSONString(response);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "user/queryToken", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @Operation(summary = "查询token", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String queryToken(
//            @Parameter(required = true, name = "phone", description = "用户手机")
//            @RequestParam(value = "phone") String phone,
//            @Parameter(required = true, name = "oldToken", description = "失效token")
//            @RequestParam(value = "oldToken") String oldToken,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            String token = userService.queryToken(phone, oldToken);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(token);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("查询token：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//            return JSON.toJSONString(response);
//        }
//    }

//    @ResponseBody
//    @RequestMapping(value = "user/buyMonthCard", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "购买月卡", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String buyMonthCard(
//            @Parameter(required = true, name = "userId", description = "用户ID")
//            @RequestParam(value = "userId", required = true) Long userId,
//            @Parameter(required = true, name = "cardType", description = "月卡类型，红卡0，蓝卡1")
//            @RequestParam(value = "cardType", required = true) Integer cardType,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            JSONObject result = userService.buyMonthCard(userId, cardType);
//            response.setData(result);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("购买月卡：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }

//    @ResponseBody
//    @RequestMapping(value = "user/gameSignIn", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "游戏自动签到", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String gameSignIn(
//            @Parameter(required = true, name = "userId", description = "用户ID")
//            @RequestParam(value = "userId", required = true) Long userId,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            JSONObject result = userService.gameSignIn(userId);
//            response.setData(result);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("游戏自动签到：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }

//    @ResponseBody
//    @RequestMapping(value = "user/isGameSignIn", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "游戏自动签到", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String isGameSignIn(
//            @Parameter(required = true, name = "userId", description = "用户ID")
//            @RequestParam(value = "userId", required = true) Long userId,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            JSONObject result = userService.isGameSignIn(userId);
//            response.setData(result);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("游戏自动签到：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }

//    @ResponseBody
//    @RequestMapping(value = "user/getAllowance", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "领取破产补助", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String getAllowance(
//            @Parameter(required = true, name = "userId", description = "用户ID")
//            @RequestParam(value = "userId", required = true) Long userId,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            JSONObject result = userService.getAllowance(userId);
//            response.setData(result);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("领取破产补助：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }

//    @ResponseBody
//    @RequestMapping(value = "user/hasMonthCard", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "是否有月卡", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String hasMonthCard(
//            @Parameter(required = true, name = "userId", description = "用户ID")
//            @RequestParam(value = "userId", required = true) Long userId,
//            @Parameter(required = true, name = "cardType", description = "月卡类型，红卡0，蓝卡1")
//            @RequestParam(value = "cardType", required = true) Integer cardType,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            JSONObject result = userService.hasMonthCard(userId, cardType);
//            response.setData(result);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("是否有月卡：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }

//    @ResponseBody
//    @RequestMapping(value = "user/isFirstCharged", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @Operation(summary = "是否首充", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//    public String isFirstCharged(
//            @Parameter(required = true, name = "userId", description = "用户ID")
//            @RequestParam(value = "userId", required = true) Long userId,
//            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            JSONObject result = userService.isFirstCharged(userId);
//            response.setData(result);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("是否首充：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
}
