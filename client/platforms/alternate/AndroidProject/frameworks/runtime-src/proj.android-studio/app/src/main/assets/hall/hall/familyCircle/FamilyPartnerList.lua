--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local FamilyPartnerList = class("FamilyPartnerList", ViewBaseLayer)

function FamilyPartnerList:ctor()

    local csbPath = "hall/res/FriendScircle/partnerlist.csb"
    FamilyPartnerList.super.ctor(self, csbPath)

end

function FamilyPartnerList:CloneLayout(clone_layout)
    local child = {}
    
    local function CloneChild(clone_layout)
        if not clone_layout then return end
        if clone_layout.getName then 
            local name = clone_layout:getName()
            child[name] = clone_layout
        end 
        local child_obj = clone_layout:getChildren() 
        if #child_obj ~= 0 then      
            for k , v in pairs(clone_layout:getChildren()) do 
                CloneChild(v)
            end
        end
    end
    CloneChild(clone_layout)
    return child
end

function FamilyPartnerList:GetObj()
    return self.root
end


return FamilyPartnerList