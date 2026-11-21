local Card = require("cs_majiang.card.card")
local sendHandle = require("cs_majiang.handle.CSMJSendHandle")
local cardUtils = require("cs_majiang.utils.cardUtils")

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

local TITLE_TYPE_WIN = 1
local TITLE_TYPE_LOSE = 2
local TITLE_TYPE_LIUJU = 3

local win_lose_table = {} -- key = seatId
local niaoCount = 0
local isShow = false

local searchPath = "cs_majiang/image/"

function RoundEndingLayer:showZhuaniao(data, isEnd)
	isShow = true
	niaoCount = 0
	local dianPaoUid = data.uid

	local lightNiaoSeatId = CSMJ_SEAT_TABLE[dianPaoUid]

	win_lose_table = {}
	for i = 0, 3, 1 do win_lose_table[i] = "N" end

	for k,v in pairs(data.players) do
		local player = v
		local huFlag = false
		for i = 1, player.huTypeCount do 
			if player.huTypes[i] >= 5 then
				huFlag = true
			end
		end
	end
	niaoCount = 0
	for i = 1, #data.birdCards, 1 do
		dump(data.birdCards[i]["position"],"data.birdCards[i][position]")
		if data.birdCards[i]["position"] > -1 then
			niaoCount = niaoCount+1
			win_lose_table[data.birdCards[i]["position"]] = "Y"
		else
			win_lose_table[data.birdCards[i]["position"]] = "N"
		end
	end

	local cards_tb1 = {}
	local zhongcard = {}
	local count = table.getn(data.birdCards)
	for i=1, count do
		table.insert(cards_tb1, data.birdCards[i]["card"])
		if win_lose_table[data.birdCards[i]["position"]] == "Y" then
			table.insert(zhongcard, data.birdCards[i]["card"])
		end
	end

	local timeDelay = require("cs_majiang.result_effect_layout"):reset_niaocard_data(cards_tb1, zhongcard)
	
	--if timeDelay == 0 then
	--	timeDelay = 3
	--else
	--	timeDelay = timeDelay + 0
	--end
	timeDelay = 3
	if GROUP_MODE == GOLD_MODE then
		local change_chip_plane = SCENENOW["scene"]._scene:getChildByName("change_chip_plane")
		change_chip_plane:setVisible(true)
		for k,v in pairs(data.players) do
		    local playerType = cardUtils:getPlayerType(CSMJ_SEAT_TABLE[v.uid..""])
		    local changeCoins = v.changeCoins
		    local change_chip = change_chip_plane:getChildByName("change_chip_"..playerType)
		    if changeCoins >= 0 then
		    	change_chip:setString("+"..changeCoins)
		    else
		    	change_chip:setString(changeCoins)
		    end
  		end
	end
	local zhuaniaoLayout = SCENENOW["scene"]:getChildByName("zhuaniaoLayout")
	if zhuaniaoLayout then
		local callFuncAc = cc.CallFunc:create(function ()
				SCENENOW["scene"]:showReadyBtn(true)
				SCENENOW["scene"]:showCopyBtn(true)
  				SCENENOW["scene"]:showShareButton(true)
				if GROUP_MODE == ROOMCARD_MODE then
					zhuaniaoLayout:removeFromParent()
					CSMJ_CONTROLLER:clearGameDatas()
					self:show(data, isEnd)
				end
			end)

		zhuaniaoLayout:runAction(cc.Sequence:create(cc.DelayTime:create(timeDelay), callFuncAc))
	end
end

