require("framework.init")
local hallHandle = require("hall.HallHandle")
local PROTOCOL          = import("zhajinhua_jb.Zhajinhua_Protocol")
local MenjiroomView     = import("zhajinhua_jb.view.MenjiroomView")
local chat              = import("zhajinhua_jb.common.chat")
local CompareView     = import("zhajinhua_jb.view.CompareView")
local ZjhHandle   = class("ZjhHandle",hallHandle)

function ZjhHandle:ctor()
    ZjhHandle.super.ctor(self);

    local func_ = {
        --[PROTOCOL.SVR_GET_ROOM_OK]          = {handler(self, ZjhHandle.SVR_GET_ROOM_OK)},
        [PROTOCOL.SVR_LOGIN_ROOM]           = {handler(self, ZjhHandle.SVR_LOGIN_ROOM)},--登录房间成功
        [PROTOCOL.SVR_READY]                = {handler(self, ZjhHandle.SVR_READY)},  ---广播用户准备
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, ZjhHandle.SVR_LOGIN_ROOM_BROADCAST)},--
        [PROTOCOL.SVR_QUIT_ROOM]            = {handler(self, ZjhHandle.SVR_QUIT_ROOM)}, -- 用户离场
        [PROTOCOL.SVR_BASE_BROADCAST]       = {handler(self, ZjhHandle.SVR_BASE_BROADCAST)},  ---广播台费
        [PROTOCOL.SVR_SEND_CARD]            = {handler(self, ZjhHandle.SVR_SEND_CARD)},   --- 发牌
        [PROTOCOL.SVR_START_BROADCAST]      = {handler(self, ZjhHandle.SVR_START_BROADCAST)},  ---广播开始游戏
        [PROTOCOL.SVR_QUIT]                 = {handler(self, ZjhHandle.SVR_QUIT)},    ---自己退出
        [PROTOCOL.SVR_DIU_BROADCAST]        = {handler(self, ZjhHandle.SVR_DIU_BROADCAST)},  --玩家弃牌
        [PROTOCOL.SVR_KAN_CARD]             = {handler(self, ZjhHandle.SVR_KAN_CARD)},
        [PROTOCOL.SVR_GEN_BROADCAST]        = {handler(self, ZjhHandle.SVR_GEN_BROADCAST)},
        [PROTOCOL.SVR_JIA_BROADCAST]        = {handler(self, ZjhHandle.SVR_JIA_BROADCAST)},
        [PROTOCOL.SVR_BI_BROADCAST]         = {handler(self, ZjhHandle.SVR_BI_BROADCAST)},
        [PROTOCOL.SVR_END]                  = {handler(self, ZjhHandle.SVR_END)},
        [PROTOCOL.SVR_ALL_COMPARE]          = {handler(self, ZjhHandle.SVR_ALL_COMPARE)},
        [PROTOCOL.SVR_ALLIN_BROADCAST]      = {handler(self, ZjhHandle.SVR_ALLIN_BROADCAST)},
        [PROTOCOL.SVR_ERROR]      = {handler(self, ZjhHandle.SVR_ERROR)},
        [PROTOCOL.BROADCAST_CAN_START_GAME]      = {handler(self, ZjhHandle.BROADCAST_CAN_START_GAME)},   --广播开始游戏按钮

        [PROTOCOL.SVR_CHARGE_BROADCAST]      = {handler(self, ZjhHandle.SVR_CHARGE_BROADCAST)},  -- 跟新玩家金币

        -- 6029玩家可以看牌了
        [PROTOCOL.SVR_KAN_SHOW]      = {handler(self, ZjhHandle.SVR_KAN_SHOW)},
        --4008 广播玩家钱数变化（用于扣取台费）
        [PROTOCOL.SVR_CHIP_CHANGE_BROADCAST]       = {handler(self, ZjhHandle.SVR_CHIP_CHANGE_BROADCAST)},
        --广播其他用户坐下（金币场） 1031
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, ZjhHandle.BROADCAST_USER_SIT_DOWN)},
        --广播用户站起 1032
        [PROTOCOL.BROADCAST_USER_STAND_UP] = {handler(self, ZjhHandle.BROADCAST_USER_STAND_UP)},
        --广播用户退出房间 1033
        [PROTOCOL.BROADCAST_USER_QUIT_ROOM] = {handler(self, ZjhHandle.BROADCAST_USER_QUIT_ROOM)},
        --广播剩余时间100F
        [PROTOCOL.SVR_BROADCAST_COUNT_DOWN]           = {handler(self, ZjhHandle.SVR_BROADCAST_COUNT_DOWN)},
        --错误提示5001
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, ZjhHandle.BROADCAST_ERROR_TIPS)},

        [PROTOCOL.SVR_MSG_FACE]={handler(self, ZjhHandle.SVR_MSG_FACE)},
        [PROTOCOL.SVR_GROUP_RANKING] = {handler(self, ZjhHandle.SVR_GROUP_RANKING)},
        [PROTOCOL.SVR_GROUP_TIME] = {handler(self, ZjhHandle.SVR_GROUP_TIME)},
        --没有此房间，解散房间失败
        [PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, ZjhHandle.G2H_CMD_DISSOLVE_FAILED)},
        --广播桌子用户请求解散组局
        [PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, ZjhHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
        --广播当前组局解散情况
        [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, ZjhHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
        --广播桌子用户成功解散组局
        [PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, ZjhHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
        --广播桌子用户解散组局 ，解散组局失败
        [PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, ZjhHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},
        --广播桌子用户ip
        [PROTOCOL.BROADCAST_USER_IP]     = {handler(self, ZjhHandle.BROADCAST_USER_IP)},
        --接收服务器返回的缓存信息
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, ZjhHandle.SERVER_CMD_FORWARD_MESSAGE)},
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, ZjhHandle.SERVER_CMD_MESSAGE)},
        --0x1050回看
        [PROTOCOL.SERVER_COMMAND_GAMERESULT_RECORD] = {handler(self, ZjhHandle.SERVER_COMMAND_GAMERESULT_RECORD)},

        --接收服务器放回的指定用户信息pack111
      -- [PROTOCOL.SERVER_CMD_HALL_GET_MESSAGE] = {handler(self, ZjhHandle.SERVER_CMD_HALL_GET_MESSAGE)},  
    }
    table.merge(self.func_, func_)
end


--
function ZjhHandle:callFunc(pack)
    dump(pack,"======111111111111======")
    print(pack.cmd)
    dump(self.func_[pack.cmd])
    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

--处理进入房间
--function ZjhHandle:SVR_GET_ROOM_OK(pack)
--    local latitude = "0.00"
--    local longitude = "0.00"
--
--    if device.platform == "ios" then
--
--        latitude = cct.getDataForApp("getLatitude", {}, "string")
--        longitude = cct.getDataForApp("getLongitude", {}, "string")
--
--    elseif device.platform == "android" then
--
--        local args = {}
--        local sigs = "()Ljava/lang/String;"
--        local luaj = require "cocos.cocos2d.luaj"
--        local className = luaJniClass
--
--        ok,ret  = luaj.callStaticMethod(className,"getLongitude",args,sigs)
--        if not ok then
--            print("luaj error:", ret)
--        else
--            longitude = ret
--        end
--
--        ok,ret  = luaj.callStaticMethod(className,"getLatitude",args,sigs)
--        if not ok then
--            print("luaj error:", ret)
--        else
--            latitude = ret
--        end
--
--    elseif device.platform == "windows" then
--        latitude = "10.00"
--        longitude = "10.00"
--
--    end
--    dump(pack, "-----SVR_GET_ROOM_OK-----")
--    local seatId = MY_SEAT_ID or -1
--    local tid = pack["tid"] or USER_INFO["tid"]
--    local packData = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM)
--    :setParameter("tid", tid)
--    :setParameter("uid", USER_INFO["uid"])
--    :setParameter("seat_id",seatId)
--    :setParameter("nickName", USER_INFO["nick"])
--    :setParameter("photoUrl", USER_INFO["icon_url"])
--    :setParameter("latitude", latitude)
--    :setParameter("longitude", longitude)
--    :setParameter("activityId", USER_INFO["activityId"])
--    :build()
--    bm.server:send(packData)
--    dump(USER_INFO, "SVR_GET_ROOM_OK=========", nesting)
--end

--接收服务器返回的缓存信息
function ZjhHandle:SERVER_CMD_FORWARD_MESSAGE(pack)

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


