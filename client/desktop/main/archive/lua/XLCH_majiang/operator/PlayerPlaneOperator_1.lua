local ControlPlaneOperator = require(TpackageName..".operator.ControlPlaneOperator")
local inhandPlaneOperator = require(TpackageName..".operator.InhandPlaneOperator")
local lefthandPlaneOperator = require(TpackageName..".operator.LefthandPlaneOperator")
local outhandPlaneOperator = require(TpackageName..".operator.OuthandPlaneOperator")
local userInfoPlaneOperator = require(TpackageName..".operator.UserInfoPlaneOperator")
local jiapiaoPlaneOperator = require(TpackageName..".operator.JiapiaoPlaneOperator")
local InhandBackMgr = require(TpackageName .. ".2DMahjongCard.InhandBackMgr")
local OutCardMgr = require(TpackageName .. ".2DMahjongCard.OutCardMgr")
local InhandCardMgr = require(TpackageName .. ".2DMahjongCard.InhandCardMgr")
local PengOrGangCardMgr = require(TpackageName .. ".2DMahjongCard.PengOrGangCardMgr")
local cardUtils = require(TpackageName..".utils.cardUtils")

local PlayerPlaneOperator = class("PlayerPlaneOperator")

local inhand_plane = "inhand_plane"
local lefthand_plane = "lefthand_plane"
local control_plane = "control_plane"
local control_img = "control_img"
local player_plane = "player_plane"
local lg_plane = "lg_plane"

local jiapiao_plane = "jiapiao_plane"
local piao_img = "piao_img"

local piao_plane = "piao_plane"
local piao_lb = "piao_lb"
local fnt_changeCoins = "fnt_changeCoins"

local CHILD_NAME_CARD_BX = "card_bx"

local CHILD_NAME_HUA_PLANE = "hua_plane"

local ShowSameCardArray = {}

local newCard = 0

function PlayerPlaneOperator:initUI(plane)
	OutCardMgr:initUI(plane)
end

function PlayerPlaneOperator:init(playerType, plane, flag)
	print("XLCH-playerType",playerType)
	local inhandPlane = plane:getChildByName(inhand_plane)
	local lefthandPlane = plane:getChildByName(lefthand_plane)
	local outhand_plane = plane:getChildByName("outhand_plane")
	if not outhand_plane.outCardNodeStartPos then
		local pos = outhand_plane.outCardNode:getPosition()
		-- local pos = (outhand_plane):convertToWorldSpace(outhand_plane.outCardNode:getPosition()) --这样写是为了贴近函数的原始用法
		outhand_plane.outCardNodeStartPos = pos
		outhand_plane:removeAllChildren()
	end
	
	local controlPlane = plane:getChildByName(control_plane)
	local control_img = plane:getChildByName(control_img)
	local userInfoPlane = plane:getChildByName(player_plane)
	local lgPlane = plane:getChildByName(lg_plane)
	local ting_hu_plane = plane:getChildByName("ting_hu_plane")

	local piao_plane = plane:getChildByName(piao_plane)
	local jiapiao_plane = plane:getChildByName(jiapiao_plane)
	local piao_img = plane:getChildByName(piao_img)
	local hua_plane = plane:getChildByName(CHILD_NAME_HUA_PLANE)

	local huipai_box = plane:getChildByName("huipai_box")
	local txt_roundResult = plane:getChildByName(fnt_changeCoins)


	self:showTuoGuanState(plane,false)

	if hua_plane then
		hua_plane:setVisible(false)
	end

	if piao_img then
		--todo
		piao_img:setVisible(false)
	end

	if piao_plane then

		piao_plane:setVisible(false)
	end
	
	if jiapiao_plane then
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
        outhandPlaneOperator:init(playerType, outhand_plane)
    end
	lefthandPlaneOperator:init(playerType, lefthandPlane)
	ControlPlaneOperator:init(playerType, control_img, controlPlane, lgPlane, ting_hu_plane)
	userInfoPlaneOperator:init(userInfoPlane)
	print("----XLCH-playerType",playerType)
	D3_OPERATOR:init(XLCHMJ_CONTROLLER, playerType, inhandPlane, outhand_plane)
end

