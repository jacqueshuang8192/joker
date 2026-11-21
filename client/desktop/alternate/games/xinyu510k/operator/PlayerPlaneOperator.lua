--
-- Author: Your Name
-- Date: 2017-09-05 19:21:38
--
local  PlayerPlaneOperator = class("PlayerPlaneOperator")
local  UserInfoPlaneOperator = require("xinyu510k.operator.UserInfoPlaneOperator")
local  CardPlaneOperator = require("xinyu510k.operator.CardPlaneOperator")

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

function PlayerPlaneOperator:showAlarm(plane, flag, playerType)
    UserInfoPlaneOperator:showAlarm(plane, flag, playerType)
end

function PlayerPlaneOperator:showPlayerInfo(playerType,headplane,userInfo)
   	return UserInfoPlaneOperator:showPlayerInfo(playerType,headplane,userInfo)
end

function PlayerPlaneOperator:setDoubleFlag(headplane, times, flag)
    UserInfoPlaneOperator:setDoubleFlag(headplane, times, flag)
end

function PlayerPlaneOperator:showNetworkImg(headplane, flag)
	UserInfoPlaneOperator:showNetworkImg(headplane,flag)
end

function PlayerPlaneOperator:updateCoin(playerType,headplane,value)
	UserInfoPlaneOperator:updateCoin(playerType,headplane,value)
end

function PlayerPlaneOperator:updateBombFen(headplane,value)
	UserInfoPlaneOperator:updateBombFen(headplane,value)
end

function PlayerPlaneOperator:showLandLord(headplane,_type,flag)
	UserInfoPlaneOperator:showLandLord(headplane,_type,flag)
end

function PlayerPlaneOperator:beginPlayCard(headplane,flag)
    UserInfoPlaneOperator:beginPlayCard(headplane,flag)
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