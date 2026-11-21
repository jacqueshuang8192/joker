local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local MenjiroomView   = import("FanSanPi.view.MenjiroomView")
local user_node_clone_f = nil
local user_node_clone_s = nil
local CompareView   = class("CompareView", function()
	return display.newNode("CompareView")
end)

local original_pos = {}
local card_orginal_pos = {}
local active_uid = nil
local compare_uid = nil
local compare_resutl = 1
local is_compare = false
local actions = {}
function CompareView:ctor()
	-- body
	self:setNodeEventEnabled(true)

end
function CompareView:runCompare(uid,c_uid,result, delay)
	is_compare = true
	-- body
	--uid主动发起，c_uid被动比牌
	active_uid = uid
	compare_uid = c_uid
	compare_resutl = result
	card_orginal_pos = {}

	if delay and delay == 1 then
		local user_node_f = MenjiroomView:getUserNode(uid)
		if user_node_f then
			user_node_f:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
				-- result 0:uid失败，1:uid获胜
				CompareView:transUserNode(active_uid, compare_uid)
				CompareView:moveUserNode()
			end)))
		end
	else
		CompareView:transUserNode(active_uid, compare_uid)
		CompareView:moveUserNode()
	end
end
-- function CompareView:showCampare(uid,c_uid,result, delay, uuid)
-- 	if is_compare == true then
-- 		local updateTime = 1

-- 		local updateCompaer = cc.CallFunc:create(function(value)
-- 			dump(value, "value======")
-- 			if is_compare == false then
-- 				if actions[uuid] then
-- 					FanSanPiPanel:stopAction(actions[uuid])
-- 					CompareView:runCompare(uid,c_uid,result, delay)
-- 				end
-- 			end
-- 		end)
-- 		local seqAc = cc.Sequence:create(updateCompaer,cc.DelayTime:create(updateTime))
-- 		local action = FanSanPiPanel:runAction(cc.RepeatForever:create(seqAc))
-- 		actions[uuid] = action
-- 	else
-- 		CompareView:runCompare(uid,c_uid,result, delay)
-- 	end


-- end

-- 转移玩家节点
function CompareView:transUserNode(uid, compare_uid)

	--复制两个玩家牌的节点
	local scenes  = FanSanPiPanel
	--	local node    = display.newLayer()

	local node    = scenes:getChildByName("zhezhao")

	if node then
		node:removeSelf()
	end
	node    = display.newNode()
	node:setVisible(true)
	node:setName("zhezhao")
	node:addTo(scenes,99999)
	--	node:setScale(1.333)

	local layer = cc.LayerColor:create(cc.c4b(0,0,0,110))
	layer:addTo(node)
	local user_node_f = MenjiroomView:getUserNode(uid)

	if user_node_f == nil then
		return false
	end

	dump(user_node_f:getContentSize(), "transUserNode user_node_f size", nesting)
	original_pos[1] = user_node_f:getPosition()
	if user_node_f:getAnchorPoint().x == 0 then
		original_pos[1].x = original_pos[1].x + user_node_f:getContentSize().width/2
		original_pos[1].y = original_pos[1].y + user_node_f:getContentSize().height/2
		user_node_f:setAnchorPoint(cc.p(0.5,0.5))
	end
	CompareView:resetUserNode(user_node_f, false, uid)


	user_node_f:setPosition(original_pos[1].x, original_pos[1].y)
	user_node_f:stopAllActions()

	user_node_clone_f = user_node_f

	local user_node_s = MenjiroomView:getUserNode(compare_uid)

	if user_node_s == nil then
		return false
	end

	original_pos[2] = user_node_s:getPosition()
	if user_node_s:getAnchorPoint().x == 0 then
		original_pos[2].x = original_pos[2].x + user_node_s:getContentSize().width/2
		original_pos[2].y = original_pos[2].y + user_node_s:getContentSize().height/2
		user_node_s:setAnchorPoint(cc.p(0.5,0.5))
	end

	CompareView:resetUserNode(user_node_s, false, compare_uid)
	--user_node_s:addTo(node, 20)
	user_node_s:setPosition(original_pos[2].x, original_pos[2].y)
	user_node_s:stopAllActions()
	user_node_clone_s = user_node_s
	for i = 1, 10 do
		if user_node_clone_f:getName() == "player_plane_"..i or user_node_clone_s:getName() == "player_plane_"..i then
			user_node_clone_f:setLocalZOrder(999999)
			user_node_clone_s:setLocalZOrder(999999)

		else
			scenes:getChildByName("player_plane_"..i):setLocalZOrder(9999)
		end

	end
	dump(original_pos, "transUserNode", nesting)

