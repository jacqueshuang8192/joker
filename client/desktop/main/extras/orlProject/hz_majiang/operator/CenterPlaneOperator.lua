local CenterPlaneOperator = class("CenterPlaneOperator")
local CONTROL_TIME_MAX = 5
local timer_value = 20

function CenterPlaneOperator:init(plane)
	plane:setVisible(false)
	self:clearGameDatas(plane)
end

function CenterPlaneOperator:stopZhiZhen( plane )
	local armatureObj = plane.zhizhenAnin
	armatureObj:stopAllActions()  
	local Animation = armatureObj:getAnimation()
	Animation:gotoAndPause(0)  
end

--指针
function CenterPlaneOperator:setZhiZhenAnim(plane, playerType)
	local type = "up"
	if playerType == CARD_PLAYERTYPE_MY then
		type = "down"
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		type = "left"
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		type = "right"
	elseif playerType == CARD_PLAYERTYPE_TOP then
		type = "up"
	end
    local zhizhenAnin = plane.zhizhenAnin
    zhizhenAnin:setVisible(true)
	local anim = zhizhenAnin:getAnimation()
	anim:playWithNames({type}, 0, true);
end


function CenterPlaneOperator:clearGameDatas(plane)
	local timer_lb = plane:getChildByName("timer_lb")
	timer_lb:setString("00")
	timer_lb:stopAllActions()
end

function CenterPlaneOperator:changeTurn(playerType, plane)
    self:setZhiZhenAnim(plane, playerType)

	local myplane = (plane:getParent()):getChildByName("my_card_plane")
	local alarm_clock = myplane:getChildByName("alarm_clock")
	local time = alarm_clock:getChildByName("time")
    if playerType == CARD_PLAYERTYPE_MY then
		local showTimerAc = cc.CallFunc:create(function()
		time:setString(timer_value )
		if timer_value == 0 then
			time:stopAllActions()
			alarm_clock:setVisible(false)
		end
		end)
		local seqAc = cc.Sequence:create(cc.DelayTime:create(1), showTimerAc)
	end

end

function CenterPlaneOperator:beginPlayCard(playerType, plane)
	self:changeTurn(playerType, plane)
	local timer_lb = plane:getChildByName("timer_lb")
	if not timer_lb then
		return
	end
	self:clearGameDatas(plane)
	timer_value = PLAY_CARD_TIME_MAX
	timer_lb:setString(timer_value )
	local showTimerAc = cc.CallFunc:create(function()
			timer_value = timer_value - 1
			local str = string.format("%02d",timer_value)
			timer_lb:setString(str)
			if timer_value == 0 then
				self:clearGameDatas(plane)
			end
		end)
	local seqAc = cc.Sequence:create(cc.DelayTime:create(1), showTimerAc)
	timer_lb:runAction(cc.RepeatForever:create(seqAc))

end

--旋转座位标志
function CenterPlaneOperator:rotateTimer(zhuang_index,plane)
	--重置标志器指向
	local location_plane = plane:getChildByName("location_plane")
	
    self:setZhiZhenAnim(plane, zhuang_index)
end

return CenterPlaneOperator