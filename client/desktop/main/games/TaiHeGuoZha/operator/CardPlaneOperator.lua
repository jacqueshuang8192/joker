--
-- Author: Your Name
-- Date: 2017-09-06 19:30:08
--
local ddzServer = import("TaiHeGuoZha.ddzServer")
local CardPlaneOperator = class("CardPlaneOperator")
local Card = require("TaiHeGuoZha.Card")
local unpack = table.unpack or unpack
local CardAnalysis, CARDTYPE = unpack(require("TaiHeGuoZha.CardAnalysis"))

----dump1(CardAnalysis, "CardAnalysis")
----dump1(CARDTYPE, "CARDTYPE")
tbTipsCards = {}

local cardY = 80 + 25
local jumpCardY = 40

local playerType2CardPlane = {}
local playerType2Cards = {}

local bombColor = cc.c3b(180, 180, 180)
local chooseColor = cc.c3b(140, 140, 140)
local oriColor = cc.c3b(255, 255, 255)

function CardPlaneOperator:init()
    Mycard_layout = cardScene:getChildByName("my_card_plane")
    Mycard_layout:setScaleX(1.0)
    Leftcard_layout = cardScene:getChildByName("left_card_plane")
    Rightcard_layout = cardScene:getChildByName("right_card_plane")
    Topcard_layout = cardScene:getChildByName("top_card_plane")

    self.IntermediatePointY = 80
    self.cardUpPosY = self.IntermediatePointY + 40
    Mycard_layout:onTouch(handler(self, self.onClickHandCard),false)
    -- self:addTouchEventListenerForCards(Mycard_layout)
    local touchCancellLayer = cardScene:getChildByName("touchCancellLayer")
    touchCancellLayer:setTouchEnabled(true)
    touchCancellLayer:addTouchEventListener(
        function(sender, event)
            -- if event == TOUCH_EVENT_BEGAN then
            print("点击空白区域重置牌")
            self:resetCards()
        end
    )

    leftUserData = {}
    rightUserData = {}
    topUserData = {}
    USER_INFO["cards"] = {}

    playerType2CardPlane = {
        [CARD_PLAYERTYPE_MY] = Mycard_layout,
        [CARD_PLAYERTYPE_LEFT] = Leftcard_layout,
        [CARD_PLAYERTYPE_RIGHT] = Rightcard_layout,
        [CARD_PLAYERTYPE_TOP] = Topcard_layout
    }

    playerType2Cards = {
        [CARD_PLAYERTYPE_MY] = USER_INFO["cards"],
        [CARD_PLAYERTYPE_LEFT] = leftUserData,
        [CARD_PLAYERTYPE_RIGHT] = rightUserData,
        [CARD_PLAYERTYPE_TOP] = topUserData
    }
end

function CardPlaneOperator:clearGameDatas()
    tbTipsCards = {}
    ptTouchBegin = cc.p(0, 0)
    BombCardList = {}
    leftUserData = {}
    rightUserData = {}
    topUserData = {}
    USER_INFO["cards"] = {}

    for playerType = 1, 4 do
        self:clearUserCards(playerType)
    end

    self:clearAllOutCards()
end

function CardPlaneOperator:getPlayerCardPlane(playerType)
    return playerType2CardPlane[playerType]
end



--清空特定玩家的手牌
function CardPlaneOperator:clearUserCards(playerType)
    local InhandCardPlane = self:getPlayerCardPlane(playerType)
    if InhandCardPlane then
        InhandCardPlane:removeAllChildren()
    end
end

function CardPlaneOperator:clearOutCards(playerType)
    if cardScene:getChildByName("outcard_plane"):getChildByName("node" .. playerType) then
        cardScene:getChildByName("outcard_plane"):removeChildByName("node" .. playerType)
    end
end

function CardPlaneOperator:clearAllOutCards()
    for seat_id = 0, TaiHeGuoZhaRoomInfo.maxSeatCount - 1 do
        local playerType = self:getPlayerType(seat_id)
        self:clearOutCards(playerType)
    end
end

