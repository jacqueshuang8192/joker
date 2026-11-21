
local Card = require("mhxl_majiang.card.card")
local inhandPlaneOperator = require("mhxl_majiang.operator.InhandPlaneOperator")
local lefthandPlaneOperator = require("mhxl_majiang.operator.LefthandPlaneOperator")
local controlPlaneOperator = require("mhxl_majiang.operator.ControlPlaneOperator")
local outhandPlaneOperator = require("mhxl_majiang.operator.OuthandPlaneOperator")
local userInfoPlaneOperator = require("mhxl_majiang.operator.UserInfoPlaneOperator")
local jiapiaoPlaneOperator = require("mhxl_majiang.operator.JiapiaoPlaneOperator")

local cardUtils = require("mhxl_majiang.utils.cardUtils")

local PlayerPlaneOperator = class("PlayerPlaneOperator")

local CHILD_NAME_INHANDPLANE = "inhand_plane"
local CHILD_NAME_LEFTHANDPLANE = "lefthand_plane"
local CHILD_NAME_OUTHANDPLANE = "outhand_plane"
local CHILD_NAME_CONTROL_PLANE = "control_plane"
local CHILD_NAME_CONTROL_IMG = "control_img"
local CHILD_NAME_PLAYERINFO_PLANE = "player_plane"
local CHILD_NAME_LG_PLANE = "lg_plane"
local CHILD_NAME_TING_HU_PLANE = "ting_hu_plane"

local CHILD_NAME_JIAPIAO_PLANE = "jiapiao_plane"
local CHILD_NAME_PIAO_IMG = "piao_img"

local CHILD_NAME_PIAO_PLANE = "piao_plane"
local CHILD_NAME_PIAO_LB = "piao_lb"

local CHILD_NAME_CARD_BX = "card_bx"

local CHILD_NAME_HUA_PLANE = "hua_plane"

local CHILD_NAME_CHANGE_COIN_LB = "change_score_lb"

local CHILD_NAME_CHUTONG_PLANE = "chutong_plane"

function PlayerPlaneOperator:init(playerType, plane)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)
	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)
	local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)
	local controlImg = plane:getChildByName(CHILD_NAME_CONTROL_IMG)
	local userInfoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
	local lgPlane = plane:getChildByName(CHILD_NAME_LG_PLANE)
	local tingHuPlane = plane:getChildByName(CHILD_NAME_TING_HU_PLANE)

	local card_bx = plane:getChildByName(CHILD_NAME_CARD_BX)

	local piao_plane = plane:getChildByName(CHILD_NAME_PIAO_PLANE)
	local jiapiao_plane = plane:getChildByName(CHILD_NAME_JIAPIAO_PLANE)
	local piao_img = plane:getChildByName(CHILD_NAME_PIAO_IMG)
	local hua_plane = plane:getChildByName(CHILD_NAME_HUA_PLANE)

	local changeCoin_lb = plane:getChildByName(CHILD_NAME_CHANGE_COIN_LB)

	if piao_img then
		--todo
		piao_img:setVisible(false)
	end

	if piao_plane then
		--todo
		piao_plane:setVisible(false)
	end
	
	if jiapiao_plane then
		--todo
		jiapiao_plane:setVisible(false)

		jiapiaoPlaneOperator:init(jiapiao_plane)
	end
	
	if card_bx then
		--todo
		card_bx:setVisible(false)
	end

	if hua_plane then
		hua_plane:setVisible(false)
	end

	if changeCoin_lb then
		--todo
		changeCoin_lb:setVisible(false)
	end

	local chutong_plane = plane:getChildByName(CHILD_NAME_CHUTONG_PLANE)
	if chutong_plane then
		--todo
		chutong_plane:setVisible(false)
	end

	inhandPlaneOperator:init(playerType, inhandPlane)
	lefthandPlaneOperator:init(playerType, lefthandPlane)
	outhandPlaneOperator:init(playerType, outhandPlane)
	controlPlaneOperator:init(playerType, controlImg, controlPlane, lgPlane, tingHuPlane)
	userInfoPlaneOperator:init(userInfoPlane)
	
	D3_OPERATOR:init(nil, playerType, inhandPlane, outhandPlane)
end


