--
-- Author: Your Name
-- Date: 2017-09-06 19:30:08
--
local   CardPlaneOperator = class("CardPlaneOperator")

local   Card          = require("puchengdazha.Card")
local   unpack = table.unpack or unpack
local   CardAnalysis, CARDTYPE = unpack(require("puchengdazha.CardAnalysis"))

dump(CardAnalysis, "CardAnalysis")
dump(CARDTYPE, "CARDTYPE")
        tbTipsCards = {}

local   cardY = 80
local   jumpCardY = 25
      
local   playerType2CardPlane = {}
local   playerType2Cards = {}

local   bombColor = cc.c3b(180,180,180)
local   chooseColor = cc.c3b(140,140,140)
local   oriColor = cc.c3b(255,255,255)


function CardPlaneOperator:init()

    Mycard_layout = cardScene:getChildByName("my_card_plane")
    Leftcard_layout = cardScene:getChildByName("left_card_plane")
    Rightcard_layout = cardScene:getChildByName("right_card_plane")
    Topcard_layout = cardScene:getChildByName("top_card_plane")
    --local w = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    --
    --local wth = w/2 - Mycard_layout:getContentSize().width/2
    --Mycard_layout:setPositionX(wth)
    --ccui.Helper:doLayout(Mycard_layout)
    self:addTouchEventListenerForCards(Mycard_layout)

    -- self:addCardTouchEvent(Mycard_layout)
    local touchCancellLayer = cardScene:getChildByName("touchCancellLayer")
    touchCancellLayer:setTouchEnabled(true)
    touchCancellLayer:addTouchEventListener(function(sender,event)
        
        -- if event == TOUCH_EVENT_BEGAN then
            dump("点击空白区域重置牌")
            self:resetCards()

            local card_record_plane = cardScene:getChildByName("card_record_plane")
            card_record_plane:setVisible(false)
            local voice_record_plane = cardScene:getChildByName("voice_record_plane")
            voice_record_plane:setVisible(false)
    
            -- require("puchengdazha.gameScene"):showCardsRecordPlane(false)
        -- end  
                 
            require("puchengdazha.operator.ControlPlaneOperator"):chuIfLight()
    end) 

    leftUserData = {}
    rightUserData = {}
    topUserData = {}
    USER_INFO["cards"] = {}

    playerType2CardPlane = {
      [CARD_PLAYERTYPE_MY] = Mycard_layout,
      [CARD_PLAYERTYPE_LEFT] = Leftcard_layout,
      [CARD_PLAYERTYPE_RIGHT] = Rightcard_layout,
      [CARD_PLAYERTYPE_TOP] = Topcard_layout,}

    playerType2Cards = {
      [CARD_PLAYERTYPE_MY] = USER_INFO["cards"],
      [CARD_PLAYERTYPE_LEFT] = leftUserData,
      [CARD_PLAYERTYPE_RIGHT] = rightUserData,
      [CARD_PLAYERTYPE_TOP] = topUserData,}

    local card_record_plane = cardScene:getChildByName("card_record_plane")
    self.card_record_lv = card_record_plane:getChildByName("card_record_lv")
    
    self.single_record_item = card_record_plane:getChildByName("single_record_item")
end

function  CardPlaneOperator:clearGameDatas()
    
    tbTipsCards = {}
    ptTouchBegin = cc.p(0,0)
    BombCardList = {}
    leftUserData = {}
    rightUserData = {}
    topUserData = {}
    USER_INFO["cards"] = {}
    
    for playerType = 1,4 do 
        self:clearUserCards(playerType) 
    end

    self:clearAllOutCards()
    self:clearCardRecord()
    
end

function CardPlaneOperator:getPlayerCardPlane(playerType)
    return playerType2CardPlane[playerType]
end


function CardPlaneOperator:clearCardRecord()
    self.card_record_lv:removeAllChildren()
end

function CardPlaneOperator:updateCardRecord(player,record_info,_type)
    
    local single_record_item = self.single_record_item:clone()
    single_record_item:setVisible(true)
    local player_txt = single_record_item:getChildByName("player_txt")
    local bonus_score = single_record_item:getChildByName("bonus_score")
    bonus_score:setString("")

    if _type ==  1 then   --抢地主

        -- if record_info["behavior"] == 1 then
            player_txt:setString("优先抢地主玩家:  " .. player)
        -- else
        --     player_txt:setString(player .. "     不叫地主")
        -- end 

    elseif _type == 2 then  --不出
        player_txt:setString(player.."            不出")
    elseif _type == 3 then  --出牌
        
        player_txt:setString(player .. " 出牌")
        local card_begin_x = player_txt:getPositionX() + player_txt:getContentSize().width + 40
        local card_y = player_txt:getPositionY()

        for i,card in pairs(record_info["cards"]) do
            local cardNode = Card:getSmallCard(card[1],card[2])
            single_record_item:addChild(cardNode)
            cardNode:setPosition(cc.p(card_begin_x + i*20,card_y))
        end 

    elseif _type == 4 then  --奖励牌型

        player_txt:setString(player .. " 特殊牌奖励")
        local card_begin_x = player_txt:getPositionX() + player_txt:getContentSize().width + 40
        local card_y = player_txt:getPositionY()

        for i,card in pairs(record_info["cards"]) do
            local cardNode = Card:getSmallCard(card[1],card[2])
            single_record_item:addChild(cardNode)
            cardNode:setPosition(cc.p(card_begin_x + i*20,card_y))
        end 

        bonus_score:setString("+" .. record_info["bonus_score"]) 
    end
    
    self.card_record_lv:pushBackCustomItem(single_record_item)