function ZjhHandle:showExpression(msg)
    local uid_from = tonumber(msg["uid_from"]) or 1
    local uid_to = tonumber(msg["uid_to"]) or 1
    local expressionType = tonumber(msg["expressionType"]) or 1

    ---------------------------------不同游戏需修改的部分----------------------------
    --通过USER_INFO["uid"]获取seatId
    local seatId_from = ZJH_PLAYERTYPE_TABLE[uid_from] or 2
    local seatId_to =  ZJH_PLAYERTYPE_TABLE[uid_to] or 0

    ------------------------------------------------------------------------------------
    local from_x = MenjiroomView:getHeadPos(seatId_from).x --+ math.random(-10,10)
    local from_y = MenjiroomView:getHeadPos(seatId_from).y --+  math.random(-10,10)

    local to_x   = MenjiroomView:getHeadPos(seatId_to).x --+  math.random(-10,10)
    local to_y   = MenjiroomView:getHeadPos(seatId_to).y --+  math.random(-10,10)

    require("hall.view.animView.animView"):ShowAnimationByPosition(from_x, from_y,to_x,to_y,expressionType)
end

function ZjhHandle:showTextMessage(pack)

    local s= SCENENOW["scene"]:getChildByName("faceUI")
    local sex = 1
    local node_head = PLAYER_HEADS_TABLE[pack.uid]
    s:showGetText(pack.uid,pack.textMessage,sex,node_head, false)
end
--接收服务器返回的组局信息
function ZjhHandle:SERVER_CMD_MESSAGE(pack)
    dump(pack, "-----NiuniuroomHandle 接收服务器返回的组局信息-----")
    if bm.isInGame == false then
        return
    end
    local msg = json.decode(pack.msg)
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
                emojiPack["type"] = msg.type
                self:SVR_MSG_FACE(emojiPack)
            elseif msgType == "EmojiArmatureView" then   --骨骼表情
                self:SVR_MSG_EMOJI_ARMATURE(msg)
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

function ZjhHandle:SVR_MSG_EMOJI_ARMATURE(pack)
    local EmojiArmatureView = SCENENOW.scene:getChildByName("EmojiArmatureView")
    if not EmojiArmatureView then
        return
    end
    if HEART_BEAT_TID ==0 then
        return
    end
    local from_id = pack.uid
    local to_uid = pack.to_uid
    local id = pack.type
    if MY_SEAT_ID >= 0 then
        local toPos = PLAYER_HEADS_POSITION_TABLE[to_uid]
        local fromPos = PLAYER_HEADS_POSITION_TABLE[from_id]
        if toPos and fromPos then
            EmojiArmatureView:showAnimi(toPos, fromPos, id)
        end

    else
        viewMgr:showTip({text = "观战不允许发表情哦!"})
    end

end
--登录房间成功
function ZjhHandle:SVR_LOGIN_ROOM( pack )
    local gameConfig = json.decode(pack["gameConfig"])
    MenjiroomView:init_player_plane(gameConfig)
    require(NetworkLoadingView_filePath):removeView(888)
    -- body
    package.loaded['hall.settlement.settlement'] = nil
    dump(pack,"登录房间返回")
    local uid = tostring(USER_INFO["uid"])
    local seat = tostring(pack.seat)
    ZJH_USER_UID[USER_INFO["uid"]]  = pack.seat
    if pack.isGoldGame == 1 then
        GROUP_MODE = 1
    else
        GROUP_MODE = 2
    end
    if pack.club_id >0 then
        CLUB_ID = pack.club_id
        USER_INFO["family_id"] = pack.club_id
    end
    bm.User.isDisplay = pack.isDisplay
    countUserAllin = pack.countUserAllin
    g_isWatch = pack.isWatch

    USER_INFO["invote_code"] = pack["invote_code"]
    ZJH_USER_SEAT[pack.seat] = USER_INFO["uid"]
    bm.User.isKan = {}
    bm.Room.now_zhu   = pack.base
    BASE_CHIP = pack.base
    IS_ALLIN = pack.is_allin
    bm.Room.now_turns = 0
    MY_SEAT_ID      = pack.seat
    bm.User.Gold      = pack.m_chips
    MenjiroomView:cuopaiTestHide()
    HEART_BEAT_TID = USER_INFO["tid"]
    dump(HEART_BEAT_TID,"HEART_BEAT_TID")
    ALLIN_CHIPS = pack["allinBetList"]
    IS_ALLIN_CHIP = pack.allin_bet
    USER_INFO["ip"] = pack.ip
    print("SVR_LOGIN_ROOM", SCENENOW["name"])
    ZJH_USERINFO_TABLE[USER_INFO["uid"]] = USER_INFO["user_info"]
    ZJH_USER_ONLINE[USER_INFO["uid"]] = 1
    --ZJH_TABLE_CHIPS[USER_INFO["uid"]] = pack["gold"]
    bm.Room.init_chips = pack["table_chips"]
    MenjiroomView:initUI()
    MenjiroomView:clearDesk()
    MenjiroomView:clearCardNode()
    MenjiroomView:resetUserInfo()
    MenjiroomView:resetOperate(false)
    MenjiroomView:setGameConfigNew(pack["gameConfig"])
    MenjiroomView:showGroupInfo()
    
    local invite_ly = ZhaJinHuaPanel:getChildByName("invite_ly")
    local copy_btn = invite_ly:getChildByName("copy_btn")
    require("hall.util.GameMenu"):registCopyRoomIdFunc(copy_btn,USER_INFO["invote_code"],GAME_NAME)  ---房间号复制
	
	if g_isWatch == 1 then
		invite_ly:setVisible(true)
	else
		invite_ly:setVisible(false)
	end

    if pack.isDisplay ~=0 and pack.isDisplay then
        --isKanBtn=true
    end

    if not MAXPEOPLE then
        MenjiroomView:change_seat(json.decode(pack["gameConfig"]).maxSeatCount)
    end
	
    if g_isWatch == 0 then
        MenjiroomView:setGuanZhanVisible(true) --观战
    end

    --添加录音按钮
    MenjiroomView:showVoice()



    --MenjiroomView:showMyinfo()
    --牌局未开始
    if_startgame=pack.if_startgame
    if pack.status == 0 then
        ZJH_GAME_STATE = GAME_STATUS_STOP
        for k,v in pairs(pack.nostart[1].userInfo) do
            dump(v,"userInfo 311")
            self:SVR_LOGIN_ROOM_BROADCAST(v)
            if v.if_ready == 1 then
                ZJH_USER_UID_PLAYING[v.uid] = 1
                MenjiroomView:showReady(v.uid,true)
            else
                MenjiroomView:showReady(v.uid,false)
            end
        end
        if pack.uid == USER_INFO["uid"] then
            --if pack.if_startgame==2 then
                MenjiroomView:showControlButtons(true)
            --elseif pack.if_startgame==1 then
                --MenjiroomView:showstartgame(true)
            --else
                --MenjiroomView:showControlButtons(false)
            --end
            if  pack.seat < 0 then
                MenjiroomView:showControlButtons(false)
                if  PLAYERNUM < TOTAL_PLAYERNUM then
                    if GROUP_MODE == 2 then
                        MenjiroomView:showSitDownButton(true)
                    end
                end
            end
        end

        if pack.if_ready == 1 then
            MenjiroomView:showReady(tonumber(uid),true)
            MenjiroomView:showControlButtons(false)
            --MenjiroomView:showSitDownButton(true)
            -- MenjiroomView:showNextReady(true)
        else

        end
        --显示房间信息
        local tmp_pack = {}
        tmp_pack.all_zhu   = 0
        tmp_pack.all_turns = 0
        tmp_pack.now_turns = 0
        MenjiroomView:showRoomInfo(tmp_pack)
        MenjiroomView:showShare(true)
    end


    --牌局开始
    if pack.status == 2 then

        

        ZJH_GAME_STATE = GAME_STATUS_OUTCARD
        dump(pack.start[1].userinfos,"pack.start[1].userinfos")
        for k,v in pairs(pack.start[1].userinfos) do
            self:SVR_LOGIN_ROOM_BROADCAST(v)
            ZJH_USER_UID_PLAYING[v.uid] = v.playing
        end
        for k,v in pairs(pack.start[1].userinfos) do
            if v["bet_values"] then
                for kk, vv in pairs(v["bet_values"]) do
                    --MenjiroomView:settingsGold(v["uid"],vv)
                    MenjiroomView:diuChips(v["uid"],vv)
                end
            end
        end

        MenjiroomView:showNextReady(false)
        -- 邀请好友
        MenjiroomView:showShare(false)

        MenjiroomView:showChipSum(true,pack.start[1].all_xia or 0)
        --显示房间信息
        local tmp_pack = {}
        tmp_pack.all_zhu   = pack.start[1].all_xia
        tmp_pack.all_turns = pack.start[1].all_cycle
        tmp_pack.now_turns = pack.start[1].now_cycle
        MenjiroomView:showRoomInfo(tmp_pack)

        bm.Room.now_turns = pack.start[1].now_cycle
        bm.Room.totalRound = pack.start[1].all_cycle
        bm.Room.now_zhu = pack.start[1]["now_xia"]
        bm.Room.min_pk = pack.start[1]["min_pk"]
        bm.Room.min_allin = pack.start[1]["min_allin"]
        ZJH_USER_UID_PLAYING[USER_INFO["uid"]]=pack.start[1]["playing"]
        --MenjiroomView:showBanker(pack.start[1]["zhuang_seat"])
        if pack.start[1]["play_content"] then
            local data = pack.start[1]["play_content"][1]
            bm.Room.zhus = data["zhus"]
        end
        local  callbackStartSendCard = function ()
            --if TimerHandle then
            --    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(TimerHandle)
            --end
            -- 玩家自己信息
            local lookCardStatus
            for i,userInfo in ipairs(pack.start[1].userinfos) do
                if userInfo.uid == USER_INFO.uid then
                    lookCardStatus = userInfo.lookCardStatus
                    break
                end
            end
            if pack.start[1]["play_content"] then
                local data = pack.start[1]["play_content"][1]
                bm.Room.zhus = data["zhus"]
                if data["if_check"] == 1 and lookCardStatus == 1 then --是否已看牌
                    dump(data["cards"],"data[cards]")
                    bm.User.Cards = MenjiroomView:sortOrder(data["cards"])
                    bm.User.card_type=data["card_type"]
                    MenjiroomView:setCards()
                    MenjiroomView:showCardType(data["card_type"])
                    --bm.User.isKan[USER_INFO["uid"]] = 1
                    --MenjiroomView:showKanpai(USER_INFO["uid"])
                end
                if data["cancel"] == 1 then -- 是否弃牌
                    --MenjiroomView:showQipai(USER_INFO["uid"])
                    bm.User.isDiu[USER_INFO["uid"]] = 1
                end
                if data["user_all_xia"] > 0 then -- 已下注
                    -- MenjiroomView:diuChips(USER_INFO["uid"],data["user_all_xia"])
                    MenjiroomView:showNowZhu(USER_INFO["uid"],data["user_all_xia"])
                   ZJH_TABLE_CHIPS[USER_INFO["uid"]] = data["user_all_xia"]
                end
                --if data["bet_values"] then
                --    for kk, vv in pairs(data["bet_values"]) do
                --        MenjiroomView:diuChips(USER_INFO["uid"],vv)
                --    end
                --end

            end
            for k,v in pairs(pack.start[1].userinfos) do
                if v.if_ready == 1 then
                    MenjiroomView:showReady(v["uid"],true)
                end
                if v["if_check"] == 1 and v.lookCardStatus == 1 then --是否已看牌
                    bm.User.isKan[v["uid"]] = 1
                    MenjiroomView:showKanpai(v["uid"])
                end
                if v["cancel"] == 1 then -- 是否弃牌
                    MenjiroomView:showQipai(v["uid"])
                    bm.User.isDiu[v["uid"]] = 1
                end
                if v["xia"] > 0 then -- 已下注
                    -- MenjiroomView:diuChips(v["uid"],v["xia"])
                    MenjiroomView:showNowZhu(v["uid"],v["xia"])
                    ZJH_TABLE_CHIPS[v["uid"]] = v["xia"]
                end

            end

        end
        local next_uid = ZJH_USER_SEAT[pack.start[1]["now_seat"]]
        if next_uid then
            MenjiroomView:showKuanNode(next_uid)
            MenjiroomView:resetOperate(true)
            MenjiroomView:showRoomButton(next_uid, pack.start[1]["can_compare"], pack.start[1]["is_allin"])
            MenjiroomView:showProgressTimer(next_uid, pack.start[1]["time"])
        end
        MenjiroomView:sendCard(callbackStartSendCard)
        MenjiroomView:showControlButtons(false)
    end
    MenjiroomView:setBaseChip(pack["base"])
    require("zhajinhua_jb.zjhSettings"):updateUserList()

    -- 自动准备
    --SCENENOW['scene'].view:readyRoom()
    require("zhajinhua_jb.ZhajinHuaServer"):CLIENT_CMD_FORWARD_MESSAGE("")
    MenjiroomView:getDeviceInfo()