function PlayerPlaneOperator:clearGameDatas(playerType, plane)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)
	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)
	local userInfoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
	local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)
	local lgPlane = plane:getChildByName(CHILD_NAME_LG_PLANE)
	local tingHuPlane = plane:getChildByName(CHILD_NAME_TING_HU_PLANE)
	local piao_plane = plane:getChildByName(CHILD_NAME_PIAO_PLANE)
	local jiapiao_plane = plane:getChildByName(CHILD_NAME_JIAPIAO_PLANE)
	local piao_img = plane:getChildByName(CHILD_NAME_PIAO_IMG)
	local card_bx = plane:getChildByName(CHILD_NAME_CARD_BX)
	local hua_plane = plane:getChildByName(CHILD_NAME_HUA_PLANE)
	print("=======playerType=====1==")
	if piao_img then
		--todo
		print("=======playerType=====2==")
		piao_img:setVisible(false)
	end

	-- if piao_plane then
	-- 	--todo
	-- 	piao_plane:setVisible(false)
	-- end
	
	if jiapiao_plane then
		--todo
		print("=======playerType=====3==")
		jiapiao_plane:setVisible(false)
	end

	if card_bx then
		--todo
		print("=======playerType=====4==")
		card_bx:setVisible(false)
	end

	if hua_plane then
		print("=======playerType=====5==")
		hua_plane:removeAllChildren()
		hua_plane:setVisible(false)
	end

	local chutong_plane = plane:getChildByName(CHILD_NAME_CHUTONG_PLANE)
	if chutong_plane then
		--todo
		print("=======playerType=====6==")
		chutong_plane:setVisible(false)
	end

	inhandPlaneOperator:init(playerType, inhandPlane)
	lefthandPlaneOperator:init(playerType, lefthandPlane)
	outhandPlaneOperator:init(playerType, outhandPlane)
	controlPlaneOperator:clearGameDatas(controlPlane, lgPlane, tingHuPlane)
	userInfoPlaneOperator:clearGameDatas(userInfoPlane)

	D3_OPERATOR:clearGameDatas(playerType, inhandPlane, outhandPlane)
end

function PlayerPlaneOperator:revertOutCardPosition()
	inhandPlaneOperator:revertOutCardPosition()
end

function PlayerPlaneOperator:reLocate(playerType, plane)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		local x = (plane:getSize().width - lefthandPlane:getSize().width - inhandPlane:getSize().width) / 2 + lefthandPlane:getSize().width

		inhandPlane:setPosition(cc.p(x, inhandPlane:getPosition().y))

		local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)
		
		local size = inhandPlane:getSize()
		local position = inhandPlane:getPosition()

		local x = position.x + size.width - 75 - controlPlane:getSize().width

		controlPlane:setPosition(cc.p(x, controlPlane:getPosition().y))
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		local y = plane:getSize().height - lefthandPlane:getSize().height - (plane:getSize().height - lefthandPlane:getSize().height - inhandPlane:getSize().height) / 2

		inhandPlane:setPosition(cc.p(inhandPlane:getPosition().x, y))
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		local y = (plane:getSize().height - lefthandPlane:getSize().height - inhandPlane:getSize().height) / 2 + lefthandPlane:getSize().height

		inhandPlane:setPosition(cc.p(inhandPlane:getPosition().x, y))

	elseif playerType == CARD_PLAYERTYPE_TOP then
		local x = plane:getSize().width - lefthandPlane:getSize().width - (plane:getSize().width - lefthandPlane:getSize().width - inhandPlane:getSize().width - 170) / 2

		inhandPlane:setPosition(cc.p(x, inhandPlane:getPosition().y))
	end
end

--add by zzy 2019-8-5 设置是否焖牌
function PlayerPlaneOperator:setMySlefCardIsMenPai(playerType,plane,isMenPai)
	print("======isMenPai=======",isMenPai)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	local tempAllChildren = inhandPlane:getChildren()
	dump(tempAllChildren)
	for k,v in pairs(tempAllChildren) do
		v:setTouchEnabled(isMenPai)
		if isMenPai then
			v:setColor(cc.c3b(140, 140, 140))
		else
			v:setColor(cc.c3b(255, 255, 255))
		end
		
	end
end

