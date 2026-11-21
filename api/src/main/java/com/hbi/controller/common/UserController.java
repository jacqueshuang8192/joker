package com.hbi.controller.common;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.core.controller.BaseController;
import com.core.util.JSONUtil;
import com.core.util.ResponseUtil;
import com.hbi.cache.model.CachePlayerProfile;
import com.hbi.cache.model.CacheUserListProfile;
import com.hbi.cache.model.CacheUserProfile;
import com.hbi.constants.Constants;
import com.hbi.datasource.DbContextHolder;
import com.hbi.mapper.TSecUserMapper;
import com.hbi.mapper.TTestConfigMapper;
import com.hbi.mapper.TUserMapper;
import com.hbi.model.FreeGameActivityInfo;
import com.hbi.model.TUser;
import com.hbi.service.common.GameService;
import com.hbi.service.common.UserService;
import com.hbi.service.common.VersionService;
import com.hbi.service.player.PlayerService;
import com.hbi.service.roomcard.RoomCardService;
import com.hbi.utils.CommonUtil;
import com.hbi.utils.InfServerException;
import com.hbi.vo.response.Response;
import com.hbi.vo.response.game.UserOnlineGame;
import com.hbi.vo.response.user.AccountVo;
import com.hbi.vo.response.user.LoginVo;
import com.hbi.vo.response.user.RandomCodeVo;
import com.wordnik.swagger.annotations.Api;
import com.wordnik.swagger.annotations.ApiOperation;
import com.wordnik.swagger.annotations.ApiParam;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.ServletRequestDataBinder;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

//import com.hbi.model.TCoinExchange;
//import com.hbi.model.TMoments;
//import com.hbi.model.TUserGame;

/**
 * 首页控制器
 * 
 * @author apple
 *
 */

@Api(basePath = "/", value = "用户信息接口", position = 1)
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
    @ApiOperation(value = "用户登陆", response = Response.class, notes = "用户登陆")
    public String userLogin(
            @ApiParam(required = true, name = "phone", value = "手机号")
            @RequestParam(value = "phone") String phone,
            @ApiParam(required = true, name = "password", value = "密码")
            @RequestParam(value = "password") String password,
            @ApiParam(required = false, name = "type", value = "用户类型")
            @RequestParam(required = false, value = "type") String type,
            @ApiParam(required = true, name = "device", value = "登录设备，0:IOS;1：ANDROID;2：PC;3：其他")
            @RequestParam(value = "device") Integer device,
            @ApiParam(name = "nickname", required = false, value = "昵称，当传入此值时会将原有昵称替换")
            @RequestParam(value = "nickname", required = false) String nickname,
            @ApiParam(name = "gender", required = false, value = "性别，当传入此值时会将原有性别替换")
            @RequestParam(value = "gender", required = false) String gender,
            @ApiParam(name = "photo", required = false, value = "头像，当传入此值时会将原有性别替换")
            @RequestParam(value = "photo", required = false) String photo,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "第一次登陆领取房卡和金币", response = Response.class, notes = "用户登陆")
