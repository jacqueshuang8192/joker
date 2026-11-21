package com.linkxin.douyouPlayer.vo;

import java.util.List;

import net.tsz.afinal.annotation.sqlite.Id;
import net.tsz.afinal.annotation.sqlite.Table;

@Table(name="Province")
public class Province {

    @Id(column="id")
    private int id;
	private String name;
	private long provinceId;
	private List<City> cities;
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public long getProvinceId() {
		return provinceId;
	}
	public void setProvinceId(long provinceId) {
		this.provinceId = provinceId;
	}

    public int getId() {
        return id;
    }

    public List<City> getCities() {
		return cities;
	}
	public void setCities(List<City> cities) {
		this.cities = cities;
	}

    public void setId(int id) {
        this.id = id;
    }

    @Override
	public String toString() {
		// TODO Auto-generated method stub
		return name;
	}

}
