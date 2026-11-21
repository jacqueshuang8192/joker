package com.hbi.vo.response.datingActivity;

import java.util.List;

import com.hbi.cache.model.CacheDatingActivityListProfile;
import com.hbi.cache.model.CacheDatingAuctionRecordProfile;

public class DatingActivityRecord {
    
    List<CacheDatingActivityListProfile> datingActivities;
    
    List<CacheDatingAuctionRecordProfile> auctionRecords;

    public List<CacheDatingActivityListProfile> getDatingActivities() {
        return datingActivities;
    }

    public void setDatingActivities(List<CacheDatingActivityListProfile> datingActivities) {
        this.datingActivities = datingActivities;
    }

    public List<CacheDatingAuctionRecordProfile> getAuctionRecords() {
        return auctionRecords;
    }

    public void setAuctionRecords(List<CacheDatingAuctionRecordProfile> auctionRecords) {
        this.auctionRecords = auctionRecords;
    }
    
    
}
