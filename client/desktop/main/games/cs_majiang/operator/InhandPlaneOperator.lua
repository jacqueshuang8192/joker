local Card = require("cs_majiang.card.card")
local cardUtils = require("cs_majiang.utils.cardUtils")

local InhandPlaneOperator = class("InhandPlaneOperator")

local SPLIT_NEWCARD = 25

local selectedTag = 99

local NEW_CARD_TAG = 20

local cardTemp = nil

function InhandPlaneOperator:init(playerType, plane)
	plane:removeAllChildren()

	-- if playerType == CARD_PLAYERTYPE_MY then
	-- 	--todo
	-- 	plane:setSize(cc.size(0, plane:getSize().height))
	-- elseif playerType == CARD_PLAYERTYPE_LEFT then
	-- 	plane:setSize(cc.size(plane:getSize().width, 0))
	-- elseif playerType == CARD_PLAYERTYPE_RIGHT then
	-- 	plane:setSize(cc.size(plane:getSize().width, 0))
	-- elseif playerType == CARD_PLAYERTYPE_TOP then
	-- 	plane:setSize(cc.size(0, plane:getSize().height))
	-- end
	
end

function InhandPlaneOperator:showCards(playerType, plane, cardDatas,tingSeq)----显示手牌	

	table.sort(cardDatas)


	dump(playerType,"--InhandPlaneOperator:showCards_1")
	dump(cardDatas,"--InhandPlaneOperator:showCards_2")

	local cardsSeq = {}
	-- local laiziSeq = {}
	--癞子放到左侧
	for k,v in pairs(cardDatas) do
  --       if v == HHMJ_LAIZI then
		-- 	local cardData = D3_CARDDATA:new(v, 0, CARDNODE_TYPE_LAIZI)

		-- 	table.insert(laiziSeq, 1, cardData)
		-- else
			local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)

			table.insert(cardsSeq, cardData)
		-- end
	end

	-- for i,v in ipairs(laiziSeq) do
	-- 	table.insert(cardsSeq, 1, v)
	-- end

	D3_OPERATOR:showCards(playerType, plane, cardsSeq)
end



--旧显示手牌函数
-- function InhandPlaneOperator:showCards(playerType, plane, cardDatas, tingSeq)
-- 	plane:removeAllChildren()
    
-- 	if playerType == CARD_PLAYERTYPE_MY then
        
--         --癞子放到左侧
--         for k,v in pairs(cardDatas) do
-- 			if v == 65 then
-- 				table.remove(cardDatas,k)
-- 				table.insert(cardDatas,1,v)
-- 			end
-- 		end

-- 		local oriX = 0
-- 		local oriY = plane:getSize().height / 2

-- 		local function onTouchBegan(touch, event)
-- 		    if D3_CHUPAI == 1 then
-- 		    	--todo

-- 		    	cardTemp = nil
-- 		    	local children = plane:getChildren()

-- 		    	for k,v in pairs(children) do
		        	
-- 				    --todo
-- 				    local locationInNode = v:convertToNodeSpace(touch:getLocation())

-- 					local s = v:getContentSize()
-- 					local rect = cc.rect(0, 0, s.width, s.height)
-- 					if cc.rectContainsPoint(rect, locationInNode) then
-- 						-- v:setOpacity(180)
-- 						cardTemp = v
-- 						self.cardOriPosition = cardTemp:getPosition()
-- 					end
				        	
-- 				end
-- 				if cardTemp then  --and cardTemp:getTag() ~= NEW_CARD_TAG 

-- 					CSMJ_CONTROLLER:hideSameCard()
-- 					CSMJ_CONTROLLER:hideTingHuPlane()
-- 					local  myhandcardnode = plane:getChildren()  --手牌不会为0
-- 		            for i,v in ipairs(myhandcardnode) do
-- 		            	v:setColor(cc.c3b(255,255,255))
-- 		            end
                    
--                     cardTemp:setColor(cc.c3b(250, 250, 0))
-- 					CSMJ_CONTROLLER:showSameCard(cardTemp.m_value)

