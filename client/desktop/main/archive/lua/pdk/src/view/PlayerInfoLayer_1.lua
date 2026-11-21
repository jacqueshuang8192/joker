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
local PDKServer = import(TpackageName .. ".src.protocol.PDKServer")

local ViewBaseLayer = require("hall.ViewBaseLayer")
local PlayerInfoLayer = class("PlayerInfoLayer", ViewBaseLayer)


local CLICK_CARD_VIOCE = "pdk/res/audio/card_click.mp3"
local MAX_USER_SIZE = 3 
local POS_CLOCK = { 
                    [1]= cc.p(640*ViewBaseLayer:_getScaleParam2(), 294),
                    [2]= cc.p(1000*ViewBaseLayer:_getScaleParam2(),580),
                    [3]= cc.p(280*ViewBaseLayer:_getScaleParam2(),580)
                }

function PlayerInfoLayer:ctor()
    PlayerInfoLayer.super.ctor(self, "pdk/res/PDKUserInfoLayer.csb")

    self:initUIInfo()
end

function PlayerInfoLayer:initUIInfo()
    self.myUser:setVisible(false)
    self.rightUser:setVisible(false)
    self.leftUser:setVisible(false)
    self.outCardBtnNode:setVisible(false)
    self.beginBtnNode:setVisible(false)
    self.errorTipsImg:setVisible(false)
    self.outCardBtnNode:setPositionY(self.outCardBtnNode:getPositionY() - 50)
    self:setPiaoVisible()
    self:stopClock()
    self:addTouchEventListenerForCards(self.handCardPanle)
    self:initQiePaiUI()
end

function PlayerInfoLayer:setPlayerInfoByViewId(viewId, info)
    g_mainScene.userInfoByViewId[info.uid] = info
    if viewId == 1 then
        self.myUser = require("hall.util.CocosUtil"):bindCocosObjToLua(self.myUser, "pdk.src.view.UserInfoNode", info)
        self.myUser:setVisible(true)
        self.myUser:setLeftPlayer(true)
        --新录音位置显示
        local point = cc.p(self.myUser:getAnchorPoint().x * self.myUser:getContentSize().width, self.myUser:getAnchorPoint().y * self.myUser:getContentSize().height)
        require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(info.uid, self.myUser:convertToWorldSpace(point))
    elseif viewId == 2 then
        self.rightUser = require("hall.util.CocosUtil"):bindCocosObjToLua(self.rightUser, "pdk.src.view.UserInfoNode", info)
        self.rightUser:setVisible(true)
        self.rightUser:setLeftPlayer(false)
        --新录音位置显示
        local point = cc.p(self.rightUser:getAnchorPoint().x * self.rightUser:getContentSize().width, self.rightUser:getAnchorPoint().y * self.rightUser:getContentSize().height)

        require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(info.uid, self.rightUser:convertToWorldSpace(point))
    elseif viewId == 3 then

        self.leftUser = require("hall.util.CocosUtil"):bindCocosObjToLua(self.leftUser, "pdk.src.view.UserInfoNode", info)
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
        cardTemp = nil
        local beganPosition = touch:getLocation()
        local children = plane:getChildren()
        for k,v in pairs(children) do
            local locationInNode = v:convertToNodeSpace(beganPosition)

            local s = v:getContentSize()
            local rect = cc.rect(0, -25, s.width, s.height + 25)
            if  cc.rectContainsPoint(rect, locationInNode) then
                cardTemp = v
            end
                    
        end

        if cardTemp then

            require("hall.GameCommon"):play2d(CLICK_CARD_VIOCE)

            _card_start_x   = cardTemp:getPositionX()  
            _card_start_y   = cardTemp:getPositionY()
            ptTouchBegin.x  = beganPosition.x
            ptTouchBegin.y  = beganPosition.y
            
            _card_move_type = 0 
            cardTemp:toBlack()

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
        local endPosition = touch:getLocation()
        local endX = endPosition.x
        local endY = endPosition.y
        --print("onTouchMoved -------------------------------",_card_start_x,  endX, (math.abs(endY - _card_start_y)  / math.abs(endX - _card_start_x) ))
        if  (math.abs(endX - _card_start_x)) > 4  then-- and (math.abs(endY - _card_start_y)  / math.abs(endX - _card_start_x) ) < 0.5 )
             
            _card_move_type  = 1
            local startx_t
            local width

            if  endX  > _card_start_x then
                startx_t = _card_start_x
                width = endX - _card_start_x + 40
            else
                startx_t = endX
                width = _card_start_x -  endX     
            end
            local pY = 0
            local rtHeight = 124
            if endY > 124 then
                pY = 50
                rtHeight = 203
            end

            rtSelectCard  =    cc.rect(startx_t, pY, width, rtHeight)

            local selectedCardCount = self:touchAreaCard(rtSelectCard)
            
            if selectedCardCount_ex ~= selectedCardCount then
                cc.SimpleAudioEngine:getInstance():playEffect(CLICK_CARD_VIOCE, false)
            end

            selectedCardCount_ex = selectedCardCount
            return

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
            print("onTouchEnded 1------------------------------- ",cardTemp.selected)
            cardTemp.selected = 1 - tonumber(cardTemp.selected or "0")
            print("onTouchEnded 2------------------------------- ",cardTemp.selected)
            if cardTemp.selected == 1 then
                cardTemp:toUp()
            else
                cardTemp:toDown()
            end
            cardTemp:toWhite()

        elseif  _card_move_type == 1 then --拉选
            local tbCards = self:touchSelectCard(rtSelectCard)

            if tbCards then
                local tbAICards = CardsAnalysis:getSuitCardsForSelectCards(tbCards)--CardsAnalysis:getSelectCardsForSingleShunzi(tbCards)
                dump(tbAICards, "tbAICards -----------")
                if #tbAICards == 0 then
                    --拉选后弹出牌
                    for i, SelectedCardNode in ipairs(tbCards) do
                        dump(SelectedCardNode)
                        SelectedCardNode.selected = 1 - tonumber(SelectedCardNode.selected or "0")        
                    end
                    self:setCardOther(tbCards)
                else
                    for i, SelectedCardNode in ipairs(tbCards) do
                        SelectedCardNode:toWhite()  
                    end
                    --拉选后弹出牌
                    for i, SelectedCardNode in ipairs(tbAICards) do
                        dump(SelectedCardNode)
                        SelectedCardNode.selected = 1 - tonumber(SelectedCardNode.selected or "0")        
                    end
                    self:setCardOther(tbAICards)
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
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener1:registerScriptHandler(onTouchCancell,cc.Handler.EVENT_TOUCH_CANCELLED )
     
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, plane)
end

