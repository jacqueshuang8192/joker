package com.j.joker.rooms.interfaces;

import com.alibaba.fastjson.JSONObject;
import java.util.List;
import java.util.Map;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

/** 将运行时可建的牛牛房型转换为 Cocos 开房界面的选项。 */
@Component
public class DouniuRoomOptions {
    private final boolean javaRooms;
    private final boolean pureJava;

    public DouniuRoomOptions(Environment env) {
        pureJava = env.getProperty("JOKER_PURE_JAVA", Boolean.class, false);
        javaRooms = "game-java".equals(env.getProperty("JOKER_DOUNIU_RUNTIME"));
    }

    public String forClient(Integer level, String content) {
        if (!javaRooms || !Integer.valueOf(302).equals(level) || content == null) return content;
        var config = JSONObject.parseObject(content);
        if (config == null || config.getJSONArray("gameConfig") == null) return content;
        var rows = config.getJSONArray("gameConfig");
        var existing = new java.util.HashSet<String>();
        for (int i = 0; i < rows.size(); i++) {
            var groups = rows.getJSONObject(i).getJSONArray("configGroup");
            if (groups == null) continue;
            for (int j = 0; j < groups.size(); j++) {
                var group = groups.getJSONObject(j);
                var key = group.getString("config");
                existing.add(key);
                if (pureJava && "subGameType".equals(key) && group.getJSONArray("configOption") != null) {
                    var options = group.getJSONArray("configOption");
                    if (options.toJavaList(JSONObject.class).stream().noneMatch(o -> o.getIntValue("optionValue") == 5))
                        options.add(Map.of("optionName","斗公牛","optionValue",5,"isDefualt",0));
                }
            }
        }
        if (pureJava && !existing.contains("waiwei")) {
            var option = Map.of("optionName", "买牛", "optionValue", 1, "isDefualt", 0);
            rows.add(Map.of("configShowName", "外围", "configGroup", List.of(Map.of("config", "waiwei",
                    "isCheckBox", 1, "configOption", List.of(option)))));
        }
        if (pureJava && !existing.contains("ipXz"))
            rows.add(choice("同 IP 限制", "ipXz", List.of(option("不限", 0), option("禁止同 IP 入座", 1))));
        if (pureJava && !existing.contains("juLi"))
            rows.add(choice("同桌最小距离", "juLi", List.of(option("不限", 0), option("100 米", 100), option("200 米", 200))));
        if (!existing.contains("special")) {
            var option = Map.of("optionName", "设置六位密码", "optionValue", 1, "isDefualt", 0);
            var group = Map.of("config", "special", "isCheckBox", 1, "configOption", List.of(option));
            rows.add(Map.of("configShowName", "密码房", "configGroup", List.of(group)));
        }
        return config.toJSONString();
    }

    private static Map<String,Object> option(String name, int value) {
        return Map.of("optionName", name, "optionValue", value, "isDefualt", value == 0 ? 1 : 0);
    }

    private static Map<String,Object> choice(String label, String key, List<Map<String,Object>> options) {
        return Map.of("configShowName", label, "configGroup", List.of(Map.of("config",key,"isCheckBox",0,"configOption",options)));
    }
}
