-- 经营状态
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local statistical_jy = class("statistical_jy", NewViewBaseLayer)
-- local statistical_jy = class("statistical_jy",function()
--     return display.newLayer("statistical_jy")
-- end)

local EVENTNAME = {
	-- QUERY_ACTIVITIES_RESULT = "/freeGame/queryActivitiesResult",
	selectJinYingZhuangkuang = "/selectJinYingZhuangkuang",
}

function statistical_jy:ctor(family_id, roleType)
    self.family_id = family_id
    self.roleType = roleType
    
    local path = "hall/res/FriendScircle/statistical_jy.csb"
    statistical_jy.super.ctor(self, path)
    -- local node = nil 
    -- if device.platform == "ios" then
    --     if isiOSVerify then
    --         node = cc.CSLoader:createNode(path):addTo(self)
    --     else
    --         node = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. path):addTo(self)
    --     end
    -- else
    --     node = cc.CSLoader:createNode(path):addTo(self)
    -- end
    -- self._csbNode = node


    self:initUI()
    self:reqInfo()
end

function statistical_jy:initUI()
    -- self.root = self._csbNode:getChildByName("root")
    local wanfaBg = self.root:getChildByName("wanfaBg")
    self.btnClose = wanfaBg:getChildByName("btnClose")
    self.qzjNode = self.root:getChildByName("qzjNode")

    
    self.infoScrollView = wanfaBg:getChildByName("ListView_1")
    self.infoScrollView:setScrollBarEnabled(false)
    self.roleInfoPanel = self.infoScrollView:getChildByName("Panel_l")
    -- 日期 = self.roleInfoPanel:getChildByName("info"):getChildByName("Text_1")
    -- 总场次 = self.roleInfoPanel:getChildByName("info"):getChildByName("Text_2")
    -- 总消耗 = self.roleInfoPanel:getChildByName("info"):getChildByName("Text_3")
    -- 大赢家次数 = self.roleInfoPanel:getChildByName("info"):getChildByName("Text_4")

    self.cytjBtn = wanfaBg:getChildByName("btn_tab_1")    -- 成员统计
    self.jyztBtn = wanfaBg:getChildByName("btn_tab_2")    -- 经营状况
    self.qtjBtn = wanfaBg:getChildByName("btn_tab_3")     -- 群统计
    self.fjjlBtn = wanfaBg:getChildByName("btn_tab_4")    -- 房间记录
    

    self:initEvent()
end

function statistical_jy:initEvent()
    ReqMgr:addHandle("statistical_jy", EVENTNAME)
    self.btnClose:onClick(handler(self, self.onClickBtnClose), true)

    self.cytjBtn:onClick(handler(self, self.onClickcytjBtn), true)
    self.jyztBtn:onClick(handler(self, self.onClickjyztBtn), true)
    self.qtjBtn:onClick(handler(self, self.onClickqtjBtn), true)
    self.fjjlBtn:onClick(handler(self, self.onClickfjjlBtn), true)

    self.infoScrollView:addEventListenerScrollView(handler(self, self.addEventListenerScrollView))
end

function statistical_jy:onClickcytjBtn()
    local statistical_cytj = require("hall.familyCircle.statistical_cytj").new(self.family_id,self.roleType)
    statistical_cytj:addTo(self:getParent())
    
    self:removeSelf()
end

function statistical_jy:onClickjyztBtn()
    
end

function statistical_jy:onClickqtjBtn()
    local statistical_qtj = require("hall.familyCircle.statistical_qtj").new(self.family_id,self.roleType)
    statistical_qtj:addTo(self:getParent())
    
    self:removeSelf()
end

function statistical_jy:onClickfjjlBtn()
    local statistical_fjjl = require("hall.familyCircle.statistical_fjjl").new(self.family_id,self.roleType)
    statistical_fjjl:addTo(self:getParent())

    self:removeSelf()
end

function statistical_jy:onClickBtnClose()
    self:removeSelf()
end

