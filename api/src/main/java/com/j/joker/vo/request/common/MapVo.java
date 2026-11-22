package com.j.joker.vo.request.common;

import java.io.Serializable;

/**
 * Created by muzi on 2017/10/23.
 */
public class MapVo implements Serializable {
    private String mapKey;
    private String mapValue;

    public String getMapKey() {
        return mapKey;
    }

    public void setMapKey(String mapKey) {
        this.mapKey = mapKey;
    }

    public String getMapValue() {
        return mapValue;
    }

    public void setMapValue(String mapValue) {
        this.mapValue = mapValue;
    }
}