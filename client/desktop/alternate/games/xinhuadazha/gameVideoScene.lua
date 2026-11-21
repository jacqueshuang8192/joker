--[[
* author:   lb
* date:     2021-05-09
* describe: 新化打炸战绩回放场景
* explain:  
--]]
local RecordBaseScene = require("hall.record.RecordBaseScene")
local xhdzgameVideoScene = class("xhdzgameVideoScene", RecordBaseScene)

-- local xhdzServer = import(TpackageName .. ".src.protocol.xhdzServer")
-- local xhdzHandle = import(TpackageName .. ".src.protocol.xhdzHandle")
-- local PROTOCOL  = require(TpackageName .. ".src.protocol.xhdzProtocol")
-- local xhdzDefine = require(TpackageName .. ".src.logic.xhdzDefine")
local CT_PASS                     = 15      --要不起音乐
local USEFUL_MSG = {}

function xhdzgameVideoScene:ctor(data, level)
    TpackageName = "xinhuadazha"
    xhdzgameVideoScene.super.ctor(self, data, USEFUL_MSG, level, true)
    self._scene = self
    g_mainScene = self
    g_mainScene.userInfoByViewId = {}
    self:initGlobalData()
    self:loadAllLayer()
    self:bindMsgProc()
    self:initVideoScene()
end

function xhdzgameVideoScene:onEnter()
    --  local groupId = nil
    -- if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
    --     groupId = USER_INFO["club_id"]["groupId"]
    -- end
    -- -- xhdzServer:LoginRoom(USER_INFO["tid"], USER_INFO["seat_id"], USER_INFO["activity_id"] , groupId)
    -- HEART_BEAT_TID = USER_INFO["tid"]
    -- self:initVideoScene()
    cc.SimpleAudioEngine:getInstance():playMusic("xinhuadazha/res/audio/bgm.mp3",true)
end

function xhdzgameVideoScene:initGlobalData()
    print("initGlobalData ---------------------")
    MAX_PLAYER_SIZE   = 4       --玩家最大人数
    MY_SEAT_ID        = 0       --玩家自己的座位号
    xhdz_CUR_ROUND    = 0       --当前打完的局数
    OUT_CARD_TIMES    = 20      --出牌时间
    CARD_INTERVAL     = 70      --手牌的间隙
    CARD_HEIGHT       = 100     --手牌的初始高度
    IS_ROOM_CARD_TYPE = true    --是否为房卡模式
    tableAI = {}
end

function xhdzgameVideoScene:clearGlobalData()
    MAX_PLAYER_SIZE = nil
    MY_SEAT_ID = nil
    xhdz_CUR_ROUND = nil
    OUT_CARD_TIMES = nil
    CARD_INTERVAL   = nil      --手牌的间隙
    CARD_HEIGHT     = nil      --手牌的初始高度
    IS_ROOM_CARD_TYPE = nil
end

function xhdzgameVideoScene:loadAllLayer()
    self.tableLayer = self:loadLayerByName("xinhuadazha.src.view.TableLayer", 1)
    self.playerInfoLayer = self:loadLayerByName("xinhuadazha.src.view.PlayerInfoLayer", 2)
    self:loadVideoLayer()

    -- self.roomCommonLayer = self:loadLayerByName("hall.roomCommonUI.RoomCommonxhdzLayer", 3, self:getToDisbandFuncs())
    -- self.gameMsgLayer = self:loadLayerByName("hall.roomCommonUI.GameMsgLayer", 5, self:getToSendFaceAndTxtFuncs())
    -- self.gameMsgLayer:setVisible(false)
    -- self.tgLayer = self:loadLayerByName(TpackageName .. ".src.view.tgLayer", 999)
end

function xhdzgameVideoScene:loadLayerByName(path, zOrder, data)
    if path == nil then
        print("xhdzgameScene:loadLayerByName [path] is nil ----------------------")
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
function xhdzgameVideoScene:bindMsgProc()
    self.func_ = {
        --广播用户出牌 0x1201
        [4609] = {handler(self, self.showOutCard)},
        --广播用户pass 0x1202
        [4610] = {handler(self, self.showUserPass)}, 
        --广播用户包庄操作 0x4003
        [16387] = {handler(self, self.showUserUnderTake)},
        --广播喜分与炸弹分变化
        [4613] = {handler(self, self.showHappyBomb)},
    }
end


function xhdzgameVideoScene:loadVideoLayer()
    self._videoOptLayer = require("hall.record.RecordOptLayer").new(self)
    -- self._videoOptLayer:setScale(720/1080)
    self._videoOptLayer:setZOrder(10000)
    self._videoOptLayer:addTo(self)
    self._videoOptLayer:resetOptPositionY(260)
