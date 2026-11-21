local UserInfoView = class("UserInfoView")
local Card = require("ldfpaofa.src.Card")
local CardUtils = require("ldfpaofa.src.CardUtils")
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
    self.img_shine = player.img_shine:hide()
    self.txt_huXi = player.txt_huXi:setString("")
    self.txt_totalScore = player.txt_totalScore:setString("总胡息:0")
    self.txt_piao = player.txt_piao:setString("")
    -- self.img_txt = player.img_txt:hide()
    self.timeNode = player.timeNode:hide()
    self.outCard = player:getParent()[self.name.."_outCard"]:hide()
    self.outCard.kuang:setZOrder(-1)
    self.fanCard = player:getParent()[self.name.."_fanCard"]:hide()
    self.out_vw = self.cards_vw[self.name.."_out_vw"]:removeAllChildren()
    self.img_head = player.img_head
    self.typeCards_vw = self.cards_vw[self.name.."_typeCards_vw"]:removeAllChildren()
    self.worldpoint = (self.img_head:getParent()):convertToWorldSpace(self.img_head:getPosition()) --这样写是为了贴近函数的原始用法
    self.ArmatureNode_6 = player.ArmatureNode_6:hide()
    self.armatrer_chis = player.armatrer_chis:hide()
    self.img_ready = player.img_ready:hide()
    if self.name == "player_1" then
        local getWinSize = cc.Director:getInstance():getWinSize()
        local inhandSize = player:getContentSize()
        local pos = player:convertToNodeSpace(cc.p(getWinSize.width / 2, getWinSize.height / 2))
        self.img_ready:setPositionX(pos.x)
    end
end

function UserInfoView:clearData()
    self.allCards = {}
    self.typeCardsIdx = 0
    self.out_vw:removeAllChildren()
    self.typeCards_vw:removeAllChildren()
    self:isShowLight(false) 
    self:isShowOutIngCard(false) 
    self:isShowZhuang(false) 
    self:isShowReady(false) 
    self:isShowHuCount(false)
    self.ArmatureNode_6:hide()
    self.armatrer_chis:hide()
    self.fanCard:hide()
    -- self:(false) 
end

function UserInfoView:getWorldpoint()
    return self.worldpoint
end

--刷新玩家的积分分数
function UserInfoView:setScore(score)
    if not score then
        dump()
    end
	self.txt_score:setString(tonumber(score) / 100)
end

function UserInfoView:setTotalScore(score)
    self.txt_totalScore:setString("总胡息:"..score / 100)
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

    if g_345.gameConfig.modetype == 1 then--1 100胡息结算 2 单局结算
        self.txt_totalScore:show()
    else
        self.txt_totalScore:hide()
    end
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

function UserInfoView:isShowLight(isShow, isShowTime) 
    if isShowTime == nil then
        isShowTime = isShow
    end
    self:isShowTime(isShowTime) 
    if isShow then
        local Blink = cc.Blink:create(0.4, 2)
        local RepeatForever = cc.RepeatForever:create(Blink)
        self.img_shine:show()
        self.img_shine:runAction(RepeatForever)
    else
        self.img_shine:hide()
        self.img_shine:stopAllActions()
    end
end
function UserInfoView:isShowTime(isShow) 
    local outTime = tonumber(g_345.gameConfig.auto_ai) or 0
    if outTime ~= 0 then
        if isShow then
            self.timeNode:show()
            self.timeNode.outTime = outTime
        else
            self.timeNode:hide()
            self.timeNode.outTime = nil
        end
    end
end

function UserInfoView:isShowOutIngCard(isShow, card, isShouKuang) 
    isShouKuang = isShouKuang or false
    self.outCard:setVisible(isShow)
    self.outCard.kuang:setVisible(isShouKuang)
    if card then
        self.card = card
        self.outCard:setVisible(isShow)
        Card:changeImg(self.outCard, card, "long")
    end
end

function UserInfoView:isShowCardFan(isShow, card) 
    self.fanCard:setVisible(isShow)
    Card:changeImg(self.fanCard, card, "long")
end

function UserInfoView:getOutCardPos() 
    return self.outCard:getPosition()
end

function UserInfoView:showOutCard(card, cardsIdx, isShowAction)
    if not cardsIdx then
	    cardsIdx = self.out_vw:getChildrenCount() + 1
    end
    local cardNode = Card.new(card, "min")
    local scale = 1
    local size = Card:getMinCardSize( )
    local cardWidth = size.width * scale
    local cardHeight = size.height * scale
	local size = self.out_vw:getSize()
    local oriX = size.width - cardWidth / 2
    local oriY = cardHeight / 2
    local row = 6
    local col = 6--一列有9个
    local x, y
    if self.name == "player_1" or self.name == "player_3" then
        local rowIdx = cardsIdx % row
        rowIdx = rowIdx == 0 and row or rowIdx
        local colIdx = math.ceil(cardsIdx/ row)
        x = oriX - (rowIdx - 1) * cardWidth
        y = oriY + (colIdx - 1) * cardHeight
    elseif self.name == "player_2" then
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

    if isShowAction then
        local pos = self.outCard:getPosition()
        pos = self.out_vw:convertToNodeSpace(pos)
        cardNode:setPosition(pos)
        local MoveTo = cc.MoveTo:create(0.2, cc.p(x, y))
        cardNode:runAction(MoveTo)
    end
end

