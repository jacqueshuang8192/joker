require("framework.init")
local hallHandle = require("hall.HallHandle")
local ddzHandle = class("ddzHandle",hallHandle)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local PROTOCOL = import("TaiHeGuoZha.ddz_PROTOCOL")
local ddzServer = import("TaiHeGuoZha.ddzServer")
local ddzSettings = require("TaiHeGuoZha.ddzSettings")

local GamePlaneOperator = require("TaiHeGuoZha.operator.GamePlaneOperator")
local CardPlaneOperator = require("TaiHeGuoZha.operator.CardPlaneOperator")
local ControlPlaneOperator = require("TaiHeGuoZha.operator.ControlPlaneOperator")

local Card = require("TaiHeGuoZha.Card")
local unpack = table.unpack or unpack
local CardAnalysis, CARDTYPE = unpack(require("TaiHeGuoZha.CardAnalysis"))

function ddzHandle:ctor()
    ddzHandle.super.ctor(self);
    local func_ = {
        --登陆房间成功返回
        [PROTOCOL.SVR_LOGIN_ROOM_OK] = {handler(self, ddzHandle.SVR_LOGIN_ROOM_OK), ""},
        [PROTOCOL.SVR_KICK_OFF] = {handler(self, ddzHandle.SVR_KICK_OFF)},
        [PROTOCOL.SVR_READY_GAME] = {handler(self, ddzHandle.SVR_READY_GAME), ""},
        [PROTOCOL.SVR_DEAL] = {handler(self, ddzHandle.SVR_DEAL), ""},
        --其他用户进入房间广播
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, ddzHandle.SVR_LOGIN_ROOM_BROADCAST), ""},
        --[PROTOCOL.SVR_LOGOUT_ROOM_OK] = {handler(self, ddzHandle.SVR_LOGOUT_ROOM_OK), ""},
        [PROTOCOL.SVR_LOGOUT_ROOM] = {handler(self, ddzHandle.SVR_LOGOUT_ROOM), ""},
        --用户重连进房间返回
        [PROTOCOL.SVR_RELOAD_ROOM] = {handler(self, ddzHandle.SVR_RELOAD_ROOM), ""},
        --[PROTOCOL.SVR_GAME_START] = {handler(self, ddzHandle.SVR_GAME_START), ""},

        [PROTOCOL.SVR_QUICK_SUC] = {handler(self, ddzHandle.SVR_QUICK_SUC), ""},
        --[PROTOCOL.SVR_BROADCAST_DOUBLE] = {handler(self, ddzHandle.SVR_BROADCAST_DOUBLE), ""},

        --[PROTOCOL.SVR_CUR_OUT_PLAYER] = {handler(self, ddzHandle.SVR_CUR_OUT_PLAYER), ""},
        [PROTOCOL.SERVER_BROADCAST_BEGIN_OUT] = {handler(self, ddzHandle.SERVER_BROADCAST_BEGIN_OUT), ""},
        [PROTOCOL.SERVER_BROADCAST_USER_FEN] = {handler(self, ddzHandle.SERVER_BROADCAST_USER_FEN), ""},
        [PROTOCOL.SERVER_BROADCAST_USER_JIANG] = {handler(self, ddzHandle.SERVER_BROADCAST_USER_JIANG), ""},
        [PROTOCOL.SVR_PLAY_CARD] = {handler(self, ddzHandle.SVR_PLAY_CARD), ""},
        [PROTOCOL.SVR_PASS] = {handler(self, ddzHandle.SVR_PASS), ""},
        [PROTOCOL.SVR_GAME_OVER] = {handler(self, ddzHandle.SVR_GAME_OVER), ""},
        [PROTOCOL.SVR_GAME_OVER_TOTAL] = {handler(self, ddzHandle.SVR_GAME_OVER_TOTAL), ""},
        [PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, ddzHandle.SVR_GROUP_BILLBOARD), ""},
        [PROTOCOL.SVR_GROUP_TIME] = {handler(self, ddzHandle.SVR_GROUP_TIME), ""},
        [PROTOCOL.SVR_MSG_FACE] = {handler(self, ddzHandle.SVR_MSG_FACE), ""},
        [PROTOCOL.SERVER_BROADCAST_MORE_OPT] = {handler(self, ddzHandle.SERVER_BROADCAST_MORE_OPT), ""},
        [PROTOCOL.SVR_RESET_USER_SEAT] = {handler(self, ddzHandle.SVR_RESET_USER_SEAT), ""},
        --1031玩家坐下
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, ddzHandle.BROADCAST_USER_SIT_DOWN), ""},
        --1032玩家站起
        [PROTOCOL.BROADCAST_USER_STAND_UP] = {handler(self, ddzHandle.BROADCAST_USER_STAND_UP), ""},
        --1033玩家离开房间
        [PROTOCOL.SVR_BROADCAST_USER_LEAVEROOM] = {handler(self, ddzHandle.SVR_BROADCAST_USER_LEAVEROOM), ""},
        --错误提示5001
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, ddzHandle.BROADCAST_ERROR_TIPS)},
        [PROTOCOL.SVR_LOGIN_ROOM_FAIL] = {handler(self, ddzHandle.SVR_LOGIN_ROOM_FAIL)},
        [PROTOCOL.SVR_CHIP_CHANGE_BROADCAST] = {handler(self, ddzHandle.SVR_CHIP_CHANGE_BROADCAST)},
        [PROTOCOL.SVR_CHARGE_BROADCAST] = {handler(self, ddzHandle.SVR_CHARGE_BROADCAST)},
        --没有此房间，解散房间失败
        [PROTOCOL.G2H_CMD_DISSOLVE_FAILED] = {handler(self, ddzHandle.G2H_CMD_DISSOLVE_FAILED)},
        --广播桌子用户请求解散组局
        [PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {handler(self, ddzHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
        --广播当前组局解散情况
        [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST] = {handler(self, ddzHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
        --广播桌子用户成功解散组局
        [PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP] = {handler(self, ddzHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
        --广播桌子用户解散组局 ，解散组局失败
        [PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP] = {handler(self, ddzHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},
        --接收服务器返回的缓存信息
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, ddzHandle.SERVER_CMD_FORWARD_MESSAGE)},
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, ddzHandle.SERVER_CMD_MESSAGE), ""},
        [PROTOCOL.SVR_BROADCAST_BONUS] = {handler(self, ddzHandle.SVR_BROADCAST_BONUS), ""},
        --[PROTOCOL.SVR_REMIND_CHOOSETEAM]={handler(self, ddzHandle.SVR_REMIND_CHOOSETEAM), ""},
        --[PROTOCOL.SVR_TEAM_RESULT]={handler(self, ddzHandle.SVR_TEAM_RESULT), ""},
        --[PROTOCOL.SVR_CHOOSETEAM_END]={handler(self, ddzHandle.SVR_CHOOSETEAM_END), ""},

        --[PROTOCOL.SVR_BROADCAST_USER_GETZHUASCORE]={handler(self, ddzHandle.SVR_BROADCAST_USER_GETZHUASCORE), ""},
        --[PROTOCOL.SVR_SEND_PARTNER_CARDS]={handler(self, ddzHandle.SVR_SEND_PARTNER_CARDS), ""},
        [PROTOCOL.SVR_REFRESH_MONEY] = {handler(self, ddzHandle.SVR_REFRESH_MONEY), ""},
        [PROTOCOL.SERVER_COMMAND_GET_CARD] = {handler(self, ddzHandle.SERVER_COMMAND_GET_CARD)},
        [PROTOCOL.SERVER_COMMAND_GET_HANDLER_CARD] = {handler(self, ddzHandle.SERVER_COMMAND_GET_HANDLER_CARD)},
        
    }
    table.merge(self.func_, func_)
end

function ddzHandle:callFunc(pack)
    --dump1(pack.cmd, "当前游戏解析协议号")

    if SCENENOW["name"] ~= "TaiHeGuoZha.gameScene" then
        -- return
    end

    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

---------------------------------------房间相关-------------------------------
--5001
function ddzHandle:BROADCAST_ERROR_TIPS(pack)
    --1dump(pack, "-----返回错误提示5001-----")

    local errorCode = pack.errorCode

    local tbErrorCode = {
        [1] = "出牌错误!",
        [10] = "游戏进行中",
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
        [22] = "您在座位上时不能坐庄！"
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
                    SCENENOW["scene"]:requestCharge()
                    return
                end
            end,
            1.5
        )
    end

    ----1dump1(tbErrorCode[errorCode], "错误提示")
    if errorCode == 1 then
        viewMgr:showTip({text = tbErrorCode[errorCode]})
        return
    end
    if tbErrorCode[errorCode] then
        require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[errorCode])
    else
        require("hall.GameTips"):showTips("提示", "", 3, "未知的错误")
    end
end

--进入房间失败 1005
function ddzHandle:SVR_LOGIN_ROOM_FAIL(pack)
    ----1dump1(pack, "-----进入房间失败-----")

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
            --require("hall.GameTips"):showTips("提示", "tohall", 3, tbErrorCode[pack.errorCode])
            -- elseif  pack.errorCode == 7 or pack.errorCode == 5 then

            local exitFunc = function()
                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
            end

            require("hall.GameTips"):showTips("提示", "", 2, tbErrorCode[pack.errorCode], nil, exitFunc)
        else
            require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[pack.errorCode])
        end
    else
        require("hall.GameTips"):showTips("提示", "", 3, "未知的错误")
    end
end

--广播自己退出 1008
function ddzHandle:SVR_QUICK_SUC(pack)
    --SCENENOW["scene"]:reConnect()
    dump(USER_INFO["tid"],"USER_INFO[tid]")
    dump(USER_INFO["activity_id"],"USER_INFO[activity_id]")
    dump(USER_INFO["GroupLevel"],"USER_INFO[GroupLevel]")
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end

--其他用户进入房间 100D
function ddzHandle:SVR_LOGIN_ROOM_BROADCAST(pack)
    dump(pack, "其他用户进入房间")
    -- self:showPlayer(pack)
    ddzSettings:collectPlayerData(pack)
    local longtitude = pack.longitude
    local latitude = pack.latitude
    dump(longtitude, "longtitude ====== ")
    dump(latitude, "latitude ====== ")

    if THGZ_SEAT_TABLE then
        local seat = THGZ_SEAT_TABLE[pack["uid"]]
        ----1dump1(THGZ_SEAT_TABLE, "100D_USERID2SEAT")
        local playerType = ddzSettings:getPlayerType(seat)

        if playerType then
            GamePlaneOperator:showNetworkImg(playerType, false)
            require("hall.GameCommon"):playEffectSound("TaiHeGuoZha/res/audio/login_notice.mp3")
        end
    end
    --gps显示
    SCENENOW["scene"]:showGPSButton()
end

--进入房间 1007
function ddzHandle:SVR_LOGIN_ROOM_OK(pack)
    require(NetworkLoadingView_filePath):removeView(888)
    ----1dump1(pack, "SVR_LOGIN_ROOM_OK")
    _G.TaiHeGuoZhaRoomInfo = json.decode(pack.Config)
    if TaiHeGuoZhaRoomInfo["escrow_time"] == 0  then
        THGZ_IS_mAI = true
    else
        THGZ_IS_mAI = false
    end
    --1dump(json.decode(pack.Config), "json.decode(pack.Config) ====== ")
    --HAS_RECEIVE_GROUP_RESULT = false
    GAME_STATE = STATUS_STOP
    --PLAY_MODE = pack.playMode
    isGoldGame = 1 --pack.Tabletype
    CLUB_ID =  pack.clubId
    local txt_jianfen = cardScene:getChildByName("txt_jianfen")
    txt_jianfen:setVisible(false)
    dump(TaiHeGuoZhaRoomInfo, "TaiHeGuoZhaRoomInfo")
    for i = 1, 4 do
        local playerPlane = cardScene:getChildByName("touxiangbufen_" .. i)
        local toujiangflag = playerPlane:getChildByName("toujiangflag")
        toujiangflag:setVisible(false)
    end

    for i, data in ipairs(pack["playerlist"]) do
        ddzSettings:collectPlayerData(data)
        USERS_READY_STATE[data.uid] = data["if_ready"]
    end
    HEART_BEAT_TID = USER_INFO["tid"]

    MY_SEAT_ID = pack["SeatID"]

    if MY_SEAT_ID >= 0 then
        if USERS_READY_STATE[USER_INFO["uid"]] ~= 1 then
            ControlPlaneOperator:showControlButtons(1)
        end
        SCENENOW["scene"]:showButtonAfterSitDown(true)
    else
    end

    --USER_INFO["activity_id"] = pack.activity_id
    USER_INFO["invote_code"] = pack.InviteCode

    --设置底分
    GamePlaneOperator:setBaseChip(pack["BaseChip"])

    for i, data in ipairs(pack["playerlist"]) do
        if data["seat_id"] >= 0 then
            ddzSettings:showPlayer(data["uid"], data["seat_id"])
        end
    end

    SCENENOW["scene"]:setRoomId(pack.InviteCode)

    --按钮遮挡层
    local separation_layer = SCENENOW["scene"]._scene:getChildByName("separation_layer")
    for k, v in pairs(TaiHeGuoZhaRoomInfo) do
        if k == "escrow_time" then
            if v == 5 then
                separation_layer:setVisible(false)
            elseif v == 0 then
                THGZ_IS_mAI = true
                separation_layer:setVisible(true)
            end
        end
    end

    --print(GAME_NAME, USER_INFO["gameConfig"])
    local remark_lb = SCENENOW["scene"]._scene:getChildByName("remark_lb")
    local s = ""
    for k, v in pairs(TaiHeGuoZhaRoomInfo) do
        if k == "maxSeatCount" then
            s = s .. v + v / 2 .. "副牌"
        elseif k == "add_joker" then
            s = s .. " 加" .. v .. "王"
        elseif k == "escrow_time" then
            s = s .. (v == 5 and " 托管5秒" or " 全托")
        end
    end
    remark_lb:setString(s)
    --gps显示
    SCENENOW["scene"]:showGPSButton()
end

--服务器广播玩家退出 100E
function ddzHandle:SVR_LOGOUT_ROOM(pack)
    ----1dump1(pack, "玩家退出房间")
    local seat = THGZ_SEAT_TABLE[pack["Uid"]]
    local playerType = ddzSettings:getPlayerType(seat)
    if playerType then
        GamePlaneOperator:showNetworkImg(playerType, true) --显示掉线
    end
end

--广播用户坐下 1031   其他用户进入房间
function ddzHandle:BROADCAST_USER_SIT_DOWN(pack)
    local uid = pack.uid
    local seat_id = pack.seat_id
    THGZ_SEAT_TABLE[uid] = seat_id --保存用户座位与id映射

    if USER_INFO["uid"] == uid then --自己坐下的话重新排版布局
        --游戏过程中加入不会重定位
        SCENENOW["scene"]:showButtonAfterSitDown(true)

        --重定位逻辑
        MY_SEAT_ID = seat_id

        if GAME_STATE == STATUS_STOP then --游戏前加入重定位
            for k, v in pairs(TaiHeGuoZhaRoomInfo) do
                if k == "escrow_time" then
                    if v == 5 then
                        ControlPlaneOperator:showControlButtons(1)
                    elseif v == 0 then
                        ControlPlaneOperator:showControlButtons(1, false)
                    end
                end
            end
            GamePlaneOperator:clearGameDatas(2)
            ddzSettings:relocatePlayer()
        else
            local seat_id = MY_SEAT_ID
            if seat_id >= 0 then
                local userInfo = THGZ_USERINFO_TABLE[uid]
                local user_if_outline = false --用户是否掉线
                ddzSettings:showPlayer(uid, seat_id, userInfo, user_if_outline)
            end
        end
    else --其他人坐下的话只给他画头像信息
        ddzSettings:collectPlayerData(pack)
        if seat_id >= 0 then
            local userInfo = THGZ_USERINFO_TABLE[uid]
            local user_if_outline = false
            ddzSettings:showPlayer(uid, seat_id, userInfo, user_if_outline)
        end
    end
    --gps显示
    SCENENOW["scene"]:showGPSButton()
end

--广播玩家站起 1032
function ddzHandle:BROADCAST_USER_STAND_UP(pack)
    ----1dump1(pack, "------广播玩家站起1032------")

    local uid = pack.uid
    local seat_id = THGZ_SEAT_TABLE[uid]
    local playerType = ddzSettings:getPlayerType(seat_id)

    if playerType then
        GamePlaneOperator:removePlayer(playerType)
    end

    -- DDZ_PLAYERTYPE_TABLE[pack.uid] = nil
    -- NIUNIU_UID_TABLE[seat_id] = nil
    THGZ_SEAT_TABLE[pack.uid] = -2

    if uid == USER_INFO["uid"] then
        ControlPlaneOperator:showControlButtons(1, false)

        SCENENOW["scene"]:showButtonAfterSitDown(false)
        MY_SEAT_ID = -1
    elseif MY_SEAT_ID < 0 then --别人站起，自己也站着的时候
    end
end

--isGoldGame  0金币场
--1033
function ddzHandle:SVR_BROADCAST_USER_LEAVEROOM(pack)
    ----1dump1(pack, "玩家退出房间")

    local uid = pack.uid
    local seat = THGZ_SEAT_TABLE[uid]
    local playerType = ddzSettings:getPlayerType(seat)
    print("SVR_BROADCAST_USER_LEAVEROOM", playerType, uid, USER_INFO["uid"], isGoldGame, HAS_RECEIVE_GROUP_RESULT)
    if playerType then
        GamePlaneOperator:removePlayer(playerType) --显示掉线
    end

    -- DDZ_PLAYERTYPE_TABLE[pack.uid] = nil
    USERS_READY_STATE[pack.uid] = nil
    THGZ_SEAT_TABLE[pack.uid] = nil

    if require("hall.view.userInfoView.userInfoView").upDateUserInfo then
        require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid, {}, "reset")
    end

    print("SVR_BROADCAST_USER_LEAVEROOM", isGoldGame, uid == USER_INFO["uid"])

    --处理自己退出
    if uid == USER_INFO["uid"] then
        if isGoldGame == 0 or (isGoldGame == 1 and HAS_RECEIVE_GROUP_RESULT ~= true) then
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
            HEART_BEAT_TID = 0
        end
    end

    --gps显示
    --SCENENOW["scene"]:showGPSButton()
