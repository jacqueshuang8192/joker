local inhandPlaneOperator = require("jiningmajiangji.operator.InhandPlaneOperator")
local lefthandPlaneOperator = require("jiningmajiangji.operator.LefthandPlaneOperator")
local controlPlaneOperator = require("jiningmajiangji.operator.ControlPlaneOperator")
local outhandPlaneOperator = require("jiningmajiangji.operator.OuthandPlaneOperator")
local userInfoPlaneOperator = require("jiningmajiangji.operator.UserInfoPlaneOperator")
local jiapiaoPlaneOperator = require("jiningmajiangji.operator.JiapiaoPlaneOperator")

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
local CHILD_NAME_CHANGECOINS = "fnt_changeCoins"

local ShowSameCardArray = {}

local newCard = 0

function PlayerPlaneOperator:init(playerType, plane, flag)
	print("zz-playerType",playerType)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)
	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)
	local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)
	local controlImg = plane:getChildByName(CHILD_NAME_CONTROL_IMG)
	local userInfoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
	local lgPlane = plane:getChildByName(CHILD_NAME_LG_PLANE)
	local tingHuPlane = plane:getChildByName(CHILD_NAME_TING_HU_PLANE)

	local piao_plane = plane:getChildByName(CHILD_NAME_PIAO_PLANE)
	local jiapiao_plane = plane:getChildByName(CHILD_NAME_JIAPIAO_PLANE)
	local piao_img = plane:getChildByName(CHILD_NAME_PIAO_IMG)

	local huipai_box = plane:getChildByName("huipai_box")
	local txt_roundResult = plane:getChildByName(CHILD_NAME_CHANGECOINS)

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

	if huipai_box then

		huipai_box:setVisible(false)
	end

	if txt_roundResult then
		txt_roundResult:setVisible(false)
	end

    if not flag then
        inhandPlaneOperator:init(playerType, inhandPlane)
        outhandPlaneOperator:init(playerType, outhandPlane)
    end
	-- inhandPlaneOperator:init(playerType, inhandPlane)
	lefthandPlaneOperator:init(playerType, lefthandPlane)
	-- outhandPlaneOperator:init(playerType, outhandPlane)
	controlPlaneOperator:init(playerType, controlImg, controlPlane, lgPlane, tingHuPlane)
	userInfoPlaneOperator:init(userInfoPlane)
	print("----zz-playerType",playerType)
	D3_OPERATOR:init(ZZMJ_CONTROLLER, playerType, inhandPlane, outhandPlane)
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
	local txt_roundResult = plane:getChildByName(CHILD_NAME_CHANGECOINS)

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
	end

	if huipai_box then

		huipai_box:setVisible(false)
	end

	if txt_roundResult then
		txt_roundResult:setVisible(false)
	end

	inhandPlaneOperator:init(playerType, inhandPlane)
	lefthandPlaneOperator:init(playerType, lefthandPlane)
	outhandPlaneOperator:init(playerType, outhandPlane)
	controlPlaneOperator:clearGameDatas(controlPlane, lgPlane, tingHuPlane)
	userInfoPlaneOperator:clearGameDatas(userInfoPlane)

	D3_OPERATOR:clearGameDatas(playerType, inhandPlane, outhandPlane)
end

