local Card = require(TpackageName..".card.card")
local sendHandle = require(TpackageName..".handle.ZZMJSendHandle")
local cardUtils = require(TpackageName..".utils.cardUtils")
local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")

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

local isShow = false
local zhongbirdCount

local searchPath = TpackageName.."/res/image/"

function RoundEndingLayer:showZhuaniao(data, isEnd)
	dump(data, "---- showZhuaniao-----")

	win_lose_table = {}

	for k,v in pairs(data.players) do
		local player = v
		-- if player.huTypeCount > 0 then
		-- 	--todo
		-- 	win_lose_table[k - 1] = "Y"
		-- else
		-- 	win_lose_table[k - 1] = "N"
		-- end
	end

	local cards_tb1 = {}
	local zhongcard = {}
	local count = table.getn(data.birdCards)
	for i=1,count do
		table.insert(cards_tb1, data.birdCards[i])
	end
     

	local timeDelay = require(TpackageName..".result_effect_layout"):reset_niaocard_data(cards_tb1, zhongcard)
--[[	if timeDelay == 0 then

		timeDelay = 1
	else
		timeDelay = timeDelay + 1
	end--]]
    if isShowRecord then
        timeDelay = 0
    else
        timeDelay = 5
    end


	local zhuaniaoLayout = SCENENOW["scene"]:getChildByName("zhuaniaoLayout")
	if zhuaniaoLayout then

		local callFuncAc = cc.CallFunc:create(function ()
				zhuaniaoLayout:removeFromParent()
				if isShowRecord then
					self:show(data, false)
				else
					self:showNew(data, isEnd)
				end

			end)

		zhuaniaoLayout:runAction(cc.Sequence:create(cc.DelayTime:create(timeDelay), callFuncAc))
	end
end

function RoundEndingLayer:showNew(pack, isEnd)
    for i=1,table.getn(pack.players) do
	    local info =  pack.players[i]
	    local seat_id = info.seat_id
	    local playerType = cardUtils:getPlayerType(seat_id)

	    if ZZMJ_USERINFO_TABLE[seat_id] then
		    local oldChips = ZZMJ_USERINFO_TABLE[seat_id].coins
		    local newChips =  info.coins
		    dump(oldChips, "---- oldChips")
		    dump(info.changeCoins, "------ changeCoins")
		    dump(newChips, "---- newChips")

		    ZZMJ_USERINFO_TABLE[seat_id].coins = newChips
		    ZZMJ_PLAYERS_INFOS[info.uid].coins = newChips


		    GamePlaneOperator:updateRoundResult(playerType, info.changeCoins)

		    GamePlaneOperator:updateUserCoins(playerType, newChips)

		    if isGoldGame == 0 then
		        local dict = {}
		        dict.uid = info.uid
		        dict.gold = newChips
		        require("hall.view.userInfoView.userInfoView"):upDateUserInfo(dict.uid, dict, "gold")
		    end
		end
	end

	local btn_ready = SCENENOW['scene']._hall:getChildByName("btn_ready")
	if btn_ready then
		btn_ready:setVisible(true)
	end

	if not isEnd then
		SCENENOW['scene']:showBtnByUserStatus("sit")
	else
		self:show(pack, isEnd)
	end

end

