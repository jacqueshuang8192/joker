local csmjData = require("cs_majiang.globle.CSMJData")

local CardUtils = class("CardUtils")

function CardUtils:insertCardsByUid(uid, newCard)
	--todo
	local cards = csmjData:getCards(uid)
	
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
	local other_index
	if CSMJ_MY_USERINFO == nil or CSMJ_MY_USERINFO.seat_id == nil or CSMJ_MY_USERINFO.seat_id < 0 then
		other_index = seatId + 1
	else
		other_index = seatId - CSMJ_MY_USERINFO.seat_id
	end

	--seatId = 4 CSMJ_MY_USERINFO.seat_id = 0 other_index = 4  对的  CARD_PLAYERTYPE_MY = 1
	--seatId = 1 CSMJ_MY_USERINFO.seat_id = 0 other_index = 1  对的	 CARD_PLAYERTYPE_TOP = 4

	--seatId = 4 CSMJ_MY_USERINFO.seat_id = 1 other_index = 3  对的	 CARD_PLAYERTYPE_MY = 1
	--seatId = 1 CSMJ_MY_USERINFO.seat_id = 1 other_index = 0  错的	 CARD_PLAYERTYPE_MY = 1

	dump(other_index, "playerType test")

	local playerType = CARD_PLAYERTYPE_MY --1
	if  CS_PLAYERNUM == 4 then

		if other_index < 0 then
			other_index = other_index + 4
		end

		if other_index == 1 then
			playerType = CARD_PLAYERTYPE_RIGHT
		elseif other_index == 2 then
			playerType = CARD_PLAYERTYPE_TOP
		elseif other_index == 3 then
			playerType = CARD_PLAYERTYPE_LEFT
		end

	elseif  CS_PLAYERNUM == 2 then

		if other_index < 0 then
			other_index = other_index + 2
		end

		if other_index == 1 then  --2020/10/28
		--if other_index == 1 or other_index == 0 then
			playerType = CARD_PLAYERTYPE_TOP --4
		end


	elseif  CS_PLAYERNUM == 3 then

		if other_index < 0 then
			other_index = other_index + 3
		end

		if other_index == 1 then
			playerType = CARD_PLAYERTYPE_RIGHT
		elseif other_index == 2 then
			playerType = CARD_PLAYERTYPE_LEFT
		end

	end
	return playerType
end

function CardUtils:getControlTable(pack, handleCard, buzhangSeq, gangSeq)

	local result = {}

	result["type"] = pack.handle
	if pack.has_bonus == 1 then
		result["type"] = result["type"] + BU_ZHANG_TYPE 
	end

	local buzhangCards = {}
	local gangCards = {}

	if buzhangSeq then
		--todo
		for i,v in ipairs(buzhangSeq) do
			if v > 0 then
				--todo
				local buzhangCard = {}
				buzhangCard.value = v
				if i < 5 then
					--todo
					buzhangCard.type = GANG_TYPE_AN
				else
					buzhangCard.type = GANG_TYPE_BU
				end

				table.insert(buzhangCards, buzhangCard)
			end
		end
	end

	if gangSeq then
		--todo
		for i,v in ipairs(gangSeq) do
			if v > 0 then
				--todo
				local gangCard = {}
				gangCard.value = v
				if i < 5 then
					--todo
					gangCard.type = GANG_TYPE_AN
				else
					gangCard.type = GANG_TYPE_BU
				end

				table.insert(gangCards, gangCard)
			end
		end
	end

	if bit.band(pack.handle, GANG_TYPE_PG) > 0 then
		--todo
		local buzhangCard = {}
		buzhangCard.value = handleCard
		buzhangCard.type = GANG_TYPE_PG

		table.insert(buzhangCards, buzhangCard)

		if pack.has_bonus == 1 then
			--todo
			local gangCard = {}
			gangCard.value = handleCard
			gangCard.type = GANG_TYPE_PG

			table.insert(gangCards, gangCard)
		end
	end

	result["buzhangCards"] = buzhangCards
	result["gangCards"] = gangCards

	-- --print("{}{}{}{}{} -- CardUtils:getControlTable", result["type"])

	if handleCard then
		--todo
		result["value"] = handleCard
		return result
	end

	local cards = pack.cards

	if cards[1] > 0 then
		--todo
		result["value"] = cards[1]

		return result
	end

	if cards[5] > 0 then
		--todo
		result["value"] = cards[5]

		return result
	end

	result["value"] = 0

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
		local insertIndex = value
		for i=value,value + 2 do
			if value ~= i then
				--todo
				table.insert(removeCards, i)
			end

			-- 被吃居中放置
			-- table.insert(progCards, i) -- ori code
			if i == value then
				table.insert(progCards, i+1) 
			elseif i == value + 1 then
				table.insert(progCards, i-1) 
			elseif i == value + 2 then
				table.insert(progCards, i) 
			end
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

			-- 被吃居中放置
			-- table.insert(progCards, i) -- ori code
			if i == value then
				table.insert(progCards, i-1) 
			elseif i == value - 1 then
				table.insert(progCards, i+1) 
			elseif i == value - 2 then
				table.insert(progCards, i) 
			end
		end
	end

	if table.getn(removeCards) > 0 then
		--todo
		self:removeCards(seatId, removeCards)
	end

	return progCards, removeCards
