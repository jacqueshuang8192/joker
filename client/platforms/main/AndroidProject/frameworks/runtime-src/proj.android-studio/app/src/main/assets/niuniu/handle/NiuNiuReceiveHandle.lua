local run_scene_name = TpackageName .. '.gameScene'
local hallHandle = require('hall.HallHandle')
local Lottery = require(TpackageName .. '.lottery.Lottery')
local PROTOCOL = require(TpackageName .. '.handle.NiuNiuProtocol')
local GamePlaneOperator = require(TpackageName .. '.operator.GamePlaneOperator')
local ControlPlaneOperator = require(TpackageName .. '.operator.ControlPlaneOperator')

local NiuNiuReceiveHandle = class('NiuNiuReceiveHandle', hallHandle)

function NiuNiuReceiveHandle:ctor()
    NiuNiuReceiveHandle.super.ctor(self)
    local func_ = {
        --进入游戏成功 0210
        --[PROTOCOL.SVR_GET_ROOM_OK] = {handler(self, NiuNiuReceiveHandle.SVR_GET_ROOM_OK)},
        --进去游戏210
        --[PROTOCOL.SVR_LOGIN_GAME] = {handler(self, NiuNiuReceiveHandle.SVR_LOGIN_GAME)},  --210
        --登录房间成功 1007
        [PROTOCOL.SVR_LOGIN_ROOM] = {handler(self, NiuNiuReceiveHandle.SVR_LOGIN_ROOM)},
        --进入房间失败
        [PROTOCOL.SVR_LOGIN_ROOM_FAIL] = {handler(self, NiuNiuReceiveHandle.SVR_LOGIN_ROOM_FAIL)},
        --广播其他用户坐下（金币场） 1031
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, NiuNiuReceiveHandle.BROADCAST_USER_SIT_DOWN)},
        --广播用户退出房间 1032
        [PROTOCOL.BROADCAST_USER_STAND_UP] = {handler(self, NiuNiuReceiveHandle.BROADCAST_USER_STAND_UP)},
        --广播围观者登录桌子 110D
        [PROTOCOL.SVR_COMMAND_WAITING_USERINFOS] = {handler(self, NiuNiuReceiveHandle.SVR_COMMAND_WAITING_USERINFOS)},
        --广播其他用户登录桌子 100D
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, NiuNiuReceiveHandle.SVR_LOGIN_ROOM_BROADCAST)},
        --广播用户退出房间 100E
        [PROTOCOL.SVR_QUIT_ROOM] = {handler(self, NiuNiuReceiveHandle.SVR_QUIT_ROOM)},
        --广播用户退出房间 1033
        [PROTOCOL.BROADCAST_USER_QUIT_ROOM] = {handler(self, NiuNiuReceiveHandle.BROADCAST_USER_QUIT_ROOM)},
        --用户退出房间成功（自己）
        [PROTOCOL.SVR_QUICK_SUC] = {handler(self, NiuNiuReceiveHandle.SVR_QUICK_SUC)},
        --获取筹码返回
        [PROTOCOL.SVR_GET_CHIP] = {handler(self, NiuNiuReceiveHandle.SVR_GET_CHIP)},
        --错误提示5001
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, NiuNiuReceiveHandle.BROADCAST_ERROR_TIPS)},
        --110E
        [PROTOCOL.SVR_REMAID_4WW] = {handler(self, NiuNiuReceiveHandle.SVR_REMAID_4WW)},
        --广播用户托管1034
        [PROTOCOL.BROADCAST_USER_AUTO_PLAY] = {handler(self, NiuNiuReceiveHandle.BROADCAST_USER_AUTO_PLAY)},
        --广播剩余时间100F
        [PROTOCOL.SVR_BROADCAST_COUNT_DOWN] = {handler(self, NiuNiuReceiveHandle.SVR_BROADCAST_COUNT_DOWN)},
        --广播剩余时间1100
        [PROTOCOL.SVR_BROADCAST_WAIT_START] = {handler(self, NiuNiuReceiveHandle.SVR_BROADCAST_WAIT_START)},
        --广播开始准备 6009 （阶段广播）
        [PROTOCOL.SVR_READY_TIME] = {handler(self, NiuNiuReceiveHandle.SVR_READY_TIME)},
        --广播用户准备 6001
        [PROTOCOL.SVR_READY_BROADCAST] = {handler(self, NiuNiuReceiveHandle.SVR_READY_BROADCAST)},
        --发送剩余手牌
        [PROTOCOL.SVR_SEND_USED_CARDS] = {handler(self, NiuNiuReceiveHandle.SVR_SEND_USED_CARDS)},
        --告知庄家可以开始游戏
        [PROTOCOL.SERVER_COMMAND_REMAID_START_GAME] = {
            handler(self, NiuNiuReceiveHandle.SERVER_COMMAND_REMAID_START_GAME)
        },
        --告知庄家不可以开始游戏
        [PROTOCOL.SERVER_COMMAND_REMAID_START_GAME_FAIL] = {
            handler(self, NiuNiuReceiveHandle.SERVER_COMMAND_REMAID_START_GAME_FAIL)
        },
        --广播游戏开始
        [PROTOCOL.SVR_BROADCAST_GAME_START] = {handler(self, NiuNiuReceiveHandle.SVR_BROADCAST_GAME_START)},
        --发牌 4001
        [PROTOCOL.SVR_SEND_USER_CARD] = {handler(self, NiuNiuReceiveHandle.SVR_SEND_USER_CARD)},
        --广播开始抢庄（阶段广播）
        [PROTOCOL.SVR_BEGIN_QIANFGZHUANG_BROADCAST] = {
            handler(self, NiuNiuReceiveHandle.SVR_BEGIN_QIANFGZHUANG_BROADCAST)
        },
        --广播抢庄过程
        [PROTOCOL.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST] = {
            handler(self, NiuNiuReceiveHandle.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST)
        },
        --广播庄家
        [PROTOCOL.SVR_BRANK_BROADCAST] = {handler(self, NiuNiuReceiveHandle.SVR_BRANK_BROADCAST)},
        --7001 广播可以开始加倍（阶段广播）
        [PROTOCOL.SVR_SEND_BASES_TO_USER_BROADCAST] = {
            handler(self, NiuNiuReceiveHandle.SVR_SEND_BASES_TO_USER_BROADCAST)
        },
        --6014 广播加倍倍数
        [PROTOCOL.SVR_USER_BASES_RESULT_BROADCAST] = {
            handler(self, NiuNiuReceiveHandle.SVR_USER_BASES_RESULT_BROADCAST)
        },
        --1042 广播外围结果
        [PROTOCOL.BROADCAST_WAIWEI_RESULT] = {handler(self, NiuNiuReceiveHandle.BROADCAST_WAIWEI_RESULT)},
        --1041 下注剩余时间
        [PROTOCOL.BROADCAST_SENDCARD_REMAINDTIME] = {handler(self, NiuNiuReceiveHandle.BROADCAST_SENDCARD_REMAINDTIME)},
        --6004 广播玩家开始出牌（阶段广播）
        [PROTOCOL.SVR_PLAY_CARD_BROADCAST] = {handler(self, NiuNiuReceiveHandle.SVR_PLAY_CARD_BROADCAST)},
        --6005  广播玩家出牌
        [PROTOCOL.SVR_USER_PLAYED_CARDS_BROADCAST] = {
            handler(self, NiuNiuReceiveHandle.SVR_USER_PLAYED_CARDS_BROADCAST)
        },
        --1043  广播玩家摊牌
        [PROTOCOL.SVR_OPEN_CARDS_BROADCAST] = {handler(self, NiuNiuReceiveHandle.SVR_OPEN_CARDS_BROADCAST)},
        --4008 广播玩家钱数变化（用于扣取台费）
        [PROTOCOL.SVR_CHIP_CHANGE_BROADCAST] = {handler(self, NiuNiuReceiveHandle.SVR_CHIP_CHANGE_BROADCAST)},
        --111 广播玩家充值
        [PROTOCOL.SVR_CHARGE_BROADCAST] = {handler(self, NiuNiuReceiveHandle.SVR_CHARGE_BROADCAST)},
        --6008  单局结算（阶段广播）
        [PROTOCOL.SVR_SETTLEMENT_BROADCAST] = {handler(self, NiuNiuReceiveHandle.SVR_SETTLEMENT_BROADCAST)},
        --5100，广播总结算
        [PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, NiuNiuReceiveHandle.SVR_GROUP_BILLBOARD)},
        --广播当前回合
        [PROTOCOL.SVR_GROUP_TIME] = {handler(self, NiuNiuReceiveHandle.SVR_GROUP_TIME)},
        --外围相关
        --返回下注总情况
        [PROTOCOL.SVR_CMD_REQ_YAZHU_INFO] = {handler(self, NiuNiuReceiveHandle.SVR_CMD_REQ_YAZHU_INFO)},
        --返回单个座位的下注详情
        [PROTOCOL.SVR_CMD_REQ_YAZHU_DETAILS] = {handler(self, NiuNiuReceiveHandle.SVR_CMD_REQ_YAZHU_DETAILS)},
        --广播开始抢外围庄家
        [PROTOCOL.SVR_BROADCAST_BEGIN_GRAB_WW_DEALER] = {
            handler(self, NiuNiuReceiveHandle.SVR_BROADCAST_BEGIN_GRAB_WW_DEALER)
        },
        --广播外围庄家结果
        [PROTOCOL.SVR_BROADCAST_GRAB_WW_DEALER] = {handler(self, NiuNiuReceiveHandle.SVR_BROADCAST_GRAB_WW_DEALER)},
        --请求下注情况返回
        [PROTOCOL.SERVER_CMD_BONUS_RECORD] = {handler(self, NiuNiuReceiveHandle.SERVER_CMD_BONUS_RECORD)},
        --广播下注
        [PROTOCOL.BROADCAST_USER_BET] = {handler(self, NiuNiuReceiveHandle.BROADCAST_USER_BET)},
        --请求录纸返回
        [PROTOCOL.SERVER_CMD_RECORD_PAPER] = {handler(self, NiuNiuReceiveHandle.SERVER_CMD_RECORD_PAPER)},
        --解散相关
        --没有此房间，解散房间失败
        [PROTOCOL.G2H_CMD_DISSOLVE_FAILED] = {handler(self, NiuNiuReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},
        --广播桌子用户请求解散组局
        [PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {
            handler(self, NiuNiuReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)
        },
        --广播当前组局解散情况
        [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST] = {handler(self, NiuNiuReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
        --广播桌子用户成功解散组局
        [PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP] = {
            handler(self, NiuNiuReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)
        },
        --广播桌子用户解散组局 ，解散组局失败
        [PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP] = {
            handler(self, NiuNiuReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)
        },
        --文字聊天相关
        [PROTOCOL.SVR_MSG_FACE] = {handler(self, NiuNiuReceiveHandle.SVR_MSG_FACE)},
        --接收服务器返回的语音表情视频文字 0214
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, NiuNiuReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},
        --接收服务器返回的距离 0213
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, NiuNiuReceiveHandle.SERVER_CMD_MESSAGE)},
        --通知庄家升庄 0x1110
        [PROTOCOL.SERVER_NOTIFY_UP_BANK] = {handler(self, NiuNiuReceiveHandle.SERVER_NOTIFY_UP_BANK)},
        --广播玩家升庄 0x2014
        [PROTOCOL.SERVER_BROADCAST_UP_BANK] = {handler(self, NiuNiuReceiveHandle.SERVER_BROADCAST_UP_BANK)},
        --广播新锅 0x2015
        [PROTOCOL.SERVER_BROADCAST_NEW_GUO] = {handler(self, NiuNiuReceiveHandle.SERVER_BROADCAST_NEW_GUO)},
        --0x1050回看
        [PROTOCOL.SERVER_COMMAND_GAMERESULT_RECORD] = {
            handler(self, NiuNiuReceiveHandle.SERVER_COMMAND_GAMERESULT_RECORD)
        }

        --接收服务器放回的指定用户信息pack111
        -- [PROTOCOL.SERVER_CMD_HALL_GET_MESSAGE] = {handler(self, NiuNiuReceiveHandle.SERVER_CMD_HALL_GET_MESSAGE)},
    }
    table.merge(self.func_, func_)
end

--协议返回数据接收
function NiuNiuReceiveHandle:callFunc(pack)
    if SCENENOW['name'] ~= run_scene_name then
        print('当前场景不是牛牛游戏场景！')
        return
    end

    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        dump(pack.cmd, '收到协议，协议号为')
        self.func_[pack.cmd][1](pack)
    end
end

--function NiuNiuReceiveHandle:SVR_LOGIN_GAME(pack)
--    dump(pack,"牛牛SVR_LOGIN_GAME---")
--    STATUS_GAME = true
--    USER_INFO["tid"] = pack.Tid
--    USER_INFO["activity_id"] = tonumber(pack.activityId or USER_INFO["activity_id"])
--    USER_INFO["player_nums"] = pack.player_nums
--    USER_INFO["Res"] = pack.Res
--    USER_INFO["isWatch"] = pack.isWatch
--    USER_INFO["roomPassword"] = pack.roomPassword   --密码房的房间密码
--    NiuNiuSendHandle:LoginRoom(USER_INFO["tid"],USER_INFO["seat_id"],USER_INFO["activity_id"],USER_INFO["family_id"])
--end