function RoundEndingLayer:show(data, isEnd)
	isShow = true
	local isEndT = isEnd or false

	win_lose_table = {}

    local RoundResultCsb_filePath = RoundResultCsb_filePath or TpackageName.."/res/roundEndingLayer.csb"
	self._scene = cc.CSLoader:createNode(RoundResultCsb_filePath)
	-- self._scene:setScale(0.75)

	self.floor = self._scene:getChildByName(CHILD_NAME_FLOOR)
	self.showPlane = self.floor:getChildByName(CHILD_NAME_SHOW_PLANE)

	local Text_13 = self.floor:getChildByName("Text_13")
     
    Text_13:setString("抓鸟")

	local endType = data.type --流局与否控制字段
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
		if data.bankerId == players[i].uid then
			--todo
			isZhuang = true
		end

		-- self:dealPlayerCards(players[i].remainCards, players[i].huCard, players[i].huTypeCount)
		self:showPlayerPlane(players[i], i, isZhuang)

		if players[i].uid == USER_INFO["uid"] then
			--todo
			me = players[i]
		end
	end

	local titleType = TITLE_TYPE_LIUJU
	if endType ~= 0 and me then
		if me.changeCoins > 0 then
			titleType = TITLE_TYPE_WIN
		else
			titleType = TITLE_TYPE_LOSE
		end
	end

	self:showTitle(titleType)

	self:showBirdCards(data.birdCards,{})

	for i=1,table.getn(players) do
		self:showEndingInfo(players[i], i)
	end
    
    local current_time = os.time()
	local timeStr = os.date("%Y-%m-%d %H:%M:%S",data["time"]+current_time)
	self:showGameRemark(timeStr)

	local start_bt = self.floor:getChildByName(CHILD_NAME_START_BT)

	if start_bt then
		--todo
		local function bt_callback(sender, event)
			if event == TOUCH_EVENT_ENDED then
				--todo
			   --sendHandle:readyNow()
               -- sendHandle:LoginGame(USER_INFO["GroupLevel"])
               self._scene:removeFromParent()
				isShow = false
                isShowRecord = false
                ZZMJ_ENDING_DATA = nil
				dump("关闭2")
			end
		end

		start_bt:addTouchEventListener(bt_callback)

		if isEndT then
			--todo
			start_bt:setVisible(false)
		else
			start_bt:setVisible(true)
		end
	end

	local close_bt = self.floor:getChildByName(CHILD_NAME_CLOSE_BT)

	if close_bt then
		--todo
		local function bt_callback(sender, event)
			if event == TOUCH_EVENT_ENDED then
				--todo
				self._scene:removeFromParent()

				if ZZMJ_GROUP_ENDING_DATA then
					--todo
					require(TpackageName..".GroupEndingLayer"):showGroupResult(ZZMJ_GROUP_ENDING_DATA)
				end
				dump("关闭1")
				isShow = false
				isShowRecord = false
                ZZMJ_ENDING_DATA = nil
			end
		end

		close_bt:addTouchEventListener(bt_callback)

		if isEndT then
			--todo
			close_bt:setVisible(true)
		else
			close_bt:setVisible(false)
		end
	end

	local jiesan_bt = self.floor:getChildByName(CHILD_NAME_JIESAN_BT)

	if jiesan_bt then
		--todo
		local function bt_callback(sender, event)
			if event == TOUCH_EVENT_ENDED then
				--todo
				SCENENOW["scene"]:disbandGroup()

			end
		end

		jiesan_bt:addTouchEventListener(bt_callback)

		if isEndT then
			--todo
			jiesan_bt:setVisible(false)
		else
			jiesan_bt:setVisible(true)
		end
	end
	
	local txt_start_game = start_bt:getChildByName("Text_1")
	if isShowRecord then
       	txt_start_game:setString("返回游戏")
        jiesan_bt:setVisible(false)
    else
        txt_start_game:setString("开始游戏")
        -- jiesan_bt:setVisible(true)
        jiesan_bt:setVisible(false)
    end
    jiesan_bt:setVisible(false)
	-- self._scene:setName("roundEndingLayer")
	-- SCENENOW["scene"]:addChild(self._scene)

	self._scene:setName("roundEndingLayer")
	self._scene:setVisible(true)
	local precent = self:_getScaleParam2()
	self._scene:setScaleX(self._scene:getScaleX()*precent)
	SCENENOW["scene"]:addChild(self._scene)
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

function RoundEndingLayer:showPlayerPlane(player, index, isZhuang)
	local playerPlaneName = "player" .. index .. "_plane"
	local playerPlane = self.showPlane:getChildByName(playerPlaneName)
	playerPlane:setVisible(true)
	local zhuang_signal = playerPlane:getChildByName(CHILD_NAME_ZHUANG_SIGNAL)
	zhuang_signal:setVisible(isZhuang)
    
	local hu_signal = playerPlane:getChildByName(CHILD_NAME_HU_SIGNAL)
    
    local huCard
    if player.hucontent then 
	    if player.hucontent[1].hutype==1 then     --平胡 
		      huCard = player.hucontent[1].pinghu[1].huCard
		      --self:dealPlayerCards(player.remainCards, huCard)
		elseif  player.hucontent[1].hutype==2 then    --自摸
		      huCard = player.hucontent[1].zimo[1].huCard	    
		      --self:dealPlayerCards(player.remainCards, huCard)
		end
    end
    
   
	if player.changeCoins > 0 then
		--todo
		win_lose_table[index - 1] = "Y"
	elseif player.changeCoins == 0 then
		win_lose_table[index - 1] = "N"
	else
		win_lose_table[index - 1] = "Y"
	end

	if player.ifhu == 1 then
		hu_signal:setVisible(true)
	else
		hu_signal:setVisible(false)
	end

	local score_lb = playerPlane:getChildByName(CHILD_NAME_SCORE_LB)
	score_lb:setString("" .. player.changeCoins/100)

	--local seatId = ZZMJ_SEAT_TABLE[player.uid ]

	local nickname = player.nick
	-- .." - ".. player.uid

	local nick_lb = playerPlane:getChildByName(CHILD_NAME_NICK_LB)

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

	-- local p = nil
	-- local cs = nil
	-- for i=1,player.cCount do
	-- 	if i % 3 == 1 then
	-- 		--todo
	-- 		p = {}
	-- 		p.type = "c"
	-- 		cs = {}
	-- 		p.cards = cs
	-- 		table.insert(cs, player.cCards[i])
	-- 	elseif i % 3 == 0 then
	-- 		table.insert(cs, player.cCards[i])

	-- 		table.insert(progCards, p)
	-- 	else
	-- 		table.insert(cs, player.cCards[i])
	-- 	end
	-- end

	if player.ifhu==1  then
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

	if player.ifpao == 1 then
		endingInfo = endingInfo .. "点炮 ".." "
	end
    
    --dump(ifhu,"是否胡牌")
    if player.ifhu == 1 then
    	if zhongbirdCount and zhongbirdCount > 0 then
			endingInfo = endingInfo .. "中" .. zhongbirdCount .. "鸟".." "
	    end

		if player.hucontent[1].hutype  == 1 then
			endingInfo = endingInfo .. "接炮 ".." "
			if   player.hucontent[1].pinghu[1].ifgangpao == 1 then 
			     endingInfo = endingInfo .. "杠上炮".." "
			elseif player.hucontent[1].pinghu[1].ifqiangganghu ==1 then
			     endingInfo = endingInfo .. "抢杠胡 ".."x2 "
			end
		elseif player.hucontent[1].hutype == 2 then
			endingInfo = endingInfo .. "自摸".." "
			if player.hucontent[1].zimo[1].ifgangshanghua== 1 then
			     endingInfo = endingInfo .. "杠上花".."x2 "
			end
		end
	end
	
	if player.dgCount and player.dgCount > 0 then
		--todo
		endingInfo = endingInfo .. "点杠x" .. player.dgCount .. " "
	end
	-- if player.gCount-player.bgCount and player.bgCount > 0 then
	-- 	--todo
	-- 	endingInfo = endingInfo .. "接杠x" .. (player.gCount-player.bgCount) .. " "
	-- end
	if player.pgCount and player.pgCount > 0 then
		--todo
		endingInfo = endingInfo .. "接杠x" .. player.pgCount .. " "
	end
	if player.bgCount and player.bgCount > 0 then
		--todo
		endingInfo = endingInfo .. "明杠x" .. player.bgCount .. " "
	end
	if player.agCount and player.agCount > 0 then
		--todo
		endingInfo = endingInfo .. "暗杠x" .. player.agCount .. " "
	end


	desc_lb:setString(endingInfo)
	desc_lb:setPositionX(desc_lb:getPosition().x+60)