function CardPlaneOperator:drawUserCards(cards, playerType)
    local InhandCardPlane = self:getPlayerCardPlane(playerType)
    playerType2Cards[playerType] = {}

    InhandCardPlane:setVisible(true)

    self:clearUserCards(playerType)

    if cards == nil then
        return
    end
    local c = Card.new()
    for i, v in ipairs(cards) do
        c:init(v)
        table.insert(playerType2Cards[playerType], {c._value, c._kind})
    end

    Card:sortCard(playerType2Cards[playerType])

    local fixBeginX = 0
    if playerType == CARD_PLAYERTYPE_MY then
        fixBeginX = InhandCardPlane:getContentSize().width / -200
    end

    local secondLineIndex = 17
    for i, v in ipairs(playerType2Cards[playerType]) do
        local img = Card:getCard(v[1], v[2], v == CALLASSCARD and 1 or 0)
        img:addTo(InhandCardPlane)
        img:setScale(0.5 * img:getScale())
        img:setLocalZOrder(i)
        if i <= secondLineIndex then
            img:setPosition(cc.p(fixBeginX + 17 * i, 45 + 0.5 * 60))
        else
            img:setPosition(cc.p(fixBeginX + 17 * (i - secondLineIndex), 0.5 * 60))
        end
    end

end

function CardPlaneOperator:showFarmerBonusCards(flag)
    local outcard_plane = cardScene:getChildByName("outcard_plane")

    for playerType = 1, 4 do
        local node = outcard_plane:getChildByName("node" .. playerType .. "bonus")
        if node then
            if flag == true then
                node:setVisible(true)
            else
                node:removeFromParent()
            end
        end
    end
end

function CardPlaneOperator:showBonusCards(cards, seat_id, offerx, showType)
    offerx = offerx or 25

    local node = display.newNode()

    local outcard_plane = cardScene:getChildByName("outcard_plane")
    node:addTo(outcard_plane)

    local playerType = self:getPlayerType(seat_id)
    node:setName("node" .. playerType)
    node:setVisible(true)

    if showType == "hide" then
        node:setName("node" .. playerType .. "bonus")
        node:setVisible(false)
    end

    local secondLineIndex = 10
    local onelinecount = #cards

    if onelinecount > secondLineIndex then
        onelinecount = secondLineIndex
    end

    local card_position = {
        [CARD_PLAYERTYPE_MY] = cc.p(visibleSize / 2 - ((onelinecount - 1) * offerx) / 2, 340),
        [CARD_PLAYERTYPE_LEFT] = cc.p(160, 450),
        [CARD_PLAYERTYPE_RIGHT] = cc.p(1110 - (onelinecount - 1) * offerx, 450),
        [CARD_PLAYERTYPE_TOP] = cc.p(visibleSize / 2 - ((onelinecount - 1) * offerx) / 2, 540)
    }

    if #cards == 33 then
        card_position[CARD_PLAYERTYPE_MY] = cc.p(visibleSize / 2 - ((onelinecount - 1) * offerx) / 2 - 50, 220)
    end

    local start_x = card_position[playerType].x
    local yh = card_position[playerType].y

    --dump1(offerx, "offerx3")
    for k, v in ipairs(cards) do
        local img = Card:getSmallCard(v[1], v[2])
        img:addTo(node)
        -- img:setPosition(cc.p(start_x+(k-1)*offerx,yh))
        if k <= secondLineIndex then
            img:setPosition(cc.p(start_x + (k - 1) * offerx, yh))
        elseif k > secondLineIndex and k <= 2 * secondLineIndex then
            img:setPosition(cc.p(start_x + (k - 1 - secondLineIndex) * offerx, yh - 30))
        elseif k > 2 * secondLineIndex and k <= 3 * secondLineIndex then
            img:setPosition(cc.p(start_x + (k - 1 - 2 * secondLineIndex) * offerx, yh - 60))
        elseif k > 3 * secondLineIndex and k <= 3 * secondLineIndex then
            img:setPosition(cc.p(start_x + (k - 1 - 3 * secondLineIndex) * offerx, yh - 90))
        end
    end
end