--获取所有牌得node
function PlayerPlaneOperator:getAllTingCardNode( playerType,plane )
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	dump(inhandPlane,"===inhandPlane===")
	local tempAllChildren = inhandPlane:getChildren()
	XLMH_MY_CARD_NODE = {}
	for k,v in pairs(tempAllChildren) do
		table.insert(XLMH_MY_CARD_NODE,v)
	end
	return XLMH_MY_CARD_NODE
end

function PlayerPlaneOperator:showCards(playerType, plane)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	local seatId = XLMH_SEAT_TABLE_BY_TYPE[playerType .. ""]

	local cards = XLMH_GAMEINFO_TABLE[seatId .. ""].hand
	local tingFlag = XLMH_GAMEINFO_TABLE[seatId .. ""].ting
	local anke = XLMH_GAMEINFO_TABLE[seatId .. ""].anke
	local liangCards = XLMH_GAMEINFO_TABLE[seatId .. ""].liangCards

	-- if tingFlag ~= 1 or XLMH_ROOM.isBufenLiang == 1 then
	if tingFlag ~= 1 then
		--todo
		inhandPlaneOperator:showCards(playerType, inhandPlane, cards, tingFlag)
	else
		inhandPlaneOperator:showCardsForAll(playerType, inhandPlane, cards, anke, liangCards)
	end
	

	-- self:reLocate(playerType, plane)
end

function PlayerPlaneOperator:showControlPlane(plane, controlType)
	local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)

	if controlPlane then
		--todo

		dump(controlType, "controlType test")
		controlPlaneOperator:showPlane(controlPlane, controlType)

		local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

		if inhandPlane then
			
			--todo
			local size = inhandPlane:getSize()
			local position = inhandPlane:getPosition()
            
			local x = position.x + size.width - 75 - controlPlane:getSize().width
			print("========if inhandPlane then======位置移动乐啊！！！==x===",x)
			if x<0 then  
				print("=======6666666666666========xx=1280=====")
				x=1280  
			end
            
			controlPlane:setPosition(cc.p(1280, controlPlane:getPosition().y))
			            
			local moveto = cc.MoveTo:create(0.2,cc.p(x,controlPlane:getPosition().y))

		    controlPlane:runAction(moveto)
		end
	end
end

function PlayerPlaneOperator:hideControlPlane(plane)
	local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)

	if controlPlane then
		--todo
		controlPlane:setVisible(false)
	end
end

function PlayerPlaneOperator:cancelSelectingCard(plane)
	-- local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	-- if inhandPlane then
	-- 	--todo
	-- 	inhandPlaneOperator:cancelSelectingCard(inhandPlane)
	-- end
end

function PlayerPlaneOperator:getNewCard(playerType, plane, value)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	if inhandPlane then
		--todo
		inhandPlaneOperator:getNewCard(playerType, inhandPlane, value)
	end
end

function PlayerPlaneOperator:removeCard_ZIMO_MENHU( plane )
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	D3_OPERATOR:removeCard_ZIMO_MENHU(inhandPlane)
end

function PlayerPlaneOperator:playCard(playerType, plane, tag, value)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)

	local  cardData = D3_CARDDATA:new(value, 1, CARDNODE_TYPE_NORMAL)

	if value == XLMH_LAIZI then
		cardData = D3_CARDDATA:new(value, 0, CARDNODE_TYPE_LAIZI)
	end
	if playerType == CARD_PLAYERTYPE_MY then
		local oriCards = XLMH_GAMEINFO_TABLE[CARD_PLAYERTYPE_MY .. ""].hand
		local count = table.getn(oriCards)
		dump(count,"count   oriCards")
		--for i = 1, count do
		--	local cardNode =inhandPlane:getChildByTag(i)
		--	if cardNode then
		--		dump(cardNode.m_value,"success 313")
		--	end
        --
		--end
		local children = inhandPlane:getChildren()
		for i1,v1 in ipairs(children) do
			if v1:getTag() >0 then
				v1:setColor(cc.c3b(255, 255, 255))
				v1:setTouchEnabled(false)
			end
		end
	end
    D3_OPERATOR:playCard(playerType, inhandPlane, outhandPlane, cardData)
end

function PlayerPlaneOperator:showImgAnim(plane,controlType)
	local controlImg = plane:getChildByName(CHILD_NAME_CONTROL_IMG)
	controlPlaneOperator:showImgAnim(controlImg, controlType)
