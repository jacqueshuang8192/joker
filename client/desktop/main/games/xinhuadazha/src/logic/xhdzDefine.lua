

local xhdzDefine = class("xhdzDefine")

function xhdzDefine:initGlobalData()
    print("initxhdzGlobalData ---------------------")
    MAX_PLAYER_SIZE   = 4       --玩家最大人数
    MY_SEAT_ID        = 0       --玩家自己的座位号
    xhdz_CUR_ROUND     = 0       --当前打完的局数
    OUT_CARD_TIMES    = 20      --出牌时间
    CARD_INTERVAL     = 70      --70手牌的间隙
    CARD_HEIGHT       = 100     --100手牌的初始高度
    IS_ROOM_CARD_TYPE = true    --是否为房卡模式
    tableAI = {}
    PLAYER_HEADS_POSITION_TABLE_FACE ={}  --头像的绝对地址,因为不想影响以前的逻辑 _FACE
end

function xhdzDefine:clearGlobalData()
    MAX_PLAYER_SIZE = nil
    MY_SEAT_ID = nil
    xhdz_CUR_ROUND = nil
    OUT_CARD_TIMES = nil
    CARD_INTERVAL   = nil      --手牌的间隙
    CARD_HEIGHT     = nil      --手牌的初始高度
    IS_ROOM_CARD_TYPE = nil
end

return xhdzDefine