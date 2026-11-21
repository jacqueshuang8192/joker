local RecordBaseScene = require("hall.record.RecordBaseScene")
local GameSceneView = require("hall.record.xupuphz.GameSceneView")
local gameScene = class("gameScene", RecordBaseScene)
local CardUtils = require("xupuphz.src.CardUtils")
local Config = require("xupuphz.src.Config")
local SoundUtils = import("xupuphz.src.SoundUtils")

function gameScene:ctor(data, level, roleType)
    self.roleType = roleType
    self.level = level
	self.data = json.decode(data) or {}
	if not self.data.frame then
		return
	end
    self.Config = Config.new()
	self.GameSceneView = GameSceneView.new():addTo(self)
	self.diPaiCards = {}
    gameScene.super.ctor(self, data, {}, level, true)
	self:setNodeEventEnabled(true)
	self:setData()
    self:bindMsgProc()
	self:loadVideoLayer()
end

function gameScene:onExit()
	self:stopUserOpt()
	self.Config:onExit()
end

--------------------------------------init UI --------------------------------
 
function gameScene:setData()
	local data = self.data
	dump(data)
	local settlements = data.settlements or {}
	local tab = {}
	for idx,value in ipairs(settlements) do
		tab[value.uid] = value
	end
	g_392.TOTAL_PLAYERNUM = #data.userinfos
	for idx,userInfo in ipairs(data.userinfos) do
		if userInfo.uid == USER_INFO.uid then
			g_392.my_seat_id = userInfo.seatID
		end
	end
	self.diPaiCards = gameScene:getTabCards( data.diPai )
	for idx,userInfo in ipairs(data.userinfos) do
		local uid = userInfo.uid
		local seatID = userInfo.seatID
		local viewId = self:getViewIdBySeatId(seatID)
		self.Config:addUser( uid, seatID, viewId, userInfo )

		local UserInfoView = self:getPlayerBySeatId( seatID )
		local settlement = tab[userInfo.uid] or {}
		userInfo.score = settlement.turnBlc or 0
		UserInfoView:setData(userInfo)

		local cards = string.split(userInfo.cards,",")
		for idx,card in ipairs(cards) do
			cards[idx] = tonumber(card)
		end
		UserInfoView:setCurHandCards(cards)
	end
	
end

function gameScene:loadVideoLayer()
    self._videoOptLayer = require("hall.record.RecordOptLayer").new(self)
	self._videoOptLayer:addTo(self)
	self._videoOptLayer._csbNode:setOpacity(120)
end

function gameScene:bindMsgProc()
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
		
		[0x1201] = {handler(self, self.SVR_PLAYER_CHU_CARD)},--玩家出牌
		[0x1204] = {handler(self, self.SVR_PLAYER_PENG_CARD)},--碰的牌
		[0x1205] = {handler(self, self.SVR_PLAYER_PAO_CARD)},--跑的牌
		[0x1206] = {handler(self, self.SVR_PLAYER_TI_CARD)},--提的牌
		[0x1207] = {handler(self, self.SVR_PLAYER_WEI_CARD)},--偎的类型 歪
		[0x1208] = {handler(self, self.SVR_PLAYER_HU_CARD)},--玩家胡牌
		[0x1210] = {handler(self, self.SVR_PLAYER_PIAO_CARD)},--玩家飘牌
		[0x1211] = {handler(self, self.SVR_PLAYER_GUCHOU)},--广播用户箍臭
	}
end

function gameScene:callFunc(pack)
    if self.func_[pack.type] and self.func_[pack.type][1] then
        self.func_[pack.type][1](pack)
    end
end

function gameScene:SVR_BUPAI_DEAL( pack )
	-- 0x4011  uid:椅子ID，argv1~argv4分别为 底牌数，type,card,if_draw
	dumpW(pack,"补牌或者派发单张")
	self.GameSceneView:hideAllPlayerOutCard()
    local seat_id = pack.uid
    local CardValue = pack.argv3
    local UserInfoView = self:getPlayerBySeatId(seat_id)
    if (pack.argv4 == 1 or pack.card_from == 1 ) then--发牌到手里
        local card = CardValue 
        local viewId = g_392.viewIds[seat_id] or 0 
        UserInfoView:addHandCard( CardValue )
        self.GameSceneView:sendCard( viewId, card )
    else
        UserInfoView:isShowOutCard(true, CardValue)
        SoundUtils:SoundCard(CardValue, seat_id)
        local perOutCard = g_392.curOutCard
        local perOutSeat = g_392.curOutSeat
        if perOutSeat and perOutCard then
            local UserInfoView = self:getPlayerBySeatId( perOutSeat )
            UserInfoView:showOutCard(perOutCard)
		end
		g_392.curOutCard = CardValue --当前
    	g_392.curOutSeat = seat_id --当前
    end
	self.GameSceneView:isShowBackNodeCount( true, pack.argv1 )
