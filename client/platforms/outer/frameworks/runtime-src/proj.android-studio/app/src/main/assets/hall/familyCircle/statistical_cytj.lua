-- 成员统计
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local statistical_cytj = class("statistical_cytj", NewViewBaseLayer)

-- local statistical_cytj = class("statistical_cytj",function()
--     return display.newLayer("statistical_cytj")
-- end)

local EVENTNAME = {
	-- QUERY_ACTIVITIES_RESULT = "/freeGame/queryActivitiesResult",
    -- SELECT_POINT_CHANGE_HISTORY = "/selectPointChangeHistory",
    selectGongXianByTime = "/selectGongXianByTime",
}

function statistical_cytj:ctor(family_id, roleType)
    self.family_id = family_id
    self.roleType = roleType

    local path = "hall/res/FriendScircle/statistical_cytj.csb"
    statistical_cytj.super.ctor(self, path)

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

    self.lastFromIndex = 1
    self.lastToIndex = 1

    self:initUI()

    self:reqInfo()
end

function statistical_cytj:initUI()
    -- self.root = self._csbNode:getChildByName("root")
    local wanfaBg = self.root:getChildByName("wanfaBg")
    self.btnClose = wanfaBg:getChildByName("btnClose")
    self.qzjNode = self.root:getChildByName("qzjNode")

    -- 时间选择
    self.btnDate1 = self.qzjNode:getChildByName("btninput1")
    self.btnDateTxt1 = self.btnDate1:getChildByName("textinput1")

    
    self.ScrollView_1 = self.qzjNode:getChildByName("ScrollView_1")
    self.roleInfoPanel = self.ScrollView_1:getChildByName("Panel_l")
    self.ScrollView_1:setScrollBarEnabled(false)
    self.roleInfoPanel:setVisible(false)
    -- 排名 = self.roleInfoPanel:getChildByName("info2"):getChildByName("Text_3_0")
    -- 头像 = self.roleInfoPanel:getChildByName("headImg")
    -- 名称 = self.roleInfoPanel:getChildByName("Text_2")
    -- ID = self.roleInfoPanel:getChildByName("Text_3")
    -- 身份 = self.roleInfoPanel:getChildByName("Text_4")
    -- 赠送 = self.roleInfoPanel:getChildByName("Text_6")

    


    self.cytjBtn = self.root:getChildByName("btn_tab_1")    -- 成员统计
    self.jyztBtn = self.root:getChildByName("btn_tab_2")    -- 经营状况
    self.qtjBtn = self.root:getChildByName("btn_tab_3")     -- 群统计
    self.fjjlBtn = self.root:getChildByName("btn_tab_4")    -- 房间记录
    if self.roleType == 2 then
        self.jyztBtn:setVisible(false)
    end


    self.dateSelBtn = self.qzjNode:getChildByName("btninput1")    -- 日期选择
    self.dateText = self.dateSelBtn:getChildByName("textinput1")    -- 日期

    self.dateText:setString(os.date("%Y-%m-%d", os.time()))

    self:initEvent()
end

function statistical_cytj:initEvent()
    ReqMgr:addHandle("statistical_cytj", EVENTNAME)
    self.btnDate1:onClick(handler(self, self.onClickDateSelect), true)
    self.btnClose:onClick(handler(self, self.onClickBtnClose), true)

    self.cytjBtn:onClick(handler(self, self.onClickcytjBtn), true)
    self.jyztBtn:onClick(handler(self, self.onClickjyztBtn), true)
    self.qtjBtn:onClick(handler(self, self.onClickqtjBtn), true)
    self.fjjlBtn:onClick(handler(self, self.onClickfjjlBtn), true)

    self.dateSelBtn:onClick(handler(self, self.onClickTimeBtn), true)

    self.ScrollView_1:addEventListenerScrollView(handler(self, self.addEventListenerScrollView))
end

function statistical_cytj:onClickDateSelect()
    local statistical_cytj = require("hall.record.RecordSelDateLayer").new(10)
    statistical_cytj:addTo(self)
end

function statistical_cytj:onClickcytjBtn()
    
end

function statistical_cytj:onClickjyztBtn()
    local statistical_jy = require("hall.familyCircle.statistical_jy").new(self.family_id,self.roleType)
    statistical_jy:addTo(self:getParent())
    
    self:removeSelf()
end

function statistical_cytj:onClickqtjBtn()
    local statistical_qtj = require("hall.familyCircle.statistical_qtj").new(self.family_id,self.roleType)
    statistical_qtj:addTo(self:getParent())
    
    self:removeSelf()
end

function statistical_cytj:onClickfjjlBtn()
    local statistical_fjjl = require("hall.familyCircle.statistical_fjjl").new(self.family_id,self.roleType)
    statistical_fjjl:addTo(self:getParent())

    self:removeSelf()
end

function statistical_cytj:onClickTimeBtn()
    local statistical_cytj = require("hall.record.RecordSelDateLayer").new(15)
    statistical_cytj:addTo(self)
    
    -- self:removeSelf()
end

function statistical_cytj:refrashRecordByIndex(idx)
    -- dump(idx)
    self.dateText:setString(os.date("%Y-%m-%d", idx))
    -- 查询此日期
    self:reqInfo()
end


function statistical_cytj:onClickBtnClose()
    self:removeSelf()
end

function statistical_cytj:reqInfo()
    -- local page = page or 1
    -- local searchid = searchid or 0

    local data = {}
    data["XYUid"] = USER_INFO["uid"]
    -- data["currentPage"] = page
    -- data["pageSize"] = self.page_num
    -- data["type"] = self.type
    -- data["searchId"] = psearchid
    data["interfaceType"] = "J"
    data["resultDate"] = self.dateText:getString()
    
    if self.family_id and tonumber(self.family_id) > 0 then
        data["groupId"] = self.family_id
    end
    dump(data)
    ReqMgr:request(EVENTNAME.selectGongXianByTime, data, handler(self, self.resultInfo), {page = page, type = self.type})
    
    -- self:resultInfo()