end

function PlayerPlaneOperator:control(playerType, plane, progCards, controlType, removeCards, fromPlayerType,value)
	local controlImg = plane:getChildByName(CHILD_NAME_CONTROL_IMG)
	
	if bit.band(CONTROL_TYPE_TING,controlType) > 0 then
		return 
	end

	if bit.band(CONTROL_TYPE_HU, controlType) > 0 then
		--todo
		return
	end

	if bit.band(GANG_TYPE_HUA, controlType) > 0 then
		--todo
		return
	end
	if bit.band(HU_TYPE_MEN_HU, controlType) > 0 then
		--todo
		return
	end
	controlPlaneOperator:showImage(controlImg, controlType)
	
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	local indexType = self:getPlayerIndex(playerType,fromPlayerType)
	local progCardDatas = {}
	dump(value,"value--------555--------")
	for i,v in ipairs(progCards) do
		--local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)
		local cardData
		if controlType == GANG_TYPE_BU or controlType == GANG_TYPE_PG then
			if indexType ==2 and i == 4 then
				cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL,nil,2)
			elseif indexType == i and indexType ~=2 then
				cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL,nil,2)
			else
				cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)
			end
		elseif bit.band(controlType, CONTROL_TYPE_CHI) > 0 then
			if v == value then
				cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL,nil,2)
			else
				cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)
			end
		elseif  controlType ~= GANG_TYPE_AN then
			if indexType == i then
				cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL,nil,2)
			else
				cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)
			end
		else
			cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)
		end
		table.insert(progCardDatas, cardData)
	end

	dump(progCardDatas,"========progCardDatas========")
	print("====playerType========",playerType)

	D3_OPERATOR:control(playerType, inhandPlane, progCardDatas, controlType, removeCards, nil, false)
	--if bit.band(controlType, CONTROL_TYPE_CHI) > 0 then
	--	local valueLast;
	--	if bit.band(controlType, CHI_TYPE_RIGHT)>0 then
	--		valueLast = value - 3
	--	elseif bit.band(controlType, CHI_TYPE_LEFT)>0 then
	--		valueLast = value + 3
	--	else
	--		valueLast = 0;
	--	end
	--	local children = inhandPlane:getChildren()
	--	dump(value,"children")
	--	if playerType == CARD_PLAYERTYPE_MY then
	--		for i1,v1 in ipairs(children) do
	--			dump(v1.m_value,"v1.m_value")
	--			if value == v1.m_value and v1:getTag()>0 then
	--				dump("success 313")
	--				v1:setColor(cc.c3b(140, 140, 140))
	--				v1:setTouchEnabled(true)
	--			end
	--			if valueLast == v1.m_value  and v1:getTag()>0 then
	--				dump("success 314")
	--				v1:setColor(cc.c3b(140, 140, 140))
	--				v1:setTouchEnabled(true)
	--			end
	--		end
	--	end
	--end
end
function PlayerPlaneOperator:getPlayerIndex(playerType,fromplayerType)
	local indexType=1
	if tonumber(playerType) - tonumber(fromplayerType) >0 then
		indexType=1
		local index = tonumber(playerType) - tonumber(fromplayerType)
		if index == 1 and playerType == 4 then
			indexType=1
		end
		if index == 2 and playerType == 4 then
			indexType=3
		end
		if index == 3 and playerType == 4 then
			indexType=2
		end
		if index == 1 and playerType == 3 then
			indexType=2
		end
		if index == 2 and playerType == 3 then
			indexType=1
		end
		if index == 1 and playerType == 2 then
			indexType=3
		end
	else
		local index = tonumber(playerType) - tonumber(fromplayerType)
		if index == -1 and playerType == 1 then
			indexType=1
		end
		if index == -2  and playerType == 1 then
			indexType=3
		end
		if index == -3 and playerType == 1 then
			indexType=2
		end
		if index == -1 and playerType == 2 then
			indexType=2
		end
		if index == -2 and playerType == 2 then
			indexType=1
		end
		if index == -1 and playerType == 3 then
			indexType=3
		end
	end
	return indexType
