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

--local RoomlevelMap    =  import("zhajinhua_jb.pintu.RoomlevelMap")
local UiCommon        =  import("zhajinhua_jb.common.UiCommon")
local ZhajinHuaServer =  import("zhajinhua_jb.ZhajinHuaServer")
local LayerShuffling = require(TpackageName .. ".view.LayerShuffling")

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local schedulerEvents = {}
local MenjiroomView   = class("MenjiroomView", function()
	return display.newScene("MenjiroomView")
end)
local Card = require("zhajinhua_jb.common.PokerCard")
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
	PLAYER_HEADS_POSITION_TABLE = {}

	-- SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    -- SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
	collectgarbage("collect")
	print(collectgarbage("count"),"collectgarbage——ctor1")  --用于检测内存占用
	display.addSpriteFrames("zhajinhua_jb/res/common_texture.plist", "zhajinhua_jb/res/common_texture.png")
	display.addSpriteFrames("zhajinhua_jb/res/NewImg/card/Plist.plist", "zhajinhua_jb/res/NewImg/card/Plist.png")


	display.addSpriteFrames("zhajinhua_jb/res/room/animation/headWinNew.plist", "zhajinhua_jb/res/room/animation/headWinNew.png")

	display.addSpriteFrames("zhajinhua_jb/res/room/compareCard/winner.plist", "zhajinhua_jb/res/room/compareCard/winner.png")
	display.addSpriteFrames("zhajinhua_jb/res/room/compareCard/boom.plist", "zhajinhua_jb/res/room/compareCard/boom.png")
	display.addSpriteFrames("zhajinhua_jb/res/room/compareCard/allCompare.plist", "zhajinhua_jb/res/room/compareCard/allCompare.png")
	display.addSpriteFrames("zhajinhua_jb/layout/PokerCard/Plist.plist", "zhajinhua_jb/layout/PokerCard/Plist.png")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("zhajinhua_jb/layout/LayerShuffling/Plist.plist")--开局之后进入会来不急加载
	MenjiroomView.isHide = false
	local csbPath = "zhajinhua_jb/layout/room.csb"
	if device.platform == "ios" then
		if isiOSVerify then
			ZhaJinHuaPanel  = cc.CSLoader:createNode(csbPath):addTo(self)
		else
			ZhaJinHuaPanel   = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() ..csbPath):addTo(self)
		end
	else
		ZhaJinHuaPanel   = cc.CSLoader:createNode(csbPath):addTo(self)
	end
	ZhaJinHuaPanel:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH, SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
	GameUtils.setNodeNameBindObj(ZhaJinHuaPanel)
	require("zhajinhua_jb.view.CompareView"):initUI()
	ZhaJinHuaPanel:setName("ZhaJinHuaPanel")
	self:setGameSetting()
	cc.Director:getInstance():getTextureCache():removeUnusedTextures();
	print(collectgarbage("count"),"collectgarbage——ctor2")  --用于检测内存占用
	--ZhaJinHuaPanel:retain()
	bm.header_url=""
	bm.Room.iswith = false
	bm.Room.isover = false
	bm.Room.is_compare = true  --比牌回调后才可以点击其它事件
	bm.Room.msg_info=true
	
	--local bar    = ZhaJinHuaPanel:getChildByName("Image_2")
	--底部按键
	local base_foot=ZhaJinHuaPanel:getChildByName("base_foot")
	base_foot:setLocalZOrder(9999)
	base_foot:setVisible(false)

	--比牌
	local btn = base_foot:getChildByName("bi_green")
	if btn then
		btn:setOpacity(80)
		btn:setTouchEnabled(false)
		btn:addTouchEventListener(
			function(sender,event)

				--触摸结束
				if event == TOUCH_EVENT_ENDED then
					print("TOUCH_EVENT_ENDED bipai")
					if bm.Room.is_compare then
						 local peoplenum=0
						 local is_compare_uid
						 for uid,state in pairs(ZJH_USER_UID_PLAYING) do
						 	if state == 1 then
						 		if bm.User.isDiu[uid] == 0 or bm.User.isDiu[uid] == nil then
						 			peoplenum=peoplenum+1
						 			if uid ~= USER_INFO["uid"] then
						 				is_compare_uid=uid
						 			end
						 		end
						 	end
						 end
						 if peoplenum==2 then
						 	ZhajinHuaServer:CLI_BI_CARD(ZJH_USER_UID[is_compare_uid])
						 	MenjiroomView:clearBipai()
						 	MenjiroomView:moveChipList()
						 else
							MenjiroomView:clearBipai()
							MenjiroomView:biPai()
							MenjiroomView:moveChipList()
						 end
					end
				end
			end
		)
	end

	btn = base_foot:getChildByName("cp_green")
	btn:setVisible(false)
	btn:onClick(
	function(event)
		--触摸结束
		bm.Room.isCuoPai = true
		ZhajinHuaServer:CLI_SEE_CARD()
	end)

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
						ZhajinHuaServer.CLI_DIU_CARD()
						isDiscard=true
						MenjiroomView:clearBipai()
						MenjiroomView:moveChipList()
						-- require("zhajinhua_jb.view.CompareView"):showCampare(525,521,1)
					end
				end
			end
		)
	end

	--加注
	btn = base_foot:getChildByName("jia_green")
	if btn then
		btn:setOpacity(80)
		btn:setTouchEnabled(false)
		btn:addTouchEventListener(
			function(sender,event)

				--触摸结束
				if event == TOUCH_EVENT_ENDED then
					print("加注按钮")
					print(bm.Room.is_compare)
					if bm.Room.is_compare then
						MenjiroomView:showJiaZhuView()
						MenjiroomView:clearBipai()
					end
				end
			end
		)
	end

	--跟住
	btn = base_foot:getChildByName("gen_green")
	if btn then
		btn:setOpacity(80)
		btn:setTouchEnabled(false)
		btn:addTouchEventListener(
			function(sender,event)

				--触摸结束
				if event == TOUCH_EVENT_ENDED then
					print("跟注按钮")
					print(bm.Room.is_compare)
					if bm.Room.is_compare then
						ZhajinHuaServer.CLI_GEN_CARD()
						MenjiroomView:clearBipai()
						MenjiroomView:moveChipList()
					end
				end
			end
		)
	end

	--全押
	btn = base_foot:getChildByName("quan_green")
	if btn then
		btn:setOpacity(80)
		btn:setTouchEnabled(false)
		btn:addTouchEventListener(
			function(sender,event)

				--触摸结束
				if event == TOUCH_EVENT_ENDED then
					print("全押按钮")
					print(bm.Room.is_compare)
					if bm.Room.is_compare then
						if IS_ALLIN_CHIP > 0 then
							ZhajinHuaServer:CLI_BET_ALLIN(0)
						else
							MenjiroomView:showAllinNode()
						end

						MenjiroomView:clearBipai()
					end
				end
			end
		)
	end
	--视频录制
	local btn_record = ZhaJinHuaPanel:getChildByName("btn_record")
	btn_record:onClick(function(event)
		local game_round = 1
        if SCENENOW["scene"].GameRound and SCENENOW["scene"].GameRound > 2 then
            game_round = SCENENOW.scene.GameRound
        end
		ZhajinHuaServer:CLI_COMMAND_GAMERESULT_RECORD(game_round)
	end)
	
	local btn_msg=ZhaJinHuaPanel:getChildByName("btn_msg")
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
				--	ZhaJinHuaPanel:getChildByName("base_chip"):setVisible(true)
				--else
				--	bm.Room.msg_info=true
				--	ZhaJinHuaPanel:getChildByName("base_chip"):setVisible(false)
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
	-- ZhaJinHuaPanel:addChild(faceUI_node, 9999)
	self:addChild(faceUI_node, 9999)
	faceUI_node:setName("faceUI")
	
	local btn_chat = ZhaJinHuaPanel:getChildByName("btn_chat")
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
	local invite_ly = ZhaJinHuaPanel:getChildByName("invite_ly")
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
	local btnSetting   = ZhaJinHuaPanel:getChildByName("btn_settings")
	local ready_plane = ZhaJinHuaPanel:getChildByName("ready_plane")
	local btn_stand_up = nil
	local btn_sit_down = ZhaJinHuaPanel:getChildByName("btn_sit_down"):setVisible(false)
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

				ZhajinHuaServer:CLI_STAND_UP()

			end
			if sender == btn_sit_down then
				local seat_id = -1
				ZhajinHuaServer:CLI_SIT_DOWN(seat_id)
			end
			if sender == btn_ready then
				--bm.SchedulerPool:clearAll()
				--MenjiroomView:clearDesk()
				dump("btn_readyrr")
				MenjiroomView:readyRoom()
			end
			
			-- if sender == btn_buy then
			-- 	-- require("hall.BuyRoomCard.BuyRoomCardScene"):showScene(isNotShowBuyCard, 1)
			-- 	require("hall.GameTips"):showTips("提示", "", 2, "有玩家积分不足，已解散！")
			-- end
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
	
	self:showGroupInfo()

	--[[local node = display.newNode()
	node:addTo(self)
	node:setName("drawnode")]]
	ZhaJinHuaPanel:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
		if event.name == "began" then
			--[[local base_foot=ZhaJinHuaPanel:getChildByName("base_foot")
			local move2 = cc.MoveTo:create(0.2,cc.p(5.07,548.51))
			base_foot:runAction(move2)]]
		end
	end)
	local clock = ZhaJinHuaPanel:getChildByName("clock")
	local clock_txt = clock:getChildByName("text_center")
	clock_txt:stopAllActions()
	clock:setVisible(false)
	local lbVersion = ccui.Text:create()
	lbVersion:setString("1.0.10")
	lbVersion:setFontSize(18)
	lbVersion:setColor(cc.c3b(125, 125, 125))
	lbVersion:setPosition(cc.p(ZhaJinHuaPanel:getContentSize().width - lbVersion:getContentSize().width / 2, lbVersion:getContentSize().height / 2))
	ZhaJinHuaPanel:addChild(lbVersion, 9999)

	local chips_sum = ZhaJinHuaPanel:getChildByName("chips_sum")
	chips_sum:setVisible(false)

	local btn_startgame=ZhaJinHuaPanel:getChildByName("btn_startgame")
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
				ZhajinHuaServer:BROADCAST_START_GAME()
			end
		end)
		btn_startgame:setVisible(false)
	end
	
	self:setGuanZhanVisible(false)
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
    -- require("zhajinhua_jb.view.CompareView"):clearActions()
	-- require("zhajinhua_jb.view.CompareView"):showCampare()
	-- ChoiceCard:showPanel()
	-- require(TpackageName..".ChoiceCard"):init()

	-- print(ZhaJinHuaPanel:getScaleX())
	-- print(ZhaJinHuaPanel:getScaleY())
	-- print(1)
	local EmojiArmatureView = require("hall.EmojiArmatureView.EmojiArmatureView"):newEmojiArmatureView(self:getToSendFaceAndTxtFuncs(), self)

	ZhaJinHuaPanel.chip_node:hide()
	ZhaJinHuaPanel.allin_node:hide()