--0210消息，发送进入房间消息113消息后的返回结果,
--function NiuNiuReceiveHandle:SVR_GET_ROOM_OK(pack)
--
--    dump(pack, "-----牛牛21000000-----")
--
--    local tid = pack.tid   --桌子ID
--
--    if  tid == 0 then
--	 	require("hall.GameTips"):showTips("提示", "tohall", 1, "游戏已结束")
--        return
--    end
--
--    if  GROUP_MODE == 2 then
--
--    else
--        Tid = tid
--        NiuNiuSendHandle:LoginRoom(tid)
--    end
--
--end

--进入房间失败 1005
function NiuNiuReceiveHandle:SVR_LOGIN_ROOM_FAIL(pack)
    if JAVA_DOUNIU and tonumber(pack.errorCode) == 16 then
        local tid, activity = USER_INFO.tid, USER_INFO.activity_id
        require(JoinGroup_filePath):unlockDouniuRoom(tid, activity, function()
            NiuNiuSendHandle:LoginRoom(tid, USER_INFO.seat_id, activity)
        end)
        return
    end
    dump(pack, '-----进入房间失败-----')

    local tbErrorCode = {
        [0] = '成功创建新连接',
        [1] = '重连成功',
        [2] = '成功踢其他玩家',
        [3] = '玩家密匙错误',
        [4] = '数据库连接错误',
        [5] = '无此房间',
        [6] = '玩家登录房间错误',
        [7] = '房间人数已满', --"无房间分配",
        [8] = '没有空桌子',
        [9] = '玩家余额不足',
        [10] = '未知错误',
        [14] = '数据库缓存出错',
        [15] = '对不起，您不是VIP',
        [13] = '您当前不能进低分场',
        [12] = '相同IP',
        [19] = '玩家距离过近或缺少定位',
        [16] = '密码错误',
        [17] = '要求携带积分不足',
        [18] = '游戏已开始，无法加入游戏',
        [100] = '不能进行升庄',
        [101] = '小于最小下注金额',
        [102] = '超过最大下注金额',
        [103] = '玩的局数不够，不能退出房间',
        [104] = '当前桌子状态下不能退出房间',
        [105] = '抢庄的积分不足'
    }

    if tbErrorCode[pack.errorCode] then
        if pack.errorCode == 18 or pack.errorCode == 5 or pack.errorCode == 7 then
            local exitFunc = function()
                require('hall.GameCommon'):gExitGroupGame(USER_INFO['enter_mode'])
            end

            require('hall.GameTips'):showTips('提示', '', 2, tbErrorCode[pack.errorCode], nil, exitFunc)
        else
            require('hall.GameTips'):showTips('提示', '', 3, tbErrorCode[pack.errorCode])
        end
    else
        require('hall.GameTips'):showTips('提示', '', 3, '未知的错误')
    end
end

