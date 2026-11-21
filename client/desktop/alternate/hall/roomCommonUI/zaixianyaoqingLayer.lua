--[[
* author:   wzw
* date:     2020-12-17
* describe:	在线邀请好友功能
* explain:  
--]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local HallServer=require("hall.HallServer")
local ZaiXianYaoQingLayer = class("ZaiXianYaoQingLayer", ViewBaseLayer)

function ZaiXianYaoQingLayer:ctor()
	 ZaiXianYaoQingLayer.super.ctor(self, "hall/res/roomCommonUI/OnlineInvitationLayer.csb")
	     GameUtils.setNodeNameBindObj(self._csbNode)
    display.doLayout(self._csbNode)
     self.inviionNode:onTouch(handler(self, self.onClick_vw), false)
     self.UserInfoTable={}
     self:initUI()
     self.UserInfoTableAll={}
     self.LinShiSave={}
end

function ZaiXianYaoQingLayer:initUI()
	  self.HaoYouListView:setScrollBarEnabled(false)       --隐藏滚动条
	self.CurPage=1
	self.inviionNode:setVisible(false)
	self.page=0
	--self.PanelUserInfo.btnYaoQing:setVisible(false)
	self.pageLabel:setString("1")
	self.btnYaoQing:setOpacity(120)
	local y=self.btnYaoQing:getPositionY()

	self.btnYaoQing:setPosition(0,y+100)
	self.btnYaoQing:setScale(1.2)
end


function ZaiXianYaoQingLayer:onClickBtnYaoQing()
	dump(USER_INFO,"---USER_INFO---")
	self.CurPage=1
	self.page=1
	self.num=0
	self.isFirst=true
	local  clubId = USER_INFO["family_id"]
	dump(clubId,"clubId")
	HallServer:CLIENT_COMMAND_ONLINE(clubId,self.CurPage-1,10)

--显示列表动画
	self.inviionNode:setVisible(true)
	local LieBiaobg=self.inviionNode.invitionLstBg
	local xy=LieBiaobg:getPosition()
	local y=LieBiaobg:getPositionY()
	LieBiaobg:setPosition(cc.p(-280,y))
	LieBiaobg:runAction(cc.MoveTo:create(0.5 , xy))

end

function ZaiXianYaoQingLayer:onClick_vw(event)
    if event.name == "began" then
    	self.UserInfoTableAll={}
    	self.UserInfoTable={}
    	self.inviionNode:setVisible(false)
    end
end


function ZaiXianYaoQingLayer:SetUserInfo(data)
	dump(data,"SetUserInfo(data)")

	table.insert(self.UserInfoTable,data)
	table.insert(self.UserInfoTableAll,data)
end

function ZaiXianYaoQingLayer:ShowViewItem(pack)

	dump(self.UserInfoTable,"self.UserInfoTable")
	dump(pack,"packback")
	if pack.uid~=USER_INFO.uid then
		return
	end
	if #self.UserInfoTable>0 then
		self.page=self.page+1
		self:ShowNewPage()
		if not self.isFirst and self.next  then
			self.next=false
			self.CurPage=self.CurPage+1
		end
		self.isFirst=false
	else
		self.UserInfoTable=clone(self.LinShiSave)
	end
	self.pageLabel:setString(self.CurPage)
			--当前翻到第几页
			dump(self.page,"self.page")

end

function ZaiXianYaoQingLayer:ShowNewPage()
	
   self.HaoYouListView:removeAllChildren()
	local k=self.CurPage*10

	for  i=1,10 do
		if self.UserInfoTable[i]  and self.UserInfoTable[i].uid~=USER_INFO.uid then
		local data=self.UserInfoTable[i]
		local  UserPanel = self.PanelUserInfo:clone()
		data.btnYQ=UserPanel:getChildByName("btnYQ")
		UserPanel:getChildByName("nickname"):setString(data.nickName)
		UserPanel:getChildByName("UserId"):setString(data.uid)
		if data.status==0 then
			UserPanel:getChildByName("btnYQ"):setVisible(true)
			UserPanel:getChildByName("online"):setVisible(true)
			UserPanel:getChildByName("playing"):setVisible(false)
		else
			UserPanel:getChildByName("btnYQ"):setVisible(false)
			UserPanel:getChildByName("online"):setVisible(false)
			UserPanel:getChildByName("playing"):setVisible(true)
		end
		--注册按钮监听
			UserPanel:getChildByName("btnYQ"):addTouchEventListener(function( sender, event )
				dump("in in in in in in ")
				local uid = self.UserInfoTable[i].uid
				local club_id = tonumber(USER_INFO["family_id"])
	local tid = USER_INFO.tid
	local activityId = USER_INFO.activity_id
	local level = USER_INFO.GroupLevel
	local nickName = USER_INFO.nick
	local portrait = USER_INFO.icon_url
	local GameConfig=USER_INFO["configData"]
	UserPanel:getChildByName("btnYQ"):setVisible(false)
	HallServer:CLINET_CMD_ENET_GAME(uid,club_id,tid,activityId,level,nickName,portrait,GameConfig)
	end)
		--头像
		local head_img=UserPanel:getChildByName("head")
    	local headSize = head_img:getContentSize().width
    	require("hall.GameCommon"):getUserHead(data.portrait, "", "", head_img, headSize, false, "", true)

		self.HaoYouListView:pushBackCustomItem(UserPanel)
	end

	end
end


function ZaiXianYaoQingLayer:onClickBtnNext()
	dump(self.CurPage,"self.CurPage")
	
	local page=0
	if (#self.UserInfoTableAll)%10>0 then
		page=(#self.UserInfoTableAll-#self.UserInfoTableAll%10)/10+1
	else
		page=(#self.UserInfoTableAll-#self.UserInfoTableAll%10)/10
	end
	dump(page,"---page")
	if self.CurPage~=page then
		self.UserInfoTable={}
		local k=(self.CurPage+1)*10
		for i=self.CurPage*10+1,k do
			local tab=clone(self.UserInfoTableAll[i])
			table.insert(self.UserInfoTable,tab)
		end
		self:ShowNewPage()
		self.CurPage=self.CurPage+1
		self.pageLabel:setString(self.CurPage)
	else
		self.next=true
		if #self.LinShiSave==0 then
			self.LinShiSave=clone(self.UserInfoTable)
		end
		self.UserInfoTable={}
		self.CurPage=self.CurPage+1
		dump(self.CurPage,"self.CurPage")
		local  clubId = USER_INFO["family_id"]
		HallServer:CLIENT_COMMAND_ONLINE(clubId,self.CurPage-1,10)
		self.CurPage=self.CurPage-1

	end	
end

function ZaiXianYaoQingLayer:onClickBtnBack()
	self.next=false
	if self.CurPage>1  then

		self.UserInfoTable={}

		local k=(self.CurPage-1)*10
		for i=(self.CurPage-2)*10+1,k do
			local tab=clone(self.UserInfoTableAll[i])
			table.insert(self.UserInfoTable,tab)
		end
		self:ShowNewPage()
		self.CurPage=self.CurPage-1
		self.pageLabel:setString(self.CurPage)
	end
end

function ZaiXianYaoQingLayer:onClickBtnYiJianAll()
	for i,v in ipairs(self.UserInfoTable) do
		if v.status==0 and v.uid~=USER_INFO.uid then
	local uid = self.UserInfoTable[i].uid
	local club_id = tonumber(USER_INFO["family_id"])
	local tid = USER_INFO.tid
	local activityId = USER_INFO.activity_id
	local level = USER_INFO.GroupLevel
	local nickName = USER_INFO.nick
	local portrait = USER_INFO.icon_url
	if v.btnYQ then
		self:HideBtnYaoqing(v.btnYQ)
	end
	--UserPanel:getChildByName("btnYQ"):setVisible(false)
	local GameConfig=USER_INFO["configData"]
	HallServer:CLINET_CMD_ENET_GAME(uid,club_id,tid,activityId,level,nickName,portrait,GameConfig)
		end
	end
	self.btnYiJianAll:setVisible(false)
		self.btnYiJianAll:performWithDelay(function()
		self.btnYiJianAll:setVisible(true)
	end,30)
end

function  ZaiXianYaoQingLayer:HideBtnYaoqing(btn)
	btn:setVisible(false)
	btn:performWithDelay(function()
		btn:setVisible(true)
	end,30)
end

return ZaiXianYaoQingLayer