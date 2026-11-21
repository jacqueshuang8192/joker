local hallHandle = require("hall.HallHandle")

local run_scene_name = TpackageName..".gameScene"

local Lottery = require(TpackageName .. ".lottery.Lottery")
local PROTOCOL = require(TpackageName .. ".handle.NiuNiuProtocol")
local GamePlaneOperator = require(TpackageName .. ".operator.GamePlaneOperator")
local cardLogicNew = require(TpackageName .. ".cardLogicNew")
local NiuNiuReceiveHandle  = class("NiuNiuReceiveHandle", hallHandle)
-- local dump = function ( ... )
--     -- body
-- end
function NiuNiuReceiveHandle:ctor()

	NiuNiuReceiveHandle.super.ctor(self);

	local func_ = {
         
        --进入游戏成功 0210
        [PROTOCOL.SVR_GET_ROOM_OK] = {handler(self, NiuNiuReceiveHandle.SVR_GET_ROOM_OK)},
        --登录房间成功 1007
        [PROTOCOL.SVR_LOGIN_ROOM] = {handler(self, NiuNiuReceiveHandle.SVR_LOGIN_ROOM)},
        --进入房间失败
        [PROTOCOL.SVR_LOGIN_ROOM_FAIL] = {handler(self, NiuNiuReceiveHandle.SVR_LOGIN_ROOM_FAIL)},  
        --广播其他用户坐下（金币场） 1031
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, NiuNiuReceiveHandle.BROADCAST_USER_SIT_DOWN)},
        --广播其他用户坐下（金币场） 1031
        [PROTOCOL.BROADCAST_USER_SIT_DOWN_NEW] = {handler(self, NiuNiuReceiveHandle.BROADCAST_USER_SIT_DOWN_NEW)},
        -- --广播替换座位ID
        -- [PROTOCOL.BROADCAST_USER_SIT_DOWN_NEW_REPLACE] = {handler(self, NiuNiuReceiveHandle.BROADCAST_USER_SIT_DOWN_NEW_REPLACE)},
        --广播用户退出房间 1032
        [PROTOCOL.BROADCAST_USER_STAND_UP] = {handler(self, NiuNiuReceiveHandle.BROADCAST_USER_STAND_UP)},
       --广播其他用户登录桌子 100D
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, NiuNiuReceiveHandle.SVR_LOGIN_ROOM_BROADCAST)},   
        --广播用户退出房间 100E
        [PROTOCOL.SVR_QUIT_ROOM]            = {handler(self, NiuNiuReceiveHandle.SVR_QUIT_ROOM)},
        --用户退出房间成功（自己）
        [PROTOCOL.SVR_QUICK_SUC]            = {handler(self, NiuNiuReceiveHandle.SVR_QUICK_SUC)}, 
        --错误提示5001
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, NiuNiuReceiveHandle.BROADCAST_ERROR_TIPS)},  
        --广播用户托管1034
        [PROTOCOL.BROADCAST_USER_AUTO_PLAY] = {handler(self, NiuNiuReceiveHandle.BROADCAST_USER_AUTO_PLAY)},
        --广播开始准备 6009 （阶段广播）
        [PROTOCOL.SVR_READY_TIME]           = {handler(self, NiuNiuReceiveHandle.SVR_READY_TIME)},
        --广播用户准备 6001
        [PROTOCOL.SVR_READY_BROADCAST]      = {handler(self, NiuNiuReceiveHandle.SVR_READY_BROADCAST)}, 
        --告知庄家可以开始游戏
    	[PROTOCOL.SERVER_COMMAND_REMAID_START_GAME] = {handler(self, NiuNiuReceiveHandle.SERVER_COMMAND_REMAID_START_GAME)},
    	--告知庄家不可以开始游戏
    	[PROTOCOL.SERVER_COMMAND_REMAID_START_GAME_FAIL] = {handler(self, NiuNiuReceiveHandle.SERVER_COMMAND_REMAID_START_GAME_FAIL)},

        [PROTOCOL.BROADCAST_USER_QUIT_ROOM] = {handler(self, NiuNiuReceiveHandle.BROADCAST_USER_QUIT_ROOM)},
        
        [PROTOCOL.SVR_PLAY_CARD_BROADCAST] = {handler (self , NiuNiuReceiveHandle.SVR_PLAY_CARD_BROADCAST)} , 
        --广播游戏开始
        [PROTOCOL.SVR_BROADCAST_GAME_START]       = {handler(self, NiuNiuReceiveHandle.SVR_BROADCAST_GAME_START)}, 
        --广播开始抢庄（阶段广播）
        [PROTOCOL.SVR_BEGIN_QIANFGZHUANG_BROADCAST]       = {handler(self, NiuNiuReceiveHandle.SVR_BEGIN_QIANFGZHUANG_BROADCAST)}, 
        --广播抢庄过程
        [PROTOCOL.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST]       = {handler(self, NiuNiuReceiveHandle.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST)},   	
    	--广播庄家
    	[PROTOCOL.SVR_BRANK_BROADCAST]            = {handler(self, NiuNiuReceiveHandle.SVR_BRANK_BROADCAST)},  	
        --7001 广播可以开始加倍（阶段广播）
    	[PROTOCOL.SVR_SEND_BASES_TO_USER_BROADCAST]      = {handler(self, NiuNiuReceiveHandle.SVR_SEND_BASES_TO_USER_BROADCAST)}, 
        --6014 广播加倍倍数
    	[PROTOCOL.SVR_USER_BASES_RESULT_BROADCAST]            = {handler(self, NiuNiuReceiveHandle.SVR_USER_BASES_RESULT_BROADCAST)}, 
    	 --1043  广播玩家摊牌
        [PROTOCOL.SVR_OPEN_CARDS_BROADCAST]            = {handler(self, NiuNiuReceiveHandle.SVR_OPEN_CARDS_BROADCAST)},   
        --6008  单局结算（阶段广播）
        [PROTOCOL.SVR_SETTLEMENT_BROADCAST]       = {handler(self, NiuNiuReceiveHandle.SVR_SETTLEMENT_BROADCAST)},  
        --5100，广播总结算
        [PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, NiuNiuReceiveHandle.SVR_GROUP_BILLBOARD)},

        [PROTOCOL.SVR_USER_PLAYED_CARDS_BROADCAST] = {handler(self , NiuNiuReceiveHandle.SVR_USER_PLAYED_CARDS_BROADCAST)},

        --广播当前回合
        [PROTOCOL.SVR_GROUP_TIME] = {handler(self, NiuNiuReceiveHandle.SVR_GROUP_TIME)},
        --4008 广播玩家钱数变化（用于扣取台费）
        [PROTOCOL.SVR_CHIP_CHANGE_BROADCAST]       = {handler(self, NiuNiuReceiveHandle.SVR_CHIP_CHANGE_BROADCAST)}, 
         --111 广播玩家充值
        [PROTOCOL.SVR_CHARGE_BROADCAST]       = {handler(self, NiuNiuReceiveHandle.SVR_CHARGE_BROADCAST)},   


    	--解散相关
    	--没有此房间，解散房间失败
     	[PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, NiuNiuReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},
     	--广播桌子用户请求解散组局
     	[PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, NiuNiuReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
     	--广播当前组局解散情况
     	[PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, NiuNiuReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
     	--广播桌子用户成功解散组局
     	[PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, NiuNiuReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
     	--广播桌子用户解散组局 ，解散组局失败
     	[PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, NiuNiuReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},

        [PROTOCOL.BROADCAST_SENDCARD_REMAINDTIME] = {handler(self , NiuNiuReceiveHandle.BROADCAST_SENDCARD_REMAINDTIME)},

    	--文字聊天相关
     	[PROTOCOL.SVR_MSG_FACE]     = {handler(self, NiuNiuReceiveHandle.SVR_MSG_FACE)},
     	--接收服务器返回的语音表情视频文字 0214
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, NiuNiuReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},
        --接收服务器返回的距离 0213
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, NiuNiuReceiveHandle.SERVER_CMD_MESSAGE)},

         --1100
        [PROTOCOL.SVR_BROADCAST_WAIT_START] = {handler(self, NiuNiuReceiveHandle.SVR_BROADCAST_WAIT_START)},

        [PROTOCOL.SVR_ZHUANG_OPT] = {handler(self, NiuNiuReceiveHandle.SVR_ZHUANG_OPT)},

        [PROTOCOL.SERVER_BROADCAST_XIANJIA_OPT] = {handler(self, NiuNiuReceiveHandle.SERVER_BROADCAST_XIANJIA_OPT)},

        [PROTOCOL.SERVER_BROADCAST_CHOSECARD] = {handler(self, NiuNiuReceiveHandle.SERVER_BROADCAST_CHOSECARD)},

        [PROTOCOL.SERVER_BROADCAST_CHOSETYPE] = {handler(self, NiuNiuReceiveHandle.SERVER_BROADCAST_CHOSETYPE)},

        [PROTOCOL.SERVER_BROADCAST_XIANTYPE] = {handler(self, NiuNiuReceiveHandle.SERVER_BROADCAST_XIANTYPE)},

        [PROTOCOL.SERVER_PlAY_BACK] = {handler(self, NiuNiuReceiveHandle.SERVER_PlAY_BACK)},


    
    }

    table.merge(self.func_, func_)
    
end

--广播开始游戏倒计时 1100
function NiuNiuReceiveHandle:SVR_BROADCAST_WAIT_START(pack)
    dump(pack, "------广播开始游戏倒计时 1100------")
    print(USERS_READY_STATE[USER_INFO.uid])
    --changed by zzy 
    local redayT = pack.time
    local  TablePlaneOperator = require(TpackageName .. ".operator.TablePlaneOperator")
    local tempNode = cc.Node:create()
    SCENENOW["scene"]:addChild(tempNode)
    if redayT < 0 then return end
    local this = self

    GamePlaneOperator:showControlButtons(1)

    SCENENOW["scene"].btn_copy_room_id:setVisible(false)
    SCENENOW["scene"].btn_invite:setVisible(false)

    local dt = cc.DelayTime:create(1)
    local function onTime()
        if USERS_READY_STATE[USER_INFO.uid] == 1 then
            tempNode:stopAllActions()
            tempNode:removeFromParent()
            TablePlaneOperator.stage_txt:setString("")
        else
            redayT = redayT - 1
            TablePlaneOperator.stage_txt:setString("即将开始："..redayT)
            if redayT <= 0 then
                print("=====倒计时为0时候，发送玩家准备=====")
                tempNode:stopAllActions()
                tempNode:removeFromParent()
                NiuNiuSendHandle:readyNow(1)
                TablePlaneOperator.stage_txt:setString("")
            end
        end
        
    end
    local funcTime = cc.CallFunc:create(onTime)
    local seq = cc.Sequence:create(dt,funcTime)
    tempNode:stopAllActions()
    tempNode:runAction(cc.RepeatForever:create(seq))

    print("======广播开始游戏倒计时=====")

end



--协议返回数据接收
function NiuNiuReceiveHandle:callFunc(pack)

    if SCENENOW["name"] ~= run_scene_name then
        print("当前场景不是牛牛游戏场景！")
        return
    end

	if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
	 	dump(pack.cmd,"收到协议，协议号为")
        self.func_[pack.cmd][1](pack)
    end

end


--0210消息，发送进入房间消息113消息后的返回结果,
function NiuNiuReceiveHandle:SVR_GET_ROOM_OK(pack)

    -- dump(pack, "-----牛牛210-----")
    
    local tid = pack.tid   --桌子ID
    
    if  tid == 0 then
	 	require("hall.GameTips"):showTips("提示", "tohall", 1, "游戏已结束") 
        return
    end

    if  GROUP_MODE == 2 then
        
    else
        Tid = tid
        NiuNiuSendHandle:LoginRoom(tid)
    end

end

--进入房间失败 1005
function NiuNiuReceiveHandle:SVR_LOGIN_ROOM_FAIL(pack)

    -- dump(pack, "-----进入房间失败-----")
    print("======进入房间失败======")
    print("======进入房间失败======")
    print("======进入房间失败======")
    print("======进入房间失败======")
    print("======进入房间失败======")
    print("======进入房间失败======")

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
            require("hall.GameTips"):showTips("提示", "tohall", 3, tbErrorCode[pack.errorCode])
        -- elseif  pack.errorCode == 7 or pack.errorCode == 5 then

        --     local exitFunc = function()
        --         require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
        --     end

        --     require("hall.GameTips"):showTips("提示", "", 1, tbErrorCode[pack.errorCode],nil,exitFunc) 
        else
            require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[pack.errorCode]) 
        end
    else
        require("hall.GameTips"):showTips("提示", "", 3, "未知的错误") 
    end

end




