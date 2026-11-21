//package com.hbi.servlet;
//
//import com.core.util.ApplicationContextHelper;
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//
//import javax.servlet.ServletException;
//import javax.servlet.http.HttpServlet;
//
///**
// * Created by ceeuoo on 3/29/2016.
// */
//public class ScheduleServlet extends HttpServlet {
////    private DynamicScheduleService dynamicScheduleService;
//
//    private static Log log = LogFactory.getLog(ScheduleServlet.class);
//
//    @Override
//    public void init() throws ServletException {
//        super.init();
//        dynamicScheduleService = (DynamicScheduleService) ApplicationContextHelper.getBean("dynamicScheduleService");
//        try {
//            dynamicScheduleService.restartSchedule();
//        } catch (Exception e) {
//            log.error(e.getLocalizedMessage());
//        }
//    }
//}