function PlayerPlaneOperator:reLocate(playerType, plane)
	-- local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	-- local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)

	-- if playerType == CARD_PLAYERTYPE_MY then
	-- 	--todo
	-- 	local x = (plane:getSize().width - lefthandPlane:getSize().width - inhandPlane:getSize().width) / 2 + lefthandPlane:getSize().width

	-- 	inhandPlane:setPosition(cc.p(x, inhandPlane:getPosition().y))

	-- 	local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)
		
	-- 	local size = inhandPlane:getSize()
	-- 	local position = inhandPlane:getPosition()

	-- 	local x = position.x + size.width - 75 - controlPlane:getSize().width

	-- 	controlPlane:setPosition(cc.p(x, controlPlane:getPosition().y))
	-- elseif playerType == CARD_PLAYERTYPE_LEFT then
	-- 	local y = plane:getSize().height - lefthandPlane:getSize().height - (plane:getSize().height - lefthandPlane:getSize().height - inhandPlane:getSize().height) / 2

	-- 	inhandPlane:setPosition(cc.p(inhandPlane:getPosition().x, y))
	-- elseif playerType == CARD_PLAYERTYPE_RIGHT then
	-- 	local y = (plane:getSize().height - lefthandPlane:getSize().height - inhandPlane:getSize().height) / 2 + lefthandPlane:getSize().height

	-- 	inhandPlane:setPosition(cc.p(inhandPlane:getPosition().x, y))

	-- elseif playerType == CARD_PLAYERTYPE_TOP then
	-- 	local x = plane:getSize().width - lefthandPlane:getSize().width - (plane:getSize().width - lefthandPlane:getSize().width - inhandPlane:getSize().width - 170) / 2

	-- 	inhandPlane:setPosition(cc.p(x, inhandPlane:getPosition().y))
	-- end
end

--显示牌，现在只有开场发牌时起作用
function PlayerPlaneOperator:showCards(playerType, plane,tingSeq)

	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	local seatId = ZZMJ_SEAT_TABLE_BY_TYPE[playerType .. ""]

	local cards = ZZMJ_GAMEINFO_TABLE[seatId .. ""].hand

	dump(playerType, "showCards - playerType")
	dump(cards, "showCards - cards")

	-- local tingFlag = ZZMJ_GAMEINFO_TABLE[seatId .. ""].ting
	-- local anke = ZZMJ_GAMEINFO_TABLE[seatId .. ""].anke

	-- if tingFlag ~= 1 or ZZMJ_ROOM.isBufenLiang == 1 then
	-- 	--todo
	inhandPlaneOperator:showCards(playerType, inhandPlane, cards,tingSeq)
	-- else
	-- 	inhandPlaneOperator:showCardsForAll(playerType, inhandPlane, cards, anke)
	-- end
	

	-- self:reLocate(playerType, plane)
end

function PlayerPlaneOperator:showControlPlane(plane, controlType)
	
	local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)

	if controlPlane then
		--todo
		controlPlaneOperator:showPlane(controlPlane, controlType)

		local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

		if inhandPlane then
			--todo
			local size = inhandPlane:getSize()
			local position = inhandPlane:getPosition()

			local x = position.x + size.width - 75 - controlPlane:getSize().width

			controlPlane:setPosition(cc.p(x, controlPlane:getPosition().y))
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
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	if inhandPlane then
		--todo
		inhandPlaneOperator:cancelSelectingCard(inhandPlane)
	end
end

function PlayerPlaneOperator:getNewCard(playerType, plane, value,tingSeq)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
   
    -- TINGSEQ=tingSeq
    newCard = value
    local cardData = D3_CARDDATA:new(value, 1, CARDNODE_TYPE_NORMAL)
    --if value == ZZMJ_LAIZI then
    --      cardData = D3_CARDDATA:new(value, 0, CARDNODE_TYPE_LAIZI)
    --end
    
	D3_OPERATOR:getNewCard(playerType, inhandPlane, cardData,false)
	-- if inhandPlane then
	-- 	--todo
	-- 	inhandPlaneOperator:getNewCard(playerType, inhandPlane, value,tingSeq)
	-- end
end


--旧打牌
-- function PlayerPlaneOperator:playCard(playerType, plane, tag, value)
-- 	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

-- 	if inhandPlane then
-- 		--todo
-- 		local seatId = ZZMJ_SEAT_TABLE_BY_TYPE[playerType .. ""]
-- 		inhandPlaneOperator:playCard(playerType, inhandPlane)
-- 		self:showCards(playerType, plane)
		
-- 	end

-- 		--todo
-- 		local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)

-- 		if outhandPlane then
-- 			--todo
-- 			outhandPlaneOperator:playCard(playerType, value, outhandPlane)
-- 		end

