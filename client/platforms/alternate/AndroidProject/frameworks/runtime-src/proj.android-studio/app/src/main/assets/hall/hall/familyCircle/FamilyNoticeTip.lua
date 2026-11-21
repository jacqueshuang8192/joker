--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local LINE_HEIGTH = 80

local ViewBaseLayer = require("hall.NewViewBaseLayer")
local FamilyNoticeTip = class("FamilyNoticeTip"  , ViewBaseLayer)
local FamilyData = require("hall.familyCircle.FamilyData")
local CommonTips = require("hall.tips.CommonTips")
local FamilyUntils = require("hall.familyCircle.FamilyUntils")

function FamilyNoticeTip:ctor(family_id)
    -- body
    local csbPath = "hall/res/FriendScircle/noticeTip.csb"
    FamilyNoticeTip.super.ctor(self, csbPath)
    self:enableMask(true)
    self.family_id = family_id
    self:InitGame()
    self.btnCreate:onClick(handler(self, self.onClickBtnCreate), true)

end

function FamilyNoticeTip:InitGame( ... )
    
end

function FamilyNoticeTip:onClickBtnCreate()
    print ("-创建房间")
    local notice = self.input_word:getString()
    FamilyData:GetClubNoticeInfo(self.family_id , USER_INFO["uid"] , notice , handler(self , self.SendInterFace))
end

function FamilyNoticeTip:SendInterFace(notice_data)
    CommonTips:showTips(FamilyUntils:SetCommTipLabel("修改联盟公告成功"))    
    self:getParent():InitBroadCast() --公告

end 

function FamilyNoticeTip:onClickBtnClose()
    self:removeSelf()
end

return FamilyNoticeTip