end

-- 是否传牌值进来
function CompareView:resetUserNode(node, is_show, uid, repleace_node)

	if node == nil then
		return
	end
	local flag = repleace_node or 1
	if flag == 1 then
		--node:retain()
		--node:removeSelf()
	end
	local bets = node:getChildByName("chip_bg")
	if bets then
		bets:setVisible(is_show)
	end
	local card_kan=node:getChildByName("card_kan")
	local  bi_back=node:getChildByName("chat")
	if bi_back then
		bi_back:removeSelf()
	end
	local btn_buy = node:getChildByName("btn_buy")
	if btn_buy then
		btn_buy:setVisible(is_show)
	end
	if card_kan~=nil then
		card_kan:removeSelf()
	end
	local kanpai = node:getChildByName("kanpai")
	if kanpai~=nil then
		kanpai:setVisible(is_show)
	end
	local card_node = node:getChildByName("card_node")
	if is_show == false then
		-- card_orginal_pos[uid] = {}
		-- -- table.insert(card_orginal_pos, {uid, {}})
		-- for i=0,2 do
		-- 	local card = card_node:getChildByName("card"..i)
		-- 	if card then
		-- 		card_orginal_pos[uid][i] = card:getPosition()
		-- 		local x = node:getPositionX() + i*20
		-- 		local y = node:getPositionY()
		-- 		local mt = cc.MoveTo:create(0.1, cc.p(x, y))
		-- 		card:runAction(mt)
		-- 		print("resetUserNode card", tostring(i), tostring(x), tostring(y))
		-- 	end
		-- end
		-- dump(card_orginal_pos, "card_orginal_pos", nesting)
	else
		if card_node then
			for i=0,2 do
				local card = card_node:getChildByName("card"..i)
				if card then
					if uid == USER_INFO["uid"] and bm.User.isKan[USER_INFO["uid"]] ~= nil then
						card:flip()
					else
						card:showBack()
					end
					-- local mt = cc.MoveTo:create(0.1, card_orginal_pos[uid][i])
					-- card:runAction(mt)
				end
			end
		end
	end
	if card_node then
		card_node:setVisible(is_show)
	end

	local head_time = ViewBase:seekChild(node, "effect_frame")
	if head_time then
		head_time:setVisible(is_show)
		if is_show then
			local pt = cc.ProgressFromTo:create(0,100,100)
			local sq2
			if bm.Room.seatProgressTimer then
				local index = -1
				if ZJH_USER_UID then
					index = ZJH_USER_UID[USER_INFO["uid"]]
				end
				if uid == USER_INFO["uid"] or index == 0 then
					sq2 = cc.Sequence:create(pt, cc.CallFunc:create(function()
						if bm.Room.seatProgressTimer then
							bm.Room.seatProgressTimer:stopAllActions()

							local action_time = 0.3
							local action_in = 0.1
							local st_big = cc.ScaleTo:create(action_time, 0.7,0.88)
							local fo = cc.FadeOut:create(action_time)
							local st_small = cc.ScaleTo:create(action_in, 0.77,0.90)
							local fi = cc.FadeIn:create(action_in)
							local sqout = cc.Spawn:create(st_big,fo)
							local sqin = cc.Spawn:create(st_small,fi)
							local sq = cc.Sequence:create(sqout,sqin)
							bm.Room.seatProgressTimer:runAction(cc.RepeatForever:create(sq))
						end
					end))
				else
					sq2 = cc.Sequence:create(pt, cc.CallFunc:create(function()
						if bm.Room.seatProgressTimer then
							bm.Room.seatProgressTimer:stopAllActions()
							local action_time = 0.3
							local action_in = 0.1
							local st_big = cc.ScaleTo:create(action_time, 0.78,0.65)
							local fo = cc.FadeOut:create(action_time)
							local st_small = cc.ScaleTo:create(action_in, 0.79,0.68)
							local fi = cc.FadeIn:create(action_in)
							local sqout = cc.Spawn:create(st_big,fo)
							local sqin = cc.Spawn:create(st_small,fi)
							local sq = cc.Sequence:create(sqout,sqin)
							bm.Room.seatProgressTimer:runAction(cc.RepeatForever:create(sq))
						end
					end))

				end
			end
			head_time:runAction(sq2)
		end
	end
