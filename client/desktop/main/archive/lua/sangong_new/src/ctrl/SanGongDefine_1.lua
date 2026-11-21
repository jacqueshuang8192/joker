local SanGongDefine = {
    -- 0:牌局已结束 1:准备 2:等待用户抢庄 3:牌局开始 4:GRABDEALER 5:等待用户选择倍数
    -- 6:CALLTIMES 7:等待出牌 8:OUTCARD 9:ISSPECTATOR

    WAIT_STATUS = 0, 
    BET_STATUS = 1, --下注
    DEAL_STATUS = 2, --发牌
    OPEN_STATUS = 3,  --开牌
    END_STATUS = 4, --结束
}

return SanGongDefine
