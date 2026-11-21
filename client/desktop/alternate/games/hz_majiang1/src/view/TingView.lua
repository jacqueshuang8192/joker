local TingView = class("TingView")
local PokerCard = require("hz_majiang.src.PokerCard")
function TingView:ctor(ting_vw, GameSceneView)
	self.ting_vw = ting_vw
	self.GameSceneView = GameSceneView
    self.img_renyi = self.ting_vw.img_renyi:hide()
    self.hupai_vw = self.ting_vw.hupai_vw:hide()
    self.tingData = {}
    self.img_renyi:onClick(function(  )
        self.img_renyi.cards_vw:setVisible(not self.img_renyi.cards_vw:isVisible())
    end)
    self.isTingHu = false
    
end

function TingView:clearData( )
    self.isTingHu = false
    self.tingData = {}
    self.img_renyi:hide()
    self.hupai_vw:hide()
end

function TingView:showTingHuData(card)
    local cards = {}
    local renYiHu = false
    if self.tingData[card] then
        for card, count in pairs(self.tingData[card].huCards) do
            table.insert(cards, card)
        end
        renYiHu = self.tingData[card].renYiHu
    end
    self:showTingHu(cards, renYiHu)
end

function TingView:showTingHu(cards, renYiHu)
    self.hupai_vw:hide()
    self.img_renyi:show()
    self.img_renyi.cards_vw:removeAllChildren()
    if #cards > 25 or renYiHu then
        self.img_renyi.txt:show()
        self.isTingHu = true
    elseif #cards <= 0 then
        self.img_renyi:hide()
        self.isTingHu = false
    else
        self.isTingHu = true
        self.img_renyi.txt:hide()
        table.sort(cards)
        local scale = 0.45
        for idx, card in ipairs(cards) do
            local cardNode = PokerCard:newMyInHandCard(card)
            
            local cardHeight = cardNode:getSize().height
            local cardWidth = cardNode:getSize().width
            cardHeight = cardHeight * scale
            cardWidth = cardWidth * scale
            local oriX = cardWidth / 2
            local oriY = cardHeight / 2
            
            local x = oriX + ( idx-1 ) * cardWidth
            cardNode:setScale(scale)
            cardNode:setPosition(cc.p(x, oriY))
            self.img_renyi.cards_vw:addChild(cardNode)
        end
    end
end

function TingView:setTing(tingCards)
    local getCurCards = self.GameSceneView:getCurCards()
    local tingData = {}
    local maxCard
    local maxCount = 0
    for _, val1 in ipairs(tingCards) do
        local arr = {}
        arr.count = 0
        arr.tingCards = {}
        arr.huCards = {}
        arr.renYiHu = false
        for _, val2 in ipairs(val1.tingHuCards) do
            for i, val3 in ipairs(val2.huCards) do
                local count = getCurCards[val3] or 0
                arr.huCards[val3] = 4 - count
                arr.count = arr.count + arr.huCards[val3]
            end
            for i, val3 in ipairs(val2.component) do
                arr.tingCards[val3] = val2.huCards
            end
            if not val2.huCards or table.getn(val2.huCards) == 0 then
                arr.renYiHu = true
            end
        end

        if arr.count > maxCount then
            maxCount = arr.count
            maxCard = val1.card
        end
        tingData[val1.card] = arr
    end

    self.tingData = tingData
    for k,v in pairs(self.tingData) do
        local cards = {}
        for card, count in pairs(v.huCards) do
            table.insert(cards, card)
        end
        if #cards > 25 or v.renYiHu then
            maxCard = k
            break
        end
    end
    if maxCard then
        self.isTingHu = false
        -- self:setTingNode(maxCard)
        -- self:setTingNodeAndCount(maxCard)
        self.hupai_vw:hide()
        self.img_renyi:hide()
        self.GameSceneView.MyUserInfoView.HandCardView:setTings(tingData, maxCard)
    end
end

function TingView:setTingNodeAndCount(cardValue)
    if self.isTingHu then--已经在听牌了
        return
    end
    local tingData = self.tingData[cardValue]
    if not tingData then
        self.hupai_vw:hide()
        return
    end

    local cards = {}
    for card, count in pairs(tingData.huCards) do
        table.insert(cards, card)
    end

    if #cards > 25 or tingData.renYiHu then
        self.hupai_vw:hide()
        self.hupai_vw.cards_vw:removeAllChildren()
    else
        self.hupai_vw:show()
        self.hupai_vw.cards_vw:removeAllChildren()
        table.sort(cards)
        local size = self.hupai_vw.cards_vw:getSize()
        local scale = 0.6
        local cardWidth = 0
        local cardHeight = 0
        local totalCount = 0
        local getCurCards = self.GameSceneView:getCurCards()
        for idx, card in ipairs(cards) do
            local cardNode = PokerCard:newMyInHandCard(card)
            
            cardHeight = cardNode:getSize().height
            cardWidth = cardNode:getSize().width
            cardHeight = cardHeight * scale
            cardWidth = cardWidth * scale
            local oriX = cardWidth / 2
            local oriY = cardHeight - 10
            
            local x = oriX + ( idx-1 ) * cardWidth
            cardNode:setScale(scale)
            cardNode:setPosition(cc.p(x, oriY))
            local count = 4 - (getCurCards[card] or 0)
			cardNode:showTxtHuRemainCards(count.."张")

            self.hupai_vw.cards_vw:addChild(cardNode)
            totalCount = totalCount + count
        end


        local number = #cards
        local width = 200 + number * cardWidth
        self.hupai_vw:setSize(cc.size(width, size.height))
        self.hupai_vw.txt_cardnum:setString("共"..totalCount.."张")
    end

   
end

function TingView:setTingNode(cardValue)
    if self.isTingHu then--已经在听牌了
        return
    end
    local tingData = self.tingData[cardValue]
    if not tingData then
        self.img_renyi:hide()
        return
    end

    self.img_renyi:show()
    self.img_renyi.cards_vw:removeAllChildren()
    local cards = {}
    for card, count in pairs(tingData.huCards) do
        table.insert(cards, card)
    end

    if #cards > 25 or tingData.renYiHu then
        self.img_renyi.txt:show()
    else
        self.img_renyi.txt:hide()
        table.sort(cards)
        local scale = 0.45
        for idx, card in ipairs(cards) do
            local cardNode = PokerCard:newMyInHandCard(card)
            
            local cardHeight = cardNode:getSize().height
            local cardWidth = cardNode:getSize().width
            cardHeight = cardHeight * scale
            cardWidth = cardWidth * scale
            local oriX = cardWidth / 2
            local oriY = cardHeight / 2
            
            local x = oriX + ( idx-1 ) * cardWidth
            cardNode:setScale(scale)
            cardNode:setPosition(cc.p(x, oriY))
            self.img_renyi.cards_vw:addChild(cardNode)
        end
    end
end


return TingView	