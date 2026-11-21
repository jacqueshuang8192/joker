package com.hbi.mapper;

import com.hbi.model.TPointChangeRecord;
import org.apache.ibatis.annotations.Param;
import tk.mybatis.mapper.common.Mapper;

import java.util.List;


public interface TPointChangeRecordMapper extends Mapper<TPointChangeRecord> {


    Integer addOne(@Param("tab") Integer tab,@Param("clubId") Integer clubId, @Param("uid") Integer uid,
                   @Param("type") Integer type, @Param("beforePoint") Integer beforePoint,
                   @Param("changePoint") Integer changePoint, @Param("nowPoint") Integer nowPoint,
                   @Param("operator") Integer operator, @Param("activityId") Integer activityId,
                   @Param("index") Integer index, @Param("remarkInfo") String remarkInfo, @Param("changeTime") String changeTime);

    List<TPointChangeRecord> selectChangeRecord(@Param("tab") int tab, @Param("clubId") Integer clubId, @Param("uid") Integer uid, @Param("typesStr") String typesStr, @Param("startInex") int startInex, @Param("pageSize") Integer pageSize);

    Integer selectChangeRecordCount(@Param("tab") int tab, @Param("clubId") Integer clubId, @Param("uid") Integer uid, @Param("typesStr") String typesStr);
}