end

function CardPlaneOperator:darkAllBombs(playerType)

    local   InhandCardPlane = self:getPlayerCardPlane(playerType)
    local   cards = playerType2Cards[playerType]

    if  playerType == CARD_PLAYERTYPE_MY then
        cards = USER_INFO["cards"]    
    end

    local bombList = CardAnalysis:getAllBombs(cards)

    for i,cardNode in pairs(InhandCardPlane:getChildren()) do
        if bombList[cardNode._value] ~= nil then
            cardNode:setColor(bombColor)
            cardNode.isBoom = true
        end
    end
    
end

--清空特定玩家的手牌
function CardPlaneOperator:clearUserCards(playerType)
    local InhandCardPlane = self:getPlayerCardPlane(playerType)
    if InhandCardPlane then
        InhandCardPlane:removeAllChildren()
    end
end

function CardPlaneOperator:clearOutCards(playerType)
    
    if  cardScene:getChildByName("outcard_plane"):getChildByName("node"..playerType) then
        cardScene:getChildByName("outcard_plane"):removeChildByName("node"..playerType)
    end
end


function CardPlaneOperator:clearAllOutCards()
    for seat_id =0,PLAYERNUM-1 do
        local playerType = ddzSettings:getPlayerType(seat_id)
        self:clearOutCards(playerType)
    end
end

function CardPlaneOperator:drawUserCards(cards,playerType)
    local   InhandCardPlane = self:getPlayerCardPlane(playerType)
            playerType2Cards[playerType] = {}
    
    InhandCardPlane:setVisible(true)

    self:clearUserCards(playerType)

    if cards == nil  then return end
  
        local c = Card.new()
        for i,v in ipairs(cards) do
            c:init(v)
            table.insert(playerType2Cards[playerType],{c._value,c._kind})
        end

        Card:sortCard(playerType2Cards[playerType])


    local fixBeginX = 0
    if playerType == CARD_PLAYERTYPE_MY then
        fixBeginX = InhandCardPlane:getContentSize().width/ - 200
    end

    local  secondLineIndex = 17
    for i,v in ipairs(playerType2Cards[playerType]) do
        local img = Card:getCard(v[1],v[2], false)
        img:addTo(InhandCardPlane)
        img:setScale(0.5*img:getScale())
        img:setLocalZOrder(i)
        if i <=secondLineIndex then
            img:setPosition(cc.p(fixBeginX + 17 * i,45+0.5*60))
        else
            img:setPosition(cc.p(fixBeginX + 17 *(i-secondLineIndex), 0.5*60))
        end
    end

    self:darkAllBombs(playerType)

end

function CardPlaneOperator:showFarmerBonusCards(flag)
    
    local   outcard_plane = cardScene:getChildByName("outcard_plane")

    for playerType = 1,4 do 
        local   node = outcard_plane:getChildByName("node"..playerType.."bonus")
        if  node then

            if  flag == true then
                node:setVisible(true)
            else
                node:removeFromParent()
            end
        end
    end

end

function CardPlaneOperator:showBonusCards(cards,seat_id,offerx,showType)
    
    -- 奖励牌型字段
    -- local   bonus_type = cc.Label:createWithSystemFont("","Arial",18)
    --         bonus_type:setColor(cc.c3b(125, 125, 125))
    --         bonus_type:setPosition(cc.p(0,0))
    --         outcard_plane:addChild(bonus_type, 999)

    offerx = offerx or 25

    local node = display.newNode()
    
    local   outcard_plane = cardScene:getChildByName("outcard_plane")
    node:addTo(outcard_plane)

    local   playerType = ddzSettings:getPlayerType(seat_id)
    node:setName("node"..playerType)
    node:setVisible(true)

    if  showType == "hide" then
        node:setName("node"..playerType.."bonus")
        node:setVisible(false)
    end
    
    local   secondLineIndex = 10
    local   onelinecount  = #cards
    
    if  onelinecount > secondLineIndex then
        onelinecount = secondLineIndex
    end
    
    local   card_position = {[CARD_PLAYERTYPE_MY] =cc.p(visibleSize/2 - ((onelinecount-1)*offerx)/2,340),
                            [CARD_PLAYERTYPE_LEFT] =cc.p(160,450),
                            [CARD_PLAYERTYPE_RIGHT] =cc.p(1110 - (onelinecount-1)*offerx,450),
                            [CARD_PLAYERTYPE_TOP] =cc.p(visibleSize/2 -((onelinecount-1)*offerx)/2,540),}

    if  #cards == 33 then
        card_position[CARD_PLAYERTYPE_MY] = cc.p(visibleSize/2 - ((onelinecount-1)*offerx)/2 -50,220)
    end

    local   start_x = card_position[playerType].x
    local   yh   = card_position[playerType].y

    dump(offerx,"offerx3")
    for k,v in ipairs(cards) do

        local img = Card:getSmallCard(v[1],v[2])
        img:addTo(node)
        -- img:setPosition(cc.p(start_x+(k-1)*offerx,yh))
        if k <=secondLineIndex then
            img:setPosition(cc.p(start_x + (k-1)*offerx,yh))
        elseif k > secondLineIndex and k <= 2*secondLineIndex then
            img:setPosition(cc.p(start_x + (k-1-secondLineIndex)*offerx,yh-30))
        elseif k > 2*secondLineIndex and k <= 3*secondLineIndex  then
            img:setPosition(cc.p(start_x + (k-1-2*secondLineIndex)*offerx,yh-60))
        elseif k > 3*secondLineIndex and k <= 3*secondLineIndex then
            img:setPosition(cc.p(start_x + (k-1-3*secondLineIndex)*offerx,yh-90))
        end

    end

