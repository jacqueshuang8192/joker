--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 NewViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local IntegralManagement = class("IntegralManagement", NewViewBaseLayer)
local UDScoreRecord = require("hall.familyCircle.UDScoreRecord")
local CocosUtil = require("hall.util.CocosUtil")
local AddNumber = require("hall.familyCircle.addNumber")
--积分管理

local EVENTNAME = {
	CLUCOINSHANDLE = "/cluCoinsHandle",
	SELECT_GROUP_PLAYER_BY_DAYINGJIA = "/selectGroupPlayerBydayingjia",
	INVITE_FOR_JOIN_PLAYER_GROUP = "/inviteForJoinPlayerGroup",
	CLEAN_CLUB_PLAYER_STORE_POINT = "/cleanClubPlayerStorePoint",
}
function IntegralManagement:initEvent()
	ReqMgr:addHandle("IntegralManagement", EVENTNAME)
	
end
function IntegralManagement:onExit()
	ReqMgr:delHandle("IntegralManagement", EVENTNAME)
	
end


function IntegralManagement:ctor(family_id, parent, owerId, ishehuoren, searchUid)
	--add by zzy 
	self.parent = parent
	self.owerId = owerId
	self.ishehuoren = ishehuoren
	self.searchUid = searchUid

	--部分适配修复
	SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
	SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
	self.AllList = {}
	self:initEvent()
	local csbPath = "hall/res/FriendScircle/IntegralManagement.csb"
	IntegralManagement.super.ctor(self, csbPath)
	self:enableMask(true)
	self.curPage = 1
	self.page_num = 6
	self.tatolPage = 1
    self.r_page:onClick(handler(self, self.btn_r_page))
	self.l_page:onClick(handler(self, self.btn_l_page))
	self.btnAddMember:onClick(handler(self, self.onClickBtnAdd), true)
	self.r_page:setLocalZOrder(996)
	self.l_page:setLocalZOrder(996)
	self.item:hide()

	self.AllMumberList = {}
	self:createTableView()
	self.family_id = family_id
	self.roleType = 3
	self:InitGame(self.curPage , self.searchUid)
	self.search:onClick(handler(self, self.btn_search))

	self.ttf_state:setString('头像(点击看流水)')
end

function IntegralManagement:btn_search()
	local addNumber = AddNumber.new(handler(self, self.setUserId))
    :addTo(SCENENOW.scene)
end

function IntegralManagement:setUserId(callData)
	local number = callData.number or ""
	local str = self.txt_search_uid:setString(number)
end

--add by zzy 2019-7-10
function IntegralManagement:setContentSizeByNode( _node )
	if _node then
		_node:setPositionX(SCREEN_WIDTH/2)
	end
	--local size = _node:getContentSize()
	--local precent = SCREEN_WIDTH/1280
	--_node:setContentSize(cc.size(size.width * precent, size.height))
end

function IntegralManagement:InitGame(page, searchUid)
	
	page = page or 1
    local data = { 
        groupId = self.family_id, 
        pageSize = self.page_num, 
        currentPage = page, 
        XYUid = USER_INFO.uid,
        searchUid = searchUid,
	}
	self.searchUid = searchUid
    ReqMgr:request(EVENTNAME.SELECT_GROUP_PLAYER_BY_DAYINGJIA, data, handler(self, self.RefushMemberList), {page = page})
end

function IntegralManagement:RefushMemberList(event)
	if tolua.isnull(self) then
		return
	end
	local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
	local error = netData.error
	if returnCode == 0 then
		self.AllMumberList = {}
		for k,v in pairs(data.list or {}) do
			if v.userId and v.changciCount and v.photoUrl and v.nickName then
				table.insert(self.AllMumberList,v)
			end
		end
		self.AllList = self.AllMumberList
		-- if self.userList then
		-- 	self.userList:reloadData()
		-- end
		self.roleType = data.myRoleType or 3
		self.tatolPage = math.ceil(data.count / self.page_num)
		if self.tatolPage == 0 then
			self.tatolPage = 1
		end
		self.curPage = param.page
		self.r_text:setString(self.curPage.."/"..self.tatolPage)
		self.ListView:removeAllItems()
		for idx,data in ipairs(self.AllList) do
			local item = self.item:clone():show()
			self.ListView:pushBackCustomItem(item)
			self:initCellInfo(item,data,idx)
		end

		if self.roleType == 0 then
			self.ttf_gamenumber:setString('保险柜积分(点击清除)')
		else
			self.ttf_gamenumber:setString('保险柜积分')
		end
	else
		viewMgr:showTip({text = error})
	end
