//package com.hbi.servlet;
//
//import java.util.List;
//
//import javax.servlet.ServletException;
//import javax.servlet.http.HttpServlet;
//
//import org.apache.commons.collections.CollectionUtils;
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//
//import com.core.util.ApplicationContextHelper;
//import com.hbi.cache.model.CacheRoomListProfile;
//import com.hbi.service.common.RoomService;
//
//public class LiveRoomServlet extends HttpServlet {
//
//    /**
//     *
//     */
//    private static final long serialVersionUID = 1L;
//
//    private static Log log = LogFactory.getLog(LiveRoomServlet.class);
//
//    private RoomService roomService;
//
//
//    @Override
//    public void init() throws ServletException {
//        super.init();
//        roomService = (RoomService) ApplicationContextHelper.getBean("roomService");
//        try {
//            List<CacheRoomListProfile> rooms = roomService.queryAllNotClosedRooms();
//            if (CollectionUtils.isNotEmpty(rooms)) {
//                for (CacheRoomListProfile room : rooms) {
//                    roomService.closeRoom(room.getCityId(), room.getRoomId(), room.getCompereId());
//                }
//            }
//        } catch (Exception e) {
//            log.error(e.getLocalizedMessage());
//        }
//    }
//
//}
