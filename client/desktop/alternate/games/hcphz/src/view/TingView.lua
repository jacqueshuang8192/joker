local TingView = class("TingView")
local Card = require("hcphz.src.Card")
 
function TingView:ctor(GameSceneView)
    self.GameSceneView = GameSceneView
    self.ting_vw = GameSceneView.ting_vw
    self.tingHuCards = {}
    self:initUI()
end

function TingView:clearTingData()
    self.tingHuCards = {}
    self:unClickTing1()
    self:hideTing2()
end

function TingView:initUI()
    self.ting_1 = self.ting_vw.ting_1
    self.ting_hu_vw = self.ting_vw.ting_hu_vw
    self.item = self.ting_vw.ting_hu_vw.item:hide()
    self.btn_ting = self.ting_vw.btn_ting
    self.btn_ting:onClick(function (  )
        self.ting_hu_vw:setVisible(not self.ting_hu_vw:isVisible())
    end, true)
    -- self.btn_ting:onClick(handler(self, self.onClickTing2), true)
    -- self.ting_hu_vw:onClick(handler(self, self.onClickHideTing2))
    self:hide()
    self.ting_1:hide()
    self.ting_hu_vw:hide()
    self.btn_ting:hide()
end

function TingView:onClickTing2()
    if not self.tingHuCards then
        return
    end
    self:show()
    self.ting_hu_vw:show()
    local num = #self.tingHuCards
    local ListView_1 = self.ting_hu_vw.img_bg.ListView_1
    local counts = {}
    ListView_1:setScrollBarEnabled(false)
    ListView_1:setTouchEnabled(false)
    ListView_1:removeAllItems()
    local tempArr = self.GameSceneView:get_all_out_cardArr()
    local tempCardNum = 0
    for k,card in pairs(tempArr) do
        if counts[card] then
            counts[card] = counts[card] + 1
        else
            counts[card] = 1
        end
    end

    for idx,card in ipairs(self.tingHuCards) do
        local item = self.item:clone()
        item:show()
        GameUtils.setNodeNameBindObj(item)
        ListView_1:pushBackCustomItem(item)
        Card:changeImg(item.card, card, "short")
        local outCardCount = counts[card] or 0
        local remain = 4 - outCardCount
        item.txt_count:setString(remain)
    end
    local size = self.ting_hu_vw.img_bg:getContentSize()
    local width = num*60 + 100
    self.ting_hu_vw.img_bg:setContentSize(width,size.height)
end

function TingView:onClickHideTing2( )
    self.ting_hu_vw:hide()
end

function TingView:setTing1(cards)
    if not cards then
        return
    end
    if self:isVisible() and self.ting_1:isVisible() then
        return
    end
    self:show()
    self.ting_1:show()

    local num = #cards
    local card_vw = self.ting_1.img_bg.card_vw
    local counts = {}
    card_vw:removeAllChildren()

    local scale = 0.4
    local getShortCardSize = Card:getShortCardSize( )
    local cardWidth = getShortCardSize.width * scale
    local cardHeight = getShortCardSize.height * scale
    local oriX = cardWidth / 2
    local oriY = cardHeight / 2

    
    for idx,card in ipairs(cards) do
        local cardNode = Card.new(card, "short")
        card_vw:addChild(cardNode)
        cardNode:setScale(scale)
        local x = oriX + (idx - 1) * cardWidth
        cardNode:setPosition(x, oriY)
    end
    local size = self.ting_1.img_bg:getContentSize()
    local width = num*cardWidth + 100
    self.ting_1.img_bg:setContentSize(width,size.height)
end

function TingView:unClickTing1()
    self.ting_1:hide()
end

function TingView:setTing2(tingHuCards)
    self.tingHuCards = tingHuCards
    if #self.tingHuCards >= 1 then
        self:show()
        self.btn_ting:show()
        self:onClickTing2()
    end
end

function TingView:hideTing2()
    self.btn_ting:hide()
    self.ting_hu_vw:hide()
end

function TingView:isTingHu()
    local result = self.btn_ting:isVisible()
    return result
end

function TingView:show()
    self.ting_vw:show()
end

function TingView:isVisible()
    self.ting_vw:isVisible()
end

function TingView:hide()
    self.ting_vw:hide()
end

return TingView