local scheduler = require(cc.PACKAGE_NAME..".scheduler")

local Card = class("Card", function()
    return ccui.ImageView:create()
end)

function Card:ctor(_pokerCard)
    self._pokerCard = _pokerCard
    self._type = _type
    local imgPath = string.format("shenshou100/res/cards/%s.png", _pokerCard)
    -- local imgPath = string.format("shenshou100/res/cards/%s/%s/%s.png", g_102.cardPath, _type, _pokerCard)
    self:loadTexture(imgPath)
    self:ignoreContentAdaptWithSize(true)
    g_102.allCards[self] = self
    self:setNodeEventEnabled(true, function(event)
        if event.name == "exit" then
            self:onExit(self)
        end
    end)
end

function Card:changeImg(node, _pokerCard)
    
    node._pokerCard = _pokerCard
    local imgPath = string.format("shenshou100/res/cards/%s.png", _pokerCard)
    node:loadTexture(imgPath)
    if not g_102.allCards[node] then
        node:setNodeEventEnabled(true, function(event)
            if event.name == "exit" then
                self:onExit(node)
            end
        end)
        g_102.allCards[node] = node
    end
end

function Card:onExit( node )
    g_102.allCards[node] = nil
end

return Card