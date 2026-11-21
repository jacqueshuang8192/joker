package com.hbi.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_game_type_game")
public class TGameTypeGame {
    @Id
    @Column("id")
    private Long id;
    @Column("game_type_id")
    private Long gameTypeId;
    
    @Column("game_id")
    private Long gameId;
    
    @Column("province_id")
    private Long provinceId;
    @Column("game_level")
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