local Card = class("Card", function ()
	return ccui.ImageView:create()
end)

function Card:ctor(_type, card)
    self:setNodeEventEnabled(true)
    self:changeImg(_type, card)
    self.isShow = false
    self._debug = debug.traceback()
    g_388.cardsAllNode[self] = self
end

function Card:changeImg(_type, _card, node)
    if not node then
        node = self
    end
    if not _type then
        _type = self._type
    end
    if not _card then
        _card = self._card
    end
    node._type = _type
    node._card = _card
    local path = "jchuapai/res/cards/"
    if g_388.isHua_388 then
        path = "jchuapai/res/cards/hua_"
    end
    if _type == "long" then
        path = path.._type.."/".._card..".png"
        node:setName(_card)
    elseif _type == "short" then
        path = path.._type.."/".._card..".png"
    elseif _type == "back" then
        path = "jchuapai/res/cards/back_1.png"
    end
    node:loadTexture(path)
    node:ignoreContentAdaptWithSize(true)
end

function Card:isShowLight(isShow)
    if not self.lightNode then
        self.lightNode = ccui.ImageView:create("jchuapai/res/cards/bg_light.png")
        self:addChild(self.lightNode)
        local size = self:getContentSize()
        self.lightNode:setPosition(size.width / 2, size.height / 2)
    end
    self.lightNode:setVisible(isShow)
    self.isShow = isShow
end

function Card:getShowLight()
    return self.isShow
end

function Card:onExit()
    g_388.cardsAllNode[self] = nil
end

return Card