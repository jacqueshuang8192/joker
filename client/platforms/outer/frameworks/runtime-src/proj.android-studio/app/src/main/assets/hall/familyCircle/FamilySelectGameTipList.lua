--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local FamilySelectGameTipList = class("FamilySelectGameTipList")
function FamilySelectGameTipList:ctor()
	self.__node = cc.CSLoader:createNode("hall/res/FriendScircle/selectTheGametiplist.csb")
	self:InitUI()
end

function FamilySelectGameTipList:InitUI() 
	for k , node in pairs(self.__node:getChildren()) do 
		local name = node:getName()
		self[name] = self.__node:getChildByName(name)
	end
end 

function FamilySelectGameTipList:GetObj()
	return self.layout
end 

function FamilySelectGameTipList:CloneLayout(clone_layout)
    local child = {}
    for k , v in pairs(clone_layout:getChildren()) do
        local name = v:getName()
        child[name] = v
    end
    return child
end

function FamilySelectGameTipList:RemoveFromParents()
    self = nil
end 

return FamilySelectGameTipList