--登录房间 1007
function NiuNiuReceiveHandle:SVR_LOGIN_ROOM(pack)
        
    dump(pack, "-----NiuNiuReceiveHandle 牛牛登录房间 1007-----")
    require(NetworkLoadingView_filePath):removeView(888)
    -- require(GameResultScene_filePath):test()
    USER_INFO.is_qipai = pack.is_qipai
    -- dump(USER_INFO)
    RELOGIN_FLAG = true
    HAS_RECEIVE_GROUP_RESULT = false
    
    M_WAIT = 1 == pack.use_wait --表示围观状态. 0表示不围观.1表示围观

    print ("SVR_LOGIN_ROOM_M_WAIT" , M_WAIT)

    BONUS_POOL_COINS  =  pack.bonusPool
    MY_SEAT_ID        =  pack.seat_id --玩家自己本身座位
    GAME_TYPE = pack.gameType
    GAME_STATE    =  pack.table_status
    BANKER_UID       =  pack.bank_uid
    TOTAL_PLAYERNUM = pack.maxPlyaerNum or TOTAL_PLAYERNUM
    BASE_CHIP    =  pack.base
    local gameConfig = pack.gameConfig
    baseChip = pack.base

    initialChip = pack.initialChip 
    isGoldGame =  pack.isGoldGame   

    TOTAL_PLAYERNUM = 9
    GamePlaneOperator:initPlayerPlane(TOTAL_PLAYERNUM)  --TOTAL_PLAYERNUM
    GamePlaneOperator:clearGameDatas(1)
    GamePlaneOperator:clearGameDatas(2)

    if  GROUP_MODE == 2 then
        USER_INFO["activity_id"] = pack.activityId
        USER_INFO["invote_code"] = pack.inviteCode
    end

    if  isGoldGame == 0 then
        initialChip = 0
    end

    if  pack.gameType == 1 then
        GAME_TYPE_NAME = "明牌抢庄" 
    elseif  pack.gameType == 2 then
        GAME_TYPE_NAME = "定庄斗牛" 
    elseif  pack.gameType == 3 then
        GAME_TYPE_NAME = "轮庄斗牛" 
    elseif  pack.gameType == 4 then
        GAME_TYPE_NAME = "牛牛坐庄"         
    end

    NIUNIU_CARDTYPE_TABLE = 
    {
        [1] = 1, --无牛
        [2] = 1,  --牛一
        [3] = 1,
        [4] = 1,
        [5] = 1,
        [6] = 1,
        [7] = 1,
        [8] = 1,
        [9] = 2,
        [10] = 2,--牛九
        [11] = 3,--牛牛
        [CARDKIND_SHUNZI] = 5,-- 顺子牛
        [CARDKIND_WUHUA] = 5,-- 五花牛
        [CARDKIND_TONGHUANIU] = 6,-- 同花牛
        [CARDKIND_HULUNIU] = 6,-- 葫芦牛
        [CARDKIND_SIZHA] = 7,-- 四炸牛
        [CARDKIND_WUXIAONIU] = 8,-- 五小牛
        [CARDKIND_SISHIDA] = 7,-- 四十大
        [-1] = 1,-- 金牌牛
    }

    --通过接口传来的字符串获取具体配置信息
    local gameConfigTable
    if type(gameConfig) =="string" then
        gameConfigTable = json.decode(gameConfig)
    end
  
    USER_INFO["gameConfig"] = gameConfigTable
    SCENENOW["scene"]:updateRoomInfo(baseChip,GAME_TYPE_NAME,pack.inviteCode,nil,nil,gameConfigTable)
    SCENENOW["scene"]:registShareButtons(pack.inviteCode)

    --根据人数更换界面布局
    SCENENOW["scene"]:switchBackGroundGrid(TOTAL_PLAYERNUM)
    if GAME_STATE ~= GAME_STATUS_STOP then
       SCENENOW["scene"]:showShareButton(false)
    end
        ---------------------------------显示信息---------------------------------------
    if  USER_INFO["longitude"] == nil  then
        NiuNiuUtils:getLocationFromDevice()
    end

    GAME_PARTICIPANTS = {}
    for _,v in pairs(pack.users_infos) do
        if  v.user_status == 1 then
            USERS_READY_STATE[v.uid] = 1
            table.insert(GAME_PARTICIPANTS,v.uid)
        else
            USERS_READY_STATE[v.uid] = 0
        end

        NiuNiuUtils:collectPlayerData(v)
    end

    PLAYERNUM = NiuNiuUtils:getPlayerNum()  --先刷新全局人数

    if  MY_SEAT_ID >= 0 then  
        RELATIVE_SEAT_ID = MY_SEAT_ID
        SCENENOW["scene"]:showButtonAfterSitDown(true)

        local seat_id = MY_SEAT_ID
        local uid = USER_INFO["uid"]
        local userInfo = NIUNIU_USERINFO_TABLE[USER_INFO["uid"]]
        local user_if_outline = 1

        NiuNiuUtils:showPlayer(uid,seat_id,userInfo,user_if_outline)
    else          --没准备或者是围观
        RELATIVE_SEAT_ID = 0
    end

    local user_datas = {}
    local send_card_num = nil

    for _,v in pairs(pack.users_infos) do
        local seat_id = v.seat_id
        if  seat_id >= 0 then
            local uid =  v.uid
            local userInfo = NIUNIU_USERINFO_TABLE[uid]

            --add by zzy 2019-6-3
            local playerType = NiuNiuUtils:getPlayerTypeBySeatId(seat_id)
            playerType = NiuNiuUtils:getViewChairId(playerType)
            print("======playerType=====",playerType)
            if  GamePlaneOperator:getSeatBtnPlane(playerType) then
                GamePlaneOperator:getSeatBtnPlane(playerType):setVisible(false)
            end

            local user_if_outline = v.user_if_outline
            NiuNiuUtils:showPlayer(uid,seat_id,userInfo,user_if_outline)

            if uid == USER_INFO["uid"] then
                IS_AUTO_PLAY = v["user_if_auto"] 
                if IS_AUTO_PLAY == 1 then
                    GamePlaneOperator:showAutoPlayTip(true)
                end
            end

            if send_card_num == nil then
                send_card_num = 0

                for _,card in pairs(v.user_base_out_cards) do
                    if card > 0 then
                        send_card_num = send_card_num + 1
                    end
                end

            end

            local tmp_user_data = {cards = v.user_base_out_cards, seatId = seat_id}
            table.insert(user_datas,tmp_user_data)

        end
    end
    ---------------------------------------------------------------------------------
    -- pack.user_status 的可能值
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
    USERS_READY_STATE[USER_INFO["uid"]] = 1

    if  pack.user_status == 0  or pack.user_status == 9 then  --没准备或者是围观
        
        -- RELATIVE_SEAT_ID = 0
        USERS_READY_STATE[USER_INFO["uid"]] = 0

        print (GAME_STATE , "----游戏状态----" , GAME_STATUS_STOP)

        -- --只有在游戏停止时才开启准备按钮
        if  GAME_STATE == GAME_STATUS_STOP then
            GamePlaneOperator:showControlButtons(1)
            GamePlaneOperator:showSitDownButton(false)

        else
            -- GamePlaneOperator:showAudienceBrand(true)
            GamePlaneOperator:showControlButtons(1,false)  
        end    

        if  pack.seat_id < 0 then 
            GamePlaneOperator:showControlButtons(1,false)  
            if  PLAYERNUM < TOTAL_PLAYERNUM then
                GamePlaneOperator:showSitDownButton(true)
            end
        end

    elseif pack.user_status > 1 then
        table.insert(GAME_PARTICIPANTS,USER_INFO["uid"]) 
    end   

    if GAME_STATE ~= GAME_STATUS_STOP and GAME_STATE ~= GAME_STATUS_OUTCARD then

        local pack = {}
        pack.isRelogin = true
        pack.user_datas = user_datas

        if GAME_CONFIG["买牛"] == true then
            pack.send_card_num = send_card_num
        end

        self:SVR_BROADCAST_GAME_START(pack)

    end

    if GAME_STATE == GAME_STATUS_OUTCARD then

        local pack = {}
        pack.time = pack.less_time
        -- self:SVR_PLAY_CARD_BROADCAST(pack)  --广播
    end

    if pack.table_status == 1 then
        GamePlaneOperator:RemaidStartGame(true)
    end

    --用户已准备
    if  pack.user_status == 1 and pack.table_status == 0  then


        local pack = {}
        pack.uid = USER_INFO["uid"]
        pack.readyState = 1

        NiuNiuReceiveHandle:SVR_READY_BROADCAST(pack)



    --等待抢庄，已经做出选择，广播庄家阶段
    elseif pack.user_status == 1 and pack.table_status == 4 then
        print("玩家开始发牌，pack.user_status == 2 or pack.user_status == 3 or pack.user_status == 4")
         print("玩家开始发牌，pack.user_status == 2 or pack.user_status == 3 or pack.user_status == 4")

        print("pack.user_status == 1 or  pack.table_status == 4")
        print ("pack.table_status_pack.table_status_SVR_LOGIN_ROOM" , pack.table_status)
          local pack_tmp     = {}
          pack_tmp.ids       = {}
          pack_tmp.time      = pack.less_time
          pack_tmp.grab_times = pack.grab_times
          pack_tmp.can_grab_times = pack.grab_times_mount

          for  uid,seat_id in pairs(NIUNIU_SEAT_TABLE) do
               table.insert(pack_tmp.ids,uid)
          end

          NiuNiuReceiveHandle:SVR_BEGIN_QIANFGZHUANG_BROADCAST(pack_tmp)

        if pack.is_banker == -1 then
          local pack_tmp     = {}
          pack_tmp.uid       = USER_INFO["uid"]
          pack_tmp.if_qiang  = 0
          -- NiuNiuReceiveHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack_tmp)

        elseif pack.is_banker ~= -1 then

          local pack_tmp     = {}
          pack_tmp.uid       = USER_INFO["uid"]
          pack_tmp.if_qiang  = 1
          NiuNiuReceiveHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack_tmp)

        end

    --等待加倍，已经加倍
    elseif pack.user_status == 1 and pack.table_status == 5 then
        print("玩家开始发牌，pack.user_status == 2 or pack.user_status == 3 or pack.user_status == 4")

        print("pack.user_status == 1 or  pack.table_status == 5")

        if pack.bank_uid ~= USER_INFO["uid"] and pack.is_jiazhu == -1 then
            local pack_tmp     = {}
            pack_tmp.time      = pack.less_time

            pack_tmp.grab_times = pack.selects_base

            --changed by zzy 2019-7-14

            NiuNiuReceiveHandle:BROADCAST_SENDCARD_REMAINDTIME(pack_tmp)
            -- NiuNiuReceiveHandle:SVR_SEND_BASES_TO_USER_BROADCAST(pack_tmp)
        end
        
        if pack.is_jiazhu ~= -1 and pack.bank_uid ~= USER_INFO["uid"] then
            local pack_tmp     = {}
            pack_tmp.uid       = USER_INFO["uid"]
            pack_tmp.base     = pack.is_jiazhu
            NiuNiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
        end

    elseif pack.user_status == 1 and pack.table_status == 6 then 

        print ("")
          if pack.user_status == 1  then

            if  BANKER_UID  ~= USER_INFO["uid"] then
                local pack_tmp     = {}
                pack_tmp.uid       = USER_INFO["uid"]
                pack_tmp.base     = pack.is_jiazhu
                NiuNiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
            end
        
            -- GamePlaneOperator:showControlButtons(5)
        end


    --等待出牌，已经出牌
    elseif pack.table_status == 7 then
        print("玩家开始发牌，pack.user_status == 2 or pack.user_status == 3 or pack.user_status == 4")

      

        --出牌完了
        if pack.is_qipai == 1  then

          if  BANKER_UID  ~= USER_INFO["uid"] then
                local pack_tmp     = {}
                pack_tmp.uid       = USER_INFO["uid"]
                pack_tmp.base      = pack.is_jiazhu
                NiuNiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
          end

          local pack_tmp     = {}
          pack_tmp.uid       = USER_INFO["uid"]
          pack_tmp.cards     = pack.user_base_out_cards
          NiuNiuReceiveHandle:SVR_USER_PLAYED_CARDS_BROADCAST(pack_tmp)

        end
    end

    for i,data in pairs(pack.users_infos) do      

        if  data["uid"] ~= USER_INFO["uid"] then

            if data["user_status"] == 1 then

                local pack = {}
                pack.uid = data["uid"]
                NiuNiuReceiveHandle:SVR_READY_BROADCAST(pack)

            --不抢庄
            elseif pack.table_status == 4  and data["user_status"] == 1 and data.is_banker ~= -1  then
                local pack_tmp     = {}
                pack_tmp.uid       = data.uid
                pack_tmp.if_qiang  = 0
                NiuNiuReceiveHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack_tmp)

            --抢庄
            elseif pack.table_status == 4  and data["user_status"] == 1 and data.is_banker == -1 and pack.bank_uid ~= data["uid"] then
                local pack_tmp     = {}
                pack_tmp.uid       = data.uid
                pack_tmp.if_qiang  = 1
                NiuNiuReceiveHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack_tmp)
            --加倍完成
            elseif pack.table_status == 5  and data["user_status"] == 1 and data.is_jiazhu ~= -1 and pack.bank_uid ~= data["uid"] then
                local pack_tmp     = {} 
                pack_tmp.uid       = data.uid
                pack_tmp.base      = data.is_jiazhu
                NiuNiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)

            --等待出牌
            elseif pack.table_status == 6 and data["user_status"] == 1 and data.is_qipai == 0 then
                if  pack.bank_uid  ~= data.uid then
                  local pack_tmp     = {}
                  pack_tmp.uid       = data.uid
                  pack_tmp.base      = data.is_jiazhu
                  -- NiuNiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
                end

            --出牌完成
            elseif pack.table_status == 7 and data["user_status"] == 1 then
                if  pack.bank_uid  ~= data.uid then
                  local pack_tmp     = {}
                  pack_tmp.uid       = data.uid
                  pack_tmp.base      = data.is_jiazhu
                  NiuNiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
                end

                local pack_tmp     = {}
                pack_tmp.uid       = data.uid
                pack_tmp.kind      = data.user_base_out_cards_cardkind
                pack_tmp.cards     = data.user_base_out_cards
                NiuNiuReceiveHandle:SVR_USER_PLAYED_CARDS_BROADCAST(pack_tmp)
            end

        end
    end

    --显示庄家
    local  BankerPlayerType = NIUNIU_PLAYERTYPE_TABLE[pack.bank_uid] 
    if pack.bank_uid ~= -1  and pack.table_status >= 2 then
        GamePlaneOperator:showHeadSymbol(BankerPlayerType,"banker",true)  
    end

    --如果存在牌，则显示牌
    local card_state = pack.table_status == 6 or pack.table_status == 8
    if pack.user_status == 1 then

        CARD_DATAS = pack.cards 
        print("重连玩家自己的牌！")     
        -- dump(pack.cards)
        local pack_tmp     = {}
        pack_tmp.cards     = pack.cards
        pack_tmp.mount     = pack.card_mount
        pack_tmp.userMount = pack.user_mount
        pack_tmp.users     = {}
        for k,v in pairs(pack.users_infos) do
            local tempArr = {}
            tempArr.seat_id = v.seat_id
            tempArr.mount = v.user_base_out_cards_mount
            tempArr.cards = v.user_base_out_cards
            tempArr.is_qipai = v.is_qipai
            if v.is_qipai == 0  then
                if v.uid == USER_INFO.uid then
                    
                else
                    tempArr.cards = {0,0,0,0}
                end
            end
            -- dump(tempArr.cards,"7776666666666666")
            table.insert(pack_tmp.users,tempArr)
        end

        pack_tmp.isRelogin   = true

        FIRSTSENDCARD = false
        NiuNiuReceiveHandle:SVR_SEND_USER_CARD(pack_tmp , card_state)
    end

    if pack.user_status == 1 and pack.table_status == 6 then 
        local pack_tmp = {}
        pack_tmp.time = pack.less_time
        pack_tmp.cards = pack.cards 
        print ("NiuNiuReceiveHandle_SVR_PLAY_CARD_BROADCAST")
        NiuNiuReceiveHandle:SVR_PLAY_CARD_BROADCAST(pack_tmp , true)
    end



