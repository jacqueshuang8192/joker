local SendHandle = require("xhpaohuzi.src.handle.SendHandle")
local OprorateBtn = class("OprorateBtn")
local CardUtils = require("xhpaohuzi.src.CardUtils")
local Card = require("xhpaohuzi.src.Card")

function OprorateBtn:ctor(hall, HandCardView)
	self.hall = hall
	self.HandCardView = HandCardView
	self.chiData1 = {}
	self.chiData2 = {}
	self.chiData3 = {}
	self:initUI()
	self:initEvent()
end

function OprorateBtn:initUI()
    self.btn_close = self.hall.btn_close:hide()
    self.btn_peng = self.hall.btn_peng:hide()
    self.btn_chi = self.hall.btn_chi:hide()
    self.btn_pao = self.hall.btn_pao:hide()
	self.btn_hu = self.hall.btn_hu:hide()
	self.fan_vw = self.hall.fan_vw:hide()
	self.cards_vw = self.hall.cards_vw:hide()
	self.btn_click = self.hall.btn_click:hide()
end

function OprorateBtn:clearData()
	-- g_398.isCanChuCard = false
	self.btn_close:hide()
    self.btn_peng:hide()
    self.btn_chi:hide()
    self.btn_pao:hide()
	self.btn_hu:hide()
	self.fan_vw:hide()
end

function OprorateBtn:initEvent()
    self.btn_close:onClick(handler(self, self.onClick_close), true)
    self.btn_peng:onClick(handler(self, self.onClick_peng), true)
    self.btn_chi:onClick(handler(self, self.onClick_chi), true)
    self.btn_pao:onClick(handler(self, self.onClick_pao), true)
    self.btn_hu:onClick(handler(self, self.onClick_hu), true)
	self.fan_vw:onClick(function()
		self.fan_vw:hide()
	end)
end

function OprorateBtn:setData( data )
	self:clearData()
	local btnArr = {
		self.btn_hu,
		self.btn_peng,
		self.btn_chi,
		self.btn_pao,
	}

	local director = cc.Director:getInstance()
	local size = director:getWinSize()
	local initPosX = size.width * 0.9
	self.btn_close:setPositionX(initPosX)
	initPosX = initPosX - (self.btn_close:getContentSize().width + 50)
	for idx,v in ipairs(data) do
		local node = btnArr[idx]
		if v == 1 then
			node:setVisible(true)
			node:setPositionX(initPosX)
			initPosX = initPosX - (node:getContentSize().width + 30)
		else
			node:setVisible(false)
		end
	end
	self.btn_close:show()
end

function OprorateBtn:onClick_close(event)
	local func = function (  )
		SendHandle:CLI_PASS()
		self:clearData()
	end
	if self.btn_hu:isVisible() then
		local data = {}
		data.type = 2
		data.content = "是否过胡"
		data.title = "提示"
		data.callBackSure = function (  )
			func()
		end
		require("hall.tips.CommonTips"):showTips(data)
	else
		func()
	end
end

function OprorateBtn:onClick_peng(event)
	local func = function (  )
		SendHandle:CLI_PLAYER_PENG_CARD()
		self:clearData()
	end
	if self.btn_hu:isVisible() then
		local data = {}
		data.type = 2
		data.content = "是否过胡"
		data.title = "提示"
		data.callBackSure = function (  )
			func()
		end
		require("hall.tips.CommonTips"):showTips(data)
	else
		func()
	end
end

function OprorateBtn:onClick_chi(event)
	local func = function (  )
		if g_398.curOutCard then
			self.chiData1 = {}
			self.chiData2 = {}
			self.chiData3 = {}
			local pokerCards = self.HandCardView:getCurHandPokersAndZiPaiCards( )
			local chiResult = CardUtils:getChiData( pokerCards, g_398.curOutCard )
			if #chiResult == 1 then
				self.chiData1 = chiResult[1]
	
				local chiData1 = clone(self.chiData1)
				table.remove(chiData1, 1)
				for i,poker1 in ipairs(chiData1) do
					for idx, poker in ipairs(pokerCards) do
						if poker == poker1 then
							table.remove(pokerCards, idx)
							break
						end
					end
				end
				local curOutCard--从手牌删除可以吃牌那一张 在寻找比牌数据 如果没有说明构不成比牌条件
				for idx, poker in ipairs(pokerCards) do
					if poker == g_398.curOutCard then
						curOutCard = poker
						table.remove(pokerCards, idx)
						break
					end
				end
				if curOutCard then
					local biResult = CardUtils:getChiData( pokerCards, curOutCard )
					if #biResult <= 1 then
						self.chiData2 = biResult[1] or {}
						self:CLI_PLAYER_CHI_CARD( )
						return
					end
				else
					self:CLI_PLAYER_CHI_CARD( )
					return
				end
			end
			self.fan_vw:removeAllChildren()
			self:showTypeCards(chiResult, g_398.curOutCard, 1)
		end
	end
	if self.btn_hu:isVisible() then
		local data = {}
		data.type = 2
		data.content = "是否过胡"
		data.title = "提示"
		data.callBackSure = function (  )
			func()
		end
		require("hall.tips.CommonTips"):showTips(data)
	else
		func()
	end
