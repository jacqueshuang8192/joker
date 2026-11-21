local hallHandle = require("hall.HallHandle")

local PROTOCOL = import(TpackageName .. ".handle.PaiJiuProtocol")

local PaiJiuReceiveHandle  = class("PaiJiuReceiveHandle", hallHandle)

local run_scene_name = TpackageName..".gameScene"

local Lottery = require(TpackageName .. ".Lottery")
local   ControlPlaneOperator = require(TpackageName .. ".operator.ControlPlaneOperator")
local is_End = false

local is_show = false

local is_qie = false
local is_doing_qie  = false
local qie_type = -1

PAIJIU_OPEN_TABLE={}

local tbErrorCode = {
    [0] = "成功创建新连接",
    [1] = "无效的操作",
    [10] = "游戏进行中",
    [11] = "无效的座位",
    [12] = "您已经准备过了",
    [13] = "请先准备",
    [14] = "您已经坐下",
    [15] = "您已经站起",
    [16] = "请先坐下",
    [17] = "不存在的用户",
    [18] = "要求携带钻石不足",
    [19] = "已经购买过奖池",
    [20] = "桌子状态不正确",
    [21] = "值超出范围",

    [100] = "大于下注限制",
    [101] = "无效出牌",
    [102] = "大于下注限制",
    [103] = "小于下注限制",
    [104] = "头把必满",
    [105] = "下注金额超过自己本身的积分",
}

local loginErrorCode = {
    [3] = "玩家密匙错误",
    [4] = "数据库连接错误",
    [5] = "无此房间",
    [7] = "房间已满人",
    [8] = "没有多余座位",
    [9] = "玩家余额不足",
    [11] = "未知错误",
    [12] = "相同IP",
    [13] = "钱太多",
    [14] = "缓存错误",
    [15] = "VIP错误",
    [16] = "密码错误",
    [17] = "要求携带不满足",
    [18] = "组局已开始",
}


function PaiJiuReceiveHandle:ctor()

	PaiJiuReceiveHandle.super.ctor(self);

	local func_ = {

        --进入游戏成功 0210
        --[PROTOCOL.SVR_GET_ROOM_OK] = {handler(self, PaiJiuReceiveHandle.SVR_GET_ROOM_OK)},
        --登录房间成功 1007
        [PROTOCOL.SVR_LOGIN_ROOM] = {handler(self, PaiJiuReceiveHandle.SVR_LOGIN_ROOM)},
        --进入房间失败 1005
        [PROTOCOL.SVR_LOGIN_ROOM_FAIL] = {handler(self, PaiJiuReceiveHandle.SVR_LOGIN_ROOM_FAIL)},

        --广播其他用户坐下（金币场） 1031
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, PaiJiuReceiveHandle.BROADCAST_USER_SIT_DOWN)},
        --广播用户退出房间 1032
        [PROTOCOL.BROADCAST_USER_STAND_UP] = {handler(self, PaiJiuReceiveHandle.BROADCAST_USER_STAND_UP)},

        --广播其他用户登录桌子 100D
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, PaiJiuReceiveHandle.SVR_LOGIN_ROOM_BROADCAST)},

        --广播用户退出房间 100E
        [PROTOCOL.SVR_QUIT_ROOM]            = {handler(self, PaiJiuReceiveHandle.SVR_QUIT_ROOM)},
        --广播用户退出房间 1033
        [PROTOCOL.BROADCAST_USER_QUIT_ROOM] = {handler(self, PaiJiuReceiveHandle.BROADCAST_USER_QUIT_ROOM)},

        --用户退出房间成功（自己）
        [PROTOCOL.SVR_QUICK_SUC]            = {handler(self, PaiJiuReceiveHandle.SVR_QUICK_SUC)},

        --获取筹码返回
    	[PROTOCOL.SVR_GET_CHIP] = {handler(self, PaiJiuReceiveHandle.SVR_GET_CHIP)},

        --错误提示5001
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, PaiJiuReceiveHandle.BROADCAST_ERROR_TIPS)},

        --广播用户托管1034
        [PROTOCOL.BROADCAST_USER_AUTO_PLAY] = {handler(self, PaiJiuReceiveHandle.BROADCAST_USER_AUTO_PLAY)},

        --广播剩余时间100F
        [PROTOCOL.SVR_BROADCAST_COUNT_DOWN]           = {handler(self, PaiJiuReceiveHandle.SVR_BROADCAST_COUNT_DOWN)},

        --广播开始准备 2001 （阶段广播）
        [PROTOCOL.SVR_READY_TIME]           = {handler(self, PaiJiuReceiveHandle.SVR_READY_TIME)},
        --广播用户准备 2001
        [PROTOCOL.SVR_READY_BROADCAST]      = {handler(self, PaiJiuReceiveHandle.SVR_READY_BROADCAST)},

        --告知庄家可以开始游戏
    	[PROTOCOL.SERVER_COMMAND_REMAID_START_GAME] = {handler(self, PaiJiuReceiveHandle.SERVER_COMMAND_REMAID_START_GAME)},
    	--告知庄家不可以开始游戏
    	[PROTOCOL.SERVER_COMMAND_REMAID_START_GAME_FAIL] = {handler(self, PaiJiuReceiveHandle.SERVER_COMMAND_REMAID_START_GAME_FAIL)},

        --广播游戏开始
        [PROTOCOL.SVR_BROADCAST_GAME_START]       = {handler(self, PaiJiuReceiveHandle.SVR_BROADCAST_GAME_START)},

        --广播开始抢庄（阶段广播）
        [PROTOCOL.SVR_BEGIN_QIANFGZHUANG_BROADCAST]       = {handler(self, PaiJiuReceiveHandle.SVR_BEGIN_QIANFGZHUANG_BROADCAST)},
        --广播用户抢庄操作
        [PROTOCOL.SVR_USER_GRABBANKER_OPTION_BROADCAST]       = {handler(self, PaiJiuReceiveHandle.SVR_USER_GRABBANKER_OPTION_BROADCAST)},
    	--广播庄家 1104
    	[PROTOCOL.SVR_BRANK_BROADCAST]            = {handler(self, PaiJiuReceiveHandle.SVR_BRANK_BROADCAST)},

        --1105 广播可以开始加倍（阶段广播）
    	[PROTOCOL.BROADCAST_BEGIN_CALL_TIMES]      = {handler(self, PaiJiuReceiveHandle.BROADCAST_BEGIN_CALL_TIMES)},
        --6014 广播加倍倍数
    	[PROTOCOL.SVR_USER_BASES_RESULT_BROADCAST] = {handler(self, PaiJiuReceiveHandle.SVR_USER_BASES_RESULT_BROADCAST)},
        -- 1106 通知玩家加倍
        [PROTOCOL.SVT_PLAYER_CALL_TIMES] = {handler(self, PaiJiuReceiveHandle.SVT_PLAYER_CALL_TIMES)},
        -- 1101 广播玩家加倍
        [PROTOCOL.SVR_USER_CALL_TIMES_BROADCAST] = {handler(self, PaiJiuReceiveHandle.SVR_USER_CALL_TIMES_BROADCAST)},
        -- 1107 广播骰子数
        [PROTOCOL.SVR_SHAIZI_BROADCAST] = {handler(self, PaiJiuReceiveHandle.SVR_SHAIZI_BROADCAST)},
        -- 1108 广播开始出牌
        [PROTOCOL.SVR_START_OUT_CARD_BROADCAST] = {handler(self, PaiJiuReceiveHandle.SVR_START_OUT_CARD_BROADCAST)},
        --发牌 0x1109
        [PROTOCOL.SVR_SEND_USER_CARDS]       = {handler(self, PaiJiuReceiveHandle.SVR_SEND_USER_CARDS)},
        -- 110A 广播用户出牌
        [PROTOCOL.SVR_OUT_CARD_BROADCAST] = {handler(self, PaiJiuReceiveHandle.SVR_OUT_CARD_BROADCAST)},
        -- 110B 广播游戏开始
        [PROTOCOL.SERVER_BROADCAST_START_GAME] = {handler(self, PaiJiuReceiveHandle.SERVER_BROADCAST_START_GAME)},
        -- 110C 广播锅底数
        [PROTOCOL.SVR_BROADCAST_GUO_DI] = {handler(self, PaiJiuReceiveHandle.SVR_BROADCAST_GUO_DI)},
        -- 110d 广播开始切锅
        [PROTOCOL.SVR_BROADCAST_START_QIE_GUO] = {handler(self, PaiJiuReceiveHandle.SVR_BROADCAST_START_QIE_GUO)},
        -- 110E 提醒用户做切锅选择
        [PROTOCOL.SVR_REMAID_QIE_GUO] = {handler(self, PaiJiuReceiveHandle.SVR_REMAID_QIE_GUO)},
        -- 110F 广播切锅结果
        [PROTOCOL.SVR_BROADCAST_GUO_RESULT] = {handler(self, PaiJiuReceiveHandle.SVR_BROADCAST_GUO_RESULT)},
        --1042 广播外围结果
        [PROTOCOL.BROADCAST_WAIWEI_RESULT] = {handler(self, PaiJiuReceiveHandle.BROADCAST_WAIWEI_RESULT)},

        -- 1207 提醒下庄
        [PROTOCOL.SVR_NOTIFY_DOWN_BANK] = {handler(self, PaiJiuReceiveHandle.SVR_NOTIFY_DOWN_BANK)},
        -- 1208 广播下庄操作
        [PROTOCOL.SVR_BROADCAST_DOWN_BANK_OPT] = {handler(self, PaiJiuReceiveHandle.SVR_BROADCAST_DOWN_BANK_OPT)},

        --1041 下注剩余时间
        [PROTOCOL.BROADCAST_SENDCARD_REMAINDTIME] = {handler(self, PaiJiuReceiveHandle.BROADCAST_SENDCARD_REMAINDTIME)},

    	--1102 广播玩家开始出牌（阶段广播）
    	[PROTOCOL.SVR_READY_OUTCARD_BROADCAST]            = {handler(self, PaiJiuReceiveHandle.SVR_READY_OUTCARD_BROADCAST)},
        --6005  广播玩家出牌
    	[PROTOCOL.SVR_USER_PLAYED_CARDS_BROADCAST]            = {handler(self, PaiJiuReceiveHandle.SVR_USER_PLAYED_CARDS_BROADCAST)},

        --4008 广播玩家钱数变化（用于扣取台费）
        [PROTOCOL.SVR_CHIP_CHANGE_BROADCAST]       = {handler(self, PaiJiuReceiveHandle.SVR_CHIP_CHANGE_BROADCAST)},

         --111 广播玩家充值
        [PROTOCOL.SVR_CHARGE_BROADCAST]       = {handler(self, PaiJiuReceiveHandle.SVR_CHARGE_BROADCAST)},

    	--6008  单局结算（阶段广播）
    	[PROTOCOL.SVR_SETTLEMENT_BROADCAST]       = {handler(self, PaiJiuReceiveHandle.SVR_SETTLEMENT_BROADCAST)},
    	--5100，广播总结算
    	[PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, PaiJiuReceiveHandle.SVR_GROUP_BILLBOARD)},
    	--广播当前回合
    	[PROTOCOL.SVR_GROUP_TIME] = {handler(self, PaiJiuReceiveHandle.SVR_GROUP_TIME)},

        --外围相关

        --广播桌子状态
    	--[PROTOCOL.SERVER_CMD_TABLE_STATE] = {handler(self, PaiJiuReceiveHandle.SERVER_CMD_TABLE_STATE)},
        
        --开奖结果
        [PROTOCOL.BROADCAST_BONUS_RESULT] = {handler(self, PaiJiuReceiveHandle.BROADCAST_BONUS_RESULT)},
        --请求下注情况返回
        [PROTOCOL.SERVER_CMD_BONUS_RECORD] = {handler(self, PaiJiuReceiveHandle.SERVER_CMD_BONUS_RECORD)},
        --广播下注
        [PROTOCOL.BROADCAST_USER_BET] = {handler(self, PaiJiuReceiveHandle.BROADCAST_USER_BET)},
        --请求录纸返回
        [PROTOCOL.SERVER_CMD_RECORD_PAPER] = {handler(self, PaiJiuReceiveHandle.SERVER_CMD_RECORD_PAPER)},

    	--解散相关
    	--没有此房间，解散房间失败
     	[PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, PaiJiuReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},
     	--广播桌子用户请求解散组局
     	[PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, PaiJiuReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
     	--广播当前组局解散情况
     	[PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, PaiJiuReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
     	--广播桌子用户成功解散组局
     	[PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, PaiJiuReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
     	--广播桌子用户解散组局 ，解散组局失败
     	[PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, PaiJiuReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},

    	--文字聊天相关
     	--[PROTOCOL.SVR_MSG_FACE]     = {handler(self, PaiJiuReceiveHandle.SVR_MSG_FACE)},
     	--接收服务器返回的语音表情视频文字 0214
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, PaiJiuReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},
        --接收服务器返回的距离 801
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, PaiJiuReceiveHandle.SERVER_CMD_MESSAGE)},
        -- --接收IP信息 106A
        -- [PROTOCOL.BROADCAST_USER_IP] = {handler(self, PaiJiuReceiveHandle.BROADCAST_USER_IP)},
        -- [PROTOCOL.BROADCAST_BEGIN_BET] = {handler(self, PaiJiuReceiveHandle.BROADCAST_BEGIN_BET)},
        [PROTOCOL.SERVER_TEST_AVAIABLE_CARDS] = {handler(self, PaiJiuReceiveHandle.SERVER_TEST_AVAIABLE_CARDS)},
        [PROTOCOL.SERVER_TEST_CARDS] = {handler(self, PaiJiuReceiveHandle.SERVER_TEST_CARDS)},

    }

    table.merge(self.func_, func_)

end


--协议返回数据接收
function PaiJiuReceiveHandle:callFunc(pack)

    if SCENENOW["name"] ~= run_scene_name then
        print("当前场景不是牌九游戏场景！")
        return
    end

    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
	 	dump(pack.cmd,"收到协议，协议号为")
        self.func_[pack.cmd][1](pack)
    end

end


