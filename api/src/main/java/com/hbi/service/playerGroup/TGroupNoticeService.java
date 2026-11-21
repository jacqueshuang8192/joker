package com.hbi.service.playerGroup;

import com.hbi.constants.Constants;
import com.hbi.mapper.TGroupNoticeMapper;
import com.hbi.mapper.TGroupPlayerMapper;
import com.hbi.mapper.TPlayerGroupMapper;
import com.hbi.model.TGroupNotice;
import com.hbi.utils.InfServerException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * Create by Mars on 2019/6/12 17:43
 */
@Service
public class TGroupNoticeService {

    @Autowired
    private TGroupNoticeMapper groupNoticeMapper;
    @Autowired
    private TGroupPlayerMapper groupPlayerMapper;
    @Autowired
    private TPlayerGroupMapper playerGroupMapper;

    public void updateNotice(Integer groupId, Integer ownerId, String notice) throws Exception {
        // 只有联盟群主才能修改公告
        Long dbOwnerId = groupPlayerMapper.queryGroupOwerId(groupId);
        if(((long) ownerId) != dbOwnerId){
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "只有联盟群主才能修改公告");
        }
        TGroupNotice tGroupNotice = groupNoticeMapper.getByGroupId(groupId);
        if(tGroupNotice == null) {
            // 如果之前没有公告，创建公告
            tGroupNotice = new TGroupNotice();
            tGroupNotice.setGroupId(groupId);
            tGroupNotice.setNotice(notice);
            groupNoticeMapper.insertTGroupNotice(tGroupNotice);
        }else {
            // 如果之前有公告，修改公告
            tGroupNotice.setNotice(notice);
            groupNoticeMapper.updateTGroupNotice(tGroupNotice);
        }
    }

    public TGroupNotice getNotice(Integer groupId, Integer playerId) throws Exception {
        // 不是群成员，没有权限查看！
//        Integer count = playerGroupMapper.countByGroupIdAndPlayerId(groupId, playerId);
//        if(count == 0){
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, "不是群成员，没有权限查看！");
//        }
        TGroupNotice tGroupNotice = groupNoticeMapper.getByGroupId(groupId);
        if(tGroupNotice == null) {
            // 如果之前没有公告，创建公告
            tGroupNotice = new TGroupNotice();
            tGroupNotice.setGroupId(groupId);
            tGroupNotice.setNotice("");
            groupNoticeMapper.insertTGroupNotice(tGroupNotice);
        }
        return tGroupNotice;
    }
}
