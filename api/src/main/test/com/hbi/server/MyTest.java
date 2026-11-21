package com.hbi.server;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.core.util.StringUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class MyTest {
    /**
     * 搜索玩家积分池
     * @param uid
     * @param usersChipMap
     * @param uid2UpIdMap
     * @param uid2RepPointMap
     * @return
     */
    public static Long queryMySonPool (Integer uid, Map<String, String> usersChipMap, Map<Integer, Integer> uid2UpIdMap, Map<Integer, Integer> uid2RepPointMap) {

        List<Integer> sonList = getMySons(uid2UpIdMap, uid);
        Long result = 0l;

        for (int i = 0; i < sonList.size(); i++) {
            //积分
            String point = usersChipMap.get((sonList.get(i) + ""));
            if (! StringUtil.isEmpty(point) ) {
                result += Long.parseLong(point);
            }
            //仓库
            Integer repPoint = uid2RepPointMap.get(sonList.get(i));
            if (!StringUtil.isEmpty(repPoint) && repPoint > 0) {
                result += Long.parseLong(repPoint+"");
            }

        }

        return result;

    }
    private static List<Integer> getMySons (Map<Integer, Integer> uid2UpIdMap, Integer uid) {

        List<Integer> sonArr = new ArrayList<Integer> ();
        sonArr.add(uid);

        for (Map.Entry<Integer, Integer> entry : uid2UpIdMap.entrySet()) {

            if ((entry.getKey()+"").equals(uid+"")) {
                continue;
            }

            if ((entry.getValue()+"").equals(uid+"")) {
                List<Integer> aesSon = getMySons(uid2UpIdMap, entry.getKey());
                sonArr.addAll(aesSon);
            }

        }

        return sonArr;
    }
    public static void main (String[] args) {
        String usersChip= "{100009:30000, 100010:50000, 100011:50000, 100012:100000, 100013:200000, 100014:50000, 100004:2100000, 100005:1012200, 100006:1296100, 100007:2501200, 100128:190000, 100008:1974800}";
        Map usersChipMap=(Map)JSON.parse(usersChip);
        String uid2UpId= String.format ("{100128:100005,100005:100005,100004:100005,100007:100005,100006:100005,100009:100005,100008:100005,100011:100013,100010:100014,100013:100010,100012:100010,100014:100005}");
        Map uid2UpIdMap=(Map) JSON.parse(uid2UpId);
        String uid2RepPoint= String.format ("{ 100128:810000, 100005:32449, 100004:0, 100007:0, 100006:6351, 100009:0, 100008:0, 100011:50000, 100010:0, 100013:0, 100012:0, 100014:0}");
        Map uid2RepPointMap=(Map) JSON.parse(uid2RepPoint);

        Long sonPool = queryMySonPool(100013, usersChipMap, uid2UpIdMap, uid2RepPointMap);
        System.out.println (sonPool);
        String str = "{\"0\":\"zhangsan\",\"1\":\"lisi\",\"2\":\"wangwu\",\"3\":\"maliu\"}";
        //第一种方式
        Map maps = (Map)JSON.parse(str);
        System.out.println("这个是用JSON类来解析JSON字符串!!!");
        for (Object map : maps.entrySet()){
            System.out.println(((Map.Entry)map).getKey()+"     " + ((Map.Entry)map).getValue());
        }
    }
}
