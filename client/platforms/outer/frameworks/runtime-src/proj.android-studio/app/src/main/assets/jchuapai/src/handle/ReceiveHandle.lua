require("framework.init")
local hallHandle = require("hall.HallHandle")
local ReceiveHandle = class("ReceiveHandle", hallHandle)
local PROTOCOL = import("jchuapai.src.handle.Protocol")
local SendHandle = import("jchuapai.src.handle.SendHandle")
local SoundUtils = import("jchuapai.src.SoundUtils")
local eventName = "jchuapai"..os.now()

function ReceiveHandle:ctor(gameScene)
    self.gameScene = gameScene
    self.GameSceneView = gameScene.GameSceneView
    self.Config = gameScene.Config
    self.CardView = self.GameSceneView.CardView
    self.OprorateBtn = self.GameSceneView.OprorateBtn
    self.GAME_STATE = 0--游戏状态  0//停止游戏状态 1//请统状态  2//正在游戏状态 3 //等待下一场游戏开始状态
    ReceiveHandle.super.ctor(self);
	local func_ = {
        --登录房间返回
        [PROTOCOL.SVR_LOGIN_ROOM_OK] = {handler(self, ReceiveHandle.SVR_LOGIN_ROOM_OK), ""},
        --断线重连
        [PROTOCOL.SVR_RELOAD_ROOM] = {handler(self, ReceiveHandle.SVR_RELOAD_ROOM), ""},
        --0x1008   --自己退出房间
        [PROTOCOL.SVR_QUIT] = {handler(self, ReceiveHandle.SVR_QUIT), ""},
        --提示错误
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, ReceiveHandle.BROADCAST_ERROR_TIPS), ""},
        --登陆错误
        [PROTOCOL.SVR_ERROR] = {handler(self, ReceiveHandle.SVR_ERROR)},
        --进入房间
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, ReceiveHandle.SVR_LOGIN_ROOM_BROADCAST), ""},
        --房间局数相关
        [PROTOCOL.SVR_GROUP_TIME] = {handler(self, ReceiveHandle.SVR_GROUP_TIME), ""},
        --错误码提示
        [PROTOCOL.BROADCAST_ERROR_STATUS] = {handler(self, ReceiveHandle.BROADCAST_ERROR_STATUS), ""},
        --0x1005   --登陆房间失败提示
		[PROTOCOL.SVR_LOGIN_ROOM_FAIL] = {handler(self, ReceiveHandle.SVR_LOGIN_ROOM_FAIL)},
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
        -- 各个玩家的积分改变
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
        [PROTOCOL.SVR_PLAYER_TONG_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_TONG_CARD), ""},--用户统牌0x1203
        [PROTOCOL.SVR_PLAYER_PENG_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_PENG_CARD), ""},--0x1204             --用户碰牌
        [PROTOCOL.SVR_PLAYER_ZHAO_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_ZHAO_CARD), ""},--0x1205             --用户招牌
        [PROTOCOL.SVR_PLAYER_FAN_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_FAN_CARD), ""},--0x1206             --用户泛牌
        [PROTOCOL.SVR_PLAYER_CHU_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_CHU_CARD), ""},--0x1201                         --玩家出牌
        [PROTOCOL.SVR_PLAYER_HU_CARD] = {handler(self, ReceiveHandle.SVR_PLAYER_HU_CARD), ""},--0x1208                        --玩家胡牌
        [PROTOCOL.SVR_PLAYER_AI_STATE] = {handler(self, ReceiveHandle.SVR_PLAYER_AI_STATE), ""},----广播用户托管
    }
    table.merge(self.func_, func_)
    self:addHandleMgr()
end                   

function ReceiveHandle:callFunc(pack)
	dump(pack, 'receiveHandle')
    self:dispatchEvent({ name = eventName..pack.cmd, pack = pack})
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
    dump(pack)
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

function ReceiveHandle:BROADCAST_ERROR_STATUS(pack)
	dump(pack,"BROADCAST_ERROR_STATUS")
end

--进入房间失败 1005
function ReceiveHandle:SVR_LOGIN_ROOM_FAIL(pack)
    dump(pack, "-----进入房间失败-----")
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

