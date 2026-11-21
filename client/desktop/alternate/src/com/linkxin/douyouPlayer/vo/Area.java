package com.linkxin.douyouPlayer.vo;

import java.util.List;

import net.tsz.afinal.annotation.sqlite.Table;

/**
 * 包含所有的省市区
 * @author lxy
 *
 */
@Table(name="Area")
public class Area {
	
	private String countryCode;
	private List<Province> provinces;
	public String getCountryCode() {
		return countryCode;
	}
	public void setCountryCode(String countryCode) {
		this.countryCode = countryCode;
	}
	public List<Province> getProvinces() {
		return provinces;
	}
	public void setProvinces(List<Province> provinces) {
		this.provinces = provinces;
	}

}