--充值后广播 111
function PaiJiuReceiveHandle:SVR_CHARGE_BROADCAST(pack)
    dump(pack, "SVR_CHARGE_BROADCAST == ")
    local uid = pack.uid
    local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]

    if  PAIJIU_USERINFO_TABLE[uid] and  playerType then
        --[[        local oriChip = PAIJIU_USERINFO_TABLE[uid].coins
                local chip = oriChip + pack.chargeCoins
                PAIJIU_USERINFO_TABLE[uid].coins = chip
                GamePlaneOperator:setCoin(playerType, chip)]]
        GamePlaneOperator:updateCoin(playerType, pack.chargeCoins/100,nil,uid)
    end

end

function PaiJiuReceiveHandle:SERVER_BROADCAST_START_GAME(pack)

    dump(pack, "----------- 110B ------------")
    -- 隐藏准备文本，因为在轮庄和固定庄模式下，没有抢庄文本,只有准备文本
    GamePlaneOperator:clearAllReadyStatus()

    -- 隐藏IP检测界面
    --GamePlaneOperator:showIpCheck(false)

    -- 隐藏桌面按钮
    GamePlaneOperator:showInviteReadyExitBtn(2)

    -- 隐藏抢庄界面
    GamePlaneOperator:loadZhuangPanel(false)

    -- 隐藏抢庄文本
    GamePlaneOperator:clearGrabBankerSymbol()

    -- 清下注界面
   -- GamePlaneOperator:loadCallTimesPanel(false)
    GamePlaneOperator:callGuoPanel(false)

    -- 隐藏开牌按钮
    GamePlaneOperator:showOutCardButtons(false)

    -- 停止动画
    GamePlaneOperator:stopTimer()

    GamePlaneOperator:showPoolCards(pack.showCards)

end

--0210消息，发送进入房间消息113消息后的返回结果,
--function PaiJiuReceiveHandle:SVR_GET_ROOM_OK(pack)
--
--    dump(pack, "-----牌九210-----")
--
--    local tid = pack.tid   --桌子ID
--
--    if tid == 0 then
--	 	require("hall.GameTips"):showTips("提示", "tohall", 1, "游戏已结束")
--        return
--    end
--
--    USER_INFO["tid"] = tid
--
--    PaiJiuSendHandle:LoginRoom(tid)
--
--end

--进入房间失败
function PaiJiuReceiveHandle:SVR_LOGIN_ROOM_FAIL(pack)
    dump(pack, "-----进入房间失败 1005-----")

    local errorCode = pack.type

    local txts = {}
    txts["title"] = "提示"
    txts["sureBt_txt"]  = "确定"
    txts["cancelBt_txt"] =  "取消"

    if loginErrorCode[errorCode] then
       
        if errorCode == 7 or errorCode == 8 or errorCode == 18 then
            local customfunc = {}
            customfunc["cancel_func"] = function() require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID) end
            customfunc["sure_func"]  = function() require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID) end

            txts["msg"] = loginErrorCode[errorCode] or "未知的错误"
            require("hall.GameTips"):showCustomTips(txts,customfunc,1)
        else
            require("hall.GameTips"):showTips("提示", "", 3, loginErrorCode[errorCode])
        end
    else
        require("hall.GameTips"):showTips("提示", "", 3, "未知的错误")
    end
end

--登录房间 1007
function PaiJiuReceiveHandle:SVR_LOGIN_ROOM(pack)
    require(NetworkLoadingView_filePath):removeView(888)
    dump(pack, "-----PaiJiuReceiveHandle 牌九登录房间 1007-----")
    -- 目前：围观重连可能有问题

    local accountScene = SCENENOW['scene']:getChildByName('accountScene')
    if not tolua.isnull(accountScene) then
        accountScene:removeSelf()
    end
    require("hall.settlement.settlement"):removeScene()

    is_End = false
    -- 清数据
    -- 全局常量
    --SCENENOW["scene"]:initData("clearGameData")
    -- 玩家头像：庄，输赢合（目前没做）
    GamePlaneOperator:clearGameDatas(2)
    -- 按钮：开牌按钮，提示按钮（目前没做），邀请好友文本根据房卡和金币场显示，

    -- 游戏公共部分：
    USER_INFO["activity_id"] = pack.activityId
    PAJIU_ACTIVITY_ID = pack.activityId

    -- 邀请码：
    USER_INFO["invote_code"] = pack.inviteCode

    HEART_BEAT_TID = USER_INFO["tid"]
    dump(HEART_BEAT_TID, "1007心跳tid")

    -- 确定游戏类型
    if pack.gameMode == 1 then
        GAME_MODE = "小牌九"
    elseif  pack.gameMode == 2 then
        GAME_MODE = "大牌九"
    end

    if pack.club_id > 0 then
        CLUB_ID = pack.club_id
    end

    -- 0金币场还是1房卡
    isGoldGame = pack.isGoldGame

    isNewGuo = pack.curGuoJuSize and pack.curGuoJuSize == 1 --是否为头道
    
    FENCHANG=pack.fenchang
    -- 游戏配置信息
    local gameConfig = pack.gameConfig
    local str_config = " "
    local gameModeName=""
    local baseScore=""
    local fanbeiRule=""
    local roomRule=""
    --通过接口传来的字符串获取具体配置信息
    if type(gameConfig) =="string" then
        local gameConfigTable = json.decode(gameConfig)
        dump(gameConfigTable, "------游戏配置信息------")
        --dump(type(gameConfigTable), "----- type_of_gameConfig")
        -- 0抢庄，2轮庄，1霸王庄
        -- 处理配置
        -- 几道注：2：2道，3：3道
        for k, v in pairs(gameConfigTable) do
            if k == "paigowGroupCount" then
                if v == 1 then
                    --GAME_CONFIG["小牌九"] = true
                    str_config  = str_config .. "小牌九 "
                    gameModeName="小牌九 "
                elseif v == 2 then
                    --GAME_CONFIG["大牌九"] = true
                    str_config  = str_config .. "大牌九 "
                    gameModeName="大牌九 "
                end
            elseif k == "daoCount" then
                DAO_COUNT = v
                if v == 2 then
                    --GAME_CONFIG["两道杠"] = true
                    str_config  = str_config .. "两道杠 "
                    fanbeiRule="两道杠 "
                elseif v == 3 then
                    --GAME_CONFIG["三道杠"] = true
                    str_config  = str_config .. "三道杠 "
                    fanbeiRule="三道杠 "
                end
            elseif k == "speType" then
                local str_type_config = string.split(v, ",")
                dump(str_type_config, "-- 切分的配置信息 --")
                for _, x in ipairs(str_type_config) do
                    x = tonumber(x)
                    if x == 1 then
                        str_config  = str_config .. "炸弹 "
                        roomRule=roomRule.."炸弹 "
                    elseif x == 2 then
                        str_config  = str_config .. "鬼子 "
                        roomRule=roomRule.."鬼子 "
                    elseif x == 3 then
                        str_config  = str_config .. "天王九 "
                        roomRule=roomRule.."天王九 "
                    elseif x == 4 then
                        str_config  = str_config .. "地九娘娘 "
                        roomRule=roomRule.."地九娘娘 "
                    end
                end
            elseif k == "guodi" then
                fenchang=v
                baseScore=v
                GUODI_NUMBER = v  --记录锅底数
            elseif k == "baseChip" then
                BASE_CHIP = v
            end
        end
    end

    local gamemsg =     
        { 
          {["玩法"] = gameModeName, ["分场"] = FENCHANG},
          {["锅底"] = baseScore},
          {["道的选择"] = fanbeiRule},  
          {["牌型"] = roomRule},  
        }
    --dump(GAME_CONFIG, "---- GAME_CONFIG ----")
    dump(str_config, "----获取到的游戏配置-----")
    -- 显示邀请码和组局配置信息
    SCENENOW["scene"]:gamerule(gamemsg)
    SCENENOW["scene"]:updateRoomInfo(nil, nil, USER_INFO["invote_code"], nil, nil, str_config)
    GamePlaneOperator:initPlayerDaoPanel()

    PJ_TOTAL_CARD_COUNT = pack.totalCardsCount
    PJ_HANDCARD_COUNT = pack.gameMode * 2

    CARDCOUNT=pack.gameMode

    initialChip = pack.initChip

    if  isGoldGame == 0 then
        initialChip = 0
    end

    -- 庄家座位
    BANKER_UID = pack.bankerId

    -- 闲家加倍
    TIMES_SIZE = pack.timesSize

    TIMES_ARRAY = pack.timesArray

    -- 牌堆相关
    local poolCardsShowCount = pack.poolCardsShowCount
    local remainCardsCount = pack.remainCardsCount
    -- 显示牌堆
    -- 骰子相关
    --[[    SHAIZI_NUMBER = pack.shaiZiNumber
        SHAIZI_ARRAY = pack.shaiZiNumber
        SHAIZI_TIMEOUT = pack.shaiziTimeOut]]

    GamePlaneOperator:showPoolCards(pack.showCardsArray)

    -- 显示锅底数
    --GUODI_NUMBER = pack.guoDiCount
    GamePlaneOperator:showGuoDi(pack.guoDiCount)

    -- 游戏状态
    GAME_STATE = pack.gameStatus
    -- 显示游戏公共部分
    --self:setGameStatus()

    -- 玩家信息相关
    local sitDownUserCount = pack.nowUserCount
    if sitDownUserCount > 0 then
        -- 判断我是否已经坐下
        dump(type(pack.usersInfo), "我自己")
        for k, user_info in pairs(pack.usersInfo) do
            -- 我已经坐下
            if user_info.uid == USER_INFO["uid"] then
                MY_SEAT_ID = user_info.seatId
                RELATIVE_SEAT_ID = MY_SEAT_ID
                break
            end
        end
    end
    if MY_SEAT_ID < 0 then
        RELATIVE_SEAT_ID = 0
    end
    old_seat=RELATIVE_SEAT_ID

    if RELATIVE_SEAT_ID == 0 then
        GamePlaneOperator:showSitDownButton(true)
    end

    if GAME_STATE >= GAME_STATUS_OUT_CARDS  and GAME_STATE < GAME_STATUS_QIE_GUO then
        local cardCount = pack.gameMode * 2
        local cardsTemp = {}
        for i=1,cardCount do
            table.insert(cardsTemp, 0)
        end
        for i=1, TOTAL_PLAYERNUM do
            GamePlaneOperator:showCards(i, cardsTemp)
        end
    end

    if sitDownUserCount > 0 then
        -- 已经有玩家坐下，先画头像信息
        for _, user_info in pairs(pack.usersInfo) do
            if user_info.isReady == 1 then
                -- 加入准备列表
                USERS_READY_STATE[user_info.uid] = 1
            end
            -- 桌面上绘制玩家的界面
            --dump(RELATIVE_SEAT_ID, "-- 桌面上绘制玩家的界面")
            self:collectPlayerData(user_info)
            if GAME_STATE > GAME_STATUS_GRAB_BANKER and user_info.uid ~= BANKER_UID then
                local playerType = PAIJIU_PLAYERTYPE_TABLE[user_info.uid]
                local dao_count = user_info.daoCount
                local daoArray = user_info.daoArray
                for i=1, dao_count do
                    GamePlaneOperator:setDao(playerType, i, daoArray[i],PLAYER_HEADS_POSITION_TABLE[user_info.uid])
                end
                dump(playerType,"显示DaoPanel的--------------")
                GamePlaneOperator:showPlayerDaoPanel(playerType, true)
            end
        end
        for _, user_info in pairs(pack.usersInfo) do

            local uid = user_info.uid
            local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
            dump(uid, "------------ uid -------------")
            dump(handCardsCount, "------- handCardsCount: ---")
            dump(handCardsArray, "------------ handCardsArray: -----")
            print("++++++++++++++++++++++++++++++++++++++", uid, USER_INFO["uid"])
            if uid == USER_INFO["uid"] then
                --todo
                PJ_HANDCARDS = user_info.handCardsArray

                --亮牌前
                if user_info.cardCombinationCountBeforeSure and user_info.cardCombinationCountBeforeSure ~= 0 then
                    PJ_AVAI_CARD_GROUPS = user_info.cardCoombinationArrayBeforeSure
                end

                -- if user_info.cardCombinationCountAfterSure and user_info.cardCombinationCountAfterSure ~= 0 then
                --     PJ_AVAI_CARD_GROUPS = user_info.cardCombinationArrayAfterSure
                -- end

            end
            -- 断线
            if user_info.isOnline == 0 then
                GamePlaneOperator:showHeadSymbol(playerType, "disconnect", true)
            end
            -- 根据游戏状态，在桌面展示更多信息
            if GAME_STATE == GAME_STATUS_STOP then
                if user_info.isReady == 1 then
                    -- 加入准备列表
                    USERS_READY_STATE[uid] = 1
                    -- 显示准备文本
                    GamePlaneOperator:setReadyStatus(playerType, true)
                    if uid == USER_INFO["uid"] then
                        if isGoldGame == 0 then
                            --
                            GamePlaneOperator:showInviteBtnText(2)
                            GamePlaneOperator:showInviteReadyExitBtn(1)
                        else
                            GamePlaneOperator:showInviteBtnText(0)
                            if GAME_ROUND == 0 then
                                GamePlaneOperator:showInviteReadyExitBtn(1)
                            else
                                GamePlaneOperator:showInviteReadyExitBtn(2)
                            end
                        end
                    end
                else
                    if uid == USER_INFO["uid"] then
                        if isGoldGame == 0 then
                            GamePlaneOperator:showInviteBtnText(2)
                            GamePlaneOperator:showInviteReadyExitBtn(0)
                        else
                            -- GamePlaneOperator:showInviteBtnText(0)
                            GamePlaneOperator:showInviteBtnText(0)
                            if GAME_ROUND == 0 then
                                GamePlaneOperator:showInviteReadyExitBtn(0)
                            else
                                GamePlaneOperator:showInviteReadyExitBtn(3)
                            end
                        end
                    end
                end
            elseif GAME_STATE == GAME_STATUS_GRAB_BANKER then
                PAIJIU_USERINFO_TABLE[uid]["feedback"]=user_info.feedback
                if user_info.feedback == -1 and uid == USER_INFO["uid"] then
                    GamePlaneOperator:loadZhuangPanel( true)
                elseif user_info.feedback == 0 then
                    GamePlaneOperator:showZhuangAttitude(playerType, 2)
                elseif user_info.feedback == 1 then
                    GamePlaneOperator:showZhuangAttitude(playerType, 1)
                end
            elseif GAME_STATE == GAME_STATUS_CALL_TIMES then
                -- 自己是庄家，不用下注，只进行下注倒计时
                if BANKER_UID == USER_INFO["uid"] then
                    -- 显示倒计时
                else
                    local dao_count = user_info.daoCount
                    local daoArray = user_info.daoArray
                    if uid == USER_INFO["uid"] then
                        CALL_TIMES_COUNT = dao_count + 1
                        if user_info.feedback == -1 and CALL_TIMES_COUNT <= DAO_COUNT  then
                            -- 自己还没下注或者没下完注
                            --GamePlaneOperator:loadCallTimesPanel(true, TIMES_SIZE, TIMES_ARRAY)
                            GamePlaneOperator:callGuoPanel(true, user_info.guoTimesLimit)
                        end
                    end
                    for i=1, dao_count do
                        GamePlaneOperator:setDao(playerType, i, daoArray[i],PLAYER_HEADS_POSITION_TABLE[user_info.uid])
                    end
                end
                -- 暂时没做
            elseif GAME_STATE == GAME_STATUS_OUT_CARDS then
                dump(USERS_READY_STATE[USER_INFO["uid"]],"-------USERS_READY_STATE-------")
                if uid == USER_INFO["uid"] then
                    --todo
                    if user_info.feedback == -1 then   --未亮牌
                        --todo
                        GamePlaneOperator:showCards(playerType, user_info.handCardsArray)
                        -- 开牌按钮
                        GamePlaneOperator:showOutCardButtons(true)
                        --IS_SURE_OPEN = false
                    else
                        local isOpenPai = true
                        GamePlaneOperator:showCards(playerType, user_info.handCardsArray,isOpenPai)  --已经亮牌
                        GamePlaneOperator:showAni4Big(playerType, user_info.cardCombinationArrayAfterSure)
                        -- 开牌按钮
                        GamePlaneOperator:showOutCardButtons(false)
                        -- 隐藏牌类型提示
                        GamePlaneOperator:showCardGroups(false)
                        --IS_SURE_OPEN = true
                        PJ_SURE_OPEN_CARD[playerType] = 1
                        PAIJIU_OPEN_TABLE[uid]=1
                    end
                else
                    local cardCount = pack.gameMode * 2

                    local cardsTemp = {}
                    for i=1,cardCount do
                        table.insert(cardsTemp, 0)
                    end
                    -- 其他玩家没有选择开牌
                    if user_info.feedback == -1 then
                        GamePlaneOperator:showCards(playerType, cardsTemp)
                    else
                        GamePlaneOperator:openCards(playerType, cardsTemp)
                        PJ_SURE_OPEN_CARD[playerType] = 1
                        PAIJIU_OPEN_TABLE[uid]=1
                    end
                end
                --GamePlaneOperator:showCards(playerType, cardsTemp)
            end
        end
    end
    if GAME_STATE > GAME_STATUS_GRAB_BANKER  and BANKER_UID > 0 then
        GamePlaneOperator:guoPos()
    end
    if GAME_STATE == GAME_STATUS_OPEN_CARDS then
        local result_info = {}
        for _, user_info in pairs(pack.usersInfo)do
            local result_Info = {}
            result_Info.uid = user_info.uid
            result_Info.cardCombinationArrayAfterSure = user_info.cardCombinationArrayAfterSure
            if result_Info.uid and result_Info.cardCombinationArrayAfterSure then
                table.insert(result_info, result_Info)
            end
        end
        local result={}
        result["resultInfo"]=result_info
        self:SVR_OUT_CARD_BROADCAST2(result)
    end
    if GAME_STATE == GAME_STATUS_SEND_CARDS then
        --发牌阶段，播放筛子动画
        GamePlaneOperator:showShiziAnimotion(pack.shaiZiNumber, pack.shaiZiArray, pack.shaiZiTimeOut)
    elseif GAME_STATE > GAME_STATUS_SEND_CARDS then
        GamePlaneOperator:showRemainCards(pack.remainCardsCount)
    end

    if GAME_STATE == GAME_STATUS_QIE_GUO then
        dump(" --------- 11111111111111111 --------------")
        if USER_INFO["uid"] == BANKER_UID then
            if pack.curGuoJuSize > 3 then
                ControlPlaneOperator:showDownBankBtn(true)
            end
            -- GamePlaneOperator:showGuoChoosePanel(true,1)
        end
    end

    if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] ~= nil and isGoldGame == 0 then
        GamePlaneOperator:showBuyCoinBotton(true)
    end

    if PLAYERNUM == TOTAL_PLAYERNUM and isGoldGame == 0 then
        if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] == nil then
            GamePlaneOperator:showInviteReadyExitBtn(4)
        end
    end

    dump(GAME_STATUS_QIE_GUO, "--- GAME_STATUS_QIE_GUO -----")
    dump(GAME_STATE, "----- GAME_STATE -----")
    dump(BANKER_UID, "------- BANKER_UID -------")
    dump(USER_INFO["uid"], " ----------- my_uid ")