end

----玩家进入私人房 0212
--function ddzHandle:SVR_ENTER_PRIVATE_ROOM(pack)
--    -- require("hall.GameTips"):showTips("您被卡在私人房中,请联系客服处理")
--    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
--end

--客户端被踢
function ddzHandle:SVR_KICK_OFF(pack)
    require("hall.GameTips"):showTips("您被请出游戏", "kick_off")
end

----服务器返回自己退出
--function ddzHandle:SVR_LOGOUT_ROOM_OK(pack)
--    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
--end

--玩家重登，进入游戏 1009
function ddzHandle:SVR_RELOAD_ROOM(pack)
    dump(pack,"玩家重登，进入游戏 1009")
    local baseChip = pack.baseChip
    require(NetworkLoadingView_filePath):removeView(888)
    _G.TaiHeGuoZhaRoomInfo = json.decode(pack.configStr)
    HEART_BEAT_TID = USER_INFO["tid"]
    GAME_STATE = pack.gameStatus
    isGoldGame = 1
    USER_INFO["invote_code"] = pack.inviteCode
    CLUB_ID = pack.clubId
    --显示剩余分
    local room_lb_plane = cardScene:getChildByName("room_lb_plane"):setVisible(true)
    local shengyufen_txt = room_lb_plane:getChildByName("shengyufen_txt")
    local tempNum = pack.shengyuFen
    shengyufen_txt:setString("" .. tempNum)
    -- for _, data in ipairs(pack["userScores"]) do
    --     -- 显示奖分
    --     dump(data.rewardScore, "--------rewardScore---------")
    --     dump(data.pickScore, "--------pickScore---------")

    --     for i = 0, pack.Playercount - 1 do
    --         GamePlaneOperator:updateJiang(ddzSettings:getPlayerType(i), data.rewardScore[i + 1])
    --     end

    --     --显示捡分
    --     for i = 0, pack.Playercount - 1 do
    --         GamePlaneOperator:updateFen(ddzSettings:getPlayerType(i), data.pickScore[i + 1])
    --     end
    -- end

    --按钮遮挡层
    local separation_layer = SCENENOW["scene"]._scene:getChildByName("separation_layer")
    for k, v in pairs(TaiHeGuoZhaRoomInfo) do
        if k == "escrow_time" then
            if v == 5 then
                separation_layer:setVisible(false)
            elseif v == 0 then
                separation_layer:setVisible(true)
            end
        end
    end

    --显示桌面分
    local tableFen = pack.txtFen
    GamePlaneOperator:updatetxtFen(ddzSettings:getPlayerType(), tableFen, true)

    --显示头奖Flag
    local JokerPlayerType = ddzSettings:getPlayerType(TouJiangFLAG)

    --设置底分和倍数
    GamePlaneOperator:setBaseChip(pack["baseChip"])

    local stop_state = GAME_STATE == STATUS_STOP

    CALLASSCARD = pack.assCard
    dump(pack["cards"],"gggggggggggggggggggggggg")
    --数据
    for _, data in ipairs(pack["playerlist"]) do
        ddzSettings:collectPlayerData(data)

        local uid = data.uid

        local seat_id = data["seatID"]
        USERS_READY_STATE[uid] = data["if_ready"]
        if not stop_state then

            REMAINCARDS[seat_id] = data["handCardCount"]
        end

        if uid == USER_INFO["uid"] then
            --设置玩家座位
            MY_SEAT_ID = seat_id
            if MY_SEAT_ID >= 0 then
                SCENENOW["scene"]:showButtonAfterSitDown(true)
            end
        end
    end

    for i, data in ipairs(pack["playerlist"]) do
        local seat_id = data["seatID"]
        local uid = data["uid"]

        if seat_id >= 0 then
            ddzSettings:showPlayer(uid, seat_id)
            if not stop_state then
                local HandCardCount = data["HandCardCount"] or 0
                local playerType = ddzSettings:getPlayerType(seat_id)
                local sex = THGZ_USERINFO_TABLE[uid].sex
                local flag = seat_id == pack.bankerUser and true or false
                local flag = seat_id == pack.jokerpos and true or false
                GamePlaneOperator:showLandLord(playerType, flag, true) --庄家
                --GamePlaneOperator:updateJoker(playerType, flag, true)--头奖玩家
                GamePlaneOperator:setRestCardNum(playerType, HandCardCount, sex, true)
            end
        end
    end

    local hide_state = false
    for i, data in ipairs(pack["playerlist"]) do
        local uid = data["uid"]
        if tonumber(USER_INFO["uid"]) == tonumber(data["uid"]) and 1 == data["if_ready"] then
            GamePlaneOperator:setReadyStatus(1, true)
            ControlPlaneOperator:showControlButtons(1, false)
            hide_state = true
            break
        end
    end

    for k, v in pairs(TaiHeGuoZhaRoomInfo) do
        if k == "escrow_time" then
            if v == 5 then
                if not hide_state then
                    ControlPlaneOperator:showControlButtons(1)
                end
            elseif v == 0 then
                if not hide_state then
                    ControlPlaneOperator:showControlButtons(1, false)
                end
            end
        end
    end
    ---------------------------------------------


    local nseat = pack["currentUser"] --当前出牌玩家座位号

    local turnwiner = pack["turnwiner"]
    local winPlayerType = ddzSettings:getPlayerType(turnwiner)

    --玩家剩余牌数
    CardPlaneOperator:updateSendCard(pack["handcarddatas"])
    _G.PartnerCards = pack.handcarddatas
    --隐藏邀请好友按钮
    SCENENOW["scene"]:showShareButton(false)

    if not stop_state then
        GamePlaneOperator:clearAllReadyStatus()
    end

    print("GAME_STATE-----", GAME_STATE)
    if GAME_STATE == STATUS_STOP then
        SCENENOW["scene"]:initData("clearGameData")
    elseif GAME_STATE == STATUS_LAND_CALLASS then
        for k, v in pairs(TaiHeGuoZhaRoomInfo) do
            if k == "escrow_time" then
                if v == 5 then
                    if pack.currentUser == MY_SEAT_ID then
                        ControlPlaneOperator:showControlButtons(4, true, 0, 1)
                    end
                elseif v == 0 then
                    if  pack.currentUser == MY_SEAT_ID then
                        ControlPlaneOperator:showControlButtons(4, false)
                    end
                end
            end
        end
    elseif GAME_STATE == STATUS_PLAY then
        for k, v in pairs(TaiHeGuoZhaRoomInfo) do
            if k == "escrow_time" then
                if v == 5 then
                    if nseat == MY_SEAT_ID then
                        if pack.turnCardType == CARDTYPE.CT_ERROR then
                            ControlPlaneOperator:showControlButtons(4, true, 0, 1)
                        else
                            ControlPlaneOperator:showControlButtons(4, true, 0, 1)
                        end
                    else
                        ControlPlaneOperator:showControlButtons(4, false)
                    end
                elseif v == 0 then
                    if nseat == MY_SEAT_ID then
                        ControlPlaneOperator:showControlButtons(4, false)
                    end
                end
            end
        end
       
    end
    local c_table = {}
    local c = Card.new()
    for i, v in ipairs(pack["cards"]) do
        c:init(v)
        table.insert(c_table, {c._value, c._kind})
    end
    if #pack.cards >= 1 then
        tbPlayCardInfo.last_cards = pack.cards
    end
    local tm_table = CardPlaneOperator:showOtherCardRank(c_table)
    --CardPlaneOperator:clearOutCards(playerType)
    if pack.outCardSeatID > -1 then
        CardPlaneOperator:showOutCard(tm_table, pack.outCardSeatID)
    end

    --gps显示
    SCENENOW["scene"]:showGPSButton()
