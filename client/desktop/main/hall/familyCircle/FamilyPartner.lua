--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 NewViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local FamilyPartner = class("FamilyPartner", NewViewBaseLayer)
local FamilyData = require("hall.familyCircle.FamilyData")
local FamilyUntils = require("hall.familyCircle.FamilyUntils")
local CommonTips = require("hall.tips.CommonTips")
local CocosUtil = require("hall.util.CocosUtil")
local addNumber = require("hall.familyCircle.addNumber")
local SubordinateMembers = require("hall.familyCircle.SubordinateMembers")
local UDScoreRecord = require("hall.familyCircle.UDScoreRecord")


function FamilyPartner:ctor(parents,roleType,family_id,userId,owerId)
 	local csbPath = "hall/res/FriendScircle/PartnerManagement/PartnerManagement.csb"
	FamilyPartner.super.ctor(self, csbPath)
	GameUtils.setNodeNameBindObj(self._csbNode)
	self:enableMask(true)
	self.parents = parents
	self.roleType = roleType
	self.family_id = family_id
	self.userId = userId
	self.owerId = owerId
 	self.seleType = 3
 	self.allPartnerList = {}
 	self.playerCanLQJF = 0
	self.AllHeHuoRenList = {}

	self.curPage = 1
	self.page_num = 5
	self.tatolPage = 1
	self.item:hide()
	self.btns:hide()
    self:initEvent()
	self:InitGame()
	if userId ~= USER_INFO["uid"] then
		self.btnGamePlayer:setVisible(false)
		self.btnAdd:setVisible(false)
	end

	if isHideYjf then
		self.ttf_management_0_1:hide()
	end
end

function FamilyPartner:initEvent()
	local time = os.now()
	self.EVENTNAME = {
		SELECT_HHR_LIST_BY_DAYINGJIA = "/selectHhrListBydayingjia".."__"..time,
		SELECT_MY_SON_CONFIG_DIST = "/selectMySonConfigDist".."__"..time,
		ADDHHR = "/addHhr".."__"..time,
		updateClubThresholdValue = "/updateClubThresholdValue".."__"..time,
	}
    ReqMgr:addHandle("FamilyPartner", self.EVENTNAME)
    self.r_page:onClick(handler(self, self.btn_r_page))
	self.l_page:onClick(handler(self, self.btn_l_page))
	self.search:onClick(handler(self, self.btn_search))
	self.btnSure:onClick(handler(self, self.onClickBtnSure))

	self.btns.btn_hhr:onClick(handler(self, self.showNetPartenr), true)
	self.btns.btn_xswj:onClick(handler(self, self.ShowSubordinate), true)
	self.btns.btn_rzxq:onClick(handler(self, self.onClickLogInfo), true)
	self.root:onClick(handler(self, self.onClickRoot))
end

function FamilyPartner:onClickRoot( )
	self.btns:hide()
end

function FamilyPartner:newTextField(node, maxLength, string, func)
    string = string or node:getString()
    maxLength = maxLength or 10
    local params = {
        size = node:getContentSize(),
        fontSize = node:getFontSize(),
        fontColor = node:getTextColor(),
        maxLength = maxLength,
        placeHolder = string,
    }
    node:hide()
    local textField = ccs.textField(params)
    textField:setContentSize(node:getContentSize())
    node:getParent():addChild(textField)
    textField:setAnchorPoint(node:getAnchorPoint())
    textField:setPosition(node:getPosition())
    textField:setTextColor(node:getTextColor())
    textField:setText(node:getString())
    textField:setTouchSize(node:getContentSize())
    textField:setTouchAreaEnabled(true)
    textField:addEventListener(function(sender,event)
        if event == ccui.TextFiledEventType.attach_with_ime then
            --光标进入
        elseif event == ccui.TextFiledEventType.detach_with_ime then
            --光标离开 关闭键盘
            local num = tonumber(sender:getString()) or 0
            num = math.floor(num)
            if num < 0 then
                num = 0
            end
            sender:setText(num)
            node:setString(num)
			if func then
				func(num, sender)
			end
        elseif event == ccui.TextFiledEventType.insert_text then
            --输入
            local num = tonumber(sender:getString()) or 0
            num = math.floor(num)
            if num < 0 then
                num = 0
            end
            sender:setText(num)
            node:setString(num)
        elseif event == ccui.TextFiledEventType.delete_backward then
             --删除
             local num = tonumber(sender:getString()) or 0
            num = math.floor(num)
            if num < 0 then
                num = 0
            end
            sender:setText(num)
            node:setString(num)
        end
    end)
