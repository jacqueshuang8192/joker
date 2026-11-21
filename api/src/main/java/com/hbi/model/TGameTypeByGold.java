package com.hbi.model;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * Created by muzi on 18/11/2017.
 */
@Table(name = "t_game_type")
public class TGameTypeByGold {
        @Id
        @Column(name = "id")
        private Long id;

        @Id
        @Column(name = "name")
        private String name;

        @Column(name = "game_type_parent_id")
        private Integer gameTypeParentId;

        @Column(name = "room_type")
        private String roomType;

        @Column(name = "room_name")
        private String roomName;

        @Column(name = "is_show")
        private Integer isShow;


    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getGameTypeParentId() {
        return gameTypeParentId;
    }

    public void setGameTypeParentId(Integer gameTypeParentId) {
        this.gameTypeParentId = gameTypeParentId;
    }

    public String getRoomType() {
        return roomType;
    }

    public void setRoomType(String roomType) {
        this.roomType = roomType;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public Integer getIsShow() {
        return isShow;
    }

    public void setIsShow(Integer isShow) {
        this.isShow = isShow;
    }
}
