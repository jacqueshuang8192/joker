local scheduler = require("framework.scheduler")
local phzServer = import("yuanjiangguihz.handle.PHZSendHandle")
local GameLogic = require("yuanjiangguihz.logic.GameLogic")
local CardConfig = require("yuanjiangguihz.logic.CardConfig")
local CardSprite = require("yuanjiangguihz.models.CardSprite")

local CardLayer = require("yuanjiangguihz.view.CardLayer")
local GameTouchLayer = require("yuanjiangguihz.view.GameTouchLayer")
local ChiCardLayer = require("yuanjiangguihz.view.PHZChiCardLayer")
local OtherCardLayer = require("yuanjiangguihz.view.PHZOtherCardLayer")
local ResultLayer = require("yuanjiangguihz.view.PHZResultLayer")
local AllResultLayer = require("yuanjiangguihz.view.PHZAllResultLayer")
local TingLayer = require("yuanjiangguihz.view.PHZTingCardNode")
local TingView = require("yuanjiangguihz.view.TingView")

local PHZMainLayer = class("PHZMainLayer", function ()
	return display.newLayer()
end)

PHZMainLayer.PLAYER_NUM = 3

PHZMainLayer.CARDLAYER_TAG = 8
PHZMainLayer.TOUCHLAYER_TAG = 999999
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

PHZMainLayer.TAG_BTN_ZHUNBEI = 4
PHZMainLayer.TAG_BTN_SETTING = 5
PHZMainLayer.TAG_BTN_DISTANCE = 6
PHZMainLayer.TAG_BTN_SHARE = 8
PHZMainLayer.READY_POS = cc.p(1061,240)

function PHZMainLayer:ctor()
	g_PHZMainLayer = self
	self:setNodeEventEnabled(true)
    self.cardConfig_ = CardConfig:new()
	self:clearNodeToNil()

	g_PHZMainLayer:initUI()
	g_PHZMainLayer:showRoomCommonLayer()
end


--设置在mainlayer上面的node全部设置为nil（空）
function PHZMainLayer:clearNodeToNil()
	self.m_downNode = nil
	self.m_upNode = nil
	
	--------player------
	self.m_headNode = {}

	g_CardScene = nil
	g_TouchLayer = nil
end

function PHZMainLayer:clearData()
	self:clearNodeToNil()
end

function PHZMainLayer:onEnter()
end

function PHZMainLayer:onExit()
	if self.phzOtherCardLayer then
		self.phzOtherCardLayer:removeFromParent()
		self.phzOtherCardLayer = nil
	end

	if self.delayHandler ~= nil then
		scheduler.unscheduleGlobal(self.delayHandler)
		self.delayHandler = nil
	end
	
	if not tolua.isnull(g_PHZChiCardLayer) then
		g_PHZChiCardLayer:removeFromParent()
		g_PHZChiCardLayer = nil
	end
end

--------------------------------------init UI --------------------------------
function PHZMainLayer:initUI()
    self.m_GameLogic = GameLogic:new()
	self.m_mainLayer = cc.CSLoader:createNode("yuanjiangguihz/res/PHZMainLayer.csb")
	self:addChild(self.m_mainLayer)
	DESIGN_SCREEN_WIDTH  = 1280
	DESIGN_SCREEN_HEIGHT = 720
	SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
	SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
	self.m_mainLayer:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH, SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
	print(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH, SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT,"---------asdasdf")
	GameUtils.setNodeNameBindObj(self.m_mainLayer)
	
	-- self.m_mainLayer:hide()
	local chids = self:getChildren()
    ccui.Helper:doLayout(self.m_mainLayer)
	self.pnl_line = self.m_mainLayer:getChildByName("img_xian")
	self.pnl_line:setVisible(false)
	self.img_ready = self.m_mainLayer:getChildByName("img_ready_act")
	self.img_ready:setVisible(false)
	self:initHuXiTxt()
	self:initButtonUI()
	self:initUpNode()
	self:initHeadNode()
	self:initCardScene()
	self:initOporateNode()
	self:initTouchLayer()
	self.HeadMoveNode = cc.CSLoader:createNode("yuanjiangguihz/res/PHZHeadMove.csb"):addTo(self.m_mainLayer)
    self.HeadMoveNode:setName("headLayer")
    self.HeadMoveNode:setLocalZOrder(15)
    self.HeadMoveNode:setPosition(cc.p(1050,300))
    self.HeadMoveNode:setVisible(false)
	self.TingView = TingView.new(self.m_mainLayer.ting_vw)

   	local  action = cc.CSLoader:createTimeline("yuanjiangguihz/res/PHZHeadMove.csb")
    self.HeadMoveNode:runAction(action)
    action:gotoFrameAndPlay(0,true)

	local device_info_plane = self.m_mainLayer.device_info_plane
	require("hall.util.GameMenu"):addMenu(nil,device_info_plane,g_379.GAME_NAME)
	self:setTuoGuanState(false)
