require("framework.init")
--加载大厅请求处理
local hallHandle = require("hall.HallHandle")
local Handle = class("Handle", hallHandle)
local Protocol = import("baijiale100.src.handle.Protocol")
local Server = import("baijiale100.src.handle.Server")
local eventName = "baijiale100"..os.now()

function Handle:ctor(gameScene)
    Handle.super.ctor(self)
    self.gameScene = gameScene
    self.GameSceneView = gameScene.GameSceneView
    self.Config = gameScene.Config
    self.frozenEvents = {}
    self.packIdx = 0

    local func_ = {
        --登陆房间成功返回
        [Protocol.SVR_LOGIN_ROOM_OK] = {handler(self, self.SVR_LOGIN_ROOM_OK)},
        [Protocol.SVR_RELOAD_ROOM] = {handler(self, self.SVR_RELOAD_ROOM)},--用户重连进房间返回
        --其他用户进入房间广播
        [Protocol.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, self.SVR_LOGIN_ROOM_BROADCAST)},
        [Protocol.SVR_LOGOUT_ROOM_OK] = {handler(self, self.SVR_LOGOUT_ROOM_OK)},--服务器返回玩家退出游戏成功
        [Protocol.SVR_LOGOUT_ROOM] = {handler(self, self.SVR_LOGOUT_ROOM)},--服务器广播玩家退出 100E
        [Protocol.SVR_QUICK_SUC] = {handler(self, self.SVR_QUICK_SUC)},--广播自己退出 1008
        --1031玩家坐下
        [Protocol.BROADCAST_USER_SIT_DOWN] = {handler(self, self.BROADCAST_USER_SIT_DOWN)},
        --1032玩家站起
        [Protocol.BROADCAST_USER_STAND_UP] = {handler(self, self.BROADCAST_USER_STAND_UP)},
        --1033玩家离开房间
        [Protocol.SVR_BROADCAST_USER_LEAVEROOM] = {handler(self, self.SVR_BROADCAST_USER_LEAVEROOM)},
        --错误提示5001
        [Protocol.BROADCAST_ERROR_TIPS] = {handler(self, self.BROADCAST_ERROR_TIPS)},
        -- [Protocol.SVR_CHIP_CHANGE_BROADCAST] = {handler(self, self.SVR_CHIP_CHANGE_BROADCAST)},--扣除台费 4800
        -- [Protocol.SVR_CHARGE_BROADCAST] = {handler(self, self.SVR_CHARGE_BROADCAST)},--接收服务器放回的指定用户信息pack111
        [Protocol.SERVER_CMD_MESSAGE] = {handler(self, self.SERVER_CMD_MESSAGE), ""},--服务器返回组局收到的信息

        --没有此房间，解散房间失败
        [Protocol.G2H_CMD_DISSOLVE_FAILED] = {handler(self, self.G2H_CMD_DISSOLVE_FAILED)},
        --广播桌子用户请求解散组局
        [Protocol.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {handler(self, self.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
        --广播当前组局解散情况
        [Protocol.G2H_CMD_REFRESH_DISSOLVE_LIST] = {handler(self, self.G2H_CMD_REFRESH_DISSOLVE_LIST)},
        --广播桌子用户成功解散组局
        [Protocol.SERVER_BROADCAST_DISSOLVE_GROUP] = {handler(self, self.SERVER_BROADCAST_DISSOLVE_GROUP)},
        --广播桌子用户解散组局 ，解散组局失败
        [Protocol.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP] = {handler(self, self.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},


        [Protocol.SERVER_BROADCAST_USER_BET_SCORE] = {handler(self, self.SERVER_BROADCAST_USER_BET_SCORE), ""},----广播玩家下注
        [Protocol.SERVER_BROADCAST_START_BET] = {handler(self, self.SERVER_BROADCAST_START_BET), ""},----广播开始下注
        [Protocol.SERVER_BROADCAST_STOP_BET] = {handler(self, self.SERVER_BROADCAST_STOP_BET), ""},----广播停止下注
        [Protocol.SERVER_COMMAND_USER_APPLY_BANKER] = {handler(self, self.SERVER_COMMAND_USER_APPLY_BANKER), ""},----申请上庄
        [Protocol.SERVER_COMMAND_USER_LOOK_TREND] = {handler(self, self.SERVER_COMMAND_USER_LOOK_TREND), ""},----走势图
        [Protocol.SERVER_BROADCAST_MOST_GLOD_USER] = {handler(self, self.SERVER_BROADCAST_MOST_GLOD_USER), ""},----广播大富豪
        [Protocol.SERVER_BROADCAST_BANKER_USER] = {handler(self, self.SERVER_BROADCAST_BANKER_USER), ""},----广播新庄家
        [Protocol.SERVER_SEND_TURN_RESULT] = {handler(self, self.SERVER_SEND_TURN_RESULT), ""},----单局结算
        [Protocol.SERVER_BROADCAST_USER_RECORD] = {handler(self, self.SERVER_BROADCAST_USER_RECORD), ""},----玩家列表（20局战绩）
    }
    table.merge(self.func_, func_)
    self:addHandleMgr()

end
function Handle:addHandleMgr()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self._eventHandles = {}
    for cmd,v in pairs(self.func_) do
        self._eventHandles[eventName..cmd] = self:addEventListener(eventName..cmd, handler(self, self.handleEventMgr))
    end
end
function Handle:handleEventMgr( event )
    local pack = event.pack
    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

function Handle:delHandleMgr()   --当场景销毁时应该删除事件 调用此方法
    for cmd,handler in pairs(self.func_) do
        local eventHandle = self._eventHandles[eventName..cmd]
        self:removeEventListener(eventHandle)
        self._eventHandles[eventName..cmd] = nil
    end
end


function Handle:callFunc(pack)
    dump(pack.cmd, "当前游戏解析协议号")

    if SCENENOW["name"] ~= "baijiale100.gameScene" then
        return
    end
    local cmd = pack.cmd
    pack.now = os.now()

    -- if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
    --     self.func_[pack.cmd][1](pack)
    -- end
    self:dispatchEvent({ name = eventName..cmd, pack = pack})
end

function Handle:getPlayerBySeatId( seatId )
    return self.GameSceneView:getPlayerBySeatId( seatId )
end
function Handle:getBankerPlayerByUid( uid )
    return self.GameSceneView:getBankerPlayerByUid( uid )
end
---------------------------------------房间相关-------------------------------
--5001
function Handle:BROADCAST_ERROR_TIPS(pack)
    dump(pack, "-----返回错误提示5001-----")
    local errorCode = pack.errorCode
    local tbErrorCode = {
        [1] = "操作无效",
        [10] = "游戏进行中",
        [11] = "您选的座位上已经有人了",
        [12] = "您已经准备过了",
        [13] = "您还没准备",
        [14] = "您已经坐下了",
        [15] = "您正在围观中",
        [16] = "桌子已经满啦",
        [17] = "玩家不存在",
        [18] = "您的积分不够了",
        [19] = "游戏未开始",
        [20] = "无法在当前阶段做此操作！",
        [21] = "下注超过上限",
        [22] = "您在座位上时不能坐庄！",
        [100] = "超出下注限制",
        [101] = "低于申请上庄分",
        [102] = "当前状态不能下庄",
    }
    if errorCode == 18 then
        SCENENOW["scene"]:performWithDelay(
            function()
                --去掉提示弹框
                local layer_tips = SCENENOW["scene"]:getTag(99998)
                if layer_tips then
                    layer_tips:removeSelf()
                end

                if not isiOSVerify then
                    SCENENOW["scene"]:requestCharge()
                end
            end,
            1.5
        )
    end

    dump(tbErrorCode[errorCode], "错误提示")
    local paras = {}
    paras.type = 1
    paras.title = "提示"
    paras.content = tbErrorCode[errorCode] == nil and "未知的错误" or tbErrorCode[errorCode]
    require("hall.tips.CommonTips"):showTips(paras)
end


--广播自己退出 1008
function Handle:SVR_QUICK_SUC(pack)
    dump(pack)
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end

--进入房间 1007 牌局没开始 or 等待玩家准备的过程中的重连
function Handle:SVR_LOGIN_ROOM_OK(pack)
    dump(pack,"SVR_LOGIN_ROOM_OK")
    USER_INFO["configData"]=pack.roomConfigStr
    HEART_BEAT_TID = USER_INFO.tid--大厅用必要
    CLUB_ID = pack.clubId
    USER_INFO.family_id = pack.clubId

    require(NetworkLoadingView_filePath):removeView(888)
    pack.roomConfigStr = json.decode(pack.roomConfigStr)
    g_101.gameConfig = pack.roomConfigStr
    g_101.OwnerID = pack.OwnerID
    self.GameSceneView:setRoomId( pack.inviteCode )
    g_101.gameStatus = pack.gameStatus

    for k,v in ipairs(pack.playerList) do
        if v.uid == USER_INFO.uid then
            g_101.my_seat_id = v.seat_id
            self.GameSceneView:setMyScore(v.chips/100)
        end
    end

    --将其他玩家的信息记录下来
    self.firstEnter = g_101.my_seat_id == -1 and USER_INFO.isWatch ~= 0--不是观战
    if self.firstEnter then
        self.playerList = pack.playerList
    else
        for k,v in ipairs(pack.playerList) do
            local uid = v.uid
            local seat_id = v.seat_id
            if seat_id ~= -1 then
                local viewId = self.gameScene:getViewIdBySeatId(seat_id)
                self.Config:addUser( uid, seat_id, viewId, v )
                local UserInfoView = self:getPlayerBySeatId( v.seat_id )
                if UserInfoView then
                    UserInfoView:show()
                    UserInfoView:refreshPlayerInfo(v.portrait, v.uid, v.sex, v.nickname, v.ip, v.addres)
                    -- UserInfoView:isShowNewWork(v.if_online == 0)
                end
            end
        end
    end

    g_101.recordData = pack.trendList
    for i,v in ipairs(pack.trendList) do
        self.GameSceneView:setGameResult(v)
    end
    self:SERVER_BROADCAST_BANKER_USER(pack)--广播新庄家
end

--玩家重登，进入游戏 1009
function Handle:SVR_RELOAD_ROOM(pack)
    require(NetworkLoadingView_filePath):removeView(888)
    dump(pack, "SVR_RELOAD_ROOM")
    USER_INFO.family_id = pack.clubId
    USER_INFO.invote_code = pack["inviteCode"]
    USER_INFO.configData = pack.roomConfigStr
    HEART_BEAT_TID = USER_INFO.tid--大厅用必要
    CLUB_ID = pack.clubId
    g_101.OwnerID = pack.OwnerID
    g_101.gameStatus = pack.gameStatus
    self.GameSceneView:clearData()
    pack.roomConfigStr = json.decode(pack.roomConfigStr)
    g_101.gameConfig = pack.roomConfigStr
    self.GameSceneView:setRoomId( pack.inviteCode )
    for k,v in ipairs(pack.playerList) do
        if v.uid == USER_INFO.uid then
            g_101.my_seat_id = v.seat_id
            self.GameSceneView:setMyScore(v.chips/100)
        end
    end
    --将其他玩家的信息记录下来
    self.firstEnter = g_101.my_seat_id == -1 and USER_INFO.isWatch ~= 0--不是观战
    if self.firstEnter then
        self.playerList = pack.playerList
    else
        for k,v in ipairs(pack.playerList) do
            local uid = v.uid
            local seat_id = v.seat_id
            if seat_id ~= -1 then
                local viewId = self.gameScene:getViewIdBySeatId(seat_id)
                self.Config:addUser( uid, seat_id, viewId, v )
                local UserInfoView = self:getPlayerBySeatId( v.seat_id )
                if UserInfoView then
                    UserInfoView:show()
                    UserInfoView:refreshPlayerInfo(v.portrait, v.uid, v.sex, v.nickname, v.ip, v.addres)
                end
            end
        end
    end
    g_101.recordData = pack.trendList
    for i,v in ipairs(pack.trendList) do
        self.GameSceneView:setGameResult(v)
    end
    self:SERVER_BROADCAST_BANKER_USER(pack)--广播新庄家
end

--其他用户进入房间 100D
function Handle:SVR_LOGIN_ROOM_BROADCAST(pack)
	print("=====服务器广播用户登陆房间======")
    dump(pack,"SVR_LOGIN_ROOM_BROADCAST")
    local seat_id = pack.seat_id
    local uid = pack.uid
    local viewId = self.gameScene:getViewIdBySeatId(seat_id)
    self.Config:addUser( uid, seat_id, viewId, pack )

    if uid == USER_INFO.uid then
        g_101.my_seat_id = seat_id
        self.GameSceneView:setMyScore(pack.chips/100)
        self.GameSceneView:updateChipPnlStatus()
    end
    if g_101.userInfos(uid) then--已添加
        dump(pack,"qwe")
        return
    end
    if uid == USER_INFO.uid and seat_id >= 0 then
        g_101.my_seat_id = seat_id
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        if UserInfoView then
            UserInfoView:show()
            UserInfoView:refreshPlayerInfo(pack.portrait, uid, pack.sex, pack.nickName, pack.ip, pack.addres)
        end
    end
end

--服务器广播玩家退出 100E
function Handle:SVR_LOGOUT_ROOM(pack)
    local uid = pack.uid
    local userInfo = g_101.userInfos(uid)
    if not (userInfo) then return end
    local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
    UserInfoView:isShowNewWork(true) 
end

--广播用户坐下 1031   其他用户进入房间
function Handle:BROADCAST_USER_SIT_DOWN(pack)
    dump(pack, "=====有玩家进来了啦！！！====")
    local seat_id = pack.seat_id
    local uid = pack.uid
    if uid == USER_INFO.uid then
        g_101.my_seat_id = seat_id
        self.GameSceneView:setMyScore(pack.chips/100)
        self.GameSceneView:updateChipPnlStatus()
    end
    local viewId = self.gameScene:getViewIdBySeatId(seat_id)
    self.Config:addUser( uid, seat_id, viewId, pack )
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    if UserInfoView then
        UserInfoView:show()
        UserInfoView:refreshPlayerInfo(pack.portrait,uid,pack.sex,pack.nickName, pack.ip, pack.addres)
    end
end

--广播玩家站起 1032
function Handle:BROADCAST_USER_STAND_UP(pack)
end

--1033
function Handle:SVR_BROADCAST_USER_LEAVEROOM(pack)
    if g_101.m_isGameOver then return end
    local uid = pack.uid
    if  uid == USER_INFO.uid then 
        if g_101.settlementData then
            self.GameSceneView:settlement(g_101.settlementData)
        else
            require("hall.GameCommon"):gExitGroupGame(USER_INFO.enter_mode, CLUB_ID)
        end
    else
        local seat_id = g_101.userInfos(uid).seat_id
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        if UserInfoView then
            UserInfoView:hide()
            self.Config:delUser(uid)
        end
    end
end

--玩家进入私人房 0212
function Handle:SVR_ENTER_PRIVATE_ROOM(pack)
    -- require("hall.GameTips"):showTips("您被卡在私人房中,请联系客服处理")
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
end


--服务器返回自己退出
function Handle:SVR_LOGOUT_ROOM_OK(pack)

end

--扣除台费 4800
function Handle:SVR_CHIP_CHANGE_BROADCAST(pack)
    dump(pack,"扣除台费 4800")
    for _,data in pairs(pack.userinfo) do
        local uid = data.uid
        local userInfo = g_101.userInfos(uid)
        if not (userInfo) then return end
        userInfo.m_chips = userInfo.m_chips + data.chargeCoins
        local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
        UserInfoView:setScore(userInfo.m_chips)
    end
end

--组局解散相关
--没有此房间，解散房间失败
function Handle:G2H_CMD_DISSOLVE_FAILED(pack)
    --dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")
    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")
end

--广播当前组局解散情况
function Handle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)
    dump(pack, "-----广播当前组局解散情况-----")
end

--广播桌子用户请求解散组局
function Handle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)
    --dump(pack, "-----广播桌子用户请求解散组局-----")
    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")
end

--广播桌子用户成功解散组局
function Handle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)
    if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
	end