function PlayerPlaneOperator:clearGameDatas(playerType, plane)
	local inhandPlane = plane:getChildByName(inhand_plane)
	local lefthandPlane = plane:getChildByName(lefthand_plane)
	local outhand_plane = plane:getChildByName("outhand_plane")
	local userInfoPlane = plane:getChildByName(player_plane)
	local controlPlane = plane:getChildByName(control_plane)
	local lgPlane = plane:getChildByName(lg_plane)
	local ting_hu_plane = plane:getChildByName("ting_hu_plane")
	local piao_plane = plane:getChildByName(piao_plane)
	local jiapiao_plane = plane:getChildByName(jiapiao_plane)
	local piao_img = plane:getChildByName(piao_img)
	local txt_roundResult = plane:getChildByName(fnt_changeCoins)
	local hua_plane = plane:getChildByName(CHILD_NAME_HUA_PLANE)


	self:showTuoGuanState(plane,false)

	if hua_plane then
		print("=======playerType=====5==")
		hua_plane:removeAllChildren()
		hua_plane:setVisible(false)
	end

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
	outhandPlaneOperator:init(playerType, outhand_plane)
	ControlPlaneOperator:clearGameDatas(controlPlane, lgPlane, ting_hu_plane)
	userInfoPlaneOperator:clearGameDatas(userInfoPlane)

	D3_OPERATOR:clearGameDatas(playerType, inhandPlane, outhand_plane)
end

function PlayerPlaneOperator:reLocate(playerType, plane)
	
end

--显示牌，现在只有开场发牌时起作用
function PlayerPlaneOperator:showCards(playerType, plane,tingSeq)

	local inhandPlane = plane:getChildByName(inhand_plane)

	local seatId = XLCHMJ_SEAT_TABLE_BY_TYPE[playerType ]

	local cards = XLCHMJ_GAMEINFO_TABLE[seatId].hand

	dump(playerType, "showCards - playerType")
	dump(cards, "showCards - cards")

	-- local tingFlag = XLCHMJ_GAMEINFO_TABLE[seatId ].ting
	-- local anke = XLCHMJ_GAMEINFO_TABLE[seatId ].anke

	-- if tingFlag ~= 1 or XLCHMJ_ROOM.isBufenLiang == 1 then
	-- 	--todo
	if playerType ~= CARD_PLAYERTYPE_MY then
		InhandBackMgr:showCards(playerType, inhandPlane, cards)
	else
		-- inhandPlaneOperator:showCards(playerType, inhandPlane, cards,tingSeq)

		local cardsSeq = {}
		local laiziSeq = {}
		--癞子放到左侧
		for k,v in pairs(XLCHMJ_GAMEINFO_TABLE[seatId ].hand) do
			if G_game.isLaiZi(v) then
				local cardData = D3_CARDDATA:new(v, 0, CARDNODE_TYPE_LAIZI)
				table.insert(laiziSeq, 1, cardData)
			else
				local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)
				table.insert(cardsSeq, cardData)
			end
		end
		for i,v in ipairs(laiziSeq) do
			table.insert(cardsSeq, 1, v)
		end
		InhandCardMgr:showMyCards(playerType, inhandPlane, cardsSeq, tingSeq)
	end
	-- else
	-- end
	

	-- self:reLocate(playerType, plane)
end

function PlayerPlaneOperator:showControlPlane(plane, controlType)
	
	local controlPlane = plane:getChildByName(control_plane)

	if controlPlane then
		--todo

		ControlPlaneOperator:showPlane(controlPlane, controlType)

		local inhandPlane = plane:getChildByName(inhand_plane)

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
	local controlPlane = plane:getChildByName(control_plane)

	if controlPlane then
		--todo
		controlPlane:setVisible(false)
	end
end

function PlayerPlaneOperator:cancelSelectingCard(plane)
	local inhandPlane = plane:getChildByName(inhand_plane)

	if inhandPlane then
		--todo
		inhandPlaneOperator:cancelSelectingCard(inhandPlane)
	end
end