--进入房间
function ReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)
	print("=====服务器广播用户登陆房间======")
    dump(pack,"SVR_LOGIN_ROOM_BROADCAST")
    local seat_id = pack.seat_id
    local uid = pack.uid

    if g_388.userInfos[uid] then--已添加
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        UserInfoView:isShowNewWork(false)
        return
    end
    local viewId = self.gameScene:getViewIdBySeatId(seat_id)
    self.Config:addUser( uid, seat_id, viewId, pack )
    if uid == USER_INFO.uid and seat_id >= 0 then
        g_388.my_seat_id = seat_id
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
    local viewId = g_388.viewIds[seatId] or 0 
    return self.GameSceneView["player_"..viewId]
end

--玩家坐下
function ReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
    print("=====有玩家进来了啦！！！====", pack.uid)
    local seat_id = pack.seat_id
    local uid = pack.uid
    if uid == USER_INFO.uid then
        g_388.my_seat_id = seat_id
    end
    local viewId = self.gameScene:getViewIdBySeatId(seat_id)
    self.Config:addUser( uid, seat_id, viewId, pack )
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    UserInfoView:show()
    UserInfoView:refreshPlayerInfo(pack.portrait,uid,pack.sex,pack.nickName, pack.ip, pack.addres)
    UserInfoView:setScore(pack.m_chips)
    if uid == USER_INFO.uid and self.playerlist then
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
    require(NetworkLoadingView_filePath):removeView(888)
    g_388.TOTAL_PLAYERNUM = pack.max_mount
    pack.RoomInfo = json.decode(pack.RoomInfo)
    g_388.gameConfig = pack.RoomInfo
    g_388.OwnerID = pack.OwnerID
    self.GameSceneView:showGameConfig(pack.RoomInfo)
    self.GameSceneView:setRoomId( pack.inviteCode )
    g_388.my_seat_id = pack.seat_id
    --将其他玩家的信息记录下来
    self.firstEnter = g_388.my_seat_id == -1 and USER_INFO.isWatch ~= 0--不是观战
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
    local seat_id = g_388.userInfos[uid].seat_id
    local userInfoView = self:getPlayerBySeatId(seat_id)
    if userInfoView then
        userInfoView:isShowReady(true)
    end
end

--发牌返回
function ReceiveHandle:SVR_DEAL(pack)
    dump(pack,"开始玩家发牌SVR_DEAL")
    self.GameSceneView:clearData()
    self.Config:oneGameEnd()

    self.GameSceneView:starGame()
    self.CardView:setCardsBack(g_388.backCount)  --初始化牌
    local seat_id = pack.seat_id
    if g_388.my_seat_id == seat_id then
        self.CardView:setCurHandCards(pack.HandCardDatas)  --初始化牌
    end
    self.banker_seat_id = pack.banker_seat_id
    local UserInfoView = self:getPlayerBySeatId(seat_id)
    UserInfoView:isShowZhuang(self.banker_seat_id == seat_id)
    local UserInfoView = self:getPlayerBySeatId(self.banker_seat_id)
    UserInfoView:isShowZhuang(true)
end

--玩家进行操作
function ReceiveHandle:SVR_PLAYER_OPRATION(pack)
    local isChu = 0
    local data = {
        isChu,
        pack.isDui,
        pack.isZhao,
        pack.isTong,
        pack.isFan,
        pack.isHu,
    }
    self.GameSceneView:isShowChuState( false )
    self.OprorateBtn:setData( data )
end

--轮到那个玩家进行出牌操作
function ReceiveHandle:SVR_PLAYER_OUT_CARD(pack)
    dump(pack, "====此玩家开始出牌====")
    local seat_id = pack.seat_id
    if not self.GameSceneView.hideAllPlayerLight then
        local isnull = tolua.isnull(self.GameSceneView)
        require(Request_filePath):upLoadAppMessage(1, "当前level：jchuapaiReceiveHandle:SVR_PLAYER_OUT_CARD(pack) "  .. "not self.GameSceneView.hideAllPlayerLight   tolua.isnull(self.GameSceneView) = "..isnull)
    end
    self.GameSceneView:hideAllPlayerLight()
    local UserInfoView = self:getPlayerBySeatId(seat_id)
    UserInfoView:isShowLight(true)
    print(seat_id == g_388.my_seat_id)
    if seat_id == g_388.my_seat_id then
        self.GameSceneView:isShowChuState(true)
    end
