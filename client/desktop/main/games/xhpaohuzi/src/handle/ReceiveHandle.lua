require("framework.init")
local hallHandle = require("hall.HallHandle")
local ReceiveHandle = class("ReceiveHandle", hallHandle)
local PROTOCOL = require("xhpaohuzi.src.handle.Protocol")
local SoundUtils = require("xhpaohuzi.src.SoundUtils")
local SendHandle = require("xhpaohuzi.src.handle.SendHandle")
local CardUtils = require("xhpaohuzi.src.CardUtils")
local eventName = "xhpaohuzi"..os.now()

function ReceiveHandle:callFunc(pack)
    local cmd = pack.cmd
    pack.now = os.now()
    local item = self.frozenEvents[cmd]
	if item then
        printInfo("recieved frozen event[%s]", cmd)
        pack.packIdx = self.packIdx
        self.packIdx = self.packIdx + 1
		if item.keepLast then
			self.frozenEvents[cmd][1] = pack
		else
			self.frozenEvents[cmd][#item + 1] = pack
		end
        dump(pack)
		return
    end
    dump(pack)
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

function ReceiveHandle:freezeEventAll(cmd)
    local data = {
        PROTOCOL.SVR_DEAL,
        PROTOCOL.SVR_PLAYER_CHU_CARD,--0x1201--玩家出牌
        PROTOCOL.SVR_BUPAI_DEAL,--补牌（包括庄家第21张牌也包括每一次打牌之后，从下面摸上来的一张牌）
        PROTOCOL.SVR_PLAYER_OUT_CARD,--轮到哪个玩家操作出牌
        PROTOCOL.SVR_PLAYER_OPRATION,--玩家操作（碰、吃同时）
        PROTOCOL.SVR_PLAYER_HU_CARD,--0x1208--玩家胡牌
        PROTOCOL.SVR_PLAYER_PENG_CARD,--0x1204--用户碰牌
        PROTOCOL.SVR_PLAYER_PAO_CARD,--0x1205--玩家跑
        PROTOCOL.SVR_PLAYER_TI_CARD,--0x1206--玩家提牌
        PROTOCOL.SVR_PLAYER_WEI_CARD,--0x1207--玩家偎牌
        PROTOCOL.SVR_PLAYER_CHI_CARD,--0x1203--玩家吃牌
        PROTOCOL.SVR_PLAYER_BI_CARD,--0x1213--玩家吃牌
        PROTOCOL.SVR_PLAYER_TING_INFO,--听牌
        PROTOCOL.SVR_BEGIN_PIAO,--飘
        PROTOCOL.SVR_SEND_PIAO,--广播用户飘
        PROTOCOL.SVR_PLAYER_AI_STATE,--广播用户托管
    }
    for i, val in ipairs(data) do
        if cmd ~= val then
            self:freezeEvent(val)
        end
    end
    dump("-------冻结")
end

function ReceiveHandle:unfreezeEventAll(cmd)
    local data = {
        PROTOCOL.SVR_DEAL,
        PROTOCOL.SVR_PLAYER_CHU_CARD,--0x1201--玩家出牌
        PROTOCOL.SVR_BUPAI_DEAL,--补牌（包括庄家第21张牌也包括每一次打牌之后，从下面摸上来的一张牌）
        PROTOCOL.SVR_PLAYER_OUT_CARD,--轮到哪个玩家操作出牌
        PROTOCOL.SVR_PLAYER_OPRATION,--玩家操作（碰、吃同时）
        PROTOCOL.SVR_PLAYER_HU_CARD,--0x1208--玩家胡牌
        PROTOCOL.SVR_PLAYER_PENG_CARD,--0x1204--用户碰牌
        PROTOCOL.SVR_PLAYER_PAO_CARD,--0x1205--玩家跑
        PROTOCOL.SVR_PLAYER_TI_CARD,--0x1206--玩家提牌
        PROTOCOL.SVR_PLAYER_WEI_CARD,--0x1207--玩家偎牌
        PROTOCOL.SVR_PLAYER_CHI_CARD,--0x1203--玩家吃牌
        PROTOCOL.SVR_PLAYER_BI_CARD,--0x1213--玩家吃牌
        PROTOCOL.SVR_PLAYER_TING_INFO,--听牌
        PROTOCOL.SVR_BEGIN_PIAO,--飘
        PROTOCOL.SVR_SEND_PIAO,--广播用户飘
        PROTOCOL.SVR_PLAYER_AI_STATE,--广播用户托管
    }
    local packs = {}
    for i, val in ipairs(data) do
        if cmd ~= val then
            local item = self.frozenEvents[val]
            if item then
                if #item == 0 then
                    self.frozenEvents[val] = nil
                end
                for _, pack in ipairs(item) do
                    table.insert(packs, pack)
                    if item.keepLast then
                        break
                    end
                end
            else
                self.frozenEvents[val] = nil
            end
        end
    end
    table.sort(packs, function( a, b )
        return a.packIdx < b.packIdx
    end)
    dump(packs,"解冻")
    for i,pack in ipairs(packs) do
        for idx, pack1 in ipairs(self.frozenEvents[pack.cmd] or {}) do
            table.remove(self.frozenEvents[pack1.cmd], idx)
        end
        if self.frozenEvents[pack.cmd] and #self.frozenEvents[pack.cmd] == 0 then
            self.frozenEvents[pack.cmd] = nil
        end

        local ok, msg = xpcall(function() 
            self:dispatchEvent({ name = eventName..pack.cmd, pack = pack})
        end, debug.traceback)
        if not ok then
            print(msg)
        end
    end
end

function ReceiveHandle:ctor(gameScene)
    self.gameScene = gameScene
    self.GameSceneView = gameScene.GameSceneView
    self.TingView = self.GameSceneView.TingView
    self.Config = gameScene.Config
    self.HandCardView = self.GameSceneView.HandCardView
    self.OprorateBtn = self.GameSceneView.OprorateBtn
    self.GAME_STATE = 0--游戏状态  --游戏状态  0 空闲，1:进行中
    ReceiveHandle.super.ctor(self);
    self.frozenEvents = {}
    self.packIdx = 0
	local func_ = {
        --登录房间返回
        [PROTOCOL.SVR_LOGIN_ROOM_OK] = {handler(self, ReceiveHandle.SVR_LOGIN_ROOM_OK), ""},
        --断线重连
        [PROTOCOL.SVR_RELOAD_ROOM] = {handler(self, ReceiveHandle.SVR_RELOAD_ROOM), ""},
        --0x1008   --自己退出房间
        [PROTOCOL.SVR_QUIT] = {handler(self, ReceiveHandle.SVR_QUIT), ""},
        --进入房间
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, ReceiveHandle.SVR_LOGIN_ROOM_BROADCAST), ""},
        --房间局数相关
        [PROTOCOL.SVR_GROUP_TIME] = {handler(self, ReceiveHandle.SVR_GROUP_TIME), ""},
        --错误码提示
        [PROTOCOL.BROADCAST_ERROR_STATUS] = {handler(self, ReceiveHandle.BROADCAST_ERROR_STATUS), ""},
        --0x1005   --登陆房间失败提示
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, ReceiveHandle.BROADCAST_ERROR_TIPS)},
        --登陆错误
        [PROTOCOL.SVR_ERROR] = {handler(self, ReceiveHandle.SVR_ERROR)},
        --玩家坐下
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, ReceiveHandle.BROADCAST_USER_SIT_DOWN), ""},
        --玩家准备
        [PROTOCOL.SVR_READY_GAME] = {handler(self, ReceiveHandle.SVR_READY_GAME), ""},
        --总结算
        [PROTOCOL.G2H_BROADCAST_GROUP_RESULT] = {handler(self, ReceiveHandle.G2H_BROADCAST_GROUP_RESULT), ""},
         ----最后的总结算
         [PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, ReceiveHandle.SVR_GROUP_BILLBOARD), ""},
        --解散房间相关
        [PROTOCOL.G2H_CMD_DISSOLVE_FAILED] = {handler(self, ReceiveHandle.G2H_CMD_DISSOLVE_FAILED), ""},
        --广播当前组局解散情况
        [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST] = {handler(self, ReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST), ""},
        --广播桌子用户请求解散组局
        [PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {handler(self, ReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP), ""},
        --广播桌子用户成功解散组局
        [PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP] = {handler(self, ReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP), ""},
        --广播桌子用户解散组局 ，解散组局失败
        [PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP] = {handler(self, ReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP), ""},
        --1033玩家离开房间
        [PROTOCOL.SVR_BROADCAST_USER_LEAVEROOM] = {handler(self, ReceiveHandle.SVR_BROADCAST_USER_LEAVEROOM), ""},
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, ReceiveHandle.SERVER_CMD_MESSAGE), ""},
        --100e  哟用户退出
        [PROTOCOL.SVR_LOGOUT_ROOM] = {handler(self, ReceiveHandle.SVR_LOGOUT_ROOM), ""},
        --111 广播玩家充值
        [PROTOCOL.SVR_CHARGE_BROADCAST]       = {handler(self, ReceiveHandle.SVR_CHARGE_BROADCAST)},
        -- -- 各个玩家的积分改变
        [PROTOCOL.SVR_CHIP_CHANGE_BROADCAST] = {handler(self, ReceiveHandle.SVR_CHIP_CHANGE_BROADCAST)},
        [PROTOCOL.SVR_REQ_TEST_CARDS] = {handler(self, ReceiveHandle.SVR_REQ_TEST_CARDS), ""},
        --发牌
        [PROTOCOL.SVR_DEAL] = {handler(self, ReceiveHandle.SVR_DEAL), ""},
        --玩家操作（碰、吃同时）
        [PROTOCOL.SVR_PLAYER_OPRATION] = {handler(self, ReceiveHandle.SVR_PLAYER_OPRATION), ""},
        --轮到哪个玩家操作出牌
        [PROTOCOL.SVR_PLAYER_OUT_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_OUT_CARD), ""},
        --补牌（包括庄家第21张牌也包括每一次打牌之后，从下面摸上来的一张牌）
        [PROTOCOL.SVR_BUPAI_DEAL] = {handler(self, ReceiveHandle.SVR_BUPAI_DEAL), ""},

        [PROTOCOL.SVR_PLAYER_HU_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_HU_CARD), ""},--0x1208                        --玩家胡牌
        [PROTOCOL.SVR_PLAYER_PENG_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_PENG_CARD), ""},--0x1204             --用户碰牌
        [PROTOCOL.SVR_PLAYER_PAO_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_PAO_CARD), ""},-- 0x1205                         --玩家跑
        [PROTOCOL.SVR_PLAYER_TI_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_TI_CARD), ""},--0x1206                         --玩家提牌
        [PROTOCOL.SVR_PLAYER_WEI_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_WEI_CARD), ""},--0x1207                        --玩家偎牌
        [PROTOCOL.SVR_PLAYER_CHI_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_CHI_CARD), ""},--0x1203                         --玩家吃牌
        [PROTOCOL.SVR_PLAYER_BI_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_BI_CARD), ""},--0x1213                         --玩家吃牌
        [PROTOCOL.SVR_PLAYER_CHU_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_CHU_CARD), ""},--0x1201                         --玩家出牌
        [PROTOCOL.SVR_PLAYER_TING_INFO] = {handler(self, ReceiveHandle.SVR_PLAYER_TING_INFO), ""},--听牌
        -- [PROTOCOL.SVR_PLAYER_FAN_XIN] = {handler(self, ReceiveHandle.SVR_PLAYER_FAN_XIN), ""},--0x1214                         --玩家翻醒
        -- [PROTOCOL.SVR_PLAYER_TING_HU_INFO] = {handler(self, ReceiveHandle.SVR_PLAYER_TING_HU_INFO), ""},--听牌
        [PROTOCOL.SVR_BEGIN_PIAO] = {handler(self, ReceiveHandle.SVR_BEGIN_PIAO), ""},--飘
        [PROTOCOL.SVR_SEND_PIAO] = {handler(self, ReceiveHandle.SVR_SEND_PIAO), ""},----广播用户飘
        [PROTOCOL.SVR_PLAYER_AI_STATE] = {handler(self, ReceiveHandle.SVR_PLAYER_AI_STATE), ""},----广播用户托管

    }
    table.merge(self.func_, func_)
    self:addHandleMgr()
