local hallHandle = require("hall.HallHandle")

local PROTOCOL = import(TpackageName .. ".handle.PaiJiuProtocol")
local ControlPlaneOperator = require(TpackageName .. ".operator.ControlPlaneOperator")

local PaiJiuReceiveHandle  = class("PaiJiuReceiveHandle", hallHandle)

local run_scene_name = TpackageName..".gameScene"

local Lottery = require(TpackageName .. ".Lottery")

local is_End = false

local is_show = false

local configTimes = 1 -- 选分次数

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

    [100] = "无效的下注",
    [101] = "无效的出牌",
    [102] = "超出下注限制",
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

        [PROTOCOL.SERVER_BROADCAST_START_GAME] = {handler(self, PaiJiuReceiveHandle.SERVER_BROADCAST_START_GAME)},

        --进入游戏成功 0210
        --[PROTOCOL.SVR_GET_ROOM_OK] = {handler(self, PaiJiuReceiveHandle.SVR_GET_ROOM_OK)},
        --登录房间成功 1007
        [PROTOCOL.SVR_LOGIN_ROOM] = {handler(self, PaiJiuReceiveHandle.SVR_LOGIN_ROOM)},
        --进入房间失败
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
        --1042 广播外围结果
        [PROTOCOL.BROADCAST_WAIWEI_RESULT] = {handler(self, PaiJiuReceiveHandle.BROADCAST_WAIWEI_RESULT)},

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
        --广播用户同意解散组局
        [PROTOCOL.SERVER_BROADCAST_AGREE_DISSOLVE_GROUP] = {handler(self, PaiJiuReceiveHandle.SERVER_BROADCAST_AGREE_DISSOLVE_GROUP)},

    	--文字聊天相关
     	--[PROTOCOL.SVR_MSG_FACE]     = {handler(self, PaiJiuReceiveHandle.SVR_MSG_FACE)},
     	--接收服务器返回的语音表情视频文字 0214
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, PaiJiuReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},
        --接收服务器返回的距离 801
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, PaiJiuReceiveHandle.SERVER_CMD_MESSAGE)},
        -- --接收IP信息 106A
        -- [PROTOCOL.BROADCAST_USER_IP] = {handler(self, PaiJiuReceiveHandle.BROADCAST_USER_IP)},
        -- [PROTOCOL.BROADCAST_BEGIN_BET] = {handler(self, PaiJiuReceiveHandle.BROADCAST_BEGIN_BET)},
        -- 1FFF
        [PROTOCOL.SERVER_TEST_AVAIABLE_CARDS] = {handler(self, PaiJiuReceiveHandle.SERVER_TEST_AVAIABLE_CARDS)},
        [PROTOCOL.SERVER_TEST_CARDS] = {handler(self, PaiJiuReceiveHandle.SERVER_TEST_CARDS)},
        --接收服务器放回的指定用户信息pack111
      -- [PROTOCOL.SERVER_CMD_HALL_GET_MESSAGE] = {handler(self, PaiJiuReceiveHandle.SERVER_CMD_HALL_GET_MESSAGE)},  

        --0x1050回看
        [PROTOCOL.SERVER_COMMAND_GAMERESULT_RECORD] = {handler(self, PaiJiuReceiveHandle.SERVER_COMMAND_GAMERESULT_RECORD)},


    }

    table.merge(self.func_, func_)

end


--协议返回数据接收
function PaiJiuReceiveHandle:callFunc(pack)
    print("revc msg --------------------------")
    dump(pack)
    if SCENENOW["name"] ~= run_scene_name then
        print("当前场景不是牌九游戏场景！")
        return
    end

	if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
	 	dump(pack.cmd,pack,"收到协议，协议号为")
        self.func_[pack.cmd][1](pack)
    end

end

--0210消息，发送进入房间消息113消息后的返回结果,
--function PaiJiuReceiveHandle:SVR_GET_ROOM_OK(pack)
--
--    dump(pack, "-----牌九210-----")
--
--    --local tid = pack.tid   --桌子ID
--    --
--    --if tid == 0 then
--    --    require("hall.GameTips"):showTips("提示", "tohall", 1, "游戏已结束")
--    --    return
--    --end
--    --
--    --USER_INFO["tid"] = tid
--    --
--    --PaiJiuSendHandle:LoginRoom(tid)
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

    local customfunc = {}
    customfunc["cancel_func"] = function() require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID) end
    customfunc["sure_func"]  = function() require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID) end

    txts["msg"] = loginErrorCode[errorCode] or "未知的错误"

    require("hall.GameTips"):showCustomTips(txts,customfunc,1)


end

