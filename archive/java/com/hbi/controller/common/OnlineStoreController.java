//package com.hbi.controller.common;
//
//import java.util.List;
//
//import javax.servlet.http.HttpServletRequest;
//
//import com.hbi.utils.InfServerException;
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Controller;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RequestMethod;
//import org.springframework.web.bind.annotation.RequestParam;
//import org.springframework.web.bind.annotation.ResponseBody;
//import com.alibaba.fastjson.JSON;
//import com.core.controller.BaseController;
//import com.hbi.cache.model.CacheMerchantGoodsProfile;
//import com.hbi.cache.model.CacheMerchantStoreProfile;
//import com.hbi.cache.model.CacheStoreCategory;
//import com.hbi.constants.Constants;
//import com.hbi.service.common.OnlineStoreService;
//import com.hbi.utils.CommonUtil;
//import com.hbi.vo.response.Response;
//import com.hbi.vo.response.onlineStore.RecommendedStore;
//import com.wordnik.swagger.annotations.Api;
//import com.wordnik.swagger.annotations.ApiOperation;
//import com.wordnik.swagger.annotations.ApiParam;
//
///**
// * 首页控制器
// *
// * @author apple
// *
// */
//
//@Api(basePath = "/", value = "线上商城接口", position = 1)
//@Controller
//public class OnlineStoreController extends BaseController {
//
//	private static final Log log = LogFactory.getLog(OnlineStoreController.class);
//
//	@Autowired
//	private OnlineStoreService onlineStoreService;
//
//	@ResponseBody
//	@RequestMapping(value = "onlineStore/queryMerchantGoodsCategories", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//	@ApiOperation(value = "获取线上商城商品分类", httpMethod = "GET", position = 2, response = Response.class, notes = "获取线上商城商品分类")
//	public String queryMerchantGoodsCategories (
//	        @ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			List<CacheStoreCategory> categories = onlineStoreService.queryStoreCategories(Long.parseLong(cityId));
//			response.setData(categories);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//            log.error("获取线上商城商品分类：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            return CommonUtil.buildJSONPResponse(Constants.QUERY_MERCHANT_GOODS_CATEGORIES, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "onlineStore/queryRecommendedStores", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//    @ApiOperation(value = "获取推荐线上商城店铺列表", httpMethod = "GET", position = 2, response = Response.class, notes = "获取推荐线上商城店铺列表")
//    public String queryRecommendedStores (
//            @ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<RecommendedStore> recommendedStores = onlineStoreService.queryRecommendedStores(Long.parseLong(cityId));
//            response.setData(recommendedStores);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("获取推荐线上商城店铺列表：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        return CommonUtil.buildJSONPResponse(Constants.QUERY_RECOMMENDED_STORES, response);
//    }
//
//	@ResponseBody
//	@RequestMapping(value = "onlineStore/queryStores", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//	@ApiOperation(value = "获取线上商城店铺列表", httpMethod = "GET", position = 2, response = Response.class, notes = "获取线上商城店铺列表")
//	public String queryStores (
//	        @ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//			@ApiParam(required = true, name = "categoryId", value = "商品分类ID") @RequestParam(value = "categoryId") String categoryId,
//			@ApiParam(required = true, name = "categoryType", value = "商品分类类型(1:一级类型;2:二级类型)") @RequestParam(value = "categoryType") String categoryType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			List<CacheMerchantStoreProfile> onlineStores = onlineStoreService.queryStores(Long.parseLong(cityId), Long.parseLong(categoryId), categoryType);
//			response.setData(onlineStores);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//            log.error("获取线上商城店铺列表：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		return CommonUtil.buildJSONPResponse(Constants.QUERY_STORES, response);
//	}
//
//	@ResponseBody
//    @RequestMapping(value = "onlineStore/queryStoreDetail", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//    @ApiOperation(value = "获取线上商城店铺详情", httpMethod = "GET", position = 2, response = Response.class, notes = "获取线上商城店铺详情")
//    public String queryStoreDetail (
//            @ApiParam(required = true, name = "storeId", value = "店铺ID") @RequestParam(value = "storeId") String storeId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            CacheMerchantStoreProfile store = onlineStoreService.queryStoreDetail(Long.parseLong(storeId));
//            response.setData(store);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("获取线上商城店铺详情：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        return CommonUtil.buildJSONPResponse(Constants.QUERY_STORE_DETAIL, response);
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "onlineStore/queryMerchantGoodsDetail", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//    @ApiOperation(value = "获取线上商城商品详情", httpMethod = "GET", position = 2, response = Response.class, notes = "获取线上商城商品详情")
//    public String queryMerchantGoodsDetail (
//            @ApiParam(required = true, name = "merchantGoodsId", value = "商品ID") @RequestParam(value = "merchantGoodsId") String merchantGoodsId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            CacheMerchantGoodsProfile merchantGoods = onlineStoreService.queryMerchantGoodsDetail(Long.parseLong(merchantGoodsId));
//            response.setData(merchantGoods);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("获取线上商城商品详情：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        return CommonUtil.buildJSONPResponse(Constants.QUERY_MERCHANT_GOODS_DETAIL, response);
//    }
//
//	@ResponseBody
//    @RequestMapping(value = "onlineStore/buyMerchantGoods", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//    @ApiOperation(value = "购买线上商城商品", httpMethod = "GET", position = 2, response = Response.class, notes = "购买线上商城商品")
//    public String buyMerchantGoods (
//            @ApiParam(required = true, name = "merchantGoodsId", value = "商品ID") @RequestParam(value = "merchantGoodsId") String merchantGoodsId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            onlineStoreService.buyMerchantGoods(Long.parseLong(merchantGoodsId));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//            log.error("购买线上商城商品：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        return CommonUtil.buildJSONPResponse(Constants.BUY_MERCHANT_GOODS, response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "onlineStore/queryAds", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//    @ApiOperation(value = "查询广告位列表", httpMethod = "GET", position = 1, response = Response.class, notes = "查询广告位列表")
//    public String queryAds(
//            @ApiParam(required = true, name = "cityId", value = "城市id")
//            @RequestParam(value = "cityId") Long cityId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<CacheMerchantStoreProfile> list = onlineStoreService.queryAds(cityId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(list);
//        } catch (InfServerException ie) {
//            log.error("查询广告位列表：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("查询广告位列表：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        return CommonUtil.buildJSONPResponse(Constants.QUERY_ADS, response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "onlineStore/queryStoreByName", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//    @ApiOperation(value = "按名称搜索店铺", httpMethod = "GET", position = 1, response = Response.class)
//    public String queryStoreByName(
//            @ApiParam(required = true, name = "name", value = "店铺名称")
//            @RequestParam(value = "name") String name,
//            @ApiParam(required = true, name = "cityId", value = "城市id")
//            @RequestParam(value = "cityId") Long cityId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<CacheMerchantStoreProfile> list = onlineStoreService.queryStoreByName(cityId, name);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(list);
//        } catch (InfServerException ie) {
//            log.error("按名称搜索店铺：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("按名称搜索店铺：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        return CommonUtil.buildJSONPResponse(Constants.QUERY_STORE_BY_NAME, response);
//    }
//}
