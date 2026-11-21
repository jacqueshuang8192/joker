local UserInfoView = class("UserInfoView")
local Card = require("xupuphz.src.Card")
local CardUtils = require("xupuphz.src.CardUtils")

function UserInfoView:ctor(player)
    self.player = player
    self.typeCardsIdx = 0
    self.allCards = {}--对 招 泛的牌{[0x01] = {}}
    self:initUI(self.player)
end

function UserInfoView:initUI(player)
    self.name = player:getName()
    self.cards_vw = player:getParent():getParent().cards_vw
    player:scheduleUpdateWithPriorityLua(handler(self, self.update), 0)
    self.txt_score = player.txt_score:setString("")
    self.txt_name = player.txt_name:setString("")
    self.img_zhuang = player.img_zhuang:hide()
    self.img_network = player.img_network:hide()
    self.txt_huXi = player.txt_huXi:setString("")
    self.txt_guchou = player.txt_guchou:hide()
    self.txt_piao = player.txt_piao:setString("")
    self.img_txt = player.img_txt:hide()
    self.img_ready = player.img_ready:hide()
    self.ArmatureNode_6 = player.ArmatureNode_6:hide()
    self.img_light = self.cards_vw[self.name.."_img_light"]:hide()
    self.hand_vw = self.cards_vw[self.name.."_hand_vw"]
    self.outCard = player:getParent()[self.name.."_outCard"]:hide()
    self.out_vw = self.cards_vw[self.name.."_out_vw"]:removeAllChildren()
    self.img_head = player.img_head
    self.typeCards_vw = self.cards_vw[self.name.."_typeCards_vw"]:removeAllChildren()
    self.worldpoint = (self.img_head:getParent()):convertToWorldSpace(self.img_head:getPosition()) --这样写是为了贴近函数的原始用法

    if self.name == "player_1" then
        local director = cc.Director:getInstance()
        local size = director:getWinSize()
        local pos = self.img_ready:getPosition()
        pos.x = size.width / 2
        local pos1 = player:convertToNodeSpace(pos)
        self.img_ready:setPositionX(pos1.x)
    end
end

function UserInfoView:clearData()
    self.allCards = {}
    self.typeCardsIdx = 0
    self.out_vw:removeAllChildren()
    self.typeCards_vw:removeAllChildren()
    self:isShowLight(false) 
    self:isShowOutCard(false) 
    self:isShowZhuang(false) 
    self:isShowReady(false) 
    self:isShowHuCount(false) 
    self.ArmatureNode_6:hide()
    -- self:isShowPiaoCount(false) 
end

function UserInfoView:setData( data )
	self.data = data
	self.player:show()
	self:refreshPlayerInfo(data.photoUrl, data.uid, data.sex, data.nickName)
	self:setScore(data.score)
end

function UserInfoView:getWorldpoint()
    return self.worldpoint
end

--刷新玩家的积分分数
function UserInfoView:setScore(score)
	self.txt_score:setString(tonumber(score) / 100)
end

function UserInfoView:isShowHuCount(isShow, count)
    if not count then
        count = 0
    end
	self.txt_huXi:setVisible(isShow)
	self.txt_huXi:setString("胡息:"..count)
end

function UserInfoView:isShowPiaoCount(isShow, count)
    if not count then
        count = 0
    end
	self.txt_piao:setVisible(isShow)
	self.txt_piao:setString("飘:"..count)
end


function UserInfoView:refreshPlayerInfo(icon_url, uid, sex, name, ip, addres)
	local size = self.img_head:getContentSize()
	require("hall.GameCommon"):getUserHead(icon_url, uid, sex, self.img_head, size.width, false, name, false, ip, addres)
	name = require("hall.GameCommon"):formatNick(name, 3)
	self.txt_name:setString(name or "")
end

function UserInfoView:isShowZhuang(isShow) 
	self.img_zhuang:setVisible(isShow)
end

function UserInfoView:isShowReady(isShow) 
	self.img_ready:setVisible(isShow)
end

function UserInfoView:isShowNewWork(isShow) 
	self.img_network:setVisible(isShow)
end

function UserInfoView:isShowLight(isShow) 
	self.img_light:setVisible(isShow)
end

function UserInfoView:isShowOutCard(isShow, card) 
    self.outCard:setVisible(isShow)
    if card then
        self.card = card
        self.outCard:setVisible(isShow)
        Card:changeImg(self.outCard, card, "max")
    end
end


