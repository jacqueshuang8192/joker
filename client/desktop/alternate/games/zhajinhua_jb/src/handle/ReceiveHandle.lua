require("framework.init")
local hallHandle = require("hall.HallHandle")
local ReceiveHandle = class("ReceiveHandle", hallHandle)
local PROTOCOL = require("zhajinhua_jb.src.handle.Protocol")
local SoundUtils = require("zhajinhua_jb.src.SoundUtils")
local CtrlMgr = require("zhajinhua_jb.src.CtrlMgr")
local SendHandle = require("zhajinhua_jb.src.handle.SendHandle")

local eventName = "zhajinhua_jb"..os.now()

function ReceiveHandle:ctor(gameScene)
    self.gameScene = gameScene
    self.Config = gameScene.Config
    self.GameSceneView = gameScene.GameSceneView
    self.OprorateBtn = self.GameSceneView.OprorateBtn
    self.PlayersMgr = self.GameSceneView.PlayersMgr
    self.CardMgr = self.GameSceneView.CardMgr
    self.ChatMgr = self.GameSceneView.ChatMgr
    ReceiveHandle.super.ctor(self);
    self.frozenEvents = {}
    local func_ = {
        [PROTOCOL.SVR_LOGIN_ROOM]           = {handler(self, ReceiveHandle.SVR_LOGIN_ROOM)},--登录房间成功
        [PROTOCOL.SVR_READY]                = {handler(self, ReceiveHandle.SVR_READY)},  ---广播用户准备
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, ReceiveHandle.SVR_LOGIN_ROOM_BROADCAST)},--
        [PROTOCOL.SVR_QUIT_ROOM]            = {handler(self, ReceiveHandle.SVR_QUIT_ROOM)}, -- 用户离场
        [PROTOCOL.SVR_BASE_BROADCAST]       = {handler(self, ReceiveHandle.SVR_BASE_BROADCAST)},  ---广播台费
        [PROTOCOL.SVR_SEND_CARD]            = {handler(self, ReceiveHandle.SVR_SEND_CARD)},   --- 发牌
        [PROTOCOL.SVR_START_BROADCAST]      = {handler(self, ReceiveHandle.SVR_START_BROADCAST)},  ---广播开始游戏
        [PROTOCOL.SVR_QUIT]                 = {handler(self, ReceiveHandle.SVR_QUIT)},    ---自己退出
        [PROTOCOL.SVR_DIU_BROADCAST]        = {handler(self, ReceiveHandle.SVR_DIU_BROADCAST)},  --玩家弃牌
        [PROTOCOL.SVR_KAN_CARD]             = {handler(self, ReceiveHandle.SVR_KAN_CARD)},--0x6021    --广播看牌
        [PROTOCOL.SVR_GEN_BROADCAST]        = {handler(self, ReceiveHandle.SVR_GEN_BROADCAST)},--0x6022    --广播玩家跟注
        [PROTOCOL.SVR_JIA_BROADCAST]        = {handler(self, ReceiveHandle.SVR_JIA_BROADCAST)},--0x6023    --广播玩家加注
        [PROTOCOL.SVR_BI_BROADCAST]         = {handler(self, ReceiveHandle.SVR_BI_BROADCAST)},--0x6025    --广播玩家比牌结果
        [PROTOCOL.SVR_END]                  = {handler(self, ReceiveHandle.SVR_END)},--0x6026  --单局结算
        [PROTOCOL.SVR_ALL_COMPARE]          = {handler(self, ReceiveHandle.SVR_ALL_COMPARE)},--0x6027   -- 全桌比牌
        [PROTOCOL.SVR_ALLIN_BROADCAST]      = {handler(self, ReceiveHandle.SVR_ALLIN_BROADCAST)},--0x6028    --广播玩家全押
        [PROTOCOL.BROADCAST_CAN_START_GAME]      = {handler(self, ReceiveHandle.BROADCAST_CAN_START_GAME)},   --广播开始游戏按钮
        [PROTOCOL.SVR_CHARGE_BROADCAST]      = {handler(self, ReceiveHandle.SVR_CHARGE_BROADCAST)},  -- 跟新玩家金币
        -- 6029玩家可以看牌了
        [PROTOCOL.SVR_KAN_SHOW]      = {handler(self, ReceiveHandle.SVR_KAN_SHOW)},
        --4008 广播玩家钱数变化（用于扣取台费）
        [PROTOCOL.SVR_CHIP_CHANGE_BROADCAST]       = {handler(self, ReceiveHandle.SVR_CHIP_CHANGE_BROADCAST)},
        --广播其他用户坐下（金币场） 1031
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, ReceiveHandle.BROADCAST_USER_SIT_DOWN)},
        --广播用户站起 1032
        [PROTOCOL.BROADCAST_USER_STAND_UP] = {handler(self, ReceiveHandle.BROADCAST_USER_STAND_UP)},
        --广播用户退出房间 1033
        [PROTOCOL.SVR_BROADCAST_USER_LEAVEROOM] = {handler(self, ReceiveHandle.SVR_BROADCAST_USER_LEAVEROOM)},
        --广播剩余时间100F
        [PROTOCOL.SVR_BROADCAST_COUNT_DOWN]           = {handler(self, ReceiveHandle.SVR_BROADCAST_COUNT_DOWN)},
        --错误提示5001
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, ReceiveHandle.BROADCAST_ERROR_TIPS)},
        --登陆错误
        [PROTOCOL.SVR_ERROR] = {handler(self, ReceiveHandle.SVR_ERROR)},
        [PROTOCOL.SVR_MSG_FACE]={handler(self, ReceiveHandle.SVR_MSG_FACE)},
        [PROTOCOL.SVR_GROUP_RANKING] = {handler(self, ReceiveHandle.SVR_GROUP_RANKING)},--0x5100--组局排行榜
        [PROTOCOL.SVR_GROUP_TIME] = {handler(self, ReceiveHandle.SVR_GROUP_TIME)},
        --没有此房间，解散房间失败
        [PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, ReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},
        --广播桌子用户请求解散组局
        [PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, ReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
        --广播当前组局解散情况
        [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, ReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
        --广播桌子用户成功解散组局
        [PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, ReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
        --广播桌子用户解散组局 ，解散组局失败
        [PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, ReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},
        --广播桌子用户ip
        [PROTOCOL.BROADCAST_USER_IP]     = {handler(self, ReceiveHandle.BROADCAST_USER_IP)},
        --接收服务器返回的缓存信息
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, ReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, ReceiveHandle.SERVER_CMD_MESSAGE)},
        --0x1050回看
        [PROTOCOL.SERVER_COMMAND_GAMERESULT_RECORD] = {handler(self, ReceiveHandle.SERVER_COMMAND_GAMERESULT_RECORD)},
        --接收服务器放回的指定用户信息pack111
        -- [PROTOCOL.SERVER_CMD_HALL_GET_MESSAGE] = {handler(self, ReceiveHandle.SERVER_CMD_HALL_GET_MESSAGE)},  
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
    self:dispatchEvent({ name = eventName..cmd, pack = pack})
end

function ReceiveHandle:addHandleMgr()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self._eventHandles = {}
    for cmd,v in pairs(self.func_) do
        self._eventHandles[eventName..cmd] = self:addEventListener(eventName..cmd, handler(self, self.handleEventMgr))
    end
end

function ReceiveHandle:handleEventMgr( event )
    local pack = event.pack
    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

function ReceiveHandle:delHandleMgr()   --当场景销毁时应该删除事件 调用此方法
    for cmd,handler in pairs(self.func_) do
        local eventHandle = self._eventHandles[eventName..cmd]
        self:removeEventListener(eventHandle)
        self._eventHandles[eventName..cmd] = nil
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
            local ok, msg = xpcall(function() 
                self:dispatchEvent({ name = eventName..cmd, pack = pack})
            end, debug.traceback)
			if not ok then
				print(msg)
			end
			if item.keepLast then
				break
			end
		end
	end
end

function ReceiveHandle:getPlayerBySeatId( seatId )
    return self.GameSceneView:getPlayerBySeatId( seatId )
end

--接收服务器返回的缓存信息
function ReceiveHandle:SERVER_CMD_FORWARD_MESSAGE(pack)
    local msgList = pack.msgList
    for k,v in pairs(msgList) do
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
        local seat_id = g_317.userInfos[uid].seat_id
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        local pos = UserInfoView:getWorldpoint()
        if msgType ~= nil and msgType ~= "" then
            if msgType == "expression" then   --表情
                self:showExpression(msg)
            elseif  msgType == "emoji" then   --文字聊天
                self:SVR_MSG_FACE(msg)
            elseif  msgType == "EmojiArmatureView" then   --文字聊天
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
        from_seatId = g_317.my_seat_id
    else
        from_seatId = g_317.userInfos[from_id].seat_id
    end
    local to_seatId = 0
    if to_uid == USER_INFO.uid then
        to_seatId = g_317.my_seat_id
    else
        local otherInfo = g_317.userInfos[to_uid] or {}
        to_seatId = otherInfo.seat_id
        if not to_seatId then
            return
        end
    end

    local from_UsetInfoView = self:getPlayerBySeatId( from_seatId )
    local to_UsetInfoView = self:getPlayerBySeatId( to_seatId )
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
        seatId = g_317.my_seat_id
    else
        sex = g_317.userInfos[uid].sex
        seatId = g_317.userInfos[uid].seat_id
    end
    local userInfoView = self:getPlayerBySeatId(seatId)
    if tonumber(sex) >= 0 then
        faceUI:showGetFace(uid, emojiType, tonumber(sex), userInfoView.img_head, userInfoView.isLeft)
    end

end

--登录房间成功g_isWatch
function ReceiveHandle:SVR_LOGIN_ROOM(pack)
    dumpW(pack,"登录房间成功g_isWatch")
    HEART_BEAT_TID = USER_INFO.tid--大厅用必要
    require(NetworkLoadingView_filePath):removeView(888)
    CLUB_ID = pack.club_id
    USER_INFO.family_id = pack.club_id
    USER_INFO.invote_code = pack.invote_code
    g_isWatch = pack.isWatch
    BASE_CHIP = pack.base
    HEART_BEAT_TID = USER_INFO.tid
    USER_INFO.ip = pack.ip

	if g_isWatch == 0 then--观战
        self.GameSceneView:isShowGuanZhan( true )
    end
    

    g_317.isCanKan = pack.isDisplay == 1
    pack.gameConfig = json.decode(pack.gameConfig)
    g_317.TOTAL_PLAYERNUM = pack.gameConfig.maxSeatCount
    g_317.gameConfig = pack.gameConfig
    g_317.OwnerID = pack.gameConfig.master
    g_317.allZhus = pack.allZhus--全压筹码
    g_317.isCanAllin = pack.isCanAllin--用户是否可以全压
    g_317.countUserAllin = pack.countUserAllin--是否可以血拼  1可以血拼 其它不可以
    g_317.isAllin = pack.isAllin--是否已经全压
    g_317.all_turns = all_turns

    self.GameSceneView:showGameConfig(pack.gameConfig)
    self.GameSceneView:setRoomId( pack.inviteCode )
    self.PlayersMgr:setPlayerNum(g_317.TOTAL_PLAYERNUM)
    --将其他玩家的信息记录下来
    self.firstEnter = g_317.my_seat_id == -1 and USER_INFO.isWatch ~= 0--不是观战

    self.GameSceneView:isShowGameRound( pack.now_turns, pack.all_turns )
    local userInfos = {}
    self.GAME_STATE = pack.status
    if pack.status == 0 then
        userInfos = pack.nostart[1].userInfos
        self.GameSceneView:isShowBtnShare(true)
        self.GameSceneView:isShowBtnCopy(true)
    elseif pack.status == 2 then--牌局开始
        userInfos = pack.start[1].userInfos
    end

    if pack.seat_id == -1 and g_isWatch == 1 then--不是观战
        g_317.my_seat_id = #userInfos--未加入房间时的特殊处理 占个座位id先
    else
        g_317.my_seat_id = pack.seat_id
    end
    
    for k, value in ipairs(userInfos) do--必须先自己加入房间
        local uid = value.uid
        local seat_id = value.seat_id
        if uid == USER_INFO.uid and seat_id ~= -1 then
            local viewId = self.gameScene:getViewIdBySeatId(seat_id)
            self.Config:addUser( uid, seat_id, viewId, value )
            local UserInfoView = self:getPlayerBySeatId( value.seat_id )
            UserInfoView:show()
            UserInfoView:refreshPlayerInfo(value.portrait, value.uid, value.sex, value.nickName, value.ip, value.addres)
            UserInfoView:setScore(value.m_chips)
            if value.if_ready == 1 then
                UserInfoView:isShowReady(true)
            elseif uid == USER_INFO.uid and pack.status == 0 then
                self.GameSceneView:isShowBtnReady( true )
            end
            g_317.userInfos[uid].if_ready = value.if_ready
        end
    end

    for k,value in ipairs(userInfos) do
        local uid = value.uid
        local seat_id = value.seat_id
        if seat_id ~= -1 then
            local viewId = self.gameScene:getViewIdBySeatId(seat_id)
            self.Config:addUser( uid, seat_id, viewId, value )
            local UserInfoView = self:getPlayerBySeatId( value.seat_id )
            UserInfoView:show()
            UserInfoView:refreshPlayerInfo(value.portrait, value.uid, value.sex, value.nickName, value.ip, value.addres)
            UserInfoView:setScore(value.m_chips)
            if value.if_ready == 1 then
                UserInfoView:isShowReady(true)
            elseif uid == USER_INFO.uid and pack.status == 0 then
                self.GameSceneView:isShowBtnReady( true )
            end
            g_317.userInfos[uid].if_ready = value.if_ready
        end
    end

    if pack.status == 2 then
		local start = pack.start[1]
		g_317.now_zhu = start.now_xia
        g_317.min_pk = start.min_pk
		g_317.min_allin = start.min_allin
        if start.play_content then
            local data = start.play_content[1]
            g_317.zhus = data.zhus
		end
        -- self.GameSceneView:isShowGameRound( start.now_turns, start.all_turns )
		for i,userInfos in ipairs(start.userInfos) do
            g_317.userInfos[userInfos.uid].if_ready = start.playing
			if userInfos.uid == USER_INFO.uid then
				g_317.isKan[USER_INFO.uid] = true
				break
			end
		end

		local UserInfoView = self:getPlayerBySeatId( start.now_seat )
		if UserInfoView then
			UserInfoView:isShowLight(true) 
			self.GameSceneView:showStartTimer(start.time)
            if start.now_seat == g_317.my_seat_id then
				self.OprorateBtn:showButton(start.can_compare, start.is_allin)
			end
		end
		
		local time = self.CardMgr:sendCard()
        local func1 = function ()
            for key,value in ipairs(start.userInfos) do
                if value.bet_values then
                    for kk, vv in ipairs(value.bet_values) do
                        self.GameSceneView:diuChips(value.uid, vv)
                    end
                end
            end
            self.GameSceneView:isShowXiaZhu(true, start.all_xia or 0)

            if start.play_content then
                local UserInfoView = self:getPlayerBySeatId( g_317.my_seat_id )
                local data = start.play_content[1]
                g_317.zhus = data.zhus
				if data.if_check == 1 and g_317.isKan[USER_INFO.uid] == true then --是否已看牌
					self.CardMgr:sortOrder(data.cards)
                    UserInfoView:setCards(data.cards)
                    UserInfoView:isShowCardType(true, data.card_type)
                end
                if data.cancel == 1 then -- 是否弃牌
                    g_317.isDiu[USER_INFO.uid] = 1
				end
                if data.user_all_xia > 0 then -- 已下注
                    UserInfoView:isShowChip(true, data.user_all_xia)
				end
			end
			
			for key,value in pairs(start.userInfos) do
				local uid = value.uid
				local userInfo = g_317.userInfos[uid]
				local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
				if value.if_ready == 1 then
                    UserInfoView:isShowReady(true)
                end
                if value.if_check == 1 and value.lookCardStatus == 1 then --是否已看牌
                    g_317.isKan[uid] = 1
                    UserInfoView:isShowQi(true, true)
                end
                if value.cancel == 1 then -- 是否弃牌
                    UserInfoView:isShowQi(true)
                    g_317.isDiu[uid] = 1
                end
                if value.xia > 0 then -- 已下注
                    UserInfoView:isShowChip(true, value.xia)
                end
            end
		end
    	self.GameSceneView:setTimingFun( func1, time )
    end
    SendHandle:CLIENT_CMD_FORWARD_MESSAGE("")
end

--广播用户坐下 1031   其他用户进入房间
function ReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
    print("=====有玩家进来了啦！！！====", pack.uid)
    local seat_id = pack.seat_id
    local uid = pack.uid
    if uid == USER_INFO.uid then
        g_317.my_seat_id = seat_id
    end
    local viewId = self.gameScene:getViewIdBySeatId(seat_id)
    self.Config:addUser( uid, seat_id, viewId, pack )
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    UserInfoView:show()
    UserInfoView:refreshPlayerInfo(pack.portrait, uid, pack.sex, pack.nickName, pack.ip, pack.addres)
    UserInfoView:setScore(pack.m_chips)
    if uid == USER_INFO.uid and self.GAME_STATE == 0 then
        self.GameSceneView:isShowBtnReady( true )
    end
end

--广播玩家站起 1032
function ReceiveHandle:BROADCAST_USER_STAND_UP(pack)
end

--用户入场
function ReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)
	print("=====服务器广播用户登陆房间======")
    dumpW(pack,"SVR_LOGIN_ROOM_BROADCAST")
    local seat_id = pack.seat_id
    local uid = pack.uid
    if g_317.userInfos[uid] then--已添加
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        UserInfoView:isShowNewWork(false)
        return
    end
    local viewId = self.gameScene:getViewIdBySeatId(seat_id)
    self.Config:addUser( uid, seat_id, viewId, pack )

    if uid == USER_INFO.uid and seat_id >= 0 then
        g_317.my_seat_id = seat_id
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        UserInfoView:show()
        UserInfoView:refreshPlayerInfo(pack.portrait, uid, pack.sex, pack.nickName, pack.ip, pack.addres)
        UserInfoView:setScore(pack.m_chips)
        if pack.if_ready == 1 and self.GAME_STATE == 0 then
            UserInfoView:isShowReady(true)
            self.GameSceneView:isShowBtnReady(false)
        elseif self.GAME_STATE == 0 then
            self.GameSceneView:isShowBtnReady( true )
        end
    end
