package com.j.joker.service.common;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.j.joker.core.service.BaseService;
import com.j.joker.mapper.TCityMapper;
import com.j.joker.model.TCity;

@Service
public class CityService extends BaseService<TCity> {

	@Autowired
	private TCityMapper cityMapper;
	
	public TCity findCityById(Long id) {
        TCity city = cityMapper.findById(id);
    	return city;
	}
}
