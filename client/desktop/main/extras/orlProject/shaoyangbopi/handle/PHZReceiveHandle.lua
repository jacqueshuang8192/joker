require("framework.init")
local hallHandle = require("hall.HallHandle")
local   PHZReceiveHandle = class("PHZReceiveHandle", hallHandle)
local   PROTOCOL = import("shaoyangbopi.handle.PaohuziCDProtocol")
local   phzServer = import("shaoyangbopi.handle.PHZSendHandle")
local   CardConfig = require("shaoyangbopi.logic.CardConfig")
local   BANKER_CARD_NUM = 20

function PHZReceiveHandle:ctor()
    PHZReceiveHandle.super.ctor(self);
    self.cardConfig_ = CardConfig:new()
	local func_ = {
        --登录房间返回
        [PROTOCOL.SVR_LOGIN_ROOM_OK] = {handler(self, PHZReceiveHandle.SVR_LOGIN_ROOM_OK), ""},
        [PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, PHZReceiveHandle.SVR_GROUP_BILLBOARD), ""},
        [PROTOCOL.SVR_QUIT] = {handler(self, PHZReceiveHandle.SVR_QUIT), ""},

        --提示错误
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, PHZReceiveHandle.BROADCAST_ERROR_TIPS), ""},
        --进入房间
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, PHZReceiveHandle.SVR_LOGIN_ROOM_BROADCAST), ""},
        --房间局数相关
        [PROTOCOL.SVR_GROUP_TIME] = {handler(self, PHZReceiveHandle.SVR_GROUP_TIME), ""},
        
        [PROTOCOL.BROADCAST_ERROR_STATUS] = {handler(self, PHZReceiveHandle.BROADCAST_ERROR_STATUS), ""},
		
		[PROTOCOL.SVR_LOGIN_ROOM_FAIL] = {handler(self, PHZReceiveHandle.SVR_LOGIN_ROOM_FAIL)},
        --玩家坐下
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, PHZReceiveHandle.BROADCAST_USER_SIT_DOWN), ""},
        --玩家准备
        [PROTOCOL.SVR_READY_GAME] = {handler(self, PHZReceiveHandle.SVR_READY_GAME), ""},
        --发牌
        [PROTOCOL.SVR_DEAL] = {handler(self, PHZReceiveHandle.SVR_DEAL), ""},
        --玩家操作（碰、吃、跑胡同时）
        [PROTOCOL.SVR_PLAYER_OPRATION] = {handler(self, PHZReceiveHandle.SVR_PLAYER_OPRATION), ""},
        --轮到哪个玩家操作出牌（有倒计时哦）
        [PROTOCOL.SVR_PLAYER_OUT_CARD] = {handler(self, PHZReceiveHandle.SVR_PLAYER_OUT_CARD), ""},
        --听牌
		[PROTOCOL.SVR_PLAYER_TING_INFO] = {handler(self, PHZReceiveHandle.SVR_PLAYER_TING_INFO), ""},
        --提
        [PROTOCOL.SVR_PLAYER_TI_CARD] = {handler(self, PHZReceiveHandle.SVR_PLAYER_TI_CARD), ""},
        --补牌（包括庄家第21张牌也包括每一次打牌之后，从下面摸上来的一张牌）
        [PROTOCOL.SVR_BUPAI_DEAL] = {handler(self, PHZReceiveHandle.SVR_BUPAI_DEAL), ""},
        --出牌
        [PROTOCOL.SVR_PLAYER_CHU_CARD] = {handler(self, PHZReceiveHandle.SVR_PLAYER_CHU_CARD), ""},
        --碰牌
        [PROTOCOL.SVR_PLAYER_PENG_CARD] = {handler(self, PHZReceiveHandle.SVR_PLAYER_PENG_CARD), ""},
        --跑牌
        [PROTOCOL.SVR_PLAYER_PAO_CARD] = {handler(self, PHZReceiveHandle.SVR_PLAYER_PAO_CARD), ""},
        --偎牌
        [PROTOCOL.SVR_PLAYER_WEI_CARD] = {handler(self, PHZReceiveHandle.SVR_PLAYER_WEI_CARD), ""},
        --吃牌
        [PROTOCOL.SVR_PLAYER_CHI_CARD] = {handler(self, PHZReceiveHandle.SVR_PLAYER_CHI_CARD), ""},
        --比牌
        [PROTOCOL.SVR_PLAYER_BI_CARD] = {handler(self, PHZReceiveHandle.SVR_PLAYER_BI_CARD), ""},
        --胡牌
        [PROTOCOL.SVR_PLAYER_HU_CARD] = {handler(self, PHZReceiveHandle.SVR_PLAYER_HU_CARD), ""},
        --断线重连
        [PROTOCOL.SVR_RELOAD_ROOM] = {handler(self, PHZReceiveHandle.SVR_RELOAD_ROOM), ""},
        --总结算
        [PROTOCOL.G2H_BROADCAST_GROUP_RESULT] = {handler(self, PHZReceiveHandle.G2H_BROADCAST_GROUP_RESULT), ""},

        --解散房间相关
        [PROTOCOL.G2H_CMD_DISSOLVE_FAILED] = {handler(self, PHZReceiveHandle.G2H_CMD_DISSOLVE_FAILED), ""},
        --广播当前组局解散情况
        [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST] = {handler(self, PHZReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST), ""},
        --广播桌子用户请求解散组局
        [PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {handler(self, PHZReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP), ""},
        --广播桌子用户成功解散组局
        [PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP] = {handler(self, PHZReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP), ""},
        --广播桌子用户解散组局 ，解散组局失败
        [PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP] = {handler(self, PHZReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP), ""},

        --1033玩家离开房间
        [PROTOCOL.SVR_BROADCAST_USER_LEAVEROOM] = {handler(self, PHZReceiveHandle.SVR_BROADCAST_USER_LEAVEROOM), ""},

        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, PHZReceiveHandle.SERVER_CMD_MESSAGE), ""},
        --1214  检测别人是否有偎
        [PROTOCOL.SVR_SEND_WEI] = {handler(self, PHZReceiveHandle.SVR_SEND_WEI), ""},
        --100e  哟用户退出
        [PROTOCOL.SVR_LOGOUT_ROOM] = {handler(self, PHZReceiveHandle.SVR_LOGOUT_ROOM), ""},
     
        --111 广播玩家充值
        [PROTOCOL.SVR_CHARGE_BROADCAST]       = {handler(self, PHZReceiveHandle.SVR_CHARGE_BROADCAST)},   
        [PROTOCOL.SVR_REQ_TEST_CARDS] = {handler(self, PHZReceiveHandle.SVR_REQ_TEST_CARDS), ""},
        [PROTOCOL.SVR_PLAYER_AI_STATE] = {handler(self, PHZReceiveHandle.SVR_PLAYER_AI_STATE), ""},----广播用户托管
    }
    table.merge(self.func_, func_)
end                   

function PHZReceiveHandle:callFunc(pack)
    dump(pack.cmd,"当前游戏解析协议号")

    if SCENENOW["name"]~= TpackageName .. ".gameScene" then
        return
    end

    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end

end
--
function PHZReceiveHandle:BROADCAST_ERROR_STATUS(pack)
	dump(pack,"BROADCAST_ERROR_STATUS")
end

--进入房间失败 1005
function PHZReceiveHandle:SVR_LOGIN_ROOM_FAIL(pack)
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
function PHZReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)
	print("=====服务器广播用户登陆房间======")
	dump(pack,"SVR_LOGIN_ROOM_BROADCAST")
    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(pack.uid,{nickName = pack.nickName,ip = pack.ip,latitude = pack.latitude,longitude = pack.longitude})
    local otherInfo = json.decode(pack.otherInfo)
    if pack.uid == USER_INFO["uid"] then
        g_PHZMainScene.m_seatID = pack.seat_id
        g_PHZMainLayer.PHZDownNode:setVisible(true)
        g_PHZMainLayer.PHZDownNode:refreshPlayerInfo(pack.portrait, pack.uid, pack.sex, pack.nickName, pack.ip, pack.addres)
        g_PHZMainLayer.m_headNode[0]:refreshPlayer_FXScore(pack.m_chips)
		g_PHZMainLayer.m_headNode[0]:setTotalHuXi(pack.m_totalBlc)
        if g_PHZMainScene.m_CardReady == false and pack.if_ready == 1 then
            g_PHZMainLayer.m_headNode[0]:isShowZhunBeiIMG(true)
            g_PHZMainLayer:isShowZhunBeiBtn(false)
        end

    end
    g_PHZMainLayer:showGPSButton()
    --phzServer:sitDown(pack.portrait,pack.nickName)
