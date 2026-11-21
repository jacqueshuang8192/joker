package com.hbi.controller.game;

import com.alibaba.fastjson.JSON;
import com.core.util.ConfigUtil;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.cache.model.CacheGameActivity;
import com.hbi.constants.Constants;
import com.hbi.mapper.TActivityMapper;
import com.hbi.mapper.TFreeGameTotalMapper;
import com.hbi.mapper.TUserMapper;
import com.hbi.model.TFreeGameResult;
import com.hbi.model.TFreeGameRound;
import com.hbi.model.TVersion;
import com.hbi.service.common.GameService;
import com.hbi.service.common.UserService;
import com.hbi.service.game.FreeGameService;
import com.hbi.utils.CommonUtil;
import com.hbi.utils.InfServerException;
import com.hbi.utils.OSSUtil;
import com.hbi.vo.response.Response;
import com.wordnik.swagger.annotations.Api;
import com.wordnik.swagger.annotations.ApiOperation;
import com.wordnik.swagger.annotations.ApiParam;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Created by ceeuoo on 8/19/2016.
 */
@Api(basePath = "/", value = "游戏组局相关接口", position = 1)
@Controller
@RequestMapping(value = "/freeGame")
public class FreeGameController {
	private static Logger log = Logger.getLogger(FreeGameController.class);