end
function MenjiroomView:reConnect()
	--SanGongSendHandle:LoginRoom(USER_INFO["tid"],USER_INFO["seat"],USER_INFO["activity_id"])
	require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function MenjiroomView:LoginRoom()
	local PROTOCOL = require("zhajinhua_jb.Zhajinhua_Protocol")
	local zjhHandle  = require("zhajinhua_jb.ZjhHandle")
	bm.server:setProtocol(PROTOCOL)
	bm.server:setHandle(zjhHandle.new())
	require("zhajinhua_jb.ZhajinHuaServer"):enterRoom()
	--require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
--function MenjiroomView:reConnect()
--	dump("MenjiroomScenes:reConnect")
--	require("zhajinhua_jb.ZhajinHuaServer"):enterRoom()
--end

function MenjiroomView:showShare(flag)
	local scenes  = ZhaJinHuaPanel
	local invite_ly = scenes:getChildByName("invite_ly")
	-- invite_ly:setLocalZOrder(9999999)
	local round = bm.Room.GroupInfo and tonumber(bm.Room.GroupInfo["round"]) or nil
	if round and round >= 1 and flag then
		-- flag = false
	end
	if g_isWatch == 0 then
        flag = false
    end
	invite_ly:setVisible(flag)
end

--观战标志可视设置
function MenjiroomView:setGuanZhanVisible(flag)
	local scenes  = ZhaJinHuaPanel
	local guanZhan_img = scenes:getChildByName("guanZhan_img")
	guanZhan_img:setVisible(flag)
end

function MenjiroomView:showstartgame(flag)
	local scenes  = ZhaJinHuaPanel
	local btn_startgame = scenes:getChildByName("btn_startgame")
	if btn_startgame then
		btn_startgame:setVisible(flag)
	end
end

function MenjiroomView:startGameTime(time)
    local scenes  = ZhaJinHuaPanel
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
        	tmp = cc.ProgressTimer:create(cc.Sprite:create("zhajinhua_jb/res/NewImg/clock_progress_dark.png"))
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
	local scenes  = ZhaJinHuaPanel
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
		--	tmp = cc.ProgressTimer:create(cc.Sprite:create("zhajinhua_jb/res/NewImg/clock_progress_dark.png"))
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
	local scenes  = ZhaJinHuaPanel
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
	local scenes  = ZhaJinHuaPanel
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
function MenjiroomView:drawUser(flag, index, strIco, uid, sex,nickName, ip, addres, userInfo)
	--新录音位置显示
	require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(uid, MenjiroomView:getHeadPos(index))

	local scenes  =ZhaJinHuaPanel

	--local scenes  = ZhaJinHuaPanel
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
			require("hall.GameCommon"):getUserHead(strIco, uid, sex, head, head:getContentSize().width , false, nickName, false, ip, addres)
			local planeItem_world_pos = (head:getParent()):convertToWorldSpace(head:getPosition())
			PLAYER_HEADS_POSITION_TABLE[uid] = planeItem_world_pos
			dump(userInfo.latitude,"33333333333333333")
			dump(userInfo.longitude,"33333333333333333")
			dump(uid,"33333333333333333")
			if not addres or addres == "" then
				ReqMgr:getAddress( userInfo.latitude, userInfo.longitude, uid, addres)
			end
		end
	else
		info:setVisible(false)
	end
end
-- 组局信息
function MenjiroomView:showGroupInfo()
	--组局显示邀请码
	local base_chip=ZhaJinHuaPanel:getChildByName("base_chip")
	local room_info=ZhaJinHuaPanel:getChildByName("room_info")
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

	local room_info=ZhaJinHuaPanel:getChildByName("room_info")
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
	--[[local txt_game_no = ZhaJinHuaPanel:getChildByName("p_game_no"):getChildByName("txt_game_no")

    if txt_game_no then
        txt_game_no:setVisible(true)
        txt_game_no:setString(tostring(curr_round+1).."/"..tostring(total_round))
    end]]
end

-- 设置底注
function MenjiroomView:setBaseChip(value)
	local p_base_chip = ZhaJinHuaPanel:getChildByName("base_chip")
	if p_base_chip then
		local txt_base_chip = p_base_chip:getChildByName("txt_chip")
		txt_base_chip:setString("底注："..tostring(value))
	end
end

--房间配置
function MenjiroomView:setGameConfig()
	local panel = ZhaJinHuaPanel:getChildByName("p_game_config")
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
		local panelGameno = ZhaJinHuaPanel:getChildByName("p_game_no")
		if panelGameno then
			panelGameno:setPositionX(480-backWith/2)
		end
		--调整底注位置
		local p_base_chip = ZhaJinHuaPanel:getChildByName("p_base_chip")
		if p_base_chip then
			p_base_chip:setPositionX(480+backWith/2)
		end
	end
end
--解散房间
function MenjiroomView:disbandGroup()
	local function send_disband()
		require("zhajinhua_jb.ZhajinHuaServer"):C2G_CMD_DISSOLVE_ROOM()
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
	self:drawUser(true,index, USER_INFO["icon_url"], USER_INFO["uid"], USER_INFO["sex"], USER_INFO.ip, USER_INFO.addres)
	
	local scenes = ZhaJinHuaPanel
	local node = scenes.player_plane:getChildByName("player_plane_1");
	local num = UiCommon:numFormat(bm.User.Gold)
	self:setGoldString(node, num)--设置金币数
	local nameStr = require("zhajinhua_jb.zjhSettings"):GetShortName(USER_INFO["nick"],9,6)
	self:setNickString(node, nameStr)--设置昵称
