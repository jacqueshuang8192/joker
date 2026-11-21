--扑克牌
------------------------------------------------------------
local PokerCard =
    class(
    'PokerCard',
    function()
        return ccui.Widget:create()
    end
)

function PokerCard:loadRes()
    local ins = cc.SpriteFrameCache:getInstance()
    local isLoad = ins:isSpriteFramesWithFileLoaded("hall/res/poker_card.plist")
    if not isLoad then
        ins:addSpriteFrames("hall/res/poker_card.plist", "hall/res/poker_card.png")
    end
end

function PokerCard:CardIdTbl()
    local cards = {
        0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0B,0x0C,0x0D,  --方块 A - K
        0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1B,0x1C,0x1D,  --梅花 A - K
        0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2a,0x2B,0x2C,0x2D,  --红桃 A - K
        0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3a,0x3B,0x3C,0x3D   --黑桃 A - K
    }
    return cards
end

function PokerCard:calcHuaSe(cardId)
    local huaSe = bit.brshift(cardId, 4)
    if huaSe > 4 then
        huaSe = huaSe - 5
    end
    return huaSe
end

function PokerCard:calcValue(cardId)
    return bit.band(cardId, 0x0f)
end

function PokerCard:calcCardId(huaSe, card_value)
    return bit.bor(bit.blshift(huaSe, 4), card_value)
end

function PokerCard:calcName(huaSe, card_value, cardId)
    if card_value == 0 then
        return 'ZERO'
    elseif huaSe >= 0 and huaSe <= 3 and card_value >= 0x1 and card_value <= 0xd then
        return self.huaSeMap[huaSe] .. self.nameMap[card_value]
    elseif card_value == 0xe then
        return '小王'
    elseif card_value == 0xf then
        return '大王'
    elseif huaSe == 4 then --癞子
        return "癞子" .. tostring(self.nameMap[card_value])
    else
        error(string.format('invalid cardId! ==> cardId:0x%02x, huaSe:%d, card_value:%d', cardId, huaSe, card_value))
    end
end

function PokerCard:ctor(scale)
    self.nameMap = {'A', 2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'k'}
    --红色：红桃 方块         黑色：梅花 黑桃
    self.huaSeMap = {[0] = '方块', [1] = '梅花', [2] = '红桃', [3] = '黑桃'}
    self.designWid, self.designHei = 138, 188 --扑克牌原始设计的宽高  138 188
    self.cardWid, self.cardHei = self.designWid * scale, self.designHei * scale
    self.size = cc.size(self.cardWid, self.cardHei)
    self.midWid, self.midHei = self.cardWid / 2, self.cardHei / 2

    self.scale_factor = scale
    self.state = 1
    self:setContentSize(cc.size(self.cardWid, self.cardHei))
    self:setCascadeColorEnabled(true)
    self:setCascadeOpacityEnabled(true)

    self:initCard()
    self:cleanCardId()
end

function PokerCard:initCard()
    self.Image_cardbg = ccui.ImageView:create()
    self.Image_cardbg:ignoreContentAdaptWithSize(false)
    self.Image_cardbg:setPosition(self.midWid, self.midHei)
    self.Image_cardbg:setContentSize(self.size)
    -- self.Image_cardbg:ignoreAnchorPointForPosition(false)
    self:addChild(self.Image_cardbg)

    self.Image_value = ccui.ImageView:create()
    self.Image_value:ignoreContentAdaptWithSize(true)
    self:addChild(self.Image_value)

    self.Image_huase1 = ccui.ImageView:create()
    self.Image_huase1:ignoreContentAdaptWithSize(true)
    self:addChild(self.Image_huase1)

    self.Image_huase2 = ccui.ImageView:create()
    self.Image_huase2:ignoreContentAdaptWithSize(true)
    self:addChild(self.Image_huase2)

    if self.scale_factor <= 0.2 then
        self.Image_value:setPosition(self.midWid, self.midHei)
        self.Image_value:setScale(1.8 * self.scale_factor)
        self.Image_huase1:setVisible(false)
        self.Image_huase2:setVisible(false)
    else
        local sc1, sc2, sc3
        if self.scale_factor <= 0.4 then
            sc1, sc2, sc3 = 0.3, 0.5, 1
            local posx = self.cardWid * 0.3
            self.huaSePos1 = cc.p(posx, self.cardHei * 0.35)
            self.huaSePos2 = cc.p(self.cardWid * 0.75, self.cardHei * 0.25)
            self.Image_value:setPosition(posx, self.cardHei * 0.7)
        elseif self.scale_factor <= 0.6 then
            sc1, sc2, sc3 = 0.3, 0.7, 0.9
            local posx = self.cardWid * 0.25
            self.huaSePos1 = cc.p(posx, self.cardHei * 0.45)
            self.huaSePos2 = cc.p(self.cardWid * 0.7, self.cardHei * 0.25)
            self.Image_value:setPosition(posx, self.cardHei * 0.75)
        else
            sc1, sc2, sc3 = 0.3, 0.7, 0.8
            local posx = self.cardWid * 0.25
            self.huaSePos1 = cc.p(posx, self.cardHei * 0.5)
            self.huaSePos2 = cc.p(self.cardWid * 0.7, self.cardHei * 0.25)
            self.Image_value:setPosition(posx, self.cardHei * 0.8)
        end

        self.huaSeSc1 = sc1 * self.scale_factor
        self.huaSeSc2 = sc2 * self.scale_factor
        self.Image_huase1:setScale(self.huaSeSc1)
        self.Image_huase2:setScale(self.huaSeSc2)
        self.Image_huase1:setPosition(self.huaSePos1)
        self.Image_huase2:setPosition(self.huaSePos2)
        self.Image_value:setScale(sc3 * self.scale_factor)
    end
