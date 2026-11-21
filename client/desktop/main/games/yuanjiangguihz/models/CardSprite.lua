-- CardSprite
-- Author: zzy
-- Date: 2019-01-08 10:56:01

local scheduler = require(cc.PACKAGE_NAME..".scheduler")
local CardConfig = require("yuanjiangguihz.logic.CardConfig")

local CardSprite = class("CardSprite", function()
    return display.newSprite()
end)

function CardSprite:ctor( cardId, row, col )
    self.Row = 0                             --行
    self.Col = 0                             --列
    self.Value = 0                           --值
    self.Color = 0                           --颜色
    self.CardId = 0                          --id
    self.Reorder = 0                         --层级
    self.CardIndex = 0                       
    self.IsLocked = true                     --是否锁住
    self.IsCovered = false                   --是否被覆盖
    self.cardConfig_ = CardConfig:new()
    self.cardId = cardId
    self:init(cardId,row,col)
end

--创建单张
function CardSprite:init( cardId, row, col )
    local cardInfo = self.cardConfig_:getCardInfoByid(cardId)
    if cardInfo then
        --设置贴图
        local imgPath = string.format("%s.png",cardInfo.CardIconB)
        local frame = display.newSpriteFrame(imgPath)

        self:setSpriteFrame(frame)
        --设置纸牌数据
        self.Row = row
        self.Col = col
        self.Value = cardInfo.Value
        self.Color = cardInfo.Color
        self.CardId = cardInfo.CardId
        self.CardIndex = cardInfo.CardIndex
        self.CanTing = false
        --设置纸牌接收触摸事件
        self:setTouchEnabled(true)
        self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            if event.name == "began" then
                print("Touch Me, card:",self.CardId)
                print("self.IsCovered =",self.IsCovered)
                print("self.IsLocked =",self.IsLocked)
                print("isCardReady =", g_PHZMainScene:isCardReady())
                if self.IsCovered==false and self.IsLocked==false and g_PHZMainScene:isCardReady()==true then
                    print("开始点击某一个牌")
                    g_CardScene:setTakeUpCard(self)
                end
            end
            return false
        end)
        -- self.LockImg = display.newScale9Sprite("#covering.png")
        -- self.LockImg:setContentSize(78, 96)
        -- self.LockImg:setPosition(41.5, 50)
        -- self:addChild(self.LockImg)

        local imgPath = string.format("%s.png","yuanjiangguihz/res/other/img_ting")
        self.TingImg = display.newSprite()
        local frame = display.newSpriteFrame(imgPath)
        self.TingImg:setSpriteFrame(frame)
        self.TingImg:setAnchorPoint(1,1)
        self:addChild(self.TingImg)
        self:setCardCanTing(false)
        self:setCardLock(false)
    else
        print("纸牌创建失败!!!",cardId)
    end
end

function CardSprite:setCardCanTing( isTing )
    self.CanTing = isTing or false
    self:setTingCardSize()
    self.TingImg:setVisible(isTing or false)
end

function CardSprite:setTingCardSize()
    local tempContentSize = self:getContentSize()
    self.TingImg:setPosition(cc.p(tempContentSize.width,tempContentSize.height))
end

function CardSprite:setCardCovered( isCover )
    self.IsCovered = isCover
    if self.IsCovered then
        self:setColor(cc.c3b(175,175,175))
    else
        self:setColor(cc.c3b(255,255,255))
    end
end

function CardSprite:setCardLock( isLock )
    self.IsLocked = isLock
    -- if self.IsLocked then
    --     self.LockImg:setVisible(true)
    -- else
    --     self.LockImg:setVisible(false)
    -- end
end

--设置移动牌的层级
function CardSprite:setMovingReorder()
    self.Reorder = 100
    self:getParent():reorderChild(self,self.Reorder)
end

function CardSprite:registerReorder()
    self.Reorder = 4-self.Row
    self:getParent():reorderChild(self,self.Reorder)
end

function CardSprite:getReorder( )
    return self.Reorder
end

function CardSprite:setRow( row )
    self.Row = row
    self:getParent():reorderChild(self,4-row)
end

function CardSprite:getRow( )
    return self.Row
end

function CardSprite:setCol( col )
    self.Col = col
end

function CardSprite:getCol()
    return self.Col
end

function CardSprite:isCovered( )
    return self.IsCovered
end

function CardSprite:getCardId( )
    return self.CardId
end

function CardSprite:getCardIndex( )
    return self.CardIndex
end

function CardSprite:getCardValue( )
    return self.Value
end

function CardSprite:getCardColor( )
    return self.Color
end

function CardSprite:setSpriteFrameBOrC(spriteFrametype)
    --print("设置纹理畏：",spriteFrametype)
    local spriteFrametype = spriteFrametype or "B"
    local cardId = self:getCardId()
    local cardInfo = self.cardConfig_:getCardInfoByid(cardId)
    local imgPath = string.format("%s.png",cardInfo["CardIcon"..spriteFrametype])
    local frame = display.newSpriteFrame(imgPath)
    self:setSpriteFrame(frame)
    local tingNode = self:getChildByName("tingNode")
    if tingNode then
        self:setTing()
    end 
end

function CardSprite:setTing()
    local tingNode = self:getChildByName("tingNode")
    if not tingNode then
        local imgPath = "yuanjiangguihz/res/newImg/ting/icon_3.png"
        tingNode = display.newSprite(imgPath)
        tingNode:setName("tingNode")
        tingNode:setAnchorPoint(0,1)
        self:addChild(tingNode)
    end
    local scale = self:getScale()
    local size = self:getContentSize()
    local height = size.height * scale
    tingNode:setPosition(0, height)
end

function CardSprite:hideTing()
    local tingNode = self:getChildByName("tingNode")
    if tingNode then
        tingNode:removeSelf()
    end
end

return CardSprite