--触摸区域显示牌
function PlayerInfoLayer:touchAreaCard(rect)
    
    local selectedCardCount = 0
    for i,cardNode in ipairs(self.handCardPanle:getChildren()) do

        local flag = cc.rectContainsPoint(rect, cardNode.oriPosition)
        if flag then
            cardNode:toBlack()
            selectedCardCount = selectedCardCount + 1
        else
            cardNode:toWhite()
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

        local flag = cc.rectContainsPoint(rect, cardNode.oriPosition)
        if flag  then
            table.insert(tbSelectCards,cardNode)
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
            else
               cardNode:toDown()
            end
       
            cardNode:toWhite()
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

function PlayerInfoLayer:setPiaoVisible(show)
    -- 隐藏面板
    self.Panel_piao:setVisible(false)
end
function PlayerInfoLayer:hideAllPiaoTipsIco()
    -- body

    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser",[4] = "topUser"}
    --local nodeName = {"myUser", "rightUser", "leftUser", "topUser"}
    for i = 1, MAX_PLAYER_SIZE do

        local info = self[nodeName[i]]:getUserInfo()

        if info then
            self[nodeName[i]]:setVisible(false)--hidePiaoTipsIco(piaoNum)
        end
    end
end


function PlayerInfoLayer:showPiaoTipsIco(uid, piaoNum)
    -- body
    print("showPiaoTipsIco ---------------", piaoNum)
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser",[4] = "topUser"}
    do return end
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].getUserInfo then
            local info = self[nodeName[i]]:getUserInfo()
            if info.uid == uid then
                self[nodeName[i]]:showPiaoTipsIco(piaoNum)
            end
        end
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
    local beginPos = self:getBeginPosX(#structCards)
    for i , v in ipairs(structCards or {}) do 
        local card = Card:getCard(v, 1 , not relogin)
        if not tolua.isnull(card) then
            card.selected = 0
            card:stopAllActions()
            card:setRotation(0)
            if relogin then 
                card:setPosition(cc.p(beginPos + CARD_INTERVAL*(i-1), CARD_HEIGHT))
            else
                local flag = (i == #structCards) and (outUid == USER_INFO.uid)
                self:SendAnimation(card, beginPos, i, flag)
            end
            card.oriPosition = cc.p(beginPos + CARD_INTERVAL*(i-1), CARD_HEIGHT)
            card:addTo(self.handCardPanle)
        end
    end
end


function PlayerInfoLayer:cleanMyHandsCards()
    self.handCardPanle:removeAllChildren()
end

--发牌动画
function PlayerInfoLayer:SendAnimation( card, beginPos, index, toShowOutBtn)
    -- body
   card:setPosition(g_mainScene:getContentSize().width / 2, g_mainScene:getContentSize().height / 2 + 170)
        local xy = cc.p(beginPos + CARD_INTERVAL*(index-1), CARD_HEIGHT)
        card:runAction(transition.sequence({
            cc.DelayTime:create(index * 0.01),
            cc.MoveTo:create(0.01 , xy),
            cc.CallFunc:create(function()
                card:toRotation()
                if toShowOutBtn then
                    self:showOutCardBtn()
                end
        end),
        }))

end

--把从服务器发过来的牌（数组），转换成{{[1]= value, [2] = color},...}
function PlayerInfoLayer:exchangeCardsValue(cards)
    local result = {}
    for i, v in ipairs( cards or {} ) do
        local logicValue = Card:Decode(v)
        local value, color = Card:init(logicValue)
        local tmp = {[1] = value, [2] = color} 
        table.insert(result, tmp)
    end

    return clone(result)
end

function PlayerInfoLayer:getBeginPosX(size)
    local surSize = math.mod(size, 2)
    if surSize == 0 then
        return 640 - CARD_INTERVAL*(math.floor(size/2) - 1) - CARD_INTERVAL/2 + 60
    else
        return 640 - CARD_INTERVAL*math.floor(size/2) + 60
    end
end

function PlayerInfoLayer:setInviteVisible(b)
    self.btnInvite:setVisible(b)
    self.btnCopyRoomnum:setVisible(b)
end

function PlayerInfoLayer:processBeinOutCard(uid,outTime)
    self:showOutCardBtnByUId(uid)
    self:showClock(uid,outTime)
end

function PlayerInfoLayer:showOutCardBtnByUId(uid)
    -- print("showOutCardBtn -------------------------", uid, USER_INFO.uid, debug.traceback())
    if USER_INFO.uid == uid then
        self.outCardBtnNode:setVisible(true)
        if not isSelfChu then
            self:onClickBtnTip()
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
        if v.selected == 1 then-- and v.value > 0 
            print("getSelectCards ---------------", v.value)
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
    if info.nPreOutUserId == USER_INFO.uid then
        self:removeOutHandCards( info.Cardbuf )
        self.outCardBtnNode:setVisible(false)
    else
        --重新显示牌数
        local user = self:getUserByUserId(info.nPreOutUserId)
        user:reduceCardSize(info.Cardcount)
    end
    --播放音效
    self:PlayMusic(info)
    g_mainScene.tableLayer:clearTableOutCardsByViewId(info.nNextOutUserId) --清理前面的出的牌
    g_mainScene.tableLayer:showOutCardsInTable(info.nPreOutUserId, info.Cardtype)
end


local CT_INVALID                  = 0        --错误类型
local CT_SINGLE                   = 1        --单牌类型
local CT_DOUBLE                   = 2        --对牌类型
local CT_THREE                    = 6        --三条类型
local CT_ONE_LINE                 = 4        --单连类型
local CT_DOUBLE_LINE              = 3        --对连类型
local CT_THREE_TAKE_ONE           = 6        --三带一单
local CT_THREE_TAKE_TOW           = 5        --三带二
local CT_PANEL                    = 7        --飞机
local CT_PANEL_LACK               = 8        --飞机
local CT_BOMB_CARD                = 12       --炸弹类型
local CT_3A_BOMB                  = 12       --3个A算特殊炸弹
local CT_BOMB_TAKE                = 9      --四带3
local CT_FOUR_TAKE_TWO = 10 --四带二
local CT_FOUR_TAKE_ONE = 11 --四带一
local CT_CHECP_TIP                = 14      --报单音乐
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
    elseif CT_THREE_TAKE_TOW == card_type then 
        music_path = music_path .. "poker_7_0.mp3"
    elseif CT_THREE == card_type then 
        music_path = music_path .. "poker_7_1.mp3"
    elseif CT_THREE_TAKE_ONE == card_type then 
        music_path = music_path .. "poker_7_2.mp3"
    elseif CT_PANEL == card_type or CT_PANEL_LACK == card_type then 
         music_path = music_path .. "poker_9_0.mp3"
    elseif CT_BOMB_CARD == card_type then 
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
        music_path = nil --TpackageName .. "/res/audio/fapai.mp3"
    else
        music_path = nil
    end

    --require("hall.GameCommon"):playEffectSound(music_path)
    if music_path ~= nil then
        require("hall.GameCommon"):play2d(music_path)
    end
    
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
    g_mainScene.tableLayer:clearTableOutCardsByViewId(info.nPassUserId)
    self:showPassFontByUId(info.nPassUserId)
    self:stopClock()
    self.outCardBtnNode:setVisible(false)
end

function PlayerInfoLayer:processUserAlert(info)
    self:showAlertFlagByUId(info.userId)
end

function PlayerInfoLayer:processSingleGameOver( info )
    self.single_tip = nil
    self:stopClock()
    local hasChuntian = false
    for i, v in ipairs( info.playerList ) do
        -- print("====i===v==",v.Turningscore)
        -- self:showResultScore(v.Uid, v.Turningscore)
        self:exchangeUserScore(v.Uid, v.Totalscore / 100)
        local userNode = self:getUserNodeByUid(v.Uid)
        if userNode then
            userNode:clearUserAni()
        end
        if v.isChunTian > 0 then
            hasChuntian = true
        end
        -- local cards = self:exchangeCardsValue(v.Cardbuf)
        -- g_mainScene.tableLayer:showOutCardsByViewId(viewId, cards)
    end
    -- if info.otherCardSize and info.otherCardSize > 0 and info.otherCards then
    --     local cards = self:exchangeCardsValue(info.otherCards)
    --     g_mainScene.tableLayer:showOutCardsByViewId(3, cards)
    -- end
    self:clearGameingData()
    if hasChuntian then
        g_mainScene.tableLayer:showChuntianAni(handler(self, self.showSingleResultLayer), info)
    else
        self:showSingleResultLayer(info)
    end
    -- self:showBeginBtnByState(1)
end

function PlayerInfoLayer:getUserNodeByUid( uid)
    local viewId = self:getViewIdByUId(uid)
    if viewId == 1 then
        return self.myUser
    elseif viewId == 2 then
        return self.rightUser
    elseif viewId == 3 then
        return self.leftUser
    end
end

function PlayerInfoLayer:showSingleResultLayer(info)
    local singleLayer = require("pdk.src.view.SingleResultLayer").new(info)
    if singleLayer then
        singleLayer:setName("singleResultLayer")
        singleLayer:setLocalZOrder(20)
        g_mainScene:addChild(singleLayer)
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

function PlayerInfoLayer:showAlertFlagByUId(uid)
    local viewId = self:getViewIdByUId(uid)
    if viewId == 1 then
        self.myUser:setAlertVisible(true)
    elseif viewId == 2 then
        self.rightUser:setAlertVisible(true)
    elseif viewId == 3 then
        self.leftUser:setAlertVisible(true)
    end

    -- 添加报单语音
    -- local info = {nPreOutUserId = uid , Cardtype = CT_PASS}
    -- self:PlayMusic(info)
end

--牌局进行中的重连收的消息
function PlayerInfoLayer:processReloadRoom(info)
    g_mainScene.roomCommonLayer:setRoomNum(info.inviteCode)
    -- 设置牌子上的玩家信息
    self:setPlayerListInfo(info.playerlist)
    if 0 == info.GAME_STATE then 
        for k , v in pairs(info.playerlist) do 
            if v.if_ready ~= 1 and v.uid == USER_INFO["uid"] then
                g_mainScene.playerInfoLayer:showBeginBtnByState(2)
                return
            end
        end
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
        if v.uid == info.OutCardUserId then
            outCardSeatId = v.seat_id
        end
    end
    self:setVisibleAllUserReady(false)
    self:setHandCardsAndOtherCardSize(info.HandCardDatas, rSize, lSize , nil,  true)

    self:showClock(info.OutCardUserId, info.LeftTime)
    if info.OutCardUserId == USER_INFO.uid then
        self:showOutCardBtn()
    end

    --if info.lastOutUserId == info.OutCardUserId then
        self.prevOutCards = info.turnCards--{} -- 保存上次的出牌
        self.prevOutCardType = info.turnCardType--0
    --end
    dump(info.LastCarddata, "info.LastCarddata")
    dump(outCardSeatId, "outCardSeatId")
    local lastSeatId = info.turnCardSeatId--self:findLastOutCardSeatId(info.LastCarddata, outCardSeatId)
    -- if lastSeatId == -1 then
    --     g_mainScene.prevOutCards = {} -- 保存上次的出牌
    --     g_mainScene.prevOutCardType = 0
    -- end
    local viewId = self:getViewIdBySeatId(lastSeatId)
    local turnCards = self:exchangeCardsValue(info.turnCards)
    g_mainScene.tableLayer:showOutCardsByViewId(viewId, turnCards, cardType, true)
    -- for i,v in ipairs(info.LastCarddata) do
    --     if v and v.CardCount > 0 then
            
    --         local cards = self:exchangeCardsValue(v.cards)
    --         local cardType = CardsAnalysis:getType(cards)
    --         if (i-1) == lastSeatId then
    --             g_mainScene.prevOutCards = cards -- 保存上次的出牌
    --             g_mainScene.prevOutCardType = cardType
    --         end
    --         g_mainScene.tableLayer:showOutCardsByViewId(viewId, cards, cardType, true)
    --     end
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
        if viewId == 2 then
            playerInfo.isLeftPlayer = false
        else
            playerInfo.isLeftPlayer = true
        end
        self:setPlayerInfoByViewId(viewId, playerInfo)
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
    local nodeName = {"myUser", "rightUser", "leftUser"}
    for i = 1, MAX_PLAYER_SIZE  do
        if self[nodeName[i]].getUserInfo then
            self[nodeName[i]]:setReadyVisible(b)
        end
    end
    --for i, v in ipairs( nodeName ) do
    --    self[v]:setReadyVisible(b)
    --end
end

function PlayerInfoLayer:getUserHeadInfo(info)
    print("getUserHeadInfo ----------------", debug.traceback())
    dump(info, 'info-------')
    local result = {}
    result.name = info.nickName
    result.score = info.user_gold / 100
    result.icon_url = info.portrait
    result.uid = info.uid
    result.sex = info.sex
    result.seatId = info.seat_id
    result.isReady = info.if_ready > 0
    result.isOnline = info.if_online > 0
    result.isAlert = tonumber(info.if_alert or "0") > 0
    result.ip = info.ip
    result.latitude = info.latitude
    result.longitude = info.longitude
    result.otherInfo = info.otherInfo

    local otherInfo = json.decode(info.otherInfo) or {}
    result.city = otherInfo.city
    if otherInfo.ip then
        result.ip = otherInfo.ip
    end
    if not result.addres or result.addres == "" then
        ReqMgr:getAddress( result.latitude, result.longitude, result.uid)
    end

    return clone(result)
end

function PlayerInfoLayer:processRevcDisbandInfo( info )
    if info.agreeNum == 0 then
        if g_mainScene.roomCommonLayer.disbandLayer == nil then
            local playerLst = self:getUserInfoLstToDisband(info.applyId)
            g_mainScene.roomCommonLayer:processRevcRequestDisband(playerLst, 180)
        end
    else
        if g_mainScene.roomCommonLayer.disbandLayer == nil then
            local playerLst = self:getUserInfoLstToDisband(info.applyId)
            g_mainScene.roomCommonLayer:processRevcRequestDisband(playerLst, 180)
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

function PlayerInfoLayer:processFaceAndTxt(info)
    local user = self:getUserByUserId(info.uid)

    user:showFaceAndTxtByIndex(info.type)
end

function PlayerInfoLayer:onClickBtnTip(sender, event)
    self._onClickTipIdx = (self._onClickTipIdx or 0) + 1
    if #(self._tipCards or {}) == 0 then
        self._tipCards = CardsAnalysis:getSuitCardFromHandlerCards(g_mainScene.prevOutCardType, g_mainScene.prevOutCards)
    end
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
    if type(cards[1]) == "number" then
        cards={
            cards
        }
    end
    for i, v in ipairs( cards or {} ) do
        for j, v2 in pairs( self.handCardPanle:getChildren() or {} ) do
            if v[1] ==  v2.value[1] and v[2] == v2.value[2] then
                if v2.selected ~= 1 then
                    v2:toUp()
                end
                v2.selected = 1
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

    for k, v in ipairs( self.handCardPanle:getChildren() or {} ) do
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

function PlayerInfoLayer:clearHandlerCardsSelect()
    for i, v in ipairs( self.handCardPanle:getChildren() or {} ) do
        if v.selected == 1 then
            v:toDown()
        end
        v.selected = 0
    end
end

function PlayerInfoLayer:onClickBtnOutCard(sender, event)
    local outCards = self:getSelectCards()
    if #outCards > 0 then
        self._onClickTipIdx = 0
        self._tipCards = {}
        local cards = self:exchangeForOutCards(outCards)
        dump(cards,"====玩家出牌====")
        PDKServer:CLI_PLAYER_CARD(#cards, cards)
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
    PDKServer:CLI_READY_GAME(1)
end

function PlayerInfoLayer:onClickBtnCopyRoomnum(sender, event)
    local strNick = require("hall.GameCommon"):formatNick(USER_INFO["nick"], 4)
    local shareInfo = "玩家"..strNick.."邀请你加入跑得快游戏，房间号【"..USER_INFO["invote_code"].."】。"
    require(GameSetting_filePath):copyToClipboard(shareInfo)
end

------------------------------切牌--------------------------------
function PlayerInfoLayer:initQiePaiUI()

    self.qiepai_vw:setVisible(false)
    local cardPath = "pdk/res/image/cards" 
    self.btn_shouzhiPos = self.btn_shouzhi:getPosition()
 
    local size = self.qiepai:getContentSize()
    local startPos = 0

    for i=1,54 do
        local cardImg = cc.Sprite:create(cardPath .. "/card_back.png")
        cardImg:setPosition(cc.p(startPos + i * 20, size.height*0.5))
        cardImg:setAnchorPoint(cc.p(0.5,0.5))
        cardImg:addTo(self.qiepai)
    end

    self.qiepai:onTouch(handler(self, self.onClickHandCard))
    self.btn_shouzhi:onTouch(handler(self, self.onClickShouZhi))
    self.btn_sure:onClick(handler(self, self.onClickQiepaiSure))
end

function PlayerInfoLayer:setQiePaiPanelVisible(flag)
    self.qiepai_vw:setVisible(flag)
end

function PlayerInfoLayer:resetQiePai()
    self.btn_shouzhi:setPosition(self.btn_shouzhiPos)

    local nodes = self.qiepai:getChildren()
    for i,node in ipairs(nodes) do
        local pos = node:getPosition()
        node:setColor(cc.c3b(255,255,255))
    end
end

function PlayerInfoLayer:showQiepai(time)
    self:resetQiePai()
    self.qiepai_vw:setVisible(true)
    self:showClock(USER_INFO["uid"],time)
end

function PlayerInfoLayer:onClickQiepaiSure(event)
    local target = event.target
    if event.name == "ended" then
        PDKServer:CLI_QIEPAI()
        self.qiepai_vw:setVisible(false)
        self:resetQiePai()
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

function PlayerInfoLayer:onExit()
    -- body
end

return PlayerInfoLayer