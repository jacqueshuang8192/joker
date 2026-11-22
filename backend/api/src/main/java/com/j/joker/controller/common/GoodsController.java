package com.j.joker.controller.common;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.controller.BaseController;
import com.j.joker.constants.Constants;
import com.j.joker.mapper.TConfigMapper;
import com.j.joker.model.ImsGoods;
import com.j.joker.model.TExchangeHistory;
import com.j.joker.model.TGoods;
import com.j.joker.service.common.GoodsService;
import com.j.joker.utils.CommonUtil;
import com.j.joker.vo.response.Response;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.Parameter;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

//import com.j.joker.model.TUserGoods;
//import com.j.joker.service.common.UserGoodsService;

/**
 * 首页控制器
 * 
 * @author apple
 *
 */

@Tag(name = "商品信息接口")
@Controller
public class GoodsController extends BaseController {

	private static final Log log = LogFactory.getLog(GoodsController.class);

	@Autowired
	private GoodsService goodsService;
	
	@ResponseBody
	@RequestMapping(value = "goods/queryGoods", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
	@Operation(summary = "获取商品信息", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "获取商品信息")
	public String queryGoods (
			@Parameter(required = true, name = "type", description = "物品类型") @RequestParam(value = "type") String type,
			@Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
			@RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
			List<TGoods> goods = goodsService.findGoodsByType(type);
			response.setData(goods);
			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
		} catch (Exception e) {
			log.error("获取商品信息：", e);
            CommonUtil.BuildErrorResponse(e, response);
        }
		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}

//	@ResponseBody
//	@RequestMapping(value = "goods/exchange", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@Operation(summary = "兑换商品", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "兑换商品")
//	public String exchange (
//			@Parameter(required = true, name = "userId", description = "用户id")
//			@RequestParam(value = "userId") Long userId,
//			@Parameter(required = true, name = "goodsId", description = "用户id")
//			@RequestParam(value = "goodsId") Long goodsId,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//			@RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			String code = goodsService.exchange(userId, goodsId);
//			response.setData(code);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("获取商品信息：", e);
//			CommonUtil.BuildErrorResponse(e, response);
//		}
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

//	@ResponseBody
//	@RequestMapping(value = "goods/queryExchangeHistory", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@Operation(summary = "兑换历史", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "兑换历史")
//	public String queryExchangeHistory (
//			@Parameter(required = true, name = "userId", description = "用户id") @RequestParam(value = "userId") Long userId,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			List<TExchangeHistory> list = goodsService.queryExchangeHistory(userId);
//			response.setData(list);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("获取商品信息：", e);
//			CommonUtil.BuildErrorResponse(e, response);
//		}
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}
	
//	@ResponseBody
//	@RequestMapping(value = "goods/queryGoodsList", method = {RequestMethod.POST, RequestMethod.GET}, produces = "text/xml; charset=utf-8")
//	@Operation(summary = "获取道具列表", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "获取道具列表")
//	public String queryGoodsList (
//			@Parameter(required = false, name = "type", description = "物品类型") @RequestParam(required = false,value = "type") String type,
//			@Parameter(required = false, name = "device", description = "登录设备，0:IOS;1：ANDROID;2：PC;3：其他") @RequestParam(required = false, value = "device") Integer device,
//			@Parameter(required = false, name = "userId", description = "userId") @RequestParam(required = false, value = "userId") Long userId,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//			@RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			//if (StringUtil.isEmpty(type)) {
//			//	type="999";
//			//}
//
//			//List<TGoods> goods = goodsService.findGoodsByType(type, device);
//			List<ImsGoods> goods = goodsService.findImsGoodsByTpey(type,device,userId);
//			JSONObject object = new JSONObject();
//			//if (userId != null) {
//			//	Integer isBind = goodsService.isBindAgent(userId);
//			//	TConfig config = new TConfig();
//			//	config.setK("bindAgentSendCard");
//			//	config=configMapper.selectOne(config);
//			//	String bindAgentSendCard = config.getV();
//			//	object.put("isBindAgent", isBind);
//			//	object.put("bindAgentSendCard", bindAgentSendCard);
//			//}
//
//			object.put("list", goods);
//			response.setData(object);
////
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("获取道具列表(JSONP)：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

}
