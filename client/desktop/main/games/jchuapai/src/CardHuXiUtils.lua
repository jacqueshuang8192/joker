local CardHuXiUtils = class("CardHuXiUtils")
local Magic_Card = 0x2d
--计算对牌胡息
local CardUtils = require("jchuapai.src.CardUtils")
function CardHuXiUtils:CalDuiHuXi( m_vecPeng, mainCardIndex )
	table.sort(m_vecPeng, function( a, b )
		local carda = CardUtils:GetCardLogicValue(a)
		local cardb = CardUtils:GetCardLogicValue(b)
		return carda < cardb
	end)

	local mainCardIndex = CardUtils:GetCardLogicValue(mainCardIndex)
	local iDuiHuXi = 0
	-- for (local j = 0 j < m_vecPeng.size() j++)
	-- for j,v in ipairs(m_vecPeng) do
		local index = CardUtils:GetCardLogicValue(m_vecPeng[1])
		if (index == 3 or index == 5 or index == 7) then
		
			-- for (local k = 0 k < 3 k++)
			for k = 1, 3 do
				local cardXi = 1
				if m_vecPeng[k] == Magic_Card then
					if index == mainCardIndex then
						cardXi = 4
					else
						cardXi = 2
					end
				else
					if ((bit.band(m_vecPeng[k], 0xF0) == 0x10)) then--花牌
						
						cardXi = cardXi + 1
					end
					if (index == mainCardIndex) then
						
						cardXi = cardXi * 2
					end
				end
				iDuiHuXi = iDuiHuXi + cardXi
			end
		elseif (index >= 17) then--上大人可知礼的对
			iDuiHuXi= iDuiHuXi + 1
		elseif (index == 1 or index == 9) then--乙9有花牌
		
			-- for (local k = 0 k < 3 k++)
			for k = 1, 3 do
				
				if bit.band(m_vecPeng[k], 0xF0) == 0x10 then--花牌
				
					iDuiHuXi= iDuiHuXi + 1
				end
			end
		end
	-- end
	return iDuiHuXi
end

function CardHuXiUtils:isSepCalXi( cards, cardsResult, mainCardIndex, isZiMo, huCard, handCards )
	local isSepCalXi = false
	if #cards == 3 then
		table.sort(cards, function( a, b )
			local carda = CardUtils:GetCardLogicValue(a)
			local cardb = CardUtils:GetCardLogicValue(b)
			return carda < cardb
		end)

		local mainCardIndex = CardUtils:GetCardLogicValue(mainCardIndex)
		local huCardIndex = CardUtils:GetCardLogicValue(huCard)
		local index1 = CardUtils:GetCardLogicValue(cards[1])
		local index2 = CardUtils:GetCardLogicValue(cards[2])
		local index3 = CardUtils:GetCardLogicValue(cards[3])
		local handCardsIndex = {}
		for i,v in ipairs(handCards) do
			local cardIdx = CardUtils:GetCardLogicValue(v)
			if not handCardsIndex[cardIdx] then
				handCardsIndex[cardIdx] = 0
			end
			handCardsIndex[cardIdx] = handCardsIndex[cardIdx] + 1
		end
		if not handCardsIndex[index1] then
			handCardsIndex[index1] = 0
		end
		if isZiMo ~= 1 and huCardIndex == index1 and handCardsIndex[index1] then
			if index1 == index2 and index1 == index3 and handCardsIndex[index1] <= 2 then
				isSepCalXi = true
			elseif index1 == index2 and Magic_Card == index3 and handCardsIndex[index1] <= 1 then
				isSepCalXi = true
			elseif Magic_Card == index2 and Magic_Card == index3 and handCardsIndex[index1] <= 0 then
				isSepCalXi = true
			end
		end
	end
	return isSepCalXi
end

