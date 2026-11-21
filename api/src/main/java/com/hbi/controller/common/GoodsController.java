package com.hbi.controller.common;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.core.controller.BaseController;
import com.hbi.constants.Constants;
import com.hbi.mapper.TConfigMapper;
import com.hbi.model.ImsGoods;
import com.hbi.model.TExchangeHistory;
import com.hbi.model.TGoods;
import com.hbi.service.common.GoodsService;
import com.hbi.utils.CommonUtil;
import com.hbi.vo.response.Response;
import com.wordnik.swagger.annotations.Api;
import com.wordnik.swagger.annotations.ApiOperation;
import com.wordnik.swagger.annotations.ApiParam;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

//import com.hbi.model.TUserGoods;
//import com.hbi.service.common.UserGoodsService;

/**
 * 首页控制器
 * 
 * @author apple
 *
 */

@Api(basePath = "/", value = "商品信息接口", position = 1)
@Controller
public class GoodsController extends BaseController {

	private static final Log log = LogFactory.getLog(GoodsController.class);

	@Autowired
	private GoodsService goodsService;
	
	@ResponseBody
	@RequestMapping(value = "goods/queryGoods", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
	@ApiOperation(value = "获取商品信息", position = 2, response = Response.class, notes = "获取商品信息")
	public String queryGoods (
			@ApiParam(required = true, name = "type", value = "物品类型") @RequestParam(value = "type") String type,
			@ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") String XYUid,
			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//	@ApiOperation(value = "兑换商品", position = 2, response = Response.class, notes = "兑换商品")
//	public String exchange (
//			@ApiParam(required = true, name = "userId", value = "用户id")
//			@RequestParam(value = "userId") Long userId,
//			@ApiParam(required = true, name = "goodsId", value = "用户id")
//			@RequestParam(value = "goodsId") Long goodsId,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
//	@ApiOperation(value = "兑换历史", position = 2, response = Response.class, notes = "兑换历史")
//	public String queryExchangeHistory (
//			@ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") Long userId,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
//	@ApiOperation(value = "获取道具列表", position = 2, response = Response.class, notes = "获取道具列表")
//	public String queryGoodsList (
//			@ApiParam(required = false, name = "type", value = "物品类型") @RequestParam(required = false,value = "type") String type,
//			@ApiParam(required = false, name = "device", value = "登录设备，0:IOS;1：ANDROID;2：PC;3：其他") @RequestParam(required = false, value = "device") Integer device,
//			@ApiParam(required = false, name = "userId", value = "userId") @RequestParam(required = false, value = "userId") Long userId,
//			@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
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
