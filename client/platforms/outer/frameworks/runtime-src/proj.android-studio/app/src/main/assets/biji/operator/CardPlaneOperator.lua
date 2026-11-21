local CardPlaneOperator = class("CardPlaneOperator")
local Card = require(TpackageName .. ".PokerCard")
local cardLogic = require(TpackageName .. ".cardLogic")

local CardHandle = require(TpackageName .. ".CardHandle")
--local ControlPlaneOperator = require(TpackageName .. ".operator.ControlPlaneOperator")

local CARD_OPTION_MAP = CARD_OPTION_MAP
local CARD_COLOR_TYPE = CARD_COLOR_TYPE
local SPECIAL_TYPE_TEXT = SPECIAL_TYPE_TEXT
local MyCardScale = 0.55
local MyOutCardScale = MyCardScale
local OtherCardScale = 0.355
local NewOtherCardScale = 0.45
local MyCardY = 20  --手牌的高度
local MyNewOutCardY = 96.87
local NewOtherOutCardY = 96.87
local MyOutCardY = 150  --出牌的高度

local OtherCardY = 0  --手牌的高度
local OtherOutCardY = 0  --其他人出牌的高度

local MyHandCardInterval
local NewMyHandCardInterval
local MyOutCardInterval
local OtherCardInterval
local cardInterval = 109.05
local MyOutCardOffsetY
local actionCount = 0
local SendCardTime = 0.1

local touch_count = 1

-- 1表示左侧对齐， 2表示中间对齐， 3表示右对齐
local PlayersLocationTable  = {}

local Cardtype_Image_Path = {}
local original_pos = {}
local card_panel_position = {}
local card_panel = {}
local card_bg = nil
local localZOrder = 10
local COLOR_WHITE = cc.c3b(0xff,0xff,0xff)
local COLOR_GRAY = cc.c3b(0x99,0x8e,0x8e)
local TEXT_COLOR_WHITE = cc.c4b(255, 255, 255, 255)
local TEXT_COLOR_GRAY = cc.c4b(150, 150, 150, 255)
local TEXT_COLOR_YELLOW = cc.c4b(255, 255, 0, 255)
----------------------------------------------------------------------

function CardPlaneOperator:init(playerType,plane)

    if  TOTAL_PLAYERNUM == 6 then
        OtherCardScale = 0.6 
    elseif  TOTAL_PLAYERNUM == 8 then
        --OtherCardScale = 0.455
        OtherCardScale = 0.7
    else
        OtherCardScale = 0.4
    end

    local resourceNode = SCENENOW["scene"]:getChildByName("cardLayer")

    if resourceNode == nil then
        local resourceFilename = TpackageName .. "/res/layout/cardLayer.csb"
        resourceNode = cc.CSLoader:createNode(resourceFilename):addTo(SCENENOW["scene"])
        resourceNode:setName("cardLayer")
        resourceNode:setZOrder(66)
        resourceNode:setScale(SCREEN_WIDTH/1280,SCREEN_HEIGHT/720)
    end
    
    local label = resourceNode:getChildByName("clock_image"):getChildByName("clock_num")
    label:setString("120")
    resourceNode:setVisible(false)
    --resourceNode:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)

    if resourceNode == nil then
        printError("load csb failed! file name is : ", resourceFilename)
        return
    end

    -- self.btnOpenCheatLayer = resourceNode:getChildByName("btnOpenCheatLayer")
    -- self.btnOpenCheatLayer:setVisible(false)

    self.ui_node = resourceNode
    self.pier_panel = resourceNode:getChildByName("pier_panel")
    self.my_card_plane = resourceNode:getChildByName("card_panel")
    self:setCardHandle(CardHandle.new())
    cardInterval = 109.05
    MyHandCardInterval = 220 *  MyCardScale
    NewMyHandCardInterval = 140 *  OtherCardScale
    MyOutCardInterval =  240 * MyOutCardScale
    OtherCardInterval =  50 * OtherCardScale
    MyOutCardOffsetY = 100 * MyCardScale
 
    -- plane:removeAllChildren()
    -- plane:setVisible(false)
    All_Card_Nodes = {}
    self.userCardData = {}
    actionCount = 0
    self.outcards = {}
    self.preOption = -1
    --操作按钮（对子、同花。。。）
    self.option_btn_tab = {}
    self.option_bg = resourceNode:getChildByName("option_bg")
    if self.option_bg then
        local optionBtn = nil
        for index = 1, CARD_OPTION_MAP.THREESAME do
            optionBtn = self.option_bg:getChildByName("option_btn_"..(index))
            if optionBtn then
                self.option_btn_tab[index] = optionBtn
                optionBtn:setTag(index)
                optionBtn:addTouchEventListener(handler(self, CardPlaneOperator.onOptionTouchEvent))
            end
        end
    end

    self:processBtnOpenCheatLayer()
end

function CardPlaneOperator:processBtnOpenCheatLayer()
    if isOpenControl then
        -- self.btnOpenCheatLayer:setVisible(true)
        -- self.btnOpenCheatLayer:addTouchEventListener(handler(self, self.onClickCheat))
    end
end

function CardPlaneOperator:onClickCheat(sender, event)
    if event == TOUCH_EVENT_ENDED then
        self:showSelectHandCards()
    end
end

function CardPlaneOperator:showSelectHandCards()
    if SCENENOW["scene"]:getChildByName("CheatCardLayer") == nil then
        local cheatLayer = require(TpackageName .. ".view.CheatCardLayer").new(cards)
        cheatLayer:setZOrder(68)
        cheatLayer:setName("CheatCardLayer")
        SCENENOW["scene"]:addChild(cheatLayer)
    end
end

function CardPlaneOperator:setCardHandle(handle)
    self.cardHandle = handle
end

function CardPlaneOperator:clearGameDatas(playerType,plane,stage)
    self.outcards = {}

    plane:stopAllActions()
    plane:removeAllChildren()
    plane:setVisible(false)
    actionCount = 0
end

function CardPlaneOperator:getOutCards()
    return self.outcards[1], self.outcards[2], self.outcards[3]
end

function CardPlaneOperator:swtichCardBackImg(typeIndex)
    CURRENTCARDBACKINDEX = typeIndex
