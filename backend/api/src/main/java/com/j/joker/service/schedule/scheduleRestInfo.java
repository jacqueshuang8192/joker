package com.j.joker.service.schedule;

import com.j.joker.core.util.RedisUtil3;
import com.j.joker.mapper.TGroupPlayerMapper;
import com.j.joker.model.TGroupPlayer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class scheduleRestInfo {

    @Autowired
    private TGroupPlayerMapper groupPlayerMapper;

    @Scheduled(cron="0 0 0 * * ?")
    public void RestClubSTTInfo() {

        List<TGroupPlayer> all = groupPlayerMapper.selectAllClub();
        RedisUtil3 ru = RedisUtil3.getRu();
        if (all != null) {

            for (TGroupPlayer tgp : all) {
                Integer groupId = tgp.getGroupId();
                ru.del(ScheduleConstants.STT_CLUB_PLAYER_GAME_COUNT_YESTERDAY_ + groupId);
                ru.del(ScheduleConstants.STT_CLUB_PLAYER_POINT_CHANGE_YESTERDAY_ + groupId);
                ru.del(ScheduleConstants.STT_CLUB_PLAYER_CONTRI_YESTERDAY_ + groupId);
                ru.del(ScheduleConstants.STT_CLUB_MYSELF_CONTRI_YESTERDAY_ + groupId);
                ru.del(ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_BEFORE_YESTERDAY_ + groupId);
            }

            for (TGroupPlayer tgp : all ) {
                Integer groupId = tgp.getGroupId();
                ru.rename(ScheduleConstants.STT_CLUB_PLAYER_GAME_COUNT_TODAY_ + groupId,ScheduleConstants.STT_CLUB_PLAYER_GAME_COUNT_YESTERDAY_ + groupId);
                ru.rename(ScheduleConstants.STT_CLUB_PLAYER_POINT_CHANGE_TODAY_ + groupId,ScheduleConstants.STT_CLUB_PLAYER_POINT_CHANGE_YESTERDAY_ + groupId);
                ru.rename(ScheduleConstants.STT_CLUB_PLAYER_CONTRI_TODAY_ + groupId,ScheduleConstants.STT_CLUB_PLAYER_CONTRI_YESTERDAY_ + groupId);
                ru.rename(ScheduleConstants.STT_CLUB_MYSELF_CONTRI_TODAY_ + groupId,ScheduleConstants.STT_CLUB_MYSELF_CONTRI_YESTERDAY_ + groupId);

                ru.rename(ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_YESTERDAY_ + groupId, ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_BEFORE_YESTERDAY_ + groupId);
                ru.rename(ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_TODAY_ + groupId,ScheduleConstants.STT_CLUB_TEAM_GAME_COUNT_YESTERDAY_ + groupId);
            }

        }

        ru.del(ScheduleConstants.STT_CLUB_CARD_COUNT_YESTERDAY);
        ru.rename(ScheduleConstants.STT_CLUB_CARD_COUNT_TODAY, ScheduleConstants.STT_CLUB_CARD_COUNT_YESTERDAY);

    }

}