end


function OprorateBtn:showTypeCards(chiResult, curOutCard, index)
	self.fan_vw:show()
	local childs = self.fan_vw:getChildren()
	for idx = index, #childs do
		childs[idx]:removeSelf()
	end

	local director = cc.Director:getInstance()
	local size = director:getWinSize()
	local initPosX = size.width
	local childs = self.fan_vw:getChildren()
	for i,node in ipairs(childs) do
		local size = node:getSize()
		initPosX = initPosX - size.width - 10
	end

	local scale = 0.45
    local getShortCardSize = Card:getShortCardSize( )
    local cardWidth = getShortCardSize.width * scale
	local cardHeight = getShortCardSize.height * scale

	local btn_clickSize = self.btn_click:getSize()
	local cards_vw = self.cards_vw:clone()
	local size = cards_vw:getSize()
	size.width = btn_clickSize.width * (#chiResult + 1)
	cards_vw:setContentSize(size)
	cards_vw:show()
	self.fan_vw:addChild(cards_vw)
	cards_vw:setPositionX(initPosX)

    local oriY = size.height / 2
    local oriX = size.width - btn_clickSize.width
	for idx, pokerCards in ipairs(chiResult) do
		local btn_click = self.btn_click:clone()
		btn_click:show()
		GameUtils.setNodeNameBindObj(btn_click)
		Card:changeImg(btn_click.Card_1, pokerCards[1], "short")
		Card:changeImg(btn_click.Card_2, pokerCards[2], "short")
		Card:changeImg(btn_click.Card_3, pokerCards[3], "short")
		btn_click:onClick(handler(self, self.onClickCard), true)
		btn_click.pokerCards = pokerCards
		btn_click.index = index
		local x = oriX - (idx - 1) * btn_clickSize.width
		btn_click:setPosition(cc.p(x, oriY))
        cards_vw:addChild(btn_click)
    end
end

function OprorateBtn:onClickCard( event )
	local target = event.target
	local index = target.index
	local pokerCards = target.pokerCards
	self["chiData"..index] = pokerCards
	print(index)
	local rpokerCards = {}
	local chiData1 = clone(self.chiData1)
	table.remove(chiData1, 1)
	if index == 1 then
		self.chiData2 = {}
		self.chiData3 = {}
		rpokerCards = chiData1
	elseif index == 2 then
		self.chiData2 = pokerCards
		self.chiData3 = {}
		rpokerCards = tableConcat(chiData1, self.chiData2)
	elseif index == 3 then
		self.chiData3 = pokerCards
		rpokerCards = tableConcat(chiData1, self.chiData2, self.chiData3)
	end
	dump(rpokerCards)
	local handPokerCards = self.HandCardView:getCurHandPokersAndZiPaiCards( )
	local count = 0
	for i,poker1 in ipairs(rpokerCards) do--从手牌删除吃牌 比牌数据 再寻找比牌数据
		for idx, poker in ipairs(handPokerCards) do
			if poker == poker1 then
				table.remove(handPokerCards, idx)
				count = count + 1
				break
			end
		end
	end
	local curOutCard--从手牌删除可以吃牌那一张 在寻找比牌数据 如果没有说明构不成比牌条件
	for idx, poker in ipairs(handPokerCards) do
		if poker == g_398.curOutCard then
			curOutCard = poker
			table.remove(handPokerCards, idx)
			break
		end
	end
	if curOutCard then
		local biResult = CardUtils:getChiData( handPokerCards, curOutCard )
		local biResult = CardUtils:getChiData( handPokerCards, curOutCard )
		if #biResult <= 0 then
			self.chiData3 = biResult[1] or {}
			self:CLI_PLAYER_CHI_CARD( )
		else
			self:showTypeCards(biResult, g_398.curOutCard, index + 1)
		end
	else
		self:CLI_PLAYER_CHI_CARD( )
	end
	
end

function OprorateBtn:CLI_PLAYER_CHI_CARD( )
	local biarr = self:getBiArr()
	SendHandle:CLI_PLAYER_CHI_CARD(self.chiData1[2], self.chiData1[3], g_398.curOutCard, biarr)
	self:clearData()
end

function OprorateBtn:getBiArr()
	local arr = {}
	for i,v in ipairs(self.chiData2) do
		local tempArr = {value = v}
		table.insert(arr,tempArr)
	end
	for i,v in ipairs(self.chiData3) do
		local tempArr = {value = v}
		table.insert(arr,tempArr)
	end
	return arr
end

function OprorateBtn:isHaveBiCard(arr,curIndex)
	for k,v in pairs(arr) do
		if k == curIndex and v > 0 then
			return true
		end
	end
	return false
end

function OprorateBtn:onClick_pao(event)
    SendHandle:CLI_PLAYER_PAO_CARD()
	self:clearData()
end

function OprorateBtn:onClick_hu(event)
    SendHandle:CLI_PLAYER_HU_CARD()
	self:clearData()
end



return OprorateBtn	