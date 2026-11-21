local Card = require("mhxl_majiang.card.card")
local sendHandle = require("mhxl_majiang.handle.XLMHSendHandle")

local RoundEndingLayer = class("RoundEndingLayer")

local CHILD_NAME_FLOOR = "floor"
local CHILD_NAME_TITLE_BG_IMG = "title_bg_img"
local CHILD_NAME_TITLE_IMG = "title_img"
local CHILD_NAME_SHOW_PLANE = "show_plane"
local CHILD_NAME_BIRD_CARD_PLANE = "bird_card_plane"
local CHILD_NAME_START_BT = "start_bt"
local CHILD_NAME_CLOSE_BT = "close_bt"
local CHILD_NAME_ROOM_LB = "room_lb"
local CHILD_NAME_BIRD_LB = "bird_lb"
local CHILD_NAME_TIME_LB = "time_lb"
local CHILD_NAME_JIESAN_BT = "jiesan_bt"

local CHILD_NAME_PLAYER1_PLANE = "player1_plane"
local CHILD_NAME_PLAYER2_PLANE = "player2_plane"
local CHILD_NAME_PLAYER3_PLANE = "player3_plane"
local CHILD_NAME_PLAYER4_PLANE = "player4_plane"

local CHILD_NAME_ZHUANG_SIGNAL = "zhuang_signal"
local CHILD_NAME_NICK_LB = "nick_lb"
local CHILD_NAME_DESC_LB = "desc_lb"
local CHILD_NAME_CARD_PLANE = "card_plane"
local CHILD_NAME_SCORE_LB = "score_lb"
local CHILD_NAME_HU_SIGNAL = "hu_signal"

local CHILD_NAME_ROLE_IMG = "role_img"

local CHILD_NAME_CAISHEN_PLANE = "caishen_plane"
local CHILD_NAME_GUANG_IMG = "guang_img"
local CHILD_NAME_GUANG_IMG_0 = "guang_img_0"
local CHILD_NAME_SHAN_IMG = "shan_img"

local TITLE_TYPE_WIN = 1
local TITLE_TYPE_LOSE = 2
local TITLE_TYPE_LIUJU = 3

win_lose_table = {} -- key = seatId

local isShow = false

local isChajiao = false

local searchPath = "mhxl_majiang/image/"

function RoundEndingLayer:showEndingAnimate(data, isEnd)
	-- body
	self:showZhuaniao(data, isEnd)
	return

	-- for k,v in pairs(data.players) do
	-- 	local player = v
	-- 	-- if player.uid == USER_INFO["uid"] and player.changeCoins <= 0 then
	-- 	if player.uid == USER_INFO["uid"] then
	-- 		self:showZhuaniao(data, isEnd)

	-- 		return
	-- 	end
	-- end


	-- self.victoryLayer = cc.CSLoader:createNode("mhxl_majiang/VictoryEffectLayer.csb")
	-- self.victoryFloor = self.victoryLayer:getChildByName(CHILD_NAME_FLOOR)
	-- local caishen_plane = self.victoryFloor:getChildByName(CHILD_NAME_CAISHEN_PLANE)

	-- local guang_img = self.victoryFloor:getChildByName(CHILD_NAME_GUANG_IMG)
	-- local guang_img_0 = self.victoryFloor:getChildByName(CHILD_NAME_GUANG_IMG_0)
	-- local shan_img = self.victoryFloor:getChildByName(CHILD_NAME_SHAN_IMG)

	-- local timeDelay = 2.5

	-- -- local ac = cc.Sequence:create(cc.RotateBy:create(2, 360))
	-- -- guang_img:runAction(cc.RepeatForever:create(ac))
	-- -- local ac_0 = cc.Sequence:create(cc.RotateBy:create(2, 360))
	-- -- guang_img_0:runAction(cc.RepeatForever:create(ac_0))

	-- guang_img:runAction(cc.ScaleTo:create(timeDelay, 1.2, 1.2, 1.2))
	-- guang_img_0:runAction(cc.ScaleTo:create(timeDelay, 1.2, 1.2, 1.2))
	-- shan_img:runAction(cc.ScaleTo:create(timeDelay, 1.2, 1.2, 1.2))

	-- require("hall.view.modelView.ModelView"):addView(caishen_plane)

	-- SCENENOW["scene"]:addChild(self.victoryLayer)

	

	-- local callFuncAc = cc.CallFunc:create(function ()
	-- 	self.victoryLayer:removeFromParent()
	-- 	self:showZhuaniao(data, isEnd)
	-- end)

	-- self.victoryLayer:runAction(cc.Sequence:create(cc.DelayTime:create(timeDelay), callFuncAc))