end

--广播桌子用户解散组局 ，解散组局失败
function Handle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)
    local userLst = {USER_INFO}
    for i, v in pairs( g_101.allUser or {} ) do
        table.insert(userLst, v)
    end
    local name = ""
    for i, v in ipairs( userLst ) do
        if pack.rejectId == v.uid then
            name = v.nick or v.nickName
        end
    end

    local rejectId = pack.rejectId
    if rejectId == USER_INFO.uid then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
    else
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2,  name .. "拒绝解散房间")
    end
end


-----------------------------------------------------------------------------------------------------------------------------
function Handle:showExpression(msg)
    local uid_from = tonumber(msg["uid_from"]) or 1
    local uid_to = tonumber(msg["uid_to"]) or 1
    local expressionType = tonumber(msg["expressionType"]) or 1

    ---------------------------------不同游戏需修改的部分----------------------------
    -- --通过UID获取seatId
    -- local seatId_from = DDZ_SEAT_TABLE[uid_from] or 2
    -- local seatId_to =  DDZ_SEAT_TABLE[seatId_to] or 0

    --制定座位号对应的动画播放起始和结束的大概位置
    local PLAYER_HEADS_POSITION_TABLE = PLAYER_HEADS_POSITION_TABLE or {}
    ------------------------------------------------------------------------------------
    local from_x = PLAYER_HEADS_POSITION_TABLE[uid_from].x
    local from_y = PLAYER_HEADS_POSITION_TABLE[uid_from].y

    local to_x = PLAYER_HEADS_POSITION_TABLE[uid_to].x
    local to_y = PLAYER_HEADS_POSITION_TABLE[uid_to].y

    require("hall.view.animView.animView"):ShowAnimationByPosition(from_x, from_y, to_x, to_y, expressionType)
