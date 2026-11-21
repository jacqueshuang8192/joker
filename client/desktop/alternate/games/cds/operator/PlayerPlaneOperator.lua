--
-- Author: Your Name
-- Date: 2017-09-05 19:21:38
--
local  PlayerPlaneOperator = class("PlayerPlaneOperator")

local  UserInfoPlaneOperator = require(TpackageName .. ".operator.UserInfoPlaneOperator")

local  PLAYER_PLANE_TABLE = {}


function PlayerPlaneOperator:init(total_playernum)

	PLAYER_PLANE_TABLE={
					[CARD_PLAYERTYPE_1] = CDS_GAME_SCENE:getChildByName("player_plane_1")
				}

	self:initPlayer(CARD_PLAYERTYPE_1) --刷新自己的

	for playerType = 1,total_playernum -1 do  --刷新头顶的头像
		local img = self:initPlayerHeadImg(playerType)
		table.insert(PLAYER_PLANE_TABLE,img)
	end

end

function PlayerPlaneOperator:initPlayerHeadImg(playerType)
	local game_plane = CDSPanel.game_plane
	local panel = game_plane.Image_head_left
	
	if playerType%2 == 0 then  --右边
		panel = game_plane.Image_head_right
	end

	local headPanel = panel:getChildByName("Panel_1")
	local headimg = headPanel:getChildByName("head_img_"..playerType)
	headimg:setVisible(false)

end

function PlayerPlaneOperator:setPlayerHeadImg(playerType,userInfo)
	local game_plane = CDSPanel.game_plane
	local panel = game_plane.Image_head_left
	
	if playerType%2 == 0 then  --右边
		panel = game_plane.Image_head_right
	end

	local headPanel = panel:getChildByName("Panel_1")
	local headimg = headPanel:getChildByName("head_img_"..playerType)
	if not headimg then
		return
	end
	
	headimg:setVisible(false)

	if userInfo then
		userInfo["icon_url"] = userInfo["icon_url"] or userInfo["portrait"] or DefaultHead_filePath
		-- dump(DefaultHead_filePath,"DefaultHead_filePath")
		-- dump(userInfo["portrait"],"portrait=====")
		-- dump(userInfo["icon_url"],"icon_url=======")

		local icon_url = userInfo.icon_url
	    local uid = userInfo.uid
	    local sex = userInfo.sex
	    local nickname = userInfo["nick"]
	    nickname = CDSUtils:formatNick(nickname, 4)
	    
		local size = headimg:getContentSize()
	    require("hall.GameCommon"):getUserHead(icon_url, uid, sex, headimg, size.width, false,nickname)
	    headimg:setVisible(true)
	else
		headimg:setVisible(false)
	end

    return headimg

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
end

function PlayerPlaneOperator:relocate(plane)
	if tolua.isnull(plane) then
		return
	end
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:relocate(headplane)
end
function PlayerPlaneOperator:hidePlayer(plane)
	local headplane = plane:getChildByName("head_plane")
	-- UserInfoPlaneOperator:hidePlayer(headplane)
end
function PlayerPlaneOperator:showPlayer(plane)
	if tolua.isnull(plane) then
		return
	end
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:showPlayer(headplane)
end

function PlayerPlaneOperator:switchMode(plane,_type)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:switchMode(headplane,_type)
end

function PlayerPlaneOperator:setBetChip(plane,value,flag)
	if tolua.isnull(plane) then
		return
	end
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:setBetChip(headplane,value,flag)
end

function PlayerPlaneOperator:setTotalBetChip(plane,value,flag)
	UserInfoPlaneOperator:setTotalBetChip(plane,value,flag)
end

function PlayerPlaneOperator:showBetEffect(playerType,value)
	local plane = self:getPlayerPlane(playerType)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:showBetEffect(headplane,value)
end
function PlayerPlaneOperator:setTextNmuber(plane,value)
	if tolua.isnull(plane) then
		return
	end
	local headplane = plane:getChildByName("head_plane")
	-- UserInfoPlaneOperator:setTextNmuber(headplane,value)
end

function PlayerPlaneOperator:clearGameDatas(playerType,plane,stage)
    
	if tolua.isnull(plane) then
		return
	end
	local headplane = plane:getChildByName("head_plane")
    UserInfoPlaneOperator:clearGameDatas(playerType,headplane,stage)
	local handCardPlane = plane:getChildByName("inhand_plane")
	plane:setLocalZOrder(88)

	UserInfoPlaneOperator:clearBetChip(plane)

end

function PlayerPlaneOperator:showPlayerInfo(playerType,plane,userInfo,seat)
	if tolua.isnull(plane) then
		return
	end
	plane:setVisible(true)

	local headplane = plane:getChildByName("head_plane")
   	return UserInfoPlaneOperator:showPlayerInfo(playerType,headplane,userInfo,seat)
end

function PlayerPlaneOperator:showMyPlayerInfo(playerType,plane,userInfo,no,pwd)
	
	if tolua.isnull(plane) then
		return
	end

	--将自己的数据存入表中------------

    CDS_SEAT_TABLE[userInfo.uid] = 1 --保存用户座位与id映射
    CDS_SEAT_TABLE_MAPPING[userInfo.uid] = 1
    SANGONG_UID_TABLE[1] = userInfo.uid  --保存用户id与座位映射

    CDS_PLAYERTYPE_TABLE[userInfo.uid] = playerType
    CDS_PLAYERTYPE_TABLE_MAPPING[userInfo.uid] = playerType

    ----------
	plane:setVisible(true)
    local headplane = plane:getChildByName("head_plane")
    return UserInfoPlaneOperator:showMyPlayerInfo(headplane,userInfo,no,pwd)
end

function PlayerPlaneOperator:updateTableNoTotal(plane, chip)
    local total_plane = plane:getChildByName("total_plane")
    UserInfoPlaneOperator:updateTableNoTotal(total_plane, chip)
end
function PlayerPlaneOperator:updateCoin(plane,value,orichip)
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:updateCoin(headplane,value,orichip)
end

function PlayerPlaneOperator:setCoin(plane,value)
	if tolua.isnull(plane) then
		return
	end
	local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:setCoin(headplane,value)
end

function PlayerPlaneOperator:setMyCoin(plane,value)
	if tolua.isnull(plane) then
		return
	end
    local headplane = plane:getChildByName("head_plane")
	UserInfoPlaneOperator:setCoin(headplane,value)
    -- UserInfoPlaneOperator:setMyCoin(headplane,value)
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

return PlayerPlaneOperator