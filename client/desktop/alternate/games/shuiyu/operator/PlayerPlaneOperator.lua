--
-- Author: Your Name
-- Date: 2017-09-05 19:21:38
--
local  PlayerPlaneOperator = class("PlayerPlaneOperator")

local  UserInfoPlaneOperator = require(TpackageName .. ".operator.UserInfoPlaneOperator")
local  CardPlaneOperator = require(TpackageName .. ".operator.CardPlaneOperator")



local  PLAYER_PLANE_TABLE = {}
local  PLAYER_SEAT_BTN_TABLE = {}
function PlayerPlaneOperator:initLayout()

	-- local six_people_player_plane = cc.CSLoader:createNode(TpackageName.."/csb/six_people_player_plane.csb")
	-- :addTo(NIUNIU_GAME_SCENE):setName("six_people_player_plane")
	-- local eight_people_player_plane = cc.CSLoader:createNode(TpackageName.."/csb/eight_people_player_plane.csb")
	-- :addTo(NIUNIU_GAME_SCENE):setName("eight_people_player_plane")
	-- local ten_people_player_plane = cc.CSLoader:createNode(TpackageName.."/csb/ten_people_player_plane.csb")
	-- :addTo(NIUNIU_GAME_SCENE):setName("ten_people_player_plane")

	-- six_people_player_plane:setVisible(false)
	-- eight_people_player_plane:setVisible(false)
	-- ten_people_player_plane:setVisible(false)
end

function PlayerPlaneOperator:init(total_playernum)
	print("=======555555555=======")
	print("=======555555555=======")
	print("=======555555555=======")
	print("=======555555555=======")
	print("=======555555555=======")
	print("=======555555555=======")
	print("=======555555555=======")
	print("=======555555555=======")
	print("====total_playernum====",total_playernum)
	local allPlayersPlane 
	if  total_playernum == 7 then
		allPlayersPlane = NIUNIU_GAME_SCENE:getChildByName("six_people_player_plane")

		-- or cc.CSLoader:createNode(TpackageName.."/csb/six_people_player_plane.csb")
		or cc.CSLoader:createNode(TpackageName.."/csb/seven_people_player_plane.csb")
		:addTo(NIUNIU_GAME_SCENE):setName("six_people_player_plane")

	elseif  total_playernum == 9 then
		allPlayersPlane = NIUNIU_GAME_SCENE:getChildByName("eight_people_player_plane")
		
		-- or cc.CSLoader:createNode(TpackageName.."/csb/eight_people_player_plane.csb")
		or cc.CSLoader:createNode(TpackageName.."/csb/nine_people_player_plane.csb")
		:addTo(NIUNIU_GAME_SCENE):setName("eight_people_player_plane")
	else
		allPlayersPlane = NIUNIU_GAME_SCENE:getChildByName("ten_people_player_plane")
		
		-- or cc.CSLoader:createNode(TpackageName.."/csb/ten_people_player_plane.csb")
		or cc.CSLoader:createNode(TpackageName.."/csb/twelve_people_player_plane.csb")
		:addTo(NIUNIU_GAME_SCENE):setName("ten_people_player_plane")
	end

	-- total_playernum = 12
	--暂时先用7个人的
	TOTAL_PLAYERNUM = total_playernum
	
	allPlayersPlane:setVisible(true)

	PLAYER_PLANE_TABLE={[CARD_PLAYERTYPE_MY] = allPlayersPlane:getChildByName("player_plane_1"),

					[CARD_PLAYERTYPE_LEFT1]  = allPlayersPlane:getChildByName("player_plane_2"),
					[CARD_PLAYERTYPE_LEFT2]  = allPlayersPlane:getChildByName("player_plane_3"),
					[CARD_PLAYERTYPE_LEFT3]  = allPlayersPlane:getChildByName("player_plane_4"),

					[CARD_PLAYERTYPE_TOP1]   = allPlayersPlane:getChildByName("player_plane_5"),
					[CARD_PLAYERTYPE_TOP2]   = allPlayersPlane:getChildByName("player_plane_6"),
					[CARD_PLAYERTYPE_TOP3]   = allPlayersPlane:getChildByName("player_plane_7"),

					[CARD_PLAYERTYPE_RIGHT1] = allPlayersPlane:getChildByName("player_plane_8"),
					[CARD_PLAYERTYPE_RIGHT2] = allPlayersPlane:getChildByName("player_plane_9"),
					[CARD_PLAYERTYPE_RIGHT3] = allPlayersPlane:getChildByName("player_plane_10"),
					[11] = allPlayersPlane:getChildByName("player_plane_11"),
					[12] = allPlayersPlane:getChildByName("player_plane_12"),

					["error"] = NIUNIU_GAME_SCENE:getChildByName("player_plane_for_error") }


	PLAYER_SEAT_BTN_TABLE={[1] = allPlayersPlane:getChildByName("player_head_1"),

					[2]  = allPlayersPlane:getChildByName("player_head_2"),
					[3]  = allPlayersPlane:getChildByName("player_head_3"),
					[4]  = allPlayersPlane:getChildByName("player_head_4"),

					[5]  = allPlayersPlane:getChildByName("player_head_5"),
					[6]  = allPlayersPlane:getChildByName("player_head_6"),
					[7]  = allPlayersPlane:getChildByName("player_head_7"),

					[8]  = allPlayersPlane:getChildByName("player_head_8"),
					[9]  = allPlayersPlane:getChildByName("player_head_9"),
					[10] = allPlayersPlane:getChildByName("player_head_10"),
					[11] = allPlayersPlane:getChildByName("player_head_11"),
					[12] = allPlayersPlane:getChildByName("player_head_12")}



	for playerType = 1,total_playernum do
		PLAYER_SEAT_BTN_TABLE[playerType]:setVisible(false)
		print("====playerType====",playerType,total_playernum)
		self:initPlayer(playerType)
		print("====game player init end====")
	end

	
	
