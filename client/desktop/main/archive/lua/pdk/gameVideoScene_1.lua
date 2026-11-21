--[[
* author:   zwm
* date:     2020-05-09
* describe: 跑得快战绩回放场景
* explain:  
--]]
local RecordBaseScene = require("hall.record.RecordBaseScene")
local PDKgameVideoScene = class("PDKgameVideoScene", RecordBaseScene)

-- local PDKServer = import(TpackageName .. ".src.protocol.PDKServer")
-- local PDKHandle = import(TpackageName .. ".src.protocol.PDKHandle")
-- local PROTOCOL  = require(TpackageName .. ".src.protocol.PDKProtocol")
-- local PDKDefine = require(TpackageName .. ".src.logic.PDKDefine")
local CT_PASS                     = 15      --要不起音乐
local USEFUL_MSG = {}

function PDKgameVideoScene:ctor(data, level)
    TpackageName = "pdk"
    PDKgameVideoScene.super.ctor(self, data, USEFUL_MSG, level, true)
    self._scene = self
    g_mainScene = self
    g_mainScene.userInfoByViewId = {}
    self:initGlobalData()
    self:loadAllLayer()
    self:bindMsgProc()
    self:initVideoScene()
end

function PDKgameVideoScene:onEnter()
    --  local groupId = nil
    -- if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
    --     groupId = USER_INFO["club_id"]["groupId"]
    -- end
    -- -- PDKServer:LoginRoom(USER_INFO["tid"], USER_INFO["seat_id"], USER_INFO["activity_id"] , groupId)
    -- HEART_BEAT_TID = USER_INFO["tid"]
    -- self:initVideoScene()
    cc.SimpleAudioEngine:getInstance():playMusic("pdk/res/audio/bgm.mp3",true)
end

function PDKgameVideoScene:initGlobalData()
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

function PDKgameVideoScene:clearGlobalData()
    MAX_PLAYER_SIZE = nil
    MY_SEAT_ID = nil
    PDK_CUR_ROUND = nil
    OUT_CARD_TIMES = nil
    CARD_INTERVAL   = nil      --手牌的间隙
    CARD_HEIGHT     = nil      --手牌的初始高度
    IS_ROOM_CARD_TYPE = nil
end

function PDKgameVideoScene:loadAllLayer()
    self.tableLayer = self:loadLayerByName("pdk.src.view.TableLayer", 1)
    self.playerInfoLayer = self:loadLayerByName("pdk.src.view.PlayerInfoLayer", 2)
    self:loadVideoLayer()
    self.tableLayer.btn_auto:setVisible(false)
    self.tableLayer.showCard:setVisible(false)
    -- self.roomCommonLayer = self:loadLayerByName("hall.roomCommonUI.RoomCommonPDKLayer", 3, self:getToDisbandFuncs())
    -- self.gameMsgLayer = self:loadLayerByName("hall.roomCommonUI.GameMsgLayer", 5, self:getToSendFaceAndTxtFuncs())
    -- self.gameMsgLayer:setVisible(false)
    -- self.tgLayer = self:loadLayerByName(TpackageName .. ".src.view.tgLayer", 999)
end

function PDKgameVideoScene:loadLayerByName(path, zOrder, data)
    if path == nil then
        print("PDKgameScene:loadLayerByName [path] is nil ----------------------")
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
function PDKgameVideoScene:bindMsgProc()
    self.func_ = {
        --广播用户出牌
        [24581] = {handler(self, self.showOutCard)},
        --广播用户pass
        [24582] = {handler(self, self.showUserPass)},  
    }
end


function PDKgameVideoScene:loadVideoLayer()
    self._videoOptLayer = require("hall.record.RecordOptLayer").new(self)
    -- self._videoOptLayer:setScale(720/1080)
    self._videoOptLayer:setZOrder(10000)
    self._videoOptLayer:addTo(self)
    self._videoOptLayer:resetOptPositionY(260)
end

function PDKgameVideoScene:initVideoScene()
    print("initVideoScene ----------------------")
    self:showAllUserInfo()
    self:showHandlerCards()
end

function PDKgameVideoScene:initUidToViewId(userLst)
    self._uidToViewId = {}
    self._viewIdHandCards = {}
    for i,v in ipairs(userLst or {}) do
        if v.uid then
            self._uidToViewId[v.uid] = self:getViewIdBySeatId(i)
        end
    end
end

function PDKgameVideoScene:showAllUserInfo()
    dump(self._allUserInfoMsgs, "self._allUserInfoMsgs == ")
    self:initUidToViewId(self._allUserInfoMsgs)
    for i,v in ipairs(self._allUserInfoMsgs or {}) do
        local viewPos = self:getViewIdBySeatId(i)
        local info = self:exchangeUserInfoToShowHead(v)
        self.playerInfoLayer:setPlayerInfoByViewId(viewPos, info)
    end
end

function PDKgameVideoScene:showHandlerCards()
    for i,v in ipairs(self._allHandCardsMsgs or {}) do
        local viewPos = self:getViewIdBySeatId(i)
        self:showHandCardsForView(viewPos, v)
    end
end

function PDKgameVideoScene:showHandCardsForView(viewPos, cards)
    print(showHandCardsForView, "")
    dump(cards,viewPos,  "_viewIdHandCards == ")
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

function PDKgameVideoScene:exchangeUserInfoToShowHead(userInfo)
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
function PDKgameVideoScene:callFunc(pack)
    if self.func_[pack.type] and self.func_[pack.type][1] then
        self.func_[pack.type][1](pack)
    end
end

function PDKgameVideoScene:getMySeatId(userLst)
    dump(USER_INFO, "USER_INFO == ")
    for i,v in ipairs(userLst or {}) do
        if USER_INFO["uid"] == v.uid then
            return i
        end
    end
    return 1 -- nil
end

function PDKgameVideoScene:getViewIdBySeatId(sId)
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


function PDKgameVideoScene:showOutCard(msg)
    dump(msg, "showOutCard === ")
    local viewId = self._uidToViewId[msg.uid]
    local cards = {}
    for i,v in ipairs(string.split(msg.cards, ",")) do
        table.insert(cards, tonumber(v))
    end
    local exCards = self.playerInfoLayer:exchangeCardsValue(cards)
    self.tableLayer:showOutCardsByViewId(viewId, exCards, msg.cardType)
    self:reShowHandCards(viewId, cards)
end

function PDKgameVideoScene:reShowHandCards(viewId, outCards)
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

function PDKgameVideoScene:showUserPass(msg)
    local viewId = self._uidToViewId[msg.uid]
    if viewId == 1 then
        self.tableLayer.myOutCard:removeAllChildren()
        self.playerInfoLayer.myUser:showPassAni(self.curSpeed)
    elseif viewId == 2 then
        self.tableLayer.ROutCard:removeAllChildren()
        self.playerInfoLayer.rightUser:showPassAni(self.curSpeed)
    elseif viewId == 3 then
        self.tableLayer.LOutCard:removeAllChildren()
        self.playerInfoLayer.leftUser:showPassAni(self.curSpeed)
    end
    local info = {nPreOutUserId = msg.uid , Cardtype = CT_PASS}
    -- self:PlayMusic(info)
end
--------------------------------------------------

function PDKgameVideoScene:onExit()
    g_mainScene = nil
end

return PDKgameVideoScene