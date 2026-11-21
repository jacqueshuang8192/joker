package com.hbi.controller.groupUnion;

import com.hbi.base.BaseController;
import com.hbi.constants.Constants;
import com.hbi.service.groupunion.GroupUnionService;
import com.hbi.utils.InfServerException;
import com.hbi.vo.response.Response;
import com.wordnik.swagger.annotations.Api;
import com.wordnik.swagger.annotations.ApiOperation;
import com.wordnik.swagger.annotations.ApiParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;

@Api(basePath = "/", value = "联盟联盟相关接口", position = 1)
@RequestMapping(value = "/group/union")
@Controller
public class GroupUnionController extends BaseController<GroupUnionController> {

    @Autowired
    private GroupUnionService groupUnionService;

    @ResponseBody
    @RequestMapping(value = "/create", method = RequestMethod.POST, produces = "application/json; charset=utf-8")
    @ApiOperation(value = "创建联盟联盟", position = 1, response = Response.class)
    public String create(
            @ApiParam(required = true, name = "unionName", value = "联盟名称") @RequestParam(required = true, value = "unionName") String unionName,
            @ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
    @ApiOperation(value = "添加副盟主", position = 2, response = Response.class)
    public String addMgr(
            @ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @ApiParam(required = true, name = "playerId2", value = "被添加人ID") @RequestParam(required = true, value = "playerId2") Integer playerId2,
            @ApiParam(required = true, name = "unionId", value = "联盟ID") @RequestParam(required = true, value = "unionId") Integer unionId,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType){
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
    @ApiOperation(value = "盟主添加联盟", position = 3, response = Response.class)
    public String addGroup(
            @ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @ApiParam(required = true, name = "unionId", value = "联盟ID") @RequestParam(required = true, value = "unionId") Integer unionId,
            @ApiParam(required = true, name = "groupId", value = "被添加的群组ID") @RequestParam(required = true, value = "groupId") Integer groupId,
            @ApiParam(required = false, name = "bonus", value = "原联盟盟主分红，默认0，之后可以设置") @RequestParam(required = false, value = "bonus", defaultValue = "0.00") Double bonus,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
    @ApiOperation(value = "设置联盟抽水", position = 4, response = Response.class)
    public String setCost(
            @ApiParam(required = true, name = "unionId", value = "群组ID") @RequestParam(required = true, value = "unionId") Integer unionId,
            @ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @ApiParam(required = true, name = "costPattern", value = "1=>固定抽水  2 => 比例抽水") @RequestParam(required = true, value = "costPattern") Integer costPattern,
            @ApiParam(required = true, name = "commission", value = "固定抽水自己定，保留两位小数。比例需要设定0-100%") @RequestParam(required = true, value = "commission") Double commission,
            @ApiParam(required = true, name = "costUserType", value = "0=>抽大赢家  1 => 抽赢家") @RequestParam(required = true, value = "costUserType") Integer costUserType,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
    @ApiOperation(value = "设置群组分红，给原群群主设置分红", position = 5, response = Response.class)
    public String setBonus(
            @ApiParam(required = true, name = "unionId", value = "联盟ID") @RequestParam(required = true, value = "unionId") Integer unionId,
            @ApiParam(required = true, name = "XYUid", value = "XYUid") @RequestParam(value = "XYUid") Integer XYUid,
            @ApiParam(required = true, name = "groupId", value = "群组ID") @RequestParam(required = true, value = "groupId") Integer groupId,
            @ApiParam(required = true, name = "bonus", value = "原群群主分红") @RequestParam(required = true, value = "bonus") Double bonus,
            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType,
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