end

--显示出牌的位置
function CardPlaneOperator:showOutCard(cards,seat_id,offerx,showType)

    offerx = offerx or 35
    local  playerType = ddzSettings:getPlayerType(seat_id)
    local  outcard_plane = cardScene:getChildByName("outcard_plane")
    local node = outcard_plane:getChildByName("node"..playerType)

    if node then
        node:removeFromParent()
    end

    node = display.newNode()
    node:addTo(outcard_plane)
    node:setName("node"..playerType)
    node:setVisible(true)

    if  showType == "hide" then
        node:setName("node"..playerType.."bonus")
        node:setVisible(false)
    end

    local   secondLineIndex = 17
    local   onelinecount  = #cards

    if  onelinecount > secondLineIndex then
        onelinecount = secondLineIndex
    end

    local   card_position = {[CARD_PLAYERTYPE_MY] =cc.p(visibleSize/2 - ((onelinecount-1)*offerx)/2,270),
                            [CARD_PLAYERTYPE_LEFT] =cc.p(220,450),
                            [CARD_PLAYERTYPE_RIGHT] =cc.p(1050 - (onelinecount-1)*offerx,450),
                            [CARD_PLAYERTYPE_TOP] =cc.p(visibleSize/2 -((onelinecount-1)*offerx)/2,540),}

    if  #cards == 33 then
        card_position[CARD_PLAYERTYPE_MY] = cc.p(visibleSize/2 - ((onelinecount-1)*offerx)/2 -50,220)
    end

    local   start_x = card_position[playerType].x
    local   yh   = card_position[playerType].y

    local   show_logo = 0


    for k,v in ipairs(cards) do

        if k == #cards and LandLordSeatIdBang == seat_id then
            show_logo = 1
        end
        local img = Card:getCard(v[1],v[2],show_logo)
        img:addTo(node)
        img:setScale(0.7*img:getScale())
        -- img:setPosition(cc.p(start_x+(k-1)*offerx,yh))
        if k <=secondLineIndex then
            img:setPosition(cc.p(start_x + (k-1)*offerx,yh))
        else
            img:setPosition(cc.p(start_x + (k-1-secondLineIndex)*offerx,yh-45))
        end

    end

end



--设置牌可以触摸
function CardPlaneOperator:setCardTouched(flag)
    for i,cardNode in ipairs(Mycard_layout:getChildren()) do
        if cardNode then
            cardNode:setTouchEnabled(flag)
        end
    end
end