end


function PlayerPlaneOperator:getPlayerPlane(playerType)
	return PLAYER_PLANE_TABLE[playerType] or PLAYER_PLANE_TABLE["error"]  --这个错误防止层是用在万一获取不到玩家层的情况下，有个承载操作的层
end

function PlayerPlaneOperator:getSeatBtnPlane( playerType )
	return PLAYER_SEAT_BTN_TABLE[playerType]
end

function PlayerPlaneOperator:removePlayer(playerType)
	self:initPlayer(playerType)
end

function PlayerPlaneOperator:initPlayer(playerType)
	local plane = self:getPlayerPlane(playerType)
	local headplane = plane:getChildByName("head_plane")
	local headSeatBtnPlane = self:getSeatBtnPlane(playerType)
    UserInfoPlaneOperator:init(playerType,headplane,headSeatBtnPlane)
	local handCardPlane = plane:getChildByName("inhand_plane")
	CardPlaneOperator:init(playerType,handCardPlane)

end

function PlayerPlaneOperator:relocate(plane)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:relocate(headplane)
end

function PlayerPlaneOperator:switchMode(plane,_type)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:switchMode(headplane,_type)
end

function PlayerPlaneOperator:swtichCardBackImg(typeIndex)
	CardPlaneOperator:swtichCardBackImg(typeIndex)
end

function PlayerPlaneOperator:setBetChip(plane,value,flag)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:setBetChip(headplane,value,flag)
end

function PlayerPlaneOperator:setTotalBetChip(plane,value,flag)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:setTotalBetChip(headplane,value,flag)
end

function PlayerPlaneOperator:showBetEffect(playerType,value)
	local plane = self:getPlayerPlane(playerType)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:showBetEffect(headplane,value)
end

function PlayerPlaneOperator:clearGameDatas(playerType,plane,stage)
	print("=====PlayerPlaneOperator:clearGameDatas====")
	local headplane = plane:getChildByName("head_plane")
    UserInfoPlaneOperator:clearGameDatas(playerType,headplane,stage)
	local handCardPlane = plane:getChildByName("inhand_plane")
	CardPlaneOperator:clearGameDatas(playerType,handCardPlane,stage)
end

