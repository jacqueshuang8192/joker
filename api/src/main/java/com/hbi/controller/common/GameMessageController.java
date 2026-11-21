package com.hbi.controller.common;

import com.alibaba.fastjson.JSON;
import com.hbi.constants.Constants;
import com.hbi.mapper.TGameMessageMapper;
import com.hbi.mapper.TServiceInformationMapper;
import com.hbi.service.common.FeedbackService;
import com.hbi.service.common.GameMessageService;
import com.hbi.utils.CommonUtil;
import com.hbi.utils.InfServerException;
import com.hbi.vo.response.Response;
import com.pingplusplus.model.Charge;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.Parameter;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import jakarta.servlet.http.HttpServletRequest;

/**
 * Created by dzesla on 2017/2/16.
 */

@Tag(name = "游戏信息收集接口")
@RequestMapping(value = "GameMessage")
@Controller
public class GameMessageController {
    private static final Logger LOGGER = Logger.getLogger(GameMessageService.class);


    @Autowired
    private GameMessageService gameMessageService;

    @ResponseBody
    @RequestMapping(value = "uploadGameMessage", method = { RequestMethod.POST,
            RequestMethod.GET }, produces = "application/json; charset=utf-8")
    @Operation(summary = "游戏问题上传接口", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String uploadGameMessage(
		@Parameter(required = true, name = "type", description = "信息类型 1为游戏错误信息")
            @RequestParam(value = "type") Integer type,
            @Parameter(required = true, name = "uid", description = "用户id")
            @RequestParam(value = "uid") Integer uid,
            @Parameter(required = true, name = "level", description = "游戏level")
            @RequestParam(value = "level") Integer level,
            @Parameter(name = "msg", description = "内容", required = true)
            @RequestParam(value = "msg") String msg,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") String XYUid,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
            @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request) {
        Response response = new Response();
        try {
            gameMessageService.uploadGameMessage(type,uid,level,msg);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        } catch (InfServerException ie) {
            LOGGER.error("游戏问题上传接口：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("游戏问题上传接口：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.toString());
        }
        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
            return CommonUtil.buildJSONPResponse(method, response);
        }
        return JSON.toJSONString(response);
    }
    
    
}