end

--玩家坐下
function PHZReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
    print("=====有玩家进来了啦！！！====",pack.uid)
	dump(pack,"BROADCAST_USER_SIT_DOWN")
    if pack.uid == USER_INFO["uid"] then
        g_PHZMainScene.m_seatID = pack.seat_id
        g_PHZMainLayer.PHZDownNode:setVisible(true)
        require("hall.view.userInfoView.userInfoView"):upDateUserInfo(pack.uid,{nickName = pack.nickName,ip = pack.ip,latitude = pack.latitude,longitude = pack.longitude})
        g_PHZMainLayer.PHZDownNode:refreshPlayerInfo(pack.portrait,pack.uid,pack.sex,pack.nickName, pack.ip, pack.addres)
        g_PHZMainLayer.m_headNode[0]:refreshPlayer_FXScore(pack.m_chips)
		g_PHZMainLayer.m_headNode[0]:setTotalHuXi(pack.m_totalBlc)
        g_PHZMainLayer:isShowHuXiTxt(0)
        for k,v in pairs(g_PHZMainScene.otherInfo) do
            local tempChairId = g_PHZMainScene:getViewChairId(v.seat_id)
            g_PHZMainLayer.m_headNode[tempChairId]:setVisible(true)
            g_PHZMainLayer:isShowHuXiTxt(tempChairId)
            require("hall.view.userInfoView.userInfoView"):upDateUserInfo(v.uid,{nickName = v.nickName,ip = v.ip,latitude = v.latitude,longitude = v.longitude})
            g_PHZMainLayer.m_headNode[tempChairId]:refreshPlayerInfo(v.portrait,v.uid,v.sex,v.nickName, v.ip, v.addres)
            g_PHZMainLayer.m_headNode[tempChairId]:refreshPlayer_FXScore(v.m_chips)
			g_PHZMainLayer.m_headNode[tempChairId]:setTotalHuXi(v.m_totalBlc)
            print("=======g_PHZMainScene.m_CardReady =======",g_PHZMainScene.m_CardReady)
            if g_PHZMainScene.m_CardReady == false and v.if_ready == 1 then
                g_PHZMainLayer.m_headNode[tempChairId]:isShowZhunBeiIMG(true)
            end

        end
    else
        --初始化玩家坐下
        local tempChairId = g_PHZMainScene:getViewChairId(pack.seat_id)
        g_PHZMainLayer.m_headNode[tempChairId]:setVisible(true)
        require("hall.view.userInfoView.userInfoView"):upDateUserInfo(pack.uid,{nickName = pack.nickName,ip = pack.ip,latitude = pack.latitude,longitude = pack.longitude})
        g_PHZMainLayer.m_headNode[tempChairId]:refreshPlayerInfo(pack.portrait,pack.uid,pack.sex,pack.nickName, pack.ip, pack.addres)
        g_PHZMainLayer.m_headNode[tempChairId]:refreshPlayer_FXScore(pack.m_chips)
		g_PHZMainLayer.m_headNode[tempChairId]:setTotalHuXi(pack.m_totalBlc)
        g_PHZMainLayer:isShowHuXiTxt(tempChairId)
        --gps显示
    end
    local isHave = false
    for k,v in pairs(g_PHZMainScene.otherInfo) do
        if v.uid == pack.uid then
            isHave = true
        end
    end
    if isHave == false then
        g_PHZMainScene.otherInfo[pack.uid] = {}
        g_PHZMainScene.otherInfo[pack.uid] = pack
        -- g_PHZMainScene.otherInfo[pack.uid].latitude = 10
        -- g_PHZMainScene.otherInfo[pack.uid].longitude = 10
    end
    g_PHZMainLayer:showGPSButton()

end

--登录房间OK
function PHZReceiveHandle:SVR_LOGIN_ROOM_OK(pack)
    require(NetworkLoadingView_filePath):removeView(888)
	dump(pack,"SVR_LOGIN_ROOM_OK")
    dump(pack.RoomInfo)

    pack.RoomInfo = json.decode(pack.RoomInfo)
    dump(pack.RoomInfo)
    g_PHZMainLayer:showGameConfig(pack.RoomInfo)

    NUMBER_USER = pack.max_mount
    GAME_HU_XI = pack.RoomInfo.huxi_score or 0
	GAME_SYBP_MODETYPE = pack.RoomInfo.modetype or 1
    local tempRank = string.split(pack.RoomInfo.rank, ",")
    local tempRankStr = ""
    if tempRank[1] == 0 then
        tempRankStr = GAME_TYPE_TANG[1]
    elseif tempRank[1] == 1 then
        tempRankStr = GAME_TYPE_TANG[1]
    end

    local tempWanFa = string.split(pack.RoomInfo.wanfa, ",")
    local tempWFStr = ""

    for k,v in pairs(tempWanFa) do
        if tonumber(v) == 1 then
            tempWFStr = tempWFStr.."大团圆".." "
        elseif tonumber(v) == 2 then
            tempWFStr = tempWFStr.."行行息".." "
        end
    end

    local tempXiStr = GAME_HU_XI.."胡起胡"

    local allStr = tempRankStr.." "..tempWFStr..tempXiStr


    g_PHZMainScene.m_seatID = pack.seat_id

    --设置自建房信息
    g_PHZMainScene.m_nMasterID = pack.OwnerID    
    g_PHZMainScene.m_nRoomID = pack.inviteCode
    HEART_BEAT_TID = USER_INFO["tid"]
    --将其他玩家的信息记录下来
    g_PHZMainScene.otherInfo = {}
    dump(pack.playerlist)

    for k,v in pairs(pack.playerlist) do
        g_PHZMainScene.otherInfo[v.uid] = {}
        g_PHZMainScene.otherInfo[v.uid] = v
        if v.uid ~= USER_INFO["uid"] then
            -- g_PHZMainScene.otherInfo[v.uid].latitude = 10
            -- g_PHZMainScene.otherInfo[v.uid].longitude = 10
            
            if g_PHZMainScene.m_seatID ~= -1 then

                local tempChairId = g_PHZMainScene:getViewChairId(v.seat_id)
                g_PHZMainLayer.m_headNode[tempChairId]:setVisible(true)
                require("hall.view.userInfoView.userInfoView"):upDateUserInfo(v.uid,{nickName = v.nickName,ip = v.ip,latitude = v.latitude,longitude = v.longitude})
                g_PHZMainLayer.m_headNode[tempChairId]:refreshPlayerInfo(v.portrait,v.uid,v.sex,v.nickName, v.ip, v.addres)
                g_PHZMainLayer.m_headNode[tempChairId]:refreshPlayer_FXScore(v.m_chips)
				 g_PHZMainLayer.m_headNode[tempChairId]:setTotalHuXi(v.m_totalBlc)
                print("=======g_PHZMainScene.m_CardReady =======",g_PHZMainScene.m_CardReady)
                if g_PHZMainScene.m_CardReady == false and v.if_ready == 1 then
                    g_PHZMainLayer.m_headNode[tempChairId]:isShowZhunBeiIMG(true)
                end
            end
        end
    end

    g_PHZMainLayer.PHZUpNode:setVisible(true)
    g_PHZMainLayer:setRoomNum(g_PHZMainScene.m_nRoomID)

    dump(g_PHZMainScene.otherInfo,"g_PHZMainScene.otherInfo")
    --gps显示
    g_PHZMainLayer:showGPSButton()
end

--房间局数相关
function PHZReceiveHandle:SVR_GROUP_TIME(pack)
    dump(pack,"SVR_GROUP_TIME")
    g_PHZMainLayer:setRoomRound(pack["round"], pack["round_total"])
    -- print("======房间局数相关======",pack.round,pack.round_total)
    -- dump(pack,"SVR_GROUP_TIME")
    g_PHZMainScene.m_bGameCount = pack.round
    g_PHZMainScene.m_bMaxGameCount = pack.round_total
    g_PHZMainLayer:setJvShu()

    --add by zzy 2019-7-17
    -- if not tolua.isnull(g_PHZMainLayer.moreFuncLayer) and pack.round == 0 then
    --     g_PHZMainLayer.moreFuncLayer.btnDisbandRoom:setVisible(false)
    -- end
    SCENENOW["scene"].GameRound = pack.round

end