--登录房间 1007
function NiuNiuReceiveHandle:SVR_LOGIN_ROOM(pack)
    require(NetworkLoadingView_filePath):removeView(888)
    dump(pack, '-----NiuNiuReceiveHandle 牛牛登录房间 1007-----')

    local accountScene = SCENENOW['scene']:getChildByName('accountScene')
    if not tolua.isnull(accountScene) then
        accountScene:removeSelf()
    end

    require('hall.settlement.settlement'):removeScene()
    RELOGIN_FLAG = true
    HAS_RECEIVE_GROUP_RESULT = false
    if pack.club_id > 0 then
        USER_INFO['family_id'] = pack.club_id
        CLUB_ID = pack.club_id
    end
    BONUS_POOL_COINS = pack.bonusPool
    MY_SEAT_ID = pack.seat_id --玩家自己本身座位
    GAME_TYPE = pack.gameType

    GAME_STATE = pack.table_status
    BANKER_UID = pack.bank_uid
    TOTAL_PLAYERNUM = pack.maxPlyaerNum or TOTAL_PLAYERNUM
    BASE_CHIP = pack.base
    local gameConfig = pack.gameConfig
    baseChip = pack.base
    -- local gameConfig_string = USER_INFO["gameConfig"] or ""
    WAIWEI_BET_LIMIT = pack.waiwei_betlimit
    WAIWEI_BET_CHIPS = pack.waiweibet_chips

    initialChip = 0
    isGoldGame = pack.isGoldGame

    g_isWatch = pack.isWatch
    if g_isWatch == 0 then
        GamePlaneOperator:setGuanZhanVisible(true) --观战
    end

    GamePlaneOperator:initPlayerPlane(TOTAL_PLAYERNUM) --TOTAL_PLAYERNUM
    GamePlaneOperator:clearGameDatas(1)
    GamePlaneOperator:clearGameDatas(2)

    if GROUP_MODE == 2 then
        USER_INFO['activity_id'] = pack.activityId
        USER_INFO['invote_code'] = pack.inviteCode
    end

    if isGoldGame == 0 then
        initialChip = 0
    end

    if pack.gameType == 1 then
        GAME_TYPE_NAME = '明牌抢庄'
    elseif pack.gameType == 2 then
        GAME_TYPE_NAME = '定庄斗牛'
    elseif pack.gameType == 3 then
        GAME_TYPE_NAME = '轮庄斗牛'
    elseif pack.gameType == 4 then
        GAME_TYPE_NAME = '牛牛坐庄'
    elseif pack.gameType == 5 then
        GAME_TYPE_NAME = '斗公牛'
    end

    NIUNIU_CARDTYPE_TABLE = {
        [1] = 1, --无牛
        [2] = 1, --牛一
        [3] = 1,
        [4] = 1,
        [5] = 1,
        [6] = 1,
        [7] = 1,
        [8] = 1,
        [9] = 2,
        [10] = 2,
         --牛九
        [11] = 3,
         --牛牛
        [CARDKIND_SHUNZI] = 5,
         -- 顺子牛
        [CARDKIND_WUHUA] = 5,
         -- 五花牛
        [CARDKIND_TONGHUANIU] = 6,
         -- 同花牛
        [CARDKIND_HULUNIU] = 6,
         -- 葫芦牛
        [CARDKIND_SIZHA] = 7,
         -- 四炸牛
        [CARDKIND_WUXIAONIU] = 8,
         -- 五小牛
        [CARDKIND_SISHIDA] = 7,
         -- 四十大
        [-1] = 1
     -- 金牌牛
    }

    --通过接口传来的字符串获取具体配置信息
    local gameConfigTable

    if type(gameConfig) == 'string' then
        gameConfigTable = json.decode(gameConfig)
        g_mainScene.gameConfigTable = gameConfigTable
        dump(gameConfigTable, 'gameConfigTable')
        if gameConfigTable['times'] then
            baseChip = string.gsub(gameConfigTable['times'], ',', '/')
        end
        if gameConfigTable['showCardNums'] == 0 then
            GAME_TYPE_NAME = '自由上庄'
        end
        if gameConfigTable['timesRule'] == 3 then
            GAME_TYPE_NAME = '疯狂斗牛'
            if appName == '点子牛' then
                GAME_TYPE_NAME = '点子牛牛'
            end
            NIUNIU_CARDTYPE_TABLE[2] = 1
            NIUNIU_CARDTYPE_TABLE[3] = 2
            NIUNIU_CARDTYPE_TABLE[4] = 3
            NIUNIU_CARDTYPE_TABLE[5] = 4
            NIUNIU_CARDTYPE_TABLE[6] = 5
            NIUNIU_CARDTYPE_TABLE[7] = 6
            NIUNIU_CARDTYPE_TABLE[8] = 7
            NIUNIU_CARDTYPE_TABLE[9] = 8
            NIUNIU_CARDTYPE_TABLE[10] = 9
            NIUNIU_CARDTYPE_TABLE[11] = 10
            NIUNIU_CARDTYPE_TABLE[CARDKIND_SHUNZI] = 11
            NIUNIU_CARDTYPE_TABLE[CARDKIND_WUHUA] = 11
            NIUNIU_CARDTYPE_TABLE[CARDKIND_TONGHUANIU] = 12
            NIUNIU_CARDTYPE_TABLE[CARDKIND_HULUNIU] = 12
            NIUNIU_CARDTYPE_TABLE[CARDKIND_SIZHA] = 15
            NIUNIU_CARDTYPE_TABLE[CARDKIND_WUXIAONIU] = 20
        elseif gameConfigTable['timesRule'] == 2 then
            NIUNIU_CARDTYPE_TABLE[8] = 2
            NIUNIU_CARDTYPE_TABLE[9] = 2
            NIUNIU_CARDTYPE_TABLE[10] = 3
             --牛九
            NIUNIU_CARDTYPE_TABLE[11] = 4
         --牛牛
        elseif gameConfigTable['timesRule'] == 1 then
            NIUNIU_CARDTYPE_TABLE[8] = 1
            NIUNIU_CARDTYPE_TABLE[9] = 2
            NIUNIU_CARDTYPE_TABLE[10] = 2
             --牛九
            NIUNIU_CARDTYPE_TABLE[11] = 3
         --牛牛
        elseif gameConfigTable['timesRule'] == 4 then
            NIUNIU_CARDTYPE_TABLE[8] = 2
            NIUNIU_CARDTYPE_TABLE[9] = 3
            NIUNIU_CARDTYPE_TABLE[10] = 4
             --牛九
            NIUNIU_CARDTYPE_TABLE[11] = 5
         --牛牛
        end

        if gameConfigTable['speType'] then
            if string.find(gameConfigTable['speType'], '5') then
                GAME_CONFIG['四炸'] = true
            end

            if string.find(gameConfigTable['speType'], '6') then
                GAME_CONFIG['五小牛'] = true
            end

            if string.find(gameConfigTable['speType'], '4') then
                GAME_CONFIG['葫芦牛'] = true
            end

            if string.find(gameConfigTable['speType'], '3') then
                GAME_CONFIG['同花牛'] = true
            end

            if string.find(gameConfigTable['speType'], '1') then
                GAME_CONFIG['顺子牛'] = true
            end

            if string.find(gameConfigTable['speType'], '2') then
                GAME_CONFIG['五花牛'] = true
            end

            if string.find(gameConfigTable['speType'], '7') then
                GAME_CONFIG['四十大'] = true
            end
        end

        if gameConfigTable['gaoji'] then
            if string.find(gameConfigTable['gaoji'], '3') then
                GAME_CONFIG['允许搓牌'] = true
            else
                GAME_CONFIG['允许搓牌'] = false
            end
        else
            GAME_CONFIG['允许搓牌'] = false
        end

        if gameConfigTable['waiwei'] and string.find(gameConfigTable['waiwei'], '1') then
            GAME_CONFIG['买牛'] = true

            if GAME_STATE == GAME_STATUS_TIMES or GAME_STATE == GAME_STATUS_OUTCARD then
                NiuNiuSendHandle:CLI_CMD_REQ_YAZHU_INFO() --请求下注情况
            end

            Lottery:init(pack.waiweibet_chips)
        end
    end

    NIUNIU_SCENE:updateRoomInfo(baseChip, GAME_TYPE_NAME, pack.inviteCode, nil, nil, gameConfigTable)
    NIUNIU_SCENE:registShareButtons(pack.inviteCode)

    --根据人数更换界面布局
    NIUNIU_SCENE:switchBackGroundGrid(TOTAL_PLAYERNUM)

    if GAME_STATE ~= GAME_STATUS_STOP then
        NIUNIU_SCENE:showShareButton(false)
    end

    dump(NIUNIU_CARDTYPE_TABLE, 'NIUNIU_CARDTYPE_TABLE')
    ---------------------------------显示信息---------------------------------------
    if USER_INFO['longitude'] == nil then
        NiuNiuUtils:getLocationFromDevice()
    end

    if GAME_TYPE == 5 then
        ControlPlaneOperator:setBetBtnVisible(false)
        ControlPlaneOperator:setUpBankBtnVisible(false)
    end

    GAME_PARTICIPANTS = {}

    for _, v in pairs(pack.users_infos) do
        if v.user_status > 0 and v.user_status < 9 then
            USERS_READY_STATE[v.uid] = 1
            if v.user_status > 1 then
                table.insert(GAME_PARTICIPANTS, v.uid)
            end
            if v.keTuizhu > 0 then
                local playerType = NIUNIU_PLAYERTYPE_TABLE[v.uid]
                GamePlaneOperator:setMaxTuizhuTimes(playerType, v.keTuizhu, true)
            end
        else
            if GAME_TYPE == 5 and v.user_status == 10 then
                USERS_READY_STATE[v.uid] = 1
            else
                USERS_READY_STATE[v.uid] = 0
            end
        end

        NiuNiuUtils:collectPlayerData(v)
    end

    PLAYERNUM, AUDIENCENUM = NiuNiuUtils:getPlayerNum() --先刷新全局人数

    if MY_SEAT_ID >= 0 then
        RELATIVE_SEAT_ID = MY_SEAT_ID
        NIUNIU_SCENE:showButtonAfterSitDown(true)

        local seat_id = MY_SEAT_ID
        local uid = USER_INFO['uid']
        local userInfo = NIUNIU_USERINFO_TABLE[USER_INFO['uid']]
        local user_if_outline = 1

        NiuNiuUtils:showPlayer(uid, seat_id, userInfo, user_if_outline)
    else --没准备或者是围观
        RELATIVE_SEAT_ID = 0
    end

    local user_datas = {}
    local send_card_num = nil

    for _, v in pairs(pack.users_infos) do
        local seat_id = v.seat_id
        if seat_id >= 0 then
            local uid = v.uid
            local userInfo = NIUNIU_USERINFO_TABLE[uid]
            local user_if_outline = v.user_if_outline
            NiuNiuUtils:showPlayer(uid, seat_id, userInfo, user_if_outline)
            GamePlaneOperator:clearBankerFlag()
            
            if uid == USER_INFO['uid'] then
                IS_AUTO_PLAY = v['user_if_auto']
                if IS_AUTO_PLAY == 1 then
                    GamePlaneOperator:showAutoPlayTip(true)
                end
            end

            if send_card_num == nil then
                send_card_num = 0

                for _, card in pairs(v.user_base_out_cards) do
                    if card > 0 then
                        send_card_num = send_card_num + 1
                    end
                end
            end

            local tmp_user_data = {cards = v.user_base_out_cards, seatId = seat_id}
            table.insert(user_datas, tmp_user_data)
        end
    end

    ---------------------------------------------------------------------------------
    -- pack.user_status 的可能值
    -- 0 //牌局已结束
    -- 1 准备
    -- 2 等待用户抢庄
    -- 3 牌局开始
    -- 4 grabdealer
    -- 5 等待用户选择倍数
    -- 6 calltimes
    -- 7 等待出牌
    -- 8 outcard
    -- 9 isspectator
    ----------------------------------------------------------------
    USERS_READY_STATE[USER_INFO['uid']] = 0

    if pack.user_status == 0 or pack.user_status == 9 then --没准备或者是围观
        -- RELATIVE_SEAT_ID = 0
        USERS_READY_STATE[USER_INFO['uid']] = 0

        --只有在游戏停止时才开启准备按钮
        if GAME_STATE == GAME_STATUS_STOP then
            GamePlaneOperator:showControlButtons(1)
        else
            GamePlaneOperator:showAudienceBrand(true)
            GamePlaneOperator:showControlButtons(1, false)
        end

        if pack.seat_id < 0 then
            GamePlaneOperator:showControlButtons(1, false)
            if PLAYERNUM < TOTAL_PLAYERNUM then
                GamePlaneOperator:showSitDownButton(true)
            end
        end
    elseif pack.user_status > 1 then
        table.insert(GAME_PARTICIPANTS, USER_INFO['uid'])
    end

    if GAME_STATE ~= GAME_STATUS_STOP and GAME_STATE ~= GAME_STATUS_OUTCARD then
        local data = {}
        data.isRelogin = true
        data.user_datas = user_datas

        if GAME_CONFIG['买牛'] == true then
            data.send_card_num = send_card_num
        end
        data.hasLeper = pack.hasLeper
        data.lepers = pack.lepers
        local lepers = pack.lepers or {}
        self:SVR_BROADCAST_GAME_START(data)
        if pack.hasLeper == 2 then
            GamePlaneOperator:showTableLaizi(lepers[1], false)
        end
    end

    if GAME_STATE == GAME_STATUS_OUTCARD then
        local pack = {}
        pack.time = pack.less_time
        self:SVR_PLAY_CARD_BROADCAST(pack) --广播
    end

    --用户已准备
    if pack.user_status == 1 then
        --等待抢庄，已经做出选择，广播庄家阶段
        if pack.seat_id == 0 and pack.allUsersReadyStatus == 1 then
            --通知房主可以开始游戏
            GamePlaneOperator:RemaidStartGame(true)
        end
        local pack = {}
        pack.uid = USER_INFO['uid']
        pack.readyState = 1
        NiuNiuReceiveHandle:SVR_READY_BROADCAST(pack)
    elseif pack.user_status == 2 or pack.user_status == 3 or pack.user_status == 4 then
        --等待加倍，已经加倍
        --发的前三张牌
        local pack_tmp = {}
        pack_tmp.cards = pack.cards
        pack_tmp.isRelogin = true
        FIRSTSENDCARD = true
        NiuNiuReceiveHandle:SVR_SEND_USER_CARD(pack_tmp)
        local pack_tmp = {}
        pack_tmp.ids = {}
        pack_tmp.time = pack.less_time
        pack_tmp.grab_times = pack.grab_times
        pack_tmp.can_grab_times = pack.can_grab_times
        pack_tmp.canGrabDealer = pack.canGrabDealer
        for uid, seat_id in pairs(NIUNIU_SEAT_TABLE) do
            table.insert(pack_tmp.ids, uid)
        end
        NiuNiuReceiveHandle:SVR_BEGIN_QIANFGZHUANG_BROADCAST(pack_tmp)
        if pack.user_status == 3 then
            local pack_tmp = {}
            pack_tmp.uid = USER_INFO['uid']
            pack_tmp.if_qiang = 0
            NiuNiuReceiveHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack_tmp)
        elseif pack.user_status == 4 then
            local pack_tmp = {}
            pack_tmp.uid = USER_INFO['uid']
            pack_tmp.if_qiang = 1
            NiuNiuReceiveHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack_tmp)
        end
    elseif pack.user_status == 5 or pack.user_status == 6 then
        --等待出牌，已经出牌
        --发的前三张牌
        local pack_tmp = {}
        pack_tmp.cards = pack.cards
        pack_tmp.isRelogin = true
        FIRSTSENDCARD = true
        NiuNiuReceiveHandle:SVR_SEND_USER_CARD(pack_tmp)
        local pack_tmp = {}
        pack_tmp.time = pack.less_time
        pack_tmp.selects_base = JAVA_DOUNIU and pack.selects_base or pack.can_selects_base --2.0BUG，pack.selects_base
        pack_tmp.can_selects_base = pack.can_selects_base
        NiuNiuReceiveHandle:SVR_SEND_BASES_TO_USER_BROADCAST(pack_tmp)
        if pack.user_status == 6 then
            local pack_tmp = {}
            pack_tmp.uid = USER_INFO['uid']
            pack_tmp.base = pack.user_base_calltime
            pack_tmp.tuizhu = pack.tuizhu
            NiuNiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
        end
    elseif pack.user_status == 7 or pack.user_status == 8 then
        if pack.user_status == 7 then
            local pack_tmp = {}
            pack_tmp.cards = pack.user_base_waitplay_cards
            pack_tmp.isRelogin = true

            FIRSTSENDCARD = true
            NiuNiuReceiveHandle:SVR_SEND_USER_CARD(pack_tmp)
            -- FIRSTSENDCARD = false
            -- NiuNiuReceiveHandle:SVR_SEND_USER_CARD(pack_tmp)
            if BANKER_UID ~= USER_INFO['uid'] then
                local pack_tmp = {}
                pack_tmp.uid = USER_INFO['uid']
                pack_tmp.base = pack.user_base_waitplay
                pack_tmp.tuizhu = pack.tuizhu
                NiuNiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
            end
            GamePlaneOperator:showControlButtons(5)
            NiuNiuSendHandle:sendMycards({0, 0, 0})
        end
        --出牌完了
        if pack.user_status == 8 then
            local pack_tmp = {}
            pack_tmp.cards = pack.user_base_out_cards
            pack_tmp.isRelogin = true
            FIRSTSENDCARD = true
            NiuNiuReceiveHandle:SVR_SEND_USER_CARD(pack_tmp)
            -- FIRSTSENDCARD = false
            -- NiuNiuReceiveHandle:SVR_SEND_USER_CARD(pack_tmp)
            if BANKER_UID ~= USER_INFO['uid'] then
                local pack_tmp = {}
                pack_tmp.uid = USER_INFO['uid']
                pack_tmp.base = pack.user_base_out
                pack_tmp.tuizhu = pack.tuizhu

                NiuNiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
            end

            local pack_tmp = {}
            pack_tmp.uid = USER_INFO['uid']
            pack_tmp.kind = pack.user_base_out_card_kind
            pack_tmp.cards = pack.user_base_out_cards
            NiuNiuReceiveHandle:SVR_USER_PLAYED_CARDS_BROADCAST(pack_tmp)
        end
    elseif pack.user_status == 10 then
        if GAME_STATE == 5 then --//庄家操作
            if pack.isWatch == 1 then
                ControlPlaneOperator:setUpBankBtnVisible(true, pack.bankerOptState)
            end
        end
    end

    for i, data in pairs(pack.users_infos) do
        if data['uid'] ~= USER_INFO['uid'] then
            if data['user_status'] == 1 then
                --不抢庄
                local pack = {}
                pack.uid = data['uid']
                NiuNiuReceiveHandle:SVR_READY_BROADCAST(pack)
            elseif data['user_status'] == 3 then
                --抢庄
                local pack_tmp = {}
                pack_tmp.uid = data.uid
                pack_tmp.if_qiang = 0
                NiuNiuReceiveHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack_tmp)
            elseif data['user_status'] == 4 then
                --加倍完成
                local pack_tmp = {}
                pack_tmp.uid = data.uid
                pack_tmp.if_qiang = 1
                NiuNiuReceiveHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack_tmp)
            elseif data['user_status'] == 6 then
                --等待出牌
                local pack_tmp = {}
                pack_tmp.uid = data.uid
                pack_tmp.base = data.user_base_calltime
                pack_tmp.tuizhu = pack.tuizhu

                NiuNiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
            elseif data['user_status'] == 7 then
                --出牌完成
                if pack.bank_uid ~= data.uid then
                    local pack_tmp = {}
                    pack_tmp.uid = data.uid
                    pack_tmp.base = data.user_base_waitplay
                    pack_tmp.tuizhu = pack.tuizhu
                    NiuNiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
                end
            elseif data['user_status'] == 8 then
                if pack.bank_uid ~= data.uid then
                    local pack_tmp = {}
                    pack_tmp.uid = data.uid
                    pack_tmp.base = data.user_base_waitplay
                    pack_tmp.tuizhu = pack.tuizhu
                    NiuNiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
                end

                local pack_tmp = {}
                pack_tmp.uid = data.uid
                pack_tmp.kind = data.user_base_out_cards_cardkind
                pack_tmp.cards = data.user_base_out_cards
                NiuNiuReceiveHandle:SVR_USER_PLAYED_CARDS_BROADCAST(pack_tmp)
            end
        end
    end

    --显示庄家
    local BankerPlayerType = NIUNIU_PLAYERTYPE_TABLE[pack.bank_uid]
    if pack.bank_uid ~= -1 and pack.table_status >= 2 then
        GamePlaneOperator:showHeadSymbol(BankerPlayerType, 'banker', true)
    end

    if GAME_TYPE == 5 then
        ControlPlaneOperator:setGuoJusize(pack.m_curGuoJuSize)
        g_mainScene.curGuoJusize = pack.m_curGuoJuSize
        if pack.m_guodi >= 0 then
            g_mainScene.curGuodi = pack.m_guodi
            g_mainScene.m_nGuoCount = pack.m_nGuoCount
            ControlPlaneOperator:setGuodiScore(pack.m_guodi)
            NIUNIU_SCENE:showShareButton(false)
        end
        ControlPlaneOperator:setRoomRoundVisible(false)
    else
        ControlPlaneOperator:setRoomRoundVisible(true)
    end
    if pack.start_id == USER_INFO['uid'] then
        GamePlaneOperator:RemaidStartGame(true)
    end
end

---------------------------------------------------------------------------------------------------------------

--广播围观者登录桌子 110D
function NiuNiuReceiveHandle:SVR_COMMAND_WAITING_USERINFOS(pack)
    dump(pack, '------广播围观者登录桌子110D------')
    local wait_players = pack.wait_players

    for _, data in pairs(wait_players) do
        NiuNiuUtils:collectPlayerData(data)
    end
end

--广播用户登录桌子 100D   其他用户进入房间
function NiuNiuReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)
    dump(pack, '------广播用户登录桌子100D------')
    NiuNiuUtils:collectPlayerData(pack)

    PLAYERNUM = NiuNiuUtils:getPlayerNum() --先刷新全局人数

    -- local seat_id = pack.seat_id
    -- if  seat_id >= 0 then
    --     local uid =  pack.uid
    --     local userInfo = NIUNIU_USERINFO_TABLE[uid]
    --     local user_if_outline = pack.user_if_outline
    --     NiuNiuUtils:showPlayer(uid,seat_id,userInfo,user_if_outline)
    -- end

    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    if playerType then
        GamePlaneOperator:showHeadSymbol(playerType, 'disconnect', false)
    end
end

--广播自己退出 1008
function NiuNiuReceiveHandle:SVR_QUICK_SUC(pack)
    dump('广播自己退出')
    --if  GROUP_MODE == 2 then
    --if NIUNIU_SCENE.reConnect then
    --    NIUNIU_SCENE:reConnect()
    --end
    require('hall.HallServer'):loginGameNew(USER_INFO['GroupLevel'], USER_INFO['tid'], USER_INFO['activity_id'], 1)
    --require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

    --end
    -- require("hall.ScoketGame"):showReloginTip()