-- 	self:reLocate(playerType, plane)
-- end


--新打牌
function PlayerPlaneOperator:playCard(playerType, plane, tag, value)---玩牌
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)

	-- if value == ZZMJ_LAIZI then
	-- 	cardData = D3_CARDDATA:new(value, 0, CARDNODE_TYPE_LAIZI)
	-- else
	local  cardData = D3_CARDDATA:new(value, 1, CARDNODE_TYPE_NORMAL)

	-- end
	ZZMJ_CURRENT_CARDNODE = cardData
	dump(ZZMJ_CURRENT_CARDNODE, "ZZMJ_CURRENT_CARDNODEplayCard")
    D3_OPERATOR:playCard(playerType, inhandPlane, outhandPlane, cardData)
end


--旧操作
-- function PlayerPlaneOperator:control(playerType, plane, progCards, controlType,tingSeq,fromplayerType)
-- 	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)
-- 	local controlImg = plane:getChildByName(CHILD_NAME_CONTROL_IMG)

-- 	controlPlaneOperator:showImage(controlImg, controlType)

-- 	if lefthandPlane then
-- 		--todo
-- 		-- if controlType == CONTROL_TYPE_GANG then
-- 		-- 	--todo
-- 		-- 	local cardDatas = {}
-- 		-- 	for i=1,3 do
-- 		-- 		local cardData = {}
-- 		-- 		cardData["value"] = 6

-- 		-- 		table.insert(cardDatas, cardData)
-- 		-- 	end

-- 		-- 	lefthandPlaneOperator:addCards(playerType, lefthandPlane, cardDatas)
-- 		-- end

-- 		lefthandPlaneOperator:addProg(playerType, lefthandPlane, progCards, controlType,fromplayerType)

-- 		self:showCards(playerType, plane, tingSeq)
		
-- 	end

-- 	self:reLocate(playerType, plane)
-- end


function PlayerPlaneOperator:control(playerType, plane, progCards, controlType,tingSeq,removeCards,fromplayerType,reloginFlage)



	-- TINGSEQ=tingSeq
	if playerType==CARD_PLAYERTYPE_MY then
		ZZMJ_GAME_PLANE:getChildByName("my_card_plane"):getChildByName("ting_hu_plane"):setVisible(false)
	end

	local controlImg = plane:getChildByName(CHILD_NAME_CONTROL_IMG)
	controlPlaneOperator:showImage(controlImg, controlType)
	if bit.band(CONTROL_TYPE_HU, controlType) > 0 then
		--todo
		return
	end

	if bit.band(GANG_TYPE_HUA, controlType) > 0 then
		--todo
		return
	end
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	local progCardDatas = {}
	for i,v in pairs(progCards) do
		local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)
		table.insert(progCardDatas, cardData)
	end
    
    
    --重连且补杠且玩家为自己的情况下
   --if reloginFlage== true and (controlType == GANG_TYPE_BU or controlType == GANG_TYPE_AN) and  playerType==CARD_PLAYERTYPE_MY then
	--    local inhandOperator = require("hall.3DMahjongCard.InhandOperator")
	--    if  removeCards[1] == newCard then
	--    	inhandOperator:removeCards(playerType, inhandPlane, removeCards, true)
	--    else
	--    	inhandOperator:removeCards(playerType, inhandPlane, removeCards, false)
	--	end
   --
	--	self:showCards(playerType,plane)
   --
   --     if controlType == GANG_TYPE_AN then
	--		inhandOperator:addCards(playerType, inhandPlane, progCardDatas)
	--		inhandOperator:addGangCard(playerType, inhandPlane, progCardDatas[1], true)
   --     elseif  controlType == GANG_TYPE_BU then
	--   	 	inhandOperator:addGangCard(playerType, inhandPlane, progCardDatas[1], false)
	--	end
	--
	--else
	D3_OPERATOR:control(playerType, inhandPlane, progCardDatas, controlType, removeCards)
	--end
end