end

function statistical_cytj:resultInfo( event )
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error

    dump(netData)
    dump(param)
    dump(returnCode)
    dump(data)
    dump(error)

    -- -- data.listCount
    if netData.returnCode == 0 then
        -- netData.data
        -- self.txt_message:setVisible(data.listCount <= 0)
        
        -- self.tatolPage = math.max(math.ceil(data.listCount / self.page_num),1)
        -- self.curPage = param.page
        -- self.labelPage:setString(self.curPage.."/"..self.tatolPage)
        -- self.infoList = data.list
        self.infoList = netData.data
        
        self:refreshList()
    else
        -- 返回错误
    end

    
    -- for i = 1, 1000 do
    --     local info = {
    --         name = "测试" .. i,
    --         photoUrl = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132",
    --         uid = i + 10000,
    --         score = i*3 + 10000,
    --         roletype = i%4,
    --         isManager = false,
    --         rankIndex = i,
    --     }
    --     self.infoList[i] = info
    -- end

    -- self:refreshList()
end

function statistical_cytj:addEventListenerScrollView(target, selector)

    if #self.infoList < 20 then
        return
    end

    local pos = self.ScrollView_1:getInnerContainerPosition().y
    -- dump(pos)   -- -8530   底 0  9000  高度:470   -8080

    local passItemNum = math.ceil((pos - self.allTripH)/self.itemH)  -- 当前滑了多少格
    
    for i = self.lastFromIndex, self.lastToIndex do
        if self.itemList[i] ~= nil then
            self.itemList[i]:setVisible(false)
        end
    end

    local fromItemIndex = math.max(1,(passItemNum - self.cacheItemNum))
    local toItemIndex = math.min(#self.infoList,(passItemNum + self.cacheItemNum + self.numPerPage))
    self.lastFromIndex = fromItemIndex
    self.lastToIndex = toItemIndex

    -- -- 展示  passItemNum - self.cacheItemNum 到  passItemNum + self.cacheItemNum + self.numPerPage
    for i = fromItemIndex, toItemIndex do
        if self.itemList[i] == nil then
            self.itemList[i] = self.roleInfoPanel:clone()
            self.ScrollView_1:addChild(self.itemList[i])
            self.itemList[i]:setPositionY(90* (self.allNum - i))
            self:setRecordInfo(self.itemList[i],self.infoList[i])
        else
            self.itemList[i]:setVisible(true)
        end
    end

end

function statistical_cytj:refreshList()

    self.itemList = {}

    self.cacheItemNum = 4
    self.contH = self.ScrollView_1:getContentSize().height   
    self.itemH = self.roleInfoPanel:getContentSize().height
    self.allTripH = self.contH - self.itemH * #self.infoList -- 总可滑动行程
    self.numPerPage = math.ceil(self.contH/self.itemH)

    for index, value in ipairs(self.ScrollView_1:getChildren()) do
        if index == 1 then
            value:setVisible(false)
        else
            value:removeSelf()
        end
    end

    -- self.roleInfoPanel:setVisible(false)

    local infoNode = nil
    self.allNum = #self.infoList
    local endIndex = 20
    if self.allNum < endIndex then
        endIndex = self.allNum
    end

    local allInnerContH = self.itemH*self.allNum
    if allInnerContH < 470 then
        allInnerContH = 470
    end

    for i = 1, endIndex do
        if i == 1 then
            infoNode = self.roleInfoPanel
            infoNode:setVisible(true)
        else
            infoNode = self.roleInfoPanel:clone()
            infoNode:setVisible(true)
            self.ScrollView_1:addChild(infoNode)
        end
        -- infoNode:setPositionY(90* (self.allNum - i))
        infoNode:setPositionY(allInnerContH - i*self.itemH)
        self.itemList[i] = infoNode
        self:setRecordInfo(infoNode,self.infoList[i],i)
    end
    self.ScrollView_1:setInnerContainerSize(cc.size(1208,allInnerContH))

end


function statistical_cytj:setRecordInfo(recordNode,recordInfo,index)
    if index < 4 then
        recordNode:getChildByName("Text_3_0"):setTextColor(cc.c3b(226,60,64))
    else
        recordNode:getChildByName("Text_3_0"):setTextColor(cc.c3b(66,103,90))
    end
    recordNode:getChildByName("Text_3_0"):setString(index)

    require("hall.GameCommon"):getUserHead(recordInfo.smallIcon, "", "", recordNode:getChildByName("headImg"), 69, false, "", true)
    
    local strName = require("hall.GameCommon"):formatNick(recordInfo.nickName or "0")
    recordNode:getChildByName("Text_2"):setString(strName)

    recordNode:getChildByName("Text_3"):setString(recordInfo.uid)

    recordNode:getChildByName("Text_4"):setString(self:getDuty(recordInfo.roleType))   -- 身份
    recordNode:getChildByName("Text_6"):setString(string.format("%.2f", recordInfo.gongXianCount/100)  )   -- 赠送额

end

function statistical_cytj:getDuty(roleType,isManager)
    if isManager == 1 then
        return "管理员"
    end

    if roleType == 0 then
        return "盟主"
    elseif roleType ==2 then
        return "合伙人"
    elseif roleType ==1 then
        return "管理员"
    elseif roleType ==3 then
        return "普通成员"
    end
end

function statistical_cytj:onExit()
    ReqMgr:delHandle("statistical_cytj", EVENTNAME)
end


return statistical_cytj