end

--广播玩家退出返回（断线） 100E
function NiuNiuReceiveHandle:SVR_QUIT_ROOM(pack)
    dump(pack, '------广播玩家退出返回100E------')

    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    if playerType then
        GamePlaneOperator:showHeadSymbol(playerType, 'disconnect', true)
    end
end

--广播用户坐下 1031   其他用户进入房间
function NiuNiuReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
    dump(pack, '--广播用户坐下 1031')

    NIUNIU_SEAT_TABLE[pack.uid] = pack.seat_id --保存用户座位与id映射

    PLAYERNUM = NiuNiuUtils:getPlayerNum() --先刷新全局人数

    if USER_INFO['uid'] == pack.uid then --自己坐下的话重新排版布局
        --游戏过程中加入不会重定位
        NIUNIU_SCENE:showButtonAfterSitDown(true)
        GamePlaneOperator:showSitDownButton(false)

        --重定位逻辑
        MY_SEAT_ID = pack.seat_id

        if GAME_STATE == GAME_STATUS_STOP then --游戏前加入重定位
            RELATIVE_SEAT_ID = MY_SEAT_ID
            GamePlaneOperator:showControlButtons(1)
            GamePlaneOperator:clearGameDatas(2)
            NiuNiuUtils:relocatePlayer()
        elseif RELATIVE_SEAT_ID == MY_SEAT_ID then
            NiuNiuUtils:relocatePlayer()
        else
            local seat_id = MY_SEAT_ID
            if seat_id >= 0 then
                local uid = pack.uid
                local userInfo = NIUNIU_USERINFO_TABLE[uid]
                local user_if_outline = false --用户是否掉线
                NiuNiuUtils:showPlayer(uid, seat_id, userInfo, user_if_outline)
            end
        end
    else --其他人坐下的话只给他画头像信息
        -- NiuNiuUtils:collectPlayerData(pack)
        local seat_id = pack.seat_id
        if seat_id >= 0 then
            local uid = pack.uid
            local userInfo = NIUNIU_USERINFO_TABLE[uid]
            local user_if_outline = false
            NiuNiuUtils:showPlayer(uid, seat_id, userInfo, user_if_outline)
        end
    end

    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    if playerType then
        GamePlaneOperator:showHeadSymbol(playerType, 'disconnect', false)
    end

    --人满之后自己作为旁观者时隐藏坐下按钮
    if MY_SEAT_ID < 0 then
        if PLAYERNUM == TOTAL_PLAYERNUM then
            GamePlaneOperator:showSitDownButton(false)
        end
    end
end

--广播玩家站起 1032
function NiuNiuReceiveHandle:BROADCAST_USER_STAND_UP(pack)
    dump(pack, '------广播玩家站起1032------')

    local seat_id = NIUNIU_SEAT_TABLE[pack.uid]

    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    -- NiuNiuUtils:returnPlayerType(NIUNIU_PLAYERTYPE_TABLE[pack.uid])

    if playerType then
        if HAS_RECEIVE_GROUP_RESULT == true then
            return
        end

        GamePlaneOperator:initPlayerView(playerType)
        Lottery:showPlaneItemChange(seat_id, 'standUp')
    end

    NIUNIU_PLAYERTYPE_TABLE[pack.uid] = nil
    if NIUNIU_UID_TABLE then
        NIUNIU_UID_TABLE[seat_id] = {}
    end
    NIUNIU_SEAT_TABLE[pack.uid] = -2

    PLAYERNUM, AUDIENCENUM = NiuNiuUtils:getPlayerNum() --先刷新全局人数

    if USER_INFO['uid'] == pack.uid then
        GamePlaneOperator:showControlButtons(1, false)
        GamePlaneOperator:showSitDownButton(true)

        NIUNIU_SCENE:showButtonAfterSitDown(false)
        MY_SEAT_ID = -2
    elseif MY_SEAT_ID < 0 then --别人站起，自己也站着的时候
        GamePlaneOperator:showSitDownButton(true)
    end

    -- local uid = pack.uid
    -- if  uid and require("hall.view.userInfoView.userInfoView").upDateUserInfo then
    --     require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,{["latitude"] = nil},"latitude")
    --     require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,{["longitude"] = nil},"longitude")
    -- end
end

--广播玩家退出返回（离开房间） 1033
function NiuNiuReceiveHandle:BROADCAST_USER_QUIT_ROOM(pack)
    dump(pack, '------广播玩家退出返回1033------')

    if HAS_RECEIVE_GROUP_RESULT == true then
        return
    end

    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    -- NiuNiuUtils:returnPlayerType(NIUNIU_PLAYERTYPE_TABLE[pack.uid])

    if playerType then
        GamePlaneOperator:initPlayerView(playerType)
        Lottery:showPlaneItemChange(seat_id, 'leaveRoom')
        GamePlaneOperator:showHeadSymbol(playerType, 'disconnect', false)
    end

    NIUNIU_PLAYERTYPE_TABLE[pack.uid] = nil

    local seat_id = NIUNIU_SEAT_TABLE[pack.uid]
    if seat_id and seat_id >= 0 then
        NIUNIU_UID_TABLE[seat_id] = 0
    end

    NIUNIU_SEAT_TABLE[pack.uid] = -1
    USERS_READY_STATE[pack.uid] = 0

    PLAYERNUM, AUDIENCENUM = NiuNiuUtils:getPlayerNum() --先刷新全局人数

    if pack.uid == USER_INFO['uid'] then
        if GAME_TYPE == 5 then
            --MY_SEAT_ID = nil
            HEART_BEAT_TID = 0
            require('hall.GameCommon'):gExitGroupGame(USER_INFO['enter_mode'], CLUB_ID)
        else
            if
                isGoldGame == 0 or
                    ((isGoldGame == 1 or isGoldGame == 2) and GAME_ROUND <= GAME_TOTAL_ROUND and
                        HAS_RECEIVE_GROUP_RESULT ~= true)
             then
                --MY_SEAT_ID = nil
                HEART_BEAT_TID = 0
                require('hall.GameCommon'):gExitGroupGame(USER_INFO['enter_mode'], CLUB_ID)
            end
        end
    end

    local uid = pack.uid
    if uid and require('hall.view.userInfoView.userInfoView').upDateUserInfo then
        require('hall.view.userInfoView.userInfoView'):upDateUserInfo(uid, {}, 'reset')
    end
end

--1041 广播下注剩余时间
function NiuNiuReceiveHandle:BROADCAST_SENDCARD_REMAINDTIME(pack)
    if GAME_TYPE == 5 then
        ControlPlaneOperator:showOptClock(pack.time)
    else
        GamePlaneOperator:startTimer(pack.time, '下注阶段')
    end
end

--5001
function NiuNiuReceiveHandle:BROADCAST_ERROR_TIPS(pack)
    dump(pack, '-----返回错误提示5001-----')

    local errorCode = pack.errorCode

    local tbErrorCode = {
        [1] = '操作无效',
        [10] = '游戏进行中，请稍后！',
        [11] = '您选的座位上已经有人了',
        [12] = '您已经准备过了',
        [13] = '您还没准备',
        [14] = '您已经坐下了',
        [15] = '您正在围观中',
        [16] = '桌子已经满啦',
        [17] = '玩家不存在',
        [18] = '您积分不够啦，请充值',
        [19] = '游戏未开始',
        [20] = '无法在当前阶段做此操作！',
        [21] = '下注超过上限',
        [22] = '您在座位上时不能坐庄！',
        [24] = '此牌已被使用！',
        [109] = '相同IP禁止入座',
        [110] = '玩家距离过近或缺少定位',
        [100] = '不能进行升庄',
        [101] = '小于最小下注金额',
        [102] = '超过最大下注金额',
        [103] = '玩的局数不够，不能退出房间',
        [104] = '当前桌子状态下不能退出房间',
        [105] = '抢庄的积分不足',
        [106] = '庄家不能退出',
        [107] = '升庄积分不足，轮到下家当庄',
        [108] = '上庄次数不足，不能退出房间'
    }

    if errorCode == 18 then
        NIUNIU_SCENE:performWithDelay(
            function()
                --去掉提示弹框
                local layer_tips = NIUNIU_SCENE:getChildByName('layer_tips')
                if layer_tips then
                    layer_tips:removeSelf()
                end

                if not isiOSVerify then
                    NIUNIU_SCENE:requestCharge()
                end
            end,
            1.5
        )
    end

    dump(tbErrorCode[errorCode], '错误提示')

    if tbErrorCode[errorCode] then
        -- require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[errorCode])
        viewMgr:showTip({text = tbErrorCode[errorCode]})
    else
        -- require("hall.GameTips"):showTips("提示", "", 3, "未知的错误")
        viewMgr:showTip({text = '未知的错误'})
    end
end

--筹码相关
--获取筹码返回
function NiuNiuReceiveHandle:SVR_GET_CHIP(pack)
    dump(pack, '-----获取筹码返回906-----')
    GamePlaneOperator:setCoin(CARD_NiuNiuReceiveHandle_MY, pack.chip)
end

--5101
function NiuNiuReceiveHandle:SVR_GROUP_TIME(pack)
    GAME_ROUND = pack.round
    GAME_TOTAL_ROUND = pack.round_total or 999

    if isGoldGame == 0 then
        GAME_TOTAL_ROUND = 999
    end

    NIUNIU_SCENE:updateRoomInfo(nil, nil, nil, GAME_ROUND, GAME_TOTAL_ROUND)

    --add by zzy 2019-7-17 游戏没有开始屏蔽解散房间
    NIUNIU_SCENE.GameRound = pack.round
end

--广播玩家开启托管 1034
function NiuNiuReceiveHandle:BROADCAST_USER_AUTO_PLAY(pack)
    dump(pack, '------广播玩家开启托管 1034------')

    if pack.uid == USER_INFO['uid'] then
        IS_AUTO_PLAY = pack.isOpenAuto

        if pack.isOpenAuto == 0 then --关闭托管
            GamePlaneOperator:showAutoPlayTip(false)
        else --开启托管
            GamePlaneOperator:showAutoPlayTip(true)
        end
    end
end

--广播开始游戏倒计时 100F
function NiuNiuReceiveHandle:SVR_BROADCAST_COUNT_DOWN(pack)
    dump(pack, '------广播开始游戏倒计时 100F------')
    if pack.time > 0 then
        if GAME_TYPE == 5 then
            ControlPlaneOperator:showOptClock(pack.time)
        else
            GamePlaneOperator:startTimer(pack.time, '准备阶段')
        end

        --游戏开始时才清除数据
        if RELOGIN_FLAG ~= true then
            Lottery:clearGameDatas()
            GamePlaneOperator:clearGameDatas(2)
        end

        if USERS_READY_STATE[USER_INFO['uid']] and USERS_READY_STATE[USER_INFO['uid']] ~= 1 and MY_SEAT_ID >= 0 then
            GamePlaneOperator:showControlButtons(1)
        end

        NIUNIU_SCENE:showShareButton(false)
    end

    RELOGIN_FLAG = false
end

--广播开始游戏倒计时 1100
function NiuNiuReceiveHandle:SVR_BROADCAST_WAIT_START(pack)
    dump(pack, '------广播开始游戏倒计时 1100------')
    local time = pack.time
    if time >= 0 then
        if GAME_TYPE == 5 then
            ControlPlaneOperator:showOptClock(time)
        else
            GamePlaneOperator:startTimer(time, '准备阶段')
        end

        Lottery:remainStageProgress(time, 'start')

        --游戏开始时才清除数据
        if RELOGIN_FLAG ~= true then
            Lottery:clearGameDatas()
            GamePlaneOperator:clearGameDatas(2)
        end

        if USERS_READY_STATE[USER_INFO['uid']] and USERS_READY_STATE[USER_INFO['uid']] ~= 1 and MY_SEAT_ID >= 0 then
            GamePlaneOperator:showControlButtons(1)
        end

        NIUNIU_SCENE:showShareButton(false)
    end

    RELOGIN_FLAG = false
end

--准备相关
--广播用户可以准备了
function NiuNiuReceiveHandle:SVR_READY_TIME(pack)
    dump(pack, '------广播用户可以准备了6009------')
    GAME_STATE = GAME_STATUS_STOP --准备阶段
    GamePlaneOperator:clearGameDatas(1)
    GamePlaneOperator:clearGameDatas(2)

    if GAME_TYPE == 5 then
        ControlPlaneOperator:showOptClock(pack.time)
    end
end

--广播玩家准备 用户准备了返回
function NiuNiuReceiveHandle:SVR_READY_BROADCAST(pack)
    dump(pack, '------广播玩家准备6001------')

    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    local readyState = pack.readyState --1是准备，0是取消准备

    if playerType then
        if readyState == 0 then
            GamePlaneOperator:setReadyStatus(playerType, false)
        else
            GamePlaneOperator:setReadyStatus(playerType, true)
        end
    end

    if pack.uid == USER_INFO['uid'] then
        if readyState == 0 then
            GamePlaneOperator:showControlButtons(1)
        else
            GamePlaneOperator:showControlButtons(1, false)
        end
    end

    if readyState == 0 then
        USERS_READY_STATE[pack.uid] = 0
    else
        USERS_READY_STATE[pack.uid] = 1
    end