end

function IntegralManagement:onClickLogInfo(event )
    local target = event.target
	local playerId = target.playerId
	UDScoreRecord.new(self.family_id, playerId):addTo(SCENENOW.scene)
end


function IntegralManagement:createTableView()
	-- self.ListView:hide()
	-- local size = self.ListView:getSize()
	-- local getPosition = self.ListView:getPosition()
	-- local getAnchorPoint = self.ListView:getAnchorPoint()
	-- local getZOrder = self.ListView:getZOrder()
	-- self.userList = cc.TableView:create(size)
	-- self.userList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	-- self.userList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	-- self.userList:setAnchorPoint(getAnchorPoint)
	-- self.userList:setPosition(getPosition)
	-- self.userList:setDelegate()
	-- self.userList:addTo(self.root)
	-- -- self.userList:setLocalZOrder(getZOrder)
	-- self.userList:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
	-- self.userList:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
	-- self.userList:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
	-- self.userList:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	-- self.userList:reloadData()

end
--test
function IntegralManagement:tableCellAtIndex(view, idx)
	-- local cell = view:dequeueCell()
	-- local item = nil
	-- if nil == cell then
	-- 	cell = cc.TableViewCell:new()
	-- 	local userBar = self:createUser(self.AllMumberList[idx+1], idx + 1)
	-- 	cell:addChild(userBar)
	-- else
	-- 	local node = cell:getChildByName("ly"):getChildByName("playerNode")
	-- 	self:initCellInfo(node,self.AllMumberList[idx+1], idx + 1)
	-- end
	-- return cell
end

function IntegralManagement:initCellInfo(tempRoot,data,index)
	--local name = string.sub(data.nickName , 1 , 12) .. "..."
	local name = require("hall.GameCommon"):formatNick(data.nickName or " ")
	tempRoot:getChildByName("Id"):setString(data.userId)
	tempRoot:getChildByName("txt_name"):setString(name)
	local falg = tonumber(self.owerId) == tonumber(data.userId)
	if self.ishehuoren then
		falg = false
	end
	tempRoot:getChildByName("sign"):setVisible(falg)
	tempRoot:getChildByName("total_score"):setString(data.pointCount/100)
	if tonumber(data.userId) == tonumber(USER_INFO["uid"]) then
		self.parent:updateUserScore(data.pointCount)
	end
	--以前是大赢家,现在是显示保险柜的积分
	--tempRoot:getChildByName("game_numbers"):setString(data.dayingjiaCount)
	tempRoot:getChildByName("game_numbers"):setString((data.repositoryPoint or 0)/100)

	if USER_INFO["uid"] ~= tonumber(self.owerId)then
		tempRoot:getChildByName("btn_increasean"):setVisible(false)
		tempRoot:getChildByName("btn_reduce"):setVisible(false)
	end
	tempRoot:getChildByName("btn_increasean"):onClick(CocosUtil:Bind(self.OnClickIncrease , self , data.userId))
	tempRoot:getChildByName("btn_reduce"):onClick(CocosUtil:Bind(self.OnClickReduce , self , data.userId))
	if self.roleType == 0 then
		tempRoot:getChildByName("game_numbers"):onClick(CocosUtil:Bind(self.OnClickCleanRepository , self , data.userId))
	end
	local headImg = tempRoot:getChildByName("headImg")
	require("hall.GameCommon"):getUserHead(data.photoUrl, "", "", headImg, 70 , false, "", true)
	headImg.playerId = data.userId
	headImg:onClick(handler(self, self.onClickLogInfo))
end
function IntegralManagement:OnClickIncrease(userId)
	local tip = ""
    local AddNumber = AddNumber.new(handler(self, self.addNumberCallback), {type = 1, tip = tip, userId = userId})
    :addTo(SCENENOW.scene)
end

function IntegralManagement:OnClickReduce(userId)
	local tip = ""
    local AddNumber = AddNumber.new(handler(self, self.addNumberCallback), {type = 0, tip = tip, userId = userId})
    :addTo(SCENENOW.scene)
end

