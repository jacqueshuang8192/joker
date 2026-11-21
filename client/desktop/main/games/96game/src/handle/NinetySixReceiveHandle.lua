local hallHandle = require("hall.HallHandle")
local NinetySixDefine = require("96game.src.ctrl.NinetySixDefine")
local PROTOCOL = import("96game.src.handle.NinetySixProtocol")
local NinetySixReceiveHandle = class("NinetySixReceiveHandle", hallHandle)

function NinetySixReceiveHandle:ctor()
    NinetySixReceiveHandle.super.ctor(self)
    self.ctrl = nil
    self.logic = nil
    self.scene = nil
    self.totalSettlePack = nil

    local func_ = {
        --登录房间成功 1007
        [PROTOCOL.S_LOGIN_ROOM] = {handler(self, NinetySixReceiveHandle.S_LOGIN_ROOM)},
        --广播其他用户登录桌子 100D
        [PROTOCOL.S_LOGIN_ROOM_BROADCAST] = {handler(self, NinetySixReceiveHandle.S_LOGIN_ROOM_BROADCAST)},
        --进入房间失败
        [PROTOCOL.S_LOGIN_ROOM_FAIL] = {handler(self, NinetySixReceiveHandle.S_LOGIN_ROOM_FAIL)},
        --广播其他用户坐下（金币场） 1031
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, NinetySixReceiveHandle.BROADCAST_USER_SIT_DOWN)},
        --广播用户退出房间 1032
        [PROTOCOL.BROADCAST_USER_STAND_UP] = {handler(self, NinetySixReceiveHandle.BROADCAST_USER_STAND_UP)},
        --广播用户退出房间 100E
        [PROTOCOL.SVR_QUIT_ROOM] = {handler(self, NinetySixReceiveHandle.SVR_QUIT_ROOM)},
        --用户退出房间成功（自己）
        [PROTOCOL.SVR_QUICK_SUC] = {handler(self, NinetySixReceiveHandle.SVR_QUICK_SUC)},
        --0x2001    --广播用户准备
        [PROTOCOL.SERVER_READYNOW_ROOM] = {handler(self, NinetySixReceiveHandle.SERVER_READYNOW_ROOM)},
        --错误提示5001
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, NinetySixReceiveHandle.BROADCAST_ERROR_TIPS)},
        --111 广播玩家充值
        [PROTOCOL.SVR_CHARGE_BROADCAST] = {handler(self, NinetySixReceiveHandle.SVR_CHARGE_BROADCAST)},
        --5100，广播总结算
        [PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, NinetySixReceiveHandle.SVR_GROUP_BILLBOARD)},
        --组局回合信息
        [PROTOCOL.SVR_GROUP_TIME] = {handler(self, NinetySixReceiveHandle.SVR_GROUP_TIME)},

        --解散相关
        --没有此房间，解散房间失败
        [PROTOCOL.G2H_CMD_DISSOLVE_FAILED] = {handler(self, NinetySixReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},
        --广播桌子用户请求解散组局
        [PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
        --广播当前组局解散情况
        [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST] = {handler(self, NinetySixReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
        --广播桌子用户成功解散组局
        [PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
        --广播桌子用户解散组局 ，解散组局失败
        [PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},
        --接收服务器返回的语音表情视频文字 0214
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, NinetySixReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},
        --接收服务器返回801
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, NinetySixReceiveHandle.SERVER_CMD_MESSAGE)},
        --服务器返回托管
        [PROTOCOL.SVR_ROBOT] = {handler(self, NinetySixReceiveHandle.SVR_ROBOT)},

        [PROTOCOL.SERVER_COMMAND_DEAL_CARD] = {handler(self, NinetySixReceiveHandle.SERVER_COMMAND_DEAL_CARD)},
        [PROTOCOL.SERVER_BROADCAST_HALF_CHANGE_FULL] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_HALF_CHANGE_FULL)},
        [PROTOCOL.SERVER_BROADCAST_NO_USER_ACTIVE] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_NO_USER_ACTIVE)},
        [PROTOCOL.BROADCAST_USER_QUIT_ROOM] = {handler(self, NinetySixReceiveHandle.BROADCAST_USER_QUIT_ROOM)},
        [PROTOCOL.SERVER_BROADCAST_USER_CHI] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_USER_CHI)},
        [PROTOCOL.SERVER_BROADCAST_USER_ZHUA] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_USER_ZHUA)},
        [PROTOCOL.SERVER_BROADCAST_USER_PENG] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_USER_PENG)},
        [PROTOCOL.SERVER_BROADCAST_USER_ZOU] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_USER_ZOU)},
        [PROTOCOL.SERVER_BROADCAST_USER_SHAO] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_USER_SHAO)},
        [PROTOCOL.SERVER_BROADCAST_USER_TIE] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_USER_TIE)},
        [PROTOCOL.SERVER_COMMAND_TIP_CHI_CARD] = {handler(self, NinetySixReceiveHandle.SERVER_COMMAND_TIP_CHI_CARD)},
        [PROTOCOL.SERVER_COMMAND_TIP_TIE_CARD] = {handler(self, NinetySixReceiveHandle.SERVER_COMMAND_TIP_TIE_CARD)},
        [PROTOCOL.SERVER_COMMAND_TIP_HU_CARD] = {handler(self, NinetySixReceiveHandle.SERVER_COMMAND_TIP_HU_CARD)},
        [PROTOCOL.SERVER_BROADCAST_USER_OUT_CARD] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_USER_OUT_CARD)},
        [PROTOCOL.SERVER_BROADCAST_USER_PASS_CARD] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_USER_PASS_CARD)},
        [PROTOCOL.SERVER_BROADCAST_USER_BEGIN_OUT] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_USER_BEGIN_OUT)},
        [PROTOCOL.SERVER_BROADCAST_USER_FEN] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_USER_FEN)},
        [PROTOCOL.SERVER_BROADCAST_USER_JIANG] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_USER_JIANG)},
        [PROTOCOL.SERVER_SEND_TURN_RESULT] = {handler(self, NinetySixReceiveHandle.SERVER_SEND_TURN_RESULT)},
        [PROTOCOL.SERVER_SEND_TOTAL_RESULT] = {handler(self, NinetySixReceiveHandle.SERVER_SEND_TOTAL_RESULT)},
        [PROTOCOL.SERVER_COMMAND_RECONNECT_SUCCESS] = {handler(self, NinetySixReceiveHandle.SERVER_COMMAND_RECONNECT_SUCCESS)},
        [PROTOCOL.SERVER_BROADCAST_TING_CATDS] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_TING_CATDS)},
        [PROTOCOL.SERVER_BROADCAST_USER_PIAO] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_USER_PIAO)},
        [PROTOCOL.SERVER_BROADCAST_START_GAME] = {handler(self, NinetySixReceiveHandle.SERVER_BROADCAST_START_GAME)},
        [PROTOCOL.SERVER_COMMAND_GET_CARD] = {handler(self, NinetySixReceiveHandle.SERVER_COMMAND_GET_CARD)},
        [PROTOCOL.SERVER_COMMAND_USER_CARD] = {handler(self, NinetySixReceiveHandle.SERVER_COMMAND_USER_CARD)},


    }
    table.merge(self.func_, func_)