end

----------------------------------------------------------------------------------------
--所有人都已准备，广播可以开始游戏
function NiuNiuReceiveHandle:SERVER_COMMAND_REMAID_START_GAME()
    GamePlaneOperator:RemaidStartGame(true)
    GamePlaneOperator:clearGameDatas(1)
    GamePlaneOperator:clearGameDatas(2)
end

--有人未准备，隐藏开始游戏按钮
function NiuNiuReceiveHandle:SERVER_COMMAND_REMAID_START_GAME_FAIL()
    GamePlaneOperator:RemaidStartGame(false)
end

--广播游戏开始 6002
function NiuNiuReceiveHandle:SVR_BROADCAST_GAME_START(pack)
    -----------------------------游戏开始-------------------------------
    dump(pack, 'SVR_BROADCAST_GAME_START')
    ControlPlaneOperator:setUpBankBtnVisible(false)
    GamePlaneOperator:showSitDownButton(false) --隐藏坐下按钮
    NIUNIU_SCENE:showShareButton(false) --隐藏分享按钮
    GamePlaneOperator:RemaidStartGame(false) --隐藏开始按钮
    GamePlaneOperator:clearAllReadyStatus() --游戏开始后清除准备状态
    FIRSTSENDCARD = true --重置发牌变量
    if USERS_READY_STATE[USER_INFO['uid']] == 0 then --如果我在游戏开始时不在准备状态的话，进入旁观模式
        GamePlaneOperator:showAudienceBrand(true)
    end
    ----------------------------------
    local cardEndIndex = pack.send_card_num or 4
    local dealCardIndex = 1
    GAME_PARTICIPANTS = {}
    for uid, ready_state in pairs(USERS_READY_STATE) do
        if ready_state == 1 then
            table.insert(GAME_PARTICIPANTS, uid)
        end
    end
    local isRelogin = pack.isRelogin
    if GAME_CONFIG['买牛'] == true then
        if isRelogin == true then
            local user_datas = pack.user_datas
            for _, data in ipairs(user_datas) do
                local seatId = data.seatId
                local cards = data.cards
                Lottery:dealCards(seatId, cards, 'cover')
                local playerType = NIUNIU_PLAYERTYPE_TABLE_BYSEAT[seatId]
                if playerType and seatId ~= MY_SEAT_ID and cardEndIndex > 0 then
                    GamePlaneOperator:showDealCardsAnimation(playerType, cards, cardEndIndex, isRelogin, 'cover')
                end
            end
        else
            local user_datas = pack.user_datas
            for _, data in pairs(user_datas) do
                local seatId = data.seatId
                local cards = data.cards
                Lottery:dealCards(seatId, cards, 'cover')
                local playerType = NIUNIU_PLAYERTYPE_TABLE_BYSEAT[seatId]
                if playerType and seatId ~= MY_SEAT_ID and cardEndIndex > 0 then
                    NIUNIU_SCENE:performWithDelay(
                        function()
                            GamePlaneOperator:showDealCardsAnimation(playerType, cards, cardEndIndex, nil, 'cover')
                        end,
                        dealCardIndex * 0.05
                    )
                    dealCardIndex = dealCardIndex + 1
                end
            end
        end
    else
        if isRelogin == true then
            for _, uid in ipairs(GAME_PARTICIPANTS) do
                local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
                if playerType and uid ~= USER_INFO['uid'] and cardEndIndex > 0 then
                    GamePlaneOperator:showDealCardsAnimation(playerType, nil, cardEndIndex, isRelogin)
                end
            end
        else
            for _, uid in ipairs(GAME_PARTICIPANTS) do
                local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
                if playerType and uid ~= USER_INFO['uid'] and cardEndIndex > 0 then
                    NIUNIU_SCENE:performWithDelay(
                        function()
                            GamePlaneOperator:showDealCardsAnimation(playerType, nil, cardEndIndex)
                        end,
                        dealCardIndex * 0.05
                    )
                    dealCardIndex = dealCardIndex + 1
                end
            end
        end
    end
    local lepers = pack.lepers or {}
    if pack.hasLeper == 2 then
        GamePlaneOperator:showTableLaizi(lepers[1])
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------
--庄家相关
--广播开始抢庄（游戏开始，第一阶段）
function NiuNiuReceiveHandle:SVR_BEGIN_QIANFGZHUANG_BROADCAST(pack)
    dump(pack, '-----广播开始抢庄6015-----')

    --棋牌进行中
    GAME_STATE = GAME_STATUS_GRAB

    local time = pack.time

    Lottery:remainStageProgress(time, 'grabGameBanker')
    if GAME_TYPE == 5 then
        ControlPlaneOperator:showOptClock(time)
    else
        GamePlaneOperator:startTimer(time, '抢庄阶段')
    end

    if USERS_READY_STATE[USER_INFO['uid']] ~= 1 then
        GamePlaneOperator:showControlButtons(1, false)
        return
    end

    if pack.time <= -3 or GAME_TYPE_NAME == '通比牛牛' then --没有此阶段
        return
    end

    local exsits = false

    local my_can_grab_times
    local canGrabDealer = 0

    for i, data in pairs(pack.ids) do
        local uid

        if type(data) == 'table' then
            uid = data.uid
            if USER_INFO['uid'] == uid then
                --当前自己已经抢庄
                exsits = true
                my_can_grab_times = data.can_grab_times
                canGrabDealer = data.canGrabDealer
            end
        else
            uid = data
            if USER_INFO['uid'] == uid then
                --当前自己已经抢庄
                if JAVA_DOUNIU then
                    my_can_grab_times = pack.can_grab_times
                    canGrabDealer = pack.canGrabDealer
                else
                    canGrabDealer = pack.can_grab_times
                end
                exsits = true
            end
        end
    end

    if GROUP_MODE == 2 then
        if my_can_grab_times then
            table.insert(pack.grab_times, 1, 0)
            table.insert(my_can_grab_times, 1, 0)
            GamePlaneOperator:loadGrabBankerButtons(pack.grab_times, JAVA_DOUNIU and my_can_grab_times or pack.can_grab_times, canGrabDealer)
        else
            local grab_times = {0, 1}
            local can_grab_times
            if exsits then
                can_grab_times = {0, 1}
            else
                can_grab_times = {0}
            end

            GamePlaneOperator:loadGrabBankerButtons(grab_times, can_grab_times, can_grab_times)
        end

        --显示推注的情况
        if pack.canTuizhu ~= nil then
            for k, v in pairs(pack.canTuizhu) do
                local playerType = NIUNIU_PLAYERTYPE_TABLE[v.uid]
                GamePlaneOperator:setMaxTuizhuTimes(playerType, v.max_tuizhu, true)
            end
        end
    else
        if my_can_grab_times then
            table.insert(my_can_grab_times, 1, 0)
            GamePlaneOperator:loadGrabBankerButtons(my_can_grab_times, my_can_grab_times)
        else
            local grab_times = {0, 1}
            local can_grab_times
            if exsits then
                can_grab_times = {0, 1}
            else
                can_grab_times = {0}
            end

            GamePlaneOperator:loadGrabBankerButtons(grab_times, can_grab_times)
        end
    end

    GamePlaneOperator:showControlButtons(2)
end

--处理抢庄  广播抢庄情况6013
function NiuNiuReceiveHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack)
    dump(pack, '------广播玩家抢庄6013-----')
    local uid = pack.uid

    if uid == USER_INFO['uid'] then
        GamePlaneOperator:showControlButtons(2, false)
        GamePlaneOperator:showStageTxt('等待其他玩家操作...')
    end

    local grabTimes = pack.if_qiang

    if grabTimes > 0 then
        local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
        RANDOM_BANKER[uid] = grabTimes
        GamePlaneOperator:setGrabBankerSymbol(playerType)
        GamePlaneOperator:setGrabBankerTimes(playerType, grabTimes)
        if NIUNIU_USERINFO_TABLE[pack.uid] then
            SoundUtils:playCardKindEffect('qiangzhuang', NIUNIU_USERINFO_TABLE[pack.uid].sex)
        end
    else
        if NIUNIU_USERINFO_TABLE[pack.uid] then
            SoundUtils:playCardKindEffect('buqiang', NIUNIU_USERINFO_TABLE[pack.uid].sex)
            GamePlaneOperator:setGrabBankerTimes(NIUNIU_PLAYERTYPE_TABLE[pack.uid], grabTimes)
        end
    end
end

--- 准备阶段    ----- 抢庄阶段 ------  加倍阶段 -----  出牌阶段

-- 准备按钮 ----- 已准备（隐藏准备按钮） ---  开始游戏按钮 -----  抢庄面板（隐藏开始游戏按钮）
---- 隐藏抢庄面板 -----  显示加倍面板 ----  隐藏加倍面板 ---- 显示出牌面板 ------ 隐藏出牌面板 ------ 准备按钮

--广播庄家id
function NiuNiuReceiveHandle:SVR_BRANK_BROADCAST(pack)
    dump(pack, '------广播庄家id 6003-----')

    if pack.uid == -1 or GAME_TYPE_NAME == '通比牛牛' then
        return
    end

    local broadcast_banker_delay = 0.1

    BANKER_UID = pack.uid
    if GAME_TYPE == 5 then
        ControlPlaneOperator:setReadyBtnVisible(true)
    else
        GamePlaneOperator:showControlButtons(2, false)
    end

    local BankerPlayerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]

    GamePlaneOperator:stopTimer()

    --隐藏抢庄标记
    GamePlaneOperator:clearGrabBankerSymbol()

    if GAME_TYPE == 1 then
        local grab_bankers = {}

        if table.nums(RANDOM_BANKER) == 0 then
            GamePlaneOperator:showRandomBankerChoose(GAME_PARTICIPANTS)
            broadcast_banker_delay = TOTAL_PLAYERNUM * 0.1
            -- GamePlaneOperator:startTimer(2,"抢庄阶段")
            GamePlaneOperator:showStageTxt('随机庄家中...')
        else
            local highest = 1
            for uid, times in pairs(RANDOM_BANKER) do
                if times > highest then
                    highest = times
                    grab_bankers = {}
                    table.insert(grab_bankers, uid)
                elseif times == highest then
                    table.insert(grab_bankers, uid)
                end
            end

            GamePlaneOperator:showRandomBankerChoose(grab_bankers)

            if #grab_bankers > 1 then
                broadcast_banker_delay = #grab_bankers * 0.1
                -- GamePlaneOperator:startTimer(2,"抢庄阶段")
                GamePlaneOperator:showStageTxt('随机庄家中...')
            end
        end
    end

    if GAME_TYPE == 5 then
        g_mainScene.curGuodi = pack.guodi
        -- g_mainScene.bFristBet = true
        ControlPlaneOperator:showGuodiNodeVisible()
        ControlPlaneOperator:setGuodiScore(pack.guodi)
    -- g_mainScene.curGuoJusize = 0
    -- ControlPlaneOperator:setGuoJusize(g_mainScene.curGuoJusize)
    end

    RANDOM_BANKER = {}

    SCENENOW['scene']:performWithDelay(
        function()
            if GAME_TYPE_NAME ~= '定庄牛牛' then
                GamePlaneOperator:showBankerChoose(pack.uid)
                -- SoundUtils:playEffect('定庄特效')
            end

            --清除抢庄失败的人的抢庄倍数
            for playerType = 1, TOTAL_PLAYERNUM do
                if playerType ~= BankerPlayerType then
                    GamePlaneOperator:setGrabBankerTimes(playerType, 0, false)
                end
            end

            GamePlaneOperator:showStageTxt('等待闲家加倍...')

            GamePlaneOperator:clearBankerFlag() --出现了一个莫名其妙的显示两个庄家的BUG，于是现在在确定前先把所有的庄家标记删了
            --显示庄
            local size = NIUNIU_SCENE:getContentSize()
            local pos = cc.p(size.width / 2, size.height / 2)
            -- GamePlaneOperator:showHeadSymbol(BankerPlayerType,"banker",true)
            self:createArmature('niuniu_zhuang', pos, pack.uid, BankerPlayerType)

            -- NIUNIU_SCENE:updateRoomInfo(nil,pack.uid)

            Lottery:remainStageProgress(time, 'gameBet')
        end,
        broadcast_banker_delay
    )
end