function PlayerPlaneOperator:showPlayerInfo(playerType,plane,userInfo)

	if plane then
		local headplane = plane:getChildByName("head_plane")
   		return UserInfoPlaneOperator:showPlayerInfo(playerType,headplane,userInfo)
   	end
end

function PlayerPlaneOperator:updateCoin(plane,value,changedMoneyArr,orichip)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:updateCoin(headplane,value,changedMoneyArr,orichip)
end

function PlayerPlaneOperator:setCoin(plane,value)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:setCoin(headplane,value)
end

function PlayerPlaneOperator:showHeadSymbol(plane,_type,flag)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:showHeadSymbol(headplane,_type,flag)
end

function PlayerPlaneOperator:setGrabBankerSymbol(plane,flag)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:setGrabBankerSymbol(headplane,flag)
end

function PlayerPlaneOperator:setBetTimes(plane,times,flag)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:setBetTimes(headplane,times,flag)
end

function PlayerPlaneOperator:setGrabBankerTimes(plane,times,flag)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:setGrabBankerTimes(headplane,times,flag)
end

function PlayerPlaneOperator:setReadyStatus(plane,flag)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:setReadyStatus(headplane,flag)
end

function PlayerPlaneOperator:setEffectFrame(playerType,plane,_type,flag)
	if  plane then
		local headplane = plane:getChildByName("head_plane")
		UserInfoPlaneOperator:setEffectFrame(playerType,headplane,_type,flag)
	end
end

function PlayerPlaneOperator:beginPlayCard(plane,flag)
	local headplane = plane:getChildByName("head_plane")
    UserInfoPlaneOperator:beginPlayCard(headplane,flag)
end

function PlayerPlaneOperator:countFanAndShow(plane)
	local handCardPlane = plane:getChildByName("inhand_plane")
	CardPlaneOperator:countFanAndShow(handCardPlane)
end

function PlayerPlaneOperator:showCuoPai(cards,flag)
	CardPlaneOperator:showCuoPai(cards,flag)
end

function PlayerPlaneOperator:showCardKind(playerType,plane,cardKind1,cardKind2)
	local handCardPlane = plane:getChildByName("inhand_plane")
	CardPlaneOperator:showCardKind(playerType,handCardPlane,cardKind1,cardKind2)
end

function PlayerPlaneOperator:showCards(playerType,plane,cards,flag,isRelogin , status , card_state)
	local handCardPlane = plane:getChildByName("inhand_plane")
	CardPlaneOperator:showCards(playerType,handCardPlane,cards,flag,isRelogin , status , card_state)
end

function PlayerPlaneOperator:turnCards(plane)
	local handCardPlane = plane:getChildByName("inhand_plane")
	CardPlaneOperator:turnCards(handCardPlane)
end


function PlayerPlaneOperator:showDealCardsAnimation(playerType,plane,cards,cardEndIndex,isRelogin, cardState,cardIndex , status)
	local handCardPlane = plane:getChildByName("inhand_plane")
	CardPlaneOperator:showDealCardsAnimation(playerType,handCardPlane,cards,cardEndIndex,isRelogin, cardState,cardIndex , status)
end

function PlayerPlaneOperator:GetAllNode(playerType)
	return CardPlaneOperator:GetAllNode(playerType)
end

function PlayerPlaneOperator:foldCard(playerType,plane,cards)
	local handCardPlane = plane:getChildByName("inhand_plane")
	CardPlaneOperator:foldCard(playerType,handCardPlane,cards)
end

function PlayerPlaneOperator:outCard(playerType,plane,cards)
	local handCardPlane = plane:getChildByName("inhand_plane")
	CardPlaneOperator:outCard(playerType,handCardPlane,cards)
end

function PlayerPlaneOperator:SetAllNode(playerType , card)
    CardPlaneOperator:SetAllNode(playerType , card)
end 


function PlayerPlaneOperator:openCards(playerType,plane)
	local handCardPlane = plane:getChildByName("inhand_plane")
	CardPlaneOperator:openCards(playerType,handCardPlane)
end


return PlayerPlaneOperator