end

function NinetySixReceiveHandle:setCtrl(ctrl, logic, scene)
    self.ctrl = ctrl
    self.logic = logic
    self.scene = scene
end

--协议返回数据接收
function NinetySixReceiveHandle:callFunc(pack)
    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

--进入房间失败
function NinetySixReceiveHandle:S_LOGIN_ROOM_FAIL(pack)
    local tbErrorCode = {
        [0] = "成功创建新连接",
        [1] = "重连成功",
        [2] = "成功踢其他玩家",
        [3] = "玩家密匙错误",
        [4] = "数据库连接错误",
        [5] = "无此房间",
        [6] = "玩家登录房间错误",
        [7] = "房间人数已满", --"无房间分配",
        [8] = "没有空桌子",
        [9] = "玩家余额不足",
        [10] = "未知错误",
        [14] = "数据库缓存出错",
        [15] = "对不起，您不是VIP",
        [13] = "您当前不能进低分场",
        [12] = "相同IP",
        [16] = "密码错误",
        [17] = "要求携带钻石不足",
        [18] = "游戏已开始，无法加入游戏"
    }

    if tbErrorCode[pack.errorCode] then
        if pack.errorCode == 18 or pack.errorCode == 7 or pack.errorCode == 5 then
            local exitFunc = function()
                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
            end

            require("hall.GameTips"):showTips("提示", "", 2, tbErrorCode[pack.errorCode], nil, exitFunc)
        else
            require("hall.GameTips"):showTips("提示", "", 1, tbErrorCode[pack.errorCode])
        end
    else
        require("hall.GameTips"):showTips("提示", "", 1, "未知的错误")
    end