function PlayerPlaneOperator:getNewCard(playerType, plane, value,tingSeq)
	local inhandPlane = plane:getChildByName(inhand_plane)
	if inhandPlane then

		local childs = inhandPlane:getChildren()
		newCard = value
		local cardData = D3_CARDDATA:new(value, 1, CARDNODE_TYPE_NORMAL)
		if G_game.isLaiZi(value) then --癞子
			  cardData = D3_CARDDATA:new(value, 0, CARDNODE_TYPE_LAIZI)
		end
		
		if playerType ~= CARD_PLAYERTYPE_MY then
			InhandBackMgr:setNewCard(playerType, inhandPlane)
		else
			-- D3_OPERATOR:getNewCard(playerType, inhandPlane, cardData, false)
			InhandCardMgr:setNewCard(inhandPlane, cardData)
		end
		-- if inhandPlane then
		-- 	inhandPlaneOperator:getNewCard(playerType, inhandPlane, value,tingSeq)
		-- end
	end
end


--新打牌
function PlayerPlaneOperator:playCard(playerType, plane, tag, value)---玩牌
	if tolua.isnull(plane) then
		return
	end
	local inhandPlane = plane:getChildByName(inhand_plane)
	local outhand_plane = plane:getChildByName("outhand_plane")
	local cardData = D3_CARDDATA:new(value, 1, CARDNODE_TYPE_NORMAL)

	XLCHMJ_CURRENT_CARDNODE = cardData
	dump(XLCHMJ_CURRENT_CARDNODE, "XLCHMJ_CURRENT_CARDNODEplayCard")
	OutCardMgr:playOutCard(playerType, outhand_plane, cardData)
	if playerType ~= CARD_PLAYERTYPE_MY then
		-- OutCardMgr:clearHandCards(inhandPlane)
		InhandBackMgr:playCard(playerType, inhandPlane, cardData)
	else
		InhandCardMgr:playCard(playerType, inhandPlane, cardData)
	end
end



function PlayerPlaneOperator:control(playerType, plane, progCards, controlType,tingSeq,removeCards,fromplayerType,reloginFlage)
	if playerType==CARD_PLAYERTYPE_MY then
		ControlPlaneOperator:setTingNodeVisible(false)
	end

	dump("PlayerPlaneOperator:control")

	--闷胡的特效单独展示了
	if bit.band(HU_TYPE_MEN_HU, controlType) > 0 then
		ControlPlaneOperator:showImgByType(plane,500) --显示闷胡的动画
	else
		--展示特效
		local control_img = plane:getChildByName(control_img)
		ControlPlaneOperator:showImage(control_img, controlType)

		if bit.band(CONTROL_TYPE_HU, controlType) > 0 then
			return
		end

		if bit.band(GANG_TYPE_HUA, controlType) > 0 then
			return
		end

	end

	local inhandPlane = plane:getChildByName(inhand_plane)

	local progCardDatas = {}
	for i,v in pairs(progCards) do
		local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)
		table.insert(progCardDatas, cardData)
	end

	if table.getn(removeCards) == 4 and controlType ~= GANG_TYPE_AN then
		table.remove(removeCards, 4)
	end

	if controlType ~= GANG_TYPE_AN then
		InhandCardMgr:removeCards(playerType, inhandPlane, removeCards,false,controlType)
	else
		InhandCardMgr:removeCards(playerType, inhandPlane, removeCards, true,controlType)
	end


	PengOrGangCardMgr:addProg(playerType, plane.lefthand_plane, progCards, controlType)

	local offsetCardCount = 0
	offsetCardCount = 3 - table.getn(removeCards)

	if offsetCardCount ~= 1 then
		offsetCardCount = 0
	end
	InhandCardMgr:movePosition(playerType, offsetCardCount, inhandPlane)

end

function PlayerPlaneOperator:showPlayerInfo(userInfo, plane)
	local infoPlane = plane:getChildByName(player_plane)
	return userInfoPlaneOperator:showInfo(userInfo, infoPlane)
end

function PlayerPlaneOperator:showZhuang(plane)
	local infoPlane = plane:getChildByName(player_plane)

	userInfoPlaneOperator:showZhuang(true, infoPlane)
end

function PlayerPlaneOperator:showQueImg(type,plane)
	local infoPlane = plane:getChildByName(player_plane)

	userInfoPlaneOperator:showQueImg(type, infoPlane)
