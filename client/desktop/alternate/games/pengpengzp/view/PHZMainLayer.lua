local scheduler = require("framework.scheduler")
local phzServer = import("pengpengzp.handle.PHZSendHandle")
local GameLogic = require("pengpengzp.logic.GameLogic")
local CardConfig = require("pengpengzp.logic.CardConfig")
local CardSprite = require("pengpengzp.models.CardSprite")

local CardLayer = require("pengpengzp.view.CardLayer")
local GameTouchLayer = require("pengpengzp.view.GameTouchLayer")
local ChiCardLayer = require("pengpengzp.view.PHZChiCardLayer")
local OtherCardLayer = require("pengpengzp.view.PHZOtherCardLayer")
local ResultLayer = require("pengpengzp.view.PHZResultLayer")
local DistanceLayer = require("pengpengzp.view.PHZDistanceLayer")
local SettingLayer = require("pengpengzp.view.PHZSettingLayer")
local SetBgLayer = require("pengpengzp.view.PHZSetBgLayer")
local AllResultLayer = require("pengpengzp.view.PHZAllResultLayer")
local MenuLayer = require("pengpengzp.view.PHZMenuLayer")
local TingLayer = require("pengpengzp.view.PHZTingCardNode")
local GPSShowLayer = require("hall.GPSShowLayer")

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
	if self.phzOtherCardLayer then
		self.phzOtherCardLayer:removeFromParent()
		self.phzOtherCardLayer = nil
	end

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

	self.m_mainLayer = cc.CSLoader:createNode("pengpengzp/res/PHZMainLayer.csb")
	self:addChild(self.m_mainLayer)

	self.m_mainLayer:getChildByName("BG"):setScale(g_PHZMainScene:_getScaleParam2())
	g_PHZMainScene:setRootSize(self.m_mainLayer)

	--self.m_mainLayer:getChildByName("phz_14"):setVisible(false)

	self.pnl_line = self.m_mainLayer:getChildByName("img_xian")
	self.pnl_line:setVisible(false)

	self.img_ready = self.m_mainLayer:getChildByName("img_ready_act")
	self.img_ready:setVisible(false)

	self:initHuXiTxt()
	self:initButtonUI()
	self:initDownNode()
	self:initUpNode()
	self:initLPlayerNode()
	self:initTPlayerNode()
	self:initRPlayerNode()
	self:initOporateNode()

	self:initHeadNode()

	self:initCardScene()
	self:initTouchLayer()

	-- self.m_head_move_node = self.m_mainLayer:getChildByName("Sprite_2")
	-- self.m_head_move_node:setVisible(false)
	--self.txt_roomInfo = self.m_mainLayer:getChildByName("txt_roomInfo")

	self.HeadMoveNode = cc.CSLoader:createNode("pengpengzp/res/PHZHeadMove.csb"):addTo(self)
    self.HeadMoveNode:setName("headLayer")
    self.HeadMoveNode:setLocalZOrder(15)
    self.HeadMoveNode:setPosition(cc.p(1050,300))
    self.HeadMoveNode:setVisible(false)

   	local  action = cc.CSLoader:createTimeline("pengpengzp/res/PHZHeadMove.csb")
    self.HeadMoveNode:runAction(action)
    action:gotoFrameAndPlay(0,true)

	self.PiaoNode = self.m_mainLayer:getChildByName("PiaoNode")
	self.PiaoNode:setVisible(false)

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

	-- self.m_GameLogic = GameLogic:new()
	-- self.m_GameLogic:getCurhandCard(self._mCardData)

	-- local log = require "log"

	-- local final_list = {}

	-- function get_val(card)
	--     return card & 0x0F
	-- end

	-- function change_hash(hash, val, ...)
	--     local pos_list = {...}
	--     for k, v in ipairs(pos_list) do
	--         hash[v] = hash[v] + val
	--     end

	--     if val < 0 then
	--         for k, v in ipairs(pos_list) do
	--             for i = 1, val do
	--                 table.insert(final_list, v)
	--             end
	--         end
	--     else
	--         for k, v in ipairs(pos_list) do
	--             for i = 1, val do
	--                 table.remove(final_list)
	--             end
	--         end
	--     end
	-- end
	-- --[[
	-- 三张 10
	-- 2 7 10   5
	-- 顺子  3
	-- 吃 2
	-- ]]
	-- local score = 0

	-- function get_hu_xi(hash)
	--     for i = 1, 31 do
	--         if hash[i] > 0 then
	--             if hash[i] == 3 then
	--                 change_hash(hash, -3, i)
	--                 score = score + 10
	--                 local re = get_hu_xi(hash)
	--                 if re == -1 then
	--                     change_hash(hash, 3, i)
	--                     score = score - 10
	--                 else
	--                     return score
	--                 end
	--             end
	            
	--             if get_val(i) == 2 and hash[i + 5] > 0 and hash[i + 5] < 3 and hash[i + 8] > 0 and hash[i + 8] < 3 then
	--                 change_hash(hash, -1, i, i + 5, i + 8)
	--                 score = score + 5
	--                 local re = get_hu_xi(hash)
	--                 if re == -1 then
	--                     change_hash(hash, 1, i, i + 5, i + 8)
	--                     score = score - 5
	--                 else
	--                     return score
	--                 end
	--             end
	            
	--             if hash[i + 1] > 0 and hash[i + 1] < 3 and hash[i + 2] > 0 and hash[i + 2] < 3 then
	--                 change_hash(hash, -1, i, i + 1, i + 2)
	--                 score = score + 3
	--                 local re = get_hu_xi(hash)
	--                 if re == -1 then
	--                     change_hash(hash, 1, i, i + 1, i + 2)
	--                     score = score - 3
	--                 else
	--                     return score
	--                 end
	--             end
	            
	--             if i < 16 and hash[i + 16] > 0 and hash[i + 16] < 3 and hash[i] + hash[i + 16] > 3 then
	--                 local cnt = hash[i]
	--                 change_hash(hash, -cnt, i)
	--                 change_hash(hash, -3 + cnt, i + 16)
	--                 score = score + 2
	--                 local re = get_hu_xi(hash)
	--                 if re == -1 then
	--                     change_hash(hash, cnt, i)
	--                     change_hash(hash, 3 - cnt, i + 16)
	--                     score = score - 2
	--                 else
	--                     return score
	--                 end
	--             end

	--             if i > 16 and hash[i - 16] > 0 and hash[i - 16] < 3 and hash[i] + hash[i - 16] > 3 then
	--                 local cnt = hash[i]
	--                 change_hash(hash, -cnt, i)
	--                 change_hash(hash, -3 + cnt, i - 16)
	--                 score = score + 2
	--                 local re = get_hu_xi(hash)
	--                 if re == -1 then
	--                     change_hash(hash, cnt, i)
	--                     change_hash(hash, 3 - cnt, i - 16)
	--                     score = score - 2
	--                 else
	--                     return score
	--                 end
	--             end
	--         end 
	--     end

	--     local flag = false
	--     for i = 1, 31 do
	--         if hash[i] > 0 then
	--             if hash[i] == 2 then
	--                 if not flag then
	--                     flag = true
	--                 else
	--                     return -1
	--                 end
	--             else
	--                 return -1
	--             end
	--         end
	--     end

	--     return score
	-- end

	-- function f(card)
	--     local hash = {}
	--     for i = 1, 31 do
	--         hash[i] = 0
	--     end

	--     for k, v in ipairs(card) do
	--         hash[v] = hash[v] + 1
	--     end

	--     score = 0
	--     final_list = {}
	--     return get_hu_xi(hash)
	-- end


	-- local card = {0x02, 0x07, 0x0A}
	-- log("xxxxxxxx", f(card), final_list)
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
	for i=1,GAME_PLAYER do
		self.m_txtHuxi[i] = self.m_mainLayer:getChildByName("huxi_"..i)
		self.m_txtHuxi[i]:setVisible(false)
	end