end                   

function ReceiveHandle:BROADCAST_ERROR_STATUS(pack)
	dump(pack,"BROADCAST_ERROR_STATUS")
end

function ReceiveHandle:SVR_PLAYER_TING_INFO(pack)
    dump(pack, '----------听牌消息---------')
    self.TingView:clearTingData()
    self.HandCardView:setTings(pack.tingCards)
end

function ReceiveHandle:SVR_PLAYER_TING_HU_INFO(pack)
    dump(pack, '----------听牌消息---------')
    self.HandCardView:setTingHuData(pack.tingCards)
end


--进入房间
function ReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)
	print("=====服务器广播用户登陆房间======")
    dump(pack,"SVR_LOGIN_ROOM_BROADCAST")
    local seat_id = pack.seat_id
    local uid = pack.uid
    if g_398.userInfos[uid] then--已添加
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        UserInfoView:isShowNewWork(false)
        return
    end
    local viewId = self.gameScene:getViewIdBySeatId(seat_id)
    self.Config:addUser( uid, seat_id, viewId, pack )
    if uid == USER_INFO.uid and seat_id >= 0 then
        g_398.my_seat_id = seat_id
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
    self.GameSceneView:showGPSButton()
end

function ReceiveHandle:getPlayerBySeatId( seatId )
    return self.GameSceneView:getPlayerBySeatId( seatId )
