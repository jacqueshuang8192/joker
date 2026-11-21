-- local CARD_WIDTH      = 233
-- local CARD_HEIGHT     = 313
local CardUtils = require(TpackageName..".CardUtils")
local CARD_WIDTH      = 233
local CARD_HEIGHT     = 315

local CARD_BACK_WIDTH      = 233
local CARD_BACK_HEIGHT     = 315

VARIETY_DIAMOND = 0x00 -- 方块
VARIETY_CLUB    = 0x10 -- 梅花
VARIETY_HEART   = 0x20 -- 红桃
VARIETY_SPADE   = 0x30 -- 黑桃
-- 0x4E 0x4f 大小鬼牌
local pai_path = TpackageName .. "/res/layout/PokerCard/"  --newcard
local PokerCardCsb = TpackageName .. "/res/layout/PokerCard/PokerCard.csb"
local ShiSanZhangConfig = require(TpackageName..".config.ShiSanZhangConfig")


local Shuffling_card_path = TpackageName .. "/res/layout/LayerShuffling/"  --newcard

local CARD_VARIETY_TRANSFORM_PATH = 
{
    [VARIETY_DIAMOND] =Shuffling_card_path.. "diamonds_",
    [VARIETY_CLUB] = Shuffling_card_path.."clubs_",
    [VARIETY_HEART] = Shuffling_card_path.."hearts_",
    [VARIETY_SPADE] = Shuffling_card_path.."spades_",
}

-- 获得花色
local function getVariety(card)
    return bit.band(card, 0xF0)
end

-- 获得牌值
local function getValue(card)
    local value = bit.band(card, 0x0F)
    if value == 14 then
        value = 20--小王
    elseif value == 15 then
        value = 21-- 大王
    end
    if value == 1 then
        value = 14
    end
    return value
end


local PokerCard = class("PokerCard", cc.Component)

function PokerCard:ctor()
    PokerCard.super.ctor(self, "PokerCard")
end

function PokerCard:initUI(node)
   
    -- if not node then
    --     node = cc.CSLoader:createNode(PokerCardCsb):addTo(self)
    --     GameUtils.setNodeNameBindObj(node)
    -- else
    -- end
    -- 初始数值
    self.isBack_ = true
    self.cardUint_ = 1
    self.font_pai_ = node.card_blank:hide()
    self.backBg_ = node.card_back:show()
    self.mask = node.mask:hide()
    self.maNode = self.font_pai_.ma:hide()
    -- dump(self)
    -- self:setContentSize(self.backBg_:getContentSize())
end

function PokerCard:getCardSize()
    return self.backBg_:getContentSize()
end

function PokerCard:hasValue()
    return self.font_pai_ and true or false
end

-- 设置扑克牌面,拼接方式生成
function PokerCard:setCard(data)
    dump(data,"PokerCard3:setCard-->>")
    local cardUint = 1
    local sd = type(data)
    if type(data) == "table" then
        if data.isKing >= 78 then
            local card1 = CardUtils:getClientCardByServerCard({data.card})[1]
            local card2 = CardUtils:getClientCardByServerCard({data.isKing})[1]
            card2.changeColor = card1.color
            card2.scores = card1.number
            self:setGuiCard(card2)
            return
        else
            cardUint = data.card
        end
    else
        cardUint = data
    end
    self.cardUint_ = cardUint or 1
    if MA_CARD == cardUint then
        self.maNode:setVisible(true)
    else
        self.maNode:setVisible(false)
    end
    -- 获取值与花色
    self.cardValue_ = getValue(self.cardUint_)
    self.cardVariety_ = getVariety(self.cardUint_)

    dump(self.cardValue_,"self.cardValue_")
    dump(self.cardVariety_,"self.cardVariety_")

    local value = self.font_pai_:getChildByName("value")
    local color_1 = self.font_pai_:getChildByName("color_1")
    local color_2 = self.font_pai_:getChildByName("color_2")
    if self.cardValue_ >= 20 then
        local tab = {
            [20] = 1,
            [21] = 2,
        }
        local king = tab[self.cardValue_]
        color_1:hide()
        value:loadTexture(pai_path .. "color_" .. king .. ".png", 1)
        color_2:loadTexture(pai_path .. "color_king_" .. king .. ".png", 1)

        value:show()
        color_2:show()
    else
        value:show()
        color_1:show()
        color_2:show()
        
        self.font_pai_:loadTexture(pai_path .."card_front.png", 1)
        if self.cardVariety_ == VARIETY_DIAMOND then -- 方块
            value:loadTexture(pai_path .. "red_" .. tostring(self.cardValue_ ) .. ".png", 1)
            color_1:loadTexture(pai_path .. "diamonds.png", 1)
            color_2:loadTexture(pai_path .. "diamonds.png", 1)
        elseif self.cardVariety_ == VARIETY_CLUB then-- 梅花
            value:loadTexture(pai_path .. "black_" .. tostring(self.cardValue_ , 1) .. ".png", 1)
            color_1:loadTexture(pai_path .. "clubs.png", 1)
            color_2:loadTexture(pai_path .. "clubs.png", 1)
        elseif self.cardVariety_ == VARIETY_HEART then-- 红桃
            value:loadTexture(pai_path .. "red_" .. tostring(self.cardValue_ , 1) .. ".png", 1)
            color_1:loadTexture(pai_path .. "hearts.png", 1)
            color_2:loadTexture(pai_path .. "hearts.png", 1)
        elseif self.cardVariety_ == VARIETY_SPADE then-- 黑桃
            value:loadTexture(pai_path .. "black_" .. tostring(self.cardValue_ , 1) .. ".png", 1)
            color_1:loadTexture(pai_path .. "spades.png", 1)
            color_2:loadTexture(pai_path .. "spades.png", 1)
        end
    end
    value:ignoreContentAdaptWithSize(true)
    color_1:ignoreContentAdaptWithSize(true)
    color_2:ignoreContentAdaptWithSize(true)
    -- self.font_pai_:setAnchorPoint(cc.p(0.5,0))
    self.font_pai_:setTouchEnabled(false)

    return self
