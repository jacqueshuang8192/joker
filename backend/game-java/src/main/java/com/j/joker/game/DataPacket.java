package com.j.joker.game;

import io.netty.buffer.ByteBuf;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.io.ByteArrayOutputStream;

final class DataPacket {
    private final int command;
    private final ByteArrayOutputStream body = new ByteArrayOutputStream();

    DataPacket(int command) { this.command = command; }

    static String string(ByteBuf input) {
        int size = input.readInt();
        if (size <= 0 || size > input.readableBytes() || input.getByte(input.readerIndex() + size - 1) != 0)
            throw new IllegalArgumentException("Invalid BY string");
        // Some clients send GBK. Keep the original bytes for forwarding audit messages.
        String text = input.readCharSequence(size - 1, StandardCharsets.ISO_8859_1).toString();
        input.skipBytes(1);
        return text;
    }

    DataPacket ints(int... values) {
        for (int value : values) body.writeBytes(ByteBuffer.allocate(4).putInt(value).array());
        return this;
    }
    DataPacket number(long value) {
        body.writeBytes(ByteBuffer.allocate(8).putLong(value).array());
        return this;
    }
    DataPacket text(String value) {
        byte[] bytes = value.getBytes(StandardCharsets.ISO_8859_1);
        ints(bytes.length + 1);
        body.writeBytes(bytes);
        body.write(0);
        return this;
    }
    DataPacket utf8Text(String value) {
        byte[] bytes=value.getBytes(StandardCharsets.UTF_8);
        ints(bytes.length+1);
        body.writeBytes(bytes);
        body.write(0);
        return this;
    }
    DataPacket utf8(String value) {
        body.writeBytes(value.getBytes(StandardCharsets.UTF_8));
        return this;
    }

    byte[] bytes() {
        // NETOutputPacket::Begin initializes a new header, including game and region zero.
        return ByteBuffer.allocate(18 + body.size()).putInt(14 + body.size()).putShort((short) 0x4259)
                .putShort((short) 0).putInt(command).putInt(0).putShort((short) 0).put(body.toByteArray()).array();
    }
}