-- 					if tingSeq~={} and  tingSeq~=nil  then  --听队列存在时才遍历
-- 					  for k,v in pairs(tingSeq) do
-- 						if v.card == cardTemp.m_value then
-- 							--显示听得牌
-- 								-- --dump(v.tingHuCards,"显示听得牌1")
-- 							CSMJ_CONTROLLER:showTingHuPlane(CARD_PLAYERTYPE_MY,v.tingHuCards)
-- 						break
-- 						end
-- 					  end
-- 					end
                    
-- 					if selectedTag == 99 then
-- 						--todoh
-- 						self.canMove = true
-- 					else
-- 						self.canMove = false
-- 					end
-- 					return true
-- 				else
-- 					return false
-- 				end
-- 		    end

-- 		    return false
-- 		end

-- 		local function onTouchMoved(touch, event)
-- 			if cardTemp then
-- 			    if self.canMove then
-- 			    	--todo
-- 			    	local posX = cardTemp:getPositionX()
-- 			    	local posY = cardTemp:getPositionY()
-- 			    	local delta = touch:getDelta()
-- 			    	cardTemp:setPosition(cc.p(posX + delta.x, posY + delta.y))
-- 			    end
-- 			end
-- 		end

-- 		local function onTouchEnded(touch, event)
-- 		   	if cardTemp then  	

-- 		   		local offsetY = cardTemp:getPosition().y - cardTemp:getSize().height / 2
-- 		   		if offsetY > plane:getSize().height then
-- 		   			--超出范围，出牌
-- 		   			CSMJ_CONTROLLER:playCard(cardTemp.m_value)
-- 		   			cardTemp:removeFromParent()
-- 		   		else
-- 		   			local locationInNode = cardTemp:convertToNodeSpace(touch:getLocation())
-- 		   			local rect = cc.rect(0, 0, cardTemp:getContentSize().width, cardTemp:getContentSize().height)
-- 					if cc.rectContainsPoint(rect, locationInNode) then
-- 						if selectedTag == cardTemp:getTag() then
-- 						    --出牌
-- 							CSMJ_CONTROLLER:playCard(cardTemp.m_value)
-- 						else
-- 							self:cancelSelectingCard(plane)

-- 							local p = cardTemp:getPosition()

-- 							if self.canMove then
-- 								--todo
-- 								p = self.cardOriPosition
-- 							end

-- 							cardTemp:setScale(1.2)
-- 							local offsetX = 0.1 * cardTemp:getSize().width

-- 							cardTemp:setPosition(cc.p(p.x + offsetX / 2, p.y + 30))

-- 							local tag = cardTemp:getTag()
-- 							selectedTag = tag
-- 							tag = tag + 1
-- 							local nextCard = plane:getChildByTag(tag)
-- 							while nextCard do
-- 								--todo
-- 								nextCard:setPosition(cc.p(nextCard:getPosition().x + offsetX, nextCard:getPosition().y))
  
-- 								tag = tag + 1
-- 								nextCard = plane:getChildByTag(tag)
-- 							end
-- 						end
-- 					else
-- 						self:cancelSelectingCard(plane)
-- 					end
		   			
-- 		   		end
-- 		   	end
-- 		end

-- 		local listener1 = cc.EventListenerTouchOneByOne:create()
--    		listener1:setSwallowTouches(true)
-- 		listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
-- 		listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
-- 		listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

-- 		local eventDispatcher = SCENENOW["scene"]:getEventDispatcher()
		    
-- 		--画牌部分
-- 		for i=1,table.getn(cardDatas) do
-- 			local data = cardDatas[i]
-- 		   	    local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data)
-- 					card:setScale(card:getScale() * 1.1)
-- 					-- card:setAnchorPoint(cc.p(0, 0))
-- 					card:setPosition(cc.p(oriX + card:getSize().width * card:getScale() / 2, card:getSize().height * card:getScale() / 2))

-- 					card:setTouchEnabled(false)

-- 					eventDispatcher:addEventListenerWithSceneGraphPriority(listener1:clone(), card)


-- 					card:setTag(i)

-- 					plane:addChild(card)

-- 					oriX = oriX + card:getSize().width * card:getScale()
-- 		end

-- 		local width = oriX + 81 * 1.1
-- 		plane:setSize(cc.size(width, plane:getSize().height))

