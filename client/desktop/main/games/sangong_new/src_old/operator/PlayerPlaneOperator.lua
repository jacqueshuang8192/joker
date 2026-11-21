--
-- Author: Your Name
-- Date: 2017-09-05 19:21:38
--
local PlayerPlaneOperator = class('PlayerPlaneOperator')

local UserInfoPlaneOperator = require(TpackageName .. '.operator.UserInfoPlaneOperator')
local CardPlaneOperator = require(TpackageName .. '.operator.CardPlaneOperator')

local PLAYER_PLANE_TABLE = {}

function PlayerPlaneOperator:initLayout(playerType, plane, uid)
    --local six_people_player_plane = SANGONG_GAME_SCENE:getChildByName("six_people_player_plane")
    --local eight_people_player_plane = SANGONG_GAME_SCENE:getChildByName("eight_people_player_plane")
    --local ten_people_player_plane = SANGONG_GAME_SCENE:getChildByName("ten_people_player_plane")
    --
    --six_people_player_plane:setVisible(false)
    --eight_people_player_plane:setVisible(false)
    --ten_people_player_plane:setVisible(false)
end

function PlayerPlaneOperator:init(total_playernum)
    PLAYER_PLANE_TABLE = {
        [CARD_PLAYERTYPE_MY] = SANGONG_GAME_SCENE:getChildByName('player_plane_0'),
        [CARD_PLAYERTYPE_1] = SANGONG_GAME_SCENE:getChildByName('player_plane_1'),
        [CARD_PLAYERTYPE_2] = SANGONG_GAME_SCENE:getChildByName('player_plane_2'),
        [CARD_PLAYERTYPE_3] = SANGONG_GAME_SCENE:getChildByName('player_plane_3'),
        [CARD_PLAYERTYPE_4] = SANGONG_GAME_SCENE:getChildByName('player_plane_4'),
        [CARD_PLAYERTYPE_5] = SANGONG_GAME_SCENE:getChildByName('player_plane_5'),
        [CARD_PLAYERTYPE_6] = SANGONG_GAME_SCENE:getChildByName('player_plane_6'),
        [CARD_PLAYERTYPE_7] = SANGONG_GAME_SCENE:getChildByName('player_plane_7'),
        [CARD_PLAYERTYPE_8] = SANGONG_GAME_SCENE:getChildByName('player_plane_8'),
        [CARD_PLAYERTYPE_9] = SANGONG_GAME_SCENE:getChildByName('player_plane_9'),
        [CARD_PLAYERTYPE_10] = SANGONG_GAME_SCENE:getChildByName('player_plane_10'),
        [CARD_PLAYERTYPE_11] = SANGONG_GAME_SCENE:getChildByName('player_plane_11'),
        [CARD_PLAYERTYPE_12] = SANGONG_GAME_SCENE:getChildByName('player_plane_12')
    }

    for playerType = 1, total_playernum do
        self:initPlayer(playerType)
    end
end

function PlayerPlaneOperator:clearPlayer()
    for playerType = 1, TOTAL_PLAYERNUM do
        self:initPlayer(playerType)
    end
end
function PlayerPlaneOperator:getPlayerPlane(playerType)
    return PLAYER_PLANE_TABLE[playerType]
end

function PlayerPlaneOperator:removePlayer(playerType)
    self:initPlayer(playerType)
end

function PlayerPlaneOperator:initPlayer(playerType)
    local plane = self:getPlayerPlane(playerType)
    --local headplane = plane:getChildByName("head_plane")
    if tolua.isnull(plane) then
        return
    end
    UserInfoPlaneOperator:init(playerType, plane)
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:init(playerType, handCardPlane)
end
function PlayerPlaneOperator:restartMoveCard()
    CardPlaneOperator:restartMoveCard()
end

function PlayerPlaneOperator:relocate(plane)
    if tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:relocate(headplane)
end
function PlayerPlaneOperator:hidePlayer(plane)
    --local headplane = plane:getChildByName("head_plane")
    -- UserInfoPlaneOperator:hidePlayer(headplane)
end
function PlayerPlaneOperator:showPlayer(plane)
    if tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:showPlayer(headplane)
end

function PlayerPlaneOperator:switchMode(plane, _type)
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:switchMode(headplane, _type)
end

function PlayerPlaneOperator:swtichCardBackImg(typeIndex)
    CardPlaneOperator:swtichCardBackImg(typeIndex)
end

function PlayerPlaneOperator:setBetChip(plane, value, flag)
    if tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:setBetChip(headplane, value, flag)
end

function PlayerPlaneOperator:setTotalBetChip(plane, value, flag)
    UserInfoPlaneOperator:setTotalBetChip(plane, value, flag)
end

function PlayerPlaneOperator:showBetEffect(playerType, value)
    local plane = self:getPlayerPlane(playerType)
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:showBetEffect(headplane, value)
end
function PlayerPlaneOperator:setTextNmuber(plane, value)
    if tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    -- UserInfoPlaneOperator:setTextNmuber(headplane,value)
end

