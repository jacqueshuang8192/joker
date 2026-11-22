//package com.hbi.cache.cacheWritter;
//
//import com.hbi.constants.Constants;
//import com.hbi.mapper.*;
//import com.hbi.model.*;
//import org.apache.commons.collections.CollectionUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//import tk.mybatis.mapper.entity.Example;
//
//import java.util.List;
//
///**
// * Created by ceeuoo on 4/20/2016.
// */
//@Service
//public class OnlineTreasureCacheLoader {
//    @Autowired
//    private TOnlineTreasureActivityMapper onlineTreasureActivityMapper;
//    @Autowired
//    private TOnlineTreasureRecordMapper onlineTreasureRecordMapper;
//    @Autowired
//    private TOnlineTreasureAddressMapper onlineTreasureAddressMapper;
//
//    public List<TOnlineTreasureActivity> queryActiveTreasureList() {
//        Example example = new Example(TOnlineTreasureActivity.class);
//        Example.Criteria criteria = example.createCriteria();
//        criteria.andEqualTo("status", Constants.ONLINE_TREASURE_STATUS_PUBLISH);
//        List<TOnlineTreasureActivity> list = onlineTreasureActivityMapper.selectByExample(example);
//        return list;
//    }
//
//    public List<TOnlineTreasureActivity> queryPreviousTreasureList() {
//        Example example = new Example(TOnlineTreasureActivity.class);
//        Example.Criteria criteria = example.createCriteria();
////        criteria.andEqualTo("status", Constants.ONLINE_TREASURE_STATUS_PAST_DUE);
//        criteria.andNotEqualTo("status", Constants.ONLINE_TREASURE_STATUS_NULL);
//        criteria.andNotEqualTo("status", Constants.ONLINE_TREASURE_STATUS_DRAFT);
//        criteria.andNotEqualTo("status", Constants.ONLINE_TREASURE_STATUS_PUBLISH);
//        criteria.andNotEqualTo("status", Constants.ONLINE_TREASURE_STATUS_WAITING);
//        example.setOrderByClause("drawTime");
//        List<TOnlineTreasureActivity> list = onlineTreasureActivityMapper.selectByExample(example);
//        return list;
//    }
//
//    public List<TOnlineTreasureActivity> drawActivities() {
//        Example example = new Example(TOnlineTreasureActivity.class);
//        Example.Criteria criteria = example.createCriteria();
//        criteria.andEqualTo("status", Constants.ONLINE_TREASURE_STATUS_WAITING);
//        List<TOnlineTreasureActivity> list = onlineTreasureActivityMapper.selectByExample(example);
//        return list;
//    }
//
//    public TOnlineTreasureActivity activityDetail(Long activityId) {
//        TOnlineTreasureActivity activity = new TOnlineTreasureActivity();
//        activity.setId(activityId);
//        List<TOnlineTreasureActivity> list = onlineTreasureActivityMapper.select(activity);
//        if (CollectionUtils.isNotEmpty(list)) {
//            return list.get(0);
//        }
//        return null;
//    }
//
//    public List<TOnlineTreasureRecord> queryRecordsByActivityId(Long activityId) {
//        Example example = new Example(TOnlineTreasureRecord.class);
//        Example.Criteria criteria = example.createCriteria();
//        criteria.andEqualTo("activityId", activityId);
//        List<TOnlineTreasureRecord> list = onlineTreasureRecordMapper.selectByExample(example);
//        return list;
//    }
//
//    public List<TOnlineTreasureRecord> queryRecordsByUserId(Long userId) {
//        Example example = new Example(TOnlineTreasureRecord.class);
//        Example.Criteria criteria = example.createCriteria();
//        criteria.andEqualTo("userId", userId);
//        List<TOnlineTreasureRecord> list = onlineTreasureRecordMapper.selectByExample(example);
//        return list;
//    }
//
//    public List<TOnlineTreasureAddress> queryAddress(Long userId) {
//        TOnlineTreasureAddress address = new TOnlineTreasureAddress();
//        address.setUserId(userId);
//        return onlineTreasureAddressMapper.select(address);
//    }
//}
