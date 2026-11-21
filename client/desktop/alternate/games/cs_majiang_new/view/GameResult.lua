--[[
	公告弹出框
]]
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local GameResult = class("GameResult", NewViewBaseLayer)
local Card = require(TpackageName .. ".2DMahjongCard.Card")
local scheduler = cc.load("scheduler")
local zhongbirdCount
local win_lose_table = {} -- key = seatId
local sendHandle = require(TpackageName..".handle.CSMJSendHandle")

local EVENTNAME = {
	GET_MY_ID_CARD = "/getMyIDCard",
}

function GameResult:ctor(data)
    ReqMgr:addHandle("GameResult", EVENTNAME)
    local csbPath = TpackageName.."/res/GameResult/GameResult.csb"
    GameResult.super.ctor(self, csbPath)
	GameUtils.setNodeNameBindObj(self._csbNode)
	display.doLayout(self._csbNode)
	self:enableMask(true)
    self:initUI()
	self:initEvent()
	self:initGame( data )
end

function GameResult:initUI()
	-- local root = self._csbNode
    -- self.item = root.item:hide()
    self.item:hide()
    self.txt_time:setString("")
	self.txt_round:setString("")
	self.txt_zhongma:setString("")
end

function GameResult:initGame( data )

	local plane = self.users_vw
	self.zhongBao = data.zhongBao ----奖码
	plane:removeAllChildren()
	local size = plane:getSize()
	local cardHeight = self.item:getSize().height
	local cardWidth = self.item:getSize().width
	local number = table.getn(data.players)
	local scale = 1
	cardHeight = cardHeight * scale + 5
	cardWidth = cardWidth * scale
	local talHeight = cardHeight * number
	local oriX = size.width / 2
	local oriY = (size.height - talHeight) / 2 + cardHeight / 2
	
	for idx,userData in ipairs(data.players) do
		local item = self:initItem(userData)
		local y = oriY + ( idx-1 ) * cardHeight
		item:setPosition(cc.p(oriX, y))
		plane:addChild(item)
	end
	local time_str = os.date("%Y-%m-%d %H:%M:%S", os.time())

	local round = CSMJ_ROUND or 0
	local tround = CSMJ_TOTAL_ROUNDS or 0
	round = round.."/"..tround.."局"
	self.txt_time:setString(time_str)
	self.txt_round:setString(round)
	local str = "中码+"..data.maScore

	--self.txt_zhongma:setString(str) 这个先不显示

	self:setZhongMaCards(data.birdCards)
end

function GameResult:initItem( data )
	local item = self.item:clone()
	item:show()
	GameUtils.setNodeNameBindObj(item)
	local nickname = require("hall.GameCommon"):formatNick(data.nick, 4)
	local desc = self:getEndingInfo(data)
	-- local desc = "self:getEndingInfo(data)"
	local score = data.changeCoins / 100
    if score >= 0 then
        score = "+"..score
		item.score:setFntFile(TpackageName .. "/res/GameResult/majiang_win.fnt")
		item:loadTexture(TpackageName .. "/res/GameResult/bg_2.png")
    else
        item.score:setFntFile(TpackageName .. "/res/GameResult/majiang_lose.fnt")
		item:loadTexture(TpackageName .. "/res/GameResult/bg_1.png")
	end
    item.name:setString(nickname)
    item.desc:setString(desc)
	item.score:setString(score)
	item.img_zhuang:hide()
	if data.zhuang == USER_INFO.uid then
		item.img_zhuang:show()
	end
	local size = item.head:getSize()
    require("hall.GameCommon"):getUserHead(data.portrait, "", "", item.head, size.width , false, "", true)

	local cards = data.remainCards
	self:setPengAndGangCards(item.card_vw, data)

	item.img_zimo:hide()
	if data.hucontent then
		local hucontent = data.hucontent[1]
		local card = 0
		local hutype = hucontent.hutype
		if hutype == 1 then
			card = hucontent.pinghu[1].huCard
		else
			card = hucontent.zimo[1].huCard
		end
		item.img_zimo:show()
		item.img_zimo:loadTexture(TpackageName .. "/2DMahjongCard/res/newImage/last_card/"..card..".png")
		item.img_zimo:setPositionX(item.img_zimo:getPosition().x-100)
		for idx, value in ipairs(cards) do
			if value == card then
				table.remove( cards, idx )
				break
			end
		end
	end
	self:setCards(item.card_vw, cards)

	return item
end

function GameResult:setZhongMaCards(cardDatas)
	local plane = self.zhongma_vw
	local card = Card:newEndingCard({m_value = 1})
	plane:removeAllChildren()
	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width - 7
	local number = table.getn(cardDatas)
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale
	local oriX = (size.width - cardWidth * number) / 2
	local oriY = size.height / 2

	for idx,cardData in ipairs(cardDatas) do
		local card = Card:newEndingCard(cardData.card)
		if  cardData.position == 1 and not (G_game and G_game.isYiMaQuanZhong) then
			card:setZhongMaAnima(false)
		end
		local x = oriX + ( idx - 1 ) * cardWidth
		card:setPosition(cc.p(x, oriY))
		card:setScale(scale)
		card:show()
		plane:addChild(card)
	end
end

