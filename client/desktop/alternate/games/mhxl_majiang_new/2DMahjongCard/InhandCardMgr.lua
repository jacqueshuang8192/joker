--[[
	自己的手牌
--]]
local InhandCardMgr = class("InhandCardMgr")
local Card = require(TpackageName.. ".2DMahjongCard.Card")
local OutCardMgr = require(TpackageName..".2DMahjongCard.OutCardMgr")
local selectedTag = 99
local cardTemp = nil
local NEW_CARD_TAG = 20
local GANGCARD = "gang"
local BTN_CLICK_VOICE = "hall/scene/res/common/music/Audio_Button_Click.mp3"

function InhandCardMgr:ctor(path)

end

function InhandCardMgr:showMyCards(playerType, plane, cardDatas)
	selectedTag = 99
	local oriX = plane:getSize().width
	local oriY = plane:getSize().height / 2
	local isTing = 0 or tingFlag
	self.moving = false
	local function onTouchBegan(touch, event)
		dump(D3_CHUPAI, "test if can touch")
		if not self.moving then
			cardTemp = nil
			local children = plane:getChildren()
			local orlselectedTag = selectedTag
			for k,v in pairs(children) do
				if orlselectedTag == 99 then -- 复原
					selectedTag = v:getTag()
					self:cancelSelectingCard(plane)
				end
				local locationInNode = v:convertToNodeSpace(touch:getLocation())
				local s = v:getContentSize()
				local rect = cc.rect(0, -15, s.width, s.height + 15)
				if cc.rectContainsPoint(rect, locationInNode) then
					cardTemp = v
					self.cardOriPosition = cardTemp:getPosition()
				end
			end
			selectedTag = orlselectedTag
			if cardTemp and (not tolua.isnull(cardTemp)) and cardTemp:getTag() > 0 then
				--if MHXLMJ_AI == 1 then
				--	return false
				--end
				require("hall.GameCommon"):play2d(BTN_CLICK_VOICE)
				-- self.moving = true
				if selectedTag == 99 then
					self.canMove = true
					self.oriSelectedPosition = cardTemp:getPosition()
				else
					if selectedTag ~= cardTemp:getTag() then
						self.oriSelectedPosition = cardTemp:getPosition()
					end
					self.canMove = false
				end
				D3_CONTROLLER:didSelectOutCard(cardTemp.m_value)
				D3_CONTROLLER:showHupai_vw(cardTemp.m_value)
				touch.beganPos = touch:getLocation()
				return true
			else
				if selectedTag == 99 then
					return false
				else
					return true
				end
			end
		end
		if selectedTag == 99 then
			return false
		else
			return true
		end
	end
	local function onTouchCancell(touch, event)
		if cardTemp then
			self.moving = false
			self:cancelSelectingCard(plane)
		end
	end
	local function onTouchMoved(touch, event)
		if cardTemp and self.canMove and  (not tolua.isnull(cardTemp)) then
			self:cancelSelectingCard(plane)
			OutCardMgr:showSelectedCards(cardTemp.m_value)
			self.moving = true
			local posX = cardTemp:getPositionX()
			local posY = cardTemp:getPositionY()
			local delta = touch:getDelta()
			cardTemp:setPosition(cc.p(posX + delta.x, posY + delta.y))
		end
	end
	local function onTouchEnded(touch, event)
		if cardTemp and (not tolua.isnull(cardTemp)) and cardTemp:getTag() > 0 then
			self.moving = false
			local playTag = nil
			local tag = cardTemp:getTag()
			local m_value = cardTemp.m_value
			local isNotLaiZi = true
			if G_game.isLaiZi(m_value) then
				isNotLaiZi = false
			end
			
				local offsetY = cardTemp:getPosition().y - cardTemp:getSize().height / 2
				if offsetY > plane:getSize().height then
					--超出范围，出牌
					selectedTag = tag
					if D3_CHUPAI == 1 and isNotLaiZi and MHXLMJ_ROOM.tuoguan_ing == 0 then
						playTag = tag
						OutCardMgr:showSelectedCards(99)
						D3_CONTROLLER:playCard(m_value)
						D3_CONTROLLER:setTingNodeVisible(false)
					else
						self:cancelSelectingCard(plane)
					end
				else
					local locationInNode = cardTemp:convertToNodeSpace(touch:getLocation())
					local rect = cc.rect(0, 0, cardTemp:getContentSize().width, cardTemp:getContentSize().height)
					if cc.rectContainsPoint(rect, locationInNode) then
						if selectedTag == tag then
							if D3_CHUPAI == 1 and isNotLaiZi and MHXLMJ_ROOM.tuoguan_ing == 0 then
								OutCardMgr:showSelectedCards(99)
								D3_CONTROLLER:playCard(m_value)
								playTag = tag
							else
								self:cancelSelectingCard(plane)
							end
							D3_CONTROLLER:setTingNodeVisible(false)
						else
							local endPos = touch:getLocation()
							local beganPos = touch.beganPos
							local canChuPai = true
							if endPos and beganPos then
								local endY = math.ceil(endPos.y)
								local beganY = math.ceil(beganPos.y)
								if endY+10 < beganY then
									canChuPai = false
								end
							end
							local mj_danjiChuPai = cc.UserDefault:getInstance():getBoolForKey("mj_danjiChuPai")
							if mj_danjiChuPai and D3_CHUPAI == 1 and isNotLaiZi and canChuPai and MHXLMJ_ROOM.tuoguan_ing == 0  then --单击出牌
								playTag = tag
								selectedTag = tag
								OutCardMgr:showSelectedCards(99)
								D3_CONTROLLER:playCard(m_value)
								D3_CONTROLLER:setTingNodeVisible(false)
							else
								self:cancelSelectingCard(plane)
								self:setMyPosY( plane, cardTemp )
								selectedTag = tag
								OutCardMgr:showSelectedCards(m_value)
							end
						end
					else
						self:cancelSelectingCard(plane)
					end
			end
			
			if playTag == nil then
				dump("playTag!=空")
				self:originalMyPosX( plane, playTag )
			end
		else
			OutCardMgr:showSelectedCards(99)
			self:cancelSelectingCard(plane)
			D3_CONTROLLER:didSelectOutCard(99)
			D3_CONTROLLER:setTingNodeVisible(false)
		end
	end
	--注册点击事件
	local listener1 = cc.EventListenerTouchOneByOne:create()
	listener1:setSwallowTouches(true)
	listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
	listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
	listener1:registerScriptHandler(onTouchCancell,cc.Handler.EVENT_TOUCH_CANCELLED )

	local eventDispatcher = SCENENOW["scene"]:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener1:clone(), plane)

		

	local card = Card:newMyInHandCard({m_value = 1})
	plane:removeAllChildren()
	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width
	local number = table.getn(cardDatas)
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale
	local oriX = size.width - cardWidth / 2
	local oriY = cardHeight / 2

	
	local idx = 0
	for i=number, 1, -1 do
		local cardData = cardDatas[i]
		local card = Card:newMyInHandCard(cardData)
		-- if cardData.m_value == 67 then
		-- 	dump(cardData)
		-- end
		local x = oriX - ( idx ) * cardWidth
		card:setTag(i)
		card:setPosition(cc.p(x, oriY))
		plane:addChild(card)
		card:show()
		idx = idx + 1
	end