end

function PHZMainLayer:isShowHuXiTxt(id)
	--for i,v in ipairs(self.m_txtHuxi) do
	--	v:setVisible(isShow)
	--end
	-- print('--isShowHuXiTxt---',id)
	-- if self.m_txtHuxi[id+1] then
		-- self.m_txtHuxi[id+1]:setVisible(true)
	-- end
end

--玩家头像集合
function PHZMainLayer:initHeadNode()
	self.m_headNode = {
	    [0] = self.PHZDownNode,
		[1] = self.PHZRPlayerNode,
		[2] = self.PHZTPlayerNode,
		[3] = self.PHZLPlayerNode,
	}
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

    self.m_BG = self.m_mainLayer:getChildByName("BG")

    local temp_zhunbei = self.m_mainLayer:getChildByName("btn_zhunbei_6")
    temp_zhunbei:setVisible(false)

   	self.btn_share = self.m_mainLayer:getChildByName("btn_share")

    self.btn_zhunbei = temp_zhunbei:clone()
    self.btn_zhunbei:setVisible(true)
    -- self.btn_setting = self.m_mainLayer:getChildByName("btn_setting")
    self.btn_distance = self.m_mainLayer:getChildByName("btn_distance")
    self.btn_distance:setVisible(false)

	self.btn_zhunbei:setTag(PHZMainLayer.TAG_BTN_ZHUNBEI)
	-- self.btn_setting:setTag(PHZMainLayer.TAG_BTN_SETTING)
	self.btn_distance:setTag(PHZMainLayer.TAG_BTN_DISTANCE)
	self.btn_share:setTag(PHZMainLayer.TAG_BTN_SHARE)
	self.btn_share:setVisible(true)
	self.btn_share:addTouchEventListener(onTouchButton)
    self.btn_zhunbei:addTouchEventListener(onTouchButton)
    -- self.btn_setting:addTouchEventListener(onTouchButton)
    self.btn_distance:addTouchEventListener(onTouchButton)

    self:addChild(self.btn_zhunbei,13)

    -- local voice_bt_worldpoint = (self.btn_yuyin:getParent()):convertToWorldSpace(self.btn_yuyin:getPosition())
    
    -- local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")

    -- if  VoiceRecordView.addVoiceRecordEvent then
    --     VoiceRecordView:addVoiceRecordEvent(self.btn_yuyin,999)
    -- else
    --     self.btn_yuyin:setVisible(false)
    --     VoiceRecordView:showView(voice_bt_worldpoint.x,voice_bt_worldpoint.y,999)
    -- end


    local   ddz_face= require("hall.FaceUI.faceUI") --require(TpackageName .. ".faceUI.faceUI") 
    
    local   ddz_face_node=ddz_face.new()
            ddz_face_node:setHandle(phzServer)
            self:addChild(ddz_face_node, 9999)
            ddz_face_node:setName("faceUI")

    -- local function onface_click(sender)
    --     local posx=sender:getPosition().x    --*0.75
    --     local posy=sender:getPosition().y    --*0.75 
    --     local pos = cc.p(posx,posy)
    --     ddz_face_node:showTxtPanle(pos, 8)
    -- end

    -- self.btn_xinxi:onClick(onface_click)

    self:setBGImg(cc.UserDefault:getInstance():getIntegerForKey("curentBGIndex",1))
	
	
	---gps按钮
    local gpsBtn = self.m_mainLayer:getChildByName("btn_gps")
    gpsBtn:setVisible(false)
    gpsBtn:onClick(function(event)
		if isOpenControl then
            phzServer:CLI_REQ_TEST_CARDS()
        else
            -- 玩法介绍同意风格
			local gpsLayer = GPSShowLayer.new()
			self:addChild(gpsLayer,1000)
			local temptab = {}
			for k,v in pairs(g_PHZMainScene.otherInfo) do
				table.insert(temptab,v)
			end
			gpsLayer:setInfo(temptab)
		end
		
    end)