end

------------------------------------游戏逻辑相关---------------------------
--游戏准备返回 6001
function ddzHandle:SVR_READY_GAME(pack)
    dump(pack, "游戏准备返回--------6001---------")

    local seatId = THGZ_SEAT_TABLE[pack["uid"]]
    local playerType = ddzSettings:getPlayerType(seatId)

    local readyState = pack.readyState --1是准备，0是取消准备

    if playerType then
        GamePlaneOperator:setReadyStatus(playerType, not readyState == 0)
    end

    USERS_READY_STATE[pack.uid] = readyState == 0 and 0 or 1

    if pack["uid"] == USER_INFO["uid"] then
        ControlPlaneOperator:showControlButtons(1, false)
        require("hall.GameCommon"):playEffectSound("TaiHeGuoZha/res/audio/on_turn.mp3")
    end
end

--手动叫边
function ddzHandle:SVR_CALL_ASS(pack)
    if pack.seatID == MY_SEAT_ID then
        ControlPlaneOperator:showControlButtons(4, true)
    end
    GamePlaneOperator:beginPlayCard(ddzSettings:getPlayerType(pack.seatID), OUT_CARD_TIMEOUT)
end

--游戏开始，发牌
function ddzHandle:SVR_DEAL(pack)
    GAME_STATE = STATUS_LAND_CALLASS
    dump(pack, "-----游戏开始发牌--------")
    local singleLayer = SCENENOW["scene"]:getChildByName("singleResultLayer")
    if singleLayer then
        singleLayer:removeSelf()
    end

    if DDZ_ROUND == 1 then
        ddzSettings:relocatePlayer()--重新处理下头像位置，
    end
    GamePlaneOperator:clearGameDatas()
    GamePlaneOperator:clearAllReadyStatus()

    --隐藏邀请好友按钮
    SCENENOW["scene"]:showShareButton(false)

    ControlPlaneOperator:showControlButtons(2, false)

    --1dump(THGZ_SEAT_TABLE, "-----游戏开始--------")
    LandLordSeatId = pack.bankUserSeatID

    PartnerCards = pack.HandCardDatas
    CardPlaneOperator:updateSendCard(PartnerCards)
    --Card:sortCard()

    for seatId = 0, TaiHeGuoZhaRoomInfo.maxSeatCount do
        REMAINCARDS[seatId] = pack.Cardcount
        local playerType = ddzSettings:getPlayerType(seatId)
        GamePlaneOperator:setRestCardNum(playerType, pack.Cardcount, nil, true)
    end

    local seat = pack.seatID

    local bankerPlayerType = ddzSettings:getPlayerType(LandLordSeatId)

    GamePlaneOperator:showLandLord(bankerPlayerType, "Banker", true)

    tbPlayCardInfo["owner"] = pack.currentSeatID
    for k, v in pairs(TaiHeGuoZhaRoomInfo) do
        if k == "escrow_time" then
            if v == 5 then
                if pack.currentSeatID == MY_SEAT_ID then
                    ControlPlaneOperator:showControlButtons(4, true, 0, 1)
                end
            elseif v == 0 then
                if pack.currentSeatID == MY_SEAT_ID then
                    ControlPlaneOperator:showControlButtons(4, false)
                end
            end
        end
    end
