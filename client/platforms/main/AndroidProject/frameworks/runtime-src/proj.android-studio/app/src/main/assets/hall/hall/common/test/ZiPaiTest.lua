local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local ZiPaiTest = class("ZiPaiTest", NewViewBaseLayer)
 
function ZiPaiTest:ctor(cards, callback, CardConfig, pngType)
    self.callback = callback
    self.CardConfig = CardConfig
    self.pngType = pngType --是否是和图1：是 0不是
    local csbPath = "hall/res/commom/test/ZiPaiTest.csb"
	ZiPaiTest.super.ctor(self, csbPath)
    GameUtils.setNodeNameBindObj(self._csbNode)
    self:enableMask(true)
    self:setClickMaskClose()
    self:initUI()
    self:setCards(cards)
end

function ZiPaiTest:initUI()
    self.cards_vw = self._csbNode.root.cards_vw
end

function ZiPaiTest:setCards(cards)
    self.cards_vw:removeAllChildren()
    local size = self.cards_vw:getSize()
	local cardHeight = 111
	local cardWidth = 97
    local scale = 1
    cardHeight = scale * cardHeight
    cardWidth = scale * cardWidth
    local intevalWidth = (cardWidth + 3) * scale
    local intevalHeight = (cardHeight + 3) * scale
    local oriX = cardWidth / 2
    local oriY = size.height - cardHeight / 2
    local row = 7
    table.sort(cards)
    for idx,card in ipairs(cards) do
        local rowIdx = idx % row
        rowIdx = rowIdx == 0 and row or rowIdx
        local colIdx = math.ceil(idx/ row)
        local cardData = self.CardConfig:getCardInfoByid(card)
        dump(cardData.CardIconB)
        local cardNode = ccui.ImageView:create(cardData.CardIconB..".png",self.pngType)
        local x = oriX + (rowIdx - 1) * intevalWidth
        local y = oriY - (colIdx - 1) * intevalHeight
        cardNode:setPosition(cc.p(x, y))
        cardNode:setScale(scale)
        self.cards_vw:addChild(cardNode)
        cardNode.card = card
        cardNode:onClick(handler(self, self.onClickCard),true)
    end
end

function ZiPaiTest:onClickCard( event )
    local card = event.target.card
    if self.callback then
        self.callback(card)
    end
    self:removeSelf()
    dump(card)
end

return ZiPaiTest