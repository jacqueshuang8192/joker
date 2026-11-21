package com.hbi.interfaces;

/**
 * Created by ceeuoo on 8/24/2016.
 */
public interface IGroupGame {
    /**
     * 创建房间
     * @throws Exception
     */
    public int createRoom(Long userId, int level, int baseChip, int needChip, String inviteCode, Long activityId,
                          int round, String json, String description,String discription2Server,Integer minCoinsGold,Integer max_playerCount,String creatorNickname,String creatorPortrait,String password,int groupId,
                          Integer configId,Integer gameType,String groupName) throws Exception;

    public int createRoomByPassword(Long userId, int level, int baseChip, int needChip, String inviteCode, Long activityId,
                          int round, String json, String description,String discription2Server,Integer minCoinsGold,Integer max_playerCount,String creatorNickname,String creatorPortrait,String password) throws Exception;

    /**
     * 解散房间
     * @throws Exception
     */
    public int dissolveRoom(Long activityId, int tid) throws Exception;

    /**
     * 通知服务器踢人出房间
     * @param userId
     * @param activityId
     */
    public int exitFreeGameByDbDateAndGame(Integer table_id,String userId, String activityId) throws Exception;
}
