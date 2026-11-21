package com.linkxin.douyouPlayer.vo;

public class Alarm {
	String id;
	String hour;
	String minute;
	String state;
	String open;

	public String GetId() {
		return id;
	}

	public void SetId(String id) {
		this.id = id;
	}
	
	public String GetHour() {
		return hour;
	}

	public void SetHour(String hour) {
		this.hour = hour;
	}
	
	public String GetMinute() {
		return minute;
	}

	public void SetMinute(String minute) {
		this.minute = minute;
	}
	
	public String GetState() {
		return state;
	}

	public void SetState(String state) {
		this.state = state;
	}
	
	public String GetOpen() {
		return open;
	}

	public void SetOpen(String open) {
		this.open = open;
	}
	
}
