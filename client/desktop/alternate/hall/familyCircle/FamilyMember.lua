--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local FamilyMember = class("FamilyMember", NewViewBaseLayer)
local addNumber = require("hall.familyCircle.addNumber")
local FamilyData = require("hall.familyCircle.FamilyData")
local CocosUtil = require("hall.util.CocosUtil")
local CommonTips = require("hall.tips.CommonTips")
local FamilyUntils = require("hall.familyCircle.FamilyUntils")
local initX = 0;
local initY = 396
local EVENTNAME = {
    -- SELECT_GROUP_PLAYER = "/selectGroupPlayerBydayingjia",
	SELECT_GROUP_PLAYER = "/selectGroupPlayerBydayingjia__FamilyMember",
    
	INVITE_FOR_JOIN_PLAYER_GROUP = "/inviteForJoinPlayerGroup",
}
function FamilyMember:initEvent()
    ReqMgr:addHandle("FamilyMember", EVENTNAME)
    self.r_page:onClick(handler(self, self.btn_r_page))
	self.l_page:onClick(handler(self, self.btn_l_page))
	self.search:onClick(handler(self, self.btn_search))
end

function FamilyMember:onExit()
    ReqMgr:delHandle("FamilyMember", EVENTNAME)
end

function FamilyMember:ctor(family_id , owerId, parent)
	--add by zzy 
	self.parent = parent

    --部分适配修复
	SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height

 	local csbPath = "hall/res/FriendScircle/PartnerMember/PartnerMember.csb"
    FamilyMember.super.ctor(self, csbPath)
    self.curPage = 1
	self.page_num = 30
	self.tatolPage = 1
    self:initEvent()
    self:enableMask(true)
    self.AllMumberList = {}
	self.AllList = {}
	self.AllListNodes = {}
	self.ListCacheNodes = {}
    --self:createTableView()
	self.family_id = family_id
    self.owerId = owerId
    self:createCacheNodes(15)
	self:InitGame()
    self.ScrollView:removeAllChildren()
    self.ScrollView:setScrollBarEnabled(false)
	--部分适配修复
    -- self:setContentSizeByNode(self.ScrollView)
    -- self:setContentSizeByNode(self.image_di)
    -- self.member_item:hide()
    self.member_item:setVisible(false)
	self.member_head = self.member_item:getChildByName("head")
	
end

function FamilyMember:btn_search()
	local addNumber = addNumber.new(handler(self, self.setUserId))
    :addTo(SCENENOW.scene)
end

function FamilyMember:setUserId(callData)
	local number = callData.number or ""
	local str = self.txt_search_uid:setString(number)
end

--add by zzy 2019-7-10
function FamilyMember:setContentSizeByNode( _node )
	local size = _node:getContentSize()
	local precent = SCREEN_WIDTH/1280
	_node:setContentSize(cc.size(size.width * precent, size.height))
end


function FamilyMember:InitGame(page, searchUid)
	page = page or self.curPage
    local data = { 
        groupId = self.family_id, 
        pageSize = self.page_num, 
        currentPage = page, 
        XYUid = USER_INFO.uid,
        searchUid = searchUid,
    }
    ReqMgr:request(EVENTNAME.SELECT_GROUP_PLAYER, data, handler(self, self.RefushMemberList), {page = page},nil,false)
end
function FamilyMember:tableCellAtIndex(view, idx)
    dump(idx,"tableCellAtIndex")
    local cell = view:dequeueCell()
    local item = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
        local userBar = self:createUser(self.AllMumberList[idx+1], idx + 1)
        cell:addChild(userBar)
    else
        local node = cell:getChildByName("ly"):getChildByName("playerNode")
        self:initCellInfo(node,self.AllMumberList[idx+1], idx + 1)
    end
    return cell
end

function FamilyMember:initCellInfo(_node,userItem,index)
    local name = require("hall.GameCommon"):formatNick(userItem.nickName or " ")
    --local name = string.sub(userItem.nickName , 1 , 12) .. "..."
    _node:getChildByName("text_name"):setString(name)
    _node:getChildByName("text_uid"):setString(userItem.userId)
    local headImg = _node:getChildByName("head")
    require("hall.GameCommon"):getUserHead(userItem.photoUrl, "", "", headImg, headImg:getWidth() , false, "", true)
end

--test
function FamilyMember:createUser(userItem, index)
    local ly = ccui.Layout:create()
    ly:setContentSize(cc.size(1060, 91.00))
    --local item = self.member_item:clone()
    local node = self.member_item:clone()
    node:setVisible(true)
    node:setName("playerNode")
    self:initCellInfo(node,userItem, index)
    ly:addChild(node)
    ly:setName("ly")
    return ly
end