end

--登录房间 1007
function NinetySixReceiveHandle:S_LOGIN_ROOM(pack)
    dump(pack, "------登录房间------")
    -- USER_INFO["activity_id"] = pack.activityId
    USER_INFO["invote_code"] = pack.inviteCode
    -- GAME_STATE = pack.tableStatus
    HEART_BEAT_TID = USER_INFO["tid"]
    CLUB_ID = pack.club_id
    self.logic:setLoginRoom(pack)
    self.logic:setPlayers(pack.tPlayers)
     GameEvent:dispatch("NinetySixHideAi",pack.m_bAI)
    self.totalSettlePack = nil
end

--广播玩家退出返回（断线） 100E
function NinetySixReceiveHandle:SVR_QUIT_ROOM(pack)
    dump(pack, "------广播玩家退出返回100E------")
    GameEvent:dispatch("NinetySixPlayerDisconnect", pack.uid, true)
end

--提示玩家是否吃牌
function NinetySixReceiveHandle:SERVER_COMMAND_TIP_CHI_CARD(pack)
    dump(pack, "------提示玩家是否吃牌------")
    self.scene:hideTingCards()
    GameEvent:dispatch("NinetySixShowOption", 'chi', pack)
end
--提示玩家是否胡牌
function NinetySixReceiveHandle:SERVER_COMMAND_TIP_HU_CARD(pack)
    dump(pack, "------提示玩家是否胡牌------")
    self.scene:hideTingCards()
    GameEvent:dispatch("NinetySixShowOption", 'hu', pack)
end
--提示玩家是否贴牌
function NinetySixReceiveHandle:SERVER_COMMAND_TIP_TIE_CARD(pack)
    dump(pack, "------提示玩家是否贴牌------")
    self.scene:hideTingCards()
    GameEvent:dispatch("NinetySixShowOption", 'tie', pack)
end

--广播用户出牌
function NinetySixReceiveHandle:SERVER_BROADCAST_USER_OUT_CARD(pack)
    dump(pack, "------广播用户出牌------")
    local viewId = self.logic:getViewId(pack.seatId)
    GameEvent:dispatch("NinetySixPlayerOutCard", viewId, pack.cardId, true,true)
    self.logic:setCurOptSeatId(pack.curOptSeatId)
end

--广播用户过牌
function NinetySixReceiveHandle:SERVER_BROADCAST_USER_PASS_CARD(pack)
    dump(pack, "------广播用户过牌------")
    self.logic:setCurOptSeatId(pack.curOptSeatId)
    local viewId = self.logic:getViewId(pack.seatId)
    GameEvent:dispatch("NinetySixHideOption", viewId)
end

--广播用户开始出牌
function NinetySixReceiveHandle:SERVER_BROADCAST_USER_BEGIN_OUT(pack)
    dump(pack, "------广播用户开始出牌------")
end

--广播用户得分
function NinetySixReceiveHandle:SERVER_BROADCAST_USER_FEN(pack)
    dump(pack, "------广播用户得分------")
end

--广播用户得奖
function NinetySixReceiveHandle:SERVER_BROADCAST_USER_JIANG(pack)
    dump(pack, "------广播用户得奖------")
end

--单局结算
function NinetySixReceiveHandle:SERVER_SEND_TURN_RESULT(pack)
    --dump(pack, "---1208---单局结算------")
   GROUP_96 = true
    self.scene:hideTingCards()
    self.logic:upateTotalBlc(pack.tPlayers)
    if self.scene then
        --dump(pack, "---1208--yyyyyyyyyy-单局结算------")
        self.scene:showRoundSettle(pack)
    end
end

--总结算(已废弃)
function NinetySixReceiveHandle:SERVER_SEND_TOTAL_RESULT(pack)
    dump(pack, "------总结算0x1209------")
    if self.scene then
        self.scene:showTotalSettle(pack)
    end
