package com.j.joker.mapper;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

public interface DouniuRoomPasswordMapper extends com.j.joker.rooms.application.RoomPasswords {
    @Select("SELECT password_hash FROM joker_douniu_room_password WHERE activity_id = #{activity}")
    String find(long activity);

    @Insert("INSERT INTO joker_douniu_room_password(activity_id,password_hash) VALUES (#{activity},#{hash})")
    void insert(@Param("activity") long activity, @Param("hash") String hash);
}
