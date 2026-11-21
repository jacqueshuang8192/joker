local hallHandle = require('hall.HallHandle')
local PROTOCOL = import(TpackageName .. '.handle.SanGongProtocol')
local SanGongReceiveHandle = class('SanGongReceiveHandle', hallHandle)
local StakeScene = require(TpackageName .. '.StakeScene')
local LowerScoreScene = require(TpackageName .. '.LowerScoreScene')

function SanGongReceiveHandle:ctor()
    SanGongReceiveHandle.super.ctor(self)

    local func_ = {
        --进入游戏成功 0210
        --[PROTOCOL.SVR_GET_ROOM_OK] = {handler(self, SanGongReceiveHandle.SVR_GET_ROOM_OK)},
        --登录房间成功 1007
        [PROTOCOL.SVR_LOGIN_ROOM] = {handler(self, SanGongReceiveHandle.SVR_LOGIN_ROOM)},
        --进入房间失败
        [PROTOCOL.SVR_LOGIN_ROOM_FAIL] = {handler(self, SanGongReceiveHandle.SVR_LOGIN_ROOM_FAIL)},
        --广播其他用户坐下（金币场） 1031
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, SanGongReceiveHandle.BROADCAST_USER_SIT_DOWN)},
        --广播用户退出房间 1032
        [PROTOCOL.BROADCAST_USER_STAND_UP] = {handler(self, SanGongReceiveHandle.BROADCAST_USER_STAND_UP)},
        --广播其他用户登录桌子 100D
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, SanGongReceiveHandle.SVR_LOGIN_ROOM_BROADCAST)},
        --广播用户退出房间 100E
        [PROTOCOL.SVR_QUIT_ROOM] = {handler(self, SanGongReceiveHandle.SVR_QUIT_ROOM)},
        --广播用户退出房间 1033
        [PROTOCOL.BROADCAST_USER_QUIT_ROOM] = {handler(self, SanGongReceiveHandle.BROADCAST_USER_QUIT_ROOM)},
        --用户退出房间成功（自己）
        [PROTOCOL.SVR_QUICK_SUC] = {handler(self, SanGongReceiveHandle.SVR_QUICK_SUC)},
        --0x2001    --广播用户准备
        [PROTOCOL.SERVER_READYNOW_ROOM] = {handler(self, SanGongReceiveHandle.SERVER_READYNOW_ROOM)},
        --错误提示5001
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, SanGongReceiveHandle.BROADCAST_ERROR_TIPS)},
        --广播用户托管1034
        [PROTOCOL.BROADCAST_USER_AUTO_PLAY] = {handler(self, SanGongReceiveHandle.BROADCAST_USER_AUTO_PLAY)},
        --广播剩余时间100F
        [PROTOCOL.SVR_BROADCAST_COUNT_DOWN] = {handler(self, SanGongReceiveHandle.SVR_BROADCAST_COUNT_DOWN)},
        --发牌 4001
        [PROTOCOL.SVR_SEND_USER_CARD] = {handler(self, SanGongReceiveHandle.SVR_SEND_USER_CARD)},
        --6005  广播玩家出牌

        --1043  广播玩家摊牌
        [PROTOCOL.SVR_OPEN_CARDS_BROADCAST] = {handler(self, SanGongReceiveHandle.SVR_OPEN_CARDS_BROADCAST)},
        --111 广播玩家充值
        [PROTOCOL.SVR_CHARGE_BROADCAST] = {handler(self, SanGongReceiveHandle.SVR_CHARGE_BROADCAST)},
        --6008  单局结算（阶段广播）
        [PROTOCOL.SVR_SETTLEMENT_BROADCAST] = {handler(self, SanGongReceiveHandle.SVR_SETTLEMENT_BROADCAST)},
        --5100，广播总结算
        [PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, SanGongReceiveHandle.SVR_GROUP_BILLBOARD)},
        --广播当前回合
        [PROTOCOL.SVR_GROUP_TIME] = {handler(self, SanGongReceiveHandle.SVR_GROUP_TIME)},
        --请求带控返回
        [PROTOCOL.SERVER_CMD_REQ_TEST] = {handler(self, SanGongReceiveHandle.SERVER_CMD_REQ_TEST)},
        --请求牌值返回
        [PROTOCOL.SERVER_CMD_TEST] = {handler(self, SanGongReceiveHandle.SERVER_CMD_TEST)},
        --请求录纸返回
        [PROTOCOL.SERVER_CMD_RECORD_PAPER] = {handler(self, SanGongReceiveHandle.SERVER_CMD_RECORD_PAPER)},
        --解散相关
        --没有此房间，解散房间失败
        [PROTOCOL.G2H_CMD_DISSOLVE_FAILED] = {handler(self, SanGongReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},
        --广播桌子用户请求解散组局
        [PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {
            handler(self, SanGongReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)
        },
        --广播当前组局解散情况
        [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST] = {handler(self, SanGongReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
        --广播桌子用户成功解散组局
        [PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP] = {
            handler(self, SanGongReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)
        },
        --广播桌子用户解散组局 ，解散组局失败
        [PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP] = {
            handler(self, SanGongReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)
        },
        --文字聊天相关
        --[PROTOCOL.SVR_MSG_FACE]     = {handler(self, SanGongReceiveHandle.SVR_MSG_FACE)},
        --接收服务器返回的语音表情视频文字 0214
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, SanGongReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},
        --接收服务器返回801
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, SanGongReceiveHandle.SERVER_CMD_MESSAGE)},
        -- 0x110A   --- 出牌时间
        [PROTOCOL.SERVER_BROADCAST_START_OUT_CARD] = {
            handler(self, SanGongReceiveHandle.SERVER_BROADCAST_START_OUT_CARD)
        },
        -- --接收IP信息 106A
        -- [PROTOCOL.BROADCAST_USER_IP] = {handler(self, SanGongReceiveHandle.BROADCAST_USER_IP)},

        [PROTOCOL.SERVER_NOTIFY_RESULT] = {handler(self, SanGongReceiveHandle.SERVER_NOTIFY_RESULT)},
        [PROTOCOL.SERVER_BROADCAST_START_YA] = {handler(self, SanGongReceiveHandle.SERVER_BROADCAST_START_YA)},
        -- 0x1101   --- 广播押注
        [PROTOCOL.SERVER_BROADCAST_YA] = {handler(self, SanGongReceiveHandle.SERVER_BROADCAST_YA)},
        --0x1102
        [PROTOCOL.SERVER_BROADCAST_CARD] = {handler(self, SanGongReceiveHandle.SERVER_BROADCAST_CARD)},
        [PROTOCOL.SERVER_BROADCAST_OUT_CARD] = {handler(self, SanGongReceiveHandle.SERVER_BROADCAST_OUT_CARD)},
        --0x1104   --- 开牌
        [PROTOCOL.SERVER_BROADCAST_OPEN_CARD] = {handler(self, SanGongReceiveHandle.SERVER_BROADCAST_OPEN_CARD)},
        [PROTOCOL.SERVER_CMD_REQ_YAZHU_INFO] = {handler(self, SanGongReceiveHandle.SERVER_CMD_REQ_YAZHU_INFO)},
        [PROTOCOL.SERVER_CMD_REQ_YAZHU_DETAILS] = {handler(self, SanGongReceiveHandle.SERVER_CMD_REQ_YAZHU_DETAILS)},
        [PROTOCOL.SERVER_BROADCAST_GIVE_COINS] = {handler(self, SanGongReceiveHandle.SERVER_BROADCAST_GIVE_COINS)},
        --0x1109--单局结算
        [PROTOCOL.SERVER_BROADCAST_WINLOSE_COUNT] = {handler(self, SanGongReceiveHandle.SERVER_BROADCAST_WINLOSE_COUNT)},
        --显示开始游戏按钮显示开始游戏按钮 0x2006
        [PROTOCOL.SERVER_BROADCAST_START_GAME] = {handler(self, SanGongReceiveHandle.SERVER_BROADCAST_START_GAME)},
        -- --广播剩余时间1100
        [PROTOCOL.SVR_BROADCAST_WAIT_START] = {handler(self, SanGongReceiveHandle.SVR_BROADCAST_WAIT_START)},
        -- --广播开始准备 6009 （阶段广播）
        [PROTOCOL.SVR_READY_TIME] = {handler(self, SanGongReceiveHandle.SVR_READY_TIME)},
        -- --广播用户准备 6001
        [PROTOCOL.SVR_READY_BROADCAST] = {handler(self, SanGongReceiveHandle.SVR_READY_BROADCAST)},
        --发送剩余手牌
        [PROTOCOL.SVR_SEND_USED_CARDS] = {handler(self, SanGongReceiveHandle.SVR_SEND_USED_CARDS)},
        --告知庄家可以开始游戏
        [PROTOCOL.SERVER_COMMAND_REMAID_START_GAME] = {
            handler(self, SanGongReceiveHandle.SERVER_COMMAND_REMAID_START_GAME)
        },
        --告知庄家不可以开始游戏
        [PROTOCOL.SERVER_COMMAND_REMAID_START_GAME_FAIL] = {
            handler(self, SanGongReceiveHandle.SERVER_COMMAND_REMAID_START_GAME_FAIL)
        },
        --广播游戏开始
        [PROTOCOL.SVR_BROADCAST_GAME_START] = {handler(self, SanGongReceiveHandle.SVR_BROADCAST_GAME_START)},
        --广播开始抢庄（阶段广播）
        [PROTOCOL.SVR_BEGIN_QIANFGZHUANG_BROADCAST] = {
            handler(self, SanGongReceiveHandle.SVR_BEGIN_QIANFGZHUANG_BROADCAST)
        },
        --广播抢庄过程
        [PROTOCOL.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST] = {
            handler(self, SanGongReceiveHandle.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST)
        },
        --广播庄家
        [PROTOCOL.SVR_BRANK_BROADCAST] = {handler(self, SanGongReceiveHandle.SVR_BRANK_BROADCAST)},
        --6014 广播加倍倍数
        [PROTOCOL.SVR_USER_BASES_RESULT_BROADCAST] = {
            handler(self, SanGongReceiveHandle.SVR_USER_BASES_RESULT_BROADCAST)
        },
        --1041 下注剩余时间
        [PROTOCOL.BROADCAST_SENDCARD_REMAINDTIME] = {handler(self, SanGongReceiveHandle.BROADCAST_SENDCARD_REMAINDTIME)},
        --6004 广播玩家开始出牌（阶段广播）
        [PROTOCOL.SVR_PLAY_CARD_BROADCAST] = {handler(self, SanGongReceiveHandle.SVR_PLAY_CARD_BROADCAST)},
        --4008 广播玩家钱数变化（用于扣取台费）
        [PROTOCOL.SVR_CHIP_CHANGE_BROADCAST] = {handler(self, SanGongReceiveHandle.SVR_CHIP_CHANGE_BROADCAST)},
        --结算0x1105
        [PROTOCOL.SERVER_BROADCAST_RESULT] = {handler(self, SanGongReceiveHandle.SERVER_BROADCAST_RESULT)},
        --0x1050回看
        [PROTOCOL.SERVER_COMMAND_GAMERESULT_RECORD] = {
            handler(self, SanGongReceiveHandle.SERVER_COMMAND_GAMERESULT_RECORD)
        }
        --接收服务器放回的指定用户信息pack111
        -- [PROTOCOL.SERVER_CMD_HALL_GET_MESSAGE] = {handler(self, SanGongReceiveHandle.SERVER_CMD_HALL_GET_MESSAGE)},
    }

    table.merge(self.func_, func_)