end

--广播用户碰牌
function NinetySixReceiveHandle:SERVER_BROADCAST_USER_PENG(pack)
    dump(pack, "------广播用户碰牌------")
    self.logic:setCurOptSeatId(pack.curOptSeatId)
    local viewId = self.logic:getViewId(pack.seatId)
    if viewId == 1 then
        self.scene:hideTingCards()
    end
    GameEvent:dispatch("NinetySixPlayerGroupCard", viewId, pack.tCards, NinetySixDefine.PENG, true)
    GameEvent:dispatch("NinetySixUpdateHuXi", pack.seatId, pack.m_HuXi)
end

--广播用户走牌
function NinetySixReceiveHandle:SERVER_BROADCAST_USER_ZOU(pack)
    dump(pack, "------广播用户走牌------")
    self.logic:setCurOptSeatId(pack.curOptSeatId)
    local viewId = self.logic:getViewId(pack.seatId)
    if viewId == 1 then
        self.scene:hideTingCards()
    end
    print("pack.m_isZiMo",pack.m_isZiMo)
    GameEvent:dispatch("NinetySixPlayerGroupCard", viewId, pack.tCards, NinetySixDefine.ZOU, true,false,pack.m_isZiMo,pack.m_isSLXZ, pack.card_type)
    GameEvent:dispatch("NinetySixUpdateHuXi", pack.seatId, pack.m_HuXi)
end

--广播用户勺牌
function NinetySixReceiveHandle:SERVER_BROADCAST_USER_SHAO(pack)
    dump(pack, "------广播用户勺牌------")

    self.logic:setCurOptSeatId(pack.curOptSeatId)
    local viewId = self.logic:getViewId(pack.seatId)
    if viewId == 1 then
        self.scene:hideTingCards()
    end
    GameEvent:dispatch("NinetySixPlayerGroupCard", viewId, pack.tCards, NinetySixDefine.SHAO, true)
    GameEvent:dispatch("NinetySixUpdateHuXi", pack.seatId, pack.m_HuXi)
end

--广播用户贴牌
function NinetySixReceiveHandle:SERVER_BROADCAST_USER_TIE(pack)
    dump(pack, "------广播用户贴牌------")

    self.logic:setCurOptSeatId(pack.curOptSeatId)
    local viewId = self.logic:getViewId(pack.seatId)
    if viewId == 1 then
        self.scene:hideTingCards()
    end
    GameEvent:dispatch("NinetySixPlayerGroupCard", viewId, pack.tCards, NinetySixDefine.TIE, true)
    GameEvent:dispatch("NinetySixHideOption", viewId)
    GameEvent:dispatch("NinetySixUpdateHuXi", pack.seatId, pack.m_HuXi)
end

--广播用户吃牌
function NinetySixReceiveHandle:SERVER_BROADCAST_USER_CHI(pack)
    dump(pack, "------广播用户吃牌------")

    self.logic:setCurOptSeatId(pack.curOptSeatId)
    local viewId = self.logic:getViewId(pack.seatId)
    if viewId == 1 then
        self.scene:hideTingCards()
    end
    GameEvent:dispatch("NinetySixPlayerGroupCard", viewId, pack.tCards, NinetySixDefine.CHI, true, pack)
    GameEvent:dispatch("NinetySixHideOption", viewId)
    GameEvent:dispatch("NinetySixUpdateHuXi", pack.seatId, pack.m_HuXi)
end

--广播用户抓牌
function NinetySixReceiveHandle:SERVER_BROADCAST_USER_ZHUA(pack)
    dump(pack, "------广播用户抓牌------")

    self.logic:setCurOptSeatId(pack.curOptSeatId)
    self.logic:setDuoPai(pack.duoPai)
    local viewId = self.logic:getViewId(pack.seatId)
    if viewId == 1 then
        --self.scene:hideTingCards()
    end
    GameEvent:dispatch("NinetySixPlayerZhuaCard", viewId, pack.cardId, true)
end