end

function gameScene:SVR_PLAYER_CHI_CARD( pack )
	-- 0x1203 argv1:底牌数，argv2:SeatID, argv3~argv5为吃的牌
	dumpW(pack, "0x1203                         --玩家吃牌")
	local cards = self:getTabCards( pack.cards )
    local seat_id = pack.argv2
    SoundUtils:SoundCardType(g_392.t_chi, seat_id)
    self.GameSceneView:hideAllPlayerOutCard()
    local UserInfoView = self:getPlayerBySeatId( seat_id )
	UserInfoView:removeHandCards( clone(cards), g_392.curOutCard )
    UserInfoView:showTypeCards(cards, g_392.t_chi, cards[1])
	UserInfoView:showImgTxt( g_392.t_chi )
    g_392.curOutCard = nil
    g_392.curOutSeat = nil
end

function gameScene:SVR_PLAYER_BI_CARD( pack )
	-- 0x1213 cards：比的牌，argv1:SeatID, argv2:card
	dumpW(pack, "0x1213                         --玩家比牌")
    local seat_id = pack.argv1
	local cards = self:getTabCards( pack.cards )
    SoundUtils:SoundCardType(g_392.t_chi, seat_id)
    self.GameSceneView:hideAllPlayerOutCard()
    local UserInfoView = self:getPlayerBySeatId( seat_id )
	UserInfoView:removeHandCards( clone(cards))
    self:handCards( UserInfoView, g_392.t_chi, cards, 3, seat_id )
    g_392.curOutCard = nil
    g_392.curOutSeat = nil
end

function gameScene:SVR_PLAYER_CHU_CARD( pack )
	-- 0x1201  argv1:SeatID, argv2:出的牌
	dumpW(pack, "0x1201                         --玩家出牌")
    local seat_id = pack.argv1
    local CardValue = pack.argv2
    local perOutCard = g_392.curOutCard
    local perOutSeat = g_392.curOutSeat
    g_392.curOutCard = CardValue
    g_392.curOutSeat = seat_id
    self.GameSceneView:hideAllPlayerOutCard()
    self.GameSceneView:hideAllPlayerLight()
    local UserInfoView = self:getPlayerBySeatId( seat_id )
	UserInfoView:removeHandCards( {CardValue} )
    UserInfoView:isShowOutCard(true, CardValue)
    SoundUtils:SoundCard(CardValue, seat_id)
    if perOutSeat and perOutCard then
        local UserInfoView = self:getPlayerBySeatId( perOutSeat )
        UserInfoView:showOutCard(perOutCard)
    end
end

function gameScene:SVR_PLAYER_PENG_CARD( pack )
	dumpW(pack)
	-- 0x1204  argv1:底牌数，argv2:SeatID, argv3:碰的牌
	dumpW(pack, "0x1204             --用户碰牌")
    local seat_id = pack.argv2
    local UserInfoView = self:getPlayerBySeatId( seat_id )
	local cards = self:getTabCards( pack.cards )
	UserInfoView:removeHandCards( clone(cards), g_392.curOutCard )
    UserInfoView:showTypeCards(cards, g_392.t_peng, cards[1])
    SoundUtils:SoundCardType(g_392.t_peng, seat_id)
    self.GameSceneView:hideAllPlayerOutCard()
	UserInfoView:showImgTxt( g_392.t_peng )
    g_392.curOutCard = nil
    g_392.curOutSeat = nil
end

function gameScene:SVR_PLAYER_PAO_CARD( pack )
	-- 0x1205  argv1:底牌数，argv2:SeatID, argv3:跑的牌
	dumpW(pack)
    dumpW(pack, "0x1205                         --玩家跑")
    local seat_id = pack.argv2
    SoundUtils:SoundCardType(g_392.t_pao, seat_id)
	local cards = self:getTabCards( pack.cards )
    self.GameSceneView:hideAllPlayerOutCard()
    local UserInfoView = self:getPlayerBySeatId( seat_id )
	UserInfoView:removeHandCards( clone(cards) )
    UserInfoView:showTypeCards(cards, g_392.t_pao, cards[1])
    UserInfoView:isShowOutCard(true, cards[1])
	UserInfoView:showImgTxt( g_392.t_pao )
	self.GameSceneView:hideAllPlayerOutCard(true)
	
	
    g_392.curOutCard = nil
    g_392.curOutSeat = nil
