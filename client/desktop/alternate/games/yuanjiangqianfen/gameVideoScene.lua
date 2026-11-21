--[[
* author:   zwm
* date:     2020-05-09
* describe: 跑得快战绩回放场景
* explain:  
--]]
local RecordBaseScene = require("hall.record.RecordBaseScene")
local YJQFgameVideoScene = class("YJQFgameVideoScene", RecordBaseScene)

-- local YJQFServer = import(TpackageName .. ".src.protocol.YJQFServer")
-- local YJQFHandle = import(TpackageName .. ".src.protocol.YJQFHandle")
-- local PROTOCOL  = require(TpackageName .. ".src.protocol.YJQFProtocol")
-- local YJQFDefine = require(TpackageName .. ".src.logic.YJQFDefine")
local CT_PASS                     = 15      --要不起音乐
local USEFUL_MSG = {}

function YJQFgameVideoScene:ctor(data, level)
    TpackageName = "yuanjiangqianfen"
    YJQFgameVideoScene.super.ctor(self, data, USEFUL_MSG, level, true)
    self._scene = self
    g_mainScene = self
    g_mainScene.userInfoByViewId = {}
    self:initGlobalData()
    self:loadAllLayer()
    self:bindMsgProc()
    self:initVideoScene()
end

function YJQFgameVideoScene:onEnter()
    --  local groupId = nil
    -- if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
    --     groupId = USER_INFO["club_id"]["groupId"]
    -- end
    -- -- YJQFServer:LoginRoom(USER_INFO["tid"], USER_INFO["seat_id"], USER_INFO["activity_id"] , groupId)
    -- HEART_BEAT_TID = USER_INFO["tid"]
    -- self:initVideoScene()
end

function YJQFgameVideoScene:initGlobalData()
    print("initGlobalData ---------------------")
    MAX_PLAYER_SIZE   = 3       --玩家最大人数
    MY_SEAT_ID        = 0       --玩家自己的座位号
    PDK_CUR_ROUND     = 0       --当前打完的局数
    OUT_CARD_TIMES    = 20      --出牌时间
    CARD_INTERVAL     = 70      --手牌的间隙
    CARD_HEIGHT       = 100      --手牌的初始高度
    IS_ROOM_CARD_TYPE = true    --是否为房卡模式
    tableAI = {}
end

function YJQFgameVideoScene:clearGlobalData()
    MAX_PLAYER_SIZE = nil
    MY_SEAT_ID = nil
    PDK_CUR_ROUND = nil
    OUT_CARD_TIMES = nil
    CARD_INTERVAL   = nil      --手牌的间隙
    CARD_HEIGHT     = nil      --手牌的初始高度
    IS_ROOM_CARD_TYPE = nil
end

function YJQFgameVideoScene:loadAllLayer()
    self.tableLayer = self:loadLayerByName("yuanjiangqianfen.src.view.TableLayer", 1)
    self.playerInfoLayer = self:loadLayerByName("yuanjiangqianfen.src.view.PlayerInfoLayer", 2)
    self:loadVideoLayer()

    -- self.roomCommonLayer = self:loadLayerByName("hall.roomCommonUI.RoomCommonPDKLayer", 3, self:getToDisbandFuncs())
    -- self.gameMsgLayer = self:loadLayerByName("hall.roomCommonUI.GameMsgLayer", 5, self:getToSendFaceAndTxtFuncs())
    -- self.gameMsgLayer:setVisible(false)
    -- self.tgLayer = self:loadLayerByName(TpackageName .. ".src.view.tgLayer", 999)
end

function YJQFgameVideoScene:loadLayerByName(path, zOrder, data)
    if path == nil then
        print("YJQFgameScene:loadLayerByName [path] is nil ----------------------")
    end
    zOrder = zOrder == nil and self:getChildrenCount() + 1 or zOrder
    local layer = require(path).new(data)
    print("======layer==zOrder=====",zOrder)
    if not tolua.isnull(layer) then
        print("======111111111111======")
        layer:addTo(self, zOrder)
    end
    print("======111111111111======")
    return layer
end

-------------------------------------------------------------------------
-- proc user card and info begin
function YJQFgameVideoScene:bindMsgProc()
    self.func_ = {
        --广播用户出牌
        [4609] = {handler(self, self.showOutCard)},
        --广播用户pass
        [4610] = {handler(self, self.showUserPass)},  
        --用户捡分
        [4612] = {handler(self, self.showUserPickScore)},
        --用户奖分
        [4613] = {handler(self, self.showUserRewardScore)},
    }
end


function YJQFgameVideoScene:loadVideoLayer()
    self._videoOptLayer = require("hall.record.RecordOptLayer").new(self)
    -- self._videoOptLayer:setScale(720/1080)
    self._videoOptLayer:setZOrder(10000)
    self._videoOptLayer:addTo(self)
    self._videoOptLayer:resetOptPositionY(260)
end

function YJQFgameVideoScene:initVideoScene()
    print("initVideoScene ----------------------")
    self:showAllUserInfo()
    self:showHandlerCards()
end

function YJQFgameVideoScene:initUidToViewId(userLst)
    self._uidToViewId = {}
    self._viewIdHandCards = {}
    for i,v in ipairs(userLst or {}) do
        if v.uid then
            self._uidToViewId[v.uid] = self:getViewIdBySeatId(i)
        end
    end
end

function YJQFgameVideoScene:showAllUserInfo()
    dump(self._allUserInfoMsgs, "self._allUserInfoMsgs == ")
    self:initUidToViewId(self._allUserInfoMsgs)
    for i,v in ipairs(self._allUserInfoMsgs or {}) do
        local viewPos = self:getViewIdBySeatId(i)
        local info = self:exchangeUserInfoToShowHead(v)
        self.playerInfoLayer:setPlayerInfoByViewId(viewPos, info)
    end
