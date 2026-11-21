local UserInfoPlaneOperator = class("UserInfoPlaneOperator")

local CHILD_NAME_PORTRAIT = "portrait"
local CHILD_NAME_NICK = "nick_lb"
local CHILD_NAME_COINS = "coins_lb"
local CHILD_NAME_ZHUANG_SIGNAL = "zhuang_signal"
local CHILD_NAME_NETWORK_IMG = "network_img"

function UserInfoPlaneOperator:init(plane)
	plane:setVisible(false)

	local zhuang_signal = plane:getChildByName(CHILD_NAME_ZHUANG_SIGNAL)

	zhuang_signal:setVisible(false)
end

function UserInfoPlaneOperator:clearGameDatas(plane)
	local zhuang_signal = plane:getChildByName(CHILD_NAME_ZHUANG_SIGNAL)

	zhuang_signal:setVisible(false)
end

function UserInfoPlaneOperator:showInfo(userInfo, plane)
	if not plane then
		--todo
		return
	end

	plane:setVisible(true)

	local photoUrl = userInfo["photoUrl"]
	local nickname = userInfo["nick"]
	local coins = userInfo["coins"]

	local portrait = plane:getChildByName(CHILD_NAME_PORTRAIT)
	local nick_lb = plane:getChildByName(CHILD_NAME_NICK)
	local coins_lb = plane:getChildByName(CHILD_NAME_COINS)

	local infos = {}
	infos["icon_url"] = photoUrl
	infos["uid"] = userInfo["uid"]
	infos["sex"] = userInfo["sex"]
	infos["nick"] = userInfo["nick"]
	--require("hall.GameCommon"):setPlayerHead(infos, portrait, 46)

	nick_lb:setString(require("hall.GameCommon"):formatNick(nickname))
	dump(tolua.type(portrait),"portrait --2")
	local   worldpoint = (portrait:getParent()):convertToWorldSpace(portrait:getPosition()) --这样写是为了贴近函数的原始用法


	PLAYER_HEADS_POSITION_TABLE[userInfo["uid"]] = worldpoint
	require("hall.GameCommon"):getUserHead(photoUrl, userInfo["uid"], userInfo["sex"], portrait, 64, false,userInfo["nick"])
	-- require("hall.GameCommon"):formatLabelStr(nickname, nick_lb, nick_lb:getSize().width)
	coins = tonumber(coins)/100
	coins_lb:setString(coins)
	self:showNetworkImg(plane, false)
	local updateUserInfoData = {}

	updateUserInfoData["latitude"] = userInfo["latitude"] or ""
	updateUserInfoData["longitude"] = userInfo["longitude"] or ""
	updateUserInfoData["ip"] = userInfo["ip"] or ""
	updateUserInfoData["invote_code"] = USER_INFO["invote_code"]
	updateUserInfoData["nickName"] = nickname or ""
	dump(updateUserInfoData,"updateUserInfoData")
	require("hall.view.userInfoView.userInfoView"):upDateUserInfo(userInfo.uid,updateUserInfoData)

end

function UserInfoPlaneOperator:showZhuang(isShow, plane)
	local zhuang_signal = plane:getChildByName(CHILD_NAME_ZHUANG_SIGNAL)

	zhuang_signal:setVisible(isShow)
end

function UserInfoPlaneOperator:getHeadNode(plane)
	return plane:getChildByName(CHILD_NAME_PORTRAIT)
end

function UserInfoPlaneOperator:showNetworkImg(plane, flag)
	local img = plane:getChildByName(CHILD_NAME_NETWORK_IMG)

	if img then
		--todo
		img:setVisible(flag)
	end
end

function UserInfoPlaneOperator:beginPlayCard(plane, flag)
	local img = plane:getChildByName("turn_img")
     
	if img then
		if flag ==true then
            img:setVisible(true)

			local showTurnAc = cc.CallFunc:create(function()
					if img:getOpacity() > 220 then		
						img:fadeTo(1.3, 50)

					elseif img:getOpacity()<80 then	
						img:fadeTo(1.3, 255)
					end

				end)

			seqAc = cc.Sequence:create(cc.DelayTime:create(1.3), showTurnAc)
			img:runAction(cc.RepeatForever:create(seqAc))

		else
		 	img:setVisible(false)
		end
	end
end


return UserInfoPlaneOperator