end

--------------------------------------------------------------------------------------------------
--整理用户数据
function PaiJiuReceiveHandle:collectPlayerData(data)

    dump(data.uid, "整理玩家信息数据")

    local gold = data.gold/100 --data.gold - initialChip

    local nick_name =  data.nickName
    dump(data.gold, "玩家金币")
    local icon_url = data.portrait
    local sex_num = data.sex
    local userInfo = {}

    --头像图片
    userInfo["icon_url"] = icon_url or ""
    --昵称
    userInfo["nick"] = nick_name or ""
    --金币
    userInfo["coins"] = gold or 0   --用户总金币
    --UID
    userInfo["uid"] = data.uid or 0
    --性别
    userInfo["sex"] = sex_num or 0
    --IP
    userInfo["ip"] = data.ip or ""

    userInfo["latitude"] = data.latitude or ""

    userInfo["longitude"] = data.longitude or ""

    userInfo["score"] = 0     --用户本局游戏的胜负
    -- 城市信息
    local otherInfo = json.decode(data.otherInfoJson)
    userInfo["city"] = otherInfo.city

    userInfo["daoCount"] = data.daoCount or ""

    userInfo["daoArray"] = data.daoArray or ""    

    local uid = data.uid
    PAIJIU_USERINFO_TABLE[uid] = userInfo
    PAIJIU_SEAT_TABLE[uid] = data.seatId --保存用户座位与id映射

--[[    if GROUP_MODE == 2  then
        require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,  {ip = userInfo["ip"]}, "ip")
    elseif GROUP_MODE == 1 then
        require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,  userInfo)
    end]]

    if  data.seatId >= 0 then
        -- 桌面绘制坐下玩家的头像
        self:showPlayer(uid, data.seatId, userInfo)
    end

    PLAYERNUM = self:getPlayerNum()

end

--获取当前坐下的玩家数量
function PaiJiuReceiveHandle:getPlayerNum()

    local playerNum = 0
    local audienceNum = 0

    for uid,seat_id in pairs(PAIJIU_SEAT_TABLE) do
        if  seat_id >= 0 then
            playerNum = playerNum + 1
        else
            audienceNum = audienceNum + 1
        end
    end

    return playerNum, audienceNum

end

function PaiJiuReceiveHandle:SERVER_CMD_TABLE_STATE(pack)
    dump(pack,"广播桌子状态")
end
--显示玩家头像
function PaiJiuReceiveHandle:showPlayer(uid, seatId, userInfo)
    -- -------------------------存进PaiJiuReceiveHandle数组里----------------------------
    local other_index = seatId - RELATIVE_SEAT_ID

    if other_index < 0 then
        other_index = other_index + TOTAL_PLAYERNUM
    end

    local playerType = other_index + 1
    PAIJIU_PLAYERTYPE_TABLE[uid] = playerType
    --PAIJIU_SEAT_TABLE_BYPLAYERTYPE[other_index + 1] = seat_id
    dump(uid, "showPlayer_uid")
    dump(userInfo.ip, "---- showPlayer ip: ----")
    PJ_IP_TABLE[uid] = userInfo.ip
    dump(PJ_IP_TABLE, "---------- PJ_IP_TABLE showPlayer:------")
    GamePlaneOperator:showIpCheck(true)
    -----------------------------------------------------------------

    --dump(playerType,"showPlayer_playerType")
    -- USERS_READY_STATE[uid] = userInfo.isReady
    --dump(USERS_READY_STATE[uid],"showPlayer_USERS_READY_STATE")

    local head
    if  uid == USER_INFO["uid"] and isGoldGame == 0 then -- 金币场，
        head = GamePlaneOperator:showPlayerInfo(playerType, userInfo,true)
    else
        head = GamePlaneOperator:showPlayerInfo(playerType, userInfo)
    end
    -- 牌九目前没有房主图标显示
    --[[    if  isGoldGame == 1 and  seatId == 0 then   --房卡场情况下，座位号为0的人是房主
            GamePlaneOperator:showHeadSymbol(playerType,"owner",true)
        else
            GamePlaneOperator:showHeadSymbol(playerType,"owner",false)
        end]]

    GamePlaneOperator:setReadyStatus(playerType,false)  --重置准备状态

    if  GAME_STATE == GAME_STATUS_STOP  and  USERS_READY_STATE[uid] == 1 then
        GamePlaneOperator:setReadyStatus(playerType, true)
        if uid == USER_INFO["uid"] then
            if isGoldGame == 0 then
                --
                GamePlaneOperator:showInviteBtnText(2)
            else
                GamePlaneOperator:showInviteBtnText(0)
            end
            GamePlaneOperator:showInviteReadyExitBtn(1)
        end
    end

    --将head的坐标映射到世界坐标系中去
    local   worldpoint = (head:getParent()):convertToWorldSpace(head:getPosition()) --这样写是为了贴近函数的原始用法

    PLAYER_HEADS_TABLE[uid] = head
    PLAYER_HEADS_POSITION_TABLE[uid] = worldpoint

    require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(userInfo["uid"], worldpoint)

    local dict = {}
    dict.uid = uid
    dict.nickName = userInfo.nick
    dict.longitude = userInfo.longitude
    dict.latitude = userInfo.latitude
    dict.ip = userInfo.ip
    dict.gold = userInfo.coins
    dict.invote_code = USER_INFO["invote_code"]
    dict.city = userInfo.city
    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,  dict)

end

--重新显示游戏桌面（坐下之后）
function PaiJiuReceiveHandle:relocatePlayer()
    --隐藏所有头像
    GamePlaneOperator:connectClear()
    if old_seat == RELATIVE_SEAT_ID or GAME_STATE == GAME_STATUS_STOP then
        for uid, seat_id in pairs(PAIJIU_SEAT_TABLE) do
            if seat_id >= 0 then
                local user_info =  PAIJIU_USERINFO_TABLE[uid]
                self:showPlayer(uid, seat_id, user_info)
            end
            if USERS_READY_STATE[uid]==1 then
                GamePlaneOperator:setReadyStatus(PAIJIU_PLAYERTYPE_TABLE[uid], true)
            elseif uid==USER_INFO["uid"] and PAIJIU_SEAT_TABLE[uid]>-1 then
                GamePlaneOperator:showInviteReadyExitBtn(0)
            end
        end
    else
        if GAME_STATE>GAME_STATUS_SEND_CARDS then
            GamePlaneOperator:joinCards()
        end
        for uid, seat_id in pairs(PAIJIU_SEAT_TABLE) do
            if seat_id>=0 then
                local user_info =  PAIJIU_USERINFO_TABLE[uid]
                self:showPlayer(uid,seat_id, user_info)
                if GAME_STATE==GAME_STATUS_GRAB_BANKER then
                    if BANKER_UID < 1 then
                        if user_info.feedback == 0 then
                            GamePlaneOperator:showZhuangAttitude(PAIJIU_PLAYERTYPE_TABLE[uid], 2)
                        elseif user_info.feedback == 1 then
                            GamePlaneOperator:showZhuangAttitude(PAIJIU_PLAYERTYPE_TABLE[uid], 1)
                        end
                    else
        	            SCENENOW["scene"]:stopAllActions()
                        -- 定庄
                        GamePlaneOperator:showBankerAni(actiontime)
                    end
                elseif GAME_STATE==GAME_STATUS_CALL_TIMES then
                    local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
                    if uid ~= BANKER_UID then
                        local dao_count = user_info.daoCount
                        local daoArray = user_info.daoArray
                        if dao_count ~= "" and daoArray ~= "" and daoArray~=nil and dao_count ~= nil then
                            for i=1, dao_count do
                                if daoArray[i]~=nil and daoArray[i]~="" then
                                    GamePlaneOperator:setDao(playerType, i, daoArray[i],PLAYER_HEADS_POSITION_TABLE[uid])
                                end
                            end
                        end
                        if USERS_READY_STATE[uid]==1 then
                            GamePlaneOperator:showPlayerDaoPanel(playerType, true)
                        end
                    end
                elseif GAME_STATE==GAME_STATUS_SEND_CARDS then
                    GamePlaneOperator:showShizi()
                elseif GAME_STATE==GAME_STATUS_OUT_CARDS then
                    -- 玩家开牌
                    if PAIJIU_OPEN_TABLE[uid] == 1 then
                        local cardCount = CARDCOUNT * 2

                        local cardsTemp = {}
                        for i=1,cardCount do
                            table.insert(cardsTemp, 0)
                        end
                        GamePlaneOperator:openCards(PAIJIU_PLAYERTYPE_TABLE[uid],cardsTemp)
                    end
                elseif GAME_STATE==GAME_STATUS_OPEN_CARDS then
                    -- 玩家开牌
                    if PAIJIU_OPEN_TABLE[uid] == 1 then
                        local cardCount = CARDCOUNT * 2

                        local cardsTemp = {}
                        for i=1,cardCount do
                            table.insert(cardsTemp, 0)
                        end
                        GamePlaneOperator:openCards(PAIJIU_PLAYERTYPE_TABLE[uid],cardsTemp)
                    end
                end
            end
            if GAME_STATE>GAME_STATUS_CALL_TIMES then
                local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
                if uid ~= BANKER_UID and user_info then
                    local dao_count = user_info.daoCount
                    local daoArray = user_info.daoArray
                    if dao_count ~= "" and daoArray ~= "" and daoArray~=nil and dao_count ~= nil then
                        for i=1, dao_count do
                            if daoArray[i]~=nil and daoArray[i]~="" then
                                GamePlaneOperator:setDao(playerType, i, daoArray[i],PLAYER_HEADS_POSITION_TABLE[uid])
                            end
                        end
                    end
                    if USERS_READY_STATE[uid]==1 then
                        GamePlaneOperator:showPlayerDaoPanel(playerType, true)
                    end
                end
            end
        end
        if GAME_STATE==GAME_STATUS_OPEN_CARDS then
            if PAIJIU_RESULTINFO then
                dump("结算牌值----------------------------------------")
                self:SVR_OUT_CARD_BROADCAST2(PAIJIU_RESULTINFO)
            end
            GamePlaneOperator:moveGuo(1)
        end
    end
    GamePlaneOperator:guoPos()
    old_seat=RELATIVE_SEAT_ID
