-- local CARD_WIDTH      = 233
-- local CARD_HEIGHT     = 313
local CARD_WIDTH      = 225
local CARD_HEIGHT     = 303

local CARD_BACK_WIDTH      = 225
local CARD_BACK_HEIGHT     = 303

VARIETY_DIAMOND = 0x00 -- 方块
VARIETY_CLUB    = 0x10 -- 梅花
VARIETY_HEART   = 0x20 -- 红桃
VARIETY_SPADE   = 0x30 -- 黑桃

-- local pai_path = TpackageName .. "/images/card/"  --newcard
local pai_path = TpackageName .. "/images/pieces_card/"  --newcard
local PokerCardCsb = TpackageName .. "/csb/PokerCard.csb"
local Card_back_img_table = {   
                                [1] = TpackageName .. "/images/pieces_card/card_back_2.png",
                                [2] = TpackageName .. "/images/pieces_card/card_back_3.png",
                                [3] = TpackageName .. "/images/pieces_card/card_back_4.png",
                                [4] = TpackageName .. "/images/pieces_card/card_back_5.png",

                                [5] = TpackageName .. "/images/pieces_card/card_back.png",
                                [6] = TpackageName .. "/images/pieces_card/cuo_card_back.png",
                            }

local Card_back_img_size_table = {   
                                [1] = {width =300 ,height =458},
                                [2] = {width =300 ,height =458},
                                [3] = {width =300 ,height =458},
                                [4] = {width =300 ,height =458},
                                
                                [5] = {width =225 ,height =303},
                                [6] = {width =300 ,height =458},
                            }
                            

local Shuffling_card_path = TpackageName .. "/images/shuffling_card/"  --newcard

local CARD_VARIETY_TRANSFORM_PATH = 
{
    [VARIETY_DIAMOND] =Shuffling_card_path.. "diamonds_",
    [VARIETY_CLUB] = Shuffling_card_path.."clubs_",
    [VARIETY_HEART] = Shuffling_card_path.."hearts_",
    [VARIETY_SPADE] = Shuffling_card_path.."spades_",
}

-- 获得花色
local function getVariety(card)
    return bit.band(card, 0xF0)
end

-- 获得牌值
local function getValue(card)
    local value = bit.band(card, 0x0F)
    if value == 1 then
        value = 14
    end
    return value
end


local PokerCard = class("PokerCard", function ()
    return display.newNode()
end)

function PokerCard:ctor()
    -- 初始数值
    self.isBack_ = true
    -- 牌背

    -- self.backBg_ = display.newSprite(pai_path .. "card_back_blue.png"):addTo(self)
    self.backBg_ = dCisplay.newSprite(Card_back_img_table[CURRENTCARDBAKINDEX]):addTo(self)
    -- self.backBg_:setContentSize(cc.size(CARD_WIDTH,CARD_HEIGHT))
    
    self.backBg_:setScaleX(CARD_WIDTH/Card_back_img_size_table[CURRENTCARDBACKINDEX].width)
    self.backBg_:setScaleY(CARD_HEIGHT/Card_back_img_size_table[CURRENTCARDBACKINDEX].height)

    self.backBg_:setAnchorPoint(cc.p(0.5,0)) 
    self.cardUint_ = 1

end

function PokerCard:showCardBackChooseBox()
    
    local chooseBox = PAIJIU_GAME_SCENE:getParent():getChildByName("hall_panel"):getChildByName("cardBackChooseBox")
          chooseBox:setVisible(true)
    local chooseBox_lv = chooseBox:getChildByName("chooseBox_lv")
    chooseBox_lv:removeAllChildren()

    local lottery_content_bottom = chooseBox:getChildByName("lottery_content_bottom")
    lottery_content_bottom:setTouchEnabled(true)
    lottery_content_bottom:addTouchEventListener(function(sender,event) 

            if  event == TOUCH_EVENT_ENDED then
                chooseBox:setVisible(false)
            end

        end)

    for typeIndex = 1,6 do

        local card_back = ccui.ImageView:create(Card_back_img_table[typeIndex])

        card_back:setScaleX(CARD_WIDTH/Card_back_img_size_table[typeIndex].width)
        card_back:setScaleY(CARD_HEIGHT/Card_back_img_size_table[typeIndex].height)

        card_back:setTouchEnabled(true)
        chooseBox_lv:pushBackCustomItem(card_back)

        card_back:addTouchEventListener(function(sender,event) 

            if  event == TOUCH_EVENT_ENDED then
                self:swtichCardBackImg(typeIndex)
                chooseBox:setVisible(false)
            end

        end)

        if typeIndex == CURRENTCARDBACKINDEX then
            card_back:setColor(cc.c3b(100,100,100))
        else
            card_back:setColor(cc.c3b(255,255,255)) 
        end
    end