--登录房间 1007
function PaiJiuReceiveHandle:SVR_LOGIN_ROOM(pack)
    require(NetworkLoadingView_filePath):removeView(888)
    dump(pack, "-----PaiJiuReceiveHandle 牌九登录房间 1007-----")
    if pack.club_id > 0 then
        CLUB_ID = pack.club_id
        USER_INFO["family_id"] = pack.club_id
    end
    is_End = false
    -- 清数据
    -- 全局常量
    SCENENOW["scene"]:initData("clearGameData")
    -- 玩家头像：庄，输赢合（目前没做）
    --GamePlaneOperator:clearGameDatas(2)
    -- 按钮：开牌按钮，提示按钮（目前没做），邀请好友文本根据房卡和金币场显示，

    -- 游戏公共部分：
    USER_INFO["activity_id"] = pack.activityId

    -- 邀请码：
    USER_INFO["invote_code"] = pack.inviteCode

    PAJIU_ACTIVITY_ID = pack.activityId
    dump(PAJIU_ACTIVITY_ID, "--------- SVR_LOGIN_ROOM__PAJIU_ACTIVITY_ID ----------")

    HEART_BEAT_TID = USER_INFO["tid"]
    dump(HEART_BEAT_TID, "1007心跳tid")

    -- 确定游戏类型
    if pack.gameMode == 1 then
        GAME_MODE = "小牌九"
    elseif  pack.gameMode == 2 then
        GAME_MODE = "大牌九"
    end

    --[[    GAME_CONFIG[GAME_MODE] = true]]

    -- 0金币场还是1房卡
    isGoldGame = pack.isGoldGame
    -- 游戏配置信息
    FENCHANG=pack.fenchang
    local gameConfig = pack.gameConfig
    local str_config = " "
    local gameModeName=""
    local baseScore=""
    local fanbeiRule=""
    local roomRule=""
    local specialRule=""
    --通过接口传来的字符串获取具体配置信息
    if type(gameConfig) =="string" then
        local gameConfigTable = json.decode(gameConfig)
        local lst = string.split(gameConfigTable.times, ',')
        configTimes = #lst
        dump(gameConfigTable, "------游戏配置信息------")
        --dump(type(gameConfigTable), "----- type_of_gameConfig")
        -- 0抢庄，2轮庄，1霸王庄
        -- 处理配置
        -- 几道注：2：2道，3：3道
        SCENENOW["scene"]:setLimitBetTotal(gameConfigTable["limitBetCount"])
        for k, v in pairs(gameConfigTable) do
            if k == "paigowGroupCount" then
                if v == 1 then
                    --GAME_CONFIG["小牌九"] = true
                    str_config  = str_config .. "小牌九 "
                    gameModeName="小牌九"
                elseif v == 2 then
                    --GAME_CONFIG["大牌九"] = true
                    str_config  = str_config .. "大牌九 "
                    gameModeName="大牌九"
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
            elseif k == "gameType" then
                if v == 0 then
                    --GAME_CONFIG["抢庄"] = true
                    str_config  = str_config .. "抢庄 "
                    specialRule="抢庄 "
                elseif v == 1 then
                    --GAME_CONFIG["轮庄"] = true
                    str_config  = str_config .. "霸王庄 "
                    specialRule="霸王庄 "
                elseif v == 2 then
                    --GAME_CONFIG["霸王庄"] = true
                    str_config  = str_config .. "轮庄 "
                    specialRule="轮庄 "
                end
            elseif k == "speType" then
                local str_type_config = string.split(v, ",")
                dump(str_type_config, "-- 切分的配置信息 --")
                for _, x in ipairs(str_type_config) do
                    x = tonumber(x)
                    if x == 1 then
                        str_config  = str_config .. "炸弹 "
                        roomRule=roomRule.. "炸弹 "
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
            elseif k == "times" then
                if v == "2" then
                    str_config  = str_config .. "固定2分 "
                    baseScore="固定2分 "
                    BASE_CHIP="2"
                elseif v == "5" then
                    str_config  = str_config .. "固定5分 "
                    baseScore="固定5分 "
                    BASE_CHIP="5"
                elseif v == "8" then
                    str_config  = str_config .. "固定8分 "
                    baseScore="固定8分 "
                    BASE_CHIP="8"
                elseif v == "10" then
                    str_config  = str_config .. "固定10分 "
                    baseScore="固定10分 "
                    BASE_CHIP="10"
                else
                    str_config  = str_config .. "每次选分 "
                    baseScore="每次选分 "
                    BASE_CHIP="0"
                end
            end
        end
    end
    --dump(GAME_CONFIG, "---- GAME_CONFIG ----")
    dump(str_config, "----获取到的游戏配置-----")

    local gamemsg={
              {["玩法"] = gameModeName, ["分场"] = FENCHANG},
              {["道的选择"] = fanbeiRule},
              {["牌型"] = roomRule},
              {["庄的选择"] = specialRule},
              {["选分"] = baseScore},
            }

    -- 显示邀请码和组局配置信息
    SCENENOW["scene"]:updateRoomInfo(nil, nil, USER_INFO["invote_code"], nil, nil, gamemsg)

    PJ_TOTAL_CARD_COUNT = pack.totalCardsCount
    PJ_HANDCARD_COUNT = pack.gameMode * 2

    CARDCOUNT=pack.gameMode


    initialChip = pack.initChip

    if  isGoldGame == 0 then
        initialChip = 0
    end

    -- 游戏状态
    GAME_STATE = pack.gameStatus

    SHAIZI_SEATID = 0 --摇完骰子第一个发牌的用户
    -- 庄家座位
    BANKER_UID = pack.bankerId
    TIMES_SIZE = pack.timesSize
    TIMES_ARRAY = pack.timesArray

    -- 闲家加倍,初始化
    GamePlaneOperator:initCallTimesPanel()

    -- 牌堆相关
    local poolCardsShowCount = pack.poolCardsShowCount
    local remainCardsCount = pack.remainCardsCount
    -- 显示牌堆
    local shaiZiNumber = pack.shaiZiNumber

    GamePlaneOperator:showPoolCards(pack.showCardsArray)

    -- 清空3个按钮
    --GamePlaneOperator:showInviteReadyExitBtn(2)

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
    if GAME_STATE >= GAME_STATUS_OUT_CARDS then
        local cardCount = pack.gameMode * 2
        local cardsTemp = {}
        for i=1,cardCount do
            table.insert(cardsTemp, 0)
        end

    end

    if sitDownUserCount > 0 then
        -- 已经有玩家坐下，先画头像信息
        for _, user_info in pairs(pack.usersInfo) do
            -- 桌面上绘制玩家的界面
            --dump(RELATIVE_SEAT_ID, "-- 桌面上绘制玩家的界面")
            self:collectPlayerData(user_info)

            if user_info.isReady == 1 then
                -- 加入准备列表
                USERS_READY_STATE[user_info.uid] = 1
            end
            if GAME_STATE > GAME_STATUS_GRAB_BANKER and user_info.uid ~= BANKER_UID and USERS_READY_STATE[uid] == 1 then
                local playerType = PAIJIU_PLAYERTYPE_TABLE[user_info.uid]
                local dao_count = user_info.daoCount
                local daoArray = user_info.daoArray
                for i=1, dao_count do
                    GamePlaneOperator:setDao(playerType, i, daoArray[i],PLAYER_HEADS_POSITION_TABLE[user_info.uid])
                end
                GamePlaneOperator:showPlayerDaoPanel(playerType, true)
            end
        end

        for _, user_info in pairs(pack.usersInfo) do

            local uid = user_info.uid
            local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]

            if uid == USER_INFO["uid"] then
                --todo
                PJ_HANDCARDS = user_info.handCardsArray
                PJ_AVAI_CARD_GROUPS = user_info.cardCoombinationArrayBeforeSure
            end
            -- 断线
            if user_info.isOnline == 0 then
                GamePlaneOperator:showHeadSymbol(playerType, "disconnect", true)
            end
            -- 根据游戏状态，在桌面展示更多信息
            if GAME_STATE == GAME_STATUS_STOP then
                if user_info.isReady == 1 then
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
                        dump("---我没准备---")
                        if isGoldGame == 0 then
                            GamePlaneOperator:showInviteBtnText(2)
                            GamePlaneOperator:showInviteReadyExitBtn(0)
                        else
                            -- GamePlaneOperator:showInviteBtnText(0)
                            dump("---房卡场-----")
                            GamePlaneOperator:showInviteBtnText(0)
                            if GAME_ROUND == 0 then
                                GamePlaneOperator:showInviteReadyExitBtn(0)
                                dump("显示3个图标")
                            else
                                GamePlaneOperator:showInviteReadyExitBtn(3)
                                dump("显示一个准备图标")
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
                if BANKER_UID == uid then
                    -- 显示倒计时

                else
                    local dao_count = 1--user_info.daoCount
                    local daoArray = user_info.daoArray
                    if uid == USER_INFO["uid"] then
                        CALL_TIMES_COUNT = dao_count + 1
                        --if user_info.feedback == -1 and CALL_TIMES_COUNT <= DAO_COUNT  then
                            -- 自己还没下注或者没下完注
                            --GamePlaneOperator:loadCallTimesPanel(true, user_info.canCallTimesCount, user_info.canCallTimesArray)
                        --end
                    end
                    local countFen = 0
                    for i,v in ipairs(daoArray) do
                        countFen = countFen + v
                    end
                    print("daoArray --------------------")
                    dump(daoArray)
                    for i=1, dao_count do
                        GamePlaneOperator:setDao(playerType, i, daoArray[i],PLAYER_HEADS_POSITION_TABLE[uid], countFen)
                    end
                    GamePlaneOperator:setBetTimes(playerType,true,countFen)
                end
            elseif GAME_STATE == GAME_STATUS_OUT_CARDS then
                local cardsTemp = user_info.handCardsArray
                if uid == USER_INFO["uid"] then
                    if user_info.feedback == -1 then
                        -- 开牌按钮
                        GamePlaneOperator:showOutCardButtons(true)
                        --IS_SURE_OPEN = false
                    else
                        cardsTemp = user_info.cardCombinationArrayAfterSure
                        -- GamePlaneOperator:showCards(playerType, user_info.handCardsArray)
                        -- GamePlaneOperator:openCards(playerType, cardsTemp)

                        -- GamePlaneOperator:showAni4Big(playerType, user_info.cardCombinationArrayAfterSure)
                        table.insert(cardsTemp, 0)
                        table.insert(cardsTemp, 0)

                        -- 开牌按钮
                        GamePlaneOperator:showOutCardButtons(false)
                        -- 隐藏牌类型提示
                        GamePlaneOperator:showCardGroups(false)
                        --IS_SURE_OPEN = true
                        PJ_SURE_OPEN_CARD[playerType] = 1
                    end
                else
                    local cardCount = pack.gameMode * 2
                    for i=1,cardCount do
                        table.insert(cardsTemp, 0)
                    end
                end
                 -- 其他玩家没有选择开牌
                if user_info.feedback == -1 then
                    GamePlaneOperator:showCards(playerType, cardsTemp)
                else
                    GamePlaneOperator:openCards(playerType, cardsTemp)
                    PJ_SURE_OPEN_CARD[playerType] = 1
                end

                local flg = true
                if BANKER_UID == uid then
                    flg = false
                end
                local countFen = 0
                for i,score in ipairs(user_info.daoArray) do
                    countFen = countFen + score
                end
                GamePlaneOperator:setBetTimes(playerType,flg,countFen)
            end

           
        end
    end

 

    if GAME_STATE > GAME_STATUS_GRAB_BANKER  and BANKER_UID > 0 then
        GamePlaneOperator:showHeadSymbol(PAIJIU_PLAYERTYPE_TABLE[BANKER_UID], "banker", true)
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
        self:SVR_OUT_CARD_BROADCAST(result)
    end

    if GAME_STATE == GAME_STATUS_SEND_CARDS then
        --发牌阶段，播放筛子动画
        local data = {}
        data.data = pack.shaiZiNumber
        data.shaiZiArray = pack.shaiZiArray
        data.shaiZiTimeOut = pack.shaiZiTimeOut
        data.seatId= pack.seatId

        GamePlaneOperator:showShiziAnimotion(data)
    elseif GAME_STATE > GAME_STATUS_SEND_CARDS then
        GamePlaneOperator:showRemainCards(pack.remainCardsCount)
    end


    if PLAYERNUM == TOTAL_PLAYERNUM and isGoldGame == 0 then
        if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] == nil then
            GamePlaneOperator:showInviteReadyExitBtn(4)
           
        end
    end
    --[[    if GAME_STATE > GAME_STATUS_STOP then
            GamePlaneOperator:showInviteReadyExitBtn(2)
        end]]