end

function Handle:showTextMessage(pack)
    local s = SCENENOW["scene"]:getChildByName("faceUI")

    local uid = pack.uid
    local seatId = DDZ_SEAT_TABLE[uid]
    local playerType = ddzSettings:getPlayerType(seatId)

    local isLeft = false
    if playerType == CARD_PLAYERTYPE_RIGHT then
        isLeft = true
    end

    local node_head = PLAYER_HEADS_TABLE[uid] --GamePlaneOperator:getPlayerHeadPlane(playerType)

    s:showGetText(uid, pack.textMessage, tonumber(sex), node_head, isLeft)
end

--接收服务器返回的组局信息
function Handle:SERVER_CMD_MESSAGE(pack)
    if bm.isInGame == false then
        return
    end
    local msg = json.decode(pack.msg)
    if msg ~= nil then
        local msgType = msg.msgType
        local uid = msg.uid
        local seat_id = g_101.userInfos(uid).seat_id
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        local pos = UserInfoView:getWorldpoint()
        if msgType ~= nil and msgType ~= "" then
            -- if msgType == "expression" then   --表情
            --     self:showExpression(msg)
            -- elseif  msgType == "emoji" then   --文字聊天
            --     self:SVR_MSG_FACE(msg)
            -- elseif  msgType == "EmojiArmatureView" then   --文字聊天
            --     self:SVR_MSG_EMOJI_ARMATURE(msg)
            -- end
            if device.platform == "ios" then
                if msgType == "voice" then
                    dump("voice", "-----接收服务器返回的组局信息-----")
                    require("hall.view.voicePlayView.NewVoicePlayView"):showView(pos, msg.voiceTime)
                    --通知本地播放录音
                    local arr = {}
                    arr["url"] = msg.url
                    cct.getDateForApp("playVoice", arr, "V")
                elseif msgType == "video" then
                    dump("video", "-----接收服务器返回的组局信息-----")
                    local arr = {}
                    arr["url"] = msg.url
                    cct.getDateForApp("playVideo", arr, "V")
                end
            else
                if msgType == "voice" then
                    dump("voice", "-----接收服务器返回的组局信息-----")
                    require("hall.view.voicePlayView.NewVoicePlayView"):showView(pos, msg.voiceTime)
                    --通知本地播放录音
                    local data = {}
                    data["url"] = msg.url
                    local arr = {}
                    table.insert(arr, json.encode(data))
                    cct.getDateForApp("playVoice", arr, "V")
                elseif msgType == "video" then
                    dump("video", "-----接收服务器返回的组局信息-----")
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

