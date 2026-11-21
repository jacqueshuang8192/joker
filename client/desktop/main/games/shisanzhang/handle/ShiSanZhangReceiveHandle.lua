require("framework.init")
local hallHandle = require("hall.HallHandle")
local PROTOCOL        = import(TpackageName..".handle.ShiSanZhangProtocol")
local ShiSanZhangReceiveHandle   = class("ShiSanZhangReceiveHandle",hallHandle)
local ShiSanZhangConfig = require(TpackageName..".config.ShiSanZhangConfig")

function ShiSanZhangReceiveHandle:ctor()
    ShiSanZhangReceiveHandle.super.ctor(self);
    local func_ = {
        --[PROTOCOL.SVR_LOGIN_GAME] = {handler(self, ShiSanZhangReceiveHandle.SVR_LOGIN_GAME)},  --210
        --[PROTOCOL.SVR_GET_ROOM_OK]          = {handler(self, ShiSanZhangReceiveHandle.SVR_GET_ROOM_OK)},
        [PROTOCOL.SVR_LOGIN_ROOM]           = {handler(self, ShiSanZhangReceiveHandle.SVR_LOGIN_ROOM)},--登录房间成功
        [PROTOCOL.SVR_READY]                = {handler(self, ShiSanZhangReceiveHandle.SVR_READY)},  ---广播用户准备
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, ShiSanZhangReceiveHandle.SVR_LOGIN_ROOM_BROADCAST)},--
        [PROTOCOL.SVR_QUIT_ROOM]            = {handler(self, ShiSanZhangReceiveHandle.SVR_QUIT_ROOM)}, -- 用户离场
        [PROTOCOL.SVR_BASE_BROADCAST]       = {handler(self, ShiSanZhangReceiveHandle.SVR_BASE_BROADCAST)},  ---广播台费
        [PROTOCOL.SVR_SEND_CARD]            = {handler(self, ShiSanZhangReceiveHandle.SVR_SEND_CARD)},   --- 发牌
        [PROTOCOL.SVR_START_BROADCAST]      = {handler(self, ShiSanZhangReceiveHandle.SVR_START_BROADCAST)},  ---广播开始游戏
        [PROTOCOL.SVR_QUIT]                 = {handler(self, ShiSanZhangReceiveHandle.SVR_QUIT)},    ---自己退出
        [PROTOCOL.SVR_DIU_BROADCAST]        = {handler(self, ShiSanZhangReceiveHandle.SVR_DIU_BROADCAST)},  --玩家弃牌
        [PROTOCOL.SVR_KAN_CARD]             = {handler(self, ShiSanZhangReceiveHandle.SVR_KAN_CARD)},
        [PROTOCOL.SVR_GEN_BROADCAST]        = {handler(self, ShiSanZhangReceiveHandle.SVR_GEN_BROADCAST)},
        [PROTOCOL.SVR_JIA_BROADCAST]        = {handler(self, ShiSanZhangReceiveHandle.SVR_JIA_BROADCAST)},
        [PROTOCOL.SVR_BI_BROADCAST]         = {handler(self, ShiSanZhangReceiveHandle.SVR_BI_BROADCAST)},
        [PROTOCOL.SVR_END]                  = {handler(self, ShiSanZhangReceiveHandle.SVR_END)},
        [PROTOCOL.SVR_ALL_COMPARE]          = {handler(self, ShiSanZhangReceiveHandle.SVR_ALL_COMPARE)},
        [PROTOCOL.SVR_ALLIN_BROADCAST]      = {handler(self, ShiSanZhangReceiveHandle.SVR_ALLIN_BROADCAST)},
        [PROTOCOL.SVR_PLAY_GAME]      = {handler(self, ShiSanZhangReceiveHandle.SVR_PLAY_GAME)},

        [PROTOCOL.SVR_ERROR]      = {handler(self, ShiSanZhangReceiveHandle.SVR_ERROR)},
        [PROTOCOL.SERVER_BROADCAST_OUT_CARD]      = {handler(self, ShiSanZhangReceiveHandle.SERVER_BROADCAST_OUT_CARD)},

        [PROTOCOL.BROADCAST_CAN_START_GAME]      = {handler(self, ShiSanZhangReceiveHandle.BROADCAST_CAN_START_GAME)},   --广播开始游戏按钮

        [PROTOCOL.SVR_CHARGE_BROADCAST]      = {handler(self, ShiSanZhangReceiveHandle.SVR_CHARGE_BROADCAST)},  -- 跟新玩家金币

        -- 6029玩家可以看牌了
        [PROTOCOL.SVR_KAN_SHOW]      = {handler(self, ShiSanZhangReceiveHandle.SVR_KAN_SHOW)},
        --4008 广播玩家钱数变化（用于扣取台费）
        [PROTOCOL.SVR_CHIP_CHANGE_BROADCAST]       = {handler(self, ShiSanZhangReceiveHandle.SVR_CHIP_CHANGE_BROADCAST)},
        --广播其他用户坐下（金币场） 1031
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, ShiSanZhangReceiveHandle.BROADCAST_USER_SIT_DOWN)},
        --广播用户站起 1032
        [PROTOCOL.BROADCAST_USER_STAND_UP] = {handler(self, ShiSanZhangReceiveHandle.BROADCAST_USER_STAND_UP)},
        --广播用户退出房间 1033
        [PROTOCOL.BROADCAST_USER_QUIT_ROOM] = {handler(self, ShiSanZhangReceiveHandle.BROADCAST_USER_QUIT_ROOM)},
        --广播剩余时间100F广播切牌
        [PROTOCOL.SVR_BROADCAST_COUNT_DOWN]           = {handler(self, ShiSanZhangReceiveHandle.SVR_BROADCAST_COUNT_DOWN)},
        --错误提示5001
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, ShiSanZhangReceiveHandle.BROADCAST_ERROR_TIPS)},

       [PROTOCOL.SVR_MSG_FACE]={handler(self, ShiSanZhangReceiveHandle.SVR_MSG_FACE)},
        [PROTOCOL.SVR_GROUP_RANKING] = {handler(self, ShiSanZhangReceiveHandle.SVR_GROUP_RANKING)},
        [PROTOCOL.SVR_GROUP_TIME] = {handler(self, ShiSanZhangReceiveHandle.SVR_GROUP_TIME)},
        --没有此房间，解散房间失败
        [PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, ShiSanZhangReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},
        --广播桌子用户请求解散组局
        [PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, ShiSanZhangReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
        --广播当前组局解散情况
        [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, ShiSanZhangReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
        --广播桌子用户成功解散组局
        [PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, ShiSanZhangReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
        --广播桌子用户解散组局 ，解散组局失败
        [PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, ShiSanZhangReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},
        --广播桌子用户ip
        [PROTOCOL.BROADCAST_USER_IP]     = {handler(self, ShiSanZhangReceiveHandle.BROADCAST_USER_IP)},
        --接收服务器返回的缓存信息
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, ShiSanZhangReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, ShiSanZhangReceiveHandle.SERVER_CMD_MESSAGE)},
        [PROTOCOL.SVR_GET_SURP_CARDS] = {handler(self, ShiSanZhangReceiveHandle.SVR_GET_SURP_CARDS)},

        [PROTOCOL.SERVER_BROADCAST_START_GAME] = {handler(self,ShiSanZhangReceiveHandle.SERVER_BROADCAST_START_GAME)},
        
    }
    table.merge(self.func_, func_)
