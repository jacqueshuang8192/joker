local Card = require(TpackageName..".card.card")
local OuthandPlaneOperator = class("OuthandPlaneOperator")

local FIRST_ROW_COUNT = 5
local ROW_COUNT = 4

local OUT_CARD_SCALE = 1.3     --出牌尺寸的放大倍数
local OUT_CARD_WIDTH_1 = 27 * OUT_CARD_SCALE
local OUT_CARD_HEIGHT_1 = 44 * OUT_CARD_SCALE
local OUT_CARD_SHOW_HEIGHT_1 = 32 * OUT_CARD_SCALE

local OUT_CARD_WIDTH_2 = 35 * OUT_CARD_SCALE
local OUT_CARD_SHOW_WIDTH_2 = 23 * OUT_CARD_SCALE

local OFFSET_Y_WITHIN_CARD_AND_PLANE = 5

-- local Seq
-- local SeqMy
-- local SeqLeft
-- local SeqRight
-- local SeqTop

-- local PositionMy
-- local PositionLeft
-- local PositionRight
-- local PositionTop

-- local timer_ids = {0, 0, 0, 0}

function OuthandPlaneOperator:init(playerType, plane)
	-- local scheduler = cc.Director:getInstance():getScheduler()

	-- for i=1,table.getn(timer_ids) do
	-- 	if timer_ids ~= 0 then
	-- 		--todo
	-- 		scheduler:unscheduleScriptEntry(timer_ids[i])
	-- 	end

	-- 	timer_ids[i] = 0
	-- end
	plane:removeAllChildren()
end



function OuthandPlaneOperator:putCard()
    if not tolua.isnull(GXHCMJ_CURRENT_CARDNODE) then
    	self:action()
    end    
end

function OuthandPlaneOperator:action()
	if  tolua.isnull(GXHCMJ_CURRENT_CARDNODE) then
		return
	end

	local cardCount = self.plane:getChildrenCount()
	local size = GXHCMJ_CURRENT_CARDNODE:getSize()
	local row = 1
	local col = cardCount
	
    if self.playerType == CARD_PLAYERTYPE_MY then

		 if  GXLZ_PLAYER_COUNT==4 or  GXLZ_PLAYER_COUNT==3 then

		   for i=1,ROW_COUNT do
		   		local countThisRow = 10
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 10
		   local x = (col - countThisRow / 2 - 0.5) * OUT_CARD_WIDTH_1 + self.plane:getSize().width / 2
		   local y = self.plane:getSize().height - ((row - 0.5) * OUT_CARD_SHOW_HEIGHT_1 + (OUT_CARD_HEIGHT_1 - OUT_CARD_SHOW_HEIGHT_1) / 2)

			self:Sequence(x,y)
		   
		  elseif GXLZ_PLAYER_COUNT == 2 then

		   for i=1,ROW_COUNT do
		   		local countThisRow = 15
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 15
		   local x = (col - countThisRow / 2 - 0.5) * OUT_CARD_WIDTH_1 + self.plane:getSize().width / 2
		   local y = self.plane:getSize().height - ((row - 0.5) * OUT_CARD_SHOW_HEIGHT_1 + (OUT_CARD_HEIGHT_1 - OUT_CARD_SHOW_HEIGHT_1) / 2)

			self:Sequence(x,y)

		   end --end GXLZ_PLAYER_COUNT

	elseif self.playerType == CARD_PLAYERTYPE_LEFT then

		   for i=1,ROW_COUNT do
		   		local countThisRow = 10
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 10

           local x = (self.plane:getSize().width - OUT_CARD_SCALE*(row - 0.5) * size.width) -OUT_CARD_HEIGHT_1
		   local y = (countThisRow / 2 - col + 0.5) * OUT_CARD_SHOW_WIDTH_2 + self.plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE
		   
           self:Sequence(x,y)

	elseif self.playerType == CARD_PLAYERTYPE_RIGHT then
		   GXHCMJ_CURRENT_CARDNODE:setLocalZOrder(200 - cardCount)
		   for i=1,ROW_COUNT do
		   		local countThisRow = 10
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 10
		   local x = OUT_CARD_SCALE*(row - 0.5) * size.width + OUT_CARD_HEIGHT_1
		   local y = (col - countThisRow / 2 - 0.5) * OUT_CARD_SHOW_WIDTH_2 + self.plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE

		  self:Sequence(x,y)

	elseif self.playerType == CARD_PLAYERTYPE_TOP then
		   GXHCMJ_CURRENT_CARDNODE:setLocalZOrder(200 - cardCount)

		 if GXLZ_PLAYER_COUNT == 4 or GXLZ_PLAYER_COUNT == 3 then

		   for i=1,ROW_COUNT do
		   		local countThisRow = 10
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 10
		   local x = (countThisRow / 2 - col + 0.5) * OUT_CARD_WIDTH_1 + self.plane:getSize().width / 2
		   local y = OUT_CARD_HEIGHT_1 / 2 + (row - 1) * OUT_CARD_SHOW_HEIGHT_1

			self:Sequence(x,y)

		elseif GXLZ_PLAYER_COUNT == 2 then

		   for i=1,ROW_COUNT do
		   		local countThisRow = 15
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 15
		   local x = (countThisRow / 2 - col + 0.5) * OUT_CARD_WIDTH_1 + self.plane:getSize().width / 2
		   local y = OUT_CARD_HEIGHT_1 / 2 + (row - 1) * OUT_CARD_SHOW_HEIGHT_1

		   self:Sequence(x,y)
		end
	end
