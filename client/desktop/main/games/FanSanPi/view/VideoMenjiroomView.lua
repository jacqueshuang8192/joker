--[[
* author:   zwm
* date:     2020-11-17
* describe: 翻三皮战绩回放场景
* explain:  
--]]

local UiCommon        =  import("FanSanPi.common.UiCommon")
local MenjiroomServer =  import("FanSanPi.FanSanPiServer")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local schedulerEvents = {}
local RecordBaseScene = require("hall.record.RecordBaseScene")
local MenjiroomView = class("MenjiroomView", RecordBaseScene)
-- local MenjiroomView   = class("MenjiroomView", function()
-- 	return display.newScene("MenjiroomView")
-- end)
local Card = require("FanSanPi.common.PokerCard")
local SoundUtils = import("FanSanPi.SoundUtils")
-- local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local headSize = 62
local user_node_y = 182.67
local card_panel_y = 152.33

local TOTAL_PLAYERNUM = 6

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

function MenjiroomView:ctor(data, level)
	MenjiroomView.super.ctor(self, data, {}, level, true)
	self._data = data
	local tableData = json.decode(data)
	self._baseChip = tableData.base
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

	DESIGN_SCREEN_WIDTH  = 1920
    DESIGN_SCREEN_HEIGHT = 1080
    SCREEN_WIDTH = 1280  --屏幕尺寸
    SCREEN_HEIGHT = 720
    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
	FanSanPiPanel:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH, SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
	GameUtils.setNodeNameBindObj(FanSanPiPanel)
	self:initUI()
	FanSanPiPanel:setName("FanSanPiPanel")
	-- self:setGameSetting()
	cc.Director:getInstance():getTextureCache():removeUnusedTextures();
	print(collectgarbage("count"),"collectgarbage——ctor2")  --用于检测内存占用


	PLAYER_HEADS_TABLE = {}
	PLAYER_HEADS_POSITION_TABLE = {}
	ZJH_USER_UID = {}
	ZJH_PLAYERTYPE_TABLE = {}
	ZJH_USER_UID_PLAYING = {}
	FSP_USER_UID_CARDS = {}
	ZJH_USER_TOTAL_CHIPS = {}
	self._betScore = {}
	self._fristBet = true
	self._totalBetScore = 0
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
	btn:setVisible(false)

	--加注
	local jia_green = base_foot:getChildByName("jia_green")
	jia_green:setVisible(false)

	--跟住
	local gen_green = base_foot:getChildByName("gen_green")
	gen_green:setVisible(false)

	--全押
	local quan_green = base_foot:getChildByName("quan_green")
	quan_green:setVisible(false)

	--秀牌
	local showCardGreen = FanSanPiPanel:getChildByName("showCardGreen")
	showCardGreen:setVisible(false)
	
	local btn_record = FanSanPiPanel:getChildByName("btn_record")
	btn_record:setVisible(false)

	local btn_auto_play = FanSanPiPanel:getChildByName("btn_auto_play")
	btn_auto_play:setVisible(false)

	local btn_voice = FanSanPiPanel:getChildByName("btn_voice")
	btn_voice:setVisible(false)

	local btn_msg=FanSanPiPanel:getChildByName("btn_msg")
	btn_msg:setVisible(false)
	
	local btn_chat = FanSanPiPanel:getChildByName("btn_chat")
    btn_chat:setVisible(false)
	--邀请好友
	--邀请微信好友
	local invite_ly = FanSanPiPanel:getChildByName("invite_ly")
	invite_ly:setVisible(false)

	local device_info_plane = FanSanPiPanel:getChildByName("device_info_plane")
	device_info_plane:setVisible(false)

	
	local btnSetting   = FanSanPiPanel:getChildByName("btn_settings")
	local ready_plane = FanSanPiPanel:getChildByName("ready_plane")
	local btn_stand_up = nil
	local btn_sit_down = FanSanPiPanel:getChildByName("btn_sit_down"):setVisible(false)
	local btn_ready = nil
	if ready_plane then
		ready_plane:setVisible(false)
	end
	if btnSetting then
		btnSetting:setVisible(false)
	end
	
	
	self:isKanButton(false)
	if self.btn_kan then
		self.btn_kan:setVisible(false)
	end
	self:showGroupInfo()

	-- self:resetUserInfo()

	local clock = FanSanPiPanel:getChildByName("clock")
	local clock_txt = clock:getChildByName("text_center")
	clock_txt:stopAllActions()
	clock:setVisible(false)
	
	self:setGuanZhanVisible(false)

	self:setChipsSumVisible(false)
	self:setPiaoOptBtnVisible(false)
	self:bindMsgProc()
	self:loadVideoLayer()
	self:initVideoScene()
	