end



--广播用户坐下 1031   其他用户进入房间
function  ZjhHandle:BROADCAST_USER_SIT_DOWN(pack)
    if pack.uid == USER_INFO["uid"] then
        MY_SEAT_ID = pack.seat
    end
    ZJH_USER_UID[pack.uid] = pack.seat --保存用户座位与id映射
    ZJH_USER_SEAT[pack.seat] = pack.uid --保存用户座位与id映射
    MenjiroomView:showNetwork(pack.uid,false)
    pack["m_chips"] = pack.gold
    pack.gold = 0
    pack.ip = USER_INFO["ip"]
    if  USER_INFO["uid"] == pack.uid then  --自己坐下的话重新排版布局
       -- SCENENOW["scene"]:showButtonAfterSitDown(true)
       local userInfo =  ZJH_USERINFO_TABLE[pack.uid]
        dump(userInfo,"userInfo444")
        userInfo["m_chips"] = pack["m_chips"]
        userInfo.gold = 0
        userInfo.ip = USER_INFO["ip"]
        userInfo.seat = pack.seat
        self:SVR_LOGIN_ROOM_BROADCAST(userInfo)
        ZhaJinHuaPanel:getChildByName("btn_chat"):setVisible(true)
        ZhaJinHuaPanel:getChildByName("btn_voice"):setVisible(false)
        MenjiroomView:showSitDownButton(false)
        --游戏过程中加入不会重定位
        if  ZJH_GAME_STATE == GAME_STATUS_STOP then
            --if if_startgame == 2 then
                MenjiroomView:showControlButtons(true)
            --elseif if_startgame == 1 then
                --MenjiroomView:showControlButtons(false)
            --else
                --MenjiroomView:showControlButtons(false)
            --end
            MenjiroomView:relocatePlayer()
        else
            MenjiroomView:relocatePlayer()
            MenjiroomView:sendCard()
        end

    else  --其他人坐下的话只给他画头像信息
        local userInfo =  ZJH_USERINFO_TABLE[pack.uid]
        if  userInfo == nil then
            self:SVR_LOGIN_ROOM_BROADCAST(pack)
        else
            MenjiroomView:showUserInfo(userInfo)
        end

    end

    --人满之后自己作为旁观者时隐藏坐下按钮
    if  ZJH_USER_UID[USER_INFO["uid"]] < 0 then
        if  PLAYERNUM == TOTAL_PLAYERNUM then
            MenjiroomView:showSitDownButton(false)
        end
    end

end

--广播玩家站起 1032
function ZjhHandle:BROADCAST_USER_STAND_UP(pack)
    if bm.Room.iswith == true then
        return
    end
    if pack.uid == USER_INFO["uid"] then
        if bm.Room.iswith == false then
            MY_SEAT_ID = -1
        end
    end
    if ZJH_USER_UID_PLAYING[pack.uid] then
        ZJH_USER_UID_PLAYING[pack.uid] = 0
    end
    MenjiroomView:removeUserInfo(pack.uid)
    MenjiroomView:removeReady(pack.uid)
    MenjiroomView:showNetwork(pack.uid,false)
    if bm.Room.iswith == false then
        ZJH_USER_UID[pack.uid] = -1
    end

    if  USER_INFO["uid"] == pack.uid then
        MenjiroomView:showControlButtons(false)
        ZhaJinHuaPanel:getChildByName("btn_chat"):setVisible(false)
        ZhaJinHuaPanel:getChildByName("btn_voice"):setVisible(false)
        if GROUP_MODE == 2 then
            MenjiroomView:showSitDownButton(true)
        end
        if  ZJH_GAME_STATE == GAME_STATUS_STOP then
            MenjiroomView:relocatePlayer()
        end
    else
        if  ZJH_USER_UID[USER_INFO["uid"]] < 0 then
            MenjiroomView:showSitDownButton(true)
        end
    end
    local updateUserInfoData = {}
    ZJH_PLAYERTYPE_TABLE[pack.uid] = nil
    updateUserInfoData["latitude"] = nil
    updateUserInfoData["longitude"] = nil
    updateUserInfoData["ip"] =  ""
    updateUserInfoData["invote_code"] = USER_INFO["invote_code"]
    updateUserInfoData["nickName"] =  ""
    dump(updateUserInfoData,"updateUserInfoData")
    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(pack.uid,{},"reset")
end

function ZjhHandle:BROADCAST_CAN_START_GAME()
    dump("---------------------广播开始游戏6030----------------------------")
    MenjiroomView:showControlButtons(false)
    MenjiroomView:showSitDownButton(false)
    MenjiroomView:showstartgame(true)
end

