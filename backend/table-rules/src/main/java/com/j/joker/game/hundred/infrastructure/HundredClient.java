package com.j.joker.game.hundred.infrastructure;

import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;

/** API 与大厅只传递当前会话的账号，钱包由内部 data 端点统一提交。 */
public record HundredClient(String host,int port) {
    public String execute(int tid,int uid,int action,String round,String key,int area,int chips) throws IOException {
        if(round.length()>36 || key.length()>64) throw new IllegalArgumentException("局号或订单号过长");
        var body=new ByteArrayOutputStream();
        var fields=new DataOutputStream(body);
        fields.writeInt(tid); fields.writeInt(uid); fields.writeInt(action);
        string(fields,round); string(fields,key); fields.writeInt(area); fields.writeInt(chips);
        try(var socket=new Socket()) {
            socket.connect(new InetSocketAddress(host,port),2000);
            socket.setSoTimeout(5000);
            var out=new DataOutputStream(socket.getOutputStream());
            out.writeInt(14+body.size()); out.writeShort(0x4259); out.writeShort(0); out.writeInt(0x101d);
            out.writeInt(0); out.writeShort(0); body.writeTo(out); out.flush();
            var in=new DataInputStream(socket.getInputStream());
            int length=in.readInt();
            if(length<19 || length>256*1024 || in.readUnsignedShort()!=0x4259) throw new IOException("百人场响应格式错误");
            in.readShort();
            if(in.readInt()!=0x201d) throw new IOException("百人场响应命令错误");
            in.skipNBytes(6);
            int size=in.readInt();
            if(size!=length-18) throw new IOException("百人场响应长度错误");
            var bytes=new byte[size-1]; in.readFully(bytes);
            if(in.readUnsignedByte()!=0) throw new IOException("百人场响应缺少结束符");
            return new String(bytes,StandardCharsets.UTF_8);
        }
    }
    private static void string(DataOutputStream out,String value) throws IOException {
        var bytes=value.getBytes(StandardCharsets.US_ASCII);
        out.writeInt(bytes.length+1); out.write(bytes); out.writeByte(0);
    }
}
