local hallHandle = require('hall.HallHandle')
local PROTOCOL = import('sangong_new.src.handle.SanGongProtocol')
local SanGongReceiveHandle = class('SanGongReceiveHandle', hallHandle)
local SanGongDefine = require("sangong_new.src.ctrl.SanGongDefine")

function SanGongReceiveHandle:ctor()
    SanGongReceiveHandle.super.ctor(self)
    self.ctrl = nil
    self.logic = nil
    self.scene = nil

    local func_ = {
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
        --接收服务器返回的语音表情视频文字 0214
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, SanGongReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},
        --接收服务器返回801
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, SanGongReceiveHandle.SERVER_CMD_MESSAGE)},
        -- 0x110A   --- 出牌时间
        [PROTOCOL.SERVER_BROADCAST_START_OUT_CARD] = {
            handler(self, SanGongReceiveHandle.SERVER_BROADCAST_START_OUT_CARD)
        },

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

        --0x1050回看
        [PROTOCOL.SERVER_COMMAND_GAMERESULT_RECORD] = {
            handler(self, SanGongReceiveHandle.SERVER_COMMAND_GAMERESULT_RECORD)
        }
    }

    table.merge(self.func_, func_)
end

function SanGongReceiveHandle:setCtrl(ctrl, logic, scene)
    self.ctrl = ctrl
    self.logic = logic
    self.scene = scene
end

--协议返回数据接收
function SanGongReceiveHandle:callFunc(pack)
    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

--显示开始游戏按钮 0x2006
function SanGongReceiveHandle:SERVER_BROADCAST_START_GAME(pack)
    dump(pack, '-----显示开始游戏按钮-----')
    if pack.star_game_uid == USER_INFO.uid then
        --隐藏准备，显示开始游戏
        if self.scene and self.scene.content and not self.logic.bIsWatch then
            self.scene.content:setStartBtnShow(true)
        end
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
    dump(pack, '-----SVR_LOGIN_ROOM 登录房间 1007-----')

    self.logic:setLoginRoom(pack)
    self.logic:setPlayers(pack.gamePlayerArr)

    USER_INFO['activity_id'] = pack.activityId
    USER_INFO['invote_code'] = pack.inviteCode
    HEART_BEAT_TID = USER_INFO['tid']

    if pack.club_id > 0 then
        CLUB_ID = pack.club_id
        USER_INFO['family_id'] = pack.club_id
    end
end

---------------------------------------------------------------------------------------------------------------

--广播用户登录桌子 100D   其他用户进入房间
function SanGongReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)
    dump(pack, '------SVR_LOGIN_ROOM_BROADCAST 广播用户登录桌子100D------')
    self.logic:addPlayers(pack)
end

--广播自己退出 1008
function SanGongReceiveHandle:SVR_QUICK_SUC(pack)
    dump(pack, '---广播自己退出---')
    require('hall.HallServer'):loginGameNew(USER_INFO['GroupLevel'], USER_INFO['tid'], USER_INFO['activity_id'], 1)
end

--广播玩家退出返回（断线） 100E
function SanGongReceiveHandle:SVR_QUIT_ROOM(pack)
    dump(pack, '------广播玩家退出返回100E------')
    self.logic:setPlayerOnLine(pack.uid, 0)
end

--广播用户坐下 1031   其他用户进入房间
function SanGongReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
    dump(pack, '------BROADCAST_USER_SIT_DOWN 其他用户进入房间------')
    self.logic:addPlayers(pack)
end

--广播玩家站起 1032
function SanGongReceiveHandle:BROADCAST_USER_STAND_UP(pack)
    dump(pack, '------广播玩家站起1032------')
    if pack.uid ~= USER_INFO["uid"] then
        self.logic:delPlayers(pack.uid)
    end
end

--广播玩家退出返回（离开房间） 1033
function SanGongReceiveHandle:BROADCAST_USER_QUIT_ROOM(pack)
    dump(pack, '------广播玩家退出返回1033------')
    self.logic:delPlayers(pack.uid)
    if pack.uid == USER_INFO["uid"] and self.totalSettlePack == nil then
        self.ctrl:returnToHall()
    end
end