function Handle:SVR_MSG_EMOJI_ARMATURE(pack)
    local EmojiArmatureView = SCENENOW.scene:getChildByName("EmojiArmatureView")
    if not EmojiArmatureView then
        return
    end
    local from_id = pack.uid
    local to_uid = pack.to_uid
    local emojiType = pack.type
    --local from_seatId = 0
    dump(pack, "接收表情的显示------")
    if from_id and to_uid then
        local fromPos = PLAYER_HEADS_POSITION_TABLE_FACE[from_id]
        local toPos = PLAYER_HEADS_POSITION_TABLE_FACE[to_uid]
        if toPos and fromPos then
            EmojiArmatureView:showAnimi(toPos, fromPos, emojiType)
        end
    end
end

function Handle:SVR_SEND_MINGPAI_REMIND(pack)
    dump(pack, "SVR_SEND_MINGPAI_REMIND")
    dump(pack.HandCardDatas, "SVR_SEND_MINGPAI_REMIND_HandCardDatas")

    for k, v in pairs(pack.HandCardDatas) do
        local card_data = clone(v.card_datas)
        card_data = g_mainScene.playerInfoLayer:exchangeCardsValue(card_data)
        g_mainScene.tableLayer:ShowPlayCard(v.user_id, card_data)
    end
