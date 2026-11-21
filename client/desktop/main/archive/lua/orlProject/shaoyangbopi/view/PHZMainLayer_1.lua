local scheduler = require("framework.scheduler")
local phzServer = import("shaoyangbopi.handle.PHZSendHandle")
local GameLogic = require("shaoyangbopi.logic.GameLogic")
local CardConfig = require("shaoyangbopi.logic.CardConfig")
local CardSprite = require("shaoyangbopi.models.CardSprite")

local CardLayer = require("shaoyangbopi.view.CardLayer")
local GameTouchLayer = require("shaoyangbopi.view.GameTouchLayer")
local ChiCardLayer = require("shaoyangbopi.view.PHZChiCardLayer")
local PHZOtherCardLayer = require("shaoyangbopi.view.PHZOtherCardLayer")
local ResultLayer = require("shaoyangbopi.view.PHZResultLayer")
local PHZAllResultLayer = require("shaoyangbopi.view.PHZAllResultLayer")
local TingLayer = require("shaoyangbopi.view.PHZTingCardNode")
local TingView = require("shaoyangbopi.view.TingView")
local PHZ_Ting = require("shaoyangbopi.PHZ_Ting")
local GPSShowLayer = require("hall.GPSShowLayer")
local PHZMainLayer = class("PHZMainLayer", function ()
	return display.newLayer()
end)

PHZMainLayer.PLAYER_NUM = 3

PHZMainLayer.CARDLAYER_TAG = 8
PHZMainLayer.OPRORATENODE_TAG = 10
PHZMainLayer.CHICARD_TAG = 11
PHZMainLayer.OTHERCARD_TAG = 12
PHZMainLayer.RESULT_TAG = 99998
PHZMainLayer.TING_CARD_TAG = 13
PHZMainLayer.DISTANCE_TAG = 14
PHZMainLayer.QIEHUAN_TAG = 14
PHZMainLayer.MENU_TAG = 5
PHZMainLayer.ALLRESULTLAYER_TAG = 99999
PHZMainLayer.SETTING_TAG = 8

PHZMainLayer.TAG_BTN_SETTING = 5
PHZMainLayer.TAG_BTN_SHARE = 8
PHZMainLayer.READY_POS = cc.p(1061,240)

function PHZMainLayer:ctor()
	g_PHZMainLayer = self
	self:setNodeEventEnabled(true)
    self.cardConfig_ = CardConfig:new()
	self:clearNodeToNil()

	self:initUI()
end


--设置在mainlayer上面的node全部设置为nil（空）
function PHZMainLayer:clearNodeToNil()
	self.m_downNode = nil
	self.m_upNode = nil
	
	--------player------
	self.m_headNode = {}
	self.m_txtHuxi = {}

	g_CardScene = nil
	g_TouchLayer = nil
end

function PHZMainLayer:clearData()
	self:clearNodeToNil()
end

function PHZMainLayer:onEnter()
end

function PHZMainLayer:onExit()
	--self:clearData()

	if self.delayHandler ~= nil then
		scheduler.unscheduleGlobal(self.delayHandler)
		self.delayHandler = nil
	end
	
	if g_PHZChiCardLayer ~= nil then
		g_PHZChiCardLayer:removeFromParent()
		g_PHZChiCardLayer = nil
	end

end

