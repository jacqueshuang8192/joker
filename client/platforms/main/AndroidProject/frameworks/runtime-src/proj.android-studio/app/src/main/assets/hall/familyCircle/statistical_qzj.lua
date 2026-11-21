-- 群战绩

local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local statistical_qzj = class("statistical_qzj", NewViewBaseLayer)


-- local statistical_qzj = class("statistical_qzj",function()
--     return display.newLayer("statistical_qzj")
-- end)

local EVENTNAME = {
	-- QUERY_ACTIVITIES_RESULT = "/freeGame/queryActivitiesResult",
	selectClubPlayInfo = "/selectClubPlayInfo",
}


function statistical_qzj:ctor(family_id, roleType)
    self.family_id = family_id
    self.roleType = roleType

    local path = "hall/res/FriendScircle/statistical_qzj.csb"
    statistical_qzj.super.ctor(self, path)

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


    self.rightListInfo = {}
    self.rightListShowInfo = {}
    -- for i = 1, 20 do
    --     local info = {
    --         name = "名称" .. i,
    --         uid = i + 10000,
    --         rankIndex = i ,
    --         allScore = i*55 ,
    --         allNum = i*21 ,
    --         allWin = i*9 ,
    --         allSendFace = i*3 ,
    --         allSendSNum = i*4 ,
    --         photoUrl = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132",
    --     }
    --     self.rightListInfo[i] = info
    -- end

    self.lastSortIndex = -1
    self.sortUp = true
    self.lastLeftType = 1   -- 0 选择我的数据  1 选择群   > 100 id 选择合伙人

    self:initUI()
    self:reqAllInfo()
    -- self:resultInfo()
end

function statistical_qzj:initUI()
    -- self.root = self._csbNode:getChildByName("root")
    local wanfaBg = self.root:getChildByName("wanfaBg")
    self.btnClose = wanfaBg:getChildByName("btnClose")
    self.qzjNode = self.root:getChildByName("qzjNode")

    -- 搜索
    self.btnSearch = self.qzjNode:getChildByName("btnCreate")
    self.input_word = self.qzjNode:getChildByName("tip_bg2"):getChildByName("input_word")

    -- 排序按钮
    self.tip_bg3 = self.qzjNode:getChildByName("tip_bg3")
    self.pxBtns = {}
    self.pxTexts = {}
    self.pxIndex = -1;
    self.pxIndexSp = self.tip_bg3:getChildByName("tip_bg1")
    self.pxIndexSp:setVisible(false)

    -- 左边列表
    self.leftListV = self.qzjNode:getChildByName("tip_bg1"):getChildByName("ListView_left")
    self.leftListV:setScrollBarEnabled(false)
    self.leftListInfo = self.leftListV:getChildByName("Panel_1")
    self.leftInfo=self.leftListV:getChildByName("Panel_1");
    -- self.leftInfoText = self.leftInfo:getChildByName("textinput");
    -- self.leftInfoBackB = self.leftInfo:getChildByName("backb");
    -- self.leftInfoBackR = self.leftInfo:getChildByName("backr");
    -- self.leftInfoText:setString("ceshi\n第二行")

    self.roleListV = self.qzjNode:getChildByName("ScrollView_1")
    self.roleListV:setScrollBarEnabled(false)
    self.roleInfoPanel = self.roleListV:getChildByName("Panel_l")
    self.roleInfoPanel:setVisible(false)
    -- 排名 = self.roleInfoPanel:getChildByName("info"):getChildByName("Text_1")
    -- 头像 = self.roleInfoPanel:getChildByName("info"):getChildByName("headImg")
    -- Text_2 Text_8

    -- 总计
    self.allBack = self.qzjNode:getChildByName("tip_bg4")
    self.allNum = self.allBack:getChildByName("Text_2")
    self.allScore = self.allBack:getChildByName("Text_4")
    self.allGame = self.allBack:getChildByName("Text_5")
    self.allWin = self.allBack:getChildByName("Text_6")
    self.allSend = self.allBack:getChildByName("Text_7")        -- 赠送表情
    self.allSendGame = self.allBack:getChildByName("Text_8")    -- 赠送场次

    self.allNum:setString("")
    self.allScore:setString("")
    self.allGame:setString("")
    self.allWin:setString("")
    self.allSend:setString("")
    self.allSendGame:setString("")


    -- 时间选择
    self.btnDate1 = self.qzjNode:getChildByName("btninput1")
    self.btnDateTxt1 = self.btnDate1:getChildByName("textinput1")
    self.btnDate2 = self.qzjNode:getChildByName("btninput2")
    self.btnDateTxt2 = self.btnDate2:getChildByName("textinput1")
    self.btnDateTxt1:setString(os.date("%Y-%m-%d", os.time()))
    self.btnDateTxt2:setString(os.date("%Y-%m-%d", os.time()))

    self.timeBack1 = self.qzjNode:getChildByName("time1")
    self.timeBack2 = self.qzjNode:getChildByName("time2")

    self.showtime1 = self.timeBack1:getChildByName("text_time1")
    self.showtime2 = self.timeBack2:getChildByName("text_time2")

    self.showtime1:setString("0")
    self.showtime2:setString("24")
    self:newEditBox(self.showtime1)
    self:newEditBox(self.showtime2)
    
    self.checkAll = self.qzjNode:getChildByName("checkBox")
    -- self.checkAll:isSelected()

    self.cytjBtn = self.root:getChildByName("btn_tab_1")    -- 成员统计
    self.jyztBtn = self.root:getChildByName("btn_tab_2")    -- 经营状况
    self.qtjBtn = self.root:getChildByName("btn_tab_3")     -- 群统计
    self.fjjlBtn = self.root:getChildByName("btn_tab_4")    -- 房间记录
    if self.roleType == 2 then
        self.jyztBtn:setVisible(false)
    end

    if self.roleType == 3 then
        self.cytjBtn:setVisible(false)
        self.jyztBtn:setVisible(false)
        self.qtjBtn:setVisible(false)
    end
    
    for i = 1, 7 do
        self.pxBtns[i] = self.tip_bg3:getChildByName("btntitle" .. i)
        self.pxTexts[i] = self.tip_bg3:getChildByName("Text_" .. i)
    end

    self:initEvent()
