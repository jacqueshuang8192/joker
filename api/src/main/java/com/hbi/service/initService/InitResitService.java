package com.hbi.service.initService;

import com.core.util.RedisUtil;
import com.core.util.RedisUtil1;
import com.core.util.RedisUtil3;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.constants.ClubConstants;
import com.hbi.mapper.TPlayerGroupMapper;
import com.hbi.model.TPlayerGroup;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import tk.mybatis.mapper.entity.Example;

import java.util.List;

/**
 * Create by Mars on 2019/7/20 21:42
 */
@Service
public class InitResitService implements InitializingBean {

    @Autowired
    private TPlayerGroupMapper playerGroupMapper;

    @Override
    public void afterPropertiesSet() throws Exception {

        RedisUtil ru = RedisUtil.getRu();
        RedisUtil3 ru3 = RedisUtil3.getRu();
        RedisUtil1 ru1 = RedisUtil1.getRu();

        System.out.println("初始化redis锁--》");

        ru.del("WAIT_CLOSE_GROUP_LOCK");
        ru.del("JIFENPROFIT_LOCK");
        ru3.del("GAME_RESULT_QUEUE_LOCK");
        ru.del("USER_POINT_CHANGE_LOCK");


        //初始化邀请码
        try {
            boolean exist = ru1.exists(ClubConstants.Club_Invite_Code_Set);
            System.out.println("exist-->" + exist);
            if (!exist) {

                Example example = new Example(TPlayerGroup.class);
                List<TPlayerGroup> tPlayerGroups = playerGroupMapper.selectByExample(example);
                System.out.println(tPlayerGroups.size());
                System.out.println("初始化邀请码---->");
                for (TPlayerGroup pl: tPlayerGroups) {
                    ru1.sadd(ClubConstants.Club_Invite_Code_Set,pl.getInviteCode());
                }

            }

        }catch (Exception e ) {
            System.out.println(e);
            System.out.println("初始化邀请码失败--->");
        }finally {

        }

    }
}
