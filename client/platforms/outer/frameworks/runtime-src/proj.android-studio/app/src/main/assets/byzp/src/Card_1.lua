local scheduler = require(cc.PACKAGE_NAME..".scheduler")
local CardUtils = require("byzp.src.CardUtils")

local Card = class("Card", function()
    return ccui.ImageView:create()
end)

function Card:ctor(_pokerCard, _type)
    self._pokerCard = _pokerCard
    self._type = _type
    local imgPath = string.format("byzp/res/cards/%s/%s.png", _type, _pokerCard)
    self:loadTexture(imgPath)
    self:ignoreContentAdaptWithSize(true)
end

function Card:changeImg(node, _pokerCard, _type)
    node._pokerCard = _pokerCard
    node._type = _type
    local imgPath = string.format("byzp/res/cards/%s/%s.png", _type, _pokerCard)
    node:loadTexture(imgPath)
end

function Card:getLongCardSize( )
    return cc.size(97, 287)
end

function Card:getShortCardSize( )
    return cc.size(97, 111)
end

function Card:setTing()
    local tingNode = self:getChildByName("tingNode")
    if not tingNode then
        local imgPath = "byzp/res/ting/icon_3.png"
        tingNode = display.newSprite(imgPath)
        tingNode:setName("tingNode")
        tingNode:setAnchorPoint(1,1)
        self:addChild(tingNode)
    end
    local scale = self:getScale()
    local size = self:getContentSize()
    local height = size.height * scale
    local width = size.width * scale
    tingNode:setPosition(width, height)
end

function Card:hideTing()
    local tingNode = self:getChildByName("tingNode")
    if tingNode then
        tingNode:removeSelf()
    end
end

return Card