package com.j.joker.service.common;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.j.joker.core.service.BaseService;
import com.j.joker.mapper.TProvinceMapper;
import com.j.joker.model.TProvince;

@Service
public class ProvinceService extends BaseService<TProvince> {

	@Autowired
	private TProvinceMapper provinceMapper;
	
	public TProvince findProvinceById(Long id) {
        TProvince province = provinceMapper.findById(id);
    	return province;
	}
	
}
