package com.j.joker.controller.game;

import com.alibaba.fastjson.JSON;
import com.j.joker.core.util.ConfigUtil;
import com.j.joker.cache.controller.BaseCacheController;
import com.j.joker.cache.model.CacheGameActivity;
import com.j.joker.constants.Constants;
import com.j.joker.mapper.TActivityMapper;
import com.j.joker.mapper.TFreeGameTotalMapper;
import com.j.joker.mapper.TUserMapper;
import com.j.joker.model.TFreeGameResult;
import com.j.joker.model.TFreeGameRound;
import com.j.joker.model.TVersion;
import com.j.joker.service.common.GameService;
import com.j.joker.service.common.UserService;
import com.j.joker.service.game.FreeGameService;
import com.j.joker.utils.CommonUtil;
import com.j.joker.utils.InfServerException;
import com.j.joker.utils.OSSUtil;
import com.j.joker.vo.response.Response;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.Parameter;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Created by ceeuoo on 8/19/2016.
 */
@Tag(name = "游戏组局相关接口")
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
//	@Operation(summary = "上传组局单场记录接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String uploadFreeGameRound(
//			@Parameter(required = true, name = "activityId", description = "组局id") @RequestParam(value = "activityId") Long activityId,
//			@Parameter(required = true, name = "content", description = "内容") @RequestParam(value = "content") String content,
//			@Parameter(required = true, name = "level", description = "游戏level") @RequestParam(value = "level") Integer level,
//			@Parameter(required = true, name = "index", description = "当前盘数index") @RequestParam(value = "index") Integer index,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@Operation(summary = "上传组局结果接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String uploadFreeGameResult(
//			@Parameter(required = true, name = "activityId", description = "组局id") @RequestParam(value = "activityId") Long activityId,
//			@Parameter(required = true, name = "content", description = "内容") @RequestParam(value = "content") String content,
//			@Parameter(required = true, name = "level", description = "游戏level") @RequestParam(value = "level") Integer level,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@Operation(summary = "上传配牌结果接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String uploadConfigCard(
//			@Parameter(required = true, name = "invitationCode", description = "邀请码") @RequestParam(value = "invitationCode") String invitationCode,
//			@Parameter(required = true, name = "content", description = "内容") @RequestParam(value = "content") String content,
//			@Parameter(required = true, name = "location", description = "位置") @RequestParam(value = "location") Integer location,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	@Operation(summary = "查询组局单场记录接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String queryFreeGameRound(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
			@Parameter(required = true, name = "activityId", description = "组局id") @RequestParam(value = "activityId") Long activityId,
			@Parameter(required = true, name = "roundIndex", description = "盘index") @RequestParam(value = "roundIndex") Integer roundIndex,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	//@Operation(summary = "查询组局结果接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	//public String queryFreeGameResult(
	//		@Parameter(required = true, name = "activityId", description = "组局id") @RequestParam(value = "activityId") Long activityId,
	//		@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@Operation(summary = "查询游戏版本接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String queryFreeGameVersion(