end

function gameScene:SVR_PLAYER_TI_CARD( pack )
	-- 0x1206  argv1:底牌数，argv2:SeatID, argv3:提的牌
	dumpW(pack, "0x1206                         --玩家提牌")
    local seat_id = pack.argv2
    SoundUtils:SoundCardType(g_392.t_ti, seat_id)
   
    local UserInfoView = self:getPlayerBySeatId( seat_id )
	local cards = self:getTabCards( pack.cards )
    local count = UserInfoView:removeHandCards( clone(cards) )
	UserInfoView:showImgTxt( g_392.t_ti )
    cards[2] = 0
    cards[3] = 0
    cards[4] = 0
	UserInfoView:showTypeCards(cards, g_392.t_ti, cards[1])
    self.GameSceneView:isShowBackNodeCount( true, pack.argv1 )
	
	if count ~= 4 then --不是起手提就放弃弃牌区
        local perOutCard = g_392.curOutCard
        local perOutSeat = g_392.curOutSeat
        if perOutCard and CardUtils:getZiPaiCard(perOutCard) ~= CardUtils:getZiPaiCard(cards[1]) then
            if perOutSeat and perOutCard then
                local UserInfoView = self:getPlayerBySeatId( perOutSeat )
                UserInfoView:showOutCard(perOutCard)
            end
        end
        g_392.curOutCard = nil
        g_392.curOutSeat = nil
    end
end

function gameScene:SVR_PLAYER_WEI_CARD( pack )
	-- 0x1207  argv1:底牌数，argv2:SeatID, argv3:偎的类型
	dumpW(pack)
    local seat_id = pack.argv2
    SoundUtils:SoundCardType(g_392.t_wei, seat_id)
   
    local UserInfoView = self:getPlayerBySeatId( seat_id )
	local cards = self:getTabCards( pack.cards )
    UserInfoView:removeHandCards( clone(cards) )
    cards[2] = 0
    cards[3] = 0
	UserInfoView:showTypeCards(cards, g_392.t_wei, cards[1])
	self.GameSceneView:hideAllPlayerOutCard()


	local perOutCard = g_392.curOutCard
    local perOutSeat = g_392.curOutSeat
    if perOutSeat and perOutCard then
		local UserInfoView = self:getPlayerBySeatId( perOutSeat )
		UserInfoView:showOutCard(perOutCard)
	end
	g_392.curOutCard = nil
    g_392.curOutSeat = nil
    UserInfoView:isShowOutCard(true, cards[1])
    self.GameSceneView:hideAllPlayerOutCard(true)
	UserInfoView:showImgTxt( g_392.t_wei )
    self.GameSceneView:isShowBackNodeCount( true, pack.argv1 )
    
end


function gameScene:SVR_PLAYER_HU_CARD( pack )
	--0x1208 uid:UserID,-1表示黄庄
	dumpW(pack)
	local uid = pack.uid
	if uid ~= -1 then
		local seat_id = g_392.userInfos[uid].seatID
		local UserInfoView = self:getPlayerBySeatId( seat_id )
		-- UserInfoView:showImgTxt( g_392.t_hu )
        UserInfoView:showZiMoOrHu("hu")
	end
end

function gameScene:SVR_PLAYER_GUCHOU(pack)
    local seat_id = pack.argv1
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    UserInfoView:isShowTxtGuChou(true)
end

function gameScene:getViewIdBySeatId(seat)
	if g_392.my_seat_id < 0 or g_392.my_seat_id == 0 then
		return seat + 1
	else
        local num = 0 - g_392.my_seat_id
		local viewId = (seat + num) % g_392.TOTAL_PLAYERNUM
		if seat + num == g_392.TOTAL_PLAYERNUM then
			return g_392.TOTAL_PLAYERNUM
		end
		return viewId + 1
	end
end

function gameScene:getPlayerBySeatId( seatId )
    local viewId = g_392.viewIds[seatId] or 0 
    return self.GameSceneView["player_"..viewId]
end

function gameScene:getTabCards( StrCards )
	local cards = string.split(StrCards,",") or {}
	for idx, card in ipairs(cards) do
		cards[idx] = tonumber(card)
	end
	return cards
end

function gameScene:handCards( UserInfoView, _type, value, num, seat_id )
    while true do
		local cards = table.splice(value, 1, num)
		if #cards == num then
			local card = cards[1]
			UserInfoView:showTypeCards(cards, _type, card)
		else
			break
		end
	end
end

return gameScene