--错误提示 5001
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
        self.scene:performWithDelay(
            function()
                --去掉提示弹框
                local layer_tips = self.scene:getChildByName('layer_tips')
                if layer_tips then
                    layer_tips:removeSelf()
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

--5101 局数
function SanGongReceiveHandle:SVR_GROUP_TIME(pack)
    dump(pack, '------SVR_GROUP_TIME组局信息------')
    --pack.time --组局时长
    self.logic:setRoundInfo(pack.round, pack.round_total or 999)
end

--广播玩家开启托管 1034
function SanGongReceiveHandle:BROADCAST_USER_AUTO_PLAY(pack)
    dump(pack, '------广播玩家开启托管 1034------')
    self.logic:setPlayerAuto(pack.uid, pack.isAuto)
end

--广播倒计时 100F
function SanGongReceiveHandle:SVR_BROADCAST_COUNT_DOWN(pack)
    dump(pack, '------广播倒计时 100F------')
    GameEvent:dispatch("SanGongCountDown", pack.time)
end

--0x2001    --广播用户准备
function SanGongReceiveHandle:SERVER_READYNOW_ROOM(pack)
    dump(pack, '-------广播用户准备------')
    self.logic:setPlayerReady(pack.uid, 1)
end

--1043玩家开始摊牌
function SanGongReceiveHandle:SVR_OPEN_CARDS_BROADCAST(pack)
    dump(pack, '-------玩家开始全部摊牌------')

    for k, p in pairs(pack.user_cards) do
        self.logic:setPlayerCardsByUid(p.uid, p.handCardArr)
    end

    -- local totalOpenCardTime = pack.openCardTime
end

--结算6008
function SanGongReceiveHandle:SVR_SETTLEMENT_BROADCAST(pack)
    dump(pack, '---广播游戏结算信息-----')
    self.logic:setGameStatus(SanGongDefine.END_STATUS)

    for k, v in pairs(pack.userinfo) do
        GameEvent:dispatch("SanGongSettlementPlayer", v)
    end
end

--组局排行榜 5100
function SanGongReceiveHandle:SVR_GROUP_BILLBOARD(pack)
    dump(pack, '-----组局排行榜5100-----')

    local data = {}
    data['resultSceneType'] = 2 --战绩界面展示选择，1为长条形，2为方块形
    data['invote_code'] = self.logic.inviteCode --房间号
    data['fenchang'] = '' --分场
    data['round'] = self.logic.curRound .. "/".. self.logic.totalRound     --局数
    data['date'] = os.date('%Y-%m-%d-%H:%M') --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
    data['activity_id'] = self.logic.activityId
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
        self.ctrl:returnToHall()
    end

    --再来一局
    local extend_action = function(sender, event)
        self.ctrl:onceAgain()
    end

    --分享按钮点击事件
    local share_action = function(sender, event)
        self.ctrl:doShareScreen()
    end
    -- require(GameResultScene_filePath):showScene(data, backHall_action, share_action)
    require("hall.settlement.settlement").new(data, backHall_action, share_action, nil, extend_action)
end

--------------------------------------周边功能-----------------------------------------
--组局解散相关
--没有此房间，解散房间失败
function SanGongReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)
    require('hall.GameTips'):showTips('提示', 'disbandGroup_fail', 2, '解散房间失败')
end