end

--------------------------------------------------------------------------------------------------
--整理用户数据
function PaiJiuReceiveHandle:collectPlayerData(data)

    dump(data.uid, "整理玩家信息数据")

    local gold = data.gold

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

    userInfo["score"] = 0     --用户本局游戏的胜负

    userInfo["latitude"] = data.latitude or ""

    userInfo["longitude"] = data.longitude or ""
    -- 城市
    local otherInfo = json.decode(data.otherInfoJson)
   
    userInfo["city"] = otherInfo.city

    userInfo["daoCount"] = data.daoCount or ""

    userInfo["daoArray"] = data.daoArray or ""

    local uid = data.uid
    PAIJIU_USERINFO_TABLE[uid] = userInfo
    PAIJIU_SEAT_TABLE[uid] = data.seatId --保存用户座位与id映射
    --[[
        if GROUP_MODE == 2  then
            require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,  {ip = userInfo["ip"]}, "ip")
        elseif GROUP_MODE == 1 then
            require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,  userInfo)
        end
    ]]


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
    if GAME_STATE < GAME_STATUS_GRAB_BANKER then
        GamePlaneOperator:showIpCheck(true)
    end

    if uid == USER_INFO["uid"] then
        USER_INFO["gold"] = userInfo.coins/100  
    end
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
    -- local   worldpoint = (head:getParent()):convertToWorldSpace(head:getPosition()) --这样写是为了贴近函数的原始用法

    local planeItem_world_pos = (head:getParent()):convertToWorldSpace(head:getPosition())
    local worldpoint = PAIJIU_GAME_SCENE:convertToNodeSpace(planeItem_world_pos)

    PLAYER_HEADS_TABLE[uid] = head
    PLAYER_HEADS_POSITION_TABLE[uid] = planeItem_world_pos

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

    PLAYERNUM = self:getPlayerNum()
end

--重新显示游戏桌面（坐下之后）
function PaiJiuReceiveHandle:relocatePlayer()

    -- GamePlaneOperator:init("player")
    GamePlaneOperator:relocate("player")
    if old_seat == RELATIVE_SEAT_ID or GAME_STATE == GAME_STATUS_STOP then
        old_seat=RELATIVE_SEAT_ID
        for uid, seat_id in pairs(PAIJIU_SEAT_TABLE) do
            if seat_id >= 0 then
                local user_info =  PAIJIU_USERINFO_TABLE[uid]
                self:showPlayer(uid,seat_id, user_info)
            end
            if GAME_STATE == GAME_STATUS_STOP then
                if PAIJIU_PLAYERTYPE_TABLE[uid] then
                    GamePlaneOperator:setReadyStatus(PAIJIU_PLAYERTYPE_TABLE[uid], false)
                end
                if USERS_READY_STATE[uid]==1 then
                    GamePlaneOperator:setReadyStatus(PAIJIU_PLAYERTYPE_TABLE[uid], true)
                end
            end
        end
    else
        old_seat=RELATIVE_SEAT_ID
        GamePlaneOperator:clearGameDatas(2)
        for i = 1,TOTAL_PLAYERNUM do
            GamePlaneOperator:deletechip(i,0)
            GamePlaneOperator:showPlayerDaoPanel(i, false)
        end
        for uid, seat_id in pairs(PAIJIU_SEAT_TABLE) do
            GamePlaneOperator:showHeadSymbol(PAIJIU_PLAYERTYPE_TABLE[uid], "banker", false)
            local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]

            if seat_id >= 0 then
                local user_info =  PAIJIU_USERINFO_TABLE[uid]
                self:showPlayer(uid,seat_id, user_info)
                if BANKER_UID>0 then
                    GamePlaneOperator:showHeadSymbol(PAIJIU_PLAYERTYPE_TABLE[BANKER_UID], "banker", true)
                end
                if GAME_STATE >= GAME_STATUS_GRAB_BANKER then
                    GamePlaneOperator:showInviteReadyExitBtn(4,true)
                    if GAME_STATE == GAME_STATUS_GRAB_BANKER then
                        if BANKER_UID < 0 then
                            if user_info.feedback == -1 and uid == USER_INFO["uid"] then
                                --GamePlaneOperator:loadZhuangPanel( true)
                            elseif user_info.feedback == 0 then
                                GamePlaneOperator:showZhuangAttitude(PAIJIU_PLAYERTYPE_TABLE[uid], 2)
                            elseif user_info.feedback == 1 then
                                GamePlaneOperator:showZhuangAttitude(PAIJIU_PLAYERTYPE_TABLE[uid], 1)
                            end
                        end
                    end
                    if GAME_STATE >= GAME_STATUS_CALL_TIMES then
                        if uid ~= BANKER_UID then
                            local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
                            local dao_count = 1--user_info.daoCount
                            local daoArray = user_info.daoArray
                            dump(daoArray, "daoArray ----------------")
                            local countValue = 0
                            if dao_count ~= "" and daoArray ~= "" and daoArray~=nil and dao_count ~= nil then
                                for i,v in ipairs(daoArray) do
                                    countValue = countValue + v
                                end
                                for i=1, dao_count do
                                    if daoArray[i]~=nil and daoArray[i]~="" then
                                        GamePlaneOperator:setDao(playerType, i, daoArray[i],PLAYER_HEADS_POSITION_TABLE[uid], countValue)
                                    end
                                end
                            end
                            if USERS_READY_STATE[uid]==1 then
                                GamePlaneOperator:showPlayerDaoPanel(playerType, true)
                            end
                        end
                    end

                    if GAME_STATE == GAME_STATUS_OUT_CARDS then
                        local cardCount = CARDCOUNT * 2

                        local cardsTemp = {}
                        for i=1,cardCount do
                            table.insert(cardsTemp, 0)
                        end
                        -- 其他玩家没有选择开牌
                        if PJ_SURE_OPEN_CARD[uid] ~= 1 then
                            GamePlaneOperator:showCards(PAIJIU_PLAYERTYPE_TABLE[uid], cardsTemp)
                        else
                            GamePlaneOperator:openCards(PAIJIU_PLAYERTYPE_TABLE[uid], cardsTemp)
                        end
                    end
                    
                    if GAME_STATE == GAME_STATUS_OPEN_CARDS then
                        if PAIJIU_RESULTINFO then
                            self:SVR_OUT_CARD_BROADCAST(PAIJIU_RESULTINFO,1)
                        end
                    end
                    --if GAME_STATE == GAME_STATUS_SEND_CARDS then
                        --发牌阶段，播放筛子动画
                    --    GamePlaneOperator:showShiziAnimotion(pack.shaiZiNumber, pack.shaiZiArray, pack.shaiZiTimeOut)
                    -- end

                end
            end
        end
    end
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
    dump("广播自己退出")
    --[[    if  GROUP_MODE == 2 then
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
        end--]]
    if not is_End then
        --SCENENOW["scene"]:reConnect()
        require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
    end
    -- require("hall.ScoketGame"):showReloginTip()
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
        RELATIVE_SEAT_ID = MY_SEAT_ID
        --游戏过程中会不会重定位
        self:relocatePlayer()
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
                    if  GAME_STATE == GAME_STATUS_STOP then
                        MY_SEAT_ID = 0
                        RELATIVE_SEAT_ID = MY_SEAT_ID
                        self:relocatePlayer()
                    end
            else
                if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] == nil then
                    GamePlaneOperator:showInviteBtnText(1)
                    GamePlaneOperator:showInviteReadyExitBtn(1)
                end
            end
        end
    end