end


function FamilyPartner:initCellInfo(tempRoot,userItem)
	dump(userItem)
	local tempPlayName = userItem.nickName or ""
	local tempPlayID = userItem.playerId or ""
	local xiaohaoYesterday = (userItem.xiaohaoYesterday or 0) / 100
	local gongxianYesterday = (userItem.gongxianYesterday or 0) / 100
	local teamPlayCountYesterday = userItem.teamPlayCountYesterday or 0
	local teamPlayCountToday = userItem.teamPlayCountToday or 0
	local playCountToday = userItem.playCountToday or 0
	local playCountYesterday = userItem.playCountYesterday or 0

	local dayingjiaCountYesterday = userItem.dayingjiaCountYesterday
	local xiaohaoToday = (userItem.xiaohaoToday or 0) / 100
	local gongxianToday = (userItem.gongxianToday  or 0) / 100
	local sonPool = userItem.sonPool / 100
	if userItem.sonCount == nil then
		userItem.sonCount =0
	end
	local sonCount = userItem.sonCount
	-- sonCount = string.format("%0.2f", sonCount)


	local thresholdValue = (userItem.thresholdValue  or 0) / 100
	tempRoot.txt_yjf.color = tempRoot.txt_yjf:getTextColor()
	if sonPool - thresholdValue <= 100 then
		tempRoot.txt_yjf:setTextColor(cc.c3b(255,0,0))
	end
	tempRoot.txt_yjf:setString(thresholdValue)
	tempRoot.txt_yjf:onClick(function()
	end)
	local function_name =  function(thresholdValue, node)
		local data = {
			hehuorenId = userItem.playerId ,
			XYUid = USER_INFO["uid"] ,
			groupId = self.family_id ,
			thresholdValue = thresholdValue * 100 ,

		}
		ReqMgr:request(self.EVENTNAME.updateClubThresholdValue, data, handler(self , self.updateClubThresholdValue))

		if tonumber(sonPool) - thresholdValue <= 100 then
			node:setTextColor(cc.c3b(255,0,0))
		else
			node:setTextColor(tempRoot.txt_yjf.color)
		end
	end
	self:newTextField(tempRoot.txt_yjf, 7, nil, function_name)
	if isHideYjf then
		tempRoot.txt_yjf:hide()
		tempRoot.Image_65:hide()
	end

	xiaohaoToday = string.format("%0.2f", xiaohaoToday)--今日积分
	gongxianToday = string.format("%0.2f", gongxianToday)--今日贡献
	xiaohaoYesterday = string.format("%0.2f", xiaohaoYesterday)--昨日积分
	gongxianYesterday = string.format("%0.2f", gongxianYesterday)--昨日贡献
 	tempRoot:getChildByName("partner_id"):setString(tempPlayID)
	tempRoot:getChildByName("fnt_bigwin"):setString(dayingjiaCountYesterday)--昨日大赢家

	tempRoot:getChildByName("fnt_gamenumber"):setString(playCountYesterday)--昨日局数
	tempRoot:getChildByName("fnt_bigwin"):setString(playCountToday)--个人局数

	tempRoot:getChildByName("fnt_zuori_jifen"):setString(teamPlayCountYesterday)--昨日局数
	tempRoot:getChildByName("fnt_jinri_jifen"):setString(teamPlayCountToday)--个人局数

 	-- tempRoot:getChildByName("fnt_zuori_jifen"):setString(xiaohaoYesterday)--昨日积分
 	-- tempRoot:getChildByName("fnt_jinri_jifen"):setString(xiaohaoToday)--今日积分

 	tempRoot:getChildByName("fnt_zuori_gongxian"):setString(gongxianYesterday)--今日积分
	tempRoot:getChildByName("fnt_jinri_gongxian"):setString(gongxianToday)--今日积分
	 
	sonPool = string.format("%0.2f", sonPool)--积分池
	tempRoot:getChildByName("fnt_jfc"):setString("" .. sonPool)--积分池
	tempRoot:getChildByName("fnt_jfc_2"):setString("" .. sonCount)--积分池
	if self.roleType ~= 0 then
		tempRoot:getChildByName("btnDelect"):setVisible(false)
	end
	tempRoot:getChildByName("btnDelect"):onClick(CocosUtil:Bind(self.showDelectTip , self , userItem.playerId))
	
	tempRoot.data = userItem
	
	tempRoot.btn_cz:onClick(handler(self, self.onClickCz), true)
	tempRoot:onClick(handler(self, self.showPartnerInfo))
	tempRoot:setSwallowTouches(false)
 	local headportrait = tempRoot:getChildByName("headportrait")
 	require("hall.GameCommon"):getUserHead(userItem.photo, "", "", headportrait, 54.94 , false, "", true)
