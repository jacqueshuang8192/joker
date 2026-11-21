require("framework.init")
--加载大厅请求处理
local hallHandle = require("hall.HallHandle")
local   xhdzHandle = class("xhdzHandle",hallHandle)

local   PROTOCOL = import(TpackageName .. ".src.protocol.xhdzProtocol")
local   xhdzServer = import(TpackageName .. ".src.protocol.xhdzServer")

local   Card          = require(TpackageName .. ".src.view.Card")
local   CardAnalysis  = require(TpackageName .. ".src.logic.CardsAnalysis")

function xhdzHandle:ctor()
    xhdzHandle.super.ctor(self);
	local  func_ = {

            --登陆房间成功返回
            [PROTOCOL.SVR_LOGIN_ROOM_OK] = {handler(self, xhdzHandle.SVR_LOGIN_ROOM_OK), ""},
            [PROTOCOL.SVR_KICK_OFF]      = {handler(self, xhdzHandle.SVR_KICK_OFF)},
            [PROTOCOL.SVR_READY_GAME] = {handler(self, xhdzHandle.SVR_READY_GAME), ""},
            [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, xhdzHandle.SVR_LOGIN_ROOM_BROADCAST), ""},
            [PROTOCOL.SVR_LOGOUT_ROOM_OK] = {handler(self, xhdzHandle.SVR_LOGOUT_ROOM_OK), ""},
            [PROTOCOL.SVR_LOGOUT_ROOM] = {handler(self, xhdzHandle.SVR_LOGOUT_ROOM), ""},
            [PROTOCOL.SVR_QUICK_SUC] = {handler(self, xhdzHandle.SVR_QUICK_SUC), ""},
            [PROTOCOL.SVR_GROUP_TIME] = {handler(self, xhdzHandle.SVR_GROUP_TIME), ""},
            [PROTOCOL.SVR_MSG_FACE]={handler(self, xhdzHandle.SVR_MSG_FACE), ""},
            --1031玩家坐下
            [PROTOCOL.BROADCAST_USER_SIT_DOWN]={handler(self, xhdzHandle.BROADCAST_USER_SIT_DOWN), ""},
            --1032玩家站起
            [PROTOCOL.BROADCAST_USER_STAND_UP]={handler(self, xhdzHandle.BROADCAST_USER_STAND_UP), ""},
            --1033玩家离开房间
            [PROTOCOL.SVR_BROADCAST_USER_LEAVEROOM]={handler(self, xhdzHandle.SVR_BROADCAST_USER_LEAVEROOM), ""},

            --错误提示5001
            [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, xhdzHandle.BROADCAST_ERROR_TIPS)},
            [PROTOCOL.SVR_LOGIN_ROOM_FAIL] = {handler(self, xhdzHandle.SVR_LOGIN_ROOM_FAIL)},



            -- 发牌
            [PROTOCOL.SVR_DEAL] = {handler(self, xhdzHandle.SVR_DEAL), ""},
            --用户重连进房间返回
            [PROTOCOL.SVR_RELOAD_ROOM] = {handler(self, xhdzHandle.SVR_RELOAD_ROOM), ""},
            -- 出牌
            [PROTOCOL.SVR_PLAY_CARD] = {handler(self, xhdzHandle.SVR_PLAY_CARD), ""},
            
            
            --通知包庄操作结果
            [PROTOCOL.SVR_SELECTUNDERTAKERESULT] = {handler(self, xhdzHandle.SVR_SELECTUNDERTAKERESULT),""},
            --通知包庄操作
            [PROTOCOL.SVR_SELECTUNDERTAKE] = {handler(self, xhdzHandle.SVR_SELECTUNDERTAKE),""},
            --通知过牌
            [PROTOCOL.SVR_BROADCAST_PASS] = {handler(self, xhdzHandle.SVR_BROADCAST_PASS),""},
            --捡分变化广播
            [PROTOCOL.SERVER_BROADCAST_USER_GAIN_SCORE] = {handler(self, xhdzHandle.SERVER_BROADCAST_USER_GAIN_SCORE),""},
            --炸弹 喜分变化 广播
            [PROTOCOL.SERVER_BROADCAST_USER_BOMB_FEN] = {handler(self, xhdzHandle.SERVER_BROADCAST_USER_BOMB_FEN),""},



            --牌局排行
            [PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, xhdzHandle.SVR_GROUP_BILLBOARD), ""},

            
            [PROTOCOL.SVR_PLAY_CARD_ERROR] = {handler(self, xhdzHandle.SVR_PLAY_CARD_ERROR), ""},
            [PROTOCOL.SVR_PASS] = {handler(self, xhdzHandle.SVR_PASS), ""},
            [PROTOCOL.SVR_ALERT] = {handler(self, xhdzHandle.SVR_ALERT), ""},
            --[PROTOCOL.SVR_GAME_OVER] = {handler(self, xhdzHandle.SVR_GAME_OVER), ""},
            [PROTOCOL.SERVER_SEND_TURN_RESULT] = {handler(self, xhdzHandle.SERVER_SEND_TURN_RESULT), ""},

            

            [PROTOCOL.SVR_CHIP_CHANGE_BROADCAST] = {handler(self, xhdzHandle.SVR_CHIP_CHANGE_BROADCAST)},
            [PROTOCOL.SVR_CHARGE_BROADCAST] = {handler(self, xhdzHandle.SVR_CHARGE_BROADCAST)},

            --没有此房间，解散房间失败
            [PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, xhdzHandle.G2H_CMD_DISSOLVE_FAILED)},
            --广播桌子用户请求解散组局
            [PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, xhdzHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
            --广播当前组局解散情况
            [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, xhdzHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
            --广播桌子用户成功解散组局
            [PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, xhdzHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
            --广播桌子用户解散组局 ，解散组局失败
            [PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, xhdzHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},
            
            --接收服务器返回的缓存信息
            [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, xhdzHandle.SERVER_CMD_FORWARD_MESSAGE)},  
            [PROTOCOL.SERVER_CMD_MESSAGE]={handler(self, xhdzHandle.SERVER_CMD_MESSAGE), ""},
            
            [PROTOCOL.SVR_BROADCAST_MINGPAI]={handler(self, xhdzHandle.SVR_BROADCAST_MINGPAI), ""},
            [PROTOCOL.SVR_BROADCAST_BONUS]={handler(self, xhdzHandle.SVR_BROADCAST_BONUS), ""},
            [PROTOCOL.SVR_BROADCAST_NOTICE_USER_OUTCARD]={handler(self, xhdzHandle.SVR_BROADCAST_NOTICE_USER_OUTCARD), ""},

            [PROTOCOL.SVR_SEND_MINGPAI_REMIND] = {handler(self , xhdzHandle.SVR_SEND_MINGPAI_REMIND) , ""},

            [PROTOCOL.SERVER_SEND_SINGE_DATA] = {handler(self , xhdzHandle.SERVER_SEND_SINGE_DATA)},
            --托管
            [PROTOCOL.SERVER_COMMAND_AUTO] = {handler(self , xhdzHandle.SERVER_COMMAND_AUTO)},



            --广播剩余时间100F广播切牌
            [PROTOCOL.SVR_BROADCAST_COUNT_DOWN] = {handler(self, xhdzHandle.SVR_BROADCAST_COUNT_DOWN)},
            --[PROTOCOL.SERVER_BROADCAST_SHUFFLE_ANI]           = {handler(self, xhdzHandle.SERVER_BROADCAST_SHUFFLE_ANI)},
            

            --接收服务器放回的指定用户信息pack111
          -- [PROTOCOL.SERVER_CMD_HALL_GET_MESSAGE] = {handler(self, xhdzHandle.SERVER_CMD_HALL_GET_MESSAGE)},        
            [PROTOCOL.SERVER_BROADCAST_REQUEST_SURRENDER]     = {handler(self, xhdzHandle.SERVER_BROADCAST_REQUEST_SURRENDER)},--广播桌子用户请求投降
            [PROTOCOL.SERVER_BROADCAST_OPT_SURRNEDER]     = {handler(self, xhdzHandle.SERVER_BROADCAST_OPT_SURRNEDER)},--广播桌子用户请求投降

    }
    table.merge(self.func_, func_)
end


function xhdzHandle:callFunc(pack)

    dump(pack.cmd,"当前游戏解析协议号")

    if SCENENOW["name"]~= TpackageName .. ".gameScene" then
        return
    end

	if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end

end

---------------------------------------房间相关-------------------------------
--5001
function xhdzHandle:BROADCAST_ERROR_TIPS(pack)

    dump(pack, "-----返回错误提示5001-----")
    
    local errorCode = pack.errorCode

    local tbErrorCode = {
        [1]  = "操作无效",
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

        [104] = "牌型错误",
        [105] = "没大过上家牌",
        [106] = "牌型不符合",
        [107] = "没有这些牌",
    }
    
    if  errorCode == 18 then
        SCENENOW["scene"]:performWithDelay(function()

            --去掉提示弹框
            local layer_tips = SCENENOW["scene"]:getTag(99998)
            if  layer_tips then
                layer_tips:removeSelf()
            end

            if not isiOSVerify then
                SCENENOW["scene"]:requestCharge()
            end

         end,1.5)    
    end
    
    dump(tbErrorCode[errorCode],"错误提示")
    local paras = {}
    paras.type = 1
    paras.title = "提示"
    paras.content = tbErrorCode[errorCode] == nil and "未知的错误" or tbErrorCode[errorCode]
    require("hall.tips.CommonTips"):showTips(paras)
    

end

--进入房间失败 1005
function xhdzHandle:SVR_LOGIN_ROOM_FAIL(pack)

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
        [17] = "要求携带的积分不足",
        [18] = "游戏已开始，无法加入游戏"
    }

    if  tbErrorCode[pack.errorCode] then
        if pack.errorCode == 18 or pack.errorCode == 7 or pack.errorCode == 5 then
            local paras = {type = 1, title = "提示", content = tbErrorCode[pack.errorCode]}
            require("hall.tips.CommonTips"):showTipsAndToHall(paras)
        else
            local paras = {type = 1, title = "提示", content = tbErrorCode[pack.errorCode]}
            require("hall.tips.CommonTips"):showTips(paras)
        end
    else
        local paras = {type = 1, title = "提示", content = "未知的错误"}
        require("hall.tips.CommonTips"):showTips(paras)
    end