end
function MenjiroomView:settingsGold(uid,gold)
	local index=ZJH_PLAYERTYPE_TABLE[uid]
	if index == nil then
		print("error",debug.getinfo(1).currentline,debug.getinfo(1).name)
		return
	end
	local scenes  = ZhaJinHuaPanel
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
	local scenes  = ZhaJinHuaPanel
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
	local scenes  = ZhaJinHuaPanel
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
					local scenes  = ZhaJinHuaPanel
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
						MenjiroomView:clearDesk()
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
	local scenes  = ZhaJinHuaPanel
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

	if ZhaJinHuaPanel == nil then
		return
	end
	local ready_plane =ZhaJinHuaPanel:getChildByName("ready_plane")
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

	local scenes  = ZhaJinHuaPanel
	local btn_sit_down =scenes:getChildByName("btn_sit_down")
	if btn_sit_down then
		btn_sit_down:setVisible(flag)
	end
end
function MenjiroomView:showButtonAfterSitDown(flag)


end
--改变位置
function MenjiroomView:change_seat(maxpeople)
	-- local scenes = ZhaJinHuaPanel
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
	-- body
	local index   = MenjiroomView:getIndex(data.uid)

	if index == nil then
		print("error",debug.getinfo(1).currentline,debug.getinfo(1).name)
		return
	end
	ZJH_PLAYERTYPE_TABLE[data.uid] = index
	if data.uid == USER_INFO["uid"] then
		if g_isWatch == 1 then
			ZhaJinHuaPanel:getChildByName("btn_chat"):setVisible(true)
		else
			ZhaJinHuaPanel:getChildByName("btn_chat"):setVisible(false)
		end
		ZhaJinHuaPanel:getChildByName("btn_voice"):setVisible(false)
	end

	local scenes  = ZhaJinHuaPanel

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
				--finalChip = string.format("%.1f", finalChipTxt) .. "万"
			end
		end

		self:setGoldString(user_node, finalChip/100)
	end

	--昵称
	local nameStr = require("zhajinhua_jb.zjhSettings"):GetShortName(data["nickName"],9,6)
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
	local otherInfo = json.decode(data.otherInfo) or {}

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
	self:drawUser(true,index, data["photoUrl"], data.uid, data["sex"],data["nickName"], otherInfo.ip, otherInfo["addres"], data)
end


--获取用户序号
function MenjiroomView:getIndex(uid)
	--if uid == USER_INFO["uid"] then
	--	return 0
	--end
	if uid == nil then
		return nil
	end
	local other_seat  = ZJH_USER_UID[uid]
	if other_seat == nil then
		return nil
	end
	
	local num = 0 - MY_SEAT_ID
	if MY_SEAT_ID < 0 or MY_SEAT_ID == 0 then
		return other_seat
	else
		local viewId = (other_seat + num) % TOTAL_PLAYERNUM
		if other_seat + num == TOTAL_PLAYERNUM then
			return TOTAL_PLAYERNUM
		end
		return viewId
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
	
	return viewId

end

function MenjiroomView:removeReady(uid)
	local scenes  = ZhaJinHuaPanel
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

	local scenes = ZhaJinHuaPanel

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
	local scenes  = ZhaJinHuaPanel
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
	local scenes    = ZhaJinHuaPanel
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
	if tolua.isnull(ZhaJinHuaPanel) then
		return
	end
	local info_node = ZhaJinHuaPanel:getChildByName("room_info")
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
	local scenes  = ZhaJinHuaPanel
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
function MenjiroomView:sav_kanPai()
	bm.Room.isCuoPai =  false
	ZhajinHuaServer:CLI_SEE_CARD()
end

--获取头像世界坐标
function MenjiroomView:getHeadPos(index)
	local scenes  = ZhaJinHuaPanel
	local user_ = self:getUserNodeByIndex(index)
	local head = self:getHeadNode(user_)
	if head then
		return user_:convertToWorldSpace(head:getPosition())
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
function MenjiroomView:sendCard(callback)
	-- body
	local scenes  = ZhaJinHuaPanel
	local count = 0
	local distance_x=50
	MenjiroomView:clearCardNode()
	
	for index = 0, 9 do
		local user_node = self:getUserNodeByIndex(index)
		if user_node then
			self:setReadyVisible(user_node, false)--准备
		end
	end
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
	for j=0,2 do
		for i=0,9 do
			for k,v in pairs(ZJH_USER_UID) do
				if ZJH_USER_UID_PLAYING[k] == 1 then
					local index = ZJH_PLAYERTYPE_TABLE[k]
					if i == index then
						local card = require("zhajinhua_jb.common.PokerCard").new()
						local card_node = MenjiroomView:getCardPanel(k)
						if card_node ~= nil then

							card_node:getParent():show()
							local height = card.backBg_:getContentSize().height
							local width = card.backBg_:getContentSize().width
							local scale = card_node:getContentSize().height / height
							-- local size = ZhaJinHuaPanel:getContentSize()
							local size = cc.Director:getInstance():getWinSize()
							card:setScale(0.5)
							card:addTo(card_node)
							card:showBack()
							-- dump(ZhaJinHuaPanel:convertToNodeSpace(cc.p(size.width/2, size.height/2)))

							card:setPosition(card_node:convertToNodeSpace(cc.p(size.width/2, size.height/2)))
							card:setName("card"..j)
							width = width * scale
							if tonumber(k) == USER_INFO["uid"]then
								if bm.User.isDisplay == 1 then
									MenjiroomView:createKanPai(card_node)
									self:isKanButton(true)
									isKanBtn=true
								end
							end
							require("hall.GameCommon"):playEffectSound("zhajinhua_jb/res/audio/send_card.mp3")
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
	local time =count/10
	if callback then
		local handle = scheduler.performWithDelayGlobal(callback, time)
		table.insert(schedulerEvents, handle)
		--TimerHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, time, false)
	end

end
function MenjiroomView:isKanButton(falg)
	if not ZhaJinHuaPanel then return end
	-- if falg == true then
	-- 	dump()
	-- end
	self.btn_kan = self.players.player_plane_1.btn_kan
	self.btn_kan:setTouchEnabled(falg)
	self.btn_kan:setVisible(falg)
	MenjiroomView:cpShow(falg)
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
	for i = 0, 9 do
		local card_node = self:getPanelCardNodeByIndex(i)
		if card_node then
			card_node:removeAllChildren()
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
		for k, v in ipairs(v_cards) do
			local card = card_node:getChildByName("card"..tostring(k-1))
			if card then
				card:setCard(v[1])
			end
		end
	end

end

--获得用户的节点
function MenjiroomView:getIndexNode(index)

	if index == nil then
		return nil
	end

	local scenes    = ZhaJinHuaPanel
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
	dump(TOTAL_PLAYERNUM)
	if ZhaJinHuaPanel == nil then
		return nil
	end
	local user_node = self.players:getChildByName("player_plane_"..index + 1)
	if user_node == nil then
		return nil
	end
	return user_node
end

-- function MenjiroomView:getPanelCardsNode()
-- 	return ZhaJinHuaPanel:getChildByName("panel_card")	
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
	local scenes  = ZhaJinHuaPanel
	print("showQipai", tostring(uid))
	--local index = ZJH_PLAYERTYPE_TABLE[uid]
	--if index == nil then
	--	return
	--end
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
			qi_green:setOpacity(80)
			qi_green:setTouchEnabled(false)
		end
		self:isKanButton(false)
	end
	--弃牌
	local state = self:getStateNode(user_node)
	state:loadTexture("zhajinhua_jb/res/newroom/icon_1.png") --已弃牌
    state:ignoreContentAdaptWithSize(true)
	state:show()
end


--显示看牌
function MenjiroomView:showKanpai(uid)
	local scenes  = ZhaJinHuaPanel
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end
	local card_node = MenjiroomView:getCardPanel(uid)
	if card_node == nil then
		return
	end
	if uid == USER_INFO["uid"] then
		self:isKanButton(false)
		return
	end
	local state = self:getStateNode(user_node)
	state:loadTexture("zhajinhua_jb/res/newroom/icon_3.png") --已看牌
    state:ignoreContentAdaptWithSize(true)
	state:show()