end

--补牌或者派发单张
function ReceiveHandle:SVR_BUPAI_DEAL(pack)
    local seat_id = pack.seat_id
    if seat_id == g_388.my_seat_id then
        self.CardView:addHandCard( pack.card_value )
    end
    self.CardView:isShowBackNodeCount( true, pack.diPaiCount )
end

--玩家断线重连 0x1009 1009
function ReceiveHandle:SVR_RELOAD_ROOM(pack)
    dump(pack, "==我断线重连了===pack")
    require(NetworkLoadingView_filePath):removeView(888)
    HEART_BEAT_TID = USER_INFO.tid--大厅用必要
    g_388.TOTAL_PLAYERNUM = pack.max_mount
    g_388.OwnerID = pack.OwnerID
    self.banker_seat_id = pack.banker_seat_id
    self.GAME_STATE = pack.GAME_STATE
    self.GameSceneView:clearData()
    pack.RoomInfo = json.decode(pack.RoomInfo)
    g_388.gameConfig = pack.RoomInfo
    self.GameSceneView:showGameConfig(pack.RoomInfo)
    self.GameSceneView:setRoomId( pack.inviteCode )
    self.GameSceneView:setRound( pack.round, pack.round_total )
    for k,v in pairs(pack.playerlist) do
        if v.uid == USER_INFO.uid then
            g_388.my_seat_id = v.seat_id
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
            UserInfoView:isShowNewWork(v.if_online == 0)
            UserInfoView:isShowZhuang(self.banker_seat_id == seat_id)
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
    elseif self.GAME_STATE == 2 then 
        local m_nCurGetCarCardSeatId = pack.m_nCurGetCarCardSeatId
        if m_nCurGetCarCardSeatId ~= -1 then
            local UserInfoView = self:getPlayerBySeatId( m_nCurGetCarCardSeatId )
            UserInfoView:isShowLight(true)
            if m_nCurGetCarCardSeatId == g_388.my_seat_id then
                self.GameSceneView:isShowChuState(true)
            end
        end
        --显示上一个出牌
        if pack.m_CurOutCard > 0 then
            g_388.curOutCard = pack.m_CurOutCard
            g_388.curOutSeat = pack.out_seat_id
            local UserInfoView = self:getPlayerBySeatId( pack.out_seat_id )
            UserInfoView:isShowOutCard( true, pack.m_CurOutCard )
        end
    end


    for k,v in pairs(pack.playerlist) do
        local seat_id = v.seat_id
        if seat_id ~= -1 then
            if seat_id == g_388.my_seat_id then
                if v.AIState == 1 then
                    self.GameSceneView:isShowTuoGuan( true )
                    g_388.isTuoGuan = true
                end

            end
        end
    end

    --轮到谁出牌
    self.CardView:setCardsBack(pack.diPaiCount + #pack.HandCardDatas)  --初始化牌
    self.CardView:setCurHandCards(pack.HandCardDatas)  --初始化牌
    self.CardView:isShowBackNodeCount( true, pack.diPaiCount )
    --初始化玩家出的牌 
    for k, v in ipairs(pack.outCards) do
        local UserInfoView = self:getPlayerBySeatId( v.seat_id )
        if g_388.curOutSeat == v.seat_id then--要少一张因为要显示一张出来
            table.splice(v.cards, #v.cards, 1)
        end
        for idx, card in ipairs(v.cards) do
            UserInfoView:showOutCard(card, idx)
        end
    end

    for k, value in ipairs(pack.CardData) do
        local UserInfoView = self:getPlayerBySeatId( value.seat_id )
        UserInfoView:isShowHuCountd(true, 0)
        UserInfoView:isShowTongCountd(true, value.tong_count)
        self:handCards( UserInfoView, "dui", value.pengList, 3 )
        self:handCards( UserInfoView, "zhao", value.zhaoList, 4 )
        self:handCards( UserInfoView, "fan", value.fanList, 5 )
    end
end

function ReceiveHandle:handCards( UserInfoView, _type, cards, num )
    while true do
        local newCards = table.splice(cards, 1, num)
        if #newCards == num then
            UserInfoView:showTypeCards(newCards, _type)
        else
            break
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
        for i, v in pairs( g_388.userInfos or {} ) do
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
    for i, v in pairs( g_388.userInfos or {} ) do
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
    if g_388.m_isGameOver then return end
    local uid = pack.uid
    if  uid == USER_INFO.uid then 
        if self.settlementData then
            self.GameSceneView:settlement(self.settlementData)
        else
            require("hall.GameCommon"):gExitGroupGame(USER_INFO.enter_mode, CLUB_ID)
        end
    else
        local seat_id = g_388.userInfos[uid].seat_id
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
        local seat_id = g_388.userInfos[uid].seat_id
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
        from_seatId = g_388.my_seat_id
    else
        from_seatId = g_388.userInfos[from_id].seat_id
    end
    local to_seatId = 0
    if to_uid == USER_INFO.uid then
        to_seatId = g_388.my_seat_id
    else
        local otherInfo = g_388.userInfos[to_uid] or {}
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
        seatId = g_388.my_seat_id
    else
        sex = g_388.userInfos[uid].sex
        seatId = g_388.userInfos[uid].seat_id
    end
    local userInfoView = self:getPlayerBySeatId(seatId)
    local isLeft = true
    if userInfoView:getName() == "player_2" then
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
    local userInfo = g_388.userInfos[uid]
    if not (userInfo) then return end
    local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
    UserInfoView:isShowNewWork(true) 
end

--接收服务器放回的指定用户信息pack111
function ReceiveHandle:SVR_CHARGE_BROADCAST(pack)
    dump(pack,"pack111")
    local uid = pack.uid
    local userInfo = g_388.userInfos[uid]
    if not (userInfo) then return end
    userInfo.m_chips = userInfo.m_chips + pack.chargeCoins

    local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
    UserInfoView:setScore(userInfo.m_chips)
end

--接收服务器放回的指定用户信息pack111
function ReceiveHandle:SVR_CHIP_CHANGE_BROADCAST(pack)
    dump(pack,"pack111")
    for _,data in pairs(pack.userinfo) do
        local uid = data.uid
        local userInfo = g_388.userInfos[uid]
        if not (userInfo) then return end
        userInfo.m_chips = userInfo.m_chips + data.chargeCoins
        local UserInfoView = self:getPlayerBySeatId( userInfo.seat_id )
        if UserInfoView then
            UserInfoView:setScore(userInfo.m_chips)
        end
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

--玩家出牌0x1201                         --玩家出牌
function ReceiveHandle:SVR_PLAYER_CHU_CARD(pack)
    dump(pack, "0x1201                         --玩家出牌")
    local seat_id = pack.seat_id
    local CardValue = pack.CardValue
    if seat_id == g_388.my_seat_id then
        if g_388.curClickCardNode and g_388.curClickCardNode._card == CardValue then
            self.CardView:removeCardNode( g_388.curClickCardNode )
            g_388.curClickCardNode = nil
        else
            self.CardView:removeHandCards( {CardValue} )
        end 
    end
    self.GameSceneView:hideAllPlayerOutCard()
    local perOutCard = g_388.curOutCard
    local perOutSeat = g_388.curOutSeat
    g_388.curOutCard = CardValue
    g_388.curOutSeat = seat_id
    self.GameSceneView:isShowChuState(false)
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    UserInfoView:isShowOutCard(true, CardValue)
    SoundUtils:SoundCard(CardValue, seat_id)

    if perOutSeat and perOutCard then
        local UserInfoView = self:getPlayerBySeatId( perOutSeat )
        UserInfoView:showOutCard(perOutCard)
    end
end

function ReceiveHandle:SVR_PLAYER_TONG_CARD(pack )--0x1203             --用户统牌
    dump(pack, "0x1203             --用户统牌")
    local UserInfoView = self:getPlayerBySeatId( pack.seat_id )
    UserInfoView:isShowTongCountd(true, pack.tong_count)
    UserInfoView:showImgTxt("tong")
    SoundUtils:SoundCard("tong", pack.seat_id)

end

function ReceiveHandle:SVR_PLAYER_PENG_CARD(pack )--0x1204             --用户碰牌
    dump(pack, "0x1204             --用户碰牌")
    self.GameSceneView:hideAllPlayerOutCard()
    local seat_id = pack.seat_id
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    UserInfoView:showTypeCards(pack.cards)
    UserInfoView:showImgTxt("dui")
    if seat_id == g_388.my_seat_id then
        self.CardView:removeHandCards( clone(pack.cards), g_388.curOutCard )
    end
    g_388.curOutCard = nil
    g_388.curOutSeat = nil
    SoundUtils:SoundCard("dui", seat_id)
end

function ReceiveHandle:SVR_PLAYER_ZHAO_CARD(pack )--0x1205             --用户招牌
    dump(pack, "0x1205             --用户招牌")
    self.GameSceneView:hideAllPlayerOutCard()
    local seat_id = pack.seat_id
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    UserInfoView:showTypeCards(pack.cards, "zhao")
    UserInfoView:showImgTxt("zhao")
    if seat_id == g_388.my_seat_id then
        self.CardView:removeHandCards( clone(pack.cards), g_388.curOutCard )
    end
    g_388.curOutCard = nil
    g_388.curOutSeat = nil
    SoundUtils:SoundCard("zhao", seat_id)
end

function ReceiveHandle:SVR_PLAYER_FAN_CARD( pack )--0x1206             --用户泛牌
    dump(pack, "0x1206             --用户泛牌")
    self.GameSceneView:hideAllPlayerOutCard()
    local seat_id = pack.seat_id
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    UserInfoView:showTypeCards(pack.cards, "fan")
    UserInfoView:showImgTxt("fan")
    if seat_id == g_388.my_seat_id then
        self.CardView:removeHandCards( clone(pack.cards), g_388.curOutCard )
    end
    g_388.curOutCard = nil
    g_388.curOutSeat = nil
    UserInfoView:isShowTongCountd(true, pack.tong_count)
    SoundUtils:SoundCard("fan", seat_id)
end

function ReceiveHandle:SVR_PLAYER_HU_CARD( pack )--0x1208                        --玩家胡牌
    dump(pack, "0x1208                        --玩家胡牌")
    self.GameSceneView:setGameResult( pack )
    self.GameSceneView:isShowBtnReady( true )
    self.GameSceneView:isShowTuoGuan( false )
    for i, userInfo in ipairs(pack.userArr) do
        local seat_id = userInfo.seat_id
        local UserInfoView = self:getPlayerBySeatId( seat_id )
        UserInfoView:setScore(userInfo.m_chips)
    end
    local huUserInfo = pack.huUserArr[1]
    if huUserInfo then
        SoundUtils:SoundCard("hu", huUserInfo.seat_id)
    end
end

--最后的总结算0x5100
function ReceiveHandle:SVR_GROUP_BILLBOARD(pack)
    dump(pack, "最后的总结算0x5100")
end

--总结算 0x1209
function ReceiveHandle:G2H_BROADCAST_GROUP_RESULT(pack)
    dump(pack,"总结算 0x1209")
    if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
	end
    if SCENENOW["scene"]:getChildByName("DisbandLayer_tips") then
        SCENENOW["scene"]:removeChildByName("DisbandLayer_tips")
	end
    
    g_388.m_isGameOver = true
    self.settlementData = pack
    self.GameSceneView:settlement(pack)
end

function ReceiveHandle:SVR_PLAYER_AI_STATE(pack)
    local seat_id = pack.seat_id
    if seat_id == g_388.my_seat_id then
        if pack.AIState == 1 then
            self.GameSceneView:isShowTuoGuan( true )
            self.OprorateBtn:clearData()
            g_388.isTuoGuan = true
        else
            self.GameSceneView:isShowTuoGuan( false )
            g_388.isTuoGuan = false
        end
    end
end

return ReceiveHandle
