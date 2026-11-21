--                            _ooOoo_
--                           o8888888o
--                           88" . "88
--                           (| -_- |)
--                            O\ = /O
--                        ____/`---'\____
--                      .   ' \\| |// `.
--                      / \\||| : |||// \
--                     / _||||| -:- |||||- \
--                       | | \\\ - /// | |
--                     | \_| ''\---/'' | |
--                      \ .-\__ `-` ___/-. /
--                   ___`. .' /--.--\ `. . __
--                ."" '< `.___\_<|>_/___.' >'"".
--               | | : `- \`.;`\ _ /`;.`/ - ` : | |
--                 \ \ `-. \_ __\ /__ _/ .-` / /
--         ======`-.____`-.___\_____/___.-`____.-'======
--                            `=---='
--
--         .............................................
--        传承         佛祖保佑             永无BUG

--local RoomlevelMap    =  import("FanSanPi.pintu.RoomlevelMap")
local UiCommon        =  import("FanSanPi.common.UiCommon")
local MenjiroomServer =  import("FanSanPi.FanSanPiServer")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local schedulerEvents = {}
local MenjiroomView   = class("MenjiroomView", function()
	return display.newScene("MenjiroomView")
end)
local Card = require("FanSanPi.common.PokerCard")
-- local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local headSize = 62
local user_node_y = 182.67
local card_panel_y = 152.33

local user5_={
	[1]={['x']=90,['y']=250},
	[2]={['x']=150,['y']=450},
	[3]={['x']=1130,['y']=450},
	[4]={['x']=1190,['y']=250},
}
local panel5_={
	[1]={['x']=180,['y']=220},
	[2]={['x']=240,['y']=420},
	[3]={['x']=880,['y']=420},
	[4]={['x']=940,['y']=220},
}

local user8_={
	[1]={['x']=100,['y']=200},
	[2]={['x']=80,['y']=380},
	[3]={['x']=200,['y']=560},
	[4]={['x']=550,['y']=630},
	[5]={['x']=1080,['y']=560},
	[6]={['x']=1200,['y']=380},
	[7]={['x']=1180,['y']=200},
}
local panel8_={
	[1]={['x']=150,['y']=160},
	[2]={['x']=130,['y']=340},
	[3]={['x']=250,['y']=520},
	[4]={['x']=600,['y']=590},
	[5]={['x']=860,['y']=520},
	[6]={['x']=980,['y']=340},
	[7]={['x']=960,['y']=160},
}

--按照传入的分隔符，切割字符串
function LuaSplit(str, split_char)
	if str == "" or str == nil then
		return {};
	end
	local split_len = string.len(split_char)
	local sub_str_tab = {};
	local i = 0;
	local j = 0;
	while true do
		j = string.find(str, split_char,i+split_len);--从目标串str第i+split_len个字符开始搜索指定串
		if string.len(str) == i then
			break;
		end


		if j == nil then
			table.insert(sub_str_tab,string.sub(str,i));
			break;
		end;


		table.insert(sub_str_tab,string.sub(str,i,j-1));
		i = j+split_len;
	end
	return sub_str_tab;
end

function MenjiroomView:ctor()
	self:setNodeEventEnabled(true)

	-- SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    -- SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
	collectgarbage("collect")
	print(collectgarbage("count"),"collectgarbage——ctor1")  --用于检测内存占用
	display.addSpriteFrames("FanSanPi/res/common_texture.plist", "FanSanPi/res/common_texture.png")
	display.addSpriteFrames("FanSanPi/res/NewImg/card/Plist.plist", "FanSanPi/res/NewImg/card/Plist.png")


	display.addSpriteFrames("FanSanPi/res/room/animation/headWinNew.plist", "FanSanPi/res/room/animation/headWinNew.png")

	display.addSpriteFrames("FanSanPi/res/room/compareCard/winner.plist", "FanSanPi/res/room/compareCard/winner.png")
	display.addSpriteFrames("FanSanPi/res/room/compareCard/boom.plist", "FanSanPi/res/room/compareCard/boom.png")
	display.addSpriteFrames("FanSanPi/res/room/compareCard/allCompare.plist", "FanSanPi/res/room/compareCard/allCompare.png")
	display.addSpriteFrames("FanSanPi/layout/PokerCard/Plist.plist", "FanSanPi/layout/PokerCard/Plist.png")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("FanSanPi/layout/LayerShuffling/Plist.plist")--开局之后进入会来不急加载
	MenjiroomView.isHide = false
	local csbPath = "FanSanPi/layout/room.csb"
	if device.platform == "ios" then
		if isiOSVerify then
			FanSanPiPanel  = cc.CSLoader:createNode(csbPath):addTo(self)
		else
			FanSanPiPanel   = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() ..csbPath):addTo(self)
		end
	else
		FanSanPiPanel   = cc.CSLoader:createNode(csbPath):addTo(self)
	end
	FanSanPiPanel:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH, SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
	GameUtils.setNodeNameBindObj(FanSanPiPanel)
	self:initUI()
	FanSanPiPanel:setName("FanSanPiPanel")
	self:setGameSetting()
	cc.Director:getInstance():getTextureCache():removeUnusedTextures();
	print(collectgarbage("count"),"collectgarbage——ctor2")  --用于检测内存占用
	--FanSanPiPanel:retain()
	bm.header_url=""
	bm.Room.iswith = false
	bm.Room.isover = false
	bm.Room.is_compare = true  --比牌回调后才可以点击其它事件
	bm.Room.msg_info=true

	PLAYER_HEADS_TABLE = {}
	PLAYER_HEADS_POSITION_TABLE = {}
	
	--local bar    = FanSanPiPanel:getChildByName("Image_2")
	--底部按键
	local base_foot=FanSanPiPanel:getChildByName("base_foot")
	base_foot:setLocalZOrder(9999)
	base_foot:setVisible(false)
	


	--比牌
	local btn = base_foot:getChildByName("bi_green")
	btn:setVisible(false)

	btn = base_foot:getChildByName("cp_green")
	btn:setVisible(false)
	

	--弃牌
	btn = base_foot:getChildByName("qi_green")
	if btn then
		btn:setOpacity(80)
		btn:setTouchEnabled(false)
		btn:addTouchEventListener(
			function(sender,event)
				--触摸结束
				if event == TOUCH_EVENT_ENDED then
					print("弃牌按钮")
					print(bm.Room.is_compare)
					if bm.Room.is_compare then
						require("hall.GameTips"):showTips("提示", "", 1, "确定弃牌？",nil, handler(MenjiroomView, MenjiroomView.procDiuCard))
						
						-- require("FanSanPi.view.CompareView"):showCampare(525,521,1)
					end
				end
			end
		)
	end

	--加注
	local jia_green = base_foot:getChildByName("jia_green")
	if jia_green then
		jia_green:setOpacity(80)
		jia_green:setTouchEnabled(false)
		jia_green:addTouchEventListener(
			function(sender,event)

				--触摸结束
				if event == TOUCH_EVENT_ENDED then
					print("加注按钮")
					print(bm.Room.is_compare)
					if bm.Room.is_compare then
						if sender._betState == 1 then
							MenjiroomServer:CLI_GEN_CARD(sender._betValue)
						else
							local allValue = sender._betValue + bm.Room.now_zhu/100
							print("加注---------------- ", sender._betValue ,bm.Room.now_zhu)
							MenjiroomServer:CLI_JIA_CARD(allValue)
							-- MenjiroomView:showJiaZhuView()
						end
						MenjiroomView:clearBipai()
						MenjiroomView:moveChipList()
					end
				end
			end
		)
	end



	--跟住
	local gen_green = base_foot:getChildByName("gen_green")
	if gen_green then
		gen_green:setOpacity(80)
		gen_green:setTouchEnabled(false)
		gen_green:addTouchEventListener(
			function(sender,event)

				--触摸结束
				if event == TOUCH_EVENT_ENDED then
					print("跟注按钮")
					print(bm.Room.is_compare)
					if bm.Room.is_compare then

						MenjiroomServer:CLI_GEN_CARD(sender._betValue)
						MenjiroomView:clearBipai()
						MenjiroomView:moveChipList()
					end
				end
			end
		)
	end

	--全押
	local quan_green = base_foot:getChildByName("quan_green")
	-- btn:setVisible(false)
	if quan_green then
		quan_green:setOpacity(80)
		quan_green:setTouchEnabled(false)
		quan_green:addTouchEventListener(
			function(sender,event)
				--触摸结束
				if event == TOUCH_EVENT_ENDED then
					print("加注按钮")
					print(bm.Room.is_compare)
					if bm.Room.is_compare then
						if sender._betState == 1 then
							print("click quan_green ----------------- ", sender._betValue)
							MenjiroomServer:CLI_GEN_CARD(sender._betValue)
						else
							local allValue = sender._betValue + bm.Room.now_zhu/100
							print("加注---------------- ", sender._betValue ,bm.Room.now_zhu)
							MenjiroomServer:CLI_JIA_CARD(allValue)
						end
						MenjiroomView:moveChipList()
						MenjiroomView:clearBipai()
					end
				end
			end
		)
	end

	--秀牌
	local showCardGreen = FanSanPiPanel:getChildByName("showCardGreen")
	-- btn:setVisible(false)
	if showCardGreen then
		-- showCardGreen:setOpacity(80)
		showCardGreen:setVisible(false)
		showCardGreen:addTouchEventListener(
			function(sender,event)
				--触摸结束
				if event == TOUCH_EVENT_ENDED then
					MenjiroomServer:CLIENT_COMMAND_USER_SHOW_CARD()
				end
			end
		)
	end
	
	local btn_record = FanSanPiPanel:getChildByName("btn_record")
	btn_record:setVisible(false)

	local btn_msg=FanSanPiPanel:getChildByName("btn_msg")
    btn_msg:addTouchEventListener(
		function(sender,event)
			--触摸开始
			if event == TOUCH_EVENT_BEGAN then
				sender:setScale(0.9)
			end

			--触摸取消
			if event == TOUCH_EVENT_CANCELED then
				sender:setScale(1.0)
			end
			--触摸结束
			if event == TOUCH_EVENT_ENDED then
				sender:setScale(1.0)
				--if bm.Room.msg_info then
				--	bm.Room.msg_info=false
				--	FanSanPiPanel:getChildByName("base_chip"):setVisible(true)
				--else
				--	bm.Room.msg_info=true
				--	FanSanPiPanel:getChildByName("base_chip"):setVisible(false)
				--end
				--MenjiroomView:cuopaiTest()
				if isOpenControl then
					require(TpackageName..".ChoiceCard"):init()
				else
					local gameConfig = USER_INFO["gameConfig"]
					require("hall.util.GameMenu"):showConfigPanel(gameConfig)
					--require(TpackageName..".ChoiceCard"):init2()
				end
			end
		end)
	btn_msg:setVisible(true)
	
	--文字聊天界面
	local faceUI = require("hall.FaceUI.faceUI")

	local faceUI_node = faceUI.new();
	faceUI_node:setHandle(bm.server:getHandle())
	-- FanSanPiPanel:addChild(faceUI_node, 9999)
	self:addChild(faceUI_node, 9999)
	faceUI_node:setName("faceUI")
	
	local btn_chat = FanSanPiPanel:getChildByName("btn_chat")
	if btn_chat then
		btn_chat:addTouchEventListener(
			function(sender,event)

				--触摸结束
				if event == TOUCH_EVENT_ENDED then
					if bm.Room.is_compare then
						self:loadGameMsgLayer()
					end
				end
			end
		)
	end
    btn_chat:setVisible(false)
	--邀请好友
	--邀请微信好友
	local invite_ly = FanSanPiPanel:getChildByName("invite_ly")
	invite_ly:setVisible(false)
	-- invite_ly:setLocalZOrder(9999999)
	local share_btn = invite_ly:getChildByName("share_btn")
	if share_btn then
		share_btn:setVisible(true)
		share_btn:addTouchEventListener(
			function(sender,event)
				--触摸开始
				if event == TOUCH_EVENT_BEGAN then
					sender:setScale(0.8)
				end

				--触摸取消
				if event == TOUCH_EVENT_CANCELED then
					sender:setScale(1.0)
				end

				--触摸结束
				if event == TOUCH_EVENT_ENDED then
					sender:setScale(1.0)
					local paras = {}
					paras["desc"] =  USER_INFO["gameConfigMsg"]
					paras["imagePath"] = "url"
					paras["name"] = "赢三张，房号：" .. USER_INFO["invote_code"]
					paras["showType"] = 2;
					paras["url"] = appDownLoadAddress
					local shareLayer = require("hall.share.ShareLayer").new(paras)
					if shareLayer then
						shareLayer:addTo(SCENENOW["scene"],9999999)
					end
				end
			end
		)
	end
	local btnSetting   = FanSanPiPanel:getChildByName("btn_settings")
	local ready_plane = FanSanPiPanel:getChildByName("ready_plane")
	local btn_stand_up = nil
	local btn_sit_down = FanSanPiPanel:getChildByName("btn_sit_down"):setVisible(false)
	local btn_ready = nil
	if ready_plane then
		ready_plane:setVisible(false)
		btn_ready = ready_plane:getChildByName("btn_ready")
		btn_ready:retain()
		btn_stand_up = ready_plane:getChildByName("btn_stand_up")
		if GROUP_MODE == 1 then
			btn_stand_up:setVisible(false)
			ready_plane:setPosition(cc.p(ready_plane:getPositionX()-70,ready_plane:getPositionY()))
		end

	end
	if btnSetting then
		btnSetting:setTouchEnabled(true)
		btnSetting:setVisible(true)
	end
	
	
	self:isKanButton(false)
	local function touchButtonEvent(sender, event)
		--缩小ui
		if event == TOUCH_EVENT_BEGAN then
			require("hall.GameCommon"):playEffectSound("hall/scene/res/common/music/Audio_Button_Click.mp3")
			local stSmall = cc.ScaleTo:create(0.1, 0.8)
			local stNormal = cc.ScaleTo:create(0.1, 1)
			local sq = cc.Sequence:create(stSmall, stNormal)
			sender:runAction(sq)
		end

		if event == TOUCH_EVENT_ENDED then
			local stBig = cc.ScaleTo:create(0.1,1.3)
			local stNormal = cc.ScaleTo:create(0.1,1)
			local sq = cc.Sequence:create(stBig,stNormal)
			sender:runAction(sq)

			if sender == btnEixt then--返回赛场选择
				sender:setScale(1.0)
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
							-- dump(data, "检查当前组局状态")
							if data == 1 then
								--创建组局
								require("hall.GameTips"):showTips("提示", "tohall", 1, "你正在房间中，是否返回大厅？")

							elseif data == 2 then
								--开始组局
								require("hall.GameTips"):showTips("提示", "", 2, "游戏已经开始，不能返回大厅")

							elseif data == 0 then
								--结束组局
								require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")

							end
						else
							require("hall.GameTips"):showTips("提示", "", 2, "游戏数据异常，不能退出房间")
						end

					end
				})
			end
			--设置
			if sender == btnSetting then


				self:loadMoreFuncLayer()
			end
			if sender == btn_stand_up then

				MenjiroomServer:CLI_STAND_UP()

			end
			if sender == btn_sit_down then
				local seat_id = -1
				MenjiroomServer:CLI_SIT_DOWN(seat_id)
			end
			if sender == btn_ready then
				dump("btn_readyrr")
				MenjiroomView:readyRoom()
			end
		end
	end

	if btnSetting then
		btnSetting:addTouchEventListener(touchButtonEvent)
	end
	if btn_stand_up then
		btn_stand_up:addTouchEventListener(touchButtonEvent)
	end
	if btn_ready then
		btn_ready:onClick(function()
			MenjiroomView:readyRoom()
		end)
	end
	if btn_sit_down then
		btn_sit_down:addTouchEventListener(touchButtonEvent)
	end
	if self.btn_kan then
		self.btn_kan:setVisible(false)
	end
	self:showGroupInfo()

	self:resetUserInfo()
	--[[local node = display.newNode()
	node:addTo(self)
	node:setName("drawnode")]]
	FanSanPiPanel:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
		if event.name == "began" then
			--[[local base_foot=FanSanPiPanel:getChildByName("base_foot")
			local move2 = cc.MoveTo:create(0.2,cc.p(5.07,548.51))
			base_foot:runAction(move2)]]
		end
	end)
	local clock = FanSanPiPanel:getChildByName("clock")
	local clock_txt = clock:getChildByName("text_center")
	clock_txt:stopAllActions()
	clock:setVisible(false)
	local lbVersion = ccui.Text:create()
	lbVersion:setString("1.0.10")
	lbVersion:setFontSize(18)
	lbVersion:setColor(cc.c3b(125, 125, 125))
	lbVersion:setPosition(cc.p(FanSanPiPanel:getContentSize().width - lbVersion:getContentSize().width / 2, lbVersion:getContentSize().height / 2))
	FanSanPiPanel:addChild(lbVersion, 9999)

	local btn_startgame=FanSanPiPanel:getChildByName("btn_startgame")
	if btn_startgame then
		btn_startgame:addTouchEventListener(function(sender,event)
			--触摸开始
			if event == TOUCH_EVENT_BEGAN then
				sender:setScale(0.8)
			end
	
			--触摸取消
			if event == TOUCH_EVENT_CANCELED then
				sender:setScale(1.0)
			end
	
			--触摸结束
			if event == TOUCH_EVENT_ENDED then
				sender:setScale(1.0)
				MenjiroomServer:BROADCAST_START_GAME()
			end
		end)
		btn_startgame:setVisible(false)
	end
	
	self:setGuanZhanVisible(false)

	self:setChipsSumVisible(false)
	self:setPiaoOptBtnVisible(false)
	-- ZJH_USER_UID_PLAYING= {
	-- 	[666681] = 1,
	-- 	[666683] = 1
	-- }
	-- ZJH_USER_UID= {
	-- 	[666681] = 1,
	-- 	[666683] = 0
	-- }
	-- ZJH_PLAYERTYPE_TABLE= {
	-- 	[666681] = 1,
	-- 	[666683] = 0
	-- }
	-- MenjiroomView:showProgressTimer(uid,time)
    -- require("FanSanPi.view.CompareView"):clearActions()
	-- require("FanSanPi.view.CompareView"):showCampare()
	-- ChoiceCard:showPanel()
	-- require(TpackageName..".ChoiceCard"):init()

	-- print(FanSanPiPanel:getScaleX())
	-- print(FanSanPiPanel:getScaleY())
	-- print(1)

	local EmojiArmatureView = require("hall.EmojiArmatureView.EmojiArmatureView"):newEmojiArmatureView(self:getToSendFaceAndTxtFuncs(), self)
  	EmojiArmatureView:setLocalZOrder(10000)
	g_mainRoomLayer = self
end

function MenjiroomView:procDiuCard()
	MenjiroomServer:CLI_DIU_CARD()
	isDiscard=true
	MenjiroomView:clearBipai()
	MenjiroomView:moveChipList()
end

function MenjiroomView:reConnect()
	--SanGongSendHandle:LoginRoom(USER_INFO["tid"],USER_INFO["seat"],USER_INFO["activity_id"])
	require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function MenjiroomView:LoginRoom()
	local PROTOCOL = require("FanSanPi.FanSanPiProtocol")
	local FSPHandle = require("FanSanPi.FanSanPiHandle") -- ZjhHandle
	bm.server:setProtocol(PROTOCOL)
	bm.server:setHandle(FSPHandle.new())
	require("FanSanPi.FanSanPiServer"):enterRoom()
end
--function MenjiroomView:reConnect()
--	dump("MenjiroomScenes:reConnect")
--	require("FanSanPi.FanSanPiServer"):enterRoom()
--end

function MenjiroomView:showShare(flag)
	local scenes  = FanSanPiPanel
	local invite_ly = scenes:getChildByName("invite_ly")
	-- invite_ly:setLocalZOrder(9999999)
	local round = bm.Room.GroupInfo and tonumber(bm.Room.GroupInfo["round"]) or nil
	if round and round >= 1 and flag then
		flag = false
	end
	if g_isWatch == 0 then
        flag = false
    end
	invite_ly:setVisible(false)
end

--观战标志可视设置
function MenjiroomView:setGuanZhanVisible(flag)
	local scenes  = FanSanPiPanel
	local guanZhan_img = scenes:getChildByName("guanZhan_img")
	guanZhan_img:setVisible(flag)
end

function MenjiroomView:showstartgame(flag)
	local scenes  = FanSanPiPanel
	local btn_startgame = scenes:getChildByName("btn_startgame")
	if btn_startgame then
		btn_startgame:setVisible(flag)
	end
end

function MenjiroomView:startGameTime(time)
    local scenes  = FanSanPiPanel
    if scenes and false then
        local clock = scenes:getChildByName("clock_start")
        clock:setLocalZOrder(999)
        local clock_txt = clock:getChildByName("text_center")
        clock_txt:stopAllActions()
        -- local clock_bottom = clock:getChildByName("clock_bottom")
        if  time <= 0 then
            clock:setVisible(false)
            return
        else
            clock:setVisible(true)
        end
        local tmp = clock:getChildByName("clock_progress")
        if tmp == nil then
        	tmp = cc.ProgressTimer:create(cc.Sprite:create("FanSanPi/res/NewImg/clock_progress_dark.png"))
        	tmp:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        	--tmp:setMidpoint(cc.p(0.5, 0.5))
        	-- tmp:setPosition(clock_bottom:getPosition())
        	tmp:addTo(clock, 99)
        	tmp:setName("clock_progress")
        end

        local  timer_value = time
        local  refreshTime = 1

        clock_txt:setString("倒计时:"..tostring(timer_value))

        tmp:setPercentage(0)
        local showProgressAc = cc.ProgressTo:create(timer_value,100)
        tmp:runAction(showProgressAc)

        local showTimerAc = cc.CallFunc:create(function()
            timer_value = timer_value - refreshTime
            clock_txt:setString("倒计时:"..tostring(timer_value))
            if timer_value <= 0 then

                --				if tmp then
                --					tmp:stopAllActions()
                --					tmp:removeSelf()
                --				end
                clock_txt:stopAllActions()
                clock:setVisible(false)
            end
        end)
        local seqAc = cc.Sequence:create(cc.DelayTime:create(refreshTime), showTimerAc)
        clock_txt:runAction(cc.RepeatForever:create(seqAc))
    end
end

function MenjiroomView:showStartTimer(time)
	local scenes  = FanSanPiPanel
	if scenes then
		local clock = scenes:getChildByName("clock")
		clock:setLocalZOrder(999)
		local clock_txt = clock:getChildByName("text_center")
		clock_txt:stopAllActions()
		-- local clock_bottom = clock:getChildByName("clock_bottom")
		if  time <= 0 then
			clock:setVisible(false)
			return
		else
			clock:setVisible(true)
		end
		--local tmp = clock:getChildByName("clock_progress")
		--if tmp == nil then
		--	tmp = cc.ProgressTimer:create(cc.Sprite:create("FanSanPi/res/NewImg/clock_progress_dark.png"))
		--	tmp:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
		--	--tmp:setMidpoint(cc.p(0.5, 0.5))
		--	tmp:setPosition(clock_bottom:getPosition())
		--	tmp:addTo(clock, 99)
		--	tmp:setName("clock_progress")
		--end

		local  timer_value = time
		local  refreshTime = 1

		clock_txt:setString("倒计时:"..tostring(timer_value))

		--tmp:setPercentage(0)
		--local showProgressAc = cc.ProgressTo:create(timer_value,100)
		--tmp:runAction(showProgressAc)

		local showTimerAc = cc.CallFunc:create(function()
			timer_value = timer_value - refreshTime
			clock_txt:setString("倒计时:"..tostring(timer_value))
			if timer_value == 0 then

				--				if tmp then
				--					tmp:stopAllActions()
				--					tmp:removeSelf()
				--				end
				clock_txt:stopAllActions()
				clock:setVisible(false)
			end
		end)
		local seqAc = cc.Sequence:create(cc.DelayTime:create(refreshTime), showTimerAc)
		clock_txt:runAction(cc.RepeatForever:create(seqAc))
	end
end

function MenjiroomView:resultTime(time,btn_next,callback)
	local  timer_value = time
	if timer_value > 0 then
		btn_next:stopAllActions()
		local refreshTime = 1
		local showTimerAc = cc.CallFunc:create(function()
			timer_value = timer_value - refreshTime
			btn_next:setTitleText("下一局" ..tostring(timer_value))
			if timer_value == 0 then

				--				if tmp then
				--					tmp:stopAllActions()
				--					tmp:removeSelf()
				--				end
				btn_next:stopAllActions()
				callback()
			end
		end)
		local seqAc = cc.Sequence:create(cc.DelayTime:create(refreshTime), showTimerAc)
		btn_next:runAction(cc.RepeatForever:create(seqAc))
	else
		btn_next:stopAllActions()
	end

end
function MenjiroomView:stopTimer()
	local scenes  = FanSanPiPanel
	if scenes then
		local clock = scenes:getChildByName("clock")
		local clock_txt = clock:getChildByName("text_center")
		clock_txt:stopAllActions()
		clock:setVisible(false)
	end
	if bm.Room.seatProgressTimer ~= nil then
		if bm.Room.seatProgressTimer:getParent() then
			bm.Room.seatProgressTimer:hide()
		end
		bm.Room.seatProgressTimer = nil
	end
end

function MenjiroomView:stopStartTimer()
	local scenes  = FanSanPiPanel
	if scenes then
		local clock = scenes:getChildByName("clock_start")
		local clock_txt = clock:getChildByName("text_center")
		clock_txt:stopAllActions()
		clock:setVisible(false)
	end
	if bm.Room.seatProgressTimer ~= nil then
		if bm.Room.seatProgressTimer:getParent() then
			bm.Room.seatProgressTimer:hide()
		end
		bm.Room.seatProgressTimer = nil
	end
end
--显示和隐藏用户信息
function MenjiroomView:drawUser(flag, index, strIco, uid, sex,nickName, ip, addres)
	--新录音位置显示
	require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(uid, MenjiroomView:getHeadPos(index))
	print("drawUser ------------------------- ", debug.traceback())
	local scenes  =FanSanPiPanel

	--local scenes  = FanSanPiPanel
	local info = self:getUserNodeByIndex(index)
	if flag then
		info:setVisible(true)
		local head = self:getHeadNode(info)
		if head then
			local head_info = {}
			head_info["icon_url"] = strIco or DefaultHead_filePath
			head_info["uid"] = uid
			head_info["sex"] = sex
			head_info["sp"] = head
			head_info["size"] = headSize
			head_info["touchable"] = 1
			head_info["use_sharp"] = 1
			head_info["nickName"] = nickName
			-- require("hall.GameCommon"):setPlayerHead(head_info, head, 74)
			-- require("hall.GameCommon"):getUserHead(strIco, head_info["uid"], head_info["sex"], head, headSize, true)
			require("hall.GameCommon"):getUserHead(strIco, uid, sex, head, head:getContentSize().width , false, nickName, false, ip, addres)
			local worldpoint = (info):convertToWorldSpace(head:getPosition()) --这样写是为了贴近函数的原始用法
			self.worldpoint = worldpoint

			PLAYER_HEADS_TABLE[uid] = info
			PLAYER_HEADS_POSITION_TABLE[uid] = worldpoint
		end
	else
		info:setVisible(false)
	end
end
-- 组局信息
function MenjiroomView:showGroupInfo()
	--组局显示邀请码
	local base_chip=FanSanPiPanel:getChildByName("base_chip")
	local room_info=FanSanPiPanel:getChildByName("room_info")
	local lb = room_info:getChildByName("txt_invitecode")
	-- local text_desc_number = room_info:getChildByName("text_desc_number")
	--local txt_config = base_chip:getChildByName("txt_config")
	--if txt_config then
	--	if USER_INFO["gameConfig"] then
	--		txt_config:setString(USER_INFO["gameConfig"])
	--	end
    --
	--end
	--txt_config:ignoreContentAdaptWithSize(false)
	--txt_config:setSize(cc.size(376, 50));
	if lb then
		print("set invote_code:",tostring(USER_INFO["invote_code"]))
		if USER_INFO["invote_code"] then
			lb:setString("房间号："..USER_INFO["invote_code"])
			--MenjiroomView.roomCommonLayer:setRoomNum(USER_INFO["invote_code"])
		end
		lb:setVisible(true)
	end
	--self:setGameConfig()
	if bm.Room.GroupInfo then
		self:updateRounds(bm.Room.GroupInfo["round"], bm.Room.GroupInfo["total_round"])
	end
end

-- 更新组局局数
function MenjiroomView:updateRounds(curr_round, total_round)
	dump("setGameSetting905")
	--MenjiroomView.roomCommonLayer:setRoomRound(curr_round+1, total_round)

	local room_info=FanSanPiPanel:getChildByName("room_info")
	local txt_game_no = room_info:getChildByName("txt_game_no")
	-- local txt_game = room_info:getChildByName("txt_game")
	txt_game_no:setString("局数："..tostring(curr_round+1).."/"..tostring(total_round))
	-- if GROUP_MODE == 1 then
	-- 	txt_game_no:setVisible(true)
	-- 	txt_game:setVisible(true)
	-- else
	-- 	txt_game_no:setVisible(false)
	-- 	txt_game:setVisible(false)

	-- end
	--[[local txt_game_no = FanSanPiPanel:getChildByName("p_game_no"):getChildByName("txt_game_no")

    if txt_game_no then
        txt_game_no:setVisible(true)
        txt_game_no:setString(tostring(curr_round+1).."/"..tostring(total_round))
    end]]
end

-- 设置底注
function MenjiroomView:setBaseChip(value)
	local p_base_chip = FanSanPiPanel:getChildByName("base_chip")
	if p_base_chip then
		local txt_base_chip = p_base_chip:getChildByName("txt_chip")
		txt_base_chip:setString("底注："..tostring(value))
	end
end

--房间配置
function MenjiroomView:setGameConfig()
	local panel = FanSanPiPanel:getChildByName("p_game_config")
	local txt_config = panel:getChildByName("txt_config")
	if txt_config then
		txt_config:setVisible(true)
		txt_config:setString(USER_INFO["gameConfig"])
		local backWith = txt_config:getContentSize().width+20
		local img_back = panel:getChildByName("Image_21")
		if img_back then
			print("setGameConfig")
			img_back:setContentSize(cc.size(backWith,37))
		end
		--调整局数位置
		local panelGameno = FanSanPiPanel:getChildByName("p_game_no")
		if panelGameno then
			panelGameno:setPositionX(480-backWith/2)
		end
		--调整底注位置
		local p_base_chip = FanSanPiPanel:getChildByName("p_base_chip")
		if p_base_chip then
			p_base_chip:setPositionX(480+backWith/2)
		end
	end
end
--解散房间
function MenjiroomView:disbandGroup()
	if g_isWatch == 0 then
		require("hall.GameTips"):showTips("提示", "", 1, "旁观不能解散房间")
		return
	end

	local function send_disband()
		require("FanSanPi.FanSanPiServer"):C2G_CMD_DISSOLVE_ROOM()
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
				if data == 1 then
					--创建组局
					require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "当前解散房间不需扣除房卡，是否解散？",_,send_disband)

				elseif data == 2 then
					--开始组局
					require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "当前已经扣除房卡，是否申请解散房间？",_,send_disband)

				elseif data == 0 then
					--结束组局
					require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")

				end
			else

			end

		end
	})

end

function MenjiroomView:showMyinfo()
	local index=MenjiroomView:getIndex(USER_INFO["uid"])
	if index == nil then
		print("error",debug.getinfo(1).currentline,debug.getinfo(1).name)
		return
	end
	self:drawUser(true,index, USER_INFO["icon_url"], USER_INFO["uid"], USER_INFO["sex"],USER_INFO["sex"])
	local scenes  = FanSanPiPanel
	local node=scenes:getChildByName("player_plane_1");
	local num = UiCommon:numFormat(bm.User.Gold)
	self:setGoldString(node, num)--设置金币数
	local nameStr = require("FanSanPi.FanSanPiSettings"):GetShortName(USER_INFO["nick"],9,6)
	self:setNickString(node, nameStr)--设置昵称
end
function MenjiroomView:settingsGold(uid,gold)
	local index=ZJH_PLAYERTYPE_TABLE[uid]
	if index == nil then
		print("error",debug.getinfo(1).currentline,debug.getinfo(1).name)
		return
	end
	local scenes  = FanSanPiPanel
	local node = self:getUserNodeByIndex(index)
	if node == nil then
		return
	end
	ZJH_USER_TOTAL_CHIPS[uid] = gold
	local value = tonumber(ZJH_USER_TOTAL_CHIPS[uid])/100
	if value and value > 100000 then
		local finalChipTxt = tostring(value/10000)
		value = string.format("%.1f", finalChipTxt) .. "万"
	end
	self:setGoldString(node, value)
end

function MenjiroomView:updataUserGold(uid,chips)
	dump(chips,"player golds!!!")
	local index=ZJH_PLAYERTYPE_TABLE[uid]
	if index == nil then
		print("error",debug.getinfo(1).currentline,debug.getinfo(1).name)
		return
	end
	local scenes  = FanSanPiPanel
	local node = self:getUserNodeByIndex(index)
	if node == nil then
		return
	end
	if chips then

		ZJH_USER_TOTAL_CHIPS[uid] = chips
		if ZJH_USERINFO_TABLE[uid] then
			ZJH_USERINFO_TABLE[uid].m_chips = chips
		end

		-- if ZJH_USERINFO_TABLE[uid] then
		-- 	local finalChip = ZJH_USERINFO_TABLE[uid].m_chips
		-- 	MenjiroomView:setCoin(uid,finalChip)
		-- end

		local value = tonumber(ZJH_USER_TOTAL_CHIPS[uid])/100
		if value and value > 100000 then
			local finalChipTxt = tostring(value/10000)
			value = string.format("%.1f", finalChipTxt) .. "万"
		end
		self:setGoldString(node, value)
	end

end

function MenjiroomView:showNextReady(flag)
	local scenes  = FanSanPiPanel
	local next_btn=scenes:getChildByName("next_btn")
	if next_btn then
		next_btn:setVisible(flag);
		next_btn:setLocalZOrder(101)
		next_btn:addTouchEventListener(function (sender,event)
			--触摸开始
			if event == TOUCH_EVENT_BEGAN then
				sender:setScale(0.9)
			end

			--触摸取消
			if event == TOUCH_EVENT_CANCELED then
				sender:setScale(1.0)
			end

			--触摸结束
			if event == TOUCH_EVENT_ENDED then
				sender:setScale(1.0)
				if bm.Room.is_compare then
					local scenes  = FanSanPiPanel
					if bm.Room.iswith == true then
						local zhezhao = scenes:getChildByName("zhezhao")
						if zhezhao ~= nil then
							zhezhao:removeSelf()
						end
						local next_btn=scenes:getChildByName("next_btn")
						if next_btn then
							next_btn:setVisible(false)
						end
						local accountScene= scenes:getChildByName("accountScene")
						if accountScene~=nil then
							accountScene:setVisible(true)
							local total_panel=accountScene:getChildByName("total_panel")
							total_panel:setVisible(true)
							local single_panel=accountScene:getChildByName("single_panel")
							single_panel:setVisible(false)
							local end_btn=total_panel:getChildByName("foot_panle"):getChildByName("end_btn")
							local share_btn=total_panel:getChildByName("foot_panle"):getChildByName("share_btn")
							end_btn:setEnabled(true)
							end_btn:addTouchEventListener(function(sender,event)
								--触摸开始
								if event == TOUCH_EVENT_BEGAN then
									sender:setScale(0.9)
								end

								--触摸取消
								if event == TOUCH_EVENT_CANCELED then
									sender:setScale(1.0)
								end

								--触摸结束
								if event == TOUCH_EVENT_ENDED then
									sender:setScale(1.0)

									--退出房间，返回大厅
									USER_INFO["gameConfig"] = ""
									require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)

								end
							end)
							share_btn:addTouchEventListener(function(sender,event)
								--触摸结束
								if event == TOUCH_EVENT_ENDED then
									local paras = {}
									paras["showType"] = 2;
									paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
									paras["imagePath"] = "screen"
									paras["name"] = "分享结果"
									paras["url"] = appDownLoadAddress
									local shareLayer = require("hall.share.ShareLayer").new(paras)
									if shareLayer then
										shareLayer:addTo(SCENENOW["scene"],9999999)
									end
									--if device.platform == "android" then
									--	local paras = {}
									--	paras["desc"] =  USER_INFO["gameConfigMsg"]
									--	paras["imagePath"] = "screen"
									--	paras["name"] = "分享结果"
									--	local shareLayer = require("hall.share.ShareLayer").new(paras)
									--	if shareLayer then
									--		shareLayer:addTo(SCENENOW["scene"])
									--	end
									--	require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
									--elseif device.platform ~= "windows" then
									--	require("hall.common.ShareLayer"):shareGroupResultForIOS()
									--end
								end

							end)
						end
					else
						bm.SchedulerPool:clearAll()
						-- MenjiroomView:clearDesk()
						MenjiroomView:readyRoom()
						bm.Room.over = true
					end
				end
			end
		end)


	end
end

--显示用户准备
function MenjiroomView:showReady(uid,flag)
	if flag == nil then
		flag = false
	end
	local scenes  = FanSanPiPanel
	local index = ZJH_PLAYERTYPE_TABLE[uid]
	if index == nil then
		print("error",debug.getinfo(1).currentline,debug.getinfo(1).name)
		return nil
	end
	local user_node = self:getUserNodeByIndex(index)
	if user_node == nil then
		return nil
	end
	print("UID uid", USER_INFO["uid"] .."uid"..uid.."index"..tostring(index))

	if uid == USER_INFO["uid"] or index == 0 then
		local next_btn=scenes:getChildByName("next_btn")
		if next_btn then
			next_btn:setVisible(false)
		end

		local change   = scenes:getChildByName("mychange")
		if change ~= nil  then
			change:removeSelf()
		end

		if g_isWatch == 1 then
			self:setReadyVisible(user_node, flag)
		else
			self:setReadyVisible(user_node, flag)
		end
		--self:setReadyVisible(user_node, true)
	else
		self:setReadyVisible(user_node, flag)
	end

end
function MenjiroomView:showControlButtons(flag)

	if FanSanPiPanel == nil then
		return
	end
	local ready_plane =FanSanPiPanel:getChildByName("ready_plane")
	if ready_plane then
		if g_isWatch == 0 then
			flag = false
        end
		ready_plane:setVisible(flag)
	end
	if GROUP_MODE == 1 then
		local btn_stand_up = ready_plane:getChildByName("btn_stand_up")
		local btn_ready = ready_plane:getChildByName("btn_ready")
		btn_ready:setPositionX(ready_plane:getContentSize().width/2)
		btn_stand_up:setVisible(false)
	end
end
function MenjiroomView:showSitDownButton(flag)

	local scenes  = FanSanPiPanel
	local btn_sit_down =scenes:getChildByName("btn_sit_down")
	if btn_sit_down then
		btn_sit_down:setVisible(flag)
	end
end
function MenjiroomView:showButtonAfterSitDown(flag)


end
--改变位置
function MenjiroomView:change_seat(maxpeople)
	-- local scenes = FanSanPiPanel
	-- local panel_card = self:getPanelCardsNode()
	-- for i=1,maxpeople-1 do
	-- 	local user_ = self:getUserNodeByIndex(i)
	-- 	local panel_ = self:getPanelCardNodeByIndex(i)
	-- 	local chip_bg = self:getChipBgNode(user_)
	-- 	if maxpeople == 5 then
	-- 		panel_:setAnchorPoint(cc.p(0,0))
	-- 		user_:setPosition(cc.p(user5_[i].x,user5_[i].y))
	-- 		panel_:setPosition(cc.p(panel5_[i].x,panel5_[i].y))
	-- 		local ccp=user_:convertToNodeSpace(panel_card:convertToWorldSpace(cc.p(panel5_[i].x,panel5_[i].y)))
	-- 		if panel5_[i].x <= cc.Director:getInstance():getWinSize().width/2 then
	-- 			chip_bg:setPosition(cc.p(ccp.x+panel_:getContentSize().width/2-20,ccp.y-30))
	-- 		else
	-- 			chip_bg:setPosition(cc.p(ccp.x+panel_:getContentSize().width/2+60,ccp.y-30))
	-- 		end
	-- 	elseif maxpeople == 8 then
	-- 		panel_:setAnchorPoint(cc.p(0,0))
	-- 		user_:setPosition(cc.p(user8_[i].x,user8_[i].y))
	-- 		panel_:setPosition(cc.p(panel8_[i].x,panel8_[i].y))
	-- 		local ccp=user_:convertToNodeSpace(panel_card:convertToWorldSpace(cc.p(panel8_[i].x,panel8_[i].y)))
	-- 		chip_bg:setPosition(cc.p(ccp.x+panel_:getContentSize().width/2+20,ccp.y-20))
	-- 	else
	-- 		return
	-- 	end
	-- end
end
--显示用户信息
function MenjiroomView:showUserInfo(data)
	print("showUserInfo ---------------------", debug.traceback())
	-- body
	local index   = MenjiroomView:getIndex(data.uid)

	if index == nil then
		print("error",debug.getinfo(1).currentline,debug.getinfo(1).name)
		return
	end
	ZJH_PLAYERTYPE_TABLE[data.uid] = index
	if data.uid == USER_INFO["uid"] then
		if g_isWatch == 1 then
			FanSanPiPanel:getChildByName("btn_chat"):setVisible(true)
		else
			FanSanPiPanel:getChildByName("btn_chat"):setVisible(true)
		end
		FanSanPiPanel:getChildByName("btn_voice"):setVisible(true)--false
	end

	local scenes  = FanSanPiPanel

	local user_node = self:getUserNodeByIndex(index)
	if user_node == nil then
		return
	end
	user_node:setLocalZOrder(9998)

	local gold_back = self:getChipBgNode(user_node)
	if ZJH_USER_UID_PLAYING[data.uid] == 1 and ZJH_GAME_STATE == GAME_STATUS_OUTCARD then
		gold_back:setVisible(true)
	end
	-- if TOTAL_PLAYERNUM == 5 then
	-- 	 user_node:setScale(1)
	-- 	-- if index == 1 or index == 9 then
	-- 	-- 	local y = user_node_y * 1.2
	-- 	-- 	user_node:setPositionY(y)
	-- 	-- end
	-- 	if index == 0 then
	-- 		gold_back:setPosition(cc.p(655,210))
	-- 	end
	-- end
	--local info = json.decode(data["info"])
	--金币数量
	--local num = UiCommon:numFormat(data['m_chips'])
	local finalChip = tonumber(data['m_chips'])
	if finalChip then
		MenjiroomView:setCoin(data.uid,finalChip)
		--if  finalChip > 10000 then
		--	local finalChipTxt = tostring(finalChip/10000)
		--	if string.len(finalChipTxt) <= 4 then
		--		finalChip = string.format("%.1f", finalChipTxt) .. "万"
		--	else
		--		local endlength = string.find(finalChipTxt,"%.")
		--		finalChip = string.sub(finalChipTxt,1,endlength-1) .. "万"
		--	end
		--end
		ZJH_USER_TOTAL_CHIPS[data.uid] = finalChip
		if GROUP_MODE == 1 then
			finalChip = finalChip 
			ZJH_USER_TOTAL_CHIPS[data.uid] = finalChip
		else
			if finalChip and finalChip > 100000 then
				local finalChipTxt = tostring(finalChip/10000)
				finalChip = string.format("%.1f", finalChipTxt) .. "万"
			end
		end

		self:setGoldString(user_node, finalChip/100)
	end

	--昵称
	local nameStr = require("FanSanPi.FanSanPiSettings"):GetShortName(data["nickName"],9,6)
	self:setNickString(user_node, nameStr)
	if ZJH_USER_UID_PLAYING[data.uid] == 1 and ZJH_GAME_STATE == GAME_STATUS_STOP then

	end
	local if_ready =  data.if_ready
	if if_ready == 1 then
		MenjiroomView:showReady(data.uid,true)
	else
		MenjiroomView:showReady(data.uid,false)
	end

	--info["nickName"]
	-- local url_icon = json.decode(info["user_info"])
	dump(data, "user data info == ")
	
	local ip = data["ip"] or USER_INFO["ip"]
	local updateUserInfoData = {}
	if  data.otherInfo and data.otherInfo ~= "" then

		updateUserInfoData["city"] = json.decode(data.otherInfo)["city"]
	end
	updateUserInfoData["latitude"] = data["latitude"] or ""
	updateUserInfoData["longitude"] = data["longitude"] or ""
	updateUserInfoData["ip"] = ip or ""
	updateUserInfoData["invote_code"] = USER_INFO["invote_code"]
	updateUserInfoData["nickName"] = data.nickName or ""
	dump(updateUserInfoData,"updateUserInfoData")
	require("hall.view.userInfoView.userInfoView"):upDateUserInfo(data.uid,updateUserInfoData)
	self:drawUser(true,index, data["photoUrl"], data.uid, data["sex"],data["nickName"], data.ip, json.decode(data.otherInfo)["addres"])

end


--获取用户序号
function MenjiroomView:getIndex(uid)

	--if uid == USER_INFO["uid"] then
	--	return 0
	--end

	if uid == nil then
		print("getIndexerror")
		return nil
	end
	local other_seat  = ZJH_USER_UID[uid]
	if other_seat == nil then
		dump(uid, "uidError")
		dump(ZJH_USER_UID, "getIndexerror")
		return nil
	end

	dump(MY_SEAT_ID,"MY_SEAT_ID")
	dump(other_seat,"other_seat")
	local other_index = other_seat
	if MY_SEAT_ID >= 0 then
		other_index = MY_SEAT_ID  -  other_seat
		if other_index < 0 then
			other_index = other_index + TOTAL_PLAYERNUM
		end
	end

	--[[五人if TOTAL_PLAYERNUM == 5 then
		if other_index == 2 then
			other_index = 3
		elseif other_index == 3 then
			other_index = 7
		elseif other_index == 4 then
			other_index = 9
		end
	end]]
	
	return other_index

end

function MenjiroomView:removeReady(uid)
	local scenes  = FanSanPiPanel
	local index = ZJH_PLAYERTYPE_TABLE[uid]
	if index == nil then
		print("error",debug.getinfo(1).currentline,debug.getinfo(1).name)
		return nil
	end
	local user_node = self:getUserNodeByIndex(index)
	if user_node == nil then
		return nil
	end	
	self:setReadyVisible(user_node, false)
end

function MenjiroomView:resetUserInfo()

	local scenes = FanSanPiPanel

	for k=0,9 do
		local user_node = self:getUserNodeByIndex(k)
		if user_node then
			user_node:setVisible(false)
			self:setReadyVisible(user_node, false)
		end
	end
end

--删除用户信息
function MenjiroomView:removeUserInfo(uid)
	--[[local node = scenes:getChildByName("drawnode")
	if node == nil then
		return nil
	end]]

	local index     = ZJH_PLAYERTYPE_TABLE[uid]
	if index ~= nil then
		local user_node = self:getUserNodeByIndex(index)
		if user_node ~= nil  then
			user_node:setVisible(false)
		end
	end
end


--改变玩家金币
function MenjiroomView:changeGold(pack)
	-- body
	local index   = ZJH_PLAYERTYPE_TABLE[pack.uid]
	if index == nil then
		return
	end
	local scenes  = FanSanPiPanel
	--[[local node    = scenes:getChildByName("drawnode")
	if node == nil  then
		return
	end]]

	local user_node = self:getUserNodeByIndex(index)
	if user_node == nil then
		return
	end

	local gold_num = user_node:getChildByName("gold")
	if gold_num == nil then
		return
	end

	--local num      = UiCommon:numFormat(pack['m_chips'])
	local finalChip = tonumber(pack['m_chips'])
	if finalChip then
		MenjiroomView:setCoin(pack.uid,finalChip)
		--if  finalChip > 10000 then
		--	local finalChipTxt = tostring(finalChip/10000)
		--	if string.len(finalChipTxt) <= 4 then
		--		finalChip = string.format("%.1f", finalChipTxt) .. "万"
		--	else
		--		local endlength = string.find(finalChipTxt,"%.")
		--		finalChip = string.sub(finalChipTxt,1,endlength-1) .. "万"
		--	end
		--end
		ZJH_USER_TOTAL_CHIPS[pack.uid] = finalChip
		if GROUP_MODE == 1 then
			finalChip = finalChip 
			ZJH_USER_TOTAL_CHIPS[pack.uid] = finalChip
		else
			if finalChip and finalChip > 100000 then
				local finalChipTxt = tostring(finalChip/10000)
				finalChip = string.format("%.1f", finalChipTxt) .. "万"
			end
		end
		self:setGoldString(user_node, finalChip/100)
	end

end


--显示牌局内信息
function MenjiroomView:showRoomInfo(pack, reset)
	-- body
	local scenes    = FanSanPiPanel
	if tolua.isnull(scenes) then
		return
	end
	local info_node = scenes:getChildByName("room_info")
	local newflag   = 0
	if info_node == nil then
		return
	end

	local sum_gold_img = info_node:getChildByName("sum_gold_img")
	if pack.all_zhu>0 then
		sum_gold_img:setVisible(true)
	end

	local info_num_node = sum_gold_img:getChildByName("sum_gold")
	if pack then
		info_num_node:setString(UiCommon:numFormat(pack.all_zhu/100))
		local game_no = info_node:getChildByName("txt_game_round")
		-- local text_desc_round = info_node:getChildByName("text_desc_round")
		if pack["all_turns"] and pack["all_turns"] > 0 then
			if game_no then
				-- text_desc_round:setVisible(true)
				game_no:setVisible(true)
				game_no:setString("轮数："..pack["now_turns"].."/"..pack["all_turns"])
				bm.Room.totalRound = pack["all_turns"]
			end
		else
			if game_no then
				game_no:setVisible(false)
				-- text_desc_round:setVisible(false)
			end
		end
	end
	if reset and reset == 1 then
		info_num_node:setString(UiCommon:numFormat(0))
	end


end

-- 刷新轮次
function MenjiroomView:showRounds()
	if tolua.isnull(FanSanPiPanel) then
		return
	end
	local info_node = FanSanPiPanel:getChildByName("room_info")
	local newflag   = 0
	if info_node == nil then
		return
	end

	local game_no = info_node:getChildByName("txt_game_round")
	-- local text_desc_round = info_node:getChildByName("text_desc_round")
	if game_no then
		if bm.Room.totalRound and bm.Room.totalRound > 0 then
			game_no:setVisible(true)
			-- text_desc_round:setVisible(true)
			game_no:setString("轮数："..tostring(bm.Room.now_turns).."/"..tostring(bm.Room.totalRound))
		else
			game_no:setVisible(false)
			-- text_desc_round:setVisible(false)
		end
	end
end


--显示倒计时
function MenjiroomView:showProgressTimer(uid,time)
	uid = 666681 
	time = 100000000000
	local scenes  = FanSanPiPanel
	--[[local node = scenes:getChildByName("drawnode")
	if node == nil then
		return nil
	end]]

	-- local tmp = nil

	if tolua.isnull(bm.Room.seatProgressTimer) == false then
		if bm.Room.seatProgressTimer:getParent() then
			bm.Room.seatProgressTimer:hide()
		end
		bm.Room.seatProgressTimer = nil
	end

	print("showProgressTimer", uid, tostring(time))

	local starTime = 100 - time/60 *100 ;
	bm.Room.time_progress = starTime
	local user_node = nil
	local index = ZJH_PLAYERTYPE_TABLE[uid]
	if index == nil then
		return
	end
	user_node = self:getUserNodeByIndex(index)
	if user_node == nil then
		return
	end
	local tmp = self:getEffect_frame(user_node)
	tmp:show()
	if not tmp then
		dump(tmp)
		dump(user_node:getName())
		dump(tmp)
	end
	local pt = cc.ProgressTo:create(time,100)
	local pt = cc.ProgressFromTo:create(time,starTime,100)
	local pt = cc.ProgressFromTo:create(0,100,100)
	local sq2
	sq2 = cc.Sequence:create(pt, cc.CallFunc:create(function()
		if bm.Room.seatProgressTimer then
			bm.Room.seatProgressTimer:stopAllActions()

			local action_time = 0.3
			local action_in = 0.1
			local st_big = cc.ScaleTo:create(action_time, 1.0, 0.95)
			local fo = cc.FadeOut:create(action_time)
			local st_small = cc.ScaleTo:create(action_in, 1.05, 1)
			local fi = cc.FadeIn:create(action_in)
			local sqout = cc.Spawn:create(st_big,fo)
			local sqin = cc.Spawn:create(st_small,fi)
			local sq = cc.Sequence:create(sqout,sqin)
			bm.Room.seatProgressTimer:runAction(cc.RepeatForever:create(sq))
		end
	end))
	tmp:runAction(sq2)
	bm.Room.seatProgressTimer = tmp
	bm.Room.seatProgressTimer:retain()
end


--获取头像世界坐标
function MenjiroomView:getHeadPos(index)
	local scenes  = FanSanPiPanel
	local user_ = self:getUserNodeByIndex(index)
	local head = self:getHeadNode(user_)
	if head then
		return user_:convertToWorldSpace(head:getPosition())
	end
end

function MenjiroomView:backAllCardByUid(uid)
	local card_node = MenjiroomView:getCardPanel(uid)
	for i,v in ipairs(card_node:getChildren() or {}) do
		if v.showBack then
			v:showBack()
		end
	end
end

--获取牌框世界坐标
-- function MenjiroomView:getCardPos(index)
-- 	local panel_card = self:getPanelCardsNode()
-- 	local panel_ = self:getPanelCardNodeByIndex(index)
-- 	if panel_ then
-- 		return panel_card:convertToWorldSpace(panel_:getPosition())
-- 	end
-- end
--发牌
function MenjiroomView:sendCard(cardSize, callback)
	-- body
	local scenes  = FanSanPiPanel
	local count = 0
	local distance_x=50
	MenjiroomView:clearCardNode()
	
	for index = 0, 5 do
		local user_node = self:getUserNodeByIndex(index)
		self:setReadyVisible(user_node, false)--准备
	end
	for j=0, (cardSize - 1) do
		for i=0,5 do
			for k,v in pairs(ZJH_USER_UID) do
				-- print("send card 1 ---------------------")
				if ZJH_USER_UID_PLAYING[k] == 1 then
					local index = ZJH_PLAYERTYPE_TABLE[k]
					-- print("send card 2 ---------------------")
					if i == index then
						print("send card 3 ---------------------", cardSize)
						dump(FSP_USER_UID_CARDS, "FSP_USER_UID_CARDS == ")
						if j < 2 or FSP_USER_UID_CARDS[tonumber(k)][j+1] ~= 0 then
							local card = require("FanSanPi.common.PokerCard").new()
							local card_node = MenjiroomView:getCardPanel(k)
							if card_node ~= nil then
								print("send card 4 ---------------------", cardSize, card_node:isVisible())
								-- card_node:removeAllChildren()
								card_node:getParent():show()
								local height = card.backBg_:getContentSize().height
								local width = card.backBg_:getContentSize().width
								local scale = card_node:getContentSize().height / height
								-- local size = FanSanPiPanel:getContentSize()
								local size = cc.Director:getInstance():getWinSize()
								card:setScale(0.5)
								card:addTo(card_node)
								if tonumber(k) == USER_INFO["uid"] and j == 0 then
									card:setCard(FSP_USER_UID_CARDS[tonumber(k)][j+1])
									card:showFront()
									card:toBlack()
								end
								if j > 0 then
									card:setCard(FSP_USER_UID_CARDS[tonumber(k)][j+1])
									card:showFront()
								elseif tonumber(k) ~= USER_INFO["uid"] then
									card:showBack()
								end
								-- card:showBack()
								if cardSize == 3 and j < 2 then -- 表示前两张不要动画
									-- card:setPosition(card_node:convertToNodeSpace(cc.p(size.width/2, size.height/2)))
									card:setName("card"..j)
									if index == 0 then
										card:setPosition(cc.p(card_node:getContentSize().width/2+(j-1)*(width+10), 0))
									else 
										card:setPosition(cc.p(card_node:getContentSize().width/2+(j-1)*distance_x -10, 0))
									end
									card:setScale(scale)
									if FSP_USER_UID_CARDS[tonumber(k)][3] == 0 then
										card:showBack()
									end
								else
								-- dump(FanSanPiPanel:convertToNodeSpace(cc.p(size.width/2, size.height/2)))

									card:setPosition(card_node:convertToNodeSpace(cc.p(size.width/2, size.height/2)))
									card:setName("card"..j)
									-- do return end
									width = width * scale
									-- if tonumber(k) == USER_INFO["uid"]then
									-- 	if bm.User.isDisplay == 1 then
									-- 		MenjiroomView:createKanPai(card_node)
									-- 		-- self:isKanButton(true)
									-- 		-- isKanBtn=true
									-- 	end
									-- end

									require("hall.GameCommon"):playEffectSound("FanSanPi/res/audio/send_card.mp3")
									local move
									if index == 0 then
										move = cc.Spawn:create(cc.ScaleTo:create(0.1, scale), 
										cc.MoveTo:create(0.1,cc.p(card_node:getContentSize().width/2+(j-1)*(width+10), 0)))
									else
										move = cc.Spawn:create(cc.ScaleTo:create(0.1, scale), 
										cc.MoveTo:create(0.1,cc.p(card_node:getContentSize().width/2+(j-1)*distance_x -10, 0)))
									end
									local delay= cc.DelayTime:create(count*0.1)
									local se   = cc.Sequence:create(delay,move)
									card:runAction(se)
									count = count +1
								end
							end
						end
					end
				end
			end
		end
	end

	local time =count/10
	if callback then
		local handle = scheduler.performWithDelayGlobal(callback, time)
		table.insert(schedulerEvents, handle)
		--TimerHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, time, false)
	end

end

--发牌
-- function MenjiroomView:sendCard(callback)
-- 	-- body
-- 	local scenes  = ZhaJinHuaPanel
-- 	local count = 0
-- 	local distance_x=50
-- 	MenjiroomView:clearCardNode()
	
-- 	for index = 0, 9 do
-- 		local user_node = self:getUserNodeByIndex(index)
-- 		-- self:setGoldString(user_node, "")--积分
-- 		-- self:setScoreString(user_node, "") --用户输赢积分
-- 		self:setReadyVisible(user_node, false)--准备
-- 		-- self:setZhuangVisible(user_node, false)--庄
-- 		-- self:setFangZhuVisible(user_node, false)--房主
-- 		-- self:getChipBgNode(user_node):hide() --筹码
-- 		-- self:getEffect_frame(user_node):hide() --人物框特效
-- 		-- self:set_grab_banker_times_txt(user_node) --抢庄积分
-- 	end
-- 	-- ZJH_USER_UID_PLAYING= {
-- 	-- 	[666681] = 1,
-- 	-- 	[666683] = 1
-- 	-- }
-- 	-- ZJH_USER_UID= {
-- 	-- 	[666681] = 1,
-- 	-- 	[666683] = 0
-- 	-- }
-- 	-- ZJH_PLAYERTYPE_TABLE= {
-- 	-- 	[666681] = 1,
-- 	-- 	[666683] = 0
-- 	-- }
-- 	for j=0,2 do
-- 		for i=0,9 do
-- 			for k,v in pairs(ZJH_USER_UID) do
-- 				if ZJH_USER_UID_PLAYING[k] == 1 then
-- 					local index = ZJH_PLAYERTYPE_TABLE[k]
-- 					if i == index then
-- 						local card = require("FanSanPi.common.PokerCard").new()
-- 						local card_node = MenjiroomView:getCardPanel(k)
-- 						if card_node ~= nil then

-- 							card_node:getParent():show()
-- 							local height = card.backBg_:getContentSize().height
-- 							local width = card.backBg_:getContentSize().width
-- 							local scale = card_node:getContentSize().height / height
-- 							-- local size = ZhaJinHuaPanel:getContentSize()
-- 							local size = cc.Director:getInstance():getWinSize()
-- 							card:setScale(0.5)
-- 							card:addTo(card_node)
-- 							card:showBack()
-- 							-- dump(ZhaJinHuaPanel:convertToNodeSpace(cc.p(size.width/2, size.height/2)))

-- 							card:setPosition(card_node:convertToNodeSpace(cc.p(size.width/2, size.height/2)))
-- 							card:setName("card"..j)
-- 							width = width * scale
-- 							if tonumber(k) == USER_INFO["uid"]then
-- 								if bm.User.isDisplay == 1 then
-- 									MenjiroomView:createKanPai(card_node)
-- 									self:isKanButton(true)
-- 									isKanBtn=true
-- 								end
-- 							end
-- 							require("hall.GameCommon"):playEffectSound("FanSanPi/res/audio/send_card.mp3")
-- 							local move
-- 							if index == 0 then
-- 								move = cc.Spawn:create(cc.ScaleTo:create(0.1, scale), 
-- 								cc.MoveTo:create(0.1,cc.p(card_node:getContentSize().width/2+(j-1)*(width+10), 0)))
-- 							else
-- 								move = cc.Spawn:create(cc.ScaleTo:create(0.1, scale), 
-- 								cc.MoveTo:create(0.1,cc.p(card_node:getContentSize().width/2+(j-1)*distance_x -10, 0)))
-- 							end
-- 							local delay= cc.DelayTime:create(count*0.1)
-- 							local se   = cc.Sequence:create(delay,move)
-- 							card:runAction(se)
-- 							count = count +1
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- 	local time =count/10
-- 	if callback then
-- 		-- local handle = scheduler.performWithDelayGlobal(callback, time)
-- 		-- table.insert(schedulerEvents, handle)
-- 		--TimerHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, time, false)
-- 	end

-- end

function MenjiroomView:showPiaoOptByType(type)
	self:setPiaoOptBtnVisible(true)
	local btnNoOpt = FanSanPiPanel:getChildByName("piaoNode"):getChildByName("noOpt")
	local btnOpted = FanSanPiPanel:getChildByName("piaoNode"):getChildByName("opted")

	btnOpted:setOpacity(255)
	btnOpted:setTouchEnabled(true)

	btnNoOpt:getChildByName("title"):setString(type == 1 and "不飘" or "不打")
	btnOpted:getChildByName("title"):setString(type == 1 and "飘一张" or "打骰")
	btnNoOpt:addTouchEventListener(
			function(sender,event)
				if event == TOUCH_EVENT_ENDED then
					MenjiroomServer:CLIENT_COMMAND_USER_OPT(1)
				end
			end
		)
	btnOpted:addTouchEventListener(
			function(sender,event)
				if event == TOUCH_EVENT_ENDED then
					btnOpted:setOpacity(80)
					btnOpted:setTouchEnabled(false)
					MenjiroomServer:CLIENT_COMMAND_USER_OPT(2)
				end
			end
		)
end

function MenjiroomView:showPiaoCardAniByType(type, value, sex)
	if type == 1 then
		value = 1
	end

	if type == 1 then
		self:showXipaiAndPiaoCards(value, sex)
	else
		self:creArmature("diushaizi", handler(self, self.showXipaiAndPiaoCards), value, sex)
	end
end

function MenjiroomView:setPiaoOptBtnVisible(flag)
	FanSanPiPanel:getChildByName("piaoNode"):getChildByName("noOpt"):setVisible(flag)
	FanSanPiPanel:getChildByName("piaoNode"):getChildByName("opted"):setVisible(flag)
end

function MenjiroomView:piaoCardsAni( value )
	-- SoundUtils:playCardKindEffect("piao_value", data_info["sex"], value)
	print("piaoCardsAni --------------", value)
	local node = FanSanPiPanel:getChildByName("piaoNode")
	for i = 1, value do
		local card = require("FanSanPi.common.PokerCard").new()
		card:showBack()
		card:addTo(node)
		card:setScale(0.56)
		card:setPositionY(-86)
		local delay= cc.DelayTime:create(i*0.25)
		local func = cc.CallFunc:create(function()
											print('piaoCardsAni reove card -------------', value, i, MenjiroomView.xipaiAni)
											require("hall.GameCommon"):playEffectSound("FanSanPi/sounds/piao_card.mp3")
											card:removeSelf()
											if i == value and MenjiroomView.xipaiAni then
												print('xipaiAni removeSelf -------------')
												MenjiroomView.xipaiAni:removeSelf()
												MenjiroomView.xipaiAni = nil
											end							                
							        	end)
		local se   = cc.Sequence:create(delay,cc.MoveTo:create(0.25, cc.p(0,1300)), func)
		card:runAction(se)
	end
end

function MenjiroomView:showXipaiAndPiaoCards(value, sex)
	SoundUtils:playCardKindEffect("piao_value", sex, value)
	self.xipaiAni = self:creArmature("xipai", handler(self, self.piaoCardsAni), value)
end

function MenjiroomView:creArmature(name, callBack, value, sex)
    local path = "FanSanPi/res/exportAni/"..name
    -- local scene = SCENENOW["scene"]
    -- local zindex = ViewBase:getZOrderByChilds(scene)
    local node = FanSanPiPanel:getChildByName("piaoNode")
    local effectManage = ccs.ArmatureDataManager:getInstance() 
    display.addSpriteFrames(path.."0.png", path.."0.plist")
    effectManage:addArmatureFileInfo(path.."0.png", path.."0.plist", path..".ExportJson")
    local Armature = ccs.Armature:create(name)
    Armature:addTo(node)
    local anim = Armature:getAnimation()
    if  name == "diushaizi" then
    	require("hall.GameCommon"):playEffectSound("FanSanPi/sounds/sezi.mp3")
    	anim:playWithNames({value.."dian"}, 0, false)
    else
    	anim:playWithIndex(0, 0, 0) --第一个参数是动画表index 第二个是时间间隔 第三个是是否循环
    end
    local function handler1(Armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
        	-- if name == "diushaizi" then
            	Armature:removeSelf()
            -- end
            if callBack then
                callBack(value, sex)
            end
        end
    end
    anim:setMovementEventCallFunc(handler1)
    return Armature
end

function MenjiroomView:setUserPoint()
	for k, v in pairs(FSP_USER_UID_CARDS) do
		local point = 0
		for i, v1 in pairs(v or {}) do
			if i > 1 then
				point = point + self:getCardPoint(v1)
			end
			if k == USER_INFO["uid"] and i == 1 then
				point = point + self:getCardPoint(v1)
			end
		end
		local user_node  = MenjiroomView:getUserNode(tonumber(k))
		if user_node then
			local state = user_node:getChildByName("state")
			local cardPointNode = user_node:getChildByName("cardPointNode")
			print("setUserPoint ------------------ ", k, state:isVisible(), USER_INFO["uid"], debug.traceback())
			if state and state:isVisible() and tonumber(k) ~= USER_INFO["uid"] then
				cardPointNode:setVisible(false)
			else
				local cardPointNode = user_node:getChildByName("cardPointNode")
				cardPointNode:setVisible(true)
				if cardPointNode then
					local cardPoint = cardPointNode:getChildByName("cardPoint")
					cardPoint:setString(string.format("点数:%d", point))
				end
			end
		end
	end
end

function MenjiroomView:getCardPoint(card)
	local gameConfig = self.gameConfigStr
	local configT = json.decode(gameConfig)
	local point = bit.band(card, 0x0F)
	local color = bit.band(card, 0xF0)
	if (point == 1 or point == 2) then
		point = point + 13
	end

	if(color == 0x40) then
		point = point + 2
	end

	if (color == 0x50) then
		point = 18
	end

	local hasLaper = (string.find(configT.happy_money or "", "2") ~= nil)
	if(hasLaper and point == 3 and color == 0x00) then
		point = 18
	end
	return point
end

function MenjiroomView:isKanButton(falg)
	if not FanSanPiPanel then return end
	self.btn_kan = FanSanPiPanel.player_plane_1.btn_kan
	self.btn_kan:setTouchEnabled(false)--falg
	self.btn_kan:setVisible(false)
	MenjiroomView:cpShow(false)
end

function MenjiroomView:getCardPanel(uid)
	local index = ZJH_PLAYERTYPE_TABLE[uid]
	if index == nil then
		return nil
	end
	local card_node = self:getPanelCardNodeByIndex(index)
	if card_node == nil then
		return nil
	end

	return card_node
end
function MenjiroomView:clearCardNode()
	for i = 0, 5 do
		local card_node = self:getPanelCardNodeByIndex(i)
		if card_node then
			card_node:removeAllChildren()
		end
		local userNode = self:getUserNodeByIndex(i)
		local cardPointNode = userNode:getChildByName("cardPointNode")
		if cardPointNode then
			cardPointNode:setVisible(false)
		end
	end

end

function MenjiroomView:createKanPai(card_node)
	

end
-- 设置牌值
function MenjiroomView:setCards(uid, cards)
	local uid_card = uid or USER_INFO["uid"]
	local v_cards = cards or bm.User.Cards
	local user_node = MenjiroomView:getUserNode(uid_card)
	local card_node = MenjiroomView:getCardPanel(uid_card)
	if card_node == nil then
		return
	end
	if user_node==nil then
		return
	end
	if card_node then
		for k, v in pairs(v_cards) do
			if v > 0 then
				local card = card_node:getChildByName("card"..tostring(k-1))
				if card then
					card:setCard(v)
				end
			end
		end
	end

end

-- 设置牌值
function MenjiroomView:setCardsNew(index, cards)
	local v_cards = cards
	local user_node = MenjiroomView:getIndexNode(index)
	local card_node = MenjiroomView:getCardPanel(uid)

	if card_node then
		for k, v in pairs(v_cards) do
			local card = card_node:getChildByName("card"..tostring(k-1))
			if card then
				card:setCard(v)
			end
		end
	end

end

--获得用户的节点
function MenjiroomView:getIndexNode(index)

	if index == nil then
		return nil
	end

	local scenes    = FanSanPiPanel
	for k, v in pairs(ZJH_USER_UID) do
		if v == index then
			local user_node = self:getUserNodeByIndex(ZJH_PLAYERTYPE_TABLE[k])
			if user_node == nil then
				return nil
			end
			return user_node
		end
	end

end

--获得用户的节点
function MenjiroomView:getUserNode(uid)

	local index = ZJH_PLAYERTYPE_TABLE[uid]
	print("getUserNode", tostring(index), tostring(uid))

	if index == nil then
		return nil
	end
	local user_node = self:getUserNodeByIndex(index)
	if user_node == nil then
		return nil
	end

	return user_node
end

--获得用户的节点
function MenjiroomView:getUserNodeByIndex(index)
	dump()
	if FanSanPiPanel == nil then
		return nil
	end
	local user_node = FanSanPiPanel:getChildByName("player_plane_"..index + 1)
	if user_node == nil then
		return nil
	end
	return user_node
end

-- function MenjiroomView:getPanelCardsNode()
-- 	return FanSanPiPanel:getChildByName("panel_card")	
-- end

function MenjiroomView:getPanelCardNodeByIndex(index) --手牌
	local user_node = self:getUserNodeByIndex(index)
	if user_node == nil then
		return nil
	end
	return user_node.inhand_plane
end

function MenjiroomView:setReadyVisible(user_node, isVisible) --准备
	user_node.head_plane.ready_img:setVisible(isVisible)
	-- return ViewBase:seekChild(user_node, "ready_img"):setVisible(isVisible)
end

function MenjiroomView:getStateNode(user_node) --看牌 超时状态
	return user_node.state
	-- return ViewBase:seekChild(user_node, "ready_img"):setVisible(isVisible)
end

function MenjiroomView:setGoldString(user_node, str)--用户积分
	user_node.head_plane.chip_txt:setString(str)
	-- ViewBase:seekChild(user_node, "chip_txt"):setString(str)
end

function MenjiroomView:setScoreString(user_node, str)--用户输赢积分
	user_node.head_plane.score_txt:setString(str)
	-- ViewBase:seekChild(user_node, "score_txt"):setString(str)
end

function MenjiroomView:setNickString(user_node, str)
	user_node.head_plane.name_txt:setString(str)
	-- ViewBase:seekChild(user_node, "name_txt"):setString(str)
end

function MenjiroomView:getChipBgNode(user_node) --筹码
	return user_node.head_plane.chip_img
	-- return ViewBase:seekChild(user_node, "chip_img")
end

function MenjiroomView:getHeadNode(user_node) -- 头像
	return user_node.head_plane.head_img
	-- return ViewBase:seekChild(user_node, "head_img")
end

function MenjiroomView:setZhuangVisible(user_node, isVisible) -- 庄
	user_node.head_plane.zhuang_flag:setVisible(isVisible)
	-- return ViewBase:seekChild(user_node, "zhuang_flag"):setVisible(isVisible)
end

function MenjiroomView:getEffect_frame(user_node) -- 人物框特效
	return user_node.head_plane.effect_frame
end

function MenjiroomView:set_grab_banker_times_txt(user_node, score) --抢庄积分
	if score then
		user_node.head_plane.grab_banker_times_txt:setString(score)
	else
		user_node.head_plane.grab_banker_times_txt:hide()
		user_node.head_plane.grab_banker_img:hide()
	end
end

function MenjiroomView:setFangZhuVisible(user_node, isVisible) -- 房主
	return user_node.head_plane.fangzhutip_img:setVisible(isVisible)
	-- return ViewBase:seekChild(user_node, "fangzhutip_img"):setVisible(isVisible)
end

------------------------------------------------------------------------------------------------
--显示弃牌图片
function MenjiroomView:showQipai(uid)
	-- body
	local scenes  = FanSanPiPanel
	
	print("showQipai", tostring(uid))

	--local index = ZJH_PLAYERTYPE_TABLE[uid]
	--if index == nil then
	--	return
	--end
	--local card_node = MenjiroomView:getCardPanel(uid)
	--if card_node == nil then
	--	return
	--end
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end
	--弃牌
	if uid == USER_INFO["uid"] then
		local base_foot = scenes:getChildByName("base_foot")
		local qi_green = base_foot:getChildByName("qi_green")
		if qi_green then
			print("showQipai ------------------ ", debug.traceback())
			qi_green:setOpacity(80)
			qi_green:setTouchEnabled(false)
		end
		self:isKanButton(false)
	end
	--弃牌
	local state = self:getStateNode(user_node)
	state:loadTexture("FanSanPi/res/newroom/icon_1.png") --已弃牌
    state:ignoreContentAdaptWithSize(true)
	state:show()
	user_node.cardPointNode:setVisible(false)
end


--显示看牌
function MenjiroomView:showKanpai(uid)
	local scenes  = FanSanPiPanel
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end
	local card_node = MenjiroomView:getCardPanel(uid)
	if card_node == nil then
		return
	end
	if uid == USER_INFO["uid"] or index == 0 then
		self:isKanButton(false)
		return
	end
	local state = self:getStateNode(user_node)
	state:loadTexture("FanSanPi/res/newroom/icon_3.png") --已看牌
    state:ignoreContentAdaptWithSize(true)
	state:show()
end

function MenjiroomView:showCardType(type)

	local card_node = self:getUserNodeByIndex(0)
	local card_type = card_node:getChildByName("card_type")
	if card_type~=nil then
		card_type:loadTexture("FanSanPi/res/NewImg/"..type..".png")
		card_type:ignoreContentAdaptWithSize(true)
		card_type:show()
	end
end

function MenjiroomView:hideCardType()
	local card_node = self:getUserNodeByIndex(0)
	if card_node ~= nil then
		local card_type = card_node:getChildByName("card_type")
		if card_type~=nil then
			card_type:hide()
		end
	end

end
-- 显示牌
function MenjiroomView:showCard(uid, cardType)

	local scenes  = FanSanPiPanel
	local card_node = MenjiroomView:getCardPanel(uid)
	if card_node == nil then
		return
	end
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end
	user_node.cardPointNode:setVisible(true)
	if cardType < 0x08 then -- 表示传回的是类型
		local cardPoint = user_node.cardPointNode:getChildByName("cardPoint")
		if cardType == 0x07 then
			cardPoint:setString(string.format("真三皮", cardType))
		elseif cardType == 0x06 then
			cardPoint:setString(string.format("假三皮", cardType))
		end
	else -- 传回的是点数
		local cardPoint = user_node.cardPointNode:getChildByName("cardPoint")
		cardPoint:setString(string.format("点数:%d", cardType))
	end
	--if card_node then
	--	for j=0,2 do
	--		local card = card_node:getChildByName("card"..j)
	--		if card then
	--			card:flipCard()
	--		end
	--	end
	--end
	local state = self:getStateNode(user_node)
	if state ~= nil then
		state:hide()
	end
	self:isKanButton(false)

end

--玩家扔出筹码
function MenjiroomView:diuChips(uid,gold)

	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end
	local chip=nil
	for k,v in pairs(bm.Room.zhus or {}) do
		if gold==v then
			chip= UiCommon:getChipBtnNew(gold/100,k)
			local random = math.random(1,90)
			local rotate=cc.RotateBy:create(0.1,random)

			chip:runAction(rotate)
		end
	end

	if chip==nil then
		chip= UiCommon:getChipBtnNew(gold/100,4)

	end

	local scenes    = FanSanPiPanel:getChildByName("diuChipNode")
	chip:addTo(scenes)

	-- CONFIG_WIN_WIDTH  = 1280
	-- CONFIG_WIN_HEIGHT = 720
	local size = scenes:getContentSize()
	local x = size.width/2
	local y = size.height/2
	local rand_x = math.random(x-200,x+200)
	local rand_y = math.random(y-60,y+60)
	

	chip:setPosition(user_node:getPosition())

	table.insert(bm.Room.chips,chip)

	local move = cc.MoveTo:create(0.1,cc.p(rand_x,rand_y))
	chip:runAction(move)

	require("hall.GameCommon"):playEffectSound("FanSanPi/res/audio/sound_jinbi.mp3")
end


--玩家扔出alllin
function MenjiroomView:diuChipsAllin(uid,gold)

	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end

	local chip = ccui.ImageView:create("FanSanPi/res/newroom/chouma_01.png")
	chip:setName("allin_gold")
	local ttfConfig = {}
	ttfConfig.fontFilePath = "FanSanPi/res/fonts/fzcy.ttf"
	ttfConfig.fontSize = 38
	local gold_text = cc.Label:createWithTTF(ttfConfig, gold)
	gold_text:setTextColor(cc.c3b(61,0,64));
	chip:addChild(gold_text)
	chip:setContentSize(cc.size(120, 120))
	gold_text:setPosition(120 / 2, 120 / 2)
	chip:ignoreContentAdaptWithSize(false)
	chip:addTo(FanSanPiPanel)


	local size = FanSanPiPanel:getContentSize()
	local x = size.width/2
	local y = size.height/2
	local rand_x = math.random(x-200,x+200)
	local rand_y = math.random(y-60,y+60)

	chip:setPosition(user_node:getPosition())

	table.insert(bm.Room.chips, chip)

	local move = cc.MoveTo:create(0.1,cc.p(rand_x,rand_y))
	chip:runAction(move)

	require("hall.GameCommon"):playEffectSound("FanSanPi/res/audio/sound_jinbi.mp3")
end


--隐藏金币筹码相关
function MenjiroomView:showChipsNowZhu(flag)
	local scenes    = FanSanPiPanel

	local info_node = scenes:getChildByName("room_info")
	local newflag   = 0
	if info_node == nil then
		return
	end
	local sum_gold_img = info_node:getChildByName("sum_gold_img")
	sum_gold_img:setVisible(flag)

	for i = 0, 9 do
		local user_node = self:getUserNodeByIndex(i)
		if user_node ~= nil then
		local gold_back = self:getChipBgNode(user_node)
		gold_back:setVisible(false)
		end
	end


	for k,v in pairs(ZJH_USER_UID) do
		local user_node = MenjiroomView:getUserNode(k)
		if user_node ~= nil then
			local gold_back = self:getChipBgNode(user_node)
			if ZJH_USER_UID_PLAYING[k] == 1 then
				gold_back:setVisible(flag)
			else
				gold_back:setVisible(false)
			end
		end
	end

end

--显示玩家当前下注数量
function  MenjiroomView:showNowZhu(uid, gold, add_flag)
	-- body
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end
	
	local gold_back = self:getChipBgNode(user_node)
	gold_back:setVisible(true)

	print("showNowZhu", tostring(uid), tostring(gold), tostring(add_flag))

	local chips = tonumber(gold)/100
	local txt = gold_back:getChildByName("bet_times_txt")
	if txt then
		if add_flag and add_flag == 1 then
			chips = tonumber(txt:getString()) + gold/100
		end
		txt:setString(UiCommon:numFormat(chips))
	end

end

--显示操作按钮
function MenjiroomView:showRoomButton(uid, bFill)
	-- body
	local scenes  = FanSanPiPanel
	if FanSanPiPanel == nil then
		return
	end
	local isQi   = false
	local isGen  = false
	local isJia  = false

	if bm.User.isDiu[USER_INFO["uid"]] == nil and  ZJH_USER_UID_PLAYING[USER_INFO["uid"]] == 1 then
		isQi  = true
	end

	local base_foot=scenes:getChildByName("base_foot")

	if (isQi) and uid == USER_INFO["uid"] then
		isGen = true
		-- isJia = (bFill ~= 0)
		isJia = true
	-- 	base_foot:setVisible(true)
	-- else
	-- 	base_foot:setVisible(false)
	end
	
	--弃牌
	local qi_green = base_foot:getChildByName("qi_green")
	if isQi then
		qi_green:setOpacity(255)
		qi_green:setVisible(true)
		qi_green:setTouchEnabled(true)
	else
		print("showQipai ------------------ ", debug.traceback())
		qi_green:setOpacity(80)
		qi_green:setTouchEnabled(false)
	end

	--跟注
	local gen_green = base_foot:getChildByName("gen_green")
	if isGen then
		gen_green:setOpacity(255)
		gen_green:setVisible(true)
		gen_green:setTouchEnabled(true)
	else
		gen_green:setTouchEnabled(false)
		gen_green:setOpacity(80)
	end
	print("showRoomButton -------------------", isJia, type(isJia))
	--加注
	local jia_green = base_foot:getChildByName("jia_green")
	if isJia then
		print("showRoomButton jia -------------------")
		jia_green:setOpacity(255)
		jia_green:setVisible(true)
		jia_green:setTouchEnabled(true)
	else
		print("showRoomButton not jia -------------------")
		jia_green:setTouchEnabled(false)
		jia_green:setOpacity(80)
	end
	--加注
	local quan_green = base_foot:getChildByName("quan_green")
	if isJia then
		print("showRoomButton jia -------------------")
		quan_green:setOpacity(255)
		quan_green:setVisible(true)
		quan_green:setTouchEnabled(true)
	else
		print("showRoomButton not jia -------------------")
		quan_green:setTouchEnabled(false)
		quan_green:setOpacity(80)
	end
end

-- 重置按钮
function MenjiroomView:resetOperate(flag)
	if FanSanPiPanel == nil then
		return
	end
	MenjiroomView:cpShow(false)
	local scenes  = FanSanPiPanel:getChildByName("base_foot")
	scenes:setVisible(flag)
	--弃牌
	local qi_green = scenes:getChildByName("qi_green")
	if qi_green then
		qi_green:setOpacity(80)
		qi_green:setTouchEnabled(false)
	end

	--比牌
	local bi_green = scenes:getChildByName("bi_green")
	if bi_green then
		bi_green:setOpacity(80)
		bi_green:setTouchEnabled(false)
	end

	--跟注
	local gen_green = scenes:getChildByName("gen_green")
	if gen_green then
		gen_green:setOpacity(80)
		gen_green:setTouchEnabled(false)
	end

	--加注
	local jia_green = scenes:getChildByName("jia_green")
	if jia_green then
		jia_green:setOpacity(80)
		jia_green:setTouchEnabled(false)
	end

	--全押
	local btn_allin = scenes:getChildByName("quan_green")
	if btn_allin then
		btn_allin:setTouchEnabled(false)
		btn_allin:setOpacity(80)
	end
end

-- 1、表示全部为下注的按钮， 2、第一个按钮为跟注按钮，第2、3个按钮为加注按钮
function MenjiroomView:reSetOptBtnByState(state)
	local scenes  = FanSanPiPanel:getChildByName("base_foot")
	local gen_greenTxt = scenes:getChildByName("gen_green"):getChildByName("Text_3")
	local jia_greenTxt = scenes:getChildByName("jia_green"):getChildByName("Text_3")
	local btn_allinTxt = scenes:getChildByName("quan_green"):getChildByName("Text_3")
	if state == 1 then
		gen_greenTxt:setString("下注"..(bm.Room.now_zhu/100).."分")
		scenes:getChildByName("jia_green")._betState = 1
		scenes:getChildByName("quan_green")._betState = 1
		jia_greenTxt:setString(string.format("下注%d分", (bm.Room.now_zhu/100) * 2))
		btn_allinTxt:setString(string.format("下注%d分", (bm.Room.now_zhu/100) * 3))
		scenes:getChildByName("gen_green")._betValue = (bm.Room.now_zhu/100)
		scenes:getChildByName("jia_green")._betValue = (bm.Room.now_zhu/100) * 2
		scenes:getChildByName("quan_green")._betValue = (bm.Room.now_zhu/100) * 3
	elseif state == 2 then
		gen_greenTxt:setString("跟注"..(bm.Room.now_zhu/100).."分")
		scenes:getChildByName("jia_green")._betState = 2
		scenes:getChildByName("quan_green")._betState = 2
		local data = json.decode(self.gameConfigStr)
		jia_greenTxt:setString(string.format("加注%d分", data.dizhu * data.baseChip))
		btn_allinTxt:setString(string.format("加注%d分", data.dizhu * data.baseChip * 2))
		scenes:getChildByName("gen_green")._betValue = (bm.Room.now_zhu/100)
		scenes:getChildByName("jia_green")._betValue = data.dizhu * data.baseChip
		scenes:getChildByName("quan_green")._betValue = data.dizhu * data.baseChip * 2
	end
end

-- 重置房间
function MenjiroomView:resetGame()
	for k , v in pairs(ZJH_USERINFO_TABLE) do
		if ZJH_USER_ONLINE[k] and ZJH_USER_ONLINE[k] == 1 and ZJH_USER_UID_PLAYING[k] ==1 then
			MenjiroomView:showNowZhu(k,0)
		elseif ZJH_USER_ONLINE[k] and ZJH_USER_ONLINE[k] == 0 and bm.Room.iswith == false then
			--MenjiroomView:removeUserInfo(k)
		end
	end
	local info_node = FanSanPiPanel:getChildByName("room_info")
	if info_node then
		local info_num_node = info_node:getChildByName("sum_gold")
		if info_num_node then
			info_num_node:setString(0)
		end
	end


	-- 重置庄家
	if bm.Room.banker then
		bm.Room.banker:removeSelf()
		bm.Room.banker = nil
	end

	bm.Room.all_compare = 0
	bm.Room.result = nil
	bm.Room.isover = false
	bm.Room.show_card = 0
end

--显示加注
function MenjiroomView:showJiaZhuView()
	-- body

	local scenes  = FanSanPiPanel
	scenes:removeNodeEventListener(cc.NODE_TOUCH_EVENT)
	local node_t = scenes:getChildByName("chip_node")
	if node_t == nil then
		return
	end
	node_t:setVisible(true)
	scenes:getChildByName("chip_panel"):setVisible(true)
	node_t:setLocalZOrder(99999)
	local cBet = bm.Room.now_zhu
	-- if bm.User.isKan[USER_INFO["uid"]] ~= nil then
	-- 	cBet = cBet * 2
	-- end
	print("showJiaZhuView", tostring(cBet), tostring(bm.User.isKan[USER_INFO["uid"]]))
	local i      = 0
--	bm.Room.zhus={}
--	bm.Room.zhus[1] = 10000
--	bm.Room.zhus[2] = 100000
--	bm.Room.zhus[3] = 1000000
--	bm.Room.zhus[4] = 10000000
	bm.Room.chip_v=0
	dump(bm.Room.zhus, "bm.Room.zhus == ")
	for k,v in pairs(bm.Room.zhus) do
		local chip_btn=node_t:getChildByName("chip_btn"..k)
		chip_btn:removeAllChildren()
		local value_bet = 0
		-- if bm.User.isKan[USER_INFO["uid"]] ~= nil then
		-- 	value_bet = v*2
		-- else
			value_bet = v
		-- end
		local chipNum = UiCommon:getChipsNum(value_bet/100,k)
		if chip_btn then
			-- if cBet > 0 then
				-- if value_bet < cBet then
				-- 	chip_btn:setTouchEnabled(false)
				-- 	chip_btn:setOpacity(70)
				-- else
					chip_btn:setTouchEnabled(true)
					chip_btn:setOpacity(255)
				-- end
			-- end
			local size = chip_btn:getContentSize()
			chipNum:setPosition(size.width/2, size.height/2)
			chipNum:addTo(chip_btn)
			chipNum:setAnchorPoint(cc.p(0.5,0.5))
			chip_btn:setScale(1)
			chip_btn:addTouchEventListener(
				function(sender,event)
					--触摸结束
					if event == TOUCH_EVENT_ENDED then
						value_bet = value_bet 
						bm.Room.chip_v = value_bet;
						
						local allValue = value_bet + bm.Room.now_zhu
						print("加注---------------- ", value_bet ,bm.Room.now_zhu)
						MenjiroomServer:CLI_JIA_CARD(allValue)
						--[[local move = cc.MoveTo:create(0.2,cc.p(1200,100))
			            node_t:runAction(move)]]
						MenjiroomView:moveChipList()
					end
				end
			)
		end
	end
	--	node_t:setPosition(397.01,139.95)
	local chip_panel =scenes:getChildByName("chip_panel")
	chip_panel:addTouchEventListener(function(sender,event)
		if event == TOUCH_EVENT_ENDED then
			MenjiroomView:moveChipList()
		end
	end)

end

-- 收起筹码表
function MenjiroomView:moveChipList()
	local scenes  = FanSanPiPanel
	local user_node_ = MenjiroomView:getUserNode(USER_INFO["uid"])
	if user_node_ then
		local node_n = scenes:getChildByName("chip_node")
		if node_n then
			node_n:setVisible(false)
			scenes:getChildByName("chip_panel"):setVisible(false)
		end
		local allin_node = scenes:getChildByName("allin_node")
		if allin_node then
			allin_node:setVisible(false)
			scenes:getChildByName("chip_panel"):setVisible(false)
		end
	end
end
function MenjiroomView:showKuanNode(uid)
	local user_node  = MenjiroomView:getUserNode(uid)
	if user_node then
		user_node:setTouchEnabled(false)
		local kuang_node = self:getEffect_frame(user_node)
		kuang_node:show()
		local action_time = 0.3
		local action_in = 0.1
		local st_big = cc.ScaleTo:create(action_time, 1.0)
		local fo = cc.FadeOut:create(action_time)
		local st_small = cc.ScaleTo:create(action_in, 1.05)
		local fi = cc.FadeIn:create(action_in)
		local sqout = cc.Spawn:create(st_big,fo)
		local sqin = cc.Spawn:create(st_small,fi)
		local sq = cc.Sequence:create(sqout,sqin)
		kuang_node:runAction(cc.RepeatForever:create(sq))
		kuang_node:setLocalZOrder(99)
	end
end

-- 清除比牌选择动画
function MenjiroomView:clearBipai()
	-- self:isKanButton(false)
	for k,v in pairs(ZJH_USER_UID) do
		local uid = k
		--if uid ~= USER_INFO["uid"] then
			local user_node = MenjiroomView:getUserNode(uid)
			if user_node~= nil then
				local kuang_node = self:getEffect_frame(user_node)
				if kuang_node then
					kuang_node:hide()
				end
			end
		--end
	end

	if bm.Room.seatProgressTimer ~= nil then
		if bm.Room.seatProgressTimer:getParent() then
			bm.Room.seatProgressTimer:hide()
		end
		bm.Room.seatProgressTimer = nil
	end
	if FanSanPiPanel then
		local zhezhao = FanSanPiPanel:getChildByName("zhezhao")
		if zhezhao ~= nil then
			zhezhao:removeSelf()
		end
	end

end


function MenjiroomView:exitGame(sender,event)

end

-- 比牌回调
function MenjiroomView:CallBackCompare(active_uid, compare_uid, compare_resutl)

	bm.Room.all_compare = 0
	local user_node_c = MenjiroomView:getUserNode(compare_uid)
	local user_node_a = MenjiroomView:getUserNode(active_uid)
	-- if user_node_a then
	-- 	local btn_buy = user_node_a:getChildByName("btn_buy")
	-- 	if btn_buy then
	-- 		if GROUP_MODE == 2 then
	-- 			btn_buy:setVisible(false)
	-- 		else
	-- 			btn_buy:setVisible(false)
	-- 		end

	-- 	end
	-- end

	-- if user_node_c then
	-- 	btn_buy = user_node_c:getChildByName("btn_buy")
	-- 	if btn_buy then
	-- 		if GROUP_MODE == 2 then
	-- 			btn_buy:setVisible(false)
	-- 		else
	-- 			btn_buy:setVisible(false)
	-- 		end
	-- 	end
	-- end

	if compare_resutl == 1 then
		print("bm.User.isKan[active_uid]",bm.User.isKan[active_uid])
		if bm.User.isKan[active_uid] ==nil then
			if active_uid==USER_INFO["uid"] then
				local card_node = MenjiroomView:getCardPanel(active_uid)
				local user_node = MenjiroomView:getUserNode(active_uid)
			end
		end
		MenjiroomView:showQipai(compare_uid)
	else
		print("bm.User.isKan[compare_uid]",bm.User.isKan[compare_uid])
		if bm.User.isKan[compare_uid] ==nil then
			if compare_uid==USER_INFO["uid"] then
				local card_node = MenjiroomView:getCardPanel(compare_uid)
			end
		end
		MenjiroomView:showQipai(active_uid)
	end

	if bm.Room.result then
		MenjiroomView:gameEnd(bm.Room.result)
	end
	bm.Room.is_compare = true
end

-- 全桌比牌
function MenjiroomView:AllCompare()
	do return end
	local scenes  = FanSanPiPanel
	print("scenes==",scenes)
	if scenes == nil then
		return
	end
	local effect = display.newSprite("#allCompare1.png")
	local frames = display.newFrames("allCompare%d.png", 1, 13)
	if frames == nil then
		display.addSpriteFrames("FanSanPi/res/room/compareCard/allCompare.plist", "FanSanPi/res/room/compareCard/allCompare.png")
		frames = display.newFrames("allCompare%d.png", 1, 13)
	end
	local animation = display.newAnimation(frames, 0.1)
	print("scenes==2")
	local function onComplete()
		print("bm.Room.result==",bm.Room.result)
		if bm.Room.result then
			print("bm.Room.result==",bm.Room.result)
			MenjiroomView:gameEnd(bm.Room.result)
		end
	end
	transition.playAnimationOnce(effect,animation,true,onComplete)
	effect:addTo(scenes)
	effect:setPosition(637.78, 366.23)
	bm.Room.all_compare = 1
	bm.Room.result = nil
end

-- 显示结果
function MenjiroomView:gameEnd(pack)
	dump(pack,"单局结算SVR_END")
	bm.Room.result = pack
	ZJH_GAME_STATE = GAME_STATUS_STOP
	MenjiroomView:stopTimer()
	MenjiroomView:resetOperate(false)
	require("FanSanPi.view.CompareView"):clearActions()
	--for k,v in pairs(ZJH_USER_UID) do
	--	ZJH_USER_UID_PLAYING[k] = 0;
	--end
	local win_uid = pack.winUid
	if win_uid == -1 then 
		self:showPingJuAni()
	end
    dump(pack.userinfos,"pack.userinfos")
	for k,v in pairs(pack.userinfos) do
		-- if v.turngold > 0 then
		-- 	win_uid = v.uid
		-- end

		local cards = nil
		local card_type=v.card_type


		-- if ZJH_IS_SHOW_ALLCARDS then
		-- 	if v.compare_content ~= nil then
		-- 		cards = v.compare_content[1]['cards']--MenjiroomView:sortOrder(v.compare_content[1]['cards'])

		-- 		MenjiroomView:setCards(v.uid, cards)
		-- 		MenjiroomView:showCard(v.uid)
		-- 	end	
		-- else
		if v.iscompare == 1 then-- or v.uid == USER_INFO["uid"] 
			cards = v['cards']--MenjiroomView:sortOrder(v.compare_content[1]['cards'])

			MenjiroomView:setCards(v.uid, cards)
			MenjiroomView:showCard(v.uid, card_type)

		else
			-- local base_foot = FanSanPiPanel:getChildByName("base_foot")
			local showCardGreen = FanSanPiPanel:getChildByName("showCardGreen")
			showCardGreen:setVisible(true)
		end
		-- end
	end
    -- if win_uid == nil then
    --     require("hall.GameTips"):showTips("提示", "", 3, "结算之后赢的筹码不能为零！")
    -- end
	local function callback()
		-- do return end
		MenjiroomView:addResult(pack, win_uid > 0)

		if ZJH_USER_UID[USER_INFO["uid"]] >=0 then
			MenjiroomView:showControlButtons(true)
			MenjiroomView:setChipsSumVisible(false)
		else
			if GROUP_MODE == 2 then
				MenjiroomView:showSitDownButton(true)
			end

		end

		-- 移除桌面动画
		MenjiroomView:clearBipai()
		print("clearBipai")
		-- if win_uid ~= nil then
		MenjiroomView:showChipsNowZhu(false)
		-- end
		print("showChipsNowZhu")
		MenjiroomView:clearCardNode()
		print("clearCardNode")
		MenjiroomView:hideCardType()
		print("hideCardType")
		MenjiroomView:relocatePlayer()
		print("relocatePlayer")
		-- 重置房间
		require("FanSanPi.FanSanPiSettings"):resetUserInfo()
		collectgarbage("collect")
		-- local base_foot = FanSanPiPanel:getChildByName("base_foot")
		local showCardGreen = FanSanPiPanel:getChildByName("showCardGreen")
		showCardGreen:setVisible(false)
	end
	MenjiroomView:recycleChips(win_uid, pack,callback)
end

function MenjiroomView:showPingJuAni()
	SoundUtils:playEffectSound("FanSanPi/sounds/pingju.mp3")
	local sp = display.newSprite("FanSanPi/layout/GameSceneSector/pingju.png")
	sp:setPosition(cc.p(0, 500))
	sp:setScale(0.3)
	sp:addTo(FanSanPiPanel:getChildByName("piaoNode"))
	local st = cc.ScaleTo:create(0.8, 1)
	local mt = cc.MoveTo:create(0.8 , cc.p(0, 100))
	local spa = cc.Spawn:create(st,mt)
	sp:runAction(transition.sequence({
            -- cc.DelayTime:create(1.2),
            spa,
            cc.FadeTo:create(4, 0),
            cc.CallFunc:create(function()
                sp:removeSelf()
        end),
        }))
end

function MenjiroomView:setChipsSumVisible(flag)

	print("setChipsSumVisible -------------------", FanSanPiPanel:getChildByName("diuChipNode"):isVisible(), debug.traceback())
	local chips_sum = FanSanPiPanel:getChildByName("chips_sum")
	if chips_sum then
		chips_sum:setVisible(flag)
	end
end

function MenjiroomView:relocatePlayer()
	dump(ZJH_USER_UID,"relocatePlayer")
	MenjiroomView:resetUserInfo()
	for  uid,seat in pairs(ZJH_USER_UID) do
		if seat >= 0 then
			local userInfo =  ZJH_USERINFO_TABLE[uid]
			MenjiroomView:showUserInfo(userInfo)
		end
	end

	-- if FSP_USER_UID_CARDS[USER_INFO.uid] ~= nil and next(FSP_USER_UID_CARDS[USER_INFO.uid]) ~= nil then
	-- 	if ZJH_GAME_STATE == GAME_STATUS_OUTCARD then
 --        	MenjiroomView:sendCard(cardSize, callbackStartSendCard)
 --        end
 --    end
end

--绘制用户列表
function MenjiroomView:drawGameoverList(pack,account)
	--function str_type(card_type)
	--	if card_type==nil then
	--		return "";
	--	elseif card_type==1 then
	--		return "散牌"
	--	elseif card_type==2 then
	--		return "一对"
	--	elseif card_type==3 then
	--		return "顺子"
	--	elseif card_type==4 then
	--		return "同花"
	--	elseif card_type==5 then
	--		return "同花顺"
	--	elseif card_type==6 then
	--		return "豹子"
	--	elseif card_type==7 then
	--		return "235"
	--	end
	--end
	-- body
	local scenes  = FanSanPiPanel
	print("account=====",account)
	if account==nil then
		return;
	end
	account:setVisible(true)
	--account:setVisible(true)
	local sing = account:getChildByName("single_panel")
	sing:setVisible(true);
	local panel;
	sing:getChildByName("ListView"):removeAllItems()
	local index = 0
	for k,v in pairs(pack.userinfos) do
		local cards = nil
		local card_type=nil
		if v.compare_content ~= nil then
			cards = MenjiroomView:sortOrder(v.compare_content[1]['cards'])
			card_type =v.compare_content[1]['card_type']
		end
		local panel_item
		if index % 2 == 0 then
			panel = sing:getChildByName("panel"):clone()
			panel_item=panel:getChildByName("panel_1")
			sing:getChildByName("ListView"):pushBackCustomItem(panel)
		else
			panel_item=panel:getChildByName("panel_2")
		end

		if v.happyMoney > 0 or v.happyMoney < 0 then
			local happyMoney  = panel_item:getChildByName("happyMoney")
			if happyMoney ~= nil then
				happyMoney:removeSelf()
			end
			local ttfConfig = {}
			ttfConfig.fontFilePath = "FanSanPi/res/fonts/fzcy.ttf"
			ttfConfig.fontSize = 36


			panel_item:getChildByName("victory_text"):setVisible(false)
			if v.happyMoney > 0 then
				happyMoney = cc.Label:createWithTTF(ttfConfig, "喜钱+"..v.happyMoney)
				happyMoney:setTextColor(cc.c4b(36,171,29,255));
			else
				happyMoney = cc.Label:createWithTTF(ttfConfig, "喜钱"..v.happyMoney)
				happyMoney:setTextColor(cc.c4b(164,18,24,255));
			end
			happyMoney:setPosition(cc.p(panel_item:getChildByName("victory_text"):getPosition().x,panel_item:getChildByName("victory_text"):getPosition().y))
			happyMoney:setName("happyMoney")
			happyMoney:addTo(panel_item)
		else
			panel_item:getChildByName("victory_text"):setVisible(true)
		end
		local tempScore = v.turngold/100
		local account_text = panel_item:getChildByName("account_text")
		account_text:setVisible(false)

		local txt_lb = display.newTTFLabel({
            text = content,
            font = "hall/res/font/FZY3JW.TTF",
            size = 30,
            color = cc.c3b(166, 59, 6),
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
            dimensions = cc.size(txtWidth, 0)
        })

        txt_lb:setAnchorPoint(account_text:getAnchorPoint())
        panel_item:addChild(txt_lb)
		txt_lb:setPosition(account_text:getPosition())
		if tempScore >0 then
			panel_item:getChildByName("victory_text"):setString("赢")
			panel_item:getChildByName("victory_text"):setTextColor(cc.c4b(36,171,29,255));
			txt_lb:setString("+"..tempScore)

		else
			panel_item:getChildByName("victory_text"):setString("输")
			panel_item:getChildByName("victory_text"):setTextColor(cc.c4b(164,18,24,255));
			txt_lb:setString(tempScore)
		end
		panel_item:setVisible(true)
		local  nick = ""
		if USER_INFO["uid"] == v.uid then
			if tempScore >0 then
				sing:getChildByName("top_img_lose"):setVisible(false)
				sing:getChildByName("top_img_win"):setVisible(true)
			else
				sing:getChildByName("top_img_lose"):setVisible(true)
				sing:getChildByName("top_img_win"):setVisible(false)
			end
		end
		nick = v.nickName
		local strNick = require("hall.GameCommon"):formatNick(nick)
		self:setNickString(panel_item, strNick)
		local head = self:getHeadNode(panel_item)
		if head == nil then -- 手动添加头像
			head = display.newSprite("FanSanPi/res/login/female_head.png")
			head:addTo(panel_item)
			head:setPosition(89.76, 58.31)
		end
		if head then
			local head_info = {}
			head_info["icon_url"] =   v.photoUrl or DefaultHead_filePath
			head_info["uid"] = v.uid
			head_info["sex"] = v["sex"] or 1
			head_info["sp"] = head
			head_info["size"] = 115
			head_info["touchable"] = 0
			head_info["use_sharp"] = 1
			require("hall.GameCommon"):setPlayerHead(head_info, head, head:getContentSize().width)
				--require("FanSanPi.FanSanPiSettings"):setPlayerHead(head_info,head,45)

		end
		local index_v = 0
		local card_class = panel_item:getChildByName("card_class")
		card_class:removeAllChildren()
		for i = 1,3 do
			local card = require("FanSanPi.common.PokerCard").new()
			card_class:addChild(card)
			-- card:setScale(1.43)
			card:pos(46.23+index_v*51.64,73.73)
			card:showBack()
			if v.iscompare==1 or v.uid == USER_INFO["uid"] then
				if cards ~= nil  then
					card:setCard(cards[i][1])
					card:showFront()
				end
				if v.uid == USER_INFO["uid"] then
					if bm.User.Cards[i] then
						card:setCard(bm.User.Cards[i][1])
						card:showFront()
					end
				end
			end
			index_v = index_v + 1
		end
		index = index +1
	end
	account:setVisible(true)
end

function MenjiroomView:onNetRanking2(pack)
	local scenes  = SCENENOW["scene"]
	--去掉提示弹框
	local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
	if layer_tips then
		layer_tips:removeSelf()
	end
	local data = {}
	data["resultSceneType"] = 2      --战绩界面展示选择，1为长条形，2为方块形
	data["invote_code"] = USER_INFO["invote_code"]      --房间号
	data["fenchang"] = BASE_CHIP            --分场
	data["round"] = pack.game_amount --.."/"..GROUP_TOTAL_ROUND                  --局数
	data["date"] = os.date("%Y-%m-%d-%H:%M")    --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
	data['activity_id'] = USER_INFO["activity_id"];
	data["resultData"] = {}

	for uid, user_info in pairs(pack.playerlist) do
		local user_result = {}             --玩家数据实体
		user_result["nick"] = user_info["nickName"]        --昵称
		user_result["uid"] = user_info.uid        --uid
		user_result["icon_url"] = user_info["photoUrl"]        --头像链接
		user_result["sex"] = user_info["sex"]               --性别
		user_result["isRoomOwer"] = 0        --是否为房主，1是，非1或不填不是
		if user_info["totalChips"] > 0 then
			user_result["isWinner"] = 1         --是否为赢家，1是，非1或不填不是
		else
			user_result["isWinner"] = 0
		end
		user_result["total"] = user_info["totalChips"]        --总输赢分


		user_result["gameDetail"] = {}       --游戏详情数组
		local gameDetail1 = {}           --游戏详情实体
		gameDetail1["showName"] = "赢的次数"   --展示名
		gameDetail1["value"] = user_info["win_num"] or 0         --值

		local gameDetail2 = {}
		gameDetail2["showName"] = "输的次数"
		gameDetail2["value"] = user_info["lose_num"] or 0

		table.insert(user_result["gameDetail"], gameDetail1)
		table.insert(user_result["gameDetail"], gameDetail2)
		table.insert(data["resultData"], user_result)
	end
	--返回大厅按钮点击事件
	local backHall_action = function(sender,event)
		-- if event == TOUCH_EVENT_BEGAN then
		-- 	sender:setScale(0.9)
		-- elseif event == TOUCH_EVENT_CANCELED then
		-- 	sender:setScale(1.0)
		-- elseif event == TOUCH_EVENT_ENDED then
		-- 	sender:setScale(1.0)
			local accountScene = SCENENOW["scene"]:getChildByName("accountScene")
			if not tolua.isnull(accountScene) then
				accountScene:removeSelf()
			end
			USER_INFO["gameConfig"] = ""
			require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
		-- end
	end

	--分享按钮点击事件
	local share_action = function(sender,event)
		-- if event == TOUCH_EVENT_BEGAN then
		-- 	sender:setScale(0.9)
		-- elseif event == TOUCH_EVENT_CANCELED then
		-- 	sender:setScale(1.0)
		-- elseif event == TOUCH_EVENT_ENDED then
		-- 	sender:setScale(1.0)
			local paras = {}
			paras["showType"] = 2;
			paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
			paras["imagePath"] = "screen"
			paras["name"] = "分享结果"
			paras["url"] = appDownLoadAddress
			local shareLayer = require("hall.share.ShareLayer").new(paras)
			if shareLayer then
				shareLayer:addTo(SCENENOW["scene"],9999999)
			end
			--require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
			----通知APP分享结果
			--if device.platform == "android" then
			--	require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
			--elseif device.platform ~= "windows" then
			--	require("hall.common.ShareLayer"):shareGroupResultForIOS()
			--end
		-- end
	end

	--再来一局
	local extend_action = function(sender,event)
		require("hall.groudgamemanager"):extend_freegame(USER_INFO["uid"], USER_INFO["activity_id"], TpackageName .. ".gameScene")
	end

	RESULT_RANKING = data
	if IS_RANKING then
		require("hall.settlement.settlement").new(data, backHall_action, share_action, nil, extend_action)
		-- require(SETTLEMENT_VIEW).new(data, backHall_action, share_action)
	end
	--ZJHGroupEndPanel = scenes:getChildByName("gameresultScene")
	--if ZJHGroupEndPanel then
	--	JHGroupEndPanel:setVisible(false)
	--end
end

-- 添加结算数据
function MenjiroomView:addResult(pack, hasWin)

	local scenes  = SCENENOW["scene"]
	MenjiroomView:clearDesk(hasWin)
	print("clearDesk")
	MenjiroomView:showShare(false)
	print("showShare")
	--MenjiroomView:resultTime(10,btn_next,callback)
	--end
	IS_RANKING = true
	if RESULT_RANKING then
		--返回大厅按钮点击事件
		local backHall_action = function(sender,event)
			-- if event == TOUCH_EVENT_BEGAN then
			-- 	sender:setScale(0.9)
			-- elseif event == TOUCH_EVENT_CANCELED then
			-- 	sender:setScale(1.0)
			-- elseif event == TOUCH_EVENT_ENDED then
			-- 	sender:setScale(1.0)
                local accountScene = SCENENOW["scene"]:getChildByName("accountScene")
                if not tolua.isnull(accountScene) then
                    accountScene:removeSelf()
                end
				USER_INFO["gameConfig"] = ""
				require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
			-- end
		end

		--分享按钮点击事件
		local share_action = function(sender,event)
			-- if event == TOUCH_EVENT_BEGAN then
			-- 	sender:setScale(0.9)
			-- elseif event == TOUCH_EVENT_CANCELED then
			-- 	sender:setScale(1.0)
			-- elseif event == TOUCH_EVENT_ENDED then
			-- 	sender:setScale(1.0)
				--通知APP分享结果
				local paras = {}
				paras["showType"] = 2;
				paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
				paras["imagePath"] = "screen"
				paras["name"] = "分享结果"
				paras["url"] = appDownLoadAddress
				local shareLayer = require("hall.share.ShareLayer").new(paras)
				if shareLayer then
					shareLayer:addTo(SCENENOW["scene"],9999999)
				end
				--if device.platform == "android" then
				--	require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
				--elseif device.platform ~= "windows" then
				--	require("hall.common.ShareLayer"):shareGroupResultForIOS()
				--end
			-- end
		end
		local extend_action = function(sender,event)
			require("hall.groudgamemanager"):extend_freegame(USER_INFO["uid"], USER_INFO["activity_id"], TpackageName .. ".gameScene")
		end
		require("hall.settlement.settlement").new(RESULT_RANKING, backHall_action, share_action,nil,extend_action)
		-- require(GameResultScene_filePath):showScene(RESULT_RANKING, backHall_action, share_action)
		print("showScene")
	end
	print("showScene2")
end



--回收筹码
function MenjiroomView:recycleChips(uid,pack,callback)
	-- uid = 666683
	print("MenjiroomView:recycleChips")
    local scenes  = FanSanPiPanel
	local user_node = MenjiroomView:getUserNode(uid)
	dump(user_node,"user_nodejjjj")
	if user_node == nil then
		print("recycleChips can't get user_node", tostring(uid))
		if callback then
			FanSanPiPanel:runAction(transition.sequence({
	            cc.DelayTime:create(2),
	            cc.CallFunc:create(function()
	                callback()
	        end),
	        }))
		end
		return
	end
	local pos = 0
    local effect_all=scenes:getChildByName("effect_all");
    if effect_all then
        effect_all:setVisible(false)
    end
	local chipsLis =table.getn(bm.Room.chips)
	--if chipsLis < 15 then
	--	for i = 1, chipsLis do
	--		for i = 1, 2 do
	--			local rand_chips = math.random(20,1000)
	--			local chip= UiCommon:getChipBtnNew(rand_chips,4)
	--			table.insert(bm.Room.chips,chip)
    --
	--			local rand_x = math.random(404.75,885.09)
	--			local rand_y = math.random(210.17,473.16)
	--			chip:setPosition(cc.p(rand_x,rand_y))
	--			chip:addTo(scenes)
	--		end
	--	end
	--end
	local time = 1.2
	local flag_callback =true
	local index_count = table.getn(bm.Room.chips)
	local chip_count = table.getn(bm.Room.chips)
	local time_init = 0.8 / chip_count
	dump(time_init,"time_init")
	-- local targetPos = scenes:convertToWorldSpace(self:getHeadNode(user_node):getPosition())
	--将head的坐标映射到世界坐标系中去
	local head = self:getHeadNode(user_node)
	local planeItem_world_pos = (head:getParent()):convertToWorldSpace(head:getPosition())
	local targetPos = scenes:getChildByName("diuChipNode"):convertToNodeSpaceAR(planeItem_world_pos)
	dump(bm.Room.chips,"bm.Room.chips")
	if not next(bm.Room.chips) then

	end
	for k,v in pairs(bm.Room.chips) do
		pos = pos + 1
		if tolua.isnull(v) == false then
			v:setLocalZOrder(99999)
		end
		local remove_chips = function ()
			-- body
			v:removeSelf()
			index_count = index_count - 1;
			if index_count <= 0 then
				if flag_callback then
					flag_callback = false
					local handle = scheduler.performWithDelayGlobal(callback, time)
					table.insert(schedulerEvents, handle)
				end

			end
		end
		local callfunc = function()

			print("recycleChips callfunc", tostring(uid))
			MenjiroomView:kuangLight(uid)
			MenjiroomView:gameEndMoneyAnim(pack)
		end

		if pos == 1 then
			if tolua.isnull(v) == false then
				local jumpHeight = math.random(0,1)
				local callback1           = cc.CallFunc:create(remove_chips)
				local callback2           = cc.CallFunc:create(callfunc)
				local mb = cc.JumpTo:create(k * time_init, targetPos, jumpHeight, 2)
				local fo = cc.FadeOut:create(0.1)
				local sq  = cc.Sequence:create(mb, fo, callback1, callback2)
				v:stopAllActions()
				v:runAction(sq)
			else
				index_count = index_count - 1;
				if index_count <= 0 then
					if flag_callback then
						flag_callback = false
						local handle = scheduler.performWithDelayGlobal(callback, time)
						table.insert(schedulerEvents, handle)
					end
				end
			end
		else
			if tolua.isnull(v) == false then
				local jumpHeight = math.random(0,1)
				local callback           = cc.CallFunc:create(remove_chips)
				local mb = cc.JumpTo:create(k * time_init, targetPos, jumpHeight, 2)
				local fo = cc.FadeOut:create(0.1)

				local seq = cc.Sequence:create(mb, fo, callback) --cc.DelayTime:create(0.4),
				v:stopAllActions()
				v:runAction(seq)
			else
				index_count = index_count - 1;
				if index_count <= 0 then
					if flag_callback then
						flag_callback = false
						local handle = scheduler.performWithDelayGlobal(callback, time)
						table.insert(schedulerEvents, handle)
					end
				end
			end
		end
	end
end

--玩家收钱的相框发亮
function MenjiroomView:kuangLight(uid)

	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil or true then
		print("kuangLight can't get user_node", tostring(uid))
		return
	end
	local index     = ZJH_PLAYERTYPE_TABLE[uid]
	local light_kuang
	local frames
	if uid == USER_INFO["uid"] or index == 0 then
		light_kuang= display.newSprite("#headWinMine1.png")
		frames = display.newFrames("headWinMine%d.png", 1, 10)
		if frames == nil then
			display.addSpriteFrames("FanSanPi/res/room/animation/headWinNew.plist", "FanSanPi/res/room/animation/headWinNew.png")
			frames = display.newFrames("headWinMine%d.png", 1, 10)
		end
	else

		light_kuang= display.newSprite("#headWin1.png")
		frames = display.newFrames("headWin%d.png", 1, 10)
		if frames == nil then
			display.addSpriteFrames("FanSanPi/res/room/animation/headWinNew.plist", "FanSanPi/res/room/animation/headWinNew.png")
			frames = display.newFrames("headWin%d.png", 1, 10)
		end
	end
	light_kuang:setScale(2)

	local animation = display.newAnimation(frames, 0.1)

	local function onComplete()
		local scenes = FanSanPiPanel
		local account = scenes:getChildByName("accountScene")
		if account == nil then
			--MenjiroomView:addResult(pack)
		end

		if account then
			if is_show_zjh_sing ==false or is_show_zjh_sing ==nil then
				account:setVisible(true)
			end
		end

	end
	--[[if device.platform == "ios" then
		light_kuang:playAnimationOnce(animation, {removeSelf=true,onComplete=onComplete})
	elseif device.platform == "android" then
		light_kuang:playAnimationOnce(animation, true,onComplete)
	else
		light_kuang:playAnimationOnce(animation, {removeSelf=true,onComplete=onComplete})
	end]]
	transition.playAnimationOnce(light_kuang,animation,true,onComplete)
	light_kuang:addTo(user_node, 2)


	light_kuang:pos(user_node:getContentSize().width/2, user_node:getContentSize().height/2)
end

--钱上浮飘啊飘
function MenjiroomView:gameEndMoneyAnim(pack)
	-- body
	require("hall.GameCommon"):playEffectSound("FanSanPi/res/audio/login_gold.mp3")

	for k,v in pairs(pack.userinfos) do
		local uid       = v.uid
		local index     = ZJH_PLAYERTYPE_TABLE[uid]
		local user_node = MenjiroomView:getUserNode(uid)
		if user_node then
			local num       = nil
			local tempScore = v.turngold/100
			-- if tempScore > 0 then
			-- 	num  =  UiCommon:gameWinGold(tempScore)
			-- else
			-- 	num  =  UiCommon:gameLostGold(-tempScore)
			-- end
			local str = ""
			local score_txt = user_node.head_plane.score_txt
			if tempScore > 0 then
				str = "+"..tostring(tempScore)
				-- score_txt:setColor(cc.c3b(255,255,255))
				score_txt:setFntFile("FanSanPi/layout/player_plane/win_num.fnt")
			else
				str = tostring(tempScore)
				-- score_txt:setColor(cc.c3b(255,255,255))
				score_txt:setFntFile("FanSanPi/layout/player_plane/lose_num.fnt")
			end
			-- score_txt:setString(str)
			self:setScoreString(user_node, str)
			-- num:addTo(user_node)
			-- num:setScale(0.5)
			-- local ccp=user_node:convertToNodeSpace(MenjiroomView:getHeadPos(index))
			-- num:pos(ccp.x,ccp.y)
			-- num:setCascadeOpacityEnabled(true)
			-- num:setLocalZOrder(9999)
			-- local move    = cc.MoveTo:create(2,cc.p(ccp.x,ccp.y+70))
			local FadeIn = cc.FadeIn:create(0.2)
			local FadeOut = cc.FadeOut:create(0.2)
			local delay= cc.DelayTime:create(2)
			local seq = cc.Sequence:create(FadeIn, delay, FadeOut)
			-- local spawn   = cc.Spawn:create(move,fadeout)
			score_txt:runAction(seq)
			--if v.happyMoney > 0 or v.happyMoney < 0  then
			--	local happyMoney  = user_node:getChildByName("happyMoney")
			--	if happyMoney ~= nil then
			--		happyMoney:removeSelf()
			--	end
			--	local ttfConfig = {}
			--	ttfConfig.fontFilePath = "res/fonts/fzcy.ttf"
			--	ttfConfig.fontSize = 36
			--	if v.happyMoney > 0 then
			--		happyMoney = cc.Label:createWithTTF(ttfConfig, "喜钱+"..v.happyMoney)
			--	else
			--		happyMoney = cc.Label:createWithTTF(ttfConfig, "喜钱"..v.happyMoney)
			--	end
            --
			--	--happyMoney:setAnchorPoint(cc.p(point))
			--	happyMoney:setPosition(cc.p(position[index]['x'],position[index]['y']))
			--	happyMoney:setColor(cc.c3b(213,41,31))
			--	happyMoney:setName("happyMoney")
			--	happyMoney:addTo(user_node)
			--	local fadeout = cc.FadeOut:create(4)
			--	happyMoney:runAction(fadeout)
			--end
			--bi_back:setScale(1.2)


			-- ZJH_TABLE_CHIPS[uid] = v["chips"]
			-- 更新玩家金币
			--local num_chips = UiCommon:numFormat(v["chips"])
			local finalChip = v["chips"]
			if finalChip then
				ZJH_USER_TOTAL_CHIPS[uid] = finalChip
				MenjiroomView:setCoin(uid,finalChip)
				if GROUP_MODE == 1 then
					finalChip = finalChip 
					ZJH_USER_TOTAL_CHIPS[uid] = finalChip
				else
					if finalChip and finalChip > 100000 then
						local finalChipTxt = tostring(finalChip/10000)
						finalChip = string.format("%.1f", finalChipTxt) .. "万"
					end
				end

				self:setGoldString(user_node, finalChip/100)
			end
		end
	end
end

--聊天内容
function MenjiroomView:chatContent(uid,str)
	--body
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return nil
	end

	local index     = ZJH_PLAYERTYPE_TABLE[uid]
	local file      = "chat_bubble_l1.png"
	local len       = #str
	dump(string.len(str) ,"======len")
	--if string.len(str)     <= 3 then
	--	file = "chat_bubble_left.png"
    --
	--end
	local headPos=MenjiroomView:getHeadPos(index)
	local point ={
		x = 0,
		y = 0.5
	}
	if headPos.x>cc.Director:getInstance():getWinSize().width/2 then
		point.x = 1
		file = "chat_bubble_r1.png"

	end



	local length    = 50*len/3
	local rlen      = 0

	local start_x = 0

	if length < 100 then
		rlen = 100
	else
		rlen=length+20
		start_x = 22/3*(len/3)
	end


	start_x = start_x  + (rlen - length)/2


	local bi_back   = user_node:getChildByName("chat")
	if bi_back ~= nil then
		bi_back:removeSelf()
	end

	--bi_back   = display.newScale9Sprite("FanSanPi/res/room/chatExpress/"..file,0,0,cc.size(rlen,90),cc.rect(20,10,220,50))
	--bi_back   = cc.Scale9Sprite:create("FanSanPi/res/room/chatExpress/"..file,cc.rect(0, 0, rlen, 90),cc.rect(20,10,rlen,50))
	bi_back   = cc.Scale9Sprite:create("FanSanPi/res/room/chatExpress/"..file)
	bi_back:addTo(user_node)
	bi_back:setName("chat")
	bi_back:setCascadeOpacityEnabled(true)
	bi_back:setLocalZOrder(999999999)
	local positionText ={
		x = 0,
		y = 0
	}
	positionText.x = 25
	positionText.y = bi_back:getContentSize().height/2
	if headPos.x > cc.Director:getInstance():getWinSize().width/2 then
		positionText.x = bi_back:getContentSize().width - 25
		positionText.y = bi_back:getContentSize().height/2
	end
	local text  = bi_back:getChildByName("font")
	if text ~= nil then
		text:removeSelf()
	end
	local ttfConfig = {}
	ttfConfig.fontFilePath = "FanSanPi/res/fonts/fzcy.ttf"
	ttfConfig.fontSize = 30
	text = cc.Label:createWithTTF(ttfConfig, str)
	text:setAnchorPoint(cc.p(point))
	text:setPosition(cc.p(positionText))
	text:setColor(cc.c3b(65,139,223))
	text:setName("font")
	text:addTo(bi_back)
	local ccp=user_node:convertToNodeSpace(headPos)
	if headPos.x<=cc.Director:getInstance():getWinSize().width/2 then
		bi_back:pos(ccp.x+50+bi_back:getContentSize().width/2,ccp.y+70)
	else
		bi_back:pos(ccp.x-50-bi_back:getContentSize().width/2,ccp.y+70)
	end

	--bi_back:setScale(1.2)

	local fadeout = cc.FadeOut:create(2)
    local seq = cc.Sequence:create(fadeout, cc.CallFunc:create(function()
        if tolua.isnull(bi_back) == false then
            bi_back:removeSelf()
        end

    end))
	bi_back:runAction(seq)

end
--全压
function MenjiroomView:showAllin()
	local scenes  = FanSanPiPanel
	local effect_all=scenes:getChildByName("effect_all");
	if effect_all then
		effect_all:setLocalZOrder(10)
		effect_all:setVisible(true)
		-- PK光
		local pk_light = display.newSprite("FanSanPi/res/room/compareCard/light01.png")
		pk_light:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE))
		pk_light:addTo(effect_all, 4)
		pk_light:setPosition(22.35, 38.82)
		--[[local mt = cc.MoveTo:create(0.4, cc.p(128.14, 34.05))
		local callback           = cc.CallFunc:create(function()
			pk_light:removeSelf()
		end)
		local sq=cc.Sequence:create(mt, callback)
		pk_light:runAction(sq)]]
		transition.execute(pk_light,  transition.moveTo(pk_light, {x = 114.02, y =  48.82, time = 0.2}), {
			delay = 0.87,
			easing = "sineOut",
			onComplete = function()
				pk_light:removeSelf()
			end,
		})
	end
end
--结算清理
function  MenjiroomView:clearDesk(hasWin)
	-- 重置轮数
	bm.Room.now_turns = 0
	MenjiroomView:showRounds()
	bm.Room.now_turns = 1
	isKanBtn=false
	for k,v in pairs(ZJH_USER_UID) do
		local user_node = MenjiroomView:getUserNode(k)
		if user_node then
			local gold_back = user_node:getChildByName("gold_back")
			if gold_back ~= nil then
				gold_back:removeSelf()
			end
		
			self:setReadyVisible(user_node, false)

			local failed = user_node:getChildByName("failed")
			if failed ~= nil then
				failed:removeSelf()
			end
			local state = self:getStateNode(user_node)
			if state ~= nil then
				state:hide()
			end
		end
	end
	local scenes  = FanSanPiPanel
	local card_my_node = MenjiroomView:getUserNode(USER_INFO["uid"])
	-- if card_my_node then
	-- 	local card_kan=card_my_node:getChildByName("stat2e")
	-- 	if card_kan~=nil then
	-- 		card_kan:removeSelf()
	-- 	end
	-- end
	self:isKanButton(false)

	local effect_all=scenes:getChildByName("effect_all")
	if effect_all~=nil then
		effect_all:setVisible(false)
	end
	bm.User.Cards     = {}
	bm.User.isKan     = {} --玩家是否看牌
	bm.User.isDiu     = {} --玩家是否弃牌
	bm.Room.anim      = 0
	if hasWin then
	    for k,v in pairs(bm.Room.chips) do
	        if tolua.isnull(v) == false then
	            v:removeSelf()
	        end
	    end
	    bm.Room.chips     = {}
	end
	
	bm.Room.zhus      = {}
	bm.SchedulerPool:clearAll()

end

-- 显示庄的位置
function MenjiroomView:showBanker(sid)
	print("showBanker sid", tostring(sid))
	local uid = ZJH_USER_SEAT[sid]
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		print("showBanker can't get user_node")
		return
	end
	local index     = MZJH_PLAYERTYPE_TABLE[uid]
	local offset_x = 0
	if index == 3 or index == 4 then
		offset_x = 30 - user_node:getContentSize().width
	end

	local banker = display.newSprite("FanSanPi/res/banker.png")
	banker:addTo(user_node, 100)
	banker:setPosition(cc.p(user_node:getContentSize().width - banker:getContentSize().width/2 + offset_x, user_node:getContentSize().height - banker:getContentSize().height/2))

	bm.Room.banker = banker
end
function MenjiroomView:showVoice()
	local scenes  = FanSanPiPanel
     if scenes then
		 local btn_voice = scenes:getChildByName("btn_voice")
		 local voice_bt_worldpoint = (btn_voice:getParent()):convertToWorldSpace(btn_voice:getPosition())
		 local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
		 if  VoiceRecordView.addVoiceRecordEvent then
             btn_voice:setVisible(true)
			 VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
		 else
			 VoiceRecordView:showView(voice_bt_worldpoint.x,voice_bt_worldpoint.y,999)
		 end
		 btn_voice:setVisible(true)
	 end


end
function MenjiroomView:showNetwork(uid,flag)

	local scenes  = FanSanPiPanel
	if scenes==nil  then
		return
	end
	local userNode = MenjiroomView:getUserNode(uid)
	if userNode==nil  then
		return
	end
	dump("显示network_img"..uid,flag)
	
	ViewBase:seekChild(userNode, "network_img"):setVisible(flag)

end
function MenjiroomView:getDeviceInfo()
	local scenes  = FanSanPiPanel
	if scenes==nil  then
		return
	end
	local device_info_plane = scenes:getChildByName("device_info_plane")
	--device_info_plane:setVisible(false)
	require("hall.util.GameMenu"):getDeviceInfo(device_info_plane)
end
function MenjiroomView:readyRoom()
	MenjiroomServer:CLI_READYNOW_ROOM()

end
function MenjiroomView:setCoin(uid,value)
	if ZJH_USERINFO_TABLE[uid] then
		ZJH_USERINFO_TABLE[uid].m_chips = value
	end
	if GROUP_MODE == 2 then
		require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,{["gold"] = value},"gold")
	end

end
function MenjiroomView:showTaiFeiTips(chips)
	local scenes  = FanSanPiPanel
	if scenes==nil  then
		return
	end



	--添加扣除台费显示
	local taiFeiTxt =0
	if  chips < 0 then
		taiFeiTxt = "扣除台费"..math.abs(chips)
	end

	-- niuniu/font/arial.ttf

	local lbVersion = cc.Label:createWithTTF(taiFeiTxt, "FanSanPi/res/fonts/systemFont.TTF",30)
	scenes:addChild(lbVersion,9999)
	lbVersion:setColor(cc.c3b(0xBF, 0xBF, 0xBF))
	lbVersion:setPosition(cc.p(scenes:getContentSize().width/2,100))
	lbVersion:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function() lbVersion:removeFromParent() end)))
end
function MenjiroomView:setGameConfigNew(jsonConfig)
	dump(jsonConfig,"123456789987654321")
	local json = json.decode(jsonConfig) or {}
    local str = ""
    USER_INFO["gameConfig"] ={}
    if json["dizhu"] then
        str = str .. "底注:" .. json["dizhu"].."轮封顶"
        table.insert(USER_INFO["gameConfig"],{["底注:"] = json["dizhu"].."分"})
    end
    if json["twoFill"] then
        str =  str.."两人加注数:"..json["twoFill"].."轮以上PK"
         table.insert(USER_INFO["gameConfig"],{["两人加注数"] = json["twoFill"].."次"})
    end
    if json["moreFill"] then
        str = str .. "多人加注数:"..json["moreFill"] .."轮以上血拼"
        table.insert(USER_INFO["gameConfig"],{["多人加注数"] = json["moreFill"].."次"})
    end
    if json["happy_money"] then
    	local wanfa = ""
    	if tonumber(json["happy_money"]) ~= nil then
    		local v = tonumber(json["happy_money"])
    		if v == 1 then
    			wanfa = wanfa.."有喜分,"
    		elseif v == 2 then
    			wanfa = wanfa.."方片3为癞子,"
    		elseif v == 3 then
    			wanfa = wanfa.."有真三皮,"
    		elseif v == 4 then
    			wanfa = wanfa.."有假三皮,"
    		end
    	else
	    	local lst = string.split(json["happy_money"], ",")
	    	
	    	for i,v in ipairs(lst or {}) do
	    		if v == 1 then
	    			wanfa = wanfa.."有喜分,"
	    		elseif v == 2 then
	    			wanfa = wanfa.."方片3为癞子,"
	    		elseif v == 3 then
	    			wanfa = wanfa.."有真三皮,"
	    		elseif v == 4 then
	    			wanfa = wanfa.."有假三皮,"
	    		end
	    	end
	    end
        str = str .. "玩法:"..wanfa
        table.insert(USER_INFO["gameConfig"],{["玩法:"] = wanfa})
    end
    

    IS_SHOW_ALLCARDS = json["show_allCard"] or 0

	--local share_content = "PK:"..json["min_round_pk"].."轮以上PK 火拼:"..json["min_round_allin"].."轮以上火拼, 闷圈:闷"..json["circleNeededToShowCards"].."圈, 手数:"..json["max_round"].."轮封顶"
	USER_INFO["gameConfigMsg"] = str
	--USER_INFO["gameConfig"] ={
	--	{["PK"] = json["min_round_pk"].."轮以上PK"},
	--	{["火拼"] = json["min_round_allin"].."轮以上火拼"},
	--	{["闷圈:闷"] = json["circleNeededToShowCards"].."圈"},
	--	{["手数"] = json["max_round"].."轮封顶"},
	--}
	--dump(share_content,"share_content")
end

-- 获得花色
function MenjiroomView:getVariety(card)
	return bit.band(card, 0xF0)
end

-- 获得牌值
function MenjiroomView:getValue(card)
	local value = bit.band(card, 0x0F)
	print("value111",value)
	if value == 1 then
		value = 14
	end
	return value
end

function MenjiroomView:sortOrder(cards)
	if cards == nil or not next(cards) then
		return nil
	end
	local test = {{},{},{}}
	local valueTable = {14, 2 ,3}
	for k, v in pairs(cards) do
		for i, m in pairs(valueTable) do
			local n  = MenjiroomView:getValue(v)
			if m == n then
				table.remove(valueTable,i)
			end
		end
	end
	for k, v in pairs(cards) do
		table.insert(test[k], {color = MenjiroomView:getVariety(v), value = MenjiroomView:getValue(v)})
	end
	table.sort(test, function (a,b)
		if a[1].value == b[1].value then
			return a[1].color > b[1].color
		else
			if a[1].value == 0 then
				return true
			elseif b[1].value == 0 then
				return false
			end
			return a[1].value > b[1].value
		end
	end)
	if next(valueTable) then

	else
		local valueTest =  test[2];
		table.remove(test, 2)
		table.insert(test,3, valueTest)

	end
	return test;
end

function MenjiroomView:setGameSetting()
	MenjiroomView.roomCommonLayer = require("hall.roomCommonUI.RoomCommonPDKLayer").new(self:getToDisbandFuncs())
	self:addChild(MenjiroomView.roomCommonLayer, 15)
	MenjiroomView.roomCommonLayer:setTouchSwallowEnabled(false)
	MenjiroomView.roomCommonLayer:setVisible(false)
	self:loadGameMsgLayer()
end


function MenjiroomView:showGameSetting()
	print("=====MenjiroomView:showGameSetting=====")
	print("=====MenjiroomView:showGameSetting=====")
	self:setGameSetting()
	self:loadMoreFuncLayer()
end
function MenjiroomView:addVoiceRecordEvent(btn_voice)
	print("voice")
	local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
	if  VoiceRecordView.addVoiceRecordEvent then
		print("voice22")
		VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
	end
end
function MenjiroomView:disbandRoom()
	if g_isWatch == 0 then
		require("hall.GameTips"):showTips("提示", "", 1, "旁观不能解散房间")
		return
	end

	MenjiroomServer:C2G_CMD_DISSOLVE_ROOM()
end

function MenjiroomView:rejectDisband()
	MenjiroomServer:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function MenjiroomView:agreeDisband()
	MenjiroomServer:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function MenjiroomView:getToDisbandFuncs()
	local data = {}
	data.quitRoomHandler = handler(self, self.quitRoom)
	data.disbandRoomHandler = handler(self, self.disbandRoom)
	data.rejectDisbandRoomHandler = handler(self, self.rejectDisband)
	data.agreeDisbandRoomHandler = handler(self, self.agreeDisband)
	data.showMoreFuncHandler = handler(self, self.loadMoreFuncLayer)
	--data.showGameMsgLayerHandler = handler(self, self.loadGameMsgLayer)
	data.voiceRecordHandler = handler(self,self.addVoiceRecordEvent)
	return data
end

function MenjiroomView:loadMoreFuncLayer()
	print("=====loadMoreFuncLayer=====")
	if tolua.isnull(MenjiroomView.moreFuncLayer) then
		MenjiroomView.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
		self:addChild(MenjiroomView.moreFuncLayer, 99999)
		-- self:addChild(MenjiroomView.moreFuncLayer)
		-- g_roomCommonLayer = self.moreFuncLayer
	else
		MenjiroomView.moreFuncLayer:setVisible(true)
		MenjiroomView.moreFuncLayer:showAni()
	end
	print("======SCENENOW['scene'].GameRound======",SCENENOW["scene"].GameRound)
	if 0 == bm.Room.now_turns and MenjiroomView.isHide == false then
        self.moreFuncLayer.btnDisbandRoom:setVisible(false)
    else
        self.moreFuncLayer.btnDisbandRoom:setVisible(true)
    end
	print("loadMoreFuncLayer --------------------", g_isWatch)
	if g_isWatch == 0 then
        self.moreFuncLayer:set_btnDisbandRoom_visible(false)
    end
end

function MenjiroomView:loadGameMsgLayer()
	if tolua.isnull(MenjiroomView.gameMsgLayer) then
		MenjiroomView.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
		self:addChild(MenjiroomView.gameMsgLayer, 99999)
		MenjiroomView.gameMsgLayer:setVisible(false)
	else
		MenjiroomView.gameMsgLayer:setVisible(true)
		MenjiroomView.gameMsgLayer:showContentByType(1)
	end
end

function MenjiroomView:getToSendFaceAndTxtFuncs()
	local data = {}
	-- data.sendEditHand = handler(self, self.sendEditTxt)
	data.sendFaceHand = handler(self, self.sendFaceByIdx)
	return data
end
function MenjiroomView:quitRoom()
	MenjiroomServer.CLI_QUIT_ROOM()
end

function MenjiroomView:sendFaceByIdx(id, msgType, to_uid)
	print("sendFaceMsg --------------------------", id, msgType, to_uid, debug.traceback())
	MenjiroomServer:CLI_MSG_FACE(id, msgType, to_uid)
end

function MenjiroomView:sendEditTxt(str)
	print("sendEditMsg --------------------------", id)
end
function MenjiroomView:onExit()
	for k,handle in pairs(schedulerEvents) do
		scheduler.unscheduleGlobal(handle)
	end
	schedulerEvents = {}
	SCENENOW["scene"]:stopAllActions()
	print('onExit-MenjiroomView')
	print(type(FanSanPiPanel))
	if FanSanPiPanel then
		FanSanPiPanel:stopAllActions()
		FanSanPiPanel = nil
		print("FanSanPiPanel:removeSelf")
		--FanSanPiPanel:removeSelf()
	end
end
function MenjiroomView:onEnter()
	--cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1280, 720, cc.ResolutionPolicy.SHOW_ALL)
end
function MenjiroomView:_initRankeng(root)
	local fin_box = root:getChildByName("fin_box")
	--local bg = FanSanPiPanel:getChildByName("room_bg")
	local precent = MenjiroomView:_getScaleParam2()
	if fin_box then
		fin_box:setScaleX(fin_box:getScale()*precent)
		local x = fin_box:getPositionX()
		fin_box:setPositionX(x*precent)
	end
	local child = root:getChildren()
	for i, v in ipairs( child or {} ) do
		local x = v:getPositionX()
		v:setPositionX(x*precent)
		if v:getDescription() == "ListView" then --容器按照比率重新设置大小
			local size = v:getContentSize()
			v:setScaleX(v:getScale()*precent)
			dump("ListView===")
			--v:setContentSize(cc.size(size.width * precent, size.height))
		end
	end
end
function MenjiroomView:initUI()
	require("FanSanPi.view.CompareView"):initUI()
	-- if FanSanPiPanel then
	-- 	local bg = FanSanPiPanel:getChildByName("room_bg")
	-- 	bg:show()
	-- 	local precent = MenjiroomView:_getScaleParam2()
	-- 	if bg then
	-- 		bg:setScaleX(bg:getScale()*precent)
	-- 		local x = bg:getPositionX()
	-- 		bg:setPositionX(x*precent)
	-- 	end

	-- 	local root = FanSanPiPanel
	-- 	if root then
	-- 		local child = root:getChildren()
	-- 		for i, v in ipairs( child or {} ) do
	-- 			local x = v:getPositionX()
	-- 			v:setPositionX(x*precent)
	-- 			if v:getDescription() == "ListView" then --容器按照比率重新设置大小
	-- 				local size = v:getContentSize()
	-- 				v:setContentSize(cc.size(size.width * precent, size.height))
	-- 			end
	-- 		end
	-- 	end
	-- end

	for index = 1, 6 do
		local user_node = FanSanPiPanel["player_plane_"..index]
		user_node:hide()
		self:setGoldString(user_node, "")--积分
		self:setScoreString(user_node, "") --用户输赢积分
		self:setReadyVisible(user_node, false)--准备
		self:setZhuangVisible(user_node, false)--庄
		self:setFangZhuVisible(user_node, false)--房主
		self:getChipBgNode(user_node):hide() --筹码
		self:getStateNode(user_node):hide() --看牌弃牌状态
		self:getEffect_frame(user_node):hide() --人物框特效
		self:set_grab_banker_times_txt(user_node) --抢庄积分
	end
	self:hideCardType()
	self:isKanButton(false)
end

function MenjiroomView:_getScaleParam2()
	local frameHeight = CONFIG_WIN_HEIGHT
	local disHeight = CONFIG_DESIGN_HEIGHT
	return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
	-- return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end
function MenjiroomView:_getScaleParam()
	local frameHeight = CONFIG_WIN_HEIGHT
	local disHeight = CONFIG_DESIGN_HEIGHT

	return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end

function MenjiroomView:onClick_share_btn()
	local paras = {}
	paras["showType"] = 2;
	paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
	paras["imagePath"] = "screen"
	paras["name"] = "分享结果"
	paras["url"] = appDownLoadAddress
	local shareLayer = require("hall.share.ShareLayer").new(paras)
	if shareLayer then
		shareLayer:addTo(SCENENOW["scene"],9999999)
	end
end
function MenjiroomView:cuopaiTestHide()
	local  cuoPaiScene = FanSanPiPanel:getChildByName("cuopai")
	if  not tolua.isnull(cuoPaiScene) then
		local cuopai_plane = cuoPaiScene:getChildByName("cuopai_plane")
		if not tolua.isnull(cuoPaiScene) then
			cuoPaiScene:removeFromParent()
		end
	end

end
function MenjiroomView:cuopaiTest(MY_CARDS)
    local cuoPaiScene =   cc.CSLoader:createNode("FanSanPi/layout/CuopaiScene.csb"):addTo(FanSanPiPanel)
    cuoPaiScene:setName("cuopai")
	cuoPaiScene:setLocalZOrder(99999)
	local  visibleSize = cc.Director:getInstance():getVisibleSize()
    --cuoPaiScene:setScale(visibleSize.width/DESIGN_SCREEN_WIDTH)

    cuoPaiScene:setVisible(true)
    --MY_CARDS ={0x15,0x14,0x25,0x21,0x23}
    local endTime = 7
    --@zC 7秒之后自动释放
    --@zc动画结束位置

    local cuopai_plane = cuoPaiScene:getChildByName("cuopai_plane")
	local close = cuopai_plane:getChildByName("b_close")
	close:addTouchEventListener(function (sendr,event)
		if event == TOUCH_EVENT_ENDED then
			if not tolua.isnull(cuoPaiScene) then
				MenjiroomView:setCards()
				MenjiroomView:showCardType(bm.User.card_type)
				cuoPaiScene:removeFromParent()
			end
		end
	end)
    --cuopai_plane:setPosition(cc.p(DESIGN_SCREEN_WIDTH/2,DESIGN_SCREEN_HEIGHT/2))

    local card_1= cuopai_plane:getChildByName("card_1")
    local card_2= cuopai_plane:getChildByName("card_2")
    local card_3= cuopai_plane:getChildByName("card_3")
     --card_4:setPosition(cc.p(endPosX, enPosY))
     --card_5:setPosition(cc.p(endPosX, enPosY))
    backCardNum = 3

	local CardRotateAngle = 12
    local cuoPaiSceneHasRemoved = false
	local testTme = 0
	local cuopaiIndex = 1
    local CloseEvent  = function(sender,event)
		local touch1 = sender:getTouchBeganPosition()
		local touch3 = sender:getTouchMovePosition()
		local difx = touch3.x - touch1.x

		if cuoPaiSceneHasRemoved == false then
			if touch3.x ~= 0 and difx > 0 then
				testTme = testTme + difx/900
				if cuopaiIndex == 1 then
					card_3:rotateTo(0,-9 + testTme)
					if testTme > CardRotateAngle*0.6 then
						cuopaiIndex = 2
					end
				elseif cuopaiIndex == 2 then
					card_2:rotateTo(0,-9 + testTme)
					card_3:rotateTo(0,-9 + 2* testTme)
					if testTme  > CardRotateAngle then
						cuoPaiSceneHasRemoved = true
					end
				end

				-- testTme = testTme + difx/900
				-- card_2:rotateTo(0,-9 + testTme)
				-- card_3:rotateTo(0,-9 + 2* testTme)
				-- if testTme  > CardRotateAngle then
				-- 	cuoPaiSceneHasRemoved = true
				-- end
			end
		end
	end

    for i=1,backCardNum do
        local a =cuopai_plane:getChildByName("card_"..i)
        local cardUint = MY_CARDS[4-i]
        Card:setCuoCard(a,cardUint)
    end
    cuopai_plane:addTouchEventListener(CloseEvent)
end
function MenjiroomView:cpShow(flag)
	if FanSanPiPanel then
		local cp_green = FanSanPiPanel:getChildByName("base_foot"):getChildByName("cp_green")
		if cp_green then
			cp_green:setVisible(flag)
		end
	end

end

function MenjiroomView:showChipSum(isShow,chips)
  local chips_sum = FanSanPiPanel:getChildByName("chips_sum")
  local text_chips = chips_sum:getChildByName("text_chips")
  text_chips:setString("总下注:0")

  if isShow and chips then
  	text_chips:setString("总下注:"..chips/100)
  end

  chips_sum:setVisible(isShow)
end

return MenjiroomView