end

function RoundEndingLayer:showZhuaniao(data, isEnd)
	isShow = true

	win_lose_table = {}

	for k,v in pairs(data.players) do
		local player = v
		if player.huTypeCount > 0 then
			--todo
			win_lose_table[k - 1] = "Y"
		else
			win_lose_table[k - 1] = "N"
		end
	end

	local cards_tb1 = {}
	local zhongcard = {}
	local count = table.getn(data.birdCards)
	for i=1,count do
		table.insert(cards_tb1, data.birdCards[i])
		if data.birdCards[i]["position"] == 1 then
			--todo
			-- table.insert(zhongcard, data.birdCards[i]["card"])
		end
	end

	local timeDelay = require("mhxl_majiang.result_effect_layout"):reset_niaocard_data(cards_tb1, zhongcard)
	
	if timeDelay == 0 then
		--todo
		timeDelay = 2
	else
		timeDelay = timeDelay + 2
	end

	local zhuaniaoLayout = SCENENOW["scene"]:getChildByName("zhuaniaoLayout")
	if zhuaniaoLayout then
		--todo
		local callFuncAc = cc.CallFunc:create(function ()
				zhuaniaoLayout:removeFromParent()
				XLMH_CONTROLLER:clearGameDatas()

				if XLMH_GROUP_ENDING_DATA then
					--todo
					self:show(data, true)
				else
					self:show(data, false)
				end
				print("========7878787878=======")
				local tempScoreLayer = require("mhxl_majiang.RoundEndingScoreLayer")
			    SCENENOW["scene"].temptempScoreLayer = tempScoreLayer.new(XLMH_ENDING_DATA)
			    SCENENOW["scene"]:addChild(SCENENOW["scene"].temptempScoreLayer,99999999)

			end)

		zhuaniaoLayout:runAction(cc.Sequence:create(cc.DelayTime:create(timeDelay), callFuncAc))
	end
end

function RoundEndingLayer:show(data, isEnd)
	isShow = true
	local isEndT = isEnd or false

	win_lose_table = {}

	local RoundResultCsb_filePath = "mhxl_majiang/roundEndingLayer.csb"
	
	self._scene = cc.CSLoader:createNode(RoundResultCsb_filePath)
	self.floor = self._scene:getChildByName(CHILD_NAME_FLOOR)
	self.showPlane = self.floor:getChildByName(CHILD_NAME_SHOW_PLANE)

	local endType = data.type
	local uid = data.uid

	local players = data.players

	local me = nil

	for i=1,4 do
		local playerPlaneName = "player" .. i .. "_plane"
		local playerPlane = self.showPlane:getChildByName(playerPlaneName)

		playerPlane:setVisible(false)
	end

	for i=1,table.getn(players) do

		local isZhuang = false
		if XLMH_ZHUANG_UID == players[i].uid then
			--todo
			isZhuang = true
		end
		dump(players[i],"players[i]查看鸡牌")
		self:dealPlayerCards(players[i].remainCards, data.huCard, players[i].huTypeCount)
		self:showPlayerPlane(players[i], i, isZhuang, data.huCard, endType)

		if players[i].uid == USER_INFO["uid"] then
			--todo
			me = players[i]
		end
	end

	local titleType = TITLE_TYPE_LIUJU
	if endType ~= 0 then
		--todo
		if me.changeCoins > 0 then
			--todo
			titleType = TITLE_TYPE_WIN
		else
			titleType = TITLE_TYPE_LOSE
		end
	end

	isChajiao = false

	if titleType == TITLE_TYPE_LIUJU then
		--todo
		for i,v in ipairs(players) do
			if v.huTypeCount > 0 then
				--todo
				isChajiao = true
				break
			end
		end
	end

	self:showTitle(titleType)

	self:showBirdCards(data.birdCards)

	for i=1,table.getn(players) do

		self:showEndingInfo(players[i], i)
	end

	local timeStr = os.date("%Y-%m-%d %H:%M:%S",data["time"])
	self:showGameRemark(timeStr)

	local start_bt = self.floor:getChildByName(CHILD_NAME_START_BT)
	start_bt:setVisible(false)
	if start_bt then
		--todo
		local function bt_callback(sender, event)
			if event == TOUCH_EVENT_ENDED then
				--todo
				sendHandle:readyNow()

				self._scene:removeFromParent()
				isShow = false
			end
		end

		start_bt:addTouchEventListener(bt_callback)

		-- if isEndT then
		-- 	--todo
		-- 	start_bt:setVisible(false)
		-- else
		-- 	start_bt:setVisible(true)
		-- end
	end

	local close_bt = self.floor:getChildByName(CHILD_NAME_CLOSE_BT)
	close_bt:setVisible(false)

	if close_bt then
		--todo
		local function bt_callback(sender, event)
			if event == TOUCH_EVENT_ENDED then
				--todo
				self._scene:removeFromParent()

				if XLMH_GROUP_ENDING_DATA then
					--todo
					require("mhxl_majiang.GroupEndingLayer"):showGroupResult(XLMH_GROUP_ENDING_DATA)
				end

				isShow = false

			end
		end

		close_bt:addTouchEventListener(bt_callback)

		-- if isEndT then
		-- 	--todo
		-- 	close_bt:setVisible(true)
		-- else
		-- 	close_bt:setVisible(false)
		-- end
	end

	local jiesan_bt = self.floor:getChildByName(CHILD_NAME_JIESAN_BT)
	jiesan_bt:setVisible(false)
	if jiesan_bt then
		--todo
		local function bt_callback(sender, event)
			if event == TOUCH_EVENT_ENDED then
				--todo
				SCENENOW["scene"]:disbandGroup()

			end
		end

		jiesan_bt:addTouchEventListener(bt_callback)

		-- if isEndT then
		-- 	--todo
		-- 	jiesan_bt:setVisible(false)
		-- else
		-- 	jiesan_bt:setVisible(true)
		-- end
	end

	local btnClose = self.floor:getChildByName("btnClose")
	if btnClose then
		local function bt_callback(sender, event)
			if event == TOUCH_EVENT_ENDED then
				--todo
				self._scene:setVisible(false)
			end
		end

		btnClose:addTouchEventListener(bt_callback)
	end

	self._scene:setName("roundEndingLayer")
	self._scene:setVisible(false)
	local precent = self:_getScaleParam2()
	self._scene:setScaleX(self._scene:getScaleX()*precent)
	SCENENOW["scene"]:addChild(self._scene,100000000)
