//package com.hbi.service.common;
//
//import java.text.SimpleDateFormat;
//import java.util.ArrayList;
//import java.util.Date;
//import java.util.HashMap;
//import java.util.Iterator;
//import java.util.List;
//import java.util.Map;
//
//import org.apache.commons.collections.CollectionUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.core.service.BaseService;
//import com.hbi.cache.CacheDatabaseObject;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.CommonCacheController;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TUserTaskMapper;
//import com.hbi.model.TTask;
//import com.hbi.model.TUserTask;
//import com.hbi.service.idGenerate.GenerateIdService;
//import com.hbi.utils.InfServerException;
//
//@Service
//public class UserTaskService extends BaseService<TUserTask> {
//
//	@Autowired
//    private TUserTaskMapper userTaskMapper;
//
//	@Autowired
//	private CommonCacheController commonCacheController;
//
//	@Autowired
//	private GenerateIdService generateIdService;
//
//	/**
//	 * 更新用户每日任务进度
//	 * @param userId
//	 * @param taskId
//	 * @throws Exception
//	 */
//	public void updateUserDailyTask(Long userId, String userType, String taskCode, Integer amount, ICache cache) throws Exception {
//		Date nowDate = new Date();
//		TTask task = null;
//		List<TTask> tasks = commonCacheController.queryAllTasks(userType, cache);
//		if (CollectionUtils.isNotEmpty(tasks)) {
//			for (TTask t : tasks) {
//				if (taskCode.equalsIgnoreCase(t.getContent()) && Constants.DAILY_TASK.equals(t.getType())) {
//					task = t;
//					break;
//				}
//			}
//		}
//		if (task != null) {
//		    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//            Date now = sdf.parse(sdf.format(nowDate));
//			Long taskId = task.getTaskId();
//			TUserTask temp = new TUserTask();
//			temp.setTaskId(taskId);
//			temp.setUserId(userId);
//			temp.setEndDate(now);
//			List<TUserTask> userTasks = userTaskMapper.select(temp);
//			if (CollectionUtils.isNotEmpty(userTasks)) {
//				userTaskMapper.processTask(userId, taskId, amount, nowDate);
//			} else {
//			    temp.setId(generateIdService.generateId(TUserTask.class.getName()));
//				temp.setTaskType(Constants.DAILY_TASK);
//				temp.setActualAmount(amount);
//				temp.setAwardStatus(Constants.TASK_AWARD_NOT_GET);
//				temp.setUpdateDate(nowDate);
//				temp.setEndDate(now);
//				temp.setPriority(1);
//				userTaskMapper.insert(temp);
//				commonCacheController.addUserTaskToCache(temp, userType, cache);
//			}
//			commonCacheController.changeTaskProgress(userId, taskId, amount, cache);
//		} else {
//			throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到相关任务");
//		}
//	}
//
//	/**
//	 * 更新用户每日任务进度
//	 * @param userId
//	 * @param taskId
//	 * @throws Exception
//	 */
//	public void updateUserDailyTaskAsync(Long userId, String userType, String taskCode, Integer amount, ICache cache, List<CacheDatabaseObject> insertList, List<CacheDatabaseObject> updateList) throws Exception {
//		Date nowDate = new Date();
//		TTask task = null;
//		List<TTask> tasks = commonCacheController.queryAllTasks(userType, cache);
//		if (CollectionUtils.isNotEmpty(tasks)) {
//			for (TTask t : tasks) {
//				if (taskCode.equalsIgnoreCase(t.getContent()) && Constants.DAILY_TASK.equals(t.getType())) {
//					task = t;
//					break;
//				}
//			}
//		}
//		if (task != null) {
//		    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//            Date now = sdf.parse(sdf.format(nowDate));
//			Long taskId = task.getTaskId();
//			TUserTask temp = new TUserTask();
//			temp.setTaskId(taskId);
//			temp.setUserId(userId);
//			temp.setEndDate(now);
//			List<TUserTask> userTasks = userTaskMapper.select(temp);
//			if (CollectionUtils.isNotEmpty(userTasks)) {
//				Map<String, Object> params = new HashMap<String, Object>();
//				params.put("userId", userId);
//				params.put("taskId", taskId);
//				params.put("amount", amount);
//				params.put("nowDate", nowDate);
//
//				CacheDatabaseObject obj = new CacheDatabaseObject();
//				obj.setControlType("updateTask:T_USER_TASK");
//				obj.setData(params);
//
//				updateList.add(obj);
//
////				userTaskMapper.processTask(userId, taskId, amount, nowDate);
//			} else {
//			    temp.setId(generateIdService.generateId(TUserTask.class.getName()));
//				temp.setTaskType(Constants.DAILY_TASK);
//				temp.setActualAmount(amount);
//				temp.setAwardStatus(Constants.TASK_AWARD_NOT_GET);
//				temp.setUpdateDate(nowDate);
//				temp.setEndDate(now);
//				temp.setPriority(1);
//				userTaskMapper.insert(temp);
//				commonCacheController.addUserTaskToCache(temp, userType, cache);
//			}
//			commonCacheController.changeTaskProgress(userId, taskId, amount, cache);
//		} else {
//			throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到相关任务");
//		}
//	}
//
//	/**
//	 * 领取每日任务奖励
//	 * @param userId
//	 * @param taskId
//	 * @param cache
//	 * @throws Exception
//	 */
//	public void getDailyTaskAward(Long userId, TUserTask userTask, ICache cache) throws Exception {
//	    userTask.setAwardStatus(Constants.TASK_AWARD_GET);
//        userTaskMapper.updateByPrimaryKeySelective(userTask);
//	    commonCacheController.getDailyTaskAward(userId, userTask.getTaskId(), cache);
//	}
//
//	/**
//	 * 更新个人成就任务
//	 * @param userId
//	 * @param taskId
//	 * @param amount
//	 * @param cache
//	 * @throws Exception
//	 */
//	public void updateUserAchievementTask(Long userId, String userType, String taskCode, Integer amount, ICache cache) throws Exception {
//		Date nowDate = new Date();
//		TTask task = null;
//		List<TTask> sortTask = new ArrayList<TTask>();
////		TTask childTask = null;
//		TUserTask userTask = null;
//		int taskIndex = -1;
//		List<TTask> tasks = commonCacheController.queryAllTasks(userType, cache);
//		if (CollectionUtils.isNotEmpty(tasks)) {
//			Iterator<TTask> iterator = tasks.iterator();
//			while(iterator.hasNext()) {
//				TTask t = iterator.next();
//				if (!taskCode.equalsIgnoreCase(t.getContent()) || !Constants.ONE_TIME_TASK.equals(t.getType())) {
//					iterator.remove();
//				}
//			}
//
//			if (tasks.size() > 0) {
//				for (int i = 0; i < tasks.size(); i++) {
//					if (i == 0) {
//						for (TTask t : tasks) {
//							if (t.getPreTaskId() == null) {
//								sortTask.add(t);
//								break;
//							}
//						}
//					} else {
//						for (TTask t : tasks) {
//							if (sortTask.get(i-1).getTaskId().equals(t.getPreTaskId())) {
//								sortTask.add(t);
//								break;
//							}
//						}
//					}
//				}
//
//				TUserTask temp = new TUserTask();
//				temp.setUserId(userId);
//				temp.setTaskType(Constants.ONE_TIME_TASK);
//				List<TUserTask> userTasks = userTaskMapper.select(temp);
//				boolean isAllHas = true;
//				if (CollectionUtils.isNotEmpty(userTasks)) {
//					for (int i = 0; i < sortTask.size(); i++) {
//						boolean isHas = false;
//						for (TUserTask ut : userTasks) {
//							if (ut.getTaskId().equals(sortTask.get(i).getTaskId())) {
//								isHas = true;
//								break;
//							}
//						}
//						if (!isHas) {
//							taskIndex = i - 1;
//							isAllHas = false;
//							break;
//						}
//					}
//				}
//
//				if (isAllHas) {
//				    taskIndex = sortTask.size() - 1;
//				}
//				if (taskIndex >= 0) {
//					task = sortTask.get(taskIndex);
////					if (taskIndex != sortTask.size() - 1) {
////						childTask = sortTask.get(taskIndex + 1);
////					}
//				} else {
//					task = sortTask.get(0);
//					taskIndex = 0;
//				}
//				for (TUserTask ut : userTasks) {
//					if (ut.getTaskId().equals(task.getTaskId())) {
//						userTask = ut;
//						break;
//					}
//				}
//			}
//
//		}
//
//		if (task != null) {
//			Long taskId = task.getTaskId();
//			if (userTask != null) {
//				if ((task.getAmount() - userTask.getActualAmount()) > amount) { //任务未完成
//					userTaskMapper.processTask(userId, taskId, amount, nowDate);
//					commonCacheController.changeTaskProgress(userId, taskId, amount, cache);
//				} else {
//					userTaskMapper.processTask(userId, taskId, task.getAmount() - userTask.getActualAmount(), nowDate);
//					insertLinkTask(sortTask, taskIndex, amount, userId, nowDate, "1");
//					commonCacheController.changeTaskProgress(userId, taskId, task.getAmount() - userTask.getActualAmount(), cache);
//				}
//			} else {
//				List<TUserTask> userTasks = insertLinkTask(sortTask, taskIndex, amount, userId, nowDate, "2");
//				if (CollectionUtils.isNotEmpty(userTasks)) {
//					commonCacheController.addUserTaskToCache(userTasks.get(0), userType, cache);
//				}
//				commonCacheController.changeTaskProgress(userId, taskId, amount, cache);
//			}
//		} else {
//			throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到相关任务");
//		}
//	}
//
//	/**
//	 * 领取成就任务奖励
//	 * @param userId
//	 * @param taskId
//	 * @param cache
//	 * @throws Exception
//	 */
//	public void getAchievementTaskAward(Long userId, String userType, TUserTask userTask, ICache cache) throws Exception {
//	    Date nowDate = new Date();
//	    userTask.setPriority(0);
//	    userTask.setAwardStatus(Constants.TASK_AWARD_GET);
//	    userTask.setUpdateDate(nowDate);
//	    userTaskMapper.updateByPrimaryKeySelective(userTask);
//
//	    Long childTaskId = null;
//	    List<TTask> tasks = commonCacheController.queryAllTasks(userType, cache);
//	    if (CollectionUtils.isNotEmpty(tasks)) {
//	        for (TTask task : tasks) {
//                if (userTask.getTaskId().equals(task.getPreTaskId())) {
//                    childTaskId = task.getTaskId();
//                    break;
//                }
//            }
//	    }
//	    if (childTaskId != null) {
//	        TUserTask childUserTask = null;
//	        TUserTask temp = new TUserTask();
//	        temp.setUserId(userId);
//	        temp.setTaskId(childTaskId);
//	        temp.setTaskType(Constants.ONE_TIME_TASK);
//	        List<TUserTask> userTasks = userTaskMapper.select(temp);
//	        if (CollectionUtils.isNotEmpty(userTasks)) {
//	            childUserTask = userTasks.get(0);
//	        }
//
//	        if (childUserTask != null) {
//	            temp.setPriority(1);
//	            temp.setUpdateDate(nowDate);
//	            userTaskMapper.updateByPrimaryKeySelective(temp);
//	            childUserTask.setPriority(1);
//	            userTaskMapper.updateByPrimaryKeySelective(childUserTask);
//	        } else {
//	            childUserTask = new TUserTask();
//                childUserTask.setId(generateIdService.generateId(TUserTask.class.getName()));
//                childUserTask.setTaskId(childTaskId);
//                childUserTask.setTaskType(Constants.ONE_TIME_TASK);
//                childUserTask.setUserId(userId);
//                childUserTask.setActualAmount(0);
//                childUserTask.setAwardStatus(Constants.TASK_AWARD_NOT_GET);
//                childUserTask.setUpdateDate(nowDate);
//                childUserTask.setPriority(1);
//                userTaskMapper.insert(childUserTask);
//	        }
//	        commonCacheController.deleteAchievementTask(userId, userTask.getTaskId(), cache);
//            commonCacheController.addUserTaskToCache(childUserTask, userType, cache);
//	    } else {
//	        commonCacheController.getAchievementTaskAward(userId, userTask.getTaskId(), cache);
//	    }
//
//
//	}
//
//
//	private List<TUserTask> insertLinkTask(List<TTask> sortTask, int taskIndex, int amount, Long userId, Date nowDate, String type) {
//		List<TUserTask> userTasks = null;
//		int priority = 1;
//		if ("1".equals(type)) {
//			priority = 2;
//		}
//		if (sortTask.size() >= taskIndex + 2) {
//			userTasks = new ArrayList<TUserTask>();
//			for (int i = taskIndex + 1; i < sortTask.size(); i++) {
//				TTask t = sortTask.get(i);
//				TUserTask childUserTask = new TUserTask();
//				childUserTask.setId(generateIdService.generateId(TUserTask.class.getName()));
//				childUserTask.setTaskId(t.getTaskId());
//				childUserTask.setTaskType(Constants.ONE_TIME_TASK);
//				childUserTask.setUserId(userId);
//				childUserTask.setAwardStatus(Constants.TASK_AWARD_NOT_GET);
//				childUserTask.setUpdateDate(nowDate);
//				childUserTask.setPriority(priority);
//				priority++;
//				if (t.getAmount() <= amount) {
//					childUserTask.setActualAmount(t.getAmount());
//					userTaskMapper.insert(childUserTask);
//				} else {
//					childUserTask.setActualAmount(amount);
//					userTaskMapper.insert(childUserTask);
//					break;
//				}
//				userTasks.add(childUserTask);
//			}
//		}
//		return userTasks;
//	}
//}
