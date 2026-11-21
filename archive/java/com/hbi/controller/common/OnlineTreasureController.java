//package com.hbi.controller.common;
//
//import com.alibaba.fastjson.JSON;
//import com.core.controller.BaseController;
//import com.hbi.cache.model.CacheStoreCategory;
//import com.hbi.constants.Constants;
//import com.hbi.model.TOnlineTreasureActivity;
//import com.hbi.model.TOnlineTreasureAddress;
//import com.hbi.service.common.OnlineTreasureService;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.hbi.vo.response.onlineTreasure.JoinTreasureActivityVo;
//import com.hbi.vo.response.onlineTreasure.MyTreasureActivityVo;
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
//import java.util.List;
//
///**
// * Created by yrou on 4/20/2016.
// */
//@Api(basePath = "/", value = "一元夺宝接口", position = 1)
//@Controller
//public class OnlineTreasureController extends BaseController {
//    private static final Log log = LogFactory.getLog(OnlineTreasureController.class);
//
//    @Autowired
//    private OnlineTreasureService onlineTreasureService;
//
//    @ResponseBody
//    @RequestMapping(value = "onlineTreasure/queryActiveTreasureList", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "夺宝首页", position = 1, response = Response.class)
//    public String queryActiveTreasureList (
//            @ApiParam(required = false, name = "cityId", value = "城市ID")
//            @RequestParam(required = false, value = "cityId") Long cityId,
//            @ApiParam(required = false, name = "categoryId", value = "分类ID")
//            @RequestParam(required = false, value = "categoryId") Long categoryId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<TOnlineTreasureActivity> list = onlineTreasureService.queryActiveTreasureList(cityId, categoryId);
//            list.addAll(onlineTreasureService.queryNearestPreviouceActivities());
//            response.setData(list);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch(InfServerException ie){
//            log.error("夺宝首页：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("夺宝首页：", e);
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
//    @RequestMapping(value = "onlineTreasure/activityDetail", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "活动详情", position = 1, response = Response.class)
//    public String activityDetail (
//            @ApiParam(required = true, name = "activityId", value = "活动ID")
//            @RequestParam(required = true, value = "activityId") Long activityId,
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(required = true, value = "userId") Long userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            MyTreasureActivityVo activity = onlineTreasureService.activityDetail(activityId, userId);
//            response.setData(activity);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch(InfServerException ie){
//            log.error("活动详情：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("活动详情：", e);
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
//    @RequestMapping(value = "onlineTreasure/joinActivity", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "参加夺宝", position = 1, response = Response.class)
//    public String joinActivity (
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(required = true, value = "userId") Long userId,
//            @ApiParam(required = true, name = "userType", value = "用户类型")
//            @RequestParam(required = true, value = "userType") String userType,
//            @ApiParam(required = true, name = "jewelAmount", value = "房卡数量")
//            @RequestParam(required = true, value = "jewelAmount") Integer jewelAmount,
//            @ApiParam(required = true, name = "activityId", value = "活动ID")
//            @RequestParam(required = true, value = "activityId") Long activityId,
//            @ApiParam(required = true, name = "isToEnd", value = "是否买光,0否，1是")
//            @RequestParam(required = true, value = "isToEnd") Integer isToEnd,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            JoinTreasureActivityVo vo = onlineTreasureService.joinActivity(userId, userType, jewelAmount, activityId, isToEnd);
//            response.setData(vo);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch(InfServerException ie){
//            log.error("参加夺宝：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("参加夺宝：", e);
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
//    @RequestMapping(value = "onlineTreasure/queryMyActivities", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "我参与的夺宝活动", position = 1, response = Response.class)
//    public String queryMyActivities (
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(required = true, value = "userId") Long userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<MyTreasureActivityVo> list = onlineTreasureService.queryMyActivities(userId);
//            response.setData(list);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch(InfServerException ie){
//            log.error("我参与的夺宝活动：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("我参与的夺宝活动：", e);
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
//    @RequestMapping(value = "onlineTreasure/queryPreviouceActivities", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "往期揭晓", position = 1, response = Response.class)
//    public String queryPreviouceActivities (
//            @ApiParam(required = false, name = "cityId", value = "城市ID")
//            @RequestParam(required = false, value = "cityId") Long cityId,
//            @ApiParam(required = false, name = "treasureId", value = "商品ID")
//            @RequestParam(required = false, value = "treasureId") Long treasureId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<TOnlineTreasureActivity> list = onlineTreasureService.queryPreviouceActivities(cityId, treasureId);
//            response.setData(list);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch(InfServerException ie){
//            log.error("往期揭晓：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("往期揭晓：", e);
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
//    @RequestMapping(value = "onlineTreasure/drawActivities", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "最新揭晓", position = 1, response = Response.class)
//    public String drawActivits (
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<TOnlineTreasureActivity> list = onlineTreasureService.drawActivities();
//            response.setData(list);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch(InfServerException ie){
//            log.error("最新揭晓：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("最新揭晓：", e);
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
//    @RequestMapping(value = "onlineTreasure/search", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "搜索", position = 1, response = Response.class)
//    public String search (
//            @ApiParam(required = false, name = "cityId", value = "城市ID")
//            @RequestParam(required = false, value = "cityId") Long cityId,
//            @ApiParam(required = true, name = "keyWord", value = "搜索关键字")
//            @RequestParam(required = true, value = "keyWord") String keyWord,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<TOnlineTreasureActivity> list = onlineTreasureService.search(cityId, keyWord);
//            response.setData(list);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch(InfServerException ie){
//            log.error("搜索：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("搜索：", e);
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
//    @RequestMapping(value = "onlineTreasure/addAddress", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "添加收获地址", position = 1, response = Response.class)
//    public String addAddress (
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(required = true, value = "userId") Long userId,
//            @ApiParam(required = true, name = "userName", value = "收件人姓名")
//            @RequestParam(required = true, value = "userName") String userName,
//            @ApiParam(required = true, name = "phone", value = "收件人手机号")
//            @RequestParam(required = true, value = "phone") String phone,
//            @ApiParam(required = true, name = "address", value = "地址")
//            @RequestParam(required = true, value = "address") String address,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            Long id = onlineTreasureService.addAddress(userId, userName, phone, address);
//            response.setData(id);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch(InfServerException ie){
//            log.error("添加收获地址：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("添加收获地址：", e);
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
//    @RequestMapping(value = "onlineTreasure/selectAddress", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "夺宝活动选择收获地址", position = 1, response = Response.class)
//    public String selectAddress (
//            @ApiParam(required = true, name = "addressId", value = "地址ID")
//            @RequestParam(required = true, value = "addressId") Long addressId,
//            @ApiParam(required = false, name = "activityId", value = "活动ID")
//            @RequestParam(required = false, value = "activityId") Long activityId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            onlineTreasureService.chooseAddress(addressId, activityId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch(InfServerException ie){
//            log.error("夺宝活动选择收获地址：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("夺宝活动选择收获地址：", e);
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
//    @RequestMapping(value = "onlineTreasure/queryAddress", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询收获地址", position = 1, response = Response.class)
//    public String queryAddress (
//            @ApiParam(required = true, name = "userId", value = "用户ID")
//            @RequestParam(required = true, value = "userId") Long userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<TOnlineTreasureAddress> list = onlineTreasureService.queryAddress(userId);
//            response.setData(list);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch(InfServerException ie){
//            log.error("查询收获地址：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("查询收获地址：", e);
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
//    @RequestMapping(value = "onlineTreasure/queryCategory", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询夺宝分类", position = 1, response = Response.class)
//    public String queryCategory (
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<CacheStoreCategory> list = onlineTreasureService.queryCategory();
//            response.setData(list);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch(InfServerException ie){
//            log.error("查询夺宝分类：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("查询夺宝分类：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//}
