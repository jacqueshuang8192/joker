local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local CheatCardLayer = class("CheatCardLayer", NewViewBaseLayer)
--local PokerCard = require( "96game.PokerCard")
local NinetySixPokerCard = require("96game.src.view.NinetySixPokerCard")
local handCardNum = 13
function CheatCardLayer:ctor(scene,cards)
	local csbPath = "96game/res/csb/cheatCardLayer.csb"
	CheatCardLayer.super.ctor(self, csbPath, false, false)
	self.card_scale = 1
	self.scene = scene
	self.ctrl = scene.ctrl
	self.logic = self.ctrl.logic
	GameUtils.setNodeNameBindObj(self._csbNode)

	self.selectedCards = {}
	-- self.cardLst = {
	-- 	0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d,
	-- 	0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d,
	-- 	0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d,
	-- 	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d,0x0a, 0x0b, 0x0c, 0x0d,0x0a, 0x0b, 0x0c, 0x0d,
	-- }
	self.cardLst = cards or {}
	self:initUI()
	self:initEvent()
	self:setCards(self.cardLst)
end

function CheatCardLayer:initUI()
	local DESIGN_SCREEN_WIDTH  = 1920
    local DESIGN_SCREEN_HEIGHT = 1080
    local SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    local SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
	self._csbNode:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH,SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
	
	self.cards_vw = self._csbNode.root.cards_vw
	self.btnClose = self._csbNode.root.btnClose
	self.btnSure = self._csbNode.root.btnSure
end

function CheatCardLayer:initEvent()
	self.btnClose:onClick(handler(self, self.onClickClose))
	self.btnSure:onClick(handler(self, self.onClickSure))
end

function CheatCardLayer:setCards(cards)
	self.cards_vw:removeAllChildren()
    local row = 12
	local colIdx = math.ceil(#cards/ row)
	local cardHeight = 188
	local cardWidth = 138

    cardHeight = self.card_scale * cardHeight
    cardWidth = self.card_scale * cardWidth
    local intevalWidth = cardWidth
	local intevalHeight = cardHeight
	local size = self.cards_vw:getSize()
	size.height = colIdx*intevalHeight
	self.cards_vw:setInnerContainerSize(size)
    local oriX = cardWidth / 2 + 40

    local oriY = 955.00 - cardHeight
	-- table.sort(cards)
    for idx,card in ipairs(cards) do
        local rowIdx = idx % row
        rowIdx = rowIdx == 0 and row or rowIdx
		colIdx = math.ceil(idx/ row)
		local cardNode = NinetySixPokerCard.new(self, self.cards_vw, self.card_scale) --138, 188
		cardNode:setCardId(card)
		cardNode:setState(2)
		cardNode:setName("card_"..idx)
        local x = oriX + (rowIdx - 1) * intevalWidth
        local y = oriY - (colIdx - 1) * intevalHeight
        cardNode:setPosition(cc.p(x, y))
        cardNode:setScale(self.card_scale)
        --self.cards_vw:addChild(cardNode)
		cardNode.card = card
		cardNode.bSelect = false
		cardNode.cardValue = card
		cardNode:setTouchEnabled(true)
		cardNode:setSwallowTouches(true)
		cardNode:addTouchEventListener(handler(self, self.onTouch))
	end
	
end
function CheatCardLayer:onTouch(sender, event)
	if event == TOUCH_EVENT_BEGAN then

	elseif event == TOUCH_EVENT_MOVED then

	elseif event == TOUCH_EVENT_ENDED then
		--print("sender.cardValue",sender.cardValue)
		self.ctrl.send:CLIENT_COMMAND_USER_CARD(sender.cardValue)
		self:removeSelf()


	end
end

function CheatCardLayer:onClickClose(event)
	self:closeSelf()
end

function CheatCardLayer:onClickSure(event)
	if #self.selectedCards > handCardNum then -- 需要的手牌只能为9个
		self:showTip()
	else
		self:sendSelectCards()
	end
end

function CheatCardLayer:closeSelf()
	self:removeSelf()
end

function CheatCardLayer:sendSelectCards()
	if #self.selectedCards > handCardNum then -- 手牌个数最多为13
		self:showTip()
		return
	end
	
	require(TpackageName..".handle.ShiSanZhangSendHandle"):CLIENT_COMMAND_USER_CARD(self.selectedCards)

	self:removeSelf()
end

function CheatCardLayer:showTip( )
	local text = string.format("可选择%s个可替换的牌", handCardNum)
	viewMgr:showTip({text = text})
end

return CheatCardLayer