require("hall.record.phz_record.util.Global")
cc.FileUtils:getInstance():addSearchPath(g_342.path1.."/res/plist")
cc.FileUtils:getInstance():addSearchPath(g_342.path1.."/res/sound")
local scheduler = require("framework.scheduler")
local CardConfig = require(g_342.path..".util.CardConfig")
local CardLayer1 = require(g_342.path..".CardLayer1")
local playerView = require(g_342.path..".playerView")
local RecordBaseScene = require("hall.record.RecordBaseScene")
local PHZMainLayer = class("PHZMainLayer", RecordBaseScene)
local USEFUL_MSG = 
{
	optMsg = {
		0x4011, 0x1203, 0x1213, 0x6004, 0x1255, 0x1201, 0x1204, 0x1205, 0x1206, 0x1207
	},
	userInfoMsg = 0x100D,
	sendCardsMsg = 0x1100,
}

function PHZMainLayer:ctor(data, level, roleType)
    self.roleType = roleType
    self.level = level
	self.data = json.decode(data) or {}
	if not self.data.frame then
		return
	end
	self.diPaiCards = {}
    PHZMainLayer.super.ctor(self, data, USEFUL_MSG, level, true)
	self:setNodeEventEnabled(true)
    self.cardConfig_ = CardConfig:new()
	self:initUI()
	self:setData()
    self:bindMsgProc()
	self:loadVideoLayer()
end

function PHZMainLayer:clearData()

end

function PHZMainLayer:onEnter()

end

function PHZMainLayer:onExit()
	if self.delayHandler ~= nil then
		scheduler.unscheduleGlobal(self.delayHandler)
		self.delayHandler = nil
	end
	self:stopUserOpt()
	g_342 = nil
	package.loaded["hall.record.phz_record.util.Global"] = nil
	package.loaded["hall.record.phz_record.PHZMainLayer"] = nil
end

--------------------------------------init UI --------------------------------
function PHZMainLayer:initUI()
	self.m_mainLayer = cc.CSLoader:createNode(g_342.path1.."res/PHZMainLayer.csb")
	self:addChild(self.m_mainLayer)
	
	GameUtils.setNodeNameBindObj(self.m_mainLayer)
	local DESIGN_SCREEN_WIDTH  = 1280
	local DESIGN_SCREEN_HEIGHT = 720
	local SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
	local SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
	self.m_mainLayer:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH, SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
    ccui.Helper:doLayout(self.m_mainLayer)
	self:initCardScene()
	self.players = {}
	for idx=1,g_342.maxSeat do
		local player = self.m_mainLayer["player_"..idx]
		self.players[idx] = playerView.new(player, self.level)
	end
	self.m_mainLayer.dipai_vw:hide()
	if self.roleType == 0 then
		self.m_mainLayer.dipai_vw:onClick(function( event )
			self.m_mainLayer.dipai_vw:hide()
		end)
		self.m_mainLayer.phz_remainCard:onClick(handler(self, self.onClickDiPai))
		self.m_mainLayer.phz_remainCard:setLocalZOrder(99)
		self.m_mainLayer.dipai_vw:setLocalZOrder(99)
	end
	local str = require("hall.familyCircle.GetGameName"):getName(self.level)
	self.m_mainLayer.txt_name:setString(str)
end

function PHZMainLayer:onClickDiPai( )
	if #self.diPaiCards >= 1 then
		local startIdx = self.m_mainLayer.phz_remainCard.txt_dicardnum:getString()
		startIdx = string.gsub(startIdx,"剩余底牌:","")
		startIdx = tonumber(startIdx)
		local endIdx = #self.diPaiCards
		startIdx = endIdx - startIdx
		local len = endIdx - startIdx
		startIdx = startIdx + 1
		local cards = table.slice(self.diPaiCards, startIdx, len)
		if #cards >= 1 then
			self:setDiPaiCards(cards)
			self.m_mainLayer.dipai_vw:show()
		end
	end
end