--骨骼动画
function NiuNiuReceiveHandle:createArmature(name, pos, uid, BankerPlayerType)
    local armatureObj = NIUNIU_SCENE:getChildByName(name)
    if armatureObj then
        armatureObj:stopAllActions()
        local Animation = armatureObj:getAnimation()
        Animation:gotoAndPause(0)
        armatureObj:removeSelf()
    end

    local path1 = TpackageName .. '/csb/GameSceneSector/dingzhuangAnimiation/' .. name
    local effectManage = ccs.ArmatureDataManager:getInstance()
    effectManage:addArmatureFileInfo(path1 .. '0.png', path1 .. '0.plist', path1 .. '.ExportJson')

    local armatureObj = ccs.Armature:create(name)
    armatureObj:setAnchorPoint(cc.p(0.5, 0.5))
    armatureObj:getAnimation():playWithIndex(0, -1, 0) --第一个参数是动画表index 第二个是时间间隔第三个是是否循环
    armatureObj:setPosition(pos)
    armatureObj:setName(name)
    NIUNIU_SCENE:addChild(armatureObj)
    if name == 'dingzhuang' and BankerPlayerType ~= CARD_PLAYERTYPE_MY then
        armatureObj:setScale(0.6)
    end
    function handler1(Armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
            if name == 'dingzhuang' then
                GamePlaneOperator:showHeadSymbol(BankerPlayerType, 'banker', true)
                Armature:removeSelf()
            else
                local pos = PLAYER_BANKER_POSITION_TABLE[uid]
                if pos then
                    local duration = 0.2
                    local spawn_action =
                        cc.Spawn:create(
                        cc.MoveTo:create(duration, pos),
                        cc.FadeOut:create(duration),
                        cc.ScaleTo:create(duration, 0.2, 0.2)
                    )
                    armatureObj:runAction(
                        cc.Sequence:create(
                            spawn_action,
                            cc.CallFunc:create(
                                function()
                                    GamePlaneOperator:showHeadSymbol(BankerPlayerType, 'banker', true)
                                    -- self:createArmature('dingzhuang', pos, uid, BankerPlayerType)
                                end
                            ),
                            cc.RemoveSelf:create()
                        )
                    )
                end
            end
        end
    end
    if tolua.isnull(armatureObj) == false then
        armatureObj:getAnimation():setMovementEventCallFunc(handler1)
        armatureObj:stopAllActions()
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------
--倍数相关
--处理加倍
function NiuNiuReceiveHandle:SVR_SEND_BASES_TO_USER_BROADCAST(pack)
    dump(pack, '-----向特定用户发送可翻倍的数值列表7001-----')

    GAME_STATE = GAME_STATUS_TIMES

    if pack.time <= -3 or GAME_TYPE_NAME == '通比牛牛' then --没有此阶段
        -- require("hall.GameTips"):showTips("提示", "", 3, "阶段时间错误")
        dump(pack.time, '阶段时间错误')
        return
    end

    if USERS_READY_STATE[USER_INFO['uid']] ~= 1 then
    --require("hall.GameTips"):showTips("提示", "", 3, "我不在准备状态")
    --return
    end
    if GAME_TYPE == 5 then
        ControlPlaneOperator:showOptClock(pack.time)
    else
        GamePlaneOperator:startTimer(pack.time, '加倍阶段')
    end

    --显示玩家自己可以选择的倍数
    if BANKER_UID ~= USER_INFO['uid'] then
        GamePlaneOperator:showControlButtons(3)
    end

    if pack.can_selects_base then
        GamePlaneOperator:loadBetButtons(pack.selects_base, pack.can_selects_base, pack.tuiZhuBase)
    else
        GamePlaneOperator:loadBetButtons(pack.selects_base)
    end

    dump(pack.canTuizhu, 'pack.canTuizhu=-----=')
    if pack.canTuizhu ~= nil then
        for k, v in pairs(pack.canTuizhu) do
            local playerType = NIUNIU_PLAYERTYPE_TABLE[v.uid]
            GamePlaneOperator:setMaxTuizhuTimes(playerType, v.max_tuizhu, true)
        end
    end
end

--广播加倍倍数
function NiuNiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack)
    dump(pack, '-----广播加倍倍数6014-----')
    dump(pack.tuizhu, '-----广播加倍pack.tuizhu-----')

    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    local isTuiZhu = pack.tuizhu
    GamePlaneOperator:setBetTimes(playerType, pack.base, nil, isTuiZhu)

    if pack.uid == USER_INFO['uid'] then
        if GAME_CONFIG['买牛'] ~= true then
            GamePlaneOperator:showStageTxt('等待其他玩家加倍...')
        end
        if GAME_TYPE == 5 then
            ControlPlaneOperator:setBetBtnVisible(false)
        else
            GamePlaneOperator:showControlButtons(3, false)
        end
    end
    local config_arr = string.split(baseChip, '/')
    local base = tonumber(config_arr[#config_arr])
    if GAME_TYPE == 5 then
        if pack.isSheMen == 1 then
            SoundUtils:playCardKindEffect('tuizhu', NIUNIU_USERINFO_TABLE[pack.uid].sex)
        end
    elseif base and pack.base and (pack.base > base) then
        SoundUtils:playCardKindEffect('tuizhu', NIUNIU_USERINFO_TABLE[pack.uid].sex)
    end
end

--广播外围开始抢庄 110C
function NiuNiuReceiveHandle:SVR_BROADCAST_BEGIN_GRAB_WW_DEALER(pack)
    Lottery:openCards()
    for _, uid in ipairs(GAME_PARTICIPANTS) do
        local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
        GamePlaneOperator:openCards(playerType)
    end

    local bankerSeatId = NIUNIU_SEAT_TABLE[BANKER_UID]
    local LotteryGrabCountdown = pack.waiwei_grab_time or 5

    Lottery:remainStageProgress(LotteryGrabCountdown, 'grabBanker')
    if GAME_TYPE == 5 then
        ControlPlaneOperator:showOptClock(LotteryGrabCountdown)
    else
        GamePlaneOperator:startTimer(LotteryGrabCountdown, '外围抢庄阶段')
    end

    if bankerSeatId then
        Lottery:showGrabBankerBtn(bankerSeatId)
    end
end

--广播外围庄家id 110A
function NiuNiuReceiveHandle:SVR_BROADCAST_GRAB_WW_DEALER(pack)
    dump(pack, 'SVR_BROADCAST_GRAB_WW_DEALER')
    local waiwei_banker_uid = pack.waiwei_banker_uid
    local waiwei_bet_time = pack.waiwei_bet_time or 20 --pack.waiwei_bet_time
    local waiwei_bet_limit_times = pack.waiwei_bet_limit_times or 10

    local waiwei_banker_userinfo = {}

    waiwei_banker_userinfo['uid'] = waiwei_banker_uid

    if waiwei_banker_uid ~= 0 then
        waiwei_banker_userinfo = NIUNIU_USERINFO_TABLE[waiwei_banker_uid] or {}
    end
    if GAME_TYPE == 5 then
        ControlPlaneOperator:showOptClock(waiwei_bet_time)
    else
        GamePlaneOperator:startTimer(waiwei_bet_time, '外围下注阶段')
    end

    Lottery:setBetLimit(BASE_CHIP, waiwei_bet_limit_times)
    Lottery:stopStageProgress('grabBanker')
    Lottery:showGrabResult(waiwei_banker_userinfo)
    Lottery:remainStageProgress(waiwei_bet_time, 'bet')
    Lottery:openBet()
end

---------------------------------------------------------------------------------------------------------------------------------------------
--发牌相关
--处理发牌协议 4001 (第一次发标志着游戏的开始)
function NiuNiuReceiveHandle:SVR_SEND_USER_CARD(pack)
    dump(pack, '------发送用户的牌信息4001------')

    -- dump(debug.traceback(),"追踪4001的来源")
    dump(FIRSTSENDCARD, '4001FIRSTSENDCARD')
    -- dump(debug.traceback(),"SVR_SEND_USER_CARD_DEBUG_RECONNECT")
    if FIRSTSENDCARD then
        if GAME_TYPE == 5 then
            ControlPlaneOperator:setUpBankBtnVisible(false)
            ControlPlaneOperator:showBetBtnScore()
            ControlPlaneOperator:showOptClock(10) --服务器叫分等待时间就是10s
        end
    end
    --服务器牌前后两次发来的顺序并不一致，注意每次收到牌都把所有牌重新画一次
    if FIRSTSENDCARD then
        USED_CARDS = {}

        local userCards = {}

        LIANGCARDNUM = 0
        MY_CARDS = {}

        if pack.users and next(pack.users) and isOpenControl == true then
            for i, data in ipairs(pack.users) do
                userCards[data.seat_id] = data.cards
                for _, card in ipairs(data.cards) do
                    table.insert(USED_CARDS, card)
                end
            end

            local myControlCards = userCards[MY_SEAT_ID]
            for _, card in ipairs(myControlCards) do
                table.insert(MY_CARDS, card)
                if card ~= 0 then
                    LIANGCARDNUM = LIANGCARDNUM + 1
                end
            end

            for _, uid in ipairs(GAME_PARTICIPANTS) do
                local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
                if playerType and playerType ~= CARD_PLAYERTYPE_MY then
                    local seat_id = NIUNIU_SEAT_TABLE[uid]
                    local cards = userCards[seat_id]

                    -- Lottery:dealCards(seatId, cards)
                    GamePlaneOperator:showDealCardsAnimation(playerType, cards, 5)
                end
            end
        else
            for i, card in ipairs(pack.cards) do
                table.insert(MY_CARDS, card)
                if card ~= 0 then
                    LIANGCARDNUM = LIANGCARDNUM + 1
                end
            end
        end

        local seatId = NIUNIU_SEAT_TABLE[USER_INFO['uid']]
        Lottery:dealCards(seatId, MY_CARDS)
        GamePlaneOperator:showCards(CARD_PLAYERTYPE_MY, MY_CARDS, FIRSTSENDCARD, pack.isRelogin)

        FIRSTSENDCARD = false
    else
        ------------------------------------
        MY_CARDS = {}

        for i, card in ipairs(pack.cards) do
            table.insert(MY_CARDS, card)
        end
        -----------------------------------

        local seatId = NIUNIU_SEAT_TABLE[USER_INFO['uid']]
        Lottery:dealCards(seatId, MY_CARDS)
        GamePlaneOperator:showCards(CARD_PLAYERTYPE_MY, pack.cards, FIRSTSENDCARD)
    end
end

-----------------------------------------------------------------------------------------------------------

function NiuNiuReceiveHandle:SVR_SEND_USED_CARDS(pack)
    USED_CARDS = pack.cards
end

--出牌相关
--广播出牌阶段开始
function NiuNiuReceiveHandle:SVR_PLAY_CARD_BROADCAST(pack)
    dump(pack, '-----广播玩家开始出牌6004-----')
    --显示阶段信息
    GAME_STATE = GAME_STATUS_OUTCARD --棋牌进行中

    local time = pack.time or 5
    local cardEndIndex = 5

    Lottery:stopStageProgress('bet')
    Lottery:remainStageProgress(time, 'checkCard')

    if USERS_READY_STATE[USER_INFO['uid']] == 1 then
        GamePlaneOperator:showControlButtons(4) --隐藏抢分
    end

    for _, uid in ipairs(GAME_PARTICIPANTS) do
        local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
        if playerType and uid ~= USER_INFO['uid'] then
            dump(playerType, '出牌阶段给玩家发最后几张牌')
            GamePlaneOperator:showDealCardsAnimation(playerType, nil, cardEndIndex)
            GamePlaneOperator:showCardKind(playerType, -1) --显示盖牌文字
        end
    end
    if GAME_TYPE == 5 then
        ControlPlaneOperator:showOptClock(time)
    else
        GamePlaneOperator:startTimer(time, '出牌阶段')
    end
end

--玩家出牌
function NiuNiuReceiveHandle:SVR_USER_PLAYED_CARDS_BROADCAST(pack)
    dump(pack, '-----玩家出牌6005-----')
    ---用于记录所有玩家对应出过的牌，牌的大小
    NIUNIUKIND[pack.uid] = pack.kind
    NIUNIU_OUTCARDS[pack.uid] = pack.cards
    local card = pack.card
    GAME_STATE = GAME_STATUS_OUTCARD

    local uid = pack.uid
    local seatId = NIUNIU_SEAT_TABLE[uid]
    local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]

    if uid == USER_INFO['uid'] then
        --清除搓牌
        require(TpackageName .. '.LayerShuffling'):removeScene()
        GamePlaneOperator:showControlButtons(5, false)
        GamePlaneOperator:showStageTxt('等待其他玩家出牌...')

        if HAS_OPEN_CARD_UIDS[uid] ~= true then
            HAS_OPEN_CARD_UIDS[uid] = true
            SoundUtils:playCardKindEffect(pack.kind)
        end

        GamePlaneOperator:outCard(playerType, pack.cards, card)
    else
        GamePlaneOperator:outCard(playerType, pack.cards, card)
        if NIUNIU_USERINFO_TABLE[uid] then
            SoundUtils:playCardKindEffect(pack.kind, NIUNIU_USERINFO_TABLE[uid].sex) --播放牌型音效
        end
    end

    Lottery:dealCards(seatId, pack.cards)
    Lottery:showCardType(seatId, pack.kind)

    GamePlaneOperator:showCardKind(playerType, pack.kind) --显示盖牌文字  NIUNIU_CARDTYPE_TABLE[pack.kind]
end

--1043玩家开始摊牌
function NiuNiuReceiveHandle:SVR_OPEN_CARDS_BROADCAST(pack)
    local totalOpenCardTime = pack.openCardTime

    GamePlaneOperator:showStageTxt('比牌中...')
    -- Lottery:shieldBet()
    Lottery:remainStageProgress(totalOpenCardTime, 'compare')
end

---------------------------------------------------------------------------------------------------------------------------------------------
--扣除台费 4800
function NiuNiuReceiveHandle:SVR_CHIP_CHANGE_BROADCAST(pack)
    local change_chip = 0
    for _, data in pairs(pack.userinfo) do
        local uid = data.uid
        local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
        local oriChip = NIUNIU_USERINFO_TABLE[uid].coins
        local chip = oriChip + data.change_chip
        NIUNIU_USERINFO_TABLE[uid].coins = chip

        GamePlaneOperator:setCoin(playerType, chip)

        if uid == USER_INFO['uid'] then
            -- --GamePlaneOperator:showTaiFeiTips(data.change_chip)
        end
    end
end

--结算
function NiuNiuReceiveHandle:SVR_SETTLEMENT_BROADCAST(pack)
    dump(
        pack,
        '-----牛牛结算6008---------===========================================================================---------------------===========================--'
    )

    FIRSTSENDCARD = true

    RELOGIN_FLAG = false

    -- Lottery:remainStageProgress(0,"showResult")
    -- BONUS_POOL_COINS  =  pack.bonusPool  --更新奖池

    GAME_STATE = GAME_STATUS_STOP --棋牌结束

    if MY_SEAT_ID and MY_SEAT_ID < 0 then --当自己没有坐下的时候才显示坐下
        GamePlaneOperator:showSitDownButton(true)
    end

    for uid, _ in pairs(USERS_READY_STATE) do --重置所有玩家的准备状态
        USERS_READY_STATE[uid] = 0
    end

    if GAME_TYPE == 5 then
        -- g_mainScene.guodiScore = pack.guodi
        g_mainScene.curGuodi = pack.guodi
        g_mainScene.bFristBet = false
        ControlPlaneOperator:setGuodiScore(pack.guodi)
    end

    local tbWin = {}

    local showCardDelay = 0.5

    local delaySettleTime = 0 -- 0.5 * (#pack.userinfo) + 0.5

    --庄家分数
    local BankerPlayerType = NIUNIU_PLAYERTYPE_TABLE[pack.banker_uid]
    tbWin[pack.banker_uid] = pack.banker_win_chip
    if NIUNIU_USERINFO_TABLE[pack.banker_uid] then
        NIUNIU_USERINFO_TABLE[pack.banker_uid].coins = pack.banker_chips
    end

    --闲家分数
    for i, data in pairs(pack.userinfo) do
        local playerType = NIUNIU_PLAYERTYPE_TABLE[data.uid]
        tbWin[data.uid] = data.win_chip
        if NIUNIU_USERINFO_TABLE[data.uid] then
            NIUNIU_USERINFO_TABLE[data.uid].coins = data.chips
        end
    end

    GamePlaneOperator:stopTimer()
    GamePlaneOperator:clearGameDatas(1)

    local settlementDelay = 3

    if GAME_CONFIG['买牛'] == true then
        settlementDelay = 5
    end

    HAS_OPEN_CARD_UIDS = {}

    --先亮牌，延迟两秒后结算
    NIUNIU_SCENE:performWithDelay(
        function()
            GamePlaneOperator:showCoinFlyAnimation(pack.banker_uid, tbWin, 'game')

            Lottery:delayCallShowBetResult()

            Lottery:remainStageProgress(0, 'wait')

            -- NiuNiuSendHandle:CLI_COMMAND_REQ_WAIWEI_RESULT()  --请求外围结果

            -- NIUNIU_SCENE:performWithDelay(function()

            --     --胜利失败动画
            --     if tbWin[USER_INFO["uid"]] and tbWin[USER_INFO["uid"]] > 0 then
            --         GamePlaneOperator:showGameEndAnimation(true)
            --     elseif tbWin[USER_INFO["uid"]] and tbWin[USER_INFO["uid"]] <= 0 then
            --         GamePlaneOperator:showGameEndAnimation(false)
            --     end

            -- end,1)

            NIUNIU_SCENE:performWithDelay(
                function()
                    if not (NIUNIU_SCENE and NIUNIU_SCENE.initData) then
                        return
                    end
                    if SCENENOW['name'] == run_scene_name then
                        if MY_SEAT_ID >= 0 and RELATIVE_SEAT_ID ~= MY_SEAT_ID then --自己已经坐下，但是是在游戏期间坐下的
                            RELATIVE_SEAT_ID = MY_SEAT_ID
                            GamePlaneOperator:clearGameDatas(2)
                            NiuNiuUtils:relocatePlayer()
                        end
                        GamePlaneOperator:hideTableLaizi()

                        CHECK_WAIWEI_RESULT_ABLE = false

                        -- GamePlaneOperator:clearGameDatas(2)
                        NIUNIU_SCENE:initData('clearGameData')

                        if GAME_TYPE == 5 or GAME_ROUND < GAME_TOTAL_ROUND then
                            GamePlaneOperator:showStageTxt('等待游戏开始...')
                            --我不在准备状态且坐下了
                            if
                                (USERS_READY_STATE[USER_INFO['uid']] and USERS_READY_STATE[USER_INFO['uid']] ~= 1 and
                                    MY_SEAT_ID >= 0) or
                                    g_isWatch == 0
                             then
                                -- if GAME_TYPE == 5 then
                                GamePlaneOperator:clearGameDatas(2)
                                -- end
                                GamePlaneOperator:showControlButtons(1)
                            end

                            NIUNIU_SCENE:showShareButton(true)
                        else
                            GamePlaneOperator:showStageTxt('')

                            local GameResult = NIUNIU_SCENE:getChildByName('gameresultScene')
                            if GameResult then
                                GameResult:setVisible(true)
                            end
                        end
                    end
                end,
                settlementDelay
            )
        end,
        delaySettleTime
    )
end

--牛牛组局排行榜 5100
function NiuNiuReceiveHandle:SVR_GROUP_BILLBOARD(pack)
    dump(pack, '-----牛牛组局排行榜5100-----')
    dump(GAME_ROUND, '-----牛牛组局排行榜GAME_ROUND-----')

    GamePlaneOperator:showStageTxt('')
    NIUNIU_SCENE:performWithDelay(
                function()
                    NiuNiuUtils:showResult(pack)
                end,
                3)

    HAS_RECEIVE_GROUP_RESULT = true

    NIUNIU_SCENE:showShareButton(false)
    GamePlaneOperator:showCheckResultButton(true)
end

--------------------------------------周边功能-----------------------------------------
--组局解散相关
--没有此房间，解散房间失败
function NiuNiuReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)
    --dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")
    require('hall.GameTips'):showTips('提示', 'disbandGroup_fail', 2, '解散房间失败')
end

--广播当前组局解散情况
function NiuNiuReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)
    dump(pack, '-----广播当前组局解散情况-----')
    dump(NIUNIU_USERINFO_TABLE, '-----广播当前房间情况-----')
    if g_isWatch == 0 then
        return
    end
    local applyId = pack.applyId
    local agreeNum = pack.agreeNum
    local agreeMember_arr = pack.agreeMember_arr

    local disband_table = {}

    --申请解散者信息
    if applyId == USER_INFO['uid'] then
        local player_table = {}
        player_table['playerName'] = '我'
        player_table['state'] = '申请'
        table.insert(disband_table, player_table)
    else
        local player_table = {}
        local applyer_info = NIUNIU_USERINFO_TABLE[applyId]
        dump(applyer_info, '-----广播当前房间情况applyer_info-----')
        if applyer_info ~= nil then
            local nickName = applyer_info.nick or ''
            if nickName ~= nil then
                player_table['playerName'] = nickName
            else
                player_table['playerName'] = tostring(applyId)
            end
        else
            player_table['playerName'] = tostring(applyId)
        end

        player_table['state'] = '申请'

        table.insert(disband_table, player_table)
    end

    local isMyAgree = 0
    if applyId ~= USER_INFO['uid'] then
        --假如申请者不是自己，添加自己的选择情况
        if agreeNum > 0 then
            for k, v in pairs(agreeMember_arr) do
                if v == USER_INFO['uid'] then
                    isMyAgree = 1
                    break
                end
            end
        end

        local player_table = {}
        player_table['playerName'] = '我'

        if isMyAgree == 1 then
            player_table['state'] = '同意'
        else
            player_table['state'] = '等待选择'
        end

        player_table['icon'] = USER_INFO['icon_url']

        table.insert(disband_table, player_table)
    end

    --显示其他人情况
    for k, v in pairs(NIUNIU_USERINFO_TABLE) do
        dump(v, '-----显示其他人情况-----')
        local uid = v.uid
        --排除掉申请者，申请者不需要显示到这里
        if uid ~= applyId and uid ~= USER_INFO['uid'] then
            --记录当前用户是否已经同意
            local isAgree = 0
            if agreeNum > 0 then
                for k, v in pairs(agreeMember_arr) do
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
                player_table['playerName'] = nickName

                if isAgree == 1 then
                    player_table['state'] = '同意'
                else
                    player_table['state'] = '等待选择'
                end

                player_table['icon'] = v.icon_url

                table.insert(disband_table, player_table)
            end
        end
    end

    local function agree_disband(value)
        NiuNiuSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(value)
    end

    if applyId == USER_INFO['uid'] then
        --假如申请者是自己，则直接显示其他用户的选择情况
        require('hall.GameTips'):showDisbandNewTips('提示', 'agree_disbandGroup', 4, disband_table)
    else
        --申请者不是自己，根据自己的同意情况进行界面显示

        if isMyAgree == 1 then
            require('hall.GameTips'):showDisbandNewTips('提示', 'agree_disbandGroup', 4, disband_table)
        else
            require('hall.GameTips'):showDisbandNewTips(
                '提示',
                'new_request_disbandGroup',
                1,
                disband_table,
                agree_disband
            )
        end
    end
