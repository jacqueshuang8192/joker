-- 房间记录
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local statistical_fjjl = class("statistical_fjjl", NewViewBaseLayer)
-- local statistical_fjjl = class("statistical_fjjl",function()
--     return display.newLayer("statistical_fjjl")
-- end)

local EVENTNAME = {
	QUERY_ACTIVITIES_RESULT = "/freeGame/queryActivitiesResult",
    -- SELECT_POINT_CHANGE_HISTORY = "/selectPointChangeHistory",
    QUERY_CARD_ACTIVITIES2_ROUND_BY_USERID = '/freeGame/queryCardActivities2RoundByUserId',
}

function statistical_fjjl:ctor(family_id, roleType)
    self.family_id = family_id
    self.roleType = roleType

    local path = "hall/res/FriendScircle/statistical_fjjl.csb"
    statistical_fjjl.super.ctor(self, path)

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

    self.type = 2 --type =2 => 积分 type =3 => 房卡  1:百人场
    self.page_num = 5
    self.curPage = 1
    self.tatolPage = 1
    self.infoList = {}
    
    local recordVideoStr = cc.UserDefault:getInstance():getStringForKey("recordVideo")
    if recordVideoStr == nil or recordVideoStr == "" then
        self.recordVideo = {}
    else
        self.recordVideo = json.decode(recordVideoStr)
    end

    self:initUI()
    self:reqInfo(1)
end

function statistical_fjjl:initUI()
    -- self.root = self._csbNode:getChildByName("root")
    local wanfaBg = self.root:getChildByName("wanfaBg")
    self.btnClose = wanfaBg:getChildByName("btnClose")
    self.qzjNode = self.root:getChildByName("qzjNode")

    -- 时间选择
    self.btnDate1 = self.qzjNode:getChildByName("btninput1")
    self.btnDateTxt1 = self.btnDate1:getChildByName("textinput1")
    self.btnDateTxt1:setString(os.date("%Y-%m-%d", os.time()))

    -- ID搜索
    self.input_word = self.qzjNode:getChildByName("time1"):getChildByName("input_word")
    self.qzjNode:getChildByName("time1"):setVisible(false)

    -- 页码
    self.btnPageL = self.root:getChildByName("btnPageL")
    self.btnPageR = self.root:getChildByName("btnPageR")
    self.labelPage = self.root:getChildByName("labelPage")

    -- 总信息
    local allInfoBack = self.qzjNode:getChildByName("tip_bg3")
    self.allGameNum = allInfoBack:getChildByName("Text_1")
    self.allScore = allInfoBack:getChildByName("Text_2")
    self.allWinNum = allInfoBack:getChildByName("Text_3")

    
    self.txt_message = self.root:getChildByName("txt_message")
    self.roleListV = self.qzjNode:getChildByName("ScrollView_1")
    self.roleListV:setScrollBarEnabled(false)

    self.roleInfoPanel = self.roleListV:getChildByName("info")
    self.roleInfoPanel:setVisible(false)


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

    self:initEvent()
end

function statistical_fjjl:initEvent()
    ReqMgr:addHandle("statistical_fjjl", EVENTNAME)

    self.btnDate1:onClick(handler(self, self.onClickDateSelect), true)
    self.btnClose:onClick(handler(self, self.onClickBtnClose), true)
    self.btnPageL:onClick(handler(self, self.onClickBtnPageL), true)
    self.btnPageR:onClick(handler(self, self.onClickBtnPageR), true)

    self.cytjBtn:onClick(handler(self, self.onClickcytjBtn), true)
    self.jyztBtn:onClick(handler(self, self.onClickjyztBtn), true)
    self.qtjBtn:onClick(handler(self, self.onClickqtjBtn), true)
    self.fjjlBtn:onClick(handler(self, self.onClickfjjlBtn), true)
end

function statistical_fjjl:refrashRecordByIndex(idx)
    self.btnDateTxt1:setString(os.date("%Y-%m-%d", idx))
    self:reqInfo(1)
end

function statistical_fjjl:onClickDateSelect()
    local statistical_cytj = require("hall.record.RecordSelDateLayer").new(10)
    statistical_cytj:addTo(self)
end

function statistical_fjjl:onClickcytjBtn()
    local statistical_cytj = require("hall.familyCircle.statistical_cytj").new(self.family_id,self.roleType)
    statistical_cytj:addTo(self:getParent())
    
    self:removeSelf()