end

--玩家坐下
function ReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
    print("=====有玩家进来了啦！！！====", pack.uid)
    local seat_id = pack.seat_id
    local uid = pack.uid
    if uid == USER_INFO.uid then
        g_398.my_seat_id = seat_id
    end
    local viewId = self.gameScene:getViewIdBySeatId(seat_id)
    self.Config:addUser( uid, seat_id, viewId, pack )
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    UserInfoView:show()
    UserInfoView:refreshPlayerInfo(pack.portrait,uid,pack.sex,pack.nickName, pack.ip, pack.addres)
    UserInfoView:setScore(pack.m_chips)
    if uid == USER_INFO.uid then
        for k,v in ipairs(self.playerlist) do
            local uid = v.uid
            local seat_id = v.seat_id
            local viewId = self.gameScene:getViewIdBySeatId(seat_id)
            self.Config:addUser( uid, seat_id, viewId, v )
            local UserInfoView = self:getPlayerBySeatId( v.seat_id )
            UserInfoView:show()
            UserInfoView:refreshPlayerInfo(v.portrait, v.uid, v.sex, v.nickName, v.ip, v.addres)
            UserInfoView:setScore(v.m_chips)
            UserInfoView:isShowNewWork(v.if_online == 0)
            if v.if_ready == 1 then
                UserInfoView:isShowReady(true)
            end
        end
        self.GameSceneView:isShowBtnReady( true )
    end
    self.GameSceneView:showGPSButton()
end

--登录房间OK 1007
function ReceiveHandle:SVR_LOGIN_ROOM_OK(pack)
    dump(pack,"SVR_LOGIN_ROOM_OK")
    HEART_BEAT_TID = USER_INFO.tid--大厅用必要
    CLUB_ID = pack.club_id
    USER_INFO.family_id = pack.club_id
    require(NetworkLoadingView_filePath):removeView(888)
    g_398.TOTAL_PLAYERNUM = pack.max_mount
    pack.RoomInfo = json.decode(pack.RoomInfo)
    g_398.gameConfig = pack.RoomInfo
    g_398.OwnerID = pack.OwnerID
    self.GameSceneView:showGameConfig(pack.RoomInfo)
    self.GameSceneView:setRoomId( pack.inviteCode )
    g_398.my_seat_id = pack.seat_id
    --将其他玩家的信息记录下来
    self.firstEnter = g_398.my_seat_id == -1 and USER_INFO.isWatch ~= 0--不是观战
    if self.firstEnter then
        self.playerlist = pack.playerlist
    else
        for k,v in ipairs(pack.playerlist) do
            local uid = v.uid
            local seat_id = v.seat_id
            if seat_id ~= -1 then
                local viewId = self.gameScene:getViewIdBySeatId(seat_id)
                self.Config:addUser( uid, seat_id, viewId, v )
                local UserInfoView = self:getPlayerBySeatId( v.seat_id )
                UserInfoView:show()
                UserInfoView:refreshPlayerInfo(v.portrait, v.uid, v.sex, v.nickName, v.ip, v.addres)
                UserInfoView:isShowNewWork(v.if_online == 0)
                UserInfoView:setScore(v.m_chips)
                if v.if_ready == 1 then
                    UserInfoView:isShowReady(true)
                elseif uid == USER_INFO.uid then
                    self.GameSceneView:isShowBtnReady( true )
                end
            end
        end
        self.GameSceneView:showGPSButton()
    end
end

--房间局数相关
function ReceiveHandle:SVR_GROUP_TIME(pack)
    dump(pack,"SVR_GROUP_TIME")
    self.GameSceneView:setRound(pack.round, pack.round_total)
end

--游戏准备返回 6001
function ReceiveHandle:SVR_READY_GAME(pack)
    dump(pack,"SVR_READY_GAME")
    local uid = pack.uid
    local seat_id = g_398.userInfos[uid].seat_id
    local userInfoView = self:getPlayerBySeatId(seat_id)
    userInfoView:isShowReady(true)
end

