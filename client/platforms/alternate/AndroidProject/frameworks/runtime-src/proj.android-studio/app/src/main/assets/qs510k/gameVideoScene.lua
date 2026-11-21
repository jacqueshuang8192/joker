--[[
* author:   zwm
* date:     2020-06-12
* describe: 棋胜510k战绩回放场景
* explain:  
--]]
local RecordBaseScene = require("hall.record.RecordBaseScene")
local gameVideoScene  = class("gameVideoScene", RecordBaseScene)
local Card            = require("qs510k.Card")
-- local PDKServer = import(TpackageName .. ".src.protocol.PDKServer")
-- local PDKHandle = import(TpackageName .. ".src.protocol.PDKHandle")
-- local PROTOCOL  = require(TpackageName .. ".src.protocol.PDKProtocol")
-- local PDKDefine = require(TpackageName .. ".src.logic.PDKDefine")
local USEFUL_MSG = {}

local CARDTYPE = {
    CT_ERROR        = 0,       --错误类型
    CT_SINGLE       = 1,       --单牌类型
    CT_DOUBLE       = 2,       --对子类型
    CT_THREE        = 3,       --三条类型
    CT_SERDOUBLE    = 4,       --连对类型
    CT_SERTHREE     = 5,       --飞机类型
    CT_510K_DC      = 6,       --副510K
    CT_510K_SC      = 7,       --正510K
     
    CT_BOMB_4       = 8,       --4炸类型
    CT_BOMB_5       = 9,       --5弹类型
    CT_BOMB_6       = 10,       --6炸类型
    CT_BOMB_7       = 11,       --7炸类型
     
    CT_BOMB_TW4     = 12,       --4天王炸弹
     
    CT_BOMB_8       = 13,       --8炸类型
    CT_BOMB_9       = 14,       --9炸类型
    CT_BOMB_10      = 15,      --10炸类型
    CT_BOMB_11      = 16,      --11炸类型
    CT_BOMB_12      = 17,      --12炸类型
}

local HANDLER_CARD_BEGIN_POS = {
    [1] = cc.p(640, 70),
    [2] = cc.p(1100, 360),
    [3] = cc.p(640, 550),
    [4] = cc.p(230, 360),
}

local OUT_CARD_CENTER_POS = {
    [1] = cc.p(640, 170),-- 中间位置
    [2] = cc.p(1040, 360), --结束的位置
    [3] = cc.p(640, 470), -- 中间位置
    [4] = cc.p(310, 360), -- 开始的位置
}

local TOTALCHIPS = nil
function gameVideoScene:ctor(data, level)
    dump(data," ============= 【 回放数据 】 ============== ")
    TpackageName = "qs510k"
    gameVideoScene.super.ctor(self, data, USEFUL_MSG, level, true)
    self._scene = self
    g_mainScene = self

    local info = json.decode(data)
    TOTALCHIPS = info.totalChips
    dump(TOTALCHIPS)

    table.sort(self._allUserInfoMsgs,function(a,b) return a.seatID < b.seatID end )
    self:loadGameLayer()
    self:initGlobalData()
    self:loadAllLayer()
    self:bindMsgProc()
    self:initVideoScene()
end

function gameVideoScene:onEnter()
end

function gameVideoScene:loadGameLayer()
    self._scene = cc.CSLoader:createNode("qs510k/res/GameScene.csb"):addTo(self)
    visibleSize = cc.Director:getInstance():getVisibleSize().width
    self.bg_select_index = 1

    GameUtils.setNodeNameBindObj(self._scene)
    self:_initUI()
    local roomBackGround = self._scene:getChildByName("roomBackGround"):setScale(self:_getScaleParam2())

    cardScene = self._scene
    
    -- require("qs510k.operator.GamePlaneOperator"):init()
    self:initGameMainLayer()
end

function gameVideoScene:_initUI()
    if self._scene then
        local bg = self._scene:getChildByName("roomBackGround")
        local precent = self:_getScaleParam2()
        local root = self._scene
        if root then
            local child = root:getChildren()
            for i, v in ipairs( child or {} ) do
                local x = v:getPositionX()
                v:setPositionX(x*precent)
                if v:getDescription() == "ListView" then --容器按照比率重新设置大小
                    local size = v:getContentSize()
                    v:setContentSize(cc.size(size.width * precent, size.height))
                end
            end
        end
    end
