local Card = require("byzp.src.Card")
local GameResult = class("GameResult", function()
    if device.platform == "ios" then
        if isiOSVerify then
            return cc.CSLoader:createNode("byzp/res/GameResult/GameResult.csb")
        else
            return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "byzp/res/GameResult/GameResult.csb")
        end
    else
        return cc.CSLoader:createNode("byzp/res/GameResult/GameResult.csb")
    end
    -- return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath().."byzp/res/GameResult/GameResult.csb")
end)
local CardUtils = require("byzp.src.CardUtils").new()
local MingTangTxt = {
	[0] = "无效",
	[1] = "门前清",
	[2] = "全油",
	[3] = "碰碰胡",
	[4] = "无油",
	[5] = "全求人",
	[7] = "十八大",
	[8] = "十八小",
	[9] = "天胡",
	[10] = "地胡",
	[11] = "13红",
	[12] = "全黑",
	[13] = "一点红",
}
function GameResult:ctor(data, txt_roomId, GameSceneView)
    self.data = data
    self.GameSceneView = GameSceneView
    -- local csbPath = "byzp/res/GameResult/GameResult.csb"
    -- GameResult.super.ctor(self, csbPath, false, false)

    -- local size = self:getContentSize()
    -- self:setAnchorPoint(0.5, 0.5)
    -- self:setPosition(size.width / 2, size.height / 2)
    GameUtils.setNodeNameBindObj(self)
    self:setMask()
    self:initUI()
    self:initEvent()
    self:setData(self.data)
    self.root.txt_roomId:setString("房间号:"..txt_roomId)
    self:setName("GameResult")
end

function GameResult:initUI()
	self.root = self.root
	self.card_item = self.card_item:hide()
	self.item = self.item:hide()
	self.show_plane = self.root.show_plane
	self.player_vw = self.root.player_vw
    self.btn_again = self.root.btn_again:hide()
    self.btn_zhanji = self.root.btn_zhanji:hide()
	self.diCard_vw = self.root.diCard_vw
    self.chouPai_vw = self.root.chouPai_vw
	self.Text_chouPai = self.root.Text_chouPai:hide()
	self.txt_title = self.root.txt_title:setString("")
	self.diCard_vw:removeAllChildren()
	self.chouPai_vw:removeAllChildren()
end

function GameResult:initEvent()
    self.btn_again:onClick(handler(self, self.onClick_close), true)
    self.btn_zhanji:onClick(handler(self,self.onClick_zhanji))
end

function GameResult:endGame()
    --有总结算数据的话显示查看战绩按钮
    self.btn_again:setVisible(false)
	self.btn_zhanji:setVisible(true)
end

function GameResult:setData( data )
    if self.data.endGame == 1 then
		self.btn_again:setVisible(false)
		self.btn_zhanji:setVisible(true)
	else
		self.btn_again:setVisible(true)
		self.btn_zhanji:setVisible(false)
    end
    local huUserInfos = {}
    for i,v in ipairs(data.huUserArr) do
        local uid = v.uid
        huUserInfos[uid] = v
    end

    local userCount = #data.userArr - 1
    local size = self.player_vw:getSize()
    local itemSize = self.item:getSize()
    itemSize.width = itemSize.width + 5
    local oriX = (size.width - itemSize.width * userCount ) / 2 
    local oriY = size.height / 2
    for idx, userInfo in ipairs(data.userArr) do
        local uid = userInfo.uid
        local item = self.item:clone()
        item:show()
        GameUtils.setNodeNameBindObj(item)
        local x = oriX + (idx - 1) * itemSize.width
        item:setPosition(cc.p(x, oriY))
        self.player_vw:addChild(item)
        self:setItem( userInfo, item, huUserInfos[uid] )
    end
    self:showOutCard(data.currCardArr, "currCardArr")

    if huUserInfos[USER_INFO.uid] then
        self.show_plane:loadTexture("byzp/res/GameResult/bottom_win.png")
        self.txt_title:setString("胜局")
    elseif data.huUserArr[1] then
        self.show_plane:loadTexture("byzp/res/GameResult/bottom_lose.png")
        self.txt_title:setString("败局")
    else
        self.show_plane:loadTexture("byzp/res/GameResult/bottom_lose.png")
        self.txt_title:setString("荒庄")
    end
end