end



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
				gType = GANG_TYPE_AN
			else
				gType = GANG_TYPE_PG
			end
			gCard.type = gType
			if G_game.isLaiZi(controlCard.card) then
				table.insert(gCard.cards,controlCard.card)
				table.insert(progCards, gCard)
 			else		
 				for i=1,4 do
 					local cardData = D3_CARDDATA:new(controlCard.card, 1, CARDNODE_TYPE_NORMAL)
					table.insert(gCard.cards, cardData)
				end
				table.insert(progCards, gCard)
			end
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

	local inhandPlane = plane:getChildByName(inhand_plane)
	local lefthand_plane = plane.lefthand_plane

	local seatId = XLCHMJ_SEAT_TABLE_BY_TYPE[playerType ]

	local outhand_plane = plane:getChildByName("outhand_plane")

	local outCards = {}

	for i,v in ipairs(data.outCards) do
		if v.outcardtype == 0 then
		local cardData = D3_CARDDATA:new(v.card, 1, CARDNODE_TYPE_NORMAL)
		--兼容了红中的出牌数组
		table.insert(outCards, cardData)
	    end
	end

	table.sort(XLCHMJ_GAMEINFO_TABLE[seatId ].hand)

	local cardsSeq = {}
	local laiziSeq = {}
	--癞子放到左侧
	for k,v in pairs(XLCHMJ_GAMEINFO_TABLE[seatId ].hand) do
        if G_game.isLaiZi(v) then
			local cardData = D3_CARDDATA:new(v, 0, CARDNODE_TYPE_LAIZI)

			table.insert(laiziSeq, 1, cardData)
		else
			local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)

			table.insert(cardsSeq, cardData)
		end
	end

	for i,v in ipairs(laiziSeq) do
		table.insert(cardsSeq, 1, v)
	end

    PengOrGangCardMgr:handData(playerType, lefthand_plane, progCards)
	dump(playerType, inhandPlane, outhand_plane, progCards, cardsSeq, outCards)

	if playerType == CARD_PLAYERTYPE_MY then
		InhandCardMgr:showMyCards(playerType, inhandPlane, cardsSeq)
		-- D3_OPERATOR:redraw(playerType, inhandPlane, outhand_plane, progCards, cardsSeq, outCards)
	else
		
		InhandBackMgr:showCards(playerType, inhandPlane, cardsSeq)
	end
	if #outCards >= 1 then
		OutCardMgr:showOutCards(playerType, outhand_plane, outCards)
	end

    if playerType == CARD_PLAYERTYPE_MY then
    	TINGSEQ = data.tingCards
    	
		if XLCHMJ_GAMEINFO_TABLE[XLCHMJ_MY_USERINFO.seat_id ].ting==1 then
			self:showTingHuPlane(plane, data.tingHuCards)
		end
		self:setDianNodeBytingpai(plane)
	end
end

function PlayerPlaneOperator:showTingCards(plane, tingSeq)
	-- local inhandPlane = plane:getChildByName(inhand_plane)
    

	-- local seatId = XLCHMJ_MY_USERINFO.seat_id

	-- local cards = XLCHMJ_GAMEINFO_TABLE[seatId ].hand


	-- inhandPlaneOperator:showTingCards(inhandPlane, cards, tingSeq)

end

function PlayerPlaneOperator:didSelectOutCard(plane,card)
  	local ting_hu_plane = plane:getChildByName("ting_hu_plane")
	if ting_hu_plane then
		ControlPlaneOperator:didSelectOutCard(ting_hu_plane, card)
	end
end

function PlayerPlaneOperator:showHupai_vw(card)
	ControlPlaneOperator:showHupai_vw(card)
end

function PlayerPlaneOperator:setTingNodeVisible(flag)
	ControlPlaneOperator:setTingNodeVisible(flag)
end

function PlayerPlaneOperator:removeLatestOutCard(plane, card)
	local outhand_plane = plane:getChildByName("outhand_plane")

	if outhand_plane then
		--todo
		return outhandPlaneOperator:removeLatestOutCard(outhand_plane, card)
	end

	return false
end

function PlayerPlaneOperator:showLgSelectBox(plane, lgCards)
	local lgPlane = plane:getChildByName(lg_plane)

	if lgPlane then
		--todo
		ControlPlaneOperator:showLgSelectBox(lgPlane, lgCards)

		local inhandPlane = plane:getChildByName(inhand_plane)

		local size = inhandPlane:getSize()
		local position = inhandPlane:getPosition()

		local x = position.x + size.width - 75 - lgPlane:getSize().width

		lgPlane:setPosition(cc.p(x, lgPlane:getPosition().y))
	end