end

function MenjiroomView:bindMsgProc()
    self.func_ = {
    	--玩家跟注
    	[24610] = {handler(self, self.procUserGenBet)},
        --玩家飘or洗牌操作
        [24642] = {handler(self, self.procUserOpt)},
        --发送最后一张牌
        [24640] = {handler(self, self.sendLastCard)},  
        --弃牌
        [24612] = {handler(self, self.procUserGiveup)}, 
        --加注
        [24611] = {handler(self, self.procUserJia)}, 
        --结束
        [24584] = {handler(self, self.procGameOver)}, 
    }
end

function MenjiroomView:callFunc(pack)
    if self.func_[pack.type] and self.func_[pack.type][1] then
        self.func_[pack.type][1](pack)
    end
end

function MenjiroomView:procUserGenBet(msg)
	print("procUserGenBet ----------------------")
	self.curBetScore = msg.optScore
	self._totalBetScore = self._totalBetScore +  msg.optScore
	
	self:showChipSum(true, self._totalBetScore)
	self:showKuanNode(msg.uid)
	self:diuChips(msg.uid, msg.optScore)
	self:updateUserBetScore(msg.uid, msg.optScore)
	self:showGenValue(msg.uid, msg.optScore)
    if self._fristBet then
        SoundUtils:playCardKindEffect("call_money", 1, msg.optScore/100)            
    else
        SoundUtils:playCardKindEffect("call", 1)
    end
    self._fristBet = false
end

function MenjiroomView:procUserOpt(msg)
	if msg.optScore == 1 then
        SoundUtils:playCardKindEffect("bupiao", 1)
    else
        self:showPiaoCardAniByType(msg.optScore, msg.optScore, 1)
    end
    self.curBetScore = self._baseChip
    if self._prevBetUid then
		local prevUser = MenjiroomView:getUserNode(self._prevBetUid)
		prevUser:getChildByName("showValueBg"):setVisible(false)
		self._prevBetUid = nil
	end
end

function MenjiroomView:sendLastCard(msg)
	self:sendCard(3, self._hasLaper)
	self:setUserPoint(self._hasLaper, 3)
end

function MenjiroomView:procUserGiveup(msg)
	self:showKuanNode(msg.uid)
	self:showQipai(msg.uid)
	SoundUtils:playCardKindEffect("fold", 1)
	self:backAllCardByUid(msg.uid)
	local user_node  = self:getUserNode(msg.uid)
	if user_node then
		local cardPointNode = user_node:getChildByName("cardPointNode")
		cardPointNode:setVisible(false)
	end
	ZJH_USER_UID_PLAYING[msg.uid] = 0
end

function MenjiroomView:procUserJia(msg)
	self._totalBetScore = self._totalBetScore +  msg.optScore
	self:showChipSum(true, self._totalBetScore)
	self:showKuanNode(msg.uid)
	self:diuChips(msg.uid, msg.optScore)
	self:updateUserBetScore(msg.uid, msg.optScore)
	self:showJiaValue(msg.uid, self._betScore[tonumber(msg.uid)] - self._betScore[tonumber(self._prevBetUid)])

    SoundUtils:playCardKindEffect("raise", 1)
	self._fristBet = false

	self.curBetScore = msg.optScore
end

function MenjiroomView:updateUserBetScore(uid, score)
	local user_node  = MenjiroomView:getUserNode(tonumber(uid))
	if user_node then
		print("updateUserBetScore ----------------", uid, self._betScore[tonumber(uid)])
		self._betScore[tonumber(uid)] = self._betScore[tonumber(uid)] + score
		user_node.head_plane.chip_img.bet_times_txt:setString(self._betScore[uid]/100)
	end
