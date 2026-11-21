
local ViewBaseLayer = require("hall.ViewBaseLayer")
local FamilyPlayingtip = class("FamilyPlayingtip", ViewBaseLayer)
local CocosUtil = require("hall.util.CocosUtil")

function FamilyPlayingtip:ctor(parents,index,data)
	self.parents = parents
	self.index = index 
	self.data = data or {}
    local csbPath = "hall/res/FriendScircle/playingtip.csb"
    FamilyPlayingtip.super.ctor(self, csbPath)
    self:setNodeEventEnabled(true)

    self:initUI()
end

function FamilyPlayingtip:initUI( )
	self.btn_close:onClick(CocosUtil:Bind(self.OnClickBtnClose , self))
	self.btn_closs:onClick(CocosUtil:Bind(self.OnClickBtnCloss , self))
	self.btn_playingwf:onClick(CocosUtil:Bind(self.OnClickBtnPlayingwf , self))

	self.wanfamc:setString("玩法"..self.index)
	-- dump(self.data[self.index])
	if not self.data[self.index] then return end
	if not self.data[self.index].gameConfig then return end
	if not self.data[self.index].gameConfig.wanfa then return end
	local strWF = self.data[self.index].gameConfig.wanfa.optionName
	self.wfzhihou:setString(strWF)
end

function FamilyPlayingtip:OnClickBtnClose()
	self:removeSelf()
end

function FamilyPlayingtip:OnClickBtnCloss()
	print("====关闭该玩法====",self.parents.family_id)


	self:removeSelf()
end

function FamilyPlayingtip:OnClickBtnPlayingwf()
	self.parents:OnClickBtnTake()
	self:removeSelf()
end

function FamilyPlayingtip:onEnter()
end

function FamilyPlayingtip:onExit()
end

return FamilyPlayingtip