-- SmallCardSprite
-- Author: zzy
-- Date: 2019-01-08 11:56:01

local CardConfig = require("ldfpaofa.logic.CardConfig")

local SmallCardSprite = class("SmallCardSprite", function()
    return display.newSprite()
end)

function SmallCardSprite:ctor( cardId,row,col )
    self.Row = 0
    self.Col = 0
    self.Value = 0
    self.Color = 0
    self.CardId = 0
    self.CardIndex = 0
    self.IsCovered = false
    self.cardConfig_ = CardConfig:new()
    self:init(cardId,row,col)
end

--创建单张
function SmallCardSprite:init( cardId,row,col )
    local cardInfo = self.cardConfig_:getCardInfoByid(cardId)
    if cardInfo then
        --设置贴图
        local imgPath = string.format("%s.png",cardInfo.CardIconA)
        local frame = display.newSpriteFrame(imgPath)
        self:setSpriteFrame(frame)
        --设置纸牌数据
        self.Row = rowa
        self.Col = col
        self.Value = cardInfo.Value
        self.Color = cardInfo.Color
        self.CardId = cardInfo.CardId
        self.CardIndex = cardInfo.CardIndex
    else
        print("纸牌创建失败!!!",cardId)
    end
end

function SmallCardSprite:setCardCovered( isCover )
    self.IsCovered = isCover
    if self.IsCovered then
        self:setColor(cc.c3b(175,175,175))
    else
        self:setColor(cc.c3b(255,255,255))
    end
end

function SmallCardSprite:setRow( row )
    self.Row = row
    self:getParent():reorderChild(self,4-row)
end

function SmallCardSprite:getRow( )
    return self.Row
end

function SmallCardSprite:setCol( col )
    self.Col = col
end

function SmallCardSprite:getCol( )
    return self.Col
end

function SmallCardSprite:getCardId( )
    return self.CardId
end

function SmallCardSprite:getCardIndex( )
    return self.CardIndex
end

function SmallCardSprite:getCardValue( )
    return self.Value
end

function SmallCardSprite:getCardColor( )
    return self.Color
end

return SmallCardSprite