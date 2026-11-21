local CARD_WIDTH = 233
local CARD_HEIGHT = 315
local CARD_BACK_WIDTH = 233
local CARD_BACK_HEIGHT = 315

VARIETY_DIAMOND = 0x00 -- 方块
VARIETY_CLUB = 0x10 -- 梅花
VARIETY_HEART = 0x20 -- 红桃
VARIETY_SPADE = 0x30 -- 黑桃
VARIETY_LAIZI = 0x40 -- 癞子

local pai_path = TpackageName .. '/csb/PokerCard/' --newcard
local PokerCardCsb = TpackageName .. '/csb/PokerCard/PokerCard.csb'
local Card_back_img_table = {
    [5] = TpackageName .. '/csb/PokerCard/card_back.png'
}
local Card_back_img_size_table = {
    [1] = {width = 300, height = 458},
    [2] = {width = 300, height = 458},
    [3] = {width = 300, height = 458},
    [4] = {width = 300, height = 458},
    [5] = {width = 233, height = 315},
    [6] = {width = 300, height = 458}
}

local Shuffling_card_path = TpackageName .. '/csb/LayerShuffling/' --newcard

local CARD_VARIETY_TRANSFORM_PATH = {
    [VARIETY_DIAMOND] = Shuffling_card_path .. 'diamonds_',
    [VARIETY_CLUB] = Shuffling_card_path .. 'clubs_',
    [VARIETY_HEART] = Shuffling_card_path .. 'hearts_',
    [VARIETY_SPADE] = Shuffling_card_path .. 'spades_',
    [VARIETY_LAIZI] = Shuffling_card_path .. 'laizi_'
}

-- 获得花色
local function getVariety(card)
    return bit.band(card, 0xF0)
end

-- 获得牌值
local function getValue(card)
    local value = bit.band(card, 0x0F)
    if value == 1 then
        value = 14
    end
    return value
end

local PokerCard =
    class(
    'PokerCard',
    function()
        return display.newSprite()
    end
)

function PokerCard:ctor()
    self:setNodeEventEnabled(true)
    -- 初始数值
    self.isBack_ = true
    -- 牌背
    self.backBg_ = ccui.ImageView:create(Card_back_img_table[CURRENTCARDBACKINDEX], 1):addTo(self)
    self.backBg_:setAnchorPoint(cc.p(0.5, 0))
    self.cardUint_ = 1
end

function PokerCard:getSingleCardBackPath()
    return Card_back_img_table[CURRENTCARDBACKINDEX], Card_back_img_size_table[CURRENTCARDBACKINDEX]
end

function PokerCard:getCardPath(cardUint)
    local cardPath = ''
    if cardUint == 0x4e or cardUint == 0x4f then
        if cardUint == 0x4e then
            cardPath = Shuffling_card_path .. 'small_king.png'
        else
            cardPath = Shuffling_card_path .. 'big_king.png'
        end
    else
        local cardValue_ = getValue(cardUint)
        local cardVariety_ = getVariety(cardUint)

        if cardValue_ >= 2 and cardValue_ < 10 then
            cardPath = CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)] .. '0' .. cardValue_ .. '.png'
        else
            cardPath = CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)] .. cardValue_ .. '.png'
        end
    end

    return cardPath
end

function PokerCard:hasValue()
    return self.font_pai_ and true or false
end

function PokerCard:createSingleCard(cardUint)
    local cardUint_ = cardUint or 1
    local cardPath = ''
    if cardUint == 0x4e or cardUint == 0x4f then
        if cardUint == 0x4e then
            cardPath = Shuffling_card_path .. 'small_king.png'
        else
            cardPath = Shuffling_card_path .. 'big_king.png'
        end
    else
        local cardValue_ = getValue(cardUint)
        local cardVariety_ = getVariety(cardUint)
        if cardValue_ >= 2 and cardValue_ < 10 then
            cardPath = CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)] .. '0' .. cardValue_ .. '.png'
        else
            cardPath = CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)] .. cardValue_ .. '.png'
        end
    end
    local ImageView = ccui.ImageView:create(cardPath, 0)
    return ImageView
end

