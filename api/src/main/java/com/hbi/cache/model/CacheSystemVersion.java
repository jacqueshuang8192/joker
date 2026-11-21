package com.hbi.cache.model;

import com.hbi.cache.CacheModel;

public class CacheSystemVersion extends CacheModel {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 系统版本号
	 */
	private String version;
	
	/**
	 * 下载url
	 */
	private String url;
	
	/**
	 * 说明
	 */
	private String remark;
	
	/**
	 * 是否强制更新
	 */
	private boolean isManual;

	public String getVersion() {
		return version;
	}

	public void setVersion(String version) {
		this.version = version;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public boolean isManual() {
		return isManual;
	}

	public void setManual(boolean isManual) {
		this.isManual = isManual;
	}

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }
}
