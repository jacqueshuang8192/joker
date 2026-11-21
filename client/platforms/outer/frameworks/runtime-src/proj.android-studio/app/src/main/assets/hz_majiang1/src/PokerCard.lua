local PokerCard = class("PokerCard", function ()
	return ccui.ImageView:create()
end)
local Path = "hz_majiang/res/cards/"

function PokerCard:ctor(_cardValue, playerType, _path)
	self._cardValue = _cardValue
	self.playerType = playerType
	self:loadTexture(Path.._path)
end

--摊牌 or 碰杠的牌
function PokerCard:setCardForAll(playerType, _cardValue)
	local paths = {
		[g_308.viewId_my] = "handCards/down/",
		[g_308.viewId_left] = "handCards/left/",
		[g_308.viewId_top] = "handCards/down/",
		[g_308.viewId_right] = "handCards/right/",
	}
	local path = paths[playerType].._cardValue..".png"
	local cardNode = self.new(_cardValue, playerType, path)
	return cardNode
end

function PokerCard:setAnGangCard()
	local paths = {
		[g_308.viewId_my] = "handCards/down/",
		[g_308.viewId_left] = "handCards/left/",
		[g_308.viewId_top] = "handCards/down/",
		[g_308.viewId_right] = "handCards/right/",
	}
	local path = paths[self.playerType].."an_back.png"
	self:loadTexture(Path..path)
	return self
end

--桌牌背
function PokerCard:newTableCard(playerType)
	local paths = {
		[g_308.viewId_my] = "outCards/down/back.png",
		[g_308.viewId_left] = "outCards/left/back.png",
		[g_308.viewId_top] = "outCards/up/back.png",
		[g_308.viewId_right] = "outCards/right/back.png",
	}
	local path = paths[playerType]
	return self.new(nil, playerType, path)
end

--用户手牌的牌背
function PokerCard:newInhandBack(playerType)
	local paths = {
		[g_308.viewId_my] = "outCards/down/inhand_back.png",
		[g_308.viewId_left] = "outCards/left/inhand_back.png",
		[g_308.viewId_top] = "outCards/up/inhand_back.png",
		[g_308.viewId_right] = "outCards/right/inhand_back.png",
	}
	local path = paths[playerType]
	return self.new(nil, playerType, path)
end

--自己的手牌
function PokerCard:newMyInHandCard(_cardValue)
	local path = "myHand/".._cardValue..".png"
	local cardNode = self.new(_cardValue, g_308.viewId_my, path)

	if g_308.laiziCards[_cardValue] then
		cardNode:showExt()
	end
	return cardNode
end

--已经出牌
function PokerCard:newOutCard(playerType, _cardValue)
	local paths = {
		[g_308.viewId_my] = "outCards/down/",
		[g_308.viewId_left] = "outCards/left/",
		[g_308.viewId_top] = "outCards/down/",
		[g_308.viewId_right] = "outCards/right/",
	}
	local path = paths[playerType].._cardValue..".png"
	return self.new(_cardValue, playerType, path)
end

--中码用 中码动画
function PokerCard:setZhongMaAnima(isAnima)
	if isAnima == nil then isAnima = true end
	local size = self:getSize()
	self.img_zhongma = display.newSprite():addTo(self)
	self.img_zhongma:setName("img_zhongma")
	self.img_zhongma:setTexture(Path.."icon_5.png")
	self.img_zhongma:setPosition(cc.p(size.width / 2, size.height / 2))
	self.img_zhongma:setVisible(true)
	if isAnima then
		self.img_zhongma:setScale(5)
		local ScaleTo1 = cc.ScaleTo:create(0.07, 0.8)
		local ScaleTo2 = cc.ScaleTo:create(0.02, 1)
		local Sequence = cc.Sequence:create(ScaleTo1,ScaleTo2)
		self.img_zhongma:runAction(Sequence)
	else
		self.img_zhongma:setPosition(cc.p(size.width / 2, size.height / 2 + 10))
		self.img_zhongma:setScale(0.5)
	end
end

--中码用 自己的牌中码用
function PokerCard:setMyInHandCard(_cardValue)
	local path = Path.."myHand/".._cardValue..".png"
	self:loadTexture(path)
	self._cardValue = _cardValue
	return self
end
--中码用 自己的牌背
function PokerCard:setMyInHandCardBack()
	local path ="myHand/back.png"
	local card = self.new(0, g_308.viewId_my, path)
	return card
end

--单局结算的牌
function PokerCard:newEndingCard(_cardValue)
	local path = "last_card/".._cardValue..".png"
	local card = self.new(_cardValue, g_308.viewId_my, path)
	return card
end


--癞子牌 癞财搭
function PokerCard:showExt()
	if g_308.laiziCards[self._cardValue] then
		self.ext = ccui.ImageView:create(Path.."ext_2.png")
		self.ext:addTo(self)
		self.ext:setName("ext")
		local size = self:getContentSize()
		local ssize = self.ext:getContentSize()
		self.ext:setPosition(cc.p(size.width - ssize.width / 2, size.height - ssize.height / 2))
	end
end

--设置可以胡牌点点
function PokerCard:showDian()
	self:hideDian()
	if not self.img_dian then
		local size = self:getContentSize()
		self.img_dian = display.newSprite():addTo(self)
		self.img_dian:setName("img_dian")
		self.img_dian:setTexture(Path.."icon_4.png")
		self.img_dian:setPosition(cc.p(size.width / 2, size.height + 30))
	end
	self.img_dian:setVisible(true)
end

function PokerCard:hideDian()
	if tolua.isnull(self.img_dian) == false then
		self.img_dian:setVisible(false)
	end
	if tolua.isnull(self.txt_dian) == false then
		self.txt_dian:removeSelf()
	end
end

function PokerCard:showTxtDian()
	self:hideDian()
	self.txt_dian = display.newTTFLabel({
		text = "多",
		font = "res/fonts/fzcy.ttf",
		size = 35,
		color = cc.c3b(68,217,249), -- 使用纯红色
	})
	self.txt_dian:addTo(self)
	local size = self:getSize()
	self.txt_dian:setPosition(cc.p(size.width / 2, size.height +30))
end
----------------

--[[
    @desc: 
    author:{author}
    time:2020-04-05 21:47:38
    @return:
    @text:3张
]]
function PokerCard:showTxtHuRemainCards(text)
	if not self.txt_remainCard then
		self.txt_remainCard = display.newTTFLabel({
			text = text,
			font = "res/fonts/fzcy.ttf",
			size = 35,
			color = cc.c3b(67,231,223), -- 使用纯红色
		})
		self.txt_remainCard:addTo(self)
		local size = self:getSize()
		local scale = self:getScale()
		self.txt_remainCard:setPosition(cc.p(size.width / 2 , -(size.height / 2 - 15) * scale))
	end
end

return PokerCard