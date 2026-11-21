package com.hbi.model;


import jakarta.persistence.Transient;
import java.util.Date;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Table(name = "t_free_game_singleresult")
public class TFreeGameSingleresult {
	@Id
    @Column(name = "id")
    private Long Id;

    @Column(name = "game_id")
    private Long gameId;
    
    @Column(name = "user_id")
    private Long userId;
    
    private Date  date ;
    
    
    private int total;
    private int  win;
    private int  lose;
    private int  draw;
    
    @Transient
    private String nickName;
    
    @Transient
    private String smallIcon;
    @Transient
    private Integer rank;
    
	public String getNickName() {
		return nickName;
	}

	public Integer getRank() {
		return rank;
	}

	public int getTotal() {
		return total;
	}

	public void setTotal(int total) {
		this.total = total;
	}

	

	public int getWin() {
		return win;
	}

	public void setWin(int win) {
		this.win = win;
	}

	public int getLose() {
		return lose;
	}

	public void setLose(int lose) {
		this.lose = lose;
	}

	public int getDraw() {
		return draw;
	}

	public void setDraw(int draw) {
		this.draw = draw;
	}

	public void setRank(Integer rank) {
		this.rank = rank;
	}

	public void setNickName(String nickName) {
		this.nickName = nickName;
	}

	public String getSmallIcon() {
		return smallIcon;
	}

	public void setSmallIcon(String smallIcon) {
		this.smallIcon = smallIcon;
	}

	public Long getId() {
		return Id;
	}

	public void setId(Long id) {
		Id = id;
	}

	public Long getGameId() {
		return gameId;
	}

	public void setGameId(Long gameId) {
		this.gameId = gameId;
	}

	public Long getUserId() {
		return userId;
	}

	public void setUserId(Long userId) {
		this.userId = userId;
	}

	

	public void setDate(java.util.Date date2) {
		this.date = date2;
	}

	

	
}