end

function PlayerPlaneOperator:showTingHuPlane(plane, tingHuCards)
	local ting_hu_plane = plane:getChildByName("ting_hu_plane")
	if ting_hu_plane then
		ControlPlaneOperator:showTingHuPlane(ting_hu_plane, tingHuCards)
	end
end

function PlayerPlaneOperator:hideTingHuPlane(plane)
	ControlPlaneOperator:setTingNodeVisible(false)
end

function PlayerPlaneOperator:showCardsForHu(playerType, plane, cardDatas,hucard)
	local inhandPlane = plane:getChildByName(inhand_plane)

	if inhandPlane then
		table.sort(cardDatas)
		local cardsSeq = {}
		local laiziSeq = {}
		local hucardData 
		local hucard = hucard or 0
		--癞子放到左侧
		for k,v in pairs(cardDatas) do
			if G_game.isLaiZi(v) then
				if v == hucard and (not hucardData) then  --胡牌单独展示
					hucardData = D3_CARDDATA:new(v, 0, CARDNODE_TYPE_LAIZI)
				else
					local cardData = D3_CARDDATA:new(v, 0, CARDNODE_TYPE_LAIZI)
					table.insert(laiziSeq, 1, cardData)
				end
			else
				if v == hucard and (not hucardData) then  --胡牌单独展示
					hucardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)
				else
					local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)
					table.insert(cardsSeq, cardData)
				end
			end
		end
		for i,v in ipairs(laiziSeq) do
			table.insert(cardsSeq, 1, v)
		end
		InhandBackMgr:showCardsForAll(playerType, inhandPlane, cardsSeq, hucardData)
	end
end

function PlayerPlaneOperator:getHeadNode(plane)
	local infoPlane = plane:getChildByName(player_plane)

	return userInfoPlaneOperator:getHeadNode(infoPlane)
end

function PlayerPlaneOperator:showNetworkImg(plane, flag)
	if plane then
		local infoPlane = plane:getChildByName(player_plane)
		userInfoPlaneOperator:showNetworkImg(infoPlane, flag)
	else
		dump(plane)
	end
end

function PlayerPlaneOperator:showJiapiaoPlane(plane, flag)
	local jiapiaoPlane = plane:getChildByName(jiapiao_plane)

	jiapiaoPlane:setVisible(flag)
end

function PlayerPlaneOperator:showPiaoImg(plane, piao, flag)
	local piaoImg = plane:getChildByName(piao_img)

	piaoImg:setVisible(flag)

	if flag then
		--todo

		local imgPath = "majong_bujia_bt_p.png"
		if piao == 1 then
			imgPath = "majong_jiagang_bt_p.png"
		elseif piao == 2 then
			imgPath = "majong_jiaerpiao_bt_p.png"
		end

		piaoImg:loadTexture(TpackageName.."/res/image/" .. imgPath)
	end
end

function PlayerPlaneOperator:showPiaoPlane(plane, piao, flag)
	local piaoPlane = plane:getChildByName(piao_plane)
	local piaoLb = piaoPlane:getChildByName(piao_lb)

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
   	local outhand_plane = plane:getChildByName("outhand_plane")
	if outhand_plane then
		local outcardnodes = outhand_plane:getChildren()
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
	local infoPlane = plane:getChildByName(player_plane)
    userInfoPlaneOperator:beginPlayCard(infoPlane,flag)
end


function PlayerPlaneOperator:putCard()
    outhandPlaneOperator:putCard()
end

function PlayerPlaneOperator:updateRoundResult(plane, changeCoins)
    if not plane then
        return
    end
    local txt_roundResult = plane:getChildByName(fnt_changeCoins)
    txt_roundResult:setZOrder(5000)
    changeCoins = changeCoins / 100
    if changeCoins >= 0 then
        txt_roundResult:setFntFile(TpackageName .. "/res/fonts/num_add.fnt")
        txt_roundResult:setString("+" .. changeCoins)
        txt_roundResult:setScale(1.5)
    else
        txt_roundResult:setFntFile(TpackageName .. "/res/fonts/num_sub.fnt")
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
    local userInfoPlane =  plane:getChildByName(player_plane)
    userInfoPlaneOperator:updateUserCoins(userInfoPlane, coins)
