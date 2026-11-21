
--[[
* author:   zwm
* date:     2019-04-16
* describe: 跑的块必须的全局变量定义
--]]

local zixidadunDefine = class("zixidadunDefine")

function zixidadunDefine:initGlobalData()
    print("initGlobalData ---------------------")
    MAX_PLAYER_SIZE   = 3       --玩家最大人数
    MY_SEAT_ID        = 0       --玩家自己的座位号
    zixidadun_CUR_ROUND     = 0       --当前打完的局数
    OUT_CARD_TIMES    = 20      --出牌时间

    --ZXDD_GameSCENE=nil
    IS_ROOM_CARD_TYPE = true    --是否为房卡模式
    tableAI = {}
    PLAYER_HEADS_POSITION_TABLE_FACE ={}  --头像的绝对地址,因为不想影响以前的逻辑 _FACE
end

function zixidadunDefine:clearGlobalData()
    MAX_PLAYER_SIZE = nil
    MY_SEAT_ID = nil
    zixidadun_CUR_ROUND = nil
    OUT_CARD_TIMES = nil


    IS_ROOM_CARD_TYPE = nil
end

return zixidadunDefine