end

--广播桌子用户请求解散组局
function NiuNiuReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)
    --dump(pack, "-----广播桌子用户请求解散组局-----")
    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")
end

--广播桌子用户成功解散组局
function NiuNiuReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)
    --dump(pack, "-----广播桌子用户成功解散组局-----")

    bm.isDisbandSuccess = true

    if isGoldGame == 0 then
        require('hall.GameCommon'):gExitGroupGame(USER_INFO['enter_mode'], CLUB_ID)
    end

    -- require("hall.GameTips"):showDisbandTips("解散房间成功","ddz_disbandGroup_success",3)
end

--广播桌子用户解散组局 ，解散组局失败
function NiuNiuReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)
    --dump(pack, "-----广播桌子用户解散组局 ，解散组局失败-----")

    local rejectId = pack.rejectId
    if rejectId == USER_INFO['uid'] then
        require('hall.GameTips'):showDisbandTips('解散房间失败', 'disbandGroup_fail', 0, '您拒绝解散房间')
    else
        local nickName = NIUNIU_USERINFO_TABLE[rejectId].nick or '路人甲'
        require('hall.GameTips'):showDisbandTips('解散房间失败', 'disbandGroup_fail', 0, nickName .. '拒绝解散房间')
    end
end

--聊天
function NiuNiuReceiveHandle:SVR_MSG_FACE(pack)
    local s = NIUNIU_SCENE:getChildByName('faceUI')

    local sex = 1

    if NIUNIU_USERINFO_TABLE[pack.uid] then
        sex = NIUNIU_USERINFO_TABLE[pack.uid].sex or 0
    end

    local isLeft = false

    local node_head = PLAYER_HEADS_TABLE[pack.uid]
    if tonumber(sex) >= 0 and node_head then
        s:showGetFace(pack.uid, pack.type, tonumber(sex), node_head, false)
    end
end

--通知庄家升庄 1110
function NiuNiuReceiveHandle:SERVER_NOTIFY_UP_BANK(pack)
    dump(pack, '-----通知庄家升庄 1110-----')
    if g_isWatch == 1 then
        if USER_INFO['uid'] == pack.banker_uid then
            ControlPlaneOperator:setUpBankBtnVisible(true, pack.state)
        else
            local data = {type = 3, title = '', content = '庄家正在选择升庄!'}
            require('hall.tips.CommonTips'):showTips(data)
        end
    end
end

--广播玩家升庄 0x2014
function NiuNiuReceiveHandle:SERVER_BROADCAST_UP_BANK(pack)
    if GAME_TYPE == 5 then
        g_mainScene.baseGuodi = pack.guodi
        g_mainScene.curGuodi = pack.guodi
        g_mainScene.bFristBet = true
        g_mainScene.m_nGuoCount = pack.m_nGuoCount
        ControlPlaneOperator:showGuodiNodeVisible()
        ControlPlaneOperator:setGuodiScore(pack.guodi)
        if GAME_ROUND > 1 then
            g_mainScene.curGuoJusize = 0
        end
        -- ControlPlaneOperator:setGuoJusize(g_mainScene.curGuoJusize)
        if USER_INFO['uid'] == pack.banker_uid then
            ControlPlaneOperator:setUpBankBtnVisible(false)
        end
    end
end