-- 	elseif playerType == CARD_PLAYERTYPE_LEFT then
-- 		--todo
-- 		local oriX = plane:getSize().width / 2
-- 		local count = table.getn(cardDatas)
-- 		local totalHeight = count * 22 + 11 + 44
-- 		local oriY = totalHeight - 22

-- 		for i=1,count do
-- 			local data = cardDatas[i]

-- 			local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data,false)

-- 			card:addTouchEventListener(function(sender, event)
-- 					----print("123")
-- 				end)

-- 			card:setPosition(cc.p(oriX, oriY))

-- 			card:setTag(i)

-- 			plane:addChild(card)

-- 			oriY = oriY - 22
-- 		end

-- 		plane:setSize(cc.size(plane:getSize().width, totalHeight))
-- 	elseif playerType == CARD_PLAYERTYPE_RIGHT then
-- 		local oriX = plane:getSize().width / 2
-- 		local oriY = 44 / 2
-- 		local count = table.getn(cardDatas)

-- 		for i=1,count do
-- 			local data = cardDatas[i]

-- 			local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data,false)

-- 			card:setPosition(cc.p(oriX, oriY))

-- 			card:setLocalZOrder(20 - i)

-- 			card:setTag(i)

-- 			plane:addChild(card)

-- 			oriY = oriY + (44 - 22)
-- 		end

-- 		plane:setSize(cc.size(plane:getSize().width, oriY - 22 + 11 + 44))
-- 	elseif playerType == CARD_PLAYERTYPE_TOP then
-- 		local count = table.getn(cardDatas)
-- 		local totalWidth = count * 30 + 15 + 30
-- 		local oriX = totalWidth - 15
-- 		local oriY = plane:getSize().height / 2

-- 		for i=1,count do
-- 			local data = cardDatas[i]

-- 			local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data,false)

-- 			card:setPosition(cc.p(oriX, oriY))

-- 			card:setTag(i)

-- 			plane:addChild(card)

-- 			oriX = oriX - 30
-- 		end

-- 		plane:setSize(cc.size(totalWidth, plane:getSize().height))
-- 	end
-- end


--旧胡牌时摊牌
-- function InhandPlaneOperator:showCardsForAll(playerType, plane, cardDatas, anke)
-- 	plane:removeAllChildren()

-- 	local cardsTemp = {}
-- 	for k,v in pairs(cardDatas) do
-- 		local isAnke = false
-- 		for m,n in pairs(anke) do
-- 			if v == n then
-- 				--todo
-- 				isAnke = true
-- 				break
-- 			end
-- 		end
-- 		if isAnke then
-- 			--todo
			
-- 			if playerType == CARD_PLAYERTYPE_MY then
-- 				--todo
-- 				table.insert(cardsTemp, 100 + v)
-- 			else
-- 				table.insert(cardsTemp, -1)
-- 			end
-- 		else
-- 			table.insert(cardsTemp, v)
-- 		end
-- 	end

-- 	table.sort(cardsTemp)

-- 	if playerType == CARD_PLAYERTYPE_MY then
-- 		--todo
-- 		local size = plane:getSize()
-- 		local oriX = 0

-- 		for i=1,table.getn(cardsTemp) do
-- 			local cardData = cardsTemp[i]

-- 			local card

-- 			if cardData > 100 then
-- 				--todo
-- 				card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_SHOW, cardData - 100)

-- 				card:setColor(cc.c3b(140, 140, 140))
-- 			else
-- 				card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_SHOW, cardData)
-- 			end

-- 			card:setScale(card:getScale() * 1.1)

-- 			card:setPosition(cc.p(oriX + card:getSize().width * card:getScale() / 2, card:getSize().height * card:getScale() / 2))

-- 			plane:addChild(card)

-- 			oriX = oriX + (card:getSize().width - 1.5) * card:getScale()

-- 		end

-- 		plane:setSize(cc.size(oriX + 75 * 1.1, size.height))
-- 	elseif playerType == CARD_PLAYERTYPE_LEFT then
-- 		----print("gang lefthand test")
-- 		local size = plane:getSize()

-- 		local count = table.getn(cardsTemp)

