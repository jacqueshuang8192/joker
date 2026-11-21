package com.hbi.controller.common;

import com.alibaba.fastjson.JSON;
import com.core.controller.BaseController;
import com.core.util.JSONUtil;
import com.hbi.constants.Constants;
//import com.hbi.model.TDataVersion;
import com.hbi.model.TVersion;
import com.hbi.service.common.VersionService;
import com.hbi.utils.CommonUtil;
import com.hbi.utils.InfServerException;
import com.hbi.vo.response.Response;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.Parameter;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

@Tag(name = "版本接口")
@Controller
public class VersionController extends BaseController {

	private static final Log log = LogFactory.getLog(VersionController.class);

	@Autowired
	private VersionService versionService;
	
	@ResponseBody
	@RequestMapping(value = "version/queryVersion", method = {RequestMethod.POST, RequestMethod.GET}, produces = "text/xml; charset=utf-8")
	@Operation(summary = "查询最新版本号", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "查询最新版本号")
	public String queryVersion (
			@Parameter(required = true, name = "type", description = "1：应用；2：游戏大厅；3：游戏") @RequestParam(value = "type") String type,
			@Parameter(required = false, name = "applicationType", description = "应用类型，type为1时，必填。1:IOS主播端;2:IOS玩家端;3:安卓主播端;4:安卓玩家端;5:APP html5;6:官网;7:后台;8:接口") @RequestParam(value = "applicationType", required = false) String applicationType,
			@Parameter(required = false, name = "gameId", description = "游戏ID，type为3时必填") @RequestParam(value = "gameId", required = false) String gameId,
			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
			@RequestParam(required = false, value = "interfaceType") String interfaceType,
			HttpServletRequest request) {
		Response response = new Response();
		try {
		    TVersion version = versionService.queryNewestVersion(type, applicationType, gameId);
			response.setData(version);
		    response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
		} catch (Exception e) {
			log.error("查询最新版本号：", e);
            CommonUtil.BuildErrorResponse(e, response);
        }
		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
			return CommonUtil.buildJSONPResponse(method, response);
		}
		return JSON.toJSONString(response);
	}
	
//	@ResponseBody
//	@RequestMapping(value = "version/downloadRecordsByLevel", method = {RequestMethod.POST, RequestMethod.GET}, produces = "text/xml; charset=utf-8")
//	@Operation(summary = "下载游戏的所有回放", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "查询最新版本号")
//	public String downloadRecordsByLevel (
//			@Parameter(required = true, name = "level", description = "level") @RequestParam(value = "level", required = true) int level,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//			@RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//		    versionService.downloadRecordsByLevel(level);
//		    response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("查询最新版本号：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSON.toJSONString(response);
//	}

//	@ResponseBody
//	@RequestMapping(value = "version/queryBaseDataVersion", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@Operation(summary = "获取基础数据版本", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "获取基础数据版本")
//	public String queryBaseDataVersion (
//			@Parameter(required = true, name = "type", description = "基础数据类型，VIP：vip")
//			@RequestParam(value = "type") String type,
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//			@RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			TDataVersion version = versionService.queryDataVersion(type);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(version);
//		} catch(InfServerException ie){
//			log.error("获取基础数据版本：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("获取基础数据版本：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSONUtil.parseJSONContainsNull(response);
//	}

//	@ResponseBody
//	@RequestMapping(value = "version/queryAllBaseDataVersion", method = {RequestMethod.POST, RequestMethod.GET}, produces = "application/json; charset=utf-8")
//	@Operation(summary = "获取基础数据版本", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))), description = "获取基础数据版本")
//	public String queryAllBaseDataVersion (
//			@Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P")
//			@RequestParam(required = false, value = "interfaceType") String interfaceType,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			List<TDataVersion> version = versionService.queryAllDataVersion();
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(version);
//		} catch(InfServerException ie){
//			log.error("获取基础数据版本：", ie);
//			response.setReturnCode(ie.getErrorCode());
//			response.setError(ie.getErrorMsg());
//		} catch (Exception e) {
//			log.error("获取基础数据版本：", e);
//			response.setReturnCode(Constants.RETURN_CODE_FAIL);
//		}
//		if(Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
//			String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
//			return CommonUtil.buildJSONPResponse(method, response);
//		}
//		return JSONUtil.parseJSONContainsNull(response);
//	}
}