end

function PHZMainLayer:showGPSButton()
    local temptab = {}
    for k,v in pairs(g_PHZMainScene.otherInfo) do
        table.insert(temptab,v)
    end
    local btn_gps = self.m_mainLayer:getChildByName("btn_gps")

	dump(temptab, 'temptab')
	print('--showGPSButton--',#temptab,debug.traceback())
	
    if #temptab == 1 then
        btn_gps:setVisible(false)
        return
    end

    local isWarning = 0
    for i=1,#temptab do
        for j=i+1,#temptab do
            if calculateDistance(temptab[i].latitude,temptab[j].latitude,temptab[i].longitude,temptab[j].longitude) <= 500 then
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

function PHZMainLayer:onCallBack(_tag)
	if _tag == PHZMainLayer.TAG_BTN_ZHUNBEI then
		self:clickBtnZhunBei()
	elseif _tag == PHZMainLayer.TAG_BTN_SETTING then
		-- self:clickBtnSetting()
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


function PHZMainLayer:setBGImg(_index)
	local tempStr = "pengpengzp/res/other/phz_bg_img".._index..".png"
	self.m_BG:setTexture(tempStr)
	
end

function PHZMainLayer:isShowZhunBeiBtn(isShow)
	self.btn_zhunbei:setVisible(isShow)
end

function PHZMainLayer:clickBtnDistance()
	-- self:showAllResultLayer(nil)
	-- self:AddOtherCardLayer(nil,{1,2,3,1,1,1,1,1,1,1,1,2,3,1,1,1,1,1,1,1})
	self:showDistanceLayer()
end

function PHZMainLayer:isShowBtnDistance(isShow)
	self.btn_distance:setVisible(isShow or false)
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
function PHZMainLayer:clickBtnZhunBei()
	print("===点击准备===")
	print("===点击准备===")
	print("===点击准备===")
	print("===点击准备===")
	self.btn_zhunbei:hide()

	self.btn_share:setVisible(false)
	self.btn_zhunbei:setVisible(false)

	if g_CardScene then
		g_CardScene:clearData()
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

--玩家自身信息Node
function PHZMainLayer:initDownNode()
	local _downNode = self.m_mainLayer:getChildByName("phzdownNode")
	self.PHZDownNode = require("pengpengzp.view.PHZDownNode").new(_downNode)
	_downNode:addChild(self.PHZDownNode)
	self.PHZDownNode:setVisible(false)
end

--房间上方信息NOde
function PHZMainLayer:initUpNode()
	self._upNode = self.m_mainLayer:getChildByName("phzupNode")
	self.PHZUpNode = require("pengpengzp.view.PHZUpNode").new()
	self._upNode:addChild(self.PHZUpNode)
	self.PHZUpNode:setVisible(false)
end

--上侧玩家Node
function PHZMainLayer:initTPlayerNode()
	local _tPlayerNode = self.m_mainLayer:getChildByName("phztplayerNode")
	self.PHZTPlayerNode = require("pengpengzp.view.PHZTPlayerNode").new(_tPlayerNode)
	_tPlayerNode:addChild(self.PHZTPlayerNode)
	self.PHZTPlayerNode:setVisible(false)
end

--左侧玩家Node
function PHZMainLayer:initLPlayerNode()
	local _lPlayerNode = self.m_mainLayer:getChildByName("phzlplayerNode")
	self.PHZLPlayerNode = require("pengpengzp.view.PHZLPlayerNode").new(_lPlayerNode)
	_lPlayerNode:addChild(self.PHZLPlayerNode)
	self.PHZLPlayerNode:setVisible(false)
end

--右侧玩家Node
function PHZMainLayer:initRPlayerNode()
	local _rPlayerNode = self.m_mainLayer:getChildByName("phzrplayerNode")
	self.PHZRPlayerNode = require("pengpengzp.view.PHZRPlayerNode").new(_rPlayerNode)
	_rPlayerNode:addChild(self.PHZRPlayerNode)
	self.PHZRPlayerNode:setVisible(false)
end

--吃牌操作Node
function PHZMainLayer:initOporateNode()
	local _oporateNode = self.m_mainLayer:getChildByName("phzoprorateNode")
	self.PHZOprorateNode = require("pengpengzp.view.PHZOprorateNode").new()
	self:addChild(self.PHZOprorateNode,PHZMainLayer.OPRORATENODE_TAG)
	self.PHZOprorateNode:setPosition(_oporateNode:getPosition())
	self.PHZOprorateNode:setVisible(false)
end

--初始化牌层
function PHZMainLayer:initCardScene()
	g_CardScene = CardLayer.new()
    self:addChild(g_CardScene,PHZMainLayer.CARDLAYER_TAG)
end

--加入吃牌层
function PHZMainLayer:AddChiCardLayer(cbIndex,curCard)
	self.phzChiCardLayer = ChiCardLayer.new(cbIndex,curCard)
	g_PHZChiCardLayer = self.phzChiCardLayer
	self:addChild(g_PHZChiCardLayer,PHZMainLayer.CHICARD_TAG)
end

--加入其他玩家剩余牌 层
function PHZMainLayer:AddOtherCardLayer(data1,data2)
	self.phzOtherCardLayer = OtherCardLayer.new(data1,data2)
	self:addChild(self.phzOtherCardLayer,PHZMainLayer.OTHERCARD_TAG)
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
    end,3)
