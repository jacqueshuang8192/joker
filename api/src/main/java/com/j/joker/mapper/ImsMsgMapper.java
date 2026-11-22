package com.j.joker.mapper;

import com.j.joker.model.ImsMsg;
import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

public interface ImsMsgMapper extends EntityMapper<ImsMsg> {

    ImsMsg selectByPhone(@Param("phone") String phone);

}