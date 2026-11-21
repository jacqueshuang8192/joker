package com.hbi.service.common;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.core.service.BaseService;
import com.hbi.mapper.TCityMapper;
import com.hbi.model.TCity;

@Service
public class CityService extends BaseService<TCity> {

	@Autowired
	private TCityMapper cityMapper;
	
	public TCity findCityById(Long id) {
        TCity city = cityMapper.findById(id);
    	return city;
	}
}