function PlayerPlaneOperator:clearGameDatas(playerType, plane, stage)
    if tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:clearGameDatas(playerType, headplane, stage)
    local handCardPlane = plane:getChildByName('inhand_plane')
    plane:setLocalZOrder(88)
    CardPlaneOperator:clearGameDatas(playerType, handCardPlane, stage)
    UserInfoPlaneOperator:clearBetChip(plane)
end

function PlayerPlaneOperator:showPlayerInfo(playerType, plane, userInfo, seat)
    if tolua.isnull(plane) then
        return
    end
    plane:setVisible(true)
    -- local number_text = plane:getChildByName("number_text")
    -- number_text:setString(tostring(seat+1).."号位")
    local headplane = plane:getChildByName('head_plane')
    return UserInfoPlaneOperator:showPlayerInfo(playerType, headplane, userInfo, seat)
end

function PlayerPlaneOperator:showMyPlayerInfo(playerType, plane, userInfo, no, pwd)
    if tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    return UserInfoPlaneOperator:showMyPlayerInfo(headplane, userInfo, no, pwd)
end
function PlayerPlaneOperator:updateTableNoTotal(plane, chip)
    local total_plane = plane:getChildByName('total_plane')
    UserInfoPlaneOperator:updateTableNoTotal(total_plane, chip)
end
function PlayerPlaneOperator:updateCoin(plane, value, orichip)
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:updateCoin(headplane, value, orichip)
end

function PlayerPlaneOperator:setCoin(plane, value)
    if tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:setCoin(headplane, value)
end

function PlayerPlaneOperator:setMyCoin(plane, value)
    if tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:setCoin(headplane, value)
    -- UserInfoPlaneOperator:setMyCoin(headplane,value)
end

function PlayerPlaneOperator:showHeadSymbol(plane, _type, flag)
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:showHeadSymbol(headplane, _type, flag)
end

function PlayerPlaneOperator:setGrabBankerSymbol(plane, flag)
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:setGrabBankerSymbol(headplane, flag)
end

function PlayerPlaneOperator:setBetTimes(plane, times, flag)
    if plane then
        local headplane = plane:getChildByName('head_plane')
        UserInfoPlaneOperator:setBetTimes(headplane, times, flag)
    end
end

function PlayerPlaneOperator:setGrabBankerTimes(plane, times, flag)
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:setGrabBankerTimes(headplane, times, flag)
end

function PlayerPlaneOperator:setReadyStatus(plane, flag)
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:setReadyStatus(headplane, flag)
end

function PlayerPlaneOperator:setEffectFrame(playerType, plane, _type, flag)
    if plane then
        local headplane = plane:getChildByName('head_plane')
        UserInfoPlaneOperator:setEffectFrame(playerType, headplane, _type, flag)
    end
end

function PlayerPlaneOperator:beginPlayCard(plane, flag)
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:beginPlayCard(headplane, flag)
end
function PlayerPlaneOperator:showCardsBack(plane, callback)
    local handCardPlane = plane:getChildByName('inhand_plane')
    handCardPlane:setLocalZOrder(88)
    CardPlaneOperator:showCardsBack(handCardPlane, callback)
end
function PlayerPlaneOperator:countFanAndShow(plane)
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:countFanAndShow(handCardPlane)
end

function PlayerPlaneOperator:showCuoPai(cards, flag)
    CardPlaneOperator:showCuoPai(cards, flag)
end

function PlayerPlaneOperator:showCardKind(playerType, plane, cardKind, type, isSound)
    if tolua.isnull(plane) then
        return
    end
    -- local handCardPlane = plane:getChildByName("inhand_plane")
    CardPlaneOperator:showCardKind(playerType, plane, cardKind, type, isSound)
end

function PlayerPlaneOperator:showCards(playerType, plane, cards)
    if tolua.isnull(plane) then
        return
    end
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:showCards(playerType, handCardPlane, cards)
end

function PlayerPlaneOperator:turnCards(plane)
    if tolua.isnull(plane) then
        return
    end
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:turnCards(handCardPlane)
end

function PlayerPlaneOperator:showAllCards(playerType, plane, cards, cardEndIndex, flag, cardType)
    if tolua.isnull(plane) then
        return
    end
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:showAllCards(playerType, handCardPlane, cards, cardEndIndex, flag, cardType)
end

function PlayerPlaneOperator:showDealCardsAnimation(playerType, plane, cards, cardEndIndex)
    if tolua.isnull(plane) then
        return
    end
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:showDealCardsAnimation(playerType, handCardPlane, cards, cardEndIndex)
end

function PlayerPlaneOperator:foldCard(playerType, plane, cards)
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:foldCard(playerType, handCardPlane, cards)
end

function PlayerPlaneOperator:outCard(playerType, plane, cards)
    if tolua.isnull(plane) then
        return
    end
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:outCard(playerType, handCardPlane, cards)
end

function PlayerPlaneOperator:clearCardPlane(playerType, plane)
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:clearCardPlane(playerType, handCardPlane)
end

return PlayerPlaneOperator
