local PokerCardCsb = TpackageName .. "/res/layout/PokerCard/PokerCard.csb"
local PokerCard = class("PokerCard", function ()
    return display.newSprite()
end)

function PokerCard:ctor()
    local node = cc.CSLoader:createNode(PokerCardCsb):addTo(self)
    GameUtils.setNodeNameBindObj(node)
    cc(self):addComponent(TpackageName..".PokerCard_3"):exportMethods()
    self:initUI(node)
end

return PokerCard
