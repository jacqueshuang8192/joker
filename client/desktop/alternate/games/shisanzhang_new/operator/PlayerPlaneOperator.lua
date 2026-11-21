--
-- Author: Your Name
-- Date: 2017-09-05 19:21:38
--
local  PlayerPlaneOperator = class("PlayerPlaneOperator")

local  UserInfoPlaneOperator = require(TpackageName .. ".operator.UserInfoPlaneOperator")
local  CardPlaneOperator = require(TpackageName .. ".operator.CardPlaneOperator")
local  CompCardLayer = require(TpackageName .. ".view.CompCardLayer")

local  PLAYER_PLANE_TABLE = {}

function PlayerPlaneOperator:initLayout(playerType,plane,uid)

end

function PlayerPlaneOperator:init(total_playernum)


	PLAYER_PLANE_TABLE={[CARD_PLAYERTYPE_MY] = SHISANZHANG_GAME_SCENE:getChildByName("rolePanel_1"),

					[CARD_PLAYERTYPE_2]  = SHISANZHANG_GAME_SCENE:getChildByName("rolePanel_2"),
					[CARD_PLAYERTYPE_3]  = SHISANZHANG_GAME_SCENE:getChildByName("rolePanel_3"),
					[CARD_PLAYERTYPE_4]  = SHISANZHANG_GAME_SCENE:getChildByName("rolePanel_4"),

					[CARD_PLAYERTYPE_5]   = SHISANZHANG_GAME_SCENE:getChildByName("rolePanel_5"),
					[CARD_PLAYERTYPE_6]   = SHISANZHANG_GAME_SCENE:getChildByName("rolePanel_6"),
					[CARD_PLAYERTYPE_7]   = SHISANZHANG_GAME_SCENE:getChildByName("rolePanel_7"),
					[CARD_PLAYERTYPE_8]   = SHISANZHANG_GAME_SCENE:getChildByName("rolePanel_8"),
				}

	dump(total_playernum,"total_playernum")
	for playerType = 1,8 do
		self:initPlayer(playerType)
	end
	self:claerAllPlane()
	CardPlaneOperator:init()
	if TOTAL_PLAYERNUM == 4 then
		SHISANZHANG_GAME_SCENE.rolePanel_3:setPositionY(540)
		SHISANZHANG_GAME_SCENE.rolePanel_4:setPositionY(540)
	end
end

function PlayerPlaneOperator:clearPlayer()
	for playerType = 1,TOTAL_PLAYERNUM do
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
	if tolua.isnull(plane) then
		return
	end
    UserInfoPlaneOperator:init(playerType,plane)
--	local handCardPlane = plane:getChildByName("handcard_plane")
--	CardPlaneOperator:init(playerType,handCardPlane)
end
function PlayerPlaneOperator:restartMoveCard()
	CardPlaneOperator:restartMoveCard()
end

function PlayerPlaneOperator:relocate(plane)
	if tolua.isnull(plane) then
		return
	end
	UserInfoPlaneOperator:relocate(plane)
end
function PlayerPlaneOperator:hidePlayer(plane)
	UserInfoPlaneOperator:hidePlayer(plane)
end
function PlayerPlaneOperator:showPlayer(plane)
	if tolua.isnull(plane) then
		return
	end
	UserInfoPlaneOperator:showPlayer(plane)
end

function PlayerPlaneOperator:switchMode(plane,_type)
	UserInfoPlaneOperator:switchMode(plane,_type)
end

function PlayerPlaneOperator:swtichCardBackImg(typeIndex)
	CardPlaneOperator:swtichCardBackImg(typeIndex)
end

function PlayerPlaneOperator:setBetChip(plane,value,flag)
	if tolua.isnull(plane) then
		return
	end
	UserInfoPlaneOperator:setBetChip(plane,value,flag)
end

function PlayerPlaneOperator:setTotalBetChip(plane,value,flag)
	UserInfoPlaneOperator:setTotalBetChip(plane,value,flag)
end