function IntegralManagement:OnClickCleanRepository(userId)
	local tip = "清除保险柜积分"
    local AddNumber = AddNumber.new(handler(self, self.cleanRepository), {type = 0, tip = tip, userId = userId})
    :addTo(SCENENOW.scene)
end

function IntegralManagement:addNumberCallback(data)
	local profitOwnerPoint = data.number or 0
    if profitOwnerPoint == 0 then
        viewMgr:showTip({text = "操作失败"})
        return
    end
    profitOwnerPoint = tonumber(profitOwnerPoint)*100
	local intType = data.type
	dump(self.family_id , data.userId , intType , profitOwnerPoint ,self.owerId)
	local signStr = crypto.md5(string.format("addCoins%d_%d&%dtype%d%d", self.family_id, self.owerId, data.userId, intType, profitOwnerPoint), false)
	local data = 
	{
		groupId = self.family_id,
		ownerId = self.owerId, 
		playerId = data.userId,
		type = intType, 
		coins = profitOwnerPoint, 
		sign = signStr
	}
	dump(data)
    ReqMgr:request(EVENTNAME.CLUCOINSHANDLE, data, handler(self, self.cluCoinsHandle))
end

function IntegralManagement:cleanRepository(data)
	local profitOwnerPoint = data.number or 0
    if profitOwnerPoint <= 0 then
        viewMgr:showTip({text = "操作失败"})
        return
    end
    profitOwnerPoint = tonumber(profitOwnerPoint)*100

	local data =
	{
		groupId = self.family_id,
		opeCleanUid = data.userId,
		opeCount = profitOwnerPoint
	}

    ReqMgr:request(EVENTNAME.CLEAN_CLUB_PLAYER_STORE_POINT, data, handler(self, self.cluCoinsHandle))
end

function IntegralManagement:cluCoinsHandle(event)
	if tolua.isnull(self) then
		return
	end
	local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
	local error = netData.error
	if returnCode == 0 then
		viewMgr:showTip({text = "修改成功"})
		self.parent:RequestCludScore()
		self:InitGame(self.curPage, self.searchUid)
	else
        viewMgr:showTip({text = error})
	end
end

--test
function IntegralManagement:createUser(userItem, index)
	local ly = ccui.Layout:create()
	ly:setContentSize(cc.size(1187.38, 82))
	local node = self.item:clone():show()
	node:setName("playerNode")
	node:setPosition(0,0)
	self:initCellInfo(node,userItem, index)
	ly:addChild(node)
	ly:setName("ly")
	ly:setLocalZOrder(-996)
	return ly
end

function IntegralManagement:tableCellTouched(view, cell)

end

function IntegralManagement:cellSizeForTable()
	local size = self.item:getContentSize()
	return size.width, size.height
end

function IntegralManagement:numberOfCellsInTableView()
	return #self.AllMumberList or 0
end


function IntegralManagement:onClickBtnRecord()
	UDScoreRecord.new(self.family_id):addTo(SCENENOW.scene)
end
--add by zzy 
function IntegralManagement:onClickBtnSure()
	local str = self.txt_search_uid:getString()
	local searchUid = tonumber(str)
	self:InitGame(nil, searchUid)
end

function IntegralManagement:onClickBtnReturn()
	self:removeSelf()
end

function IntegralManagement:btn_r_page()
	local page = self.curPage + 1
	if page <= 0 or page > self.tatolPage or self.curPage == page then
		return
	end
	self:InitGame(page)
end

function IntegralManagement:btn_l_page()
	local page = self.curPage - 1
	if page <= 0 or page > self.tatolPage or self.curPage == page then
		return
	end
	self:InitGame(page)
end


function IntegralManagement:onClickBtnAdd()
    local addNumber = AddNumber.new(handler(self, self.InvitePlayer))
    :addTo(SCENENOW.scene)
end

function IntegralManagement:InvitePlayer(callData)
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
    ReqMgr:request(EVENTNAME.INVITE_FOR_JOIN_PLAYER_GROUP, data, handler(self , self.INVITE_FOR_JOIN_PLAYER_GROUP))
end
function IntegralManagement:INVITE_FOR_JOIN_PLAYER_GROUP(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if netData.returnCode == 0 then
		self:InitGame(self.curPage , self.searchUid)
        if g_hallMainLayer then
            g_hallMainLayer:loadClub()
        end
        viewMgr:showTip({text = "操作成功！"})
    else
        viewMgr:showTip({text = error})
    end
end
return IntegralManagement