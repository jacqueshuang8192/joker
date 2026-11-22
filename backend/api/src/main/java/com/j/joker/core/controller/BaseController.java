/**
 * 
 */
package com.j.joker.core.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.serializer.SerializerFeature;
import com.j.joker.core.constants.YTConstants;
import com.j.joker.vo.response.base.BaseResultVo;

/**
 * 
 * @description: 基础controller
 * @version V1.0.0
 * 
 */
public class BaseController
{
    private static final Log LOGGER = LogFactory.getLog(BaseController.class);

    SerializerFeature[] feature =
    { SerializerFeature.DisableCircularReferenceDetect, SerializerFeature.WriteNullListAsEmpty,
            SerializerFeature.WriteNullStringAsEmpty, SerializerFeature.WriteNullBooleanAsFalse,
            SerializerFeature.WriteMapNullValue };

    /**
     * @description: 构造成功返回结果
     * @param resultData 需要返回的数据，可选
     * @return
     */
    protected String buildSuccessResultInfo(Object resultData)
    {
        LOGGER.debug(String.format("enter function, %s", resultData));
        BaseResultVo resultVo = new BaseResultVo(YTConstants.RESULT_SUCCESS,"");
        return JSON.toJSONString(resultVo, feature);
    }
    
    /**
     * 构造成功无返回结果
     * @param resultData
     * @return
     */
    protected String buildSuccessResultInfo()
    {
        BaseResultVo resultVo = new BaseResultVo(YTConstants.RESULT_SUCCESS,"");
        return JSON.toJSONString(resultVo, feature);
    }

    /**
     * @description: 构造失败返回结果
     * @param resultCode 任意非0数字，代表失败
     * @param failedMsg 失败信息
     * @return
     */
    protected String buildFailedResultInfo(String failedMsg)
    {
        BaseResultVo resultVo = new BaseResultVo(YTConstants.RESULT_FAIL,failedMsg);
        return JSON.toJSONString(resultVo, feature);
    }

}
