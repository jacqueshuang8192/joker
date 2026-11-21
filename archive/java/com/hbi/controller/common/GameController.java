//package com.hbi.controller.common;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.core.controller.BaseController;
//import com.core.util.JSONUtil;
//import com.hbi.constants.Constants;
//import com.hbi.model.*;
//import com.hbi.service.common.GameService;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.hbi.vo.response.game.UserOnlineGame;
//import com.wordnik.swagger.annotations.Api;
//import com.wordnik.swagger.annotations.ApiOperation;
//import com.wordnik.swagger.annotations.ApiParam;
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
//import java.util.Iterator;
//import java.util.List;
//
////import com.hbi.vo.response.user.MatchGameVo;
////import java.util.concurrent.atomic.LongAccumulator;
//
//@Api(basePath = "/", value = "游戏接口", position = 1)
//@Controller
//public class GameController extends BaseController {
//
//	private static final Log log = LogFactory.getLog(GameController.class);
//    private static final Log rechargeLog = LogFactory.getLog("Recharge");
//
//    @Autowired
//    private GameService gameService;
//
//    @ResponseBody
//    @RequestMapping(value = "game/hallLoading", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "大厅登陆", httpMethod = "POST", position = 2, response = Response.class, notes = "大厅登陆")
//    public String hallLoading(
//            @ApiParam(required = false, name = "platform", value = "平台：0pc，1安卓，2ios，3全平台")
//            @RequestParam(required = false, value = "platform") Integer platform,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
//            List<TGame> games = gameService.getHallLoadingGames();
//            if (platform == null) {
//                Iterator<TGame> iterator = games.iterator();
//                while (iterator.hasNext()) {
//                    TGame g = iterator.next();
//                    if (g.getGameId() != 1L) {
//                        iterator.remove();
//                    }
//                }
//            }
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            vo.setData(games);
//            return JSON.toJSONString(vo);
//        } catch (Exception e) {
//            log.error("大厅登陆：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSON.toJSONString(vo);
//        }
//    }
//
//
//
//    @ResponseBody
//    @RequestMapping(value = "game/queryGameProvince", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "大厅登陆", httpMethod = "POST", position = 2, response = Response.class, notes = "大厅登陆")
//    public String queryGameProvince(
//    		@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
//            List<TGameProvince> gameProvinces = gameService.getGameProvince();
//
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            vo.setData(gameProvinces);
//            return JSON.toJSONString(vo);
//        } catch (Exception e) {
//            log.error("游戏种类：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSON.toJSONString(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "game/freeGameList", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "组局游戏列表", httpMethod = "POST", position = 2, response = Response.class)
//    public String freeGameList(
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
//            List<TGame> games = gameService.getFreeGameList();
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            vo.setData(games);
//            return JSON.toJSONString(vo);
//        } catch (Exception e) {
//            log.error("组局游戏列表：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSON.toJSONString(vo);
//        }
//    }
//
////    @ResponseBody
////    @RequestMapping(value = "game/matchLoading", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//////    @ApiOperation(value = "选择赛场", httpMethod = "POST", position = 2, response = Response.class, notes = "选择赛场")
////    public String matchLoading(
////            @ApiParam(required = true, name = "gameId", value = "游戏id")
////            @RequestParam(value = "gameId") Long gameId,
////            @ApiParam(required = true, name = "userId", value = "用户id")
////            @RequestParam(value = "userId") Long userId,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            MatchLoadingVo vo = gameService.getMatchLoadingGames(gameId, userId);
////            response.setData(vo);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSON.toJSONString(response);
////        } catch (Exception e) {
////            log.error("选择赛场：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSON.toJSONString(response);
////        }
////    }
//
////    @ResponseBody
////    @RequestMapping(value = "game/freeMatch", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//////    @ApiOperation(value = "选择赛场", httpMethod = "POST", position = 2, response = Response.class, notes = "选择赛场")
////    public String freeGame(
////            @ApiParam(required = true, name = "gameId", value = "游戏id")
////            @RequestParam(value = "gameId") Long gameId,
////            HttpServletRequest request) {
////        Response vo = new Response();
////        try {
////            List<TQuickGame> games = gameService.getFree(gameId);
////            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            vo.setData(games);
////            return JSON.toJSONString(vo);
////        } catch (Exception e) {
////            log.error("自由场列表：", e);
////            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSON.toJSONString(vo);
////        }
////    }
//
////    @ResponseBody
////    @RequestMapping(value = "game/matchGame", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//////    @ApiOperation(value = "选择赛场", httpMethod = "POST", position = 2, response = Response.class, notes = "选择赛场")
////    public String matchGame(
////            @ApiParam(required = true, name = "gameId", value = "游戏id")
////            @RequestParam(value = "gameId") Long gameId,
////            HttpServletRequest request) {
////        Response vo = new Response();
////        try {
////            MatchGameVo games = gameService.getMatch(gameId);
////            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            vo.setData(games);
////            return JSON.toJSONString(vo);
////        } catch (Exception e) {
////            log.error("matchGame：", e);
////            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSON.toJSONString(vo);
////        }
////    }
//
////    @ResponseBody
////    @RequestMapping(value = "game/quickGameExtract", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    public String quickGameExtract(
////            @ApiParam(required = true, name = "quickGameId", value = "快速游戏id") @RequestParam(value = "quickGameId") String quickGameId,
////            @ApiParam(required = true, name = "totalIncome", value = "总收入") @RequestParam(value = "totalIncome") String totalIncome,
////            @ApiParam(required = true, name = "extractIncome", value = "分成收入") @RequestParam(value = "extractIncome") String extractIncome,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            gameService.addQuickGameProfit(Long.parseLong(quickGameId), Integer.parseInt(totalIncome), Integer.parseInt(extractIncome));
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSON.toJSONString(response);
////        } catch (Exception e) {
////            log.error("quickGameExtract：", e);
////            CommonUtil.BuildErrorResponse(e, response);
////			return JSON.toJSONString(response);
////        }
////    }
//
////    @ResponseBody
////    @RequestMapping(value = "game/signUpGameMatch", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    public String signUpGameMatch(
////    		@ApiParam(required = true, name = "gameId", value = "游戏id") @RequestParam(value = "gameId") String gameId,
////            @ApiParam(required = true, name = "gameMatchId", value = "游戏比赛分场id") @RequestParam(value = "gameMatchId") String gameMatchId,
////            @ApiParam(required = true, name = "userId", value = "玩家id") @RequestParam(value = "userId") String userId,
////            @ApiParam(required = true, name = "userType", value = "用户类型") @RequestParam(value = "userType") String userType,
////            @ApiParam(required = true, name = "totalIncome", value = "总收入") @RequestParam(value = "totalIncome") String totalIncome,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            gameService.signUpGameMatch(Long.parseLong(gameId), Long.parseLong(gameMatchId), Long.parseLong(userId), userType, Integer.parseInt(totalIncome));
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSON.toJSONString(response);
////        } catch (Exception e) {
////            log.error("signUpGameMatch：", e);
////            CommonUtil.BuildErrorResponse(e, response);
////			return JSON.toJSONString(response);
////        }
////    }
//
////    @ResponseBody
////    @RequestMapping(value = "game/applyGameAwardPool", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    public String applyGameAwardPool(
////            @ApiParam(required = true, name = "gameId", value = "游戏id") @RequestParam(value = "gameId") String gameId,
////            @ApiParam(required = true, name = "userId", value = "玩家id") @RequestParam(value = "userId") String userId,
////            @ApiParam(required = true, name = "userType", value = "用户类型") @RequestParam(value = "userType") String userType,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            gameService.applyGameAwardPool(Long.parseLong(gameId), Long.parseLong(userId), userType);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSON.toJSONString(response);
////        } catch (Exception e) {
////            log.error("applyGameAwardPool：", e);
////            CommonUtil.BuildErrorResponse(e, response);
////            return JSON.toJSONString(response);
////        }
////    }
//
////    @ResponseBody
////    @RequestMapping(value = "game/receiveGameAwardPoolReward", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    public String receiveGameAwardPoolReward(
////            @ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") String userId,
////            @ApiParam(required = true, name = "gameAwardPoolId", value = "奖池ID") @RequestParam(value = "gameAwardPoolId") String gameAwardPoolId,
////            @ApiParam(required = true, name = "userType", value = "用户类型") @RequestParam(value = "userType") String userType,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            gameService.receiveGameAwardPoolReward(Long.parseLong(userId), userType, Long.parseLong(gameAwardPoolId));
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSON.toJSONString(response);
////        } catch (Exception e) {
////            log.error("receiveGameAwardPoolReward：", e);
////            CommonUtil.BuildErrorResponse(e, response);
////            return JSON.toJSONString(response);
////        }
////    }
//
//    @ResponseBody
//    @RequestMapping(value = "game/liveGameExtract", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    public String liveGameExtract(
//    		@ApiParam(required = false, name = "roomId", value = "房间id") @RequestParam(value = "roomId", required = false) String roomId,
//    		@ApiParam(required = true, name = "gameId", value = "游戏id") @RequestParam(value = "gameId") String gameId,
//            @ApiParam(required = true, name = "compereId", value = "主播id") @RequestParam(value = "compereId") String compereId,
//            @ApiParam(required = true, name = "userId", value = "玩家id") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "extractIncome", value = "分成收入") @RequestParam(value = "extractIncome") String extractIncome,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            gameService.addLiveGameExtract(roomId, Long.parseLong(gameId), Long.parseLong(compereId), Long.parseLong(userId),Integer.parseInt(extractIncome));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("liveGameExtract：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "game/freeGameExtract", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    public String freeGameExtract(
//            @ApiParam(required = true, name = "activityId", value = "活动id") @RequestParam(value = "activityId") String activityId,
//            @ApiParam(required = false, name = "gameLevel", value = "游戏level") @RequestParam(required = false, value = "gameLevel") String gameLevel,
//            @ApiParam(required = true, name = "userId", value = "玩家id") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "extractIncome", value = "分成收入") @RequestParam(value = "extractIncome") String extractIncome,
//            @ApiParam(required = true, name = "totalIncome", value = "分成收入") @RequestParam(value = "totalIncome") Integer totalIncome,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            gameService.addFreeGameExtract(Long.parseLong(activityId), gameLevel, userId, totalIncome, Integer.parseInt(extractIncome));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("freeGameExtract：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//            return JSON.toJSONString(response);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "game/gameNumChanged", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    public String gameNumChanged(
//            @ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "userType", value = "用户类型") @RequestParam(value = "userType") String userType,
//            @ApiParam(required = true, name = "amount", value = "游戏局数") @RequestParam(value = "amount") String amount,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            gameService.gameNumChanged(Long.parseLong(userId), userType, Integer.parseInt(amount));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("gameNumChanged：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//        }
//    }
//
////    @ResponseBody
////    @RequestMapping(value = "game/updateDanPoint", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "更新段位积分", httpMethod = "POST", position = 1, response = Response.class)
////    public String updateDanPoint(
////            @ApiParam(required = true, name = "gameId", value = "游戏id,唯一")
////            @RequestParam(value = "gameId") Long gameId,
////            @ApiParam(required = true, name = "userId", value = "用户id")
////            @RequestParam(value = "userId") Long userId,
////            @ApiParam(required = true, name = "result", value = "输赢平，0输；1赢；2平")
////            @RequestParam(value = "result") Integer result,
////            @ApiParam(required = true, name = "userType", value = "用户类型")
////            @RequestParam(value = "userType") String userType,
////            HttpServletRequest request) {
////        Response vo = new Response();
////        try {
////            gameService.updateDanPoint(gameId, userId, userType, result);
////            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSONUtil.parseJSONContainsNull(vo);
////        } catch (InfServerException ie) {
////            log.error("更新段位积分：", ie);
////            vo.setReturnCode(ie.getErrorCode());
////            vo.setError(ie.getErrorMsg());
////            return JSONUtil.parseJSONContainsNull(vo);
////        } catch (Exception e) {
////            log.error("更新段位积分：", e);
////            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSONUtil.parseJSONContainsNull(vo);
////        }
////    }
//
//    @ResponseBody
//    @RequestMapping(value = "game/queryGameServer", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询游戏服务器", httpMethod = "POST", position = 1, response = Response.class)
//    public String queryGameServer(
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            TGameServer gameServer = gameService.queryGameServer();
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(gameServer);
//            return JSONUtil.parseJSONContainsNull(response);
//        } catch (InfServerException ie) {
//            log.error("查询游戏服务器：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(response);
//        } catch (Exception e) {
//            log.error("查询游戏服务器：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(response);
//        }
//    }
//
////    @ResponseBody
////    @RequestMapping(value = "getRoomCatetoryList", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "获取房间类别列表", httpMethod = "POST", response = Response.class, notes = "获取房间类别列表")
////    public String getRoomCatetoryList(
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////        	response.setData(gameService.getLiveActivityList());
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////        } catch (Exception e) {
////            log.error("获取房间类别列表：", e);
////            CommonUtil.BuildErrorResponse(e, response);
////        }
////        return JSON.toJSONString(response);
////    }
////
////    @ResponseBody
////    @RequestMapping(value = "game/queryPoolCoinAmount", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    public String queryPoolCoinAmount(
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            Integer coinAmount = gameService.queryPoolCoinAmount();
////            response.setData(coinAmount);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSON.toJSONString(response);
////        } catch (Exception e) {
////            log.error("queryPoolCoinAmount：", e);
////            CommonUtil.BuildErrorResponse(e, response);
////            return JSON.toJSONString(response);
////        }
////    }
//
//    @ResponseBody
//    @RequestMapping(value = "game/queryUserOnlineGameStatus", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询用户游戏在线情况", httpMethod = "POST", response = Response.class, notes = "查询用户游戏在线情况")
//    public String addAttention(
//            @ApiParam(required = true, name = "userId", value = "userId") @RequestParam(value = "userId") String userId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            UserOnlineGame userOnlineGame = gameService.queryUserOnlineGame(userId);
//            response.setData(userOnlineGame);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSON.toJSONString(response);
//        } catch (Exception e) {
//            log.error("查询用户游戏在线情况：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//            return JSON.toJSONString(response);
//        }
//    }
//    @ResponseBody
//    @RequestMapping(value = "game/queryGameType", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "大厅登陆", httpMethod = "POST", position = 2, response = Response.class, notes = "大厅登陆")
//    public String queryGameType(
//    		@ApiParam(required = false, name = "provinceId", value = "省份编号") @RequestParam(required = false,value = "provinceId") Long provinceId,
//    		@ApiParam(required = false, name = "agentId", value = "代理id") @RequestParam(required = false,value = "agentId") Long agentId,
//    		@ApiParam(required = false, name = "roomType", value = "房间类型  1 : 房卡场  2 : 房卡场  默认2:房卡场") @RequestParam(required = false,value = "roomType") Integer roomType,
//    		@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
//            List<TGameType> gametypes = gameService.getGametype(provinceId,agentId,roomType);
//
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            vo.setData(gametypes);
//            return JSON.toJSONString(vo);
//        } catch (Exception e) {
//            log.error("游戏种类：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSON.toJSONString(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "game/queryGameTypeByGold", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "大厅登陆", httpMethod = "POST", position = 2, response = Response.class, notes = "大厅登陆")
//    public String queryGameTypeByGold(
//            @ApiParam(required = false, name = "provinceId", value = "省份编号") @RequestParam(required = false,value = "provinceId") Long provinceId,
//            @ApiParam(required = false, name = "agentId", value = "代理id") @RequestParam(required = false,value = "agentId") Long agentId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
//            List<TGameTypeGold> gametypes = gameService.getGametypeByGold(provinceId,agentId);
//
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            vo.setData(gametypes);
//            return JSON.toJSONString(vo);
//        } catch (Exception e) {
//            log.error("游戏种类：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSON.toJSONString(vo);
//        }
//    }
//
////    @ResponseBody
////    @RequestMapping(value = "game/queryGameType", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//////    @ApiOperation(value = "大厅登陆", httpMethod = "POST", position = 2, response = Response.class, notes = "大厅登陆")
////    public String queryGameType(
//////    		@ApiParam(required = false, name = "provinceId", value = "省份编号") @RequestParam(required = false,value = "provinceId") Long provinceId,
//////    		@ApiParam(required = false, name = "agentId", value = "代理id") @RequestParam(required = false,value = "agentId") Long agentId,
////    		@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
////            @RequestParam(required = false, value = "interfaceType") String interfaceType,
////            HttpServletRequest request) {
////        Response vo = new Response();
////        try {
////            List<TGameType> gametypes = gameService.getGametype();
////
////            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            vo.setData(gametypes);
////            return JSON.toJSONString(vo);
////        } catch (Exception e) {
////            log.error("游戏种类：", e);
////            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSON.toJSONString(vo);
////        }
////    }
////    @ResponseBody
////    @RequestMapping(value = "game/queryGameMatchAwardByCondition", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "查询游戏奖励", httpMethod = "POST", position = 1, response = Response.class)
////    public String queryGameMatchAwardByCondition(
////            @ApiParam(required = true, name = "gameId", value = "游戏id") @RequestParam(value = "gameId") Long gameId,
////            @ApiParam(required = true, name = "level", value = "游戏level") @RequestParam(required = true, value = "level") Integer level,
////            HttpServletRequest request) {
////        Response vo = new Response();
////        try {
////            List<TGameMatchAward> list = gameService.queryGameMatchAwardByCondition(gameId, level);
////            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            vo.setData(list);
////            return JSONUtil.parseJSONContainsNull(vo);
////        } catch (InfServerException ie) {
////            log.error("查询游戏奖励：", ie);
////            vo.setReturnCode(ie.getErrorCode());
////            vo.setError(ie.getErrorMsg());
////            return JSONUtil.parseJSONContainsNull(vo);
////        } catch (Exception e) {
////            log.error("查询游戏奖励：", e);
////            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSONUtil.parseJSONContainsNull(vo);
////        }
////    }
//
//    @ResponseBody
//    @RequestMapping(value = "game/queryScoreSection", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询游戏分场进入区间", httpMethod = "POST", position = 1, response = Response.class)
//    public String queryScoreSection(
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
//            JSONObject result = gameService.queryScoreSection();
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            vo.setData(result);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("查询游戏奖励：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("查询游戏奖励：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "game/queryGameConfig", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询游戏配置", position = 2, response = Response.class)
//    public String queryGameConfig (
//    		@ApiParam(required = false, name = "provinceId", value = "省份编号") @RequestParam(required = false,value = "provinceId") Long provinceId,
//    		@ApiParam(required = false, name = "agentId", value = "代理id") @RequestParam(required = false,value = "agentId") Long agentId,
//    		@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response= new Response();
//        try {
//        	List<JSONObject> result = gameService.queryGameConfig(provinceId,agentId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(result);
//        } catch (InfServerException ie) {
//            log.error("查询游戏配置：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("查询游戏配置：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//
////    @ResponseBody
////    @RequestMapping(value = "game/queryGameConfig", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "查询游戏配置", position = 2, response = Response.class)
////    public String queryGameConfig (
////            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
////            @RequestParam(required = false, value = "interfaceType") String interfaceType,
////            HttpServletRequest request) {
////        Response response= new Response();
////        try {
////            TGameConfig result = gameService.queryGameConfig();
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            response.setData(result);
////        } catch (InfServerException ie) {
////            log.error("查询游戏配置：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////        } catch (Exception e) {
////            log.error("查询游戏配置：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////        }
////        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
////            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
////            return CommonUtil.buildJSONPResponse(method, response);
////        }
////        return JSON.toJSONString(response);
////    }
//}
