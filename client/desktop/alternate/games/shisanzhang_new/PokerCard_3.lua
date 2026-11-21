local maColor = cc.c3b(207,207,103)
local orlColor = cc.c3b(255,255,255)
local maskColor = cc.c3b(0,0,0)
local pai_path = TpackageName .. "/res/layout/PokerCard/"  --newcard
local PokerCard = class("PokerCard", cc.Component)

function PokerCard:ctor()
    PokerCard.super.ctor(self, "PokerCard")
end

function PokerCard:initUI(node)
    -- 初始数值
    self.node = node
    self.isBack_ = true
    self.cardUint_ = 1
    self.font_pai_ = node.card_blank:hide()
    self.backBg_ = node.card_back:show()
end

function PokerCard:getCardSize()
    return self.backBg_:getContentSize()
end

-- 设置扑克牌面,拼接方式生成
function PokerCard:setCard(data)
    local card
    if type(data) == "table" then
        if data.isKing >= 78 then
            card = data.isKing
        else
            card = data.card
        end
    else
        card = data
    end
    self:setMaNode(MA_CARD == card)
    self.font_pai_:loadTexture(pai_path..card..".png")
    self.font_pai_:setTouchEnabled(false)
    return self
end

function PokerCard:setMaNode(flag)
    if self.maNode then
        self.maNode:setVisible(flag)
    elseif flag == true then
        self.maNode = display.newSprite(pai_path.."ma.png")
        self.maNode:addTo(self.font_pai_)
        self.maNode:setPosition(46, 175)
        self.maNode:setVisible(flag)
    end
    -- if flag then
    --     self.font_pai_:setColor(maColor)
    -- else
    --     self.font_pai_:setColor(orlColor)
    -- end
end

-- 显示正面
function PokerCard:showFront()
    self.isBack_ = false
    self.backBg_:setVisible(false)
    if self.font_pai_ then 
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
    if self.maskNode then
        if flag then
            self.maskNode:show()
        else
            self.maskNode:hide()
        end
    else
        if flag then
            self:setMaskLayout( )
            self.maskNode:show()
        end
    end
end

function PokerCard:setMaskLayout( )
    local getAnchorPoint = self.font_pai_:getAnchorPoint()
    local getPosition = self.font_pai_:getPosition()
    local size = self.font_pai_:getContentSize()
    self.maskNode = self.font_pai_:clone()
    self.maskNode:setOpacity(150)
    self.maskNode:setTouchEnabled(true)
    self.maskNode:setColor(maskColor)
    self.node:addChild(self.maskNode)
end

function PokerCard:isMask()
    if self.maskNode then
        return self.maskNode:isVisible()
    else
        return false
    end
end

function PokerCard:exportMethods()
    self:exportMethods_({
        "isMask",
        "setMask",
        "isBack",
        "showBack",
        "showFront",
        "setCard",
        "initUI",
        "setMaNode",
        "getCardSize",
    })
    return self.target_
end

return PokerCard