-- 		for i=1,count do
-- 			local cardData = cardsTemp[i]

-- 			local card

-- 			if cardData ~= -1 then
-- 				--todo
-- 				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_SHOW, cardData)
-- 			else
-- 				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_HIDE, cardData)
-- 			end

-- 			card:setPosition(cc.p(size.width / 2, (count - i + 0.5) * 23 + 46))

-- 			plane:addChild(card)
-- 		end

-- 		plane:setSize(cc.size(plane:getSize().width, count * 23 + 46))
-- 	elseif playerType == CARD_PLAYERTYPE_RIGHT then
-- 		--todo
-- 		local size = plane:getSize()
-- 		local oriY = 0

-- 		for i=1,table.getn(cardsTemp) do
-- 			local cardData = cardsTemp[i]

-- 			local card

-- 			if cardData ~= -1 then
-- 				--todo
-- 				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_SHOW, cardData)
-- 			else
-- 				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_HIDE, cardData)
-- 			end

-- 			card:setPosition(cc.p(size.width / 2, oriY + 23 / 2))

-- 			card:setLocalZOrder(100 - plane:getChildrenCount())

-- 			plane:addChild(card)

-- 			oriY = oriY + 23
-- 		end

-- 		plane:setSize(cc.size(plane:getSize().width, oriY + 46))
-- 	elseif playerType == CARD_PLAYERTYPE_TOP then
-- 		local size = plane:getSize()

-- 		local count = table.getn(cardsTemp)

-- 		for i=1,count do
-- 			local cardData = cardsTemp[i]

-- 			local card

-- 			if cardData ~= -1 then
-- 				--todo
-- 				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_SHOW, cardData)
-- 			else
-- 				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_HIDE, cardData)
-- 			end

-- 			card:setPosition(cc.p((count - i + 0.5) * 27 + 27 * 1.5, size.height / 2))

-- 			plane:addChild(card)
-- 		end

-- 		plane:setSize(cc.size(count * 27 + 27 * 1.5, plane:getSize().height))
-- 	end
-- end


--新胡牌时摊牌  斜着显示出来
function InhandPlaneOperator:showCardsForAll(playerType, plane, cardDatas, anke)---显示所有的牌（胡牌的时候）

	table.sort(cardDatas)

	local cardsSeq = {}
	--癞子放到左侧
	for k,v in pairs(cardDatas) do
        
		local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)

		table.insert(cardsSeq, cardData)
	end

	D3_OPERATOR:showCardsForAll( playerType, plane, {}, cardsSeq )

end

---取消选择中的牌
function InhandPlaneOperator:cancelSelectingCard(plane)
	-- if selectedTag == 99 then
	-- 	--todo
	-- 	return
	-- end

	-- local selectedCard = plane:getChildByTag(selectedTag)

	-- if selectedCard then
	-- 	--todo
	-- 	local oriY = plane:getSize().height / 2

	-- 	local position = selectedCard:getPosition()

	-- 	if position.y > oriY then
	-- 		--todo
	-- 		selectedCard:setScale(1.1)
	-- 		local offsetX = 0.1 * selectedCard:getSize().width
	-- 		selectedCard:setPosition(cc.p(selectedCard:getPosition().x - offsetX / 2, selectedCard:getSize().height * selectedCard:getScale() / 2))

	-- 		local tag = selectedCard:getTag()
	-- 		tag = tag + 1
	-- 		local nextCard = plane:getChildByTag(tag)
	-- 		while nextCard do
	-- 			--todo
	-- 			nextCard:setPosition(cc.p(nextCard:getPosition().x - offsetX, nextCard:getPosition().y))
 --                -- nextCard:setColor(cc.c3b(255,255,255))
 --                tag = tag + 1

 --                nextCard = plane:getChildByTag(tag)
               
 --            end

 --            selectedTag = 99
 --            D3_CHUPAI = 1
 --        end
 --        D3_CHUPAI = 1
 --    end
 --     D3_CHUPAI = 1
    
end


-- --旧取消选择中的牌
-- function InhandPlaneOperator:cancelSelectingCard(plane)
-- 	if selectedTag == 99 then
-- 		--todo
-- 		return
-- 	end

