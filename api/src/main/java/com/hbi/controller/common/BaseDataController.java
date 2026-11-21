package com.hbi.controller.common;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.alibaba.fastjson.JSON;
import com.core.controller.BaseController;
import com.hbi.constants.Constants;
import com.hbi.service.common.BaseDataService;
import com.hbi.utils.CommonUtil;
import com.hbi.vo.response.Response;
import com.wordnik.swagger.annotations.Api;
import com.wordnik.swagger.annotations.ApiOperation;
import com.wordnik.swagger.annotations.ApiParam;

@Api(basePath = "/", value = "基础数据接口", position = 1)
@Controller
public class BaseDataController extends BaseController {

    private static final Log log = LogFactory.getLog(BaseDataController.class);

    @Autowired
    private BaseDataService baseDataService;

    @ResponseBody
    @RequestMapping(value = "baseData/queryAnnouncements", method = RequestMethod.POST, produces = "text/xml; charset=utf-8")
    @ApiOperation(value = "查询公告", httpMethod = "POST", position = 2, response = Response.class, notes = "查询公告")
    public String queryVersion(
            @ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") String XYUid,
            @ApiParam(required = false, name = "type", value = "1：购买房卡；2：走马灯；3，查询消息；4商品兑换说明。不传返回所有")
            @RequestParam(required = false, value = "type") String type,
            HttpServletRequest request) {
        Response response = new Response();
        try {
            response.setData(baseDataService.queryAnnouncementByType(type));
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        } catch (Exception e) {
            log.error(CommonUtil.buildErrorLog(e));
            CommonUtil.BuildErrorResponse(e, response);
        }
        return JSON.toJSONString(response);
    }


    @ResponseBody
    @RequestMapping(value = "baseData/queryConfig", method = RequestMethod.POST, produces = "text/xml; charset=utf-8")
    @ApiOperation(value = "查询配置", httpMethod = "POST", position = 2, response = Response.class, notes = "查询公告")
    public String queryConfig(
            @ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") String XYUid,
            @ApiParam(required = false, name = "type", value = "查询配置") @RequestParam(required = false, value = "type") String type,
            HttpServletRequest request) {
        Response response = new Response();
        try {
            response.setData(baseDataService.queryConfig(type));
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        } catch (Exception e) {
            log.error(CommonUtil.buildErrorLog(e));
            CommonUtil.BuildErrorResponse(e, response);
        }
        return JSON.toJSONString(response);
    }


}