end
---------------------------------------------------------------------------------------------------------------

--广播用户登录桌子 100D   其他用户进入房间
function  PaiJiuReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)

    dump(pack, "------广播用户登录桌子100D------")
    self:collectPlayerData(pack)
    local playerType = PAIJIU_PLAYERTYPE_TABLE[pack.uid]
    if  playerType then
        GamePlaneOperator:showHeadSymbol(playerType,"disconnect",false)
    end

end

--广播自己退出 1008
function  PaiJiuReceiveHandle:SVR_QUICK_SUC(pack)
    dump(" ----- 广播自己退出_1008 -----")
    --[[    if  GROUP_MODE == 2 then
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
        end]]
    -- 1.在有效切回
    -- 2.无效切回
    -- require("hall.ScoketGame"):showReloginTip()
    -- 发1001
    if not is_end then
        --SCENENOW["scene"]:reConnect()
        require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
    end
end

--广播玩家退出返回（断线） 100E
function PaiJiuReceiveHandle:SVR_QUIT_ROOM(pack)

    dump(pack, "------广播玩家退出返回100E------")

    local playerType = PAIJIU_PLAYERTYPE_TABLE[pack.uid]
    if  playerType then
        GamePlaneOperator:showHeadSymbol(playerType,"disconnect",true)
    end

end


--广播用户坐下 1031
function  PaiJiuReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
    dump(pack, "1031_BROADCAST_USER_SIT_DOWN")
    if is_End then
        return
    end
    PAIJIU_SEAT_TABLE[pack.uid] = pack.seatId --保存用户座位与id映射
    local userInfo = PAIJIU_USERINFO_TABLE[pack.uid]
    if userInfo == nil then
        self:collectPlayerData(pack)
    else
        self:showPlayer(pack.uid, pack.seatId, userInfo)
    end

    if  USER_INFO["uid"] == pack.uid then
        if isGoldGame == 0 then
            -- 显示站起
            GamePlaneOperator:showInviteBtnText(2)
            GamePlaneOperator:showInviteReadyExitBtn(0)
            -- 显示快速充值按钮
            GamePlaneOperator:showBuyCoinBotton(true)
        else
            -- 显示邀请好友
            GamePlaneOperator:showInviteBtnText(0)
            if GAME_ROUND > 0 then
                GamePlaneOperator:showInviteReadyExitBtn(3)
            else
                GamePlaneOperator:showInviteReadyExitBtn(0)
            end
        end

        --重定位逻辑
        MY_SEAT_ID = pack.seatId

        --游戏过程中加入不会重定位
        --if  GAME_STATE == GAME_STATUS_STOP then
            RELATIVE_SEAT_ID = MY_SEAT_ID
            self:relocatePlayer()
        --end
    end

    if isGoldGame == 0 then
        if PLAYERNUM == TOTAL_PLAYERNUM then
            if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] == nil then
                GamePlaneOperator:showInviteReadyExitBtn(4)
            end
        end
    end
end

--广播玩家站起 1032
function PaiJiuReceiveHandle:BROADCAST_USER_STAND_UP(pack)

    dump(pack, "------广播玩家站起1032------")
    local uid = pack.uid

    local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]

    if  playerType then
        GamePlaneOperator:removePlayer(playerType)
        -- 将准备文本清空
        GamePlaneOperator:setReadyStatus(playerType, false)
        -- 准备列表清空
        USERS_READY_STATE[uid] = 0

        PAIJIU_SEAT_TABLE[pack.uid] = -2
        PAIJIU_PLAYERTYPE_TABLE[pack.uid] = nil
        PJ_IP_TABLE[pack.uid] = nil

        if  isGoldGame == 0 then
            if uid == USER_INFO["uid"] then
                GamePlaneOperator:showInviteBtnText(1)
                GamePlaneOperator:showInviteReadyExitBtn(1)
                GamePlaneOperator:showBuyCoinBotton(false)
                --if  GAME_STATE == GAME_STATUS_STOP then
                    MY_SEAT_ID = 0
                    RELATIVE_SEAT_ID = 0
                    self:relocatePlayer()
                --end
            else
                if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] == nil then
                    GamePlaneOperator:showInviteBtnText(1)
                    GamePlaneOperator:showInviteReadyExitBtn(1)
                end
            end
        end
    end

end

--广播玩家退出返回（离开房间） 1033 金币场协议
function PaiJiuReceiveHandle:BROADCAST_USER_QUIT_ROOM(pack)

    dump(pack, "------广播玩家退出返回1033------")

    local playerType = PAIJIU_PLAYERTYPE_TABLE[pack.uid]

    if  playerType then
        if isGoldGame == 0 then
            GamePlaneOperator:removePlayer(playerType)
        end
        GamePlaneOperator:showHeadSymbol(playerType,"disconnect",false)
    end

    PAIJIU_SEAT_TABLE[pack.uid] = nil
    USERS_READY_STATE[pack.uid] = nil
    PAIJIU_USERINFO_TABLE[pack.uid] = nil
    PAIJIU_PLAYERTYPE_TABLE[pack.uid] = nil

    if  pack.uid == USER_INFO["uid"] and not is_End then
        require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
    end
    require("hall.GameTips"):DeleteTimer()
end

--1041 广播下注剩余时间
function PaiJiuReceiveHandle:BROADCAST_SENDCARD_REMAINDTIME(pack)
    GamePlaneOperator:startTimer(pack.time)
end

function PaiJiuReceiveHandle:SVR_USER_CALL_TIMES_BROADCAST(pack)
    dump(pack, "------- 广播用户加倍 1101--------")
    -- 隐藏IP检测界面
    --GamePlaneOperator:showIpCheck(false)

    -- 隐藏准备文本，因为在轮庄和固定庄模式下，没有抢庄文本,只有准备文本
    GamePlaneOperator:clearAllReadyStatus()

    -- 隐藏桌面按钮
    GamePlaneOperator:showInviteReadyExitBtn(2)

    -- 隐藏抢庄界面
    GamePlaneOperator:loadZhuangPanel(false)

    -- 隐藏抢庄文本
    GamePlaneOperator:clearGrabBankerSymbol()

    local uid = pack.uid
    local sureDaoCount = pack.sureDaoCount
    local sureDaoArray = pack.sureDaoArray
    PAIJIU_USERINFO_TABLE[uid]["daoCount"]=sureDaoCount or ""
    PAIJIU_USERINFO_TABLE[uid]["daoArray"]=sureDaoArray or ""
    local canCallTimes = pack.canCallTimes

    if sureDaoCount <= 0 then
        dump(daoCount, "------- 广播用户加倍 1101---- daoCount： ----")
        return
    end

    local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
    for i=1, sureDaoCount do
        GamePlaneOperator:setDao(playerType, i, sureDaoArray[i],PLAYER_HEADS_POSITION_TABLE[uid])
    end

    -- 自己下注
    if uid == USER_INFO["uid"] then
        if canCallTimes > 0 then
            -- 自己还能下注
            CALL_TIMES_COUNT = sureDaoCount + 1
            --GamePlaneOperator:loadCallTimesPanel(true, canCallTimesCount, canCallTimesArray)
            GamePlaneOperator:callGuoPanel(true, canCallTimes)
        end

    end

end

-- 110A 广播用户出牌
function PaiJiuReceiveHandle:SVR_OUT_CARD_BROADCAST(pack,state)
    dump(pack, "-------- 广播用户出牌 110A ---------" )
    -- local openCardAniTimeOut = pack.openCardAniTimeOut
    -- local playerCount = pack.playerCount
    dump(pack.resultInfo, "SVR_OUT_CARD_BROADCAST_resultInfo")

    isNewGuo = false 
    GAME_STATE = GAME_STATUS_OPEN_CARDS

    -- 隐藏准备文本，因为在轮庄和固定庄模式下，没有抢庄文本,只有准备文本
    GamePlaneOperator:clearAllReadyStatus()

    if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] ~= nil then
        -- 自己坐下，隐藏桌面按钮
        GamePlaneOperator:showInviteReadyExitBtn(2)
    else
        -- 自己围观、只显示退出房间按钮
        GamePlaneOperator:showInviteReadyExitBtn(4)
    end

    -- 隐藏抢庄界面
    GamePlaneOperator:loadZhuangPanel(false)

    -- 隐藏抢庄文本
    GamePlaneOperator:clearGrabBankerSymbol()

    -- 清下注界面
    GamePlaneOperator:loadCallTimesPanel(false)

    -- 隐藏开牌按钮
    GamePlaneOperator:showOutCardButtons(false)

    -- 隐藏提示文本
    GamePlaneOperator:showCardGroups(false)

    -- 停止动画
    GamePlaneOperator:stopTimer()

    GamePlaneOperator:setCardRecover() --判断是否已经将牌搓开
    
    -- 开牌动画时间
    local openCardAniTimeOut = pack.openCardAniTimeOut

    local resultInfo = pack.resultInfo
    if not state then
        PAIJIU_RESULTINFO=pack
    end
    -- 整理玩家动画
    local firstAction = {}
    local secondAction = {}

    for i, info in pairs(resultInfo)do
        local uid = info.uid
        local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
        if uid == USER_INFO["uid"] and PJ_SURE_OPEN_CARD[playerType] == 0 then
            -- 自己做出牌动画
            GamePlaneOperator:showAni4Big(playerType, info.cardCombinationArrayAfterSure)
        elseif uid ~= USER_INFO["uid"] and PJ_SURE_OPEN_CARD[playerType] == 0 then
            GamePlaneOperator:showAni4Big(playerType, {})
        end
        --local seatId = info.seatId
        local cardsGroup = info.cardCombinationArrayAfterSure
        local count = #cardsGroup
        for k=1, count do
            -- 大牌九，两道
            local actionItem = {}
            local group = cardsGroup[k]
            dump(uid, "------- uid ------")
            dump(k, "----------- k -----------")
            actionItem.uid = uid
            actionItem.playerType = playerType
            -- 牌值
            dump(group.cards, "---------- cards ---------")
            actionItem.cards = group.cards
            if group.type > PJ_GROUP_TYPE_SPE or group.type == 0 then
                --todo
                actionItem.type = PJ_GROUP_TYPE[group.type]
                actionItem.cardType = group.type * 10
            else
                --actionItem.type = PJ_GROUP_TYPE[group.type] .. PJ_GROUP_POINT[group.point]
                actionItem.type = PJ_GROUP_TYPE[group.type] .. PJ_GROUP_POINT[group.point]
                actionItem.cardType = group.type * 10 + group.point
            end
            if k == 1 then
                table.insert(firstAction, actionItem)
            else
                table.insert(secondAction, actionItem)
            end
        end
    end
    function cprSeatId(a, b)
        return a.playerType < b.playerType
    end
    if #firstAction > 0 then
        table.sort(firstAction, cprSeatId)
    end
    if #secondAction > 0 then
        table.sort(secondAction, cprSeatId)
    end
    dump(firstAction, "-------1--------")
    dump(secondAction, "--------2--------")
    --local seqAc = cc.Sequence:create(cc.CallFunc:create(GamePlaneOperator:showOpenAllCardsAni, {firstAction, secondAction}))
    --SCENENOW["scene"]:runAction(cc.RepeatForever:create(seqAc))
    --self:runAction(cc.RepeatForever:create(seqAc))

    local seqAc = cc.Sequence:create(cc.DelayTime:create(0.6), cc.CallFunc:create(function()
        GamePlaneOperator:showOpenAllCardsAni(firstAction, secondAction)
    end))
    SCENENOW["scene"]:runAction(cc.RepeatForever:create(seqAc))
end
-- 110A 广播用户出牌
function PaiJiuReceiveHandle:SVR_OUT_CARD_BROADCAST2(pack)
    dump(pack, "-------- 广播用户出牌 110A ---------" )
    -- local openCardAniTimeOut = pack.openCardAniTimeOut
    -- local playerCount = pack.playerCount
    dump(pack.resultInfo, "SVR_OUT_CARD_BROADCAST_resultInfo")
    
    SCENENOW["scene"]:stopAllActions()

    GAME_STATE = GAME_STATUS_OPEN_CARDS

    -- 隐藏准备文本，因为在轮庄和固定庄模式下，没有抢庄文本,只有准备文本
    GamePlaneOperator:clearAllReadyStatus()

    if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] ~= nil then
        -- 自己坐下，隐藏桌面按钮
        GamePlaneOperator:showInviteReadyExitBtn(2)
    else
        -- 自己围观、只显示退出房间按钮
        GamePlaneOperator:showInviteReadyExitBtn(4)
    end

    -- 隐藏抢庄界面
    GamePlaneOperator:loadZhuangPanel(false)

    -- 隐藏抢庄文本
    GamePlaneOperator:clearGrabBankerSymbol()

    -- 清下注界面
    GamePlaneOperator:loadCallTimesPanel(false)

    -- 隐藏开牌按钮
    GamePlaneOperator:showOutCardButtons(false)

    -- 隐藏提示文本
    GamePlaneOperator:showCardGroups(false)

    -- 停止动画
    GamePlaneOperator:stopTimer()

    local resultInfo = pack.resultInfo
    -- 整理玩家动画
    local firstAction = {}
    local secondAction = {}

    for i, info in pairs(resultInfo)do
        local uid = info.uid
        local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
        local cardsGroup = info.cardCombinationArrayAfterSure
        local count = #cardsGroup
        for k=1, count do
            -- 大牌九，两道
            local actionItem = {}
            local group = cardsGroup[k]
            dump(uid, "------- uid ------")
            dump(k, "----------- k -----------")
            actionItem.uid = uid
            actionItem.playerType = playerType
            -- 牌值
            dump(group.cards, "---------- cards ---------")
            actionItem.cards = group.cards
            if group.type > PJ_GROUP_TYPE_SPE or group.type == 0 then
                --todo
                actionItem.type = PJ_GROUP_TYPE[group.type]
                actionItem.cardType = group.type * 10
            else
                --actionItem.type = PJ_GROUP_TYPE[group.type] .. PJ_GROUP_POINT[group.point]
                actionItem.type = PJ_GROUP_TYPE[group.type] .. PJ_GROUP_POINT[group.point]
                actionItem.cardType = group.type * 10 + group.point
            end
            if k == 1 then
                table.insert(firstAction, actionItem)
            else
                table.insert(secondAction, actionItem)
            end
        end
    end
    function cprSeatId(a, b)
        return a.playerType < b.playerType
    end
    if #firstAction > 0 then
        table.sort(firstAction, cprSeatId)
    end
    if #secondAction > 0 then
        table.sort(secondAction, cprSeatId)
    end
    local seqAc = cc.Sequence:create(cc.CallFunc:create(function()
        GamePlaneOperator:showOpenAllCardsAni(firstAction, secondAction)
    end))
    SCENENOW["scene"]:runAction(cc.RepeatForever:create(seqAc))