end

function xhdzgameVideoScene:initVideoScene()
    print("initVideoScene ----------------------")
    self:showAllUserInfo()
    self:showHandlerCards()
end

function xhdzgameVideoScene:initUidToViewId(userLst)
    self._uidToViewId = {}
    self._viewIdHandCards = {}
    for i,v in ipairs(userLst or {}) do
        if v.uid then
            self._uidToViewId[v.uid] = self:getViewIdBySeatId(i)
        end
    end
end

function xhdzgameVideoScene:showAllUserInfo()
    dump(self._allUserInfoMsgs, "self._allUserInfoMsgs == ")
    self:initUidToViewId(self._allUserInfoMsgs)
    for i,v in ipairs(self._allUserInfoMsgs or {}) do
        local viewPos = self:getViewIdBySeatId(i)
        local info = self:exchangeUserInfoToShowHead(v)

        dump(viewPos,"xhdzgameVideoScene:showAllUserInfo")

        --这里有个问题 隐藏是构造函数执行的， 但是构造后才执行isLeftPlayer  2020/01/08
        if viewPos == 2 then
            info.isLeftPlayer = false
        else
            info.isLeftPlayer = true
        end

        self.playerInfoLayer:setPlayerInfoByViewId(viewPos, info)
    end
end

function xhdzgameVideoScene:showHandlerCards()
    for i,v in ipairs(self._allHandCardsMsgs or {}) do
        local viewPos = self:getViewIdBySeatId(i)
        self:showHandCardsForView(viewPos, v)
    end
end

function xhdzgameVideoScene:showHandCardsForView(viewPos, cards)
    print(showHandCardsForView, "")
    dump(cards,viewPos,  "_viewIdHandCards == ")
    self._viewIdHandCards[viewPos] = cards

    cards = self.playerInfoLayer:exchangeCardsValue(cards)

    if #cards == 0 then
        if viewPos == 3 then
            self.tableLayer.LShowCard:removeAllChildren()
        elseif viewPos == 2 then
            self.tableLayer.RShowCard:removeAllChildren()
        elseif viewPos == 4 then
            self.tableLayer.TShowCard:removeAllChildren()
        elseif viewPos == 1 then
            self.tableLayer.MShowCard:removeAllChildren()
        end
    else
        self.tableLayer:showHelpCard(viewPos, cards)
    end

    --[[
    if viewPos == 1 then
        self.playerInfoLayer:showHandlCards(cards, nil, true)

        --用新面板弹出自己手牌
        --cards = self.playerInfoLayer:exchangeCardsValue(cards)
        --dump(cards,"xhdzgameVideoScene:showHandCardsForView")

        --self.tableLayer:showHelpCard(viewPos, cards)

    elseif viewPos == 2 or viewPos == 3 or viewPos == 4 then
        cards = self.playerInfoLayer:exchangeCardsValue(cards)
        if #cards == 0 then
            if viewPos == 3 then
                self.tableLayer.LShowCard:removeAllChildren()
            else
                self.tableLayer.RShowCard:removeAllChildren()
            end
        else
            dump(viewPos,"showHelpCard")
            self.tableLayer:showHelpCard(viewPos, cards)
        end
    end
    ]]
end

function xhdzgameVideoScene:exchangeUserInfoToShowHead(userInfo)
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
function xhdzgameVideoScene:callFunc(pack)
    if self.func_[pack.type] and self.func_[pack.type][1] then
        self.func_[pack.type][1](pack)
    end
end

function xhdzgameVideoScene:getMySeatId(userLst)
    dump(USER_INFO, "USER_INFO == ")
    for i,v in ipairs(userLst or {}) do
        if USER_INFO["uid"] == v.uid then
            return i
        end
    end
    return 1 -- nil
end

function xhdzgameVideoScene:getViewIdBySeatId(sId)
    local mySeatId = self:getMySeatId(self._allUserInfoMsgs)
    if mySeatId == nil then return end

    if self._userSize == 2 then
        if sId == mySeatId then
            return 1
        else
            return 4 --2
        end
    else
        if sId == mySeatId then
            return 1
        else
            return (sId - mySeatId + MAX_PLAYER_SIZE ) % MAX_PLAYER_SIZE + 1
            --return (sId - mySeatId + 3 )%3 + 1
        end
    end
end


function xhdzgameVideoScene:showOutCard(msg)
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

function xhdzgameVideoScene:reShowHandCards(viewId, outCards)
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

