local UserInfoView = class("UserInfoView")
local Card = require("jchuapai.src.Card")
local CardHuXiUtils = require("jchuapai.src.CardHuXiUtils").new()
function UserInfoView:ctor(player)
    self.player = player
    self.typeCardsIdx = 0
    self.allCards = {}--对 招 泛的牌{[0x01] = {}}
    self:initUI(player)
end

function UserInfoView:initUI(player)
    self.name = player:getName()
    self.cards_vw = player:getParent():getParent().cards_vw
    player:scheduleUpdateWithPriorityLua(handler(self, self.update), 0)
    self.txt_score = player.txt_score:setString("")
    self.txt_name = player.txt_name:setString("")
    self.img_zhuang = player.img_zhuang:hide()
    self.img_network = player.img_network:hide()
    self.img_hu = player.img_hu:hide()
    self.img_tong = player.img_tong:hide()
    self.txt_tong = player.txt_tong:setString("")
    self.txt_hu = player.txt_hu:setString("")
    self.img_txt = player.img_txt:hide()
    self.timeNode = player.timeNode:hide()
    self.img_light = self.cards_vw[self.name.."_img_light"]:hide()
    self.outCard = player:getParent()[self.name.."_outCard"]:hide()
    self.out_vw = self.cards_vw[self.name.."_out_vw"]:removeAllChildren()
    self.img_head = player.img_head
    self.typeCards_vw = player:getParent()[self.name.."_typeCards_vw"]:removeAllChildren()
    self.worldpoint = (self.img_head:getParent()):convertToWorldSpace(self.img_head:getPosition()) --这样写是为了贴近函数的原始用法
   
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
    self:isShowTongCountd(false) 
    self:isShowHuCountd(false) 
end

function UserInfoView:getWorldpoint()
    return self.worldpoint
end

function UserInfoView:getFanCards()
    local fan = {}
    for _,cards in pairs(self.allCards) do
        if #cards == 4 then
            local card = cards[1]
            if card <= 25 then
                card = card % 16
            end
            fan[card] = 4
        end 
    end
    return fan
end

--刷新玩家的积分分数
function UserInfoView:setScore(score)
	self.txt_score:setString(tonumber(score) / 100)
end

function UserInfoView:isShowTongCountd(isShow, count)
    if not count then
        count = 0
    end
	self.img_tong:setVisible(isShow)
	self.txt_tong:setVisible(isShow)
	self.txt_tong:setString(count)
end

function UserInfoView:isShowHuCountd(isShow, count)
    if not count then
        count = 0
    end
	self.img_hu:setVisible(isShow)
	self.txt_hu:setVisible(isShow)
	self.txt_hu:setString(count)
end

function UserInfoView:refreshPlayerInfo(icon_url, uid, sex, name, ip, addres)
    local size = self.img_head:getContentSize()
    
	name = require("hall.GameCommon"):formatNick(name, 3)
	self.txt_name:setString(name or "")

    --黑夜模式
    if g_388.gameModel == 1 then
        self.img_head:loadTexture("jchuapai/res/GameScene/headimg.png")
        self.txt_name:setString("黑衣人")
    else
        require("hall.GameCommon"):getUserHead(icon_url, uid, sex, self.img_head, size.width, false, name, g_388.disableTouch, ip, addres)
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

function UserInfoView:isShowLight(isShow) 
    self.img_light:setVisible(isShow)

    local outTime = tonumber(g_388.gameConfig.auto_ai) or 0
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

function UserInfoView:isShowOutCard(isShow, card) 
    self.outCard:setVisible(isShow)
    if card then
        self.card = card
        self.outCard:setVisible(isShow)
        Card:changeImg("long", card, self.outCard)
    end
end

function UserInfoView:changeImg() 
    if self.card then
        Card:changeImg("long", self.card, self.outCard)
    end
end

