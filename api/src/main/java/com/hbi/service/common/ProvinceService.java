package com.hbi.service.common;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.core.service.BaseService;
import com.hbi.mapper.TProvinceMapper;
import com.hbi.model.TProvince;

@Service
public class ProvinceService extends BaseService<TProvince> {

	@Autowired
	private TProvinceMapper provinceMapper;
	
	public TProvince findProvinceById(Long id) {
    	TProvince province = provinceMapper.selectByPrimaryKey(id);
    	return province;
	}
	
}