function GameResult:setCards(plane, cardDatas)
	table.sort(cardDatas,function(a,b)
		return b < a
	end)
	local card = Card:newEndingCard({m_value = 1})
	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width - 7
	local number = table.getn(cardDatas)
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale

	
	local oriX = cardWidth / 2
	-- local oriX = size.width - cardWidth / 2
	local oriY = cardHeight / 2
	local childs = plane:getChildren()
	if #childs > 0 then
		local pos = childs[#childs]:getPosition()
		oriX = pos.x + 10
	end
	local idx = 1
	for i=number, 1, -1 do
		local cardData = cardDatas[i]
		local card = Card:newEndingCard(cardData)
		-- local x = oriX - ( idx ) * cardWidth
		local x = oriX + ( idx ) * cardWidth
		card:setTag(i)
		card:setScale(scale)
		card:setPosition(cc.p(x, oriY))
		plane:addChild(card)
		card:show()
		idx = idx + 1
	end
end

function GameResult:setPengAndGangCards(plane, data)
	plane:removeAllChildren()
	local card = Card:newEndingCard({m_value = 1})
	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width - 7
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale
	local oriX = cardWidth / 2
	local oriY = cardHeight / 2
	local idx = 0
	
	--暗杠
	for i,cardData in ipairs(data.agCards) do
		for idxx = 1, 4 do
			local card = Card:newEndingCard(cardData)
			local x = oriX + ( idx ) * cardWidth
			local y = oriY
			if idxx == 3 then
				x = oriX + ( idx-1 ) * cardWidth
				y = y + 23
			else
				idx = idx + 1
				card:setEndingAnGangCard()
			end
			card:setScale(scale)
			card:setPosition(cc.p(x, y))
			plane:addChild(card)
			card:show()
		end
		oriX = oriX + 10
	end

	--杠
	for i,cardData in ipairs(data.gCards) do
		for idxx = 1, 4 do
			local card = Card:newEndingCard(cardData)
			local x = oriX + ( idx ) * cardWidth
			local y = oriY
			if idxx == 3 then
				x = oriX + ( idx-1 ) * cardWidth
				y = y + 23
			else
				idx = idx + 1
			end
			card:setScale(scale)
			card:setPosition(cc.p(x, y))
			plane:addChild(card)
			card:show()
		end
		oriX = oriX + 10
	end
	
	--碰
	for i,cardData in ipairs(data.pCards) do
		for idxx = 1, 3 do
			local card = Card:newEndingCard(cardData)
			local x = oriX + ( idx ) * cardWidth
			card:setScale(scale)
			card:setPosition(cc.p(x, oriY))
			plane:addChild(card)
			card:show()
			idx = idx + 1
		end
		oriX = oriX + 10
	end

	--吃
	local index = 0
	for i,cardData in ipairs(data.cCards) do
		local card = Card:newEndingCard(cardData.card)
		local x = oriX + ( idx ) * cardWidth
		card:setScale(scale)
		card:setPosition(cc.p(x, oriY))
		plane:addChild(card)
		card:show()
		idx = idx + 1

		index = index+1
		if index % 3 == 0 then
			oriX = oriX + 10
		end
	end

end

function GameResult:initEvent()
	self.btn_jixu:onClick(handler(self, self.onClickJiXu), true)
    self.make:onTouch(handler(self, self.onClick_vw), false)
end

function GameResult:onClickJiXu(event)
	sendHandle:readyNow()
	self:onClickBtnClose(event)
end

function GameResult:getEndingInfo(player, index)
	local endingInfo = ""

	if player.ifhu == 1 then
		if player.hucontent then
			local hucontent = player.hucontent[1]
			local hutype = hucontent.hutype
			if hutype == 1 then
				endingInfo = endingInfo .. "接炮 "
			elseif hutype == 2 then
				endingInfo = endingInfo .. "自摸 "
			end
		end
	elseif player.ifpao == 1 then
		endingInfo = endingInfo .. "放炮 "
	end

	--显示起手小胡
	if player.qishou_hu_tai_size and player.qishou_hu_tai_size > 0 then
		endingInfo = endingInfo .."起手胡: "
		for k,v in pairs(player.qishou_hu_tai) do
			endingInfo = endingInfo .. CSMJ_HU_TYPE_TABLE[v.byType] .."+" .. v.byTaiCount .. " "
		end
	end
	
	--显示胡牌时候的胡
	for k,v in pairs(player.hu_tai) do
		endingInfo = endingInfo .. CSMJ_HU_TYPE_TABLE[v.byType] .."+" .. v.byTaiCount .. " "
	end

	if player.niaoScore and tonumber(player.niaoScore) and player.niaoScore > 0 then
		endingInfo = endingInfo .."中鸟+" .. player.niaoScore.." "
	end


	if tonumber(player.piaoScore) and player.piaoScore > 0 then
		endingInfo = endingInfo .. "漂+" .. player.piaoScore.." "
	end

	return endingInfo
end

function GameResult:onClick_vw(event)
    if event.name == "began" then
        dump("定时器------------------------------")
		self.handle = scheduler.performWithDelayGlobal(function()
			if self and self.root then
				self.root:hide()
				self.maskLayout:hide()
				self.btn_jixu:hide()
			end
        end, 0.1)
    elseif event.name == "ended" then
        if self.handle then
            dump("清除定时器------------------------------")
            self.root:show()
            self.maskLayout:show()
			self.btn_jixu:show()
            scheduler.unscheduleGlobal(self.handle)
        end
    elseif event.name == "cancelled" then
        if self.handle then
            dump("cancelled清除定时器------------------------------")
            self.root:show()
            self.maskLayout:show()
			self.btn_jixu:show()
            scheduler.unscheduleGlobal(self.handle)
        end
    end
end

-- 关闭界面
function GameResult:onClickBtnClose(event)
    self:removeSelf()
end

function GameResult:onExit()
	ReqMgr:delHandle("GameResult", EVENTNAME)
	if self.handle then
		scheduler.unscheduleGlobal(self.handle)
	end
	CSMJ_ENDING_DATA = nil
	if CSMJ_GROUP_ENDING_DATA then
		require(TpackageName ..".GroupEndingLayer"):showGroupResult(CSMJ_GROUP_ENDING_DATA)
	end
end

return GameResult

