package com.j.joker.utils;

import com.alibaba.fastjson.JSONObject;

/**
 * Created by ceeuoo on 3/30/2016.
 */
public class PushUtil {
    public static void push(Integer type, JSONObject json) throws Exception {
        JPushUtil.push(type, json);
    }
}