function PHZMainLayer:setDiPaiCards(cards)
	local cards_vw = self.m_mainLayer.dipai_vw.cards_vw
    cards_vw:removeAllChildren()
    local size = cards_vw:getSize()
	local cardHeight = 111
	local cardWidth = 97
    local scale = 1
    cardHeight = scale * cardHeight
    cardWidth = scale * cardWidth
    local intevalWidth = (cardWidth + 3) * scale
    local intevalHeight = (cardHeight + 3) * scale
    local oriX = cardWidth / 2
    local oriY = size.height - cardHeight / 2
	local row = 7
	for idx,card in ipairs(cards) do
		local rowIdx = idx % row
        rowIdx = rowIdx == 0 and row or rowIdx
        local colIdx = math.ceil(idx/ row)
        local cardData = self.cardConfig_:getCardInfoByid(card)
        local cardNode = ccui.ImageView:create(cardData.CardIconB..".png", 1)
        local x = oriX + (rowIdx - 1) * intevalWidth
        local y = oriY - (colIdx - 1) * intevalHeight
        cardNode:setPosition(cc.p(x, y))
        cardNode:setScale(scale)
        cards_vw:addChild(cardNode)
        cardNode.card = card
	end
end

function PHZMainLayer:setDicardNum( num )
	self.m_mainLayer.phz_remainCard.txt_dicardnum:setString("剩余底牌:"..num)
end

function PHZMainLayer:getSelfSeatId( userInfos )
	g_342.user_views = {}
	self.mySeatId = 1
	for idx,userInfo in ipairs(userInfos) do
		if userInfo.uid == USER_INFO.uid  then
			self.mySeatId = userInfo.seatID + 1
		end
	end
	if self.mySeatId == 1 then
		for idx,userInfo in ipairs(userInfos) do
			local uid = userInfo.uid
			local seatID = userInfo.seatID + 1
			g_342.user_views[uid] = seatID
			g_342.user_views[seatID - 1] = g_342.user_views[uid]
		end
	else
		local maxSeat = g_342.maxSeat
		-- local num = self.mySeatId - 1
		local interval = math.abs(4 - self.mySeatId + 1)
		-- local num = 
		for idx,userInfo in ipairs(userInfos) do

			local uid = userInfo.uid
			local seatID = userInfo.seatID + 1
			g_342.user_views[uid] = (seatID + interval) % maxSeat
			if g_342.user_views[uid] == 0 then
				g_342.user_views[uid] = maxSeat
			end

			g_342.user_views[userInfo.seatID] = g_342.user_views[uid]
		end
	end
	
	dump(g_342.user_views)
end

function PHZMainLayer:getViewChairId(seatID)
    local viewId = 0
    local viewId = g_342.user_views[seatID]
    return viewId
end
 