function statistical_jy:reqInfo()
    -- local page = page or 1
    -- local searchid = searchid or 0

    local data = {}
    data["XYUid"] = USER_INFO["uid"]
    -- data["currentPage"] = page
    -- data["pageSize"] = self.page_num
    -- data["type"] = self.type
    -- data["searchId"] = psearchid
    data["interfaceType"] = "J"
    if self.family_id and tonumber(self.family_id) > 0 then
        data["groupId"] = self.family_id
    end

    ReqMgr:request(EVENTNAME.selectJinYingZhuangkuang, data, handler(self, self.resultInfo))

    -- self:resultInfo()
end

function statistical_jy:resultInfo( event )

    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error

    -- dump(netData)
    -- dump(data)
    -- data.listCount
    if netData.returnCode == 0 then
    --     self.txt_message:setVisible(data.listCount <= 0)
        
    --     self.tatolPage = math.max(math.ceil(data.listCount / self.page_num),1)
    --     self.curPage = param.page
    --     self.labelPage:setString(self.curPage.."/"..self.tatolPage)
        self.infoList = data
        self:refreshList()
    else
    --     -- 返回错误
    end




    -- self.infoList = {}
    -- for i = 1, 100 do
    --     local info = {
    --         dateTime = os.time() - i*200,
    --         allNum = i*2,                   -- 总场次
    --         allSNum = i*3,                  -- 总消耗
    --         winNum = i*4,                   -- 大赢家次数
    --     }
    --     self.infoList[i] = info
    -- end

    -- self:refreshList()
end

function statistical_jy:addEventListenerScrollView(target, selector)

    if #self.infoList < 20 then
        return
    end

    local pos = self.infoScrollView:getInnerContainerPosition().y
    -- dump(pos)   -- -8530   底 0  9000  高度:470   -8080

    local passItemNum = math.ceil((pos - self.allTripH)/self.itemH)  -- 当前滑了多少格
    

    local fromItemIndex = math.max(1,(passItemNum - self.cacheItemNum))
    local toItemIndex = math.min(#self.infoList,(passItemNum + self.cacheItemNum + self.numPerPage))

    -- -- 展示  passItemNum - self.cacheItemNum 到  passItemNum + self.cacheItemNum + self.numPerPage
    for i = fromItemIndex, toItemIndex do
        if self.itemList[i] == nil then
            self.itemList[i] = self.roleInfoPanel:clone()
            self.infoScrollView:addChild(self.itemList[i])
            self.itemList[i]:setPositionY(self.itemH*self.allNum - i*self.itemH)
            self:setRecordInfo(self.itemList[i],self.infoList[i])
        end
    end

end


function statistical_jy:refreshList()
    self.itemList = {}
    self.cacheItemNum = 4
    self.contH = self.infoScrollView:getContentSize().height   
    self.itemH = self.roleInfoPanel:getContentSize().height
    self.allTripH = self.contH - self.itemH * #self.infoList -- 总可滑动行程
    self.numPerPage = math.ceil(self.contH/self.itemH)

    self.roleInfoPanel:setVisible(false)

    -- dump(self.infoList)

    local infoNode = nil
    self.allNum = #self.infoList
    local endIndex = 20
    if self.allNum < endIndex then
        endIndex = self.allNum
    end

    local allInnerContH = self.itemH*self.allNum
    if allInnerContH < 360 then
        allInnerContH = 360
    end

    for i = 1, endIndex do
        if i == 1 then
            infoNode = self.roleInfoPanel
            infoNode:setVisible(true)
        else
            infoNode = self.roleInfoPanel:clone()
            infoNode:setVisible(true)
            self.infoScrollView:addChild(infoNode)
        end
        infoNode:setPositionY(allInnerContH - i*self.itemH)
        self.itemList[i] = infoNode
        self:setRecordInfo(infoNode,self.infoList[i])
    end
    self.infoScrollView:setInnerContainerSize(cc.size(934,allInnerContH))
end

function statistical_jy:setRecordInfo(recordNode,recordInfo)
    local infoNode = recordNode:getChildByName("info")
    infoNode:getChildByName("Text_1"):setString( recordInfo.date  )
    infoNode:getChildByName("Text_2"):setString( recordInfo.playCount )
    infoNode:getChildByName("Text_3"):setString( recordInfo.useCards )
    infoNode:getChildByName("Text_4"):setString( recordInfo.dyjCount )
end

function statistical_jy:onExit()
    ReqMgr:delHandle("statistical_jy", EVENTNAME)
end


return statistical_jy