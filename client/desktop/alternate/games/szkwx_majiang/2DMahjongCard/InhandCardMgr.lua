--[[
	自己的手牌
--]]
local InhandCardMgr = class("InhandCardMgr")
local Card = require(TpackageName..".2DMahjongCard.Card")
local OutCardMgr = require(TpackageName..".2DMahjongCard.OutCardMgr")
local selectedTag = 99
local cardTemp = nil
local NEW_CARD_TAG = 20
local GANGCARD = "gang"
local BTN_CLICK_VOICE = "hall/scene/res/common/music/Audio_Button_Click.mp3"
local mahjongLogic = require(TpackageName..".mahjongLogic.mahjongLogic")
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

		if SZKWX_PLAYERS_INFOS[USER_INFO["uid"]].isMing then
			return
		end

		if SZKWX_IS_MING and SZKWX_IS_MING == 2 then    --卡五星的扣牌操作
			cardTemp = nil
			local children = plane:getChildren()
			for k,v in pairs(children) do
				local locationInNode = v:convertToNodeSpace(touch:getLocation())
				local s = v:getContentSize()
				local rect = cc.rect(0, -15, s.width, s.height + 15)
				if cc.rectContainsPoint(rect, locationInNode) then
					cardTemp = v
				end
			end	

			if cardTemp and (not tolua.isnull(cardTemp)) and cardTemp:getTag() > 0 and not cardTemp.m_isBlack then
				table.insert(KOU_PAI_TABLE,cardTemp.m_value)
				--缺扣牌的展示效果 明天打一局看下

				--cardTemp:setPositionY(oriY+30)
				--让手牌里这只牌都变成牌背
				self:setKouPaiShowCardBack(plane,cardTemp.m_value)

			else
				KOU_PAI_TABLE = {}
				--self:setMyPosY(plane)
				--复原
				self:setKouPaiShowCardBack(plane)
			end

			return
		end

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
			if cardTemp and (not tolua.isnull(cardTemp)) and cardTemp:getTag() > 0 and not cardTemp.m_isBlack then
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
				dump(cardTemp.m_value,"----cardTemp.m_value------")
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

		if SZKWX_PLAYERS_INFOS[USER_INFO["uid"]].isMing then
			return
		end

		if cardTemp then
			self.moving = false
			self:cancelSelectingCard(plane)
		end
	end
	local function onTouchMoved(touch, event)

		if SZKWX_IS_MING and SZKWX_IS_MING == 1 then
			return
		end

		if cardTemp and self.canMove and  (not tolua.isnull(cardTemp)) and not cardTemp.m_isBlack then
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

		if SZKWX_PLAYERS_INFOS[USER_INFO["uid"]].isMing then
			return
		end

		if cardTemp and (not tolua.isnull(cardTemp)) and cardTemp:getTag() > 0 and not cardTemp.m_isBlack then
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
					if D3_CHUPAI == 1 and isNotLaiZi then
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
							if D3_CHUPAI == 1 and isNotLaiZi then
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
							if mj_danjiChuPai and D3_CHUPAI == 1 and isNotLaiZi and canChuPai and SZKWX_IS_MING == 0 then --单击出牌
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

	if SZKWX_PLAYERS_INFOS[USER_INFO["uid"]].isMing then
		dump("用户明牌时候 摸到的手牌")
		card:setMingPai(CARD_PLAYERTYPE_MY,cardData.m_value)
		local cardHeight = card:getSize().height
		local oriY = cardHeight / 2
		card:setPositionY(oriY)
	end

	plane:addChild(card)


	--摸到了其他玩家的胡牌 置黑 不准出牌
	if #OTHER_PLAYER_HU_CARDS  == 0 then
		return
	end

	local tabTemp = {}
	local index = 1
	for i,v in ipairs(OTHER_PLAYER_HU_CARDS) do
		tabTemp[v] = 1
		index = index + 1
	end

	if index == 1 then
		return
	end
	dump(tabTemp,"tabTemp")

	if card.m_value and tabTemp[card.m_value] == 1 then
		card:setColor(cc.c3b(191,191,191))
		card.m_isBlack = true
	end	

	local childs = plane:getChildren()

	if not childs then
		return
	end

	local isNotTouch = 0
	for i,v1 in ipairs(childs) do
		if v1.m_isBlack then
			isNotTouch = isNotTouch + 1
		end
	end

	--都不能点 那就都能出
	if isNotTouch == #childs then
		for i,v1 in ipairs(childs) do
			if v1 then
				v1:setColor(cc.c3b(255,255,255))
				v1.m_isBlack = false
			end	
		end
	end

end

