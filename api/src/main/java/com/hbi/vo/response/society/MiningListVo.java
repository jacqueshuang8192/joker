package com.hbi.vo.response.society;

import java.util.List;

/**
 * Created by ceeuoo on 4/8/2016.
 */
public class MiningListVo {

    private int count;

    private List list;

    /**
     * 本公会是否爆矿
     */
    private boolean isSelfSocietyBoomed;

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public boolean isSelfSocietyBoomed() {
        return isSelfSocietyBoomed;
    }

    public void setSelfSocietyBoomed(boolean selfSocietyBoomed) {
        isSelfSocietyBoomed = selfSocietyBoomed;
    }

    public List getList() {
        return list;
    }

    public void setList(List list) {
        this.list = list;
    }
}
