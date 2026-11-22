package com.j.joker.utils;

import com.j.joker.model.TGroupUnionMember;

import java.lang.reflect.Field;

/**
 * 自动生成代码
 * Create by Mars on 2019/5/24 15:04
 */
public class AutoGeneration {

    /**
     * 
     * Create by Mars on 15:06 2019/5/24
     * @param clz class
     * @return Parameter + RequestParam
     **/
    public static void printCrtlParams(Class clz){
        StringBuffer sb = new StringBuffer("");
        Field[] fields = clz.getDeclaredFields();
        for(Field f : fields){
            // required = true, name = "", value = "") @RequestParam(value = "", required = true) String yesterdayDayingjia
            String name = f.getName();
            sb.append("@Parameter(required = true, ")
                    .append("name = \"").append(name).append("\", ")
                    .append("description = \"").append(name).append("\") ")
                    .append("@RequestParam(required = true, ")
                    .append("value = \"").append(name).append("\") ")
                    .append(f.getType().getSimpleName()).append(" ").append(name)
                    .append(",\n");
        }
        System.out.println(sb.toString());
    }

    /**
     *
     * Create by Mars on 15:06 2019/5/24
     * @param clz class
     * @param prefix 前缀
     * @return Parameter + RequestParam
     **/
    public static void printInsertValues(Class clz, String prefix){
        StringBuffer sb = new StringBuffer("(");
        Field[] fields = clz.getDeclaredFields();
        for(Field f : fields){
            // (value1, value2, value3, ....)
            String value = prefix + "." + f.getName();
            sb.append("#{").append(value).append("}, ");
        }
        String values = sb.substring(0, sb.length() - 2);
        System.out.println(values + ")");
    }

    public static void main(String[] args) {
        printInsertValues(TGroupUnionMember.class, "vo");
    }

}