function InhandCardMgr:showMyCardsAfterOperation(playerType, plane, cardDatas,curGradCard)

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

	if curGradCard and curGradCard > 0 then
		for i=number, 1, -1 do
			if curGradCard == cardDatas[i].m_value then
				table.remove(cardDatas,i)
				break
			end
		end

		local idx = 0
		number = table.getn(cardDatas)
		for i=number, 1, -1 do
			local cardData = cardDatas[i]
			local card = Card:newMyInHandCard(cardData)
			local x = oriX - ( idx ) * cardWidth
			card:setTag(i)
			card:setPosition(cc.p(x, oriY))
			plane:addChild(card)
			card:show()
			idx = idx + 1
		end

		--在加入新的手牌
		self:setNewCardAfterOperation(plane, curGradCard)
	else
		local idx = 0
		for i=number, 1, -1 do
			local cardData = cardDatas[i]
			local card = Card:newMyInHandCard(cardData)
			local x = oriX - ( idx ) * cardWidth
			card:setTag(i)
			card:setPosition(cc.p(x, oriY))
			plane:addChild(card)
			card:show()
			idx = idx + 1
		end
	end
	

	local tabHu = {}
	for i,v in ipairs(OTHER_PLAYER_HU_CARDS) do
		tabHu[tonumber(v)] = true
	end

	local childs = plane:getChildren()
	for i,child in ipairs(childs) do
		local card = child.m_value
		if card and not tabHu[card] then
			child:setColor(cc.c3b(255,255,255))
			child.m_isBlack = false
		else
			child:setColor(cc.c3b(191,191,191))
			child.m_isBlack = true
		end
	end
end

