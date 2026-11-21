--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local FamilySelectGameTip = class("FamilySelectGameTip", ViewBaseLayer)
local FamilySelectGameTipList = require("hall.familyCircle.FamilySelectGameTipList")

function FamilySelectGameTip:ctor()
    local csbPath = "hall/res/FriendScircle/selectTheGametip.csb"
    FamilySelectGameTip.super.ctor(self, csbPath)
    self:InitGame()
end

function FamilySelectGameTip:InitGame(...)
    -- body
    self.ListView:setScrollBarEnabled(false)
    local list = FamilySelectGameTipList.new()
    local select_list = list:GetObj()
    for i = 1 , 5 do 
        local clone_layout = select_list:clone()
        local layout = list:CloneLayout(clone_layout)
        self.ListView:pushBackCustomItem(clone_layout)
    end
end

function FamilySelectGameTip:onClickBtnClose( ... )
    -- body
    self:removeSelf()
end

return FamilySelectGameTip