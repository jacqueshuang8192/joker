local SendHandle = require("jchuapai.src.handle.SendHandle")
local OprorateBtn = require("jchuapai.src.view.OprorateBtn")
local CardView = require("jchuapai.src.view.CardView")
local GameResult = require("jchuapai.src.view.GameResult")
local faceUI = require("hall.FaceUI.faceUI")
local HuaPaiTest = require("jchuapai.src.view.HuaPaiTest")
local GPSShowLayer = require("hall.GPSShowLayer")
local GameSceneView = class("GameSceneView", function()
    if device.platform == "ios" then
        if isiOSVerify then
            return cc.CSLoader:createNode("jchuapai/res/GameScene/GameScene.csb")
        else
            return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "jchuapai/res/GameScene/GameScene.csb")
        end
    else
        return cc.CSLoader:createNode("jchuapai/res/GameScene/GameScene.csb")
    end
    -- return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath().."jchuapai/res/GameScene/GameScene.csb")
end)

function GameSceneView:ctor()
    GameUtils.setNodeNameBindObj(self)
    self:setNodeEventEnabled(true)
    self:initUI()
    self:initEvent()
    require("hall.util.GameMenu"):getDeviceInfo(self.hall.device_info_plane)
    self:setRoomId("000000")
    self:setRound(0, 0)

    self.faceUI = faceUI.new()
    self.faceUI:setHandle(SendHandle)
    self:addChild(self.faceUI, 9999)
    self.faceUI:setName("faceUI")
    self.CardView = CardView.new(self)
    self.OprorateBtn = OprorateBtn.new(self, self.CardView)
    self.CardView:setParam(self.OprorateBtn)
end

function GameSceneView:initUI()
    -- display.doLayout(self.hall,self.bg)
    -- display.doLayout(self.players)
    -- ccui.Helper:doLayout(self.cards_vw)
    display.doLayout(self)
    self.take_bg = self.take_bg:hide()
    self.btn_cancelTuoGuan = self.take_bg.btn_cancelTuoGuan
    self.btn_chat = self.hall.btn_chat:hide()
    self.btn_tuoGuan = self.hall.btn_tuoGuan
    self.btn_voice = self.hall.btn_voice:hide()
    self.btn_menu = self.hall.btn_menu
    self.btn_share = self.hall.btn_share
    self.btn_gameConfig = self.hall.btn_gameConfig
    self.btn_copyRoom = self.hall.btn_copyRoom
    self.btn_ready = self.hall.btn_ready
    self.btn_start = self.hall.btn_start
    self.btn_cardType = self.hall.btn_cardType
    self.btn_gps = self.hall.btn_gps:show()
    self.img_line = self.hall.img_line:hide()
    self.txt_gameConfig = self.hall.txt_gameConfig:setString("")
    self.player_1 = self.players.player_1:hide()
    self.player_2 = self.players.player_2:hide()
    self.player_3 = self.players.player_3:hide()
    
    self.player_1 = require("jchuapai.src.view.UserInfoView").new(self.player_1)
    self.player_2 = require("jchuapai.src.view.UserInfoView").new(self.player_2)
    self.player_3 = require("jchuapai.src.view.UserInfoView").new(self.player_3)
    
	if g_388.isHua_388 then--这是柳叶花牌
		self.btn_cardType:loadTexture("jchuapai/res/GameScene/btn_9.png")
	else--这是普通牌
		self.btn_cardType:loadTexture("jchuapai/res/GameScene/btn_8.png")
    end
    self:isShowBtnReady( false )
    self:isShowBtnStart( false )
    self:isShowBtnShare( false )
    self:isShowBtnCopy( false )
end

function GameSceneView:initEvent()
    self.btn_chat:onClick(handler(self, self.onClick_chat), true)
    self.btn_menu:onClick(handler(self, self.onClick_menu), true)
    self.btn_voice:onClick(handler(self, self.onClick_voice), true)
    self.btn_share:onClick(handler(self, self.onClick_share), true)
    self.btn_ready:onClick(handler(self, self.onClick_ready), true)
    self.btn_start:onClick(handler(self, self.onClick_start), true)
    self.btn_cardType:onClick(handler(self, self.onClick_cardType), true)
    self.btn_gameConfig:onClick(handler(self, self.onClick_gameConfig), true)
    self.btn_gps:onClick(handler(self, self.onClick_gps), true)
    self.btn_cancelTuoGuan:onClick(handler(self, self.onClick_cancelTuoGuan), true)
    self.btn_tuoGuan:onClick(handler(self, self.onClick_tuoGuan), true)
    require("hall.util.GameMenu"):registCopyRoomIdFunc(self.btn_copyRoom, self.roomId)