end

--给自己发牌
function CardPlaneOperator:showCards(playerType, plane, cards)
    -- local children = self.my_card_plane:getChildren()
    if #cards ~= 0 then
        self.recordPiersIndex = {}
        if tolua.isnull(self.my_card_plane) then
            return
        end
        self.my_card_plane:removeAllChildren()
        local pier_bg = self.pier_panel:getChildByName("pier_bg")
        local children = pier_bg:getChildren()
        for i,v in ipairs(children) do
            if string.sub(v:getName(), 1, 4) == "card" then
                v:removeFromParent()   
            end
        end
    end
    self.ui_node:setVisible(true)
    --ControlPlaneOperator:showCardCountDown()
    dump(self.ui_node:getPosition(), "显示玩家手牌")
    

    local IntermediatePointX = self.my_card_plane:getContentSize().width/2

    local WorldMiddlePosition = self.my_card_plane:convertToNodeSpace(cc.p(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - 100))
    
    local actionCount = 0
    local cardnum = #cards
    self.userCardData ={}
    for index,value in ipairs(cards) do
        local num = #self.userCardData + 1

        actionCount = actionCount + 1
        local card = Card.new(1)
        card:setScale(OtherCardScale)
        card:addTo(self.my_card_plane)
        card:setPosition(WorldMiddlePosition)
        card:setCard(value.card)
        --        card:flipCard()
              -- card:setFilpEvent(value,All_Card_Nodes[playerType])
              -- table.insert(All_Card_Nodes[playerType],card)
      
        local target_point_x = IntermediatePointX + (index - (cardnum + 1)/2) *MyHandCardInterval
        local target_point_y = MyCardY

        local moveAction = cc.MoveTo:create(0.2,cc.p(target_point_x,target_point_y))
        local scaleAction = cc.ScaleTo:create(0.2,MyCardScale)
        local itemData = {}
        itemData.value, itemData.color = self:getCardLogicValue(value.card)
        local icon = card.font_pai_:getChildByName("big_card_kong")

        local moveAndScaleAction = cc.Spawn:create(moveAction,scaleAction)
        local delay= cc.DelayTime:create(actionCount* SendCardTime)
        local callFuncAc = cc.CallFunc:create(function ()
            card:flipCard()
        end)
        itemData.sprite = card
        itemData.card = value.card
        local se  = cc.Sequence:create(delay,moveAndScaleAction,callFuncAc)
        local icon = card.font_pai_:getChildByName("big_card_kong")
        itemData.icon =icon
        --        icon:setEnabled(true)
        itemData.selected = false
        itemData.pierState = 0

        itemData.pos = icon:getPosition()
        icon:setTag(index)
        icon:addTouchEventListener(handler(self, CardPlaneOperator.onCardTouchEvent))
        self.userCardData[num] = itemData

        card:runAction(se)

    end
    --普通牌型
    self:sortCards()
    self:analyseCards()
    self:checkOptionEnable()
    self:checkSelectedState()
end

function CardPlaneOperator:checkOptionEnable()
    if self.cardHandle then
        local bEnabled = false
        for index = 1, CARD_OPTION_MAP.THREESAME do
            bEnabled = self.cardHandle:callFunc(index)
            self.option_btn_tab[index]:setEnabled(bEnabled)
            -- if bEnabled then
            --     self.option_btn_tab[index]:getChildByName("explain_txt"):setTextColor(TEXT_COLOR_WHITE)
            -- else
            --     self.option_btn_tab[index]:getChildByName("explain_txt"):setTextColor(TEXT_COLOR_GRAY)
            -- end
        end
    end
end
function CardPlaneOperator:outCards(playerType, plane, cards,indexData)
    self.ui_node:setVisible(false)
    local IntermediatePointX = plane:getContentSize().width/2
    local IntermediatePointY = plane:getContentSize().height/1.5
--    local WorldMiddlePosition = plane:convertToNodeSpace(cc.p(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - 100))

    local actionCount = 0
    local cardnum = #cards
    local tempData = {}
    for key,value in pairs(cards) do
        local data = {}
        data.card = value
        data.value, data.color = GamePlaneOperator:getCardLogicValue(value)
        table.insert(tempData,data)
    end
    table.sort(tempData,function (a, b)
        if a.value == b.value then
            return a.color < b.color
        else
            if a.value == 0 then
                return true
            elseif b.value == 0 then
                return false
            end
            return a.value < b.value
        end
    end)
    print("CardPlaneOperator:outCards -------------------------", debug.traceback())
    for index,value in ipairs(tempData) do
        local target_point_x = IntermediatePointX + (index - (cardnum + 1)/2) * NewMyHandCardInterval
        local target_point_y = IntermediatePointY - 70  - (MyNewOutCardY * (indexData -1)) + 80
        if playerType ~= CARD_PLAYERTYPE_MY then
            target_point_y = IntermediatePointY -50 - (NewOtherOutCardY * (indexData -1)) + 80
        end
        dump(target_point_y, "target_point_y")
        actionCount = actionCount + 1
        local card = Card.new(1)
        local seale = OtherCardScale
        card:setScale(seale)
        if playerType ~= CARD_PLAYERTYPE_MY then
            seale = NewOtherCardScale
            card:setScaleY(0.5)
        end

        plane:addChild(card)
        card:setPosition(cc.p(target_point_x,target_point_y))
        card:setCard(value.card)
        card:showFront()
    end
end

