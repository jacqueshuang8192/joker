local Card = class("Card", function ()
	return ccui.ImageView:create()
end)
local maPath = TpackageName.."/2DMahjongCard/res/newImage/"

function Card:ctor(path, m_value, cardData)
	self.m_value = m_value
	self.playerType = nil
	self.cardData = cardData
	self:loadTexture(path)
	ViewBase:setTextureSize(self)
	self.arrow = display.newSprite():addTo(self)
	self.ext = display.newSprite():addTo(self)
	
	self._getContentSize = self:getContentSize()
	self._getScale = self:getScale()
	self._getPosition = self:getPosition()
	self._getAnchorPoint = self:getAnchorPoint()
	self._getParent = self:getParent()
	self._gisVisible = self:isVisible()
end

--牌背
function Card:newBack(_type)
	local paths = {
		down = maPath.."down_flods/back.png",
		left = maPath.."left_flods/back.png",
		up = maPath.."up_flods/back.png",
		right = maPath.."right_flods/back.png",
	}
	local path = paths[_type]
	return self.new(path)
end

--用户自己的牌背
function Card:newInhandBack(playerType)
	local paths = {
		-- down = maPath.."down_flods/inhand_back.png",
		left = maPath.."left_flods/inhand_back.png",
		up = maPath.."up_flods/inhand_back.png",
		right = maPath.."right_flods/inhand_back.png",
	}

	local tal = {
        [CARD_PLAYERTYPE_MY] = "down",
        [CARD_PLAYERTYPE_LEFT] = "left",
        [CARD_PLAYERTYPE_RIGHT] = "right",
        [CARD_PLAYERTYPE_TOP] = "up",
    }
    local type_ = tal[playerType]
	local path = paths[type_]
	return self.new(path)
end

--已经出牌
function Card:newOutCard(playerType, cardData, bUp)
	if type(cardData) == "number" then
		local int = cardData
		cardData = {}
		cardData.m_value = int
	end
	local tal = {
        [CARD_PLAYERTYPE_MY] = "down_flods/",
        [CARD_PLAYERTYPE_LEFT] = "left_flods/",
        [CARD_PLAYERTYPE_RIGHT] = "right_flods/",
        -- [CARD_PLAYERTYPE_TOP] = "up_flods/",
        [CARD_PLAYERTYPE_TOP] = "down_flods/",
	}
	if bUp then
		tal[CARD_PLAYERTYPE_TOP] = "up_flods/"
	end
	local path = maPath..""..tal[playerType]..cardData.m_value..".png"
	return self.new(path, cardData.m_value)
end

--碰杠的牌
function Card:newPengOrGangCard(playerType, cardData, bUp)
	if type(cardData) == "number" then
		local int = cardData
		cardData = {}
		cardData.m_value = int
	end
	local tal = {
        [CARD_PLAYERTYPE_MY] = "cardImg/down/",
        [CARD_PLAYERTYPE_LEFT] = "cardImg/left/",
        [CARD_PLAYERTYPE_RIGHT] = "cardImg/right/",
		-- [CARD_PLAYERTYPE_TOP] = "cardImg/up/",
        [CARD_PLAYERTYPE_TOP] = "down_flods/",
        [CARD_PLAYERTYPE_TOP] = "cardImg/down/",
		
	}
	if bUp then
		tal[CARD_PLAYERTYPE_TOP] = "cardImg/up/"
	end
	local path = maPath..""..tal[playerType]..cardData.m_value..".png"
	local card = self.new(path, cardData.m_value)
	self.playerType = playerType
	card:setScale(1)
	return card
end

--选吃的牌
function Card:newChoiseChiCard(cardData)

	local tal = "down_holds/" 
	local path = maPath..tal..cardData.m_value..".png"
	dump(path,"chi===path")
	local card = self.new(path, cardData.m_value)

	return card
end

--暗杠的牌
function Card:setAnGangCard(bUp)
	local playerType = self.playerType
	local m_value = "an_back"
	local tal = {
        [CARD_PLAYERTYPE_MY] = "cardImg/down/",
        [CARD_PLAYERTYPE_LEFT] = "cardImg/left/",
        [CARD_PLAYERTYPE_RIGHT] = "cardImg/right/",
        -- [CARD_PLAYERTYPE_TOP] = "cardImg/up/",
        [CARD_PLAYERTYPE_TOP] = "down_flods/",
        [CARD_PLAYERTYPE_TOP] = "cardImg/down/",
	}
	if bUp then
		tal[CARD_PLAYERTYPE_TOP] = "cardImg/up/"
	end
	local path = maPath..""..tal[playerType]..m_value..".png"
	self:loadTexture(path)
	return self
end