end

function ddzHandle:SERVER_COMMAND_GET_HANDLER_CARD( pack )
    dump(pack, "SERVER_COMMAND_GET_HANDLER_CARD == ")
    CardPlaneOperator:updateSendCard(pack.cards)
end

--玩家开始出牌
function ddzHandle:SERVER_BROADCAST_BEGIN_OUT(pack)
    local seat = pack["currentUser"]
    --当前叫牌的座位
    print(MY_SEAT_ID, seat)
    for k, v in pairs(TaiHeGuoZhaRoomInfo) do
        if k == "escrow_time" then
            if v == 5 then
                if seat == MY_SEAT_ID then
                    ControlPlaneOperator:showControlButtons(4, true, 0, 1)
                end
            elseif v == 0 then
                if seat == MY_SEAT_ID then
                    ControlPlaneOperator:showControlButtons(4, false)
                end
            end
        end
    end

    GAME_STATE = STATUS_PLAY

    GamePlaneOperator:beginPlayCard(ddzSettings:getPlayerType(seat), OUT_CARD_TIMEOUT)
end

--更新玩家的奖分 0x1206
function ddzHandle:SERVER_BROADCAST_USER_JIANG(pack)
    dump(pack.Jiang, "--------pack.Jiang-------")
    for i = 0, pack.playercount - 1 do -- 奖值
        GamePlaneOperator:updateJiang(ddzSettings:getPlayerType(i), pack.Jiang[i + 1])
    end
    TouJiangFLAG = pack.jokerpos
end

--更新玩家的捡分 0x1205
function ddzHandle:SERVER_BROADCAST_USER_FEN(pack)
    for i = 0, pack.playercount - 1 do
        GamePlaneOperator:updateFen(ddzSettings:getPlayerType(i), pack.Fen[i + 1])
    end