end
function PlayerPlaneOperator:showPlayerInfo(userInfo, plane)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
	userInfoPlaneOperator:showInfo(userInfo, infoPlane)

	return infoPlane
end

function PlayerPlaneOperator:showZhuang(plane)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)

	userInfoPlaneOperator:showZhuang(true, infoPlane)
end

function PlayerPlaneOperator:redrawGameInfo(playerType, plane, data)
	local seatId = XLMH_SEAT_TABLE_BY_TYPE[playerType .. ""]

	local progCards = {}

	if data.gCount > 0 then
		--todo
		local controlCards = data.gCards
		for i=1,data.gCount do
			local controlCard = controlCards[i]
			local gCard = {}
			gCard.cards = {}
			local gType
			if controlCard.isAg > 0 then
				--todo
				gType = GANG_TYPE_AN
			else
				gType = GANG_TYPE_PG
			end

			gCard.type = gType
			gCard.fromPlayerType = cardUtils:getPlayerType(controlCard.targetSeatId)
			local indexType = self:getPlayerIndex(playerType,gCard.fromPlayerType)
			gCard.fromPlayerType =nil
			for i=1,4 do
				local gData
				if gType ~= GANG_TYPE_AN then
					if indexType ==2 and i == 4 then
						gData = D3_CARDDATA:new(controlCard.card, 1, CARDNODE_TYPE_NORMAL,nil,2)
					elseif indexType == i and indexType ~=2 then
						gData = D3_CARDDATA:new(controlCard.card, 1, CARDNODE_TYPE_NORMAL,nil,2)
					else
						gData = D3_CARDDATA:new(controlCard.card, 1, CARDNODE_TYPE_NORMAL)
					end
				else
					gData = D3_CARDDATA:new(controlCard.card, 1, CARDNODE_TYPE_NORMAL)
				end

				table.insert(gCard.cards, gData)
			end

			table.insert(progCards, gCard)
		end
	end

	if data.pCount > 0 then
		--todo
		local controlCards = data.pCards
		for i=1,data.pCount do
			local controlCard = controlCards[i].card
			local pCard = {}
			pCard.cards = {}
			pCard.type = CONTROL_TYPE_PENG
			pCard.fromPlayerType = cardUtils:getPlayerType(controlCards[i].targetSeatId)
			local indexType = self:getPlayerIndex(playerType,pCard.fromPlayerType)
			pCard.fromPlayerType =nil
			for i=1,3 do
				if i ==indexType then
					table.insert(pCard.cards, D3_CARDDATA:new(controlCard, 1, CARDNODE_TYPE_NORMAL,nil,2))
				else
					table.insert(pCard.cards, D3_CARDDATA:new(controlCard, 1, CARDNODE_TYPE_NORMAL))
				end

			end

			table.insert(progCards, pCard)
		end
	end

	local p = nil
	local cs = nil
	for i=1,data.cCount do
		if i % 3 == 1 then
			--todo
			p = {}
			p.type = CONTROL_TYPE_CHI
			cs = {}
			p.cards = cs
			p.fromPlayerType = cardUtils:getPlayerType(data.cCards[i].targetSeatId)
			p.fromPlayerType =nil
			table.insert(cs, D3_CARDDATA:new(data.cCards[i].card, 1, CARDNODE_TYPE_NORMAL))
		elseif i % 3 == 0 then
			table.insert(cs, D3_CARDDATA:new(data.cCards[i].card, 1, CARDNODE_TYPE_NORMAL))

			table.insert(progCards, p)
		else
			table.insert(cs, D3_CARDDATA:new(data.cCards[i].card, 1, CARDNODE_TYPE_NORMAL))
		end
	end

	local outCards = {}

	for i,v in pairs(data.outCards) do
		local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)
		--兼容了广东的出牌数组
		table.insert(outCards, cardData)
	end
	
	local cardsSeq = {}
	local laiziSeq = {}
	--癞子放到左侧
	for k,v in pairs(XLMH_GAMEINFO_TABLE[seatId .. ""].hand) do
        if v == XLMH_LAIZI then
			local cardData = D3_CARDDATA:new(v, 0, CARDNODE_TYPE_LAIZI)

			table.insert(laiziSeq, 1, cardData)
		else
			local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)

			table.insert(cardsSeq, cardData)
		end
	end

	for i,v in ipairs(laiziSeq) do
		table.insert(cardsSeq, 1,v)
	end


	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)

	D3_OPERATOR:redraw(playerType, inhandPlane, outhandPlane, progCards, cardsSeq, outCards, false)

