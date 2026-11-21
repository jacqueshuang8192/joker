
--[[
* author:   zwm
* date:     2020-08-10
* describe: 泰和过炸战绩回放场景
* explain:  
--]]
local RecordBaseScene = require("hall.record.RecordBaseScene")
local DDZgameVideoScene = class("DDZgameVideoScene", RecordBaseScene)

require("TaiHeGuoZha.ddzDefine")
local ddzServer = import("TaiHeGuoZha.ddzServer")
local ddzHandle = import("TaiHeGuoZha.ddzHandle")
local PROTOCOL = require("TaiHeGuoZha.ddz_PROTOCOL")
local GPSShowLayer = require("hall.GPSShowLayer")
local fs = require("hall.tool.utils.fs")
local Card = require("TaiHeGuoZha.Card")
local CardPlaneOperator = require("TaiHeGuoZha.operator.CardPlaneOperator")
local GamePlaneOperator = require("TaiHeGuoZha.operator.GamePlaneOperator")
local ControlPlaneOperator = require("TaiHeGuoZha.operator.ControlPlaneOperator")

local OUT_CARD_CENTER_POS = {
    [1] = cc.p(640, 170),-- 中间位置
    [2] = cc.p(1040, 360), --结束的位置
    [3] = cc.p(640, 440), -- 中间位置
    [4] = cc.p(300, 360), -- 开始的位置
}

local HANDLER_CARD_BEGIN_POS = {
    [1] = cc.p(640, 70),
    [2] = cc.p(1100, 360),
    [3] = cc.p(640, 550),
    [4] = cc.p(180, 360),
}

local USEFUL_MSG = {}

--添加复制房号功能，放大牌，添加剩余牌数显示，带控牌显示
function DDZgameVideoScene:initData(_type)
    HAS_RECEIVE_GROUP_RESULT = false
    decidecard = nil
    if _type == "init" then
        TpackageName = "TaiHeGuoZha"
        THGZ_IS_mAI = false   --是否托管
        require("hall.view.voicePlayView.voiceListView"):clearList()
        --dump1 = function (  )

        --end
        DDZ_USERINFO_TABLE = {}
        DDZ_SEAT_TABLE = {}
        SEAT2USERID = {}
        PLAYER_HEADS_POSITION_TABLE = {}

        REMAINCARDS = {}
        for seatId = 0, PLAYERNUM - 1 do
            REMAINCARDS[seatId] = 0
        end
        MY_SEAT_ID = -1
        USERS_READY_STATE = {}

        tbPlayCardInfo = {}

        LandLordSeatId = 1 --地主座位

        AUTO_OUT_CARD = false

        LocaArrayByPlayerType = {}

        DDZ_ROUND = 1

        DDZ_TOTAL_ROUND = 1

        FARMER_BONUS_CARDS = {}

        PLAYER_HEADS_TABLE = {}

        PLAYER_HEADS_POSITION_TABLE = {}

        bonus_array = {
            [0] = 0,
            [1] = 4,
            [2] = 0,
            [3] = 4,
            [4] = 4,
            [5] = 4,
            [6] = 0,
            [7] = 8,
            [8] = 4,
            [9] = 14,
            [10] = 0,
            [11] = 0,
            [12] = 0,
            [13] = 999
        }

        SHOW_GAME_CONFIG = {
            ["地主4张炸弹3连拖 无奖"] = true,
            ["地主4张炸弹3连拖 1分"] = true,
            ["地主4张炸弹3连拖 2分"] = true,
            ["明牌2分"] = true,
            ["5张炸弹2连拖有奖"] = true,
            ["7张炸弹2分"] = true,
            ["封顶8分"] = true
        }
        --ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/res/hallMain/newAnim/anime"..v.."/anime"..v..".png","hall/res/hallMain/newAnim/anime"..v.."/anime"..v..".plist","hall/res/hallMain/newAnim/anime"..v.."/anime"..v..".ExportJson");                         -- 加载动画所用到的数据
        --btn:removeAllChildren()
        GAME_CONFIG = {}

        --通过接口传来的字符串获取具体配置信息
        if type(USER_INFO["gameConfig"]) == "string" then
            if string.find(USER_INFO["gameConfig"], "不显示剩余牌数") then
                GAME_CONFIG["不显示剩余牌数"] = true
            end
        end

        PartnerUid = nil
        PartnerCards = nil
    elseif _type == "clearGameData" then
        FARMER_BONUS_CARDS = {}
        PartnerUid = nil
        PartnerCards = nil

        for seatId in pairs(REMAINCARDS) do
            REMAINCARDS[seatId] = 0 --？？？？？
        end

        tbPlayCardInfo["last_cards"] = nil
    elseif _type == "release" then
        require("hall.view.voicePlayView.voiceListView"):clearList()

        --dump1(collectgarbage("count"),"collectgarbagecount2") --用于检测内存占用

        PLAYER_HEADS_TABLE = {}

        PLAYER_HEADS_POSITION_TABLE = {}

        USERS_READY_STATE = {}

        GAME_CONFIG = nil
        TpackageName = nil
        DDZ_ROUND = nil

        DDZ_TOTAL_ROUND = nil

        BASE_CARD_NUM = nil
        LocaArrayByPlayerType = nil

        DDZ_SEAT_TABLE = nil
        SEAT2USERID = nil
        PLAYER_HEADS_POSITION_TABLE = nil

        REMAINCARDS = nil

        tbPlayCardInfo = nil

        LandLordSeatId = nil --地主座位
        tbSeatCoin = nil

        AUTO_OUT_CARD = nil
        PartnerUid = nil
        PartnerCards = nil

        collectgarbage("collect")
    --dump1(collectgarbage("count"),"collectgarbagecount3")  --用于检测内存占用
    end
