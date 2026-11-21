package com.hbi.mapper;

import com.hbi.model.BullfightGameinfo;
import org.apache.ibatis.annotations.Param;
import tk.mybatis.mapper.common.Mapper;

/**
 * Created by ceeuoo on 4/1/2016.
 */
public interface BullFightGameInfoMapper extends Mapper<BullfightGameinfo> {
    public BullfightGameinfo selectById(@Param("bullfight_gameinfo") BullfightGameinfo gameInfo);

    public int createUser(@Param("bullfight_gameinfo") BullfightGameinfo gameInfo);

    public String selectByMoney(@Param("l") Long l,
                                @Param("playerId") Long playerId);

}
