require("framework.init")
local hallHandle = require("hall.HallHandle")
local ReceiveHandle = class("ReceiveHandle", hallHandle)
local PROTOCOL = require("hz_majiang.src.handle.Protocol")
local SoundUtils = require("hz_majiang.src.SoundUtils")
local SendHandle = require("hz_majiang.src.handle.SendHandle")

local eventName = "hz_majiang" .. os.now()

function ReceiveHandle:ctor(gameScene)
    self.gameScene = gameScene
    self.Config = gameScene.Config
    self.GameSceneView = gameScene.GameSceneView
    self.TableCardView = self.GameSceneView.TableCardView
    self.TingView = self.GameSceneView.TingView
    ReceiveHandle.super.ctor(self)
    self.frozenEvents = {}
    local func_ = {
        [PROTOCOL.SVR_LOGIN_ROOM] = {handler(self, ReceiveHandle.SVR_LOGIN_ROOM)},
         --登录房间成功
        [PROTOCOL.SVR_REGET_ROOM] = {handler(self, ReceiveHandle.SVR_REGET_ROOM)},
         --0x1107 重连
        [PROTOCOL.SVR_READY] = {handler(self, ReceiveHandle.SVR_READY)}, ---广播用户准备
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, ReceiveHandle.SVR_LOGIN_ROOM_BROADCAST)},
         --
        [PROTOCOL.SVR_QUIT_ROOM] = {handler(self, ReceiveHandle.SVR_QUIT_ROOM)}, -- 用户离场
        [PROTOCOL.SVR_SEND_CARD] = {handler(self, ReceiveHandle.SVR_SEND_CARD)}, --- 发牌
        [PROTOCOL.SVR_QUIT] = {handler(self, ReceiveHandle.SVR_QUIT)}, ---自己退出
        [PROTOCOL.SVR_END] = {handler(self, ReceiveHandle.SVR_END)},
         --0x6026  --单局结算
        [PROTOCOL.SVR_CHARGE_BROADCAST] = {handler(self, ReceiveHandle.SVR_CHARGE_BROADCAST)}, -- 跟新玩家金币
        --4008 广播玩家钱数变化（用于扣取台费）
        [PROTOCOL.SVR_CHIP_CHANGE_BROADCAST] = {handler(self, ReceiveHandle.SVR_CHIP_CHANGE_BROADCAST)},
        --广播其他用户坐下 1031
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, ReceiveHandle.BROADCAST_USER_SIT_DOWN)},
        --广播用户站起 1032
        [PROTOCOL.BROADCAST_USER_STAND_UP] = {handler(self, ReceiveHandle.BROADCAST_USER_STAND_UP)},
        --广播用户退出房间 1033
        [PROTOCOL.SVR_BROADCAST_USER_LEAVEROOM] = {handler(self, ReceiveHandle.SVR_BROADCAST_USER_LEAVEROOM)},
        --错误提示5001
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, ReceiveHandle.BROADCAST_ERROR_TIPS)},
        [PROTOCOL.SVR_LOGIN_ERROR] = {handler(self, ReceiveHandle.SVR_LOGIN_ERROR)},
        [PROTOCOL.SVR_MSG_FACE] = {handler(self, ReceiveHandle.SVR_MSG_FACE)},
        [PROTOCOL.SVR_GROUP_RANKING] = {handler(self, ReceiveHandle.SVR_GROUP_RANKING)},
         --0x5100--组局排行榜
        [PROTOCOL.SVR_GROUP_TIME] = {handler(self, ReceiveHandle.SVR_GROUP_TIME)},
        --没有此房间，解散房间失败
        [PROTOCOL.G2H_CMD_DISSOLVE_FAILED] = {handler(self, ReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},
        --广播桌子用户请求解散组局
        [PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {handler(self, ReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
        --广播当前组局解散情况
        [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST] = {handler(self, ReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
        --广播桌子用户成功解散组局
        [PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP] = {handler(self, ReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
        --广播桌子用户解散组局 ，解散组局失败
        [PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP] = {handler(self, ReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},
        --广播桌子用户ip
        [PROTOCOL.BROADCAST_USER_IP] = {handler(self, ReceiveHandle.BROADCAST_USER_IP)},
        --接收服务器返回的缓存信息
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, ReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, ReceiveHandle.SERVER_CMD_MESSAGE)}
        --0x1050回看
        -- [PROTOCOL.SERVER_COMMAND_GAMERESULT_RECORD] = {handler(self, ReceiveHandle.SERVER_COMMAND_GAMERESULT_RECORD)},
        --接收服务器放回的指定用户信息pack111
        -- [PROTOCOL.SERVER_CMD_HALL_GET_MESSAGE] = {handler(self, ReceiveHandle.SERVER_CMD_HALL_GET_MESSAGE)},
        -- [PROTOCOL.SVR_BASE_BROADCAST]       = {handler(self, ReceiveHandle.SVR_BASE_BROADCAST)},  ---广播台费
    }
    table.merge(self.func_, func_)
    self:addHandleMgr()
end

function ReceiveHandle:callFunc(pack)
    local cmd = pack.cmd
    if PROTOCOL and PROTOCOL.CONFIG and PROTOCOL.CONFIG.SERVER and PROTOCOL.CONFIG.SERVER[cmd] then
        dumpW(pack)
    end
    local item = self.frozenEvents[cmd]
    if item then
        printInfo("recieved frozen event[%s]", cmd)
        if item.keepLast then
            self.frozenEvents[cmd][1] = pack
        else
            self.frozenEvents[cmd][#item + 1] = pack
        end
        return
    end
    self:dispatchEvent({name = eventName .. cmd, pack = pack})
end

function ReceiveHandle:addHandleMgr()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self._eventHandles = {}
    for cmd, v in pairs(self.func_) do
        self._eventHandles[eventName .. cmd] = self:addEventListener(eventName .. cmd, handler(self, self.handleEventMgr))
    end
end

function ReceiveHandle:handleEventMgr(event)
    local pack = event.pack
    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

function ReceiveHandle:delHandleMgr() --当场景销毁时应该删除事件 调用此方法
    for cmd, handler in pairs(self.func_) do
        local eventHandle = self._eventHandles[eventName .. cmd]
        self:removeEventListener(eventHandle)
        self._eventHandles[eventName .. cmd] = nil
    end
end

--[[
	冻结事件协议触发，这个仅为客户端行为，事件数据缓存在客户端，解冻时在触发事件分派行为
	@param protoEvent 要冻结的事件协议
	@param keepLast 对于同一协议，是否只保留最后一次缓存数据
]]
function ReceiveHandle:freezeEvent(cmd, keepLast)
    if self.frozenEvents[cmd] == nil then
        self.frozenEvents[cmd] = {}
    end
    self.frozenEvents[cmd].keepLast = keepLast
end

--[[
	解结事件协议, 解冻后会马上触发已经缓存的事件分派行为
	@param protoEvent 要冻结的事件协议
	@param clear  如果为该值为真，则只会清楚缓存的事件数据，而不会触发事件分派行为
]]
function ReceiveHandle:unfreezeEvent(cmd, clear)
    local item = self.frozenEvents[cmd]
    if item then
        self.frozenEvents[cmd] = nil
        if #item == 0 or clear then
            return
        end
        for _, pack in ipairs(item) do
            if pack == true then
                pack = nil
            end
            local ok, msg =
                xpcall(
                function()
                    self:dispatchEvent({name = eventName .. cmd, pack = pack})
                end,
                debug.traceback
            )
            if not ok then
                print(msg)
            end
            if item.keepLast then
                break
            end
        end
    end
end

function ReceiveHandle:getPlayerBySeatId(seatId)
    return self.GameSceneView:getPlayerBySeatId(seatId)
end

--接收服务器返回的缓存信息
function ReceiveHandle:SERVER_CMD_FORWARD_MESSAGE(pack)
    local msgList = pack.msgList
    for k, v in pairs(msgList) do
        if v ~= nil and v ~= "" then
            local msg = json.decode(v)
            if msg ~= nil and msg ~= "" then
                if msg.uid ~= nil and msg.uid ~= "" then
                    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(msg.uid, msg)
                end
            end
        end
    end
end

function ReceiveHandle:showExpression(msg)
end

--接收服务器返回的组局信息
function ReceiveHandle:SERVER_CMD_MESSAGE(pack)
    if bm.isInGame == false then
        return
    end
    local msg = json.decode(pack.msg)
    if msg ~= nil then
        local msgType = msg.msgType
        local uid = msg.uid
        local seat_id = g_308.userInfos[uid].seat_id
        local UserInfoView = self:getPlayerBySeatId(seat_id)
        local pos = UserInfoView:getWorldpoint()
        if msgType ~= nil and msgType ~= "" then
            if msgType == "expression" then --表情
                self:showExpression(msg)
            elseif msgType == "emoji" then --文字聊天
                self:SVR_MSG_FACE(msg)
            elseif msgType == "EmojiArmatureView" then --文字聊天
                self:SVR_MSG_EMOJI_ARMATURE(msg)
            end
            if device.platform == "ios" then
                if msgType == "voice" then
                    dumpW("voice", "-----接收服务器返回的组局信息-----")
                    require("hall.view.voicePlayView.NewVoicePlayView"):showView(pos, msg.voiceTime)
                    --通知本地播放录音
                    local arr = {}
                    arr["url"] = msg.url
                    cct.getDateForApp("playVoice", arr, "V")
                elseif msgType == "video" then
                    dumpW("video", "-----接收服务器返回的组局信息-----")
                    local arr = {}
                    arr["url"] = msg.url
                    cct.getDateForApp("playVideo", arr, "V")
                end
            else
                if msgType == "voice" then
                    dumpW("voice", "-----接收服务器返回的组局信息-----")
                    require("hall.view.voicePlayView.NewVoicePlayView"):showView(pos, msg.voiceTime)
                    --通知本地播放录音
                    local data = {}
                    data["url"] = msg.url
                    local arr = {}
                    table.insert(arr, json.encode(data))
                    cct.getDateForApp("playVoice", arr, "V")
                elseif msgType == "video" then
                    dumpW("video", "-----接收服务器返回的组局信息-----")
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

function ReceiveHandle:SVR_MSG_EMOJI_ARMATURE(pack)
    if g_isWatch == 0 then
        return
    end
    local EmojiArmatureView = SCENENOW.scene:getChildByName("EmojiArmatureView")
    if not EmojiArmatureView then
        return
    end
    local from_id = pack.uid
    local to_uid = pack.to_uid
    local emojiType = pack.type
    local from_seatId = 0
    if from_id == USER_INFO.uid then
        from_seatId = g_308.my_seat_id
    else
        from_seatId = g_308.userInfos[from_id].seat_id
    end
    local to_seatId = 0
    if to_uid == USER_INFO.uid then
        to_seatId = g_308.my_seat_id
    else
        local otherInfo = g_308.userInfos[to_uid] or {}
        to_seatId = otherInfo.seat_id
        if not to_seatId then
            return
        end
    end

    local from_UsetInfoView = self:getPlayerBySeatId(from_seatId)
    local to_UsetInfoView = self:getPlayerBySeatId(to_seatId)
    local toPos = to_UsetInfoView:getWorldpoint()
    local fromPos = from_UsetInfoView:getWorldpoint()
    EmojiArmatureView:showAnimi(toPos, fromPos, emojiType)
end

--聊天相关
function ReceiveHandle:SVR_MSG_FACE(pack)
    local faceUI = self.GameSceneView:getChildByName("faceUI")
    local uid = pack.uid
    local emojiType = pack.type

    local sex = 0
    local seatId = 0
    if uid == USER_INFO.uid then
        sex = USER_INFO.sex
        seatId = g_308.my_seat_id
    else
        sex = g_308.userInfos[uid].sex
        seatId = g_308.userInfos[uid].seat_id
    end
    local userInfoView = self:getPlayerBySeatId(seatId)
    if tonumber(sex) >= 0 then
        faceUI:showGetFace(uid, emojiType, tonumber(sex), userInfoView.img_head, userInfoView.isLeft)
    end
end

--登录房间成功g_isWatch
function ReceiveHandle:SVR_LOGIN_ROOM(pack)
    dumpW(pack, "登录房间成功g_isWatch")
    HEART_BEAT_TID = USER_INFO.tid
     --大厅用必要
    require(NetworkLoadingView_filePath):removeView(888)
    CLUB_ID = pack.club_id
    USER_INFO.family_id = pack.club_id
    USER_INFO.invote_code = pack.invote_code
    g_isWatch = pack.isWatch or 1
    BASE_CHIP = pack.base
    HEART_BEAT_TID = USER_INFO.tid
    USER_INFO.ip = pack.ip

    if g_isWatch == 0 then --观战
        self.GameSceneView:isShowGuanZhan(true)
    end

    pack.gameConfig = json.decode(pack.gameConfig)
    g_308.laiziCount = pack.laiziCount --local tabs = {[1] = {65},[2] = {65,67}}
    g_308.TOTAL_PLAYERNUM = pack.gameConfig.maxSeatCount
    g_308.gameConfig = pack.gameConfig
    g_308.OwnerID = pack.gameConfig.master
    g_308.isTuoGuan = pack.m_bAI == 1
     --托管

    self.GameSceneView:showGameConfig(pack.gameConfig)
    self.GameSceneView:setRoomId(pack.invote_code)
    --将其他玩家的信息记录下来
    self.firstEnter = g_308.my_seat_id == -1 and USER_INFO.isWatch ~= 0
     --不是观战

    local userInfos = pack.userInfos
    self.GAME_STATE = pack.status or 0
    if self.GAME_STATE == 0 then
        self.GameSceneView:isShowBtnShare(true)
        self.GameSceneView:isShowBtnCopy(true)
    end

    g_308.my_seat_id = pack.seat_id
    for k, value in ipairs(userInfos) do
        local uid = value.uid
        local seat_id = value.seat_id
        if seat_id ~= -1 then
            local viewId = self.gameScene:getViewIdBySeatId(seat_id)
            self.Config:addUser(uid, seat_id, viewId, value)
            local UserInfoView = self:getPlayerBySeatId(value.seat_id)
            UserInfoView:show()
            UserInfoView:refreshPlayerInfo(value.portrait, value.uid, value.sex, value.nick, value.ip, value.addres)
            UserInfoView:setScore(value.m_chips)
            if value.if_ready == 1 then
                UserInfoView:isShowReady(true)
            elseif uid == USER_INFO.uid and self.GAME_STATE == 0 then
                self.GameSceneView:isShowBtnReady(true)
            end
            g_308.userInfos[uid].if_ready = value.if_ready
        end
    end
end

function ReceiveHandle:SVR_REGET_ROOM(pack)
    dumpW(pack, "重连")
    HEART_BEAT_TID = USER_INFO.tid
     --大厅用必要
    require(NetworkLoadingView_filePath):removeView(888)
    CLUB_ID = pack.club_id
    USER_INFO.family_id = pack.club_id
    USER_INFO.invote_code = pack.invote_code
    g_isWatch = pack.isWatch or 1
    BASE_CHIP = pack.base
    HEART_BEAT_TID = USER_INFO.tid
    USER_INFO.ip = pack.ip

    g_308.laiziCount = pack.laiziCount --local tabs = {[1] = {65},[2] = {65,67}}
    g_308.isTuoGuan = pack.m_bAI == 1
     --托管
    self.GAME_STATE = pack.status -- 0 未开始 1 进行中 4停止 3等待用户操作

    pack.gameConfig = json.decode(pack.gameConfig)
    self.GameSceneView:showGameConfig(pack.gameConfig)
    self.GameSceneView:setRoomId(pack.invote_code)
    local userInfos = pack.userInfos
    if pack.seat_id == -1 and g_isWatch == 1 then --不是观战
        g_308.my_seat_id = #userInfos
     --未加入房间时的特殊处理 占个座位id先
    else
        g_308.my_seat_id = pack.seat_id
    end
    table.sort(
        userInfos,
        function(a, b) --自己必须在第一
            if a.uid == USER_INFO.uid then
                return a.uid == USER_INFO.uid
            else
                return a.uid ~= USER_INFO.uid
            end
        end
    )
    for k, value in ipairs(userInfos) do --必须先自己加入房间
        local uid = value.uid
        local seat_id = value.seat_id
        if seat_id ~= -1 then
            local viewId = self.gameScene:getViewIdBySeatId(seat_id)
            self.Config:addUser(uid, seat_id, viewId, value)
            local UserInfoView = self:getPlayerBySeatId(value.seat_id)
            UserInfoView:show()
            UserInfoView:refreshPlayerInfo(value.portrait, value.uid, value.sex, value.nick, value.ip, value.addres)
            UserInfoView:setScore(value.m_chips)
            if value.if_ready == 1 and pack.status == 0 then
                UserInfoView:isShowReady(true)
            elseif uid == USER_INFO.uid and pack.status == 0 then
                self.GameSceneView:isShowBtnReady(true)
            end
            g_308.userInfos[uid].if_ready = value.if_ready
        end
    end
    if g_308.isTuoGuan then
        self.GameSceneView:isShowTuoGuan(true)
    end

    if self.GAME_STATE == 0 then
        return
    elseif self.GAME_STATE == 1 then
        self.TableCardView:setTableCards(pack.cardCount, pack.m_nShaiZi)
        self.TableCardView:removeTableCard(pack.cardCount - pack.card_less)
        self.GameSceneView:setRemainCount(pack.card_less)
    end

    local UserInfoView = self:getPlayerBySeatId(pack.banker_seat_id)
    UserInfoView:isShowZhuang()

    for i, userInfo in ipairs(pack.userInfos) do
        local UserInfoView = self:getPlayerBySeatId(userInfo.seat_id)
        if userInfo.uid ~= USER_INFO.uid then
            local handCards = {}
            for i = 1, userInfo.countHandCards do
                table.insert(handCards, 0)
            end
            if #handCards % 3 == 2 then
                table.remove(handCards, 1)
                UserInfoView.HandCardView:showCards(handCards)
                 --绘制其他玩家手牌
                UserInfoView.HandCardView:setNewCard()
            else
                UserInfoView.HandCardView:showCards(handCards)
             --绘制其他玩家手牌
            end
        end
        local outCards = {}
        for i, v in ipairs(userInfo.outCards) do
            if v.outcardtype == 0 then --其他用户信息: 该牌有没有被吃碰杠，1是有，0是没有
                table.insert(outCards, v.card)
            end
        end
        UserInfoView.OutCardView:showOutCards(outCards)
        self:handCards(UserInfoView, userInfo.allOperation)
    end

    if g_308.my_seat_id >= 0 then
        local UserInfoView = self:getPlayerBySeatId(g_308.my_seat_id)
        local handCards = pack.handCards
        table.sort(handCards)
        if #handCards % 3 == 2 then
            local card = table.remove(handCards, 1)
            UserInfoView.HandCardView:showCards(handCards)
            UserInfoView.HandCardView:setNewCard(card)
        else
            UserInfoView.HandCardView:showCards(handCards)
        end
        self.TingView:showTingHuPlane(pack.tingHuCards)
        self.TingView:setDianNodeBytingpai(pack.tingCards)
    end

    local currentPlayerId = pack.currentPlayerId
    if pack.handle ~= 0 then --重连后自己有操作的情况下
        currentPlayerId = pack.currentPlayerId - 1
        g_308.isCanChuCard = true
    end
    local UserInfoView = self:getPlayerBySeatId(currentPlayerId)
    UserInfoView:isShowLight(true)
    self.GameSceneView:setZhiZhenAnim(g_308.viewIds[currentPlayerId])
end

function ReceiveHandle:handCards(UserInfoView, allOperation)
    for i, v in ipairs(allOperation) do
        local _type = v.ope
        local card = v.card
        local targetSeatId = v.targetSeatId
        local cards = {}
        if bit.band(_type, g_308.t_peng) > 0 then --碰
            table.insert(cards, card)
            table.insert(cards, card)
            table.insert(cards, card)
        elseif bit.band(_type, g_308.t_gang) > 0 then
            table.insert(cards, card)
            table.insert(cards, card)
            table.insert(cards, card)
            table.insert(cards, card)
        elseif bit.band(_type, g_308.t_chi) > 0 then
            if _type == g_308.chi_right then
                table.insert(cards, card - 2)
                table.insert(cards, card - 1)
                table.insert(cards, card)
            elseif _type == g_308.chi_middle then
                table.insert(cards, card + 1)
                table.insert(cards, card - 1)
                table.insert(cards, card)
            elseif _type == g_308.chi_left then
                table.insert(cards, card + 1)
                table.insert(cards, card + 2)
                table.insert(cards, card)
            end
        end
        UserInfoView.PAndGView:addPOrGCards(cards, _type)
    end
end

--广播用户坐下 1031   其他用户进入房间
function ReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
    print("=====有玩家进来了啦！！！====", pack.uid)
    local seat_id = pack.seat_id
    local uid = pack.uid
    if uid == USER_INFO.uid then
        g_308.my_seat_id = seat_id
        for i, UserInfoView in ipairs(self.GameSceneView.UserInfoViews) do
            UserInfoView:hide()
        end
    end
    local viewId = self.gameScene:getViewIdBySeatId(seat_id)
    self.Config:addUser(uid, seat_id, viewId, pack)
    local UserInfoView = self:getPlayerBySeatId(seat_id)
    UserInfoView:show()
    UserInfoView:refreshPlayerInfo(pack.portrait, uid, pack.sex, pack.nick, pack.ip, pack.addres)
    UserInfoView:setScore(pack.m_chips)
    if uid == USER_INFO.uid and self.GAME_STATE == 0 then
        self.GameSceneView:isShowBtnReady(true)
    end
    if uid == USER_INFO.uid then
        for k, value in pairs(g_308.userInfos) do
            local uid = value.uid
            local seat_id = value.seat_id
            if seat_id ~= -1 then
                local viewId = self.gameScene:getViewIdBySeatId(seat_id)
                self.Config:addUser(uid, seat_id, viewId, value)
                local UserInfoView = self:getPlayerBySeatId(value.seat_id)
                UserInfoView:show()
                UserInfoView:refreshPlayerInfo(value.portrait, value.uid, value.sex, value.nick, value.ip, value.addres)
                UserInfoView:setScore(value.m_chips)
                if value.if_ready == 1 then
                    UserInfoView:isShowReady(true)
                elseif uid == USER_INFO.uid and self.GAME_STATE == 0 then
                    self.GameSceneView:isShowBtnReady(true)
                end
                g_308.userInfos[uid].if_ready = value.if_ready
            end
        end
    end
end

--广播玩家站起 1032
function ReceiveHandle:BROADCAST_USER_STAND_UP(pack)
end

--用户入场
function ReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)
    print("=====服务器广播用户登陆房间======")
    dumpW(pack, "SVR_LOGIN_ROOM_BROADCAST")
    local seat_id = pack.seat_id
    local uid = pack.uid
    if g_308.userInfos[uid] then --已添加
        local UserInfoView = self:getPlayerBySeatId(seat_id)
        UserInfoView:isShowNewWork(false)
        return
    end
    local viewId = self.gameScene:getViewIdBySeatId(seat_id)
    self.Config:addUser(uid, seat_id, viewId, pack)

    if uid == USER_INFO.uid and seat_id >= 0 then
        g_308.my_seat_id = seat_id
        for i, UserInfoView in ipairs(self.GameSceneView.UserInfoViews) do
            UserInfoView:hide()
        end

        local UserInfoView = self:getPlayerBySeatId(seat_id)
        UserInfoView:show()
        UserInfoView:refreshPlayerInfo(pack.portrait, uid, pack.sex, pack.nick, pack.ip, pack.addres)
        UserInfoView:setScore(pack.m_chips)
        if pack.if_ready == 1 and self.GAME_STATE == 0 then
            UserInfoView:isShowReady(true)
            self.GameSceneView:isShowBtnReady(false)
        elseif self.GAME_STATE == 0 then
            self.GameSceneView:isShowBtnReady(true)
        end

        for k, value in pairs(g_308.userInfos) do
            local uid = value.uid
            local seat_id = value.seat_id
            if seat_id ~= -1 then
                local viewId = self.gameScene:getViewIdBySeatId(seat_id)
                self.Config:addUser(uid, seat_id, viewId, value)
                local UserInfoView = self:getPlayerBySeatId(value.seat_id)
                UserInfoView:show()
                UserInfoView:refreshPlayerInfo(value.portrait, value.uid, value.sex, value.nick, value.ip, value.addres)
                UserInfoView:setScore(value.m_chips)
                if value.if_ready == 1 then
                    UserInfoView:isShowReady(true)
                elseif uid == USER_INFO.uid and self.GAME_STATE == 0 then
                    self.GameSceneView:isShowBtnReady(true)
                end
                g_308.userInfos[uid].if_ready = value.if_ready
            end
        end
    end
end

--用户离场
function ReceiveHandle:SVR_QUIT_ROOM(pack)
    dumpW(pack, "用户离场离线")
    local uid = pack.uid
    local userInfo = g_308.userInfos[uid]
    local UserInfoView = self:getPlayerBySeatId(userInfo.seat_id)
    UserInfoView:isShowNewWork(true)
end

--自己离场
function ReceiveHandle:SVR_QUIT(pack)
    dumpW("SVR_QUITgggggg")
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end

--广播台费
function ReceiveHandle:SVR_BASE_BROADCAST(pack)
    --改变玩家金币
    dumpW(pack, "广播台费改变玩家金币")
end

--组局排行榜
function ReceiveHandle:SVR_GROUP_RANKING(pack)
    dumpW(pack, "组局结束")
    if pack then
        if SCENENOW["scene"]:getChildByName("layer_tips") then
            SCENENOW["scene"]:removeChildByName("layer_tips")
        end
        if SCENENOW["scene"]:getChildByName("DisbandLayer_tips") then
            SCENENOW["scene"]:removeChildByName("DisbandLayer_tips")
        end
        g_308.m_isGameOver = true
        g_308.settlementData = pack
        self.GameSceneView:settlement(pack)
    end
end

--组局时长
function ReceiveHandle:SVR_GROUP_TIME(pack)
    dumpW(pack, "SVR_GROUP_TIME")
    local round = tonumber(pack.round) or 0
    self.GameSceneView:setRound(round, pack.round_total)
end

--组局解散相关
--没有此房间，解散房间失败
function ReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)
    --dumpW("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")
    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")
end

function ReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)
    if tolua.isnull(self.disbandLayer) then
        local userLst = {}
        for i, v in pairs(g_308.userInfos or {}) do
            table.insert(userLst, v)
        end
        local playerList = {}
        for i, v in ipairs(userLst) do
            local tmp = {}
            tmp.state = v.uid == pack.applyId and 3 or 2
            tmp.userId = v.uid
            tmp.userName = v.nick
            tmp.userUrl = v.portrait or v.icon_url
            table.insert(playerList, tmp)
        end

        local info = {}
        info.userLst = playerList
        local function callBackSure()
            SendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
        end
        local function callBackReject()
            SendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
        end
        info.callBackReject = callBackReject
        info.callBackSure = callBackSure

        self.disbandLayer = require("hall.tips.DisbandLayer"):showDisbandLayer(info)
        self.disbandLayer:setTimes(dissolutionTime)
    end
    if pack.agreeNum ~= 0 then
        for i, v in ipairs(pack.agreeMember_arr) do
            local info = {userId = v, state = 1}
            self.disbandLayer:exChangeState(info, 1)
        end
    end
end

--广播桌子用户请求解散组局
function ReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)
end

--广播桌子用户成功解散组局
function ReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)
    if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
    end
end

--广播桌子用户解散组局 ，解散组局失败
function ReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)
    local userLst = {USER_INFO}
    for i, v in pairs(g_308.userInfos or {}) do
        table.insert(userLst, v)
    end
    local name = ""
    for i, v in ipairs(userLst) do
        if pack.rejectId == v.uid then
            name = v.nick or v.nick
        end
    end

    local rejectId = pack.rejectId
    if rejectId == USER_INFO.uid then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
    else
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, name .. "拒绝解散房间")
    end
