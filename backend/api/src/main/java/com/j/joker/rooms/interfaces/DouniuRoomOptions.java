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
        javaRooms = "game-java".equals(env.getProperty("JOKER_DOUNIU_RUNTIME"));
        pureJava = env.getProperty("JOKER_PURE_JAVA", Boolean.class, false);
    }

    public String forClient(Integer level, String content) {
        if (!javaRooms || !Integer.valueOf(302).equals(level) || content == null) return content;
        var config = JSONObject.parseObject(content);
        if (config == null || config.getJSONArray("gameConfig") == null) return content;
        var rows = config.getJSONArray("gameConfig");
        boolean hasPasswordOption = false;
        for (int i = 0; i < rows.size(); i++) {
            var groups = rows.getJSONObject(i).getJSONArray("configGroup");
            if (groups == null) continue;
            for (int j = 0; j < groups.size(); j++) {
                var group = groups.getJSONObject(j);
                var key = group.getString("config");
                if ("special".equals(key)) hasPasswordOption = true;
                if (pureJava && "hasLeper".equals(key)) {
                    group.put("configOption", List.of(Map.of("optionName", "无癞子", "optionValue", 0, "isDefualt", 1)));
                }
            }
        }
        if (!hasPasswordOption) {
            var option = Map.of("optionName", "设置六位密码", "optionValue", 1, "isDefualt", 0);
            var group = Map.of("config", "special", "isCheckBox", 1, "configOption", List.of(option));
            rows.add(Map.of("configShowName", "密码房", "configGroup", List.of(group)));
        }
        return config.toJSONString();
    }
}