end

--广播自己退出 1008   
function  xhdzHandle:SVR_QUICK_SUC(pack)
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end


--进入房间 1007 牌局没开始 or 等待玩家准备的过程中的重连
function xhdzHandle:SVR_LOGIN_ROOM_OK(pack)
    require(NetworkLoadingView_filePath):removeView(888)
    dump(pack, "SVR_LOGIN_ROOM_OK")
    USER_INFO["invote_code"] = pack["inviteCode"]
    USER_INFO["configData"]=pack.roomConfigStr
    USER_INFO["family_id"] = pack.clubId
    if g_mainScene == nil then return end
    HEART_BEAT_TID = USER_INFO["tid"]

    g_mainScene.tableLayer:setShowCardBtn(pack.isTest)
    g_mainScene.roomCommonLayer:setRoomNum(pack.inviteCode)
    -- g_mainScene.tableLayer:setShowCardBtn(pack.isTest)
    MAX_PLAYER_SIZE = pack.tableUserCount
    -- 设置牌子上的玩家信息
    for i, v in ipairs( pack.playerlist ) do
        if v.uid == USER_INFO.uid then 
            MY_SEAT_ID = v.seat_id
        end
    end
    local isReady = false
    for i, v in ipairs( pack.playerlist ) do
        if v.uid == USER_INFO.uid and v.if_ready > 0 then
            isReady = true
        end
        local playerInfo = g_mainScene.playerInfoLayer:getUserHeadInfo(v)
        local viewId = g_mainScene.playerInfoLayer:getViewIdBySeatId(v.seat_id)
        if viewId == 2 then
            playerInfo.isLeftPlayer = false
        else
            playerInfo.isLeftPlayer = true
        end
        g_mainScene.playerInfoLayer:setPlayerInfoByViewId(viewId, playerInfo)
    end
    tableAI[USER_INFO["uid"]] = pack.m_bAIUser
    -- 显示开始游戏按钮
    if xhdz_CUR_ROUND == 0 then
        g_mainScene.playerInfoLayer:showBeginBtnByState(2)
    else
        g_mainScene.playerInfoLayer:showBeginBtnByState(1)
    end
    g_mainScene:initGameConfigData(pack.roomConfigStr)

    if isReady then
        g_mainScene.playerInfoLayer.btnReady:setVisible(false)
    end

    g_mainScene.playerInfoLayer:setFangZhuFlag(pack.OwnerID)
    if pack.m_bAIUser ~= 0 then
        g_mainScene.tgLayer:showTg()
    end
    -- -- to test
    -- local lst = {20,1,3,19,4,5,21,22,6,23,7,5,6,26,11,13}--,11,27,28,44,60,19
    -- -- local lst = {2,1,3,19,51}
    -- -- g_mainScene.prevOutCards = g_mainScene.playerInfoLayer:exchangeCardsValue(lst)
    -- -- g_mainScene.tableLayer:showOutCardsInTable(2, 8)
    -- -- g_mainScene.tableLayer:showOutCardsInTable(3)
    -- g_mainScene.playerInfoLayer:showHandlCards(lst)
    -- g_mainScene.playerInfoLayer.outCardBtnNode:setVisible(true)
    -- g_mainScene.playerInfoLayer.beginBtnNode:setVisible(false)