end

function gameVideoScene:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
    -- return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end

function gameVideoScene:initGameMainLayer()
    self._scene:getChildByName("btn_setting"):setVisible(false)
    self._scene:getChildByName("remain_rounds_count_plane"):setVisible(false)
    self._scene:getChildByName("device_info_plane"):setVisible(false)
    self._scene:getChildByName("room_lb_plane"):setVisible(false)

    local layout_ui = self._scene:getChildByName("layout_ui")
    layout_ui:setVisible(true)
    layout_ui:getChildByName("team_btns"):setVisible(false)
    layout_ui:getChildByName("operate_btns"):setVisible(false)
    layout_ui:getChildByName("btn_ready"):setVisible(false)
    layout_ui:getChildByName("btn_startGame"):setVisible(false)
    layout_ui:getChildByName("btn_stand"):setVisible(false)
    layout_ui:getChildByName("btn_showGroupResult"):setVisible(false)
    layout_ui:getChildByName("btn_returnToHall"):setVisible(false)

    self._scene:getChildByName("btn_chat"):setVisible(false)
    self._scene:getChildByName("btn_voice"):setVisible(false)
    self._scene:getChildByName("clock"):setVisible(false)
    self._scene:getChildByName("invite_ly"):setVisible(false) 
    self._scene:getChildByName("huopaiTxt"):setVisible(false)   
    self._scene:getChildByName("btn_gps"):setVisible(false)   

    for i = 1, 4 do
        local playerPanle = self._scene:getChildByName("touxiangbufen_"..i)
        playerPanle:setVisible(false)
    end
    self._handlerCardPanle = {}
    self._outCardPanle     = {}
end

function gameVideoScene:initGlobalData()
    print("initGlobalData ---------------------")
    MAX_PLAYER_SIZE   = 4       --玩家最大人数
    MY_SEAT_ID        = 0       --玩家自己的座位号
    OUT_CARD_TIMES    = 20      --出牌时间
    CARD_INTERVAL     = 70      --手牌的间隙
    CARD_HEIGHT       = 100      --手牌的初始高度
    IS_ROOM_CARD_TYPE = true    --是否为房卡模式
    tableAI = {}
end

function gameVideoScene:clearGlobalData()
    MAX_PLAYER_SIZE = nil
    MY_SEAT_ID = nil
    PDK_CUR_ROUND = nil
    OUT_CARD_TIMES = nil
    CARD_INTERVAL   = nil      --手牌的间隙
    CARD_HEIGHT     = nil      --手牌的初始高度
    IS_ROOM_CARD_TYPE = nil
end

function gameVideoScene:loadAllLayer()
    self:loadVideoLayer()
end

-------------------------------------------------------------------------
-- proc user card and info begin
function gameVideoScene:bindMsgProc()
    self.func_ = {
        --广播用户出牌
        [4609] = {handler(self, self.showOutCard)},
        --广播用户pass
        [4610] = {handler(self, self.showUserPass)},          
        --广播伙牌
        --[4611] = {handler(self, self.showHuoCard)},  
        --广播奖励 
        [0x1205] = {handler(self, self.showUserBombReward)}
    }
end

function gameVideoScene:loadVideoLayer()
    self._videoOptLayer = require("hall.record.RecordOptLayer").new(self)
    -- self._videoOptLayer:setScale(720/1080)
    self._videoOptLayer:setZOrder(10000)
    self._videoOptLayer:addTo(self)
    self._videoOptLayer:resetOptPositionY(310)
end

function gameVideoScene:initVideoScene()
    print("initVideoScene ----------------------")
    self:showAllUserInfo()
    self:showHandlerCards()
end

function gameVideoScene:initUidToViewId(userLst)
    self._uidToViewId = {}
    self._viewIdHandCards = {}
    for i,v in ipairs(userLst or {}) do
        if v.uid then
            self._uidToViewId[v.uid] = self:getViewIdBySeatId(i)
        end
    end
end