--广播玩家退出返回（离开房间） 1033
function ZjhHandle:BROADCAST_USER_QUIT_ROOM(pack)
    print("BROADCAST_USER_QUIT_ROOM"..os.date("%Y-%m-%d-%H:%M"))
    if GROUP_MODE == 2 or bm.Room.iswith == false  then
        local uid  = pack.uid
        local seat = ZJH_USER_UID[uid]
        if seat == nil then
            return
        end

        MenjiroomView:removeUserInfo(uid)
        MenjiroomView:removeReady(uid)
        MenjiroomView:showNetwork(uid,false)
        ZJH_USER_UID_PLAYING[uid] = 0
        if ZJH_USER_SEAT then
            ZJH_USER_SEAT[seat]      = nil
        end
        if  ZJH_USER_UID then
            ZJH_USER_UID[uid]       = nil
        end
        if bm.User.isKan then
            bm.User.isKan[pack.uid]     = nil
        end
        if bm.User.isDiu then
            bm.User.isDiu[pack.uid]     = nil
        end

        if ZJH_USERINFO_TABLE[pack["uid"]] then
            ZJH_USER_ONLINE[pack["uid"]] = 0

        end
        require("zhajinhua_jb.zjhSettings"):updateUserList()
       -- require("zhajinhua_jb.zjhSettings"):resetUserInfo()
        if  pack.uid == USER_INFO["uid"] then
            collectgarbage("collect")
            collectgarbage("collect")
            dump(collectgarbage("count"),"collectgarbagecount3")  --用于检测内存占用
            --cc.Director:getInstance():destroyInstance();
            -- ShowCard:destroyInstance();
            cc.Director:getInstance():getTextureCache():removeUnusedTextures();
            cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames();
            -- ZhaJinHuaPanel:removeSelf()
            USER_INFO["gameConfig"] = ""
            HEART_BEAT_TID = 0
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
        end
        if ZJH_PLAYERTYPE_TABLE[pack.uid] then
            ZJH_PLAYERTYPE_TABLE[pack.uid] = nil
        end

    end
    --local updateUserInfoData = {}
    --updateUserInfoData["latitude"] =  ""
    --updateUserInfoData["longitude"] =  ""
    --updateUserInfoData["ip"] =  ""
    --updateUserInfoData["invote_code"] = USER_INFO["invote_code"]
    --updateUserInfoData["nickName"] =  ""
    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(pack.uid,{},"reset")

end

--结算协议
function ZjhHandle:SVR_END(pack)
    dump(pack,"--结算协议")
    dump(bm.Room)
    bm.Room.over = false
    bm.Room.isover = true
    IS_RANKING = false
    bm.User.isDisplay = 0  --看牌重置
    MenjiroomView:showChipSum(true,0)

    print("gameEnd3===bm.Room.all_compare ",bm.Room.all_compare)
    for k,v in pairs(ZJH_USER_UID) do
        ZJH_USER_UID_PLAYING[k] = 0;
    end

    if bm.Room.all_compare and bm.Room.all_compare == 1 then
        bm.Room.result = pack
    else
    end
    MenjiroomView:cpShow(false)
    local cuopai = ZhaJinHuaPanel:getChildByName("cuopai")
    if not tolua.isnull(cuopai) then
        cuopai:removeSelf()
    end
    MenjiroomView:gameEnd(pack)

end

--广播全桌比牌
function ZjhHandle:SVR_ALL_COMPARE( pack )
    print("AllCompare")
    -- body
    MenjiroomView:AllCompare()
end

--广播比牌结果
function ZjhHandle:SVR_BI_BROADCAST( pack )
    countUserAllin = pack.countUserAllin
    MenjiroomView:clearBipai()
    MenjiroomView:stopTimer()
    local uid = pack["uid"] --uid主动发起，buid被动比牌
    local buid = pack["buid"]
    local selfUid = USER_INFO["uid"]
    dump(pack,"---广播比牌结果--------------")

    MenjiroomView:showChipSum(true,pack.all_zhu or 0)

    -- body
    --pack.result == 1 成功
    if (pack.result ~= 1 and uid == selfUid) or (pack.result == 1 and buid == selfUid) then
        bm.Room.is_compare = false
    end
    if (uid == selfUid) or (buid == selfUid) then
        bm.Room.now_zhu = pack.kou_gold----扣费 要跟注的分
    end
    bm.Room.all_compare = 1
    bm.Room.result = nil

    bm.Room.anim = 7

    local delay_compare = 0
    bm.Room.show_card = 0
    bm.Room.show_cards = {}
    bm.Room.init_chips = pack["table_chips"]
    local user_node = MenjiroomView:getUserNode(selfUid)

    if pack["f_cards"] and pack.f_cards > 0 then
        bm.Room.show_cards[uid] = {}
        bm.Room.show_cards[uid] = pack["f_card"]
        if is_show_zjh_sing then
            if bm.User.isDiu[selfUid] == 1 then
                bm.Room.show_card = 0  --比牌结算是否展示玩家牌 1是展示
            else
                bm.Room.show_card = 1  --比牌结算是否展示玩家牌 1是展示
            end

        else
            bm.Room.show_card = 1  --比牌结算是否展示玩家牌 1是展示
        end
    end
    if pack["s_cards"] and pack.s_cards > 0 then
        bm.Room.show_cards[buid] = {}
        bm.Room.show_cards[buid] = pack["s_card"]
        if is_show_zjh_sing then
            if bm.User.isDiu[selfUid] == 1 then
                bm.Room.show_card = 0  --比牌结算是否展示玩家牌 1是展示
            else
                bm.Room.show_card = 1  --比牌结算是否展示玩家牌 1是展示
            end
        else
            bm.Room.show_card = 1  --比牌结算是否展示玩家牌 1是展示
        end
      
    end

    if pack.next_seat == -1 then
        if bm.Room.seatProgressTimer ~= nil then
            if bm.Room.seatProgressTimer:getParent() then
                bm.Room.seatProgressTimer:removeSelf()
            end
            bm.Room.seatProgressTimer = nil
        end

        MenjiroomView:resetOperate(false)
    else
        local uid = ZJH_USER_SEAT[pack["next_seat"]]
        if uid then
            MenjiroomView:showStartTimer(pack.time)
            MenjiroomView:showProgressTimer(uid,pack.time)
            MenjiroomView:showRoomButton(uid, pack["can_compare"])
            MenjiroomView:showKuanNode(uid)
        end

        if uid == selfUid then
            bm.Room.zhus = pack.zhus
        end
    end

    -- 设置比牌结果
    --if pack["result"] then
        if pack["result"] == 0 then
            bm.User.isDiu[uid] = 1
            MenjiroomView:showQipai(uid)
        else

            bm.User.isDiu[buid] = 1
            MenjiroomView:showQipai(buid)
        end
    --end
    --if USER_INFO["uid"] == uid or USER_INFO["uid"] == buid and
    MenjiroomView:diuChips(pack.uid,pack.kou_gold)
    MenjiroomView:showNowZhu(pack.uid,pack.user_zhu)
    MenjiroomView:showRoomInfo(pack)
    ZJH_TABLE_CHIPS[uid] = ZJH_TABLE_CHIPS[uid] + pack["kou_gold"]
    --MenjiroomView:settingsGold(pack.uid,pack.m_chips)

    MenjiroomView:updataUserGold(pack.uid,pack.m_chips)

    -- 游戏音效
    local data_info = ZJH_USERINFO_TABLE[uid]
    if data_info then
        print ("data_info[sex]lin", debug.getinfo(1).currentline)
        print ("data_info[sex]", data_info["sex"])
        -- SoundUtils:playCardKindEffect("call", data_info["sex"])
        -- if data_info["sex"] == 1 or data_info["sex"] == "1" then --男
        --     require("hall.GameCommon"):playEffectSound("zhajinhua_jb/res/audio/f_cmp.mp3")
        -- else
        --     require("hall.GameCommon"):playEffectSound("zhajinhua_jb/res/audio/m_cmp.mp3")
        -- end
    end
    -- CompareView:showCampare(pack.uid,pack.buid,pack.result)
   
    --if not (uid == selfUid or buid == selfUid) then --不是自己的话不显示牌的信息
    --    bm.Room.show_cards[buid] = {}
    --    bm.Room.show_cards[uid] = {}
    --else
    --    require("zhajinhua_jb.view.CompareView"):showCampare(uid,buid,pack["result"])
    --end
    if not (uid == selfUid or buid == selfUid) then --不是自己的话不显示牌的信息
        bm.Room.show_cards[buid] = {}
        bm.Room.show_cards[uid] = {}
    end
    if selfUid == uid and pack.result == 1 and pack.uidLookCardStatus == 0 then
        MenjiroomView:isKanButton(true)
    elseif selfUid == buid and pack.result ~= 1 and pack.buidLookCardStatus == 0 then
        MenjiroomView:isKanButton(true)
    end
    require("zhajinhua_jb.view.CompareView"):showCampare(uid,buid,pack["result"], pack)
    for k,v in pairs(ZJH_USER_UID) do
        local uid = tonumber(k)
        if uid ~= selfUid then
            local user_node = MenjiroomView:getUserNode(uid)
            if user_node~= nil then
                local tmp = user_node:getChildByName("kuang_node")
                if tmp ~= nil then
                    tmp:removeSelf()
                end
            end

        end
    end