function GameResult:setItem( itemData, item, huUserInfo )
    item.img_fan:hide()
    item.fan_card:hide()
    local uid = itemData.uid
    local userInfo = g_359.userInfos[uid]
    
    item.txt_name:setString(userInfo.nickName)

    local size = item.img_head:getContentSize()
    require("hall.GameCommon"):getUserHead(userInfo.portrait, uid, userInfo.sex, item.img_head, size.width, false, nil, true)
    local cardsResult = {}
    self:handCards( cardsResult, itemData.tiList, 4, g_359.t_ti )
    self:handCards( cardsResult, itemData.paoList, 4, g_359.t_pao )
    self:handCards( cardsResult, itemData.weiList, 3, g_359.t_wei )
    self:handCards( cardsResult, itemData.pengList, 3, g_359.t_peng )
    self:handCards( cardsResult, itemData.biList, 3, g_359.t_chi )
    self:handCards( cardsResult, itemData.chiList, 3, g_359.t_chi )
    local txt_msg = ""
    if huUserInfo and uid == huUserInfo.uid then
        item.img_hu:show()
        item.txt_msg:show()
        item.hu_card:show()
        Card:changeImg(item.hu_card, self.data.m_HuCard, "short")

        if self.data.isZiMo == 1 then
            txt_msg = "自摸"
        else
            txt_msg = "放炮"
        end
		-- for _,tai in ipairs(itemData.taiList) do
		-- 	txt_msg = txt_msg..MingTangTxt[tai].." "
        -- end
        txt_msg = txt_msg.."\n"
        if g_359.fanData then
            item.img_fan:show()
            item.fan_card:show()
            Card:changeImg(item.fan_card, g_359.fanData.srcCardDatas[1], "short")
            txt_msg = txt_msg.."翻醒："..huUserInfo.fanxincount.."\n"
        end

        local handCardArr = itemData.handCardArr
        if self.data.m_HuCard then
            table.insert(handCardArr, self.data.m_HuCard)
        end
        for idx, cardGroupArr in ipairs(huUserInfo.cardGroupArr) do
            local ziPaiCards = cardGroupArr.cards
            local _type = ""
            if cardGroupArr.type == 1 then
               _type = g_359.t_chi
            elseif cardGroupArr.type == 2 then
               _type = g_359.t_peng
            elseif cardGroupArr.type == 3 then
               _type = g_359.t_wei
            elseif cardGroupArr.type == 4 then
               _type = ""
            end
            table.insert(cardsResult, {cbCardList = ziPaiCards, cardType = _type, isShowTxtType = false})
        end
    else
        -- item.txt_msg:hide()
        item.img_hu:hide()
        item.hu_card:hide()
		local result = CardUtils:getCurhandCard(itemData.handCardArr)
        for i,value in ipairs(result) do
            table.insert(cardsResult, {cbCardList = value, cardType = ''})
        end
    end
    item.ListView:removeAllItems()
    for _,WeaveItem in ipairs(cardsResult) do
        local card_item = self.card_item:clone()
        card_item:show()
        GameUtils.setNodeNameBindObj(card_item)
        item.ListView:pushBackCustomItem(card_item)
        local cbCardList = WeaveItem.cbCardList
        for idx = 1, 4 do
            local card = cbCardList[idx]
            local cardNode = card_item["card_"..idx]
            if card then
                cardNode:show()
                Card:changeImg(cardNode, card, "short")
            else
                cardNode:hide()
            end
        end
        if huUserInfo and uid == huUserInfo.uid then
            card_item.txt_type:show()
            card_item.txt_huxi:show()
            local _type = g_359.txtType[WeaveItem.cardType] or ""
            if WeaveItem.isShowTxtType == false then
                _type = ""
            end
            card_item.txt_type:setString(_type)
            local huXi = CardUtils:GetWeaveHuXi(WeaveItem)
            card_item.txt_huxi:setString(huXi)
        else
            card_item.txt_type:hide()
            card_item.txt_huxi:hide()
        end
    end

    local zi = "子："
    if itemData.m_turnBlc/100 > 0 then
        zi = zi..(itemData.m_turnBlc/100).." "
    else
        zi = zi..(itemData.m_turnBlc/100).." "
    end
    local m_oil = "油：" .. itemData.m_oil.." "--油
    txt_msg = txt_msg..zi..m_oil
    item.txt_msg:setString(txt_msg)
end

function GameResult:handCards( cardsResult, value, num, _type )
    for i,data in ipairs(value) do
        local card = data.card
        local cards = {}
        if _type == g_359.t_ti then
            cards = {card, 0, 0, 0}
        elseif _type == g_359.t_pao then
            cards = {card, card, card, card}
        elseif _type == g_359.t_peng then
            cards = {card, card, card}
        elseif _type == g_359.t_wei then
            cards = {card, 0, 0}
        elseif _type == g_359.t_chi then
            cards = data.cards
        end
        table.insert(cardsResult, {cbCardList = cards, cardType = _type})
    end
end

function GameResult:showOutCard(cards, _type)
    local scale = 0.4
    local size = Card:getShortCardSize( )
    local cardWidth = size.width * scale
    local cardHeight = size.height * scale

    local size = self.diCard_vw:getSize()
    if _type == "chouCardArr" then
        size = self.chouPai_vw:getSize()
    else
        size = self.diCard_vw:getSize()
    end
    local row = 30
    local col = 6--一列有9个
    local x, y
    local oriX = cardWidth / 2
    local oriY = size.height - cardHeight / 2 - 2
    for cardsIdx, card in ipairs(cards) do
        local cardNode = Card.new(card, "short")
        local rowIdx = cardsIdx % row
        rowIdx = rowIdx == 0 and row or rowIdx
        local colIdx = math.ceil(cardsIdx/ row)
        x = oriX + (rowIdx - 1) * cardWidth
        y = oriY - (colIdx - 1) * cardHeight
        cardNode:setPosition(cc.p(x, y))
        cardNode:setScale(scale)
        if _type == "chouCardArr" then
            self.chouPai_vw:addChild(cardNode)
        else
            self.diCard_vw:addChild(cardNode)
        end
    end
end

function GameResult:onClick_close(event)
    -- self.GameSceneView:clearData()
    self:removeSelf()
end

function GameResult:onClick_zhanji( )
    if g_359.settlementData then
        self.GameSceneView:settlement(g_359.settlementData)
    end
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
    self.maskLayout:setBackGroundColorOpacity(222)
    self.maskLayout:setTouchEnabled(true)
    self.maskLayout:setVisible(true)
    self:addChild(self.maskLayout, -1000)
end

function GameResult:onExit()
    
end

return GameResult