end

function ddzHandle:SVR_PLAY_CARD(pack) -- 0x1201
    ControlPlaneOperator:showControlButtons(4, false)
    dump(pack, "SVR_PLAY_CARD")
    ControlPlaneOperator:showControlButtons(2, false) --为了解决起手地主无炸自动出牌导致叫地主按钮没消的问题

    local seat = pack["outCardSeatID"]
    --当前出牌的座位
    local nextUser = pack["nextUser"]
    --下一个出牌玩家
    local playerType = ddzSettings:getPlayerType(seat)

    REMAINCARDS[seat] = REMAINCARDS[seat] - pack["cardcount"] --当前出牌玩家剩余牌数
    CHUPAIDESHULIANG = pack.cardcount

    local cardtype = pack["cardType"]

    --显示头奖Flag
    local JokerPlayerType = ddzSettings:getPlayerType(TouJiangFLAG)

    if TouJiangFLAG ~= -1 and TouJiangFLAG ~= nil then
        GamePlaneOperator:updateJoker(JokerPlayerType, "Joker", true)
    end
    --显示桌面分
    local tableFen = pack.txtFen
    GamePlaneOperator:updatetxtFen(ddzSettings:getPlayerType(), tableFen, true)

    --显示剩余分
    local room_lb_plane = cardScene:getChildByName("room_lb_plane"):setVisible(true)
    local shengyufen_txt = room_lb_plane:getChildByName("shengyufen_txt")
    local tempNum = pack.shengyuFen
    shengyufen_txt:setString("" .. tempNum)

    local c_table = {}
    local c = Card.new()
    for i, v in ipairs(pack["cards"]) do
        c:init(v)
        table.insert(c_table, {c._value, c._kind})
    end
    local tm_table = CardPlaneOperator:showOtherCardRank(c_table)

    print(seat, MY_SEAT_ID, "SVR_PLAY_CARD")

    --给玩家出牌表赋值
    if #pack.cards >= 1 then
        tbPlayCardInfo.last_cards = pack.cards
    end
   
    local h = nil

    if TaiHeGuoZhaRoomInfo["escrow_time"] == 5 then
        if seat == MY_SEAT_ID then
            local cards = pack.cards
            table.sort(cards,function( a,b )
                return a > b
            end)
            local value, kind = Card:init(cards[1])
            CardPlaneOperator:popCard(value)
            ControlPlaneOperator:showControlButtons(4, true, 0, 1)
            h=scheduler.performWithDelayGlobal(function()
                CardPlaneOperator:reduceCard(pack.cards)
            end, 0.1)
        else
            GamePlaneOperator:clearUserDesk(CARD_PLAYERTYPE_MY)
            CardPlaneOperator:clearOutCards(CARD_PLAYERTYPE_MY)
        end
    elseif TaiHeGuoZhaRoomInfo["escrow_time"] ==0 then

        if seat == MY_SEAT_ID then
            ControlPlaneOperator:showControlButtons(4, false)
            local cards = pack.cards
            table.sort(cards,function( a,b )
                return a > b
            end)
            local value, kind = Card:init(cards[1])
            CardPlaneOperator:popCard(value)
            --h=scheduler.performWithDelayGlobal(function()
            --    --scheduler:unscheduleGlobal(h)
            --end, 1)

        else
            GamePlaneOperator:clearUserDesk(CARD_PLAYERTYPE_MY)
            CardPlaneOperator:clearOutCards(CARD_PLAYERTYPE_MY)
        end
    end
    -- local sex = THGZ_USERINFO_TABLE[seat].sex
    GamePlaneOperator:setRestCardNum(playerType, REMAINCARDS[seat], sex, true)
    GamePlaneOperator:clearUserDesk(playerType)
    dump(c_table,"c_table==")
    CardPlaneOperator:clearOutCards(playerType)
    if TaiHeGuoZhaRoomInfo["escrow_time"] ==0 then

        if seat == MY_SEAT_ID then
            h=scheduler.performWithDelayGlobal(function()
                CardPlaneOperator:reduceCard(pack.cards)
                CardPlaneOperator:showOutCard(tm_table, seat)
                if pack.cardcount >= 7 then
                    cardtype = 7

                    CardPlaneOperator:playCardsMusic(c_table, cardtype, seat)
                elseif pack.cardcount == 1 then
                    cardtype = 1
                    CardPlaneOperator:playCardsMusic(c_table, cardtype, seat)
                elseif pack.cardcount == 2 then
                    cardtype = 2
                    CardPlaneOperator:playCardsMusic(c_table, cardtype, seat)
                elseif pack.cardcount == 3 then
                    cardtype = 3
                    CardPlaneOperator:playCardsMusic(c_table, cardtype, seat)
                else
                    ControlPlaneOperator:disPlayChoice(seat, "chupai")
                end
                --scheduler:unscheduleGlobal(h)
            end, 0.1)
        else
            CardPlaneOperator:showOutCard(tm_table, seat)
            if pack.cardcount >= 7 then
                cardtype = 7

                CardPlaneOperator:playCardsMusic(c_table, cardtype, seat)
            elseif pack.cardcount == 1 then
                cardtype = 1
                CardPlaneOperator:playCardsMusic(c_table, cardtype, seat)
            elseif pack.cardcount == 2 then
                cardtype = 2
                CardPlaneOperator:playCardsMusic(c_table, cardtype, seat)
            elseif pack.cardcount == 3 then
                cardtype = 3
                CardPlaneOperator:playCardsMusic(c_table, cardtype, seat)
            else
                ControlPlaneOperator:disPlayChoice(seat, "chupai")
            end
        end
    else
        CardPlaneOperator:showOutCard(tm_table, seat)
        if pack.cardcount >= 7 then
            cardtype = 7

            CardPlaneOperator:playCardsMusic(c_table, cardtype, seat)
        elseif pack.cardcount == 1 then
            cardtype = 1
            CardPlaneOperator:playCardsMusic(c_table, cardtype, seat)
        elseif pack.cardcount == 2 then
            cardtype = 2
            CardPlaneOperator:playCardsMusic(c_table, cardtype, seat)
        elseif pack.cardcount == 3 then
            cardtype = 3
            CardPlaneOperator:playCardsMusic(c_table, cardtype, seat)
        else
            ControlPlaneOperator:disPlayChoice(seat, "chupai")
        end
    end





    for _seat = 0, TaiHeGuoZhaRoomInfo.maxSeatCount - 1 do
        local _playerTyp = ddzSettings:getPlayerType(_seat)
        if REMAINCARDS[_seat] == 0 and _seat ~= seat then
            CardPlaneOperator:clearOutCards(_playerTyp)
        end
    end

    --出牌为CT_ERROR表示出牌的玩家已经出完牌了
    if cardtype == CARDTYPE.CT_ERROR then
        tbPlayCardInfo["last_cards"] = nil
    end

    tbPlayCardInfo["owner"] = pack["outCardSeatID"] --当前出牌玩家ID

    for k, v in pairs(TaiHeGuoZhaRoomInfo) do
        if k == "escrow_time" then
            if v == 5 then
                if nextUser == MY_SEAT_ID then
                    --出牌的类型为ERROR表示此玩家已经出完手牌了，下一下玩家必须要出牌
                    if cardtype == CARDTYPE.CT_ERROR then
                        ControlPlaneOperator:showControlButtons(4, true, 0, 1)
                    else
                        ControlPlaneOperator:showControlButtons(4, true, 0, 1)
                    end
                else
                    ControlPlaneOperator:showControlButtons(4, false)
                end
            elseif v == 0 then
                if nextUser == MY_SEAT_ID then
                    ControlPlaneOperator:showControlButtons(4, false)
                end
            end
        end
    end
    GamePlaneOperator:beginPlayCard(ddzSettings:getPlayerType(nextUser), OUT_CARD_TIMEOUT)
    if seat == MY_SEAT_ID then
        for k,v in pairs(pack.cards) do
            for k,card in pairs(PartnerCards) do
                if card == v then
                    table.remove(PartnerCards,k)
                    break
                end
            end
        end
        CardPlaneOperator:updateSendCard(PartnerCards)
    end
