local TingView = class("TingView")
local Card = require("xhpaohuzi.src.Card")
 
function TingView:ctor(GameSceneView)
    self.GameSceneView = GameSceneView
    self.ting_vw = GameSceneView.ting_vw
    self.tingHuCards = {}
    self:initUI()
end

function TingView:clearTingData()
    self.tingHuCards = {}
    self:hideTing2()
end

function TingView:initUI()
    self.ting_hu_vw = self.ting_vw.ting_hu_vw
    self.item = self.ting_vw.item:hide()
    self.btn_ting = self.ting_vw.btn_ting
    self.btn_ting:onClick(function (  )
        self.ting_hu_vw:setVisible(not self.ting_hu_vw:isVisible())
    end, true)
    self.ting_hu_vw:hide()
    self.btn_ting:hide()
    self:hide()
end

function TingView:showTingCards(tingHuCards)
    if not tingHuCards then
        return
    end
    self:show()
    self.ting_hu_vw:show()
    local num = #tingHuCards
    local ListView_1 = self.ting_hu_vw.ListView_1
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

    for idx,card in ipairs(tingHuCards) do
        local item = self.item:clone()
        item:show()
        GameUtils.setNodeNameBindObj(item)
        ListView_1:pushBackCustomItem(item)
        Card:changeImg(item.card, card, "short")
        local outCardCount = counts[card] or 0
        local remain = 4 - outCardCount
        item.txt_count:setString(remain)
    end
    local size = self.ting_hu_vw:getContentSize()
    local width = num*60 + 100
    self.ting_hu_vw:setContentSize(width,size.height)
end

function TingView:updateTingData( )
    self:setTing2(self.tingHuCards)
end

function TingView:setTingHuCards(tingHuCards)
    self.tingHuCards = tingHuCards
end

function TingView:setTing2(tingHuCards)
    if #tingHuCards >= 1 then
        self:show()
        self.btn_ting:show()
        self:showTingCards(tingHuCards)
    end
end

function TingView:hideTing2()
    if #self.tingHuCards <= 0 then
        self.btn_ting:hide()
        self.ting_hu_vw:hide()
    end
end

function TingView:show()
    self.ting_vw:show()
end

function TingView:hide()
    self.ting_vw:hide()
end

return TingView