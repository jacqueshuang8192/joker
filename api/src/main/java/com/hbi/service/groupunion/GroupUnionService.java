package com.hbi.service.groupunion;

import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.GroupPlayerCacheController;
import com.hbi.constants.Constants;
import com.hbi.enums.PlayerTypeEnum;
import com.hbi.mapper.groupunion.GroupUnionMapper;
import com.hbi.mapper.groupunion.GroupUnionMemberMapper;
import com.hbi.utils.InfServerException;
import com.hbi.model.TGroupUnionMember;
import com.hbi.model.TGroupUnion;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;

/**
 * Create by Mars on 2019/5/27 15:40
 */
@Service
public class GroupUnionService {

    @Autowired
    private GroupUnionMapper groupUnionMapper;
    @Autowired
    private GroupUnionMemberMapper groupUnionMemberMapper;
    @Autowired
    private GroupPlayerCacheController groupPlayerCacheController;

    public void createGroupUnion(String unionName, Integer playerId) throws Exception {
        // 创建联盟，返回联盟编号
        TGroupUnion TGroupUnion = new TGroupUnion(unionName);
        groupUnionMapper.add(TGroupUnion);
        // 把创建人加入到成员表，成员类型是盟主
        TGroupUnionMember TGroupUnionMember = new TGroupUnionMember();
        TGroupUnionMember.setPlayerId(playerId);
        TGroupUnionMember.setInviterId(playerId);
        TGroupUnionMember.setUnionId(TGroupUnion.getId());
        TGroupUnionMember.setCreateTime(new Date());
        TGroupUnionMember.setPlayerType(PlayerTypeEnum.MASTER);
        TGroupUnionMember.setBonus(100.00);
        groupUnionMemberMapper.add(TGroupUnionMember);
    }

    public void addMgr(Integer unionId, Integer playerId1, Integer playerId2) throws Exception {

        ICache cache = null;

        try {
            cache = CacheManager.getCache();

            // 不能添加自己
            if(playerId1 == playerId2){
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "不能添加自己");
            }
            // 盟主才能添加副盟主
            Integer playerType1 = groupUnionMemberMapper.getPlayerTypeByPlayerIdAndUnionId(playerId1, unionId);
            if(playerType1 != PlayerTypeEnum.MASTER){
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "盟主才有权限添加副盟主");
            }
            Integer playerType2 = groupUnionMemberMapper.getPlayerTypeByPlayerIdAndUnionId(playerId2, unionId);
            if(playerType2 != null){
                if(playerType2 == PlayerTypeEnum.MASTER) {
                    // 不能重复添加
                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "不能重复添加");
                }else{
                    // 如果已经是联盟里的普通成员，设置成副盟主
                    groupUnionMemberMapper.setPlayerType(unionId, playerId2, PlayerTypeEnum.MANAGER);
                    groupPlayerCacheController.removeRoleType(cache,unionId,playerId2);

                }
            }else {
                // 不在联盟，就添加副盟主
                TGroupUnionMember TGroupUnionMember = new TGroupUnionMember();
                TGroupUnionMember.setPlayerId(playerId2);
                TGroupUnionMember.setInviterId(playerId1);
                TGroupUnionMember.setUnionId(unionId);
                TGroupUnionMember.setCreateTime(new Date());
                TGroupUnionMember.setPlayerType(PlayerTypeEnum.MANAGER);
                TGroupUnionMember.setBonus(0.00);
                groupUnionMemberMapper.add(TGroupUnionMember);
                groupPlayerCacheController.removeRoleType(cache,unionId,playerId2);
            }

        } catch (Exception e ) {
            throw e;
        }finally {
            CacheManager.releaseCache(cache);
        }


    }

    public void addGroup(Integer playerId, Integer unionId, Integer groupId, Double bonus) {
        // 判断邀请人是不是联盟联盟盟主，只有盟主、管理员才能才能添加群组
        Integer playerType = groupUnionMemberMapper.getPlayerTypeByPlayerIdAndUnionId(playerId, unionId);
        if(playerType == null){
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "操作错误：玩家没有权限添加联盟，请联系盟主申请!!");
        }else if(playerType != 0 && playerId != 1){
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "玩家没有权限添加联盟，请联系盟主申请!!");
        }
        // 添加联盟成员到联盟
        groupUnionMemberMapper.addUnoinMember4Group(unionId, playerId, groupId, bonus, new Date());
    }

    public void setBonus(Integer playerId, Integer unionId, Integer groupId, Double bonus) {
        // 判断邀请人是不是联盟盟主，只有盟主、管理员才能才能设置群组成员分红
        Integer playerType = groupUnionMemberMapper.getPlayerTypeByPlayerIdAndUnionId(playerId, unionId);
        if(playerType == null){
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "操作错误：玩家没有权限设置联盟分红!!");
        }else if(playerType != 0 && playerId != 1){
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "玩家没有权限设置联盟分红!!");
        }
        // 给原群群主设置分红
        groupUnionMapper.setBonus(unionId, groupId, bonus, PlayerTypeEnum.OLD_MASTER);
    }

    public void setCost(Integer unionId, Integer playerId, Integer costPattern, Double commission, Integer costUserType) {
        // 只有盟主或管理员才能设置抽水
        Integer playerType = groupUnionMemberMapper.getPlayerTypeByPlayerIdAndUnionId(playerId, unionId);
        if(playerType == null){
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "操作错误：玩家没有权限设置联盟抽水!!");
        }else if(playerType != 0 && playerId != 1){
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "玩家没有权限设置联盟抽水!!");
        }
        groupUnionMapper.setCost(unionId, costPattern, commission, costUserType);
    }
}
