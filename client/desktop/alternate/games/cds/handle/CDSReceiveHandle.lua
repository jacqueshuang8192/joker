local hallHandle = require("hall.HallHandle")
-- local GamePlaneOperator = require(TpackageName .. ".operator.GamePlaneOperator")

local PROTOCOL = import(TpackageName .. ".handle.CDSProtocol")

local CDSReceiveHandle  = class("CDSReceiveHandle", hallHandle)

local run_scene_name = TpackageName..".gameScene"

function CDSReceiveHandle:ctor()

	CDSReceiveHandle.super.ctor(self);

	local func_ = {
         
        --进入游戏成功 0210
        --[PROTOCOL.SVR_GET_ROOM_OK] = {handler(self, CDSReceiveHandle.SVR_GET_ROOM_OK)},
        --登录房间成功 1007
        [PROTOCOL.SVR_LOGIN_ROOM] = {handler(self, CDSReceiveHandle.SVR_LOGIN_ROOM)},
        --进入房间失败
        [PROTOCOL.SVR_LOGIN_ROOM_FAIL] = {handler(self, CDSReceiveHandle.SVR_LOGIN_ROOM_FAIL)},

        --广播其他用户坐下（金币场） 1031
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, CDSReceiveHandle.BROADCAST_USER_SIT_DOWN)},
        --广播用户退出房间 1032
        [PROTOCOL.BROADCAST_USER_STAND_UP] = {handler(self, CDSReceiveHandle.BROADCAST_USER_STAND_UP)},

        --广播其他用户登录桌子 100D
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, CDSReceiveHandle.SVR_LOGIN_ROOM_BROADCAST)},

        --广播用户退出房间 100E
        [PROTOCOL.SVR_QUIT_ROOM]            = {handler(self, CDSReceiveHandle.SVR_QUIT_ROOM)},
        --广播用户退出房间 1033
        [PROTOCOL.BROADCAST_USER_QUIT_ROOM] = {handler(self, CDSReceiveHandle.BROADCAST_USER_QUIT_ROOM)},
 
        --用户退出房间成功（自己）
        [PROTOCOL.SVR_QUICK_SUC]            = {handler(self, CDSReceiveHandle.SVR_QUICK_SUC)},

        --0x2001    --广播用户准备
        [PROTOCOL.SERVER_READYNOW_ROOM]            = {handler(self, CDSReceiveHandle.SERVER_READYNOW_ROOM)},

        --错误提示5001
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, CDSReceiveHandle.BROADCAST_ERROR_TIPS)},
              
        --广播用户托管1034
        [PROTOCOL.BROADCAST_USER_AUTO_PLAY] = {handler(self, CDSReceiveHandle.BROADCAST_USER_AUTO_PLAY)},

        --发牌 4001
        --[PROTOCOL.SVR_SEND_USER_CARD]       = {handler(self, CDSReceiveHandle.SVR_SEND_USER_CARD)},

        --1043  广播玩家摊牌
        --[PROTOCOL.SVR_OPEN_CARDS_BROADCAST]            = {handler(self, CDSReceiveHandle.SVR_OPEN_CARDS_BROADCAST)},

         --111 广播玩家充值
        --[PROTOCOL.SVR_CHARGE_BROADCAST]       = {handler(self, CDSReceiveHandle.SVR_CHARGE_BROADCAST)},

    	--6008  单局结算（阶段广播）
    	[PROTOCOL.SVR_SETTLEMENT_BROADCAST]       = {handler(self, CDSReceiveHandle.SVR_SETTLEMENT_BROADCAST)},

    	--5100，广播总结算
    	[PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, CDSReceiveHandle.SVR_GROUP_BILLBOARD)},

    	--广播当前回合
    	[PROTOCOL.SVR_GROUP_TIME] = {handler(self, CDSReceiveHandle.SVR_GROUP_TIME)},

        --请求带控返回
        [PROTOCOL.SERVER_CMD_REQ_TEST] = {handler(self, CDSReceiveHandle.SERVER_CMD_REQ_TEST)},

        --请求牌值返回
    	[PROTOCOL.SERVER_CMD_TEST] = {handler(self, CDSReceiveHandle.SERVER_CMD_TEST)},

        --请求录纸返回
        [PROTOCOL.SERVER_CMD_RECORD_PAPER] = {handler(self, CDSReceiveHandle.SERVER_CMD_RECORD_PAPER)},

    	--没有此房间，解散房间失败
     	[PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, CDSReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},

     	--广播桌子用户请求解散组局
     	[PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, CDSReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},

     	--广播当前组局解散情况
     	[PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, CDSReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},

     	--广播桌子用户成功解散组局
     	[PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, CDSReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},

     	--广播桌子用户解散组局 ，解散组局失败
     	[PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, CDSReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},

    	--文字聊天相关
     	--[PROTOCOL.SVR_MSG_FACE]     = {handler(self, CDSReceiveHandle.SVR_MSG_FACE)},

        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, CDSReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},
        --接收服务器返回801
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, CDSReceiveHandle.SERVER_CMD_MESSAGE)},

        -- 0x110A   --- 出牌时间
        [PROTOCOL.SERVER_BROADCAST_START_OUT_CARD] = {handler(self, CDSReceiveHandle.SERVER_BROADCAST_START_OUT_CARD)},
        -- --接收IP信息 106A
        -- [PROTOCOL.BROADCAST_USER_IP] = {handler(self, CDSReceiveHandle.BROADCAST_USER_IP)},

        [PROTOCOL.SERVER_NOTIFY_RESULT] = {handler(self, CDSReceiveHandle.SERVER_NOTIFY_RESULT)},
        [PROTOCOL.SERVER_BROADCAST_START_YA] = {handler(self,CDSReceiveHandle.SERVER_BROADCAST_START_YA)},
         -- 0x1101   --- 广播押注
        [PROTOCOL.SERVER_BROADCAST_YA] = {handler(self,CDSReceiveHandle.SERVER_BROADCAST_YA)},
        --0x1102
        [PROTOCOL.SERVER_BROADCAST_CARD] = {handler(self,CDSReceiveHandle.SERVER_BROADCAST_CARD)},
        [PROTOCOL.SERVER_BROADCAST_OUT_CARD] = {handler(self,CDSReceiveHandle.SERVER_BROADCAST_OUT_CARD)},
        
        --0x1104   --- 开牌
        [PROTOCOL.SERVER_BROADCAST_OPEN_CARD] = {handler(self,CDSReceiveHandle.SERVER_BROADCAST_OPEN_CARD)},

        -- [PROTOCOL.SERVER_CMD_REQ_YAZHU_INFO] = {handler(self,CDSReceiveHandle.SERVER_CMD_REQ_YAZHU_INFO)},
        -- [PROTOCOL.SERVER_CMD_REQ_YAZHU_DETAILS] = {handler(self,CDSReceiveHandle.SERVER_CMD_REQ_YAZHU_DETAILS)},
        -- [PROTOCOL.SERVER_BROADCAST_GIVE_COINS] = {handler(self,CDSReceiveHandle.SERVER_BROADCAST_GIVE_COINS)},
        --0x1109--单局结算
        [PROTOCOL.SERVER_BROADCAST_WINLOSE_COUNT] = {handler(self,CDSReceiveHandle.SERVER_BROADCAST_WINLOSE_COUNT)},

        --显示开始游戏按钮显示开始游戏按钮 0x2006 
        [PROTOCOL.SERVER_BROADCAST_START_GAME] = {handler(self,CDSReceiveHandle.SERVER_BROADCAST_START_GAME)},
        
        -- --广播游戏开始倒计时
        [PROTOCOL.SVR_BROADCAST_WAIT_START]           = {handler(self, CDSReceiveHandle.SVR_BROADCAST_WAIT_START)},

        -- -- --广播开始准备 6009 （阶段广播）
        -- [PROTOCOL.SVR_READY_TIME]           = {handler(self, CDSReceiveHandle.SVR_READY_TIME)},
        -- -- --广播用户准备 6001
        -- [PROTOCOL.SVR_READY_BROADCAST]      = {handler(self, CDSReceiveHandle.SVR_READY_BROADCAST)},

        --发送剩余手牌
        --[PROTOCOL.SVR_SEND_USED_CARDS]      = {handler(self, CDSReceiveHandle.SVR_SEND_USED_CARDS)},

     --    --告知庄家可以开始游戏
    	-- [PROTOCOL.SERVER_COMMAND_REMAID_START_GAME] = {handler(self, CDSReceiveHandle.SERVER_COMMAND_REMAID_START_GAME)},
    	-- --告知庄家不可以开始游戏
    	-- [PROTOCOL.SERVER_COMMAND_REMAID_START_GAME_FAIL] = {handler(self, CDSReceiveHandle.SERVER_COMMAND_REMAID_START_GAME_FAIL)},

        --广播游戏开始
        [PROTOCOL.SVR_BROADCAST_GAME_START]       = {handler(self, CDSReceiveHandle.SVR_BROADCAST_GAME_START)},

     --    --广播开始抢庄（阶段广播）
     --    [PROTOCOL.SVR_BEGIN_QIANFGZHUANG_BROADCAST]       = {handler(self, CDSReceiveHandle.SVR_BEGIN_QIANFGZHUANG_BROADCAST)},
     --    --广播抢庄过程
     --    [PROTOCOL.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST]       = {handler(self, CDSReceiveHandle.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST)},
    	-- --广播庄家
    	-- [PROTOCOL.SVR_BRANK_BROADCAST]            = {handler(self, CDSReceiveHandle.SVR_BRANK_BROADCAST)},

     --    --7001 广播可以开始加倍（阶段广播）
    	-- [PROTOCOL.SVR_SEND_BASES_TO_USER_BROADCAST]      = {handler(self, CDSReceiveHandle.SVR_SEND_BASES_TO_USER_BROADCAST)},
     --    --6014 广播加倍倍数
    	-- [PROTOCOL.SVR_USER_BASES_RESULT_BROADCAST]            = {handler(self, CDSReceiveHandle.SVR_USER_BASES_RESULT_BROADCAST)},

        --1041 下注剩余时间
        [PROTOCOL.BROADCAST_SENDCARD_REMAINDTIME] = {handler(self, CDSReceiveHandle.BROADCAST_SENDCARD_REMAINDTIME)},

        --6010 停止下注
        [PROTOCOL.BROADCAST_STOP_XIAZHU] = {handler(self, CDSReceiveHandle.BROADCAST_STOP_XIAZHU)},

        --0x600B 摇色子
        [PROTOCOL.BROADCAST_YAOSHAIZI] = {handler(self, CDSReceiveHandle.BROADCAST_YAOSHAIZI)},

    	--6004 广播玩家开始出牌（阶段广播）
    	[PROTOCOL.SVR_PLAY_CARD_BROADCAST]            = {handler(self, CDSReceiveHandle.SVR_PLAY_CARD_BROADCAST)},

        --4008 广播玩家钱数变化（用于扣取台费）
        [PROTOCOL.SVR_CHIP_CHANGE_BROADCAST]       = {handler(self, CDSReceiveHandle.SVR_CHIP_CHANGE_BROADCAST)},

        --结算0x1105
        [PROTOCOL.SERVER_BROADCAST_RESULT]       = {handler(self, CDSReceiveHandle.SERVER_BROADCAST_RESULT)},

        --接收服务器放回的指定用户信息pack111
      -- [PROTOCOL.SERVER_CMD_HALL_GET_MESSAGE] = {handler(self, CDSReceiveHandle.SERVER_CMD_HALL_GET_MESSAGE)},  

        [PROTOCOL.SVR_USER_XIAZHU_DATA]       = {handler(self, CDSReceiveHandle.SVR_USER_XIAZHU_DATA)}, 

        --广播游戏的结果
        [PROTOCOL.SVR_BROADCAST_GAME_RESULT]       = {handler(self, CDSReceiveHandle.SVR_BROADCAST_GAME_RESULT)}, 

        --广播头像的显示
        [PROTOCOL.BROADCAST_SHOW_HEAD]       = {handler(self, CDSReceiveHandle.BROADCAST_SHOW_HEAD)}, 
        
    }
   
    table.merge(self.func_, func_)
    
