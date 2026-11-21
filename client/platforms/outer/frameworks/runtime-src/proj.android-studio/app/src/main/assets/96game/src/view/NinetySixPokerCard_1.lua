--扑克牌视图
------------------------------------------------------------

local NinetySixPokerCard =
    class(
    "NinetySixPokerCard",
    function()
        return ccui.Widget:create()
    end
)

function NinetySixPokerCard:ctor(handcards, parent, scale)
    self.nameMap = {"A", 2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "k"}
    --红色：红桃 方块         黑色：梅花 黑桃
    self.huaSeMap = {[0] = "方块", [1] = "梅花", [2] = "红桃", [3] = "黑桃"}
    self.designWid, self.designHei = 138, 188 --扑克牌原始设计的宽高  138 188
    self.cardWid, self.cardHei = self.designWid * scale, self.designHei * scale
    
    self.handcards = handcards
    self.logic = handcards.logic
    self.ctrl = handcards.ctrl
    self.scene = handcards.scene
    self.scale_factor = scale
    self.parent = parent
    if self.parent then
        self.parent:addChild(self)
    end
    self:setContentSize(cc.size(self.cardWid, self.cardHei))
    self:setCascadeColorEnabled(true)
    self:setCascadeOpacityEnabled(true)

    self.posX = 0
    self.posY = 0
    self.scale = 1
    self.rotate = 0
    self.pos_idx = 0

    self.state = 1
    self.chairId = 0

    self:initCard()
    self:cleanCardId()
end

function NinetySixPokerCard:calcHuaSe(cardId)
    local huaSe = bit.brshift(cardId, 4)
    if huaSe > 4 then
        huaSe = huaSe - 5
    end
    return huaSe
end

function NinetySixPokerCard:calcValue(cardId)
    return bit.band(cardId, 0x0f)
end

function NinetySixPokerCard:calcCardId(huaSe, card_value)
    return bit.bor(bit.blshift(huaSe, 4), card_value)
end

function NinetySixPokerCard:calcName(huaSe, card_value, cardId)
    if card_value == 0 then
        return "ZERO"
    elseif huaSe >= 0 and huaSe <= 3 and card_value >= 0x1 and card_value <= 0xd then
        return self.huaSeMap[huaSe] .. self.nameMap[card_value]
    elseif card_value == 0xe then
        return "小王"
    elseif card_value == 0xf then
        return "大王"
    else
        error(string.format("invalid cardId! ==> cardId:0x%02x, huaSe:%d, card_value:%d", cardId, huaSe, card_value))
    end
end

function NinetySixPokerCard:bindTouch()
    self:setTouchEnabled(true)
    self:setSwallowTouches(true)
    self:addTouchEventListener(handler(self, self.onTouch))
end

function NinetySixPokerCard:onTouch(sender, event)
    if event == TOUCH_EVENT_BEGAN then
        self:setLocalZOrder(30)
        self.touchStartPos = cc.p(self:getPosition())
        self.scene:showTingCards(self.tingCards)
    elseif event == TOUCH_EVENT_MOVED then
        local delta = cc.pSub(sender:getTouchMovePosition(), sender:getTouchBeganPosition())
        local dstPos = cc.pAdd(self.touchStartPos, delta)
        if delta.y > 25 then
            --self.scene:hideTingCards()
        end
        self:setPosition(dstPos)
    elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
        local delta = cc.pSub(sender:getTouchEndPosition(), sender:getTouchBeganPosition())
        local endPos = cc.pAdd(self.touchStartPos, delta)
        
        if not self.handcards:checkOutCard(self, endPos) then
            self.handcards:pokerMove(self, endPos)
        end
    end
end

function NinetySixPokerCard:getCardId()
    return self.cardId
end

function NinetySixPokerCard:getHuaSe()
    return self.huaSe
end

function NinetySixPokerCard:getCardValue()
    return self.card_value
end

--1黑色：梅花1 黑桃3  2红色：方块0 红桃2   
function NinetySixPokerCard:getCardColor()
    return self.card_color
end

function NinetySixPokerCard:getCardName()
    return self.card_name
end

function NinetySixPokerCard:getIcon()
    return self.res_icon
end

function NinetySixPokerCard:printMe()
    local str = "cardId:" .. string.format("0x%02x", self.cardId) .. "\thuaSe:" .. self.huaSe .. "\tcard_value: " .. self.card_value .. "\t" .. self.card_name
    print(str)
end

function NinetySixPokerCard:initCard()
    self.cardPic = ccui.ImageView:create()
    self.cardPic:ignoreContentAdaptWithSize(false)
    self.cardPic:setPosition(self.cardWid / 2, self.cardHei / 2)
    self.cardPic:setContentSize(cc.size(self.cardWid, self.cardHei))
    -- self.cardPic:ignoreAnchorPointForPosition(false)
    self:addChild(self.cardPic)
end

function NinetySixPokerCard:setPokerColor(color)
    self.cardPic:setColor(color)
end