end

--新拿的牌 第14张
function InhandCardMgr:setNewCard(plane, cardData)
    OutCardMgr:showSelectedCards(cardData.m_value)
	local card = Card:newMyInHandCard(cardData)
	if cardData.m_value == 67 then
		dump(cardData)
	end

	local seatId = MHXLMJ_SEAT_TABLE_BY_TYPE[CARD_PLAYERTYPE_MY]
	if  MHXLMJ_USERINFO_TABLE[seatId].m_isMenHu == 1 or (not BAO_JIAO_FIRST_OUT_CARD and MHXLMJ_USERINFO_TABLE[seatId].m_tianTing == 1)  then
		local childs = plane:getChildren()
		for i,child in ipairs(childs) do
			child:setColor(cc.c3b(144, 144, 144))
			child:setOpacity(230)
			child:setTouchEnabled(true)
		end	
	end	
	
	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale
	local oriX = size.width + cardWidth 
	local oriY = cardHeight / 2
	card:setTag(NEW_CARD_TAG)
	card:setPosition(cc.p(oriX, oriY))
	plane:addChild(card)
end

function InhandCardMgr:sortCardsNode( chids,isNewCard )
	if isNewCard == nil then isNewCard = true end
	for idx,node in ipairs(chids) do
		local tag = node:getTag()
		if tag == NEW_CARD_TAG and isNewCard then
			table.remove( chids, idx )
		end
	end
	local sfun = function(a, b)
		local valuea = tonumber(a.m_value) or 1
        local valueb = tonumber(b.m_value) or 1
        local flag = false
		if G_game.isLaiZi(valuea) and G_game.isLaiZi(valueb) then
			flag = valuea > valueb
		elseif G_game.isLaiZi(valuea) then
			flag = false
		elseif G_game.isLaiZi(valueb) then
            flag = true
        else
            flag = valuea > valueb
		end
        return flag
    end

    local count = #chids
    for i=1, count do
        for j=1,count - i do
            local flag = sfun(chids[j+1], chids[j])
            if flag then
                local temp = chids[j+1]
                chids[j+1] = chids[j]
                chids[j] = temp
            end
        end
	end
	return chids
