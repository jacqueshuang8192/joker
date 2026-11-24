package com.j.joker.game.niuniu.proto;

import java.util.List;

/** 一个命令的包体结构。 */
public record Schema(int cmd, int ver, List<FieldSpec> fields) {
}