--游戏准备返回 6001
function PHZReceiveHandle:SVR_READY_GAME(pack)
    dump(pack,"SVR_READY_GAME")
    if pack.uid == USER_INFO["uid"] then
        g_PHZMainLayer:isShowZhunBeiBtn(false)
        g_PHZMainLayer.PHZDownNode:isShowZhunBeiIMG(true)
        for i = 0, 2 do
            g_PHZMainLayer.m_headNode[i]:setHuXi(0)
        end
    else
        local tempSeatID = g_PHZMainScene.otherInfo[pack.uid].seat_id
        g_PHZMainScene.otherInfo[pack.uid].if_ready = 1
        local tempChairId = g_PHZMainScene:getViewChairId(tempSeatID)
        g_PHZMainLayer.m_headNode[tempChairId]:isShowZhunBeiIMG(true)
    end
end

--发牌返回
function PHZReceiveHandle:SVR_DEAL(pack)
    dump(pack,"开始玩家发牌SVR_DEAL")
    g_CardScene:clearTingData()
    g_PHZMainLayer.btn_share:setVisible(false)
    if g_PHZMainScene.m_seatID == pack.seat_id then
    --     pack.HandCardDatas = {
    --         10,10,3,25,4,25,18,24,24,5,24,5,4,9,18,20,8,18,19,19
    -- }
        g_CardScene:setCurHandCard(pack.HandCardDatas)  --初始化牌

    --     pack.HandCardDatas = {
    --         10,10,3,25,4,25,18,24,24,5,24,5,4,9,18,20,8,18,19,19
    -- }

        --设置玩家底牌
        g_PHZMainScene.m_diCardCount = pack.diPaiCount
		g_PHZMainScene.m_BeginDiCardCount = pack.diPaiCount
        g_PHZMainLayer.PHZUpNode:setDicardNum(g_PHZMainScene.m_diCardCount)

    end

    --显示出玩家谁是庄家
    g_PHZMainScene.m_bankerSeatID = pack.banker_seat_id
    local wViewId = g_PHZMainScene:getViewChairId(pack.banker_seat_id)

    --将所有的准备图片收起来,显示谁是庄家
    for i=0,2 do
        g_PHZMainLayer.m_headNode[i]:isShowZhunBeiIMG(false)
        if wViewId == i then
            g_PHZMainLayer.m_headNode[i]:isShowZhuangIMG(true)
        else
            g_PHZMainLayer.m_headNode[i]:isShowZhuangIMG(false)
        end 
    end
end

--玩家进行操作
function PHZReceiveHandle:SVR_PLAYER_OPRATION(pack)
    print("=======玩家进行操作====碰、吃、胡==88888888888888888888=")
    dump(pack,"SVR_PLAYER_OPRATION")
    g_PHZMainLayer.PHZOprorateNode:setVisible(false)

    --获取相对自己得玩家座位号
    if g_PHZMainScene.m_seatID == pack.seat_id then
        print("==自己开始操作=9999999999999999=")
        g_PHZMainScene.m_bOutCard = false     --能否出牌
        if pack.Cardbuf[1] == 1 then
            local tempNode = cc.Node:create()
            g_PHZMainScene:addChild(tempNode)
            tempNode:stopAllActions()
            local dt = cc.DelayTime:create(0.9)
            local function func()
                g_PHZMainLayer.PHZOprorateNode:setVisible(true)
                tempNode:stopAllActions()
                tempNode:removeFromParent()
            end
            local funcTime = cc.CallFunc:create(func)
            local seq = cc.Sequence:create(dt,funcTime)
            tempNode:runAction(seq)
        else
            g_PHZMainLayer.PHZOprorateNode:setVisible(true)
        end
        g_PHZMainLayer.PHZOprorateNode:setButtonCanClick(pack.Cardbuf)
    end
end

--轮到那个玩家进行出牌操作
function PHZReceiveHandle:SVR_PLAYER_OUT_CARD(pack)
    if not g_PHZMainLayer.m_headNode then
        return
    end
    print("====此玩家开始出牌====",pack.seat_id)
    dump(pack,"SVR_PLAYER_OUT_CARD")
    --停止以及移除玩家头像闪烁以及倒计时
    for i=0,2 do
        g_PHZMainLayer.m_headNode[i]:ShowTimerText(-1)
    end
    local wViewId = g_PHZMainScene:getViewChairId(pack.seat_id)
    g_PHZMainLayer.m_headNode[wViewId]:ShowTimerText(pack.out_time)

    if wViewId == 0 then
        g_PHZMainScene.m_bOutCard = true

        --显示滑动出牌
        g_PHZMainLayer:show_Action_Ready()
    end 
end

function PHZReceiveHandle:SVR_PLAYER_TING_INFO(pack)
    dump(pack,"----听牌消息")
    if g_PHZMainLayer.tingAuto then
        g_PHZMainLayer.TingView:hideTing2()
        local tingData = {}
        for idx,data in ipairs(pack.tingCards) do
            tingData[data.card] = data.tingHuCards
        end
        g_CardScene:setTings(tingData)
        g_PHZMainLayer:showTingNode()
    end
end

--提牌操作
function PHZReceiveHandle:SVR_PLAYER_TI_CARD(pack)
    dump(pack,"SVR_PLAYER_TI_CARD")
    require("hall.GameCommon"):playEffectSound("shaoyangbopi/res/sound/ti.mp3")
    
    g_PHZMainScene.m_newDiCard = nil

    if pack.CardValue == g_PHZMainScene.m_cbOutCardData then
        g_PHZMainScene.m_cbOutCardData = 0
    end
    
    local tempNode = cc.Node:create()
    g_PHZMainScene:addChild(tempNode)
    tempNode:stopAllActions()
    local dt = cc.DelayTime:create(0.9)
    g_CardScene:removeBuCardNode( pack.CardValue )
    local function func()
        local tempChairId = g_PHZMainScene:getViewChairId(pack.seat_id)
        --g_PHZMainScene:OnSubSaoExCardTi(pack)
        g_CardScene:onSaoExCard(tempChairId,pack.CardValue,4,false)
   
		--print('----------------xxxxxxxxxxxxxxxx------',g_PHZMainScene.m_diCardCount, g_PHZMainScene.m_BeginDiCardCount)
        --if g_PHZMainScene.m_diCardCount ~= 19 then
        --起手提第一圈出牌不隐藏出的牌
        
        --print(g_PHZMainScene.m_BeginDiCardCount)
        --print(g_PHZMainScene.m_diCardCount)
        --dump("56421065sdfsdf78943165")
        if not g_PHZMainScene.m_BeginDiCardCount or (g_PHZMainScene.m_BeginDiCardCount - g_PHZMainScene.m_diCardCount)>=2 then
            for i=0,2 do
                if g_CardScene.m_OutSprite[i].card == pack.CardValue then
                    g_CardScene.m_OutSprite[i]:setVisible(false)
                end
            end
            --g_CardScene.m_OutSprite[0]:setVisible(false)
        end
       
        tempNode:stopAllActions()
        tempNode:removeFromParent()

        if pack.seat_id == g_PHZMainScene.m_seatID then
            g_PHZMainLayer:showTingNode()
        end
    end
    local funcTime = cc.CallFunc:create(func)
    local seq = cc.Sequence:create(dt,funcTime)
    tempNode:runAction(seq)
    g_PHZMainScene.m_diCardCount = pack.diPaiCount
    g_PHZMainLayer.PHZUpNode:setDicardNum(g_PHZMainScene.m_diCardCount)
    -- local tempChairId = g_PHZMainScene:getViewChairId(pack.seat_id)
    -- g_CardScene:onSaoExCard(tempChairId,pack.CardValue,1,false)
    -- print("===关闭玩家出的牌=285==")
    -- for i=0,2 do
    --     g_CardScene.m_OutSprite[i]:setVisible(false)
    -- end
    
end