//			@Parameter(required = false, name = "gameId", description = "游戏id") @RequestParam(required = false,value = "gameId") Long gameId,
//			@Parameter(required = false, name = "invitationCode", description = "邀请码") @RequestParam(required = false,value = "invitationCode") String invitationCode,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	//@Operation(summary = "查询某个组局所有盘", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	//public String querRoundsByActivityId(
	//		@Parameter(required = true, name = "activityId", description = "组局id") @RequestParam(value = "activityId") Long activityId,
	//		@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	//@Operation(summary = "创建组局综合", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	//public String createGroupGame(
	//		@Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
	//		@Parameter(required = true, name = "gameId", description = "游戏ID") @RequestParam(value = "gameId") String gameId,
	//		@Parameter(required = true, name = "name", description = "组局名称") @RequestParam(value = "name") String name,
	//		@Parameter(required = true, name = "level", description = "level") @RequestParam(value = "level") Integer level,
	//		@Parameter(required = true, name = "round", description = "round") @RequestParam(value = "round") Integer round,
	//		@Parameter(required = true, name = "invitationCode", description = "邀请码") @RequestParam(value = "invitationCode") String invitationCode,
	//		@Parameter(required = false, name = "activityId", description = "活动ID") @RequestParam(required = false, value = "activityId") String activityId,
	//		@Parameter(required = true, name = "json", description = "json") @RequestParam(value = "json") String json,
	//		@Parameter(required = false, name = "discription", description = "discription") @RequestParam(required = false, value = "discription") String discription,
	//		@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	//@Operation(summary = "创建组局", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	//public String createFreeGame(
	//		@Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
	//		@Parameter(required = true, name = "gameId", description = "游戏ID") @RequestParam(value = "gameId") String gameId,
	//		@Parameter(required = true, name = "name", description = "组局名称") @RequestParam(value = "name") String name,
	//		@Parameter(required = true, name = "level", description = "level") @RequestParam(value = "level") Integer level,
	//		@Parameter(required = true, name = "round", description = "round") @RequestParam(value = "round") Integer round,
	//		@Parameter(required = true, name = "json", description = "json") @RequestParam(value = "json") String json,
	//		@Parameter(required = false, name = "discription", description = "discription") @RequestParam(required = false, value = "discription") String discription,
	//		@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
	//		HttpServletRequest request) {
	//	Response response = new Response();
	//	try {
	//		TUser player = userMapper.findById(Long.parseLong(userId));
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
	@Operation(summary = "代开组局", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String createFreeGameByOthers(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
			@Parameter(required = true, name = "gameId", description = "游戏ID") @RequestParam(value = "gameId") String gameId,
			@Parameter(required = true, name = "name", description = "组局名称") @RequestParam(value = "name") String name,
			@Parameter(required = true, name = "level", description = "level") @RequestParam(value = "level") Integer level,
			@Parameter(required = true, name = "round", description = "round") @RequestParam(value = "round") Integer round,
			@Parameter(name = "others", description = " 0 : 代开  1 : 自己开") @RequestParam(value = "others") Integer others,
			@Parameter(name = "baseChip", description = "底注,由前段发送给java,再发送给c++") @RequestParam(value = "baseChip") Integer baseChip,
			@Parameter(required = true, name = "json", description = "json") @RequestParam(value = "json") String json,
			@Parameter(required = false, name = "groupId", description = "由某个联盟创建的") @RequestParam(required = false,value = "groupId") Integer groupId,
			@Parameter(required = false, name = "password", description = "password") @RequestParam(required = false,value = "password") String password,
			@Parameter(required = false, name = "discription2Server", description = "discription2Server") @RequestParam(required = false, value = "discription2Server") String discription2Server,
			@Parameter(required = false, name = "discription", description = "discription") @RequestParam(required = false, value = "discription") String discription,
			@Parameter(required = false, name = "configId", description = "configId") @RequestParam(required = false, value = "configId") Integer configId,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	@Operation(summary = "代开组局", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String A2IcreateFreeGame(
			@Parameter(required = true, name = "clubId", description = "clubId") @RequestParam(value = "clubId") Integer clubId,
			@Parameter(required = true, name = "level", description = "level") @RequestParam(value = "level", required = true) String level,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	@Operation(summary = "续开组局", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String extendFreeGameByOthers(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
			@Parameter(required = true, name = "activityId", description = "组局ID") @RequestParam(value = "activityId") Long activityId,

			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@Operation(summary = "批量创建组局", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String createFreeGameByRobot(
//			@Parameter(required = true, name = "userId", description = "用户ID") @RequestParam(value = "userId") String userId,
//			@Parameter(required = true, name = "gameId", description = "游戏ID") @RequestParam(value = "gameId") String gameId,
//			@Parameter(required = true, name = "name", description = "组局名称") @RequestParam(value = "name") String name,
//			@Parameter(required = true, name = "level", description = "level") @RequestParam(value = "level") Integer level,
//			@Parameter(required = true, name = "round", description = "round") @RequestParam(value = "round") Integer round,
//			@Parameter(name = "others", description = " 0 : 代开  1 : 自己开") @RequestParam(value = "others") Integer others,
//			@Parameter(name = "baseChip", description = "底注,由前段发送给java,再发送给c++") @RequestParam(value = "baseChip") Integer baseChip,
//			@Parameter(required = true, name = "json", description = "json") @RequestParam(value = "json") String json,
//			@Parameter(required = false, name = "groupId", description = "由某个联盟创建的") @RequestParam(required = false,value = "groupId") Integer groupId,
//			@Parameter(required = false, name = "discription2Server", description = "discription2Server") @RequestParam(required = false, value = "discription2Server") String discription2Server,
//			@Parameter(required = false, name = "discription", description = "discription") @RequestParam(required = false, value = "discription") String discription,
//			@Parameter(required = false, name = "times", description = "times") @RequestParam(required = true, value = "times") Integer times,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@Operation(summary = "通过level查询游戏名字", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String queryGameNameByLevel(
//			@Parameter(required = false, name = "level", description = "level") @RequestParam(required = false, value = "level") String level,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	//@Operation(summary = "查询用户所有组局", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	//public String queryActivitiesByUserId(
	//		@Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") Long userId,
	//		@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	@Operation(summary = "查询某个用户的房卡的战绩记录", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String queryGoldActivitiesByUserId(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Long XYUid,
			@Parameter(required = true, name = "currentPage", description = "当前页") @RequestParam(value = "currentPage") String currentPage,
			@Parameter(required = false, name = "pageSize", description = "每页显示数,可以不穿,默认为10") @RequestParam(required = false,value = "pageSize") String pageSize,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	@Operation(summary = "查询某个用户的房卡的战绩记录,通过level", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String queryGoldActivitiesByUserIdAndLevel(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Long XYUid,
			@Parameter(required = true, name = "level", description = "level") @RequestParam(value = "level") Long level,
			@Parameter(required = true, name = "currentPage", description = "当前页") @RequestParam(value = "currentPage") String currentPage,
			@Parameter(required = false, name = "pageSize", description = "每页显示数,可以不穿,默认为10") @RequestParam(required = false,value = "pageSize") String pageSize,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	@Operation(summary = "查询某个用户的组局的战绩记录", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String queryActivitiesResult(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
			@Parameter(required = false, name = "searchId", description = "searchId") @RequestParam(value = "searchId", required = false) Integer searchId,
			@Parameter(required = false, name = "groupId", description = "groupId") @RequestParam(value = "groupId",required = false) Integer groupId,
			@Parameter(required = false, name = "type", description = "2 : 积分场组局 3 : 房卡场") @RequestParam(value = "type",required = false) Integer type,
			@Parameter(required = false, name = "level", description = "level") @RequestParam(value = "level",required = false) Integer level,
			@Parameter(required = false, name = "currentPage", description = "当前页") @RequestParam(value = "currentPage",required = false,defaultValue = "1") Integer currentPage,
			@Parameter(required = false, name = "pageSize", description = "每页显示数,可以不穿,默认为10") @RequestParam(required = false,value = "pageSize",defaultValue = "10") Integer pageSize,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	@Operation(summary = "查询某个用户的房卡场的组局的战绩记录", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String queryCardActivitiesByUserId(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Long XYUid,
			@Parameter(required = true, name = "currentPage", description = "当前页") @RequestParam(value = "currentPage") String currentPage,
			@Parameter(required = false, name = "pageSize", description = "每页显示数,可以不穿,默认为10") @RequestParam(required = false,value = "pageSize") String pageSize,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	@Operation(summary = "通过组局ID查询组局里面的具体回合数", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String queryCardActivities2RoundByUserId(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Long XYUid,
			@Parameter(required = false, name = "activityId", description = "activityId") @RequestParam(value = "activityId", required = false) Long activityId,
			@Parameter(required = false, name = "inviteCode", description = "inviteCode, 优先使用房间号查找战绩") @RequestParam(value = "inviteCode", required = false) String inviteCode,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@Operation(summary = "查询用户所有创建的组局", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String queryActivitiesByOwner(
//			@Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") Long userId,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	@Operation(summary = "查询组局状态", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	public String queryGroupGameStatus(
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
			@Parameter(required = true, name = "activityId", description = "组局id") @RequestParam(value = "activityId") Long activityId,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@Operation(summary = "开房人解散组局", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String closeGroupGameByOwner(
//			@Parameter(required = true, name = "inviteCode", description = "邀请码") @RequestParam(value = "inviteCode") String inviteCode,
//			@Parameter(required = true, name = "activityId", description = "组局id") @RequestParam(value = "activityId") Long activityId,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@Operation(summary = "查询用户所创建的房间", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String queryGroupGameByOwner(
//			@Parameter(required = true, name = "userId", description = "userId") @RequestParam(value = "userId") Long userId,
//			@Parameter(required = true, name = "roomType", description = "roomType  1:") @RequestParam(value = "roomType") Integer roomType,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@Operation(summary = "清除组局状态", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String cleanGroupGameStatus(
//			@Parameter(required = true, name = "inviteCode", description = "邀请码") @RequestParam(value = "inviteCode") String inviteCode,
//			@Parameter(required = true, name = "activityId", description = "组局id") @RequestParam(value = "activityId") Long activityId,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@Operation(summary = "根据游戏清除组局", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String cleanGroupGameByLevel(
//			@Parameter(required = true, name = "level", description = "level") @RequestParam(value = "level") int level,
//			@Parameter(required = true, name = "chain", description = "chain") @RequestParam(value = "chain") String chain,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@Operation(summary = "清除所有组局", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String cleanAllGroupGame(
//			@Parameter(required = true, name = "chain", description = "chain") @RequestParam(value = "chain") String chain,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@Operation(summary = "清除所有待关闭组局", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String cleanWaitCloseGroupGame(
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	//@Operation(summary = "查询总排行榜", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	//public String queryTotalGroupRank(
	//		@Parameter(required = true, name = "userId", description = "userid") @RequestParam(value = "userId") Long userId,
	//		@Parameter(required = true, name = "rankcount", description = "前几名") @RequestParam(value = "rankcount") Long rankcount,
	//		@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
	//		HttpServletRequest request) {
	//	Response response = new Response();
	//	try {
	//		TUser user = userMapper.findById(userId);
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
//	@Operation(summary = "查询总排行榜", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
//	public String queryTotalGroupRank(
//			@Parameter(required = true, name = "userId", description = "userid") @RequestParam(value = "userId") Long userId,
//			@Parameter(required = true, name = "rankcount", description = "前几名") @RequestParam(value = "rankcount") Long rankcount,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
	//@Operation(summary = "查询某个周期内的排行榜", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
	//public String querySingleResult(
	//		@Parameter(required = true, name = "userId", description = "userId") @RequestParam(value = "userId") Long userId,
	//		@Parameter(required = true, name = "rankcount", description = "前几名") @RequestParam(value = "rankcount") Long rankcount,
	//		@Parameter(required = true, name = "startTime", description = "开始时间") @RequestParam(value = "startTime") String startTime,
	//		@Parameter(required = true, name = "endTime", description = "结束时间") @RequestParam(value = "endTime") String endTime,
	//		@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
	//		HttpServletRequest request) {
	//	Response response = new Response();
	//	try {
	//		TUser user = userMapper.findById(userId);
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