end



--其他用户进入房间 100D
function xhdzHandle:SVR_LOGIN_ROOM_BROADCAST(pack)

end

--服务器广播玩家退出 100E
function xhdzHandle:SVR_LOGOUT_ROOM(pack)
    dump(pack,"玩家退出房间")
    do return end
    local  seat = DDZ_SEAT_TABLE[pack["Uid"]]
    local  playerType = ddzSettings:getPlayerType(seat)
    if  playerType then
        GamePlaneOperator:showNetworkImg(playerType,true)  --显示掉线
    end
end

--广播用户坐下 1031   其他用户进入房间
function  xhdzHandle:BROADCAST_USER_SIT_DOWN(pack)
    dump(pack, "BROADCAST_USER_SIT_DOWN")

    if pack.uid == USER_INFO.uid then 
        MY_SEAT_ID = pack.seat_id
        g_mainScene.playerInfoLayer:reSetPlayerInfo()
        -- g_mainScene.playerInfoLayer:showBeginBtnByState(2)
    end

    pack.if_ready = 0
    pack.if_online = 1
    local playerInfo = g_mainScene.playerInfoLayer:getUserHeadInfo(pack)
    local viewId = g_mainScene.playerInfoLayer:getViewIdBySeatId(pack.seat_id)
    if viewId == 2 then
        playerInfo.isLeftPlayer = false
    else
        playerInfo.isLeftPlayer = true
    end
    g_mainScene.playerInfoLayer:setPlayerInfoByViewId(viewId, playerInfo)
    -- local info = {nPassUserId = USER_INFO.uid}
    -- g_mainScene.playerInfoLayer:processUserPass(info)
end


--广播玩家站起 1032
function xhdzHandle:BROADCAST_USER_STAND_UP(pack)

    dump(pack, "------广播玩家站起1032------")
    g_mainScene.playerInfoLayer:processUserStandUp(pack)
    do return end
    if  isGoldGame == 1 and HAS_RECEIVE_GROUP_RESULT == true then
        return
    end

    local uid = pack.uid
    local seat_id = DDZ_SEAT_TABLE[uid]
    local playerType = ddzSettings:getPlayerType(seat_id)
    
    if  playerType then
        GamePlaneOperator:removePlayer(playerType)
    end
    
    -- DDZ_PLAYERTYPE_TABLE[pack.uid] = nil
    -- NIUNIU_UID_TABLE[seat_id] = nil
    DDZ_SEAT_TABLE[pack.uid] = -2

    if  uid == USER_INFO["uid"] then

        ControlPlaneOperator:showControlButtons(1,false)
        ControlPlaneOperator:showSitDownButton(true)

        SCENENOW["scene"]:showButtonAfterSitDown(false)
        MY_SEAT_ID = -1

    elseif  MY_SEAT_ID < 0 then  --别人站起，自己也站着的时候
        ControlPlaneOperator:showSitDownButton(true)
    end

end

--1033
function xhdzHandle:SVR_BROADCAST_USER_LEAVEROOM(pack)
    if USER_INFO.uid == pack.uid  then
        if SCENENOW["scene"].GameRound == 0 then

            if USER_INFO["family_data"] then 
                require("hall.GameCommon"):gExitGroupGame(nil , true)
            else
                dump(pack,"玩家退出房间")
                require("hall.tips.CommonTips"):_gameToHall()
            end
        end
        return
    end

    local uid = pack.uid
    -- local seat = DDZ_SEAT_TABLE[uid]
    -- local playerType = ddzSettings:getPlayerType(seat)

    -- if  playerType then
    --     GamePlaneOperator:removePlayer(playerType)  --显示掉线
    -- end

    -- -- DDZ_PLAYERTYPE_TABLE[pack.uid] = nil
    -- USERS_READY_STATE[pack.uid] = nil
    -- DDZ_SEAT_TABLE[pack.uid] = nil

    if  require("hall.view.userInfoView.userInfoView").upDateUserInfo then
        require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,{},"reset")
    end

    --处理自己退出
    if  uid == USER_INFO["uid"] then
        if  isGoldGame == 0 or (isGoldGame == 1 and HAS_RECEIVE_GROUP_RESULT ~= true) then
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
            HEART_BEAT_TID = 0
        end
    end

end

--玩家进入私人房 0212
function xhdzHandle:SVR_ENTER_PRIVATE_ROOM(pack)
    -- require("hall.GameTips"):showTips("您被卡在私人房中,请联系客服处理")
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
end

--客户端被踢
function xhdzHandle:SVR_KICK_OFF(pack)
    require("hall.GameTips"):showTips("您被请出游戏","kick_off")
end

--服务器返回自己退出
function xhdzHandle:SVR_LOGOUT_ROOM_OK(pack)

    -- if tolua.isnull(SCENENOW["scene"]) == false then

    -- if GAME_STATE == STATUS_STOP then
    --     bm.server:addAvoidReconnectTime(2)
        
    --     local function func()
    --         print("wtf reduceAvoidReconnectTime")
    --     end

    --     LMyTimer:getInstance():register("server:reduceAvoidReconnectTime", nil, func, 5, 1)
    -- end
    
    -- else
    --     local next = require("src.app.scenes.MainScene").new()
    --     SCENENOW["scene"] = next
    --     SCENENOW["name"] = "app.scenes.MainScene"
    --     display.replaceScene(next)
    -- end
end