	@Autowired
	private FreeGameService freeGameService;
	@Autowired
    private UserService userService;
	
//	@ResponseBody
//	@RequestMapping(value = "uploadFreeGameRound", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "上传组局单场记录接口", position = 2, response = Response.class)
//	public String uploadFreeGameRound(
//			@ApiParam(required = true, name = "activityId", value = "组局id") @RequestParam(value = "activityId") Long activityId,
//			@ApiParam(required = true, name = "content", value = "内容") @RequestParam(value = "content") String content,
//			@ApiParam(required = true, name = "level", value = "游戏level") @RequestParam(value = "level") Integer level,
//			@ApiParam(required = true, name = "index", value = "当前盘数index") @RequestParam(value = "index") Integer index,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			log.info(content);
//			content = CommonUtil.filterAscii(content);
//
//			String replayUrl = CommonUtil.dateFormat(new Date(), "yyyyMM") + "/" + activityId + "_" + level + "_"
//					+ index + "_" + CommonUtil.dateFormat(new Date(), "ddHHmmSSSS");
//
//			freeGameService.uploadFreeGameRound(activityId, content.replaceAll("\\\\", ""), level, index,replayUrl);
//
//			OSSUtil.simpleUpload(content, replayUrl, ConfigUtil.get("oss.bucketName.replay"));
//
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (InfServerException ie) {
//			log.error("上传组局单场记录接口：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("上传组局单场记录接口：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			response.setError(e.getMessage());
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "uploadFreeGameResult", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "上传组局结果接口", position = 2, response = Response.class)
//	public String uploadFreeGameResult(
//			@ApiParam(required = true, name = "activityId", value = "组局id") @RequestParam(value = "activityId") Long activityId,
//			@ApiParam(required = true, name = "content", value = "内容") @RequestParam(value = "content") String content,
//			@ApiParam(required = true, name = "level", value = "游戏level") @RequestParam(value = "level") Integer level,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			freeGameService.uploadFreeGameResult(activityId, content, level);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (InfServerException ie) {
//			log.error("上传组局结果接口：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("上传组局结果接口：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			response.setError(e.getMessage());
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "uploadConfigCard", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "上传配牌结果接口", position = 2, response = Response.class)
//	public String uploadConfigCard(
//			@ApiParam(required = true, name = "invitationCode", value = "邀请码") @RequestParam(value = "invitationCode") String invitationCode,
//			@ApiParam(required = true, name = "content", value = "内容") @RequestParam(value = "content") String content,
//			@ApiParam(required = true, name = "location", value = "位置") @RequestParam(value = "location") Integer location,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			freeGameService.uploadConfigCard(invitationCode, content, location);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (InfServerException ie) {
//			log.error("上传配牌结果接口：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("上传配牌结果接口：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			response.setError(e.getMessage());
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

	@ResponseBody
	@RequestMapping(value = "queryFreeGameRound", method = { RequestMethod.POST,
			RequestMethod.GET }, produces = "application/json; charset=utf-8")
	@ApiOperation(value = "查询组局单场记录接口", position = 2, response = Response.class)
	public String queryFreeGameRound(
			@ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") String XYUid,
			@ApiParam(required = true, name = "activityId", value = "组局id") @RequestParam(value = "activityId") Long activityId,
			@ApiParam(required = true, name = "roundIndex", value = "盘index") @RequestParam(value = "roundIndex") Integer roundIndex,
			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
			TFreeGameRound round = freeGameService.queryFreeGameRound(activityId, roundIndex);
			// TODO 需要增加链接防盗链功能，见阿里OSS API
			round.setReplayUrl(FreeGameController.getSignedReplayUrl(round.getReplayUrl()));
			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
			response.setData(round);
		} catch (InfServerException ie) {
			log.error("查询组局单场记录接口：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		} catch (Exception e) {
			log.error("查询组局单场记录接口：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
			response.setError(e.getMessage());
		}
		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}

	//@ResponseBody
	//@RequestMapping(value = "queryFreeGameResult", method = { RequestMethod.POST,
	//		RequestMethod.GET }, produces = "application/json; charset=utf-8")
	//@ApiOperation(value = "查询组局结果接口", position = 2, response = Response.class)
	//public String queryFreeGameResult(
	//		@ApiParam(required = true, name = "activityId", value = "组局id") @RequestParam(value = "activityId") Long activityId,
	//		@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
	//		HttpServletRequest request) {
	//	Response response = new Response();
	//	try {
	//		TFreeGameResult result = freeGameService.queryFreeGameResult(activityId);
	//		response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
	//		response.setData(result);
	//	} catch (InfServerException ie) {
	//		log.error("查询组局结果接口：", ie);
	//		response.setReturnCode(ie.getErrorCode());
	//		response.setError(ie.getErrorMsg());
	//	} catch (Exception e) {
	//		log.error("查询组局结果接口：", e);
	//		response.setReturnCode(Constants.RETURN_CODE_FAIL);
	//		response.setError(e.getMessage());
	//	}
	//	if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
	//		String method = Thread.currentThread().getStackTrace()[1].getMethodName();
	//		return CommonUtil.buildJSONPResponse(method, response);
	//	}
	//	return JSON.toJSONString(response);
	//}
	
	//
//	@ResponseBody
//	@RequestMapping(value = "queryFreeGameVersion", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "查询游戏版本接口", position = 2, response = Response.class)
//	public String queryFreeGameVersion(
//			@ApiParam(required = false, name = "gameId", value = "游戏id") @RequestParam(required = false,value = "gameId") Long gameId,
//			@ApiParam(required = false, name = "invitationCode", value = "邀请码") @RequestParam(required = false,value = "invitationCode") String invitationCode,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			TVersion version = freeGameService.queryFreeGameVersion(gameId,invitationCode);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(version);
//		} catch (InfServerException ie) {
//			log.error("查询组局结果接口：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("查询组局结果接口：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			response.setError(e.getMessage());
//		}
//
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

	//@ResponseBody
	//@RequestMapping(value = "querRoundsByActivityId", method = { RequestMethod.POST,
	//		RequestMethod.GET }, produces = "application/json; charset=utf-8")
	//@ApiOperation(value = "查询某个组局所有盘", position = 2, response = Response.class)
	//public String querRoundsByActivityId(
	//		@ApiParam(required = true, name = "activityId", value = "组局id") @RequestParam(value = "activityId") Long activityId,
	//		@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
	//		HttpServletRequest request) {
	//	Response response = new Response();
	//	try {
	//		List<TFreeGameRound> result = freeGameService.querRoundsByActivityId(activityId);
	//		response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
	//		response.setData(result);
	//	} catch (InfServerException ie) {
	//		log.error("查询组局结果接口：", ie);
	//		response.setReturnCode(ie.getErrorCode());
	//		response.setError(ie.getErrorMsg());
	//	} catch (Exception e) {
	//		log.error("查询组局结果接口：", e);
	//		response.setReturnCode(Constants.RETURN_CODE_FAIL);
	//		response.setError(e.getMessage());
	//	}
	//	if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
	//		String method = Thread.currentThread().getStackTrace()[1].getMethodName();
	//		return CommonUtil.buildJSONPResponse(method, response);
	//	}
	//	return JSON.toJSONString(response);
	//}

	//@ResponseBody
	//@RequestMapping(value = "createGroupGame", method = { RequestMethod.POST,
	//		RequestMethod.GET }, produces = "application/json; charset=utf-8")
	//@ApiOperation(value = "创建组局综合", position = 2, response = Response.class)
	//public String createGroupGame(
	//		@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
	//		@ApiParam(required = true, name = "gameId", value = "游戏ID") @RequestParam(value = "gameId") String gameId,
	//		@ApiParam(required = true, name = "name", value = "组局名称") @RequestParam(value = "name") String name,
	//		@ApiParam(required = true, name = "level", value = "level") @RequestParam(value = "level") Integer level,
	//		@ApiParam(required = true, name = "round", value = "round") @RequestParam(value = "round") Integer round,
	//		@ApiParam(required = true, name = "invitationCode", value = "邀请码") @RequestParam(value = "invitationCode") String invitationCode,
	//		@ApiParam(required = false, name = "activityId", value = "活动ID") @RequestParam(required = false, value = "activityId") String activityId,
	//		@ApiParam(required = true, name = "json", value = "json") @RequestParam(value = "json") String json,
	//		@ApiParam(required = false, name = "discription", value = "discription") @RequestParam(required = false, value = "discription") String discription,
	//		@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
	//		HttpServletRequest request) {
	//	Response response = new Response();
	//	try {
	//		JSONObject object = new JSONObject();
	//		List<FreeGameActivityInfo> reganizeHistory=userService.viewReganizeGames(userId);
     //   	UserOnlineGame userOnlineGame = gameService.queryUserOnlineGame(userId);
     //   	Object createFreeGame=freeGameService.createFreeGame(userId, gameId, level, name, round, json, discription);
     //   	Object joinFreeGame= userService.joinFreeGame(userId, invitationCode, activityId, level);
     //   	object.put("reganizeHistory", reganizeHistory);
     //   	object.put("userOnlineGame", userOnlineGame);
     //   	object.put("createFreeGame", createFreeGame);
     //   	object.put("joinFreeGame", joinFreeGame);
     //   	response.setData(object);
     //   	response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
	//	} catch (InfServerException ie) {
	//		log.error("创建组局：", ie);
	//		response.setReturnCode(ie.getErrorCode());
	//		response.setError(ie.getErrorMsg());
	//	} catch (Exception e) {
	//		log.error("创建组局：", e);
	//		response.setReturnCode(Constants.RETURN_CODE_FAIL);
	//		response.setError(e.getMessage());
	//	}
	//	if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
	//		String method = Thread.currentThread().getStackTrace()[1].getMethodName();
	//		return CommonUtil.buildJSONPResponse(method, response);
	//	}
	//	return JSON.toJSONString(response);
	//}
	
	//@ResponseBody
	//@RequestMapping(value = "createFreeGame", method = { RequestMethod.POST,
	//		RequestMethod.GET }, produces = "application/json; charset=utf-8")
	//@ApiOperation(value = "创建组局", position = 2, response = Response.class)
	//public String createFreeGame(
	//		@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
	//		@ApiParam(required = true, name = "gameId", value = "游戏ID") @RequestParam(value = "gameId") String gameId,
	//		@ApiParam(required = true, name = "name", value = "组局名称") @RequestParam(value = "name") String name,
	//		@ApiParam(required = true, name = "level", value = "level") @RequestParam(value = "level") Integer level,
	//		@ApiParam(required = true, name = "round", value = "round") @RequestParam(value = "round") Integer round,
	//		@ApiParam(required = true, name = "json", value = "json") @RequestParam(value = "json") String json,
	//		@ApiParam(required = false, name = "discription", value = "discription") @RequestParam(required = false, value = "discription") String discription,
	//		@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
	//		HttpServletRequest request) {
	//	Response response = new Response();
	//	try {
	//		TUser player = userMapper.selectByPrimaryKey(Long.parseLong(userId));
	//		String status = player.getState();
	//		if ( status == null || status.equals("0")) {
	//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
	//			response.setError("您好,您的账号已经被封停了,请联系您的代理!!");
	//			return JSON.toJSONString(response);
	//		}
	//		response.setData(freeGameService.createFreeGame(userId, gameId, level, name, round, json, discription));
     //   	response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
	//	} catch (InfServerException ie) {
	//		log.error("创建组局：", ie);
	//		response.setReturnCode(ie.getErrorCode());
	//		response.setError(ie.getErrorMsg());
	//	} catch (Exception e) {
	//		log.error("创建组局：", e);
	//		response.setReturnCode(Constants.RETURN_CODE_FAIL);
	//		response.setError(e.getMessage());
	//	}
	//	if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
	//		String method = Thread.currentThread().getStackTrace()[1].getMethodName();
	//		return CommonUtil.buildJSONPResponse(method, response);
	//	}
	//	return JSON.toJSONString(response);
	//}
	
	@ResponseBody
	@RequestMapping(value = "createFreeGameByOthers", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
	@ApiOperation(value = "代开组局", position = 2, response = Response.class)
	public String createFreeGameByOthers(
			@ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") String XYUid,
			@ApiParam(required = true, name = "gameId", value = "游戏ID") @RequestParam(value = "gameId") String gameId,
			@ApiParam(required = true, name = "name", value = "组局名称") @RequestParam(value = "name") String name,
			@ApiParam(required = true, name = "level", value = "level") @RequestParam(value = "level") Integer level,
			@ApiParam(required = true, name = "round", value = "round") @RequestParam(value = "round") Integer round,
			@ApiParam(name = "others", value = " 0 : 代开  1 : 自己开") @RequestParam(value = "others") Integer others,
			@ApiParam(name = "baseChip", value = "底注,由前段发送给java,再发送给c++") @RequestParam(value = "baseChip") Integer baseChip,
			@ApiParam(required = true, name = "json", value = "json") @RequestParam(value = "json") String json,
			@ApiParam(required = false, name = "groupId", value = "由某个联盟创建的") @RequestParam(required = false,value = "groupId") Integer groupId,
			@ApiParam(required = false, name = "password", value = "password") @RequestParam(required = false,value = "password") String password,
			@ApiParam(required = false, name = "discription2Server", value = "discription2Server") @RequestParam(required = false, value = "discription2Server") String discription2Server,
			@ApiParam(required = false, name = "discription", value = "discription") @RequestParam(required = false, value = "discription") String discription,
			@ApiParam(required = false, name = "configId", value = "configId") @RequestParam(required = false, value = "configId") Integer configId,
			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
			//判断用户的状态
			String status = userService.statusByUserId(XYUid);
			if ( status == null || status.equals("0")) {
				response.setReturnCode(Constants.RETURN_CODE_FAIL);
				response.setError("您好,您的账号已经被封停了,请联系您的代理!!");
				return JSON.toJSONString(response);
			}
			response.setData(freeGameService.createFreeGameByOthers(XYUid, gameId, level, name, round, json, discription,discription2Server,others,baseChip,groupId,password,configId,null));
			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
		} catch (InfServerException ie) {
			log.error("创建组局：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		} catch (Exception e) {
			log.error("创建组局：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
			response.setError(e.getMessage());
		}
		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}


	@ResponseBody
	@RequestMapping(value = "A2IcreateFreeGame", method = { RequestMethod.POST,
			RequestMethod.GET }, produces = "application/json; charset=utf-8")
	@ApiOperation(value = "代开组局", position = 2, response = Response.class)
	public String A2IcreateFreeGame(
			@ApiParam(required = true, name = "clubId", value = "clubId") @RequestParam(value = "clubId") Integer clubId,
			@ApiParam(required = true, name = "level", value = "level") @RequestParam(value = "level", required = true) String level,
			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {

			response.setData(freeGameService.A2IcreateFreeGame(clubId, level));
			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
		} catch (InfServerException ie) {
			log.error("创建组局：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		} catch (Exception e) {
			log.error("创建组局：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
			response.setError(e.getMessage());
		}
		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}

	@ResponseBody
	@RequestMapping(value = "extendFreeGameByOthers", method = { RequestMethod.POST,
			RequestMethod.GET }, produces = "application/json; charset=utf-8")
	@ApiOperation(value = "续开组局", position = 2, response = Response.class)
	public String extendFreeGameByOthers(
			@ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") String XYUid,
			@ApiParam(required = true, name = "activityId", value = "组局ID") @RequestParam(value = "activityId") Long activityId,

			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
			//判断用户的状态
			Map<String, String> gameResult = freeGameService.extendFreeGameByOthers(XYUid, activityId);
			Object o = userService.joinFreeGame(XYUid, gameResult.get("inviteCode") , gameResult.get("activityId"), null, null, 1);

			response.setData(o);
			response.setReturnCode("0");
		} catch (InfServerException ie) {
			log.error("创建组局：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		} catch (Exception e) {
			log.error("创建组局：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
			response.setError(e.getMessage());
		}
		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}


//	@ResponseBody
//	@RequestMapping(value = "createFreeGameByRobot", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "批量创建组局", position = 2, response = Response.class)
//	public String createFreeGameByRobot(
//			@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//			@ApiParam(required = true, name = "gameId", value = "游戏ID") @RequestParam(value = "gameId") String gameId,
//			@ApiParam(required = true, name = "name", value = "组局名称") @RequestParam(value = "name") String name,
//			@ApiParam(required = true, name = "level", value = "level") @RequestParam(value = "level") Integer level,
//			@ApiParam(required = true, name = "round", value = "round") @RequestParam(value = "round") Integer round,
//			@ApiParam(name = "others", value = " 0 : 代开  1 : 自己开") @RequestParam(value = "others") Integer others,
//			@ApiParam(name = "baseChip", value = "底注,由前段发送给java,再发送给c++") @RequestParam(value = "baseChip") Integer baseChip,
//			@ApiParam(required = true, name = "json", value = "json") @RequestParam(value = "json") String json,
//			@ApiParam(required = false, name = "groupId", value = "由某个联盟创建的") @RequestParam(required = false,value = "groupId") Integer groupId,
//			@ApiParam(required = false, name = "discription2Server", value = "discription2Server") @RequestParam(required = false, value = "discription2Server") String discription2Server,
//			@ApiParam(required = false, name = "discription", value = "discription") @RequestParam(required = false, value = "discription") String discription,
//			@ApiParam(required = false, name = "times", value = "times") @RequestParam(required = true, value = "times") Integer times,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			//判断用户的状态
//			for(int i = 0 ; i <	times ; i++) {
//				freeGameService.createFreeGameByOthers(userId, gameId, level, name, round, json, discription,discription2Server,others,baseChip,groupId,null,null);
//				Thread.sleep(20);
//			}
//			response.setData("创建成功");
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (InfServerException ie) {
//			log.error("创建组局：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("创建组局：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			response.setError(e.getMessage());
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

//	@ResponseBody
//	@RequestMapping(value = "queryGameNameByLevel", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "通过level查询游戏名字", position = 2, response = Response.class)
//	public String queryGameNameByLevel(
//			@ApiParam(required = false, name = "level", value = "level") @RequestParam(required = false, value = "level") String level,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(freeGameService.queryGameNameByLevel(level));
//		} catch (InfServerException ie) {
//			log.error("通过level查询游戏名字：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("通过level查询游戏名字：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			response.setError(e.getMessage());
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

	//@ResponseBody
	//@RequestMapping(value = "queryActivitiesByUserId", method = { RequestMethod.POST,
	//		RequestMethod.GET }, produces = "application/json; charset=utf-8")
	//@ApiOperation(value = "查询用户所有组局", position = 2, response = Response.class)
	//public String queryActivitiesByUserId(
	//		@ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") Long userId,
	//		@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
	//		HttpServletRequest request) {
	//	Response response = new Response();
	//	try {
	//		List<TFreeGameResult> result = freeGameService.queryActivitiesByUserId(userId);
	//		response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
	//		response.setData(result);
	//	} catch (InfServerException ie) {
	//		log.error("查询用户所有组局：", ie);
	//		response.setReturnCode(ie.getErrorCode());
	//		response.setError(ie.getErrorMsg());
	//	} catch (Exception e) {
	//		log.error("查询用户所有组局：", e);
	//		response.setReturnCode(Constants.RETURN_CODE_FAIL);
	//		response.setError(e.getMessage());
	//	}
	//	if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
	//		String method = Thread.currentThread().getStackTrace()[1].getMethodName();
	//		return CommonUtil.buildJSONPResponse(method, response);
	//	}
	//	return JSON.toJSONString(response);
	//}


	@ResponseBody
	@RequestMapping(value = "queryGoldActivitiesByUserId", method = { RequestMethod.POST,
			RequestMethod.GET }, produces = "application/json; charset=utf-8")
	@ApiOperation(value = "查询某个用户的房卡的战绩记录", position = 2, response = Response.class)
	public String queryGoldActivitiesByUserId(
			@ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") Long XYUid,
			@ApiParam(required = true, name = "currentPage", value = "当前页") @RequestParam(value = "currentPage") String currentPage,
			@ApiParam(required = false, name = "pageSize", value = "每页显示数,可以不穿,默认为10") @RequestParam(required = false,value = "pageSize") String pageSize,
			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
			List<TFreeGameRound> result = freeGameService.queryGoldActivitiesByUserId(XYUid,currentPage,pageSize);
			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
			response.setData(result);
		} catch (InfServerException ie) {
			log.error("查询某个用户的房卡的战绩记录：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		} catch (Exception e) {
			log.error("查询某个用户的房卡的战绩记录：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
			response.setError(e.getMessage());
		}
		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}

	@ResponseBody
	@RequestMapping(value = "queryGoldActivitiesByUserIdAndLevel", method = { RequestMethod.POST,
			RequestMethod.GET }, produces = "application/json; charset=utf-8")
	@ApiOperation(value = "查询某个用户的房卡的战绩记录,通过level", position = 2, response = Response.class)
	public String queryGoldActivitiesByUserIdAndLevel(
			@ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") Long XYUid,
			@ApiParam(required = true, name = "level", value = "level") @RequestParam(value = "level") Long level,
			@ApiParam(required = true, name = "currentPage", value = "当前页") @RequestParam(value = "currentPage") String currentPage,
			@ApiParam(required = false, name = "pageSize", value = "每页显示数,可以不穿,默认为10") @RequestParam(required = false,value = "pageSize") String pageSize,
			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
			List<TFreeGameRound> result = freeGameService.queryGoldActivitiesByUserIdAndLevel(XYUid,currentPage,pageSize,level );
			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
			response.setData(result);
		} catch (InfServerException ie) {
			log.error("查询某个用户的房卡的战绩记录：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		} catch (Exception e) {
			log.error("查询某个用户的房卡的战绩记录：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
			response.setError(e.getMessage());
		}
		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}


	@ResponseBody
	@RequestMapping(value = "queryActivitiesResult", method = { RequestMethod.POST,
			RequestMethod.GET }, produces = "application/json; charset=utf-8")
	@ApiOperation(value = "查询某个用户的组局的战绩记录", position = 2, response = Response.class)
	public String queryActivitiesResult(
			@ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
			@ApiParam(required = false, name = "searchId", value = "searchId") @RequestParam(value = "searchId", required = false) Integer searchId,
			@ApiParam(required = false, name = "groupId", value = "groupId") @RequestParam(value = "groupId",required = false) Integer groupId,
			@ApiParam(required = false, name = "type", value = "2 : 积分场组局 3 : 房卡场") @RequestParam(value = "type",required = false) Integer type,
			@ApiParam(required = false, name = "level", value = "level") @RequestParam(value = "level",required = false) Integer level,
			@ApiParam(required = false, name = "currentPage", value = "当前页") @RequestParam(value = "currentPage",required = false,defaultValue = "1") Integer currentPage,
			@ApiParam(required = false, name = "pageSize", value = "每页显示数,可以不穿,默认为10") @RequestParam(required = false,value = "pageSize",defaultValue = "10") Integer pageSize,
			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {

			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
			response.setData(freeGameService.queryActivitiesResult(XYUid,groupId,type,currentPage,pageSize,level, searchId));
		} catch (InfServerException ie) {
			log.error("查询某个用户的组局的战绩记录：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		} catch (Exception e) {
			log.error("查询某个用户的组局的战绩记录：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
			response.setError(e.getMessage());
		}
		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}


	@ResponseBody
	@RequestMapping(value = "queryCardActivitiesByUserId", method = { RequestMethod.POST,
			RequestMethod.GET }, produces = "application/json; charset=utf-8")
	@ApiOperation(value = "查询某个用户的房卡场的组局的战绩记录", position = 2, response = Response.class)
	public String queryCardActivitiesByUserId(
			@ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") Long XYUid,
			@ApiParam(required = true, name = "currentPage", value = "当前页") @RequestParam(value = "currentPage") String currentPage,
			@ApiParam(required = false, name = "pageSize", value = "每页显示数,可以不穿,默认为10") @RequestParam(required = false,value = "pageSize") String pageSize,
			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
			List<TFreeGameResult> result = freeGameService.queryCardActivitiesByUserId(XYUid,currentPage,pageSize);
			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
			response.setData(result);
		} catch (InfServerException ie) {
			log.error("查询某个用户的房卡的战绩记录：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		} catch (Exception e) {
			log.error("查询某个用户的房卡的战绩记录：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
			response.setError(e.getMessage());
		}
		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}

	@ResponseBody
	@RequestMapping(value = "queryCardActivities2RoundByUserId", method = { RequestMethod.POST,
			RequestMethod.GET }, produces = "application/json; charset=utf-8")
	@ApiOperation(value = "通过组局ID查询组局里面的具体回合数", position = 2, response = Response.class)
	public String queryCardActivities2RoundByUserId(
			@ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") Long XYUid,
			@ApiParam(required = false, name = "activityId", value = "activityId") @RequestParam(value = "activityId", required = false) Long activityId,
			@ApiParam(required = false, name = "inviteCode", value = "inviteCode, 优先使用房间号查找战绩") @RequestParam(value = "inviteCode", required = false) String inviteCode,
			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
			List<TFreeGameRound> result = freeGameService.queryCardActivities2RoundByUserI(XYUid, activityId, inviteCode);
			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
			response.setData(result);
		} catch (InfServerException ie) {
			log.error("查询某个用户的房卡的战绩记录：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		} catch (Exception e) {
			log.error("查询某个用户的房卡的战绩记录：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
			response.setError(e.getMessage());
		}
		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}
	
//	@ResponseBody
//	@RequestMapping(value = "queryActivitiesByOwner", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "查询用户所有创建的组局", position = 2, response = Response.class)
//	public String queryActivitiesByOwner(
//			@ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") Long userId,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			List<TFreeGameResult> result = freeGameService.queryActivitiesByOwner(userId);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(result);
//		} catch (InfServerException ie) {
//			log.error("查询用户所有组局：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("查询用户所有组局：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			response.setError(e.getMessage());
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

	@ResponseBody
	@RequestMapping(value = "queryGroupGameStatus", method = { RequestMethod.POST,
			RequestMethod.GET }, produces = "application/json; charset=utf-8")
	@ApiOperation(value = "查询组局状态", position = 2, response = Response.class)
	public String queryGroupGameStatus(
			@ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") String XYUid,
			@ApiParam(required = true, name = "activityId", value = "组局id") @RequestParam(value = "activityId") Long activityId,
			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
			Integer result = freeGameService.queryGroupGameStatus(activityId);
			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
			response.setData(result);
		} catch (InfServerException ie) {
			log.error("查询组局状态：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		} catch (Exception e) {
			log.error("查询组局状态：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
		}
		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}
	
//	@ResponseBody
//	@RequestMapping(value = "closeGroupGameByOwner", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "开房人解散组局", position = 2, response = Response.class)
//	public String closeGroupGameByOwner(
//			@ApiParam(required = true, name = "inviteCode", value = "邀请码") @RequestParam(value = "inviteCode") String inviteCode,
//			@ApiParam(required = true, name = "activityId", value = "组局id") @RequestParam(value = "activityId") Long activityId,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			freeGameService.closeGroupGameByOwner(inviteCode, activityId);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (InfServerException ie) {
//			log.error("查询组局状态：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("查询组局状态：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}
	
//	@ResponseBody
//	@RequestMapping(value = "queryGroupGameByOwner", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "查询用户所创建的房间", position = 2, response = Response.class)
//	public String queryGroupGameByOwner(
//			@ApiParam(required = true, name = "userId", value = "userId") @RequestParam(value = "userId") Long userId,
//			@ApiParam(required = true, name = "roomType", value = "roomType  1:") @RequestParam(value = "roomType") Integer roomType,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(freeGameService.queryGroupGameByOwner(userId,roomType));
//		} catch (InfServerException ie) {
//			log.error("查询组局状态：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("查询组局状态：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

//	@ResponseBody
//	@RequestMapping(value = "cleanGroupGameStatus", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "清除组局状态", position = 2, response = Response.class)
//	public String cleanGroupGameStatus(
//			@ApiParam(required = true, name = "inviteCode", value = "邀请码") @RequestParam(value = "inviteCode") String inviteCode,
//			@ApiParam(required = true, name = "activityId", value = "组局id") @RequestParam(value = "activityId") Long activityId,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			freeGameService.cleanGroupGameStatus(inviteCode, activityId);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (InfServerException ie) {
//			log.error("查询组局状态：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("查询组局状态：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}
	
//	@ResponseBody
//	@RequestMapping(value = "cleanGroupGameByLevel", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "根据游戏清除组局", position = 2, response = Response.class)
//	public String cleanGroupGameByLevel(
//			@ApiParam(required = true, name = "level", value = "level") @RequestParam(value = "level") int level,
//			@ApiParam(required = true, name = "chain", value = "chain") @RequestParam(value = "chain") String chain,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			freeGameService.cleanGroupGameByLevel(level, chain);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("清除出错：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

//	@ResponseBody
//	@RequestMapping(value = "cleanAllGroupGame", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "清除所有组局", position = 2, response = Response.class)
//	public String cleanAllGroupGame(
//			@ApiParam(required = true, name = "chain", value = "chain") @RequestParam(value = "chain") String chain,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			freeGameService.cleanAllGroupGame(chain);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("清除出错：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}
	
//	@ResponseBody
//	@RequestMapping(value = "cleanWaitCloseGroupGame", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "清除所有待关闭组局", position = 2, response = Response.class)
//	public String cleanWaitCloseGroupGame(
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			freeGameService.cleanWaitCloseGroupGame();
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("清除出错：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

	//@ResponseBody
	//@RequestMapping(value = "queryTotalGroupRank", method = { RequestMethod.POST,
	//		RequestMethod.GET }, produces = "application/json; charset=utf-8")
	//@ApiOperation(value = "查询总排行榜", position = 2, response = Response.class)
	//public String queryTotalGroupRank(
	//		@ApiParam(required = true, name = "userId", value = "userid") @RequestParam(value = "userId") Long userId,
	//		@ApiParam(required = true, name = "rankcount", value = "前几名") @RequestParam(value = "rankcount") Long rankcount,
	//		@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
	//		HttpServletRequest request) {
	//	Response response = new Response();
	//	try {
	//		TUser user = userMapper.selectByPrimaryKey(userId);
	//		if (user != null) {
	//			Long self1 = freeGameTotalMapper.queryTotalByUserId(userId);
	//			if (self1 != null) {
	//				List<TFreeGameTotal> result = freeGameService.queryTotalGroupRank(rankcount);
	//				if (self1 > 0) {
	//					TFreeGameTotal self = freeGameService.queryTotalGroupGeRenRank(userId);
	//					GameRankVo vo = new GameRankVo();
	//					vo.setRankList(result);
	//					vo.setSelf(self);
	//					response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
	//					response.setData(vo);
	//				} else {
	//
	//					TFreeGameTotal self = freeGameService.queryTotalGroupGeRenRank2(userId);
	//					GameRankVo vo = new GameRankVo();
	//					vo.setRankList(result);
	//					vo.setSelf(self);
	//					response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
	//					response.setData(vo);
	//				}
	//			}else{
	//				TFreeGameTotal total1 = new TFreeGameTotal();
	//				total1.setUserId(userId);
	//				total1.setWin(0);
	//				total1.setScore(0);
	//				total1.setDraw(0);
	//				total1.setLose(0);
	//				total1.setTotal(0);
	//				freeGameTotalMapper.insert(total1);
	//				List<TFreeGameTotal> result = freeGameService.queryTotalGroupRank(rankcount);
	//				TFreeGameTotal self = freeGameService.queryTotalGroupGeRenRank2(userId);
	//
	//				GameRankVo vo = new GameRankVo();
	//				vo.setRankList(result);
	//				vo.setSelf(self);
	//				response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
	//				response.setData(vo);
	//			}
	//
	//		} else {
	//			throw new InfServerException(Constants.RETURN_CODE_FAIL, "该用户不存在");
	//		}
    //
	//	} catch (InfServerException ie) {
	//		log.error("查询总排行榜：", ie);
	//		response.setReturnCode(ie.getErrorCode());
	//		response.setError(ie.getErrorMsg());
	//	} catch (Exception e) {
	//		log.error("查询总排行榜：", e);
	//		response.setReturnCode(Constants.RETURN_CODE_FAIL);
	//	}
	//	if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
	//		String method = Thread.currentThread().getStackTrace()[1].getMethodName();
	//		return CommonUtil.buildJSONPResponse(method, response);
	//	}
	//	return JSON.toJSONString(response);
	//}

//	@ResponseBody
//	@RequestMapping(value = "queryTotalGroupRank", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "查询总排行榜", position = 2, response = Response.class)
//	public String queryTotalGroupRank(
//			@ApiParam(required = true, name = "userId", value = "userid") @RequestParam(value = "userId") Long userId,
//			@ApiParam(required = true, name = "rankcount", value = "前几名") @RequestParam(value = "rankcount") Long rankcount,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response=freeGameService.queryRedisTotalGroupBank(userId);
//		if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}
	
	//@ResponseBody
	//@RequestMapping(value = "querySingleResult", method = { RequestMethod.POST,
	//		RequestMethod.GET }, produces = "application/json; charset=utf-8")
	//@ApiOperation(value = "查询某个周期内的排行榜", position = 2, response = Response.class)
	//public String querySingleResult(
	//		@ApiParam(required = true, name = "userId", value = "userId") @RequestParam(value = "userId") Long userId,
	//		@ApiParam(required = true, name = "rankcount", value = "前几名") @RequestParam(value = "rankcount") Long rankcount,
	//		@ApiParam(required = true, name = "startTime", value = "开始时间") @RequestParam(value = "startTime") String startTime,
	//		@ApiParam(required = true, name = "endTime", value = "结束时间") @RequestParam(value = "endTime") String endTime,
	//		@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
	//		HttpServletRequest request) {
	//	Response response = new Response();
	//	try {
	//		TUser user = userMapper.selectByPrimaryKey(userId);
	//		if (user!=null) {
	//			Long self1 = freeGameTotalMapper.queryTotalByUserId(userId);
	//			List<TFreeGameSingleresult> result = freeGameService.querySingleResult(rankcount, startTime, endTime);
	//			if (self1>0) {
	//				TFreeGameSingleresult self = freeGameService.queryGeRenSingleResult(userId, startTime, endTime);
	//				GameSingleRankVo vo = new GameSingleRankVo();
	//				vo.setRankList(result);
	//				vo.setSelf(self);
	//				response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
	//				response.setData(vo);
	//			}else{
	//				TFreeGameSingleresult self = freeGameService.queryGeRenSingleResult2(userId, startTime, endTime);
	//				GameSingleRankVo vo = new GameSingleRankVo();
	//				vo.setRankList(result);
	//				vo.setSelf(self);
	//				response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
	//				response.setData(vo);
	//			}
	//		}
	//
	//
	//	} catch (InfServerException ie) {
	//		log.error("查询某个周期排行榜：", ie);
	//		response.setReturnCode(ie.getErrorCode());
	//		response.setError(ie.getErrorMsg());
	//	} catch (Exception e) {
	//		log.error("查询某个周期排行榜：", e);
	//		response.setReturnCode(Constants.RETURN_CODE_FAIL);
	//	}
	//	if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
	//		String method = Thread.currentThread().getStackTrace()[1].getMethodName();
	//		return CommonUtil.buildJSONPResponse(method, response);
	//	}
	//	return JSON.toJSONString(response);
	//}

	private static String getSignedReplayUrl(String genUrl) {
		return OSSUtil.getFullyHttpUrl(genUrl);
	}

//	private static String getRound() {
//		String content = "{\"gameTime\":\"2016-08-30 17:50\",\"activityId\":\"100\",\"roundId\":\"1\", \"userinfos\":[{\"uid\":\"414\",\"icon_url\":\"\",\"nick\":\"华宝\",\"gold\":\"2000\",\"sex\":\"1\",\"seat_id\":\"0\",\"score\":\"10\"},{\"uid\":\"414\",\"icon_url\":\"\",\"nick\":\"码农\",\"gold\":\"2000\",\"sex\":\"1\",\"seat_id\":\"0\",\"score\":\"10\"},{\"uid\":\"414\",\"icon_url\":\"\",\"nick\":\"海鱼\",\"gold\":\"2000\",\"sex\":\"1\",\"seat_id\":\"0\",\"score\":\"10\"},{\"uid\":\"414\",\"icon_url\":\"\",\"nick\":\"小磊\",\"gold\":\"2000\",\"sex\":\"1\",\"seat_id\":\"0\",\"score\":\"10\"}],\"replayInfo\":\"\"}";
//		return content;
//	}

	//public static void main(String[] args) {
	//	System.out.println(FreeGameController.getRound());
    //
	//	JSONObject jo = JSONObject.parseObject(getRound());
	//	JSONObject jo2 = new JSONObject();
	//	jo2.put("gameTime", jo.getString("gameTime"));
	//	jo2.put("activityId", jo.getString("activityId"));
	//	jo2.put("activityId", jo.getString("roundId"));
	//	jo2.put("userinfos", jo.getString("userinfos"));
	//	jo2.put("activityId", jo.getString("activityId"));
	//	String contentList = jo.getString("gameTime") + jo.getString("activityId") + jo.getString("roundId")
	//			+ jo.getString("userinfos") + jo.getString("activityId");
	//	System.out.println(contentList.replaceAll("\\\\", ""));
	//}
}