--补牌或者派发单张
function PHZReceiveHandle:SVR_BUPAI_DEAL(pack)
    for i=0, GAME_PLAYER - 1 do
        g_PHZMainLayer.m_headNode[i]:ShowTimerText(-1)
    end
    dump(pack,"SVR_BUPAI_DEAL")


   --设置玩家底牌
    g_PHZMainScene.m_diCardCount = pack.diPaiCount
    g_PHZMainLayer.PHZUpNode:setDicardNum(g_PHZMainScene.m_diCardCount)

   g_PHZMainLayer.PHZOprorateNode:setVisible(false)
   local wViewId = g_PHZMainScene:getViewChairId(pack.seat_id)

   --最新摸的底牌的数值
   g_PHZMainScene.m_newDiCard = pack.card_value

   --判断是否为补牌（第20张时，即为补牌21）
   g_PHZMainScene.m_CardReady = true

   if pack.if_draw == 1  then
        print("=====这张牌为补牌，数值为：=====",pack.card_value)
        g_CardScene:supplyCard(wViewId,pack.card_value,pack.card_from)
        if wViewId == 0 then
            g_PHZMainLayer:show_Action_Ready()
            g_PHZMainScene.m_bOutCard = true
        end
        g_PHZMainLayer:isShowHuXiTxt(wViewId)
   else
        if pack.card_from == 1 then
            print("===从底部抽取一张牌===")
            g_CardScene:supplyCard(wViewId,pack.card_value,pack.card_from)
            return
        end

        local cardInfo = self.cardConfig_:getCardInfoByid(pack.card_value)
        if cardInfo then
            local strSound = cardInfo.Mousic
            require("hall.GameCommon"):playEffectSound(strSound)
        end

        g_PHZMainLayer.PHZOprorateNode:setVisible(false)
        g_PHZMainScene:OnSubSendCard(pack.seat_id,pack.card_value)
   end

    --判断是否有听牌显示
    print("=判断是否有听牌显示====383=====")
    if wViewId == 0 then
        g_PHZMainLayer:showTingNode()
    end
end

--玩家出牌
function PHZReceiveHandle:SVR_PLAYER_CHU_CARD(pack)
    dump(pack,"SVR_PLAYER_CHU_CARD")
    for i=0,2 do
        g_PHZMainLayer.m_headNode[i]:ShowTimerText(-1)
    end
    g_PHZMainLayer:isShowImgReady(false)
    if g_PHZMainScene.m_seatID == pack.seat_id then
        if isTuoGuan then
            g_CardScene:removeCardByWeave( {pack.CardValue} )
        end 
        g_CardScene:setTingHuBtn(pack.CardValue)
    end
    local cardInfo = self.cardConfig_:getCardInfoByid(pack.CardValue)
    if cardInfo then
        local strSound = cardInfo.Mousic
        require("hall.GameCommon"):playEffectSound(strSound)
    end

    g_PHZMainLayer.PHZOprorateNode:setVisible(false)
    g_PHZMainScene:OnSubOutCard(pack)

    local wViewId = g_PHZMainScene:getViewChairId(pack.seat_id)
    if wViewId == 0 then
        g_PHZMainLayer:showTingNode()

        g_PHZMainScene.m_bOutCard = false
        --停止闪烁，停止滑动
        g_PHZMainLayer.m_headNode[0]:stopShanShou()

        g_PHZMainLayer:isShowImgReady(false)
    end
    print("==判断是否有听牌显示===413=====")
    --判断是否有听牌显示

end

--玩家碰牌
function PHZReceiveHandle:SVR_PLAYER_PENG_CARD(pack)
    dump(pack,"SVR_PLAYER_PENG_CARD")
    g_PHZMainLayer.PHZOprorateNode:setVisible(false)
    if g_PHZChiCardLayer then
        g_PHZChiCardLayer:removeFromParent()
        g_PHZChiCardLayer = nil
    end

    require("hall.GameCommon"):playEffectSound("shaoyangbopi/res/sound/peng.mp3")

    g_PHZMainScene:OnSubPengCard(pack)
    g_PHZMainScene.m_diCardCount = pack.diPaiCount
    g_PHZMainLayer.PHZUpNode:setDicardNum(g_PHZMainScene.m_diCardCount)
    --判断是否有听牌显示
    print("==判断是否有听牌显示===431=====")
    g_PHZMainLayer:showTingNode()
    if pack.seat_id == g_PHZMainScene.m_seatID then
        g_PHZMainLayer:showTingNode()
    end
end

--玩家跑牌
function PHZReceiveHandle:SVR_PLAYER_PAO_CARD(pack)
    dump(pack,"玩家跑牌了")

    g_PHZMainScene.m_newDiCard = nil

    g_PHZMainLayer.PHZOprorateNode:setVisible(false)
    if g_PHZChiCardLayer then
        g_PHZChiCardLayer:removeFromParent()
        g_PHZChiCardLayer = nil
    end


    require("hall.GameCommon"):playEffectSound("shaoyangbopi/res/sound/pao.mp3")

    local tempNode = cc.Node:create()
    g_PHZMainScene:addChild(tempNode)
    tempNode:stopAllActions()
    local dt = cc.DelayTime:create(0.9)
    local function func()
        g_PHZMainScene:OnSubSaoExCard(pack)
        print("===关闭玩家出的牌=385==")
        for i=0,2 do
            g_CardScene.m_OutSprite[i]:setVisible(false)
        end
        g_PHZMainScene.m_cbOutCardData = 0
        tempNode:stopAllActions()
        tempNode:removeFromParent()

        print("===判断是否有听牌显示==469=====")
        if pack.seat_id == g_PHZMainScene.m_seatID then
            g_PHZMainLayer:showTingNode()
        end
    end
    local funcTime = cc.CallFunc:create(func)
    local seq = cc.Sequence:create(dt,funcTime)
    tempNode:runAction(seq)
    g_PHZMainScene.m_diCardCount = pack.diPaiCount
    g_PHZMainLayer.PHZUpNode:setDicardNum(g_PHZMainScene.m_diCardCount)
    --判断是否有听牌显示
    
    -- g_PHZMainScene:OnSubSaoExCard(pack)
    -- print("===关闭玩家出的牌=385==")
    -- for i=0,2 do
    --     g_CardScene.m_OutSprite[i]:setVisible(false)
    -- end
end

--玩家畏牌
function PHZReceiveHandle:SVR_PLAYER_WEI_CARD(pack)
    dump(pack,"SVR_PLAYER_WEI_CARD")
    -- pack.cardType = 0
    g_PHZMainScene.m_newDiCard = nil
    if pack.CardValue == g_PHZMainScene.m_cbOutCardData then
        g_PHZMainScene.m_cbOutCardData = 0
    end
    g_PHZMainScene:OnSubSendCardWei()
    g_PHZMainScene.m_cbOutCardData = 0
    local card = pack.CardValue
    if pack.seat_id ~= g_PHZMainScene.m_seatID then
        card = 0
    end
    g_PHZMainScene:OnSubSendCard(pack.seat_id,card)

    require("hall.GameCommon"):playEffectSound("shaoyangbopi/res/sound/wei.mp3")
    g_PHZMainLayer.PHZOprorateNode:setVisible(false)

    local tempNode = cc.Node:create()
    g_PHZMainScene:addChild(tempNode)
    tempNode:stopAllActions()
    local dt = cc.DelayTime:create(0.9)
    local function func()
        g_PHZMainScene:OnSubSaoCard(pack)
        print("=wei==关闭玩家出的牌=400==")
        for i=0,2 do
            local m_OutSprite = g_CardScene.m_OutSprite[i]
            if m_OutSprite.card == card then
                m_OutSprite:setVisible(false)
            end
        end
        tempNode:stopAllActions()
        tempNode:removeFromParent()

        if pack.seat_id == g_PHZMainScene.m_seatID then
            g_PHZMainLayer:showTingNode()
        end
    end
    local funcTime = cc.CallFunc:create(func)
    local seq = cc.Sequence:create(dt,funcTime)
    tempNode:runAction(seq)
    g_PHZMainScene.m_diCardCount = pack.diPaiCount
    g_PHZMainLayer.PHZUpNode:setDicardNum(g_PHZMainScene.m_diCardCount)
    --判断是否有听牌显示
    print("===506==判断是否有听牌显示")
    
end

--玩家吃牌
function PHZReceiveHandle:SVR_PLAYER_CHI_CARD(pack)
    print("=====吃牌9999999====")
    print("=====吃牌9999999====")
    print("=====吃牌9999999====")
    print("=====吃牌9999999====")
    if g_PHZChiCardLayer then
        g_PHZChiCardLayer:removeFromParent()
        g_PHZChiCardLayer = nil
    end

    require("hall.GameCommon"):playEffectSound("shaoyangbopi/res/sound/chi.mp3")
    g_PHZMainLayer.PHZOprorateNode:setVisible(false)
    local wViewId = g_PHZMainScene:getViewChairId(pack.seat_id)
    if g_PHZMainScene.m_wOutCardUser~=INVALID_CHAIR then
        local wResViewId = g_PHZMainScene:getViewChairId(g_PHZMainScene.m_wOutCardUser)
        g_CardScene:onEventCard(wViewId,wResViewId)
    end
    -- dump(pack.Cardbuf)
    g_CardScene:onChiCard(wViewId,pack.Cardbuf)
    g_PHZMainScene.m_diCardCount = pack.diPaiCount
    g_PHZMainLayer.PHZUpNode:setDicardNum(g_PHZMainScene.m_diCardCount)
    --判断是否有听牌显示
    print("===538==判断是否有听牌显示")
    if wViewId == 0 then
        g_PHZMainLayer:showTingNode()
    end
