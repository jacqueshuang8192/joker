package com.hbi.cache.model;

/**
 * Created by ceeuoo on 5/9/2016.
 */
public class CacheAuctionRank {
    private Integer auctionCount;

    private Integer rank;

    private Long userId;

    private CacheUserProfile user;

    public Integer getAuctionCount() {
        return auctionCount;
    }

    public void setAuctionCount(Integer auctionCount) {
        this.auctionCount = auctionCount;
    }

    public Integer getRank() {
        return rank;
    }

    public void setRank(Integer rank) {
        this.rank = rank;
    }

    public CacheUserProfile getUser() {
        return user;
    }

    public void setUser(CacheUserProfile user) {
        this.user = user;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }
}
