local scheduler = require(cc.PACKAGE_NAME..".scheduler")
local CardUtils = require("ldfpaofa.src.CardUtils")

local Card = class("Card", function()
    return ccui.ImageView:create()
end)

function Card:ctor(_pokerCard, _type)
    self._pokerCard = _pokerCard
    self._type = _type
    local imgPath = string.format("ldfpaofa/res/cards/%s/%s/%s.png", g_345.cardPath, _type, _pokerCard)
    self:loadTexture(imgPath)
    self:ignoreContentAdaptWithSize(true)
    g_345.allCards[self] = self
    self:setNodeEventEnabled(true, function(event)
        if event.name == "exit" then
            self:onExit(self)
        end
    end)
end

function Card:changeImg(node, _pokerCard, _type)
    node._pokerCard = _pokerCard
    node._type = _type
    local imgPath = string.format("ldfpaofa/res/cards/%s/%s/%s.png", g_345.cardPath, _type, _pokerCard)
    node:loadTexture(imgPath)
    if not g_345.allCards[node] then
        node:setNodeEventEnabled(true, function(event)
            if event.name == "exit" then
                self:onExit(node)
            end
        end)
        g_345.allCards[node] = node
    end
end

function Card:getLongCardSize( )
    return cc.size(97, 287)
end

function Card:getShortCardSize( )
    return cc.size(97, 111)
end

function Card:getMinCardSize( )
    return cc.size(32-1, 38-1.5)
end

function Card:setTing()
    local tingNode = self:getChildByName("tingNode")
    if not tingNode then
        local imgPath = "ldfpaofa/res/ting/icon_3.png"
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

function Card:onExit( node )
    g_345.allCards[node] = nil
end

return Card