end

function DDZgameVideoScene:ctor(data, level)
    --dump1(collectgarbage("count"),"collectgarbagecount1") --用于检测内存占用
    self:initData("init")
    DDZgameVideoScene.super.ctor(self, data, USEFUL_MSG, level, true)
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(ddzHandle.new())

    self._scene = cc.CSLoader:createNode("TaiHeGuoZha/res/GameScene.csb"):addTo(self)
    visibleSize = cc.Director:getInstance():getVisibleSize().width
    self.bg_select_index = 1

    GameUtils.setNodeNameBindObj(self._scene)
    self:_initUI()
    -- self:setGameSetting()
    local roomBackGround = self._scene:getChildByName("roomBackGround"):setScale(self:_getScaleParam2())

    audio.preloadMusic("TaiHeGuoZha/res/audio/Audio_Game_Back.mp3")

    cardScene = self._scene

    --前端版本号
    self._scene.txt_version:setString(GAME_VERSION)
    self._scene.txt_version:hide()
    self._scene.device_info_plane.battery_shell:onClick(function(  )
        if isOpenControl then
            ddzServer:CLIENT_COMMAND_GET_CARD()
        end
    end,true)

    require("TaiHeGuoZha.operator.GamePlaneOperator"):init()

    --玩法说明

    local upConfigCount = 0
    local upConfig = ""
    local downConfig = ""

    if next(GAME_CONFIG) then
        for configName, v in pairs(GAME_CONFIG) do
            if v == true and SHOW_GAME_CONFIG[configName] then
                if upConfigCount <= 2 then
                    upConfigCount = upConfigCount + 1
                    upConfig = upConfig .. "  " .. configName
                else
                    downConfig = downConfig .. "  " .. configName
                end
            end
        end
    end

    self._scene:getChildByName("room_lb_plane"):setVisible(false)

    --邀请微信好友
    local invite_ly = self._scene:getChildByName("invite_ly"):setVisible(false)

    local btn_share = invite_ly:getChildByName("btn_share"):setVisible(false)
    local btn_copy_room_id = invite_ly:getChildByName("btn_copy_room_id")

    require("hall.util.GameMenu"):registCopyRoomIdFunc(btn_copy_room_id, USER_INFO["invote_code"], GAME_NAME, "四人洼地菌瓦")

    --设置按钮
    local btnSetting = self._scene:getChildByName("btn_setting"):setVisible(false)
    self._scene:getChildByName("layout_ui"):getChildByName("btn_ready"):setVisible(false)
    self._scene:getChildByName("layout_ui"):getChildByName("operate_btns"):setVisible(false)
    self._scene:getChildByName("layout_ui"):getChildByName("btn_showGroupResult"):setVisible(false)
    self._scene:getChildByName("layout_ui"):getChildByName("btn_returnToHall"):setVisible(false)
    self._scene:getChildByName("distance_gps"):setVisible(false)

    local remain_rounds_count_plane = self._scene:getChildByName("remain_rounds_count_plane"):setVisible(false)
    self._scene:getChildByName("device_info_plane"):setVisible(false)

    local lbVersion = cc.Label:createWithSystemFont(round_info, "Arial", 40)
    lbVersion:setColor(cc.c3b(255, 255, 0))
    lbVersion:setPosition(
        cc.p(SCENENOW["scene"]:getContentSize().width - lbVersion:getContentSize().width / 2 - 40, SCENENOW["scene"]:getContentSize().height - lbVersion:getContentSize().height / 2 - 30)
    )
    SCENENOW["scene"]:addChild(lbVersion, 999)

    local chat_bt = cardScene:getChildByName("btn_chat"):setVisible(false)

    self._handlerCardPanle = {}
    self._outCardPanle     = {}

    self:showTableScore(0)
    self:bindMsgProc()
    self:initVideoScene()
    self:loadVideoLayer()