end


--
function ShiSanZhangReceiveHandle:callFunc(pack)
    local desc = ""
    if pack.cmd and PROTOCOL.DESC[pack.cmd] then
        desc = PROTOCOL.DESC[pack.cmd].."------------------------"
    end
    dump(pack, desc)
    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

--function ShiSanZhangReceiveHandle:SVR_LOGIN_GAME(pack)
--    dump(pack,"十三水SVR_LOGIN_GAME---")
--    STATUS_GAME = true
--    USER_INFO["tid"] = pack.Tid
--    USER_INFO["activity_id"] = tonumber(pack.activityId or USER_INFO["activity_id"])
--    USER_INFO["player_nums"] = pack.player_nums
--    USER_INFO["Res"] = pack.Res
--    USER_INFO["isWatch"] = pack.isWatch
--    USER_INFO["roomPassword"] = pack.roomPassword   --密码房的房间密码
--
--    ShiSanZhangSendHandle:enterRoom()
--end

--0x6004    --服务器广播开始打牌
function ShiSanZhangReceiveHandle:SVR_PLAY_GAME(pack)
    SHISANZHANG_GAME_SCENE:performWithDelay(function(  )
        local MatchCardView = SCENENOW["scene"]:getChildByName("MatchCardView")
        if MatchCardView then
            MatchCardView:showCardCountDown(pack.timeout)
        end
    end, 1)
    dump("--0x6004    --服务器广播开始打牌")
    if pack.mapai then
        MA_CARD = pack.mapai--马牌
    end
    -- GamePlaneOperator:showTimes(pack.timeout)
    --if pack.timeout > 0 then
    --    GamePlaneOperator:resetAllTipStatus(false)
    --    GamePlaneOperator:claerHandCardPlane()
    --end
end
function ShiSanZhangReceiveHandle:SERVER_CMD_FORWARD_MESSAGE(pack)

    dump(pack, "-----NiuniuroomHandle 接收服务器返回的缓存信息-----")

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


function ShiSanZhangReceiveHandle:showExpression(msg)
    dump(msg,"ggewgewgweg")
    local uid_from = tonumber(msg["uid_from"]) or 1
    local uid_to = tonumber(msg["uid_to"]) or 1
    local expressionType = tonumber(msg["expressionType"]) or 1

    ---------------------------------不同游戏需修改的部分----------------------------
    -- --通过UID获取seat
    -- local seat_from = USERID2SEAT[uid_from] or 2
    -- local seat_to =  USERID2SEAT[seat_to] or 0

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
-----------------------------------------------------------------------------------------------------------------------------
function ShiSanZhangReceiveHandle:showTextMessage(pack)

    local s= SCENENOW["scene"]:getChildByName("faceUI")

    local sex = 1

    if SHISANZHANG_USERINFO_TABLE[pack.uid] then
        sex = SHISANZHANG_USERINFO_TABLE[pack.uid].sex or 0
    end

    local node_head = PLAYER_HEADS_TABLE[pack.uid]

    s:showGetText(pack.uid,pack.textMessage,tonumber(sex),node_head, false)