end

--广播玩家加注
function ZjhHandle:SVR_JIA_BROADCAST(pack)
    MenjiroomView:clearBipai()
    MenjiroomView:stopTimer()
    local next_seat = pack.next_seat
    local next_uid  = ZJH_USER_SEAT[next_seat]
    if next_uid == nil then
        return
    end

    MenjiroomView:showChipSum(true,pack.all_zhu or 0)

    bm.Room.init_chips = pack["table_chips"]
    MenjiroomView:chatContent(pack.uid,chat[5]['font'])
    bm.Room.now_zhu    = pack["round_chips"]
    bm.Room.now_turns  = pack.now_turns
    if next_uid ~= nil then
        MenjiroomView:showStartTimer(pack.time)
        MenjiroomView:showProgressTimer(next_uid,pack.time)
        MenjiroomView:showRoomButton(next_uid, pack["can_compare"])
        if tonumber(next_uid) == USER_INFO["uid"] then
            bm.Room.zhus      = pack.zhus
        end
        MenjiroomView:showKuanNode(next_uid)
    end

    MenjiroomView:diuChips(pack.uid,pack.gold)
    MenjiroomView:showRoomInfo(pack)
    MenjiroomView:showNowZhu(pack.uid,pack.user_zhu)

    MenjiroomView:updataUserGold(pack.uid,pack.m_chips)


    ZJH_TABLE_CHIPS[pack["uid"]] = ZJH_TABLE_CHIPS[pack["uid"]] + pack["gold"]
    --MenjiroomView:settingsGold(pack.uid,pack.m_chips)

    -- 游戏音效
    local data_info = ZJH_USERINFO_TABLE[pack["uid"]]
    if data_info then
        print ("data_info[sex]lin", debug.getinfo(1).currentline)
        print ("data_info[sex]", data_info["sex"])
        SoundUtils:playCardKindEffect("raise", data_info["sex"])
        -- if data_info["sex"] == 1 or data_info["sex"] == "1" then --男
        --     require("hall.GameCommon"):playEffectSound("zhajinhua_jb/res/audio/f_add.mp3")
        -- else
        --     require("hall.GameCommon"):playEffectSound("zhajinhua_jb/res/audio/m_add.mp3")
        -- end
    end
end

--广播玩家allin
function ZjhHandle:SVR_ALLIN_BROADCAST(pack)
    MenjiroomView:clearBipai()
    local next_seat = pack.next_seat
    IS_ALLIN_CHIP = 1
    MenjiroomView:stopTimer()
--    MenjiroomView:showAllin()
    MenjiroomView:chatContent(pack.uid,chat[5]['font'])
    bm.Room.now_zhu    = pack.gold
    bm.Room.now_turns  = pack.now_turns

    MenjiroomView:showChipSum(true,pack.all_zhu or 0)

    MenjiroomView:diuChipsAllin(pack["uid"],pack["gold"]/100)
    MenjiroomView:showNowZhu(pack["uid"],pack["gold"], 1)
    MenjiroomView:showRoomInfo(pack)

    ZJH_TABLE_CHIPS[pack["uid"]] = ZJH_TABLE_CHIPS[pack["uid"]] + pack["gold"]
    --MenjiroomView:settingsGold(pack["uid"],pack["m_chips"])


     MenjiroomView:updataUserGold(pack.uid,pack.m_chips)

    local next_uid  = ZJH_USER_SEAT[next_seat]
    if next_uid and next_uid >=0 then
        MenjiroomView:showStartTimer(pack.time)
        MenjiroomView:showProgressTimer(next_uid,pack.time)
        MenjiroomView:showRoomButton(next_uid, 0,1)
        MenjiroomView:showKuanNode(next_uid)
    end
    -- 游戏音效
    local data_info = ZJH_USERINFO_TABLE[pack["uid"]]
    if data_info then
        print ("data_info[sex]lin", debug.getinfo(1).currentline)
        print ("data_info[sex]", data_info["sex"])
        if data_info["sex"] == 1 or data_info["sex"] == "1" then --男
            require("hall.GameCommon"):playEffectSound("zhajinhua_jb/res/audio/f_allin.mp3")
        else
            require("hall.GameCommon"):playEffectSound("zhajinhua_jb/res/audio/m_allin.mp3")
        end
    end
end


--玩家看牌
function ZjhHandle:SVR_KAN_CARD(pack)
    dump(pack,"玩家看牌------")
    bm.User.isKan[pack.uid] = 1
    local next_seat = pack.next_seat
    local next_uid  = ZJH_USER_SEAT[next_seat]
    bm.Room.now_zhu    = pack["round_chips"]
    bm.Room.now_turns  = pack.now_turns
    MenjiroomView:chatContent(pack.uid,chat[6]['font'])
    MenjiroomView:showKanpai(pack.uid)
    if next_uid ~= nil and next_uid == pack.uid then
        bm.Room.init_chips = pack["table_chips"]
        MenjiroomView:showRoomButton(next_uid, pack["can_compare"])
    end

    -- 游戏音效
    local data_info = ZJH_USERINFO_TABLE[pack["uid"]]
    if data_info then
        print ("data_info[sex]lin", debug.getinfo(1).currentline)
        print ("data_info[sex]", data_info["sex"])
        -- SoundUtils:playCardKindEffect("view", data_info["sex"])
        -- if data_info["sex"] == 1 or data_info["sex"] == "1" then --男
        --     require("hall.GameCommon"):playEffectSound("zhajinhua_jb/res/audio/f_see.mp3")
        -- else
        --     require("hall.GameCommon"):playEffectSound("zhajinhua_jb/res/audio/m_see.mp3")
        -- end
    end
end


--玩家跟注
function ZjhHandle:SVR_GEN_BROADCAST(pack)
    MenjiroomView:clearBipai()
    MenjiroomView:stopTimer()

    local next_seat = pack.next_seat
    local next_uid  = ZJH_USER_SEAT[next_seat]
    bm.Room.init_chips = pack["table_chips"]
    --bm.Room.now_zhu = pack["round_chips"]
    dump(next_uid,"next_uid")
    if next_uid == nil then
        MenjiroomView:resetOperate(false)
    end

    MenjiroomView:showChipSum(true,pack.all_zhu or 0)

    local point = 0
    if bm.User.isKan[pack.uid] == nil then
        point = 2
        if pack.now_turns >=3 then
            local num = math.random(1,10)
            if num >= 7 then
                point = 7
            else
                point = 2
            end
        end
    else
        point = 1
        if pack.now_turns >=3 then
            local num = math.random(1,10)
            if num >= 7 then
                point = 10
            else
                point = 1
            end
        else
            local num = math.random(1,10)
            if num >= 7 then
                point = 8
            end
        end

    end

    MenjiroomView:chatContent(pack.uid,chat[point]['font'])

    bm.Room.now_turns  = pack.now_turns
    if next_uid ~=nil then
        MenjiroomView:showStartTimer(pack.time)
        MenjiroomView:showProgressTimer(next_uid,pack.time)
        MenjiroomView:showRoomButton(next_uid, pack["can_compare"])
        if tonumber(next_uid) == USER_INFO["uid"] then
            bm.Room.zhus      = pack.zhus
        end
        MenjiroomView:showKuanNode(next_uid)
    end

    MenjiroomView:diuChips(pack.uid,pack.gold)
    MenjiroomView:showRoomInfo(pack)
    MenjiroomView:showNowZhu(pack.uid,pack.user_zhu)


    -- ZJH_TABLE_CHIPS[pack["uid"]] = ZJH_TABLE_CHIPS[pack["uid"]] + pack["gold"]
    MenjiroomView:updataUserGold(pack.uid,pack.m_chips)

    --MenjiroomView:settingsGold(pack.uid,pack.gold)

    -- 游戏音效
    local data_info = ZJH_USERINFO_TABLE[pack["uid"]]
    if data_info == nil then
    end
    if data_info then
        print ("data_info[sex]lin", debug.getinfo(1).currentline)
        print ("data_info[sex]", data_info["sex"])
        SoundUtils:playCardKindEffect("call", data_info["sex"])
        
    end

end