end

--玩家比牌
function PHZReceiveHandle:SVR_PLAYER_BI_CARD(pack)
    print("=====比牌9999999====")
    dump(pack)
    local wViewId = g_PHZMainScene:getViewChairId(pack.seat_id)
    g_CardScene:onBiCard(wViewId,pack.Cardbuf,pack.biCardValue)
    --判断是否有听牌显示
    print("===552==判断是否有听牌显示")
    if pack.seat_id == g_PHZMainScene.m_seatID then
        g_PHZMainLayer:showTingNode()
    end
	if pack.isDeath == 1 then
		g_PHZMainLayer:isShowImgReady(false)
	end
end

--玩家胡牌
function PHZReceiveHandle:SVR_PLAYER_HU_CARD(pack)
    print("====我胡牌了====")
    dump(pack)
    g_PHZMainLayer:isShowTuoGuan( false )

    if g_PHZTingNode then
        g_PHZTingNode:removeTingNode()
    end
    g_PHZMainScene.m_bOutCard = false     --能否出牌
    g_PHZMainScene.m_CardReady = false    --字牌是否就绪

    g_PHZMainLayer.PHZOprorateNode:setVisible(false)

    if g_PHZChiCardLayer then
        g_PHZChiCardLayer:removeFromParent()
        g_PHZChiCardLayer = nil
    end

    --显示玩家胡得图片
    -- local playHuUid,wViewId = nil,nil
    -- for k,v in pairs(pack.playerList) do
    --     if v.isWin == 1 then
    --         playHuUid = v.uid
    --         break
    --     end
    -- end

    -- if playHuUid then
    --     if playHuUid == USER_INFO.uid then
    --         wViewId = g_PHZMainScene:getViewChairId(USER_INFO.seat_id)
    --     else
    --         if g_PHZMainScene.otherInfo[playHuUid] then
    --             wViewId = g_PHZMainScene:getViewChairId(g_PHZMainScene.otherInfo[playHuUid].seat_id)
    --         end
    --     end
    --     if wViewId then
    --         g_PHZMainLayer.m_headNode[wViewId]:showImgHu()
    --     end
    -- end

    --处理胡牌的时候，所有胡的牌按下

    --判断一下是否最后胡牌的玩家是是不是本人，如果是本人的话则将所要胡牌的队列放入队列中

    local tempWinUid = nil
    for k,v in pairs(pack.userArr) do
        if v.m_turnBlc >0 then
            tempWinUid = v.uid
            break
        end
    end

    if not tempWinUid  then
        require("hall.GameCommon"):playEffectSound("shaoyangbopi/res/sound/huangzhuang.mp3")
    else
        require("hall.GameCommon"):playEffectSound("shaoyangbopi/res/sound/hu.mp3")
    end
    for k,v in pairs(pack.huUserArr) do
        if v.uid == USER_INFO.uid then
            if v.group_count == 3 then
                if v.groupArr[1] == v.groupArr[2] and v.groupArr[1] == v.groupArr[3] then
                    local tempData = {seat_id = g_PHZMainScene.m_seatID ,CardValue = v.groupArr[1]}
                    g_PHZMainScene:OnSubPengCard(tempData)
                else
                    local wViewId = g_PHZMainScene:getViewChairId(g_PHZMainScene.m_seatID)
                    if g_PHZMainScene.m_wOutCardUser~=INVALID_CHAIR then
                        local wResViewId = g_PHZMainScene:getViewChairId(g_PHZMainScene.m_wOutCardUser)
                        g_CardScene:onEventCard(wViewId,wResViewId)
                    end

                    local tempChiHuList = {}
                    local tempHuCard = pack.m_CheckCard
                    for k2,v2 in pairs(v.groupArr) do
                        if v2 == tempHuCard then
                            table.insert(tempChiHuList,v2)
                        end
                    end

                    for k2,v2 in pairs(v.groupArr) do
                        if v2 ~= tempHuCard then
                            table.insert(tempChiHuList,v2)
                        end
                    end

                    g_CardScene:onChiCard(wViewId,tempChiHuList)
                end
            elseif v.group_count == 2 then
                local wViewId = g_PHZMainScene:getViewChairId(g_PHZMainScene.m_seatID)
                g_CardScene:onDuiCard(wViewId,v.groupArr[1])
            end
        end

    end

    --刷新玩家
    for k,v in pairs(pack.userArr) do
        if v.uid == USER_INFO.uid then
            g_PHZMainLayer.m_headNode[0]:refreshPlayer_FXScore(v.m_chips)
			g_PHZMainLayer.m_headNode[0]:setTotalHuXi(v.m_totalBlc)
        else
            local temp_seat_id = g_PHZMainScene.otherInfo[v.uid].seat_id
            local wViewId = g_PHZMainScene:getViewChairId(temp_seat_id)
            g_PHZMainLayer.m_headNode[wViewId]:refreshPlayer_FXScore(v.m_chips)
			g_PHZMainLayer.m_headNode[wViewId]:setTotalHuXi(v.m_totalBlc)
        end
    end

    --1:初始化其他两个玩家手中剩下的牌
    g_PHZMainLayer:AddOtherCardLayer(pack.userArr,pack.currCardArr)
    --2:延后几秒加入总结算层
    g_PHZMainLayer:showResultLayer(pack)

    
end

function PHZReceiveHandle:G2H_BROADCAST_GROUP_RESULT(pack)

    dump(pack,"G2H_BROADCAST_GROUP_RESULT")
    g_PHZMainScene.m_isGameOver = true

    g_PHZMainScene.m_AllZhanJi = pack
    g_PHZMainLayer:updateBtnResult()
    if pack.isShowSingle == 0 then
        g_PHZMainLayer:showAllResultLayer(pack)
    end

    --gps显示
    g_PHZMainLayer:showGPSButton()

end

