-- local CARD_WIDTH      = 233
-- local CARD_HEIGHT     = 315

local CARD_BACK_WIDTH      = 233
local CARD_BACK_HEIGHT     = 315

local VARIETY_DIAMOND = 0x00 -- 方块
local VARIETY_CLUB    = 0x10 -- 梅花
local VARIETY_HEART   = 0x20 -- 红桃
local VARIETY_SPADE   = 0x30 -- 黑桃

local pai_path = "FanSanPi/layout/PokerCard/"  --newcard
local PokerCardCsb = "FanSanPi/layout/PokerCard/PokerCard.csb"
local Shuffling_card_path = "FanSanPi/layout/LayerShuffling/"  --newcard

local CARD_VARIETY_TRANSFORM_PATH = 
{
    [VARIETY_DIAMOND] =Shuffling_card_path.. "diamonds_",
    [VARIETY_CLUB] = Shuffling_card_path.."clubs_",
    [VARIETY_HEART] = Shuffling_card_path.."hearts_",
    [VARIETY_SPADE] = Shuffling_card_path.."spades_",
}

local chooseColor = cc.c3b(140,140,140)
local oriColor = cc.c3b(255,255,255)

-- 获得花色
local function getVariety(card)
    return bit.band(card, 0xF0)
end

-- 获得牌值
local function getValue(card)
    if card == nil then
        return 0
    end
    local value = bit.band(card, 0x0F)
    if value == 1 then
        value = 14
    end
    return value
end


local PokerCard = class("PokerCard", function ()
    return display.newSprite()
end)

function PokerCard:ctor()
    -- 初始数值
    self.isBack_ = true
    -- 牌背
    self.backBg_ = ccui.ImageView:create("FanSanPi/layout/PokerCard/card_back.png", 1):addTo(self) 
    self.backBg_:setAnchorPoint(cc.p(0.5,0)) 
    self.cardUint_ = 1

end

function PokerCard:hasValue()
    return self.font_pai_ and true or false
end

function PokerCard:createSingleCard(cardUint)

    local cardUint_  = cardUint or 1
    local cardPath = ""
    local flag = 1
    if cardUint == 0x4e or cardUint == 0x4f then
        if cardUint == 0x4e then
            cardPath = Shuffling_card_path.."small_king.png"
        else
            cardPath = Shuffling_card_path.."big_king.png"
        end
        flag = 0
    else
        local cardValue_ = getValue(cardUint)
        local cardVariety_ = getVariety(cardUint)

        if  cardValue_  >= 2 and  cardValue_  < 10 then
            cardPath =  CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)].."0"..cardValue_..".png"          
        else
            cardPath =  CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)]..cardValue_..".png"    
        end
    end

    -- dump(cardPath,"createSingleCard")
    local s = ccui.ImageView:create(cardPath, flag)
    return s
end


-- function PokerCard:setCuoCard(cardNode,cardUint,isBack)
--     if  cardNode == nil then
--         cardNode = display.newNode()
--     end

--     cardNode.backBg_ = ccui.ImageView:create(Card_back_img, 1):addTo(cardNode)  
--     cardNode.backBg_:setContentSize(cc.size(300,458))
--     cardNode.backBg_:setAnchorPoint(cc.p(0,0)) 

--     if  isBack == true then
--         cardNode.backBg_:setVisible(true)
--         return
--     else
--         cardNode.backBg_:setVisible(false)
--     end


--     local cardUint_  = cardUint or 1

--     -- 获取值与花色
--     local cardValue_ = getValue(cardUint_)
--     local cardVariety_ = getVariety(cardUint_)
--     local cardPath = ""

--     if  cardValue_  >= 2 and  cardValue_  < 10 then
--         cardPath =  CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)].."0"..cardValue_..".png"          
--     else
--         cardPath =  CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)]..cardValue_..".png"    
--     end

--     local s = ccui.ImageView:create(cardPath, 1):addTo(cardNode)
--     cardNode.font_pai_  = s
--     cardNode.font_pai_:setVisible(true)
--     cardNode.font_pai_:setAnchorPoint(cc.p(0,0)) 

--     return cardNode
-- end

