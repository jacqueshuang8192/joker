//package com.hbi.schedule.service;
//
//import com.hbi.mapper.TScheduleMapper;
//import com.hbi.model.TSchedule;
//import com.hbi.schedule.utils.ScheduleUtil;
//import com.hbi.service.idGenerate.GenerateIdService;
//import org.quartz.*;
//import org.springframework.beans.BeanUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.scheduling.quartz.SchedulerFactoryBean;
//import org.springframework.stereotype.Service;
//
//import com.hbi.schedule.core.QuartzJobFactory;
//import com.hbi.schedule.model.ScheduleJob;
//import tk.mybatis.mapper.entity.Example;
//
//import java.util.Date;
//import java.util.List;
//
//@Service
//public class DynamicScheduleService {
//
//	@Autowired
//	private SchedulerFactoryBean schedulerFactoryBean;
//	@Autowired
//	private GenerateIdService idService;
//	@Autowired
//	private TScheduleMapper scheduleMapper;
//
//	public void enableSchedule(ScheduleJob job) throws Exception {
//		ScheduleUtil.invokeEnableScheduleServlet(job);
////		Scheduler scheduler = schedulerFactoryBean.getScheduler();
////		TriggerKey triggerKey = TriggerKey.triggerKey(job.getJobId(), job.getJobGroup());
////		// 获取trigger，即在spring配置文件中定义的 bean id="myTrigger"
////		CronTrigger trigger = (CronTrigger) scheduler.getTrigger(triggerKey);
////		// 不存在，创建一个
////		if (null == trigger) {
////			JobDetail jobDetail = JobBuilder.newJob(QuartzJobFactory.class)
////					.withIdentity(job.getJobId(), job.getJobGroup()).build();
////			jobDetail.getJobDataMap().put("scheduleJob", job);
////			// 表达式调度构建器
////			CronScheduleBuilder scheduleBuilder = CronScheduleBuilder.cronSchedule(job.getCronExpression());
////			// 按新的cronExpression表达式构建一个新的trigger
////			trigger = TriggerBuilder.newTrigger().withIdentity(job.getJobId(), job.getJobGroup())
////					.withSchedule(scheduleBuilder).build();
////			scheduler.scheduleJob(jobDetail, trigger);
////
////			TSchedule ts = new TSchedule();
////			ts.setId(idService.generateId(TSchedule.class.getName()));
////			BeanUtils.copyProperties(job, ts);
////			scheduleMapper.insert(ts);
////		} else {
////			// Trigger已存在，那么更新相应的定时设置
////			// 表达式调度构建器
////			CronScheduleBuilder scheduleBuilder = CronScheduleBuilder.cronSchedule(job.getCronExpression());
////			// 按新的cronExpression表达式重新构建trigger
////			trigger = trigger.getTriggerBuilder().withIdentity(triggerKey).withSchedule(scheduleBuilder).build();
////			// 按新的trigger重新设置job执行
////			scheduler.rescheduleJob(triggerKey, trigger);
////			TSchedule ts = new TSchedule();
////			ts.setJobGroup(job.getJobGroup());
////			ts.setJobId(job.getJobId());
////			ts = scheduleMapper.selectOne(ts);
////			ts.setCronExpression(job.getCronExpression());
////			scheduleMapper.updateByPrimaryKeySelective(ts);
////		}
//	}
//
//	public void removeSchedule(String jobId, String jobGroup) {
//        try {
//			ScheduleUtil.invokeRemoveScheduleServlet(jobId, jobGroup);
////            Scheduler scheduler = schedulerFactoryBean.getScheduler();
////            TriggerKey triggerKey = TriggerKey.triggerKey(jobId, jobGroup);
////            if (triggerKey != null) {
////                scheduler.pauseTrigger(triggerKey);
////                scheduler.unscheduleJob(triggerKey);
////                JobKey jobKey = new JobKey(jobId, jobGroup);
////                scheduler.deleteJob(jobKey);
////
////				TSchedule ts = new TSchedule();
////				ts.setJobGroup(jobId);
////				ts.setJobId(jobGroup);
////				scheduleMapper.delete(ts);
////            }
//        } catch (Exception e) {
//            throw new RuntimeException(e);
//        }
//    }
//
//	public void restartSchedule() throws SchedulerException {
//		Example example = new Example(TSchedule.class);
//		Example.Criteria criteria = example.createCriteria();
//		criteria.andGreaterThanOrEqualTo("endDate", new Date());
//		List<TSchedule> list = scheduleMapper.selectByExample(example);
//		for (TSchedule s : list) {
//			ScheduleJob scheduleJob = new ScheduleJob();
//			BeanUtils.copyProperties(s, scheduleJob);
//			Scheduler scheduler = schedulerFactoryBean.getScheduler();
//			TriggerKey triggerKey = TriggerKey.triggerKey(scheduleJob.getJobId(), scheduleJob.getJobGroup());
//			// 获取trigger，即在spring配置文件中定义的 bean id="myTrigger"
//			CronTrigger trigger = (CronTrigger) scheduler.getTrigger(triggerKey);
//			// 不存在，创建一个
//			if (null == trigger) {
//				JobDetail jobDetail = JobBuilder.newJob(QuartzJobFactory.class)
//						.withIdentity(scheduleJob.getJobId(), scheduleJob.getJobGroup()).build();
//				jobDetail.getJobDataMap().put("scheduleJob", scheduleJob);
//				// 表达式调度构建器
//				CronScheduleBuilder scheduleBuilder = CronScheduleBuilder.cronSchedule(scheduleJob.getCronExpression());
//				// 按新的cronExpression表达式构建一个新的trigger
//				trigger = TriggerBuilder.newTrigger().withIdentity(scheduleJob.getJobId(), scheduleJob.getJobGroup())
//						.withSchedule(scheduleBuilder).build();
//				scheduler.scheduleJob(jobDetail, trigger);
//			}
//		}
//	}
//}
