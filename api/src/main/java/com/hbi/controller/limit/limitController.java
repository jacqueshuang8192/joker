package com.hbi.controller.limit;

import com.alibaba.fastjson.JSON;
import com.hbi.constants.Constants;
import com.hbi.model.TTestConfig;
import com.hbi.service.limit.TTestConfigService;
import com.hbi.utils.CommonUtil;
import com.hbi.vo.response.Response;
import com.wordnik.swagger.annotations.Api;
import com.wordnik.swagger.annotations.ApiOperation;
import com.wordnik.swagger.annotations.ApiParam;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

/**
 * Created by Administrator on 2017/7/21.
 */
@Api(basePath = "/", value = "受限的相关控制", position = 1)
@Controller
@RequestMapping(value = "/limit")
public class limitController {
    private static Logger log = Logger.getLogger(limitController.class);
    @Autowired
    private TTestConfigService testConfigService;

    @ResponseBody
    @RequestMapping(value = "verify", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @ApiOperation(value = "校验数据", position = 1, response = Response.class)
    public String verify(
            @ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") String XYUid,
            @ApiParam(required = true, name = "level", value = "level") @RequestParam(value = "level", required = true) String level,
            @ApiParam(required = true, name = "verify", value = "verify") @RequestParam(value = "verify", required = true) String verify,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {
            String verifyByUid = testConfigService.getVerifyByUidAndLevel(XYUid, level);
            if (verify!= null && verifyByUid != null && verify.equals(verifyByUid)) {
                response.setData("校验成功");
                response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            }else {
                response.setData("校验失败");
                response.setReturnCode(Constants.RETURN_CODE_FAIL);
            }
        } catch (Exception e) {
            log.error("快速注册：", e);
            CommonUtil.BuildErrorResponse(e, response);
        }
        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
            return CommonUtil.buildJSONPResponse(method, response);
        }
        return JSON.toJSONString(response);
    }

    @ResponseBody
    @RequestMapping(value = "getDataByUidOrLevel", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
    @ApiOperation(value = "根据level 查询数据uid", position = 1, response = Response.class)
    public String getDataByUidOrLevel(
            @ApiParam(required = true, name = "level", value = "level") @RequestParam(value = "level", required = true) String level,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {
            //如果传入的levle传入为空 直接返回
            if(level == null || level.trim() == "") {
                response.setError("level不可以为空哦");
                response.setReturnCode(Constants.RETURN_CODE_FAIL);
                if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
                    String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
                    return CommonUtil.buildJSONPResponse(method, response);
                }
                return JSON.toJSONString(response);
            }

            Map<String, Object> result = testConfigService.getDataByUidOrLevel(level);
            response.setData(result);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        } catch (Exception e) {
            log.error("根据level：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError("游戏版本异常...");
        }
        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
            return CommonUtil.buildJSONPResponse(method, response);
        }
        return JSON.toJSONString(response);
    }
}