--------------------------------------init UI --------------------------------
function PHZMainLayer:initUI()
    self.m_GameLogic = GameLogic:new()
	self.m_mainLayer = cc.CSLoader:createNode("shaoyangbopi/res/PHZMainLayer.csb")
	self:addChild(self.m_mainLayer)
	GameUtils.setNodeNameBindObj(self.m_mainLayer)
	DESIGN_SCREEN_WIDTH  = 1280
	DESIGN_SCREEN_HEIGHT = 720
	SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
	SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
	self.m_mainLayer:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH, SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
	self.txt_gameConfig = self.m_mainLayer.txt_gameConfig:setString("")

	self.take_bg = self.m_mainLayer.take_bg:hide()
    self.btn_cancelTuoGuan = self.m_mainLayer.take_bg.btn_cancelTuoGuan
	self.btn_tuoGuan = self.m_mainLayer.btn_tuoGuan
	self.btn_tuoGuan:onClick(function(  )
		phzServer:CLI_PLAYER_CANCELAUTO(1)
	end)
	self.btn_cancelTuoGuan:onClick(function(  )
		phzServer:CLI_PLAYER_CANCELAUTO(0)
	end)
	isTuoGuan = false

	self.take_bg:setZOrder(99)

    ccui.Helper:doLayout(self.m_mainLayer)
	self.pnl_line = self.m_mainLayer:getChildByName("img_xian")
	self.pnl_line:setVisible(false)
	self.img_ready = self.m_mainLayer:getChildByName("img_ready_act")
	self.img_ready:setVisible(false)
	self:initHuXiTxt()
	self:initButtonUI()
	self:initDownNode()
	self:initUpNode()
	self:initLPlayerNode()
	self:initRPlayerNode()
	self:initOporateNode()

	self:initHeadNode()

	self:initCardScene()
	self:initTouchLayer()
	self.TingView = TingView.new(self.m_mainLayer.ting_vw)
	-- self.m_head_move_node = self.m_mainLayer:getChildByName("Sprite_2")
	-- self.m_head_move_node:setVisible(false)

	self.HeadMoveNode = cc.CSLoader:createNode("shaoyangbopi/res/PHZHeadMove.csb"):addTo(self)
    self.HeadMoveNode:setName("headLayer")
    self.HeadMoveNode:setLocalZOrder(15)
    self.HeadMoveNode:setPosition(cc.p(1050,300))
    self.HeadMoveNode:setVisible(false)

   	local  action = cc.CSLoader:createTimeline("shaoyangbopi/res/PHZHeadMove.csb")
    self.HeadMoveNode:runAction(action)
    action:gotoFrameAndPlay(0,true)
	self.m_mainLayer.btn_menu:onClick(function(event)
        self:loadMoreFuncLayer()
	end)
	local idx = ViewBase:getZOrderByChilds(self)
	self.m_mainLayer.btn_menu:setLocalZOrder(idx)
	self.m_mainLayer.btn_yuyin:setLocalZOrder(idx+1)
	self.m_mainLayer.btn_xinxi:setLocalZOrder(idx+2)
	local EmojiArmatureView = require("hall.EmojiArmatureView.EmojiArmatureView"):newEmojiArmatureView(self:getToSendFaceAndTxtFuncs(), g_PHZMainScene)
	EmojiArmatureView:setLocalZOrder(idx)
	dump()

	---gps按钮
    local gpsBtn = self.m_mainLayer:getChildByName("btn_gps")
	gpsBtn:setVisible(false)
	self.tingAuto = true
    gpsBtn:onClick(function(event)
		local idx = ViewBase:getZOrderByChilds(self)
		local gpsLayer = GPSShowLayer.new()
		self:addChild(gpsLayer, idx)
		local temptab = {}
		for k,v in pairs(g_PHZMainScene.otherInfo) do
			table.insert(temptab,v)
		end
		--self.tingAuto = not self.tingAuto
		gpsLayer:setInfo(temptab)
	end)
	
	local device_info_plane = self.m_mainLayer.device_info_plane
    require("hall.util.GameMenu"):addMenu(nil,device_info_plane,GAME_NAME)
end

function PHZMainLayer:isShowTuoGuan( isShow )
    self.take_bg:setVisible(isShow)
    isTuoGuan = isShow
end

function PHZMainLayer:setRoomNum(numStr)
    self.m_mainLayer.device_info_plane.room_id:setString(string.format("房间号:%s", numStr))
end

function PHZMainLayer:setRoomRound(round, round_total)
   
end

function PHZMainLayer:testMain()

	local data = {
		{
			Cardbuf = {1,3,4,5,6,8,1,2,3,4,5,6,7,8},
			uid = 15033
		},

		{
			Cardbuf = {1,2,3,4,5,6,7,8,1,2,3,4,5,6,7,8,10},
			uid = 15034
		},
	}

	g_PHZMainLayer:AddOtherCardLayer(data)