--给自己发牌 --没有动画
function CardPlaneOperator:resetShowCards(cards)
    if cards == nil then
        cards = MY_HAND_CARDS
    end
    --dump(MY_HAND_CARDS," MY_HAND_CARDS==--")
    print("showCards ui_node 2 --------------------")
    self.ui_node:setVisible(true)
    self.my_card_plane:removeAllChildren()
    local IntermediatePointX = self.my_card_plane:getContentSize().width/2

    local WorldMiddlePosition = self.my_card_plane:convertToNodeSpace(cc.p(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - 100))

    local actionCount = 0
    local cardnum = #cards

    self.userCardData ={}
    for index,value in ipairs(cards) do
        local itemData = {}
        actionCount = actionCount + 1
        local num = #self.userCardData + 1
        local card = Card.new(1)
        card:setScale(MyCardScale)
        card:addTo(self.my_card_plane)

        -- card:setFilpEvent(value,All_Card_Nodes[playerType])
        -- table.insert(All_Card_Nodes[playerType],card)

        local target_point_x = IntermediatePointX + (index - (cardnum + 1)/2) *MyHandCardInterval
        local target_point_y = MyCardY
        card:setPosition(cc.p(target_point_x,target_point_y))
        card:setCard(value.card)
        card:showFront()
        itemData.card = value.card
        itemData.value, itemData.color = self:getCardLogicValue(value.card)
        local icon = card.font_pai_:getChildByName("big_card_kong")
        itemData.icon =icon
        --        icon:setEnabled(true)
        itemData.selected = false
        itemData.pierState = 0
        itemData.sprite = card
        itemData.pos = icon:getPosition()
        icon:setTag(index)
        icon:addTouchEventListener(handler(self, CardPlaneOperator.onCardTouchEvent))
        self.userCardData[num] = itemData
    end
    --普通牌型
    self:sortCards()
    self:analyseCards()
    self:checkOptionEnable()
    self:checkSelectedState()
end

--分析扑克
function CardPlaneOperator:analyseCards()
    if self.cardHandle then

        local cardDataList = {}
        local data = nil
        for i, k in ipairs(self.userCardData) do
            data = {}
            data.color = k.color
            data.value = k.value
            cardDataList[#cardDataList + 1] = data
        end

        --分析扑克，计算各种组合情况(对子、两对、三条、顺子、同花等)
        self.cardHandle:analyseCardData(cardDataList)
    end
end


function CardPlaneOperator:clearCardPlane()
    self.my_card_plane:removeAllChildren()
   self.pier_panel:getChildByName("pier_bg"):removeAllChildren()
end

function CardPlaneOperator:showEachPiersCards(pierIndex, cards, cardType)

    dump(MY_BEST_CARDS, "CardPlaneOperator_showEachPiersCards")

    local card_pos_tbl = {
        {x = 220, y = 215},
        {x = 330, y = 215},
        {x = 440, y = 215},

        {x = 220, y = 125},
        {x = 330, y = 125},
        {x = 440, y = 125},

        {x = 220, y = 37},
        {x = 330, y = 37},
        {x = 440, y = 37},
    }

    local pier_bg = self.pier_panel:getChildByName("pier_bg")
    local cardsTemp = {}
    for key,value in pairs(cards) do
        local data = {}
        data.card = value
        data.value, data.color = self:getCardLogicValue(value)

        table.insert(cardsTemp,data)
    end
    table.sort(cardsTemp,function (a, b)
        if a.value == b.value then
            return a.color < b.color
        else
            if a.value == 0 then
                return true
            elseif b.value == 0 then
                return false
            end
            return a.value < b.value
        end
    end)
    self.outcards[pierIndex] = cardsTemp

    for i = 1,3 do
        local card_index = (3 * pierIndex - 3 + i)

        local card = Card.new(1)

        card:setScaleX(MyCardScale)
        card:setScaleY(MyCardScale)
        card.card = cardsTemp[i].card
        card:setZOrder(10+card_index)
        card:setName("card"..tostring(10+card_index))
        card:addTo(pier_bg)
        card:setPosition(card_pos_tbl[card_index])
        card:setCard(cardsTemp[i].card)
        card:showFront()
    end

end


function CardPlaneOperator:showThreePiersCards(playerType, plane, cards)
    print("showCards ui_node 3 --------------------")
    self.ui_node:setVisible(true)
    plane = self.my_card_plane

    local IntermediatePointX = plane:getContentSize().width/2

    local WorldMiddlePosition = plane:convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2 - 100))
    
    local actionCount = 0
    local cardnum = #cards

    for index,value in ipairs(cards) do
         
        actionCount = actionCount + 1

        local card = Card.new()
              card:setScale(OtherCardScale)
              card:addTo(plane)
              card:setPosition(WorldMiddlePosition)
              card:setCard(value)
              card:showBack()
              -- card:setFilpEvent(value,All_Card_Nodes[playerType])
              table.insert(All_Card_Nodes[playerType],card)
      
        local target_point_x = IntermediatePointX + (index - (cardnum + 1)/2) *MyHandCardInterval
        local target_point_y = MyCardY

        local moveAction = cc.MoveTo:create(0.2,cc.p(target_point_x,target_point_y))
        local scaleAction = cc.ScaleTo:create(0.2,MyCardScale)

        local moveAndScaleAction = cc.Spawn:create(moveAction,scaleAction)
        local delay= cc.DelayTime:create(actionCount* SendCardTime)
        local se  = cc.Sequence:create(delay,moveAndScaleAction)

              card:runAction(se)

    end

end


function CardPlaneOperator:showCardsBack(plane,callback)

    if SHAICARD then
        plane:setVisible(true)
        plane:setLocalZOrder(999)
        local WorldMiddlePosition = plane:convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))
        local center_point_x =  WorldMiddlePosition.x
        local center_point_y =  WorldMiddlePosition.y
        local card = Card.new(1):addTo(plane,999999)
        card:setCard(SHAICARD)
      --  card:showBack()

        dump(SHAICARD,"showCardsBack")
        card:setScale(OtherCardScale)
        card:setPosition(cc.p(center_point_x,center_point_y))
        card:flipCard()
        card:retain()
        if CHECK_SCHEDULER_GLOBAL then
            SCHEDULER.unscheduleGlobal(CHECK_SCHEDULER_GLOBAL)
        end
        CHECK_SCHEDULER_GLOBAL =SCHEDULER.performWithDelayGlobal(function ()
            callback()
            if tolua.isnull(card) then
                return
            end
            card:removeSelf()

        end, 1)
    end
end



