package com.j.joker.game.niuniu.proto;

import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * 牛牛客户端/服务端封包格式。
 *
 * <pre>
 * 偏移  长度  字段
 *  0     4   bodyLen = 整包长度 - 4（大端 int）
 *  4     2   魔数 "BY"
 *  6     2   version（客户端固定 1）
 *  8     4   cmd
 * 12     2   gameId
 * 14     2   bizId
 * 16     1   platform
 * 17     1   checkCode（包体置换加密的校验位）
 * 18     n   包体（先按 Cipher 置换）
 * </pre>
 * 无包体时整包正好 18 字节，bodyLen = 14。
 */
public final class PacketCodec {

    public static final int HEADER_LEN = 18;
    public static final int MAGIC = 0x4259; // "BY"

    public record Frame(int cmd, int version, int gameId, int bizId, int platform, byte[] body) {
    }

    private PacketCodec() {
    }

    public static byte[] encode(int cmd, byte[] body) {
        return encode(cmd, 1, 1, 1, 0, body == null ? new byte[0] : body);
    }

    public static byte[] encode(int cmd, int version, int gameId, int bizId, int platform, byte[] body) {
        byte[] plain = body == null ? new byte[0] : body;
        // 大厅 ScoketGame 的心跳也对桌号做字节置换。空探针的包体和校验自然为零。
        byte[] cipher = Cipher.encryptBody(plain);
        int total = HEADER_LEN + cipher.length;
        BinaryWriter w = new BinaryWriter();
        w.i32(total - 4);
        w.u8('B').u8('Y');
        w.u16(version);
        w.i32(cmd);
        w.u16(gameId);
        w.u16(bizId);
        w.u8(platform);
        w.u8(Cipher.checkCode(plain));
        w.bytes(cipher);
        return w.toByteArray();
    }

    public static Frame decode(byte[] packet) {
        if (packet.length < HEADER_LEN) {
            throw new IllegalArgumentException("包长不足: " + packet.length);
        }
        BinaryReader r = new BinaryReader(packet);
        int bodyLen = r.i32();
        int magic = r.u16();
        if (magic != MAGIC) {
            throw new IllegalArgumentException(String.format("魔数错误: 0x%04X", magic));
        }
        int version = r.u16();
        int cmd = r.i32();
        int gameId = r.u16();
        int bizId = r.u16();
        int platform = r.u8();
        int check = r.u8();
        byte[] cipher = r.bytes(packet.length - HEADER_LEN);
        byte[] plain = Cipher.decryptBody(cipher);
        int expect = Cipher.checkCode(plain);
        if (check != 0 && expect != check) {
            throw new IllegalArgumentException(String.format("校验位错误: got=%d expect=%d", check, expect));
        }
        if (bodyLen != packet.length - 4) {
            throw new IllegalArgumentException("长度字段不匹配: " + bodyLen + " vs " + (packet.length - 4));
        }
        return new Frame(cmd, version, gameId, bizId, platform, plain);
    }

    /** 从流里读一整包（阻塞）。 */
    public static Frame readFrame(InputStream in) throws IOException {
        byte[] head = readN(in, 4);
        int bodyLen = ((head[0] & 0xFF) << 24) | ((head[1] & 0xFF) << 16) | ((head[2] & 0xFF) << 8) | (head[3] & 0xFF);
        int total = bodyLen + 4;
        if (total < HEADER_LEN || total > 1024 * 1024) {
            throw new IOException("非法包长: " + total);
        }
        byte[] packet = new byte[total];
        System.arraycopy(head, 0, packet, 0, 4);
        byte[] rest = readN(in, total - 4);
        System.arraycopy(rest, 0, packet, 4, rest.length);
        return decode(packet);
    }

    public static void writeFrame(OutputStream out, int cmd, byte[] body) throws IOException {
        out.write(encode(cmd, body));
        out.flush();
    }

    private static byte[] readN(InputStream in, int n) throws IOException {
        byte[] buf = new byte[n];
        int off = 0;
        while (off < n) {
            int r = in.read(buf, off, n - off);
            if (r < 0) {
                throw new EOFException("连接关闭");
            }
            off += r;
        }
        return buf;
    }
}