end


--协议返回数据接收


--协议返回数据接收
function CDSReceiveHandle:callFunc(pack)
--[[    if SCENENOW["name"] ~= run_scene_name then
        print("当前场景不是牛牛游戏场景！")
        return
    end]]

	if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
	 	dump(pack.cmd,"收到协议，协议号为")
        self.func_[pack.cmd][1](pack)
    end

end



--结算0x1105
function CDSReceiveHandle:SERVER_BROADCAST_RESULT(pack)
    dump(pack, "-----结算0x1105-----")

end

--显示开始游戏按钮 0x2006 
function CDSReceiveHandle:SERVER_BROADCAST_START_GAME(pack)
    dump(pack, "-----显示开始游戏按钮-----")
    if pack.star_game_uid == USER_INFO.uid then
        local playerType = CDS_PLAYERTYPE_TABLE[pack.star_game_uid]
        if playerType then
            GamePlaneOperator:setReadyStatus(playerType,false)
        end
        GamePlaneOperator:RemaidStartGame(true)
    end
end

--进入房间失败
function CDSReceiveHandle:SVR_LOGIN_ROOM_FAIL(pack)

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
                 require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
             end

             require("hall.GameTips"):showTips("提示", "", 2, tbErrorCode[pack.errorCode],nil,exitFunc)
        else
            require("hall.GameTips"):showTips("提示", "", 1, tbErrorCode[pack.errorCode]) 
        end
    else
        require("hall.GameTips"):showTips("提示", "", 1, "未知的错误") 
    end

end


--登录房间 1007
function CDSReceiveHandle:SVR_LOGIN_ROOM(pack)
    dump(pack, "-----CDSReceiveHandle 猜单双登录房间 1007-----")

    require(NetworkLoadingView_filePath):removeView(888)
    USER_INFO["activity_id"] = pack.activityId
    USER_INFO["invote_code"] = pack.inviteCode

    if pack.club_id > 0 then
        CLUB_ID = pack.club_id
        USER_INFO["family_id"] = pack.club_id
    end 

    GAME_STATE    =  pack.tableStatus
    GAME_LOGIN_DATA = pack
	g_isWatch = pack.isWatch

    BASE_CHIP    =  pack.baseChip
    local gameConfig = pack.gameConfig
    local baseChip = pack.baseChip
    local gameConfig_string = USER_INFO["gameConfig"] or ""

    initialChip =0
    maxChip = 0

    isGoldGame =  pack.gamePattern
    USERS_READY_STATE[USER_INFO["uid"]] = 0
    HEART_BEAT_TID = USER_INFO["tid"]
    SCENENOW["scene"]:initGameView()

    GamePlaneOperator:initPlayerPlane(TOTAL_PLAYERNUM) 

    if MY_SEAT_ID >= 0 then  
        RELATIVE_SEAT_ID = MY_SEAT_ID

        local seat_id = MY_SEAT_ID
        local uid = USER_INFO["uid"]
        local userInfo = CDS_USERINFO_TABLE[USER_INFO["uid"]]
        local user_if_outline = 1
        CDSUtils:showPlayer(uid,seat_id,userInfo,user_if_outline)
    else          --没准备或者是围观
        RELATIVE_SEAT_ID = 0
    end


    SCENENOW["scene"]:updateRoomInfo(baseChip,GAME_TYPE_NAME,pack.inviteCode,nil,nil,gameConfig_string)
    SCENENOW["scene"]:registShareButtons(pack.inviteCode)

    --邀请按钮
    -- if GAME_STATE  == GAME_STATUS_STOP then
    --     SCENENOW["scene"]:showShareButton(true)
    -- else
    --     SCENENOW["scene"]:showShareButton(false)
    -- end

    SCENENOW["scene"]:showShareButton(false)
    
    --桌面总筹码
    if pack.tab_xiazhu_count  then
        GamePlaneOperator:showTotalXiaZhu(pack.tab_xiazhu_info)
    end

    --自己的总下注
    if pack.tab_xiazhu_count_my and pack.tab_xiazhu_count_my > 0 then
        GamePlaneOperator:showMyTotalXiaZhu(pack.tab_xiazhu_info_my)
    end

    --自己下注的筹码
    if pack.my_xiazhu_count and pack.my_xiazhu_count > 0 and GAME_STATE == GAME_STATUS_YA then
        GamePlaneOperator:onXiaZhuByChongLian(pack.my_xiazhu_info)
    end

    --显示战绩
    if pack.gameResults_count and pack.gameResults_count >0 then
        self:SVR_BROADCAST_GAME_RESULT(pack)
    end

    ---------------------------------显示信息玩家---------------------------------------
    local myUserInfo ={}
    myUserInfo["ready"] = 0
    myUserInfo["seat"] = -1
    myUserInfo["uid"]  = USER_INFO["uid"]
    myUserInfo["gold"] = pack.gold
    myUserInfo["nick"] = USER_INFO["nick"]
    myUserInfo["sex"]  = USER_INFO["sex"]
    myUserInfo["icon_url"] = USER_INFO["icon_url"]
    myUserInfo["latitude"] = USER_INFO["latitude"]
    myUserInfo["longitude"] = USER_INFO["longitude"] or "" .. "-" .. (USER_INFO["LocalCity"] or "")
    GAME_PARTICIPANTS = {}

    CDSUtils:collectPlayerData(myUserInfo)
    myUserInfo["gold"] = CDSUtils:goldMath(pack.gold)
    GamePlaneOperator:showMyPlayerInfo(myUserInfo, 1, 111)


    --显示其他头像
    self:BROADCAST_SHOW_HEAD(pack)
    
    --取消了
    -- local index = 1
    -- for _,v in pairs(pack.gamePlayerArr) do
    --     if v.uid ~= USER_INFO["uid"] and index < MAX_PLAYERNUM then
    --         CDSUtils:collectPlayerData(v)
    --         index = index + 1    
    --     end
    -- end

    -- local index = 1
    -- for i,v in pairs(pack.gamePlayerArr) do
    --     local uid =  v.uid
    --     if v.uid ~= USER_INFO["uid"] and index < MAX_PLAYERNUM then
    --         local userInfo = CDS_USERINFO_TABLE[uid]
    --         local user_if_outline = v.onLine

    --         local playerType = CDSUtils:getPlayerTypeBySeatId(v.seat)
    --         CDS_PLAYERTYPE_TABLE[uid] = playerType

    --         GamePlaneOperator:setPlayerHeadImg(playerType,userInfo)

    --         index = index + 1  
    --     end
    -- end


    if GAME_STATE  == GAME_STATUS_STOP then  --牌局结束 0
        GamePlaneOperator:startTimer(0,"准备开始：")
        self:SERVER_BROADCAST_START_GAME(pack)
    elseif GAME_STATE  == GAME_STATUS_START  then--牌局开始阶段 1 
        --显示游戏开始倒计时 
        pack.time = pack.outCardAniTime
        self:SVR_BROADCAST_WAIT_START(pack)
    elseif GAME_STATE == GAME_STATUS_YAOSHAIZI then  --摇色子阶段
        pack.time = pack.outCardAniTime
        self:BROADCAST_YAOSHAIZI(pack)
    elseif GAME_STATE == GAME_STATUS_YA then  --押注阶段
        pack.time = pack.outCardAniTime
        self:BROADCAST_SENDCARD_REMAINDTIME(pack)

        GamePlaneOperator:showKouPanZi(true)
    elseif GAME_STATE == GAME_STATUS_STOP_YA then  --封盘阶段 
        pack.time = pack.outCardAniTime
        self:BROADCAST_STOP_XIAZHU(pack)
        GamePlaneOperator:showKouPanZi(true)

    elseif GAME_STATE == GAME_STATUS_OPEN_CARD then  --开牌阶段
        self:SERVER_BROADCAST_OPEN_CARD(pack)
    elseif GAME_STATE == GAME_STATUS_WAIT_STOP then  --等待停止时间
        GamePlaneOperator:startTimer(pack.outCardAniTime,"即将开始")
        CDSUtils:clearPlayerGold()
        -- self:setBtnReady()
    end

   
   -- CDSSendHandle:CLIENT_CMD_REQ_YAZHU_INFO()
    ---------------------------------------------------------------------------------

    -- pack.tableStatus 的可能值
    -- 0 //牌局已结束
    -- 1 准备
    -- 2 等待用户抢庄
    -- 3 牌局开始
    -- 4 GRABDEALER
    -- 5 等待用户选择倍数
    -- 6 CALLTIMES
    -- 7 等待出牌
    -- 8 OUTCARD
    -- 9 ISSPECTATOR

    ----------------------------------------------------------------
   

    --测试1
    -- local pack = {}
    -- pack.shaizi_1=2
    -- pack.shaizi_2=3

    -- SCENENOW["scene"]:showShareButton(false)
    -- GamePlaneOperator:showShaiziAnimation(pack.shaizi_1,pack.shaizi_2)


    -- GamePlaneOperator:showYaoShaiziAnimation()

    --测试2
    -- dump("hhhhhhhhhhhhhhhhhhhhhh")
    -- local tbWin = {}
    -- tbWin[USER_INFO["uid"]] = 1000
    -- GamePlaneOperator:showCoinFlyAnimation(nil,tbWin,"game")

