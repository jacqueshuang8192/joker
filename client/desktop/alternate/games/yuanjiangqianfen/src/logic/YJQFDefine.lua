
--[[
* author:   zwm
* date:     2019-04-16
* describe: 跑的块必须的全局变量定义
--]]

local YJQFDefine = class("YJQFDefine")

function YJQFDefine:initGlobalData()
    print("initGlobalData ---------------------")
    MAX_PLAYER_SIZE   = 3       --玩家最大人数
    MY_SEAT_ID        = 0       --玩家自己的座位号
    PDK_CUR_ROUND     = 0       --当前打完的局数
    OUT_CARD_TIMES    = 20      --出牌时间
    CARD_INTERVAL     = 70      --手牌的间隙
    CARD_HEIGHT       = 100      --手牌的初始高度
    IS_ROOM_CARD_TYPE = true    --是否为房卡模式
    tableAI = {}
end

function YJQFDefine:clearGlobalData()
    MAX_PLAYER_SIZE = nil
    MY_SEAT_ID = nil
    PDK_CUR_ROUND = nil
    OUT_CARD_TIMES = nil
    CARD_INTERVAL   = nil      --手牌的间隙
    CARD_HEIGHT     = nil      --手牌的初始高度
    IS_ROOM_CARD_TYPE = nil
end

return YJQFDefine