--玩家弃牌
function ZjhHandle:SVR_DIU_BROADCAST( pack )
    MenjiroomView:clearBipai()
    bm.User.isDiu[pack.uid] = 1
    countUserAllin = pack.countUserAllin
    if pack.next_id  ~= -1 then
        local uid = ZJH_USER_SEAT[pack.next_id]
        MenjiroomView:showStartTimer(pack.time)
        MenjiroomView:showProgressTimer(uid,pack.time)
        local is_allin = 0
        if pack["game_status"] == 4 then
            is_allin = 1
        end
        MenjiroomView:showRoomButton(uid, pack["can_compare"], is_allin)

        if tonumber(uid) == USER_INFO["uid"] then
            bm.Room.zhus = pack["zhus"]
        end
        MenjiroomView:showKuanNode(uid)
    end

    bm.Room.now_turns  = pack["now_turn"]
    bm.Room.totalRound = pack["all_turns"]
    MenjiroomView:showRounds()
    MenjiroomView:showQipai(pack.uid)
    local point = 4
    local num   =  math.random(1,10)
    if num % 2 ==0 then
        point = 3
    end
    MenjiroomView:chatContent(pack.uid,chat[point]['font'])
    -- 游戏音效
    local data_info = ZJH_USERINFO_TABLE[pack["uid"]]
    if data_info then
        print ("data_info[sex]lin", debug.getinfo(1).currentline)
        print ("data_info[sex]", data_info["sex"])
        SoundUtils:playCardKindEffect("fold", data_info["sex"])

        -- if data_info["sex"] == 1 or data_info["sex"] == "1" then --男
        --     require("hall.GameCommon"):playEffectSound("zhajinhua_jb/res/audio/f_giveup.mp3")
        -- else
        --     require("hall.GameCommon"):playEffectSound("zhajinhua_jb/res/audio/m_giveup.mp3")
        -- end
    end
end

--用户准备
function ZjhHandle:SVR_READY(pack)


    --if bm.Room.over == true then
    --    local zhezhao = scenes:getChildByName("zhezhao")
    --    if zhezhao ~= nil then
    --        zhezhao:removeSelf()
    --    end
    --end
    if pack.readyState == 1 then
        MenjiroomView:showReady(pack.uid, true)
    elseif pack.readyState ==0 then
        MenjiroomView:removeReady(pack.uid,false)
    end

    ZJH_USER_UID_PLAYING[pack.uid] = 1;
    if pack["uid"] == USER_INFO["uid"] then
        --MenjiroomView:resetGame()
        if pack.readyState == 1 then
            MenjiroomView:showControlButtons(false)
        elseif pack.readyState == 0 then
            MenjiroomView:showControlButtons(true)
        end

    end

end


--用户入场
function ZjhHandle:SVR_LOGIN_ROOM_BROADCAST(pack)
    dump(pack,"SVR_LOGIN_ROOM_BROADCAST")
    local uid  = pack.uid
    ZJH_USER_UID[uid]  = pack.seat
    ZJH_USER_SEAT[pack.seat] = pack.uid
    -- local user_info = json.decode(pack["info"])
    if pack.sex == nil then
        pack.sex = 1
    end
    ZJH_USERINFO_TABLE[pack["uid"]]  = pack
    ZJH_USER_ONLINE[pack["uid"]] = 1
    ZJH_TABLE_CHIPS[pack["uid"]] = pack["gold"]
    ZJH_USERINFO_TABLE[pack["uid"]] = pack
    local finalChip = pack["m_chips"]

    if finalChip then
        MenjiroomView:setCoin(uid,finalChip)
        --if  finalChip > 10000 then
        --	local finalChipTxt = tostring(finalChip/10000)
        --	if string.len(finalChipTxt) <= 4 then
        --		finalChip = string.format("%.1f", finalChipTxt) .. "万"
        --	else
        --		local endlength = string.find(finalChipTxt,"%.")
        --		finalChip = string.sub(finalChipTxt,1,endlength-1) .. "万"
        --	end
        --end
        if GROUP_MODE == 1 then
            finalChip = finalChip 
        end
        ZJH_USER_TOTAL_CHIPS[uid] = finalChip

    end
    if pack.seat>=0 then
        MenjiroomView:showUserInfo(pack)
        require("zhajinhua_jb.zjhSettings"):updateUserList()
    end
    MenjiroomView:showNetwork(uid,false)
    dump(ZJH_USER_UID,"ZJH_USER_UID")
    --MenjiroomView:setCoin(uid,pack["m_chips"])
end

--获取当前坐下的玩家数量
function ZjhHandle:getPlayerNum()

    local playerNum = 0
    local audienceNum = 0

    for uid,seat in pairs(ZJH_USER_SEAT) do
        if  seat >= 0 then
            playerNum = playerNum + 1
        else
            audienceNum = audienceNum + 1
        end
    end

    return playerNum,audienceNum

end
--function ZjhHandle:relocatePlayer()
--    dump(ZJH_USER_UID,"relocatePlayer")
--    MenjiroomView:resetUserInfo()
--    for  uid,seat in pairs(ZJH_USER_UID) do
--        if seat >= 0 then
--            local userInfo =  ZJH_USERINFO_TABLE[uid]
--            MenjiroomView:showUserInfo(userInfo)
--        end
--    end
--end
--用户离场
function ZjhHandle:SVR_QUIT_ROOM(pack)
    dump(pack,"用户离场")
    local uid  = pack.uid
    if uid == USER_INFO["uid"] then
        --require("zhajinhua_jb.ZhajinHuaServer"):enterRoom()
    end
    --local seat = ZJH_USER_UID[uid]
    --MenjiroomView:removeUserInfo(uid)
    --print("SVR_QUIT_ROOM")
    -- ZJH_USER_SEAT[seat]      = nil
    -- ZJH_USER_UID[uid]       = nil
    --bm.User.isKan[pack.uid]     = nil
    --bm.User.isDiu[pack.uid]     = nil
    --
    --if ZJH_USERINFO_TABLE[pack["uid"]] then
    --    ZJH_USER_ONLINE[pack["uid"]] = 0
    --end
    MenjiroomView:showNetwork(uid,true)

   -- require("zhajinhua_jb.zjhSettings"):updateUserList()
    --require("zhajinhua_jb.zjhSettings"):resetUserInfo()
end

--自己离场
function ZjhHandle:SVR_QUIT(pack)
    dump("SVR_QUITgggggg")
    --require("zhajinhua_jb.ZhajinHuaServer"):enterRoom()
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
    --self:SVR_GET_ROOM_OK({})
    --if bm.Room.seatProgressTimer ~= nil then
    --    if bm.Room.seatProgressTimer:getParent() then
    --        bm.Room.seatProgressTimer:removeSelf()
    --    end
    --    bm.Room.seatProgressTimer = nil
    --end
    --
    -- --ZJH_USERINFO_TABLE[USER_INFO["uid"]] = nil
    --ZJH_USER_ONLINE[USER_INFO["uid"]] = 0
    --require("zhajinhua_jb.ZhajinHuaServer"):enterRoom()
   -- require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
    --require("zhajinhua_jb.zjhSettings"):updateUserList()
end



--广播台费
function ZjhHandle:SVR_BASE_BROADCAST(pack)
    --改变玩家金币
    dump(pack,"SVR_BASE_BROADCAST")
    --MenjiroomView:changeGold(pack)
end

--发牌
function ZjhHandle:SVR_SEND_CARD(pack)
    MenjiroomView:stopStartTimer()

    bm.User.Cards = MenjiroomView:sortOrder(pack.cards)
    --dump(bm.User.Cards,"bm.User.Cards")
    bm.User.card_type=pack.card_type
    --dump(pack,"SVR_SEND_CARD")
    if pack.lookCardStatus == 1 then
        if bm.Room.isCuoPai then
            local cards = {{pack.cards[1]},{pack.cards[2]}}
            MenjiroomView:setCards(USER_INFO.uid, cards)
            MenjiroomView:cuopaiTest(pack.cards)
        else
            MenjiroomView:setCards()
            MenjiroomView:showCardType(pack.card_type)
        end
    end
    --因为扎金花初始化房间得场次为1，所有这里加多一道逻辑  add by zzy 2019-7-17
    if not tolua.isnull(MenjiroomView.moreFuncLayer) then
        MenjiroomView.moreFuncLayer.btnDisbandRoom:setVisible(false) 
    end
    MenjiroomView.isHide = true

end