end

--是否显示玩家开始出牌提示操作
function PHZMainLayer:isShowImgReady(isShow)
	self.HeadMoveNode:setVisible(isShow)
	-- self.img_ready:setVisible(isShow)
	-- if isShow == false then
	-- 	self.img_ready:stopAllActions()
	-- end
end

--显示玩家开始出牌动画操作
function PHZMainLayer:show_Action_Ready()
	self.HeadMoveNode:setVisible(true)
	-- self.img_ready:stopAllActions()
	-- self.img_ready:setVisible(true)
	-- self.img_ready:setPosition(PHZMainLayer.READY_POS)
	-- local moveBy1 = cc.MoveBy:create(0.6,cc.p(0,200))
	-- local moveBy2 = cc.MoveBy:create(0.6,cc.p(0,-200))
	-- local seq = cc.Sequence:create(moveBy1,moveBy2)
	-- self.img_ready:runAction(cc.RepeatForever:create(seq))
end

function PHZMainLayer:initHuXiTxt()

end

function PHZMainLayer:isShowHuXiTxt(id)
	
end

--玩家头像集合
function PHZMainLayer:initHeadNode()
	self.m_headNode = {
	    [0] = self.PHZDownNode,
		[1] = self.PHZLPlayerNode,
		[2] = self.PHZRPlayerNode
	}
	-- self.m_headNode = {
	--     [0] = self.PHZDownNode,
	-- 	[1] = self.PHZRPlayerNode,
	-- 	[2] = self.PHZLPlayerNode
	-- }
end

function PHZMainLayer:showGameConfig(gameConfigtbl)
	local gameConfigStr = ""
	for k, v in pairs(gameConfigtbl) do
        if k == "pay_type" then
            if v == "fangka" then
                gameConfigStr = gameConfigStr .. "房主开房 "
            elseif v == "AA" then
                gameConfigStr = gameConfigStr .. "AA开房 "
            end
        elseif k == "modetype" then
            if v == 1 then
                gameConfigStr = gameConfigStr .. "100胡息结算 "
            elseif v == 2 then
                gameConfigStr = gameConfigStr .. "单局结算 "
            end
        elseif k == "huxi_score" then
            if v == 15 then
                gameConfigStr = gameConfigStr .. "十五胡起胡 "
			elseif v == 10 then
                gameConfigStr = gameConfigStr .. "十胡起胡 "
			end
		elseif k == "isBiHu" then
            if v == 1 then
                gameConfigStr = gameConfigStr .. "有胡必胡 "
            end
        elseif k == "autoai_round" then
            if v == 1 then
                gameConfigStr = gameConfigStr .. "托管1局解散 "
            elseif v == 2 then
                gameConfigStr = gameConfigStr .. "托管2局解散 "
            elseif v == 2 then
                gameConfigStr = gameConfigStr .. "托管3局解散 "
			end
		elseif k == "choupai" then
            if v == 5 then
                gameConfigStr = gameConfigStr .. "抽5张 "
            elseif v == 10 then
                gameConfigStr = gameConfigStr .. "抽10张 "
            elseif v == 15 then
                gameConfigStr = gameConfigStr .. "抽15张 "
            end
        elseif k == "wfone" then
            local canPickStr= string.split(v, ",")
            for _, x in pairs(canPickStr) do
                if x == '1' then
                    gameConfigStr = gameConfigStr .. "小红胡 "
                elseif x == '2' then
                    gameConfigStr = gameConfigStr .. "大红胡 "
                elseif x == '3' then
                    gameConfigStr = gameConfigStr .. "黑胡 "
                elseif x == '4' then
                    gameConfigStr = gameConfigStr .. "一点红 "
                end
            end
        end
    end
	
    local BASE_CHIP = gameConfigtbl.baseChip
    gameConfigStr = gameConfigStr .. "底分=" .. BASE_CHIP .." "
    USER_INFO["gameConfig"] = gameConfigtbl.name.." 玩法: "..gameConfigStr
	self.txt_gameConfig:setString(USER_INFO["gameConfig"])
	gameConfigTable = {
		{["游戏名"]=gameConfigtbl.name, ["底分"] = BASE_CHIP}, {["特殊玩法"] = gameConfigStr}
	}
	self.gameConfigtbl = gameConfigtbl

	
	if gameConfigtbl.dis_agree and gameConfigtbl.dis_agree == 3 then
        self:hideDisbandBtn()
    end