function UserInfoView:showOutCard(card, cardsIdx)
    if not cardsIdx then
	    cardsIdx = self.out_vw:getChildrenCount() + 1
    end
    local cardNode = Card.new(card, "min")
	local size = self.out_vw:getSize()
    local scale = 0.7
    local cardWidth = 42
    local cardHeight = 56

    cardHeight = scale * (cardHeight)
    cardWidth = scale * (cardWidth)
    local oriX = size.width - cardWidth / 2
    local oriY = cardHeight / 2
    local row = 10
    local col = 6--一列有9个
    local x, y
    if self.name == "player_1" or self.name == "player_2" then
        local rowIdx = cardsIdx % row
        rowIdx = rowIdx == 0 and row or rowIdx
        local colIdx = math.ceil(cardsIdx/ row)
        x = oriX - (rowIdx - 1) * cardWidth
        y = oriY + (colIdx - 1) * cardHeight
    elseif self.name == "player_3" then
        local oriX = cardWidth / 2
        local oriY = cardHeight / 2

        local rowIdx = cardsIdx % row
        rowIdx = rowIdx == 0 and row or rowIdx
        local colIdx = math.ceil(cardsIdx/ row)
        x = oriX + (rowIdx - 1) * cardWidth
        y = oriY + (colIdx - 1) * cardHeight
    end
    cardNode:setPosition(cc.p(x, y))
    cardNode:setScale(scale)
    self.out_vw:addChild(cardNode)
end

function UserInfoView:showTypeCards(cards, _type, pokerCard)
    local cbCardList = {}
    for i,v in ipairs(cards) do
        local ziPaiCard = CardUtils:getZiPaiCard(v)
        table.insert(cbCardList, ziPaiCard)
    end
    if _type == g_392.t_chi then
        local WeaveItem = {
            cardType = _type,
            cbCardList = cbCardList,
            pokerCard = pokerCard,
        }
        table.insert(self.allCards, WeaveItem)
    else
        local WeaveItem = {
            cardType = _type,
            cbCardList = cbCardList,
            pokerCard = pokerCard,
        }
        self.allCards[pokerCard] = WeaveItem
    end
   
    self.typeCardsIdx = self.typeCardsIdx + 1
	local size = self.typeCards_vw:getSize()
    local scale = 1
    local cardWidth = 42
    local cardHeight = 56
    cardHeight = scale * (cardHeight - 2)
    cardWidth = scale * (cardWidth)
    local oriX = cardWidth / 2
    local oriY = cardHeight / 2
    local x = oriX + (self.typeCardsIdx - 1) * cardWidth
    if self.name == "player_2" then
        oriX = size.width - cardWidth / 2
        x = oriX - (self.typeCardsIdx - 1) * cardWidth
    end

    if _type == g_392.t_pao or _type == g_392.t_ti then
        local isRemove = false
        local chlds = self.typeCards_vw:getChildren()
        for i, poker in ipairs(cards) do
            local _ziPaiCard = CardUtils:getZiPaiCard( poker )
            for idx, node in ipairs(chlds) do
                if node.removeCard then
                    if CardUtils:getZiPaiCard( node.removeCard ) == _ziPaiCard then
                        x = math.ceil(node:getPositionX())
                        node:removeSelf()
                        table.remove(chlds, idx)
                        isRemove = true
                        break
                    end
                end
            end
        end
        if isRemove then
            self.typeCardsIdx = self.typeCardsIdx - 1
        end
    end
    for idx, card in ipairs(cards) do
        local cardNode = Card.new(card, "min")
        local y = oriY + (idx - 1) * cardHeight
        cardNode:setPosition(cc.p(x, y))
        cardNode:setScale(scale)
        self.typeCards_vw:addChild(cardNode)
        if g_392.t_peng == _type or _type == g_392.t_wei then
            cardNode.removeCard = pokerCard
        end
        if _type == g_392.t_chi and idx == 1 then
            cardNode:setColor(cc.c3b(127,127,127))
        end
    end
    self:setHuXi()
end

function UserInfoView:setHuXi()
    local allHuXi = 0
    for k,cards in pairs(self.allCards) do
        local huxi = 0
        huxi = CardUtils:GetWeaveHuXi( cards )
        allHuXi = allHuXi + huxi
    end
    self:isShowHuCount(true, allHuXi)
end

function UserInfoView:showImgTxt(type_)
    self.time = 1
    local path = "txt_zimo.png"
    if type_ == g_392.t_chi then
        path = "txt_chi.png"
    elseif type_ == g_392.t_peng then
        path = "txt_peng.png"
    elseif type_ == g_392.t_ti then
        path = "txt_ti.png"
    elseif type_ == g_392.t_pao then
        path = "txt_pao.png"
    elseif type_ == g_392.t_wei then
        path = "txt_wei.png"
    elseif type_ == g_392.t_hu then
        path = "txt_hu.png"
    end
    self.img_txt:loadTexture("hall/res/record/xupuphz/player/"..path)
    self.img_txt:ignoreContentAdaptWithSize(true)
    self.img_txt:show()
end

function UserInfoView:show( )
    self.player:setVisible(true)
end

function UserInfoView:hide( )
    self.player:setVisible(false)
end

function UserInfoView:update( dt )
    if self.time then
        self.time = self.time - dt
        if self.time <= 0 then
            self.time = nil
            self.img_txt:hide()
        end
    end