end

function CardUtils:removeCards(seatId, removeCards)
	local oriCards = CSMJ_GAMEINFO_TABLE[seatId .. ""].hand

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

	local liangCards = CSMJ_GAMEINFO_TABLE[seatId .. ""].liangCards
	if liangCards then
		--todo
		for i,v in ipairs(removeCards) do
			for i1,v1 in ipairs(liangCards) do
				if v == v1 then
					--todo
					table.remove(liangCards, i1)
					break
				end
			end
		end
	end

	-- local countTest = table.getn(oriCards)
	-- if countTest % 3 ~= 2 then
	-- 	--todo
	-- 	local testStr = "相公seatId:" .. seatId
	-- 	require("hall.GameCommon"):showAlert(true, testStr, 300)
	-- 	dump(removeCards, testStr)
	-- end
end

function CardUtils:playCard(seatId, value)
	local oriCards = CSMJ_GAMEINFO_TABLE[seatId .. ""].hand

	local tag = nil
	for i=1,table.getn(oriCards) do
		if oriCards[i] == 0 or oriCards[i] == value then
			--todo
			tag = i
			dump(oriCards[i], "remove card test " .. seatId)
			table.remove(oriCards, i)
			break
		end
	end

	local liangCards = CSMJ_GAMEINFO_TABLE[seatId .. ""].liangCards
	if liangCards then
		--todo
		for i,v in ipairs(liangCards) do
			if v == value then
				--todo
				table.remove(liangCards, i)
				break
			end
		end
	end

	-- local countTest = table.getn(oriCards)
	-- if countTest % 3 ~= 1 then
	-- 	--todo
	-- 	local testStr = "相公seatId:" .. seatId
	-- 	require("hall.GameCommon"):showAlert(true, testStr, 300)
	-- 	dump(value, testStr)
	-- end

	return tag
end

function CardUtils:getNewCard(seatId, value)
	-- dump(seatId, "getNewCard seatId test")
	-- dump(CSMJ_GAMEINFO_TABLE, "getNewCard CSMJ_GAMEINFO_TABLE test")

	local oriCards = CSMJ_GAMEINFO_TABLE[seatId .. ""].hand

	-- self:insertCards(oriCards, value)

	table.insert(oriCards, value)
	table.sort(oriCards)

	-- dump(oriCards, "sort cards test")

	local countTest = table.getn(oriCards)

	-- dump(countTest .. " " .. type(seatId) .. " " .. type(CSMJ_MY_USERINFO.seat_id), "sort cards test")
	-- dump(countTest .. " " .. seatId .. " " .. CSMJ_MY_USERINFO.seat_id, "sort cards test")

	if countTest % 3 ~= 2 and seatId == CSMJ_MY_USERINFO.seat_id then
		--todo
		local testStr = "相公seatId:" .. seatId
		-- require("hall.GameCommon"):showAlert(true, testStr, 300)
		-- dump(value, testStr)

		display_scene("app.scenes.MainScene")
	end
end

return CardUtils
