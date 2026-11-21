//package com.hbi.controller.common;
//
//import com.alibaba.fastjson.JSONObject;
//import com.core.controller.BaseController;
//import com.core.util.JSONUtil;
//import com.hbi.cache.model.CacheSocietyProfile;
//import com.hbi.constants.Constants;
//import com.hbi.service.society.SocietyService;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.hbi.vo.response.society.*;
//import com.hbi.vo.response.user.ListVo;
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
// * 公会控制器
// *
// * @author apple
// *
// */
//
//@Api(basePath = "/", value = "公会接口", position = 1)
//@Controller
//public class SocietyController extends BaseController {
//
//    private static final Log log = LogFactory.getLog(SocietyController.class);
//
//    @Autowired
//    private SocietyService societyService;
//
//    @ResponseBody
//    @RequestMapping(value = "society/getSocietyListByCity", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "按城市查询公会列表", position = 2, response = CacheSocietyProfile.class, notes = "按城市查询公会列表")
//    public String getSocietyListByCity (
//            @ApiParam(required = true, name = "cityId", value = "城市id")
//            @RequestParam(value = "cityId") Long cityId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            ListVo vo = new ListVo();
//            List<CacheSocietyProfile> profiles = societyService.querySocietyListByCity(cityId);
//            vo.setCount(profiles.size());
//            vo.setList(profiles);
//            response.setData(vo);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch(InfServerException ie){
//            log.error("按城市查询公会列表：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("按城市查询公会列表：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponseContainsNull(method, response);
//        }
//        return JSONUtil.parseJSONContainsNull(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/queryAllSocieties", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询所有公会列表", position = 2, response = CacheSocietyProfile.class)
//    public String queryAllSocieties (
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            ListVo vo = new ListVo();
//            List<CacheSocietyProfile> profiles = societyService.queryAllSocieties();
//            vo.setCount(profiles.size());
//            vo.setList(profiles);
//            response.setData(vo);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch(InfServerException ie){
//            log.error("查询所有公会列表：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("查询所有公会列表：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSONUtil.parseJSONContainsNull(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/getSocietyDetail", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "获取公会详情", position = 2, response = SocietyDetailVo.class, notes = "获取公会详情")
//    public String getSocietyDetail (
//            @ApiParam(required = true, name = "societyId", value = "公会id,唯一")
//            @RequestParam(value = "societyId") String societyId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            CacheSocietyProfile profile = societyService.findSocietyDetailById(Long.parseLong(societyId));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(profile);
//        } catch(InfServerException ie){
//            log.error("获取公会详情：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("获取公会详情：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponse(method, response);
//        }
//        return JSONUtil.parseJSONContainsNull(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/getSocietyCompereList", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "获取公会主播列表", httpMethod = "POST", position = 2, response = ListVo.class, notes = "获取公会主播列表")
//    public String getSocietyCompereList (
//            @ApiParam(required = true, name = "societyId", value = "公会id,唯一")
//            @RequestParam(value = "societyId") String societyId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            ListVo vo = societyService.getSocietyCompereListById(Long.parseLong(societyId));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(vo);
//            return JSONUtil.parseJSONContainsNull(response);
//        } catch(InfServerException ie){
//            log.error("获取公会主播列表：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(response);
//        } catch (Exception e) {
//            log.error("获取公会主播列表：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(response);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/getSocietyPlayerList", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "获取公会玩家列表", httpMethod = "POST", position = 2, response = ListVo.class, notes = "获取公会玩家列表")
//    public String getSocietyPlayerList (
//            @ApiParam(required = true, name = "societyId", value = "公会id,唯一")
//            @RequestParam(value = "societyId") String societyId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            ListVo vo = societyService.getSocietyPlayerListById(Long.parseLong(societyId));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(vo);
//            return JSONUtil.parseJSONContainsNull(response);
//        } catch(InfServerException ie){
//            log.error("获取公会主播列表：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(response);
//        } catch (Exception e) {
//            log.error("获取公会玩家列表：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(response);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/getSocietyManagerList", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "获取公会管理员列表", httpMethod = "POST", position = 2, response = ListVo.class, notes = "获取公会管理员列表")
//    public String getSocietyManagerList (
//            @ApiParam(required = true, name = "societyId", value = "公会id,唯一")
//            @RequestParam(value = "societyId") String societyId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            ListVo vo = societyService.getSocietyManagerListById(Long.parseLong(societyId));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(vo);
//            return JSONUtil.parseJSONContainsNull(response);
//        } catch (InfServerException ie){
//            log.error("获取公会管理员列表：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(response);
//        } catch (Exception e) {
//            log.error("获取公会管理员列表：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(response);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/setSocietyManager", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "设置公会管理员", httpMethod = "POST", position = 2, response = Response.class, notes = "设置公会管理员")
//    public String setSocietyManager (
//            @ApiParam(required = true, name = "societyId", value = "公会id,唯一")
//            @RequestParam(value = "societyId") String societyId,
//            @ApiParam(required = true, name = "userId", value = "用户id,唯一")
//            @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "type", value = "用户类型")
//            @RequestParam(value = "type") String type,
//            HttpServletRequest request) {
//        Response vo= new Response();
//        try {
//            String managerId = request.getHeader("userId");
//            managerId = "1000";
//            boolean result = societyService.setSocietyManager(Long.parseLong(societyId), Long.parseLong(userId), type, Long.parseLong(managerId));
//            if(!result) {
//                vo.setReturnCode(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR);
//                return JSONUtil.parseJSONContainsNull(vo);
//            }
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("设置公会管理员：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("设置公会管理员：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/cancelSocietyManager", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "取消公会管理员", httpMethod = "POST", position = 2, response = Response.class, notes = "取消公会管理员")
//    public String cancelSocietyManager (
//            @ApiParam(required = true, name = "societyId", value = "公会id,唯一")
//            @RequestParam(value = "societyId") String societyId,
//            @ApiParam(required = true, name = "userId", value = "用户id,唯一")
//            @RequestParam(value = "userId") String userId,
//            HttpServletRequest request) {
//        Response vo= new Response();
//        try {
//            String managerId = request.getHeader("userId");
//            boolean result = societyService.cancelSocietyManager(Long.parseLong(societyId), Long.parseLong(userId), Long.parseLong(managerId));
//            if(!result) {
//                vo.setReturnCode(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR);
//                return JSONUtil.parseJSONContainsNull(vo);
//            }
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("取消公会管理员：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("取消公会管理员：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/joinSociety", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "加入公会", httpMethod = "POST", position = 2, response = Response.class, notes = "加入公会")
//    public String joinSociety (
//            @ApiParam(required = true, name = "societyId", value = "公会id,唯一")
//            @RequestParam(value = "societyId") String societyId,
//            @ApiParam(required = true, name = "userId", value = "用户id,唯一")
//            @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "type", value = "用户类型")
//            @RequestParam(value = "type") String type,
//            @ApiParam(required = true, name = "phone", value = "电话")
//            @RequestParam(value = "phone") String phone,
//            HttpServletRequest request) {
//        Response vo= new Response();
//        try {
//            boolean result = societyService.joinSociety(Long.parseLong(societyId), Long.parseLong(userId), type, phone);
//            if(!result) {
//                vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//                return JSONUtil.parseJSONContainsNull(vo);
//            }
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("加入公会：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("加入公会：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/exitSociety", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "退出公会", position = 2, response = Response.class, notes = "退出公会")
//    public String exitSociety (
//            @ApiParam(required = true, name = "userId", value = "用户id,唯一")
//            @RequestParam(value = "userId") String userId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            boolean result = societyService.exitSociety(Long.parseLong(userId));
//            if(!result) {
//                response.setReturnCode(Constants.RETURN_CODE_FAIL);
//                return JSONObject.toJSONString(response);
//            }
//        } catch (InfServerException ie) {
//            log.error("退出公会：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("退出公会：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponseContainsNull(method, response);
//        }
//        return JSONUtil.parseJSONContainsNull(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/kickPlayerOutOfSociety", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "踢出成员", httpMethod = "POST", position = 2, response = Response.class, notes = "踢出成员")
//    public String kickPlayerOutOfSociety (
//            @ApiParam(required = true, name = "societyId", value = "公会id,唯一")
//            @RequestParam(value = "societyId") String societyId,
//            @ApiParam(required = true, name = "userId", value = "用户id,唯一")
//            @RequestParam(value = "userId") String userId,
//            HttpServletRequest request) {
//        Response vo= new Response();
//        try {
//            String managerId = request.getHeader("userid");
//            boolean result = societyService.kickPlayerOutOfSociety(Long.parseLong(societyId), Long.parseLong(userId), Long.parseLong(managerId));
//            if(!result) {
//                vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//                return JSONUtil.parseJSONContainsNull(vo);
//            }
//            //TODO 管理员账户通知玩家端之类
//
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("踢出成员：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("踢出成员：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/getMiningList", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询可抢矿列表", position = 1, response = Response.class, notes = "查询可抢矿列表")
//    public String getMiningList(
//            @ApiParam(required = true, name = "cityId", value = "城市id")
//            @RequestParam(value = "cityId") Long cityId,
//            @ApiParam(required = true, name = "societyId", value = "公会id,唯一")
//            @RequestParam(value = "societyId") Long societyId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
////            MiningListVo list = miningService.queryMiningList(cityId, societyId);
////            response.setData(list);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (InfServerException ie) {
//            log.error("查询可抢矿列表：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("查询可抢矿列表：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponseContainsNull(method, response);
//        }
//        return JSONUtil.parseJSONContainsNull(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/getMyMiningTimes", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询可抢矿次数", position = 1, response = MiningTimes.class, notes = "查询可抢矿次数")
//    public String getMyMiningTimes(
//            @ApiParam(required = true, name = "userId", value = "玩家id")
//            @RequestParam(value = "userId") Long userId,
//            @ApiParam(required = true, name = "userType", value = "用户类型，主播C，玩家P")
//            @RequestParam(value = "userType") String userType,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
////            MiningTimes times = miningService.queryMiningTimes(userId, userType);
////            response.setData(times);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (InfServerException ie) {
//            log.error("查询可抢矿次数：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("查询可抢矿次数：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponseContainsNull(method, response);
//        }
//        return JSONUtil.parseJSONContainsNull(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/getMiningDetail", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询采矿活动详情", position = 1, response = Response.class, notes = "查询采矿活动详情")
//    public String getMiningDetail(
//            @ApiParam(required = true, name = "userId", value = "玩家id")
//            @RequestParam(value = "userId") Long userId,
//            @ApiParam(required = true, name = "activityId", value = "采矿活动id")
//            @RequestParam(value = "activityId") Long activityId,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
////            MiningDetail detail = miningService.queryMiningDetail(userId, activityId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            response.setData(detail);
//        } catch (InfServerException ie) {
//            log.error("查询采矿活动详情：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("查询采矿活动详情：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponseContainsNull(method, response);
//        }
//        return JSONUtil.parseJSONContainsNull(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/startMining", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "开始抢矿", position = 1, response = Response.class, notes = "开始抢矿")
//    public String startMining(
//            @ApiParam(required = true, name = "userId", value = "玩家id")
//            @RequestParam(value = "userId") Long userId,
//            @ApiParam(required = true, name = "activityId", value = "采矿活动id")
//            @RequestParam(value = "activityId") Long activityId,
//            @ApiParam(required = true, name = "mineSectionId", value = "矿坑id")
//            @RequestParam(value = "mineSectionId") Long mineSectionId,
//            @ApiParam(required = true, name = "userType", value = "用户类型，主播C，玩家P")
//            @RequestParam(value = "userType") String userType,
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
//            @RequestParam(required = false, value = "interfaceType") String interfaceType,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
////            List<MiningResultVo> resultVos = miningService.startMining(userId, activityId, mineSectionId, userType);
////            MiningDetail detail = miningService.queryMiningDetail(userId, activityId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            response.setData(resultVos);
//        } catch (InfServerException ie) {
//            log.error("开始抢矿：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//        } catch (Exception e) {
//            log.error("开始抢矿：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//        }
//        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//            return CommonUtil.buildJSONPResponseContainsNull(method, response);
//        }
//        return JSONUtil.parseJSONContainsNull(response);
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/battleResult", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "抢矿战斗", httpMethod = "POST", position = 1, response = Response.class, notes = "抢矿战斗")
//    public String battleResult(
//            @ApiParam(required = true, name = "userId", value = "玩家id")
//            @RequestParam(value = "userId") Long userId,
//            @ApiParam(required = true, name = "activityId", value = "采矿活动id")
//            @RequestParam(value = "activityId") Long activityId,
//            @ApiParam(required = true, name = "userType", value = "用户类型，主播C，玩家P")
//            @RequestParam(value = "userType") String userType,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
////            BattleResult result = miningService.battleResult(userId, activityId, userType);
////            vo.setData(result);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("抢矿战斗：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("抢矿战斗：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/dig", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "挖矿", httpMethod = "POST", position = 1, response = Response.class, notes = "挖矿")
//    public String dig(
//            @ApiParam(required = true, name = "userId", value = "玩家id")
//            @RequestParam(value = "userId") Long userId,
//            @ApiParam(required = true, name = "activityId", value = "采矿活动id")
//            @RequestParam(value = "activityId") Long activityId,
//            @ApiParam(required = true, name = "mineSectionId", value = "矿坑id")
//            @RequestParam(value = "mineSectionId") Long mineSectionId,
//            @ApiParam(required = true, name = "userType", value = "用户类型，主播C，玩家P")
//            @RequestParam(value = "userType") String userType,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
////            MiningDig result = miningService.dig(userId, activityId, mineSectionId, userType);
////            vo.setData(result);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("挖矿：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("挖矿：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
////    @ResponseBody
////    @RequestMapping(value = "society/finishDig", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "结束挖矿", httpMethod = "POST", position = 1, response = Response.class)
////    public String finishDig(
////            @ApiParam(required = true, name = "userId", value = "玩家id")
////            @RequestParam(value = "userId") Long userId,
////            @ApiParam(required = true, name = "activityId", value = "采矿活动id")
////            @RequestParam(value = "activityId") Long activityId,
////            @ApiParam(required = true, name = "mineSectionId", value = "矿坑id")
////            @RequestParam(value = "mineSectionId") Long mineSectionId,
////            HttpServletRequest request) {
////        Response vo = new Response();
////        try {
////            MiningDig result = miningService.dig(userId, activityId, mineSectionId);
////            vo.setData(result);
////            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSONUtil.parseJSONContainsNull(vo);
////        } catch (InfServerException ie) {
////            ie.printStackTrace();
////            vo.setReturnCode(ie.getErrorCode());
////            vo.setError(ie.getErrorMsg());
////            return JSONUtil.parseJSONContainsNull(vo);
////        } catch (Exception e) {
////            e.printStackTrace();
////            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSONUtil.parseJSONContainsNull(vo);
////        }
////    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/releaseSection", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "释放矿坑", httpMethod = "POST", position = 1, response = Response.class)
//    public String releaseSection(
//            @ApiParam(required = true, name = "mineSectionId", value = "矿坑id")
//            @RequestParam(value = "mineSectionId") Long mineSectionId,
//            @ApiParam(required = true, name = "activityId", value = "采矿活动id")
//            @RequestParam(value = "activityId") Long activityId,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
////            miningService.releaseSection(mineSectionId, activityId);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("释放矿坑：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("释放矿坑：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/hasDefender", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查看是否有防守玩家", httpMethod = "POST", position = 1, response = Response.class)
//    public String hasDefender(
//            @ApiParam(required = true, name = "activityId", value = "采矿活动id")
//            @RequestParam(value = "activityId") Long activityId,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
////            boolean hasDefender = miningService.hasDefender(activityId);
//            HasDefender has = new HasDefender();
////            has.setHasDefender(hasDefender);
//            vo.setData(has);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("查看是否有防守玩家：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("查看是否有防守玩家：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/queryMaxFightRound", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "采矿最大战斗回合数", httpMethod = "POST", position = 1, response = Response.class)
//    public String queryMaxFightRound(
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
////            Integer maxRound = miningService.queryMaxFightRound();
////            vo.setData(maxRound);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("采矿最大战斗回合数：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("采矿最大战斗回合数：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/boomMine", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "爆矿测试接口", httpMethod = "POST", position = 1, response = Response.class)
//    public String boomMine(
//            @ApiParam(required = true, name = "societyId", value = "公会id,唯一")
//            @RequestParam(value = "societyId") Long societyId,
//            @ApiParam(required = true, name = "fullAmount", value = "爆矿金额")
//            @RequestParam(value = "fullAmount") Long fullAmount,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
////            miningService.boomMine(societyId, fullAmount);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("爆矿测试接口：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("爆矿测试接口：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/enterMiningActivity", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "进入采矿活动界面", httpMethod = "POST", position = 1, response = Response.class)
//    public String enterMiningActivity(
//            @ApiParam(required = true, name = "activityId", value = "采矿活动id,唯一")
//            @RequestParam(value = "activityId") Long activityId,
//            @ApiParam(required = true, name = "userId", value = "玩家id")
//            @RequestParam(value = "userId") Long userId,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
////            miningService.enterMiningActivity(activityId, userId);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("进入采矿活动界面：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("进入采矿活动界面：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/exitMiningActivity", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "退出采矿活动界面", httpMethod = "POST", position = 1, response = Response.class)
//    public String exitMiningActivity(
//            @ApiParam(required = true, name = "activityId", value = "采矿活动id,唯一")
//            @RequestParam(value = "activityId") Long activityId,
//            @ApiParam(required = true, name = "userId", value = "玩家id")
//            @RequestParam(value = "userId") Long userId,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
////            miningService.exitMiningActivity(activityId, userId);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("退出采矿活动界面：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("退出采矿活动界面：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/queryAttackerList", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询采矿活动攻击人员列表", httpMethod = "POST", position = 1, response = Response.class)
//    public String queryAttackerList(
//            @ApiParam(required = true, name = "activityId", value = "采矿活动id,唯一")
//            @RequestParam(value = "activityId") Long activityId,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
////            List<CacheUserProfile> list = miningService.queryAttackerList(activityId);
////            vo.setData(list);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("查询采矿活动攻击人员列表：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("查询采矿活动攻击人员列表：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "society/queryDefenderList", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询公会防守人员列表", httpMethod = "POST", position = 1, response = Response.class)
//    public String queryDefenderList(
//            @ApiParam(required = true, name = "societyId", value = "公会id,唯一")
//            @RequestParam(value = "societyId") Long societyId,
//            HttpServletRequest request) {
//        Response vo = new Response();
//        try {
////            List<CacheUserProfile> list = miningService.queryDefenderList(societyId);
////            vo.setData(list);
//            vo.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (InfServerException ie) {
//            log.error("查询公会防守人员列表：", ie);
//            vo.setReturnCode(ie.getErrorCode());
//            vo.setError(ie.getErrorMsg());
//            return JSONUtil.parseJSONContainsNull(vo);
//        } catch (Exception e) {
//            log.error("查询公会防守人员列表：", e);
//            vo.setReturnCode(Constants.RETURN_CODE_FAIL);
//            return JSONUtil.parseJSONContainsNull(vo);
//        }
//    }
//}
