local Card = require("jchuapai.src.Card")
local SendHandle = require("jchuapai.src.handle.SendHandle")
local HuaPaiTest = class("HuaPaiTest", function()
    if device.platform == "ios" then
        if isiOSVerify then
            return cc.CSLoader:createNode("jchuapai/res/HuaPaiTest.csb")
        else
            return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "jchuapai/res/HuaPaiTest.csb")
        end
    else
        return cc.CSLoader:createNode("jchuapai/res/HuaPaiTest.csb")
    end
    -- return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath().."jchuapai/res/HuaPaiTest.csb")
end)
 
function HuaPaiTest:ctor(cards)
    GameUtils.setNodeNameBindObj(self)
    self:setMask()
    self:initUI()
    self:setCards(cards)
end

function HuaPaiTest:initUI()
    self.cards_vw = self.root.cards_vw
end

function HuaPaiTest:setCards(cards)
    self.cards_vw:removeAllChildren()
    local size = self.cards_vw:getSize()
	local cardHeight = 468
	local cardWidth = 100
    local scale = 0.5
    cardHeight = scale * cardHeight
    cardWidth = scale * cardWidth
    local oriX = cardWidth / 2
    local oriY = size.height - cardHeight / 2
    local row = 13
    table.sort(cards)
    for idx,card in ipairs(cards) do
        local rowIdx = idx % row
        rowIdx = rowIdx == 0 and row or rowIdx
        local colIdx = math.ceil(idx/ row)
        local cardNode = Card.new("long", card)
        local x = oriX + (rowIdx - 1) * cardWidth
        local y = oriY - (colIdx - 1) * cardHeight
        cardNode:setPosition(cc.p(x, y))
        cardNode:setScale(scale)
        self.cards_vw:addChild(cardNode)
        cardNode.card = card
        cardNode:onClick(handler(self, self.onClickCard),true)
    end
end

function HuaPaiTest:onClickCard( event )
    local card = event.target.card
    SendHandle:CLI_TEST_CARD(card)
    self:removeSelf()
    dump(card)
end

function HuaPaiTest:setMask()
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

return HuaPaiTest