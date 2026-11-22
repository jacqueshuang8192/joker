package com.j.joker.mapper;

import com.j.joker.model.BullfightGameinfo;
import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

/**
 * Created by ceeuoo on 4/1/2016.
 */
public interface BullFightGameInfoMapper extends EntityMapper<BullfightGameinfo> {
    public BullfightGameinfo selectById(@Param("bullfight_gameinfo") BullfightGameinfo gameInfo);

    public int createUser(@Param("bullfight_gameinfo") BullfightGameinfo gameInfo);

    public String selectByMoney(@Param("l") Long l,
                                @Param("playerId") Long playerId);

}