end

--加入切换背景图片界面
function PHZMainLayer:clickBtnQieHuan()
	local tempSetBgLayer = SetBgLayer.new()
	self:addChild(tempSetBgLayer,PHZMainLayer.QIEHUAN_TAG)
end

--加入距离层
function PHZMainLayer:showDistanceLayer()
	local tempDistanceLayer = DistanceLayer.new()
	self:addChild(tempDistanceLayer,PHZMainLayer.DISTANCE_TAG)
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
	self:addChild(g_PHZTingNode,PHZMainLayer.TING_CARD_TAG)
	tempTingNode:setPosition(cc.p(80,250))
	tempTingNode:refreshTingCards(tempTingCardsData)

	-- test
	-- tempTingNode:refreshTingCards(nil)

end

--加入菜单层
function PHZMainLayer:showMenuLayer()
	-- local tempMenuLayer = MenuLayer.new()
	-- self:addChild(tempMenuLayer,PHZMainLayer.MENU_TAG)
end

--加入总结算层
function PHZMainLayer:showAllResultLayer(data)
    local tempAllResultLayer = AllResultLayer.new(data)
	self:addChild(tempAllResultLayer,PHZMainLayer.ALLRESULTLAYER_TAG)
end
function PHZMainLayer:updateBtnResult()
	ResultLayer:setBtnIsResult()