end

function PHZMainLayer:hideDisbandBtn()
	if self.moreFuncLayer ~= nil then
		self.moreFuncLayer.btnDisbandRoom:setVisible(false)
	end
end

function PHZMainLayer:initButtonUI()
	local function onTouchButton(sender,eventType)
    	if sender then
    		if eventType == ccui.TouchEventType.began then
    			sender:setScale(1.1)
    		elseif eventType == ccui.TouchEventType.ended then
    			sender:setScale(1)
    			self:onCallBack(sender:getTag())
    		elseif eventType == ccui.TouchEventType.canceled then
    			sender:setScale(1)
    		end
    	end
    end

	local btn_msg = self.m_mainLayer:getChildByName("btn_msg")
    btn_msg:onClick(function(event)
		if isOpenControl then
            phzServer:CLI_REQ_TEST_CARDS()
        else
            -- 玩法介绍同意风格
            require("hall.util.GameMenu"):showConfigPanel(gameConfigTable)
        end
	end)

    self.m_BG = self.m_mainLayer:getChildByName("BG")
   	self.btn_share = self.m_mainLayer:getChildByName("btn_share")
    self.btn_zhunbei = self.m_mainLayer:getChildByName("btn_zhunbei_6")
    self.btn_zhunbei:setVisible(true)
	
	self.btn_share:setVisible(true)
	self.btn_share:addTouchEventListener(onTouchButton)
	self.btn_zhunbei:onClick(handler(self, self.clickBtnZhunBei))
	self.btn_zhunbei:setLocalZOrder(100002)
    local voice_bt_worldpoint = (self.m_mainLayer.btn_yuyin:getParent()):convertToWorldSpace(self.m_mainLayer.btn_yuyin:getPosition())
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        VoiceRecordView:addVoiceRecordEvent(self.m_mainLayer.btn_yuyin,999)
    else
        self.m_mainLayer.btn_yuyin:setVisible(false)
        VoiceRecordView:showView(voice_bt_worldpoint.x,voice_bt_worldpoint.y,999)
    end


    local ddz_face= require("hall.FaceUI.faceUI") --require(TpackageName .. ".faceUI.faceUI") 
    
    local   ddz_face_node=ddz_face.new()
            ddz_face_node:setHandle(phzServer)
            self:addChild(ddz_face_node, 9999)
            ddz_face_node:setName("faceUI")

	local function onface_click(event)
		self:loadGameMsgLayer()
    end

    self.m_mainLayer.btn_xinxi:onClick(onface_click)

    -- self:setBGImg(cc.UserDefault:getInstance():getIntegerForKey("curentBGIndex",1))
end


function PHZMainLayer:onCallBack(_tag)
	if _tag == PHZMainLayer.TAG_BTN_SETTING then
		-- self:clickBtnSetting()
	elseif _tag == PHZMainLayer.TAG_BTN_SHARE then
		self:clickBtnShare()
	end
end

function PHZMainLayer:clickBtnShare()
	USER_INFO["invote_code"] = g_PHZMainScene.m_nRoomID
	print("===clickBtnShare=====")
	local   config_arr = LuaSplit(USER_INFO["gameConfig"], " ")
    local   share_content = ""
    for k,v in pairs(config_arr) do
        if v ~= "" then
            share_content = share_content .. v .. ","
        end
    end

    share_content = string.sub(share_content, 1, string.len(share_content) - 1)  
	local paras = {}
	paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
	paras["imagePath"] = "url"
	paras["name"] = "跑胡子，房号：" .. USER_INFO["invote_code"]
	paras["showType"] = 2;
	paras["url"] = appDownLoadAddress
	local shareLayer = require("hall.share.ShareLayer").new(paras)
	if shareLayer then
		shareLayer:addTo(SCENENOW["scene"],9999999)
	end


    -- require("hall.common.ShareLayer"):showShareLayer("跑胡子，房号：" .. USER_INFO["invote_code"], "http://download.doudougame.cn/app/index.html", "url", share_content)    
