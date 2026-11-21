local UserInfoPlaneOperator = class("UserInfoPlaneOperator")

function UserInfoPlaneOperator:init(plane)
	plane:setVisible(false)
	self:clearGameDatas(plane)
end

function UserInfoPlaneOperator:clearGameDatas(plane)
	local zhuang_signal = plane:getChildByName("zhuang_signal")

	zhuang_signal:setVisible(false)
	self:beginPlayCard(plane, false)
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

	local portrait = plane:getChildByName("portrait")
	local nick_lb = plane:getChildByName("nick_lb")
	local coins_lb = plane:getChildByName("coins_lb")

	local infos = {}
	infos["icon_url"] = photoUrl
	infos["uid"] = userInfo["uid"]
	infos["sex"] = userInfo["sex"]
	-- require("hall.GameCommon"):setPlayerHead(infos, portrait, 46)
	require("hall.GameCommon"):getUserHead(photoUrl, userInfo["uid"], userInfo["sex"], portrait, 64, false, nickname, false)
	

	nick_lb:setString(require("hall.GameCommon"):formatNick(nickname))

	-- require("hall.GameCommon"):formatLabelStr(nickname, nick_lb, nick_lb:getSize().width)
	-- coins_lb:setString(coins)
    self:updateUserCoins(plane, userInfo.coins)
	self:showNetworkImg(plane, false)
	return portrait
end

function UserInfoPlaneOperator:showZhuang(isShow, plane)
	local zhuang_signal = plane:getChildByName("zhuang_signal")

	zhuang_signal:setVisible(isShow)
end

function UserInfoPlaneOperator:getHeadNode(plane)
	return plane:getChildByName("portrait")
end

function UserInfoPlaneOperator:showNetworkImg(plane, flag)
	local network_img = plane:getChildByName("network_img")

	if network_img then
		network_img:setVisible(flag)
	end
end

function UserInfoPlaneOperator:beginPlayCard(plane, flag)
	local turn_img = plane:getChildByName("turn_img")
	if turn_img then
		if flag == true then
            turn_img:setVisible(true)
			local showTurnAc = cc.CallFunc:create(function()
				if turn_img:getOpacity() > 220 then		
					turn_img:fadeTo(1.3, 50)
				elseif turn_img:getOpacity()<80 then	
					turn_img:fadeTo(1.3, 255)
				end
			end)
			local seqAc = cc.Sequence:create(cc.DelayTime:create(1.3), showTurnAc)
			turn_img:runAction(cc.RepeatForever:create(seqAc))
		else
			turn_img:setVisible(false)
		end
	end
end


function UserInfoPlaneOperator:updateUserCoins(plane, coins)
    if not plane then
        return
    end
    dump("------------------------1111")
    local coins_lb = plane:getChildByName("coins_lb")
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