end

--用户离场
function ReceiveHandle:SVR_QUIT_ROOM(pack)
    dumpW(pack,"用户离场离线")
    local uid = pack.uid
    local userInfo = g_317.userInfos[uid]
    local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
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
    dumpW(pack,"广播台费改变玩家金币")
end

--组局排行榜
function ReceiveHandle:SVR_GROUP_RANKING(pack)
    dumpW(pack,"组局结束")
    if pack then
        if SCENENOW["scene"]:getChildByName("layer_tips") then
            SCENENOW["scene"]:removeChildByName("layer_tips")
        end
        if SCENENOW["scene"]:getChildByName("DisbandLayer_tips") then
            SCENENOW["scene"]:removeChildByName("DisbandLayer_tips")
        end
        g_317.m_isGameOver = true
        g_317.settlementData = pack
        self.GameSceneView:settlement(pack)
    end
end

--组局时长
function ReceiveHandle:SVR_GROUP_TIME(pack)
    dumpW(pack,"SVR_GROUP_TIME")
    local round = tonumber(pack.round) or 0
    self.GameSceneView:setRound(round, pack.round_total)
end

--组局解散相关
--没有此房间，解散房间失败
function ReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)
    --dumpW("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")
    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")
end

function ReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST( pack )
    if tolua.isnull(self.disbandLayer) then
        local userLst = {}
        for i, v in pairs( g_317.userInfos or {} ) do
            table.insert(userLst, v)
        end
        local playerList = {} 
        for i, v in ipairs( userLst ) do
            local tmp = {}
            tmp.state = v.uid == pack.applyId and 3 or 2
            tmp.userId = v.uid
            tmp.userName = v.nickName
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
        for i, v in ipairs( pack.agreeMember_arr ) do
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
    for i, v in pairs( g_317.userInfos or {} ) do
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