end

function Handle:SERVER_SEND_SINGE_DATA(pack)
    g_mainScene.playerInfoLayer:showCheckTip(pack["uid"])
end

--接收服务器放回的指定用户信息pack111
function Handle:SVR_CHARGE_BROADCAST(pack)
    dump(pack,"pack111")
    local uid = pack.uid
    local userInfo = g_101.userInfos(uid)
    if not (userInfo) then return end
    userInfo.m_chips = userInfo.m_chips + pack.chargeCoins

    local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
    UserInfoView:setScore(userInfo.m_chips)

    --上分提示
    for k,v in pairs(g_101.allUser) do
        if pack.uid == k then
            local str = require('hall.GameCommon'):formatNick(v.nickName, 4) .. "(" .. pack.uid .. ")"
            viewMgr:showTip({text = "玩家:" .. str .. "被上" .. ( pack.chargeCoins / 100) .. "积分"})
        end
    end
end



------------------------------------游戏逻辑相关---------------------------
---广播玩家下注
function Handle:SERVER_BROADCAST_USER_BET_SCORE(pack)--广播玩家下注
    dump(pack, "--广播玩家下注")
    local betScore = pack.betScore
    local uid = pack.uid
    self.GameSceneView:setXZScore(pack.totalLongScore, pack.totalHuScore, pack.totalHeScore)
    self.GameSceneView:setMaxKXZ(pack.surpLongMaxScore, pack.surpHuMaxScore, pack.surpHeMaxScore)
    self.GameSceneView:playerXZ(uid, betScore, pack.betType)
    local userInfo = g_101.updateChips(uid)
    local chips = userInfo.chips - betScore * 100
    g_101.updateChips(uid, chips)
    -- if uid == self.GameSceneView.player1.uid then
    --     self.GameSceneView.player1:setFh(chips / 100)
    -- end
    -- if uid == USER_INFO.uid then
    --     self.GameSceneView:setMyScore(chips / 100)
    -- end
