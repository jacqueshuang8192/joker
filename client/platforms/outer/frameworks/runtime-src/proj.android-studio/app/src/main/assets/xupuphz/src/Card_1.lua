local scheduler = require(cc.PACKAGE_NAME..".scheduler")
local CardUtils = require("xupuphz.src.CardUtils")

local Card = class("Card", function()
    return ccui.ImageView:create()
end)

function Card:ctor(_pokerCard, _type, _ziPaiCard)
    if not _ziPaiCard then
        _ziPaiCard = CardUtils:getZiPaiCard( _pokerCard )
    end
    self._ziPaiCard = _ziPaiCard
    self._pokerCard = _pokerCard
    self._type = _type
    local imgPath = string.format("xupuphz/res/cards/%s/%s.png", _type, _pokerCard)
    -- local frame = display.newSpriteFrame(imgPath)
    -- self:setSpriteFrame(frame)
    self:loadTexture(imgPath)
    self:ignoreContentAdaptWithSize(true)
end

function Card:changeImg(node, _pokerCard, _type, _ziPaiCard)
    if not _ziPaiCard then
        _ziPaiCard = CardUtils:getZiPaiCard( _pokerCard )
    end
    node._ziPaiCard = _ziPaiCard
    node._pokerCard = _pokerCard
    node._type = _type
    local imgPath = string.format("xupuphz/res/cards/%s/%s.png", _type, _pokerCard)
    node:loadTexture(imgPath)
end

function Card:setTing()
    local tingNode = self:getChildByName("tingNode")
    if not tingNode then
        local imgPath = "xupuphz/res/ting/icon_3.png"
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