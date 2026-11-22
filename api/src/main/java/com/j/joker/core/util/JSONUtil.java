package com.j.joker.core.util;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.serializer.SerializerFeature;
import com.alibaba.fastjson.serializer.ValueFilter;

public class JSONUtil {
    /**
     * 解析json，null值被解析为空字符串""
     * @param obj
     * @return
     */
    public static String parseJSONContainsNull(Object obj) {
        return JSON.toJSONString(obj, filter,
                SerializerFeature.WriteMapNullValue);
    }
    
    private static ValueFilter filter = new ValueFilter() {
        @Override
        public Object process(Object obj, String s, Object v) {
            if (v == null)
                return "";
            return v;
        }
    };
}
