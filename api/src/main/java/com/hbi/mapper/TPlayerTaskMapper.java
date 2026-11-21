package com.hbi.mapper;

import com.hbi.model.TPlayerTask;
import com.hbi.model.TTask;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

import java.util.List;

/**
 * Created by muzi on 23/11/2017.
 */
public interface TPlayerTaskMapper extends EntityMapper<TPlayerTask> {

    public Integer selectTermIsOk(@Param("l") Long l,
                                  @Param("playerId") Long playerId);


    public void insertOne(@Param("l") long l,
                          @Param("playerId") Long playerId,
                          @Param("count") Long count);

    public List<TTask> selectTask();

    public List<TTask> selectByparentId(@Param("taskId") Integer taskId);

    public TTask selectByTaskId(@Param("i") int i,
                                @Param("i1") int i1);

    public List<TTask> selectByTaskIdNotSquence(@Param("i") int i);

    TPlayerTask selectByTask_id(@Param("l") Long l,
                                @Param("playerId") Long playerId,
                                @Param("i") int i);

    public void updateTaskStatus(@Param("l") long l,
                                 @Param("playerId") Long playerId,
                                 @Param("taskId") int taskId,
                                 @Param("squence") int squence,
                                 @Param("status") int status);

    public void updateSquence(@Param("l") long l,
                              @Param("playerId") Long playerId,
                              @Param("taskId") int taskId,
                              @Param("squence") int squence);

    public TPlayerTask selectPlayerTaskByTask(@Param("playerId") Long playerId,
                                              @Param("l") Long l,
                                              @Param("i") int i,
                                              @Param("i1") int i1);

    TPlayerTask selectPlayerTaskByTaskId(@Param("playerId") Long playerId,
                                         @Param("l") long l,
                                         @Param("i") int i);
}
