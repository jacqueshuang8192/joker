package com.j.joker.wallet;

import com.j.joker.core.util.ConfigUtil;
import com.j.joker.vo.response.Response;
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.web.bind.annotation.*;

@RestController
@ConditionalOnProperty(name="JOKER_PURE_JAVA", havingValue="true")
public class ChipPurchaseController {
    @PostMapping("/wallet/purchaseChips")
    public Response purchase(@RequestParam("XYUid") int uid, @RequestParam int chips,
                             @RequestParam String requestId) throws IOException {
        var response = new Response();
        if (chips <= 0 || !requestId.matches("[a-zA-Z0-9_-]{8,64}")) {
            response.setReturnCode("1");
            response.setError("筹码数量或订单号无效");
            return response;
        }
        try (var socket = new Socket()) {
            socket.connect(new InetSocketAddress(ConfigUtil.get("game.ip"), Integer.parseInt(ConfigUtil.get("game.port"))),2000);
            socket.setSoTimeout(5000);
            var key = requestId.getBytes(StandardCharsets.US_ASCII);
            var out = new DataOutputStream(socket.getOutputStream());
            out.writeInt(39+key.length); out.writeShort(0x4259); out.writeShort(0);
            out.writeInt(0x301a); out.writeInt(0); out.writeShort(0);
            out.writeInt(uid); out.writeInt(0); out.writeInt(chips); out.writeInt(1200); out.writeInt(0);
            out.writeInt(key.length+1); out.write(key); out.writeByte(0); out.flush();
            var in = new DataInputStream(socket.getInputStream());
            if (in.readInt()!=30 || in.readUnsignedShort()!=0x4259) throw new IOException("筹码购买回执长度错误");
            in.readShort();
            if (in.readInt()!=0x301a) throw new IOException("筹码购买回执命令错误");
            in.skipNBytes(6);
            int accepted=in.readInt(), after=in.readInt();
            in.readInt(); // 旧报文的钱包余额只有 32 位。这里只展示本单筹码。
            if (in.readInt()!=chips) throw new IOException("筹码购买回执数量错误");
            if (accepted==1) response.setData(Map.of("requestId",requestId,"chips",chips,"chipsAfter",after));
            else {
                response.setReturnCode("1");
                response.setError("购买未执行，请核对余额、在桌状态及订单号");
            }
            return response;
        }
    }
}