end


function  CDSReceiveHandle:TIME_SHOW()
    --local updateTime = 5
    --
    --local updateInfo = cc.CallFunc:create(
    --	function()
    --        local nowtime = os.date("%m/%d %H:%M")
    --        CDSPanel:getChildByName("hall_plane"):getChildByName("time_txt"):setString(nowtime)
    --	end)
    --
    --local seqAc = cc.Sequence:create(updateInfo,cc.DelayTime:create(updateTime))
    --CDSPanel:getChildByName("hall_plane"):getChildByName("time_txt"):runAction(cc.RepeatForever:create(seqAc))

end

---------------------------------------------------------------------------------------------------------------

--广播用户登录桌子 100D   其他用户进入房间
function  CDSReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)

    dump(pack, "------广播用户登录桌子100D------")
    --CDSUtils:collectPlayerData(pack)

    if not pack then
        return 
    end

    local index = 0
    for k,v in pairs(SHOW_PLAYER_HEAD_INFO) do
        index = index +1
    end

    local userinfo = {}
    userinfo.uid = pack.uid or ""
    userinfo.sex = pack.sex or ""
    userinfo.portrait = pack.portrait or ""
    userinfo.nickName = pack.nickName or ""

    if index < 12 then
        SHOW_PLAYER_HEAD_INFO[userinfo.uid] = userinfo
         ---先刷新掉头像
        for i=1,12 do
            GamePlaneOperator:setPlayerHeadImg(i)
        end

        local temp = 0
        for k,v in pairs(SHOW_PLAYER_HEAD_INFO) do
            temp = temp+1
            GamePlaneOperator:setPlayerHeadImg(temp,v)
        end
    end

    -- local seat = pack.seat
    -- if  seat >= 0 then
    --     local uid =  pack.uid
    --     local userInfo = CDS_USERINFO_TABLE[uid]
    --     local user_if_outline = pack.user_if_outline
    --     CDSUtils:showPlayer(uid,seat,userInfo,user_if_outline)
    -- end

    -- local playerType = CDS_PLAYERTYPE_TABLE[pack.uid]
    -- if  playerType then
    --     GamePlaneOperator:showHeadSymbol(playerType,"disconnect",false)
    -- end

end

--广播自己退出 1008   
function  CDSReceiveHandle:SVR_QUICK_SUC(pack)
    dump("广播自己退出")
    --if  GROUP_MODE == 2 then
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
      --require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

    --end
    -- require("hall.ScoketGame"):showReloginTip()    
end

--广播玩家退出返回（断线） 100E
function CDSReceiveHandle:SVR_QUIT_ROOM(pack)

    dump(pack, "------广播玩家退出返回100E------")
    
    local playerType =  CDS_PLAYERTYPE_TABLE[pack.uid]

    if playerType then
        GamePlaneOperator:removePlayer(playerType)
    end

    CDS_SEAT_TABLE[pack.uid] = -1
    CDS_PLAYERTYPE_TABLE[pack.uid] = nil

end

--广播用户坐下 1031   其他用户进入房间
function  CDSReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
    dump(pack,"其他用户进入房间==1031==BROADCAST_USER_SIT_DOWN")

    -- CDS_SEAT_TABLE[pack.uid] = pack.seat --保存用户座位与id映射

    -- PLAYERNUM = CDSUtils:getPlayerNum()  --先刷新全局人数

    -- local seat = pack.seat
    -- if  seat >= 0 and pack.uid ~= USER_INFO["uid"] then
    --     local uid = pack.uid
    --     local userInfo = CDS_USERINFO_TABLE[uid]
    --     local user_if_outline = 1
    --     local playerType = CDSUtils:getPlayerTypeBySeatId(seat)
    --     CDS_PLAYERTYPE_TABLE[pack.uid] = playerType
    --     GamePlaneOperator:setPlayerHeadImg(playerType,userInfo)
    -- end

end

--广播玩家站起 1032
function CDSReceiveHandle:BROADCAST_USER_STAND_UP(pack)

    dump(pack, "------广播玩家站起1032------")

    -- local playerType =  CDS_PLAYERTYPE_TABLE[pack.uid]

    -- if  playerType then
    --     GamePlaneOperator:removePlayer(playerType)
    -- end

    -- CDS_SEAT_TABLE[pack.uid] = -1
    -- CDS_PLAYERTYPE_TABLE[pack.uid] = nil

end

--广播玩家退出返回（离开房间） 1033
function CDSReceiveHandle:BROADCAST_USER_QUIT_ROOM(pack)

    dump(pack, "------广播玩家退出返回1033------")

    local playerType = CDS_PLAYERTYPE_TABLE[pack.uid]

    if  playerType then
        GamePlaneOperator:removePlayer(playerType)
    end

    if  playerType and playerType >=0 then
        GamePlaneOperator:showSitDownButton(playerType,true)
    end

    if SANGONG_UID_TABLE[CDS_SEAT_TABLE[pack.uid]] then
        SANGONG_UID_TABLE[CDS_SEAT_TABLE[pack.uid]] = nil
    end

    CDS_SEAT_TABLE[pack.uid] = nil
    CDS_USERINFO_TABLE[pack.uid] = nil
    CDS_PLAYERTYPE_TABLE[pack.uid] = nil

    if  pack.uid == USER_INFO["uid"] then
        PreviousLevel = 0
        require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
    end

end

--1042
function CDSReceiveHandle:showWaiWeiResult(data)
    
    dump(data,"showWaiWeiResult")

-- 界面测试代码
--     local data = {
--     {score = 35, nickName = "用户820104",uid = 10001},
-- }
   
--     local news = json.encode(data)  
--     local newfile = io.open("D:/work/hellouniverse/gameClient/trunk/sangong/gameConfig1.txt","w")
--     dump(news,"showWaiWeiResult")
--     newfile:write(news)
--     newfile:close()
    -- local hall_plane = CDS_GAME_SCENE:getParent():getChildByName("hall_plane")
    -- local btn_switch_bet_mode = hall_plane:getChildByName("btn_switch_bet_mode")
    -- local btn_checkoutZ = btn_switch_bet_mode:getPositionZ()   

    --获取总结算界面
    local s = CDS_GAME_SCENE:getParent():getChildByName("waiwei_plane")

    -- local s = SCENENOW["scene"]:getChildByName("WaiWeiResult")
    if  not s then
        return
        -- s = cc.CSLoader:createNode(TpackageName .. "/csb/------LotteryResult.csb"):addTo(SCENENOW["scene"])
    end

    -- s:setPositionZ(btn_checkoutZ - 1)   
    -- s:setName("WaiWeiResult")
    -- s:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
    s:setVisible(false)

    local title = s:getChildByName("title")
          title:setString("投注结算")
    local mask = s:getChildByName("mask")
          mask:addTouchEventListener(function(sender,event) 

            if  event == TOUCH_EVENT_ENDED then
                s:setVisible(false)
            end

        end)

    --结果显示区域
    local content_sv = s:getChildByName("content_sv")
    local content_ly = content_sv:getChildByName("content_ly")

    --定义结果分项
    local result_Item = s:getChildByName("group_ending_box") 

    local result_Item_position_index = 1
     
    local playerNum = table.nums(data)

    local lineCount = math.ceil(playerNum/3)

    local contentHeight = content_sv:getInnerContainerSize().height
    local contentWidth = content_sv:getInnerContainerSize().width

          if contentHeight < 160 * lineCount then  contentHeight = 160 * lineCount end

          content_sv:setInnerContainerSize(cc.size(contentWidth,contentHeight))
          content_ly:setContentSize(cc.size(contentWidth,contentHeight))
          content_ly:setPositionY(contentHeight)
          content_ly:removeAllChildren()
          -- dump(contentHeight,"content_lycontentHeight")
          -- dump(content_ly:getPosition(),"content_ly位置")

    local my_bet_chip = s:getChildByName("my_bet_chip")
          my_bet_chip:setString("我的下注:0")
    local total_bet_chip = s:getChildByName("total_bet_chip")
          total_bet_chip:setString("我的输赢:0")

    local positionIndex = 0
    --生成界面
    for k,v in pairs(data) do  
        ------------------------------------------数据-----------------------------------
        local sex= 1
        local uid = v.uid
        local nickName = v.nickName
        local photo_url = v.portrait
        local score = v.score
        -------------------------------------------界面-------------------------------------------
        if  uid == USER_INFO["uid"] then
            my_bet_chip:setString("我的下注:" .. (my_bet_chip[uid] or 0))
            total_bet_chip:setString("我的输赢:" .. score)
        end

        positionIndex = positionIndex + 1
        local result_Item = result_Item:clone()
        content_ly:addChild(result_Item)

        local x = contentWidth / 2 - (2 - math.ceil(positionIndex % 3.01)) * 400 
        local y = contentHeight - (math.ceil(positionIndex/3.01) - 1) * 155 

        result_Item:setPosition(cc.p(x,y))

        --用户头像
        local head_im = result_Item:getChildByName("head_im")
        require("hall.GameCommon"):getUserHead(photo_url, uid, sex, head_im, head_im:getContentSize().width, false, nickName)

        --用户昵称
        local nickName_txt = result_Item:getChildByName("nickName_txt")
        
        local total_bet_chip = result_Item:getChildByName("total_bet_chip")
              total_bet_chip:setString("输赢：" .. score)
        local bet_chip_txt = result_Item:getChildByName("bet_chip")
              bet_chip_txt:setString("下注：" .. (SINGLE_BET_CHIP[uid] or 0) )

        local namenick = CDSUtils:formatNick(nickName, 7)
        nickName_txt:setString(namenick)

    end

