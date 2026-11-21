local RecordBaseScene = require("hall.record.RecordBaseScene")
local GameSceneView = require("jchuapai.src.record.GameSceneView")
local gameScene = class("gameScene", RecordBaseScene)
local CardUtils = require("jchuapai.src.CardUtils")
local Config = require("jchuapai.src.Config")
-- local SoundUtils = require("jchuapai.src.SoundUtils")

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
	g_388.TOTAL_PLAYERNUM = #data.userinfos
	for idx,userInfo in ipairs(data.userinfos) do
		if userInfo.uid == USER_INFO.uid then
			g_388.my_seat_id = userInfo.seatID
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
	-- argv4:提的牌
	self.func_ = {
		[0x4011] = {handler(self, self.SVR_BUPAI_DEAL)},--补牌或者派发单张
		[0x1203] = {handler(self, self.SVR_PLAYER_TONG_CARD)},--用户统牌
		[0x1201] = {handler(self, self.SVR_PLAYER_CHU_CARD)},--玩家出牌
		[0x1204] = {handler(self, self.SVR_PLAYER_PENG_CARD)},--碰的牌
		[0x1205] = {handler(self, self.SVR_PLAYER_ZHAO_CARD)},--用户招牌
		[0x1206] = {handler(self, self.SVR_PLAYER_FAN_CARD)},--用户泛牌
		[0x1208] = {handler(self, self.SVR_PLAYER_HU_CARD)},--玩家胡牌
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
	local seat_id = pack.uid
	local UserInfoView = self:getPlayerBySeatId(seat_id)
	UserInfoView:addHandCard( pack.argv2 )
	self.GameSceneView:isShowBackNodeCount( true, pack.argv1 )
end

function gameScene:SVR_PLAYER_TONG_CARD( pack )
	-- 0x1203 argv1:底牌数，argv2:SeatID, argv3~用户统牌
	dumpW(pack, "0x1203                         --用户统牌")
	local UserInfoView = self:getPlayerBySeatId( pack.argv2 )
    UserInfoView:isShowTongCountd(true, pack.argv1)
    UserInfoView:showImgTxt("tong")
end

function gameScene:SVR_PLAYER_CHU_CARD( pack )
	-- 0x1201  argv1:SeatID, argv2:出的牌
	dumpW(pack, "0x1201                         --玩家出牌")
	self.GameSceneView:hideAllPlayerOutCard()
    local seat_id = pack.argv1
    local CardValue = pack.argv2
    local perOutCard = g_388.curOutCard
    local perOutSeat = g_388.curOutSeat
    g_388.curOutCard = CardValue
    g_388.curOutSeat = seat_id
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    UserInfoView:isShowOutCard(true, CardValue)
	UserInfoView:removeHandCards( {CardValue} )
    if perOutSeat and perOutCard then
        local UserInfoView = self:getPlayerBySeatId( perOutSeat )
        UserInfoView:showOutCard(perOutCard)
	end
	
end

function gameScene:SVR_PLAYER_PENG_CARD( pack )
	dumpW(pack)
	-- 0x1204  argv1:底牌数，argv2:SeatID, argv3:碰的牌
	dump(pack, "0x1204             --用户碰牌")
    self.GameSceneView:hideAllPlayerOutCard()
    local seat_id = pack.argv2
	local cards = self:getTabCards( pack.cards )
	local UserInfoView = self:getPlayerBySeatId( seat_id )
    UserInfoView:showTypeCards(cards)
    UserInfoView:showImgTxt("dui")
	UserInfoView:removeHandCards( clone(cards), g_388.curOutCard )
    g_388.curOutCard = nil
	g_388.curOutSeat = nil
end

function gameScene:SVR_PLAYER_ZHAO_CARD( pack )
	-- 0x1205  argv1:底牌数，argv2:SeatID, argv3:用户招牌
	self.GameSceneView:hideAllPlayerOutCard()
    local seat_id = pack.argv2
	local cards = self:getTabCards( pack.cards )
	local UserInfoView = self:getPlayerBySeatId( seat_id )
    UserInfoView:showTypeCards(cards, "zhao")
    UserInfoView:showImgTxt("zhao")
	UserInfoView:removeHandCards( clone(cards), g_388.curOutCard )
    g_388.curOutCard = nil
	g_388.curOutSeat = nil
end

function gameScene:SVR_PLAYER_FAN_CARD( pack )
	-- 0x1206  argv1:底牌数，argv2:SeatID, argv3:用户泛牌
	self.GameSceneView:hideAllPlayerOutCard()
    local seat_id = pack.argv2
	local cards = self:getTabCards( pack.cards )
	local UserInfoView = self:getPlayerBySeatId( seat_id )
    UserInfoView:showTypeCards(cards, "zhao")
    UserInfoView:showImgTxt("zhao")
	UserInfoView:removeHandCards( clone(cards), g_388.curOutCard )
    g_388.curOutCard = nil
	g_388.curOutSeat = nil
    UserInfoView:isShowTongCountd(true, pack.argv3)
end


function gameScene:SVR_PLAYER_HU_CARD( pack )
	--0x1208 uid:UserID,-1表示黄庄
	dumpW(pack)
	local uid = pack.uid
	if uid ~= -1 then
		local seat_id = g_388.userInfos[uid].seatID
		local UserInfoView = self:getPlayerBySeatId( seat_id )
		UserInfoView:showImgTxt( "hu" )
	end
end



function gameScene:getViewIdBySeatId(seat)
	if g_388.my_seat_id < 0 or g_388.my_seat_id == 0 then
		return seat + 1
	else
        local num = 0 - g_388.my_seat_id
		local viewId = (seat + num) % g_388.TOTAL_PLAYERNUM
		if seat + num == g_388.TOTAL_PLAYERNUM then
			return g_388.TOTAL_PLAYERNUM
		end
		return viewId + 1
	end
end

function gameScene:getPlayerBySeatId( seatId )
    local viewId = g_388.viewIds[seatId] or 0 
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