end

function MenjiroomView:showGenValue(uid, value)
	if self._prevBetUid then
		local prevUser = MenjiroomView:getUserNode(self._prevBetUid)
		prevUser:getChildByName("showValueBg"):setVisible(false)
	end
	local user_node  = MenjiroomView:getUserNode(uid)
	if user_node then
		user_node:getChildByName("showValueBg"):setVisible(true)
		local betValue = user_node:getChildByName("showValueBg"):getChildByName("betValue")
		betValue:setString(string.format("跟注%d分", value/100))
		self._prevBetUid = uid
	end
end

function MenjiroomView:showJiaValue(uid, value)
	if self._prevBetUid then
		local prevUser = MenjiroomView:getUserNode(self._prevBetUid)
		prevUser:getChildByName("showValueBg"):setVisible(false)
	end
	local user_node  = MenjiroomView:getUserNode(uid)
	if user_node then
		user_node:getChildByName("showValueBg"):setVisible(true)
		local betValue = user_node:getChildByName("showValueBg"):getChildByName("betValue")
		betValue:setString(string.format("加注%d分", value/100))
		self._prevBetUid = uid
	end
end

function MenjiroomView:procGameOver()
	if self._isEquatGame then
		self:showPingJuAni()
	else
		self:gameEnd()
	end
end

function MenjiroomView:loadVideoLayer()
    self._videoOptLayer = require("hall.record.RecordOptLayer").new(self)
    -- self._videoOptLayer:setScale(720/1080)
    self._videoOptLayer:setZOrder(10000)
    self._videoOptLayer:addTo(self)
    self._videoOptLayer:resetOptPositionY(260)
end

function MenjiroomView:initVideoScene()
    print("initVideoScene ----------------------")
    self:showAllUserInfo()
    -- self:showHandlerCards()
end

function MenjiroomView:showAllUserInfo()
	-- local x = 1
	for i,v in ipairs(self._allUserInfoMsgs or {}) do
		ZJH_USER_UID[v.uid] = i
		local cards = string.split(v.cards, ",")
		if #cards == 3 then
			ZJH_USER_UID_PLAYING[v.uid] = 1
			FSP_USER_UID_CARDS[v.uid] = cards
		end
	end
	self._hasLaper = false
	self._winUid = nil
	local maxScore = 0
	for i, v in ipairs(self._allUserInfoMsgs) do
		dump(v, "userinfos === ")
		local userNode = self:showUserInfo(v)
		self._hasLaper = tonumber(v.isLaper) == 1
		if maxScore < v.score then
			maxScore = v.score
			self._winUid = v.uid
		end
		if v.beginTotalScore == 0 then
			self._totalBetScore = #self._allUserInfoMsgs * self._baseChip
			self:diuChips(v.uid, self._baseChip)
		else
			self._totalBetScore = v.beginTotalScore
		end
		self._isEquatGame = tonumber(v.isEquatGame) == 1
		-- if userNode then
		-- 	self:setUserBeginCards(v.cards)
		-- end
	end
	self:sendCard(2, self._hasLaper)
	self:setUserPoint(self._hasLaper, 2)
	self:showChipSum(true, self._totalBetScore)
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
	local base_chip=FanSanPiPanel:getChildByName("base_chip"):setVisible(false)
	local room_info=FanSanPiPanel:getChildByName("room_info"):setVisible(false)
	local lb = room_info:getChildByName("txt_invitecode"):setVisible(false)
	-- if lb then
	-- 	print("set invote_code:",tostring(USER_INFO["invote_code"]))
	-- 	if USER_INFO["invote_code"] then
	-- 		lb:setString("房间号："..USER_INFO["invote_code"])
	-- 	end
	-- 	lb:setVisible(true)
	-- end
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

