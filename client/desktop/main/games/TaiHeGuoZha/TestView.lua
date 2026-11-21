local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local Card = require("TaiHeGuoZha.Card")
local TestView = class("TestView", NewViewBaseLayer)
 
function TestView:ctor(cards, callback, pngType)
    self.callback = callback
    self.pngType = pngType --是否是和图1：是 0不是
    local csbPath = TpackageName.."/res/TestView.csb"
	TestView.super.ctor(self, csbPath)
    GameUtils.setNodeNameBindObj(self._csbNode)
    self:enableMask(true)
    self:setClickMaskClose()
    self:initUI()
    self:setCards(cards)
end

function TestView:initUI()
    self.cards_vw = self._csbNode.root.cards_vw
    self.btnSure = self._csbNode.root.btnSure
	self.btnSure:onClick(handler(self, self.onClickSure), true)
end

function TestView:setCards(cards)
    self.cards_vw:removeAllChildren()
    local size = self.cards_vw:getSize()

    local cardNode =  Card:getCard(3, 1)
    local cardNodeSize = cardNode:getContentSize()
	local cardHeight = cardNodeSize.height
	local cardWidth = cardNodeSize.width
    local scale = 0.8
    cardHeight = scale * cardHeight
    cardWidth = scale * cardWidth
    local intevalWidth = (cardWidth + 20) * scale
    local intevalHeight = (cardHeight + 30) * scale
    local oriX = cardWidth / 2
    local oriY = size.height - cardHeight / 2
    local row = 9
    table.sort(cards)
    local chooseColor = cc.c3b(140, 140, 140)
    local oriColor = cc.c3b(255, 255, 255)
    for idx,card in ipairs(cards) do
        local rowIdx = idx % row
        rowIdx = rowIdx == 0 and row or rowIdx
        local colIdx = math.ceil(idx/ row)
        local value, kind = Card:init(card)
        local cardNode =  Card:getCard(value, kind)
        -- local cardNode = ccui.ImageView:create(cardData.CardIconB..".png",self.pngType)
        local x = oriX + (rowIdx - 1) * intevalWidth
        local y = oriY - (colIdx - 1) * intevalHeight
        cardNode:setPosition(cc.p(x, y))
        cardNode:setScale(scale)
        self.cards_vw:addChild(cardNode)
        cardNode.card = card
        cardNode:onClick(handler(self, self.onClickCard), true)
        cardNode.setMask = function(cardNode,flag)
            if flag then
                cardNode:setColor(chooseColor)
            else
                cardNode:setColor(oriColor)
            end
        end
        cardNode.isMask = function(cardNode)
            local color = cardNode:getColor()
            for key, value in pairs(color) do
                local value1 = chooseColor[key]
                if value1 ~= value then
                    return false
                end
            end
            return true
        end
    end
end

function TestView:onClickCard(event)
	local target = event.target
	target:setMask(not target:isMask())
end

function TestView:onClickSure()
    local chis = self.cards_vw:getChildren()
    local cards = {}
    for i,cardNode in ipairs(chis) do
        if cardNode:isMask() then
            table.insert(cards, cardNode.card)
        end
    end
    if #cards >= 1 and self.callback then
        self.callback(cards)
    end
	self:removeSelf()
end

return TestView