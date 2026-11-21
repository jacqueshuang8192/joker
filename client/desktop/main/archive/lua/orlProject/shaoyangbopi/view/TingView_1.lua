local TingView = class("TingView")
local CardConfig = require("shaoyangbopi.logic.CardConfig")
 
function TingView:ctor(ting_vw)
    self.ting_vw = ting_vw
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
    self.ting_2 = self.ting_vw.ting_2
    self.item = self.ting_vw.ting_2.item:hide()
    self.btn_ting = self.ting_vw.btn_ting
    self.btn_ting:onClick(handler(self, self.onClickTing2), true)
    self.ting_2:onClick(handler(self, self.onClickHideTing2))
    self:hide()
    self.ting_1:hide()
    self.ting_2:hide()
    self.btn_ting:hide()
end

function TingView:onClickTing2()
    if not self.tingHuCards then
        return
    end
    self:show()
    self.ting_2:show()
    local num = #self.tingHuCards
    local ListView_1 = self.ting_2.img_bg.ListView_1
    local counts = {}
    ListView_1:setScrollBarEnabled(false)
    ListView_1:setTouchEnabled(false)
    ListView_1:removeAllItems()

    local tempArr = g_PHZMainScene:get_all_out_cardArr()
    local tempCardNum = 0
    for k,card in pairs(tempArr) do
        if counts[card] then
            counts[card] = counts[card] + 1
        else
            counts[card] = 1
        end
    end

    for idx,card in ipairs(self.tingHuCards) do
        local cardInfo = CardConfig:getCardInfoByid(card)
        if cardInfo then
            local imgPath = string.format("%s.png",cardInfo.CardIconB)
            local item = self.item:clone()
            item:show()
            GameUtils.setNodeNameBindObj(item)
            ListView_1:pushBackCustomItem(item)
            item.card:loadTexture(imgPath, 1)
            local outCardCount = counts[card] or 0
            local remain = 4 - outCardCount
            item.txt_count:setString(remain)
        end
    end
    local size = self.ting_2.img_bg:getContentSize()
    local width = num*100 + 150
    self.ting_2.img_bg:setContentSize(width,size.height)
end

function TingView:onClickHideTing2( )
    self.ting_2:hide()
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
    local ListView_1 = self.ting_1.img_bg.ListView_1
    local counts = {}
    ListView_1:setScrollBarEnabled(false)
    ListView_1:removeAllItems()
    ListView_1:setTouchEnabled(false)
    for idx,card in ipairs(cards) do
        local cardInfo = CardConfig:getCardInfoByid(card)
        if cardInfo then
            local imgPath = string.format("%s.png",cardInfo.CardIconA)
            local cardNode = ccui.ImageView:create(imgPath, 1)
            ListView_1:pushBackCustomItem(cardNode)
        end
    end
    local size = self.ting_1.img_bg:getContentSize()
    local width = num*37 + 100
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
    end
end

function TingView:hideTing2()
    self.btn_ting:hide()
    self.ting_2:hide()
end

function TingView:isTingHu()
    local result = self.btn_ting:isVisible()
    if result == false then
    dump()
        end
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