function RoundEndingLayer:show(data, isEnd)

	-- for k,v in pairs(data.players) do
	-- 	local seatId = CSMJ_SEAT_TABLE[v.uid..""]
	-- 	if seatId == nil then
	-- 		return
	-- 	end
	-- 	if CSMJ_USERINFO_TABLE[seatId..""] == nil then
	-- 		return
	-- 	end
	-- end

	if SCENENOW["scene"]:getChildByName("roundEndingLayer") then
		SCENENOW["scene"]:getChildByName("roundEndingLayer"):removeFromParent()
	end
	isShow = true
	local isEndT = isEnd or false
	local RoundResultCsb_filePath = RoundResultCsb_filePath or "cs_majiang/roundEndingLayer.csb"

	self._scene = cc.CSLoader:createNode(RoundResultCsb_filePath)
	self.floor = self._scene:getChildByName(CHILD_NAME_FLOOR)
	self.showPlane = self.floor:getChildByName(CHILD_NAME_SHOW_PLANE)

	local Text_13 = self.floor:getChildByName("Text_13")
    Text_13:setString("抓鸟")

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
		if CSMJ_ZHUANG_UID == players[i].uid then
			isZhuang = true
		end
		
		self:dealPlayerCards(players[i].remainCards, players[i]["hu_card"], players[i].huTypeCount)
		
		self:showPlayerPlane(players[i], i, isZhuang, players[i]["hu_card"])

		if players[i].uid == USER_INFO["uid"] then
			me = players[i]
		end
	end

	local titleType = TITLE_TYPE_LIUJU
	if endType ~= 0 then
		if me.changeCoins > 0 then
			titleType = TITLE_TYPE_WIN
		else
			titleType = TITLE_TYPE_LOSE
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

	if start_bt then
		local function bt_callback(sender, event)
			if event == TOUCH_EVENT_ENDED then
				if GROUP_MODE == ROOMCARD_MODE then
					SCENENOW["scene"]:showReadyBtn(true)
					SCENENOW["scene"]:showCopyBtn(true)
	  				SCENENOW["scene"]:showShareButton(true)
	  			end
				self._scene:removeFromParent()
				isShow = false
			end
		end

		start_bt:addTouchEventListener(bt_callback)

		if isEndT then
			start_bt:setVisible(false)
		else
			start_bt:setVisible(true)
		end
	end

	local close_bt = self.floor:getChildByName(CHILD_NAME_CLOSE_BT)

	if close_bt then
		local function bt_callback(sender, event)
			if event == TOUCH_EVENT_ENDED then
				self._scene:removeFromParent()

				if CSMJ_GROUP_ENDING_DATA then
					require("cs_majiang.GroupEndingLayer"):showGroupResult(CSMJ_GROUP_ENDING_DATA)
				end

				isShow = false
			end
		end

		close_bt:addTouchEventListener(bt_callback)

		if isEndT then
			close_bt:setVisible(true)
		else
			close_bt:setVisible(false)
		end
	end

	local jiesan_bt = self.floor:getChildByName(CHILD_NAME_JIESAN_BT)
	jiesan_bt:setVisible(false)
	if jiesan_bt then
		local function bt_callback(sender, event)
			if event == TOUCH_EVENT_ENDED then
				SCENENOW["scene"]:disbandGroup()

			end
		end

		jiesan_bt:addTouchEventListener(bt_callback)

		-- if isEndT then
		-- 	jiesan_bt:setVisible(false)
		-- else
		-- 	jiesan_bt:setVisible(true)
		-- end
	end

	self._scene:setName("roundEndingLayer")
	SCENENOW["scene"]:addChild(self._scene)

	local precent = self:_getScaleParam2()
	self._scene:setScaleX(self._scene:getScaleX()*precent)

end

function RoundEndingLayer:_getScaleParam2()
	local frameHeight = CONFIG_WIN_HEIGHT
	local disHeight = CONFIG_DESIGN_HEIGHT
	return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
end

function RoundEndingLayer:showEnd()
	print("====RoundEndingLayer:showEnd()=====")
	local close_bt = self.floor:getChildByName(CHILD_NAME_CLOSE_BT)
	close_bt:setVisible(true)
end

function RoundEndingLayer:hide()
	isShow = false

	local layer = SCENENOW["scene"]:getChildByName("roundEndingLayer")

	if layer then
		--todo
		layer:removeFromParent()
	end
end

function RoundEndingLayer:isShow()
	return isShow
end