end

--广播玩家退出返回（离开房间） 1033
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

end


--1041 广播下注剩余时间
function PaiJiuReceiveHandle:BROADCAST_SENDCARD_REMAINDTIME(pack)
    GamePlaneOperator:startTimer(pack.time,"下注阶段")
end


--1042 广播外围结果
function PaiJiuReceiveHandle:BROADCAST_WAIWEI_RESULT(pack)

    CHECK_WAIWEI_RESULT_ABLE = true

    SCENENOW["scene"]:performWithDelay(function()

        local hall_panel = PAIJIU_GAME_SCENE:getParent():getChildByName("hall_panel")
        local btn_switch_bet_mode = hall_panel:getChildByName("btn_switch_bet_mode")

        local anyOneWin = false

        local tbWin = {}
        local oriChipTable = {}

        for i,v in pairs(pack.waiwei_result) do

            local uid = v.uid
            local score = v.score

            oriChipTable[uid] = PAIJIU_USERINFO_TABLE[uid].coins

            PAIJIU_USERINFO_TABLE[uid].coins = PAIJIU_USERINFO_TABLE[uid].coins + score

            tbWin[uid] = score


            -- if uid ~= BANKER_UID then

            --     local nickName = v.nickName
            --     local portrait = v.portrait

            --     local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]

            --     local pos = PLAYER_HEADS_POSITION_TABLE[uid]
            --     local finalPos = PLAYER_HEADS_POSITION_TABLE[BANKER_UID]

            --     dump(finalPos,"finalPos")
            --     dump(pos,"pos")

            --     if  pos and finalPos then
            --         if  score < 0 then
            --             SCENENOW["scene"]:performWithDelay(function()
            --                 GamePlaneOperator:waiWeiCoinFly(playerType,pos,score,PAIJIU_USERINFO_TABLE[uid].coins,finalPos)
            --             end,2)
            --         elseif score > 0 then
            --             anyOneWin = true
            --             SCENENOW["scene"]:performWithDelay(function()
            --                 GamePlaneOperator:waiWeiCoinFly(playerType,pos,score,PAIJIU_USERINFO_TABLE[uid].coins,finalPos)
            --             end,3)
            --         end
            --     end

            -- else

            --     if score ~= 0 then
            --         SCENENOW["scene"]:performWithDelay(function()
            --             local BankerPlayerType = PAIJIU_PLAYERTYPE_TABLE[uid]
            --         end,4)
            --     end

            -- end

        end

        if  next(tbWin) then

            GamePlaneOperator:showCoinFlyAnimation(BANKER_UID,tbWin,oriChipTable,"bet")

            --     self:showWaiWeiResult(pack.waiwei_result)

            --     local bottom_img = btn_switch_bet_mode:getChildByName("bottom_img")

            --     bottom_img:setColor(cc.c3b(255,255,255))

            --     btn_switch_bet_mode:runAction(
            --     cc.Sequence:create(
            --         cc.Spawn:create(
            --             cc.MoveTo:create(1,cc.p(DESIGN_SCREEN_WIDTH/2,DESIGN_SCREEN_HEIGHT/2 -50) ),
            --             cc.ScaleTo:create(1,2)
            --             ),
            --         cc.DelayTime:create(0.7),
            --         cc.CallFunc:create(function()
            --             bottom_img:loadTexture(TpackageName .. "/images/jubaopen_0.png")
            --             bottom_img:setContentSize(cc.size(110,171))
            --             end),
            --         cc.DelayTime:create(1.3),
            --         cc.CallFunc:create(function()
            --             bottom_img:loadTexture(TpackageName .. "/images/jubaopen_1.png")
            --             bottom_img:setContentSize(cc.size(110,102))
            --             end)
            --         )
            --     )


            --     local goBackToNormal = function()
            --         btn_switch_bet_mode:setPosition(cc.p(96,110))
            --         btn_switch_bet_mode:setScale(1)
            --     end

            --     SCENENOW["scene"]:performWithDelay(function()
            --         goBackToNormal()
            --     end,5)

        end

    end,3)

end

--1042
function PaiJiuReceiveHandle:showWaiWeiResult(data)

    dump(data,"showWaiWeiResult")

    -- 界面测试代码
    --     local data = {
    --     {score = 35, nickName = "用户820104",uid = 10001},
    --     {score = 35, nickName = "用户820104",uid = 10001},
    --    { score = 35, nickName = "用户820104",uid = 10001},
    --    { score = 35, nickName = "用户820104",uid = 10001},
    --    { score = 35, nickName = "用户820104",uid = 10001},
    --    { score = 35, nickName = "用户820104",uid = 10001},
    --    { score = 35, nickName = "用户820104",uid = 10001},
    --   {  score = 35, nickName = "用户820104",uid = 10001},
    --   {  score = 35, nickName = "用户820104",uid = 10001},
    --   {  score = 35, nickName = "用户820104",uid = 10001},
    --   {  score = 35, nickName = "用户820104",uid = 10001},
    --   {  score = 35, nickName = "用户820104",uid = 10001},
    --   {  score = 35, nickName = "用户820104",uid = 10001},
    --  {   score = 35, nickName = "用户820104",uid = 10001},
    --   {  score = 35, nickName = "用户820104",uid = 10001},
    --   {  score = 35, nickName = "用户820104",uid = 10001},
    --    { score = 35, nickName = "用户820104",uid = 10001},
    --    {  score = 35, nickName = "用户820104",uid = 10001},
    --     {score = 35, nickName = "用户820104",uid = 10001},
    --     {score = 35, nickName = "用户820104",uid = 10001},
    --     {score = 35, nickName = "用户820104",uid = 10001},
    --     {score = 35, nickName = "用户820104",uid = 10001},
    --     {score = -35, nickName = "用户820104",uid = 10002}
    -- }

    --     local news = json.encode(data)
    --     local newfile = io.open("D:/work/hellouniverse/gameClient/trunk/niuniu/gameConfig1.txt","w")
    --     dump(news,"showWaiWeiResult")
    --     newfile:write(news)
    --     newfile:close()
    -- local hall_panel = PAIJIU_GAME_SCENE:getParent():getChildByName("hall_panel")
    -- local btn_switch_bet_mode = hall_panel:getChildByName("btn_switch_bet_mode")
    -- local btn_checkoutZ = btn_switch_bet_mode:getPositionZ()

    --获取总结算界面
    local s = PAIJIU_GAME_SCENE:getParent():getChildByName("waiwei_panel")

    -- local s = SCENENOW["scene"]:getChildByName("WaiWeiResult")
    if  not s then
        return
        -- s = cc.CSLoader:createNode(TpackageName .. "/csb/lotteryResult.csb"):addTo(SCENENOW["scene"])
    end

    -- s:setPositionZ(btn_checkoutZ - 1)
    -- s:setName("WaiWeiResult")
    -- s:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
    s:setVisible(false)

    local title = s:getChildByName("title")
    title:setString("投注结算")
    local mask = s:getChildByName("mask")
    mask:addTouchEventListener(function(sender,event)

        if  event == TOUCH_EVENT_ENDED then
            s:setVisible(false)
        end

    end)

    --结果显示区域
    local content_sv = s:getChildByName("content_sv")
    local content_ly = content_sv:getChildByName("content_ly")

    --定义结果分项
    local result_Item = s:getChildByName("group_ending_box")

    local result_Item_position_index = 1

    local playerNum = table.nums(data)

    local lineCount = math.ceil(playerNum/3)

    local contentHeight = content_sv:getInnerContainerSize().height
    local contentWidth = content_sv:getInnerContainerSize().width

    if contentHeight < 160 * lineCount then  contentHeight = 160 * lineCount end

    content_sv:setInnerContainerSize(cc.size(contentWidth,contentHeight))
    content_ly:setContentSize(cc.size(contentWidth,contentHeight))
    content_ly:setPositionY(contentHeight)
    content_ly:removeAllChildren()
    -- dump(contentHeight,"content_lycontentHeight")
    -- dump(content_ly:getPosition(),"content_ly位置")

    local my_bet_chip = s:getChildByName("my_bet_chip")
    my_bet_chip:setString("我的下注:0")
    local total_bet_chip = s:getChildByName("total_bet_chip")
    total_bet_chip:setString("我的输赢:0")

    local positionIndex = 0
    --生成界面
    for k,v in pairs(data) do
        ------------------------------------------数据-----------------------------------
        local sex= 1
        local uid = v.uid
        local nickName = v.nickName
        local photo_url = v.portrait
        local score = v.score
        -------------------------------------------界面-------------------------------------------
        if  uid == USER_INFO["uid"] then
            my_bet_chip:setString("我的下注:" .. (my_bet_chip[uid] or 0))
            total_bet_chip:setString("我的输赢:" .. score)
        end

        positionIndex = positionIndex + 1
        local result_Item = result_Item:clone()
        content_ly:addChild(result_Item)

        local x = contentWidth / 2 - (2 - math.ceil(positionIndex % 3.01)) * 400
        local y = contentHeight - (math.ceil(positionIndex/3.01) - 1) * 155

        result_Item:setPosition(cc.p(x,y))

        --用户头像
        local head_im = result_Item:getChildByName("head_im")
        require("hall.GameCommon"):getUserHead(photo_url, uid, sex, head_im, head_im:getContentSize().width, false, nickName)

        --用户昵称
        local nickName_txt = result_Item:getChildByName("nickName_txt")

        local total_bet_chip = result_Item:getChildByName("total_bet_chip")
        total_bet_chip:setString("输赢：" .. score)
        local bet_chip_txt = result_Item:getChildByName("bet_chip")
        bet_chip_txt:setString("下注：" .. (SINGLE_BET_CHIP[uid] or 0) )

        local namenick = require("hall.GameCommon"):formatNick(nickName, 7)
        nickName_txt:setString(namenick)

    end

