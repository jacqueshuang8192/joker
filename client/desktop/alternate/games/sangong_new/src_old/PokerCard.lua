local CARD_WIDTH = 233
local CARD_HEIGHT = 315

local CARD_BACK_WIDTH = 233
local CARD_BACK_HEIGHT = 315

VARIETY_DIAMOND = 0x00 -- 方块
VARIETY_CLUB = 0x10 -- 梅花
VARIETY_HEART = 0x20 -- 红桃
VARIETY_SPADE = 0x30 -- 黑桃

local pai_path = TpackageName .. '/csb/PokerCard/' --newcard
local PokerCardCsb = TpackageName .. '/csb/PokerCard/PokerCard.csb'
local Card_back_img_table = {
    [1] = TpackageName .. '/images/pieces_card/card_back_2.png',
    [2] = TpackageName .. '/images/pieces_card/card_back_3.png',
    [3] = TpackageName .. '/images/pieces_card/card_back_4.png',
    [4] = TpackageName .. '/images/pieces_card/card_back_5.png',
    -- [5] = TpackageName .. "/images/pieces_card/card_back.png",
    [5] = TpackageName .. '/csb/PokerCard/card_back.png',
    [6] = TpackageName .. '/images/pieces_card/cuo_card_back.png'
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
    [VARIETY_SPADE] = Shuffling_card_path .. 'spades_'
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
    -- 初始数值
    self._isBack = true
    -- 牌背

    self.backBg_ = ccui.ImageView:create(Card_back_img_table[CURRENTCARDBACKINDEX], 1):addTo(self)

    self.backBg_:setAnchorPoint(cc.p(0.5, 0))
    self.cardUint_ = 1
end

function PokerCard:getSingleCardBackPath()
    return Card_back_img_table[CURRENTCARDBACKINDEX], Card_back_img_size_table[CURRENTCARDBACKINDEX]
end

function PokerCard:getCardBackAndSizeTable()
    return Card_back_img_table, Card_back_img_size_table
end

function PokerCard:getCardPath(cardUint)
    local cardValue_ = getValue(cardUint)
    local cardVariety_ = getVariety(cardUint)

    if cardValue_ >= 2 and cardValue_ < 10 then
        cardPath = CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)] .. '0' .. cardValue_ .. '.png'
    else
        cardPath = CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)] .. cardValue_ .. '.png'
    end

    return cardPath
end

function PokerCard:hasValue()
    return self.font_pai_ and true or false
end

function PokerCard:createSingleCard(cardUint)
    local cardUint_ = cardUint or 1

    -- 获取值与花色
    local cardValue_ = getValue(cardUint_)
    local cardVariety_ = getVariety(cardUint_)

    if cardValue_ >= 2 and cardValue_ < 10 then
        cardPath = CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)] .. '0' .. cardValue_ .. '.png'
    else
        cardPath = CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)] .. cardValue_ .. '.png'
    end
    local s = ccui.ImageView:create(cardPath, 0)
    return s
end

function PokerCard:setCuoCard(cardNode, cardUint, isBack)
    if cardNode == nil then
        cardNode = display.newNode()
    end

    cardNode.backBg_ = ccui.ImageView:create(Card_back_img, 0):addTo(cardNode)
    cardNode.backBg_:setContentSize(cc.size(300, 458))
    cardNode.backBg_:setAnchorPoint(cc.p(0, 0))

    if isBack == true then
        cardNode.backBg_:setVisible(true)
        return
    else
        cardNode.backBg_:setVisible(false)
    end

    local cardUint_ = cardUint or 1

    -- 获取值与花色
    local cardValue_ = getValue(cardUint_)
    local cardVariety_ = getVariety(cardUint_)

    if cardValue_ >= 2 and cardValue_ < 10 then
        cardPath = CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)] .. '0' .. cardValue_ .. '.png'
    else
        cardPath = CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)] .. cardValue_ .. '.png'
    end

    local s = ccui.ImageView:create(cardPath, 0):addTo(cardNode)
    cardNode.font_pai_ = s
    cardNode.font_pai_:setVisible(true)
    cardNode.font_pai_:setAnchorPoint(cc.p(0, 0))

    return cardNode
end

-- 设置扑克牌面,拼接方式生成
function PokerCard:setCard(cardUint)
    self.cardUint_ = cardUint or 1

    -- 获取值与花色
    self.cardValue_ = getValue(self.cardUint_)
    self.cardVariety_ = getVariety(self.cardUint_)

    if self.font_pai_ then
        self.font_pai_:removeFromParent()
    end

    self.font_pai_ = cc.CSLoader:createNode(PokerCardCsb):addTo(self)
    GameUtils.setNodeNameBindObj(self.font_pai_)

    local cardValue_iv = self.font_pai_:getChildByName('cardValue_iv')
    local cardVarietySmall_iv = self.font_pai_:getChildByName('cardVarietySmall_iv')
    local cardVariety_iv = self.font_pai_:getChildByName('cardVariety_iv')

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
    end

    self.font_pai_:setAnchorPoint(cc.p(0.5, 0))
    self.font_pai_:setTouchEnabled(false)

    return self
end

function PokerCard:flipCard()
    self:showFront()
    if 1 then
        return
    end
    if not self.font_pai_ then
        return
    end
    self._isBack = false

    local cardFace = self.font_pai_
    local cardBack = self.backBg_
    local aniTime = 0.15
    local to_p1 = cc.RotateBy:create(0, cc.vec3(0, 90, 0))
    cardFace:runAction(to_p1)
    -- SCENENOW["scene"]:performWithDelay(function()

    local to_B = cc.RotateBy:create(aniTime, cc.vec3(0, -90, 0))
    cardBack:runAction(to_B)
    cardBack:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(aniTime - aniTime / 100),
            cc.CallFunc:create(
                function()
                    if cardBack and self.font_pai_ then
                        cardBack:setVisible(false)
                        self.font_pai_:setVisible(true)
                    end
                end
            )
        )
    )

    local de = cc.DelayTime:create(aniTime)
    local to_p2 = cc.RotateBy:create(aniTime, cc.vec3(0, -90, 0))
    local seqP2 = cc.Sequence:create(de, to_p2)
    cardFace:runAction(seqP2)
end

-- 显示正面
function PokerCard:showFront()
    self._isBack = false
    self.backBg_:setVisible(false)

    if self.font_pai_ then
        self.font_pai_:setVisible(true)
    end

    return self
end

-- 显示背面
function PokerCard:showBack()
    self._isBack = true

    if self.font_pai_ then
        self.font_pai_:setVisible(false)
    end

    if self.backBg_ then
        self.backBg_:setVisible(true)
    end

    return self
end

function PokerCard:isBack()
    return self._isBack
end

function PokerCard:getCardSize()
    return self.font_pai_:getContentSize()
end

return PokerCard