end

--协议返回数据接收

--协议返回数据接收
function SanGongReceiveHandle:callFunc(pack)
    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

--结算0x1105
function SanGongReceiveHandle:SERVER_BROADCAST_RESULT(pack)
    dump(pack, '-----结算0x1105-----')
end

--显示开始游戏按钮 0x2006
function SanGongReceiveHandle:SERVER_BROADCAST_START_GAME(pack)
    dump(pack, '-----显示开始游戏按钮-----')
    if pack.star_game_uid == USER_INFO.uid then
        local playerType = SANGONG_PLAYERTYPE_TABLE[pack.star_game_uid]
        if playerType then
            GamePlaneOperator:setReadyStatus(playerType, false)
        end
        GamePlaneOperator:RemaidStartGame(true)
    end
end

--进入房间失败
function SanGongReceiveHandle:SVR_LOGIN_ROOM_FAIL(pack)
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
        [16] = '密码错误',
        [17] = '要求携带钻石不足',
        [18] = '游戏已开始，无法加入游戏'
    }

    if tbErrorCode[pack.errorCode] then
        if pack.errorCode == 18 or pack.errorCode == 7 or pack.errorCode == 5 then
            --require("hall.GameTips"):showTips("提示", "tohall", 1, tbErrorCode[pack.errorCode])
            -- elseif  pack.errorCode == 7 or pack.errorCode == 5 then

            local exitFunc = function()
                require('hall.GameCommon'):gExitGroupGame(USER_INFO['enter_mode'])
            end

            require('hall.GameTips'):showTips('提示', '', 2, tbErrorCode[pack.errorCode], nil, exitFunc)
        else
            require('hall.GameTips'):showTips('提示', '', 1, tbErrorCode[pack.errorCode])
        end
    else
        require('hall.GameTips'):showTips('提示', '', 1, '未知的错误')
    end
end

--登录房间 1007
function SanGongReceiveHandle:SVR_LOGIN_ROOM(pack)
    if tolua.isnull(SanGongScene) or not SanGongScene.initGameView then
        return
    end
    g_360 = {}
    require(NetworkLoadingView_filePath):removeView(888)
    USER_INFO['activity_id'] = pack.activityId
    USER_INFO['invote_code'] = pack.inviteCode
    if pack.club_id > 0 then
        CLUB_ID = pack.club_id
        USER_INFO['family_id'] = pack.club_id
    end
    GAME_STATE = pack.tableStatus
    GAME_LOGIN_DATA = pack
    g_isWatch = pack.isWatch
    dump(pack, '-----SanGongReceiveHandle 三公登录房间 1007-----')

    self:SERVER_BROADCAST_START_GAME(pack)
    BASE_CHIP = pack.baseChip
    local gameConfig = pack.gameConfig
    local baseChip = pack.baseChip
    local gameConfig_string = USER_INFO['gameConfig'] or ''
    g_sangongMainScene.gameConfig = gameConfig

    initialChip = pack.initialChip / 100
    maxChip = pack.times / 100

    isGoldGame = pack.gamePattern
    USERS_READY_STATE[USER_INFO['uid']] = 0
    HEART_BEAT_TID = USER_INFO['tid']

    SanGongScene:initGameView()

    GamePlaneOperator:initPlayerPlane(TOTAL_PLAYERNUM) --TOTAL_PLAYERNUM
    local gameConfigTable = json.decode(gameConfig)


    if g_isWatch == 0 then
        GamePlaneOperator:setGuanZhanVisible(true) --观战
    end


    if gameConfigTable['times'] then
        baseChip = gameConfigTable['times']
    end
    g_360.anCard = gameConfigTable.anCard
    -- --GAME_CHIP_CONFIG = gameConfigTable["times"]:split(",")
    -- GAME_CHIP_CONFIG = {}
    -- for i,v in ipairs(pack.timesArr) do
    --     table.insert( GAME_CHIP_CONFIG, v/100)
    -- end

    --提取规则玩法数据
    local ruleplayerdata = {}
    ruleplayerdata.players = gameConfigTable.maxSeatCount
    ruleplayerdata.base = gameConfigTable.times
    ruleplayerdata.startCount = gameConfigTable.startCount
    _G.RULE_PLAYER_DATA = ruleplayerdata

    if not isNewLowerScore then
        StakeScene:init()
    end
    -- RoundEnding:init()
    -- GamePlaneOperator:clearGameDatas(1)
    -- GamePlaneOperator:clearGameDatas(2)

    if MY_SEAT_ID >= 0 then
        RELATIVE_SEAT_ID = MY_SEAT_ID
        SanGongScene:showButtonAfterSitDown(true)
        local seat_id = MY_SEAT_ID
        local uid = USER_INFO['uid']
        local userInfo = SANGONG_USERINFO_TABLE[USER_INFO['uid']]
        local user_if_outline = 1
        SanGongUtils:showPlayer(uid, seat_id, userInfo, user_if_outline)
    else --没准备或者是围观
        RELATIVE_SEAT_ID = 0
    end

    SanGongScene:updateRoomInfo(baseChip, GAME_TYPE_NAME, pack.inviteCode, nil, nil, gameConfig_string)
    SanGongScene:registShareButtons(pack.inviteCode)

    --根据人数更换界面布局
    SanGongScene:switchBackGroundGrid(TOTAL_PLAYERNUM)

    --SanGongScene:showWaiWeiButton(false)

    --SanGongScene:showShareButton(false)

    ---------------------------------显示信息---------------------------------------
    local myUserInfo = {}
    myUserInfo['ready'] = 0
    myUserInfo['seat'] = -1
    myUserInfo['uid'] = USER_INFO['uid']
    myUserInfo['gold'] = pack.gold
    myUserInfo['nick'] = USER_INFO['nick']
    myUserInfo['sex'] = USER_INFO['sex']
    myUserInfo['icon_url'] = USER_INFO['icon_url']
    myUserInfo['latitude'] = USER_INFO['latitude']
    myUserInfo['longitude'] = USER_INFO['longitude'] or '' .. '-' .. (USER_INFO['LocalCity'] or '')
    myUserInfo['ip'] = USER_INFO['ip']
    GAME_PARTICIPANTS = {}
    SanGongUtils:collectPlayerData(myUserInfo)
    myUserInfo['gold'] = SanGongUtils:goldMath(pack.gold)
    GamePlaneOperator:showMyPlayerInfo(myUserInfo, 1, 111)
    for _, v in pairs(pack.gamePlayerArr) do
        SanGongUtils:collectPlayerData(v)
    end
    local selfUserInfo = {}
    for i, v in ipairs(pack.gamePlayerArr) do
        local uid = v.uid
        local userInfo = SANGONG_USERINFO_TABLE[uid]
        local user_if_outline = v.onLine
        -- local playerType = SanGongUtils:getPlayerTypeBySeatId(v.seat)
        --SANGONG_PLAYERTYPE_COUNT[playerType] = v.count
        SanGongUtils:showPlayer(uid, v.seat, userInfo, user_if_outline)
        --GamePlaneOperator:setTotalBetChip(SANGONG_PLAYERTYPE_TABLE[uid], v.totalGold/100)
        --GamePlaneOperator:setSeatGold(SANGONG_SEAT_TABLE[v.uid]+1, v.totalGold/100)
        --GamePlaneOperator:showSitDownButton(v.seat+1,false)
        if v.ready > 0 then
            USERS_READY_STATE[v.uid] = 1
        else
            USERS_READY_STATE[v.uid] = 0
        end
        if uid == USER_INFO.uid then
            selfUserInfo = v
        end
    end

    if GAME_STATE == GAME_STATUS_STOP then --牌局结束
        GamePlaneOperator:startTimer(0, '准备开始：')
        self:setBtnReady()
        self:SERVER_BROADCAST_START_GAME(pack)
    elseif GAME_STATE == GAME_STATUS_YA then --押注阶段
        pack.time = pack.outCardAniTime
        local isShowXiaZhu = true
        local userInfo = SANGONG_USERINFO_TABLE[USER_INFO['uid']]
        if userInfo.totalGold >= 1 then --下过注了
            isShowXiaZhu = false
        end
        self:SERVER_BROADCAST_CARD(pack, true, nil, '下过时间', isShowXiaZhu)
    elseif GAME_STATE == GAME_STATUS_SEND_CARD then --发牌
        -- GamePlaneOperator:startTimer(0,"看牌时间：")
        self:SERVER_BROADCAST_CARD(pack, true, nil, '发牌时间')
    elseif GAME_STATE == GAME_STATUS_OUT_CARD then ---出牌
        -- GamePlaneOperator:startTimer(0,"看牌时间：")
        self:SERVER_BROADCAST_CARD(pack, true, nil, '看牌时间')
        if selfUserInfo.user_status ~= 1 then
            -- GamePlaneOperator:showControlButtons(6)
            GamePlaneOperator:showControlButtons(4)
        end
    elseif GAME_STATE == GAME_STATUS_OPEN_CARD then --开牌阶段
        --self:SERVER_BROADCAST_OPEN_CARD(pack)
        GAME_STATE = GAME_STATUS_OPEN_KIND
        self:SERVER_BROADCAST_CARD(pack, true, true, '正在报牌：')
    elseif GAME_STATE == GAME_STATUS_WAIT_STOP then --等待停止时间
        GamePlaneOperator:startTimer(pack.outCardAniTime, '结算等待：')
        SanGongUtils:clearPlayerGold()
        self:setBtnReady()
    end

    for i, v in pairs(pack.gamePlayerArr) do
        local uid = v.uid
        local userInfo = SANGONG_USERINFO_TABLE[uid]
        if userInfo.totalGold >= 1 then --下过注了
            local playerType = SanGongUtils:getPlayerTypeBySeatId(v.seat)
            GamePlaneOperator:setBetTimes(playerType, userInfo.totalGold / 100)
        end
    end

    for i, v in pairs(pack.gamePlayerArr) do
        local uid = v.uid
        if uid == USER_INFO.uid and v.isAuto == 1 then
            g_sangongMainScene.tgLayer:showTg()
        end
    end
    -- SanGongSendHandle:CLIENT_CMD_REQ_YAZHU_INFO()

    ---------------------------------------------------------------------------------

    -- pack.tableStatus 的可能值
    -- 0 //牌局已结束
    -- 1 准备
    -- 2 等待用户抢庄
    -- 3 牌局开始
    -- 4 GRABDEALER
    -- 5 等待用户选择倍数
    -- 6 CALLTIMES
    -- 7 等待出牌
    -- 8 OUTCARD
    -- 9 ISSPECTATOR

    ----------------------------------------------------------------
    self:TIME_SHOW()

    --USERS_READY_STATE[USER_INFO["uid"]] = 1