end
--加入设置层
function PHZMainLayer:showSettingLayer()
    local tempSettingLayer = SettingLayer.new()
	self:addChild(tempSettingLayer,PHZMainLayer.SETTING_TAG)
end

--初始化触摸层，放在牌层的上面
function PHZMainLayer:initTouchLayer()
	g_TouchLayer = GameTouchLayer.new()
    self:addChild(g_TouchLayer, PHZMainLayer.TOUCHLAYER_TAG)
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

--加入菜单层
function PHZMainLayer:showRoomCommonLayer()
	-- do return end
	self.roomCommonLayer = require("hall.roomCommonUI.RoomCommonPDKLayer").new(self:getToDisbandFuncs())
	self:addChild(self.roomCommonLayer, 9999)
	if tolua.isnull(self.roomCommonLayer.btnChange) == false then
		self.roomCommonLayer.btnChange:setVisible(false)
	end

	self.roomCommonLayer:setTouchSwallowEnabled(false)
	self.roomCommonLayer.roomInfoNode:setPosition(cc.p(5,730))
	--self.roomCommonLayer:setVisible(false)
	--self:loadGameMsgLayer()
	-- local tempMenuLayer = MenuLayer.new()
	-- self:addChild(tempMenuLayer,PHZMainLayer.MENU_TAG)
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
        -- self.moreFuncLayer = self:loadLayerByName("hall.roomCommonUI.GameMoreFuncLayer", 4)
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

------------------断线重连----------------------

return PHZMainLayer