-- 	local selectedCard = plane:getChildByTag(selectedTag)

-- 	if selectedCard then
-- 		--todo
-- 		local oriY = plane:getSize().height / 2

-- 		local position = selectedCard:getPosition()

-- 		if position.y > oriY then
-- 			--todo
-- 			selectedCard:setScale(1.1)
-- 			local offsetX = 0.1 * selectedCard:getSize().width
-- 			selectedCard:setPosition(cc.p(selectedCard:getPosition().x - offsetX / 2, selectedCard:getSize().height * selectedCard:getScale() / 2))

-- 			local tag = selectedCard:getTag()
-- 			tag = tag + 1
-- 			local nextCard = plane:getChildByTag(tag)
-- 			while nextCard do
-- 				--todo
-- 				nextCard:setPosition(cc.p(nextCard:getPosition().x - offsetX, nextCard:getPosition().y))
--                 -- nextCard:setColor(cc.c3b(255,255,255))
-- 				tag = tag + 1

-- 				nextCard = plane:getChildByTag(tag)
-- 			end

-- 			selectedTag = 99
-- 		end
-- 	end
-- end


-- --旧摸牌
-- function InhandPlaneOperator:getNewCard(playerType, plane, value,tingSeq)
-- 	local displayType = CARD_DISPLAY_TYPE_OPPOSIVE
-- 	local seatId = CSMJ_SEAT_TABLE_BY_TYPE[playerType .. ""]
-- 	-- local tingFlag = CSMJ_GAMEINFO_TABLE[seatId .. ""].ting
-- 	-- if tingFlag == 1 and CSMJ_ROOM.isBufenLiang ~= 1 then
-- 	-- 	--todo
-- 	-- 	displayType = CARD_DISPLAY_TYPE_SHOW
-- 	-- end
   

-- 	if playerType == CARD_PLAYERTYPE_MY then
-- 		--todo
-- 		local card = Card:new(playerType, CARD_TYPE_INHAND, displayType, value)
-- 		card:setTag(NEW_CARD_TAG)

-- 		-- card:addTouchEventListener(function(sender, event)
--   --               if event == TOUCH_EVENT_BEGAN then 
--   --               	CSMJ_CONTROLLER:showSameCard(value)
--   --               	CSMJ_CONTROLLER:hideTingHuPlane()
--   --               end
			
-- 		-- 		if event == TOUCH_EVENT_ENDED then
-- 		-- 			--todo
-- 		-- 			if sender:getTag() == NEW_CARD_TAG and D3_CHUPAI == 1 then
--   --                       CSMJ_CONTROLLER:hideSameCard()
-- 		-- 				if tingSeq~={} and tingSeq~=nil then  --听队列存在时才遍历
-- 		-- 				  for k,v in pairs(tingSeq) do
-- 		-- 					if v.card == value then
-- 		-- 						--显示听得牌
-- 		-- 						CSMJ_CONTROLLER:showTingHuPlane(CARD_PLAYERTYPE_MY,v.tingHuCards)
-- 		-- 					break
-- 		-- 					end
-- 		-- 				  end
-- 		-- 				end
						
-- 		-- 				CSMJ_CONTROLLER:playCard(value)
-- 		-- 			end
-- 		-- 		end
-- 		-- 	end)

-- 		local size = plane:getSize()

-- 		card:setScale(card:getScale() * 1.1)
-- 		card:setPosition(cc.p(size.width - card:getSize().width / 2 * card:getScale(), card:getSize().height * card:getScale() / 2))
--         card:setTouchEnabled(false)
-- 		plane:addChild(card)
		
-- 	elseif playerType == CARD_PLAYERTYPE_LEFT then
-- 		local card = Card:new(playerType, CARD_TYPE_INHAND, displayType, value)
-- 		card:setTag(NEW_CARD_TAG)

-- 		local size = plane:getSize()

-- 		card:setPosition(cc.p(size.width / 2, card:getSize().height / 2))

-- 		plane:addChild(card)
-- 	elseif playerType == CARD_PLAYERTYPE_RIGHT then
-- 		local card = Card:new(playerType, CARD_TYPE_INHAND, displayType, value)
-- 		card:setTag(NEW_CARD_TAG)

