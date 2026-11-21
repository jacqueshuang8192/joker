--[[
* author:   zwm
* date:     2019-03-25
* describe: 总战绩界面
* explain:  如果要继承 NewViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local PokerCard = require( TpackageName..".PokerCard")
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local MatchCardView = class("MatchCardView", NewViewBaseLayer)
local CardUtils = require(TpackageName..".CardUtils")
local MAX_DATE = 15
local EVENTNAME = {
	QUERY_ACTIVITIES_RESULT = "/freeGame/queryActivitiesResult",
}
local instance = cc.UserDefault:getInstance()

function MatchCardView:ctor()
    local csbPath = TpackageName.."/res/layout/MatchCardView/MatchCardView.csb"
	MatchCardView.super.ctor(self, csbPath, true, false)
	local size = self._csbNode:getContentSize()
	self.root:setPositionX(size.width/2)
	GameUtils.setNodeNameBindObj(self._csbNode)
	self:enableMask(true)
	
    -- display.doLayout(nil, self._csbNode.bg)
  
	self.handCardNodes = {} --手牌node
	self.curHandCardIdxs = {} --点击的手牌indexs
	self._cards  = {} --0x02,0x03,0x04,0x05,0x06, 13张所有牌
	self._curCards  = {} --0x02,0x03,0x04,0x05,0x06, 当前的牌
	self.cardsData = {}--客户端的牌数据 {value id number score}
	self.clickCrads = {}--点击两张牌互换位置
	self.cardSpcardtype = 1--特殊牌
	self._allDaoNode = {} --
	self.cardsNodePosition = {} --1-3头道4-8中道9-13尾道
	self.typeDaoPosY = {} --用以区分头中尾
	self.IntermediatePointY = 0
	self.cardUpPosY = self.IntermediatePointY+20
	self:initEvent()
end

function MatchCardView:setDataCards(_cards, cardSpcardtype)
	
	self._cards = _cards
	self.cardSpcardtype = cardSpcardtype
	-- self._cards = {
    --     0x02,0x03,0x04,0x05,0x06,
    --     0x14,0x15,0x16,0x17,0x18,
    --     -- 0x3C,0x3D,0x31,
    --     0x4E,0x4f,0x4f,
    -- }
	self._curCards = clone(self._cards)
	self:initUI()
end

function MatchCardView:initUI(  )
	self.btns:hide()
	self.btns = self.btns_0
	
	self.btns:setScrollBarEnabled(false)
	self.select_lvw:setScrollBarEnabled(false)
	self.select_lvw:removeAllItems()--自动出牌选项框
	self.item:hide()
	self.btns:hide()--对子两对。。。
	self.select_lvw:hide()
	self.btn_close_1:hide()
	self.btn_close_2:hide()
	self.btn_close_3:hide()
	self.btn_shoudong:hide()
	self.btn_zidong:hide()
	self.handCard:hide()
	self.handCard:removeAllChildren()
	self.clock_image:hide()
	self.btn_teshu:hide()
	self.types = {
		["tou"] = self.type_1:hide(),
		["zhong"] = self.type_2:hide(),
		["wei"] = self.type_3:hide(),
	}
	for i,v in ipairs(self.cards_vw:getChildren()) do
		local pos = v:getPosition()
		local y = math.round(pos.y)
		local find_index = table.indexof(self.typeDaoPosY, y)
		if find_index == false then
			table.insert( self.typeDaoPosY, y )
		end
		self.cardsNodePosition[i] = pos
	end
	self.cards_vw:removeAllChildren()
	self:setAutoOrZiDongUI()
	if self.cardSpcardtype > 1 then
		self:onClick_teshu()
		self.btn_teshu:show()
	end
end

function MatchCardView:initEvent()
	-- ReqMgr:addHandle("MatchCardView", EVENTNAME)
	self.btn_shoudong:onClick(handler(self, self.onClickShouDong), true)
	self.btn_zidong:onClick(handler(self, self.onClickZiDong), true)
	self.btn_sure:onClick(handler(self, self.onClickSure), true)
	self.vw_tou:onClick(handler(self, self.onClickTou), true)
	self.vw_zhong:onClick(handler(self, self.onClickZhong), true)
	self.vw_wei:onClick(handler(self, self.onClickWei), true)
	self.btn_close_1:onClick(handler(self, self.onClickDelTou), true)
	self.btn_close_2:onClick(handler(self, self.onClickDelZhong), true)
	self.btn_close_3:onClick(handler(self, self.onClickDelWei), true)
	self.handCard:onTouch(handler(self, self.onClickHandCard))
	self.btn_teshu:onClick(handler(self, self.onClick_teshu), true)
end

function MatchCardView:onClick_teshu()
	local function callFunc()
        ShiSanZhangSendHandle:CLIENT_USER_SPCARDTYPE()
    end
    local paras = {}
    paras.type = 2
    paras.title = "提示"
	paras.sceneName = "CommonTips_MatchCardView"
	paras.callBackSure = callFunc
	local name = CardUtils:getTypeName(self.cardSpcardtype)
    paras.content = string.format("是否按照特殊牌型：[%s] 出牌？\r\n取消后点击右下角可再报道", name)
    require("hall.tips.CommonTips"):showTips(paras)
end

--通过node获取cards
function MatchCardView:getCradsByNode(nodes)
	local cards = {}
	for i,node in ipairs(nodes) do
		table.insert( cards, node._card )
	end
	return cards
end

-----------设置自动
function MatchCardView:setAuto()
	self.cardsData = CardUtils:getClientCardByServerCard(self._cards)
	if not self.result then
		self.result = CardUtils:autoSelectCards(self.cardsData)
	end
	
	local size = self.cards_vw:getContentSize()
	local pos = self.cardsNodePosition[6]
	for i, value in ipairs(self._cards) do
		local card = self:newPoker(pos,value,i)
        card:addTo(self.cards_vw)
	end

	self.select_lvw:removeAllItems()
	for idx,datas in ipairs(self.result) do
		local item = self.item:clone()
		GameUtils.setNodeNameBindObj(item)
		item:setName("item_"..idx)
		item:show()
		item.data = datas
		item.select:hide()
		for jdx,data in ipairs(datas) do
			local type = data.type
			if jdx == 1 then
				if type == CardUtils.TYPE.SanTiao then
					type = "冲三"
				end
			elseif jdx == 2 then
				if type == CardUtils.TYPE.HuLu then
					type = "中墩葫芦"
				end
			end
			local fileName = CardUtils:getTypeFileName(type)
			-- dump(fileName)
			-- dump(type)
			item["type_"..jdx]:loadTexture(TpackageName.."/res/layout/roomScene/type/"..fileName..".png")
			ViewBase:setTextureSize(item["type_"..jdx])
		end
		item:onClick(handler(self,self.onClickItem))
		self.select_lvw:pushBackCustomItem(item)
		
		if idx == 1 then
			item.select:show()
			self:setAutoCardNodePos(datas)
		end
	end

end

function MatchCardView:setAutoCardNodePos(datas)
	local posIdx = 1
	local nodes = self.cards_vw:getChildren()
	for _,data in ipairs(datas) do
		for _,idx in ipairs(data.ids) do
			local node = nodes[idx]
			local pos = self.cardsNodePosition[posIdx]
			posIdx = posIdx + 1
			node:setMask(false)
			local time = 0.1
			local mb1 = cc.MoveTo:create(time, pos)
			local func = cc.CallFunc:create(function()
				self:initAllDaoType()
		  	end)
			if posIdx == 14 then
				node:runAction(cc.Sequence:create(mb1,func))
			else
				node:runAction(cc.Sequence:create(mb1))
			end
		end
	end

end

function MatchCardView:onClickItem(event)
	local target = event.target
	local name = target:getName()
	if self.curItemName == name then
		return
	end
	self.curItemName = name

	local data = target.data
	for idx,node in ipairs(self.select_lvw:getChildren()) do
		node.select:hide()
	end 
	target.select:show()
	self:setAutoCardNodePos(data)
end
-------------------------------------------


--自动比牌还是手动
function MatchCardView:setAutoOrZiDongUI()
	local isshoufong = instance:getBoolForKey("sss_isshoudong")
	self.cards_vw:removeAllChildren()
	self:initAllDaoType()
	if isshoufong == false then--手动出牌
		self.select_lvw:hide()
		
		self.handCard:show()
		self.btns:show()
		self.btn_close_1:show()
		self.btn_close_2:show()
		self.btn_close_3:show()
		self._curCards = clone(self._cards)
		self:setShouDongCardsNode()
		self.btn_shoudong:hide()
		self.btn_zidong:show()
		self.btn_zidong:setEnabled(true)
	else--自动出牌
		self.select_lvw:show()
		
		self.handCard:hide()
		self.btns:hide()
		self.btn_close_1:hide()
		self.btn_close_2:hide()
		self.btn_close_3:hide()
		self:setAuto()
		self.btn_zidong:hide()
		self.btn_shoudong:show()
		self.btn_shoudong:setEnabled(true)

	end
end

 --手动手牌的节点
function MatchCardView:setShouDongCardsNode()
	-- CardUtils:_typeServeCardsSortByScores(self._curCards,"sortMin")
	CardUtils:_typeServeCardsSortByScores(self._curCards,"sortMax")
	local _cards = self._curCards or {}
	local cardnum = #_cards
	local cardHeight = 315
	local cardWidth = 233
	local size = self.handCard:getContentSize()
	local OtherCardScale = size.height / cardHeight
	local IntermediatePointX = size.width/2
	-- self.IntermediatePointY = 0
	-- self.cardUpPosY = self.IntermediatePointY+20
    local MyHandCardInterval = cardWidth * OtherCardScale * 0.6
	self.handCard:removeAllChildren()
	self.handCardNodes = {} 
	for index,value in ipairs(_cards) do
		
		local card = PokerCard.new()
		local target_point_x = IntermediatePointX + (index - (cardnum + 2.5)/2) * MyHandCardInterval
        local target_point_y = 0
        card:setScale(OtherCardScale)
        card:addTo(self.handCard)
		card:setPosition(target_point_x, 0)
		card:setCard(value)
		card:showFront()
		card._card = value
		card._idx = index
		table.insert( self.handCardNodes, card)
	end
	
	self:setHandCardNodesPos()
	self.cardsData = CardUtils:getClientCardByServerCard(_cards)
	self:setBtns()
end

--点击选中手牌
function MatchCardView:onClickHandCard(event)
	local target = event.target
	if event.name == "moved" or event.name == "began" then
		local x, y = event.x, event.y
        local childs = target:getChildren()
		for i,node in ipairs(childs) do
			if node:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
				local next = i + 1
                local nextNode = childs[next]
                if nextNode then--重叠区域处理
                    if nextNode:getCascadeBoundingBox():containsPoint(cc.p(x, y)) and nextNode.setMask then
						nextNode:setMask(true)
                        return
                    end
				end
				node:setMask(true)
			end
		end
	elseif event.name == "ended" or event.name == "cancelled" then
		local nodes = {}
		for i,node in ipairs(target:getChildren()) do
			if node:isMask() then
				local y = math.round(node:getPositionY())
				if y == self.IntermediatePointY then
					y = self.cardUpPosY
				else
					y = self.IntermediatePointY
				end
				node:setPositionY(y)
			end
			node:setMask(false)
		end
	end
end

function MatchCardView:onClickCardThenDel( cardNode )
	local type = cardNode._type
	local id = cardNode._idx
	if not (type and id) then
		return
	end 
	local nodes = self._allDaoNode[type]
	local talNode = {}
	for idx,node in ipairs(nodes) do
		if node._idx == id then
			table.insert(talNode, node)
		end
	end
	self:delDaoNodeByCards(type, talNode)

end

function MatchCardView:onClickCard(event)
	if event.name == "ended" then
		local card = event.target:getParent()
		if #self.clickCrads < 2 then
			local flag = not card:isMask()
			card:setMask(flag)
			if card:isMask() then
				table.insert( self.clickCrads, card )
			else
				self.clickCrads = {}
			end
		end

		if #self.clickCrads >= 2 then
			for i,node in ipairs(self.cards_vw:getChildren()) do
				node.touchlayer:setTouchEnabled(false)
				node:setMask(false)
			end
			local pos_1 = self.clickCrads[1]:getPosition()
			local pos_2 = self.clickCrads[2]:getPosition()
			local time = 0.1
			local mb1 = cc.MoveTo:create(time, pos_2)
			local mb2 = cc.MoveTo:create(time, pos_1)
			local func = cc.CallFunc:create(function()           
				for i,node in ipairs(self.cards_vw:getChildren()) do
					node.touchlayer:setTouchEnabled(true)
				end
				self:initAllDaoType()

		  	end)
			self.clickCrads[1]:runAction(cc.Sequence:create(mb1))
			self.clickCrads[2]:runAction(cc.Sequence:create(mb2,func))
	
		end
	end
end

--处理对子 两对。。。btn---------------
function MatchCardView:setBtns()
	local result = CardUtils:_findHandCards(self.cardsData)
	local btns = self.btns:getChildren()
	local sanPai = self:getSanPai(clone(self.cardsData))
	for i, btn in ipairs(btns) do
		if #result[i] >= 1 then
			btn:setEnabled(true)
		else
			btn:setEnabled(false)
		end
		btn:onClick(handler(self, self.onClickBtn))
		btn.cardResult = result[i]
		btn.sanPai = sanPai
		btn.cardResultIdx = 0
	end
end

function MatchCardView:getSanPai(cardsData)
	local cardNumbers = CardUtils:getSamescoresCount(cardsData)
	for scores, count in pairs(cardNumbers) do
		if count >= 2 then
			for i=1, count do
				for idx, value in ipairs(cardsData) do
					if value.scores == scores then
						table.remove(cardsData, idx)
						break
					end
				end
			end
		end
	end
	local ids = {}
	for k,value in ipairs(cardsData) do
		table.insert(ids, 1, value.id)
	end
	return ids
end

function MatchCardView:setHandCardNodesPos(idxs)

	if not idxs then idxs = {} end
	local size = self.handCard:getContentSize()
	for i, cardNode in ipairs(self.handCardNodes) do
		cardNode:setPositionY(self.IntermediatePointY)
	end

	for i, idx in ipairs(idxs) do
		local cardNode = self.handCardNodes[idx]
		cardNode:setPositionY(self.cardUpPosY)
	end
end

function MatchCardView:onClickBtn(event)
	local target = event.target
	local _curBtnName = target:getName()
	if self._curBtnName ~= _curBtnName then
		for _, btn in ipairs(self.btns:getChildren()) do
			btn.cardResultIdx = 0
		end
	end
	local cardResult = target.cardResult
	local cardResultIdx = target.cardResultIdx
	local sanPai = clone(target.sanPai)
	cardResultIdx = cardResultIdx + 1
	if cardResultIdx > #cardResult then
		cardResultIdx = 1
	end
	target.cardResultIdx = cardResultIdx
	local result = cardResult[cardResultIdx]
	while #result ~= 5 and #sanPai >= 1 do
		local index = table.remove(sanPai, 1)
		if table.indexof(result, index) == false then
			table.insert(result, index)
		end
	end
	self:setHandCardNodesPos(result)
	self._curBtnName = _curBtnName
end
-----------------------------------------

--点击的手牌indexs
function MatchCardView:setCurHandCardIdxs()
	self.curHandCardIdxs = {}
	for i,node in ipairs(self.handCard:getChildren()) do
		local y = math.round(node:getPositionY())
		if y == self.cardUpPosY then
			table.insert( self.curHandCardIdxs, node._idx )
		end
	end
end

--根据posy获取头中尾三道
function MatchCardView:setAllDaoNode()
	self._allDaoNode = {}
	self._allDaoNode["tou"] = {}
	self._allDaoNode["zhong"] = {}
	self._allDaoNode["wei"] = {}
	local nodes = {}
	for i,node in ipairs(self.cards_vw:getChildren()) do
		local y = math.round(node:getPositionY())
		if y == self.typeDaoPosY[1] then
			table.insert( self._allDaoNode["tou"], node )
		elseif y == self.typeDaoPosY[2] then
			table.insert( self._allDaoNode["zhong"], node )
		else
			table.insert( self._allDaoNode["wei"], node )
		end
	end

end

function MatchCardView:newPoker(pos, value, _idx)
	local card = PokerCard.new()
	card:setScale(0.5)
	card:setPosition(pos)
	card:setCard(value)
	card:showFront()
	local touchlayer = ccui.Layout:create()
	local sizea = card:getCardSize()
	touchlayer:setTouchEnabled(true)
	touchlayer:addTo(card)
	touchlayer:setName("touchlayer")
	touchlayer:setAnchorPoint(0.5,0.5)
	touchlayer:setContentSize(sizea)
	touchlayer:setPosition(card:getComponent(TpackageName..".PokerCard_3").backBg_:getPosition())
	touchlayer:onTouch(handler(self, self.onClickCard),true)
	card.touchlayer = touchlayer
	card._card = value
	card._idx = _idx
	return card
end

--把牌添加到头中尾三道
function MatchCardView:addDaoNodeByCards(type_)
	if type(self._curCards) ~= "table" then
		return
	end
	local len = 5
	local startIdx = 1
	if type_ == "tou" then
		len = 3
	elseif type_ == "zhong" then
		startIdx = 4
	else
		startIdx = 9
	end
    self:setAllDaoNode()
	self:setCurHandCardIdxs()
	local nodes = self._allDaoNode[type_]
	if #nodes > len or #self.curHandCardIdxs <= 0 then return end

	--先获取头中尾一道中的牌和点击的牌合并
	local _cards = self:getCradsByNode(nodes) or {}
	for i, idx in ipairs(self.curHandCardIdxs) do
		if #_cards >= len then break end
		local card = self._curCards[idx]
		table.insert( _cards, card )
	end
	--先删除头中尾一道中的牌
	for i, node in ipairs(nodes) do
		local card = node._card
		table.insert( self._curCards, card )
		node:removeFromParent()
	end

	local posArr = table.slice(self.cardsNodePosition, startIdx, len)--1-3头道4-8中道9-13尾道
	CardUtils:_typeServeCardsSortByScores(_cards,"max")
	local clientCards = CardUtils:getClientCardByServerCard(_cards)
	clientCards = CardUtils:handleSortCards(clone(clientCards))
	-- table.sort(_cards,function(card1, card2)
	-- 	card1 = CardUtils:getClientCardByServerCard({card1})[1]
	-- 	card2 = CardUtils:getClientCardByServerCard({card2})[1]
	-- end)

	for i, card in ipairs(clientCards) do
		local idx = card.id
		local value = _cards[idx]
		local pos = posArr[i]
		local PokerCard = self:newPoker(pos,value,i)
		PokerCard._type = type_
		-- if card.number >= 20 then
		-- 	PokerCard:setGuiCard(card)
		-- end
        PokerCard:addTo(self.cards_vw)
	end

	-- for i, value in ipairs(_cards) do
	-- 	local pos = posArr[i]
	-- 	local card = self:newPoker(pos,value,i)
    --     card:addTo(self.cards_vw)
	-- end

	--删除手牌
	for i, card in ipairs(_cards) do
		for idx, curCard in ipairs(self._curCards) do
			if curCard == card then
				table.remove( self._curCards, idx )
				break
			end
		end	
	end
	self:setHandCardNodesPos()
	self:setShouDongCardsNode()
	self:setAllDaoType(type_)

	self:addDaoNodes()
end

--添加剩余的到到头中尾三道
function MatchCardView:addDaoNodes()
	local tou_nodes = self._allDaoNode["tou"]
	local zhong_nodes = self._allDaoNode["zhong"]
	local wei_nodes = self._allDaoNode["wei"]
	local func = function (  ) --把牌升起来添加到头中尾一道
		for i,node in ipairs(self.handCard:getChildren()) do
			node:setPositionY(self.cardUpPosY)
		end
	end
	
	if #tou_nodes == 3 and #zhong_nodes == 5 then
		func()
		self:addDaoNodeByCards("wei")
	elseif #tou_nodes == 3 and #wei_nodes == 5 then
		func()
		self:addDaoNodeByCards("zhong")
	elseif #zhong_nodes == 5 and #wei_nodes == 5 then
		func()
		self:addDaoNodeByCards("tou")
	end
end

function MatchCardView:initAllDaoType()
	self.clickCrads = {}
	self.curItemName = ""
	self:setAllDaoType("tou")
	self:setAllDaoType("zhong")
	self:setAllDaoType("wei")
end

function MatchCardView:setAllDaoType(typestr)
	local node = self.types[typestr]
	node:hide()
	self:setAllDaoNode()
	local nodes = self._allDaoNode[typestr]
	local len = 5
	local serverCard = self:getCradsByNode(nodes)
	local clientCards = CardUtils:getClientCardByServerCard(serverCard)
	local cardsType = CardUtils:_cardsType(clientCards)
	clientCards = CardUtils:handleSortCards(clientCards,cardsType,nil,true)
	
	for index, card in ipairs(clientCards) do
		local idx  = card.id
		local PokerCard = nodes[idx]
		-- if card.number >= 20 then
		-- 	PokerCard:setGuiCard(card)
		-- else
		-- 	PokerCard:setCard(serverCard[idx])
		-- end
		PokerCard:setCard(serverCard[idx])
	end
	if typestr == "tou" then
		len = 3
		if cardsType == CardUtils.TYPE.SanTiao then
			cardsType = "冲三"
		end
	elseif typestr == "zhong" then
		if cardsType == CardUtils.TYPE.HuLu then
			cardsType = "中墩葫芦"
		end
	end
	if #nodes < len then
		return
	end
	local fileName = CardUtils:getTypeFileName(cardsType)
	node:show()
	node:loadTexture(TpackageName.."/res/layout/roomScene/type/"..fileName..".png")
	ViewBase:setTextureSize(node)
end

function MatchCardView:onClickTou(event)
	local type = "tou"
	self:addDaoNodeByCards(type)
end

function MatchCardView:onClickZhong(event)
	local type = "zhong"
	self:addDaoNodeByCards(type)
end

function MatchCardView:onClickWei(event)
	local type = "wei"
	self:addDaoNodeByCards(type)
end

--把牌删除再添加到手牌
function MatchCardView:delDaoNodeByCards(type, nodes)
	if not nodes then
		nodes = self._allDaoNode[type]
	end
	if #nodes <= 0 then
		return
	end
	-- local _cards = self:getCradsByNode(nodes) or {}
	for i, node in ipairs(nodes) do
		local card = node._card
		table.insert( self._curCards, card )
		node:removeFromParent()
	end
	self:setHandCardNodesPos()
	self:setShouDongCardsNode()
	self:setAllDaoType(type)

end

function MatchCardView:onClickDelTou(event)
	local type = "tou"
	self:delDaoNodeByCards(type)
end

function MatchCardView:onClickDelZhong(event)
	local type = "zhong"
	self:delDaoNodeByCards(type)
end

function MatchCardView:onClickDelWei(event)
	local type = "wei"
	self:delDaoNodeByCards(type)

end

function MatchCardView:onClickBtnReturn(sender, event)
    self:removeSelf()
end

--点击完成
function MatchCardView:onClickSure(  )
    self:setAllDaoNode()
	local touNode = self._allDaoNode["tou"]
	local zhongNode = self._allDaoNode["zhong"]
	local weiNode = self._allDaoNode["wei"]
	if #touNode == 3 and #zhongNode == 5 and #weiNode == 5 then
		local tou_cards = self:getCradsByNode(touNode)
		local zhong_cards = self:getCradsByNode(zhongNode)
		local wei_cards = self:getCradsByNode(weiNode)

		local touClientCards = CardUtils:getClientCardByServerCard(tou_cards)
		local zhongClientCards = CardUtils:getClientCardByServerCard(zhong_cards)
		local weiClientCards = CardUtils:getClientCardByServerCard(wei_cards)
		local tou = CardUtils:getDaoTypeAndValue(touClientCards)
		local zhong = CardUtils:getDaoTypeAndValue(zhongClientCards)
		local wei = CardUtils:getDaoTypeAndValue(weiClientCards)
		local touScore = tou.value 
		local zhongScore = zhong.value
		local weiScore = wei.value
		dump(tou_cards)
		dump(zhong_cards)
		dump(wei_cards)
		dump(touScore)
		dump(zhongScore)
		dump(weiScore)
		if touScore > zhongScore or zhongScore > weiScore then
			viewMgr:showTip({text = "倒水了!"})
			return
		end
		-- local tal = 
		-- {
		-- 	-- 0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x01,   --方块
		-- 	-- 0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x11,   --樱花
		-- 	-- 0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x21,   --红桃
		-- 	0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x31,   --黑桃
		-- }
		local server_tou_cards = CardUtils:getServerCardByClientCard(tou.cards)
		local server_zhong_cards = CardUtils:getServerCardByClientCard(zhong.cards)
		local server_wei_cards = CardUtils:getServerCardByClientCard(wei.cards)
		ShiSanZhangSendHandle:CLI_OPEN_CARD(server_tou_cards, server_zhong_cards, server_wei_cards)
		self:removeSelf()
	end
end

function MatchCardView:onExit()
	ReqMgr:delHandle("MatchCardView", EVENTNAME)
	if self.cardCountDowmHandler then 
		scheduler.unscheduleGlobal(self.cardCountDowmHandler)
		self.cardCountDowmHandler = nil
    end
end

function MatchCardView:onClickShouDong( event )
	local target = event.target
	target:setEnabled(false)
	target:setVisible(false)
	instance:setBoolForKey("sss_isshoudong", false)
	self:setAutoOrZiDongUI()		
end

function MatchCardView:onClickZiDong( event )
	local target = event.target
	target:setEnabled(false)
	target:setVisible(false)
	instance:setBoolForKey("sss_isshoudong", true)
	self:setAutoOrZiDongUI()		
end


function MatchCardView:showCardCountDown(timeout)
	self.beginTime = tonumber(timeout) or 0
    if self.cardCountDowmHandler == nil and self.beginTime >= 1 then 
		self.clock_image:show()
        self.clock_num:setString(tostring(self.beginTime))
        self.cardCountDowmHandler = scheduler.scheduleGlobal(handler(self, self.playCountDown), 1.0)
    end
end

function MatchCardView:playCountDown()
    self.beginTime = self.beginTime - 1
    self.clock_num:setString(tostring(self.beginTime))
	if self.beginTime <= 0 then
		self.clock_image:hide()
        scheduler.unscheduleGlobal(self.cardCountDowmHandler)
        self.cardCountDowmHandler = nil
    end
end

return MatchCardView