--玩家断线重连 0x1009 1009
function ReceiveHandle:SVR_RELOAD_ROOM(pack)
    dump(pack, "==我断线重连了===pack")
    require(NetworkLoadingView_filePath):removeView(888)
    HEART_BEAT_TID = USER_INFO.tid--大厅用必要

    CLUB_ID = pack.club_id
    USER_INFO.family_id = pack.club_id

    g_398.TOTAL_PLAYERNUM = pack.max_mount
    g_398.OwnerID = pack.OwnerID
    self.GAME_STATE = pack.GAME_STATE
    self.GameSceneView:clearData()
    pack.RoomInfo = json.decode(pack.RoomInfo)
    g_398.gameConfig = pack.RoomInfo
    g_398.banker_seat_id = pack.banker_seat_id

    self.GameSceneView:showGameConfig(pack.RoomInfo)
    self.GameSceneView:setRoomId( pack.inviteCode )
    self.GameSceneView:setRound( pack.round, pack.round_total )
    for k,v in pairs(pack.playerlist) do
        if v.uid == USER_INFO.uid then
            g_398.my_seat_id = v.seat_id
        end 
    end

    for k,v in pairs(pack.playerlist) do
        local seat_id = v.seat_id
        local uid = v.uid
        if seat_id ~= -1 then
            local viewId = self.gameScene:getViewIdBySeatId(seat_id)
            self.Config:addUser( uid, seat_id, viewId, v )
            local UserInfoView = self:getPlayerBySeatId( seat_id )
            UserInfoView:show()
            UserInfoView:refreshPlayerInfo(v.portrait, uid, v.sex, v.nickName, v.ip, v.addres)
            UserInfoView:setScore(v.m_chips)
            UserInfoView:setTotalScore(v.m_totalBlc)
            UserInfoView:isShowNewWork(v.if_online == 0)
            UserInfoView:isShowZhuang(pack.banker_seat_id == seat_id)
            if self.GAME_STATE == 0 and v.if_ready == 1 then
                UserInfoView:isShowReady(true)
            elseif self.GAME_STATE == 0 and uid == USER_INFO.uid then
                self.GameSceneView:isShowBtnReady( true )
            end
        end
    end
    self.GameSceneView:showGPSButton()
    if self.GAME_STATE == 0 then 
        return
    end
    for k,v in pairs(pack.playerlist) do
        local seat_id = v.seat_id
        if seat_id ~= -1 then
            local UserInfoView = self:getPlayerBySeatId( seat_id )
            if g_398.isPiao then
                UserInfoView:isShowPiaoCount(true, v.piao)
                g_398.piaoPoints[seat_id] = v.piao
            end
            if seat_id == g_398.my_seat_id then
                if v.AIState == 1 then
                    self.GameSceneView:isShowTuoGuan( true )
                    g_398.isTuoGuan = true
                end

            end
        end
    end
    self.GameSceneView:starGame()

    local OutCardUserId = pack.OutCardUserId
    if OutCardUserId ~= -1 then--轮到谁出牌
        local UserInfoView = self:getPlayerBySeatId( OutCardUserId )
        UserInfoView:isShowLight(true)
        if OutCardUserId == g_398.my_seat_id then
            self.GameSceneView:isShowChuPai(true)
        end
    end

    --显示谁出了牌
    if pack.m_CurOutCard > 0 then--上一把谁出了牌
        g_398.curOutCard = pack.m_CurOutCard
        g_398.curOutSeat = pack.m_nCurGetCarCardSeatId
        local UserInfoView = self:getPlayerBySeatId( pack.m_nCurGetCarCardSeatId )
        UserInfoView:isShowOutIngCard(true, pack.m_CurOutCard)
    end

    --显示谁摸了牌
    if pack.m_CurGetCard > 0 then--显示谁摸了牌
        g_398.curOutCard = pack.m_CurGetCard
        g_398.curOutSeat = pack.m_nCurGetCarCardSeatId
        local UserInfoView = self:getPlayerBySeatId( g_398.curOutSeat )
        UserInfoView:isShowOutIngCard(true,  g_398.curOutCard, true)
    end

    self.HandCardView:setCurHandCards(pack.HandCardDatas)  --初始化牌
    self.GameSceneView:isShowBackNodeCount( true, pack.diPaiCount )
    --初始化玩家出的牌 
   
    for k, v in pairs(pack.LastCarddata) do
        local UserInfoView = self:getPlayerBySeatId( v.seat_id )
        for idx, card in ipairs(v.cards) do
            UserInfoView:showOutCard(card, idx)
        end
    end


    for k, value in ipairs(pack.Carddata) do
        self:handCards( g_398.t_ti, value.tiList, 4, value.seat_id )
        self:handCards( g_398.t_pao, value.paoList, 4, value.seat_id )
        self:handCards( g_398.t_peng, value.pengList, 3, value.seat_id )
        self:handCards( g_398.t_wei, value.weiList, 3, value.seat_id )
        self:handCards( g_398.t_chi, value.chiList, 3, value.seat_id )
        self:handCards( g_398.t_bi, value.biList, 3, value.seat_id )
    end

    local tingCards = pack.tingCards
    local tingHuCards = pack.tingHuCards
    self.HandCardView:setTings(pack.tingCards)
    self.TingView:setTingHuCards(tingHuCards)
    self.TingView:setTing2(tingHuCards)
end

function ReceiveHandle:handCards( _type, value, num, seat_id )
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    for i,data in ipairs(value) do
        local card = data
        local cards = {}
        if _type == g_398.t_bi then
            for k2,v2 in pairs(data.cardsList) do
                cards = v2.Cardbuf
                card = v2.Cardbuf[1]
                UserInfoView:showTypeCards(cards, g_398.t_chi, card)
            end
        else
            if _type == g_398.t_ti then
                cards = {data, 0, 0, 0}
            elseif _type == g_398.t_pao then
                cards = {data, data, data, data}
            elseif _type == g_398.t_peng then
                cards = {data, data, data}
            elseif _type == g_398.t_wei then
                card = data.cardvalue
                local card1 = data.cardvalue
                if seat_id ~= g_398.my_seat_id and data.cardType == 1 then --暗偎
                    card1 = 0
                end
                cards = {card1, 0, 0}
            elseif _type == g_398.t_chi then
                cards = data.Cardbuf
                card = data.Cardbuf[1]
            end
            UserInfoView:showTypeCards(cards, _type, card)
        end
    end