end

function MenjiroomView:showCardType(type)

	local card_node = self:getUserNodeByIndex(0)
	local card_type = card_node:getChildByName("card_type")
	if card_type~=nil then
		card_type:loadTexture("zhajinhua_jb/res/NewImg/"..type..".png")
		card_type:ignoreContentAdaptWithSize(true)
		card_type:show()
		SoundUtils:playCardKindEffectType(type)
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
function MenjiroomView:showCard(uid, cards)

	local scenes  = ZhaJinHuaPanel
	local card_node = MenjiroomView:getCardPanel(uid)
	if card_node == nil then
		return
	end
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end
	
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
	for k,v in pairs(bm.Room.zhus) do
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

	local scenes    = ZhaJinHuaPanel
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

	require("hall.GameCommon"):playEffectSound("zhajinhua_jb/res/audio/sound_jinbi.mp3")
end


--玩家扔出alllin
function MenjiroomView:diuChipsAllin(uid,gold)

	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end

	local chip = ccui.ImageView:create("zhajinhua_jb/res/newroom/chouma_01.png")
	chip:setName("allin_gold")
	local ttfConfig = {}
	ttfConfig.fontFilePath = "zhajinhua_jb/res/fonts/fzcy.ttf"
	ttfConfig.fontSize = 38
	local gold_text = cc.Label:createWithTTF(ttfConfig, gold)
	gold_text:setTextColor(cc.c3b(61,0,64));
	chip:addChild(gold_text)
	chip:setContentSize(cc.size(120, 120))
	gold_text:setPosition(120 / 2, 120 / 2)
	chip:ignoreContentAdaptWithSize(false)
	chip:addTo(ZhaJinHuaPanel)


	local size = ZhaJinHuaPanel:getContentSize()
	local x = size.width/2
	local y = size.height/2
	local rand_x = math.random(x-200,x+200)
	local rand_y = math.random(y-60,y+60)

	chip:setPosition(user_node:getPosition())

	table.insert(bm.Room.chips, chip)

	local move = cc.MoveTo:create(0.1,cc.p(rand_x,rand_y))
	chip:runAction(move)

	require("hall.GameCommon"):playEffectSound("zhajinhua_jb/res/audio/sound_jinbi.mp3")
end


--隐藏金币筹码相关
function MenjiroomView:showChipsNowZhu(flag)
	local scenes    = ZhaJinHuaPanel

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
function MenjiroomView:showRoomButton(uid, can_compare, allin_flag)
	-- body
	local scenes  = ZhaJinHuaPanel
	if ZhaJinHuaPanel == nil then
		return
	end
	local isQi   = false
	local isKan  = false
	local isBi   = true
	local isGen  = false
	local isJia  = false
	local isShowAllin = false  -- 是否显示火拼
	local isAllin = allin_flag or 0
	if bm.User.isKan[uid] == nil then
		isKan = true
	end
	if bm.User.isDiu[USER_INFO["uid"]] == nil and  ZJH_USER_UID_PLAYING[USER_INFO["uid"]] == 1 then
		isQi  = true
	end
	-- 全押不能弃牌
	--if ZJH_TABLE_CHIPS[USER_INFO["uid"]] and ZJH_TABLE_CHIPS[USER_INFO["uid"]] >= bm.Room.init_chips then
	--	isQi = false
	--end

	local min_pk = bm.Room.min_pk or 3
	local min_allin = bm.Room.min_allin or 3


	if bm.Room.now_turns <= min_pk or tonumber(uid) ~= USER_INFO["uid"] then
		isBi = false
	end
	if can_compare and can_compare == 1 and tonumber(uid) == USER_INFO["uid"] then
		isBi = true
	end

	local tempMinBetChips = ALLIN_CHIPS[1] or nil

	if bm.Room.now_turns >= min_allin and tonumber(uid) == USER_INFO["uid"]  then
		if tempMinBetChips and tempMinBetChips <= ZJH_USER_TOTAL_CHIPS[uid] then
			isShowAllin = true
		end
	end
 
	-- 当玩家分数不够时，只能弃牌或全押
	if tonumber(uid) == USER_INFO["uid"] then
		local zhu  = bm.Room.now_zhu

		if bm.User.isKan[USER_INFO["uid"]]  ~= nil then
			zhu = zhu * 2
		end
		if (bm.Room.init_chips -  zhu) <= 0 then
			isAllin = 1
		end
	end

	-- allin不能比牌
	if isAllin == 1 then
		isBi = false
	--		local effect_all=scenes:getChildByName("effect_all");
	--		if effect_all then
	--			effect_all:setLocalZOrder(10)
	--			effect_all:setVisible(true)
	--		end
		if tonumber(uid) ~= USER_INFO["uid"] then
			isShowAllin = false
		else
			isShowAllin = true
		end
	end

	if uid == USER_INFO["uid"] and isAllin == 0 then
		isGen = true
		isJia = true
	end


	local base_foot=scenes:getChildByName("base_foot")
	base_foot:setVisible(uid == USER_INFO["uid"])
	if uid == USER_INFO.uid then
		dump()
	end
	if IS_ALLIN_CHIP >0 then
		isGen = false
		isJia = false
		isBi = false
	end
	--弃牌
	local qi_green = base_foot:getChildByName("qi_green")
	if isQi then
		qi_green:setOpacity(255)
		qi_green:setVisible(true)
		qi_green:setTouchEnabled(true)
	else
		qi_green:setOpacity(80)
		qi_green:setTouchEnabled(false)
	end

	--比牌
	local bi_green = base_foot:getChildByName("bi_green")
	if isBi then
		bi_green:setOpacity(255)
		bi_green:setVisible(true)
		bi_green:setTouchEnabled(true)
	else
		bi_green:setTouchEnabled(false)
		bi_green:setOpacity(80)
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

	--加注
	local jia_green = base_foot:getChildByName("jia_green")
	if isJia then
		jia_green:setOpacity(255)
		jia_green:setVisible(true)
		jia_green:setTouchEnabled(true)
	else
		jia_green:setTouchEnabled(false)
		jia_green:setOpacity(80)
	end
	
	local cp_green = base_foot:getChildByName("cp_green")
	cp_green.pos = cp_green:getPosition()
	--全押
	local btn_allin = base_foot:getChildByName("quan_green")
	if IS_ALLIN == 1 and countUserAllin == 1 then
		cp_green:setPosition(cp_green.pos)
		if btn_allin then
			if isShowAllin then
				btn_allin:setOpacity(255)
				btn_allin:setVisible(true)
				btn_allin:setTouchEnabled(true)

			else
				btn_allin:setTouchEnabled(false)
				btn_allin:setOpacity(80)
			end
		end
	else
		btn_allin:hide()
		cp_green:setPosition(btn_allin:getPosition())
	end



end

-- 重置按钮
function MenjiroomView:resetOperate(flag)
	if ZhaJinHuaPanel == nil then
		return
	end
	MenjiroomView:cpShow(false)
	local scenes  = ZhaJinHuaPanel:getChildByName("base_foot")
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

-- 重置房间
function MenjiroomView:resetGame()
	for k , v in pairs(ZJH_USERINFO_TABLE) do
		if ZJH_USER_ONLINE[k] and ZJH_USER_ONLINE[k] == 1 and ZJH_USER_UID_PLAYING[k] ==1 then
			MenjiroomView:showNowZhu(k,0)
		elseif ZJH_USER_ONLINE[k] and ZJH_USER_ONLINE[k] == 0 and bm.Room.iswith == false then
			--MenjiroomView:removeUserInfo(k)
		end
	end
	local info_node = ZhaJinHuaPanel:getChildByName("room_info")
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

	local scenes  = ZhaJinHuaPanel
	scenes:removeNodeEventListener(cc.NODE_TOUCH_EVENT)
	local node_t = scenes:getChildByName("chip_node")
	if node_t == nil then
		return
	end
	node_t:setVisible(true)
	scenes:getChildByName("chip_panel"):setVisible(true)
	node_t:setLocalZOrder(99999)
	local cBet = bm.Room.now_zhu
	if bm.User.isKan[USER_INFO["uid"]] ~= nil then
		cBet = cBet * 2
	end
	print("showJiaZhuView", tostring(cBet), tostring(bm.User.isKan[USER_INFO["uid"]]))
	local i      = 0
