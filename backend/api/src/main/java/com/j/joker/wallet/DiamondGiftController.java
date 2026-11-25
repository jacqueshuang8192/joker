package com.j.joker.wallet;

import com.j.joker.service.player.PlayerService;
import com.j.joker.vo.response.Response;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@ConditionalOnProperty(name="JOKER_PURE_JAVA", havingValue="true")
public class DiamondGiftController {
    private final DiamondGifts gifts;
    private final PlayerService players;

    @PostMapping("/playerXXX")
    public Response give(@RequestParam("XYUid") int uid, @RequestParam("playerId1") int sender,
                         @RequestParam("playerId2") int recipient, @RequestParam int count,
                         @RequestParam(defaultValue="") String remark, @RequestParam(defaultValue="") String requestId) {
        if (uid != sender || sender <= 0 || recipient <= 0 || sender == recipient || count <= 0 || remark.length()>255)
            return error("赠送账号、数量或备注无效");
        if (!requestId.matches("[a-zA-Z0-9_-]{8,64}")) return error("请更新客户端后赠送");
        try {
            return switch (gifts.transfer(sender,recipient,count,requestId,remark)) {
                case 0 -> {
                    gifts.notifyRecipient(recipient,count);
                    yield success();
                }
                case 5 -> success();
                case 2 -> error("请先退出牌桌或等待上一笔赠送完成");
                case 3 -> error("玩家钱包不存在");
                case 4 -> error("钱包余额不足或超出上限");
                default -> error("赠送请求编号与先前记录不符");
            };
        } catch (java.io.IOException unavailable) {
            // HTTP 非 200 让旧客户端用同一组参数重试，沿用原请求编号。
            throw new org.springframework.web.server.ResponseStatusException(
                    org.springframework.http.HttpStatus.SERVICE_UNAVAILABLE,"赠送回执待确认",unavailable);
        }
    }

    @PostMapping("/queryPlayerXXX")
    public Response history(@RequestParam("XYUid") int uid, @RequestParam("playerId1") int sender,
                            @RequestParam int type, @RequestParam(defaultValue="1") int currentPage,
                            @RequestParam(defaultValue="30") int pageSize) {
        if (uid!=sender || type<1 || type>2 || currentPage<1 || pageSize<1 || pageSize>100
                || (long)currentPage*pageSize>Integer.MAX_VALUE) return error("赠送记录查询参数无效");
        return players.queryPlayerXXX(uid,type,Integer.toString(currentPage),Integer.toString(pageSize));
    }

    private static Response success() {
        var reply = new Response();
        reply.setData("赠送成功");
        return reply;
    }

    private static Response error(String message) {
        var result = new Response();
        result.setReturnCode("1");
        result.setError(message);
        return result;
    }
}
