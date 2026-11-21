package com.hbi.controller.groupUnion;

import com.hbi.base.BaseController;
import com.hbi.constants.Constants;
import com.hbi.service.groupunion.GroupUnionService;
import com.hbi.utils.InfServerException;
import com.hbi.vo.response.Response;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.Parameter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import jakarta.servlet.http.HttpServletRequest;

@Tag(name = "联盟联盟相关接口")
@RequestMapping(value = "/group/union")
@Controller
public class GroupUnionController extends BaseController<GroupUnionController> {

    @Autowired
    private GroupUnionService groupUnionService;

    @ResponseBody
    @RequestMapping(value = "/create", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "创建联盟联盟", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String create(
            @Parameter(required = true, name = "unionName", description = "联盟名称") @RequestParam(required = true, value = "unionName") String unionName,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request){
        Response response = new Response();
        try {
            groupUnionService.createGroupUnion(unionName, XYUid);
            response.setData("添加联盟成功");
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        } catch (InfServerException ie) {
            LOGGER.error("添加联盟：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("添加联盟：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.getMessage());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "/addMgr", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "添加副盟主", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String addMgr(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "playerId2", description = "被添加人ID") @RequestParam(required = true, value = "playerId2") Integer playerId2,
            @Parameter(required = true, name = "unionId", description = "联盟ID") @RequestParam(required = true, value = "unionId") Integer unionId,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
        Response response = new Response();
        try {
            groupUnionService.addMgr(unionId, XYUid, playerId2);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("添加副盟主成功");
        } catch (InfServerException ie) {
            LOGGER.error("添加副盟主：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("添加副盟主：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.getMessage());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "/addGroup", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "盟主添加联盟", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String addGroup(
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "unionId", description = "联盟ID") @RequestParam(required = true, value = "unionId") Integer unionId,
            @Parameter(required = true, name = "groupId", description = "被添加的群组ID") @RequestParam(required = true, value = "groupId") Integer groupId,
            @Parameter(required = false, name = "bonus", description = "原联盟盟主分红，默认0，之后可以设置") @RequestParam(required = false, value = "bonus", defaultValue = "0.00") Double bonus,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request){
        Response response = new Response();
        try {
            groupUnionService.addGroup(XYUid, unionId, groupId, bonus);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("盟主添加联盟成功");
        } catch (InfServerException ie) {
            LOGGER.error("添加联盟：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("添加联盟：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.getMessage());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "/setCost", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "设置联盟抽水", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String setCost(
            @Parameter(required = true, name = "unionId", description = "群组ID") @RequestParam(required = true, value = "unionId") Integer unionId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "costPattern", description = "1=>固定抽水  2 => 比例抽水") @RequestParam(required = true, value = "costPattern") Integer costPattern,
            @Parameter(required = true, name = "commission", description = "固定抽水自己定，保留两位小数。比例需要设定0-100%") @RequestParam(required = true, value = "commission") Double commission,
            @Parameter(required = true, name = "costUserType", description = "0=>抽大赢家  1 => 抽赢家") @RequestParam(required = true, value = "costUserType") Integer costUserType,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request){
        Response response = new Response();
        try {
            groupUnionService.setCost(unionId, XYUid, costPattern, commission, costUserType);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("设置联盟抽水成功");
        } catch (InfServerException ie) {
            LOGGER.error("设置联盟抽水：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("设置联盟抽水：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.getMessage());
        }
        return responseJsonString(response, interfaceType);
    }

    @ResponseBody
    @RequestMapping(value = "/setBonus", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @Operation(summary = "设置群组分红，给原群群主设置分红", responses = @ApiResponse(responseCode = "200", content = @Content(schema = @Schema(implementation = Response.class))))
    public String setBonus(
            @Parameter(required = true, name = "unionId", description = "联盟ID") @RequestParam(required = true, value = "unionId") Integer unionId,
            @Parameter(required = true, name = "XYUid", description = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @Parameter(required = true, name = "groupId", description = "群组ID") @RequestParam(required = true, value = "groupId") Integer groupId,
            @Parameter(required = true, name = "bonus", description = "原群群主分红") @RequestParam(required = true, value = "bonus") Double bonus,
            @Parameter(required = false, name = "interfaceType", description = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
            HttpServletRequest request){
        Response response = new Response();
        try {
            groupUnionService.setBonus(XYUid, unionId, groupId, bonus);
            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
            response.setData("设置群组分红成功");
        } catch (InfServerException ie) {
            LOGGER.error("设置群组分红：", ie);
            response.setReturnCode(ie.getErrorCode());
            response.setError(ie.getErrorMsg());
        } catch (Exception e) {
            LOGGER.error("设置群组分红：", e);
            response.setReturnCode(Constants.RETURN_CODE_FAIL);
            response.setError(e.getMessage());
        }
        return responseJsonString(response, interfaceType);
    }
}
