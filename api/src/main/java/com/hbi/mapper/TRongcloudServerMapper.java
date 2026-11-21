package com.hbi.mapper;


import com.hbi.model.TRongcloudServer;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface TRongcloudServerMapper{
    void deleteOrderDate();

    void insertRoom(TRongcloudServer tRongcloudServer);

    List<TRongcloudServer> getAllProvinceIds(@Param("provinceId") String provinceId);

    void deleteByRoom_id(@Param("room_id") String room_id);

    List<TRongcloudServer> getAllRoom(@Param("provinceId") String provinceId);

    public List<String> getRoomList();
}