--玩家断线重连
function PHZReceiveHandle:SVR_RELOAD_ROOM(pack)
    require(NetworkLoadingView_filePath):removeView(888)
    dump(pack,"==我断线重连了===pack")
    pack.RoomInfo = json.decode(pack.RoomInfo)
    g_PHZMainLayer:showGameConfig(pack.RoomInfo)
	GAME_SYBP_MODETYPE = pack.RoomInfo.modetype or 1
   
    -- print("======我断线重连了===pack.LeftTime==",pack.LeftTime)
    -- print("======我断线重连了=== if pack.OutCardUserId == m_CurOutCard==",pack.m_CurOutCard)
    -- print("======我断线重连了===pack.OutCardUserId==",pack.OutCardUserId)
    -- print("======我断线重连了===USER_INFO.uid==",g_PHZMainScene.m_seatID)
    -- print("======我断线重连了=====")
    -- print("======我断线重连了=====")
    -- dump(pack.LastCarddata,"我断线重连了555")
    -- dump(pack.Carddata[1].pengList)

    GAME_HU_XI = pack.RoomInfo.huxi_score or 0
    -- local tempRank = string.split(pack.RoomInfo.rank, ",")
    -- local tempRankStr = ""
    -- if tempRank[1] == 0 then
    --     tempRankStr = GAME_TYPE_TANG[1]
    -- elseif tempRank[1] == 1 then
    --     tempRankStr = GAME_TYPE_TANG[1]
    -- end

    -- local tempWanFa = string.split(pack.RoomInfo.wanfa, ",")
    -- local tempWFStr = ""
    -- for k,v in pairs(tempWanFa) do
    --     tempWFStr = tempWFStr..GAME_PLAY_TYPE[v].." "
    -- end

    -- local tempXiStr = GAME_HU_XI.."胡起胡"

    -- local allStr = tempRankStr.." "..tempWFStr..tempXiStr


    NUMBER_USER = pack.max_mount
    g_PHZMainScene:clearData()

    g_PHZMainLayer:restGame()
    HEART_BEAT_TID = USER_INFO["tid"]
    --初始化房间信息
    g_PHZMainScene.m_nMasterID = pack.OwnerID    
    g_PHZMainScene.m_nRoomID = pack.inviteCode
    g_PHZMainLayer.PHZUpNode:setVisible(true)
    g_PHZMainLayer:setRoomNum(g_PHZMainScene.m_nRoomID)
    g_PHZMainLayer:setRoomRound(pack["round"], pack["round_total"])

    g_PHZMainScene.m_bGameCount = pack.round
    g_PHZMainScene.m_bMaxGameCount = pack.round_total
    g_PHZMainLayer:setJvShu()
    if pack.GAME_STATE ~= 0 then
        g_PHZMainLayer.btn_share:setVisible(false)
    end
    print("======我断线重连了===USER_INFO.uid==",g_PHZMainScene.m_seatID)
    for k,v in pairs(pack.playerlist) do
        if v.uid == USER_INFO["uid"] then
            g_PHZMainScene.m_seatID = v.seat_id
        end 
    end
    g_PHZMainScene.otherInfo = {}
    dump(pack.playerlist,"玩家重連")
    for k,v in pairs(pack.playerlist) do
        g_PHZMainScene.otherInfo[v.uid] = {}
        g_PHZMainScene.otherInfo[v.uid] = v
        if v.uid == USER_INFO["uid"] then 
            
            if pack.GAME_STATE == 0 then
                if v.if_ready == 0 then                 
                    g_PHZMainLayer.btn_zhunbei:setVisible(true)
                else
                    g_PHZMainLayer.m_headNode[0]:isShowZhunBeiIMG(true)
                end
            end

            g_PHZMainScene.m_seatID = v.seat_id
            g_PHZMainLayer:isShowHuXiTxt(0)
            g_PHZMainLayer.m_headNode[0]:setVisible(true)
            require("hall.view.userInfoView.userInfoView"):upDateUserInfo(v.uid,{nickName = v.nickName,ip = v.ip,latitude = v.latitude,longitude = v.longitude})
            g_PHZMainLayer.m_headNode[0]:refreshPlayerInfo(v.portrait,v.uid,v.sex,v.nickName, v.ip, v.addres)
            g_PHZMainLayer.m_headNode[0]:refreshPlayer_FXScore(v.m_chips)
			g_PHZMainLayer.m_headNode[0]:setTotalHuXi(v.m_totalBlc)
        else
            
            
            if g_PHZMainScene.m_seatID ~= -1 then
                local tempChairId = g_PHZMainScene:getViewChairId(v.seat_id)
                g_PHZMainLayer.m_headNode[tempChairId]:setVisible(true)
                require("hall.view.userInfoView.userInfoView"):upDateUserInfo(v.uid,{nickName = v.nickName,ip = v.ip,latitude = v.latitude,longitude = v.longitude})
                g_PHZMainLayer:isShowHuXiTxt(tempChairId)
                g_PHZMainLayer.m_headNode[tempChairId]:refreshPlayerInfo(v.portrait,v.uid,v.sex,v.nickName, v.ip, v.addres)
                g_PHZMainLayer.m_headNode[tempChairId]:refreshPlayer_FXScore(v.m_chips)
				g_PHZMainLayer.m_headNode[tempChairId]:setTotalHuXi(v.m_totalBlc)
                if pack.GAME_STATE == 0 and v.if_ready == 1 then
                    g_PHZMainLayer.m_headNode[tempChairId]:isShowZhunBeiIMG(true)
                end
            end
        end
    end

    if pack.GAME_STATE == 0 then return end
    for k,v in pairs(pack.playerlist) do
        local seat_id = v.seat_id
        if seat_id ~= -1 then
            if seat_id == g_PHZMainScene.m_seatID then
                if v.AIState == 1 then
                    g_PHZMainLayer:isShowTuoGuan( true )
                end
            end
        end
    end
    g_PHZMainScene.m_CardReady = true

    --胡息

    print("======我断线重连了=7777777777777==USER_INFO.uid==",g_PHZMainScene.m_seatID)
    print("pack.LeftTime==",pack.LeftTime)
    print("pack.m_CurOutCard==",pack.m_CurOutCard)
    print("pack.OutCardUserId==",pack.OutCardUserId)
    --轮到谁出牌
    if pack.LeftTime >= 1  then
        if pack.OutCardUserId == g_PHZMainScene.m_seatID then
            g_PHZMainLayer.m_headNode[0]:ShowTimerText(pack.LeftTime)
            g_PHZMainScene.m_bOutCard = true
            --显示滑动出牌
            g_PHZMainLayer:show_Action_Ready()

        else
            for k2,v2 in pairs(g_PHZMainScene.otherInfo) do
                if pack.OutCardUserId == v2.seat_id then
                    local wViewId = g_PHZMainScene:getViewChairId(v2.seat_id)
                    g_PHZMainLayer.m_headNode[wViewId]:ShowTimerText(pack.LeftTime)
                end
            end
        end
    end

    --显示谁出了牌
    if pack.m_CurOutCard > 0 then
        local tempData = {}
        tempData.seat_id = pack.OutCardUserId
        tempData.CardValue = pack.m_CurOutCard
        g_PHZMainScene:OnSubOutCard(tempData)
    end

    --显示谁摸了牌
    if pack.m_CurGetCard > 0 then
        g_PHZMainScene:OnSubSendCard(pack.m_nCurGetCarCardSeatId,pack.m_CurGetCard)
    end


    --显示出玩家谁是庄家
    g_PHZMainScene.m_bankerSeatID = pack.banker_seat_id
    local wViewId = g_PHZMainScene:getViewChairId(pack.banker_seat_id)
    --将所有的准备图片收起来,显示谁是庄家
    for i=0, pack.max_mount-1 do
        g_PHZMainLayer.m_headNode[i]:isShowZhunBeiIMG(false)
        if wViewId == i then
            g_PHZMainLayer.m_headNode[i]:isShowZhuangIMG(true)
        end 
    end  

    --初始化玩家手牌            
    g_CardScene:setCurHandCard(pack.HandCardDatas)  --初始化牌
    print("====重连玩家手牌====")
    -- dump(pack.HandCardDatas)

    --设置玩家底牌
    g_PHZMainScene.m_diCardCount = pack.diPaiCount
    g_PHZMainLayer.PHZUpNode:setDicardNum(pack.diPaiCount)

    print("玩家丢弃的牌")
    -- dump(pack.LastCarddata)
    --初始化玩家丢弃的牌
    for k, v in pairs(pack.LastCarddata) do
        local wViewId = g_PHZMainScene:getViewChairId(v.seat_id)
        for k1,v1 in pairs(v.cards) do
            if v1 ~= 0 then
                g_CardScene:drawQiCard(wViewId, v1)
            end
        end
    end

    --初始化玩家（提、跑、碰、吃、偎的牌）
    for k,v in pairs(pack.Carddata) do
        local wViewId = g_PHZMainScene:getViewChairId(v.seat_id)
        --提
        for k1,v1 in pairs(v.tiList) do
            print("==提提提提提提提提==",v1)
            local weaveItem = {}
            weaveItem.cbWeaveKind  = AK_SAO_EX
            weaveItem.cbCardCount  = 4
            weaveItem.cbCenterCard = v1
            weaveItem.cbCardList   = {v1,v1,v1,v1}
            weaveItem.weaveCard    = {v1,0x00,0x00,0x00}
            -- if g_PHZMainScene.m_seatID ~= v.seat_id then
            --     weaveItem.weaveCard = {0x00,0x00,0x00,0x00}
            -- end
            --插入新数据，删除旧字牌
            table.insert(g_CardScene.m_WeaveItem[wViewId],weaveItem)
        end

        --跑
        for k1,v1 in pairs(v.paoList) do
            print("==跑跑跑跑跑跑跑跑==",v1)
            local weaveItem = {}
            weaveItem.cbWeaveKind  = AK_DUO
            weaveItem.cbCardCount  = 4
            weaveItem.cbCenterCard = v1
            weaveItem.cbCardList   = {v1,v1,v1,v1}
            weaveItem.weaveCard    = {v1,v1,v1,v1}

            --插入新数据，删除旧字牌
            table.insert(g_CardScene.m_WeaveItem[wViewId],weaveItem)
        end

         --碰
        for k1,v1 in pairs(v.pengList) do
            print("==碰碰碰碰碰碰碰==",v1)
            local weaveItem = {}
            weaveItem.cbWeaveKind  = AK_PENG
            weaveItem.cbCardCount  = 3
            weaveItem.cbCenterCard = v1
            weaveItem.cbCardList   = {v1,v1,v1}
            weaveItem.weaveCard    = {v1,v1,v1}

            --插入新数据，删除旧字牌
            table.insert(g_CardScene.m_WeaveItem[wViewId],weaveItem)
        end

        --偎
        for k1,v1 in pairs(v.weiList) do
            -- print("==偎偎偎偎偎偎偎偎==",v1)
            local weaveItem = {}
            weaveItem.cbWeaveKind  = AK_SAO
            weaveItem.cbCardCount  = 3
            weaveItem.cbCenterCard = v1.cardvalue
            weaveItem.cbCardList   = {v1.cardvalue,v1.cardvalue,v1.cardvalue}
            weaveItem.weaveCard    = {v1.cardvalue,0x00,0x00}
            if wViewId == 0 then
                weaveItem.weaveCard    = {v1.cardvalue,0x00,0x00}
            else
                --if v1.cardType == 1 then
                weaveItem.weaveCard    = {v1.cardvalue,0x00,0x00}
                --end
            end
            if g_PHZMainScene.m_seatID ~= v.seat_id then
                weaveItem.weaveCard = {0x00,0x00,0x00}
            end
            --插入新数据，删除旧字牌
            table.insert(g_CardScene.m_WeaveItem[wViewId],weaveItem)
        end

        --吃
        for k1,v1 in pairs(v.chiList) do
            print("==偎偎偎偎偎偎偎偎==",v1)
            dump(v1)
            local weaveItem = {}
            weaveItem.cbWeaveKind  = AK_CHI
            weaveItem.cbCardCount  = 3
            weaveItem.cbCenterCard = v1.Cardbuf[2]
            weaveItem.cbCardList   = {v1.Cardbuf[3],v1.Cardbuf[2],v1.Cardbuf[1]}
            weaveItem.weaveCard    = {v1.Cardbuf[3],v1.Cardbuf[2],v1.Cardbuf[1]}

            --增加吃的牌做阴影
            weaveItem.showChi      = true

            --插入新数据，删除旧字牌
            table.insert(g_CardScene.m_WeaveItem[wViewId],weaveItem)
        end

        --bi
        for k1,v1 in pairs(v.biList) do

            local tempBiCardValue = v1.card

            for k2,v2 in pairs(v1.cardsList) do
                local weaveItem = {}
                weaveItem.cbWeaveKind  = AK_CHI
                weaveItem.cbCardCount  = 3
                weaveItem.cbCenterCard = v2.Cardbuf[2]
                weaveItem.cbCardList   = {v2.Cardbuf[1],v2.Cardbuf[2],v2.Cardbuf[3]}
                weaveItem.weaveCard    = {v2.Cardbuf[1],v2.Cardbuf[2],v2.Cardbuf[3]}

                weaveItem.cbCardList = g_CardScene:sortBiCardList(weaveItem.cbCardList,tempBiCardValue)
                weaveItem.weaveCard = g_CardScene:sortBiCardList(weaveItem.cbCardList,tempBiCardValue)

                weaveItem.isBi = true
                weaveItem.biCardNumber = g_CardScene:getBiCardValueNumber(weaveItem.cbCardList,tempBiCardValue)

                --插入新数据，删除旧字牌
                table.insert(g_CardScene.m_WeaveItem[wViewId],weaveItem)
            end
        end
        g_CardScene:restoreWeaveCard(wViewId)

        --判断是否有听牌显示
        -- dump(g_PHZMainScene.otherInfo)

    end
    --判断是否有听牌显示
    print("===906==判断是否有听牌显示")
    -- 记录开始时间
    local starttime = os.clock();                           --> os.clock()用法
    print(string.format("start time : %.4f", starttime));
    -- 记录结束时间
    local endtime = os.clock();                           --> os.clock()用法
    print(string.format("end time   : %.4f", endtime));
    print(string.format("cost time  : %.4f", endtime - starttime))

    g_PHZMainLayer:showTingNode()

    if g_PHZMainLayer.tingAuto then
        local tingData = {}
        for idx,data in ipairs(pack.tingCards) do
            tingData[data.card] = data.tingHuCards
        end
        g_CardScene:setTings(tingData)
        local tingHuCards = pack.tingHuCards
        g_PHZMainLayer.TingView:setTing2(tingHuCards)
    end