end

--组局解散相关
--没有此房间，解散房间失败
function ReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)
    --dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")
    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")
end

function ReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST( pack )
    if tolua.isnull(self.disbandLayer) then
        local userLst = {}
        for i, v in pairs( g_398.userInfos or {} ) do
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
    for i, v in pairs( g_398.userInfos or {} ) do
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
    if g_398.m_isGameOver then return end
    local uid = pack.uid
    if  uid == USER_INFO.uid then 
        if g_398.settlementData then
            self.GameSceneView:settlement(g_398.settlementData)
        else
            require("hall.GameCommon"):gExitGroupGame(USER_INFO.enter_mode, CLUB_ID)
        end
    else
        local seat_id = g_398.userInfos[uid].seat_id
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        if UserInfoView then
            UserInfoView:hide()
            self.Config:delUser(uid)
        end
        self.GameSceneView:showGPSButton()
    end
end

--广播玩家站起 1032
function ReceiveHandle:BROADCAST_USER_STAND_UP(pack)
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
        local seat_id = g_398.userInfos[uid].seat_id
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

function ReceiveHandle:SVR_MSG_EMOJI_ARMATURE(pack)
    local EmojiArmatureView = SCENENOW.scene:getChildByName("EmojiArmatureView")
    if not EmojiArmatureView then
        return
    end
    local from_id = pack.uid
    local to_uid = pack.to_uid
    local emojiType = pack.type
    local from_seatId = 0
    if from_id == USER_INFO.uid then
        from_seatId = g_398.my_seat_id
    else
        from_seatId = g_398.userInfos[from_id].seat_id
    end
    local to_seatId = 0
    if to_uid == USER_INFO.uid then
        to_seatId = g_398.my_seat_id
    else
        local otherInfo = g_398.userInfos[to_uid] or {}
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

------------------------------------------------------------------
function ReceiveHandle:showExpression(msg)
    local uid_from = tonumber(msg["uid_from"]) or 1
    local uid_to = tonumber(msg["uid_to"]) or 1
    local expressionType = tonumber(msg["expressionType"]) or 1
    local from_x = 100
    local from_y = 100
    local to_x   = 600
    local to_y   = 500
    require("hall.view.animView.animView"):ShowAnimationByPosition(from_x, from_y,to_x,to_y,expressionType)        
end

--聊天
function ReceiveHandle:SVR_MSG_FACE(pack)
    local faceUI = self.GameSceneView:getChildByName("faceUI")
    local uid = pack.uid
    local emojiType = pack.type

    local sex = 0
    local seatId = 0
    if uid == USER_INFO.uid then
        sex = USER_INFO.sex
        seatId = g_398.my_seat_id
    else
        sex = g_398.userInfos[uid].sex
        seatId = g_398.userInfos[uid].seat_id
    end
    local userInfoView = self:getPlayerBySeatId(seatId)
    local isLeft = true
    if userInfoView:getName() == "player_3" then
        isLeft = false
    end
    if tonumber(sex) >= 0 then
        faceUI:showGetFace(uid, emojiType, tonumber(sex), userInfoView.img_head, isLeft)
    end

end

--5001
function ReceiveHandle:BROADCAST_ERROR_TIPS(pack)
    dump(pack, "-----返回错误提示5001-----")
    local errorCode = pack.errorCode
    local tbErrorCode = {
        [1]  = "操作无效",
        [10] = "游戏进行中，请稍后！",
        [11] = "您选的座位上已经有人了",
        [12] = "您已经准备过了",
        [13] = "您还没准备",
        [14] = "您已经坐下了",
        [15] = "您正在围观中",
        [16] = "桌子已经满啦",
        [17] = "玩家不存在",
        [18] = "您钻石不够啦，请充值",
        [19] = "游戏未开始",
        [20] = "无法在当前阶段做此操作！",
        [21] = "下注超过上限",
        [22] = "您在座位上时不能坐庄！",
        [24] = "网络异常，此牌已被使用！",
		
		[100] = "网络异常，吃操作无效",
    }
    if errorCode == 18 then
        SCENENOW["scene"]:performWithDelay(function()

            --去掉提示弹框
            local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
            if  layer_tips then
                layer_tips:removeSelf()
            end

            if not isiOSVerify then
                -- SCENENOW["scene"]:requestCharge()
                require("hall.GameTips"):showTips("提示", "", 2, "有玩家积分不足，已解散！")
            end

        end,1.5)
    end

    dump(tbErrorCode[errorCode],"错误提示")
    local errorTxt = tbErrorCode[errorCode] or "网络异常"
    if errorCode == 100 or errorCode == 24 or not tbErrorCode[errorCode] then
        require("hall.HallServer"):loginGameNew(USER_INFO.GroupLevel, USER_INFO.tid, USER_INFO.activity_id, 1)
        viewMgr:showTip({text = errorTxt})
    else
        require("hall.GameTips"):showTips("提示", "", 3, errorTxt)
    end
end

--登陆错误
function ReceiveHandle:SVR_ERROR(pack)
    dump(pack, "-----进入房间失败-----")
    local tbErrorCode = {
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
        [19] = "积分不足",
    }
    if tbErrorCode[pack.errorCode] then
        if pack.errorCode == 18 or pack.errorCode == 7 or pack.errorCode == 5 then
             local exitFunc = function()
                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
             end
             require("hall.GameTips"):showTips("提示", "", 2, tbErrorCode[pack.errorCode],nil,exitFunc)
        else
            require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[pack.errorCode])
        end
    else
        require("hall.GameTips"):showTips("提示", "", 3, "未知的错误") 
    end

end

function ReceiveHandle:SVR_QUIT()
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end