--广播当前组局解散情况
function SanGongReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)
    dump(pack, "-----广播当前组局解散情况-----")

    if self.logic.bIsWatch then
        return
    end

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
        local applyer_info = self.logic:getPlayerByUid(applyId)
        player_table["playerName"] = applyer_info and applyer_info.nickName or tostring(applyId)
        player_table["state"] = "申请"
        table.insert(disband_table, player_table)
    end

    local isMyAgree = 0
    if applyId ~= USER_INFO["uid"] then
        --假如申请者不是自己，添加自己的选择情况
        if agreeNum > 0 then
            for k, v in pairs(agreeMember_arr) do
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
    for k, v in pairs(self.logic.tPlayers) do
        local uid = v.uid
        --排除掉申请者，申请者不需要显示到这里
        if uid ~= applyId and uid ~= USER_INFO["uid"] then
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
            player_table["playerName"] = v.nickName
            if isAgree == 1 then
                player_table["state"] = "同意"
            else
                player_table["state"] = "等待选择"
            end
            player_table["icon"] = v.portrait
            table.insert(disband_table, player_table)
        end
    end

    local function agree_disband(value)
        self.ctrl.send:C2G_CMD_REPLY_DISSOLVE_ROOM(value)
    end

    if applyId == USER_INFO["uid"] then
        --假如申请者是自己，则直接显示其他用户的选择情况
        require("hall.GameTips"):showDisbandNewTips("提示", "agree_disbandGroup", 4, disband_table)
    else
        --申请者不是自己，根据自己的同意情况进行界面显示
        if isMyAgree == 1 then
            require("hall.GameTips"):showDisbandNewTips("提示", "agree_disbandGroup", 4, disband_table)
        else
            require("hall.GameTips"):showDisbandNewTips("提示", "new_request_disbandGroup", 1, disband_table, agree_disband)
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
    dump(pack, "-----广播桌子用户解散组局 ，解散组局失败-----")

    local rejectId = pack.rejectId
    if rejectId == USER_INFO["uid"] then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
    else
        local p = self.logic:getPlayerByUid(rejectId)
        local nickName = p and p.nickName or "路人甲"
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, nickName .. "拒绝解散房间")
    end
end

--聊天
function SanGongReceiveHandle:SVR_MSG_FACE(pack)
    local player = self.scene:getPlayerView(pack.uid)
    if player then
        self.scene.faceUI:showGetFace(pack.uid, pack.type, tonumber(player.data.sex), player.Head, false)
    else
        print("======表情消息错误1，未找到此玩家===>", pack.uid)
    end
end

function SanGongReceiveHandle:showTextMessage(pack)
    local player = self.scene:getPlayerView(pack.uid)
    if player then
        self.scene.faceUI:showGetText(pack.uid, pack.textMessage, tonumber(player.data.sex), player.Head, false)
    else
        print("======表情消息错误2，未找到此玩家===>", pack.uid)
    end
end

function SanGongReceiveHandle:showExpression(msg)
    local uid_from = tonumber(msg["uid_from"]) or 1
    local uid_to = tonumber(msg["uid_to"]) or 1
    local expressionType = tonumber(msg["expressionType"]) or 1

    local form_view = self.scene:getPlayerView(uid_from)
    local to_view = self.scene:getPlayerView(uid_to)
    if form_view and to_view then
        require("hall.view.animView.animView"):ShowAnimationByPosition(form_view.headWSPos.x, form_view.headWSPos.y, to_view.headWSPos.x, to_view.headWSPos.y, expressionType)
    else
        dump(msg, "==============showExpression error================")
    end
end

--接收服务器返回的组局信息
function SanGongReceiveHandle:SERVER_CMD_MESSAGE(pack)
    if bm.isInGame == false then
        return
    end

    local msg = json.decode(pack.msg)
    dump(msg, "-----SERVER_CMD_MESSAGE 表情-----")

    if msg ~= nil then
        local msgType = msg.msgType
        if msgType ~= nil and msgType ~= "" then
            if msgType == "expression" then --表情
                self:showExpression(msg)
            elseif msgType == "text" then --文字聊天
                self:showTextMessage(msg)
            elseif msgType == "emoji" then
                local emojiPack = {}
                emojiPack["uid"] = msg.uid
                emojiPack["type"] = msg.id
                self:SVR_MSG_FACE(emojiPack)
            elseif msgType == 'EmojiArmatureView' then --动态表情
                self:SVR_MSG_EMOJI_ARMATURE(msg)
            end

            if device.platform == "ios" then
                if msgType == "voice" then
                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                    require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)
                    --通知本地播放录音
                    local arr = {}
                    arr["url"] = msg.url
                    cct.getDateForApp("playVoice", arr, "V")
                elseif msgType == "video" then
                    local arr = {}
                    arr["url"] = msg.url
                    cct.getDateForApp("playVideo", arr, "V")
                end
            else
                if msgType == "voice" then
                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                    require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)
                    --通知本地播放录音
                    local data = {}
                    data["url"] = msg.url
                    local arr = {}
                    table.insert(arr, json.encode(data))
                    cct.getDateForApp("playVoice", arr, "V")
                elseif msgType == "video" then
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