--玩家重登，进入游戏 1009
function xhdzHandle:SVR_RELOAD_ROOM(pack)
    dump(pack,"xhdzHandle:SVR_RELOAD_ROOM")
    require(NetworkLoadingView_filePath):removeView(888)
    if g_mainScene == nil then return end
    
    USER_INFO["invote_code"] = pack["inviteCode"]
    USER_INFO["family_id"] = pack.clubId
    USER_INFO["configData"]=pack.roomConfigStr
    -- USER_INFO["_isTest"] = pack["isTest"]
    g_mainScene.tableLayer:setShowCardBtn(pack.isTest)
    MAX_PLAYER_SIZE = pack.tableUserCount
    g_mainScene:initGameConfigData(pack.roomConfigStr)
    g_mainScene.playerInfoLayer:processReloadRoom(pack)
    --g_mainScene.playerInfoLayer:setFangZhuFlag(pack.OwnerID)
    g_mainScene.playerInfoLayer:setZhuangFlag(pack.bank_uid)
    tableAI[USER_INFO["uid"]] = pack.m_bAIUser
    dump(pack.m_bAIUser,"pack.m_bAIUser")
    if pack.m_bAIUser ~= 0 then     --断线重连弹出UI托管UI
        dump(pack.m_bAIUser,"pack.m_bAIUser")
        g_mainScene.tgLayer:showTg()
    end
    -- g_mainScene.playerInfoLayer:processSingleGameOver(game_over)



    if pack.surrenderUid and pack.surrenderUid ~= 0 then
        local data = {}
        data.applyId = pack.surrenderUid
        self:SERVER_BROADCAST_REQUEST_SURRENDER(data)
        if self.DisbandLayer then
            local data = {[1] = 1, [2] = 0, [0] = 2}  --state 0,拒绝 1,同意 2,未选择 3,申请人
            for k,playerlist in pairs(pack.playerlist) do
                if pack.surrenderUid ~= playerlist.uid then
                    self.DisbandLayer:exChangeState({userId = playerlist.uid, state = data[playerlist.opt]}, playerlist.opt ~= 0)
                end
            end
        end

    end
    --下面直接不执行了。。。。。。。
    do return end

    GAME_STATE = pack.GAME_STATE 
    PLAY_MODE = pack.playMode
    isGoldGame = false--pack.Tabletype

    --金币场的话初始化金币为0
    initialChip =  isGoldGame == 0 and 0 or (USER_INFO["group_chip"] or 2000)  

    if PLAY_MODE == 1 then
        FARMER_CARDNUM = 16
    else
        FARMER_CARDNUM = 15
    end

    LANDLORD_CARDNUM = FARMER_CARDNUM
    
    -- local layer_top = cardScene:getChildByName("play_top")
    -- local btn_auto = layer_top:getChildByName("btn_auto")
    -- if isGoldGame == 0 then
    --     btn_auto:setVisible(true)
    -- else
    --     btn_auto:setVisible(false)
    -- end

    GamePlaneOperator:showAudienceBrand(true)

    --数据
    for _, data in ipairs(pack["playerlist"]) do

        ddzSettings:collectPlayerData(data)

        local uid = data.uid
        local seat_id = data["seat_id"]

        USERS_READY_STATE[uid] = data["if_ready"]
        REMAINCARDS[seat_id] = data["HandCardCount"]

        if uid == USER_INFO["uid"] then
            --设置玩家座位
            MY_SEAT_ID = seat_id

            RELATIVE_SEAT_ID = 0
            if  MY_SEAT_ID >= 0 then
                SCENENOW["scene"]:showButtonAfterSitDown(true)
                RELATIVE_SEAT_ID = MY_SEAT_ID
                GamePlaneOperator:showAudienceBrand(false)        
            end
        end
    end
    
    --界面
    for i, data in ipairs(pack["playerlist"]) do

        local seat_id = data["seat_id"]
        local uid = data["uid"]

        if  seat_id >= 0 then

            ddzSettings:showPlayer(uid, seat_id)

            local HandCardCount = data["HandCardCount"]
            local playerType = ddzSettings:getPlayerType(seat_id)
            local sex = DDZ_USERINFO_TABLE[uid].sex

            GamePlaneOperator:setRestCardNum(playerType, HandCardCount, sex)
        end

    end


    --牌局状态
    if GAME_TYPE ~= 3 then 
        CardPlaneOperator:sendBaseCard()
    end

    local xFlag = 1

    --4 就是代表包庄状态
    if GAME_STATE == 4  then
        --包庄状态
        iTotalTimes = pack["Landscore"]
        xFlag = 1

        local curUid  = pack["Curlandlordscore"]
        local seat = DDZ_SEAT_TABLE[curUid]

        --叫地主返回
        if curUid > 0 then
            if(curUid == USER_INFO["uid"]) then
                local Landscore = pack["Landscore"]
                ControlPlaneOperator:showControlButtons(2,nil,Landscore)
                if pack["Landscore"] > 0 then
                    call_bet_first = 1
                end
            end
            
            local playerType = ddzSettings:getPlayerType(seat) 
            -- GamePlaneOperator:clockAnimation(playerType)
            GamePlaneOperator:beginPlayCard(playerType)
        end

    else


        iTotalTimes = pack["LandlordScore"]
        xFlag = 0

        --打牌阶段
        --三张地主牌
        if GAME_TYPE ~= 3 then

            LandLordSeatId = DDZ_SEAT_TABLE[pack["LandlordUserId"]]
            local   LandLordplayerType = ddzSettings:getPlayerType(LandLordSeatId)

            local   c  = Card.new()
            local   table_value = {}

            GamePlaneOperator:showLandLord(LandLordplayerType)

            for i,v in ipairs(pack["LandCarddata"])  do
                local card = Card:Decode(v)
                c:init(card)
                table.insert(table_value,{c._value,c._kind})
            end
            
            CardPlaneOperator:cardRotation(table_value)

        end

        --设置出牌的玩家
        local nseat = DDZ_SEAT_TABLE[pack["OutCardUserId"]] --当前出牌玩家座位号
        local playerType2 = ddzSettings:getPlayerType(nseat)  --当前出牌玩家类型
    
        -- local preSeat = ddzSettings:getPreOutCardSeatId(nseat) 
       
        for i,v in pairs(pack["LastCarddata"]) do
             
            local seat = i-1
            local playerType1 = ddzSettings:getPlayerType(seat)  --上一个出牌的玩家类型

            if v["CardCount"]~=0 then

                if  playerType1 ~= CARD_PLAYERTYPE_MY then
                    mustOutCard = false 
                end
                
                local c_table = {}
                local c  = Card.new()
                for i,v in ipairs(v["cards"])  do
                    local card = Card:Decode(v)
                    c:init(card)
                    table.insert(c_table,{c._value,c._kind})
                end

                if playerType1 ~= playerType2 then

                    GamePlaneOperator:clearUserDesk(playerType1)
                    CardPlaneOperator:clearOutCards(playerType1)

                    local tm_table = CardPlaneOperator:showOtherCardRank(c_table)
 
                     SCENENOW["scene"]:performWithDelay(function()
                         CardPlaneOperator:showOutCard(tm_table,seat) 
                        end,0.1*i)
                    
                    --给玩家出牌表赋值
                    --自己
                    if seat == MY_SEAT_ID then
                        tbPlayCardInfo["last_cards"] = nil
                        tbPlayCardInfo["card_type"] = nil
                    else

                        local cardType = CardAnalysis:getType(c_table) 

                        if tbPlayCardInfo["card_type"] == nil or 
                           cardType > tbPlayCardInfo["card_type"] then
                            
                            tbPlayCardInfo["last_cards"] = c_table
                            tbPlayCardInfo["card_type"]  = cardType
                        
                        end
                    end
                end
            end
        end

        local nPlayerType = ddzSettings:getPlayerType(nseat) 

        SCENENOW["scene"]:performWithDelay(function()
            GamePlaneOperator:beginPlayCard(nPlayerType, pack["LeftTime"])
            -- GamePlaneOperator:clockAnimation(nPlayerType, pack["LeftTime"]) 
        end,0.1)
  
        if nseat == MY_SEAT_ID then
            GamePlaneOperator:clearUserDesk(nPlayerType)
            CardPlaneOperator:clearOutCards(nPlayerType)
            ControlPlaneOperator:showControlButtons(4, nil, 1,0,1,0)
        end

    end


    --设置底分和倍数
    GamePlaneOperator:setBaseChip(pack["Basechip"])

    if GAME_TYPE ~= 3 then
        GamePlaneOperator:setBaseTime(iTotalTimes,xFlag)
    end

    --玩家剩余牌数
    CardPlaneOperator:updateSendCard(pack["HandCardDatas"])

    --隐藏邀请好友按钮
    SCENENOW["scene"]:showShareButton(false)
    
    if isOpenControl == true then
        ddzServer:CLI_SEND_APPLY_FOR_SPECIAL_PERMISSION()
    else
        ddzServer:CLI_SEND_CANCEL_FOR_SPECIAL_PERMISSION()
    end


