package com.j.joker.impl.protocol;

import java.nio.charset.StandardCharsets;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by ceeuoo on 9/5/2016.
 */
public abstract class Protocol {

    protected List<Byte> initPacketHead(byte[] protocolNo) {
        List<Byte> list = new ArrayList<Byte>();
        addZeros(4, list);
        // BY
        list.add((byte) 'B');
        list.add((byte) 'Y');
        // version
        list.add((byte) 0);
        list.add((byte) 1);

        // Cmd
        addZeros(2, list);
        list.add(protocolNo[0]);
        list.add((protocolNo[1]));

        // gameid
        addZeros(2, list);

        // regionid
        addZeros(2, list);

        // deviceid
        addZeros(1, list);

        // code
        addZeros(1, list);
        return list;
    }

    protected void addZeros(int num, List<Byte> list) {
        for (int i = 0; i < num; i++) {
            list.add((byte) 0);
        }
    }

    protected byte[] intToBytes(int value) {
        byte[] src = new byte[4];
        src[0] = (byte) ((value >> 24) & 0xFF);
        src[1] = (byte) ((value >> 16) & 0xFF);
        src[2] = (byte) ((value >> 8) & 0xFF);
        src[3] = (byte) (value & 0xFF);
        return src;
    }

    protected void writeUid(List<Byte> packet, Long userId) {
        int id = userId.intValue();
        byte[] b = intToBytes(id);
        for (byte c : b) {
            packet.add(c);
        }
    }

    protected void writeInt(List<Byte> packet, int value) {
        byte[] b = intToBytes(value);
        for (byte c : b) {
            packet.add(c);
        }
    }

    protected void writeString(List<Byte> packet, String str) {
        if (str == null) {
            str = "";
        }
        byte[] bytes = str.getBytes(StandardCharsets.UTF_8);
        writeInt(packet, bytes.length + 1);
        for (byte value : bytes) packet.add(value);
        packet.add((byte) 0);
    }
}