end

function RoundEndingLayer:showTitle(titleType)
	-- local title_bg_img = self.floor:getChildByName(CHILD_NAME_TITLE_BG_IMG)
	local title_txt = self.showPlane:getChildByName("title_txt")

	if titleType == TITLE_TYPE_WIN then
		-- --todo
		title_txt:setString("胜局")
		self.showPlane:loadTexture(searchPath.."bottom_win.png")
		-- title_bg_img:loadTexture("gd_majiang_3d/res/image/red_button_p.png")
		-- title_img:loadTexture("gd_majiang_3d/res/image/mahjong_win.png")
	elseif titleType == TITLE_TYPE_LOSE then
		title_txt:setString("败局")
		self.showPlane:loadTexture(searchPath.."bottom_lose.png")
		-- title_bg_img:loadTexture("gd_majiang_3d/res/image/mahjong_lose_bt.png")
		-- title_img:loadTexture("gd_majiang_3d/res/image/mahjong_lose.png")
	else
		title_txt:setString("流局")
		self.showPlane:loadTexture(searchPath.."bottom_lose.png")
		-- title_bg_img:loadTexture("gd_majiang_3d/res/image/grey_button.png")
		-- title_img:loadTexture("gd_majiang_3d/res/image/text_liuju.png")
	end
end

function RoundEndingLayer:showGameRemark(timeStr)
	local room_lb = self.floor:getChildByName(CHILD_NAME_ROOM_LB)
	local bird_lb = self.floor:getChildByName(CHILD_NAME_BIRD_LB)
	local time_lb = self.floor:getChildByName(CHILD_NAME_TIME_LB)

	room_lb:setString("房号" .. USER_INFO["invote_code"])
	-- bird_lb:setString("抓2鸟")
	if USER_INFO["gameConfig"] then
		--todo
		bird_lb:setString(GameName .. "：" .. USER_INFO["gameConfig"])
	else
		bird_lb:setString("正在读取组局信息")
	end
	time_lb:setString(timeStr)
end

function RoundEndingLayer:showBirdCards(cards,zhongcard)
	if not cards then
		--todo
		return
	end


end

function RoundEndingLayer:showPlayerCards(progCards, handCards, cardPlane, huCard)

	dump(handCards, "-----handCards-----")

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

	local flag = true
	for i=1,handCount do
		if huCard and flag and handCards[i] == huCard then
			flag = false
		else
			local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, handCards[i])
	
			local size = card:getSize()
	
			card:setPosition(cc.p(oriX + size.width / 2, size.height / 2))
	
			cardPlane:addChild(card)
	
			oriX = oriX + size.width
		end
	end

	if huCard then
		--todo
		oriX = oriX + 20

		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, huCard)

		local size = card:getSize()

		card:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		cardPlane:addChild(card)
	end
end


function RoundEndingLayer:dealPlayerCards(cards, huCard)
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