end
--接收服务器返回的组局信息
function ShiSanZhangReceiveHandle:SERVER_CMD_MESSAGE(pack)
    if bm.isInGame == false then
        return
    end

    local msg = json.decode(pack.msg)
    dump(msg, "-----SERVER_CMD_MESSAGE 表情-----")
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
                emojiPack["type"] = msg.id
                self:SVR_MSG_FACE(emojiPack)
            end

            if device.platform == "ios" then

                if msgType == "voice" then
                    dump("voice", "-----接收服务器返回的组局信息-----")

                    require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

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

                    require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

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

function ShiSanZhangReceiveHandle:forTestComp(cards)
    if SCENENOW["scene"]:getChildByName("CheatCardLayer") == nil then
        local cheatLayer = require(TpackageName .. ".view.CheatCardLayer").new(cards)
        cheatLayer:setZOrder(68)
        cheatLayer:setName("CheatCardLayer")
        SCENENOW["scene"]:addChild(cheatLayer)
    end
end

--登录房间成功-----SHISANZHANG录房间 1007-----
function ShiSanZhangReceiveHandle:SVR_LOGIN_ROOM( pack )
    require(NetworkLoadingView_filePath):removeView(888)
    SCENENOW["scene"]:initData()
    USER_INFO["invote_code"] = pack.invote_code
    dump(pack, "-----SHISANZHANG录房间 1007-----")
    local gameConfig = json.decode(pack.gameConfig)
    local accountScene = SCENENOW["scene"]:getChildByName("accountScene")
    if not tolua.isnull(accountScene) then
        accountScene:removeSelf()
    end
    require("hall.settlement.settlement"):removeScene()
    if pack.mapai then
        MA_CARD = pack.mapai--马牌
    end
    if gameConfig.SoftOrHard == 0 then
        g_guiNumber = gameConfig.joker or 0 --配置选项里面的选了几个王
    end
    dump(USER_INFO["club_id"],"USER_INFOuuu")
    if pack.club_id > 0 then
        CLUB_ID = pack.club_id
        USER_INFO["family_id"] = pack.club_id
    end

    GAME_STATE    =  pack.status
    BASE_CHIP    =  pack.base
    local baseChip = pack.base
    local gameConfig_string = USER_INFO["gameConfig"] or ""
    initialChip = pack.initialChip
    isGoldGame =  pack.isGoldGame
    dump(USER_INFO ,"userin")
    SCENENOW["scene"]:showRoomCode(pack.invote_code)
    HEART_BEAT_TID = USER_INFO["tid"]
    GamePlaneOperator:init()  --TOTAL_PLAYERNUM
    local myUserInfo = {}
    myUserInfo.uid = pack.uid
    myUserInfo.nickName = pack.nickName
    myUserInfo.icon_url = pack.icon_url
    myUserInfo.sex = pack.sex
    myUserInfo.if_ready = pack.if_ready
    myUserInfo.m_chips = pack.m_chips
    myUserInfo.latitude = pack.latitude
    myUserInfo.longitude = pack.longitude
    myUserInfo.seat = pack.seat
    SHISANZHANG_USERINFO_TABLE[pack.uid] = myUserInfo
    ShiSanZhangUtils:collectPlayerData(myUserInfo)

    if pack.if_ready <= 0 and pack.status == 0 then
        SCENENOW["scene"]:showReady(true)
    else
        SCENENOW["scene"]:showReady(false)
    end
    GamePlaneOperator:claerAllPlane()
    if pack.status == 0 then
        SHISANZHANG_GAME_STATE = GAME_STATUS_STOP
        if pack.m_GroupTimes == 0 then
            SCENENOW["scene"]:showInviteWxBtn(true)
        end
        for k,userInfo in pairs(pack.nostart[1].userInfo) do
            dump(userInfo, "vv--userInfo")
            ShiSanZhangUtils:collectPlayerData(userInfo)
            ShiSanZhangUtils:showPlayer(userInfo.uid, userInfo.seat, userInfo)
        end
    else
       
        MY_HAND_CARDS = allCards
        MY_HAND_CARDS_TEMP = allCards
        SHISANZHANG_GAME_STATE = GAME_STATUS_START
        SCENENOW["scene"]:showInviteWxBtn(false)
        local allCards = pack.start[1].hand_card
        for k,userInfo in pairs(pack.start[1].userInfo) do
            local seat = userInfo.seat
            ShiSanZhangUtils:collectPlayerData(userInfo)
            ShiSanZhangUtils:showPlayer(userInfo.uid, userInfo.seat, userInfo)
            SHISANZHANG_USERINFO_TABLE[userInfo.uid].m_isOpenCard = userInfo.m_isOpenCard

            local seat = userInfo.seat
            local func = function(  )
                GamePlaneOperator:operationCardZhong(SHISANZHANG_PLAYERTYPE_TABLE[userInfo.uid], true)
            end
            if seat >= 0 then
                if userInfo.uid == USER_INFO["uid"] then
                    func = function(  )
                        if userInfo.m_isOpenCard and #allCards == 13 then
                            GamePlaneOperator:showCards(pack.start[1].cardSpcardtype, allCards)
                            -- self:SVR_PLAY_GAME(pack)
                        end
                        GamePlaneOperator:operationCardZhong(SHISANZHANG_PLAYERTYPE_TABLE[userInfo.uid], true)
                    end
                    userInfo.cards = pack.start[1].cards
                end
                if userInfo.m_isOpenCard == 0 then
                    GamePlaneOperator:showCardsBack(func, SHISANZHANG_PLAYERTYPE_TABLE[userInfo.uid])
                else
                    -- GamePlaneOperator:showCardsBack()

                    ShiSanZhangReceiveHandle:SERVER_BROADCAST_OUT_CARD(userInfo)
                end
            end

        end
        
        -- if pack.start[1].m_isOpenCard == 0 then
        --     GamePlaneOperator:setCardType()
        -- end
        MY_BEST_CARDS[1] = pack.start[1].fanscard1
        MY_BEST_CARDS[2] = pack.start[1].fanscard2
        MY_BEST_CARDS[3] = pack.start[1].fanscard3
        -- local allCards = pack.start[1].hand_card
       
        -- dump(pack.start[1].m_isOpenCard, "pack.start[1].m_isOpenCard")
        -- if pack.start[1].m_isOpenCard then
        --     dump(pack.start[1].openCard, "pack.start[1].openCard")
        -- end
    end
    self:SERVER_BROADCAST_START_GAME({["star_game_uid"] = pack.star_game_uid})
    