end


--5001
function CDSReceiveHandle:BROADCAST_ERROR_TIPS(pack)

    dump(pack, "-----返回错误提示5001-----")
    
    local errorCode = pack.errorCode

    local tbErrorCode = {
        [1]  = "操作无效",
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
        [20] = "游戏正在进行中，请稍后...在做操作",
        [100] = "已经下注，无法退出",
        [101] = "下注时间小于5秒，禁止取消下注",
        [102] = "已达限注",
        [103] = "已达到最高下注",
    }
    
    if  errorCode == 18 then
        SCENENOW["scene"]:performWithDelay(function()

            --去掉提示弹框
            local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
            if  layer_tips then
                layer_tips:removeSelf()
            end

            if not isiOSVerify then
                SCENENOW["scene"]:requestCharge()
            end

         end,1.5)    
    end
    
    dump(tbErrorCode[errorCode],"错误提示")
    
    if tbErrorCode[errorCode] then
        viewMgr:showTip({text = tbErrorCode[errorCode]})
        -- require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[errorCode]) 
    else
        viewMgr:showTip({text = "未知的错误"})
        -- require("hall.GameTips"):showTips("提示", "", 3, "未知的错误") 
    end

end



--5101
function CDSReceiveHandle:SVR_GROUP_TIME(pack)
    dump(pack, "SVR_GROUP_TIME")
    GAME_ROUND = pack.round
    GAME_TOTAL_ROUND = pack.round_total or 999
    CDSPanel.hall_plane.info_bg.txt_game_no:setString("局数："..GAME_ROUND)
    --CDSPanel.hall_plane.info_bg.txt_game_no:setString("局数："..GAME_ROUND.."/"..GAME_TOTAL_ROUND)
    --SCENENOW["scene"]:showShareButton(true)    --隐藏分享按钮
    
    --if  isGoldGame == 0 then
    --    GAME_TOTAL_ROUND = 999
    --end
    --
    --SCENENOW["scene"]:updateRoomInfo(nil,nil,nil,GAME_ROUND,GAME_TOTAL_ROUND)

end


--广播玩家开启托管 1034
function CDSReceiveHandle:BROADCAST_USER_AUTO_PLAY(pack)
    
    dump(pack, "------广播玩家开启托管 1034------")
    
    if  pack.uid == USER_INFO["uid"] then
        IS_AUTO_PLAY = pack.isOpenAuto

        if  pack.isOpenAuto == 0 then  --关闭托管
            GamePlaneOperator:showAutoPlayTip(false)
        else --开启托管
            GamePlaneOperator:showAutoPlayTip(true)
        end

    end

end

 --0x2001    --广播用户准备
function CDSReceiveHandle:SERVER_READYNOW_ROOM(pack)
    dump(pack, "-------0x2001    --广播用户准备------")
    local playerType = CDS_PLAYERTYPE_TABLE[pack.uid]
    local readyState = 1  --1是准备，0是取消准备

    if  playerType then
        if readyState == 0 then 
            GamePlaneOperator:setReadyStatus(playerType,false)
        else
            GamePlaneOperator:setReadyStatus(playerType,true)    
        end
    end
    if readyState == 0 then
        USERS_READY_STATE[pack.uid] = 0
    else
        USERS_READY_STATE[pack.uid] = 1
    end
    self:setBtnReady()

end



---------------------------------------------------------------------------------------------------------------------------------------------



--1043玩家开始摊牌
function CDSReceiveHandle:SVR_OPEN_CARDS_BROADCAST(pack)

    GamePlaneOperator:showStageTxt("比牌中")
    -- local totalOpenCardTime = pack.openCardTime

    -- local singleOutCardTime = 0.3
    -- if  next(GAME_PARTICIPANTS) then
        -- singleOutCardTime =  totalOpenCardTime/#GAME_PARTICIPANTS
    -- end

    -- if  singleOutCardTime > 0.5 then
        -- singleOutCardTime = 0.5
    -- end

    -- dump(SANGONGKIND,"SANGONGKIND")
    -- dump(SANGONG_UID_TABLE,"SANGONG_UID_TABLE")

    -- local showCardIndex = 0

    -- for k,v in pairs(pack.user_cards) do
        
        -- local uid = v.uid

        -- if  HAS_OPEN_CARD_UIDS[uid] ~= true then

            -- local handCards  = v.handCards
            -- local playerType = CDS_PLAYERTYPE_TABLE[v.uid]

            -- SCENENOW["scene"]:performWithDelay(function()
                -- GamePlaneOperator:outCard(playerType)
                -- GamePlaneOperator:showCardKind(playerType,SANGONGKIND[uid])
                --播放牛牛结果牌的声音
                -- SoundUtils:playCardKindEffect(SANGONGKIND[uid])
            -- end,showCardIndex*singleOutCardTime)

            -- showCardIndex = showCardIndex  + 1

        -- end
        
    -- end

end
---------------------------------------------------------------------------------------------------------------------------------------------

function CDSReceiveHandle:setBtnReady()
    -- if USERS_READY_STATE and USERS_READY_STATE[USER_INFO["uid"]] and USERS_READY_STATE[USER_INFO["uid"]] ~= 1 and MY_SEAT_ID >= 0 then
    --     GamePlaneOperator:showControlButtons(1)
    -- end
end

--结算6008
function CDSReceiveHandle:SVR_SETTLEMENT_BROADCAST(pack)

    dump(pack, "---猜单双结算-----")
    GAME_STATE  = GAME_STATUS_STOP
    print("SVR_SETTLEMENT_BROADCAST")

    TIMES_COUNT = -1

    CDSUtils:clearPlayerGold()

    for uid,_ in pairs(USERS_READY_STATE) do  --重置所有玩家的准备状态
        USERS_READY_STATE[uid] = 0  
    end

    if  GAME_ROUND < GAME_TOTAL_ROUND then
        GamePlaneOperator:showStageTxt("等待游戏开始...")
        --SCENENOW["scene"]:showShareButton(true)
    end

    local tbWin = {}
    local playerType = CDS_PLAYERTYPE_TABLE[pack.uid]
    if playerType then
        local userinfo = CDS_USERINFO_TABLE[pack.uid]

        CDS_USERINFO_TABLE[pack.uid].gold = CDSUtils:goldMath(pack.chips)
        
        GamePlaneOperator:updateCoin(playerType, pack.score/100, userinfo.gold)
        GamePlaneOperator:setCoin(playerType,  CDS_USERINFO_TABLE[pack.uid].gold)
        if pack.score ~= 0 then
            tbWin[pack.uid] = pack.score/100
        end
    end

    GamePlaneOperator:initXiaZhuPanel()
    
    GamePlaneOperator:showCoinFlyAnimation(nil,tbWin,"game",pack.winType)


    -- --刷新每个玩家的金币数
    -- for i,v in ipairs(pack.gamePlayerArr or {}) do
    --     if v.uid ~= pack.uid then
    --         local playerType = CDS_PLAYERTYPE_TABLE[v.uid]
    --         if playerType then
    --             local userinfo = CDS_USERINFO_TABLE[v.uid]
    --             CDS_USERINFO_TABLE[v.uid].gold = CDSUtils:goldMath(v.gold)
    --             GamePlaneOperator:setCoin(playerType, CDS_USERINFO_TABLE[v.uid].gold)
    --         end
    --     end
    -- end

end

--大结算排行榜
function CDSReceiveHandle:SVR_GROUP_BILLBOARD(pack)
    dump(pack, "-----排行榜5100-----")

    GamePlaneOperator:showStageTxt("")

    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end

    local exitFunc = function()
        require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
    end

    require("hall.GameTips"):showTips("提示", "", 2, "房间已解散",nil,exitFunc)

end


--------------------------------------周边功能-----------------------------------------
--组局解散相关
--没有此房间，解散房间失败
function CDSReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)

    --dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")
    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")
end

