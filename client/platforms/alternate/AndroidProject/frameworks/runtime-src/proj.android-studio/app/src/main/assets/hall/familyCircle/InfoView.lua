local InfoView = class("InfoView", function()
    return cc.CSLoader:createNode("hall/res/FriendScircle/SpeedjoinView/InfoView.csb")
end)

local GetGameName = require("hall.familyCircle.GetGameName")

function InfoView:ctor(str)
    self:setMask()
    GameUtils.setNodeNameBindObj(self)
    self:initUI()
    self:initEvent()
    self.txt_info:setString(str)
end



function InfoView:initUI()
    self.txt_info = self.root.txt_info
    self.btnClose = self.root.btnClose
end

function InfoView:initEvent()
    self.btnClose:onClick(handler(self, self.onClickBtnClose), true)
end

function InfoView:onClickBtnClose()
    self:removeSelf()
end

function InfoView:setMask()
	local director = cc.Director:getInstance()
    local size = director:getWinSize()
    -- self:setAnchorPoint(0.5, 0.5)
    -- self:setPosition(size.width / 2, size.height / 2)


    self.maskLayout = ccui.Layout:create()
    self.maskLayout:setAnchorPoint(cc.p(0.5, 0.5))
    self.maskLayout:setContentSize(cc.size(size.width, size.height))
    local size = self:getContentSize()
    self.maskLayout:setPosition(cc.p(size.width / 2, size.height / 2))
    self.maskLayout:setBackGroundColorType(1)
    self.maskLayout:setBackGroundColor(cc.c3b(0, 0, 0))
    self.maskLayout:setBackGroundColorOpacity(150)
    self.maskLayout:setTouchEnabled(true)
    self.maskLayout:setVisible(true)
    self:addChild(self.maskLayout, -1000)
end

function InfoView:onExit()
end

return InfoView