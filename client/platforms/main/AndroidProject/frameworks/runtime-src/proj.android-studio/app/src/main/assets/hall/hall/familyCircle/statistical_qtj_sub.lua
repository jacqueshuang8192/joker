-- 群统计
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local statistical_qtj_sub = class("statistical_qtj_sub", NewViewBaseLayer)


-- local statistical_qtj_sub = class("statistical_qtj",function()
--     return display.newLayer("statistical_qtj")
-- end)

local EVENTNAME = {
	-- QUERY_ACTIVITIES_RESULT = "/freeGame/queryActivitiesResult",
	selectMySonPlayInfo = "/selectMySonPlayInfo",
}


function statistical_qtj_sub:ctor(family_id, roleType,listInfo,reqUid,qtjNode)
    self.family_id = family_id
    self.roleType = roleType
    self.infoList = listInfo
    self.reqUid = reqUid
    self.qtjNode = qtjNode

    local path = "hall/res/FriendScircle/statistical_qtj.csb"
    statistical_qtj_sub.super.ctor(self, path)
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
    -- self:refreshList()
end

function statistical_qtj_sub:initUI()
    -- self.root = self._csbNode:getChildByName("root")
    local wanfaBg = self.root:getChildByName("wanfaBg")
    self.btnClose = wanfaBg:getChildByName("btnClose")
    self.qzjNode = self.root:getChildByName("qzjNode")

    -- 时间选择
    self.btnDate1 = self.qzjNode:getChildByName("btninput1")
    self.dateText = self.btnDate1:getChildByName("textinput1")
    self.dateText:setString(os.date("%Y-%m-%d", os.time()))

    self.infoScrollView = self.qzjNode:getChildByName("ScrollView_1")
    self.roleInfoPanel = self.infoScrollView:getChildByName("Panel_l")
    self.infoScrollView:setScrollBarEnabled(false)
    self.roleInfoPanel:setVisible(false)
    
    self.cytjBtn = self.root:getChildByName("btn_tab_1")    -- 成员统计
    self.jyztBtn = self.root:getChildByName("btn_tab_2")    -- 经营状况
    self.qtjBtn = self.root:getChildByName("btn_tab_3")     -- 群统计
    self.fjjlBtn = self.root:getChildByName("btn_tab_4")    -- 房间记录
    if self.roleType == 2 then
        self.jyztBtn:setVisible(false)
    end

    self:initEvent()
end

function statistical_qtj_sub:initEvent()
    ReqMgr:addHandle("statistical_qtj_sub", EVENTNAME)

    self.btnDate1:onClick(handler(self, self.onClickDateSelect), true)
    self.btnClose:onClick(handler(self, self.onClickBtnClose), true)

    self.cytjBtn:onClick(handler(self, self.onClickcytjBtn), true)
    self.jyztBtn:onClick(handler(self, self.onClickjyztBtn), true)
    self.qtjBtn:onClick(handler(self, self.onClickqtjBtn), true)
    self.fjjlBtn:onClick(handler(self, self.onClickfjjlBtn), true)
    self.infoScrollView:addEventListenerScrollView(handler(self, self.addEventListenerScrollView))

end

function statistical_qtj_sub:onClickDateSelect()
    local statistical_cytj = require("hall.record.RecordSelDateLayer").new(10)
    statistical_cytj:addTo(self)
end

function statistical_qtj_sub:onClickcytjBtn()
    local statistical_cytj = require("hall.familyCircle.statistical_cytj").new(self.family_id,self.roleType)
    statistical_cytj:addTo(self.qtjNode:getParent())
    self.qtjNode:removeSelf()
    self:removeSelf()
end

function statistical_qtj_sub:onClickjyztBtn()
    local statistical_jy = require("hall.familyCircle.statistical_jy").new(self.family_id,self.roleType)
    statistical_jy:addTo(self.qtjNode:getParent())
    self.qtjNode:removeSelf()
    
    self:removeSelf()
end

function statistical_qtj_sub:onClickqtjBtn()
    
end

function statistical_qtj_sub:onClickfjjlBtn()
    local statistical_fjjl = require("hall.familyCircle.statistical_fjjl").new(self.family_id,self.roleType)
    statistical_fjjl:addTo(self.qtjNode:getParent())
    self.qtjNode:removeSelf()

    self:removeSelf()
end

function statistical_qtj_sub:onClickBtnClose()
    self:removeSelf()
end

function statistical_qtj_sub:refrashRecordByIndex(idx)
    self.dateText:setString(os.date("%Y-%m-%d", idx))
    -- 查询此日期
    self:reqInfo()
end

function statistical_qtj_sub:reqInfo()
    local data = {}
    data["XYUid"] = USER_INFO["uid"]
    data["resultDate"] = self.dateText:getString()
    data["interfaceType"] = "J"
    data["searchId"] = self.reqUid
    if self.family_id and tonumber(self.family_id) > 0 then
        data["groupId"] = self.family_id
    end
    dump(data)
    ReqMgr:request(EVENTNAME.selectMySonPlayInfo, data, handler(self, self.resultInfo),{},nil,true)
    -- self:resultInfo()
end

