package com.hbi.ioc.groupgame;

import com.core.util.ApplicationContextHelper;
import com.hbi.interfaces.IGroupGame;

/**
 * Created by ceeuoo on 8/24/2016.
 */
public class GroupGameService {
    private IGroupGame groupGame;

    public GroupGameService() {
        groupGame = (IGroupGame) ApplicationContextHelper.getBean("groupGameBean");
    }

    public void createRoom() throws Exception {
//        groupGame.createRoom();
    }

    public void dissolveRoom(Long activityId, int tid) throws Exception {
        groupGame.dissolveRoom(activityId, tid);
    }
}
