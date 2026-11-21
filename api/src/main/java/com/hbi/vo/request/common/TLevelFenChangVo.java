package com.hbi.vo.request.common;

import java.io.Serializable;

public class TLevelFenChangVo implements Serializable{
    private Integer fenchang;
    private Integer misCoinsGold;
    private Integer isQuickMatch;

    public Integer getIsQuickMatch() {
        return isQuickMatch;
    }

    public void setIsQuickMatch(Integer isQuickMatch) {
        this.isQuickMatch = isQuickMatch;
    }

    public Integer getFenchang() {
        return fenchang;
    }

    public void setFenchang(Integer fenchang) {
        this.fenchang = fenchang;
    }

    public Integer getMisCoinsGold() {
        return misCoinsGold;
    }

    public void setMisCoinsGold(Integer misCoinsGold) {
        this.misCoinsGold = misCoinsGold;
    }
}
