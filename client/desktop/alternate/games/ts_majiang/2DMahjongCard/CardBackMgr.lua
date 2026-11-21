--[[
	桌面牌背
--]]
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local Card = require(TpackageName..".2DMahjongCard.Card")

local CardBackMgr = class("CardBackMgr", NewViewBaseLayer)
local EVENTNAME = {
	QUERY_ACTIVITIES_RESULT = "/freeGame/queryActivitiesResult",
}

function CardBackMgr:ctor()
    local csbPath = TpackageName.."/res/GameScene/GameScene.csb"
	CardBackMgr.super.ctor(self, csbPath, false, false)
	local size = self._csbNode:getContentSize()
	GameUtils.setNodeNameBindObj(self._csbNode)
	self:setScene( self._csbNode )
	self.tableNodes = {}

	self:initUI()
	self:clearGameNodes( )
end

function CardBackMgr:initUI(remainCard, shaizi)
	self.curTableCardIndex = shaizi or 81 --必须是单数
	local contCard = TSMJ_CARDS_LESS_INIT or 144
	remainCard = remainCard or contCard 
	if contCard == remainCard then
		return
	end
	self:showTableCards(contCard, remainCard)
	self.remainCard = contCard
end

function CardBackMgr:setScene( node )
	self._scene = node
end

function CardBackMgr:clearGameNodes( )
	self.tableNodes = {}
	local nodes = {
		self._scene.players.my_card_plane.table_cards_plane,
		self._scene.players.left_card_plane.table_cards_plane,
		self._scene.players.top_card_plane.table_cards_plane,
		self._scene.players.right_card_plane.table_cards_plane,
	}
	for type, node in ipairs(nodes) do
		node:removeAllChildren()
	end
end

function CardBackMgr:showTableCards(cardCont, nextCont)
    if cardCont == 0 then
        return
	end

	local tal = {
		up = 1,
		right = 2,
		down = 3,
		left = 4,
	}
	local paths = {
		[tal.down] = "down",
		[tal.left] = "left",
		[tal.up] = "up",
		[tal.right] = "right",
	}
	local nodes = {
		[tal.down] = self._scene.players.my_card_plane.table_cards_plane,
		[tal.left] = self._scene.players.left_card_plane.table_cards_plane,
		[tal.up] = self._scene.players.top_card_plane.table_cards_plane,
		[tal.right] = self._scene.players.right_card_plane.table_cards_plane,
	}
	
	local x = 4
	local numa, numb = math.modf( cardCont / x )
	numb = numb * x
	self.tableNodes = {}
	for type, path in ipairs(paths) do
		local number = numa
		if type == tal.left then
			number = number + numb
		end
		local cardIdx = 1
		local parent = nodes[type]
		parent:removeAllChildren()
		local pool_col_space = 0
		local card = Card:newBack(path)
		local size = parent:getContentSize()
		-- local scale = size.height / card:getSize().height
		local scale = 1
		local cardHeight = card:getSize().height * scale
		local cardWidth = card:getSize().width * scale + pool_col_space
		
		local oriX = size.width / 2
		local oriY = size.height / 2
		-- local initX = 0
		-- local initY = 0
		local number_2 = math.ceil(number/2)
		if type == tal.down then
			oriX = size.width - (number_2 * cardWidth) + cardWidth / 2
			oriX = size.width - oriX / 2
			if oriX > size.width then
				oriX = size.width - cardWidth / 2
			end
		elseif type == tal.left then
			cardHeight = 29
			oriY = size.height - (number_2 * cardHeight) + cardHeight / 2
			oriY = oriY / 2
			if oriY < 0 then
				oriY = 0 + cardHeight / 2
			end
			-- initY = (20 - number_2) * 5.7
		elseif type == tal.up then
			oriX = size.width - (number_2 * cardWidth) + cardWidth / 2
			oriX = oriX / 2
			if oriX < cardWidth / 2 then
				oriX = cardWidth / 2
			end
		elseif type == tal.right then
			cardHeight = 28
			oriY = size.height - (number_2 * cardHeight) + cardHeight / 2
			oriY = size.height - oriY / 2
			if oriY > size.height then
				oriY = size.height - cardHeight / 2
			end
		end
		-- oriY = oriY + initY
		-- oriX = oriX + initX
		local nodea,nodeb
		local cardNodes = {}
		for idx = 1, number do
			local index = idx % 2
			card = Card:newBack(path)
			card:setScale(scale)
			local x = 0
			local y = 0
			
			local ixx = math.ceil(idx/2) - 1
			if type == tal.down then
				x = oriX - cardWidth * ixx
				y = oriY - (index * 18)
				if index == 0 then
					nodeb = card
				elseif index == 1 then
					nodea = card
				end

			elseif type == tal.left then
				x = oriX + (ixx * 6)
				y = oriY + (ixx * cardHeight)
				if index == 0 then
					nodea = card
				elseif index == 1 then
					x = x - 7
					y = y + 18
					nodeb = card
				end
			elseif type == tal.up then
				x = oriX + cardWidth * ixx
				y = oriY - (index * 12)
				if index == 0 then
					nodeb = card
				elseif index == 1 then
					nodea = card
				end
			elseif type == tal.right then
				x = oriX + (ixx * 6)
				y = oriY - (ixx * cardHeight)
				if index == 0 then
					nodeb = card
				elseif index == 1 then
					x = x - 8
					y = y - 15
					nodea = card
				end
			end
			card:setPosition(cc.p(x, y))
			parent:addChild(card)
			if nodea and nodeb then
				table.insert(cardNodes, nodeb)
				table.insert(cardNodes, nodea)
				nodea = nil
				nodeb = nil
			elseif idx == number then
				if nodeb then
					table.insert(cardNodes, nodeb)
					nodeb = nil
				end
				if nodea then
					table.insert(cardNodes, nodea)
					nodea = nil
				end
			end
		end
		if type == tal.left then
			local tmp = {}
			local total = #cardNodes
			for i = 1, total do
				local index = #cardNodes - (i -1)
				local node = cardNodes[index]
				node:setZOrder(i)
			end
		end
		self.tableNodes = tableConcat(self.tableNodes, cardNodes)
	end
	local number = cardCont - nextCont
	for i=1,number do
		self:removeTableCrad()
	end
end

function CardBackMgr:removeTableCrad( remainCount )
	if not self.tableNodes or #self.tableNodes <= 0 then return end
	if remainCount and #self.tableNodes == remainCount then return end
	local index = self.curTableCardIndex
	local node = table.remove(self.tableNodes, index)
	-- self.curTableCardIndex = self.curTableCardIndex + 1
	if not node then 
		if #self.tableNodes >= 1 and self.curTableCardIndex ~= 1 then
			self.curTableCardIndex = 1
			self:removeTableCrad()
		end
		return 
	end
	node:removeSelf()
	-- dump(self.tableNodes, self.curTableCardIndex)
end

function CardBackMgr:onClickSelf( )
	self:removeSelf()
end

return CardBackMgr