end

-- 移动玩家节点到比牌位置
function CompareView:moveUserNode()

	local pos_end = {
		[0] = {
			['x']    = 320.46,
			['y']    = 407.16,
		},
		[1] = {
			['x']    = 923.64,
			['y']    = 354.16,
		}
	}
	local node    = FanSanPiPanel:getChildByName("zhezhao")
	local WorldMiddlePosition = node:convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))

	local move = cc.MoveTo:create(0.4,cc.p(WorldMiddlePosition.x - 280, WorldMiddlePosition.y+35))
	user_node_clone_f:runAction(move)

	local move = cc.MoveTo:create(0.4,cc.p(WorldMiddlePosition.x + 280, WorldMiddlePosition.y))
	local sq = cc.Sequence:create(move, cc.CallFunc:create(function()
		CompareView:movePK()
	end))
	user_node_clone_s:runAction(sq)
end

-- 移动玩家节点回原来位置
function CompareView:moveUsernode2Original()

	print("moveUsernode2Original")

	local scenes  = FanSanPiPanel
	local node    = scenes:getChildByName("zhezhao")
	print ("zhezhao", debug.getinfo(1).currentline )
	print ( "zhezhao",debug.getinfo(1).name )
	print ( node, "zhezhao")
	if node ~= nil then
		node:removeSelf()
	end

	user_node_clone_f:setAnchorPoint(cc.p(0.5, 0.5))
	--user_node_clone_s:addTo(scenes, 1)
	user_node_clone_s:setAnchorPoint(cc.p(0.5, 0.5))


	dump(original_pos, "original_pos", nesting)
	local move = cc.MoveTo:create(0.4,cc.p(original_pos[1].x, original_pos[1].y))
	user_node_clone_f:stopAllActions()
	user_node_clone_f:runAction(move)

	local move = cc.MoveTo:create(0.4,cc.p(original_pos[2].x, original_pos[2].y))
	local sq = cc.Sequence:create(move, cc.CallFunc:create(function()
		-- 还原玩家节点
		CompareView:resetUserNode(user_node_clone_f, true, active_uid, 0)
		CompareView:resetUserNode(user_node_clone_s, true, compare_uid, 0)
		for i = 1, 10 do
			scenes:getChildByName("player_plane_"..i):setLocalZOrder(9999)

		end
		MenjiroomView:CallBackCompare(active_uid, compare_uid, compare_resutl)
		is_compare = false
	end))
	user_node_clone_s:stopAllActions()
	user_node_clone_s:runAction(sq)
end

