--[[
* author:   zwm
* date:     2019-03-25
* describe: 总战绩界面
* explain:  如果要继承 NewViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]


local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local RecordLayer = class("RecordLayer", NewViewBaseLayer)
local clubSendData = require("hall.view.clubView.clubSendData")
local AddNumber = require("hall.familyCircle.addNumber")
SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
local EVENTNAME = {
	QUERY_ACTIVITIES_RESULT = "/freeGame/queryActivitiesResult",
	SELECT_POINT_CHANGE_HISTORY = "/selectPointChangeHistory",
}
local type_bairen = 1
function RecordLayer:ctor(family_id, searchId, roleType)
    local csbPath = "hall/res/record/recordLayer.csb"
    if family_id then
        csbPath = "hall/res/record/recordNode.csb"
        RecordLayer.super.ctor(self, csbPath, nil, false)
    else
        RecordLayer.super.ctor(self, csbPath)
        self:enableMask(true)
    end
   
    self.type = 2 --type =2 => 积分 type =3 => 房卡  1:百人场
    self.curPage = 1
	self.page_num = 5
    self.tatolPage = 1
    self.roleType = roleType
    self.family_id = family_id or 0
    self.searchId = searchId
    self.r_text:setString(self.curPage.."/"..self.tatolPage)

    self:initUI()
    self:initEvent()
    self:setBtns( )
end

function RecordLayer:onExit()
    ReqMgr:delHandle("RecordLayer", EVENTNAME)
end

function RecordLayer:initEvent()
    ReqMgr:addHandle("RecordLayer", EVENTNAME)
    self.r_page:onClick(handler(self, self.btn_r_page))
    self.l_page:onClick(handler(self, self.btn_l_page))
    self.img_by_invitecode:onClick(handler(self, self.selectGameResultByInviteCode))
    for i=1,3 do
        local flag = i == self.type
        local btn = self["btn_"..i]
        btn._type = i
        btn:onClick(handler(self, self.onClickType))
    end
end
--add by zzy 2019-6-27
function RecordLayer:initUI(  )
    self.listView:removeAllItems()
    self.listView:hide()
    self.item:hide()
    self.listView:setScrollBarEnabled(false)
    self:createTableView()
    self.txt_message:setString("暂无战绩,快去约上好友大战三百回合吧!")
    self.btn_1:hide()
    if isShowBaiRen then
        self.btn_1:show()
    else
        self.btn_1:hide()
    end
end

function RecordLayer:setBtns( isInit )
    if isInit == nil then isInit = true end
    for i=1,3 do
        local flag = i == self.type
        local btn = self["btn_"..i]
        local color = i == self.type and cc.c3b(255, 255, 255) or cc.c3b(33, 73, 140)
        btn:setTitleColor(color)
        btn:setEnabled(not flag)
    end
    if isInit then
        self.txt_message:show()
        self:getZJData()
    end
end

function RecordLayer:getZJData(page)
    page = page or 1
    local data = {}
    if self.type == type_bairen then
        data["XYUid"] = USER_INFO["uid"]
        data["searchId"] = self.searchId
        data["groupId"] = self.family_id
        data["currentPage"] = page
        data["pageSize"] = self.page_num
        data["type"] = 6
        data["interfaceType"] = "J"
        ReqMgr:request(EVENTNAME.SELECT_POINT_CHANGE_HISTORY, data, handler(self, self.resultZJ), {page = page, type = self.type})
    else
        data["XYUid"] = USER_INFO["uid"]
        data["currentPage"] = page
        data["pageSize"] = self.page_num
        data["type"] = self.type
        data["searchId"] = self.searchId
        data["interfaceType"] = "J"
        if self.family_id and tonumber(self.family_id) > 0 then
            data["groupId"] = self.family_id
        end
        ReqMgr:request(EVENTNAME.QUERY_ACTIVITIES_RESULT, data, handler(self, self.resultZJ), {page = page, type = self.type})
    end
end

function RecordLayer:resultZJ( event )
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if netData.returnCode == 0 then
        if data.listCount >= 1 then
            self.txt_message:hide()
        end
        self.tatolPage = math.ceil(data.listCount / self.page_num)
        if self.tatolPage == 0 then
            self.tatolPage = 1
        end
        self.curPage = param.page
        -- self.type = param.type
        -- self:setBtns(false)

        if data ~= nil then
            self.AllHeHuoRenList = data.list
            self.userList:reloadData()
            self.r_text:setString(self.curPage.."/"..self.tatolPage)
        end
    end
 end

function RecordLayer:onClickItem( event )
    if event.name == "ended" then
        local target = event.target
        local activityId = target.id
        require("hall.record.RecordLayerInfo").new(activityId, nil,  nil, self.roleType):addTo(SCENENOW.scene)
    end
end

--test
function RecordLayer:createTableView()
    local listView = self.listView
    local size = listView:getContentSize()
    local pos = listView:getPosition()
    local anchor = listView:getAnchorPoint()

    self.userList = cc.TableView:create(size)
    self.userList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.userList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- self.userList:setPosition(cc.p(105, 102))
    self.userList:setAnchorPoint(anchor)
    self.userList:setPosition(pos)
    self.userList:setDelegate()
    self.userList:addTo(self.root,99)
    self.userList:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self.userList:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self.userList:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self.userList:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.userList:reloadData()
end

--test
function RecordLayer:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local item = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
        local node = self:createUser(self.AllHeHuoRenList[idx+1], idx + 1)
        node.item:setAnchorPoint(cc.p(0, 0))
        node.item:setPosition(cc.p(0, 0))
        cell:addChild(node)
    else
        local node = cell:getChildByName("ly")
        self:initCellInfo(node,self.AllHeHuoRenList[idx+1], idx + 1)
    end
	self.userList._getContentSize = self.userList:getContentSize()
    return cell
end

function RecordLayer:initCellInfo(ly, data, index)
    local item = ly.item
    local state = false
    local time_str = ""
    local score = 0
    local scoreColor = cc.c3b(60, 152, 240)

    if self.type == type_bairen then
        item.roomIdStr:hide()
        item.state_0:hide()
        score = data.changePoint / 100
        time_str = os.date("%Y-%m-%d %H:%M:%S", data.changeTime/1000)
        local remarkInfo = json.decode(data["remarkInfo"])
        item.gameTypeStr:setString(remarkInfo.gameName)
    else
        time_str = os.date("%Y-%m-%d %H:%M:%S", data.endDate/1000)
        item.id = data.activityId
        item.level = data.level
        local content = json.decode(data["content"])
        item.gameTypeStr:setString(content.gameName)
        item.roomIdStr:setString("战绩码："..content.roomNum)
        item.roomIdStr:show()
        item.state_0:show()
        for k, userInfo in ipairs(content.userinfos) do
            if userInfo.uid == USER_INFO.uid then
                score = userInfo.score / 100
                break
            elseif self.searchId ~= nil and userInfo.uid == self.searchId then
                score = userInfo.score / 100
                break
            end

        end
    end

    if score >= 0 then
        scoreColor = cc.c3b(255, 0, 0)
        score = "+"..score
        state = true
    end
    item.tiemStr:setString(time_str)
    item.txt_score:setString(score)
    item.txt_score:setTextColor(scoreColor)
    local path = "hall/res/record/icon_1.png"
    if state then
         path = "hall/res/record/icon_2.png"
    end
    item.state:loadTexture(path)
end

--test
function RecordLayer:createUser(userItem, index)
    local item = self.item:clone()
    item:show()
    item:setName("item")
   
    local width, height = self:cellSizeForTable()
    local ly = ccui.Layout:create()
    ly:setContentSize(cc.size(width,height))
    ly:setTouchEnabled(false)
    ly:addChild(item)
    ly:setName("ly")
    GameUtils.setNodeNameBindObj(ly)
    self:initCellInfo(ly, userItem, index)
    return ly
    -- GameUtils.setNodeNameBindObj(item)
    -- self:initCellInfo(item, userItem, index)
    -- return item
end

function RecordLayer:tableCellTouched(view, cell)
    local target = cell:getChildByName("ly").item
    local activityId = target.id
    local level = target.level
	--娄底放炮罚不需要打开详细界面(统一结算的，没有单局详细信息)
	if self.type == type_bairen then
		return
	end
    require("hall.record.RecordLayerInfo").new(activityId, level, nil, self.roleType):addTo(SCENENOW.scene)
    dump(cell:getIdx())
end

function RecordLayer:cellSizeForTable()
    local itemSize = self.item:getContentSize()
    return itemSize.width, itemSize.height + 5
end

function RecordLayer:numberOfCellsInTableView()
    if not (self and self.AllHeHuoRenList) then return end
    return #self.AllHeHuoRenList or 0
end

function RecordLayer:btn_r_page()
	local page = self.curPage + 1
	if page <= 0 or page > self.tatolPage or self.curPage == page then
		return
	end
	self:getZJData(page)
end

function RecordLayer:btn_l_page()
    local page = self.curPage - 1
	if page <= 0 or page > self.tatolPage or self.curPage == page then
		return
	end
	self:getZJData(page)
end

function RecordLayer:onClickType(event)
    local target = event.target
    self.type = target._type
    if self.type == 3 then
        dump()
    end
    self:setBtns()
    
end

function RecordLayer:onClickBtnReturn(event)
    self:removeSelf()
end

function RecordLayer:selectGameResultByInviteCode(event)
    dump('selectGameResultByInviteCode')
    local tip = "请输入战绩码:"
    local AddNumber = AddNumber.new(handler(self, self.addNumberCallback), {tip = tip})
    self:addChild(AddNumber,9999)
end

function RecordLayer:addNumberCallback(data)
    dump(data,'addNumberCallback----')
    local inviteCode = data.strNumber
    if string.len(inviteCode) < 6 then
        viewMgr:showTip({text = "请输入有效的战绩码..."})
        return
    end
    require("hall.record.RecordLayerInfo").new(nil, nil, inviteCode, self.roleType):addTo(SCENENOW.scene)
end

return RecordLayer