function SanGongReceiveHandle:SVR_MSG_EMOJI_ARMATURE(pack)
    local uid_from = pack.uid
    local uid_to = pack.to_uid
    local emojiType = pack.type

    local form_view = self.scene:getPlayerView(uid_from)
    local to_view = self.scene:getPlayerView(uid_to)
    if form_view and to_view then
        self.scene.emojiView:showAnimi(to_view.headWSPos, form_view.headWSPos, emojiType)
    else
        dump(pack, "==============SVR_MSG_EMOJI_ARMATURE error================")
    end
end

----------------------------------------外围功能---------------------------------------------------

--请求录纸返回 1035
function SanGongReceiveHandle:SERVER_CMD_RECORD_PAPER(pack)
    dump(pack, "-----请求录纸返回SERVER_CMD_RECORD_PAPER  有打印时需接入-----")
end

--发牌相关
--处理发牌协议 4001 (第一次发标志着游戏的开始)
function SanGongReceiveHandle:SVR_SEND_USER_CARD(pack)
    self.logic:setPlayerCardsByUid(USER_INFO["uid"], pack.cards)

    for k, p in pairs(pack.users) do
        self.logic:setPlayerCardsBySeatId(p.seatId, p.cards)
    end

    GameEvent:dispatch("SanGongDealCards")
end

function SanGongReceiveHandle:SERVER_BROADCAST_START_YA(pack)
    dump(pack, '-----------开始押注SERVER_BROADCAST_START_YA-------------')
    GameEvent:dispatch("SanGongCountDown", pack.outCardAniTime)
    GameEvent:dispatch("SanGongSetBetSliderShow", true)
end

-- 0x1101   --- 广播押注
function SanGongReceiveHandle:SERVER_BROADCAST_YA(pack)
    dump(pack, '-----------广播押注SERVER_BROADCAST_YA-------------')
    
    GameEvent:dispatch("SanGongSetDiChi", true, pack.chip)
    GameEvent:dispatch("SanGongSetBetAndGold", pack.uid, pack.chip, pack.gold)
end

function SanGongReceiveHandle:SERVER_BROADCAST_CARD(pack)
    dump(pack, '-----------开始发牌SERVER_BROADCAST_CARD -------------')
    self.logic:setGameStatus(SanGongDefine.DEAL_STATUS)
    GameEvent:dispatch("SanGongCountDown", pack.outCardAniTime)
    GameEvent:dispatch("SanGongSetBetSliderShow", false)

    self.logic:setBankerSeat(pack.bankSeatId)
    for k, p in pairs(pack.gamePlayerArr) do
        self.logic:setPlayerCardsByUid(p.uid, p.handCardArr)
    end

    GameEvent:dispatch("SanGongDealCards")
    GameEvent:dispatch("SanGongSetFangPaiBtnShow", true)
end

--广播开始出牌
function SanGongReceiveHandle:SERVER_BROADCAST_START_OUT_CARD(pack)
    dump(pack, '-------SERVER_BROADCAST_START_OUT_CARD----------')
    self.logic:setGameStatus(SanGongDefine.OPEN_STATUS)
    GameEvent:dispatch("SanGongCountDown", pack.outCardAniTime)
    GameEvent:dispatch("SanGongSetLiangPaiBtnShow", true)
end

-- 0x1103   -- 广播出牌
function SanGongReceiveHandle:SERVER_BROADCAST_OUT_CARD(pack)
    dump(pack, '-------广播出牌SERVER_BROADCAST_OUT_CARD ----------')

    if pack.uid == USER_INFO["uid"] then
        GameEvent:dispatch("SanGongSetLiangPaiBtnShow", false)
    end
    GameEvent:dispatch("SanGongCountDown", pack.outCardAniTime)
    self.logic:setOpenCards(pack.uid, pack.handCardArr, pack.cards_type, pack.cards_point, pack.maxCard)
end