--显示比鸡牌型
function CardPlaneOperator:showCardKind(playerType,plane,cardKind,type,isSound)
    local  bg_img
    local  dian
    if cardKind < 5 then
        bg_img = "small_bg.png"
        dian = "small_dian.png"
    elseif cardKind < 8 then
        bg_img = "middle_bg .png"
        dian = "middle_dian.png"
    else
        dian = "big_dian.png"
        bg_img = "big_bg.png"
    end
    local cardKind_imgPath = Cardtype_Image_Path[cardKind]
    if type >0 then
        cardKind_imgPath = Cardtype_Image_Path[10]
    end
    if isSound == nil then
        SoundUtils:playCardKindEffect(cardKind,USER_INFO["sex"],type)
    end
    local old_niu_tips = plane:getChildByName("BIJI_tip")
    if  old_niu_tips then
        old_niu_tips:removeFromParent()
    end
    local bg = ccui.ImageView:create(cardKind_imgPath.b)
    local dian_bg = ccui.ImageView:create(cardKind_imgPath.d)
    dian_bg:setPosition(cc.p(128.76,75.06))
    dian_bg:addTo(bg,999)
    local number = ccui.ImageView:create(cardKind_imgPath.n)
    number:setPosition(cc.p(74.83,70.96))
    number:addTo(bg,999)

    bg:addTo(plane,999)
    bg:setPosition(cc.p(64.05,67.62))
    local action1 = cc.FadeIn:create(0.2)
    local actionBy = cc.ScaleBy:create(0.2, 1.0, 1.0)
    local actionBy2 = cc.ScaleBy:create(0.2, 1.3, 1.3)
    local sq = cc.Sequence:create( action1, actionBy2,actionBy);
    bg:runAction(sq)

end


function CardPlaneOperator:foldCard(playerType,plane,cards)

    if  playerType ~= CARD_PLAYERTYPE_MY then

        for key,value in pairs(cards) do

            if All_Card_Nodes[playerType][key] then

                local cardNode = All_Card_Nodes[playerType][key]

                if cardNode.setCard and cardNode.isBack_ then    --setCard方法存在且牌为背面
                    cardNode:setCard(value)
                    cardNode:showBack()
                end

            end
        end

    else   
     
        local planeWidth = plane:getContentSize().width   
        local target_point_y = MyOutCardY 

        for i,cardNode in ipairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
            local target_point_x = planeWidth/2 - (3 - i) * MyOutCardInterval
            local value = cards[i]
            cardNode:setScale(MyOutCardScale)
            cardNode:setCard(value)
            cardNode:setTouchEnabled(false)
            cardNode:stopAllActions()
            cardNode:showFront()
            -- cardNode:setPosition(cc.p(target_point_x,target_point_y))
        end

    end
end


function CardPlaneOperator:outCard(playerType,plane,value)
    local cardNode = All_Card_Nodes[playerType]
    if cardNode then    --setCard方法存在且牌为背面
        cardNode:setCard(value)
        cardNode:flipCard()
    end

end

function CardPlaneOperator:turnCards(plane)
    for _,cardNode in ipairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
        if  cardNode:isBack() then
            cardNode:flipCard()
        end
    end
end


function CardPlaneOperator:setCardType()
    local count = #MY_BEST_CARDS
    dump(MY_BEST_CARDS,"#MY_BEST_CARDS")
    ---选择推荐牌型
    -- for i = 1 ,count do
    --     local group = "group_"..i
    --     self[group] =   self.ui_node:getChildByName(group)
    --     local text = self[group]:getChildByName("text")
    --     text:setString("")
    --     local str =""
    --     for j = 1,count do

    --         if j == 1 then
    --             str = CARD_TYPE_TABLE[MY_BEST_CARDS[i][j].son_card_type]
    --         else
    --             str =  CARD_TYPE_TABLE[MY_BEST_CARDS[i][j].son_card_type] .."+".. str
    --         end
    --         dump(str,"#MY_BEST_CARDS")
    --     end
    --     text:setString(str)
    -- end
end

function CardPlaneOperator:showTipsText(str)
   local tips_text = self.ui_node:getChildByName("tips_text")
    if tips_text then
        tips_text:setString(str)
    end

end

function CardPlaneOperator:getCardLogicValue(card_value)
    local value = bit.band(card_value, 0x0F)
    print("value111",value)
    if value == 1 then
        value = 14
    end
    local color =  bit.band(card_value, 0xF0)
    if color == 0x00 then
        color = 1
    elseif color == 0x10 then
        color = 2
    elseif color == 0x20 then
        color = 3
    elseif color == 0x30 then
        color = 4
    elseif color == 0x40 then
        color = 5
    elseif color == 0x50 then
        color = 6
    end

    return value, color
end

--按照牌值大小排序
function CardPlaneOperator:sortCards()
    if self.userCardData then
        table.sort(self.userCardData, function (a, b)
            if a.value == b.value then
                return a.color < b.color
            else
                if a.value == 0 then
                    return true
                elseif b.value == 0 then
                    return false
                end
                return a.value < b.value
            end
        end)
    else
        print("sort cards error!")
    end
end
--点击卡牌事件
function CardPlaneOperator:onCardTouchEvent(sender, event)
    print("onCardTouchEvent sender name:"..sender:getName()..", event:"..event)
    if event == TOUCH_EVENT_BEGAN then
        local touch = sender:getTouchBeganPosition()
        self:onTouchBegan(sender, touch.x, touch.y)
    elseif event == TOUCH_EVENT_ENDED then
        local touch = sender:getTouchEndPosition()
        self:onTouchEnd(sender, touch.x, touch.y)
    elseif event == TOUCH_EVENT_MOVED then
        local touch = sender:getTouchMovePosition()
        self:onTouchMove(sender, touch.x, touch.y)
    else
        --取消拖动后，判断是否选中了扑克
--        if self.moveData and self.moveData.startIndex>0 and self.moveData.moveIndex>0 then
--            local startIndex = MIN(self.moveData.startIndex, self.moveData.moveIndex)
--            local endIndex = MAX(self.moveData.startIndex, self.moveData.moveIndex)
--            for i, k in ipairs(self.userCardData) do
--                if i >= startIndex and i <= endIndex then
--                    if k and k.sprite then
--                        k.selected = not k.selected
--                        if k.selected == true then
--                            k.sprite:setPositionY(k.pos.y + 20)
--                        else
--                            k.sprite:setPositionY(k.pos.y)
--                        end
--                    end
--                end
--                k.sprite:setColor(COLOR_WHITE)
--            end
--
--            self:checkSelectedState()
--        else
--            for i, k in ipairs(self.userCardData) do
--                k.sprite:setColor(COLOR_WHITE)
--            end
--        end
--        self.moveData = nil
    end