--发牌动画
function CardPlaneOperator:updateSendCard(cards)

    dump(USER_INFO.cards,"用户初始手牌")
    local flagCard = false
    require("hall.GameCommon"):playEffectSound("puchengdazha/audio/Audio_Deal_Card.mp3")
    for k,v in pairs(cards) do
        if v == decidecard then
            flagCard = true
            break
        end
    end
    USER_INFO["cards"] = {}
    local c  = Card.new()
    for i,v in ipairs(cards)  do
        c:init(v)
        table.insert(USER_INFO["cards"], {c._value,c._kind,0,0,0})
    end

    USER_INFO["cards"] = table.unique(USER_INFO["cards"],true)

    Card:sortCard(USER_INFO["cards"])

    local indexSendCard = #USER_INFO.cards
    local startx = 30
    local xCenter = (visibleSize-startx*2)/2

    CardPlaneOperator:clearUserCards(CARD_PLAYERTYPE_MY)

    local dis    = math.floor((visibleSize-startx*2)/indexSendCard)
    if dis > 52 then
        dis = 52
    end
    dump(dis,"dis")
    local show_logo = -1
    startx = startx + xCenter-(indexSendCard-1)*dis/2

    for i = 1, indexSendCard do
        if (i == #USER_INFO.cards and  LandLordSeatId == MY_SEAT_ID ) or (i == #USER_INFO.cards and flagCard) then
            show_logo = 1
        end
        if USER_INFO["uid"] == BankerUid then
            show_logo = 0
        end
        local card_area,x,y =  self:addCard(USER_INFO.cards[i][1],USER_INFO.cards[i][2],startx,flag,i,dis,show_logo)
        -- if card_area == nil then
        --     CardPlaneOperator:clearUserCards(CARD_PLAYERTYPE_MY)
        --     return
        -- end
            card_area.oriPosition = cc.p(x,y)
            card_area.selected = 0
    end

    self:darkAllBombs(CARD_PLAYERTYPE_MY)
end

-- 重新显示牌 状态全部清洗 默认视为玩家手中牌 减少了
function  CardPlaneOperator:setCard(flag)

    local len = #USER_INFO.cards
    self:clearUserCards(CARD_PLAYERTYPE_MY)

    local startx = 30
    local xCenter = (visibleSize - startx*2)/2
    local dis    = math.floor((visibleSize-startx*2)/len)
    if  dis > 52 then
        dis = 52
    end

    startx = startx + xCenter-(len-1)*dis/2
    local show_logo = 0
    for key, value in ipairs(USER_INFO.cards) do
     
        if key == #USER_INFO.cards and LandLordSeatId == MY_SEAT_ID then
            show_logo = 1
        end
        if USER_INFO["uid"] == BankerUid then
            show_logo = 0
        end
        local card_area,x,y =  self:addCard(value[1],value[2],startx,flag,key,dis,show_logo)
        -- if card_area == nil then
        --     self:clearCards()
        --     self:setCard()
        --     return
        -- end

        -- USER_INFO.cards[key][3] = x
        -- USER_INFO.cards[key][4] = y
        -- USER_INFO.cards[key][5] = 0
        if value[3] == 1 then
            card_area.isBaseCard = 1
        else
            card_area.isBaseCard = 0
        end
            
        card_area.selected = 0
        card_area.oriPosition = cc.p(x,y) 
    end 

    self:darkAllBombs(CARD_PLAYERTYPE_MY)

end


function  CardPlaneOperator:addTouchEventListenerForCards(plane)
    
    local nowPlayIndex = -1     
    local selectedCardCount_ex
    local rtSelectCard
    local ptTouchBegin = cc.p(0,0)

    local _card_start_x = 0 
    local _card_start_y = 0 
    local _card_move_type = 0

    local cardTemp

    local   touchCardSoundPath = {}
    for i = 0,6 do 
        touchCardSoundPath[i] = "puchengdazha/audio/card_click_"..i..".wav"
    end

    local function onTouchBegan(touch, event)

        dump(event,"touch_began_event")
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

            require("hall.GameCommon"):playEffectSound("puchengdazha/audio/card_click_0.wav")

            _card_start_x   = cardTemp:getPositionX()  
            _card_start_y   = cardTemp:getPositionY()
            ptTouchBegin.x  = beganPosition.x
            ptTouchBegin.y  = beganPosition.y
            
            -- cardTemp.selected = 1 - cardTemp.selected
            _card_move_type = 0 
            cardTemp:toBlack()

            return true
        end

        return false
    end

    local function onTouchCancell(touch, event)
        _card_start_x   = 0 
        _card_start_y   = 0 
        _card_move_type = 0
        rtSelectCard = nil
    end

    local function onTouchMoved(touch, event)

        local endPosition = touch:getLocation()
        local endX = endPosition.x
        local endY = endPosition.y

         -- (_card_move_type  ==  1 or 
        if  (math.abs(endX - _card_start_x) > 4  and (math.abs(endY - _card_start_y)  / math.abs(endX - _card_start_x) ) < 0.5 ) then

            _card_move_type  = 1
            local startx_t
            local width

            if  endX  > _card_start_x then
                startx_t = _card_start_x
                width = endX - _card_start_x  -- + 20
            else
                startx_t = endX   -- - 20
                width = _card_start_x -  endX
            end

             local startx_t  =    endX < _card_start_x and endX - 20  or _card_start_x
             local width     =    endX - _card_start_x > 0 and endX - _card_start_x + 20 or _card_start_x -  endX
              if startx_t == endX - 20 then
                 width = width + 30
              end

            rtSelectCard      =    cc.rect(startx_t,0,width,320)

            local selectedCardCount = self:touchAreaCard(rtSelectCard)

            if selectedCardCount_ex ~= selectedCardCount then
                nowPlayIndex = nowPlayIndex + 1
                cc.SimpleAudioEngine:getInstance():playEffect(touchCardSoundPath[nowPlayIndex],false)
            end

            selectedCardCount_ex = selectedCardCount

            if  nowPlayIndex == 6 then
                nowPlayIndex = -1
            end

            return

        end

        if math.abs(endX - ptTouchBegin.x) > 5  then
            _card_move_type = 1 --左右选择
            return
        end

        -- if math.abs(endY - _card_start_y) > 5  then
        --    _card_move_type = 2 --上下拖动
        -- end 
    end

    local function onTouchEnded(touch, event)
      
        if _card_move_type == 0 and cardTemp then --点选
              
            local y = cardTemp:getPositionY()

            if  y > cardY then
                cardTemp:setPositionY(y-jumpCardY)
                cardTemp.selected = 0
            else
                cardTemp:setPositionY(y+jumpCardY)
                cardTemp.selected = 1
            end
          
            cardTemp:toWhite()

        elseif  _card_move_type == 1 then --拉选
             
            local tbCards = self:touchSelectCard(rtSelectCard)
             
            --因为touchSelectCard会把第一张卡反选，所以这里要恢复

            -- img:toBlack()  
            -- img.selected = 1 - img.selected    

            if tbCards then
                --拉选后弹出牌
                for i, SelectedCardNode in ipairs(tbCards) do
                    SelectedCardNode.selected = 1 - SelectedCardNode.selected          
                end
            end

            self:setCardOther()
            _card_move_type = 0

        -- elseif _card_move_type == 2 then
        --     self:resetCards()
        end
       
        _card_start_x   = 0 
        _card_start_y   = 0 
        _card_move_type = 0

        rtSelectCard = nil

        require("puchengdazha.operator.ControlPlaneOperator"):chuIfLight()

        -- local locationInNode = cardTemp:convertToNodeSpace(touch:getLocation())
        -- local rect = cc.rect(0, -15, cardTemp:getContentSize().width, cardTemp:getContentSize().height + 15)
        -- if cc.rectContainsPoint(rect, locationInNode) then
        -- end
    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener1:registerScriptHandler(onTouchCancell,cc.Handler.EVENT_TOUCH_CANCELLED )
     
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1:clone(), plane)

end

--牌容器增加牌
function CardPlaneOperator:addCard(value,kind,startx,flag,cout,dis,show_landlord)
      
    -- local   rtSelectCard
    local   isLandlord = show_landlord or 0

    local   tag = value+(kind+100)*20
    local   img = Card:getCard(value,kind,isLandlord)

    if  img == nil then
        return nil, nil, nil
    end

    Mycard_layout:addChild(img)
    
    img.toWhite = function(img) 
        if img.isBoom then 
            img:setColor(bombColor)  
        else
            img:setColor(oriColor)  
        end
    end

    img.toBlack = function(img) 
        img:setColor(chooseColor)  
    end
                -- ddzSettings:playEffectSound("puchengdazha/audio/card_click.mp3")
    img:setTag(tag)
    -- local nowPlayIndex = -1     
    -- local selectedCardCount_ex
     
    -- img:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)  
    -- img:setTouchEnabled(true)
    -- img:setTouchSwallowEnabled(true)
    -- local   ptTouchBegin = cc.p(0,0)
        
    -- if flag ~= 0 then

    -- local  _card_start_x = 0 
    -- local  _card_start_y = 0 
    -- local  _card_move_type = 0

    --     img:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
            
    --         if event.name == "began"  then
    --             require("hall.GameCommon"):playEffectSound("puchengdazha/audio/card_click_0.wav")
    --             dump("touch began")
    --             _card_start_x   = img:getPositionX()
    --             _card_start_y   = img:getPositionY()
    --             ptTouchBegin.x = event.x
    --             ptTouchBegin.y = event.y
    --             _card_move_type = 0 
    --             img:toBlack()
    --             return true
    --         end

    --         if event.name == "ended"  then
    --             dump("touch ended")
    --             if _card_move_type == 0 then --点选
                      
    --                 local y = img:getPositionY()
    --                 if  y > cardY then
    --                     img:setPositionY(y-jumpCardY)
    --                     img.selected = 0
    --                 else
    --                     img:setPositionY(y+jumpCardY)
    --                     img.selected = 1
    --                 end
                  
    --                 img:toWhite()

    --             elseif  _card_move_type == 1 then --拉选
                     
    --                 local tbCards = self:touchSelectCard(rtSelectCard,img)
                     
    --                 --因为touchSelectCard会把第一张卡反选，所以这里要恢复

    --                 -- img:toBlack()  
    --                 -- img.selected = 1 - img.selected    

    --                 if tbCards then
    --                     --拉选后弹出牌
    --                     for i, SelectedCardNode in ipairs(tbCards) do
    --                         SelectedCardNode.selected = 1 - SelectedCardNode.selected          
    --                     end
    --                 end

    --                 self:setCardOther()
    --                 _card_move_type = 0

    --             elseif _card_move_type == 2 then
    --                     -- self:resetCards()
    --             end
               
    --             _card_start_x   = 0 
    --             _card_start_y   = 0 
    --             _card_move_type = 0

    --             require("puchengdazha.operator.ControlPlaneOperator"):chuIfLight()

    --         end

    --         if event.name == "moved" then
    --              --左右拉选                 

    --             if  (_card_move_type  ==  1 or (math.abs(event.x - _card_start_x) > 4  and (math.abs(event.y - _card_start_y)  / math.abs(event.x - _card_start_x) ) < 0.5 )) then
                     
    --                  _card_move_type  = 1
    --                  local startx_t  =    event.x<= _card_start_x and event.x - 20  or _card_start_x
    --                  local width     =    event.x - _card_start_x > 0 and event.x - _card_start_x + 20 or _card_start_x -  event.x
    --                  if startx_t == event.x - 20 then
    --                     width = width + 30
    --                  end

    --                 rtSelectCard      =    cc.rect(startx_t,0,width,320)

    --                 local selectedCardCount = self:touchAreaCard(rtSelectCard)
                    
    --                 if selectedCardCount_ex ~= selectedCardCount then
    --                     nowPlayIndex = nowPlayIndex + 1 
    --                     cc.SimpleAudioEngine:getInstance():playEffect(touchCardSoundPath[nowPlayIndex],false)
    --                 end

    --                 selectedCardCount_ex = selectedCardCount

    --                 if  nowPlayIndex == 6 then
    --                     nowPlayIndex = -1
    --                 end

    --                 return

    --             end
    --             -- end
            
    --             if math.abs(event.x - ptTouchBegin.x) > 5  then
    --                 _card_move_type = 1 --左右选择
    --                 return
    --             end

    --             if math.abs(event.y - _card_start_y) > 5  then
    --                _card_move_type = 2 --上下拖动
    --             end 

    --         end

    --         return

    --     end)
    -- end      

    img:setPosition(cc.p(startx + (cout-1) *dis ,cardY))
    
    local x = startx + (cout-1) *dis
    local y = cardY

    return img,x,y