function ReceiveHandle:SVR_LOGOUT_ROOM(pack)
    dump(pack,"用户离场")
    local uid = pack.uid
    local userInfo = g_398.userInfos[uid]
    if not (userInfo) then return end
    local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
    UserInfoView:isShowNewWork(true) 
end

--接收服务器放回的指定用户信息pack111
function ReceiveHandle:SVR_CHARGE_BROADCAST(pack)
    dump(pack,"pack111")
    local uid = pack.uid
    local userInfo = g_398.userInfos[uid]
    if not (userInfo) then return end
    userInfo.m_chips = userInfo.m_chips + pack.chargeCoins

    local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
    UserInfoView:setScore(userInfo.m_chips)

    --上分提示
    for k,v in pairs(g_398.userInfos) do
        if pack.uid == v.uid then
            local str = require('hall.GameCommon'):formatNick(v.nickName, 4) .. "(" .. pack.uid .. ")"
            viewMgr:showTip({text = "玩家:" .. str .. "被上" .. ( pack.chargeCoins / 100) .. "积分"}) 
        end
    end
end

--接收服务器放回的指定用户信息pack111
function ReceiveHandle:SVR_CHIP_CHANGE_BROADCAST(pack)
    dump(pack,"pack111")

    for _,data in pairs(pack.userinfo) do
        local uid = data.uid
        local userInfo = g_398.userInfos[uid]
        if not (userInfo) then return end
        userInfo.m_chips = userInfo.m_chips + data.chargeCoins
        local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
        UserInfoView:setScore(userInfo.m_chips)
    end
end

function ReceiveHandle:SVR_TEST_CARD(pack)
	local text = "成功"
    if pack.res == 1 then
    else
		text = "失败"
	end
	viewMgr:showTip({text = text})
end

function ReceiveHandle:SVR_REQ_TEST_CARDS(pack)
    if pack.cardCount > 0 then
        self.GameSceneView:setZiPaiTest( pack.cards )
    end
end

--发牌返回
function ReceiveHandle:SVR_DEAL(pack)
    dump(pack,"开始玩家发牌SVR_DEAL")
    self.GameSceneView:clearData()
    self.Config:starGame()
    self.GameSceneView:starGame()

    local seat_id = pack.seat_id
    if g_398.my_seat_id == seat_id then
        self.HandCardView:setCurHandCards(pack.HandCardDatas, true)  --初始化牌
    end
    local UserInfoView = self:getPlayerBySeatId(pack.banker_seat_id)
    UserInfoView:isShowZhuang(true)
    self.GameSceneView:isShowBackNodeCount( true, pack.diPaiCount )
    g_398.banker_seat_id = pack.banker_seat_id
end

--玩家进行操作
function ReceiveHandle:SVR_PLAYER_OPRATION(pack)
    self.OprorateBtn:setData( pack.Cardbuf )
    self.GameSceneView:isShowChuPai(false)
    self.GameSceneView:hideAllPlayerLight()
end

--轮到那个玩家进行出牌操作
function ReceiveHandle:SVR_PLAYER_OUT_CARD(pack)
    dump(pack, "====此玩家开始出牌====")
    local seat_id = pack.seat_id
    self.GameSceneView:hideAllPlayerLight()
    local UserInfoView = self:getPlayerBySeatId(seat_id)
    UserInfoView:isShowLight(true)
    print(seat_id == g_398.my_seat_id)
    if seat_id == g_398.my_seat_id then
        self.GameSceneView:isShowChuPai(true)
    else
        self.GameSceneView:isShowChuPai(false)
    end
end

--补牌或者派发单张
function ReceiveHandle:SVR_BUPAI_DEAL(pack)
    dump(pack, "补牌或者派发单张")
    local seat_id = pack.seat_id
    local CardValue = pack.CardValue
    local viewId = g_398.viewIds[seat_id] or 0 
    if (pack.if_draw == 1 or pack.card_from == 1 ) then--发牌到手里
        local card = CardValue 
        -- if seat_id ~= g_398.my_seat_id then
        --     card = 0
        -- end
        local time = self.GameSceneView:sendCard( viewId, card )
        local func1 = function (  )
            if seat_id == g_398.my_seat_id then
                self.HandCardView:addHandCard( CardValue )
            end
            if not pack.packIdx then
                self:unfreezeEvent(PROTOCOL.SVR_PLAYER_OUT_CARD)
            end        end
        local func2 = function (  )
            if not pack.packIdx then
                self:unfreezeEventAll()
            end
        end
        if not pack.packIdx then
            self:freezeEventAll()
        end
        self.GameSceneView:setTimingFun( func1, time )
        self.GameSceneView:setTimingFun( func2, time+0.1 )

    else
        self.GameSceneView:hideAllPlayerOutCard()
        local UserInfoView = self:getPlayerBySeatId(seat_id)
        self.GameSceneView:showActionOutIngCard( seat_id, CardValue, true )
        SoundUtils:SoundCard(CardValue, seat_id)
        self.GameSceneView:showOutCard()
        g_398.curOutCard = CardValue --当前
        g_398.curOutSeat = seat_id --当前
    end
    
    self.GameSceneView:isShowBackNodeCount( true, pack.diPaiCount )
    self.TingView:updateTingData( )
end

--玩家出牌0x1201                         --玩家出牌
function ReceiveHandle:SVR_PLAYER_CHU_CARD(pack)
    dumpW(pack, "0x1201                         --玩家出牌")
    local seat_id = pack.seat_id
    local CardValue = pack.CardValue
    self.GameSceneView:hideAllPlayerOutCard()
    self.GameSceneView:isShowChuPai(false)
    self.GameSceneView:hideAllPlayerLight()

    local isShowChu = false
    if seat_id == g_398.my_seat_id then
        if g_398.curClickCardNode and g_398.curClickCardNode._pokerCard == CardValue then
            self.HandCardView:removeCardNode( g_398.curClickCardNode )
        elseif g_398.isTuoGuan then
            self.HandCardView:removeHandCards( {CardValue} )
            isShowChu = true
        end 
        if isShowChu then --自己出牌的时候客户端已经删牌了 这里面的动作已经执行过了
            self.HandCardView:setTingHuBtn(CardValue)
        end
    else
        isShowChu = true
    end
    if isShowChu then --自己出牌的时候客户端已经删牌了 这里面的动作已经执行过了
        self.GameSceneView:showActionOutIngCard( seat_id, CardValue, false)
        SoundUtils:SoundCard(CardValue, seat_id)
        self.GameSceneView:showOutCard()
    end

    g_398.curOutCard = CardValue
    g_398.curOutSeat = seat_id
    self.TingView:updateTingData( )