end

function PokerCard:getSingleCardBackPath()
    -- s:setContentSize(cc.size(300,458))
    -- if GROUP_MODE == 2 then
    --     return Card_back_img_table[5],Card_back_img_size_table[5]
    -- else
        return Card_back_img_table[CURRENTCARDBACKINDEX],Card_back_img_size_table[CURRENTCARDBACKINDEX]
    -- end

end

function PokerCard:getCardBackAndSizeTable()
    return Card_back_img_table,Card_back_img_size_table
end

function PokerCard:createSingleCard(cardUint)

    local cardUint_  = cardUint or 1

    -- 获取值与花色
    local cardValue_ = getValue(cardUint_)
    local cardVariety_ = getVariety(cardUint_)

    if  cardValue_  >= 2 and  cardValue_  < 10 then
        cardPath =  CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)].."0"..cardValue_..".png"          
    else
        cardPath =  CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)]..cardValue_..".png"    
    end

    dump(cardPath,"createSingleCard")
    local s = display.newSprite(cardPath)

    -- local s = cc.CSLoader:createNode(PokerCardCsb)

    -- local cardValue_iv = s:getChildByName("cardValue_iv")
    -- local cardVarietySmall_iv = s:getChildByName("cardVarietySmall_iv")
    -- local cardVariety_iv = s:getChildByName("cardVariety_iv")

    -- if cardVariety_ == VARIETY_DIAMOND then -- 方块

    --     cardValue_iv:loadTexture(pai_path .. "red_" .. tostring(cardValue_ ) .. ".png")
    --     cardVarietySmall_iv:loadTexture(pai_path .. "diamonds.png")
    --     cardVariety_iv:loadTexture(pai_path .. "diamonds.png")

    -- elseif cardVariety_ == VARIETY_CLUB then-- 梅花

    --     cardValue_iv:loadTexture(pai_path .. "black_" .. tostring(cardValue_ ) .. ".png")
    --     cardVarietySmall_iv:loadTexture(pai_path .. "clubs.png")
    --     cardVariety_iv:loadTexture(pai_path .. "clubs.png")

    -- elseif cardVariety_ == VARIETY_HEART then-- 红桃
        
    --     cardValue_iv:loadTexture(pai_path .. "red_" .. tostring(cardValue_ ) .. ".png")
    --     cardVarietySmall_iv:loadTexture(pai_path .. "hearts.png")
    --     cardVariety_iv:loadTexture(pai_path .. "hearts.png")

    -- elseif cardVariety_ == VARIETY_SPADE then-- 黑桃

    --     cardValue_iv:loadTexture(pai_path .. "black_" .. tostring(cardValue_ ) .. ".png")
    --     cardVarietySmall_iv:loadTexture(pai_path .. "spades.png")
    --     cardVariety_iv:loadTexture(pai_path .. "spades.png")

    -- end

    return s

end


