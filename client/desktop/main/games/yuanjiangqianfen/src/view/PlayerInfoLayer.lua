--[[
* author:   zwm
* date:     2019-04-11
* describe: 跑得快玩家信息界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local Card = require(TpackageName .. ".src.view.Card") 
local CardsAnalysis  = require(TpackageName .. ".src.logic.CardsAnalysis")
local YJQFServer = import(TpackageName .. ".src.protocol.YJQFServer")

local ViewBaseLayer = require("hall.ViewBaseLayer")
local PlayerInfoLayer = class("PlayerInfoLayer", ViewBaseLayer)


local CLICK_CARD_VIOCE = "yuanjiangqianfen/res/audio/card_click.wav"
local MAX_USER_SIZE = 3 
local POS_CLOCK = { 
                    [1]= cc.p(640*ViewBaseLayer:_getScaleParam2(), 444),
                    [2]= cc.p(1030*ViewBaseLayer:_getScaleParam2(),540),
                    [3]= cc.p(240*ViewBaseLayer:_getScaleParam2(),540)
                }
local NO_BOMB_CARD_SPACE_Y = 55
local NO_BOMB_CARD_SPACE_X = 124
local  HANDLER_CARD_SCALE = 0.8

function PlayerInfoLayer:ctor()
    PlayerInfoLayer.super.ctor(self, "yuanjiangqianfen/res/YJQFUserInfoLayer.csb")

    self:initUIInfo()
end

function PlayerInfoLayer:initUIInfo()
    self.myUser:setVisible(false)
    self.rightUser:setVisible(false)
    self.leftUser:setVisible(false)
    self.outCardBtnNode:setVisible(false)
    self.beginBtnNode:setVisible(false)
    self.errorTipsImg:setVisible(false)
    self:stopClock()
    -- self:addTouchEventListenerForCards(self.handCardPanle)
    self:initQiePaiUI()
end

function PlayerInfoLayer:setPlayerInfoByViewId(viewId, info)
    g_mainScene.userInfoByViewId[info.uid] = info
    if viewId == 1 then
        self.myUser = require("hall.util.CocosUtil"):bindCocosObjToLua(self.myUser, "yuanjiangqianfen.src.view.UserInfoNode", info)
        self.myUser:setVisible(true)
        self.myUser:setLeftPlayer(true)
        --新录音位置显示
        local point = cc.p(self.myUser:getAnchorPoint().x * self.myUser:getContentSize().width, self.myUser:getAnchorPoint().y * self.myUser:getContentSize().height)
        require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(info.uid, self.myUser:convertToWorldSpace(point))
    elseif viewId == 2 then
        self.rightUser = require("hall.util.CocosUtil"):bindCocosObjToLua(self.rightUser, "yuanjiangqianfen.src.view.UserInfoNode", info)
        self.rightUser:setVisible(true)
        self.rightUser:setLeftPlayer(false)
        --新录音位置显示
        local point = cc.p(self.rightUser:getAnchorPoint().x * self.rightUser:getContentSize().width, self.rightUser:getAnchorPoint().y * self.rightUser:getContentSize().height)

        require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(info.uid, self.rightUser:convertToWorldSpace(point))
    elseif viewId == 3 then

        self.leftUser = require("hall.util.CocosUtil"):bindCocosObjToLua(self.leftUser, "yuanjiangqianfen.src.view.UserInfoNode", info)
        self.leftUser:setVisible(true)
        self.leftUser:setLeftPlayer(true)
        --新录音位置显示
        local point = cc.p(self.leftUser:getAnchorPoint().x * self.leftUser:getContentSize().width, self.leftUser:getAnchorPoint().y * self.leftUser:getContentSize().height)

        require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(info.uid, self.leftUser:convertToWorldSpace(point))
    end
end

function PlayerInfoLayer:setHandCards(cards)
    local startPos = 640 - (#(cards or {}) - 1)*CARD_INTERVAL
    for i, v in ipairs( cards or {} ) do
        local cardImg = Card:getCard(v)
        card.selected = 0
        cardImg:setPosition(cc.p(startPos + i * CARD_INTERVAL, 0))
        cardImg:addTo(self.handCardPanle)
    end
end

function  PlayerInfoLayer:addTouchEventListenerForCards(plane)
    
    local selectedCardCount_ex
    local rtSelectCard
    local ptTouchBegin = cc.p(0,0)

    local _card_start_x = 0 
    local _card_start_y = 0 
    local _card_move_type = 0

    local cardTemp

    local function onTouchBegan(touch, event)
        print("onTouchBegan ------------------------------- afdasdf")
        self.qie_listener1:setSwallowTouches(false)
        cardTemp = nil
        local beganPosition = self.handCardPanle:convertToNodeSpace(touch:getLocation())--touch:getLocation()
        _card_start_x   = beganPosition.x
        _card_start_y   = beganPosition.y
        local children = plane:getChildren()
        for k,v in pairs(children) do
            if v.oriPosition then
                local cardNodePos = v.oriPosition
                -- print("onTouchBegan ------------------------------- ", beganPosition.x, cardNodePos.x, table.nums(self._twoDimensionalCards[v.value[1] ]))
                -- dump(self._twoDimensionalCards, "self._twoDimensionalCards == ")
                if math.abs((_card_start_x - cardNodePos.x)) < (NO_BOMB_CARD_SPACE_X/2) then -- and math.abs((_card_start_y - cardNodePos.y)) < 50
                    if table.nums(self._twoDimensionalCards[v.value[1] ]) < 4 then
                        if cardNodePos.y == CARD_HEIGHT then --表示最下面的一个
                            if math.abs((_card_start_y - cardNodePos.y)) < 70 then
                                cardTemp = v
                            end
                        else
                            if math.abs((_card_start_y - cardNodePos.y)) < NO_BOMB_CARD_SPACE_Y/2 then
                                cardTemp = v
                            end
                        end
                    else
                        cardTemp = v
                        break
                    end
                end 
            end
        end

        if cardTemp then

            require("hall.GameCommon"):playEffectSound(CLICK_CARD_VIOCE)

            -- _card_start_x   = cardTemp:getPositionX()  
            -- _card_start_y   = cardTemp:getPositionY()
            ptTouchBegin.x  = beganPosition.x
            ptTouchBegin.y  = beganPosition.y
            
            _card_move_type = 0 
            cardTemp:toBlack()
            dump(cardTemp, "cardTemp == ")
            for k,v in pairs(children) do
                if v.oriPosition then
                    if table.nums(self._twoDimensionalCards[cardTemp.value[1] ]) >= 4 and v.value[1] == cardTemp.value[1] then
                        v:toBlack()
                    end
                end
            end

            return true
        end

        return false
    end

    local function onTouchCancell(touch, event)
        print("onTouchCancell -------------------------------")
        _card_start_x   = 0 
        _card_start_y   = 0 
        _card_move_type = 0
        rtSelectCard = nil
    end

    local function onTouchMoved(touch, event)
        -- local endPosition = touch:getLocation()
        -- local locationInNode = cardNode:convertToNodeSpace(cardNode.oriPosition)
        local endPosition = self.handCardPanle:convertToNodeSpace(touch:getLocation())
        local endX = endPosition.x
        local endY = endPosition.y
        print("onTouchMoved -------------------------------",_card_start_x,  endX, (math.abs(endY - _card_start_y)  / math.abs(endX - _card_start_x) ))
        if  (math.abs(endX - _card_start_x)) > 4  then-- and (math.abs(endY - _card_start_y)  / math.abs(endX - _card_start_x) ) < 0.5 )
             
            _card_move_type  = 1
            local startx_t
            local width

            if  endX  > _card_start_x then
                startx_t = _card_start_x
                width = endX - _card_start_x
            else
                startx_t = endX
                width = _card_start_x -  endX     
            end

            startx_t, width = self:getResponseWidth(_card_start_x, endX)

            local pY, rtHeight = self:getResponseHeight(_card_start_y, endY)
            -- if pY ~= nil then
            rtSelectCard  =    cc.rect(startx_t, pY, width, rtHeight)
            dump(rtSelectCard, "rtSelectCard === ")
            local selectedCardCount = self:touchAreaCard(rtSelectCard)
            
            if selectedCardCount_ex ~= selectedCardCount then
                cc.SimpleAudioEngine:getInstance():playEffect(CLICK_CARD_VIOCE, false)
            end

            selectedCardCount_ex = selectedCardCount
            return true
            -- end

        end
    
        if math.abs(endX - ptTouchBegin.x) > CARD_INTERVAL  then
            _card_move_type = 1 --左右选择
            return
        end
    end

    local function onTouchEnded(touch, event)
        print("onTouchEnded -------------------------------",_card_move_type)
        if _card_move_type == 0 then --点选
            if tolua.isnull(cardTemp)then 
                return 
            end
            local children = plane:getChildren()
            print("asfasdf -------------------- ", cardTemp.value[1], cardTemp:isBlack(), cardTemp.selected)
            dump(self._twoDimensionalCards[cardTemp.value[1] ], "cards == ")
            for k,v in pairs(children) do
                if v.oriPosition then
                    if table.nums(self._twoDimensionalCards[cardTemp.value[1] ]) >= 4 and v.value[1] == cardTemp.value[1] then
                        if v:isBlack() then
                            if v.selected == nil or v.selected == 0 then
                                v:toUp()
                                v.selected = 1
                            else
                                v:toDown()
                                v:toWhite()
                                v.selected = 0
                            end
                        end
                    elseif table.nums(self._twoDimensionalCards[cardTemp.value[1] ]) < 4 and v.value[1] == cardTemp.value[1] and v.oriPosition.y == cardTemp.oriPosition.y then
                        if cardTemp:isBlack() then
                            if cardTemp.selected == nil or cardTemp.selected == 0 then
                                cardTemp:toUp()
                                cardTemp.selected = 1
                            else
                                cardTemp:toDown()
                                cardTemp:toWhite()
                                cardTemp.selected = 0
                            end
                        end
                    end
                end
            end
        elseif  _card_move_type == 1 then --拉选
            local tbCards = self:touchSelectCard(rtSelectCard)
            -- local children = plane:getChildren()
            for k,v in pairs(tbCards or {}) do
                -- v.selected = 1 - tonumber(v.selected or "0") 
                if v:isBlack() then
                    if v.selected == nil or v.selected == 0 then
                        v:toUp()
                        v.selected = 1
                    else
                        v:toDown()
                        v:toWhite()
                        v.selected = 0
                    end
                end
            end
            _card_move_type = 0
        end
       
        _card_start_x   = 0 
        _card_start_y   = 0 
        _card_move_type = 0

        rtSelectCard = nil

    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    -- self.handlerCardListener = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener1:registerScriptHandler(onTouchCancell,cc.Handler.EVENT_TOUCH_CANCELLED )
     
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, plane)
end

function PlayerInfoLayer:addOrRemoveHandlerCardsListener(flag)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    if flag then
        self:addTouchEventListenerForCards(self.handCardPanle)
    else
        eventDispatcher:removeEventListenersForTarget(self.handCardPanle)
    end
end

function PlayerInfoLayer:getResponseHeight(beganY, endY)
    local maxY = beganY > endY and beganY or endY
    local minY = beganY > endY and endY or beganY
    if minY < CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2 then
        if maxY < CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2 then
            return 30, (220*HANDLER_CARD_SCALE)
        elseif maxY >= CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2 and maxY < CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2 + NO_BOMB_CARD_SPACE_Y then
            return 30, (220*HANDLER_CARD_SCALE) + NO_BOMB_CARD_SPACE_Y
        elseif maxY >= CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2 + NO_BOMB_CARD_SPACE_Y then
            return 30, (220*HANDLER_CARD_SCALE) + 2*NO_BOMB_CARD_SPACE_Y
        end
    elseif minY >= CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2 and minY < CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2 + NO_BOMB_CARD_SPACE_Y then
        if maxY >= CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2 and maxY < CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2 + NO_BOMB_CARD_SPACE_Y then
            return CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2, NO_BOMB_CARD_SPACE_Y
        elseif maxY >= CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2 + NO_BOMB_CARD_SPACE_Y then
            return CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2, (220*HANDLER_CARD_SCALE) + 2*NO_BOMB_CARD_SPACE_Y
        end
    elseif minY >= CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2 and minY < CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2 + 2*NO_BOMB_CARD_SPACE_Y then
        return CARD_HEIGHT + (220*HANDLER_CARD_SCALE)/2 + NO_BOMB_CARD_SPACE_Y, NO_BOMB_CARD_SPACE_Y
    end

    return 1000, 0
end

function PlayerInfoLayer:getResponseWidth(beganX, endX)
    local minX = beganX > endX and endX or beganX
    local maxX = beganX > endX and beganX or endX
    local modValue = math.mod(minX, NO_BOMB_CARD_SPACE_X)
    local intValue = math.floor(minX/NO_BOMB_CARD_SPACE_X)
    local beginPos = self:getBeginPosX(table.nums(self._twoDimensionalCards))

    local minPos = 0
    local maxPos = 0
    for i = 1, 9 do--最多只有9个不同的牌值
        if minX >= (beginPos + (i-1)*NO_BOMB_CARD_SPACE_X - (NO_BOMB_CARD_SPACE_X/2)) and minX < (beginPos + (i-1)*NO_BOMB_CARD_SPACE_X + (NO_BOMB_CARD_SPACE_X/2)) then
            minPos = (beginPos + (i-1)*NO_BOMB_CARD_SPACE_X - (NO_BOMB_CARD_SPACE_X/2))
        end
        if maxX >= (beginPos + (i-1)*NO_BOMB_CARD_SPACE_X - (NO_BOMB_CARD_SPACE_X/2)) and maxX < (beginPos + (i-1)*NO_BOMB_CARD_SPACE_X + (NO_BOMB_CARD_SPACE_X/2)) then
            maxPos = (beginPos + (i-1)*NO_BOMB_CARD_SPACE_X - (NO_BOMB_CARD_SPACE_X/2))
        end
    end

    return minPos, (maxPos - minPos) + NO_BOMB_CARD_SPACE_X
end

--触摸区域显示牌
function PlayerInfoLayer:touchAreaCard(rect)
    
    local selectedCardCount = 0
    local lstT = {[15] = 0, [14] = 0, [13] = 0, [12] = 0, [11] = 0, [10] = 0, [9] = 0, [8] = 0, [5] = 0}
    local children = self.handCardPanle:getChildren()
    dump(rect, "touchAreaCard == ")
    for i,cardNode in ipairs(children or {}) do
        if cardNode.oriPosition then
            local flag = cc.rectContainsPoint(rect, cardNode.oriPosition)
            if flag then
                dump(cardNode.oriPosition, "cardNode == ")
                local value = cardNode.value[1]
                if table.nums(self._twoDimensionalCards[cardNode.value[1] ]) >= 4  then
                    for j, v in ipairs(children or {}) do
                        if v.oriPosition and v.value[1] == value then
                            v:toBlack()
                            selectedCardCount = selectedCardCount + 1
                        end
                    end
                else
                    cardNode:toBlack()
                    selectedCardCount = selectedCardCount + 1
                end
            else
                local value = cardNode.value[1]
                if table.nums(self._twoDimensionalCards[cardNode.value[1] ]) >= 4  then
                    for j, v in ipairs(children or {}) do
                        if v.oriPosition and v.value[1] == value then
                            if v.selected == nil or v.selected == 0 then
                                v:toWhite()
                            end
                        end
                    end
                else
                    if cardNode.selected == nil or cardNode.selected == 0 then
                        cardNode:toWhite()
                    end
                end
            end
        end
    end

    return selectedCardCount
end

--触摸区选牌
function PlayerInfoLayer:touchSelectCard(rect)
    if rect == nil then
        return
    end
  
    local tbSelectCards = {}

    for i,cardNode in ipairs(self.handCardPanle:getChildren()) do
        if cardNode.oriPosition then
            local flag = cc.rectContainsPoint(rect, cardNode.oriPosition)
            if flag then
                table.insert(tbSelectCards,cardNode)
            end
        end
    end

    return tbSelectCards
end

function  PlayerInfoLayer:setCardOther(tbSelectCards)
    for i,cardNode in ipairs(tbSelectCards) do
        if not tolua.isnull(cardNode) then

            local px  = cardNode:getPositionX()
            local py  = cardNode:getPositionY()
               
            if cardNode.selected == 1 then
                cardNode:toUp()
                cardNode:toBlack()
            else
               cardNode:toDown()
               cardNode:toWhite()
            end
       
            
        end

    end
end

--参数：state  1、只显示开始游戏按钮, 2、显示开始游戏和邀请好友按钮，
function PlayerInfoLayer:showBeginBtnByState(state)
    self.beginBtnNode:setVisible(true)
    local state = state == nil and 1 or state
    
    if state == 1 then
        self.btnInvite:setVisible(false)
        self.btnCopyRoomnum:setVisible(false)
        self.btnReady:setPositionX(0)
    elseif state == 2 then
        self.btnInvite:setVisible(true)
        self.btnCopyRoomnum:setVisible(true)
        self.btnReady:setPositionX(0)
    end
end


function PlayerInfoLayer:showOutCardBtn()
    print("showOutCardBtn -------------------------", debug.traceback())
    self.outCardBtnNode:setVisible(true)
end

--参数：viewId 本地座位号，1、表示自己
function PlayerInfoLayer:showClockByViewId(viewId, times)
    if viewId ~= nil and viewId >= 1 and viewId <= MAX_PLAYER_SIZE then
        local position = POS_CLOCK[viewId]
        self.clockBg:setVisible(true)
        self.clockBg:setPosition(position)
        self.timeFont:stopAllActions()
        local ani = self:getClockAnimation(times)
        self.timeFont:runAction(ani)
    end
end

--闹钟动画
function PlayerInfoLayer:getClockAnimation(times)
    local showTimerAc = cc.CallFunc:create(function()
            
            if times <= 0 then
                self.timeFont:setString("00")
                self.clockBg:setVisible(false) 
                self.timeFont:stopAllActions()
            end
            self.timeFont:setString(string.format("%02d", times))
            times = times - 1
        end)

    local seqAc = cc.Sequence:create(showTimerAc, cc.DelayTime:create(1))
    
    return cc.RepeatForever:create(seqAc)
end

--停止闹钟动画
function PlayerInfoLayer:stopClock()
    self.clockBg:setVisible(false)
end

function PlayerInfoLayer:reSetPlayerInfo()
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    local players = {} 
    --先把原来的数据去出来
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].getUserInfo then
            local info = self[nodeName[i]]:getUserInfo()
            if (info.seatId or -1) >= 0 and (info.seatId or -1) < MAX_PLAYER_SIZE then
                table.insert(players, info)
            end
        end
    end

    for i, v in ipairs( players ) do
        local viewId = self:getViewIdBySeatId(v.seatId)
        if viewId == 2 then
            v.isLeftPlayer = false
        else
            v.isLeftPlayer = true
        end
        self:setPlayerInfoByViewId(viewId, v)
    end
    