--摊牌
function Card:setCardForAll(playerType, cardData, bUp)
	if type(cardData) == "number" then
		local int = cardData
		cardData = {}
		cardData.m_value = int
	end
	local tal = {
        [CARD_PLAYERTYPE_MY] = "cardImg/down/",
        [CARD_PLAYERTYPE_LEFT] = "cardImg/left/",
        [CARD_PLAYERTYPE_RIGHT] = "cardImg/right/",
		-- [CARD_PLAYERTYPE_TOP] = "cardImg/up/",
        [CARD_PLAYERTYPE_TOP] = "cardImg/down/",
	}
	if bUp then
		tal[CARD_PLAYERTYPE_TOP] = "cardImg/up/"
	end
	local path = maPath..""..tal[playerType]..cardData.m_value..".png"
	self:loadTexture(path)
	self:setScale(1.3)
end

--自己的牌
function Card:newMyInHandCard(cardData)
	if type(cardData) == "number" then
		local int = cardData
		cardData = {}
		cardData.m_value = int
	end
	local path = maPath.."down_holds/"..cardData.m_value..".png"
	local card = self.new(path, cardData.m_value)
	self = card
	card.orderSeq = cardData.orderSeq
	card.type = cardData.type
	if card.type == CARDNODE_TYPE_LAIZI then
		self:showExt(card)
	end

	return card
end
--中码用 自己的牌中码用
function Card:setMyInHandCard(cardData)
	if type(cardData) == "number" then
		local int = cardData
		cardData = {}
		cardData.m_value = int
	end
	local path = maPath.."down_holds/"..cardData.m_value..".png"
	self:loadTexture(path)
	self.orderSeq = cardData.orderSeq
	self.type = cardData.type
	return self
end
--中码用 自己的牌背
function Card:setMyInHandCardBack()
	local path = maPath.."down_holds/back.png"
	local card = self.new(path)
	return card
end
--中码用 中码动画
function Card:setZhongMaAnima(isAnima)
	if isAnima == nil then isAnima = true end
	local size = self:getSize()
	self.img_zhongma = display.newSprite():addTo(self)
	self.img_zhongma:setName("img_zhongma")
	self.img_zhongma:setTexture(maPath.."icon_5.png")
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

--单局结算的牌
function Card:newEndingCard(cardData)
	if type(cardData) == "number" then
		local int = cardData
		cardData = {}
		cardData.m_value = int
	end
	local path = maPath.."last_card/"..cardData.m_value..".png"
	local card = self.new(path, cardData.m_value)
	self = card
	card.orderSeq = cardData.orderSeq
	card.type = cardData.type

	return card
end

--单局结算暗杠的牌
function Card:setEndingAnGangCard()
	local m_value = "an_back"
	local path = maPath.."last_card/"..m_value..".png"
	self:loadTexture(path)
	return self
end

function Card:showArrow(fromplayerType)
	if fromplayerType and fromplayerType > 0 then
		self.arrow:setVisible(true)
		self.arrow:setTexture("hall/3DMahjongCard/image/arrow_" .. fromplayerType .. ".png")
	else
		self.arrow:setVisible(false)
	end
end

--比较判断顺序 癞子 普通 财神牌
-- CARDNODE_TYPE_NORMAL = 1
-- CARDNODE_TYPE_LAIZI = 2
-- CARDNODE_TYPE_CAISHEN = 3
function Card:compare(card1, card2)
	if card1 == nil or not card1.orderSeq then
		return 1
	end
	if card1.orderSeq > card2.orderSeq then
		return 1
	elseif card1.orderSeq == card2.orderSeq then
		if card1.m_value > card2.m_value then
			return 1
		elseif card1.m_value == card2.m_value then
			return 0
		else
			return -1
		end
	else
		return -1
	end
end

--癞子牌 癞财搭
function Card:showExt(parent)
	if G_game and G_game.isLaiZi then
		local isLaiZi = G_game.isLaiZi(self.m_value)
		if isLaiZi then
			self.ext:setVisible(true)
			self.ext:setName("ext")
			self.ext:setTexture(maPath.."ext_" .. self.type .. ".png")
			self.ext:setPosition(cc.p(self:getSize().width - self.ext:getContentSize().width / 2, self:getSize().height - self.ext:getContentSize().height / 2))
		end
	end
end

--设置可以胡牌点点
function Card:showDian()
	self:hideDian()
	if not self.img_dian then
		local size = self:getSize()
		self.img_dian = display.newSprite():addTo(self)
		self.img_dian:setName("img_dian")
		self.img_dian:setTexture(maPath.."icon_4.png")
		self.img_dian:setPosition(cc.p(size.width / 2, size.height +30))
	end
	self.img_dian:setVisible(true)
end

function Card:hideDian()
	if tolua.isnull(self.img_dian) == false then
		self.img_dian:setVisible(false)
	end
	if tolua.isnull(self.txt_dian) == false then
		self.txt_dian:removeSelf()
	end
end

function Card:showTxtDian()
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
function Card:showTxtHuRemainCards(text)
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



return Card