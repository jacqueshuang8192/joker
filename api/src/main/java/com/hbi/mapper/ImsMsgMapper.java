package com.hbi.mapper;

import com.hbi.model.ImsMsg;
import org.apache.ibatis.annotations.Param;
import tk.mybatis.mapper.common.Mapper;

public interface ImsMsgMapper extends Mapper<ImsMsg> {

    ImsMsg selectByPhone(@Param("phone") String phone);

}