function statistical_qtj_sub:resultInfo( event )
    local netData = event.netData
    local data = netData.data
    dump(netData)

    if netData.returnCode == 0 then

        self.infoList = data
        self:refreshList()
    else
        -- 返回错误
    end
end

function statistical_qtj_sub:addEventListenerScrollView(target, selector)

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
            self.itemList[i]:setPositionY(90* (self.allNum - i))
            self:setRecordInfo(self.itemList[i],self.infoList[i])
        end
    end

end

function statistical_qtj_sub:refreshList()
    self.itemList = {}

    self.cacheItemNum = 4
    self.contH = self.infoScrollView:getContentSize().height   
    self.itemH = self.roleInfoPanel:getContentSize().height
    self.allTripH = self.contH - self.itemH * #self.infoList -- 总可滑动行程
    self.numPerPage = math.ceil(self.contH/self.itemH)

    self.roleInfoPanel:setVisible(false)

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
            self.infoScrollView:addChild(infoNode)
        end
        -- infoNode:setPositionY(90* (self.allNum - i))
        infoNode:setPositionY(allInnerContH - i*self.itemH)
        self.itemList[i] = infoNode
        self:setRecordInfo(infoNode,self.infoList[i])
    end
    self.infoScrollView:setInnerContainerSize(cc.size(1208,allInnerContH))
end

function statistical_qtj_sub:setRecordInfo(recordNode,recordInfo)

    if recordInfo.roleType == 0 or recordInfo.roleType == 2 then
        recordNode:getChildByName("info2"):setVisible(false)
        recordNode:getChildByName("Text_3_0"):setVisible(false)

        recordNode:getChildByName("info1"):setVisible(true)
        recordNode:getChildByName("Text_7"):setVisible(true)
        recordNode:getChildByName("btnmem"):setVisible(true)
        recordNode:getChildByName("btnopenclose"):setVisible(true)
        recordNode:getChildByName("Image_1"):setVisible(true)
        -- recordNode:getChildByName("Sprite_2"):setVisible(false)
        recordNode:getChildByName("Text_1"):setVisible(true)
        recordNode:getChildByName("Text_1"):setString(self:getDuty(recordInfo.roleType))
    else
        recordNode:getChildByName("info2"):setVisible(true)
        recordNode:getChildByName("Text_3_0"):setVisible(true)

        recordNode:getChildByName("info1"):setVisible(false)
        recordNode:getChildByName("Text_7"):setVisible(false)
        recordNode:getChildByName("btnmem"):setVisible(false)
        recordNode:getChildByName("btnopenclose"):setVisible(false)
        recordNode:getChildByName("Image_1"):setVisible(false)
        -- recordNode:getChildByName("Sprite_1"):setVisible(false)
        -- recordNode:getChildByName("Sprite_2"):setVisible(false)
        recordNode:getChildByName("Text_1"):setVisible(false)
    end

    if recordInfo.uid == self.reqUid or recordInfo.roleType == 0  then
        recordNode:getChildByName("btnmem"):setVisible(false)
        recordNode:getChildByName("Text_7"):setVisible(false)
    end

    require("hall.GameCommon"):getUserHead(recordInfo.smallIcon, "", "", recordNode:getChildByName("headImg"), 69, false, "", true)
    
    local strName = require("hall.GameCommon"):formatNick(recordInfo.nickName or "0")
    recordNode:getChildByName("Text_2"):setString(strName)
    
    recordNode:getChildByName("Text_3"):setString(recordInfo.uid)
    recordNode:getChildByName("Text_4"):setString(string.format("%.2f", recordInfo.myAllProfit/100))
    recordNode:getChildByName("Text_5"):setString(recordInfo.myAllSonDYJCount)
    recordNode:getChildByName("Text_6"):setString(recordInfo.myAllSonPlayCount)
    recordNode:getChildByName("btnmem"):addClickEventListener(function(sender)
        self:reqSubInfo(recordInfo.uid)
    end)
end

function statistical_qtj_sub:onClickBtnmem()
end

function statistical_qtj_sub:reqSubInfo(uid)
    ReqMgr:delHandle("statistical_qtj_sub", EVENTNAME)
    self.reqUid = uid
    local statistical_qtj = require("hall.familyCircle.statistical_qtj_sub").new(self.family_id,self.roleType,data,uid)
    statistical_qtj:addTo(self:getParent())
    self:removeSelf()

    -- 
    -- local data = {}
    -- data["XYUid"] = USER_INFO["uid"]
    -- data["resultDate"] = self.dateText:getString()
    -- data["interfaceType"] = "J"
    -- if self.family_id and tonumber(self.family_id) > 0 then
    --     data["groupId"] = self.family_id
    -- end
    -- data["searchId"] = uid
    -- dump(data)

    -- ReqMgr:request(EVENTNAME.selectMySonPlayInfo, data, handler(self, self.resultSubInfo),{},nil,true)
end

function statistical_qtj_sub:getDuty(roleType,isManager)
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


function statistical_qtj_sub:onExit()
    ReqMgr:delHandle("statistical_qtj_sub", EVENTNAME)
end


return statistical_qtj_sub