end
function Handle:SERVER_BROADCAST_START_BET(pack)--广播开始下注
    dump(pack, "--广播开始下注")
    g_101.gameStatus = 1
    self.GameSceneView:clearData()
    self.GameSceneView:setMaxKXZ(pack.surpLongMaxScore, pack.surpHuMaxScore, pack.surpHeMaxScore, pack.times)
    self.GameSceneView:updateChipPnlStatus()
end
function Handle:SERVER_BROADCAST_STOP_BET(pack)--广播停止下注
    dump(pack, "--广播停止下注")
    g_101.gameStatus = 0
    self.GameSceneView:setTZXZ()
end

function Handle:SERVER_SEND_TURN_RESULT(pack)--单局结算
    dump(pack, "--单局结算")
    g_101.gameStatus = 0
    local openRes = pack.openRes
    local dfhScore = 0
    for i,v in ipairs(pack.playerList) do
        g_101.updateChips(v.uid, v.chips)
        pack.playerList[i].turnBlc = v.turnBlc / 100
        pack.playerList[i].chips = v.chips / 100
        if v.uid == pack.mostUid then
            dfhScore = pack.playerList[i].chips
        end
        if v.uid == USER_INFO.uid then
            self.GameSceneView:setMyScore(pack.playerList[i].chips)
        end
    end
    self.GameSceneView:actionAllChip(openRes, pack.playerList)
    self.GameSceneView:setDYJandXYX(pack.mostUid, pack.winUid, dfhScore)
    self.GameSceneView:setTZXZ(pack.longCard, pack.huCard, true)
    self.GameSceneView:setGameResult(openRes)
    self.GameSceneView:updateChipPnlStatus()
    table.insert(g_101.recordData, openRes)