--广播当前组局解散情况
function CDSReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)

    dump(pack, "-----广播当前组局解散情况-----")
    dump(CDS_USERINFO_TABLE, "-----广播当前房间情况-----")
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
        local applyer_info = CDS_USERINFO_TABLE[applyId]
        dump(applyer_info, "-----广播当前房间情况applyer_info-----")
        if applyer_info ~= nil then
            local nickName = applyer_info.nick or ""
            if nickName ~= nil then
                player_table["playerName"] = nickName 
            else
                player_table["playerName"] = tostring(applyId)
            end
        else
            player_table["playerName"] = tostring(applyId)
        end

        player_table["state"] = "申请"

        table.insert(disband_table, player_table)
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
    for k,v in pairs(CDS_USERINFO_TABLE) do
        dump(v, "-----显示其他人情况-----")
        local uid = v.uid
        --排除掉申请者，申请者不需要显示到这里
        if uid ~= applyId and uid ~= USER_INFO["uid"] then

            --记录当前用户是否已经同意
            local isAgree = 0
            if agreeNum > 0 then
                for k,v in pairs(agreeMember_arr) do
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

    local function agree_disband(value)
        CDSSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(value)
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
function CDSReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

    --dump(pack, "-----广播桌子用户请求解散组局-----")

    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")

end

--广播桌子用户成功解散组局
function CDSReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

    --dump(pack, "-----广播桌子用户成功解散组局-----")

    bm.isDisbandSuccess = true

    -- require("hall.GameTips"):showDisbandTips("解散房间成功","ddz_disbandGroup_success",3)

end

--广播桌子用户解散组局 ，解散组局失败
function CDSReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

    --dump(pack, "-----广播桌子用户解散组局 ，解散组局失败-----")

    local rejectId = pack.rejectId
    if rejectId == USER_INFO["uid"] then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
    else
        local nickName = CDS_USERINFO_TABLE[rejectId].nick or "路人甲"
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2,  nickName.. "拒绝解散房间")
    end

end

--聊天
function CDSReceiveHandle:SVR_MSG_FACE(pack)

    local faceUI = SCENENOW["scene"]:getChildByName("faceUI")

    local sex = 1

    if CDS_USERINFO_TABLE[pack.uid] then
       sex = CDS_USERINFO_TABLE[pack.uid].sex or 0
    end

    local isLeft = false

    local node_head = PLAYER_HEADS_TABLE[pack.uid]
    if  tonumber(sex) >= 0 and node_head then
        faceUI:showGetFace(pack.uid, pack.type, tonumber(sex), node_head, false)
    end

end
-----------------------------------------------------------------------------------------------------------------------------
function CDSReceiveHandle:showTextMessage(pack)

    local s= SCENENOW["scene"]:getChildByName("faceUI")
    
    local sex = 1

    if CDS_USERINFO_TABLE[pack.uid] then
       sex = CDS_USERINFO_TABLE[pack.uid].sex or 0
    end

    local node_head = PLAYER_HEADS_TABLE[pack.uid]

    s:showGetText(pack.uid,pack.textMessage,tonumber(sex),node_head, false)  
end


function CDSReceiveHandle:showExpression(msg)
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

--接收服务器返回的组局信息
function CDSReceiveHandle:SERVER_CMD_MESSAGE(pack)

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
                    --dump("voice", "-----接收服务器返回的组局信息-----")
                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                     require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)
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
                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                     require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)
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


----------------------------------------外围功能---------------------------------------------------


--请求录纸返回 1035
function CDSReceiveHandle:SERVER_CMD_RECORD_PAPER(pack)

    local record_paper = pack.record_paper

end



--发牌相关
--处理发牌协议 4001 (第一次发标志着游戏的开始)
function CDSReceiveHandle:SVR_SEND_USER_CARD(pack)

    -- dump(pack, "------发送用户的牌信息4001------")
    
    -- dump(FIRSTSENDCARD,"4001FIRSTSENDCARD")
    -- dump(debug.traceback(),"SVR_SEND_USER_CARD_DEBUG_RECONNECT")
    
    -- if FIRSTSENDCARD then
    
    --    local userCards = {}
    
    --    LIANGCARDNUM = 0
    --    MY_CARDS = {}
    
    --    if  pack.users and next(pack.users) then
    
    --        for i,data in pairs(pack.users) do
    --            userCards[data.seat] = data.cards
    --        end
    
    --        local myControlCards = userCards[MY_seat]
    --        for _,card in ipairs(myControlCards) do
    --            table.insert(MY_CARDS,card)
    --            if  card ~= 0 then
    --                LIANGCARDNUM = LIANGCARDNUM + 1
    --            end
    --        end
    --        for _,uid in pairs(GAME_PARTICIPANTS) do   --先清理
    --            local playerType = CDS_PLAYERTYPE_TABLE[uid]
    --            GamePlaneOperator:clearCardPlane(playerType)
    --        end
    --        for i = 1 , 3 do
    --            for k = 1, 8 do
    --                for _,uid in pairs(GAME_PARTICIPANTS) do   --先清理
    --                    local playerType = CDS_PLAYERTYPE_TABLE[uid]
    --                    local seat =  CDS_SEAT_TABLE[uid]
    --                    local cards = userCards[seat]
    --                    GamePlaneOperator:showDealCardsAnimation(playerType, cards,i)
    --                end
    
    --            end
    --        end
    
    --    else
    
    --        for i,card in ipairs(pack.cards) do
    --            table.insert(MY_CARDS,card)
    --            if  card ~= 0 then
    --                LIANGCARDNUM = LIANGCARDNUM + 1
    --            end
    --        end
    
    --    end
    
    --    -- GamePlaneOperator:showCards(CARD_PLAYERTYPE_MY,MY_CARDS,FIRSTSENDCARD)
    
    --    FIRSTSENDCARD = false
    -- else
    --    ------------------------------------
    --    MY_CARDS = {}
    
    --    for i,card in ipairs(pack.cards) do
    --        table.insert(MY_CARDS,card)
    --    end
    --    -----------------------------------
    --    GamePlaneOperator:showCards(CARD_PLAYERTYPE_MY,pack.cards,FIRSTSENDCARD)
    
    -- end

end


-- 0x1101   --- 广播下注
function CDSReceiveHandle:SERVER_BROADCAST_YA(pack)
    dump(pack,"-----------广播下注-------------")

    local playerType = CDS_PLAYERTYPE_TABLE[pack.uid]
    local desPlayerType = CDS_SEAT_TABLE[pack.desUid]+1
    local desPlayerTypeOther = CDS_PLAYERTYPE_TABLE[pack.desUid]
    dump(playerType, "SERVER_CMD_REQ_YAZHU_INFO-playerType")

    if playerType then
        CDS_USERINFO_TABLE[pack.uid].gold = CDSUtils:goldMath(pack.gold)
        GamePlaneOperator:setCoin(playerType,CDSUtils:goldMath(pack.gold))
    end
    if desPlayerTypeOther then
        CDS_USERINFO_TABLE[pack.desUid].totalGold = pack.total
        GamePlaneOperator:setTotalBetChip(desPlayerTypeOther, CDSUtils:goldMath(pack.total))
    end
    if pack.uid == USER_INFO["uid"] then
        CDS_USERINFO_TABLE[pack.uid].gold = CDSUtils:goldMath(pack.gold)
        GamePlaneOperator:setMyCoin(CDSUtils:goldMath(pack.gold))
        GamePlaneOperator:setSeatGold(desPlayerType, CDSUtils:goldMath(pack.total))
        if isNewLowerScore then
            local playerNo = CDS_SEAT_TABLE[pack.desUid] +1
            -- require("hall.GameTips"):showTips("提示", "", 2, playerNo.. " 号桌成功押注 "..CDSUtils:goldMath(pack.chip) .."分")
            --require(CommonTips_filePath):showTips("提示", "", 3, playerNo.. " 号桌成功押注 "..CDSUtils:goldMath(pack.chip) .."分")
        end

    end
    local playerType = CDS_PLAYERTYPE_TABLE[pack.uid]
    GamePlaneOperator:setBetTimes(playerType,pack.chip/100)

    ------设置底池
    GamePlaneOperator:showDiChi(pack.chip/100)
end
function CDSReceiveHandle:SERVER_BROADCAST_START_YA(pack)
    local GAME_TIME = pack.outCardAniTime
    GAME_STATE = GAME_STATUS_YA
    GAME_IS_ENDING = 1
    GAME_OUT_CARD_COUNT = 1
    GAME_OVER_RANKING =1
    IS_ON_RANKING = false
    GamePlaneOperator:startTimer(GAME_TIME,"投分时间：")
    --GamePlaneOperator:showIsButtonXZ(false)
    GamePlaneOperator:showPlayer()
    GamePlaneOperator:showStartAnimation()
    GamePlaneOperator:clearGameDatas(true)
end