end

--游戏开始
function xhdzHandle:SVR_GAME_START(pack)
    
    dump(pack,"-----游戏开始--------")
        --切牌
    g_mainScene.playerInfoLayer:setQiePaiPanelVisible(false)
    g_mainScene.playerInfoLayer:hideAllPlayerReady() -- 清理准备标志
    g_mainScene.playerInfoLayer:setInviteVisible(false)-- 隐藏邀请按钮
    g_mainScene.tableLayer:clearAllOutCards()--清理桌面上的牌
    g_mainScene.playerInfoLayer:setPiaoVisible(false)
    g_mainScene.playerInfoLayer:clearAllScoreInfo()
    g_mainScene.playerInfoLayer:hideBtn()
    --g_mainScene.playerInfoLayer:hideAllPiaoTipsIco()
end




--游戏准备返回 6001
function xhdzHandle:SVR_READY_GAME(pack) 
    dump(pack,"游戏准备返回--------6001---------")

    g_mainScene.playerInfoLayer:setReadyStateByUId(pack.uid)
end
 

--发牌 4001
function xhdzHandle:SVR_DEAL(pack)--发牌
        
    dump(pack,"SVR_DEAL")
    local singleResultLayer = g_mainScene:getChildByName("singleResultLayer")
    if singleResultLayer and not tolua.isnull(singleResultLayer) then
        singleResultLayer:removeFromParent()
    end
    self:SVR_GAME_START()

    --隐藏包庄
    g_mainScene.playerInfoLayer:hideAllPiaoTipsIco()
    g_mainScene.playerInfoLayer:setDuiyouFlag(pack.FriendUserId)

    g_mainScene.playerInfoLayer:cleanMyHandsCards()
    g_mainScene.playerInfoLayer.qiepai_vw:setVisible(false)
    g_mainScene.playerInfoLayer:resetQiePai()
    g_mainScene.playerInfoLayer:setHandCardsAndOtherCardSize(pack.HandCardDatas, pack.CardCount, pack.CardCount, pack.nOutCardUserId)

end


--通知开始包庄 0x4003
function xhdzHandle:SVR_SELECTUNDERTAKE(pack)

    --如果这个是自己则显示出来 面板
    dump(pack,"SVR_SELECTUNDERTAKE pack")
    dump(MY_SEAT_ID,"SVR_SELECTUNDERTAKE MY_SEAT_ID")

    self:SVR_GAME_START()
    if MY_SEAT_ID == pack.nSelectSeat then
        g_mainScene.playerInfoLayer:setPiaoVisible(true)
    end

    g_mainScene.playerInfoLayer:HideZhuangFlag()

end

--服务器广播玩家操作包庄结果
function xhdzHandle:SVR_SELECTUNDERTAKERESULT(pack)
    
    dump(pack,"SVR_SELECTUNDERTAKERESULT pack")

    if MY_SEAT_ID == pack.nUserSeat then
        g_mainScene.playerInfoLayer:setPiaoVisible(false)
    else
        --其他玩家头顶飘显示出来
        g_mainScene.playerInfoLayer:showPiaoTipsIco(pack.uid, pack.isSelect)
    end

    if pack.isSelect == 1 then
        g_mainScene.playerInfoLayer:setZhuangFlag(pack.uid)
    end

end

--服务器广播PASS
function xhdzHandle:SVR_BROADCAST_PASS(pack)
    -- body
    dump(pack,"xhdzHandle:SVR_BROADCAST_PASS")
    if USER_INFO.uid == pack.uid then
        g_mainScene.playerInfoLayer:showOutCardBtn(false)
        g_mainScene.playerInfoLayer:showPassFontByUId(pack.uid)
        g_mainScene.playerInfoLayer:clearHandlerCardsSelect() --重置手牌到原来的位置
    end
end


--服务器广播捡分变化
function xhdzHandle:SERVER_BROADCAST_USER_GAIN_SCORE(pack)
    -- body
    dump(pack,"xhdzHandle:SERVER_BROADCAST_USER_GAIN_SCORE")

    g_mainScene.playerInfoLayer:pickScoreUpdate(pack.uid, pack.pickScore)