function PlayerPlaneOperator:showPlayerInfo(userInfo, plane)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
	return userInfoPlaneOperator:showInfo(userInfo, infoPlane)
end

function PlayerPlaneOperator:showZhuang(plane)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)

	userInfoPlaneOperator:showZhuang(true, infoPlane)
end


--旧重绘
-- function PlayerPlaneOperator:redrawGameInfo(playerType, plane, data)
-- 	local progCards = {}

-- 	if data.gCount > 0 then
-- 		--todo
-- 		local controlCards = data.gCards
-- 		for i=1,data.gCount do
-- 			local controlCard = controlCards[i]
-- 			local gCard = {}
-- 			gCard.cards = {}
-- 			local gType
-- 			if controlCard.isAg > 0 then
-- 				--todo
-- 				gType = GANG_TYPE_AN
-- 			else
-- 				gType = GANG_TYPE_PG
-- 			end

-- 			gCard.type = gType

-- 			for i=1,4 do
-- 				table.insert(gCard.cards, controlCard.card)
-- 			end

-- 			table.insert(progCards, gCard)
-- 		end
-- 	end

-- 	if data.pCount > 0 then
-- 		--todo
-- 		local controlCards = data.pCards
-- 		for i=1,data.pCount do
-- 			local controlCard = controlCards[i]
-- 			local pCard = {}
-- 			pCard.cards = {}
-- 			pCard.type = CONTROL_TYPE_PENG

-- 			for i=1,3 do
-- 				table.insert(pCard.cards, controlCard)
-- 			end

-- 			table.insert(progCards, pCard)
-- 		end
-- 	end

-- 	local p = nil
-- 	local cs = nil
-- 	-- for i=1,data.cCount do
-- 	-- 	if i % 3 == 1 then
-- 	-- 		--todo
-- 	-- 		p = {}
-- 	-- 		p.type = CONTROL_TYPE_CHI
-- 	-- 		cs = {}
-- 	-- 		p.cards = cs
-- 	-- 		table.insert(cs, data.cCards[i])
-- 	-- 	elseif i % 3 == 0 then
-- 	-- 		table.insert(cs, data.cCards[i])

-- 	-- 		table.insert(progCards, p)
-- 	-- 	else
-- 	-- 		table.insert(cs, data.cCards[i])
-- 	-- 	end
-- 	-- end

-- 	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)

-- 	if lefthandPlane then
-- 		--todo
-- 		lefthandPlaneOperator:redraw(playerType, lefthandPlane, progCards)
-- 	end

-- 	self:showCards(playerType, plane, data.tingCards)

-- 	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)

-- 	if outhandPlane then
-- 		--todo
-- 		outhandPlaneOperator:redraw(playerType, outhandPlane, data.outCards)
-- 	end
    
--     if playerType == CARD_PLAYERTYPE_MY then
-- 		if ZZMJ_GAMEINFO_TABLE[ZZMJ_MY_USERINFO.seat_id .. ""].ting==1 then
-- 			self:showTingHuPlane(plane, data.tingHuCards)
-- 		end
-- 	end


-- 	-- if playerType == CARD_PLAYERTYPE_MY then
-- 		--todo
-- 		-- local tingFlag = ZZMJ_GAMEINFO_TABLE[data.seat_id .. ""].ting

-- 		-- if tingFlag == 1 then
-- 		-- 	--todo
-- 		-- 	local tingHuPlane = plane:getChildByName(CHILD_NAME_TING_HU_PLANE)
-- 		-- 	if tingHuPlane then
-- 		-- 		--todo
-- 		-- 		controlPlaneOperator:showTingHuPlane(tingHuPlane, data.tingHuCards)
-- 		-- 	end
-- 		-- end
-- 	-- end
-- end