end

function RoundEndingLayer:isShowRoundEndingLayer(_isShow)
	self._scene:setVisible(_isShow)
end

function RoundEndingLayer:_getScaleParam2()
	local frameHeight = CONFIG_WIN_HEIGHT
	local disHeight = CONFIG_DESIGN_HEIGHT
	return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
	-- return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end
function RoundEndingLayer:hide()
	local layer = SCENENOW["scene"]:getChildByName("roundEndingLayer")

	if layer then
		--todo
		layer:removeFromParent()
	end
end

function RoundEndingLayer:isShow()
	return isShow
end

function RoundEndingLayer:setIsShow(param)
	isShow = param
end

function RoundEndingLayer:showPlayerPlane(player, index, isZhuang, huCard, endType)
	local playerPlaneName = "player" .. index .. "_plane"
	local playerPlane = self.showPlane:getChildByName(playerPlaneName)

	playerPlane:setVisible(true)

	local zhuang_signal = playerPlane:getChildByName(CHILD_NAME_ZHUANG_SIGNAL)
	zhuang_signal:setVisible(isZhuang)

	local hu_signal = playerPlane:getChildByName(CHILD_NAME_HU_SIGNAL)
	hu_signal:setVisible(false)
	if player.changeCoins > 0 then
		--todo
		win_lose_table[index - 1] = "Y"
	elseif player.changeCoins == 0 then
		win_lose_table[index - 1] = "N"
	else
		win_lose_table[index - 1] = "Y"
	end

	-- if player.huTypeCount > 0 and endType ~= 0 then
	-- 	--todo
	-- 	hu_signal:setVisible(true)
	-- else
	-- 	hu_signal:setVisible(false)
	-- end

	local score_lb = playerPlane:getChildByName(CHILD_NAME_SCORE_LB)
	score_lb:setString("" .. player.changeCoins)
	score_lb:setVisible(false)

	local seatId = index - 1

	local nickname = XLMH_USERINFO_TABLE[seatId .. ""].nick

	local nick_lb = playerPlane:getChildByName(CHILD_NAME_NICK_LB)

	nick_lb:setString(nickname)

	local card_plane = playerPlane:getChildByName(CHILD_NAME_CARD_PLANE)

	local progCards = {}

	for i=1,player.agCount do
		local p = {}
		p.type = "ag"

		local cs = {player.agCards[i].card, player.agCards[i].card, player.agCards[i].card, player.agCards[i].card}

		p.cards = cs

		table.insert(progCards, p)
	end

	for i=1,player.gCount do
		local p = {}
		p.type = "g"

		local cs = {player.gCards[i].card, player.gCards[i].card, player.gCards[i].card, player.gCards[i].card}

		p.cards = cs

		table.insert(progCards, p)
	end

	for i=1,player.pCount do
		local p = {}
		p.type = "p"

		local cs = {player.pCards[i].card, player.pCards[i].card, player.pCards[i].card}

		p.cards = cs

		table.insert(progCards, p)
	end

	local p = nil
	local cs = nil
	for i=1,player.cCount do
		dump(player.cCards[i].card,"chi===")
		if i % 3 == 1 then
			--todo
			p = {}
			p.type = "c"
			cs = {}
			p.cards = cs
			table.insert(cs, player.cCards[i].card)
		elseif i % 3 == 0 then
			table.insert(cs, player.cCards[i].card)

			table.insert(progCards, p)
		else
			table.insert(cs, player.cCards[i].card)
		end
	end

	if player.huTypeCount > 0 and player.isQishou == 0 and endType ~= 0 then
		--todo
		self:showPlayerCards(progCards, player.remainCards, card_plane, huCard)
	else
		self:showPlayerCards(progCards, player.remainCards, card_plane, nil)
	end

	
