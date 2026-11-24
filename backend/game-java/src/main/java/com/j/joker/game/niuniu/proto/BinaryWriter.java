package com.j.joker.game.niuniu.proto;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

/**
 * 大端二进制读写，对应客户端 cc.utils.ByteArray（ENDIAN_BIG）。
 */
public final class BinaryWriter {
    private final java.io.ByteArrayOutputStream out = new java.io.ByteArrayOutputStream();
    private Charset charset = StandardCharsets.UTF_8;

    public BinaryWriter charset(Charset cs) {
        this.charset = cs;
        return this;
    }

    public BinaryWriter u8(int v) {
        out.write(v & 0xFF);
        return this;
    }

    public BinaryWriter i8(int v) {
        out.write(v & 0xFF);
        return this;
    }

    public BinaryWriter u16(int v) {
        out.write((v >>> 8) & 0xFF);
        out.write(v & 0xFF);
        return this;
    }

    public BinaryWriter i16(int v) {
        return u16(v);
    }

    public BinaryWriter i32(int v) {
        out.write((v >>> 24) & 0xFF);
        out.write((v >>> 16) & 0xFF);
        out.write((v >>> 8) & 0xFF);
        out.write(v & 0xFF);
        return this;
    }

    public BinaryWriter i64(long v) {
        for (int shift = 56; shift >= 0; shift -= 8) {
            out.write((int) (v >>> shift) & 0xFF);
        }
        return this;
    }

    public BinaryWriter bytes(byte[] b) {
        out.write(b, 0, b.length);
        return this;
    }

    public BinaryWriter rawString(String s) {
        return bytes(s.getBytes(charset));
    }

    /** 协议 STRING：4 字节长度（含结尾 0）+ 内容 + 0。 */
    public BinaryWriter string(String s) {
        byte[] b = s.getBytes(charset);
        i32(b.length + 1);
        bytes(b);
        out.write(0);
        return this;
    }

    public byte[] toByteArray() {
        return out.toByteArray();
    }

    public int size() {
        return out.size();
    }
}