end


function statistical_qzj:newEditBox(node, maxLength, string)
    string = string or node:getString()
    maxLength = maxLength or 2

    local params = {
        size = node:getContentSize(),
        -- fontSize = node:getFontSize(),
        fontSize = node:getFontSize(),
        fontColor = node:getTextColor(),
        maxLength = maxLength,
        inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
        -- placeHolder = string,
    }
    local editBox = ccs.newEditBox(params)
    node:getParent():addChild(editBox)
    editBox:setAnchorPoint(node:getAnchorPoint())
    editBox:setPosition(node:getPosition())
    local idx = editBox:getLocalZOrder()
    editBox:setLocalZOrder(-99)
    editBox:setText(node:getString())
    editBox:registerScriptEditBoxHandler(function( strEventName,sender )
        if strEventName == "began" then--光标进入，选中全部内容
            sender:setText("")
            node:setString("")
            node:setVisible(false)
        elseif strEventName == "ended" then--当编辑框失去焦点并且键盘消失的时候被调用
            local num = tonumber(sender:getText()) or 0
            num = math.floor(num)
            if num < 0 then
                num = 0
            elseif num > 24 then
                num = 24
            end
            sender:setText(num)
            node:setString(num)
            node:setVisible(true)
            self:reqAllInfo()
        elseif strEventName == "return" then--当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
        elseif strEventName == "changed" then--输入内容改变时调用
            local num = tonumber(sender:getText()) or 0
            num = math.floor(num)
            if num < 0 then
                num = 0
            elseif num > 24 then
                num = 24
            end
            node:setString(num)
        end
    end)
end


function statistical_qzj:initEvent()
    ReqMgr:addHandle("statistical_qzj", EVENTNAME)
    self.btnClose:onClick(handler(self, self.onClickBtnClose), true)

    self.cytjBtn:onClick(handler(self, self.onClickcytjBtn), true)
    self.jyztBtn:onClick(handler(self, self.onClickjyztBtn), true)
    self.qtjBtn:onClick(handler(self, self.onClickqtjBtn), true)
    self.fjjlBtn:onClick(handler(self, self.onClickfjjlBtn), true)
    self.btnSearch:onClick(handler(self, self.onClickSearchBtn), true)

    self.btnDate1:onClick(handler(self, self.onClickTimeBtn1), true)
    self.btnDate2:onClick(handler(self, self.onClickTimeBtn2), true)

    self.checkAll:onClick(handler(self, self.onClickCheckAll), true)

    self.roleListV:addEventListenerScrollView(handler(self, self.addEventListenerScrollView))

    
    for i = 1, 7 do
        self.pxBtns[i]:addClickEventListener(function(sender)
            -- 排列数据
            if i ~= 2 then
                self:sortRightInfo(i)
            end
        end)
    end

    
    -- reqInfo
