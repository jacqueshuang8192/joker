--[[
* author:   w
* date:     2019-1-23
* describe: 点击新大厅更多游戏的界面操作
--]]

local MoreGameslayer = class("MoreGameslayer" , function ()
	return cc.CSLoader:createNode("hall/myNewHall/MoreGameslayer.csb") 
end)

function MoreGameslayer:ctor()
   self:initGetValidNode()
end

function MoreGameslayer:initGetValidNode()

   self.root = self:getChildByName("root")
   self.moreGameBack = self.root:getChildByName("moreGameBack")
   self.returnButton = self.moreGameBack:getChildByName("returnButton")
   self.gameNameList = self.moreGameBack:getChildByName("gameNameList")
   self.gamePanel = self.moreGameBack:getChildByName("gamePanel")

   self.returnButton:addTouchEventListener(handler(self, self.onTouchEvent))
end

function AddCludList:onTouchEvent(sender, event)

	if event == TOUCH_EVENT_BEGAN then
        sender:setScale(0.9)
    elseif event == TOUCH_EVENT_ENDED then
        sender:setScale(1)
        local touchName = sender:getName()
        if touchName == returnButton then
        	self:removeSelf()
        end
    end
end

return MoreGameslayer
