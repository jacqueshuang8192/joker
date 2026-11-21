local YJMJData = require(TpackageName..".globle.YJMJData")

local CardUtils = class("CardUtils")

function CardUtils:insertCardsByUid(uid, newCard)
	--todo
	local cards = YJMJData:getCards(uid)
	
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

			--dump(index, "cards test")

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
	if type(seatId) ~= "number" then
		return
	end
	dump(seatId,"seat======")
	dump(YJMJ_MY_USERINFO, "YJMJ_MY_USERINFO")
	local other_index = seatId - MY_SEAT_ID

	dump(other_index, "playerType test")

	local playerType = CARD_PLAYERTYPE_MY
	if other_index < 0 then
		other_index = other_index + YJ_PLAYER_COUNT
	end

	if YJ_PLAYER_COUNT == 4 then
		--todo
		if other_index == 1 then
			playerType = CARD_PLAYERTYPE_RIGHT
		elseif other_index == 2 then
			playerType = CARD_PLAYERTYPE_TOP
		elseif other_index == 3 then
			playerType = CARD_PLAYERTYPE_LEFT
		end
	elseif YJ_PLAYER_COUNT == 3 then
		if other_index == 1 then
			playerType = CARD_PLAYERTYPE_RIGHT
		elseif other_index == 2 then
			playerType = CARD_PLAYERTYPE_LEFT
		end
	elseif YJ_PLAYER_COUNT == 2 then
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
	if  ableGangCards then
  	  local ableGangCards = {ableGangCards[1],ableGangCards[5]}
  	end

	if status == 1 then
		--todo

		local gangCards = {}
		if bit.band(handle, CONTROL_TYPE_GANG) > 0 then
			--todo
			table.insert(gangCards, handleCard)
		end
		result["gangCards"] = gangCards
	elseif status == 2 then
		local gangCards = {}
		for k,v in pairs(ableGangCards) do
			if v > 0 then
				--todo
				table.insert(gangCards, v)
			-- else
			-- 	break
			end
		end
		
		result["gangCards"] = gangCards
	elseif status == 3 then
		local gangCards = {}
		local m = false
		for k,v in pairs(ableGangCards) do
			if v > 0 then
				--todo
				table.insert(gangCards, v)
				m = true
			-- else
			-- 	break
			end
		end

		if not m then
			--todo
			if bit.band(handle, CONTROL_TYPE_GANG) > 0 then
				--todo
				table.insert(gangCards, handleCard)
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

	self:removeCards(seatId, removeCards)

	return progCards,removeCards
end

function CardUtils:removeCards(seatId, removeCards)
	local oriCards = YJMJ_GAMEINFO_TABLE[seatId].hand

	dump(oriCards,"oriCards111===>>>")

	local count = table.getn(oriCards)
	dump(count,"count==>>")

	local removeCount = table.getn(removeCards)
	local removeIndex = 1

	local removeIndexs = {}
	for i=1,count do
		if (oriCards[i] == removeCards[removeIndex]) or oriCards[i] == 0 then
			table.insert(removeIndexs, i)
			removeIndex = removeIndex + 1
			dump(i,"i=====")
			if removeIndex > removeCount then
				break
			end
		end
	end

	dump(oriCards,"oriCards222=====>>>")
	for i=table.getn(removeIndexs),1,-1 do
		table.remove(oriCards, removeIndexs[i])
	end
end

function CardUtils:playCard(seatId, value)
	local gameInfo = YJMJ_GAMEINFO_TABLE[seatId] or {}
	local oriCards = gameInfo.hand or {}

	local tag = nil
	for i=1,table.getn(oriCards) do
		if oriCards[i] == 0 or oriCards[i] == value then
			--todo
			tag = i
			table.remove(oriCards, i)
			return tag
		end
	end

	return tag
end


-- function CardUtils:GetMaxLenString(s, maxLen)

-- 	local function GetUTFLenWithCount(s, count)  
-- 	    local sTable = StringToTable(s)  
	  
-- 	    local len = 0  
-- 	    local charLen = 0  
-- 	    local isLimited = (count >= 0)  
	  
-- 	    for i=1,#sTable do  
-- 	        local utfCharLen = string.len(sTable[i])  
-- 	        if utfCharLen > 1 then -- 长度大于1的就认为是中文  
-- 	            charLen = 2  
-- 	        else  
-- 	            charLen = 1  
-- 	        end  
	  
-- 	        len = len + utfCharLen  
	  
-- 	        if isLimited then  
-- 	            count = count - charLen  
-- 	            if count <= 0 then  
-- 	                break  
-- 	            end  
-- 	        end  
-- 	    end  
	  
-- 	    return len  
-- 	end 

-- 	local function GetUTFLen(s)  
-- 	    local sTable = StringToTable(s)  
	  
-- 	    local len = 0  
-- 	    local charLen = 0  
	  
-- 	    for i=1,#sTable do  
-- 	        local utfCharLen = string.len(sTable[i])  
-- 	        if utfCharLen > 1 then -- 长度大于1的就认为是中文  
-- 	            charLen = 2  
-- 	        else  
-- 	            charLen = 1  
-- 	        end  
	  
-- 	        len = len + charLen  
-- 	    end  
	  
-- 	    return len  
-- 	end  

--     local len = GetUTFLen(s)  
--     local maxLen=maxLen or 10
--     local dstString = s  
--     -- 超长，裁剪，加...  
--     if len > maxLen then  
--         dstString = string.sub(s, 1, GetUTFLenWithCount(s, maxLen))  
--         dstString = dstString..".."  
--     end  
-- end


return CardUtils