end

function PlayerPlaneOperator:setDianNodeBytingpai(plane)
	local inhandPlane = plane:getChildByName(inhand_plane)
	if inhandPlane then
		InhandCardMgr:setDianNodeBytingpai(inhandPlane)
	end
end

function PlayerPlaneOperator:hideDianNodeBytingpai(plane)
	local inhandPlane = plane:getChildByName(inhand_plane)
	if inhandPlane then
		InhandCardMgr:hideDianNodeBytingpai(inhandPlane)
	end
end

function PlayerPlaneOperator:showBaoJiaoImg(plane, isVisible)
	if not plane  then 
		return
	end

	local userInfoPlane = plane:getChildByName(player_plane)
	local baojiaoImg = userInfoPlane:getChildByName("baojiaoImg")
	if baojiaoImg then
		baojiaoImg:setVisible(isVisible)
	end
end



function PlayerPlaneOperator:showTuoGuanState(plane, isVisible)
	if not plane  then 
		return
	end

	local userInfoPlane = plane:getChildByName(player_plane)
	local tuoguanState = userInfoPlane:getChildByName("tuoguanState")
	if tuoguanState then
		tuoguanState:setVisible(isVisible)
	end
end

function PlayerPlaneOperator:setDianNodeBytingpaiTianTing(plane)
	local inhandPlane = plane:getChildByName(inhand_plane)
	if inhandPlane then
		local isTiantingFirst = true
		InhandCardMgr:setDianNodeBytingpai(inhandPlane,isTiantingFirst)
	end
end

function PlayerPlaneOperator:setMySlefCardIsMenPai(playerType,plane,isMenPai)
	print("======isMenPai=======",isMenPai)
	local inhandPlane = plane:getChildByName(inhand_plane)

	if inhandPlane then
		InhandCardMgr:setMenPai(inhandPlane,isMenPai)
	end
end


function PlayerPlaneOperator:showImgAnim(plane,controlType)
	local controlImg = plane:getChildByName(control_img)
	ControlPlaneOperator:showImgByType(controlImg, controlType)
end

function PlayerPlaneOperator:removeCard_ZIMO_MENHU(plane)
	local inhandPlane = plane:getChildByName(inhand_plane)
	if inhandPlane then
		D3_OPERATOR:removeCard_ZIMO_MENHU(inhandPlane)
	end
end

function PlayerPlaneOperator:removeCard_ZIMO_MENHU_for_Other(playerType,plane)
	local inhandPlane = plane:getChildByName(inhand_plane)
	if inhandPlane then
		InhandCardMgr:removeCardsForOtherMenHu(playerType,inhandPlane)
	end
end



function PlayerPlaneOperator:playHuaCard(playerType,plane,value)
    local huaPlane = plane:getChildByName(CHILD_NAME_HUA_PLANE)

    --牌子上显示
    if huaPlane then
    	huaPlane:setVisible(true)
    	outhandPlaneOperator:playHuaCard(playerType,huaPlane,value)
    end
     
    --[[local inhandPlane = plane:getChildByName(inhand_plane)
    if inhandPlane then
		self:showCards(playerType, plane)
	end--]]

	--[[--设置出牌位置的牌的颜色
	local outhandPlane = plane:getChildByName("outhand_plane")
	if outhandPlane then
		local cardData = D3_CARDDATA:new(value, 1, CARDNODE_TYPE_NORMAL)
		D3_OPERATOR:playCardForOuthand( playerType, outhandPlane, cardData, cc.c3b(180, 120, 120) )
	end--]]
end

function PlayerPlaneOperator:jiShow(type,card,plane)
	local infoPlane = plane:getChildByName("player_plane")
    userInfoPlaneOperator:jiShow(type,card,infoPlane)
end

function PlayerPlaneOperator:hideJiShow(plane)
	local infoPlane = plane:getChildByName("player_plane")
    userInfoPlaneOperator:hideJiImg(infoPlane)
end


return PlayerPlaneOperator