function MenjiroomView:showMyinfo()
	local index=self:getIndex(USER_INFO["uid"])
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

		-- ZJH_USER_TOTAL_CHIPS[uid] = chips
		if ZJH_USERINFO_TABLE[uid] then
			ZJH_USERINFO_TABLE[uid] = ZJH_USERINFO_TABLE[uid] + chips
		else
			ZJH_USER_TOTAL_CHIPS[uid] = chips
		end

		local value = tonumber(ZJH_USER_TOTAL_CHIPS[uid])/100
		if value and value > 100000 then
			local finalChipTxt = tostring(value/10000)
			value = string.format("%.1f", finalChipTxt) .. "万"
		end
		self:setGoldString(node, value)
	end

end

--显示用户信息
function MenjiroomView:showUserInfo(data)
	-- body
	local index   = self:getIndex(data.uid)

	if index == nil then
		print("error",debug.getinfo(1).currentline,debug.getinfo(1).name)
		return
	end
	ZJH_PLAYERTYPE_TABLE[data.uid] = index

	local scenes  = FanSanPiPanel

	local user_node = self:getUserNodeByIndex(index)
	if user_node == nil then
		return
	end
	user_node:setLocalZOrder(9998)

	local finalChip = data.totalScore or 0--0--data.remainCoins
	if finalChip then

		-- ZJH_USER_TOTAL_CHIPS[data.uid] = finalChip
		if finalChip and finalChip > 100000 then
			local finalChipTxt = tostring(finalChip/10000)
			finalChip = string.format("%.1f", finalChipTxt) .. "万"
		end

		self:setGoldString(user_node, finalChip/100)
	end
	user_node.head_plane.chip_img:setVisible(true)
	if self._betScore[data.uid] == nil then
		print("asfasdfasdf --------------", data.uid)
		self._betScore[tonumber(data.uid)] = self._baseChip or 0
	end
	dump(self._betScore, "self._betScore ----------------")
	user_node.head_plane.chip_img.bet_times_txt:setString(self._betScore[data.uid]/100)
	--昵称
	local nameStr = require("FanSanPi.FanSanPiSettings"):GetShortName(data["nickName"],9,6)
	self:setNickString(user_node, nameStr)

	local showValueBg = display.newSprite("FanSanPi/layout/player_plane/bg_15.png"):addTo(user_node)
	showValueBg:setPosition(self:getBetValuePos(index + 1))
	showValueBg:setName("showValueBg")
	local text1 = ccui.Text:create("跟注0分", "hall/res/font/FZY3JW.TTF", 32):addTo(showValueBg)
	text1:setName("betValue")
	text1:setColor(cc.c3b(0xFF, 0xFF, 0xFF))
	text1:setPosition(cc.p(90, 23))
	showValueBg:setVisible(false)

	self:drawUser(true,index, data["photoUrl"], data.uid, 1,data["nickName"], "", "")

	return user_node
end

function MenjiroomView:getBetValuePos(idx)
	if idx == 1 then
		return cc.p(294.00, 260)
	elseif idx == 6 then
		return cc.p(-80, 190)
	elseif idx == 3 or idx == 4 or idx == 5 then
		return cc.p(290, 122)
	elseif idx == 2 then
		return cc.p(286, 190)
	end
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
		return nil
	end

	local mySeatId = self:getMySeatId()
    if mySeatId == nil then return end

	local other_index = other_seat
	if mySeatId >= 0 then
		other_index = other_seat - mySeatId
		if other_index < 0 then
			other_index = other_index + TOTAL_PLAYERNUM
		end
	end
	print("getIndex ------------------- ", uid, mySeatId, other_seat, other_index)
	return other_index

end

function MenjiroomView:getMySeatId()
    dump(self._allUserInfoMsgs, "self._allUserInfoMsgs == ")
    for i,v in ipairs(self._allUserInfoMsgs or {}) do
    	print("getMySeatId 1--------------------- ", i)
        if USER_INFO["uid"] == v.uid then
        	print("getMySeatId --------------------- ", i)
            return i
        end
    end
    return 1 -- nil
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

	local finalChip = tonumber(pack['m_chips'])
	if finalChip then
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