end

--服务器广播玩家退出
function ReceiveHandle:SVR_BROADCAST_USER_LEAVEROOM(pack)
    if g_308.m_isGameOver then
        return
    end
    local uid = pack.uid
    if uid == USER_INFO.uid then
        if g_308.settlementData then
            self.GameSceneView:settlement(g_308.settlementData)
        else
            require("hall.GameCommon"):gExitGroupGame(USER_INFO.enter_mode, CLUB_ID)
        end
    elseif g_308.userInfos[uid] then
        local seat_id = g_308.userInfos[uid].seat_id
        local UserInfoView = self:getPlayerBySeatId(seat_id)
        if UserInfoView then
            UserInfoView:hide()
            self.Config:delUser(uid)
        end
    end
end

function ReceiveHandle:BROADCAST_USER_IP(pack)
    -- require("hall.GameCommon"):showAlert(true, "提示：" .. msg .. "  ip地址相同，谨防作弊", 300)
end

function ReceiveHandle:SVR_LOGIN_ERROR(pack)
    dumpW(pack, "-----登陆错误-----")
    local loginErrorCode = {
        [3] = "玩家密匙错误",
        [4] = "数据库连接错误",
        [5] = "无此房间",
        [7] = "房间已满人",
        [8] = "没有多余座位",
        [9] = "金币不足",
        [11] = "未知错误",
        [12] = "相同IP",
        [13] = "钱太多",
        [14] = "缓存错误",
        [15] = "VIP错误",
        [16] = "密码错误",
        [17] = "要求携带不满足",
        [18] = "组局已开始",
        [19] = "积分不足"
    }
    local errcode = "error"
    local showBtn = 2
    if pack.errorCode == 9 then
        errcode = "change_money"
        showBtn = 1
    end
    require("hall.GameTips"):showTips("提示", "tohall", 3, loginErrorCode[pack.errorCode])
    local callFuncAc =
        cc.CallFunc:create(
        function()
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
        end
    )
    SCENENOW["scene"]:runAction(cc.Sequence:create(cc.DelayTime:create(3), callFuncAc))
