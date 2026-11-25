package com.j.joker.wallet;

import com.j.joker.core.util.ConfigUtil;
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import org.springframework.stereotype.Service;

@Service
class DiamondGifts {
    void notifyRecipient(int uid,int count) {
        var notice=new com.alibaba.fastjson.JSONObject();
        notice.put("type","exchangeGold");
        notice.put("count",count);
        try { com.j.joker.utils.GameServerUtil.notice2HallPublice((long)uid,notice); }
        catch (IOException failure) {
            org.slf4j.LoggerFactory.getLogger(DiamondGifts.class).warn("玩家 {} 的赠钻已入账，大厅通知未送达",uid,failure);
        }
    }

    int transfer(int sender,int recipient,int count,String request,String remark) throws IOException {
        byte[] key = request.getBytes(StandardCharsets.US_ASCII), note = remark.getBytes(StandardCharsets.UTF_8);
        try (var socket = new Socket()) {
            socket.connect(new InetSocketAddress(ConfigUtil.get("game.ip"),Integer.parseInt(ConfigUtil.get("game.port"))),2000);
            socket.setSoTimeout(5000);
            var out = new DataOutputStream(socket.getOutputStream());
            out.writeInt(31+key.length+note.length);
            out.writeShort(0x4259); out.writeShort(1); out.writeInt(0x101a); out.writeInt(0); out.writeShort(0);
            out.writeInt(sender); out.writeInt(recipient); out.writeInt(count);
            out.writeInt(key.length+1); out.write(key); out.writeByte(0); out.write(note); out.flush();
            var in = new DataInputStream(socket.getInputStream());
            if (in.readInt()!=18 || in.readUnsignedShort()!=0x4259) throw new IOException("赠钻响应长度或标记无效");
            in.readShort();
            if (in.readInt()!=0x201a) throw new IOException("赠钻响应命令无效");
            in.skipNBytes(6);
            return in.readInt();
        }
    }
}
