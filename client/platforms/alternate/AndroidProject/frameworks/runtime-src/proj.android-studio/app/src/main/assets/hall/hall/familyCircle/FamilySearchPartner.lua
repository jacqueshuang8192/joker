--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local ViewBaseLayer = require("hall.ViewBaseLayer")
local FamilySearchPartner = class("FamilySearchPartner", ViewBaseLayer)
local CommonTips = require("hall.tips.CommonTips")
local FamilyUntils = require("hall.familyCircle.FamilyUntils")
local FamilyData = require("hall.familyCircle.FamilyData")
local CocosUtil = require("hall.util.CocosUtil")

function FamilySearchPartner:ctor(parents,secondParents)
 	self.parents = parents
 	self.secondParents = secondParents
 	local csbPath = "hall/res/FriendScircle/search.csb"
 	FamilySearchPartner.super.ctor(self, csbPath)
 	self:InitGame()

 	self.btn_creat:onClick(CocosUtil:Bind(self.onClickBtnSure , self))
end

function FamilySearchPartner:InitGame()
	self.input_word:setString("")
	self.bonus_txt:setString("")

end

function FamilySearchPartner:onClickBtnSure()
	local uid = self.input_word:getString()
	local my_uid = USER_INFO["uid"]
	local bonus = self.bonus_txt:getString()
	print("========666666======")
	print("========666666======")
	print("========666666======")
	print("========666666======")
	print (self.parents.family_id , uid , bonus , my_uid ,  "---打印一个家庭id---" , "---一个uid---")
	FamilyData:AddHhr(my_uid , uid , self.parents.family_id , bonus , handler(self , self.SetPartner))
end

function FamilySearchPartner:SetPartner(data)
	-- dump (data , "----SetPartner---")
	
	CommonTips:showTips(FamilyUntils:SetCommTipLabel("添加合伙人成功"))
	self.secondParents:refreshHhrList()
	self:removeSelf()
end

function FamilySearchPartner:onClickBtnClose()
	self:removeSelf()
end

return FamilySearchPartner