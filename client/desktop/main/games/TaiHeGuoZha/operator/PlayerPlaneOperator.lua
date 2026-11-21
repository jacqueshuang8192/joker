--
-- Author: Your Name
-- Date: 2017-09-05 19:21:38
--
local PlayerPlaneOperator = class("PlayerPlaneOperator")
local UserInfoPlaneOperator = require("TaiHeGuoZha.operator.UserInfoPlaneOperator")
local CardPlaneOperator = require("TaiHeGuoZha.operator.CardPlaneOperator")

function PlayerPlaneOperator:init(playerType, headplane)
    UserInfoPlaneOperator:init(headplane)
end

function PlayerPlaneOperator:clearGameDatas(playerType, headplane)
    UserInfoPlaneOperator:clearGameDatas(playerType, headplane)
end

function PlayerPlaneOperator:removePlayer(playerType, plane)
    UserInfoPlaneOperator:removePlayer(playerType, plane)
    CardPlaneOperator:clearUserCards(playerType)
    CardPlaneOperator:clearOutCards(playerType)
end

function PlayerPlaneOperator:clearUserDesk(playerType, plane)
    UserInfoPlaneOperator:clearUserDesk(playerType, plane)
end

function PlayerPlaneOperator:showAlarm(plane, flag)
    UserInfoPlaneOperator:showAlarm(plane, flag)
end

function PlayerPlaneOperator:showPlayerInfo(playerType, headplane, userInfo)
    return UserInfoPlaneOperator:showPlayerInfo(playerType, headplane, userInfo)
end

function PlayerPlaneOperator:setDoubleFlag(headplane, times, flag)
    UserInfoPlaneOperator:setDoubleFlag(headplane, times, flag)
end

function PlayerPlaneOperator:showNetworkImg(headplane, flag)
    UserInfoPlaneOperator:showNetworkImg(headplane, flag)
end

function PlayerPlaneOperator:updateCoin(playerType, headplane, value)
    UserInfoPlaneOperator:updateCoin(playerType, headplane, value)
end

function PlayerPlaneOperator:updateAllFen(playerType, headplane, value)
    UserInfoPlaneOperator:updateAllFen(playerType, headplane, value)
end
--奖分
function PlayerPlaneOperator:updateJiang(headplane, value)
    UserInfoPlaneOperator:updateJiang(headplane, value)
end

--捡分
function PlayerPlaneOperator:updateFen(headplane, value)
    UserInfoPlaneOperator:updateFen(headplane, value)
end

--桌面显示的分
function PlayerPlaneOperator:updatetxtFen(headplane, value, flag)
    UserInfoPlaneOperator:updatetxtFen(headplane, value, flag)
end

--显示头奖Flag
function PlayerPlaneOperator:updateJoker(headplane, _type, flag)
    UserInfoPlaneOperator:updateJoker(headplane, _type, flag)
end

--显示庄家flag
function PlayerPlaneOperator:showLandLord(headplane, _type, flag)
    UserInfoPlaneOperator:showLandLord(headplane, _type, flag)
end

function PlayerPlaneOperator:beginPlayCard(headplane, flag)
    UserInfoPlaneOperator:beginPlayCard(headplane, flag)
end

function PlayerPlaneOperator:showRemainCardsNum(plane, cardsNum, flag)
    UserInfoPlaneOperator:showRemainCardsNum(plane, cardsNum, flag)
end

function PlayerPlaneOperator:addScore(headplane, typ, score)
    UserInfoPlaneOperator:addScore(headplane, typ, score)
end

function PlayerPlaneOperator:setScore(headplane, typ, score)
    UserInfoPlaneOperator:setScore(headplane, typ, score)
end

return PlayerPlaneOperator