--	bm.Room.zhus={}
--	bm.Room.zhus[1] = 10000
--	bm.Room.zhus[2] = 100000
--	bm.Room.zhus[3] = 1000000
--	bm.Room.zhus[4] = 10000000
	bm.Room.chip_v=0
	for k,v in pairs(bm.Room.zhus) do
		local chip_btn=node_t:getChildByName("chip_btn"..k)
		local value_bet = 0
		if bm.User.isKan[USER_INFO["uid"]] ~= nil then
			value_bet = v*2
		else
			value_bet = v
		end
		local chipNum = UiCommon:getChipsNum(value_bet/100)
		if #chipNum == 5 then
			chip_btn.txt:setScale(0.7)
		elseif #chipNum == 4 then
			chip_btn.txt:setScale(0.8)
		elseif #chipNum == 3 then
			chip_btn.txt:setScale(0.9)
		else
			chip_btn.txt:setScale(0.9)
		end
		chip_btn.txt:setString(chipNum)

		if chip_btn then
			local size = chip_btn:getContentSize()
			chip_btn:setScale(1)
			chip_btn:onClick(
				function(event)
					--触摸结束
						value_bet = value_bet 
						bm.Room.chip_v = value_bet;
						print("加注", tostring(value_bet))
						ZhajinHuaServer:CLI_JIA_CARD(value_bet)
						--[[local move = cc.MoveTo:create(0.2,cc.p(1200,100))
			            node_t:runAction(move)]]
						MenjiroomView:moveChipList()
					end
			)
			if cBet > 0 then
				if value_bet < cBet then
					chip_btn:setTouchEnabled(false)
					chip_btn:setOpacity(70)
				else
					chip_btn:setTouchEnabled(true)
					chip_btn:setOpacity(255)
				end
			end
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

--显示加注
function MenjiroomView:showAllinNode()
	-- body

	local scenes  = ZhaJinHuaPanel
	scenes:removeNodeEventListener(cc.NODE_TOUCH_EVENT)
	local node_t = scenes:getChildByName("allin_node")
	if node_t == nil then
		return
	end
	node_t:setVisible(true)
	scenes:getChildByName("chip_panel"):setVisible(true)
	node_t:setLocalZOrder(99999)
--    ALLIN_CHIPS={}
--    if bm.User.isKan[USER_INFO["uid"]] ~= nil  then
--        ALLIN_CHIPS[1] = 60
--        ALLIN_CHIPS[2] = 100
--        ALLIN_CHIPS[3] = 160
--    else
--        ALLIN_CHIPS[1] = 30
--        ALLIN_CHIPS[2] = 50
--        ALLIN_CHIPS[3] = 80
--
--    end

	dump(ALLIN_CHIPS,"quan_green")
	for k,v in pairs(ALLIN_CHIPS) do
		local chip_btn=node_t:getChildByName("chip_btn"..k)
		
        local v_chip = v;
		
        if bm.User.isKan[USER_INFO["uid"]] ~= nil then
            v_chip = v_chip*2
        end
		local chipNum = UiCommon:getChipsNum(v_chip/100)
		if #chipNum == 5 then
			chip_btn.txt:setScale(0.7)
		elseif #chipNum == 4 then
			chip_btn.txt:setScale(0.8)
		elseif #chipNum == 3 then
			chip_btn.txt:setScale(0.9)
		else
			chip_btn.txt:setScale(0.9)
		end
		chip_btn.txt:setString(chipNum)

		--end
		if chip_btn then
			local size = chip_btn:getContentSize()
            chip_btn:setOpacity(255)
			chip_btn:setScale(1)
			chip_btn:onClick(
				function(event)
					--触摸结束
						print("全压", tostring(k))
						ZhajinHuaServer:CLI_BET_ALLIN(k)
						--[[local move = cc.MoveTo:create(0.2,cc.p(1200,100))
			            node_t:runAction(move)]]
						MenjiroomView:moveChipList()
				end
			)
			if v_chip >=  ZJH_USER_TOTAL_CHIPS[USER_INFO.uid] then
				chip_btn:setTouchEnabled(false)
			else
				chip_btn:setTouchEnabled(true)
			end
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
	local scenes  = ZhaJinHuaPanel
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

--比牌
function MenjiroomView:biPai()

	print("MenjiroomView:biPai")

	for k,v in pairs(ZJH_USER_UID) do
		local uid = tonumber(k)
		if uid ~= USER_INFO["uid"]  and  bm.User.isDiu[uid] ~= 1 and ZJH_USER_UID_PLAYING[uid] ==1 then
			local user_node  = MenjiroomView:getUserNode(uid)
			if user_node then
				user_node:setTouchEnabled(true)
				local kuang_node = self:getEffect_frame(user_node)
				kuang_node:show()
				--local kuang_node  = ccui.Button:create("zhajinhua_jb/res/NewImg/grab_effect_2.png", nil, nil)
				-- local kuang_node  = ccui.Button:create("zhajinhua_jb/res/room/head_choose.png", nil, nil)
				-- kuang_node:setScale(1.7)
				-- local kuang = display.newSprite("zhajinhua_jb/res/room/head_choose.png")
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
				-- kuang:addTo(kuang_node)
				-- kuang:setName("kuang_select")
				-- kuang:setPosition(kuang_node:getContentSize().width/2, kuang_node:getContentSize().height/2)
				-- kuang_node:addTo(user_node,10)
				-- kuang_node:setLocalZOrder(10)
				-- kuang_node:setContentSize(kuang:getContentSize())
				-- kuang_node:setName("kuang_node")
				-- local i     = 0
				-- local index = ZJH_PLAYERTYPE_TABLE[uid]
				-- kuang_node:setPosition(user_node:getContentSize().width/2, user_node:getContentSize().height/2+6)

				-- local jiantou = nil
				-- if TOTAL_PLAYERNUM == 5 then
				-- 	if index == 1 or index == 3 then
				-- 		jiantou = display.newSprite("zhajinhua_jb/res/room/headBox/arrow2.png")
				-- 		jiantou:setPosition(kuang_node:getContentSize().width/2 + 60 + jiantou:getContentSize().width/2, kuang_node:getContentSize().height/2)
				-- 	else
				-- 		jiantou = display.newSprite("zhajinhua_jb/res/room/headBox/arrow1.png")
				-- 		jiantou:setPosition(-(kuang_node:getContentSize().width/2 + 60 - jiantou:getContentSize().width), kuang_node:getContentSize().height/2)
				-- 	end
				-- else
				-- 	if index == 1 or index == 2 or index == 3 or index == 4 then
				-- 		jiantou = display.newSprite("zhajinhua_jb/res/room/headBox/arrow2.png")
				-- 		jiantou:setPosition(kuang_node:getContentSize().width/2 + 60 + jiantou:getContentSize().width/2, kuang_node:getContentSize().height/2)
				-- 	else
				-- 		jiantou = display.newSprite("zhajinhua_jb/res/room/headBox/arrow1.png")
				-- 		jiantou:setPosition(-(kuang_node:getContentSize().width/2 + 60 - jiantou:getContentSize().width), kuang_node:getContentSize().height/2)
				-- 	end
				-- end


				-- jiantou:addTo(kuang_node,6)
				-- jiantou:setScale(0.6)
				local seat = ZJH_USER_UID[uid]
				kuang_node:onClick(function (event)
					kuang_node:setLocalZOrder(1)
					print("CLI_BI_CARD", tostring(seat), tostring(uid))
					ZhajinHuaServer:CLI_BI_CARD(seat)
					-- kuang:removeSelf()
					MenjiroomView:clearBipai()
				end)
			end
		end
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
	if ZhaJinHuaPanel then
		local zhezhao = ZhaJinHuaPanel:getChildByName("zhezhao")
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
	local scenes  = ZhaJinHuaPanel
	print("scenes==",scenes)
	if scenes == nil then
		return
	end
	local effect = display.newSprite("#allCompare1.png")
	local frames = display.newFrames("allCompare%d.png", 1, 13)
	if frames == nil then
		display.addSpriteFrames("zhajinhua_jb/res/room/compareCard/allCompare.plist", "zhajinhua_jb/res/room/compareCard/allCompare.png")
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
	require("zhajinhua_jb.view.CompareView"):clearActions()
	--for k,v in pairs(ZJH_USER_UID) do
	--	ZJH_USER_UID_PLAYING[k] = 0;
	--end
	local win_uid = nil
	dump(pack.userinfos,"pack.userinfos")
	LayerShuffling:removeScene()
	for k,v in pairs(pack.userinfos) do
		if v.turngold > 0 then
			win_uid = v.uid
		end

		local cards = nil
		local card_type=nil


		if ZJH_IS_SHOW_ALLCARDS then
			if v.compare_content ~= nil then
				cards = MenjiroomView:sortOrder(v.compare_content[1]['cards'])

				MenjiroomView:setCards(v.uid, cards)
				MenjiroomView:showCard(v.uid)
			end	
		else
			if v.iscompare == 1 or v.uid == USER_INFO["uid"] then
				if v.compare_content ~= nil then
					cards = MenjiroomView:sortOrder(v.compare_content[1]['cards'])

					MenjiroomView:setCards(v.uid, cards)
					MenjiroomView:showCard(v.uid)
				end
			end
		end
	end
    if win_uid == nil then
        require("hall.GameTips"):showTips("提示", "", 3, "结算之后赢的筹码不能为零！")
    end
	local function callback()
		MenjiroomView:addResult(pack)

		if ZJH_USER_UID[USER_INFO["uid"]] >=0 then
			MenjiroomView:showControlButtons(true)
		else
			if GROUP_MODE == 2 then
				MenjiroomView:showSitDownButton(true)
			end

		end

		-- 移除桌面动画
		MenjiroomView:clearBipai()
		print("clearBipai")
		MenjiroomView:showChipsNowZhu(false)
		print("showChipsNowZhu")
		MenjiroomView:clearCardNode()
		print("clearCardNode")
		MenjiroomView:hideCardType()
		print("hideCardType")
		MenjiroomView:relocatePlayer()
		print("relocatePlayer")
		-- 重置房间
		collectgarbage("collect")
	end
	MenjiroomView:recycleChips(win_uid, pack,callback)