end

---------------------------------------------------------------------------------------------------------------

--广播围观者登录桌子 110D   
function  NiuNiuReceiveHandle:SVR_COMMAND_WAITING_USERINFOS(pack)

    -- dump(pack, "------广播围观者登录桌子110D------")
    local wait_players = pack.wait_players

    for _,data in pairs(wait_players) do
        NiuNiuUtils:collectPlayerData(data)
    end

end


--广播用户登录桌子 100D   其他用户进入房间
function  NiuNiuReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)

    -- dump(pack, "------广播用户登录桌子100D------")
    -- dump( "------广播用户登录桌子100D------")
    -- dump( "------广播用户登录桌子100D------")
    -- dump( "------广播用户登录桌子100D------")
    -- dump( "------广播用户登录桌子100D------")
    -- dump( "------广播用户登录桌子100D------")
    NiuNiuUtils:collectPlayerData(pack)

    PLAYERNUM = NiuNiuUtils:getPlayerNum()  --先刷新全局人数

    -- local seat_id = pack.seat_id
    -- if  seat_id >= 0 then
    --     local uid =  pack.uid
    --     local userInfo = NIUNIU_USERINFO_TABLE[uid]
    --     local user_if_outline = pack.user_if_outline
    --     NiuNiuUtils:showPlayer(uid,seat_id,userInfo,user_if_outline)
    -- end

    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    if  playerType then
        GamePlaneOperator:showHeadSymbol(playerType,"disconnect",false)  
    end

end

--广播自己退出 1008   
function  NiuNiuReceiveHandle:SVR_QUICK_SUC(pack)
    -- dump("广播自己退出")
    if  GROUP_MODE == 2 then
        require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
        --SCENENOW["scene"]:reConnect()
     -- require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

    end
    -- require("hall.ScoketGame"):showReloginTip()    
end

--广播玩家退出返回（断线） 100E
function NiuNiuReceiveHandle:SVR_QUIT_ROOM(pack)

    -- dump(pack, "------广播玩家退出返回100E------")
    
    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    if  playerType then
        GamePlaneOperator:showHeadSymbol(playerType,"disconnect",true)  
    end

end

local sevenArr = {"红色","蓝色","黑色","白色","橙色","黄色","紫色","红色","蓝色","黑色","白色","橙色","黄色","紫色"}
local nineArr = {"青龙","白虎","朱雀","玄武","麒麟","貔貅","凤凰","白泽","饕餮","青龙","白虎","朱雀","玄武","麒麟","貔貅","凤凰","白泽","饕餮"}
local twelveArr = {"水瓶座","双鱼座","白羊座","金牛座","双子座","巨蟹座","狮子座","处女座","天瓶座","天蝎座","射手座","摩羯座","水瓶座","双鱼座","白羊座","金牛座","双子座","巨蟹座","狮子座","处女座","天瓶座","天蝎座","射手座","摩羯座"}

--广播用户坐下 1031   其他用户进入房间
function  NiuNiuReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
    print("==1031==1031==1031==")
    print("==1031==1031==1031==")
    print("==1031==1031==1031==")
    print("==1031==1031==1031==")
    
    -- dump (pack,"----BROADCAST_USER_SIT_DOWN---")
    -- dump(NIUNIU_SEAT_TABLE)

    local tempYuanLaiSeatId = pack.seat_id_old or -1

    print("=====777777777777777===tempYuanLaiSeatId==",tempYuanLaiSeatId,USERS_READY_STATE[USER_INFO["uid"]])
    print("=====777777777777777=====")
    print("=====777777777777777=====")
    print("=====777777777777777=====")
    print("=====777777777777777=====")


    NIUNIU_SEAT_TABLE[pack.uid] = pack.seat_id --保存用户座位与id映射

    --add by zzy
    NIUNIU_OLD_SEAT_TABLE[pack.uid] = tempYuanLaiSeatId

    PLAYERNUM = NiuNiuUtils:getPlayerNum()  --先刷新全局人数
    
    GamePlaneOperator:getSeatBtnPlane(1):setVisible(false)


    if  USER_INFO["uid"] == pack.uid then  --自己坐下的话重新排版布局

        print("桌面其他玩家的所有信息！！！")
        print("桌面其他玩家的所有信息！！！")
        print("桌面其他玩家的所有信息！！！")
        print("桌面其他玩家的所有信息！！！")
        -- dump(NIUNIU_USERINFO_TABLE)
         
        SCENENOW["scene"]:showButtonAfterSitDown(true)
        GamePlaneOperator:showSitDownButton(false)

        --重定位逻辑
        MY_SEAT_ID = pack.seat_id

        for i=2,TOTAL_PLAYERNUM do
            GamePlaneOperator:getSeatBtnPlane(i):setVisible(true)
        end
        
        if  GAME_STATE == GAME_STATUS_STOP then --游戏前加入重定位
            RELATIVE_SEAT_ID = MY_SEAT_ID
            GamePlaneOperator:showControlButtons(1)
            GamePlaneOperator:clearGameDatas(2)
            NiuNiuUtils:relocatePlayer()
        elseif  RELATIVE_SEAT_ID == MY_SEAT_ID then
            NiuNiuUtils:relocatePlayer()
        else
            local seat_id = MY_SEAT_ID
            if  seat_id >= 0 then
                local uid =  pack.uid
                local userInfo = NIUNIU_USERINFO_TABLE[uid]
                local user_if_outline = false  --用户是否掉线
                NiuNiuUtils:showPlayer(uid,seat_id,userInfo,user_if_outline)
            end
        end

        --ADD BY ZZY 2019-7-4
        -- local strArr = nil
        -- if TOTAL_PLAYERNUM == 7 then
        --     strArr = sevenArr
        -- elseif TOTAL_PLAYERNUM == 9 then
        --     strArr = nineArr
        -- elseif TOTAL_PLAYERNUM == 12 then
        --     strArr = twelveArr
        -- end
        -- for i=1,TOTAL_PLAYERNUM do
        --     local tempPlaneNode = GamePlaneOperator:getSeatBtnPlane(i)
        --     local txt_name = tempPlaneNode:getChildByName("name")
        --     local tempNum = MY_SEAT_ID - i + 1
        --     local tempIndex = 1
        --     if tempNum >=  0 then
        --         tempIndex = tempNum + 1
        --     else
        --         tempIndex = tempNum + TOTAL_PLAYERNUM+1
        --     end
        --     txt_name:setString(strArr[tempIndex] or "")

        --     if i == TOTAL_PLAYERNUM then
        --         print("====tempIndex===MY_SEAT_ID====",tempIndex,MY_SEAT_ID)
        --     end
        -- end


        --游戏过程中加入不会重定位




    else  --其他人坐下的话只给他画头像信息

        -- NiuNiuUtils:collectPlayerData(pack)
        local seat_id = pack.seat_id
        if  seat_id >= 0 then
            local uid =  pack.uid
            local userInfo = NIUNIU_USERINFO_TABLE[uid]
            local user_if_outline = false
            NiuNiuUtils:showPlayer(uid,seat_id,userInfo,user_if_outline)
        end

        if pack.seat_id >= 0 then
            local playerType = NiuNiuUtils:getPlayerTypeBySeatId(pack.seat_id)
            playerType = NiuNiuUtils:getViewChairId(playerType)
            print("======playerType=====",playerType)
            if  GamePlaneOperator:getSeatBtnPlane(playerType) then
                GamePlaneOperator:getSeatBtnPlane(playerType):setVisible(false)
            end
        end

        if pack.seat_id >= 0 and USERS_READY_STATE[USER_INFO["uid"]] ~= 1 then
            local playerType = NiuNiuUtils:getPlayerTypeBySeatId(pack.seat_id)
            playerType = NiuNiuUtils:getViewChairId(playerType)
            print("======playerType=====",playerType)
            if  GamePlaneOperator:getSeatBtnPlane(playerType) and playerType ~= 1 then
                GamePlaneOperator:getSeatBtnPlane(playerType):setVisible(false)
            end
            if  GamePlaneOperator:getPlayerPlane(playerType) then
                 GamePlaneOperator:getPlayerPlane(playerType):setVisible(true)
            end

        end

       -- --如果是别的人换位置，则将原来的位置设置为TRUE
        if tempYuanLaiSeatId >= 0 and USERS_READY_STATE[USER_INFO["uid"]] ~= 1 then
            local playerType_old = NiuNiuUtils:getPlayerTypeBySeatId(tempYuanLaiSeatId)
            playerType_old = NiuNiuUtils:getViewChairId(playerType_old)
            print("======playerType_old=====",playerType_old)
            if  playerType_old > 0  then
                print ("NIUNIURECVAFS")
                GamePlaneOperator:getSeatBtnPlane(playerType_old):setVisible(true)
            end

            if playerType_old > 0 and playerType_old ~= 1 then
                GamePlaneOperator:getPlayerPlane(playerType_old):setVisible(false)
            end
        elseif tempYuanLaiSeatId >= 0 and USERS_READY_STATE[USER_INFO["uid"]] == 1 then
            local playerType_old = NiuNiuUtils:getPlayerTypeBySeatId(tempYuanLaiSeatId)
            playerType_old = NiuNiuUtils:getViewChairId(playerType_old)
            if playerType_old > 0 and playerType_old ~= 1 then
                GamePlaneOperator:getPlayerPlane(playerType_old):setVisible(false)
            end
        end
        GamePlaneOperator:getSeatBtnPlane(1):setVisible(false)

    end
    
    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    if  playerType then
        GamePlaneOperator:showHeadSymbol(playerType,"disconnect",false)  
        GamePlaneOperator:setCoin(playerType,pack.gold / 100)
    end

    --人满之后自己作为旁观者时隐藏坐下按钮
    if  MY_SEAT_ID < 0 then
        if  PLAYERNUM == TOTAL_PLAYERNUM then
            GamePlaneOperator:showSitDownButton(false)
        end
    end

end

