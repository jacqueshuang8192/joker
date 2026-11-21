--[[
* author:   zwm
* date:     2020-08-05
* describe: 选牌界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]


local ViewBaseLayer = require("hall.ViewBaseLayer")
local SelectCardsLayer = class("SelectCardsLayer", ViewBaseLayer)

local PDKServer = import(TpackageName .. ".src.protocol.PDKServer")
local Card = require(TpackageName..".src.view.Card")

local size_16 = {
    0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,
    0x11,0x13,0x14,0x16,0x17,0x15,0x18,0x19,0x1A,0x1B,0x1C,0x1D,
    0x21,0x23,0x24,0x26,0x27,0x25,0x28,0x29,0x2A,0x2B,0x2C,0x2D,
    0x31,0x32,0x33,0x36,0x37,0x34,0x35,0x38,0x39,0x3A,0x3B,0x3C,0x3D, 
}

local size_15 = {
    0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C, 
    0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,
    0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D, 
    0x31,0x32,0x33,0x36,0x37,0x34,0x35,0x38,0x39,0x3A,0x3B,0x3C,0x3D, 
}

function SelectCardsLayer:ctor()
    SelectCardsLayer.super.ctor(self, "pdk/res/SelectCardsLayer.csb")
    self._selectCards = {}
    self:showAllCards()
    self:addTouchEventListenerForCards(self.root)
end

function SelectCardsLayer:showAllCards()
    local data = json.decode(g_mainScene._gameConfingStr)
    local cards = {}
    self.eachSize = 16
    if data.wanfa == 1 then
        cards = clone(size_16)
    else
        cards = clone(size_15)
        self.eachSize = 15
    end
    cards = self:exchangeCardsValue(cards)
    Card:sortCard(cards)

    for i,v in ipairs(cards) do
        local card = Card:getCard(v, 1)
        local pos = self:getCardPos(i, self.eachSize)
        card:setPosition(pos)
        card:addTo(self.root)
        card:setName("selectCard"..i)
        -- card:onClick(handler(self, self.onClickCard))
        -- card:addTouchEventListener(handler(self, self.onClickCard))
    end
end

function SelectCardsLayer:getCardPos(idx, eachSize)
    local line = math.ceil(idx/eachSize)
    local index = math.mod(idx, eachSize) == 0 and eachSize or math.mod(idx, eachSize)
    local beginX = 100
    local beginY = 600
    local inter = 72
    local x = beginX+(index-1)*inter*self:_getScaleParam2()
    return cc.p(x, beginY - 210*(line - 1))
end

function SelectCardsLayer:exchangeCardsValue(cards)
    local result = {}
    for i, v in ipairs( cards or {} ) do
        local logicValue = Card:Decode(v)
        local value, color = Card:init(logicValue)
        local tmp = {[1] = value, [2] = color} 
        table.insert(result, tmp)
    end

    return clone(result)
end

function SelectCardsLayer:sortCards(a, b)
    return Card:Decode(a) > Card:Decode(b)
end

function SelectCardsLayer:onClickCard(sender, event)
    if event == TOUCH_EVENT_ENDED then
        print("onClickCard -------------- ", card.select)
        local card = sender
        if card.select and card.select == 1 then
            card.select = 0
            card:toWhite()
        else
            card.select = 1
            card:toBlack()
        end
    end
end

function  SelectCardsLayer:addTouchEventListenerForCards(plane)
    
    local selectedCardCount_ex
    local rtSelectCard
    local ptTouchBegin = cc.p(0,0)

    local _card_start_x = 0 
    local _card_start_y = 0 
    local _card_move_type = 0

    local cardTemp

    local function onTouchBegan(touch, event)
        dump(touch:getLocation(),"onTouchBegan ------------------------------- afdasdf")
        cardTemp = nil
        local beganPosition = touch:getLocation()
        local children = plane:getChildren()
        for k,v in pairs(children) do
            local locationInNode = v:convertToNodeSpace(beganPosition)

            local s = v:getContentSize()
            local rect = cc.rect(0, -25, s.width, s.height + 25)
            if  cc.rectContainsPoint(rect, locationInNode) then
                cardTemp = v
            end
                    
        end

        if cardTemp then

            require("hall.GameCommon"):playEffectSound(CLICK_CARD_VIOCE)

            _card_start_x   = cardTemp:getPositionX()  
            _card_start_y   = cardTemp:getPositionY()
            ptTouchBegin.x  = beganPosition.x
            ptTouchBegin.y  = beganPosition.y
            
            _card_move_type = 0 
            cardTemp:toBlack()

            return true
        end

        return false
    end

    local function onTouchCancell(touch, event)
        print("onTouchCancell -------------------------------")
        _card_start_x   = 0 
        _card_start_y   = 0 
        _card_move_type = 0
        rtSelectCard = nil
    end

    local function onTouchEnded(touch, event)
        print("onTouchEnded -------------------------------",_card_move_type)
        if _card_move_type == 0 then --点选
            if tolua.isnull(cardTemp)then 
                return 
            end

            cardTemp.selected = 1 - tonumber(cardTemp.selected or "0") 
            if cardTemp.selected == 1 then
                cardTemp:toBlack()
            else
                cardTemp:toWhite()
            end
            -- cardTemp:toWhite()

        elseif  _card_move_type == 1 then --拉选
            local tbCards = self:touchSelectCard(rtSelectCard)

            if tbCards then
                local tbAICards = CardsAnalysis:getSuitCardsForSelectCards(tbCards)--CardsAnalysis:getSelectCardsForSingleShunzi(tbCards)
                dump(tbAICards, "tbAICards -----------")
                if #tbAICards == 0 then
                    --拉选后弹出牌
                    for i, SelectedCardNode in ipairs(tbCards) do
                        dump(SelectedCardNode)
                        SelectedCardNode.selected = 1 - tonumber(SelectedCardNode.selected or "0")        
                    end
                    self:setCardOther(tbCards)
                else
                    for i, SelectedCardNode in ipairs(tbCards) do
                        SelectedCardNode:toWhite()  
                    end
                    --拉选后弹出牌
                    for i, SelectedCardNode in ipairs(tbAICards) do
                        dump(SelectedCardNode)
                        SelectedCardNode.selected = 1 - tonumber(SelectedCardNode.selected or "0")        
                    end
                    self:setCardOther(tbAICards)
                end
            end
            _card_move_type = 0
        end
       
        _card_start_x   = 0 
        _card_start_y   = 0 
        _card_move_type = 0

        rtSelectCard = nil

    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    -- listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener1:registerScriptHandler(onTouchCancell,cc.Handler.EVENT_TOUCH_CANCELLED )
     
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, plane)
end

function SelectCardsLayer:onClickBtnSure(sender, event)
    local child = self.root:getChildren()
    local selectCards = {}
    for i, v in ipairs(child or {}) do
        local name = v:getName()
        if string.find(name, "selectCard") and v.selected == 1 then
            table.insert(selectCards, {["card"]=v.defValue})
        end
    end
    if self.eachSize < #selectCards then
        viewMgr:showTip({text = "选的牌是数量过多"})
    end
    PDKServer:CLI_PLAYER_SELECT_CARD(#selectCards, selectCards)
    local selectCardsLayer = g_mainScene:getChildByName("selectCardsLayer")
    if selectCardsLayer then
        selectCardsLayer:removeFromParent()
    end
end

function SelectCardsLayer:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
    -- return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end

return SelectCardsLayer