end


function PHZMainLayer:setBGImg(_index)
	-- local tempStr = "shaoyangbopi/res/other/phz_bg_img".._index..".png"
	-- self.m_BG:setTexture(tempStr)
	
end

function PHZMainLayer:isShowZhunBeiBtn(isShow)
	local idx = ViewBase:getZOrderByChilds(self)
	self.btn_zhunbei:setVisible(isShow)
end

--点击设置按钮

function PHZMainLayer:clickBtnSetting()
	print("====点击设置按钮====")
	-- local cardInfo = self.cardConfig_:getCardInfoByid(1)
	-- dump(cardInfo)
 --    if cardInfo then
 --        local strSound = cardInfo.Mousic
 --        require("hall.GameCommon"):playEffectSound(cardInfo.Mousic)
 --    end

    self:showSettingLayer()
end

--点击准备按钮
function PHZMainLayer:clickBtnZhunBei(event)
	self.btn_zhunbei:hide()
	print("===点击准备===")
	print("===点击准备===")
	print("===点击准备===")
	print("===点击准备===")

	self.btn_share:setVisible(false)

	if g_CardScene then
		g_CardScene:clearData()
		g_CardScene:clearTingData()
	end

	if g_PHZChiCardLayer ~= nil then
		g_PHZChiCardLayer:removeFromParent()
		g_PHZChiCardLayer = nil
	end
	if not tolua.isnull(self.phzOtherCardLayer) then
		self.phzOtherCardLayer:clearNode()
	end

	phzServer:CLI_READY_GAME(1)
	-- self:isShowBtnDistance(true)
	-- local _mCardData = {1,1,3,15,7,15,1,3,15,10,25,3,15,9,6,25,2,1,26,25}
	-- g_CardScene:setCurHandCard(_mCardData)

end

--退出房间
function PHZMainLayer:quitRoom()
	--print("======g_PHZMainLayer.m_CardReady=====",g_PHZMainScene.m_CardReady)
	--print("======g_PHZMainLayer.m_CardReady=====",g_PHZMainScene.m_CardReady)
	--print("======g_PHZMainLayer.m_CardReady=====",g_PHZMainScene.m_CardReady)
	--print("======g_PHZMainLayer.m_CardReady=====",g_PHZMainScene.m_CardReady)
	
	if g_PHZMainScene.m_CardReady or g_PHZMainScene.m_bGameCount < g_PHZMainScene.m_bMaxGameCount  then
		if  g_PHZMainScene.m_bGameCount >= 1 then
			require("hall.GameTips"):showTips("提示", "", 3, "游戏正在进行中...")
			return 
		end
	end
    phzServer:quitRoom()
end

--解散房间
function PHZMainLayer:disbandGroup()

    local function requestDisband()
        dump("C2G_CMD_DISSOLVE_ROOM")
        phzServer:C2G_CMD_DISSOLVE_ROOM()
    end

    --查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
    cct.createHttRq({
        url = HttpAddr .. "/freeGame/queryGroupGameStatus",
        date = {
            activityId = USER_INFO["activity_id"],
            interfaceType = "j"
        },
        type_= "POST",
        callBack = function(data)
            local responseData = data.netData
            responseData = json.decode(responseData)
            local returnCode = responseData.returnCode
            if returnCode == "0" then
                local data = tonumber(responseData.data)
                dump(data, "检查当前组局状态")
                if data == 1 then
                    --创建组局
                    require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "提前解散房间不扣钻石，是否确定解散",requestDisband)
                elseif data == 2 then
                    --开始组局
                    require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "牌局已开始，确定要申请解散房间？",requestDisband)
                    
                elseif data == 0 then
                    --结束组局
                    require("hall.GameTips"):showTips("提示", "tohall", 1, "牌局已结束，是否返回大厅？")

                end             
            end

        end
    })