end

function PHZMainLayer:setRoomRound(round, round_total)
	local str = "1/1"
	local round = round or 1
    local totalRound = round_total or 1
	str = round .. "/" .. totalRound
	self.m_mainLayer.device_info_plane.txt_jvshu:setString("局数："..str)
end

function PHZMainLayer:setRoomNum(numStr)
    self.m_mainLayer.device_info_plane.room_id:setString(string.format("房间号:%s", numStr))
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
	for idx=0, g_379.GAME_PLAYER - 1 do
		local node = self.m_mainLayer.players["player_"..idx]:hide()
		local PlayerView = require("yuanjiangguihz.view.PlayerView").new(node)
		self.m_headNode[idx] = PlayerView 
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
   	self.btn_share = self.m_mainLayer:getChildByName("btn_share")
    self.btn_zhunbei = self.m_mainLayer:getChildByName("btn_zhunbei")
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
    local ddz_face_node=ddz_face.new()
	ddz_face_node:setHandle(phzServer)
	self:addChild(ddz_face_node, 9999)
	ddz_face_node:setName("faceUI")

	local function onface_click(event)
		self:loadGameMsgLayer()
    end
	self.m_mainLayer.btn_xinxi:onClick(onface_click)
	
	self.m_mainLayer.btn_menu:onClick(function(event)
        self:loadMoreFuncLayer()
	end)
	local idx = ViewBase:getZOrderByChilds(self)
	self.m_mainLayer.btn_menu:setLocalZOrder(idx)
	self.m_mainLayer.btn_yuyin:setLocalZOrder(idx+1)
	self.m_mainLayer.btn_xinxi:setLocalZOrder(idx+2)
end

function PHZMainLayer:onCallBack(_tag)
	if _tag == PHZMainLayer.TAG_BTN_ZHUNBEI then
		self:clickBtnZhunBei()
	elseif _tag == PHZMainLayer.TAG_BTN_SETTING then
	elseif _tag == PHZMainLayer.TAG_BTN_DISTANCE then
		self:clickBtnDistance()
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


function PHZMainLayer:isShowZhunBeiBtn(isShow)
	self.btn_zhunbei:setVisible(isShow)
end

function PHZMainLayer:clickBtnDistance()
	-- self:showAllResultLayer(nil)
	-- self:AddOtherCardLayer(nil,{1,2,3,1,1,1,1,1,1,1,1,2,3,1,1,1,1,1,1,1})
end

--点击准备按钮
function PHZMainLayer:clickBtnZhunBei()
	print("===点击准备===")
	print("===点击准备===")
	print("===点击准备===")
	print("===点击准备===")
	self.btn_zhunbei:hide()

	self.btn_share:setVisible(false)

	if g_CardScene then
		g_CardScene:clearData()
		g_CardScene:clearTingData()
	end
	for i=0,g_379.GAME_PLAYER -1 do
        self.m_headNode[i]:hideImgHu()
    end
	if g_PHZChiCardLayer ~= nil then
		g_PHZChiCardLayer:removeFromParent()
		g_PHZChiCardLayer = nil
	end

	if self.phzOtherCardLayer then
		self.phzOtherCardLayer:removeFromParent()
		self.phzOtherCardLayer = nil
	end

	phzServer:CLI_READY_GAME(1)
	-- local _mCardData = {1,1,3,15,7,15,1,3,15,10,25,3,15,9,6,25,2,1,26,25}
	-- g_CardScene:setCurHandCard(_mCardData)
end