end
---------------------------------------------------------------------------------------------------------------------------------------------
--扣除台费 4800

function ReceiveHandle:SVR_CHIP_CHANGE_BROADCAST(pack)
    dumpW(pack, "pack111")
    for _, data in pairs(pack.userinfo) do
        local uid = data.uid
        local userInfo = g_308.userInfos[uid]
        if not (userInfo) then
            return
        end
        userInfo.m_chips = userInfo.m_chips + data.chargeCoins
        local UserInfoView = self:getPlayerBySeatId(userInfo.seat_id)
        UserInfoView:setScore(userInfo.m_chips)
    end
end

--5001
function ReceiveHandle:BROADCAST_ERROR_TIPS(pack)
    dumpW(pack, "-----返回错误提示5001-----")
    local errorCode = pack.errorCode
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
        [22] = "要求携带积分不足",
        [100] = "战绩不存在"
    }
    dumpW(tbErrorCode[errorCode], "错误提示")
    if errorCode == 18 then
        local scenes = SCENENOW.scene
        if scenes then
            scenes:performWithDelay(
                function()
                    --去掉提示弹框
                    local layer_tips = scenes:getChildByName("layer_tips")
                    if layer_tips then
                        layer_tips:removeSelf()
                    end
                    require("hall.GameTips"):showTips("提示", "", 2, "有玩家积分不足，已解散！")
                end,
                1.5
            )
        end
    else
        if tbErrorCode[errorCode] then
            local paras = {}
            paras.type = 1
            paras.title = "提示"
            paras.content = tbErrorCode[errorCode] == nil and "未知的错误" or tbErrorCode[errorCode]
            require("hall.tips.CommonTips"):showTips(paras)
        end
    end