function PHZMainLayer:setData()
	local data = self.data
	local settlements = data.settlements or {}
	local tab = {}
	for idx,value in ipairs(settlements) do
		tab[value.uid] = value
	end
	local seat_id = 2
	local selfUserInfo
	self.diPaiCards = string.split(data.diPai,",") or {}
	for idx,card in ipairs(self.diPaiCards) do
		self.diPaiCards[idx] = tonumber(card)
	end
	self:setDicardNum( #self.diPaiCards )
	self:getSelfSeatId( data.userinfos )
	for idx,userInfo in ipairs(data.userinfos) do
		local itemdata = userInfo
		local settlement = tab[userInfo.uid] or {}
		itemdata.score = settlement.turnBlc or 0
		local viewId = g_342.user_views[itemdata.uid]
		local cards = string.split(userInfo.cards,",")
		for idx,card in ipairs(cards) do
			cards[idx] = tonumber(card)
		end
		self.CardLayer1:setCurHandCard(cards, viewId)
		self.players[viewId]:setData(itemdata)
		if userInfo.uid == USER_INFO.uid then
			selfUserInfo = userInfo
		end
	end
	-- local cards = string.split(selfUserInfo.cards,",")
	-- for idx,card in ipairs(cards) do
	-- 	cards[idx] = tonumber(card)
	-- end
	-- self.CardLayer1:setCurHandCard(cards, viewId)
end

function PHZMainLayer:showGameConfig(gameConfigtbl)
end

--初始化牌层
function PHZMainLayer:initCardScene()
	self.CardLayer1 = CardLayer1.new(self, self.level)
    self.m_mainLayer:addChild(self.CardLayer1)
end

function PHZMainLayer:loadVideoLayer()
    self._videoOptLayer = require("hall.record.RecordOptLayer").new(self)
	self._videoOptLayer:addTo(self.m_mainLayer)
	self._videoOptLayer._csbNode:setOpacity(120)
end

function PHZMainLayer:getHeadPosByID(viewId)
	local index = viewId
	local pos = self.players[index]:getPosition()
	return pos.x, pos.y
end

function PHZMainLayer:getSendCardPos()
	return self.m_mainLayer.phz_remainCard:getPosition()
end

function PHZMainLayer:bindMsgProc()
	-- 0x1255  argv1:SeatID, argv2:偎的牌
	-- 0x4011  uid:椅子ID，argv1~argv4分别为底牌数，type,card,if_draw
	-- 0x1213 cards：比的牌，argv1:SeatID, argv2:card
	-- 0x6004  argv1:人数，argv2~argv4:分别对应0~3椅子上的分点

	-- 0x1201  argv1:SeatID, argv2:出的牌
	-- 0x1203 argv1:底牌数，argv2:SeatID, argv3~argv5为吃的牌
	-- 0x1204  argv1:底牌数，argv2:SeatID, argv3:碰的牌
	-- 0x1205  argv1:底牌数，argv2:SeatID, argv3:跑的牌
	-- 0x1206  argv1:底牌数，argv2:SeatID, argv3:提的牌
	-- 0x1207  argv1:底牌数，argv2:SeatID, argv3:偎的类型
	-- 0x1210  argv1:底牌数，argv2:SeatID, argv3:玩家飘牌
	-- 0x1211  argv1:底牌数，argv2:SeatID, argv3:玩家溜牌

	-- 0x1208 uid:UserID,-1表示黄庄
	-- argv4:提的牌
	self.func_ = {
		[0x4011] = {handler(self, self.SVR_BUPAI_DEAL)},--补牌或者派发单张
		[0x1203] = {handler(self, self.SVR_PLAYER_CHI_CARD)},--玩家吃牌
		[0x1213] = {handler(self, self.SVR_PLAYER_BI_CARD)},--玩家比牌
		[0x6004] = {handler(self, self.SVR_USER_FENPOINT)},--广播用户的分点
		
		[0x1255] = {handler(self, self.SVR_PLAYER_FIRSTWEI_CARD)},--玩家首偎
		[0x1201] = {handler(self, self.SVR_PLAYER_CHU_CARD)},--玩家出牌
		[0x1204] = {handler(self, self.SVR_PLAYER_PENG_CARD)},--碰的牌
		[0x1205] = {handler(self, self.SVR_PLAYER_PAO_CARD)},--跑的牌
		[0x1206] = {handler(self, self.SVR_PLAYER_TI_CARD)},--提的牌
		[0x1207] = {handler(self, self.SVR_PLAYER_WEI_CARD)},--偎的类型 歪
		[0x1208] = {handler(self, self.SVR_PLAYER_HU_CARD)},--玩家胡牌
		[0x1210] = {handler(self, self.SVR_PLAYER_PIAO_CARD)},--玩家飘牌
		[0x1211] = {handler(self, self.SVR_PLAYER_LIU_CARD)},--玩家溜牌
	}
end

function PHZMainLayer:callFunc(pack)
    if self.func_[pack.type] and self.func_[pack.type][1] then
        self.func_[pack.type][1](pack)
    end
end

function PHZMainLayer:SVR_BUPAI_DEAL( pack )
	-- 0x4011  uid:椅子ID，argv1~argv4分别为 底牌数，type,card,if_draw
	dump(pack,"补牌或者派发单张")
   	--补牌或者派发单张
	self.CardLayer1:hideDealCard()
	local seatId = pack.uid
	self.m_diCardCount = pack.diPaiCount
	self:setDicardNum(pack.argv1)
	local viewId = self:getViewChairId(seatId)
	self.m_newDiCard = pack.argv3
	for i=1,g_342.maxSeat do
		self.players[i]:hideFontType()
	end
	if pack.argv4 == 1  then
		self.CardLayer1:supplyCard(viewId,pack.argv3, pack.argv2)
	else
		if pack.argv2 == 1 then
			self.CardLayer1:supplyCard(viewId,pack.argv3, pack.argv2)
			return
		end
		local cardInfo = self.cardConfig_:getCardInfoByid(pack.argv3)
		if cardInfo then
			require("hall.GameCommon"):playEffectSound(cardInfo.Mousic)
		end
		self:OnSubSendCard(seatId, pack.argv3)
	end
	
end

function PHZMainLayer:OnSubSendCard(seat_id,card_value)
    if self.m_cbOutCardData ~= 0 then
		local wDisViewId = self:getViewChairId(self.m_wOutCardUser)
        self.CardLayer1:onDiscardCard(wDisViewId, self.m_cbOutCardData)
	end
	self.m_wOutCardUser = seat_id
    self.m_cbOutCardData = card_value
	self.m_cbCurrentCard = card_value
    local viewId = self:getViewChairId(seat_id)
	self.CardLayer1:sendCard(viewId,card_value,1)

end

function PHZMainLayer:SVR_PLAYER_CHI_CARD( pack )
	-- 0x1203 argv1:底牌数，argv2:SeatID, argv3~argv5为吃的牌
	dump(pack)
    require("hall.GameCommon"):playEffectSound(g_342.path1.."res/sound/chi.mp3")
	local viewId = self:getViewChairId(pack.argv2)
	self.players[viewId]:setFontType("吃")

	if self.m_wOutCardUser ~= INVALID_CHAIR then
        local wResViewId = self:getViewChairId(self.m_wOutCardUser)
		self.CardLayer1.m_OutSprite[wResViewId]:setVisible(false)
	end

	local cards = {}
	table.insert(cards, pack.argv3)
	table.insert(cards, pack.argv4)
	table.insert(cards, pack.argv5)
    self.CardLayer1:onChiCard(viewId, cards)
	self:setDicardNum(pack.argv1)
end

function PHZMainLayer:SVR_PLAYER_BI_CARD( pack )
	-- 0x1213 cards：比的牌，argv1:SeatID, argv2:card
	dump(pack)
	local viewId = self:getViewChairId(pack.argv1)
    local cards = string.split(pack.cards,",")
	for idx,card in ipairs(cards) do
		cards[idx] = tonumber(card)
	end
	self.CardLayer1:onBiCard(viewId, cards, pack.argv2)
end

function PHZMainLayer:SVR_USER_FENPOINT( pack )
	-- 0x6004  argv1:人数，argv2~argv4:分别对应0~3椅子上的分点
	dump(pack)
	for seatId = 0, pack.argv1 - 1 do
		local fen = pack["argv"..seatId + 2]
		local viewId = self:getViewChairId(seatId)
		self.players[viewId]:setHuXi(fen)
	end
end

function PHZMainLayer:SVR_PLAYER_FIRSTWEI_CARD( pack )
	-- 0x1255  argv1:SeatID, argv2:偎的牌
	dump(pack)
	local seatId = pack.argv1
	local viewId = self:getViewChairId(seatId)
    require("hall.GameCommon"):playEffectSound(g_342.path1.."res/sound/wei.mp3")
	self.CardLayer1:onFirstSaoCard( viewId, pack.argv2 )
	local str = "偎"
	if self.level == 379 then
		str = "歪"
	end
	self.players[viewId]:setFontType(str)
	self.CardLayer1:hideDealCard()
end
	

function PHZMainLayer:SVR_PLAYER_CHU_CARD( pack )
	-- 0x1201  argv1:SeatID, argv2:出的牌
	dump(pack,"玩家出牌-----")
	local viewId = g_342.user_views[pack.argv1]
	local data = {
		seatID = pack.argv1,
		card = pack.argv2,
	}
	self.CardLayer1:hideDealCard()
	self:OnSubOutCard(data)
	local cardInfo = self.cardConfig_:getCardInfoByid(pack.argv2)
    if cardInfo then
		require("hall.GameCommon"):playEffectSound(cardInfo.Mousic)
	end
	for i=1,g_342.maxSeat do
		self.players[i]:hideFontType()
	end
end

function PHZMainLayer:SVR_PLAYER_PENG_CARD( pack )
	dump(pack)
	-- 0x1204  argv1:底牌数，argv2:SeatID, argv3:碰的牌
	require("hall.GameCommon"):playEffectSound(g_342.path1.."res/sound/peng.mp3")
	local data = {
		seatID = pack.argv2,
		card = pack.argv3,
	}
	local viewId = self:getViewChairId(data.seatID)
	self.players[viewId]:setFontType("碰")

	local viewId = g_342.user_views[pack.argv2]
    self:OnSubPengCard( data)
    self:setDicardNum(pack.argv1)
end

function PHZMainLayer:OnSubPengCard(data)
    local viewId = self:getViewChairId(data.seatID)
    self.CardLayer1:onPengCard(viewId, data.card)
end

function PHZMainLayer:SVR_PLAYER_PAO_CARD( pack )
	-- 0x1205  argv1:底牌数，argv2:SeatID, argv3:跑的牌
	dump(pack)
    require("hall.GameCommon"):playEffectSound(g_342.path1.."res/sound/pao.mp3")
	self.m_newDiCard = nil
	local data = {
		seatID = pack.argv2,
		card = pack.argv3,
	}
	local viewId = self:getViewChairId(data.seatID)
	self.players[viewId]:setFontType("跑")
	self:OnSubSaoExCard(data)
	print("===关闭玩家出的牌=385==")
	self.CardLayer1:hideDealCard()
	self.m_cbOutCardData = 0
    self:setDicardNum(pack.argv1)
end

function PHZMainLayer:SVR_PLAYER_TI_CARD( pack )
	-- 0x1206  argv1:底牌数，argv2:SeatID, argv3:提的牌
	dump(pack)
    require("hall.GameCommon"):playEffectSound(g_342.path1.."res/sound/ti.mp3")
    self.m_newDiCard = nil
    if pack.argv3 == self.m_cbOutCardData then
        self.m_cbOutCardData = 0
	end
	local viewId = self:getViewChairId(pack.argv2)
	self.players[viewId]:setFontType("提")
	-- self.CardLayer1:removeBuCardNode( pack.argv3 )
	self.CardLayer1:onSaoExCard(viewId, pack.argv3, 4, false)
	self.CardLayer1:hideDealCard()
    self:setDicardNum(pack.argv1)
end

function PHZMainLayer:SVR_PLAYER_WEI_CARD( pack )
	-- 0x1207  argv1:底牌数，argv2:SeatID, argv3:偎的类型
	dump(pack)
	pack.cardType = 0
    self.m_newDiCard = nil
    self.m_cbOutCardData = 0
    self:OnSubSendCardWei()
    require("hall.GameCommon"):playEffectSound(g_342.path1.."res/sound/wei.mp3")
	local data = {
		seatID = pack.argv2,
		card = pack.argv4,
		cardType = pack.argv3,
	}
	
	self:OnSubSaoCard(data)
	for i=1,g_342.maxSeat do
		self.CardLayer1.m_OutSprite[i]:setVisible(false)
	end
	local viewId = self:getViewChairId(pack.argv2)
	local str = "偎"
	if self.level == 379 then
		str = "歪"
	end
	self.players[viewId]:setFontType(str)
    self:setDicardNum(pack.argv1)
end

function PHZMainLayer:SVR_PLAYER_PIAO_CARD( pack )
	-- 0x1207  argv1:底牌数，argv2:SeatID, argv3:偎的类型
	pack.cardType = 0
    self.m_newDiCard = nil
    self.m_cbOutCardData = 0
    require("hall.GameCommon"):playEffectSound(g_342.path1.."res/sound/wei.mp3")
	local data = {
		seatID = pack.argv2,
		card = pack.argv3,
	}
	
	self:onPiaoCard(data)
	for i=1,g_342.maxSeat do
		self.CardLayer1.m_OutSprite[i]:setVisible(false)
	end
	local viewId = self:getViewChairId(pack.argv2)
	self.players[viewId]:setFontType("飘")
	


    print("===关闭玩家出的牌=385==")
    
end

--玩家溜牌
function PHZMainLayer:SVR_PLAYER_LIU_CARD(pack)
	-- 0x1211  argv1:底牌数，argv2:SeatID, argv3:提的牌
    self.m_cbCurrentCard = 0
	local viewId = self:getViewChairId(pack.argv2)
    if self.m_wOutCardUser ~= INVALID_CHAIR then
        local wResViewId = self:getViewChairId(self.m_wOutCardUser)
        self.CardLayer1:onEventCard(viewId,wResViewId)
    end
	self.CardLayer1:onLiuCard(viewId, pack.argv3)
	self.players[viewId]:setFontType("溜")
end


function PHZMainLayer:onPiaoCard(data)
    local viewId = self:getViewChairId(data.seatID)
    if self.m_wOutCardUser~=INVALID_CHAIR then
        local wResViewId = self:getViewChairId(self.m_wOutCardUser)
        self.CardLayer1:onEventCard(viewId,wResViewId)
    end
    self.CardLayer1:onPiaoCard(viewId, data.card)
end 

function PHZMainLayer:OnSubSendCardWei()
    if self.m_cbOutCardData ~= 0 then
        if self.m_wOutCardUser == INVALID_CHAIR then self.m_wOutCardUser = 0 end
        local wDisViewId = self:getViewChairId(self.m_wOutCardUser)
        --print("====m_cbOutCardData",wDisViewId,self.m_cbOutCardData)
        self.CardLayer1:onDiscardCard(wDisViewId,self.m_cbOutCardData)
    end
end

function PHZMainLayer:OnSubSaoCard(data)
    local viewId = self:getViewChairId(data.seatID)
    if self.m_wOutCardUser~=INVALID_CHAIR then
        local wResViewId = self:getViewChairId(self.m_wOutCardUser)
        self.CardLayer1:onEventCard(viewId,wResViewId)
    end
    self.CardLayer1:onSaoCard(viewId, data.card, data.cardType)
end 

function PHZMainLayer:SVR_PLAYER_HU_CARD( pack )
	--0x1208 uid:UserID,-1表示黄庄
	dump(pack)
	local winUid = pack.uid
    local viewId = self:getViewChairId(winUid)
	if viewId then
		self.players[viewId]:setFontType("胡")
	end
end

function PHZMainLayer:OnSubOutCard(data)
    self.m_wOutCardUser = data.seatID
    self.m_cbOutCardData = data.card
    self.m_cbCurrentCard = data.card
    local viewId = self:getViewChairId(self.m_wOutCardUser)
    self.CardLayer1:playerOutCard(viewId,self.m_cbOutCardData)
end

function PHZMainLayer:OnSubSaoExCard(data)
    local viewId = self:getViewChairId(data.seatID)
    if self.m_wOutCardUser~=INVALID_CHAIR then
        local wResViewId = self:getViewChairId(self.m_wOutCardUser)
        self.CardLayer1:onEventCard(viewId,wResViewId)
    end
    self.CardLayer1:onSaoExCard(viewId, data.card, 4, true)
end

return PHZMainLayer