end

--重置所有牌的状态
function  CardPlaneOperator:resetCards()
    for _,cardNode in ipairs(Mycard_layout:getChildren()) do
        cardNode.selected = 0
        cardNode:setPositionY(cardY)  --cardNode.oriPosition
        cardNode:toWhite()
    end
end

-- 重新显示牌 重新插入 保持选中状态
function  CardPlaneOperator:setCardOther()

    for i,cardNode in ipairs(Mycard_layout:getChildren()) do
        if cardNode then

            local px  = cardNode:getPositionX()
            local py  = cardNode:getPositionY()
               
            if cardNode.selected == 1 then
                if py <= cardY then
                    cardNode:setPosition(px,py+jumpCardY)
                    -- cardNode.oriPosition.y = cardNode:getPositionY()
                end
            else
                if py > cardY then
                    cardNode:setPosition(px,py-jumpCardY)
                    -- cardNode.oriPosition.y = cardNode:getPositionY()
                end
            end
       
            cardNode:toWhite()
        end

    end
end


--触摸区选牌
function CardPlaneOperator:touchSelectCard(rect)
    if rect == nil then
        return
    end
  
    local tbSelectCards = {}
    -- local tmp_table     = {} 
    -- local tmp_value     = {}

    for i,cardNode in ipairs(Mycard_layout:getChildren()) do

        local flag = cc.rectContainsPoint(rect, cardNode.oriPosition)
        if flag  then
            table.insert(tbSelectCards,cardNode)
            -- cardNode:toBlack()
            -- cardNode.selected = 1 - cardNode.selected
        end
    end

    return tbSelectCards


    -- for key, value in pairs(USER_INFO.cards) do
    --     local tag = value[1]+(value[2]+100)*20

    --     flag = cc.rectContainsPoint(rect, cc.p(value[3], value[4]))
    --     if flag then
    --         table.insert(tbSelectCards,tag)
    --         tmp_table[value[1]] = value[2]
    --         table.insert(tmp_value,value[1])
    --     end
    -- end

    -- for i,cardNode in ipairs(Mycard_layout:getChildren()) do

    --     local flag = cc.rectContainsPoint(rect, cardNode.oriPosition)
    --     if flag then
    --         table.insert(tbSelectCards,cardNode)
    --         tmp_table[cardNode._value] = cardNode._kind
    --         table.insert(tmp_value,cardNode)
    --     end

    -- end


    -- local res = {}
    -- -- table.sort(tmp_value)
    -- local res2 = {}


    -- for k,v in pairs(tmp_value) do
    --     if v._value>2  and v._value<15 then   --不等于两个王
    --         if k<#tmp_value and tmp_value[k+1] then
    --             if v._value==tmp_value[k+1]._value then
    --                 if k==1 then

    --                     table.insert(res2,v)
    --                     table.insert(res2,tmp_value[k+1])

    --                 elseif #res2==0 then

    --                     table.insert(res2,v)
    --                     table.insert(res2,tmp_value[k+1])

    --                 elseif v._value-res2[#res2]._value==1 then --v-tmp_value[k-1]==1 then
                        
    --                     table.insert(res2,v)
    --                     table.insert(res2,tmp_value[k+1])

    --                 elseif v._value-tmp_value[k-1]._value>1 and #res2<6 then
    --                     res2 = {}

    --                     table.insert(res2,v)
    --                     table.insert(res2,tmp_value[k+1])
    --                 end                     
    --             end
    --         end
    --     end
    -- end  
   
    -- local t_value = 0  
    -- for key,cardNode in pairs(tmp_value) do  
    --     if cardNode._value >2  and cardNode._value<15 then
    --         if cardNode._value ~= t_value then
    --             if t_value == 0 then
    --                 table.insert(res,cardNode)
    --             else
    --                 if cardNode._value  - t_value  == 1 then
    --                     table.insert(res,cardNode)
    --                 else
    --                     if #res<5 then
    --                         res     = {}
    --                         table.insert(res,cardNode)
    --                     end
    --                 end
    --             end
    --         end
    --     end

    --     t_value = cardNode._value
    -- end 

    -- if #tbSelectCards <5 then
    --     return tbSelectCards
    -- else
    --     local last_res = {}

    --     if #res >=5 then             
    --          for key,cardNode in pairs(res) do  
    --                -- local s_value =  tmp_table[value]._value
    --                -- local tag     =  value+(s_value+100)*20
    --                table.insert(last_res,cardNode)
    --          end

    --          return last_res 

    --     elseif  #res2 >=6 

    --         --这里的序号表示元素位置而非牌的属性

    --         and res2[3]._value-res2[1]._value == 1 
    --         and res2[5]._value-res2[3]._value == 1 then 

    --          for i=1,#res2-1,2 do  

    --             -- for key, value in pairs(USER_INFO.cards) do
    --             local HandCardNodes = Mycard_layout:getChildren()
    --             for i,cardNode in ipairs(HandCardNodes) do

    --                 -- if key>1 and key<#USER_INFO.cards then
    --                 if key>1 and key<#HandCardNodes then

    --                     local cardNode1 = HandCardNodes[key-1]  --USER_INFO.cards[key-1]
    --                     local cardNode2 = HandCardNodes[key+1]  --USER_INFO.cards[key+1]

    --                     if value1 and value2 
    --                     and res2[i]._value == cardNode._value 
    --                     and res2[i]._value == cardNode1._value 
    --                     and res2[i]._value ~= cardNode2._value then
                        
    --                         table.insert(last_res,cardNode)
    --                         table.insert(last_res,cardNode1)                        
    --                     end

    --                 elseif key==#HandCardNodes then

    --                     local cardNode1 = HandCardNodes[key-1]

    --                     if value1 
    --                         and res2[i] == cardNode._value 
    --                         and res2[i] == cardNode1._value  then
                        
    --                         table.insert(last_res,cardNode)
    --                         table.insert(last_res,cardNode1)                        
    --                     end
    --                 end
    --             end
    --          end

    --          return last_res
    --     end
    -- end

    -- return tbSelectCards
end

--触摸区域显示牌
function CardPlaneOperator:touchAreaCard(rect)
    
    local selectedCardCount = 0
    for i,cardNode in ipairs(Mycard_layout:getChildren()) do

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

--打牌减少牌
function CardPlaneOperator:reduceCard(cards)

    for k,v in pairs(cards) do

        for i = #USER_INFO.cards , 1 , -1 do
            if v[1] == USER_INFO.cards[i][1] and v[2] == USER_INFO.cards[i][2] then
                table.remove(USER_INFO.cards,i)
                break
            end
        end
      
        -- for _,cardNode in pairs(Mycard_layout:getChildren()) do
        --     if v[1] == cardNode._value and v[2] == cardNode._kind then
        --         cardNode:removeFromParent()
        --         break
        --     end
        -- end

    end
    
    self:setCard(1)

end

--显示别人出的牌排序 
function  CardPlaneOperator:showOtherCardRank(cards)
    table.sort(cards,function(a,b)
        --if( a[2]  == 4 and b[2] == 4) then
            return a[1]>b[1]
        --end
        --
        --if(a[2] == 4 and b[2] ~= 4) then
        --    return true
        --end
        --
        --if(a[2] ~= 4 and b[2] == 4) then
        --    return false
        --end
        --
        --if(a[2] ~= 4 and b[2] ~= 4) then
        --    if a[1] == b[1] then
        --        return a[2] > b[2]
        --    else
        --        return a[1]>b[1]
        --    end
        --
        --end
    end)

    --local type_t = CardAnalysis:getType(cards)
    --local tmp    = {}
    --if type_t and type_t >=7 and type_t <= 12 then
    --
    --    for k,v in pairs(cards) do
    --        if not tmp[v[1]] then
    --            tmp[v[1]] = {}
    --        end
    --
    --        table.insert(tmp[v[1]],{v[1],v[2]})
    --    end
    --
    --    local all = {}
    --    for k,v in pairs(tmp) do
    --        table.insert(all,v)
    --    end
    --
    --    table.sort(all,function(a,b)
    --        return #a>#b
    --    end)
    --
    --    local result ={}
    --    for k,v in pairs(all) do
    --        for kk,vv in pairs(v) do
    --             table.insert(result,{vv[1],vv[2]})
    --        end
    --
    --    end
    --
    --    return result
    --end
    return cards   
end

--获得要出的牌
function CardPlaneOperator:tobeChuCards()
    local tmp = {}

    for key,cardNode in ipairs(Mycard_layout:getChildren()) do 
        if  cardNode.selected == 1 then
            table.insert(tmp,{cardNode._value,cardNode._kind})
        end
    end

    return tmp
end

--提示然后把牌弹出
function CardPlaneOperator:popCard(cards)
     
    --先重置之前牌的选中状态

    local cardNodes = Mycard_layout:getChildren()

    self:resetCards()
    
    --再根据提示的牌队列弹出牌
    for _,v in pairs(cards) do  
        for key,cardNode in ipairs(cardNodes) do           
    
            if  (v[1] == cardNode._value 
                and v[2] == cardNode._kind)   --对比两张牌，一模一样
                and cardNode.selected == 0 then    --且牌未被选中

                local x                    = cardNode:getPositionX()
                local y                    = cardNode:getPositionY()

                if y <= cardY then
                    cardNode:setPosition(cc.p(x,y+jumpCardY))
                end
                
                cardNode.selected = 1
                break
            end

        end
    end

    require("hall.GameCommon"):playEffectSound("puchengdazha/audio/Audio_Button_Click.mp3")
end

--检查出牌
function CardPlaneOperator:checkPlayCard(flag)

    local cards =  self:tobeChuCards()
    local str   =  Card:dealCardToString(cards)
    local CardType, realMaxCardValue  =  CardAnalysis:getType(cards)  -- 分析滑出的牌
    
    dump(CardType,"CardType")

    if not CardType then
        if flag then
            require("puchengdazha.operator.ControlPlaneOperator"):showErrorTips("kind_error")
        end
        dump("牌型不存在")
        return false
    end

    --检查出的牌是否比上家牌大
    if tbPlayCardInfo and tbPlayCardInfo["last_cards"] then     
        
        --先检查类型
        --相同类型
        if CardAnalysis:belongtoSameType(CardType, tbPlayCardInfo["card_type"])  then
            local lType,max_card,amount  =  CardAnalysis:getType(tbPlayCardInfo["last_cards"])
            --比较最大牌值
            if (#cards == amount) and (realMaxCardValue <= max_card) then
                if flag then
                   require("puchengdazha.operator.ControlPlaneOperator"):showErrorTips("kind_error")
                end
               
                dump("牌值小于")
                return false

            elseif CardAnalysis:belongtoBoomType(CardType) == false and #cards ~= amount then

                if flag then
                   require("puchengdazha.operator.ControlPlaneOperator"):showErrorTips("no_match")
                end
                  
                dump("牌的张数不对")            
                return false

            end

        else--不同牌型
             
            dump(CardType,"牌型")
            dump(CardAnalysis:belongtoBoomType(CardType),"判断是不是炸弹")

            if CardAnalysis:belongtoBoomType(CardType) then--炸弹,火箭,拖车,天王炸弹

            else
                if flag then
                    require("puchengdazha.operator.ControlPlaneOperator"):showErrorTips("kind_error")
                end
                
                dump("不是炸弹")            
                return false
            end

        end
    end

    return true
end

--播放出片的声音&效果
function CardPlaneOperator:playCardsMusic(card_table,type,seat)   

    local ddzSettings = require("puchengdazha.ddzSettings") 
    local layout_effect = cardScene:getChildByName("layout_effect")
    local file
    local _uid = SEAT2USERID[seat]
    local playerType = ddzSettings:getPlayerType(seat)
    local sex = DDZ_USERINFO_TABLE[_uid].sex 
    local main_value = card_table[1][1]
    dump(card_table,"card_table===")
    if type == CARDTYPE.One then--单牌类型

        if card_table[1][2] == 4 then
            main_value = main_value - 15
        end

        if sex == 2 then
            file = "Woman_"..main_value..".mp3"
        else
            file = "Man_"..main_value..".mp3"
        end
        --file = "Woman__Sing.mp3"

    elseif type == CARDTYPE.Two then--对牌类型
        
        if main_value then
            if sex == 2 then
                file = "Woman_dui"..main_value..".mp3"
            else
                file = "Man_dui"..main_value..".mp3"
            end
        end
        --file = "Woman_dui.mp3"
    elseif type == CARDTYPE.Three then--三条类型
        if sex == 2 then
            -- file = "Audio_Card_Three_W.mp3"
            file = "Woman_tuple"..main_value..".mp3"
        else
            -- file = "Audio_Card_Three_M.mp3"
            file = "Man_tuple"..main_value..".mp3"
        end  

    elseif type == CARDTYPE.OneLine then--单连类型

        if sex == 2 then
            file = "Audio_Card_Straight_W.mp3"
        else
            file = "Audio_Card_Straight_W.mp3"
        end
        require("puchengdazha.Animation"):animShun(layout_effect,playerType)

    elseif type == CARDTYPE.TwoLine then--对连类型

        if sex == 2 then
            file = "Audio_Card_DoubleLine_W.mp3"
        else
            file = "Audio_Card_DoubleLine_W.mp3"
        end
        
        require("puchengdazha.Animation"):animDoubleLine(layout_effect)
      
    elseif type == CARDTYPE.Plane or type == CARDTYPE.PlaneTakeOne or type == CARDTYPE.PlaneTakeTwo then--三连类型（飞机）
        if sex == 2 then  
            file = "Audio_Card_Plane_W.mp3"
        else
            file = "Audio_Card_Plane_M.mp3"
        end
        
        require("puchengdazha.Animation"):animPlane(layout_effect)
        
    elseif type == CARDTYPE.ThreeTakeOne  then--三带单    

        if sex == 2 then
            file = "Audio_Card_Three_Take_One_W.mp3"
        else
            file = "Audio_Card_Three_Take_One_M.mp3"
        end

    elseif type == CARDTYPE.ThreeTakeTwo  then--三带对

        if sex == 2 then
            file = "Audio_Card_Three_Take_Double_W.mp3"
        else
            file = "Audio_Card_Three_Take_Double_W.mp3"
        end

    elseif type == CARDTYPE.FourTakeTwo then--四带两单

        if sex == 2 then
            file = "Audio_Card_Four_Take_2_W.mp3"
        else
            file = "Audio_Card_Four_Take_2_M.mp3"
        end

    elseif type == CARDTYPE.FourTakeThree  then--四带两对
        if sex == 2 then
            file = "Audio_Card_Four_Take_2Double_W.mp3"
        else
            file = "Audio_Card_Four_Take_2Double_M.mp3"
        end
    --炸弹类型
    elseif  type == CARDTYPE.Bomb then

        if sex == 2 then
            file = "Audio_Card_Bomb_W.mp3"
        else
            file = "Audio_Card_Bomb_W.mp3"
        end
        --if table.getn(card_table) > 4 or card_table[1][2] == 15 then
            require("puchengdazha.Animation"):animBoom(layout_effect)
        --end

        -- cc.SimpleAudioEngine:getInstance():playEffect("puchengdazha/audio/new/Audio_after_bomb.mp3",false)
        -- bBombMusic = true
    elseif  type == CARDTYPE.Rocket then--火箭类型

        if sex == 2 then
            file = "Audio_Card_Rocket_W.mp3"
        else
            file = "Audio_Card_Rocket_M.mp3"
        end
        require("puchengdazha.Animation"):animRocket(layout_effect)

    elseif  type == CARDTYPE.BombTrailer then--拖车类型
        
        if sex == 2 then
            file = "Audio_Card_Bomb_W.mp3"
        else
            file = "Audio_Card_Bomb_M.mp3"
        end
        require("puchengdazha.Animation"):animBoom(layout_effect)
        -- cc.SimpleAudioEngine:getInstance():playEffect("puchengdazha/audio/new/Audio_after_bomb.mp3",false)
    elseif  type == CARDTYPE.KingBomb then--天王炸弹
        if sex == 2 then
            file = "Audio_Card_Rocket_W.mp3"
        else
            file = "Audio_Card_Rocket_M.mp3"
        end
        require("puchengdazha.Animation"):animRocket(layout_effect)
    end
   
    if  file then
        require("hall.GameCommon"):playEffectSound("puchengdazha/audio/new/"..file,false)
    end

end

-- //扑克类型
-- #define CT_INVALID                  0                               //错误类型
-- #define CT_SINGLE                   1                               //单牌类型
-- #define CT_DOUBLE                   2                               //对牌类型
-- #define CT_THREE                    3                               //三条类型
-- #define CT_ONE_LINE                 4                               //单连类型  
-- #define CT_DOUBLE_LINE              5                               //连对类型
-- #define CT_THREE_LINE               6                               //三连类型（飞机）
-- #define CT_THREE_LINE_TAKE_ONE      7                               //三带单（四人斗地主禁止3带1）
-- #define CT_THREE_LINE_TAKE_DOUBLE   8                               //三带对
-- #define CT_FOUR_LINE_TAKE_ONE       9                               //四带两单（四人斗地主禁止炸弹带其他牌）
-- #define CT_FOUR_LINE_TAKE_DOUBLE    10                              //四带两对（四人斗地主禁止炸弹带其他牌）
-- #define CT_BOMB_CARD                11                              //炸弹类型（四人斗地主里炸弹可以超过4张)
-- #define CT_MISSILE_CARD             12                              //火箭类型
-- #define CT_BOMB_TRAILER_CARD        13                              //四人斗地主：拖车
-- #define CT_FOUR_KING_CARD           14                              //四人斗地主：天王炸弹（4张王）

return CardPlaneOperator