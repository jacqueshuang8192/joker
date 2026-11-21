-- 群统计

local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local statistical_qtj = class("statistical_qtj", NewViewBaseLayer)

-- local statistical_qtj = class("statistical_qtj",function()
--     return display.newLayer("statistical_qtj")
-- end)

local EVENTNAME = {
	-- QUERY_ACTIVITIES_RESULT = "/freeGame/queryActivitiesResult",
	selectMySonPlayInfo = "/selectMySonPlayInfo",
}


function statistical_qtj:ctor(family_id, roleType)
    self.family_id = family_id
    self.roleType = roleType

    local path = "hall/res/FriendScircle/statistical_qtj.csb"
    statistical_qtj.super.ctor(self, path)


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

function statistical_qtj:initUI()
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
    -- self.roleInfoPanel:getChildByName("info1"):
    -- self.roleInfoPanel:getChildByName("info2"):
    -- 玩家 = self.roleInfoPanel:getChildByName("info2"):getChildByName("Text_3_0"):setString("玩家")
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

    self:initEvent()
end

function statistical_qtj:initEvent()
    ReqMgr:addHandle("statistical_qtj", EVENTNAME)

    self.btnDate1:onClick(handler(self, self.onClickDateSelect), true)
    self.btnClose:onClick(handler(self, self.onClickBtnClose), true)

    self.cytjBtn:onClick(handler(self, self.onClickcytjBtn), true)
    self.jyztBtn:onClick(handler(self, self.onClickjyztBtn), true)
    self.qtjBtn:onClick(handler(self, self.onClickqtjBtn), true)
    self.fjjlBtn:onClick(handler(self, self.onClickfjjlBtn), true)
    self.infoScrollView:addEventListenerScrollView(handler(self, self.addEventListenerScrollView))

end

function statistical_qtj:onClickDateSelect()
    local statistical_cytj = require("hall.record.RecordSelDateLayer").new(10)
    statistical_cytj:addTo(self)
end

function statistical_qtj:onClickcytjBtn()
    local statistical_cytj = require("hall.familyCircle.statistical_cytj").new(self.family_id,self.roleType)
    statistical_cytj:addTo(self:getParent())
    
    self:removeSelf()
end

function statistical_qtj:onClickjyztBtn()
    local statistical_jy = require("hall.familyCircle.statistical_jy").new(self.family_id,self.roleType)
    statistical_jy:addTo(self:getParent())
    
    self:removeSelf()
end

function statistical_qtj:onClickqtjBtn()
    
end

function statistical_qtj:onClickfjjlBtn()
    local statistical_fjjl = require("hall.familyCircle.statistical_fjjl").new(self.family_id,self.roleType)
    statistical_fjjl:addTo(self:getParent())

    self:removeSelf()
end

function statistical_qtj:onClickBtnClose()
    self:removeSelf()
end

function statistical_qtj:refrashRecordByIndex(idx)
    self.dateText:setString(os.date("%Y-%m-%d", idx))
    -- 查询此日期
    self:reqInfo()
end

function statistical_qtj:onClickBtnmem()
end

function statistical_qtj:reqInfo()
    local data = {}
    data["XYUid"] = USER_INFO["uid"]
    data["resultDate"] = self.dateText:getString()
    data["interfaceType"] = "J"
    if self.family_id and tonumber(self.family_id) > 0 then
        data["groupId"] = self.family_id
    end
    -- dump(data)
    ReqMgr:request(EVENTNAME.selectMySonPlayInfo, data, handler(self, self.resultInfo),{},nil,true)
end

function statistical_qtj:resultInfo( event )
    
    local netData = event.netData
    local data = netData.data
    -- dump(data)

    if netData.returnCode == 0 then
        self.infoList = data
        self:refreshList()
    else
        -- 返回错误
    end

    -- 测试数据
    -- self.infoList = {}
    -- for i = 1, 100 do
    --     local info = {
    --         name = "测试" .. i,
    --         photoUrl = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132",
    --         uid = i + 10000,
    --         roletype = i%4,
    --         isManager = false,
    --         expend = i*12,
    --         winNum = i*7,
    --         allSend = i*6,
    --     }
    --     self.infoList[i] = info
    -- end

    -- self:refreshList()
end

function statistical_qtj:addEventListenerScrollView(target, selector)

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
            self.itemList[i]:setVisible(true)
            self.infoScrollView:addChild(self.itemList[i])
            self.itemList[i]:setPositionY(90* (self.allNum - i))
            self:setRecordInfo(self.itemList[i],self.infoList[i])
        end
    end

end

function statistical_qtj:refreshList()
    self.itemList = {}

    

    for index, value in ipairs(self.infoScrollView:getChildren()) do
        if index == 1 then
            value:setVisible(false)
        else
            value:removeSelf()
        end
    end
    

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

function statistical_qtj:setRecordInfo(recordNode,recordInfo)

    if recordInfo.roleType == 0 or recordInfo.roleType == 2 then
        recordNode:getChildByName("info2"):setVisible(false)
        recordNode:getChildByName("Text_3_0"):setVisible(false)

        recordNode:getChildByName("info1"):setVisible(true)
        recordNode:getChildByName("Text_7"):setVisible(true)
        recordNode:getChildByName("btnmem"):setVisible(true)
        recordNode:getChildByName("btnopenclose"):setVisible(true)
        recordNode:getChildByName("Image_1"):setVisible(false)
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
    recordNode:getChildByName("Text_4"):setString(recordInfo.myAllSonPlayCount)
    recordNode:getChildByName("Text_5"):setString(recordInfo.myAllSonDYJCount)
    recordNode:getChildByName("Text_6"):setString(string.format("%.2f", recordInfo.myAllProfit/100))

    -- recordNode:getChildByName("btnmem").param = recordInfo.uid
    -- recordNode:getChildByName("btnmem"):addClickEventListener(handler(self, self.openSubInfo))
    
    recordNode:getChildByName("btnmem"):addClickEventListener(function(sender)
        self:reqSubInfo(recordInfo.uid)
    end)
end

function statistical_qtj:reqSubInfo(uid)
    ReqMgr:delHandle("statistical_qtj", EVENTNAME)
    self.reqUid = uid
    local statistical_qtj = require("hall.familyCircle.statistical_qtj_sub").new(self.family_id,self.roleType,data,uid,self)
    statistical_qtj:addTo(self)
end

function statistical_qtj:resultSubInfo(event)
    local netData = event.netData
    local data = netData.data
    dump(data)
    if netData.returnCode == 0 then
        local statistical_qtj = require("hall.familyCircle.statistical_qtj_sub").new(self.family_id,self.roleType,data,self.reqUid)
        statistical_qtj:addTo(self)
    else
        -- 返回错误
    end
end



function statistical_qtj:getDuty(roleType,isManager)
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


function statistical_qtj:onExit()
    ReqMgr:delHandle("statistical_qtj", EVENTNAME)
end


return statistical_qtj