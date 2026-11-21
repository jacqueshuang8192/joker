--[[
* author:   zwm
* date:     2020-09-16
* describe: 牛牛全部玩家界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local GameUserInfoLayer = class("GameUserInfoLayer", ViewBaseLayer)

local SIX_ORDER_POSITION   = {[1] = cc.p(20, 35), [2] = cc.p(1920, 360), [3] = cc.p(1500, 1010), [4] = cc.p(960, 1040),
							  [5] = cc.p(1500, 1010), [6] = cc.p(20, 360)}

local SIX_BALANCE_POSITION = {[1] = cc.p(20, 35), [2] = cc.p(960, 1040), [3] = cc.p(20, 360), [4] = cc.p(1920, 360), [5] = cc.p(420, 1010),
							[6] = cc.p(1500, 1010)}
--8人顺序位置
local EIGHT_ORDER_POSITION = {[1] = cc.p(20, 35), [2] = cc.p(1920, 280), [3] = cc.p(1920, 480), [4] = cc.p(1500, 1010),
							  [5] = cc.p(960, 1040), [6] = cc.p(420, 1010), [7] = cc.p(20, 480), [8] = cc.p(20, 280)}
--8人平衡位置
local EIGHT_BALANCE_POSITION = {[1] = cc.p(20, 35), [2] = cc.p(960, 1040), [3] = cc.p(20, 480), [4] = cc.p(1920, 480), [5] = cc.p(420, 1010),
							[6] = cc.p(1500, 1010), [7] = cc.p(20, 280), [8] = cc.p(1920, 280)}

local TEN_ORDER_POSITION = {[1] = cc.p(20, 35), [2] = cc.p(1920, 280), [3] = cc.p(1920, 480), [4] = cc.p(1700, 1010), [5] = cc.p(1320, 1020),
							[6] = cc.p(960, 1040), [7] = cc.p(580, 1020), [8] = cc.p(220, 1010), [9] = cc.p(20, 480), [10] = cc.p(20, 280)}

local TEN_BALANCE_POSITION = {[1] = cc.p(20, 35), [2] = cc.p(960, 1040), [3] = cc.p(20, 480), [4] = cc.p(1920, 480), [5] = cc.p(220, 1010),
							[6] = cc.p(1700, 1010), [7] = cc.p(20, 280), [8] = cc.p(1920, 280), [9] = cc.p(580, 1020), [10] = cc.p(1320, 1020)}

function GameUserInfoLayer:ctor()
    GameUserInfoLayer.super.ctor(self, "NewNiuniu/res/csb/gameUserInfoLayer.csb")
    self._csbNode:setScale(1280/1920, 720/1080)
end

function GameUserInfoLayer:onEnter()
	self.allUserInfo = {}
	self.grabBankerUid = {}
	self._seatIdToViewId = {}
	self._userIdToViewId = {}
end

function GameUserInfoLayer:saveUserInfo(data)
	for i,v in ipairs(data or {}) do
		if self.allUserInfo[v.uid] == nil then
			self.allUserInfo[v.uid] = self:collectPlayerData(v)
		end
	end
end

function GameUserInfoLayer:addUserInfo(data)
	if self.allUserInfo[data.uid] == nil then
		self.allUserInfo[data.uid] = self:collectPlayerData(data)
	end
end

function GameUserInfoLayer:getAllUserInfo()
	return self.allUserInfo
end

function GameUserInfoLayer:getUserObjByUid(uId)
	if self.allUserInfo[uId] then
		return self.allUserInfo[uId]._objNode
	end
end

function GameUserInfoLayer:getUserObjBySeatId(sId)
	-- body
end

function GameUserInfoLayer:createUserObj(data)
	
	local viewId = self:getViewIdBySeatId(data.seatId)
	print("createUserObj ------------- ",data.uid, viewId)
	if viewId == nil then return end

	self._seatIdToViewId[data.seatId] = viewId
	self._userIdToViewId[data.uid]    = viewId
	local obj = self:getUserObjByViewId(viewId, data)
	self.allUserInfo[data.uid]._objNode = obj
	self.allUserInfo[data.uid]._isMyObj = viewId == 1
	local pos = self:getExchangePos(self:getPositionByViewId(viewId))

	obj:setPosition(pos)
	obj:addTo(self)
end

function GameUserInfoLayer:getExchangePos(pos)
	return cc.p(pos.x * (72/108)*self:_getScaleParam2(), pos.y * (72/108))
end

function GameUserInfoLayer:getPositionByViewId(viewId)
	local maxPlayer = g_mainScene.gameDefine.TOTAL_PLAYERNUM
	local isBalanceSeat = self:isBalanceSeat()
	-- print("getPositionByViewId -------------", maxPlayer, isBalanceSeat, viewId)
	if maxPlayer == 6 then
		if isBalanceSeat then
			return SIX_BALANCE_POSITION[viewId]
		else
			return SIX_ORDER_POSITION[viewId]
		end
	elseif maxPlayer == 8 then
		if isBalanceSeat then
			return EIGHT_BALANCE_POSITION[viewId]
		else
			return EIGHT_ORDER_POSITION[viewId]
		end
	else
		if isBalanceSeat then
			return TEN_BALANCE_POSITION[viewId]
		else
			return TEN_ORDER_POSITION[viewId]
		end
	end
end

function GameUserInfoLayer:saveGrabData(data)
	local maxGarb = 0
	for i,v in ipairs(self.grabBankerUid) do
		if v.if_qiang > maxGarb then
			maxGarb = v.if_qiang
		end
	end
	if data.if_qiang > maxGarb then
		self.grabBankerUid = {}
		table.insert(self.grabBankerUid, data)
	elseif data.if_qiang == maxGarb then
		table.insert(self.grabBankerUid, data)
	end
end

function GameUserInfoLayer:showSelectZhuanAni(bankerId)
	-- print("showSelectZhuanAni --------------", debug.traceback())
	if #self.grabBankerUid == 0 then
		for k,v in pairs(self.allUserInfo) do
			local tmp = {}
			tmp.uid = k
			tmp.if_qiang = 1
			table.insert(self.grabBankerUid, data)
		end
	end
	self.curBankerId = bankerId
	if #self.grabBankerUid > 1 then
		self._bankerAniLst = self:DisruptionTable()
		self._bankerAniIdx = 0
		self.bankerAniSch = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.rankBankerChoose), 0.1, false)
	else
		local size = self:getContentSize()
        local pos = cc.p(960*self._getScaleParam2()*72/108, 540*72/108)
	    self:createArmature('niuniu_zhuang_1', pos, self.curBankerId)
	end
	self.grabBankerUid = {}
