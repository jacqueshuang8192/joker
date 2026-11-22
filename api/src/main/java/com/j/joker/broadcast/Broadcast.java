package com.j.joker.broadcast;

import com.alibaba.fastjson.JSONObject;
import com.j.joker.impl.protocol.Protocol;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.util.List;

/**
 * Created by ceeuoo on 9/5/2016.
 */
public class Broadcast extends Protocol {
    private String ip;
    private int port;
    private byte[] protocolNo;

    public Broadcast(String ip, int port, byte[] protocolNo) {
        this.ip = ip;
        this.port = port;
        this.protocolNo = protocolNo;
    }

    public void sendBroadcast(String msg) throws IOException {
        Socket socket = new Socket(ip, port);
        socket.setSoTimeout(10 * 1000);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();

        try {
            byte[] packet = buildPacket(msg);
            out.write(packet);
            out.flush();

        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            out.close();
            in.close();
            socket.close();
        }
    }

    public byte[] buildPacket(String msg) {
        List<Byte> list = initPacketHead();
        initPacketBody(list, msg);
        Integer length = list.size();
        byte[] array = new byte[length];
        for (int i = 0; i < length; i++) {
            array[i] = list.get(i);
        }
        byte[] b = intToBytes(length - 4);
        for (int i = 0; i < b.length; i++) {
            array[i] = b[i];
        }
        return array;
    }

    private List<Byte> initPacketHead() {
        return super.initPacketHead(protocolNo);
    }

    private void initPacketBody(List<Byte> list, String msg) {
        JSONObject json = new JSONObject();
        json.put("cmd", "102");
        JSONObject data = new JSONObject();
        data.put("msg", msg);
        json.put("data", data);
        String str = json.toString();
        writeString(list, str);
    }

    public static void main(String[] strings) throws IOException {
        byte[] protocolNo = new byte[2];
        protocolNo[0] = 0x01;
        protocolNo[1] = 0x01;
        Broadcast broadcast = new Broadcast("192.168.1.106", 12358, protocolNo);
        broadcast.sendBroadcast("hello");
    }
}