--清空所有桌面数据
function PHZMainLayer:clearTableData()
	self.btn_zhunbei:hide()
	self.btn_share:setVisible(false)
	self:setTuoGuanState(false)
	if g_CardScene then
		g_CardScene:clearData()
	end
	for i=0,g_379.GAME_PLAYER -1 do
        self.m_headNode[i]:hideImgHu()
    end
	if g_PHZChiCardLayer ~= nil then
		g_PHZChiCardLayer:removeFromParent()
		g_PHZChiCardLayer = nil
	end

	if self.phzOtherCardLayer then
		self.phzOtherCardLayer:removeFromParent()
		self.phzOtherCardLayer = nil
	end
	local node = self:getChildByName("ResultLayer")
	if node then
		node:removeFromParent()
	end
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
                    require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "提前解散房间不扣钻石，是否确定解散",_,requestDisband)
                elseif data == 2 then
                    --开始组局
                    require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "牌局已开始，确定要申请解散房间？",_,requestDisband)
                    
                elseif data == 0 then
                    --结束组局
                    require("hall.GameTips"):showTips("提示", "tohall", 1, "牌局已结束，是否返回大厅？")

                end             
            end

        end
    })
end


--房间上方信息NOde
function PHZMainLayer:initUpNode()
	self._upNode = self.m_mainLayer:getChildByName("phzupNode")
	self.PHZUpNode = require("yuanjiangguihz.view.PHZUpNode").new()
	self._upNode:addChild(self.PHZUpNode)
	self.PHZUpNode:setVisible(false)
end


--吃牌操作Node
function PHZMainLayer:initOporateNode()
	local PHZOprorateNode = self.m_mainLayer:getChildByName("phzoprorateNode")
	local idx = ViewBase:getZOrderByChilds(self.m_mainLayer)
	self.PHZOprorateNode = require("yuanjiangguihz.view.PHZOprorateNode").new(PHZOprorateNode)
	self.PHZOprorateNode:hide()
	-- PHZOprorateNode:setLocalZOrder(idx)
end

--初始化牌层
function PHZMainLayer:initCardScene()
	g_CardScene = CardLayer.new()
    self.m_mainLayer:addChild(g_CardScene)
end

--加入吃牌层
function PHZMainLayer:AddChiCardLayer(cbIndex, curCard, type_, liuData)
	self.phzChiCardLayer = ChiCardLayer.new(cbIndex, curCard, type_, liuData)
	g_PHZChiCardLayer = self.phzChiCardLayer
	self.m_mainLayer:addChild(g_PHZChiCardLayer)
end

--加入其他玩家剩余牌 层
function PHZMainLayer:AddOtherCardLayer(data1,data2)
	self.phzOtherCardLayer = OtherCardLayer.new(data1,data2)
	self.m_mainLayer:addChild(self.phzOtherCardLayer,PHZMainLayer.OTHERCARD_TAG)
end

--加入结算层
function PHZMainLayer:showResultLayer(data)
	local this = self

	-- local tempResultLayer = ResultLayer.new(data)
	-- this:addChild(tempResultLayer,PHZMainLayer.RESULT_TAG)
	-- 发送新牌
    self.delayHandler = scheduler.performWithDelayGlobal(function ()
        local tempResultLayer = ResultLayer.new(data)
		this:addChild(tempResultLayer)
		tempResultLayer:setName("ResultLayer")
    end,3)
end


--加入听牌node
function PHZMainLayer:showTingNode()
	--触发听牌
	-- 1：获取手中牌的列表
	if g_PHZTingNode then
		g_PHZTingNode:removeTingNode()
	end

    local tempHandCardsData = g_CardScene:getMyHandCardData()
    local tempTingCardsData = {}
    if #tempHandCardsData >= 1 then
    	print("====自己手中的牌====")
		-- tempTingCardsData = self.m_GameLogic:getTingCardArr(tempHandCardsData)
    end

    if not tempTingCardsData or #tempTingCardsData <= 0 then 
    	if not g_PHZTingNode then return end
    	g_PHZTingNode:removeTingNode()
    	return 
    end

    local tempTingNode = TingLayer.new()
    g_PHZTingNode = tempTingNode
	self.m_mainLayer:addChild(g_PHZTingNode,PHZMainLayer.TING_CARD_TAG)
	tempTingNode:setPosition(cc.p(80,250))
	tempTingNode:refreshTingCards(tempTingCardsData)

	-- test
	-- tempTingNode:refreshTingCards(nil)

end