end

--重置点击事件
function CardPlaneOperator:resetOptionBtn()
    local bEnabled = false
    for index = 1, CARD_OPTION_MAP.THREESAME do
        self.option_btn_tab[index]:setEnabled(bEnabled)
        -- if bEnabled then
        --     self.option_btn_tab[index]:getChildByName("explain_txt"):setTextColor(TEXT_COLOR_WHITE)
        -- else
        --     self.option_btn_tab[index]:getChildByName("explain_txt"):setTextColor(TEXT_COLOR_GRAY)
        -- end
    end

end

--处理选择卡牌
function CardPlaneOperator:checkSelectedState()
    self.selectingCard = {}

    local leftCard = {}
    for i, k in ipairs(self.userCardData) do
        if k.selected == true then
            table.insert(self.selectingCard, i)
        else
            table.insert(leftCard, {color = k.color, value = k.value})
        end
    end

    --选中部分扑克后，剩余扑克判断能否再组合成牌型
    if #leftCard > 0 then
        if #leftCard < #(self.userCardData) then
            local info = self.cardHandle:analyseCardData(leftCard, true)
            if info then
                local result = {info.bOnePair, info.bStraight, info.bFlush, info.bStraightFlush,info.bThreeSame}

                for index = 1, CARD_OPTION_MAP.THREESAME do
                    if result[index] == true then
                        --self.option_btn_tab[index]:getChildByName("explain_txt"):setTextColor(TEXT_COLOR_WHITE)
                    else
                        --self.option_btn_tab[index]:getChildByName("explain_txt"):setTextColor(TEXT_COLOR_GRAY)

                        if self.preOption == index then
                            local bEnabled, num = self.cardHandle:callFunc(index)
                            if num > 1 then
                                --self.option_btn_tab[index]:getChildByName("explain_txt"):setTextColor(TEXT_COLOR_WHITE)
                            end
                        end
                    end
                end
            end
        else
            self:checkOptionEnable()
        end
    else

    end
end

function CardPlaneOperator:onTouchBegan(sender, touchX, touchY)
    local cardIndex = sender:getTag()
    print("onTouchBegan cardIndex:"..cardIndex..", touchX:"..touchX..", touchY:"..touchY)
    self.moveData = {}
    self.moveData.startIndex = 0
    self.moveData.moveIndex = 0
    if cardIndex > 0 then
        self.moveData.startIndex = cardIndex
        self.moveData.startPos = {x=touchX, y=touchY}
        self.moveData.contentSize = sender:getContentSize()
        self.moveData.movePos = {x=0, y=0}
    end
end

function CardPlaneOperator:onTouchMove(sender, touchX, touchY)
    local cardIndex = sender:getTag()
    --print("onTouchMove cardIndex:"..cardIndex..", touchX:"..touchX..", touchY:"..touchY)
--    if self.moveData and self.moveData.startIndex > 0 then
--        self.moveData.moveIndex = 0
--
--        local offsetX = touchX - self.moveData.startPos.x --计算拖动偏移
--        local offsetY = touchY - self.moveData.startPos.y --计算拖动偏移
--        if ABS(offsetX) >= 5 or ABS(offsetY) >= 5 then
--            --处理拖动选中卡牌
--            local moveIndex = self:isCardContainsPoint(touchX, touchY)
--            if moveIndex > 0 then
--                --print("selected index:", self.moveData.startIndex, moveIndex)
--                local startIndex = MIN(self.moveData.startIndex, moveIndex)
--                local endIndex = MAX(self.moveData.startIndex, moveIndex)
--                for i, k in ipairs(self.userCardData) do
--                    if i >= startIndex and i <= endIndex then
--                        k.sprite:setColor(COLOR_GRAY)
--                    else
--                        k.sprite:setColor(COLOR_WHITE)
--                    end
--                end
--            else
--                for i, k in ipairs(self.userCardData) do
--                    k.sprite:setColor(COLOR_WHITE)
--                end
--            end
--
--            self.moveData.moveIndex = moveIndex
--        end
--    end
end

function CardPlaneOperator:onTouchEnd(sender, touchX, touchY)
    local cardIndex = sender:getTag()
    if cardIndex > 0 then
        print("onTouchEnd cardIndex:",cardIndex)
        local itemData = self.userCardData[cardIndex]
        if itemData and itemData.icon then
            dump(itemData.selected, "itemData.selected")
--            itemData.selected = not itemData.selected
            if itemData.selected == false then
--                itemData.selected = false
                self.userCardData[cardIndex].selected = true
                itemData.icon:setPositionY(itemData.pos.y + 40)
            else
                self.userCardData[cardIndex].selected = false
                dump(itemData.pos.y, "itemData.pos.y")
                itemData.icon:setPositionY(itemData.pos.y)
            end

--                self:checkSelectedState()
        end
    end

    for i, k in ipairs(self.userCardData) do
        k.icon:setColor(COLOR_WHITE)
    end

