local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local ScoreRecordView = class("ScoreRecordView", NewViewBaseLayer)
local GetGameName = require("hall.familyCircle.GetGameName")

local EVENTNAME = {
	SELECT_GROUP_PLAYER = "/selectMyXiaohaoList",
}

function ScoreRecordView:ctor(family_id, roleType, searchId)
 	local csbPath = "hall/res/FriendScircle/ScoreRecord/ScoreRecordView.csb"
    ScoreRecordView.super.ctor(self, csbPath)
    self:enableMask(true)
    self.curPage = 1
	self.page_num = 10
	self.tatolPage = 1
    self.family_id = family_id
    self.roleType = roleType
    self.searchId = searchId
    self:initUI()
    self:initEvent()
    self:InitGame()
    if searchId then
        self:onClickBtn2(searchId )
    else
        self:onClickBtn2()
    end
end

function ScoreRecordView:initUI()
    self.ListView:removeAllChildren()
    self.item:setVisible(false)
    self.vw_1:show()
    self.btn_1:setEnabled(false)
    self.btn_2:setEnabled(true)
end

function ScoreRecordView:initEvent()
    ReqMgr:addHandle("ScoreRecordView", EVENTNAME)
    self.r_page:onClick(handler(self, self.btn_r_page))
	self.l_page:onClick(handler(self, self.btn_l_page))
	self.btn_1:onClick(handler(self, self.onClickBtn1))
	self.btn_2:onClick(handler(self, self.onClickBtn2))
end

function ScoreRecordView:onClickBtn1( )
    self.RecordLayer:hide()
    self.vw_1:show()
    self.btn_1:setEnabled(false)
    self.btn_2:setEnabled(true)

end

function ScoreRecordView:onClickBtn2( )
    -- dump(self.family_id)    -- 社区ID
    if not self.RecordLayer then
        self.RecordLayer = require("hall.record.RecordLayer").new(self.family_id, self.searchId, self.roleType)
        self.RecordLayer:addTo(self.root)
        self.RecordLayer:setAnchorPoint(cc.p(0,0))
        self.RecordLayer:setPosition(cc.p(0,0))
        self.RecordLayer:setPosition(cc.p(0,0))
    end
    self.RecordLayer:show()
    self.vw_1:hide()
    self.btn_1:setEnabled(true)
    self.btn_2:setEnabled(false)
end

function ScoreRecordView:InitGame(page, searchUid)
	page = page or self.curPage
    local data = { 
        groupId = self.family_id, 
        pageSize = self.page_num, 
        currentPage = page, 
        XYUid = USER_INFO.uid,
        searchUid = searchUid,
    }
    
    ReqMgr:request(EVENTNAME.SELECT_GROUP_PLAYER, data, handler(self, self.SELECT_GROUP_PLAYER), {page = page})
end

function ScoreRecordView:SELECT_GROUP_PLAYER(event)
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
    self:reloadData(players)
    self.tatolPage = math.ceil(data.listCount / self.page_num)
	if self.tatolPage == 0 then
        self.tatolPage = 1
    end
	self.curPage = param.page
	self.r_text:setString(self.curPage.."/"..self.tatolPage)
end

function ScoreRecordView:reloadData(players)
    self.ListView:removeAllChildren()
    --    玩家头像(smallPhoto) 玩家昵称(nickName) 游戏名字(gameLevel)/游戏标志(activityId) 赠送额(profit) 赠送时间(profitTime) 
    for k,datav in ipairs(players) do
        local item = self.item:clone()
        GameUtils.setNodeNameBindObj(item)
        item:setVisible(true)
        item.txt_id:setString(datav.playerId or "0")
        
        local strName = require("hall.GameCommon"):formatNick(datav.nickName or "0")
        item.txt_name:setString(strName or "0")

        local activityId = datav.activityId or "" 
        local str = GetGameName:getName(datav.gameLevel).."\n"..activityId
        item.txt_gameName:setString(str)
        item.txt_remain:setString(datav.profit/100)
        item.txt_time:setString(os.date("%Y-%m-%d\n%H:%M:%S", math.ceil(tonumber(datav.profitTime or "0")/1000)))
        local headSize = item.headImg:getContentSize().width
        require("hall.GameCommon"):getUserHead(datav.smallPhoto, "", "", item.headImg, headSize, false, "", true)

        self.ListView:pushBackCustomItem(item)
    end
end

function ScoreRecordView:btn_r_page()
	local page = self.curPage + 1
	if page <= 0 or page > self.tatolPage or self.curPage == page then
		return
	end
	self:InitGame(page)
end

function ScoreRecordView:btn_l_page()
	local page = self.curPage - 1
	if page <= 0 or page > self.tatolPage or self.curPage == page then
		return
	end
	self:InitGame(page)
end

function ScoreRecordView:onClickBtnReturn()
    self:removeSelf()
end 

function ScoreRecordView:onExit()
    ReqMgr:delHandle("ScoreRecordView", EVENTNAME)
end

return ScoreRecordView