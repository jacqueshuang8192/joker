package com.j.joker.controller.common;

import jakarta.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.alibaba.fastjson.JSON;
import com.j.joker.core.controller.BaseController;
import com.j.joker.constants.Constants;
import com.j.joker.service.common.BaseDataService;
import com.j.joker.utils.CommonUtil;
import com.j.joker.vo.response.Response;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.Parameter;

@Tag(name = "基础数据接口")
@Controller
public class BaseDataController extends BaseController {

    private static final Log log = LogFactory.getLog(BaseDataController.class);

    @Autowired
    private BaseDataService baseDataService;

    @ResponseBody
    @RequestMapping(value = "baseData/queryAnnouncements", method = RequestMethod.POST, produces = "text/xml; charset=utf-8")
    @Operation(summary = "查询公告", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "查询公告")
    public String queryVersion(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
            @Parameter(required = false, name = "type", description = "1：购买房卡；2：走马灯；3，查询消息；4商品兑换说明。不传返回所有")
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
    @Operation(summary = "查询配置", method = "POST", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "查询公告")
    public String queryConfig(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
            @Parameter(required = false, name = "type", description = "查询配置") @RequestParam(required = false, value = "type") String type,
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