end

--玩家自身信息Node
function PHZMainLayer:initDownNode()
	local _downNode = self.m_mainLayer:getChildByName("phzdownNode")
	self.PHZDownNode = require("shaoyangbopi.view.PHZDownNode").new(_downNode)
	_downNode:addChild(self.PHZDownNode)
	self.PHZDownNode:setVisible(false)
end

--房间上方信息NOde
function PHZMainLayer:initUpNode()
	self._upNode = self.m_mainLayer:getChildByName("phzupNode")
	self.PHZUpNode = require("shaoyangbopi.view.PHZUpNode").new()
	self._upNode:addChild(self.PHZUpNode)
	self.PHZUpNode:setVisible(false)
end

--左侧玩家Node
function PHZMainLayer:initLPlayerNode()
	local _lPlayerNode = self.m_mainLayer:getChildByName("phzlplayerNode")
	self.PHZLPlayerNode = require("shaoyangbopi.view.PHZLPlayerNode").new(_lPlayerNode)
	_lPlayerNode:addChild(self.PHZLPlayerNode)
	self.PHZLPlayerNode:setVisible(false)
end

--右侧玩家Node
function PHZMainLayer:initRPlayerNode()
	local _rPlayerNode = self.m_mainLayer:getChildByName("phzrplayerNode")
	self.PHZRPlayerNode = require("shaoyangbopi.view.PHZRPlayerNode").new(_rPlayerNode)
	_rPlayerNode:addChild(self.PHZRPlayerNode)
	self.PHZRPlayerNode:setVisible(false)
end

--吃牌操作Node
function PHZMainLayer:initOporateNode()
	local _oporateNode = self.m_mainLayer:getChildByName("phzoprorateNode")
	self.PHZOprorateNode = require("shaoyangbopi.view.PHZOprorateNode").new()
	self:addChild(self.PHZOprorateNode,PHZMainLayer.OPRORATENODE_TAG)
	self.PHZOprorateNode:setPosition(_oporateNode:getPosition())
	self.PHZOprorateNode:setVisible(false)
end

--初始化牌层
function PHZMainLayer:initCardScene()
	g_CardScene = CardLayer.new()
    self.m_mainLayer:addChild(g_CardScene)
end

--加入吃牌层
function PHZMainLayer:AddChiCardLayer(cbIndex,curCard)
	self.phzChiCardLayer = ChiCardLayer.new(cbIndex,curCard)
	g_PHZChiCardLayer = self.phzChiCardLayer
	self:addChild(g_PHZChiCardLayer,PHZMainLayer.CHICARD_TAG)
end

--加入其他玩家剩余牌 层
function PHZMainLayer:AddOtherCardLayer(data1,data2)
	self.phzOtherCardLayer = PHZOtherCardLayer.new(data1,data2, self.m_mainLayer.PHZOtherCardLayer)
end

--加入结算层
function PHZMainLayer:showResultLayer(data)
	local this = self

	-- local tempResultLayer = ResultLayer.new(data)
	-- this:addChild(tempResultLayer,PHZMainLayer.RESULT_TAG)
	-- 发送新牌
    self.delayHandler = scheduler.performWithDelayGlobal(function ()
        local tempResultLayer = ResultLayer.new(data)
		this:addChild(tempResultLayer,PHZMainLayer.RESULT_TAG)
    end,1)
end

--加入菜单层
function PHZMainLayer:showMenuLayer()
	-- local tempMenuLayer = MenuLayer.new()
	-- self:addChild(tempMenuLayer,PHZMainLayer.MENU_TAG)
end

--加入总结算层
function PHZMainLayer:showAllResultLayer(data)
    local tempAllResultLayer = PHZAllResultLayer.new(data)
	self:addChild(tempAllResultLayer,PHZMainLayer.ALLRESULTLAYER_TAG)