--广播用户坐下 8001   其他用户进入房间
function  NiuNiuReceiveHandle:BROADCAST_USER_SIT_DOWN_NEW(pack)

    print("==8001==8001==8001==")
    print("==8001==8001==8001==")
    print("==8001==8001==8001==")
    print("==8001==8001==8001==")

    dump (pack,"----BROADCAST_USER_SIT_DOWN_NEW---")
    NIUNIU_SEAT_TABLE[pack.uid] = pack.seat_id --保存用户座位与id映射

    PLAYERNUM = NiuNiuUtils:getPlayerNum()  --先刷新全局人数
    if  USER_INFO["uid"] == pack.uid then  --自己坐下的话重新排版布局
         
        SCENENOW["scene"]:showButtonAfterSitDown(true)
        GamePlaneOperator:showSitDownButton(false)

        --重定位逻辑
        MY_SEAT_ID = pack.seat_id
        
        if  GAME_STATE == GAME_STATUS_STOP then --游戏前加入重定位
            RELATIVE_SEAT_ID = MY_SEAT_ID
            GamePlaneOperator:showControlButtons(1)
            GamePlaneOperator:clearGameDatas(2)
            NiuNiuUtils:relocatePlayer()
        elseif  RELATIVE_SEAT_ID == MY_SEAT_ID then
            NiuNiuUtils:relocatePlayer()
        else
            local seat_id = MY_SEAT_ID
            if  seat_id >= 0 then
                local uid =  pack.uid
                local userInfo = NIUNIU_USERINFO_TABLE[uid]
                local user_if_outline = false  --用户是否掉线
                NiuNiuUtils:showPlayer(uid,seat_id,userInfo,user_if_outline)
            end
        end


        --游戏过程中加入不会重定位

    else  --其他人坐下的话只给他画头像信息

        -- NiuNiuUtils:collectPlayerData(pack)
        local seat_id = pack.seat_id
        if  seat_id >= 0 then
            local uid =  pack.uid
            local userInfo = NIUNIU_USERINFO_TABLE[uid]
            local user_if_outline = false
            NiuNiuUtils:showPlayer(uid,seat_id,userInfo,user_if_outline)

        end

    end
    
    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    if  playerType then
        GamePlaneOperator:showHeadSymbol(playerType,"disconnect",false)
        GamePlaneOperator:setCoin(playerType,pack.gold)  
    end

    --人满之后自己作为旁观者时隐藏坐下按钮
    if  MY_SEAT_ID < 0 then
        if  PLAYERNUM == TOTAL_PLAYERNUM then
            GamePlaneOperator:showSitDownButton(false)
        end
    end

end

--广播玩家站起 1032
function NiuNiuReceiveHandle:BROADCAST_USER_STAND_UP(pack)

    dump(pack, "------广播玩家站起1032------")

    local seat_id = NIUNIU_SEAT_TABLE[pack.uid]

    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    -- NiuNiuUtils:returnPlayerType(NIUNIU_PLAYERTYPE_TABLE[pack.uid])
    
    if  playerType then
        
        if  HAS_RECEIVE_GROUP_RESULT == true then
            return
        end

        GamePlaneOperator:removePlayer(playerType)
        Lottery:showPlaneItemChange(seat_id, "standUp")
    end
    
    NIUNIU_PLAYERTYPE_TABLE[pack.uid] = nil

    NIUNIU_UID_TABLE[seat_id] = nil
    NIUNIU_SEAT_TABLE[pack.uid] = -2

    PLAYERNUM = NiuNiuUtils:getPlayerNum()  --先刷新全局人数

    if  USER_INFO["uid"] == pack.uid then
        GamePlaneOperator:showControlButtons(1,false)
        GamePlaneOperator:showSitDownButton(true)

        SCENENOW["scene"]:showButtonAfterSitDown(false)
        MY_SEAT_ID = -2

    elseif  MY_SEAT_ID < 0 then  --别人站起，自己也站着的时候
        GamePlaneOperator:showSitDownButton(true)
    end

    -- local uid = pack.uid
    -- if  uid and require("hall.view.userInfoView.userInfoView").upDateUserInfo then
    --     require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,{["latitude"] = nil},"latitude")
    --     require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,{["longitude"] = nil},"longitude")
    -- end

end

--广播玩家退出返回（离开房间） 1033
function NiuNiuReceiveHandle:BROADCAST_USER_QUIT_ROOM(pack)

    dump(pack, "------广播玩家退出返回1033------")
    dump( "------广播玩家退出返回1033------")
    dump( "------广播玩家退出返回1033------")
    dump( "------广播玩家退出返回1033------")
    dump( "------广播玩家退出返回1033------")
    dump( "------广播玩家退出返回1033------")

    if  HAS_RECEIVE_GROUP_RESULT == true then
        return
    end

    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    -- NiuNiuUtils:returnPlayerType(NIUNIU_PLAYERTYPE_TABLE[pack.uid])

    if  playerType then
        GamePlaneOperator:removePlayer(playerType)
        Lottery:showPlaneItemChange(seat_id, "leaveRoom")
        GamePlaneOperator:showHeadSymbol(playerType,"disconnect",false)
    end

    NIUNIU_PLAYERTYPE_TABLE[pack.uid] = nil

    local  seat_id = NIUNIU_SEAT_TABLE[pack.uid]
    if  seat_id and seat_id>=0 then
        NIUNIU_UID_TABLE[seat_id] = nil
    end

    NIUNIU_SEAT_TABLE[pack.uid] = nil
    USERS_READY_STATE[pack.uid] = nil

    PLAYERNUM = NiuNiuUtils:getPlayerNum()  --先刷新全局人数

    if  pack.uid == USER_INFO["uid"] then
        if  isGoldGame == 0 or (isGoldGame == 1 and GAME_ROUND < GAME_TOTAL_ROUND and HAS_RECEIVE_GROUP_RESULT ~= true) then
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
            HEART_BEAT_TID = 0
        end
    end

    local uid = pack.uid
    if  uid and require("hall.view.userInfoView.userInfoView").upDateUserInfo then
        require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,{},"reset")
    end
    
end



--1041 广播下注剩余时间
function NiuNiuReceiveHandle:BROADCAST_SENDCARD_REMAINDTIME(pack)
    dump (pack , "------广播用户开始下注-----")
    dump ("------广播用户开始下注-----")
    dump ("------广播用户开始下注-----")
    dump ("------广播用户开始下注-----")
    dump ("------广播用户开始下注-----")
    dump ("------广播用户开始下注-----")
    dump ("------广播用户开始下注-----")

    print ("BROADCAST_SENDCARD_REMAINDTIME_M_WAIT" , M_WAIT)
    if M_WAIT then 
        return 
    end

    GAME_STATE = GAME_STATUS_TIMES
    --显示玩家自己可以选择的倍数
    if  BANKER_UID == USER_INFO["uid"]  then
        return 
    end
    GamePlaneOperator:startTimer(pack.time,"下注阶段")
    GamePlaneOperator:showControlButtons(3 , true)

    local card = {}
    for k , v in ipairs(pack.grab_times) do 
        card[k] = v 
    end
    table.insert(card , 0)
    GamePlaneOperator:loadBetButtons(card)
end

--5001
function NiuNiuReceiveHandle:BROADCAST_ERROR_TIPS(pack)

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
        [24] = "此牌已被使用！",
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
        require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[errorCode]) 
    else
        require("hall.GameTips"):showTips("提示", "", 3, "未知的错误") 
    end

end

--5101
function NiuNiuReceiveHandle:SVR_GROUP_TIME(pack)
    dump(pack)
    print("=====SVR_GROUP_TIME==6666666==")
    print("=====SVR_GROUP_TIME==6666666==")
    print("=====SVR_GROUP_TIME==6666666==")
    print("=====SVR_GROUP_TIME==6666666==")
    GAME_ROUND = pack.round
    GAME_TOTAL_ROUND = pack.round_total or 999
    
    if  isGoldGame == 0 then 
        GAME_TOTAL_ROUND = 999
    end

    SCENENOW["scene"]:updateRoomInfo(nil,nil,nil,GAME_ROUND,GAME_TOTAL_ROUND , USER_INFO["gameConfig"])
   
   local c = USERS_READY_STATE[USER_INFO.uid]
    if c == 1 or GAME_ROUND > 0 then
        for i = 1 , TOTAL_PLAYERNUM do
            GamePlaneOperator:getSeatBtnPlane(i):setVisible(false)
        end
    end
   
    --add by zzy 2019-7-17 游戏没有开始屏蔽解散房间
    SCENENOW["scene"].GameRound = pack.round


end

--广播玩家开启托管 1034
function NiuNiuReceiveHandle:BROADCAST_USER_AUTO_PLAY(pack)
    
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


--广播开始游戏倒计时 100F
function NiuNiuReceiveHandle:SVR_BROADCAST_COUNT_DOWN(pack)
    
    dump(pack, "------广播开始游戏倒计时 100F------")
    print (pack , "-----时间-----")
    if  pack.time > 0 then
        print("=1086===GamePlaneOperator:startTimer(pack.time,准备阶段)=====")
        GamePlaneOperator:startTimer(pack.time,"准备阶段")

        --游戏开始时才清除数据
        if  RELOGIN_FLAG ~= true then
            Lottery:clearGameDatas()
            GamePlaneOperator:clearGameDatas(2)
        end

        if  USERS_READY_STATE[USER_INFO["uid"]] and USERS_READY_STATE[USER_INFO["uid"]] ~= 1 and MY_SEAT_ID >= 0 then
            GamePlaneOperator:showControlButtons(1)
        end

        SCENENOW["scene"]:showShareButton(false)
    end

    RELOGIN_FLAG = false
end

--准备相关
--广播用户可以准备了
function NiuNiuReceiveHandle:SVR_READY_TIME(pack)
    
    dump(pack, "------广播用户可以准备了6009------")

    GAME_STATE = GAME_STATUS_STOP      --准备阶段
end

--广播玩家准备 用户准备了返回
function NiuNiuReceiveHandle:SVR_READY_BROADCAST(pack)
    
    dump(pack, "------广播玩家准备6001------")
    GamePlaneOperator:clearGameDatas(2)
    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    local readyState = pack.readyState  --1是准备，0是取消准备

    if  playerType then
        if readyState == 0 then 
            GamePlaneOperator:setReadyStatus(playerType,false)
        else
            GamePlaneOperator:setReadyStatus(playerType,"action")    
        end
    end

    if  pack.uid == USER_INFO["uid"] then
        if readyState == 0 then
            GamePlaneOperator:showControlButtons(1)
        else
            GamePlaneOperator:showControlButtons(1,false)
        end
    end

    if readyState == 0 then
        USERS_READY_STATE[pack.uid] = 0
    else
        USERS_READY_STATE[pack.uid] = 1
    end

    --add by zzy 2019-6-3
    if pack.uid == USER_INFO.uid then
        for i=1,TOTAL_PLAYERNUM do
            if  GamePlaneOperator:getSeatBtnPlane(i) then
                print ("SVR_READY_BROADCAST")
                GamePlaneOperator:getSeatBtnPlane(i):setVisible(false)
            end
        end
    end

end

----------------------------------------------------------------------------------------
--所有人都已准备，广播可以开始游戏
function NiuNiuReceiveHandle:SERVER_COMMAND_REMAID_START_GAME()
    GamePlaneOperator:RemaidStartGame(true)
end

--有人未准备，隐藏开始游戏按钮
function NiuNiuReceiveHandle:SERVER_COMMAND_REMAID_START_GAME_FAIL()
    GamePlaneOperator:RemaidStartGame(false)
end

--广播游戏开始 6002
function NiuNiuReceiveHandle:SVR_BROADCAST_GAME_START(pack)
    -----------------------------游戏开始-------------------------------

    dump(pack, "SVR_BROADCAST_GAME_START")
    print ("SVR_BROADCAST_GAME_START" , USER_INFO["uid"] , "pack.use_wait" , pack.use_wait)
    M_WAIT = 1 == pack.use_wait --表示围观状态. 0表示不围观.1表示围观

    GamePlaneOperator:showSitDownButton(false)  --隐藏坐下按钮
    SCENENOW["scene"]:showShareButton(false)    --隐藏分享按钮
    GamePlaneOperator:RemaidStartGame(false)    --隐藏开始按钮
   
    GamePlaneOperator:clearAllReadyStatus()  --游戏开始后清除准备状态

    FIRSTSENDCARD = true   --重置发牌变量

    if  USERS_READY_STATE[USER_INFO["uid"]] == 0 then  --如果我在游戏开始时不在准备状态的话，进入旁观模式
        GamePlaneOperator:showAudienceBrand(true)
    end



    ----------------------------------
    local cardEndIndex =  4
    local dealCardIndex = 1

    GAME_PARTICIPANTS = {}

    for uid,ready_state in pairs(USERS_READY_STATE) do 
        if  ready_state == 1 then
            table.insert(GAME_PARTICIPANTS,uid) 
        end
    end

    local isRelogin = pack.isRelogin


    if  isRelogin == true then

        for _,data in ipairs(pack.user_datas) do
                
            local playerType = NIUNIU_PLAYERTYPE_TABLE[data.uid]
            if  playerType and data.uid ~= USER_INFO["uid"] and cardEndIndex > 0 then
                GamePlaneOperator:showDealCardsAnimation(playerType,data.cards,cardEndIndex)
            end

             if data.uid == USER_INFO["uid"] then 

                CARD_DATAS = data.cards
                
            end 

        end

    else


        for _,data in ipairs(pack.user_datas) do
            
            local playerType = NIUNIU_PLAYERTYPE_TABLE[data.uid]
            if  playerType and cardEndIndex > 0 then
                print("玩家发牌，还没有让它直接弃牌的时候")
                dump(data.cards)

                --围观的时候.不发自己的手牌
                if M_WAIT and data.uid ~= USER_INFO["uid"] then 
                    SCENENOW["scene"]:performWithDelay(function()
                        GamePlaneOperator:showDealCardsAnimation(playerType,data.cards,cardEndIndex)
                    end,dealCardIndex*0.05)
                end

                --不是围观的时候.全发牌
                if not M_WAIT then 
                     SCENENOW["scene"]:performWithDelay(function()
                        GamePlaneOperator:showDealCardsAnimation(playerType,data.cards,cardEndIndex)
                    end,dealCardIndex*0.05)
                end

                dealCardIndex = dealCardIndex + 1
            end

            if data.uid == USER_INFO["uid"] then 
                CARD_DATAS = data.cards
            end 

        end



    end