end

function SanGongReceiveHandle:TIME_SHOW()
    --local updateTime = 5
    --
    --local updateInfo = cc.CallFunc:create(
    --	function()
    --        local nowtime = os.date("%m/%d %H:%M")
    --        SanGongPanel:getChildByName("hall_plane"):getChildByName("time_txt"):setString(nowtime)
    --	end)
    --
    --local seqAc = cc.Sequence:create(updateInfo,cc.DelayTime:create(updateTime))
    --SanGongPanel:getChildByName("hall_plane"):getChildByName("time_txt"):runAction(cc.RepeatForever:create(seqAc))
end

---------------------------------------------------------------------------------------------------------------

--广播用户登录桌子 100D   其他用户进入房间
function SanGongReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)
    dump(pack, '------广播用户登录桌子100D------')
    SanGongUtils:collectPlayerData(pack)

    -- local seat = pack.seat
    -- if  seat >= 0 then
    --     local uid =  pack.uid
    --     local userInfo = SANGONG_USERINFO_TABLE[uid]
    --     local user_if_outline = pack.user_if_outline
    --     SanGongUtils:showPlayer(uid,seat,userInfo,user_if_outline)
    -- end

    local playerType = SANGONG_PLAYERTYPE_TABLE[pack.uid]
    if playerType then
        GamePlaneOperator:showHeadSymbol(playerType, 'disconnect', false)
    end
end

--广播自己退出 1008
function SanGongReceiveHandle:SVR_QUICK_SUC(pack)
    dump('广播自己退出')
    --if  GROUP_MODE == 2 then
    --SanGongScene:reConnect()
    require('hall.HallServer'):loginGameNew(USER_INFO['GroupLevel'], USER_INFO['tid'], USER_INFO['activity_id'], 1)
    --  require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

    --end
    -- require("hall.ScoketGame"):showReloginTip()
end

--广播玩家退出返回（断线） 100E
function SanGongReceiveHandle:SVR_QUIT_ROOM(pack)
    dump(pack, '------广播玩家退出返回100E------')

    local playerType = SANGONG_PLAYERTYPE_TABLE[pack.uid]
    if playerType then
    --GamePlaneOperator:showHeadSymbol(playerType,"disconnect",true)
    end
end

-- --广播用户坐下 1031   其他用户进入房间
-- function  SanGongReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
--     dump(pack,"--广播用户坐下 1031   其他用户进入房间")
--     SANGONG_SEAT_TABLE[pack.uid] = pack.seat --保存用户座位与id映射
--     SanGongUtils:collectPlayerData(pack)
--     local seat = pack.seat
--     if  seat >= 0 then
--         local uid =  pack.uid
--         local userInfo = SANGONG_USERINFO_TABLE[uid]
--         if not isNewLowerScore then
--             StakeScene:showOnStake(pack)
--         end

--         if uid == USER_INFO["uid"] then
--             MY_SEAT_ID = seat
--             --if  GAME_STATE == GAME_STATUS_STOP then --游戏前加入重定位
--                 SanGongUtils:relocatePlayer()
--             --else
--             --    SanGongUtils:showPlayerAfter(uid,seat,userInfo,GAME_SEAT_DOWN)

--             --end

--         else
--             SanGongUtils:showPlayer(uid,seat,userInfo)
--         end
--         --GamePlaneOperator:showPlayerInfo(seat,userInfo,seat)
--         GamePlaneOperator:setTextNmuber(pack.seat+1, pack.count)
--     end
--    -- local playerType = SANGONG_PLAYERTYPE_TABLE[pack.uid]
--     --if  playerType thenf
--     --    GamePlaneOperator:showHeadSymbol(playerType,"disconnect",false)
--     --end
-- end