function xhdzgameVideoScene:showUserPass(msg)

    local win_uid = msg.round_win_uid   --当前赢家
    local win_pick_score = msg.cardType --捡分

    local viewId = self._uidToViewId[msg.uid]
    local viewId_win = self._uidToViewId[msg.round_win_uid]

    if viewId == 1 then
        self.tableLayer.myOutCard:removeAllChildren()
        self.playerInfoLayer.myUser:showPassAni(self.curSpeed)
    elseif viewId == 2 then
        self.tableLayer.ROutCard:removeAllChildren()
        self.playerInfoLayer.rightUser:showPassAni(self.curSpeed)
    elseif viewId == 3 then
        self.tableLayer.LOutCard:removeAllChildren()
        self.playerInfoLayer.leftUser:showPassAni(self.curSpeed)
    elseif viewId == 4 then
        self.tableLayer.TOutCard:removeAllChildren()
        self.playerInfoLayer.topUser:showPassAni(self.curSpeed)
    end
    local info = {nPreOutUserId = msg.uid , Cardtype = CT_PASS}
    -- self:PlayMusic(info)


    if viewId_win == 1 then
        self.playerInfoLayer.myUser:setPickScore(win_pick_score)
    elseif viewId_win == 2 then
        self.playerInfoLayer.rightUser:setPickScore(win_pick_score)
    elseif viewId_win == 3 then
        self.playerInfoLayer.leftUser:setPickScore(win_pick_score)
    elseif viewId_win == 4 then
        self.playerInfoLayer.topUser:setPickScore(win_pick_score)
    end

end


function xhdzgameVideoScene:showUserUnderTake(msg)

    dump(msg,"xhdzgameVideoScene:showUserUnderTake")

    local isSelect = msg.cardType

    local viewId = self._uidToViewId[msg.uid]
    if viewId == 1 then
        self.playerInfoLayer.myUser:showUnderTakeAni(self.curSpeed,isSelect)
    elseif viewId == 2 then
        self.playerInfoLayer.rightUser:showUnderTakeAni(self.curSpeed,isSelect)
    elseif viewId == 3 then
        self.playerInfoLayer.leftUser:showUnderTakeAni(self.curSpeed,isSelect)
    elseif viewId == 4 then
        self.playerInfoLayer.topUser:showUnderTakeAni(self.curSpeed,isSelect)
    end
end


function xhdzgameVideoScene:setHappyScore(uid, score)
    
    local viewId = self._uidToViewId[uid]

    if viewId == 1 then
        self.playerInfoLayer.myUser:setHappyScore(score)
    elseif viewId == 2 then
        self.playerInfoLayer.rightUser:setHappyScore(score)
    elseif viewId == 3 then
        self.playerInfoLayer.leftUser:setHappyScore(score)
    elseif viewId == 4 then
        self.playerInfoLayer.topUser:setHappyScore(score)
    end
end

function xhdzgameVideoScene:setBombCount(uid, count)
    
    local viewId = self._uidToViewId[uid]

    if viewId == 1 then
        self.playerInfoLayer.myUser:setBombCount(count)
    elseif viewId == 2 then
        self.playerInfoLayer.rightUser:setBombCount(count)
    elseif viewId == 3 then
        self.playerInfoLayer.leftUser:setBombCount(count)
    elseif viewId == 4 then
        self.playerInfoLayer.topUser:setBombCount(count)
    end

end


function xhdzgameVideoScene:showHappyBomb(msg)
    
    dump(msg,"xhdzgameVideoScene:showHappyBomb")
   
    local viewId = self._uidToViewId[msg.uid]
    local dataUID = {}
    local dataHappyScore = {}
    local dataBombCount = {}
    local index = 0
    for i,v in ipairs(string.split(msg.cards, ",")) do
        
        if index % 3 == 0 then
             table.insert(dataUID, tonumber(v))
        elseif index % 3 == 1 then
             table.insert(dataHappyScore, tonumber(v))
        elseif index % 3 == 2 then
             table.insert(dataBombCount, tonumber(v))
        end

        index = index + 1
    end

    dump(dataUID,"showHappyBomb_1")
    dump(dataHappyScore,"showHappyBomb_2")
    dump(dataBombCount,"showHappyBomb_3")   

    --设置值
    for i = 1, #dataUID do
        self:setHappyScore(dataUID[i],dataHappyScore[i])
        self:setBombCount(dataUID[i],dataBombCount[i])
    end
end


--------------------------------------------------

function xhdzgameVideoScene:onExit()
    g_mainScene = nil
end

return xhdzgameVideoScene