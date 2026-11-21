--
-- Author: Your Name
-- Date: 2017-09-05 19:57:49
--
local 	UserInfoPlaneOperator = class("UserInfoPlaneOperator")

function UserInfoPlaneOperator:init(headplane)

	headplane:setVisible(false)

	self:beginPlayCard(headplane, false)

	self:showRemainCardsNum(headplane, 0, false)
	self:showLandLord(headplane, nil, "clear")
	self:showNetworkImg(headplane,false)
	self:setDoubleFlag(headplane,1,false)
	self:showAlarm(headplane, false)
	self:setScore(headplane, "bonus", 0)
	local  chips = headplane:getChildByName("chips"):setVisible(false)
	
	--headplane:getChildByName("img_bonus"):setVisible(false)
	--headplane:getChildByName("txt_bonus"):setVisible(false)
	headplane:getChildByName("txt_bonus"):setString('0')
end

function UserInfoPlaneOperator:clearGameDatas(playerType, headplane)

	self:showLandLord(headplane, nil, "clear")
	self:setDoubleFlag(headplane, 1, false)
	self:showRemainCardsNum(headplane, 0, false)
	self:showAlarm(headplane, false)
	self:clearUserDesk(playerType, headplane)
	self:setScore(headplane, "bonus", 0)
end

function UserInfoPlaneOperator:addScore(headplane, typ, score)
	local txt = headplane:getChildByName(typ == "bonus" and "txt_bonus") 
	print("addScore", txt:getName(), score, tonumber(txt:getString()) + score)
	self:setScore(headplane, typ, tonumber(txt:getString()) + score)
end

function UserInfoPlaneOperator:setScore(headplane, typ, score)
	local txt = headplane:getChildByName(typ == "bonus" and "txt_bonus") 
	print("setScore", txt:getName(), score)
	txt:setString(tostring(score))
end

function UserInfoPlaneOperator:clearUserDesk(playerType, headplane)

    if layout_ui:getChildByName("tt"..tostring(playerType)) then
        layout_ui:removeChildByName("tt"..tostring(playerType))
    end

    if cardScene:getChildByName("clock") then
        cardScene:getChildByName("clock"):setVisible(false)
    end

end

function UserInfoPlaneOperator:removePlayer(playerType, headplane)
	headplane:setVisible(false)
	self:clearGameDatas(playerType, headplane)
end

function UserInfoPlaneOperator:showAlarm(headplane, flag, playerType)
	--print('----',debug.traceback()) 
    local alarm = headplane:getChildByName("baojing") 

    if flag == false then
    	flag = false 
    else
    	flag = true
    end

    if alarm then
        alarm:setVisible(flag)
    else
        local s = 0.3
        alarm = require("qs510k.Animation"):Alarm()
        alarm:addTo(headplane)
        alarm:setName("baojing")
        alarm:setScale(s)
        alarm:setVisible(flag)
		
		local alarmpos = headplane:getChildByName("baojingpos") 
        alarm:setPosition(alarmpos:getPosition())
    end

end

function UserInfoPlaneOperator:showPlayerInfo(playerType,headplane,userInfo)
	--dump(userInfo, "userInfo")

	local uid = userInfo["uid"]
	local icon_url = userInfo["icon_url"]
	local sex = userInfo["sex"] 
    local coins = userInfo["coins"] 
    local head = headplane:getChildByName("head")
    local headMode = headplane:getChildByName("headMode")
    local nickName = userInfo["nick"] --and require("hall.GameCommon"):formatNick(userInfo["nick"], 5) or "未知昵称"
	local ip = userInfo["ip"]
	local addres = userInfo["addres"]
	--print('--showPlayerInfo--',debug.traceback())

	--dump(userInfo, 'userInfo')
	local latitude = userInfo.latitude
	local longitude = userInfo.longitude
	ReqMgr:getAddress( latitude, longitude, uid )

	local txt_nick = headplane:getChildByName("nickName_txt")
	txt_nick:setString(require("hall.GameCommon"):formatNick(nickName))
	if GAME_MODE == 0 then
		headMode:setVisible(false)
    	require("hall.GameCommon"):getUserHead(icon_url, uid, sex, head, 64 , false, nickName, false, ip,addres)
    else
    	--黑夜模式  固定头像和昵称
    	txt_nick:setString("黑衣人")
    	head:setVisible(false)
    	--headMode:setTexture("qs510k/newImages/head.png")
    end
	headplane:setVisible(true)
	headplane.uid = uid



	self:updateUserCoins(headplane , coins)


	return head