end

function PokerCard:setGuiCard(clientCard)
    if not (clientCard and clientCard.number >= 20) then
        return
    end
    -- self:setMaNode(false)
    self.maNode:setVisible(false)

    self.cardValue_ = clientCard.scores == 1 and 14 or clientCard.scores
    self.cardVariety_ = clientCard.changeColor
    -- self.cardValue_ = self.cardValue_ or 
   
    local value = self.font_pai_:getChildByName("value")
    local color_1 = self.font_pai_:getChildByName("color_1")
    local color_2 = self.font_pai_:getChildByName("color_2")
    if ShiSanZhangConfig:getVersion() then
        local tab = {
            [1] = "king_1.png",
            [2] = "king_2.png",
        }
        value:hide()
        color_1:hide()
        color_2:hide()
        self.font_pai_:loadTexture(pai_path ..tab[clientCard.color], 1)
    else
        local tab = {
            [1] = "color_king_1.png",
            [2] = "color_king_2.png",
        }
        value:show()
        color_1:show()
        color_2:show()
        self.font_pai_:loadTexture(pai_path .."card_front.png", 1)    
        dump(clientCard)
        if self.cardVariety_ == 1 then -- 方块
            value:loadTexture(pai_path .. "red_" .. tostring(self.cardValue_ ) .. ".png", 1)
            color_1:loadTexture(pai_path .. "diamonds.png", 1)
        elseif self.cardVariety_ == 2 then-- 梅花
            value:loadTexture(pai_path .. "black_" .. tostring(self.cardValue_ , 1) .. ".png", 1)
            color_1:loadTexture(pai_path .. "clubs.png", 1)
        elseif self.cardVariety_ == 3 then-- 红桃
            value:loadTexture(pai_path .. "red_" .. tostring(self.cardValue_ , 1) .. ".png", 1)
            color_1:loadTexture(pai_path .. "hearts.png", 1)
        elseif self.cardVariety_ == 4 then-- 黑桃
            value:loadTexture(pai_path .. "black_" .. tostring(self.cardValue_ , 1) .. ".png", 1)
            color_1:loadTexture(pai_path .. "spades.png", 1)
        end
        color_2:loadTexture(pai_path .. tab[clientCard.color], 1)
    end

    

    value:ignoreContentAdaptWithSize(true)
    color_1:ignoreContentAdaptWithSize(true)
    color_2:ignoreContentAdaptWithSize(true)
    self.font_pai_:setTouchEnabled(false)
    return self
end

function PokerCard:setMaNode(flag)
    self.maNode:setVisible(flag)
end

function PokerCard:flipCard()

    self.isBack_ = false
    local cardFace = self.font_pai_
    local cardBack = self.backBg_
    local aniTime = 0.15
    local to_p1 = cc.RotateBy:create(0,cc.vec3(0,90,0));
    cardFace:runAction(to_p1)  
    -- SCENENOW["scene"]:performWithDelay(function()
    local to_B = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0))
    cardBack:runAction(to_B);
    cardBack:runAction(cc.Sequence:create(cc.DelayTime:create(aniTime-aniTime/100),cc.CallFunc:create(function() cardBack:setVisible(false) cardFace:setVisible(true) end)))

    local de = cc.DelayTime:create(aniTime);
    local to_p2 = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0));
    local seqP2 = cc.Sequence:create(de,to_p2);
    cardFace:runAction(seqP2);

        -- end,0.1)
end

-- 显示正面
function PokerCard:showFront()
    self.isBack_ = false
    self.backBg_:setVisible(false)

    if  self.font_pai_ then 
        self.font_pai_:setVisible(true)
    end

    return self
end

-- 显示背面
function PokerCard:showBack()
    self.isBack_ = true
    
    if  self.font_pai_ then
        -- dump("隐藏牌面")
        self.font_pai_:setVisible(false)
    end

    if  self.backBg_ then
        -- dump("显示牌背")
        self.backBg_:setVisible(true)
    end
    
    return self
end

function PokerCard:isBack()
    return self.isBack_
end

function PokerCard:setMask(flag)
    self.mask:setVisible(flag)
end

function PokerCard:isMask()
    return self.mask:isVisible()
end

function PokerCard:exportMethods()
    self:exportMethods_({
        "isMask",
        "setMask",
        "isBack",
        "showBack",
        "showFront",
        "flipCard",
        "setGuiCard",
        "setCard",
        "initUI",
        "setMaNode",
        "getCardSize",
    })
    return self.target_
end

return PokerCard