end

function ReceiveHandle:SVR_PLAYER_PENG_CARD(pack )--0x1204             --用户碰牌
    dump(pack, "0x1204             --用户碰牌")
    self.OprorateBtn:clearData()
    self.GameSceneView:hideAllPlayerOutCard()
    local seat_id = pack.seat_id
    local CardValue = pack.CardValue
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    local cards = {
        CardValue,
        CardValue,
        CardValue,
    }
    if seat_id == g_398.my_seat_id then
        self.HandCardView:removeHandCards( clone(cards), g_398.curOutCard )
    end
    UserInfoView:showTypeCards(cards, g_398.t_peng, CardValue, true)
    SoundUtils:SoundCardType(g_398.t_peng, seat_id)
    UserInfoView:showImgTxt( g_398.t_peng )
    g_398.curOutCard = nil
    g_398.curOutSeat = nil
    self.TingView:updateTingData( )
end

function ReceiveHandle:SVR_PLAYER_WEI_CARD(pack )--0x1207                        --玩家偎牌
    dump(pack, "0x1207                        --玩家偎牌")
    self.OprorateBtn:clearData()
    self.GameSceneView:isShowBackNodeCount( true, pack.diPaiCount )
    if not pack.packIdx then
        self:freezeEventAll()
    end
    local seat_id = pack.seat_id
    local CardValue = pack.CardValue
    local showOutCard = pack.CardValue
    if pack.cardType == 1 then --暗偎
        if seat_id == g_398.my_seat_id then
            SoundUtils:SoundCard(CardValue, seat_id)
        end
        self.GameSceneView:showOutCard()
        self.GameSceneView:hideAllPlayerOutCard()
        self.GameSceneView:showActionOutIngCard( seat_id, showOutCard, true )
    end
   
    local func1 = function (  )
        self.GameSceneView:hideAllPlayerOutCard()
        local cards = {
            CardValue, CardValue, CardValue,
        }
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        if seat_id == g_398.my_seat_id then
            self.HandCardView:removeHandCards( clone(cards) )
        end
        cards = {
            CardValue, 0, 0,
        }
        if pack.cardType == 1 and seat_id ~= g_398.my_seat_id then --暗偎
            cards[1] = 0
        end

        UserInfoView:showTypeCards(cards, g_398.t_wei, CardValue, true)
        UserInfoView:showImgTxt( g_398.t_wei )
        SoundUtils:SoundCardType(g_398.t_wei, seat_id)
        self.TingView:updateTingData( )
    end
    
    local func2 = function (  )
        if not pack.packIdx then
            self:unfreezeEventAll()
        end
    end
    self.GameSceneView:setTimingFun( func1, 1.2 )
    self.GameSceneView:setTimingFun( func2, 1.5 )
    g_398.curOutCard = nil
    g_398.curOutSeat = nil
end

function ReceiveHandle:SVR_PLAYER_CHI_CARD(pack )--0x1203                         --玩家吃牌
    dump(pack, "0x1203                         --玩家吃牌")
    self.OprorateBtn:clearData()

    local seat_id = pack.seat_id
    SoundUtils:SoundCardType(g_398.t_chi, seat_id)
    self.GameSceneView:hideAllPlayerOutCard()
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    if seat_id == g_398.my_seat_id then
        self.HandCardView:removeHandCards( clone(pack.Cardbuf), g_398.curOutCard )
    end
    UserInfoView:showTypeCards(pack.Cardbuf, g_398.t_chi, pack.Cardbuf[1], true)
    UserInfoView:showImgTxt( g_398.t_chi )
    g_398.curOutCard = nil
    g_398.curOutSeat = nil
    self.TingView:updateTingData( )
end

function ReceiveHandle:SVR_PLAYER_BI_CARD(pack )--0x1213                         --玩家比牌
    dump(pack, "0x1213                         --玩家比牌")
    self.OprorateBtn:clearData()
    local seat_id = pack.seat_id
    SoundUtils:SoundCardType(g_398.t_chi, seat_id)
    self.GameSceneView:hideAllPlayerOutCard()
    if seat_id == g_398.my_seat_id then
        self.HandCardView:removeHandCards( clone(pack.Cardbuf))
    end

    local UserInfoView = self:getPlayerBySeatId( seat_id )
    while true do
        local cards = table.splice(pack.Cardbuf, 1, 3)
        if #cards == 3 then
            UserInfoView:showTypeCards(cards, g_398.t_chi, cards[1], true)
        else
            break
        end
    end
    g_398.curOutCard = nil
    g_398.curOutSeat = nil
    self.TingView:updateTingData( )
end