function gameVideoScene:showAllUserInfo()
    dump(self._allUserInfoMsgs, " self._allUserInfoMsgs == ")
    self:initUidToViewId(self._allUserInfoMsgs)
    for i,v in ipairs(self._allUserInfoMsgs or {}) do
        local viewPos = self:getViewIdBySeatId(i)
        local info = self:exchangeUserInfoToShowHead(v)
        self:initUser(info, viewPos)
    end

    local count = 1
    local Panel_kuang = self._scene:getChildByName("Panel_kuang")
    Panel_kuang:setVisible(true)
    Panel_kuang:getChildByName("Text_5"):setVisible(false)
    Panel_kuang:getChildByName("tableScore"):setVisible(false)
    if #self._allUserInfoMsgs < 4 then
        for i,v in pairs(self._allUserInfoMsgs) do
            Panel_kuang:getChildByName("tableFen"..i):setVisible(true)
            Panel_kuang:getChildByName("tableFen"..i):setString("0")

            Panel_kuang:getChildByName("tableFen"..count):setVisible(true)
            Panel_kuang:getChildByName("tableName"..count):setVisible(true)
            Panel_kuang:getChildByName("tableName"..count):setString(require("hall.GameCommon"):formatNick(v.nickName, 4))
            count = count + 1
        end

        if TOTALCHIPS and next(TOTALCHIPS) then
            for i,v in ipairs(TOTALCHIPS) do
                Panel_kuang:getChildByName("tableFen"..i):setString(v)
            end
        end
    else
        Panel_kuang:getChildByName("tableName1"):setVisible(true)
        Panel_kuang:getChildByName("tableName2"):setVisible(true)
        local one = require("hall.GameCommon"):formatNick(self._allUserInfoMsgs[1].nickName, 4) .. "," .. require("hall.GameCommon"):formatNick(self._allUserInfoMsgs[3].nickName, 4)
        local two = require("hall.GameCommon"):formatNick(self._allUserInfoMsgs[2].nickName, 4) .. "," .. require("hall.GameCommon"):formatNick(self._allUserInfoMsgs[4].nickName, 4)
        Panel_kuang:getChildByName("tableName1"):setString(one)
        Panel_kuang:getChildByName("tableName2"):setString(two)

        Panel_kuang:getChildByName("tableFen1"):setVisible(true)
        Panel_kuang:getChildByName("tableFen2"):setVisible(true)
        Panel_kuang:getChildByName("tableFen1"):setString("0")
        Panel_kuang:getChildByName("tableFen2"):setString("0")
        if TOTALCHIPS and next(TOTALCHIPS) then
            Panel_kuang:getChildByName("tableFen1"):setString(TOTALCHIPS[1] + TOTALCHIPS[3])
            Panel_kuang:getChildByName("tableFen2"):setString(TOTALCHIPS[2] + TOTALCHIPS[4])
        end
    end
end
    
function gameVideoScene:initUser(info, vPos)
    local playerPanle = self._scene:getChildByName("touxiangbufen_"..vPos)
    playerPanle:getChildByName("network_img"):setVisible(false)
    playerPanle:getChildByName("im_ready"):setVisible(false)
    playerPanle:getChildByName("chips"):setVisible(false)
    playerPanle:getChildByName("cardNumBack"):setVisible(false)
    playerPanle:getChildByName("landlord_flag"):setVisible(false)
    playerPanle:getChildByName("ass_flag"):setVisible(false)
    playerPanle:getChildByName("img_bonus"):setVisible(false)
    playerPanle:getChildByName("txt_bonus"):setVisible(false)

    self:showInfo(info, playerPanle)
end

function gameVideoScene:showInfo(userInfo, plane)
    print("showInfo ===================== ", plane == nil)
    if not plane then
        --todo
        return
    end

    plane:setVisible(true)

    local photoUrl = userInfo["icon_url"]
    local nickname = userInfo["name"]
    local coins = userInfo["score"]

    local portrait = plane:getChildByName("head")
    local nick_lb = plane:getChildByName("nickName_txt")
    local coins_lb = plane:getChildByName("gold_mine")

    local infos = {}
    infos["icon_url"] = photoUrl
    infos["uid"] = userInfo["uid"]
    infos["sex"] = userInfo["sex"]
    -- require("hall.GameCommon"):setPlayerHead(infos, portrait, 46)
    require("hall.GameCommon"):getUserHead(photoUrl, userInfo["uid"], userInfo["sex"], portrait, 64, false, nickname)
    

    nick_lb:setString(require("hall.GameCommon"):formatNick(nickname, 4))

    local coins_str = coins/100
    if coins_str > 100000 then
        coins_str = string.format("%.1f", coins_str / 10000) .. "万"
    end
    coins_lb:setString(coins_str)
    plane:getChildByName("txt_bonus"):setString("0")
