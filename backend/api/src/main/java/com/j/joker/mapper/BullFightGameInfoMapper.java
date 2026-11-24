package com.j.joker.mapper;

import com.j.joker.model.BullfightGameinfo;
import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

/**
 * Created by ceeuoo on 4/1/2016.
 */
public interface BullFightGameInfoMapper extends EntityMapper<BullfightGameinfo> {
    public BullfightGameinfo selectById(@Param("bullfight_gameinfo") BullfightGameinfo gameInfo);

    default int createUser(BullfightGameinfo gameInfo) {
        int inserted = insertRegistration(gameInfo);
        initializeShard(gameInfo, Math.floorMod(gameInfo.getMid(), 10));
        return inserted;
    }

    int insertRegistration(@Param("bullfight_gameinfo") BullfightGameinfo gameInfo);
    int initializeShard(@Param("bullfight_gameinfo") BullfightGameinfo gameInfo, @Param("shard") int shard);

    public String selectByMoney(@Param("l") Long l,
                                @Param("playerId") Long playerId);

}