function RoundEndingLayer:showPlayerPlane(player, index, isZhuang, huCard)
	local playerPlaneName = "player" .. index .. "_plane"
	local playerPlane = self.showPlane:getChildByName(playerPlaneName)
	playerPlane:setVisible(true)
	local zhuang_signal = playerPlane:getChildByName(CHILD_NAME_ZHUANG_SIGNAL)
	zhuang_signal:setVisible(isZhuang)

	local hu_signal = playerPlane:getChildByName(CHILD_NAME_HU_SIGNAL)

	
	local qishouFlag = false	-- 起手胡标记 @Jhao.
	local huFlag = false		-- 常规和牌标记
	for i = 1, player.huTypeCount, 1 do
		--print("<<<<<<<<<<<<<", player.huTypes[i])
		if player.huTypes[i] < 5 then
			qishouFlag = true
		end

		if player.huTypes[i] >= 5 then
			huFlag = true
		end
	end

	--print("index:", index, "qishouFlag:", qishouFlag, "huFlag", huFlag)
	
	hu_signal:setVisible(huFlag)
	-- if player.huTypeCount > 0 and not qishouFlag then
	-- 	--todo
	-- 	hu_signal:setVisible(true)
	-- else
	-- 	hu_signal:setVisible(false)
	-- end

	local score_lb = playerPlane:getChildByName(CHILD_NAME_SCORE_LB)
	score_lb:setString("" .. tonumber(player.changeCoins)/100)

	local seatId = index - 1

	local nickname = player.nick

	local nick_lb = playerPlane:getChildByName(CHILD_NAME_NICK_LB)
	nick_lb:setFontName("cs_majiang/fonts/fzcs.ttf")
	nick_lb:setString(nickname)

	local card_plane = playerPlane:getChildByName(CHILD_NAME_CARD_PLANE)

	local progCards = {}

	for i=1,player.agCount do
		local p = {}
		p.type = "ag"

		local cs = {player.agCards[i], player.agCards[i], player.agCards[i], player.agCards[i]}

		p.cards = cs

		table.insert(progCards, p)
	end

	for i=1,player.gCount do
		local p = {}
		p.type = "g"

		local cs = {player.gCards[i], player.gCards[i], player.gCards[i], player.gCards[i]}

		p.cards = cs

		table.insert(progCards, p)
	end

	for i=1,player.pCount do
		local p = {}
		p.type = "p"

		local cs = {player.pCards[i], player.pCards[i], player.pCards[i]}

		p.cards = cs

		table.insert(progCards, p)
	end

	local p = nil
	local cs = nil
	for i=1,player.cCount do
		if i % 3 == 1 then
			--todo
			p = {}
			p.type = "c"
			cs = {}
			p.cards = cs
			table.insert(cs, player.cCards[i])
		elseif i % 3 == 0 then
			table.insert(cs, player.cCards[i])

			table.insert(progCards, p)
		else
			table.insert(cs, player.cCards[i])
		end
	end


	if huFlag then
		self:showPlayerCards(progCards, player.remainCards, card_plane, huCard)
	else
		self:showPlayerCards(progCards, player.remainCards, card_plane, nil)
	end
	-- if player.huTypeCount > 0 and player.isQishou == 0 then 
	-- 	--todo
	-- 	self:showPlayerCards(progCards, player.remainCards, card_plane, huCard)
	-- else
	-- 	self:showPlayerCards(progCards, player.remainCards, card_plane, nil)
	-- end

	
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

	if player.dgCount > 0 then
		--todo
		endingInfo = endingInfo .. "点杠x" .. player.dgCount .. " "
	end
	if player.pgCount > 0 then
		--todo
		endingInfo = endingInfo .. "接杠x" .. player.pgCount .. " "
	end
	if player.bgCount > 0 then
		--todo
		endingInfo = endingInfo .. "补杠x" .. player.bgCount .. " "
	end
	if player.agCount > 0 then
		--todo
		endingInfo = endingInfo .. "暗杠x" .. player.agCount .. " "
	end
	
	for i=1,player.huTypeCount do

		if player.huTypes[i] < 5 and i == 1 then -- 起手胡逻辑 @Jhao
			if i == 1 then
				endingInfo = endingInfo .. STR_HU_TYPE_QISHOU .. ""
			else
				endingInfo = endingInfo .. ", "
			end
		end

		endingInfo = endingInfo .. HU_TYPE_TABLE[player.huTypes[i]] .. " "
		if player.hu_card>0 then
			--local birdCount = win_lose_table[(index - 1) .. "birdCount"]
			--if not birdCount then
			--	--todo
			--	birdCount = 0
			--end

		end
	end

	if player.huTypeCount and player.huTypeCount > 0 then
		if player.piaoScore and player.piaoScore > 0  then 
			endingInfo = endingInfo .. "漂+" .. player.piaoScore.." "
		end 
	end


	if niaoCount > 0 then
		endingInfo = endingInfo .. "中" .. niaoCount .. "鸟"
	end


	desc_lb:setString(endingInfo)
end

function RoundEndingLayer:showTitle(titleType)
	-- local title_bg_img = self.floor:getChildByName(CHILD_NAME_TITLE_BG_IMG)
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
	-- room_lb:setFontName("cs_majiang/fonts/fzcs.ttf")
	room_lb:setString("房号" .. USER_INFO["invote_code"])

	--local ttf = {}
	--ttf.fontFilePath = "cs_majiang/fonts/systemFont.TTF"
	--ttf.fontSize = 23
	--room_lb:setTTFConfig(ttf)
	-- bird_lb:setString("抓2鸟")
	if USER_INFO["gameConfig"] then
		--todo
		bird_lb:setString(GameNameValue..": " .. USER_INFO["gameConfig"])
	else
		bird_lb:setString("正在读取组局信息")
	end
	time_lb:setString(timeStr)
end

function RoundEndingLayer:showBirdCards(cards)
	if not cards then
		return
	end

	local bird_card_plane = self.floor:getChildByName(CHILD_NAME_BIRD_CARD_PLANE)

	local height = bird_card_plane:getSize().height

	local count = table.getn(cards)
	for i=1,count do
		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_SHOW, cards[i]["card"])

		local scale = height / card:getSize().height

		if win_lose_table[cards[i]["position"]] == "Y" then
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

		card:setPosition(cc.p(card:getSize().width * scale * (i - 1) + card:getSize().width * scale / 2, height / 2))

		bird_card_plane:addChild(card)
	end
end

function RoundEndingLayer:showPlayerCards(progCards, handCards, cardPlane, huCard)

	dump(handCards, "test 0508")

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

			card:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

			cardPlane:addChild(card)

			oriX = oriX + size.width
		end

		oriX = oriX + 20
	end

	for i=1,handCount do
		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, handCards[i])

		local size = card:getSize()

		card:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		cardPlane:addChild(card)

		oriX = oriX + size.width
	end

	if huCard and huCard > 0 then
		--todo
		oriX = oriX + 20

		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, huCard)

		local size = card:getSize()

		card:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

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

return RoundEndingLayer
