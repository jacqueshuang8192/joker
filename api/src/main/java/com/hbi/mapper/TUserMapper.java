package com.hbi.mapper;

import com.hbi.cache.model.CacheUserListProfile;
import com.hbi.model.ImsTpCard;
import com.hbi.model.TBiqiCardId;
import com.hbi.model.TUser;
import com.hbi.vo.request.common.CommissionVo;
import com.hbi.vo.request.common.MapVo;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

import java.util.List;
import java.util.Map;

public interface TUserMapper extends EntityMapper<TUser> {
    int updateDatingActivityInfo(@Param("userId") Long userId, @Param("onTimeGrade") Float onTimeGrade,
            @Param("satisfaction") Float satisfaction);

    int exitSociety(@Param("userId") Long userId);
    
    Long selectRoomcardByUSerId(@Param("userId") String userId);
    Long selectPiontByUSerId(@Param("userId") Long userId);
    String selectNickNameByUSerId(@Param("userId") Long userId);
    String selectIdentity(@Param("userId") String userId);
    int increaseYaoqingRoomCard(@Param("userId") Long userId,
            @Param("count") Integer count);
    void updatePoint(@Param("userId") Long userId,@Param("point") Integer point);
    void updatePointByUserId(@Param("userId") Long userId,@Param("points") Long points);
    int updateIsYaoqing(@Param("userId") Long userId);
    void updateIdentity(@Param("userId") String userId,@Param("name") String name,@Param("identity") String identity);
    List<CacheUserListProfile> queryUserByPhoneOrNickName(@Param("condition") String condition);
    
    List<Map<String, Object>> queryUserTypes();
    Long insertUser(TUser user);

    int increaseRoomCard(@Param("userId") Long userId,
                       @Param("count") Integer count);
    int userBindingAgent(@Param("userId") Long userId,
            @Param("agentId") Long agentId);
    int increasePoint(@Param("userId") Long userId,
                         @Param("count") Integer count);

    void updateToken(@Param("userId") Long userId, @Param("token") String token);

    void giftRoomCardEveryDay(@Param("userId") Long userId,
                              @Param("cardEveryDay") String cardEveryDay);

    void giftRoomCardEveryDay1(@Param("userId") Long userId,
                              @Param("cardEveryDay") String cardEveryDay);

    List<MapVo> isCardCountEnough(@Param("users") String users,
                                  @Param("cardNum") Integer cardNum);

    void cutRoomCardByUsersAndNum(@Param("users") String users,
                                  @Param("cardNum") Integer cardNum);

    public String getSign(@Param("playerId") Long playerId);

    public void updateSign(@Param("playerId") Long playerId,
                           @Param("context") String context);

    Integer selectRoomCardCount(@Param("userId") Long userId);

    void updateAgentId(@Param("userId") Long userId,
                       @Param("agentId") Long agentId);

    public void pickUpGold(@Param("playerId") Long playerId,
                           @Param("count") Long count);

    public Long selectAgentIsExit(@Param("agentId") long agentId);

    public void updateRecGoldCount(@Param("userId") Long userId,
                                   @Param("count") Integer count);

    int selectRechangeGoldCount(@Param("playerId") Long playerId);

    public void insertTplayerShareGiftRecord(@Param("userId") Long userId,
                                             @Param("cardEveryDay") String cardEveryDay,
                                             @Param("goldEveryDay") String goldEveryDay,
                                             @Param("type") int type);
    public void insertTplayerShareGiftRecord2AgentId(@Param("userId") Long userId,
                                             @Param("cardEveryDay") String cardEveryDay,
                                             @Param("goldEveryDay") String goldEveryDay,
                                             @Param("type") int type,
                                             @Param("agentId")Long agentId);

    public List<TUser> selectMaxPoint(@Param("rankNum")String rankNum);

    public void updateCardCount(@Param("card")Long card);

    public int selectImsTpUserById(@Param("agentId")Long agentId);

    CommissionVo selectImsCommission();