--新重绘
function PlayerPlaneOperator:redrawGameInfo(playerType, plane, data)---重绘游戏信息
	local progCards = {}---应该是左方面板显示的牌

	if data.gCount > 0 then
		local controlCards = data.gCards---杠牌的值（除了普通的杠之外，还包括赖子杠）

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

			--if controlCard.card == ZZMJ_LAIZI then
			--	table.insert(gCard.cards,controlCard.card)
			--	table.insert(progCards, gCard)
 			--else
 				for i=1,4 do
 					local cardData = D3_CARDDATA:new(controlCard.card, 1, CARDNODE_TYPE_NORMAL)
					table.insert(gCard.cards, cardData)
				end
				table.insert(progCards, gCard)
			--end
		end

	end

	if data.pCount > 0 then
		dump(value, desciption, nesting)
		local controlCards = data.pCards
		for i=1,data.pCount do
			local controlCard = controlCards[i]
			local pCard = {}
			pCard.cards = {}
			pCard.type = CONTROL_TYPE_PENG

			for i=1,3 do
				local cardData = D3_CARDDATA:new(controlCard, 1, CARDNODE_TYPE_NORMAL)
				table.insert(pCard.cards, cardData)
			end
			table.insert(progCards, pCard)
		end
	end

	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	local seatId = ZZMJ_SEAT_TABLE_BY_TYPE[playerType .. ""]

	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)

	local outCards = {}

	for i,v in ipairs(data.outCards) do
		if v.outcardtype == 0 then
		local cardData = D3_CARDDATA:new(v.card, 1, CARDNODE_TYPE_NORMAL)
		--兼容了红中的出牌数组
		table.insert(outCards, cardData)
	    end
	end

	table.sort(ZZMJ_GAMEINFO_TABLE[seatId .. ""].hand)

	local cardsSeq = {}
	local laiziSeq = {}
	--癞子放到左侧
	for k,v in pairs(ZZMJ_GAMEINFO_TABLE[seatId .. ""].hand) do
        --if v == ZZMJ_LAIZI then
		--	local cardData = D3_CARDDATA:new(v, 0, CARDNODE_TYPE_LAIZI)
        --
		--	table.insert(laiziSeq, 1, cardData)
		--else
			local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)

			table.insert(cardsSeq, cardData)
		--end
	end

	for i,v in ipairs(laiziSeq) do
		table.insert(cardsSeq, 1, v)
	end
    
    
	D3_OPERATOR:redraw(playerType, inhandPlane, outhandPlane, progCards, cardsSeq, outCards)

    if playerType == CARD_PLAYERTYPE_MY then
    	TINGSEQ = data.tingCards
    	
		if ZZMJ_GAMEINFO_TABLE[ZZMJ_MY_USERINFO.seat_id .. ""].ting==1 then
			self:showTingHuPlane(plane, data.tingHuCards)
		end
	end
end

function PlayerPlaneOperator:showTingCards(plane, tingSeq)
	-- local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
    

	-- local seatId = ZZMJ_MY_USERINFO.seat_id

	-- local cards = ZZMJ_GAMEINFO_TABLE[seatId .. ""].hand


	-- inhandPlaneOperator:showTingCards(inhandPlane, cards, tingSeq)

end

function PlayerPlaneOperator:didSelectOutCard(plane,card)
  	local tingHuPlane = plane:getChildByName(CHILD_NAME_TING_HU_PLANE)
	if tingHuPlane then
		controlPlaneOperator:didSelectOutCard(tingHuPlane, card)
	end
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

		lgPlane:setPosition(cc.p(x, lgPlane:getPosition().y))
	end
end

function PlayerPlaneOperator:showTingHuPlane(plane, tingHuCards)
	local tingHuPlane = plane:getChildByName(CHILD_NAME_TING_HU_PLANE)
	if tingHuPlane then
		controlPlaneOperator:showTingHuPlane(tingHuPlane, tingHuCards)
	end
end

function PlayerPlaneOperator:hideTingHuPlane(plane)
	local tingHuPlane = plane:getChildByName(CHILD_NAME_TING_HU_PLANE)
	-- local tingFlag = ZZMJ_GAMEINFO_TABLE[ZZMJ_MY_USERINFO.seat_id .. ""].ting
	if tingHuPlane then
		--todo
		tingHuPlane:setVisible(false)
	end