end

function DDZgameVideoScene:bindMsgProc()
    self.func_ = {
        --广播用户出牌
        [4609] = {handler(self, self.showOutCard)},
        --广播用户pass
        [4610] = {handler(self, self.showUserPass)},  
        --广播用户得分
        [4613] = {handler(self, self.showUserRewardFen)}, 
        --广播用户得奖
        [4614] = {handler(self, self.showUserBombReward)}, 
    }
end

function DDZgameVideoScene:loadVideoLayer()
    self._videoOptLayer = require("hall.record.RecordOptLayer").new(self)
    -- self._videoOptLayer:setScale(720/1080)
    self._videoOptLayer:setZOrder(10000)
    self._videoOptLayer:addTo(self)
    self._videoOptLayer:resetOptPositionY(160)
end

function DDZgameVideoScene:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH / CONFIG_DESIGN_WIDTH) * (disHeight / (frameHeight or 0))
end

function DDZgameVideoScene:_initUI()
    if self._scene then
        local bg = self._scene:getChildByName("roomBackGround")
        local precent = self:_getScaleParam2()
        local root = self._scene
        if root then
            local child = root:getChildren()
            for i, v in ipairs(child or {}) do
                local x = v:getPositionX()
                v:setPositionX(x * precent)
                if v:getDescription() == "ListView" then --容器按照比率重新设置大小
                    local size = v:getContentSize()
                    v:setContentSize(cc.size(size.width * precent, size.height))
                end
            end
        end
    end
    local traceback = string.split(debug.traceback("", 2), "\n")
    print(traceback)

    ---gps按钮
    local gpsBtn = self._scene:getChildByName("distance_gps")
    gpsBtn:setVisible(false)
    
end

function DDZgameVideoScene:onEnter()
    local groupId = nil
    if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
        groupId = USER_INFO["club_id"]["groupId"]
    end

    ddzServer:LoginRoom(USER_INFO["tid"], USER_INFO["seat_id"], USER_INFO["activity_id"], groupId)

    local device_info_plane = self._scene:getChildByName("device_info_plane")
    require("hall.util.GameMenu"):addMenu(nil, device_info_plane)
    require("hall.GameCommon"):playEffectMusic("TaiHeGuoZha/res/audio/Audio_Game_Back.mp3", true)

    local btn_voice = cardScene:getChildByName("btn_voice"):setVisible(false)


    self._scene:getChildByName("friendCardNode"):setVisible(false)
    self._scene:getChildByName("huopaiTxt"):setVisible(false)
end

function DDZgameVideoScene:initVideoScene()
    print("initVideoScene ----------------------")
    self:showAllUserInfo()
    self:showHandlerCards()
end

function DDZgameVideoScene:initUidToViewId(userLst)
    self._uidToViewId = {}
    self._viewIdHandCards = {}
    for i,v in ipairs(userLst or {}) do
        if v.uid then
            self._uidToViewId[v.uid] = self:getViewIdBySeatId(i)
        end
    end
end

function DDZgameVideoScene:showAllUserInfo()
    dump(self._allUserInfoMsgs, "self._allUserInfoMsgs == ")
    self:initUidToViewId(self._allUserInfoMsgs)
    for i,v in ipairs(self._allUserInfoMsgs or {}) do
        local viewPos = self:getViewIdBySeatId(i)
        local info = self:exchangeUserInfoToShowHead(v)
        self:initUser(info, viewPos)
    end
end

function DDZgameVideoScene:initUser(info, vPos)
    local playerPanle = self._scene:getChildByName("touxiangbufen_"..vPos)
    playerPanle:getChildByName("network_img"):setVisible(false)
    playerPanle:getChildByName("im_ready"):setVisible(false)
    playerPanle:getChildByName("chips"):setVisible(false)
    playerPanle:getChildByName("cardNumBack"):setVisible(false)
    playerPanle:getChildByName("landlord_flag"):setVisible(false)
    -- playerPanle:getChildByName("ass_flag"):setVisible(false)

    self:showInfo(info, playerPanle)
