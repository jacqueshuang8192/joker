//package com.hbi.controller.rongcloud;
//
//import com.alibaba.druid.sql.visitor.functions.Now;
//import com.alibaba.fastjson.JSON;
//import com.core.util.UUIDUtils;
//import com.hbi.constants.Constants;
//import com.hbi.controller.common.BaseDataController;
//import com.hbi.model.TGameProvince;
//import com.hbi.model.TRongcloudServer;
//import com.hbi.service.rongcloud.TRongcloudServerService;
//import com.hbi.vo.response.Response;
//import com.wordnik.swagger.annotations.Api;
//import com.wordnik.swagger.annotations.ApiOperation;
//import com.wordnik.swagger.annotations.ApiParam;
//import io.rong.RongCloud;
//import io.rong.models.*;
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.scheduling.annotation.Scheduled;
//import org.springframework.stereotype.Controller;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RequestMethod;
//import org.springframework.web.bind.annotation.RequestParam;
//import org.springframework.web.bind.annotation.ResponseBody;
//
//import javax.servlet.http.HttpServletRequest;
//import java.util.ArrayList;
//import java.util.Date;
//import java.util.List;
//
///**
// * Created by muzi on 2017/6/23.
// */
//@Api(basePath = "/", value = "融云服务器的相关接口", position = 2)
//@Controller
//public class CreateRoomByRoonCloud {
//    private static final Log log = LogFactory.getLog(BaseDataController.class);
//    @Autowired
//    private TRongcloudServerService rongcloudServerService;
//
//    @ResponseBody
//    @ApiOperation(value = "获取游戏用户的token", response = String.class, notes = "获取游戏用户的token")
//    @RequestMapping(value = "rongCloud/getUserToken", method = { RequestMethod.GET, RequestMethod.POST }, produces = "application/json; charset=utf-8")
//    public String getUserToken(
//            @ApiParam(required = true, name = "appKey", value = "融云的Key") @RequestParam(value = "appKey") String appKey,
//            @ApiParam(required = true, name = "appSecret", value = "融云的Secret") @RequestParam(value = "appSecret") String appSecret,
//            @ApiParam(required = true, name = "userId", value = "userId") @RequestParam(value = "userId") String userId,
//            @ApiParam(required = true, name = "userName", value = "userName") @RequestParam(value = "userName") String userName,
//            HttpServletRequest request) {
//        Response response = new Response();
//        TRongcloudServer tRongcloudServer = new TRongcloudServer();
//        try {
//            RongCloud rongCloud = RongCloud.getInstance(appKey, appSecret);
//            TokenResult token = rongCloud.user.getToken(userId, userName, "http://www.rongcloud.cn/images/logo.png");
//            rongcloudServerService.updateToken(userId,token.getToken());
//            return token.toString();
//        }catch (Exception e){
//            response.setReturnCode(com.hbi.constants.Constants.RETURN_CODE_FAIL);
//            response.setError(e.getMessage());
//        }
//
//        return JSON.toJSONString(response);
//        //return null;
//    }
//
//    @ResponseBody
//    @ApiOperation(value = "你发一个省份ID给我,我给你这个省的三大频道的room_id", response = String.class, notes = "你发一个省份ID给我,我给你这个省的三大频道的room_id")
//    @RequestMapping(value = "rongCloud/getRoomIdsByProvinceBig", method = { RequestMethod.GET, RequestMethod.POST }, produces = "application/json; charset=utf-8")
//    public String getRoomIdsByProvinceBig(
//            @ApiParam(required = true, name = "provinceId", value = "provinceId") @RequestParam(required = true ,value = "provinceId") String provinceId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try{
//            if(provinceId == null || provinceId == ""){
//                response.setError(Constants.RETURN_CODE_FAIL);
//                response.setError("请输入一个有效的省份id");
//                return JSON.toJSONString(response);
//            }
//            List<TRongcloudServer> list = rongcloudServerService.getAllProvinceIds(provinceId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(list);
//        }catch (Exception e) {
//            response.setReturnCode(com.hbi.constants.Constants.RETURN_CODE_FAIL);
//            response.setError(e.getMessage());
//        }
//        return JSON.toJSONString(response);
//        //return null;
//    }
//
//    @ResponseBody
//    @ApiOperation(value = "查看所有房间的信息", response = String.class, notes = "查看所有房间的信息")
//    @RequestMapping(value = "rongCloud/getRoomIds", method = { RequestMethod.GET, RequestMethod.POST }, produces = "application/json; charset=utf-8")
//    public String getRoomIds(
//            @ApiParam(required = false, name = "provinceId", value = "provinceId") @RequestParam(required = false ,value = "provinceId") String provinceId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try{
//            List<TRongcloudServer> list = rongcloudServerService.getAllRoom(provinceId);
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//            response.setData(list);
//        }catch (Exception e) {
//            response.setReturnCode(com.hbi.constants.Constants.RETURN_CODE_FAIL);
//            response.setError(e.getMessage());
//        }
//        return JSON.toJSONString(response);
//        //return null;
//    }
//
//
//    @ResponseBody
//    @ApiOperation(value = "根据省份创建一系列房间", response = String.class, notes = "根据省份创建一系列房间")
//    @RequestMapping(value = "rongCloud/createRongCloudRoomByProvince", method = { RequestMethod.GET, RequestMethod.POST }, produces = "application/json; charset=utf-8")
//    public String createRongCloudRoomByProvince(
//            @ApiParam(required = true, name = "appKey", value = "融云的Key") @RequestParam(value = "appKey") String appKey,
//            @ApiParam(required = true, name = "appSecret", value = "融云的Secret") @RequestParam(value = "appSecret") String appSecret,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            rongcloudServerService.deleteOrderDate();
//            List<TGameProvince> list = rongcloudServerService.getAllProvince();
//            RongCloud rongCloud = RongCloud.getInstance(appKey, appSecret);
//            List<ChatRoomInfo> roomList = new ArrayList<ChatRoomInfo>();
//            for (TGameProvince province : list) {
//                int y = 1001;
//                for (int i = 1; i <= 3; i++) {
//                    TRongcloudServer tRongcloudServer = new TRongcloudServer();
//                    String roomName = province.getProvinceName() + "频道" + i;
//                    tRongcloudServer.setRoomName(roomName);
//                    String roomId = UUIDUtils.getUUID();
//                    tRongcloudServer.setRoomId(roomId);
//                    tRongcloudServer.setProvinceId(province.getProvinceId().toString() + y);
//                    rongcloudServerService.insertRoom(tRongcloudServer);
//                    y++;
//                    ChatRoomInfo chatRoomInfo = new ChatRoomInfo(roomId, roomName);
//                    roomList.add(chatRoomInfo);
//                }
//            }
//            ChatRoomInfo[] arrays = new ChatRoomInfo[roomList.size()];
//            String[] roomId = new String[roomList.size()];
//            for (int i = 0; i < roomList.size(); i++) {
//                arrays[i] = roomList.get(i);
//                roomId[i] = roomList.get(i).getId();
//            }
//            CodeSuccessResult codeSuccessResult = rongCloud.chatroom.create(arrays);
//            ChatroomQueryResult query = rongCloud.chatroom.query(roomId);
//            return query.toString();
//        }catch (Exception e) {
//            response.setReturnCode(com.hbi.constants.Constants.RETURN_CODE_FAIL);
//            response.setError(e.getMessage());
//        }
//        return JSON.toJSONString(response);
//        //return null;
//    }
//
//    @ResponseBody
//    @ApiOperation(value = "新增一个指定的房间", response = String.class, notes = "新增一个指定的房间")
//    @RequestMapping(value = "rongCloud/createRoomByMe", method = { RequestMethod.GET, RequestMethod.POST }, produces = "application/json; charset=utf-8")
//    public String createRoomByMe(
//            @ApiParam(required = true, name = "appKey", value = "融云的Key") @RequestParam(value = "appKey") String appKey,
//            @ApiParam(required = true, name = "appSecret", value = "融云的Secret") @RequestParam(value = "appSecret") String appSecret,
//            @ApiParam(required = true, name = "provinceId", value = "provinceId") @RequestParam(value = "provinceId") String provinceId,
//            @ApiParam(required = true, name = "room_name", value = "room_name") @RequestParam(value = "room_name") String room_name,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try{
//            RongCloud rongCloud = RongCloud.getInstance(appKey, appSecret);
//            String room_id = UUIDUtils.getUUID();
//            CodeSuccessResult codeSuccessResult = rongCloud.chatroom.create(new ChatRoomInfo[]{new ChatRoomInfo(room_id, room_name)});
//            TRongcloudServer rongcloudServer = new TRongcloudServer();
//            rongcloudServer.setRoomId(room_id);
//            rongcloudServer.setRoomName(room_name);
//            rongcloudServer.setProvinceId(provinceId);
//            rongcloudServerService.insertRoom(rongcloudServer);
//            return codeSuccessResult.toString();
//        }catch (Exception e) {
//            response.setReturnCode(com.hbi.constants.Constants.RETURN_CODE_FAIL);
//            response.setError(e.getMessage());
//        }
//        return JSON.toJSONString(response);
//        //return null;
//    }
//
//    @ResponseBody
//    @ApiOperation(value = "销毁一个房间", response = String.class, notes = "销毁一个房间")
//    @RequestMapping(value = "rongCloud/destoryByRoom_id", method = { RequestMethod.GET, RequestMethod.POST }, produces = "application/json; charset=utf-8")
//    public String destoryByRoom_id(
//            @ApiParam(required = true, name = "appKey", value = "融云的Key") @RequestParam(value = "appKey") String appKey,
//            @ApiParam(required = true, name = "appSecret", value = "融云的Secret") @RequestParam(value = "appSecret") String appSecret,
//            @ApiParam(required = true, name = "room_id", value = "room_id") @RequestParam(value = "room_id") String room_id,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try{
//            RongCloud rongCloud = RongCloud.getInstance(appKey, appSecret);
//            CodeSuccessResult destroy = rongCloud.chatroom.destroy(new String[]{room_id});
//            rongcloudServerService.deleteByRoom_id(room_id);
//            return destroy.toString();
//        }catch (Exception e) {
//            response.setReturnCode(com.hbi.constants.Constants.RETURN_CODE_FAIL);
//            response.setError(e.getMessage());
//        }
//        return JSON.toJSONString(response);
//        //return null;
//    }
//
//    @ResponseBody
//    @ApiOperation(value = "查询聊天室内的用户", response = String.class, notes = "查询聊天室内的用户")
//    @RequestMapping(value = "rongCloud/getUserByRoom", method = { RequestMethod.GET, RequestMethod.POST }, produces = "application/json; charset=utf-8")
//    public String getUserByRoom(
//            @ApiParam(required = true, name = "appKey", value = "融云的Key") @RequestParam(value = "appKey") String appKey,
//            @ApiParam(required = true, name = "appSecret", value = "融云的Secret") @RequestParam(value = "appSecret") String appSecret,
//            @ApiParam(required = true, name = "room_id", value = "room_id") @RequestParam(value = "room_id") String room_id,
//            @ApiParam(required = false, name = "order", value = "加入聊天室的先后顺序,1为加入时间正序,2为加入时间倒序,默认为1") @RequestParam(value = "order") String order,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try{
//            RongCloud rongCloud = RongCloud.getInstance(appKey, appSecret);
//            if (order == null || order == "") {
//                order = "1";
//            }
//            ChatroomUserQueryResult result = rongCloud.chatroom.queryUser(room_id, "500", order);
//            return result.toString();
//        }catch (Exception e) {
//            response.setReturnCode(com.hbi.constants.Constants.RETURN_CODE_FAIL);
//            response.setError(e.getMessage());
//        }
//        return JSON.toJSONString(response);
//        //return null;
//    }
//
//    //每50分钟更新加入房间,保持房间不被解散
//    //@Scheduled(cron="0 0/30 * * * ?")
//    public void queryZ() throws Exception {
//        RongCloud rongCloud = RongCloud.getInstance("kj7swf8okhx42", "5e7YoyUBqoNhQ");
//        List<String> list = rongcloudServerService.getRoomList();
//        int i = 1;
//        for (String s : list) {
//            String[] chatroomJoinUserId={i+""};
//            i++;
//            CodeSuccessResult join = rongCloud.chatroom.join(chatroomJoinUserId, s);
//        }
//        System.out.println(new Date() + "------------------------");
//    }
//
//}