//    public String userLogin(
//            @ApiParam(name = "userId", required = true, value = "用户ID") @RequestParam(value = "userId", required = true) Long userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "获取用户资料", httpMethod = "POST", response = Response.class, notes = "获取用户资料")
//    public String getUserInfo(
//            @ApiParam(required = true, name = "userId", value = "用户名,唯一")
//            @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "type", value = "用户类型")
//            @RequestParam(value = "type") String type,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "获取随机验证码", position = 2, response = Response.class, notes = "获取随机验证码")
//    public String getRandomCode(
//            @ApiParam(required = true, name = "phone", value = "手机号")
//            @RequestParam(value = "phone") String phone,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "通过手机验证码找回密码", position = 2, response = Response.class, notes = "通过手机验证码找回密码")
//    public String modifyPasswordByCode(
//            @ApiParam(required = true, name = "phone", value = "手机号")
//            @RequestParam(value = "phone") String phone,
//            @ApiParam(required = true, name = "code", value = "验证码")
//            @RequestParam(value = "code") String code,
//            @ApiParam(required = true, name = "password", value = "新密码")
//            @RequestParam(value = "password") String password,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "通过旧密码找回密码", httpMethod = "POST", position = 2, response = Response.class, notes = "通过旧密码找回密码")
//    public String modifyPasswordByOldPassword(
//            @ApiParam(required = true, name = "phone", value = "手机号")
//            @RequestParam(value = "phone") String phone,
//            @ApiParam(required = true, name = "oldPassword", value = "旧密码")
//            @RequestParam(value = "oldPassword") String oldPassword,
//            @ApiParam(required = true, name = "password", value = "新密码")
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
//    @ApiOperation(value = "添加关注", httpMethod = "POST", response = Response.class, notes = "添加关注")
//    public String addAttention(
//            @ApiParam(required = true, name = "userId", value = "userId") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "userType", value = "userType") @RequestParam(value = "userType") String userType,
//            @ApiParam(required = true, name = "compereId", value = "compereId") @RequestParam(value = "compereId") String compereId,
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
//    @ApiOperation(value = "取消关注", httpMethod = "POST", response = Response.class, notes = "取消关注")
//    public String removeAttention(
//            @ApiParam(required = true, name = "userId", value = "userId") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "compereId", value = "compereId") @RequestParam(value = "compereId") String compereId,
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
//    @ApiOperation(value = "分享", httpMethod = "POST", response = Response.class, notes = "分享")
//    public String recommendUser(
//            @ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "userType", value = "用户类型") @RequestParam(value = "userType") String userType,
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
//    @ApiOperation(value = "创建组局", httpMethod = "POST", response = Response.class, notes = "创建组局")
//    public String createFreeGame(
//            @ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "phone", value = "电话") @RequestParam(value = "phone") String phone,
//            @ApiParam(required = true, name = "coins", value = "底注") @RequestParam(value = "coins") int coins,
//            @ApiParam(required = true, name = "gameId", value = "游戏ID") @RequestParam(value = "gameId") String gameId,
//            @ApiParam(required = true, name = "minutes", value = "用户ID") @RequestParam(value = "minutes") int minutes,
//            @ApiParam(required = true, name = "type", value = "用户类型") @RequestParam(value = "type") String type,
//            @ApiParam(required = true, name = "oriCoins", value = "带入筹码") @RequestParam(value = "oriCoins") int oriCoins,
//            @ApiParam(required = true, name = "name", value = "组局名称") @RequestParam(value = "name") String name,
//            @ApiParam(required = true, name = "level", value = "level") @RequestParam(value = "level") int level,
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
//    @ApiOperation(value = "开始组局", httpMethod = "POST", response = Response.class, notes = "开始组局")
//    public String startFreeGame(
//            @ApiParam(required = true, name = "inviteCode", value = "邀请码") @RequestParam(value = "inviteCode") String inviteCode,
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
//    @ApiOperation(value = "关闭组局", httpMethod = "POST", response = Response.class, notes = "关闭组局")
//    public String closeFreeGame(
//            @ApiParam(required = true, name = "inviteCode", value = "邀请码") @RequestParam(value = "inviteCode") String inviteCode,
//            @ApiParam(required = false, name = "activityId", value = "活动id") @RequestParam(required = false, value = "activityId") String activityId,
//            @ApiParam(required = false, name = "rounds", value = "局数") @RequestParam(required = false, value = "rounds") String rounds,
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
    @ApiOperation(value = "加入组局", httpMethod = "POST", response = Response.class, notes = "加入组局")
    public String joinFreeGame(
            @ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") String XYUid,
            @ApiParam(required = true, name = "invitationCode", value = "邀请码") @RequestParam(value = "invitationCode") String invitationCode,
            @ApiParam(required = true, name = "type", value = "用户类型") @RequestParam(value = "type") String type,
            @ApiParam(required = false, name = "activityId", value = "活动ID") @RequestParam(required = false, value = "activityId") String activityId,
            @ApiParam(required = false, name = "level", value = "level") @RequestParam(required = false, value = "level") Integer level,
            @ApiParam(required = false, name = "isWatch", value = "是否观战, 1 : 不是观战, 其他,是观战") @RequestParam(required = false, value = "isWatch", defaultValue = "1") Integer isWatch,
            @ApiParam(required = false, name = "configId", value = "configId") @RequestParam(required = false, value = "configId") Integer configId,
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
//    @ApiOperation(value = "加入组局并查看用户游戏在线情况与组局记录", httpMethod = "POST", response = Response.class, notes = "加入组局并查看用户游戏在线情况与组局记录")
//    public String joinGroupGame(
//            @ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "invitationCode", value = "邀请码") @RequestParam(value = "invitationCode") String invitationCode,
//            @ApiParam(required = false, name = "activityId", value = "活动ID") @RequestParam(required = false, value = "activityId") String activityId,
//            @ApiParam(required = false,name = "level", value = "level") @RequestParam(required = false,value = "level") Integer level,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "退出组局", httpMethod = "POST", response = Response.class, notes = "退出组局")
//    public String exitFreeGame(
//            @ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "type", value = "用户类型") @RequestParam(value = "type") String type,
//            @ApiParam(required = true, name = "invitationCode", value = "邀请码") @RequestParam(value = "invitationCode") String invitationCode,
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
//    @ApiOperation(value = "踢人或者中途退出专用,清除数据库记录和通知游戏服", httpMethod = "POST", response = Response.class, notes = "踢人或者中途退出专用,清除数据库记录和通知游戏服")
//    public String exitFreeGameByDbDateAndGame(
//            @ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "activityId", value = "activityId") @RequestParam(value = "activityId") String activityId,
//            @ApiParam(required = true, name = "table_id", value = "table_id") @RequestParam(value = "table_id") Integer table_id,
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
//    @ApiOperation(value = "邀请玩家组局", httpMethod = "POST", response = Response.class, notes = "邀请玩家组局")
//    public String invitePlayerForFreeGame(
//            @ApiParam(required = true, name = "invitationCode", value = "邀请码") @RequestParam(value = "invitationCode") String invitationCode,
//            @ApiParam(required = true, name = "phones", value = "手机号集合") @RequestParam(value = "phones") List<String> phones,
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
//    @ApiOperation(value = "查看玩家个人段位", response = Response.class, notes = "查看玩家个人段位")
//    public String viewPlayerGameLevels(
//    		@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "查看组局记录,重连使用", httpMethod = "POST", response = Response.class, notes = "查看组局记录")
//    public String viewReganizeHistory(
//    		@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
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
    @ApiOperation(value = "重连(统一使用接口)", httpMethod = "POST", response = Response.class, notes = "查看组局记录")
    public String queryUserGameStatus(
            @ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") String XYUid,
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
//	@ApiOperation(value = "查询用户所有创建的组局", position = 2, response = Response.class)
//	public String queryOwnActivitiesByUserId(
//			@ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") String userId,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//    @ApiOperation(value = "查看组局玩家", httpMethod = "POST", response = Response.class, notes = "查看组局玩家")
//    public String viewActivityPlayers(
//    		@ApiParam(required = true, name = "activityId", value = "活动ID") @RequestParam(value = "activityId") String activityId,
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
//    @ApiOperation(value = "查看玩家好友列表", httpMethod = "POST", response = Response.class, notes = "查看玩家好友列表")
//    public String queryUserFriends(
//    		@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
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
//    @ApiOperation(value = "转发审核消息", httpMethod = "POST", response = Response.class, notes = "转发审核消息")
//    public String transmitVerifyMessage(
//            @ApiParam(required = true, name = "phone", value = "电话号码") @RequestParam(value = "phone") String phone,
//            @ApiParam(required = true, name = "message", value = "消息内容") @RequestParam(value = "message") String message,
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
//    @ApiOperation(value = "转发个推消息", httpMethod = "POST", response = Response.class, notes = "转发个推消息")
//    public String transmitGetuiMessage(
//            @ApiParam(required = true, name = "message", value = "消息内容") @RequestParam(value = "message") String message,
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
//    @ApiOperation(value = "添加好友", httpMethod = "POST", response = Response.class, notes = "添加玩家")
//    public String addFriend(
//    		@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//    		@ApiParam(required = true, name = "friendPhone", value = "好友电话号码") @RequestParam(value = "friendPhone") String friendPhone,
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
//    @ApiOperation(value = "删除好友", httpMethod = "POST", response = Response.class, notes = "添加玩家")
//    public String removeFriend(
//    		@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//    		@ApiParam(required = true, name = "friendPhone", value = "好友电话号码") @RequestParam(value = "friendPhone") String friendPhone,
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
//    @ApiOperation(value = "查看玩家黑名单", response = Response.class, notes = "查看玩家好友列表")
//    public String queryUserBlacklist(
//    		@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "添加黑名单", response = Response.class, notes = "添加黑名单")
//    public String addToBlacklist(
//    		@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//    		@ApiParam(required = true, name = "blackUserPhone", value = "黑名单用户电话号码") @RequestParam(value = "blackUserPhone") String blackUserPhone,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//    @ApiOperation(value = "移出黑名单", httpMethod = "POST", response = Response.class, notes = "移出黑名单")
//    public String removeFromBlacklist(
//    		@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//    		@ApiParam(required = true, name = "blackUserPhone", value = "黑名单用户电话号码") @RequestParam(value = "blackUserPhone") String blackUserPhone,
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
//    @ApiOperation(value = "主播排行榜", response = Response.class, notes = "主播排行榜")
//    public String compereRank(
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "验证电话", httpMethod = "POST", response = Response.class, notes = "验证电话")
//    public String varifyPhones(
//    		@ApiParam(required = true, name = "phones", value = "电话号码串") @RequestParam(value = "phones") String phones,
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
//    @ApiOperation(value = "实名认证", httpMethod = "POST", response = Response.class, notes = "实名认证")
//    public String varifyIdentity(
//    		@ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") String userId,
//    		@ApiParam(required = true, name = "name", value = "姓名") @RequestParam(value = "name") String name,
//    		@ApiParam(required = true, name = "identity", value = "身份证") @RequestParam(value = "identity") String identity,
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
//    @ApiOperation(value = "创建群组", httpMethod = "POST", response = Response.class, notes = "创建群组")
//    public String createGroup(
//    		@ApiParam(required = true, name = "userId", value = "创建人ID") @RequestParam(value = "userId") String userId,
//    		@ApiParam(required = true, name = "groupName", value = "群组名称") @RequestParam(value = "groupName") String groupName,
//    		@ApiParam(required = true, name = "easeGroupId", value = "环信群ID") @RequestParam(value = "easeGroupId") String easeGroupId,
//    		@ApiParam(required = true, name = "invitees", value = "被邀请人ID") @RequestParam(value = "invitees") String invitees,
//    		@ApiParam(required = true, name = "photoUrl", value = "群组头像") @RequestParam(value = "photoUrl") String photoUrl,
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
//    @ApiOperation(value = "邀请入群组", httpMethod = "POST", response = Response.class, notes = "邀请入群组")
//    public String inviteJoinGroup(
//    		@ApiParam(required = true, name = "groupId", value = "群组ID") @RequestParam(value = "groupId") String groupId,
//    		@ApiParam(required = true, name = "invitees", value = "被邀请人ID") @RequestParam(value = "invitees") String invitees,
//    		@ApiParam(required = true, name = "photoUrl", value = "群组头像") @RequestParam(value = "photoUrl") String photoUrl,
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
//    @ApiOperation(value = "加入群组", httpMethod = "POST", response = Response.class, notes = "加入群组")
//    public String joinGroup(
//    		@ApiParam(required = true, name = "userId", value = "加入者ID") @RequestParam(value = "userId") String userId,
//    		@ApiParam(required = true, name = "groupId", value = "群组ID") @RequestParam(value = "groupId") String groupId,
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
//    @ApiOperation(value = "退出群组", httpMethod = "POST", response = Response.class, notes = "退出群组")
//    public String exitGroup(
//    		@ApiParam(required = true, name = "userId", value = "退出者ID") @RequestParam(value = "userId") String userId,
//    		@ApiParam(required = true, name = "groupId", value = "群组ID") @RequestParam(value = "groupId") String groupId,
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
//    @ApiOperation(value = "修改群组", httpMethod = "POST", response = Response.class, notes = "修改群组")
//    public String modifyGroup(
//    		@ApiParam(required = false, name = "userId", value = "新群主ID") @RequestParam(required = false, value = "userId") String userId,
//    		@ApiParam(required = false, name = "groupName", value = "群组名称") @RequestParam(required = false, value = "groupName") String groupName,
//    		@ApiParam(required = true, name = "groupId", value = "群组ID") @RequestParam(value = "groupId") String groupId,
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
//    @ApiOperation(value = "查询群组", httpMethod = "POST", response = Response.class, notes = "查询群组")
//    public String queryGroup(
//    		@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
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
//    @ApiOperation(value = "查询群组详情", httpMethod = "POST", response = Response.class, notes = "查询群组详情")
//    public String queryGroupDetails(
//    		@ApiParam(required = true, name = "groupId", value = "群组ID") @RequestParam(value = "groupId") String groupId,
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
//	@ApiOperation(value = "查询余额", position = 1, response = Response.class, notes = "查询余额")
//	public String viewAccount(
//			@ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@ApiOperation(value = "宝贝币兑换房卡", position = 2, response = Response.class, notes = "宝贝币兑换房卡")
//	public String exchange(
//			@ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") String userId,
//			@ApiParam(required = true, name = "coinAmount", value = "游戏币数") @RequestParam(value = "coinAmount") String coinAmount,
//			@ApiParam(required = true, name = "jewelAmount", value = "房卡数") @RequestParam(value = "jewelAmount") String jewelAmount,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//	@ApiOperation(value = "宝贝币兑换房卡记录",  position = 2, response = Response.class, notes = "宝贝币兑换房卡记录")
//	public String exchangeHistory(
//			@ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") String userId,
//			@ApiParam(required = true, name = "startDate", value = "查询起始日期,yyyy-MM-dd") @RequestParam(value = "startDate") String startDate,
//			@ApiParam(required = true, name = "endDate", value = "查询结束日期,yyyy-MM-dd") @RequestParam(value = "endDate") String endDate,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@ApiOperation(value = "更新地理位置", httpMethod = "POST", position = 2, response = Response.class, notes = "更新地理位置")
//	public String updateLocation(
//			@ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") String userId,
//			@ApiParam(required = true, name = "latitude", value = "纬度") @RequestParam(value = "latitude") float latitude,
//			@ApiParam(required = true, name = "longitude", value = "经度") @RequestParam(value = "longitude") float longitude,
//			@ApiParam(required = true, name = "type", value = "用户类型") @RequestParam(value = "type") String type,
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
//    @ApiOperation(value = "用户任务列表", response = Response.class, notes = "用户任务列表")
//    public String getTaskList(
//            @ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "userType", value = "用户类型") @RequestParam(value = "userType") String userType,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "用户上传图片视频文字", httpMethod = "POST", position = 1, response = Response.class)
//    public String uploadMoments(
//            @ApiParam(required = true, name = "userId", value = "用户id")
//            @RequestParam(value = "userId") Long userId,
//            @ApiParam(name = "text", value = "朋友圈文字")
//            @RequestParam(required = false, value = "text") String text,
//            @ApiParam(name = "photos", value = "json格式图片列表路径")
//            @RequestParam(value = "photos") String photos,
//            @ApiParam(name = "type", value = "资源类型，0图片；1视频")
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
//    @ApiOperation(value = "朋友圈翻页", httpMethod = "POST", position = 1, response = Response.class)
//    public String turnMomentPage(
//            @ApiParam(required = true, name = "userId", value = "用户id")
//            @RequestParam(value = "userId") Long userId,
//            @ApiParam(name = "pageNo", value = "页码，如第二页传2")
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
//    @ApiOperation(value = "手机号是否已被注册", httpMethod = "POST", position = 1, response = Response.class)
//    public String isPhoneExist(
//            @ApiParam(required = true, name = "phone", value = "用户手机号")
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
//    @ApiOperation(value = "设置支付密码", httpMethod = "POST", position = 1, response = Response.class)
//    public String setPayPassword(
//            @ApiParam(required = true, name = "userId", value = "用户id")
//            @RequestParam(value = "userId") Long userId,
//            @ApiParam(required = true, name = "payPassword", value = "支付密码，MD5之后的值")
//            @RequestParam(value = "payPassword") String payPassword,
//            @ApiParam(required = true, name = "userType", value = "用户类型：C主播；P玩家")
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
//    @ApiOperation(value = "验证旧支付密码", httpMethod = "POST", position = 1, response = Response.class)
//    public String varifyPayPassword(
//            @ApiParam(required = true, name = "userId", value = "用户id")
//            @RequestParam(value = "userId") Long userId,
//            @ApiParam(required = true, name = "oldPayPassword", value = "旧密码")
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
//    @ApiOperation(value = "增加用户房卡", httpMethod = "POST", position = 1, response = Response.class)
//    public String increaseJewel(
//            @ApiParam(required = true, name = "userId", value = "用户id")
//            @RequestParam(value = "userId") Long userId,
//            @ApiParam(required = true, name = "amount", value = "增加的房卡数量，减房卡传负值")
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
//    @ApiOperation(value = "查找用户", httpMethod = "POST", position = 1, response = Response.class)
//    public String findUser(
//            @ApiParam(required = true, name = "condition", value = "查询条件")
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
//    @ApiOperation(value = "查询token", httpMethod = "POST", position = 1, response = Response.class)
//    public String queryToken(
//            @ApiParam(required = true, name = "phone", value = "用户手机")
//            @RequestParam(value = "phone") String phone,
//            @ApiParam(required = true, name = "oldToken", value = "失效token")
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
//    @ApiOperation(value = "购买月卡", position = 1, response = Response.class)
//    public String buyMonthCard(
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(value = "userId", required = true) Long userId,
//            @ApiParam(required = true, name = "cardType", value = "月卡类型，红卡0，蓝卡1")
//            @RequestParam(value = "cardType", required = true) Integer cardType,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "游戏自动签到", position = 1, response = Response.class)
//    public String gameSignIn(
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(value = "userId", required = true) Long userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "游戏自动签到", position = 1, response = Response.class)
//    public String isGameSignIn(
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(value = "userId", required = true) Long userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "领取破产补助", position = 1, response = Response.class)
//    public String getAllowance(
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(value = "userId", required = true) Long userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "是否有月卡", position = 1, response = Response.class)
//    public String hasMonthCard(
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(value = "userId", required = true) Long userId,
//            @ApiParam(required = true, name = "cardType", value = "月卡类型，红卡0，蓝卡1")
//            @RequestParam(value = "cardType", required = true) Integer cardType,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//    @ApiOperation(value = "是否首充", position = 1, response = Response.class)
//    public String isFirstCharged(
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(value = "userId", required = true) Long userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