end

function RoundEndingLayer:showEndingInfo(player, index)
	local playerPlaneName = "player" .. index .. "_plane"
	local playerPlane = self.showPlane:getChildByName(playerPlaneName)

	local desc_lb = playerPlane:getChildByName(CHILD_NAME_DESC_LB)

	local endingInfo = ""

	if player.winLoseType == -1 then
		--todo
		endingInfo = endingInfo .. "点炮 "
	elseif player.winLoseType == 1 then
		endingInfo = endingInfo .. "接炮 "
	elseif player.winLoseType == 2 then
		endingInfo = endingInfo .. "自摸 "
	end

	if isChajiao and player.isChajiao == 1 then
		--todo
		endingInfo = endingInfo .. "查叫 "
	end

	if player.piao > -1 then
		--todo
		endingInfo = endingInfo .. player.piao .. "点 "
	end

	for i=1,player.huTypeCount do
		endingInfo = endingInfo .. XLMH_HU_TYPE_TABLE[player.huTypes[i] + 1] .. " "
	end

	if player.daizhuang == 1 then
		--todo
		endingInfo = endingInfo .. "带庄 "
	end
	if player.mobao == 1 then
		--todo
		endingInfo = endingInfo .. "摸宝 "
	end

	if player.agCount > 0 then
		--todo
		endingInfo = endingInfo .. "暗杠x" .. player.agCount .. " "
	end
	if player.pgCount > 0 then
		--todo
		endingInfo = endingInfo .. "明杠x" .. player.pgCount .. " "
	end
	if player.bgCount > 0 then
		--todo
		endingInfo = endingInfo .. "共杠x" .. player.bgCount .. " "
	end
	if player.dgCount > 0 then
		--todo
		endingInfo = endingInfo .. "点杠x" .. player.dgCount .. " "
	end
	if player.is_dahu > 0 then
		endingInfo = endingInfo .. "大胡" .. " "
	end
	if player.isCSB > 0 then
		--todo
		endingInfo = endingInfo .. "吃三比".. ""
	end
	local birdCount = win_lose_table[(index - 1) .. "birdCount"]
	if not birdCount then
		--todo
		birdCount = 0
	end

	-- desc_lb:setString(endingInfo)
	desc_lb:setString(" ")
end

function RoundEndingLayer:showTitle(titleType)
	local title_txt = self.showPlane:getChildByName("title_txt")

	if titleType == TITLE_TYPE_WIN then
		-- --todo
		title_txt:setString("胜局")
		self.showPlane:loadTexture(searchPath.."bottom_win.png")
		-- title_bg_img:loadTexture("gd_majiang_3d/image/red_button_p.png")
		-- title_img:loadTexture("gd_majiang_3d/image/mahjong_win.png")
	elseif titleType == TITLE_TYPE_LOSE then
		title_txt:setString("败局")
		self.showPlane:loadTexture(searchPath.."bottom_lose.png")
		-- title_bg_img:loadTexture("gd_majiang_3d/image/mahjong_lose_bt.png")
		-- title_img:loadTexture("gd_majiang_3d/image/mahjong_lose.png")
	else
		title_txt:setString("流局")
		self.showPlane:loadTexture(searchPath.."bottom_lose.png")
		-- title_bg_img:loadTexture("gd_majiang_3d/image/grey_button.png")
		-- title_img:loadTexture("gd_majiang_3d/image/text_liuju.png")
	end