end
function Handle:SERVER_BROADCAST_MOST_GLOD_USER(pack, winUid)--广播大富豪
    local userInfo = g_101.userInfos(pack.uid)
    self.GameSceneView:setDYJandXYX(pack.uid, winUid, userInfo.chips / 100)
    dump(pack, "--广播大富豪")
end
function Handle:SERVER_COMMAND_USER_APPLY_BANKER(pack)--申请上庄
    dump(pack, "--申请上庄")
    local bankerList = pack.bankerList
    for k, j in ipairs(g_101.allUser) do
        g_101.allUser[k].isBanker = 0
    end
    for i,v in ipairs(bankerList) do
        g_101.updateChips(v.uid, v.chips, 1)
    end

    local waitBankerList = pack.waitBankerList
    for i,v in ipairs(waitBankerList) do
        g_101.updateChips(v.uid, v.chips, 2)
    end
end
function Handle:SERVER_COMMAND_USER_LOOK_TREND(pack)--走势图
    dump(pack, "--走势图")
end
function Handle:SERVER_BROADCAST_USER_RECORD(pack)--玩家列表（20局战绩）
    dump(pack, "--玩家列表（20局战绩）")
    self.GameSceneView:showPlayerView(pack.playerList)
end
function Handle:SERVER_BROADCAST_BANKER_USER(pack)--广播新庄家
    dump(pack, "--广播新庄家")
    local mostUid = pack.mostUid
    local winUid = pack.winUid
    local dyjScore = 0
    if g_101.userInfos(mostUid) then
        dyjScore = g_101.userInfos(mostUid).chips / 100
    end

    local allChips = 0
    local bankerList = pack.bankerList
    for k, j in ipairs(g_101.allUser) do
        g_101.allUser[k].isBanker = 0
    end
    for i,v in ipairs(bankerList) do
        local uid = v.uid
        allChips  = allChips + v.chips
        g_101.updateChips(v.uid, v.chips, 1)
    end

    local waitBankerList = pack.waitBankerList
    for i,v in ipairs(waitBankerList) do
        g_101.updateChips(v.uid, v.chips, 2)
    end

    self.GameSceneView:updateChipPnlStatus()
    self.GameSceneView:setDYJandXYX(mostUid, winUid, dyjScore)
    self.GameSceneView:hideAllZhuang()
    for i,v in ipairs(bankerList) do
        local uid = v.uid
        local chips = v.chips
        local perc = string.format("%0.2f",chips / allChips * 100)
        local userInfo = g_101.userInfos(uid)
        local UserInfoView = self:getBankerPlayerByUid( i )
        if UserInfoView then
            UserInfoView:show()
            UserInfoView:setFenE(perc)
            UserInfoView:refreshPlayerInfo(userInfo.portrait, userInfo.uid, userInfo.sex, userInfo.nickname, userInfo.ip, userInfo.addres)
        end
    end
end

return Handle