function CardHuXiUtils:CalHuXi( cards, mainCardIndex )
	table.sort(cards, function( a, b )
		local carda = CardUtils:GetCardLogicValue(a)
		local cardb = CardUtils:GetCardLogicValue(b)
		return carda < cardb
	end)

	local mainCardIndex = CardUtils:GetCardLogicValue(mainCardIndex)
	local huxi = 0
	local len = #cards
	if (len == 2) then
		-- for (local j = 0 j < len j++)
		--特殊情况下有两个赖子，直接算最大胡息
		if (cards[1] == Magic_Card and cards[2] == Magic_Card) then
			return 8
		end
		for j = 1, len do
			local index = CardUtils:GetCardLogicValue(cards[j])
			if (index == 3 or index == 5 or index == 7) then
			
				local cardXi = 1
				if (bit.band(cards[j], 0xF0) == 0x10) then--花牌
				
					cardXi = cardXi + 1
				end
				if (index == mainCardIndex) then
				
					cardXi = cardXi * 2
				end
				huxi = huxi + cardXi
			elseif (index == 1 or index == 9) then--乙9有花牌
			
				if (bit.band(cards[j], 0xF0) == 0x10) then--花牌
				
					huxi = huxi + 1
				end
			elseif (index == 23) then--赖子
			
				local cardXi = 2
				local otherIndex = CardUtils:GetCardLogicValue(cards[1])
				if (otherIndex == 10 or otherIndex == 15) and (mainCardIndex == 7) then--十土
				
					cardXi = cardXi * 2
				elseif (otherIndex == 13 or otherIndex == 14) and (mainCardIndex == 3) then--话千
				
					cardXi = cardXi * 2
				elseif (otherIndex <= 5 and mainCardIndex == 3) then
				
					cardXi = cardXi * 2
				elseif (otherIndex >= 3 and otherIndex <= 7 and mainCardIndex == 5) then
				
					cardXi = cardXi * 2
				elseif (otherIndex >= 5 and otherIndex <= 9 and mainCardIndex == 7) then
					cardXi = cardXi * 2
				end
				huxi = huxi + cardXi
			end
			
		end
	elseif len == 3 then
	
		local index1 = CardUtils:GetCardLogicValue(cards[1])
		local index2 = CardUtils:GetCardLogicValue(cards[2])
		local index3 = CardUtils:GetCardLogicValue(cards[3])

		local iFlower = 0--花牌数量
		local iMagic = 0--赖子牌数量
		-- for (local i = 0 i < 3 i++)
		for i = 1, 3 do
			
			if (bit.band(cards[i], 0xF0) == 0x10) then
			
				iFlower = iFlower + 1
			elseif (cards[i] == Magic_Card) then
			
				iMagic= iMagic + 1
			end
		end

		local isKan = false
		if (index1 == index2 and (index1 == index3 or index3 == 23)) then
		
			isKan = true
		elseif (index2 == index3 and index2 == 23) then
		
			isKan = true
		elseif (index1 == index2 and index3 == 23) then
		
			isKan = true
		end

		--经坎
		if ((index1 == 3 or index1 == 5 or index1 == 7) and isKan) then
		
			if (iFlower == 0 and iMagic == 0) then
			
				if (index1 == mainCardIndex) then
				
					huxi = 10
				else
				
					huxi = 5
				end
			elseif ((iFlower == 1 and iMagic == 0) or (iFlower == 0 and iMagic == 1)) then
			
				if (index1 == mainCardIndex) then
				
					huxi = 12
				else
				
					huxi = 6
				end
			elseif ((iFlower == 2 and iMagic == 0) or (iFlower == 1 and iMagic == 1) or (iFlower == 0 and iMagic == 2)) then
			
				if (index1 == mainCardIndex) then
				
					huxi = 14
				else
				
					huxi = 7
				end
			elseif ((iFlower == 2 and iMagic == 1)) then
			
				if (index1 == mainCardIndex) then
				
					huxi = 18
				else
				
					huxi = 9
				end
			elseif ((iFlower == 1 and iMagic == 2)) then
			
				if (index1 == mainCardIndex) then
				
					huxi = 24
				else
				
					huxi = 12
				end
			end
			return huxi
		--红坎
		elseif (isKan and index1 >= 17) then
		
			huxi = 2
			return huxi
		--黑坎
		elseif (isKan) then
		
			huxi = 1 + iFlower
			return huxi
		end
		--红句
		if (index1 >= 17) then
		
			huxi = 1
			return huxi
		end
		--两个赖子的顺子，只有345，567
		if (iMagic == 2) then
		
			if (index1 == 4) then
			
				if (mainCardIndex == 7) then
				
					huxi = 2 + 2
					return huxi
				else
				
					huxi = 4 + 2
					return huxi
				end
			elseif (index1 == 6) then
			
				if (mainCardIndex == 3) then
				
					huxi = 2 + 2
					return huxi
				else
				
					huxi = 4 + 2
					return huxi
				end
			end
		--1个赖子的顺子
		elseif (iMagic == 1) then
		
			local changeMagicIndex = 0
			if (index1 == (index2 - 1)) then
			
				if (((index2 + 1) == 3 or (index2 + 1) == 5 or (index2 + 1) == 7)) then
				
					changeMagicIndex = index2 + 1
				elseif (((index1 - 1) == 3 or (index1 - 1) == 5 or (index1 - 1) == 7)) then
					changeMagicIndex = index1 - 1	
				elseif (index1 == 13 and index2 == 14) then--话三千
					changeMagicIndex = 3
				end
			elseif (index1 == 10 and index2 == 15) then--七十土
				changeMagicIndex = 7
			elseif (index1 == (index2 - 2) and ((index1 + 1) == 3 or (index1 + 1) == 5 or (index1 + 1) == 7)) then
			
				changeMagicIndex = index1 + 1
			end
			if (index1 == 3 or index1 == 5 or index1 == 7) then
			
				if (bit.band(cards[1], 0xF0) == 0x10) then
				
					huxi = huxi + 2 + (index1 == mainCardIndex and 2 or 0)
				else
				
					huxi = huxi + 1 + (index1 == mainCardIndex and 1 or 0)
				end
			elseif (bit.band(cards[1], 0xF0) == 0x10) then
			
				huxi = huxi + 1
			end
			if (index2 == 3 or index2 == 5 or index2 == 7) then
			
				if (bit.band(cards[2], 0xF0) == 0x10) then
				
					huxi = huxi + 2 + (index2 == mainCardIndex and 2 or 0)
				else
				
					huxi = huxi + 1 + (index2 == mainCardIndex and 1 or 0)
				end
			elseif (bit.band(cards[2], 0xF0) == 0x10) then
			
				huxi = huxi + 1
			end
			huxi = huxi + 2 + (changeMagicIndex == mainCardIndex and 2 or 0)
			return huxi
		--没有赖子的顺子
		else
		
			if (index1 == 3 or index1 == 5 or index1 == 7) then
			
				if (bit.band(cards[1], 0xF0) == 0x10) then
				
					huxi = huxi + 2 + (index1 == mainCardIndex and 2 or 0)
				else
				
					huxi = huxi + 1 + (index1 == mainCardIndex and 1 or 0)
				end
			elseif (bit.band(cards[1], 0xF0) == 0x10) then
			
				huxi = huxi + 1
			end
			if (index2 == 3 or index2 == 5 or index2 == 7) then
			
				if (bit.band(cards[2], 0xF0) == 0x10) then
				
					huxi = huxi + 2 + (index2 == mainCardIndex and 2 or 0)
				else
				
					huxi = huxi + 1 + (index2 == mainCardIndex and 1 or 0)
				end
			elseif (bit.band(cards[2], 0xF0) == 0x10) then
			
				huxi = huxi + 1
			end
			if (index3 == 3 or index3 == 5 or index3 == 7) then
			
				if (bit.band(cards[3], 0xF0) == 0x10) then
				
					huxi = huxi + 2 + (index3 == mainCardIndex and 2 or 0)
				else
					huxi = huxi + 1 + (index3 == mainCardIndex and 1 or 0)
				end
			elseif (bit.band(cards[3], 0xF0) == 0x10) then
				huxi = huxi + 1
			end
			return huxi
		end
	elseif (len == 4) then
		local index1 = CardUtils:GetCardLogicValue(cards[1])
		--经4
		if ((index1 == 3 or index1 == 5 or index1 == 7)) then
			local iFlowerOrMagic = 0--花牌或者赖子数量
			-- for (local i = 0 i < 4 i++)
			for i = 1, 4 do
				if (bit.band(cards[i], 0xF0) == 0x10) then
					iFlowerOrMagic = iFlowerOrMagic + 1
				elseif (cards[i] == Magic_Card) then
					iFlowerOrMagic = iFlowerOrMagic + 1
				end
			end
			if (iFlowerOrMagic == 1) then
				huxi = 12 + (index1 == mainCardIndex and 12 or 0)
			elseif (iFlowerOrMagic == 2) then
				huxi = 14 + (index1 == mainCardIndex and 14 or 0)
			elseif (iFlowerOrMagic == 3) then
				huxi = 18 + (index1 == mainCardIndex and 18 or 0)
			elseif (iFlowerOrMagic == 4) then
				huxi = 24 + (index1 == mainCardIndex and 24 or 0)
			end
			return huxi
		elseif (index1 >= 17) then--红4
			huxi = 4
			return huxi
		elseif (index1 == 1 or index1 == 9) then--可能带花的黑4
			local flowerNum = 0
			-- for (local k = 0 k < 4 k++)
			for k = 1, 4 do
				if (bit.band(cards[k], 0xF0) == 0x10) then--花牌
					flowerNum= flowerNum+ 1
				end
			end
			huxi = (2 + flowerNum)
			return huxi
		else
			huxi = 2
			return huxi
		end
	elseif (len == 5) then
		local index1 = CardUtils:GetCardLogicValue(cards[1])
		--经5
		if ((index1 == 3 or index1 == 5 or index1 == 7)) then
			local iFlowerOrMagic = 0--花牌或者赖子数量
			--for (local i = 0 i < 5 i++)
			for i = 1, 5 do
				if (bit.band(cards[i], 0xF0) == 0x10) then
					iFlowerOrMagic = iFlowerOrMagic + 1
				elseif (cards[i] == Magic_Card) then
					iFlowerOrMagic = iFlowerOrMagic + 1
				end
			end
			if (iFlowerOrMagic == 2) then
				huxi =28 + (index1 == mainCardIndex and 28 or 0)
			elseif (iFlowerOrMagic == 3) then
				huxi =36 + (index1 == mainCardIndex and 36 or 0)
			elseif (iFlowerOrMagic == 4) then
				huxi =48 + (index1 == mainCardIndex and 48 or 0)
			end
			return huxi
		elseif (index1 >= 17) then--红5
			huxi = 8
			return huxi
		elseif (index1 == 1 or index1 == 9) then--带花的黑5
			huxi = 6
			return huxi
		else
			huxi = 4
			return huxi
		end
	end
	return huxi
end

function CardHuXiUtils:IsKanWeave( cards )
	if #cards ~= 3 then
		return false
	end
	table.sort(cards, function( a, b )
		local carda = CardUtils:GetCardLogicValue(a)
		local cardb = CardUtils:GetCardLogicValue(b)
		return carda < cardb
	end)
	local index1 = CardUtils:GetCardLogicValue(cards[1])
	local index2 = CardUtils:GetCardLogicValue(cards[2])
	local index3 = CardUtils:GetCardLogicValue(cards[3])
	local isKan = false
	if (index1 == index2 and (index1 == index3 or index3 == 23)) then
		isKan = true
	elseif (((index1 == 3 or index1 == 5 or index1 == 7)) and index2 == index3 and index2 == 23) then
		isKan = true
	elseif (index1 == index2 and index3 == 23) then
		isKan = true
	end
	return isKan
end

return CardHuXiUtils