end

function MenjiroomView:relocatePlayer()
	dump(ZJH_USER_UID,"relocatePlayer")
	self:resetUserInfo()
	for  uid,seat in pairs(ZJH_USER_UID) do
		if seat >= 0 then
			local userInfo =  ZJH_USERINFO_TABLE[uid]
			MenjiroomView:showUserInfo(userInfo)
		end
	end
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
	local scenes  = ZhaJinHuaPanel
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
			ttfConfig.fontFilePath = "zhajinhua_jb/res/fonts/fzcy.ttf"
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
			head = display.newSprite("zhajinhua_jb/res/login/female_head.png")
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
				--require("zhajinhua_jb.zjhSettings"):setPlayerHead(head_info,head,45)

		end
		local index_v = 0
		local card_class = panel_item:getChildByName("card_class")
		card_class:removeAllChildren()
		for i = 1,3 do
			local card = require("zhajinhua_jb.common.PokerCard").new()
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


--结算排行榜
function MenjiroomView:onNetRanking(pack)
	local scenes  = ZhaJinHuaPanel
	local winColor = cc.c3b(0xFF,0xFF,0x00)
	local loseColor =  cc.c3b(0xFF,0x00,0x00)
	--去掉提示弹框
	local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
	if layer_tips then
		layer_tips:removeSelf()
	end

	ZJHGroupEndPanel= cc.CSLoader:createNode("zhajinhua_jb/layout/GroupEnding.csb")
	if device.platform == "ios" then
		if isiOSVerify then
			ZJHGroupEndPanel= cc.CSLoader:createNode("zhajinhua_jb/layout/GroupEnding.csb")
		else
			ZJHGroupEndPanel= cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .."zhajinhua_jb/layout/GroupEnding.csb")
		end
	else
		ZJHGroupEndPanel= cc.CSLoader:createNode("zhajinhua_jb/layout/GroupEnding.csb")
	end
	scenes:addChild(ZJHGroupEndPanel,99999)

	--if bm.Room.isover == true then
	if bm.Room.all_compare and bm.Room.all_compare == 1 then
		ZJHGroupEndPanel:setVisible(false)
	end
	--end
	--ZJHGroupEndPanel:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
	print("bm.Room.isover",bm.Room.isover)
	-- local btn_exit=ZJHGroupEndPanel:getChildByName("btn_exit")
	-- btn_exit:setVisible(false)
	local share_btn=ZJHGroupEndPanel:getChildByName("btn_share")
	share_btn:onClick(handler(self, self.onClick_share_btn))
	
    local content_sv = ZJHGroupEndPanel:getChildByName("content_sv")
    local contentWidth = content_sv:getInnerContainerSize().width
    local contentHeight = content_sv:getInnerContainerSize().height

    local single_result_Item_width = contentWidth/6
    local single_result_Item_height = contentHeight/8

    local room_id = ZJHGroupEndPanel:getChildByName("room_id")
    room_id:setString(USER_INFO["invote_code"])

    local time_txt = ZJHGroupEndPanel:getChildByName("time_txt")
    time_txt:setString(os.date("%H:%M"))

    local round = ZJHGroupEndPanel:getChildByName("round")
    round:setString(pack.game_amount)

    local score = ZJHGroupEndPanel:getChildByName("score")

    --定义结果分项
    local result_Item = ZJHGroupEndPanel:getChildByName("group_ending_box")

    --显示用户结算结果
    local playerlist = pack.playerlist

    local fuhao_uid = nil
    local lastChip = 0

    dump(playerlist,"playerlist")
    for k,v in pairs(playerlist) do

        --获取用户id
        local uid = v.uid
        local chips
		if k == 1 then
			fuhao_uid = uid
		end
        ------------------------------------------------数据---------------------------------------
        chips = v.totalChips
        ---------------------------------------------------------------------------------------------
        if chips ~= nil then
            --比较分数
            if chips > lastChip then
                --记录最新点炮数和点炮id
                lastChip = chips
                fuhao_uid = uid
            end
        end
    end


    dump(fuhao_uid,"fuhao_uid")

    local result_Item_position_index = 1

    local playerNum =  #playerlist

    local lineCount = 4
    if playerNum > 10 then
        lineCount = math.ceil(playerNum/3)
        content_sv:setInnerContainerSize(cc.size(contentWidth,content_sv:getInnerContainerSize().height/4 * lineCount))
    end

    if playerNum > 0 then

        --生成界面
        for k,v in ipairs(playerlist) do

            ------------------------------------------数据-----------------------------------
            local uid = v.uid
            local photo_url
            local sex = v.sex
            local nick_name
            local chips

            photo_url = v.photoUrl
            nick_name = v.nickName
            chips  = v.totalChips
            -------------------------------------------界面-------------------------------------------

            local result_Item = result_Item:clone()
            content_sv:addChild(result_Item)

            local group_ending_winer = result_Item:getChildByName("group_ending_winer")

            if playerNum <= 10 then

                if  uid == fuhao_uid then
                    group_ending_winer:setVisible(true)
                    local x = 3 * single_result_Item_width
                    local y = 7 * single_result_Item_height
                    result_Item:setPosition(cc.p(x,y))
                else
                    group_ending_winer:setVisible(false)
                    local x = contentWidth / 2 - (2 - math.ceil(result_Item_position_index % 3.01)) * 400
                    dump(x,"游戏框位置"..k)
                    -- local x = (math.ceil(result_Item_position_index % 3.01) * 2 - 1) * single_result_Item_width
                    local y = (7 - math.ceil(result_Item_position_index/3.01)* 2) * single_result_Item_height

                    result_Item:setPosition(cc.p(x,y))
                    result_Item_position_index = result_Item_position_index + 1
                end

            else

                if  uid == fuhao_uid then
                    group_ending_winer:setVisible(true)
                else
                    group_ending_winer:setVisible(false)
                end

                local x = (math.ceil(result_Item_position_index % 3.01) * 2 - 1) * single_result_Item_width
                local y = ((lineCount*2 + 1) - math.ceil(result_Item_position_index/3.01)* 2) * single_result_Item_height
                result_Item_position_index = result_Item_position_index + 1
                result_Item:setPosition(cc.p(x,y))

            end

            --用户头像
            local head_im = result_Item:getChildByName("head_im")
            require("hall.GameCommon"):getUserHead(photo_url, uid, sex, head_im, head_im:getContentSize().width, false, nick_name)

            --用户昵称
            local nick_txt = result_Item:getChildByName("nick_txt")

            local namenick =  require("hall.GameCommon"):formatNick(nick_name, 7)


            nick_txt:setString(namenick)

            --用户id
            local id_txt = result_Item:getChildByName("id_txt")
            id_txt:setString("ID:" .. tostring(uid))

            local score_txt = result_Item:getChildByName("score_txt")

            if  chips >= 0 then
                score_txt:setTextColor(winColor)
            else
                score_txt:setTextColor(loseColor)
            end

            score_txt:setString(tostring(chips))

            if  uid == USER_INFO["uid"] then
                score:setString(tostring(chips))
            end

        end

    end
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
function MenjiroomView:addResult(pack)

	local scenes  = SCENENOW["scene"]
	-- local account = scenes:getChildByName("accountScene")
	-- if account then
	-- 	account:removeSelf()
	-- end
	-- if device.platform == "ios" then
	-- 	if isiOSVerify then
	-- 		account= cc.CSLoader:createNode("zhajinhua_jb/layout/new_account.csb")
	-- 	else
	-- 		account= cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .."zhajinhua_jb/layout/new_account.csb")
	-- 	end
	-- else
	-- 	account= cc.CSLoader:createNode("zhajinhua_jb/layout/new_account.csb")
	-- end
	-- account:addTo(scenes,999999)
	-- --account:retain()
	-- account:setName("accountScene")
	-- account:setVisible(false)
	-- account:setLocalZOrder(999999)
	-- account:setScale(0.6666666666666667)
	-- --if is_show_zjh_sing then
	-- --	local next_btn=scenes:getChildByName("next_btn")
	-- --	if next_btn then
	-- --		if pack then
	-- --			--next_btn:setVisible(true)
	-- --		end
	-- --	end
	-- --else
	-- MenjiroomView:drawGameoverList(pack,account)
	-- local back_close=account:getChildByName("single_panel"):getChildByName("back_close")
	-- self:_initRankeng(account:getChildByName("single_panel"))
	-- local btn_next=account:getChildByName("single_panel"):getChildByName("btn_next")
	-- local function touchButtonEvent (sender,event)
	-- 	--触摸开始
	-- 	if event == TOUCH_EVENT_BEGAN then
	-- 		sender:setScale(0.9)
	-- 	end

	-- 	--触摸取消
	-- 	if event == TOUCH_EVENT_CANCELED then
	-- 		sender:setScale(1.0)
	-- 	end
	-- 	--触摸结束
	-- 	if event == TOUCH_EVENT_ENDED then
	-- 		sender:setScale(1.0)
	-- 		if sender == back_close then
	-- 			if bm.Room.iswith == true then
	-- 				--if ZJHGroupEndPanel then
	-- 				--	JHGroupEndPanel:setVisible(true)
	-- 				--end

	-- 			end
	-- 			account:getChildByName("single_panel"):setVisible(false)
	-- 		elseif sender == btn_next then
	-- 			if bm.Room.iswith == true then
	-- 				--if ZJHGroupEndPanel then
	-- 				--	JHGroupEndPanel:setVisible(true)
	-- 				--end
	-- 			end
	-- 			btn_next:stopAllActions()
	-- 			account:getChildByName("single_panel"):setVisible(false)

	-- 		end

	-- 	end
	-- end
	-- btn_next:addTouchEventListener(touchButtonEvent)
	-- back_close:addTouchEventListener(touchButtonEvent)
	-- local function callback()
	-- 	if bm.Room.iswith == true then
	-- 		if ZJHGroupEndPanel then
	-- 			JHGroupEndPanel:setVisible(true)
	-- 		end
	-- 	end

	-- 	account:getChildByName("single_panel"):setVisible(false)

	-- end
	MenjiroomView:clearDesk()
	print("clearDesk")
	MenjiroomView:showShare(true)
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
				HEART_BEAT_TID = 0
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
    local scenes  = ZhaJinHuaPanel
	local user_node = MenjiroomView:getUserNode(uid)
	dump(user_node,"user_nodejjjj")
	if user_node == nil then
		print("recycleChips can't get user_node", tostring(uid))
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
	local time = 1
	local flag_callback =true
	local index_count = table.getn(bm.Room.chips)
	local chip_count = table.getn(bm.Room.chips)
	local time_init = 1.5 / chip_count
	dump(time_init,"time_init")
	-- local targetPos = scenes:convertToWorldSpace(self:getHeadNode(user_node):getPosition())
	--将head的坐标映射到世界坐标系中去
	local head = self:getHeadNode(user_node)
	local planeItem_world_pos = (head:getParent()):convertToWorldSpace(head:getPosition())
	local targetPos = scenes:convertToNodeSpaceAR(planeItem_world_pos)
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
			display.addSpriteFrames("zhajinhua_jb/res/room/animation/headWinNew.plist", "zhajinhua_jb/res/room/animation/headWinNew.png")
			frames = display.newFrames("headWinMine%d.png", 1, 10)
		end
	else

		light_kuang= display.newSprite("#headWin1.png")
		frames = display.newFrames("headWin%d.png", 1, 10)
		if frames == nil then
			display.addSpriteFrames("zhajinhua_jb/res/room/animation/headWinNew.plist", "zhajinhua_jb/res/room/animation/headWinNew.png")
			frames = display.newFrames("headWin%d.png", 1, 10)
		end
	end
	light_kuang:setScale(2)

	local animation = display.newAnimation(frames, 0.1)

	local function onComplete()
		local scenes = ZhaJinHuaPanel
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
	require("hall.GameCommon"):playEffectSound("zhajinhua_jb/res/audio/login_gold.mp3")

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
				score_txt:setFntFile("zhajinhua_jb/layout/player_plane/win_num.fnt")
			else
				str = tostring(tempScore)
				-- score_txt:setColor(cc.c3b(255,255,255))
				score_txt:setFntFile("zhajinhua_jb/layout/player_plane/lose_num.fnt")
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

	--bi_back   = display.newScale9Sprite("zhajinhua_jb/res/room/chatExpress/"..file,0,0,cc.size(rlen,90),cc.rect(20,10,220,50))
	--bi_back   = cc.Scale9Sprite:create("zhajinhua_jb/res/room/chatExpress/"..file,cc.rect(0, 0, rlen, 90),cc.rect(20,10,rlen,50))
	bi_back   = cc.Scale9Sprite:create("zhajinhua_jb/res/room/chatExpress/"..file)
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
	ttfConfig.fontFilePath = "zhajinhua_jb/res/fonts/fzcy.ttf"
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
	local scenes  = ZhaJinHuaPanel
	local effect_all=scenes:getChildByName("effect_all");
	if effect_all then
		effect_all:setLocalZOrder(10)
		effect_all:setVisible(true)
		-- PK光
		local pk_light = display.newSprite("zhajinhua_jb/res/room/compareCard/light01.png")
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
function  MenjiroomView:clearDesk()
	-- 重置轮数
	bm.Room.now_turns = 0
	MenjiroomView:showRounds()
	bm.Room.now_turns = 1
	isKanBtn=false
	for k,v in pairs(ZJH_USER_UID) do
		local user_node = MenjiroomView:getUserNode(k)
		if user_node then
			local gold_back = user_node:getChildByName("gold_back")
			-- if gold_back ~= nil then
				-- gold_back:removeSelf()
			-- end
		
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
	local scenes  = ZhaJinHuaPanel
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
    for k,v in pairs(bm.Room.chips) do
        if tolua.isnull(v) == false then
            v:removeSelf()
        end
    end
	bm.Room.chips     = {}
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

	local banker = display.newSprite("zhajinhua_jb/res/banker.png")
	banker:addTo(user_node, 100)
	banker:setPosition(cc.p(user_node:getContentSize().width - banker:getContentSize().width/2 + offset_x, user_node:getContentSize().height - banker:getContentSize().height/2))

	bm.Room.banker = banker