--显示出牌的位置
function CardPlaneOperator:showOutCard(cards, seat_id, offerx, showType, viewId, bVideo)
    offerx = offerx or 35

    local playerType = self:getPlayerType(seat_id)
    if viewId ~= nil then
        playerType = viewId
    end
    
    print("showOutCard ", playerType)
    local outcard_plane = cardScene:getChildByName("outcard_plane")
    local node = outcard_plane:getChildByName("node" .. playerType)

    if node then
        node:removeFromParent()
    end

    node = display.newNode()
    node:addTo(outcard_plane)
    node:setName("node" .. playerType)
    node:setVisible(true)

    if showType == "hide" then
        node:setName("node" .. playerType .. "bonus")
        node:setVisible(false)
    end

    local secondLineIndex = 17
    local onelinecount = #cards

    if onelinecount > secondLineIndex then
        onelinecount = secondLineIndex
    end

    local card_position = {
        [CARD_PLAYERTYPE_MY] = cc.p(visibleSize / 2 - ((onelinecount - 1) * offerx) / 2, 300),
        [CARD_PLAYERTYPE_LEFT] = cc.p(220, 450),
        [CARD_PLAYERTYPE_RIGHT] = cc.p(1050 - (onelinecount - 1) * offerx, 450),
        [CARD_PLAYERTYPE_TOP] = cc.p(visibleSize / 2 - ((onelinecount - 1) * offerx) / 2, 520)
    }
    if bVideo then
        card_position = {
            [CARD_PLAYERTYPE_MY] = cc.p(visibleSize / 2 - ((onelinecount - 1) * offerx) / 2, 250),
            [CARD_PLAYERTYPE_LEFT] = cc.p(320* self:_getScaleParam2(), 450),
            [CARD_PLAYERTYPE_RIGHT] = cc.p((1000 - (onelinecount - 1) * offerx)* self:_getScaleParam2(), 450),
            [CARD_PLAYERTYPE_TOP] = cc.p(visibleSize / 2 - ((onelinecount - 1) * offerx) / 2, 470)
        }
    end

    if #cards == 33 then
        card_position[CARD_PLAYERTYPE_MY] = cc.p(visibleSize / 2 - ((onelinecount - 1) * offerx) / 2 - 50, 220)
    end

    local start_x = card_position[playerType].x
    local yh = card_position[playerType].y
    -- if bVideo then
    --     start_x = card_position[playerType].x * self:_getScaleParam2()
    --     -- yh = card_position[playerType].y * self:_getScaleParam2()
    -- end

    local show_logo = 0

    local magic2CardValue = {}
    print(debug.traceback())
    --dump1(cards)
    if tbPlayCardInfo["card_type"] == CARDTYPE.CT_510K_DC or tbPlayCardInfo["card_type"] == CARDTYPE.CT_510K_SC then
        local t = {[0x05] = true, [0x0A] = true, [0x0D] = true}
        for k, v in ipairs(cards) do
            if v[2] ~= 4 then
                t[v[1]] = nil
            end
        end
        for v, _ in pairs(t) do
            magic2CardValue[#magic2CardValue + 1] = v
        end
    else
        local tempValue = nil
        for k, v in ipairs(cards) do
            if v[2] ~= 4 then
                tempValue = v[1]
                break
            end
        end
        for k, v in ipairs(cards) do
            if v[2] == 4 then
                magic2CardValue[#magic2CardValue + 1] = tempValue
            end
        end
    end

    local showMagicNum = 1
    for k, v in ipairs(cards) do
        --if k == #cards and LandLordSeatIdBang == seat_id then
        show_logo = 0
        --end
        local img
        if v[2] == 4 and magic2CardValue[showMagicNum] then
            img = Card:getCardByMagic(v[1], v[2], magic2CardValue[showMagicNum])
            showMagicNum = showMagicNum + 1
        else
            if CALLASSCARD then
                local assvalue, asskind = Card:init(CALLASSCARD)
                if assvalue == v[1] and asskind == v[2] then
                    show_logo = 1
                end
            end
            img = Card:getCard(v[1], v[2], show_logo)
        end

        img:addTo(node)
        if bVideo then
            img:setScale(0.55 * img:getScale())
        else
            img:setScale(0.7 * img:getScale())
        end

        --显示牌数Logo
        if k == 1 then
            local psLogoc = cc.CSLoader:createNode("TaiHeGuoZha/res/Node.csb")
            local nbbg = psLogoc:getChildByName("nbbg")
            local paishu_txtc = psLogoc:getChildByName("paishu_txt")
            paishu_txtc:setString(CHUPAIDESHULIANG)
            if psLogoc then
                psLogoc:setScale(0.9)
                local cardSize = img:getContentSize()
                local y = cardSize.height * 5 / 9
                local nbbgSize = psLogoc:getContentSize()
                psLogoc:setPosition(cc.p(28, y))
                img:addChild(psLogoc)
                local paishu_txtc = psLogoc:getChildByName("paishu_txt")
                paishu_txtc:setString(#cards)
            end
        end
        if k <= secondLineIndex then
            img:setPosition(cc.p(start_x + (k - 1) * offerx, yh))
        else
            img:setPosition(cc.p(start_x + (k - 1 - secondLineIndex) * offerx, yh - 45))
        end
    end
end

function CardPlaneOperator:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH / CONFIG_DESIGN_WIDTH) * (disHeight / (frameHeight or 0))
end

--设置牌可以触摸
function CardPlaneOperator:setCardTouched(flag)
    for i, cardNode in ipairs(Mycard_layout:getChildren()) do
        if cardNode then
            cardNode:setTouchEnabled(flag)
        end
    end
end

--发牌动画
function CardPlaneOperator:updateSendCard(cards)
    Mycard_layout:removeAllChildren()
    local newCards = {}
    for idx,card in ipairs(cards) do
        if not newCards[card] then
            newCards[card] = 0
        end
        newCards[card] = newCards[card] + 1
    end
    local clientCards = {}
    for card,num in pairs(newCards) do
        local clientCard, huase = Card:init(card)
        local tab = {}
        tab.card = card
        tab.huase = huase
        tab.clientCard = clientCard
        if not clientCards[clientCard] then
            clientCards[clientCard] = {}
            clientCards[clientCard].num = num
            clientCards[clientCard].maxCard = card
            clientCards[clientCard].tals = {}
        else
            clientCards[clientCard].num = clientCards[clientCard].num + num
        end
        if clientCards[clientCard].maxCard < card then
            clientCards[clientCard].maxCard = card
        end
        table.insert(clientCards[clientCard].tals, tab)
    end
    if clientCards[16] and clientCards[17] then --大小王
        if clientCards[16].num + clientCards[17].num >= 4 then
            clientCards[17].num = clientCards[17].num + clientCards[16].num
            for i,tab in ipairs(clientCards[16].tals) do
                table.insert(clientCards[17].tals, tab)
            end
            clientCards[16] = nil
        end
    end
    local newClientCards = {}
    local clientCardsCount = 0
    for value,data in pairs(clientCards) do
        data.clientCard = value
        table.insert( newClientCards, data)
        clientCardsCount = clientCardsCount + 1
    end
    self:sortClientCards(newClientCards)
	local OtherCardScale = 0.86
	local cardHeight = 173 * OtherCardScale
	local cardWidth = 130 * OtherCardScale
	local size = Mycard_layout:getContentSize()
    local MyHandCardInterval = cardWidth *  OtherCardScale * 0.6
	local IntermediatePointX = (size.width - MyHandCardInterval*clientCardsCount)/2
    local index = 1
    for index,data in ipairs(newClientCards) do
        local value, kind = Card:init(data.maxCard)
        local card = Card:getCard(value, kind)
		local target_point_x = (IntermediatePointX - 40 + (index - 1) * MyHandCardInterval)*self:_getScaleParam2()
        local target_point_y = self.IntermediatePointY + 25
        card:setScale(1.3)--OtherCardScale
        card:addTo(Mycard_layout)
		card:setPosition(target_point_x, target_point_y)
		card._cardData = data
        self:setCardNodeFunc(card)
        card:setName(value)
        Card:setCardNum( card, data.num)
        -- print(string.format("show card value = %d size = %d ----------------", value, data.num))
    end
    
    -- dump(newClientCards,"----newClientCards")
end


function CardPlaneOperator:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH / CONFIG_DESIGN_WIDTH) * (disHeight / (frameHeight or 0))
end

function CardPlaneOperator:sortClientCards(clientCards, type)
    if not type then type = "max" end 
    table.sort(
        clientCards,
        function(card1, card2)
            local numberOfCard1 = card1.num
            local numberOfCard2 = card2.num
            local scores1 = card1.clientCard
            local scores2 = card2.clientCard
            -- if scores1 >= 16 and scores2 >= 16 then
            --     return scores1 < scores2
            -- elseif scores1 >= 16 then
            --     return scores2 < scores1
            -- elseif scores2 >= 16 then
            --     return scores2 < scores1
            -- end
            if (numberOfCard2 ~= numberOfCard1) then
                if type == "max" then
                    return numberOfCard2 < numberOfCard1
                elseif type == "min" then
                    return numberOfCard2 > numberOfCard1
                end
            end
            if type == "max" then
                return scores2 < scores1
            elseif type == "sortMin" then
                return scores2 > scores1
            elseif type == "sortMax" then
                return scores2 < scores1
            end
            return scores2 < scores1
        end
    )
end

function CardPlaneOperator:setCardNodeFunc(cardNode)
    cardNode.toWhite = function(cardNode)
        if cardNode.isBoom then
            cardNode:setColor(bombColor)
        else
            cardNode:setColor(oriColor)
        end
    end
    cardNode.toBlack = function(cardNode)
        cardNode:setColor(chooseColor)
    end
    cardNode.isMask = function(cardNode)
        local color = cardNode:getColor()
        for key, value in pairs(color) do
            local value1 = chooseColor[key]
            if value1 ~= value then
                return false
            end
        end
        return true
    end
    cardNode.setMask = function(cardNode,flag)
        if flag then
            cardNode:setColor(chooseColor)
        else
            cardNode:setColor(oriColor)
        end
    end
end

function CardPlaneOperator:onClickHandCard(event)
	local target = event.target
    local nowPlayIndex = 0
    local touchCardSoundPath = {}
    for i = 0, 6 do
        touchCardSoundPath[i] = "TaiHeGuoZha/res/audio/card_click_" .. i .. ".wav"
    end
	if event.name == "moved" or event.name == "began" then
        local x, y = event.x, event.y
        local childs = target:getChildren()
        for i,node in ipairs(childs) do
            if node:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
                local next = i + 1
                local nextNode = childs[next]
                if nextNode then--重叠区域处理
                    if nextNode:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
                        local isMask = nextNode:isMask()
                        if not isMask then
                            dump(node._cardData)
                            nextNode:setMask(true)
                            cc.SimpleAudioEngine:getInstance():playEffect(touchCardSoundPath[nowPlayIndex], false)
                            nowPlayIndex = nowPlayIndex + 1
                            if nowPlayIndex >= 7 then
                                nowPlayIndex = 0
                            end
                        end
                        return
                    end
                end
                local isMask = node:isMask()
                if not isMask then
                    dump(node._cardData)
                    node:setMask(true)
                    cc.SimpleAudioEngine:getInstance():playEffect(touchCardSoundPath[nowPlayIndex], false)
                    nowPlayIndex = nowPlayIndex + 1
                    if nowPlayIndex >= 7 then
                        nowPlayIndex = 0
                    end
                end
			end
		end
	elseif event.name == "ended" or event.name == "cancelled" then
		local nodes = {}
		for i,node in ipairs(target:getChildren()) do
			if node:isMask() then
				local y = math.round(node:getPositionY())
				if y == self.IntermediatePointY then
					y = self.cardUpPosY
				else
					y = self.IntermediatePointY
				end
				node:setPositionY(y)
			end
			node:setMask(false)
		end
	end
end

function CardPlaneOperator:addCard(value, kind, startx, cout, dis, show_landlord, cardvalue, cardlength)
    local isLandlord = 0
    if CALLASSCARD then
        local assvalue, asskind = Card:init(CALLASSCARD)
        if assvalue == value and asskind == kind then
            isLandlord = 1
        end
    end

    local tag = value + (kind + 100) * 20
    local img = Card:getCard(value, kind, isLandlord)

    img._kind = 1

    if img == nil then
        return nil, nil, nil
    end

    Mycard_layout:addChild(img)

    img.toWhite = function(img)
        if img.isBoom then
            img:setColor(bombColor)
        else
            img:setColor(oriColor)
        end
    end

    img.toBlack = function(img)
        img:setColor(chooseColor)
    end


    img.isMask = function(img)
        local color = img:getColor()
        for key, value in pairs(color) do
            local value1 = chooseColor[key]
            if value1 ~= value then
                return false
            end
        end
        return true
    end

    img.setMask = function(img,flag)
        if flag then
            img:setColor(chooseColor)
        else
            img:setColor(oriColor)
        end
    end

    img:setTag(tag)

    --显示牌数Logo
    local psLogo = cc.CSLoader:createNode("TaiHeGuoZha/res/Node.csb")
    local nbbg = psLogo:getChildByName("nbbg")

    local smallking = false
    local bigking = false
    if value == cardvalue then
        if value == 16 or value == 17 then
            cardlength = WanDeZhangShu
        end
        local paishu_txt = psLogo:getChildByName("paishu_txt")
        paishu_txt:setString(cardlength)
    end

    if psLogo then
        psLogo:setScale(0.8)
        local cardSize = img:getContentSize()
        local y = cardSize.height * 5 / 9
        local nbbgSize = psLogo:getContentSize()
        psLogo:setPosition(cc.p(25, y))
        img:addChild(psLogo)
    end
    img:setScale(1.25)
    img:setPosition(cc.p(startx * 5 / 9 - 50 + cout * 80, cardY))
    local x = startx + cout * 80
    local y = cardY
    return img, x, y
end

--重置所有牌的状态
function CardPlaneOperator:resetCards()
    for _, cardNode in ipairs(Mycard_layout:getChildren()) do
        cardNode.selected = 0
        cardNode:setPositionY(cardY)
        cardNode:toWhite()
    end
end

--打牌减少牌
function CardPlaneOperator:reduceCard(cards)
    print("reduceCard ------------------------", debug.traceback())
    dump(cards, "reduceCard === ")
    -- dump(USER_INFO.cards, "USER_INFO.cards == ")
    -- for k, v in pairs(cards) do
    --     for i = #USER_INFO.cards, 1, -1 do
    --         if v[1] == USER_INFO.cards[i][1] and v[2] == USER_INFO.cards[i][2] then
    --             table.remove(USER_INFO.cards, i)
    --             break
    --         end
    --     end
    -- end
    table.sort(cards,function( a,b )
        return a > b
    end)
    local value, kind = Card:init(cards[1])
    dump("--")
    if not value then
        return
    end
    if Mycard_layout:getChildrenCount() == 0 and (not HAS_RECEIVE_GROUP_RESULT) then
        ddzServer:CLIENT_COMMAND_GET_HANDLER_CARD()
    end
    local node = Mycard_layout:getChildByName(value)
    if node then
        node:removeSelf()
    end
    local childs = Mycard_layout:getChildren()
    local size = Mycard_layout:getContentSize()
    local clientCardsCount = #childs
    if clientCardsCount > 0 then
        local OtherCardScale = 0.86
        local cardHeight = 173 * OtherCardScale
        local cardWidth = 130 * OtherCardScale
        local MyHandCardInterval = cardWidth *  OtherCardScale * 0.6
        local IntermediatePointX = (size.width - MyHandCardInterval*clientCardsCount)/2
        for index,node in ipairs(childs) do
            local target_point_x = (IntermediatePointX - 40 + (index - 1) * MyHandCardInterval)*self:_getScaleParam2()
            local target_point_y = self.IntermediatePointY + 25
            node:setPosition(target_point_x, target_point_y)
        end
    end
    
end

--显示别人出的牌排序
function CardPlaneOperator:showOtherCardRank(cards)
    table.sort(
        cards,
        function(a, b)
            --if( a[2]  == 4 and b[2] == 4) then
            return a[1] > b[1]
        end
    )

    return cards
end

--获得要出的牌
function CardPlaneOperator:tobeChuCards()
    local tmp = {}

    for key, cardNode in ipairs(Mycard_layout:getChildren()) do
        if cardNode.selected == 1 then
            table.insert(tmp, {cardNode._value, cardNode._kind})
        end
    end
    return CardAnalysis:AnalyseMagicData(tmp)
end

--提示然后把牌弹出
function CardPlaneOperator:popCard(clientCard)
    --先重置之前牌的选中状态
    local node = Mycard_layout:getChildByName(clientCard)
    self:resetCards()
    --再根据提示的牌队列弹出牌
    if node then
        node:setPositionY(self.cardUpPosY)
    end

end

--检查出牌
function CardPlaneOperator:checkPlayCard(flag)
    local cards = self:tobeChuCards()
    --local str   =  Card:dealCardToString(cards)
    local CardType, realMaxCardValue = CardAnalysis:getType(cards) -- 分析滑出的牌

    --1dump(CardType, "CardType")
    --1dump(cards, "cardscardscardscards")

    if CARDTYPE.CT_ERROR == CardType then
        --if flag then
        require("TaiHeGuoZha.operator.ControlPlaneOperator"):showErrorTips("kind_error")
        --end
        dump("牌型不存在")
        return false
    end

    --检查出的牌是否比上家牌大
    if tbPlayCardInfo and tbPlayCardInfo.last_cards then
        if CardAnalysis:CompareCard(cards, tbPlayCardInfo.last_cards) then
            return true
        else
            require("TaiHeGuoZha.operator.ControlPlaneOperator"):showErrorTips("kind_error")
            print("-----out error small then before----")
            return false
        end
    end

    return true
end

--播放出片的声音&效果
function CardPlaneOperator:playCardsMusic(card_table, type, seat)
    ---[[
    local layout_effect = cardScene:getChildByName("layout_effect")
    local file
    local _uid = SEAT2USERID[seat]
    local playerType = self:getPlayerType(seat)
    -- local sex = THGZ_USERINFO_TABLE[_uid].sex
    local sex = 1
    local main_value = card_table[1][1]
    --dump1(card_table, "card_table===")
    if type == CARDTYPE.CT_SINGLE then --单牌类型
        if sex == 2 then
            file = "1_W" .. ".mp3"
        else
            file = "1_M" ..  ".mp3"
        end
    elseif type == CARDTYPE.CT_DOUBLE then --对牌类型
        if sex == 2 then
            file = "2_W" .. ".mp3"
        else
            file = "2_M" ..  ".mp3"
        end

    elseif type == CARDTYPE.CT_THREE then --三条类型
        if sex == 2 then
            -- file = "Audio_Card_Three_W.mp3"
            file = "3_W" ..  ".mp3"
        else
            -- file = "Audio_Card_Three_M.mp3"
            file = "3_M" ..  ".mp3"
        end
    end
    dump(type,"====type")

    if type ~=nil and type >= 6 then --炸弹
        -- local ArmatureRuns = cardScene:getChildByName("ArmatureRuns")
        -- ArmatureRuns:getAnimation():playWithIndex(0,-1,0)
        if sex == 2 then
            -- file = "Audio_Card_Three_W.mp3"
            file = "Audio_Card_Bomb_M.mp3"
        else
            -- file = "Audio_Card_Three_M.mp3"
            file = "Audio_Card_Bomb_W.mp3"
        end
    end
    if file then
        require("hall.GameCommon"):playEffectSound("TaiHeGuoZha/res/audio/new/" .. file, false)
    end
    --]]
end

function CardPlaneOperator:getPlayerType(seatId) --seatId为服务器座位号
    print("getPlayerType  ", seatId, TaiHeGuoZhaRoomInfo, TaiHeGuoZhaRoomInfo and TaiHeGuoZhaRoomInfo.maxSeatCount)
    if seatId == nil or seatId < 0 then
        return nil
    end
    print("f1")
    if not TaiHeGuoZhaRoomInfo then
        print("self:getPlayerType error", debug.traceback())
        return nil
    end
    print("f2")
    local playerType = CARD_PLAYERTYPE_MY
    if TaiHeGuoZhaRoomInfo.maxSeatCount == 2 then
        if seatId == MY_SEAT_ID then
            playerType = CARD_PLAYERTYPE_MY
        else
            playerType = CARD_PLAYERTYPE_TOP
        end
    else
        local other_index = seatId - MY_SEAT_ID

        if other_index < 0 then
            other_index = other_index + TaiHeGuoZhaRoomInfo.maxSeatCount
        end

        playerType = other_index + 1 -- otherIndex2playerType[other_index]
        if playerType > 4 then
            playerType = 4
        end
    end

    print("f3", playerType)
    return playerType
end
-- //扑克类型
-- #define CT_INVALID                  0                               //错误类型
-- #define CT_SINGLE                   1                               //单牌类型
-- #define CT_DOUBLE                   2                               //对牌类型
-- #define CT_THREE                    3                               //三条类型
-- #define CT_ONE_LINE                 4                               //单连类型
-- #define CT_DOUBLE_LINE              5                               //连对类型
-- #define CT_THREE_LINE               6                               //三连类型（飞机）
-- #define CT_THREE_LINE_TAKE_ONE      7                               //三带单（四人斗地主禁止3带1）
-- #define CT_THREE_LINE_TAKE_DOUBLE   8                               //三带对
-- #define CT_FOUR_LINE_TAKE_ONE       9                               //四带两单（四人斗地主禁止炸弹带其他牌）
-- #define CT_FOUR_LINE_TAKE_DOUBLE    10                              //四带两对（四人斗地主禁止炸弹带其他牌）
-- #define CT_BOMB_CARD                11                              //炸弹类型（四人斗地主里炸弹可以超过4张)
-- #define CT_MISSILE_CARD             12                              //火箭类型
-- #define CT_BOMB_TRAILER_CARD        13                              //四人斗地主：拖车
-- #define CT_FOUR_KING_CARD           14                              //四人斗地主：天王炸弹（4张王）

return CardPlaneOperator
