local UserInfoView = class("UserInfoView")
local Card = require("xupuphz.src.Card")
local CardUtils = require("xupuphz.src.CardUtils")
local cardWidth = 45
local cardHeight = 59
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
    self.txt_guchou = player.txt_guchou:hide()
    self.img_txt = player.img_txt:hide()
    self.timeNode = player.timeNode:hide()
    self.img_chu = player.img_chu:hide()
    self.ArmatureNode_6 = player.ArmatureNode_6:hide()
    self.img_light = self.cards_vw[self.name.."_img_light"]:hide()
    self.outCard = player:getParent()[self.name.."_outCard"]:hide()
    self.out_vw = self.cards_vw[self.name.."_out_vw"]:removeAllChildren()
    self.img_head = player.img_head
    self.typeCards_vw = self.cards_vw[self.name.."_typeCards_vw"]:removeAllChildren()
    self.worldpoint = (self.img_head:getParent()):convertToWorldSpace(self.img_head:getPosition()) --这样写是为了贴近函数的原始用法


    if self.name == "player_3" then
        self.txt_huXi = player.txt_huXi:setString("")
        self.txt_piao = player.txt_piao:setString("")
    else
        self.txt_huXi = self.cards_vw[self.name.."_txt_huXi"]:setString("")
        self.txt_piao = self.cards_vw[self.name.."_txt_piao"]:setString("")
    end

    if self.name == "player_1" then
        self.img_ready = player:getParent().img_ready:hide()
    else
        self.img_ready = player.img_ready:hide()
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
    self:isShowTxtGuChou(false)
    self.ArmatureNode_6:hide()
    -- self:isShowPiaoCount(false) 
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
	-- self.txt_piao:setVisible(isShow)
	-- self.txt_piao:setString("飘:"..count)
end

function UserInfoView:isShowTxtGuChou(isShow)
	self.txt_guchou:setVisible(isShow)
end

function UserInfoView:refreshPlayerInfo(icon_url, uid, sex, name, ip, addres)
	local size = self.img_head:getContentSize()
	require("hall.GameCommon"):getUserHead(icon_url, uid, sex, self.img_head, size.width, true, name, false, ip, addres)
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
    -- self.img_light:setVisible(isShow)
    self.img_chu:setVisible(isShow)
    local outTime = tonumber(g_392.gameConfig.auto_ai) or 0
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

function UserInfoView:isShowOutCard(isShow, card, isDiPai) 
    self.outCard:setVisible(isShow)
    if card then
        self.card = card
        self.outCard:setVisible(isShow)
        Card:changeImg(self.outCard, card, "max")
        if isDiPai then
            self.outCard.img_di:show()
        else
            self.outCard.img_di:hide()
        end
    end
end


function UserInfoView:showOutCard(card, cardsIdx)
    if not cardsIdx then
	    cardsIdx = self.out_vw:getChildrenCount() + 1
    end
    local cardNode = Card.new(card, "min")
	local size = self.out_vw:getSize()
    local scale = 0.7
    local cardWidth = cardWidth
    local cardHeight = cardHeight
    cardHeight = scale * (cardHeight)
    cardWidth = scale * (cardWidth)
    local oriX = size.width - cardWidth / 2
    local oriY = cardHeight / 2
    local row = 6
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
        local ziPaiCard = CardUtils:getZiPaiCard(pokerCard)
        self.allCards[ziPaiCard..""] = WeaveItem
    end
    
   
    self.typeCardsIdx = self.typeCardsIdx + 1
	local size = self.typeCards_vw:getSize()
    local scale = 1
    local cardWidth = cardWidth
    local cardHeight = cardHeight
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
    local size = #cards
    for idx, card in ipairs(cards) do
        local cardNode = Card.new(card, "min")
        cardNode:setZOrder(size)
        size  = size - 1
        local y = oriY + (idx - 1) * (cardHeight-22)
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
        -- path = "txt_hu.png"
    end
    self.img_txt:loadTexture("xupuphz/res/GameScene/player/"..path)
    self.img_txt:ignoreContentAdaptWithSize(true)
    self.img_txt:show()
    self.time = 1
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
            self.img_txt:hide()
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


function UserInfoView:showZiMoOrHu(_type, callFunc)
    self.ArmatureNode_6:show()
    local anim = self.ArmatureNode_6:getAnimation()
    anim:playWithNames({_type}, 0, false)
    local function handler1(Armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
            callFunc()
        end
    end
	anim:setMovementEventCallFunc(handler1)
end

return UserInfoView