end
function MenjiroomView:showVoice()
	local scenes  = ZhaJinHuaPanel
     if scenes then
		 local btn_voice = scenes:getChildByName("btn_voice")
		 local voice_bt_worldpoint = (btn_voice:getParent()):convertToWorldSpace(btn_voice:getPosition())
		 local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
		 if  VoiceRecordView.addVoiceRecordEvent then
             btn_voice:setVisible(false)
			 VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
		 else
			 VoiceRecordView:showView(voice_bt_worldpoint.x,voice_bt_worldpoint.y,999)
		 end
		 btn_voice:setVisible(false)
	 end


end
function MenjiroomView:showNetwork(uid,flag)

	local scenes  = ZhaJinHuaPanel
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
	local scenes  = ZhaJinHuaPanel
	if scenes==nil  then
		return
	end
	local device_info_plane = scenes:getChildByName("device_info_plane")
	--device_info_plane:setVisible(false)
	require("hall.util.GameMenu"):getDeviceInfo(device_info_plane)
end
function MenjiroomView:readyRoom()
	ZhajinHuaServer:CLI_READYNOW_ROOM()

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
	local scenes  = ZhaJinHuaPanel
	if scenes==nil  then
		return
	end



	--添加扣除台费显示
	local taiFeiTxt =0
	if  chips < 0 then
		taiFeiTxt = "扣除台费"..math.abs(chips)
	end


	local lbVersion = cc.Label:createWithTTF(taiFeiTxt, "zhajinhua_jb/res/fonts/systemFont.TTF",30)
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
    if json["min_round_pk"] then
        str =  str.."PK:"..json["min_round_pk"].."轮以上PK"
         table.insert(USER_INFO["gameConfig"],{["PK"] = json["min_round_pk"].."轮以上PK"})
    end
    if json["min_round_allin"] then
        str = str .. " 血拼:"..json["min_round_allin"] .."轮以上血拼"
        table.insert(USER_INFO["gameConfig"],{["血拼"] = json["min_round_allin"].."轮以上血拼"})
    end
    if json["circleNeededToShowCards"] then
        str = str .. "  闷圈:"..json["circleNeededToShowCards"].."圈"
        table.insert(USER_INFO["gameConfig"],{["闷圈:闷"] = json["circleNeededToShowCards"].."圈"})
    end
    if json["max_round"] then
        str = str .. "手数:" .. json["max_round"].."轮封顶"
        table.insert(USER_INFO["gameConfig"],{["手数"] = json["max_round"].."轮封顶"})
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
	
	self.gameConfigTable = json
	if json.dis_agree and json.dis_agree == 3 then
        self:hideDisbandBtn()
    else
    	if self.moreFuncLayer and (not tolua.isnull(self.moreFuncLayer)) then
        	self.moreFuncLayer.btnDisbandRoom:setVisible(true)
        end
    end
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
	for k, v in ipairs(cards) do
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

	table.sort(cards, function (a,b)
		local acolor = MenjiroomView:getVariety(a)
		local avalue = MenjiroomView:getValue(a)
		local bcolor = MenjiroomView:getVariety(b)
		local bvalue = MenjiroomView:getValue(b)
		if avalue == bvalue then
			return acolor > bcolor
		else
			if avalue == 0 then
				return true
			elseif bvalue == 0 then
				return false
			end
			return avalue > bvalue
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
	ZhajinHuaServer:C2G_CMD_DISSOLVE_ROOM()
end

function MenjiroomView:rejectDisband()
	ZhajinHuaServer:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function MenjiroomView:agreeDisband()
	ZhajinHuaServer:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
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
		if self.gameConfigTable and self.gameConfigTable.dis_agree and self.gameConfigTable.dis_agree == 3 then
	        self:hideDisbandBtn()
	    else
        	self.moreFuncLayer.btnDisbandRoom:setVisible(true)
        end
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
    	if self.gameConfigTable and self.gameConfigTable.dis_agree and self.gameConfigTable.dis_agree == 3 then
	        self:hideDisbandBtn()
	    else
        	self.moreFuncLayer.btnDisbandRoom:setVisible(true)
        end
    end
	
	if g_isWatch == 0 then
        self.moreFuncLayer:set_btnDisbandRoom_visible(false)
    end
end

function MenjiroomView:hideDisbandBtn()
	if self.moreFuncLayer and (not tolua.isnull(self.moreFuncLayer)) then
    	self.moreFuncLayer.btnDisbandRoom:setVisible(false)
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
	ZhajinHuaServer.CLI_QUIT_ROOM()
end

function MenjiroomView:sendFaceByIdx(id, msgType, to_uid)
	print("sendFaceMsg --------------------------", id)
	ZhajinHuaServer:CLI_MSG_FACE(id, msgType, to_uid)
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
	print(type(ZhaJinHuaPanel))
	if ZhaJinHuaPanel then
		ZhaJinHuaPanel:stopAllActions()
		ZhaJinHuaPanel = nil
		print("ZhaJinHuaPanel:removeSelf")
		--ZhaJinHuaPanel:removeSelf()
	end
end
function MenjiroomView:onEnter()
	--cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1280, 720, cc.ResolutionPolicy.SHOW_ALL)
