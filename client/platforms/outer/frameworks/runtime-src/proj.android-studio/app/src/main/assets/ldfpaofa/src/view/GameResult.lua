local Card = require("ldfpaofa.src.Card")
local SendHandle = require("ldfpaofa.src.handle.SendHandle")
local GameResult = class("GameResult", function()
    if device.platform == "ios" then
        if isiOSVerify then
            return cc.CSLoader:createNode("ldfpaofa/res/GameResult/GameResult.csb")
        else
            return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "ldfpaofa/res/GameResult/GameResult.csb")
        end
    else
        return cc.CSLoader:createNode("ldfpaofa/res/GameResult/GameResult.csb")
    end
    -- return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath().."ldfpaofa/res/GameResult/GameResult.csb")
end)
local CardUtils = require("ldfpaofa.src.CardUtils").new()

local MingTangTxt = {
	[0] = "无效",
	[1] = "大团圆",
	[2] = "背靠背",
	[3] = "碰碰胡",
	[4] = "行行息",
	[5] = "耍猴",
	[6] = "海底胡",
	[7] = "十八大",
	[8] = "十六小",
	[9] = "天胡",
	[10] = "地胡",
	[11] = "小红胡",
	[12] = "黑乌",
	[13] = "点胡",
	[14] = "小卡胡",
	[15] = "大卡胡",
	[16] = "大红胡",
	[17] = "一块扁",
	[144] = "黄庄",
}
function GameResult:ctor(data, txt_roomId, GameSceneView)
    self.data = data
    self.GameSceneView = GameSceneView

   
    GameUtils.setNodeNameBindObj(self)
    self:setMask()
    self:initUI()
    self:initEvent()
    self:setData(self.data)
    -- self.root.txt_roomId:setString("房间号:"..txt_roomId)
    self:setName("GameResult")
end

function GameResult:initUI()
	self.root = self.root
	self.card_item = self.card_item:hide()
	self.item = self.item:hide()
	self.bg_lose = self.root.bg_lose
	self.bg_win = self.root.bg_win
	self.title_win = self.root.title_win
	self.title_lose = self.root.title_lose
	self.player_vw = self.root.player_vw
    self.btn_again = self.root.btn_again:hide()
    self.btn_zhanji = self.root.btn_zhanji:hide()
	self.diCard_vw = self.root.diCard_vw
    self.chouCard_vw = self.root.chouCard_vw
    self.txt_chou = self.root.txt_chou:hide()
	self.diCard_vw:removeAllChildren()
    self.chouCard_vw:removeAllChildren()

    self.btn_hall = self.root.btn_hall:hide()
    if g_345.gameConfig.modetype == 2 then--1 100胡息结算 2 单局结算
        self.btn_hall:show()
    else
        local size = self:getContentSize()
        self.btn_again:setPositionX(size.width / 2)
        self.btn_zhanji:setPositionX(size.width / 2)
    end
end

function GameResult:initEvent()
    self.btn_again:onClick(handler(self, self.onClick_close), true)
    self.btn_zhanji:onClick(handler(self,self.onClick_zhanji))
    self.btn_hall:onClick(handler(self,self.onClick_hall))
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
        local seat_id = userInfo.seat_id
        local item = self.item:clone()
        item:show()
        GameUtils.setNodeNameBindObj(item)
        item.img_selected:setVisible(uid == USER_INFO.uid)
        item.img_zhuang:setVisible(seat_id == g_345.banker_seat_id)
        local x = oriX + (idx - 1) * itemSize.width
        item:setPosition(cc.p(x, oriY))
        self.player_vw:pushBackCustomItem(item)
        self:setItem( userInfo, item, huUserInfos[uid] )
    end
    self:showOutCard(data.currCardArr, "currCardArr")
    if data.chouCardArr and #data.chouCardArr > 0 then
        self.txt_chou:show()
        self:showOutCard(data.chouCardArr, "chouCardArr")
    else
        self.txt_chou:hide()
    end

    if huUserInfos[USER_INFO.uid] then
        self.bg_win:show()
        self.title_win:show()
        self.bg_lose:hide()
        self.title_lose:hide()
    else
        self.bg_win:hide()
        self.title_win:hide()
        self.bg_lose:show()
        self.title_lose:show()
    end
end

