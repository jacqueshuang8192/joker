package com.hbi.mapper;

import com.hbi.model.ImsMsg;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

public interface ImsMsgMapper extends EntityMapper<ImsMsg> {

    ImsMsg selectByPhone(@Param("phone") String phone);

}