end

function FamilyPartner:onClickCz( event )
	local target = event.target
	local x = event.x
	local y = event.y
	local target = event.target
	self.click_playerId = target:getParent().data.playerId
	self.btns:setPosition(x, y)
	self.btns:setVisible(not self.btns:isVisible())
end


function FamilyPartner:InitGame(page, searchId)
	self.btns:hide()
	page = page or 1
    local data = {
		groupId = self.family_id, 
		playerId = self.userId, 
		currentPage = page, 
		pageSize = self.page_num,
		searchId = searchId
	}
    ReqMgr:request(self.EVENTNAME.SELECT_HHR_LIST_BY_DAYINGJIA, data, handler(self, self.SELECT_HHR_LIST_BY_DAYINGJIA), {page = page})
end

function FamilyPartner:SELECT_HHR_LIST_BY_DAYINGJIA(event)
	local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
	if returnCode == 1 then 
		viewMgr:showTip({text = "该联盟还没有成员"})
		return
	end

	dump(data)
	self.allPartnerList = data
	self.AllHeHuoRenList = {}
	self.AllHeHuoRenList = data.list

	self.tatolPage = math.ceil(data.listCount / self.page_num)
	if self.tatolPage == 0 then
        self.tatolPage = 1
    end
	self.curPage = param.page
	self.r_text:setString(self.curPage.."/"..self.tatolPage)
	self:FlushPartnerList_new(data)

	self.labelXH:setString("团队昨日/今日局数: "..data.teamPlayCountYesterday.."/"..data.teamPlayCountToday)
	self.txt_allXH:hide()
	if data.cardCountTeamYesterday then --只有盟主才会返回钻石,其他人不会返回,以这个为依据,如果没有返回的话还是用以前的那个(注:合伙人可以调整当前点位)
		self.labelYE:setString("昨日/今日消耗钻石: "..data.cardCountTeamYesterday.."/"..data.cardCountTeamToday)
	else
		self.labelYE:setString("我的点位: "..(data.myBonus or 0) )
	end
end


function FamilyPartner:btn_r_page()
	local page = self.curPage + 1
	if page <= 0 or page > self.tatolPage or self.curPage == page then
		return
	end
	self:InitGame(page)
end

function FamilyPartner:btn_l_page()
	local page = self.curPage - 1
	if page <= 0 or page > self.tatolPage or self.curPage == page then
		return
	end
	self:InitGame(page)
end

function FamilyPartner:initLQNode()
	self.tempNode:setVisible(false)
	self.tempNode:setLocalZOrder(999)
end

function FamilyPartner:onClickBtnLQ()
	self.tempNode:setVisible(true)
end

function FamilyPartner:onClickBtnTempClose()
	self.tempNode:setVisible(false)
end

function FamilyPartner:setHideLingQuNode()
	self.tempNode:setVisible(false)
	self.btnLQ:setVisible(false)
	-- self.labelXH:setVisible(false)
	-- self.txt_allXH:setVisible(false)
	-- self.labelYE:setVisible(false)
	-- self.txt_YE:setVisible(false)
end

function FamilyPartner:onClickBtnSureLQ()
	--发送post请求，领取
	print("=====领取积分=====")
	local strN = tonumber(self.TextField_money:getString()) or 0 
	if strN <= 0 then return end
	if strN > self.playerCanLQJF then return end
	strN = strN * 100
	self:postLQJIFEN(strN)

end

function FamilyPartner:postLQJIFEN(_tixianJiFen)
	local interfaceName = "/heHuoRenTixian"
    local httpType = "POST"
     local data = {
            groupId = self.parents.family_id,
            playerId = USER_INFO.uid,
            tixianCount = _tixianJiFen
     }
    local function callback(returnCode, data)
        if 0 == returnCode then 
            CommonTips:showTips(FamilyUntils:SetCommTipLabel("领取成功"))
            self.tempNode:setVisible(false)
            self:refreshHhrList()
        end 
        if 1 == returnCode then 
            CommonTips:showTips(FamilyUntils:SetCommTipLabel("领取失败"))
        end
    end
    cct.createHttRq({
        url = HttpAddr .. interfaceName,
        date = data,
        type_= httpType,
        callBack = function(data)
        	-- print("========领取返回！！！========")
        	-- dump(data)
            local responseData = data.netData
            if responseData then
                responseData = json.decode(responseData)
                if callback then
                    local returnCode = tonumber(responseData.returnCode)
                    callback(returnCode, responseData)
                end

            else
            end
        end})
