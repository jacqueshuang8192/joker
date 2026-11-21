local PokerCard = class("PokerCard", function()
    return ccui.ImageView:create()
end)

function PokerCard:ctor(_pokerCard)
    if not _pokerCard then
        _pokerCard = 0
        self.isBack_ = true
    end
    self._pokerCard = _pokerCard
    
    local imgPath = string.format("zhajinhua_jb/res/PokerCard/%s.png", _pokerCard)
    self:loadTexture(imgPath)
    self:ignoreContentAdaptWithSize(true)
    g_317.allCards[self] = self
    self:setNodeEventEnabled(true, function(event)
        if event.name == "exit" then
            self:onExit(true)
        end
    end)
end

function PokerCard:changeImg(node, _pokerCard)
    local imgPath = string.format("zhajinhua_jb/res/PokerCard/%s.png", _pokerCard)
    node:loadTexture(imgPath)
    if not g_317.allCards[node] then
        node:setNodeEventEnabled(true, function(event)
            if event.name == "exit" then
                self:onExit(node)
            end
        end)
        g_317.allCards[node] = node
    end
end

function PokerCard:setCard(card)
    self:changeImg(self, card)
    self.isBack_ = false
end

-- 显示正面
function PokerCard:showFront()
    self.isBack_ = false
    self:changeImg(self, self._pokerCard)
end

-- 显示背面
function PokerCard:showBack()
    self.isBack_ = true
    self:changeImg(self, 0)
end

function PokerCard:getCardSize()
    return cc.size(154, 208)
end

function PokerCard:onExit( node )
    g_317.allCards[node] = nil
end

return PokerCard