end

function UserInfoView:showZiMoOrHu(_type, callFunc)
    self.ArmatureNode_6:show()
    local anim = self.ArmatureNode_6:getAnimation()
    anim:playWithNames({_type}, 0, false)
    local function handler1(Armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
        end
    end
	anim:setMovementEventCallFunc(handler1)
end

function UserInfoView:isShowTxtGuChou(isShow)
	self.txt_guchou:setVisible(isShow)
end

----------------------
function UserInfoView:addHandCard( _pokerCard )
    local childs = self.hand_vw:getChildren()
    local pokerCards = {_pokerCard}
    for i,node in ipairs(childs) do
        table.insert(pokerCards, node._pokerCard)
    end
    self:setCurHandCards(pokerCards)
end

function UserInfoView:setCurHandCards(pokerCards)
    local ziPaiCards = CardUtils:getZiPaiCards( pokerCards )
    self.pokerCards = clone(pokerCards)
    self.ziPaiCards = ziPaiCards

    self.hand_vw:removeAllChildren()
    local result = CardUtils:getCurhandCard(pokerCards)
    local scale = 0.6
    local interY = 65 * scale
    local count = 0
    local cardWidth = 130 - 55
    local cardHeight = 173
    cardWidth = cardWidth * scale
    cardHeight = cardHeight * scale
    local initY = cardHeight / 2
    local userCount = #result - 1
    local size = self.hand_vw:getSize()
    local initX = (size.width - cardWidth * userCount ) / 2 
    for idx, cards in ipairs(result) do
        local posX = initX + (idx - 1) * cardWidth
        local zOrder = 5
        for index, pokerCard in ipairs(cards) do
            -- local pokerCard = CardUtils:getPokerCard( pokerCards, ziPaiCard )
            local cardNode = Card.new(pokerCard, "max")
            local y = initY + (index - 1) * interY
            cardNode:setZOrder(zOrder)
            cardNode:setScale(scale)
            cardNode:setPosition(math.ceil(posX), y)
            cardNode:addTo(self.hand_vw)
            cardNode._cardType = cards._type
            zOrder = zOrder - 1
            if cardNode._cardType == g_392.t_wei then
                cardNode:setColor(cc.c3b(127,127,127))
            end
            cardNode:onTouch(handler(self, self.onClickHandCard))
        end
    end
end

function UserInfoView:removeHandCards( cards, curOutCard )
    for idx, card in ipairs(cards) do
        if curOutCard == card then
            table.remove(cards, idx)
            break
        end
    end
    local count = 0
    local childs = self.hand_vw:getChildren()
    for i,card in ipairs(cards) do
        for idx,node in ipairs(childs) do
            if node._pokerCard == card then
                table.remove(childs, idx)
                node:removeSelf()
                count = count + 1
                break        
            end
        end
    end
    self:setCurHandCardsPos()
    return count
end

--cardNode有值的话就往最后加一列 没有的话就刷新位置
function UserInfoView:setCurHandCardsPos(cardNode, isBegin)
    local posArr = {}
    local childs = self.hand_vw:getChildren()
    local colCount = 0
    for i,node in ipairs(childs) do
        if cardNode ~= node then
            local pos = node:getPosition()
            pos.x = math.ceil(pos.x)
            if not posArr[pos.x] then
                posArr[pos.x] = {}
                colCount = colCount + 1
            end
            table.insert(posArr[pos.x], node)
        end
    end
    local resultNode = {}
    for posX, nodes in pairs(posArr) do
        table.sort(nodes, function( a, b )
            local posa = a:getPosition()
            local posb = b:getPosition()
            return posa.y < posb.y
        end)
        nodes.posX = posX
        table.insert(resultNode, nodes)
    end
    table.sort(resultNode, function( a, b )
        return a.posX < b.posX
    end)
    if cardNode then
        if isBegin then
            table.insert(resultNode, 1, {cardNode})
        else
            table.insert(resultNode, {cardNode})
        end
        colCount = colCount + 1
    end
    local scale = 0.6
    local interY = 65 * scale
    local count = 0
    local cardWidth = 130 - 55
    local cardHeight = 173
    cardWidth = cardWidth * scale
    cardHeight = cardHeight * scale

    local initY = cardHeight / 2
    local userCount = colCount - 1
    local size = self.hand_vw:getSize()
    local initX = (size.width - cardWidth * userCount ) / 2 
    for idx, nodes in pairs(resultNode) do
        local posX = initX + (idx - 1) * cardWidth
        local zOrder = 5 + idx
        for index, cardNode in ipairs(nodes) do
            local y = initY + (index - 1) * interY
            cardNode:setPosition(math.ceil(posX), y)
            cardNode:setZOrder(zOrder)
            zOrder = zOrder - 1
        end
    end
end
----------------------

return UserInfoView
