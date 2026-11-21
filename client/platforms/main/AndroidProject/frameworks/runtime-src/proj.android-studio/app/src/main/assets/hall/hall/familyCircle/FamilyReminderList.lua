--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local FamilyReminderList = class("FamilyReminderList", ViewBaseLayer)

function FamilyReminderList:ctor(word)

    local csbPath = (("join" == word or "exit" == word) and "hall/res/FriendScircle/reminderlist_1.csb") or "hall/res/FriendScircle/reminderlist.csb"
    print (csbPath , "-------FamilyReminderList--")
    FamilyReminderList.super.ctor(self, csbPath)

end

-- function FamilyReminderList:InitUI() 
-- 	for k , node in pairs(self.__node:getChildren()) do 
-- 		local name = node:getName()
-- 		self[name] = self.__node:getChildByName(name)
-- 	end
-- end 

-- function FamilyReminderList:GetObj()
-- 	return self.layout
-- end 

function FamilyReminderList:CloneLayout(clone_layout)
    local child = {}
    for k , v in pairs(clone_layout:getChildren()) do
        local name = v:getName()
        child[name] = v
    end
    return child
end

-- function FamilyReminderList:RemoveFromParents()
--     self.__node:removeFromParent()
--     self = nil
-- end 



function FamilyReminderList:GetObj()
    return self.layout
end

-- function FamilyReminderList:CloneLayout(clone_layout)
--     local clone_layout = clone_layout:getChildByName("list_1")
--     local child = {}
--     for k , v in pairs(clone_layout:getChildren()) do
--         local name = v:getName()
--         child[name] = v
--     end
--     return child
-- end
 

return FamilyReminderList