end

function statistical_fjjl:onClickjyztBtn()
    local statistical_jy = require("hall.familyCircle.statistical_jy").new(self.family_id,self.roleType)
    statistical_jy:addTo(self:getParent())
    
    self:removeSelf()
end

function statistical_fjjl:onClickqtjBtn()
    local statistical_qtj = require("hall.familyCircle.statistical_qtj").new(self.family_id,self.roleType)
    statistical_qtj:addTo(self:getParent())
    
    self:removeSelf()
end

function statistical_fjjl:onClickfjjlBtn()
    local statistical_fjjl = require("hall.familyCircle.statistical_fjjl").new(self.family_id,self.roleType)
    statistical_fjjl:addTo(self:getParent())

    self:removeSelf()
end

function statistical_fjjl:onClickBtnClose()
    self:removeSelf()
end

function statistical_fjjl:onClickBtnPageL()
    if self.curPage > 1 then
        self.input_word:setString("")
        self:reqInfo(self.curPage - 1)
    end
end

function statistical_fjjl:onClickBtnPageR()
    if self.curPage < self.tatolPage then
        self.input_word:setString("")
        self:reqInfo(self.curPage + 1)
    end
end

function statistical_fjjl:reqInfo(page,searchid)
    local page = page or 1
    local searchid = searchid or 0

    local data = {}
    data["XYUid"] = USER_INFO["uid"]
    data["currentPage"] = page
    data["pageSize"] = self.page_num
    data["type"] = self.type
    data["searchId"] = psearchid
    data["interfaceType"] = "J"
    data["resultDate"] = self.btnDateTxt1:getString()
    
    if self.family_id and tonumber(self.family_id) > 0 then
        data["groupId"] = self.family_id
    end
    dump(data)
    ReqMgr:request(EVENTNAME.QUERY_ACTIVITIES_RESULT, data, handler(self, self.resultZJ), {page = page, type = self.type})
end

