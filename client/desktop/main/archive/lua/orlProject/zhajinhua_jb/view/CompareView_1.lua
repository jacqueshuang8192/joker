local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local MenjiroomView   = import("zhajinhua_jb.view.MenjiroomView")
local CompareView   = class("CompareView", function()
	return display.newNode("CompareView")
end)

function CompareView:ctor()
	-- body
	self:setNodeEventEnabled(true)
end

function CompareView:clearActions()
	ZhaJinHuaPanel.comparePnl:hide()
end

function CompareView:initUI()
	local comparePnl = ZhaJinHuaPanel.comparePnl:hide()
	comparePnl:setLocalZOrder(9999)
	for i = 1, 2 do
		comparePnl["state_"..i]:hide()
		comparePnl["ArmatureNode_"..i]:hide()
		local cardsNode = comparePnl["cards_"..i]
		for i,node in ipairs(cardsNode:getChildren()) do
			node:removeAllChildren()
		end
	end

	if self.curScheduler then
		scheduler.unscheduleGlobal(self.curScheduler)
	end
end

function CompareView:onExit()
	if self.curScheduler then
		scheduler.unscheduleGlobal(self.curScheduler)
	end
end

--uid主动发起，c_uid被动比牌
function CompareView:showCampare(uid, c_uid, result, pack)
	SoundUtils:playEffectSound("zhajinhua_jb/res/audio/cmp.mp3")
	CompareView:initUI()
	local comparePnl = ZhaJinHuaPanel.comparePnl:show()
	local uids = {
		[1] = uid,
		[2] = c_uid,
	}
	local status = {
		[uid] = pack.uidLookCardStatus,
		[c_uid] = pack.buidLookCardStatus,
	}
	for i = 1, 2 do
		local uid = uids[i]
		local userInfo = ZJH_USERINFO_TABLE[uid]
		if not userInfo then break end
		local head = comparePnl["haed_"..i]
		local strNick = require("hall.GameCommon"):formatNick(userInfo.nickName)
		comparePnl["name_"..i]:setString(strNick)
		require("hall.GameCommon"):getUserHead(userInfo.photoUrl, "", "", head, head:getContentSize().width , false, "", true)
	end

	-- local function getVariety(card)
	-- 	return bit.band(card, 0xF0)
	-- end
	
	-- -- 获得牌值
	-- local function getValue(card)
	-- 	local value = bit.band(card, 0x0F)
	-- 	if value == 1 then
	-- 		value = 14
	-- 	end
	-- 	return value
	-- end
	
	self.curScheduler = scheduler.performWithDelayGlobal(function()
		for i = 1, 2 do
			local uid = uids[i]
			dump(bm.Room.show_cards)
			local cards = bm.Room.show_cards[uid]
			local cardsNode = comparePnl["cards_"..i]
			if not cards then 
				break 
			end
			if status[uid] == 1 then
				for i,node in ipairs(cardsNode:getChildren()) do
					local card = require(TpackageName..".common.PokerCard").new()
					local cardValue = cards[i]
					card:addTo(node)
					if cardValue then
						card:setCard(cardValue)
						card:showFront()
					end
					card:setPositionX(node:getContentSize().width/2)
				end
			end
			-- comparePnl["card_"..i]:setString(strNick)
			-- cc.p(cards:getContentSize().width/2+(j-1)*(width+10), 0))
		end

		local index = 1
		if result == 1 then --成功
			index = 2
		else
			index = 1
		end
		local anim = comparePnl["ArmatureNode_"..index]:getAnimation()
		comparePnl["ArmatureNode_"..index]:show()
		anim:playWithIndex(0, -1, 0) --第一个参数是动画表index 第二个是时间间隔第三个是是否循环
		function handler1(Armature, MovementEventType, handlerName)
			dump(MovementEventType)
			if MovementEventType == ccs.MovementEventType.complete then
				CompareView:initUI()
				MenjiroomView:CallBackCompare(uid, c_uid, result)
			end
		end
		comparePnl["state_"..index]:show()
		anim:setMovementEventCallFunc(handler1)
	end, 1)
end

return CompareView