end

function statistical_qzj:onClickBtntitle1()
end

function statistical_qzj:onClickBtntitle2()
end

function statistical_qzj:onClickBtntitle3()
end

function statistical_qzj:onClickBtntitle4()
end

function statistical_qzj:onClickBtntitle5()
end

function statistical_qzj:onClickBtntitle6()
end

function statistical_qzj:onClickBtntitle7()
end

function statistical_qzj:addEventListenerScrollView(target, selector)

    if #self.rightListShowInfo < 20 then
        return
    end

    local pos = self.roleListV:getInnerContainerPosition().y

    local passItemNum = math.ceil((pos - self.allTripH)/self.itemH)  -- 当前滑了多少格
    

    local fromItemIndex = math.max(1,(passItemNum - self.cacheItemNum))
    local toItemIndex = math.min(#self.rightListShowInfo,(passItemNum + self.cacheItemNum + self.numPerPage))

    -- -- 展示  passItemNum - self.cacheItemNum 到  passItemNum + self.cacheItemNum + self.numPerPage
    for i = fromItemIndex, toItemIndex do
        if self.itemList[i] == nil then
            self.itemList[i] = self.roleInfoPanel:clone()
            self.itemList[i]:setVisible(true)
            self.roleListV:addChild(self.itemList[i])
            self.itemList[i]:setPositionY(90* (self.allNum2 - i))
            -- self:setRecordInfo(self.itemList[i],self.infoList[i])
            local infoNode = self.itemList[i]
            local info = self.rightListShowInfo[i]
            infoNode:getChildByName("info"):getChildByName("Text_1"):setString(info.rankIndex)
            require("hall.GameCommon"):getUserHead(info.smallIcon, "", "", infoNode:getChildByName("info"):getChildByName("headImg"), 69, false, "", true)

            local strName = require("hall.GameCommon"):formatNick(info.nickName or "0")
            infoNode:getChildByName("info"):getChildByName("Text_2"):setString(strName)

            infoNode:getChildByName("info"):getChildByName("Text_3"):setString(info.uid)
            infoNode:getChildByName("info"):getChildByName("Text_4"):setString(string.format("%.2f", info.changePoint/100))
            infoNode:getChildByName("info"):getChildByName("Text_5"):setString(info.playCount)
            infoNode:getChildByName("info"):getChildByName("Text_6"):setString(info.dyjCount)
            infoNode:getChildByName("info"):getChildByName("Text_7"):setString(string.format("%.2f", info.profitCount/100))
            infoNode:getChildByName("info"):getChildByName("Text_8"):setString(info.profitTimes)

        end
    end

end


function statistical_qzj:onClickCheckAll()
    -- dump(self.checkAll:isSelected())
    self:reqAllInfo()
    
end

function statistical_qzj:onClickTimeBtn1()
    local statistical_cytj = require("hall.record.RecordSelDateLayer").new(10)
    statistical_cytj:addTo(self)
    self.TimeClickIndex = 1
end

function statistical_qzj:onClickTimeBtn2()
    local statistical_cytj = require("hall.record.RecordSelDateLayer").new(5)
    statistical_cytj:addTo(self)
    self.TimeClickIndex = 2
end

function statistical_qzj:refrashRecordByIndex(idx)
    if idx < os.time() - (7)*24*3600 then
        idx = os.time() - (7)*24*3600
    end
    if self.TimeClickIndex == 1 then
        self.btnDateTxt1:setString(os.date("%Y-%m-%d", idx))
    elseif self.TimeClickIndex == 2 then
        self.btnDateTxt2:setString(os.date("%Y-%m-%d", idx))
    end
    
    self:reqAllInfo()
end

function statistical_qzj:onClickcytjBtn()
    local statistical_cytj = require("hall.familyCircle.statistical_cytj").new(self.family_id,self.roleType)
    statistical_cytj:addTo(self:getParent())
    
    self:removeSelf()
end

function statistical_qzj:onClickjyztBtn()
    local statistical_jy = require("hall.familyCircle.statistical_jy").new(self.family_id,self.roleType)
    statistical_jy:addTo(self:getParent())
    
    self:removeSelf()
end

function statistical_qzj:onClickqtjBtn()
    local statistical_qtj = require("hall.familyCircle.statistical_qtj").new(self.family_id,self.roleType)
    statistical_qtj:addTo(self:getParent())
    
    self:removeSelf()
end

function statistical_qzj:onClickfjjlBtn()
    local statistical_fjjl = require("hall.familyCircle.statistical_fjjl").new(self.family_id,self.roleType)
    statistical_fjjl:addTo(self:getParent())

    self:removeSelf()
end


function statistical_qzj:reqAllInfo()
    local data = {}
    data["XYUid"] = USER_INFO["uid"]
    -- data["resultDate"] = self.dateText:getString()
    data["interfaceType"] = "J"
    if self.family_id and tonumber(self.family_id) > 0 then
        data["groupId"] = self.family_id
    end
    local _hour1 = self.showtime1:getString()
    local _hour2 = self.showtime2:getString()
    if tonumber(_hour1) < 10 then
        _hour1 = "0" .. _hour1
    end
    if tonumber(_hour2) < 10 then
        _hour2 = "0" .. _hour2
    end
    data["startTime"] = self.btnDateTxt1:getString() .. " " ..  _hour1
    data["endTime"] = self.btnDateTxt2:getString() .. " " .. _hour2

    if self.checkAll:isSelected() then
        data["isAllReuslt"] = 1
    end
    
    -- data["isAllReuslt"] = 1


    ReqMgr:request(EVENTNAME.selectClubPlayInfo, data, handler(self, self.resultAllInfo),{},nil,true)
end

function statistical_qzj:resultAllInfo(event)
    local netData = event.netData
    local data = netData.data


    self.rightListInfo = data.ClubPlayInfoVo

    self.rightListShowInfo = {}
    for index, value in ipairs(self.rightListInfo) do
        table.insert(self.rightListShowInfo, value)
    end

    -- 刷新左侧列表

    self.leftInfoList = data.myAgentList
    self:resultInfo()

    table.sort( self.rightListShowInfo, function(a, b)
        -- if self.sortUp == true then
            return a.changePoint > b.changePoint
        -- else
        --     return a.changePoint > b.changePoint
        -- end
    end)

    for index, value in ipairs(self.rightListShowInfo) do
        value.rankIndex = index
    end

    self:updateRightListInfo()
end

function statistical_qzj:resetSelectLeftItem( sender )
    for index, value in ipairs(self.leftItems) do
        value:getChildByName("backb"):setVisible(true)
        value:getChildByName("backr"):setVisible(false)
    end
    sender.target:getChildByName("backb"):setVisible(false)
    sender.target:getChildByName("backr"):setVisible(true)
end

function statistical_qzj:resetBtnState( btns,btn )
    dump(btns)
    for index, value in ipairs(btns) do
        value:getChildByName("backb"):setVisible(true)
        value:getChildByName("backr"):setVisible(false)
    end
    btn:getChildByName("backb"):setVisible(false)
    btn:getChildByName("backr"):setVisible(true)
end

function statistical_qzj:resultInfo( event )
    self.leftListInfo:setVisible(false)
    for i, info in ipairs(self.leftListV:getChildren()) do
        if i ~= 1 then
            info:removeSelf()
        end
    end

    self.leftItems = {}

    if self.roleType == 0 or self.roleType == 1 then    -- 盟主或管理员 
        self.lastLeftType = 1
        self.leftListInfo:setVisible(true)
        self.leftListInfo:getChildByName("backb"):setVisible(false)
        self.leftListInfo:getChildByName("backr"):setVisible(true)
        self.leftListInfo:getChildByName("textinput"):setString("群数据")
        self.leftItems[1] = self.leftListInfo
        self.leftListInfo:onClick(function(sender)
            self:resetBtnState(self.leftItems,sender.target)
            self.lastLeftType = 1
            dump("-------------------------------------111")
            -- self:resetSelectLeftItem(sender)
            self.input_word:setString("")
            self.rightListShowInfo = {}
            for index, value in ipairs(self.rightListInfo) do
                table.insert(self.rightListShowInfo, value)
            end

            self:sortRightListShowInfo(1,true)
            self:updateRightListInfo()
        end, true)

        local infoNode = self.leftListInfo:clone()
        infoNode:setVisible(true)
        infoNode:getChildByName("backb"):setVisible(true)
        infoNode:getChildByName("backr"):setVisible(false)
        infoNode:getChildByName("textinput"):setString("我的数据")
        infoNode:onClick(function(sender,param)
            dump("-------------------------------------222")
            self:resetBtnState(self.leftItems,sender.target)

            self.lastLeftType = 0
            -- self:resetSelectLeftItem(sender)
            -- 查询我的数据
            self.input_word:setString("")
            self.rightListShowInfo = {}
            for index, value in ipairs(self.rightListInfo) do
                if value.pUid == USER_INFO["uid"] or value.uid == USER_INFO["uid"] then
                    table.insert(self.rightListShowInfo, value)
                end
            end

            self:sortRightListShowInfo(1,true)
            self:updateRightListInfo()
        end, true)

        self.leftListV:addChild(infoNode)
        self.leftItems[2] = infoNode

        local index = 1
        for i, info in ipairs(self.leftInfoList) do
            if info.uid ~= USER_INFO["uid"] then
                local infoNode = self.leftListInfo:clone()
                infoNode:setVisible(true)
                infoNode:getChildByName("backb"):setVisible(true)
                infoNode:getChildByName("backr"):setVisible(false)
                
                local strName = require("hall.GameCommon"):formatNick(info.nickName or "0")
                infoNode:getChildByName("textinput"):setString(strName .. "\n" .. info.uid)
                self.leftListV:addChild(infoNode)
                self.leftItems[2+index] = infoNode
    
                infoNode:onClick(function(sender)
                    dump("-------------------------------------333")
                    self:resetBtnState(self.leftItems,sender.target)

                    self.lastLeftType = info.uid

                    self.input_word:setString("")
                    self.rightListShowInfo = {}
                    for index, value in ipairs(self.rightListInfo) do
                        if value.pUid == info.uid then
                            table.insert(self.rightListShowInfo, value)
                        end
                    end
                    self:sortRightListShowInfo(1,true)
                    self:updateRightListInfo()

                end, true)
                index = index + 1
            end
        end
    elseif self.roleType == 2 then      -- 合伙人
        self.lastLeftType = 0

        self.leftListInfo:setVisible(true)
        local infoNode = self.leftListInfo
        infoNode:setVisible(true)
        infoNode:getChildByName("backb"):setVisible(false)
        infoNode:getChildByName("backr"):setVisible(true)
        infoNode:getChildByName("textinput"):setString("我的数据")
        infoNode:onClick(function(sender)
            dump("-------------------------------------222")
            self:resetBtnState(self.leftItems,sender.target)

            self.lastLeftType = 0
            self.input_word:setString("")
            self.rightListShowInfo = {}
            for index, value in ipairs(self.rightListInfo) do
                if value.pUid == USER_INFO["uid"] or value.uid == USER_INFO["uid"] then
                    table.insert(self.rightListShowInfo, value)
                end
            end
            self:sortRightListShowInfo(1,true)
            self:updateRightListInfo()
        end, true)
        -- self.leftListV:addChild(infoNode)
        self.leftItems[1] = infoNode

        local index = 1
        for i, info in ipairs(self.leftInfoList) do
            if info.uid ~= USER_INFO["uid"] then
                local infoNode = self.leftListInfo:clone()
                infoNode:setVisible(true)
                infoNode:getChildByName("backb"):setVisible(true)
                infoNode:getChildByName("backr"):setVisible(false)
                local strName = require("hall.GameCommon"):formatNick(info.nickName or "0")
                infoNode:getChildByName("textinput"):setString(strName .. "\n" .. info.uid)
                self.leftListV:addChild(infoNode)
                self.leftItems[1+index] = infoNode
    
                infoNode:onClick(function(sender)
                    dump("-------------------------------------333")
                    self:resetBtnState(self.leftItems,sender.target)

                    -- self:resetSelectLeftItem(sender)
                    self.lastLeftType = info.uid

                    self.input_word:setString("")
                    self.rightListShowInfo = {}
                    for index, value in ipairs(self.rightListInfo) do
                        if value.pUid == info.uid then
                            table.insert(self.rightListShowInfo, value)
                        end
                    end
                    self:sortRightListShowInfo(1,true)
                    self:updateRightListInfo()

                end, true)
                index = index + 1
            end
        end
    else
        self.lastLeftType = 0
        self.leftListInfo:setVisible(true)
        local infoNode = self.leftListInfo
        infoNode:setVisible(true)
        infoNode:getChildByName("backb"):setVisible(false)
        infoNode:getChildByName("backr"):setVisible(true)
        infoNode:getChildByName("textinput"):setString("我的数据")
        infoNode:onClick(function(sender)
            dump("-------------------------------------222")
            -- self:resetSelectLeftItem(sender)
        end, true)
        -- self.leftListV:addChild(infoNode)
        self.leftItems[1] = infoNode
    end
    
    self.leftListV:setInnerContainerSize(cc.size(260,#self.leftItems*100))

end


function statistical_qzj:onClickBtnClose()
    ReqMgr:delHandle("statistical_qzj", EVENTNAME)
    self:removeSelf()
end

function statistical_qzj:clearRightList()
    self.roleInfoPanel:setVisible(false)
    for i, info in ipairs(self.roleListV:getChildren()) do
        if i ~= 1 then
            info:removeSelf()
        end
    end
end

-- 右侧列表总数据  self.rightListInfo
-- 搜ID  当前右列表筛选  
function statistical_qzj:onClickSearchBtn()
    -- dump(self.input_word)
    -- self.input_word:setString("")
    
    -- self.rightListShowInfo = {}

    if self.input_word:getString() == "" then
        -- for index, value in ipairs(self.rightListInfo) do
        --     table.insert(self.rightListShowInfo, value)
        -- end
        self:updateRightListInfo()
        return 
    end

    for index, value in ipairs(self.rightListShowInfo) do
        if self.input_word:getString() == "" .. value.uid then
            self:updateRightListInfo(value)
            return
        end
    end
end



function statistical_qzj:sortRightInfo(index)
    self.input_word:setString("")
    self.rightListShowInfo = {}

    if self.roleType == 0 or self.roleType == 1 then    -- 盟主或管理员 
        if self.lastLeftType == 1 then
            for index, value in ipairs(self.rightListInfo) do
                table.insert(self.rightListShowInfo, value)
            end
        elseif self.lastLeftType == 0 then
            for index, value in ipairs(self.rightListInfo) do
                if value.pUid == USER_INFO["uid"] or value.uid == USER_INFO["uid"] then
                    table.insert(self.rightListShowInfo, value)
                end
            end
        else
            for index, value in ipairs(self.rightListInfo) do
                if value.pUid == self.lastLeftType then
                    table.insert(self.rightListShowInfo, value)
                end
            end
        end
    elseif self.roleType == 2 then
        if self.lastLeftType == 0 then
            for index, value in ipairs(self.rightListInfo) do
                if value.pUid == USER_INFO["uid"] or value.uid == USER_INFO["uid"] then
                    table.insert(self.rightListShowInfo, value)
                end
            end
        else
            for index, value in ipairs(self.rightListInfo) do
                if value.pUid == self.lastLeftType then
                    table.insert(self.rightListShowInfo, value)
                end
            end
        end
    else
        for index, value in ipairs(self.rightListInfo) do
            table.insert(self.rightListShowInfo, value)
        end
    end

    -- if index ~= 1 then
    table.sort(self.rightListShowInfo, function(a, b)
        return a.changePoint > b.changePoint
    end)

    for index, value in ipairs(self.rightListShowInfo) do
        value.rankIndex = index
    end
    -- end
    dump(self.rightListShowInfo)

    self:sortRightListShowInfo(index)
    dump(self.rightListShowInfo)
    self:updateRightListInfo()
end

function statistical_qzj:sortRightListShowInfo(index,up)
    self.pxIndexSp:setVisible(true)
    self.pxIndexSp:setPosition(cc.p( self.pxTexts[index]:getPosition().x , self.pxTexts[index]:getPosition().y+2))


    if up then
        self.lastSortIndex = index
        self.sortUp = true
    else
        if self.lastSortIndex == index then
            if self.sortUp == true then
                self.sortUp = false
            else
                self.sortUp = true
            end
        else
            self.lastSortIndex = index
            self.sortUp = true
        end
    end

    table.sort(self.rightListShowInfo, function(a, b)
        if index == 1 then
            if self.sortUp == true then
                return a.changePoint > b.changePoint
            else
                return a.changePoint < b.changePoint
            end
        elseif index == 3 then
            if self.sortUp == true then
                return a.changePoint > b.changePoint
            else
                return a.changePoint < b.changePoint
            end
        elseif index == 4 then
            if self.sortUp == true then
                return a.playCount > b.playCount
            else
                return a.playCount < b.playCount
            end
        elseif index == 5 then
            if self.sortUp == true then
                return a.dyjCount > b.dyjCount
            else
                return a.dyjCount < b.dyjCount
            end
        elseif index == 6 then
            if self.sortUp == true then
                return a.profitCount > b.profitCount
            else
                return a.profitCount < b.profitCount
            end
        elseif index == 7 then
            if self.sortUp == true then
                return a.profitTimes > b.profitTimes
            else
                return a.profitTimes < b.profitTimes
            end
        end
    end)

    if index == 1 then
        if self.sortUp then
            for index, value in ipairs(self.rightListShowInfo) do
                value.rankIndex = index
            end
        else
            for index, value in ipairs(self.rightListShowInfo) do
                value.rankIndex = #self.rightListShowInfo - index + 1
            end
        end
        
    end
end


function statistical_qzj:updateRightListInfo(sinfo)
    self:clearRightList()

    local infoNode = nil
    local allNum = 0
    local allScore = 0
    local allGameNum = 0
    local allWin = 0
    local allSendFace = 0
    local allSendSNum = 0

    if sinfo then
        infoNode = self.roleInfoPanel
        infoNode:setVisible(true)
        local info = sinfo
        
        infoNode:getChildByName("info"):getChildByName("Text_1"):setString("1")
        require("hall.GameCommon"):getUserHead(info.smallIcon, "", "", infoNode:getChildByName("info"):getChildByName("headImg"), 69, false, "", true)

        local strName = require("hall.GameCommon"):formatNick(info.nickName or "0")
        infoNode:getChildByName("info"):getChildByName("Text_2"):setString(strName)

        infoNode:getChildByName("info"):getChildByName("Text_3"):setString(info.uid)
        infoNode:getChildByName("info"):getChildByName("Text_4"):setString( string.format("%.2f", info.changePoint/100))
        infoNode:getChildByName("info"):getChildByName("Text_5"):setString(info.playCount)
        infoNode:getChildByName("info"):getChildByName("Text_6"):setString(info.dyjCount)
        infoNode:getChildByName("info"):getChildByName("Text_7"):setString(  string.format("%.2f", info.profitCount/100))
        infoNode:getChildByName("info"):getChildByName("Text_8"):setString(info.profitTimes)
        allScore = allScore + info.changePoint/100
        allGameNum = allGameNum + info.playCount
        allWin = allWin + info.dyjCount
        allSendFace = allSendFace + info.profitCount/100
        allSendSNum = allSendSNum + info.profitTimes
    else
        self.itemList = {}

        for i, info in ipairs(self.rightListShowInfo) do
            allNum = allNum + 1
            -- self:setRecordInfo(infoNode,info)
            allScore = allScore + info.changePoint/100
            allGameNum = allGameNum + info.playCount
            allWin = allWin + info.dyjCount
            allSendFace = allSendFace + info.profitCount/100
            allSendSNum = allSendSNum + info.profitTimes
        end


        self.cacheItemNum = 4
        self.contH = self.roleListV:getContentSize().height   
        self.itemH = self.roleInfoPanel:getContentSize().height
        self.allTripH = self.contH - self.itemH * #self.rightListShowInfo -- 总可滑动行程
        self.numPerPage = math.ceil(self.contH/self.itemH)
        self.roleInfoPanel:setVisible(false)

        self.allNum2 = #self.rightListShowInfo
        local endIndex = 20
        if self.allNum2 < endIndex then
            endIndex = self.allNum2
        end
        local allInnerContH = self.itemH*self.allNum2
        if allInnerContH < 360 then
            allInnerContH = 360
        end

        for i = 1, endIndex do
            local info = self.rightListShowInfo[i]
        -- for i, info in ipairs(self.rightListShowInfo) do
            if i == 1 then
                infoNode = self.roleInfoPanel
                infoNode:setVisible(true)
            else
                infoNode = self.roleInfoPanel:clone()
                infoNode:setVisible(true)
                self.roleListV:addChild(infoNode)
            end

            infoNode:setPositionY(allInnerContH - i*self.itemH)
            self.itemList[i] = infoNode

            infoNode:getChildByName("info"):getChildByName("Text_1"):setString(info.rankIndex)
            require("hall.GameCommon"):getUserHead(info.smallIcon, "", "", infoNode:getChildByName("info"):getChildByName("headImg"), 69, false, "", true)
            
            local strName = require("hall.GameCommon"):formatNick(info.nickName or "0")
            infoNode:getChildByName("info"):getChildByName("Text_2"):setString(strName)

            infoNode:getChildByName("info"):getChildByName("Text_3"):setString(info.uid)
            infoNode:getChildByName("info"):getChildByName("Text_4"):setString(string.format("%.2f", info.changePoint/100))
            infoNode:getChildByName("info"):getChildByName("Text_5"):setString(info.playCount)
            infoNode:getChildByName("info"):getChildByName("Text_6"):setString(info.dyjCount)
            infoNode:getChildByName("info"):getChildByName("Text_7"):setString(string.format("%.2f", info.profitCount/100))
            infoNode:getChildByName("info"):getChildByName("Text_8"):setString(info.profitTimes)
        end
        self.roleListV:setInnerContainerSize(cc.size(934,allInnerContH))


    end

    self.allNum:setString("" .. allNum .. "人")
    self.allScore:setString("" .. string.format("%.2f", allScore) )
    self.allGame:setString("" .. allGameNum)
    self.allWin:setString("" .. allWin)
    self.allSend:setString("" .. string.format("%.2f", allSendFace) )
    self.allSendGame:setString("" .. allSendSNum)

    -- self.roleListV:setInnerContainerSize(cc.size(934,90*allNum))
end




function statistical_qzj:onExit()
    ReqMgr:delHandle("statistical_qzj", EVENTNAME)
end


-- -- uid : 0 群数据  uid==自己UID
-- function statistical_qzj:reqRightInfo(uid)
--     if USER_INFO["uid"] == uid then
--         -- 查看自己 我的数据
--     elseif 0 == uid then
--         -- 查看群数据
--     else
--         -- 查看下面合伙人的数据

--     end
    
--     local strDate1 = self.btnDateTxt1:getString()
--     local _, _, y1, m1, d1 = string.find(strDate1, "(%d+)-(%d+)-(%d+)");
--     local _hour1 = tonumber(self.timeEdit[1]:getText())

--     local strDate2 = self.btnDateTxt2:getString()
--     local _, _, y2, m2, d2 = string.find(strDate2, "(%d+)-(%d+)-(%d+)");
--     local _hour2 = tonumber(self.timeEdit[2]:getText())

--     local timestamp1 = os.time({year=y1, month = m1, day = d1, hour = _hour1, min = 0, sec = 0});
--     local timestamp2 = os.time({year=y2, month = m2, day = d2, hour = _hour2, min = 0, sec = 0});

--     -- -- 是否选中完成所有局
--     -- self.checkAll:isSelected()
-- end


-- function statistical_qzj:reqLeftInfo()
--     self.leftListInfo:setVisible(false)

--     if self.roleType == 0 or self.roleType == 1 then
--         self.leftInfoList = {}
--         for i = 1, 20 do
--             local info = {
--                 name = "名称" .. i,
--                 uid = i + 10000,
--             }
--             self.leftInfoList[i] = info
--         end

--         self:reqRightInfo(0)

--         self:resultInfo()
--     elseif self.roleType == 2 then
--         self.leftInfoList = {}
--         for i = 1, 20 do
--             local info = {
--                 name = "名称" .. i,
--                 uid = i + 10000,
--             }
--             self.leftInfoList[i] = info
--         end

--         -- 请求左边列表  下属合伙人
--             -- local page = page or 1
--     -- local searchid = searchid or 0

--     -- local data = {}
--     -- data["XYUid"] = USER_INFO["uid"]
--     -- data["currentPage"] = page
--     -- data["pageSize"] = self.page_num
--     -- data["type"] = self.type
--     -- data["searchId"] = psearchid
--     -- data["interfaceType"] = "J"
--     -- if self.family_id and tonumber(self.family_id) > 0 then
--     --     data["groupId"] = self.family_id
--     -- end
    
--     -- ReqMgr:request(EVENTNAME.QUERY_ACTIVITIES_RESULT, data, handler(self, self.resultInfo), {page = page, type = self.type})
        
        
--         -- self.leftInfoList = {}
--         -- for i = 1, 20 do
--         --     local info = {
--         --         name = "名称" .. i,
--         --         uid = i + 10000,
--         --     }
--         --     self.leftInfoList[i] = info
--         -- end

--         self:resultInfo()
--     elseif self.roleType == 3 then
--         self.cytjBtn:setVisible(false)
--         self.jyztBtn:setVisible(false)
--         self.qtjBtn:setVisible(false)
--         self.allBack:setVisible(false)

--         self.qzjNode:getChildByName("tip_bg4"):setVisible(false)
--         self.btnDate1:setVisible(false)
--         self.btnDate2:setVisible(false)
--         -- self.checkAll:setVisible(false)
--         self.timeBack1:setVisible(false)
--         self.timeBack2:setVisible(false)
--         self.qzjNode:getChildByName("statictext"):setVisible(false)
--         self.qzjNode:getChildByName("statictext_0"):setVisible(false)
--         self.qzjNode:getChildByName("tip_bg2"):setVisible(false)
--         self.btnSearch:setVisible(false)

--         self:resultInfo()
--     end
-- end

return statistical_qzj