end

function FamilyPartner:getBegainTimeAndEndTime(nDay)
	local str1 = "00:00:00"
	local str2 = "23:59:59"
    local time = string.split(os.date("%Y-%m-%d %H:%M:%S", os.time() - nDay*24*3600), " ")
    -- local begainT = time[1].." "..str1
    -- local endT = time[1].." "..str2
    --changed by zzy 2019-7-20 只需要发当天，不需要加时分秒
    local begainT = time[1]
    local endT = time[1]
    if nDay == 3 then
    	return nil,nil
    end
    return begainT,endT
end

function FamilyPartner:refreshHhrList()
	local t1,t2 = self:getBegainTimeAndEndTime(self.seleType)
	self:InitGame()
end

function FamilyPartner:FlushPartnerList_new(data)
	local tempData = data
	if tempData.clubFreeGameCountToday and tempData.clubUseCardCountToday then
		local tempStr = '今日局数/今日钻石消耗/昨日钻石消耗: ' .. tempData.clubFreeGameCountToday .. '/' .. tempData.clubUseCardCountToday .. '/' .. (tempData.clubUseCardCountYesterday or '0')
		self.labelYE:setString(tempStr)
	end

	if tempData.myAllSonCount then
		local tempStr = '我的玩家数:' .. tempData.myAllSonCount
		self.labelMyWJ:setString(tempStr)
	end

	if tempData.mySonAllPoint then
		local tempStr = '我的积分池:' .. string.format("%0.2f", tempData.mySonAllPoint/100)
		self.labelMyJF:setString(tempStr)
	end

	if not next(tempData) then return end
	data = data.list
	if not data then
		return
	end

	self.img_hhr_none:setVisible(false)
	local data_num = #data
	if data_num <= 0 then
		self.img_hhr_none:setVisible(true)
	end

	self.txt_allXH:setString((tempData.sonPlayerCount or 0) .. "/" .. (tempData.sonTempPlayCount or 0))

	self.ListView_1:removeAllItems()
	for idx,value in ipairs(data) do
		local item = self.item:clone()
		item:show()
		GameUtils.setNodeNameBindObj(item)
		self:initCellInfo(item,value)
		self.ListView_1:pushBackCustomItem(item)
	end
end

function FamilyPartner:showNetPartenr( event )
	local target = event.target
	local playerId = self.click_playerId
	local s = FamilyPartner.new(self, self.roleType, self.family_id, playerId)
	s:addTo(SCENENOW.scene)
	return
end

function FamilyPartner:ShowSubordinate(event)
	local target = event.target
	local playerId = self.click_playerId
	SubordinateMembers.new(self, self.family_id, playerId, self.owerId):addTo(SCENENOW.scene)
end

function FamilyPartner:onClickLogInfo( )
	UDScoreRecord.new(self.family_id, self.click_playerId):addTo(SCENENOW.scene)
end

function FamilyPartner:showDelectTip( _userId,isCanDelect )
	local this = self
	local function callFunc()
		this:delectPlayer(_userId)
	end
	local data = {type = 2, title = "提示", content = "确定移除合伙人？", callBackSure = callFunc} 
	
    require("hall.tips.CommonTips"):showTips(data)
end

function FamilyPartner:showPartnerInfo(event)
	local target = event.target
	local data = target.data
	if isShowDianWei then
		local newdata = {}
		newdata.groupId = self.family_id
		newdata.XYUid = USER_INFO.uid
		newdata.searchUid = data.playerId
		self.curPlayerId = data.playerId
		dump("SELECT_MY_SON_CONFIG_DIST几次")
		ReqMgr:request(self.EVENTNAME.SELECT_MY_SON_CONFIG_DIST, newdata, handler(self, self.SELECT_MY_SON_CONFIG_DIST))
	else
		local PartnerInfo = require("hall.familyCircle.PartnerInfo")
		local view = PartnerInfo.new(self.family_id,data,self)
		view:addTo(SCENENOW.scene)
	end