end


--广播用户坐下 1031   其他用户进入房间
function  ShiSanZhangReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)

    local userInfo = {}
    userInfo = SHISANZHANG_USERINFO_TABLE[pack.uid]
    userInfo.uid = pack.uid
    userInfo.nickName = pack.nickName
    userInfo.icon_url = pack.icon_url
    userInfo.sex = pack.sex or 0
    userInfo.m_chips = pack.m_chips
    userInfo.seat = pack.seat
    ShiSanZhangUtils:collectPlayerData(userInfo)
    if userInfo.uid == USER_INFO["uid"] then
        MY_SEAT_ID = userInfo.seat
        if SHISANZHANG_GAME_STATE == GAME_STATUS_STOP then
            ShiSanZhangUtils:relocatePlayer()
        end
        if SHISANZHANG_GAME_STATE == GAME_STATUS_START then
            ShiSanZhangUtils:relocatePlayer()
--                ShiSanZhangUtils:relocatePlayer()
        end


    else
        ShiSanZhangUtils:showPlayer(userInfo.uid, userInfo.seat, userInfo)
    end



end

--广播玩家站起 1032
function ShiSanZhangReceiveHandle:BROADCAST_USER_STAND_UP(pack)

    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(pack.uid,{},"reset")
end

function ShiSanZhangReceiveHandle:BROADCAST_CAN_START_GAME()
    dump("---------------------广播开始游戏6030----------------------------")

end

--广播玩家退出返回（离开房间） 1033
function ShiSanZhangReceiveHandle:BROADCAST_USER_QUIT_ROOM(pack)
    dump(pack,"--广播玩家退出返回（离开房间） 1033")
    if GAME_IS_OVER == true then--已经解散房间不需要下面的操作
        return
    end
    local uid = pack.uid
    local seat = SHISANZHANG_USERINFO_TABLE[uid].seat

    local playerType =  SHISANZHANG_PLAYERTYPE_TABLE[uid]
    if  playerType then
        GamePlaneOperator:removePlayer(playerType)
        GamePlaneOperator:showHeadSymbol(playerType,"disconnect",false)
    end

    SHISANZHANG_UID_TABLE[seat] = nil
    SHISANZHANG_USERINFO_TABLE[uid] = nil
    SHISANZHANG_PLAYERTYPE_TABLE[uid] = nil
    SHISANZHANG_SEAT_TABLE_MAPPING[uid] = nil
    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,{},"reset")
    if uid == USER_INFO["uid"] then
        if GAME_IS_OVER == false then
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
        end
    end
    
    -- PLAYERNUM = ShiSanZhangUtils:getPlayerNum()  --先刷新全局人数
end