end

function DDZgameVideoScene:showInfo(userInfo, plane)
    print("showInfo ===================== ", plane == nil)
    dump(userInfo, 'userInfo = ')
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

    local coins_str = tonumber(coins or "0")/100
    if coins_str > 100000 then
        coins_str = string.format("%.1f", coins_str / 10000) .. "万"
    end
    coins_lb:setString(coins_str)
    plane:getChildByName("txt_bonus"):setString("0")
end

function DDZgameVideoScene:showHandlerCards()
    for i,v in ipairs(self._allHandCardsMsgs or {}) do
        local viewPos = self:getViewIdBySeatId(i)
        self:showHandCardsForView(viewPos, v)
    end
end

function DDZgameVideoScene:showHandCardsForView(viewPos, cards)
    dump(cards,  "_viewIdHandCards == ")
    self._viewIdHandCards[viewPos] = cards
    local isLandlord = false
    local sortStruCards = self:getExchangeHandlerCards(cards)-- self:sortCard(cards)
    dump(sortStruCards, "sortStruCards == ")
    if self._handlerCardPanle[viewPos] == nil then
        local cardsNode = display.newNode()
        -- dump(HANDLER_CARD_BEGIN_POS[viewPos], "HANDLER_CARD_BEGIN_POS[viewPos] == ")
        cardsNode:setPosition(self:getHandCardNodePos(viewPos))
        local outcard_plane = self._scene:getChildByName('outcard_plane')
        outcard_plane:addChild(cardsNode)
        self._handlerCardPanle[viewPos] = cardsNode
    end
    self._handlerCardPanle[viewPos]:removeAllChildren()

    local beginX = math.floor((#sortStruCards - 1)/2) * (-20)
    for i,v in ipairs(sortStruCards or {}) do
        -- local card = Card:getCard(v[1], v[2], isLandlord)
        local value, kind = Card:init(v.maxCard)
        local card = Card:getCard(value, kind)
        card:setPosition(cc.p(beginX + (i -1)*20, 0))
        card:setScale(0.4)
        card._cardData = v
        -- self:setCardNodeFunc(card)
        card:setName(value)
        Card:setCardNum( card, v.num)
        self._handlerCardPanle[viewPos]:addChild(card)
        if viewPos == 2 then 
            self._handlerCardPanle[viewPos]:setRotation(-90)
        elseif viewPos == 4 then
            self._handlerCardPanle[viewPos]:setRotation(90)
        end
    end
end

function DDZgameVideoScene:getExchangeHandlerCards(cards)
    local newCards = {}
    for idx,card in ipairs(cards) do
        if not newCards[card] then
            newCards[card] = 0
        end
        newCards[card] = newCards[card] + 1
    end
    local clientCards = {}
    for card,num in pairs(newCards) do
        card = tonumber(card)
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

    return newClientCards
end

function DDZgameVideoScene:sortClientCards(clientCards, type)
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

function DDZgameVideoScene:getHandCardNodePos(vPos)
    return cc.p(HANDLER_CARD_BEGIN_POS[vPos].x*self:_getScaleParam2(), HANDLER_CARD_BEGIN_POS[vPos].y)
end

function DDZgameVideoScene:sortCard(cards)
    local result = {}
    local c  = Card.new()
    for i,v in ipairs(cards)  do
        c:init(v)
        table.insert(result, {c._value,c._kind,0,0,0,v})
    end

    result = Card:HandCardSort(result)
    return result
end

function DDZgameVideoScene:exchangeUserInfoToShowHead(userInfo)
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
function DDZgameVideoScene:callFunc(pack)
    if self.func_[pack.type] and self.func_[pack.type][1] then
        self.func_[pack.type][1](pack)
    end
end

function DDZgameVideoScene:getMySeatId(userLst)
    dump(USER_INFO, "USER_INFO == ")
    for i,v in ipairs(userLst or {}) do
        if USER_INFO["uid"] == v.uid then
            return i
        end
    end
    return 1--nil
end

function DDZgameVideoScene:getViewIdBySeatId(sId)
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


function DDZgameVideoScene:showOutCard(msg)
    dump(msg, "showOutCard === ")
    self:showTableScore(msg.cardType or "0")
    local cards = {}
    if string.find(msg.cards, ",") ~= nil then
        for i,v in ipairs(string.split(msg.cards, ",")) do
            table.insert(cards, tonumber(v))
        end
    else
        table.insert(cards, tonumber(msg.cards))
    end
    local viewId = self._uidToViewId[msg.uid]
    local c_table = {}
    local c = Card.new()
    for i, v in ipairs(cards) do
        c:init(v)
        table.insert(c_table, {c._value, c._kind})
    end
    local tm_table = CardPlaneOperator:showOtherCardRank(c_table)
    CardPlaneOperator:showOutCard(tm_table, nil, nil, nil, viewId, true)

    if #cards >= 7 then
        local ArmatureRuns = self._scene:getChildByName("ArmatureRuns")
        ArmatureRuns:getAnimation():playWithIndex(0,-1,0)
    end
    self:reShowHandCards(viewId, cards)

    do return end
    local cards = {}
    if string.find(msg.cards, ",") ~= nil then
        for i,v in ipairs(string.split(msg.cards, ",")) do
            table.insert(cards, tonumber(v))
        end
    else
        table.insert(cards, tonumber(msg.cards))
    end

    if self._outCardPanle[viewId] == nil then
        local cardsNode = display.newNode()
        cardsNode:setPosition(self:getOutCardNodePos(viewId))
        local outcard_plane = self._scene:getChildByName('outcard_plane')
        outcard_plane:addChild(cardsNode)
        self._outCardPanle[viewId] = cardsNode
    end
    self._outCardPanle[viewId]:removeAllChildren()

    local tableFen = msg.cardType--桌面分
    self:showTableScore(tableFen or "0")

    self:addCardsToCardNode(cards, viewId, 0)
    -- self:playCardsMusic(cards, msg.cardType) 
    if #cards >= 7 then
        local ArmatureRuns = self._scene:getChildByName("ArmatureRuns")
        ArmatureRuns:getAnimation():playWithIndex(0,-1,0)
    end
    self:reShowHandCards(viewId, cards)
end

function DDZgameVideoScene:getOutCardNodePos(vPos)
    return cc.p(OUT_CARD_CENTER_POS[vPos].x*self:_getScaleParam2(), OUT_CARD_CENTER_POS[vPos].y)
end


function DDZgameVideoScene:addCardsToCardNode(cards, vPos, cardType)
    local imgCards = {}
    local isLandlord = false
    -- for k,v in pairs(cards or {}) do
    --     local c  = Card.new()
    --     c:init(v)
    --     local card = Card:getCard(c._value, c._kind, isLandlord)        
    --     card:setScale(0.6)
    --     table.insert(imgCards, card)
    -- end
    imgCards = self:getOutCardImgs(cards, cardType, isLandlord)
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

function DDZgameVideoScene:getOutCardImgs(cards, cardType, show_logo)
    local result = {}
    local cardsT = {}

    local c  = Card.new()
    for i,v in ipairs(cards)  do
        c:init(v)
        table.insert(cardsT, {c._value,c._kind,0,0,0,v})
    end
    local magic2CardValue = {}

    local showMagicNum = 1
    for k,v in ipairs(cardsT) do

        local img
        if v[2] == 4 and magic2CardValue[showMagicNum] then
            img = Card:getCardByMagic(v[1],v[2],magic2CardValue[showMagicNum])
            img:setScale(0.6)
            showMagicNum = showMagicNum + 1
        else
            img = Card:getCard(v[1],v[2],show_logo)
            img:setScale(0.6)
        end
        table.insert(result, img)
    end
    
    return result
end

function DDZgameVideoScene:reShowHandCards(viewId, outCards)
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

function DDZgameVideoScene:showTableScore(tableFen)
    local txt_jianfen = self._scene:getChildByName("txt_jianfen"):setString(tostring(tableFen))
    txt_jianfen:setVisible(true)
end

function DDZgameVideoScene:showUserPass(msg)
    local viewId = self._uidToViewId[msg.uid]

    GamePlaneOperator:clearUserDesk(viewId)
    CardPlaneOperator:clearOutCards(viewId)
    ControlPlaneOperator:disPlayChoice(0, "noyao", viewId)
end

function DDZgameVideoScene:showUserRewardFen(msg)
    local viewId = self._uidToViewId[msg.uid]
    GamePlaneOperator:updateFen(viewId, msg.cardType)
end

function DDZgameVideoScene:showUserBombReward(msg)
    local viewId = self._uidToViewId[msg.uid]
    GamePlaneOperator:updateJiang(viewId, msg.cardType)
end

function DDZgameVideoScene:onExit()
    audio.stopMusic(false)
    AudioEngine.stopAllEffects()
end

return DDZgameVideoScene
