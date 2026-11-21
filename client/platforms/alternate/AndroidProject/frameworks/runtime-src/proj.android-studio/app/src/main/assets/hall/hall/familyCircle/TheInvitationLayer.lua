--[[
* author:   wzw
* date:     2020-12-17
* describe:	邀请进房提示
* explain:  
--]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local HallServer=require("hall.HallServer")
local TheInvitationLayer = class("TheInvitationLayer", ViewBaseLayer)

function TheInvitationLayer:ctor(data)
	 TheInvitationLayer.super.ctor(self, "hall/res/FriendScircle/TheInvitationLayer.csb")
	 self.data=data
 	self:SetInfo(data)
end


function TheInvitationLayer:onClickBtnTongYi()
    SCENENOW['scene'].hallMainLayer.familyMainlayer:CreateGameTable(2 , self.RoomInfo , nil, 0)
    self:removeSelf()
end

function TheInvitationLayer:onClickBtnJuJue()
    self:removeSelf()
end

function TheInvitationLayer:onClickBtnClose()
    self:removeSelf()
end

function TheInvitationLayer:SetInfo(data)
	local GameConfig=SCENENOW['scene'].hallMainLayer.familyMainlayer.gameConfigList	
	local gameName=""
	local dataC = json.decode(data.config)
	local  wanfa = dataC or ""
	dump(GameConfig,"---GameConfig---")
	dump(data,"---data---")
	dump(dataC,"dataC")
	
	for i,v in pairs(GameConfig) do
		dump(v,"***------")
		for j,k in pairs(v) do
			if data.level==k.level then
				gameName=k.gameConfig.gameName
			end
		end
	end


	self.RoomInfo={}
	self.RoomInfo.config={}
	self.RoomInfo.config.id=dataC["id"]
	self.RoomInfo.config.table_info={}
	self.RoomInfo.config.level=data.level
	self.RoomInfo.config.table_id=data.tid
	self.RoomInfo.config.table_info.activityId=data.activityId
	--设置头像
	local head_img=self.ImageHead
    local headSize = head_img:getContentSize().width
    require("hall.GameCommon"):getUserHead(data.portrait, "", "", head_img, headSize, false, "", true)
    --
    self.TextName:setString(data.nickName)
    self.textId:setString(data.uid)
    --这里首先要要获取桌子的config
    self.TextMessage:setString("我是来自".."("..data.club_id..")".."圈子的"..data.nickName..",\n".."快来一起玩"..gameName.."吧！")
    --self.TextConfig:setString("游戏名： "..gameName.."\n"..wanfa)
    self.TextConfig:setString("游戏名： "..gameName)
end

return TheInvitationLayer