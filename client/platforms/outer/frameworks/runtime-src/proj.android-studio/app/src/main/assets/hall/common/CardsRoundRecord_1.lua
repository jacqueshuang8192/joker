
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local CardsRoundRecord = class("CardsRoundRecord", NewViewBaseLayer)

function CardsRoundRecord:ctor( _data )
    local csbPath = "hall/res/commom/CardsRoundRecord/CardsRoundRecord.csb"
    CardsRoundRecord.super.ctor(self, csbPath)
    ccui.Helper:doLayout(self)
    self.curPage = 1
    self.tatolPage = 50
    self:enableMask(true)
    self:initUI()
    self:initEvent()
    self:setData(_data)
end

function CardsRoundRecord:initUI( )
    self.item:hide()
end

function CardsRoundRecord:initEvent( )
    self.btn_l:onClick(handler(self,self.btn_l_page), true)
    self.btn_r:onClick(handler(self,self.btn_r_page), true)
    self.maskLayout:onClick(handler(self,self.btn_close))
end

function CardsRoundRecord:setHandler( handler )
    self.handler = handler
end

function CardsRoundRecord:setData( _data )
    self.vw:removeAllChildren()
    local number = #_data.gameResult
    local scale = self.item:getScale()
    local vwsize = self.vw:getContentSize()
    local size = self.item:getContentSize()
    local width = size.width * scale
    local height = size.height * scale
    local oriX = vwsize.width / 2 - width * (number/2) + width / 2
    local oriY = vwsize.height / 2 

    if number >= 0 then
        for idx,data in ipairs(_data.gameResult) do
            local item = self.item:clone()
            GameUtils.setNodeNameBindObj(item)
            item:show()
            local x = oriX + width * (idx-1)
            item:addTo(self.vw)
            item:setPosition(cc.p(x, oriY))

            if _data.gameName and _data.gameName == "paijiu" then
                self:setItemForPaiJiu(item, data)
            else
                self:setItem(item, data)
            end
        end
    end

    self.curPage = _data.resultIndex
    self.txt_page:setString(self.curPage)
end

function CardsRoundRecord:setItem( item, data )
    local size = item.head:getContentSize()
    local value = data.changeChip / 100
    local str = ""
    if math.abs(value) > 1000 then
        item.score:setScale(0.7)
    end
    if value > 0 then
        str = "+"..tostring(value)
        item.score:setFntFile("hall/res/commom/CardsRoundRecord/win_num.fnt")
    else
        str = tostring(value)
        item.score:setFntFile("hall/res/commom/CardsRoundRecord/lose_num.fnt")
    end
    item.isZhuang:setVisible(data.isZhuang == 1)
    item.score:setString(str)
    item.name:setString(data.nickName)
    item.xiazhuScore:setString(data.xiazhu)
    item.cardType:loadTexture(data.cardType, data.cardType_plist)
    item.cardType:ignoreContentAdaptWithSize(true)

    local str = tonumber(data.grab)
    if str == 0 then
        str = "不抢"
    elseif str == nil then
        str = ""
    else
        str = "X"..str
    end
    item.zhuangScore:setString(str)
    local scale = 1
    local cw = item.cardType:getWidth()
    local iw = item:getWidth()
    if cw > iw then
        scale = iw / cw
    end
    item.cardType:setScale(scale)
    require("hall.GameCommon"):getUserHead(data.smallPhoto, "", "", item.head, size.width , false, "", true)

    local cards = data.cards
    local cardNode = cards[1]
    local number = #cards
    local vwsize = item.cards_vw:getContentSize()
    local size = cardNode:getContentSize()
        if size.width == 0 then
        size = cardNode:getCardSize()
    end
    local scale = vwsize.height / size.height 
    local width = size.width * scale
    local height = size.height * scale
    local oriX = width / 2
    local oriY = vwsize.height / 2 

    local intervalW = (vwsize.width - width) / (number - 1)

    for idx,cardNode in ipairs(cards) do
        cardNode:addTo(item.cards_vw)
        cardNode:setScale(scale)
        cardNode:setAnchorPoint(cc.p(0.5, 0.5))
        if cardNode.font_pai_ then
            cardNode.font_pai_:setAnchorPoint(cc.p(0.5, 0.5))
        end
        local x = oriX + intervalW * (idx-1)
        cardNode:setPosition(cc.p(x, oriY))
    end
end

function CardsRoundRecord:setItemForPaiJiu( item, data )
    local size = item.head:getContentSize()
    local value = data.changeChip / 100
    local str = ""
    if math.abs(value) > 1000 then
        item.score:setScale(0.7)
    end
    if value > 0 then
        str = "+"..tostring(value)
        item.score:setFntFile("hall/res/commom/CardsRoundRecord/win_num.fnt")
    else
        str = tostring(value)
        item.score:setFntFile("hall/res/commom/CardsRoundRecord/lose_num.fnt")
    end
    item.isZhuang:setVisible(data.isZhuang == 1)
    item.score:setString(str)
    item.name:setString(data.nickName)

    item.xiazhuScore:setString(data.xiazhu)
    
    item.cardType:setVisible(false)

    local str = data.grab or 0
    if str == 0 then
        str = "不抢"
    else
        str = "X"..str
    end
    item.zhuangScore:setString(str)
    item.zhuangScore:setVisible(false)

    local scale = 1
    local cw = item.cardType:getWidth()
    local iw = item:getWidth()
    if cw > iw then
        scale = iw / cw
    end
    item.cardType:setScale(scale)
    require("hall.GameCommon"):getUserHead(data.smallPhoto, "", "", item.head, size.width , false, "", true)

    local cardNode = data.cardNode
    local vwsize = item.cards_vw:getContentSize()
    local size = cardNode:getContentSize()
        if size.width == 0 then
        size = cardNode:getContentSize()
    end
    local scale = vwsize.height / size.height 
    local width = size.width * scale
    local height = size.height * scale
    local oriX = width / 2
    local oriY = vwsize.height / 2 
    cardNode:addTo(item.cards_vw)
    cardNode:setPosition(10,-10)

end

function CardsRoundRecord:btn_r_page()
	local page = self.curPage + 1
	if page <= 0 or page > self.tatolPage or self.curPage == page then
		return
    end
    if self.handler then
        self.handler(page)
    end
end

function CardsRoundRecord:btn_l_page()
	local page = self.curPage - 1
	if page <= 0 or page > self.tatolPage or self.curPage == page then
		return
    end
    if self.handler then
        self.handler(page)
    end
end

function CardsRoundRecord:btn_close()
    self:removeSelf()

end

return CardsRoundRecord