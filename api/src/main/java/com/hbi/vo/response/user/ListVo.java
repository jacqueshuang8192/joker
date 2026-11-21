package com.hbi.vo.response.user;

import java.util.List;

import io.swagger.v3.oas.annotations.media.Schema;

public class ListVo {
    @Schema(title = "返回码", required = true)
    private String returnCode;
    
    private int count;
    
    private List list;

    public String getReturnCode() {
        return returnCode;
    }

    public void setReturnCode(String returnCode) {
        this.returnCode = returnCode;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public List getList() {
        return list;
    }

    public void setList(List list) {
        this.list = list;
    }
}