end


--服务器喜分与炸弹数量变化
function xhdzHandle:SERVER_BROADCAST_USER_BOMB_FEN(pack)
    
    dump(pack,"xhdzHandle:SERVER_BROADCAST_USER_BOMB_FEN")
    --for i, v in ipairs( pack.ScoreData or {} ) do
    g_mainScene.playerInfoLayer:bombHappyUpdate(pack)
end



--广播通知那个玩家出牌  0x1207
function xhdzHandle:SVR_BROADCAST_NOTICE_USER_OUTCARD(pack)
    dump(pack, "SVR_BROADCAST_NOTICE_USER_OUTCARD")
    if pack.canOutCards == 0 then
        -- local info = {}
        -- info.nPassUserId = pack.nOutCardUserId
        -- g_mainScene.playerInfoLayer:processUserPass(info)
        g_mainScene.playerInfoLayer:processUserPassCard(pack.nOutCardUserId)
    else
        g_mainScene.playerInfoLayer:processBeginOutCard(pack.nOutCardUserId, pack.outTime, pack.firstOutCards)
    end

    --如果是第一个出牌了 广播消息了  清理掉每个玩家出牌面板上的牌
    if pack.firstOutCards == 1 then
        g_mainScene.tableLayer:clearAllOutCards()--清理桌面上的牌
    end
end


--服务器通知出牌 6005
function xhdzHandle:SVR_PLAY_CARD(pack)
    dump(pack, "SVR_PLAY_CARD")
    g_mainScene.playerInfoLayer:processUserOutHandCards(pack)
end

--出牌错误 4002
function xhdzHandle:SVR_PLAY_CARD_ERROR(pack)
    dump(pack, "SVR_PLAY_CARD_ERROR")
    g_mainScene.playerInfoLayer:processUserOutCardsError(pack)
end

--不出 6006
function xhdzHandle:SVR_PASS(pack)
    dump(pack, "SVR_PASS")
    g_mainScene.playerInfoLayer:processUserPass(pack)
end

--不出 6006
function xhdzHandle:SVR_ALERT(pack)
    dump(pack, "SVR_ALERT")
    g_mainScene.playerInfoLayer:processUserAlert(pack)
end

--游戏结束 6008 单局结算
function xhdzHandle:SVR_GAME_OVER(pack)
    
    dump(pack,"SVR_GAME_OVER")
    for i, v in ipairs( pack.playerList or {} ) do
        dump(v.Cardbuf)
    end
    g_mainScene.playerInfoLayer:processSingleGameOver(pack)
end

function xhdzHandle:SERVER_SEND_TURN_RESULT(pack)
    -- body
    dump(pack,"SERVER_SEND_TURN_RESULT")
    for i, v in ipairs( pack.playerList or {} ) do
        dump(v.Cardbuf)
    end

    g_mainScene.playerInfoLayer:hideDuiyouFlag()    --清理队友标志
    g_mainScene.playerInfoLayer:cleanMyHandsCards() --清理当前手牌

    g_mainScene.playerInfoLayer:processSingleGameOver(pack)
end


--组局排行榜 5100  游戏结束时
function xhdzHandle:SVR_GROUP_BILLBOARD(pack)
    dump(pack, "SVR_GROUP_BILLBOARD")
    -- SCENENOW["scene"]:performWithDelay(function()
    --     g_mainScene:showAllResultLayer(pack)
    -- end,2)
    g_mainScene.tgLayer:hideTg()
    g_mainScene:showAllResultLayer(pack)
end




--接收奖励手牌 6024
function xhdzHandle:SVR_BROADCAST_BONUS(pack)
    
    local LandLordUid = pack.LandLordUid

    FARMER_BONUS_CARDS = {}

    for _,data in pairs(pack.playerlist) do
       
        if data.cardCount > 0 then

            local seatId = DDZ_SEAT_TABLE[data.uid]
            local playerType = ddzSettings:getPlayerType(seatId)
           
            if  data.uid == LandLordUid then
                -- if  playerType~= CARD_PLAYERTYPE_MY then
                --     CardPlaneOperator:drawUserCards(pack.cardList,playerType)
                --     SCENENOW["scene"]:performWithDelay(function()
                --         if  mingpaiState ~= 2 then
                --             CardPlaneOperator:clearUserCards(playerType)
                --         end
                --     end,8)  
                -- else   
                    local c_table = {}
                    local c  = Card.new()
                    -- for _,cardValue in ipairs(pack["cardList"])  do
                    for i = #data["cardList"],1,-1 do
                        local cardValue = data["cardList"][i]
                        
                        local card = Card:Decode(cardValue)
                        c:init(card)
                        table.insert(c_table,{c._value,c._kind})
                    end

                    local record_info = {}
                    record_info["cards"]=c_table
                    record_info["bonus_score"]=data["bonus_score"]

                    CardPlaneOperator:updateCardRecord(DDZ_USERINFO_TABLE[data.uid]["nick"],record_info,4)
                    CardPlaneOperator:showBonusCards(c_table,seatId)
                -- end
            else
                    local c_table = {}
                    local c  = Card.new()
                    -- for _,cardValue in ipairs(data["cardList"])  do
                    for i = #data["cardList"],1,-1 do
                        local cardValue = data["cardList"][i]
                        
                        local card = Card:Decode(cardValue)
                        c:init(card)
                        table.insert(c_table,{c._value,c._kind})
                    end

                    local record_info = {}
                    record_info["cards"]=c_table
                    record_info["bonus_score"]=data["bonus_score"]

                    FARMER_BONUS_CARDS[data.uid] = record_info

                    CardPlaneOperator:showBonusCards(c_table,seatId,nil,"hide")
                
            end
        end

    end
end

--接收明牌信息  6023
function xhdzHandle:SVR_BROADCAST_MINGPAI(pack)
    -- mingpaiState = 2
    local seatId = DDZ_SEAT_TABLE[pack.uid]
    local playerType = ddzSettings:getPlayerType(seatId)
    if  playerType ~= CARD_PLAYERTYPE_MY then
        CardPlaneOperator:drawUserCards(pack.cardList,playerType)
    end
end