end

function OuthandPlaneOperator:Sequence(x,y)
	
	local function card_callback()
		GXHCMJ_CARD_POINTER:stopAllActions()

		local worldPoint = GXHCMJ_CURRENT_CARDNODE:convertToWorldSpace(cc.p(0, 0))
		GXHCMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + GXHCMJ_CURRENT_CARDNODE:getSize().width / 2, worldPoint.y + GXHCMJ_CURRENT_CARDNODE:getSize().height + GXHCMJ_CARD_POINTER:getSize().height / 4))
		GXHCMJ_CARD_POINTER:setVisible(true)

		local pointPosition = GXHCMJ_CARD_POINTER:getPosition()

		local seqAcT = cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(pointPosition.x, pointPosition.y + 10)), cc.MoveTo:create(0.5, pointPosition))

		GXHCMJ_CARD_POINTER:runAction(cc.RepeatForever:create(seqAcT))
	end
     
    local delaytime = cc.DelayTime:create(0.5)
    local callbackAc = cc.CallFunc:create(card_callback)
    local sequenceAc = cc.Sequence:create(delaytime,cc.ScaleTo:create(0,1.3),cc.MoveTo:create(0, cc.p(x,y)),callbackAc)

	GXHCMJ_CURRENT_CARDNODE:runAction(sequenceAc)
	
	-- GXHCMJ_CURRENT_CARDNODE:stopAllActions()
	-- local Animation = GXHCMJ_CURRENT_CARDNODE:getAnimation()
	-- Animation:gotoAndPause(0)  

    -- GXHCMJ_CURRENT_CARDNODE:setVisible(true)
	-- local anim = GXHCMJ_CURRENT_CARDNODE:getAnimation()
	-- anim:playWithIndex(0)
	-- toShot:getAnimation():playWithIndex(0, -1, 0) --第一个参数是动画表index 第二个是时间间隔第三个是是否循环
end


