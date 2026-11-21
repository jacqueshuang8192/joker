//package com.hbi.controller.compere;
//
//import java.sql.SQLException;
//import java.text.DateFormat;
//import java.text.SimpleDateFormat;
//import java.util.Date;
//import java.util.List;
//
//import javax.servlet.http.HttpServletRequest;
//
//import com.hbi.model.*;
//import com.hbi.service.inviteCodeGen.InviteCodeGen;
//import org.apache.commons.lang.StringUtils;
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.beans.propertyeditors.CustomDateEditor;
//import org.springframework.stereotype.Controller;
//import org.springframework.web.bind.ServletRequestDataBinder;
//import org.springframework.web.bind.annotation.InitBinder;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RequestMethod;
//import org.springframework.web.bind.annotation.RequestParam;
//import org.springframework.web.bind.annotation.ResponseBody;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.core.controller.BaseController;
//import com.core.util.ConfigUtil;
//import com.hbi.cache.model.CacheCompereProfile;
//import com.hbi.cache.model.CachePlayerListProfile;
//import com.hbi.constants.Constants;
//import com.hbi.service.common.UserGoodsService;
//import com.hbi.service.common.UserService;
//import com.hbi.service.compere.CompereService;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.hbi.vo.response.base.BaseResultVo;
//import com.hbi.vo.response.user.AccountVo;
//import com.hbi.vo.response.user.LevelVo;
//import com.hbi.vo.response.user.ListVo;
//import com.hbi.vo.response.user.TaskListVo;
//import com.hbi.vo.response.user.UserGoodsPresentDetail;
//import com.wordnik.swagger.annotations.Api;
//import com.wordnik.swagger.annotations.ApiOperation;
//import com.wordnik.swagger.annotations.ApiParam;
//
///**
// * 主播控制器
// * @author yrou
// *
// */
//
//@Api(basePath = "/", value = "主播相关接口",position=1)
//@Controller
//public class CompereController extends BaseController {
//    private static final Log log = LogFactory.getLog(CompereController.class);
//
//    @Autowired
//    private CompereService compereService;
//    @Autowired
//    private UserService userService;
//    @Autowired
//	private UserGoodsService userGoodsService;
//    @Autowired
//    private InviteCodeGen codeGen;
//
//    @InitBinder
//    protected void initBinder(HttpServletRequest request,
//            ServletRequestDataBinder binder) throws Exception {
//            DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
//            CustomDateEditor editor = new CustomDateEditor(df, false);
//            binder.registerCustomEditor(Date.class, editor);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "compereRegister", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "主播注册", httpMethod = "POST", position = 2, response = Response.class, notes = "主播注册")
//    public String compereRegister(
//            @ApiParam(required = true, name = "phone", value = "手机号")
//            @RequestParam(value = "phone") String phone,
//            @ApiParam(required = true, name = "password", value = "密码，MD5加密之后的密码")
//            @RequestParam(value = "password") String password,
//            @ApiParam(required = false, name = "photo", value = "头像，url")
//            @RequestParam(value = "photo") String photo,
//            @ApiParam(name = "roomPhoto", value = "房间图片，url")
//            @RequestParam(required = true, value = "roomPhoto") String roomPhoto,
//            @ApiParam(name = "livePhoto", value = "直播间图片，url")
//            @RequestParam(required = true, value = "livePhoto") String livePhoto,
//            @ApiParam(required = true, name = "nickname", value = "昵称")
//            @RequestParam(value = "nickname") String nickname,
//            @ApiParam(required = true, name = "sex", value = "性别：0保密，1男，2女")
//            @RequestParam(value = "sex") String sex,
//            @ApiParam(required = true, name = "provinceId", value = "省")
//            @RequestParam(value = "provinceId", required = false) Long provinceId,
//            @ApiParam(required = true, name = "cityId", value = "市")
//            @RequestParam(value = "cityId", required = false) Long cityId,
//            @ApiParam(required = true, name = "townId", value = "区")
//            @RequestParam(value = "townId", required = false) Long townId,
//            @ApiParam(required = true, name = "code", value = "短信验证码")
//            @RequestParam(value = "code") String code,
//            @ApiParam(required = true, name = "invitationCode", value = "邀请码")
//            @RequestParam(value = "invitationCode") String invitationCode,
//            HttpServletRequest request) {
//    	Response response = new Response();
//        try {
//			int minutes = Integer.parseInt(ConfigUtil.get("sms.effectiveTime"));
//			boolean isValid = userService.isCodeValid(phone, code, minutes);
//			if (!isValid) {
//                response.setReturnCode(Constants.RETURN_CODE_CHECKCODE_INVALID);
//				response.setError("验证码错误！");
//			    return JSONObject.toJSONString(response);
//			}
//
//            String result = "";
////                    easeMobService.registerOnEaseMob(phone, password.toUpperCase(), nickname);
//            if (!result.equalsIgnoreCase(Constants.RETURN_CODE_SUCCESS) && result.indexOf("duplicate") == -1) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "注册失败，请稍后再试");
//            }
//
//			TCompere compere = new TCompere();
//			compere.setProvinceId(provinceId);
//			compere.setCityId(cityId);
//			compere.setTownId(townId);
//			compere.setLevel(1L);
//			compere.setExpiricValue(0);
//			compere.setPlayerNum(0L);
//			compere.setExtractIncome(0L);
//			compere.setSharedProfit(0L);
//			compere.setCaptureStatus(Constants.CAPTURE_FREE);
//
//			TUser user = new TUser();
//			user.setPhone(phone);
////			user.setPassword(EncryptUtils.encodeMD5String(password));
//			user.setPassword(password);
//			user.setNickName(nickname);
//			user.setType(Constants.USER_TYPE_C);
//			user.setGender(sex);
//			user.setSmallIcon(photo);
//            user.setRoomPhoto(roomPhoto);
//            user.setAccount(phone);
//            user.setLivePhoto(livePhoto);
//			user.setGrade(0F);
//	        user.setDatingNum(0);
//			user.setCreateDate(new Date());
//			user.setState(Constants.VALID);
//			user.setDeprecated(Constants.USER_NOT_DEPRECATED);
//			compereService.register(compere, user, invitationCode);
//			if(!result.equalsIgnoreCase(Constants.RETURN_CODE_SUCCESS)) {
//			    response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			    response.setData(result);
//			} else {
//				response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			}
//			return JSONObject.toJSONString(response);
//		} catch (InfServerException ee) {
//            log.error("主播注册：", ee);
//            response.setError(ee.getErrorMsg());
//            response.setReturnCode(ee.getErrorCode());
//            return JSON.toJSONString(response);
//        } catch (SQLException e) {
//            log.error("主播注册：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError("注册插入数据库失败");
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("主播注册：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
//
//    @ResponseBody
//	@RequestMapping(value = "compereUser/getUserInfo", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "获取个人资料", position = 1, response = Response.class, notes = "获取个人资料")
//	public String getUserInfo(
//			@ApiParam(required = true, name = "userId", value = "用户名,唯一") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//    		Response response = new Response();
//		try {
//			CacheCompereProfile compereDetail = compereService.getCompereInfoById(userId);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(compereDetail);
//		} catch (Exception e) {
//            log.error("获取个人资料：", e);
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
//    @RequestMapping(value = "compereUser/getUserInfo4GameServer", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "游戏服务器获取个人资料", httpMethod = "POST", position = 1, response = Response.class, notes = "获取个人资料")
//    public String getUserInfo4GameServer(
//            @ApiParam(required = true, name = "userId", value = "用户名,唯一") @RequestParam(value = "userId") String userId,
//            HttpServletRequest request) {
//            Response response = new Response();
//        try {
//            GameServerAuthInfo compereDetail = compereService.getCompereInfo4GameServer(userId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(compereDetail);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("游戏服务器获取个人资料：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//            return JSON.toJSONString(response);
//        }
//    }
//
//	@ResponseBody
//	@RequestMapping(value = "compereUser/modifyUserInfo", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "修改个人资料", position = 1, response = Response.class, notes = "修改个人资料")
//	public String modifyUserInfo(
//			@ApiParam(name = "userId", value = "用户名,唯一", required = true) @RequestParam(value = "userId") String userId,
//			@ApiParam(name = "photo", value = "图像", required = false) @RequestParam(value = "photo", required = false) String photo,
//			@ApiParam(name = "roomPhoto", value = "房间图片，url") @RequestParam(required = false, value = "roomPhoto") String roomPhoto,
//            @ApiParam(name = "livePhoto", value = "直播间图片，url") @RequestParam(required = false, value = "livePhoto") String livePhoto,
//			@ApiParam(name = "nickName", value = "昵称", required = false) @RequestParam(value = "nickName", required = false) String nickName,
//			@ApiParam(name = "name", value = "名称", required = false) @RequestParam(value = "name", required = false) String name,
//			@ApiParam(name = "birthday", value = "生日", required = false) @RequestParam(value = "birthday", required = false) String birthday,
//			@ApiParam(name = "provinceId", value = "省份", required = false) @RequestParam(value = "provinceId", required = false) String provinceId,
//			@ApiParam(name = "cityId", value = "城市", required = false) @RequestParam(value = "cityId", required = false) String cityId,
//			@ApiParam(name = "townId", value = "区", required = false) @RequestParam(value = "townId", required = false) String townId,
//			@ApiParam(name = "sign", value = "个性签名", required = false) @RequestParam(value = "sign", required = false) String sign,
//			@ApiParam(name = "gender", value = "性别", required = false) @RequestParam(value = "gender", required = false) String gender,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			TCompere compere = compereService.getCompereById(userId);
//			String oldCity = compere.getCityId().toString();
//			TUser user = compere.getUser();
//			if (user != null) {
//				if (StringUtils.isNotBlank(photo)) {
//					user.setSmallIcon(photo);
//				}
//				if (StringUtils.isNotBlank(roomPhoto)) {
//				    user.setRoomPhoto(roomPhoto);
//				}
//				if (StringUtils.isNotBlank(livePhoto)) {
//				    user.setLivePhoto(livePhoto);
//				}
//				if (StringUtils.isNotBlank(nickName)) {
//					user.setNickName(nickName);
//				}
//				if (StringUtils.isNotBlank(name)) {
//					user.setName(name);
//				}
//
//				if (StringUtils.isNotBlank(birthday)) {
//					user.setBirthday(CommonUtil.dateParse(birthday, "yyyy-MM-dd"));
//				}
//				if (StringUtils.isNotBlank(sign)) {
//					user.setSign(sign);
//				}
//                if (StringUtils.isNotBlank(gender)) {
//                    user.setGender(gender);
//                }
//
//				compere.setUser(user);
////				if (StringUtils.isNotBlank(provinceId)) {
////					compere.setProvinceId(Long.parseLong(provinceId));
////				}
////				if (StringUtils.isNotBlank(cityId)) {
////					compere.setCityId(Long.parseLong(cityId));
////				}
////				if (StringUtils.isNotBlank(townId)) {
////					compere.setTownId(Long.parseLong(townId));
////				}
//				compereService.updateCompere(compere, oldCity);
//
//				response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			} else {
//				throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到相关账号");
//			}
//
//		} catch (Exception e) {
//            log.error("修改个人资料：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//	}
//
//
////    @ResponseBody
////    @RequestMapping(value = "compereUser/getCompereByCity", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "按城市获取主播列表", httpMethod = "POST", response = ListVo.class, notes = "获取主播信息")
////    public String getCompereByCity(
////            @ApiParam(required = true, name = "cityId", value = "城市ID")
////            @RequestParam(value = "cityId") String cityId,
////            HttpServletRequest request)
////    {
////        ListVo vo = new ListVo();
////        try {
////            //先拿Redis
////            List<CompereVo> compereList = compereService.getCompereListByCity(cityId);
////            vo.setList(compereList);
////            vo.setCount(compereList.size());
////            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSON.toJSONString(vo);
////        } catch (Exception e) {
////            log.error(CommonUtil.buildErrorLog(e));
////            String returnCode = e instanceof InfServerException ? ((InfServerException) e).getErrorCode()
////                    : Constants.SYSTEM_ERROR;
////            vo.setReturnCode(returnCode);
////            return JSON.toJSONString(vo);
////        }
////    }
//
//    @ResponseBody
//    @RequestMapping(value = "compereUser/getCompereByStatus", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "按状态获取主播列表", httpMethod = "POST", response = ListVo.class, notes = "获取主播信息")
//    public String getCompereByStatus(
//            @ApiParam(required = true, name = "status", value = "主播状态")
//            @RequestParam(value = "status") String status,
//            HttpServletRequest request)
//    {
//        ListVo vo = new ListVo();
//        try {
//            //先拿Redis
//            List<CompereVo> compereList = compereService.getCompereListByStatus(status);
//            vo.setList(compereList);
//            vo.setCount(compereList.size());
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(vo);
//        } catch (Exception e) {
//            log.error("按状态获取主播列表：", e);
//            String returnCode = e instanceof InfServerException ? ((InfServerException) e).getErrorCode()
//                    : Constants.SYSTEM_ERROR;
//            vo.setReturnCode(returnCode);
//            return JSON.toJSONString(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "compereUser/queryComperesNearby", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查看附近主播", httpMethod = "POST", position = 1, response = ListVo.class, notes = "查看附近主播")
//    public String queryComperesNearby(
//            @ApiParam(required = true, name = "longitude", value = "经度")
//            @RequestParam(value = "longitude") double longitude,
//            @ApiParam(required = true, name = "latitude", value = "纬度")
//            @RequestParam(value = "latitude") double latitude,
//            HttpServletRequest request) {
//        try {
//            ListVo vo = new ListVo();
//            List<CompereVo> compereVos = compereService.queryComperesNearby(longitude, latitude);
//            if(compereVos == null) {
//                return JSON.toJSONString(new BaseResultVo(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, null));
//            }
//            vo.setList(compereVos);
//            vo.setCount(compereVos.size());
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(vo);
//        } catch (Exception e) {
//            log.error("查看附近主播：", e);
//            return JSON.toJSONString(new BaseResultVo(e.getLocalizedMessage(), null));
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "compereUser/queryAgent", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询主播代理", position = 1, response = Response.class, notes = "查询主播代理")
//    public String queryAgent(
//            @ApiParam(required = true, name = "compereId", value = "主播id")
//            @RequestParam(value = "compereId") Long compereId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            String agentName = compereService.queryAgent(compereId);
//            response.setData(agentName);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("查询主播代理：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "compereUser/sendJewel", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "赠送房卡", position = 1, response = Response.class, notes = "赠送房卡")
//    public String sendJewel(
//            @ApiParam(required = true, name = "compereId", value = "主播id")
//            @RequestParam(value = "compereId") long compereId,
//            @ApiParam(required = true, name = "jewelAmount", value = "房卡数量")
//            @RequestParam(value = "jewelAmount") int jewelAmount,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//    	Response response = new Response();
//        try {
//            AccountVo vo = compereService.sendJewel(compereId, jewelAmount);
//            response.setData(vo);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//            log.error("赠送房卡：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "compereUser/querySendJewelHistory", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询赠送房卡记录", position = 1, response = Response.class, notes = "查询赠送房卡记录")
//    public String querySendJewelHistory(
//            @ApiParam(required = true, name = "compereId", value = "主播id")
//            @RequestParam(value = "compereId") Long compereId,
//            @ApiParam(required = true, name = "startDate", value = "查询起始日期")
//            @RequestParam(value = "startDate") String startDate,
//            @ApiParam(required = true, name = "endDate", value = "查询结束日期")
//            @RequestParam(value = "endDate") String endDate,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//    	Response response = new Response();
//        try {
//            List<SendJewelHistoryVo> voList = userGoodsService.findSendJewelHistoryByConditions(compereId, startDate, endDate);
//            response.setData(voList);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("查询赠送房卡记录：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "compereUser/setAsRoomManager", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "设置管理员", httpMethod = "POST", response = Response.class, notes = "设置管理员")
//    public String setAsRoomManager(
//            @ApiParam(required = true, name = "compereId", value = "主播ID") @RequestParam(value = "compereId") String compereId,
//            @ApiParam(required = true, name = "playerId", value = "玩家ID") @RequestParam(value = "playerId") String playerId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            compereService.setAdmin(compereId, playerId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("设置管理员：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "compereUser/removeRoomManager", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "取消管理员", httpMethod = "POST", response = Response.class, notes = "取消管理员")
//    public String removeRoomManager(
//            @ApiParam(required = true, name = "compereId", value = "主播ID") @RequestParam(value = "compereId") String compereId,
//            @ApiParam(required = true, name = "playerId", value = "玩家ID") @RequestParam(value = "playerId") String playerId,
//            HttpServletRequest request) {
//    	Response response = new Response();
//        try {
//            //先拿Redis
//            compereService.cancelAdmin(compereId, playerId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("取消管理员：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "compereUser/myFans", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "我的粉丝", response = Response.class, notes = "我的粉丝")
//    public String myFans(
//            @ApiParam(required = true, name = "userId", value = "主播ID") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//
//        try {
//        	response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        	response.setData(compereService.queryMyFans(userId));
//        } catch (Exception e) {
//            log.error("我的粉丝：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//    @ResponseBody
//   	@RequestMapping(value = "compereUser/queryReceiveGiftDetail", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//   	@ApiOperation(value = "查询收到礼物详情", httpMethod = "POST", position = 1, response = Response.class, notes = "查询收到礼物详情个人资料")
//   	public String queryReceiveGiftDetail(
//   			@ApiParam(required = true, name = "compereId", value = "主播ID") @RequestParam(value = "compereId") String compereId,
//   			HttpServletRequest request) {
//       		Response response = new Response();
//   		try {
//   			List<TUserGoods> userGoods = compereService.queryGiftsByCompereId(compereId);
//   			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//   			response.setData(userGoods);
//   			return JSON.toJSONString(response);
//   		} catch (Exception e) {
//            log.error("查询收到礼物详情：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//   	}
//
//    @ResponseBody
//   	@RequestMapping(value = "compereUser/queryContributionRank", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//   	@ApiOperation(value = "查询贡献排行榜", position = 1, response = Response.class, notes = "查询贡献排行榜")
//   	public String queryContributionRank(
//   			@ApiParam(required = true, name = "compereId", value = "主播ID") @RequestParam(value = "compereId") String compereId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//   			HttpServletRequest request) {
//       		Response response = new Response();
//   		try {
//   			List<CachePlayerListProfile> players = compereService.queryContributionRank(compereId);
//   			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//   			response.setData(players);
//   		} catch (Exception e) {
//            log.error("查询贡献排行榜：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//   	}
//
//    @ResponseBody
//   	@RequestMapping(value = "compereUser/queryMonthlyIncome", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//   	@ApiOperation(value = "查询每月收入", httpMethod = "POST", position = 1, response = Response.class, notes = "查询每月收入")
//   	public String queryMonthlyIncome(
//   			@ApiParam(required = true, name = "compereId", value = "主播ID") @RequestParam(value = "compereId") String compereId,
//   			@ApiParam(required = true, name = "month", value = "月份(yyyy-MM)") @RequestParam(value = "month") String month,
//   			HttpServletRequest request) {
//       		Response response = new Response();
//   		try {
//   			List<TUserGoodsPresentRecord> presentRecords = compereService.queryGiftsForMonth(Long.parseLong(compereId), month);
//   			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//   			response.setData(presentRecords);
//   			return JSON.toJSONString(response);
//   		} catch (Exception e) {
//            log.error("查询每月收入：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//   	}
//
//    @ResponseBody
//   	@RequestMapping(value = "compereUser/queryTodayIncome", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//   	@ApiOperation(value = "查询当天收入", httpMethod = "POST", position = 1, response = Response.class, notes = "查询当天收入")
//   	public String queryTodayIncome(
//   			@ApiParam(required = true, name = "compereId", value = "主播ID") @RequestParam(value = "compereId") String compereId,
//   			HttpServletRequest request) {
//       		Response response = new Response();
//   		try {
//   			List<TUserGoodsPresentRecord> presentRecords = compereService.queryTodayGifts(Long.parseLong(compereId));
//   			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//   			response.setData(presentRecords);
//   			return JSON.toJSONString(response);
//   		} catch (Exception e) {
//            log.error("查询当天收入：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//   	}
//
//    @ResponseBody
//   	@RequestMapping(value = "compereUser/queryMonthlyIncomeDetail", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//   	@ApiOperation(value = "查询当月收入详情", httpMethod = "POST", position = 1, response = Response.class, notes = "查询当月收入详情")
//   	public String queryMonthlyIncomeDetail(
//   			@ApiParam(required = true, name = "compereId", value = "主播ID") @RequestParam(value = "compereId") String compereId,
//   			@ApiParam(required = true, name = "month", value = "月份(yyyy-MM)") @RequestParam(value = "month") String month,
//   			@ApiParam(required = true, name = "categoryId", value = "分类ID") @RequestParam(value = "categoryId") String categoryId,
//   			HttpServletRequest request) {
//       		Response response = new Response();
//   		try {
//   			List<UserGoodsPresentDetail> goodsPresentDetails = compereService.queryMonthlyCategoryDetail(Long.parseLong(compereId), month, Long.parseLong(categoryId));
//   			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//   			response.setData(goodsPresentDetails);
//   			return JSON.toJSONString(response);
//   		} catch (Exception e) {
//            log.error("查询当月收入详情：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//   	}
//
//    @ResponseBody
//   	@RequestMapping(value = "compereUser/queryTodayIncomeDetail", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//   	@ApiOperation(value = "查询当天收入详情", httpMethod = "POST", position = 1, response = Response.class, notes = "查询当天收入详情")
//   	public String queryTodayIncomeDetail(
//   			@ApiParam(required = true, name = "compereId", value = "主播ID") @RequestParam(value = "compereId") String compereId,
//   			@ApiParam(required = true, name = "categoryId", value = "分类ID") @RequestParam(value = "categoryId") String categoryId,
//   			HttpServletRequest request) {
//       		Response response = new Response();
//   		try {
//   			List<UserGoodsPresentDetail> goodsPresentDetails = compereService.queryTodayCategoryDetail(Long.parseLong(compereId), Long.parseLong(categoryId));
//   			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//   			response.setData(goodsPresentDetails);
//   			return JSON.toJSONString(response);
//   		} catch (Exception e) {
//            log.error("查询当天收入详情：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//   	}
//
//    @ResponseBody
//    @RequestMapping(value = "compereUser/queryMonthlyTotalIncome", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询每月所有收入", position = 1, response = Response.class, notes = "查询每月所有收入")
//    public String queryMonthlyTotalIncome(
//            @ApiParam(required = true, name = "compereId", value = "主播ID") @RequestParam(value = "compereId") String compereId,
//            @ApiParam(required = true, name = "month", value = "月份(yyyy-MM)") @RequestParam(value = "month") String month,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<TCompereIncome> compereIncomes = compereService.queryCompereImcomesForMonth(Long.parseLong(compereId), month);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(compereIncomes);
//        } catch (Exception e) {
//            log.error("查询每月所有收入：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "compereUser/receiveTaskReward", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "领取任务奖励", response = TaskListVo.class, notes = "领取任务奖励")
//    public String receiveTaskReward(
//            @ApiParam(required = true, name = "userId", value = "主播id") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "taskId", value = "任务id") @RequestParam(value = "taskId") String taskId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            LevelVo vo = compereService.receiveTaskReward(Long.parseLong(userId), Long.parseLong(taskId));
//            response.setData(vo);
//        } catch (Exception e) {
//            log.error("领取任务奖励：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//    @ResponseBody
//	@RequestMapping(value = "compereUser/queryCompereDetail", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//	@ApiOperation(value = "获取主播详情(JSONP)", httpMethod = "GET", position = 2, response = Response.class, notes = "获取主播详情(JSONP)")
//	public String queryCompereDetail (
//			@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			CacheCompereProfile compereDetail = compereService.getCompereInfoById(userId);
//			response.setData(compereDetail);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//            log.error("获取主播详情(JSONP)：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		return CommonUtil.buildJSONPResponse(Constants.QUERY_COMPERE_DETAIL, response);
//	}
//
//    @ResponseBody
//    @RequestMapping(value = "compereUser/queryJewelStatement", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询主播对账单", position = 2, response = Response.class)
//    public String joinSociety (
//            @ApiParam(required = true, name = "userId", value = "用户id,唯一")
//            @RequestParam(value = "userId") Long userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response= new Response();
//        try {
//            List<ZJewelStatement> result = compereService.queryJewelStatement(userId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(result);
//        } catch (InfServerException ie) {
//            log.error("查询主播对账单：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("查询主播对账单：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "compereUser/test", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "测试 方法", httpMethod = "POST", response = TaskListVo.class)
//    public String test(
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            response.setData(codeGen.getCode());
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("测试：", e);
//            response.setError(Constants.RETURN_CODE_FAIL);
//            return JSON.toJSONString(response);
//        }
//
//    }
//}