--0x1104   --- 开牌
function SanGongReceiveHandle:SERVER_BROADCAST_OPEN_CARD(pack) --开牌阶段
    dump(pack, '-------SERVER_BROADCAST_OPEN_CARD开牌 ----------')
    GameEvent:dispatch("SanGongSetLiangPaiBtnShow", false)
    GameEvent:dispatch("SanGongCountDown", pack.outCardAniTime)
    for _, pp in ipairs(pack.gamePlayerArr) do
        self.logic:setOpenCards(pp.uid, pp.handCardArr, pp.cards_type, pp.cards_point, pp.maxCard)
    end 
end

function SanGongReceiveHandle:SERVER_CMD_REQ_YAZHU_INFO(pack) --押注情况
    dump(pack, '-------SERVER_CMD_REQ_YAZHU_INFO押注情况 有打印时需接入----------')
end

function SanGongReceiveHandle:SERVER_CMD_REQ_YAZHU_DETAILS(pack)
    dump(pack, '----SERVER_CMD_REQ_YAZHU_DETAILS押注详情  有打印时需接入----')

end

function SanGongReceiveHandle:SERVER_NOTIFY_RESULT(pack)
    dump(pack, '----SERVER_NOTIFY_RESULT------')
    --pack.score ??
    self.logic:setPlayerGold(USER_INFO["uid"], pack.gold)
end

function SanGongReceiveHandle:SERVER_BROADCAST_GIVE_COINS(pack)
    dump(pack, '----SERVER_BROADCAST_GIVE_COINS-赠送----')
    self.logic:setPlayerGold(pack.fromUid, pack.fromCoins, true)
    self.logic:setPlayerGold(pack.toUid, pack.toCoins, true)

    require(GiveScene_filePath):removeScene()
    if pack.fromUid == USER_INFO['uid'] then
        require(CommonTips_filePath):showTips("提示", "", 3, "赠送成功")
    end
end

--0x1109--单局结算
function SanGongReceiveHandle:SERVER_BROADCAST_WINLOSE_COUNT(pack)
    dump(pack, '---SERVER_BROADCAST_WINLOSE_COUNT单局结算-有打印时需接入---')

end

function SanGongReceiveHandle:SERVER_CMD_REQ_TEST(pack)
    dump(pack, '---------------------------请求带控返回 测试1-这是什么鬼？---------------------')
end

function SanGongReceiveHandle:SERVER_CMD_TEST(pack)
    dump(pack, '---------------------------请求带控返回 测试2-这是什么鬼？------------------------------------')
end
---------------------------------------------------------------------------------------------------

--准备相关
--广播用户可以准备了
function SanGongReceiveHandle:SVR_READY_TIME(pack)
    dump(pack, '------广播用户可以准备了SVR_READY_TIME 6009------')
    GameEvent:dispatch("SanGongCountDown", pack.time)
end

--广播玩家准备 用户准备了返回
function SanGongReceiveHandle:SVR_READY_BROADCAST(pack)
    dump(pack, '------广播玩家准备6001------')
    self.logic:setPlayerReady(pack.uid, 1)
end

--所有人都已准备，广播可以开始游戏
function SanGongReceiveHandle:SERVER_COMMAND_REMAID_START_GAME()
    print("=====所有人都已准备，广播可以开始游戏=====")

    if self.scene and self.scene.content and not self.logic.bIsWatch then
        self.scene.content:setStartBtnShow(true)
    end
end

--广播游戏开始 6002
function SanGongReceiveHandle:SVR_BROADCAST_GAME_START(pack)
    -----------------------------游戏开始-------------------------------
    dump(pack, '=====广播游戏开始 SVR_BROADCAST_GAME_START=-有打印时需接入---====')
    --隐藏坐下 分享 开始 按钮 准备状态,未准备的进入旁观模式，已准备的发牌
end

--1041 广播下注剩余时间
function SanGongReceiveHandle:BROADCAST_SENDCARD_REMAINDTIME(pack)
    dump(pack, '-----广播下注剩余时间-----')
    GameEvent:dispatch("SanGongCountDown", pack.time)
end

--广播出牌阶段开始
function SanGongReceiveHandle:SVR_PLAY_CARD_BROADCAST(pack)
    dump(pack, '-----广播玩家开始出牌SVR_PLAY_CARD_BROADCAST-----')
    GameEvent:dispatch("SanGongCountDown", pack.time)
    --隐藏抢