--广播用户坐下 1031   其他用户进入房间
function SanGongReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
    SANGONG_SEAT_TABLE[pack.uid] = pack.seat --保存用户座位与id映射

    PLAYERNUM = SanGongUtils:getPlayerNum() --先刷新全局人数
    local seat = pack.seat
    if seat >= 0 then
        local uid = pack.uid
        USER_INFO['latitude'] = pack.latitude
        USER_INFO['latitude'] = pack.longitude
        USER_INFO['ip'] = pack.ip
        SANGONG_USERINFO_TABLE[pack.uid].latitude = pack.latitude
        SANGONG_USERINFO_TABLE[pack.uid].longitude = pack.longitude
        SANGONG_USERINFO_TABLE[pack.uid].ip = pack.ip
        local userInfo = SANGONG_USERINFO_TABLE[uid]
        -- if  USER_INFO["uid"] == pack.uid then
        --     userInfo = USER_INFO
        --     -- seat = 1
        -- end
        local user_if_outline = 1
        SanGongUtils:showPlayer(uid, seat, userInfo, user_if_outline)
    end
    --重定位逻辑

    if USER_INFO['uid'] == pack.uid then --自己坐下的话重新排版布局
        MY_SEAT_ID = pack.seat
        SanGongScene:showButtonAfterSitDown(true)
        GamePlaneOperator:showSitDownButton(false)

        --重定位逻辑
        MY_SEAT_ID = pack.seat

        if GAME_STATE == GAME_STATUS_STOP then --游戏前加入重定位
            --SanGongUtils:relocatePlayer()
            RELATIVE_SEAT_ID = MY_SEAT_ID
            USERS_READY_STATE[USER_INFO['uid']] = 0
            self:setBtnReady()
            GamePlaneOperator:clearGameDatas(2)
        elseif RELATIVE_SEAT_ID == MY_SEAT_ID then
        --SanGongUtils:relocatePlayer()
        end

        SanGongUtils:relocatePlayer()
        if GAME_STATE == GAME_STATUS_STOP then --牌局结束
            GamePlaneOperator:startTimer(0, '准备开始：')
            self:setBtnReady()
            self:SERVER_BROADCAST_START_GAME(GAME_LOGIN_DATA)
        elseif GAME_STATE == GAME_STATUS_YA then --押注阶段
            GAME_LOGIN_DATA.time = GAME_LOGIN_DATA.outCardAniTime
            self:SVR_BROADCAST_WAIT_START(GAME_LOGIN_DATA)
        elseif GAME_STATE == GAME_STATUS_SEND_CARD then --发牌
            -- GamePlaneOperator:startTimer(0,"看牌时间：")
            self:SERVER_BROADCAST_CARD(GAME_LOGIN_DATA, true, nil, '发牌时间')
        elseif GAME_STATE == GAME_STATUS_OUT_CARD then ---出牌
            -- GamePlaneOperator:startTimer(0,"看牌时间：")
            self:SERVER_BROADCAST_CARD(GAME_LOGIN_DATA, true, nil, '看牌时间')
        elseif GAME_STATE == GAME_STATUS_OPEN_CARD then --开牌阶段
            --self:SERVER_BROADCAST_OPEN_CARD(pack)
            GAME_STATE = GAME_STATUS_OPEN_KIND
            self:SERVER_BROADCAST_CARD(GAME_LOGIN_DATA, true, true, '正在报牌：')
        elseif GAME_STATE == GAME_STATUS_WAIT_STOP then --等待停止时间
            GamePlaneOperator:startTimer(GAME_LOGIN_DATA.outCardAniTime, '结算等待：')
            SanGongUtils:clearPlayerGold()
            self:setBtnReady()
        end
    end

    local playerType = SANGONG_PLAYERTYPE_TABLE[pack.uid]
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
function SanGongReceiveHandle:BROADCAST_USER_STAND_UP(pack)
    dump(pack, '------广播玩家站起1032------')

    --if  HAS_RECEIVE_GROUP_RESULT == true then
    --    return
    --end

    local playerType = SANGONG_PLAYERTYPE_TABLE[pack.uid]
    -- SanGongUtils:returnPlayerType(SANGONG_PLAYERTYPE_TABLE[pack.uid])

    if playerType then
        GamePlaneOperator:removePlayer(playerType)
    end
    GamePlaneOperator:showSitDownButton(playerType, true)
    -- SanGongScene:showButtonAfterSitDown(false)
    SANGONG_SEAT_TABLE[pack.uid] = -1
    SANGONG_PLAYERTYPE_TABLE[pack.uid] = nil
    --[[    local seat = SANGONG_SEAT_TABLE[pack.uid]

    SANGONG_UID_TABLE[seat] = nil
    SANGONG_SEAT_TABLE[pack.uid] = -2

    PLAYERNUM = SanGongUtils:getPlayerNum()  --先刷新全局人数

    if  USER_INFO["uid"] == pack.uid then
        GamePlaneOperator:showControlButtons(1,false)
        GamePlaneOperator:showSitDownButton(true)

        SanGongScene:showButtonAfterSitDown(false)

    else  --
        if  SANGONG_SEAT_TABLE[USER_INFO["uid"]] --[[ < 0 then
            GamePlaneOperator:showSitDownButton(true)
        end
    end]]
end

--广播玩家退出返回（离开房间） 1033
function SanGongReceiveHandle:BROADCAST_USER_QUIT_ROOM(pack)
    dump(pack, '------广播玩家退出返回1033------')

    --if  HAS_RECEIVE_GROUP_RESULT == true then
    --    return
    --end

    local playerType = SANGONG_PLAYERTYPE_TABLE[pack.uid]
    -- SanGongUtils:returnPlayerType(SANGONG_PLAYERTYPE_TABLE[pack.uid])

    if playerType then
        GamePlaneOperator:removePlayer(playerType)
    --
    end

    if playerType and playerType >= 0 then
        GamePlaneOperator:showSitDownButton(playerType, true)
    end

    if SANGONG_UID_TABLE[SANGONG_SEAT_TABLE[pack.uid]] then
        SANGONG_UID_TABLE[SANGONG_SEAT_TABLE[pack.uid]] = nil
    end

    SANGONG_SEAT_TABLE[pack.uid] = nil
    SANGONG_USERINFO_TABLE[pack.uid] = nil
    SANGONG_PLAYERTYPE_TABLE[pack.uid] = nil
    if pack.uid == USER_INFO['uid'] then
        if isGoldGame == 0 or (isGoldGame == 1 and GAME_ROUND < GAME_TOTAL_ROUND and HAS_RECEIVE_GROUP_RESULT ~= true) then
            require('hall.GameCommon'):gExitGroupGame(USER_INFO['enter_mode'], CLUB_ID)
            HEART_BEAT_TID = 0
        end
    end
end

--1042
function SanGongReceiveHandle:showWaiWeiResult(data)
    dump(data, 'showWaiWeiResult')

    -- 界面测试代码
    --     local data = {
    --     {score = 35, nickName = "用户820104",uid = 10001},
    -- }

    --     local news = json.encode(data)
    --     local newfile = io.open("D:/work/hellouniverse/gameClient/trunk/sangong/gameConfig1.txt","w")
    --     newfile:write(news)
    --     newfile:close()
    -- local hall_plane = SANGONG_GAME_SCENE:getParent():getChildByName("hall_plane")
    -- local btn_switch_bet_mode = hall_plane:getChildByName("btn_switch_bet_mode")
    -- local btn_checkoutZ = btn_switch_bet_mode:getPositionZ()

    --获取总结算界面
    local s = SANGONG_GAME_SCENE:getParent():getChildByName('waiwei_plane')

    -- local s = SanGongScene:getChildByName("WaiWeiResult")
    if not s then
        return
    -- s = cc.CSLoader:createNode(TpackageName .. "/csb/------LotteryResult.csb"):addTo(SanGongScene)
    end

    -- s:setPositionZ(btn_checkoutZ - 1)
    -- s:setName("WaiWeiResult")
    -- s:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
    s:setVisible(false)

    local title = s:getChildByName('title')
    title:setString('投注结算')
    local mask = s:getChildByName('mask')
    mask:addTouchEventListener(
        function(sender, event)
            if event == TOUCH_EVENT_ENDED then
                s:setVisible(false)
            end
        end
    )

    --结果显示区域
    local content_sv = s:getChildByName('content_sv')
    local content_ly = content_sv:getChildByName('content_ly')

    --定义结果分项
    local result_Item = s:getChildByName('group_ending_box')

    local result_Item_position_index = 1

    local playerNum = table.nums(data)

    local lineCount = math.ceil(playerNum / 3)

    local contentHeight = content_sv:getInnerContainerSize().height
    local contentWidth = content_sv:getInnerContainerSize().width

    if contentHeight < 160 * lineCount then
        contentHeight = 160 * lineCount
    end

    content_sv:setInnerContainerSize(cc.size(contentWidth, contentHeight))
    content_ly:setContentSize(cc.size(contentWidth, contentHeight))
    content_ly:setPositionY(contentHeight)
    content_ly:removeAllChildren()

    local my_bet_chip = s:getChildByName('my_bet_chip')
    my_bet_chip:setString('我的下注:0')
    local total_bet_chip = s:getChildByName('total_bet_chip')
    total_bet_chip:setString('我的输赢:0')

    local positionIndex = 0
    --生成界面
    for k, v in pairs(data) do
        ------------------------------------------数据-----------------------------------
        local sex = 1
        local uid = v.uid
        local nickName = v.nickName
        local photo_url = v.portrait
        local score = v.score
        -------------------------------------------界面-------------------------------------------
        if uid == USER_INFO['uid'] then
            my_bet_chip:setString('我的下注:' .. (my_bet_chip[uid] or 0))
            total_bet_chip:setString('我的输赢:' .. score)
        end

        positionIndex = positionIndex + 1
        local result_Item = result_Item:clone()
        content_ly:addChild(result_Item)

        local x = contentWidth / 2 - (2 - math.ceil(positionIndex % 3.01)) * 400
        local y = contentHeight - (math.ceil(positionIndex / 3.01) - 1) * 155

        result_Item:setPosition(cc.p(x, y))

        --用户头像
        local head_im = result_Item:getChildByName('head_im')
        require('hall.GameCommon'):getUserHead(
            photo_url,
            uid,
            sex,
            head_im,
            head_im:getContentSize().width,
            false,
            nickName
        )

        --用户昵称
        local nickName_txt = result_Item:getChildByName('nickName_txt')

        local total_bet_chip = result_Item:getChildByName('total_bet_chip')
        total_bet_chip:setString('输赢：' .. score)
        local bet_chip_txt = result_Item:getChildByName('bet_chip')
        bet_chip_txt:setString('下注：' .. (SINGLE_BET_CHIP[uid] or 0))

        local namenick = SanGongUtils:formatNick(nickName, 7)
        nickName_txt:setString(namenick)
    end
end

--5001
function SanGongReceiveHandle:BROADCAST_ERROR_TIPS(pack)
    dump(pack, '-----返回错误提示5001-----')

    local errorCode = pack.errorCode

    local tbErrorCode = {
        [1] = '操作无效',
        [10] = '您正在游戏中',
        [11] = '您已经坐下了',
        [12] = '您已经准备过了',
        [13] = '您还没准备',
        [14] = '您已经坐下了',
        [15] = '您正在围观中',
        [16] = '桌子已经满啦',
        [17] = '玩家不存在',
        [18] = '您积分不够啦，请充值',
        [20] = '游戏未开始',
        [20] = '游戏正在进行中，请稍后...在做操作'
    }

    if errorCode == 18 then
        SanGongScene:performWithDelay(
            function()
                --去掉提示弹框
                local layer_tips = SanGongScene:getChildByName('layer_tips')
                if layer_tips then
                    layer_tips:removeSelf()
                end

                if not isiOSVerify then
                    SanGongScene:requestCharge()
                end
            end,
            1.5
        )
    end

    if tbErrorCode[errorCode] then
        -- require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[errorCode])
        viewMgr:showTip({text = tbErrorCode[errorCode]})
    else
        -- require("hall.GameTips"):showTips("提示", "", 3, "未知的错误")
        viewMgr:showTip({text = '未知的错误'})
    end
end

--5101
function SanGongReceiveHandle:SVR_GROUP_TIME(pack)
    dump(pack, 'SVR_GROUP_TIME')
    GAME_ROUND = pack.round
    GAME_TOTAL_ROUND = pack.round_total or 999
    SanGongPanel.hall_plane.info_bg.txt_game_no:setString('局数：' .. GAME_ROUND .. '/' .. GAME_TOTAL_ROUND)
    SanGongScene:showShareButton(true) --隐藏分享按钮

    --if  isGoldGame == 0 then
    --    GAME_TOTAL_ROUND = 999
    --end
    --
    --SanGongScene:updateRoomInfo(nil,nil,nil,GAME_ROUND,GAME_TOTAL_ROUND)
end

--广播玩家开启托管 1034
function SanGongReceiveHandle:BROADCAST_USER_AUTO_PLAY(pack)
    dump(pack, '------广播玩家开启托管 1034------')
    if pack.isOpenAuto == 1 then
        g_sangongMainScene.tgLayer:showTg()
    else
        g_sangongMainScene.tgLayer:hideTg()
    end
end

--广播开始游戏倒计时 100F
function SanGongReceiveHandle:SVR_BROADCAST_COUNT_DOWN(pack)
    dump(pack, '------广播开始游戏倒计时 100F------')
end

--0x2001    --广播用户准备
function SanGongReceiveHandle:SERVER_READYNOW_ROOM(pack)
    dump(pack, '-------0x2001    --广播用户准备------')
    local playerType = SANGONG_PLAYERTYPE_TABLE[pack.uid]
    local readyState = 1 --1是准备，0是取消准备

    if playerType then
        if readyState == 0 then
            GamePlaneOperator:setReadyStatus(playerType, false)
        else
            GamePlaneOperator:setReadyStatus(playerType, true)
        end
    end
    if readyState == 0 then
        USERS_READY_STATE[pack.uid] = 0
    else
        USERS_READY_STATE[pack.uid] = 1
    end
    self:setBtnReady()
end

---------------------------------------------------------------------------------------------------------------------------------------------

--1043玩家开始摊牌
function SanGongReceiveHandle:SVR_OPEN_CARDS_BROADCAST(pack)
    GamePlaneOperator:showStageTxt('比牌中')
end
---------------------------------------------------------------------------------------------------------------------------------------------

function SanGongReceiveHandle:setBtnReady()
    if
        USERS_READY_STATE and USERS_READY_STATE[USER_INFO['uid']] and USERS_READY_STATE[USER_INFO['uid']] ~= 1 and
            MY_SEAT_ID >= 0
     then
        GamePlaneOperator:showControlButtons(1)
    end
end

--结算6008
function SanGongReceiveHandle:SVR_SETTLEMENT_BROADCAST(pack)
    dump(pack, '---三公结算-----')
    GAME_STATE = GAME_STATUS_STOP
    TIMES_COUNT = -1
    SanGongUtils:clearPlayerGold()
    for uid, _ in pairs(USERS_READY_STATE) do --重置所有玩家的准备状态
        USERS_READY_STATE[uid] = 0
    end

    if GAME_ROUND < GAME_TOTAL_ROUND then
        GamePlaneOperator:showStageTxt('等待游戏开始...')
        --我不在准备状态且坐下了
        self:setBtnReady()
        SanGongScene:showShareButton(true)
    else
        GamePlaneOperator:showStageTxt('')
        local GameResult = SanGongScene:getChildByName('gameresultScene')
        if GameResult then
            GameResult:setVisible(true)
        end
    end

    local tbWin = {}
    for k, v in pairs(pack.userinfo) do
        local playerType = SANGONG_PLAYERTYPE_TABLE[v.uid]
        if playerType then
            local userinfo = SANGONG_USERINFO_TABLE[v.uid]
            SANGONG_USERINFO_TABLE[v.uid].gold = SanGongUtils:goldMath(v.chips)
            GamePlaneOperator:updateCoin(playerType, v.score / 100, userinfo.gold)
            GamePlaneOperator:setCoin(playerType, SANGONG_USERINFO_TABLE[v.uid].gold)
            if v.score >= 1 then
                tbWin[v.uid] = v.score / 100
            end
        end
    end
    GamePlaneOperator:showCoinFlyAnimation(nil, tbWin, 'game')
end

--牛牛组局排行榜 5100
function SanGongReceiveHandle:SVR_GROUP_BILLBOARD(pack)
    dump(pack, '-----牛牛组局排行榜5100-----')
    dump(GAME_ROUND, '-----牛牛组局排行榜GAME_ROUND-----')

    g_sangongMainScene.tgLayer:hideTg()

    GamePlaneOperator:showStageTxt('')
    --SanGongUtils:showResult(pack)
    --
    --SanGongScene:showShareButton(false)
    GamePlaneOperator:showCheckResultButton(true)
    --去掉提示弹框
    local layer_tips = SanGongScene:getChildByName('layer_tips')
    if layer_tips then
        layer_tips:removeSelf()
    end
    local data = {}
    data['resultSceneType'] = 2 --战绩界面展示选择，1为长条形，2为方块形
    data['invote_code'] = USER_INFO['invote_code'] --房间号
    data['fenchang'] = '' --分场
    data['round'] = GAME_ROUND --.."/"..GROUP_TOTAL_ROUND                  --局数
    data['date'] = os.date('%Y-%m-%d-%H:%M') --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
    data['activity_id'] = USER_INFO['activity_id']
    data['resultData'] = {}

    for uid, user_info in pairs(pack.playerlist) do
        local user_result = {} --玩家数据实体
        user_result['nick'] = user_info['nickName'] --昵称
        user_result['uid'] = user_info.uid --uid
        user_result['icon_url'] = user_info['portrait'] --头像链接
        user_result['sex'] = user_info['sex'] --性别
        user_result['isRoomOwer'] = 0 --是否为房主，1是，非1或不填不是
        if user_info['chips'] > 0 then
            user_result['isWinner'] = 1 --是否为赢家，1是，非1或不填不是
        else
            user_result['isWinner'] = 0
        end
        user_result['total'] = user_info['chips'] --总输赢分

        user_result['gameDetail'] = {} --游戏详情数组
        local gameDetail1 = {} --游戏详情实体
        gameDetail1['showName'] = '赢的次数' --展示名
        gameDetail1['value'] = user_info['win_num'] or 0 --值

        local gameDetail2 = {}
        gameDetail2['showName'] = '输的次数'
        gameDetail2['value'] = user_info['lose_num'] or 0

        table.insert(user_result['gameDetail'], gameDetail1)
        table.insert(user_result['gameDetail'], gameDetail2)
        table.insert(data['resultData'], user_result)
    end
    --返回大厅按钮点击事件
    local backHall_action = function(sender, event)
        USER_INFO['gameConfig'] = ''
        require('hall.GameCommon'):gExitGroupGame(USER_INFO['enter_mode'], CLUB_ID)
    end

    --再来一局
    local extend_action = function(sender, event)
        require('hall.groudgamemanager'):extend_freegame(USER_INFO['uid'], USER_INFO['activity_id'])
    end

    --分享按钮点击事件
    local share_action = function(sender, event)
        local paras = {}
        paras['showType'] = 2
        paras['desc'] = USER_INFO['gameConfigMsg'] or ' '
        paras['imagePath'] = 'screen'
        paras['name'] = '分享结果'
        paras['url'] = appDownLoadAddress
        local shareLayer = require('hall.share.ShareLayer').new(paras)
        if shareLayer then
            shareLayer:addTo(SanGongScene, 9999999)
        end
        --require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
        ----通知APP分享结果
        --if device.platform == "android" then
        --	require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
        --elseif device.platform ~= "windows" then
        --	require("hall.common.ShareLayer"):shareGroupResultForIOS()
        --end
    end
    -- require(GameResultScene_filePath):showScene(data, backHall_action, share_action)
    require('hall.settlement.settlement').new(data, backHall_action, share_action, nil, extend_action)

    -- SanGongScene:performWithDelay(function()
    --     SanGongScene:initData("release")
    -- end,5)
end

--------------------------------------周边功能-----------------------------------------
--组局解散相关
--没有此房间，解散房间失败
function SanGongReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)
    --dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")
    require('hall.GameTips'):showTips('提示', 'disbandGroup_fail', 2, '解散房间失败')
