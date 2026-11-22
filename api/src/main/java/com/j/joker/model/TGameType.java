package com.j.joker.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_game_type")
public class TGameType {
    @Id
    @Column("id")
    private Long id;

    @Id
    @Column("name")
    private String name;
    @Column("game_id")
    private Long gameId;
    @Column("game_type")
    private String gameType;
    @Column("is_show")
    private Long isShow;
    @Column("roomType")
	private Integer roomType;

	public Integer getRoomType() {
		return roomType;
	}

	public void setRoomType(Integer roomType) {
		this.roomType = roomType;
	}

	public Long getIsShow() {
		return isShow;
	}
	public void setIsShow(Long isShow) {
		this.isShow = isShow;
	}
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
	
	public Long getGameId() {
		return gameId;
	}
	public void setGameId(Long gameId) {
		this.gameId = gameId;
	}
	public String getGameType() {
		return gameType;
	}
	public void setGameType(String gameType) {
		this.gameType = gameType;
	}

	

    
}