//package com.hbi.schedule.service;
//
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.hbi.schedule.core.ScheduleJobInf;
//import com.hbi.service.common.DatingService;
//import com.hbi.utils.CommonUtil;
//
//@Service
//public class DatingActivityScheduleService implements ScheduleJobInf {
//
//	private static final Log log = LogFactory.getLog(DatingActivityScheduleService.class);
//
//	@Autowired
//	private DatingService datingService;
//
//	@Override
//	public void executeSchedule(int methodType, Object obj) {
//		String str = (String) obj;
//		Long datingActivityId = Long.parseLong(str);
//		try {
////		    if (methodType == 1) {
//		        datingService.closeDatingActivity(datingActivityId);
////		    }
//		} catch (Exception e) {
//			log.error(CommonUtil.buildErrorLog(e));
//		}
//	}
//
//}
