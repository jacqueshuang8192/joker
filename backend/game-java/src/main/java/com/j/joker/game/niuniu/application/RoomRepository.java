package com.j.joker.game.niuniu.application;

import com.j.joker.game.niuniu.domain.table.NiuNiuTable;
import java.util.List;
import java.util.Set;

/** 牌桌持久化边界。finish 必须同时保存退桌通知、清理本桌路由和移除快照。 */
public interface RoomRepository {
    record RoomState(int version, int tid, int activity, int owner, String invite, int club, String rules,
                     boolean closing, Set<Long> admitted, NiuNiuTable.Snapshot table,
                     DouniuService.Vote vote, boolean playerClosed) {}

    int level();
    int serverId();
    List<RoomState> rooms();
    List<DouniuService.End> pendingEnds();
    void save(RoomState room);
    void route(int tid, int activity, long uid);
    void leave(int tid, int activity, long uid);
    void finish(DouniuService.End end, Set<Long> admitted);
    void endSent(DouniuService.End end);
}
