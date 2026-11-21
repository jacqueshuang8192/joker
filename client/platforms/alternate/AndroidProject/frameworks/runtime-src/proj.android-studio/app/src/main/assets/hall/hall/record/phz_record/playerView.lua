local playerView = class("playerView")

function playerView:ctor(playerNode, level)
	self.level = level
	playerNode:hide()
	self.playerNode = playerNode
	self:initUI()
end

function playerView:getPosition()
	return self.playerNode:getPosition()
end

function playerView:onEnter()

end

function playerView:onExit()
end


function playerView:initUI()
	self.playHeadImg = self.playerNode.userInfo:getChildByName("playHeadImg")
	self.playName = self.playerNode.userInfo:getChildByName("playName")
	self.playScore = self.playerNode.userInfo:getChildByName("playScore")
	self.huxi = self.playerNode.userInfo:getChildByName("huxi")
	self.img_zhuang = self.playerNode.userInfo:getChildByName("img_zhuang")
	self.node_tips = self.playerNode.userInfo:getChildByName("tipsNode")
	self.font_type = self.playerNode.userInfo.font_type:hide()
	self.playScore:setString("积分：0")
	self.huxi:setString("胡息：0")
	self.img_zhuang:setVisible(false)

	if self.level == 379 then--沅江鬼胡子
		self.huxi:hide()
	end
	
end

function playerView:setData( data )
	self.data = data
	self.playerNode:show()
	self:refreshPlayerInfo(data.photoUrl, data.uid, data.sex, data.nickName)
	self:setScore(data.score)
end

--刷新玩家的积分分数
function playerView:setScore(score)
	self.playScore:setString("积分："..tonumber(score)/100)
end

function playerView:setHuXi(huxi)
	-- self.huxi:setString("胡息："..huxi)
	self.huxi:setString("分："..huxi)--碰碰胡
end

function playerView:clearPlayerData()
	self.playName:setString("")
	self.img_zhuang:setVisible(false)
end

function playerView:refreshPlayerInfo(icon_url, uid, sex, name, ip, addres)
	local worldpoint = (self.playHeadImg:getParent()):convertToWorldSpace(self.playHeadImg:getPosition()) --这样写是为了贴近函数的原始用法
	self.worldpoint = worldpoint
	local size = self.playHeadImg:getContentSize()
	require("hall.GameCommon"):getUserHead(icon_url, uid, sex, self.playHeadImg, size.width, false, name, true, ip, addres)
	name = require("hall.GameCommon"):formatNick(name, 3)
	self.playName:setString(name or "")
end

function playerView:isShowZhuangIMG(isShow) 
	self.img_zhuang:setVisible(isShow or false)
end

function playerView:ShowTimerText(tTime)
	
end

--停止闪烁
function playerView:stopShanShou()

end

--吃碰杠胡等
function playerView:setFontType(str)
	self.font_type:setString(str)
	self.font_type:show()
end

function playerView:hideFontType()
	self.font_type:hide()
end

return playerView