function PlayerPlaneOperator:showBetEffect(playerType,value)
	local plane = self:getPlayerPlane(playerType)
	UserInfoPlaneOperator:showBetEffect(plane,value)
end
function PlayerPlaneOperator:setTextNmuber(plane,value)
	if tolua.isnull(plane) then
		return
	end
	UserInfoPlaneOperator:setTextNmuber(headplane,value)
end

function PlayerPlaneOperator:clearGameDatas(playerType,plane,stage)
	if tolua.isnull(plane) then
		return
	end
	local handCardPlane = plane:getChildByName("handcard_plane")
	handCardPlane:hide()
	CardPlaneOperator:clearGameDatas(playerType,plane,stage)
	UserInfoPlaneOperator:clearGameDatas(playerType,plane,stage)

end

function PlayerPlaneOperator:showPlayerInfo(playerType,plane,userInfo,seat)
	dump(plane,"yiy888888")
	if tolua.isnull(plane) then
		return
	end
	plane:setVisible(true)

   	return UserInfoPlaneOperator:showPlayerInfo(playerType,plane,userInfo,seat)
end

function PlayerPlaneOperator:showMyPlayerInfo(playerType,plane,userInfo,no,pwd)
	if tolua.isnull(plane) then
		return
	end
    return UserInfoPlaneOperator:showMyPlayerInfo(plane,userInfo,no,pwd)
end
function PlayerPlaneOperator:updateTableNoTotal(plane, chip)
    local total_plane = plane:getChildByName("total_plane")
    UserInfoPlaneOperator:updateTableNoTotal(total_plane, chip)
end
function PlayerPlaneOperator:updateCoin(plane,value,orichip)
	UserInfoPlaneOperator:updateCoin(plane,value,orichip)
end

function PlayerPlaneOperator:setCoin(plane,value)
	if tolua.isnull(plane) then
		return
	end
	UserInfoPlaneOperator:setCoin(plane,value)
end

function PlayerPlaneOperator:setMyCoin(plane,value)
	if tolua.isnull(plane) then
		return
	end
    UserInfoPlaneOperator:setMyCoin(plane,value)
end

function PlayerPlaneOperator:showHeadSymbol(plane,_type,flag)

	UserInfoPlaneOperator:showHeadSymbol(plane,_type,flag)
end

function PlayerPlaneOperator:setGrabBankerSymbol(plane,flag)
	UserInfoPlaneOperator:setGrabBankerSymbol(plane,flag)
end

function PlayerPlaneOperator:setBetTimes(plane,times,flag)
	UserInfoPlaneOperator:setBetTimes(plane,times,flag)
end

function PlayerPlaneOperator:setGrabBankerTimes(plane,times,flag)
	UserInfoPlaneOperator:setGrabBankerTimes(plane,times,flag)
end

function PlayerPlaneOperator:setReadyStatus(plane,flag)
    UserInfoPlaneOperator:showHeadSymbol(plane, "room_rd", flag)
end

function PlayerPlaneOperator:setEffectFrame(playerType,plane,_type,flag)
	if  plane then
		UserInfoPlaneOperator:setEffectFrame(playerType,plane,_type,flag)
	end
end

function PlayerPlaneOperator:beginPlayCard(plane,flag)
    UserInfoPlaneOperator:beginPlayCard(plane,flag)
end
function PlayerPlaneOperator:showCardsBack(plane,callback,cards)
	if tolua.isnull(plane) then
		return
	end
	local handCardPlane = plane:getChildByName("back_vw")
	handCardPlane:setLocalZOrder(88)
	CardPlaneOperator:showCardsBack(handCardPlane,callback,cards)
end
function PlayerPlaneOperator:countFanAndShow(plane)
	local handCardPlane = plane:getChildByName("handcard_plane")
	CardPlaneOperator:countFanAndShow(handCardPlane)
end

function PlayerPlaneOperator:showCuoPai(cards,flag)
	CardPlaneOperator:showCuoPai(cards,flag)
end