--广播开始
function ZjhHandle:SVR_START_BROADCAST(pack)
    dump(pack,"SVR_START_BROADCAST")
    MenjiroomView:clearBipai()
    bm.User.isKan = {}
    IS_ALLIN_CHIP = 0
    countUserAllin = pack.countUserAllin
    MenjiroomView:stopStartTimer()
    MenjiroomView:resetGame()
    local scenes  = SCENENOW["scene"]
    local account = scenes:getChildByName("accountScene")
    if account then
        account:removeSelf()
    end
    MenjiroomView:hideCardType()
    MenjiroomView:setBaseChip(pack["base"])
    ZJH_GAME_STATE = GAME_STATUS_OUTCARD
    --require("zhajinhua_jb.zjhSettings"):addGame()
    -- 初始化玩家下注
    isDiscard=false
    bm.Room.is_compare = true
    for k, v in pairs(ZJH_TABLE_CHIPS) do
        ZJH_TABLE_CHIPS[k] = 0
    end
    local uid  = ""
    local seat = pack.handle_seat
    bm.Room.now_zhu   = pack.base

    if MY_SEAT_ID == seat then
        uid  = USER_INFO["uid"]
    else
        uid  = ZJH_USER_SEAT[seat]
    end
    MenjiroomView:resetOperate(true)
    bm.Room.now_turns  = pack.now_turns
    bm.Room.min_pk = pack["min_pk_round"]
    bm.Room.min_allin = pack["min_allin_round"]
    bm.Room.zhus      = pack.zhus
    bm.Room.init_chips = pack["table_chips"]

    --删除准备的按钮
    for k,v in pairs(ZJH_USER_UID) do
        local node = MenjiroomView:getUserNode(k)
        if node ~= nil then
            local ready = node:getChildByName("ready_img")
            if ready then
                ready:removeSelf()
            end
        end

    end
    MenjiroomView:showShare(false)
    MenjiroomView:showChipsNowZhu(true)
    MenjiroomView:showControlButtons(false)
    MenjiroomView:showstartgame(false)
    MenjiroomView:showSitDownButton(false)
    --MenjiroomView:showBanker(pack["zhuang_seat"])
    MenjiroomView:showRoomInfo(pack)
    MenjiroomView:sendCard()
    --显示倒计时
    MenjiroomView:showStartTimer(pack.time)
    MenjiroomView:showProgressTimer(uid,pack.time)

    MenjiroomView:showRoomButton(uid, pack["can_compare"])
    MenjiroomView:showKuanNode(uid)
    --该我操作了
    if uid == USER_INFO["uid"] then


    else
        --弃牌
        --弃牌
        local qi_green = ZhaJinHuaPanel:getChildByName("base_foot")
        if qi_green then
            -- qi_green:setVisible(true)
            -- qi_green:setOpacity(255)
            -- qi_green:setEnabled(true)
        end

        --跟注
        --[[local gen_grey  = scenes:getChildByName("gen_grey")
        local gen_green = scenes:getChildByName("gen_green")
        gen_grey:setVisible(true)
        gen_green:setVisible(false)]]

        --加注
        --[[local jia_grey  = scenes:getChildByName("jia_grey")
        local jia_green = scenes:getChildByName("jia_green")
        jia_grey:setVisible(true)
        jia_green:setVisible(false)]]
    end

    for k,v in pairs(ZJH_USER_UID) do
        if ZJH_USER_UID_PLAYING[k] == 1 then
            MenjiroomView:diuChips(k,bm.Room.now_zhu)
            MenjiroomView:showNowZhu(k,bm.Room.now_zhu)
            ZJH_TABLE_CHIPS[k] = bm.Room.now_zhu
            --MenjiroomView:settingsGold(k,bm.Room.now_zhu)
        end
    end

    dump(pack.playersChips)
    for k,v in pairs(pack.playersChips) do
         MenjiroomView:updataUserGold(v.userId,v.m_chips)
    end

    -- 邀请好友
    MenjiroomView:showShare(false)
    local playerCount=pack['playerCount']

    if isOpenControl then
        for k, v in pairs(pack['players']) do
            local uid = ZJH_USER_SEAT[v['seatId']]
            if uid then
                local cards = MenjiroomView:sortOrder(v.cards)
                MenjiroomView:setCards(uid, cards)
                MenjiroomView:showCard(uid)
            end
        end
        local card_node = MenjiroomView:getCardPanel(USER_INFO["uid"])
        if card_node then
            --if isKanBtn then
                MenjiroomView:createKanPai(card_node)
            --end
        end
    end
end

--聊天相关
function ZjhHandle:SVR_MSG_FACE(pack)
    if ZhaJinHuaPanel ==nil then
        return
    end
    local faceUI = ZhaJinHuaPanel:getParent():getChildByName("faceUI")
    if faceUI == nil then
        print("scene:"..SCENENOW["name"],"not match faceUI")
        return
    end
    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end

    local index  = ZJH_PLAYERTYPE_TABLE[pack.uid]
    local sexT = 2
    local isLeft = false
    if MenjiroomView:getUserNode(pack["uid"]) == nil then
        return
    end
    local user_node = MenjiroomView:getUserNode(pack["uid"])
    local node_head = MenjiroomView:getHeadNode(user_node)

    --性别,头像位置
    if index == 0 then
        sexT = USER_INFO["sex"]

    else
        local othInfo = json.decode(ZJH_USERINFO_TABLE[pack.uid])
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
end

--组局排行榜
function ZjhHandle:SVR_GROUP_RANKING(pack)
    dump(pack,"组局结束")
    bm.Room.iswith = true
    if pack then
        MenjiroomView:onNetRanking2(pack)
    end

end
--组局时长
function ZjhHandle:SVR_GROUP_TIME(pack)
    if pack == nil then
        return
    end
    if bm.Room.GroupInfo == nil then
        bm.Room.GroupInfo = {}
    end
    bm.Room.GroupInfo["round"] = pack["round"]
    bm.Room.GroupInfo["round_total"] = pack["round_total"]

    dump(bm.Room.GroupInfo, "SVR_GROUP_TIME")
    if MenjiroomView then
        MenjiroomView:updateRounds(bm.Room.GroupInfo["round"], bm.Room.GroupInfo["round_total"])
    end

    --add by zzy 2019-7-17 游戏没有开始屏蔽解散房间
    print("======SVR_GROUP_TIME=====当前第几居数===",pack.round)
    SCENENOW["scene"].GameRound = pack.round

end
--组局解散相关
--没有此房间，解散房间失败
function ZjhHandle:G2H_CMD_DISSOLVE_FAILED(pack)

    dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")

    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")

end

-- --广播当前组局解散情况
-- function ZjhHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)

--     dump(pack, "-----广播当前组局解散情况-----")
--     dump(ZJH_USERINFO_TABLE, "-----广播当前房间情况-----")

--     local applyId = pack.applyId
--     local agreeNum = pack.agreeNum
--     local agreeMember_arr = pack.agreeMember_arr

--     local showMsg = ""

--     --申请解散者信息
--     local applyer_info = {}
--     if applyId == USER_INFO["uid"] then
--         showMsg =  "\n" .. "您申请解散房间，请等待其他玩家同意（超过5分钟未做选择，则默认同意）" .. "\n"
--     else
--         if bm.User ~= nil then
--             if ZJH_USERINFO_TABLE ~= nil then
--                 applyer_info = ZJH_USERINFO_TABLE[applyId]
--                 applyer_info = json.decode(applyer_info)
--                 dump(applyer_info, "-----广播当前房间情况applyer_info-----")
--                 if applyer_info ~= nil then
--                     local nickName = applyer_info["nickName"]
--                     if nickName ~= nil then
--                         showMsg = "\n" .. "玩家【" .. nickName .. "】申请解散房间，请等待其他玩家同意（超过5分钟未做选择，则默认同意）" .. "\n"
--                     end
--                 else
--                     showMsg = "\n" .. "玩家申请解散房间，请等待其他玩家同意（超过5分钟未做选择，则默认同意）" .. "\n"
--                 end
--             end
--         end
--     end

--     local isMyAgree = 0
--     if applyId ~= USER_INFO["uid"] then
--         --假如申请者不是自己，添加自己的选择情况
--         if agreeNum > 0 then
--             for k,v in pairs(agreeMember_arr) do
--                 if v == USER_INFO["uid"] then
--                     isMyAgree = 1
--                     break
--                 end
--             end
--         end
--         if isMyAgree == 1 then
--             showMsg = showMsg .. "  【我】已同意" .. "\n"
--         else
--             showMsg = showMsg .. "  【我】等待选择" .. "\n"
--         end
--     end

--     --显示其他人情况
--     if bm.User ~= nil then
--         if ZJH_USERINFO_TABLE ~= nil then
--             for k,v in pairs(ZJH_USERINFO_TABLE) do
--                 dump(v, "-----显示其他人情况-----")
--                 local uid = k
--                 --排除掉申请者，申请者不需要显示到这里
--                 if uid ~= applyId then

--                     --记录当前用户是否已经同意
--                     local isAgree = 0
--                     if agreeNum > 0 then
--                         for k,m in pairs(agreeMember_arr) do
--                             if uid == m then
--                                 --当前用户已经同意
--                                 isAgree = 1
--                                 break
--                             end
--                         end
--                     end

--                     --显示当前用户情况
--                     local user_data = json.decode(v)
--                     local nickName = user_data["nickName"]
--                     if nickName ~=nil then
--                         if isAgree == 1 then
--                             showMsg = showMsg .. "  【" .. nickName .. "】已同意" .. "\n"
--                         else
--                             showMsg = showMsg .. "  【" .. nickName .. "】等待选择" .. "\n"
--                         end
--                     end

--                 end
--             end
--         end
--     end