--加入菜单层
function PHZMainLayer:showMenuLayer()
	-- local tempMenuLayer = MenuLayer.new()
	-- self.m_mainLayer:addChild(tempMenuLayer,PHZMainLayer.MENU_TAG)
end

--加入总结算层
function PHZMainLayer:showAllResultLayer(data)
	local tempAllResultLayer = AllResultLayer.new(data)
	local idx = ViewBase:getZOrderByChilds(self.m_mainLayer)
	self.m_mainLayer:addChild(tempAllResultLayer, idx)
end
function PHZMainLayer:updateBtnResult()
	ResultLayer:setBtnIsResult()
end

--初始化触摸层，放在牌层的上面
function PHZMainLayer:initTouchLayer()
	g_TouchLayer = GameTouchLayer.new()
    self.m_mainLayer:addChild(g_TouchLayer, PHZMainLayer.TOUCHLAYER_TAG)
end

--隐藏或者显示出牌线
function PHZMainLayer:isShowTopOutLine(isHide)
	self.pnl_line:setVisible(false)
end

--获取发牌位置
function PHZMainLayer:getSendCardPos()
	local x,y = self._upNode:getPosition().x,self._upNode:getPosition().y
	return x,y
end

function PHZMainLayer:getHeadPosByID(_ChairID)
	if _ChairID == nil or _ChairID < 0 then return print("_ChairID is error!!!") end
	local index = _ChairID
	local x,y = self.m_headNode[index].player:getPosition().x,self.m_headNode[index].player:getPosition().y
	return x,y
end

--返回游戏初始状态
function PHZMainLayer:restGame()

	-- 1:初始化牌层
	if g_CardScene then
		g_CardScene:clearData()
	end
	
	-- 2：玩家状态初始化(关闭倒计时、关闭闪烁、隐藏庄家)
	for i=0,g_379.GAME_PLAYER -1 do
		self.m_headNode[i]:setVisible(false)
        self.m_headNode[i]:ShowTimerText(-1)
        self.m_headNode[i]:isShowZhuangIMG(false)
        self.m_headNode[i]:isShowZhunBeiIMG(false)
        self.m_headNode[i]:hideImgHu()
    end

    --房间信息
    self.PHZUpNode:clearData()

    --胡息隐藏
    --self:isShowHuXiTxt(false)

    --准备隐藏
    self.btn_zhunbei:setVisible(false)

end

--加入菜单层
function PHZMainLayer:showRoomCommonLayer()
	-- do return end
	
	--self:loadGameMsgLayer()
	-- local tempMenuLayer = MenuLayer.new()
	-- self.m_mainLayer:addChild(tempMenuLayer,PHZMainLayer.MENU_TAG)
end

function PHZMainLayer:getToDisbandFuncs()
    local data = {} 
    data.quitRoomHandler = handler(self, self.quitRoom)
    data.disbandRoomHandler = handler(self, self.disbandRoom)
    data.rejectDisbandRoomHandler = handler(self, self.rejectDisband)
    data.agreeDisbandRoomHandler = handler(self, self.agreeDisband)
    data.showMoreFuncHandler = handler(self, self.loadMoreFuncLayer)
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

function PHZMainLayer:loadMoreFuncLayer()
    if tolua.isnull(self.moreFuncLayer) then
    	self.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
		self:addChild(self.moreFuncLayer, 99999)
		local data = {}
        data.quitRoom = handler(self, self.quitRoom)
        data.disbandRoom = handler(self, self.disbandRoom)
        self.moreFuncLayer:registerDisbandFuncs(data)
    else
    	if 0 == SCENENOW["scene"].GameRound then
	        self.moreFuncLayer.btnDisbandRoom:setVisible(false)
	    else
	        self.moreFuncLayer.btnDisbandRoom:setVisible(true)
	    end

        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end
end

function PHZMainLayer:getToSendFaceAndTxtFuncs()
    local data = {}
    data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function PHZMainLayer:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
        self.m_mainLayer:addChild(self.gameMsgLayer, PHZMainLayer.MENU_TAG+5)
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

function PHZMainLayer:sendFaceByIdx(id)
    --print("sendFaceMsg --------------------------", id)
    phzServer:CLI_MSG_FACE(id)
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

function PHZMainLayer:setTuoGuanState(flag)
	self.m_mainLayer.take_bg:setVisible(flag)
end

------------------断线重连----------------------

return PHZMainLayer