end

function PaiJiuReceiveHandle:SVR_USER_CALL_TIMES_BROADCAST(pack)
    dump(pack, "------- 广播用户加倍 1101--------")

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

    local uid = pack.uid
    local sureDaoCount = pack.sureDaoCount
    local sureDaoArray = pack.sureDaoArray
    PAIJIU_USERINFO_TABLE[uid]["daoCount"]=sureDaoCount or ""
    PAIJIU_USERINFO_TABLE[uid]["daoArray"]=sureDaoArray or ""
    local canCallTimesCount = pack.canCallTimesCount
    local canCallTimesArray = pack.canCallTimesArray
    if sureDaoCount <= 0 then
        dump(daoCount, "------- 广播用户加倍 1101---- daoCount： ----")
        return
    end
    local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]

    -- 自己下注
    if uid == USER_INFO["uid"] then
        -- 显示接下来下注的界面
        if canCallTimesCount > 0 then
            CALL_TIMES_COUNT = CALL_TIMES_COUNT + 1
            --GamePlaneOperator:loadCallTimesPanel(true, canCallTimesCount, canCallTimesArray)
        end

    end

    local countFen = 0
    for i,score in ipairs(sureDaoArray) do
        countFen = countFen + score
    end
    local playerType = PAIJIU_PLAYERTYPE_TABLE[pack.uid]
    GamePlaneOperator:setBetTimes(playerType,true,countFen)

end


-- 110A 广播用户出牌
function PaiJiuReceiveHandle:SVR_OUT_CARD_BROADCAST(pack,state)
    dump(pack, "-------- 广播用户出牌 110A ---------" )
    -- local openCardAniTimeOut = pack.openCardAniTimeOut
    -- local playerCount = pack.playerCount
    dump(pack.resultInfo, "SVR_OUT_CARD_BROADCAST_resultInfo")
    print("out card-------------------------------")
    dump(pack.resultInfo.cardCombinationArrayAfterSure)
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
    -- 开牌动画时间
    local openCardAniTimeOut = pack.openCardAniTimeOut

    local resultInfo = pack.resultInfo
    if not state then
        PAIJIU_RESULTINFO=pack
    end
    -------------------标签4---------------------------------
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

    local seqAc = cc.Sequence:create(cc.DelayTime:create(0.8), cc.CallFunc:create(function()
        GamePlaneOperator:showOpenAllCardsAni(firstAction, secondAction)
    end))

    SCENENOW["scene"]:runAction(cc.RepeatForever:create(seqAc))
end


--5001
function PaiJiuReceiveHandle:BROADCAST_ERROR_TIPS(pack)

    dump(pack, "-----返回错误提示5001-----")

    local errorCode = pack.errorCode

    if tbErrorCode[errorCode] then
        require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[errorCode])
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
    print("test -------------------------------")
    dump(pack)
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

--准备相关
--广播用户可以准备了
function PaiJiuReceiveHandle:SVR_READY_TIME(pack)

    dump(pack, "------广播用户可以准备了6009------")

    GAME_STATE = GAME_STATUS_STOP      --准备阶段

end

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
        GamePlaneOperator:clearGameDatas(2)
        ControlPlaneOperator:showRedBtn(false)
        -- GamePlaneOperator:setReadyStatus(playerType, false)
    end
    -- 显示准备文本
    if  playerType then
        GamePlaneOperator:setReadyStatus(playerType,true)
    end

end

----------------------------------------------------------------------------------------
--所有人都已准备，广播可以开始游戏
function PaiJiuReceiveHandle:SERVER_COMMAND_REMAID_START_GAME()
    GamePlaneOperator:RemaidStartGame(true)
end

--有人未准备，隐藏开始游戏按钮
function PaiJiuReceiveHandle:SERVER_COMMAND_REMAID_START_GAME_FAIL()

    GamePlaneOperator:RemaidStartGame(false)

end


--广播游戏开始 6002
function PaiJiuReceiveHandle:SVR_BROADCAST_GAME_START(pack)
    -----------------------------游戏开始-------------------------------

    SCENENOW["scene"]:showShareButton(false)
    SCENENOW["scene"]:showDisbandButton(false)

    --游戏开始后清除准备状态
    GamePlaneOperator:clearAllReadyStatus()
    GamePlaneOperator:showStartAnimation()

    GAME_PARTICIPANTS = {}

    for uid,ready_state in pairs(USERS_READY_STATE) do
        if  ready_state == 1 then
            table.insert(GAME_PARTICIPANTS,uid)
        end
    end
    -----------------------------------
    local cardEndIndex = pack.send_card_num or 4

    for _,uid in pairs(GAME_PARTICIPANTS) do

        local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
        dump(playerType,"6002_playerType")
        if  playerType and uid ~= USER_INFO["uid"] and cardEndIndex > 0 then
            -- local seat_id =  PAIJIU_SEAT_TABLE[uid]
            -- local cards = userCards[seat_id]  --控制
            GamePlaneOperator:showDealCardsAnimation(playerType,nil,cardEndIndex)
            -- Lottery:drawSmallCards(uid)
        end

    end
    --------------------------------------------------------------------
end

---------------------------------------------------------------------------------------------------------------------------------------------
--庄家相关
--广播开始抢庄（游戏开始，第一阶段）1103
function PaiJiuReceiveHandle:SVR_BEGIN_QIANFGZHUANG_BROADCAST(pack)

    dump(pack,"-----广播开始抢庄1103-----")

    -- 抢庄阶段
    GAME_STATE = GAME_STATUS_GRAB_BANKER

    -- 清除桌面准备文本
    GamePlaneOperator:clearAllReadyStatus()

    if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] ~= nil then
        -- 自己坐下，隐藏桌面按钮
        GamePlaneOperator:showInviteReadyExitBtn(2)
    else
        -- 自己围观、只显示退出房间按钮
        GamePlaneOperator:showInviteReadyExitBtn(4)
    end

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
    local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
    local  player_attitude = 1
    PAIJIU_USERINFO_TABLE[uid]["feedback"]=1
    if pack.if_qiang == 0 then
        player_attitude = 2
        PAIJIU_USERINFO_TABLE[uid]["feedback"]=0
    end

    -- 清除桌面准备文本
    GamePlaneOperator:clearAllReadyStatus()

    if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] ~= nil then
        -- 自己坐下，隐藏桌面按钮
        GamePlaneOperator:showInviteReadyExitBtn(2)
    else
        -- 自己围观、只显示退出房间按钮
        GamePlaneOperator:showInviteReadyExitBtn(4)
    end

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
    if #grabBankerArray ~= grabBankerCount then
        dump("抢庄人数和抢庄人数组不匹配")
        return
    end

    BANKER_UID = pack.bankerId
    --local BankerPlayerType = PAIJIU_PLAYERTYPE_TABLE[BANKER_UID]

    GamePlaneOperator:stopTimer()


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

    -- 抢庄动画
    GamePlaneOperator:showGrabBankerAnim(grabBankerCount, grabBankerArray, grabBankerTimeOut)
    --显示庄
    --local BankerPlayerType = PAIJIU_PLAYERTYPE_TABLE[BANKER_UID]