end


--组局解散相关
--没有此房间，解散房间失败
function PHZReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)

    --dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")
    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")
end

function PHZReceiveHandle:getUserInfoLstToDisband(applyId)
    dump(g_PHZMainScene.otherInfo, "getUserInfoLstToDisband")
    local userLst = {USER_INFO}
    for i, v in pairs( g_PHZMainScene.otherInfo or {} ) do
        table.insert(userLst, v)
    end
    local result = {} 
    for i, v in ipairs( userLst ) do
        local tmp = {}
        tmp.state = v.uid == applyId and 3 or 2
        tmp.userId = v.uid
        tmp.userName = v.nickName
        tmp.userUrl = v.portrait or v.icon_url

        table.insert(result, tmp)
    end

    return result
end

--广播当前组局解散情况
function PHZReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)
    dump(pack, "-----广播当前组局解散情况-----")
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
        if g_PHZMainScene.otherInfo ~= nil and g_PHZMainScene.otherInfo[applyId] then
            applyer_info = g_PHZMainScene.otherInfo[applyId]
            dump(applyer_info, "-----广播当前房间情况applyer_info-----")
            if applyer_info ~= nil then
                local nickName = applyer_info.nickName
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
    if g_PHZMainScene.otherInfo ~= nil  then
        for k,v in pairs(g_PHZMainScene.otherInfo) do
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
                local nickName = v.nickName
                if nickName ~= nil then
                    player_table["playerName"] = nickName
                    if isAgree == 1 then
                        player_table["state"] = "同意"
                    else
                        player_table["state"] = "等待选择"
                    end
                    player_table["icon"] = v.portrait 
                    table.insert(disband_table, player_table)
                end
            end
        end
    end

    local function agree_disband(value)
        phzServer:C2G_CMD_REPLY_DISSOLVE_ROOM(value)
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
function PHZReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

    --dump(pack, "-----广播桌子用户请求解散组局-----")

    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")

end

--广播桌子用户成功解散组局
function PHZReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)
    print("-----广播桌子用户成功解散组局-----")
    if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
	end
end


--广播桌子用户解散组局 ，解散组局失败
function PHZReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)
    -- dump(pack, "-----广播桌子用户解散组局 ，解散组局失败-----")
    local userLst = {USER_INFO}
    for i, v in pairs( g_PHZMainScene.otherInfo or {} ) do
        table.insert(userLst, v)
    end
    local name = ""
    for i, v in ipairs( userLst ) do
        if pack.rejectId == v.uid then
            name = v.nick or v.nickName
        end
    end

    local rejectId = pack.rejectId
    if rejectId == USER_INFO["uid"] then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
    else
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2,  name .. "拒绝解散房间")
    end

end

--服务器广播玩家退出
function PHZReceiveHandle:SVR_BROADCAST_USER_LEAVEROOM(pack)
    print("=====广播玩家退出==uid=1==",pack.uid)
    print("=====广播玩家退出==uid===",pack.uid)
    print("=====广播玩家退出==uid===",pack.uid)
    print("==USER_INFO[uid]==",USER_INFO["uid"])
    
    if GAME_SYBP_MODETYPE == 1 and g_PHZMainScene.m_isGameOver then return end

    local uid = pack.uid
    local wViewId = 0
    if uid ~= USER_INFO.uid and g_PHZMainScene.otherInfo[uid] then
        wViewId = g_PHZMainScene:getViewChairId(g_PHZMainScene.otherInfo[uid].seat_id)
    end
    
    --处理自己退出
	print('xxxx2222 ',uid, USER_INFO["uid"])
    if  uid == USER_INFO["uid"] then 
        require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
        HEART_BEAT_TID = 0
		print('xxxx')
    else
        g_PHZMainScene.otherInfo[uid] = nil
        g_PHZMainLayer.m_headNode[wViewId]:setVisible(false)
    end
    g_PHZMainLayer:showGPSButton() 
end

--广播玩家站起 1032
function PHZReceiveHandle:BROADCAST_USER_STAND_UP(pack)

    dump(pack, "------广播玩家站起1032------")

    print("=====BROADCAST_USER_STAND_UP=======",pack.uid)

    if  isGoldGame == 1 and HAS_RECEIVE_GROUP_RESULT == true then
        return
    end

    local uid = pack.uid

    local wViewId = 0
    if uid ~= USER_INFO.uid then
        wViewId = g_PHZMainScene:getViewChairId(g_PHZMainScene.otherInfo[uid].seat_id)
    end

    if  uid == USER_INFO["uid"] then
        g_PHZMainLayer:isShowZhunBeiIMG(true)

        MY_SEAT_ID = -1

    elseif  MY_SEAT_ID < 0 then  --别人站起，自己也站着的时候
        g_PHZMainLayer:isShowZhunBeiIMG(true)
    end
 
    -- if uid ~= USER_INFO["uid"] then
        g_PHZMainScene.otherInfo[uid] = nil
        g_PHZMainLayer.m_headNode[wViewId]:setVisible(false)
    -- end

