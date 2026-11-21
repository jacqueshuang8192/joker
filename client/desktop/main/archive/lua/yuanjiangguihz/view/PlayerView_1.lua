local PlayerView = class("PlayerView")

function PlayerView:ctor(player)
	self.player = player
	self.node = cc.Node:create()
	self.player:addChild(self.node)
	self:initUI()
	local listener = function(event)
		local name = event.name
		if name == "enter" then
			self:onEnter()
		elseif name == "exit" then
			self:onExit()
		end
	end
	self.node:setNodeEventEnabled(true, listener)
end

function PlayerView:onEnter()
end

function PlayerView:onExit()
	self.node:stopAllActions()
end

function PlayerView:initUI()
	self.img_shan = self.player:getChildByName("img_shan")
	self.playHeadImg = self.player:getChildByName("playHeadImg")
	self.playName = self.player:getChildByName("playName")
	self.playScore = self.player:getChildByName("playScore")
	self.huxi = self.player:getChildByName("huxi"):hide()
	-- self.piao = self.player:getChildByName("piao")
	self.img_zhuang = self.player:getChildByName("img_zhuang")
	self.txt_djs = self.player:getChildByName("txt_djs")
	self.img_zhunbei = self.player:getChildByName("img_zhunbei")
	self.node_tips = self.player:getChildByName("tipsNode")
	self.img_zhunbei:setVisible(false)
	self.player:getChildByName("X_4"):setVisible(false)
	self:refreshPlayer_FXScore("0")
	-- self.piao:setVisible(false)
	--self.piao:setString('0')
	--self.player:getChildByName("Text_2"):setVisible(false)
	self.img_shan:setVisible(false)
	self.txt_djs:setVisible(false)
	self.img_zhuang:setVisible(false)

	self.img_hu = self.player:getChildByName("img_hu")
	self.img_hu:setVisible(false)
end

--刷新玩家的积分分数
function PlayerView:refreshPlayer_FXScore(_score)
	local score = tonumber(_score)/100
	local str = "积分："..score
	local name = self.player:getName()
	if name == "player_1" then
		str = score .. "：积分"
	end

	self.playScore:setString(str)
end
function PlayerView:setFenPointValue(_score)
	local str = "胡息：".._score
	local name = self.player:getName()
	if name == "player_1" then
		str = _score .. "：胡息"
	end
	self.huxi:setString(str)
end

function PlayerView:setPiaoValue(_score)
	-- self.piao:setString(_score)
end

function PlayerView:showImgHu()
	self.img_hu:setVisible(true)
end

function PlayerView:hideImgHu()
	self.img_hu:setVisible(false)
end

function PlayerView:isShowZhunBeiIMG(isShow)
	self.img_zhunbei:setVisible(isShow)
end

function PlayerView:clearPlayerData()
	self.img_shan:setVisible(true)
	self.playName:setString("")
	self.img_zhuang:setVisible(false)
	self.txt_djs:stopAllActions()
	self.txt_djs:setString("")
	--self:setFenPointValue(0)
end

function PlayerView:refreshPlayerInfo(icon_url,uid,sex,name,ip,addres)
	local   worldpoint = (self.playHeadImg:getParent()):convertToWorldSpace(self.playHeadImg:getPosition()) --这样写是为了贴近函数的原始用法
	self.worldpoint = worldpoint
	local size = self.playHeadImg:getContentSize()
	require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(uid, worldpoint)
	require("hall.GameCommon"):getUserHead(icon_url, uid, sex, self.playHeadImg, size.width, false, name,false,ip,addres)
	name = require("hall.GameCommon"):formatNick(name, 3)
	self.playName:setString(name or "")
end

function PlayerView:isShowZhuangIMG(isShow) 
	self.img_zhuang:setVisible(isShow or false)
end

function PlayerView:ShowTimerText(tTime)
	if tTime == -1 then
		self.node:stopAllActions()
        self.img_shan:stopAllActions()
        self.img_shan:setVisible(false)
        self.txt_djs:setVisible(false)
        return
	end
	self.img_shan:stopAllActions()
	local timeStr = string.format("%02d",tTime)
    self.txt_djs:setString(timeStr)
	self.txt_djs:setVisible(true)
	self.img_shan:setVisible(true)
	local BlinkMove = cc.Blink:create(1, 5)
	self.img_shan:runAction(cc.RepeatForever:create(BlinkMove))
	local dt = cc.DelayTime:create(1)
        local function onTime()
	        tTime = tTime - 1
            local timeStr = string.format("%02d",tTime)
            self.txt_djs:setString(timeStr)
            if tTime <= 0 then
    	        self.node:stopAllActions()
    	        -- self.img_shan:stopAllActions()
    	        -- self.img_shan:setVisible(false)
    	        self.txt_djs:setVisible(false)
            end
       end 
    local funcTime = cc.CallFunc:create(onTime)
    local seq = cc.Sequence:create(dt,funcTime)
    self.node:stopAllActions()
    self.node:runAction(cc.RepeatForever:create(seq))
end

--停止闪烁
function PlayerView:stopShanShou()
	self.img_shan:stopAllActions()
    self.img_shan:setVisible(false)
end


function PlayerView:showScoreTips(str)
	local tempNode = cc.Node:create()
	self.node_tips:addChild(tempNode)
	local tipslabel = display.newTTFLabel({
        text = str,
        font = "fonts/FZY3JW.ttf",
        size = 40,
        color = cc.c3b(220, 255, 0),
        align = cc.TEXT_ALIGNMENT_CENTER
    })
    tempNode:addChild(tipslabel)
    local onRemove = cc.CallFunc:create(function ( fc ) fc:removeFromParent() end)
    local seq = cc.Sequence:create(cc.DelayTime:create(2),onRemove)
    tempNode:runAction(seq)

    tempNode:runAction(cc.MoveBy:create(1.5,cc.p(0,50)))

end

function PlayerView:setVisible( flag )
	self.player:setVisible( flag )
end

function PlayerView:hide(  )
	self.player:setVisible( false )
end

function PlayerView:show(  )
	self.player:setVisible( true )
end

return PlayerView