end
function MenjiroomView:_initRankeng(root)
	local fin_box = root:getChildByName("fin_box")
	--local bg = ZhaJinHuaPanel:getChildByName("room_bg")
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
	for index = 1, 10 do
		local user_node = self.players["player_plane_"..index]
		if user_node then
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
	end
	self:hideCardType()
	self:isKanButton(false)
	self.btn_kan:onClick(function (  )
		bm.Room.isCuoPai = false
		ZhajinHuaServer:CLI_SEE_CARD()
	end)
	
end

function MenjiroomView:init_player_plane(gameConfig)
	local childs = ZhaJinHuaPanel.player_plane:getChildren()
	if #childs >= 1 then
	else
		TOTAL_PLAYERNUM = gameConfig.maxSeatCount
		local csbPath = "zhajinhua_jb/layout/room_10.csb"
		if gameConfig.maxSeatCount <= 6 then
			csbPath = "zhajinhua_jb/layout/room_6.csb"
		elseif gameConfig.maxSeatCount <= 8 then
			csbPath = "zhajinhua_jb/layout/room_8.csb"
		elseif gameConfig.maxSeatCount <= 9 then
			csbPath = "zhajinhua_jb/layout/room_9.csb"
		end
		self.players = cc.CSLoader:createNode(csbPath):addTo(ZhaJinHuaPanel.player_plane)
		GameUtils.setNodeNameBindObj(self.players)
		self:initUI()
	end
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
	local  cuoPaiScene = ZhaJinHuaPanel:getChildByName("cuopai")
	if  not tolua.isnull(cuoPaiScene) then
		local cuopai_plane = cuoPaiScene:getChildByName("cuopai_plane")
		if not tolua.isnull(cuoPaiScene) then
			cuoPaiScene:removeFromParent()
		end
	end

end

function MenjiroomView:cuopaiTest(cards)
	local func = function (  )
		MenjiroomView:setCards()
		MenjiroomView:showCardType(bm.User.card_type)
	end
	LayerShuffling.new(cards[#cards], func)
end

function MenjiroomView:cpShow(flag)
	if ZhaJinHuaPanel then
		local traceback = string.split(debug.traceback("", 2), "\n")
		dump(traceback)
		dump(flag, "-------asdfasdfasdf")

		local cp_green = ZhaJinHuaPanel:getChildByName("base_foot"):getChildByName("cp_green")
		if cp_green then
			if flag == false then
			end
			cp_green:setVisible(flag)
		end
	end

end

function MenjiroomView:showChipSum(isShow,chips)
  local chips_sum = ZhaJinHuaPanel:getChildByName("chips_sum")
  local text_chips = chips_sum:getChildByName("text_chips")
  text_chips:setString("总下注:0")

  if isShow and chips then
  	text_chips:setString("总下注:"..chips/100)
  end

  chips_sum:setVisible(isShow)
end

return MenjiroomView