--服务器广播玩家退出
function ReceiveHandle:SVR_BROADCAST_USER_LEAVEROOM(pack)
    if g_317.m_isGameOver then return end
    local uid = pack.uid
    if  uid == USER_INFO.uid then 
        if g_317.settlementData then
            self.GameSceneView:settlement(g_317.settlementData)
        else
            require("hall.GameCommon"):gExitGroupGame(USER_INFO.enter_mode, CLUB_ID)
        end
    elseif g_317.userInfos[uid] then
        local seat_id = g_317.userInfos[uid].seat_id
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        if UserInfoView then
            UserInfoView:hide()
            self.Config:delUser(uid)
        end
    end
end

function ReceiveHandle:BROADCAST_USER_IP(pack)
    -- require("hall.GameCommon"):showAlert(true, "提示：" .. msg .. "  ip地址相同，谨防作弊", 300)
end

---------------------------------------------------------------------------------------------------------------------------------------------
--扣除台费 4800

function ReceiveHandle:SVR_CHIP_CHANGE_BROADCAST(pack)
    dumpW(pack,"pack111")
    for _,data in pairs(pack.userinfo) do
        local uid = data.uid
        local userInfo = g_317.userInfos[uid]
        if not (userInfo) then return end
        userInfo.m_chips = userInfo.m_chips + data.chargeCoins
        local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
        UserInfoView:setScore(userInfo.m_chips)
    end
