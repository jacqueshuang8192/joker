package com.j.joker.game.niuniu.proto;

import java.util.List;

/** 协议字段类型，对应客户端 PACKET_DATA_TYPE。 */
public enum PType {
    UBYTE, BYTE, SHORT, USHORT, INT, UINT, LONG, ULONG, STRING, STRINGBYTES, ARRAY;

    public static PType of(String s) {
        if (s == null) {
            return BYTE;
        }
        return switch (s.trim().toLowerCase(java.util.Locale.ROOT)) {
            case "ubyte" -> UBYTE;
            case "short" -> SHORT;
            case "ushort" -> USHORT;
            case "int" -> INT;
            case "uint" -> UINT;
            case "long", "int64" -> LONG;
            case "ulong" -> ULONG;
            case "string" -> STRING;
            case "stringbytes" -> STRINGBYTES;
            case "array" -> ARRAY;
            default -> BYTE;
        };
    }
}
