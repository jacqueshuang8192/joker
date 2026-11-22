//package com.hbi.controller.compere;
//
//import java.util.List;
//
//import javax.servlet.http.HttpServletRequest;
//
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Controller;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RequestMethod;
//import org.springframework.web.bind.annotation.RequestParam;
//import org.springframework.web.bind.annotation.ResponseBody;
//
//import com.alibaba.fastjson.JSONObject;
//import com.core.util.ResponseUtil;
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.BaseCacheController;
//import com.hbi.cache.model.CacheCountry;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TCityMapper;
//import com.hbi.mapper.TProvinceMapper;
//import com.hbi.mapper.TTownMapper;
//import com.hbi.model.TCity;
//import com.hbi.model.TProvince;
//import com.hbi.model.TTown;
//import com.hbi.vo.response.Response;
//import com.wordnik.swagger.annotations.Api;
//import com.wordnik.swagger.annotations.ApiOperation;
//import com.wordnik.swagger.annotations.ApiParam;
//
//@Api(basePath = "/", value = "省市区相关接口", position = 2)
//@Controller
//public class AreaController {
//
//    @Autowired
//    private TProvinceMapper provinceMapper;
//
//    @Autowired
//    private TCityMapper cityMapper;
//
//    @Autowired
//    private TTownMapper townMapper;
//
//    @Autowired
//    private BaseCacheController baseCacheController;
//
//    @ResponseBody
//    @RequestMapping(value = "getProvince", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    public String getProvince(HttpServletRequest request) {
//        TProvince province = new TProvince();
//        List<TProvince> resultList = provinceMapper.select(province);
//        Response response = ResponseUtil.getSuccessWithDataResponse(resultList);
//        return JSONObject.toJSONString(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "getCity", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    public String getCity(
//            @ApiParam(required = true, name = "provinceId", value = "省") @RequestParam(value = "provinceId") String provinceId,
//            HttpServletRequest request) {
//        TCity city = new TCity();
//        city.setProvinceId(Long.parseLong(provinceId));
//        List<TCity> resultList = cityMapper.select(city);
//        Response response = ResponseUtil.getSuccessWithDataResponse(resultList);
//        return JSONObject.toJSONString(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "getTown", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    public String getTown(
//            @ApiParam(required = true, name = "cityId", value = "省") @RequestParam(value = "cityId") String cityId,
//            HttpServletRequest request) {
//        TTown town = new TTown();
//        town.setCityId(Long.parseLong(cityId));
//        List<TTown> resultList = townMapper.select(town);
//        Response response = ResponseUtil.getSuccessWithDataResponse(resultList);
//        return JSONObject.toJSONString(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "getAllAreaInfo", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "获取所有省市区", httpMethod = "POST", position = 2, response = Response.class, notes = "获取所有省市区")
//    public String getAllAreaInfo(
//            HttpServletRequest request)
//    {
//    	Response response = new Response();
//        ICache cache = CacheManager.getCache();
//        CacheCountry cacheCountry = baseCacheController.queryCountry("CN", cache);
//        CacheManager.releaseCache(cache);
//        if (cacheCountry == null || cacheCountry.getProvinces().size() == 0) {
//            cacheCountry = new CacheCountry();
//            cacheCountry.setReturnCode(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR);
//            return JSONObject.toJSONString(cacheCountry);
//        }
//        response.setData(cacheCountry);
//        response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        return JSONObject.toJSONString(response);
//    }
//}
