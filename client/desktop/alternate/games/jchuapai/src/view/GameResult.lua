local Card = require("jchuapai.src.Card")
local CardUtils = require("jchuapai.src.CardUtils")
local GameResult = class("GameResult", function()
    if device.platform == "ios" then
        if isiOSVerify then
            return cc.CSLoader:createNode("jchuapai/res/GameResult/GameResult.csb")
        else
            return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "jchuapai/res/GameResult/GameResult.csb")
        end
    else
        return cc.CSLoader:createNode("jchuapai/res/GameResult/GameResult.csb")
    end
    -- return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath().."jchuapai/res/GameResult/GameResult.csb")
end)
local CardHuXiUtils = require("jchuapai.src.CardHuXiUtils").new()

function GameResult:ctor(data, mgs)
    self.data = data
    local csbPath = "jchuapai/res/GameResult/GameResult.csb"
    GameUtils.setNodeNameBindObj(self)
    self:setMask()
    self:initUI()
    self:initEvent()
    self:setData(self.data)
    self.txt_msg:setString(mgs)



end

function GameResult:initUI()
    self.txt_msg = self.root.txt_msg
    self.btn_close = self.root.btn_close
    self.diCard_vw = self.root.diCard_vw
    self.player_vw = self.root.player_vw
    self.item = self.root.item:hide()
    self.card_item = self.root.card_item:hide()
end

function GameResult:initEvent()
    self.btn_close:onClick(handler(self, self.onClick_close), true)
end

function GameResult:setData( data )
    local huUserInfo = data.huUserArr[1]
    local userCount = #data.userArr - 1
    local size = self.player_vw:getSize()
    local itemSize = self.item:getSize()
    itemSize.width = itemSize.width + 5
    local oriX = (size.width - itemSize.width * userCount ) / 2 
    local oriY = size.height / 2
    for idx, userInfo in ipairs(data.userArr) do
        local item = self.item:clone()
        item:show()
        GameUtils.setNodeNameBindObj(item)
        local x = oriX + (idx - 1) * itemSize.width
        item:setPosition(cc.p(x, oriY))
        self.player_vw:addChild(item)
        self:setItem( userInfo, item, huUserInfo )
    end
    self:showOutCard(data.currCardArr)
    self.txt_msg:setString("")
end