end

function UserInfoPlaneOperator:updateUserCoins(plane, coins)
    if not plane then
        return
    end

    coins = coins/100
    dump("------------------------1111")
    local coins_lb = plane:getChildByName("gold_mine")
    local coins_str = coins
    if coins > 100000 then
        --coins = math.floor(coins / 10000)
        dump(coins, "-------------2222")
        coins_str = string.format("%.1f", coins / 10000) .. "万"
    end
    dump(coins_str, "----------3333")
    coins_lb:setString(coins_str)
end

function UserInfoPlaneOperator:showLandLord(headplane,_type,flag)
	local landlord_flag = headplane:getChildByName("landlord_flag")
	local ass_flag = headplane:getChildByName("ass_flag")

    if flag == "clear" then
    	landlord_flag:setVisible(false)
		ass_flag:setVisible(false)
    elseif _type == "LandLord" then
    	landlord_flag:setVisible(true)
		landlord_flag:loadTexture("qs510k/images/help.png")
        -- landlord_flag:setContentSize(cc.size(65,68))
	elseif _type == "Farmer" then
		landlord_flag:setVisible(false)
        -- landlord_flag:loadTexture("qs510k/images/Img_GameTable_Farmer.png")
        -- landlord_flag:setContentSize(cc.size(41,42))
    elseif _type == "Banker" then
    	landlord_flag:setVisible(true)
    	landlord_flag:loadTexture("qs510k/images/banker.png")
	elseif _type == "du" then
		landlord_flag:setVisible(true)
		landlord_flag:loadTexture("qs510k/images/du.png")
	elseif _type == 'ass' then
		ass_flag:setVisible(true)
	end
end

function UserInfoPlaneOperator:showNetworkImg(headplane, flag)
	local network_img = headplane:getChildByName("network_img")
	if network_img then
    	dump(flag,"是否显示断线图片2")
		network_img:setVisible(flag)
	end
end

function UserInfoPlaneOperator:updateCoin(playerType, headplane, value)

	local coin_lb = headplane:getChildByName("gold_mine")

	if coin_lb then
		coin_lb:setVisible(true)
		coin_lb:setString(require(NumberUtil_filePath):toWan(value/100, 99999, "w"))
	end

    if  isGoldGame == 0 then
        local uid = headplane.uid
        if  uid and require("hall.view.userInfoView.userInfoView").upDateUserInfo then
            require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,{["gold"] = value},"gold")
        end
    end

end

function UserInfoPlaneOperator:updateBombFen(headplane, value)
	headplane:getChildByName("txt_bonus"):setString(tostring(value))
end

function UserInfoPlaneOperator:updateAuto(headplane, value)
	headplane:getChildByName("tuoguan"):setVisible(value == 1 and true or false)
end

function UserInfoPlaneOperator:userRank(headplane, value)
	if value > 0 then
		headplane:getChildByName("gamewin"):setVisible(true)
		headplane:getChildByName("gamewin"):setTexture("qs510k/newImages/win_" .. value ..".png")
	else
		headplane:getChildByName("gamewin"):setVisible(false)
	end
end

function UserInfoPlaneOperator:setDoubleFlag(headplane, times, flag)
	local txt_player_double = headplane:getChildByName("txt_player_double")
	if txt_player_double then
		txt_player_double:setVisible(flag)
	end
end


function UserInfoPlaneOperator:showRemainCardsNum(headplane, value, flag)
	local cardNumBack = headplane:getChildByName("cardNumBack")

	if cardNumBack then
		cardNumBack:setVisible(flag)
		if value then
			local cardNum_txt = cardNumBack:getChildByName("cardNum")
			cardNum_txt:setVisible(true)
			cardNum_txt:setString(value)
		else
			cardNumBack:getChildByName("cardNum"):setVisible(false)
		end
	end
end



function UserInfoPlaneOperator:beginPlayCard(headplane, flag)

	local img = headplane:getChildByName("turn_img")
     
	if img then
		if flag ==true then
            img:setVisible(true)

			local showTurnAc = cc.CallFunc:create(function()
					if  img:getOpacity() > 220 then		
						img:fadeTo(1.3, 50)

					elseif img:getOpacity()<80 then	
						img:fadeTo(1.3, 255)
					end

				end)

			seqAc = cc.Sequence:create(cc.DelayTime:create(1.3), showTurnAc)
			img:runAction(cc.RepeatForever:create(seqAc))

		else
			img:stopAllActions()
		 	img:setVisible(false)
		end
	end
end

return  UserInfoPlaneOperator
