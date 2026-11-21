--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local ViewBaseLayer = require("hall.ViewBaseLayer")
local FamilyCreateTip = class("FamilyCreateTip", ViewBaseLayer)
local clubSendData = require("hall.view.clubView.clubSendData")
local CommonTips = require("hall.tips.CommonTips")
local FamilyData = require("hall.familyCircle.FamilyData")
local CocosUtil = require("hall.util.CocosUtil")
local FamilyUntils = require("hall.familyCircle.FamilyUntils")

function FamilyCreateTip:ctor(parentes)
    -- dump(USER_INFO)
    local csbPath = "hall/res/FriendScircle/createFamilyTip.csb"
    FamilyCreateTip.super.ctor(self, csbPath)
    self.input_word:setString("") 
    self.__parentes = parentes
end

function FamilyCreateTip:onClickBtnCreate(sender , event)
    local family_name = self.input_word:getString()
    local number = CocosUtil:LuaWordNum(family_name)
    if number < 2 or number > 8 then 
        CommonTips:showTips(FamilyUntils:SetCommTipLabel("输入正确的联盟名称"))
        self.input_word:setString("")
        return 
    end 
    self:CreateFamilySucess(family_name)
end

function FamilyCreateTip:CreateFamilySucess(family_name)

    local data =  {
        playerId = USER_INFO["uid"],
        groupName = family_name,
        --changed by zzy 后台数据更改，前端配合
        configArrays = json.encode({SelectGameConfig = "[]", is_config = 0, is_agree = 1, is_invitation = 1})
        -- configArrays = json.encode({SelectGameConfig = {}, is_config = 0, is_agree = 1, is_invitation = 1})
    }  

    local function callback(returnCode, data, error)
        if 0 == returnCode then
            CommonTips:showTips(FamilyUntils:SetCommTipLabel("创建联盟成功"))
            self.__parentes:loadClub()
            self:removeSelf()
            return    
        end
        CommonTips:showTips(FamilyUntils:SetCommTipLabel(error))
    end
    clubSendData:requestCreateClub(data, callback)
    self:setVisible(false) 
end 

function FamilyCreateTip:onClickBtnClose(...)
    self:removeSelf()
end 


return FamilyCreateTip