end

function PlayerPlaneOperator:showComponentSelectBox(plane, outCardParam)
	local lgPlane = plane:getChildByName(CHILD_NAME_LG_PLANE)

	if lgPlane then
		--todo
		controlPlaneOperator:showComponentSelectBox(lgPlane, outCardParam)

		local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

		local size = inhandPlane:getSize()
		local position = inhandPlane:getPosition()

		local x = position.x + size.width - 75 - lgPlane:getSize().width
        
        if x<0 then  x=1280  end

		lgPlane:setPosition(cc.p(1280, lgPlane:getPosition().y))
		local moveto = cc.MoveTo:create(0.2,cc.p(x,lgPlane:getPosition().y))
		lgPlane:runAction(moveto)
	end
end

function PlayerPlaneOperator:showTingCards(plane, tingSeq)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	local seatId = XLMH_MY_USERINFO.seat_id

	local cards = XLMH_GAMEINFO_TABLE[seatId .. ""].hand

	inhandPlaneOperator:showTingCards(inhandPlane, cards, tingSeq)

end

function PlayerPlaneOperator:removeLatestOutCard(plane, card)
	local outPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)

	if outPlane then
		--todo
		return outhandPlaneOperator:removeLatestOutCard(outPlane, card)
	end

	return false
end

function PlayerPlaneOperator:showLgSelectBox(plane, lgCards)
	local lgPlane = plane:getChildByName(CHILD_NAME_LG_PLANE)

	if lgPlane then
		--todo
		controlPlaneOperator:showLgSelectBox(lgPlane, lgCards)

		local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

		local size = inhandPlane:getSize()
		local position = inhandPlane:getPosition()

		local x = position.x + size.width - 75 - lgPlane:getSize().width
         
        if x<0 then  x=1280  end
        
		lgPlane:setPosition(cc.p(1280, lgPlane:getPosition().y))
		local moveto = cc.MoveTo:create(0.2,cc.p(x,lgPlane:getPosition().y))
		lgPlane:runAction(moveto)
	end
end

function PlayerPlaneOperator:showTingHuPlane(playerType, plane, tingHuCards)
	local tingHuPlane = plane:getChildByName(CHILD_NAME_TING_HU_PLANE)

	if tingHuPlane then
		--todo
		controlPlaneOperator:showTingHuPlane(playerType, tingHuPlane, tingHuCards)
	end
end

function PlayerPlaneOperator:hideTingHuPlane(plane)
	local tingHuPlane = plane:getChildByName(CHILD_NAME_TING_HU_PLANE)
	-- local tingFlag = XLMH_GAMEINFO_TABLE[XLMH_MY_USERINFO.seat_id .. ""].ting
	-- if tingHuPlane and tingFlag ~= 1 then
	if tingHuPlane then
		--todo
		tingHuPlane:setVisible(false)
	end
end

function PlayerPlaneOperator:showCardsForHu(playerType, plane, cardDatas, huCard)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	if inhandPlane then
		--todo

		local showDatas = {}

		for i,v in ipairs(cardDatas) do
			table.insert(showDatas, v)
		end

		for i,v in ipairs(showDatas) do
			if v == huCard then
				--todo
				table.remove(showDatas, i)
				break
			end
		end

		inhandPlaneOperator:showCardsForAll(playerType, inhandPlane, showDatas, {})

		if huCard > 0 then
			--todo
			inhandPlaneOperator:showHuCard(playerType, inhandPlane, huCard)
		end
		
	end
end

function PlayerPlaneOperator:getHeadNode(plane)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)

	return userInfoPlaneOperator:getHeadNode(infoPlane)
end

function PlayerPlaneOperator:showNetworkImg(plane, flag)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)

	userInfoPlaneOperator:showNetworkImg(infoPlane, flag)
end

function PlayerPlaneOperator:showJiapiaoPlane(plane, flag)
	local jiapiaoPlane = plane:getChildByName(CHILD_NAME_JIAPIAO_PLANE)

	jiapiaoPlane:setVisible(flag)
end