function CDSReceiveHandle:SERVER_BROADCAST_CARD(pack,flag,isShow,timeStr)
    dump(pack,"---------------------------发牌")
    local BANKSEATID = (pack.bankSeatId or 0)
    SHAICARD = pack.shaiCard
    local GAME_TIME = pack.outCardAniTime or 0
    dump(BANKSEATID,"BANKSEATID-SERVER_BROADCAST_CARD")
    BANKSEATID = CDSUtils:getPlayerTypeBySeatId(BANKSEATID)
    GAME_STATE = GAME_STATUS_SEND_CARD
    local timeStr = timeStr or "发牌时间："

    GamePlaneOperator:hidePlayer("player")
    local userCards = {}
    local cardType ={}
    local panel_playerType = 5
    MY_CARDS = {}
    local SendCardTime = 0
    local dichiNum = 0
    for i,data in pairs(pack.gamePlayerArr) do  --先清理，后再发牌
        local playerType = CDS_PLAYERTYPE_TABLE[data.uid]
        userCards[playerType] = data.handCardArr
        cardType[playerType] = {}
        cardType[playerType].type = data.type
        cardType[playerType].point = data.point
        cardType[playerType].maxCard = data.maxCard
        panel_playerType = playerType
        -- GamePlaneOperator:clearCardPlane(playerType)
        All_Card_Nodes[playerType] = {}
        local isSelf = false
        if data.uid == USER_INFO["uid"] then
            MY_CARDS = data.handCardArr
            isSelf = true
        end
        GamePlaneOperator:showCards(playerType,data.handCardArr, isSelf)
        SendCardTime = SendCardTime + 0.2

        if data.totalGold then
           dichiNum = data.totalGold + dichiNum 
        end
        
    end
    if dichiNum > 0 then
        GamePlaneOperator:showDiChi(dichiNum/100)
    end
    
    if self.chupai_cuopai then
        SCHEDULER.unscheduleGlobal(self.chupai_cuopai)
    end
    self.chupai_cuopai = SCHEDULER.performWithDelayGlobal(function ()
        GamePlaneOperator:showControlButtons(4)
    end, SendCardTime)


    -- local function callback()
    --     for i = 1 , 3 do
    --         for k = BANKSEATID, (12 + BANKSEATID -1) do
    --             for _,data in pairs(pack.gamePlayerArr) do
    --                 local playerType = CDS_PLAYERTYPE_TABLE[data.uid]
    --                 local index =k
    --                 if k >12 then
    --                     index = k - 12
    --                 end
    --                 -- dump("index")
    --                 if index == playerType then
    --                     local cards = userCards[playerType]
    --                     -- dump(cards,"userCards")
    --                     if flag then
    --                         GamePlaneOperator:showAllCards(playerType, cards,i,isShow,cardType[playerType])
    --                         if isShow then
    --                             GamePlaneOperator:showCardKind(playerType,cardType[playerType].point,cardType[playerType].type,true)
    --                         end
    --                     else
    --                         GamePlaneOperator:showDealCardsAnimation(playerType, cards,i)
    --                     end

    --                 end
    --             end

    --         end
    --     end
    -- end
    -- if flag then
    --     callback()
    -- else
    --     GamePlaneOperator:showCardsBack(callback,panel_playerType)
    -- end
end

-- 0x1103   -- 广播出牌
function CDSReceiveHandle:SERVER_BROADCAST_OUT_CARD(pack)
    dump(pack,"----------------------广播出牌")
    if GAME_STATE == GAME_STATUS_OPEN_KIND then
        return
    end
    GAME_STATE = GAME_STATUS_OPEN_CARD
    if pack.uid == USER_INFO.uid then
        GamePlaneOperator:showControlButtons(0,false)
    end
    --
    --GAME_TIME = pack.outCardAniTime
    --GamePlaneOperator:startTimer(GAME_TIME,"出牌：")
    --GamePlaneOperator:showIsButtonXZ(false)
    TIMES_COUNT = TIMES_COUNT + pack.outCardAniTime
    if GAME_OUT_CARD_COUNT == 1 then
        GAME_OUT_CARD_COUNT = GAME_OUT_CARD_COUNT+1
        if CHECK_SCHEDULER_GLOBAL then
            SCHEDULER.unscheduleGlobal(CHECK_SCHEDULER_GLOBAL)
        end
    end

    CHECK_SCHEDULER_GLOBAL =SCHEDULER.performWithDelayGlobal(function ()
        local playerType = CDS_PLAYERTYPE_TABLE[pack.uid]
        if All_Card_Nodes[playerType]  then
            GamePlaneOperator:outCard(playerType,pack.handCardArr)
            GamePlaneOperator:showCardKind(playerType,pack.point,pack.type)
        end
    end, TIMES_COUNT)

end
function CDSReceiveHandle:SERVER_BROADCAST_START_OUT_CARD(pack)
    local GAME_TIME = pack.outCardAniTime
    GAME_STATE = GAME_STATUS_OUT_CARD
    GamePlaneOperator:startTimer(GAME_TIME,"看牌时间：")
end

--0x1104   --- 开牌
function CDSReceiveHandle:SERVER_BROADCAST_OPEN_CARD(pack)  --开牌阶段
    dump(pack, "开牌：SERVER_BROADCAST_OPEN_CARD")
    if pack then
        GAME_STATE = GAME_STATUS_OPEN_CARD
        --开启动画
        if pack.first and pack.first > 0 and pack.second and pack.second > 0 then

            GamePlaneOperator:showKouPanZi(false)
            GamePlaneOperator:showShaiziAnimation(pack.first,pack.second,pack.shaiziPos)
        end
    end
end

function CDSReceiveHandle:SERVER_CMD_REQ_YAZHU_INFO(pack)   --押注情况
    print("SERVER_CMD_REQ_YAZHU_INFO")

    for i,v in pairs(pack.gamePlayerArr) do
        local playerType = CDS_PLAYERTYPE_TABLE[v.uid]
        GamePlaneOperator:setSeatGold(playerType, CDSUtils:goldMath(v.my_total))
        GamePlaneOperator:setTotalBetChip(playerType, CDSUtils:goldMath(v.total))
    end

end
function CDSReceiveHandle:SERVER_CMD_REQ_YAZHU_DETAILS(pack)
    dump(pack, "SERVER_CMD_REQ_YAZHU_DETAILS")
end

function CDSReceiveHandle:SERVER_NOTIFY_RESULT(pack)
    dump(pack,"SERVER_NOTIFY_RESULT")
    TIMES_COUNT = -1
    --GamePlaneOperator:startTimer(0,"正在结算：")
    GAME_STATE = GAME_STATUS_STOP

    GamePlaneOperator:setMyCoin(CDSUtils:goldMath(pack.gold))
    CDS_USERINFO_TABLE[USER_INFO["uid"]].gold = CDSUtils:goldMath(pack.gold)
    -- RoundEnding:showNotify(pack)
    IS_ON_RANKING = true


end
function CDSReceiveHandle:SERVER_BROADCAST_GIVE_COINS(pack)
    dump(pack,"SERVER_BROADCAST_GIVE_COINS")

    local from_playerType = CDS_PLAYERTYPE_TABLE[pack.fromUid]
    local to_playerType = CDS_PLAYERTYPE_TABLE[pack.toUid]
    if CDS_USERINFO_TABLE[pack.toUid] then
        CDS_USERINFO_TABLE[pack.toUid].gold = (CDS_USERINFO_TABLE[pack.toUid].gold or 0) + CDSUtils:goldMath(pack.toCoins)
        if pack.toUid == USER_INFO["uid"] then
            GamePlaneOperator:setMyCoin(CDS_USERINFO_TABLE[pack.toUid].gold)
        end
    end
    if  CDS_USERINFO_TABLE[pack.fromUid] then
        CDS_USERINFO_TABLE[pack.fromUid].gold = (CDS_USERINFO_TABLE[pack.fromUid].gold or 0) + CDSUtils:goldMath(pack.fromCoins)
        if pack.fromUid == USER_INFO["uid"] then
            GamePlaneOperator:setMyCoin(CDS_USERINFO_TABLE[pack.fromUid].gold)
        end
    end


    if from_playerType then
        GamePlaneOperator:setCoin(from_playerType, CDS_USERINFO_TABLE[pack.fromUid].gold)
    end

    if to_playerType then
        GamePlaneOperator:setCoin(to_playerType, CDS_USERINFO_TABLE[pack.toUid].gold)
    end
    require(GiveScene_filePath):removeScene()
    if pack.fromUid == USER_INFO["uid"] then
        --require(CommonTips_filePath):showTips("提示", "", 3, "赠送成功")
    end
end

--0x1109--单局结算
function CDSReceiveHandle:SERVER_BROADCAST_WINLOSE_COUNT(pack)
    dump(pack,"------------------------0x1109--单局结算")
    -- self:setBtnReady()
end

function CDSReceiveHandle:SERVER_CMD_REQ_TEST(pack)
    dump(pack,"---------------------------测试1-------------------------------------")
    local count = pack.count
    local testSeats = pack.testSeats
    if count <= 0 or #testSeats <= 0 then
        return
    end
    if SCENENOW["scene"]:getChildByName("ConfigPanel") then
        SCENENOW["scene"]:getChildByName("ConfigPanel"):removeSelf()
    end
    for i,info in pairs(testSeats) do
        -- if info.seat==isOpenControlSeat then
        --     require(TpackageName..".Control"):init(pack.seatCount,info.rank+1)
        --     return
        -- end
        require(TpackageName..".Control"):init(pack.seatCount,info.rank+1)
        return
    end
end

function CDSReceiveHandle:SERVER_CMD_TEST(pack)
    dump(pack,"---------------------------测试2-------------------------------------")
    if pack.errorCode == 0 then
        require("hall.GameTips"):showTips("提示", "", 3, "成功")
    else
        require("hall.GameTips"):showTips("提示", "", 3, "失败")
    end
end
---------------------------------------------------------------------------------------------------

--准备相关
--广播用户可以准备了
function CDSReceiveHandle:SVR_READY_TIME(pack)
    
    dump(pack, "------广播用户可以准备了6009------")

    GAME_STATE = GAME_STATUS_STOP      --准备阶段
end

--广播玩家准备 用户准备了返回
function CDSReceiveHandle:SVR_READY_BROADCAST(pack)
    
    dump(pack, "------广播玩家准备6001------")

    local playerType = CDS_PLAYERTYPE_TABLE[pack.uid]
    local readyState = pack.readyState  --1是准备，0是取消准备

    if  playerType then
        if readyState == 0 then 
            GamePlaneOperator:setReadyStatus(playerType,false)
        else
            GamePlaneOperator:setReadyStatus(playerType,true)    
        end
    end

    if readyState == 0 then
        USERS_READY_STATE[pack.uid] = 0
    else
        USERS_READY_STATE[pack.uid] = 1
    end
    self:setBtnReady()

end
--所有人都已准备，广播可以开始游戏
function CDSReceiveHandle:SERVER_COMMAND_REMAID_START_GAME()
    GamePlaneOperator:RemaidStartGame(true)