    void insertIntoImsTpGold(@Param("imsTpCard")ImsTpCard imsTpCard);

    void updateCommissionsCardA(@Param("agnet")int agent,@Param("count") int count);

    void updateCommissionsCardB(@Param("agnet")int agent,@Param("count") int count);

    void updateCommissionsCardC(@Param("agnet")int agent,@Param("count") int count);

    TBiqiCardId selectBiqiCard(@Param("price")Integer price);

    void updateBiqiCard(@Param("playerId")Long playerId,@Param("id")Integer id,@Param("price")Integer price);

    String selectAgentAdvice(@Param("agentId")String agentId);

    String selectImsTpUserByBiqiId(@Param("l") long l);

    void updateUserFirstLoginStatus(@Param("userId")Long userId);

    MapVo selectImsTpUserByIsShare(@Param("agentId")Long agentId);

    MapVo selectImsTpUserByIsBind(@Param("agentId")long agentId);

    void increaseUseGoldshare(@Param("agentId")Long agentId,@Param("goldEveryDay")String goldEveryDay);

    void increaseUseGoldbind(@Param("agentId")long agentId, @Param("bindAgentSendGold")String bindAgentSendGold);

    List<String> selectAllagents();

    Integer selectAgentMoneyCountA(@Param("agentId")String agentId);
    Integer selectAgentMoneyCountB(@Param("agentId")String agentId);
    Integer selectAgentMoneyCountC(@Param("agentId")String agentId);


    Integer selectAgentMoneyCountAdmin();

    Integer selectAgentOrderCount(@Param("agentId")String agentId);
    Integer selectAgentOrderCountAdmin();

    Integer selectAgentGoldMoneyA(@Param("agentId")String agentId);
    Integer selectAgentGoldMoneyB(@Param("agentId")String agentId);
    Integer selectAgentGoldMoneyC(@Param("agentId")String agentId);

    Integer selectAgentGoldMoneyAdmin();

    MapVo selectAgentGoldinfo(@Param("agentId")String agentId);
    MapVo selectAgentGoldinfoAdmin();

    void insertIntoImstpagentcardreport(@Param("agentId")String agentId,
                                        @Param("agentGoldMoneyA")Integer agentGoldMoneyA,
                                        @Param("agentGoldMoneyB")Integer agentGoldMoneyB,
                                        @Param("agentGoldMoneyC")Integer agentGoldMoneyC,
                                        @Param("mapKey")String mapKey,
                                        @Param("mapValue")String mapValue,
                                        @Param("agentMoneyA")Integer agentMoneyA,
                                        @Param("agentMoneyB")Integer agentMoneyB,
                                        @Param("agentMoneyC")Integer agentMoneyC,
                                        @Param("agentOrderCount")Integer agentOrderCount,
                                        @Param("useMoney")Integer useMoney,
                                        @Param("channelMoney")Integer channelMoney,
                                        @Param("robotUse")Integer robotUse,
                                        @Param("surplus")Integer surplus,
                                        @Param("parentMoneyCard")Integer parent_money_card,
                                        @Param("parentMoneyGold")Integer parent_money_gold);

    Integer selectAgentUseMoney(@Param("agentId")String agentId);

    Integer selectCommissionMoney();

    Integer selectRobotUse();

    void updatePingTaiCard(@Param("count") Integer count);

    void updatePingTaiGold(@Param("count")Integer count);

    Integer selectAgentImsTpmoney(@Param("agentId")String agentId,
                                  @Param("ii")Integer ii);

    MapVo selectAgentGoldinfoImsTpmoney(@Param("agentId")String agentId,@Param("ii") int ii);

    Integer selectAgentMoneyCountAImstpmoney(@Param("agentId")String agentId,@Param("ii") int ii);

    Integer selectAgentOrderCountImstpmoney(@Param("agentId")String agentId,@Param("ii") int ii);

    Integer selectParnetMoneyCard(@Param("agentId")String agentId,@Param("i")int i);

    Integer selectParnetMoneyGold(@Param("agentId")String agentId,@Param("i")int i);

}
