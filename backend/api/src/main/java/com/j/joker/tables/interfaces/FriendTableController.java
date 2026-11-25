package com.j.joker.tables.interfaces;

import com.j.joker.tables.application.FriendTables;
import com.j.joker.game.mahjong.domain.HongzhongOptions;
import com.j.joker.vo.response.Response;
import java.util.Arrays;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/friendTable")
@RequiredArgsConstructor
@ConditionalOnProperty(name="JOKER_PURE_JAVA", havingValue="true")
public class FriendTableController {
    private final FriendTables tables;

    private final com.j.joker.tables.application.FriendTableHistory records;

    @PostMapping("/history")
    public Response history(@RequestParam("XYUid") int uid,@RequestParam int level,@RequestParam(defaultValue="0") int before) {
        return result(records.history(uid,level,before));
    }
    @PostMapping("/rounds")
    public Response rounds(@RequestParam("XYUid") int uid,@RequestParam int code) {
        return result(records.rounds(uid,code));
    }
    @PostMapping("/replay")
    public Response replay(@RequestParam("XYUid") int uid,@RequestParam int code,@RequestParam int round,
                           @RequestParam int deal,@RequestParam int step) {
        return result(records.replay(uid,code,round,deal,step));
    }

    @PostMapping("/create")
    public Response create(@RequestParam("XYUid") int uid,@RequestParam int level,@RequestParam String requestId,
                           @RequestParam(defaultValue="1") int rounds,@RequestParam(defaultValue="true") boolean red,
                           @RequestParam(defaultValue="2") int birds) {
        return result(tables.create(uid,level,requestId,rounds,new HongzhongOptions(red,birds)));
    }
    @PostMapping("/join")
    public Response join(@RequestParam("XYUid") int uid,@RequestParam int level,@RequestParam int code) {
        return result(tables.join(uid,level,code));
    }
    @PostMapping("/current")
    public Response current(@RequestParam("XYUid") int uid,@RequestParam int level) {
        return result(tables.current(uid,level));
    }
    @PostMapping("/state")
    public Response state(@RequestParam("XYUid") int uid,@RequestParam int code,
                          @RequestParam(defaultValue="-1") int version) {
        return result(tables.state(uid,code,version));
    }
    @PostMapping("/act")
    public Response act(@RequestParam("XYUid") int uid,@RequestParam int code,@RequestParam int version,
                        @RequestParam String action,@RequestParam(defaultValue="") String cards) {
        if (!cards.isEmpty() && !cards.matches("[0-9]{1,2}(,[0-9]{1,2}){0,38}"))
            throw new IllegalArgumentException("牌码格式有误");
        var selection = cards.isEmpty() ? List.<Integer>of() : Arrays.stream(cards.split(",")).map(Integer::valueOf).toList();
        return result(tables.act(uid,code,version,action,selection));
    }

    private Response result(Object data) {
        var response = new Response();
        response.setData(data);
        return response;
    }
    @ExceptionHandler(IllegalArgumentException.class)
    public Response invalid(IllegalArgumentException error) {
        var response = new Response();
        response.setReturnCode("1"); response.setError(error.getMessage());
        return response;
    }
}