function UserInfoView:showOutCard(card, cardsIdx)
    if not cardsIdx then
	    cardsIdx = self.out_vw:getChildrenCount() + 1
    end
    local cardNode = Card.new("short", card)
	local size = self.out_vw:getSize()
	local cardHeight = 48
	local cardWidth = 38
    local scale = 0.7
    cardHeight = scale * (cardHeight + 4)
    cardWidth = scale * (cardWidth + 4)
    local oriX = cardWidth / 2 + 4
    local oriY = size.height - cardHeight / 2 - 2
    local row = 10
    local col = 6--一列有9个
    local x, y
    if self.name == "player_1" then
        local rowIdx = cardsIdx % row
        rowIdx = rowIdx == 0 and row or rowIdx
        local colIdx = math.ceil(cardsIdx/ row)
        x = oriX + (rowIdx - 1) * cardWidth
        y = oriY - (colIdx - 1) * cardHeight
    elseif self.name == "player_2" then
        local oriY = size.height - cardHeight / 2 - 2
        local colIdx = cardsIdx % col
        colIdx = colIdx == 0 and col or colIdx
        local rowIdx = math.ceil(cardsIdx / col)
        x = oriX + (rowIdx - 1) * cardWidth
        y = oriY - (colIdx - 1) * cardHeight
    elseif self.name == "player_3" then
        local oriX = size.width - cardWidth / 2 - 4
        local oriY = size.height - cardHeight / 2 - 2
        local colIdx = cardsIdx % col
        colIdx = colIdx == 0 and col or colIdx
        local rowIdx = math.ceil(cardsIdx / col)
        x = oriX - (rowIdx - 1) * cardWidth
        y = oriY - (colIdx - 1) * cardHeight
    end
    cardNode:setPosition(cc.p(x, y))
    cardNode:setScale(scale)
    self.out_vw:addChild(cardNode)
end

function UserInfoView:showTypeCards(cards, _type)
    local card = cards[1]
    if card <= 25 then
        card = card % 16
    end
    table.sort(cards)
    if not self.allCards[card] then
        self.typeCardsIdx = self.typeCardsIdx + 1
    end
    self.allCards[card] = cards
    dump(self.allCards,"self.allCards")
	local size = self.typeCards_vw:getSize()
	local cardHeight = 48
	local cardWidth = 38
    local scale = 0.7
    cardHeight = scale * (cardHeight - 2)
    cardWidth = scale * (cardWidth)
    local oriX = cardWidth / 2
    local oriY = cardHeight / 2
    local x = oriX + (self.typeCardsIdx - 1) * cardWidth
    if self.name == "player_2" then
        oriX = size.width - cardWidth / 2
        x = oriX - (self.typeCardsIdx - 1) * cardWidth
    end
    if _type == "fan" then
        local chlds = self.typeCards_vw:getChildren()
        for i,card in ipairs(cards) do
            for idx, node in ipairs(chlds) do
                if node._card == card then
                    x = math.ceil(node:getPositionX())
                    node:removeSelf()
                    table.remove(chlds, idx)
                    break
                end
            end
        end
    end
    for idx, card in ipairs(cards) do
        local cardNode = Card.new("short", card)
        local y = oriY + (idx - 1) * cardHeight
        cardNode:setPosition(cc.p(x, y))
        cardNode:setScale(scale)
        self.typeCards_vw:addChild(cardNode)
    end
    self:setHuXi()
end

function UserInfoView:setHuXi()
    local allHuXi = 0
    for k,cards in pairs(self.allCards) do
        local huxi = 0
        if #cards == 3 then
            huxi = CardHuXiUtils:CalDuiHuXi( cards )
        else
            huxi = CardHuXiUtils:CalHuXi( cards )
        end
        allHuXi = allHuXi + huxi
    end
    self:isShowHuCountd(true, allHuXi)
end

function UserInfoView:showImgTxt(type_)
    local path = "txt_zimo.png"
    if type_ == "dui" then
        path = "txt_dui.png"
    elseif type_ == "fan" then
        path = "txt_fan.png"
    elseif type_ == "hu" then
        path = "txt_hu.png"
    elseif type_ == "tong" then
        path = "txt_tong.png"
    elseif type_ == "zhao" then
        path = "txt_zhao.png"
    end
    self.img_txt:loadTexture("jchuapai/res/GameScene/player/"..path)
    self.img_txt:show()
    self.time = 2
end

function UserInfoView:show( )
    self.player:show()
end

function UserInfoView:hide( )
    self.player:hide()
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

return UserInfoView