end

function FamilyPartner:SELECT_MY_SON_CONFIG_DIST(event)
	local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data or {}
    local error = netData.error
	dump("------几次")
	local PointSetView = require("hall.familyCircle.PointSetView")
	local newData = {}
	for k,v in pairs(data) do
		newData[tonumber(k)] = v
	end
	local view = PointSetView.new(self.family_id, self.curPlayerId, newData)
	view:addTo(SCENENOW.scene)
end


function FamilyPartner:delectPlayer(_userId)
	print("======DelectJLB======")
    local this = self
    local interfaceName = "/removeHhr"
    local httpType = "POST"

     local data = {
		playerId = _userId,
		ownerId = USER_INFO.uid,
		groupId = tonumber(self.parents.family_id),
     }

     dump(data,"FamilyPartner:delectPlayer(_userId)")

    cct.createHttRq({
        url = HttpAddr .. interfaceName,
        date = data,
        type_= httpType,

        callBack = function(data)
            local returnCode = tonumber(json.decode(data.netData).returnCode)
            if 0 == returnCode then 
				viewMgr:showTip({text = "移除合伙人成功！"})
            	this:InitGame()
            elseif 1 == returnCode then 
            	local strError = tostring(json.decode(data.netData).error)
            	CommonTips:showTips(FamilyUntils:SetCommTipLabel(strError))
            	dump("======删除成员失败！=====")
            end 
        end})
end

function FamilyPartner:onClickBtnGamePlayer()
	SubordinateMembers.new(self, self.family_id, USER_INFO["uid"]):addTo(SCENENOW.scene)
end

--add by zzy 
function FamilyPartner:onClickBtnSure()
	-- dump("onClickBtnSure")
	-- dump(self.allPartnerList)
	local str = self.txt_id:getString()
	local strNum = tonumber(str)
	self:InitGame(nil, strNum)
end


function FamilyPartner:FlushPartnerListBySeek( data )
	self:FlushPartnerList(data)
end


function FamilyPartner:onClickBtnPartner(...)
	-- body
	-- print ("添加合伙人")
end

function FamilyPartner:onClickBtnSelectDate(...)
	-- print ("选择日期")
end

function FamilyPartner:onClickBtnMember( ... )
	-- body
	-- print ("成员列表")
	local FamilyMemberLayer =  self.parents:getChildByName("FamilyPartner")
	if FamilyMemberLayer then
		FamilyMemberLayer:setVisible(true)
		FamilyMemberLayer:InitGame(self.parents.family_id)
		self:setVisible(false)
	end
	dump("onClickBtnMember0000000000")
end

function FamilyPartner:onClickBtnReturn(...)
    self:removeSelf()
end

function FamilyPartner:onClickBtnAdd(...)

	print ("添加合伙人")
	--self.family_partner = FamilySearchPartner.new(self.parents,self):addTo(SCENENOW.scene)
	local addNumber = addNumber.new(handler(self, self.InvitePlayer))
    :addTo(SCENENOW.scene)
end

function FamilyPartner:onClickBtnProfit(...)
	
    require("hall.familyCircle.FamilyParnterProfit").new(self.family_id, self):addTo(SCENENOW.scene)
end

function FamilyPartner:InvitePlayer(callData)
	print(callData,"======InvitePlayer======")
	local number = callData.number
    if not number then
        viewMgr:showTip({text = "操作失败！"})
        return
    end
    local data = {
        playerId1 = USER_INFO.uid,
        playerId2 = number,
        groupId = self.family_id,
        bonus = 0
    }
    ReqMgr:request(self.EVENTNAME.ADDHHR, data, handler(self , self.ADDHHR))
end

function FamilyPartner:ADDHHR(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if netData.returnCode == 0 then
        self:InitGame()
        if g_hallMainLayer then
            g_hallMainLayer:loadClub()
        end
        viewMgr:showTip({text = "操作成功！"})
    else
        viewMgr:showTip({text = error})
    end
end

function FamilyPartner:btn_search()
	local addNumber = addNumber.new(handler(self, self.setUserId))
    :addTo(SCENENOW.scene)
end

function FamilyPartner:setUserId(callData)
	local number = callData.number or ""
	local str = self.txt_id:setString(number)
end

function FamilyPartner:onExit()
    ReqMgr:delHandle("FamilyPartner", self.EVENTNAME)
end

return FamilyPartner