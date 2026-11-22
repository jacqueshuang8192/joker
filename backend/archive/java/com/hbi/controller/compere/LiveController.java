//package com.hbi.controller.compere;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.core.controller.BaseController;
//import com.core.util.HttpUtil;
//import com.hbi.cache.model.CacheRoomListProfile;
//import com.hbi.cache.model.CacheRoomProfile;
//import com.hbi.constants.Constants;
//import com.hbi.model.*;
//import com.hbi.service.common.*;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.hbi.vo.response.room.BackgroundSong;
//import com.hbi.vo.response.room.ViewRoomPlayersVo;
//import com.wordnik.swagger.annotations.Api;
//import com.wordnik.swagger.annotations.ApiOperation;
//import com.wordnik.swagger.annotations.ApiParam;
//import org.apache.commons.lang.StringUtils;
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Controller;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RequestMethod;
//import org.springframework.web.bind.annotation.RequestParam;
//import org.springframework.web.bind.annotation.ResponseBody;
//
//import javax.servlet.http.HttpServletRequest;
//import java.util.ArrayList;
//import java.util.List;
//
///**
// * 主播控制器
// *
// * @author yrou
// *
// */
//
//@Api(basePath = "/", value = "主播直播相关接口", position = 1)
//@Controller
//public class LiveController extends BaseController {
//	private static final Log log = LogFactory.getLog(LiveController.class);
//
//	@Autowired
//	private LiveService liveService;
//
//	@Autowired
//	private GameService gameService;
//
//	@Autowired
//	private BaseDetailService baseDetailService;
//
//	@Autowired
//	private RoomService roomService;
//
//	@Autowired
//	private CaptureCompereService captureService;
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/createPasswordRoom", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "创建密码房", httpMethod = "POST", position = 2, response = Response.class, notes = "创建密码房")
//	public String createPasswordRoom(
//			@ApiParam(required = true, name = "compereId", value = "主播id") @RequestParam(value = "compereId") String compereId,
//			@ApiParam(required = false, name = "roomName", value = "房间名") @RequestParam(value = "roomName") String roomName,
//			@ApiParam(required = false, name = "roomPhoto", value = "房间封面") @RequestParam(value = "roomPhoto") String roomPhoto,
//			@ApiParam(required = false, name = "roomListPhoto", value = "房间封面") @RequestParam(value = "roomListPhoto") String roomListPhoto,
//			@ApiParam(required = false, name = "password", value = "密码") @RequestParam(value = "password", required = false) String password,
//			@ApiParam(required = true, name = "liveLastTime", value = "持续时间/小时，如3.5") @RequestParam(value = "liveLastTime", required = true) String liveLastTime,
//			@ApiParam(required = true, name = "liveType", value = "直播类型") @RequestParam(value = "liveType", required = true) String liveType,
//			@ApiParam(required = false, name = "liveActivityCode", value = "直播活动编码") @RequestParam(value = "liveActivityCode", required = false) String liveActivityCode,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			CacheRoomProfile vo = liveService.createRoom(compereId, roomName, roomPhoto, roomListPhoto, password, Float.parseFloat(liveLastTime), liveType, liveActivityCode);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(vo);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("创建密码房：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/startLive", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "开始直播", httpMethod = "POST", position = 2, response = Response.class, notes = "开始直播")
//	public String startLive(
//			@ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//			@ApiParam(required = true, name = "roomId", value = "房间id") @RequestParam(value = "roomId") String roomId,
//			@ApiParam(required = true, name = "liveId", value = "直播id") @RequestParam(value = "liveId") String liveId,
//			@ApiParam(required = true, name = "compereId", value = "主播id") @RequestParam(value = "compereId") String compereId,
//			@ApiParam(required = false, name = "resolution", value = "分辨率") @RequestParam(required = false,value = "resolution") String resolution,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			if(StringUtils.isBlank(resolution)) {
//				resolution = "3,4";
//			}
//			liveService.startLive(cityId, roomId, liveId, compereId, resolution);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("开始直播：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/viewLiveGames", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "获取主播游戏", httpMethod = "POST", position = 2, response = Response.class, notes = "获取主播游戏")
//	public String viewLiveGames(
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			List<TGame> games = gameService.viewLiveGames();
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(games);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("获取主播游戏：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/queryBackgroundSongs", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "获取音效", httpMethod = "POST", position = 2, response = Response.class, notes = "获取音效")
//	public String queryBackgroundSongs(
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			List<TBaseDetail> details = baseDetailService.queryBackgroundSongs();
//
//			List<BackgroundSong> songs = new ArrayList<BackgroundSong>();
//			for (TBaseDetail t : details) {
//				BackgroundSong song = new BackgroundSong();
//				song.setFileName(t.getDetail());
//				song.setPhoto(t.getName());
//				song.setSeconds(t.getRemark());
//				songs.add(song);
//			}
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(songs);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("获取音效：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/queryTheme", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "获取主题", httpMethod = "POST", position = 2, response = Response.class, notes = "获取主题")
//	public String queryTheme(
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//		    List<TRadioStationType> radioStationTypes = roomService.queryRadioStationTypes();
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(radioStationTypes);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("获取主题：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/openMicrophone", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "开麦", httpMethod = "POST", position = 2, response = Response.class, notes = "开麦")
//	public String openMicrophone(
//			@ApiParam(required = true, name = "roomId", value = "房间id") @RequestParam(value = "roomId") String roomId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			liveService.openMicrophone(roomId);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("开麦：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/resetMicrophone", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "放麦", httpMethod = "POST", position = 2, response = Response.class, notes = "放麦")
//	public String resetMicrophone(
//			@ApiParam(required = true, name = "roomId", value = "房间id") @RequestParam(value = "roomId") String roomId,
//			@ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") String userId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			liveService.resetMicrophone(roomId, userId);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("放麦：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/exitFm", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "退出电台", httpMethod = "POST", position = 2, response = Response.class, notes = "退出电台")
//	public String exitFm(
//			@ApiParam(required = true, name = "roomId", value = "房间id") @RequestParam(value = "roomId") String roomId,
//			@ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") String userId,
//			@ApiParam(required = true, name = "position", value = "位置") @RequestParam(value = "position") String position,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			liveService.exitFm(roomId, userId, position);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("退出电台：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/takebackMicrophone", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "收麦", httpMethod = "POST", position = 2, response = Response.class, notes = "收麦")
//	public String takebackMicrophone(
//			@ApiParam(required = true, name = "roomId", value = "房间id") @RequestParam(value = "roomId") String roomId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			liveService.takebackMicrophone(roomId);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("收麦：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/applyMicrophone", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "抢麦", httpMethod = "POST", position = 2, response = Response.class, notes = "抢麦")
//	public String applyMicrophone(
//			@ApiParam(required = true, name = "roomId", value = "房间id") @RequestParam(value = "roomId") String roomId,
//			@ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") String userId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			liveService.queueMicrophone(roomId, userId);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("抢麦：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/joinFm", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "加入电台", httpMethod = "POST", position = 2, response = Response.class, notes = "加入电台")
//	public String joinFm(
//			@ApiParam(required = true, name = "roomId", value = "房间id") @RequestParam(value = "roomId") String roomId,
//			@ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") String userId,
//			@ApiParam(required = true, name = "position", value = "位置") @RequestParam(value = "position") String position,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			liveService.joinFm(roomId, userId, position);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("加入电台：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/changeWaitingMicrophoneOrder", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "改麦", httpMethod = "POST", position = 2, response = Response.class, notes = "改麦")
//	public String changeWaitingMicrophoneOrder(
//			@ApiParam(required = true, name = "roomId", value = "房间id") @RequestParam(value = "roomId") String roomId,
//			@ApiParam(required = true, name = "playerId", value = "房间id") @RequestParam(value = "playerId") String playerId,
//			@ApiParam(required = true, name = "position", value = "位置") @RequestParam(value = "position") String position,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			liveService.changeWaitingMicrophoneOrder(roomId, playerId, position);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("改麦：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/removeFromWaitingMicrophone", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "移麦", httpMethod = "POST", position = 2, response = Response.class, notes = "移麦")
//	public String removeFromWaitingMicrophone(
//			@ApiParam(required = true, name = "roomId", value = "房间id") @RequestParam(value = "roomId") String roomId,
//			@ApiParam(required = true, name = "playerId", value = "玩家id") @RequestParam(value = "playerId") String playerId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			liveService.removeFromWaitingMicrophone(roomId, playerId);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("移麦：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/viewRoomPlayers", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "房间玩家列表", httpMethod = "POST", position = 2, response = Response.class, notes = "房间玩家列表")
//	public String viewRoomPlayers(
//			@ApiParam(required = true, name = "roomId", value = "房间id") @RequestParam(value = "roomId") String roomId,
//			@ApiParam(required = true, name = "compereId", value = "主播id") @RequestParam(value = "compereId") String compereId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			ViewRoomPlayersVo roomPlayers = new ViewRoomPlayersVo();
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			roomPlayers.setPlayers(liveService.viewRoomPlayers(roomId));
//			roomPlayers.setMicPlayers(liveService.viewMicphonePlayers(roomId));
//			roomPlayers.setFmPlayers(liveService.viewFmPlayers(roomId));
//			roomPlayers.setDefendPlayers(captureService.viewDefendPlayers(compereId));
//			response.setData(roomPlayers);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("房间玩家列表：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//    @RequestMapping(value = "compereUser/removeRoomPlayer", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "踢人", httpMethod = "POST", response = Response.class, notes = "踢人")
//    public String removeRoomPlayer(
//    		@ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            @ApiParam(required = true, name = "playerId", value = "玩家ID") @RequestParam(value = "playerId") String playerId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//        	roomService.removeMemberFromRoom(cityId, roomId, playerId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//			log.error("踢人：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "compereUser/closeLive", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "停止直播", httpMethod = "POST", response = Response.class, notes = "停止直播")
//    public String closeLive(
//    		@ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//        	roomService.endLive(cityId, roomId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//			log.error("停止直播：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "compereUser/closeRoom", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "关闭房间", httpMethod = "POST", response = Response.class, notes = "关闭房间")
//    public String closeRoom(
//    		@ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            @ApiParam(required = true, name = "compereId", value = "主播ID") @RequestParam(value = "compereId") String compereId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//			String chatRoomId = roomService.closeRoom(cityId, roomId, compereId);
////			easeMobService.closeRoomMessage(chatRoomId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//			log.error("关闭房间：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "compereUser/startLiveGame", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "开启视频游戏", httpMethod = "POST", response = Response.class, notes = "开始视频游戏")
//    public String startLiveGame(
//    		@ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            @ApiParam(required = true, name = "gameId", value = "游戏ID") @RequestParam(value = "gameId") String gameId,
//            @ApiParam(required = true, name = "gameName", value = "游戏名称") @RequestParam(value = "gameName") String gameName,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//        	roomService.startGame(cityId, roomId, gameId, gameName);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//			log.error("开启视频游戏：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "compereUser/startFm", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "开启电台", httpMethod = "POST", response = Response.class, notes = "开启电台")
//	public String startFm(
//    		@ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            @ApiParam(required = true, name = "topicId", value = "电台ID") @RequestParam(value = "topicId") String topicId,
//            @ApiParam(required = true, name = "topic", value = "电台主题") @RequestParam(value = "topic") String topic,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//        	roomService.startFm(cityId, roomId, topicId, topic);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//			log.error("开启电台：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "compereUser/closeLiveGame", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "关闭视频游戏", httpMethod = "POST", response = Response.class, notes = "关闭视频游戏")
//    public String closeLiveGame(
//    		@ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            HttpServletRequest request)  {
//        Response response = new Response();
//        try {
//        	roomService.closeGame(cityId, roomId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//			log.error("关闭视频游戏：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "compereUser/closeFm", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "关闭电台", httpMethod = "POST", response = Response.class, notes = "关闭电台")
//    public String closeFm(
//    		@ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            HttpServletRequest request)  {
//        Response response = new Response();
//        try {
//        	roomService.closeFm(cityId, roomId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//			log.error("关闭电台：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "compereLive/queryFmHintContent", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "获取电台主题内容", httpMethod = "POST", response = Response.class, notes = "获取电台主题内容")
//    public String startFm(
//            @ApiParam(required = true, name = "topicId", value = "电台主题ID") @RequestParam(value = "topicId") String topicId,
//            @ApiParam(required = true, name = "count", value = "数量") @RequestParam(value = "count") String count,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<TRadioStationContent> radioStationContents = roomService.queryFmHintContent(Long.parseLong(topicId), Integer.parseInt(count));
//            response.setData(radioStationContents);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//			log.error("获取电台主题内容：", e);
//             CommonUtil.BuildErrorResponse(e, response);
//             return JSON.toJSONString(response);
//        }
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "compereUser/viewPresentsInActivity", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询本次活动收到的礼物", httpMethod = "POST", response = Response.class, notes = "查询本次活动收到的礼物")
//    public String viewPresentsInActivity(
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            HttpServletRequest request) {
//		Response response = new Response();
//        try {
//        	response.setData(roomService.queryGiftForRoom(roomId));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//			log.error("查询本次活动收到的礼物：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "exitRoom", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "退出房间", httpMethod = "POST", response = Response.class, notes = "退出房间")
//    public String exitRoom(
//    		@ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//    		@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            HttpServletRequest request) {
//		Response response = new Response();
//        try {
//        	roomService.exitRoom(cityId, userId, roomId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//			log.error("退出房间：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "givePresent", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "赠送礼物", httpMethod = "POST", response = Response.class, notes = "赠送礼物")
//    public String givePresent(
//            @ApiParam(required = true, name = "giverId", value = "赠送人ID") @RequestParam(value = "giverId") String giverId,
//            @ApiParam(required = true, name = "goodsId", value = "物品ID") @RequestParam(value = "goodsId") String goodsId,
//            @ApiParam(required = true, name = "amount", value = "数量") @RequestParam(value = "amount") int amount,
//            @ApiParam(required = true, name = "receiverId", value = "接收人ID") @RequestParam(value = "receiverId") String receiverId,
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            @ApiParam(required = true, name = "currentCount", value = "该礼物当前送出的数量") @RequestParam(value = "currentCount") int currentCount,
//            HttpServletRequest request) {
//		Response response = new Response();
//        try {
//        	roomService.givePresents(Long.parseLong(giverId), Long.parseLong(goodsId), amount, Long.parseLong(receiverId), Long.parseLong(roomId), currentCount);
//        	response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (InfServerException ee) {
//			log.error("赠送礼物：", ee);
//			response.setError(ee.getErrorMsg());
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			return JSON.toJSONString(response);
//		}
//		catch (Exception e) {
//			log.error("赠送礼物：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "compereLive/enterRoom", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "加入房间", httpMethod = "POST", position = 2, response = Response.class, notes = "加入房间，如果加密则需输入密码")
//    public String enterRoom(
//            @ApiParam(required = true, name = "roomId", value = "房间id")
//            @RequestParam(value = "roomId") String roomId,
//            @ApiParam(required = true, name = "userId", value = "用户id")
//            @RequestParam(value = "userId") String userId,
//            @ApiParam(name = "password", required = false, value = "密码")
//            @RequestParam(value = "password", required = false) String password,
//            @ApiParam(name = "excRoomId", required = false, value = "异常房间号")
//            @RequestParam(value = "excRoomId", required = false) String excRoomId,
//            HttpServletRequest request) {
//	    Response response = new Response();
//        try {
//            CacheRoomProfile profile = liveService.isEnterRoomSuccess(roomId, userId, password, excRoomId, false);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(profile);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//			log.error("加入房间：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "compereLive/getRoomList", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "按城市获取房间列表", httpMethod = "POST", position = 2, response = Response.class)
//    public String getRoomList(
//            @ApiParam(required = true, name = "cityId", value = "城市id")
//            @RequestParam(value = "cityId") Long cityId,
//            HttpServletRequest request) {
//	    Response response = new Response();
//        try {
//            List<CacheRoomListProfile> profiles = liveService.getRoomList(cityId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(profiles);
//            return JSONObject.toJSONString(response);
//        } catch (Exception e) {
//			log.error("按城市获取房间列表：", e);
//			CommonUtil.BuildErrorResponse(e, response);
//			response.setError(e.getMessage());
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/getAllRoomList", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "获取所有房间列表", position = 2, response = Response.class)
//	public String getAllRoomList(
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//			@RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			List<CacheRoomListProfile> profiles = liveService.getAllRoomList();
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(profiles);
//		} catch (Exception e) {
//			log.error("获取所有房间列表：", e);
//			CommonUtil.BuildErrorResponse(e, response);
//			response.setError(e.getMessage());
//		}
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/getFollowedRoomList", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "获取玩家关注的房间列表", httpMethod = "POST", position = 2, response = Response.class)
//	public String getFollowedRoomList(
//			@ApiParam(required = true, name = "userId", value = "用户id")
//			@RequestParam(value = "userId") String userId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			List<CacheRoomListProfile> profiles = liveService.getFollowedRoomList(userId);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(profiles);
//			return JSONObject.toJSONString(response);
//		} catch (Exception e) {
//			log.error("获取玩家关注的房间列表：", e);
//			CommonUtil.BuildErrorResponse(e, response);
//			response.setError(e.getMessage());
//			return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//    @RequestMapping(value = "compereLive/openYouSayIGuess", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "开启你说我猜", httpMethod = "POST", position = 2, response = Response.class, notes = "开启你说我猜")
//    public String openYouSayIGuess(
//    		@ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            @ApiParam(required = true, name = "topicId", value = "电台ID") @RequestParam(value = "topicId") String topicId,
//            @ApiParam(required = true, name = "topic", value = "电台主题") @RequestParam(value = "topic") String topic,
//            @ApiParam(required = true, name = "goodsId", value = "商品ID") @RequestParam(value = "goodsId") String goodsId,
//            HttpServletRequest request) {
//	    Response response = new Response();
//        try {
//            roomService.openYouSayIGuess(cityId, roomId, topicId, topic, goodsId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONObject.toJSONString(response);
//        } catch (Exception e) {
//			log.error("开启你说我猜：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "compereLive/startYouSayIGuess", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "开始你说我猜", httpMethod = "POST", position = 2, response = Response.class, notes = "开始你说我猜")
//    public String startYouSayIGuess(
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            HttpServletRequest request) {
//	    Response response = new Response();
//        try {
//            roomService.startYouSayIGuess(roomId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONObject.toJSONString(response);
//        } catch (Exception e) {
//			log.error("开始你说我猜：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "compereLive/selectWordForYouSayIGuess", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "你说我猜选词", httpMethod = "POST", position = 2, response = Response.class, notes = "你说我猜选词")
//    public String selectWordForYouSayIGuess(
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            @ApiParam(required = true, name = "word", value = "选词") @RequestParam(value = "word") String word,
//            HttpServletRequest request) {
//	    Response response = new Response();
//        try {
//            roomService.selectWordForYouSayIGuess(roomId, word);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONObject.toJSONString(response);
//        } catch (Exception e) {
//			log.error("你说我猜选词：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "compereLive/joinYouSayIGuess", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "加入你说我猜", httpMethod = "POST", position = 2, response = Response.class, notes = "加入你说我猜")
//    public String joinYouSayIGuess(
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            @ApiParam(required = true, name = "compereId", value = "主播ID") @RequestParam(value = "compereId") String compereId,
//            @ApiParam(required = true, name = "playerId", value = "玩家ID") @RequestParam(value = "playerId") String playerId,
//            @ApiParam(required = true, name = "goodsId", value = "商品ID") @RequestParam(value = "goodsId") String goodsId,
//            @ApiParam(required = true, name = "position", value = "位置") @RequestParam(value = "position") String position,
//            @ApiParam(required = true, name = "currentCount", value = "该礼物当前送出的数量") @RequestParam(value = "currentCount") int currentCount,
//            HttpServletRequest request) {
//	    Response response = new Response();
//        try {
//            roomService.joinYouSayIGuess(roomId, compereId, playerId, goodsId, position, currentCount);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONObject.toJSONString(response);
//        } catch (Exception e) {
//			log.error("加入你说我猜：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "compereLive/answerYouSayIGuess", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "回答你说我猜", httpMethod = "POST", position = 2, response = Response.class, notes = "回答你说我猜")
//    public String answerYouSayIGuess(
//            @ApiParam(required = true, name = "roomId", value = "房间ID") @RequestParam(value = "roomId") String roomId,
//            @ApiParam(required = true, name = "position", value = "位置") @RequestParam(value = "position") String position,
//            HttpServletRequest request) {
//	    Response response = new Response();
//        try {
//        	roomService.answerYouSayIGuess(roomId, position);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONObject.toJSONString(response);
//        } catch (Exception e) {
//			log.error("回答你说我猜：", e);
//			 CommonUtil.BuildErrorResponse(e, response);
//			 return JSON.toJSONString(response);
//		}
//    }
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/uploadLiveCut", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "上传视频帧", httpMethod = "POST", position = 2, response = Response.class, notes = "上传视频帧")
//	public String uploadLiveCut(
//			@ApiParam(required = true, name = "roomId", value = "房间id")
//			@RequestParam(value = "roomId") String roomId,
//			@ApiParam(required = true, name = "photoUrl", value = "photoUrl")
//			@RequestParam(value = "photoUrl") String photoUrl,
//			@ApiParam(required = true, name = "cityId", value = "城市id")
//			@RequestParam(value = "cityId") String cityId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			liveService.uploadLiveCut(roomId, photoUrl, cityId);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSONObject.toJSONString(response);
//		} catch (Exception e) {
//			log.error("上传视频帧：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/hotWords", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "直播间热词", httpMethod = "POST", position = 2, response = Response.class, notes = "上传视频帧")
//	public String hotWords(
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			List<TLiveHotWords> list = liveService.hotWords();
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(list);
//			return JSONObject.toJSONString(response);
//		} catch (Exception e) {
//			log.error("直播间热词：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/compereGetRedPacket", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "主播领取直播间红包", httpMethod = "POST", position = 2, response = Response.class)
//	public String compereGetRedPacket(
//			@ApiParam(required = true, name = "roomId", value = "房间id")
//			@RequestParam(value = "roomId") String roomId,
//			@ApiParam(required = true, name = "index", value = "红包轮数下标")
//			@RequestParam(value = "index") Integer index,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			liveService.compereGetRedPacket(roomId, index);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSONObject.toJSONString(response);
//		} catch (Exception e) {
//			log.error("主播领取直播间红包：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			response.setError(e.getMessage());
//			return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/playerGetRedPacket", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "玩家领取直播间红包", httpMethod = "POST", position = 2, response = Response.class)
//	public String playerGetRedPacket(
//			@ApiParam(required = true, name = "roomId", value = "房间id")
//			@RequestParam(value = "roomId") String roomId,
//			@ApiParam(required = true, name = "playerId", value = "玩家id")
//			@RequestParam(value = "playerId") Long playerId,
//			@ApiParam(required = true, name = "index", value = "红包轮数下标")
//			@RequestParam(value = "index") Integer index,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			liveService.playerGetRedPacket(roomId, playerId, index);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSONObject.toJSONString(response);
//		} catch (Exception e) {
//			log.error("玩家领取直播间红包：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			response.setError(e.getMessage());
//			return JSON.toJSONString(response);
//		}
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "compereLive/testGivePresent", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "测试送礼物", httpMethod = "POST", position = 2, response = Response.class, notes = "测试送礼物")
//	public String testGivePresent(
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			final Long giverId = 272L;
//			final Long goodsId = 8L;
//			final Integer amount = 10;
//			final Long receiverId = 290L;
//			final Long roomId = 1973L;
//			final Integer currentCount = 10;
//			final String url = "http://localhost:8080/hbiInterface/givePresent";
//			final String param = "giverId=" + giverId + "&&goodsId=" + goodsId + "&&amount=" + amount + "&&receiverId=" + receiverId + "&&roomId=" + roomId + "&&currentCount=" + currentCount;
//			for (int i = 0; i < 150; i++) {
//				new Thread(new Runnable() {
//					@Override
//					public void run() {
//						HttpUtil.sendPost(url, param);
//					}
//				}).start();
//			}
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSONObject.toJSONString(response);
//		} catch (Exception e) {
//			log.error("测试送礼物：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//			return JSON.toJSONString(response);
//		}
//	}
//
//}
