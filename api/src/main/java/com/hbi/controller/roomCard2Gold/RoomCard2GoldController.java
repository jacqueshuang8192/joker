//package com.hbi.controller.roomCard2Gold;
//
//import com.hbi.constants.Constants;
//import com.hbi.service.Gold.GoldService;
//import com.hbi.service.roomCard2Gold.RoomCard2GoldService;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
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
//@Api(basePath = "/roomCard2Gold", value = "房卡房卡转换", position = 1)
//@RequestMapping(value = "roomCard2Gold")
//@Controller
//public class RoomCard2GoldController {
//
//    private static final Logger LOGGER = Logger.getLogger(RoomCard2GoldController.class);
//    @Autowired
//    private RoomCard2GoldService roomCard2GoldService;
//
//
//    @ResponseBody
//    @RequestMapping(value = "changeByRoomCardAndGold", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "房卡和金币兑换", position = 2, response = Response.class)
//    public Response changeByRoomCardAndGold(
//            @ApiParam(required = true, name = "playerId", value = "玩家ID") @RequestParam(required = true, value = "playerId") Long playerId,
//            @ApiParam(required = true, name = "category_type", value = "转换类型  2 : 房卡转金币   3 : 金币转房卡") @RequestParam(required = true, value = "category_type") Integer category_type,
//            @ApiParam(required = true, name = "count", value = "数量") @RequestParam(required = true, value = "count") Long count,
//
//            @ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType, HttpServletRequest request) {
//        Response response = new Response();
//        try {
//
//            roomCard2GoldService.changeByRoomCardAndGold(playerId,category_type,count);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData("兑换成功!!");
//            return response;
//        } catch (InfServerException ie) {
//            LOGGER.error("房卡和金币兑换：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//            return response;
//        } catch (Exception e) {
//            LOGGER.error("房卡和金币兑换：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//            return response;
//        }
//    }
//
//    @ResponseBody
//    @RequestMapping(value = "queryMinGold2Card", method = { RequestMethod.POST, RequestMethod.GET }, produces = "application/json; charset=utf-8")
//    @ApiOperation(value = "查询最小的兑换金币数量", position = 2, response = Response.class)
//    public Response queryMinGold2Card(@ApiParam(required = false, name = "interfaceType", value = "接口类型，JSON传J，JSONP传P") @RequestParam(required = false, value = "interfaceType") String interfaceType, HttpServletRequest request) {
//        Response response = new Response();
//        try {
//
//            Integer minGold =  roomCard2GoldService.queryMinGold2Card();
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(minGold);
//            return response;
//        } catch (InfServerException ie) {
//            LOGGER.error("查询最小的兑换金币数量：", ie);
//            response.setReturnCode(ie.getErrorCode());
//            response.setError(ie.getErrorMsg());
//            return response;
//        } catch (Exception e) {
//            LOGGER.error("查询最小的兑换金币数量：", e);
//            response.setReturnCode(Constants.RETURN_CODE_FAIL);
//            response.setError(e.toString());
//            return response;
//        }
//    }
//
//}
