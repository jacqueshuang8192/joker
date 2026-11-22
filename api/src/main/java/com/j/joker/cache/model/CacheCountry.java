package com.j.joker.cache.model;

import java.util.List;

import com.j.joker.cache.CacheModel;
import com.j.joker.model.TProvince;

public class CacheCountry extends CacheModel {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 国家代码
	 */
	private String countryCode;
	
	/**
	 * 省份列表
	 */
	private List<TProvince> provinces;

	public String getCountryCode() {
		return countryCode;
	}

	public void setCountryCode(String countryCode) {
		this.countryCode = countryCode;
	}

	public List<TProvince> getProvinces() {
		return provinces;
	}

	public void setProvinces(List<TProvince> provinces) {
		this.provinces = provinces;
	}
	
	
}
