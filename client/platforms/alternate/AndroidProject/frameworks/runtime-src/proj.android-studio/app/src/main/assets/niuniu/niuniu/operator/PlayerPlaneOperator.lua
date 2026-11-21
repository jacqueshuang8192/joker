--
-- Author: Your Name
-- Date: 2017-09-05 19:21:38
--
local PlayerPlaneOperator = class('PlayerPlaneOperator')

local UserInfoPlaneOperator = require(TpackageName .. '.operator.UserInfoPlaneOperator')
local CardPlaneOperator = require(TpackageName .. '.operator.CardPlaneOperator')

local PLAYER_PLANE_TABLE = {}

function PlayerPlaneOperator:initLayout()
end

function PlayerPlaneOperator:init(total_playernum)
    print("PlayerPlaneOperator:init ---------------------", total_playernum)
    local allPlayersPlane
    if NIUNIU_GAME_SCENE:getChildByName('ten_people_player_plane') then
        allPlayersPlane = NIUNIU_GAME_SCENE:getChildByName('ten_people_player_plane')
    else
        if USER_INFO['GroupLevel'] == 304 or USER_INFO['GroupLevel'] == 368 then
            local csbPath = total_playernum == 6 and (TpackageName .. '/csb/player_plane/six_people_player_plane2.csb') or (TpackageName .. '/csb/player_plane/ten_people_player_plane2.csb')
            allPlayersPlane =
                cc.CSLoader:createNode(csbPath):addTo(
                NIUNIU_GAME_SCENE
            ):setName('ten_people_player_plane')
        else
            local csbPath = total_playernum == 6 and (TpackageName .. '/csb/player_plane/six_people_player_plane.csb') or (TpackageName .. '/csb/player_plane/ten_people_player_plane.csb')
            allPlayersPlane =
                cc.CSLoader:createNode(csbPath):addTo(
                NIUNIU_GAME_SCENE
            ):setName('ten_people_player_plane')
        end
        GameUtils.setNodeNameBindObj(allPlayersPlane)

        local zidx = NIUNIU_GAME_SCENE.control_plane:getLocalZOrder()
        allPlayersPlane:setLocalZOrder(zidx - 1)
    end

    local tAllPlane = {}
    for i = 1, 12 do
        local plane = allPlayersPlane:getChildByName('player_plane_' .. i)
        if not (plane == nil or tolua.isnull(plane)) then
            tAllPlane[i] = plane
            local headplane = plane:getChildByName('head_plane')
            UserInfoPlaneOperator:init(i, headplane)
            local handCardPlane = plane:getChildByName('inhand_plane')
            CardPlaneOperator:init(i, handCardPlane)
        end
    end

    -- total_playernum = 10
    allPlayersPlane:setVisible(true)
    if total_playernum == 6 then
        PLAYER_PLANE_TABLE = {
            [CARD_PLAYERTYPE_MY] = tAllPlane[1],
            [CARD_PLAYERTYPE_LEFT1] = tAllPlane[2],
            [CARD_PLAYERTYPE_LEFT2] = tAllPlane[3],
            [CARD_PLAYERTYPE_LEFT3] = tAllPlane[4],
            [CARD_PLAYERTYPE_TOP1] = tAllPlane[5],
            [CARD_PLAYERTYPE_TOP2] = tAllPlane[6],
            ['error'] = NIUNIU_GAME_SCENE:getChildByName('player_plane_for_error')
        }
    else
        PLAYER_PLANE_TABLE = {
            [CARD_PLAYERTYPE_MY] = tAllPlane[1],
            [CARD_PLAYERTYPE_LEFT1] = tAllPlane[2],
            [CARD_PLAYERTYPE_LEFT2] = tAllPlane[3],
            [CARD_PLAYERTYPE_LEFT3] = tAllPlane[4],
            [CARD_PLAYERTYPE_TOP1] = tAllPlane[5],
            [CARD_PLAYERTYPE_TOP2] = tAllPlane[6],
            [CARD_PLAYERTYPE_TOP3] = tAllPlane[7],
            [CARD_PLAYERTYPE_RIGHT1] = tAllPlane[8],
            -- [CARD_PLAYERTYPE_RIGHT2] = tAllPlane[9],
            -- [CARD_PLAYERTYPE_RIGHT3] = tAllPlane[10],
            ['error'] = NIUNIU_GAME_SCENE:getChildByName('player_plane_for_error')
        }
    end
end

function PlayerPlaneOperator:getPlayerPlane(playerType)
    return PLAYER_PLANE_TABLE[playerType] or PLAYER_PLANE_TABLE['error'] --这个错误防止层是用在万一获取不到玩家层的情况下，有个承载操作的层
end

function PlayerPlaneOperator:removePlayer(playerType)
    self:initPlayer(playerType)