end
function PHZMainLayer:updateBtnResult()
	ResultLayer:setBtnIsResult()
end

--初始化触摸层，放在牌层的上面
function PHZMainLayer:initTouchLayer()
	g_TouchLayer = GameTouchLayer.new()
    self.m_mainLayer:addChild(g_TouchLayer)
end

--隐藏或者显示出牌线
function PHZMainLayer:isShowTopOutLine(isHide)
	self.pnl_line:setVisible(isHide)
end

--获取发牌位置
function PHZMainLayer:getSendCardPos()
	local x,y = self._upNode:getPosition().x,self._upNode:getPosition().y
	return x,y
end

function PHZMainLayer:getHeadPosByID(_ChairID)
	if _ChairID == nil or _ChairID < 0 then return print("_ChairID is error!!!") end
	local index = _ChairID
	local x,y = self.m_headNode[index].parent:getPosition().x,self.m_headNode[index].parent:getPosition().y
	return x,y
end

--返回游戏初始状态
function PHZMainLayer:restGame()

	-- 1:初始化牌层
	if g_CardScene then
		g_CardScene:clearData()
	end
	
	-- 2：玩家状态初始化(关闭倒计时、关闭闪烁、隐藏庄家)
	for i=0,GAME_PLAYER -1 do
		self.m_headNode[i]:setVisible(false)
        self.m_headNode[i]:ShowTimerText(-1)
        self.m_headNode[i]:isShowZhuangIMG(false)
        self.m_headNode[i]:isShowZhunBeiIMG(false)
    end

    --房间信息
    self.PHZUpNode:clearData()

    --胡息隐藏
    --self:isShowHuXiTxt(false)

    --准备隐藏
    self.btn_zhunbei:setVisible(false)

end

function PHZMainLayer:loadMoreFuncLayer()
    print("=====loadMoreFuncLayer=====")
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
    -- print("======SCENENOW['scene'].GameRound======",SCENENOW["scene"].GameRound)

    if 0 == SCENENOW["scene"].GameRound then
    	if self.gameConfigtbl and self.gameConfigtbl.dis_agree and self.gameConfigtbl.dis_agree == 3 then
	        self:hideDisbandBtn()
	    else
        	self.moreFuncLayer.btnDisbandRoom:setVisible(true)
        end
    else
        if self.gameConfigtbl and self.gameConfigtbl.dis_agree and self.gameConfigtbl.dis_agree == 3 then
	        self:hideDisbandBtn()
	    else
        	self.moreFuncLayer.btnDisbandRoom:setVisible(true)
        end
    end
end

function PHZMainLayer:getToDisbandFuncs()
    local data = {}
	data.showMoreFuncHandler = handler(self, self.loadMoreFuncLayer)

    data.quitRoomHandler = handler(self, self.quitRoom)
    data.disbandRoomHandler = handler(self, self.disbandRoom)
    data.rejectDisbandRoomHandler = handler(self, self.rejectDisband)
    data.agreeDisbandRoomHandler = handler(self, self.agreeDisband)

    data.showGameMsgLayerHandler = handler(self, self.loadGameMsgLayer)
  	data.voiceRecordHandler = handler(self,self.addVoiceRecordEvent)
    return data
end

function PHZMainLayer:addVoiceRecordEvent(btn_voice)
    print("voice")
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        print("voice22")
        VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
    end
end

-- function PHZMainLayer:loadMoreFuncLayer()
--     if tolua.isnull(self.moreFuncLayer) then
--     	self.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
-- 		self:addChild(self.moreFuncLayer, 99999)
-- 		-- self.moreFuncLayer = self:loadLayerByName("hall.roomCommonUI.GameMoreFuncLayer", 4)
-- 		local data = {}
--         data.quitRoom = handler(self, self.quitRoom)
--         data.disbandRoom = handler(self, self.disbandRoom)
--         self.moreFuncLayer:registerDisbandFuncs(data)
--     else
--     	if 0 == SCENENOW["scene"].GameRound then
-- 	        self.moreFuncLayer.btnDisbandRoom:setVisible(false)
-- 	    else
-- 	        self.moreFuncLayer.btnDisbandRoom:setVisible(true)
-- 	    end