end

--5001
function PaiJiuReceiveHandle:BROADCAST_ERROR_TIPS(pack)

    dump(pack, "-----返回错误提示5001-----")

    
    --OPC_FAIL_GREATER_MAX = 100,         //大于下注限制
    --OPC_FAIL_LITTLE_BET_SCORE = 101,    //小于下注限制
    --OPC_FAIL_FRIST_MUST_ALL_SCORE  == 102,   //头把必满

    local errorCode = pack.errorCode

    if tbErrorCode[errorCode] then 
        require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[errorCode])
        if errorCode == 102 or errorCode == 103 or errorCode == 104 or errorCode == 105 then -- 表示下注错误
            ControlPlaneOperator:callGuoPanel(true, ControlPlaneOperator.curGuoBetLimit)
        end
    else
        require("hall.GameTips"):showTips("提示", "", 3, "未知的错误")
    end

end

--筹码相关
--获取筹码返回
function PaiJiuReceiveHandle:SVR_GET_CHIP(pack)

    dump(pack, "-----获取筹码返回906-----")
    GamePlaneOperator:setCoin(CARD_PaiJiuReceiveHandle_MY,pack.chip)

end

--5101 组局信息
function PaiJiuReceiveHandle:SVR_GROUP_TIME(pack)

    GAME_ROUND = pack.round
    GAME_TOTAL_ROUND = pack.round_total or 999
    if  isGoldGame == 1 then
        SCENENOW["scene"]:updateRoomInfo(nil, nil ,nil, GAME_ROUND,GAME_TOTAL_ROUND, nil)
    end

end


--广播玩家开启托管 1034
function PaiJiuReceiveHandle:BROADCAST_USER_AUTO_PLAY(pack)

    dump(pack, "------广播玩家开启托管 1034------")

    if  pack.uid == USER_INFO["uid"] then
        IS_AUTO_PLAY = pack.isOpenAuto

        if  pack.isOpenAuto == 0 then  --关闭托管
            GamePlaneOperator:showAutoPlayTip(false)
        else --开启托管
            GamePlaneOperator:showAutoPlayTip(true)
        end

    end

end


--广播开始游戏倒计时 100F
function PaiJiuReceiveHandle:SVR_BROADCAST_COUNT_DOWN(pack)

    dump(pack, "------广播开始游戏倒计时 100F------")

    if  pack.time > 0 then
        GamePlaneOperator:startTimer(pack.time)
    end
--[[    if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]]--[[ ~= nil then
        GamePlaneOperator:showInviteReadyExitBtn(2)
    end]]

end

--准备
--广播玩家准备 用户准备了返回 2001
function PaiJiuReceiveHandle:SVR_READY_BROADCAST(pack)

    dump(pack, "------广播玩家准备2001------")

    local  playerType = PAIJIU_PLAYERTYPE_TABLE[pack.uid]
    if pack.readyState == 1 then
        -- 将用户添加到“玩家准备表”里
        USERS_READY_STATE[pack.uid] = 1
    else
        USERS_READY_STATE[pack.uid] = 0
    end

    -- 自己准备，隐藏开始准备按钮
    if  playerType == PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] then
        --GamePlaneOperator:showInviteReadyExitBtn(1)
        if isGoldGame == 0 then
            GamePlaneOperator:showInviteBtnText(2)
            GamePlaneOperator:showInviteReadyExitBtn(1)
        else
            -- 组局还没开始
            if GAME_ROUND == 0 then
                GamePlaneOperator:showInviteReadyExitBtn(1)
            else
                GamePlaneOperator:showInviteReadyExitBtn(2)
            end
        end

        -- GamePlaneOperator:setReadyStatus(playerType, false)
    end
    -- 显示准备文本
    if  playerType then
        GamePlaneOperator:setReadyStatus(playerType,true)
    end

end

---------------------------------------------------------------------------------------------------------------------------------------------
--庄家相关
--广播开始抢庄（游戏开始，第一阶段）1103
function PaiJiuReceiveHandle:SVR_BEGIN_QIANFGZHUANG_BROADCAST(pack)

    dump(pack,"-----广播开始抢庄1103-----")

    -- 抢庄阶段
    GAME_STATE = GAME_STATUS_GRAB_BANKER
    --self:setGameStatus()
    if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] ~= nil then
        -- 自己坐下，隐藏桌面按钮
        GamePlaneOperator:showInviteReadyExitBtn(2)
    else
        -- 自己围观、只显示退出房间按钮
        GamePlaneOperator:showInviteReadyExitBtn(4)
    end

    -- 准备文本
    GamePlaneOperator:clearAllReadyStatus()

    -- 抢庄倒计时间
    local qiangTime = pack.grabBankerTimeOut

    -- 倒计时显示
    GamePlaneOperator:startTimer(qiangTime)

    -- 抢庄候选人
    local   candicatesCount = pack.candicatesCount
    if candicatesCount > 0 then
        for _, player_uid in pairs(pack.candicatesArray) do
            if USER_INFO["uid"] == player_uid then
                GamePlaneOperator:loadZhuangPanel(true)
            end
        end
    end
end

--处理抢庄  广播抢庄情况1100
function PaiJiuReceiveHandle:SVR_USER_GRABBANKER_OPTION_BROADCAST(pack)

    dump(pack,"------广播玩家抢庄选择1100-----")

    local uid = pack.uid
    PAIJIU_USERINFO_TABLE[uid]["feedback"]=1
    local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
    local  player_attitude = 1
    if pack.if_qiang == 0 then
        player_attitude = 2
        PAIJIU_USERINFO_TABLE[uid]["feedback"]=0
    end
    -- 3个按钮
    GamePlaneOperator:showInviteReadyExitBtn(2)
    -- 准备文本
    GamePlaneOperator:clearAllReadyStatus()

    -- 清空抢庄按钮
    if uid == USER_INFO["uid"] then
        GamePlaneOperator:loadZhuangPanel(false)
    end
    -- 显示玩家抢庄文本
    GamePlaneOperator:showZhuangAttitude(playerType, player_attitude)
end


--- 准备阶段    ----- 抢庄阶段 ------  加倍阶段 -----  出牌阶段

-- 准备按钮 ----- 已准备（隐藏准备按钮） ---  开始游戏按钮 -----  抢庄面板（隐藏开始游戏按钮）
---- 隐藏抢庄面板 -----  显示加倍面板 ----  隐藏加倍面板 ---- 显示出牌面板 ------ 隐藏出牌面板 ------ 准备按钮

--广播庄家id
function PaiJiuReceiveHandle:SVR_BRANK_BROADCAST(pack)

    dump(pack, "------广播庄家id 1104-----")

    -- SCENENOW["scene"]:showWaiWeiButton(_,true)
    local grabBankerTimeOut = pack.showBankerTimeOut
    local grabBankerCount = pack.grabBankerCount
    local grabBankerArray = pack.grabBankerArray
    isNewGuo = true
    if #grabBankerArray ~= grabBankerCount then
        dump("抢庄人数和抢庄人数组不匹配")
        return
    end

    BANKER_UID = pack.bankerId
    --local BankerPlayerType = PAIJIU_PLAYERTYPE_TABLE[BANKER_UID]

    --GamePlaneOperator:stopTimer()

    -- 隐藏IP检测界面
    --GamePlaneOperator:showIpCheck(false)

    -- 隐藏准备文本，因为在轮庄和固定庄模式下，没有抢庄文本,只有准备文本
    GamePlaneOperator:clearAllReadyStatus()

    -- 隐藏桌面按钮
    GamePlaneOperator:showInviteReadyExitBtn(2)

    -- 隐藏抢庄界面
    GamePlaneOperator:loadZhuangPanel(false)

    -- 隐藏抢庄文本
    GamePlaneOperator:clearGrabBankerSymbol()

    -- 抢庄动画
    GamePlaneOperator:showGrabBankerAnim(grabBankerCount, grabBankerArray, grabBankerTimeOut)

end
---------------------------------------------------------------------------------------------------------------------------------------------
--倍数相关
--处理加倍
function PaiJiuReceiveHandle:BROADCAST_BEGIN_CALL_TIMES(pack)

    dump(pack, "----广播玩家开始加倍1105-----")

    GAME_STATE = GAME_STATUS_CALL_TIMES
    --self:setGameStatus()
    -- 隐藏IP检测
    GamePlaneOperator:showIpCheck(false)

    -- 显示加倍倒计时
    GamePlaneOperator:startTimer(pack.callTimesTimtOut)

    for uid, _ in pairs(PAIJIU_SEAT_TABLE) do
        local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
        if playerType then
            if uid == BANKER_UID then
                GamePlaneOperator:showPlayerDaoPanel(playerType, false)
            else
                if USERS_READY_STATE[uid]==1 then 
                    GamePlaneOperator:showPlayerDaoPanel(playerType, true)
                end
            end
        end
    end
end

function PaiJiuReceiveHandle:SVT_PLAYER_CALL_TIMES(pack)
    dump(pack, "---------- 通知玩家加倍 1106 ------")
    -- 隐藏IP检测界面
    --GamePlaneOperator:showIpCheck(false)

    -- 隐藏准备文本，因为在轮庄和固定庄模式下，没有抢庄文本,只有准备文本
    GamePlaneOperator:clearAllReadyStatus()

    -- 隐藏桌面按钮
    GamePlaneOperator:showInviteReadyExitBtn(2)

    -- 隐藏抢庄界面
    GamePlaneOperator:loadZhuangPanel(false)

    -- 隐藏抢庄文本
    GamePlaneOperator:clearGrabBankerSymbol()

    local guoBetLimit = pack.guoBetLimit
    -- 确定是第几道加倍
    CALL_TIMES_COUNT = CALL_TIMES_COUNT + 1

    -- 锅下注
    GamePlaneOperator:callGuoPanel(true, guoBetLimit)

end

function PaiJiuReceiveHandle:SVR_SHAIZI_BROADCAST(pack)
    dump(pack, "---------- 广播骰子数 1107 ------")
    -- 发牌阶段，即摇骰子
    GAME_STATE = GAME_STATUS_SEND_CARDS

    local shaiziTimeOut = pack.shaiziTimeOut
    local shaiziCount = pack.shaiziCount
    local shaiziArray = pack.shaiziArray
    -- 显示倒计时
    -- GamePlaneOperator:startTimer(shaiziTimeOut)
    GamePlaneOperator:stopTimer()

    -- 隐藏准备文本，因为在轮庄和固定庄模式下，没有抢庄文本,只有准备文本
    GamePlaneOperator:clearAllReadyStatus()

    -- 隐藏桌面按钮
    GamePlaneOperator:showInviteReadyExitBtn(2)

    -- 隐藏抢庄界面
    GamePlaneOperator:loadZhuangPanel(false)

    -- 隐藏抢庄文本
    GamePlaneOperator:clearGrabBankerSymbol()

    -- 清下注界面
    GamePlaneOperator:callGuoPanel(false)

    -- 骰子动画
    GamePlaneOperator:showShiziAnimotion(shaiziCount, shaiziArray, shaiziTimeOut)
end

--广播加倍倍数
function PaiJiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack)

    dump(pack, "-----广播加倍倍数6014-----")

    local playerType = PAIJIU_PLAYERTYPE_TABLE[pack.uid]
    GamePlaneOperator:setBetTimes(playerType,pack.base)

    if  playerType == CARD_PLAYERTYPE_MY then
        GamePlaneOperator:showControlButtons(3,false)
    end

end

---------------------------------------------------------------------------------------------------------------------------------------------

--发牌相关
--处理发牌协议 1109
function PaiJiuReceiveHandle:SVR_SEND_USER_CARDS(pack)

    dump(pack, "------发送用户的牌信息1109------")
    PJ_HANDCARDS = pack.cardsArray
    PJ_AVAI_CARD_GROUPS = pack.allCardsCombinationArray

    -- 隐藏准备文本，因为在轮庄和固定庄模式下，没有抢庄文本,只有准备文本
    GamePlaneOperator:clearAllReadyStatus()

    -- 隐藏桌面按钮
    GamePlaneOperator:showInviteReadyExitBtn(2)

    -- 隐藏抢庄界面
    GamePlaneOperator:loadZhuangPanel(false)

    -- 隐藏抢庄文本
    GamePlaneOperator:clearGrabBankerSymbol()

    -- 清下注界面
    GamePlaneOperator:callGuoPanel(false)

    -- 画牌
    GamePlaneOperator:showCards(1, PJ_HANDCARDS)

    if #PJ_HANDCARDS == 2 then
        --todo
        PJ_CARDS_SELECTED = {}
        PJ_CARDS_SELECTED[1] = PJ_HANDCARDS[1]
        PJ_CARDS_SELECTED[2] = PJ_HANDCARDS[2]
    end
end

