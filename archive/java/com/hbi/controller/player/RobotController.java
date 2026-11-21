//package com.hbi.controller.player;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.core.util.ConfigUtil;
//import com.hbi.constants.Constants;
//import com.hbi.model.TPlayer;
//import com.hbi.model.TUser;
//import com.hbi.service.player.RobotService;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
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
//import java.sql.SQLException;
//import java.util.Date;
//
//@Api(basePath = "/", value = "robot用户信息管理", position = 2)
//@Controller
//public class RobotController {
//
//    private static final Log log = LogFactory.getLog(RobotController.class);
//
//    @Autowired
//    private RobotService robotService;
//
//
//    @ResponseBody
//    @RequestMapping(value = "updateJWD", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "更新玩家信息里面的经纬度,(服务器调用需要加入GeoLiteCity.dat文件,在/opt/ 目录下加)",  response = Response.class, notes = "玩家注册")
//    public String updateJWD(
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
////            robotService.updateJWD();
//
//            robotService.verifyIp();
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (InfServerException ie) {
//            log.error("更新玩家信息里面的经纬度：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("更新玩家信息里面的经纬度：", e);
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
//    @RequestMapping(value = "addRobotinfo", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "添加一批机器人!!",  response = Response.class, notes = "addRobotinfo")
//    public String addRobotinfo(
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
////            robotService.updateJWD();
//            robotService.addRobotinfo();
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (InfServerException ie) {
//            log.error("添加一批机器人：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("添加一批机器人：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSON.toJSONString(response);
//    }
//
//}