end

function PokerCard:cleanCardId()
    self.huaSe = 0 --0方块, 1梅花, 2红桃, 3黑桃
    self.card_value = 0 --默认牌值
    self.card_color = 0 --1黑色：梅花1 黑桃3  2红色：方块0 红桃2
    self.color_str = "black"
    self.cardId = 0
    self.card_name = ''

    self:showBack()
end

function PokerCard:setCardId(cardId,level)
    self.cardId = cardId
    self.level = level
    self.huaSe = self:calcHuaSe(self.cardId)
    self.card_value = self:calcValue(self.cardId)

    if self.huaSe == 0 or self.huaSe == 2 then
        self.card_color = 2
        self.color_str = "red"
    else
        self.card_color = 1
        self.color_str = "black"
    end

    if level == 374 and cardId == 95 then
        self.huaSe = 5
    end

    self.card_name = self:calcName(self.huaSe, self.card_value, self.cardId)
end

function PokerCard:showBack()
    if self.labellaizi then
        self.labellaizi:setVisible(false)
    end

    self.Image_value:setVisible(false)
    self.Image_huase1:setVisible(false)
    self.Image_huase2:setVisible(false)
    self.Image_cardbg:setVisible(true)
    self.Image_cardbg:loadTexture('poker_card_back.png', 1)
end

function PokerCard:showFront()
    if self.labellaizi then
        self.labellaizi:setVisible(false)
    end

    if self.card_value < 1 or self.card_value > 0xf then
        self:showBack()
    else
        self.Image_cardbg:setVisible(true)
        if self.card_value == 0xe then --'小王'
            self.Image_cardbg:loadTexture('poker_card_small_king.png', 1)
            if self.huaSe == 5 then
                local object  = display.newSprite("hall/res/PokerCard/binwan.png")
                object:setScale(0.24)
                object:setPosition(self.Image_cardbg:getContentSize().width/2,self.Image_cardbg:getContentSize().height/2)
		        object:addTo(self.Image_cardbg)
            end
            self.Image_value:setVisible(false)
            self.Image_huase1:setVisible(false)
            self.Image_huase2:setVisible(false)
        elseif self.card_value == 0xf then --'大王'
            self.Image_cardbg:loadTexture('poker_card_big_king.png', 1)
            if self.huaSe == 5 then
                local object  = display.newSprite("hall/res/PokerCard/binwan.png")
                object:setScale(0.24)
                object:setPosition(self.Image_cardbg:getContentSize().width/2,self.Image_cardbg:getContentSize().height/2)
		        object:addTo(self.Image_cardbg)
            end
            self.Image_value:setVisible(false)
            self.Image_huase1:setVisible(false)
            self.Image_huase2:setVisible(false)
        else
            self.Image_cardbg:loadTexture('poker_card_front.png', 1)
            local str = string.format('poker_card_%s_%d.png', self.color_str, self.card_value)
            self.Image_value:loadTexture(str, 1)
            self.Image_value:setVisible(true)

            if self.scale_factor <= 0.2 then
                self.Image_huase1:setVisible(false)
                self.Image_huase2:setVisible(false)
            else
                if self.huaSe == 4 then --癞子
                    if self.labellaizi == nil then
                        self.labellaizi = cc.Label:createWithTTF("癞", "hall/res/font/fzcs.ttf", 120)
                        self.labellaizi:setPosition(self.huaSePos1)
                        self.labellaizi:setScale(self.huaSeSc1)
                        self.labellaizi:setColor(cc.c3b(0xCF, 0xB5, 0x3B))
                        self:addChild(self.labellaizi)
                    end
                    self.Image_huase1:setVisible(false)
                    self.Image_huase2:setVisible(false)
                    self.labellaizi:setVisible(true)
                else
                    str = string.format('poker_card_huase_%d.png', self.huaSe)
                    self.Image_huase1:loadTexture(str, 1)
                    self.Image_huase2:loadTexture(str, 1)
                    self.Image_huase1:setVisible(true)
                    self.Image_huase2:setVisible(true)
                end
            end
        end
    end
end

function PokerCard:getCardId()
    return self.cardId
end

function PokerCard:getHuaSe()
    return self.huaSe
end

function PokerCard:getCardValue()
    return self.card_value
end

--1黑色：梅花1 黑桃3  2红色：方块0 红桃2
function PokerCard:getCardColor()
    return self.card_color
end

function PokerCard:getCardName()
    return self.card_name
end

function PokerCard:printMe()
    local str =
        'cardId:' ..
        string.format('0x%02x', self.cardId) ..
            '\thuaSe:' .. self.huaSe .. '\tcard_value: ' .. self.card_value .. '\t' .. self.card_name
    print(str)
end

function PokerCard:bindTouch(touch_fun)
    self:setTouchEnabled(true)
    self:setSwallowTouches(true)
    self.touch_fun = touch_fun
    self:addTouchEventListener(handler(self, self.onTouch))
end

function PokerCard:onTouch(sender, event)
    if event == TOUCH_EVENT_BEGAN then
        self.touchStartPos = cc.p(self:getPosition())
    elseif event == TOUCH_EVENT_MOVED then
        local delta = cc.pSub(sender:getTouchMovePosition(), sender:getTouchBeganPosition())
        local dstPos = cc.pAdd(self.touchStartPos, delta)
        self:setPosition(dstPos)
    elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
        local delta = cc.pSub(sender:getTouchEndPosition(), sender:getTouchBeganPosition())
        local endPos = cc.pAdd(self.touchStartPos, delta)
        self:setPosition(dstPos)
    end

    if self.touch_fun then
        self.touch_fun(sender, event)
    end
end

return PokerCard