function GameResult:setItem( itemData, item, huUserInfo )
    item.img_fan:hide()
    item.fan_card:hide()
    local uid = itemData.uid
    local userInfo = g_345.userInfos[uid]
    local seat_id = itemData.seat_id
    
    item.txt_name:setString(userInfo.nickName)

    local size = item.img_head:getContentSize()
    require("hall.GameCommon"):getUserHead(userInfo.portrait, uid, userInfo.sex, item.img_head, size.width, false, nil, true)
    local cardsResult = {}
    self:handCards( cardsResult, itemData.tiList, 4, g_345.t_ti )
    self:handCards( cardsResult, itemData.paoList, 4, g_345.t_pao )
    self:handCards( cardsResult, itemData.weiList, 3, g_345.t_wei )
    self:handCards( cardsResult, itemData.pengList, 3, g_345.t_peng )
    self:handCards( cardsResult, itemData.biList, 3, g_345.t_chi )
    self:handCards( cardsResult, itemData.chiList, 3, g_345.t_chi )
    local txt_msg = ""
    if huUserInfo and uid == huUserInfo.uid then
        item.img_hu:show()
        item.txt_msg:show()
        item.hu_card:show()
        Card:changeImg(item.hu_card, self.data.m_HuCard, "short")

        
        if g_345.fanData then
            item.img_fan:show()
            item.fan_card:show()
            Card:changeImg(item.fan_card, g_345.fanData.srcCardDatas[1], "short")
            txt_msg = txt_msg.."翻醒："..huUserInfo.fanxincount.."\n"
        else
            local y = item.img_hu:getPositionY() - 35
            item.img_hu:setPositionY(y)
            local y = item.hu_card:getPositionY() - 35
            item.hu_card:setPositionY(y)
        end

        if self.data.isZiMo == 1 then
            txt_msg = "自摸 "
        elseif self.data.nFangPaoSeat >= 0 then
            txt_msg = "放炮 "
        end
		for _,tai in ipairs(huUserInfo.taiList) do
			txt_msg = txt_msg..MingTangTxt[tai].." "
        end
        if txt_msg ~= "" then
            txt_msg = "\n"..txt_msg
        end

        local handCardArr = itemData.handCardArr
        if self.data.m_HuCard then
            table.insert(handCardArr, self.data.m_HuCard)
        end
        for idx, cardGroupArr in ipairs(huUserInfo.cardGroupArr) do
            local ziPaiCards = cardGroupArr.cards
            local _type = ""
            if cardGroupArr.type == 1 then
               _type = g_345.t_chi
            elseif cardGroupArr.type == 2 then
               _type = g_345.t_peng
            elseif cardGroupArr.type == 3 then
               _type = g_345.t_wei
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
        local newCards = {}
        for i,v in ipairs(cbCardList) do
            table.insert(newCards, 1, v)
        end
        for idx = 1, 4 do
            card_item["card_"..idx]:hide()
        end
        for idx, card in ipairs(newCards) do
            local cardNode = card_item["card_"..idx]
            cardNode:show()
            Card:changeImg(cardNode, card, "min")
        end

        -- if huUserInfo and uid == huUserInfo.uid then
            card_item.txt_type:show()
            local huXi = CardUtils:GetWeaveHuXi(WeaveItem)
            local _type = g_345.txtType[WeaveItem.cardType]
            if WeaveItem.isShowTxtType == false then
                _type = huXi
            elseif not _type then
                _type = ""
            else
                huXi = "("..huXi..")"
                _type = _type..huXi
            end
            card_item.txt_type:setString(_type)
        -- else
        --     card_item.txt_type:hide()
        -- end
    end

    local huxi = "分："
    if itemData.m_turnBlc/100 > 0 then
        huxi = huxi.."+"..(itemData.m_turnBlc/100).." "
    else
        huxi = huxi..(itemData.m_turnBlc/100).." "
    end

    if g_345.gameConfig.modetype == 1 then--1 100胡息结算 2 单局结算
        huxi = ""
    end

    huxi = huxi.."胡息："
    if itemData.m_turnBlc/100 > 0 then
        huxi = huxi.."+"..(itemData.m_turnBlc/100).." "
    else
        huxi = huxi..(itemData.m_turnBlc/100).." "
    end
    -- if g_345.gameConfig.modetype == 2 then--1 100胡息结算 2 单局结算
    --     if itemData.m_turnBlc/100 > 0 then
    --         huxi = huxi.." 得分：+"..(itemData.m_turnBlc/100).." "
    --     else
    --         huxi = huxi.." 得分："..(itemData.m_turnBlc/100).." "
    --     end
    -- end

    if g_345.isPiao then
        local piao = g_345.piaoPoints[seat_id] or 0
        local chong = " 飘："..piao.." "
        txt_msg = txt_msg..chong
    end
    txt_msg = huxi..txt_msg
    item.txt_msg:setString(txt_msg)
end

function GameResult:handCards( cardsResult, value, num, _type )
    for i,data in ipairs(value) do
        local card = data.card
        local cards = {}
        if _type == g_345.t_ti then
            cards = {card, 0, 0, 0}
        elseif _type == g_345.t_pao then
            cards = {card, card, card, card}
        elseif _type == g_345.t_peng then
            cards = {card, card, card}
        elseif _type == g_345.t_wei then
            cards = {card, 0, 0}
        elseif _type == g_345.t_chi then
            cards = data.cards
        end
        table.insert(cardsResult, {cbCardList = cards, cardType = _type})
    end
end

function GameResult:showOutCard(cards, _type)
    local scale = 1
    local size = Card:getMinCardSize( )
    local cardWidth = size.width * scale
    local cardHeight = size.height * scale

    local size = self.diCard_vw:getSize()
    if _type == "chouCardArr" then
        size = self.chouCard_vw:getSize()
    else
        size = self.diCard_vw:getSize()
    end

    local row = 30
    local userCount = #cards > row - 1 and row - 1 or #cards
    local oriX = (size.width - cardWidth * userCount ) / 2 
    local col = 6--一列有9个
    local x, y
    -- local oriX = cardWidth / 2
    local oriY = size.height - cardHeight / 2
    for cardsIdx, card in ipairs(cards) do
        local cardNode = Card.new(card, "min")
        local rowIdx = cardsIdx % row
        rowIdx = rowIdx == 0 and row or rowIdx
        local colIdx = math.ceil(cardsIdx/ row)
        x = oriX + (rowIdx - 1) * cardWidth
        y = oriY - (colIdx - 1) * cardHeight
        
        cardNode:setPosition(cc.p(x, y))
        cardNode:setScale(scale)
        if _type == "chouCardArr" then
            self.chouCard_vw:addChild(cardNode)
        else
            self.diCard_vw:addChild(cardNode)
        end
    end
end

function GameResult:onClick_close(event)
    self.GameSceneView:clearData()
    SendHandle:CLI_READY_GAME(1)
    self:removeSelf()
end

function GameResult:onClick_hall(event)
    SendHandle:quitRoom()
end

function GameResult:onClick_zhanji( )
    if g_345.settlementData then
        self.GameSceneView:settlement(g_345.settlementData)
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
