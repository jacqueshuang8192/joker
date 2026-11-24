package com.j.joker.controller.common;

import com.j.joker.constants.Constants;
import com.j.joker.mapper.TActivityMapper;
import com.j.joker.service.Gold.GoldService;
import com.j.joker.service.common.GoodsService;
import com.j.joker.service.game.FreeGameService;
import com.j.joker.service.tack.TPlayerTaskService;
import com.j.joker.vo.response.Response;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

/** 大厅客户端读取商品、兑换、任务、财富榜和牌局记录的入口。 */
@RestController
public class HallReadController {
    private final GoodsService goods;
    private final GoldService gold;
    private final FreeGameService games;
    private final TActivityMapper activities;
    private final TPlayerTaskService tasks;

    public HallReadController(GoodsService goods, GoldService gold, FreeGameService games,
                              TActivityMapper activities, TPlayerTaskService tasks) {
        this.goods = goods;
        this.gold = gold;
        this.games = games;
        this.activities = activities;
        this.tasks = tasks;
    }

    @RequestMapping(value = "/goods/queryGoodsList", method = {RequestMethod.GET, RequestMethod.POST})
    public Response goods(@RequestParam("XYUid") long uid, @RequestParam(name = "type", required = false) String type,
                          @RequestParam(name = "device", required = false) Integer device) throws Exception {
        return success(Map.of("list", goods.findImsGoodsByTpey(type, device, uid)));
    }

    @PostMapping("/goods/queryExchangeHistory")
    public Response history(@RequestParam("XYUid") long uid) {
        return success(goods.queryExchangeHistory(uid));
    }

    @PostMapping("/task/getTaskList")
    public Response tasks(@RequestParam("XYUid") long uid) {
        return success(tasks.getTaskList(uid));
    }

    @PostMapping("/gold/getGoldRanking")
    public Response ranking() throws Exception {
        return success(gold.getGoldRanking());
    }

    @PostMapping("/freeGame/querRoundsByActivityId")
    public Response rounds(@RequestParam("XYUid") long uid, @RequestParam("activityId") long activityId) throws Exception {
        if (activities.canReadRounds(uid, activityId)) return success(games.querRoundsByActivityId(activityId));
        Response response = new Response();
        response.setReturnCode(Constants.RETURN_CODE_FAIL);
        response.setError("没有可查看的牌局记录");
        return response;
    }

    private static Response success(Object data) {
        Response response = new Response();
        response.setData(data);
        return response;
    }
}