end

function PlayerInfoLayer:getViewIdBySeatId(seatId)   --seatId为服务器座位号
        
    if seatId == nil or seatId < 0 then return nil end

    local other_index = seatId - MY_SEAT_ID
    local viewId = 0

    if other_index < 0 then
       other_index = other_index + MAX_PLAYER_SIZE
    end
     
    viewId =  other_index + 1  -- otherIndex2playerType[other_index]

    return viewId
end

function PlayerInfoLayer:setReadyStateByUId(uid)
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].getUserInfo then
            local info = self[nodeName[i]]:getUserInfo()
            if info.uid == uid then
                self[nodeName[i]]:setReadyVisible(true)
            end
        end
    end

    if USER_INFO.uid == uid then
        self.beginBtnNode:setVisible(false)
        require("hall.GameCommon"):playEffectSound(TpackageName .. "/res/audio/on_turn.mp3")
    end
end

function PlayerInfoLayer:getUserPanleByUid(uid)
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].getUserInfo then
            local info = self[nodeName[i]]:getUserInfo()
            if info.uid == uid then
                return self[nodeName[i]]
            end
        end
    end
end

function PlayerInfoLayer:setFangZhuFlag( uid )
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].getUserInfo then
            local info = self[nodeName[i]]:getUserInfo()
            if info.uid == uid then
                self[nodeName[i]]:setFangZhuFlag(true)
            end
        end
    end