--test
function FamilyMember:createTableView()
    self.userList = cc.TableView:create(cc.size(1199.42, 488.00))
    self.userList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.userList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.userList:setAnchorPoint(cc.p(0, 0))
    self.userList:setPosition(cc.p(60.29,77))
    self.userList:setDelegate()
    self.root:addChild( self.userList,99999999999)
    self.userList:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self.userList:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self.userList:registerScriptHandler(self.cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.userList:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.userList:reloadData()
end

function FamilyMember:tableCellTouched(view, cell)

end
function FamilyMember:updateNode(userItem,node,index,size, height)
    -- dump(userItem,"---userItem")
    if not next(userItem) then
        return
    end
    local uid = tonumber(userItem.userId)
    print("Head:" .. index .. "__" .. userItem.photoUrl .. "uid:" .. uid)

    --local name = string.sub(userItem.nickName , 1 , 12) .. "..."
    local name = require("hall.GameCommon"):formatNick(userItem.nickName or " ")
    node:getChildByName("text_name"):setString(name)
    node:getChildByName("text_uid"):setString(uid)
    local  y = math.ceil(index / 6)
    local size = node:getContentSize()
    local indexY = height - (size.height+9) * y
    if y > 1 then
        index = index % 6
        if index == 0 then
            index = 6
        end 
    end
    local x = (index-1) * (size.width+10)
    node:setPosition(cc.p(x + 60, indexY + 67))
    local headImg = node:getChildByName("head")
    headImg.userId = uid
    -- dump(userItem.photoUrl)
    -- require("hall.GameCommon").new():getUserHead(userItem.photoUrl, "", "", headImg, headImg:getWidth() , false, "", true)
    require("hall.GameCommon"):getUserHead(userItem.photoUrl, "", "", headImg, headImg:getWidth() , false, "", true)
    headImg.data = userItem
    -- headImg:onClick(handler(self, self.showDelectTip))
    node.data = userItem
    node.userId = uid
    node:onClick(handler(self, self.showDelectTip))
    local path = ""
    local icon = node:getChildByName("icon"):hide()
    
    if userItem.roleType == 0 then
        --盟主
        path = "hall/res/FriendScircle/PartnerMember/icon_1.png"
        icon:show()
    else
        if userItem.roleType == 2 then
            --合伙人
            path = "hall/res/FriendScircle/PartnerMember/icon_2.png"
            icon:show()
        end
        if userItem.isManager == 1 then
            --管理员
            path = "hall/res/FriendScircle/PartnerMember/icon_3.png"
            icon:show()
        end
    end
    icon:loadTexture(path)
end

function FamilyMember:showDelectTip( event )
    local target = event.target
    local userId = target.userId
    if self.owerId == USER_INFO.uid and tonumber(userId) ~= USER_INFO.uid then
        -- local data = {type = 2, title = "提示", content = "确定删除该成员？", callBackSure = callFunc} 
        -- require("hall.tips.CommonTips"):showTips(data)
        local MenberInfoView = require("hall.familyCircle.MenberInfoView")
        MenberInfoView.new(self.parent, self, target.data, self.family_id, userId, self.roleType):addTo(self.parent)
    else
        CommonTips:showTips(FamilyUntils:SetCommTipLabel("没有权限对该成员做操作！！！"))
    end
end

function FamilyMember:RefushMemberList(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if returnCode ~= 0 then
        viewMgr:showTip({text = error})
        return
    end
    if not data then
        return 
    end
    local players = data.list
	self.AllList = players
    self:reloadData(players)
    
    self.tatolPage = math.ceil(data.count / self.page_num)
	if self.tatolPage == 0 then
        self.tatolPage = 1
    end
	self.curPage = param.page
	self.r_text:setString(self.curPage.."/"..self.tatolPage)
end

function FamilyMember:createCacheNodes(num)
    for i = 1, num do
        local node = self.member_item:clone()
        self.root:addChild(node)
        node:setVisible(false)
        table.insert(self.ListCacheNodes, node)
    end
end

function FamilyMember:getCacheNode()
    if #self.ListCacheNodes < 1 then
        self:createCacheNodes(15)
    end
    return table.remove(self.ListCacheNodes)
end

function FamilyMember:recycleCacheNode(rNode)
    rNode:setVisible(false)
    table.insert(self.ListCacheNodes,rNode)
end

function FamilyMember:reloadData(players)
    for index, value in ipairs(self.AllListNodes) do
        value:setVisible(false)
        table.insert(self.ListCacheNodes,value)
    end
    -- for index, value in ipairs(self.AllListNodes) do
    --     value:removeSelf()
    -- end
    self.AllListNodes = {}
    local size = table.nums(players)

    for k,datav in ipairs(players) do
        local node = self:getCacheNode()
        -- local node = self.member_item:clone()
        table.insert(self.AllListNodes, node)
        GameUtils.setNodeNameBindObj(node)
        node.makes:setString("")
        node:show()
        -- self:addChild(node)
        self:updateNode(datav, node, k, size, 500)
    end
end

function FamilyMember:numberOfCellsInTableView()

    return #self.AllMumberList or 0
end

function FamilyMember.cellSizeForTable()
    return 187.00, 91
end

function FamilyMember:onClickBtnAdd()
    local addNumber = addNumber.new(handler(self, self.InvitePlayer))
    :addTo(SCENENOW.scene)
end
--add by zzy 
function FamilyMember:onClickBtnSure()
	local str = self.txt_search_uid:getString()
	local searchUid = tonumber(str)
	self:InitGame(nil, searchUid)
end

function FamilyMember:onClickBtnReturn()
    self:removeSelf()
end 

function FamilyMember:btn_r_page()
	local page = self.curPage + 1
	if page <= 0 or page > self.tatolPage or self.curPage == page then
		return
	end
	self:InitGame(page)
end

function FamilyMember:btn_l_page()
	local page = self.curPage - 1
	if page <= 0 or page > self.tatolPage or self.curPage == page then
		return
	end
	self:InitGame(page)
end

function FamilyMember:InvitePlayer(callData)
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

function FamilyMember:INVITE_FOR_JOIN_PLAYER_GROUP(event)
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

return FamilyMember