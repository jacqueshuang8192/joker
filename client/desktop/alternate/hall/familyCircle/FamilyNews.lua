--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local ViewBaseLayer = require("hall.ViewBaseLayer")
local FamilyNews = class("FamilyNews", ViewBaseLayer)
local FamilyReminderList = require("hall.familyCircle.FamilyReminderList")
local clubSendData = require("hall.view.clubView.clubSendData")
local FamilyData = require("hall.familyCircle.FamilyData")
local CommonTips = require("hall.tips.CommonTips")
local CocosUtil = require("hall.util.CocosUtil")
local FamilyUntils = require("hall.familyCircle.FamilyUntils")


function FamilyNews:ctor()
    local csbPath = "hall/res/FriendScircle/reminder_tip.csb"
    FamilyNews.super.ctor(self, csbPath)
    self:InitGame()
end

function FamilyNews:InitGame()
    self.ListView:setScrollBarEnabled(false)

    self:RushListView("join")
    self.friend_path = {"hall/res/FriendScircle/image/information/ttf_message.png" , 
                        "hall/res/FriendScircle/image/information/1_4.png"}
    self.join_path = {"hall/res/FriendScircle/image/information/ttf_join.png" ,
                        "hall/res/FriendScircle/image/information/1_3.png"} 
    self.exit_path = {"hall/res/FriendScircle/image/information/ttf_apply.png" , 
                        "hall/res/FriendScircle/image/information/1_2.png"}
    self.invite_path = {"hall/res/FriendScircle/image/information/ttf_invite.png" , 
                            "hall/res/FriendScircle/image/information/1_1.png"}
    self.my_news:setVisible(false)
end

function FamilyNews:onClickBtnJoin(...)
    print ("加入申请")
    self.friend_news:setVisible(true)
    self.my_news:setVisible(false)
    self.btnJoin:loadTextures(self.join_path[2] , self.join_path[2] , nil)
    self.btnInvite:loadTextures(self.invite_path[1] , self.invite_path[1] , nil)
    self:RushListView("join")
end

function FamilyNews:onClickBtnInvite(...)
    print ("我的邀请")

    self.friend_news:setVisible(false)
    self.my_news:setVisible(true)
    self.btnJoin:loadTextures(self.join_path[1] , self.join_path[1] , nil)
    self.btnInvite:loadTextures(self.invite_path[2] , self.invite_path[2] , nil)
    self:RushListView("invite")
end

function FamilyNews:RushListView(word)
    local family = {
                    join = handler(self, self.JoinFamily) , 
                    invite = handler(self, self.MyInvite) ,
                }
    family[word]()
end

function FamilyNews:FamilyContent()
    self.ListView:removeAllChildren()
end

function FamilyNews:JoinFamily(word)
    FamilyData:GetMessage(handler(self, self.InitJoinView), 2)
end

function FamilyNews:InitJoinView(data)
    if tolua.isnull(self.ListView) then
        return
    end
    self.ListView:removeAllChildren()
    if not next(data) then return end 

    local list = FamilyReminderList.new("join")
    local family_list = list:GetObj()
    local path = "hall/res/FriendScircle/image/information/btn_agree.png"
    for k , list_data in ipairs(data) do
        local clone_layout = family_list:clone()
        local layout = list:CloneLayout(clone_layout)
        layout.btn_agree:loadTextures(path , path , nil)
        layout.btn_agree:onClick(CocosUtil:Bind(self.BtnAgree , self , list_data.playerId , list_data.groupId))
        layout.name:setString(list_data.nickName .. "[" .. "ID:" .. list_data.playerId .. "]")
        layout.time:setVisible(false)
        self.ListView:pushBackCustomItem(clone_layout)
    end
end

function FamilyNews:BtnAgree(uid , clubId)
    local function callback(returnCode, data)
        if 0 == returnCode then
            self:RushListView("join")
            CommonTips:showTips(FamilyUntils:SetCommTipLabel("已回复该玩家"))
        else
            CommonTips:showTips(FamilyUntils:SetCommTipLabel("玩家已经在该联盟中！"))
        end 
    end
    local status = 1
    if type == 5 then
        local data={
            playerId = USER_INFO["uid"] ,
            owerId = uid,
            groupId = clubId,
            status = status,
            playerId1 = uid
        }
        clubSendData:requestReplyInvite(data, callback)
    else
        local data = {
            playerId = uid,
            owerId = USER_INFO["uid"],
            groupId = clubId,
            status = status,
            playerId1 =  USER_INFO["uid"] 
        }
        clubSendData:requestReplyJoinClub(data, callback)
    end
end

function FamilyNews:ExitFamily()
    self.ListView:removeAllChildren()
end

function FamilyNews:MyInvite()
    FamilyData:GetMessage(handler(self, self.InitInviteView), 4)
end

function FamilyNews:InitInviteView(data)
    print("========FamilyNews:InitInviteView======")
    -- dump(data)
    if tolua.isnull(self) then return end
   
    if not next(data) then return end 
    self.ListView:removeAllChildren()
    local list = FamilyReminderList.new("invite")
    local family_list = list:GetObj()
    for k , list_data in ipairs(data) do
        local clone_layout = family_list:clone()
        local layout = list:CloneLayout(clone_layout)
        if layout.btn_agree then
            layout.btn_agree:loadTextures(path , path , nil)
            layout.btn_agree:onClick(CocosUtil:Bind(self.BtnAgree , self , list_data.playerId , list_data.groupId))
            layout.name:setString(list_data.nickName .. "[" .. "ID:" .. list_data.playerId .. "]")
        end
        layout.name:setString(list_data.nickName)
        layout.message:setString("邀请进入联盟："..list_data.groupId)
        layout.time:setString("时间点")
        self.ListView:pushBackCustomItem(clone_layout)
    end

end

function FamilyNews:onClickBtnClose(...)
    self:removeSelf()
end

return FamilyNews