end

function PlayerPlaneOperator:showCardsForHu(playerType, plane, cardDatas,hucard)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	if inhandPlane then
		--todo
		inhandPlaneOperator:showCardsForAll(playerType, inhandPlane, cardDatas, {},hucard)
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

		local imgPath = "majong_bujia_bt_p.png"
		if piao == 1 then
			imgPath = "majong_jiagang_bt_p.png"
		elseif piao == 2 then
			imgPath = "majong_jiaerpiao_bt_p.png"
		end

		piaoImg:loadTexture("jiningmajiangji/image/" .. imgPath)
	end
end

function PlayerPlaneOperator:showPiaoPlane(plane, piao, flag)
	local piaoPlane = plane:getChildByName(CHILD_NAME_PIAO_PLANE)
	local piaoLb = piaoPlane:getChildByName(CHILD_NAME_PIAO_LB)

	piaoPlane:setVisible(flag)

	if flag then
		--todo

		local txt = "不加"
		if piao == 1 then
			txt = "加钢"
		elseif piao == 2 then
			txt = "加二飘"
		end

		piaoLb:setString(txt)
	end
end

--显示公共会牌
function PlayerPlaneOperator:HuiPai(plane,huipai)
    
 --    local huipai_box=plane:getChildByName("huipai_box")
 --    huipai_box:setVisible(true)
 --    huipai_box:removeAllChildren()
 --    local value = huipai
 --    local card = card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, value)
	-- local size = card:getSize()
	-- local scale = (huipai_box:getSize().height - 20) / size.height
	-- card:setScale(scale)
	-- card:setPosition(cc.p(huipai_box:getSize().width / 2, huipai_box:getSize().height / 2))
 --    huipai_box:addChild(card)
end

function PlayerPlaneOperator:showSameCard(plane,value)
   	local outPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)
	if outPlane then
		local outcardnodes = outPlane:getChildren()
		if next(outcardnodes)~=nil then
			for i,v in pairs(outcardnodes) do
		    if v.m_value == value then
		       v:setColor(cc.c3b(255,255,0))
		       table.insert(ShowSameCardArray,v)      
			end
			end
	    end	
	end
end

function PlayerPlaneOperator:hideSameCard()

	if next(ShowSameCardArray)~=nil then
		for i,v in pairs(ShowSameCardArray) do
			v:setColor(cc.c3b(255,255,255))
		end
	end
	ShowSameCardArray = {}

end

function PlayerPlaneOperator:beginPlayCard(plane,flag)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
    userInfoPlaneOperator:beginPlayCard(infoPlane,flag)
end


function PlayerPlaneOperator:putCard()
    outhandPlaneOperator:putCard()
end

function PlayerPlaneOperator:updateRoundResult(plane, changeCoins)
    if not plane then
        return
    end
    local txt_roundResult = plane:getChildByName(CHILD_NAME_CHANGECOINS)
    txt_roundResult:setZOrder(5000)
    changeCoins = changeCoins / 100
    if changeCoins >= 0 then
        txt_roundResult:setFntFile(TpackageName .. "/fonts/num_add.fnt")
        txt_roundResult:setString("+" .. changeCoins)
        txt_roundResult:setScale(1.5)
    else
        txt_roundResult:setFntFile(TpackageName .. "/fonts/num_sub.fnt")
        txt_roundResult:setString(changeCoins)
        txt_roundResult:setScale(1.5)
    end
    txt_roundResult:setVisible(true)
    local scaleAction1 = cc.ScaleTo:create(0.2, 2.0)
    local scaleAction2 = cc.ScaleTo:create(0.2, 1.5)
    local seq = cc.Sequence:create(scaleAction1, scaleAction2)
    txt_roundResult:runAction(seq)
end

function PlayerPlaneOperator:updateUserCoins(plane, coins)
    if not plane then
    end
    local userInfoPlane =  plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
    userInfoPlaneOperator:updateUserCoins(userInfoPlane, coins)
end

return PlayerPlaneOperator