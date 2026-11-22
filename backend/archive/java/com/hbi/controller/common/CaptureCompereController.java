//package com.hbi.controller.common;
//
//import java.util.List;
//
//import javax.servlet.http.HttpServletRequest;
//
//import com.hbi.model.*;
//import com.hbi.utils.CommonUtil;
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
//import com.hbi.cache.model.CacheCompereProfile;
//import com.hbi.constants.Constants;
//import com.hbi.service.common.CaptureCompereService;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.wordnik.swagger.annotations.Api;
//import com.wordnik.swagger.annotations.ApiOperation;
//import com.wordnik.swagger.annotations.ApiParam;
//
////@Api(basePath = "/captureCompere", value = "抓主播接口", position = 1)
////@Controller
////public class CaptureCompereController extends BaseController{
//
////    private static final Log log = LogFactory.getLog(CaptureCompereController.class);
////
////    @Autowired
////    private CaptureCompereService captureService;
////
////    @ResponseBody
////    @RequestMapping(value = "/captureCompere/getCompereCaptureStatus", method = {RequestMethod.POST}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "查看主播的被抓状态", position = 1, response = Response.class, notes = "查看主播的被抓状态接口")
////    public String getCompereCaptureStatus(
////            @ApiParam(required = true, name = "compereId", value = "主播id")
////            @RequestParam(value = "compereId") Long compereId,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            CaptureInfo info = captureService.getCompereCaptureStatus(compereId);
////            response.setData(info);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch(InfServerException ie){
////            log.error("查看主播的被抓状态：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch (Exception e) {
////            log.error("查看主播的被抓状态：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSONUtil.parseJSONContainsNull(response);
////        }
////    }
////
////    @ResponseBody
////    @RequestMapping(value = "/captureCompere/getRansomDetail", method = {RequestMethod.POST}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "查看主播赎身详情", position = 1, response = Response.class)
////    public String getRansomDetail(
////            @ApiParam(required = true, name = "compereId", value = "主播id")
////            @RequestParam(value = "compereId") Long compereId,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            RansomInfo info = captureService.getRansomDetail(compereId);
////            response.setData(info);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch(InfServerException ie){
////            log.error("查看主播赎身详情：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch (Exception e) {
////            log.error("查看主播赎身详情：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSONUtil.parseJSONContainsNull(response);
////        }
////    }
////
////    @ResponseBody
////    @RequestMapping(value = "/captureCompere/getMyDefendCompere", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "查看我的守护", position = 1, response = Response.class)
////    public String getMyDefendCompere(
////            @ApiParam(required = true, name = "playerId", value = "玩家id")
////            @RequestParam(value = "playerId") Long playerId,
////            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
////            @RequestParam(required = false, value = "interfaceType") String interfaceType,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            List<TCaptureDefender> info = captureService.getMyDefendCompere(playerId);
////            response.setData(info);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////        } catch(InfServerException ie){
////            log.error("查看我的守护：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////        } catch (Exception e) {
////            log.error("查看我的守护：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////        }
////        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
////            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
////            return CommonUtil.buildJSONPResponseContainsNull(method, response);
////        }
////        return JSONUtil.parseJSONContainsNull(response);
////    }
////
////    @ResponseBody
////    @RequestMapping(value = "/captureCompere/getMyDefendPlayer", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "查看守护我的玩家", position = 1, response = Response.class)
////    public String getMyDefendPlayer(
////            @ApiParam(required = true, name = "compereId", value = "主播id")
////            @RequestParam(value = "compereId") Long compereId,
////            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
////            @RequestParam(required = false, value = "interfaceType") String interfaceType,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            List<TCaptureDefender> info = captureService.getMyDefendPlayer(compereId);
////            response.setData(info);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////        } catch(InfServerException ie){
////            log.error("查看守护我的玩家：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////        } catch (Exception e) {
////            log.error("查看守护我的玩家：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////        }
////        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
////            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
////            return CommonUtil.buildJSONPResponseContainsNull(method, response);
////        }
////        return JSONUtil.parseJSONContainsNull(response);
////    }
////
////    @ResponseBody
////    @RequestMapping(value = "/captureCompere/getMyWives", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "查看我的后宫", position = 1, response = Response.class)
////    public String getMyWives(
////            @ApiParam(required = true, name = "playerId", value = "玩家id")
////            @RequestParam(value = "playerId") Long playerId,
////            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
////            @RequestParam(required = false, value = "interfaceType") String interfaceType,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            List<CacheCompereProfile> info = captureService.getMyWives(playerId);
////            response.setData(info);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////        } catch(InfServerException ie){
////            log.error("查看我的后宫：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////        } catch (Exception e) {
////            log.error("查看我的后宫：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////        }
////        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
////            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
////            return CommonUtil.buildJSONPResponseContainsNull(method, response);
////        }
////        return JSONUtil.parseJSONContainsNull(response);
////    }
////
////    @ResponseBody
////    @RequestMapping(value = "/captureCompere/releaseCompere", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "释放主播", position = 1, response = Response.class)
////    public String releaseCompere(
////            @ApiParam(required = true, name = "compereId", value = "主播id")
////            @RequestParam(value = "compereId") Long compereId,
////            @ApiParam(required = true, name = "playerId", value = "玩家id")
////            @RequestParam(value = "playerId") Long playerId,
////            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
////            @RequestParam(required = false, value = "interfaceType") String interfaceType,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            captureService.releaseCompere(playerId, compereId);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////        } catch(InfServerException ie){
////            log.error("释放主播：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////        } catch (Exception e) {
////            log.error("释放主播：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////        }
////        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
////            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
////            return CommonUtil.buildJSONPResponseContainsNull(method, response);
////        }
////        return JSONUtil.parseJSONContainsNull(response);
////    }
////
////    @ResponseBody
////    @RequestMapping(value = "/captureCompere/useRansomCard", method = {RequestMethod.POST}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "使用赎身卡", position = 1, response = Response.class)
////    public String useRansomCard(
////            @ApiParam(required = true, name = "compereId", value = "主播id")
////            @RequestParam(value = "compereId") Long compereId,
////            @ApiParam(required = true, name = "playerId", value = "玩家id")
////            @RequestParam(value = "playerId") Long playerId,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            UseRansomInfo info = captureService.useRansomCard(playerId, compereId);
////            response.setData(info);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch(InfServerException ie){
////            log.error("使用赎身卡：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch (Exception e) {
////            log.error("使用赎身卡：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSONUtil.parseJSONContainsNull(response);
////        }
////    }
////
////    @ResponseBody
////    @RequestMapping(value = "/captureCompere/enterFightPage", method = {RequestMethod.POST}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "进入战斗页面", position = 1, response = Response.class)
////    public String enterFightPage(
////            @ApiParam(required = true, name = "compereId", value = "主播id")
////            @RequestParam(value = "compereId") Long compereId,
////            @ApiParam(required = true, name = "playerId", value = "玩家id")
////            @RequestParam(value = "playerId") Long playerId,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            CaptureFightInfo info = captureService.enterFightPage(compereId, playerId);
////            response.setData(info);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch(InfServerException ie){
////            log.error("进入战斗页面：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch (Exception e) {
////            log.error("进入战斗页面：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSONUtil.parseJSONContainsNull(response);
////        }
////    }
////
////    @ResponseBody
////    @RequestMapping(value = "/captureCompere/startFighting", method = {RequestMethod.POST}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "开始战斗", position = 1, response = Response.class)
////    public String startFighting(
////            @ApiParam(required = true, name = "compereId", value = "主播id")
////            @RequestParam(value = "compereId") Long compereId,
////            @ApiParam(required = true, name = "playerId", value = "玩家id")
////            @RequestParam(value = "playerId") Long playerId,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            CaptureFightInfo info = captureService.startFighting(compereId, playerId);
////            response.setData(info);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch(InfServerException ie){
////            log.error("开始战斗：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch (Exception e) {
////            log.error("开始战斗：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSONUtil.parseJSONContainsNull(response);
////        }
////    }
////
////    @ResponseBody
////    @RequestMapping(value = "/captureCompere/fightRound", method = {RequestMethod.POST}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "战斗一回合", position = 1, response = Response.class)
////    public String fightRound(
////            @ApiParam(required = true, name = "compereId", value = "主播id")
////            @RequestParam(value = "compereId") Long compereId,
////            @ApiParam(required = true, name = "playerId", value = "玩家id")
////            @RequestParam(value = "playerId") Long playerId,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            CaptureFightInfo info = captureService.fightRound(compereId, playerId);
////            response.setData(info);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch(InfServerException ie){
////            log.error("战斗一回合：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch (Exception e) {
////            log.error("战斗一回合：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSONUtil.parseJSONContainsNull(response);
////        }
////    }
////
////    @ResponseBody
////    @RequestMapping(value = "/captureCompere/castSpell", method = {RequestMethod.POST}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "使用技能", position = 1, response = Response.class)
////    public String castSpell(
////            @ApiParam(required = true, name = "compereId", value = "主播id")
////            @RequestParam(value = "compereId") Long compereId,
////            @ApiParam(required = true, name = "playerId", value = "玩家id")
////            @RequestParam(value = "playerId") Long playerId,
////            @ApiParam(required = true, name = "spellId", value = "技能id")
////            @RequestParam(value = "spellId") Long spellId,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            CaptureFightInfo info = captureService.castSpell(compereId, playerId, spellId);
////            response.setData(info);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch(InfServerException ie){
////            log.error("使用技能：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch (Exception e) {
////            log.error("使用技能：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSONUtil.parseJSONContainsNull(response);
////        }
////    }
////
////    @ResponseBody
////    @RequestMapping(value = "/captureCompere/buyCaptureFightTime", method = {RequestMethod.POST}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "购买抢主播战斗次数", position = 1, response = Response.class)
////    public String buyCaptureFightTime(
////            @ApiParam(required = true, name = "playerId", value = "玩家id")
////            @RequestParam(value = "playerId") Long playerId,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            Integer times = captureService.buyCaptureFightTime(playerId);
////            response.setData(times);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch(InfServerException ie){
////            log.error("购买抢主播战斗次数：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////            return JSONUtil.parseJSONContainsNull(response);
////        } catch (Exception e) {
////            log.error("购买抢主播战斗次数：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////            return JSONUtil.parseJSONContainsNull(response);
////        }
////    }
////
////    @ResponseBody
////    @RequestMapping(value = "/captureCompere/modifyTitle", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
////    @ApiOperation(value = "修改后宫称谓", position = 1, response = Response.class)
////    public String modifyTitle(
////            @ApiParam(required = true, name = "compereId", value = "主播id")
////            @RequestParam(value = "compereId") Long compereId,
////            @ApiParam(required = true, name = "title", value = "称号")
////            @RequestParam(value = "title") String title,
////            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P")
////            @RequestParam(required = false, value = "interfaceType") String interfaceType,
////            HttpServletRequest request) {
////        Response response = new Response();
////        try {
////            captureService.modifyTitle(compereId, title);
////            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
////        } catch(InfServerException ie){
////            log.error("修改后宫称谓：", ie);
////            response.setReturnCode(ie.getErrorCode());
////            response.setError(ie.getErrorMsg());
////        } catch (Exception e) {
////            log.error("修改后宫称谓：", e);
////            response.setReturnCode(Constants.RETURN_CODE_FAIL);
////        }
////        if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
////            String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
////            return CommonUtil.buildJSONPResponseContainsNull(method, response);
////        }
////        return JSONUtil.parseJSONContainsNull(response);
////    }
////}
