package com.j.joker.game.niuniu.proto;

import java.util.List;

/** 一个协议字段：名称、类型、数组长度来源、数组元素结构。 */
public record FieldSpec(String name, PType type, String fixedLengthParser, List<FieldSpec> sub) {
}
