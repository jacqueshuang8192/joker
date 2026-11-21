package com.hbi.model;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Table;

@Table(name = "t_game_type_game")
public class TGameTypeGame {
    @Id
    @Column(name = "id")
    private Long id;
    @Column(name = "game_type_id")
    private Long gameTypeId;
    
    @Column(name = "game_id")
    private Long gameId;
    
    @Column(name = "province_id")
    private Long provinceId;
    @Column(name = "game_level")
    private Long Level;


	public Long getProvinceId() {
		return provinceId;
	}


	public void setProvinceId(Long provinceId) {
		this.provinceId = provinceId;
	}


	public Long getId() {
		return id;
	}


	public void setId(Long id) {
		this.id = id;
	}


	public Long getGameTypeId() {
		return gameTypeId;
	}


	public void setGameTypeId(Long gameTypeId) {
		this.gameTypeId = gameTypeId;
	}


	public Long getGameId() {
		return gameId;
	}


	public void setGameId(Long gameId) {
		this.gameId = gameId;
	}


	public Long getLevel() {
		return Level;
	}


	public void setLevel(Long level) {
		Level = level;
	}
	
	
	

    
}