local SendHandle = require("hz_majiang.src.handle.SendHandle")
local OprorateBtn = class("OprorateBtn")
local PokerCard = require("hz_majiang.src.PokerCard")

function OprorateBtn:ctor(GameSceneView)
	self.GameSceneView = GameSceneView
	self.hall = GameSceneView.hall
	self:initUI()
	self:initEvent()
end

function OprorateBtn:initUI()
    self.btn_peng = self.hall.btn_peng:hide()
    self.btn_chi = self.hall.btn_chi:hide()
    self.btn_gang = self.hall.btn_gang:hide()
	self.btn_hu = self.hall.btn_hu:hide()
	self.btn_guo = self.hall.btn_guo:hide()
	self.gang_vw = self.hall.gang_vw:hide()
end

function OprorateBtn:clearData()
    self.btn_peng:hide()
    self.btn_chi:hide()
    self.btn_gang:hide()
	self.btn_hu:hide()
	self.btn_guo:hide()
	self.gang_vw:hide()
	self.gang_vw:removeAllChildren()
end

function OprorateBtn:initEvent()
    self.btn_peng:onClick(handler(self, self.onClick_peng), true)
    self.btn_chi:onClick(handler(self, self.onClick_chi), true)
    self.btn_gang:onClick(handler(self, self.onClick_gang), true)
    self.btn_hu:onClick(handler(self, self.onClick_hu), true)
    self.btn_guo:onClick(handler(self, self.onClick_guo), true)
end

function OprorateBtn:handCards(handle, handleCard, ableGangCards)
	local data = {0, 0, 0, 0}
	local gangCards
	if bit.band(handle, g_308.t_peng) > 0 then --碰
		data[2] = 1
	end
	if bit.band(handle, g_308.t_gang) > 0 then
		gangCards = {}
		local isSelect = false
        for k, v in pairs(ableGangCards or {}) do
            if v > 0 then
                table.insert(gangCards, v)
                table.insert(gangCards, v)
                table.insert(gangCards, v)
				table.insert(gangCards, v)
				if handleCard == v then
					isSelect = true
				end
            end
		end
		if not isSelect then
			table.insert(gangCards, handleCard)
			table.insert(gangCards, handleCard)
			table.insert(gangCards, handleCard)
			table.insert(gangCards, handleCard)
		end
		data[4] = 1
	end
	if bit.band(handle, g_308.t_chi) > 0 then
        if handle == g_308.chi_right then
        elseif handle == g_308.chi_middle then
        elseif handle == g_308.chi_left then
        end
		data[3] = 1
	end
	if bit.band(handle, g_308.t_hu) > 0 then
		data[1] = 1
    end
	self:setData(data, gangCards)
end

function OprorateBtn:setData( data, gangCards )
	self:clearData()
	local btnArr = {
		self.btn_hu,
		self.btn_peng,
		self.btn_chi,
		self.btn_gang,
	}

	local director = cc.Director:getInstance()
	local size = director:getWinSize()
	local initPosX = size.width * 0.89
	self.btn_guo:show()
	self.btn_guo:setPositionX(initPosX)
	initPosX = initPosX - (self.btn_guo:getContentSize().width)

	
	for idx,v in ipairs(data) do
		local node = btnArr[idx]
		if v == 1 then
			if gangCards and idx == 4 then
				self:showGangCards(gangCards)
				local width = self.gang_vw:getContentSize().width
				initPosX = initPosX - (width)
				self.gang_vw:setPositionX(initPosX + width / 2 + node:getContentSize().width / 2)
			end
			node:setVisible(true)
			node:setPositionX(initPosX)
			initPosX = initPosX - (node:getContentSize().width)
		else
			node:setVisible(false)
		end
	end
end

function OprorateBtn:showGangCards(cards)
	self.gang_vw:removeAllChildren()
	self.gang_vw:show()
	local size = self.gang_vw:getSize()
    local scale = 0.7
    local newCards = {}
    for idx, card in ipairs(cards) do
        table.insert(newCards, 1, card)
	end
	local cardWidth = 0
	for idx, card in ipairs(newCards) do
		local colIdx = math.ceil(idx / 4) - 1
        local cardNode = PokerCard:newMyInHandCard(card)
        local cardHeight = cardNode:getSize().height
        cardWidth = cardNode:getSize().width
        cardHeight = cardHeight * scale
        cardWidth = cardWidth * scale
        local oriX = cardWidth + colIdx * (cardWidth/4)
        local oriY = size.height / 2

		local x = oriX + ( idx-1 ) * cardWidth
		cardNode:setPosition(cc.p(x, oriY))
		cardNode:setScale(scale)
		self.gang_vw:addChild(cardNode)
		cardNode:onClick(handler(self, self.onClickGang))
	end
	local colIdx = math.ceil(#newCards  / 4) - 1
	size.width = cardWidth * (#newCards + 1) + colIdx * (cardWidth/4)
	self.gang_vw:setContentSize(size)
end

function OprorateBtn:onClickGang(event)
	local _cardValue = event.target._cardValue
	local UserInfoView = self.GameSceneView.MyUserInfoView
	local cards = UserInfoView.HandCardView:getCurHandCards()
	local handleType = 0
	if _cardValue > 0 and cards[_cardValue] and cards[_cardValue] > 0 then
		if cards[_cardValue] == 1 then --手上只有一个 补杠啦
			handleType = g_308.gang_bu
		elseif cards[_cardValue] == 4 then--手上有大于三个以上 就是暗杠  因为碰杠不可能和其他两种杠同时存在
			handleType = g_308.gang_an
		elseif cards[_cardValue] == 3 then--碰杠
			handleType = g_308.gang_peng
		end
	else
		--补杠的时候 手牌中没有这个牌
		if not cards[_cardValue] then
			handleType = g_308.gang_bu
		end
	end
	SendHandle:requestHandle(handleType, _cardValue)
	if g_308.isCanChuCard == nil then
		g_308.isCanChuCard = true
	end
	self:clearData()
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
	SendHandle:requestHandle(g_308.handleType, g_308.handleCard)
	if g_308.isCanChuCard == nil then
		g_308.isCanChuCard = true
	end
	self:clearData()
end

function OprorateBtn:onClick_chi(event)
end


function OprorateBtn:showTypeCards(chiResult, curOutCard, index)
	local director = cc.Director:getInstance()
	local size = director:getWinSize()
	local initPosX = size.width
	

	local scale = 0.45
    local getShortCardSize = PokerCard:getShortCardSize( )
    local cardWidth = getShortCardSize.width * scale
	local cardHeight = getShortCardSize.height * scale
end

function OprorateBtn:onClickCard( event )
	
end

function OprorateBtn:CLI_PLAYER_CHI_CARD( )
	local biarr = self:getBiArr()
	self:clearData()
end

function OprorateBtn:onClick_gang(event)
	local handleType = bit.band(g_308.handleType, g_308.t_gang)
	SendHandle:requestHandle(handleType, g_308.handleCard)
	if g_308.isCanChuCard == nil then
		g_308.isCanChuCard = true
	end
	self:clearData()
end

function OprorateBtn:onClick_hu(event)
	SendHandle:requestHandle(g_308.handleType, g_308.handleCard)
	if g_308.isCanChuCard == nil then
		g_308.isCanChuCard = true
	end
	self:clearData()
end

function OprorateBtn:onClick_guo(event)
	SendHandle:requestHandle(0, g_308.handleCard)
	if g_308.isCanChuCard == nil then
		g_308.isCanChuCard = true
	end
	self:clearData()
end



return OprorateBtn	