--结算协议 0x6026 
function ShiSanZhangReceiveHandle:SVR_END(pack)

    if ShiSanZhangConfig:getVersion() and not pack.isAction then
        pack.isAction = true
        local callBack = function( )
            ShiSanZhangReceiveHandle:SVR_END(pack)
        end
        GamePlaneOperator:setAnim("kaishibipai", callBack)
        return
    end

    dump(pack, "结算协议 0x6026 ------------------------")
    local MatchCardView = SCENENOW["scene"]:getChildByName("MatchCardView")
    if MatchCardView then
        MatchCardView:removeFromParent()
    end
    local userInfos = pack.userinfos
    SoundUtils:playCardKindEffect("开始比牌", USER_INFO.sex)

    local flag = false
    local bfTime = 0--比分需要的时间
    local dqTime = 2.2 --打枪需要的时间
    local qldTime = 0 --全垒打需要的时间
    local totalDq = 0
    local isqld = false --全垒打
    local num_1 = 0 --普通人次
    local num_2 = 0 --特殊牌人次
    for _,userInfo in ipairs(userInfos) do
        dump(userInfo.dqMap)

        GamePlaneOperator:outCards(SHISANZHANG_PLAYERTYPE_TABLE[userInfo.uid], nil, flag)
        totalDq = totalDq + userInfo.dqSize
        if userInfo.isSwat == 1 then
            qldTime = 1.7
            isqld = true
        end
        if userInfo.cardSpcardOutType > 1 then
            num_2 = num_2 + 1
        else
            num_1 = num_1 + 1
        end
    end
    bfTime = num_1 * 3.4
    if bfTime == 0 then
        bfTime = bfTime + num_2 * 1.2
    else
        bfTime = bfTime + num_2 * 1.2
    end
    dqTime = dqTime * totalDq + bfTime--打枪需要的时间
    qldTime = qldTime + dqTime --全垒打需要的时间 

    GamePlaneOperator:compCards(userInfos) --比牌

    SHISANZHANG_GAME_SCENE:performWithDelay(function() --打枪
        dump(bfTime,"-----打枪时间---------")
        GamePlaneOperator:setShotData(userInfos)
    end,bfTime)
    SHISANZHANG_GAME_SCENE:performWithDelay(function() --全垒打
        GamePlaneOperator:showCoinFlyAnimation(userInfos)
        for _,userInfo in ipairs(userInfos) do
            local user = SHISANZHANG_USERINFO_TABLE[userInfo.uid]
            user.m_chips = userInfo.m_chips
            ShiSanZhangUtils:collectPlayerData(user)
            local playerType = SHISANZHANG_PLAYERTYPE_TABLE[userInfo.uid]
            local time = 0.3

            if isqld then
                GamePlaneOperator:setPlayerScore(playerType, userInfo.turngold)
                time = 2
            end
            SHISANZHANG_GAME_SCENE:performWithDelay(function() --总分
                GamePlaneOperator:updateCoin(playerType, userInfo.turngold)
                GamePlaneOperator:setCoin(playerType, userInfo.m_chips)
            end,time)

        end
        SCENENOW["scene"]:showReady(true)
    end,qldTime)
    JIESUAN_TIME = qldTime+2 --总结算时间
    -- SHISANZHANG_GAME_SCENE
end

--广播全桌比牌
function ShiSanZhangReceiveHandle:SVR_ALL_COMPARE( pack )

end

--广播比牌结果
function ShiSanZhangReceiveHandle:SVR_BI_BROADCAST( pack )

end

--广播玩家加注
function ShiSanZhangReceiveHandle:SVR_JIA_BROADCAST(pack)

end

--广播玩家allin
function ShiSanZhangReceiveHandle:SVR_ALLIN_BROADCAST(pack)

end


--玩家看牌
function ShiSanZhangReceiveHandle:SVR_KAN_CARD(pack)

end


--玩家跟注
function ShiSanZhangReceiveHandle:SVR_GEN_BROADCAST(pack)

end


--玩家弃牌
function ShiSanZhangReceiveHandle:SVR_DIU_BROADCAST( pack )

end

--用户准备
function ShiSanZhangReceiveHandle:SVR_READY(pack)
    dump(pack, "SVR_READY")
    dump(SHISANZHANG_PLAYERTYPE_TABLE[pack.uid], "SVR_READY-SHISANZHANG_PLAYERTYPE_TABLE[pack.uid]")
    GamePlaneOperator:showHeadSymbol(SHISANZHANG_PLAYERTYPE_TABLE[pack.uid],"room_rd",true)
    if pack.uid == USER_INFO["uid"] then
        SCENENOW["scene"]:showReady(false)
    end

end


--用户入场 100d
function ShiSanZhangReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)
    local userInfo = {}
    userInfo.uid = pack.uid
    userInfo.nickName = pack.nickName
    userInfo.icon_url = pack.icon_url
    userInfo.sex = pack.sex
    userInfo.if_ready = pack.if_ready
    userInfo.m_chips = pack.m_chips
    userInfo.latitude = pack.latitude
    userInfo.longitude = pack.longitude
    userInfo.seat = pack.seat
    SHISANZHANG_USERINFO_TABLE[pack.uid] = userInfo
    ShiSanZhangUtils:collectPlayerData(userInfo)
    if pack.seat>=0 then
        ShiSanZhangUtils:showPlayer(pack.uid, pack.seat, userInfo)
    end
end

--获取当前坐下的玩家数量
function ShiSanZhangReceiveHandle:getPlayerNum()

end

--用户离场
function ShiSanZhangReceiveHandle:SVR_QUIT_ROOM(pack)

end

--自己离场
function ShiSanZhangReceiveHandle:SVR_QUIT(pack)
    --SCENENOW["scene"]:reConnect()
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end

--广播台费
function ShiSanZhangReceiveHandle:SVR_BASE_BROADCAST(pack)

end

