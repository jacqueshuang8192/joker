package com.j.joker.game.niuniu.application;

import com.j.joker.game.niuniu.application.history.RoundRecord;
import com.j.joker.game.niuniu.domain.table.Settlement;
import java.util.Map;
import java.util.UUID;

/** 筹码和战绩用例的出站接口。相同局号的重复提交必须返回相同结果。 */
public interface RoundAccounts {
    record History(int latest, RoundRecord record) {}
    boolean enabled();
    long chips(int uid);
    boolean settle(UUID round, Settlement.Result result, RoundRecord record);
    java.util.List<Integer> clubMembersAfter(int club, int after);
    boolean isClubMember(int club, long uid);
    boolean isClubOwner(int club, long uid);
    History history(int activity, int level, int index);
    Map<String,Object> billboard(int activity, int level, int rounds);
}
