package com.j.joker.mapper;

import org.apache.ibatis.annotations.*;

public interface UsernameCredentialMapper {
    record Credential(long userId, String passwordHash, byte[] recoveryHash) {}

    @Select("SELECT user_id, password_hash, recovery_hash FROM t_username_credential WHERE username=#{username} FOR UPDATE")
    Credential lock(String username);

    @Insert("INSERT INTO t_username_credential(username,user_id,password_hash,recovery_hash) VALUES(#{name},#{id},#{hash},#{recovery})")
    void insert(@Param("name") String username, @Param("id") long userId, @Param("hash") String hash,
                @Param("recovery") byte[] recovery);

    @Update("UPDATE t_username_credential SET recovery_hash=#{recovery} WHERE user_id=#{id}")
    void enroll(@Param("id") long userId, @Param("recovery") byte[] recovery);

    @Update("UPDATE t_username_credential SET password_hash=#{hash},recovery_hash=#{recovery} WHERE user_id=#{id}")
    void replace(@Param("id") long userId, @Param("hash") String hash, @Param("recovery") byte[] recovery);

    @Select("SELECT COUNT(*) FROM t_username_credential WHERE username=#{username}")
    int countByName(String username);
}