end

function GameSceneView:clearData()
    self.CardView:clearData()
    self.OprorateBtn:clearData()
    self.player_1:clearData()
    self.player_2:clearData()
    self.player_3:clearData()
    self:isShowTuoGuan( false )

end

function GameSceneView:starGame()
    self.player_1:isShowTongCountd(true, 0)
    self.player_2:isShowTongCountd(true, 0)
    self.player_3:isShowTongCountd(true, 0)
    self.player_1:isShowHuCountd(true, 0)
    self.player_2:isShowHuCountd(true, 0)
    self.player_3:isShowHuCountd(true, 0)
    self:isShowBtnReady( false )
    if not tolua.isnull(self.GameResult) then
        self.GameResult:removeSelf()
    end
end

function GameSceneView:setGameResult( data )
    local roomId = "房间号:"..self.roomId
    local round = self.hall.device_info_plane.txt_round:getString()
    self.baseChip = self.baseChip or 1
    local str = roomId.." "..round.." 底分:"..self.baseChip
    self.GameResult = GameResult.new(data, str):addTo(self)
    local size = self:getContentSize()
    self.GameResult:setAnchorPoint(0.5, 0.5)
    self.GameResult:setPosition(size.width / 2, size.height / 2)

end

function GameSceneView:hideAllPlayerOutCard()
    self.player_1:isShowOutCard(false)
    self.player_2:isShowOutCard(false)
    self.player_3:isShowOutCard(false)
end

function GameSceneView:hideAllPlayerLight()
    self.player_1:isShowLight(false)
    self.player_2:isShowLight(false)
    self.player_3:isShowLight(false)
end

function GameSceneView:isShowChuState( isShow, isHideAllPlayerOutCard )
    if isShow then
        g_388.isCanChuCard = true
        self.OprorateBtn:showChuBtn()
        self.CardView:isShowMask( false )
    else
        g_388.isCanChuCard = false
        self.OprorateBtn:clearData()
    end
end

function GameSceneView:isShowLine( isShow )
    if g_388.isCanChuCard and isShow then
        self.img_line:show()
    else
        self.img_line:hide()
    end
end

function GameSceneView:isShowBtnReady( isShow )
    self.btn_ready:setVisible(isShow)
end

function GameSceneView:isShowTuoGuan( isShow )
    self.take_bg:setVisible(isShow)
end

function GameSceneView:isShowBtnStart( isShow )
    self.btn_start:setVisible(isShow)
end

function GameSceneView:isShowBtnShare( isShow )
    self.btn_share:setVisible(isShow)
end

function GameSceneView:isShowBtnCopy( isShow )
    self.btn_copyRoom:setVisible(isShow)
end

function GameSceneView:showGPSButton()
    local temptab = {}
    for k,v in pairs(g_388.userInfos) do
        table.insert(temptab,v)
    end
    local isWarning = 0
    for i=1,#temptab do
        for j=i+1,#temptab do
            if temptab[i].latitude and temptab[j].latitude and temptab[i].longitude and temptab[j].longitude and calculateDistance(temptab[i].latitude, temptab[j].latitude, temptab[i].longitude,temptab[j].longitude) <= 100 then
                isWarning = isWarning + 1
                break
            end
        end
    end
    if isWarning > 0 then
        self.btn_gps.img_safe:setVisible(false)
        self.btn_gps.img_warnning:setVisible(true)
    else
        self.btn_gps.img_safe:setVisible(true)
        self.btn_gps.img_warnning:setVisible(false)
    end
    self.btn_gps:setVisible(true)
end

function GameSceneView:onClick_chat(event)
    self:loadGameMsgLayer()
end

function GameSceneView:onClick_menu(event)
    self:loadMoreFuncLayer()
end

function GameSceneView:onClick_voice(event)
    local voice_bt_worldpoint = (self.btn_voice:getParent()):convertToWorldSpace(self.btn_voice:getPosition())
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        VoiceRecordView:addVoiceRecordEvent(self.btn_voice,999)
    else
        self.btn_voice:setVisible(false)
        VoiceRecordView:showView(voice_bt_worldpoint.x,voice_bt_worldpoint.y,999)
    end
