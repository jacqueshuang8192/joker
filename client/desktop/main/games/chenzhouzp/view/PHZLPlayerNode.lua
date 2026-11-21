local PHZLPlayerNode = class("PHZLPlayerNode", function ()
   return cc.CSLoader:createNode("chenzhouzp/res/PHZLPlayerNode.csb")
end)

function PHZLPlayerNode:ctor(parent)
	self.parent = parent
	self:setNodeEventEnabled(true)
	self.node = cc.Node:create()
	self:addChild(self.node)
	self:initUI()
end

function PHZLPlayerNode:onEnter()
end

function PHZLPlayerNode:onExit()
	self.node:stopAllActions()
	self.img_hu:stopAllActions()
end

function PHZLPlayerNode:getNodePos()
	return self.parent:getPosition()
end

function PHZLPlayerNode:initUI()
	self.img_shan = self:getChildByName("img_shan")
	self.playHeadImg = self:getChildByName("playHeadImg")
	self.playName = self:getChildByName("playName")
	self.playScore = self:getChildByName("playScore")
	self.huxi = self:getChildByName("huxi")
	self.img_zhuang = self:getChildByName("img_zhuang")
	self.txt_djs = self:getChildByName("txt_djs")
	self.img_zhunbei = self:getChildByName("img_zhunbei")
	self.node_tips = self:getChildByName("tipsNode")
	self.img_zhunbei:setVisible(false)
	self:getChildByName("X_4"):setVisible(false)
	self.playScore:setString("0")
	self.huxi:setString("0")
	--self.huxi:setVisible(false)
	--self:getChildByName("Text_2"):setVisible(false)
	-- self.playScore:setVisible(false)
	self.img_shan:setVisible(false)
	self.txt_djs:setVisible(false)
	self.img_zhuang:setVisible(false)

	self.img_hu = self:getChildByName("img_hu")
    self.img_hu:setVisible(false)
end

--刷新玩家的积分分数
function PHZLPlayerNode:refreshPlayer_FXScore(_score)
	self.playScore:setString(tonumber(_score)/100)
end
function PHZLPlayerNode:setPiaoValue(_score)
	self.huxi:setString(_score)
end
function PHZLPlayerNode:showImgHu()
	local this  = self
	self.img_hu:setVisible(true)
	local dt = cc.DelayTime:create(1)
	local function funcHu()
		this.img_hu:setVisible(false)
		this.img_hu:stopAllActions()
	end
	local callFunc_1 = cc.CallFunc:create(funcHu)
	local seq = cc.Sequence:create(dt,callFunc_1)
	self.img_hu:stopAllActions()
	self.img_hu:runAction(seq)
end

function PHZLPlayerNode:isShowZhunBeiIMG(isShow)
	self.img_zhunbei:setVisible(isShow)
end

function PHZLPlayerNode:clearPlayerData()
	self.img_shan:setVisible(true)
	self.playName:setString("")
	-- self.playScore:setVisible(false)
	self.img_zhuang:setVisible(false)
	self.txt_djs:stopAllActions()
	self.txt_djs:setString("")
end


function PHZLPlayerNode:refreshPlayerInfo(icon_url,uid,sex,name,ip,addres)
	local   worldpoint = (self.playHeadImg:getParent()):convertToWorldSpace(self.playHeadImg:getPosition()) --这样写是为了贴近函数的原始用法
	self.worldpoint = worldpoint
	require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(uid, worldpoint)
	require("hall.GameCommon"):getUserHead(icon_url, uid, sex, self.playHeadImg, 80, false, name,false,ip,addres)
	name = require("hall.GameCommon"):formatNick(name, 3)
	self.playName:setString(name or "")
end

function PHZLPlayerNode:isShowZhuangIMG(isShow)
	self.img_zhuang:setVisible(isShow or false)
end

function PHZLPlayerNode:ShowTimerText(tTime)
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
	local BlinkMove = cc.Blink:create(1, 5);
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
function PHZLPlayerNode:stopShanShou()
	self.img_shan:stopAllActions()
    self.img_shan:setVisible(false)
end

function PHZLPlayerNode:showScoreTips(str)
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

return PHZLPlayerNode