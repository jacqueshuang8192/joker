package com.linkxin.douyouPlayer.vo;

import java.util.List;

public class GameList{

    private List<GameInfo> data;
    private String returnCode;
    
	public List<GameInfo> getData() {
		return data;
	}
	public void setData(List<GameInfo> data) {
		this.data = data;
	}
	public String getReturnCode() {
		return returnCode;
	}
	public void setReturnCode(String returnCode) {
		this.returnCode = returnCode;
	}
	
}
