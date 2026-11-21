--[[
* author:   zwm
* date:     2020-06-01
* describe: 合伙人返利列表
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local ViewBaseLayer = require("hall.ViewBaseLayer")
local FamilyParnterFrofit = class("FamilyMember", ViewBaseLayer)
local CommonTips = require("hall.tips.CommonTips")

local initX = 0;
local initY = 396
local EVENTNAME = {
	SELECT_GROUP_PLAYER = "/selectMyXiaohaoList",
}

function FamilyParnterFrofit:initEvent()
    -- ReqMgr:addHandle("FamilyMember", EVENTNAME)
 --    self.r_page:onClick(handler(self, self.btn_r_page))
	-- self.l_page:onClick(handler(self, self.btn_l_page))
end
function FamilyParnterFrofit:onExit()
    ReqMgr:delHandle("FamilyMember", EVENTNAME)
end

function FamilyParnterFrofit:ctor(family_id , parent)
	--add by zzy 
	self.parent = parent

 	local csbPath = "hall/res/FriendScircle/PartnerProfitLst.csb"
    FamilyParnterFrofit.super.ctor(self, csbPath)
    self.curPage = 1
	self.page_num = 10
	self.tatolPage = 1
    self._toChange = 0
    self:initEvent()

	self.AllList = {}
    --self:createTableView()
	self.family_id = family_id
	self:InitGame()
    self.ListView:removeAllChildren()

    self.member_item:setVisible(false)
	
	self.ttf_search:onClick(function (event)
		self.ttf_search:setString('')
    end)
    
end

function FamilyParnterFrofit:InitGame(page, searchUid)
	page = page or 1
    local data = { 
        groupId = self.family_id, 
        pageSize = self.page_num, 
        currentPage = page, 
        XYUid = USER_INFO.uid,
        searchUid = searchUid,
    }
    
    ReqMgr:request(EVENTNAME.SELECT_GROUP_PLAYER, data, handler(self, self.RefushMemberList), {page = page})
end

function FamilyParnterFrofit:initCellInfo(_node, data)
    _node:getChildByName("name"):setString(data.playerId or "0")
    _node:getChildByName("times"):setString(os.date("%Y-%m-%d %H:%M:%S", math.ceil(tonumber(data.profitTime or "0")/1000)))
    _node:getChildByName("score"):setString(tonumber(data.profit or "0")/100)
end

function FamilyParnterFrofit:RefushMemberList(event)
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
    
    self.tatolPage = math.ceil(data.listCount / self.page_num)
	if self.tatolPage == 0 then
        self.tatolPage = 1
    end
	self.curPage = self.curPage + self._toChange
	self.r_text:setString(self.curPage.."/"..self.tatolPage)
end

function FamilyParnterFrofit:reloadData(players)
   self.ListView:removeAllChildren()

    for k,datav in ipairs(players) do
        if k == 1 then
            dump(datav,"user info == ")
        end
        local node = self.member_item:clone()
        node:setVisible(true)
        self:initCellInfo(node, datav)
        self.ListView:pushBackCustomItem(node)
    end
end

--add by zzy 
function FamilyParnterFrofit:onClickBtnSure()
    self._toChange = 0
    self.curPage = 1
	local str = self.ttf_search:getString()
	local searchUid = tonumber(str)
	self:InitGame(nil, searchUid)
end

function FamilyParnterFrofit:onClickBtnReturn()
    self:removeSelf()
end 

function FamilyParnterFrofit:onClickBtnNextPage()
	local page = self.curPage + 1
	if page <= 0 or page > self.tatolPage or self.curPage == page then
		return
	end
    self._toChange = 1
    local str = self.ttf_search:getString()
    local searchUid = tonumber(str)
	self:InitGame(page, searchUid)
end

function FamilyParnterFrofit:onClickBtnPrevPage()
	local page = self.curPage - 1
	if page <= 0 or page > self.tatolPage or self.curPage == page then
		return
	end
    self._toChange = -1
    local str = self.ttf_search:getString()
    local searchUid = tonumber(str)
	self:InitGame(page, searchUid)
end

return FamilyParnterFrofit