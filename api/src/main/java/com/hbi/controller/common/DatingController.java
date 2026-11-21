//package com.hbi.controller.common;
//
//import java.util.Date;
//import java.util.List;
//
//import javax.servlet.http.HttpServletRequest;
//
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Controller;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RequestMethod;
//import org.springframework.web.bind.annotation.RequestParam;
//import org.springframework.web.bind.annotation.ResponseBody;
//
//import com.core.controller.BaseController;
//import com.core.util.DateUtils;
//import com.hbi.cache.model.CacheDatingActivityListProfile;
//import com.hbi.cache.model.CacheDatingActivityProfile;
//import com.hbi.cache.model.CacheDatingAuctionRecordProfile;
//import com.hbi.constants.Constants;
//import com.hbi.model.TDatingActivity;
//import com.hbi.model.TUserGoods;
//import com.hbi.service.common.DatingService;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.Response;
//import com.hbi.vo.response.datingActivity.DatingActivityRecord;
//import com.wordnik.swagger.annotations.Api;
//import com.wordnik.swagger.annotations.ApiOperation;
//import com.wordnik.swagger.annotations.ApiParam;
//
///**
// * 首页控制器
// *
// * @author apple
// *
// */
//
//@Api(basePath = "/", value = "约饭接口", position = 1)
//@Controller
//public class DatingController extends BaseController {
//
//	private static final Log log = LogFactory.getLog(DatingController.class);
//
//	@Autowired
//	private DatingService datingService;
//
//	@ResponseBody
//	@RequestMapping(value = "dating/createDatingActivity", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//	@ApiOperation(value = "新建约饭活动", httpMethod = "GET", position = 2, response = Response.class, notes = "新建约饭活动")
//	public String createDatingActivity (
//			@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//			@ApiParam(required = true, name = "userType", value = "用户类型") @RequestParam(value = "userType") String userType,
//			@ApiParam(required = true, name = "datingTime", value = "约饭时间") @RequestParam(value = "datingTime") String datingTime,
//			@ApiParam(required = true, name = "period", value = "时段(1：早上；2：中午；3：下午；4：晚上)") @RequestParam(value = "period") String period,
//			@ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//			@ApiParam(required = true, name = "categoryId", value = "物品ID") @RequestParam(value = "categoryId") String categoryId,
//			@ApiParam(required = true, name = "auctionCount", value = "起价数量") @RequestParam(value = "auctionCount") String auctionCount,
//			@ApiParam(required = true, name = "auctionDeclaration", value = "拍卖宣言") @RequestParam(value = "auctionDeclaration") String auctionDeclaration,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			TDatingActivity datingActivity = new TDatingActivity();
//			datingActivity.setUserId(Long.parseLong(userId));
//			datingActivity.setUserType(userType);
//			Date nowDate = new Date();
//			Date dt = DateUtils.getParseDate(datingTime, "yyyy-MM-dd HH:mm:ss");
//			if ((dt.getTime() - nowDate.getTime()) < 1800000) {
//				throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR, "约饭时间必须早于当前时间半个小时");
//			}
//			datingActivity.setTime(dt);
//			datingActivity.setPeriod(period);
//			datingActivity.setCityId(Long.parseLong(cityId));
//			datingActivity.setCategoryId(Long.parseLong(categoryId));
//			datingActivity.setAuctionCount(Integer.parseInt(auctionCount));
//			datingActivity.setAuctionDeclaration(auctionDeclaration);
//			datingActivity.setStatus(Constants.DATING_STATUS_IN_AUCTION);
//			datingActivity.setCreateDate(nowDate);
//			datingService.createDatingActivity(datingActivity);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("新建约饭活动：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		return CommonUtil.buildJSONPResponse(Constants.CREATE_DATING_ACTIVITY, response);
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "dating/queryDatingActivities", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//	@ApiOperation(value = "获取附近约饭列表", httpMethod = "GET", position = 2, response = Response.class, notes = "获取附近约饭列表")
//	public String queryDatingActivities (
//			@ApiParam(required = true, name = "cityId", value = "城市ID") @RequestParam(value = "cityId") String cityId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			List<CacheDatingActivityListProfile> nearbydatingActivities = datingService.queryDatingActivitiesNearby(cityId);
//			response.setData(nearbydatingActivities);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("获取附近约饭列表：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		return CommonUtil.buildJSONPResponse(Constants.QUERY_DATING_ACTIVITIES, response);
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "dating/queryUserDatingActivities", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//	@ApiOperation(value = "获取用户约饭活动列表", httpMethod = "GET", position = 2, response = Response.class, notes = "获取用户约饭活动列表")
//	public String queryUserDatingActivities (
//			@ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			DatingActivityRecord datingActivityRecord = datingService.queryDatingActivitiesByUserId(Long.parseLong(userId));
//			response.setData(datingActivityRecord);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("获取用户约饭活动列表：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		return CommonUtil.buildJSONPResponse(Constants.QUERY_USER_DATING_ACTIVITIES, response);
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "dating/queryDatingActivityDetail", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//	@ApiOperation(value = "获取约饭活动详情", httpMethod = "GET", position = 2, response = Response.class, notes = "获取约饭活动详情")
//	public String queryDatingActivityDetail (
//			@ApiParam(required = true, name = "activityId", value = "约饭活动ID") @RequestParam(value = "activityId") String activityId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			CacheDatingActivityProfile datingActivity = datingService.queryDatingActivityDetailByActivityId(Long.parseLong(activityId));
//			response.setData(datingActivity);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("获取约饭活动详情：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		return CommonUtil.buildJSONPResponse(Constants.QUERY_DATING_ACTIVITY_DETAIL, response);
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "dating/queryMyDatingGoods", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//	@ApiOperation(value = "查询我的约饭道具", httpMethod = "GET", position = 2, response = Response.class, notes = "查询我的约饭道具")
//	public String queryMyDatingGoods (
//			@ApiParam(required = true, name = "userId", value = "竞价用户ID") @RequestParam(value = "userId") String userId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			List<TUserGoods> userGoods = datingService.queryMyDatingGoods(Long.parseLong(userId));
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//			response.setData(userGoods);
//		} catch (Exception e) {
//			log.error("查询我的约饭道具：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		return CommonUtil.buildJSONPResponse(Constants.QUERY_MY_DATING_GOODS, response);
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "dating/applyForDatingAuction", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//	@ApiOperation(value = "申请约饭活动竞价", httpMethod = "GET", position = 2, response = Response.class, notes = "申请约饭活动竞价")
//	public String applyForDatingAuction (
//			@ApiParam(required = true, name = "activityId", value = "约饭活动ID") @RequestParam(value = "activityId") String activityId,
//			@ApiParam(required = true, name = "auctionUserId", value = "竞价用户ID") @RequestParam(value = "auctionUserId") String auctionUserId,
//			@ApiParam(required = true, name = "categoryId", value = "物品类型ID") @RequestParam(value = "categoryId") String categoryId,
//			@ApiParam(required = true, name = "auctionCount", value = "竞价数量") @RequestParam(value = "auctionCount") String auctionCount,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			datingService.applyDatingAuction(Long.parseLong(activityId), Long.parseLong(auctionUserId), Long.parseLong(categoryId), Integer.parseInt(auctionCount));
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("申请约饭活动竞价：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		return CommonUtil.buildJSONPResponse(Constants.APPLY_FOR_DATING_AUCTION, response);
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "dating/cancelDatingActivity", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//	@ApiOperation(value = "主播取消约会活动", httpMethod = "GET", position = 2, response = Response.class, notes = "主播取消约会活动")
//	public String replyInviteDating (
//			@ApiParam(required = true, name = "activityId", value = "约饭记录ID") @RequestParam(value = "activityId") String activityId,
//			@ApiParam(required = false, name = "cancelReason", value = "取消理由") @RequestParam(value = "cancelReason", required = false) String cancelReason,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			datingService.cancelDatingActivity(Long.parseLong(activityId), cancelReason);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("主播取消约会活动：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		return CommonUtil.buildJSONPResponse(Constants.CANCEL_DATING_ACTIVITY, response);
//	}
//
//	@ResponseBody
//    @RequestMapping(value = "dating/confirmPayment", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//    @ApiOperation(value = "确认支付", httpMethod = "GET", position = 2, response = Response.class, notes = "确认支付")
//    public String confirmPayment (
//            @ApiParam(required = true, name = "activityId", value = "约饭记录ID") @RequestParam(value = "activityId") String activityId,
//            @ApiParam(required = true, name = "userId", value = "用户ID") @RequestParam(value = "userId") String userId,
//            HttpServletRequest request) {
//        Response response = new Response();
//        try {
//            datingService.confirmPayment(Long.parseLong(activityId), Long.parseLong(userId));
//            response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//        } catch (Exception e) {
//			log.error("确认支付：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//        return CommonUtil.buildJSONPResponse(Constants.DATING_ACTIVITY_CONFIRM_PAYMENT, response);
//    }
//
//	@ResponseBody
//	@RequestMapping(value = "dating/evaluateDating", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//	@ApiOperation(value = "玩家评论约会", httpMethod = "GET", position = 2, response = Response.class, notes = "玩家评论约会")
//	public String evaluateDating (
//			@ApiParam(required = true, name = "activityId", value = "约饭记录ID") @RequestParam(value = "activityId") String activityId,
//			@ApiParam(required = true, name = "onTimeGrade", value = "准时度") @RequestParam(value = "onTimeGrade") String onTimeGrade,
//			@ApiParam(required = true, name = "satisfaction", value = "满意度") @RequestParam(value = "satisfaction") String satisfaction,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			datingService.evaluateDatingActivity(Long.parseLong(activityId), Float.parseFloat(onTimeGrade), Float.parseFloat(satisfaction));
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("玩家评论约会：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		return CommonUtil.buildJSONPResponse(Constants.EVALUATE_DATING, response);
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "dating/queryDatingAuctiongRecord", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//	@ApiOperation(value = "查询约饭活动记录", httpMethod = "GET", position = 2, response = Response.class, notes = "查询约饭活动记录")
//	public String queryDatingAuctiongRecord (
//			@ApiParam(required = true, name = "userId", value = "用户id") @RequestParam(value = "userId") String userId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			List<CacheDatingAuctionRecordProfile> auctionRecords = datingService.queryDatingAuctionRecords(Long.parseLong(userId));
//			response.setData(auctionRecords);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("查询约饭活动记录：", e);
//            CommonUtil.BuildErrorResponse(e, response);
//        }
//		return CommonUtil.buildJSONPResponse(Constants.QUERY_DATING_AUCTION_RECORD, response);
//	}
//
//	@ResponseBody
//	@RequestMapping(value = "dating/closeDatingActivity", method = RequestMethod.GET, produces = "text/xml; charset=utf-8")
//	@ApiOperation(value = "关闭约饭活动", httpMethod = "GET", position = 2, response = Response.class, notes = "查询约饭活动记录")
//	public String closeDatingActivity (
//			@ApiParam(required = true, name = "activityId", value = "活动id") @RequestParam(value = "activityId") Long activityId,
//			HttpServletRequest request) {
//		Response response = new Response();
//		try {
//			datingService.closeDatingActivity(activityId);
//			response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
//		} catch (Exception e) {
//			log.error("关闭约饭活动：", e);
//			CommonUtil.BuildErrorResponse(e, response);
//		}
//		return CommonUtil.buildJSONPResponse(Constants.QUERY_DATING_AUCTION_RECORD, response);
//	}
//
//
//}
