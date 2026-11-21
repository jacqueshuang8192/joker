//package com.hbi.controller.common;
//
//import com.alibaba.fastjson.JSON;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TServiceInformationMapper;
//import com.hbi.service.common.FeedbackService;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.pingplusplus.model.Charge;
//import com.wordnik.swagger.annotations.Api;
//import com.wordnik.swagger.annotations.ApiOperation;
//import com.wordnik.swagger.annotations.ApiParam;
//import org.apache.log4j.Logger;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Controller;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RequestMethod;
//import org.springframework.web.bind.annotation.RequestParam;
//import org.springframework.web.bind.annotation.ResponseBody;
//
//import javax.servlet.http.HttpServletRequest;
//
///**
// * Created by dzesla on 2017/2/16.
// */
//
//@Api(basePath = "", value = "反馈接口", position = 1)
//@RequestMapping(value = "feedback")
//@Controller
//public class FeedbackController {
//    private static final Logger LOGGER = Logger.getLogger(FeedbackService.class);
//
//
//    @Autowired
//    private FeedbackService feedbackService;
//    @Autowired
//    private TServiceInformationMapper serviceInformationMapper;
//
//    @ResponseBody
//    @RequestMapping(value = "problemFeedback", method = { RequestMethod.POST,
//            RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "问题反馈接口", position = 2, response = Response.class)
//    public String problemFeedback(
//            @ApiParam(required = true, name = "userId", value = "用户id")
//            @RequestParam(value = "userId") Long userId,
//            @ApiParam(name = "content", value = "内容",required = true)
//            @RequestParam(value = "content") String content,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            feedbackService.problemFeedback(userId, content);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (InfServerException ie) {
//            LOGGER.error("问题反馈接口：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("问题反馈接口：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "feedback/queryServiceInformation", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询客服信息", position = 2, response = Response.class)
//    public String queryServiceInformation (
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response= new Response();
//        try {
//            String content = serviceInformationMapper.queryServiceInformation();
//            response.setData(content);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (InfServerException ie) {
//            LOGGER.error("查询客服信息：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            LOGGER.error("查询客服信息：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//        }
//        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//}
