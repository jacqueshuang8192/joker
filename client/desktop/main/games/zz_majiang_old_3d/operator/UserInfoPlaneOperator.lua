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

	local turn_img = plane:getChildByName("turn_img")
    turn_img:setVisible(true)
	turn_img:stopAllActions()
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
	-- require("hall.GameCommon"):setPlayerHead(infos, portrait, 46)
	require("hall.GameCommon"):getUserHead(photoUrl, userInfo["uid"], userInfo["sex"], portrait, 64, false, nickname)
	

	nick_lb:setString(require("hall.GameCommon"):formatNick(nickname))

	-- require("hall.GameCommon"):formatLabelStr(nickname, nick_lb, nick_lb:getSize().width)
	-- coins_lb:setString(coins)
    self:updateUserCoins(plane, userInfo.coins)
	self:showNetworkImg(plane, false)
	return portrait
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

			local seqAc = cc.Sequence:create(cc.DelayTime:create(1.3), showTurnAc)
			img:runAction(cc.RepeatForever:create(seqAc))

		else
		 	img:setVisible(false)
		end
	end
end


function UserInfoPlaneOperator:updateUserCoins(plane, coins)
    if not plane then
        return
    end
    dump("------------------------1111")
    local coins_lb = plane:getChildByName(CHILD_NAME_COINS)
    local coins_str = coins/100
    if coins_str > 100000 then
        --coins = math.floor(coins / 10000)
        dump(coins_str, "-------------2222")
        coins_str = string.format("%.1f", coins_str / 10000) .. "万"
    end
    dump(coins_str, "----------3333")
    coins_lb:setString(coins_str)
end

return UserInfoPlaneOperator