function PokerCard:setCuoCard(cardNode,cardUint,isBack)
    
    if  cardNode == nil then
        cardNode = display.newNode()
    end

    cardNode.backBg_ = display.newSprite(Card_back_img):addTo(cardNode)  
    cardNode.backBg_:setContentSize(cc.size(300,458))
    cardNode.backBg_:setAnchorPoint(cc.p(0,0)) 

    if  isBack == true then
        cardNode.backBg_:setVisible(true)
        return
    else
        cardNode.backBg_:setVisible(false)
    end


    local cardUint_  = cardUint or 1

    -- 获取值与花色
    local cardValue_ = getValue(cardUint_)
    local cardVariety_ = getVariety(cardUint_)

    if  cardValue_  >= 2 and  cardValue_  < 10 then
        cardPath =  CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)].."0"..cardValue_..".png"          
    else
        cardPath =  CARD_VARIETY_TRANSFORM_PATH[tonumber(cardVariety_)]..cardValue_..".png"    
    end

    local s = display.newSprite(cardPath):addTo(cardNode)

    -- local s = cc.CSLoader:createNode(PokerCardCsb):addTo(cardNode)

    -- local cardValue_iv = s:getChildByName("cardValue_iv")
    -- local cardVarietySmall_iv = s:getChildByName("cardVarietySmall_iv")
    -- local cardVariety_iv = s:getChildByName("cardVariety_iv")
    
    -- if cardVariety_ == VARIETY_DIAMOND then -- 方块

    --     cardValue_iv:loadTexture(pai_path .. "red_" .. tostring(cardValue_ ) .. ".png")
    --     cardVarietySmall_iv:loadTexture(pai_path .. "diamonds.png")
    --     cardVariety_iv:loadTexture(pai_path .. "diamonds.png")

    -- elseif cardVariety_ == VARIETY_CLUB then-- 梅花

    --     cardValue_iv:loadTexture(pai_path .. "black_" .. tostring(cardValue_ ) .. ".png")
    --     cardVarietySmall_iv:loadTexture(pai_path .. "clubs.png")
    --     cardVariety_iv:loadTexture(pai_path .. "clubs.png")

    -- elseif cardVariety_ == VARIETY_HEART then-- 红桃
        
    --     cardValue_iv:loadTexture(pai_path .. "red_" .. tostring(cardValue_ ) .. ".png")
    --     cardVarietySmall_iv:loadTexture(pai_path .. "hearts.png")
    --     cardVariety_iv:loadTexture(pai_path .. "hearts.png")

    -- elseif cardVariety_ == VARIETY_SPADE then-- 黑桃

    --     cardValue_iv:loadTexture(pai_path .. "black_" .. tostring(cardValue_ ) .. ".png")
    --     cardVarietySmall_iv:loadTexture(pai_path .. "spades.png")
    --     cardVariety_iv:loadTexture(pai_path .. "spades.png")

    -- end
    
    cardNode.font_pai_  = s
    cardNode.font_pai_:setVisible(true)
    cardNode.font_pai_:setAnchorPoint(cc.p(0,0)) 

    return cardNode
end

-- 设置扑克牌面,拼接方式生成
function PokerCard:setCard(cardUint)

    self.cardUint_  = cardUint or 1

    -- 获取值与花色
    self.cardValue_ = getValue(self.cardUint_)
    self.cardVariety_ = getVariety(self.cardUint_)

    self.font_pai_ = cc.CSLoader:createNode(PokerCardCsb):addTo(self)

    local cardValue_iv = self.font_pai_:getChildByName("cardValue_iv")
    local cardVarietySmall_iv = self.font_pai_:getChildByName("cardVarietySmall_iv")
    local cardVariety_iv = self.font_pai_:getChildByName("cardVariety_iv")
    

    dump(pai_path,"pai_path")
    dump(self.cardValue_,"cardValue_")
    
    if self.cardVariety_ == VARIETY_DIAMOND then -- 方块

        cardValue_iv:loadTexture(pai_path .. "red_" .. tostring(self.cardValue_ ) .. ".png")
        cardVarietySmall_iv:loadTexture(pai_path .. "diamonds.png")
        cardVariety_iv:loadTexture(pai_path .. "diamonds.png")

    elseif self.cardVariety_ == VARIETY_CLUB then-- 梅花

        cardValue_iv:loadTexture(pai_path .. "black_" .. tostring(self.cardValue_ ) .. ".png")
        cardVarietySmall_iv:loadTexture(pai_path .. "clubs.png")
        cardVariety_iv:loadTexture(pai_path .. "clubs.png")

    elseif self.cardVariety_ == VARIETY_HEART then-- 红桃
        
        cardValue_iv:loadTexture(pai_path .. "red_" .. tostring(self.cardValue_ ) .. ".png")
        cardVarietySmall_iv:loadTexture(pai_path .. "hearts.png")
        cardVariety_iv:loadTexture(pai_path .. "hearts.png")

    elseif self.cardVariety_ == VARIETY_SPADE then-- 黑桃

        cardValue_iv:loadTexture(pai_path .. "black_" .. tostring(self.cardValue_ ) .. ".png")
        cardVarietySmall_iv:loadTexture(pai_path .. "spades.png")
        cardVariety_iv:loadTexture(pai_path .. "spades.png")

    end

    -- self.font_pai_ = s
    self.font_pai_:setAnchorPoint(cc.p(0.5,0))
    
    self.font_pai_:setTouchEnabled(false)

    return self
end

-- -- 设置扑克牌面
-- function PokerCard:setCard(cardUint)

--     self.cardUint_  = cardUint or 1

