local TablePlaneOperator = class("TablePlaneOperator")
local coin_img_path = TpackageName .. "/res/layout/roomScene/icon_2.png"
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

function TablePlaneOperator:init()
    self.clock= SHISANZHANG_GAME_SCENE:getChildByName("clock")
    -- self.qiepai_vw = SHISANZHANG_GAME_SCENE.qiepai_vw:hide()
    self.clock:setVisible(false)
    -- self.qiepaiNodes:onTouch(handler(self, self.onClickHandCard))

    --------------
    self.qiepai_vw = SHISANZHANG_GAME_SCENE.qiepai_vw
    self.qiepaiNodes = self.qiepai_vw.qiepai
    self.btn_sure = self.qiepai_vw.btn_sure
    self.btn_shouzhi = self.qiepai_vw.btn_shouzhi
    self.time_bg = self.qiepai_vw.time_bg
    self.timeStr = self.time_bg.timeStr
    self.qiepaiNodes:onTouch(handler(self, self.onClickHandCard))
    self.btn_shouzhi:onTouch(handler(self, self.onClickShouZhi))
    self.btn_sure:onClick(handler(self, self.onClickQiepaiSure))
    self:set_qiepai_vw(false)
    --------------

    self:claerAllPlane()

end

function TablePlaneOperator:onClickHandCard(event)
	local target = self.qiepaiNodes
	if event.name == "moved" or event.name == "began" then
		local x, y = event.x, event.y
		for i,node in ipairs(target:getChildren()) do
            if node:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
                local color = node:getColor()
                if color.b == 0 then
                    node:setColor(cc.c3b(255,255,255))
                else
                    node:setColor(cc.c3b(255,255,0))
                end
			end
		end
	elseif event.name == "ended" or event.name == "cancelled" then
		-- local x, y = event.x, event.y
		-- for i,node in ipairs(target:getChildren()) do
        --     if node:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
		-- 		node:setColor(cc.c3b(255,255,0))
		-- 	end
		-- end
	end
end

function TablePlaneOperator:startGameTime(time)
    local clock_txt =  self.clock:getChildByName("text_center")
    clock_txt:stopAllActions()
    if  time <= 0 then
        self.clock:setVisible(false)
        return
    else
        self.clock:setVisible(true)
    end
    local  timer_value = time
    local  refreshTime = 1
    
    clock_txt:setString("倒计时："..string.format( "%02d", timer_value ))
    local showTimerAc = cc.CallFunc:create(function()
        timer_value = timer_value - refreshTime
        clock_txt:setString("倒计时："..string.format( "%02d", timer_value ))
        if timer_value <= 0 then
            clock_txt:stopAllActions()
            self.clock:setVisible(false)
        end
    end)
    local seqAc = cc.Sequence:create(cc.DelayTime:create(refreshTime), showTimerAc)
    clock_txt:runAction(cc.RepeatForever:create(seqAc))
end

function TablePlaneOperator:claerAllPlane()
    if self.coin_nodes and #(self.coin_nodes) >= 1 then
        for i,node in ipairs(self.coin_nodes) do
            node:stopAllActions()
            node:removeFromParent()
        end
    end
    self.coin_nodes = {}
    self:set_qiepai_vw(false)
end

--画金币
function TablePlaneOperator:showCoinFlyAnimation(userInfos)
    -- math.randomseed(os.time())
    -- dump(userInfos, "-----输赢分数-----")
    self:claerAllPlane()
    local sceneNow = SCENENOW["scene"]
    local size = sceneNow:getContentSize()
    local coinflyLose = function(oriPos,targetPos,i)
        local delaytime = i*0.035 + math.random(-2,2)/100
        local coin_sp = display.newSprite("#"..coin_img_path):setPosition(oriPos):setScale(0.8)
        table.insert( self.coin_nodes, coin_sp )
        oriPos = cc.pAdd(oriPos,cc.p(math.random(-30,30),math.random(-30,30) ) )
        sceneNow:addChild(coin_sp)
        targetPos = cc.pAdd(targetPos,cc.p(math.random(-50,50),math.random(-50,50) ) )
        local middleY = (targetPos.y + oriPos.y)/2
        local q1 = cc.p((targetPos.x - oriPos.x)*0.56 + oriPos.x, (targetPos.y - oriPos.y)*0.44 + oriPos.y)
        local q2 = cc.p((targetPos.x - oriPos.x)*0.67 + oriPos.x, (targetPos.y - oriPos.y)*0.8 + oriPos.y)
        local tiem = 0.2
        local mb = cc.BezierTo:create(tiem,{q1, q2, targetPos})
        local delay = cc.DelayTime:create(delaytime)
        local seq = cc.Sequence:create(delay, mb)
        coin_sp:runAction(seq)
        return delaytime
    end

    local coinflyWin = function(coin_sp, targetPos, i, delayInit)
        local delaytime = i*0.035 + math.random(-2,2)/100
        targetPos = cc.pAdd(targetPos,cc.p(math.random(-0,0),math.random(-0,0) ) )
        local tiem = 0.2
        local mb = cc.MoveTo:create(tiem, targetPos)
        local fo = cc.FadeOut:create(tiem)
        local delay = cc.DelayTime:create(delaytime + delayInit + 0.4)
        local seq = cc.Sequence:create(delay, mb, fo, cc.RemoveSelf:create()) 
        coin_sp:runAction(seq)
    end

    local tbWin = {}
    local tbLose = {}

    for i,userInfo in ipairs(userInfos) do
        local gold = userInfo.turngold
        local uid = userInfo.uid
        if gold > 0 then
            tbWin[uid] = gold
        elseif gold < 0 then
            tbLose[uid] = gold
        end
    end

   
    local worldPos = cc.p(size.width/2,size.height/2)
    local delaytime = 1
    for uid,value in pairs(tbLose) do
        local playerType = SHISANZHANG_PLAYERTYPE_TABLE[uid]
        local oriPosition = PLAYER_HEADS_POSITION_TABLE[uid]
        if  playerType then
            local coin_count = 15
            for i=1, coin_count do
                --筹码飞动 
                delaytime = coinflyLose(oriPosition,worldPos,i)
            end
        end
    end

    local coinIdx = 1
    local delaytime_2 = 0
    for uid,value in pairs(tbWin) do
        local playerType = SHISANZHANG_PLAYERTYPE_TABLE[uid]
        local targetPos = PLAYER_HEADS_POSITION_TABLE[uid]
        if  playerType then
            local coin_count = 15
            for i=1, coin_count do
                --筹码飞动 
                -- local coin_sp = self.coin_nodes[coinIdx]
                local coin_sp = table.splice(self.coin_nodes,1,1)[1]
                if coin_sp then
                    delaytime_2 = coinflyWin(coin_sp, targetPos, i, delaytime)
                    coinIdx = coinIdx + 1
                end
            end
        end
    end
    self:claerAllPlane()