function PokerCard:setCuoCard(cardNode, cardUint, isBack)
    if cardNode == nil then
        cardNode = display.newNode()
    end
    cardNode.backBg_ = ccui.ImageView:create(Card_back_img, 1):addTo(cardNode)
    cardNode.backBg_:setContentSize(cc.size(300, 458))
    cardNode.backBg_:setAnchorPoint(cc.p(0, 0))
    if isBack == true then
        cardNode.backBg_:setVisible(true)
        return
    else
        cardNode.backBg_:setVisible(false)
    end
    local cardUint_ = cardUint or 1
    local cardPath = ''
    if cardUint == 0x4e or cardUint == 0x4f then
        if cardUint == 0x4e then
            cardPath = Shuffling_card_path .. 'small_king.png'
        else
            cardPath = Shuffling_card_path .. 'big_king.png'
        end
    else
        local cardValue_ = getValue(cardUint)
        local cardVariety_ = getVariety(cardUint)

        if cardValue_ >= 2 and cardValue_ < 10 then
            cardPath = CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)] .. '0' .. cardValue_ .. '.png'
        else
            cardPath = CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)] .. cardValue_ .. '.png'
        end
    end
    local ImageView = ccui.ImageView:create(cardPath, 0):addTo(cardNode)
    cardNode.font_pai_ = ImageView
    cardNode.font_pai_:setVisible(true)
    cardNode.font_pai_:setAnchorPoint(cc.p(0, 0))
    return cardNode
end

-- 设置扑克牌面,拼接方式生成
function PokerCard:setCard(cardUint)
    if cardUint == nil or cardUint == 0 then
        return
    end

    self.cardUint_ = cardUint or 1
    -- 获取值与花色
    self.cardValue_ = getValue(self.cardUint_)
    self.cardVariety_ = getVariety(self.cardUint_)
    if self.font_pai_ then
        self.font_pai_:removeFromParent()
    end
    local csbPath = nil
    if cardUint > 0x40 then
        if cardUint == 0x4e or cardUint == 0x4f then
            csbPath = TpackageName .. '/csb/PokerCard/PokerCardJoke.csb'
        else
            csbPath = TpackageName .. '/csb/PokerCard/LaiZiCrad.csb'
        end
    else
        csbPath = TpackageName .. '/csb/PokerCard/PokerCard.csb'
    end

    self.font_pai_ = cc.CSLoader:createNode(csbPath):addTo(self)
    GameUtils.setNodeNameBindObj(self.font_pai_)
    local cardValue_iv = self.font_pai_:getChildByName('cardValue_iv')
    local cardVarietySmall_iv = self.font_pai_:getChildByName('cardVarietySmall_iv')
    local cardVariety_iv = self.font_pai_:getChildByName('cardVariety_iv')
    local cardVariety_lai = self.font_pai_:getChildByName('cardVariety_lai')
    local cardVariety_niu = self.font_pai_:getChildByName('cardVariety_niu')
    if self.cardVariety_ == VARIETY_DIAMOND then -- 方块
        cardValue_iv:loadTexture(pai_path .. 'red_' .. tostring(self.cardValue_) .. '.png', 1)
        cardVarietySmall_iv:loadTexture(pai_path .. 'diamonds.png', 1)
        cardVariety_iv:loadTexture(pai_path .. 'diamonds.png', 1)
    elseif self.cardVariety_ == VARIETY_CLUB then -- 梅花
        cardValue_iv:loadTexture(pai_path .. 'black_' .. tostring(self.cardValue_, 1) .. '.png', 1)
        cardVarietySmall_iv:loadTexture(pai_path .. 'clubs.png', 1)
        cardVariety_iv:loadTexture(pai_path .. 'clubs.png', 1)
    elseif self.cardVariety_ == VARIETY_HEART then -- 红桃
        cardValue_iv:loadTexture(pai_path .. 'red_' .. tostring(self.cardValue_, 1) .. '.png', 1)
        cardVarietySmall_iv:loadTexture(pai_path .. 'hearts.png', 1)
        cardVariety_iv:loadTexture(pai_path .. 'hearts.png', 1)
    elseif self.cardVariety_ == VARIETY_SPADE then -- 黑桃
        cardValue_iv:loadTexture(pai_path .. 'black_' .. tostring(self.cardValue_, 1) .. '.png', 1)
        cardVarietySmall_iv:loadTexture(pai_path .. 'spades.png', 1)
        cardVariety_iv:loadTexture(pai_path .. 'spades.png', 1)
    elseif self.cardVariety_ == VARIETY_LAIZI then --  癞子
        if cardUint == 0x4e or cardUint == 0x4f then
            local pathValue = self.cardUint_ == 0x4f and 'big_king.png' or 'small_king.png'
            local pathColor = self.cardUint_ == 0x4f and 'big_color.png' or 'small_color.png'
            cardValue_iv:loadTexture(pai_path .. pathValue, 0)
            cardValue_iv:setPosition(cc.p(26, 244))
            cardValue_iv:setScale(1.2)
            cardVarietySmall_iv:setVisible(false)
            cardVariety_iv:loadTexture(pai_path .. pathColor, 0)
            cardVariety_iv:setPosition(cc.p(46, 262))
            cardVariety_iv:setScale(0.8)
        else
            cardValue_iv:loadTexture(pai_path .. 'black_' .. tostring(self.cardValue_, 1) .. '.png', 1)
        end
    end
    self.font_pai_:setAnchorPoint(cc.p(0.5, 0))
    self.font_pai_:setTouchEnabled(false)
    return self