end

--接收服务器返回的组局信息
function PHZReceiveHandle:SERVER_CMD_MESSAGE(pack)
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
            elseif  msgType == "EmojiArmatureView" then   --文字聊天
                self:SVR_MSG_EMOJI_ARMATURE(msg)
            end

            if device.platform == "ios" then

                if msgType == "voice" then
                    dump("voice", "-----接收服务器返回的组局信息-----")
                    print("msg.uid",msg.uid)
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
                    print("msg.uid",msg.uid)
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
function PHZReceiveHandle:SVR_MSG_EMOJI_ARMATURE(pack)

    local EmojiArmatureView = SCENENOW.scene:getChildByName("EmojiArmatureView")
    if not EmojiArmatureView then
        return
    end
    local from_id = pack.uid
    local to_uid = pack.to_uid
    local emojiType = pack.type
    local from_seatId = 0
    if from_id == USER_INFO.uid then
        from_seatId = g_PHZMainScene.m_seatID
    else
        from_seatId = g_PHZMainScene.otherInfo[from_id].seat_id
    end
    local to_seatId = 0
    if to_uid == USER_INFO.uid then
        to_seatId = g_PHZMainScene.m_seatID
    else
        local otherInfo = g_PHZMainScene.otherInfo[to_uid] or {}
        to_seatId = otherInfo.seat_id
        if not to_seatId then
            return
        end
    end

    local from_tempChairId = g_PHZMainScene:getViewChairId(from_seatId)
    local to_tempChairId = g_PHZMainScene:getViewChairId(to_seatId)
    local toPos = g_PHZMainLayer.m_headNode[to_tempChairId].worldpoint
    local fromPos = g_PHZMainLayer.m_headNode[from_tempChairId].worldpoint
	
    EmojiArmatureView:showAnimi(toPos, fromPos, emojiType)
end

------------------------------------------------------------------
function PHZReceiveHandle:showExpression(msg)
    local uid_from = tonumber(msg["uid_from"]) or 1
    local uid_to = tonumber(msg["uid_to"]) or 1
    local expressionType = tonumber(msg["expressionType"]) or 1
    
    ---------------------------------不同游戏需修改的部分----------------------------
    -- --通过UID获取seatId
    -- local seatId_from = DDZ_SEAT_TABLE[uid_from] or 2
    -- local seatId_to =  DDZ_SEAT_TABLE[seatId_to] or 0

    --制定座位号对应的动画播放起始和结束的大概位置
    -- local PLAYER_HEADS_POSITION_TABLE = PLAYER_HEADS_POSITION_TABLE or {}
    ------------------------------------------------------------------------------------
    local from_x = 100
    local from_y = 100

    local to_x   = 600
    local to_y   = 500

    require("hall.view.animView.animView"):ShowAnimationByPosition(from_x, from_y,to_x,to_y,expressionType)        
end

function PHZReceiveHandle:showTextMessage(pack)

    local s= g_PHZMainLayer:getChildByName("faceUI")
    -- dump(g_PHZMainScene.otherInfo)
    -- print(uid)
    local uid = pack.uid
    local sex = 0
    local seatId = 0
    if uid == USER_INFO.uid then
        sex = USER_INFO.sex
        seatId = g_PHZMainScene.m_seatID
    else
        sex = g_PHZMainScene.otherInfo[uid].sex
        seatId = g_PHZMainScene.otherInfo[uid].seat_id
    end

    local wViewId = g_PHZMainScene:getViewChairId(seatId)

    local isLeft = true
    if wViewId == 2 then
        isLeft = false
    end
  
    local node_head = g_PHZMainLayer.m_headNode[wViewId].node_tips 

    s:showGetText(uid,pack.textMessage,tonumber(sex),node_head, isLeft)  
end


--聊天
function PHZReceiveHandle:SVR_MSG_FACE(pack)

    local s= g_PHZMainLayer:getChildByName("faceUI")

    local uid = pack.uid
    local emojiType = pack.type


    local sex = 0
    local seatId = 0
    if uid == USER_INFO.uid then
        sex = USER_INFO.sex
        seatId = g_PHZMainScene.m_seatID
    else
        sex = g_PHZMainScene.otherInfo[uid].sex
        seatId = g_PHZMainScene.otherInfo[uid].seat_id
    end

    local wViewId = g_PHZMainScene:getViewChairId(seatId)

    local isLeft = true
    if wViewId == 2 then
        isLeft = false
    end
  
    local node_head = g_PHZMainLayer.m_headNode[wViewId].node_tips 
    if tonumber(sex) >= 0 then
        s:showGetFace(uid, emojiType, tonumber(sex), node_head, isLeft)
    end

end
--5001
function PHZReceiveHandle:BROADCAST_ERROR_TIPS(pack)

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
		
		[100] = "网络异常，吃操作无效",
    }

    if  errorCode == 18 then
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

    if tbErrorCode[errorCode] then
        require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[errorCode])
    else
        require("hall.GameTips"):showTips("提示", "", 3, "未知的错误")
    end
	
	if errorCode == 100 then
        require("hall.HallServer"):loginGameNew(USER_INFO.GroupLevel, USER_INFO.tid, USER_INFO.activity_id, 1)
    end

end
function PHZReceiveHandle:SVR_QUIT()
    --phzServer:LoginRoom(USER_INFO["tid"],USER_INFO["seat_id"],USER_INFO["activity_id"])
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function PHZReceiveHandle:SVR_GROUP_BILLBOARD(pack)
    print("=======SVR_GROUP_BILLBOARD=======")
    print("=======0000000000000000000=======")
    print("=======0000000000000000000=======")
    print("=======SVR_GROUP_BILLBOARD=======")
    g_PHZMainScene.m_isGameOver = true
end
function PHZReceiveHandle:SVR_LOGOUT_ROOM(pack)
    dump(pack,"用户离场")

end
function PHZReceiveHandle:SVR_SEND_WEI(pack)
    dump(pack,"SVR_SEND_WEI")
    -- if pack.flag == 1 then
    --     local callFunc = function()
    --     end
    --     local callBackCancel  = function()
    --         g_CardScene:backOutCard()

    --     end
    --     local data = {type = 2, title = "提示", content = "是否放跑？", callBackSure = callFunc,callBackCancel = callBackCancel}

    --     require("hall.tips.CommonTips"):showTips(data)
    -- else
    -- end
    g_CardScene:outCardYes()
end

--接收服务器放回的指定用户信息pack111
function PHZReceiveHandle:SVR_CHARGE_BROADCAST(pack)
    dump(pack,"pack111")
    local uid = pack.uid
    local userInfo = g_PHZMainScene.otherInfo[uid]
    if not (userInfo) then return end
    userInfo.m_chips = userInfo.m_chips + pack.chargeCoins
    local tempChairId = g_PHZMainScene:getViewChairId(userInfo.seat_id)
    g_PHZMainLayer.m_headNode[tempChairId]:refreshPlayer_FXScore(userInfo.m_chips)
end

function PHZReceiveHandle:SVR_TEST_CARD(pack)
	local text = "成功"
    if pack.res == 1 then
    else
		text = "失败"
	end
	viewMgr:showTip({text = text})
end

function PHZReceiveHandle:SVR_REQ_TEST_CARDS(pack)
    dump(pack,"SVR_REQ_TEST_CARDS")
    local function CLI_SEND_TEST_CARD_FUNC(card)
        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_TEST_CARD)
        :setParameter("card", card)
        :build()
        bm.server:send(pack)
    end
    if pack.cardCount > 0 then
        local ZiPaiTest = require("hall.common.test.ZiPaiTest").new(pack.cards, CLI_SEND_TEST_CARD_FUNC, CardConfig, 1)
        local idx = ViewBase:getZOrderByChilds(SCENENOW.scene)
        SCENENOW.scene:addChild(ZiPaiTest, idx)
    end

end

function PHZReceiveHandle:SVR_PLAYER_AI_STATE(pack)
    local seat_id = pack.seat_id
    if seat_id == g_PHZMainScene.m_seatID then
        if pack.AIState == 1 then
            g_PHZMainLayer.PHZOprorateNode:setVisible(false)
            g_PHZMainLayer:isShowTuoGuan( true )
        else
            g_PHZMainLayer:isShowTuoGuan( false )
        end
    end
end

return PHZReceiveHandle