--     -- 获取值与花色
--     self.cardValue_ = getValue(self.cardUint_)
--     self.cardVariety_ = getVariety(self.cardUint_)
    
--     local cardPath

--     if  self.cardValue_  >= 2 and  self.cardValue_  < 10 then
--         cardPath =  CARD_VARIETY_TRANSFORM_PATH[tonumber(self.cardVariety_)].."0"..self.cardValue_..".png"          
--     else
--         cardPath =  CARD_VARIETY_TRANSFORM_PATH[tonumber(self.cardVariety_)]..self.cardValue_..".png"    
--     end

--     dump(cardPath,"cardPath")

--     self.font_pai_ = display.newSprite(cardPath):addTo(self)
--     self.font_pai_:setAnchorPoint(cc.p(0.5,0))
    
--     self.font_pai_:setTouchEnabled(false)

--     return self
-- end

function PokerCard:flipCard()

    self.isBack_ = false

    local cardFace = self.font_pai_
    local cardBack = self.backBg_

    -- 正反面旋转  
    local aniTime = 0.25  
    self:runAction(cc.Sequence:create(   
    cc.CallFunc:create(  
        function (sender)  
            cardFace:setVisible(false)  
            cardBack:setVisible(true)  
            cardBack:runAction(cc.OrbitCamera:create(aniTime, 1, 0, 0, 90, 0, 0) ) 
        end),  
    -- cc.DelayTime:create(aniTime),  
    cc.CallFunc:create(  
        function (sender)  
            cardFace:setVisible(true)  
            cardBack:setVisible(false)  
            cardFace:runAction( cc.OrbitCamera:create(aniTime, 1, 0, 270, 90, 0, 0) )
            -- cardBack:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0)) 
        end)
    )) 


end

-- 显示正面
function PokerCard:showFront()
    self.isBack_ = false
    self.backBg_:setVisible(false)
    self.font_pai_:setVisible(true)
    return self
end

-- 显示背面
function PokerCard:showBack()
    self.isBack_ = true
    
    if  self.font_pai_ then
        dump("隐藏牌面")
        self.font_pai_:setVisible(false)
    end

    if  self.backBg_ then
        dump("显示牌背")
        self.backBg_:setVisible(true)
    end
    
    return self
end

function PokerCard:isBack()
    return self.isBack_
end

function PokerCard:setFilpEvent(value,handcardnodes)

    self:setTouchEnabled(true)
    self:setCard(value)
    self:showBack()
     
     -- self.backBg_:setTouchMode(cc.TOUCHES_ALL_AT_ONCE)    
     -- self.backBg_:setTouchSwallowEnabled(false)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event) 

         dump(event.name,"setFilpEvent_touchtest1")
         dump("setFilpEvent_touchtest2")

        if  self.isBack_ == false then
            return
        end

        self:flipCard()
         
        local ifAllcardsLiang = true
        for key,card in pairs(handcardnodes) do
            if card.isBack_ == true then
                ifAllcardsLiang = false
            end
        end

        if ifAllcardsLiang==true then
            SCENENOW["scene"]:performWithDelay(function()
                GamePlaneOperator:countFanAndShow(CARD_PLAYERTYPE_MY)
            end,0.1)
        end

        return true
 end)

end


function PokerCard:setTouchEvent(handcardnodes)

    self:setTouchEnabled(true)
    self.isCounted = false

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event) 
         
        if event.name == "began" then

            local  CountedCardCount = 0
  
            for index,cardValue in ipairs(EMPTY_TABLE) do
                if  EMPTY_TABLE[index] ~= 0 then
                    CountedCardCount = CountedCardCount + 1    
                end
            end

            if  self.isCounted == false then

                if  CountedCardCount >= 3 then
                    return false
                end

                self:setPositionY(self:getPositionY() + 30)

                for index,cardValue in ipairs(EMPTY_TABLE) do
                    if  EMPTY_TABLE[index] == 0 then
                        self.countedIndex = index
                        EMPTY_TABLE[index] = self.cardValue_
                        break
                    end
                end

                self.isCounted = not(self.isCounted) 
                GamePlaneOperator:showNumCount(self.cardValue_,self.countedIndex)

            elseif self.isCounted == true then

                self:setPositionY(self:getPositionY() - 30)
                EMPTY_TABLE[self.countedIndex] = 0
                GamePlaneOperator:showNumCount(self.cardValue_,self.countedIndex,false)
                self.isCounted = not(self.isCounted) 
                
            end       


            return true

        end

    end)

end


return PokerCard