--[[
	桌面牌背
--]]
local PokerCard = require("hz_majiang.src.PokerCard")
local TableCardView = class("TableCardView")
function TableCardView:ctor(cards_vw)
	self.cards_vw = cards_vw
	self.tableNodes = {}
end

function TableCardView:setTableCards(maxCardCount, shaizi)
	self.curTableCardIndex = shaizi or 81 --必须是单数
	self:showTableCards(maxCardCount)
end

function TableCardView:clearData()
	self.tableNodes = {}
	local nodes = {
		self.cards_vw.player_1.table_cards_vw,
		self.cards_vw.player_4.table_cards_vw,
		self.cards_vw.player_2.table_cards_vw,
		self.cards_vw.player_3.table_cards_vw,
	}
	for _type, node in ipairs(nodes) do
		node:removeAllChildren()
	end
end

function TableCardView:showTableCards(cardCont)
    if cardCont == 0 then
        return
	end
	local tal = {
		{
			node = self.cards_vw.player_1.table_cards_vw, 
			_type = g_308.viewId_my
		},
		{
			node = self.cards_vw.player_4.table_cards_vw, 
			_type = g_308.viewId_left
		},
		{
			node = self.cards_vw.player_2.table_cards_vw, 
			_type = g_308.viewId_top
		},
		{
			node = self.cards_vw.player_3.table_cards_vw, 
			_type = g_308.viewId_right
		},
	}

	local playerCount = 4
	local numa, numb = math.modf( cardCont / playerCount )
	numb = numb * playerCount
	self.tableNodes = {}
	for _, val in ipairs(tal) do
		local _type = val._type

		local number = numa
		local table_cards_vw = val.node
		table_cards_vw:removeAllChildren()
		if _type == g_308.viewId_left then
			number = number + numb
		end
		local cardIdx = 1
		local pool_col_space = 0
		local cardNode = PokerCard:newTableCard(_type)
		local size = table_cards_vw:getContentSize()
		-- local scale = size.height / cardNode:getSize().height
		local scale = 1
		local cardHeight = cardNode:getSize().height * scale
		local cardWidth = cardNode:getSize().width * scale + pool_col_space
		
		local oriX = size.width / 2
		local oriY = size.height / 2
		-- local initX = 0
		-- local initY = 0
		local number_2 = math.ceil(number/2)
		if _type == g_308.viewId_my then
			oriX = size.width - (number_2 * cardWidth) + cardWidth / 2
			oriX = size.width - oriX / 2
			if oriX > size.width then
				oriX = size.width - cardWidth / 2
			end
		elseif _type == g_308.viewId_left then
			cardHeight = 29
			oriY = size.height - (number_2 * cardHeight) + cardHeight / 2
			oriY = oriY / 2
			if oriY < 0 then
				oriY = 0 + cardHeight / 2
			end
			-- initY = (20 - number_2) * 5.7
		elseif _type == g_308.viewId_top then
			oriX = size.width - (number_2 * cardWidth) + cardWidth / 2
			oriX = oriX / 2
			if oriX < cardWidth / 2 then
				oriX = cardWidth / 2
			end
		elseif _type == g_308.viewId_right then
			cardHeight = 28
			oriY = size.height - (number_2 * cardHeight) + cardHeight / 2
			oriY = size.height - oriY / 2
			if oriY > size.height then
				oriY = size.height - cardHeight / 2
			end
		end
		local nodea,nodeb
		local cardNodes = {}
		for idx = 1, number do
			local index = idx % 2
			cardNode = PokerCard:newTableCard(_type)
			cardNode:setScale(scale)
			local x = 0
			local y = 0
			
			local ixx = math.ceil(idx/2) - 1
			if _type == g_308.viewId_my then
				x = oriX - cardWidth * ixx
				y = oriY - (index * 17)
				if index == 0 then
					nodeb = cardNode
				elseif index == 1 then
					nodea = cardNode
				end

				cardNode:setPosition(cc.p(x, y))
			elseif _type == g_308.viewId_left then
				-- x = oriX + (ixx * 6)
				y = oriY + (ixx * cardHeight)
				x = oriX
				if index == 0 then
					nodea = cardNode
				elseif index == 1 then
					x = x - 7
					y = y + 18
					nodeb = cardNode
				end
				cardNode:setPosition(cc.p(x, y))
				cardNode:setRotation(-12)
			elseif _type == g_308.viewId_top then
				x = oriX + cardWidth * ixx
				y = oriY - (index * 10)
				if index == 0 then
					nodeb = cardNode
				elseif index == 1 then
					nodea = cardNode
				end
				cardNode:setPosition(cc.p(x, y))
			elseif _type == g_308.viewId_right then
				-- x = oriX + (ixx * 6)
				y = oriY - (ixx * cardHeight)
				x = oriX
				if index == 0 then
					nodeb = cardNode
				elseif index == 1 then
					x = x - 8
					y = y - 15
					nodea = cardNode
				end
				cardNode:setPosition(cc.p(x, y))
				cardNode:setRotation(12)
			end
			table_cards_vw:addChild(cardNode)
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
		if _type == g_308.viewId_left then
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
	
end

function TableCardView:removeTableCard( remainCount )
	for i = 1, remainCount do
		local node = table.remove(self.tableNodes, self.curTableCardIndex)
		if not node then 
			node = table.remove(self.tableNodes, 1)
		end
		if node then 
			node:removeSelf()
		end
	end
end

return TableCardView