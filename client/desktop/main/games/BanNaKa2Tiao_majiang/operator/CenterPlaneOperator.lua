local CenterPlaneOperator = class("CenterPlaneOperator")
local PLAY_CARD_TIME_MAX = 20
local CONTROL_TIME_MAX = 5
local timer_value = 20

local voiceUtils = require(TpackageName..".utils.VoiceUtils")

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

function CenterPlaneOperator:showPaiXing(plane,paixingList)

	if table.getn(paixingList) <= 0 then
		return;
	end

	--local hasPaiXingList = {18, 6, 22, 7, 8, 9, 10}
	--local allHas = true; --是不是所有的牌型都存在
	--for k,v in ipairs(paixingList) do
	--	local flag = false
	--	for j,k in ipairs(hasPaiXingList) do
	--		if k == v then
	--			flag = true
	--		end
	--	end
	--	if not flag then
	--		allHas = false;
	--	end
	--end

	local allHas = true
	if allHas then
		-- 如果是一个 x: 206 y: 80
		-- 如果是两个 x1: 120 y1: 105 x2:270 y2:28
		-- 如果是两个 x1: 208 y1: 112 x2:78 y2:24 x3: 333 y3: 24
		local paixing_bg = plane:getChildByName("paixing_bg")
		if paixing_bg then
			local paixing_1 = paixing_bg:getChildByName("paixing_1")
			local paixing_2 = paixing_bg:getChildByName("paixing_2")
			local paixing_3 = paixing_bg:getChildByName("paixing_3")
			paixing_1:setVisible(false);
			paixing_2:setVisible(false);
			paixing_3:setVisible(false);

			if table.getn(paixingList) == 1 then
				paixing_1:setPosition(206, 80);
				paixing_1:loadTexture(TpackageName .. "/res/image/paixing/paixing_" .. paixingList[1] .. '.png');
				paixing_1:setVisible(true)

				paixing_1:runAction(transition.sequence({
					cc.DelayTime:create(0.5),
					cc.CallFunc:create(function()

						voiceUtils:playEffectHuPaiType(0, paixingList[1]);

					end),
				}))
			end

			if table.getn(paixingList) == 2 then
				paixing_1:setPosition(120, 105);
				paixing_1:loadTexture(TpackageName .. "/res/image/paixing/paixing_" .. paixingList[1] .. '.png');
				paixing_2:setPosition(270, 28);
				paixing_2:loadTexture(TpackageName .. "/res/image/paixing/paixing_" .. paixingList[2] .. '.png');
				paixing_1:setVisible(true)
				paixing_2:setVisible(true)

				paixing_1:runAction(transition.sequence({
					cc.DelayTime:create(0.5),
					cc.CallFunc:create(function()

						voiceUtils:playEffectHuPaiType(0, paixingList[1]);
						paixing_1:runAction(transition.sequence({
							cc.DelayTime:create(1),
							cc.CallFunc:create(function()
								voiceUtils:playEffectHuPaiType(0, paixingList[2]);
							end),
						}))

					end),
				}))
			end

			if table.getn(paixingList) == 3 then
				paixing_1:setPosition(208, 112);
				paixing_1:loadTexture(TpackageName .. "/res/image/paixing/paixing_" .. paixingList[1] .. '.png');
				paixing_2:setPosition(78, 24);
				paixing_2:loadTexture(TpackageName .. "/res/image/paixing/paixing_" .. paixingList[2] .. '.png');
				paixing_3:setPosition(333, 24);
				paixing_3:loadTexture(TpackageName .. "/res/image/paixing/paixing_" .. paixingList[3] .. '.png');
				paixing_1:setVisible(true)
				paixing_2:setVisible(true)
				paixing_3:setVisible(true)

				paixing_1:runAction(transition.sequence({
					cc.DelayTime:create(0.5),
					cc.CallFunc:create(function()

						vvoiceUtils:playEffectHuPaiType(0, paixingList[1]);
						paixing_1:runAction(transition.sequence({
							cc.DelayTime:create(1),
							cc.CallFunc:create(function()
								voiceUtils:playEffectHuPaiType(0, paixingList[2]);
							end),
						}))

						paixing_2:runAction(transition.sequence({
							cc.DelayTime:create(2),
							cc.CallFunc:create(function()
								voiceUtils:playEffectHuPaiType(0, paixingList[3]);
							end),
						}))

					end),
				}))
			end

			paixing_bg:setVisible(true)
		end
	end

end

function CenterPlaneOperator:hidePaiXing(plane)

	local paixing_bg = plane:getChildByName("paixing_bg")
	if paixing_bg then
		local paixing_1 = paixing_bg:getChildByName("paixing_1")
		local paixing_2 = paixing_bg:getChildByName("paixing_2")
		local paixing_3 = paixing_bg:getChildByName("paixing_3")
		paixing_1:setVisible(false)
		paixing_2:setVisible(false)
		paixing_3:setVisible(false)
		paixing_bg:setVisible(false)
	end

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