end

--5001
function ReceiveHandle:BROADCAST_ERROR_TIPS(pack)
    dumpW(pack, "-----返回错误提示5001-----")
    local errorCode = pack.errorCode
    local tbErrorCode = {
        [1]  = "操作无效",
        [10] = "您正在游戏中",
        [11] = "您选的座位上已经有人了",
        [12] = "您已经准备过了",
        [13] = "您还没准备",
        [14] = "您已经坐下了",
        [15] = "您正在围观中",
        [16] = "桌子已经满啦",
        [17] = "玩家不存在",
        [18] = "您金币不够啦，请充值",
        [20] = "游戏未开始",
        [20] = "下注超过上限",
        [21] = "必须闷三圈看牌哦！",
    }
    dumpW(tbErrorCode[errorCode],"错误提示")
    if  errorCode == 18 then
        local scenes  = SCENENOW.scene
        if scenes then
            scenes:performWithDelay(function()
                --去掉提示弹框
                local layer_tips = scenes:getChildByName("layer_tips")
                if  layer_tips then
                    layer_tips:removeSelf()
                end
                require("hall.GameTips"):showTips("提示", "", 2, "有玩家积分不足，已解散！")
            end,1.5)
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

--登陆错误
function ReceiveHandle:SVR_ERROR(pack)
    dumpW(pack, "-----登陆错误-----")
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
	if  tbErrorCode[pack.errorCode] then
		if pack.errorCode == 18 or pack.errorCode == 5 then
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
		elseif  pack.errorCode == 7 then
			 local exitFunc = function()
				 require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
			 end
			 require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[pack.errorCode],nil,exitFunc)
		else
			require("hall.GameTips"):showTips("提示", "", 1, tbErrorCode[pack.errorCode])
		end
	else
		require("hall.GameTips"):showTips("提示", "", 1, "未知的错误")
	end