--发牌  4001
function ShiSanZhangReceiveHandle:SVR_SEND_CARD(pack)
    GamePlaneOperator:clearGameDatas()
    GamePlaneOperator:claerAllPlane()
    GamePlaneOperator:RemaidStartGame(false)
    dump(pack,"---发牌  4001--------------")
    GamePlaneOperator:resetAllTipStatus(true)
    SCENENOW["scene"]:showInviteWxBtn(false)
    -- for k,uid in ipairs(pack.users) do
    --     GamePlaneOperator:showHeadSymbol(SHISANZHANG_PLAYERTYPE_TABLE[uid],"room_rd",false)
    -- end

    JIESUAN_TIME = 1
    local allCards = pack.cards
    for k,uid in ipairs(pack.users) do
        GamePlaneOperator:showHeadSymbol(SHISANZHANG_PLAYERTYPE_TABLE[uid],"room_rd",false)
        local func = function()
            GamePlaneOperator:showCards(pack.cardSpcardtype, allCards)
            GamePlaneOperator:operationCardZhong(SHISANZHANG_PLAYERTYPE_TABLE[USER_INFO["uid"]], true)
        end
        if USER_INFO["uid"] ~= uid then
            func = nil
        end
        GamePlaneOperator:showCardsBack(func, SHISANZHANG_PLAYERTYPE_TABLE[uid])
    end
    GamePlaneOperator:startGameTime(0)
   
end

--出牌6005
function ShiSanZhangReceiveHandle:SERVER_BROADCAST_OUT_CARD(pack)
    dump(pack, "--------出牌6005------------")
    GamePlaneOperator:outCards(SHISANZHANG_PLAYERTYPE_TABLE[pack.uid], pack.cards, true)
    SoundUtils:playCardKindEffect("比牌", SHISANZHANG_USERINFO_TABLE[pack.uid].sex)
    
    if pack.uid == USER_INFO.uid then
        local MatchCardView = SCENENOW["scene"]:getChildByName("MatchCardView")
        if MatchCardView then
            MatchCardView:removeFromParent()
        end
        local CommonTips_MatchCardView = SCENENOW["scene"]:getChildByName("CommonTips_MatchCardView")
        if CommonTips_MatchCardView then
            CommonTips_MatchCardView:removeFromParent()
        end
    end
end


--广播开始
function ShiSanZhangReceiveHandle:SVR_START_BROADCAST(pack)
    dump(pack, "SVR_START_BROADCAST")
end


--组局排行榜 0x5100
function ShiSanZhangReceiveHandle:SVR_GROUP_RANKING(pack)
    GAME_IS_OVER = true
    if not pack then return end
    GamePlaneOperator:openTotalResult(pack)
end
--组局时长 5101
function ShiSanZhangReceiveHandle:SVR_GROUP_TIME(pack)
    SCENENOW['scene'].group_round = pack.round or 0
    SCENENOW['scene'].group_total_round = pack.round_total or 8

    SCENENOW['scene']:setGroupRound(pack.round, pack.round_total)
end


---聊天
function ShiSanZhangReceiveHandle:SVR_MSG_FACE(pack)

    local faceUI = SCENENOW["scene"]:getChildByName("faceUI")
    if faceUI == nil then
        print("scene:"..SCENENOW["name"],"not match faceUI")
        return
    end
    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end

    local index  = SHISANZHANG_USERINFO_TABLE[pack.uid].seat
    local sexT = 2
    local isLeft = false

    local node_head = PLAYER_HEADS_TABLE[pack.uid]
    if not node_head then return end

    --性别,头像位置
    if index == 0 then
        sexT = USER_INFO["sex"]
    else
        local othInfo = json.decode(SHISANZHANG_USERINFO_TABLE[pack.uid])
        if othInfo ~= nil then
            sexT = tonumber(othInfo.sex)
        end

    end

    if index > 2 then
        isLeft = true
    end
    if faceUI ~= nil and node_head ~= nil then
        faceUI:showGetFace(pack.uid, pack.type, tonumber(sexT), node_head, isLeft)
    end
    -- local s= SCENENOW["scene"]:getChildByName("faceUI")

    -- local sex = 1

    -- if SHISANZHANG_USERINFO_TABLE[pack.uid] then
    --     sex = SHISANZHANG_USERINFO_TABLE[pack.uid].sex or 0
    -- end

    -- local isLeft = false

    -- local node_head = PLAYER_HEADS_TABLE[pack.uid]
    -- if  tonumber(sex) >= 0 and node_head then
    --     s:showGetFace(pack.uid, pack.type, tonumber(sex), node_head, false)
    -- end



end

--组局解散相关
--没有此房间，解散房间失败
function ShiSanZhangReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)

    dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")

    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")

end


