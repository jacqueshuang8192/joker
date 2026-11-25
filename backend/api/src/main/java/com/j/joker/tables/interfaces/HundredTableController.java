package com.j.joker.tables.interfaces;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.j.joker.core.util.ConfigUtil;
import com.j.joker.game.hundred.infrastructure.HundredClient;
import com.j.joker.vo.response.Response;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.web.bind.annotation.*;
import java.io.IOException;

@RestController
@RequestMapping("/hundredTable")
@RequiredArgsConstructor
@ConditionalOnProperty(name="JOKER_PURE_JAVA",havingValue="true")
public class HundredTableController {
    private final ObjectMapper json;

    @PostMapping("/{operation:state|apply|withdraw|bet|history}")
    public Response handle(@RequestParam("XYUid") int uid,@RequestParam int tid,@PathVariable String operation,
                           @RequestParam(defaultValue="") String round,@RequestParam(defaultValue="") String requestId,
                           @RequestParam(defaultValue="0") int area,@RequestParam(defaultValue="0") int chips) throws IOException {
        var result=new Response();
        try {
            var data=new HundredClient(ConfigUtil.get("game.ip"),Integer.parseInt(ConfigUtil.get("game.port")));
            int command=switch(operation) { case "state" -> 0; case "apply" -> 1; case "withdraw" -> 2; case "bet" -> 3; case "history" -> 5;
                default -> throw new IllegalArgumentException("未知操作"); };
            var state=json.readTree(data.execute(tid,uid,command,round,requestId,area,chips));
            if(state.has("error")) throw new IllegalArgumentException(state.get("error").asText());
            result.setData(json.convertValue(state,java.util.Map.class));
        } catch(IllegalArgumentException e) {
            result.setReturnCode("1"); result.setError(e.getMessage());
        }
        return result;
    }
}
