local Card = require("hcphz.src.Card")
local SendHandle = require("hcphz.src.handle.SendHandle")
local ZiPaiTest = class("ZiPaiTest", function()
    return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath().."hcphz/res/ZiPaiTest.csb")
end)
 
function ZiPaiTest:ctor(cards)
    GameUtils.setNodeNameBindObj(self)
    self:setMask()
    self:initUI()
    self:setCards(cards)
end

function ZiPaiTest:initUI()
    self.cards_vw = self.root.cards_vw
end

function ZiPaiTest:setCards(cards)
    self.cards_vw:removeAllChildren()
    local size = self.cards_vw:getSize()

    local scale = 1
    local getShortCardSize = Card:getShortCardSize( )
    local cardWidth = getShortCardSize.width * scale
    local cardHeight = getShortCardSize.height * scale
    
    local oriX = cardWidth / 2
    local oriY = size.height - cardHeight / 2
    local row = 12
    table.sort(cards)
    for idx,card in ipairs(cards) do
        local rowIdx = idx % row
        rowIdx = rowIdx == 0 and row or rowIdx
        local colIdx = math.ceil(idx/ row)
        local cardNode = Card.new(card, "short")
        local x = oriX + (rowIdx - 1) * cardWidth
        local y = oriY - (colIdx - 1) * cardHeight
        cardNode:setPosition(cc.p(x, y))
        cardNode:setScale(scale)
        self.cards_vw:addChild(cardNode)
        cardNode.card = card
        cardNode:onClick(handler(self, self.onClickCard),true)
    end
end

function ZiPaiTest:onClickCard( event )
    local card = event.target.card
    SendHandle:CLI_TEST_CARD(card)
    self:removeSelf()
    dump(card)
end

function ZiPaiTest:setMask()
	local director = cc.Director:getInstance()
	local size = director:getWinSize()
    self.maskLayout = ccui.Layout:create()
    self.maskLayout:setAnchorPoint(cc.p(0.5, 0.5))
    self.maskLayout:setContentSize(cc.size(size.width, size.height))

    local size = self:getContentSize()
    self.maskLayout:setPosition(cc.p(size.width / 2, size.height / 2))
    self.maskLayout:setBackGroundColorType(1)
    self.maskLayout:setBackGroundColor(cc.c3b(0, 0, 0))
    self.maskLayout:setBackGroundColorOpacity(222)
    self.maskLayout:setTouchEnabled(true)
    self.maskLayout:setVisible(true)
    self:addChild(self.maskLayout, -1000)
    self.maskLayout:onClick(function(  )
        self:removeSelf()
    end)
end

return ZiPaiTest