--组局时长 5101
function xhdzHandle:SVR_GROUP_TIME(pack)
    dump(pack, "SVR_GROUP_TIME")
    g_mainScene.roomCommonLayer:setRoomRound(pack["round"], pack["round_total"])
    --add by zzy 2019-7-17 游戏没有开始屏蔽解散房间
    SCENENOW["scene"].GameRound = pack.round
    SCENENOW["scene"].isTouxiang = nil
end

--------------------------------------周边功能-----------------------------------------
--扣除台费 4800
function xhdzHandle:SVR_CHIP_CHANGE_BROADCAST(pack)

    for _,data in pairs(pack.userinfo) do

        local uid = data.uid

        local coins = g_mainScene.playerInfoLayer:getUserScore(uid)
        coins = coins + data.change_chip/100
        -- GamePlaneOperator:updateCoin(playerType, userInfo.coins)
        g_mainScene.playerInfoLayer:exchangeUserScore(uid, coins)

        if  uid == USER_INFO["uid"] then
            ----GamePlaneOperator:showTaiFeiTips(data.change_chip)
        end

    end
end


--组局解散相关
--没有此房间，解散房间失败
function xhdzHandle:G2H_CMD_DISSOLVE_FAILED(pack)

    --dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")
    -- require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")
end

--广播当前组局解散情况
function xhdzHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)

    dump(pack, "-----广播当前组局解散情况-----")

    g_mainScene.playerInfoLayer:processRevcDisbandInfo(pack)

end

--广播桌子用户请求解散组局
function xhdzHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

    --dump(pack, "-----广播桌子用户请求解散组局-----")

    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")

end

--广播桌子用户成功解散组局
function xhdzHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

    -- if IS_ROOM_CARD_TYPE then
    print("SERVER_BROADCAST_DISSOLVE_GROUP -------------")
    dump("SERVER_BROADCAST_DISSOLVE_GROUP -------------")
    g_mainScene.roomCommonLayer:processRevcDisbandRoomSucc()

    -- end

end

--广播桌子用户解散组局 ，解散组局失败
function xhdzHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

    dump(pack, "-----广播桌子用户解散组局 ，解散组局失败-----")
   g_mainScene.playerInfoLayer:processRevcRejectDisband(pack)
    do return end

    local rejectId = pack.rejectId
    if rejectId == USER_INFO["uid"] then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
    else
        if DDZ_USERINFO_TABLE ~= nil then
            if DDZ_USERINFO_TABLE[rejectId] ~= nil then
                --dump(DDZ_USERINFO_TABLE, "rejecter_info")
                local rejecter_info = DDZ_USERINFO_TABLE[rejectId]
                --dump(rejecter_info, "rejecter_info")
                require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, rejecter_info.nick .. "拒绝解散房间")
            end
        end
    end

end

--聊天
function xhdzHandle:SVR_MSG_FACE(pack)

    g_mainScene.playerInfoLayer:processFaceAndTxt(pack)
    do return end
end
-----------------------------------------------------------------------------------------------------------------------------
function xhdzHandle:showExpression(msg)
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

    local to_x   = PLAYER_HEADS_POSITION_TABLE[uid_to].x
    local to_y   = PLAYER_HEADS_POSITION_TABLE[uid_to].y

    require("hall.view.animView.animView"):ShowAnimationByPosition(from_x, from_y,to_x,to_y,expressionType)        
end

function xhdzHandle:showTextMessage(pack)

    local s= SCENENOW["scene"]:getChildByName("faceUI")

    local uid = pack.uid
    local seatId = DDZ_SEAT_TABLE[uid]
    local playerType = ddzSettings:getPlayerType(seatId)

    local isLeft = false
    if playerType == CARD_PLAYERTYPE_RIGHT then
        isLeft = true
    end

    local node_head = PLAYER_HEADS_TABLE[uid] --GamePlaneOperator:getPlayerHeadPlane(playerType)

    s:showGetText(uid,pack.textMessage,tonumber(sex),node_head, isLeft)  
end

--接收服务器返回的组局信息
function xhdzHandle:SERVER_CMD_MESSAGE(pack)

    dump(pack, "SERVER_CMD_MESSAGE")

    -- do return end

    if bm.isInGame == false then
        return
    end
    
    local msg = json.decode(pack.msg)
    --dump(msg, "-----NiuniuroomHandle 接收服务器返回的组局信息-----")
    if msg ~= nil then
        local msgType = msg.msgType
        if msgType ~= nil and msgType ~= "" then

            if msgType == "expression" then   --表情
                self:showExpression(msg)
            elseif  msgType == "text" then   --文字聊天
                self:showTextMessage(msg)
            elseif  msgType == "emoji" then   --文字聊天
                self:SVR_MSG_FACE(msg)
            elseif  msgType == "EmojiArmatureView" then   --动态表情
                self:SVR_MSG_EMOJI_ARMATURE(msg)
            end

            if device.platform == "ios" then

                if msgType == "voice" then
                    --dump("voice", "-----接收服务器返回的组局信息-----")
                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                     --通知本地播放录音
                     local arr = {}
                     arr["url"] = msg.url
                     cct.getDateForApp("playVoice", arr, "V")

                elseif msgType == "video" then
                    --dump("video", "-----接收服务器返回的组局信息-----")

                    local arr = {}
                    arr["url"] = msg.url
                    cct.getDateForApp("playVideo", arr, "V")

                end

            else

                if msgType == "voice" then
                    --dump("voice", "-----接收服务器返回的组局信息-----")

                    -- require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)
                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                     --通知本地播放录音

                     local data = {}
                     data["url"] = msg.url
                    
                     local arr = {}
                     table.insert(arr, json.encode(data))
                     cct.getDateForApp("playVoice", arr, "V")

                elseif msgType == "video" then
                    --dump("video", "-----接收服务器返回的组局信息-----")
                    
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

function xhdzHandle:SVR_MSG_EMOJI_ARMATURE(pack)

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
        local fromPos = PLAYER_HEADS_POSITION_TABLE_FACE[from_id]
        local toPos = PLAYER_HEADS_POSITION_TABLE_FACE[to_uid]
        if toPos and fromPos then
            EmojiArmatureView:showAnimi(toPos, fromPos, emojiType)
        end
    end

end