-- 出PK效果
function CompareView:movePK()
	local pos_end_back = {
		[0] = {
			['x']    = 403.53,
			['y']    = 377.00,
			['s']    = 1.333
		},
		[1] = {
			['x']    = 886.00,
			['y']    = 357.00,
			['s']    = 1.333
		}
	}
	local pos_end_txt = {
		[0] = {
			['x']    = 562.00,
			['y']    = 393.06,
			['s']    = 1.333
		},
		[1] = {
			['x']    = 737.33,
			['y']    = 366.67,
			['s']    = 1.333
		}
	}

	local scenes  = FanSanPiPanel
	local node    = scenes:getChildByName("zhezhao")
	print ("zhezhao", debug.getinfo(1).currentline )
	print ( "zhezhao",debug.getinfo(1).name )
	print ( node, "zhezhao")
	if node == nil then
		return
	end

	local offset_x = 500
	local move_time = 0.1

	local back_left = display.newSprite("FanSanPi/res/room/compareCard/pk_left_box01.png")
	back_left:addTo(node, 1)
	back_left:setScale(pos_end_back[0].s)
	back_left:setPosition(pos_end_back[0].x - offset_x, pos_end_back[0].y)
	local mt = cc.MoveTo:create(move_time, cc.p(pos_end_back[0].x, pos_end_back[0].y))
	back_left:runAction(mt)

	local back_right = display.newSprite("FanSanPi/res/room/compareCard/pk_right_box01.png")
	back_right:addTo(node, 1)
	back_right:setScale(pos_end_back[1].s)
	back_right:setPosition(pos_end_back[1].x + offset_x, pos_end_back[1].y)
	local mt = cc.MoveTo:create(move_time, cc.p(pos_end_back[1].x, pos_end_back[1].y))
	back_right:runAction(mt)

	local txt_left = display.newSprite("FanSanPi/res/room/compareCard/pk_p.png")
	txt_left:addTo(node, 4)
	txt_left:setScale(pos_end_txt[0].s)
	txt_left:setPosition(pos_end_txt[0].x - offset_x, pos_end_txt[0].y)
	local mt = cc.MoveTo:create(move_time, cc.p(pos_end_txt[0].x, pos_end_txt[0].y))
	txt_left:runAction(mt)

	local txt_right = display.newSprite("FanSanPi/res/room/compareCard/pk_k.png")
	txt_right:addTo(node, 4)
	txt_right:setScale(pos_end_txt[1].s)
	txt_right:setPosition(pos_end_txt[1].x + offset_x, pos_end_txt[1].y)
	local mt = cc.MoveTo:create(move_time, cc.p(pos_end_txt[1].x, pos_end_txt[1].y))
	local sq = cc.Sequence:create(mt, cc.DelayTime:create(1), cc.CallFunc:create(function()
		CompareView:showFire()
	end))
	txt_right:runAction(sq)
end