end
--接收服务器放回的指定用户信息pack111
function ReceiveHandle:SVR_CHARGE_BROADCAST(pack)
    dumpW(pack,"pack111")
    local uid = pack.uid
    local userInfo = g_317.userInfos[uid]
    if not (userInfo) then return end
    userInfo.m_chips = userInfo.m_chips + pack.chargeCoins
    local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
    UserInfoView:setScore(userInfo.m_chips)

end

--回看
function ReceiveHandle:SERVER_COMMAND_GAMERESULT_RECORD(pack)
    dumpW(pack,"SERVER_COMMAND_GAMERESULT_RECORD")
    if #pack.gameResult == 0 then
        viewMgr:showTip({text = "无当前所选局数回看！"})
        return
    end
    local PokerCard = require("zhajinhua_jb.src.PokerCard")
    for i,userInfo in ipairs(pack.gameResult) do
        for idx,value in ipairs(userInfo.cards) do
            local cardNode = PokerCard.new(value)
            -- cardNode:setCard(value)
            -- cardNode:showFront() 
            pack.gameResult[i].cards[idx] = cardNode
        end
        pack.gameResult[i].xiazhu = pack.gameResult[i].xiazhu / 100
        local cardKind_imgPath = "zhajinhua_jb/res/card_type/"..userInfo.cardType..".png"
        pack.gameResult[i].cardType = cardKind_imgPath
        pack.gameResult[i].cardType_plist = 0 --1是plist 0不是
    end
    
    local CardsRoundRecord = SCENENOW.scene:getChildByName("CardsRoundRecord")
    if CardsRoundRecord then
        CardsRoundRecord:setData(pack)
    else
        local CardsRoundRecord = require("hall.common.CardsRoundRecord").new(pack)
        CardsRoundRecord:setName("CardsRoundRecord")
        CardsRoundRecord:setHandler(handler(SendHandle, SendHandle.CLI_COMMAND_GAMERESULT_RECORD))

        local size = SCENENOW.scene:getContentSize()
        -- CardsRoundRecord._csbNode:setAnchorPoint(cc.p(0.5, 0.5))
        -- CardsRoundRecord:setAnchorPoint(cc.p(0.5, 0.5))

        -- CardsRoundRecord._csbNode:setPosition(cc.size(size.width, size.height))
        -- CardsRoundRecord:setPosition(cc.size(size.width, size.height))
        CardsRoundRecord:setScale(0.67)
        CardsRoundRecord:addTo(SCENENOW.scene)
    
    end