end

--不出 6006
function ddzHandle:SVR_PASS(pack)
    local seat = pack["nPassSeatId"]
    local nseat = pack["nextUser"]

    local playerType = ddzSettings:getPlayerType(seat)

    GamePlaneOperator:clearUserDesk(playerType)
    CardPlaneOperator:clearOutCards(playerType)
    ControlPlaneOperator:disPlayChoice(seat, "noyao")

    if seat == MY_SEAT_ID then
        ControlPlaneOperator:showControlButtons(4, false)
        CardPlaneOperator:resetCards()
    end
    for k, v in pairs(TaiHeGuoZhaRoomInfo) do
        if k == "escrow_time" then
            if v == 5 then
                if nseat == MY_SEAT_ID then
                    if tbPlayCardInfo["owner"] == MY_SEAT_ID then
                        tbPlayCardInfo["last_cards"] = nil
                        ControlPlaneOperator:showControlButtons(4, true, 0, 1)
                    else
                        ControlPlaneOperator:showControlButtons(4, true, 0, 1)
                    end
                else
                    ControlPlaneOperator:showControlButtons(4, false)
                end
            elseif v == 0 then
                if nseat == MY_SEAT_ID then
                    ControlPlaneOperator:showControlButtons(4, false)
                end
            end
        end
    end
    GamePlaneOperator:beginPlayCard(ddzSettings:getPlayerType(nseat), OUT_CARD_TIMEOUT)
end

function ddzHandle:SERVER_BROADCAST_MORE_OPT(pack)
    dump(pack, "SERVER_BROADCAST_MORE_OPT == ")
    for i,v in ipairs(pack.msgLst) do
        local subMsg = {}
        subMsg.cmd = v.cmd
        if v.cmd == PROTOCOL.SVR_PLAY_CARD then --出牌消息
            subMsg.outCardSeatID = v.outCardSeatID
            subMsg.cardcount = v.cardSize
            subMsg.cards = v.cards
            subMsg.nextUser = v.nextUser
            subMsg.txtFen = v.txtFen
            subMsg.shengyuFen = v.shengyuFen
            if v.jiangAndFen[1] then-- and  v.jiangAndFen[1].jiang > 0
                subMsg.otherMsg = {}
                subMsg.otherMsg.playercount = #v.jiangAndFen
                subMsg.otherMsg.Jiang = {}
                for _, v2 in ipairs(v.jiangAndFen) do
                    if v2.jiang > 0 then
                        subMsg.otherMsg.needChangeJiang = true
                    end
                    table.insert(subMsg.otherMsg.Jiang, v2.jiang);
                end
                subMsg.otherMsg.jokerpos = v.jokerpos
            end
        elseif v.cmd == PROTOCOL.SVR_PASS then --pass消息
            subMsg.nPassSeatId = v.outCardSeatID
            subMsg.nextUser = v.nextUser
            if v.jiangAndFen[1] then
                subMsg.otherMsg = {}
                subMsg.otherMsg.playercount = #v.jiangAndFen
                subMsg.otherMsg.Fen = {}
                for _, v2 in ipairs(v.jiangAndFen) do
                    if v2.fen > 0 then
                        subMsg.otherMsg.needChangeFen = true
                    end
                    table.insert(subMsg.otherMsg.Fen, v2.fen);
                end
            end
        end

        if i == 1 then
            self._nextComposeMsg = subMsg
            self:proComposeMsg(subMsg)
        else
            self._nextComposeMsg = subMsg
            self.opt_proComposeMsg = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.proComposeMsg), 0.5, false)
        end
    end
end

function ddzHandle:proComposeMsg(subMsg)
    subMsg = self._nextComposeMsg

    if subMsg.cmd == PROTOCOL.SVR_PLAY_CARD then --调出牌的方法
        self:SVR_PLAY_CARD(subMsg)
        if subMsg.otherMsg and subMsg.otherMsg.needChangeJiang then
            self:SERVER_BROADCAST_USER_JIANG(subMsg.otherMsg)
        end
    elseif subMsg.cmd == PROTOCOL.SVR_PASS then --pass消息
        self:SVR_PASS(subMsg)
        if subMsg.otherMsg and subMsg.otherMsg.needChangeFen then
            self:SERVER_BROADCAST_USER_FEN(subMsg.otherMsg)
        end
    end

    if self.opt_proComposeMsg then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.opt_proComposeMsg)
        self.opt_proComposeMsg = nil
    end
end

function ddzHandle:SVR_RESET_USER_SEAT(pack)
    for _, data in ipairs(pack["playerlist"]) do
        ddzSettings:collectPlayerData(data)

        local uid = data.uid

        local seat_id = data["seatID"]
        USERS_READY_STATE[uid] = data["if_ready"]
        if not stop_state then

            REMAINCARDS[seat_id] = data["handCardCount"]
        end

        if uid == USER_INFO["uid"] then
            --设置玩家座位
            MY_SEAT_ID = seat_id
            if MY_SEAT_ID >= 0 then
                SCENENOW["scene"]:showButtonAfterSitDown(true)
            end
        end
    end

    for i, data in ipairs(pack["playerlist"]) do
        local seat_id = data["seatID"]
        local uid = data["uid"]

        if seat_id >= 0 then
            ddzSettings:showPlayer(uid, seat_id)
            if not stop_state then
                local HandCardCount = data["HandCardCount"] or 0
                local playerType = ddzSettings:getPlayerType(seat_id)
                local sex = THGZ_USERINFO_TABLE[uid].sex
                local flag = seat_id == pack.bankerUser and true or false
                local flag = seat_id == pack.jokerpos and true or false
                GamePlaneOperator:showLandLord(playerType, flag, true) --庄家
                --GamePlaneOperator:updateJoker(playerType, flag, true)--头奖玩家
                GamePlaneOperator:setRestCardNum(playerType, HandCardCount, sex, true)
            end
        end
    end

    local hide_state = false
    for i, data in ipairs(pack["playerlist"]) do
        local uid = data["uid"]
        if tonumber(USER_INFO["uid"]) == tonumber(data["uid"]) and 1 == data["if_ready"] then
            GamePlaneOperator:setReadyStatus(1, true)
            ControlPlaneOperator:showControlButtons(1, false)
            hide_state = true
            break
        end
    end

    for k, v in pairs(TaiHeGuoZhaRoomInfo) do
        if k == "escrow_time" then
            if v == 5 then
                if not hide_state then
                    ControlPlaneOperator:showControlButtons(1)
                end
            elseif v == 0 then
                if not hide_state then
                    ControlPlaneOperator:showControlButtons(1, false)
                end
            end
        end
    end
end

function ddzHandle:SVR_REFRESH_MONEY(pack)
    for i, v in ipairs(pack["playerlist"]) do
        local uid = v["uid"]
        local playerType = ddzSettings:getPlayerType(THGZ_SEAT_TABLE[uid])
        print("SVR_REFRESH_MONEY", v["money"])
        GamePlaneOperator:updateCoin(playerType, v["money"])
    end
end

function ddzHandle:SVR_GAME_OVER_TOTAL(pack)
    --dump1(pack, "SVR_GAME_OVER_TOTAL")
end

