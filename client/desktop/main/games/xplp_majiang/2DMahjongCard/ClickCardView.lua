--[[
	公告弹出框
]]
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local ClickCardView = class("ClickCardView", NewViewBaseLayer)
local Card = require("xplp_majiang.2DMahjongCard.Card")


function ClickCardView:ctor(data, isPengOrGang)
    local csbPath = "xplp_majiang/res/ClickCardView.csb"
    ClickCardView.super.ctor(self, csbPath)
	GameUtils.setNodeNameBindObj(self._csbNode, nil, false)
	self:enableMask(true)
	self:setClickMaskClose()
    self.ScrollView_1:setScrollBarEnabled(false)
	if isPengOrGang then
		self:PengOrGangCardMgr(data)
	else
		self:OutCardMgr(data)
	end
	local director = cc.Director:getInstance()
    local size = director:getWinSize()
    self.ScrollView_1:setAnchorPoint(0.5, 0.5)
	self.ScrollView_1:setPosition(size.width / 2, size.height / 2)
end

function ClickCardView:PengOrGangCardMgr( data )
	self.ScrollView_1:setDirection(cc.SCROLLVIEW_DIRECTION_BOTH)
	local ssize = self.ScrollView_1:getInnerContainerSize()
	local scrollsize = self.ScrollView_1:getContentSize()

	local cardNode = Card:newOutCard(CARD_PLAYERTYPE_MY, 1)
	local tableNodeSize = cardNode:getContentSize()
	local cardH = tableNodeSize.height + 5
	local cardW = tableNodeSize.width + 5
	cardNode:removeSelf()
	

	local size = 0
	for i,v in ipairs(data) do
		for idx,card in ipairs(v.cards) do
			size = size + 1
		end
		size = size + 1
	end
	if size > 0 then
		size  = size - 1
	end
	local width = size * cardW
	if width < scrollsize.width then
		width = scrollsize.width
	end
	self.ScrollView_1:setInnerContainerSize(cc.size(width, ssize.height))

	local ox = (scrollsize.width - cardW * size) / 2
	if size >= 16 then
		ox = 0
	end
	local size = 0
	for i,v in ipairs(data) do
		local isAnGang = v.isAnGang
		for idx,card in ipairs(v.cards) do
			local x = ox + size * cardW + cardW / 2
			local y = 120
			local cardNode = Card:newOutCard(CARD_PLAYERTYPE_MY, card)
			self.ScrollView_1:addChild(cardNode)
			cardNode:setPosition(cc.p(x, y))
			-- cardNode:onClick(handler(self, self.onClickBtnClose))
			size = size + 1
			if isAnGang and idx ~= 4 then
				cardNode:setAnGangCard()
			end
		end
		size = size + 1
	end
end

function ClickCardView:OutCardMgr( cards )
	-- local ssize = self.ScrollView_1:getInnerContainerSize()
	-- local scrollsize = self.ScrollView_1:getContentSize()
	-- local size = #cards

	-- local col = 16
	-- local cardNode = Card:newOutCard(CARD_PLAYERTYPE_MY, 1)
	-- local tableNodeSize = cardNode:getContentSize()
	-- local cardH = tableNodeSize.height + 5
	-- local cardW = tableNodeSize.width + 5
	-- local height = math.ceil(size / col) * cardH
	-- if height < scrollsize.height then
	-- 	height = scrollsize.height
	-- end
	-- self.ScrollView_1:setInnerContainerSize(cc.size(ssize.width, height))
	-- cardNode:removeSelf()
	-- local ox = (scrollsize.width - cardW * size) / 2
	-- if size >= col then
	-- 	ox = 0
	-- end
	-- for size,card in ipairs(cards) do
	-- 	local cardNode = Card:newOutCard(CARD_PLAYERTYPE_MY, card)
	-- 	self.ScrollView_1:addChild(cardNode)
	-- 	local idx_x = math.ceil(size / col)
	-- 	local idxy = size % col
	-- 	if idxy == 0 then
	-- 		idxy = 1
	-- 	end
	-- 	local x = ox + (idxy - 1) * cardW + cardW / 2
	-- 	local y = height - (idx_x * cardH)  + cardH/2
	-- 	cardNode:setPosition(cc.p(x, y))
	-- end

	self.ScrollView_1:setDirection(cc.SCROLLVIEW_DIRECTION_BOTH)
	local ssize = self.ScrollView_1:getInnerContainerSize()
	local scrollsize = self.ScrollView_1:getContentSize()

	local cardNode = Card:newOutCard(CARD_PLAYERTYPE_MY, 1)
	local tableNodeSize = cardNode:getContentSize()
	local cardH = tableNodeSize.height + 5
	local cardW = tableNodeSize.width + 5
	cardNode:removeSelf()
	
	local size = #cards
	local width = size * cardW
	if width < scrollsize.width then
		width = scrollsize.width
	end
	self.ScrollView_1:setInnerContainerSize(cc.size(width, ssize.height))


	local ox = (scrollsize.width - cardW * size) / 2
	if size >= 16 then
		ox = 0
	end
	for size,card in ipairs(cards) do
		local x = ox + (size - 1 ) * cardW + cardW / 2
		local y = 120
		local cardNode = Card:newOutCard(CARD_PLAYERTYPE_MY, card)
		cardNode:setAnchorPoint(0.5, 0.5)

		cardNode:setPosition(cc.p(x, y))
		self.ScrollView_1:addChild(cardNode)
	end
end

-- 关闭界面
function ClickCardView:onClickBtnClose(event)
    self:removeSelf()
end

function ClickCardView:onExit()
	
end

return ClickCardView

