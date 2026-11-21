--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]


local Figure = class("Figure")

function Figure:ctor(parents)
	self.__node = cc.CSLoader:createNode("hall/res/FriendScircle/figure.csb"):addTo(parents)
	self:InitUI()
end

function Figure:InitUI() 
	for k , node in pairs(self.__node:getChildren()) do 
		local name = node:getName()
		self[name] = self.__node:getChildByName(name)
	end
end 

function Figure:SetVisible(status)
	self.__node:setVisible(status)
end 

function Figure:SetPositionX(x)
  	self.__node:setPositionX(x)
end 

function Figure:SetPositionY(y)
	self.__node:setPositionY(y)
end

function Figure:SetString(label)
	self.Text_1:setString(label)
end 

function Figure:SetLabelPosition(x , y)
	self.Text_1:setPosition(x , y)
end 

function Figure:__delete()
	self.__node:removeFromParent()
end 

return Figure