--广播新锅 0x2015
function NiuNiuReceiveHandle:SERVER_BROADCAST_NEW_GUO(pack)
    if GAME_TYPE == 5 then
        g_mainScene.baseGuodi = pack.guodi
        g_mainScene.curGuodi = pack.guodi
        g_mainScene.bFristBet = true
        ControlPlaneOperator:showGuodiNodeVisible()
        ControlPlaneOperator:setGuodiScore(pack.guodi)
        g_mainScene.m_nGuoCount = pack.m_nGuoCount
        if GAME_ROUND > 1 then
            g_mainScene.curGuoJusize = 0
        end
        if USER_INFO['uid'] == pack.banker_uid then
            ControlPlaneOperator:setUpBankBtnVisible(false)
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------
function NiuNiuReceiveHandle:showTextMessage(pack)
    local s = NIUNIU_SCENE:getChildByName('faceUI')

    local sex = 1

    if NIUNIU_USERINFO_TABLE[pack.uid] then
        sex = NIUNIU_USERINFO_TABLE[pack.uid].sex or 0
    end

    local node_head = PLAYER_HEADS_TABLE[pack.uid]

    s:showGetText(pack.uid, pack.textMessage, tonumber(sex), node_head, false)
end

function NiuNiuReceiveHandle:showExpression(msg)
    local uid_from = tonumber(msg['uid_from'])
    local uid_to = tonumber(msg['uid_to'])
    local expressionType = tonumber(msg['expressionType']) or 1

    --屏蔽和围观玩家有关的互动表情
    if (NIUNIU_SEAT_TABLE[uid_from] or -1) < 0 or (NIUNIU_SEAT_TABLE[uid_to] or -1) < 0 then
        return
    end
    ---------------------------------不同游戏需修改的部分----------------------------
    -- --通过UID获取seat_id
    -- local seat_id_from = USERID2SEAT[uid_from] or 2
    -- local seat_id_to =  USERID2SEAT[seat_id_to] or 0

    --制定座位号对应的动画播放起始和结束的大概位置
    ------------------------------------------------------------------------------------
    local playerHeadPosition_from = PLAYER_HEADS_POSITION_TABLE[uid_from] or {x = 0, y = 0}

    local from_x = playerHeadPosition_from.x
    local from_y = playerHeadPosition_from.y

    local playerHeadPosition_to = PLAYER_HEADS_POSITION_TABLE[uid_to] or {x = 0, y = 0}
    local to_x = playerHeadPosition_to.x
    local to_y = playerHeadPosition_to.y

    require('hall.view.animView.animView'):ShowAnimationByPosition(from_x, from_y, to_x, to_y, expressionType)
end

--接收服务器发来的距离数据
function NiuNiuReceiveHandle:SERVER_CMD_FORWARD_MESSAGE(pack)
    dump(pack, '-------距离数据---------')
    local msgList = pack.msgList
    --存放距离数据的数组

    for k, v in pairs(msgList) do
        if v and v ~= '' then
            local msg = json.decode(v)
            if msg and msg.uid then
                dump(msg, '更新对应玩家的数据')
                require('hall.view.userInfoView.userInfoView'):upDateUserInfo(msg.uid, msg)
            end
        end
    end
end

--接收服务器返回的组局信息
function NiuNiuReceiveHandle:SERVER_CMD_MESSAGE(pack)
    if bm.isInGame == false then
        return
    end

    local msg = json.decode(pack.msg)
    --dump(msg, "-----NiuNiuReceiveHandle 接收服务器返回的组局信息-----")
    if msg ~= nil then
        local msgType = msg.msgType
        if msgType ~= nil and msgType ~= '' then
            if msgType == 'expression' then --表情
                self:showExpression(msg)
            elseif msgType == 'text' then --文字聊天
                self:showTextMessage(msg)
            elseif msgType == 'EmojiArmatureView' then --动态表情
                self:SVR_MSG_EMOJI_ARMATURE(msg)
            elseif msgType == 'emoji' then --文字聊天
                self:SVR_MSG_FACE(msg)
            end

            if device.platform == 'ios' then
                if msgType == 'voice' then
                    --dump("voice", "-----接收服务器返回的组局信息-----")

                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                    require('hall.view.voicePlayView.voicePlayView'):showView(msg.uid, msg.voiceTime)

                    --通知本地播放录音
                    local arr = {}
                    arr['url'] = msg.url
                    cct.getDateForApp('playVoice', arr, 'V')
                elseif msgType == 'video' then
                    --dump("video", "-----接收服务器返回的组局信息-----")

                    local arr = {}
                    arr['url'] = msg.url
                    cct.getDateForApp('playVideo', arr, 'V')
                end
            else
                if msgType == 'voice' then
                    --dump("voice", "-----接收服务器返回的组局信息-----")
                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                    require('hall.view.voicePlayView.voicePlayView'):showView(msg.uid, msg.voiceTime)

                    --通知本地播放录音

                    local data = {}
                    data['url'] = msg.url

                    local arr = {}
                    table.insert(arr, json.encode(data))
                    cct.getDateForApp('playVoice', arr, 'V')
                elseif msgType == 'video' then
                    --dump("video", "-----接收服务器返回的组局信息-----")

                    local data = {}
                    data['url'] = msg.url

                    local arr = {}
                    table.insert(arr, json.encode(data))
                    cct.getDateForApp('playVideo', arr, 'V')
                end
            end
        end
    end
end

function NiuNiuReceiveHandle:SVR_MSG_EMOJI_ARMATURE(pack)
    local EmojiArmatureView = SCENENOW.scene:getChildByName('EmojiArmatureView')
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

--请求下注情况返回 1039
function NiuNiuReceiveHandle:SERVER_CMD_BONUS_RECORD(pack)
    local bonus_record = pack.bonus_record

    for i, data in pairs(bonus_record) do
        local uid = data.uid
        local seatId = NIUNIU_SEAT_TABLE[uid]

        local my_bet_count = data.my_bet_count
        local total_bet_count = data.total_bet_count

        Lottery:setMyBet(seatId, my_bet_count)
        Lottery:setTotalBet(seatId, total_bet_count)
    end
end

--110B 广播外围结果
function NiuNiuReceiveHandle:BROADCAST_WAIWEI_RESULT(pack)
    Lottery:storeBetResultData(pack.betResult)
end

--110E
function NiuNiuReceiveHandle:SVR_REMAID_4WW(pack)
    local typ = pack.typ
    local value = pack.value

    -- { [1] = "金币不足"
    -- }

    -- if typ == 1 then
    require('hall.GameTips'):showTips('提示', '', 3, '由于您参与内围游戏，您的积分数目不能低于' .. value)
    -- end
end

--下注总情况返回 1106
function NiuNiuReceiveHandle:SVR_CMD_REQ_YAZHU_INFO(pack)
    dump(pack, 'SVR_CMD_REQ_YAZHU_INFO')

    local waiwei_banker_uid = pack.waiwei_banker_uid
    local remainTime = pack.remainTime
    local players_bet_situation = pack.players_bet_situation

    if waiwei_banker_uid < 0 then --外围抢庄阶段  -- -2加倍,-1抢庄，
        local bankerSeatId = NIUNIU_SEAT_TABLE[BANKER_UID]
        Lottery:remainStageProgress(remainTime, 'grabBanker')
        if GAME_TYPE == 5 then
            ControlPlaneOperator:showOptClock(remainTime)
        else
            GamePlaneOperator:startTimer(remainTime, '外围抢庄阶段')
        end

        Lottery:showGrabBankerBtn(bankerSeatId)

        if waiwei_banker_uid == -1 then
            Lottery:openCards()
            for _, uid in ipairs(GAME_PARTICIPANTS) do
                local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
                GamePlaneOperator:openCards(playerType)
            end
        end
    else --外围下注阶段
        Lottery:openCards()
        for _, uid in ipairs(GAME_PARTICIPANTS) do
            local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
            GamePlaneOperator:openCards(playerType)
        end

        if remainTime > 0 then
            local bankerSeatId = NIUNIU_SEAT_TABLE[BANKER_UID]

            local waiwei_banker_userinfo = {}

            waiwei_banker_userinfo['uid'] = waiwei_banker_uid

            if waiwei_banker_uid ~= 0 then
                waiwei_banker_userinfo = NIUNIU_USERINFO_TABLE[waiwei_banker_uid]
            end
            if GAME_TYPE == 5 then
                ControlPlaneOperator:showOptClock(remainTime)
            else
                GamePlaneOperator:startTimer(remainTime, '外围下注阶段')
            end

            Lottery:setBankerSeatId(bankerSeatId)
            Lottery:stopStageProgress('grabBanker')
            Lottery:showGrabResult(waiwei_banker_userinfo)
            Lottery:remainStageProgress(remainTime, 'bet')
            Lottery:openBet()
        end
    end

    for _, data in pairs(players_bet_situation) do
        local uid = data.uid
        local seatId = data.seatId
        local total_bet_count = data.total_bet_count
        local my_bet_count = data.my_bet_count

        Lottery:setMyBet(seatId, my_bet_count)
        Lottery:setTotalBet(seatId, total_bet_count)
    end
end

--座位下注详情 1107
function NiuNiuReceiveHandle:SVR_CMD_REQ_YAZHU_DETAILS(pack)
    dump(pack, 'SVR_CMD_REQ_YAZHU_DETAILS')

    local seatId = pack.seatId
    local players_bet_situation = pack.players_bet_situation

    for _, data in ipairs(players_bet_situation) do
        local bet_count = data.bet_count
        local bet_uid = data.bet_uid

        Lottery:updateBetDatas(seatId, bet_uid, bet_count)
    end

    Lottery:showBetDetails(seatId, minusData)
end

--广播下注 1040
function NiuNiuReceiveHandle:BROADCAST_USER_BET(pack)
    dump(pack, 'BROADCAST_USER_BET')
    local uid = pack.uid --被押注人的UID
    local seatId = NIUNIU_SEAT_TABLE[uid]

    local bet_uid = pack.bet_uid --押注人的UID

    local costCoins = pack.costCoins

    NIUNIU_USERINFO_TABLE[bet_uid].coins = pack.bet_player_chip --NIUNIU_USERINFO_TABLE[uid].coins - costCoins

    local playerChip = pack.bet_player_chip --NIUNIU_USERINFO_TABLE[uid].coins

    local playerType = NIUNIU_PLAYERTYPE_TABLE[bet_uid]

    if playerType then
        GamePlaneOperator:setCoin(playerType, playerChip)
    end

    local my_bet_count = pack.my_bet_count
    local total_bet_count = pack.total_bet_count

    if bet_uid == USER_INFO['uid'] then
        Lottery:setMyBet(seatId, my_bet_count)
    end

    Lottery:setTotalBet(seatId, total_bet_count)

    Lottery:updateBetDatas(seatId, bet_uid, costCoins)
    Lottery:updateBetSituation(seatId, bet_uid, costCoins)
end

--请求录纸返回 1035
function NiuNiuReceiveHandle:SERVER_CMD_RECORD_PAPER(pack)
    local record_paper = pack.record_paper
    Lottery:showPaper(record_paper)
end

---------------------------------------------------------------------------------------------------

--接收服务器放回的指定用户信息pack111
function NiuNiuReceiveHandle:SVR_CHARGE_BROADCAST(pack)

    local uid = pack.uid
    local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
    local userInfo = NIUNIU_USERINFO_TABLE[uid]
    if not (playerType and userInfo) then
        return
    end
    
    userInfo.coins = userInfo.coins + pack.chargeCoins
    -- GamePlaneOperator:setCoin(playerType, userInfo.coins)
    GamePlaneOperator:updateCoinUserChips(playerType, pack.chargeCoins)
     
end

--回看
function NiuNiuReceiveHandle:SERVER_COMMAND_GAMERESULT_RECORD(pack)
    dump(pack, 'SERVER_COMMAND_GAMERESULT_RECORD')
    if #pack.gameResult == 0 then
        viewMgr:showTip({text = '无当前所选局数回看！'})
        return
    end
    local Card = require(TpackageName .. '.PokerCard')
    for i, userInfo in ipairs(pack.gameResult) do
        for idx, value in ipairs(userInfo.cards) do
            local cardNode = Card.new()
            cardNode:setCard(value)
            cardNode:showFront()
            pack.gameResult[i].cards[idx] = cardNode
        end
        local cardKind_imgPath = CARDTYPE_IMAGE_PATH[userInfo.cardType]
        pack.gameResult[i].cardType = cardKind_imgPath
        pack.gameResult[i].cardType_plist = 1 --1是plist 0不是
    end

    local CardsRoundRecord = SCENENOW['scene']._scene:getChildByName('CardsRoundRecord')
    if CardsRoundRecord then
        CardsRoundRecord:setData(pack)
    else
        local CardsRoundRecord = require('hall.common.CardsRoundRecord').new(pack)
        CardsRoundRecord:setName('CardsRoundRecord')
        CardsRoundRecord:setHandler(handler(NiuNiuSendHandle, NiuNiuSendHandle.CLI_COMMAND_GAMERESULT_RECORD))
        local zidx = ViewBase:getZOrderByChilds(SCENENOW['scene']._scene)
        CardsRoundRecord:addTo(SCENENOW['scene']._scene, zidx)
    end
end

return NiuNiuReceiveHandle