end

function PlayerInfoLayer:setZhuangFlag( uid )
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].getUserInfo then
            local info = self[nodeName[i]]:getUserInfo()
            if info.uid == uid then
                self[nodeName[i]]:setZhuangFlag(true)
            end
        end
    end
end

function PlayerInfoLayer:HideZhuangFlag( ... )
    -- body
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].setZhuangFlag then
            self[nodeName[i]]:setZhuangFlag(false)
        end
    end
end

function PlayerInfoLayer:hideAllPlayerReady()
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE  do
        if self[nodeName[i]].getUserInfo then
           self[nodeName[i]]:setReadyVisible(false)
        end
    end
    --for i, v in ipairs( nodeName ) do
    --   self[v]:setReadyVisible(false)
    --end
end

function PlayerInfoLayer:showHandlCards(cards, outUid, relogin)
    g_mainScene.myHandlerCards = self:exchangeCardsValue(cards)
    self:addCardsToPlane(g_mainScene.myHandlerCards, outUid, relogin)
end



function PlayerInfoLayer:addCardsToPlane(structCards, outUid, relogin)
    Card:sortCard(structCards)
    self.handCardPanle:removeAllChildren()
    local structCards = self:exchangeHandStrutCard(structCards)
    self._twoDimensionalCards = structCards
    for k, v in pairs(structCards or {}) do 
        for i, v1 in ipairs(v or {}) do
            local card = Card:getCard(v1, 1 , not relogin)
            if not tolua.isnull(card) then
                card.selected = 0
                card:stopAllActions()
                card:setScale(HANDLER_CARD_SCALE)
                card:setRotation(0)
                card:onClick(handler(self, self.procTouchCard))
                card:setName("card"..k)
                local posX = self:getHandCardPosX(structCards, k)
                if relogin then 
                    card:setPosition(cc.p(posX, CARD_HEIGHT + (#v - i)*((#v >= 4) and 15 or NO_BOMB_CARD_SPACE_Y)))
                else
                    local flag = (outUid == USER_INFO.uid)
                    local pos = cc.p(posX, CARD_HEIGHT + (#v - i)*((#v >= 4) and 15 or NO_BOMB_CARD_SPACE_Y))
                    self:SendAnimation(card, pos, i, flag)
                end
                if (#v < 4) and i ~= #v then
                    card.oriPosition = cc.p(posX, CARD_HEIGHT + (#v - i)*((#v >= 4) and 15 or NO_BOMB_CARD_SPACE_Y) + self:offsetPoinstionY(card))
                else
                    card.oriPosition = cc.p(posX, CARD_HEIGHT + (#v - i)*((#v >= 4) and 15 or NO_BOMB_CARD_SPACE_Y))
                end
                card:addTo(self.handCardPanle)
                if i == #v and #v >= 4 then
                    local cardSizeObj = self.cardSizeNode:clone()
                    cardSizeObj:setName("flag"..k)
                    local sizeTTF = cardSizeObj:getChildByName("sizeTTF")
                    sizeTTF:setString(#v)
                    cardSizeObj:setPosition(cc.p(posX+35, CARD_HEIGHT + #v*15 + 45))
                    cardSizeObj:addTo(self.handCardPanle)
                    if relogin then
                        cardSizeObj:setVisible(true)
                    else
                        cardSizeObj:setVisible(false)
                    end
                end
            end
        end
    end

    self:addOrRemoveHandlerCardsListener(true)-- 添加手牌的监听
end

function PlayerInfoLayer:showBombSize()
    local children = self.handCardPanle:getChildren()
    for i,v in ipairs(children or {}) do
        if v.oriPosition == nil then
            v:setVisible(true)
        end
    end
end

function PlayerInfoLayer:offsetPoinstionY(card)
    local size = card:getContentSize()
    return ((size.height*HANDLER_CARD_SCALE)/2 - NO_BOMB_CARD_SPACE_Y/2)
end

function PlayerInfoLayer:procTouchCard(event)
    dump(event.target.value, "procTouchCard == ")
end

--补充切出牌的显示，需要显示在切牌的位置
function PlayerInfoLayer:showQieCard(card, outUid)
    if card == 0 then
        self.qiepai_vw:setVisible(false)
        self:resetQiePai()
    else
        local logicValue = Card:Decode(card)
        local value, color = Card:init(logicValue)
        local tmp = {[1] = value, [2] = color} 
        local card = Card:getCard(tmp, 2)
        card:addTo(self.qiepai)
        card:setPosition(self._qieCardPos)--self._qieCardPos
        card:setScale(0.5)
        local pos = self.qiepai:convertToNodeSpace(self:getUserPanleByUid(outUid):getPosition())
        -- card:setPosition(g_mainScene:getContentSize().width / 2, g_mainScene:getContentSize().height / 2 + 170)
        card:runAction(transition.sequence({
                cc.DelayTime:create(0.5),
                cc.MoveTo:create(0.8 , pos),
                cc.FadeTo:create(0.8, 0),
                cc.CallFunc:create(function()
                    card:removeSelf()
                    self.qiepai_vw:setVisible(false)
                    self:resetQiePai()
            end),
            }))
    end
end

function PlayerInfoLayer:cleanMyHandsCards()
    self.handCardPanle:removeAllChildren()
end

-- 转换成{[value] = {{[1] = value, [2] = color},...}}
function PlayerInfoLayer:exchangeHandStrutCard(sCards)
    local result = {}
    for i,v in ipairs(sCards or {}) do
        if result[v[1] ] == nil then
            result[v[1] ] = {}
        end
        table.insert(result[v[1] ], v)
    end

    return result
end

function PlayerInfoLayer:getHandCardPosX(sCards, key)
    local beginPos = self:getBeginPosX(table.nums(sCards))
    local lstT = {[15] = 0, [14] = 0, [13] = 0, [12] = 0, [11] = 0, [10] = 0, [9] = 0, [8] = 0, [5] = 0}
    for k,v in pairs(sCards) do
        lstT[k] = 1
    end
    local idx = 0
    for i = 15, 5, -1 do
        if lstT[i] ~= nil and lstT[i] > 0 then
            idx = idx + 1
            if key == i then
                break
            end
        end
    end

    return beginPos + NO_BOMB_CARD_SPACE_X*(idx-1)
end

--发牌动画
function PlayerInfoLayer:SendAnimation( card, beginPos, index, toShowOutBtn)
    -- body
   card:setPosition(g_mainScene:getContentSize().width / 2, g_mainScene:getContentSize().height / 2 + 170)
        local xy = cc.p(beginPos, CARD_HEIGHT)
        card:runAction(transition.sequence({
            cc.DelayTime:create(index * 0.06),
            cc.MoveTo:create(0.5 , beginPos),
            cc.CallFunc:create(function()
                card:toRotation()
                if toShowOutBtn then
                    self:showOutCardBtn()
                end
                self:showBombSize()
        end),
        }))

end

--把从服务器发过来的牌（数组），转换成{{[1]= value, [2] = color},...}
function PlayerInfoLayer:exchangeCardsValue(cards)
    local result = {}
    for i, v in ipairs( cards or {} ) do
        local logicValue = Card:Decode(v)
        local value, color = Card:init(logicValue)
        if value ~= 3 and value ~= 4 then
            local tmp = {[1] = value, [2] = color} 
            table.insert(result, tmp)
        end
    end

    return clone(result)
end

function PlayerInfoLayer:getBeginPosX(size)
    local surSize = math.mod(size, 2)
    if surSize == 0 then
        return 560 - NO_BOMB_CARD_SPACE_X*(math.floor(size/2) - 1)  - NO_BOMB_CARD_SPACE_X/2
    else
        return 560 - NO_BOMB_CARD_SPACE_X*math.floor(size/2)
    end
end

function PlayerInfoLayer:setInviteVisible(b)
    self.btnInvite:setVisible(b)
end

function PlayerInfoLayer:processBeinOutCard(uid,outTime)
    if uid == g_mainScene.prevOutUserId then
        g_mainScene.prevOutCards = {} 
        g_mainScene.prevOutCardType = 0
    end
    self:showOutCardBtnByUId(uid)
    self:showClock(uid,outTime)
end

function PlayerInfoLayer:showOptTipsKuang(uid)
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].getUserInfo then
            local info = self[nodeName[i]]:getUserInfo()
            if self[nodeName[i]].optKuang then
                self[nodeName[i]].optKuang:setVisible(info.uid == uid)
            end
        end
    end
end

function PlayerInfoLayer:showOutCardBtnByUId(uid)
    print("showOutCardBtn -------------------------", uid, USER_INFO.uid, debug.traceback())
    if uid == USER_INFO.uid then
        self:showOutCardBtn()
    end
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].getUserInfo then
            local info = self[nodeName[i]]:getUserInfo()
            if self[nodeName[i]].optKuang then
                self[nodeName[i]].optKuang:setVisible(info.uid == uid)
            end
        end
    end
end

function PlayerInfoLayer:showClock(uid, times)
    local viewId = self:getViewIdByUId(uid)
    self:showClockByViewId(viewId, (times or OUT_CARD_TIMES))
end

function PlayerInfoLayer:getViewIdByUId(uid)
    local viewId = 0
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].getUserInfo then
            local info = self[nodeName[i]]:getUserInfo()
            if info.uid == uid then
                viewId = self:getViewIdBySeatId(info.seatId)
                return viewId
            end
        end
    end

    return viewId
end

function PlayerInfoLayer:getSelectCards()
    local result = {}
    local children = self.handCardPanle:getChildren()
    for i, v in ipairs( children or {} ) do
        if v.selected == 1 then
            table.insert(result, v.value)
        end
    end

    return result
end

function PlayerInfoLayer:exchangeForOutCards(cards)
    local result = {}
    for i, v in ipairs( cards or {} ) do
        local value = Card:Encode(v[1]+16*v[2])
        table.insert(result, {["card"]=value})
    end 

    return result
end

function PlayerInfoLayer:processUserOutHandCards(info)
    g_mainScene.prevOutCards = self:exchangeCardsValue(info.Cardbuf)
    g_mainScene.prevOutCardType = info.Cardtype
    g_mainScene.prevOutUserId = info.nPreOutUserId
    if info.nPreOutUserId == USER_INFO.uid then
        self:removeOutHandCards( info.Cardbuf )
        self.outCardBtnNode:setVisible(false)
    -- else
    --     --重新显示牌数
    --     local user = self:getUserByUserId(info.nPreOutUserId)
    --     user:reduceCardSize(info.Cardcount)
    end
    --播放音效
    self:PlayMusic(info)
    g_mainScene.tableLayer:clearTableOutCardsByViewId(info.nNextOutUserId) --清理前面的出的牌
    g_mainScene.tableLayer:showOutCardsInTable(info.nPreOutUserId, info.Cardtype)
end

function PlayerInfoLayer:processTurnPickScore(score)
    g_mainScene.tableLayer.pickScore:setString(score)
end


local CT_INVALID                  = 0        --错误类型
local CT_SINGLE                   = 1        --单牌类型
local CT_DOUBLE                   = 2        --对牌类型
local CT_THREE                    = 3        --三条类型
local CT_ONE_LINE                 = 4        --单连类型
local CT_DOUBLE_LINE              = 5        --对连类型
local CT_THREE_TAKE_ONE           = 6        --三带一单
local CT_THREE_TAKE_TOW           = 7        --三带二
local CT_PANEL                    = 8        --飞机
local CT_BOMB_CARD                = 9       --炸弹类型
local CT_3A_BOMB                  = 10       --3个A算特殊炸弹
local CT_BOMB_TAKE                = 11      --四带3
local CT_FOUR_TAKE_TWO            = 12      --四带二
local CT_FOUR_TAKE_ONE            = 13      --四带一
local CT_CHECP_TIP                = 14      --报单音乐
local CT_PASS                     = 15      --要不起音乐
local CT_WIN                      = 16      --赢得音乐
local CT_LOSE                     = 17      --输得音乐
local CT_SEND_CARD                = 18      --发牌音乐

local CT_INVALID                  = 0        --错误类型
local CT_SINGLE                   = 1        --单牌类型
local CT_DOUBLE                   = 2        --对牌类型
local CT_DOUBLE_LINE              = 3        --对连类型
local CT_ONE_LINE                 = 4        --顺子类型
local CT_THREE                    = 5        --三带二和飞机
local CT_BOMB_4                   = 6        --
local CT_BOMB_5                   = 7        --
local CT_BOMB_6                   = 8        --
local CT_BOMB_7                   = 9        --
local CT_BOMB_8                   = 10       --
local CT_BOMB_9                   = 11       --
local CT_BOMB_10                  = 12       --
local CT_BOMB_11                  = 13       --
local CT_BOMB_12                  = 14       --
local CT_PASS                     = 15      --要不起音乐
local CT_WIN                      = 16      --赢得音乐
local CT_LOSE                     = 17      --输得音乐
local CT_SEND_CARD                = 18      --发牌音乐



function PlayerInfoLayer:PlayMusic( info )
    -- body
    local user = self:getUserByUserId(info.nPreOutUserId)
    if user == nil then return end
    
    local sex = user:getUserInfo().sex
    local sex_path = 1 == sex and "man" or "woman"
    local music_path = TpackageName .. "/res/audio/" .. sex_path .. "/"
    local card_type = info.Cardtype
    --1.单牌类型音乐
    if CT_SINGLE == card_type then 
        local music_value = info.Cardbuf[1] % 16
        music_path = music_path .. "poker_1_" .. music_value .. ".mp3"
    elseif CT_DOUBLE == card_type then 
        local music_value = info.Cardbuf[1] % 16
        music_path = music_path .. "poker_3_" .. music_value .. ".mp3"
    elseif CT_ONE_LINE == card_type then 
        music_path = music_path .. "poker_2_0.mp3"
    elseif CT_DOUBLE_LINE == card_type then 
        music_path = music_path .. "poker_4_0.mp3"
    elseif CT_THREE == card_type then 
        music_path = music_path .. "poker_7_0.mp3"
    elseif CT_BOMB_4 <= card_type and CT_BOMB_12 >= card_type then 
        music_path = music_path .. "poker_14_0.mp3"
    elseif CT_CHECP_TIP == card_type then 
        music_path = music_path .. "poker_only_1.mp3"
    elseif CT_PASS == card_type then 
        math.randomseed(socket.gettime())
        local random = math.random(1,4)
        music_path = music_path .. "pass_" .. random .. ".mp3"
    elseif CT_WIN == card_type then 
        music_path = TpackageName .. "/res/audio/win.mp3"
    elseif CT_LOSE == card_type then 
        music_path = TpackageName .. "/res/audio/lose.mp3"
    elseif CT_FOUR_TAKE_TWO == card_type then 
        music_path = music_path .. "sidaier.mp3"
    elseif CT_SEND_CARD == card_type then 
        music_path = TpackageName .. "/res/audio/fapai.mp3"
    end

    --require("hall.GameCommon"):playEffectSound(music_path)
    require("hall.GameCommon"):play2d(music_path)

    -- viewMgr:showTip({text = tbErrorCode[errorCode]})
end

function PlayerInfoLayer:processUserOutCardsError(info)
    local seq = cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function ( ... )
                self.errorTipsImg:setVisible(false)
            end))

    self.errorTipsImg:setVisible(true)
    self.errorTipsImg:runAction(seq)
end

function PlayerInfoLayer:removeOutHandCards( cards )
    
    for i, v1 in ipairs( g_mainScene.prevOutCards ) do
        for j, v2 in ipairs( g_mainScene.myHandlerCards ) do
            if v1[1] == v2[1] and v1[2] == v2[2] then
                table.remove(g_mainScene.myHandlerCards, j)
                break
            end
        end
    end

    self:addCardsToPlane(g_mainScene.myHandlerCards, nil, true)
end

function PlayerInfoLayer:processUserPass(info)
    self:showPassFontByUId(info.nPassUserId)
    self:stopClock()
    self.outCardBtnNode:setVisible(false)
end

function PlayerInfoLayer:processSingleGameOver( info )
    self.single_tip = nil
    self._singleResultData = info
    self:stopClock()
    local sCards = self:exchangeCardsValue(info.playerList[1].diCards)
    g_mainScene.tableLayer:showDiCards(sCards)
    
    -- self:showSingleResult(info)
    print("processSingleGameOver ------------------", b, debug.traceback())
    local nodeName = {"myUser", "rightUser", "leftUser"}
    for i = 1, MAX_PLAYER_SIZE  do
        if self[nodeName[i]].getUserInfo then
            self[nodeName[i]].rankFlag:setVisible(false)
        end
    end

    self:updateUsersScore(info)
    self:clearGameingData()
    -- self:showBeginBtnByState(1)
end

function PlayerInfoLayer:showSingleResult(info)
    local singleLayer = require("yuanjiangqianfen.src.view.SingleResultLayer").new(info.playerList)
    if singleLayer then
        singleLayer:setName("singleResultLayer")
        singleLayer:setLocalZOrder(2000)
        g_mainScene:addChild(singleLayer)
    end
end

function PlayerInfoLayer:clearDeskForOver()
    self.handCardPanle:removeAllChildren()
    self:addOrRemoveHandlerCardsListener(false)
end

function PlayerInfoLayer:updateUsersScore(info)
    for i,v in ipairs(info.playerList or {}) do
        local userPanle = self:getUserPanleByUid(v.uid)
        if userPanle then
            userPanle.singleScore:setString(string.format("积分  :0"))
            userPanle.singleBombScore:setString(string.format("喜分  :0"))
            userPanle.totalScore:setString(string.format("总积分:%d", v.totalPickScore))
            userPanle.totalBombScore:setString(string.format("总喜分:%d", v.totalBombScore))
        end
    end
end

function PlayerInfoLayer:showResultScore(uid, score)
    local viewId = self:getViewIdByUId(uid)
    print("====uid==viewId=score=",uid,viewId,score)
    if viewId == 1 then
        self.myUser:showResutlScore(score)
    elseif viewId == 2 then
        self.rightUser:showResutlScore(score)
    elseif viewId == 3 then
        self.leftUser:showResutlScore(score)
    end
    if uid == USER_INFO["uid"] then
        local status = score > 0 and CT_WIN or CT_LOSE
        local info = {nPreOutUserId = uid , Cardtype = status}
        self:PlayMusic(info)
    end
end

function PlayerInfoLayer:showCheckTip(uid)
    if uid == USER_INFO["uid"] then 
        return
    end
    local viewId = self:getViewIdByUId(uid)
    print("====uid==viewId=",uid,viewId)
    if viewId == 1 then
        self.myUser:showCheckTip()
    elseif viewId == 2 then
        self.rightUser:showCheckTip()
    elseif viewId == 3 then
        self.leftUser:showCheckTip()
    end

    self.single_tip = true
    local info = {nPreOutUserId = uid , Cardtype = CT_CHECP_TIP}
    self:PlayMusic(info)
end

function PlayerInfoLayer:exchangeUserScore(uid, score)
    local viewId = self:getViewIdByUId(uid)
    if viewId == 1 then
        self.myUser:exchangeForSingleScore(score)
    elseif viewId == 2 then
        self.rightUser:exchangeForSingleScore(score)
    elseif viewId == 3 then
        self.leftUser:exchangeForSingleScore(score)
    end
end

function PlayerInfoLayer:getUserScore(uid)
    local viewId = self:getViewIdByUId(uid)
    if viewId == 1 then
        return self.myUser:getUserScore()
    elseif viewId == 2 then
        return self.rightUser:getUserScore()
    elseif viewId == 3 then
        return self.leftUser:getUserScore()
    end
    return 0
end

function PlayerInfoLayer:clearAllUserInfo()
    self.outCardBtnNode:setVisible(false)
    self.beginBtnNode:setVisible(false)
    self:stopClock()
end

function PlayerInfoLayer:clearGameingData()
    g_mainScene.myHandlerCards = {}
    g_mainScene.prevOutCards = {} 
    g_mainScene.prevOutCardType = 0
end

function PlayerInfoLayer:showPassFontByUId(uid)
    local viewId = self:getViewIdByUId(uid)
    if viewId == 1 then
        self.myUser:showPassAni()
    elseif viewId == 2 then
        self.rightUser:showPassAni()
    elseif viewId == 3 then
        self.leftUser:showPassAni()
    end
    local info = {nPreOutUserId = uid , Cardtype = CT_PASS}
    self:PlayMusic(info)
end

--牌局进行中的重连收的消息
function PlayerInfoLayer:processReloadRoom(info)
    g_mainScene.roomCommonLayer:setRoomNum(info.inviteCode)
    -- 设置牌子上的玩家信息
    self:setPlayerListInfo(info.playerlist)
    self.qie_listener1:setSwallowTouches(false)
    if 0 == info.GAME_STATE then 
        for k , v in pairs(info.playerlist) do 
            if v.if_ready ~= 1 and v.uid == USER_INFO["uid"] then
                g_mainScene.playerInfoLayer:showBeginBtnByState(2)
                return
            end
        end
        return 
    end

    if 1 ==  info.GAME_STATE then -- 切牌状态
        local outUser = self:getUserBySeatId(info.qieSeatId)
        local outUserInfo = outUser:getUserInfo()
        self:showQiepai(outUserInfo.uid)
        return 
    end

    --重连牌的设置
    local rSize = 0
    local lSize = 0
    local outCardSeatId = -1
    for i, v in ipairs( info.playerlist ) do
        local viewId = self:getViewIdByUId(v.uid)
        if viewId == 2 then
            rSize = v.HandCardCount
        elseif viewId == 3 then
            lSize = v.HandCardCount
        end 
        -- if v.uid == info.OutCardUserId then
        --     outCardSeatId = v.seat_id
        -- end
    end
    self:setVisibleAllUserReady(false)
    self:setHandCardsAndOtherCardSize(info.HandCardDatas, rSize, lSize , nil,  true)
    self:processTurnPickScore(info.tablePickScore)
    local outUser = self:getUserBySeatId(info.OutCardSeatId)
    local outUserInfo = outUser:getUserInfo()
    self:showClock(outUserInfo.uid, info.LeftTime)
    if outUserInfo.uid == USER_INFO.uid then
        self:showOutCardBtn()
    end

    if info.OutCardSeatId == info.turnCardSeatId then
        self.prevOutCards = {} -- 保存上次的出牌
        self.prevOutCardType = 0
    end

    local lastSeatId = info.turnCardSeatId--self:findLastOutCardSeatId(info.turnOutCard, info.turnCardSeatId)
    if lastSeatId == -1 then
        g_mainScene.prevOutCards = {} -- 保存上次的出牌
        g_mainScene.prevOutCardType = 0
    end
    -- for i,v in ipairs(info.turnOutCard) do
    if info.turnOutCardSize > 0 then
        local viewId = self:getViewIdBySeatId(lastSeatId)
        local cards = self:exchangeCardsValue(info.turnOutCard)
        local cardType = info.turnCardType--CardsAnalysis:getType(cards)
        g_mainScene.prevOutCards = cards -- 保存上次的出牌
        g_mainScene.prevOutCardType = info.turnCardType
        g_mainScene.tableLayer:showOutCardsByViewId(viewId, cards, cardType, true)
    end
    -- end
end

function PlayerInfoLayer:findLastOutCardSeatId(cards, outCardSeatId)
    for i = 1, #cards do
        local prevSeatId = outCardSeatId - i < 0 and MAX_PLAYER_SIZE -1 or outCardSeatId - i
        if cards[prevSeatId+1].CardCount ~= 0 then
            return prevSeatId
        end
    end

    return -1
end

function PlayerInfoLayer:setPlayerListInfo(lst)
    -- 设置牌子上的玩家信息
    for i, v in ipairs( lst ) do
        if v.uid == USER_INFO.uid then 
            MY_SEAT_ID = v.seat_id
        end
    end
    for i, v in ipairs( lst ) do
        local playerInfo = self:getUserHeadInfo(v)
        local viewId = self:getViewIdBySeatId(v.seat_id)
        -- print("setPlayerListInfo ---------------", viewId, v.seat_id, v.singleBombScore)
        if viewId == 2 then
            playerInfo.isLeftPlayer = false
        else
            playerInfo.isLeftPlayer = true
        end
        self:setPlayerInfoByViewId(viewId, playerInfo)

        if viewId == 1 then
            self.myUser:setUserGameScore(v.singlePickScore, v.totalPickScore, v.singleBombScore, v.totalBombScore)
        elseif viewId == 2 then
            self.rightUser:setUserGameScore(v.singlePickScore, v.totalPickScore, v.singleBombScore, v.totalBombScore)
        elseif viewId == 3 then
            self.leftUser:setUserGameScore(v.singlePickScore, v.totalPickScore, v.singleBombScore, v.totalBombScore)
        end
    end
end

--relogin 用来作重连动画.以及发牌动画
function PlayerInfoLayer:setHandCardsAndOtherCardSize(cards, rSize, lSize , outUid, relogin)
    self:showHandlCards(cards, outUid, relogin)
    if  self.rightUser.setSurplusCardSize then
        self.rightUser:setSurplusCardSize(rSize)
    end
    if self.leftUser.setSurplusCardSize  then
        self.leftUser:setSurplusCardSize(lSize)
    end
    if not relogin then 
        local info = {nPreOutUserId = USER_INFO["uid"] , Cardtype = CT_SEND_CARD}
        self:PlayMusic(info)
    end
end

function PlayerInfoLayer:setVisibleAllUserReady(b)
    print("setVisibleAllUserReady ------------------", b, debug.traceback())
    local nodeName = {"myUser", "rightUser", "leftUser"}
    for i = 1, MAX_PLAYER_SIZE  do
        if self[nodeName[i]].getUserInfo then
            self[nodeName[i]]:setReadyVisible(b)
            self[nodeName[i]].rankFlag:setVisible(b)
        end
    end
    --for i, v in ipairs( nodeName ) do
    --    self[v]:setReadyVisible(b)
    --end
end

function PlayerInfoLayer:getUserHeadInfo(info)
    local result = {}
    result.name = info.nickName
    result.score = info.user_gold / 100
    result.icon_url = info.portrait
    result.uid = info.uid
    result.sex = info.sex
    result.seatId = info.seat_id
    result.isReady = info.if_ready > 0
    result.isOnline = (info.if_online or 1) > 0

    return clone(result)
end

function PlayerInfoLayer:processRevcDisbandInfo( info )
    if info.agreeNum == 0 then
        if g_mainScene.roomCommonLayer.disbandLayer == nil then
            local playerLst = self:getUserInfoLstToDisband(info.applyId)
            g_mainScene.roomCommonLayer:processRevcRequestDisband(playerLst)
        end
    else
        if g_mainScene.roomCommonLayer.disbandLayer == nil then
            local playerLst = self:getUserInfoLstToDisband(info.applyId)
            g_mainScene.roomCommonLayer:processRevcRequestDisband(playerLst)
        end
        for i, v in ipairs( info.agreeMember_arr ) do
            g_mainScene.roomCommonLayer:exchangeStateBySel(v, 1)
        end
    end
end

function PlayerInfoLayer:getUserInfoLstToDisband(applyId)
    --{state = 1,userId = 12345, userName = "asdf", userUrl = "" }
    local nodeName = {"myUser", "rightUser", "leftUser"}
    local result = {}
    for i = 1, MAX_PLAYER_SIZE  do
        if self[nodeName[i]].getUserInfo then
            local info =  self[nodeName[i]]:getUserInfo()
            local tmp = {}
            tmp.state = info.uid == applyId and 3 or 2
            tmp.userId = info.uid
            tmp.userName = info.name
            tmp.userUrl = info.icon_url
            table.insert(result, tmp)
        end
    end
    --for i, v in ipairs( nodeName ) do
    --    if self[v].getUserInfo then
    --        local info = self[v]:getUserInfo()
    --        local tmp = {}
    --        tmp.state = info.uid == applyId and 3 or 2
    --        tmp.userId = info.uid
    --        tmp.userName = info.name
    --        tmp.userUrl = info.icon_url
    --
    --        table.insert(result, tmp)
    --    end
    --end

    return result
end

function PlayerInfoLayer:processRevcRejectDisband( info )
    g_mainScene.roomCommonLayer:clearDisbandLayer()
    local userLst = self:getUserInfoLstToDisband(0)
    local name = ""
    for i, v in ipairs( userLst ) do
        if info.rejectId == v.userId then
            name = v.userName
        end
    end
    local paras = {}
    paras.type = 1
    paras.title = "提示"
    paras.content = string.format("解散房间失败,玩家[%s]拒绝解散!", name)
    require("hall.tips.CommonTips"):showTips(paras)
    --g_mainScene.roomCommonLayer:exchangeStateBySel(info.rejectId, 0)
end

function PlayerInfoLayer:processRevcDisbandRoomSucc()
    -- 清理桌面数据
    bm.isDisbandSuccess = true
    g_mainScene.roomCommonLayer:clearDisbandLayer()
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
end

function PlayerInfoLayer:processUserStandUp(info)
    local user = self:getUserByUserId(info.uid)
    user:initUserInfo({})
    user:setVisible(false)
    -- require("hall.tips.CommonTips"):_gameToHall()
end

function PlayerInfoLayer:getUserByUserId(uid)
    local viewId = self:getViewIdByUId(uid)
    dump("viewId",viewId)
    if viewId == 1 then
        return self.myUser
    elseif viewId == 2 then
        return self.rightUser
    elseif viewId == 3 then
        return self.leftUser
    end
end

function PlayerInfoLayer:getUserInfoByUserId(uid)
    local viewId = self:getViewIdByUId(uid)
    print("viewId -------------------", viewId)
    if viewId == 1 then
        return self.myUser:getUserInfo()
    elseif viewId == 2 then
        return self.rightUser:getUserInfo()
    elseif viewId == 3 then
        return self.leftUser:getUserInfo()
    end
end

function PlayerInfoLayer:getUserBySeatId(sid)
    local viewId = self:getViewIdBySeatId(sid)
    dump("viewId",viewId)
    if viewId == 1 then
        return self.myUser
    elseif viewId == 2 then
        return self.rightUser
    elseif viewId == 3 then
        return self.leftUser
    end
end

function PlayerInfoLayer:processFaceAndTxt(info)
    local user = self:getUserByUserId(info.uid)

    user:showFaceAndTxtByIndex(info.type)
end

function PlayerInfoLayer:onClickBtnTip(sender, event)
    self._onClickTipIdx = (self._onClickTipIdx or 0) + 1

    if #(self._tipCards or {}) == 0 then
        self._tipCards = CardsAnalysis:getSuitCardFromHandlerCards(g_mainScene.prevOutCardType, g_mainScene.prevOutCards)
    end
    -- print("onClickBtnTip --------------- ", self._onClickTipIdx)
    -- dump(self._tipCards, "onClickBtnTip == ")
    local card = self.single_tip and self._tipCards[#self._tipCards] or self._tipCards[self._onClickTipIdx]
    self:showTipsCards(card)
    if #self._tipCards == self._onClickTipIdx then
        self._onClickTipIdx = 0
    end
end

function PlayerInfoLayer:showTipsCards(cards)
    self:clearHandlerCardsSelect()
    local childCards = self.handCardPanle:getChildren()
    dump( cards,"numbershowTipsCards ---------------------")
    if cards == nil then
        --提示出牌
        -- self:TipsAutoCard()
        return
    end
    if next(cards) == nil then
        return
    end
    if type(cards[1]) == "number" then
        cards={
            cards
        }
    end
    for i, v in ipairs( cards or {} ) do
        for j, v2 in pairs( self.handCardPanle:getChildren() or {} ) do
            if v2.oriPosition and v[1] ==  v2.value[1] and v[2] == v2.value[2] then
                if v2.selected ~= 1 then
                    v2:toUp()
                    v2:toBlack()
                    v2.selected = 1
                    break
                end
            end
        end
    end
end

function PlayerInfoLayer:TipsAutoCard()
    local small_value = 100
    local small_index = 0
    local second_index
    local second_value
    local big_value = -1
    local big_index = -1

    local big_state = false
    if self.rightUser and self.rightUser.leftCardSize and 1 == tonumber(self.rightUser.leftCardSize:getString()) then 
        big_state = true
    end

    for k , v in ipairs(self.handCardPanle:getChildren() or {}) do
        -- dump(v.value , "TipsAutoCard")
        if v.oriPosition then
            if v.value[1] == small_value then 
                second_index = k
                second_value = v.value[1]
            end

            if v.value[1] < small_value then 
                small_value = v.value[1]
                small_index = k
            end
            if v.value[1] > big_value then 
                big_value = v.value[1]
                big_index = k
            end
        end
    end

    for k, v in ipairs( self.handCardPanle:getChildren() or {} ) do
        if v.oriPosition then
            if big_state and k == big_index then 
                if v.selected ~= 1 then
                    v:toUp()
                end
                v.selected = 1
                break
            end
            if k == small_index or (second_index and k == second_index and small_value == second_value) then 
                if v.selected ~= 1 then
                    v:toUp()
                end
                v.selected = 1
            end
        end
    end
end

function PlayerInfoLayer:clearHandlerCardsSelect()
    for i, v in ipairs( self.handCardPanle:getChildren() or {} ) do
        if v.oriPosition then
            if v.selected == 1 then
                v:toDown()
                v:toWhite()
            end
            v.selected = 0
        end
    end
end

function PlayerInfoLayer:onClickBtnOutCard(sender, event)
    local outCards = self:getSelectCards()
    if #outCards > 0 then
        self._onClickTipIdx = 0
        self._tipCards = {}
        local cards = self:exchangeForOutCards(outCards)
        dump(cards,"====玩家出牌====")
        YJQFServer:CLI_PLAYER_CARD(#cards, cards)
    end
end

function PlayerInfoLayer:onClickBtnInvite(sender, event)
    -- body
    local paras = {}
    paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
    paras["imagePath"] = "url"
    paras["name"] = "跑得快，房号：" .. USER_INFO["invote_code"]
    paras["showType"] = 2;
    paras["url"] = appDownLoadAddress

    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(SCENENOW["scene"],9999999)
    end
end

function PlayerInfoLayer:onClickBtnReady(sender, event)
    -- g_mainScene:showAllResultLayer()
    YJQFServer:CLI_READY_GAME(1)
    -- self:showQiepai(USER_INFO.uid)
end

function PlayerInfoLayer:onClickBtnCopyRoomnum(sender, event)
    local strNick = require("hall.GameCommon"):formatNick(USER_INFO["nick"], 4)
    local shareInfo = "玩家"..strNick.."邀请你加入千分游戏，房间号【"..USER_INFO["invote_code"].."】。"
    require(GameSetting_filePath):copyToClipboard(shareInfo)
end

------------------------------切牌--------------------------------
function PlayerInfoLayer:initQiePaiUI()

    self.qiepai_vw:setVisible(false)
    local cardPath = "yuanjiangqianfen/res/image/cards" 
    -- self.btn_shouzhiPos = self.btn_shouzhi:getPosition()
 
    local size = self.qiepai:getContentSize()
    local startPos = -100

    for i = 1, 101 do
        local cardImg = cc.Sprite:create(cardPath .. "/card_back.png")
        cardImg:setPosition(cc.p(startPos + i * 10, size.height*0.5))
        cardImg:setScale(0.5)
        cardImg:setAnchorPoint(cc.p(0.5,0.5))
        cardImg:addTo(self.qiepai)
    end
    self:addTouchEventListenerQiePanel(self.qiepai)
    -- self.qiepai:onTouch(handler(self, self.onClickHandCard))
    -- self.btn_shouzhi:onTouch(handler(self, self.onClickShouZhi))
    self.btn_sure:onClick(handler(self, self.onClickQiepaiSure))
    self._qieCardPos = cc.p(440, 55)
    -- self.qie_listener1:setSwallowTouches(false)
end

function  PlayerInfoLayer:addTouchEventListenerQiePanel(plane)
    
    local selectedCardCount_ex
    local rtSelectCard
    local ptTouchBegin = cc.p(0,0)

    local _card_start_x = 0 
    local _card_start_y = 0 
    local _card_move_type = 0

    local cardTemp

    local function onTouchBegan(touch, event)
        print("onTouchBegan qie ------------------------------- afdasdf", self.qiepai_vw:isVisible(), plane:isVisible(), plane:getChildrenCount())
        cardTemp = nil
        local beganPosition = touch:getLocation()
        _card_start_x = beganPosition.x
        local children = plane:getChildren()
        for k,v in pairs(children) do
            local locationInNode = v:convertToNodeSpace(beganPosition)
            if locationInNode.x > 0 then
                v:setColor(cc.c3b(127,127,127))
            else
                v:setColor(cc.c3b(255,255,255))
            end                    
        end
        local pos = self.qiepai:convertToNodeSpace(beganPosition)
        self._qieCardPos = cc.p(pos.x, 55)
        return true
    end

    local function onTouchMoved(touch, event)
        local endPosition = touch:getLocation()
        local endX = endPosition.x
        local endY = endPosition.y
        print("onTouchMoved qie -------------------------------",_card_start_x,  endX)
        -- if  (math.abs(endX - _card_start_x)) > 4  then-- and (math.abs(endY - _card_start_y)  / math.abs(endX - _card_start_x) ) < 0.5 )
            local beganPosition = touch:getLocation()
            local children = plane:getChildren()
            for k,v in pairs(children) do
                local locationInNode = v:convertToNodeSpace(endPosition)
                if locationInNode.x > 0 then
                    v:setColor(cc.c3b(127,127,127))
                else
                    v:setColor(cc.c3b(255,255,255))
                end                    
            end
            local pos = self.qiepai:convertToNodeSpace(beganPosition)
            self._qieCardPos = cc.p(pos.x, 55)
        -- end
        return true
    end

    local function onTouchEnded(touch, event)
        print("touch qie end -----------------------")
    end

    local function onTouchCancell(touch, event)
        print("touch qie cancel -----------------------")
    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    self.qie_listener1 = listener1
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    -- listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    -- listener1:registerScriptHandler(onTouchCancell,cc.Handler.EVENT_TOUCH_CANCELLED )
     
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, plane)
end

function PlayerInfoLayer:setQiePaiPanelVisible(flag)
    print("setQiePaiPanelVisible ------------------", flag)
    self.qiepai_vw:setVisible(flag)
    self.qie_listener1:setSwallowTouches(flag)
end

function PlayerInfoLayer:resetQiePai()
    -- self.btn_shouzhi:setPosition(self.btn_shouzhiPos)
    self._qieCardPos = cc.p(40, 55)
    local nodes = self.qiepai:getChildren()
    for i,node in ipairs(nodes) do
        local pos = node:getPosition()
        node:setColor(cc.c3b(255,255,255))
    end
end

--还没完成的方法
function PlayerInfoLayer:showQiepai(uid)
    local info = self.myUser:getUserInfo()
    -- if uid == info.uid then
    self:resetQiePai()
    self.qie_listener1:setSwallowTouches(true)
    self.qiepai_vw:setVisible(true)
    print("showQiepai ----------------", self.qiepai_vw:isVisible())
    self.btn_sure:setVisible(uid == info.uid)
    -- end
end

function PlayerInfoLayer:showBombScore(data)
    for i,v in ipairs(data.playerList or {}) do
        local userPanle = self:getUserPanleByUid(v.uid)
        if userPanle then
            userPanle.singleBombScore:setString(string.format("喜分:%d", v.singleBombScore or 0))
            userPanle.totalBombScore:setString(string.format("总喜分:%d", v.totalBombScore or 0))
        end
    end
    
end

function PlayerInfoLayer:showUserSinglePickScore(uid, score)
    local userPanle = self:getUserPanleByUid(uid)
    if userPanle then
        userPanle.singleScore:setString(string.format("积分:%d", score or 0))
    end
end

function PlayerInfoLayer:onClickQiepaiSure(event)
    local target = event.target
    if event.name == "ended" then
        YJQFServer:CLI_QIEPAI()
        -- self.qiepai_vw:setVisible(false)
        -- self.qie_listener1:setSwallowTouches(false)
        -- self:resetQiePai()
    end
end

function PlayerInfoLayer:onClickShouZhi(event)
    local target = event.target
    if event.name == "moved" or event.name == "began" then
        local x, y = event.x, event.y
        local pos = cc.p(x, y)
        local nodePos = target:convertToNodeSpace(pos) --这样写是为了贴近函数的原始用法
        local parentPos = target:getParent():convertToNodeSpace(pos) --这样写是为了贴近函数的原始用法
        self:change_btn_shouzhi_pos(parentPos)
    end
end

function PlayerInfoLayer:onClickHandCard(event)
    local target = self.qiepai
    if event.name == "moved" or event.name == "began" then
        local x, y = event.x, event.y
        local pos = cc.p(x, y)
        local nodePos = target:convertToNodeSpace(pos) --这样写是为了贴近函数的原始用法
        local parentPos = target:getParent():convertToNodeSpace(pos) --这样写是为了贴近函数的原始用法
        self:change_btn_shouzhi_pos(parentPos)
    end
end

function PlayerInfoLayer:change_btn_shouzhi_pos(parentPos)
    if parentPos.x < 200 or parentPos.x > 1280 then
        return 
    end
    self.btn_shouzhi:setPositionX(parentPos.x)
    local worldpoint = (self.btn_shouzhi:getParent()):convertToWorldSpace(self.btn_shouzhi:getPosition()) --这样写是为了贴近函数的原始用法
    local pos = self.qiepai:convertToNodeSpace(worldpoint) --这样写是为了贴近函数的原始用法
    self:changeColorByPos(pos.x)
end

function PlayerInfoLayer:changeColorByPos(x)
    local nodes = self.qiepai:getChildren()
    for i,node in ipairs(nodes) do
        local pos = node:getPosition()
        if pos.x < x then
            node:setColor(cc.c3b(255,255,255))
        else
            node:setColor(cc.c3b(255,255,0))
        end
    end
end

function PlayerInfoLayer:showUserRank(pack)
    local userNode = self:getUserPanleByUid(pack.userId)
    if userNode then
        userNode:showRank(pack.rank)
    end
end

function PlayerInfoLayer:onExit()
    -- body
end

return PlayerInfoLayer