-- 碰撞火花
function CompareView:showFire()
	local scenes  = FanSanPiPanel
	local node    = scenes:getChildByName("zhezhao")
	print ("zhezhao", debug.getinfo(1).currentline )
	print ( "zhezhao",debug.getinfo(1).name )
	print ( node, "zhezhao")
	if node == nil then
		return
	end

	-- 爆炸光
	local boom_light = display.newSprite("FanSanPi/res/room/compareCard/light02.png")
	boom_light:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE))
	boom_light:addTo(node, 3)
	boom_light:setPosition(625.79, 360.27)
	boom_light:setScale(0.1)
	boom_light:setAnchorPoint(cc.p(0.5,0.5))
	local st = cc.ScaleTo:create(0.4, 2)
	boom_light:runAction(st)

	-- PK光
	local pk_light = display.newSprite("FanSanPi/res/room/compareCard/light01.png")
	pk_light:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE))
	pk_light:addTo(node, 40)
	pk_light:setPosition(534.33, 469.33)
	pk_light:setScale(2)
	--	local mt = cc.MoveTo:create(0.4, cc.p(628, 361))
	--	pk_light:runAction(mt)


	local boom = display.newSprite("#boom_01.png")
	local frames = display.newFrames("boom_%02d.png", 1, 4)
	if frames == nil then
		display.addSpriteFrames("FanSanPi/res/room/compareCard/boom.plist", "FanSanPi/res/room/compareCard/boom.png")
		frames = display.newFrames("boom_%02d.png", 1, 4)
	end
	local animation = display.newAnimation(frames, 0.2)
	--[[local animation =CCAnimation:create()
	local number,name;
	for i=1,4 do
		if i<10 then
			number="0"..i
		else
			number=i;
		end
		name="#boom_"..number..".png"
		--animation:addSpriteFrameWithFileName(name)

	end
	animation:setDelayPerUnit(1.0)]]
	local function onComplete()
		boom_light:removeSelf()
		pk_light:removeSelf()
		CompareView:showWinner()
	end
	--local action = CCAnimate:create(animation)

	--boom:runAction(cc.Sequence:create(action,cc.CallFunc:create(onComplete)))
	--[[if device.platform == "ios" then

		boom:playAnimationOnce(animation, {removeSelf=true,onComplete=onComplete})
	elseif device.platform == "android" then
		boom:playAnimationOnce(animation, true,onComplete)
	else
		transition.playAnimationOnce(boom,animation,true,onComplete)
		boom:playAnimationOnce(animation, {removeSelf=true,onComplete=onComplete})
	end]]
	transition.playAnimationOnce(boom,animation,true,onComplete)
	boom:addTo(node, 2)
	boom:setScale(3)
	boom:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE))
	boom:setPosition(625.79, 360.27)

end

-- 显示赢家
function CompareView:showWinner()

	print("showWinner", tostring(compare_resutl))

	local scenes  = FanSanPiPanel
	local node    = scenes:getChildByName("zhezhao")
	print ("zhezhao", debug.getinfo(1).currentline )
	print ( "zhezhao",debug.getinfo(1).name )
	print ( node, "zhezhao")
	if node == nil then
		return
	end

	local user_node = nil
	if compare_resutl == 1 then
		user_node = user_node_clone_f
	else
		user_node = user_node_clone_s
	end

	if user_node == nil then
		return
	end

	dump(user_node:getPosition(), "showWinner", nesting)
	local effect_winner = display.newSprite("#effect_winner_1.png")
	local frames = display.newFrames("effect_winner_%d.png", 1, 10)
	if frames == nil then
		display.addSpriteFrames("FanSanPi/res/room/compareCard/winner.plist", "FanSanPi/res/room/compareCard/winner.png")
		frames = display.newFrames("boom_%02d.png", 1, 4)
	end
	local animation = display.newAnimation(frames, 0.1)
	local function onComplete()
		CompareView:moveUsernode2Original()
		-- effect_winner:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
		-- 		CompareView:moveUsernode2Original()
		-- 	end)))
	end
	--[[if device.platform == "ios" then
		effect_winner:playAnimationOnce(animation, {removeSelf=true,onComplete=onComplete})
	elseif device.platform == "android" then
		effect_winner:playAnimationOnce(animation, true,onComplete)
	else
		effect_winner:playAnimationOnce(animation, {removeSelf=true,onComplete=onComplete})
	end]]
	transition.playAnimationOnce(effect_winner,animation,true,onComplete)
	effect_winner:addTo(node, 21)
	effect_winner:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE))
	effect_winner:setScaleX(user_node:getContentSize().width/effect_winner:getContentSize().width + 0.5)
	effect_winner:setScaleY(user_node:getContentSize().height/effect_winner:getContentSize().height)
	effect_winner:setPosition(cc.p(user_node:getPositionX(), user_node:getPositionY()))
end
function CompareView:clearActions()
	actions = {}
end

function CompareView:initUI()

	if self.curScheduler then
		scheduler.unscheduleGlobal(self.curScheduler)
	end
end

function CompareView:onExit()
	if self.curScheduler then
		scheduler.unscheduleGlobal(self.curScheduler)
	end
end

return CompareView