function OuthandPlaneOperator:playCard(playerType, cardValue, plane)
	local cardNode = Card:new(playerType, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cardValue)
    self.plane=plane
    self.playerType=playerType
	cardNode:setLocalZOrder(200)
	cardNode:setScale(2.0)

	local cardCount = plane:getChildrenCount()
	local row = 1
	local col = cardCount
	
	local size = cardNode:getSize()

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		cardNode:setPosition(cc.p(plane:getSize().width / 2, size.height))

		-- cardNode:setScale(2.0)		
		plane:addChild(cardNode)

		local function card_callback()  
		   -- local cardCount = plane:getChildrenCount()

		   if GXLZ_PLAYER_COUNT == 4 or GXLZ_PLAYER_COUNT ==3  then
		   for i=1,ROW_COUNT do
		   		local countThisRow = 10
				if col > countThisRow then
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 10
		   local x = (col - countThisRow / 2 - 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
		   local y = plane:getSize().height - ((row - 0.5) * OUT_CARD_SHOW_HEIGHT_1 + (OUT_CARD_HEIGHT_1 - OUT_CARD_SHOW_HEIGHT_1) / 2)

		   -- cardNode:setScale(OUT_CARD_SCALE)
		   -- cardNode:setPosition(cc.p(x, y))
		   PositionMy = cc.p(x, y)

		   elseif 	GXLZ_PLAYER_COUNT == 2	then

		   	for i=1,ROW_COUNT do
		   		local countThisRow = 15
		   		--old countThisRow (i - 1) * 2 + FIRST_ROW_COUNT
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 15
		   local x = (col - countThisRow / 2 - 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
		   local y = plane:getSize().height - ((row - 0.5) * OUT_CARD_SHOW_HEIGHT_1 + (OUT_CARD_HEIGHT_1 - OUT_CARD_SHOW_HEIGHT_1) / 2)

		   -- cardNode:setScale(OUT_CARD_SCALE)
		   -- cardNode:setPosition(cc.p(x, y))
           -- PositionMy = cc.p(x, y)
			--todo
		   end

		   -- local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   -- scheduler:unscheduleScriptEntry(schedulerID)
		end
		-- timer_ids[playerType] = schedulerID
		-- local wait = cc.DelayTime:create(0.6)
		-- local callbackAc = cc.CallFunc:create(card_callback)
		-- local seqAc = cc.Sequence:create(wait, callbackAc)
           
  --       SeqMy = seqAc
		-- cardNode:runAction(seqAc)
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		cardNode:setPosition(cc.p(cardNode:getSize().width, plane:getSize().height / 2))

		-- cardNode:setScale(2.0)	
		plane:addChild(cardNode)

		-- local scheduler = cc.Director:getInstance():getScheduler()  
		-- local schedulerID = nil  
		-- schedulerID = scheduler:scheduleScriptFunc(function()  
		local function card_callback()  
		   -- local cardCount = plane:getChildrenCount()

		   for i=1,ROW_COUNT do
		   		local countThisRow = 10
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 10
		   local x = (plane:getSize().width - OUT_CARD_SCALE*(row - 0.5) * size.width) -OUT_CARD_HEIGHT_1
		   local y = (countThisRow / 2 - col + 0.5) * OUT_CARD_SHOW_WIDTH_2 + plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE
		end
	
	elseif playerType == CARD_PLAYERTYPE_RIGHT then

		cardNode:setPosition(cc.p(plane:getSize().width - size.width, plane:getSize().height / 2))
		-- cardNode:setLocalZOrder(200 - cardCount)
		plane:addChild(cardNode)

		local function card_callback()  	   

		   for i=1,ROW_COUNT do
		   		local countThisRow = 10
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 10
		   local x = OUT_CARD_SCALE*(row - 0.5) * size.width + OUT_CARD_HEIGHT_1
		   local y = (col - countThisRow / 2 - 0.5) * OUT_CARD_SHOW_WIDTH_2 + plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE

		 
		end
		
	elseif playerType == CARD_PLAYERTYPE_TOP then

			cardNode:setPosition(cc.p(plane:getSize().width / 2, plane:getSize().height - size.height))
			-- cardNode:setLocalZOrder(200 - cardCount)
			plane:addChild(cardNode)
		-- local scheduler = cc.Director:getInstance():getScheduler()  
		-- local schedulerID = nil  
		-- schedulerID = scheduler:scheduleScriptFunc(function()  
		local function card_callback()  
		   -- local cardCount = plane:getChildrenCount()


		   if GXLZ_PLAYER_COUNT == 4 or GXLZ_PLAYER_COUNT ==3  then

		   for i=1,ROW_COUNT do
		   		local countThisRow = 10
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 10
		   local x = (countThisRow / 2 - col + 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
		   local y = OUT_CARD_HEIGHT_1 / 2 + (row - 1) * OUT_CARD_SHOW_HEIGHT_1

		   -- cardNode:setScale(OUT_CARD_SCALE)
		   -- PositionTop = cc.p(x, y)
		   -- cardNode:setPosition(cc.p(x, y))

		   elseif GXLZ_PLAYER_COUNT == 2 then

		   for i=1,ROW_COUNT do
		   		local countThisRow = 15
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 15
		   local x = (countThisRow / 2 - col + 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
		   local y = OUT_CARD_HEIGHT_1 / 2 + (row - 1) * OUT_CARD_SHOW_HEIGHT_1

		   -- cardNode:setScale(OUT_CARD_SCALE)
		   -- PositionTop = cc.p(x, y)
           
		  end
		  
		end

		-- local wait = cc.DelayTime:create(0.6)
		-- local callbackAc = cc.CallFunc:create(card_callback)
		-- local seqAc = cc.Sequence:create(wait, callbackAc)
        -- SeqTop = seqAc
		-- cardNode:runAction(seqAc)
	end

	GXHCMJ_CURRENT_CARDNODE = cardNode
	-- Seq = seqAc
end

function OuthandPlaneOperator:redraw(playerType, plane, outCards)

    --3/13号兼容了红中的出牌数组
    local  new_outCards ={}
    for i,v in pairs(outCards) do 
    	if outCards[i].outcardtype == 0 then
    		table.insert(new_outCards,outCards[i].card)
    	end
    end
	--dump(new_outCards,"new_outCards")
	local count = table.getn(new_outCards)
	for i=1,count do
		local cardValue = new_outCards[i]
		local cardNode = Card:new(playerType, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cardValue)
		local size = cardNode:getSize()

		if playerType == CARD_PLAYERTYPE_MY then
			--todo
			local cardCount = i

			local row = 1
			local col = cardCount
			for i=1,ROW_COUNT do
			    local countThisRow = 10
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
			end

			local countThisRow = 10
			local x = (col - countThisRow / 2 - 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
			local y = plane:getSize().height - ((row - 0.5) * OUT_CARD_SHOW_HEIGHT_1 + (OUT_CARD_HEIGHT_1 - OUT_CARD_SHOW_HEIGHT_1) / 2)

			cardNode:setPosition(cc.p(x, y))
			cardNode:setScale(OUT_CARD_SCALE)

			plane:addChild(cardNode)
		elseif playerType == CARD_PLAYERTYPE_LEFT then
			   local cardCount = i

			   local row = 1
			   local col = cardCount
			   for i=1,ROW_COUNT do
			   		local countThisRow = 10
					if col > countThisRow then
						--todo
						row = row + 1
						col = col - countThisRow
					else
						break
					end
			   end

			   local countThisRow = 10 
			   local x = (plane:getSize().width - OUT_CARD_SCALE*(row - 0.5) * size.width) - OUT_CARD_HEIGHT_1
			   local y = (countThisRow / 2 - col + 0.5) * OUT_CARD_SHOW_WIDTH_2 + plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE

			   cardNode:setPosition(cc.p(x, y))
               cardNode:setScale(OUT_CARD_SCALE)           
			   plane:addChild(cardNode)
		elseif playerType == CARD_PLAYERTYPE_RIGHT then

			   local cardCount = i
			   plane:addChild(cardNode)
			   cardNode:setLocalZOrder(200 - cardCount)

			   local row = 1
			   local col = cardCount
			   for i=1,ROW_COUNT do
			   		local countThisRow = 10
					if col > countThisRow then
						--todo
						row = row + 1
						col = col - countThisRow
					else
						break
					end
			   end

			   local countThisRow = 10
			   local x = OUT_CARD_SCALE*(row - 0.5) * size.width + OUT_CARD_HEIGHT_1
			   local y = (col - countThisRow / 2 - 0.5) * OUT_CARD_SHOW_WIDTH_2 + plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE

			   cardNode:setPosition(cc.p(x, y))
               cardNode:setScale(OUT_CARD_SCALE)

			   
		elseif playerType == CARD_PLAYERTYPE_TOP then
			   local cardCount = i
			   plane:addChild(cardNode)
			   cardNode:setLocalZOrder(200 - cardCount)

			   local row = 1
			   local col = cardCount
			   for i=1,ROW_COUNT do
			   		local countThisRow = 10
					if col > countThisRow then
						--todo
						row = row + 1
						col = col - countThisRow
					else
						break
					end
			   end

			   local countThisRow = 10
			   local x = (countThisRow / 2 - col + 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
			   local y = OUT_CARD_HEIGHT_1 / 2 + (row - 1) * OUT_CARD_SHOW_HEIGHT_1

			   cardNode:setPosition(cc.p(x, y))
               cardNode:setScale(OUT_CARD_SCALE)
  
			   
		end
	end
end

function OuthandPlaneOperator:removeLatestOutCard(outPlane, card)
	local cardNodes = outPlane:getChildren()
	local count = table.getn(cardNodes)
	if count > 0 then
		for i=count,1,-1 do
			local node = cardNodes[i]
			if node.m_value == card then
				return node
			end
		end
	end

	return false
end

return OuthandPlaneOperator