-- 		local size = plane:getSize()

-- 		card:setPosition(cc.p(size.width / 2, size.height - card:getSize().height / 2))

-- 		plane:addChild(card)
-- 	elseif playerType == CARD_PLAYERTYPE_TOP then
-- 		local card = Card:new(playerType, CARD_TYPE_INHAND, displayType, value)
-- 		card:setTag(NEW_CARD_TAG)

-- 		local size = plane:getSize()

-- 		card:setPosition(cc.p(30 / 2, size.height / 2))

-- 		plane:addChild(card)
-- 	end	
-- end


--新摸牌
function InhandPlaneOperator:getNewCard(playerType, plane, value,tingSeq)

	local cardData = D3_CARDDATA:new(value, 1, CARDNODE_TYPE_NORMAL)

	D3_OPERATOR:getNewCard(playerType, plane, cardData, false)
end

function InhandPlaneOperator:showHuCard(playerType, plane, value)

	if value == 0 then
		return
	end
	
	local cardData = D3_CARDDATA:new(value, 1, CARDNODE_TYPE_NORMAL)

	D3_OPERATOR:getNewCard(playerType, plane, cardData, true)
end


function InhandPlaneOperator:playCard(playerType, plane)
	-- if not tag then
	-- 	--todo
	-- 	tag = NEW_CARD_TAG
	-- end

	-- local card = plane:getChildByTag(tag)

	-- if not card then
	-- 	--todo
	-- 	return
	-- end

	-- self:showCards(playerType, plane)

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		selectedTag = 99
	end
end

-- function InhandPlaneOperator:showTingCards(plane, cards, tingSeq)
-- 	plane:removeAllChildren()

-- 	selectedTag = 99

-- 	local oriX = 0
-- 	local oriY = plane:getSize().height / 2

-- 		for i=1,table.getn(cards) do
-- 			local data = cards[i]

-- 			local isTing = false

-- 			for k,v in pairs(tingSeq) do
-- 				if data == v.card then
-- 					--todo
-- 					isTing = true
-- 					break
-- 				end
-- 			end

-- 			local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data)
-- 			card:setScale(card:getScale() * 1.1)
-- 			card:setPosition(cc.p(oriX + card:getSize().width * card:getScale() / 2, card:getSize().height * card:getScale() / 2))
-- 			card:setTag(i)

-- 			if isTing then
-- 				--todo
-- 				card:setTouchEnabled(true)

-- 				card:addTouchEventListener(function(sender, event)

				

-- 				if event == TOUCH_EVENT_ENDED then
-- 					--todo
-- 					----print("card value")
-- 					--dump(sender.m_value, "card value") 
-- 					--dump(sender:getAnchorPoint())

					
-- 					if selectedTag == sender:getTag() then
-- 						    --出牌
-- 						    -- CSMJ_CONTROLLER:hideTingHuPlane()
-- 						 --    for k,v in pairs(tingSeq) do
-- 							-- 	if v.card == sender.m_value then
-- 							-- 		--todo
-- 							-- 		local tingHuCards = v.tingHuCards
-- 							-- 		CSMJ_CONTROLLER:showTingHuPlane(tingHuCards)

-- 							-- 		CSMJ_CONTROLLER:requestLiang(tingHuCards)
-- 							-- 		CSMJ_CONTROLLER:playCard(sender.m_value)	
-- 							-- 		break
-- 							-- 	end
-- 							-- end
-- 							--dump(sender.m_value, "liang card test")
-- 							CSMJ_CONTROLLER:requestLiang(sender.m_value)
-- 							-- CSMJ_CONTROLLER:playCard(sender.m_value)	
							
-- 						else
-- 							self:cancelSelectingCard(plane)

-- 							local p = sender:getPosition()

-- 							sender:setScale(1.2)
-- 							local offsetX = 0.1 * sender:getSize().width

-- 							sender:setPosition(cc.p(p.x + offsetX / 2, p.y + 30))

-- 							local tag = sender:getTag()
-- 							selectedTag = tag
-- 							tag = tag + 1
-- 							local nextCard = plane:getChildByTag(tag)
-- 							while nextCard do
-- 								--todo
-- 								nextCard:setPosition(cc.p(nextCard:getPosition().x + offsetX, nextCard:getPosition().y))

-- 								tag = tag + 1
-- 								nextCard = plane:getChildByTag(tag)
-- 							end

-- 							for k,v in pairs(tingSeq) do
-- 								if v.card == sender.m_value then
-- 									--todo
-- 									local tingHuCards = v.tingHuCards
-- 									CSMJ_CONTROLLER:showTingHuPlane(CARD_PLAYERTYPE_MY, tingHuCards)

-- 									break
-- 								end
-- 							end
-- 						end
-- 				end

-- 				end)
-- 			else
-- 				card:setTouchEnabled(false)
-- 				card:setColor(cc.c3b(150, 150, 150))
-- 			end

