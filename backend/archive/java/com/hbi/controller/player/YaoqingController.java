//package com.hbi.controller.player;
//
//import java.io.ByteArrayOutputStream;
//import java.io.InputStream;
//import java.sql.SQLException;
//import java.text.DateFormat;
//import java.text.SimpleDateFormat;
//import java.util.*;
//import javax.servlet.http.HttpServletRequest;
//import com.core.util.*;
//import com.hbi.datasource.DbContextHolder;
//import com.hbi.mapper.TConfigMapper;
//import com.hbi.mapper.TYaoQingBangDingMapper;
//import com.hbi.model.*;
//import com.hbi.service.common.GoodsService;
//import com.hbi.service.inviteCodeGen.InviteCodeGen;
//import com.hbi.utils.ChargeException;
//import org.apache.commons.collections.MapUtils;
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
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.core.controller.BaseController;
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.model.CachePlayerProfile;
//import com.hbi.constants.Constants;
//import com.hbi.service.common.AccountChargeService;
//import com.hbi.service.common.UserService;
//import com.hbi.service.player.PlayerService;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.hbi.vo.response.base.BaseResultVo;
//import com.hbi.vo.response.user.LevelVo;
//import com.hbi.vo.response.user.OAuthVo;
////import com.hbi.vo.response.user.TaskListVo;
//import com.pingplusplus.Pingpp;
//import com.pingplusplus.model.Charge;
//import com.pingplusplus.model.Event;
//import com.wordnik.swagger.annotations.Api;
//import com.wordnik.swagger.annotations.ApiOperation;
//import com.wordnik.swagger.annotations.ApiParam;
//
///**
// * 玩家控制器
// *
// * @author yrou
// *
// */
//
//@Api(basePath = "/", value = "玩家邀请相关接口", position = 2)
//@Controller
//public class YaoqingController extends BaseController {
//
//	private static final Log log = LogFactory.getLog(YaoqingController.class);
//	private static final Log rechargeLog = LogFactory.getLog("Recharge");
//
//	@Autowired
//	private PlayerService playerService;
//	@Autowired
//	private TYaoQingBangDingMapper tYaoQingBangDingMapper;
//	@Autowired
//	private TConfigMapper tConfigMapper;
//	@Autowired
//	private InviteCodeGen codeGen;
//
//	@ResponseBody
//	@RequestMapping(value = "userBindingPromoter", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "玩家绑定推荐人", httpMethod = "POST", response = Response.class, notes = "玩家绑定推荐人")
//	public String userBindingAgent(
//			@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//			@ApiParam(required = true, name = "promoterId", value = "推荐人ID") @RequestParam(value = "promoterId") String promoterId,
//			HttpServletRequest request) {
//		Response response = new Response();
//
//		try {
//			playerService.userBindingPromoter(Long.parseLong(userId), Long.parseLong(promoterId));
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("玩家绑定代理：", e);
//			CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//		}
//
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "getRoomcard", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//	@ApiOperation(value = "领取房卡", httpMethod = "POST", response = Response.class, notes = "领取房卡")
//	public String getRoomcard(
//			@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//			HttpServletRequest request) {
//		Response response = new Response();
//
//		try {
//			playerService.getRoomcard(Long.parseLong(userId));
//			JSONObject object = new JSONObject();
//			if (userId != null) {
//				TConfig config = new TConfig();
//                config.setK("bindPromoterSendCard");
//                config=tConfigMapper.selectOne(config);
//				Integer yaoqingRoomcards =  Integer.valueOf(config.getV());
//				object.put("yaoqingRoomcards", yaoqingRoomcards);
//
//
//			}
//			response.setData(object);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			return JSON.toJSONString(response);
//		} catch (Exception e) {
//			log.error("领取房卡：", e);
//			CommonUtil.BuildErrorResponse(e, response);
//			return JSON.toJSONString(response);
//		}
//
//	}
////1
//	@ResponseBody
//	@RequestMapping(value = "queryPromoterList", method = { RequestMethod.POST,
//			RequestMethod.GET }, produces = "application/json; charset=utf-8")
//	public String queryPromoterList(
//			@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") Long userId,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response vo = new Response();
//		try {
//			List<TYaoQingBangDing>  promoterList= tYaoQingBangDingMapper.queryPromoterList(userId);
//
//			vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			vo.setData(promoterList);
//			return JSON.toJSONString(vo);
//		} catch (Exception e) {
//			log.error("推荐人列表：", e);
//			vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//			return JSON.toJSONString(vo);
//		}
//	}
//}
