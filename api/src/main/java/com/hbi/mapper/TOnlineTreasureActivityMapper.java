//package com.hbi.mapper;
//
//import com.hbi.model.TOnlineTreasureActivity;
//import org.apache.ibatis.annotations.Param;
//import tk.mybatis.mapper.common.Mapper;
//
//import java.util.List;
//
//public interface TOnlineTreasureActivityMapper extends Mapper<TOnlineTreasureActivity> {
//    int increaseSelledAmount(@Param(value = "activityId") Long activityId,
//                             @Param(value = "jewelAmount") Integer jewelAmount);
//
//    List<Long> search(@Param(value = "cityId")
//                      Long cityId,
//                      @Param(value = "keyWord")
//                      String keyWord);
//}