end



---------------------------------------------------------------------------------------------------------------------------------------------
--庄家相关
--广播开始抢庄（游戏开始，第一阶段）
function NiuNiuReceiveHandle:SVR_BEGIN_QIANFGZHUANG_BROADCAST(pack)
    
    print ("--------广播开始抢庄---------")

    dump(pack,"-----广播开始抢庄6015-----")
    
    print ("M_WAIT" , M_WAIT)
    if M_WAIT then 
        return 
    end
    --棋牌进行中
    GAME_STATE = GAME_STATUS_GRAB

    local time = pack.time

    Lottery:remainStageProgress(time,"grabGameBanker")
    GamePlaneOperator:startTimer(time,"抢庄阶段")

    local card = {}
    for k , v in ipairs(pack.grab_times) do 
        card[k] = v 
    end
    table.insert(card , 0)

    local tempNode = cc.Node:create()
    SCENENOW["scene"]:addChild(tempNode)

    local dyT = cc.DelayTime:create(2)
    local function func()
        GamePlaneOperator:loadGrabBankerButtons(card)
        tempNode:stopAllActions()
        tempNode:removeFromParent()
    end
    local funcTime = cc.CallFunc:create(func)
    local seq = cc.Sequence:create(dyT,funcTime)
    tempNode:runAction(seq)
    GamePlaneOperator:showControlButtons(2) 

end

--处理抢庄  广播抢庄情况6013
function NiuNiuReceiveHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack)
    
    dump(pack,"------广播玩家抢庄6013-----")
     
    -- M_WAIT = 1 == pack.use_wait --表示围观状态. 0表示不围观.1表示围观
    print ("SVR_USER_QIANFGZHUANG_RESULT_BROADCAST_M_WAIT" , M_WAIT)
    if M_WAIT then 
        return 
    end

    local uid = pack.uid
    if  uid == USER_INFO["uid"] then
        GamePlaneOperator:showControlButtons(2 , false)
        GamePlaneOperator:showStageTxt("等待其他玩家操作...")
    end

    local  grabTimes = pack.if_qiang

    if  grabTimes > 0 then

        local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
        -- dump(NIUNIU_PLAYERTYPE_TABLE,"SVR_USER_QIANFGZHUANG_RESULT_BROADCAST_playerType")
        RANDOM_BANKER[uid] = grabTimes
        GamePlaneOperator:setGrabBankerSymbol(playerType)
        GamePlaneOperator:setGrabBankerTimes(playerType,grabTimes)

    end

end


--- 准备阶段    ----- 抢庄阶段 ------  加倍阶段 -----  出牌阶段  

-- 准备按钮 ----- 已准备（隐藏准备按钮） ---  开始游戏按钮 -----  抢庄面板（隐藏开始游戏按钮）  
---- 隐藏抢庄面板 -----  显示加倍面板 ----  隐藏加倍面板 ---- 显示出牌面板 ------ 隐藏出牌面板 ------ 准备按钮

--广播庄家id
function NiuNiuReceiveHandle:SVR_BRANK_BROADCAST(pack)

    dump(pack, "------广播庄家id 6003-----")
    dump("------广播庄家id 6003-----")
    dump("------广播庄家id 6003-----")
    dump("------广播庄家id 6003-----")
    dump("------广播庄家id 6003-----")

    -- if pack.uid == -1 or GAME_TYPE_NAME == "通比牛牛" then
    --     return
    -- end

    -- local broadcast_banker_delay = 0.1
    
    BANKER_UID = pack.uid

    GamePlaneOperator:showControlButtons(2,false)

    local BankerPlayerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]

  

    -- --隐藏抢庄标记
    GamePlaneOperator:clearGrabBankerSymbol()
 
    -- if  GAME_TYPE == 1 then 

    --     local grab_bankers = {}

    --     if  table.nums(RANDOM_BANKER) == 0 then
    --         GamePlaneOperator:showRandomBankerChoose(GAME_PARTICIPANTS)
    --         broadcast_banker_delay = 1.77
    --         -- GamePlaneOperator:startTimer(2,"抢庄阶段")
    --         GamePlaneOperator:showStageTxt("随机庄家中...")
    --     else
    --         local highest = 1
    --         for uid,times in pairs(RANDOM_BANKER) do

    --             if  times > highest then
    --                 highest = times 
    --                 grab_bankers = {}
    --                 table.insert(grab_bankers,uid)
    --             elseif times == highest then
    --                 table.insert(grab_bankers,uid)
    --             end

    --         end

    --         GamePlaneOperator:showRandomBankerChoose(grab_bankers)
            
    --         if  #grab_bankers > 1 then 
    --             broadcast_banker_delay = 1.77
    --             -- GamePlaneOperator:startTimer(2,"抢庄阶段")
    --             GamePlaneOperator:showStageTxt("随机庄家中...")
    --         end

    --     end

    -- end

    -- RANDOM_BANKER = {}
    
    -- SCENENOW['scene']:performWithDelay(function()
        
    --     if  GAME_TYPE_NAME ~= "定庄牛牛" then 
    --         GamePlaneOperator:showBankerChoose(pack.uid)
    --         SoundUtils:playEffect("定庄特效")
    --     end

    --     --清除抢庄失败的人的抢庄倍数
    --     for playerType = 1,TOTAL_PLAYERNUM do 
    --         if  playerType ~= BankerPlayerType  then
    --             GamePlaneOperator:setGrabBankerTimes(playerType,0,false)
    --         end
    --     end
           
    --     GamePlaneOperator:showStageTxt("等待闲家加倍...")

        GamePlaneOperator:clearBankerFlag()  --出现了一个莫名其妙的显示两个庄家的BUG，于是现在在确定前先把所有的庄家标记删了
    --     --显示庄
        GamePlaneOperator:showHeadSymbol(BankerPlayerType,"banker",true)  
    --     -- SCENENOW["scene"]:updateRoomInfo(nil,pack.uid)

    --     Lottery:remainStageProgress(time,"gameBet")
        GamePlaneOperator:stopTimer()

    -- end,broadcast_banker_delay)

end

---------------------------------------------------------------------------------------------------------------------------------------------
--倍数相关
--处理加倍
function NiuNiuReceiveHandle:SVR_SEND_BASES_TO_USER_BROADCAST(pack)

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
    print("=1472===GamePlaneOperator:startTimer(pack.time,加倍阶段)=====")
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
function NiuNiuReceiveHandle:SVR_USER_BASES_RESULT_BROADCAST(pack)
    
    dump(pack, "-----广播加倍倍数6014-----")
        
    if M_WAIT then 
        return 
    end

    -- if pack.uid ~= BANKER_UID then
    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.uid]
    GamePlaneOperator:setBetTimes(playerType , pack.base)
    -- end
    
    if  pack.uid == USER_INFO["uid"] then
        -- if GAME_CONFIG["买牛"] ~= true then
            
        -- end
        GamePlaneOperator:showStageTxt("等待其他玩家加倍...")
        GamePlaneOperator:showControlButtons(3 , false)
    end

end
---------------------------------------------------------------------------------------------------------------------------------------------
--发牌相关
--处理发牌协议 4001 (第一次发标志着游戏的开始)
function NiuNiuReceiveHandle:SVR_SEND_USER_CARD(pack , card_state)
    dump(pack, "------发送用户的牌信息4001------")

    dump("", "------发送用户的牌信息4001------")
    dump("", "------发送用户的牌信息4001------")
    dump("", "------发送用户的牌信息4001------")
    dump("", "------发送用户的牌信息4001------")
    dump("", "------发送用户的牌信息4001------")

    -- dump(debug.traceback(),"追踪4001的来源")
    dump(FIRSTSENDCARD,"4001FIRSTSENDCARD")
    -- dump(debug.traceback(),"SVR_SEND_USER_CARD_DEBUG_RECONNECT")

    --服务器牌前后两次发来的顺序并不一致，注意每次收到牌都把所有牌重新画一次
    if  FIRSTSENDCARD then

        USED_CARDS = {}

        local userCards = {}

        LIANGCARDNUM = 0 
        MY_CARDS = {}
        print("=====pack.users=====",pack.users)
        print("=====isOpenControl=====",isOpenControl)
        -- if  pack.users and next(pack.users) and isOpenControl == true then
        if  pack.users and next(pack.users)  then
            for i,data in ipairs(pack.users) do
                userCards[data.seat_id] = data.cards
                dump(data.cards,"玩家的牌！！！")
                for _, card in ipairs(data.cards) do
                    table.insert(USED_CARDS, card) 
                end
            end

            local myControlCards = userCards[MY_SEAT_ID]
            local tempIndex = 1
            for _,card in ipairs(myControlCards) do
                if tempIndex == 4 and  USER_INFO.is_qipai == 0 then
                    -- card = 0
                    -- table.insert(MY_CARDS,0)
                else
                    table.insert(MY_CARDS,card)
                    LIANGCARDNUM = LIANGCARDNUM + 1
                end
                tempIndex = tempIndex + 1
                -- if  card ~= 0 then
                --     LIANGCARDNUM = LIANGCARDNUM + 1
                -- end
            end  
            for _,uid in ipairs(GAME_PARTICIPANTS) do
                local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
   
                if playerType and playerType ~= CARD_PLAYERTYPE_MY then    
                    local seat_id =  NIUNIU_SEAT_TABLE[uid]
                    local cards = userCards[seat_id]
                    GamePlaneOperator:showDealCardsAnimation(playerType,cards,4,true)
                end
            end

        else

            for i,card in ipairs(pack.cards) do
                table.insert(MY_CARDS,card)  
                if  card ~= 0 then
                    LIANGCARDNUM = LIANGCARDNUM + 1
                end 
            end

        end
        local seatId = NIUNIU_SEAT_TABLE[USER_INFO["uid"]]
        Lottery:dealCards(seatId, MY_CARDS)
        GamePlaneOperator:showCards(CARD_PLAYERTYPE_MY,MY_CARDS,FIRSTSENDCARD,pack.isRelogin)
        
        FIRSTSENDCARD = false
    else
        ------------------------------------
        MY_CARDS = {}

        for i,card in ipairs(pack.cards) do
            table.insert(MY_CARDS,card)
        end
        -----------------------------------     
        print("========9999999999999999999999999========")
        print("========9999999999999999999999999========")
        print("========9999999999999999999999999========")
        print("========9999999999999999999999999========")

        print("========9999999999999999999999999========")
        print("========9999999999999999999999999========")
        print("========9999999999999999999999999========")
        print("========9999999999999999999999999========")
        print("========9999999999999999999999999========")
        print("========9999999999999999999999999========")
        local seatId = NIUNIU_SEAT_TABLE[USER_INFO["uid"]]
        Lottery:dealCards(seatId, MY_CARDS)
        GamePlaneOperator:showCards(CARD_PLAYERTYPE_MY,pack.cards,FIRSTSENDCARD , nil , nil , card_state)

    end

end