--广播用户该牌无人操作（应用于玩家的摸牌或手牌打出去没有人要的场景）
function NinetySixReceiveHandle:SERVER_BROADCAST_NO_USER_ACTIVE(pack)
    dump(pack, "------广播用户该牌无人操作（应用于玩家的摸牌或手牌打出去没有人要的场景）------")

    self.logic:setCurOptSeatId(pack.curOptSeatId)
    local viewId = self.logic:getViewId(pack.seatId)
    GameEvent:dispatch("NinetySixPlayerNoUserOpt", viewId, pack.cardId)
end

--广播用户半招变满招
function NinetySixReceiveHandle:SERVER_BROADCAST_HALF_CHANGE_FULL(pack)
    dump(pack, "------广播用户半招变满招------")
    self.logic:setCurOptSeatId(pack.curOptSeatId)
    local viewId = self.logic:getViewId(pack.seatId)
    if viewId == 1 then
        self.scene:hideTingCards()
    end
    GameEvent:dispatch("NinetySixPlayerGroupCard", viewId, pack.tCards, NinetySixDefine.BAN_ZHAO_MAN_ZHAO, true, pack, pack.m_isZiMo)
    GameEvent:dispatch("NinetySixHideOption", viewId)
    GameEvent:dispatch("NinetySixUpdateHuXi", pack.seatId, pack.m_HuXi)
end

--服务端发牌
function NinetySixReceiveHandle:SERVER_COMMAND_DEAL_CARD(pack)
    dump(pack, "------服务端发牌------")
    GameEvent:dispatch("NinetySixShowStopTime")
    GROUP_96 = false
    self.scene:hideTingCards()
    self.scene:removeNinetySixRoundSettle()
    self.totalSettlePack = nil
    self.logic:setBankerSeat(pack.bankerSeatId)
    self.logic:setCurOptSeatId(pack.curOptSeatId)
    self.logic:setPlayerCards(pack.tCards, false)
    self.logic:setDuoPai(pack.duoPai)
end

--广播用户坐下 1031   其他用户进入房间
function NinetySixReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
    dump(pack, "------广播用户坐下1031------")
    self.logic:addPlayers(pack)
end

--5101 组局回合信息
function NinetySixReceiveHandle:SVR_GROUP_TIME(pack)
    self.logic:setRoundInfo(pack.curRound, pack.totalRound)
end


--广播用户登录桌子 100D   其他用户进入房间
function NinetySixReceiveHandle:S_LOGIN_ROOM_BROADCAST(pack)
    GameEvent:dispatch("NinetySixPlayerDisconnect", pack.uid, false)
end

--广播自己退出 1008   断线重连
function NinetySixReceiveHandle:SVR_QUICK_SUC(pack)
    --SCENENOW["scene"]:reConnect()
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end


--广播玩家站起 1032
function NinetySixReceiveHandle:BROADCAST_USER_STAND_UP(pack)
    dump(pack, "------广播玩家站起1032------")
    -- self.logic:delPlayers(pack.uid)
    -- if pack.uid == USER_INFO["uid"] and self.totalSettlePack == nil then
    --     self.ctrl:returnToHall()
    -- end
end

