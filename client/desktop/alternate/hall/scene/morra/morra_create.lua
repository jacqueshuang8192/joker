local morra_create = class("morra_create")
local action = nil

function morra_create:showScene()
	if SCENENOW["scene"] then
		--释放之前的
        s = SCENENOW["scene"]:getChildByName("morra_create")

        if s then
            s:removeSelf()
        end

        --添加新场景
        if device.platform == "ios" then
            if isiOSVerify then
                s = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/morra/morra_create.csb")
            else
                s = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "hall/scene/res/" .. resFolder .."/morra/morra_create.csb")
            end
        else
            s = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/morra/morra_create.csb")
        end
        action = cc.CSLoader:createTimeline("hall/scene/res/" .. resFolder .."/morra/morra_create.csb")
        action:retain()
        s:runAction(action)
        action:gotoFrameAndPlay(0,25,false)
        s:setName("morra_create")
        SCENENOW["scene"]:addChild(s)	
        self:init(s)
    end

end

function morra_create:init(_root)
	-- body
	_w = self:loadChildrenWidget(_root)

	_w["morra_close_btn"]:addTouchEventListener(morra_create.touchEvent)
	_w["morra_score_btn"]:addTouchEventListener(morra_create.touchEvent)
	_w["morra_create_btn"]:addTouchEventListener(morra_create.touchEvent)
	_w["morra_join_btn"]:addTouchEventListener(morra_create.touchEvent)
end


--获取子控件table
function morra_create:loadChildrenWidget(_node, _childrenTable)
	local function func(node, childrenTable)
		if node ~= nil and node:getChildrenCount() <= 0 then return end
		local cTable = node:getChildren()
		for i, v in ipairs(cTable) do
			childrenTable[v:getName()] = v
			func(v, childrenTable)
		end
	end
	if _childrenTable == nil then _childrenTable = {} end
	func(_node, _childrenTable)
	return _childrenTable
end

function morra_create.touchEvent(sender, event)
	-- body
	local name = sender:getName()
	if event == TOUCH_EVENT_BEGAN then
		require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
        --sender:setScale(0.9)
    end
    if event == TOUCH_EVENT_CANCELED then
        --sender:setScale(1.0)
    end
	if event == TOUCH_EVENT_ENDED then
		--sender:setScale(1.0)
		if name == "morra_close_btn" then   
			s:removeSelf()
		elseif name == "morra_score_btn" then
			require("hall.scene.morra.morra_score"):show()
		elseif name == "morra_create_btn" then
			local tbl = {}
			local tmpJson = {}
    		tbl.userId = tostring(USER_INFO["uid"])--用户ID
		    tbl.gameId = 2--游戏ID
		    tbl.name = tostring(USER_INFO["nick"].."的组局")--组局名称
		    tbl.baseChip = 1 --level
		    tbl.level = 2--level
		    tbl.round = 0--局数
		    tbl.json = json.encode(tmpJson)
		    tbl.roomType = 1
		    tbl.discription = ""--discription
		    tbl.discription2Server = "cool"--isShowOp
		    tbl.interfaceType = "J"
		    tbl.others = 1
		    dump(tbl, "-----创建组局请求入参-----")

		    require("hall.groudgamemanager"):createfreegame(USER_INFO["uid"], tbl)

		elseif name == "morra_join_btn" then	
			require(JoinGroup_filePath):showScene()
		end	
	end	

end



return morra_create