--出牌相关
--广播玩家已准备好出牌 0x1102
function PaiJiuReceiveHandle:SVR_READY_OUTCARD_BROADCAST(pack)
    dump(pack, "-----广播玩家已经准备好出牌1102-----")
    --显示阶段信息
    -- GAME_STATE = GAME_STATUS_OUTCARD --棋牌进行中
    -- 隐藏准备文本，因为在轮庄和固定庄模式下，没有抢庄文本,只有准备文本
    GamePlaneOperator:clearAllReadyStatus()

    -- 隐藏桌面按钮
    GamePlaneOperator:showInviteReadyExitBtn(2)

    -- 隐藏抢庄界面
    GamePlaneOperator:loadZhuangPanel(false)

    -- 隐藏抢庄文本
    GamePlaneOperator:clearGrabBankerSymbol()

    -- 清下注界面
    GamePlaneOperator:callGuoPanel(false)

    PAIJIU_OPEN_TABLE[pack.uid]=1
    if #pack.cardGroupsArray > 0 then
        --todo
        -- 清除开牌按钮
        GamePlaneOperator:showOutCardButtons(false)
        --GamePlaneOperator:openCards(1, pack.cardGroupsArray)
        GamePlaneOperator:showAni4Big(1, pack.cardGroupsArray)
        --IS_SURE_OPEN = true
        PJ_SURE_OPEN_CARD[1] = 1
        --PAIJIU_OPEN_TABLE[pack.uid]=1
    else
        local playerType = PAIJIU_PLAYERTYPE_TABLE[pack.uid]
        GamePlaneOperator:showAni4Big(playerType, {})
        PJ_SURE_OPEN_CARD[playerType] = 1
        --PAIJIU_OPEN_TABLE[pack.uid]=1
    end


end

-- 广播玩家开始出牌 0x1108
function PaiJiuReceiveHandle:SVR_START_OUT_CARD_BROADCAST(pack)
    dump(pack, "------ 广播玩家可以开始出牌 1108----------")
    GAME_STATE = GAME_STATUS_OUT_CARDS
    -- 出牌倒计时
    GamePlaneOperator:startTimer(pack.outCardTimeOut)

    GamePlaneOperator:showRemainCards(pack.remainCardsCount)

    -- 隐藏准备文本，因为在轮庄和固定庄模式下，没有抢庄文本,只有准备文本
    GamePlaneOperator:clearAllReadyStatus()

    -- 隐藏桌面按钮
    GamePlaneOperator:showInviteReadyExitBtn(2)

    -- 隐藏抢庄界面
    GamePlaneOperator:loadZhuangPanel(false)

    -- 隐藏抢庄文本
    GamePlaneOperator:clearGrabBankerSymbol()

    -- 清下注界面
    GamePlaneOperator:callGuoPanel(false)

    local card_tbl = {}
    for i=1, pack.handCardsCount do
        table.insert(card_tbl, i, 0)
    end
    dump(PAIJIU_PLAYERTYPE_TABLE,"PAIJIU_PLAYERTYPE_TABLE ==")
    local size = table.nums(PAIJIU_PLAYERTYPE_TABLE)

    --
    for uid, playerType in pairs(PAIJIU_PLAYERTYPE_TABLE) do
        --dump(playerType, "SVR_START_OUT_CARD = ")
        GamePlaneOperator:showCards(playerType, card_tbl)
    end

    --for playerType=1, size do--
    --  GamePlaneOperator:showCards(playerType, card_tbl)
    --end

    --4人
    --[[for playerType=1, TOTAL_PLAYERNUM do
        GamePlaneOperator:showCards(playerType, card_tbl)
    end]]


end

---------------------------------------------------------------------------------------------------------------------------------------------

--结算
function PaiJiuReceiveHandle:SVR_SETTLEMENT_BROADCAST(pack)
    dump(pack, "-----牌九结算6008-----")
    if SCENENOW["name"] ~= run_scene_name then
        print("当前场景不是牌九游戏场景！")
        return
    end
    
    GamePlaneOperator:showGuoDi(pack.guoDiNumber)

    GamePlaneOperator:showIpCheck(false)

    GAME_STATE=GAME_STATUS_STOP

    local playerCount = pack.playerCount

    -- 隐藏开牌按钮
    GamePlaneOperator:showOutCardButtons(false)
    
    SCENENOW["scene"]:stopAllActions()

    SCENENOW["scene"]:initData("clearGameData")
    -- 玩家头像：庄，输赢合（目前没做）
    GamePlaneOperator:clearGameDatas(2)
    is_show = false

    if not is_End then
        SCENENOW["scene"]:performWithDelay(function()
            if is_qie then
                GamePlaneOperator:showGuoChoosePanel(true, qie_type)
            elseif is_doing_qie then
            else
                if isGoldGame == 0 then
                    if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] ~= nil then
                        GamePlaneOperator:showInviteBtnText(2)
                        GamePlaneOperator:showInviteReadyExitBtn(0)
                    else
                        GamePlaneOperator:showInviteReadyExitBtn(4)
                    end
                else
                    if not self.b_waitQuitBank then
                        GamePlaneOperator:showInviteReadyExitBtn(3)
                    end
                end
            end
        end,1)
    end

    if isGoldGame==1 then
        SCENENOW["scene"]:performWithDelay(function()
            if GROUP_RESULT then
                self:showResult2(GROUP_RESULT)
            end
        end,1)
    end

    local is_win = true
    for i=1, playerCount do
        local info = pack.userinfo[i]
        if USER_INFO["uid"] == info.uid then
            if info.chips < 0 then
                is_win = false
            end
        end
        if info.uid~=BANKER_UID then
            GamePlaneOperator:deletechip(PAIJIU_PLAYERTYPE_TABLE[info.uid],(info.chips/100),PLAYER_HEADS_POSITION_TABLE[info.uid])
        end
    end

    if not is_win then
        -- 输音效
        SoundUtils:playEffect("输")
    else
        -- 赢音效
        SoundUtils:playEffect("赢")
    end

    for i=1, playerCount do
        local info = pack.userinfo[i]
        GamePlaneOperator:showend(PAIJIU_PLAYERTYPE_TABLE[info.uid],(info.chips/100))
        GamePlaneOperator:updateCoin(PAIJIU_PLAYERTYPE_TABLE[info.uid], (info.chips/100),nil, info.uid)
        PAIJIU_USERINFO_TABLE[info.uid].coins=PAIJIU_USERINFO_TABLE[info.uid].coins+(info.chips/100)
    end
    
    --is_show = true

    for uid,_ in pairs(PAIJIU_USERINFO_TABLE) do
        USERS_READY_STATE[uid]=0
        PAIJIU_USERINFO_TABLE[uid]["feedback"]=0
        PAIJIU_USERINFO_TABLE[uid]["daoCount"]=""
        PAIJIU_USERINFO_TABLE[uid]["daoArray"]=""
        PAIJIU_OPEN_TABLE[uid]=0
    end
    --BANKER_UID=0;
end

--广播扣台费
function PaiJiuReceiveHandle:SVR_CHIP_CHANGE_BROADCAST(pack)
    dump(pack,"-------------扣除台费--------------")
    for _,data in pairs(pack.userinfo) do

        local uid = data.uid
        local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
        local oriChip = PAIJIU_USERINFO_TABLE[uid].coins 
        local chip = oriChip + data.change_chip / 100
        PAIJIU_USERINFO_TABLE[uid].coins  = chip

        GamePlaneOperator:setCoin(playerType,chip)

        --if  uid == USER_INFO["uid"] then
        --    --GamePlaneOperator:showTaiFeiTips(data.change_chip)
        --end
    end
end
    --组局排行榜 5100
function PaiJiuReceiveHandle:SVR_GROUP_BILLBOARD(pack)

    dump(pack, "-----牌九组局排行榜5100-----")
    dump(GAME_ROUND, "-----牌九组局排行榜GAME_ROUND-----")
    GROUP_RESULT = pack
    is_End = true
    if not is_show then
        self:showResult2(pack)
    end
end

--显示组局总结果 5100
function PaiJiuReceiveHandle:showResult(pack)
    dump(pack, "--5100_showResult--")

    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end
    local s = cc.CSLoader:createNode(TotalResultCsb_filePath)
    -- s:setScale(0.75)
    --s:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
    SCENENOW["scene"]:addChild(s)

    --退出按钮（当前组局结算，返回到大厅）
    local back_bt = s:getChildByName("back_bt")
    back_bt:addTouchEventListener(
    function(sender,event)
        --触摸开始
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end

        --触摸取消
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        --触摸结束
        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)

            --退出房间，返回大厅
            -- require("majiang.ddzSettings"):setEndGroup(2)
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
            require("hall.util.GameUtil"):LogoutRoom()
        end
    end
    )

    --结果显示区域
    local content_ly = s:getChildByName("content_ly")
    local content_sv = content_ly:getChildByName("content_sv")

    --显示用户结算结果
    local playerlist = pack.playerlist
    if #playerlist > 0 then

        --记录最佳炮手和大富豪
        --[[        local paoshou_uid = nil
                local lastPaoNum = 0]]

        local fuhao_uid = nil
        local lastChip = 0
        local max_win_chip = -10000000000
        -- 找出大富翁
        for k, v in pairs(playerlist)do
            if tonumber(v.chips) > max_win_chip then
                fuhao_uid = v.uid
            end
        end

        --[[        for k, v in pairs(playerlist) do]]
        --[[
        ]]

        --[[            --获取用户id]]
        --[[            local uid = v.uid]]
        --[[
        ]]

        --[[            --获取用户信息以及结算情况]]
        --[[            --local user_info = json.decode(v.user_info)]]
        --[[
        ]]

        --[[            if conditions then]]
        --[[                --todo]]
        --[[            end]]
        --[[
        ]]

        --[[            local dianpao_dahu_count = user_info.dianpao_dahu or 0]]
        --[[            local dianpao_xiaohu_count = user_info.dianpao_xiaohu or 0]]
        --[[            --获取用户点炮数]]
        --[[            local dianpao = dianpao_dahu_count + dianpao_xiaohu_count]]
        --[[            if dianpao ~= nil then]]
        --[[                --比较点炮数]]
        --[[                if dianpao > lastPaoNum then]]
        --[[                    --记录最新点炮数和点炮id]]
        --[[                    lastPaoNum = dianpao]]
        --[[                    paoshou_uid = uid]]
        --[[                end]]
        --[[            end]]
        --[[
        ]]

        --[[
        ]]

        --[[            --获取用户分数]]
        --[[            local chips = user_info.chips]]
        --[[            if chips ~= nil then]]
        --[[                --比较分数]]
        --[[                local cha = chips - 2000]]
        --[[                if cha > lastChip then]]
        --[[                    --记录最新点炮数和点炮id]]
        --[[                    lastChip = cha]]
        --[[                    fuhao_uid = uid]]
        --[[                end]]
        --[[            end]]
        --[[
        ]]

        --[[        end]]

        local zOrder = 10

        --生成界面
        for k, user_info in pairs(playerlist) do

            --获取用户id
            local uid = user_info.uid

            --[[            --获取用户信息以及结算情况
                        local user_info = json.decode(v.user_info)]]

            --定义结果分项
            local ResultItemCsb_filePath = ResultItemCsb_filePath

            local result_Item = cc.CSLoader:createNode(ResultItemCsb_filePath)
            result_Item:setLocalZOrder(zOrder)
            zOrder = zOrder - 1
            content_sv:addChild(result_Item)

            local item_ly = result_Item:getChildByName("item_ly")
            item_ly:setPosition(300 * (k - 1), content_sv:getContentSize().height)

            --[[            --显示最佳炮手
                        local paoshou_im = item_ly:getChildByName("paoshou_im")
                        if paoshou_uid ~= nil then
                            if paoshou_uid == uid then
                                paoshou_im:setVisible(true)
                            end
                        end]]

            --显示大富豪
            local winner_im = item_ly:getChildByName("winner_im")
            if fuhao_uid ~= nil then
                if fuhao_uid == uid then
                    winner_im:setVisible(true)
                end
            end

            local top_ly = item_ly:getChildByName("top_ly")

            --用户头像
            local head_im = top_ly:getChildByName("head_im")
            --require("hall.GameCommon"):getUserHead(user_info.photo_url, uid, user_info.sex, head_im, 88, false, user_info.nickName)
            require("hall.GameCommon"):getUserHead(user_info.portrait, uid, user_info.sex, head_im, 88, false)
            --require("hall.GameCommon"):getUserHead(user_info.photo_url, uid, user_info.sex, head_im, 88, false)
            --是否为房主
            local roomowner_im = top_ly:getChildByName("roomowner_im")
            --只有房主才出现房主标志
            local group_owner = tonumber(USER_INFO["group_owner"])
            if group_owner == uid then
                roomowner_im:setVisible(true)
            else
                roomowner_im:setVisible(false)
            end

            --用户昵称
            if  PAIJIU_USERINFO_TABLE then
                local name_tt = top_ly:getChildByName("name_tt")

                local nick = "未知昵称"
                if PAIJIU_USERINFO_TABLE[uid] then
                    nick = PAIJIU_USERINFO_TABLE[uid].nick
                end
                name_tt:setString(nick)
            end

            --用户id
            local id_tt = top_ly:getChildByName("id_tt")
            id_tt:setString("ID:" .. tostring(uid))

            --中间区域
            local content_sv = item_ly:getChildByName("content_sv")
            content_sv:setVisible(true)
            --单局最高分数
            local dhzm_ly = content_sv:getChildByName("dhzm_ly")
            local dhzm_itemName_tt = dhzm_ly:getChildByName("itemName_tt")
            local dhzm_itemNum_tt = dhzm_ly:getChildByName("itemNum_tt")
            if user_info.maxScore ~= nil then
                dhzm_itemName_tt:setString("单局最高分数")
                dhzm_itemNum_tt:setString(tostring(user_info.maxScore))
            end

            --单局最大牌型
            local xhzm_ly = content_sv:getChildByName("xhzm_ly")
            local xhzm_itemName_tt = xhzm_ly:getChildByName("itemName_tt")
            local xhzm_itemNum_tt = xhzm_ly:getChildByName("itemNum_tt")
            if user_info.maxCardsType ~= nil then
                xhzm_itemName_tt:setString("单局最大牌型")
                local str_type = ""
                if user_info.maxCardsType > PJ_GROUP_TYPE_SPE or user_info.maxCardsType == 0 then
                    --todo
                    str_type = PJ_GROUP_TYPE[user_info.maxCardsType]
                else
                    str_type = PJ_GROUP_TYPE[user_info.maxCardsType] .. PJ_GROUP_POINT[user_info.maxCardPoint]
                end
                xhzm_itemNum_tt:setString(str_type)
            end

            --胜利局数
            local dhdp_ly = content_sv:getChildByName("dhdp_ly")
            local dhdp_itemName_tt = dhdp_ly:getChildByName("itemName_tt")
            local dhdp_itemNum_tt = dhdp_ly:getChildByName("itemNum_tt")
            if user_info.winCount ~= nil then
                dhdp_itemName_tt:setString("胜利局数")
                dhdp_itemNum_tt:setString(tostring(user_info.winCount))
            end

            --通杀次数
            local xhdp_ly = content_sv:getChildByName("xhdp_ly")
            local xhdp_itemName_tt = xhdp_ly:getChildByName("itemName_tt")
            local xhdp_itemNum_tt = xhdp_ly:getChildByName("itemNum_tt")
            if user_info.winAllCount ~= nil then
                xhdp_itemName_tt:setString("通杀次数")
                xhdp_itemNum_tt:setString(tostring(user_info.winAllCount))
            end

            --通赔次数
            local dhjp_ly = content_sv:getChildByName("dhjp_ly")
            local dhjp_itemName_tt = dhjp_ly:getChildByName("itemName_tt")
            local dhjp_itemNum_tt = dhjp_ly:getChildByName("itemNum_tt")
            if user_info.loseAllCount ~= nil then
                dhjp_itemName_tt:setString("通赔次数")
                dhjp_itemNum_tt:setString(tostring(user_info.loseAllCount))
            end

            --大叫
            local xhjp_ly = content_sv:getChildByName("xhjp_ly")
            local xhjp_itemNum_tt = xhjp_ly:getChildByName("itemNum_tt")
            xhjp_ly:setVisible(false)

            --底部区域
            local bottom_ly = item_ly:getChildByName("bottom_ly")

            --总成绩
            --用户当前的积分
            local chips = user_info.chips
            local socre_tt = bottom_ly:getChildByName("socre_tt")
            socre_tt:setString(tostring(chips))

        end

    end

    local share_ly = s:getChildByName("share_ly")
    share_ly:addTouchEventListener(
    function(sender,event)
        --触摸开始
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end

        --触摸取消
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        --触摸结束
        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)

            --通知APP分享结果
            if device.platform == "android" then
                require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
            elseif device.platform ~= "windows" then
                require("hall.common.ShareLayer"):shareGroupResultForIOS()
            end

        end
    end
    )

    HEART_BEAT_TID = 0