end

function GameSceneView:onClick_share(event)
    local paras = {}
    paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
    paras["imagePath"] = "url"
    paras["name"] =  g_388.GameName.."房号：" .. self.roomId
    paras["showType"] = 2;
    paras["url"] = appDownLoadAddress
    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(SCENENOW["scene"], 9999999)
    end
end

function GameSceneView:onClick_ready(event)
    self.btn_ready:hide()
    SendHandle:CLI_READY_GAME(1)
    self:clearData()
end

function GameSceneView:onClick_start(event)
    
end

function GameSceneView:onClick_gameConfig(event)
    if isOpenControl then
        SendHandle:CLI_REQ_TEST_CARDS()
    else
        require("hall.util.GameMenu"):showConfigPanel(g_388.gameConfigTable)
    end
end

function GameSceneView:onClick_cancelTuoGuan(event)
    SendHandle:CLI_PLAYER_CANCELAUTO(0)
end

function GameSceneView:onClick_tuoGuan(event)--点击托管
    SendHandle:CLI_PLAYER_CANCELAUTO(1)
end

function GameSceneView:onClick_gps(event)
    local gpsLayer = GPSShowLayer.new()
    self:addChild(gpsLayer,1000)
    local temptab = {}
    for k,v in pairs(g_388.userInfos) do
        table.insert(temptab,v)
    end
    gpsLayer:setInfo(temptab)
end

function GameSceneView:onClick_cardType(event)
	g_388.isHua_388 = not g_388.isHua_388
	cc.UserDefault:getInstance():setBoolForKey("isHua_388", g_388.isHua_388)
	if g_388.isHua_388 then--这是柳叶花牌
		self.btn_cardType:loadTexture("jchuapai/res/GameScene/btn_9.png")
	else--这是普通牌
		self.btn_cardType:loadTexture("jchuapai/res/GameScene/btn_8.png")
    end
    local idx = 0
    for k,node in pairs(g_388.cardsAllNode) do
        -- if tolua.isnull(node) then 
        --     g_388.cardsAllNode[k] = nil
        -- else
        if node.type_ ~= "back" then
            node:changeImg()
        else
            g_388.cardsAllNode[k] = nil
        end
       
    end
    self.player_1:changeImg()
    self.player_2:changeImg()
    self.player_3:changeImg()
end

function GameSceneView:setRoomId( roomId )
    self.roomId = roomId
    self.hall.device_info_plane.txt_room:setString("房间号:"..roomId)
end

function GameSceneView:setRound( round, totalRound )
    self.round = round
    self.totalRound = totalRound
    self.hall.device_info_plane.txt_round:setString(round.."/"..totalRound)
    local isShow = round <= 0
    self:isShowBtnCopy(isShow)
    self:isShowBtnShare(isShow)
end

function GameSceneView:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
        self:addChild(self.gameMsgLayer)
    else
        self.gameMsgLayer:showContentByType(1)
    end
    self.gameMsgLayer:setVisible(true)
end

function GameSceneView:getToSendFaceAndTxtFuncs()
    local data = {}
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function GameSceneView:loadMoreFuncLayer()
    if tolua.isnull(self.moreFuncLayer) then
        self.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
        self:addChild(self.moreFuncLayer, 99999)
        local data = {}
        data.quitRoom = handler(self, self.quitRoom)
        data.disbandRoom = handler(self, self.disbandRoom)
        self.moreFuncLayer:registerDisbandFuncs(data)
    else
        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end
    self.moreFuncLayer.btnDisbandRoom:setVisible(true)
end

function GameSceneView:sendFaceByIdx(id, msgType, to_uid)
    SendHandle:CLI_MSG_FACE(id, msgType, to_uid)
end

function GameSceneView:disbandRoom()
    SendHandle:C2G_CMD_DISSOLVE_ROOM()
end

function GameSceneView:rejectDisband()
    SendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function GameSceneView:agreeDisband()
    SendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function GameSceneView:quitRoom()
    SendHandle:quitRoom()
end