end

--用户准备
function ReceiveHandle:SVR_READY(pack)
    dumpW(pack,"SVR_READY_GAME")
    local uid = pack.uid
    local seat_id = g_317.userInfos[uid].seat_id
    local userInfoView = self:getPlayerBySeatId(seat_id)
    userInfoView:isShowReady(true)
    g_317.userInfos[uid].if_ready = 1
end

--广播开始
function ReceiveHandle:SVR_START_BROADCAST(pack)
    dumpW(pack,"广播开始")
    self.GameSceneView:clearData()
    self.Config:starGame()
    g_317.countUserAllin = pack.countUserAllin
    g_317.zhus = pack.zhus
    g_317.now_zhu = pack.di_zhu
    g_317.min_pk_round = pack.min_pk_round
    g_317.min_allin_round = pack.min_allin_round
    g_317.table_chips = pack.table_chips

    local all_zhu = 0
    local di_zhu = pack.di_zhu
    local handle_seat = pack.handle_seat


    local time = self.CardMgr:sendCard()
    local func1 = function ()
        for idx, value in ipairs(pack.playersChips) do
            local userInfo = g_317.userInfos[value.uid]
            local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
            UserInfoView:setScore(value.m_chips)
            userInfo.m_chips = value.m_chips
    
            self.GameSceneView:diuChips(userInfo.uid, di_zhu)
            UserInfoView:isShowChip(true, di_zhu)
            all_zhu = all_zhu + di_zhu
        end
     
    
        self.GameSceneView:isShowXiaZhu(true, all_zhu)
        self.GameSceneView:hideAllPlayerLight()
        local UserInfoView = self:getPlayerBySeatId( handle_seat )
        UserInfoView:isShowLight(true)
        if handle_seat == g_317.my_seat_id then
            self.OprorateBtn:showButton(pack.can_compare)
        end
    end
    self.GameSceneView:setTimingFun( func1, time )

    self.GameSceneView:showStartTimer(pack.time)
    self.GameSceneView:isShowGameRound( pack.now_turns, pack.all_turns )
    
end

--发牌
function ReceiveHandle:SVR_SEND_CARD(pack)
    dumpW(pack,"--发牌")
    local cards = pack.cards    
    -- self.GameSceneView:stopStartTimer()
    g_317.handCards = self.CardMgr:sortOrder(cards)
    g_317.card_type = pack.card_type
    if pack.lookCardStatus == 1 then
        local UserInfoView = self:getPlayerBySeatId( g_317.my_seat_id )
        if g_317.isCuoPai then
            self.GameSceneView:cuopaiTest(cards)
            local cards = table.slice(cards, 1, 2)
            UserInfoView:setCards(cards)
        else
            UserInfoView:setCards(cards)
            UserInfoView:isShowCardType(true, pack.card_type)
        end
    end

end

--玩家看牌
function ReceiveHandle:SVR_KAN_SHOW(pack)
    dumpW(pack, "可以看牌")
    local uid = USER_INFO.uid
    if (g_317.isKan[uid] == nil or g_317.isKan[uid] == 0) and g_317.isDiu[uid] == nil then
        g_317.isCanKan = true
    end
end

--广播开始游戏倒计时 100F
function ReceiveHandle:SVR_BROADCAST_COUNT_DOWN(pack)
    dumpW(pack, "------广播开始游戏倒计时 100F------")
    if pack.time > 0 then
        self.GameSceneView:showStartTimer(pack.time)
    end
end

function ReceiveHandle:BROADCAST_CAN_START_GAME(pack)
    dumpW("广播可以显示开始游戏")
    self.GameSceneView:isShowBtnReady(false)
end

--广播全桌比牌
function ReceiveHandle:SVR_ALL_COMPARE( pack )
    print("广播全桌比牌")
    self.GameSceneView:AllCompare()
end

