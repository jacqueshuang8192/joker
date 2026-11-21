package com.hbi.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_free_game_totalranking")
	public class TFreeGameTotalranking {
		@Id
	    @Column("id")
	    private Long Id;

	    @Column("user_id")
	    private Long userId;
	    @Column("game_id")
	    private Long gameId;
	    // Populated by the ranking XML queries. Exclude primitive defaults from entity filters.
	    @Column(ignore = true)
	    private int score;
	    @Column(ignore = true)
	    private int total;
	    @Column(ignore = true)
	    private int win;
	    @Column(ignore = true)
	    private int draw;
	    @Column(ignore = true)
	    private int lose;
	    @Column(ignore = true)
	    private String nickName;
	    
	    @Column(ignore = true)
	    private String smallIcon;
	    @Column(ignore = true)
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