--广播当前组局解散情况
function ShiSanZhangReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)
    dump(pack,"--广播当前组局解散情况------------------------")
    local function send_disband(agree)
        require(TpackageName..".handle.ShiSanZhangSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    end
    
    local myPlayer_table={}
    local applyId = pack.applyId
    local agreeNum = pack.agreeNum
    local agreeMember_arr = pack.agreeMember_arr

    local disband_table = {}

    --申请解散者信息
    local applyer_info = {}
    if applyId == USER_INFO["uid"] then
        local player_table = {}
        player_table["playerName"] = "我"
        player_table["state"] = "申请"
        table.insert(disband_table, player_table)
    else
        -- if bm.User ~= nil then
            local player_table = {}
            if SHISANZHANG_USERINFO_TABLE ~= nil then
                applyer_info = SHISANZHANG_USERINFO_TABLE[applyId]
                if applyer_info ~= nil then
                    local nickName = applyer_info["nickName"]
                    if nickName ~= nil then
                        player_table["playerName"] = nickName
                    else
                        player_table["playerName"] = applyId
                    end
                    player_table["state"] = "申请"
                    table.insert(disband_table, player_table)
                end
            end
        end
    -- end
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

        myPlayer_table["playerName"] = "我"

        if isMyAgree == 1 then
            myPlayer_table["state"] = "同意"
        else
            myPlayer_table["state"] = "等待选择"
        end
        myPlayer_table["icon"] = USER_INFO["icon_url"]
        --[[if bm.User ~= nil then
            if SHISANZHANG_USERINFO_TABLE ~= nil then
                for k,v in pairs(SHISANZHANG_USERINFO_TABLE) do
                    local user_data = json.decode(v)
                    if k == USER_INFO["uid"] then
                        if user_data["icon_url"] ~= nil then
                            myPlayer_table["icon"] = user_data["icon_url"]
                        else
                            myPlayer_table["icon"] = ""
                        end
                    end
                end
            end
        end
        table.insert(disband_table, myPlayer_table)]]
        table.insert(disband_table, myPlayer_table)
    end

    --显示其他人情况
     -- if bm.User ~= nil then
        if SHISANZHANG_USERINFO_TABLE ~= nil then
            for k,v in pairs(SHISANZHANG_USERINFO_TABLE) do
                local uid = k
                --排除掉申请者，申请者不需要显示到这里
                if uid ~= applyId and uid ~= USER_INFO["uid"] then

                    --记录当前用户是否已经同意
                    local isAgree = 0
                    if agreeNum > 0 then
                        for k,m in pairs(agreeMember_arr) do
                            if uid == m then
                                --当前用户已经同意
                                isAgree = 1
                                break
                            end
                        end
                    end
                    dump(v,"user_data")
                    --显示当前用户情况
                    local user_data = v
                    local player_table = {}
                    local nickName = user_data["nickName"]
                    if nickName ~= nil then

                        player_table["playerName"] = nickName

                        if isAgree == 1 then
                            player_table["state"] = "同意"
                        else
                            player_table["state"] = "等待选择"
                        end

                        if user_data["icon_url"] ~= nil then
                            player_table["icon"] = user_data["icon_url"]
                        else
                            player_table["icon"] = ""
                        end

                        table.insert(disband_table, player_table)

                    end
                end
            end
        end
     -- end

    if applyId == USER_INFO["uid"] then
        --假如申请者是自己，则直接显示其他用户的选择情况
        require("hall.GameTips"):showDisbandNewTips("提示", "agree_disbandGroup", 4, disband_table)
    else
        --申请者不是自己，根据自己的同意情况进行界面显示
        if isMyAgree == 1 then
            require("hall.GameTips"):showDisbandNewTips("提示", "agree_disbandGroup", 4, disband_table)
        else
            require("hall.GameTips"):showDisbandNewTips("提示", "new_request_disbandGroup", 1, disband_table,send_disband)
        end
    end


end

--广播桌子用户请求解散组局
function ShiSanZhangReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

    dump(pack, "-----广播桌子用户请求解散组局-----")

    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")

end

--广播桌子用户成功解散组局0x103A
function ShiSanZhangReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

    dump(pack, "-------广播桌子用户成功解散组局-----")

    bm.isDisbandSuccess = true

    -- require("hall.GameTips"):showDisbandTips("解散房间成功","ddz_disbandGroup_success",3)

end

--广播桌子用户解散组局 ，解散组局失败
function ShiSanZhangReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

    local rejectId = pack.rejectId
    if rejectId == USER_INFO["uid"] then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
    else
        if SHISANZHANG_USERINFO_TABLE ~= nil then
            if SHISANZHANG_USERINFO_TABLE[rejectId] ~= nil then
                local rejecter_info = SHISANZHANG_USERINFO_TABLE[rejectId]

                require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, rejecter_info["nickName"] .. "拒绝解散房间")
            end
        end

    end

end

function ShiSanZhangReceiveHandle:BROADCAST_USER_IP(pack)
    if pack == nil then
        return
    end
    local ip_list = {}
    for k, v in pairs(pack["playeripdata"]) do
        require("zhajinhua_jb.SHISANZHANGSettings"):setUserIP(v["uid"], v["ip"])
        if v["uid"] == USER_INFO['uid'] then
            require("zhajinhua_jb.ShiSanZhangSendHandle"):CLIENT_CMD_FORWARD_MESSAGE(v["ip"])
        end
        if v["uid"] ~= USER_INFO["uid"] and v["uid"] ~= 0 then
            if ip_list[v["ip"]] == nil then
                ip_list[v["ip"]] = 1
            else
                ip_list[v["ip"]] = ip_list[v["ip"]] + 1
            end
        end
    end

    local same_ip = {}
    for k, v in pairs(ip_list) do
        print("ip_list ",tostring(k), tostring(v))
        if v > 1 then
            same_ip[k] = 1
        end
    end


    local msg = "玩家："
    local show_alert = 0
    if bm.User ~= nil then
        for k, v in pairs(pack["playeripdata"]) do
            if v["ip"]~="" and same_ip[v["ip"]] ~= nil then
                if SHISANZHANG_USERINFO_TABLE and SHISANZHANG_USERINFO_TABLE[v["uid"]] and v["uid"] ~= USER_INFO["uid"] then
                    local nick = SHISANZHANG_USERINFO_TABLE[v["uid"]]

                    msg = msg .. "  "..nick["nickName"]
                    show_alert = 1
                end
            end
        end
    end
    if bm.Room.GroupInfo then
        if bm.Room.GroupInfo["round"] and bm.Room.GroupInfo["round"] > 0 then
            show_alert = 0
        end
    end


    if show_alert == 1 then
        require("hall.GameCommon"):showAlert(false)
        require("hall.GameCommon"):showAlert(true, "提示：" .. msg .. "  ip地址相同，谨防作弊", 300)
    end
