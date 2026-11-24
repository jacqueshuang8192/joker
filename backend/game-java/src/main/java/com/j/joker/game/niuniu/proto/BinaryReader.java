package com.j.joker.game.niuniu.proto;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

/** 大端二进制读取，与 BinaryWriter 对称。 */
public final class BinaryReader {
    private final byte[] data;
    private int pos;
    private Charset charset = StandardCharsets.UTF_8;

    public BinaryReader(byte[] data) {
        this.data = data;
    }

    public BinaryReader charset(Charset cs) {
        this.charset = cs;
        return this;
    }

    public int remaining() {
        return data.length - pos;
    }

    public int u8() {
        return data[pos++] & 0xFF;
    }

    public int i8() {
        return data[pos++];
    }

    public int u16() {
        int v = ((data[pos] & 0xFF) << 8) | (data[pos + 1] & 0xFF);
        pos += 2;
        return v;
    }

    public int i16() {
        return (short) u16();
    }

    public int i32() {
        int v = ((data[pos] & 0xFF) << 24) | ((data[pos + 1] & 0xFF) << 16)
                | ((data[pos + 2] & 0xFF) << 8) | (data[pos + 3] & 0xFF);
        pos += 4;
        return v;
    }

    public long i64() {
        long v = 0;
        for (int i = 0; i < 8; i++) {
            v = (v << 8) | (data[pos++] & 0xFFL);
        }
        return v;
    }

    public byte[] bytes(int n) {
        if (n < 0 || n > remaining()) throw new IllegalArgumentException("无效字段长度");
        byte[] b = new byte[n];
        System.arraycopy(data, pos, b, 0, n);
        pos += n;
        return b;
    }

    /**
     * 协议 STRING：读 4 字节长度（含结尾 0），内容去掉结尾 0。
     * 客户端解析器带容错：末字节不是 0 时按整长度取字符串。
     */
    public String string() {
        int len = i32();
        if (len <= 0) {
            return "";
        }
        byte[] raw = bytes(len);
        int n = len;
        if (n > 0 && raw[n - 1] == 0) {
            n--;
        }
        return new String(raw, 0, n, charset);
    }

    public String stringBytes(int n) {
        return new String(bytes(n), charset);
    }
}