function NinetySixPokerCard:showLight(light)
    if self.card_light == nil then
        self.card_light = ccui.ImageView:create()
        self.card_light:ignoreContentAdaptWithSize(false)
        self.card_light:setPosition(self.cardWid / 2, self.cardHei / 2)
        self.card_light:setScale9Enabled(true)
        self.card_light:setCapInsets(cc.rect(12, 12, 138, 188))
        self.card_light:setContentSize(cc.size(self.cardWid + 12, self.cardHei + 12))
        -- self.card_light:ignoreAnchorPointForPosition(false)
        self:addChild(self.card_light)
    end

    local res = "ninetysix_poker_cardlightBG1.png"
    if light == 2 then --162, 212;  138 188
        res = "ninetysix_poker_cardlightBG2.png"
    end
    self.card_light:loadTexture(res, 1)
    self.card_light:setVisible(true)
end

function NinetySixPokerCard:showHu()
    if self.imgage_hu == nil then
        self.imgage_hu = ccui.ImageView:create("ninetysix_poker_hu.png", 1)
        self.imgage_hu:setAnchorPoint(cc.p(1, 0))
        self.imgage_hu:setPosition(self.cardWid, 0)
        self.imgage_hu:setScale(self.scale_factor)
        self:addChild(self.imgage_hu)
    end
    self.imgage_hu:setVisible(true)
end

function NinetySixPokerCard:hideHu()
    if self.imgage_hu then
        self.imgage_hu:setVisible(false)
    end
end

function NinetySixPokerCard:showTingFlag()
    if self.imgage_ting == nil then
        self.imgage_ting = ccui.ImageView:create("ninetysix_poker_ting.png", 1)
        self.imgage_ting:setAnchorPoint(cc.p(0.5, 1))
        self.imgage_ting:setPosition(self.cardWid / 2, self.cardHei)
        self.imgage_ting:setScale(self.scale_factor)
        self:addChild(self.imgage_ting)
    end
    self.imgage_ting:setVisible(true)
end

function NinetySixPokerCard:hideTingFlag()
    if self.imgage_ting then
        self.imgage_ting:setVisible(false)
    end
end

function NinetySixPokerCard:setTingCards(cards)
    self.tingCards = cards
    if self.tingCards and #self.tingCards > 0 then
        self:showTingFlag()
    else
        self:hideTingFlag()
    end
end

function NinetySixPokerCard:cleanCardId()
    self.huaSe = 0 --0方块, 1梅花, 2红桃, 3黑桃
    self.card_value = 0 --默认牌值
    self.card_color = 0 --1黑色：梅花1 黑桃3  2红色：方块0 红桃2         

    self.cardId = 0
    self.res_icon = "poker_card_back.png"
    self.card_name = ""

    if self.card_light then
        self.card_light:setVisible(false)
    end

    if self.imgage_hu then
        self.imgage_hu:setVisible(false)
    end
end

function NinetySixPokerCard:setCardId(cardId)
    self.cardId = cardId
    self.huaSe = self:calcHuaSe(self.cardId)
    self.card_value = self:calcValue(self.cardId)

    if self.huaSe == 0 or self.huaSe == 2 then
        self.card_color = 2
    else
        self.card_color = 1
    end

    self.card_name = self:calcName(self.huaSe, self.card_value, self.cardId)
    if self.card_value < 1 or self.card_value > 0x0D then
        self.res_icon = "poker_card_back.png"
    else
        self.res_icon = string.format("poker_card_%d_%d.png", self.huaSe, self.card_value)
    end
end

function NinetySixPokerCard:setPosIdx(idx, ani, delay)
    self.pos_idx = idx
    local info = self.handcards:getPosByIdx(idx)
    self:stopAllActions()
    if ani then 
        local cbAction =
            cc.CallFunc:create(
            function()
                self:setLocalZOrder(info.zoder)
            end
        )
        
        if delay then --发牌动画
            self:setScale(0.1)
            local function doCall()
                self:setState(2)
            end

            local a1 = cc.DelayTime:create(delay)
            local a3 = cc.MoveTo:create(0.2, info.pos)
            local a4 = cc.ScaleTo:create(0.2, 1)
            local spaw = cc.Spawn:create(a3, a4)
            local cbAction2 = cc.CallFunc:create(doCall)

            self:runAction(cc.Sequence:create(a1, spaw, cbAction2, cbAction))
        else
            self:setScale(1)
            self:setOpacity(255)
            local moveAction = cc.MoveTo:create(0.1, info.pos)
            self:runAction(cc.Sequence:create(moveAction, cbAction))
        end
    else
        self:setScale(1)
        self:setOpacity(255)
        self:setPosition(info.pos)
        self:setLocalZOrder(info.zoder)
    end
end

--两种状态 1显示背牌， 2显示明牌
function NinetySixPokerCard:setState(state)
    self.state = state

    local str = "poker_card_back.png" --默认暗牌
    if self.state == 2 then --明牌
        str = self.res_icon
    end

    -- str = "96game/res/poker/" .. str
    self.cardPic:loadTexture(str, 1)
end
function NinetySixPokerCard:onOutCard()
    self.touchStartPos = cc.p(self:getPosition())
    local delta = cc.pSub(self:getTouchEndPosition(), self:getTouchBeganPosition())
    local endPos = cc.pAdd(self.touchStartPos, delta)
    self.handcards:pokerMoveTest(self, endPos)
end

return NinetySixPokerCard