end

--还原位置
function InhandCardMgr:originalMyPosX( plane, playTag )
    local chids = plane:getChildren()
	local card = chids[1]
    if not card then
        return
	end
	dump(#chids,"-----还原位置-------")
	chids = self:sortCardsNode( chids )
	local size = plane:getSize()
	local cardWidth = card:getSize().width
	local scale = 1
	cardWidth = cardWidth * scale
	local oriX = size.width - cardWidth / 2
	for idx,node in ipairs(chids) do
		if not (playTag and playTag == node:getTag()) then
			local x = oriX - ( idx - 1 ) * cardWidth
			node:setPositionX(x)
			node:show()
		end
    end
    local newCardNode = plane:getChildByTag(NEW_CARD_TAG)
    if not newCardNode then
        return
    end
	local oriX = size.width + cardWidth
	if playTag and newCardNode:getTag() == playTag then
	else
		newCardNode:setPositionX(oriX)
	end
end

function InhandCardMgr:runActionMyPosX( plane )
    local chids = plane:getChildren()
	local card = chids[1]
    if not card then
        return
	end
	dump(#chids,"-------runActionMyPosX")
	chids = self:sortCardsNode( chids, false )
	dump(#chids,"-------vchids")
	local size = plane:getSize()
	local cardWidth = card:getSize().width
	local scale = 1
	cardWidth = cardWidth * scale

	local cardHeight = card:getSize().height
	cardHeight = cardHeight * scale
	local oriY = cardHeight / 2


	local oriX = size.width - cardWidth / 2
    for idx,node in ipairs(chids) do
		local x = oriX - ( idx - 1 ) * cardWidth
		dump(cc.p(x, oriY),"-------runActionMyPosition")
		node:show()
		node:stopAllActions()
		node:runAction(cc.MoveTo:create(0.3, cc.p(x, oriY)))
    end
end

function InhandCardMgr:setMyPosY( plane, selectNode )
    local chids = plane:getChildren()
	local card = chids[1]
    if not card then
        return
	end
	local scale = 1
	local cardHeight = card:getSize().height
	cardHeight = cardHeight * scale
	local oriY = cardHeight / 2
    for idx,card in ipairs(chids) do
		card:setPositionY(oriY)
	end

    if not selectNode then
        return
    end
    selectNode:setPositionY(oriY + 25)
end

function InhandCardMgr:cancelSelectingCard(plane)
    if selectedTag == 99 then
        return
    end
    -- SZKWX_CONTROLLER:hideTingHuPlane()
    local selectedCard = plane:getChildByTag(selectedTag)
    if selectedCard then
		selectedTag = 99
		self:setMyPosY( plane )
    end
    -- D3_SHOW_OPERATOR:revertHighlightOutCards()
end

-- 删除碰杠牌
function InhandCardMgr:removeCards(playerType, plane, removeCards, isRemoveNewCard,controlType)
    local oriRemoveCount = table.getn(removeCards)
    if isRemoveNewCard then
        local newCardNode = plane:getChildByTag(NEW_CARD_TAG)
        if playerType == CARD_PLAYERTYPE_MY then
            if newCardNode and newCardNode.m_value == removeCards[table.getn(removeCards)] then
                newCardNode:removeFromParent()
                table.remove(removeCards, table.getn(removeCards))
            end
        else
            if newCardNode then
                newCardNode:removeFromParent()
                table.remove(removeCards, table.getn(removeCards))
            end
        end
    end
    if not removeCards then
        return
    end
    local removeCount = table.getn(removeCards)
    if removeCount == 0 then
        return
    end

    if playerType == CARD_PLAYERTYPE_MY then
        local maxIndex = 15
		local cardTable = {}
		-- cardTable = plane.inhand_plane:getChildren()
        for i = 1, maxIndex do
            local cardNode = plane:getChildByTag(i)
            if not cardNode then
                break
            end
            cardTable[i] = cardNode
		end
		-- cardTable = self:sortCardsNode( cardTable )
        if oriRemoveCount > 1 then
            local newCardNode = plane:getChildByTag(NEW_CARD_TAG)
            if newCardNode then
                --若没移除新牌
                removeCount = removeCount - 1
            end
            local removeIndex = 1
			local index = 1

			--[[
            for i=1,table.getn(cardTable) do
                if removeIndex <= removeCount and cardTable[i].m_value == removeCards[removeIndex] then
                    cardTable[i]:removeFromParent()
                    removeIndex = removeIndex + 1
                else
                    cardTable[i]:setTag(index)
                    index = index + 1
                end
            end--]]
            
            --  删牌的问题  先做这个处理
            for i=table.getn(cardTable),1,-1 do
                if removeIndex <= removeCount and cardTable[i].m_value == removeCards[removeIndex] then
                    cardTable[i]:removeFromParent()
                    removeIndex = removeIndex + 1
                else
                    cardTable[i]:setTag(index)
                    index = index + 1
                end
            end

			self:runActionMyPosX( plane )
            if newCardNode then
                --相当于打出一张未移除的非新牌
                for i=1,15 do
                    local cardNode = plane:getChildByTag(i)
                    if cardNode and cardNode.m_value == removeCards[removeCount + 1] then
                        selectedTag = i
                        self.cardOriPosition = cardNode:getPosition()
                        break
                    end
                end
                dump(selectedTag, "test 0510")
                self:playCard(playerType, plane, D3_CARDDATA:new(removeCards[removeCount + 1], 1, CARDNODE_TYPE_NORMAL))
            else
            end
        else
            local newCardTemp = plane:getChildByTag(NEW_CARD_TAG)
            if newCardTemp then
                --处理在非新牌中取牌补杠的情况
                --相当于打出一张未移除的非新牌
                for i=1,15 do
                    local cardNode = plane:getChildByTag(i)
                    if cardNode and cardNode.m_value == removeCards[1] then
                        selectedTag = i
                        self.cardOriPosition = cardNode:getPosition()
                        break
                    end
                end

                self:playCard(playerType, plane, D3_CARDDATA:new(removeCards[1], 1, CARDNODE_TYPE_NORMAL))
            else
                --处理在非新牌中取牌补杠的情况
                for i=table.getn(cardTable),1,-1 do
                    if cardTable[i].m_value == removeCards[1] then
                        cardTable[i]:removeFromParent()
                        break
                    else
                        cardTable[i]:setTag(i - 1)
                    end
				end
				self:runActionMyPosX( plane )
				
            end

        end
    elseif playerType == CARD_PLAYERTYPE_LEFT then
		local count = 0
		local chlds = plane:getChildren()
		table.sort(chlds, function(a,b)
			return a:getPositionY() > b:getPositionY()
		end)
		for i,cardNode in ipairs(chlds) do
			cardNode:removeFromParent()
			count = count + 1
			if count == removeCount then
				break
			end
		end
      
    elseif playerType == CARD_PLAYERTYPE_RIGHT then
		local count = 0
		local chlds = plane:getChildren()
		table.sort(chlds, function(a,b)
			return a:getPositionY() < b:getPositionY()
		end)
		for i,cardNode in ipairs(chlds) do
			cardNode:removeFromParent()
			count = count + 1
			if count == removeCount then
				break
			end
		end
    elseif playerType == CARD_PLAYERTYPE_TOP then

    	if removeCount <= 0 then
    		return
    	end
    	
		local chlds = plane:getChildren()
		table.sort(chlds, function(a,b)
			return a:getPositionX() < b:getPositionX()
		end)

    	if controlType == GANG_TYPE_AN or controlType == GANG_TYPE_BU then
    		--暗杆和补杠的时候 应该要优先删除掉 手上摸的那只牌

    		local cardNode = plane:getChildByTag(NEW_CARD_TAG)
    		if cardNode then
    			cardNode:removeFromParent()
    			removeCount = removeCount - 1	
    		end

    	end

    	if removeCount <= 0 then
    		return
    	end

        local count = 0
        local chlds = plane:getChildren()
		table.sort(chlds, function(a,b)
			return a:getPositionX() < b:getPositionX()
		end)

		for i=#chlds,1,-1 do
			local cardNode = chlds[i]
			cardNode:removeFromParent()
			count = count + 1

			if count == removeCount then
				break
			end
		end
    end
end


-- 删除闷牌的时候  自摸的那张
function InhandCardMgr:removeCardsForOtherMenHu(playerType,plane)
	dump(playerType,"闷胡删除其他玩家手牌啦 playerType")

	local removeCount = 1
	if playerType == CARD_PLAYERTYPE_LEFT then
		local count = 0
		local chlds = plane:getChildren()
		table.sort(chlds, function(a,b)
			return a:getPositionY() < b:getPositionY()
		end)
		for i,cardNode in ipairs(chlds) do
			cardNode:removeFromParent()
			count = count + 1
			if count == removeCount then
				break
			end
		end
      
    elseif playerType == CARD_PLAYERTYPE_RIGHT then
		local count = 0
		local chlds = plane:getChildren()
		table.sort(chlds, function(a,b)
			return a:getPositionY() > b:getPositionY()
		end)
		for i,cardNode in ipairs(chlds) do
			cardNode:removeFromParent()
			count = count + 1
			if count == removeCount then
				break
			end
		end
    elseif playerType == CARD_PLAYERTYPE_TOP then
        local count = 0
		local chlds = plane:getChildren()
		table.sort(chlds, function(a,b)
			return a:getPositionX() < b:getPositionX()
		end)
		for i,cardNode in ipairs(chlds) do
			cardNode:removeFromParent()
			count = count + 1
			if count == removeCount then
				break
			end
		end
    end
end

function InhandCardMgr:playCard(playerType, plane, card)
	if MHXLMJ_ROOM.tuoguan_ing == 1 then
		selectedTag = 20
	else
	end
	local newCardNode = plane:getChildByTag(NEW_CARD_TAG)
	if newCardNode and selectedTag == NEW_CARD_TAG then
		newCardNode:removeFromParent()
		selectedTag = 99
		return
	end
	local cardNode = plane:getChildByTag(selectedTag)
	if not cardNode then
		local isJudge = false
		if newCardNode and newCardNode.m_value == card.m_value then
			newCardNode:removeFromParent()
			isJudge = true
		end
		selectedTag = 99
		if not isJudge then
			for i=14, 1, -1 do
				local tmp_card =  plane:getChildByTag(i)
				if tmp_card and tmp_card.m_value == card.m_value then
					selectedTag = tmp_card:getTag()
					cardNode = tmp_card
				end
			end
		end
		if not cardNode then
			return
		end
	end

	if not newCardNode then
		cardNode:removeFromParent()
		for i=selectedTag + 1,15 do
			cardNode = plane:getChildByTag(i)
			if not cardNode then
				break
			end
			cardNode:setTag(i - 1)
		end
		if playerType == CARD_PLAYERTYPE_MY then
			self:runActionMyPosX( plane )
		else
			dump("----------错位了")
		end
	else
		cardNode:removeFromParent()
		local desPosition
		local MoveToTime = 0.1

		local chids = plane:getChildren()
		local card = chids[1]
		if not card then
			return
		end
		chids = self:sortCardsNode( chids, false )
		local size = plane:getSize()
		local cardWidth = card:getSize().width
		local scale = 1
		cardWidth = cardWidth * scale
		local cardHeight = card:getSize().height
		cardHeight = cardHeight * scale
		local oriY = cardHeight / 2
	
		local oriX = size.width - cardWidth / 2
		for idx,node in ipairs(chids) do
			local x = oriX - ( idx - 1 ) * cardWidth
			if node == newCardNode then
				desPosition = cc.p(x, oriY)
			else
				node:stopAllActions()
				node:runAction(cc.MoveTo:create(MoveToTime, cc.p(x, oriY)))
			end
			node:setTag(idx)
		end

		MoveToTime = 0.04
		local moveAc1 = cc.MoveTo:create(MoveToTime, cc.p(newCardNode:getPosition().x, newCardNode:getSize().height * newCardNode:getScale() * 2))
		local moveAc2 = cc.MoveTo:create(MoveToTime * 2, cc.p(desPosition.x, newCardNode:getSize().height * newCardNode:getScale() * 2))
		local moveAc3 = cc.MoveTo:create(MoveToTime, desPosition)
		local seqAc = cc.Sequence:create(moveAc1, moveAc2, moveAc3)
		newCardNode:stopAllActions()
		newCardNode:runAction(seqAc)
	end
	selectedTag = 99
end

function InhandCardMgr:movePosition(playerType, offsetCardCount, plane)
	if playerType == CARD_PLAYERTYPE_MY then
		-- local offsetX = 0
		-- for i=1,offsetCardCount do
		-- 	local cardNode = plane:getChildByTag(i)
		-- 	if cardNode then
		-- 		offsetX = offsetX + cardNode:getSize().width * cardNode:getScale()
		-- 	end
		-- end
		-- for i=1,15 do
		-- 	local cardNode = plane:getChildByTag(i)
		-- 	if not cardNode then
		-- 		break
		-- 	end
		-- 	cardNode:runAction(cc.MoveTo:create(0.3, cc.p(cardNode:getPosition().x + offsetX, cardNode:getPosition().y)))
		-- end
		dump("movePosition-","-----------------------movePosition")
		self:runActionMyPosX( plane )
	elseif playerType == CARD_PLAYERTYPE_LEFT then
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
	elseif playerType == CARD_PLAYERTYPE_TOP then
	end
end

--自己手牌上的点点能胡牌的
function InhandCardMgr:setDianNodeBytingpai( plane ,isTiantingFirst)
	if not (type(TINGSEQ) == "table") then
		return
	end

	local remainCardValues = self:getCardsValueByOutNodesAndMyNodes( plane )
	local tal = {}
	local index = 0--必须有超过一个
	local maxCount = 0
	local isTxtDuo = false
	local maxCard = nil
    local renyipaiCard
	for k,data in pairs(TINGSEQ) do
		local tingHuCards_1 = {}

		for i1,v1 in ipairs(data.tingHuCards) do

			if not v1.huCards or table.getn(v1.huCards) == 0 then
				renyipaiCard = data.card
			end

			for i2,v2 in ipairs(v1.huCards) do
				local isExist = false
				for i3,v3 in ipairs(tingHuCards_1) do
					if v3 == v2 then
						isExist = true
						break
					end
				end
				if not isExist then
					table.insert(tingHuCards_1, v2)
				end
			end
		end

		if #tingHuCards_1 > 25 then --胡任意牌
			renyipaiCard = data.card
		end
	

		local count = 0 --剩余张数
		for idx,v in ipairs(tingHuCards_1) do	
			local remainCard = 0
			if remainCardValues[v] then
				remainCard = remainCardValues[v]
			else
				remainCard = 4
			end
			count = count + remainCard
		end

		tal[data.card] = tingHuCards_1
		index = index + 1
		local num = #tingHuCards_1
		if maxCount < count then
			maxCount = count
			maxCard = data.card
		elseif tal[maxCard] and maxCount == count and #tal[maxCard] < num then
			maxCount = count
			maxCard = data.card
		end
	end
	if renyipaiCard then --胡任意牌
		maxCard = renyipaiCard
	end

	local seatId = MHXLMJ_SEAT_TABLE_BY_TYPE[CARD_PLAYERTYPE_MY]

	local childs = plane:getChildren()
	for i,child in ipairs(childs) do
		local card = child.m_value
		if card and tal[card] then
			if maxCard == card and index >= 2 and not isTxtDuo then
				child:showTxtDian()
				isTxtDuo = true
			else
				child:showDian()
			end

			if MHXLMJ_USERINFO_TABLE[seatId].m_tianTing == 1  and isTiantingFirst then
				child:setColor(cc.c3b(255, 255, 255))
				child:setOpacity(230)
				child:setTouchEnabled(false)
			end

		else

			if MHXLMJ_USERINFO_TABLE[seatId].m_tianTing == 1 and isTiantingFirst then
				child:setColor(cc.c3b(144, 144, 144))
				child:setOpacity(230)
				child:setTouchEnabled(true)
			end

			child:hideDian()
		end
	end
end

function InhandCardMgr:hideDianNodeBytingpai( plane )
	local childs = plane:getChildren()
	for i,child in ipairs(childs) do
		child:hideDian()
	end
end

function InhandCardMgr:getCardsValueByOutNodesAndMyNodes( inhand_plane )
	-- local inhand_plane = MHXLMJ_SCENE.players.my_card_plane.inhand_plane
	local outhand_planes = clone(D3_OUTHAND_ARR) or {}
	table.insert(outhand_planes, inhand_plane)
	local tabl = {}
	for i,v in ipairs(outhand_planes) do
		if v then
			local children = v:getChildren()
			for i1,v1 in ipairs(children) do
				local m_value = v1.m_value
				if m_value then
					if not tabl[m_value] then
						tabl[m_value] = 0
					end
					tabl[m_value] = tabl[m_value] + 1
				end
			end
		end
	end
	for k,v in pairs(tabl) do
		tabl[k] = 4 - v
	end
	dump(tabl)
	return tabl
end


function InhandCardMgr:setMenPai(plane,isMen)
	local tempAllChildren = plane:getChildren()

	for k,v in pairs(tempAllChildren) do
		v:setTouchEnabled(isMenPai)
		if isMenPai then
			v:setColor(cc.c3b(140, 140, 140))
		else
			v:setColor(cc.c3b(255, 255, 255))
		end
	end
end

return InhandCardMgr