function statistical_fjjl:resultZJ( event )
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error

    dump(data)

    if netData.returnCode == 0 then
        self.allGameNum:setString("总场次:"..data.playInfo.playCount)
        self.allScore:setString("总分数:"..string.format("%.2f", data.playInfo.changePoint/100) )
        self.allWinNum:setString("大赢家:"..data.playInfo.dyjCount)
        

        self.txt_message:setVisible(#data.list <= 0)
        
        self.tatolPage = math.max(math.ceil(data.playInfo.playCount / self.page_num),1)

        self.curPage = param.page
        self.labelPage:setString(self.curPage.."/"..self.tatolPage)
        self.infoList = data.list
        self:refreshList()
    else
        -- 返回错误
    end
end

function statistical_fjjl:refreshList()
    self.roleInfoPanel:setVisible(false)
    for i, info in ipairs(self.roleListV:getChildren()) do
        if i ~= 1 then
            info:removeSelf()
        end
    end

    local infoNode = nil
    local allNum = #self.infoList
    local allInnerContH = 176*allNum
    if allInnerContH < 470 then
        allInnerContH = 470
    end

    for i, info in ipairs(self.infoList or {}) do
        if i == 1 then
            infoNode = self.roleInfoPanel
            infoNode:setVisible(true)
        else
            infoNode = self.roleInfoPanel:clone()
            infoNode:setVisible(true)
            self.roleListV:addChild(infoNode)
        end
        infoNode:setPositionY(allInnerContH - (i-1)*176 - 88)
        self:setRecordInfo(infoNode,info)
    end
    self.roleListV:setInnerContainerSize(cc.size(1208,allInnerContH))
end

function statistical_fjjl:setRecordInfo(recordNode,recordInfo)
    local contInfo = json.decode(recordInfo.content)
    recordNode:getChildByName("nameText"):setString(contInfo.gameName)
    recordNode:getChildByName("circleIdText"):setString("亲友圈:"..self.family_id)
    recordNode:getChildByName("videoText"):setString("回放码:".. contInfo.roomNum)
    recordNode:getChildByName("timeText"):setString(os.date("%Y/%m/%d %H:%M:%S", contInfo.gameTime))
    recordNode:getChildByName("checkBox"):setSelected(false)
    for index, value in ipairs(self.recordVideo) do
        if value == recordInfo.id then
            recordNode:getChildByName("checkBox"):setSelected(true)
        end
    end

    local roleNodes = {}
    for i = 1, 4 do
        roleNodes[i] = recordNode:getChildByName("rolePanel"..i)
        roleNodes[i]:setVisible(false)
    end

    dump(contInfo.userinfos,"contInfo.userinfos==>>>")
    for i, role in ipairs(contInfo.userinfos or {}) do
        if roleNodes[i] then
            roleNodes[i]:setVisible(true)
            self:setRoleInfo(roleNodes[i],role)
        end
    end

    recordNode:getChildByName("checkBox"):addClickEventListener(function(sender)
        local isselect = recordNode:getChildByName("checkBox"):isSelected()
        if isselect then
            local isfind = false
            for index, value in ipairs(self.recordVideo) do
                if value == recordInfo.id then
                    isfind = true
                end
            end
            if not isfind then
                table.insert(self.recordVideo,recordInfo.id)
            end
        else
            local isfind = false
            for index, value in ipairs(self.recordVideo) do
                if value == recordInfo.id then
                    table.remove(self.recordVideo, index)
                    break
                end
            end
        end
        
        cc.UserDefault:getInstance():setStringForKey("recordVideo",json.encode(self.recordVideo))
    end)

    recordNode:getChildByName("btnmem"):addClickEventListener(function(sender)
        -- self:openDetails(recordInfo)
        local statistical_fjjl_replay = require("hall.familyCircle.statistical_fjjl_replay").new(self.family_id, self.roleType,recordInfo.level,recordInfo.activityId,nil)
        statistical_fjjl_replay:addTo(self)
    end)
end

function statistical_fjjl:onClickBtnmem()
end

function statistical_fjjl:openDetails(recordInfo)

end

function statistical_fjjl:openDetails(recordInfo)
    -- videoid  activityId
    -- videoid  activityId
    -- require("hall.record.RecordLayerInfo").new(recordInfo.activityId, recordInfo.level, nil, self.roleType):addTo(SCENENOW.scene)

    -- 输入回放码回放
    -- require("hall.record.RecordLayerInfo").new(nil, nil, inviteCode, self.roleType):addTo(SCENENOW.scene)

    
-- function RecordLayerInfo:getZJInfo(activityId, inviteCode)
    local data = {}
    data['userId'] = USER_INFO['uid']
    data['activityId'] = recordInfo.activityId
    data['interfaceType'] = 'J'

    dump(data)
    ReqMgr:request(EVENTNAME.QUERY_CARD_ACTIVITIES2_ROUND_BY_USERID, data, handler(self, self.resultVideo))
-- end

end

function statistical_fjjl:resultVideo( event )

    local netData = event.netData
    dump(netData, '===成功返回战绩详情===')

    if netData.returnCode == 0 then
        -- dump(netData.data, '===成功返回战绩详情===')
        local sData = netData.data
        if sData == nil or #sData <= 0 then
            viewMgr:showTip({text = '战绩不存在...'})
            -- self:onClickBtnReturn()
            return
        end

        if sData ~= nil and self then
            -- self:updateTableView(sData)
        end
    else
        viewMgr:showTip({text = '战绩不存在...'})
        -- self:onClickBtnReturn()
    end

end

function statistical_fjjl:setRoleInfo(roleNode,roleInfo)
    local strName = require("hall.GameCommon"):formatNick(roleInfo.nickName or "0")
    roleNode:getChildByName("Text_2"):setString(strName)


    roleNode:getChildByName("Text_3"):setString(roleInfo.uid)
    if roleInfo.score > 0 then
        roleNode:getChildByName("Text_1"):setTextColor(cc.c3b(60,191,146))
        roleNode:getChildByName("Text_1"):setString("+" .. string.format("%.2f", roleInfo.score/100) )
    elseif roleInfo.score < 0 then
        roleNode:getChildByName("Text_1"):setTextColor(cc.c3b(226,60,60))
        roleNode:getChildByName("Text_1"):setString(string.format("%.2f", roleInfo.score/100))
    elseif roleInfo.score == 0 then
        roleNode:getChildByName("Text_1"):setTextColor(cc.c3b(60,191,146))
        roleNode:getChildByName("Text_1"):setString(string.format("%.2f", roleInfo.score/100))
    end
    require("hall.GameCommon"):getUserHead(roleInfo.photoUrl, "", "", roleNode:getChildByName("headImg"), 69, false, "", true)
end

function statistical_fjjl:onExit()
    ReqMgr:delHandle("statistical_fjjl", EVENTNAME)
end

return statistical_fjjl