end

--显示组局总结果
function PaiJiuReceiveHandle:showResult2(pack)
    dump("showResult2-------------------")
    --local pack = json.decode(pack.msg_data)
    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end

    --退出按钮（当前组局结算，返回到大厅）
    local backHall_action = function(sender,event)
        --退出房间，返回大厅
        --CLUB_ID
        require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
        HEART_BEAT_TID = 0
    end

    --截屏分享
    local share_action = function(sender,event)
        if device.platform == "android" then
            require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
        elseif device.platform ~= "windows" then
            require("hall.common.ShareLayer"):shareGroupResultForIOS()
        end    
    end

    local extend_action = function(sender, event)
        --require(TpackageName..".NiuNiuUtils"):returnToHall()
        require('hall.groudgamemanager'):extend_freegame(USER_INFO['uid'], USER_INFO['activity_id'])
    end

    local data = {}
    data["resultSceneType"] = 1       --战绩界面展示选择，1为长条形，2为方块形
    data["invote_code"] = USER_INFO["invote_code"]     --房间号
    data["fenchang"] = FENCHANG            --分场
    data["round"] = GAME_ROUND                  --局数
    data["date"] = os.date("%Y-%m-%d-%H:%M")    --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
    data["resultData"] = {}             --玩家数据数组
    data['activity_id'] = USER_INFO['activity_id']

    --显示用户结算结果
    local playerlist = pack.playerlist

    local fuhao_uid = nil
    local lastChip = 0
    local playerNum = 0
    dump(playerlist,"playerlist")
    for k,v in pairs(playerlist) do
        playerNum = playerNum+1
        --获取用户id
        local uid = tonumber(k)
        local chips

        ------------------------------------------------数据---------------------------------------
        --if  GROUP_MODE == 2 then
            chips = v.chip
        --else
        --    --获取用户信息以及结算情况
        --    local user_info = json.decode(v.user_info)
        --    local oriChips = user_info.oriChips or initialChip
        --    --获取用户分数
        --    chips = user_info.chips - oriChips
        --end

        ---------------------------------------------------------------------------------------------
        --dump(chips,"0000000000000000000000")
        if chips ~= nil then
            --比较分数
            if chips > lastChip then
                --记录最新点炮数和点炮id
                lastChip = chips
                fuhao_uid = uid
            end
        end
    end

    if playerNum > 0 then
        --生成界面
       -- dump(playerNum,"0000000000000000000000")
        for k,v in pairs(playerlist) do
            --dump(v,"11111111111111111111111111")
            ------------------------------------------数据-----------------------------------
            local uid = v.uid--tonumber(k)
            local photo_url
            local sex = 1
            local nick_name
            local chips

            --if GROUP_MODE == 2 then
                --photo_url = PAIJIU_USERINFO_TABLE[uid].icon_url or ""
                --require("hall.GameCommon"):getUserHead(v.portrait, uid, v.sex, photo_url, 88, false)
           -- dump(photo_url,"222222222222222222222222222222")
                --nick_name = PAIJIU_USERINFO_TABLE[uid].nick or ""
            --dump(nick_name,"33333333333333333333333333333")
                chips  = v.chips --ERBA_USERINFO_TABLE[uid].coins
            --dump(chips,"444444444444444444444444444444444444444")
            --else
            --    local user_info = json.decode(v.user_info)
            --
                photo_url = v.portrait
                nick_name = v.nickName
                sex = v.sex
            --
            --    local oriChips = user_info.oriChips or initialChip
            --    chips = user_info.chips - oriChips
            --end

            -------------------------------------------界面-------------------------------------------

            local namenick = ""
            --if  PAIJIU_USERINFO_TABLE[uid] then
                --dump(ERBA_USERINFO_TABLE[uid],"555555555555555555555555555555555555")
            --    namenick = PAIJIU_USERINFO_TABLE[uid].nick or "未知昵称"
                namenick = require("hall.GameCommon"):formatNick(nick_name, 7)
            --end

            if GAME_ROUND == 0 and chips == -20000 then
                chips = 0
            end

            local p1 = {}             --玩家数据实体
            p1["nick"] = namenick         --昵称
            p1["uid"] = uid         --uid
            p1["icon_url"] = photo_url  --头像链接
            p1["sex"] = 1               --性别
            p1["isRoomOwer"] = (tonumber(USER_INFO["group_owner"]) == v.uid and 1) or 0        --是否为房主，1是，非1或不填不是

            if uid == fuhao_uid then
                p1["isWinner"] = 1          --是否为赢家，1是，非1或不填不是
            end

            if chips > 0 then
                p1["total"] = "+" .. chips
            elseif  chips < 0 then
                p1["total"] = tostring(chips)
            end

            local gameDetail1 = {}           --游戏详情实体
            gameDetail1["showName"] = "单局最高分数"   --展示名
            gameDetail1["value"] = v.maxScore or 0         --值
    
            local gameDetail2 = {}
            gameDetail2["showName"] = "单局最大牌型"
            local str_type = ""
            if v.maxCardsType > PJ_GROUP_TYPE_SPE or v.maxCardsType == 0 then
            --todo
                str_type = PJ_GROUP_TYPE[v.maxCardsType]
            else
                str_type = PJ_GROUP_TYPE[v.maxCardsType] .. PJ_GROUP_POINT[v.maxCardPoint]
            end
            gameDetail2["value"] = str_type or 0
    
            local gameDetail3 = {}
            gameDetail3["showName"] = "胜利局数"
            gameDetail3["value"] = v.winCount or 0

            local gameDetail4 = {}
            gameDetail4["showName"] = "通杀次数"
            gameDetail4["value"] = v.winAllCount or 0

            local gameDetail5 = {}
            gameDetail5["showName"] = "通赔次数"
            gameDetail5["value"] = v.loseAllCount or 0

            p1["gameDetail"]={}
            table.insert(p1["gameDetail"], gameDetail1)
            table.insert(p1["gameDetail"], gameDetail2)
            table.insert(p1["gameDetail"], gameDetail3)
            table.insert(p1["gameDetail"], gameDetail4)
            table.insert(p1["gameDetail"], gameDetail5)
            table.insert(data["resultData"], p1)
            --dump(data["resultData"],"66666666666666666666666666666666666")
        end

    end

    --require(GameResultScene_filePath):showScene(data, backHall_action, share_action)
    --采用新大厅
    require("hall.settlement.settlement").new(data, backHall_action, share_action, nil, extend_action)

end

--------------------------------------周边功能-----------------------------------------
--组局解散相关
--没有此房间，解散房间失败
function PaiJiuReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)

    --dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")
    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")
end

--广播当前组局解散情况
function PaiJiuReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)

    dump(pack, "-----广播当前组局解散情况-----")
    dump(PAIJIU_USERINFO_TABLE, "-----广播当前房间情况-----")

    local applyId = pack.applyId
    local agreeNum = pack.agreeNum
    local agreeMember_arr = pack.agreeMember_arr

    local disband_table = {}

    --申请解散者信息
    if applyId == USER_INFO["uid"] then
        local player_table = {}
        player_table["playerName"] = "我"
        player_table["state"] = "申请"
        table.insert(disband_table, player_table)
    else
        local player_table = {}
        local applyer_info = PAIJIU_USERINFO_TABLE[applyId]
        dump(applyer_info, "-----广播当前房间情况applyer_info-----")
        if applyer_info ~= nil then
            local nickName = applyer_info.nick or ""
            if nickName ~= nil then
                player_table["playerName"] = nickName
            else
                player_table["playerName"] = tostring(applyId)
            end
        else
            player_table["playerName"] = tostring(applyId)
        end

        player_table["state"] = "申请"

        table.insert(disband_table, player_table)
    end

    local isMyAgree = 0
    if applyId ~= USER_INFO["uid"] then
        --假如申请者不是自己，添加自己的选择情况
        if agreeNum > 0 then
            for k,v in pairs(agreeMember_arr) do
                if v == USER_INFO["uid"] then
                    isMyAgree = 1
                    break
                end
            end
        end

        local player_table = {}
        player_table["playerName"] = "我"

        if isMyAgree == 1 then
            player_table["state"] = "同意"
        else
            player_table["state"] = "等待选择"
        end

        player_table["icon"] = USER_INFO["icon_url"]

        table.insert(disband_table, player_table)

    end

    --显示其他人情况
    for k,v in pairs(PAIJIU_USERINFO_TABLE) do
        dump(v, "-----显示其他人情况-----")
        local uid = v.uid
        --排除掉申请者，申请者不需要显示到这里
        if uid ~= applyId and uid ~= USER_INFO["uid"] then

            --记录当前用户是否已经同意
            local isAgree = 0
            if agreeNum > 0 then
                for k,v in pairs(agreeMember_arr) do
                    if uid == v then
                        --当前用户已经同意
                        isAgree = 1
                        break
                    end
                end
            end

            --显示当前用户情况
            local player_table = {}
            local nickName = v.nick
            if nickName ~= nil then

                player_table["playerName"] = nickName

                if isAgree == 1 then
                    player_table["state"] = "同意"
                else
                    player_table["state"] = "等待选择"
                end

                player_table["icon"] = v.icon_url

                table.insert(disband_table, player_table)

            end

        end
    end

    local function agree_disband(value)
        PaiJiuSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(value)
    end

    if applyId == USER_INFO["uid"] then
        --假如申请者是自己，则直接显示其他用户的选择情况
        require("hall.GameTips"):showDisbandNewTips("提示", "agree_disbandGroup", 4, disband_table)
    else
        --申请者不是自己，根据自己的同意情况进行界面显示
        if isMyAgree == 1 then
            require("hall.GameTips"):showDisbandNewTips("提示", "agree_disbandGroup", 4, disband_table)
        else
            require("hall.GameTips"):showDisbandNewTips("提示", "new_request_disbandGroup", 1, disband_table,agree_disband)
        end
    end
    
    require("hall.GameTips"):StartTimer(180)

end

--广播桌子用户请求解散组局
function PaiJiuReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

    --dump(pack, "-----广播桌子用户请求解散组局-----")

    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")

end

--广播桌子用户成功解散组局
function PaiJiuReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

    --dump(pack, "-----广播桌子用户成功解散组局-----")

    bm.isDisbandSuccess = true
    HEART_BEAT_TID = 0
    -- require("hall.GameTips"):showDisbandTips("解散房间成功","ddz_disbandGroup_success",3)

end

--广播桌子用户解散组局 ，解散组局失败
function PaiJiuReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

    --dump(pack, "-----广播桌子用户解散组局 ，解散组局失败-----")

    local rejectId = pack.rejectId
    if rejectId == USER_INFO["uid"] then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
    else
        local nickName = PAIJIU_USERINFO_TABLE[rejectId].nick or "路人甲"
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2,  nickName.. "拒绝解散房间")
    end

end

--聊天
function PaiJiuReceiveHandle:SVR_MSG_FACE(pack)
    dump(pack, "-------SVR_MSG_FACE_1004------")
    local s= SCENENOW["scene"]:getChildByName("faceUI")

    local sex = 1

    if PAIJIU_USERINFO_TABLE[pack.uid] then
        sex = PAIJIU_USERINFO_TABLE[pack.uid].sex or 0
    end
    local isLeft = false
    if PAIJIU_PLAYERTYPE_TABLE[pack.uid] == CARD_PLAYERTYPE_TOP or PAIJIU_PLAYERTYPE_TABLE[pack.uid] == CARD_PLAYERTYPE_RIGHT then
        isLeft = true
    end

    local node_head = PLAYER_HEADS_TABLE[pack.uid]
    if tonumber(sex) >= 0 then
        s:showGetFace(pack.uid, pack.type, tonumber(sex), node_head, isLeft)
    end

