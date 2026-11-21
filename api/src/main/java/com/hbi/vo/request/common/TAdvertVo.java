package com.hbi.vo.request.common;

import java.io.Serializable;

/**
 * Created by muzi on 2017/9/20.
 */
public class TAdvertVo implements Serializable{
    private String photoUrl;
    private String visitUrl;

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public String getVisitUrl() {
        return visitUrl;
    }

    public void setVisitUrl(String visitUrl) {
        this.visitUrl = visitUrl;
    }
}