--广播比牌结果
function ReceiveHandle:SVR_BI_BROADCAST( pack )
    

    dumpW(pack,"---广播比牌结果--------------")
    g_317.countUserAllin = pack.countUserAllin

    local uid = pack.uid
    local buid = pack.buid
    local next_seat = pack.next_seat or -1
    local uid = pack.uid
    local userInfo = g_317.userInfos[uid]
    local all_zhu = pack.all_zhu
    local m_chips = pack.m_chips
    local user_zhu = pack.user_zhu


    self.ChatMgr:getQuanYaTxt(uid)
    self.GameSceneView:hideAllPlayerLight()
    self.GameSceneView:isShowXiaZhu(true, all_zhu)
    self.GameSceneView:diuChips(uid, pack.kou_gold)
    self.GameSceneView:showStartTimer(pack.time)
    self.GameSceneView:isShowGameRound( pack.now_turns, pack.all_turns )

    local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
    UserInfoView:setScore(m_chips)
    userInfo.m_chips = m_chips
    UserInfoView:isShowChip(true, user_zhu)

    local result = pack.result == 0 and true or false
    local isSelfComp = uid == USER_INFO.uid or buid == USER_INFO.uid --自己有参加比牌
    local datas = {
        [1] = { --发起比牌的人
            uid = uid,
            uidLookCardStatus = pack.uidLookCardStatus,
            cards = isSelfComp == true and pack.f_card or {0, 0, 0},
            result = result,
        },
        [2] = {
            uid = buid,
            uidLookCardStatus = pack.buidLookCardStatus,
            cards = isSelfComp == true and pack.s_card or {0, 0, 0},
            result = not result,
        },
    }
    self.GameSceneView:showCampare(datas)

    local func2 = function (  )
        self.GameSceneView:clearCampare()
        self:unfreezeEvent(PROTOCOL.SVR_END)
        if result then
            g_317.isDiu[uid] = 2
            local userInfo = g_317.userInfos[uid]
            local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
            UserInfoView:isShowQi(true) 
        else
            g_317.isDiu[buid] = 2
            local userInfo = g_317.userInfos[buid]
            local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
            UserInfoView:isShowQi(true) 
        end
    end
    self:freezeEvent(PROTOCOL.SVR_END, true)
    self.GameSceneView:setTimingFun( func2, 2 )
    self.OprorateBtn:clearData()
    if next_seat == -1 then
        self.GameSceneView:showStartTimer(0)
        return
    end

    g_317.now_zhu = pack.kou_gold / 2--比牌会乘2倍
    if g_317.isKan[uid] then
        g_317.now_zhu = g_317.now_zhu / 2--看牌会乘2倍
    end
    if next_seat == g_317.my_seat_id then
        self.OprorateBtn:showButton(pack.can_compare)
    end
end

--广播玩家加注
function ReceiveHandle:SVR_JIA_BROADCAST(pack)
    dumpW(pack,"---广播玩家加注--------------")
    local next_seat = pack.next_seat or -1
    local uid = pack.uid
    local userInfo = g_317.userInfos[uid]
    local gold = pack.gold
    local all_zhu = pack.all_zhu
    local m_chips = pack.m_chips
    self.ChatMgr:getJiaTxt(uid)
    self.GameSceneView:hideAllPlayerLight()

    self.GameSceneView:isShowXiaZhu(true, all_zhu)
    self.GameSceneView:diuChips(uid, gold)
    self.GameSceneView:showStartTimer(pack.time)
    self.GameSceneView:isShowGameRound( pack.now_turns, pack.all_turns )
    g_317.table_chips = pack.table_chips
    g_317.now_zhu = pack.round_chips
    SoundUtils:playCardKindEffect("raise", userInfo.sex)

    local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
    UserInfoView:setScore(m_chips)
    userInfo.m_chips = m_chips
    UserInfoView:isShowChip(true, pack.user_zhu)
    self.OprorateBtn:clearData()
    if next_seat == -1 then
        self.GameSceneView:showStartTimer(0)
        return
    end
    local UserInfoView = self:getPlayerBySeatId( next_seat )
    UserInfoView:isShowLight(true) 
    if next_seat == g_317.my_seat_id then
        self.OprorateBtn:showButton(pack.can_compare)
    end
end

--玩家跟注
function ReceiveHandle:SVR_GEN_BROADCAST(pack)
    dumpW(pack,"玩家跟注------")
    local uid = pack.uid
    self.ChatMgr:getGenTxt(pack)
    local next_seat = pack.next_seat or -1
    local uid = pack.uid
    local userInfo = g_317.userInfos[uid]
    local gold = pack.gold
    local all_zhu = pack.all_zhu
    local m_chips = pack.m_chips
    self.GameSceneView:hideAllPlayerLight()
    self.GameSceneView:isShowXiaZhu(true, all_zhu)
    self.GameSceneView:diuChips(uid, gold)
    self.GameSceneView:showStartTimer(pack.time)
    self.GameSceneView:isShowGameRound( pack.now_turns, pack.all_turns )
    SoundUtils:playCardKindEffect("call", userInfo.sex)

    local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
    UserInfoView:setScore(m_chips)
    userInfo.m_chips = m_chips
    UserInfoView:isShowChip(true, pack.user_zhu)
    
    self.OprorateBtn:clearData()
    if next_seat == -1 then
        self.GameSceneView:showStartTimer(0)
        return
    end
    local UserInfoView = self:getPlayerBySeatId( next_seat )
    UserInfoView:isShowLight(true) 
    if next_seat == g_317.my_seat_id then
        self.OprorateBtn:showButton(pack.can_compare)
    end
end