--         self.moreFuncLayer:setVisible(true)
--         self.moreFuncLayer:showAni()
--     end
-- 	--local data = {}
-- 	--data.quitRoom = handler(self, self.quitRoom)
-- 	--data.disbandRoom = handler(self, self.disbandGroup)
-- 	--self.moreFuncLayer:registerDisbandFuncs(data)
-- end

function PHZMainLayer:getToSendFaceAndTxtFuncs()
    local data = {}
    data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function PHZMainLayer:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
        self:addChild(self.gameMsgLayer, PHZMainLayer.MENU_TAG+5)
    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end

function PHZMainLayer:loadLayerByName(path, zOrder, data)
    if path == nil then
        --print("PDKgameScene:loadLayerByName [path] is nil ----------------------")
    end
    zOrder = zOrder == nil and self:getChildrenCount() + 1 or zOrder
    local layer = require(path).new(data)
    if not tolua.isnull(layer) then
        layer:addTo(self, zOrder)
    end
    return layer
end

function PHZMainLayer:sendFaceByIdx(id, msgType, to_uid)
    --print("sendFaceMsg --------------------------", id)
    phzServer:CLI_MSG_FACE(id, msgType, to_uid)
end

function PHZMainLayer:sendEditTxt(str)
    --print("sendEditMsg --------------------------", id)
end

function PHZMainLayer:quitRoom()
	dump("quitRoom===")
    phzServer:quitRoom()
end

function PHZMainLayer:disbandRoom()
    phzServer:C2G_CMD_DISSOLVE_ROOM()
end

function PHZMainLayer:rejectDisband()
    phzServer:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function PHZMainLayer:agreeDisband()
    phzServer:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function PHZMainLayer:showGPSButton()
    dump(g_PHZMainScene.otherInfo,"showGPSButton--g_PHZMainScene.otherInfo")
    local temptab = {}
    for k,v in pairs(g_PHZMainScene.otherInfo) do
        table.insert(temptab,v)
    end
    local btn_gps = self.m_mainLayer:getChildByName("btn_gps")

    if #temptab == 1 then
        btn_gps:setVisible(false)
        return
    end

    local isWarning = 0
    for i=1,#temptab do
        for j=i+1,#temptab do
            if calculateDistance(temptab[i].latitude,temptab[j].latitude,temptab[i].longitude,temptab[j].longitude) <= 100 then
                isWarning = isWarning + 1
                break
            end
        end
    end

    local img_safe = btn_gps:getChildByName("img_safe")
    local img_warnning = btn_gps:getChildByName("img_warnning")

    if isWarning > 0 then
        img_safe:setVisible(false)
        img_warnning:setVisible(true)
    else
        img_safe:setVisible(true)
        img_warnning:setVisible(false)
    end

    btn_gps:setVisible(true)
end

function PHZMainLayer:setJvShu( )
	-- local str = "1/1"
	-- local round = g_PHZMainScene.m_bGameCount or 1
    -- local totalRound = g_PHZMainScene.m_bMaxGameCount or 1
	-- str = round .. "/" .. totalRound
	-- self.m_mainLayer.device_info_plane.txt_jvshu:setString("局数："..str)
	self.m_mainLayer.device_info_plane.txt_jvshu:setString("")
end

--加入听牌node
function PHZMainLayer:showTingNode()
	if self.tingAuto then
		return
	end
    local cards = g_CardScene:getMyHandCardData()
	if #cards >= 1 then
		local tingHuInfo = PHZ_Ting:CheckHuCard(cards)
		if type(tingHuInfo) == "table" then
			self.TingView:setTing2(tingHuInfo)
			return
		end
		
		local tingInfo = PHZ_Ting:CheckTingCard(cards)
		if type(tingInfo) == "table" then
			g_CardScene:setTings(tingInfo)
		end
	end
end

return PHZMainLayer