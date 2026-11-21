package com.hbi.model;

import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

@Table(name = "t_free_game_totalranking")
	public class TFreeGameTotalranking {
		@Id
	    @Column(name = "id")
	    private Long Id;

	    @Column(name = "user_id")
	    private Long userId;
	    @Column(name = "game_id")
	    private Long gameId;
	    private int score;
	    private int total;
	    private int  win;
	    private int  draw;
	    private int  lose;	    
	    @Transient
	    private String nickName;
	    
	    @Transient
	    private String smallIcon;
	    @Transient
	    private Integer rank;
		public Long getId() {
			return Id;
		}
		public int getScore() {
			return score;
		}
		public void setScore(int score) {
			this.score = score;
		}
		public void setId(Long id) {
			Id = id;
		}
		public Long getUserId() {
			return userId;
		}
		public void setUserId(Long userId) {
			this.userId = userId;
		}
		public Long getGameId() {
			return gameId;
		}
		public void setGameId(Long gameId) {
			this.gameId = gameId;
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
		public int getDraw() {
			return draw;
		}
		public void setDraw(int draw) {
			this.draw = draw;
		}
		public int getLose() {
			return lose;
		}
		public void setLose(int lose) {
			this.lose = lose;
		}
		public String getNickName() {
			return nickName;
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
		public Integer getRank() {
			return rank;
		}
		public void setRank(Integer rank) {
			this.rank = rank;
		}
}