end
-----------------------------------------------------------------------------------------------------------------------------
function PaiJiuReceiveHandle:showTextMessage(pack)

    local s= SCENENOW["scene"]:getChildByName("faceUI")

    local sex = 1

    if PAIJIU_USERINFO_TABLE[pack.uid] then
        sex = PAIJIU_USERINFO_TABLE[pack.uid].sex or 0
    end

    local node_head = PLAYER_HEADS_TABLE[pack.uid]

    s:showGetText(pack.uid,pack.textMessage,tonumber(sex),node_head, false)
end


function PaiJiuReceiveHandle:showExpression(msg)
    local uid_from = tonumber(msg["uid_from"]) or 1
    local uid_to = tonumber(msg["uid_to"]) or 1
    local expressionType = tonumber(msg["expressionType"]) or 1

    ---------------------------------不同游戏需修改的部分----------------------------
    -- --通过UID获取seat_id
    -- local seat_id_from = USERID2SEAT[uid_from] or 2
    -- local seat_id_to =  USERID2SEAT[seat_id_to] or 0

    --制定座位号对应的动画播放起始和结束的大概位置
    ------------------------------------------------------------------------------------
    local playerHeadPosition_from = PLAYER_HEADS_POSITION_TABLE[uid_from] or {x=0,y=0}
    local from_x = playerHeadPosition_from.x
    local from_y = playerHeadPosition_from.y

    local playerHeadPosition_to = PLAYER_HEADS_POSITION_TABLE[uid_to] or {x=0,y=0}
    local to_x   = playerHeadPosition_to.x
    local to_y   = playerHeadPosition_to.y

    require("hall.view.animView.animView"):ShowAnimationByPosition(from_x, from_y,to_x,to_y,expressionType)

end

--接收服务器返回的组局信息
function PaiJiuReceiveHandle:SERVER_CMD_MESSAGE(pack)
    dump("----------- 801 -------------")
    if bm.isInGame == false then
        return
    end

    local msg = json.decode(pack.msg)
    --dump(msg, "-----PaiJiuReceiveHandle 接收服务器返回的组局信息-----")
    if msg ~= nil then
        local msgType = msg.msgType
        if msgType ~= nil and msgType ~= "" then

            if msgType == "expression" then   --表情
                self:showExpression(msg)
            elseif  msgType == "text" then   --文字聊天
                self:showTextMessage(msg)
            elseif msgType == "emoji" then
                local emojiPack = {}
                emojiPack["uid"] = msg.uid
                emojiPack["type"] = msg.id
                self:SVR_MSG_FACE(emojiPack)
            elseif  msgType == "EmojiArmatureView" then   --动态表情
                self:SVR_MSG_EMOJI_ARMATURE(msg)
            end

            if device.platform == "ios" then

                if msgType == "voice" then
                    --dump("voice", "-----接收服务器返回的组局信息-----")

                    require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                    -- require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

                    -- --通知本地播放录音
                    -- local arr = {}
                    -- arr["url"] = msg.url
                    -- cct.getDateForApp("playVoice", arr, "V")

                elseif msgType == "video" then
                    --dump("video", "-----接收服务器返回的组局信息-----")

                    local arr = {}
                    arr["url"] = msg.url
                    cct.getDateForApp("playVideo", arr, "V")

                end

            else

                if msgType == "voice" then
                    --dump("voice", "-----接收服务器返回的组局信息-----")
                    require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                    -- require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

                    -- --通知本地播放录音

                    -- local data = {}
                    -- data["url"] = msg.url

                    -- local arr = {}
                    -- table.insert(arr, json.encode(data))
                    -- cct.getDateForApp("playVoice", arr, "V")

                elseif msgType == "video" then
                    --dump("video", "-----接收服务器返回的组局信息-----")

                    local data = {}
                    data["url"] = msg.url

                    local arr = {}
                    table.insert(arr, json.encode(data))
                    cct.getDateForApp("playVideo", arr, "V")

                end

            end
        end
    end

end

function PaiJiuReceiveHandle:SVR_MSG_EMOJI_ARMATURE(pack)

    local EmojiArmatureView = SCENENOW.scene:getChildByName("EmojiArmatureView")
    if not EmojiArmatureView then
        return
    end
    local from_id = pack.uid
    local to_uid = pack.to_uid
    local emojiType = pack.type
    --local from_seatId = 0
    dump(pack, '接收表情的显示------')
    if from_id and to_uid then
        local fromPos = PLAYER_HEADS_POSITION_TABLE[from_id]
        local toPos = PLAYER_HEADS_POSITION_TABLE[to_uid]
        if toPos and fromPos then
            EmojiArmatureView:showAnimi(toPos, fromPos, emojiType)
        end
    end

end

----------------------------------------外围功能---------------------------------------------------
--开奖结果 1038
function PaiJiuReceiveHandle:BROADCAST_BONUS_RESULT(pack)

    local winPlayers = ""
    for _,v in pairs(pack.bonusDict) do
        local uid = v.uid
        local nickName = v.nickName
        local portrait = v.portrait
        local bonusMoney = v.bonusMoney

        local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]

        if  playerType then
            local chip = PAIJIU_USERINFO_TABLE[uid].coins + bonusMoney
            PAIJIU_USERINFO_TABLE[uid].coins = chip
            GamePlaneOperator:setCoin(playerType,chip)
        end

        winPlayers = winPlayers .. nickName .."押中了!奖金"..bonusMoney  .. "\n"
    end

    dump(winPlayers,"winPlayers")

    if  winPlayers ~= "" then
        require("hall.GameTips"):showTips("提示", "", 3, winPlayers)
    end

    -- --清空奖池
    -- BONUS_POOL_COINS = 0
    -- Lottery:setBonusPool(BONUS_POOL_COINS)

end

--请求下注情况返回 1039
function PaiJiuReceiveHandle:SERVER_CMD_BONUS_RECORD(pack)

    local  bonus_record = pack.bonus_record

    for i,data in pairs(bonus_record) do

        local bet_uid = data.bet_uid

        if bet_uid > 0 and bet_uid ~= BANKER_UID then

            local bet_PlayerType = PAIJIU_PLAYERTYPE_TABLE[bet_uid]

            MY_BET_CHIP[bet_uid] = data.bet_count
            TOTAL_BET_CHIP[bet_uid] = data.total_bet_count

            MY_TOTAL_BET_CHIP = (MY_TOTAL_BET_CHIP or 0) + data.bet_count

            if  bet_PlayerType then
                GamePlaneOperator:setBetChip(bet_PlayerType,MY_BET_CHIP[bet_uid])
                GamePlaneOperator:setTotalBetChip(bet_PlayerType,TOTAL_BET_CHIP[bet_uid])
            end

        end

    end

    -- Lottery:showBetSituation()

end

--广播下注 1040
function PaiJiuReceiveHandle:BROADCAST_USER_BET(pack)

    local bet_uid = pack.bet_uid  --押的座位号
    local uid = pack.uid  --押注人的UID
    local costCoins = pack.costCoins

    local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]

    if  playerType then
        local chip = PAIJIU_USERINFO_TABLE[uid].coins - costCoins
        PAIJIU_USERINFO_TABLE[uid].coins = chip
        GamePlaneOperator:setCoin(playerType,chip)
    end


    local bet_PlayerType = PAIJIU_PLAYERTYPE_TABLE[bet_uid]
    -- local other_index = bet_seat_id - RELATIVE_SEAT_ID

    -- if other_index < 0 then
    --    other_index = other_index + TOTAL_PLAYERNUM
    -- end

    -- local bet_PlayerType = other_index + 1

    SINGLE_BET_CHIP[uid] = (SINGLE_BET_CHIP[uid] or 0) + math.abs(costCoins)

    if  uid == USER_INFO["uid"] then
        MY_BET_CHIP[bet_uid] = (MY_BET_CHIP[bet_uid] or 0) + math.abs(costCoins)
    end

    TOTAL_BET_CHIP[bet_uid] = (TOTAL_BET_CHIP[bet_uid] or 0) + math.abs(costCoins)

    if  bet_PlayerType then
        GamePlaneOperator:showBetEffect(bet_PlayerType,costCoins)
        GamePlaneOperator:setBetChip(bet_PlayerType,MY_BET_CHIP[bet_uid])
        GamePlaneOperator:setTotalBetChip(bet_PlayerType,TOTAL_BET_CHIP[bet_uid])
    end

    Lottery:updateBetSituation(bet_uid,math.abs(costCoins),TOTAL_BET_CHIP[bet_uid],(MY_BET_CHIP[bet_uid] or 0))

    -- BONUS_POOL_COINS = BONUS_POOL_COINS + costCoins
    -- Lottery:setBonusPool(BONUS_POOL_COINS)

end

--请求录纸返回 1035
function PaiJiuReceiveHandle:SERVER_CMD_RECORD_PAPER(pack)

    local record_paper = pack.record_paper
    Lottery:showPaper(record_paper)

end

function PaiJiuReceiveHandle:BROADCAST_BEGIN_BET(pack)
    -- 展示下注界面
    GAME_STATE = GAME_STATUS_TIMES
    GamePlaneOperator:showControlButtons(GAME_STATE)
end

-- 110E,提醒玩家做锅选择操作
function PaiJiuReceiveHandle:SVR_REMAID_QIE_GUO(pack)
    dump(pack, "--------- SVR_REMAID_QIE_GUO --------")
    --self:setGameStatus()
    --GamePlaneOperator:showInviteReadyExitBtn(2)
    is_qie = true
    qie_type = pack.qieType
    --GamePlaneOperator:showGuoChoosePanel(true, pack.qieType)
end

-- 1207,提醒下庄
function PaiJiuReceiveHandle:SVR_NOTIFY_DOWN_BANK(pack)
    dump(pack, "--------- SVR_NOTIFY_DOWN_BANK --------")
    dump(USER_INFO)
    self.b_waitQuitBank = true
    ControlPlaneOperator:showInviteReadyExitBtn(2)
    
    if pack.bankerId == USER_INFO["uid"] then
        ControlPlaneOperator:showDownBankBtn(true)
    else
        viewMgr:showTip({text = "等待庄家是否下庄"})
    end
end

-- 1208,广播下庄操作
function PaiJiuReceiveHandle:SVR_BROADCAST_DOWN_BANK_OPT(pack)
    dump(pack, "--------- SVR_BROADCAST_DOWN_BANK_OPT --------")
    self.b_waitQuitBank = false
    ControlPlaneOperator:showInviteReadyExitBtn(3)
    ControlPlaneOperator:showDownBankBtn(false)
end

function PaiJiuReceiveHandle:SVR_BROADCAST_GUO_RESULT(pack)
    dump(pack, "------------ SVR_BROADCAST_GUO_RESULT 110F-----------")
    GamePlaneOperator:stopTimer()
    local opt = pack.opt
    GamePlaneOperator:showGuoChoosePanel(false)
    if opt == 0 then
        if isGoldGame == 0 then
            GamePlaneOperator:showInviteReadyExitBtn(0)
            --GamePlaneOperator:showQieguo()
            GamePlaneOperator:moveGuo()
            BANKER_UID=0
        else
            GamePlaneOperator:showInviteReadyExitBtn(3)
        end
    elseif opt == 1 then
        if GROUP_RESULT then
            self:showResult2(GROUP_RESULT)
        end
    end
    is_doing_qie = false
    is_qie = false
end

-- 110C，广播锅底
function PaiJiuReceiveHandle:SVR_BROADCAST_GUO_DI(pack)
    dump(pack, "---------- SVR_BROADCAST_GUO_DI ------------")
    GamePlaneOperator:showGuoDi(pack.guoDiNumber)
end

-- 110D 广播开始切锅
function PaiJiuReceiveHandle:SVR_BROADCAST_START_QIE_GUO(pack)
    dump(pack, "--------- SVR_BROADCAST_START_QIE_GUO --------")
    GAME_STATE = GAME_STATUS_QIE_GUO
    is_doing_qie = true
    -- 清下注界面
    GamePlaneOperator:loadCallTimesPanel(false)
    -- 隐藏桌面按钮
    GamePlaneOperator:showInviteReadyExitBtn(2)

    -- 隐藏抢庄界面
    GamePlaneOperator:loadZhuangPanel(false)

    -- 隐藏抢庄文本
    GamePlaneOperator:clearGrabBankerSymbol()


    -- 隐藏开牌按钮
    GamePlaneOperator:showOutCardButtons(false)

    -- 隐藏提示文本
    GamePlaneOperator:showCardGroups(false)

    GamePlaneOperator:startTimer(pack.qieguoTimeOut)
    -- 隐藏准备文本，因为在轮庄和固定庄模式下，没有抢庄文本,只有准备文本

    GamePlaneOperator:clearAllReadyStatus()
    --self:setGameStatus()
    -- 移除结算界面
    --[[    if SCENENOW["scene"]:getChildByName("gameResult") then
            SCENENOW["scene"]:getChildByName("gameResult"):removeFromParent()
        end]]
end

function PaiJiuReceiveHandle:SERVER_TEST_AVAIABLE_CARDS(pack)
    dump(pack, "11111111111111111111111111111111111111111111111111111111111111111111111111111")
    dump(pack, "--------- 1FFF SERVER_TEST_AVAIABLE_CARDS")
    local count = pack.count
    local testCards = pack.testCards
    if count <= 0 or #testCards <= 0 then
        return
    end
    local introduceScene = SCENENOW["scene"]:getChildByName("testCards")
    if introduceScene then
        introduceScene:removeSelf()
    end

    GamePlaneOperator:showTestCards(testCards)

end

function PaiJiuReceiveHandle:SERVER_TEST_CARDS(pack)
    dump(pack, "---------- 2000 SERVER_TEST_CARDS")
    if pack.returnCode == 1 then
        require("hall.GameTips"):showTips("提示", "", 3, "成功")
    else
        require("hall.GameTips"):showTips("提示", "", 3, "失败")
    end

end

---------------------------------------------------------------------------------------------------

return PaiJiuReceiveHandle

--测试性能专用代码
--   local t1 = os.time();
--   for  i =1,10000000  do
--    local PaiJiuReceiveHandle = math.random(1,4)
--        self:getPlayerPlane(PaiJiuReceiveHandle)
-- end

-- local t2 = os.time();
-- print(os.difftime(t2, t1),"运行时间");