end

function PlayerPlaneOperator:initPlayer(playerType)
    local plane = self:getPlayerPlane(playerType)

    if plane == nil or tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:init(playerType, headplane, uid)
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:init(playerType, handCardPlane)
end

function PlayerPlaneOperator:relocate(plane)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:relocate(headplane)
end

function PlayerPlaneOperator:switchMode(plane, _type)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:switchMode(headplane, _type)
end

function PlayerPlaneOperator:setBetChip(plane, value, flag)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:setBetChip(headplane, value, flag)
end

function PlayerPlaneOperator:setTotalBetChip(plane, value, flag)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:setTotalBetChip(headplane, value, flag)
end

function PlayerPlaneOperator:showBetEffect(playerType, value)
    local plane = self:getPlayerPlane(playerType)
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:showBetEffect(headplane, value)
end

function PlayerPlaneOperator:clearGameDatas(playerType, plane, stage)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:clearGameDatas(playerType, headplane, stage)
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:clearGameDatas(playerType, handCardPlane, stage)
end

function PlayerPlaneOperator:showPlayerInfo(playerType, plane, userInfo)
    if tolua.isnull(plane) == false then
        --dump(plane:getPosition(), "getPositionplane"..playerType)
        --dump(plane:getName(), "getName"..playerType)
        local headplane = plane:getChildByName('head_plane')
        return UserInfoPlaneOperator:showPlayerInfo(playerType, headplane, userInfo)
    end
end

function PlayerPlaneOperator:updateCoinUserChips(plane, value, orichip)
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:updateCoinUserChips(headplane, value, orichip)
end
function PlayerPlaneOperator:updateCoin(plane, value, orichip)
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:updateCoin(headplane, value, orichip)
end
function PlayerPlaneOperator:setCoin(plane, value)
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:setCoin(headplane, value)
end

function PlayerPlaneOperator:showHeadSymbol(plane, _type, flag)
    if not plane then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:showHeadSymbol(headplane, _type, flag)
end

function PlayerPlaneOperator:setGrabBankerSymbol(plane, flag)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:setGrabBankerSymbol(headplane, flag)
end

function PlayerPlaneOperator:setBetTimes(plane, times, flag, isTuiZhu, isLaiZi)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:setBetTimes(headplane, times, flag, isTuiZhu, isLaiZi)
end

function PlayerPlaneOperator:setGrabBankerTimes(plane, times, flag)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:setGrabBankerTimes(headplane, times, flag)
end

function PlayerPlaneOperator:setMaxTuizhuTimes(plane, times, flag)
    if plane then
        local headplane = plane:getChildByName('head_plane')
        UserInfoPlaneOperator:setMaxTuizhuTimes(headplane, times, flag)
    end
end

function PlayerPlaneOperator:setReadyStatus(plane, flag)
    if plane == nil or tolua.isnull(plane) then
        return
    end
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
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:beginPlayCard(headplane, flag)
end

function PlayerPlaneOperator:countFanAndShow(plane)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:countFanAndShow(handCardPlane)
end

function PlayerPlaneOperator:showCuoPai(cards, flag)
    CardPlaneOperator:showCuoPai(cards, flag)
end

function PlayerPlaneOperator:showCardKind(playerType, plane, cardKind)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:showCardKind(playerType, handCardPlane, cardKind)
end

function PlayerPlaneOperator:showCards(playerType, plane, cards, flag, isRelogin)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:showCards(playerType, handCardPlane, cards, flag, isRelogin)
end

function PlayerPlaneOperator:turnCards(plane)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local handCardPlane = plane.inhand_plane
    CardPlaneOperator:turnCards(handCardPlane)
end

function PlayerPlaneOperator:showDealCardsAnimation(playerType, plane, cards, cardEndIndex, isRelogin, cardState)
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:showDealCardsAnimation(playerType, handCardPlane, cards, cardEndIndex, isRelogin, cardState)
end

function PlayerPlaneOperator:foldCard(playerType, plane, cards)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:foldCard(playerType, handCardPlane, cards)
end

function PlayerPlaneOperator:outCard(playerType, plane, cards, card)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:outCard(playerType, handCardPlane, cards, card)
end

function PlayerPlaneOperator:openCards(playerType, plane)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:openCards(playerType, handCardPlane)
end
function PlayerPlaneOperator:initPlayerView(playerType)
    local plane = self:getPlayerPlane(playerType)
    if plane == nil or tolua.isnull(plane) then
        return
    end
    local headplane = plane:getChildByName('head_plane')
    UserInfoPlaneOperator:init(playerType, headplane)
    local handCardPlane = plane:getChildByName('inhand_plane')
    CardPlaneOperator:clearGameDatas(playerType, handCardPlane, 2)
end

return PlayerPlaneOperator