end

--广播玩家钱数变化（用于扣取台费）
function SanGongReceiveHandle:SVR_CHIP_CHANGE_BROADCAST(pack)
    dump(pack, '-----广播玩家钱数变化（用于扣取台费）-----')
    for _, data in pairs(pack.userinfo) do
        self.logic:setPlayerGold(data.uid, data.change_chip, true)
    end 
end

--广播开始抢庄（游戏开始，第一阶段）
function SanGongReceiveHandle:SVR_BEGIN_QIANFGZHUANG_BROADCAST(pack)
    dump(pack, '-----广播开始抢庄SVR_BEGIN_QIANFGZHUANG_BROADCAST--有打印时需接入-----')

end

--处理抢庄  广播抢庄情况6013
function SanGongReceiveHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack)
    dump(pack, '------广播玩家抢庄SVR_USER_QIANFGZHUANG_RESULT_BROADCAST-有打印时需接入----')
end

--有人未准备，隐藏开始游戏按钮
function SanGongReceiveHandle:SERVER_COMMAND_REMAID_START_GAME_FAIL()

end

function SanGongReceiveHandle:SVR_SEND_USED_CARDS(pack)
    dump(pack, '------发送用户的牌信息SVR_SEND_USED_CARDS-有打印时需接入----')
end

--广播庄家id
function SanGongReceiveHandle:SVR_BRANK_BROADCAST(pack)
    dump(pack, '------SVR_BRANK_BROADCAST 广播庄家id 有打印时需接入-----')

end

--广播加倍倍数
function SanGongReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack)
    dump(pack, '-----广播加倍倍数6014-有打印时需接入----')

end

--广播开始游戏倒计时 下注 1100
function SanGongReceiveHandle:SVR_BROADCAST_WAIT_START(pack, isShowXiaZhu)
    dump(pack, '------广播开始游戏倒计时 SVR_BROADCAST_WAIT_START------')
    GameEvent:dispatch("SanGongCountDown", pack.time)
    GameEvent:dispatch("SanGongSetBetSliderShow", true)
    self.logic:setGameStatus(SanGongDefine.BET_STATUS)
end

--接收服务器放回的指定用户信息pack111
function SanGongReceiveHandle:SVR_CHARGE_BROADCAST(pack)
    dump(pack, '------SVR_CHARGE_BROADCAST广播充值信息-----')
    self.logic:setPlayerGold(data.uid, data.chargeCoins, true)
end

--回看
function SanGongReceiveHandle:SERVER_COMMAND_GAMERESULT_RECORD(pack)
    dump(pack, 'SERVER_COMMAND_GAMERESULT_RECORD')

    if #pack.gameResult == 0 then
        viewMgr:showTip({text = '无当前所选局数回看！'})
        return
    end

    local Card = require('hall.PokerCard')
    for i, userInfo in ipairs(pack.gameResult) do
        for idx, value in ipairs(userInfo.cards) do
            local cardNode = Card.new(0.6)
            cardNode:setCardId(value)
            cardNode:showFront()
            pack.gameResult[i].cards[idx] = cardNode
        end
        local cardKind = userInfo.cards_point
        if userInfo.cards_type > 0 then
            cardKind = 10
        end
        pack.gameResult[i].xiazhu = pack.gameResult[i].xiazhu / 100
        local cardKind_imgPath = 'sangong_new/res/images/card_type_' .. cardKind .. '.png'
        pack.gameResult[i].cardType = cardKind_imgPath
        pack.gameResult[i].cardType_plist = 1 --1是plist 0不是
    end

    local CardsRoundRecord = self.scene:getChildByName('CardsRoundRecord')
    if CardsRoundRecord then
        CardsRoundRecord:setData(pack)
    else
        local CardsRoundRecord = require('hall.common.CardsRoundRecord').new(pack)
        CardsRoundRecord:setName('CardsRoundRecord')
        CardsRoundRecord:setHandler(handler(self.ctrl.send, self.ctrl.send.CLI_COMMAND_GAMERESULT_RECORD))
        CardsRoundRecord:addTo(self.scene)
    end
end

return SanGongReceiveHandle
