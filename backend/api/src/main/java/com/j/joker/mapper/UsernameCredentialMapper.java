package com.j.joker.mapper;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

public interface UsernameCredentialMapper {
    record Credential(long userId, String passwordHash) {}

    @Select("SELECT user_id, password_hash FROM t_username_credential WHERE username = #{username}")
    Credential find(String username);

    @Insert("INSERT INTO t_username_credential(username, user_id, password_hash) VALUES(#{name}, #{id}, #{hash})")
    void insert(@Param("name") String username, @Param("id") long userId, @Param("hash") String hash);
}