--游戏结束单局结算
function ddzHandle:SVR_GAME_OVER(pack)
    dump(pack, "SVR_GAME_OVER")

    SCENENOW["scene"]:initData("clearGameData")

    GAME_STATE = STATUS_WAIT_NEXT_GAME

    LandLordSeatId = nil
    TouJiangFLAG = nil
    for uid, _ in pairs(USERS_READY_STATE) do --重置所有玩家的准备状态
        USERS_READY_STATE[uid] = 0
    end

    local tbWin = {}

    for i, v in ipairs(pack["playerList"]) do
        local uid = v["uid"]
        local playerType = ddzSettings:getPlayerType(THGZ_SEAT_TABLE[uid])
        local AllFen = v["AllFen"]
        local oriChip = THGZ_USERINFO_TABLE[uid].coins
        local chip = v.m_chips--oriChip + AllFen
        THGZ_USERINFO_TABLE[uid].coins = chip
        GamePlaneOperator:updateAllFen(playerType, chip)
        --显示玩家剩余牌
        if uid ~= winnerUid and uid ~= USER_INFO["uid"] then
            CardPlaneOperator:drawUserCards(v["cards"], playerType)
        end

        tbWin[uid] = v["roundmoney"]
        tbWin[uid] = 0
    end

    GamePlaneOperator:drawCoin(tbWin)
    GamePlaneOperator:clearAllUserDesk()


    ControlPlaneOperator:showControlButtons(4, false)

    local singleLayer = require("TaiHeGuoZha.SingleResultLayer").new(pack["playerList"])
    if singleLayer then
        singleLayer:setName("singleResultLayer")
        SCENENOW["scene"]:addChild(singleLayer, 9999)
    end
end

--组局排行榜 5100  游戏结束时
function ddzHandle:SVR_GROUP_BILLBOARD(pack)
    --dump1(pack, "SVR_GROUP_BILLBOARD")
    HAS_RECEIVE_GROUP_RESULT = true
    HEART_BEAT_TID = 0
    local TotalResultLayer = require("TaiHeGuoZha.TotalResultLayer").new(pack["playerlist"])
    if TotalResultLayer then
        local singleLayer = SCENENOW["scene"]:getChildByName("singleResultLayer")
        if singleLayer ~= nil then
            singleLayer:removeSelf()
        end
        SCENENOW["scene"]:addChild(TotalResultLayer,99999)
    end
    SCENENOW["scene"].roomCommonLayer:processRevcDisbandRoomSucc()
    if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
    end
end

--组局时长 5101
function ddzHandle:SVR_GROUP_TIME(pack)
    -- SCENENOW["scene"]:updateDiamondCount()
    DDZ_ROUND = pack["round"] --+ 1
    DDZ_TOTAL_ROUND = pack["round_total"]

    SCENENOW["scene"].GameRound = pack.round

    local remain_rounds_count_plane = cardScene:getChildByName("remain_rounds_count_plane"):setVisible(true)

    local rounds = remain_rounds_count_plane:getChildByName("rounds")

    if isGoldGame == 0 then
        remain_rounds_count_plane:setVisible(false)
        return
    end

    if DDZ_TOTAL_ROUND == 999 then
        rounds:setString(DDZ_ROUND .. "局")
    else

        rounds:setString(string.format("%d/%d局", DDZ_ROUND, DDZ_TOTAL_ROUND))
    end
end

--------------------------------------周边功能-----------------------------------------
--扣除台费 4800
function ddzHandle:SVR_CHIP_CHANGE_BROADCAST(pack)
    local change_chip = 0
    for _, data in pairs(pack.userinfo) do
        local uid = data.uid
        local seatId = THGZ_SEAT_TABLE[uid]
        local playerType = ddzSettings:getPlayerType(seatId)
        local oriChip = THGZ_USERINFO_TABLE[uid].coins
        local chip = oriChip + data.change_chip
        THGZ_USERINFO_TABLE[uid].coins = chip

        GamePlaneOperator:updateCoin(playerType, chip)

        if uid == USER_INFO["uid"] then
            --GamePlaneOperator:showTaiFeiTips(data.change_chip)
        end
    end
end

--充值后广播 111
function ddzHandle:SVR_CHARGE_BROADCAST(pack)
    local uid = pack.uid
    local seatId = THGZ_SEAT_TABLE[uid]
    local playerType = ddzSettings:getPlayerType(seatId)

    if THGZ_USERINFO_TABLE[uid] and playerType then
        local oriChip = THGZ_USERINFO_TABLE[uid].coins
        local chip = oriChip + pack.chargeCoins
        THGZ_USERINFO_TABLE[uid].coins = chip
        GamePlaneOperator:updateCoin(playerType, chip)
    end
end

function ddzHandle:getUserInfoLstToDisband(applyId)
    --dump1(THGZ_USERINFO_TABLE, "getUserInfoLstToDisband")
    local userLst = THGZ_USERINFO_TABLE or {}

    local result = {}
    for k, v in pairs(userLst) do
        local tmp = {}
        tmp.state = v.uid == applyId and 3 or 2
        tmp.userId = v.uid
        tmp.userName = v.nickName
        tmp.userUrl = v.portrait or v.icon_url

        table.insert(result, tmp)
    end
    --dump1(result, "根据老赵之前的改动，这边相应的变化")
    return result
end

--组局解散相关
--没有此房间，解散房间失败
function ddzHandle:G2H_CMD_DISSOLVE_FAILED(pack)
    --dump1("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")
    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")
end

function ddzHandle:processRevcDisbandInfo(info)
    if info.agreeNum == 0 then
        print("===11111===")
        if SCENENOW["scene"].roomCommonLayer.disbandLayer == nil then
            print("22222")
            local playerLst = self:getUserInfoLstToDisband(info.applyId)
            SCENENOW["scene"].roomCommonLayer:processRevcRequestDisband(playerLst, info.applyTime)
        else
            --dump1(SCENENOW["scene"].roomCommonLayer.disbandLayer)
            SCENENOW["scene"].roomCommonLayer.disbandLayer = nil
            local playerLst = self:getUserInfoLstToDisband(info.applyId)
            SCENENOW["scene"].roomCommonLayer:processRevcRequestDisband(playerLst, info.applyTime)
        end
    else
        print("===33333===")
        if SCENENOW["scene"].roomCommonLayer.disbandLayer == nil then
            print("===44444===")
            local playerLst = self:getUserInfoLstToDisband(info.applyId)
            SCENENOW["scene"].roomCommonLayer:processRevcRequestDisband(playerLst, info.applyTime)
        end
        for i, v in ipairs(info.agreeMember_arr) do
            if SCENENOW["scene"].roomCommonLayer.disbandLayer.exChangeState then
                SCENENOW["scene"].roomCommonLayer:exchangeStateBySel(v, 1)
            end
        end
    end
end

--广播当前组局解散情况
function ddzHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)
    --dump1(pack, "-----广播当前组局解散情况-----")
    --dump1(THGZ_USERINFO_TABLE, "-----广播当前房间情况-----")
    self:processRevcDisbandInfo(pack)
    do
        return
    end
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
        local player_table = {}
        if THGZ_USERINFO_TABLE ~= nil then
            applyer_info = THGZ_USERINFO_TABLE[applyId]
            --dump1(applyer_info, "-----广播当前房间情况applyer_info-----")
            if applyer_info ~= nil then
                local nickName = applyer_info.nick
                if nickName ~= nil then
                    player_table["playerName"] = nickName
                else
                    player_table["playerName"] = applyId
                end
            else
                player_table["playerName"] = applyId
            end

            player_table["state"] = "申请"
        end
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
    if THGZ_USERINFO_TABLE ~= nil then
        for k, v in pairs(THGZ_USERINFO_TABLE) do
            --dump1(v, "-----显示其他人情况-----")
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
                local nickName = v.nick
                if nickName ~= nil then
                    player_table["playerName"] = nickName

                    if isAgree == 1 then
                        player_table["state"] = "同意"
                    else
                        player_table["state"] = "等待选择"
                    end

                    player_table["icon"] = v.icon_url

                    table.insert(disband_table, player_table)
                end
            end
        end
    end

    local function agree_disband(value)
        ddzServer:C2G_CMD_REPLY_DISSOLVE_ROOM(value)
    end

    if applyId == USER_INFO["uid"] then
        --假如申请者是自己，则直接显示其他用户的选择情况
        require("hall.GameTips"):showDisbandNewTips("提示", "agree_disbandGroup", 4, disband_table)
    else
        --申请者不是自己，根据自己的同意情况进行界面显示
        if isMyAgree == 1 then
            require("hall.GameTips"):showDisbandNewTips("提示", "agree_disbandGroup", 4, disband_table)
        else
            require("hall.GameTips"):showDisbandNewTips("提示", "new_request_disbandGroup", 1, disband_table,agree_disband)
        end
    end
