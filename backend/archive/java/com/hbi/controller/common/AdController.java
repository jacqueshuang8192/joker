//package com.hbi.controller.common;
//
//import com.core.util.JSONUtil;
//import com.hbi.constants.Constants;
//import com.hbi.model.TAd;
//import com.hbi.service.common.AdService;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.wordnik.swagger.annotations.Api;
//import com.wordnik.swagger.annotations.ApiOperation;
//import com.wordnik.swagger.annotations.ApiParam;
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
// * Created by ceeuoo on 5/19/2016.
// */
//@Api(basePath = "/ad", value = "广告接口", position = 1)
//@Controller
//public class AdController {
//    @Autowired
//    private AdService adService;
//
//    @ResponseBody
//    @RequestMapping(value = "/getAdList", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "获取广告列表", position = 2, response = Response.class, notes = "获取广告列表")
//    public String getAdList(
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            List<TAd> ads = adService.queryAds();
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(ads);
//        } catch (InfServerException ie) {
//            ie.printStackTrace();
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            e.printStackTrace();
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSONUtil.parseJSONContainsNull(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "/getRandomAd", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "获取广告列表", position = 2, response = Response.class, notes = "获取广告列表")
//    public String getRandomAd(
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            TAd ads = adService.queryRandomAd();
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(ads);
//        } catch (InfServerException ie) {
//            ie.printStackTrace();
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            e.printStackTrace();
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSONUtil.parseJSONContainsNull(response);
//    }
//}