function GameResult:setItem( itemData, item, huUserInfo )
    local uid = itemData.uid
    local userInfo = g_388.userInfos[uid]
    local m_turnBlc = itemData.m_turnBlc / 100
    if m_turnBlc > 0 then
        item.txt_score:setFntFile("jchuapai/res/GameResult/font_add.fnt")
        m_turnBlc = "+"..m_turnBlc
    else
        item.txt_score:setFntFile("jchuapai/res/GameResult/font_red.fnt")
    end
    item.txt_name:setString(userInfo.nickName)
    item.txt_score:setString(m_turnBlc)
    item.txt_id:setString(uid)

    local size = item.img_head:getContentSize()
    
    --黑夜模式
    if g_388.gameModel == 1 then
        item.img_head:loadTexture("jchuapai/res/GameScene/headimg.png")
        item.txt_name:setString("黑衣人")
    else
        require("hall.GameCommon"):getUserHead(userInfo.portrait, uid, userInfo.sex, item.img_head, size.width, false, nil, true)
    end

    local cardsResult = {}
    local mainJing
    if huUserInfo and uid == huUserInfo.uid then
        self:handCards( cardsResult, itemData.fanList, 5, "泛" )
        self:handCards( cardsResult, itemData.zhaoList, 4, "招" )
        self:handCards( cardsResult, itemData.pengList, 3, "对" )
        local str = "自\n摸"
        local huUserInfoView
        if self.data.isZiMo == 0 and self.data.nFangPaoSeat then
            str = "放\n炮"
        end
        mainJing = huUserInfo.mainJing
        item.img_huCard:show()
        item.txt_1:setString(str)
        item.img_zhuJingCard:show()
        item.txt_huCount:setString(huUserInfo.maxHuXi)
        Card:changeImg("short", huUserInfo.mainJing, item.img_zhuJingCard)
        Card:changeImg("short", self.data.m_HuCard, item.img_huCard)
        for idx, tongCardArr in ipairs(huUserInfo.tongCardArr) do
            table.insert(cardsResult, 1, {cards = tongCardArr.cards, _type = "统"})
        end

        for idx, groupCardArr in ipairs(huUserInfo.groupCardArr) do
            local cards = groupCardArr.cards
            local _type = ""
            if #cards == 3 then
                local card_1 = cards[1]
                local card_2 = cards[2]
                local card_3 = cards[3]
                card_1 = card_1 <= 25 and card_1 % 16 or card_1
                card_2 = card_2 <= 25 and card_2 % 16 or card_2
                card_3 = card_3 <= 25 and card_3 % 16 or card_3
                if card_1 == 0x2d or card_2 == 0x2d or card_3 == 0x2d then--癞子
                    _type = ""
                elseif card_1 == card_2 and card_1 == card_3 then 
                    _type = "坎"
                else
                    _type = "句"
                end
            elseif #cards == 4 then
                _type = "泛"
            elseif #cards == 5 then
                _type = "统"
            end
            if huUserInfo.indexBuPai ~= -1 and huUserInfo.indexBuPai + 1 == idx and CardHuXiUtils:IsKanWeave( cards ) then
                _type = "补"
            end 
            table.insert(cardsResult, {cards = cards, _type = _type})
        end
    else
        self:handCards( cardsResult, itemData.fanList, 5 )
        self:handCards( cardsResult, itemData.zhaoList, 4 )
        self:handCards( cardsResult, itemData.pengList, 3 )
        item.img_huCard:hide()
        item.img_zhuJingCard:hide()
        item.txt_huCount:setString("")
        local maxSize = 12 - #cardsResult
        local result = CardUtils:_findHandCards(itemData.handCardArr, maxSize, 5)
        for i,value in ipairs(result) do
            table.insert(cardsResult, {cards = value})
        end
    end
    item.ListView_1:removeAllItems()
    for index,value in ipairs(cardsResult) do
        local card_item = self.card_item:clone()
        card_item:show()
        GameUtils.setNodeNameBindObj(card_item)
        item.ListView_1:pushBackCustomItem(card_item)
        cards = value.cards
        for idx=1, 5 do
            local card = cards[idx]
            local cardNode = card_item["card_"..idx]
            if card then
                cardNode:show()
                Card:changeImg("short", card, cardNode)
            else
                cardNode:hide()
            end
        end
        
        if huUserInfo and uid == huUserInfo.uid then
            card_item.txt_type:show()
            card_item.txt_score:show()
            local huXi = 0
            if value._type == "对" then
                huXi = CardHuXiUtils:CalDuiHuXi(cards, mainJing)
            -- elseif value._type and value._type ~= "" then
            elseif value._type == "补" then
                huXi = CardHuXiUtils:CalDuiHuXi(cards, mainJing)
                cardsResult[index]._type = ""
            else
                huXi = CardHuXiUtils:CalHuXi(cards, mainJing)
            end
            -- huXi = huXi == 0 and "" or huXi
            card_item.txt_type:setString(value._type)
            card_item.txt_score:setString(huXi)
        else
            card_item.txt_type:hide()
            card_item.txt_score:hide()
        end
    end
end

function GameResult:handCards( result, cards, num, _type )
    -- local result = {}
    while true do
        local newCards = table.splice(cards, 1, num)
        if #newCards == num then
            table.insert(result, {cards = newCards, _type = _type})
        else
            break
        end
    end
    return result
end

function GameResult:showOutCard(cards)
    local size = self.diCard_vw:getSize()
	local cardHeight = 48
	local cardWidth = 38
    local scale = 0.8
    cardHeight = scale * (cardHeight + 4)
    cardWidth = scale * (cardWidth + 4)
    local oriX = cardWidth / 2 + 4
    local oriY = size.height - cardHeight / 2 - 2
    local row = 29
    local col = 6--一列有9个
    for cardsIdx, card in ipairs(cards) do
        local cardNode = Card.new("short", card)
        local x, y
        local rowIdx = cardsIdx % row
        rowIdx = rowIdx == 0 and row or rowIdx
        local colIdx = math.ceil(cardsIdx/ row)
        x = oriX + (rowIdx - 1) * cardWidth
        y = oriY - (colIdx - 1) * cardHeight
        cardNode:setPosition(cc.p(x, y))
        cardNode:setScale(scale)
        self.diCard_vw:addChild(cardNode)
    end
    
end

function GameResult:onClick_close(event)
    self:removeSelf()
end

function GameResult:setMask()
	local director = cc.Director:getInstance()
	local size = director:getWinSize()
    self.maskLayout = ccui.Layout:create()
    self.maskLayout:setAnchorPoint(cc.p(0.5, 0.5))
    self.maskLayout:setContentSize(cc.size(size.width, size.height))

    local size = self:getContentSize()
    self.maskLayout:setPosition(cc.p(size.width / 2, size.height / 2))
    self.maskLayout:setBackGroundColorType(1)
    self.maskLayout:setBackGroundColor(cc.c3b(0, 0, 0))
    self.maskLayout:setBackGroundColorOpacity(150)
    self.maskLayout:setTouchEnabled(true)
    self.maskLayout:setVisible(true)
    self:addChild(self.maskLayout, -1000)
end

function GameResult:onExit()
    
end

return GameResult
