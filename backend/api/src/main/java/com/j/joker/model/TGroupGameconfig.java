package com.j.joker.model;

import lombok.Setter;
import lombok.Getter;
import java.util.Date;
import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;

@Getter
@Setter
@Table("t_group_gameconfig")
public class TGroupGameconfig {
    @Id(keyType = KeyType.Auto)
    private Integer id;

    @Column("group_id")
    private Integer groupId;

    private Integer level;

    private String name;

    private String config;

    @Column("game_type")
    private Integer gameType;

    private Integer status;

    @Column("crate_time")
    private Date crateTime;
}
