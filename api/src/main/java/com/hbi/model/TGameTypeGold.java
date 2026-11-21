package com.hbi.model;

import jakarta.persistence.*;

@Table(name = "t_game_type_gold")
public class TGameTypeGold {
    @Id
    @Column(name = "id")
    private Long id;

    @Id
    @Column(name = "name")
    private String name;
    @Column(name = "game_id")
    private Long gameId;
    @Column(name = "game_type")
    private String gameType;
    @Column(name = "is_show")
    private Long isShow;
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