--local m_byHandCardData = {1,2,3, 3, 4, 4, 5, 0x16, 7, 8, 9, 0x11, 0x12, 0x13}
--local m_byHandCardData = {1,2,3, 3, 4, 4, 5, 6, 7, 8, 9}

local PHZ_Ting = class("PHZ_Ting")
function PHZ_Ting:ctor()
end

local	CARD_GROUP_TYPE_HUA = 1
local	CARD_GROUP_TYPE_PENG = 2
local	CARD_GROUP_TYPE_KAN = 3
local	CARD_GROUP_TYPE_JIANG = 4

local GetCardValue = function(c)
	return bit.band(c,0x0F)
end
local GetCardColor = function(c)
	return bit.band(c, 0xF0) == 0x10 and 1 or 0 
end

local calXi4CardGroup = function(group)
	local cardGroup = group.cards
	if #cardGroup ~= 3 then
		return 0
	end
	local card1 = cardGroup[1]
	local row = GetCardColor(card1)
	local col = GetCardValue(card1)
	
	if group.type == CARD_GROUP_TYPE_KAN then
		if row == 0 then
			return 3
		else
			return 6
		end
	elseif group.type == CARD_GROUP_TYPE_PENG then
		if row == 0 then
			return 1
		else
			return 3
		end
	elseif group.type == CARD_GROUP_TYPE_JIANG then
		return 0
	else
		if col == 1 then
			if cardGroup[2] == card1 + 1 and cardGroup[3] == card1 + 2 then
				if row == 0 then
					return 3
				else
					return 6
				end
			else
				return 0
			end
		elseif col ==2 then
			if cardGroup[2] == card1 + 5 and cardGroup[3] == card1 + 8 then
				if row == 0 then
					return 3
				else
					return 6
				end
			else
				return 0
			end
		else
			return 0
		end
	end
end
local v1IsSame = function(v1,v2)
	if #v1 ~= #v2 then
		return false
	end
	for i=1, #v1 do
		if v1[i] ~= v2[i] then
			return false
		end
	end
	return true
end

local v2IsSame = function(v2a,v2b)
	if #v2a ~= #v2b then
		return false
	end
	local len = #v2a
	local count = 0
	for i=1, len do
		for j=1, len do
			if v1IsSame(v2a[i], v2b[j]) then
				count = count + 1
				break
			else
				if j == len then
					return false
				end
			end
		end
	end
	if count ~= len then
		return false
	end
	
	count = 0
	for i=1, len do
		for j=1, len do
			if v1IsSame(v2b[i], v2a[j]) then
				count = count + 1
				break
			else
				if j == len then
					return false
				end
			end
		end
	end
	if count ~= len then
		return false
	end
	return true
end

local V2InV3 = function(v2, v3)
	for i=1, #v3 do
		if v2IsSame(v2, v3[i]) then
			return true
		end
	end
	return false
end