end
function CardPlaneOperator:checkCrch(index)
    local cards = {}
    for i, k in ipairs(self.userCardData) do
        if k.selected then
            table.insert(cards, k.card)
        end
    end
    
    if #cards ~= 3 then
        self:showTipsText("选择的牌不能是".. #cards .."张");
        return false
    end

    if self:isHasCardsForCurPier(index) then return end
--    for i =1, #MY_HAND_CARDS_TEMP do
--        for j = 1,#cards do
--            if cards[j] == MY_HAND_CARDS_TEMP[i].card  then
--                table.remove(MY_HAND_CARDS_TEMP,i)
--                break
--            end
--
--        end
--    end
    self:showEachPiersCards(index, cards, 1)
    self:removebyvalue(MY_HAND_CARDS_TEMP,cards[1],false)
    self:removebyvalue(MY_HAND_CARDS_TEMP,cards[2],false)
    self:removebyvalue(MY_HAND_CARDS_TEMP,cards[3],false)
    dump(#MY_HAND_CARDS_TEMP, "#MY_HAND_CARDS_TEMP")

    if #MY_HAND_CARDS_TEMP >0 then
        self:resetShowCards(MY_HAND_CARDS_TEMP)
    else
        self:resetOptionBtn()
        self.my_card_plane:removeAllChildren()
    end

    -- 添加手动配牌最后一道自动配上
    self:forAutoLastPiers(index)
    return true
end

function CardPlaneOperator:getLastPier(t)
    if #t ~= 2 then return 0 end

    local count = 0
    for i,v in ipairs(t) do
        count = count + v
    end

    if count == 3 then 
        return 3 
    elseif count == 4 then
        return 2
    elseif count == 5 then
        return 1
    else
        return 0
    end

end

function CardPlaneOperator:isHasCardsForCurPier(pier)
    for i,v in ipairs(self.recordPiersIndex) do
        if v == pier then
            return true
        end
    end

    return false
end

-- @param index 点击道数的index
function CardPlaneOperator:forAutoLastPiers(index)
    if index >= 1 and index <= 3 then
        local bHas = self:isHasCardsForCurPier(index)

        if not bHas then
            table.insert(self.recordPiersIndex, index)
        end
    end
    if #self.recordPiersIndex == 2 then
        local lastIndex = self:getLastPier(self.recordPiersIndex)
        if lastIndex == 0 then return end

        for i,v in ipairs(self.userCardData) do
            v.selected = true
        end
        self:checkCrch(lastIndex)
    end
end

--    table中删除指定元素(非根据索引)
--    @param    array 要操作的容器
--    @param     value 删除value值
--     @param    removeadll 是否删除所有相同的值
--    @return 返回删除值的个数
function CardPlaneOperator:removebyvalue(array, value, removeadll)
    --    deleteNum用于接收/返回删除个数; i/max 构成控制while循环
    local deleteNum,i,max=0,1,#array
    while i<=max do
        if array[i].card == value then
            --    通过索引操作表的删除元素
            table.remove(array,i)
            --    标记删除次数
            deleteNum = deleteNum+1
            i = i-1
            --    控制while循环操作
            max = max-1
            --    判断是否删除所有相同的value值
            if not removeadll then break end
        end
        i= i+1
    end
    --    返回删除次数
    return deleteNum
end

function CardPlaneOperator:sortFunction(a,b)
    if a.value == b.value then
        return a.color < b.color
    else
        if a.value == 0 then
            return true
        elseif b.value == 0 then
            return false
        end
        return a.value < b.value
    end
end

function CardPlaneOperator:clearOutCard(index)
    local pier_bg = self.pier_panel:getChildByName("pier_bg")
    local tableTemp = {}
    if self.outcards[index] then
        for k,v in pairs(pier_bg:getChildren()) do
            if  #self.outcards[index] >0 then
                for _,vo in pairs(self.outcards[index]) do
                    if tolua.isnull(v) ==false then

                        if v.card == vo.card then
                            dump(vo, "====vo")
                            table.insert(MY_HAND_CARDS_TEMP, vo)
                            v:removeSelf()
                            break
                        end
                    end
                end
            end
        end
        if #MY_HAND_CARDS_TEMP >0 then
            table.sort(MY_HAND_CARDS_TEMP, function (a, b)
                if a.value == b.value then
                    return a.color < b.color
                else
                    if a.value == 0 then
                        return true
                    elseif b.value == 0 then
                        return false
                    end
                    return a.value < b.value
                end
            end)
            self:resetShowCards(MY_HAND_CARDS_TEMP)
        end

        for i,v in ipairs(self.recordPiersIndex) do
            if v == index then
                table.remove(self.recordPiersIndex, i)
                break
            end
        end

        self.outcards[index] = {}
    end
end
function CardPlaneOperator:claerHandCardPlane(plane)
    plane:removeAllChildren()
end
function CardPlaneOperator:claerAllPlane()
    MY_HAND_CARDS_TEMP = {}
    self.outcards[1] = {}
    self.outcards[2] = {}
    self.outcards[3] = {}
    local pier_bg = self.pier_panel:getChildByName("pier_bg")
    pier_bg:removeAllChildren()
    self.my_card_plane:removeAllChildren()
    self.ui_node:setVisible(false)
end

function CardPlaneOperator:showActionChips(plaeryType,plane,chip,index)
    local ttfConfig = {}
    ttfConfig.fontFilePath = TpackageName .."/res/fonts/fzcs.ttf"
    ttfConfig.fontSize = 68
    local chips_text = cc.Label:createWithTTF(ttfConfig, chip)
    if chip > 0 then
        chips_text = cc.Label:createWithTTF(ttfConfig, "+"..chip)

    end
    local winColor = cc.c3b(0xFF,0x00,0x00)
    local loseColor =  cc.c3b(0xFF,0xFF,0x00)
    local x = plane:getContentSize().width/2
    if plaeryType == CARD_PLAYERTYPE_MY then
        chips_text:setAnchorPoint(cc.p(0,0.5))
        x = x + plane:getContentSize().width/1.7
    elseif plaeryType == CARD_PLAYERTYPE_2 then
        chips_text:setAnchorPoint(cc.p(1,0.5))
        x = x - plane:getContentSize().width/1.5
    elseif plaeryType == CARD_PLAYERTYPE_3 then
        chips_text:setAnchorPoint(cc.p(1,0.5))
        x = x - plane:getContentSize().width/1.5
    elseif plaeryType == CARD_PLAYERTYPE_4 then
        chips_text:setAnchorPoint(cc.p(0,0.5))
        x = x + plane:getContentSize().width/1.2
    elseif plaeryType == CARD_PLAYERTYPE_5 then
        chips_text:setAnchorPoint(cc.p(0,0.5))
        x = x + plane:getContentSize().width/1.2
    elseif plaeryType == CARD_PLAYERTYPE_6 then
        chips_text:setAnchorPoint(cc.p(0,0.5))
        x = x + plane:getContentSize().width/1.2
    end
    plane:addChild(chips_text,9999)
    if chip >0 then
        chips_text:setTextColor(winColor)
    else
        chips_text:setTextColor(loseColor)
    end



    local y = 284.99 - (index -1) * 100
    if plaeryType == CARD_PLAYERTYPE_MY then
        y = 324.99 - (index -1) * 120
    end
    chips_text:setAnchorPoint(cc.p(1,0.5))
    chips_text:setPosition(cc.p(x, y))
end
function CardPlaneOperator:showActionTypeCard(plaeryType,plane,data,index)
    local ttfConfig = {}
    local countType = 1
--    if data.qinglianshun >0 then
--        ttfConfig.fontFilePath = TpackageName .."/res/fonts/fzcs.ttf"
--        ttfConfig.fontSize = 48
--        local chips_text = cc.Label:createWithTTF(ttfConfig, "清连顺+"..data.qinglianshun)
--        local winColor = cc.c3b(0xFF,0x00,0x00)
--        chips_text:setPosition( cc.p(plane:getContentSize().width/2,chips_text:getContentSize().height *
--                (countType - 1) + chips_text:getContentSize().height  / 2))
--        countType = countType + 1
--        chips_text:setTextColor(winColor)
--        plane:addChild(chips_text,9999)
--    end
--    if data.sanshunqing >0 then
--        ttfConfig.fontFilePath = TpackageName .."/res/fonts/fzcs.ttf"
--        ttfConfig.fontSize = 48
--        local chips_text = cc.Label:createWithTTF(ttfConfig, "三顺清+"..data.sanshunqing)
--        local winColor = cc.c3b(0xFF,0x00,0x00)
--        chips_text:setPosition( cc.p(plane:getContentSize().width/2,chips_text:getContentSize().height *
--                (countType - 1) + chips_text:getContentSize().height  / 2))
--        countType = countType + 1
--        chips_text:setTextColor(winColor)
--        plane:addChild(chips_text,9999)
--    end
        if data.sanqin >0 then
            ttfConfig.fontFilePath = TpackageName .."/res/fonts/fzcs.ttf"
            ttfConfig.fontSize = 48
            local chips_text = cc.Label:createWithTTF(ttfConfig, "三清+"..data.sanqin)
            local winColor = cc.c3b(41,66,144)
            chips_text:setPosition( cc.p(plane:getContentSize().width/2,chips_text:getContentSize().height *
                    (countType - 1) + chips_text:getContentSize().height  / 2))
            countType = countType + 1
            chips_text:setTextColor(winColor)
            plane:addChild(chips_text,9999)
        end
    if data.quanhei >0 then
        ttfConfig.fontFilePath = TpackageName .."/res/fonts/fzcs.ttf"
        ttfConfig.fontSize = 68
        local chips_text = cc.Label:createWithTTF(ttfConfig, "全黑+"..data.quanhei)
        local winColor = cc.c3b(41,66,144)
        chips_text:setPosition( cc.p(plane:getContentSize().width/2,chips_text:getContentSize().height *
                (countType - 1) + chips_text:getContentSize().height  / 2))
        countType = countType + 1
        chips_text:setTextColor(winColor)
        plane:addChild(chips_text,9999)
    end
    if data.quanhong >0 then
        ttfConfig.fontFilePath = TpackageName .."/res/fonts/fzcs.ttf"
        ttfConfig.fontSize = 48
        local chips_text = cc.Label:createWithTTF(ttfConfig, "全红+"..data.quanhong)
        local winColor = cc.c3b(41,66,144)
        chips_text:setPosition( cc.p(plane:getContentSize().width/2,chips_text:getContentSize().height *
                (countType - 1) + chips_text:getContentSize().height  / 2))
        countType = countType + 1
        chips_text:setTextColor(winColor)
        plane:addChild(chips_text,9999)
    end
    if data.sanshunzi >0 then
        ttfConfig.fontFilePath = TpackageName .."/res/fonts/fzcs.ttf"
        ttfConfig.fontSize = 48
        local chips_text = cc.Label:createWithTTF(ttfConfig, "三顺子+"..data.sanshunzi)
        local winColor = cc.c3b(41,66,144)
        chips_text:setPosition( cc.p(plane:getContentSize().width/2,chips_text:getContentSize().height *
                (countType - 1) + chips_text:getContentSize().height  / 2))
        countType = countType + 1
        chips_text:setTextColor(winColor)
        plane:addChild(chips_text,9999)
    end
    if data.lianshun >0 then
        ttfConfig.fontFilePath = TpackageName .."/res/fonts/fzcs.ttf"
        ttfConfig.fontSize = 48
        local chips_text = cc.Label:createWithTTF(ttfConfig, "连顺+"..data.lianshun)
        local winColor = cc.c3b(41,66,144)
        chips_text:setPosition( cc.p(plane:getContentSize().width/2,chips_text:getContentSize().height *
                (countType - 1) + chips_text:getContentSize().height  / 2))
        countType = countType + 1
        chips_text:setTextColor(winColor)
        plane:addChild(chips_text,9999)
    end
    if data.sitou >0 then
        ttfConfig.fontFilePath = TpackageName .."/res/fonts/fzcs.ttf"
        ttfConfig.fontSize = 48
        local chips_text = cc.Label:createWithTTF(ttfConfig, "四个头+"..data.sitou)
        local winColor = cc.c3b(41,66,144)
        chips_text:setPosition( cc.p(plane:getContentSize().width/2,chips_text:getContentSize().height *
                (countType - 1) + chips_text:getContentSize().height  / 2))
        countType = countType + 1
        chips_text:setTextColor(winColor)
        plane:addChild(chips_text,9999)
    end

    if data.shuangshunqing >0 then
        ttfConfig.fontFilePath = TpackageName .."/res/fonts/fzcs.ttf"
        ttfConfig.fontSize = 48
        local chips_text = cc.Label:createWithTTF(ttfConfig, "双顺清+"..data.shuangshunqing)
        local winColor = cc.c3b(41,66,144)
        chips_text:setPosition( cc.p(plane:getContentSize().width/2,chips_text:getContentSize().height *
                (countType - 1) + chips_text:getContentSize().height  / 2))
        countType = countType + 1
        chips_text:setTextColor(winColor)
        plane:addChild(chips_text,9999)
    end
    if data.shuangsantiao >0 then
        ttfConfig.fontFilePath = TpackageName .."/res/fonts/fzcs.ttf"
        ttfConfig.fontSize = 48
        local chips_text = cc.Label:createWithTTF(ttfConfig, "双三条+"..data.shuangsantiao)
        local winColor = cc.c3b(41,66,144)
        chips_text:setPosition( cc.p(plane:getContentSize().width/2,chips_text:getContentSize().height *
                (countType - 1) + chips_text:getContentSize().height  / 2))
        countType = countType + 1
        chips_text:setTextColor(winColor)
        plane:addChild(chips_text,9999)
    end
    if data.quansantiao >0 then
        ttfConfig.fontFilePath = TpackageName .."/res/fonts/fzcs.ttf"
        ttfConfig.fontSize = 48
        local chips_text = cc.Label:createWithTTF(ttfConfig, "全三条+"..data.quansantiao)
        local winColor = cc.c3b(41,66,144)
        chips_text:setPosition( cc.p(plane:getContentSize().width/2,chips_text:getContentSize().height *
                (countType - 1) + chips_text:getContentSize().height  / 2))
        countType = countType + 1
        chips_text:setTextColor(winColor)
        plane:addChild(chips_text,9999)
    end
    if data.guding >0 then
        ttfConfig.fontFilePath = TpackageName .."/res/fonts/fzcs.ttf"
        ttfConfig.fontSize = 48
        local chips_text = cc.Label:createWithTTF(ttfConfig, "固定分+"..data.guding)
        local winColor = cc.c3b(41,66,144)
        chips_text:setPosition( cc.p(plane:getContentSize().width/2,chips_text:getContentSize().height *
                (countType - 1) + chips_text:getContentSize().height  / 2))
        countType = countType + 1
        chips_text:setTextColor(winColor)
        plane:addChild(chips_text,9999)
    end
    if data.clearanceScore >0 then
        ttfConfig.fontFilePath = TpackageName .."/res/fonts/fzcs.ttf"
        ttfConfig.fontSize = 48
        local chips_text = cc.Label:createWithTTF(ttfConfig, "通关+"..data.clearanceScore)
        local winColor = cc.c3b(41,66,144)
        chips_text:setPosition( cc.p(plane:getContentSize().width/2,chips_text:getContentSize().height *
                (countType - 1) + chips_text:getContentSize().height  / 2))
        countType = countType + 1
        chips_text:setTextColor(winColor)
        plane:addChild(chips_text,9999)
    end
--    chips_text:setAnchorPoint(cc.p(1,0.5))
end

--点击选项(对子、两对......)
function CardPlaneOperator:onOptionTouchEvent(sender, event)
    --print("touch btn name:"..sender:getName())
    if self.isTimeOut == true then
        return
    end

    if event == TOUCH_EVENT_BEGAN then
        sender:setScale(0.8)
    elseif event == TOUCH_EVENT_ENDED then
        local tag = sender:getTag()
        if tag > 0 and self.cardHandle then
            self:clearSelectedState()
            print("preOption:"..self.preOption..", tag:"..tag)
            --点击对应组合选项，连续点击相同按钮，则选择同类型不同组合
            if self.preOption == -1 or self.preOption == tag then
                local result = self.cardHandle:getResultFunc(tag)
                local num = #result
                if num > 0 then
                    local item = nil
                    for i=1, num do
                        item = self.userCardData[result[i]]
                        if item and item.icon then
                            item.selected = true
                            item.icon:setPositionY(item.pos.y + 40)
                        end
                    end
                    self.preOption = tag
                else
                    self.preOption = -1
                end
                --dump(result, "selected result card")
            else
                self.cardHandle:clearSelectedState()
                self.preOption = -1
            end

            self:checkSelectedState()
        end

--        Utils:playEffectSound("button_click")

        sender:setScale(1.0)
    else
        sender:setScale(1.0)
    end
end

--清除选中状态
function CardPlaneOperator:clearSelectedState()
    local itemData = nil
    for i, k in ipairs(self.userCardData) do
        if k and k.icon then
--            icon:setPositionY(itemData.pos.y)
            k.selected = false
            k.icon:setPosition(k.pos)
        end
    end
    self.selectingCard = {}
end

function comp(a, b)
    if a.color == b.color then
        return a.value < b.value
    else
        return a.color > b.color
    end
end

function CardPlaneOperator:sortByMode( mode )
    if mode > 0 then
        self:sortCards()
    else
        table.sort(self.userCardData, comp)
    end
end

function CardPlaneOperator:getCardByCardData( data )
    local children = self.my_card_plane:getChildren()
    for i,v in ipairs(children) do
        local color, _ = math.modf(v.cardVariety_/16)

        if v.cardValue_ == data.value and (color+1) == data.color then

            return v
        end
    end
    return nil
end

function CardPlaneOperator:showCardByMode(mode)
    local IntermediatePointX = self.my_card_plane:getContentSize().width/2
    local WorldMiddlePosition = self.my_card_plane:convertToNodeSpace(cc.p(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - 100))

    self:sortByMode(mode)
    for index,value in ipairs(self.userCardData) do
        local card = self:getCardByCardData(value)
        local target_point_x = IntermediatePointX + (index - (#self.userCardData + 1)/2) *MyHandCardInterval
        local target_point_y = MyCardY
        if card == nil then return end
        local icon = card.font_pai_:getChildByName("big_card_kong")
        icon:setTag(index)
        card:setPosition(cc.p(target_point_x,target_point_y))
    end
    self:analyseCards()
end

return CardPlaneOperator


--self.tips_text = resourceNode:get
--------------------------------------------------------------------------
-- local Cuo_Card_Path = TpackageName .. "/images/newcard/"

-- local Card_Variety_Transform_Path = 
-- {
--     [VARIETY_DIAMOND] = "diamonds_",
--     [VARIETY_CLUB] = "clubs_",
--     [VARIETY_HEART] = "hearts_",
--     [VARIETY_SPADE] = "spades_",
-- }

-- local Card_Value_Transform_Path = 
-- {
--     [0] = "",
--     [1] = "01.png",
--     [2] = "02.png",
--     [3] = "03.png",
--     [4] = "04.png",
--     [5] = "05.png",
--     [6] = "06.png",
--     [7] = "07.png",
--     [8] = "08.png",
--     [9] = "09.png",
--     [10] = "10.png",
--     [11] = "j.png",
--     [12] = "q.png",
--     [13] = "k.png",
--     [14] = "14.png",--五小牛
-- }

