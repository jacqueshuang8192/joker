local CardPlaneOperator = class("CardPlaneOperator")
local PokerCard = require(TpackageName .. ".PokerCard")

--local ControlPlaneOperator = require(TpackageName .. ".operator.ControlPlaneOperator")

local CARD_OPTION_MAP = CARD_OPTION_MAP
local CARD_COLOR_TYPE = CARD_COLOR_TYPE
local SPECIAL_TYPE_TEXT = SPECIAL_TYPE_TEXT
local MyCardScale = 1
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
    cardInterval = 109.05
    MyHandCardInterval = 80 * MyCardScale
    NewMyHandCardInterval = 140 *  OtherCardScale
    MyOutCardInterval =  240 * MyOutCardScale
    OtherCardInterval =  50 * OtherCardScale
    MyOutCardOffsetY = 100 * MyCardScale
    All_Card_Nodes = {}
    self:claerAllPlane()
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
    plane:stopAllActions()
    -- plane:removeAllChildren()
    -- plane:setVisible(false)
end

function CardPlaneOperator:swtichCardBackImg(typeIndex)
    CURRENTCARDBACKINDEX = typeIndex
end

--给自己发牌
function CardPlaneOperator:showCards(cardSpcardtype, cards)
    dump(cards,"--给自己发牌------------------")
    if #cards == 13 then
        GamePlaneOperator:removeMatchCardView()
        local MatchCardView = require(TpackageName..".view.MatchCardView").new()
        MatchCardView._csbNode:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH,SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
        MatchCardView:setName("MatchCardView")
        SCENENOW["scene"]:addChild(MatchCardView)
        MatchCardView:setDataCards(cards, cardSpcardtype)
    end
end


function CardPlaneOperator:showCardsBack(plane,callback,cards)
    local WorldMiddlePosition = plane:convertToNodeSpace(cc.p(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 ))
    plane:removeAllChildren()
    plane:getParent().handcard_plane:hide()
    SoundUtils:playEffect("发牌")
    for index=1,13 do
        local pokerCard = PokerCard.new()

        pokerCard:setScale(OtherCardScale)
        pokerCard:addTo(plane)
        pokerCard:setPosition(WorldMiddlePosition)

        local scale = plane:getContentSize().height/pokerCard:getCardSize().height
        local target_point_x = (index - 1) * (MyHandCardInterval * scale)
        local target_point_y = MyCardY
        local atime = 0.1
        local moveAction = cc.MoveTo:create(atime,cc.p(target_point_x,target_point_y))
        local scaleAction = cc.ScaleTo:create(atime,scale)
        local moveAndScaleAction = cc.Spawn:create(moveAction,scaleAction)
        local delay= cc.DelayTime:create(index * (atime - 0.04 ))
        local callFuncAc = cc.CallFunc:create(function ()
            if index == 13 and callback then
                callback()
            end           
        end)
        local delay1= cc.DelayTime:create(0)
        if index == 13 and callback then
            delay1= cc.DelayTime:create(atime)
        end 
        local se  = cc.Sequence:create(delay,moveAndScaleAction,delay1,callFuncAc)
        pokerCard:runAction(se)
    end
end


function CardPlaneOperator:clearCardPlane()
end

function CardPlaneOperator:setCardType()
end

function CardPlaneOperator:claerAllPlane()
  
end

return CardPlaneOperator