function PlayerPlaneOperator:showCardKind(playerType,plane,cardKind,type,isSound)

	local handCardPlane = plane:getChildByName("handcard_plane")
	CardPlaneOperator:showCardKind(playerType,handCardPlane,cardKind,type,isSound)
end

function PlayerPlaneOperator:showCards(cardSpcardtype, cards)
	-- local handCardPlane = plane:getChildByName("handcard_plane")
	CardPlaneOperator:showCards(cardSpcardtype, cards)
end

function PlayerPlaneOperator:showEachPiersCards(pierIndex, cards, cardType)
	CardPlaneOperator:showEachPiersCards(pierIndex, cards, cardType)
end

function PlayerPlaneOperator:showThreePiersCards(playerType,plane,cards,flag)
	if tolua.isnull(plane) then
		return
	end
	local handCardPlane = plane:getChildByName("handcard_plane")
	CardPlaneOperator:showThreePiersCards(playerType,handCardPlane,cards,flag)
end


function PlayerPlaneOperator:showAllCards(playerType,plane,cards,cardEndIndex,flag,cardType)
	if tolua.isnull(plane) then
		return
	end
	local handCardPlane = plane:getChildByName("handcard_plane")
	CardPlaneOperator:showAllCards(playerType,handCardPlane,cards,cardEndIndex,flag,cardType)
end

function PlayerPlaneOperator:showDealCardsAnimation(playerType,plane,cards,cardEndIndex)
	if tolua.isnull(plane) then
		return
	end
	local handCardPlane = plane:getChildByName("handcard_plane")
	CardPlaneOperator:showDealCardsAnimation(playerType,handCardPlane,cards,cardEndIndex)
end

function PlayerPlaneOperator:foldCard(playerType,plane,cards)
	if tolua.isnull(plane) then
		return
	end
	local handCardPlane = plane:getChildByName("handcard_plane")
	CardPlaneOperator:foldCard(playerType,handCardPlane,cards)
end

function PlayerPlaneOperator:clearCardPlane(playerType,plane)
	if tolua.isnull(plane) then
		return
	end
	local handCardPlane = plane:getChildByName("handcard_plane")
	CardPlaneOperator:clearCardPlane(playerType,handCardPlane)
end

function PlayerPlaneOperator:setCardType()
	CardPlaneOperator:setCardType()
end

function PlayerPlaneOperator:outCards(plaeryType, plane, flag, cards)
	if tolua.isnull(plane) then
		return
	end
	-- local  handcard_plane =  plane:getChildByName("handcard_plane")
	CompCardLayer:outCards(plaeryType, plane, flag, cards)
end



function PlayerPlaneOperator:claerAllPlane()
	CompCardLayer:claerAllPlane()
end

function PlayerPlaneOperator:showActionTypeCard(plaeryType,plane,data, indexData)
    if tolua.isnull(plane) then
        return
    end
    local  handcard_plane =  plane:getChildByName("handcard_plane")
    CardPlaneOperator:showActionTypeCard(plaeryType, handcard_plane, data, indexData)
end
function PlayerPlaneOperator:showActionChips(plaeryType,plane,chip, indexData)
	if tolua.isnull(plane) then
		return
	end
	local  handcard_plane =  plane:getChildByName("handcard_plane")
	CardPlaneOperator:showActionChips(plaeryType, handcard_plane, chip, indexData)
end



function PlayerPlaneOperator:operationCardZhong(plaeryType, plane, flag, isOpen)
	if tolua.isnull(plane) then
		return
	end
	UserInfoPlaneOperator:operationCardZhong(plane, flag, isOpen)
end

function PlayerPlaneOperator:setPlayerScore(plane, score, isPlus)
	if tolua.isnull(plane) then
		return
	end
	UserInfoPlaneOperator:setPlayerScore(plane, score, isPlus)
end

function PlayerPlaneOperator:showCheatSurpCards(cards)
	CardPlaneOperator:showCheatSurpCards(cards)
end

return PlayerPlaneOperator