--广播玩家allin
function ReceiveHandle:SVR_ALLIN_BROADCAST(pack)
    local uid = pack.uid
    local next_seat = pack.next_seat or -1
    local uid = pack.uid
    local userInfo = g_317.userInfos[uid]
    local gold = pack.gold
    local all_zhu = pack.all_zhu
    local m_chips = pack.m_chips

    g_317.isAllin = 1--是否已经全压
    g_317.now_zhu = gold

    self.ChatMgr:getQuanYaTxt(uid)
    self.GameSceneView:hideAllPlayerLight()
    self.GameSceneView:isShowXiaZhu(true, all_zhu)
    self.GameSceneView:diuChips(uid, gold, true)
    self.GameSceneView:showStartTimer(pack.time)
    self.GameSceneView:isShowGameRound( pack.now_turns, pack.all_turns )
    SoundUtils:playCardKindEffect("yaman", userInfo.sex)

    local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
    UserInfoView:setScore(m_chips)
    userInfo.m_chips = m_chips
    UserInfoView:isShowChip(true, gold, true)

    self.OprorateBtn:clearData()
    dumpW(pack,"---广播玩家allin--------------")
    if next_seat == -1 then
        self.GameSceneView:showStartTimer(0)
        return
    end
    if next_seat == g_317.my_seat_id then
        self.OprorateBtn:showButton(pack.can_compare, 1)
    end
end

--玩家看牌
function ReceiveHandle:SVR_KAN_CARD(pack)
    dumpW(pack,"玩家看牌------")
    local uid = pack.uid
    local next_seat = pack.next_seat or -1
    self.ChatMgr:getKanTxt(uid)
    g_317.isKan[uid] = pack.isLookCard
    g_317.now_zhu = pack.round_chips

    if g_317.isKan[USER_INFO.uid] == 1 then
        g_317.isCanKan = false
    end

    local userInfo = g_317.userInfos[uid]
    local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
    UserInfoView:isShowQi(true, true)
    SoundUtils:playCardKindEffect("view", userInfo.sex)

    if next_seat == -1 then
        self.GameSceneView:showStartTimer(0)
        return
    end
    if next_seat == g_317.my_seat_id then
        self.OprorateBtn:showButton(pack.can_compare)
    end
end

--玩家弃牌
function ReceiveHandle:SVR_DIU_BROADCAST( pack )
    g_317.countUserAllin = pack.countUserAllin
    dumpW(pack, "玩家弃牌")
    local uid = pack.uid
    local next_seat = pack.next_seat or -1
    local userInfo = g_317.userInfos[uid]

    g_317.isDiu[uid] = 1

    self.ChatMgr:getQiTxt(uid)
    SoundUtils:playCardKindEffect("fold", userInfo.sex)
    local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
    UserInfoView:isShowQi(true) 
    self.GameSceneView:hideAllPlayerLight()

    self.OprorateBtn:clearData()
    if next_seat == -1 then
        self.GameSceneView:showStartTimer(0)
        return
    end
    if next_seat == g_317.my_seat_id then
        local is_allin = 0
        if pack.game_status == 4 then
            is_allin = 1
        end
        self.OprorateBtn:showButton(pack.can_compare, is_allin)
    end

    local UserInfoView = self:getPlayerBySeatId( next_seat )
    UserInfoView:isShowLight(true) 
end

--结算协议
function ReceiveHandle:SVR_END(pack)
    dump(pack,"--结算协议")
	local win_seat_id = nil
    for k,value in pairs(pack.userInfos) do
        local uid = value.uid
        local userInfo = g_317.userInfos[uid]
        local seat_id = userInfo.seat_id
		if value.turngold > 0 then
			win_seat_id = seat_id
		end
        local cards = value.compare_content[1]['cards']
        self.CardMgr:sortOrder(cards)
        -- local turngold = value.turngold
        if g_317.isDiu[uid] ~= 1 or uid == USER_INFO.uid then
            local UserInfoView = self:getPlayerBySeatId( seat_id )
            UserInfoView:setCards(cards)
        end
    end
    local time = self.GameSceneView:recycleChips(win_seat_id, pack)
    local func1 = function (  )
        dump(pack.userInfos,"pack.userInfos")
        --小局输赢分
        SoundUtils:playEffect("login_gold")
        for key, value in ipairs(pack.userInfos) do
            local uid = value.uid
            local turngold = value.turngold

            local userInfo = g_317.userInfos[uid]
            local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
            UserInfoView:setScore1(turngold)
            UserInfoView:setScore(value.m_chips)
            userInfo.m_chips = value.m_chips
        end
    end
    local func2 = function (  )
        self.GameSceneView:isShowXiaZhu(true, 0)
        self.GameSceneView:clearData()
        self.GameSceneView:isShowBtnReady(true)
        self:unfreezeEvent(PROTOCOL.SVR_GROUP_RANKING)
        self:unfreezeEvent(PROTOCOL.SVR_BROADCAST_USER_LEAVEROOM)
    end
    self:freezeEvent(PROTOCOL.SVR_GROUP_RANKING, true)
    self:freezeEvent(PROTOCOL.SVR_BROADCAST_USER_LEAVEROOM)
    self.GameSceneView:setTimingFun( func1, time )
    self.GameSceneView:setTimingFun( func2, time + 1 )
    self.OprorateBtn:clearData()
    self.GameSceneView:showStartTimer(0)
end
return ReceiveHandle