end

-----------------切牌begin----------------------------
function TablePlaneOperator:initQiepai( time )
    self:set_qiepai_vw(true)
    self:change_btn_shouzhi_pos({x = 960})
    self:showCardCountDown(time)
end

function TablePlaneOperator:set_qiepai_vw(flag)
    flag = flag and true or false
    self.qiepai_vw:setVisible(flag)
    if flag == false then
        self:unscheduleGlobal()
    end
end

function TablePlaneOperator:onClickQiepaiSure(event)
    ShiSanZhangSendHandle:CLI_QIEPAI()
	self:set_qiepai_vw(false)
end

function TablePlaneOperator:onClickShouZhi(event)
	local target = event.target
	if event.name == "moved" or event.name == "began" then
        local x, y = event.x, event.y
        local pos = cc.p(x, y)
        local nodePos = target:convertToNodeSpace(pos) --这样写是为了贴近函数的原始用法
        local parentPos = target:getParent():convertToNodeSpace(pos) --这样写是为了贴近函数的原始用法
        self:change_btn_shouzhi_pos(parentPos)
	elseif event.name == "ended" or event.name == "cancelled" then
       
	end
end

function TablePlaneOperator:onClickHandCard(event)
	local target = self.qiepaiNodes
	if event.name == "moved" or event.name == "began" then
        local x, y = event.x, event.y
        local pos = cc.p(x, y)
        local nodePos = target:convertToNodeSpace(pos) --这样写是为了贴近函数的原始用法
        local parentPos = target:getParent():convertToNodeSpace(pos) --这样写是为了贴近函数的原始用法
        parentPos.x = parentPos.x + 100
        self:change_btn_shouzhi_pos(parentPos)
	elseif event.name == "ended" or event.name == "cancelled" then
	end
end

function TablePlaneOperator:change_btn_shouzhi_pos(parentPos)
    if parentPos.x < 350 or parentPos.x > 1665.60 then
        return 
    end
    self.btn_shouzhi:setPositionX(parentPos.x)
    local worldpoint = (self.btn_shouzhi:getParent()):convertToWorldSpace(self.btn_shouzhi:getPosition()) --这样写是为了贴近函数的原始用法
    local pos = self.qiepaiNodes:convertToNodeSpace(worldpoint) --这样写是为了贴近函数的原始用法
    self:changeColorByPos(pos.x - 100)
end

function TablePlaneOperator:changeColorByPos(x)
    local nodes = self.qiepaiNodes:getChildren()
    for i,node in ipairs(nodes) do
        local pos = node:getPosition()
        if pos.x < x then
            node:setColor(cc.c3b(255,255,255))
        else
            node:setColor(cc.c3b(255,255,0))
        end
    end
end

function TablePlaneOperator:showCardCountDown(timeout)
    if self.cardCountDowmHandler == nil then 
		self.beginTime = tonumber(timeout)
		self.time_bg:show()
        self.timeStr:setString(tostring(self.beginTime))
        self.cardCountDowmHandler = scheduler.scheduleGlobal(handler(self, self.playCountDown), 1.0)
    end
end

function TablePlaneOperator:playCountDown()
    self.beginTime = self.beginTime - 1
    self.timeStr:setString(tostring(self.beginTime))
	if self.beginTime == 0 then
        self:unscheduleGlobal()
    end
end

function TablePlaneOperator:unscheduleGlobal()
    self.time_bg:hide()
	if self.cardCountDowmHandler then 
		scheduler.unscheduleGlobal(self.cardCountDowmHandler)
		self.cardCountDowmHandler = nil
    end
end
-------------------切牌end--------------------------

return TablePlaneOperator