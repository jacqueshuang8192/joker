local GXLZData = require("gxlz_majiang.globle.GXLZData")

local CardUtils = class("CardUtils")

function CardUtils:insertCardsByUid(uid, newCard)
	--todo
	local cards = GXLZData:getCards(uid)
	
	self:insertCardsByUid(cards, newCard)
end

function CardUtils:insertCards(cards, newCard)
	if cards and table.getn(cards) > 0 then
		--todo
		local newValue = newCard

		local insertIndex = 1;
		local j = table.getn(cards)
		for i = 1, j do
			local index = math.floor((i + j) / 2)

			dump(index, "cards test")

			if cards[index] < newValue then
				--todo
				i = index + 1
				insertIndex = i
			elseif cards[index] > newValue then
				j = index - 1
				insertIndex = j
			else
				insertIndex = index + 1
				break
			end
		end

		table.insert(cards, insertIndex, newCard)
	end
end

function CardUtils:getPlayerType(seatId)
	dump(seatId,"seat======")
	dump(GXLZ_MY_USERINFO, "GXLZ_MY_USERINFO")
    local other_index = seatId - GXLZ_MY_USERINFO.seat_id

    dump(other_index, "playerType test")

	local playerType = CARD_PLAYERTYPE_MY
    if other_index < 0 then
      other_index = other_index + GXLZ_PLAYER_COUNT
    end

    if GXLZ_PLAYER_COUNT == 4 then
    	--todo
    	if other_index == 1 then
	    	playerType = CARD_PLAYERTYPE_RIGHT
	    elseif other_index == 2 then
	    	playerType = CARD_PLAYERTYPE_TOP
	    elseif other_index == 3 then
	    	playerType = CARD_PLAYERTYPE_LEFT
	    end
	elseif GXLZ_PLAYER_COUNT == 3 then
		if other_index == 1 then
	    	playerType = CARD_PLAYERTYPE_RIGHT
	    elseif other_index == 2 then
	    	playerType = CARD_PLAYERTYPE_LEFT
	    end
	elseif GXLZ_PLAYER_COUNT == 2 then
		if other_index == 1 then
	    	playerType = CARD_PLAYERTYPE_TOP
	    end
    end

    return playerType
end

-- status 1：出牌 2：摸牌 3：重连
function CardUtils:getControlTable(handle, handleCard, status, ableGangCards)

	local result = {}
	result["type"] = handle
	result["value"] = handleCard

	if status == 1 then
		--todo

		local gangCards = {}
		if bit.band(handle, CONTROL_TYPE_GANG) > 0 then
			--todo
			local gangCard = {}
			gangCard.value = handleCard
			gangCard.type = bit.band(handle, CONTROL_TYPE_GANG)
			table.insert(gangCards, gangCard)
		end
		result["gangCards"] = gangCards
	elseif status == 2 then
		local gangCards = {}
		for k,v in pairs(ableGangCards) do
			if v > 0 then
				--todo
				local gangCard = {}
				gangCard.value = v

				local gangType = nil
				if k < 5 then
					--todo
					gangType = GANG_TYPE_AN
				else
					gangType = GANG_TYPE_BU
				end
				gangCard.type = gangType
				table.insert(gangCards, gangCard)
			end
		end
		
		result["gangCards"] = gangCards
	elseif status == 3 then
		local gangCards = {}
		local m = false
		for k,v in pairs(ableGangCards) do
			if v > 0 then
				--todo
				m = true
				
				local gangCard = {}
				gangCard.value = v

				local gangType = nil
				if k < 5 then
					--todo
					gangType = GANG_TYPE_AN
				else
					gangType = GANG_TYPE_BU
				end
				gangCard.type = gangType
				table.insert(gangCards, gangCard)
			end
		end

		if not m then
			--todo
			if bit.band(handle, CONTROL_TYPE_GANG) > 0 then
				--todo
				local gangCard = {}
				gangCard.value = handleCard
				gangCard.type = bit.band(handle, CONTROL_TYPE_GANG)
				table.insert(gangCards, gangCard)
			end
		end

		result["gangCards"] = gangCards
	end

	return result
end

function CardUtils:processControl(seatId, handle, value)
	local progCards = {}

	local removeCards = {}

	if bit.band(handle, CONTROL_TYPE_GANG) > 0 then
		--todo
		if bit.band(handle, GANG_TYPE_BU) > 0 then
			--todo
			for i=1,4 do
				table.insert(progCards, value)
			end
			table.insert(removeCards, value)
		else
			for i=1,3 do
				table.insert(progCards, value)
				table.insert(removeCards, value)
			end
			table.insert(progCards, value)
			if bit.band(handle, GANG_TYPE_AN) > 0 then
				--todo
				table.insert(removeCards, value)
			end
		end
		
	elseif bit.band(handle, CONTROL_TYPE_PENG) > 0 then
		for i=1,2 do
			table.insert(progCards, value)
			table.insert(removeCards, value)
		end
		table.insert(progCards, value)
	elseif bit.band(handle, CHI_TYPE_LEFT) > 0 then
		for i=value,value + 2 do
			if value ~= i then
				--todo
				table.insert(removeCards, i)
			end

			table.insert(progCards, i)
		end
	elseif bit.band(handle, CHI_TYPE_MIDDLE) > 0 then
		for i=value - 1,value + 1 do
			if value ~= i then
				--todo
				table.insert(removeCards, i)
			end

			table.insert(progCards, i)
		end
	elseif bit.band(handle, CHI_TYPE_RIGHT) > 0 then
		for i=value - 2,value do
			if value ~= i then
				--todo
				table.insert(removeCards, i)
			end

			table.insert(progCards, i)
		end
	end

	if table.getn(removeCards) > 0 then
		--todo
		self:removeCards(seatId, removeCards)
	end

	return progCards, removeCards
end

function CardUtils:removeCards(seatId, removeCards)
	local oriCards = GXLZ_GAMEINFO_TABLE[seatId .. ""].hand

	local count = table.getn(oriCards)
	local removeCount = table.getn(removeCards)

	local removeIndex = 1

	local removeIndexs = {}
	for i=1,count do
		if oriCards[i] == removeCards[removeIndex] or oriCards[i] == 0 then
			--todo
			table.insert(removeIndexs, i)
			removeIndex = removeIndex + 1

			if removeIndex > removeCount then
				--todo
				break
			end
		end
	end

	for i=table.getn(removeIndexs),1,-1 do
		table.remove(oriCards, removeIndexs[i])
	end
end

function CardUtils:playCard(seatId, value)
	local oriCards = GXLZ_GAMEINFO_TABLE[seatId .. ""].hand

	local tag = nil
	for i=1,table.getn(oriCards) do
		if oriCards[i] == 0 or oriCards[i] == value then
			--todo
			tag = i
			table.remove(oriCards, i)
			return tag
		end
	end

	if not tag then
		--todo
		for i=1,table.getn(oriCards) do
			if oriCards[i] == -1 then
				--todo
				tag = i
				table.remove(oriCards, i)
				return tag
			end
		end
	end
	
	return tag
end

function CardUtils:getNewCard(seatId, value)
	dump(seatId, "getNewCard seatId test")
	dump(GXLZ_GAMEINFO_TABLE, "getNewCard GXLZ_GAMEINFO_TABLE test")

	local oriCards = GXLZ_GAMEINFO_TABLE[seatId .. ""].hand

	-- self:insertCards(oriCards, value)

	table.insert(oriCards, value)
	table.sort(oriCards)

	dump(oriCards, "sort cards test")
end

return CardUtils