end
---------------------------------------------------------------------------------------------------------------------------------------------
--倍数相关
--处理加倍
function PaiJiuReceiveHandle:BROADCAST_BEGIN_CALL_TIMES(pack)

    dump(pack, "----广播玩家开始加倍1105-----")

    GAME_STATE = GAME_STATUS_CALL_TIMES

    -- 隐藏IP检测
    GamePlaneOperator:showIpCheck(false)

    -- 显示加倍倒计时
    GamePlaneOperator:startTimer(pack.callTimesTimtOut)

    for uid, _ in pairs(PAIJIU_SEAT_TABLE) do
        local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
        if playerType and USERS_READY_STATE[uid]==1 then
            if uid == BANKER_UID then
                GamePlaneOperator:showPlayerDaoPanel(playerType, false)
            else
                GamePlaneOperator:showPlayerDaoPanel(playerType, true)
                if configTimes > 1 then
                    --------------标签99-------------------------------
                    GamePlaneOperator:startTimer(10 or pack.callTimesTimtOut)
                end
            end
        end
    end
end

function PaiJiuReceiveHandle:SVT_PLAYER_CALL_TIMES(pack)
    dump(pack, "---------- 通知玩家加倍 1106 ------")

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

    -- 显示下注倒计时

    local timesCount = pack.timesCount
    local timesFenArray = pack.timesFenArray
    -- 确定是第几道加倍
    CALL_TIMES_COUNT = CALL_TIMES_COUNT + 1
   
    GamePlaneOperator:loadCallTimesPanel(true, timesCount, timesFenArray)
end

function PaiJiuReceiveHandle:SVR_SHAIZI_BROADCAST(pack)
    dump(pack, "---------- 广播骰子数 1107 ------")
    -- 发牌阶段，即摇骰子
    GAME_STATE = GAME_STATUS_SEND_CARDS
    local shaiziTimeOut = pack.shaiziTimeOut
    local shaiziCount = pack.shaiziCount
    local shaiziArray = pack.shaiziArray
    SHAIZI_SEATID = pack.shaiziSeatId
    -- 显示倒计时
    -- GamePlaneOperator:startTimer(shaiziTimeOut)

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
    CALL_TIMES_COUNT=DAO_COUN
    GamePlaneOperator:loadCallTimesPanel(false)

    -- 骰子动画
    GamePlaneOperator:showShiziAnimotion(pack)
end

--广播加倍倍数
function PaiJiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack)

    dump(pack, "-----广播加倍倍数6014-----")

    local playerType = PAIJIU_PLAYERTYPE_TABLE[pack.uid]
    GamePlaneOperator:setBetTimes(playerType,true,pack.base)

    if  playerType == CARD_PLAYERTYPE_MY then
        GamePlaneOperator:showControlButtons(3,false)
    end

end

---------------------------------------------------------------------------------------------------------------------------------------------

--发牌相关
--处理发牌协议 1109 给自己画发牌
function PaiJiuReceiveHandle:SVR_SEND_USER_CARDS(pack)

    dump(pack, "------发送用户的牌信息1109------")

    PJ_AVAI_CARD_GROUPS = pack.allCardsCombinationArray
    PJ_HANDCARDS = pack.cardsArray

    -- 隐藏准备文本，因为在轮庄和固定庄模式下，没有抢庄文本,只有准备文本
    GamePlaneOperator:clearAllReadyStatus()

    -- 自己坐下，隐藏桌面按钮
    GamePlaneOperator:showInviteReadyExitBtn(2)

    -- 隐藏抢庄界面
    GamePlaneOperator:loadZhuangPanel(false)

    -- 隐藏抢庄文本
    GamePlaneOperator:clearGrabBankerSymbol()

    -- 清下注界面
    GamePlaneOperator:loadCallTimesPanel(false)

    -- GamePlaneOperator:showCards(1, PJ_HANDCARDS)
    
    -- local userNum = 0
    -- for k,seatId in pairs(PAIJIU_SEAT_TABLE) do
    --     if seatId >= 0 then
    --         userNum = userNum + 1
    --     end
    -- end

    -- local time = userNum * 0.3 + 0.8
    -- SCENENOW["scene"]:performWithDelay(function(  )
    --     GamePlaneOperator:setCardsValue(1, PJ_HANDCARDS)
    --     -- 画牌
    -- end, time)

    -- 显示开牌相关按钮
    --GamePlaneOperator:showOutCardButtons(true)

    if #PJ_HANDCARDS == 2 then
        --todo
        PJ_CARDS_SELECTED = {}
        PJ_CARDS_SELECTED[1] = PJ_HANDCARDS[1]
        PJ_CARDS_SELECTED[2] = PJ_HANDCARDS[2]
    end
end

-- 广播玩家开始出牌 0x1108 给所有用户发牌
function PaiJiuReceiveHandle:SVR_START_OUT_CARD_BROADCAST(pack)
    dump(pack, "给所有用户发牌-----给所有用户发牌- 广播玩家可以开始出牌 1108----------")
    GAME_STATE = GAME_STATUS_OUT_CARDS
    -- 出牌倒计时
    GamePlaneOperator:startTimer(pack.outCardTimeOut)

    -- GamePlaneOperator:showRemainCards(pack.remainCardsCount)

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

    local card_tbl = {}
    for i=1, pack.handCardsCount do
        table.insert(card_tbl, i, 0)
    end


    local tal = self:handlerFaPai()
    local idx = 0
    for uid,playerType in pairs(tal) do
        SCENENOW["scene"]:performWithDelay(function() 
            GamePlaneOperator:showCards(playerType, card_tbl)
        end,0.2 * idx)
        idx = idx + 1
    end
end

function PaiJiuReceiveHandle:handlerFaPai( )
    local fapai_uid = GamePlaneOperator:getUidBySeatId(SHAIZI_SEATID) --第一个发牌的人的id
    local tal = clone(PAIJIU_PLAYERTYPE_TABLE)
    table.sort(tal,function(a, b)
        return a > b
    end)
    local isFapai = false

    local tal_1 = {}
    local tal_2 = {}
    for uid,playerType in pairs(tal) do
        if uid == fapai_uid then
            isFapai = true
        end
        if isFapai then
            tal_1[uid] = playerType
        else
            tal_2[uid] = playerType
        end
    end
    local table_3 = clone(tal_1)

    for uid,playerType in pairs(tal_2) do
        table_3[uid] = playerType
    end

    return table_3
end

--110B发牌发牌到桌面
function PaiJiuReceiveHandle:SERVER_BROADCAST_START_GAME(pack)
    GamePlaneOperator:showRemainCards(pack.cardsCount)

    dump(pack, "--110B发牌到桌面----------- 110B ------------")
    GamePlaneOperator:showPoolCards(pack.showCards)
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

    -- 停止动画
    GamePlaneOperator:stopTimer()

end

--出牌相关
--广播玩家已准备好出牌 0x1102
function PaiJiuReceiveHandle:SVR_READY_OUTCARD_BROADCAST(pack)
    dump(pack, "-----广播玩家已经准备好出牌1102-----")
    --显示阶段信息
    -- GAME_STATE = GAME_STATUS_OUTCARD --棋牌进行中\

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

    if #pack.cardGroupsArray > 0 then
        --todo
        -- 清除开牌按钮
        GamePlaneOperator:showOutCardButtons(false)
        GamePlaneOperator:showAni4Big(1, pack.cardGroupsArray)
        --IS_SURE_OPEN = true
        PJ_SURE_OPEN_CARD[1] = 1
    else
        local playerType = PAIJIU_PLAYERTYPE_TABLE[pack.uid]
        GamePlaneOperator:showAni4Big(playerType, {})
        PJ_SURE_OPEN_CARD[playerType] = 1
    end