end

--广播当前组局解散情况
function SanGongReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)
    dump(pack, '-----广播当前组局解散情况-----')
    dump(SANGONG_USERINFO_TABLE, '-----广播当前房间情况-----')
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
        local applyer_info = SANGONG_USERINFO_TABLE[applyId]
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
    for k, v in pairs(SANGONG_USERINFO_TABLE) do
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
        SanGongSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(value)
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
function SanGongReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)
    --dump(pack, "-----广播桌子用户请求解散组局-----")
    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")
end

--广播桌子用户成功解散组局
function SanGongReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)
    --dump(pack, "-----广播桌子用户成功解散组局-----")

    bm.isDisbandSuccess = true

    -- require("hall.GameTips"):showDisbandTips("解散房间成功","ddz_disbandGroup_success",3)
end

--广播桌子用户解散组局 ，解散组局失败
function SanGongReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)
    --dump(pack, "-----广播桌子用户解散组局 ，解散组局失败-----")

    local rejectId = pack.rejectId
    if rejectId == USER_INFO['uid'] then
        require('hall.GameTips'):showDisbandTips('解散房间失败', 'disbandGroup_fail', 0, '您拒绝解散房间')
    else
        local nickName = SANGONG_USERINFO_TABLE[rejectId].nick or '路人甲'
        require('hall.GameTips'):showDisbandTips('解散房间失败', 'disbandGroup_fail', 0, nickName .. '拒绝解散房间')
    end
end

--聊天
function SanGongReceiveHandle:SVR_MSG_FACE(pack)
    local faceUI = SanGongScene:getChildByName('faceUI')

    local sex = 1

    if SANGONG_USERINFO_TABLE[pack.uid] then
        sex = SANGONG_USERINFO_TABLE[pack.uid].sex or 0
    end

    local isLeft = false

    local node_head = PLAYER_HEADS_TABLE[pack.uid]
    if tonumber(sex) >= 0 and node_head then
        faceUI:showGetFace(pack.uid, pack.type, tonumber(sex), node_head, false)
    end
end
-----------------------------------------------------------------------------------------------------------------------------
function SanGongReceiveHandle:showTextMessage(pack)
    local s = SanGongScene:getChildByName('faceUI')

    local sex = 1

    if SANGONG_USERINFO_TABLE[pack.uid] then
        sex = SANGONG_USERINFO_TABLE[pack.uid].sex or 0
    end

    local node_head = PLAYER_HEADS_TABLE[pack.uid]

    s:showGetText(pack.uid, pack.textMessage, tonumber(sex), node_head, false)
end

function SanGongReceiveHandle:showExpression(msg)
    local uid_from = tonumber(msg['uid_from']) or 1
    local uid_to = tonumber(msg['uid_to']) or 1
    local expressionType = tonumber(msg['expressionType']) or 1

    ---------------------------------不同游戏需修改的部分----------------------------
    -- --通过UID获取seat
    -- local seat_from = USERID2SEAT[uid_from] or 2
    -- local seat_to =  USERID2SEAT[seat_to] or 0

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

--接收服务器返回的组局信息
function SanGongReceiveHandle:SERVER_CMD_MESSAGE(pack)
    if bm.isInGame == false then
        return
    end

    local msg = json.decode(pack.msg)
    dump(msg, '-----SERVER_CMD_MESSAGE 表情-----')
    if msg ~= nil then
        local msgType = msg.msgType
        if msgType ~= nil and msgType ~= '' then
            if msgType == 'expression' then --表情
                self:showExpression(msg)
            elseif msgType == 'text' then --文字聊天
                self:showTextMessage(msg)
            elseif msgType == 'emoji' then
                local emojiPack = {}
                emojiPack['uid'] = msg.uid
                emojiPack['type'] = msg.type
                self:SVR_MSG_FACE(emojiPack)
            elseif msgType == 'EmojiArmatureView' then --动态表情
                self:SVR_MSG_EMOJI_ARMATURE(msg)
            end

            if device.platform == 'ios' then
                if msgType == 'voice' then
                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                    require('hall.view.voicePlayView.voicePlayView'):showView(msg.uid, msg.voiceTime)
                    --通知本地播放录音
                    local arr = {}
                    arr['url'] = msg.url
                    cct.getDateForApp('playVoice', arr, 'V')
                elseif msgType == 'video' then
                    local arr = {}
                    arr['url'] = msg.url
                    cct.getDateForApp('playVideo', arr, 'V')
                end
            else
                if msgType == 'voice' then
                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                    require('hall.view.voicePlayView.voicePlayView'):showView(msg.uid, msg.voiceTime)
                    --通知本地播放录音
                    local data = {}
                    data['url'] = msg.url
                    local arr = {}
                    table.insert(arr, json.encode(data))
                    cct.getDateForApp('playVoice', arr, 'V')
                elseif msgType == 'video' then
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