function PlayerPlaneOperator:showPiaoImg(plane, piao, flag)
	local piaoImg = plane:getChildByName(CHILD_NAME_PIAO_IMG)

	piaoImg:setVisible(flag)

	if flag then
		--todo

		local imgPath = "majong_bupiao_bt_p.png"
		if piao == 1 then
			imgPath = "majong_jiayipiao_bt_p.png"
		elseif piao == 2 then
			imgPath = "majong_jiaerpiao_bt_p.png"
		end

		piaoImg:loadTexture("mhxl_majiang/image/" .. imgPath)
	end
end

function PlayerPlaneOperator:showPiaoPlane(plane, piao, flag)
	local piaoPlane = plane:getChildByName(CHILD_NAME_PIAO_PLANE)
	local piaoLb = piaoPlane:getChildByName(CHILD_NAME_PIAO_LB)

	piaoPlane:setVisible(flag)

	if flag then
		--todo

		local txt = piao .. "点"

		piaoLb:setString(txt)
	end
end


function PlayerPlaneOperator:showCoinChange(plane,value)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
	userInfoPlaneOperator:showCoinChange(infoPlane,value )
end

function PlayerPlaneOperator:beginPlayCard(plane,flag)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
    userInfoPlaneOperator:beginPlayCard(infoPlane,flag)
end

function PlayerPlaneOperator:jiShow(type,card,plane)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
    userInfoPlaneOperator:jiShow(type,card,infoPlane)
end

--补花动画
function PlayerPlaneOperator:buHua(plane)
    local controlImg = plane:getChildByName(CHILD_NAME_CONTROL_IMG)
    local controlType = CONTROL_TYPE_BUHUA
	controlPlaneOperator:showImage(controlImg, controlType)
end

function PlayerPlaneOperator:playHuaCard(playerType,plane,value)
    local huaPlane = plane:getChildByName(CHILD_NAME_HUA_PLANE)

    if huaPlane then
    	huaPlane:setVisible(true)
    	outhandPlaneOperator:playHuaCard(playerType,huaPlane,value)
    end
     
    local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
    if inhandPlane then
		self:showCards(playerType, plane)
	end

	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)
	if inhandPlane then
		local cardData = D3_CARDDATA:new(value, 1, CARDNODE_TYPE_NORMAL)
		D3_OPERATOR:playCardForOuthand( playerType, outhandPlane, cardData, cc.c3b(180, 120, 120) )
	end
end

function PlayerPlaneOperator:changeCoin(plane, value)
	local lb = plane:getChildByName(CHILD_NAME_CHANGE_COIN_LB)

	if lb then
		lb:stopAllActions()

		lb:setVisible(true)
		--todo
		local fontColor
		if value > 0 then
			--todo
			fontColor = cc.c3b(0, 255, 0)

			lb:setString("+" .. value)
		else
			fontColor = cc.c3b(255, 0, 0)

			lb:setString(value)
		end

		lb:setColor(fontColor)

		local seqAc = cc.Sequence:create(cc.DelayTime:create(3), cc.Hide:create())

		lb:runAction(seqAc)
	end
end

function PlayerPlaneOperator:showChutong(plane, card)
	-- body
	local chutong_plane = plane:getChildByName(CHILD_NAME_CHUTONG_PLANE)
	if chutong_plane then
		--todo
		if card > 0 then
			--todo
			chutong_plane:setVisible(true)

			chutong_plane:removeAllChildren()

			local node = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, card)

			local scale = chutong_plane:getContentSize().width / node:getContentSize().width

			node:setScale(scale)

			chutong_plane:addChild(node)

			node:setPosition(cc.p(node:getContentSize().width * scale / 2, node:getContentSize().height * scale / 2))

			chutong_plane:setSize(cc.size(node:getContentSize().width * scale, chutong_plane:getSize().height))
		else
			chutong_plane:setVisible(false)
		end
	end
end
function PlayerPlaneOperator:playPanelRes(plane, playerType)

	outhandPlaneOperator:playPanelRes(plane:getChildByName(CHILD_NAME_OUTHANDPLANE),playerType)
end

function PlayerPlaneOperator:hideJiImg(plane)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
	userInfoPlaneOperator:hideJiImg(infoPlane)
end


return PlayerPlaneOperator