local NewCalMinReq = function(seqs, card, reqList, maxGroupCount, count)
	local result = {}
	local reqListTemp = {}
	for p=1, #seqs do
		local seq = seqs[p]
		local size = #seq
		local currentReq = reqList[p]
		
		local m = false
		for i=size, 1, -1 do
			repeat
			
			local l = seq[i]
			local sizeT = #l
			
			if sizeT == 3 then
				break--模拟continue
			end
			
			local v = l[sizeT]
			
			if sizeT == 1 then
				local col = GetCardValue(v)
				
				if card == v or card == v + 1 or card == v + 2 or card == v + 16 or (col == 2 and (card == v + 5 or card == v + 8)) or (col == 7 and card == v + 3) then
					local seqT = clone(seq)
					local values = clone(seqT[i])
					values[ #values + 1 ] = card
					seqT[i] = values
					
					if not V2InV3(seqT, result) then
						result[ #result + 1 ] = seqT
						reqListTemp[ #reqListTemp + 1 ] = currentReq - 1
					end
				end
			else
				local v1 = l[1]
				local v2 = l[2]
				
				if (v1 == v2 and (card == v2 + 16 or card == v2)) or (v1 + 16 == v2 and v2 == card) or (v1 == v2 - 1 and v2 == card - 1) or
				 (v1 == v2 - 5 and v2 == card - 3) then
					local seqT = clone(seq)
					local values = clone(seqT[i])
					values[ #values + 1 ] = card
					seqT[i] = values
					
					if not V2InV3(seqT, result) then
						result[ #result + 1 ] = seqT
						reqListTemp[ #reqListTemp + 1 ] = currentReq - 1
					end
				end
			end
			
			until true
		end
		
		--优化
		if (not m) and #seq < maxGroupCount + 1 and (currentReq) < count then
		--if (not m) and #seq < maxGroupCount + 1 then
			local nl = {card}
			local seqT = clone(seq)
			seqT[ #seqT + 1 ] = nl
			
			if not V2InV3(seqT, result) then
				result[ #result + 1 ] = seqT
				reqListTemp[ #reqListTemp + 1 ] = currentReq + 2
			end
		end
	end
	
	reqList = reqListTemp
	return result, reqList
end

local checkTingWithoutJiang = function(cards, jiangIndex, isDouble, cardGroup, cardGroupList)
	local maxGroupCount = math.floor((#cards + 1) / 3)
	local seqs = {}
	local reqList = {}
	local b = true
	local forFlag = true
	for i=1, #cards do
		if forFlag then
			repeat
				if jiangIndex > -1 and (i == jiangIndex or (isDouble and i == jiangIndex + 1)) then
					break
				end
				
				if #seqs == 0 and b then
					local l1 = {{cards[i]}}
					seqs[ #seqs + 1 ] = l1
					reqList[ #reqList + 1 ] = 2
					b = false
				else
					seqs, reqList = NewCalMinReq(seqs, cards[i], reqList, maxGroupCount, #cards - i)
					if #seqs > 2000 then
						print('--!!!!!!!!!checkTingWithoutJiang seqs is big!!!!!---', #seqs)
						forFlag = false
						seqs = {}
						reqList = {}
						break
					end
				end
			until true
		else
			break
		end
	end
	
	if b then
		return 0
	end
	
	if #reqList == 0 then
		return -1
	end
	
	local maxXi = -1
	
	local cardGroupTemp = {}
	
	for i = 1, #reqList do
		if jiangIndex < 0 or isDouble then
			if reqList[i] == 1 then
				local combines = seqs[i]
				local temp = {}
				local xi = 0
				for j = 1, #combines do
					local vec = combines[j]
					
					local group = {type = -1, cards={}}
					if #vec == 3 then
						if vec[1] == vec[2] and vec[1] == vec[3] then
							group.type = CARD_GROUP_TYPE_PENG
						else
							group.type = CARD_GROUP_TYPE_HUA
						end
						
						for k=1, #vec do
							group.cards[ #group.cards + 1 ] = vec[k]
						end
					elseif #vec == 2 then
						local card1 = vec[1]
						local card2 = vec[2]
						
						local group = {type = -1, cards={}}
						local groupTemp = {type = -1, cards={}}
						groupTemp.cards[1] = card1
						groupTemp.cards[2] = card2
						cardGroupList[ #cardGroupList + 1 ] = groupTemp
						if card1 == card2 then
							group.type = CARD_GROUP_TYPE_KAN
							group.cards[1] = card1
							group.cards[2] = card1
							group.cards[3] = card1
						else
							group.type = CARD_GROUP_TYPE_HUA
							local row1 = GetCardColor(card1)
							local row2 = GetCardColor(card2)
							local col1 = GetCardValue(card1)
							local col2 = GetCardValue(card2)
							
							if row1 == row2 then
								if col2 < 4 then
									group.cards[1] = row1*16 + 1
									group.cards[2] = row1*16 + 2
									group.cards[3] = row1*16 + 3
								elseif (col1 == 2 or col1 == 7 or col1 == 10) and (col2 == 2 or col2 == 7 or col2 == 10) then
									group.cards[1] = row1*16 + 2
									group.cards[2] = row1*16 + 7
									group.cards[3] = row1*16 + 10
								else
									if card1 == card2 - 2 then
										group.cards[1] = card1
										group.cards[2] = card1+1
										group.cards[3] = card2
									else
										group.cards[1] = card1-1
										group.cards[2] = card1
										group.cards[3] = card2
									end
								end
							else
								group.cards[1] = card1
								group.cards[2] = card1
								group.cards[3] = card2
							end
						end
					end
					
					xi = xi + calXi4CardGroup(group)
					temp[ #temp + 1 ] = group 
				end
				
				if xi > maxXi then
					maxXi = xi
					cardGroupTemp = temp
				end
			end
		else
			if reqList[i] == 0 then
				--满足胡牌牌型，还得算出最大胡息
				local combines = seqs[i]
				local temp = {}
				local xi = 0
				for j = 1, #combines do
					local vec = combines[j]
					local group = {type = -1, cards={}}
					
					if #vec == 3 and vec[1] == vec[2] and vec[1] == vec[3] then
						group.type = CARD_GROUP_TYPE_PENG
					else
						group.type = CARD_GROUP_TYPE_HUA
					end
					
					for k=1, #vec do
						group.cards[k] = vec[k]
					end
					
					xi = xi + calXi4CardGroup(group)
					temp[ #temp + 1 ] = group
				end
				
				if xi > maxXi then
					maxXi = xi
					cardGroupTemp = temp
				end
			end
		end
	end
	
	for i = 1, #cardGroupTemp do
		cardGroup[ #cardGroup + 1 ] = cardGroupTemp[i]
	end
	
	return maxXi
end

local checkTingWithJiang = function(cards, cardGroup, cardGroupList)
	local maxXi = -1
	local cardGroupTemp = {}
	
	--特殊的写法，因为lua里无法修改循环变量的值
	local i = 1
	for value in function()
		if i < #cards and cards[i] == cards[i+1] then
			local temp = {}
			local xi = checkTingWithoutJiang(cards, i, true, temp, cardGroupList)
			--print('checkTingWithJiang  ', xi, i)
			if xi > -1 then
				local group = {type = CARD_GROUP_TYPE_JIANG, cards = {cards[i],cards[i]}}
				temp[ #temp + 1 ] = group
				
				maxXi = xi
				local groupTemp = {cards= {cards[i]}}
				cardGroupList[ #cardGroupList + 1 ] = groupTemp
				cardGroupTemp = temp
			end
			i = i + 1
		else
			local temp = {}
			local xi = checkTingWithoutJiang(cards, i, false, temp, cardGroupList)
			
			if xi > -1 then
				local group = {type = CARD_GROUP_TYPE_JIANG, cards = {cards[i],cards[i]}}
				temp[ #temp + 1 ] = group
				
				maxXi = xi
				local groupTemp = {cards={cards[i]}}
				cardGroupList[ #cardGroupList + 1 ] = groupTemp
				cardGroupTemp = temp
			end
		end
		i = i + 1
		return i
	end do
	--print('---checkTingWithJiang--', value, #cards)
	if value > #cards then
		break
	end
	end
	--end
	
	for i = 1, #cardGroupTemp do
		cardGroup[ #cardGroup + 1 ] = cardGroupTemp[i]
	end
	
	return maxXi
end

local isHuWithoutJiang = function(cards, jiangIndex, cardGroup)
	local maxGroupCount = math.floor((#cards) / 3)
	local seqs = {}
	local reqList = {}
	local b = true
	local forFlag = true
	for i=1, #cards do
		if forFlag then
			repeat
				if jiangIndex > -1 and (i == jiangIndex or i == jiangIndex + 1) then
					break
				end
				
				if #seqs == 0 and b then
					local l1 = {{cards[i]}}
					seqs[ #seqs + 1 ] = l1
					reqList[ #reqList + 1 ] = 2
					b = false
				else
					seqs, reqList = NewCalMinReq(seqs, cards[i], reqList, maxGroupCount, #cards - i)
					if #seqs > 2500 then
						print('--!!!!!!!!!isHuWithoutJiang seqs is big!!!!!---', #seqs)
						forFlag = false
						seqs = {}
						reqList = {}
						break
					end
				end
			until true
		else
			break
		end
	end
	
	if b then
		return 0
	end
	
	if #reqList == 0 then
		return -1
	end
	
	local maxXi = -1
	
	local cardGroupTemp = {}
	
	for i = 1, #reqList do
		if reqList[i] == 0 then
			local combines = seqs[i]
			local temp = {}
			local xi = 0
			for j = 1, #combines do
				local vec = combines[j]
				
				local group = {type = -1, cards={}}
				if #vec == 3 and vec[1] == vec[2] and vec[1] == vec[3] then
					group.type = CARD_GROUP_TYPE_PENG
				else
					group.type = CARD_GROUP_TYPE_HUA
				end
					
				for k=1, #vec do
					group.cards[ #group.cards + 1 ] = vec[k]
				end
				
				
				xi = xi + calXi4CardGroup(group)
				temp[ #temp + 1 ] = group 
			end
			
			if xi > maxXi then
				maxXi = xi
				cardGroupTemp = temp
			end
		end
	end
	
	for i = 1, #cardGroupTemp do
		cardGroup[ #cardGroup + 1 ] = cardGroupTemp[i]
	end
	
	return maxXi
end

local isHuWithJiang = function(cards, cardGroup)
	local maxXi = -1
	local cardGroupTemp = {}
	
	--特殊的写法，因为lua里无法修改循环变量的值
	local i = 1
	for value in function()
		if i < #cards and cards[i] == cards[i+1] then
			local temp = {}
			local xi = isHuWithoutJiang(cards, i, temp)
			
			if xi > maxXi then
				local group = {type = CARD_GROUP_TYPE_JIANG, cards = {cards[i],cards[i]}}
				temp[ #temp + 1 ] = group
				
				maxXi = xi
				cardGroupTemp = temp
			end
			i = i + 1
		end
		i = i + 1
		return i
	end do
		if value > #cards then
			break
		end
	end
	--end
	
	for i = 1, #cardGroupTemp do
		cardGroup[ #cardGroup + 1 ] = cardGroupTemp[i]
	end
	
	return maxXi
end

local checkTing = function(card_vec, cardGroupList)
	local cardGroup = {}
	local curXi = 0
	local cpyHas = {}
	for i = 1, #card_vec do
		cpyHas[ card_vec[i] ] = (cpyHas[ card_vec[i] ] or 0) + 1
	end
	
	local cards = {}
	for i = 1, 27 do
		if cpyHas[i] and cpyHas[i] > 0 then
			for k=1, cpyHas[i] do
				cards[ #cards + 1 ] = i
			end
		end
	end
	
	local len = #cards
	if len == 0 then
		return -1
	end
	
	-------------todo---------此处要修改
	local hasTiOrPao = g_CardScene:isTiOrPao(0)
	--print('----checkTing--', hasTiOrPao)
	if hasTiOrPao then
		if (len % 3) ~= 1 then
			return -1
		end
	else
		if (len % 3) ~= 2 then
			return -1
		end
	end
	
	if hasTiOrPao then
		local xi = checkTingWithJiang(cards, cardGroup, cardGroupList)
		if xi > -1 then
			return curXi + xi
		else
			return -1
		end
	else
		local xi = checkTingWithoutJiang(cards, -1, true, cardGroup, cardGroupList)
		if xi > -1 then
			return curXi + xi
		else
			return -1
		end
	end
	
end

local CanHuPaiTest = function(cardGroup, listCs, opCard)
	local curXi = g_CardScene:getHuXiCount(0)
	
	local cpyHas = {}
	for i=1, #listCs do
		cpyHas[ listCs[i] ] = (cpyHas[ listCs[i] ] or 0) + 1
		--print('xmz ', i, listCs[i], cpyHas[listCs[i]])
	end
	
	local cards = {}
	if opCard ~= 0 then
		cards[ #cards + 1 ] = opCard
	end
	--dump(cpyHas, 'CanHuPaiTest-cpyHas')
	for i=1, 26 do
		if cpyHas[i] == 3 then
			cardGroup[ #cardGroup + 1 ] = {type = CARD_GROUP_TYPE_KAN, cards={i, i, i}}
		elseif cpyHas[i] and cpyHas[i] > 0 then
			for k=1, cpyHas[i] do
				
				cards[ #cards + 1 ] = i
			end
		end
	end
	
	-----------------------todo-----修改为是否有提或者跑-------
	local hasTiOrPao = g_CardScene:isTiOrPao(0)
	
	for i=1, #cardGroup do
		curXi = curXi + calXi4CardGroup(cardGroup[i])
	end
	table.sort(cards)
	--dump(listCs, 'CanHuPaiTest-listCs')
	--dump(cards, 'CanHuPaiTest-cards')
	
	if #cards == 0 then
		cardGroupList = cardGroup
		return curXi
	else
		if hasTiOrPao then
			if (#cards % 3) ~= 2 then
				return -1
			end
			
			local xi = isHuWithJiang(cards, cardGroup)
			if xi > -1 then
				cardGroupList = cardGroup
				--print('-CanHuPaiTest--',xi)
				--dump(cardGroupList,'cardGroupList')
				return curXi + xi
			else
				return -1
			end
		else
			if (#cards % 3) ~= 0 then
				return -1
			end
			
			local xi = isHuWithoutJiang(cards, -1, cardGroup)
			if xi > -1 then
				cardGroupList = cardGroup
				return curXi + xi
			else
				return -1
			end
		end
	end
end

local tingParam = function(cards, outCard)
	local m_byHandCardData = g_CardScene:getMyHandCardData()
	local list = {}
	for _, card in pairs(cards) do
		local cardGroup = {}
		local card_vec = {}
		
		--去一张牌
		local bFlag = false
		------------------todo----添加手牌----
		for i=1, #m_byHandCardData do
			repeat
			if not bFlag and m_byHandCardData[i] == outCard then
				bFlag = true
				break
			end
			card_vec[ #card_vec + 1 ] = m_byHandCardData[i]
			until true
		end
		
		--dump(card_vec, 'card_vec')
		local huxi = CanHuPaiTest(cardGroup, card_vec, card)
		--dump(cardGroup, 'cardGroup')
		print('tingParam----', card, huxi, outCard)
		---------------todo----添加胡牌胡息数
		if huxi >= GAME_HU_XI then
			list[ #list + 1 ] = card
		end
	end
	return list
end

function PHZ_Ting:CheckTingCard(handCards)
	do
		return {}
	end
	local checkOutCard = {}
	local cards = {}
	local hasCards = {}
	for i=1, #handCards do
		hasCards[ handCards[i] ] = (hasCards[ handCards[i] ] or 0) + 1
	end
	
	for card, num in pairs(hasCards) do
		if num == 1 or num == 2 then
			checkOutCard[ card ] = true
			
			for i=1, num do
				cards[ #cards + 1 ] = card
			end
		end
	end
	
	local m_mapTingInfo = {}
	
	if #cards > 15 then
		print('----no cal ting info---')
		return m_mapTingInfo
	end
	
	for OutCard, _ in pairs(checkOutCard) do
		local has = {}
		for j=1, #cards do
			has[ cards[j] ] = (has[ cards[j] ] or 0) + 1
		end
		has[ OutCard ] = has[ OutCard ] - 1
		
		local card_vec = {}
		for j=1, 26 do
			if has[j] and has[j] > 0 then
				for k=1, has[j] do
					card_vec[ #card_vec + 1 ] = j
				end
			end
		end
		
		local m_huCardGroup = {}
		local mapList = {}
		checkTing(card_vec, m_huCardGroup)
		--dump(m_huCardGroup, 'xx')
		--dump(card_vec, 'yy')
		for j=1, #m_huCardGroup do
			if #m_huCardGroup[j].cards == 2 then
				local card = GetCardValue(m_huCardGroup[j].cards[1])
				local card1 = GetCardValue(m_huCardGroup[j].cards[2])
				if m_huCardGroup[j].cards[1] == m_huCardGroup[j].cards[2] then
					mapList[ m_huCardGroup[j].cards[1] ] = m_huCardGroup[j].cards[1]
					if m_huCardGroup[j].cards[1] > 16 then
						mapList[card] = card
					else
						mapList[ card + 16 ] = card + 16
					end
				elseif card == 2 and card1 == 7 then
					if m_huCardGroup[j].cards[1] > 16 then
						mapList[0x1A] = 0x1A
					else
						mapList[0x0A] = 0x0A
					end
				elseif card == 7 and card1 == 0x0A then
					if m_huCardGroup[j].cards[1] > 16 then
						mapList[0x12] = 0x12
					else
						mapList[0x02] = 0x02
					end
				elseif card == 2 and card1 == 0x0A then
					if m_huCardGroup[j].cards[1] > 16 then
						mapList[0x17] = 0x17
					else
						mapList[0x07] = 0x07
					end
				elseif card == (card1-1) then
					if m_huCardGroup[j].cards[1] > 0x11 then
						mapList[m_huCardGroup[j].cards[1] - 1] = m_huCardGroup[j].cards[1] - 1
					elseif m_huCardGroup[j].cards[1] <= 0x0A and m_huCardGroup[j].cards[1] > 0x01 then
						mapList[m_huCardGroup[j].cards[1] - 1] = m_huCardGroup[j].cards[1] - 1
					end
					
					if m_huCardGroup[j].cards[2] < 0x0A then
						mapList[ m_huCardGroup[j].cards[2] + 1 ] = m_huCardGroup[j].cards[2] + 1
					elseif m_huCardGroup[j].cards[2] > 0x0A and m_huCardGroup[j].cards[2] < 0x1A then
						mapList[m_huCardGroup[j].cards[2] + 1] = m_huCardGroup[j].cards[2] + 1
					end
				elseif card == card1 -2 then
					mapList[m_huCardGroup[j].cards[1] + 1] = m_huCardGroup[j].cards[1] + 1
				elseif card == card1 then
					mapList[card] = card
					mapList[card + 16] = card + 16
				end
			end
			
			if #m_huCardGroup[j].cards == 1 then
				mapList[m_huCardGroup[j].cards[1]] = m_huCardGroup[j].cards[1]
			end
		end
		--dump(mapList, 'mapList')
		local items = tingParam(mapList, OutCard)
		--dump(items, '听的牌items')
		--print('打的牌 ', OutCard)
		if #items > 0 then
			m_mapTingInfo[ OutCard ] = items
		end
	end
	
	return m_mapTingInfo
end

function PHZ_Ting:CheckHuCard(handCards)
	-- do
		-- return nil
	-- end
	local cards = {}
	
	local hasCards = {}
	for i=1, #handCards do
		hasCards[ handCards[i] ] = (hasCards[ handCards[i] ] or 0) + 1
	end
	
	for card, num in pairs(hasCards) do
		if num == 1 or num == 2 then
			for i=1, num do
				cards[ #cards + 1 ] = card
			end
		end
	end
	
	
	if #cards > 14 then
		print('----no cal hu info---')
		return nil
	end
	
	local has = {}
	for j=1, #cards do
		has[ cards[j] ] = (has[ cards[j] ] or 0) + 1
	end
		
	local card_vec = {}
	for j=1, 26 do
		if has[j] and has[j] > 0 then
			for k=1, has[j] do
				card_vec[ #card_vec + 1 ] = j
			end
		end
	end
		
	local m_huCardGroup = {}
	local mapList = {}
	checkTing(card_vec, m_huCardGroup)
	--dump(m_huCardGroup, 'xx')
	--dump(card_vec, 'yy')
	for j=1, #m_huCardGroup do
		if #m_huCardGroup[j].cards == 2 then
			local card = GetCardValue(m_huCardGroup[j].cards[1])
			local card1 = GetCardValue(m_huCardGroup[j].cards[2])
			if m_huCardGroup[j].cards[1] == m_huCardGroup[j].cards[2] then
				mapList[ m_huCardGroup[j].cards[1] ] = m_huCardGroup[j].cards[1]
				if m_huCardGroup[j].cards[1] > 16 then
					mapList[card] = card
				else
					mapList[ card + 16 ] = card + 16
				end
			elseif card == 2 and card1 == 7 then
				if m_huCardGroup[j].cards[1] > 16 then
					mapList[0x1A] = 0x1A
				else
					mapList[0x0A] = 0x0A
				end
			elseif card == 7 and card1 == 0x0A then
				if m_huCardGroup[j].cards[1] > 16 then
					mapList[0x12] = 0x12
				else
					mapList[0x02] = 0x02
				end
			elseif card == 2 and card1 == 0x0A then
				if m_huCardGroup[j].cards[1] > 16 then
					mapList[0x17] = 0x17
				else
					mapList[0x07] = 0x07
				end
			elseif card == (card1-1) then
				if m_huCardGroup[j].cards[1] > 0x11 then
					mapList[m_huCardGroup[j].cards[1] - 1] = m_huCardGroup[j].cards[1] - 1
				elseif m_huCardGroup[j].cards[1] <= 0x0A and m_huCardGroup[j].cards[1] > 0x01 then
					mapList[m_huCardGroup[j].cards[1] - 1] = m_huCardGroup[j].cards[1] - 1
				end
				
				if m_huCardGroup[j].cards[2] < 0x0A then
					mapList[ m_huCardGroup[j].cards[2] + 1 ] = m_huCardGroup[j].cards[2] + 1
				elseif m_huCardGroup[j].cards[2] > 0x0A and m_huCardGroup[j].cards[2] < 0x1A then
					mapList[m_huCardGroup[j].cards[2] + 1] = m_huCardGroup[j].cards[2] + 1
				end
			elseif card == card1 -2 then
				mapList[m_huCardGroup[j].cards[1] + 1] = m_huCardGroup[j].cards[1] + 1
			elseif card == card1 then
				mapList[card] = card
				mapList[card + 16] = card + 16
			end
		end
		
		if #m_huCardGroup[j].cards == 1 then
			mapList[m_huCardGroup[j].cards[1]] = m_huCardGroup[j].cards[1]
		end
	end
	--dump(mapList, 'mapList')
	local items = tingParam(mapList)
		--dump(items, '听的牌items')
		--print('打的牌 ', OutCard)
	if #items > 0 then
		return items
	end
	
	return nil
end

return PHZ_Ting
-----------------------------test---------------------------------
-- local t1 = os.clock()
-- local m_mapTingInfo = CheckTingCard(m_byHandCardData)
-- dump(m_mapTingInfo, 'm_mapTingInfo')
-- print('cost  ',(os.clock()-t1)*1000)