--出牌相关
--广播出牌阶段开始
function NiuNiuReceiveHandle:SVR_PLAY_CARD_BROADCAST(pack , state)

    dump(pack, "-----广播开始选牌-----")

    if not pack then return end
    if not pack.time then return end
    if pack.time == nil then return end
    if tonumber(pack.time) <= 0 then return end
    print ("M_WAIT" , M_WAIT)
    if M_WAIT then 
        return 
    end

    --显示阶段信息
    GAME_STATE = GAME_STATUS_OUTCARD --棋牌进行中

    GamePlaneOperator:startTimer(pack.time,"选牌阶段")
    GamePlaneOperator:turnCards()
 
    local time = pack.time or 5
    -- local cardEndIndex = 5

    Lottery:stopStageProgress("bet")
    Lottery:remainStageProgress(time,"checkCard")
    
    print("=1617===GamePlaneOperator:startTimer(pack.time,弃牌阶段)=====")
    print("=====玩家开始弃牌====")
    print("=====玩家开始弃牌====")
    print("=====玩家开始弃牌====")
    print("=====玩家开始弃牌====")
    print("=====玩家开始弃牌====")


    -- if state then 
    --     local playerType = NIUNIU_PLAYERTYPE_TABLE[USER_INFO["uid"]]
    --     print ("playerType" , playerType)
    --     dump(playerType , pack.cards)
    --     if  playerType  then
    --         GamePlaneOperator:showCards(playerType , pack.cards , true , nil , true)

    --         GamePlaneOperator:showDealCardsAnimation(playerType,,4 , true)
    --     end
    -- end

    local uid = USER_INFO["uid"]
    local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
    local card_data = GamePlaneOperator:GetAllNode(playerType)

    local  sepical_value = self:CheckSpeicalValue(card_data)
    --特殊牌型
    if 1 == sepical_value then 
        GamePlaneOperator:ShowShuiYuButton("水鱼" , 6)
    elseif 2 == sepical_value then 
        GamePlaneOperator:ShowShuiYuButton("水鱼天下" , 5)
    else
        self:showChooseCard()
        for k , v in pairs(card_data) do 
            self:add_eventlistener( v.font_pai_,k)
        end 
    end

end

function NiuNiuReceiveHandle:CheckSpeicalValue( card_data )
    -- body
    local value_1 = -1
    local value_2 = -1

    for k , v in pairs(card_data) do 
        local temp_value = v.cardUint_ % 16
        value_1 = temp_value
        break
    end

    print ("CheckSpeicalValue" , value_1)

    for key , value in pairs(card_data) do 
        local temp_value = value.cardUint_ % 16
        if temp_value ~= value_1 then 
            value_2 = temp_value
            break
        end
    end

    local value_1_time = 0
    local value_2_time = 0
    for key , value in pairs(card_data) do 
        local temp_value = value.cardUint_ % 16
        if temp_value == value_1 then 
            value_1_time = value_1_time + 1
        end
        if temp_value == value_2 then 
            value_2_time = value_2_time + 1
        end
    end

    if value_1_time == 4 then 
        return 2 --2.代表水鱼天下
    end 

    if value_1_time == 2 and value_2_time == 2 then 
        return 1 --1.代表水鱼
    end




end

function NiuNiuReceiveHandle:add_eventlistener( card_image,_index )

        print("=========add_eventlistener========",GAME_STATE)
        print("=========add_eventlistener========",GAME_STATE)
        print("=========add_eventlistener========",GAME_STATE)
        --add by zzy 2019-5-25 begain
        if GAME_STATE ~= GAME_STATUS_OUTCARD then
            return 
        end
        if not card_image then return end
        --add by zzy 2019-5-25 begain
        print("=======999999999999999999999999=========")

        local a=card_image:getPosition()
        local touchBeginPoint = nil  

        local function onTouchBegan(touch, event)  
            local target = event:getCurrentTarget()  --获取事件绑定的目标
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0,0, s.width, s.height) --设置点击的区域
            if cc.rectContainsPoint(rect, locationInNode) then
                local location = touch:getLocation()  
                touchBeginPoint = {x = location.x, y = location.y}  
                return true  
            end  
        end  
  
        local function onTouchMoved(touch, event)  
            --changed by zzy 2019-5-25 begain  
            --注释掉

            -- local location = touch:getLocation()  
            -- if touchBeginPoint then  
            --     local cx =card_image:getPosition().x
            --     local cy=card_image:getPosition().y                
            --     card_image:setPosition(cc.p(cx + location.x - touchBeginPoint.x,  
            --                            cy + location.y - touchBeginPoint.y))
            --     touchBeginPoint = {x = location.x, y = location.y}  
            -- end   

            --changed by zzy 2019-5-25 end
        end  
  
        local function onTouchEnded(touch, event)  
            --changed by zzy 2019-5-25 begain  此处仅仅只是将所选择的图片往上罢了，如果再此之前选择过其他的弃牌，则其他弃牌位置复原
            print("=======888888888888888888888888=========")
            print("=======888888888888888888888888=========")
            print("=======888888888888888888888888=========")
            print("=======888888888888888888888888=========")
            print("=======888888888888888888888888=========")
            if GAME_STATE == GAME_STATUS_STOP then
                return 
            end
            if GAME_STATE ~= GAME_STATUS_OUTCARD then
                return 
            end
            local uid = USER_INFO["uid"]
            local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
            local tempAllCardNodes = GamePlaneOperator:GetAllNode(playerType)

            for k , v in pairs(self.choose_card) do 
                if v == tempAllCardNodes[_index].cardUint_ then 
                    return 
                end 
            end
            self:ShowCardColor(tempAllCardNodes, _index)
        
        end  
  
        local listener = cc.EventListenerTouchOneByOne:create()  --依次一个一个的执行
        listener:setSwallowTouches(true)  --当两个碰撞体重叠的时候，只检测到最上层的那一个
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )  
        listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )  
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )  
        local eventDispatcher = card_image:getEventDispatcher()  
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, card_image)

end

function NiuNiuReceiveHandle:ShowCardColor( tempAllCardNodes, _index )

    for k , v in pairs(tempAllCardNodes) do 
        if k == _index then
            self:addCard(v.cardUint_)
            self.currentcardCount = self.currentcardCount + 1
        end 
        v.font_pai_:setOpacity(255)
    end

    for k , v in pairs(tempAllCardNodes) do 
        for key , value in pairs(self.choose_card) do 
            if v.cardUint_ == value then 
                v.font_pai_:setOpacity(100)
                break
            end
        end
    end

end

--所选牌值加入选牌框
function NiuNiuReceiveHandle:addCard(value)
  if self.currentcardCount > 2 then 
        self.currentcardCount = 1
    end
    self.choose_card[self.currentcardCount] = value


    local s = SCENENOW["scene"]:getChildByName("testConfigScene"):getChildByName("Image_1")
    print ("addCard" , self.currentcardCount)
    local btn_card = s:getChildByName("card_layout".. self.currentcardCount)
    local img_card = btn_card:getChildByName("img_card")
    if img_card then
        img_card:removeSelf()
    end

    local card = require(TpackageName..".PokerCard").new()
    card:setAnchorPoint(cc.p(0.5, 0.5))
    card:setPosition(cc.p(120 , 10))
    card:addTo(btn_card)
    card:showFront()
    card:setCard(value)
    card:setName("img_card")

    print ("NiuNiuReceiveHandle_addCard" , #self.choose_card)
    if #self.choose_card == 2 then 
       GamePlaneOperator:SetHeadValue(self.choose_card , self.RemoveChooseCard)
    end
end

function NiuNiuReceiveHandle:RemoveChooseCard( choose_card )
    -- body

    local uid = USER_INFO["uid"]
    local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
    local tempAllCardNodes = GamePlaneOperator:GetAllNode(playerType)

    local second_value = {}
    for k , v in pairs(tempAllCardNodes) do
        local state = false
        for key,value in pairs(choose_card) do
            if value == v.cardUint_ then 
                state = not state
                break
            end
        end
        if not state then 
            table.insert(second_value , v.cardUint_)
        end
    end

    local cards = {}
    for k , v in ipairs(choose_card) do 
        table.insert(cards , v)
    end

    for key , value in ipairs(second_value) do 
        table.insert(cards , value)
    end
    print ("RemoveChooseCard")

    GamePlaneOperator:showCards(CARD_PLAYERTYPE_MY , cards , true , nil , true)
    local scene = SCENENOW["scene"]:getChildByName("testConfigScene")
    if scene then 
        scene:removeFromParent()
        scene = nil
    end
    
    GamePlaneOperator:showStageTxt("等待其他玩家操作...")
   

end

function NiuNiuReceiveHandle:showChooseCard()

    self.currentcardCount = 1
    self.choose_card = {}

    local scene = SCENENOW["scene"]:getChildByName("testConfigScene")
    if scene then 
        scene:removeFromParent()
        scene = nil
    end

    local layout = cc.CSLoader:createNode(TpackageName .. "/csb/chooseTestCard.csb")
    layout:setName("testConfigScene")
    layout:addTo(SCENENOW["scene"],9999)
    layout:setScale(1280/1920)
    local Image_1 = layout:getChildByName("Image_1")
    Image_1:setPosition(cc.p(Image_1:getPositionX() , Image_1:getPositionY() + 160))
    Image_1:setContentSize(cc.size(700, 500))

    local mask = layout:getChildByName("mask"):setVisible(false)
    layout:getChildByName("card_plane"):setVisible(false)
    for i = 1 , 2 do 

        local card_layout = ccui.Layout:create()
        card_layout:setAnchorPoint(cc.p(0 , 0))
        card_layout:setContentSize(cc.size(250 , 330))
        card_layout:setName("card_layout" .. i)
        if 2 == i then 
            card_layout:setPosition(i * 230 , 0)
        end
        card_layout:addTo(Image_1)


        local card = require(TpackageName..".PokerCard").new()
        card:setAnchorPoint(cc.p(0.5, 0.5))
        card:setPosition(cc.p(120 , 10))
        card:addTo(card_layout)
        card:showBack()
        card:setName("img_card")

    end

    if USER_INFO["uid"] == BANKER_UID then 
        GamePlaneOperator:showControlButtons(6)
    else
        GamePlaneOperator:showControlButtons(7)
    end

end


--玩家丢弃自己的牌
function NiuNiuReceiveHandle:SVR_USER_PLAYED_CARDS_BROADCAST(pack)
    local a = 1
    if a == 1 then return end


    dump(pack, "-----广播玩家时间到了丢弃自己的牌---6005--")

    dump(pack.card , "------时间到了玩家自己丢弃的牌--------")
    -- ---用于记录所有玩家对应出过的牌，牌的大小
    -- NIUNIUKIND[pack.uid] =  pack.kind
    -- NIUNIU_OUTCARDS[pack.uid] = pack.cards

    GAME_STATE = GAME_STATUS_OUTCARD 
        
    local uid = pack.uid
    local seatId = NIUNIU_SEAT_TABLE[uid]
    local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
    local cardEndIndex = 4
    if  uid == USER_INFO["uid"] then

    --     --清除搓牌
        require(TpackageName .. ".LayerShuffling"):removeScene()
        GamePlaneOperator:showControlButtons(5,false)
        GamePlaneOperator:showStageTxt("等待其他玩家出牌...")

        if  HAS_OPEN_CARD_UIDS[uid] ~= true then
            HAS_OPEN_CARD_UIDS[uid] = true
        end

       
        local put_card = pack.card 
     
        local uid = USER_INFO["uid"]
        local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
        local card_data = GamePlaneOperator:GetAllNode(playerType)
        local card_value = {}
        for k , v in pairs(card_data) do 
            print ("SVR_USER_PLAYED_CARDS_BROADCAST" , v.cardUint_)
            v.font_pai_:setPositionY(0)
            if tonumber(v.cardUint_) == tonumber(put_card) then
                v.font_pai_:setPositionY(50)
                table.insert(card_value , v)
            else
                table.insert(card_value , v)
            end  
            print("======node 牌的高度======",v:getPositionY())   
        end
        GamePlaneOperator:SetAllNode(playerType , card_value)

        GamePlaneOperator:outCard(playerType)

    else      

    end


end

--1043玩家开始摊牌
function NiuNiuReceiveHandle:SVR_OPEN_CARDS_BROADCAST(pack)

    local totalOpenCardTime = pack.openCardTime

    GamePlaneOperator:showStageTxt("比牌中...")
    -- Lottery:shieldBet()
    Lottery:remainStageProgress(totalOpenCardTime,"compare")
end

---------------------------------------------------------------------------------------------------------------------------------------------
--扣除台费 4800
function NiuNiuReceiveHandle:SVR_CHIP_CHANGE_BROADCAST(pack)
     
    local  change_chip = 0
    for _,data in pairs(pack.userinfo) do

        local uid = data.uid
        local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
        local oriChip = NIUNIU_USERINFO_TABLE[uid].coins 
        local chip = oriChip + data.change_chip
        NIUNIU_USERINFO_TABLE[uid].coins  = chip
        print("=====pppppppppp==扣除台费==")
        GamePlaneOperator:setCoin(playerType,chip)

        if  uid == USER_INFO["uid"] then
            --GamePlaneOperator:showTaiFeiTips(data.change_chip)
        end

    end
end

--充值后广播 111
function NiuNiuReceiveHandle:SVR_CHARGE_BROADCAST(pack)
    --  print("===pppppppppp=2==充值后广播=")
    local uid = pack.uid
    local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]

    if  NIUNIU_USERINFO_TABLE[uid] and  playerType then
        local oriChip = NIUNIU_USERINFO_TABLE[uid].coins 
        local chip = oriChip + pack.chargeCoins/100
        NIUNIU_USERINFO_TABLE[uid].coins = chip
        GamePlaneOperator:setCoin(playerType,chip)
    end