end

function PokerCard:flipCard()

    self.isBack_ = false
    local cardFace = self.font_pai_
    local cardBack = self.backBg_
    do
        cardBack:setVisible(false)
        cardFace:setVisible(true)
        return
    end

    -- -- 正反面旋转
    -- local aniTime = 0.25
    -- self:runAction(cc.Sequence:create(
    -- cc.CallFunc:create(
    --     function (sender)
    --         cardFace:setVisible(false)
    --         cardBack:setVisible(true)
    --         cardBack:runAction(cc.OrbitCamera:create(aniTime, 1, 0, 0, 90, 0, 0) )
    --     end),
    -- -- cc.DelayTime:create(aniTime),
    -- cc.CallFunc:create(
    --     function (sender)
    --         cardFace:setVisible(true)
    --         cardBack:setVisible(false)
    --         cardFace:runAction( cc.OrbitCamera:create(aniTime, 1, 0, 270, 90, 0, 0) )
    --         -- cardBack:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
    --     end)
    -- ))

    local to_a = cc.ScaleTo:create(0.1, 0.1, 1)
    local call_f =
    cc.CallFunc:create(
            function()
                if not tolua.isnull(cardBack) and not tolua.isnull(cardFace) then
                    cardBack:setVisible(false)
                    cardFace:setVisible(true)
                end
            end
    )
    local to_b = cc.ScaleTo:create(0.1, 1, 1)
    local seqP2 = cc.Sequence:create(to_a, call_f, to_b)
    cardBack:setVisible(true)
    cardFace:setVisible(false)
    self:runAction(seqP2)
end

-- 显示正面
function PokerCard:showFront(show_logo)
    self.isBack_ = false
    self.backBg_:setVisible(false)
    if self.font_pai_ then
        self.font_pai_:setVisible(true)
    end
    if show_logo then
        local spLogo = self:getLogo(true)
        if spLogo then
            spLogo:setAnchorPoint(cc.p(1, 1))
            self.font_pai_:addChild(spLogo)
            local cardSize = self.font_pai_:getContentSize()
            local x = cardSize.width
            local y = cardSize.height
            spLogo:setPosition(cc.p(x + 5, y + 5))
        end
    end
    return self
end

--地主logo
function PokerCard:getLogo(flag)
    local spBack = display.newSprite(TpackageName .. '/images/5th.png')
    return spBack
end

function PokerCard:set_font_pai_color(color)
    if self.font_pai_ then
        self.font_pai_:setColor(color)
    end
    return self
end

-- 显示背面
function PokerCard:showBack()
    self.isBack_ = true
    if self.font_pai_ then
        self.font_pai_:setVisible(false)
    end
    if self.backBg_ then
        self.backBg_:setVisible(true)
    end
    return self
end

function PokerCard:isBack()
    return self.isBack_
end

function PokerCard:onExit()

end

function PokerCard:getCardSize()
    return self.font_pai_:getContentSize()
end
return PokerCard
