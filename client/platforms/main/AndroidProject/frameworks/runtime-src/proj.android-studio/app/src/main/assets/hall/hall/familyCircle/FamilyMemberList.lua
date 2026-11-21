--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
--]]
local ViewBaseLayer = require("hall.ViewBaseLayer")
local FamilyMemberList = class("FamilyMemberList", ViewBaseLayer)

function FamilyMemberList:ctor()
    local csbPath = "hall/res/FriendScircle/memberlist.csb"
    FamilyMemberList.super.ctor(self, csbPath)
end

function FamilyMemberList:GetObj()
    return self.root
end

--add by zzy 2019-7-10
function FamilyMemberList:setContentSizeByNode( _node )
    local size = _node:getContentSize()
    local precent = SCREEN_WIDTH/1280
    _node:setContentSize(cc.size(size.width * precent, size.height))
end


function FamilyMemberList:CloneLayout(clone_layout)
    local clone_layout = clone_layout:getChildByName("list_1")
    local child = {}
    for k , v in pairs(clone_layout:getChildren()) do
        local name = v:getName()
        child[name] = v
    end
    return child
end
 

return FamilyMemberList