end

--广播桌子用户请求解散组局
function ddzHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)
    --dump1(pack, "-----广播桌子用户请求解散组局-----")
    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")
end

--广播桌子用户成功解散组局
function ddzHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)
    dump(pack, "-----广播桌子用户成功解散组局-----")

    -- require("hall.GameTips"):showTips("解散房间成功","cs_disbandGroup_success",3)
    --SCENENOW["scene"]:showBtnByUserStatus(false)
    if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
    end
    bm.isDisbandSuccess = true
    SCENENOW["scene"].roomCommonLayer:processRevcDisbandRoomSucc()
end

--广播桌子用户解散组局 ，解散组局失败
function ddzHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)
    SCENENOW["scene"].roomCommonLayer:processRevcRejectDisband(pack)
end

--聊天
function ddzHandle:SVR_MSG_FACE(pack)
    local s = SCENENOW["scene"]:getChildByName("faceUI")

    local uid = pack.uid
    local emojiType = pack.type

    local sex = THGZ_USERINFO_TABLE[uid].sex or 0

    local seatId = THGZ_SEAT_TABLE[uid]
    local playerType = ddzSettings:getPlayerType(seatId)

    local isLeft = false
    if playerType == CARD_PLAYERTYPE_RIGHT then
        isLeft = true
    end

    local node_head = PLAYER_HEADS_TABLE[uid] --GamePlaneOperator:getPlayerHeadPlane(playerType)
    if tonumber(sex) >= 0 then
        s:showGetFace(uid, emojiType, tonumber(sex), node_head, isLeft)
    end
end
-----------------------------------------------------------------------------------------------------------------------------
function ddzHandle:showExpression(msg)
    local uid_from = tonumber(msg["uid_from"]) or 1
    local uid_to = tonumber(msg["uid_to"]) or 1
    local expressionType = tonumber(msg["expressionType"]) or 1

    --制定座位号对应的动画播放起始和结束的大概位置
    local PLAYER_HEADS_POSITION_TABLE = PLAYER_HEADS_POSITION_TABLE or {}
    ------------------------------------------------------------------------------------
    local from_x = PLAYER_HEADS_POSITION_TABLE[uid_from].x
    local from_y = PLAYER_HEADS_POSITION_TABLE[uid_from].y

    local to_x = PLAYER_HEADS_POSITION_TABLE[uid_to].x
    local to_y = PLAYER_HEADS_POSITION_TABLE[uid_to].y

    require("hall.view.animView.animView"):ShowAnimationByPosition(from_x, from_y, to_x, to_y, expressionType)
end

function ddzHandle:showTextMessage(pack)
    local s = SCENENOW["scene"]:getChildByName("faceUI")

    local uid = pack.uid
    local seatId = THGZ_SEAT_TABLE[uid]
    local playerType = ddzSettings:getPlayerType(seatId)

    local isLeft = false
    if playerType == CARD_PLAYERTYPE_RIGHT then
        isLeft = true
    end

    local node_head = PLAYER_HEADS_TABLE[uid] --GamePlaneOperator:getPlayerHeadPlane(playerType)

    s:showGetText(uid, pack.textMessage, tonumber(sex), node_head, isLeft)
end

--接收服务器返回的组局信息
function ddzHandle:SERVER_CMD_MESSAGE(pack)
    if bm.isInGame == false then
        return
    end

    local msg = json.decode(pack.msg)
    --dump1(msg, "-----NiuniuroomHandle 接收服务器返回的组局信息-----")
    if msg ~= nil then
        local msgType = msg.msgType
        if msgType ~= nil and msgType ~= "" then
            if msgType == "expression" then --表情
                self:showExpression(msg)
            elseif msgType == "text" then --文字聊天
                self:showTextMessage(msg)
            elseif msgType == "emoji" then --文字聊天
                self:SVR_MSG_FACE(msg)
            elseif  msgType == "EmojiArmatureView" then   --动态表情
                self:SVR_MSG_EMOJI_ARMATURE(msg)
            end

            if device.platform == "ios" then
                if msgType == "voice" then
                    --dump1("voice", "-----接收服务器返回的组局信息-----")

                    require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

                    --通知本地播放录音
                    local arr = {}
                    arr["url"] = msg.url
                    cct.getDateForApp("playVoice", arr, "V")
                elseif msgType == "video" then
                    --dump1("video", "-----接收服务器返回的组局信息-----")

                    local arr = {}
                    arr["url"] = msg.url
                    cct.getDateForApp("playVideo", arr, "V")
                end
            else
                if msgType == "voice" then
                    --dump1("voice", "-----接收服务器返回的组局信息-----")

                    require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

                    --通知本地播放录音

                    local data = {}
                    data["url"] = msg.url

                    local arr = {}
                    table.insert(arr, json.encode(data))
                    cct.getDateForApp("playVoice", arr, "V")
                elseif msgType == "video" then
                    --dump1("video", "-----接收服务器返回的组局信息-----")

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

function ddzHandle:SVR_MSG_EMOJI_ARMATURE(pack)
    local EmojiArmatureView = SCENENOW.scene:getChildByName("EmojiArmatureView")
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

--接收服务器返回的缓存信息 0213
function ddzHandle:SERVER_CMD_FORWARD_MESSAGE(pack)
    dump(pack, "-----ddzHandle 接收服务器返回的缓存信息-----")

    local msgList = pack.msgList
    for k, v in pairs(msgList) do
        if v ~= nil and v ~= "" then
            local msg = json.decode(v)
            if msg ~= nil and msg ~= "" then
                if msg.uid ~= nil and msg.uid ~= "" then
                    if next(THGZ_SEAT_TABLE) ~= nil then
                        local seatId = THGZ_SEAT_TABLE[msg.uid]
                        if seatId then
                            local playerType = ddzSettings:getPlayerType(seatId)
                            if tonumber(msg.longitude) ~= 0 and not LocaArrayByPlayerType[playerType] then
                                LocaArrayByPlayerType[playerType] = {[1] = tonumber(msg.longitude), [2] = tonumber(msg.latitude)}
                            end
                        end
                    end

                    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(msg.uid, msg)
                end
            end
        end
    end
end

function ddzHandle:SERVER_COMMAND_GET_CARD(pack)
    dump(pack,"SVR_GET_SURP_CARDS ------------------------------------")
    --GamePlaneOperator:showCheatSurpCards(CARD_PLAYERTYPE_MY, pack.cards)
    if pack.cardCount > 0 then
        local function func(cardLst)
            ddzServer:CLIENT_COMMAND_USER_CARD(cardLst)
        end
        local ZiPaiTest = require(TpackageName..".TestView").new(pack.cards, func, 1)
        local idx = ViewBase:getZOrderByChilds(SCENENOW.scene)
        SCENENOW.scene:addChild(ZiPaiTest, idx)
    end
end


return ddzHandle

--测试性能专用代码
--   local t1 = os.time();
--   for  i =1,10000000  do
--    local playerType = math.random(1,4)
--        self:getPlayerPlane(playerType)
-- end

-- local t2 = os.time();
-- print(os.difftime(t2, t1),"运行时间");
