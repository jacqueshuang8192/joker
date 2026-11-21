package com.hbi.base;

import com.alibaba.fastjson.JSON;
import com.hbi.constants.Constants;
import com.hbi.utils.CommonUtil;
import org.apache.log4j.Logger;

import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;

/**
 * Create by Mars on 2019/5/27 16:04
 */
public class BaseController<T> {

    protected Logger LOGGER = Logger.getLogger(getEntityClass());
    protected Class<T> getEntityClass() {
        Type genType = getClass().getGenericSuperclass();
        Type[] params = ((ParameterizedType) genType).getActualTypeArguments();
        return (Class<T>) params[0];
    }

    public String responseJsonString(Object response, String interfaceType){
        if (Constants.RETURN_TYPE_JSONP.equalsIgnoreCase(interfaceType)) {
            String method = Thread.currentThread().getStackTrace()[1].getMethodName();
            return CommonUtil.buildJSONPResponse(method, response);
        }
        return JSON.toJSONString(response);
    }

}
