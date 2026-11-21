--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local ViewBaseLayer = require("hall.ViewBaseLayer")
local JiLuView = class("JiLuView"  , ViewBaseLayer)
local GetGameName = require("hall.familyCircle.GetGameName")
local EVENTNAME = {
	SELECT_CLU_HISTORY = "/selectCluHistory",
}
function JiLuView:ctor(family_id, parent, owerId, roleType, config)
    -- body
    self.family_id = family_id
    self.owerId = owerId
    self.config = config
    self.ishehuoren = not (tonumber(self.owerId) == tonumber(USER_INFO["uid"]))
    self.roleType = roleType
    self.parent = parent
    local csbPath = "hall/res/FriendScircle/PartnerManagement/JiLuView.csb"
    JiLuView.super.ctor(self, csbPath, false)
    GameUtils.setNodeNameBindObj(self._csbNode)
    self:enableMask(true)
    self:initUI()
    self:initEvent()
    self:onClickBtnHhr()
end


function JiLuView:initUI()

    self.btn_tab_1 = self._csbNode.root_0.btn_tab_1
    self.btn_tab_2 = self._csbNode.root_0.btn_tab_2
    self.btn_tab_2 = self._csbNode.root_0.btn_tab_2
    self.btn_tab_4 = self._csbNode.root_0.btn_tab_4
    self.btnClose = self._csbNode.root_0.btnClose
    self.root = self._csbNode.root


    self:doLayoutPosition(self._csbNode.root_0)
    self:doLayoutPosition(self._csbNode.root)
    self:doLayoutPosition(self._csbNode.bg)


    self.btnHhr = self.btn_tab_1
	self.btnJf = self.btn_tab_2
	self.btnCy = self.btn_tab_4
	self.btnCylb = self.btn_tab_3

    self.btn_tab_1.Text_1:setString("合伙人")
    self.btn_tab_2.Text_1:setString("积分")
    self.btn_tab_3.Text_1:setString("成员列表")
    self.btn_tab_4.Text_1:setString("成员管理")
    self.btnHhr:setEnabled(true)
	self.btnJf:setEnabled(true)
	self.btnCy:setEnabled(true)
	self.btnCylb:setEnabled(true)

    self.btn_tab_4:hide()
    if self.roleType == 0 then -- 盟主
        self.btn_tab_4:show()
    elseif self.roleType == 2 then-- 合伙人
        -- self.btn_tab_4:show()
    elseif self.roleType == 3 then-- 普通玩家
    end

    local show_member = (self.config.show_member or 1) == 1 or self.owerId == USER_INFO.uid or self.parent.data.isManager == 1
    self.btn_tab_3:setVisible(show_member)

end

function JiLuView:initEvent()
    self.btnJf:onClick(handler(self, self.onClickBtnJf), true)
	self.btnCy:onClick(handler(self, self.onClickBtnCy), true)
	self.btnHhr:onClick(handler(self, self.onClickBtnHhr), true)
	self.btnCylb:onClick(handler(self, self.onClickBtnCylb), true)
	self.btnClose:onClick(handler(self, self.onClickBtnClose), true)
end


function JiLuView:onClickBtnJf()
	self:hideBtn()

    local IntegralManagement = require("hall.familyCircle.IntegralManagement")
	self.jfView = IntegralManagement.new(self.family_id, self.parent, USER_INFO["uid"], self.ishehuoren, nil, self.roleType):addTo(self.root)
    local size = self.root:getContentSize()
	self.jfView.root:setPositionX(size.width / 2)
    self.jfView.bg:setPositionX(size.width / 2)
	self.jfView:enableMask(false)
	self.jfView.btnReturn:hide()
	self.jfView.Text_1:hide()
    
	self.btnJf:setEnabled(false)
end

function JiLuView:onClickBtnCy()
	self:hideBtn()
	if self.cyView then
		self.cyView:show()
	else
		local FamilyMember = require("hall.familyCircle.FamilyMember")
		self.cyView = FamilyMember.new(self.family_id , USER_INFO["uid"], self.parent):addTo(self.root)
		local size = self.root:getContentSize()
        self.cyView.root:setPositionX(size.width / 2)
        self.cyView.bg:setPositionX(size.width / 2)
        self.cyView.Text_1:hide()
        self.cyView:enableMask(false)
		self.cyView.btnReturn:hide()
	end
	self.btnCy:setEnabled(false)
end

function JiLuView:onClickBtnHhr()
	self:hideBtn()
	if self.hhrView then
		self.hhrView:show()
	else
		local FamilyPartner = require("hall.familyCircle.FamilyPartner")
		self.hhrView = FamilyPartner.new(self.parent,self.roleType,self.family_id,USER_INFO["uid"],self.owerId):addTo(self.root)
        local size = self.root:getContentSize()
        self.hhrView.root:setPositionX(size.width / 2)
        self.hhrView.bg:setPositionX(size.width / 2)
		self.hhrView.btnReturn:hide()
        self.hhrView.Text_1:hide()
	end
	self.btnHhr:setEnabled(false)
end

function JiLuView:onClickBtnCylb()
	self:hideBtn()
	if self.cylbView then
		self.cylbView:show()
	else
		local SubordinateMembers = require("hall.familyCircle.SubordinateMembers")
		self.cylbView = SubordinateMembers.new(self.parent,self.family_id,USER_INFO["uid"]):addTo(self.root)
		local size = self.root:getContentSize()
        self.cylbView.root:setPositionX(size.width / 2)
        -- self.cylbView.bg:setPositionX(size.width / 2)
		self.cylbView.btnReturn:hide()
        self.cylbView.Text_1:hide()
	end
	self.btnCylb:setEnabled(false)
end


function JiLuView:hideBtn()
    if self.jfView then
		self.jfView:removeSelf()
		self.jfView = nil
	end
	if self.hhrView then
		self.hhrView:removeSelf()
		self.hhrView = nil
	end
	if self.cyView then
		self.cyView:removeSelf()
		self.cyView = nil
	end
	if self.cylbView then
		self.cylbView:removeSelf()
		self.cylbView = nil
	end
	
	self.btnHhr:setEnabled(true)
	self.btnJf:setEnabled(true)
	self.btnCy:setEnabled(true)
	self.btnCylb:setEnabled(true)
end

function JiLuView:onExit()
    ReqMgr:delHandle("JiLuView", EVENTNAME)
end

function JiLuView:onClickBtnClose(...)
	self:removeSelf()
end

return JiLuView