end

function GameUserInfoLayer:rankBankerChoose()
	self._bankerAniIdx = self._bankerAniIdx + 1
	if self._bankerAniIdx <= #self._bankerAniLst then
		for i,v in ipairs(self._bankerAniLst) do
			local uid = self._bankerAniLst[i].uid
			local tempObj = self.allUserInfo[uid]._objNode
			if tempObj then
				tempObj:setEffectKuangVisible(i == self._bankerAniIdx)
			end
		end
		
	else
		if self.bankerAniSch then 
	        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.bankerAniSch)
	        self.bankerAniSch = nil
	    end
	    local size = self:getContentSize()
        local pos = cc.p(960*self._getScaleParam2()*72/108, 540*72/108)
	    self:createArmature('niuniu_zhuang_1', pos, self.curBankerId)
	end
end

function GameUserInfoLayer:clearUserKuangEffect()
	for k, v in pairs(self.allUserInfo or {}) do
		local uObj = v._objNode
		if uObj then
			uObj:setEffectKuangVisible(false)
		end
	end
end

--骨骼动画
function GameUserInfoLayer:createArmature(name, pos, uid)
	self:clearUserKuangEffect()
    local armatureObj = self:getChildByName(name)
    if armatureObj then
        armatureObj:stopAllActions()
        local Animation = armatureObj:getAnimation()
        Animation:gotoAndPause(0)
        armatureObj:removeSelf()
    end

    local path1 = TpackageName .. '/res/ani/dingzhuangAnimiation/' .. name
    local effectManage = ccs.ArmatureDataManager:getInstance()
    effectManage:addArmatureFileInfo(path1 .. '0.png', path1 .. '0.plist', path1 .. '.ExportJson')

    local armatureObj = ccs.Armature:create(name)
    armatureObj:setAnchorPoint(cc.p(0.5, 0.5))
    armatureObj:getAnimation():playWithIndex(0, -1, 0) --第一个参数是动画表index 第二个是时间间隔第三个是是否循环
    armatureObj:setPosition(pos)
    armatureObj:setName(name)
    self:addChild(armatureObj)
    if name == 'dingzhuang' and uid ~= USER_INFO.uid then
        armatureObj:setScale(0.6)
    end
    function handler1(Armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
            if name == 'dingzhuang' then
            	local bankerObj = self.allUserInfo[uid]._objNode
            	if bankerObj ~= nil then 
            		if g_mainScene.BANKER_UID > 0 then
	            		bankerObj:setZhuangVisible(true) 
	            		bankerObj:setEffectKuangVisible(true)
	            	end
            	end
                Armature:removeSelf()
            else
            	local bankerObj = self.allUserInfo[uid]._objNode
            	if bankerObj == nil then return end
            	local userPos = bankerObj:getPosition()

                local pos = nil 
                if bankerObj._headType == "left" then
                	pos = cc.p((userPos.x + 21), (userPos.y + 120))
                elseif bankerObj._headType == "top" then
                	pos = cc.p((userPos.x - 75), (userPos.y - 18))
                elseif bankerObj._headType == "right" then
                	pos = cc.p((userPos.x - 50), (userPos.y + 130))
                else
                	pos = cc.p((userPos.x + 13), (userPos.y + 112))
                end
                if pos then
                    local duration = 0.4
                    local spawn_action =
                        cc.Spawn:create(
                        cc.MoveTo:create(duration, pos),
                        cc.FadeOut:create(duration),
                        cc.ScaleTo:create(duration, 0.2, 0.2)
                    )
                    armatureObj:runAction(
                        cc.Sequence:create(
                            spawn_action,
                            cc.CallFunc:create(
                                function()
                                    self:createArmature('dingzhuang', pos, uid)
                                end
                            ),
                            cc.RemoveSelf:create()
                        )
                    )
                end
            end
        end
    end
    if tolua.isnull(armatureObj) == false then
        armatureObj:getAnimation():setMovementEventCallFunc(handler1)
        armatureObj:stopAllActions()
    end
end

function GameUserInfoLayer:clearAllArmatureAni()
	local aniNameLst = {"dingzhuang", "niuniu_zhuang_1"}
	for k, v in pairs(aniNameLst) do
		local armatureObj = self:getChildByName(v)
	    if armatureObj then
	        armatureObj:stopAllActions()
	        local Animation = armatureObj:getAnimation()
	        Animation:gotoAndPause(0)
	        armatureObj:removeSelf()
	    end
	end
end

function GameUserInfoLayer:DisruptionTable()
	for i = 1, 3 do
		local idx = math.random(1, #self.grabBankerUid)
		local item = self.grabBankerUid[idx]
		table.remove(self.grabBankerUid, idx)
		table.insert(self.grabBankerUid, 1, item)
	end
	return self.grabBankerUid
end

function GameUserInfoLayer:getViewIdBySeatId(seatId)

	if MY_SEAT_ID < 0 then return (seatId + 1) end

	local dt = seatId - MY_SEAT_ID
	if dt < 0 then
		dt = dt + g_mainScene.gameDefine.TOTAL_PLAYERNUM
	end
	if (dt + 1) > g_mainScene.gameDefine.TOTAL_PLAYERNUM then
		print(string.format("get viewId is error, seatId = %d, MY_SEAT_ID = %d, player size = %d", seatId, g_mainScene.gameDefine.MY_SEAT_ID, g_mainScene.gameDefine.TOTAL_PLAYERNUM))
	else
		print("getViewIdBySeatId --------------- ", seatId, MY_SEAT_ID, g_mainScene.gameDefine.TOTAL_PLAYERNUM, dt+1)
		return dt+1
	end
end

function GameUserInfoLayer:getUserObjByViewId(viewId, data)
	if viewId == 1 then
		return require("NewNiuniu.src.view.gameUserCell").new("my", data)
	end

	local isBalanceSeat = self:isBalanceSeat()
	if g_mainScene.gameDefine.TOTAL_PLAYERNUM == 6 then
		if isBalanceSeat then
			if viewId == 2 or viewId == 5 or viewId == 6 then
				return require("NewNiuniu.src.view.gameUserCell").new("top", data)
			elseif viewId == 3 then
				return require("NewNiuniu.src.view.gameUserCell").new("left", data)
			else
				return require("NewNiuniu.src.view.gameUserCell").new("right", data)
			end
		else
			if viewId == 5 or viewId == 3 or viewId == 4 then
				return require("NewNiuniu.src.view.gameUserCell").new("top", data)
			elseif viewId == 2 then
				return require("NewNiuniu.src.view.gameUserCell").new("right", data)
			else
				return require("NewNiuniu.src.view.gameUserCell").new("left", data)
			end
		end
	elseif g_mainScene.gameDefine.TOTAL_PLAYERNUM == 8 then
		if isBalanceSeat then
			if viewId == 2 or viewId == 5 or viewId == 6 then
				return require("NewNiuniu.src.view.gameUserCell").new("top", data)
			elseif viewId == 3 or viewId == 7 then
				return require("NewNiuniu.src.view.gameUserCell").new("left", data)
			else
				return require("NewNiuniu.src.view.gameUserCell").new("right", data)
			end
		else
			if viewId == 5 or viewId == 6 or viewId == 4 then
				return require("NewNiuniu.src.view.gameUserCell").new("top", data)
			elseif viewId == 2 or viewId == 3 then
				return require("NewNiuniu.src.view.gameUserCell").new("right", data)
			else
				return require("NewNiuniu.src.view.gameUserCell").new("left", data)
			end
		end
	elseif g_mainScene.gameDefine.TOTAL_PLAYERNUM == 10 then
		if isBalanceSeat then
			if viewId == 2 or viewId == 5 or viewId == 6 or viewId == 9 or viewId == 10 then
				return require("NewNiuniu.src.view.gameUserCell").new("top", data)
			elseif viewId == 3 or viewId == 7 then
				return require("NewNiuniu.src.view.gameUserCell").new("left", data)
			else
				return require("NewNiuniu.src.view.gameUserCell").new("right", data)
			end
		else
			if viewId == 5 or viewId == 6 or viewId == 4 or viewId == 7 or viewId == 8 then
				return require("NewNiuniu.src.view.gameUserCell").new("top", data)
			elseif viewId == 2 or viewId == 3 then
				return require("NewNiuniu.src.view.gameUserCell").new("left", data)
			else
				return require("NewNiuniu.src.view.gameUserCell").new("right", data)
			end
		end
	end
end

function GameUserInfoLayer:isBalanceSeat()
	if g_mainScene.gameDefine.GAME_TYPE == 3 or g_mainScene.gameDefine.GAME_TYPE == 5 then--轮庄和公牛，需要安装顺序排座位
		return false
	else
		return true
	end
end

--整理用户数据
function GameUserInfoLayer:collectPlayerData(data)

    local info = {}
    local gold = data.gold

    --data数据是直接获得的，金币场
    --info协议放在userinfo_json里
    local nick_name = data.nickName or info.nickName
    -- dump(data.gold,"玩家金币")
    local icon_url = data.portrait or (info.photoUrl or info.icon_url)
    local sex_num = data.sex or info.sex
    local userInfo = {}

    --头像图片
    userInfo['icon_url'] = icon_url or ''
    --昵称
    userInfo['nick'] = nick_name or ''
    --金币
    userInfo['coins'] = gold or 0 --用户总金币
    --UID
    userInfo['uid'] = data.uid or 0
    --性别
    userInfo['sex'] = sex_num or 0
    --IP
    userInfo['ip'] = data.ip or '0.0.0.0'
    userInfo['otherInfo'] = data.otherInfo

    userInfo['score'] = 0 --用户本局游戏的胜负
    userInfo['longitude'] = data.longitude
    userInfo['latitude'] = data.latitude

    userInfo['seatId'] = data.seat_id
    userInfo.status = data.user_status or 0
    userInfo.gameingData = data
    if data.user_status and data.user_status > 0 then
    	userInfo._isPlaying = true
    end
    local uid = data.uid

    local updateUserInfoData = {}

    if data.longitude then
        updateUserInfoData['longitude'] = data.longitude
        updateUserInfoData['latitude'] = data.latitude
        updateUserInfoData['invote_code'] = USER_INFO['invote_code']
    end

    if data.otherInfo then
        local otherInfo = json.decode(data.otherInfo)
        if otherInfo then
            updateUserInfoData['city'] = otherInfo['city']
        end
    end

    updateUserInfoData['uid'] = uid
    updateUserInfoData['nickName'] = userInfo['nick']
    updateUserInfoData['ip'] = data.ip
    -- require('hall.view.userInfoView.userInfoView'):upDateUserInfo(uid, updateUserInfoData)

    if not userInfo.addres or userInfo.addres == '' then
        ReqMgr:getAddress(userInfo.latitude, userInfo.longitude, userInfo.uid)
    end

    return userInfo
end

function GameUserInfoLayer:showSendCardAni(idxLst, isFirst)
	print("showSendCardAni ------------------- ", debug.traceback())
	dump(idxLst, "idxLst == ")
	local batchNode = display.newBatchNode("NewNiuniu/res/image/card_back.png", 50)
	batchNode:setPosition(cc.p(0, 0))
	batchNode:setName("cardBatchNode")
	batchNode:addTo(self)

	--handler(self, self.cardMoveEndCallBack)
	local callBack = function ()
		batchNode:removeSelf()
		if g_mainScene.isGameConnect then return end

		local size = 0
		for i,v in ipairs(g_mainScene._myHandCards) do
			if v > 0 then
				size = size + 1
			end
		end
		for k,v in pairs(self.allUserInfo) do
			if v._isMyObj and v._isPlaying then --v._isPlaying and
				local objNode = v._objNode
				if objNode then
					if size < 5 then
						objNode:showCardsValue(g_mainScene._myHandCards)
					else
						for i = size, 5 do
							objNode:showCardBackByIdx(i)
						end
					end
				end
			elseif v._isPlaying then
				local objNode = v._objNode
				if objNode then
					local size = 0
					for i,v in ipairs(g_mainScene._myHandCards or {}) do
						if v > 0 then
							size = size + 1
						end
					end
					objNode:showCardBack(size)
				end
			end
		end
	end

	local cardSize = 0
	for k,v in pairs(self.allUserInfo) do
		if v._isPlaying then
			local isMyObj = v._isMyObj
			for _, v1 in ipairs(idxLst or {}) do
				local cardNode = display.newSprite(batchNode:getTexture())
				batchNode:addChild(cardNode)
				cardNode:setPosition(cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - 100))
				local scale = isMyObj and 0.95*(76/108) or 0.45*(72/108)
				cardNode:setScale(scale)
				cardSize =  cardSize + 1
				local ani = self:createCardMoveAni(batchNode, v._objNode, v1, cardSize, isMyObj, callBack, isFirst)
				cardNode:runAction(ani)
			end
		end
	end

end

function GameUserInfoLayer:showOtherCards(cards)
	for k,v in pairs(self.allUserInfo) do
		print("showOtherCards -----------", k, v._isPlaying)
		if (not v._isMyObj) and v._isPlaying then --v._isPlaying and
			local objNode = v._objNode
			if objNode then
				local size = 0
				for i,v in ipairs(cards or {}) do
					if v > 0 then
						size = size + 1
					end
				end
				size = size < 4 and 4 or size
				objNode:showCardBack(size)
			end
		end
	end
end

function GameUserInfoLayer:cardMoveEndCallBack(isFirst)
	local batchNode = self:getChildByName("cardBatchNode")
	if batchNode then
		batchNode:removeSelf()
		for k,v in pairs(self.allUserInfo) do
			if v._isMyObj and v._isPlaying then --v._isPlaying and
				local objNode = v._objNode
				if objNode and isFirst then
					objNode:showCardsValue(g_mainScene._myHandCards)
				end
			elseif v._isPlaying then
				local objNode = v._objNode
				if objNode then
					local size = 0
					for i,v in ipairs(g_mainScene._myHandCards or {}) do
						if v > 0 then
							size = size + 1
						end
					end
					objNode:showCardBack(size)
				end
			end
		end
	end
end

local SendCardTime = 0--0.015
local SendCardMoveToTime = 0.3

function GameUserInfoLayer:createCardMoveAni(parent, obj, idx, size, isMyObj, callBack)
	local basePos = obj:getParent():convertToWorldSpace(obj:getPosition())
	local x = self:getMoveEndPosX(basePos.x, obj._headType, idx)+(obj._cardOffset or 0)*(72/108)
	local y =  self:getMoveEndPosY(basePos.y, obj._headType)--isMyObj and (basePos.y + 110) or (basePos.y + 70)
	-- print("createCardMoveAni -----------------------", idx, x, y)
	local move = cc.MoveTo:create(SendCardMoveToTime, cc.p(x, y))--*self._getScaleParam2()
    local delay = cc.DelayTime:create(size * SendCardTime)
    local se
    if size == 1 then
    	se = cc.Sequence:create(delay, move, cc.CallFunc:create(
                callBack
            ))
    else
    	se = cc.Sequence:create(delay, move)
    end
    return se
end

function GameUserInfoLayer:getMoveEndPosX(beginX, type, idx)
	if type == "my" then
		return (beginX + 413 + (idx - 1)*106.67)
	elseif type == "top" then
		return (beginX - 57 + (idx - 1)*30.67)
	elseif type == "left" then
		return (beginX + 148 + (idx - 1)*30.67)
	elseif type == "right" then
		return (beginX - 283 + (idx - 1)*30.67)
	end
end

function GameUserInfoLayer:getMoveEndPosY( beginY, type )
	if type == "my" then
		return (beginY + 82)
	elseif type == "top" then
		return (beginY - 170)
	elseif type == "left" then
		return (beginY + 52)
	elseif type == "right" then
		return (beginY + 52)
	end
end

function GameUserInfoLayer:showGoldMoveAni(data)
	-- local userinfo = data.userinfo
	-- for i, v in ipairs(userinfo or {}) do
	-- 	local tempObj = self.allUserInfo[v.uid]._objNode
	-- 	if tempObj then
	-- 		tempObj:showSinglerResult(v.win_chip)
	-- 		tempObj:setCoin(v.chips)
	-- 	end
	-- end

	local batchNode = display.newBatchNode("NewNiuniu/res/image/icon_2.png", 100)
	batchNode:setPosition(cc.p(0, 0))
	batchNode:setName("goldBatchNode")
	batchNode:addTo(self)
	local bankerObj = self.allUserInfo[data.banker_uid]._objNode
	if bankerObj then
		local bankerPos = bankerObj.head_img:getParent():convertToWorldSpace(bankerObj.head_img:getPosition())
		local loseUser = {}
		local winUser  = {}
		for i, v in ipairs(data.userinfo or {}) do
			if v.uid ~= data.banker_uid then
				if v.win_chip > 0 then
					table.insert(winUser, v.uid)
				else
					table.insert(loseUser, v.uid)
				end
			end
		end

		for i = 1, 10 do
			for j, v in ipairs(loseUser) do
				local tempObj = self.allUserInfo[v]._objNode
				if tempObj then
					local beginPos = tempObj.head_img:getParent():convertToWorldSpace(tempObj.head_img:getPosition())
					local goldNode = self:createMoveGold(batchNode, beginPos)
					goldNode:runAction(self:getGoldMoveAni(i, bankerPos, 0))
				end
			end

			for j, v in ipairs(winUser) do
				local tempObj = self.allUserInfo[v]._objNode
				if tempObj then
					local endPos = tempObj.head_img:getParent():convertToWorldSpace(tempObj.head_img:getPosition())
					local goldNode = self:createMoveGold(batchNode, bankerPos)
					goldNode:runAction(self:getGoldMoveAni(i, endPos, 0.55))
				end
			end
		end		
		self.singlerResult = data
		self:performWithDelay(handler(self, self.showSinglerResult), 1.1)
	end
end

function GameUserInfoLayer:createMoveGold(parent, beginPos)
	local goldNode = display.newSprite(parent:getTexture())
	parent:addChild(goldNode)
	goldNode:setPosition(beginPos)
	goldNode:setScale(0.7)
	return goldNode
end

function GameUserInfoLayer:getGoldMoveAni(idx, endPos, delayTime)
	local mo = cc.MoveTo:create(0.25, endPos)
    local fo = cc.FadeOut:create(0.2)
    local delay = cc.DelayTime:create(idx * 0.01 + delayTime)
    local seq = cc.Sequence:create(delay, mo, fo)
    return seq
end

function GameUserInfoLayer:showSinglerResult()
	local goldBatchNode = self:getChildByName('goldBatchNode')
	if goldBatchNode then
		goldBatchNode:removeSelf()
	end
	-- self:performWithDelay(handler(g_mainScene.gameOptLayer, g_mainScene.gameOptLayer.showReadyBtn), 0.5)
	if self.singlerResult == nil or self.singlerResult.userinfo == nil then return end

	local userinfo = self.singlerResult.userinfo
	for i, v in ipairs(userinfo or {}) do
		local tempObj = self.allUserInfo[v.uid]._objNode
		if tempObj then
			tempObj:showSinglerResult(v.win_chip)
			tempObj:setCoin(v.chips)
		end
	end

	local bankObj = self.allUserInfo[self.singlerResult.banker_uid]._objNode
	if bankObj then
		bankObj:showSinglerResult(self.singlerResult.banker_win_chip)
		bankObj:setCoin(self.singlerResult.banker_chips)
	end

	g_mainScene.gameOptLayer.btnReady:setVisible(true)
end

function GameUserInfoLayer:turnMyLastCards()
	local myObj = self.allUserInfo[USER_INFO.uid]._objNode
	if myObj then
		myObj:showCardsValue(g_mainScene._myHandCards, self:getBackCardIdxs())
	end
end

function GameUserInfoLayer:getBackCardIdxs()
	local result = {}
	for i = 1, 5 do
		if g_mainScene.gameConfig.showCardNums < i then
			table.insert(result, i)
		end
	end

	return result
end

function GameUserInfoLayer:showAllUserInfo(loginMsg)-- 1007 的消息包
	if MY_SEAT_ID < 0 then --自己还没分配椅子
		self._saveUserInfo = clone(loginMsg.users_infos)
	else
		for i,v in ipairs(loginMsg.users_infos or {}) do
			local userInfo = self.allUserInfo[v.uid]
			if userInfo == nil or (userInfo ~= nil and userInfo._objNode == nil) then
				self.allUserInfo[v.uid] = self:collectPlayerData(v)
				self:createUserObj(self.allUserInfo[v.uid])
			else
				local obj = self.allUserInfo[v.uid]._objNode
				if obj and (not tolua.isnull(obj)) then
					obj:clearUserStatus()
				end
			end
		end
	end
end

function GameUserInfoLayer:showMyUserBySeated(pack)
	-- g_mainScene.gameDefine.TOTAL_PLAYERNUM = 8
	if MY_SEAT_ID < 0 then
		table.insert(self._saveUserInfo, pack)
	else
		local userInfo = self.allUserInfo[pack.uid]
		if userInfo == nil or (userInfo ~= nil and userInfo._objNode == nil) then
			self.allUserInfo[pack.uid] = self:collectPlayerData(pack)
			self:createUserObj(self.allUserInfo[pack.uid])

			-- for i = 1, 7 do
			-- 	local tempPack = clone(pack)
			-- 	tempPack.uid = tempPack.uid + i
			-- 	tempPack.seat_id = tempPack.seat_id + i
			-- 	table.insert(self._saveUserInfo, tempPack)
			-- end

			for i,v in ipairs(self._saveUserInfo or {}) do
				local userInfo = self.allUserInfo[v.uid]
				if userInfo == nil or (userInfo ~= nil and userInfo._objNode == nil) then
					self.allUserInfo[v.uid] = self:collectPlayerData(v)
					self:createUserObj(self.allUserInfo[v.uid])
				end
			end
		end

		if g_mainScene.BANKER_UID > 0 then
			local bankerObj = g_mainScene.gameUserInfoLayer.allUserInfo[g_mainScene.BANKER_UID]._objNode
	        if bankerObj ~= nil then 
	            bankerObj:setZhuangVisible(true) 
	            bankerObj:setEffectKuangVisible(true)
	        end
		end

		local tempStatus = g_mainScene._toEnterStatus
		if tempStatus == 2 or tempStatus == 3 or tempStatus == 4 then
			if tempStatus == 4 then
				self:showOtherCards({1,1,1,1,1})
			else
				self:showOtherCards({1,1,1,1})
			end
		end

		if USER_INFO.uid == pack.uid then
			
			g_mainScene.gameOptLayer.btnReady:setVisible(g_mainScene.curRound == 0)
		end
	end
end

function GameUserInfoLayer:showOtherUserBySeated(pack)
	if MY_SEAT_ID < 0 or pack.seat_id < 0 then
		table.insert(self._saveUserInfo, pack)
	else
		local userInfo = self.allUserInfo[pack.uid]
		if userInfo == nil or (userInfo ~= nil and userInfo._objNode == nil) then
			self.allUserInfo[pack.uid] = self:collectPlayerData(pack)
			self:createUserObj(self.allUserInfo[pack.uid])
		end
	end
end

function GameUserInfoLayer:reomveUserForQuitRoom(uid)
	local hasUser = false
	for k,v in pairs(self.allUserInfo or {}) do
		if uid == k and uid ~= USER_INFO.uid then
			v._objNode:removeSelf()
			self.allUserInfo[uid] = nil
			hasUser = true
			return
		end
	end

	if not hasUser then
		for i,v in ipairs(self._saveUserInfo or {}) do
			if v.uid == uid then
				table.remove(self._saveUserInfo, i)
				return
			end
		end
	end

end

function GameUserInfoLayer:playEffectByUId(type, uid)
	if self.allUserInfo[uid] then
		SoundUtils:playCardKindEffect(type, self.allUserInfo[uid].sex)
	end
end

function GameUserInfoLayer:showUserTuiZhuInfo(info)
	if info == nil then return end
	for i, v in ipairs(info or {}) do
		local tObj = self:getUserObjByUid(v.uid)
		if tObj then
			tObj:showTuizhuValue(v.max_tuizhu)
		end
	end
end

function GameUserInfoLayer:clearAllReadyStatus()
	for k,v in pairs(self.allUserInfo or {}) do
		local usrObj = v._objNode
		usrObj:setReadVisible(false)
	end
end

function GameUserInfoLayer:clearGrabBankerSymbol(bankerId)
	for k,v in pairs(self.allUserInfo) do
		if k == bankerId then
			local tObj = v._objNode
			if tObj then
				tObj:hideTuizhuValue()
				if tObj.grab_not_banker_img:isVisible() then
					tObj:showQiangZhuangStatus(1)
				end
			end
		else
			local tObj = v._objNode
			if tObj then
				tObj:hideTuizhuValue()
				tObj:clearQiangZhuangStatus()
			end
		end
	end
end

function GameUserInfoLayer:clearForClickReady()
	for k,v in pairs(self.allUserInfo) do
		local tObj = v._objNode
		-- local tObj = self:getUserObjByUid(k)
		if tObj then
			tObj:clearUserForClickReady()
		end
	end
end

function GameUserInfoLayer:showUserDisconnect(data)
	local uObj = self:getUserObjByUid(data.uid)
	if uObj then
		uObj:setNetworkState(true)
	end
end

function GameUserInfoLayer:onEixt()
	-- body
end

return GameUserInfoLayer