--接收服务器返回的缓存信息 0213
function xhdzHandle:SERVER_CMD_FORWARD_MESSAGE(pack)

    dump(pack, "-----xhdzHandle 接收服务器返回的缓存信息-----")
  
    local msgList = pack.msgList
    for k,v in pairs(msgList) do
        if v ~= nil and v ~= "" then
            local msg = json.decode(v)
            if msg ~= nil and msg ~= "" then
                if msg.uid ~= nil and msg.uid ~= "" then
                    if  next(DDZ_SEAT_TABLE)~=nil then
                        local seatId = DDZ_SEAT_TABLE[msg.uid]
                        if seatId then
                            local playerType = ddzSettings:getPlayerType(seatId)
                            if  tonumber(msg.longitude) ~= 0 and not LocaArrayByPlayerType[playerType] then
                                LocaArrayByPlayerType[playerType] = {[1] = tonumber(msg.longitude) ,[2] = tonumber(msg.latitude)}
                            end
                        end
                    end
                    
                    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(msg.uid, msg)
                end
            end
        end
    end
end

function xhdzHandle:SVR_SEND_MINGPAI_REMIND(pack)
    dump(pack , "SVR_SEND_MINGPAI_REMIND")
    dump(pack.HandCardDatas , "SVR_SEND_MINGPAI_REMIND_HandCardDatas")

    for k , v in pairs(pack.HandCardDatas) do 

        local card_data = clone(v.card_datas)
        card_data = g_mainScene.playerInfoLayer:exchangeCardsValue(card_data)
        g_mainScene.tableLayer:ShowPlayCard(v.user_id , card_data)
    end

end


function xhdzHandle:SERVER_SEND_SINGE_DATA(pack)
    g_mainScene.playerInfoLayer:showCheckTip(pack["uid"])

end

--接收服务器放回的指定用户信息pack111
function xhdzHandle:SVR_CHARGE_BROADCAST(pack)
    dump(pack,"pack111")
   
    local uid = pack.uid

    -- local seat = DDZ_SEAT_TABLE[uid]
    -- if not (seat) then return end
    -- local playerType = ddzSettings:getPlayerType(seat)
    -- local userInfo = DDZ_USERINFO_TABLE[uid]

    local coins = g_mainScene.playerInfoLayer:getUserScore(uid) 
    coins = coins + pack.chargeCoins/100
    -- GamePlaneOperator:updateCoin(playerType, userInfo.coins)
    g_mainScene.playerInfoLayer:exchangeUserScore(uid, coins)

    --上分提示
    for k,v in pairs(g_mainScene.userInfoByViewId) do
        if pack.uid == k then
            local str = require('hall.GameCommon'):formatNick(v.nickName, 4) .. "(" .. pack.uid .. ")"
            viewMgr:showTip({text = "玩家:" .. str .. "被上" .. ( pack.chargeCoins / 100) .. "积分"})
        end
    end
end
function xhdzHandle:SERVER_COMMAND_AUTO(pack)
    dump(pack, "SERVER_COMMAND_AUTO")
    tableAI[pack.uid] = pack.m_bAIUser
    if pack.m_bAIUser == 1 then
        g_mainScene.tgLayer:showTg()
    else
        g_mainScene.tgLayer:hideTg()
    end
end

--广播开始游戏倒计时 100F广播切牌
function xhdzHandle:SVR_BROADCAST_COUNT_DOWN(pack)
    dump(pack, "------广播开始游戏倒计时 切牌 100F------")
    local singleResultLayer = g_mainScene:getChildByName("singleResultLayer")
    if singleResultLayer then
        singleResultLayer:removeSelf()
    end
    if pack.time > 0 then
        --设置准备转态不可见
        dump(pack,"-----切牌时间")
        dump(USER_INFO.uid,"-----切牌玩家ID")
        self:SVR_GAME_START()
        g_mainScene.playerInfoLayer:cleanMyHandsCards()
        if USER_INFO.uid == pack.uid then
            g_mainScene.playerInfoLayer:showQiepai(pack.time)
        else
            g_mainScene.playerInfoLayer:showClock(USER_INFO["uid"],pack.time)
        end
    end
end

--广播开始游戏倒计时 广播洗牌
function xhdzHandle:SERVER_BROADCAST_SHUFFLE_ANI(pack)
    dump(pack, "SERVER_BROADCAST_SHUFFLE_ANI = ")
    local singleResultLayer = g_mainScene:getChildByName("singleResultLayer")
    if singleResultLayer then
        singleResultLayer:removeSelf()
    end

    g_mainScene.playerInfoLayer:cleanMyHandsCards()
    g_mainScene.tableLayer:showShuffleCard()
end

function xhdzHandle:SERVER_BROADCAST_REQUEST_SURRENDER(pack)    
    local playerLst = g_mainScene.playerInfoLayer:getUserInfoLstToDisband(pack.applyId)
    local info = {}
    info.userLst = playerLst
    info.txtDes = "玩家投降"
    info.callBackReject = handler(self, function()
        xhdzServer:C2G_CMD_OPT_SURRENDER(2)--1 同意，2为拒绝
    end)
    info.callBackSure = handler(self, function()
        xhdzServer:C2G_CMD_OPT_SURRENDER(1)--1 同意，2为拒绝
    end)
    self.DisbandLayer = require("hall.tips.DisbandLayer"):showDisbandLayer(info)
    self.DisbandLayer:setTimes(180)
    self.DisbandLayer.touxiangNum = 1
end

function xhdzHandle:SERVER_BROADCAST_OPT_SURRNEDER(pack)-- 1 同意  2 拒绝
    if not self.DisbandLayer then
        return
    end
    if pack.opt == 2 then
        local paras = {}
        paras.type = 1
        paras.title = "提示"
        paras.content = string.format("投降失败,玩家拒绝投降!")
        require("hall.tips.CommonTips"):showTips(paras)
        self.DisbandLayer:removeFromParent()
        self.DisbandLayer = nil
    else
        local data = {[1] = 1, [2] = 0}
        self.DisbandLayer:exChangeState({userId = pack.curUid, state = data[pack.opt]})
        self.DisbandLayer.touxiangNum  = self.DisbandLayer.touxiangNum + 1
        local num = g_mainScene.playerInfoLayer:getPlayerInfo()
        if self.DisbandLayer.touxiangNum == #num then
            self.DisbandLayer:removeFromParent()
            self.DisbandLayer = nil
        end
    end
end

return xhdzHandle

--测试性能专用代码
--   local t1 = os.time();
--   for  i =1,10000000  do
--    local playerType = math.random(1,4)
--        self:getPlayerPlane(playerType)
-- end

-- local t2 = os.time();
-- print(os.difftime(t2, t1),"运行时间");
