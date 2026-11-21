package com.core.beanUtil;

import java.util.*;

/**
 * Created by muzi on 30/11/2017.
 */
public class MapUtils {

    public static <K, V extends Comparable<? super V>> Map<K, V> sortByValue(Map<K, V> map) {
        List<Map.Entry<K, V>> list = new LinkedList<Map.Entry<K, V>>(map.entrySet());
        Collections.sort(list, new Comparator<Map.Entry<K, V>>() {
            @Override
            public int compare(Map.Entry<K, V> o1, Map.Entry<K, V> o2) {
                return (o2.getValue()).compareTo(o1.getValue());
            }
        });

        Map<K, V> result = new LinkedHashMap<K, V>();
        for (Map.Entry<K, V> entry : list) {
            result.put(entry.getKey(), entry.getValue());
        }
        return result;
    }

    public static void main(String[] args) {

        Map<String, String > map = new HashMap<String, String>();

        map.put("3333", "3");
        map.put("1111", "1");
        map.put("4444", "4");
        map.put("2222", "2");

        for (Map.Entry<String, String > entry: map.entrySet()) {
            System.out.println(entry.getKey() + "----" + entry.getValue());
        }


        System.out.println("----------------");
        Map<String, String> stringStringMap = sortByValue(map);

        for (Map.Entry<String, String > entry: stringStringMap.entrySet()) {
            System.out.println(entry.getKey() + "----" + entry.getValue());
        }

    }
}
