package com.linkxin.douyouPlayer.vo;


import java.util.Comparator;

/**
 * 热词
 * Created by lxy on 2016/5/17.
 */
public class HotWord implements Comparator<HotWord>{

    /**
     * id : 15
     * name : 哈哈哈哈哈哈哈
     */

    private long id;
    private String name;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public int compare(HotWord lhs, HotWord rhs) {
        if (lhs.id <rhs.id){
            return -1;
        }else if (lhs.id > rhs.id){
            return 1;
        }
        return 0;
    }
}