end

function RoundEndingLayer:showGameRemark(timeStr)
	local room_lb = self.floor:getChildByName(CHILD_NAME_ROOM_LB)
	local bird_lb = self.floor:getChildByName(CHILD_NAME_BIRD_LB)
	local time_lb = self.floor:getChildByName(CHILD_NAME_TIME_LB)

	self.floor:getChildByName("Text_13"):setVisible(false)
	

	room_lb:setString("房号" .. USER_INFO["invote_code"])
	room_lb:setVisible(false)
	bird_lb:setVisible(false)
	time_lb:setVisible(false)

	-- bird_lb:setString("抓2鸟")
	if USER_INFO["gameConfig"] then
		--todo
		bird_lb:setString(XLMH_PRV_GAME_NAME .. "：" .. USER_INFO["gameConfig"])
	else
		bird_lb:setString("正在读取组局信息")
	end
	time_lb:setString(timeStr)
end

function RoundEndingLayer:showBirdCards(cards)
	if not cards then
		--todo
		return
	end

	local bird_card_plane = self.floor:getChildByName(CHILD_NAME_BIRD_CARD_PLANE)
	bird_card_plane:setVisible(false)

	local height = bird_card_plane:getSize().height

	local count = table.getn(cards)
	for i=1,count do
		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cards[i]["card"])

		local scale = height / card:getSize().height/2

		if cards[i]["position"] == 1 then
			--todo
			card:setColor(cc.c3b(200, 200, 50))

			local countKey = cards[i]["position"] .. "birdCount"

			if win_lose_table[countKey] then
				--todo
				local count = win_lose_table[countKey] + 1

				win_lose_table[countKey] = count
			else
				local count = 1
				win_lose_table[countKey] = count
			end
		end

		card:setScale(scale)
		if i<= 6 then
			card:setPosition(cc.p(card:getSize().width * scale * (i - 1) + card:getSize().width * scale / 2, height / 2+card:getSize().height/2))
		else
			card:setPosition(cc.p(card:getSize().width * scale * (i - 7) + card:getSize().width * scale / 2, card:getSize().height/2))
		end
		bird_card_plane:addChild(card)
		end
end

function RoundEndingLayer:showPlayerCards(progCards, handCards, cardPlane, huCard)
	if not cardPlane then
		--todo
		return
	end

	local progCount = table.getn(progCards)
	local handCount = table.getn(handCards)

	local oriX = 0

	for i=1,progCount do
		local cType = progCards[i].type
		local cards = progCards[i]["cards"]

		for j=1,table.getn(cards) do
			local card

			if cType == "ag" and j == 1 then
				--todo
				card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_HIDE, cards[j])
			else
				card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cards[j])
			end

			local size = card:getSize()

			-- card:setScale(70 / size.height)

			card:setPosition(cc.p(oriX + size.width * card:getScale() / 2, size.height * card:getScale() / 2))

			cardPlane:addChild(card)

			oriX = oriX + size.width * card:getScale()
		end

		oriX = oriX + 20
	end

	for i=1,handCount do
		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, handCards[i])

		local size = card:getSize()

		-- card:setScale(70 / size.height)

		card:setPosition(cc.p(oriX + size.width * card:getScale() / 2, size.height * card:getScale() / 2))

		cardPlane:addChild(card)

		oriX = oriX + size.width * card:getScale()
	end

	if huCard and huCard > 0 then
		--todo
		oriX = oriX + 20

		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, huCard)

		local size = card:getSize()

		-- card:setScale(70 / size.height)

		card:setPosition(cc.p(oriX + size.width * card:getScale() / 2, size.height * card:getScale() / 2))

		cardPlane:addChild(card)
	end
end

function RoundEndingLayer:dealPlayerCards(cards, huCard, huTypeCount)
	if huTypeCount <= 0 then
		--todo
		return
	end
	
	if huCard and huCard > 0 then
		--todo
		for i=1,table.getn(cards) do
			if cards[i] == huCard then
				--todo
				table.remove(cards, i)

				break
			end
		end
	end
end

function RoundEndingLayer:groupEnd()
	local layer = SCENENOW["scene"]:getChildByName("roundEndingLayer")


	if layer then
		--todo
		local floor = layer:getChildByName(CHILD_NAME_FLOOR)
		-- local start_bt = floor:getChildByName(CHILD_NAME_START_BT)
		-- local close_bt = floor:getChildByName(CHILD_NAME_CLOSE_BT)

		-- start_bt:setVisible(false)
		-- close_bt:setVisible(true)
	end
end

return RoundEndingLayer