end
--广播游戏开始 6002
function CDSReceiveHandle:SVR_BROADCAST_GAME_START(pack)
    -----------------------------游戏开始-------------------------------
    
    dump(pack, "SVR_BROADCAST_GAME_START")

    GamePlaneOperator:showSitDownButton(false)  --隐藏坐下按钮
    SCENENOW["scene"]:showShareButton(false)    --隐藏分享按钮
    GamePlaneOperator:RemaidStartGame(false)    --隐藏开始按钮
   
    GamePlaneOperator:clearAllReadyStatus()  --游戏开始后清除准备状态

    FIRSTSENDCARD = true   --重置发牌变量

    if  USERS_READY_STATE[USER_INFO["uid"]] == 0 then  --如果我在游戏开始时不在准备状态的话，进入旁观模式
        GamePlaneOperator:showAudienceBrand(true)
    end


    ----------------------------------
    local cardEndIndex = pack.send_card_num or 4
    local dealCardIndex = 1

    GAME_PARTICIPANTS = {}

    for uid,ready_state in pairs(USERS_READY_STATE) do 
        if  ready_state == 1 then
            table.insert(GAME_PARTICIPANTS,uid) 
        end
    end

    local isRelogin = pack.isRelogin

    if GAME_CONFIG["买牛"] == true then

        if  isRelogin == true then

            local user_datas = pack.user_datas

            for _, data in ipairs(user_datas) do

                local seatId = data.seatId
                local cards = data.cards

                local playerType = CDS_PLAYERTYPE_TABLE_BYSEAT[seatId]
                
                if  playerType and seatId ~= MY_SEAT_ID and cardEndIndex > 0 then
                    GamePlaneOperator:showDealCardsAnimation(playerType,cards,cardEndIndex,isRelogin,"cover")
                end

            end

        else

            local user_datas = pack.user_datas

            for _, data in pairs(user_datas) do

                local seatId = data.seatId
                local cards = data.cards

                -- for i = cardEndIndex + 1,5 do
                --     cards[i] = 0
                -- end

                local playerType = CDS_PLAYERTYPE_TABLE_BYSEAT[seatId]
                
                if  playerType and seatId ~= MY_SEAT_ID and cardEndIndex > 0 then

                    SCENENOW["scene"]:performWithDelay(function()
                        GamePlaneOperator:showDealCardsAnimation(playerType,cards,cardEndIndex,nil,"cover")
                    end,dealCardIndex*0.05)   

                    dealCardIndex = dealCardIndex + 1
                end

            end

        end

    else

        if  isRelogin == true then

            for _,uid in ipairs(GAME_PARTICIPANTS) do
                    
                local playerType = CDS_PLAYERTYPE_TABLE[uid]
                if  playerType and uid ~= USER_INFO["uid"] and cardEndIndex > 0 then

                    GamePlaneOperator:showDealCardsAnimation(playerType,nil,cardEndIndex,isRelogin)
                end

            end

        else

            for _,uid in ipairs(GAME_PARTICIPANTS) do
                local playerType = CDS_PLAYERTYPE_TABLE[uid]
                if  playerType and uid ~= USER_INFO["uid"] and cardEndIndex > 0 then

                    SCENENOW["scene"]:performWithDelay(function()
                        GamePlaneOperator:showDealCardsAnimation(playerType,nil,cardEndIndex)
                    end,dealCardIndex*0.05)                

                    dealCardIndex = dealCardIndex + 1
                end
            end
        end
    end
end


--1041 广播下注剩余时间
function CDSReceiveHandle:BROADCAST_SENDCARD_REMAINDTIME(pack)
    dump(pack,"BROADCAST_SENDCARD_REMAINDTIME=")

    if pack.time then
        GAME_STATE = GAME_STATUS_YA
        SCENENOW["scene"]:showShareButton(false)
        SoundUtils:playEffect("kaishixiazhu")
        GamePlaneOperator:startTimer(pack.time,"开始下注")
    end
end

--0x600B 广播摇色子
function CDSReceiveHandle:BROADCAST_YAOSHAIZI(pack)
    dump(pack,"BROADCAST_YAOSHAIZI=")

    if pack.time then
        GAME_STATE = GAME_STATUS_YAOSHAIZI
        SCENENOW["scene"]:showShareButton(false)

        --加个摇色子声音
        SoundUtils:playShaziMusic()

        --摇色子特效
        GamePlaneOperator:showYaoShaiziAnimation()

    end
end


--出牌相关
--广播出牌阶段开始
function CDSReceiveHandle:SVR_PLAY_CARD_BROADCAST(pack)

    dump(pack, "-----广播玩家开始出牌6004-----")
    --显示阶段信息
    GAME_STATE = GAME_STATUS_OUTCARD --棋牌进行中
 
    local time = pack.time or 5
    local cardEndIndex = 5

    if  USERS_READY_STATE[USER_INFO["uid"]] == 1 then
        GamePlaneOperator:showControlButtons(4)   --隐藏抢分
    end
    
    for _,uid in ipairs(GAME_PARTICIPANTS) do
        local playerType = CDS_PLAYERTYPE_TABLE[uid]
        if  playerType and uid ~= USER_INFO["uid"] then
            dump(playerType,"出牌阶段给玩家发最后几张牌")
            GamePlaneOperator:showDealCardsAnimation(playerType,nil,cardEndIndex) 
            GamePlaneOperator:showCardKind(playerType,-1)  --显示盖牌文字
        end
    end

    GamePlaneOperator:startTimer(time,"出牌阶段")

end

--扣除台费 4800
function CDSReceiveHandle:SVR_CHIP_CHANGE_BROADCAST(pack)
     
    local  change_chip = 0
    for _,data in pairs(pack.userinfo) do

        local uid = data.uid
        local playerType = CDS_PLAYERTYPE_TABLE[uid]
        local oriChip = CDS_USERINFO_TABLE[uid].coins 
        local chip = oriChip + data.change_chip
        CDS_USERINFO_TABLE[uid].coins  = chip

        GamePlaneOperator:setCoin(playerType,chip)

        if  uid == USER_INFO["uid"] then
            --GamePlaneOperator:showTaiFeiTips(data.change_chip)
        end

    end
end

--1043玩家开始摊牌
function CDSReceiveHandle:SVR_OPEN_CARDS_BROADCAST(pack)

    local totalOpenCardTime = pack.openCardTime

    GamePlaneOperator:showStageTxt("比牌中...")
end


--广播开始抢庄（游戏开始，第一阶段）
function CDSReceiveHandle:SVR_BEGIN_QIANFGZHUANG_BROADCAST(pack)
    
    dump(pack,"-----广播开始抢庄6015-----")
  
    --棋牌进行中
    GAME_STATE = GAME_STATUS_GRAB

    local time = pack.time


    GamePlaneOperator:startTimer(time,"抢庄阶段")
    
    if  USERS_READY_STATE[USER_INFO["uid"]] ~= 1 then
        GamePlaneOperator:showControlButtons(1,false)
        return
    end

    if  pack.time <= -3 or GAME_TYPE_NAME == "通比牛牛" then    --没有此阶段
        return
    end
    

    local exsits = false

    local my_can_grab_times

    for i,data in pairs(pack.ids) do
        local uid 

        if type(data) == "table" then
            uid = data.uid 
            if USER_INFO["uid"] == uid then
            --当前自己已经抢庄
                exsits = true
                my_can_grab_times = data.can_grab_times
            end
        else
            uid = data
            if USER_INFO["uid"] == uid then
            --当前自己已经抢庄
                exsits = true
            end
        end

    end
     
    if GROUP_MODE == 2 then
        if  my_can_grab_times then
            table.insert(pack.grab_times,1,0)
            table.insert(my_can_grab_times,1,0)
            GamePlaneOperator:loadGrabBankerButtons(pack.grab_times,pack.can_grab_times)
        else
            local grab_times = {0,1}
            local can_grab_times 
            if  exsits then
                can_grab_times = {0,1}
            else
                can_grab_times= {0}
            end

            GamePlaneOperator:loadGrabBankerButtons(grab_times,can_grab_times)
        end
    else
        if  my_can_grab_times then
            table.insert(my_can_grab_times,1,0)
            GamePlaneOperator:loadGrabBankerButtons(my_can_grab_times,my_can_grab_times)
        else
            local grab_times = {0,1}
            local can_grab_times 
            if  exsits then
                can_grab_times = {0,1}
            else
                can_grab_times= {0}
            end

            GamePlaneOperator:loadGrabBankerButtons(grab_times,can_grab_times)
        end
    end


    GamePlaneOperator:showControlButtons(2) 

end
--处理抢庄  广播抢庄情况6013
function CDSReceiveHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack)
    
    dump(pack,"------广播玩家抢庄6013-----")
    local uid = pack.uid
   
    if  uid == USER_INFO["uid"] then
        GamePlaneOperator:showControlButtons(2,false)
        GamePlaneOperator:showStageTxt("等待其他玩家操作...")
    end

    local  grabTimes = pack.if_qiang

    if  grabTimes > 0 then

        local playerType = CDS_PLAYERTYPE_TABLE[pack.uid]
        dump(CDS_PLAYERTYPE_TABLE,"SVR_USER_QIANFGZHUANG_RESULT_BROADCAST_playerType")
        RANDOM_BANKER[uid] = grabTimes
        GamePlaneOperator:setGrabBankerSymbol(playerType)
        GamePlaneOperator:setGrabBankerTimes(playerType,grabTimes)
        SoundUtils:playCardKindEffect("qiangzhuang", CDS_USERINFO_TABLE[pack.uid].sex)
    else
        SoundUtils:playCardKindEffect("buqiang", CDS_USERINFO_TABLE[pack.uid].sex)
    end

end


--有人未准备，隐藏开始游戏按钮
function CDSReceiveHandle:SERVER_COMMAND_REMAID_START_GAME_FAIL()
    GamePlaneOperator:RemaidStartGame(false)
end

function CDSReceiveHandle:SVR_SEND_USED_CARDS(pack)
    USED_CARDS = pack.cards
end

