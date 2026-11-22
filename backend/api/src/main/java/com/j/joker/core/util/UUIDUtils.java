package com.j.joker.core.util;

import java.util.UUID;

/**
 * Created by muzi on 2017/6/24.
 */
public class UUIDUtils {
    public static  String getUUID() {
        UUID uuid = UUID.randomUUID();
        String str = uuid.toString();
        String uuidStr=str.replace("-", "");
        return uuidStr;
    }
}