--5001
function NinetySixReceiveHandle:BROADCAST_ERROR_TIPS(pack)
    dump(pack, "-----返回错误提示5001-----")

    local errorCode = pack.errorCode
    local tbErrorCode = {
        [1] = "操作无效",
        [10] = "您正在游戏中",
        [11] = "您已经坐下了",
        [12] = "您已经准备过了",
        [13] = "您还没准备",
        [14] = "您已经坐下了",
        [15] = "您正在围观中",
        [16] = "桌子已经满啦",
        [17] = "玩家不存在",
        [18] = "您积分不够啦，请充值",
        [20] = "游戏未开始",
        [21] = "游戏正在进行中，请稍后...在做操作"
    }

    if errorCode == 18 then
        SCENENOW["scene"]:performWithDelay(
            function()
                --去掉提示弹框
                local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
                if layer_tips then
                    layer_tips:removeSelf()
                end

                if not isiOSVerify then
                    require("hall.GameTips"):showTips("提示", "", 2, "有玩家积分不足，已解散！")
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
        viewMgr:showTip({text = "未知的错误"})
    end

    if errorCode == 1 then
        GameEvent:dispatch("NinetySixCurErrorOpt")
    end
end


--0x2001    --广播用户准备
function NinetySixReceiveHandle:SERVER_READYNOW_ROOM(pack)
    dump(pack, "-------0x2001    --广播用户准备------")
    self.logic:setPlayerReady(pack.uid, pack.ready)
    
    if pack.uid == USER_INFO.uid then
        self.scene:removeNinetySixRoundSettle()
        GameEvent:dispatch("NinetySixNextRoundClean")
    end
    
end

----总结算 5100
function NinetySixReceiveHandle:SVR_GROUP_BILLBOARD(pack)
    dump(pack, "-----总结算5100-----")
    self.totalSettlePack = pack
    if GROUP_96 then
        if self.scene.isShowRund then
            GameEvent:dispatch("NinetySixSettlementButton")
        end
        --self.scene:performWithDelay(function()
        --    GameEvent:dispatch("NinetySixSettlementButton")
        --end, 2.1)

    else
        self:RUND_TOTAL(pack)
    end

end
function NinetySixReceiveHandle:RUND_TOTAL(pack)
    self.scene:hideTingCards()

    -- if self.scene then
    --     self.scene:showTotalSettle(pack)
    -- end

    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end
    local data = {}
    data["resultSceneType"] = 2 --战绩界面展示选择，1为长条形，2为方块形
    data["invote_code"] = self.logic.inviteCode --房间号
    data["fenchang"] = "" --分场
    data["round"] = GAME_ROUND --.."/"..GROUP_TOTAL_ROUND                  --局数
    data["date"] = os.date("%Y-%m-%d-%H:%M") --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
    data["activity_id"] = USER_INFO["activity_id"]
    data["resultData"] = {}

    for uid, user_info in pairs(pack.playerlist) do
        local user_result = {} --玩家数据实体
        user_result["nick"] = user_info["nickName"] --昵称
        user_result["uid"] = user_info.uid --uid
        user_result["icon_url"] = user_info["portrait"] --头像链接
        user_result["sex"] = user_info["sex"] --性别
        user_result["isRoomOwer"] = 0 --是否为房主，1是，非1或不填不是
        if user_info["chips"] > 0 then
            user_result["isWinner"] = 1 --是否为赢家，1是，非1或不填不是
        else
            user_result["isWinner"] = 0
        end
        user_result["total"] = user_info["chips"] --总输赢分

        user_result["gameDetail"] = {} --游戏详情数组
        local gameDetail1 = {} --游戏详情实体
        gameDetail1["showName"] = "赢的次数" --展示名
        gameDetail1["value"] = user_info["win_num"] or 0 --值

        local gameDetail2 = {}
        gameDetail2["showName"] = "输的次数"
        gameDetail2["value"] = user_info["lose_num"] or 0

        table.insert(user_result["gameDetail"], gameDetail1)
        table.insert(user_result["gameDetail"], gameDetail2)
        table.insert(data["resultData"], user_result)
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
function NinetySixReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)
    --dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")
    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")
end

--广播当前组局解散情况
function NinetySixReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)
    dump(pack, "-----广播当前组局解散情况-----")

    self.scene:hideTingCards()
    if g_isWatch == 0 then
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
function NinetySixReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)
    --dump(pack, "-----广播桌子用户请求解散组局-----")
    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")
end

--广播桌子用户成功解散组局
function NinetySixReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)
    --dump(pack, "-----广播桌子用户成功解散组局-----")

    bm.isDisbandSuccess = true
    if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
    end
    if not GROUP_96 then--没有单局结算的话
        if self.totalSettlePack then --总结算
           self:RUND_TOTAL(self.totalSettlePack)
        else
            dump("----444")
            --require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
        end
    end
    -- require("hall.GameTips"):showDisbandTips("解散房间成功","ddz_disbandGroup_success",3)
end

--广播桌子用户解散组局 ，解散组局失败
function NinetySixReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)
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
function NinetySixReceiveHandle:SVR_MSG_FACE(pack)
    local player = self.scene:getPlayerView(pack.uid)
    if player then
        self.scene.faceUI:showGetFace(pack.uid, pack.type, tonumber(player.data.sex), player.Head, false)
    else
        print("======表情消息错误1，未找到此玩家===>", pack.uid)
    end
end