--     if applyId == USER_INFO["uid"] then
--         --假如申请者是自己，则直接显示其他用户的选择情况
--         require("hall.GameTips"):showDisbandTips("提示", "agree_disbandGroup", 4, showMsg)
--     else
--         --申请者不是自己，根据自己的同意情况进行界面显示
--         if isMyAgree == 1 then
--             require("hall.GameTips"):showDisbandTips("提示", "agree_disbandGroup", 4, showMsg)
--         else
--             require("hall.GameTips"):showDisbandTips("提示", "zjh_request_disbandGroup", 1, showMsg)
--         end
--     end


-- end

--广播当前组局解散情况
function ZjhHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)
	if g_isWatch == 0 then
		return
	end
   local function send_disband(agree)
        require("zhajinhua_jb.ZhajinHuaServer"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
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
            if ZJH_USERINFO_TABLE ~= nil then
                applyer_info = ZJH_USERINFO_TABLE[applyId]
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
         -- end
    end
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
            if ZJH_USERINFO_TABLE ~= nil then
                for k,v in pairs(ZJH_USERINFO_TABLE) do
                    local user_data = json.decode(v)
                    if k == USER_INFO["uid"] then
                        if user_data["photoUrl"] ~= nil then
                            myPlayer_table["icon"] = user_data["photoUrl"]
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
        if ZJH_USERINFO_TABLE ~= nil then
            for k,v in pairs(ZJH_USERINFO_TABLE) do
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

                        if user_data["photoUrl"] ~= nil then
                            player_table["icon"] = user_data["photoUrl"]
                        else
                            player_table["icon"] = ""
                        end

                        table.insert(disband_table, player_table)

                    end
                end
            end
        end
    --  end

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
function ZjhHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

    dump(pack, "-----广播桌子用户请求解散组局-----")

    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")

end

--广播桌子用户成功解散组局
function ZjhHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)


    bm.isDisbandSuccess = true

    -- require("hall.GameTips"):showDisbandTips("解散房间成功","ddz_disbandGroup_success",3)

end

--广播桌子用户解散组局 ，解散组局失败
function ZjhHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

    local rejectId = pack.rejectId
    if rejectId == USER_INFO["uid"] then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
    else
         -- if bm.User ~= nil then
            if ZJH_USERINFO_TABLE ~= nil then
                if ZJH_USERINFO_TABLE[rejectId] ~= nil then
                    local rejecter_info = ZJH_USERINFO_TABLE[rejectId]

                    require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, rejecter_info["nickName"] .. "拒绝解散房间")
                end
            end
         -- end
    end

end

function ZjhHandle:BROADCAST_USER_IP(pack)
    if pack == nil then
        return
    end
    local ip_list = {}
    for k, v in pairs(pack["playeripdata"]) do
        require("zhajinhua_jb.zjhSettings"):setUserIP(v["uid"], v["ip"])
        if v["uid"] == USER_INFO['uid'] then
            require("zhajinhua_jb.ZhajinHuaServer"):CLIENT_CMD_FORWARD_MESSAGE(v["ip"])
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
                if ZJH_USERINFO_TABLE and ZJH_USERINFO_TABLE[v["uid"]] and v["uid"] ~= USER_INFO["uid"] then
                    local nick = ZJH_USERINFO_TABLE[v["uid"]]

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
function ZjhHandle:CLI_MSG_FACE(id, msgType, to_uid)
    -- local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_MSG_FACE)
    -- :setParameter("type", id)
    -- :build()
    -- bm.server:send(sendpack)


    if not msgType then
        msgType = "emoji"
    end
    local data = {
        msgType = msgType,
        type = id,
        uid = USER_INFO["uid"],
        to_uid = to_uid,
    }
    local msg = json.encode(data)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_MSG_FACE)
                    :setParameter("level", USER_INFO["GroupLevel"])
                    :setParameter("msg", msg)
                    :build()
    bm.server:send(pack)
end

--广播开始游戏倒计时 100F
function ZjhHandle:SVR_BROADCAST_COUNT_DOWN(pack)

    dump(pack, "------广播开始游戏倒计时 100F------")
    if pack.time >0 then
        MenjiroomView:stopTimer(false)
        MenjiroomView:showStartTimer(pack.time)
    end
    --if  pack.time > 0 then
    --    SCENENOW["scene"]:showShareButton(false)
    --end

end
function ZjhHandle:SVR_ERROR(pack)
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
		if pack.errorCode == 18  or pack.errorCode == 5 then
			--require("hall.GameTips"):showTips("提示", "tohall", 1, tbErrorCode[pack.errorCode])
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
---------------------------------------------------------------------------------------------------------------------------------------------
--扣除台费 4800
function ZjhHandle:SVR_CHIP_CHANGE_BROADCAST(pack)
    dump(pack,"SVR_CHIP_CHANGE_BROADCAST")
    local  change_chip = 0
    for _,data in pairs(pack.userinfo) do

        local uid = data.uid
        if ZJH_USER_UID_PLAYING[uid] == 1 then
            --ZJH_USER_TOTAL_CHIPS[uid] = ZJH_USER_TOTAL_CHIPS[uid] + data.change_chip
            --MenjiroomView:settingsGold(uid,math.abs(data.change_chip))
            if  uid == USER_INFO["uid"] then
                MenjiroomView:showTaiFeiTips(data.change_chip)
            end
        end
    end
end
--5001
function ZjhHandle:BROADCAST_ERROR_TIPS(pack)

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
        [20] = "下注超过上限",
        [21] = "必须闷三圈看牌哦！",
    }
    dump(tbErrorCode[errorCode],"错误提示")
    if  errorCode == 18 then
        local scenes  = ZhaJinHuaPanel
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
            local paras = {}
            paras.type = 1
            paras.title = "提示"
            paras.content = tbErrorCode[errorCode] == nil and "未知的错误" or tbErrorCode[errorCode]
            require("hall.tips.CommonTips"):showTips(paras)
            --require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[errorCode])
        --else
        --    require("hall.GameTips"):showTips("提示", "", 3, "未知的错误")
        end
    end
end
function ZjhHandle:SVR_KAN_SHOW(pack)
    dump("SVR_KAN_SHOW",pack)
    for k,v in pairs(ZJH_USER_UID) do
        if ZJH_USER_UID_PLAYING[k] == 1 then
            local card_node = MenjiroomView:getCardPanel(k)
            if card_node ~= nil then
                if tonumber(k) == USER_INFO["uid"] and (bm.User.isKan[k] ==nil or bm.User.isKan[k] == 0) and bm.User.isDiu[k] == nil then
                    MenjiroomView:cpShow(true)
                    --isKanBtn=true
                    MenjiroomView:createKanPai(card_node)
                    MenjiroomView:isKanButton(true)
                end
            end
        end

    end

end


--接收服务器放回的指定用户信息pack111
function ZjhHandle:SVR_CHARGE_BROADCAST(pack)
    dump(pack,"pack111")
   
    local uid = pack.uid
    local playerType = ZJH_PLAYERTYPE_TABLE[uid]
    local userInfo = ZJH_USERINFO_TABLE[uid]
    if not (playerType and userInfo) then return end
    userInfo.m_chips = userInfo.m_chips + pack.chargeCoins
    MenjiroomView:updataUserGold(uid, userInfo.m_chips)

end

--回看
function ZjhHandle:SERVER_COMMAND_GAMERESULT_RECORD(pack)
    dump(pack,"SERVER_COMMAND_GAMERESULT_RECORD")
    if #pack.gameResult == 0 then
        viewMgr:showTip({text = "无当前所选局数回看！"})
        return
    end

    local Card = require("zhajinhua_jb.common.PokerCard")

    for i,userInfo in ipairs(pack.gameResult) do
        for idx,value in ipairs(userInfo.cards) do
            local cardNode = Card.new()
            cardNode:setCard(value)
            cardNode:showFront() 
            pack.gameResult[i].cards[idx] = cardNode
        end
        
        pack.gameResult[i].xiazhu = pack.gameResult[i].xiazhu / 100
        local cardKind_imgPath = "zhajinhua_jb/res/NewImg/"..userInfo.cardType..".png"
        pack.gameResult[i].cardType = cardKind_imgPath
        pack.gameResult[i].cardType_plist = 0 --1是plist 0不是
    end
    
    local CardsRoundRecord = ZhaJinHuaPanel:getChildByName("CardsRoundRecord")
    if CardsRoundRecord then
        CardsRoundRecord:setData(pack)
    else
        local ZhajinHuaServer = require("zhajinhua_jb.ZhajinHuaServer")
        local CardsRoundRecord = require("hall.common.CardsRoundRecord").new(pack)
        CardsRoundRecord:setName("CardsRoundRecord")
        CardsRoundRecord:setHandler(handler(ZhajinHuaServer, ZhajinHuaServer.CLI_COMMAND_GAMERESULT_RECORD))
        local zidx = ViewBase:getZOrderByChilds(ZhaJinHuaPanel)
        CardsRoundRecord:addTo(ZhaJinHuaPanel, zidx)
    end
end

return ZjhHandle