end

--玩家出牌
function PaiJiuReceiveHandle:SVR_USER_PLAYED_CARDS_BROADCAST(pack)

    dump(pack, "-----玩家出牌6005-----")

    ---用于记录所有玩家对应出过的牌，牌的大小
    PAIJIUKIND[pack.uid] =  pack.kind
    PAIJIU_OUTCARDS[pack.uid] = pack.cards

    GAME_STATE = GAME_STATUS_OUTCARD --棋牌进行中

    local playerType = PAIJIU_PLAYERTYPE_TABLE[pack.uid]

    GamePlaneOperator:foldCard(playerType,pack.cards)
    -- GamePlaneOperator:outCard(playerType,pack.cards)
    GamePlaneOperator:showCardKind(playerType,0)  --显示盖牌文字

    if  playerType == CARD_PLAYERTYPE_MY then
        GamePlaneOperator:showControlButtons(5,false)
    end

end

---------------------------------------------------------------------------------------------------------------------------------------------
--扣除台费 4800
function PaiJiuReceiveHandle:SVR_CHIP_CHANGE_BROADCAST(pack)

        local  change_chip = 0
        for _,data in pairs(pack.userinfo) do

            local uid = data.uid
            local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
            local oriChip = PAIJIU_USERINFO_TABLE[uid].coins
            local chip = oriChip + data.change_chip
            PAIJIU_USERINFO_TABLE[uid].coins  = chip

            GamePlaneOperator:setCoin(playerType,chip)

            if  uid == USER_INFO["uid"] then
                --GamePlaneOperator:showTaiFeiTips(data.change_chip)
            end

        end
end

--结算
function PaiJiuReceiveHandle:SVR_SETTLEMENT_BROADCAST(pack)

    dump(pack, "-----牌九结算6008-----")
    if SCENENOW["name"] ~= run_scene_name then
        print("当前场景不是牌九游戏场景！")
        return
    end

    GAME_STATE=GAME_STATUS_STOP

    local playerCount = pack.playerCount

    -- 隐藏开牌按钮
    GamePlaneOperator:showOutCardButtons(false)

    --[[    if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]]--[[ ~= nil then
        -- 自己坐下，隐藏桌面按钮
        GamePlaneOperator:showInviteReadyExitBtn(2)
    else
        -- 自己围观、只显示退出房间按钮
        GamePlaneOperator:showInviteReadyExitBtn(4)
    end]]

    -- 加载单局结算csb
    --[[local s = cc.CSLoader:createNode(TpackageName .. "/csb/gameEnding.csb"):addTo(SCENENOW["scene"])
    s:setScale(1280/1920)
    s:setName("gameResult")
    --s:setLocalZOrder(9999)
    local action = cc.CSLoader:createTimeline(TpackageName .. "/csb/gameEnding.csb")
    action:retain()
    s:runAction(action)
    action:gotoFrameAndPlay(0,25,false)

    local Layer = s:getChildByName("Layer")
    -- 输赢背景
    local bg = Layer:getChildByName("img_bg")
    -- 确定按钮
    local btn_sure = Layer:getChildByName("btn_sure")
    btn_sure:addTouchEventListener(
    function(sender, event)
        if event == TOUCH_EVENT_ENDED then
            dump("---------- 游戏结算确定按钮 ---------")
            s:removeSelf()
            -- 初始化
            -- 清数据
            -- 全局常量

        end
    end)]]
    SCENENOW["scene"]:stopAllActions()
    SCENENOW["scene"]:initData("clearGameData")
    -- -- 玩家头像：庄，输赢合（目前没做）
    --GamePlaneOperator:clearGameDatas(2)
    is_show = false

    if not is_End then
        if isGoldGame == 0 then
            if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] ~= nil then
                GamePlaneOperator:showInviteBtnText(2)
                GamePlaneOperator:showInviteReadyExitBtn(0)
            else
                GamePlaneOperator:showInviteReadyExitBtn(4)
            end
        else
            GamePlaneOperator:showInviteReadyExitBtn(3)
        end
    end
    if GROUP_RESULT then
        self:showResult2(GROUP_RESULT)
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
            GamePlaneOperator:deletechip(PAIJIU_PLAYERTYPE_TABLE[info.uid],info.chips,PLAYER_HEADS_POSITION_TABLE[info.uid])
        end
    end

    if not is_win then
        -- 默认是赢按钮，如果自己输则替换成输背景
        --bg:loadTexture(TpackageName .. "/images/lose.png")
        -- 输音效
        SoundUtils:playEffect("输")
    else
        -- 赢音效
        SoundUtils:playEffect("赢")
    end

    --[[for i=1, 4 do
        player_panel = Layer:getChildByName("player_" ..tostring(i))
        player_panel:setVisible(false)
    end

    for i=1, playerCount do
        local info = pack.userinfo[i]
        local player_panel = Layer:getChildByName("player_"..tostring(i))
        local txt_name = player_panel:getChildByName("txt_name")
        local nickname = require("hall.GameCommon"):formatNick(info.nickName, 4)
        txt_name:setString(nickname)

        local player_panel = Layer:getChildByName("player_"..tostring(i))
        player_panel:setVisible(true)
        local img_head = player_panel:getChildByName("img_head")
        require("hall.GameCommon"):getUserHead(info.portrait, info.uid, info.sex, img_head, 70, false, nickname)

        --[[        local first_panel = player_panel:getChildByName("first_panel")

                local txt_first = player_panel:getChildByName("txt_first")

                local txt_second = player_panel:getChildByName("txt_second")-------------------
        dump(info.uid, "结算画玩家")
        GamePlaneOperator:showCardsOnResultCsb(PAIJIU_PLAYERTYPE_TABLE[info.uid], player_panel, info.cardGroupArray)
        local fnt_score = player_panel:getChildByName("fnt_score")
        if info.chips >= 0 then
            fnt_score:setString("+" .. tostring(info.chips))
        else()
            fnt_score:setString(tostring(info.chips))
        end
        -- 界面增加玩家金币数变化
    end]]

    for i=1, playerCount do
        local info = pack.userinfo[i]
        GamePlaneOperator:showend(PAIJIU_PLAYERTYPE_TABLE[info.uid],info.m_turnBlc/100)
        GamePlaneOperator:setCoin(PAIJIU_PLAYERTYPE_TABLE[info.uid], info.chips)
    end

    --is_show = true

    for uid,_ in pairs(PAIJIU_USERINFO_TABLE) do
        USERS_READY_STATE[uid]=0
        PAIJIU_USERINFO_TABLE[uid]["feedback"]=0
        PAIJIU_USERINFO_TABLE[uid]["daoCount"]=""
        PAIJIU_USERINFO_TABLE[uid]["daoArray"]=""
    end
    BANKER_UID=0;
    --PAIJIU_RESULTINFO=""
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
    --SCENENOW["scene"]:showShareButton(false)
    --GamePlaneOperator:showChecResultButton(true)
    --SCENENOW["scene"]:initData("release")
    --[[    SCENENOW["scene"]:performWithDelay(function()
            SCENENOW["scene"]:initData("release")
        end,1)]]

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
            --[[            if  PAIJIU_USERINFO_TABLE then

                            if PAIJIU_USERINFO_TABLE[uid] then
                                nick = PAIJIU_USERINFO_TABLE[uid].nick
                            end

                        end--]]
            local name_tt = top_ly:getChildByName("name_tt")
            local nick = user_info.nickName
            name_tt:setString(nick)

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
    --local pack = json.decode(pack.msg_data)
    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end

    --退出按钮（当前组局结算，返回到大厅）
    local backHall_action = function(sender,event)

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
            --移除录音按钮
            require("hall.VoiceRecord.VoiceRecordView"):removeView()
            if  SCENENOW["scene"].initData() then
                SCENENOW["scene"]:initData("release")
            end
            --退出房间，返回大厅
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
            HEART_BEAT_TID = 0

        end
    end
    backHall_action = function(sender,event)
        --移除录音按钮
        require("hall.VoiceRecord.VoiceRecordView"):removeView()
        if  SCENENOW["scene"].initData() then
            SCENENOW["scene"]:initData("release")
        end
        --退出房间，返回大厅
        require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
        HEART_BEAT_TID = 0
    end
    --截屏分享
    local share_action = function(sender,event)
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
    share_action = function(sender,event)
        if device.platform == "android" then
            require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
        elseif device.platform ~= "windows" then
            require("hall.common.ShareLayer"):shareGroupResultForIOS()
        end
    end

    --再来一局
    local extend_action = function(sender,event)
        --require(TpackageName..".NiuNiuUtils"):returnToHall()
        require("hall.groudgamemanager"):extend_freegame(USER_INFO["uid"], USER_INFO["activity_id"])
    end

    local data = {}
    data["resultSceneType"] = 2       --战绩界面展示选择，1为长条形，2为方块形
    data["invote_code"] = USER_INFO["invote_code"]     --房间号
    data["fenchang"] = FENCHANG            --分场
    data["round"] = GAME_ROUND                  --局数
    data["date"] = os.date("%Y-%m-%d-%H:%M")    --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
    data["resultData"] = {}             --玩家数据数组
    data['activity_id'] = USER_INFO["activity_id"];

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
            local uid = tonumber(v.uid)
            local photo_url
            local sex = 1
            local nick_name
            local chips
            chips  = v.chips --ERBA_USERINFO_TABLE[uid].coins
            photo_url = v.portrait
            nick_name = v.nickName
            sex = v.sex
            local namenick = ""
            namenick = require("hall.GameCommon"):formatNick(nick_name, 7)
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
            gameDetail1["showName"] = "最高分数"   --展示名
            gameDetail1["value"] = v.maxScore or 0         --值

            local gameDetail2 = {}
            gameDetail2["showName"] = "最大牌型"
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
            gameDetail4["showName"] = "通杀"
            gameDetail4["value"] = v.winAllCount or 0

            local gameDetail5 = {}
            gameDetail5["showName"] = "通赔"
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
    require("hall.settlement.settlement").new(data, backHall_action, share_action, nil, extend_action)

    -- require(GameResultScene_filePath):showScene(data, backHall_action, share_action)
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


end

--广播桌子用户请求解散组局
function PaiJiuReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

    dump(pack, "----- 102A 广播桌子用户请求解散组局-----")

    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")

end

--广播桌子用户成功解散组局
function PaiJiuReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

    dump(pack, "----- 103A 广播桌子用户成功解散组局-----")

    bm.isDisbandSuccess = true
    HEART_BEAT_TID = 0

end

--广播桌子用户解散组局 ，解散组局失败
function PaiJiuReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

    dump(pack, "----- 104A 广播桌子用户解散组局 ，解散组局失败-----")

    local rejectId = pack.rejectId
    if rejectId == USER_INFO["uid"] then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 0, "您拒绝解散房间")
    else
        local nickName = PAIJIU_USERINFO_TABLE[rejectId].nick or "路人甲"
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 0,  nickName.. "拒绝解散房间")
    end

