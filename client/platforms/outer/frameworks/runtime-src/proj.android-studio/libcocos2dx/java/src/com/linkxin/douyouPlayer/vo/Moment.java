package com.linkxin.douyouPlayer.vo;

import java.util.List;

/**
 * Created by lxy on 2016/4/13.
 */
public class Moment {

    /**
     * createDate : 2016-03-14 19:26:35
     * id : 19
     * status : 1
     * text :
     * userId : 207
     */

    private String createDate;
    private long id;
    private String status;
    private String text;
    private long userId;
    private List<Photo> list;

    public String getCreateDate() {
        return createDate;
    }

    public void setCreateDate(String createDate) {
        this.createDate = createDate;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

	public List<Photo> getList() {
		return list;
	}

	public void setList(List<Photo> list) {
		this.list = list;
	}
    
}