-- 			card:setTag(i)

-- 			plane:addChild(card)

-- 			oriX = oriX + card:getSize().width * card:getScale()
-- 		end

-- 		local width = oriX
-- 		plane:setSize(cc.size(width, plane:getSize().height))
-- end

function InhandPlaneOperator:showCard4QiShouHu(playerType, plane, cardDatas, _liangCards)
	dump(_liangCards, "-------------   liangCards -=++++++++++++++ ")

	local seatId = CSMJ_SEAT_TABLE_BY_TYPE[playerType .. ""]
	CSMJ_GAMEINFO_TABLE[seatId .. ""].liangCards = _liangCards

	local cardsTemp = {}

	local cardCountTb = {}

	local liangCardsCount = {}
	
	for _, c in pairs(_liangCards) do
		if liangCardsCount[c] == nil then
			liangCardsCount[c] = 0
		end
		liangCardsCount[c] = liangCardsCount[c] + 1
	end

	dump(liangCardsCount, "----- @@@@  InhandPlaneOperator:showCard4QiShouHu")

	local anCards = {}
	
	local showCards = {}

	local liangCounter = 0
	for idx, c in pairs(cardDatas) do
		if playerType == CARD_PLAYERTYPE_MY then
			if liangCardsCount[c] ~= nil and liangCardsCount[c] > 0 then
				cardsTemp[idx] = c + 100
				liangCardsCount[c] = liangCardsCount[c] - 1

				local cardData = D3_CARDDATA:new(c, 1, CARDNODE_TYPE_NORMAL)
				table.insert(showCards, cardData)
			else
				cardsTemp[idx] = c

				local cardData = D3_CARDDATA:new(c, 1, CARDNODE_TYPE_NORMAL)
				table.insert(anCards, cardData)
			end
		else
			if liangCardsCount[c] ~= nil and liangCardsCount[c] > 0 then
				cardsTemp[idx] = c
				liangCardsCount[c] = liangCardsCount[c] - 1

				local cardData = D3_CARDDATA:new(c, 1, CARDNODE_TYPE_NORMAL)
				table.insert(showCards, cardData)
			else
				cardsTemp[idx] = -1

				local cardData = D3_CARDDATA:new(c, 1, CARDNODE_TYPE_NORMAL)
				table.insert(anCards, cardData)
			end
		end

		if c == 0 and _liangCards[idx] ~= nil then
			cardsTemp[idx] = _liangCards[idx]
			local cardData = D3_CARDDATA:new(c, 1, CARDNODE_TYPE_NORMAL)
			table.insert(showCards, cardData)
		end
	end

	dump(cardsTemp, "----- @@@@  InhandPlaneOperator:showCard4QiShouHu")
	dump(showCards, "----- @@@@  InhandPlaneOperator:showCard4QiShouHu")

	table.sort(cardsTemp)

	if playerType ~= CARD_PLAYERTYPE_MY then
		--todo
		showCards = {}
		anCards = {}

		for i,v in ipairs(cardsTemp) do
			if v == -1 then
				--todo
				local cardData = D3_CARDDATA:new(0, 1, CARDNODE_TYPE_NORMAL)
				table.insert(anCards, cardData)
			else
				local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)
				table.insert(showCards, cardData)
			end
		end
	end

	D3_OPERATOR:showCardsForAll(playerType, plane, anCards, showCards)
end

return InhandPlaneOperator