end

function PaiJiuReceiveHandle:SERVER_BROADCAST_AGREE_DISSOLVE_GROUP(pack)
    dump(pack, "---- 105A 广播用户同意解散组局")

end
--聊天
function PaiJiuReceiveHandle:SVR_MSG_FACE(pack)
    dump(pack, "-------SVR_MSG_FACE------")
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
    dump(uid_from, "-- showExpression uid_from: ---- ")
    dump(uid_to, "-- showExpression uid_to: ---- ")
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
    dump(pack, "----------- 801 -------------")
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
                emojiPack["type"] = msg.type
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

function PaiJiuReceiveHandle:SERVER_TEST_AVAIABLE_CARDS(pack)
    dump(pack, "--------- 1FFF SERVER_TEST_AVAIABLE_CARDS")
    local count = pack.count
    local testCards = pack.testCards
    if count <= 0 or #testCards <= 0 then
        return
    end


    local ConfigPanel = SCENENOW["scene"]:getChildByName("ConfigPanel")
    if ConfigPanel then
        ConfigPanel:removeSelf()
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

--接收服务器放回的指定用户信息pack111
function PaiJiuReceiveHandle:SVR_CHARGE_BROADCAST(pack)
    dump(pack,"pack111")
   
    local uid = pack.uid
    local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
    local userInfo = PAIJIU_USERINFO_TABLE[uid]
    if not (playerType and userInfo) then return end
    userInfo.coins = userInfo.coins + pack.chargeCoins
    GamePlaneOperator:setCoin(playerType, userInfo.coins)
end

-- --回看
function PaiJiuReceiveHandle:SERVER_COMMAND_GAMERESULT_RECORD(pack)
    dump(pack,"SERVER_COMMAND_GAMERESULT_RECORD")
    if #pack.gameResult == 0 then
        viewMgr:showTip({text = "无当前所选局数回看！"})
        return
    end

    pack.gameName = "paijiu"  --针对牌九的

    local csbPath = "hall/res/record/node/paijiu_cards.csb"
    local cardsNode = cc.CSLoader:createNode(csbPath)

    for i,userInfo in ipairs(pack.gameResult) do
        local cardNode = cardsNode:clone()
        local index = 1
        local cardsTab = {}
        local root = cardNode:getChildByName("root")

        for idx,value in ipairs(userInfo.cardGroupArray) do
            for i,v in ipairs(value.cards) do
                local tempCard = root:getChildByName("card_"..index)
                tempCard:loadTexture("paijiu/images/cards/" .. v .. ".png")
                index = index+1
                table.insert(cardsTab,v)
            end
        end    
        --游戏类型
        root:getChildByName("img_left"):setVisible(false)
        root:getChildByName("img_right"):setVisible(false)
        root:getChildByName("img_mid"):setVisible(false)
        --大牌九
        if #cardsTab == 4 then
            root:getChildByName("img_left"):setString(LoadCard.changeCardsString(cardsTab[1],cardsTab[2]))
            root:getChildByName("img_left"):setVisible(true)
            root:getChildByName("img_right"):setString(LoadCard.changeCardsString(cardsTab[3],cardsTab[4]))
            root:getChildByName("img_right"):setVisible(true)
        elseif #cardsTab == 2 then
            --小牌九            
            local _type
            local value = userInfo.cardGroupArray[1]
            if value and value.type > PJ_GROUP_TYPE_SPE or value.type == 0 then
                _type = PJ_GROUP_TYPE[value.type]
            else
                _type = PJ_GROUP_TYPE[value.type] .. PJ_GROUP_POINT[value.point]
            end

            root:getChildByName("img_mid"):loadTexture(TpackageName .. "/images/cardname/"..PJ_CARD_TYPE[tostring(_type)]..".png")
            root:getChildByName("img_mid"):setVisible(true)
            root:getChildByName("img_mid"):setScale(3)
        end
        pack.gameResult[i].cardNode = cardNode
    end

    
    local CardsRoundRecord = SCENENOW["scene"]._scene:getChildByName("CardsRoundRecord")
    if CardsRoundRecord then
        CardsRoundRecord:setData(pack)
    else
        local CardsRoundRecord = require("hall.common.CardsRoundRecord").new(pack)
        CardsRoundRecord:setName("CardsRoundRecord")

        CardsRoundRecord:setHandler(handler(PaiJiuSendHandle, PaiJiuSendHandle.CLI_COMMAND_GAMERESULT_RECORD))

        local zidx = ViewBase:getZOrderByChilds(SCENENOW["scene"]._scene)
        CardsRoundRecord:addTo(SCENENOW["scene"]._scene, zidx)
    end
end



return PaiJiuReceiveHandle

--测试性能专用代码
--   local t1 = os.time();
--   for  i =1,10000000  do
--    local PaiJiuReceiveHandle = math.random(1,4)
--        self:getPlayerPlane(PaiJiuReceiveHandle)
-- end

-- local t2 = os.time();
-- print(os.difftime(t2, t1),"运行时间");