end

--接收服务器放回的指定用户信息pack111
function ReceiveHandle:SVR_CHARGE_BROADCAST(pack)
    dumpW(pack, "pack111")
    local uid = pack.uid
    local userInfo = g_308.userInfos[uid]
    if not (userInfo) then
        return
    end
    userInfo.m_chips = userInfo.m_chips + pack.chargeCoins
    local UserInfoView = self:getPlayerBySeatId(userInfo.seat_id)
    UserInfoView:setScore(userInfo.m_chips)
    
    --上分提示
    for k,v in pairs(g_308.userInfos) do
        if pack.uid == v.uid then
            local str = require('hall.GameCommon'):formatNick(v.nick, 4) .. "(" .. pack.uid .. ")"
            viewMgr:showTip({text = "玩家:" .. str .. "被上" .. ( pack.chargeCoins / 100) .. "积分"}) 
        end
    end
end

--用户准备
function ReceiveHandle:SVR_READY(pack)
    dumpW(pack, "SVR_READY_GAME")
    local uid = pack.uid
    local seat_id = g_308.userInfos[uid].seat_id
    local userInfoView = self:getPlayerBySeatId(seat_id)
    userInfoView:isShowReady(true)
    g_308.userInfos[uid].if_ready = 1
end

--发牌
function ReceiveHandle:SVR_SEND_CARD(pack)
    dumpW(pack, "--发牌")
end

--广播开始游戏倒计时 100F
function ReceiveHandle:SVR_BROADCAST_COUNT_DOWN(pack)
    dumpW(pack, "------广播开始游戏倒计时 100F------")
    if pack.time > 0 then
        self.GameSceneView:showStartTimer(pack.time)
    end
end

return ReceiveHandle