--新拿的牌 第14张
function InhandCardMgr:setNewCardAfterOperation(plane, value)
    OutCardMgr:showSelectedCards(value)
	local card = Card:newMyInHandCard(value)
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

        for i = 1, maxIndex do
            local cardNode = plane:getChildByTag(i)
            if not cardNode then
                break
            end
            cardTable[i] = cardNode
		end

        if oriRemoveCount > 1 then
            local newCardNode = plane:getChildByTag(NEW_CARD_TAG)
            if newCardNode then
                --若没移除新牌
                removeCount = removeCount - 1
            end
            local removeIndex = 1
			local index = #cardTable - removeCount

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
                    index = index - 1
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
		
		----------------------------
		if removeCount <= 0 then
    		return
    	end

    	local chlds = plane:getChildren()
		table.sort(chlds, function(a,b)
			return a:getPositionY() > b:getPositionY()
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
		if removeCount <= 0 then
    		return
    	end

    	local chlds = plane:getChildren()
		table.sort(chlds, function(a,b)
			return a:getPositionY() < b:getPositionY()
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

function InhandCardMgr:playCard(playerType, plane, card)

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
		local moveAc1 = cc.MoveTo:create(MoveToTime, cc.p(newCardNode:getPosition().x, newCardNode:getSize().height * newCardNode:getScaleY() * 2))
		local moveAc2 = cc.MoveTo:create(MoveToTime * 2, cc.p(desPosition.x, newCardNode:getSize().height * newCardNode:getScaleY() * 2))
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
		self:runActionMyPosX( plane )
	elseif playerType == CARD_PLAYERTYPE_LEFT then
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
	elseif playerType == CARD_PLAYERTYPE_TOP then
	end
end

--自己手牌上的点点能胡牌的
function InhandCardMgr:setDianNodeBytingpai( plane )
	dump("--setCardNotTouchByMingPai-->>>")
	if not (type(TINGSEQ) == "table") then
		return
	end
	dump(TINGSEQ,"TINGSEQ = ")

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
		else
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

--置黑和不可点 非报听牌
function InhandCardMgr:setCardNotTouchByMingPai( plane )
	dump("setCardNotTouchByMingPai-->>>")
	if not (type(TINGSEQ) == "table") then
		return
	end

	dump(TINGSEQ,"TINGSEQ=")

	local remainCardValues = self:getCardsValueByOutNodesAndMyNodes( plane )
	dump(remainCardValues,"remainCardValues")
	local tal = {}
   
	for k,data in pairs(TINGSEQ) do
		local tingHuCards_1 = {}
		for i1,v1 in ipairs(data.tingHuCards) do
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

		tal[data.card] = tingHuCards_1
	end

	local tabKou = {}
	for i,v in ipairs(KOU_PAI_TABLE) do
		tabKou[v] = true
	end

	local tabHu = {}
	for i,v in ipairs(OTHER_PLAYER_HU_CARDS) do
		tabHu[v] = true
	end

	local childs = plane:getChildren()
	for i,child in ipairs(childs) do
		local card = child.m_value
		if card and tal[card] and not tabKou[card] and not tabHu[card] then
			child:setColor(cc.c3b(255,255,255))
			child.m_isBlack = false
		else
			child:setColor(cc.c3b(77,77,77))
			child.m_isBlack = true
		end
	end
end

--恢复牌的颜色与可点击性
function InhandCardMgr:setCardTouchByMingPai( plane )
	local childs = plane:getChildren()
	for i,child in ipairs(childs) do
		child:setColor(cc.c3b(255,255,255))
		child.m_isBlack = false
	end

	self:setMyPosY(plane)
end

--明牌的时候 取消了 还是要置黑掉不能出的牌
function InhandCardMgr:setCardTouchByCancelMingPai( plane )
	local childs = plane:getChildren()
	for i,child in ipairs(childs) do
		child:setColor(cc.c3b(255,255,255))
		child.m_isBlack = false
	end

	self:setMyPosY(plane)

	local tabHu = {}
	for i,v in ipairs(OTHER_PLAYER_HU_CARDS) do
		tabHu[tonumber(v)] = true
	end

	local childs = plane:getChildren()
	for i,child in ipairs(childs) do
		local card = child.m_value
		if card and not tabHu[card] then
			child:setColor(cc.c3b(255,255,255))
			child.m_isBlack = false
		else
			child:setColor(cc.c3b(191,191,191))
			child.m_isBlack = true
		end
	end
end
--玩家明牌
function InhandCardMgr:showMyCardsMingPai(playerType,plane,cardDatas,kouCards,HuCards)
	
	local card = Card:newMingCard(playerType,1)
	plane:removeAllChildren()

	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width
	local number = table.getn(cardDatas)
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale

	LIANGCARDS_HU[playerType] = HuCards
	local notLiangCard,liangcard = self:getNewLiangPaiCard(cardDatas,HuCards)
	table.sort(notLiangCard,function(a,b)
			return a < b
		end)	
	table.sort(liangcard,function(a,b)
			return a < b
		end)

	dump(notLiangCard,"notLiangCard--->>")
	dump(liangcard,"liangcard--->>")

	if playerType == CARD_PLAYERTYPE_MY  then
		local idx = 0
		local lastX = 0
		local cardWidth1 = cardWidth * 1.1
		local oriX = size.width - cardWidth / 2
		local oriY = size.height / 2

		local tempTag = #cardDatas

		--手牌从左往右摆

		--先摆亮的牌
		for i=#liangcard, 1, -1 do   
			local card = Card:newMingCard(playerType,liangcard[i])
			card:setTag(tempTag)
			tempTag = tempTag -1

			local x = oriX - idx * cardWidth
			lastX = x
	        card:setPosition(cc.p(x, oriY))
	        idx = idx + 1

	        plane:addChild(card)
	        card:show()
		end


		--在摆不亮的且没有扣的牌
		lastX = lastX - cardWidth1*0.5
		idx = 1	
		local lastX1 = lastX
		local cardWidth2 = cardWidth*1.1
		for i=#notLiangCard, 1, -1 do
			local flag = 0
			for j,v in ipairs(kouCards) do
				if v == notLiangCard[i] then  --有扣牌
					flag = 1
				end
			end

			if flag == 0 then
				local card = Card:newMyInHandCard(notLiangCard[i])
				card:setTag(tempTag)
				tempTag = tempTag -1

				local x = lastX - idx* cardWidth2
				lastX1 = x
		        card:setPosition(cc.p(x, oriY))

		        plane:addChild(card)
				card:show()
				idx = idx + 1
			end
		end	

		--显示扣牌的牌
		lastX1 = lastX1 - 10
		idx = 1
		local cardWidth3 = cardWidth*1.1

		for i=#notLiangCard, 1, -1 do
			local flag = 0
			for j,v in ipairs(kouCards) do
				if v == notLiangCard[i] then  --有扣牌
					dump(v,"vvvvvvvvvvvvvvvvvvvvvvvvvvvvv")
					flag = 1
				end
			end

			if flag == 1 then
				dump("hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh")
				local card = Card:newMingCard(playerType,notLiangCard[i])
				card:showCardBack(CARD_PLAYERTYPE_MY,true,1)
				card:setTag(tempTag)
				tempTag = tempTag -1
				
				local x = lastX1 - idx * cardWidth3
		        card:setPosition(cc.p(x, oriY))
		        dump(x,"xxxxxxxxxxxxxxxxxxxxxx")
		        
				if playerType == CARD_PLAYERTYPE_MY then
					card:setColor(cc.c3b(191,191,191))
					card.m_isBlack = true
				end

		        plane:addChild(card)
				card:show()
				idx = idx + 1
			end
		end

	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		local idx = 0
		local orlPos = 	cc.p(size.width/2 + 10,size.height - cardHeight )

		local lastY = 0
		local lastX = 0

		local tempTag = #cardDatas

		for i=#notLiangCard, 1, -1 do
			local card = Card:newMingCard(playerType,notLiangCard[i])
			card:showCardBack(CARD_PLAYERTYPE_RIGHT,true,1)
			card:setTag(tempTag)
			tempTag = tempTag -1

			local x = orlPos.x + (( idx - 1 ) * 9)
			local y = orlPos.y - idx * 27

			lastY = y
			lastX = x

			card:setPosition(cc.p(x, y))
			plane:addChild(card)
			card:show()
			idx = idx + 1
		end	


		lastY = lastY - 27
		lastX = lastX + 9

		idx = 1
		for i=#liangcard, 1, -1 do   
			local card = Card:newMingCard(playerType,liangcard[i])
			card:setTag(tempTag)
			tempTag = tempTag -1

			local x = lastX + (( idx - 1 ) * 9)
			local y = lastY - idx * 27

			card:setPosition(cc.p(x, y))
			plane:addChild(card)
			card:show()
			idx = idx + 1
		end

	elseif playerType == CARD_PLAYERTYPE_LEFT then
		local idx = 0
		local orlPos = 	cc.p(size.width + 60 ,size.height - cardHeight / 2 )
		local tempTag = #cardDatas

		local lastY = 0
		local lastX = 0

		for i=#notLiangCard, 1, -1 do
			local card = Card:newMingCard(playerType,notLiangCard[i])
			card:showCardBack(CARD_PLAYERTYPE_LEFT,true,1)
			card:setTag(tempTag)
			tempTag = tempTag -1

			local x = orlPos.x - (( idx - 1 ) * 8)
			local y = orlPos.y - idx * 26
			lastY = y
			lastX = x

			card:setPosition(cc.p(x, y))
			plane:addChild(card,idx)
			card:show()
			idx = idx + 1
		end	

		lastY = lastY - 26
		lastX = lastX - 8

		idx = 1

		for i=#liangcard, 1, -1 do   
			local card = Card:newMingCard(playerType,liangcard[i])
			card:setTag(tempTag)
			tempTag = tempTag -1

			local x = lastX - (( idx - 1 ) * 8)
			local y = lastY - idx * 26
			card:setPosition(cc.p(x, y))
			plane:addChild(card,idx)
			card:show()
			idx = idx + 1
		end

	elseif playerType == CARD_PLAYERTYPE_TOP then
		cardWidth = cardWidth - 5
		local oriX = cardWidth / 2
		local oriY = size.height / 2
		local idx = 0
		local lastX = 0
		
		local cardWidth1 = cardWidth*0.8
		for i=1,#notLiangCard do
			local card = Card:newMingCard(playerType,notLiangCard[i])
			card:showCardBack(CARD_PLAYERTYPE_TOP,true,1)
			card:setTag(i)

			local x = oriX + ( idx - 1 ) * cardWidth1
			lastX = x
            card:setTag(i)
            card:setPosition(cc.p(x, oriY))
			plane:addChild(card,idx)
			card:show()
			idx = idx + 1
		end	

        lastX = lastX + cardWidth1*0.5  --记录最后一张牌的布局
        local cardWidth2 = cardWidth - 3
        idx = 1

        for i=1,#liangcard do
			local card = Card:newMingCard(playerType,liangcard[i])
			card:setTag(i)

			local x = lastX + idx* cardWidth2
            card:setTag(i)
            card:setPosition(cc.p(x, oriY))
			plane:addChild(card,idx)
			card:show()
			idx = idx + 1
		end

	end	

end
-- 明牌的时候删除碰杠牌
function InhandCardMgr:removeCardsThenMing(playerType, plane, removeCards, controlType)
    local oriRemoveCount = table.getn(removeCards)

    local  isAnGang = controlType and controlType == GANG_TYPE_AN
    local  isFanGang = controlType and controlType == GANG_TYPE_PG

    if isAnGang then  --这是暗杠
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

    local maxIndex = 15
	local cardTable = {}

    for i = 1, maxIndex do
        local cardNode = plane:getChildByTag(i)
        if not cardNode then
            break
        end
        cardTable[i] = cardNode
	end

    if oriRemoveCount > 1 then
        local newCardNode = plane:getChildByTag(NEW_CARD_TAG)
        if newCardNode then
            --若没移除新牌
            removeCount = removeCount - 1
        end
        local removeIndex = 1
		local index = #cardTable - removeCount

        --  删牌的问题  先做这个处理
        for i=table.getn(cardTable),1,-1 do
            if removeIndex <= removeCount and cardTable[i].m_value == removeCards[removeIndex] then
                cardTable[i]:removeFromParent()
                removeIndex = removeIndex + 1
            else
                cardTable[i]:setTag(index)
                index = index - 1
            end
        end

        --扣牌的时候 放杠 这个时候删不了 所以在在删牌背
        if isFanGang and removeIndex == 1 then
        	local index = 1
        	for i=1,table.getn(cardTable) do
        		if cardTable[i].m_value == 0 and removeIndex <= 3 then
        			cardTable[i]:removeFromParent()
                	removeIndex = removeIndex + 1

                	dump(removeIndex,"removeIndex=")
                else
                	cardTable[i]:setTag(index)
                	index = index + 1
        		end
        	end
        end


		if playerType == CARD_PLAYERTYPE_MY then
			--self:runActionMyPosX( plane )
			self:runActionMyMingPai( plane )
		elseif playerType == CARD_PLAYERTYPE_LEFT then
			self:runActionLeftMingPai( plane )
		elseif playerType == CARD_PLAYERTYPE_RIGHT then
			self:runActionRightMingPai( plane )
		elseif playerType == CARD_PLAYERTYPE_TOP then
			self:runActionTopMingPai( plane )
		end
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
			if playerType == CARD_PLAYERTYPE_MY then
				--self:runActionMyPosX( plane )
				self:runActionMyMingPai( plane )
			elseif playerType == CARD_PLAYERTYPE_LEFT then
				self:runActionLeftMingPai( plane )
			elseif playerType == CARD_PLAYERTYPE_RIGHT then
				self:runActionRightMingPai( plane )
			elseif playerType == CARD_PLAYERTYPE_TOP then
				self:runActionTopMingPai( plane )
			end
        end

    end
end


--设置扣牌（手牌中有三个三个的就变白 可点）
function InhandCardMgr:setKouPai(plane)
	local childs = plane:getChildren()
	local tempTab = {}
	local index = 1

	if not childs then
		return
	end

	table.sort(childs, function(a,b)
        return a.m_value < b.m_value
    end)

	local tabSize = 0

	for i=1,#childs-1 do
		if childs[i].m_value == childs[i+1].m_value then
			index = index + 1
		else
			index = 1
		end

		if index == 3 then
			tempTab[childs[i].m_value] = 1
			index = 1
			tabSize = tabSize + 1
		end
	end

	dump(tempTab,"tempTab")

	for i,v1 in ipairs(childs) do
		if tempTab[v1.m_value] == 1 then
			v1:setColor(cc.c3b(255,255,255))
			v1.m_isBlack = false
		else
			v1:setColor(cc.c3b(191,191,191))
			v1.m_isBlack = true
		end
	end

	return tabSize
end


function InhandCardMgr:setKouPaiShowCardBack(plane,value)  --让其显示变成牌背
	local childs = plane:getChildren()
	if not childs then
		return
	end

	if value then
		for i,v1 in ipairs(childs) do
			if v1.m_value == value then
				v1:showCardBack(CARD_PLAYERTYPE_MY,true,1)
			end
		end
	else
		for i,v1 in ipairs(childs) do
			v1:showCardBack(CARD_PLAYERTYPE_MY,false,1)
		end
	end
end

function InhandCardMgr:runActionLeftMingPai( plane )
    local chids = plane:getChildren()
	local card = chids[1]
    if not card then
        return
	end

	local cardDatas = {}
	for i,v in ipairs(chids) do
		table.insert(cardDatas,v.m_value)
	end

	table.sort(cardDatas,function(a,b)
		return a < b
	end)


	local playerType = CARD_PLAYERTYPE_LEFT
	local notLiangCard,liangcard = self:getNewLiangPaiCard(cardDatas,LIANGCARDS_HU[playerType])
	table.sort(notLiangCard,function(a,b)
			return a < b
		end)	
	table.sort(liangcard,function(a,b)
			return a < b
		end)


	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width
	local number = table.getn(cardDatas)
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale
	plane:removeAllChildren()


	local orlPos = 	cc.p(size.width + 60 ,size.height - cardHeight / 2 )
	local idx = 0
	local lastY = 0
	local lastX = 0

	for i=#notLiangCard, 1, -1 do
		local cardData = notLiangCard[i]
		local card = Card:newMingCard(playerType,cardData)
		card:showCardBack(CARD_PLAYERTYPE_LEFT,true,1)
		card:setTag(i)

		local x = orlPos.x - (( idx - 1 ) * 8)
		local y = orlPos.y - idx * 26
		lastY = y
		lastX = x

		plane:addChild(card,idx)
		card:show()
		idx = idx + 1
		card:runAction(cc.MoveTo:create(0.3, cc.p(x, y)))
	end

	lastY = lastY - 26
	lastX = lastX - 8

	idx = 1
	for i=#liangcard, 1, -1 do   
		local cardData = liangcard[i]
		local card = Card:newMingCard(playerType,cardData)
		card:setTag(i)

		local x = lastX - (( idx - 1 ) * 8)
		local y = lastY - idx * 26
		plane:addChild(card,idx)
		card:show()
		idx = idx + 1
		card:runAction(cc.MoveTo:create(0.3, cc.p(x, y)))
	end

end

function InhandCardMgr:runActionRightMingPai( plane )
    local chids = plane:getChildren()
	local card = chids[1]
    if not card then
        return
	end

	local cardDatas = {}
	for i,v in ipairs(chids) do
		table.insert(cardDatas,v.m_value)
	end

	table.sort(cardDatas,function(a,b)
		return a < b
	end)

	local playerType = CARD_PLAYERTYPE_RIGHT
	local notLiangCard,liangcard = self:getNewLiangPaiCard(cardDatas,LIANGCARDS_HU[playerType])
	table.sort(notLiangCard,function(a,b)
			return a < b
		end)	
	table.sort(liangcard,function(a,b)
			return a < b
		end)

	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width
	local number = table.getn(cardDatas)
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale
	plane:removeAllChildren()

	local idx = 0
	local orlPos = 	cc.p(size.width/2 + 10,size.height - cardHeight )

	local lastY = 0
	local lastX = 0

	for i=#notLiangCard, 1, -1 do
		local flag = 1 
		local cardData = notLiangCard[i]

		local card = Card:newMingCard(playerType,cardData)
		card:showCardBack(CARD_PLAYERTYPE_RIGHT,true,1)
		card:setTag(i)

		local x = orlPos.x + (( idx - 1 ) * 9)
		local y = orlPos.y - idx * 27

		lastY = y
		lastX = x

		plane:addChild(card)
		card:show()
		idx = idx + 1
		card:runAction(cc.MoveTo:create(0.3, cc.p(x, y)))

	end

	lastY = lastY - 27
	lastX = lastX + 9

	idx = 1
	for i=#liangcard, 1, -1 do  
		local cardData = liangcard[i]
		local card = Card:newMingCard(playerType,cardData)
		card:setTag(i)

		local x = lastX + (( idx - 1 ) * 9)
		local y = lastY - idx * 27

		plane:addChild(card)
		card:show()
		idx = idx + 1

		card:runAction(cc.MoveTo:create(0.3, cc.p(x, y)))
	end

end

function InhandCardMgr:runActionTopMingPai( plane )
    local chids = plane:getChildren()
	local card = chids[1]
    if not card then
        return
	end

	local cardDatas = {}
	for i,v in ipairs(chids) do
		table.insert(cardDatas,v.m_value)
	end

	table.sort(cardDatas,function(a,b)
		return a < b
	end)

	dump(cardDatas,"runActionTopMingPai----cardDatas")

	local playerType = CARD_PLAYERTYPE_TOP

	local notLiangCard,liangcard = self:getNewLiangPaiCard(cardDatas,LIANGCARDS_HU[playerType])
	table.sort(notLiangCard,function(a,b)
			return a < b
		end)	
	table.sort(liangcard,function(a,b)
			return a < b
		end)

	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width

	local number = table.getn(cardDatas)
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale

	plane:removeAllChildren()

	cardWidth = cardWidth
	local oriX = cardWidth / 2 + 25
	local oriY = size.height / 2
	local idx = 0
	local lastX = 0
		
	local cardWidth1 = cardWidth
    for i=1,#notLiangCard do
        local cardData = notLiangCard[i]
		local card = Card:newMingCard(playerType,cardData)
		card:showCardBack(CARD_PLAYERTYPE_TOP,true,1)
		if idx== 0 then
			cardWidth1 = card:getSize().width
		end

		local x = oriX + ( idx - 1 ) * cardWidth1
		lastX = x
        card:setTag(i)

		plane:addChild(card,idx)
		card:show()
		idx = idx + 1

		card:runAction(cc.MoveTo:create(0.3, cc.p(x, oriY)))
    end
    lastX = lastX + cardWidth1*0.5 + 5  --记录最后一张牌的布局


    local cardWidth2 = cardWidth+5
    idx = 1

   	for i=1,#liangcard do
        local cardData = liangcard[i]
		--显示亮牌的
		local card = Card:newMingCard(playerType,cardData)
		if idx== 1 then
			cardWidth2 = card:getSize().width
		end
		local x = lastX + cardWidth2*0.5 +(idx-1)* cardWidth2
        card:setTag(i)
		plane:addChild(card,idx)
		card:show()
		idx = idx + 1

		card:runAction(cc.MoveTo:create(0.3, cc.p(x, oriY)))
	end

	
	--[[
	显示全部亮牌的
	chids = self:sortCardsNode( chids, false )
	local size = plane:getSize()
	local cardWidth = card:getSize().width

	local scale = 1
	cardWidth = cardWidth * scale
	local cardHeight = card:getSize().height
	cardHeight = cardHeight * scale
	cardWidth = cardWidth - 5* scale

	local oriX = cardWidth / 2
	local oriY = size.height / 2

	local index = 0
    for idx,node in ipairs(chids) do
		local x = oriX + index  * (cardWidth - 3)
		node:show()
		node:stopAllActions()
		node:runAction(cc.MoveTo:create(0.3, cc.p(x, oriY)))
		index = index + 1
    end--]]
end

function InhandCardMgr:runActionMyMingPai( plane )
    local chids = plane:getChildren()
	local card = chids[1]
    if not card then
        return
	end

	local cardDatas = {}
	for i,v in ipairs(chids) do
		table.insert(cardDatas,v.m_value)
	end

	table.sort(cardDatas,function(a,b)
		return a < b
	end)

	local playerType = CARD_PLAYERTYPE_MY
	local card = Card:newMingCard(CARD_PLAYERTYPE_MY,1)
	plane:removeAllChildren()

	--部分亮牌的
	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width
	local number = table.getn(cardDatas)
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale

	local uid = USER_INFO["uid"]
	local kouCards = SZKWX_PLAYERS_INFOS[uid].kouPaitabs or {}

	local notLiangCard,liangcard = self:getNewLiangPaiCard(cardDatas,LIANGCARDS_HU[playerType])

	local idx = 0
	local lastX = 0
	local cardWidth1 = cardWidth
	local oriX = size.width - cardWidth / 2
	local oriY = size.height / 2

	for i=#liangcard, 1, -1 do 
		local cardData = liangcard[i]
		local card = Card:newMingCard(playerType,cardData)
		card:setTag(i)

		local x = oriX - idx * cardWidth1
		lastX = x
        
		if playerType == CARD_PLAYERTYPE_MY then
			card:setColor(cc.c3b(191,191,191))
			card.m_isBlack = true
		end

        plane:addChild(card)
		card:show()
		idx = idx + 1
		card:runAction(cc.MoveTo:create(0.3, cc.p(x, oriY)))
	end

	lastX = lastX - cardWidth1*0.5
	idx = 1	
	local lastX1 = lastX

	local cardWidth2 = cardWidth
	if cardWidth < 80 then
		cardWidth2 = 1.1*cardWidth2
	end

	for i=#notLiangCard, 1, -1 do

		local flag = 0
		for j,v in ipairs(kouCards) do
			if v == notLiangCard[i] then  --有扣牌
				flag = 1
			end
		end 

		if flag == 0 then
			local cardData = notLiangCard[i]
			local card = Card:newMyInHandCard(cardData)
			card:setTag(i)

			local x = lastX - idx* cardWidth2
			lastX1 = x
	        
			if playerType == CARD_PLAYERTYPE_MY then
				card.m_isBlack = true
			end

	        plane:addChild(card)
			card:show()
			idx = idx + 1

			card:runAction(cc.MoveTo:create(0.3, cc.p(x, oriY)))
		end
	end

	lastX1 = lastX1 - 10
	--显示扣牌的牌
	idx = 1
	local cardWidth3 = cardWidth
	if cardWidth < 80 then
		cardWidth3 = 1.1*cardWidth3
	end
	
	for i=#notLiangCard, 1, -1 do

		local flag = 0
		for j,v in ipairs(kouCards) do
			if v == notLiangCard[i] then  --有扣牌
				flag = 1
			end
		end 

		if flag == 1 then
			local cardData = notLiangCard[i]
			local card = Card:newMingCard(playerType,cardData)
			card:setTag(i)
			card:showCardBack(CARD_PLAYERTYPE_MY,true,1)

			local x = lastX1 - idx * cardWidth3
	        
			if playerType == CARD_PLAYERTYPE_MY then
				card:setColor(cc.c3b(191,191,191))
				card.m_isBlack = true
			end

	        plane:addChild(card)
			card:show()
			idx = idx + 1

			card:runAction(cc.MoveTo:create(0.3, cc.p(x, oriY)))
		end
	end
end

function InhandCardMgr:setOtherPlayerHuCardsNotClick(playertype,plane,notClickCards)
	local childs = plane:getChildren()
	if not childs then
		return
	end

	for i,v1 in ipairs(childs) do
		dump(v1,"v1=")
		if v1 and v1.m_value and v1.m_value > 0 then   --非牌背要判断一波
			if notClickCards[v1.m_value] == 1 then
				v1:setColor(cc.c3b(191,191,191))
				v1.m_isBlack = true
			end	
		end
	end
end

function InhandCardMgr:getNewLiangPaiCard(handCards,huCards)
	--table.insert(handCards,17)
	dump(huCards,"huCards1===")
    local temoHuCard ={}
    for i,v in ipairs(huCards) do
		for i1,v1 in ipairs(v.huCards) do
			if not temoHuCard[v1]then
				temoHuCard[v1] = 1
			end
        end
    end

	local huCardsTemp={}
	local flag = false
	for key,value in pairs(temoHuCard) do
		if bit.band(key, 0x0F) == 5 then
			flag = true
		end
		table.insert(huCardsTemp,key)
	end

	table.sort(huCardsTemp,function(a,b)
		return a > b
	end)
	dump(huCardsTemp,"huCardsTemp")
	local tableList = mahjongLogic.getBaiCards(handCards, {}, {}, {}, {})

	local tempCard = {}
	local tempCardCount = {}

	for i,v in ipairs(handCards) do
		tempCard[v]=0
		if tempCardCount[v] then
			tempCardCount[v] = tempCardCount[v] + 1
		else
			tempCardCount[v] = 1
		end
	end
	local tingTable = {}
	local addBaiPai = {}
	for i,v in ipairs(tableList) do
		local tempList = {}
		for i,v in ipairs(v["tingcards"]) do
			table.insert(tempList, v["tingcard"])
		end

		table.sort(tempList,function(a,b)
			return a > b
		end)
		dump(tempList,"tempList==")
		if #tempList == #huCardsTemp then
			local isTing = true
			for i2, v2 in ipairs(tempList) do
				if tempList[i2] ~= huCardsTemp[i2] then
					isTing = false
					break
				end
			end
			if isTing then
				table.insert(tingTable,v)
			end
		end
		if flag then
			if #v["tingcards"] == 1 and #v["baicards"] == 2 and (bit.band(v["tingcards"][1]["tingcard"], 0x0F) == 5) then

				local card1 = bit.band(v["baicards"][1], 0x0F)
				local card2 = bit.band(v["baicards"][2], 0x0F)


				if ((card1+1) == 5) and ((card2 -1) == 5) then
					table.insert(addBaiPai,v["baicards"][1])
					table.insert(addBaiPai,v["baicards"][2])
					table.insert(addBaiPai,v["tingcards"][1]["tingcard"])
				end
			end
		end
	end
	dump(tingTable,"tingTable")
	local listTempCards = {}
	for i,v in ipairs(handCards) do
		table.insert(listTempCards,v)
	end
	for i,v in ipairs(tingTable[1]["baicards"]) do
		for i2,v2 in ipairs(listTempCards) do
			if v == v2 then
				table.remove(listTempCards,i2)
				break
			end
		end
		tempCard[v] =tempCard[v]+1
	end

	function v_include(tab, value)
		for k,v in pairs(tab) do
			if v == value then
				return true
			end
		end
		return false
	end

	local isAddTing = true
	if #addBaiPai == 3 then
		for k2,v2 in ipairs(addBaiPai) do
			if v_include(listTempCards,v2) == false then
				isAddTing = false
				break
			end

		end
		dump(isAddTing,"huCards-666==--------------")
		if isAddTing then
			for k2,v2 in ipairs(addBaiPai) do
				tempCard[v2] =tempCard[v2]+1
			end
		end
	end

	local notLiangCard = {}
	local mayBeHuCard = {}
	for i,v in ipairs(handCards) do
		if tempCard[v] == 0 then
			table.insert(notLiangCard,v)  --这里可以确定没有涉及到胡的牌
		else
			--有被涉及到的牌 但是要去重
			table.insert(mayBeHuCard,v)  --这里可以确定没有涉及到胡的牌
		end
	end

	 dump(tempCard,"tempCard======99999")
	-- dump(notLiangCard,"notLiangCard111===")
	-- dump(mayBeHuCard,"mayBeHuCard111===")
	-- dump(tempCard,"tempCard==")

	for i,v in ipairs(mayBeHuCard) do
		if v > 0 then
			if tempCard[v] < tempCardCount[v] then
				local num = tempCardCount[v] - tempCard[v]
				for i=1,num do
					table.insert(notLiangCard,v)
				end

				for i1,v1 in ipairs(mayBeHuCard) do
					if v == v1 then
						mayBeHuCard[i1] = 0
					end
				end
			end
		end
	end

	table.sort(notLiangCard)

	--dump(notLiangCard,"notLiangCard2222===")

	local tempHandcards = {}
	local tempNotLiang = {}

	for i,v in ipairs(handCards) do --潜拷贝
		table.insert(tempHandcards,v)
	end

	for i,v in ipairs(notLiangCard) do --潜拷贝
		table.insert(tempNotLiang,v)
	end

	-- dump(tempHandcards,"tempHandcards===")
	-- dump(tempNotLiang,"tempNotLiang===")

	for i,v in ipairs(tempHandcards) do
		if v>0 then
			for i1,v1 in ipairs(tempNotLiang) do
				if v == v1 then
					v = 0
					tempHandcards[i] = 0
					tempNotLiang[i1] = 0
				end
			end
		end
	end

	-- dump(tempHandcards,"tempHandcards===>>>>")
	-- dump(tempNotLiang,"tempNotLiang===")

	local liangCards = {}

	for i,v in ipairs(tempHandcards) do
		if v > 0 then
			table.insert(liangCards,v)
		end
	end

	-- dump(notLiangCard,"notLiangCard3333===")
	-- dump(liangCards,"liangCards3333===")

	if #liangCards + #notLiangCard == #handCards then
		return notLiangCard,liangCards
	else
		return {},{}
	end
end

return InhandCardMgr