end

function gameVideoScene:showHandlerCards()
    for i,v in ipairs(self._allHandCardsMsgs or {}) do
        local viewPos = self:getViewIdBySeatId(i)
        self:showHandCardsForView(viewPos, v)
    end
end

function gameVideoScene:showHandCardsForView(viewPos, cards)
    dump(cards,  "_viewIdHandCards == ")
    self._viewIdHandCards[viewPos] = cards
    local isLandlord = false
    local sortStruCards = self:sortCard(cards)
    --dump(sortStruCards, "sortStruCards == ")
    if self._handlerCardPanle[viewPos] == nil then
        local cardsNode = display.newNode()
        dump(HANDLER_CARD_BEGIN_POS[viewPos], "HANDLER_CARD_BEGIN_POS[viewPos] == ")
        cardsNode:setPosition(self:getHandCardNodePos(viewPos))
        local outcard_plane = self._scene:getChildByName('outcard_plane')
        outcard_plane:addChild(cardsNode)
        self._handlerCardPanle[viewPos] = cardsNode
    end
    self._handlerCardPanle[viewPos]:removeAllChildren()

    local beginX = math.floor((#sortStruCards - 1)/2) * (-20)
    for i,v in ipairs(sortStruCards or {}) do
        local card = Card:getCard(v[1], v[2], isLandlord)
        card:setPosition(cc.p(beginX + (i -1)*20, 0))
        card:setScale(0.4)
        self._handlerCardPanle[viewPos]:addChild(card)
        if viewPos == 2 then 
            self._handlerCardPanle[viewPos]:setRotation(-90)
        elseif viewPos == 4 then
            self._handlerCardPanle[viewPos]:setRotation(90)
        end
    end
end

function gameVideoScene:getHandCardNodePos(vPos)
    return cc.p(HANDLER_CARD_BEGIN_POS[vPos].x*self:_getScaleParam2(), HANDLER_CARD_BEGIN_POS[vPos].y)
end

function gameVideoScene:sortCard(cards)
    local result = {}
    local c  = Card.new()
    for i,v in ipairs(cards)  do
        c:init(v)
        table.insert(result, {c._value,c._kind,0,0,0,v})
    end

    result = Card:HandCardSort(result)
    return result
end

function gameVideoScene:exchangeUserInfoToShowHead(userInfo)
    local result = {}
    result.name = userInfo.nickName
    result.score = userInfo.remainCoins
    result.icon_url = userInfo.photoUrl
    result.uid = userInfo.uid
    result.sex = 0
    result.isReady = false
    return result
end

------------------------------------------------------------------------------------------------------------------------------------
-- proc msg begin
function gameVideoScene:callFunc(pack)
    if self.func_[pack.type] and self.func_[pack.type][1] then
        self.func_[pack.type][1](pack)
    end
end

function gameVideoScene:getMySeatId(userLst)
    dump(USER_INFO, "USER_INFO == ")
    for i,v in ipairs(userLst or {}) do
        if USER_INFO["uid"] == v.uid then
            return i
        end
    end
    return 1--nil
end

function gameVideoScene:getViewIdBySeatId(sId)
    local mySeatId = self:getMySeatId(self._allUserInfoMsgs)
    if mySeatId == nil then return end

    if self._userSize == 2 then
        if sId == mySeatId then
            return 1
        else
            return 3
        end
    else
        if sId == mySeatId then
            return 1
        else
            return (sId - mySeatId + 4 )%4 + 1
        end
    end
end


function gameVideoScene:showOutCard(msg)
    dump(msg, " 【出牌】 showOutCard === ")
    local viewId = self._uidToViewId[msg.uid]
    local cards = {}
    local cardsSrc = {}
    if string.find(msg.cards, ",") ~= nil then
        for i,v in ipairs(string.split(msg.cards, ",")) do
            table.insert(cards, tonumber(v))
        end
    else
        table.insert(cards, tonumber(msg.cards))
    end

    if string.find(msg.cardsSrc, ",") ~= nil then
        for i,v in ipairs(string.split(msg.cardsSrc, ",")) do
            table.insert(cardsSrc, tonumber(v))
        end
    else
        table.insert(cardsSrc, tonumber(msg.cardsSrc))
    end

    if self._outCardPanle[viewId] == nil then
        local cardsNode = display.newNode()
        cardsNode:setPosition(self:getOutCardNodePos(viewId))
        local outcard_plane = self._scene:getChildByName('outcard_plane')
        outcard_plane:addChild(cardsNode)
        self._outCardPanle[viewId] = cardsNode
    end
    self._outCardPanle[viewId]:removeAllChildren()

    self:addCardsToCardNode(cards, cardsSrc, viewId, msg.cardType)
    self:playCardsMusic(cards, msg.cardType) 
    self:reShowHandCards(viewId, cardsSrc)
end

function gameVideoScene:getOutCardNodePos(vPos)
    return cc.p(OUT_CARD_CENTER_POS[vPos].x*self:_getScaleParam2(), OUT_CARD_CENTER_POS[vPos].y)
end

--播放出片的声音&效果
function gameVideoScene:playCardsMusic(cards, type) 
    local layout_effect = self._scene:getChildByName("layout_effect")
    local file
    local sex = 2
    local c  = Card.new()
        c:init(cards[1])
    local main_value = c._value

    if type == CARDTYPE.CT_SINGLE then--单牌类型
		if sex == 2 then
            -- file = "Audio_Card_Three_W.mp3"
            file = "Woman_dan.mp3"
        else
            -- file = "Audio_Card_Three_M.mp3"
            file = "Man_dan.mp3"
        end
    elseif type == CARDTYPE.CT_DOUBLE then--对牌类型
        --对子，带了一个赖子
		local c2 = Card.new()
		c2:init(cards[2])
        if (main_value == 16 or main_value == 17) and main_value ~= c2._value then
			main_value = c2._value
		end
        if main_value then
            if sex == 2 then
                file = "Woman_dui"..main_value..".mp3"
            else
                file = "Man_dui"..main_value..".mp3"
            end
        end
    elseif type == CARDTYPE.CT_THREE then--三条类型
        if sex == 2 then
            file = "Woman_tuple"..main_value..".mp3"
        else
            file = "Man_tuple"..main_value..".mp3"
        end
    --炸弹类型
    elseif  type >= CARDTYPE.CT_510K_DC then

        if sex == 2 then
            file = "Man_zhadan.mp3"
        else
            file = "Man_zhadan.mp3"
        end
        require("qs510k.Animation"):animBoom(layout_effect)
    end
   
    if file then
        require("hall.GameCommon"):playEffectSound("qs510k/audio/new/"..file,false)
    end
end

function gameVideoScene:addCardsToCardNode(cards, cardsSrc, vPos, cardType)
    local imgCards = {}
    local isLandlord = false
    -- for k,v in pairs(cards or {}) do
    --     local c  = Card.new()
    --     c:init(v)
    --     local card = Card:getCard(c._value, c._kind, isLandlord)        
    --     card:setScale(0.6)
    --     table.insert(imgCards, card)
    -- end
    imgCards = self:getOutCardImgs(cards, cardsSrc, cardType, isLandlord)
    if next(imgCards) == nil then return end

    if vPos == 1 or vPos == 3 then
        local beginX = math.floor((#imgCards - 1)/2)*(-25)
        for i,v in ipairs(imgCards) do
            v:setPosition(cc.p(beginX + (i-1) * 25, 0))
            self._outCardPanle[vPos]:addChild(v)
        end
    elseif vPos == 2 then
        local beginX = (#imgCards)*(-25)
        for i,v in ipairs(imgCards) do
            v:setPosition(cc.p(beginX + (i-1) * 25, 0))
            self._outCardPanle[vPos]:addChild(v)
        end
    elseif vPos == 4 then
        for i,v in ipairs(imgCards) do
            v:setPosition(cc.p((i-1) * 25, 0))
            self._outCardPanle[vPos]:addChild(v)
        end
    end
    for k,v in pairs(cards or {}) do
        print(k,v)
    end
end

function gameVideoScene:getOutCardImgs(cards, cardsSrc, cardType, show_logo)
    local result = {}
    local cardsT = {}

    local c  = Card.new()
    for i,v in ipairs(cards)  do
        c:init(v)
        table.insert(cardsT, {c._value,c._kind,0,0,0,v})
    end

    local count = 1
    local magic2CardValue = {}
    local TsrcCards = {}

    local changeCards = clone(cards)
    local srcCards = clone(cardsSrc)

    -- 判断changeCards和srcCards中相同的元素剔除，留下的是癞子变的牌
    for i,v in pairs(changeCards) do
        for j,k in pairs(srcCards) do
            if v == k then
                TsrcCards[count] = k
                count = count + 1
                table.remove(srcCards, j)
                break
            end
        end
    end

    for i,v in pairs(TsrcCards) do
        for j,k in pairs(changeCards) do
            if v == k then
                table.remove(changeCards, j)
                break
            end
        end
    end

    for i,v in ipairs(changeCards) do
        for j,k in ipairs(cardsT) do
            if v == k[1] and k[2] == 0 then
                cardsT[j][2] = 6
                break
            end
        end
    end

    local showMagicNum = 1
    for k,v in ipairs(cardsT) do

        local img
        -- if v[2] == 4 and magic2CardValue[showMagicNum] then
        --     img = Card:getCardByMagic(v[1],v[2],magic2CardValue[showMagicNum])
        --     img:setScale(0.6)
        --     showMagicNum = showMagicNum + 1
        -- else
            img = Card:getCard(v[1],v[2],show_logo)
            img:setScale(0.5)
        --end
        table.insert(result, img)
    end
    
    return result
end

function gameVideoScene:reShowHandCards(viewId, outCards)
    local allCards = clone(self._viewIdHandCards[viewId])
    local deledCards = {}

    dump(allCards, "allCards == ")
    dump(outCards, "outCards == ")
    for i,v in ipairs(outCards or {}) do
        for j, v1 in ipairs(allCards or {}) do
            if v == v1 then
                table.remove(allCards, j)
                break
            end
        end
    end
    deledCards = allCards
    dump(deledCards, "deledCards == ")
    self:showHandCardsForView(viewId, deledCards)
end

function gameVideoScene:showUserPass(msg)
    
    local vPos = self._uidToViewId[msg.uid]
    dump(msg, "showUserPass == ")
    dump(self._uidToViewId[msg.uid], "self._uidToViewId[msg.uid] == ")
    --图片
    if self._outCardPanle[vPos] then
        self._outCardPanle[vPos]:removeAllChildren()
    end
    local   img_path = "qs510k/images/ddz_text_buchu.png"
    local   sp = display.newSprite(img_path)
    local pos = self:getOutCardNodePos(vPos)
    if vPos == 2 then
        pos = cc.p(pos.x - 30, pos.y) 
    end
    sp:setPosition(pos)
    local outcard_plane = self._scene:getChildByName('outcard_plane')
    outcard_plane:addChild(sp)
	local   rnd = math.random(1,3)
	local soundFile = {"qs510k/audio/Audio_Pass1_M.mp3", "qs510k/audio/Audio_Pass2_M.mp3", "qs510k/audio/Audio_Pass3_M.mp3"}
    require("hall.GameCommon"):playEffectSound(soundFile[rnd])
    local endCallFunc = cc.CallFunc:create(function() 
                            sp:removeSelf()
                            end)
    local se  = cc.Sequence:create(cc.DelayTime:create(1.5), endCallFunc)
    sp:runAction(se)
end

function gameVideoScene:showHuoCard(msg)
end

function gameVideoScene:showUserBombReward(msg)
    dump(msg, " =================== 【  总分变化  】  ===================== ")
    local Panel_kuang = self._scene:getChildByName("Panel_kuang")
    if #self._allUserInfoMsgs < 4 then
        Panel_kuang:getChildByName("tableFen"..(msg.uid + 1)):setString(msg.cardType)
    else
        if msg.uid == 0 or msg.uid == 2 then
            Panel_kuang:getChildByName("tableFen1"):setString(msg.cardType)
        else
            Panel_kuang:getChildByName("tableFen2"):setString(msg.cardType)
        end
    end
end
--------------------------------------------------

function gameVideoScene:onExit()
    g_mainScene = nil
end

return gameVideoScene