function UserInfoView:showTypeCards(cards, _type, pokerCard, isAction)
    dump(pokerCard, "showTypeCards")
    local cbCardList = {}
    for i,v in ipairs(cards) do
        table.insert(cbCardList, v)
    end
    if _type == g_345.t_chi then
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
        self.allCards[pokerCard..""] = WeaveItem --必须使用字符串要不然有可能会是 1，2，3之类的key
    end
   
    self.typeCardsIdx = self.typeCardsIdx + 1
    local scale = 1
    local size = Card:getMinCardSize( )
    local cardWidth = size.width * scale
    local cardHeight = size.height * scale
    local oriX = cardWidth / 2
    local oriY = cardHeight / 2
    local x = oriX + (self.typeCardsIdx - 1) * cardWidth
    local size = self.typeCards_vw:getSize()
    local nodeX = size.width * 1.5
    if self.name == "player_3" then
        oriX = size.width - cardWidth / 2
        x = oriX - (self.typeCardsIdx - 1) * cardWidth
        nodeX = 0 - size.width * 1.5
    end

    if _type == g_345.t_pao or _type == g_345.t_ti then
        local isRemove = false
        local chlds = self.typeCards_vw:getChildren()
        for i, poker in ipairs(cards) do
            for idx, node in ipairs(chlds) do
                if node.removeCard == pokerCard  then
                    x = math.ceil(node:getPositionX())
                    node:removeSelf()
                    table.remove(chlds, idx)
                    isRemove = true
                    break
                end
            end
        end
        if isRemove then
            self.typeCardsIdx = self.typeCardsIdx - 1
        end
    end

    local index = 1
    local node = cc.Node:create()
    node:setPosition(cc.p(x, 0))
    self.typeCards_vw:addChild(node)
    if g_345.t_peng == _type or _type == g_345.t_wei then
        node.removeCard = pokerCard
    end
    if g_345.t_ti == _type or _type == g_345.t_wei then
        node.cardValue = cards[1]
    end
    for idx = #cards, 1, -1 do
        local card = cards[idx]
        local cardNode = Card.new(card, "min")
        local y = oriY + (index - 1) * cardHeight
        cardNode:setPosition(cc.p(0, y))
        cardNode:setScale(scale)
        node:addChild(cardNode)
        if _type == g_345.t_chi and idx == 1 then
            cardNode:setColor(cc.c3b(127,127,127))
        end
        index = index + 1
    end
    self:setHuXi()

    if isAction then
        node:setPosition(cc.p(nodeX, 0))
        node:setScale(1.5)
        local ScaleTo = cc.ScaleTo:create(0.1, 1)
        local MoveTo2 = cc.MoveTo:create(0.15, cc.p(x, 0))
        local Sequence = cc.Sequence:create(ScaleTo, MoveTo2)
        node:runAction(Sequence)
    end
end

function UserInfoView:getChiPengCards()
    local nodes = self.typeCards_vw:getChildren()
    local cards = {}
    for _,node in ipairs(nodes) do
        local childs = node:getChildren()
        for idx, cardNode in ipairs(childs) do
            if node.cardValue then--提偎
                table.insert(cards, node.cardValue)
            else
                table.insert(cards, cardNode._pokerCard)
            end
        end
    end
    return cards
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
    local path = "txt_zimo.png"
    if type_ == g_345.t_chi then
        path = "txt_chi.png"
    elseif type_ == g_345.t_peng then
        path = "txt_peng.png"
    elseif type_ == g_345.t_ti then
        path = "txt_ti.png"
    elseif type_ == g_345.t_pao then
        path = "txt_pao.png"
    elseif type_ == g_345.t_wei then
        path = "txt_wei.png"
    elseif type_ == g_345.t_hu then
        -- path = "txt_hu.png"
    end
    -- self.img_txt:loadTexture("ldfpaofa/res/GameScene/player/"..path)
    -- self.img_txt:ignoreContentAdaptWithSize(true)
    -- self.img_txt:show()
    self.time = 2
    local _type = ""
    if type_ == g_345.t_chi then
        _type = "chi"
    elseif type_ == g_345.t_peng then
        _type = "peng"
    elseif type_ == g_345.t_ti then
        _type = "ti"
    elseif type_ == g_345.t_pao then
        _type = "pao"
    elseif type_ == g_345.t_wei then
        _type = "wei"
    end
    self.armatrer_chis:show()
    local anim = self.armatrer_chis:getAnimation()
    anim:playWithNames({_type}, 0, false)
    local function handler1(Armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
        end
    end
	anim:setMovementEventCallFunc(handler1)
end

function UserInfoView:show( )
    self.player:setVisible(true)
end

function UserInfoView:hide( )
    self.player:setVisible(false)
    self:clearData()
    self.img_head:removeAllChildren()
end

function UserInfoView:getName( )
    return self.player:getName()
end

function UserInfoView:update( dt )
    if self.time then
        self.time = self.time - dt
        if self.time <= 0 then
            self.time = nil
            -- self.img_txt:hide()
            self.armatrer_chis:hide()
            
        end
    end

    if self.timeNode.outTime then
        self.timeNode.outTime = self.timeNode.outTime - dt
        local outTime = math.ceil(self.timeNode.outTime) or 0
        self.timeNode.txt_time:setString(outTime)
        if outTime <= 0 then
            self.timeNode:hide()
            self.timeNode.outTime = nil
        end
    end
end


function UserInfoView:showZiMoOrHu(_type)
    self.ArmatureNode_6:show()
    local anim = self.ArmatureNode_6:getAnimation()
    anim:playWithNames({_type}, 0, false)
    local function handler1(Armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
        end
    end
	anim:setMovementEventCallFunc(handler1)
end

return UserInfoView