end



--结算
function NiuNiuReceiveHandle:SVR_SETTLEMENT_BROADCAST(pack)

    dump(pack, "-----牛牛结算6008-----")
    print("-----牛牛结算6008-----")
    print("-----牛牛结算6008-----")
    print("-----牛牛结算6008-----")
    print("-----牛牛结算6008-----")

    GamePlaneOperator:setVisible(false)
    GamePlaneOperator:SetLoadValue( "杀" , "走" )
    dump(pack.user_datas)
    --by zzy 2019-5-27
    local uid = USER_INFO["uid"]
    local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]

    --根据玩家index获取玩家自己桌面牌得node
    local tempAllCardNodes = GamePlaneOperator:GetAllNode(playerType)

    -- for k,v in pairs(tempAllCardNodes) do
    --     v.font_pai_:setPositionY(0)
    -- end 
    --end
    -- local banker_type = NIUNIU_PLAYERTYPE_TABLE[BANKER_UID]
    -- local card_data = GamePlaneOperator:GetAllNode(banker_type)
    -- local banker_data = {}
    -- if card_data then
    --     for k , v in pairs(card_data) do 
    --         print("===v.cardUint_==",v.cardUint_)
    --         table.insert(banker_data, v.cardUint_)  
    --     end
    -- end

    -- for k , v in pairs(banker_data) do 
    --     print (k , v ,"==v.cardUint_=_SVR_SETTLEMENT_BROADCAST")
    -- end

    -- GamePlaneOperator:showDealCardsAnimation(banker_type, banker_data, 4, true)


    function getValue(card)
        local value = bit.band(card, 0x0F)
        if value == 1 then
            value = 14
        end
        return value
    end

    FIRSTSENDCARD = true

    RELOGIN_FLAG = false


    --add by zzy 2019-5-27 begain 牌局结束，将其他玩家的牌显示出来
    local tbWin = {}
    local tempChangedMoney = {}
    if pack.playerCount <= 0 then return print("玩家个数返回 error！！！") end
    for i=1,pack.playerCount do
        local uid = pack.user_datas[i].uid
        -- if uid == USER_INFO.uid then 
        if uid == BANKER_UID then 
            local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
            local card_data = GamePlaneOperator:GetAllNode(playerType)
            local card_value = pack.user_datas[i].cards
            for k , v in pairs(card_value) do 
                print (k , v , "BANKER_UID_tempChangedMoney")
            end
            GamePlaneOperator:showDealCardsAnimation(playerType,card_value,4,true)
        end
            -- local outCard_index = pack.user_datas[i].indexCard

            --=================changed by zzy 2019-7-6================
            -- for k,v in pairs(card_data) do
            --     v:setCard(card_value[k])
            --     v:setPositionY(0)
            --     if k == outCard_index and uid == USER_INFO.uid then
            --         v:setPositionY(50)
            --         v.font_pai_:setColor(cc.c3b(130,130,130))
            --     elseif k == outCard_index then
            --         v:setPositionY(25)
            --         v.font_pai_:setColor(cc.c3b(130,130,130))
            --     end
            -- end
            --=================changed by zzy 2019-7-6================


            --  --获取原来所有牌的数值
            -- local  tempCardData = {}

            -- print("=======其他人的牌的集合=======")
            -- print(pack.user_datas[i].money)
            -- if card_data then
            --     for k , v in pairs(card_data) do 
            --         print("===v.cardUint_==",v.cardUint_)
            --         table.insert(tempCardData,v.cardUint_)  
            --         v:removeSelf()
            --         v = nil 
            --         -- v:setPositionY(30) 
            --     end
            -- end
            -- local cardIndex = 0
            -- for k,v in pairs(tempCardData) do
            --     local tempN = 0
            --     for k1,v1 in pairs(card_value) do
            --         if v ~= v1 then
            --             tempN = tempN + 1
            --         end
            --     end
            --     if tempN == 3 then
            --         cardIndex = k
            --         break
            --     end
            -- end

            -- -- table.insert(card_value,3)


            -- GamePlaneOperator:showDealCardsAnimation(playerType,tempCardData,4,false,nil,cardIndex)
        -- end
   
        print("======22222222222222222=====")
        print("cardType==",pack.user_datas[i].turn_money)


        local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
        tbWin[uid] = pack.user_datas[i].money / 100
        NIUNIU_USERINFO_TABLE[uid].money = pack.user_datas[i].money / 100

        --总结算再加一个字段
        NIUNIU_USERINFO_TABLE[uid].MatchScore = pack.user_datas[i].MatchScore / 100

        -- tempChangedMoney[uid] = {pack.user_datas[i].turn_money,pack.user_datas[i].turn_money2}
        tempChangedMoney[uid] = pack.user_datas[i].turn_money

        -- GamePlaneOperator:showCoinFlyAnimation(pack.banker_uid,tbWin,"game")

        GamePlaneOperator:showCoinFlyAnimation(BANKER_UID,tbWin,tempChangedMoney,"game")
        print("cardType==",pack.user_datas[i].cardType,pack.user_datas[i].cardType2)

        -- print("===pppppppppp=3===",pack.user_datas[i].money,playerType)
        -- GamePlaneOperator:setCoin(playerType,pack.user_datas[i].money)

        -- local node  = cc.Node:create()
        -- SCENENOW["scene"]:addChild(node)
        -- node:stopAllActions()
        -- local dt = cc.DelayTime:create(0.4*i)
        -- local function func()
        --     GamePlaneOperator:showCardKind(playerType,pack.user_datas[i].cardType,pack.user_datas[i].cardType2)
        --     node:removeFromParent()
        -- end
        -- local funcTime = cc.CallFunc:create(func)
        -- local seq = cc.Sequence:create(dt,funcTime)
        -- node:runAction(seq)
    end

    -- GamePlaneOperator:outCard(playerType)

    --add by zzy end
    Lottery:remainStageProgress(0,"showResult")
    -- -- BONUS_POOL_COINS  =  pack.bonusPool  --更新奖池

    GAME_STATE = GAME_STATUS_STOP --棋牌结束

    -- if  MY_SEAT_ID and MY_SEAT_ID < 0 then   --当自己没有坐下的时候才显示坐下
    --     GamePlaneOperator:showSitDownButton(true)
    -- end

    for uid,_ in pairs(USERS_READY_STATE) do  --重置所有玩家的准备状态
        USERS_READY_STATE[uid] = 0  
    end
    
    -- local tbWin = {}

    local showCardDelay = 0.5

    local delaySettleTime = 0 -- 0.5 * (#pack.userinfo) + 0.5
    
    --庄家分数
    -- local BankerPlayerType = NIUNIU_PLAYERTYPE_TABLE[pack.banker_uid]
    -- tbWin[pack.banker_uid] = pack.banker_win_chip
    -- NIUNIU_USERINFO_TABLE[pack.banker_uid].coins = pack.banker_chips - initialChip

    -- --闲家分数
    -- for i,data in pairs(pack.userinfo) do

    --     local playerType = NIUNIU_PLAYERTYPE_TABLE[data.uid]
    --     tbWin[data.uid] = data.win_chip
    --     NIUNIU_USERINFO_TABLE[data.uid].coins = data.chips - initialChip

    -- end

    GamePlaneOperator:stopTimer()
    GamePlaneOperator:clearGameDatas(1)

    local settlementDelay = 3 

    -- if  GAME_CONFIG["买牛"] == true then
    --     settlementDelay = 5
    -- end

    -- HAS_OPEN_CARD_UIDS = {}

    --延迟2秒去掉显示分数
    -- local tempNode = cc.Node:create()
    -- tempNode:addTo(SCENENOW["scene"])
    -- local function CallFun1()
    --     GamePlaneOperator:clearGameDatas(2)
    -- end
    -- local function CallFun2()
    --     tempNode:stopAllActions()
    --     tempNode:removeFromParent()
    -- end 
    -- local dt = cc.DelayTime:create(2) 
    -- local funcCallFun1 = cc.CallFunc:create(CallFun1)
    -- local funcCallFun2 = cc.CallFunc:create(CallFun2)
    -- local seq = cc.Sequence:create(dt,CallFun1,CallFun2)
    -- tempNode:runAction(seq)


    -- --先亮牌，延迟两秒后结算
    SCENENOW["scene"]:performWithDelay(function()

        -- GamePlaneOperator:showCoinFlyAnimation(pack.banker_uid,tbWin,"game")

        Lottery:delayCallShowBetResult()

        Lottery:remainStageProgress(0,"wait")


        SCENENOW["scene"]:performWithDelay(function()
                 
            if SCENENOW["name"] == run_scene_name then
                    
                if  MY_SEAT_ID >= 0 and RELATIVE_SEAT_ID ~= MY_SEAT_ID  then --自己已经坐下，但是是在游戏期间坐下的
                    RELATIVE_SEAT_ID = MY_SEAT_ID
                    -- GamePlaneOperator:clearGameDatas(1)
                    GamePlaneOperator:clearGameDatas(2)
                    NiuNiuUtils:relocatePlayer()
                end

                -- GamePlaneOperator:clearGameDatas(2)
                SCENENOW["scene"]:initData("clearGameData")
                
                if  GAME_ROUND < GAME_TOTAL_ROUND then
                        
                    -- GamePlaneOperator:showStageTxt("等待游戏开始...")
                    --我不在准备状态且坐下了
                    if  USERS_READY_STATE[USER_INFO["uid"]] and USERS_READY_STATE[USER_INFO["uid"]] ~= 1 and MY_SEAT_ID >= 0 then
                        -- GamePlaneOperator:showControlButtons(1)
                    end
                    
                    SCENENOW["scene"]:showShareButton(true)

                else

                    GamePlaneOperator:showStageTxt("")

                    local GameResult = SCENENOW["scene"]:getChildByName("gameresultScene")
                    if  GameResult then
                        GameResult:setVisible(true)
                    end
                    
                end

                if GAME_ROUND >= GAME_TOTAL_ROUND then
                    -- GamePlaneOperator:showCheckResultButton(true)
                end

            end

        end,settlementDelay)

    end,delaySettleTime)


end

--牛牛组局排行榜 5100
function NiuNiuReceiveHandle:SVR_GROUP_BILLBOARD(pack)

    dump(pack, "-----牛牛组局排行榜5100-----")
    dump(GAME_ROUND, "-----牛牛组局排行榜GAME_ROUND-----")

    GamePlaneOperator:showStageTxt("")
    NiuNiuUtils:showResult(pack)
    
    HAS_RECEIVE_GROUP_RESULT = true
    
    SCENENOW["scene"]:showShareButton(false)
    GamePlaneOperator:showCheckResultButton(true)

end


--------------------------------------周边功能-----------------------------------------
--组局解散相关
--没有此房间，解散房间失败
function NiuNiuReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)

    --dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")
    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")
end

--根据老赵之前的改动，这边相应的变化
function NiuNiuReceiveHandle:getUserInfoLstToDisband(applyId)
    dump(NIUNIU_USERINFO_TABLE, "getUserInfoLstToDisband")
    local userLst = NIUNIU_USERINFO_TABLE or {}
   
    local result = {} 
    for k, v in pairs( userLst ) do
        local tmp = {}
        tmp.state = v.uid == applyId and 3 or 2
        tmp.userId = v.uid
        tmp.userName = v.nickName
        tmp.userUrl = v.portrait or v.icon_url

        table.insert(result, tmp)
    end
    dump(result,"根据老赵之前的改动，这边相应的变化")
    return result
end

function NiuNiuReceiveHandle:processRevcDisbandInfo( info )
    if info.agreeNum == 0 then
        print("===11111===")
        if SCENENOW["scene"].roomCommonLayer.disbandLayer == nil then
            print("22222")
            local playerLst = self:getUserInfoLstToDisband(info.applyId)
            SCENENOW["scene"].roomCommonLayer:processRevcRequestDisband(playerLst,info.applyTime)
        else
            dump(SCENENOW["scene"].roomCommonLayer.disbandLayer)
            SCENENOW["scene"].roomCommonLayer.disbandLayer = nil
            local playerLst = self:getUserInfoLstToDisband(info.applyId)
            SCENENOW["scene"].roomCommonLayer:processRevcRequestDisband(playerLst,info.applyTime)
        end
    else
        print("===33333===")
        if SCENENOW["scene"].roomCommonLayer.disbandLayer == nil then
            print("===44444===")
            local playerLst = self:getUserInfoLstToDisband(info.applyId)
            SCENENOW["scene"].roomCommonLayer:processRevcRequestDisband(playerLst,info.applyTime)
        end
        for i, v in ipairs( info.agreeMember_arr ) do
            SCENENOW["scene"].roomCommonLayer:exchangeStateBySel(v, 1)
        end
    end
end