function ReceiveHandle:SVR_PLAYER_TI_CARD(pack )--0x1206                         --玩家提牌
    dump(pack, "0x1206                         --玩家提牌")
    self.OprorateBtn:clearData()
    self.GameSceneView:isShowBackNodeCount( true, pack.diPaiCount )
    local seat_id = pack.seat_id
    local CardValue = pack.CardValue
    if CardValue == g_398.curOutCard then
        g_398.curOutCard = nil
        g_398.curOutSeat = nil
    end
    if pack.IsFirst == 0 then --不是起手提就放弃弃牌区 非起手提有一个假的摸牌效果
        local showOutCard = pack.CardValue
        if seat_id ~= g_398.my_seat_id then
            showOutCard = 0
        else
            SoundUtils:SoundCard(CardValue, seat_id)
        end
        self.GameSceneView:hideAllPlayerOutCard()
        self.GameSceneView:showActionOutIngCard( seat_id, showOutCard, true )
        self.GameSceneView:showOutCard()
    end
    local func1 = function (  )
        if pack.IsFirst == 0 then --不是起手提
            self.GameSceneView:hideAllPlayerOutCard()
        end
        local cards = {
            CardValue, CardValue, CardValue, CardValue,
        }
        if seat_id == g_398.my_seat_id then
            self.HandCardView:removeHandCards( clone(cards) )
        end
        cards = {
            CardValue, 0, 0, 0,
        }
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        UserInfoView:showTypeCards(cards, g_398.t_ti, CardValue, true)
        UserInfoView:showImgTxt( g_398.t_ti )
        SoundUtils:SoundCardType(g_398.t_ti, seat_id)
        self.TingView:updateTingData( )
    end
    local func2 = function (  )
        if not pack.packIdx then
            self:unfreezeEventAll()
        end
    end
    if pack.IsFirst == 0 then--不是起手提就放弃弃牌区 非起手提有一个假的摸牌效果
        if not pack.packIdx then
            self:freezeEventAll()
        end
        self.GameSceneView:setTimingFun( func1, 1.2 )
        self.GameSceneView:setTimingFun( func2, 1.5 )
    else
        func1()
    end
    
end

function ReceiveHandle:SVR_PLAYER_PAO_CARD(pack )--0x1205                         --玩家跑
    dump(pack, "0x1205                         --玩家跑")
    self.OprorateBtn:clearData()
    if not pack.packIdx then
        self:freezeEventAll()
    end
    local seat_id = pack.seat_id
    local CardValue = pack.CardValue
    g_398.curOutCard = nil
    g_398.curOutSeat = nil
    local func1 = function (  )
        self.GameSceneView:hideAllPlayerOutCard()
        local cards = {
            CardValue,
            CardValue,
            CardValue,
            CardValue,
        }
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        UserInfoView:showTypeCards(clone(cards), g_398.t_pao, CardValue, true)
        if seat_id == g_398.my_seat_id then
            self.HandCardView:removeHandCards( clone(cards) )
        end
        UserInfoView:showImgTxt( g_398.t_pao )
        SoundUtils:SoundCardType(g_398.t_pao, seat_id)
        self.TingView:updateTingData( )
    end
    local func2 = function (  )
        if not pack.packIdx then
            self:unfreezeEventAll()
        end
    end
    self.GameSceneView:setTimingFun( func1, 1.2 )
    self.GameSceneView:setTimingFun( func2, 1.5 )
end

function ReceiveHandle:SVR_PLAYER_HU_CARD( pack )--0x1208                        --玩家胡牌
    dump(pack, "0x1208                        --玩家胡牌")
    self.GameSceneView:isShowChuPai(false)
    -- self.GameSceneView:isShowTuoGuan( false )
    for i, userInfo in ipairs(pack.userArr) do
        local seat_id = userInfo.seat_id
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        UserInfoView:setScore(userInfo.m_chips)
        UserInfoView:setTotalScore(userInfo.m_totalBlc)
    end

    local huUserArr
    for i,v in ipairs(pack.huUserArr) do
        if v.uid == USER_INFO.uid then
            huUserArr = v
            break
        end
    end
    if not huUserArr then
        huUserArr = pack.huUserArr[1] or {}
    end
    if huUserArr.seat_id == g_398.my_seat_id then
        SoundUtils:SoundCardType("hu", huUserArr.seat_id)
    else
        -- SoundUtils:SoundCardType("huangzhuang", g_398.my_seat_id)
    end

    local actionName
    local huUserInfoView
    if huUserArr.seat_id then
        actionName = "zimo" 
        if pack.isZiMo == 0 and pack.nFangPaoSeat then
            actionName = "hu" 
        end
        huUserInfoView = self:getPlayerBySeatId( huUserArr.seat_id )
    end
    self.GameSceneView:setGameResult( pack, huUserInfoView, actionName  )
end

--最后的总结算0x5100
function ReceiveHandle:SVR_GROUP_BILLBOARD(pack)
    dump(pack, "最后的总结算0x5100")
end

--总结算 0x1209
function ReceiveHandle:G2H_BROADCAST_GROUP_RESULT(pack)
    dump(pack,"总结算 0x1209")
    g_398.m_isGameOver = true
    if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
	end
    if SCENENOW["scene"]:getChildByName("DisbandLayer_tips") then
        SCENENOW["scene"]:removeChildByName("DisbandLayer_tips")
	end
    if self.GameSceneView:getChildByName("GameResult") then
        g_398.settlementData = pack
        self.GameSceneView:getChildByName("GameResult"):endGame()
    else
        self.GameSceneView:settlement(pack)
    end
end

function ReceiveHandle:SVR_PLAYER_AI_STATE(pack)
    local seat_id = pack.seat_id
    if seat_id == g_398.my_seat_id then
        if pack.AIState == 1 then
            self.OprorateBtn:clearData()
            self.GameSceneView:isShowTuoGuan( true )
            g_398.isTuoGuan = true
        else
            self.GameSceneView:isShowTuoGuan( false )
            g_398.isTuoGuan = false
        end
    end
end

function ReceiveHandle:SVR_PLAYER_FAN_XIN(pack)
    dump(pack, "翻醒数据")
    g_398.fanData = pack
end

function ReceiveHandle:SVR_BEGIN_PIAO( pack )
    self.GameSceneView:clearData()
    self.Config:starGame()
    self.GameSceneView:starGame()
    self.GameSceneView:isShowBtnPiao( true, pack )
    g_398.piaoPoints = {}--seat_id:piao
end

function ReceiveHandle:SVR_SEND_PIAO( pack )
    local seat_id = pack.seat_id
    if seat_id == g_398.my_seat_id then
        self.GameSceneView:isShowBtnPiao( false )
    end
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    UserInfoView:isShowPiaoCount(true, pack.piaovalue)
    g_398.piaoPoints[seat_id] = pack.piaovalue
end

return ReceiveHandle
