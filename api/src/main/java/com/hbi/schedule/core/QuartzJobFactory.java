package com.hbi.schedule.core;

import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import com.core.util.ApplicationContextHelper;
import com.hbi.schedule.model.ScheduleJob;

public class QuartzJobFactory implements Job {

	@Override
	public void execute(JobExecutionContext context) throws JobExecutionException {
		ScheduleJob scheduleJob = (ScheduleJob) context.getMergedJobDataMap().get("scheduleJob");
		String beanName = scheduleJob.getBeanName();
		Object bean = ApplicationContextHelper.getBean(beanName);
		ScheduleJobInf job= (ScheduleJobInf)bean;
		job.executeSchedule(scheduleJob.getMethodType(), scheduleJob.getData());
//		if (bean instanceof DatingActivityScheduleService) {
//			((DatingActivityScheduleService) bean).executeSchedule(scheduleJob.getMethodType(), scheduleJob.getData());
//		} else if (bean instanceof BoomMineScheduleService) {
//            ((BoomMineScheduleService) bean).executeSchedule(scheduleJob.getMethodType(), scheduleJob.getData());
//        } else if (bean instanceof ReleaseCaptureService) {
//            ((ReleaseCaptureService) bean).executeSchedule(scheduleJob.getMethodType(), scheduleJob.getData());
//        }
	}

}