--广播当前组局解散情况
function NiuNiuReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)

    dump(pack, "-----广播当前组局解散情况-----")
    dump(NIUNIU_USERINFO_TABLE, "-----广播当前房间情况-----")
    self:processRevcDisbandInfo(pack)
    do return end
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
        local applyer_info = NIUNIU_USERINFO_TABLE[applyId]
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
        print("假如申请者不是自己，添加自己的选择情况")
        print("假如申请者不是自己，添加自己的选择情况")
        --假如申请者不是自己，添加自己的选择情况
        if agreeNum > 0 then
            for k,v in pairs(agreeMember_arr) do
                if v == USER_INFO["uid"] then
                    isMyAgree = 1
                    print("=====我的选择==5===",isMyAgree)
                    break
                end
            end
        end
        
        local player_table = {}
        player_table["playerName"] = "我"
        print("=====我的选择==3===",isMyAgree)
        if isMyAgree == 1 then
            player_table["state"] = "同意"
        else
            player_table["state"] = "等待选择"
        end

        player_table["icon"] = USER_INFO["icon_url"]

        table.insert(disband_table, player_table)

    end
    print("=====我的选择==2===",isMyAgree)
    --显示其他人情况
    for k,v in pairs(NIUNIU_USERINFO_TABLE) do
        dump(v, "-----显示其他人情况-----")
        local uid = v.uid
        --排除掉申请者，申请者不需要显示到这里
        if uid ~= applyId and uid ~= USER_INFO["uid"] then
            print("显示不是申请解散的其他人==id==",uid,USER_INFO["uid"])
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
            print("==isAgree==",isAgree)
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
        print("=====同意解散房间=====")
        NiuNiuSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(value)
    end
    print("=====我的选择=====",isMyAgree)
    if applyId == USER_INFO["uid"] then
        --假如申请者是自己，则直接显示其他用户的选择情况
        require("hall.GameTips"):showDisbandNewTips("提示", "niuniu_disbandGroup_success", 4, disband_table)
    else
        --申请者不是自己，根据自己的同意情况进行界面显示
        if isMyAgree == 1 then
            print("=====我的选择==8===",isMyAgree)
            require("hall.GameTips"):showDisbandNewTips("提示", "niuniu_disbandGroup_success", 4, disband_table)
        else
            require("hall.GameTips"):showDisbandNewTips("提示", "new_request_disbandGroup", 1, disband_table,agree_disband)
        end
    end
end


--广播桌子用户请求解散组局
function NiuNiuReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

    --dump(pack, "-----广播桌子用户请求解散组局-----")

    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")

end

--广播桌子用户成功解散组局
function NiuNiuReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

    dump(pack, "-----广播桌子用户成功解散组局-----")

    bm.isDisbandSuccess = true

    if isGoldGame == 0 then
        require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
    end

    -- require("hall.GameTips"):showDisbandTips("解散房间成功","ddz_disbandGroup_success",3)

end

--广播桌子用户解散组局 ，解散组局失败
function NiuNiuReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

    --dump(pack, "-----广播桌子用户解散组局 ，解散组局失败-----")

    local rejectId = pack.rejectId
    if rejectId == USER_INFO["uid"] then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
    else
        local nickName = NIUNIU_USERINFO_TABLE[rejectId].nick or "路人甲"
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2,  nickName.. "拒绝解散房间")
    end

end

--聊天
function NiuNiuReceiveHandle:SVR_MSG_FACE(pack)
    print("=======NiuNiuReceiveHandle:SVR_MSG_FACE======")
    local s= SCENENOW["scene"]:getChildByName("faceUI")

    local sex = 1

    if NIUNIU_USERINFO_TABLE[pack.uid] then
       sex = NIUNIU_USERINFO_TABLE[pack.uid].sex or 0
    end

    local isLeft = false

    local node_head = PLAYER_HEADS_TABLE[pack.uid]
    if  tonumber(sex) >= 0 and node_head then
        s:showGetFace(pack.uid, pack.type, tonumber(sex), node_head, false)
    end

end
-----------------------------------------------------------------------------------------------------------------------------
function NiuNiuReceiveHandle:showTextMessage(pack)

    local s= SCENENOW["scene"]:getChildByName("faceUI")
    
    local sex = 1

    if NIUNIU_USERINFO_TABLE[pack.uid] then
       sex = NIUNIU_USERINFO_TABLE[pack.uid].sex or 0
    end

    local node_head = PLAYER_HEADS_TABLE[pack.uid]

    s:showGetText(pack.uid,pack.textMessage,tonumber(sex),node_head, false)  

end


function NiuNiuReceiveHandle:showExpression(msg)

    local uid_from = tonumber(msg["uid_from"])
    local uid_to = tonumber(msg["uid_to"])
    local expressionType = tonumber(msg["expressionType"]) or 1

    --屏蔽和围观玩家有关的互动表情
    if NIUNIU_SEAT_TABLE[uid_from] < 0 or NIUNIU_SEAT_TABLE[uid_to] < 0 then
        return
    end
    ---------------------------------不同游戏需修改的部分----------------------------
    -- --通过UID获取seat_id
    -- local seat_id_from = USERID2SEAT[uid_from] or 2
    -- local seat_id_to =  USERID2SEAT[seat_id_to] or 0

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


--接收服务器发来的距离数据
function NiuNiuReceiveHandle:SERVER_CMD_FORWARD_MESSAGE(pack)

    dump(pack,"-------距离数据---------")   
    local msgList = pack.msgList
    --存放距离数据的数组

    for k,v in pairs(msgList) do
        if v and v ~= "" then
            local msg = json.decode(v)
            if  msg and msg.uid then
                dump(msg,"更新对应玩家的数据")
                require("hall.view.userInfoView.userInfoView"):upDateUserInfo(msg.uid,msg)
            end
        end
    end

end

--接收服务器返回的组局信息
function NiuNiuReceiveHandle:SERVER_CMD_MESSAGE(pack)
    print("=======接收服务器返回的组局信息==表情發送====")
    print("=======接收服务器返回的组局信息==表情發送====")
    print("=======接收服务器返回的组局信息==表情發送====")
    -- if bm.isInGame == false then
    --     return
    -- end
    
    local msg = json.decode(pack.msg)
    --dump(msg, "-----NiuNiuReceiveHandle 接收服务器返回的组局信息-----")
    if msg ~= nil then
        local msgType = msg.msgType
        if msgType ~= nil and msgType ~= "" then

            if msgType == "expression" then   --表情
                self:showExpression(msg)
            elseif  msgType == "text" then   --文字聊天
                self:showTextMessage(msg)
            end

            if device.platform == "ios" then

                if msgType == "voice" then
                    --dump("voice", "-----接收服务器返回的组局信息-----")
                    --require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)
                    -- require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                     require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

                     --通知本地播放录音
                     local arr = {}
                     arr["url"] = msg.url
                     cct.getDateForApp("playVoice", arr, "V")

                elseif msgType == "video" then
                    --dump("video", "-----接收服务器返回的组局信息-----")
                    require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)
                    local arr = {}
                    arr["url"] = msg.url
                    cct.getDateForApp("playVideo", arr, "V")

                end

            else

                if msgType == "voice" then
                    --dump("voice", "-----接收服务器返回的组局信息-----")
                    require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)
                    -- require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                    -- require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

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

--告诉庄家做啥操作
function NiuNiuReceiveHandle:SVR_ZHUANG_OPT(pack)

    dump(pack.head_arr , pack.final_arr , "SVR_ZHUANG_OPT")
    

    if USER_INFO["uid"] == BANKER_UID or USER_INFO["uid"] == pack.user_id then 
        GamePlaneOperator:startTimer(pack.time,"比牌阶段")
    end

    if USER_INFO["uid"] == BANKER_UID then 
        GamePlaneOperator:SetBtnTxt(pack.card_type)
    end

     local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.user_id]
     --闲家撒扑 亮牌.所有玩家都能看见的
        if pack.card_type == 1 then 
            --庄家能看到闲家的牌
            local cards = {}
           
            for k , v in pairs(pack.head_arr) do 
                table.insert(cards , v)
            end
            for k , v in pairs(pack.final_arr) do 
                table.insert(cards , v)
            end

            GamePlaneOperator:showDealCardsAnimation(playerType,cards,4,true , nil , nil , true)


        -- if pack.card_type == 1 then
        --     print ("闲家撒扑,庄家显示杀,走")

        -- end

        -- if pack.card_type == 2 then 
        --     print ("闲家密牌,庄家显示开,认")
        -- end 

        -- if pack.card_type == 4 then 
        --     print ("闲家密陪,庄家盛")
        end

        --闲家密牌.显示牌型
        print ("pack.card_type" , pack.card_type)
        if pack.card_type == 2 then 

            GamePlaneOperator:showCardKind(playerType , "密牌")

        end

 
end

--广播庄杀 庄走.牌类型
function NiuNiuReceiveHandle:SERVER_BROADCAST_XIANJIA_OPT( pack )
    -- body
    dump("SERVER_BROADCAST_XIANJIA_OPT")
    dump(pack.user_id)
    if USER_INFO["uid"] == pack.user_id then 
        GamePlaneOperator:SetBtnJia()
    end

    --庄杀
    if pack.value == 1 then 
        dump("SERVER_BROADCAST_XIANJIA_OPT")
        dump(NIUNIU_PLAYERTYPE_TABLE)
        local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.user_id]
        print ("SERVER_BROADCAST_XIANJIA_OPT_playerType" , playerType)
        GamePlaneOperator:showCardKind(playerType , "庄杀")  --显示盖牌文字

    end

    if pack.value == 2 then 
           local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.user_id]
        print ("SERVER_BROADCAST_XIANJIA_OPT_playerType" , playerType)
        GamePlaneOperator:showCardKind(playerType , "庄走")  --显示盖牌文字
    end

end

--广播闲信.闲反 牌类型
function NiuNiuReceiveHandle:SERVER_BROADCAST_XIANTYPE( pack )
    -- body
    dump("SERVER_BROADCAST_XIANTYPE")
    dump(pack.user_id)

    --闲信
    print ("SERVER_BROADCAST_XIANTYPE_pack.value" , pack.value , pack.zhuang_value)
    local card_value1 = 1 == pack.zhuang_value and "庄杀" or "庄走"
    local card_value2 = 1 == pack.value and "闲信" or "闲反"
    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.user_id]
    GamePlaneOperator:showCardKind(playerType , card_value1 , card_value2)

end

function NiuNiuReceiveHandle:SERVER_BROADCAST_CHOSECARD( pack )

    print ("SERVER_BROADCAST_CHOSECARD")
    GamePlaneOperator:SetChooseBtn(false)
    local choose_card = {pack.head_value1 , pack.head_value2}
    self:RemoveChooseCard(choose_card)

end

function NiuNiuReceiveHandle:SERVER_BROADCAST_CHOSETYPE( pack )

    --1. 闲家密牌. 庄开的类型.则开牌
    --2.闲家强攻.  庄也开牌.
    local playerType = NIUNIU_PLAYERTYPE_TABLE[pack.user_id]
     if (pack.send_state == 2 and pack.value == 1) or pack.send_state == 3 then 
            --庄家能看到闲家的牌
            local cards = {}
       
            for k , v in pairs(pack.head_arr) do 
                table.insert(cards , v)
            end
            for k , v in pairs(pack.final_arr) do 
                table.insert(cards , v)
            end

            GamePlaneOperator:showDealCardsAnimation(playerType,cards,4,true , nil , nil , true)


        -- if pack.card_type == 1 then
        --     print ("闲家撒扑,庄家显示杀,走")

        -- end

        -- if pack.card_type == 2 then 
        --     print ("闲家密牌,庄家显示开,认")
        -- end 

        -- if pack.card_type == 4 then 
        --     print ("闲家密陪,庄家盛")
        end

    --闷牌
    if pack.send_state == 2 then 
        local card_value2 = 1 == pack.value and "庄开" or "庄认"
        GamePlaneOperator:showCardKind(playerType , "密牌" , card_value2)
    end

    --玩家强攻
    if pack.send_state == 3 then 
        GamePlaneOperator:showCardKind(playerType , "强攻")
    end


   --闲家闷陪.显示牌型
    if pack.send_state == 4 then 
        GamePlaneOperator:showCardKind(playerType , "密陪")
    end

   if pack.user_id == USER_INFO["uid"] then 
        GamePlaneOperator:ShowShuiYuButtonState( false )
    end
    
    

    --闲家水鱼天下
    if pack.send_state == 6 then 


     
        GamePlaneOperator:showCardKind(playerType , "水鱼")
    end

    --闲家水鱼
    if pack.send_state == 5 then 



        GamePlaneOperator:showCardKind(playerType , "水鱼天下")
    end

end

--收到回放信息
function NiuNiuReceiveHandle:SERVER_PlAY_BACK( pack )
    -- body
    SCENENOW["scene"]:ShowPlayBack(pack)
end

---------------------------------------------------------------------------------------------------

return NiuNiuReceiveHandle

--测试性能专用代码
--   local t1 = os.time();
--   for  i =1,10000000  do
--    local NiuNiuReceiveHandle = math.random(1,4)
--        self:getPlayerPlane(NiuNiuReceiveHandle)
-- end

-- local t2 = os.time();
-- print(os.difftime(t2, t1),"运行时间");


