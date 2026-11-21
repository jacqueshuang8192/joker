//package com.hbi.controller.common;
//
//import javax.servlet.http.HttpServletRequest;
//
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Controller;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RequestMethod;
//import org.springframework.web.bind.annotation.RequestParam;
//import org.springframework.web.bind.annotation.ResponseBody;
//
//import com.core.controller.BaseController;
//import com.core.util.JSONUtil;
//import com.hbi.constants.Constants;
//import com.hbi.service.common.InformService;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.wordnik.swagger.annotations.Api;
//import com.wordnik.swagger.annotations.ApiOperation;
//import com.wordnik.swagger.annotations.ApiParam;
//
//@Api(basePath = "/", value = "举报接口", position = 1)
//@Controller
//public class InformController extends BaseController {
//
//    private static final Log log = LogFactory.getLog(InformController.class);
//
//    @Autowired
//    private InformService informService;
//
//    @ResponseBody
//    @RequestMapping(value = "inform/informUser", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "举报用户", httpMethod = "POST", position = 2, response = Response.class)
//    public String informUser (
//            @ApiParam(required = true, name = "informerId", value = "举报者ID")
//            @RequestParam(value = "informerId") Long informerId,
//            @ApiParam(required = true, name = "informantId", value = "被举报者ID")
//            @RequestParam(value = "informantId") Long informantId,
//            @ApiParam(required = true, name = "content", value = "举报内容")
//            @RequestParam(value = "content") String content,
//            @ApiParam(required = true, name = "type", value = "被举报类型：0用户；1群")
//            @RequestParam(value = "type") Integer type,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            informService.informUser(informerId, informantId, content, type);
//            return JSONUtil.parseJSONContainsNull(response);
//        } catch(InfServerException ie){
//            log.error("举报用户：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(response);
//        } catch (Exception e) {
//            log.error("举报用户：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(response);
//        }
//    }
//}
