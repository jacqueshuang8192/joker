package com.j.joker.game.niuniu.proto;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** 按 Schema 编解码包体。 */
public final class SchemaCodec {

    private SchemaCodec() {
    }

    public static byte[] encode(Schema schema, Map<String, Object> values) {
        BinaryWriter w = new BinaryWriter();
        writeFields(w, schema.fields(), values);
        return w.toByteArray();
    }

    public static Map<String, Object> decode(Schema schema, byte[] body) {
        BinaryReader r = new BinaryReader(body);
        return readFields(r, schema.fields());
    }

    private static void writeFields(BinaryWriter w, List<FieldSpec> fields, Map<String, Object> values) {
        for (FieldSpec f : fields) {
            Object v = values.get(f.name());
            switch (f.type()) {
                case UBYTE, BYTE -> w.u8(asInt(v));
                case SHORT, USHORT -> w.u16(asInt(v));
                case INT, UINT -> w.i32(asInt(v));
                case LONG, ULONG -> w.i64(asLong(v));
                case STRING -> w.string(v == null ? "" : String.valueOf(v));
                case STRINGBYTES -> w.rawString(v == null ? "" : String.valueOf(v));
                case ARRAY -> {
                    List<?> list = v instanceof List<?> l ? l : List.of();
                    int count = f.fixedLengthParser() == null ? list.size() : asInt(values.get(f.fixedLengthParser()));
                    if (count < 0) {
                        count = list.size();
                    }
                    for (int i = 0; i < count; i++) {
                        Object item = i < list.size() ? list.get(i) : null;
                        if (f.sub().isEmpty()) {
                            w.u8(asInt(item));
                        } else if (f.sub().size() == 1 && f.sub().getFirst().name().isEmpty()) {
                            writeFields(w, f.sub(), Map.of("", item == null ? 0 : item));
                        } else {
                            @SuppressWarnings("unchecked")
                            Map<String, Object> m = item instanceof Map<?, ?> mm
                                    ? (Map<String, Object>) mm
                                    : new LinkedHashMap<>();
                            writeFields(w, f.sub(), m);
                        }
                    }
                }
            }
        }
    }

    private static Map<String, Object> readFields(BinaryReader r, List<FieldSpec> fields) {
        Map<String, Object> out = new LinkedHashMap<>();
        for (FieldSpec f : fields) {
            switch (f.type()) {
                case UBYTE -> out.put(f.name(), r.u8());
                case BYTE -> out.put(f.name(), r.i8());
                case SHORT -> out.put(f.name(), r.i16());
                case USHORT -> out.put(f.name(), r.u16());
                case INT, UINT -> out.put(f.name(), r.i32());
                case LONG, ULONG -> out.put(f.name(), r.i64());
                case STRING -> out.put(f.name(), r.string());
                case STRINGBYTES -> out.put(f.name(), r.stringBytes(r.remaining()));
                case ARRAY -> {
                    int count = f.fixedLengthParser() == null ? 0 : asInt(out.get(f.fixedLengthParser()));
                    List<Object> list = new ArrayList<>(Math.max(0, Math.min(count, 4096)));
                    for (int i = 0; i < count; i++) {
                        if (f.sub().isEmpty()) {
                            list.add(r.u8());
                        } else {
                            var item = readFields(r, f.sub());
                            list.add(item.containsKey("") ? item.get("") : item);
                        }
                    }
                    out.put(f.name(), list);
                }
            }
        }
        return out;
    }

    private static int asInt(Object v) {
        return v instanceof Number n ? n.intValue() : 0;
    }

    private static long asLong(Object v) {
        return v instanceof Number n ? n.longValue() : 0L;
    }
}