--发牌
function MenjiroomView:sendCard(cardSize, isLaper)
	-- body
	local scenes  = FanSanPiPanel
	local count = 0
	local distance_x=50
	self:clearCardNode()
	
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
						if j < 2 or tonumber(FSP_USER_UID_CARDS[tonumber(k)][j+1]) ~= 0 then
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
									card:setCard(tonumber(FSP_USER_UID_CARDS[tonumber(k)][j+1]), isLaper)
									card:showFront()
									card:toBlack()
								end
								-- if j > 0 then
									card:setCard(tonumber(FSP_USER_UID_CARDS[tonumber(k)][j+1]), isLaper)
									card:showFront()
								-- elseif tonumber(k) ~= USER_INFO["uid"] then
								-- 	card:showBack()
								-- end
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
									if tonumber(FSP_USER_UID_CARDS[tonumber(k)][3]) == 0 then
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

function MenjiroomView:setUserPoint(hasLaper, size)
	for k, v in pairs(FSP_USER_UID_CARDS) do
		local point = 0
		for i, v1 in pairs(v or {}) do
			if i <= size then
				-- if i > 1 then
				-- 	point = point + self:getCardPoint(tonumber(v1), hasLaper)
				-- end
				-- if k == USER_INFO["uid"] and i == 1 then
					point = point + self:getCardPoint(tonumber(v1), hasLaper)
				-- end
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

function MenjiroomView:getCardPoint(card, hasLaper)
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

	-- local hasLaper = (string.find(configT.happy_money or "", "2") ~= nil)
	if(hasLaper and point == 3 and color == 0x00) then
		point = 18
	end
	print("getCardPoint -----------------------", card, point)
	return point
end

function MenjiroomView:isKanButton(falg)
	if not FanSanPiPanel then return end
	self.btn_kan = FanSanPiPanel.player_plane_1.btn_kan
	self.btn_kan:setTouchEnabled(false)--falg
	self.btn_kan:setVisible(false)
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
	for i, v in ipairs(self._allUserInfoMsgs) do
		local card_node = self:getCardPanel(v.uid)
		if card_node and ZJH_USER_UID_PLAYING[v.uid] == 1 then
			card_node:removeAllChildren()
		end
		local userNode = self:getUserNode(v.uid)
		local cardPointNode = userNode:getChildByName("cardPointNode")
		if cardPointNode then
			cardPointNode:setVisible(false)
		end
	end
	-- for i = 0, 5 do
	-- 	local card_node = self:getPanelCardNodeByIndex(i)
	-- 	if card_node then
	-- 		card_node:removeAllChildren()
	-- 	end
	-- 	local userNode = self:getUserNodeByIndex(i)
	-- 	local cardPointNode = userNode:getChildByName("cardPointNode")
	-- 	if cardPointNode then
	-- 		cardPointNode:setVisible(false)
	-- 	end
	-- end

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
			if tonumber(v) > 0 then
				local card = card_node:getChildByName("card"..tostring(k-1))
				if card then
					card:setCard(tonumber(v), self._hasLaper)
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
	-- for k,v in pairs(bm.Room.zhus or {}) do
	-- 	if gold==v then
	-- 		chip= UiCommon:getChipBtnNew(gold/100,k)
	-- 		local random = math.random(1,90)
	-- 		local rotate=cc.RotateBy:create(0.1,random)

	-- 		chip:runAction(rotate)
	-- 	end
	-- end

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
	if self.totalChips == nil then
		self.totalChips = {}
		table.insert(self.totalChips, chip)--self.totalChips
	else
		table.insert(self.totalChips, chip)
	end

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

function MenjiroomView:showKuanNode(uid)
	for i, v in ipairs(self._allUserInfoMsgs) do
		local user_node  = MenjiroomView:getUserNode(v.uid)
		if user_node then
			local kuang_node = self:getEffect_frame(user_node)
			kuang_node:stopAllActions()
			kuang_node:hide()
		end
	end

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

function MenjiroomView:exitGame(sender,event)

end