function GameSceneView:showGameConfig(gameConfigtbl)
    local gameConfigStr = ""
	for k, v in pairs(gameConfigtbl) do
        if k == "pay_type" then
            if v == "fangka" then
                gameConfigStr = gameConfigStr .. "房主开房 "
            elseif v == "AA" then
                gameConfigStr = gameConfigStr .. "AA开房 "
            end
        elseif k == "maxSeatCount" then
            if v == 2 then
                gameConfigStr = gameConfigStr .. "2人 "
            elseif v == 3 then
                gameConfigStr = gameConfigStr .. "3人 "
            end
        elseif k == "asdf" then
            local canPickStr= string.split(v, ",")
            for _, x in pairs(canPickStr) do
                if x == '1' then
                    gameConfigStr = gameConfigStr .. "全名堂 "
                elseif x == '2' then
                    gameConfigStr = gameConfigStr .. "大团圆 "
                end
            end
        end
    end
    self.baseChip = gameConfigtbl.baseChip
    gameConfigStr = gameConfigStr .. "底分=" .. self.baseChip .." "
    USER_INFO["gameConfig"] = "玩法: "..gameConfigStr
	g_388.gameConfigTable = {
        {
            ["游戏名"] = g_388.GameName, 
            ["底分"] = self.baseChip
        }, 
        {["特殊玩法"] = gameConfigStr},
        {["版本号"] = g_388.version}
    }
    self.txt_gameConfig:setString(gameConfigStr)

    --模式
    if gameConfigtbl.model ~= nil then
        g_388.gameModel = gameConfigtbl.model
    end
end

function GameSceneView:settlement(pack)
    --去掉提示弹框
    local DisbandLayer_tips = SCENENOW.scene:getChildByName("DisbandLayer_tips")
    if DisbandLayer_tips then
        DisbandLayer_tips:removeSelf()
    end
    local data = {}
    data.resultSceneType = 1      --战绩界面展示选择，1为长条形，2为方块形
    data.invote_code = self.roomId      --房间号
    data.fenchang = BASE_CHIP            --分场
    data.round = self.round.."/"..self.totalRound --.."/"..GROUP_TOTAL_ROUND                  --局数
    data.date = os.date("%Y-%m-%d-%H:%M")    --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
    data.activity_id = USER_INFO.activity_id;
    data.resultData = {}
    for idx, user_info in ipairs(pack.player_info) do
        local uid = user_info.uid
        local user_result = {}             --玩家数据实体
        user_result.uid = uid
        user_result.nick = g_388.userInfos[uid].nickName        --昵称
        user_result.icon_url = g_388.userInfos[uid].portrait        --头像链接
        user_result.sex = g_388.userInfos[uid].sex               --性别
        user_result.isRoomOwer = g_388.OwnerID == uid and 1 or 0        --是否为房主，1是，非1或不填不是
        user_result.total = user_info.m_totalBlc        --总输赢分
        user_result.gameDetail = {}       --游戏详情数组

        for k,v in pairs(user_info.huxilist) do
            local strHuXi =v
            strHuXi =strHuXi/100
            if strHuXi > 0 then
                strHuXi = "+"..strHuXi
            end
            local gameDetail = {}
            gameDetail.showName = "第"..k.."局"
            gameDetail.value = strHuXi
            table.insert(user_result.gameDetail, gameDetail)
        end
        table.insert(data.resultData, user_result)
    end

    local share_action = function(event)
        local paras = {}
        paras.showType = 2;
        paras.desc =  USER_INFO.gameConfigMsg or " "
        paras.imagePath = "screen"
        paras.name = "分享结果"
        paras.url = appDownLoadAddress
        local shareLayer = require("hall.share.ShareLayer").new(paras)
        if shareLayer then
            shareLayer:addTo(SCENENOW["scene"],9999999)
        end
    end

    --再来一局
    local extend_action = function(event)
        require("hall.groudgamemanager"):extend_freegame(USER_INFO.uid, USER_INFO.activity_id, "jchuapai.gameScene")
    end
    local backHall_action = function(event)
        USER_INFO.gameConfig = ""
        require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
    end
    require("hall.settlement.settlement").new(data, backHall_action, share_action, nil, extend_action)
end

function GameSceneView:setZiPaiTest( pokers )
    if not tolua.isnull(self.HuaPaiTest) then
        self.HuaPaiTest:removeSelf()
    end
    self.HuaPaiTest = HuaPaiTest.new(pokers):addTo(self)
    local size = self:getContentSize()
    self.HuaPaiTest:setAnchorPoint(0.5, 0.5)
    self.HuaPaiTest:setPosition(size.width / 2, size.height / 2)
end

return GameSceneView
