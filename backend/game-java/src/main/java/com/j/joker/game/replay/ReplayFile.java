package com.j.joker.game.replay;

import com.j.joker.game.niuniu.util.Json;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;

/** 每行一局解码后的 JSON，错误保留原始牌谱行号。 */
public final class ReplayFile {
    private ReplayFile() {}

    public static int number(Object value) {
        if (!(value instanceof Number n)) throw new IllegalArgumentException("缺少数值字段");
        return new BigDecimal(n.toString()).intValueExact();
    }

    public static List<Integer> integers(Object value) {
        if (!(value instanceof List<?> list)) throw new IllegalArgumentException("需要整数列表");
        return list.stream().map(ReplayFile::number).toList();
    }

    public static int verify(Path file, Consumer<Map<String,Object>> check) throws IOException {
        int count = 0, line = 0;
        try (var input = Files.newBufferedReader(file)) {
            for (String data; (data = input.readLine()) != null;) {
                line++;
                if (data.isBlank()) continue;
                try { check.accept(Json.parseObject(data)); }
                catch (RuntimeException invalid) { throw new IllegalArgumentException("第 " + line + " 行复算失败", invalid); }
                count++;
            }
        }
        if (count == 0) throw new IllegalArgumentException("文件没有牌局");
        return count;
    }
}