function SanGongReceiveHandle:SVR_MSG_EMOJI_ARMATURE(pack)
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

--请求录纸返回 1035
function SanGongReceiveHandle:SERVER_CMD_RECORD_PAPER(pack)
    local record_paper = pack.record_paper
end

--发牌相关
--处理发牌协议 4001 (第一次发标志着游戏的开始)
function SanGongReceiveHandle:SVR_SEND_USER_CARD(pack)
    MY_CARDS = {}
    for i, card in ipairs(pack.cards) do
        table.insert(MY_CARDS, card)
    end
    -----------------------------------
    GamePlaneOperator:showCards(CARD_PLAYERTYPE_MY, pack.cards)
end

-- 0x1101   --- 广播下注
function SanGongReceiveHandle:SERVER_BROADCAST_YA(pack)
    dump(pack, '-----------广播下注-------------')
    -- GamePlaneOperator:showControlButtons(3)

    if not isNewLowerScore then
        StakeScene:updateStakeGold(pack)
    end
    local playerType = SANGONG_PLAYERTYPE_TABLE[pack.uid]
    if SANGONG_SEAT_TABLE == nil or SANGONG_SEAT_TABLE[pack.desUid] == nil then
        return
    end
    local desPlayerType = SANGONG_SEAT_TABLE[pack.desUid] + 1
    local desPlayerTypeOther = SANGONG_PLAYERTYPE_TABLE[pack.desUid]
    dump(playerType, 'SERVER_CMD_REQ_YAZHU_INFO-playerType')

    if playerType then
        SANGONG_USERINFO_TABLE[pack.uid].gold = SanGongUtils:goldMath(pack.gold)
        GamePlaneOperator:setCoin(playerType, SanGongUtils:goldMath(pack.gold))
    end
    if desPlayerTypeOther then
        SANGONG_USERINFO_TABLE[pack.desUid].totalGold = pack.total
        GamePlaneOperator:setTotalBetChip(desPlayerTypeOther, SanGongUtils:goldMath(pack.total))
    end
    if pack.uid == USER_INFO['uid'] then
        GamePlaneOperator:hideClickXiaZhu()

        SANGONG_USERINFO_TABLE[pack.uid].gold = SanGongUtils:goldMath(pack.gold)
        GamePlaneOperator:setMyCoin(SanGongUtils:goldMath(pack.gold))
        GamePlaneOperator:setSeatGold(desPlayerType, SanGongUtils:goldMath(pack.total))
        if isNewLowerScore then
            LowerScoreScene:removeScene()
            local playerNo = SANGONG_SEAT_TABLE[pack.desUid] + 1
        -- require("hall.GameTips"):showTips("提示", "", 2, playerNo.. " 号桌成功押注 "..SanGongUtils:goldMath(pack.chip) .."分")
        --require(CommonTips_filePath):showTips("提示", "", 3, playerNo.. " 号桌成功押注 "..SanGongUtils:goldMath(pack.chip) .."分")
        end
    end
    local playerType = SANGONG_PLAYERTYPE_TABLE[pack.uid]
    GamePlaneOperator:setBetTimes(playerType, pack.chip / 100)

    ------设置底池
    GamePlaneOperator:showDiChi(pack.chip / 100)
end
function SanGongReceiveHandle:SERVER_BROADCAST_START_YA(pack)
    local GAME_TIME = pack.outCardAniTime
    GAME_STATE = GAME_STATUS_YA
    GAME_IS_ENDING = 1
    GAME_OUT_CARD_COUNT = 1
    GAME_OVER_RANKING = 1
    IS_ON_RANKING = false
    GamePlaneOperator:startTimer(GAME_TIME, '投分时间：')
    --GamePlaneOperator:showIsButtonXZ(false)
    --GamePlaneOperator:showPlayer()
    --GamePlaneOperator:showStartAnimation()
    -- RoundEnding:removeView()
    --if not isNewLowerScore then
    --    StakeScene:clearDetailList()
    --end
    --GamePlaneOperator:clearGameDatas(true)
end