-- 设置扑克牌面,拼接方式生成
function PokerCard:setCard(cardUint, isLaper)
    -- cardUint = {
    --     color=48,
    --     value=10
    -- }
    if type(cardUint) ~= "table" then
        local data = {}
        data.value = getValue(cardUint)
        data.color = getVariety(cardUint)
        cardUint = data
    end
    self.cardUint_ = cardUint
    self.cardValue_ = cardUint.value --getValue(cardUint)
    self.cardVariety_ = cardUint.color --getVariety(cardUint)


    if  self.font_pai_ then
        self.font_pai_:removeFromParent()
    end

    local csbPath = (self.cardVariety_ >= 0x40) and  "FanSanPi/layout/PokerCard/PokerCardJoke.csb" or "FanSanPi/layout/PokerCard/PokerCard.csb"
    self.font_pai_ = cc.CSLoader:createNode(csbPath):addTo(self)
    GameUtils.setNodeNameBindObj(self.font_pai_)

    if self.cardVariety_ < 0x40 then
        local flag = self.font_pai_:getChildByName("laperFlag")
        flag:setVisible(false)
        if flag and self.cardValue_ == 3 and self.cardVariety_ == 0x00 then
            if isLaper == nil then
                local gameConfig = g_mainRoomLayer.gameConfigStr
                local configT = json.decode(gameConfig)
                local hasLaper = (string.find(configT.happy_money or "", "2") ~= nil)
                flag:setVisible(hasLaper)
            else
                local hasLaper = isLaper
                flag:setVisible(hasLaper)
            end
        end
    end

    local cardValue_iv = self.font_pai_:getChildByName("cardValue_iv")
    local cardVarietySmall_iv = self.font_pai_:getChildByName("cardVarietySmall_iv")
    local cardVariety_iv = self.font_pai_:getChildByName("cardVariety_iv")
    
    if self.cardVariety_ == VARIETY_DIAMOND then -- 方块
        cardValue_iv:loadTexture(pai_path .. "red_" .. tostring(self.cardValue_ ) .. ".png", 1)
        cardVarietySmall_iv:loadTexture(pai_path .. "diamonds.png", 1)
        cardVariety_iv:loadTexture(pai_path .. "diamonds.png", 1)
    elseif self.cardVariety_ == VARIETY_CLUB then-- 梅花
        cardValue_iv:loadTexture(pai_path .. "black_" .. tostring(self.cardValue_ , 1) .. ".png", 1)
        cardVarietySmall_iv:loadTexture(pai_path .. "clubs.png", 1)
        cardVariety_iv:loadTexture(pai_path .. "clubs.png", 1)
    elseif self.cardVariety_ == VARIETY_HEART then-- 红桃
        cardValue_iv:loadTexture(pai_path .. "red_" .. tostring(self.cardValue_ , 1) .. ".png", 1)
        cardVarietySmall_iv:loadTexture(pai_path .. "hearts.png", 1)
        cardVariety_iv:loadTexture(pai_path .. "hearts.png", 1)
    elseif self.cardVariety_ == VARIETY_SPADE then-- 黑桃
        cardValue_iv:loadTexture(pai_path .. "black_" .. tostring(self.cardValue_ , 1) .. ".png", 1)
        cardVarietySmall_iv:loadTexture(pai_path .. "spades.png", 1)
        cardVariety_iv:loadTexture(pai_path .. "spades.png", 1)
    elseif self.cardVariety_ == 0x40 then-- 大小王
        local pathValue = self.cardUint_.value == 0x0f and "big_king.png" or "small_king.png"
        local pathColor = self.cardUint_.value == 0x0f and "big_color.png" or "small_color.png"
        cardValue_iv:loadTexture(pai_path..pathValue, 0)
        cardValue_iv:setPosition(cc.p(26, 244))
        cardValue_iv:setScale(1.2)
        cardVarietySmall_iv:setVisible(false)
        cardVariety_iv:loadTexture(pai_path..pathColor, 0)
        cardVariety_iv:setPosition(cc.p(46, 262))
        cardVariety_iv:setScale(0.8)
    elseif self.cardVariety_ == 0x50 then-- 宾王
        cardValue_iv:setVisible(false)
        cardVarietySmall_iv:setVisible(false)
        cardVariety_iv:setVisible(false)
        local big_card_kong_1 = self.font_pai_:getChildByName("big_card_kong_1")
        big_card_kong_1:setTexture(pai_path.."binwan.png")
    end

    self.font_pai_:setAnchorPoint(cc.p(0.5,0))
    self.font_pai_:setTouchEnabled(false)
    self:showFront()
	dump(self.font_pai_:getPosition())
	dump(self.font_pai_:getAnchorPoint())
	dump(self.font_pai_:getScale())
	dump(self.font_pai_:getContentSize())
    return self