-- 显示结果
function MenjiroomView:gameEnd()
	for k,v in pairs(self._allUserInfoMsgs or {}) do

		local cards = nil
		local card_type=v.card_type

		if ZJH_USER_UID_PLAYING[v.uid] == 1 then-- or v.uid == USER_INFO["uid"] 
			cards = v['cards']--MenjiroomView:sortOrder(v.compare_content[1]['cards'])

			self:setCards(v.uid, FSP_USER_UID_CARDS[v.uid])
			local point = 0
			for i, v1 in pairs(FSP_USER_UID_CARDS[v.uid]) do
				point = point + self:getCardPoint(tonumber(v1), self._hasLaper)
			end
			MenjiroomView:showCard(v.uid, point)

		else
			local showCardGreen = FanSanPiPanel:getChildByName("showCardGreen")
			-- showCardGreen:setVisible(true)
		end
	end

	self:recycleChips(self._winUid, pack)
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

	local chips_sum = FanSanPiPanel:getChildByName("chips_sum")
	if chips_sum then
		chips_sum:setVisible(flag)
	end
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
	local chipsLis =table.getn(self.totalChips)
	local time = 1.2
	local flag_callback =true
	local index_count = table.getn(self.totalChips)
	local chip_count = table.getn(self.totalChips)
	local time_init = 0.8 / chip_count
	dump(time_init,"time_init")
	-- local targetPos = scenes:convertToWorldSpace(self:getHeadNode(user_node):getPosition())
	--将head的坐标映射到世界坐标系中去
	local head = self:getHeadNode(user_node)
	local planeItem_world_pos = (head:getParent()):convertToWorldSpace(head:getPosition())
	local targetPos = scenes:getChildByName("diuChipNode"):convertToNodeSpaceAR(planeItem_world_pos)

	local gameEndMoneyAnimHandler = handler(self, self.gameEndMoneyAnim)
	dump(self.totalChips,"self.totalChips")
	if not next(self.totalChips) then

	end
	for k,v in pairs(self.totalChips) do
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
					-- local handle = scheduler.performWithDelayGlobal(callback, time)
					-- table.insert(schedulerEvents, handle)
				end

			end
		end
		local callfunc = function()

			print("recycleChips callfunc", tostring(uid))
			MenjiroomView:kuangLight(uid)
			-- MenjiroomView:gameEndMoneyAnim(pack)
			gameEndMoneyAnimHandler()
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
						-- local handle = scheduler.performWithDelayGlobal(callback, time)
						-- table.insert(schedulerEvents, handle)
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
						-- local handle = scheduler.performWithDelayGlobal(callback, time)
						-- table.insert(schedulerEvents, handle)
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
	transition.playAnimationOnce(light_kuang,animation,true,onComplete)
	light_kuang:addTo(user_node, 2)


	light_kuang:pos(user_node:getContentSize().width/2, user_node:getContentSize().height/2)
end

--钱上浮飘啊飘
function MenjiroomView:gameEndMoneyAnim(pack)
	-- body
	require("hall.GameCommon"):playEffectSound("FanSanPi/res/audio/login_gold.mp3")

	for k,v in pairs(self._allUserInfoMsgs) do--
		local uid       = v.uid
		local index     = ZJH_PLAYERTYPE_TABLE[uid]
		local user_node = MenjiroomView:getUserNode(uid)
		if user_node then
			local num       = nil
			local tempScore = v.score/100

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

			local FadeIn = cc.FadeIn:create(0.2)
			local FadeOut = cc.FadeOut:create(0.2)
			local delay= cc.DelayTime:create(2)
			local seq = cc.Sequence:create(FadeIn, delay, FadeOut)
			-- local spawn   = cc.Spawn:create(move,fadeout)
			score_txt:runAction(seq)
			-- local finalChip = v["chips"]
			-- if finalChip then
			-- 	ZJH_USER_TOTAL_CHIPS[uid] = finalChip
			-- 	if GROUP_MODE == 1 then
			-- 		finalChip = finalChip 
			-- 		ZJH_USER_TOTAL_CHIPS[uid] = finalChip
			-- 	else
			-- 		if finalChip and finalChip > 100000 then
			-- 			local finalChipTxt = tostring(finalChip/10000)
			-- 			finalChip = string.format("%.1f", finalChipTxt) .. "万"
			-- 		end
			-- 	end

			-- 	self:setGoldString(user_node, finalChip/100)
			-- end
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
	cc.SimpleAudioEngine:getInstance():stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopMusic()
    -- audio.playMusic(HallBgm_filePath, true)
    --播放背景音乐
    SoundUtils:playBackgroundMusic()
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