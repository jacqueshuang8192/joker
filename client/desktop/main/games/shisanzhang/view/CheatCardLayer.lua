--[[
* author:   zwm
* date:     2018-12-09
* describe: 作弊界面
--]]

local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local CheatCardLayer = class("CheatCardLayer", NewViewBaseLayer)
local PokerCard = require( TpackageName..".PokerCard")
local handCardNum = 13
function CheatCardLayer:ctor(cards)
	local csbPath = TpackageName.."/res/layout/cheatCardLayer.csb"
	CheatCardLayer.super.ctor(self, csbPath, false, false)

	GameUtils.setNodeNameBindObj(self._csbNode)

	self.selectedCard = {}
	-- self.cardLst = {
	-- 	0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d,
	-- 	0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d,
	-- 	0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d,
	-- 	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d,0x0a, 0x0b, 0x0c, 0x0d,0x0a, 0x0b, 0x0c, 0x0d,
	-- }
	self.cardLst = cards or {}
	self:initUI()
	self:initEvent()
	self:showPoolCards(self.cardLst)
end

function CheatCardLayer:initUI()
	local DESIGN_SCREEN_WIDTH  = 1920
    local DESIGN_SCREEN_HEIGHT = 1080
    local SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    local SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
	self._csbNode:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH,SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
	
	self.cardsPanel = self._csbNode.root.cardsPanel
	self.btnClose = self._csbNode.root.btnClose
	self.btnSure = self._csbNode.root.btnSure
end

function CheatCardLayer:initEvent()
	self.btnClose:onClick(handler(self, self.onClickClose))
	self.btnSure:onClick(handler(self, self.onClickSure))
end

function CheatCardLayer:showPoolCards(showCards)
   
    self.cardsPanel:removeAllChildren()

	local scale = 0.5
    local card = PokerCard.new()
    local panelSize = self.cardsPanel:getContentSize()
	local POOL_COL_SPACE = 10
	
	local cardHeight = 315 * scale
	local cardWidth = 233 * scale

    local interval = 13
    local height = panelSize.height 

    for index,value in ipairs(showCards) do
		local card = PokerCard.new()
		card:setCard(value)
		card:showFront()
        card:setScale(scale)
        local  y = math.ceil(index / interval)
        local indexY = height - (cardHeight) * y
        if y > 1 then
            index = index % interval
            if index == 0 then
                index = interval
            end 
        end
        local x = (index-1) * (cardWidth+10)
        card:setPosition(cc.p(x, indexY))
		self.cardsPanel:addChild(card)
		card.bSelect = false
		card.cardValue = value
		local sizea = card:getCardSize()
		local touchlayer = ccui.Layout:create()
		touchlayer:setTouchEnabled(true)
		touchlayer:addTo(card)
		touchlayer:setName("touchlayer")
		touchlayer:setAnchorPoint(0.5,0.5)
		touchlayer:setContentSize(sizea)
		touchlayer:setPosition(card:getComponent(TpackageName..".PokerCard_3").backBg_:getPosition())
		touchlayer:onClick(handler(self, self.onClickCard))
    end
  
end

function CheatCardLayer:onClickCard(event)
	local target = event.target:getParent()
	if target.bSelect then
		target.bSelect = false
		target:setMask(false)
		for i, v in ipairs(self.selectedCard) do
			if v == target.cardValue then
				table.remove(self.selectedCard, i)
				break
			end
		end
	else
		if #self.selectedCard >= handCardNum then -- 手牌个数最多为13
			self:showTip()
			return
		end
		target.bSelect = true
		target:setMask(true)

		table.insert(self.selectedCard, target.cardValue)
	end
end

function CheatCardLayer:onClickClose(event)
	self:closeSelf()
end

function CheatCardLayer:onClickSure(event)
	if #self.selectedCard > handCardNum then -- 需要的手牌只能为9个
		self:showTip()
	else
		self:sendSelectCards()
	end
end

function CheatCardLayer:closeSelf()
	self:removeSelf()
end

function CheatCardLayer:sendSelectCards()
	if #self.selectedCard > handCardNum then -- 手牌个数最多为13
		self:showTip()
		return
	end
	
	require(TpackageName..".handle.ShiSanZhangSendHandle"):CLIENT_COMMAND_USER_CARD(self.selectedCard)

	self:removeSelf()
end

function CheatCardLayer:showTip( )
	local text = string.format("可选择%s个可替换的牌", handCardNum)
	viewMgr:showTip({text = text})
end

return CheatCardLayer