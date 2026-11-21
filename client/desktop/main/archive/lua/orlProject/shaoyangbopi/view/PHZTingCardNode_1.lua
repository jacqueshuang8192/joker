local PHZTingCardNode = class("PHZTingCardNode", function ()
   return cc.CSLoader:createNode("shaoyangbopi/res/PHZTingCardNode.csb")
end)

PHZTingCardNode.ADD_WIDTH = 40
PHZTingCardNode.LITTER_NUMBER = 3

PHZTingCardNode.FIRST_W = 70
PHZTingCardNode.FIRST_H = 61

function PHZTingCardNode:ctor()
	self:setNodeEventEnabled(true)
	self:initUI()
    self:refreshTingCards()
end

function PHZTingCardNode:onEnter()
    
end

function PHZTingCardNode:onExit()
    self.tingBG:removeAllChildren()
    g_PHZTingNode = nil
end

function PHZTingCardNode:initUI()
    self.tingBG = self:getChildByName("img_tingbg")
    self.m_card = self.tingBG:getChildByName("card")


end

function PHZTingCardNode:removeTingNode()
    if g_PHZTingNode then
        g_PHZTingNode:removeFromParent()
        g_PHZTingNode = nil
    end
end

function PHZTingCardNode:refreshTingCards(data)
    -- test
    -- self.data = {1,2,3}
    self.data = data
    if not self.data then return end
    local cardN = #self.data
    self:refreshBGSize(cardN)
    for k,v in pairs(self.data) do
        -- print("==v==",v)
        self:createCardCell(k,v)
    end
end

--create new card 
function PHZTingCardNode:createCardCell(_index,_data)
    if not _index then return end
    if not _data then return end

    local tempCard = self.m_card
    if _index ~= 1 then 
        tempCard = tempCard:clone()
        self.tingBG:addChild(tempCard)
        self:refreshCardPos(_index,tempCard)
    end

    local CardConfig = require("shaoyangbopi.logic.CardConfig")
    self.m_CardConfig = CardConfig:new()
    local imgPath = "shaoyangbopi/res/CardLitter/Card_miniature_000_blue.png"
    local cardInfo = self.m_CardConfig:getCardInfoByid(_data)
    if cardInfo then
        imgPath = string.format("%s.png",cardInfo.CardIconA)
    end

    local frame = display.newSpriteFrame(imgPath)
    tempCard:setSpriteFrame(frame)

    local temp_card_N = tempCard:getChildByName("Text_1")
    self:refreshCardNumber(temp_card_N,_data)
end

function PHZTingCardNode:refreshCardPos(_index,node)
    node:setPosition(cc.p((_index-1)*PHZTingCardNode.ADD_WIDTH+PHZTingCardNode.FIRST_W,PHZTingCardNode.FIRST_H))
end

--获取所对应听牌还剩余的数值（仅仅只将打出去的牌进行一次的筛选）
function PHZTingCardNode:refreshCardNumber(node,_value)
    local tingCardNum = g_PHZMainScene:getTingCardNumByCardID(_value)
    if tingCardNum < 0 then
       tingCardNum = 0 
    end
    node:setString(tingCardNum or "")
end

function PHZTingCardNode:refreshBGSize(cardN)
    if cardN <= 0 then return end
    local BGContentSize = self.tingBG:getContentSize()
    print("======BGContentSize========",BGContentSize.width,BGContentSize.height)
    self.tingBG:setContentSize((cardN-PHZTingCardNode.LITTER_NUMBER)*PHZTingCardNode.ADD_WIDTH+180,BGContentSize.height)
end

return PHZTingCardNode