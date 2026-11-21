printInfo("what?")

-- local mainView = _V("main_ui.main_ui_2")
-- local BUBBLE_PARTICLE_PATH1 = "particle/zjm_qipao.plist"
-- local BUBBLE_PARTICLE_PATH2 = "particle/bj_qipao.plist"

-- function mainView:startBubble()
-- 	local uiNode =  self:getUINode()
-- 	local bg =  self:getUIChild("Image_1")
-- 	local bubble1 = cc.ParticleSystemQuad:create(BUBBLE_PARTICLE_PATH1)
-- 	bubble1:setPositionX(display.width - 100)
-- 	bg:addChild(bubble1)

-- 	local bubble2 = cc.ParticleSystemQuad:create(BUBBLE_PARTICLE_PATH2)
-- 	bubble2:setPositionX(display.width - 150)
-- 	uiNode:addChild(bubble2, 999)

-- 	local bubble3 = cc.ParticleSystemQuad:create(BUBBLE_PARTICLE_PATH1)
-- 	bubble3:setPositionX(100)
-- 	bg:addChild(bubble3)
-- end 

local actCtrl = app.ctrls.activity

local ActivityModel = actCtrl.model

-- function ActivityModel:updateActvityTime()
-- 	local now = os.now() - self.diffTimeToServer
-- 	if not self.activityTimeTb then self.activityTimeTb = {} end
-- 	local open_status = nil
-- 	for i, info in ipairs(self.activityTimeTb) do
-- 		open_status = info.isOpen
-- 		info.isOpen = true
-- 		self:dispatchEvent({name = ActivityModel.EVENT_ACT_OPEN_STATUS, actId = info.id, status = info.isOpen})
-- 		info.leftTime = info.eTime - now
-- 	end
-- end
-- local actCtrl = app.ctrls.activity

local act_data = {
	[1] = {
		["activityId"] = 1,
		["eTime"     ] = 0,
		["sTime"     ] = 0,
		["status"    ] = true,
	},
	[15] = {
		["activityId"] = 11,
		["eTime"     ] = 10,
		["sTime"     ] = 10,
		["status"    ] = true,
	},
}
actCtrl.model:updateActivityTimeInfo(act_data[1])
actCtrl.model:updateActivityTimeInfo(act_data[15])

--viewMgr:showView("RECHARGE_ACTIVITY")
--viewMgr:showView("TASK_VIEW")
--viewMgr:showView("PLAY_GUIDE_VIEW")
--viewMgr:showView("RECHARGE_ACTIVITY")
--viewMgr:showView("INVITE_COPY_TIPS_VIEW")
--viewMgr:showView("LOGIN_INFO_SUC_TIP_VIEW")
--viewMgr:showView("EXCHANGE_VIEW")
--viewMgr:showView("EXCHANGE_CONTACT_VIEW")

-- actCtrl.model:dispatchEvent({name = actCtrl.model.EVENT_ACT_OPEN_STATUS})