end

function PokerCard:flipCard()
    self.isBack_ = false
    local cardFace = self.font_pai_
    local cardBack = self.backBg_
    local aniTime = 0.15
    local to_p1 = cc.RotateBy:create(0,cc.vec3(0,90,0));
    cardFace:runAction(to_p1)  

    local to_B = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0))
    cardBack:runAction(to_B);
    cardBack:runAction(cc.Sequence:create(cc.DelayTime:create(aniTime-aniTime/100),cc.CallFunc:create(function() cardBack:setVisible(false) cardFace:setVisible(true) end)))
    local de = cc.DelayTime:create(aniTime);
    local to_p2 = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0));
    local seqP2 = cc.Sequence:create(de,to_p2);
    cardFace:runAction(seqP2);

end
-- -- 翻牌动画
-- function PokerCard:flip()
--     -- if self.isBack_ == false then
--     --     return
--     -- end
--     self.isBack_ = false

--     local delayAction = cc.DelayTime:create(0.2)
--     local orbitAction = cc.OrbitCamera:create(0.25, 1, 0, 0, 90, 0, 0)
--     local callback = cc.CallFunc:create(handler(self, self.onBackActionComplete_))
--     self.flipBackAction_ = cc.Sequence:create(delayAction,orbitAction,callback)
--     self.flipBackAction_:retain()

--     local orbitAction = cc.OrbitCamera:create(0.25, 1, 0, -90, 90, 0, 0)
--     local callback = cc.CallFunc:create(handler(self, self.onFrontActionComplete_))

--     self.flipFrontAction_ = cc.Sequence:create(orbitAction,callback)
--     self.flipFrontAction_:retain()
--     -- 首先显示牌背，0.5s后开始翻牌动画
--     self:showBack_()
--     self.backBg_:runAction(self.flipBackAction_)
--     return self
-- end
-- function PokerCard:onBackActionComplete_()
--     self:showFront();
--     self.frontBatch_:runAction(self.flipFrontAction_)
-- end
-- function PokerCard:onFrontActionComplete_()
--     self.frontBatch_:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
-- end

-- function PokerCard:showBack_()
--     -- self.frontBatch_:removeFromParent()
--     if not tolua.isnull(self.backBg_) then
--         if not self.backBg_:getParent() then
--             self.backBg_:addTo(self)
--             self.backBg_:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
--         end
--     else
--         self.backBg_=self
--     end

--     return self
-- end
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
function PokerCard:setCuoCard(cardNode,cardUint,isBack)
    if  cardNode == nil then
        cardNode = display.newNode()
    end

    cardNode.backBg_ = ccui.ImageView:create("FanSanPi/layout/PokerCard/card_back.png", 1):addTo(cardNode)
    cardNode.backBg_:setContentSize(cc.size(300,458))
    cardNode.backBg_:setAnchorPoint(cc.p(0,0))

    if  isBack == true then
        cardNode.backBg_:setVisible(true)
        return
    else
        cardNode.backBg_:setVisible(false)
    end


    local cardUint_  = cardUint or 1
    local cardPath = nil
    -- 获取值与花色
    local cardValue_ = getValue(cardUint_)
    local cardVariety_ = getVariety(cardUint_)

    if  cardValue_  >= 2 and  cardValue_  < 10 then
        cardPath =  CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)].."0"..cardValue_..".png"
    else
        cardPath =  CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)]..cardValue_..".png"
    end
    dump(cardPath,"===cardPath")
    local s = ccui.ImageView:create(cardPath, 1):addTo(cardNode)


    cardNode.font_pai_  = s
    cardNode.font_pai_:setVisible(true)
    cardNode.font_pai_:setAnchorPoint(cc.p(0,0))

    return cardNode
end

function PokerCard:toBlack()
    self.font_pai_:setColor(chooseColor)  
end

function PokerCard:toWhite()
    self.font_pai_:setColor(oriColor)  
end

function PokerCard:isBack()
    return self.isBack_
end


return PokerCard