function SanGongReceiveHandle:SERVER_BROADCAST_CARD(pack, flag, isShow, timeStr, isShowXiaZhu)
    GamePlaneOperator:showPlayer()
    GamePlaneOperator:showStartAnimation()
    -- RoundEnding:removeView()
    if not isNewLowerScore then
        StakeScene:clearDetailList()
    end
    -- GamePlaneOperator:clearGameDatas(true)
    local BANKSEATID = (pack.bankSeatId or 0)
    SHAICARD = pack.shaiCard
    local GAME_TIME = pack.outCardAniTime or 0
    dump(BANKSEATID, 'BANKSEATID-SERVER_BROADCAST_CARD')
    BANKSEATID = SanGongUtils:getPlayerTypeBySeatId(BANKSEATID)
    GAME_STATE = GAME_STATUS_SEND_CARD
    local timeStr = timeStr or '发牌时间：'
    -- GamePlaneOperator:startTimer(GAME_TIME,timeStr)
    --GamePlaneOperator:showIsButtonXZ(false)
    if not isNewLowerScore then
        StakeScene:closeStakeScene()
    else
        LowerScoreScene:removeScene()
    end
    GamePlaneOperator:hidePlayer('player')
    local userCards = {}
    local cardType = {}
    local panel_playerType = 5
    MY_CARDS = {}
    local SendCardTime = 0
    local dichiNum = 0
    local isChuPai = false
    for i, data in pairs(pack.gamePlayerArr) do --先清理，后再发牌
        local playerType = SANGONG_PLAYERTYPE_TABLE[data.uid]
        GamePlaneOperator:clearCardPlane(playerType)
    end

    for i, data in pairs(pack.gamePlayerArr) do --先清理，后再发牌
        local playerType = SANGONG_PLAYERTYPE_TABLE[data.uid]
        userCards[playerType] = data.handCardArr
        cardType[playerType] = {}
        cardType[playerType].type = data.type
        cardType[playerType].point = data.point
        cardType[playerType].maxCard = data.maxCard
        panel_playerType = playerType
        --GamePlaneOperator:clearCardPlane(playerType)
        All_Card_Nodes[playerType] = {}
        if data.uid == USER_INFO['uid'] then
            MY_CARDS = data.handCardArr
            if data.user_status == 1 then
                isChuPai = true
                GamePlaneOperator:showControlButtons(nil, false)
            end
        end
        GamePlaneOperator:showCards(playerType, data.handCardArr)
        if data.user_status == 1 then
            GamePlaneOperator:showCardKind(playerType, data.point, data.type)
            GamePlaneOperator:showOpenCards(playerType)
        end
        SendCardTime = SendCardTime + 0.2
        if data.totalGold then
            dichiNum = data.totalGold + dichiNum
        end
    end
    if dichiNum > 0 then
        GamePlaneOperator:showDiChi(dichiNum / 100)
    end
    --if self.chupai_cuopai then
    --    SCHEDULER.unscheduleGlobal(self.chupai_cuopai)
    --end
    self.chupai_cuopai =
        SCHEDULER.performWithDelayGlobal(
        function()
            if isChuPai == false then
            -- GamePlaneOperator:showControlButtons(4)
            end
            if isShowXiaZhu then
                self:SVR_BROADCAST_WAIT_START(pack, isShowXiaZhu)
            end
            -- for i,data in pairs(pack.
        end,
        SendCardTime
    )
    -- local function callback()
    --     for i = 1 , 3 do
    --         for k = BANKSEATID, (12 + BANKSEATID -1) do
    --             for _,data in pairs(pack.gamePlayerArr) do
    --                 local playerType = SANGONG_PLAYERTYPE_TABLE[data.uid]
    --                 local index =k
    --                 if k >12 then
    --                     index = k - 12
    --                 end
    --                 if index == playerType then
    --                     local cards = userCards[playerType]
    --                     if flag then
    --                         GamePlaneOperator:showAllCards(playerType, cards,i,isShow,cardType[playerType])
    --                         if isShow then
    --                             GamePlaneOperator:showCardKind(playerType,cardType[playerType].point,cardType[playerType].type,true)
    --                         end
    --                     else
    --                         GamePlaneOperator:showDealCardsAnimation(playerType, cards,i)
    --                     end

    --                 end
    --             end

    --         end
    --     end
    -- end
    -- if flag then
    --     callback()
    -- else
    --     GamePlaneOperator:showCardsBack(callback,panel_playerType)
    -- end
end

-- 0x1103   -- 广播出牌
function SanGongReceiveHandle:SERVER_BROADCAST_OUT_CARD(pack)
    dump(pack, '----------------------广播出牌')
    if GAME_STATE == GAME_STATUS_OPEN_KIND then
        return
    end
    GAME_STATE = GAME_STATUS_OPEN_CARD
    if pack.uid == USER_INFO.uid then
        GamePlaneOperator:showControlButtons(0, false)
    end
    --
    --GAME_TIME = pack.outCardAniTime
    --GamePlaneOperator:startTimer(GAME_TIME,"出牌：")
    --GamePlaneOperator:showIsButtonXZ(false)
    TIMES_COUNT = TIMES_COUNT + pack.outCardAniTime
    if GAME_OUT_CARD_COUNT == 1 then
        GAME_OUT_CARD_COUNT = GAME_OUT_CARD_COUNT + 1
        if CHECK_SCHEDULER_GLOBAL then
            SCHEDULER.unscheduleGlobal(CHECK_SCHEDULER_GLOBAL)
        end
    end

    --CHECK_SCHEDULER_GLOBAL =SCHEDULER.performWithDelayGlobal(function ()
    local playerType = SANGONG_PLAYERTYPE_TABLE[pack.uid]
    if All_Card_Nodes and All_Card_Nodes[playerType] then
        GamePlaneOperator:outCard(playerType, pack.handCardArr)
        GamePlaneOperator:showCardKind(playerType, pack.point, pack.type)
    end
    --end, TIMES_COUNT)
end
function SanGongReceiveHandle:SERVER_BROADCAST_START_OUT_CARD(pack)
    local GAME_TIME = pack.outCardAniTime
    GAME_STATE = GAME_STATUS_OUT_CARD
    GamePlaneOperator:startTimer(GAME_TIME, '看牌时间：')
    -- GamePlaneOperator:showControlButtons(6)
    GamePlaneOperator:showControlButtons(4)
end
--0x1104   --- 开牌
function SanGongReceiveHandle:SERVER_BROADCAST_OPEN_CARD(pack) --开牌阶段
    --dump(pack, "SERVER_BROADCAST_OPEN_CARD")
    --GAME_STATE = GAME_STATUS_OPEN_CARD
    ----local GAME_TIME = pack.outCardAniTime
    --local GAME_TIME = pack.gamePlayerCount + 3
    ---- GamePlaneOperator:showControlButtons(1, false)
    -------GamePlaneOperator:startTimer(GAME_TIME,"正在报牌：")
    ----GamePlaneOperator:showIsButtonXZ(false)
    --GamePlaneOperator:restartMoveCard()
    ----if restart then
    ----    local userCards = {}
    ----    for i,data in pairs(pack.gamePlayerArr) do  --先清理，后再发牌
    ----        local playerType = SANGONG_PLAYERTYPE_TABLE[data.uid]
    ----        userCards[playerType] = data.handCardArr
    ----        GamePlaneOperator:clearCardPlane(playerType)
    ----    end
    ----    for i = 1 , 3 do
    ----        for k = 1, 8 do
    ----            for _,data in pairs(pack.gamePlayerArr) do
    ----                local playerType = SANGONG_PLAYERTYPE_TABLE[data.uid]
    ----                if k == playerType then
    ----                    local cards = userCards[playerType]
    ----                    GamePlaneOperator:showAllCards(playerType, cards,i)
    ----                   -- GamePlaneOperator:showDealCardsAnimation(playerType, cards,i)
    ----                end
    ----            end
    ----
    ----        end
    ----    end
    ----else
    --for i,v in pairs(pack.gamePlayerArr) do
    --    local playerType = SANGONG_PLAYERTYPE_TABLE[v.uid]
    --    local card = v.handCardArr[table.getn(v.handCardArr)]
    --    GamePlaneOperator:outCard(playerType, v.handCardArr)
    --end
    --
    --end
    --self:SERVER_BROADCAST_CARD(pack)
end

function SanGongReceiveHandle:SERVER_CMD_REQ_YAZHU_INFO(pack) --押注情况

    if not isNewLowerScore then
        StakeScene:showStakeScene(pack.gamePlayerArr)
    end
    for i, v in pairs(pack.gamePlayerArr) do
        local playerType = SANGONG_PLAYERTYPE_TABLE[v.uid]
        GamePlaneOperator:setSeatGold(playerType, SanGongUtils:goldMath(v.my_total))
        GamePlaneOperator:setTotalBetChip(playerType, SanGongUtils:goldMath(v.total))
    end
end
function SanGongReceiveHandle:SERVER_CMD_REQ_YAZHU_DETAILS(pack)
    dump(pack, 'SERVER_CMD_REQ_YAZHU_DETAILS')
    --if IS_DETAIL_STOP then
    --    return
    --end
    if not isNewLowerScore then
        StakeScene:showDetail(pack)
    else
        LowerScoreScene:showLowerScoreScene(pack)
    end

    --
end
function SanGongReceiveHandle:SERVER_NOTIFY_RESULT(pack)
    dump(pack, 'SERVER_NOTIFY_RESULT')
    TIMES_COUNT = -1
    --GamePlaneOperator:startTimer(0,"正在结算：")
    GAME_STATE = GAME_STATUS_STOP
    if not isNewLowerScore then
        StakeScene:clearGoldPanel()
    end

    GamePlaneOperator:setMyCoin(SanGongUtils:goldMath(pack.gold))
    SANGONG_USERINFO_TABLE[USER_INFO['uid']].gold = SanGongUtils:goldMath(pack.gold)
    -- RoundEnding:showNotify(pack)
    IS_ON_RANKING = true
end
function SanGongReceiveHandle:SERVER_BROADCAST_GIVE_COINS(pack)
    dump(pack, 'SERVER_BROADCAST_GIVE_COINS')

    local from_playerType = SANGONG_PLAYERTYPE_TABLE[pack.fromUid]
    local to_playerType = SANGONG_PLAYERTYPE_TABLE[pack.toUid]
    if SANGONG_USERINFO_TABLE[pack.toUid] then
        SANGONG_USERINFO_TABLE[pack.toUid].gold =
            (SANGONG_USERINFO_TABLE[pack.toUid].gold or 0) + SanGongUtils:goldMath(pack.toCoins)
        if pack.toUid == USER_INFO['uid'] then
            GamePlaneOperator:setMyCoin(SANGONG_USERINFO_TABLE[pack.toUid].gold)
        end
    end
    if SANGONG_USERINFO_TABLE[pack.fromUid] then
        SANGONG_USERINFO_TABLE[pack.fromUid].gold =
            (SANGONG_USERINFO_TABLE[pack.fromUid].gold or 0) + SanGongUtils:goldMath(pack.fromCoins)
        if pack.fromUid == USER_INFO['uid'] then
            GamePlaneOperator:setMyCoin(SANGONG_USERINFO_TABLE[pack.fromUid].gold)
        end
    end

    if from_playerType then
        GamePlaneOperator:setCoin(from_playerType, SANGONG_USERINFO_TABLE[pack.fromUid].gold)
    end

    if to_playerType then
        GamePlaneOperator:setCoin(to_playerType, SANGONG_USERINFO_TABLE[pack.toUid].gold)
    end
    require(GiveScene_filePath):removeScene()
    if pack.fromUid == USER_INFO['uid'] then
    --require(CommonTips_filePath):showTips("提示", "", 3, "赠送成功")
    end
end

--0x1109--单局结算
function SanGongReceiveHandle:SERVER_BROADCAST_WINLOSE_COUNT(pack)
    dump(pack, '------------------------0x1109--单局结算')
    -- self:setBtnReady()
end

function SanGongReceiveHandle:SERVER_CMD_REQ_TEST(pack)
    dump(pack, '---------------------------测试1-------------------------------------')
    local count = pack.count
    local testSeats = pack.testSeats
    if count <= 0 or #testSeats <= 0 then
        return
    end
    if SanGongScene:getChildByName('ConfigPanel') then
        SanGongScene:getChildByName('ConfigPanel'):removeSelf()
    end
    for i, info in pairs(testSeats) do
        -- if info.seat==isOpenControlSeat then
        --     require(TpackageName..".Control"):init(pack.seatCount,info.rank+1)
        --     return
        -- end
        require(TpackageName .. '.Control'):init(pack.seatCount, info.rank + 1)
        return
    end
end

function SanGongReceiveHandle:SERVER_CMD_TEST(pack)
    require(TpackageName .. '.Control'):removeScene()
    dump(pack, '---------------------------测试2-------------------------------------')
    if pack.errorCode == 0 then
        require('hall.GameTips'):showTips('提示', '', 3, '成功')
    else
        require('hall.GameTips'):showTips('提示', '', 3, '失败')
    end
end
---------------------------------------------------------------------------------------------------

--准备相关
--广播用户可以准备了
function SanGongReceiveHandle:SVR_READY_TIME(pack)
    dump(pack, '------广播用户可以准备了6009------')

    GAME_STATE = GAME_STATUS_STOP --准备阶段
end

--广播玩家准备 用户准备了返回
function SanGongReceiveHandle:SVR_READY_BROADCAST(pack)
    dump(pack, '------广播玩家准备6001------')

    local playerType = SANGONG_PLAYERTYPE_TABLE[pack.uid]
    local readyState = pack.readyState --1是准备，0是取消准备

    if playerType then
        if readyState == 0 then
            GamePlaneOperator:setReadyStatus(playerType, false)
        else
            GamePlaneOperator:setReadyStatus(playerType, true)
        end
    end

    if readyState == 0 then
        USERS_READY_STATE[pack.uid] = 0
    else
        USERS_READY_STATE[pack.uid] = 1
    end
    self:setBtnReady()
end
--所有人都已准备，广播可以开始游戏
function SanGongReceiveHandle:SERVER_COMMAND_REMAID_START_GAME()
    GamePlaneOperator:RemaidStartGame(true)
end
--广播游戏开始 6002
function SanGongReceiveHandle:SVR_BROADCAST_GAME_START(pack)
    -----------------------------游戏开始-------------------------------
    dump(pack, 'SVR_BROADCAST_GAME_START')
    GamePlaneOperator:showSitDownButton(false) --隐藏坐下按钮
    SanGongScene:showShareButton(false) --隐藏分享按钮
    GamePlaneOperator:RemaidStartGame(false) --隐藏开始按钮
    GamePlaneOperator:clearAllReadyStatus() --游戏开始后清除准备状态
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

                local playerType = SANGONG_PLAYERTYPE_TABLE_BYSEAT[seatId]

                if playerType and seatId ~= MY_SEAT_ID and cardEndIndex > 0 then
                    GamePlaneOperator:showDealCardsAnimation(playerType, cards, cardEndIndex, isRelogin, 'cover')
                end
            end
        else
            local user_datas = pack.user_datas

            for _, data in pairs(user_datas) do
                local seatId = data.seatId
                local cards = data.cards

                -- for i = cardEndIndex + 1,5 do
                --     cards[i] = 0
                -- end

                local playerType = SANGONG_PLAYERTYPE_TABLE_BYSEAT[seatId]

                if playerType and seatId ~= MY_SEAT_ID and cardEndIndex > 0 then
                    SanGongScene:performWithDelay(
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
                local playerType = SANGONG_PLAYERTYPE_TABLE[uid]
                if playerType and uid ~= USER_INFO['uid'] and cardEndIndex > 0 then
                    GamePlaneOperator:showDealCardsAnimation(playerType, nil, cardEndIndex, isRelogin)
                end
            end
        else
            for _, uid in ipairs(GAME_PARTICIPANTS) do
                local playerType = SANGONG_PLAYERTYPE_TABLE[uid]
                if playerType and uid ~= USER_INFO['uid'] and cardEndIndex > 0 then
                    SanGongScene:performWithDelay(
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
end

--1041 广播下注剩余时间
function SanGongReceiveHandle:BROADCAST_SENDCARD_REMAINDTIME(pack)
    GamePlaneOperator:startTimer(pack, '下注阶段')
end
--出牌相关
--广播出牌阶段开始
function SanGongReceiveHandle:SVR_PLAY_CARD_BROADCAST(pack)
    dump(pack, '-----广播玩家开始出牌6004-----')
    --显示阶段信息
    GAME_STATE = GAME_STATUS_OUTCARD --棋牌进行中

    local time = pack.time or 5
    local cardEndIndex = 5

    if USERS_READY_STATE[USER_INFO['uid']] == 1 then
    -- GamePlaneOperator:showControlButtons(4)   --隐藏抢分
    end

    for _, uid in ipairs(GAME_PARTICIPANTS) do
        local playerType = SANGONG_PLAYERTYPE_TABLE[uid]
        if playerType and uid ~= USER_INFO['uid'] then
            dump(playerType, '出牌阶段给玩家发最后几张牌')
            GamePlaneOperator:showDealCardsAnimation(playerType, nil, cardEndIndex)
            GamePlaneOperator:showCardKind(playerType, -1) --显示盖牌文字
        end
    end

    GamePlaneOperator:startTimer(time, '出牌阶段')
end

--扣除台费 4800
function SanGongReceiveHandle:SVR_CHIP_CHANGE_BROADCAST(pack)
    local change_chip = 0
    for _, data in pairs(pack.userinfo) do
        local uid = data.uid
        local playerType = SANGONG_PLAYERTYPE_TABLE[uid]
        local oriChip = SANGONG_USERINFO_TABLE[uid].coins
        local chip = oriChip + data.change_chip
        SANGONG_USERINFO_TABLE[uid].coins = chip

        GamePlaneOperator:setCoin(playerType, chip)

        if uid == USER_INFO['uid'] then
            --GamePlaneOperator:showTaiFeiTips(data.change_chip)
        end
    end
end

--1043玩家开始摊牌
function SanGongReceiveHandle:SVR_OPEN_CARDS_BROADCAST(pack)
    local totalOpenCardTime = pack.openCardTime

    GamePlaneOperator:showStageTxt('比牌中...')
end

--广播开始抢庄（游戏开始，第一阶段）
function SanGongReceiveHandle:SVR_BEGIN_QIANFGZHUANG_BROADCAST(pack)
    dump(pack, '-----广播开始抢庄6015-----')

    --棋牌进行中
    GAME_STATE = GAME_STATUS_GRAB

    local time = pack.time

    GamePlaneOperator:startTimer(time, '抢庄阶段')

    if USERS_READY_STATE[USER_INFO['uid']] ~= 1 then
        GamePlaneOperator:showControlButtons(1, false)
        return
    end

    if pack.time <= -3 or GAME_TYPE_NAME == '通比牛牛' then --没有此阶段
        return
    end

    local exsits = false

    local my_can_grab_times

    for i, data in pairs(pack.ids) do
        local uid

        if type(data) == 'table' then
            uid = data.uid
            if USER_INFO['uid'] == uid then
                --当前自己已经抢庄
                exsits = true
                my_can_grab_times = data.can_grab_times
            end
        else
            uid = data
            if USER_INFO['uid'] == uid then
                --当前自己已经抢庄
                exsits = true
            end
        end
    end

    if GROUP_MODE == 2 then
        if my_can_grab_times then
            table.insert(pack.grab_times, 1, 0)
            table.insert(my_can_grab_times, 1, 0)
            GamePlaneOperator:loadGrabBankerButtons(pack.grab_times, pack.can_grab_times)
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
function SanGongReceiveHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack)
    dump(pack, '------广播玩家抢庄6013-----')
    local uid = pack.uid

    if uid == USER_INFO['uid'] then
        GamePlaneOperator:showControlButtons(2, false)
        GamePlaneOperator:showStageTxt('等待其他玩家操作...')
    end

    local grabTimes = pack.if_qiang

    if grabTimes > 0 then
        local playerType = SANGONG_PLAYERTYPE_TABLE[pack.uid]
        dump(SANGONG_PLAYERTYPE_TABLE, 'SVR_USER_QIANFGZHUANG_RESULT_BROADCAST_playerType')
        RANDOM_BANKER[uid] = grabTimes
        GamePlaneOperator:setGrabBankerSymbol(playerType)
        GamePlaneOperator:setGrabBankerTimes(playerType, grabTimes)
        SoundUtils:playCardKindEffect('qiangzhuang', SANGONG_USERINFO_TABLE[pack.uid].sex)
    else
        SoundUtils:playCardKindEffect('buqiang', SANGONG_USERINFO_TABLE[pack.uid].sex)
    end
end

--有人未准备，隐藏开始游戏按钮
function SanGongReceiveHandle:SERVER_COMMAND_REMAID_START_GAME_FAIL()
    GamePlaneOperator:RemaidStartGame(false)
end

function SanGongReceiveHandle:SVR_SEND_USED_CARDS(pack)
    USED_CARDS = pack.cards
end

--广播庄家id
function SanGongReceiveHandle:SVR_BRANK_BROADCAST(pack)
    dump(pack, '------广播庄家id 6003-----')

    if pack.uid == -1 or GAME_TYPE_NAME == '通比牛牛' then
        return
    end

    local broadcast_banker_delay = 0.1

    BANKER_UID = pack.uid

    GamePlaneOperator:showControlButtons(2, false)

    local BankerPlayerType = SANGONG_PLAYERTYPE_TABLE[pack.uid]

    GamePlaneOperator:stopTimer()

    --隐藏抢庄标记
    GamePlaneOperator:clearGrabBankerSymbol()

    if GAME_TYPE == 1 then
        local grab_bankers = {}

        if table.nums(RANDOM_BANKER) == 0 then
            GamePlaneOperator:showRandomBankerChoose(GAME_PARTICIPANTS)
            broadcast_banker_delay = 1.77
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
                broadcast_banker_delay = 1.77
                -- GamePlaneOperator:startTimer(2,"抢庄阶段")
                GamePlaneOperator:showStageTxt('随机庄家中...')
            end
        end
    end

    RANDOM_BANKER = {}

    SCENENOW['scene']:performWithDelay(
        function()
            if GAME_TYPE_NAME ~= '定庄牛牛' then
                GamePlaneOperator:showBankerChoose(pack.uid)
                SoundUtils:playEffect('定庄特效')
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
            local size = SanGongScene:getContentSize()
            local pos = cc.p(size.width / 2, size.height / 2)
            -- GamePlaneOperator:showHeadSymbol(BankerPlayerType,"banker",true)
            self:createArmature('niuniu_zhuang_1', pos, pack.uid, BankerPlayerType)

            -- SanGongScene:updateRoomInfo(nil,pack.uid)
        end,
        broadcast_banker_delay
    )
end

--广播加倍倍数
function SanGongReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack)
    dump(pack, '-----广播加倍倍数6014-----')

    local playerType = SANGONG_PLAYERTYPE_TABLE[pack.uid]
    GamePlaneOperator:setBetTimes(playerType, pack.base)

    if pack.uid == USER_INFO['uid'] then
        if GAME_CONFIG['买牛'] ~= true then
            GamePlaneOperator:showStageTxt('等待其他玩家加倍...')
        end
        GamePlaneOperator:showControlButtons(3, false)
    end
    local config_arr = string.split(baseChip, '/')
    local base = tonumber(config_arr[#config_arr])
    -- if pack.base > base then
    --     SoundUtils:playCardKindEffect("tuizhu", SANGONG_USERINFO_TABLE[pack.uid].sex)
    -- end
end

--广播开始游戏倒计时 下注 1100
function SanGongReceiveHandle:SVR_BROADCAST_WAIT_START(pack, isShowXiaZhu)
    GAME_IS_ENDING = 1
    GAME_OUT_CARD_COUNT = 1
    GAME_OVER_RANKING = 1
    IS_ON_RANKING = false
    dump(pack, '------广播开始游戏倒计时 1100------')
    local time = pack.time
    if time >= 0 then
        --GamePlaneOperator:loadBetButtons(GAME_CHIP_CONFIG,nil,nil,BASE_CHIP)
        GamePlaneOperator:loadXiaZhu(BASE_CHIP)
        GamePlaneOperator:initDiChi()
        --游戏开始时才清除数据
        if RELOGIN_FLAG ~= true then
        --GamePlaneOperator:clearGameDatas(2)
        end
        GamePlaneOperator:clearGameDatas(true)
        self:setBtnReady()
        GamePlaneOperator:showControlButtons(3, nil, isShowXiaZhu)
        SanGongScene:showShareButton(false)
        GamePlaneOperator:startTimer(time, '准备阶段')
    end

    RELOGIN_FLAG = false
end

--接收服务器放回的指定用户信息pack111
function SanGongReceiveHandle:SVR_CHARGE_BROADCAST(pack)
    local uid = pack.uid
    local playerType = SANGONG_PLAYERTYPE_TABLE[uid]
    local userInfo = SANGONG_USERINFO_TABLE[uid]
    if not (playerType and userInfo) then
        return
    end
    userInfo.gold = userInfo.gold + pack.chargeCoins / 100
    -- SanGongUtils:collectPlayerData(userInfo)
    GamePlaneOperator:setCoin(playerType, userInfo.gold)
end

--回看
function SanGongReceiveHandle:SERVER_COMMAND_GAMERESULT_RECORD(pack)
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
        local cardKind = userInfo.point
        if userInfo.type > 0 then
            cardKind = 10
        end
        pack.gameResult[i].xiazhu = pack.gameResult[i].xiazhu / 100
        local cardKind_imgPath = 'sangong/csb/player_plane/type/type_' .. cardKind .. '.png'
        pack.gameResult[i].cardType = cardKind_imgPath
        pack.gameResult[i].cardType_plist = 0 --1是plist 0不是
    end

    local CardsRoundRecord = SanGongPanel:getChildByName('CardsRoundRecord')
    if CardsRoundRecord then
        CardsRoundRecord:setData(pack)
    else
        local CardsRoundRecord = require('hall.common.CardsRoundRecord').new(pack)
        CardsRoundRecord:setName('CardsRoundRecord')
        CardsRoundRecord:setHandler(handler(SanGongSendHandle, SanGongSendHandle.CLI_COMMAND_GAMERESULT_RECORD))
        local zidx = ViewBase:getZOrderByChilds(SanGongPanel)
        CardsRoundRecord:addTo(SanGongPanel, zidx)
    end
end

return SanGongReceiveHandle