end

function YJQFgameVideoScene:showHandlerCards()
    for i,v in ipairs(self._allHandCardsMsgs or {}) do
        local viewPos = self:getViewIdBySeatId(i)
        self:showHandCardsForView(viewPos, v)
    end
end

function YJQFgameVideoScene:showHandCardsForView(viewPos, cards)
    dump(cards,  "_viewIdHandCards == ")
    self._viewIdHandCards[viewPos] = cards
    if viewPos == 1 then
        self.playerInfoLayer:showHandlCards(cards, nil, true)
    elseif viewPos == 2 or viewPos == 3 then
        cards = self.playerInfoLayer:exchangeCardsValue(cards)
        if #cards == 0 then
            if viewPos == 3 then
                self.tableLayer.LShowCard:removeAllChildren()
            else
                self.tableLayer.RShowCard:removeAllChildren()
            end
        else
            self.tableLayer:showHelpCard(viewPos, cards)
        end
    end
end

function YJQFgameVideoScene:exchangeUserInfoToShowHead(userInfo)
    local result = {}
    result.name = userInfo.nickName
    result.score = userInfo.remainCoins/100
    result.icon_url = userInfo.photoUrl
    result.uid = userInfo.uid
    result.sex = 0
    result.isReady = false
    return result
end

------------------------------------------------------------------------------------------------------------------------------------
-- proc msg begin
function YJQFgameVideoScene:callFunc(pack)
    if self.func_[pack.type] and self.func_[pack.type][1] then
        self.func_[pack.type][1](pack)
    end
end

function YJQFgameVideoScene:getMySeatId(userLst)
    dump(USER_INFO, "USER_INFO == ")
    for i,v in ipairs(userLst or {}) do
        if USER_INFO["uid"] == v.uid then
            return i
        end
    end
    return nil
end

function YJQFgameVideoScene:getViewIdBySeatId(sId)
    local mySeatId = self:getMySeatId(self._allUserInfoMsgs)
    if mySeatId == nil then return end

    if self._userSize == 2 then
        if sId == mySeatId then
            return 1
        else
            return 2
        end
    else
        if sId == mySeatId then
            return 1
        else
            return (sId - mySeatId + 3 )%3 + 1
        end
    end
end


function YJQFgameVideoScene:showOutCard(msg)
    dump(msg, "showOutCard === ")
    local viewId = self._uidToViewId[msg.uid]
    local cards = {}
    for i,v in ipairs(string.split(msg.cards, ",")) do
        table.insert(cards, tonumber(v))
    end
    local exCards = self.playerInfoLayer:exchangeCardsValue(cards)
    self.tableLayer:showOutCardsByViewId(viewId, exCards, msg.cardType,nil,200)
    self:reShowHandCards(viewId, cards)
end

function YJQFgameVideoScene:reShowHandCards(viewId, outCards)
    local allCards = self._viewIdHandCards[viewId]
    local deledCards = {}
    for i, v in ipairs(allCards or {}) do
        local finded = false
        for j, v1 in ipairs(outCards or {}) do
            -- local low = bit.band(15, v1)
            -- if low == 1 or low == 2 then
            --     v1 = v1 + 13
            -- end
            if v == v1 then
                finded = true
                break
            end
        end
        if not finded then
            table.insert(deledCards, v)
        end
    end
    dump(outCards, "outCards === ")
    dump(allCards, "allCards === ")
    dump(deledCards, "deledCards === ")
    self:showHandCardsForView(viewId, deledCards)
end

function YJQFgameVideoScene:showUserPass(msg)
    local viewId = self._uidToViewId[msg.uid]
    if viewId == 1 then
        self.playerInfoLayer.myUser:showPassAni(self.curSpeed)
    elseif viewId == 2 then
        self.playerInfoLayer.rightUser:showPassAni(self.curSpeed)
    elseif viewId == 3 then
        self.playerInfoLayer.leftUser:showPassAni(self.curSpeed)
    end
    local info = {nPreOutUserId = msg.uid , Cardtype = CT_PASS}
    -- self:PlayMusic(info)
end

function YJQFgameVideoScene:showUserPickScore(msg)
    local viewId = self._uidToViewId[msg.uid]
    if viewId == 1 then
        self.playerInfoLayer.myUser:setSinglePickScore(msg.cardType)
        self.playerInfoLayer.myUser:setTotalPickScore(msg.round_win_uid)
    elseif viewId == 2 then
        self.playerInfoLayer.rightUser:setSinglePickScore(msg.cardType)
        self.playerInfoLayer.rightUser:setTotalPickScore(msg.round_win_uid)
    elseif viewId == 3 then
        self.playerInfoLayer.leftUser:setSinglePickScore(msg.cardType)
        self.playerInfoLayer.leftUser:setTotalPickScore(msg.round_win_uid)
    end
    
end

function YJQFgameVideoScene:showUserRewardScore(msg)
    local viewId = self._uidToViewId[msg.uid]
    if viewId == 1 then
        self.playerInfoLayer.myUser:setSingleBombScore(msg.cardType)
        self.playerInfoLayer.myUser:setTotalBombScore(msg.round_win_uid)
    elseif viewId == 2 then
        self.playerInfoLayer.rightUser:setSingleBombScore(msg.cardType)
        self.playerInfoLayer.rightUser:setTotalBombScore(msg.round_win_uid)
    elseif viewId == 3 then
        self.playerInfoLayer.leftUser:setSingleBombScore(msg.cardType)
        self.playerInfoLayer.leftUser:setTotalBombScore(msg.round_win_uid)
    end
end


--------------------------------------------------

function YJQFgameVideoScene:onExit()
    g_mainScene = nil
end

return YJQFgameVideoScene