--广播庄家id
function CDSReceiveHandle:SVR_BRANK_BROADCAST(pack)

    dump(pack, "------广播庄家id 6003-----")

    if pack.uid == -1 or GAME_TYPE_NAME == "通比牛牛" then
        return
    end

    local broadcast_banker_delay = 0.1
    
    BANKER_UID = pack.uid

    GamePlaneOperator:showControlButtons(2,false)

    local BankerPlayerType = CDS_PLAYERTYPE_TABLE[pack.uid]
   
    GamePlaneOperator:stopTimer()

    --隐藏抢庄标记
    GamePlaneOperator:clearGrabBankerSymbol()
 
    if  GAME_TYPE == 1 then 

        local grab_bankers = {}

        if  table.nums(RANDOM_BANKER) == 0 then
            GamePlaneOperator:showRandomBankerChoose(GAME_PARTICIPANTS)
            broadcast_banker_delay = 1.77
            -- GamePlaneOperator:startTimer(2,"抢庄阶段")
            GamePlaneOperator:showStageTxt("随机庄家中...")
        else
            local highest = 1
            for uid,times in pairs(RANDOM_BANKER) do

                if  times > highest then
                    highest = times 
                    grab_bankers = {}
                    table.insert(grab_bankers,uid)
                elseif times == highest then
                    table.insert(grab_bankers,uid)
                end

            end

            GamePlaneOperator:showRandomBankerChoose(grab_bankers)
            
            if  #grab_bankers > 1 then 
                broadcast_banker_delay = 1.77
                -- GamePlaneOperator:startTimer(2,"抢庄阶段")
                GamePlaneOperator:showStageTxt("随机庄家中...")
            end

        end

    end

    RANDOM_BANKER = {}
    
    SCENENOW['scene']:performWithDelay(function()
        
        if  GAME_TYPE_NAME ~= "定庄牛牛" then 
            GamePlaneOperator:showBankerChoose(pack.uid)
            SoundUtils:playEffect("定庄特效")
        end

        --清除抢庄失败的人的抢庄倍数
        for playerType = 1,TOTAL_PLAYERNUM do 
            if  playerType ~= BankerPlayerType  then
                GamePlaneOperator:setGrabBankerTimes(playerType,0,false)
            end
        end
           
        GamePlaneOperator:showStageTxt("等待闲家加倍...")

        GamePlaneOperator:clearBankerFlag()  --出现了一个莫名其妙的显示两个庄家的BUG，于是现在在确定前先把所有的庄家标记删了
        --显示庄
        local size = SCENENOW["scene"]:getContentSize()
        local pos = cc.p(size.width / 2, size.height / 2)
        -- GamePlaneOperator:showHeadSymbol(BankerPlayerType,"banker",true)
        self:createArmature("niuniu_zhuang_1", pos, pack.uid, BankerPlayerType)

    end,broadcast_banker_delay)

end
--倍数相关
--处理加倍
function CDSReceiveHandle:SVR_SEND_BASES_TO_USER_BROADCAST(pack)

    dump(pack, "-----向特定用户发送可翻倍的数值列表7001-----")
    
    GAME_STATE = GAME_STATUS_TIMES

    if  pack.time <= -3 or GAME_TYPE_NAME == "通比牛牛" then    --没有此阶段
        -- require("hall.GameTips"):showTips("提示", "", 3, "阶段时间错误") 
        dump(pack.time,"阶段时间错误") 
        return
    end

    if  USERS_READY_STATE[USER_INFO["uid"]] ~= 1 then
        require("hall.GameTips"):showTips("提示", "", 3, "我不在准备状态") 
        return
    end

    GamePlaneOperator:startTimer(pack.time,"加倍阶段")

    --显示玩家自己可以选择的倍数
    if  BANKER_UID ~= USER_INFO["uid"]  then
        GamePlaneOperator:showControlButtons(3)
    end

    if  pack.can_selects_base then
        GamePlaneOperator:loadBetButtons(pack.selects_base,pack.can_selects_base,pack.tuiZhuBase)
    else
        GamePlaneOperator:loadBetButtons(pack.selects_base)
    end

end

--广播加倍倍数
function CDSReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack)
    
    dump(pack, "-----广播加倍倍数6014-----")

    local playerType = CDS_PLAYERTYPE_TABLE[pack.uid]
          GamePlaneOperator:setBetTimes(playerType,pack.base)

    if  pack.uid == USER_INFO["uid"] then
        if GAME_CONFIG["买牛"] ~= true then
            GamePlaneOperator:showStageTxt("等待其他玩家加倍...")
        end
        GamePlaneOperator:showControlButtons(3,false)
    end
    local config_arr = string.split(baseChip, "/")
    local base = tonumber(config_arr[#config_arr])
    -- if pack.base > base then
    --     SoundUtils:playCardKindEffect("tuizhu", CDS_USERINFO_TABLE[pack.uid].sex)
    -- end
end

---------------------------------------------------------------------------------
--广播开始游戏倒计时 下注 1100
function CDSReceiveHandle:SVR_BROADCAST_WAIT_START(pack)
    
    dump(pack, "------广播开始游戏倒计时 1100------")
    local time = pack.time
    if  time >= 0 then

        --游戏开始时才清除数据
        if  RELOGIN_FLAG ~= true then
            GamePlaneOperator:clearGameDatas(2)
        end

        SoundUtils:playEffect("dengdaixiazhu")

        GamePlaneOperator:startTimer(time,"等待下注")
        
    end

    RELOGIN_FLAG = false
end


--接收服务器放回的指定用户信息pack111
function CDSReceiveHandle:SVR_CHARGE_BROADCAST(pack)
   
    local uid = pack.uid
    local playerType = CDS_PLAYERTYPE_TABLE[uid]
    local userInfo = CDS_USERINFO_TABLE[uid]
    if not (playerType and userInfo) then return end
    userInfo.gold = userInfo.gold + pack.chargeCoins/100
    -- CDSUtils:collectPlayerData(userInfo)
    GamePlaneOperator:setCoin(playerType, userInfo.gold)
    dump(pack,"pack111")
end


function CDSReceiveHandle:SVR_USER_XIAZHU_DATA(pack)
   dump(pack,"---------0x600A----SVR_USER_XIAZHU_DATA")
    if pack then
        --刷新金币（自己的）
        local tempGold = CDS_USERINFO_TABLE[USER_INFO["uid"]].gold

        CDS_USERINFO_TABLE[USER_INFO["uid"]].gold = CDSUtils:goldMath(pack.gold)
        GamePlaneOperator:setMyCoin(CDSUtils:goldMath(pack.gold))

        --[[--刷新其他人的
            for i,v in ipairs(pack.gamePlayerArr or {}) do
                local playerType = CDS_PLAYERTYPE_TABLE[v.uid]
                if playerType then
                    local userinfo = CDS_USERINFO_TABLE[v.uid]
                    CDS_USERINFO_TABLE[v.uid].gold = CDSUtils:goldMath(v.gold)
                    GamePlaneOperator:setCoin(playerType, CDS_USERINFO_TABLE[v.uid].gold)
                end
            end--]]
        dump(tempGold,"tempGold===")
            
        if pack.gold/100 <= tempGold then  --表示正常下注了 或者没有下注
            --刷新下注数
            if pack.my_xiazhu_count and pack.my_xiazhu_count > 0 then
                GamePlaneOperator:onXiaZhu(pack.my_xiazhu_info)
            end
        else
            --取消了下注 所以现在的钱要比之前一轮数据的钱多
            GamePlaneOperator:onDeleteChouMa()
        end

        --刷新桌面总的下注数量
        if pack.tab_xiazhu_count then
            GamePlaneOperator:showTotalXiaZhu(pack.tab_xiazhu_info)
        end

        --刷新我的下注总数
        if pack.tab_xiazhu_count_my then
            MY_TOTAL_XIAZHU_TAB = pack.tab_xiazhu_info_my
            GamePlaneOperator:showMyTotalXiaZhu(pack.tab_xiazhu_info_my)
        else
            MY_TOTAL_XIAZHU_TAB = {}
        end
        
    end

end



function CDSReceiveHandle:SVR_BROADCAST_GAME_RESULT(pack)
   dump(pack,"---------0x600C----SVR_BROADCAST_GAME_RESULT")
    if pack then
       GamePlaneOperator:initZhanJiPanel(pack.gameResults)
    end
end

function CDSReceiveHandle:BROADCAST_STOP_XIAZHU(pack)
    dump(pack,"BROADCAST_STOP_XIAZHU=")

    if pack.time then
        GAME_STATE = GAME_STATUS_STOP_YA
        SCENENOW["scene"]:showShareButton(false)

        SoundUtils:playEffect("tingzhixiazhu")
        GamePlaneOperator:startTimer(pack.time,"停止下注")
        
    end
end

function CDSReceiveHandle:BROADCAST_SHOW_HEAD(pack)
    dump(pack,"BROADCAST_SHOW_HEAD=")
    if pack then
        local index = 0
        local tempTab = {}
        
        if pack.showHead_count > 0 then
            for i,v in ipairs(pack.showHead) do
                if index < 12 and v.uid ~= USER_INFO["uid"] then
                    tempTab[v.uid] = v
                    index = index +1
                end
            end

        end

        SHOW_PLAYER_HEAD_INFO = tempTab

        ---先刷新掉头像
        for i=1,12 do
            GamePlaneOperator:setPlayerHeadImg(i)
        end

        if index > 0 then
            local temp = 0
            for k,v in pairs(SHOW_PLAYER_HEAD_INFO) do
                temp = temp+1
                GamePlaneOperator:setPlayerHeadImg(temp,v)
            end
        end
    end
end


return CDSReceiveHandle

--测试性能专用代码
--   local t1 = os.time();
--   for  i =1,10000000  do
--    local CDSReceiveHandle = math.random(1,4)
--        self:getPlayerPlane(CDSReceiveHandle)
-- end

-- local t2 = os.time();
-- print(os.difftime(t2, t1),"运行时间");