end
function ShiSanZhangReceiveHandle:CLI_MSG_FACE(id)
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_MSG_FACE)
    :setParameter("type", id)
    :build()
    bm.server:send(sendpack)
end

--广播开始游戏倒计时 100F广播切牌
function ShiSanZhangReceiveHandle:SVR_BROADCAST_COUNT_DOWN(pack)
    dump(pack, "------广播开始游戏倒计时 切牌 100F------")

    GamePlaneOperator:RemaidStartGame(false)
    if pack.time > 0 then
        GamePlaneOperator:resetAllTipStatus(false)
        if MY_SEAT_ID == pack.seatId then
            GamePlaneOperator:setQiePai(pack.time)
        else
            GamePlaneOperator:startGameTime(pack.time)
        end
    end
end

function ShiSanZhangReceiveHandle:SVR_ERROR(pack)
    dump(pack, "-----登陆错误-----")

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
            --require("hall.GameTips"):showTips("提示", "tohall", 1, tbErrorCode[pack.errorCode])
            -- elseif  pack.errorCode == 7 or pack.errorCode == 5 then
             local exitFunc = function()
                 require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
             end

             require("hall.GameTips"):showTips("提示", "", 1, tbErrorCode[pack.errorCode],nil,exitFunc)
        else
            require("hall.GameTips"):showTips("提示", "", 1, tbErrorCode[pack.errorCode])
        end
    else
        require("hall.GameTips"):showTips("提示", "", 1, "未知的错误")
    end

end
---------------------------------------------------------------------------------------------------------------------------------------------
--扣除台费 4800
function ShiSanZhangReceiveHandle:SVR_CHIP_CHANGE_BROADCAST(pack)
    dump(pack,"SVR_CHIP_CHANGE_BROADCAST")

end
--5001
function ShiSanZhangReceiveHandle:BROADCAST_ERROR_TIPS(pack)

    dump(pack, "-----返回错误提示5001-----")

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
        [21] = "出牌错误！",
        [23] = "前道牌不能大于后道牌！",
    }
    dump(tbErrorCode[errorCode],"错误提示")
    if errorCode == 23 then
        local CardPlaneOperator = require(TpackageName .. ".operator.CardPlaneOperator")
        CardPlaneOperator.recordPiersIndex = {1,2,3}
    end

    if  errorCode == 18 then
        local scenes  = SHISANZHANG_GAME_SCENE
        if scenes then
            scenes:performWithDelay(function()

                --去掉提示弹框
                local layer_tips = scenes:getChildByName("layer_tips")
                if  layer_tips then
                    layer_tips:removeSelf()
                end
                -- require("hall.BuyRoomCard.BuyRoomCardScene"):showScene(isNotShowBuyCard, 1)
                require("hall.GameTips"):showTips("提示", "", 2, "有玩家积分不足，已解散！")
            end,1.5)
        end

    else
        if tbErrorCode[errorCode] then
            require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[errorCode])
        else
            require("hall.GameTips"):showTips("提示", "", 3, "未知的错误")
        end
    end
end
function ShiSanZhangReceiveHandle:SVR_KAN_SHOW(pack)

end

function ShiSanZhangReceiveHandle:SVR_GET_SURP_CARDS(pack)
    print("SVR_GET_SURP_CARDS ------------------------------------")
    dump(pack)
    --GamePlaneOperator:showCheatSurpCards(CARD_PLAYERTYPE_MY, pack.cards)
    if pack.cardSize > 0 then
        self:forTestComp(pack.cards)
    end
    
end



--显示开始游戏按钮 0x2006 
function ShiSanZhangReceiveHandle:SERVER_BROADCAST_START_GAME(pack)
    dump(pack, "-----显示开始游戏按钮-----")
    if pack.star_game_uid == USER_INFO.uid then
        local playerType = SHISANZHANG_PLAYERTYPE_TABLE[pack.star_game_uid]
        if playerType then
            GamePlaneOperator:setReadyStatus(playerType,false)
        end
        GamePlaneOperator:RemaidStartGame(true)
    end
end

--接收服务器放回的指定用户信息pack111
function ShiSanZhangReceiveHandle:SVR_CHARGE_BROADCAST(pack)
   
    local uid = pack.uid
    local playerType = SHISANZHANG_PLAYERTYPE_TABLE[uid]
    local userInfo = SHISANZHANG_USERINFO_TABLE[uid]
    if not (playerType and userInfo) then return end
    userInfo.m_chips = userInfo.m_chips + pack.chargeCoins
    GamePlaneOperator:setCoin(playerType, userInfo.m_chips)
    dump(pack,"pack111")
end

return ShiSanZhangReceiveHandle