function NinetySixReceiveHandle:showTextMessage(pack)
    local player = self.scene:getPlayerView(pack.uid)
    if player then
        self.scene.faceUI:showGetText(pack.uid, pack.textMessage, tonumber(player.data.sex), player.Head, false)
    else
        print("======表情消息错误2，未找到此玩家===>", pack.uid)
    end
end

function NinetySixReceiveHandle:showExpression(msg)
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

function NinetySixReceiveHandle:SERVER_CMD_MESSAGE(pack)
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
function NinetySixReceiveHandle:SVR_ROBOT(pack)
     if pack.uid == USER_INFO["uid"] then
        GameEvent:dispatch("NinetySixHideAi", pack.m_bAI)
     end
    
end

--广播玩家充值
function NinetySixReceiveHandle:SVR_CHARGE_BROADCAST(pack)
    dump(pack, "---------------------------广播玩家充值------------------------------")
end

function NinetySixReceiveHandle:BROADCAST_USER_QUIT_ROOM(pack)
    --用户自己退出还需要清理的数据需要补充好
    if self.logic.curRound < 1 then
        self.logic:delPlayers(pack.uid)
        if pack.uid == USER_INFO["uid"] and self.totalSettlePack == nil then
            self.ctrl:returnToHall()
        end
    end
end

--断线重连
function NinetySixReceiveHandle:SERVER_COMMAND_RECONNECT_SUCCESS(pack)
    dump(pack, "---------------------------断线重连------------------------------")
    self.totalSettlePack = nil
    CLUB_ID = pack.club_id
    GROUP_96 = false
    self.logic:setReconnection(pack)
    GameEvent:dispatch("NinetySixHideAi",pack.m_bAI)
    self.logic:setRoundInfo(pack.curRound, pack.totalRound)
    self.logic:setPlayers(pack.tPlayers)
    self.logic:setPlayerCards(pack.tCards, true)
    self.logic:reconnectionAllCards()
    self.logic:setCurOptSeatId(pack.curOptSeatId)
    self.logic:setDuoPai(pack.duoPai)
    self.logic:setTingCards(pack.tingCards)

    local args = {tCards = {}, opCard = pack.opCard}
    for k, v in ipairs(pack.opCards) do
        table.insert(args.tCards, v)
    end

    if pack.opCode == 1 then --提示吃
        GameEvent:dispatch("NinetySixShowOption", 'chi', args)
        GameEvent:dispatch("NinetySixPlayerZhuaCard", 1, pack.opCard, false)
    elseif pack.opCode == 3 then --提示贴
        GameEvent:dispatch("NinetySixShowOption", 'tie', args)
        GameEvent:dispatch("NinetySixPlayerZhuaCard", 1, pack.opCard, false)
    elseif pack.opCode == 7 then --提示贴
        GameEvent:dispatch("NinetySixShowOption", 'hu', args)
        GameEvent:dispatch("NinetySixPlayerZhuaCard", 1, pack.opCard, false)
    end
end

--广播用户听牌列表
function NinetySixReceiveHandle:SERVER_BROADCAST_TING_CATDS(pack)
    dump(pack, "---------------------------广播用户听牌列表------------------------------")
    self.logic:setTingCards(pack.tingCards)
end
function NinetySixReceiveHandle:SERVER_BROADCAST_START_GAME(pack)
    GROUP_96 = false
    GameEvent:dispatch("NinetySixShowOptionPiao", pack)
end
function NinetySixReceiveHandle:SERVER_BROADCAST_USER_PIAO(pack)
    print("piao   pack",pack.piaoFeng)
    GameEvent:dispatch("NinetySixUpdatePiao", pack.seatId, pack.piaoFeng)
end
function NinetySixReceiveHandle:SERVER_COMMAND_GET_CARD(pack)
    if pack.cardCount > 0 then
        local cheatLayer = require("96game.src.view.CheatCardLayer").new(self.scene,pack.cards)
        cheatLayer:setZOrder(999)
        cheatLayer:setName("CheatCardLayer")
        self.scene:addChild(cheatLayer)
    end

end
function NinetySixReceiveHandle:SERVER_COMMAND_USER_CARD(pack)
    if  self.scene:getChildByName("CheatCardLayer") then
        self.scene:getChildByName("CheatCardLayer"):removeSelf()
    end
end
return NinetySixReceiveHandle
